# External skill dependencies

Every third-party skill this library relies on. **Referenced and pinned, never copied** —
vendoring forks a skill and forfeits every upstream fix.

Re-check this file quarterly, or whenever an external skill misbehaves.

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

## Rules

1. **Never vendor.** Reference and pin. A local copy is a fork and must be declared here.
2. **Wrappers stay thin.** A wrapper adds house rules only. If it starts restating
   upstream's content, it has begun forking by accident.
3. **External skills are machine-tier by default.** Promoting one to universal means the
   account store's 1,024-char description cap applies to text you do not control — which
   forces a fork. Weigh it as such.
4. **Verify before claiming installed.** A plugin that is not installed cannot run. Check
   the session, do not carry the name forward from memory.
