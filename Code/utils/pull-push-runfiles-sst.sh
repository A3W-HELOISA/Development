#!/usr/bin/env bash
set -euo pipefail

# Defaults (you can override with flags)
SRC_REPO="git@github.com:CDXi-solutions/sea-surface-temperature.git"
SRC_BRANCH="binaries"
DEST_REPO_LOCAL="/home/kostageo/Projects/HELOISA-software/integration-tests/water-monitoring-integration-tests"
DEST_SUBPATH="water-quality/sst/run-files"
COMMIT_MSG="Update sst run-files (sst.cwl, inputs.yaml)"
VERBOSE=0
FORCE=0   # if 1, stash local changes in dest repo to allow pull
QUIET_GIT=--quiet

# Replacement defaults
REWRITE_FROM='dockerPull: "ghcr.io/cdxi-solutions/sst-service:bin"'
REWRITE_TO='dockerPull: "ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/sst-service:latest"'

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --src-repo URL            Source repo (default: $SRC_REPO)
  --src-branch NAME         Source branch (default: $SRC_BRANCH)
  --dest-repo PATH          Local path to destination repo (default: $DEST_REPO_LOCAL)
  --dest-subpath PATH       Subpath inside the destination repo (default: $DEST_SUBPATH)
  --commit-msg TEXT         Commit message (default set)
  --rewrite-from TEXT       Text to replace in reference_muddy.cwl
  --rewrite-to TEXT         Replacement text for reference_muddy.cwl
  --force                   Stash local changes in destination repo before pulling
  -v, --verbose             Verbose output
  -h, --help                Show this help

Example:
  $0 --dest-repo "/home/kostageo/Projects/HELOISA-software/integration-tests/water-monitoring-integration-tests" \\
     --dest-subpath "water-quality/extreme-events/run-files"
EOF
}

log(){ echo "[$(date +'%F %T')] $*"; }
err(){ echo "ERROR: $*" >&2; exit 1; }
warn(){ echo "WARN: $*" >&2; }

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --src-repo) SRC_REPO="$2"; shift 2;;
    --src-branch) SRC_BRANCH="$2"; shift 2;;
    --dest-repo) DEST_REPO_LOCAL="$2"; shift 2;;
    --dest-subpath) DEST_SUBPATH="$2"; shift 2;;
    --commit-msg) COMMIT_MSG="$2"; shift 2;;
    --rewrite-from) REWRITE_FROM="$2"; shift 2;;
    --rewrite-to) REWRITE_TO="$2"; shift 2;;
    --force) FORCE=1; shift;;
    -v|--verbose) VERBOSE=1; QUIET_GIT=""; shift;;
    -h|--help) usage; exit 0;;
    *) err "Unknown argument: $1";;
  esac
done

[[ $VERBOSE -eq 1 ]] && set -x

# Basic checks
command -v git >/dev/null 2>&1 || err "git not found"
[[ -d "$DEST_REPO_LOCAL/.git" ]] || err "Destination repo '$DEST_REPO_LOCAL' is not a git repo"

