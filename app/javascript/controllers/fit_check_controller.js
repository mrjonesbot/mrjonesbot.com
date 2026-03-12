import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit", "submitText", "result"]

  submit(event) {
    const text = this.textareaTarget.value.trim()
    if (text.length < 50) {
      event.preventDefault()
      return
    }

    this.submitTarget.disabled = true
    this.submitTextTarget.textContent = "Analyzing..."
  }

  resultTargetConnected() {
    this.submitTarget.disabled = false
    this.submitTextTarget.textContent = "Check Fit"
  }

  export() {
    const resultEl = this.resultTarget.querySelector(".markdown-content")
    if (!resultEl) return

    const text = resultEl.innerText
    const blob = new Blob([text], { type: "text/plain" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "fit-check.txt"
    a.click()
    URL.revokeObjectURL(url)
  }
}
