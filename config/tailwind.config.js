const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}"
  ],
  theme: {
    colors: {
      "text": "#211B3F",
      "blue": "#140F3F",
      "purple": "#582ABB",
      "selected": "#4D4499",
      "bg-purple-1": "#AEAAF7",
      "bg-purple-2": "#D6D4FB",
      "light-purple": "#C5C0F5",
      "violet": "#5A1B4D",
      "magenta": "#E72456",
      "red": "#E72F2B",
      "orange": "#EC651A",
      "grey": "#989CAA",
      "light-grey": "#F1F1F1",
      "light-bg": "#FEFEFE",
      "white": "#FFFFFF"

    },
    fontFamily: {
      sans: ["Open Sauce Sans", "sans-serif"]
    },
    fontSize: {
      "xs": ["0.75rem", { lineHeight: "1rem" }],
      "sm": ["0.875rem", { lineHeight: "1.25rem" }],
      "base": ["17px", { lineHeight: "20px" }],
      "lg": ["1.125rem", { lineHeight: "1.75rem" }],
      "xl": ["1.25rem", { lineHeight: "1.75rem" }],
      "2xl": ["1.5rem", { lineHeight: "2rem" }],
      "3xl": ["1.875rem", { lineHeight: "2.25rem" }],
      "4xl": ["2.25rem", { lineHeight: "2.5rem" }],
      "5xl": ["3rem", { lineHeight: "1" }],
      "6xl": ["3.75rem", { lineHeight: "1" }],
      "7xl": ["4.5rem", { lineHeight: "1" }],
      "8xl": ["6rem", { lineHeight: "1" }],
      "9xl": ["8rem", { lineHeight: "1" }],
    },
    borderRadius: {
      'none': '0',
      DEFAULT: '10px',
      'md': '0.375rem',
      'lg': '0.5rem',
      'xl': '0.75rem',
      'xxl': '1.25rem',
      '3xl': '1.5rem',
      'full': '9999px'
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ]
}
