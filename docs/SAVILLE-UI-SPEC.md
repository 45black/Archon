# Archon UI Specification — Saville Edition

**Version:** 1.0
**Date:** January 2026
**Status:** Production
**Author:** 45Black Limited

---

## Executive Summary

In January 2026, Archon's UI was completely redesigned from a Tron-inspired glassmorphism aesthetic to the **Saville Edition**, a design system rooted in the visual language of Peter Saville's iconic work for Factory Records and The Haçienda. This specification documents the design tokens, principles, and implementation patterns that define Archon's visual identity.

**Key Transformation:**
- **Before:** Glassmorphism, neon glows, translucent surfaces, cyberpunk aesthetic
- **After:** Solid containers, geometric precision, IBM Plex typography, colour as information

**Design Philosophy:** Typography as architecture. Colour as information, not decoration. Geometric precision meets emotional resonance.

---

## Design Heritage

### Peter Saville / Factory Records / Haçienda

The Saville Edition draws inspiration from:

1. **Factory Records Album Covers** - Geometric precision, restrained colour palettes, typography as the primary visual element
2. **FAC Numbers** - Catalogue numbering system that treated design as systematized, auditable, and precise
3. **Haçienda Branding** - Bold colour bars, architectural forms, industrial materials meeting refined aesthetics
4. **Typography Philosophy** - Helvetica and Futura used as structural elements, not decorative flourishes

**Core Principle:** Design should be serious about craft, not about itself. Functional beauty over ornamental excess.

---

## Visual Principles

### 1. Solid Planes, Not Blur
- Containers use solid backgrounds with defined borders
- No glassmorphism, frosted glass, or backdrop filters
- Clear visual hierarchy through elevation and shadow

### 2. Subtle Borders, Not Neon
- 1px borders with low-contrast colors
- Border colors: `rgba(255,255,255,0.1)` (dark mode) or `rgba(0,0,0,0.1)` (light mode)
- No glowing outlines or animated border effects

### 3. Geometric Precision
- Clean grids and aligned elements
- 8px base spacing unit for mathematical consistency
- Minimal border radius (2-8px max, often 0px for pure geometry)

### 4. Typography as Architecture
- IBM Plex Sans/Mono as structural foundation
- Type scale based on 1.25 modular ratio
- Letter spacing and line height treated as design elements
- Code/data displayed in monospace for clarity

### 5. Colour as Information, Not Decoration
- Palette conveys semantic meaning (success, warning, error, info)
- Primary Saville palette used for brand identity and key actions
- Away Strip palette provides secondary accents
- No arbitrary colour choices

---

## Colour Palette

### Saville Signature Palette (Primary / Home Strip)

**Order matters** - this is the Code Bar sequence:

| Colour | Hex | RGB | Meaning |
|--------|-----|-----|---------|
| **Forest Green** | `#4A7C59` | `74, 124, 89` | Growth, sustainability, success |
| **Deep Teal** | `#2E8B8B` | `46, 139, 139` | Trust, professionalism, stability |
| **Saville Blue** | `#1565C0` | `21, 101, 192` | Primary brand, authority, expertise |
| **Royal Purple** | `#7B1FA2` | `123, 31, 162` | Innovation, creativity, distinction |
| **Burnt Coral** | `#E65100` | `230, 81, 0` | Energy, action, urgency |
| **Warm Orange** | `#F57C00` | `245, 124, 0` | Optimism, accessibility, warmth |

**Usage:**
- **Saville Blue** is the primary interactive colour (buttons, links, focus states)
- **Forest Green** for success states and positive feedback
- **Burnt Coral** for errors and critical alerts
- **Deep Teal** for informational messages

### Away Strip Palette (Secondary)

| Colour | Hex | RGB | Meaning |
|--------|-----|-----|---------|
| **Mist Grey** | `#E0E0E0` | `224, 224, 224` | Subtle backgrounds, disabled states |
| **Slate Blue** | `#5C6BC0` | `92, 107, 192` | Secondary accent, links |
| **Dusty Rose** | `#D48CA1` | `212, 140, 161` | Soft accent, notifications |
| **Sage Green** | `#81C784` | `129, 199, 132` | Success states, positive feedback |
| **Soft Gold** | `#FFD54F` | `255, 213, 79` | Haçienda Yellow, warnings, highlights |
| **Charcoal** | `#424242` | `66, 66, 66` | Dark text on light backgrounds |

