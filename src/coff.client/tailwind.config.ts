import type { Config } from "tailwindcss";

export default {
	content: [
		"./pages/**/*.{js,ts,jsx,tsx,mdx}",
		"./components/**/*.{js,ts,jsx,tsx,mdx}",
		"./app/**/*.{js,ts,jsx,tsx,mdx}",
	],
	theme: {
		extend: {
			colors: {
				// Brand palette (shades for brand usage across the app)
				brand: {
					mint: {
						50: '#F7FFFE',
						100: '#EAFDFD',
						200: '#CBF3F0',
						300: '#8DE2D5',
						400: '#2EC4B6',
						500: '#2EC4B6',
						600: '#27AB99',
						700: '#198F7F'
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
