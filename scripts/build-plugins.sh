#!/usr/bin/env bash
# Build the .plugin bundles that Cowork installs.
#
# WHY THIS EXISTS
# ---------------
# Cowork does not read the CLI marketplace and does not read GitHub. It installs
# .plugin files: plain zips of a plugins/<name>/ directory. They are point-in-time
# snapshots with NO refresh mechanism — nothing pulls, nothing syncs.
#
# On 2026-08-28 that gap cost a full session. The bundles Cowork was serving had
# been zipped at 12:35. Between then and 17:00 the repo had a skill deleted for
# leaking private material and two skills materially rewritten. A fresh Cowork
# session loaded none of it, and served the deleted template back as if current.
# `sync.bat` reported "all good" throughout — correctly, because it refreshes the
# CLI marketplace, which Cowork never consults.
#
# The other two scripts are NOT substitutes and never were:
#   sync.bat        pull + validate + CLI marketplace update   (Claude Code CLI)
#   build-zips.sh   per-skill zips, universal tier only        (claude.ai account store)
#   build-plugins.sh  whole-plugin bundles                     (Cowork)  <- this file
#
# USAGE
#   bash scripts/build-plugins.sh [OUT_DIR] [PRIVATE_ROOT]
#
#   OUT_DIR       where the .plugin files land       (default: <repo>/dist)
#   PRIVATE_ROOT  the private repo, built too if present and readable
#
# After building, install each bundle in Cowork, then START A NEW SESSION. A
# running session holds its plugin cache frozen, so an install mid-session
# changes nothing you can see — which looks identical to a failed install.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist}"
PRIVATE_ROOT="${2:-}"

command -v zip >/dev/null || { echo "ERROR: zip not found on PATH."; exit 1; }

mkdir -p "$OUT"
n=0

build_one() {
    local plugin_dir="$1" name
    name="$(basename "$plugin_dir")"

    # A plugin is only valid with its manifest. Without it the bundle installs
    # and contributes nothing — a silent no-op, the worst failure shape.
    if [ ! -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
        echo "  SKIP $name — no .claude-plugin/plugin.json"
        return
    fi
    if [ ! -d "$plugin_dir/skills" ]; then
        echo "  SKIP $name — no skills/ directory"
        return
    fi

    rm -f "$OUT/$name.plugin"
    ( cd "$plugin_dir" && zip -qr "$OUT/$name.plugin" .claude-plugin skills )

    local count size
    count="$(find "$plugin_dir/skills" -name SKILL.md | wc -l | tr -d ' ')"
    size="$(du -k "$OUT/$name.plugin" | cut -f1)"
    printf "  built %-22s %2s skills  %5s KB\n" "$name.plugin" "$count" "$size"
    n=$((n+1))
}

echo "Building Cowork plugin bundles -> $OUT"
echo ""
echo "public ($ROOT):"
for d in "$ROOT"/plugins/*/; do
    [ -d "$d" ] && build_one "${d%/}"
done

if [ -n "$PRIVATE_ROOT" ] && [ -d "$PRIVATE_ROOT/plugins" ]; then
    echo ""
    echo "private ($PRIVATE_ROOT):"
    for d in "$PRIVATE_ROOT"/plugins/*/; do
        [ -d "$d" ] && build_one "${d%/}"
    done
elif [ -n "$PRIVATE_ROOT" ]; then
    echo ""
    echo "  NOTE: private root '$PRIVATE_ROOT' has no plugins/ directory — skipped."
fi

echo ""
echo "built $n bundle(s)."
echo "Install each in Cowork, then start a NEW session — the cache is frozen per session."
