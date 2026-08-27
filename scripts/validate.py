#!/usr/bin/env python3
"""Validate every skill in skill-stack. Exit 1 on any failure."""
import re,sys,pathlib
ROOT=pathlib.Path(__file__).resolve().parent.parent
BLOCK=[l.strip() for l in (ROOT/"scripts/blocklist.txt").read_text().splitlines() if l.strip()]
DRIVE_EXEMPT={"hermes-upload","verify-before-versioning"}  # explicit allowlist, never a blanket rule
NAME_RE=re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')
errs=[];warns=[];seen={}
skills=sorted(ROOT.glob("plugins/*/skills/*/SKILL.md"))
for f in skills:
    name=f.parent.name; plugin=f.parts[-4]; rel=f.relative_to(ROOT)
    E=lambda m: errs.append(f"{name}: {m}")
    for sib in f.parent.iterdir():
        if sib.is_file() and sib.name.lower()=="skill.md" and sib.name!="SKILL.md":
            E(f"wrong capitalisation: {sib.name}")
    t=f.read_text(encoding="utf-8")
    if not t.startswith("---"): E("no YAML frontmatter"); continue
    try: fm=t[3:t.index("\n---",3)]
    except ValueError: E("unterminated frontmatter"); continue
    m=re.search(r'^name:\s*(.+)$',fm,re.M)
    if not m: E("missing name:")
    else:
        v=m.group(1).strip()
        if v!=name: E(f"name '{v}' != folder '{name}'")
        if len(v)>64: E(f"name {len(v)} chars > 64")
        if not NAME_RE.match(v): E(f"name '{v}' bad charset")
    d=re.search(r'^description:\s*(>[-+]?)?\s*\n?((?:.|\n)*?)(?=^\w+:|\Z)',fm,re.M)
    if not d: E("missing description:")
    else:
        dl=len(" ".join(d.group(2).split()))
        if dl==0: E("empty description")
        elif dl>1024: E(f"description {dl} chars > 1024")
        elif dl<60: warns.append(f"{name}: description only {dl} chars — may not trigger reliably")
    if name in seen: E(f"duplicate name, also in {seen[name]}")
    else: seen[name]=plugin
    # ---- portability gate ----
    low=t.lower()
    for b in BLOCK:
        if b in low: E(f"PORTABILITY: project name '{b}'")
    if re.search(r'[A-Za-z]:\\\\|[A-Za-z]:\\|/home/|/Users/',t): E("PORTABILITY: absolute local path")
    if "raw.githubusercontent" in low: E("PORTABILITY: raw GitHub URL — reference skills by name, not link")
    if name not in DRIVE_EXEMPT and re.search(r'google drive|drive\.google|gdrive',low): E("PORTABILITY: Google Drive reference (not exempt)")
print(f"validated {len(skills)} skills")
u=sum(1 for f in skills if 'tier: universal' in f.read_text(encoding='utf-8'))
print(f"  universal: {u} | machine: {len(skills)-u}")
for w in warns: print("WARN ",w)
for e in errs: print("ERROR",e)
print(("FAIL: %d error(s)"%len(errs)) if errs else "PASS")
sys.exit(1 if errs else 0)
