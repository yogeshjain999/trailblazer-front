let showMobileMenu = () => {
	hamburgerIcon.classList.toggle("hamburger-toggle");
	navbar.classList.toggle("active-mobile-navbar");
	navList.classList.toggle("hidden");
}

let showSideMenu = () => {
	sideNav.style.right = "0"
}

let hideSideMenu = () => {
	sideNav.style.right = "100vw"
}

let hamburgerIcon = document.querySelector("#hamburgerIcon")
let navbar = document.querySelector("#navbar")
let navList = document.querySelector("#navList")
let sideNav = document.querySelector("#sideNav")
let sideNavHideButton = document.querySelector("#sideNavHideButton")
let sideNavShowButton = document.querySelector("#sideNavShowButton")

hamburgerIcon.addEventListener("click", showMobileMenu);
sideNavHideButton.addEventListener("click", hideSideMenu);
sideNavShowButton.addEventListener("click", showSideMenu);
