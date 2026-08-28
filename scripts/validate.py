#!/usr/bin/env python3
"""Validate every skill in skill-stack. Exit 1 on any failure.

Portability exemptions are declared IN the skill's own frontmatter, never hardcoded here,
so the exemption travels with the file and is visible to anyone reading it:

    metadata:
      portability_exempt:
        drive-ref: "Google Drive is this skill's delivery target."

Valid keys: drive-ref, raw-github, project-name, abs-path.
Every exemption needs a non-empty reason or it is rejected.
"""
import re,sys,pathlib
ROOT=pathlib.Path(__file__).resolve().parent.parent
BLOCK=[l.strip() for l in (ROOT/"scripts/blocklist.txt").read_text().splitlines() if l.strip()]
NAME_RE=re.compile(r'^[a-z0-9]+(-[a-z0-9]+)*$')
VALID_EX={"drive-ref","raw-github","project-name","abs-path"}
errs=[];warns=[];seen={};tiers={}

def split_fm(t):
    if not t.startswith("---"): return None,None
    try: i=t.index("\n---",3)
    except ValueError: return None,None
    return t[3:i], t[i+4:]

for f in sorted(ROOT.glob("plugins/*/skills/*/SKILL.md")):
    name=f.parent.name; plugin=f.parts[-4]
    E=lambda m: errs.append(f"{name}: {m}")
    for sib in f.parent.iterdir():
        if sib.is_file() and sib.name.lower()=="skill.md" and sib.name!="SKILL.md":
            E(f"wrong capitalisation: {sib.name}")
    t=f.read_text(encoding="utf-8")
    fm,body=split_fm(t)
    if fm is None: E("missing or unterminated frontmatter"); continue

    m=re.search(r'^name:\s*(.+)$',fm,re.M)
    if not m: E("missing name:")
    else:
        v=m.group(1).strip()
        if v!=name: E(f"name '{v}' != folder '{name}'")
        if len(v)>64: E(f"name {len(v)} chars > 64")
        if not NAME_RE.match(v): E(f"name '{v}' bad charset")
    if name in seen: E(f"duplicate name, also in {seen[name]}")
    else: seen[name]=plugin

    d=re.search(r'^description:\s*(>[-+]?)?\s*\n?((?:.|\n)*?)(?=^\w+:|\Z)',fm,re.M)
    if not d: E("missing description:")
    else:
        dl=len(" ".join(d.group(2).split()))
        if dl==0: E("empty description")
        elif dl>1024: E(f"description {dl} chars > 1024 (blocks account-store upload)")
        elif dl<60: warns.append(f"{name}: description only {dl} chars - may not trigger reliably")

    # tier: frontmatter ONLY. Never grep the body - skills may discuss tiers in prose.
    tm=re.search(r'^\s+tier:\s*(\w+)',fm,re.M)
    tier=tm.group(1) if tm else None
    if tier not in ("universal","machine"): E(f"metadata.tier missing or invalid: {tier!r}")
    else: tiers[name]=tier

    # exemptions, declared in frontmatter with a mandatory reason
    ex=set()
    exb=re.search(r'^\s+portability_exempt:\s*\n((?:\s+\S+:.*\n?)+)',fm,re.M)
    if exb:
        for line in exb.group(1).splitlines():
            km=re.match(r'\s+([\w-]+):\s*(.*)',line)
            if not km: continue
            k,reason=km.group(1),km.group(2).strip().strip('"\'')
            if k not in VALID_EX: E(f"unknown portability_exempt key '{k}'")
            elif not reason: E(f"portability_exempt '{k}' has no reason")
            else: ex.add(k)

    # ---- portability gate: body only, frontmatter already checked ----
    low=body.lower()
    if "project-name" not in ex:
        for b in BLOCK:
            if b in low: E(f"PORTABILITY: project name '{b}'")
    if "abs-path" not in ex and re.search(r'[A-Za-z]:\\|/home/|/Users/',body):
        E("PORTABILITY: absolute local path")
    if "raw-github" not in ex and "raw.githubusercontent" in low:
        E("PORTABILITY: raw GitHub URL - reference skills by name, not link")
    if "drive-ref" not in ex and re.search(r'google drive|drive\.google|gdrive',low):
        E("PORTABILITY: Google Drive reference (declare an exemption if intentional)")

n=len(seen)
print(f"validated {n} skills")
print(f"  universal: {sum(1 for v in tiers.values() if v=='universal')} | machine: {sum(1 for v in tiers.values() if v=='machine')}")
for w in warns: print("WARN ",w)
for e in errs: print("ERROR",e)
print(("FAIL: %d error(s)"%len(errs)) if errs else "PASS")
sys.exit(1 if errs else 0)
