import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="application"
export default class extends Controller {

    navigate(event) {
        event.preventDefault();
        console.log(event)
        Turbo.visit(event.params.location);
    }
}
