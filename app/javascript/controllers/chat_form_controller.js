import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    this.scrollToBottom()

    // Listen for suggested questions
    this.element.addEventListener("chat-overlay:question-selected", (event) => {
      this.inputTarget.value = event.detail.question
      this.inputTarget.focus()
    })
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  submit(event) {
    // Prevent default form submission
    event.preventDefault()

    const message = this.inputTarget.value.trim()
    if (!message) return

    // Clear input immediately for better UX
    this.inputTarget.value = ""

    // Form will submit via Turbo
    event.target.requestSubmit()

    // Scroll to bottom after a short delay
    setTimeout(() => this.scrollToBottom(), 100)
  }

  messagesTargetConnected() {
    this.scrollToBottom()
  }
}
