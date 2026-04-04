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
BACKUP_ROOT="${BACKUP_ROOT:-hostinger_backups/battlestroke}"
KEEP_BACKUPS="${KEEP_BACKUPS:-5}"

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
backup_root="$4"
keep_backups="$5"
shift 5

live_root_raw="$live_root"
staging_root_raw="$staging_root"

resolve_path() {
  local raw="$1"
  local candidate=""

  if [[ "$raw" == /* ]]; then
    printf '%s\n' "$raw"
    return 0
  fi

  for candidate in "$raw" "$PWD/$raw" "$HOME/$raw"; do
    if [[ -e "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  candidate="$(find "$HOME" -maxdepth 6 \( -type d -o -type f \) -path "*/$raw" 2>/dev/null | head -n 1 || true)"
  if [[ -n "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  printf '%s\n' "$HOME/$raw"
}

staging_root="$(resolve_path "$staging_root")"
backup_root="$(resolve_path "$backup_root")"

if [[ "$live_root_raw" != /* && "$staging_root_raw" == "$live_root_raw/"* ]]; then
  staging_suffix="${staging_root_raw#"$live_root_raw"/}"
  live_root="${staging_root%"/$staging_suffix"}"
else
  live_root="$(resolve_path "$live_root")"
fi

if [[ ! -d "$staging_root" ]]; then
  echo "Staging folder not found: $staging_root" >&2
  exit 1
fi

echo "Live root: $live_root"
echo "Staging root: $staging_root"
echo "Backup root: $backup_root"
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

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$backup_root/$timestamp"
mkdir -p "$backup_dir"

echo "Creating backup in $backup_dir"
for item in "$@"; do
  src="$live_root/$item"
  dst="$backup_dir/$item"

  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    cp -a "$src"/. "$dst"/
    echo "Backed up directory: $item"
  elif [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    echo "Backed up file: $item"
  else
    echo "No live copy to back up for: $item"
  fi
done

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

if [[ -d "$backup_root" ]]; then
  mapfile -t backup_dirs < <(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | sort)
  if (( ${#backup_dirs[@]} > keep_backups )); then
    remove_count=$(( ${#backup_dirs[@]} - keep_backups ))
    for (( i=0; i<remove_count; i++ )); do
      rm -rf "${backup_dirs[$i]}"
      echo "Removed old backup: ${backup_dirs[$i]}"
    done
  fi
fi

echo
echo "Promotion complete."
EOF

echo "BattleStroke Hostinger promote script"
echo "Target server: ${SSH_TARGET}:${HOSTINGER_PORT}"
echo "Live root: ${LIVE_ROOT}"
echo "Staging root: ${STAGING_ROOT}"
echo "Backup root: ${BACKUP_ROOT}"
echo

if [[ "${APPLY}" -eq 0 ]]; then
  echo "Running in dry-run mode. Use --apply to create a backup and copy files into the live root."
else
  echo "Running in apply mode. Whitelisted files will be backed up and copied into the live root."
fi

ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" \
  "bash -s -- '${APPLY}' '${LIVE_ROOT}' '${STAGING_ROOT}' '${BACKUP_ROOT}' '${KEEP_BACKUPS}'" \
  "${WHITELIST[@]}" <<< "${REMOTE_SCRIPT}"
