# battlestroke

Simple stroke education anyone can remember.

## Deployment

This site uses a staged Hostinger Git deployment flow:

- `main` deploys to Hostinger staging at `public_html/test-git`
- `production` is the live-publish branch
- GitHub Actions promotes the staged copy into `public_html`
- A server-side backup is created before each live promotion

See [DEPLOYMENT.md](C:\Users\signu\Documents\Personal\Employment-Jobs-Retirement\Stinson Digital Consulting LLC\Codex\BattleStroke\DEPLOYMENT.md) for the full workflow and setup details.
