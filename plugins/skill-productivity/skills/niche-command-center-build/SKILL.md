---
name: niche-command-center-build
description: A two-phase skill for designing and building a personalized command center. Phase 1 researches the user's past conversations and proposes a tailored dashboard concept. Phase 2 interviews the user to spec a Node.js MVP running entirely locally with JSON file storage. Use when the user says "build me a command center", "design my dashboard", or "niche command center build skill."
metadata:
  tier: machine
  plugin: skill-productivity
---

# Niche Command Center Build Skill

This skill takes a user from zero to a fully specced, locally-running personal command center. It runs in two phases — design first, then build spec. Never skip Phase 1; the quality of Phase 2 depends entirely on knowing who you're building for.

---

## PHASE 1 — Design: Research & Propose

**Trigger phrase (or equivalent):** *"Based on our previous chat conversations, what do you think a personal command center could look like for me? What would be the most effective dashboard I could build to streamline how I actually work?"*

### Step 1: Research

Before saying anything, silently run the following searches against the user's past conversations:

- Their job, role, or primary income source
- Their side businesses, projects, or side income
- Their stated goals (financial, personal, professional)
- Their biggest frustrations, blind spots, or dropped balls
- Any tools, apps, or trackers they already use
- Their working style (remote/office, hours, pace)
- Any personal habits or routines they track or want to track

Do not ask the user for any of this. Find it. If you can't find enough context (fewer than 3 meaningful data points), tell the user you don't have enough history and ask them 3 targeted questions before proceeding.

### Step 2: Identify Their "Niche"

Every command center has a niche — the organizing identity of the person using it. Name it clearly before designing. Examples:

- "Multi-business solo operator running 4 income streams from a home office"
- "Field sales rep managing a 60-account territory across 3 states"
- "Creator monetizing across YouTube, Patreon, and merchandise"
- "Freelance consultant juggling 5 active client engagements"

The niche determines which modules matter and which are noise.

### Step 3: Propose the Command Center

Present the design as a **strategic overview, not a feature list**. Lead with:

1. **The core problem it solves** — one sentence. What drops through the cracks today that this fixes?
2. **The hero metric** — the single number at the top of the screen that, if it's green, means their day started well
3. **The modules** — 4-6 sections, each named and justified. For each module, explain *why it belongs* given their specific life, not just what it does
4. **What's intentionally left out** — name 1-2 things that might seem obvious but don't belong in the MVP

Do not use generic dashboard language ("track your KPIs," "stay on top of tasks"). Every sentence should be specific to *this person's* actual situation.

---

## PHASE 2 — Build Spec: The MVP Interview

**Trigger phrase (or equivalent):** *"Interview me to identify what's needed for a version 1.0 of [niche command center]. I want it to be a Node.js app, running entirely locally with no database, just local JSON files. The app should be a Minimum Viable Product to get it running locally."*

### Interview Rules

- Ask **one question at a time**. Never stack questions.
- Each question builds on the last answer. Do not follow a rigid script — follow the thread.
- The goal is to understand: what data exists, how it currently lives, what gets entered manually vs. pulled automatically, and what the user will actually *do* every day in the app.
- Keep going until you can answer all items in the MVP Spec Checklist below.

### Core Interview Questions (adapt based on answers)

Start here, in this order, but deviate based on what you learn:

1. **The hero moment:** "When you picture yourself actually *using* this on a Tuesday morning — what's the first thing you want to see the moment it opens? What's the one number or status that, if it's green, means your day started well?"

2. **Data reality check:** "How do you currently track [the thing they named]? Spreadsheet, app, mental math, nothing at all?" *(Ask about each major income stream or data source separately if needed.)*

3. **What falls through the cracks:** "Outside of money — what actually *falls through the cracks* right now? What's the thing you occasionally realize you forgot, or the ball you've dropped more than once?"

4. **Personal vs. professional:** "Does personal tracking — health habits, personal goals — belong inside this command center, or do you want that completely separate?"

5. **Data ownership:** "For the data you'd enter manually — how often would you realistically update it? Daily, weekly, whenever you remember?"