**Usage:**
- **Sage Green** for success confirmations and completed states
- **Soft Gold** for warnings and attention-requiring items
- **Slate Blue** for secondary actions and navigation elements
- **Dusty Rose** for soft notifications and tertiary accents

### Background System

**Dark Mode (Primary):**
- Primary: `#1A1A1A`
- Secondary: `#2D2D2D`
- Elevated: `#3D3D3D`
- Overlay: `rgba(0, 0, 0, 0.7)`

**Light Mode:**
- Primary: `#FAFAFA`
- Secondary: `#F5F5F5`
- Elevated: `#FFFFFF`
- Accent: `#FFF8F0` (warm tint for highlights)

**Archon is dark-first** - dark mode is the default and primary design target.

### Semantic Colours

**Interactive:**
- Primary: `var(--saville-blue)` → `#1565C0`
- Primary Hover: `#1976D2`
- Primary Active: `#0D47A1`

**States:**
- Success: `var(--away-sage)` → `#81C784`
- Warning: `var(--away-gold)` → `#FFD54F`
- Error: `var(--saville-coral)` → `#E65100`
- Info: `var(--saville-teal)` → `#2E8B8B`

**Text (Dark Mode):**
- Primary: `#FFFFFF`
- Secondary: `rgba(255, 255, 255, 0.7)`
- Muted: `rgba(255, 255, 255, 0.5)`

**Text (Light Mode):**
- Primary: `#424242` (Charcoal)
- Secondary: `#757575`
- Muted: `#9E9E9E`

---

## Typography

### Font Families

**Primary:** IBM Plex Sans
**Monospace:** IBM Plex Mono

**Rationale:** IBM Plex echoes Saville's love of Helvetica and Futura with a contemporary edge. Excellent multilingual support and comprehensive weights. Open source and optimized for digital interfaces.

**Stack:**
```css
--font-sans: 'IBM Plex Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'IBM Plex Mono', 'SF Mono', 'Fira Code', monospace;
```

### Font Weights

| Weight | Value | Usage |
|--------|-------|-------|
| Light | 300 | Large headings, subtle emphasis |
| Regular | 400 | Body text, default weight |
| Medium | 500 | Subheadings, UI labels |
| SemiBold | 600 | Headings, strong emphasis |
| Bold | 700 | Alerts, critical information |

**Default:** Regular (400) for body, SemiBold (600) for headings.

### Type Scale

Based on 1.25 modular ratio:

| Name | Size | Pixels | Usage |
|------|------|--------|-------|
| xs | 0.75rem | 12px | Labels, metadata, FAC numbers |
| sm | 0.875rem | 14px | Secondary text, captions |
| base | 1rem | 16px | Body text, default |
| lg | 1.125rem | 18px | Emphasized body |
| xl | 1.25rem | 20px | Small headings |
| 2xl | 1.5rem | 24px | Section headings |
| 3xl | 1.875rem | 30px | Page headings |
| 4xl | 2.25rem | 36px | Hero text |
| 5xl | 3rem | 48px | Display text |

### Line Heights

| Name | Value | Usage |
|------|-------|-------|
| none | 1 | Headings with tight spacing |
| tight | 1.25 | Large headings |
| snug | 1.375 | Subheadings |
| normal | 1.5 | Body text (default) |
| relaxed | 1.625 | Long-form content |
| loose | 2 | Spacious layouts |

### Letter Spacing

| Name | Value | Usage |
|------|-------|-------|
| tighter | -0.05em | Large display text |
| tight | -0.025em | Headings |
| normal | 0 | Body text |
| wide | 0.025em | All-caps labels |
| wider | 0.05em | Metadata, tags |
| widest | 0.1em | FAC numbers, IDs |

---

## Spacing System

**Base Unit:** 8px

Follows an 8-point grid for mathematical consistency and alignment precision.

| Token | Rem | Pixels | Usage |
|-------|-----|--------|-------|
| space-0 | 0 | 0 | No spacing |
| space-1 | 0.25rem | 4px | Tight spacing, icon gaps |
| space-2 | 0.5rem | 8px | Base unit, minimal padding |
| space-3 | 0.75rem | 12px | Input padding, small gaps |
| space-4 | 1rem | 16px | Standard padding, button padding |
| space-5 | 1.25rem | 20px | Card padding (small) |
| space-6 | 1.5rem | 24px | Card padding (standard) |
| space-8 | 2rem | 32px | Section spacing |
| space-10 | 2.5rem | 40px | Large section spacing |
| space-12 | 3rem | 48px | Page margins |
| space-16 | 4rem | 64px | Large page margins |
| space-20 | 5rem | 80px | Spacious layouts |
| space-24 | 6rem | 96px | Hero sections |

