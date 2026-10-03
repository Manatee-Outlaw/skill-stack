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
| **Account plugin upload** | uploaded `.plugin`, held server-side as "My Uploads"; materialised locally under `local-agent-mode-sessions\…\rpm\` | **every desktop-app agent session** — Cowork *and* the Code tab. NOT Cowork-only. | Upload in the desktop app. Nothing local reaches it — not the repo, not the CLI cache, not `dist/`. |
| **CLI marketplace** | `claude plugin marketplace add <path or repo>`, cached under `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` | Claude Code CLI **and** the desktop app (see precedence below) | **Bump the version in `plugin.json` first**, then `claude plugin update <name>@<marketplace>`. An update without a version bump is a silent no-op. |
| **Claude Code user skills** | `%USERPROFILE%\.claude\skills\<name>` | Claude Code CLI **and the desktop Code tab** (proven 2026-09-09) | Manual — re-clone or `git pull` in that folder. |
| **Project scope** | `<project>\.agents\skills\<name>` | only agents whose working folder is that project | Manual. Narrowest scope available. |

### Which copy actually wins, when a plugin exists on two paths

A desktop session reads the account-upload plane **and** the CLI plugin cache. When the
same plugin name is present in both, **the account upload wins.** Verified 2026-09-09:
`skill-engineering` existed as an Aug 28 account upload (1.0.0) and as a CLI cache entry
(1.1.0); a desktop session loaded the 1.0.0 copy, confirmed by reading the base directory
the skill was actually served from. `ponytail`, `impeccable` and `legal-skills` exist in
**no** account upload and load in that same session from the CLI cache — which is how we
know both planes are read rather than one.

The consequence is nasty: **updating the CLI plane changes nothing you can see in the
desktop app if an account upload of the same name exists.** A full skill-library audit was
run against twelve-day-old skill bodies this way, with an up-to-date CLI cache sitting right
beside it, and nothing anywhere reported a problem.

### The refresh key is a version string, not file content

`claude plugin update` compares the `version` in `plugin.json`. Edit fifty skills, leave the
version alone, and the plugin cache never changes — while the command prints
`already at the latest version`. All five plugins here sat at `1.0.0` from creation until
2026-09-09, so **every skill edit between 2026-08-27 and then was invisible to Claude Code.**

Bump the version as part of shipping, not as an afterthought. `scripts\sync.bat` does not do
this and cannot: it only runs `marketplace update`, which refreshes the marketplace
*definition* and never touches installed plugin content.

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
- **A `.plugin` upload can be accepted and still not persist.** On 2026-09-09 five bundles
  were uploaded through the desktop app; it matched them to existing plugins and prompted
  *"you're going to replace the underlying file"*. After confirming: claude.ai still showed
  1.0.0, two fresh server fetches still returned `updatedAt: 2026-08-28T21:24`, and the new
  content existed nowhere on disk outside the repo and the CLI cache. No error was shown, and
  app logging had been inactive since 2026-08-24, so nothing recorded the attempt. Treat an
  upload as unverified until the version visibly changes on claude.ai.
- **A CLI marketplace update does not.** `marketplace update` returned ok and changed
  nothing a running Cowork session could see.

### Verifying, rather than hoping

Ask a session to **read the actual file**, not to list names. A stale skill has the right
name and the wrong content — the failure above was invisible to any check that stopped at
the name:

> *"List the skill-private skills you can see, then read the brand-guidelines SKILL.md you
> have loaded and tell me whether it names the real brands or contains placeholders."*

### Open questions — unverified, do not repeat as fact

- ~~**Does Cowork read `%USERPROFILE%\.claude\skills`?**~~ **Partly answered 2026-09-09.**
  The **desktop Code tab does**: `brainstorming` was loaded in a live session, exists in zero
  account-upload plugins, and lives only at `%USERPROFILE%\.claude\skills\brainstorming`.
  The old "evidence says no" rested on never having seen `unlazy` appear — an absence nobody
  had checked directly, which is the reasoning `verify-before-claiming` exists to forbid.
  **Cowork specifically is still untested**; do not extend the Code-tab result to it.
- ~~**Why does `ponytail` show installed in the desktop Plugins panel but not in Cowork?**~~
  **Half answered 2026-09-09.** `ponytail` loads fine in the desktop Code tab, served from
  the CLI plugin cache — so the desktop app reads that plane. Whether Cowork also does, and
  therefore why it was missing there, remains open.
- **Still open, and now the blocking one: how do you ship to the account-upload plane?**
  The only known route is the desktop app's upload, and on 2026-09-09 it did not persist
  (see above). Until that is resolved the desktop plane cannot be updated at all — and it
  takes precedence over the CLI plane for any plugin name present in both.

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
| Status | **FORK — description and six role-neutral body edits deliberately diverge; everything else tracks upstream** |

**What diverges: the description, plus a small fixed set of role-neutral body edits.** Measured
2026-10-02 against upstream `skills/adhd/SKILL.md` (11118 bytes). The body edits exist to make the
body honour the broader description — without them the body says "coding agent" while the
description promises business use:

1. Intro: "senior engineer" → "any senior practitioner — engineer, marketer, founder", plus
   launch angle / pricing page / product name as examples.
2. Pre-flight Step 1: brainstorming phrases ("brainstorm", "let's figure out", …) opt in
   automatically; upstream opts in only on `/adhd` or an explicit ADHD-mode request.
3. Step 2 high-stakes list: adds launch angle, pricing model, positioning, go-to-market;
   "Side project at 11pm" → "A throwaway tweak at 11pm".
4. Viability score: "could it actually ship" → "shipped or executed with the resources at hand".
5. Deepen step: builder/coder first step → domain-neutral ("write the code, draft the copy,
   mock the page, run the test").
6. Upstream's closing `## Source spec` section is not carried (see below).

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
3. Take upstream's body changes wholesale; the method is theirs and improves upstream —
   then re-apply the six role-neutral edits listed above.
4. **Never take upstream's description.** Re-apply ours.
5. Re-check ours is still ≤1024 chars — it is universal-tier, so the account-store cap
   applies (`scripts/validate.py` enforces this).

Because the divergence is one field plus a listed set of body edits, a re-sync stays a
checklist. Keep it that way: any body edit not in the list above turns this into an unmanaged
fork — add it to the list the same day, or revert it.

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
