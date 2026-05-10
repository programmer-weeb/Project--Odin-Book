import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { currentUserId: Number }

  connect() {
    this.refresh()
    this.boundRefresh = () => requestAnimationFrame(() => this.refresh())
    document.addEventListener("turbo:before-stream-render", this.boundRefresh)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.boundRefresh)
  }

  refresh() {
    this.element.querySelectorAll("[data-comment-user-id]").forEach((a) => {
      const cu = Number(a.dataset.commentUserId)
      const pu = Number(a.dataset.postUserId)
      if (cu === this.currentUserIdValue || pu === this.currentUserIdValue) {
        a.querySelector(".comment-delete-form")?.classList.remove("hidden")
      }
    })
  }
}
