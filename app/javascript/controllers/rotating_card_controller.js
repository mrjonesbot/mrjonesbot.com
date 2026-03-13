import { Controller } from "@hotwired/stimulus"

// Rotating card controller: cycles through project cards with smooth transitions
export default class extends Controller {
  static targets = ["card", "progress"]
  static values = {
    interval: { type: Number, default: 5000 }, // 5 seconds
    projects: Array
  }

  connect() {
    this.currentIndex = 0
    this.setupProgressCircle()
    this.startRotation()
  }

  disconnect() {
    this.stopRotation()
    this.stopProgress()
  }

  setupProgressCircle() {
    if (!this.hasProgressTarget) return

    const circle = this.progressTarget
    const radius = circle.r.baseVal.value
    const circumference = radius * 2 * Math.PI

    circle.style.strokeDasharray = `${circumference} ${circumference}`
    circle.style.strokeDashoffset = circumference

    this.circumference = circumference
  }

  startRotation() {
    this.startProgress()
    this.intervalId = setInterval(() => {
      this.rotate()
    }, this.intervalValue)
  }

  stopRotation() {
    if (this.intervalId) {
      clearInterval(this.intervalId)
    }
  }

  startProgress() {
    if (!this.hasProgressTarget) return

    this.startTime = Date.now()
    this.animateProgress()
  }

  stopProgress() {
    if (this.progressAnimationId) {
      cancelAnimationFrame(this.progressAnimationId)
    }
  }

  animateProgress() {
    const elapsed = Date.now() - this.startTime
    const progress = Math.min(elapsed / this.intervalValue, 1)
    const offset = this.circumference - (progress * this.circumference)

    this.progressTarget.style.strokeDashoffset = offset

    if (progress < 1) {
      this.progressAnimationId = requestAnimationFrame(() => this.animateProgress())
    }
  }

  rotate() {
    const currentCard = this.cardTarget

    // Reset progress
    this.stopProgress()
    if (this.hasProgressTarget) {
      this.progressTarget.style.strokeDashoffset = this.circumference
    }

    // Fade out
    currentCard.style.opacity = "0"
    currentCard.style.transform = "translateY(-10px)"

    setTimeout(() => {
      // Update to next project
      this.currentIndex = (this.currentIndex + 1) % this.projectsValue.length
      const nextProject = this.projectsValue[this.currentIndex]

      // Update card content
      const titleElement = currentCard.querySelector("[data-card-title]")
      const descElement = currentCard.querySelector("[data-card-description]")
      const linkElement = currentCard.closest("a")

      if (titleElement) titleElement.textContent = nextProject.name
      if (descElement) descElement.textContent = nextProject.description
      if (linkElement) {
        const hasUrl = nextProject.url && nextProject.url !== "#"
        linkElement.href = hasUrl ? nextProject.url : "javascript:void(0)"
        linkElement.style.cursor = hasUrl ? "pointer" : "default"
      }

      // Reset position and fade in
      currentCard.style.transform = "translateY(10px)"

      setTimeout(() => {
        currentCard.style.opacity = "1"
        currentCard.style.transform = "translateY(0)"
        // Restart progress animation
        this.startProgress()
      }, 50)
    }, 300) // Match transition duration
  }

  // Pause rotation on hover
  pause() {
    this.stopRotation()
    this.stopProgress()
  }

  // Resume rotation on mouse leave
  resume() {
    this.startRotation()
  }
}
