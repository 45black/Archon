/**
 * 45BLACK Card Component — Saville Edition
 *
 * Solid containers with geometric precision.
 * No glassmorphism, no blur effects.
 * Colour as information, not decoration.
 */

import React from "react";
import { cn, solidCard, glassCard } from "./styles";

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  // Background variant
  background?: "default" | "elevated" | "muted" | "transparent";

  // Colour tint (Saville palette)
  tint?: "none" | "blue" | "purple" | "teal" | "green" | "coral" | "orange" | "gold";
  tintIntensity?: "light" | "medium" | "strong";

  // Border style
  border?: "default" | "subtle" | "strong" | "primary" | "accent";

  // Edge accent bar
  edgePosition?: "none" | "top" | "left" | "right" | "bottom";
  edgeColor?: "blue" | "purple" | "teal" | "green" | "coral" | "orange" | "gold";

  // Size (padding)
  size?: "none" | "sm" | "md" | "lg" | "xl";

  // Hover effect
  hover?: "none" | "subtle" | "lift" | "border";

  // Legacy props for backward compatibility
  /** @deprecated Use background instead */
  blur?: "none" | "sm" | "md" | "lg" | "xl" | "2xl" | "3xl";
  /** @deprecated Use background instead */
  transparency?: "clear" | "light" | "medium" | "frosted" | "solid";
  /** @deprecated Use tint instead */
  glassTint?: "none" | "purple" | "blue" | "cyan" | "green" | "orange" | "pink" | "red";
  /** @deprecated Use edgeColor with tint instead */
  glowColor?: "none" | "purple" | "blue" | "cyan" | "green" | "orange" | "pink" | "red";
  /** @deprecated No longer used */
  glowType?: "outer" | "inner";
  /** @deprecated No longer used */
  glowSize?: "sm" | "md" | "lg" | "xl";
}

// Map legacy colour names to Saville palette
const colourMap: Record<string, "blue" | "purple" | "teal" | "green" | "coral" | "orange" | "gold"> = {
  cyan: "teal",
  pink: "purple",
  red: "coral",
};

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  (
    {
      className,
      // New Saville props
      background = "default",
      tint = "none",
      tintIntensity = "light",
      border = "default",
      edgePosition = "none",
      edgeColor = "blue",
      size = "md",
      hover = "none",
      // Legacy props
      blur,
      transparency,
      glassTint,
      glowColor,
      glowType,
      glowSize,
      children,
      ...props
    },
    ref,
  ) => {
    // Handle legacy glassTint prop
    const effectiveTint = glassTint && glassTint !== "none"
      ? (colourMap[glassTint] || glassTint as "blue" | "purple" | "teal" | "green" | "coral" | "orange" | "gold")
      : tint;

    // Handle legacy glowColor prop (now maps to edge)
    const effectiveEdgeColor = glowColor && glowColor !== "none"
      ? (colourMap[glowColor] || glowColor as "blue" | "purple" | "teal" | "green" | "coral" | "orange" | "gold")
      : edgeColor;

    const hasEdge = edgePosition !== "none";

    // Get edge style from solidCard
    const edgeStyle = solidCard.edgeColors[effectiveEdgeColor] || solidCard.edgeColors.blue;

    if (hasEdge) {
      // Edge-accented card with actual div elements
      const flexClasses =
        className?.match(/(flex|flex-col|flex-row|flex-1|items-\S+|justify-\S+|gap-\S+)/g)?.join(" ") || "";
      const otherClasses =
        className?.replace(/(flex|flex-col|flex-row|flex-1|items-\S+|justify-\S+|gap-\S+)/g, "").trim() || "";

      // Edge configuration per position
      const edgeConfig = {
        top: {
          line: "absolute inset-x-0 top-0 h-[2px]",
        },
        bottom: {
          line: "absolute inset-x-0 bottom-0 h-[2px]",
        },
        left: {
          line: "absolute inset-y-0 left-0 w-[2px]",
        },
        right: {
          line: "absolute inset-y-0 right-0 w-[2px]",
        },
      };

      const config = edgeConfig[edgePosition as keyof typeof edgeConfig];

      return (
        <div
          ref={ref}
          className={cn(
            "relative rounded-md overflow-hidden border",
            solidCard.border[border],
            solidCard.background[background],
            otherClasses
          )}
          {...props}
        >
          {/* Edge accent bar */}
          <div className={cn(config.line, "pointer-events-none z-10", edgeStyle.solid)} />
          {/* Content */}
          <div className={cn(edgeStyle.bg, solidCard.sizes[size], flexClasses)}>{children}</div>
        </div>
      );
    }

    // Standard card (no edge accent)
    const getTintClass = () => {
      if (effectiveTint === "none") return "";
      const tintConfig = solidCard.tints[effectiveTint as keyof typeof solidCard.tints];
      if (!tintConfig || typeof tintConfig === "string") return "";
      return tintConfig[tintIntensity] || "";
    };

    return (
      <div
        ref={ref}
        className={cn(
          solidCard.base,
          // Background - tint takes precedence
          getTintClass() || solidCard.background[background],
          // Border
          solidCard.border[border],
          // Size
          solidCard.sizes[size],
          // Hover
          solidCard.hover[hover],
          className,
        )}
        {...props}
      >
        {children}
      </div>
    );
  },
);

Card.displayName = "Card";
