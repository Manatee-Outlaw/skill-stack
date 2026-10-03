---
name: find-existing-solution
description: >
  Before building anything that reaches OUTSIDE the project — an external API, data
  feed, protocol, hardware/service integration, auth, payments, scraping —
  deliberately search for existing third-party solutions instead of building from
  scratch or diving into official-API rabbit holes. Use when the user says "before we
  build X", "how do we get data from X", "is there a library/service for", "build vs
  buy", "what's the best way to integrate X", or is about to hand-roll an external
  integration. The EulerStream lesson made repeatable.
metadata:
  tier: universal
  produces_findings: false
  plugin: skill-engineering
---


# find-existing-solution

The lesson behind this skill: weeks of production work went into TikTok's
official-API rules trying to ingest TikTok Live data — when **EulerStream** (a
third-party signing service) had already solved it, and `tiktok-live-connector`
wrapped it. Nobody knew it existed. This skill is the repeatable search that
would have found it in an hour.

## When this fires

Any time we're about to build something that **crosses the project boundary**:
external API integration, a live data feed, a protocol implementation, a
hardware/device integration, auth/SSO, payments, scraping, transcoding, ML
inference, notifications, etc. Building a purely-internal feature does NOT need
this.

## Step 1 — Reframe the problem (the move that finds hidden solutions)

Do NOT ask "how do I call X's official API?" — that's the rabbit hole. Ask:
**"Who ELSE already needs this exact capability or data, and how did they get
it?"** Streamers need TikTok Live events → tools that serve streamers already
solved it → EulerStream / tiktok-live-connector. This reframe is the whole game.
(For a wider reframe, invoke the **adhd** skill: how would a lazy dev, a
competitor, or a 10-year-old get this? Remove the load-bearing assumption that
you must use the official path.)

## Step 2 — Search breadth-first, multiple sources

Cast wide before committing. In rough priority:

1. **Your own index first** — if the team keeps a knowledge vault
   (`<knowledge-vault>/library/dependencies.md` or similar), it is the running index of
   third-party solutions already found. Check it before searching the internet.
2. **Package registries** — npm, PyPI, crates.io, NuGet, Maven, RubyGems.
   Search the capability, not the vendor.
3. **GitHub** — topic search, stars, and especially **"awesome-<domain>"** curated
   lists. Read recent issues to gauge health.
4. **What do incumbents/competitors use?** — the highest-signal source. If a
   competitor's app already does this, **reverse-engineer it** (the
   `study-codebase` skill) to see the dependency/service they use. This is how we
   found EulerStream. Studying competitors is a first-class discovery method.
5. **Domain communities** — the specific subreddit / Discord / forum for the
   niche (VR, streaming, etc.) — practitioners name the tool everyone uses.
6. **API marketplaces / aggregators** — RapidAPI and "X as a service" searches —
   for hosted solutions to data/capability problems.

## Step 3 — Official vs unofficial

Recognize that the **official API is often the rabbit hole** and a third-party
service or community lib is the real answer (EulerStream vs. TikTok's official
API; `tiktok-live-connector` reverse-engineering webcast). Don't dismiss
unofficial/community solutions — weigh them (Step 4). Conversely, note when the
official path genuinely is best (Twitch EventSub, YouTube Data API).

## Step 4 — Evaluate candidates

For each real candidate: **maintained?** (recent commits/releases), **license**
(compatible with our use/resale?), **official vs unofficial + stability risk**
(will it break when the upstream changes?), **dependency ownership** — can we own
the account/key and make the endpoint config-driven, or is it a shared/hardcoded
key that becomes a dead-man's switch? (in one measured case a desktop tool depended on
its vendor's shared key and licence server; when the server died, so did the tool),
**cost**, and **footprint**. Recommend, don't just list.

## Step 5 — Record it (so the search compounds)

Write the finding into the team's dependency index (`<knowledge-vault>/library/dependencies.md`,
or wherever the project keeps it): adopt/own/avoid + the gotcha. Next time this capability comes up, it's already known — the vault
becomes a compounding index of third-party solutions, so we never re-lose an
EulerStream.

## Default-habit mode (lightweight)

Even without invoking this skill in full, run a **quick** version of Steps 1–2 by
default before committing to build any external integration, and surface what you
find. Reserve the full
skill for consequential build-vs-buy decisions.
