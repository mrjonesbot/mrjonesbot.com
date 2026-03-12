import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit", "submitText"]

  submit(event) {
    const text = this.textareaTarget.value.trim()
    if (text.length < 50) {
      event.preventDefault()
      return
    }

    this.submitTarget.disabled = true
    this.submitTextTarget.textContent = "Analyzing..."
  }
}
