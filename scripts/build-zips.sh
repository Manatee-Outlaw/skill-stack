#!/usr/bin/env bash
# Build upload-ready zips for the UNIVERSAL tier -> claude.ai > Customize > Skills.
# SKILL.md must sit at the ZIP ROOT. Nesting it in a folder makes the upload fail.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
rm -rf "$ROOT/dist"; mkdir -p "$ROOT/dist"; n=0
for f in "$ROOT"/plugins/*/skills/*/SKILL.md; do
  grep -q 'tier: universal' "$f" || continue
  d="$(dirname "$f")"; name="$(basename "$d")"
  ( cd "$d" && zip -qr "$ROOT/dist/$name.zip" . ) && n=$((n+1))
done
echo "built $n universal-tier zips in dist/"