**Usage Guideline:** Prefer multiples of the base unit (8px). Avoid arbitrary spacing values.

---

## Borders

### Border Widths

| Token | Value | Usage |
|-------|-------|-------|
| border-0 | 0 | No border |
| border-1 | 1px | Standard borders (default) |
| border-2 | 2px | Emphasized borders |
| border-4 | 4px | Strong visual separation |

### Border Radius

Geometric, not rounded. Minimal radius preserves architectural precision.

| Token | Value | Usage |
|-------|-------|-------|
| radius-none | 0 | Pure geometric shapes |
| radius-sm | 2px | Subtle softening |
| radius-md | 4px | Standard UI elements |
| radius-lg | 6px | Cards, panels |
| radius-xl | 8px | Modals, large containers |

**Philosophy:** Prefer sharp corners (`radius-none`) for data displays, code blocks, and architectural elements. Use minimal radius (2-6px) for interactive elements only.

### Border Colours

**Dark Mode:**
- Default: `rgba(255, 255, 255, 0.1)`
- Strong: `rgba(255, 255, 255, 0.2)`

**Light Mode:**
- Default: `rgba(0, 0, 0, 0.1)`
- Strong: `rgba(0, 0, 0, 0.2)`

---

## Shadows

Subtle elevation, not neon glows. Shadows indicate depth hierarchy, not decoration.

### Dark Mode Shadows

| Token | Value | Usage |
|-------|-------|-------|
| shadow-sm | `0 1px 2px rgba(0, 0, 0, 0.3)` | Buttons, inputs |
| shadow-md | `0 2px 4px rgba(0, 0, 0, 0.3)` | Cards, dropdowns |
| shadow-lg | `0 4px 8px rgba(0, 0, 0, 0.3)` | Modals, overlays |
| shadow-xl | `0 8px 16px rgba(0, 0, 0, 0.3)` | Popovers, tooltips |

### Light Mode Shadows

| Token | Value | Usage |
|-------|-------|-------|
| shadow-sm | `0 1px 2px rgba(0, 0, 0, 0.1)` | Buttons, inputs |
| shadow-md | `0 2px 4px rgba(0, 0, 0, 0.1)` | Cards, dropdowns |
| shadow-lg | `0 4px 8px rgba(0, 0, 0, 0.1)` | Modals, overlays |
| shadow-xl | `0 8px 16px rgba(0, 0, 0, 0.1)` | Popovers, tooltips |

### Focus Ring

- **Ring:** `0 0 0 2px var(--saville-blue)` - Saville Blue focus indicator
- **Offset:** `0 0 0 4px var(--bg-dark-primary)` - Background separation

**Accessibility:** Focus states must be clearly visible. Never remove focus rings without replacement.

---

## Animation & Transitions

Precise micro-interactions, not glow pulses or dramatic effects.

### Durations

| Token | Value | Usage |
|-------|-------|-------|
| duration-instant | 0ms | No animation |
| duration-fast | 100ms | Hover states |
| duration-normal | 200ms | Standard transitions |
| duration-slow | 300ms | Modal appearance |
| duration-slower | 500ms | Page transitions |

### Easing

| Token | Curve | Usage |
|-------|-------|-------|
| ease-linear | `linear` | Progress bars, loaders |
| ease-in | `cubic-bezier(0.4, 0, 1, 1)` | Exit animations |
| ease-out | `cubic-bezier(0, 0, 0.2, 1)` | Enter animations |
| ease-in-out | `cubic-bezier(0.4, 0, 0.2, 1)` | State changes |

### Standard Transitions

```css
--transition-colors: color 200ms ease-in-out,
                     background-color 200ms ease-in-out,
                     border-color 200ms ease-in-out;
--transition-transform: transform 200ms ease-out;
--transition-opacity: opacity 200ms ease-in-out;
--transition-all: all 200ms ease-in-out;
```

**Usage:** Apply transitions to interactive elements (buttons, links, cards) for smooth feedback.

