#!/usr/bin/env python3
"""Zip <src>/.claude-plugin and <src>/skills into <out>, paths relative to <src>.

Exists because build-plugins.sh required the `zip` binary, which is not present on
every authoring machine (Windows + Git Bash has zipinfo but not zip). The script
exited before building anything, so the Cowork bundles it was written to refresh
were never actually built here. Reproduces `zip -qr <out> .claude-plugin skills`
run from inside <src>, using only the standard library.
"""
import sys, zipfile, pathlib

out, src = sys.argv[1], pathlib.Path(sys.argv[2])
n = 0
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for top in (".claude-plugin", "skills"):
        for p in sorted((src / top).rglob("*")):
            if p.is_file():
                z.write(p, p.relative_to(src).as_posix())
                n += 1
print(n)
