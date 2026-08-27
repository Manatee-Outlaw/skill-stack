---
name: discord-announcements
description: >
  Draft Discord announcements for any occasion — feature releases, bug fixes,
  maintenance windows, urgent notices, or community updates. Produces
  ready-to-post messages tailored to the audience and tone. Use when the user
  asks to "draft a Discord announcement", "announce to the community",
  "write a Discord message for streamers", "what should I tell my community
  about X", or when a feature ships that users need to know about. Also trigger
  proactively when a bug is fixed that was silently affecting users — they
  deserve to know. Always ask about audience and urgency before drafting.
metadata:
  tier: universal
  plugin: skill-engineering
---

# Discord Announcements

Drafts clear, appropriately-toned Discord announcements for any occasion.
The goal: users get the information they need, presented in a way that
builds trust rather than creating confusion or alarm.

---

## Step 1 — Establish context before drafting

Ask these questions if not already clear from context. Don't assume.

1. **What happened?** (feature shipped, bug fixed, downtime, etc.)
2. **Who needs to know?** (all users, specific role, new users only)
3. **Is any user action required?** (update software, reconnect account, etc.)
4. **What's the tone?** (exciting news, routine update, apology, urgent warning)
5. **Is there a deadline?** (act before X date, do this before your next stream)

If the context is already clear from the current conversation (e.g., a feature
just shipped), skip straight to drafting — don't re-ask what you already know.

---

## Step 2 — Choose the template

### Template A — Feature release (something new is available)
Use for: new features, improvements, quality-of-life updates.
Tone: positive, brief, action-oriented.

Structure:
```
🎉 [Feature name] is live

[One sentence: what it does and why it matters to the user]

[Optional: what they need to do to use it. If nothing: "No action needed — it's
already active for you."]

[Optional: one caveat or known limitation, if relevant]
```

### Template B — Bug fix (something broken is now fixed)
Use for: fixes to things users were experiencing problems with.
Tone: straightforward, no over-apologizing, action-only if needed.

Structure:
```
✅ [Brief description of what was fixed]

[One sentence: what the problem was and that it's resolved]

[If action required: "To get the fix: [specific step]"]
[If no action needed: "No action needed — the fix is already live."]
```

### Template C — User action required (something users must do)
Use for: updates that require users to take a step (re-download, reconnect, etc.)
Tone: clear, specific, no ambiguity about what to do.

Structure:
```
📋 Action needed: [brief description]

[One sentence: why this is needed]

To update:
1. [Step one — be specific]
2. [Step two]
3. [Step three if needed]

[Optional: what happens if they don't do this]
[Optional: when they need to do it by]
```

### Template D — Maintenance / downtime notice
Use for: planned maintenance windows, temporary unavailability.
Tone: calm, informative, specific about timing.

Structure:
```
🔧 Maintenance window: [date/time range]

[Platform/service] will be briefly unavailable on [date] from
[start time] to approximately [end time] [timezone].

[One sentence: what's being done]

No data will be lost. [Or: any other relevant reassurance.]
```

### Template E — Urgent notice
Use for: active issues, immediate action needed, security concerns.
Tone: clear and direct, not alarmist. Factual.

Structure:
```
⚠️ [Brief description of the issue]

[What users may be experiencing]

[What they should do right now]

We're [working on it / it's resolved as of X]. Will update here.
```

---

## Step 3 — Draft and present

Draft the announcement using the appropriate template.
Present it as ready-to-post copy.

Then add a "posting checklist":
- [ ] Right channel? (#announcements, #updates, #urgent, etc.)
- [ ] Right role ping? (@streamers, @everyone, or no ping)
- [ ] Best time to post? (before streams, not during peak hours)
- [ ] Anything that needs to be true before posting? (fix deployed, etc.)

---