6. **The one thing:** "If this app only did one thing perfectly in version 1.0, what would that one thing be?"

### MVP Spec Checklist

Before ending the interview, confirm you have answers for all of these:

- [ ] Hero metric (the top-of-screen number)
- [ ] All data modules (what sections exist)
- [ ] Data entry method for each module (manual entry, copy-paste from platform, auto-calculated)
- [ ] Update frequency per module
- [ ] Client/contact roster (if applicable) — fields needed
- [ ] Personal tracking requirements (yes/no and what)
- [ ] Any data that already exists elsewhere (reports, exports) that needs to be mirrored

### Step 3: Present the Full MVP Spec

Once the interview is complete, present the spec as a clean summary:

**Format:**
```
## [Niche Name] Command Center — MVP Spec

**What it is:** One sentence.

**Tech stack:** Node.js + Express server, local JSON files, browser-based UI (no install beyond Node.js)

**Modules:**
1. [Module Name] — [what it shows] — [data entry method]
2. ...

**JSON data files:**
- [filename].json — [what it stores]
- ...

**Daily workflow:** A 2-3 sentence description of how the user actually uses this each day

**Intentionally out of scope for v1.0:**
- [Thing 1]
- [Thing 2]
```

---

## PHASE 3 — Build

After the spec is approved by the user, build the Node.js application.

### Architecture

```
[app-name]/
├── server.js          ← Express server; handles all routes and data reads/writes
├── package.json       ← Dependencies (express only for MVP)
├── data/              ← All JSON files live here
│   ├── [module].json
│   └── ...
└── public/            ← The browser-facing app (served by Express)
    ├── index.html     ← Single page; all modules rendered here
    ├── style.css      ← Dashboard styling
    └── app.js         ← Frontend logic; calls the server API
```

### Technical Constraints

- **No database.** All data is read from and written to local JSON files via the Express server.
- **No authentication.** This runs locally; no login needed.
- **No external APIs for MVP.** All data is manually entered unless the user explicitly has a data export they want to import.
- **Single page.** Everything on one screen. No routing, no page navigation in v1.0.
- **Node.js + Express only.** No React, no Vue, no build tools. Keep the dependency footprint minimal so it actually runs.
- **Port 3000 by default.** User runs `node server.js`, opens `localhost:3000`.

### Data File Pattern

Every JSON data file follows one of two patterns:

**List of records** (for rosters, income entries, projects):
```json
[
  { "id": "unique-id", "field1": "value", "field2": "value", "createdAt": "ISO date" },
  ...
]
```

**Key-value config** (for goals, settings, thresholds):
```json
{
  "key": "value",
  "updatedAt": "ISO date"
}
```

### Server Route Pattern

For each data module, create 3 routes:

```javascript
// GET all records
app.get('/api/[module]', (req, res) => { ... })

// POST new record
app.post('/api/[module]', (req, res) => { ... })

// DELETE record by id
app.delete('/api/[module]/:id', (req, res) => { ... })
```

### UI Guidelines

- **Dark background preferred** — command centers look like command centers, not spreadsheets
- **Hero metric dominates the top** — large, high-contrast, immediately readable
- **Modules in a grid below** — 2-3 columns depending on content density
- **Minimal chrome** — no nav bars, no sidebars, no unnecessary UI. If it's not data, it shouldn't be there.
- **One-click data entry** — every module that accepts input should have an inline form, not a separate page

---

## SAVING THE SKILL

After building, save this skill file into the skill-stack repo (edited in place, per verify-before-versioning) as:

`productivity/niche-command-center-build.md`

And add the following trigger line to any relevant bundle files:

```
- "Build me a command center" / "Design my dashboard" / "niche command center build skill" → niche-command-center-build
```

---

## NOTES FOR FUTURE VERSIONS

Things intentionally out of scope for MVP that belong in v2:
- Multi-user access (for agency use cases)
- Data export to CSV
- Email/platform API integrations (auto-pull instead of manual entry)
- Mobile responsiveness
- Notifications or alerts
- Historical charts and trend views

The guiding principle for MVP: **it has to run the first day you install it, with no configuration and no data imports.** If it requires setup before it's useful, it won't get used.