# Determine default branch of destination remote
determine_default_branch() {
  local repo="$1"
  local def
  def=$(git -C "$repo" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p' || true)
  if [[ -z "$def" ]]; then
    def=$(git -C "$repo" rev-parse --abbrev-ref HEAD || true)
    [[ -n "$def" ]] || def="main"
  fi
  echo "$def"
}

DEST_DEFAULT_BRANCH="$(determine_default_branch "$DEST_REPO_LOCAL")"
log "Destination repo default branch: $DEST_DEFAULT_BRANCH"

# Ensure remote origin is reachable
git -C "$DEST_REPO_LOCAL" ls-remote --exit-code origin >/dev/null 2>&1 || \
  err "Cannot reach 'origin' of destination repo. Check network/credentials."

# Handle local changes before pull
if ! git -C "$DEST_REPO_LOCAL" diff --quiet || ! git -C "$DEST_REPO_LOCAL" diff --cached --quiet; then
  if [[ $FORCE -eq 1 ]]; then
    log "Local changes detected. Stashing due to --force."
    git -C "$DEST_REPO_LOCAL" stash push -u -m "auto-stash before sync_extreme_events_files"
  else
    err "Local changes detected in $DEST_REPO_LOCAL. Commit/stash them or rerun with --force."
  fi
fi

# Sync destination repo with remote
log "Syncing destination repo with remote…"
git -C "$DEST_REPO_LOCAL" fetch $QUIET_GIT origin
git -C "$DEST_REPO_LOCAL" checkout $QUIET_GIT "$DEST_DEFAULT_BRANCH"
git -C "$DEST_REPO_LOCAL" pull $QUIET_GIT --rebase origin "$DEST_DEFAULT_BRANCH"

# Prepare temp workspace and shallow clone of source branch
WORKDIR="$(mktemp -d -t extreme-events-src-XXXXXX)"
cleanup(){ rm -rf "$WORKDIR"; }
trap cleanup EXIT

log "Cloning $SRC_REPO (branch: $SRC_BRANCH)…"
git clone $QUIET_GIT --depth 1 --branch "$SRC_BRANCH" "$SRC_REPO" "$WORKDIR/src"

# Locate the two files anywhere in the source tree
find_one() {
  local name="$1"
  local path
  path=$(find "$WORKDIR/src" -type f -name "$name" -print -quit)
  [[ -n "$path" ]] || err "Could not find '$name' in $SRC_REPO@$SRC_BRANCH"
  echo "$path"
}

SRC_MUDDY="$(find_one 'sst.cwl')"
SRC_INPUTS="$(find_one 'inputs.yaml')"

# Rewrite dockerPull line(s) in reference_muddy.cwl
log "Rewriting dockerPull line(s) in sst.cwl…"
before_count=$(grep -Fxc "$REWRITE_FROM" "$SRC_MUDDY" || true)
MODIFIED_CWL="$WORKDIR/sst.modified.cwl"
# Use '#' as sed delimiter (safe for URLs), and replace all occurrences
sed -e "s#${REWRITE_FROM//\#/\\#}#${REWRITE_TO//\#/\\#}#g" "$SRC_MUDDY" > "$MODIFIED_CWL"
after_count=$(grep -Fxc "$REWRITE_FROM" "$MODIFIED_CWL" || true)
changed=$(( before_count - after_count ))
if [[ $before_count -gt 0 ]]; then
  log "Replaced $changed occurrence(s) (found: $before_count)."
else
  warn "No exact occurrences of the expected line were found; file copied unchanged."
fi

# Build destination path
DEST_DIR="$DEST_REPO_LOCAL/$DEST_SUBPATH"
mkdir -p "$DEST_DIR"

# Pull changes in destination repo again to minimize conflicts
log "Pulling latest changes in destination repo again to minimize conflicts…"
git -C "$DEST_REPO_LOCAL" pull

# Copy/rename to muddy.cwl, and inputs.yaml unchanged
log "Copying files into $DEST_DIR…"
install -m 0644 "$MODIFIED_CWL" "$DEST_DIR/sst.cwl"
install -m 0644 "$SRC_INPUTS" "$DEST_DIR/inputs.yaml"

# Stage changes
git -C "$DEST_REPO_LOCAL" add "$DEST_DIR/sst.cwl" "$DEST_DIR/inputs.yaml"

# Commit only if there are changes
if git -C "$DEST_REPO_LOCAL" diff --cached --quiet; then
  log "No changes to commit (files identical)."
else
  log "Committing…"
  git -C "$DEST_REPO_LOCAL" commit -m "$COMMIT_MSG"
  log "Pushing to origin/$DEST_DEFAULT_BRANCH…"
  git -C "$DEST_REPO_LOCAL" push $QUIET_GIT origin "$DEST_DEFAULT_BRANCH"
fi

log "Done."
