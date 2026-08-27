---
name: grill-with-docs
description: A grilling session that challenges your plan against the project's existing language and documented decisions, and updates documentation (CONTEXT.md, decision records) as decisions crystallise. Use when user wants to stress-test a plan, align language before building, or says "grill me on this". Prefer this over grill-me for any coding or engineering project.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Grill With Docs

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Use analogies and plain language throughout.

A grilling session — like grill-me, but with domain awareness. Interview me relentlessly about every aspect of this plan. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions **one at a time**, waiting for feedback before continuing.

If a question can be answered by looking at files or context already shared in this conversation, use that instead of asking.

---

## Domain awareness

Before starting, look for existing documentation in any files shared in the conversation:

- **CONTEXT.md** — the project's shared language/glossary. Terms defined here are canonical.
- **docs/adr/** — records of past decisions that should not be re-litigated unless there's a strong reason.

If these don't exist yet, create them lazily — only when there's something worth writing down.

---

## During the session

### Challenge against the glossary
When the user uses a term that conflicts with CONTEXT.md, call it out. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language
When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things in your domain."

### Discuss concrete scenarios
Stress-test domain relationships with specific scenarios. Invent edge cases that force the user to be precise about where one concept ends and another begins.

### Cross-reference with context
When the user states how something works, check if it contradicts anything already shared. Surface contradictions clearly: "Your earlier description says X, but now you're saying Y — which is right?"

### Update CONTEXT.md inline
When a term is resolved, update CONTEXT.md right there — don't batch up. Capture decisions as they happen.

**CONTEXT.md format:**
```
# Glossary

## [Term]
[One-sentence definition from the domain expert's perspective. No implementation details.]
```

### Offer decision records sparingly
Only offer to record a decision when all three are true:
1. **Hard to reverse** — changing your mind later is costly
2. **Surprising without context** — a future reader would wonder "why did they do it this way?"
3. **A real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of these is missing, skip it.

**Decision record format (save to docs/decisions/ or similar):**
```
# [Short title]
Date: [today]
Status: Accepted

## Context
[Why this decision was needed]

## Decision
[What was decided]

## Consequences
[What this means going forward]
```

---

## End of session
Summarise all decisions made and any terms added to the glossary as a compact list.
