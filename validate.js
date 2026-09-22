document.addEventListener('DOMContentLoaded', function () {
	var form = document.getElementById('customerForm') || document.getElementById('employeeForm');
	if (! form) return;

	var messageBox = document.getElementById('formMessage');

	function showMessage(text) {
		messageBox.textContent = text;
		messageBox.hidden = false;
	}

	function hideMessage() {
		messageBox.hidden = true;
	}

	form.addEventListener('submit', function (e) {
		e.preventDefault();
		hideMessage();

		if (! form.checkValidity()) {
			form.reportValidity();
			return;
		}

		var password = form.querySelector('[name="password"]').value;
		var confirm = form.querySelector('[name="confirm_password"]').value;

		if (password !== confirm) {
			showMessage('Password and Confirm Password do not match.');
			return;
		}

		// No backend wired up yet — this is where a fetch()/AJAX call
		// (or a normal <form action="..."> submit) would send the data.
		var formData = new FormData(form);
		var entries = {};
		formData.forEach(function (value, key) { entries[key] = value; });
		console.log('Form is valid. Data ready to send:', entries);

		messageBox.classList.remove('alert--error');
		messageBox.classList.add('alert--success');
		showMessage('Looks good! (No backend connected yet — this is a front-end-only form.)');
	});
});
