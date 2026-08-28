---
name: legal-paralegal
description: >
  US paralegal skill for drafting, reviewing, and structuring legal documents —
  TOS, NDAs, service agreements, privacy notices, and data retention policies.
  Drawn from anthropics/claude-for-legal (Apache 2.0) and adapted for
  small to mid-size US business contexts. All output is DRAFT work product
  for attorney review before reliance or distribution.
sources:
  - https://github.com/anthropics/claude-for-legal (Apache 2.0, copyright 2026 Anthropic PBC)
  - https://github.com/cbrown1515/Public-Code-Counsel-Legal-Skills (MIT)
jurisdiction: United States (federal + California/CCPA-aware by default)
last_updated: 2026-05-27
metadata:
  tier: universal
  plugin: skill-enterprise
---

# US Paralegal Skill

## Core Principles

Every document produced using this skill is DRAFT work product. It is not legal advice,
not a legal conclusion, and not a substitute for a licensed attorney's review. The user
is responsible for having a qualified attorney verify, revise, and approve any document
before it is signed, distributed, or relied upon.

This skill is calibrated for:
- Small to mid-size US businesses and agencies
- Service-based businesses, professional services, and client programs
- Plain-language drafting that is enforceable without being unnecessarily intimidating
- California/CCPA-aware data handling by default (most protective US standard)

---

## Document Types This Skill Covers

### 1. Terms of Service (TOS) / Platform Agreements
For software platforms and SaaS-style services delivered to end users.
Key sections: acceptance of terms, service description, user obligations,
prohibited conduct, IP ownership, disclaimers, limitation of liability,
governing law, dispute resolution, modification clause.

### 2. Non-Disclosure Agreements (NDA)
One-way (discloser/recipient) or mutual. Key sections: definition of
confidential information, exclusions, obligations of recipient, term,
return/destruction of information, remedies, governing law.

### 3. Combined TOS + NDA / Program Participation Agreement
For programs where users are both receiving a service AND agreeing to
keep the agency's methods confidential. Most common in client programs,
professional services, and proprietary systems. Sections from both above,
plus: relationship definition, data collection disclosure, retention policy.

### 4. Privacy Notice / Data Disclosure
Standalone or embedded. Key sections: what is collected, why, how stored,
how long retained, who has access, user rights (CCPA/opt-out), contact.

### 5. Data Retention Policy
Internal or user-facing. Key sections: categories of data retained,
retention periods by category, legal basis for retention, deletion
triggers, security measures.

---

## Drafting Methodology (from anthropics/claude-for-legal)

