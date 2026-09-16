// Klinik Kalite mockup'lari - ortak etkilesim.
// Ekranlar/Medula/*.html icindeki sekme betiginin aynisi; uc ekran ayni
// dosyayi okusun diye disari alindi.

// SEKMELER: .sekmeler icindeki .sekme tiklaninca ayni kapsamdaki .pnl panelleri
//   degisir. Eslesme data-s anahtariyla, yoksa sira numarasiyla. Ic ice
//   sekmeler desteklenir (panel kendi kapsamini filtreler).
document.querySelectorAll('.sekmeler').forEach(function (bar) {
  var tabs = [].slice.call(bar.querySelectorAll('.sekme'));
  var scope = bar.parentElement;
  var pnls = [].slice.call(scope.querySelectorAll('.pnl')).filter(function (p) {
    return p.parentElement.closest('.pnl') === scope.closest('.pnl');
  });
  function key(el, i) { return el.dataset.s || String(i); }
  function goster(k) { pnls.forEach(function (p, j) { p.hidden = (key(p, j) !== k); }); }
  tabs.forEach(function (t, i) {
    t.style.cursor = 'pointer';
    t.addEventListener('click', function () {
      tabs.forEach(function (x) { x.classList.remove('on'); });
      t.classList.add('on');
      goster(key(t, i));
    });
  });
  var on = tabs.findIndex(function (t) { return t.classList.contains('on'); });
  if (on < 0) on = 0;
  if (pnls.length) goster(key(tabs[on], on));
});

// CIPLER: tek secim, gorsel.
document.querySelectorAll('.arama').forEach(function (bar) {
  var cips = [].slice.call(bar.querySelectorAll('.chip'));
  cips.forEach(function (c) {
    c.addEventListener('click', function () {
      cips.forEach(function (x) { x.classList.remove('on'); });
      c.classList.add('on');
    });
  });
});

// SOL LISTE: .olgu tiklaninca secilir; data-hedef varsa o panel gosterilir.
document.querySelectorAll('[data-liste]').forEach(function (liste) {
  var ogeler = [].slice.call(liste.querySelectorAll('.olgu'));
  ogeler.forEach(function (o) {
    o.addEventListener('click', function () {
      ogeler.forEach(function (x) { x.classList.remove('on'); });
      o.classList.add('on');
    });
  });
});

// Satir secimi (gorsel).
document.querySelectorAll('.dg tbody').forEach(function (tb) {
  var trs = [].slice.call(tb.querySelectorAll('tr.tik'));
  trs.forEach(function (tr) {
    tr.addEventListener('click', function () {
      trs.forEach(function (x) { x.classList.remove('sel'); });
      tr.classList.add('sel');
    });
  });
});

// data-git="dosya.html" tasiyan her oge o mockup'a gecer.
document.querySelectorAll('[data-git]').forEach(function (b) {
  b.style.cursor = 'pointer';
  b.addEventListener('click', function () { location.href = b.dataset.git; });
});