---

## Component Tokens

### Buttons

| Property | Value | Description |
|----------|-------|-------------|
| Height (Small) | 2rem (32px) | Compact buttons |
| Height (Medium) | 2.5rem (40px) | Standard buttons |
| Height (Large) | 3rem (48px) | Prominent CTAs |
| Padding X | var(--space-4) (16px) | Horizontal padding |
| Border Radius | var(--radius-md) (4px) | Subtle rounding |

**States:**
- Default: Saville Blue background, white text
- Hover: Darker blue (`#1976D2`)
- Active: Darkest blue (`#0D47A1`)
- Disabled: Mist Grey background, reduced opacity

### Cards

| Property | Value | Description |
|----------|-------|-------------|
| Padding | var(--space-6) (24px) | Interior spacing |
| Border Radius | var(--radius-lg) (6px) | Soft corners |
| Border | 1px solid rgba(255,255,255,0.1) | Subtle definition |
| Background | var(--bg-dark-secondary) | Elevated surface |
| Shadow | var(--shadow-md) | Depth indication |

**Variants:**
- **Default Card:** Standard elevation and padding
- **Interactive Card:** Hover state with subtle transform or border color change
- **Elevated Card:** Higher z-index, larger shadow for modals/popovers

### Inputs

| Property | Value | Description |
|----------|-------|-------------|
| Height | 2.5rem (40px) | Standard input height |
| Padding X | var(--space-3) (12px) | Horizontal padding |
| Border Radius | var(--radius-md) (4px) | Subtle rounding |
| Border | 1px solid rgba(255,255,255,0.2) | Stronger border for visibility |
| Background | var(--bg-dark-elevated) | Slightly elevated |

**States:**
- Focus: Saville Blue ring, stronger border
- Error: Burnt Coral border
- Disabled: Mist Grey background, reduced opacity

### Navigation

| Property | Value | Description |
|----------|-------|-------------|
| Nav Height | 4rem (64px) | Top navigation bar |
| Sidebar Width | 16rem (256px) | Expanded sidebar |
| Sidebar Collapsed | 4rem (64px) | Collapsed to icons |

---

## Z-Index Scale

Systematic layering for predictable stacking contexts:

| Token | Value | Usage |
|-------|-------|-------|
| z-base | 0 | Default layer |
| z-dropdown | 100 | Dropdown menus |
| z-sticky | 200 | Sticky headers |
| z-fixed | 300 | Fixed navigation |
| z-modal-backdrop | 400 | Modal backgrounds |
| z-modal | 500 | Modal dialogs |
| z-popover | 600 | Popovers, tooltips |
| z-tooltip | 700 | Highest priority tooltips |

**Usage:** Always use tokens, never arbitrary z-index values.

---

## Code Bar Feature

### Purpose

Optional branding element for marketing, splash screens, or showcase moments. Inspired by Factory Records' use of coloured bars and blocks in album artwork.

### Visual Design

A thin horizontal gradient bar displaying the six Saville Signature colours in sequence:

```css
.code-bar {
  height: 4px;
  background: linear-gradient(
    90deg,
    var(--saville-green) 0%,
    var(--saville-green) 16.66%,
    var(--saville-teal) 16.66%,
    var(--saville-teal) 33.33%,
    var(--saville-blue) 33.33%,
    var(--saville-blue) 50%,
    var(--saville-purple) 50%,
    var(--saville-purple) 66.66%,
    var(--saville-coral) 66.66%,
    var(--saville-coral) 83.33%,
    var(--saville-orange) 83.33%,
    var(--saville-orange) 100%
  );
}
```

### Variants

- **Thin:** 2px height - Subtle accent
- **Default:** 4px height - Standard
- **Thick:** 6px height - Prominent branding

### Usage Guidelines

**Do:**
- Use on splash screens, login pages, or about pages
- Place at top or bottom of viewport
- Use sparingly for visual impact

**Don't:**
- Display persistently across all pages
- Use in data-dense UIs or dashboards
- Combine with other decorative elements

### Example

```tsx
<MainLayout showCodeBar={true}>
  {/* Content */}
</MainLayout>
```

**Default:** `showCodeBar={false}` - Code bar is opt-in, not persistent.

---

## FAC Numbering

### Concept

Inspired by Factory Records' catalogue numbering system (FAC numbers), which treated every design output as a numbered artifact in a systematic catalogue.

