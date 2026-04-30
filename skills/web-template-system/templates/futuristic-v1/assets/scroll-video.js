/* ============================================================
   Humanio — futuristic-v1
   Scroll-scrubbed hero video (desktop, fine pointer)
   Mobile / coarse pointer / reduced-motion → autoplay loop
   ============================================================ */
(function () {
  'use strict';

  var root = document.documentElement;
  var prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var coarse = window.matchMedia('(pointer: coarse)').matches;
  var smallScreen = window.innerWidth < 880;

  function updateScrollProgress() {
    var max = Math.max(document.body.scrollHeight - window.innerHeight, 1);
    var progress = Math.min(Math.max(window.scrollY / max, 0), 1);
    root.style.setProperty('--scroll-progress', progress.toFixed(4));
  }

  updateScrollProgress();
  window.addEventListener('scroll', updateScrollProgress, { passive: true });
  window.addEventListener('resize', updateScrollProgress);

  if (!prefersReduced && !coarse) {
    document.body.classList.add('has-pointer');
    window.addEventListener('pointermove', function (event) {
      root.style.setProperty('--cursor-x', event.clientX + 'px');
      root.style.setProperty('--cursor-y', event.clientY + 'px');
    }, { passive: true });

    document.querySelectorAll('.card, .pkg').forEach(function (el) {
      el.addEventListener('pointermove', function (event) {
        var rect = el.getBoundingClientRect();
        el.style.setProperty('--card-x', (event.clientX - rect.left) + 'px');
        el.style.setProperty('--card-y', (event.clientY - rect.top) + 'px');
      });
    });
  }

  var revealTargets = document.querySelectorAll('section, .stats, .diagnostic, .card, .pkg, .metric, .section-block, .final-cta');
  revealTargets.forEach(function (el) { el.setAttribute('data-reveal', ''); });

  if ('IntersectionObserver' in window && !prefersReduced) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });
    revealTargets.forEach(function (el) { observer.observe(el); });
  } else {
    revealTargets.forEach(function (el) { el.classList.add('is-visible'); });
  }

  var video = document.querySelector('.hero__video');
  if (!video) return;

  // Mobile / coarse / reduced-motion → simple autoplay loop, no scrub
  if (prefersReduced || coarse || smallScreen) {
    video.setAttribute('loop', '');
    video.setAttribute('autoplay', '');
    video.muted = true;
    video.playsInline = true;
    video.play().catch(function () { /* autoplay blocked, ignore */ });
    return;
  }

  // Desktop: scroll-scrub
  // Strategy: precompute hero height, map scrollY in [0..heroHeight] to currentTime in [0..duration]
  video.removeAttribute('autoplay');
  video.removeAttribute('loop');
  video.muted = true;
  video.playsInline = true;
  video.pause();

  var hero = document.querySelector('.hero');
  if (!hero) return;

  var ticking = false;
  var lastTime = 0;
  var SCROLL_RANGE_VH = 1.4; // span 140% of hero height for the scrub

  function onScroll() {
    if (!ticking) {
      window.requestAnimationFrame(updateVideo);
      ticking = true;
    }
  }

  function updateVideo() {
    if (!isFinite(video.duration) || video.duration <= 0) { ticking = false; return; }
    var heroHeight = hero.offsetHeight;
    var scrollRange = heroHeight * SCROLL_RANGE_VH;
    var progress = Math.min(Math.max(window.scrollY / scrollRange, 0), 1);
    var target = progress * (video.duration - 0.01);
    // Avoid jitter: only update on meaningful change
    if (Math.abs(target - lastTime) > 0.02) {
      try { video.currentTime = target; } catch (_) {}
      lastTime = target;
    }
    ticking = false;
  }

  function init() {
    if (!isFinite(video.duration) || video.duration <= 0) {
      video.addEventListener('loadedmetadata', init, { once: true });
      return;
    }
    updateVideo();
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
  }

  if (video.readyState >= 1) init();
  else video.addEventListener('loadedmetadata', init, { once: true });
})();
