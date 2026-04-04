#!/usr/bin/env bash

set -euo pipefail

APPLY=0
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=1
fi

HOSTINGER_HOST="${HOSTINGER_HOST:-109.106.250.190}"
HOSTINGER_PORT="${HOSTINGER_PORT:-65002}"
HOSTINGER_USER="${HOSTINGER_USER:-u514430741}"
LIVE_ROOT="${LIVE_ROOT:-public_html}"
STAGING_SUBDIR="${STAGING_SUBDIR:-test-git}"
STAGING_ROOT="${LIVE_ROOT}/${STAGING_SUBDIR}"

WHITELIST=(
  "index.html"
  "about.html"
  "faq.html"
  "proclamation.html"
  "stroke-symptoms.html"
  "what-to-do-during-a-stroke.html"
  "be-fast-vs-fast.html"
  "home.css"
  "pages.css"
  "robots.txt"
  "sitemap.xml"
  "assets"
)

SSH_TARGET="${HOSTINGER_USER}@${HOSTINGER_HOST}"
SSH_OPTS=(-p "${HOSTINGER_PORT}")

read -r -d '' REMOTE_SCRIPT <<'EOF' || true
set -euo pipefail

apply_flag="$1"
live_root="$2"
staging_root="$3"
shift 3

if [[ ! -d "$staging_root" ]]; then
  echo "Staging folder not found: $staging_root" >&2
  exit 1
fi

echo "Live root: $live_root"
echo "Staging root: $staging_root"
echo
echo "Whitelisted publish set:"
for item in "$@"; do
  echo "  - $item"
done
echo

missing=0
for item in "$@"; do
  if [[ ! -e "$staging_root/$item" ]]; then
    echo "Missing from staging: $staging_root/$item" >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Aborting because one or more whitelisted items were missing." >&2
  exit 1
fi

if [[ "$apply_flag" != "1" ]]; then
  echo "Dry run only. No files copied."
  exit 0
fi

for item in "$@"; do
  src="$staging_root/$item"
  dst="$live_root/$item"

  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -a "$src"/. "$dst"/
    echo "Promoted directory: $item"
  else
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    echo "Promoted file: $item"
  fi
done

echo
echo "Promotion complete."
EOF

echo "BattleStroke Hostinger promote script"
echo "Target server: ${SSH_TARGET}:${HOSTINGER_PORT}"
echo "Live root: ${LIVE_ROOT}"
echo "Staging root: ${STAGING_ROOT}"
echo

if [[ "${APPLY}" -eq 0 ]]; then
  echo "Running in dry-run mode. Use --apply to copy files into the live root."
else
  echo "Running in apply mode. Whitelisted files will be copied into the live root."
fi

ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" \
  "bash -s -- '${APPLY}' '${LIVE_ROOT}' '${STAGING_ROOT}'" -- \
  "${WHITELIST[@]}" <<< "${REMOTE_SCRIPT}"
