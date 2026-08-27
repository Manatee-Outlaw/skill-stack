---
name: to-prd
description: Turn the current conversation context into a structured PRD (Product Requirements Document). Use when the user wants to capture what's been discussed into a formal spec, says "write this up as a PRD", or wants to document a planned feature before building it. Does NOT re-interview the user — synthesises what's already been discussed.
metadata:
  tier: universal
  plugin: skill-engineering
---

# To PRD

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Use analogies and plain language throughout.

This skill takes the current conversation context and produces a PRD. Do NOT interview the user — synthesise what you already know from the conversation.

## Process

1. Review everything discussed in the conversation so far.
2. If any code or files have been shared, review them to understand the current state.
3. Sketch out the major areas that will need to be built or changed. Look for self-contained pieces that can be built and tested independently.
4. Check with the user that these areas match their expectations, and which ones they want tests written for.
5. Write the PRD using the template below and save it as a document.

---

## PRD Template

# PRD: [Feature Name]

## Problem Statement
[The problem being solved, from the user's perspective. What pain exists today?]

## Solution
[The solution, from the user's perspective. What will exist after this is built?]

## User Stories
A numbered list covering all aspects of the feature. Each story follows this format:
As a [type of person], I want [something], so that [benefit].

This list should be extensive — cover the normal case, edge cases, error situations, and any admin or power-user scenarios.

## Implementation Decisions
Key decisions about how this will be built:
- Parts of the system that will be created or changed
- Any significant technical choices made
- Data or structural changes required

Do NOT include specific file names or code — they go out of date quickly.

## Testing Decisions
- What a good test looks like for this feature
- Which parts will have tests written
- Any similar existing tests that can serve as reference

## Out of Scope
[What this document explicitly does NOT cover — this is as important as what's in scope]

## Further Notes
[Anything else worth capturing — open questions, future considerations, known dependencies]

---

## Notes on good PRDs

- Use the project's own vocabulary throughout
- User stories should be thorough — if in doubt, add the story
- "Out of scope" prevents scope creep — take it seriously
