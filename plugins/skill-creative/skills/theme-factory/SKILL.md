---
name: theme-factory
description: Apply a consistent, professional visual theme — colour palette, typography, and component styling — to any artifact, document, slide deck, or web page. Use when the user wants to style something, asks for a visual theme, wants things to "look consistent", or is building anything that needs a coherent visual identity. Also use when applying a theme to a presentation or report.
metadata:
  tier: universal
  plugin: skill-creative
---

# Theme Factory

Apply a complete, professional visual theme to any artifact. Each theme includes a carefully matched colour palette, font pairing, and component style.

---

## Step 1 — Show available themes

When this skill is invoked, present the following 10 themes and ask the user to choose one — OR offer to generate a custom theme based on their description.

| # | Theme | Character | Primary Colour | Font Pairing |
|---|---|---|---|---|
| 1 | **Ocean Depths** | Professional, calm, trustworthy | #1a4a7a (deep navy) | Libre Baskerville + Source Sans Pro |
| 2 | **Ember** | Bold, energetic, warm | #c0392b (deep red) | Montserrat + Merriweather |
| 3 | **Forest** | Natural, grounded, sustainable | #2d6a4f (forest green) | Lora + Open Sans |
| 4 | **Obsidian** | Sleek, premium, modern | #1a1a2e (near-black) | Raleway + IBM Plex Mono |
| 5 | **Dawn** | Soft, optimistic, approachable | #e8905a (warm coral) | Playfair Display + Nunito |
| 6 | **Arctic** | Clean, precise, minimal | #4a9eda (sky blue) | Inter + Inter |
| 7 | **Aubergine** | Creative, distinctive, luxe | #6c3483 (deep purple) | Cormorant Garamond + Karla |
| 8 | **Sandstone** | Warm, sophisticated, editorial | #c19a6b (warm tan) | EB Garamond + Fira Sans |
| 9 | **Void** | Dark-mode, dramatic, technical | #0d1117 (near-black) | JetBrains Mono + Inter |
| 10 | **Sage** | Calm, balanced, thoughtful | #7d9b76 (muted sage) | Spectral + Mulish |

---

## Step 2 — Apply the theme

Once a theme is chosen, apply it consistently across the artifact using these rules:

### Colour application
- **Primary colour:** Headings, key accents, buttons, highlighted elements
- **Background:** Light neutral (or dark if Void/Obsidian theme)
- **Body text:** High-contrast on background (near-black on light, near-white on dark)
- **Borders/dividers:** 15-20% opacity version of primary colour
- **Success/Warning/Error:** Standard greens, ambers, reds unless the theme overrides them

### Typography application
- **Display font:** All headings H1–H3
- **Body font:** All body text, labels, captions
- **Size hierarchy:** H1: 36–44pt, H2: 24–32pt, H3: 18–22pt, Body: 14–16pt, Caption: 11–12pt
- **Weight:** Headings bold/semibold, body regular, never bold in body copy
- **Line height:** 1.5–1.7 for body, 1.2–1.3 for headings

### Spacing & layout
- Consistent padding: 24–32px for sections, 16px for components
- Clear visual hierarchy through size and weight, not colour alone
- Ample white space — designs should breathe

---

## Generating a custom theme

If the user describes a feeling, brand, or aesthetic instead of picking from the list, generate a custom theme:

1. Ask: "What feeling or impression should this convey? (e.g. trustworthy, playful, sophisticated, technical)"
2. Optionally ask: "Are there any existing colours or fonts you want to build from?"
3. Generate a complete theme specification with the same structure as above
4. Apply it

---

## Applying to specific artifact types

**Slides / presentations:** Apply theme to title slide, section headers, content slides, and any charts. Consistent slide background, title font size, and accent colour throughout.

**Documents / reports:** Header colour bar or accent line, consistent heading styles, pull quotes in primary colour, consistent table styling.

**Web pages / HTML artifacts:** CSS custom properties for all theme values at the top of the file, applied consistently to all elements.

**Data visualisations:** Chart colours derived from the theme palette — primary for main series, lighter tints for secondary series.
