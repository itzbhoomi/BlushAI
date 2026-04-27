# Blush / Wobbly Frontend Design System Prompt

Create a premium iOS frontend for a feminine wellness app inspired by modern Apple-level craftsmanship, soft emotional design, and cozy calm minimalism.

The app should feel like:

* 🌸 emotionally safe
* 🌫 airy and soft
* 🧘 peaceful and slow
* ✨ elegant but cute
* 🐼 charming and companion-like

Use the attached wireframe only as structural inspiration. Improve it visually.

---

# Core Design Direction

Build the UI using a **Liquid Glass Pink Aesthetic**.

Think:

* Apple glassmorphism refined for 2026
* floating translucent layers
* warm blush tones
* subtle depth
* tactile softness
* no aggressive contrast
* emotionally soothing experience

The UI should feel like:

> a soft pink cloud made of glass panels

---

# Overall Visual Language

## Surfaces

Every card / panel / nav bar should feel:

* translucent
* frosted
* layered
* softly glowing
* floating above background

## Motion

Animations should be:

* slow
* fluid
* organic
* eased
* premium

Nothing should snap harshly.

---

# Color System (Monochromatic Pink Luxury)

## Background

Use subtle gradient:

Top: `#FFF8FA`
Bottom: `#FFF2F5`

Barely visible.

## Glass Surfaces

Use pink translucent overlays:

```css
rgba(255,228,236,0.55)
rgba(255,228,236,0.68)
```

## Borders

Soft luminous borders:

```css
rgba(255,255,255,0.40)
```

## Text

Primary: `#5C4550`
Secondary: `#8D7380`
Muted labels: `#B59AA6`

## Accent Pink

`#F39CB3`

## Success Soft

`#E7B7C7`

---

# Typography

Use elegant rounded modern fonts.

Preferred:

* SF Pro Rounded
* Inter Rounded
* Poppins
* Nunito

## Hierarchy

### Headings

* medium / semibold
* slightly larger
* spacious tracking

### Body

* regular
* breathable line-height

### Labels

* small
* subtle

Never dense text blocks.

---

# Glass Component System

Every reusable card should have:

```css
backdrop-filter: blur(18px);
border: 1px solid rgba(255,255,255,0.4);
border-radius: 24px;
box-shadow:
0 8px 30px rgba(243,156,179,0.10),
inset 0 1px 0 rgba(255,255,255,0.35);
background: rgba(255,228,236,0.58);
```

Feels like:

* milky frosted glass
* delicate depth
* premium softness

---

# Layout Rules

## Structure

Use masonry / organic grid layouts.

* cards of uneven heights
* generous spacing
* breathing room
* asymmetry allowed

Avoid rigid boring dashboard grids.

## Padding

Outer page padding: `20–24`

Card padding: `16–22`

Gap between cards: `14–18`

---

# Home Screen Structure

## Top Header

Left:

* Greeting based on time
* Username

Right:

* Tiny companion panda / icon
* Notification icon

## Main Dashboard

Use floating cards.

### Large Card

Cycle status / next period

### Medium Cards Row

Mood card + Journal card

### Full Width Card

Daily insight

### Optional Additional Cards

* hydration
* sleep
* trends
* reminders

---

# Navigation Bar

Floating pill navigation.

Detached from bottom edge.

Use stronger blur than cards.

```css
border-radius: 999px;
padding: 14px 20px;
background: rgba(255,240,245,0.72);
backdrop-filter: blur(24px);
```

Icons:

* thin
* elegant
* pink tint

Active icon:

* soft glow
* slight scale up
* gentle fill

---

# Card Styles

## Cycle Card

Should feel important but calm.

Include:

* next period countdown
* cycle day
* subtle progress ring / bar
* phase chip

## Mood Card

Cute and inviting.

Single CTA button:

**Check In 🌸**

After completed:

* mood emoji
* logged today
* tiny glow

## Journal Card

Soft notebook vibe.

Minimal icon + subtitle.

## Insight Card

Readable supportive paragraph.

No clutter.

---

# Mood Logging Screen

Minimal emotional experience.

## Layout

Top:

**How are you feeling today?**

Then vertical mood choices:

* 😊 Good
* 🙂 Okay
* 😐 Meh
* 😴 Tired
* 😣 Stressed

Each option in soft glass pill row.

After tap:

Generate beautiful AI summary card.

If already logged:

Show locked state with saved mood + summary.

---

# Journal Screen

Prompted reflection.

Use stack of soft cards with single-tap choices.

Examples:

* Did today go the way you expected?
* Did you feel at ease?
* Did you rest enough?

At bottom:

Text fields:

* Today’s core memory
* Manifestation for tomorrow

Save button only appears when edits happen.

---

# Animations

## Press

Scale to `0.97`

## Release

Spring back softly.

## Card Appear

Fade + slight upward float + blur sharpening.

## Navigation Switch

Crossfade with blur.

## Scroll

Subtle parallax layers.

---

# Illustration Style

Use tiny panda mascot occasionally.

Style:

* simple
* rounded
* kawaii
* tasteful
* not childish

Use sparingly.

---

# UX Feel Rules

The app must never feel:

* stressful
* loud
* clinical
* data-heavy
* corporate
* crowded

It should always feel:

* warm
* private
* feminine
* premium
* comforting

---

# Developer Implementation Notes

## If building in SwiftUI

Use:

* `.ultraThinMaterial`
* custom pink overlays
* shadow radius 20+
* `RoundedRectangle(cornerRadius: 24)`
* `matchedGeometryEffect`
* spring animations
* safe-area floating nav

## If building React Native / Flutter

Replicate Apple softness closely.

---

# Final Emotional Goal

When user opens the app, they should feel:

> Everything is okay.
> I can slow down here.
> This app understands me.

---

# Important

Do NOT make generic pink UI.

Need:

* depth
* softness
* layering
* premium Apple aesthetic
* cozy feminine emotion
* elegant restraint

Think:

**Apple Health + Pinterest softness + luxury skincare brand + calm diary**

Note: Do not modify or interfere with any AI/ML logic, data processing, or backend functionality. All changes must be strictly limited to the frontend (UI/UX) layer only.