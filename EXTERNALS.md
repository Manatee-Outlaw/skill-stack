# External skill dependencies

Every third-party skill this library relies on. **Referenced and pinned, never copied** —
vendoring forks a skill and forfeits every upstream fix.

Re-check this file quarterly, or whenever an external skill misbehaves.

---

## Where each skill lives, and where it follows you

A skill is not "installed" in one place. There are **five delivery paths**, they reach
different surfaces, and only one of them follows your login. Before asking *"why can't
Claude see this skill"*, work out which path it took.

| Path | Where it lives | Reaches | Refreshed by |
|---|---|---|---|
| **Account store** | claude.ai → Customize → Skills | **everywhere** — web, mobile, Cowork, Claude Code | Re-upload by hand. `scripts/build-zips.sh` builds the per-skill zips (universal tier only). |
| **Cowork bundle** | an installed `.plugin` file | **Cowork only** | `scripts/build-plugins.sh`, then re-install each bundle. Nothing else. |
| **CLI marketplace** | `claude plugin marketplace add <path or repo>` | **Claude Code only** | `claude plugin marketplace update <name>`, or `scripts\sync.bat`. |
| **Claude Code user skills** | `%USERPROFILE%\.claude\skills\<name>` | **Claude Code only** | Manual — re-clone or `git pull` in that folder. |
| **Project scope** | `<project>\.agents\skills\<name>` | only agents whose working folder is that project | Manual. Narrowest scope available. |

### The rule that decides everything

**If a skill must reach a tablet or a phone, it has to be universal-tier and in the account
store. There is no other path.** Everything else is a file on one computer.

This mirrors the connector rule further down: one authorisation at claude.ai reaches all
three surfaces; a local install reaches one machine.

### Each path refreshes separately, and silence is not success

The paths do **not** feed each other. Committing to the repo updates none of them. Each has
its own build step and its own staleness, and a stale one reports no error — it serves old
content confidently.

> **2026-08-28 — the failure this section exists to prevent.** A skill was deleted from the
> repo for carrying private material, and two others were materially rewritten. All of it
> was committed and pushed. A fresh Cowork session loaded none of it and served the deleted
> skill back as current, because Cowork reads `.plugin` bundles that had been built five
> hours earlier and **nothing in the toolchain rebuilt them**. `sync.bat` reported "all
> good" throughout — correctly, because it refreshes the CLI marketplace, which Cowork
> never consults. `build-plugins.sh` was written that day to close the gap.

Two behaviours worth knowing, both observed directly rather than assumed:

- **Installing a `.plugin` bundle refreshes a live session.** The skills become available
  immediately; no restart needed.
- **A CLI marketplace update does not.** `marketplace update` returned ok and changed
  nothing a running Cowork session could see.

### Verifying, rather than hoping

Ask a session to **read the actual file**, not to list names. A stale skill has the right
name and the wrong content — the failure above was invisible to any check that stopped at
the name:

> *"List the skill-private skills you can see, then read the brand-guidelines SKILL.md you
> have loaded and tell me whether it names the real brands or contains placeholders."*

### Open questions — unverified, do not repeat as fact

- **Does Cowork read `%USERPROFILE%\.claude\skills`?** Evidence says no: `unlazy` sits
  there and has never appeared in a Cowork session. Not proven — that folder is outside
  what a Cowork session can inspect, so the conclusion rests on absence.
- **Why does `ponytail` show installed and enabled in the desktop Plugins panel while being
  absent from a Cowork session's plugin set?** Possibly a per-surface toggle. Unresolved.

---

## Installed as plugins (marketplace)

### impeccable
| | |
|---|---|
| Source | `pbakaus/impeccable` |
| Author / licence | Paul Bakaus · Apache-2.0 · impeccable.style |
| Install | `/plugin marketplace add pbakaus/impeccable` |
| Scope | user-scope |
| Tier | machine |
| Wrapper | none — self-triggering |

Design fluency for frontend work: 23 commands, 58 deterministic anti-pattern rules
(AI-slop tells, WCAG contrast, typography, layout, spacing, motion). Its own description
covers "change the design", "make the UI look better", redesign, critique, polish — **no
trigger phrase needed and no wrapper wanted.**

