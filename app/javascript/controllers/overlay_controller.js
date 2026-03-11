import { Controller } from "@hotwired/stimulus"

// Provides accessibility features for slide-over overlays:
// - Escape key to close
// - Focus trap (tab cycles within overlay)
// - Focus management (restore focus on close)
// - Backdrop click to close
export default class extends Controller {
  static values = { closeUrl: String }

  connect() {
    this.previouslyFocusedElement = document.activeElement
    this.trapFocus()
    this.slideIn()
  }

  disconnect() {
    this.restoreFocus()
  }

  slideIn() {
    // Trigger slide-in animation after connect
    requestAnimationFrame(() => {
      this.element.style.transform = "translateX(0)"
      this.element.style.transition = "transform 0.3s cubic-bezier(0.16, 1, 0.3, 1)"
    })
  }

  backdropClose(event) {
    // Only close if clicking directly on backdrop, not on panel
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  close() {
    // Navigate to close URL via Turbo Frame
    window.Turbo.visit(this.closeUrlValue, { frame: 'overlay' })
  }

  // Keyboard handling
  keydown(event) {
    if (event.key === 'Escape') {
      event.preventDefault()
      this.close()
    } else if (event.key === 'Tab') {
      this.handleTab(event)
    }
  }

  // Focus trap - keep tab within overlay
  handleTab(event) {
    const focusableElements = this.element.querySelectorAll(
      'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'
    )
    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus()
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus()
    }
  }

  trapFocus() {
    // Focus first focusable element
    const firstFocusable = this.element.querySelector(
      'input, textarea, select, button, a[href]'
    )
    if (firstFocusable) {
      setTimeout(() => firstFocusable.focus(), 100)
    }

    // Add keydown listener for focus trap and escape
    this.boundKeydown = this.keydown.bind(this)
    document.addEventListener('keydown', this.boundKeydown)
  }

  restoreFocus() {
    document.removeEventListener('keydown', this.boundKeydown)
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
    }
  }
}
