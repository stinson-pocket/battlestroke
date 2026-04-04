# Hostinger Promote Scripts

`promote_hostinger_test_git.sh` promotes the approved BattleStroke site files from the Hostinger Git staging folder into the live web root.

Assumed layout:

- Live site: `public_html`
- Hostinger Git staging site: `public_html/test-git`

Default Hostinger connection values baked into the script:

- Host: `109.106.250.190`
- Port: `65002`
- User: `u514430741`

Usage:

```bash
scripts/promote_hostinger_test_git.sh
```

Dry run only. It verifies the expected staging paths and prints the whitelist without copying.

```bash
scripts/promote_hostinger_test_git.sh --apply
```

Copies only the whitelist into the live root.

Override values if needed:

```bash
HOSTINGER_HOST=example.com HOSTINGER_PORT=22 HOSTINGER_USER=user LIVE_ROOT=public_html STAGING_SUBDIR=test-git scripts/promote_hostinger_test_git.sh --apply
```

Guardrails:

- Whitelist-based promotion only
- No delete or wipe behavior
- Does not touch draft-only files such as `battle-stroke-homepage-source.html`, `home-preview.html`, or `pdf-render.html`
- Leaves likely live-only items alone by default, including `.htaccess` and any unlisted folders
