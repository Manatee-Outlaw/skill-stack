#!/usr/bin/env python3
"""Daily staleness check: does every place Claude reads skills from still match the repo?

Each delivery path refreshes separately and a stale one reports no error (EXTERNALS.md), so this
script asks each one directly. Run by sync.bat after the plugin update; also runnable by hand:

    python scripts/check-drift.py

Checks, on this machine:
  1. repo        - skill edits not committed, or commits not pushed (other machines can't see them)
  2. plugins     - installed CLI plugin version != repo version (sync didn't install it)
  3. desktop     - any of our plugins uploaded to the desktop app (frozen; shadows the plugins)
  4. claude.ai   - a universal skill whose claude.ai copy differs from the repo (upload its zip),
                   claude.ai edited AFTER the repo (bring it back first - the manatee lesson), or a
                   private skill sitting on claude.ai (unless listed in the private folder's
                   claude-ai-exceptions.txt - then it is drift-checked like a universal one)
  5. backup      - private skills not backed up in the last 2 days

Writes scripts/drift-report.txt. Exit 0 = all current, 1 = something to do.
Paths come from %APPDATA% / the home folder; a path that doesn't exist (no desktop app, no private
folder) is reported as skipped, never as clean.
"""
import json, os, re, subprocess, sys, time, datetime as dt
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PRIVATE = ROOT.parent / "skill-stack-private"
HOME = Path.home()
APPDATA = Path(os.environ.get("APPDATA", HOME / "AppData/Roaming"))
SESSIONS = APPDATA / "Claude/local-agent-mode-sessions"
problems, notes = [], []

def fm_and_body(text):
    text = text.replace("\r", "")
    m = re.match(r"^---\n(.*?)\n---\n?(.*)$", text, re.S)
    return (m.group(1), m.group(2)) if m else ("", text)

def norm(body):  # the account store re-wraps frontmatter; compare bodies, whitespace-insensitive
    return re.sub(r"\s+", " ", body).strip()

def skills(root):
    out = {}
    for f in sorted(root.glob("plugins/*/skills/*/SKILL.md")):
        fm, body = fm_and_body(f.read_text(encoding="utf-8"))
        tier = re.search(r"^\s+tier:\s*(\w+)", fm, re.M)
        out[f.parent.name] = {"file": f, "plugin": f.parts[-4], "body": body,
                              "tier": tier.group(1) if tier else None}
    return out

def git(*a):
    return subprocess.run(["git", "-C", str(ROOT), *a], capture_output=True, text=True).stdout.strip()

public = skills(ROOT)
private = skills(PRIVATE) if PRIVATE.is_dir() else {}

# 1. repo -----------------------------------------------------------------------------------
dirty = git("status", "--porcelain", "--", "plugins")
if dirty:
    problems.append(f"repo: {len(dirty.splitlines())} skill file(s) changed but not committed - "
                    "ask Claude to commit and push them")
git("fetch", "-q", "origin")
ahead = git("rev-list", "--count", "origin/main..HEAD")
if ahead and ahead != "0":
    problems.append(f"repo: {ahead} commit(s) not pushed to GitHub - other machines can't see them")

# 2. plugins --------------------------------------------------------------------------------
inst_file = HOME / ".claude/plugins/installed_plugins.json"
if inst_file.exists():
    inst = json.loads(inst_file.read_text(encoding="utf-8")).get("plugins", {})
    for root, mkt in ((ROOT, "skill-stack"), (PRIVATE, "skill-stack-private")):
        for pj in sorted(root.glob("plugins/*/.claude-plugin/plugin.json")):
            meta = json.loads(pj.read_text(encoding="utf-8"))
            key = f"{meta['name']}@{mkt}"
            have = inst.get(key, [{}])[0].get("version")
            if have is None:
                notes.append(f"plugins: {key} is not installed on this machine")
            elif have != meta["version"]:
                problems.append(f"plugins: {meta['name']} installed {have}, repo has {meta['version']} "
                                "- run sync.bat (if it fails, read scripts/sync.log)")
else:
    notes.append("plugins: SKIPPED - no Claude Code plugin registry on this machine")

