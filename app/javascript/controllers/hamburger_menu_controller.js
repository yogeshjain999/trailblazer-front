import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static get targets() {
			return ["hamburgerIcon", "navbar", "navList"]
	}

	click(event) {
	    this.hamburgerIconTarget.classList.toggle("hamburger-toggle");
	    this.navbarTarget.classList.toggle("active-mobile-navbar");
	    this.navListTarget.classList.toggle("hidden");
	}
}
