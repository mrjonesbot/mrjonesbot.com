import { Controller } from "@hotwired/stimulus"

// Theme controller: respects OS preference, persists user choice in localStorage
export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.initializeTheme()
  }

  initializeTheme() {
    // Check localStorage first, then fall back to OS preference
    const savedTheme = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    if (savedTheme) {
      this.setTheme(savedTheme)
    } else if (prefersDark) {
      this.setTheme("dark")
    } else {
      this.setTheme("light")
    }

    // Listen for OS theme changes (only if user hasn't set a preference)
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
      if (!localStorage.getItem("theme")) {
        this.setTheme(e.matches ? "dark" : "light")
      }
    })
  }

  toggle() {
    const currentTheme = document.documentElement.dataset.theme || "light"
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    this.setTheme(newTheme)
    localStorage.setItem("theme", newTheme)
  }

  setTheme(theme) {
    document.documentElement.dataset.theme = theme
    this.updateToggleButton(theme)
  }

  updateToggleButton(theme) {
    if (this.hasToggleTarget) {
      // Update ARIA label for accessibility
      this.toggleTarget.setAttribute("aria-label", `Switch to ${theme === "dark" ? "light" : "dark"} mode`)

      // Swap icon: sun in dark mode, moon in light mode
      const svg = this.toggleTarget.querySelector("svg")
      if (svg) {
        if (theme === "dark") {
          // Show sun icon (switch to light mode)
          svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>'
        } else {
          // Show moon icon (switch to dark mode)
          svg.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>'
        }
      }
    }
  }
}
