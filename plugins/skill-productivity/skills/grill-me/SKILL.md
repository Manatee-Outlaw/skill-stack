---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or says "grill me". Also use at the start of any new feature or task to clarify scope before diving in.
metadata:
  tier: universal
  plugin: skill-productivity
---

# Grill Me

> **Communication note:** The user is not a programmer. Avoid technical jargon in all responses. When a technical concept must be mentioned, briefly explain it in plain English first. Use analogies and plain language throughout.

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions **one at a time**, waiting for my response before continuing.

If a question can be answered by looking at files or context already shared in this conversation, use that instead of asking.

## How to run this session

1. Start by asking what plan or change the user wants to discuss, if not already clear.
2. Work through every meaningful decision: what it does, who uses it, edge cases, constraints, dependencies.
3. For each question, state your own recommended answer — don't just ask open questions.
4. Keep going until every branch of the decision tree is resolved and you could hand this plan to someone else without ambiguity.
5. At the end, summarise the decisions made as a compact list.
