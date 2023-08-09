import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static get targets() {
		return ["sideNav"]
	}
	
	showMenu() {
		console.log("works")
		this.sideNavTarget.style.right = "0"
	}
	
	hideMenu() {
		console.log("asd")
		this.sideNavTarget.style.right = "100vw"
	}
}
