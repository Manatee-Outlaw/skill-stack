---
name: improve-codebase-architecture
description: >
  Find refactoring opportunities in a codebase that will make it more testable,
  easier to navigate, and less tangled. Use when the user wants to improve
  architecture, find refactoring opportunities, says the codebase is getting
  messy, wants to make code easier to test, or asks how to clean things up.
  Trigger phrases: "clean up the codebase", "codebase is getting messy",
  "hard to test", "refactor this", "find refactoring opportunities",
  "explore the architecture", "what could be improved structurally".
  Run this periodically on any active codebase — not just when things are broken.
  NOTE: For a deep structured architecture audit via Claude Code (quarterly cadence),
  use architecture-review instead. This skill is for interactive exploration in chat.
metadata:
  tier: machine
  plugin: skill-engineering
---

# Improve Codebase Architecture

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Use analogies and plain language throughout.

Think of this skill like a property survey — walking through a building to find where the structure is sound and where there are cracks worth fixing before they become bigger problems. The goal is to find parts of the codebase that are tangled or hard to test, and propose targeted improvements.

**This skill vs architecture-review:**
- This skill: interactive, exploratory, in chat, anytime — good for "let's poke around and see what's worth improving"
- architecture-review: structured deep audit via Claude Code, quarterly cadence — good for "run a thorough check and give me a full report"

---

## Key ideas (explained plainly)

- **Module** — any chunk of code with a job to do (a function, a file, a package).
- **Deep module** — does a lot of work behind a simple, clean front door. Easy to use and test. Good.
- **Shallow module** — the front door is almost as complicated as what's inside. Not much value. Worth fixing.
- **Seam** — a place where one part of the code can be swapped out or tested without touching everything else. More seams = easier to test and change.
- **Locality** — when a bug or change only requires touching one place, not ten.

**Deletion test:** imagine removing a chunk of code entirely. If the complexity just disappears, it wasn't pulling its weight. If the complexity reappears scattered across many other places, it was genuinely useful.

---

## Process

### 1. Explore
Review the code and files shared in the conversation. Look for friction:

- Needing to read many different files just to understand one thing
- Parts that are nearly impossible to test in isolation
- Pieces that are tightly tangled together, so changing one breaks others
- Areas where bugs would be hard to track down because everything is connected

Apply the deletion test to anything that looks like it's not earning its keep.

Also read any glossary (CONTEXT.md) and past decision records.

### 2. Present candidates
Show a numbered list of improvement opportunities. For each one:

- **What's involved** — which parts of the code
- **The problem** — why this is causing friction today
- **The suggestion** — what would change, in plain English
- **The benefit** — how it would make the code easier to test, change, or understand

Do NOT jump to solutions yet. Ask: "Which of these would you like to explore?"

### 3. Work through it together
Once the user picks one, dig into it together. Walk through the constraints, what depends on what, and what becomes easier once the change is made.

As you go:
- If a new concept gets named that isn't in the glossary, add it.
- If the user rejects an idea with a strong reason, offer to record it so future reviews don't re-suggest it.

---

## Connection to diagnose
If a bug was just fixed and it revealed that the code structure made it hard to catch or test, this skill picks up where diagnose left off. The friction from the bug is the best starting point.
