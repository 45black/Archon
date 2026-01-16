/**
 * 45BLACK Shared Style Utilities — Saville Edition
 *
 * Inspired by Peter Saville's work for Factory Records and Haçienda.
 * Solid containers, geometric precision, subtle depth.
 *
 * Theme Support:
 * - All styles use Tailwind's dark: prefix for automatic theme switching
 * - Theme is managed by ThemeContext (light/dark)
 * - For runtime theme values, use useThemeAware hook
 */

// ==========================================================================
// SAVILLE DESIGN SYSTEM
// Replaces glassmorphism with solid containers and precise borders
// ==========================================================================

export const saville = {
  // Background variations - solid colours, no blur
  background: {
    subtle: "bg-muted/50 dark:bg-muted/30",
    strong: "bg-muted dark:bg-muted/50",
    card: "bg-card dark:bg-card",
    elevated: "bg-background dark:bg-card",
    // Saville palette tints
    blue: "bg-saville-blue/5 dark:bg-saville-blue/10",
    purple: "bg-saville-purple/5 dark:bg-saville-purple/10",
    teal: "bg-saville-teal/5 dark:bg-saville-teal/10",
    green: "bg-saville-green/5 dark:bg-saville-green/10",
    coral: "bg-saville-coral/5 dark:bg-saville-coral/10",
    gold: "bg-away-gold/10 dark:bg-away-gold/5",
  },

  // Border styles - precise, not glowing
  border: {
    default: "border border-border",
    strong: "border border-border dark:border-muted-foreground/20",
    subtle: "border border-border/50",
    primary: "border border-primary/30 dark:border-primary/40",
    accent: "border border-accent/30 dark:border-accent/40",
    focus: "focus:border-primary focus:ring-2 focus:ring-primary/20",
    hover: "hover:border-primary/50",
  },

  // Interactive states - precise, not neon
  interactive: {
    base: "transition-all duration-200",
    hover: "hover:bg-muted/80 dark:hover:bg-muted/40",
    active: "active:bg-muted dark:active:bg-muted/60",
    selected: "data-[state=checked]:bg-primary/10 dark:data-[state=checked]:bg-primary/20 data-[state=checked]:text-primary",
    disabled: "disabled:opacity-50 disabled:cursor-not-allowed",
  },

  // Animation presets - precise micro-interactions
  animation: {
    fadeIn: "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
    slideIn: "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
    slideFromTop: "data-[side=bottom]:slide-in-from-top-2",
    slideFromBottom: "data-[side=top]:slide-in-from-bottom-2",
    slideFromLeft: "data-[side=right]:slide-in-from-left-2",
    slideFromRight: "data-[side=left]:slide-in-from-right-2",
  },

  // Shadow effects - subtle depth, not neon glow
  shadow: {
    sm: "shadow-sm",
    md: "shadow-md",
    lg: "shadow-lg",
    elevated: "shadow-md dark:shadow-lg dark:shadow-black/20",
    // Colour accents for special emphasis (used sparingly)
    accent: {
      blue: "shadow-md shadow-saville-blue/10",
      purple: "shadow-md shadow-saville-purple/10",
      teal: "shadow-md shadow-saville-teal/10",
      green: "shadow-md shadow-saville-green/10",
      coral: "shadow-md shadow-saville-coral/10",
    },
  },

  // Edge positions for accent bars
  edge: {
    none: "",
    top: "before:content-[''] before:absolute before:top-0 before:left-0 before:right-0 before:h-[2px]",
    left: "before:content-[''] before:absolute before:top-0 before:left-0 before:bottom-0 before:w-[2px]",
    right: "before:content-[''] before:absolute before:top-0 before:right-0 before:bottom-0 before:w-[2px]",
    bottom: "before:content-[''] before:absolute before:bottom-0 before:left-0 before:right-0 before:h-[2px]",
  },

  // Sizes
  sizes: {
    card: {
      sm: "p-4",
      md: "p-6",
      lg: "p-8",
      xl: "p-10",
    },
  },

  // Priority colors (matching task system)
  priority: {
    critical: {
      background: "bg-saville-coral/10 dark:bg-saville-coral/20",
      text: "text-saville-coral dark:text-saville-coral",
      hover: "hover:bg-saville-coral/20 dark:hover:bg-saville-coral/30",
      border: "border-saville-coral/30",
    },
    high: {
      background: "bg-saville-orange/10 dark:bg-saville-orange/20",
      text: "text-saville-orange dark:text-saville-orange",
      hover: "hover:bg-saville-orange/20 dark:hover:bg-saville-orange/30",
      border: "border-saville-orange/30",
    },
    medium: {
      background: "bg-saville-blue/10 dark:bg-saville-blue/20",
      text: "text-saville-blue dark:text-saville-blue",
      hover: "hover:bg-saville-blue/20 dark:hover:bg-saville-blue/30",
      border: "border-saville-blue/30",
    },
    low: {
      background: "bg-muted dark:bg-muted/50",
      text: "text-muted-foreground",
      hover: "hover:bg-muted/80 dark:hover:bg-muted/70",
      border: "border-border",
    },
  },
};

