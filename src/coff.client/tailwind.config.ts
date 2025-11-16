import type { Config } from "tailwindcss";

export default {
	content: [
		"./components/**/*.{js,ts,jsx,tsx,mdx}",
		"./app/**/*.{js,ts,jsx,tsx,mdx}",
	],
	theme: {
		extend: {
			colors: {
				// Brand palette (shades for brand usage across the app)
				brand: {
					mint: {
						50: "var(--color-brand-mint-50)",
						100: "var(--color-brand-mint-100)",
						200: "var(--color-brand-mint-200)",
						300: "var(--color-brand-mint-300)",
						400: "var(--color-brand-mint-400)",
						500: "var(--color-brand-mint-500)",
						600: "var(--color-brand-mint-600)",
						700: "var(--color-brand-mint-700)",
					}
				},


				// Semantic tokens powered by CSS variables for runtime theming
				background: 'var(--color-background)',
				surface: 'var(--color-surface)',
				card: {
					DEFAULT: 'var(--color-card)',
					foreground: 'var(--color-card-foreground)'
				},
				popover: {
					DEFAULT: 'var(--color-popover)',
					foreground: 'var(--color-popover-foreground)'
				},
				foreground: 'var(--color-foreground)',
				primary: {
					DEFAULT: 'var(--color-primary)',
					foreground: 'var(--color-primary-foreground)'
				},
				muted: {
					DEFAULT: 'var(--color-muted)',
					foreground: 'var(--color-muted-foreground)'
				},
				secondary: {
					DEFAULT: 'var(--secondary)',
					foreground: 'var(--secondary-foreground)'
				},
				accent: {
					DEFAULT: 'var(--accent)',
					foreground: 'var(--accent-foreground)'
				},
				destructive: {
					DEFAULT: 'var(--destructive)',
					foreground: 'var(--destructive-foreground)'
				},
				border: 'var(--color-border)',
				input: 'var(--color-input)',
				ring: 'var(--color-ring)',
				chart: {
					'1': 'var(--color-chart-1)',
					'2': 'var(--color-chart-2)',
					'3': 'var(--color-chart-3)',
					'4': 'var(--color-chart-4)',
					'5': 'var(--color-chart-5)'
				}
			},
			borderRadius: {
				lg: 'var(--radius)',
				md: 'calc(var(--radius) - 2px)',
				sm: 'calc(var(--radius) - 4px)'
			}
		}
	},
	plugins: [],
} satisfies Config;
