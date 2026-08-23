/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#fbf8f0',
          100: '#f5efdc',
          200: '#ebdeba',
          300: '#dec791',
          400: '#d0ac67',
          500: '#c59546', // Ethiopian gold/ochre
          600: '#ad7b38',
          700: '#8a5c2d',
          800: '#714b29',
          900: '#5e3e25',
          950: '#342011',
        },
        forest: {
          50: '#effbf4',
          100: '#d7f7e4',
          200: '#b2edce',
          300: '#7fdeb0',
          400: '#47c58d',
          500: '#22a971', // Ethiopian emerald green
          600: '#15895a',
          700: '#126d4a',
          800: '#11573c',
          900: '#104732',
          950: '#03281b',
        },
        surface: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          800: '#1e293b',
          850: '#172133',
          900: '#0f172a',
          950: '#090d16',
        }
      },
    },
  },
  plugins: [],
};
