---
name: project-planning
description: >
  Strategic project planning for solo operators and small business owners.
  Use for infrastructure decisions, build-vs-buy analysis, migration planning,
  risk assessment, effort estimation, and sequencing work. Designed for
  non-technical founders who need to make good decisions about systems,
  tools, and investments without a team to delegate to. Trigger phrases:
  "should we build or buy", "is it time to migrate", "help me plan this",
  "what are the risks", "how do we sequence this", "assess this decision",
  "remote hosting", "infrastructure assessment".
sources:
  - General PM best practices (PMI, DACI, RICE frameworks)
  - Adapted for solo/small-team operators without engineering staff
last_updated: 2026-05-27
metadata:
  tier: universal
  plugin: skill-productivity
---

# Project Planning Skill

> **Communication note:** The reader may not be technical.
> Lead with business impact, not technical detail. Use plain language.
> Always give a recommendation — don't just present options and leave the decision open.

---

## When to use this skill

Use this skill when facing any of the following:

- **Infrastructure decisions** — Should we stay on this server? Move to the cloud? When?
- **Build vs. buy** — Should we build this ourselves or use an existing tool/service?
- **Migration planning** — How do we move from what we have now to what we need?
- **Risk assessment** — What could go wrong, how likely is it, and what does it cost us?
- **Sequencing decisions** — What order should we tackle these projects in?
- **Effort vs. value** — Is this worth doing now, later, or never?

---

## Core frameworks

### 1. The Four Questions (for any strategic decision)

Before recommending anything, answer these four questions explicitly:

1. **What problem are we actually solving?** (Not the surface problem — the underlying one)
2. **What does success look like in plain terms?** (Not metrics — a sentence describing the world after it's done)
3. **What's the cost of doing nothing?** (What happens if we never make this change?)
4. **What's the reversibility?** (If we're wrong, how hard is it to undo?)

Low reversibility decisions deserve more caution and more analysis.
High reversibility decisions deserve speed over thoroughness.

---

### 2. Risk Assessment Matrix

For every significant risk identified, score it on two axes:

**Likelihood:** How probable is this?
- Low: could happen but unlikely in the next 12 months
- Medium: realistic possibility in the next 12 months
- High: likely to happen, possibly already happening

**Impact:** How bad is it if it does happen?
- Low: inconvenient, recoverable within hours, minimal business effect
- Medium: disrupting, recoverable within days, noticeable business effect
- High: severe, potentially unrecoverable, existential business effect

Present findings as: [Risk] → [Likelihood] × [Impact] = [Priority]

High × High = address immediately
High × Medium or Medium × High = plan for mitigation
Everything else = monitor or accept

---

### 3. Infrastructure Assessment Framework

Use when evaluating whether to stay on current infrastructure or migrate.

**Current state audit — answer each:**
- What is the system? (hardware, hosting, location)
- What does it cost? (money + time to maintain)
- What are its hard limits? (users, data, uptime, geographic reach)
- What are its failure modes? (what breaks and how often)
- What mitigations are in place? (backups, redundancy, monitoring)
- What mitigations are missing?

**Threshold triggers — define the specific conditions that make migration necessary:**
- User count threshold
- Uptime requirement threshold
- Data volume threshold
- Revenue threshold (when the cost of downtime exceeds the cost of migration)
- Reliability incident threshold (X outages in Y months = time to move)

**Migration options — for each viable option:**
- What is it? (plain description)
- What does it cost? (monthly, setup, ongoing maintenance time)
- What does migration take? (effort, downtime, risk)
- What does it solve? (which current problems go away)
- What does it not solve? (which problems remain)
- Reversibility: if we move to this and don't like it, how hard is it to move again?

**Recommendation format:**
1. Current state verdict: acceptable / monitoring / urgent
2. Recommended trigger: "migrate when X happens"
3. Recommended option: named, with reasoning
4. Next step: one concrete action to take now

---

### 4. Build vs. Buy Framework

Use when deciding whether to build something custom or use an existing tool/service.

**Build if:**
- The capability is core to what makes your product different (competitive advantage)
- No existing tool does it at a price you can justify
- The maintenance burden is low once built
- You have a developer (Claude) who can maintain it

**Buy if:**
- The capability is commodity (everyone needs it, it's not your edge)
- An existing tool does it well at an acceptable cost
- Switching costs are low (you could change tools later without major rework)
- The tool's reliability exceeds what you could build yourself

**The hidden cost of building:** every custom system you build is a system you have to maintain, debug, and update forever. Before building, ask: in 18 months, would you rather be improving your core product, or maintaining this piece of infrastructure?

---

### 5. Sequencing Framework (for multiple projects)

When deciding order of operations across multiple projects, score each on:

**Value:** How much business impact does this create?
- High: directly drives revenue, retention, or legal protection
- Medium: improves operations or reliability
- Low: nice to have

**Urgency:** How time-sensitive is this?
- High: there is a real cost to waiting (legal exposure, active failures, blocked revenue)
- Medium: would benefit from doing soon but no immediate cost to waiting
- Low: could wait 6+ months with no meaningful consequence

**Effort:** How much work is it?
- High: multi-session build, multiple moving parts
- Medium: single session with some complexity
- Low: quick, well-defined task

**Dependencies:** What must be true before this can start?
- List anything that blocks it

Recommended sequence: High Value + High Urgency first, regardless of effort.
Never let Low Urgency work displace High Urgency work because it's easier.

---

### 6. Decision Record Format

When a significant strategic decision is made, record it:

```
DECISION: [Short title]
Date: [today]
Status: Accepted

Context:
[Why this decision was needed — what problem or choice prompted it]

Decision:
[What was decided, in one clear sentence]

Reasoning:
[The 2-3 factors that drove the choice]

Consequences:
[What this means going forward — what changes, what is now true]

Trigger to revisit:
[The specific condition that would make us reconsider this decision]
```

---

## Output format

For any assessment or planning output:

1. **Current state** — what is true right now, plainly stated
2. **The real problem** — the underlying issue (may differ from the surface question)
3. **Options** — 2-4 realistic choices, each with cost/benefit/risk
4. **Recommendation** — a clear pick with reasoning
5. **Next step** — one concrete action to take now
6. **Trigger to revisit** — when should we look at this again?

Never leave a planning session without a recommendation and a next step.
A decision deferred indefinitely is a decision to accept the current state.
