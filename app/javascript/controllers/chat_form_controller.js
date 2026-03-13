import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages"]

  connect() {
    this.scrollToBottomIfNeeded()
    this.observeMessages()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  observeMessages() {
    if (!this.hasMessagesTarget) return

    this.observer = new MutationObserver(() => {
      if (this.isNearBottom()) {
        this.scrollToBottom()
      }
    })

    this.observer.observe(this.messagesTarget, {
      childList: true,
      subtree: true,
      characterData: true
    })
  }

  isNearBottom() {
    if (!this.hasMessagesTarget) return true
    const { scrollTop, scrollHeight, clientHeight } = this.messagesTarget
    return (scrollHeight - scrollTop - clientHeight) < 150
  }

  scrollToBottomIfNeeded() {
    if (this.hasMessagesTarget) {
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
