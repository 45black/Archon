/**
 * 45BLACK Button Component — Saville Edition
 *
 * Flat + precise hover states. No gradients or neon glows.
 * Typography as architecture.
 */

import React from "react";
import { cn } from "./styles";

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "default" | "destructive" | "outline" | "ghost" | "link" | "cyan" | "knowledge" | "green" | "blue";
  size?: "default" | "sm" | "lg" | "icon" | "xs";
  loading?: boolean;
  children: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "default", size = "default", loading = false, disabled, children, ...props }, ref) => {
    const baseStyles = cn(
      "inline-flex items-center justify-center rounded-md font-medium",
      "transition-all duration-200",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-background",
      "disabled:pointer-events-none disabled:opacity-50",
      loading && "cursor-wait",
    );

    type ButtonVariant = NonNullable<ButtonProps["variant"]>;
    const variants: Record<ButtonVariant, string> = {
      // Default: Saville Blue solid
      default: cn(
        "bg-primary text-primary-foreground",
        "hover:bg-primary/90",
        "active:bg-primary/80",
      ),
      // Destructive: Burnt Coral
      destructive: cn(
        "bg-destructive text-destructive-foreground",
        "hover:bg-destructive/90",
        "active:bg-destructive/80",
      ),
      // Outline: transparent with border
      outline: cn(
        "bg-transparent",
        "border border-border",
        "text-foreground",
        "hover:bg-muted/50 hover:border-primary/50",
        "active:bg-muted",
      ),
      // Ghost: no background, subtle hover
      ghost: cn(
        "text-foreground",
        "hover:bg-muted/80",
        "active:bg-muted",
      ),
      // Link: underline style
      link: cn(
        "text-primary",
        "underline-offset-4 hover:underline",
        "hover:text-primary/80",
      ),
      // Primary: explicit Saville Blue (same as default)
      primary: cn(
        "bg-saville-blue text-white",
        "hover:bg-saville-blue/90",
        "active:bg-saville-blue/80",
      ),
      // Accent: Royal Purple
      accent: cn(
        "bg-accent text-accent-foreground",
        "hover:bg-accent/90",
        "active:bg-accent/80",
      ),
      green: cn(
        "backdrop-blur-md",
        "bg-gradient-to-b from-green-100/80 to-white/60",
        "dark:from-green-500/20 dark:to-green-500/10",
        "text-green-700 dark:text-green-100",
        "border border-green-300/50 dark:border-green-500/50",
        "hover:from-green-200/90 hover:to-green-100/70",
        "dark:hover:from-green-400/30 dark:hover:to-green-500/20",
        "hover:shadow-[0_0_20px_rgba(34,197,94,0.5)]",
        "dark:hover:shadow-[0_0_25px_rgba(34,197,94,0.7)]",
        "focus-visible:ring-green-500",
      ),
      blue: cn(
        "backdrop-blur-md",
        "bg-gradient-to-b from-blue-100/80 to-white/60",
        "dark:from-blue-500/20 dark:to-blue-500/10",
        "text-blue-700 dark:text-blue-100",
        "border border-blue-300/50 dark:border-blue-500/50",
        "hover:from-blue-200/90 hover:to-blue-100/70",
        "dark:hover:from-blue-400/30 dark:hover:to-blue-500/20",
        "hover:shadow-[0_0_20px_rgba(59,130,246,0.5)]",
        "dark:hover:shadow-[0_0_25px_rgba(59,130,246,0.7)]",
        "focus-visible:ring-blue-500",
      ),
    };

    type ButtonSize = NonNullable<ButtonProps["size"]>;
    const sizes: Record<ButtonSize, string> = {
      default: "h-10 px-4 py-2",
      sm: "h-9 rounded-md px-3",
      lg: "h-11 rounded-md px-8",
      icon: "h-10 w-10",
      xs: "h-7 px-2 text-xs",
    };

    return (
      <button
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        ref={ref}
        disabled={disabled || loading}
        {...props}
      >
        {loading && (
          <svg
            className="mr-2 h-4 w-4 animate-spin"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-label="Loading"
            role="img"
          >
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
        )}
        {children}
      </button>
    );
  },
);

Button.displayName = "Button";

export interface IconButtonProps extends Omit<ButtonProps, "size" | "children"> {
  icon: React.ReactNode;
  "aria-label": string;
}

export const IconButton = React.forwardRef<HTMLButtonElement, IconButtonProps>(({ icon, className, ...props }, ref) => {
  return (
    <Button ref={ref} size="icon" className={cn("relative", className)} {...props}>
      {icon}
    </Button>
  );
});

IconButton.displayName = "IconButton";