// ==========================================================================
// SOLID CARD STYLES (replaces glassCard)
// ==========================================================================

export const solidCard = {
  // Base card styling
  base: "relative rounded-md overflow-hidden border transition-all duration-200",

  // Background variants
  background: {
    default: "bg-card dark:bg-card",
    elevated: "bg-background dark:bg-card",
    muted: "bg-muted/50 dark:bg-muted/30",
    transparent: "bg-transparent",
  },

  // Border variants
  border: {
    default: "border-border",
    subtle: "border-border/50",
    strong: "border-border dark:border-muted-foreground/20",
    primary: "border-primary/30",
    accent: "border-accent/30",
  },

  // Colour tints for cards
  tints: {
    none: "",
    blue: {
      light: "bg-saville-blue/5 dark:bg-saville-blue/10",
      medium: "bg-saville-blue/10 dark:bg-saville-blue/15",
      strong: "bg-saville-blue/15 dark:bg-saville-blue/20",
    },
    purple: {
      light: "bg-saville-purple/5 dark:bg-saville-purple/10",
      medium: "bg-saville-purple/10 dark:bg-saville-purple/15",
      strong: "bg-saville-purple/15 dark:bg-saville-purple/20",
    },
    teal: {
      light: "bg-saville-teal/5 dark:bg-saville-teal/10",
      medium: "bg-saville-teal/10 dark:bg-saville-teal/15",
      strong: "bg-saville-teal/15 dark:bg-saville-teal/20",
    },
    green: {
      light: "bg-saville-green/5 dark:bg-saville-green/10",
      medium: "bg-saville-green/10 dark:bg-saville-green/15",
      strong: "bg-saville-green/15 dark:bg-saville-green/20",
    },
    coral: {
      light: "bg-saville-coral/5 dark:bg-saville-coral/10",
      medium: "bg-saville-coral/10 dark:bg-saville-coral/15",
      strong: "bg-saville-coral/15 dark:bg-saville-coral/20",
    },
    orange: {
      light: "bg-saville-orange/5 dark:bg-saville-orange/10",
      medium: "bg-saville-orange/10 dark:bg-saville-orange/15",
      strong: "bg-saville-orange/15 dark:bg-saville-orange/20",
    },
    gold: {
      light: "bg-away-gold/5 dark:bg-away-gold/10",
      medium: "bg-away-gold/10 dark:bg-away-gold/15",
      strong: "bg-away-gold/15 dark:bg-away-gold/20",
    },
  },

  // Accent edge colours
  edgeColors: {
    blue: {
      solid: "bg-saville-blue",
      border: "border-saville-blue/30",
      bg: "bg-saville-blue/5 dark:bg-saville-blue/10",
    },
    purple: {
      solid: "bg-saville-purple",
      border: "border-saville-purple/30",
      bg: "bg-saville-purple/5 dark:bg-saville-purple/10",
    },
    teal: {
      solid: "bg-saville-teal",
      border: "border-saville-teal/30",
      bg: "bg-saville-teal/5 dark:bg-saville-teal/10",
    },
    green: {
      solid: "bg-saville-green",
      border: "border-saville-green/30",
      bg: "bg-saville-green/5 dark:bg-saville-green/10",
    },
    coral: {
      solid: "bg-saville-coral",
      border: "border-saville-coral/30",
      bg: "bg-saville-coral/5 dark:bg-saville-coral/10",
    },
    orange: {
      solid: "bg-saville-orange",
      border: "border-saville-orange/30",
      bg: "bg-saville-orange/5 dark:bg-saville-orange/10",
    },
    gold: {
      solid: "bg-away-gold",
      border: "border-away-gold/30",
      bg: "bg-away-gold/5 dark:bg-away-gold/10",
    },
    // Legacy colour mappings for DataCard compatibility
    cyan: {
      solid: "bg-saville-teal",
      border: "border-saville-teal/30",
      bg: "bg-saville-teal/5 dark:bg-saville-teal/10",
    },
    pink: {
      solid: "bg-saville-purple",
      border: "border-saville-purple/30",
      bg: "bg-saville-purple/5 dark:bg-saville-purple/10",
    },
    red: {
      solid: "bg-saville-coral",
      border: "border-saville-coral/30",
      bg: "bg-saville-coral/5 dark:bg-saville-coral/10",
    },
  },

  // Size variants
  sizes: {
    none: "p-0",
    sm: "p-4",
    md: "p-6",
    lg: "p-8",
    xl: "p-10",
  },

  // Hover states
  hover: {
    none: "",
    subtle: "hover:bg-muted/50 dark:hover:bg-muted/20",
    lift: "hover:shadow-lg hover:-translate-y-0.5",
    border: "hover:border-primary/50",
  },
};

