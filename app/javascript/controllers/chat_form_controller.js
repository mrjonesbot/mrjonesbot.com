import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  submit(event) {
    const message = this.inputTarget.value.trim()
    if (!message) {
      event.preventDefault()
      return
    }

    // Clear input for better UX
    this.inputTarget.value = ""

    // Scroll to bottom after a short delay
    setTimeout(() => this.scrollToBottom(), 100)

    // Let Turbo handle the actual form submission
  }

  messagesTargetConnected() {
    this.scrollToBottom()
  }
}
