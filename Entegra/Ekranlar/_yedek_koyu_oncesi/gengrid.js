/* ============================================================================
   GenGrid — Gentegre AI ortak grid sarmalayıcısı
   ----------------------------------------------------------------------------
   Amaç: ekranlar grid kütüphanesini doğrudan çağırmaz; hepsi bu arayüzü kullanır.
   Bugün içi kendi kodumuz; yarın DevExtreme ya da AG Grid'e geçilirse
   ekranlar değil yalnız bu dosya değişir.

   İlk kolon HER ZAMAN onay kutusudur — kural, seçenek değil.

   GenGrid(kap, {
     kolonlar:[{alan,ad,tip,gen,hiza,gizli,sabit,bicim(v,r),sinif(v,r),siralanabilir,filtrelenebilir}],
     veri:[...], anahtar:'id',
     detay:(r)=>HTML | null,          // master-detail
     detayVar:(r)=>bool,
     secimDegisti:(secililer)=>{},
     satirSinifi:(r)=>'',
     ustBilgi:'…'
   })
   tip: 'metin' | 'sayi' | 'tutar' | 'tarih' | 'rozet'
   ========================================================================== */
(function(){
if (window.GenGrid) return;

/* ---------------------------------------------------------------- yardımcı */
var TRC = new Intl.Collator('tr', {numeric:true, sensitivity:'base'});
function norm(s){
  return (s == null ? '' : '' + s).toLocaleLowerCase('tr')
    .replace(/İ/g,'i').replace(/I/g,'ı').trim();
}
function trh(s){
  var p = ('' + (s||'')).split('.');
  return p.length === 3 ? new Date(+p[2], +p[1]-1, +p[0]).getTime() : NaN;
}
function sayi(v){
  if (typeof v === 'number') return v;
  var m = ('' + (v||'')).replace(/[^\d,.-]/g,'').replace(/\./g,'').replace(',','.');
  return parseFloat(m);
}
function para(x){
  return (+x||0).toLocaleString('tr-TR',{minimumFractionDigits:2, maximumFractionDigits:2});
}
function el(t,c,h){ var d=document.createElement(t); if(c)d.className=c; if(h!=null)d.innerHTML=h; return d; }

/* ------------------------------------------------------------------ stil */
function stilKur(){
  if (document.getElementById('genGridCss')) return;
  var s = el('style'); s.id = 'genGridCss';
  s.textContent = [
  '.gg{border:1px solid var(--line,#cdd6e0);border-radius:3px;background:#fff;overflow:auto}',
  '.gg table{border-collapse:collapse;width:100%}',
  '.gg thead tr:first-child th:last-child{padding-right:86px}',
  '.gg th{background:linear-gradient(#f4f7fb,#e7eef6);border-bottom:1px solid var(--line,#cdd6e0);',
  '  border-right:1px solid var(--line2,#e3e9f0);text-align:left;padding:5px 7px;font-size:11px;',
  '  color:#3a5573;font-weight:bold;white-space:nowrap;position:relative;user-select:none}',
  '.gg th.sir{cursor:pointer}.gg th.sir:hover{background:linear-gradient(#eaf2fb,#dde8f5)}',
  '.gg th .ok{font-size:9px;margin-left:4px;color:#2f6db3}',
  '.gg th .sn{font-size:8.5px;background:#2f6db3;color:#fff;border-radius:6px;padding:0 4px;margin-left:3px}',
  '.gg td{border-bottom:1px solid var(--line2,#e3e9f0);border-right:1px solid #eef2f6;',
  '  padding:4px 7px;font-size:11.5px;white-space:nowrap}',
  '.gg.yog-sik td{padding:1px 6px!important;font-size:11px!important;line-height:1.35}',
  '.gg.yog-sik td .bar{display:none}',
  '.gg.yog-genis td{padding:9px 8px!important;line-height:1.6}',
  '.gg.sigdir table{width:auto;min-width:100%}',
  '.gg.sigdir th{width:auto!important}',
  '.gg td.sag{text-align:right;font-family:"Segoe UI",Tahoma}',
  '.gg td.ort,.gg th.ort{text-align:center}',
  '.gg tr.gsec td{background:#d7e7fb!important}',
  '.gg tr.foc td{box-shadow:inset 0 0 0 1px #98c2ee}',
  '.gg tbody tr:hover td{filter:brightness(.985)}',
  '.gg tfoot td{background:linear-gradient(#eef4fa,#e2eaf3);border-top:1px solid var(--line,#cdd6e0);',
  '  font-weight:bold;color:#14315a}',
  /* onay kutusu */
  '.gg th.cbk,.gg td.cbk{width:30px;text-align:center;padding:2px 0}',
  '.ggcb{width:14px;height:14px;border:1px solid #90a4b8;border-radius:3px;background:#fff;',
  '  display:inline-block;position:relative;cursor:pointer;vertical-align:-2px}',
  '.ggcb.on{background:#2f6db3;border-color:#2f6db3}',
  '.ggcb.on::after{content:"";position:absolute;left:4px;top:1px;width:4px;height:8px;',
  '  border:solid #fff;border-width:0 2px 2px 0;transform:rotate(42deg)}',
  '.ggcb.yari{background:#2f6db3;border-color:#2f6db3}',
  '.ggcb.yari::after{content:"";position:absolute;left:2px;top:5px;width:8px;height:2px;background:#fff}',
  /* aç/kapa */
  '.gg th.ack,.gg td.ack{width:24px;text-align:center;padding:2px 0}',
  '.ggac{width:18px;height:18px;border:1px solid #b9c6d4;border-radius:3px;background:#fff;',
  '  display:inline-flex;align-items:center;justify-content:center;cursor:pointer;font-size:10px;color:#3a5573}',
  '.ggac:hover{background:#e6f0fb}.ggac.yok{opacity:.22;cursor:default}',
  '.gg tr.detay>td{padding:0!important;background:#f7fafd!important;border-bottom:2px solid var(--line,#cdd6e0)!important}',
  /* filtre satırı */
  '.gg tr.flt th{padding:2px 3px;background:#f8fbfe}',
  '.gg tr.flt input,.gg tr.flt select{width:100%;border:1px solid #cdd6e0;border-radius:2px;height:21px;',
  '  font-size:11px;padding:0 4px;font-family:inherit;background:#fff}',
  '.gg tr.flt input:focus{border-color:#2f6db3;outline:none}',
  '.gg tr.flt .op{width:26px;border:1px solid #cdd6e0;background:#eef3f8;border-radius:2px;height:21px;',
  '  font-size:10px;cursor:pointer;color:#3a5573;padding:0}',
  '.gg tr.flt .kut{display:flex;gap:2px}',
  /* grid kapsayıcı + sağ üst köşe menüsü */
  '.ggkap{position:relative}',
  '.ggkose{position:absolute;right:0;top:0;z-index:5;height:27px;display:flex;align-items:center;',
  '  gap:0;background:linear-gradient(#f4f7fb,#e7eef6);border-left:1px solid #cdd6e0;',
  '  border-bottom:1px solid #cdd6e0;border-radius:0 3px 0 0}',
  '.ggkose .dgm{width:26px;height:27px;display:flex;align-items:center;justify-content:center;',
  '  cursor:pointer;font-size:13px;color:#3a5573;user-select:none;position:relative;',
  '  border-left:1px solid #dbe4ee}',
  '.ggkose .dgm:first-child{border-left:0}',
  '.ggkose .dgm:hover{background:#dbe8f7;color:#14315a}',
  '.ggkose .dgm.etkin{color:#1f5391;background:#dbe8f7;font-weight:bold}',
  '.ggkose .dgm .nk{position:absolute;top:3px;right:3px;width:6px;height:6px;border-radius:50%;background:#d8a013}',
  /* kabuk içinde grid menüsünün girişi üstteki "Grid" düğmesidir; köşe şeridi gizlenir */
  'body.gomulu .ggkose{display:none!important}',
  'body.gomulu .gg thead tr:first-child th:last-child{padding-right:7px}',
  /* sayfalama + 10 satırlık görüntü penceresi */
  '.gg{max-height:none}',
  '.gg thead th{position:sticky;top:0;z-index:3}',
  '.gg tr.flt th{position:sticky;z-index:3}',
  '.gg tfoot td{position:sticky;bottom:0;z-index:2}',
  '.ggsyf{display:flex;align-items:center;gap:8px;padding:5px 8px;border:1px solid var(--line,#cdd6e0);',
  '  border-top:0;border-radius:0 0 3px 3px;background:linear-gradient(#f7fafd,#eef3f8);font-size:11px;color:#4a5a6e}',
  '.ggsyf .sy{display:flex;align-items:center;gap:2px}',
  '.ggsyf .sb{min-width:23px;height:22px;border:1px solid #cdd6e0;background:#fff;border-radius:3px;',
  '  display:inline-flex;align-items:center;justify-content:center;cursor:pointer;color:#3a5573;padding:0 5px}',
  '.ggsyf .sb:hover{border-color:#2f6db3;background:#eaf2fb}',
  '.ggsyf .sb.on{background:#2f6db3;border-color:#1f5391;color:#fff;font-weight:bold}',
  '.ggsyf .sb.pas{opacity:.35;cursor:default}',
  '.ggsyf .sb.pas:hover{border-color:#cdd6e0;background:#fff}',
  '.ggsyf select{height:22px;border:1px solid #cdd6e0;border-radius:3px;background:#fff;',
  '  font-size:11px;font-family:inherit;color:#3a5573;padding:0 3px}',
  '.ggsyf .bg{margin-left:auto;color:#667085}',
  '.ggsyf .bg b{color:#14315a}',
  '.ggser .tmz2{margin-left:8px;color:#1f5391;text-decoration:underline;cursor:pointer}',
  '.ggb{border:1px solid #cdd6e0;background:linear-gradient(#fff,#eef3f8);border-radius:3px;',
  '  padding:3px 9px;font-size:11px;cursor:pointer;white-space:nowrap;font-family:inherit}',
  '.ggb:hover{border-color:#98c2ee;background:linear-gradient(#fff,#dce8f6)}',
  '.ggmenu{position:fixed;z-index:9999;min-width:250px;background:#fff;border:1px solid #b9c6d4;',
  '  max-height:calc(100vh - 16px);overflow-y:auto;overscroll-behavior:contain;',
  '  border-radius:5px;box-shadow:0 12px 34px rgba(20,40,70,.24);padding:4px;display:none;',
  '  font:12px "Segoe UI",Tahoma,sans-serif;color:#1f2d3a}',
  '.ggmenu.on{display:block}',
  '.ggmenu .bs2{font-size:10px;text-transform:uppercase;letter-spacing:.4px;color:#8296ab;',
  '  padding:6px 9px 3px;font-weight:bold}',
  '.ggmenu .og{display:flex;align-items:center;gap:9px;padding:5px 9px;border-radius:3px;cursor:pointer}',
  '.ggmenu .og:hover{background:#e6f0fb}',
  '.ggmenu .og.pas2{color:#a9b4c0;cursor:default}.ggmenu .og.pas2:hover{background:#f4f6f9}',
  '.ggmenu .og .ic2{width:16px;text-align:center;flex:none;font-size:13px}',
  '.ggmenu .og .ad2{flex:1;white-space:nowrap}',
  '.ggmenu .og .tk{color:#2e7d46;font-weight:bold;flex:none}',
  '.ggmenu .og .ks2{font-size:10.5px;color:#8296ab;flex:none}',
  '.ggmenu .ayr2{height:1px;background:#e3e9f0;margin:4px 6px}',
  '.ggmenu .bg2{font-size:10.5px;color:#6b7a8b;padding:5px 9px 3px;border-top:1px solid #e3e9f0;margin-top:3px}',
  /* seçim şeridi */
  '.ggser{display:none;align-items:center;gap:8px;margin-bottom:7px;padding:6px 10px;border-radius:4px;',
  '  background:linear-gradient(#e9f2fc,#d9e9f9);border:1px solid #a8c8ea;font-size:12px;flex-wrap:wrap}',
  '.ggser.on{display:flex}.ggser b{color:#14315a}',
  '.ggser .tmz{margin-left:auto;color:#2f6db3;text-decoration:underline;cursor:pointer;font-size:11.5px}',
  /* kolon seçici */
  '.ggks{position:fixed;z-index:9999;background:#fff;border:1px solid #b9c6d4;border-radius:5px;',
  '  box-shadow:0 12px 34px rgba(20,40,70,.24);padding:8px;min-width:260px;max-height:70vh;overflow:auto;',
  '  font:12px "Segoe UI",Tahoma,sans-serif;display:none}',
  '.ggks.on{display:block}',
  '.ggks h6{margin:0 0 6px;font-size:10.5px;text-transform:uppercase;letter-spacing:.3px;color:#7b8ea3}',
  '.ggks .k{display:flex;align-items:center;gap:7px;padding:4px 6px;border-radius:3px;cursor:pointer}',
  '.ggks .k:hover{background:#eef4fb}',
  '.ggks .k.suru{cursor:grab}.ggks .k.hedef{border-top:2px solid #2f6db3}',
  '.ggks .k .tas{color:#9fb3c8;font-size:12px}',
  '.ggks .alt{display:flex;gap:6px;margin-top:8px;border-top:1px solid #e3e9f0;padding-top:8px}'
  ].join('\n');
  document.head.appendChild(s);
}

/* ================================================================ GenGrid */
function GenGrid(kap, ayar){
  if (!(this instanceof GenGrid)) return new GenGrid(kap, ayar);
  stilKur();
  this.kap = typeof kap === 'string' ? document.querySelector(kap) : kap;
  this.a = ayar || {};
  this.kolonlar = (this.a.kolonlar || []).map(function(k, i){
    return Object.assign({sira:i, siralanabilir:true, filtrelenebilir:true, gizli:false}, k);
  });
  this.veri = this.a.veri || [];
  this.anahtar = this.a.anahtar || 'id';
  this.secili = new Set();
  this.acik = {};
  this.sira = [];               /* [{alan, yon}] çoklu sıralama */
  this.filtre = {};             /* {alan:{op, deger}} */
  this.filtreAcik = false;
  this.sonTik = null;
  this.sayfaBoyu = this.a.sayfaBoyu || 10;   /* PROTOTIP: ekranda 10 satır */
  this.yogunluk = this.a.yogunluk || 'normal';
  this.sigdir = false;
  this.sayfa = 1;
  this.pencere = this.a.pencere == null ? 10 : this.a.pencere;  /* kaç satırlık görüntü penceresi */
  this.ciz();
}

GenGrid.prototype.satirlar = function(){
  var self = this, v = this.veri.slice();
  /* --- filtre --- */
  Object.keys(this.filtre).forEach(function(alan){
    var f = self.filtre[alan]; if (!f || f.deger === '' || f.deger == null) return;
    var k = self.kol(alan); if (!k) return;
    v = v.filter(function(r){
      var d = r[alan], q = f.deger;
      if (k.tip === 'sayi' || k.tip === 'tutar'){
        var a = sayi(d), b = sayi(q); if (isNaN(b)) return true;
        return f.op === '>' ? a > b : f.op === '<' ? a < b : a === b;
      }
      if (k.tip === 'tarih'){
        var x = trh(d), y = trh(q); if (isNaN(y)) return norm(d).indexOf(norm(q)) >= 0;
        return f.op === '>' ? x > y : f.op === '<' ? x < y : x === y;
      }
      var s = norm(d), t = norm(q);
      return f.op === '=' ? s === t : f.op === '^' ? s.indexOf(t) === 0 : s.indexOf(t) >= 0;
    });
  });
  /* --- sıralama (çoklu, tip duyarlı, Türkçe) --- */
  if (this.sira.length){
    v.sort(function(x, y){
      for (var i = 0; i < self.sira.length; i++){
        var s = self.sira[i], k = self.kol(s.alan), c = 0;
        var a = x[s.alan], b = y[s.alan];
        if (!k) continue;
        if (k.tip === 'sayi' || k.tip === 'tutar') c = (sayi(a)||0) - (sayi(b)||0);
        else if (k.tip === 'tarih') c = (trh(a)||0) - (trh(b)||0);
        else c = TRC.compare('' + (a==null?'':a), '' + (b==null?'':b));
        if (c) return s.yon === 'desc' ? -c : c;
      }
      return 0;
    });
  }
  return v;
};
GenGrid.prototype.kol = function(alan){
  return this.kolonlar.filter(function(k){ return k.alan === alan; })[0];
};
GenGrid.prototype.gorunen = function(){
  return this.kolonlar.filter(function(k){ return !k.gizli; })
    .sort(function(a,b){ return a.sira - b.sira; });
};

/* ------------------------------------------------------------------ çizim */
GenGrid.prototype.ciz = function(){
  var self = this;
  var tum = this.satirlar(), kols = this.gorunen();
  var detayVar = !!this.a.detay;

  /* --- sayfalama: ekranda yalnızca geçerli sayfa çizilir --- */
  var bs = this.sayfaBoyu || 0;
  var sayfaAdet = bs ? Math.max(1, Math.ceil(tum.length / bs)) : 1;
  if (this.sayfa > sayfaAdet) this.sayfa = sayfaAdet;
  if (this.sayfa < 1) this.sayfa = 1;
  var bas = bs ? (this.sayfa - 1) * bs : 0;
  var sat = bs ? tum.slice(bas, bas + bs) : tum;
  this._tum = tum;

  this.kap.innerHTML = '';

  /* seçim şeridi */
  var ser = el('div','ggser');
  this.kap.appendChild(ser);

  /* grid kapsayıcı — sağ üst köşe menüsü buraya oturur */
  var ggkap = el('div','ggkap');
  var sar = el('div','gg' + (this.yogunluk && this.yogunluk !== 'normal' ? ' yog-' + this.yogunluk : '') +
    (this.sigdir ? ' sigdir' : '')), tbl = el('table');
  var thead = el('thead'), tr = el('tr');

  tr.appendChild(el('th','cbk','<span class="ggcb" data-hep="1"></span>'));   /* KURAL: ilk kolon onay */
  if (detayVar) tr.appendChild(el('th','ack'));

  kols.forEach(function(k){
    var th = el('th', (k.siralanabilir ? 'sir ' : '') + (k.hiza === 'sag' ? '' : k.hiza === 'ort' ? 'ort' : ''));
    var s = self.sira.filter(function(x){ return x.alan === k.alan; })[0];
    var si = self.sira.indexOf(s);
    th.innerHTML = k.ad +
      (s ? '<span class="ok">' + (s.yon === 'asc' ? '▲' : '▼') + '</span>' +
           (self.sira.length > 1 ? '<span class="sn">' + (si+1) + '</span>' : '') : '');
    if (k.gen && !self.sigdir) th.style.width = k.gen + 'px';
    if (k.siralanabilir) th.addEventListener('click', function(ev){ self.siralaTik(k.alan, ev.shiftKey); });
    tr.appendChild(th);
  });
  tr.addEventListener('contextmenu', function(ev){
    ev.preventDefault(); ev.stopPropagation();
    self.koseMenu(self.kap.querySelector('.ggkose .dgm:last-child') || tr, tum, kols);
  });
  thead.appendChild(tr);

  /* filtre satırı */
  if (this.filtreAcik){
    var ftr = el('tr','flt');
    ftr.appendChild(el('th','cbk'));
    if (detayVar) ftr.appendChild(el('th','ack'));
    kols.forEach(function(k){
      var th = el('th');
      if (k.filtrelenebilir !== false){
        var f = self.filtre[k.alan] || {op: (k.tip==='sayi'||k.tip==='tutar'||k.tip==='tarih') ? '=' : '~', deger:''};
        var kut = el('div','kut');
        var ob = el('button','op', f.op);
        ob.title = 'Operatör değiştir';
        ob.addEventListener('click', function(ev){
          ev.stopPropagation();
          var liste = (k.tip==='sayi'||k.tip==='tutar'||k.tip==='tarih') ? ['=','>','<'] : ['~','=','^'];
          f.op = liste[(liste.indexOf(f.op)+1) % liste.length];
          self.filtre[k.alan] = f; self.ciz(); self.odakFiltre(k.alan);
        });
        var inp = document.createElement('input');
        inp.value = f.deger; inp.dataset.flt = k.alan;
        inp.placeholder = k.tip === 'tarih' ? 'gg.aa.yyyy' : '';
        inp.addEventListener('input', function(){
          f.deger = inp.value; self.filtre[k.alan] = f;
          clearTimeout(self._ft); self._ft = setTimeout(function(){
            var p = inp.selectionStart; self.ciz(); self.odakFiltre(k.alan, p);
          }, 260);
        });
        kut.appendChild(ob); kut.appendChild(inp); th.appendChild(kut);
      }
      ftr.appendChild(th);
    });
    thead.appendChild(ftr);
  }
  tbl.appendChild(thead);

  /* gövde */
  var tb = el('tbody');
  sat.forEach(function(r, i){
    var id = '' + r[self.anahtar];        /* anahtar her yerde metin — sayı/metin karışmasın */
    var trr = el('tr', (self.a.satirSinifi ? self.a.satirSinifi(r) : '') +
      (self.secili.has(id) ? ' gsec' : ''));
    trr.dataset.id = id;
    trr.appendChild(el('td','cbk','<span class="ggcb' + (self.secili.has(id)?' on':'') + '" data-cb="' + id + '"></span>'));
    if (detayVar){
      var v = !self.a.detayVar || self.a.detayVar(r);
      trr.appendChild(el('td','ack','<span class="ggac' + (v?'':' yok') + '" data-ac="' + id + '">' +
        (v ? (self.acik[id] ? '⌄' : '▸') : '·') + '</span>'));
    }
    kols.forEach(function(k){
      var d = r[k.alan];
      var metin = k.bicim ? k.bicim(d, r)
        : k.tip === 'tutar' ? para(d)
        : k.tip === 'sayi'  ? (d == null ? '' : (+d).toLocaleString('tr-TR'))
        : (d == null ? '' : d);
      var td = el('td', (k.hiza === 'sag' || k.tip === 'tutar' || k.tip === 'sayi' ? 'sag' :
                          k.hiza === 'ort' ? 'ort' : '') + (k.sinif ? ' ' + (k.sinif(d, r)||'') : ''), metin);
      trr.appendChild(td);
    });
    trr.addEventListener('click', function(ev){
      if (ev.target.closest('.ggcb,.ggac,a,button,input')) return;
      self.satirTik(id, i, ev, sat);
    });
    tb.appendChild(trr);

    if (detayVar && self.acik[id] && (!self.a.detayVar || self.a.detayVar(r))){
      var dtr = el('tr','detay');
      var dtd = el('td'); dtd.colSpan = kols.length + 1 + (detayVar?1:0);
      dtd.innerHTML = self.a.detay(r);
      dtr.appendChild(dtd); tb.appendChild(dtr);
    }
  });
  tbl.appendChild(tb);

  /* toplam satırı */
  var toplamKol = kols.filter(function(k){ return k.toplam; });
  if (toplamKol.length){
    var tf = el('tfoot'), ttr = el('tr');
    ttr.appendChild(el('td','cbk')); if (detayVar) ttr.appendChild(el('td','ack'));
    kols.forEach(function(k, x){
      if (k.toplam){
        var t = tum.reduce(function(a, r){ return a + (sayi(r[k.alan])||0); }, 0);
        ttr.appendChild(el('td','sag', k.tip === 'tutar' ? para(t) : t.toLocaleString('tr-TR')));
      } else ttr.appendChild(el('td', '', x === 0 ? 'TOPLAM (' + tum.length + ')' : ''));
    });
    tf.appendChild(ttr); tbl.appendChild(tf);
  }

  sar.appendChild(tbl);
  ggkap.appendChild(sar);
  ggkap.appendChild(this.koseDugmesi(tum, kols));
  this.kap.appendChild(ggkap);
  this.kap.appendChild(this.sayfaSeridi(tum, sat.length, bas, sayfaAdet));

  /* olaylar */
  this.kap.querySelectorAll('[data-cb]').forEach(function(c){
    c.addEventListener('click', function(ev){ ev.stopPropagation();
      var id = c.dataset.cb;
      self.secili.has(id) ? self.secili.delete(id) : self.secili.add(id);
      self.ciz();
    });
  });
  var hep = this.kap.querySelector('[data-hep]');
  var sayfaSecili = sat.filter(function(r){ return self.secili.has('' + r[self.anahtar]); }).length;
  hep.title = 'Bu sayfadaki ' + sat.length + ' kaydı seç / bırak';
  hep.addEventListener('click', function(){
    if (sayfaSecili === sat.length) sat.forEach(function(r){ self.secili.delete('' + r[self.anahtar]); });
    else sat.forEach(function(r){ self.secili.add('' + r[self.anahtar]); });
    self.ciz();
  });
  hep.classList.toggle('on', sayfaSecili === sat.length && sat.length > 0);
  hep.classList.toggle('yari', sayfaSecili > 0 && sayfaSecili < sat.length);

  this.kap.querySelectorAll('[data-ac]').forEach(function(b){
    b.addEventListener('click', function(ev){ ev.stopPropagation();
      if (b.classList.contains('yok')) return;
      var id = b.dataset.ac; self.acik[id] = !self.acik[id]; self.ciz();
    });
  });

  /* seçim şeridi içeriği */
  if (this.secili.size){
    ser.classList.add('on');
    var sec = tum.filter(function(r){ return self.secili.has('' + r[self.anahtar]); });
    var hepsiSecili = tum.length && tum.every(function(r){ return self.secili.has('' + r[self.anahtar]); });
    ser.innerHTML = '<b>' + this.secili.size + ' kayıt seçili</b>' +
      (this.a.secimOzet ? '<span>· ' + this.a.secimOzet(sec) + '</span>' : '') +
      (!hepsiSecili && tum.length > sat.length
        ? '<span class="tmz2">Filtredeki <b>' + tum.length + '</b> kaydın tümünü seç</span>' : '') +
      '<span class="tmz">Seçimi temizle (Esc)</span>';
    ser.querySelector('.tmz').addEventListener('click', function(){ self.secili.clear(); self.ciz(); });
    var t2 = ser.querySelector('.tmz2');
    if (t2) t2.addEventListener('click', function(){
      tum.forEach(function(r){ self.secili.add('' + r[self.anahtar]); }); self.ciz(); });
    if (this.a.secimDegisti) this.a.secimDegisti(sec);
  }
  this.pencereAyarla();
};

/* ---------------------------------------------- sağ üst köşe düğmesi */
GenGrid.prototype.koseDugmesi = function(sat, kols){
  var self = this;
  var k = el('div','ggkose');
  var suzuluyor = Object.keys(this.filtre).some(function(a){
    return self.filtre[a] && self.filtre[a].deger !== ''; });
  var etkin = suzuluyor || this.sira.length || kols.length < this.kolonlar.length;

  /* filtre satırını aç/kapa */
  var f = el('div','dgm' + (this.filtreAcik || suzuluyor ? ' etkin' : ''), '🔎');
  f.title = 'Filtre satırı — her kolon için ayrı süzgeç (aç / kapat)';
  f.addEventListener('click', function(ev){ ev.stopPropagation();
    self.filtreAcik = !self.filtreAcik; self.ciz(); });
  k.appendChild(f);

  /* kolon ekle / kaldır */
  var c = el('div','dgm' + (kols.length < this.kolonlar.length ? ' etkin' : ''), '▦');
  c.title = 'Kolon ekle / kaldır — göster, gizle, sürükleyerek sırala';
  c.addEventListener('click', function(ev){ ev.stopPropagation(); self.kolonSecici(c); });
  k.appendChild(c);

  /* tüm grid menüsü */
  var d = el('div','dgm' + (etkin ? ' etkin' : ''), '⋮' + (etkin ? '<span class="nk"></span>' : ''));
  d.title = 'Grid menüsü — sıralama, filtre, seçim, aktarım, görünüm kaydet';
  d.addEventListener('click', function(ev){ ev.stopPropagation(); self.koseMenu(d, sat, kols); });
  k.appendChild(d);
  return k;
};

GenGrid.prototype.koseMenu = function(dugme, sat, kols){
  var self = this;
  var eski = document.querySelector('.ggmenu'); if (eski){ eski.remove(); return; }
  var m = el('div','ggmenu on');
  var detayVar = !!this.a.detay;
  var suzuluyor = Object.keys(this.filtre).some(function(a){
    return self.filtre[a] && self.filtre[a].deger !== ''; });

  function bas(t){ m.appendChild(el('div','bs2', t)); }
  function ayr(){ m.appendChild(el('div','ayr2')); }
  function oge(ik, ad, ks, secili, pasSebep, fn, ipucu){
    var o = el('div','og' + (pasSebep ? ' pas2' : ''));
    o.innerHTML = '<span class="ic2">' + ik + '</span><span class="ad2">' + ad + '</span>' +
      (secili ? '<span class="tk">✓</span>' : '') + (ks ? '<span class="ks2">' + ks + '</span>' : '');
    o.title = pasSebep || ipucu || '';
    if (!pasSebep) o.addEventListener('click', function(ev){ ev.stopPropagation(); m.remove(); fn(); });
    m.appendChild(o);
  }

  bas('Seçim');
  oge('☑','Tümünü Seç (filtredeki)', 'Ctrl+A', false, null, function(){
    sat.forEach(function(r){ self.secili.add('' + r[self.anahtar]); }); self.ciz(); });
  oge('☐','Seçimi Temizle', 'Esc', false,
    this.secili.size ? null : 'Seçili kayıt yok', function(){ self.secili.clear(); self.ciz(); });
  oge('⇄','Seçimi Tersine Çevir', null, false, null, function(){
    sat.forEach(function(r){ var id = '' + r[self.anahtar];
      self.secili.has(id) ? self.secili.delete(id) : self.secili.add(id); }); self.ciz(); });
  ayr();

  bas('Kolonlar ve Satırlar');
  oge('🔎','Satır Filtreleme', null, this.filtreAcik, null, function(){
    self.filtreAcik = !self.filtreAcik; self.ciz(); },
    'Kolon başlıklarının altında süzgeç kutuları açılır; yazdıkça satırlar süzülür (filtre satırı).');
  oge('▦','Kolon Ekle / Kaldır…', null, false, null, function(){ self.kolonSecici(dugme); },
    'Kolonları göster / gizle, sürükleyerek sırala.');
  oge('↔','Kolon Genişliklerini Sığdır', null, this.sigdir, null, function(){
    self.sigdir = !self.sigdir; self.ciz(); },
    'Sabit kolon genişliklerini bırakır, içeriğe göre daraltır / genişletir.');
  oge('⇤','Kolon Düzenini Sıfırla', null, false,
    (function(){ var d = self.kolonlar.some(function(x, i){
        return x.sira !== i || !!x.gizli !== !!(self.a.kolonlar[i]||{}).gizli; });
      return d ? null : 'Kolon düzeni zaten varsayılan'; })(), function(){
    self.kolonlar.forEach(function(x, i){ x.gizli = !!(self.a.kolonlar[i]||{}).gizli; x.sira = i; });
    self.sigdir = false; self.ciz(); },
    'Gizlenen kolonları geri getirir, sırayı ve genişlikleri varsayılana döndürür.');
  ayr();

  bas('Satır Yüksekliği');
  ['sik|Sık|Daha çok satır sığar','normal|Normal|Varsayılan (prototip ölçüsü)','genis|Rahat|Okuması kolay']
    .forEach(function(x){
      var p = x.split('|');
      oge(p[0] === (self.yogunluk || 'normal') ? '●' : '○', p[1], null, false, null, function(){
        self.yogunluk = p[0]; self.ciz(); }, p[2]);
    });
  ayr();

  bas('Sayfa');
  [10, 25, 50, 100, 0].forEach(function(n){
    oge(n === (self.sayfaBoyu || 0) ? '●' : '○', n ? n + ' satır' : 'Tümü (sayfalama yok)',
      null, false, null, function(){ self.sayfaBoyu = n; self.sayfa = 1; self.ciz(); },
      'Bir sayfada gösterilecek satır sayısı. Ekranda 10 satır görünür, gerisi kaydırılır.');
  });
  ayr();

  if (detayVar){
    bas('Görünüm');
    oge('⌄','Tüm Detayları Aç', null, false, null, function(){
      sat.forEach(function(r){ if (!self.a.detayVar || self.a.detayVar(r))
        self.acik[r[self.anahtar]] = true; }); self.ciz(); });
    oge('⌃','Tüm Detayları Kapat', null, false,
      Object.keys(this.acik).length ? null : 'Açık detay yok', function(){ self.acik = {}; self.ciz(); });
    ayr();
  }

  bas('Sıralama ve Filtre');
  oge('↕','Sıralamayı Temizle', null, false,
    this.sira.length ? null : 'Etkin sıralama yok', function(){ self.sira = []; self.ciz(); });
  oge('✖','Filtreyi Temizle', null, false,
    suzuluyor ? null : 'Etkin filtre yok', function(){ self.filtre = {}; self.ciz(); });
  oge('🧹','Tümünü Sıfırla', null, false, null, function(){
    self.sira = []; self.filtre = {}; self.filtreAcik = false; self.secili.clear(); self.acik = {};
    self.kolonlar.forEach(function(x, i){ x.gizli = !!(self.a.kolonlar[i]||{}).gizli; x.sira = i; });
    self.ciz(); });
  ayr();

  bas('Aktarım');
  oge('⬇','Excel’e Aktar', null, false, null, function(){ self.aktar('xlsx', sat, kols); });
  oge('📄','CSV’ye Aktar', null, false, null, function(){ self.aktar('csv', sat, kols); });
  oge('📋','Panoya Kopyala', 'Ctrl+C', false, null, function(){ self.aktar('pano', sat, kols); });
  oge('🖨','Yazdır', 'Ctrl+P', false, null, function(){ self.aktar('yazdir', sat, kols); });
  ayr();

  bas('Görünüm Kaydet');
  oge('💾','Kişisel Görünüm Kaydet', null, false, null, function(){ self.bildir('Görünüm kaydedildi — kolon düzeni, sıralama ve filtre bu kullanıcı için hatırlanır.'); });
  oge('👥','Ortak Görünüm Yap', null, false, 'Ortak görünüm kaydetme yetkisi yok', function(){});
  oge('↺','Varsayılana Dön', null, false, null, function(){
    self.kolonlar.forEach(function(x, i){ x.gizli = !!(self.a.kolonlar[i]||{}).gizli; x.sira = i; });
    self.ciz(); });

  var bg = el('div','bg2');
  bg.innerHTML = '<b>' + sat.length + '</b> / ' + this.veri.length + ' satır · <b>' +
    kols.length + '</b> / ' + this.kolonlar.length + ' kolon' +
    (this.secili.size ? ' · <b>' + this.secili.size + '</b> seçili' : '') +
    (this.sira.length ? '<br>Sıralı: ' + this.sira.map(function(s){
      return self.kol(s.alan).ad + (s.yon === 'desc' ? ' ↓' : ' ↑'); }).join(', ') : '') +
    (suzuluyor ? '<br>Filtreli: ' + Object.keys(this.filtre).filter(function(a){
      return self.filtre[a].deger !== ''; }).map(function(a){ return self.kol(a).ad; }).join(', ') : '');
  m.appendChild(bg);

  document.body.appendChild(m);
  var r = dugme.getBoundingClientRect();
  m.style.left = Math.max(8, Math.min(r.right - m.offsetWidth, innerWidth - m.offsetWidth - 8)) + 'px';
  /* menü pencereden uzunsa yukarı taşmasın: düğmenin altından başlar, gerisi menü içinde kayar */
  var ust = Math.max(6, r.bottom + 3);
  var bosluk = innerHeight - ust - 8;
  if (m.offsetHeight > bosluk){
    if (bosluk < 240){ ust = 6; bosluk = innerHeight - 14; }
    m.style.maxHeight = bosluk + 'px';
  }
  m.style.top = ust + 'px';
  setTimeout(function(){
    document.addEventListener('click', function kapa(e){
      if (!m.contains(e.target)){ m.remove(); document.removeEventListener('click', kapa); }
    });
  }, 0);
};


/* --------------------------------------------- sayfa şeridi (10 satır kuralı) */
GenGrid.prototype.sayfaSeridi = function(tum, gosterilen, bas, sayfaAdet){
  var self = this;
  var s = el('div','ggsyf');

  function dug(metin, hedef, pas, secili){
    var d = el('div','sb' + (pas ? ' pas' : '') + (secili ? ' on' : ''), metin);
    if (!pas && !secili) d.addEventListener('click', function(){ self.sayfa = hedef; self.ciz(); });
    return d;
  }
  var nav = el('div','sy');
  nav.appendChild(dug('«', 1, this.sayfa === 1));
  nav.appendChild(dug('‹', this.sayfa - 1, this.sayfa === 1));
  var ilk = Math.max(1, Math.min(this.sayfa - 2, sayfaAdet - 4));
  var son = Math.min(sayfaAdet, ilk + 4);
  for (var i = ilk; i <= son; i++) nav.appendChild(dug('' + i, i, false, i === this.sayfa));
  nav.appendChild(dug('›', this.sayfa + 1, this.sayfa === sayfaAdet));
  nav.appendChild(dug('»', sayfaAdet, this.sayfa === sayfaAdet));
  s.appendChild(nav);

  s.appendChild(el('span', null, 'Sayfa boyutu'));
  var sel = document.createElement('select');
  [10, 25, 50, 100, 0].forEach(function(n){
    var o = document.createElement('option');
    o.value = n; o.textContent = n ? n : 'Tümü';
    if (n === self.sayfaBoyu) o.selected = true;
    sel.appendChild(o);
  });
  sel.addEventListener('change', function(){
    self.sayfaBoyu = +sel.value; self.sayfa = 1; self.ciz(); });
  s.appendChild(sel);

  var bilgi = el('span','bg');
  bilgi.innerHTML = tum.length
    ? '<b>' + (bas + 1) + '–' + (bas + gosterilen) + '</b> / ' + tum.length + ' kayıt' +
      (this.veri.length !== tum.length ? ' <span style="opacity:.7">(' + this.veri.length + ' kayıttan süzüldü)</span>' : '')
    : 'kayıt yok';
  s.appendChild(bilgi);
  return s;
};

/* ------------------- görüntü penceresi: 10 satırdan uzun liste kaydırılır */
GenGrid.prototype.pencereAyarla = function(){
  var sar = this.kap.querySelector('.gg');
  if (!sar || !this.pencere) return;
  var tb = sar.querySelector('tbody');
  var trs = tb ? tb.querySelectorAll('tr') : [];
  if (trs.length <= this.pencere){ sar.style.maxHeight = ''; return; }
  var h = 0;
  for (var i = 0; i < this.pencere; i++) h += trs[i].offsetHeight;
  var th = sar.querySelector('thead');
  var tf = sar.querySelector('tfoot');
  sar.style.maxHeight = (h + (th ? th.offsetHeight : 0) + (tf ? tf.offsetHeight : 0) + 2) + 'px';
};

GenGrid.prototype.bildir = function(metin){
  if (window.GnSagMenu && window.GnSagMenu.bildir) return window.GnSagMenu.bildir(metin);
  var d = document.createElement('div');
  d.style.cssText = 'position:fixed;right:14px;bottom:14px;z-index:10001;background:#1f3a5f;color:#fff;' +
    'font:600 11.5px Segoe UI,sans-serif;padding:8px 13px;border-radius:14px;opacity:.95;max-width:400px';
  d.textContent = metin; document.body.appendChild(d);
  setTimeout(function(){ d.style.transition = 'opacity .4s'; d.style.opacity = '0';
    setTimeout(function(){ d.remove(); }, 420); }, 2600);
};

GenGrid.prototype.aktar = function(tip, sat, kols){
  var self = this;
  var kayit = this.secili.size ? sat.filter(function(r){
    return self.secili.has('' + r[self.anahtar]); }) : sat;
  var bas = kols.map(function(k){ return k.ad; });
  var satirlar = kayit.map(function(r){
    return kols.map(function(k){
      var v = r[k.alan];
      if (k.tip === 'tutar' || k.tip === 'sayi') return v == null ? '' : v;
      return ('' + (v == null ? '' : v)).replace(/<[^>]*>/g, '');
    });
  });
  if (tip === 'csv' || tip === 'pano'){
    var m = [bas.join(';')].concat(satirlar.map(function(s){
      return s.map(function(h){ return ('' + h).indexOf(';') >= 0 ? '"' + h + '"' : h; }).join(';');
    })).join('\n');
    if (tip === 'pano' && navigator.clipboard) navigator.clipboard.writeText(m).catch(function(){});
    this.bildir((tip === 'pano' ? '📋 Panoya kopyalandı' : '📄 CSV hazırlandı') +
      ' — ' + kayit.length + ' satır × ' + kols.length + ' kolon' +
      (this.secili.size ? ' (yalnız seçililer)' : ''));
  } else if (tip === 'yazdir'){
    this.bildir('🖨 Yazdırma önizlemesi — ' + kayit.length + ' satır · görünen kolonlar ve mevcut sıralama korunur.');
  } else {
    this.bildir('⬇ Excel dosyası hazırlanıyor — ' + kayit.length + ' satır × ' + kols.length +
      ' kolon' + (this.secili.size ? ' (yalnız seçililer)' : '') +
      ' · biçimlendirme sunucuda üretilir (FastReport .NET).');
  }
};

GenGrid.prototype.odakFiltre = function(alan, poz){
  var i = this.kap.querySelector('input[data-flt="' + alan + '"]');
  if (i){ i.focus(); if (poz != null) try{ i.setSelectionRange(poz, poz); }catch(e){} }
};

GenGrid.prototype.siralaTik = function(alan, coklu){
  var v = this.sira.filter(function(s){ return s.alan === alan; })[0];
  if (!coklu && this.sira.length && !(this.sira.length === 1 && v)) this.sira = [];
  v = this.sira.filter(function(s){ return s.alan === alan; })[0];
  if (!v) this.sira.push({alan:alan, yon:'asc'});
  else if (v.yon === 'asc') v.yon = 'desc';
  else this.sira = this.sira.filter(function(s){ return s.alan !== alan; });
  this.ciz();
};

GenGrid.prototype.satirTik = function(id, i, ev, sat){
  var self = this;
  if (ev.shiftKey && this.sonTik != null){
    var a = Math.min(this.sonTik, i), b = Math.max(this.sonTik, i);
    if (!ev.ctrlKey && !ev.metaKey) this.secili.clear();
    for (var j = a; j <= b; j++) this.secili.add('' + sat[j][this.anahtar]);
  } else if (ev.ctrlKey || ev.metaKey){
    this.secili.has(id) ? this.secili.delete(id) : this.secili.add(id);
    this.sonTik = i;
  } else {
    this.secili.clear(); this.secili.add(id); this.sonTik = i;
  }
  this.ciz();
};

/* -------------------------------------------------------- kolon seçici */
GenGrid.prototype.kolonSecici = function(dugme){
  var self = this;
  var eski = document.querySelector('.ggks'); if (eski) eski.remove();
  var p = el('div','ggks on');
  p.innerHTML = '<h6>Kolonlar — göster / gizle · sürükle sırala</h6>';
  var liste = el('div');
  this.kolonlar.slice().sort(function(a,b){ return a.sira - b.sira; }).forEach(function(k){
    var d = el('div','k suru');
    d.draggable = true; d.dataset.alan = k.alan;
    d.innerHTML = '<span class="tas">⣿</span><span class="ggcb' + (k.gizli?'':' on') + '"></span>' +
      '<span>' + k.ad + '</span>';
    d.addEventListener('click', function(){
      var gorunur = self.kolonlar.filter(function(x){ return !x.gizli; }).length;
      if (!k.gizli && gorunur <= 1) return;      /* en az bir kolon kalsın */
      k.gizli = !k.gizli; self.ciz(); self.kolonSecici(dugme);
    });
    d.addEventListener('dragstart', function(e){ e.dataTransfer.setData('text/plain', k.alan); });
    d.addEventListener('dragover', function(e){ e.preventDefault(); d.classList.add('hedef'); });
    d.addEventListener('dragleave', function(){ d.classList.remove('hedef'); });
    d.addEventListener('drop', function(e){
      e.preventDefault(); d.classList.remove('hedef');
      var kaynak = self.kol(e.dataTransfer.getData('text/plain'));
      if (!kaynak || kaynak === k) return;
      var sirali = self.kolonlar.slice().sort(function(a,b){ return a.sira-b.sira; });
      sirali.splice(sirali.indexOf(kaynak), 1);
      sirali.splice(sirali.indexOf(k), 0, kaynak);
      sirali.forEach(function(x, i){ x.sira = i; });
      self.ciz(); self.kolonSecici(dugme);
    });
    liste.appendChild(d);
  });
  p.appendChild(liste);
  var alt = el('div','alt');
  var b1 = el('button','ggb','Tümünü Göster');
  b1.addEventListener('click', function(){ self.kolonlar.forEach(function(k){ k.gizli=false; });
    self.ciz(); self.kolonSecici(dugme); });
  var b2 = el('button','ggb','Varsayılana Dön');
  b2.addEventListener('click', function(){
    self.kolonlar.forEach(function(k, i){ k.gizli = !!(self.a.kolonlar[i]||{}).gizli; k.sira = i; });
    self.ciz(); self.kolonSecici(dugme); });
  var b3 = el('button','ggb','💾 Görünümü Kaydet');
  b3.addEventListener('click', function(){ p.remove(); });
  alt.appendChild(b1); alt.appendChild(b2); alt.appendChild(b3);
  p.appendChild(alt);
  document.body.appendChild(p);
  var r = dugme.getBoundingClientRect();
  p.style.left = Math.min(r.left, innerWidth - p.offsetWidth - 10) + 'px';
  p.style.top = Math.min(r.bottom + 4, innerHeight - p.offsetHeight - 10) + 'px';
  setTimeout(function(){
    document.addEventListener('click', function kapa(e){
      if (!p.contains(e.target)){ p.remove(); document.removeEventListener('click', kapa); }
    });
  }, 0);
};

/* klavye */
document.addEventListener('keydown', function(e){
  if (e.key === 'Escape' && window._genAktif){ window._genAktif.secili.clear(); window._genAktif.ciz(); }
});

GenGrid.prototype.seciliVeri = function(){
  var self = this;
  return this.veri.filter(function(r){ return self.secili.has('' + r[self.anahtar]); });
};
GenGrid.prototype.yenile = function(veri){ if (veri) this.veri = veri; this.ciz(); };

window.GenGrid = GenGrid;
})();
