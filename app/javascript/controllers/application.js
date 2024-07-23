import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

Turbo.StreamActions.update_and_scroll_to_bottom = function () {
    const newOrdering = parseInt(this.getAttribute("ordering"));
    for (const targetElement of this.targetElements) {
        const priorOrdering = parseInt(targetElement.getAttribute("ordering"));
        if (newOrdering < priorOrdering) {
            return;
        }
    }

    Turbo.StreamActions.update.call(this);

    this.targetElements.forEach(function (element) {
        const matchingParent = element.closest("[data-scroll-to-bottom-target]");
        if (!matchingParent) {
            return;
        }

        matchingParent.scrollTop = matchingParent.scrollHeight;
        matchingParent.dispatchEvent(new Event("change"));
        matchingParent.setAttribute("ordering", newOrdering);
    });
};


export { application }
