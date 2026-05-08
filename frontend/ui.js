function showToast(message, type = 'info') {
  let stack = document.querySelector('.toast-stack');
  if (!stack) {
    stack = document.createElement('div');
    stack.className = 'toast-stack';
    document.body.appendChild(stack);
  }

  const toast = document.createElement('div');
  toast.className = `app-toast app-toast-${type}`;
  toast.textContent = message;
  stack.appendChild(toast);

  requestAnimationFrame(() => toast.classList.add('show'));
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 200);
  }, 2600);
}

function showComingSoon(label = 'This feature') {
  showToast(`${label} — coming soon.`, 'info');
}

// ── Notification Panel ─────────────────────────────────────────────────────

function _safeHtml(str) {
  return String(str ?? '').replace(/[&<>"']/g, c =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[c])
  );
}

function _getOrCreatePanel() {
  let panel = document.getElementById('hs-notif-panel');
  if (panel) return panel;

  panel = document.createElement('div');
  panel.id = 'hs-notif-panel';
  panel.className = 'hs-notif-panel';
  panel.innerHTML = `
    <div class="hs-notif-head">
      <span class="fw-700">Notifications</span>
      <button type="button" class="hs-notif-close" onclick="closeNotifPanel()">&#x2715;</button>
    </div>
    <div class="hs-notif-body" id="hsNotifBody">
      <div class="hs-notif-empty">Loading…</div>
    </div>`;
  document.body.appendChild(panel);

  // Close when clicking outside
  document.addEventListener('click', (e) => {
    if (!panel.classList.contains('open')) return;
    if (panel.contains(e.target)) return;
    if (e.target.closest('.btn-icon')?.querySelector('.bi-bell')) return;
    closeNotifPanel();
  });

  return panel;
}

function closeNotifPanel() {
  document.getElementById('hs-notif-panel')?.classList.remove('open');
}

function toggleNotifPanel() {
  const panel = _getOrCreatePanel();
  if (panel.classList.contains('open')) {
    closeNotifPanel();
    return;
  }
  panel.classList.add('open');
  _loadNotifPanel();
}

function _loadNotifPanel() {
  const body = document.getElementById('hsNotifBody');
  if (!body) return;
  body.innerHTML = '<div class="hs-notif-empty">Loading…</div>';

  // apiRequest is defined in api.js — always loaded on the same page
  apiRequest('get_notifications.php?all=1')
    .then(data => {
      const list = data.notifications || [];
      if (list.length === 0) {
        body.innerHTML = '<div class="hs-notif-empty">No notifications yet.</div>';
        return;
      }
      body.innerHTML = list.map(n => {
        const time = n.created_at ? n.created_at.slice(0, 16).replace('T', ' ') : '';
        return `
          <div class="hs-notif-item${n.is_read ? '' : ' hs-notif-unread'}">
            <div class="hs-notif-msg">${_safeHtml(n.message)}</div>
            <div class="hs-notif-time">${_safeHtml(time)}</div>
          </div>`;
      }).join('');
    })
    .catch(() => {
      body.innerHTML = '<div class="hs-notif-empty">Could not load notifications.</div>';
    });
}

// ── Bootstrap Icons check ──────────────────────────────────────────────────

function checkBootstrapIcons() {
  (document.fonts ? document.fonts.ready : Promise.resolve()).then(() => {
    const probe = document.createElement('i');
    probe.className = 'bi bi-check';
    probe.style.cssText = 'position:absolute;opacity:0;pointer-events:none;';
    document.body.appendChild(probe);
    // Bootstrap Icons sets font-family on ::before, not the element itself.
    const loaded = getComputedStyle(probe, '::before').fontFamily.toLowerCase().includes('bootstrap-icons');
    probe.remove();
    if (!loaded) {
      document.documentElement.classList.add('icons-missing');
      showToast('Bootstrap Icons did not load — check your internet connection.', 'warning');
    }
  });
}

// ── Wire up bell buttons and log-out links ─────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  // Bell buttons → notification panel
  document.querySelectorAll('.btn-icon').forEach((button) => {
    if (button.querySelector('.bi-bell') && !button.dataset.boundNotification) {
      button.dataset.boundNotification = 'true';
      button.type = 'button';
      button.title = button.title || 'Notifications';
      button.addEventListener('click', toggleNotifPanel);
    }
  });

  checkBootstrapIcons();
});
