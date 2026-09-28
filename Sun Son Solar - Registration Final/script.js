/* Sun Son Solar — all site JavaScript in one file.
   Each section only runs on the page that has its elements. */

document.addEventListener('DOMContentLoaded', function () {
    initRegisterForm();
    initHomePage();
    initDashboard();
});

/* ---------- Register pages (customer + employee) ---------- */
function initRegisterForm() {
    var form = document.querySelector('form[data-redirect]');
    var box = document.getElementById('formMessage');
    if (!form || !box) return;

    form.addEventListener('submit', function (e) {
        e.preventDefault();
        var d = {};
        new FormData(form).forEach(function (v, k) { d[k] = String(v).trim(); });
        var errors = [];

        form.querySelectorAll('[required]').forEach(function (f) {
            if (!f.value.trim()) {
                var label = f.closest('label').firstChild.textContent.trim();
                errors.push(label + ' is required.');
            }
        });
        if (d.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(d.email)) errors.push('Enter a valid email address.');
        if (d.username && d.username.length < 5) errors.push('Username must be at least 5 characters.');
        if (d.password && d.password.length < 8) errors.push('Password must be at least 8 characters.');
        if (d.password !== d.confirm_password) errors.push('Passwords do not match.');

        if (errors.length) {
            box.textContent = errors.join('\n');
            box.hidden = false;
            box.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return;
        }
        box.hidden = true;

        // TODO: send `d` to the CodeIgniter register endpoint here, then redirect on success.

        sessionStorage.setItem('ssUser', JSON.stringify({
            name: d.first_name + ' ' + d.last_name,
            role: form.dataset.role,
            department: d.department || ''
        }));
        window.location.href = form.dataset.redirect;
    });
}

/* ---------- Home page ---------- */
function initHomePage() {
    var year = document.getElementById('year');
    if (year) year.textContent = new Date().getFullYear();

    var navUser = document.getElementById('navUser');
    var navCta = document.getElementById('navCta');
    if (!navUser || !navCta) return;

    try {
        var user = JSON.parse(sessionStorage.getItem('ssUser'));
        if (user && user.name) {
            navUser.textContent = 'Hi, ' + user.name.split(' ')[0];
            navCta.hidden = true;
        }
    } catch (e) {}
}

/* ---------- Admin dashboard ---------- */
function initDashboard() {
    var btn = document.getElementById('timeInBtn');
    if (!btn) return;

    var user = null;
    try { user = JSON.parse(sessionStorage.getItem('ssUser')); } catch (e) {}
    var name = (user && user.name) || 'Employee';

    document.getElementById('userName').textContent = name;
    document.getElementById('userRole').textContent = (user && user.department) || 'Sun Son Solar';
    if (user && user.name) document.getElementById('welcomeName').textContent = ', ' + user.name.split(' ')[0];

    document.getElementById('logout').addEventListener('click', function () {
        sessionStorage.removeItem('ssUser');
    });

    var status = document.getElementById('timeInStatus');
    var body = document.getElementById('logBody');
    var count = 0;

    function setStatus(msg, cls) {
        status.textContent = msg;
        status.className = 'timein-page__status ' + (cls || '');
    }

    btn.addEventListener('click', function () {
        if (!navigator.geolocation) {
            setStatus('Your phone or browser cannot share location.', 'is-error');
            return;
        }
        btn.disabled = true;
        setStatus('Getting your location…');

        navigator.geolocation.getCurrentPosition(function (pos) {
            var lat = pos.coords.latitude.toFixed(7);
            var lng = pos.coords.longitude.toFixed(7);
            var now = new Date();

            // TODO: POST { name, lat, lng } to the CodeIgniter time-in endpoint (saves to time_logs).

            if (count === 0) body.innerHTML = '';
            count++;
            document.getElementById('todayCount').textContent = count;

            var tr = document.createElement('tr');
            [name, now.toLocaleString(), lat + ', ' + lng].forEach(function (text) {
                var td = document.createElement('td');
                td.textContent = text;
                tr.appendChild(td);
            });
            body.insertBefore(tr, body.firstChild);

            setStatus('Time in recorded at ' + now.toLocaleTimeString() + '. Thank you, ' + name.split(' ')[0] + '!', 'is-success');
            btn.disabled = false;
        }, function () {
            setStatus('We could not get your location. Please allow location access and try again.', 'is-error');
            btn.disabled = false;
        }, { enableHighAccuracy: true, timeout: 15000 });
    });
}
