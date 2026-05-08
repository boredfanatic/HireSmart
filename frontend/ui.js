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
  showToast(`${label} is a frontend demo right now. Backend wiring is still pending.`, 'info');
}

function markNotificationButton(button) {
  const count = button.querySelector('.notification-dot');
  if (count) count.remove();
  showToast('No new notifications in this demo.', 'info');
}

function checkBootstrapIcons() {
  const probe = document.createElement('i');
  probe.className = 'bi bi-check';
  probe.style.position = 'absolute';
  probe.style.opacity = '0';
  probe.style.pointerEvents = 'none';
  document.body.appendChild(probe);

  const fontFamily = getComputedStyle(probe).fontFamily || '';
  const loaded = fontFamily.toLowerCase().includes('bootstrap-icons');
  probe.remove();

  if (!loaded) {
    document.documentElement.classList.add('icons-missing');
    showToast('Bootstrap Icons did not load. Check internet/CDN access or vendor the icon CSS locally.', 'warning');
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.btn-icon').forEach((button) => {
    if (button.querySelector('.bi-bell') && !button.dataset.boundNotification) {
      button.dataset.boundNotification = 'true';
      button.type = 'button';
      button.title = button.title || 'Notifications';
      button.addEventListener('click', () => markNotificationButton(button));
    }
  });

  checkBootstrapIcons();
});
