import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    this.scrollToBottomIfNeeded()
  }

  scrollToBottomIfNeeded() {
    if (this.hasMessagesTarget) {
      // Only scroll to bottom when there are actual chat messages (not just the empty state)
      const isEmptyState = this.messagesTarget.querySelector('#chat_empty_state')
      if (!isEmptyState) {
        this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
      }
    }
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

    // Clear input after Turbo has captured form data
    requestAnimationFrame(() => {
      this.inputTarget.value = ""
    })

    // Scroll to bottom after a short delay
    setTimeout(() => this.scrollToBottom(), 100)

    // Let Turbo handle the actual form submission
  }

  messagesTargetConnected() {
    this.scrollToBottomIfNeeded()
  }
}
