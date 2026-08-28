---
name: hermes-upload
description: >
  Generate a structured handoff document from the current conversation and write it to the
  Notion Hermes Handoffs database so the next session resumes with full context. Trigger
  immediately on "hermes upload" — do not ask for clarification, proceed through all steps.
  One page per chat, keyed on the exact chat title and updated in place; never create a
  second page or a version suffix for a chat that already has one. Every number in the
  handoff must carry its provenance — sample or population, measured or estimated, and by
  whom — because a figure that loses its denominator becomes a false statistic in the next
  session, which has no way to see the qualifier was ever there. Also triggers on
  "export to hermes", "send to hermes", "hermes handoff".
metadata:
  tier: universal
  plugin: skill-engineering
---

# Hermes Upload

Generates a structured handoff document so the next session can resume with full context,
then writes it to the Notion **Hermes Handoffs** database — one page per chat, keyed on the
exact chat title, edited in place.

**Notion, not the old cloud folder.** A handoff exists to be read on the *next* device,
which is often a laptop or tablet. The previous destination was unreachable there, and its
inability to edit a file in place forced the `v1`/`v2`/`v3` sprawl this skill used to
generate.

## Trigger
`hermes upload`

---

## Execution — Run All Steps in Order

### Step 1 — Generate the Handoff Document

Using the full context of this conversation, produce the following document. Write it as if the next session has zero prior context — be specific and complete, not high-level:

```
1. WHAT WE BUILT OR CHANGED
   List every feature, fix, or file created or modified in this conversation.
   Include exact filenames and what each one does.

2. DECISIONS MADE
   Every architecture, design, or product decision reached.
   Include the reasoning and what alternatives were ruled out.

3. CURRENT KNOWN BUGS OR ISSUES
   Anything broken, half-built, or flagged for later.

4. EXACT STATE OF THE CODEBASE
   What is deployed and working vs. WIP vs. planned but not started.

5. OPEN QUESTIONS OR DEFERRED ITEMS
   Things explicitly set aside with "we'll do this later."

6. CONTEXT HERMES NEEDS THAT ISN'T IN THE CODE
   Business logic, user behavior observations, workarounds,
   gotchas in the tech stack, anything implicit.
```

Format: plain text. Actual details, not paragraph summaries.

**Every number in a handoff carries its provenance, or it does not go in.**
For each figure, the handoff must say: is it a SAMPLE or the POPULATION, was it
MEASURED or ESTIMATED, and BY WHOM. Write "8 of 8 in a sample of 8 (of ~80
total), checked by me this session" — never "8 of 8".

This is not pedantry; it is the failure this rule was written for. A session
sampled 8 items, found 8 clean, and reported it correctly **as a sample**. The
handoff recorded "8 of 8". The next session read that as the population and told
the user it was a fact. The real number was 78 of 80. Nobody lied and nothing was
unverified — the denominator was simply dropped in transit, and a sample became a
statistic.

The handoff is the one document every cold start treats as authoritative and
nobody re-derives. That is exactly why it is the worst possible place to lose a
qualifier: a hedge stripped here is never recovered downstream, because the
downstream reader has no idea a hedge ever existed. **A figure that arrives
without its denominator has already lost the thing that made it true.**

If you cannot state a number's provenance, either go and establish it, or write
the qualifier you do have — "unverified", "estimated", "sampled, denominator
unknown". An honest hedge survives the handoff. A stripped one does not.

---

### Step 2 — Determine the Chat Name

Use the **exact title of the current Claude chat conversation** as the file name prefix.

- Do NOT derive or invent a name from the conversation content.
- Do NOT paraphrase or shorten the chat title.
- The chat title is the canonical identifier for this conversation's handoff series.
- Examples of correct usage:
  - Chat titled "Payments API Refactor" → use `Payments API Refactor`
  - Chat titled "Q3 Analytics Dashboard" → use `Q3 Analytics Dashboard`
- If you are uncertain of the exact chat title, ask the user before proceeding.

The chat title is the **key**. One chat means one page, updated — not a new page each time.

---

### Step 3 — Find the existing handoff page

The destination is the Notion **Hermes Handoffs** database:

`collection://0a0836e0-289d-4398-9168-52bfca8f4a70`
(under the *Claude Skill Stack* page)

Query it for a page whose `Chat` property matches the exact chat title from Step 2.

- **Found** → Step 4a: update it.
- **Not found** → Step 4b: create it.

**Do not create a second page for a chat that already has one.** No `v2`, no "(updated)",
no date appended to the title. That convention existed only because the previous cloud
store could not edit a file in place. Notion can, and page history keeps the record.

---

### Step 4a — Update the existing page

Replace the page body with the current handoff document. Refresh:

| Property | Value |
|---|---|
| `Status` | `active` · `complete` · `stalled` · `abandoned` |
| `Next step` | The single most useful line for a future session |
| `Project` | If it changed |

`Updated` maintains itself. Previous states remain in Notion's page history — nothing is
lost by editing in place.

### Step 4b — Create a new page

| Property | Value |
|---|---|
| `Chat` | The exact chat title — never derived, shortened, or invented |
| `Project` | The project or repo this belongs to |
| `Status` | Usually `active` |
| `Next step` | The single most useful line for a future session |

Page body: the handoff document from Step 1.

---

### Step 5 — Confirm to the user

Report:
- The chat title used as the key
- Whether a page was **created** or **updated**
- The `Next step` recorded
- One sentence on what the next session will find

Include the page URL so it can be opened from any device — a handoff you cannot read on
the machine you are picking up on has failed at its only job.

---

## Error Handling

- **Notion not reachable**: display the full handoff document in chat, say Notion could not
  be reached, and point at the connector in claude.ai settings. **Never fail silently** —
  the document in chat is better than no handoff.
- **Multiple pages match the same chat title**: do not guess. Report them and ask which is
  canonical. Duplicates are the exact failure this design removes; finding one means the
  rule was broken earlier and needs fixing rather than compounding.
- **Chat title uncertain**: ask. Never guess — a wrong key silently splits a chat's history
  into two pages.

## Hard Rules

- Always use the exact chat title — never derive, shorten, or invent a name.
- **Always search before writing.** One chat, one page, updated in place. No version
  suffixes, ever.
- Never skip the write — if something fails, show the document in chat rather than silently failing.
- The handoff document must be written as if the next session is reading a cold brief with no prior context.
- Never write a bare number. Every figure carries sample-or-population, measured-or-estimated, and by whom. A denominator dropped in a handoff never comes back — the next reader cannot miss what they cannot see was removed.
