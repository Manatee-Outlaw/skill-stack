---
name: no-assumed-memory
description: >
  Never assume a fresh Claude Code session, subprocess, or any other
  stateless collaborator shares memory with a different conversation or
  window — even one running minutes earlier on the same project. When
  handing off a task that depends on a prior decision, design, or
  approval, either embed the actual content directly rather than
  referencing it by claim, or have the fresh session independently verify
  it against real, checkable evidence (files on disk, git history, live
  state) rather than trust an assertion about what happened elsewhere.
  Trigger whenever writing a task for a separate session/window, or
  whenever a fresh session is told something was "already decided"
  somewhere it can't see. No trigger phrase needed.
metadata:
  tier: universal
  plugin: skill-core
---

# No Assumed Memory

## Why this skill exists

Two real incidents in one project, both from the same root cause:

1. A task was written for a fresh Claude Code window referencing "the
   design already approved earlier" — but that approval happened in a
   different window's conversation, invisible to the fresh one. The fresh
   window correctly refused to build against a spec it couldn't verify
   had really been approved, rather than trusting the claim — the right
   instinct, but it cost a round trip that embedding the actual approved
   content directly would have avoided entirely.
2. Content meant for one window (a task description) was accidentally
   pasted into a different window that had no context for it, producing
   confusion before the mix-up was caught.

Both point at the same underlying fact: **separate windows, separate
sessions, and separate subprocesses do not share memory just because they
're working on the same project, sometimes minutes apart.** Each one only
knows what's actually visible to it — files on disk, its own conversation
history, and whatever is explicitly included in what it's given. Nothing
else.

## The core rule

**Treat every fresh session as having zero memory of anything that
happened outside its own visible context — because it does.** If a task
depends on a decision, a design, or an approval that happened elsewhere,
that content needs to actually be IN the task, not referenced as
something the fresh session should already know or trust on assertion.

## What to do, when handing work to a separate session

1. **When a task depends on a prior decision or design, embed the actual
   content** — the real specifics, not "per what we already agreed."
   A fresh session has no way to verify a claim about a conversation it
   wasn't part of.
2. **If the content is too large to fully embed, point at something the
   fresh session CAN independently verify** — a specific file already
   saved to disk, a specific git commit, a specific piece of live state
   it can check itself — rather than a summary it has to take on faith.
3. **If a fresh session is skeptical of an unverifiable claim and asks for
   confirmation before proceeding, that's the correct instinct, not a
   problem to route around.** The fix is to give it real, checkable
   grounding — not to insist it trust the claim anyway.
4. **Before sending anything to a specific window, confirm it's actually
   going to the right one.** A brief pause to check "is this the window
   that's expecting this content" costs nothing; a misdirected paste can
   cause real confusion, especially across several windows running in
   parallel on the same project.

## Relationship to other skills

- **verify-before-claiming** is about proving claims with real execution.
  **no-assumed-memory** is about a specific kind of unearned trust — not
  a false claim, but a true one that a separate session has no way to
  verify from where it sits.
- **trust-the-live-signal** is closely related: a fresh session's own
  live check of real files/state is a trustworthy signal; a summary of
  what happened in a different conversation is not, no matter how
  accurate that summary actually is.

## Trigger this skill

- Whenever writing a task or instruction for a separate Claude Code
  window, subprocess, or any other session that won't share this
  conversation's memory
- Whenever a fresh session reports being unable to verify something it's
  been told was "already decided" — treat this as a signal to provide
  real grounding, not an obstacle to push past
- Before pasting or sending content across multiple open windows — confirm
  the destination
- No trigger phrase needed; always-on whenever work crosses a session
  boundary
