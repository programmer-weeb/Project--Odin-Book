import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  show() {
    const file = this.inputTarget.files[0]
    if (!file) return
    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.classList.remove("hidden")
  }
}
