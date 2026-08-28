---
name: icon-libraries
description: >
  Pick and use icons correctly in any artifact, component, page or design — Lucide
  (1,780 icons) and Phosphor (1,543 icons × 6 weights). Use whenever an interface needs
  an icon, when choosing between icon sets, when an icon renders blank, or when you are
  about to write an icon name you are not certain exists. Covers which library is
  actually available in which environment, the kebab-to-PascalCase conversion that
  silently breaks imports, Phosphor's weight system, and how to verify a name against
  the bundled reference lists instead of guessing. Trigger phrases: "add an icon",
  "what icon should I use", "the icon isn't showing", "lucide", "phosphor", "icon set".
metadata:
  tier: universal
  plugin: skill-creative
---

# Icon Libraries

## Rule zero: never invent an icon name

A wrong icon name does not error. It renders **nothing**, or crashes the component with an
undefined import. Both look like a styling problem and waste real time.

Two complete name lists ship with this skill:

- `references/lucide.txt` — 1,780 names
- `references/phosphor.txt` — 1,543 base names

**If you are not certain a name exists, grep the reference file before writing it.** These
lists are generated from the upstream repositories and are complete — an absent name means
the icon genuinely does not exist, so pick a different one rather than hoping.

Do not load a reference file into context just to browse. Search it for the specific name
or concept you need.

## Which library is available where — this decides most choices

| Environment | Lucide | Phosphor |
|---|---|---|
| **Claude artifacts (React)** | ✅ `lucide-react` is pre-installed | ❌ not available — needs a cdnjs import |
| **Claude artifacts (HTML)** | via cdnjs | via cdnjs |
| **A project you control** | `npm i lucide-react` | `npm i @phosphor-icons/react` |

**In a Claude React artifact, default to Lucide.** It is already there:

```jsx
import { Camera, ArrowRight, Search } from "lucide-react";

<Camera size={20} strokeWidth={1.5} />
```

Phosphor in an artifact means a cdnjs script tag — cdnjs is the only external host
artifacts permit. That is extra fragility for an aesthetic preference, so only reach for it
when Phosphor's weights genuinely carry the design.

## The conversion that silently breaks imports

**The reference list is kebab-case. React imports are PascalCase.**

```
arrow-down       →  ArrowDown
chevron-right    →  ChevronRight
a-arrow-down     →  AArrowDown
message-circle   →  MessageCircle
```

Every hyphen disappears and the following letter capitalises. Miss this and the import is
`undefined` at runtime, which surfaces as a blank space rather than an error.

Short and unusual names to be careful with: `ad`, `hd`, `pi`, `tv`, `x` → `Ad`, `Hd`, `Pi`,
`Tv`, `X`. No Lucide name begins with a digit, so that edge case does not arise.

For raw SVG or HTML, use the kebab name as-is — it is the filename.

## Phosphor weights

Phosphor ships every icon in six weights. This is its distinguishing feature and the main
reason to choose it.

`thin` · `light` · `regular` (default) · `bold` · `fill` · `duotone`

```jsx
import { Heart } from "@phosphor-icons/react";

<Heart weight="fill" size={24} />
```

`references/phosphor.txt` lists **base names only**. Every name in it exists in all six
weights — do not append the weight to the name.

## Choosing between them

**Lucide** — geometric, uniform 2px stroke, one weight, descends from Feather. Neutral and
utilitarian; disappears into an interface, which is usually what an icon should do. The
right default for dashboards, tools, admin surfaces, and anything dense.

**Phosphor** — softer curves, more personality, and the six weights let icon emphasis carry
hierarchy the way type weight does. Better for marketing pages, consumer products, and
anywhere the icons are part of the character rather than the plumbing.

**Never mix the two in one interface.** Different stroke logic and corner treatment read as
sloppiness even to people who cannot name why. Pick one per product.

## Sizing and alignment

- Match icon size to the type it sits beside: 16px with small text, 20px with body, 24px standalone.
- Lucide's `strokeWidth` defaults to 2. Drop to 1.5 at 20px and above, or icons look heavy next to text.
- Optical alignment beats mathematical: an icon centred by geometry often sits a pixel low
  next to a cap-height letter.
- Set `aria-hidden="true"` on decorative icons. An icon carrying meaning alone needs an
  accessible label.

## When an icon renders blank

Work down this list — it is ordered by how often each is the cause:

1. **Name does not exist.** Grep the reference file. This is the usual answer.
2. **Case is wrong.** `arrowDown` and `Arrowdown` both fail; it is `ArrowDown`.
3. **Not imported**, or imported from the wrong package.
4. **Weight appended to a Phosphor name** — `heart-fill` is not a name; `Heart` with
   `weight="fill"` is.
5. **Size or colour collapsed** — zero size, or the icon painted in the background colour.

## Keeping the reference lists current

Both libraries add icons. Regenerate from upstream clones:

```bash
ls refs-lucide/icons/*.svg | sed 's|.*/||;s|\.svg$||' | sort -u > references/lucide.txt

find refs-phosphor -name "*.svg" | sed 's|.*/||;s|\.svg$||;s|-thin$||;s|-light$||;s|-bold$||;s|-fill$||;s|-duotone$||' | sort -u > references/phosphor.txt
```

Counts at last generation: **Lucide 1,780**, **Phosphor 1,543** (× 6 weights = 9,110 files).
If a regeneration returns fewer names than this, the clone is shallow or incomplete — stop
and fix it. **A truncated list is worse than no list**, because a missing name reads as
"this icon does not exist" and sends you looking for a substitute that was never needed.

## Related

- **impeccable** (external plugin) — design fluency and anti-pattern rules for frontend
  work. It governs whether the interface is good; this skill governs whether the icon
  exists and is used correctly.
- **theme-factory** — colour and type. Icons inherit `currentColor`, so theme first.
