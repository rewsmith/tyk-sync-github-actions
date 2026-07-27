#!/usr/bin/env bash
#
# Exports APIs (Tyk OAS + classic), policies and assets (templates) from a Tyk
# Dashboard into ./apis, ./policies and ./assets so they can be committed and
# picked up by the tyk-sync GitHub Actions workflow (.github/workflows/tyk-sync.yml).
#
# Configuration is read from a .env file (see .env.example) or from the
# environment. TYK_DASHBOARD_URL and TYK_DASHBOARD_SECRET must not be
# committed to git.
set -euo pipefail

cd "$(dirname "$0")"

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

: "${TYK_DASHBOARD_URL:?Set TYK_DASHBOARD_URL in .env or the environment}"
: "${TYK_DASHBOARD_SECRET:?Set TYK_DASHBOARD_SECRET in .env or the environment}"
TYK_SYNC_VERSION="${TYK_SYNC_VERSION:-2.2.0}"

DUMP_DIR="$(mktemp -d)"
trap 'rm -rf "$DUMP_DIR"' EXIT

echo "Dumping APIs, policies and assets from ${TYK_DASHBOARD_URL} (tyk-sync ${TYK_SYNC_VERSION})"

docker run --rm -v "${DUMP_DIR}:/app/data" "tykio/tyk-sync:${TYK_SYNC_VERSION}" \
  dump --dashboard "${TYK_DASHBOARD_URL}" --secret "${TYK_DASHBOARD_SECRET}" --target /app/data

rm -rf apis policies assets
mkdir -p apis policies assets

shopt -s nullglob
for f in "${DUMP_DIR}"/api-*.json "${DUMP_DIR}"/oas-*.json "${DUMP_DIR}"/mcp-*.json; do
  mv "$f" apis/
done
for f in "${DUMP_DIR}"/policy-*.json; do
  mv "$f" policies/
done
for f in "${DUMP_DIR}"/asset-*.json; do
  mv "$f" assets/
done

echo "Done."
echo "Review the changes in ./apis ./policies ./assets, then commit and push to trigger the sync workflow."
