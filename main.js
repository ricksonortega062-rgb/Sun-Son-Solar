document.addEventListener('DOMContentLoaded', function () {
	var toggle = document.getElementById('navToggle');
	var links = document.getElementById('navLinks');

	if (toggle && links) {
		toggle.addEventListener('click', function () {
			var isOpen = links.classList.toggle('is-open');
			toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
		});
	}
});
