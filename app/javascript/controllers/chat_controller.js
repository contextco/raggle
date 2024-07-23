import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat"
export default class extends Controller {
  static targets = ["scrollContainer"]

  connect() {
      this.scrollContainerTarget.scrollTop = this.scrollContainerTarget.scrollHeight;
  }

  submit(event) {
    event.preventDefault();
    event.currentTarget.requestSubmit();
  }
}
