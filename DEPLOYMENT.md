# BattleStroke Deployment Flow

## Branches

- `main`: staging content for Hostinger Git deployment into `public_html/test-git`
- `production`: approved content branch that triggers live promotion

## Hosting model

- Live site root: `public_html`
- Hostinger Git staging path: `public_html/test-git`
- Backup location: `hostinger_backups/battlestroke`

## Publish flow

1. Push changes to `main`
2. Let Hostinger deploy `main` to `test-git` or click `Deploy`
3. Review the staged site in `test-git`
4. Merge `main` into `production`
5. GitHub Actions connects to Hostinger over SSH
6. The workflow creates a timestamped backup of the current live whitelisted files
7. The workflow promotes the staged copy from `public_html/test-git` into `public_html`

## GitHub setup required

Add this repository secret:

- `HOSTINGER_SSH_KEY`: private SSH key for the Hostinger account

Optional repository variables if you ever need to override the defaults:

- `HOSTINGER_HOST`
- `HOSTINGER_PORT`
- `HOSTINGER_USER`
- `LIVE_ROOT`
- `STAGING_SUBDIR`
- `BACKUP_ROOT`
- `KEEP_BACKUPS`

## Notes

- The promotion is whitelist-based and does not wipe unlisted live files
- Draft pages are not promoted live
- The workflow keeps the 5 most recent backups by default