// ==========================================================================
// LEGACY COMPATIBILITY LAYER
// Maps old glassmorphism API to new Saville styles
// ==========================================================================

/** @deprecated Use saville instead */
export const glassmorphism = {
  background: {
    subtle: saville.background.subtle,
    strong: saville.background.strong,
    card: saville.background.card,
    cyan: saville.background.teal, // Map cyan to teal
    blue: saville.background.blue,
    purple: saville.background.purple,
  },

  border: {
    default: saville.border.default,
    cyan: saville.border.primary, // Map cyan to primary (Saville Blue)
    blue: saville.border.primary,
    purple: saville.border.accent,
    focus: saville.border.focus,
    hover: saville.border.hover,
  },

  interactive: saville.interactive,
  animation: saville.animation,

  shadow: {
    sm: saville.shadow.sm,
    md: saville.shadow.md,
    lg: saville.shadow.lg,
    elevated: saville.shadow.elevated,
    // Legacy glow mappings - now subtle shadows
    glow: {
      purple: saville.shadow.accent.purple,
      blue: saville.shadow.accent.blue,
      green: saville.shadow.accent.green,
      red: saville.shadow.accent.coral,
      orange: saville.shadow.accent.coral,
      cyan: saville.shadow.accent.teal,
      pink: saville.shadow.accent.purple,
    },
  },

  edgePositions: saville.edge,
  sizes: saville.sizes,
  priority: saville.priority,
};

