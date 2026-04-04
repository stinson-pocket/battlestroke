# Hostinger Promote Scripts

`promote_hostinger_test_git.sh` promotes the approved BattleStroke site files from the Hostinger Git staging folder into the live web root.

Assumed layout:

- Live site: `public_html`
- Hostinger Git staging site: `public_html/test-git`

Default Hostinger connection values baked into the script:

- Host: `109.106.250.190`
- Port: `65002`
- User: `u514430741`
- Backup root: `hostinger_backups/battlestroke`

Usage:

```bash
scripts/promote_hostinger_test_git.sh
```

Dry run only. It verifies the expected staging paths and prints the whitelist without copying.

```bash
scripts/promote_hostinger_test_git.sh --apply
```

Copies only the whitelist into the live root.

When run with `--apply`, the script first creates a timestamped server-side backup of the whitelisted live files, then promotes the staging copy into `public_html`. By default it keeps the 5 most recent backups.

Override values if needed:

```bash
HOSTINGER_HOST=example.com HOSTINGER_PORT=22 HOSTINGER_USER=user LIVE_ROOT=public_html STAGING_SUBDIR=test-git BACKUP_ROOT=hostinger_backups/battlestroke KEEP_BACKUPS=5 scripts/promote_hostinger_test_git.sh --apply
```

Guardrails:

- Whitelist-based promotion only
- No delete or wipe behavior
- Creates a timestamped server-side backup before promotion
- Does not touch draft-only files such as `battle-stroke-homepage-source.html`, `home-preview.html`, or `pdf-render.html`
- Leaves likely live-only items alone by default, including `.htaccess` and any unlisted folders

Git-driven workflow recommendation:

- `main` deploys to Hostinger staging at `public_html/test-git`
- Review the staged site
- Merge `main` into `production`
- GitHub Actions promotes the staged copy into `public_html` and stores a backup first
