/** @type {import('tailwindcss').Config} */
export default {
    content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
    theme: {
        extend: {
            colors: {
                // Primary colors - customize based on DESIGN.md
                primary: {
                    DEFAULT: '#2563eb',
                    hover: '#1d4ed8',
                    light: '#dbeafe',
                },
                secondary: {
                    DEFAULT: '#64748b',
                    hover: '#475569',
                },

                // Background colors
                background: '#f8fafc',
                surface: '#ffffff',

                // Semantic colors
                success: '#22c55e',
                warning: '#f59e0b',
                error: '#ef4444',
                info: '#3b82f6',
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
            },
            borderRadius: {
                'card': '12px',
                'button': '8px',
                'input': '6px',
            },
            boxShadow: {
                'card': '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
                'card-hover': '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
                'elevated': '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
            },
        },
    },
    plugins: [],
}