/** @deprecated Use solidCard instead */
export const glassCard = {
  base: solidCard.base,

  // Blur no longer used - map to empty or subtle effect
  blur: {
    none: "",
    sm: "",
    md: "",
    lg: "",
    xl: "",
    "2xl": "",
    "3xl": "",
  },

  // Transparency maps to background variants
  transparency: {
    clear: solidCard.background.transparent,
    light: solidCard.background.muted,
    medium: solidCard.background.default,
    frosted: solidCard.background.elevated,
    solid: solidCard.background.default,
  },

  // Edge colours
  edgeColors: solidCard.edgeColors,

  // Tints map to new structure
  tints: {
    none: "",
    purple: {
      clear: solidCard.tints.purple.light,
      light: solidCard.tints.purple.light,
      medium: solidCard.tints.purple.medium,
      frosted: solidCard.tints.purple.strong,
      solid: solidCard.tints.purple.strong,
    },
    blue: {
      clear: solidCard.tints.blue.light,
      light: solidCard.tints.blue.light,
      medium: solidCard.tints.blue.medium,
      frosted: solidCard.tints.blue.strong,
      solid: solidCard.tints.blue.strong,
    },
    cyan: {
      clear: solidCard.tints.teal.light,
      light: solidCard.tints.teal.light,
      medium: solidCard.tints.teal.medium,
      frosted: solidCard.tints.teal.strong,
      solid: solidCard.tints.teal.strong,
    },
    green: {
      clear: solidCard.tints.green.light,
      light: solidCard.tints.green.light,
      medium: solidCard.tints.green.medium,
      frosted: solidCard.tints.green.strong,
      solid: solidCard.tints.green.strong,
    },
    orange: {
      clear: solidCard.tints.orange.light,
      light: solidCard.tints.orange.light,
      medium: solidCard.tints.orange.medium,
      frosted: solidCard.tints.orange.strong,
      solid: solidCard.tints.orange.strong,
    },
    pink: {
      clear: solidCard.tints.purple.light,
      light: solidCard.tints.purple.light,
      medium: solidCard.tints.purple.medium,
      frosted: solidCard.tints.purple.strong,
      solid: solidCard.tints.purple.strong,
    },
    red: {
      clear: solidCard.tints.coral.light,
      light: solidCard.tints.coral.light,
      medium: solidCard.tints.coral.medium,
      frosted: solidCard.tints.coral.strong,
      solid: solidCard.tints.coral.strong,
    },
  },

  // Variants - simplified, no more neon glows
  variants: {
    none: {
      border: solidCard.border.default,
      glow: "",
      hover: solidCard.hover.subtle,
    },
    purple: {
      border: "border-saville-purple/30",
      glow: "",
      hover: "hover:border-saville-purple/50",
    },
    blue: {
      border: "border-saville-blue/30",
      glow: "",
      hover: "hover:border-saville-blue/50",
    },
    green: {
      border: "border-saville-green/30",
      glow: "",
      hover: "hover:border-saville-green/50",
    },
    cyan: {
      border: "border-saville-teal/30",
      glow: "",
      hover: "hover:border-saville-teal/50",
    },
    orange: {
      border: "border-saville-orange/30",
      glow: "",
      hover: "hover:border-saville-orange/50",
    },
    pink: {
      border: "border-saville-purple/30",
      glow: "",
      hover: "hover:border-saville-purple/50",
    },
    red: {
      border: "border-saville-coral/30",
      glow: "",
      hover: "hover:border-saville-coral/50",
    },
  },

  // Legacy glow sizes - now empty (no neon effects)
  outerGlowSizes: {
    cyan: { sm: "", md: "", lg: "", xl: "" },
    purple: { sm: "", md: "", lg: "", xl: "" },
    blue: { sm: "", md: "", lg: "", xl: "" },
    pink: { sm: "", md: "", lg: "", xl: "" },
    green: { sm: "", md: "", lg: "", xl: "" },
    orange: { sm: "", md: "", lg: "", xl: "" },
    red: { sm: "", md: "", lg: "", xl: "" },
  },

  innerGlowSizes: {
    cyan: { sm: "", md: "", lg: "", xl: "" },
    purple: { sm: "", md: "", lg: "", xl: "" },
    blue: { sm: "", md: "", lg: "", xl: "" },
    pink: { sm: "", md: "", lg: "", xl: "" },
    green: { sm: "", md: "", lg: "", xl: "" },
    orange: { sm: "", md: "", lg: "", xl: "" },
    red: { sm: "", md: "", lg: "", xl: "" },
  },

  outerGlowHover: {
    cyan: { sm: "", md: "", lg: "", xl: "" },
    purple: { sm: "", md: "", lg: "", xl: "" },
    blue: { sm: "", md: "", lg: "", xl: "" },
    pink: { sm: "", md: "", lg: "", xl: "" },
    green: { sm: "", md: "", lg: "", xl: "" },
    orange: { sm: "", md: "", lg: "", xl: "" },
    red: { sm: "", md: "", lg: "", xl: "" },
  },

  innerGlowHover: {
    cyan: { sm: "", md: "", lg: "", xl: "" },
    purple: { sm: "", md: "", lg: "", xl: "" },
    blue: { sm: "", md: "", lg: "", xl: "" },
    pink: { sm: "", md: "", lg: "", xl: "" },
    green: { sm: "", md: "", lg: "", xl: "" },
    orange: { sm: "", md: "", lg: "", xl: "" },
    red: { sm: "", md: "", lg: "", xl: "" },
  },

  sizes: solidCard.sizes,

  // Edge-lit effects - simplified
  edgeLit: {
    position: saville.edge,
    color: {
      purple: {
        line: "before:bg-saville-purple",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-purple before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-purple before:to-transparent",
        },
      },
      blue: {
        line: "before:bg-saville-blue",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-blue before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-blue before:to-transparent",
        },
      },
      cyan: {
        line: "before:bg-saville-teal",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-teal before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-teal before:to-transparent",
        },
      },
      green: {
        line: "before:bg-saville-green",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-green before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-green before:to-transparent",
        },
      },
      orange: {
        line: "before:bg-saville-orange",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-orange before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-orange before:to-transparent",
        },
      },
      pink: {
        line: "before:bg-saville-purple",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-purple before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-purple before:to-transparent",
        },
      },
      red: {
        line: "before:bg-saville-coral",
        glow: "",
        gradient: {
          horizontal: "before:bg-gradient-to-r before:from-transparent before:via-saville-coral before:to-transparent",
          vertical: "before:bg-gradient-to-b before:from-transparent before:via-saville-coral before:to-transparent",
        },
      },
    },
  },
};

// ==========================================================================
// COMPOUND STYLES
// ==========================================================================

export const compoundStyles = {
  // Standard interactive element
  interactiveElement: `
    ${saville.interactive.base}
    ${saville.interactive.hover}
    ${saville.interactive.disabled}
  `,

  // Floating panels (dropdowns, popovers, tooltips)
  floatingPanel: `
    ${saville.background.elevated}
    ${saville.border.default}
    ${saville.shadow.lg}
    ${saville.animation.fadeIn}
    ${saville.animation.slideIn}
  `,

  // Form controls
  formControl: `
    ${saville.background.subtle}
    ${saville.border.default}
    ${saville.border.hover}
    ${saville.border.focus}
    ${saville.interactive.base}
    ${saville.interactive.disabled}
  `,

  // Cards
  card: `
    ${saville.background.card}
    ${saville.border.default}
    ${saville.shadow.md}
  `,
};

// ==========================================================================
// UTILITY FUNCTIONS
// ==========================================================================

/**
 * Combine CSS classes, filtering out falsy values
 */
export function cn(...classes: (string | undefined | false)[]): string {
  return classes.filter(Boolean).join(" ");
}
