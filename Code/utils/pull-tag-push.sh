#!/usr/bin/env bash
set -euo pipefail

# pull-tag-push.sh — copy an OCI image between registries.
# Usage:
#   ./pull-tag-push.sh \
#     --from ghcr.io/cdxi-solutions/muddy-service:bin \
#     --to   ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest \
#     [--pin-digest] [--retries 3] [--dry-run]
#
# Notes:
# - Requires `docker` (or `skopeo` if SKOPEO_COPY=1).
# - Make sure you're logged in to both registries if they’re private.

FROM_REF=""
TO_REF=""
RETRIES=2
PIN_DIGEST=0
DRY_RUN=0
SKOPEO_COPY=0

log()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

usage() {
  grep -E '^#' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_REF="$2"; shift 2;;
    --to)   TO_REF="$2";   shift 2;;
    --retries) RETRIES="${2:-2}"; shift 2;;
    --pin-digest) PIN_DIGEST=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) usage 0;;
    *) err "Unknown arg: $1"; usage 1;;
  esac
done

[[ -n "$FROM_REF" && -n "$TO_REF" ]] || { err "Both --from and --to are required."; usage 1; }

# Optional: use skopeo for direct registry-to-registry copy (faster, no local storage).
if [[ "${SKOPEO_COPY:-0}" == "1" ]]; then
  cmd=(skopeo copy --multi-arch=all "docker://${FROM_REF}" "docker://${TO_REF}")
  [[ $DRY_RUN -eq 1 ]] && { log "(dry-run) ${cmd[*]}"; exit 0; }
  log "Copying with skopeo: ${FROM_REF} -> ${TO_REF}"
  "${cmd[@]}"
  exit 0
fi

# Docker path (pull -> tag -> push) with retries.
attempt() {
  local n=0
  until [[ $n -gt $RETRIES ]]; do
    ((n++))
    log "[$n/$((RETRIES+1))] Pulling ${FROM_REF}…"
    docker pull "${FROM_REF}" && return 0
    warn "Pull failed; retrying…"
    sleep $((n*2))
  done
  return 1
}

# Dry-run early exit
if [[ $DRY_RUN -eq 1 ]]; then
  log "(dry-run) Would: docker pull ${FROM_REF}"
  log "(dry-run) Would: docker tag  ${FROM_REF} ${TO_REF}"
  log "(dry-run) Would: docker push  ${TO_REF}"
  exit 0
fi

attempt || { err "Pull failed after $((RETRIES+1)) attempts."; exit 2; }

# Optionally pin destination to the source’s content digest (immutable ref).
if [[ $PIN_DIGEST -eq 1 ]]; then
  # Resolve the pulled local image digest
  DIGEST="$(docker inspect --format='{{index .RepoDigests 0}}' "${FROM_REF}" | awk -F@ '{print $2}')"
  if [[ -z "$DIGEST" ]]; then
    err "Could not resolve digest for ${FROM_REF}."
    exit 3
  fi
  # Rewrite TO_REF to use @sha256:… form while preserving repo.
  TO_REPO="${TO_REF%@*}"; TO_REPO="${TO_REPO%:*}" # strip tag and any digest
  TO_REF="${TO_REPO}@${DIGEST}"
  log "Pinned destination to digest: ${TO_REF}"
fi

log "Tagging ${FROM_REF} -> ${TO_REF}"
docker tag "${FROM_REF}" "${TO_REF}"

# Push with retries too
n=0
until [[ $n -gt $RETRIES ]]; do
  ((n++))
  log "[$n/$((RETRIES+1))] Pushing ${TO_REF}…"
  if docker push "${TO_REF}"; then
    log "Success."
    exit 0
  fi
  warn "Push failed; retrying…"
  sleep $((n*2))
done

err "Push failed after $((RETRIES+1)) attempts."
exit 4

#echo "Pulling bin image from CDXi registry..." &&
#docker pull ghcr.io/cdxi-solutions/muddy-service:bin

#echo "Tagging bin image for production..." &&
#docker tag ghcr.io/cdxi-solutions/muddy-service:bin ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest

#echo "Pushing bin image to production registry..." &&
#docker push ghcr.io/hellenicspacecenter/water-monitoring-integration-tests/muddy-service:latest