### Visual Style

```css
.fac-number {
  font-family: var(--font-mono);        /* IBM Plex Mono */
  font-weight: var(--font-medium);      /* 500 */
  font-size: var(--text-xs);            /* 12px */
  letter-spacing: var(--tracking-wider); /* 0.05em */
  text-transform: uppercase;
  color: var(--text-muted-dark);        /* rgba(255,255,255,0.5) */
}
```

### Usage

Apply `.fac-number` class to:
- Version numbers (e.g., "v1.2.3")
- Entity IDs (e.g., "PROJ-001", "TASK-042")
- Indices or catalogue references
- Timestamps or dates in data views

**Example:**
```html
<span class="fac-number">FAC-451</span>
<span class="fac-number">v2.1.0</span>
```

**Philosophy:** Treat data and metadata as systematized, auditable, and precise - not decorative.

---

## Component Patterns

### Solid Card (Replacing Glassmorphism)

**Before (Tron Glassmorphism):**
```css
.glassCard {
  background: rgba(255,255,255,0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(0,255,255,0.3);
}
```

**After (Saville Solid):**
```css
.solidCard {
  background: var(--bg-dark-secondary); /* #2D2D2D */
  border: 1px solid var(--border-dark);  /* rgba(255,255,255,0.1) */
  box-shadow: var(--shadow-md-dark);     /* 0 2px 4px rgba(0,0,0,0.3) */
  border-radius: var(--radius-lg);       /* 6px */
  padding: var(--space-6);                /* 24px */
}
```

### Legacy API Compatibility

For backward compatibility during migration, the following exports map old glassmorphism styles to new Saville patterns:

```typescript
// Old API (deprecated, but still functional)
export const glassCard = solidCard;
export const glassmorphism = saville;

// New API (recommended)
export const solidCard = { ... };
export const saville = { ... };
```

**Migration Strategy:** Update all `glassCard` references to `solidCard` progressively. No breaking changes during transition.

---

## Theme Switching

Archon supports both dark and light modes, with dark mode as the default.

### Implementation

```css
/* Dark Mode (Default) */
[data-theme="dark"],
:root {
  --bg-primary: var(--bg-dark-primary);
  --text-primary: var(--text-primary-dark);
  --border-color: var(--border-dark);
  --shadow-sm: var(--shadow-sm-dark);
}

/* Light Mode */
[data-theme="light"] {
  --bg-primary: var(--bg-light-primary);
  --text-primary: var(--text-primary-light);
  --border-color: var(--border-light);
  --shadow-sm: var(--shadow-sm-light);
}
```

### Toggle Mechanism

User preference stored in local storage and applied via `data-theme` attribute on root element.

**Recommendation:** Maintain dark mode as primary design target. Ensure all components work in both modes but optimize for dark-first experience.

---

## Implementation

### File Location

Design tokens are centralized in:

**Path:** `archon-ui-main/src/styles/saville-tokens.css`

**Contents:**
- Colour tokens (Saville Signature, Away Strip, backgrounds, semantic colours)
- Typography tokens (fonts, weights, sizes, line heights, letter spacing)
- Spacing system (8px grid)
- Border tokens (widths, radius, colours)
- Shadow tokens (elevation system)
- Animation tokens (durations, easing, transitions)
- Z-index scale
- Component tokens (buttons, cards, inputs, navigation)
- Utility classes (code-bar, fac-number)
- Theme switching

### Usage in Components

```tsx
import '../styles/saville-tokens.css';

function MyComponent() {
  return (
    <div
      style={{
        background: 'var(--bg-dark-secondary)',
        color: 'var(--text-primary)',
        padding: 'var(--space-6)',
        borderRadius: 'var(--radius-lg)',
        boxShadow: 'var(--shadow-md)',
      }}
    >
      Content
    </div>
  );
}
```

### Tailwind Integration

