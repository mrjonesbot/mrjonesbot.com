import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "input"]
  static values = { question: String }

  open() {
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    // Focus input after a short delay to ensure overlay is visible
    setTimeout(() => {
      if (this.hasInputTarget) {
        this.inputTarget.focus()
      }
    }, 100)
  }

  openWithQuestion(event) {
    const question = event.currentTarget.dataset.chatOverlayQuestionValue
    this.open()

    // Wait for overlay to be visible, then dispatch event with question
    setTimeout(() => {
      this.dispatch("question-selected", { detail: { question } })
    }, 150)
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
