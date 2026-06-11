// Mobile sidebar toggle
document.addEventListener('DOMContentLoaded', function () {
  const hamburger = document.getElementById('hamburger');
  const sidebar = document.getElementById('sidebar');
  const overlay = document.getElementById('sidebar-overlay');

  if (!hamburger) return;

  function openSidebar() {
    sidebar.classList.add('open');
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeSidebar() {
    sidebar.classList.remove('open');
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  hamburger.addEventListener('click', openSidebar);
  overlay.addEventListener('click', closeSidebar);

  // Mark active links
  const path = window.location.pathname;
  const links = document.querySelectorAll('.sidebar-nav a');
  links.forEach(function (link) {
    const href = link.getAttribute('href');
    if (href && path.includes(href) && href !== '../index.html' && href !== 'index.html') {
      link.classList.add('active');
    }
  });
});
