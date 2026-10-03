#!/usr/bin/env bash
# Build upload-ready zips for the UNIVERSAL tier -> claude.ai > Customize > Skills.
# SKILL.md must sit at the ZIP ROOT. Nesting it in a folder makes the upload fail.
# Entry paths use forward slashes (claude.ai rejects backslashes - see build-zips.ps1).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Only old skill zips are removed: dist/ also holds the .plugin bundles from
# build-plugins.sh, and wiping the folder silently deleted them.
mkdir -p "$ROOT/dist"; rm -f "$ROOT"/dist/*.zip; n=0
# zip is absent on Windows/Git-Bash authoring machines; fall back to the stdlib.
if command -v zip >/dev/null; then ZIPPER=zip
elif command -v python >/dev/null; then ZIPPER=python
elif command -v python3 >/dev/null; then ZIPPER=python3
else echo "ERROR: need either zip or python on PATH."; exit 1; fi
for f in "$ROOT"/plugins/*/skills/*/SKILL.md; do
  grep -qE '^[[:space:]]+tier:[[:space:]]*universal' "$f" || continue  # indented = frontmatter metadata; the body may discuss tiers
  d="$(dirname "$f")"; name="$(basename "$d")"
  if [ "$ZIPPER" = zip ]; then ( cd "$d" && zip -qr "$ROOT/dist/$name.zip" . )
  else "$ZIPPER" -c 'import sys,zipfile,pathlib
s=pathlib.Path(sys.argv[2])
with zipfile.ZipFile(sys.argv[1],"w",zipfile.ZIP_DEFLATED) as z:
    [z.write(p,p.relative_to(s).as_posix()) for p in sorted(s.rglob("*")) if p.is_file()]' "$ROOT/dist/$name.zip" "$d"
  fi
  n=$((n+1))
done
echo "built $n universal-tier zips in dist/"
