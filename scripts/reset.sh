#!/usr/bin/env bash
#
# Empties ./apis, ./policies and ./assets and commits + pushes the result to
# master. This lets the tyk-sync GitHub Actions workflow (which deletes any
# Dashboard resource not present in the repo) wipe the target Dashboard clean,
# so the next dump.sh + sync run starts from a known-empty state.
set -euo pipefail

cd "$(dirname "$0")/.."

for dir in apis policies assets; do
  rm -rf "${dir}"
  mkdir -p "${dir}"
  touch "${dir}/.gitkeep"
done

if git diff --quiet -- apis policies assets && git diff --cached --quiet -- apis policies assets; then
  echo "Nothing to reset — apis, policies and assets are already empty."
  exit 0
fi

git add apis policies assets
git commit -m "Reset apis, policies and assets for a clean demo run"
git push

echo "Done. Pushed an empty apis/policies/assets to master — the sync workflow will clear the Dashboard."
