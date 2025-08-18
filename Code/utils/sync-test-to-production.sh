#/bin/bash
# This script pushes the latest changes from the internal repository to the production repository.
git clone --depth 1 -b main git@github.com:kvlachos-cdxi/test-1.git /tmp/internal/ # Clone snapshot of production-ready source code (latest commit of main branch)
git clone git@github.com:kvlachos-cdxi/test-2.git /tmp/prod
cd /tmp/prod
git checkout main # or whatever production branch
rsync -a --delete --exclude='.git' --exclude='LICENSE' /tmp/internal/ /tmp/prod/ # sync files from internal to production
git add -A
git commit -m "New update"
git push origin main


#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config - Edit these values
# -----------------------------
INTERNAL_REPO="git@github.com:kvlachos-cdxi/test-1.git"
INTERNAL_BRANCH="main"
INTERNAL_DIR="/tmp/internal"

PROD_REPO="git@github.com:kvlachos-cdxi/test-2.git"
PROD_BRANCH="main"
PROD_DIR="/tmp/prod"

# If you want a dry-run (no push, rsync in -n mode), set DRY_RUN=true
DRY_RUN=false

# If your internal repo uses Git LFS and you want to pull LFS content, set to true
GIT_LFS_PULL=false

# -----------------------------
# Helpers
# -----------------------------
error() { echo "ERROR: $*" >&2; exit 1; }
info()  { echo "[info] $*"; }

# Only allow removals under /tmp or /var/tmp for safety
safe_rmdir() {
  local dir="$1"
  if [[ -z "$dir" ]]; then return 0; fi
  case "$dir" in
    /tmp/*|/var/tmp/*)
      rm -rf -- "$dir"
      ;;
    *)
      error "Refusing to remove '$dir' (not under /tmp or /var/tmp)."
      ;;
  esac
}

# Check if a directory is a git repo and its origin url equals the expected url
is_repo_with_origin() {
  local dir="$1"; shift
  local expected_url="$1"
  if [[ ! -d "$dir/.git" ]]; then
    return 1
  fi
  local url
  url=$(git -C "$dir" remote get-url origin 2>/dev/null || true)
  if [[ "$url" == "$expected_url" ]]; then
    return 0
  else
    return 1
  fi
}

# -----------------------------
# Main
# -----------------------------
info "Starting sync: internal -> prod"
info "DRY_RUN=$DRY_RUN  GIT_LFS_PULL=$GIT_LFS_PULL"

# Prepare internal checkout
if is_repo_with_origin "$INTERNAL_DIR" "$INTERNAL_REPO"; then
  info "Reusing existing internal checkout at $INTERNAL_DIR"
  cd "$INTERNAL_DIR"
  git remote set-url origin "$INTERNAL_REPO" 2>/dev/null || true
  git fetch --depth=1 origin "$INTERNAL_BRANCH"
  git checkout -f "$INTERNAL_BRANCH"
  git reset --hard origin/"$INTERNAL_BRANCH"
  git clean -fdx
else
  info "Creating fresh internal shallow clone at $INTERNAL_DIR"
  safe_rmdir "$INTERNAL_DIR" || true
  git clone --depth 1 --branch "$INTERNAL_BRANCH" "$INTERNAL_REPO" "$INTERNAL_DIR"
fi

# Optionally pull LFS (if enabled)
if [[ "$GIT_LFS_PULL" == "true" ]]; then
  if command -v git-lfs >/dev/null 2>&1; then
    info "Pulling LFS objects for internal repo"
    (cd "$INTERNAL_DIR" && git lfs pull --include="*" || true)
  else
    info "git-lfs not installed; skipping LFS pull"
  fi
fi

# Prepare prod checkout
if is_repo_with_origin "$PROD_DIR" "$PROD_REPO"; then
  info "Reusing existing prod checkout at $PROD_DIR"
  cd "$PROD_DIR"
  git remote set-url origin "$PROD_REPO" 2>/dev/null || true
  git fetch origin
  git checkout -f "$PROD_BRANCH"
  git reset --hard origin/"$PROD_BRANCH"
  git clean -fdx
else
  info "Creating fresh prod clone at $PROD_DIR"
  safe_rmdir "$PROD_DIR" || true
  git clone "$PROD_REPO" "$PROD_DIR"
  cd "$PROD_DIR"
  git checkout "$PROD_BRANCH"
fi

# rsync exclude args: only .git and LICENSE
RSYNC_EXCLUDE_ARGS=(--exclude='.git' --exclude='LICENSE')

# rsync options
RSYNC_OPTS=(-a --delete)
if [[ "$DRY_RUN" == "true" ]]; then
  RSYNC_OPTS+=(-n -v)
fi

info "Running rsync from $INTERNAL_DIR/ -> $PROD_DIR/"
rsync "${RSYNC_OPTS[@]}" "${RSYNC_EXCLUDE_ARGS[@]}" "$INTERNAL_DIR/" "$PROD_DIR/"

# Commit & push if changes (only if not DRY_RUN)
cd "$PROD_DIR"
if [[ "$DRY_RUN" == "true" ]]; then
  info "DRY_RUN mode: skipping commit/push"
  git status --porcelain
  exit 0
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "New update"
  info "Pushing to origin/$PROD_BRANCH"
  git push origin "$PROD_BRANCH"
  info "Push complete"
else
  info "No changes to commit."
fi

info "Sync finished successfully."