For projects using Tailwind CSS, extend the theme configuration to include Saville tokens:

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        'saville-green': '#4A7C59',
        'saville-teal': '#2E8B8B',
        'saville-blue': '#1565C0',
        // ... other colours
      },
      fontFamily: {
        sans: ['IBM Plex Sans', 'sans-serif'],
        mono: ['IBM Plex Mono', 'monospace'],
      },
      spacing: {
        // Use 8px grid
      },
    },
  },
};
```

---

## Documentation Gap Analysis

### What's Missing

1. **Component Library Documentation**
   - No Storybook or visual style guide yet
   - Component API documentation incomplete
   - Usage examples needed for each component

2. **Responsive Breakpoints**
   - Mobile, tablet, desktop breakpoints not documented
   - Responsive typography scale undefined
   - Fluid spacing system not specified

3. **Accessibility Guidelines**
   - WCAG compliance targets not documented
   - Keyboard navigation patterns not standardized
   - Screen reader considerations not specified

4. **Icon System**
   - Icon library not defined (Heroicons, Lucide, custom?)
   - Icon sizing and colour usage not documented

5. **Data Visualization**
   - Chart colour palette not extended to Saville Edition
   - Data viz guidelines missing

### Recommended Next Steps

1. **Create Storybook** - Visual component library with all Saville Edition patterns
2. **Document Responsive Patterns** - Define mobile-first breakpoints and fluid spacing
3. **Accessibility Audit** - Ensure WCAG 2.1 AA compliance across all components
4. **Icon Library Selection** - Choose and document icon usage patterns
5. **Data Viz Extension** - Apply Saville palette to charts, graphs, and dashboards

---

## Appendices

### Appendix A: Design Token Summary

**Total Tokens:** 100+

**Categories:**
- Colours: 24 base colours + 12 semantic colours
- Typography: 6 weights, 9 sizes, 6 line heights, 6 letter spacings
- Spacing: 14 spacing units
- Borders: 4 widths, 5 radii, 4 colours
- Shadows: 8 shadow definitions (4 per mode)
- Animation: 5 durations, 4 easing curves, 4 transition sets
- Z-Index: 8 layers
- Components: 15 component-specific tokens

### Appendix B: Browser Support

**Target Browsers:**
- Chrome/Edge 90+ (Chromium)
- Firefox 88+
- Safari 14+
- Mobile Safari (iOS 14+)
- Chrome Android (last 2 versions)

**CSS Features Used:**
- CSS Custom Properties (CSS Variables)
- Flexbox & Grid
- Backdrop-filter (not used in Saville Edition)
- RGBA colours with alpha
- Cubic-bezier easing

**No Polyfills Required** - All features have >95% global browser support.

### Appendix C: Migration Checklist

For teams migrating from Tron glassmorphism to Saville Edition:

- [ ] Replace `backdrop-filter` with solid backgrounds
- [ ] Update `glassCard` references to `solidCard`
- [ ] Swap neon colours for Saville Signature/Away Strip palette
- [ ] Replace Geist fonts with IBM Plex Sans/Mono
- [ ] Update border colours from `rgba(0,255,255,0.3)` to `rgba(255,255,255,0.1)`
- [ ] Remove glow effects and dramatic shadows
- [ ] Apply geometric precision (8px grid, minimal radius)
- [ ] Update focus states to Saville Blue ring
- [ ] Test theme switching (dark and light modes)
- [ ] Verify accessibility (focus indicators, contrast ratios)

### Appendix D: Version History

**v1.0 (January 2026)**
- Initial Saville Edition implementation
- Complete redesign from Tron glassmorphism
- 100+ design tokens defined
- Code Bar and FAC Numbering utility classes
- Legacy API compatibility maintained

**Future Versions:**
- v1.1: Component library documentation (Storybook)
- v1.2: Responsive patterns and mobile-first guidelines
- v1.3: Data visualization colour palette extension

---

## Conclusion

The Saville Edition represents a fundamental shift in Archon's visual identity - from cyberpunk ornamentation to functional modernism. By grounding the design in Peter Saville's legacy, Archon achieves:

1. **Professional Credibility** - Design rooted in iconic visual language
2. **Functional Clarity** - Colour and typography serve purpose, not decoration
3. **Systematic Rigor** - 100+ tokens ensure consistency and maintainability
4. **Brand Identity** - Distinct visual language separates Archon from generic SaaS aesthetics

**Core Philosophy:** Typography as architecture. Colour as information. Geometric precision meets emotional resonance.

**Status:** Production-ready. All tokens implemented in `saville-tokens.css`. Ready for component library expansion and responsive pattern documentation.

---

**Document Version:** 1.0
**Last Updated:** January 2026
**Maintained By:** 45Black Limited
**Location:** `~/Projects/infrastructure/archon/docs/SAVILLE-UI-SPEC.md`