# 3. desktop uploads ------------------------------------------------------------------------
ours = {p.parent.parent.name for p in ROOT.glob("plugins/*/.claude-plugin/plugin.json")} | {"skill-private"}
if SESSIONS.is_dir():
    for pj in SESSIONS.glob("*/*/rpm/plugin_*/.claude-plugin/plugin.json"):
        name = json.loads(pj.read_text(encoding="utf-8")).get("name")
        if name in ours:
            problems.append(f"desktop: '{name}' is uploaded to the desktop app - it is frozen and hides "
                            "the auto-updated copy. Remove it in the desktop app's Plugins screen")
else:
    notes.append("desktop: SKIPPED - Claude desktop app data not found")

# 4. claude.ai account store ---------------------------------------------------------------
mirrors = sorted(SESSIONS.glob("skills-plugin/*/*/skills")) if SESSIONS.is_dir() else []
if mirrors:
    acct_dir = mirrors[0]
    manifest = {}
    mf = acct_dir.parent / "manifest.json"
    if mf.exists():
        manifest = {s["name"]: s for s in json.loads(mf.read_text(encoding="utf-8")).get("skills", [])}
    acct = {d.name: fm_and_body((d / "SKILL.md").read_text(encoding="utf-8"))[1]
            for d in acct_dir.iterdir() if (d / "SKILL.md").exists()}
    def compare(name, s, is_git=True):  # claude.ai copy vs the local one
        if norm(acct[name]) == norm(s["body"]):
            return
        up = manifest.get(name, {}).get("updatedAt", "")
        local = (git("log", "-1", "--format=%cI", "--", str(s["file"].relative_to(ROOT))) if is_git
                 else dt.datetime.fromtimestamp(s["file"].stat().st_mtime, dt.timezone.utc).isoformat())
        newer_online = False
        try:
            newer_online = dt.datetime.fromisoformat(up.replace("Z", "+00:00")) >                            dt.datetime.fromisoformat(local)
        except ValueError:
            pass
        if newer_online:
            problems.append(f"claude.ai: '{name}' was EDITED ON CLAUDE.AI after the local copy's last change - "
                            "ask Claude to bring that version back BEFORE uploading anything over it")
        else:
            problems.append(f"claude.ai: '{name}' is out of date there - upload a fresh zip of it "
                            "(ask Claude to build the zips first)")
    for name, s in public.items():
        if s["tier"] != "universal":
            continue
        if name not in acct:
            problems.append(f"claude.ai: '{name}' is universal but not on claude.ai - upload dist/{name}.zip")
        else:
            compare(name, s)
    # Owner-approved private skills allowed on claude.ai: one name per line, reasons in the README
    exc_file = PRIVATE / "claude-ai-exceptions.txt"
    allowed = ({l.split("#")[0].strip() for l in exc_file.read_text(encoding="utf-8").splitlines()} - {""}
               if exc_file.exists() else set())
    for name, s in private.items():
        if name not in acct:
            continue
        if name in allowed:
            compare(name, s, is_git=False)  # allowed there, but must still match
        else:
            problems.append(f"claude.ai: private skill '{name}' is on claude.ai - the private folder's "
                            "README forbids this; remove it there or add it to claude-ai-exceptions.txt")
else:
    notes.append("claude.ai: SKIPPED - no local copy of the account's skills found (desktop app not installed?)")

# 5. private backup -------------------------------------------------------------------------
if PRIVATE.is_dir():
    status = PRIVATE / "backup-status.txt"
    if not status.exists():
        problems.append("backup: private skills have never been backed up")
    else:
        age_days = (time.time() - status.stat().st_mtime) / 86400
        if age_days > 2:
            problems.append(f"backup: last private-skills backup was {age_days:.0f} days ago - "
                            "is the N: drive connected? (EZ Connect)")

# report ------------------------------------------------------------------------------------
stamp = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
lines = [f"Skill stack check - {stamp}", ""]
lines += [f"PROBLEM  {p}" for p in problems] or ["ALL CURRENT - every place Claude reads skills from matches the repo."]
lines += [f"note     {n}" for n in notes]
report = "\n".join(lines)
print(report)
(ROOT / "scripts/drift-report.txt").write_text(report + "\n", encoding="utf-8")
sys.exit(1 if problems else 0)
