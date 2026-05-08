const API_BASE = '../backend/';

async function apiRequest(endpoint, options = {}) {
  const response = await fetch(API_BASE + endpoint, {
    credentials: 'same-origin',
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
    ...options,
  });

  const text = await response.text();
  let data = {};
  try {
    data = text ? JSON.parse(text) : {};
  } catch (error) {
    throw new Error('Server returned invalid JSON. Check PHP/XAMPP errors.');
  }

  if (!response.ok || data.success === false) {
    throw new Error(data.error || 'Request failed.');
  }

  return data;
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  }[char]));
}

function initials(name) {
  const parts = String(name || 'User').trim().split(/\s+/).filter(Boolean);
  return (parts[0]?.[0] || 'U').toUpperCase() + (parts[1]?.[0] || '').toUpperCase();
}

function setText(selector, text) {
  const el = document.querySelector(selector);
  if (el) el.textContent = text;
}

function skillTags(skills = []) {
  return skills.map(skill =>
    `<span class="skill-tag ${escapeHtml(skill.category || 'default')}">${escapeHtml(skill.name || skill.skill_name)}</span>`
  ).join('');
}

function statusLabel(status) {
  return {
    pending: 'Pending Review',
    shortlisted: 'Shortlisted',
    rejected: 'Not Selected',
    interview_scheduled: 'Interview Scheduled',
  }[status] || status;
}

function statusClass(status) {
  return {
    pending: 'badge-pending',
    shortlisted: 'badge-shortlisted',
    rejected: 'badge-rejected',
    interview_scheduled: 'badge-interview',
    open: 'badge-open',
    closed: 'badge-closed',
  }[status] || 'badge-pending';
}

async function requireCurrentUser(expectedType = null) {
  try {
    const { user } = await apiRequest('me.php');
    if (expectedType && user.user_type !== expectedType) {
      window.location.href = user.user_type === 'employer' ? 'dashboard_employer.html' : 'dashboard_candidate.html';
      return null;
    }
    applyUserToShell(user);
    return user;
  } catch (error) {
    window.location.href = 'login.html';
    return null;
  }
}

function applyUserToShell(user) {
  const name = user.name || user.email || 'User';
  document.querySelectorAll('.sidebar-user-name').forEach(el => { el.textContent = name; });
  document.querySelectorAll('.sidebar-user-role').forEach(el => { el.textContent = user.user_type === 'employer' ? 'Employer' : 'Candidate'; });
  document.querySelectorAll('.sidebar-avatar').forEach(el => {
    if (el.textContent.trim().length <= 2) {
      el.textContent = initials(name);
    }
  });
}

async function logout(event) {
  if (event) event.preventDefault();
  try {
    await apiRequest('logout.php', { method: 'POST', body: '{}' });
  } finally {
    window.location.href = 'login.html';
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('a[href="login.html"]').forEach(link => {
    if (link.textContent.toLowerCase().includes('log out')) {
      link.addEventListener('click', logout);
    }
  });
});