### ponytail
| | |
|---|---|
| Source | `DietrichGebert/ponytail` |
| Author / licence | DietrichGebert · MIT |
| Install | plugin `ponytail@ponytail` |
| Last verified | v4.7.0, 2026-07-23 — **re-verify, do not trust this number** |
| Tier | machine |
| Wrapper | `ponytail-audit` (ours) |

Over-engineering audit. Ships adapters for other agent hosts too (Codex, Cursor, Windsurf,
Gemini/Antigravity, OpenCode).

`ponytail-audit` is a **correct thin wrapper** and needs no slimming: it records ownership
and source, names the relevant commands, and adds our triage rules. It does not restate
upstream's audit logic. It also instructs re-verifying the plugin is installed rather than
assuming — keep that.

---

## Installed via the skills CLI

These repos are **not** marketplaces. They install into a skills directory instead.

### unlazy
| | |
|---|---|
| Source | `Leonxlnx/unlazy` |
| Licence | MIT |
| Install | `npx skills add Leonxlnx/unlazy` |
| Alt | `git clone https://github.com/Leonxlnx/unlazy ~/.claude/skills/unlazy` |
| Tier | machine |

Anti-laziness skill; the Depth Tree method. `SKILL.md` at repo root, plus `references/`,
`templates/`, and zero-dependency Node scripts.

**Machine-tier by nature:** its enforcement relies on gate files, `gate-check.mjs`, and an
optional Claude Code Stop hook that blocks ending a turn while gates are unmet. None of
that exists on a tablet.

Actively developed — v2 replaced v1's instructions-only model with structural enforcement.
That churn is exactly why it is pinned here rather than copied.

---

## Deliberately NOT in this library — Anthropic built-ins

`algorithmic-art`, `canvas-design`, `theme-factory` were removed from `skill-creative`
because **Anthropic ships them as built-in skills** and its versions are materially better.

The decision was made on evidence, not preference. Anthropic's versions carry substantial
bundled assets; the local rewrites were prose only:

| Skill | Anthropic ships | The local version had |
|---|---|---|
| `algorithmic-art` | `templates/generator_template.js`, `templates/viewer.html` | SKILL.md only |
| `canvas-design` | ~40 real font files (.ttf) plus licences, in `canvas-fonts/` | SKILL.md only |
| `theme-factory` | `themes/` — 10 named theme definitions + `theme-showcase.pdf` | SKILL.md only |

The clincher: Anthropic's `algorithmic-art` instructs **"STEP 0: READ THE TEMPLATE FIRST"**.
The local version had no template, so that instruction pointed at nothing. `canvas-design`
without the fonts cannot use the typography it describes.

**Do not re-add them.** They are available automatically as built-ins, they update with
Claude, and a local copy would both collide on name and be worse. If a genuine house rule
is ever needed on top, write a thin wrapper under a **different** name — the `ponytail-audit`
pattern — never a competing copy.

A name collision here is not cosmetic: the account store holds one skill per name, and
Claude Code will not load a local skill beside a synced one of the same name.

## Managed fork

### adhd
| | |
|---|---|
| Upstream | `UditAkhourii/adhd` · `skills/adhd/SKILL.md` |
| Licence | MIT |
| Local copy | `plugins/skill-core/skills/adhd/SKILL.md` |
| Tier | **universal** |
| Status | **FORK — body tracks upstream, description deliberately diverges** |

**What diverges: the description only. The body is upstream's.**

| | Upstream | Ours |
|---|---|---|
| Scope | "for coding agents" | code **+ marketing, sales copy, positioning, pricing, business strategy** |
| Use cases | architecture, API/SDK surface, fuzzy debugging | + launch angle, pricing model, go-to-market bet |
| Triggers | `/adhd`, "ADHD mode", brainstorm/ideate | + "campaign ideas", "positioning ideas", "how should I pitch/price/name this" |

**Why the fork exists.** adhd is universal-tier — it must reach a tablet for business
decisions. Upstream's description scopes it to coding agents, so it would not fire on
"how should I price this." The divergence is the entire reason the skill is useful here.

**How to re-sync (do this quarterly):**

