---
name: canvas-design
description: Create original, high-quality visual artwork and design pieces — posters, covers, infographics, marketing visuals, or any static designed image. Use when the user asks to create a poster, piece of art, design, visual, cover, or any static designed image. Always use this skill for visual design requests, even if the user just says "make something that looks good" or "design this for me".
metadata:
  tier: universal
  plugin: skill-creative
---

# Canvas Design

Create original, high-quality visual art and design. Never copy existing artists' styles directly — always create something original.

**Output format:** An SVG or HTML artifact rendered inline, or a described composition the user can recreate.

---

## Two-phase process: Philosophy first, then execution

### Phase 1 — Define the design philosophy

Before creating anything, establish the aesthetic direction. Write a design philosophy (4-6 paragraphs) that defines:

- **The movement name** (2-3 words: e.g. "Chromatic Silence", "Brutalist Joy", "Geometric Warmth")
- **The visual worldview** — what does this aesthetic believe about composition, space, colour?
- **How text is treated** — minimal and integrated as a visual element, never lengthy copy
- **Spatial expression** — how do space, form, and colour communicate rather than words?
- **Craftsmanship standard** — this piece should look like it took countless hours; meticulous, intentional, expert

The philosophy must emphasise: visual expression over explanation, minimal text, spatial communication, and that the final work appears masterfully crafted.

**Example philosophy names and their character:**
- *Geometric Silence* — Pure order and restraint; grid-based precision, dramatic negative space; Swiss formalism meets Brutalist honesty
- *Chromatic Language* — Colour as the primary information system; geometric precision; Josef Albers meets data visualisation
- *Concrete Poetry* — Monumental form and bold geometry; massive colour blocks; Brutalist spatial divisions; Polish poster energy

### Phase 2 — Express the philosophy

With the philosophy established, create the design. Rules:

**Text:** Always minimal and visual-first. Text is a design element — spare, essential, integrated. Font choice should be design-forward. Nothing overlaps, nothing falls off canvas, every element has breathing room.

**Composition:** Ideas communicate through space, form, colour — not paragraphs. Every element placed with precision.

**Quality bar:** Sophisticated is non-negotiable. The result should look like it came from someone at the absolute top of their field.

---

## Creating the artifact

For Claude.ai, produce the design as:
1. **SVG** — for geometric, typography-forward, or flat compositions
2. **HTML with inline CSS** — for richer compositions needing gradients, layers, or animation
3. **React artifact** — for interactive or animated pieces

All in a single self-contained file. No external assets except system fonts or Google Fonts via CDN link.

---

## Design principles

- **Spatial hierarchy** — use size, weight, and position to guide the eye without labels
- **Restraint** — every element must earn its place; remove rather than add when uncertain
- **Contrast** — strong contrast between elements creates visual tension and interest
- **Proportion** — relationships between elements should feel deliberate and balanced
- **Consistency** — a limited palette and font set applied with precision beats variety applied carelessly

---

## When the user provides content to design

If the user gives you text, a concept, or a theme:
1. Identify the core visual idea (not the literal words)
2. Choose a philosophy that serves it
3. Translate the content into the minimum necessary visual elements
4. Let space and composition carry the meaning

Never lay out content like a Word document. If it looks like a brochure, start over.
