/**
 * 45BLACK Main Layout — Saville Edition
 *
 * Clean layout with optional code bar for branding moments.
 * Geometric precision, invisible structural grid.
 */

import { AlertCircle, WifiOff } from "lucide-react";
import type React from "react";
import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { useToast } from "../../features/shared/hooks/useToast";
import { cn } from "../../lib/utils";
import { credentialsService } from "../../services/credentialsService";
import { isLmConfigured } from "../../utils/onboarding";

// TEMPORARY: Import from old components until they're migrated to features
import { BackendStartupError } from "../BackendStartupError";
import { useBackendHealth } from "./hooks/useBackendHealth";
import { Navigation } from "./Navigation";

interface MainLayoutProps {
  children: React.ReactNode;
  className?: string;
  /** Show the 45Black code bar at the bottom */
  showCodeBar?: boolean;
}

interface BackendStatusProps {
  isHealthLoading: boolean;
  isBackendError: boolean;
  healthData: { ready: boolean } | undefined;
}

/**
 * Backend health indicator component
 */
function BackendStatus({ isHealthLoading, isBackendError, healthData }: BackendStatusProps) {
  if (isHealthLoading) {
    return (
      <div className="flex items-center gap-2 px-3 py-1.5 rounded-md bg-away-gold/20 text-away-charcoal dark:text-away-gold text-sm">
        <div className="w-2 h-2 bg-away-gold rounded-full animate-pulse" />
        <span>Connecting...</span>
      </div>
    );
  }

  if (isBackendError) {
    return (
      <div className="flex items-center gap-2 px-3 py-1.5 rounded-md bg-saville-coral/10 text-saville-coral text-sm">
        <WifiOff className="w-4 h-4" />
        <span>Backend Offline</span>
      </div>
    );
  }

  if (healthData?.ready === false) {
    return (
      <div className="flex items-center gap-2 px-3 py-1.5 rounded-md bg-away-gold/20 text-away-charcoal dark:text-away-gold text-sm">
        <AlertCircle className="w-4 h-4" />
        <span>Backend Starting...</span>
      </div>
    );
  }

  return null;
}

/**
 * 45Black Code Bar - signature brand element
 * Only shown on specific branding moments, not persistent
 */
function CodeBar() {
  return (
    <div className="code-bar w-full" aria-hidden="true" />
  );
}

/**
 * Modern main layout using Saville design principles
 * Uses CSS Grid for layout instead of fixed positioning
 */
export function MainLayout({ children, className, showCodeBar = false }: MainLayoutProps) {
  const navigate = useNavigate();
  const location = useLocation();
  const { showToast } = useToast();

  // Backend health monitoring with TanStack Query
  const {
    data: healthData,
    isError: isBackendError,
    error: backendError,
    isLoading: isHealthLoading,
    failureCount,
  } = useBackendHealth();

  // Track if backend has completely failed (for showing BackendStartupError)
  const backendStartupFailed = isBackendError && failureCount >= 5;

  // TEMPORARY: Handle onboarding redirect using old logic until migrated
  useEffect(() => {
    const checkOnboarding = async () => {
      // Skip if backend failed to start
      if (backendStartupFailed) {
        return;
      }

      // Skip if not ready, already on onboarding, or already dismissed
      if (!healthData?.ready || location.pathname === "/onboarding") {
        return;
      }

      // Check if onboarding was already dismissed
      if (localStorage.getItem("onboardingDismissed") === "true") {
        return;
      }

      try {
        // Fetch credentials in parallel (using old service temporarily)
        const [ragCreds, apiKeyCreds] = await Promise.all([
          credentialsService.getCredentialsByCategory("rag_strategy"),
          credentialsService.getCredentialsByCategory("api_keys"),
        ]);

        // Check if LM is configured (using old utility temporarily)
        const configured = isLmConfigured(ragCreds, apiKeyCreds);

        if (!configured) {
          // Redirect to onboarding
          navigate("/onboarding", { replace: true });
        }
      } catch (error) {
        // Log error but don't block app
        console.error("ONBOARDING_CHECK_FAILED:", error);
        showToast(`Configuration check failed. You can manually configure in Settings.`, "warning");
      }
    };

    checkOnboarding();
  }, [healthData?.ready, backendStartupFailed, location.pathname, navigate, showToast]);

  // Show backend error toast (once)
  useEffect(() => {
    if (isBackendError && backendError) {
      const errorMessage = backendError instanceof Error ? backendError.message : "Backend connection failed";
      showToast(`Backend unavailable: ${errorMessage}. Some features may not work.`, "error");
    }
  }, [isBackendError, backendError, showToast]);

  return (
    <div className={cn("relative min-h-screen flex flex-col overflow-hidden", className)}>
      {/* TEMPORARY: Show backend startup error using old component */}
      {backendStartupFailed && <BackendStartupError />}

      {/* Clean background - solid colour */}
      <div className="fixed inset-0 bg-background pointer-events-none -z-10" />

      {/* Subtle structural grid (optional, very faint) */}
      <div className="fixed inset-0 saville-grid pointer-events-none z-0" />

      {/* Floating Navigation */}
      <div className="fixed left-6 top-1/2 -translate-y-1/2 z-50 flex flex-col gap-4">
        <Navigation />
        <BackendStatus isHealthLoading={isHealthLoading} isBackendError={isBackendError} healthData={healthData} />
      </div>

      {/* Main Content Area */}
      <div className="relative flex-1 pl-[100px]">
        <div className="container mx-auto px-8 relative">
          <div className="min-h-screen pt-8 pb-16">{children}</div>
        </div>
      </div>

      {/* Optional Code Bar Footer */}
      {showCodeBar && (
        <div className="fixed bottom-0 left-0 right-0 z-40">
          <CodeBar />
        </div>
      )}

      {/* TEMPORARY: Floating Chat Button (disabled) - from old layout */}
      <div className="fixed bottom-6 right-6 z-50 group">
        <button
          type="button"
          disabled
          className="w-14 h-14 rounded-full flex items-center justify-center bg-muted/50 dark:bg-muted/30 border border-border shadow-md cursor-not-allowed opacity-60 overflow-hidden"
          aria-label="Knowledge Assistant - Coming Soon"
        >
          <img src="/logo-neon.png" alt="Archon" className="w-7 h-7 grayscale opacity-50" />
        </button>
        {/* Tooltip */}
        <div className="absolute bottom-full right-0 mb-2 px-3 py-2 bg-card border border-border text-foreground text-sm rounded-md shadow-lg opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap">
          <div className="font-medium">Coming Soon</div>
          <div className="text-xs text-muted-foreground">Knowledge Assistant is under development</div>
          <div className="absolute bottom-0 right-6 transform translate-y-1/2 rotate-45 w-2 h-2 bg-card border-r border-b border-border"></div>
        </div>
      </div>
    </div>
  );
}

/**
 * Layout variant without navigation for special pages
 */
export function MinimalLayout({ children, className }: MainLayoutProps) {
  return (
    <div className={cn("min-h-screen bg-background", "flex items-center justify-center", className)}>
      {/* Subtle Background Grid */}
      <div className="absolute inset-0 saville-grid pointer-events-none opacity-50" />

      {/* Centered Content */}
      <div className="relative w-full max-w-4xl px-6">{children}</div>
    </div>
  );
}

/**
 * Branded layout variant with code bar - for landing pages, key screens
 */
export function BrandedLayout({ children, className }: MainLayoutProps) {
  return (
    <MainLayout className={className} showCodeBar={true}>
      {children}
    </MainLayout>
  );
}