### Step 1 — Identify the document type and key facts
Before drafting, confirm:
- Who are the parties? (company name, user/member description)
- What is the service or program? (describe in plain terms)
- What data is collected? (be specific — names, payment info, usage metrics, etc.)
- What is confidential? (methods, reports, tools, strategies)
- What jurisdiction governs? (default: state of company's formation/principal office)
- Is this a one-time signature or a living document with version history?

### Step 2 — Select the minimum viable sections
Do not over-draft. A document that reads like a Fortune 500 EULA for a small agency
creates distrust and reduces compliance. Include only what is necessary for the specific
risks present. Expand later if needed.

### Step 3 — Plain language first, legal accuracy second
Draft every clause in plain English. Then check that the plain-language version is
legally accurate for the jurisdiction. If a clause cannot be said plainly without
losing legal effect, add a plain-language summary after the clause in parentheses.

### Step 4 — Required disclaimers and enforceability flags
Every TOS must include:
- A clear acceptance mechanism (click-through, signature, or checkbox)
- A "you must be 18 or older" or age-appropriate statement
- A disclaimer of warranty (services provided "as is" where applicable)
- A limitation of liability clause
- A governing law and venue clause

Every NDA must include:
- A clear definition of "Confidential Information" (and what it excludes)
- A term/expiration clause
- A statement that breach may cause irreparable harm warranting injunctive relief

### Step 5 — Data collection language
For any document that involves collecting user data (applicable to any software platform):
- Disclose what is collected explicitly (do not use vague "information you provide")
- State the legal basis for collection (service delivery, legitimate interest, consent)
- State the retention period or the standard used to determine it
- Give the user a contact for data requests
- If in California or serving California users: include CCPA opt-out right reference
- Do not promise to never share data unless you are certain that is true

### Step 6 — Data encryption and security representations
Only represent what is true. If data is encrypted at rest on a server,
say so specifically. If it is not, do not say it is. Misrepresentation
in a TOS about data security creates significant liability.

Standard-safe language when encryption is implemented:
"Data stored on Agency servers is encrypted at rest using industry-standard
encryption. Access is limited to authorized Agency personnel."

Standard-safe language when encryption status is uncertain:
"The Agency implements reasonable technical and organizational measures to
protect your data. We cannot guarantee absolute security."

### Step 7 — Data retention
"Retained indefinitely" or "as long as legally permissible" is valid and enforceable
language, but only if you actually retain the data and have a process to respond to
deletion requests. Do not use this language if the data is routinely deleted.

Standard language for indefinite retention with deletion rights:
"Agency retains your data for as long as your account is active and thereafter
for as long as required by applicable law or permitted by applicable law.
You may request deletion of your data at any time by contacting [email].
Certain data may be retained beyond your request where required by law
or where the Agency has a legitimate ongoing business need."

---

## Section Templates

### Acceptance Clause
"By creating an account, logging in for the first time, or clicking 'I Accept,'
you agree to be bound by these Terms. If you do not agree, do not use the Service."

### Relationship Clause (agency services, not employment)
"Your participation in the [Program Name] does not create an employment relationship,
partnership, joint venture, or franchise between you and [Agency Name]. You are an
independent participant receiving a service."

### Confidentiality Clause (NDA-style, one-way)
"In the course of participating in the Program, you may receive access to non-public
information about [Agency Name]'s methods, tools, strategies, reports, and systems
('Confidential Information'). You agree not to disclose, share, reproduce, or use
Confidential Information for any purpose outside your participation in the Program,
during and after the term of your membership. Confidential Information does not
include information that (a) is or becomes publicly available through no fault of
yours, (b) you received independently from a third party without restriction, or
(c) you can demonstrate you knew prior to disclosure."

### Data Collection Clause
"By using the Service, you consent to the collection and use of the following data:
[list specific data types]. This data is used to [describe how the Service uses
the data]. Data is stored on Agency servers
[encrypted at rest / with reasonable security measures]. For questions about
your data, contact [email]."

### Retention Clause
"Agency retains your data for the duration of your account and thereafter for
as long as permitted by applicable law. You may request a copy of your data
or deletion of your data at any time by contacting [email]. Requests will be
processed within 30 days."

### Governing Law Clause
"These Terms are governed by the laws of the State of [State], without regard
to conflict of law principles. Any dispute shall be resolved in the courts of
[County, State], and you consent to personal jurisdiction there."

### Modification Clause
"Agency may update these Terms at any time. You will be notified of material
changes via [platform notification / email]. Continued use of the Service
after notification constitutes acceptance of the updated Terms."

---

## Red Flags to Flag for Attorney Review

Always flag the following for the reviewing attorney:
- Any clause that limits liability to $0 or a trivial amount (may be unenforceable)
- Any arbitration clause (state-specific enforceability varies significantly)
- Any clause that waives the right to a class action (may be challenged)
- Any representation about data security that overstates actual practices
- Any clause that claims ownership of user-generated content without clear scope
- Any non-compete or non-solicitation clause (heavily regulated by state)
- 1099 / payment obligations (confirm with tax counsel)

---

## Output Format

When drafting a document, produce:
1. The full draft document with section headers
2. A brief "Attorney Review Notes" section at the end listing:
   - Clauses flagged for review
   - Jurisdiction assumptions made
   - Information that was assumed or invented (needs verification)
   - Any state-specific supplements that may be needed

Label the top of every document:
"DRAFT — FOR ATTORNEY REVIEW — NOT LEGAL ADVICE — [DATE]"