1. Fetch `https://raw.githubusercontent.com/UditAkhourii/adhd/main/skills/adhd/SKILL.md`
2. Diff **the body only** — everything below the frontmatter.
3. Take upstream's body changes wholesale; the method is theirs and improves upstream.
4. **Never take upstream's description.** Re-apply ours.
5. Re-check ours is still ≤1024 chars — it is universal-tier, so the account-store cap
   applies (`scripts/validate.py` enforces this).

Because the divergence is one field, a re-sync is a one-field decision. Keep it that way:
if the bodies ever diverge, this stops being a managed fork and becomes an unmanaged one.

**Known upstream-only section:** `SOURCE-SPEC.md` reference. Not carried locally. Harmless.

---

---

## MCP connectors

Connectors are not skills, but they are external dependencies this library leans on, and
an unrecorded one is an invisible one.

### The rule that decides everything

**Add connectors at `claude.ai/customize/connectors`. Nowhere else.**

One authorisation there reaches **all three surfaces** — claude.ai, Cowork, and Claude Code
(which fetches account connectors on login). Adding the same server with `claude mcp add`
instead gives you Claude Code on **that one machine**, and nothing else.

⚠️ **Never do both.** A server added in Claude Code takes precedence over a claude.ai
connector pointing at the same URL — the local entry silently shadows the connector, and
`/mcp` lists the connector as hidden. If a connector seems dead, check for a local
duplicate before re-authorising.

### Current connectors

| Connector | Status | Used by |
|---|---|---|
| **Notion** | ✅ account-level, verified live | lesson log, Hermes handoffs |
| **Mobbin** | ⚠️ Claude Code only — see below | design reference for UI work |

**Notion** — `claude.ai/customize/connectors`. Read/write tools both set to Always allow.
Verified by calling `notion-get-users`, not by reading a status list.

**Mobbin** — `https://api.mobbin.com/mcp`. Design pattern and screenshot reference for
building responsive apps and sites; pairs with `icon-libraries` and the external
`impeccable` plugin.

Currently added via `claude mcp add mobbin --scope user`, which is why it reaches Claude
Code but **not Cowork or claude.ai** — confirmed by searching the live tool registry in a
Cowork session and finding no Mobbin tools.

To make it universal:

```
claude mcp remove mobbin          # drop the local entry first, or it shadows the connector
```

then add `https://api.mobbin.com/mcp` as a custom connector at
`claude.ai/customize/connectors`.

### Diagnosing a connector

1. **Call one of its tools.** A live call settles it; a warning list does not.
2. **Check for a local duplicate** — `claude mcp list`. A Claude Code entry shadows the
   account connector at the same URL.
3. **Check the active auth** — `/status`. Connectors are fetched only under a claude.ai
   subscription login. An `ANTHROPIC_API_KEY`, a third-party provider, or a profile
   credential disables connector loading entirely, even after a previous `/login`.
4. **`connected · session token rejected`** means the Claude Code login expired, not that
   the connector needs re-authorising. Run `/login`, then reconnect from `/mcp`.

**Beware the two-servers trap.** Installed plugins bundle their own MCP servers that
duplicate account connectors — `plugin:productivity:notion`, `plugin:legal:slack`,
`plugin:small-business:quickbooks` and others sit permanently on the needs-authentication
notice. They are mostly redundant. Prefer the account connector; ignore or disable the
plugin duplicates. This has already produced one wrong "Notion needs authorising" claim.

---

## Reference clones (not dependencies)

`icon-libraries` ships generated name lists rather than icon files. The upstream clones
live **beside** this repo and are gitignored:

```
F:\Projects\refs-lucide      git clone --depth 1 https://github.com/lucide-icons/lucide
F:\Projects\refs-phosphor    git clone --depth 1 https://github.com/phosphor-icons/homepage
```

They exist only to regenerate the lists (procedure in the skill). Nothing at runtime reads
them, and they must never be committed.

---

## Rules

1. **Never vendor.** Reference and pin. A local copy is a fork and must be declared here.
2. **Wrappers stay thin.** A wrapper adds house rules only. If it starts restating
   upstream's content, it has begun forking by accident.
3. **External skills are machine-tier by default.** Promoting one to universal means the
   account store's 1,024-char description cap applies to text you do not control — which
   forces a fork. Weigh it as such.
4. **Verify before claiming installed.** A plugin that is not installed cannot run. Check
   the session, do not carry the name forward from memory.
