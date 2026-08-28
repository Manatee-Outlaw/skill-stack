---
name: algorithmic-art
description: Create interactive generative and algorithmic artwork — living systems, particle art, geometric patterns, flow fields, and procedural visuals rendered in the browser. Use when the user asks for generative art, algorithmic art, animated visuals, interactive art, or anything described as "living", "procedural", or "generative". Also use for creative coding requests involving p5.js, particles, or mathematical art.
metadata:
  tier: universal
  plugin: skill-creative
---

# Algorithmic Art

Create living, parametric artwork — visual systems that generate beauty through mathematics, behaviour, and emergence. Every piece is unique and interactive.

**Output:** A single self-contained HTML artifact with p5.js from CDN. Everything inline — no external files.

---

## Two-phase process: Philosophy first, then algorithm

### Phase 1 — Algorithmic philosophy

Before writing code, establish the computational aesthetic in 4-6 paragraphs:

- **The system name** (2-3 words: e.g. "Recursive Bloom", "Turbulent Fields", "Crystalline Growth")
- **The computational worldview** — what mathematical or physical behaviour drives this piece?
- **How parameters shape the experience** — what can the viewer control?
- **The emergent quality** — what arises from the algorithm that wasn't explicitly programmed?
- **Craftsmanship** — the algorithm must feel meticulously refined, the product of deep expertise; repeat this emphasis

The philosophy must stress: beauty emerging from process, parametric expression, living algorithms (not static images with randomness), and expert craftsmanship repeated throughout.

### Phase 2 — Express through code

With the philosophy established, build the artifact.

---

## Technical structure

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.7.0/p5.min.js"></script>
  <style>
    body { margin: 0; background: #141413; }
    canvas { display: block; }
    #controls { padding: 16px; font-family: sans-serif; color: #faf9f5; }
  </style>
</head>
<body>
  <div id="canvas-container"></div>
  <div id="controls">
    <!-- Parameter sliders here -->
  </div>
  <script>
    // All p5.js code inline
    // Always seed randomness for reproducibility
    let seed = 12345;
    
    function setup() {
      randomSeed(seed);
      noiseSeed(seed);
      // ...
    }
    
    function draw() {
      // ...
    }
  </script>
</body>
</html>
```

---

## Core principles

**Seeded randomness:** Always use `randomSeed()` and `noiseSeed()` so pieces are reproducible. Include a seed control so the viewer can explore variations.

**Parameters:** Design 4-8 adjustable parameters that emerge naturally from the philosophy. Each should meaningfully change the character of the piece — not just cosmetic tweaks.

**Performance:** Avoid redrawing the entire canvas each frame unless necessary. Use `noLoop()` for static pieces and re-render on parameter change.

**Uniqueness:** Every piece gets its own algorithm. Never reuse the same particle system or flow field structure — the philosophy drives a genuinely new approach each time.

---

## Types of algorithmic systems (pick what serves the philosophy)

- **Flow fields** — Perlin noise vector fields guiding particle movement
- **Recursive structures** — L-systems, fractal trees, subdivision patterns
- **Particle systems** — emergent behaviour from simple rules (flocking, gravity, attraction)
- **Cellular automata** — Game of Life variants, reaction-diffusion
- **Geometric constructions** — Voronoi, Delaunay, tiling systems
- **Wave interference** — Superimposed sine waves, Lissajous figures
- **Growth algorithms** — DLA (diffusion-limited aggregation), space colonisation

---

## Controls UI

Include a minimal control panel below the canvas:
- Seed input (text or number)
- 3-6 parameter sliders with labels and current value display
- Regenerate button
- Optional: save/export button

Keep the UI minimal and dark to not compete with the artwork.
