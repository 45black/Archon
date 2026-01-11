/**
 * 45BLACK Tailwind Configuration — Saville Edition
 *
 * Tailwind v4 uses @theme in CSS for most configuration.
 * This config extends with 45Black brand colors and IBM Plex fonts.
 */

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],

  theme: {
    extend: {
      // 45Black Saville Palette
      colors: {
        // Primary Saville colours
        saville: {
          green: '#4A7C59',
          teal: '#2E8B8B',
          blue: '#1565C0',
          purple: '#7B1FA2',
          coral: '#E65100',
          orange: '#F57C00',
        },
        // Away strip colours
        away: {
          grey: '#E0E0E0',
          slate: '#5C6BC0',
          rose: '#D48CA1',
          sage: '#81C784',
          gold: '#FFD54F',
          charcoal: '#424242',
        },
      },

      // IBM Plex fonts
      fontFamily: {
        sans: ['IBM Plex Sans', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'sans-serif'],
        mono: ['IBM Plex Mono', 'SF Mono', 'Fira Code', 'monospace'],
      },

      // Geometric border radius (minimal)
      borderRadius: {
        'saville': '4px',
        'saville-sm': '2px',
        'saville-lg': '6px',
      },

      // 8px base spacing grid
      spacing: {
        '18': '4.5rem',
        '22': '5.5rem',
      },

      // Precise animations
      animation: {
        'fade-in': 'fade-in 0.2s ease-out',
        'slide-up': 'slide-up 0.3s ease-out',
      },

      keyframes: {
        'fade-in': {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        'slide-up': {
          from: { opacity: '0', transform: 'translateY(8px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
}
