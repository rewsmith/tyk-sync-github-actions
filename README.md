# tyk-sync-github-actions
New and improved tyk sync based github actions demo

## Promoting changes to Tyk (push → sync)

Any commit pushed to `master` triggers `.github/workflows/tyk-sync.yml`, which
runs `tyk-sync sync` against the target Dashboard to apply everything under
`./apis`, `./policies` and `./assets`.

Configure the target Dashboard as repo secrets (Settings → Secrets and
variables → Actions):

- `TYK_DASHBOARD_URL` (secret)
- `TYK_DASHBOARD_SECRET` (secret)
- `TYK_SYNC_VERSION` (variable, e.g. `v2.2.0`)

## Dumping changes from Tyk (export)

`scripts/dump.sh` exports APIs (Tyk OAS + classic), policies and assets (templates)
from a source Dashboard into `./apis`, `./policies` and `./assets` using
`tyk-sync dump` (run via Docker). Commit and push the result to promote it
through the sync workflow above.

1. Copy `.env.example` to `.env` and fill in your Dashboard URL and secret.
   `.env` is git-ignored — never commit real credentials.
2. Run:

   ```bash
   ./scripts/dump.sh
   ```

3. Review the diff in `./apis`, `./policies` and `./assets`, then commit and
   push.

`TYK_SYNC_VERSION` defaults to `v2.2.0` but can be overridden in `.env` or the
environment.

## Resetting for a clean demo run

`scripts/reset.sh` empties `./apis`, `./policies` and `./assets` (leaving
`.gitkeep` placeholders) and commits + **pushes** the result directly to
`master`. Since `tyk-sync sync` deletes any Dashboard resource not present in
the repo, this push causes the sync workflow to wipe the target Dashboard, so
the repo and Dashboard both start from a known-empty state before your next
`dump.sh` run.

```bash
./scripts/reset.sh
```

Run this deliberately — it pushes to `master` and triggers the workflow.
