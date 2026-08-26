# -*- coding: utf-8 -*-
"""Turkce (varsayilan) / Ingilizce dil destegi.

Kapsam — kabuk + menuler:
  · gentegre_data.js : her modul/bolum adina `ad_en`, her gruba `grup_en`
  · gentegre_v4_web.html : bayrakli dil secici + kabuk metinleri sozlugu

Ekranlarin kendi ic metinleri cevrilmez; kabuk yine de iframe'lere
{gentegre:'dil'} mesaji yollar, ekranlar ileride buna cevap verebilir.

Betik yeniden calistirilabilir (isaretli bloklar once sokulur).
"""
import io, re, json, base64

KOK = '/home/claude/test'
VERI = KOK + '/gentegre_data.js'
KABUK = KOK + '/gentegre_v4_web.html'

# ------------------------------------------------- 1. modul / bolum adlari
AD = {
 "Alınan Siparişler": "Sales Orders",
 "Alış": "Purchasing",
 "Alış Faturaları": "Purchase Invoices",
 "Alış Fişleri": "Purchase Vouchers",
 "Alış Konsinyeleri": "Purchase Consignments",
 "Alış Tahakkukları": "Purchase Accruals",
 "Alış İrsaliyeleri": "Purchase Delivery Notes",
 "Alış/Satış": "Purchasing / Sales",
 "Ana Sayfa": "Home",
 "Banka": "Bank",
 "Banka Bilgileri": "Bank Details",
 "Banka Hesapları": "Bank Accounts",
 "CRM": "CRM",
 "Cari": "Accounts",
 "Demirbaş": "Fixed Assets",
 "Demirbaş Listesi": "Fixed Asset List",
 "Denetim": "Audits",
 "Değerlendirme": "Assessment",
 "Doküman": "Documents",
 "Doküman Listesi": "Document List",
 "DÖF": "CAPA",
 "Dökümler": "Reports",
 "Döviz Değerleri": "Exchange Rates",
 "Eğitim": "Training",
 "Firma Bilgileri": "Company Details",
 "Fiyat Sor": "Price Inquiry",
 "Gen": "Gen",
 "Genel": "General",
 "Gentegre Yapay Zeka": "Gentegre AI",
 "Gider Pusulaları": "Expense Vouchers",
 "Giriş Fişleri": "Goods Receipts",
 "Giriş Sayfası": "Landing Page",
 "Grid Karşılaştırma": "Grid Comparison",
 "Görev / Aktivite": "Task / Activity",
 "Hesap Planı": "Chart of Accounts",
 "Hızlı Satış (POS)": "Quick Sale (POS)",
 "Kalite": "Quality",
 "Kasa": "Cash",
 "Kasalar": "Cash Accounts",
 "Kişiler": "Contacts",
 "Kredi Kartları": "Credit Cards",
 "Krediler": "Loans",
 "Kullanıcı Ayarları": "User Settings",
 "Log Info": "Log Info",
 "Mesajlar": "Messages",
 "Müşteriler": "Customers",
 "POS Listesi": "POS List",
 "Personel Kartları": "Employee Records",
 "Personel Listesi": "Employee List",
 "Potansiyel Müşteriler": "Leads",
 "Proje Dosyası": "Project Dossier",
 "Projeler": "Projects",
 "Rehber Arama": "Directory Search",
 "Reçete / Ürün Ağacı": "Bill of Materials",
 "Sapma / Olay": "Deviation / Incident",
 "Satınalma Talepleri": "Purchase Requisitions",
 "Satış": "Sales",
 "Satış Faturaları": "Sales Invoices",
 "Satış Fişleri": "Sales Vouchers",
 "Satış Fırsatları": "Opportunities",
 "Satış Konsinyeleri": "Sales Consignments",
 "Satış Tahakkukları": "Sales Accruals",
 "Satış İrsaliyeleri": "Sales Delivery Notes",
 "Senetler": "Promissory Notes",
 "Servis": "Service",
 "Servis Fişleri": "Service Tickets",
 "Stok": "Inventory",
 "Stok Listesi": "Stock List",
 "Stoktan Talepler": "Stock Requests",
 "Tedarikçiler": "Suppliers",
 "Teklif": "Quotations",
 "Teklif Listesi": "Quotation List",
 "Toplantı": "Meetings",
 "Transferler": "Transfers",
 "Uygulama Planı": "Implementation Plan",
 "Verilen Siparişler": "Purchase Orders",
 "Yedekleme": "Backup",
 "Yönetim": "Administration",
 "Çekler": "Cheques",
 "Çekler (Ver2 · deneme)": "Cheques (v2 · trial)",
 "Çekler (Ver3 · deneme)": "Cheques (v3 · trial)",
 "Çıkış Fişleri": "Goods Issues",
 "ÜTS Bildirim": "UTS Notification",
 "Üretim": "Production",
 "Üretim Fişleri": "Production Vouchers",
 "İK": "HR",
 "İletişim & AI": "Communication & AI",
 "İzlem Girişi (Lot/SKT)": "Tracking Entry (Lot / Expiry)",
 "İzlem · AG Grid": "Tracking · AG Grid",
 "İzlem · GenGrid": "Tracking · GenGrid",
 "İş Emirleri": "Work Orders",
 "İş Listesi": "Task List",
}

GRUP = {
 "Opsiyonlar": "Options",
 "Sistem": "System",
 "Tanımlar": "Definitions",
 "İzlem": "Tracking",
}


def veri_yamasi():
    s = io.open(VERI, encoding='utf-8').read()
    i = s.index('var MODULLER'); j = s.index('\nvar ', i + 5)
    blok = s[i:j]
    eksik = set()

    def ad_ekle(m):
        tr = m.group(1)
        if tr not in AD:
            eksik.add(tr); return m.group(0)
        return "ad:'%s', ad_en:'%s'" % (tr, AD[tr].replace("'", "\\'"))

    def grup_ekle(m):
        tr = m.group(1)
        if tr not in GRUP:
            eksik.add(tr); return m.group(0)
        return "grup:'%s', grup_en:'%s'" % (tr, GRUP[tr])

    # once eski _en alanlarini sok (yeniden calistirilabilirlik)
    blok = re.sub(r",\s*ad_en:'(?:[^'\\]|\\.)*'", '', blok)
    blok = re.sub(r",\s*grup_en:'(?:[^'\\]|\\.)*'", '', blok)

    blok = re.sub(r"\bad:'((?:[^'\\]|\\.)*)'", ad_ekle, blok)
    blok = re.sub(r"\bgrup:'((?:[^'\\]|\\.)*)'", grup_ekle, blok)

    if eksik:
        raise SystemExit('SOZLUKTE YOK: %s' % sorted(eksik))
    io.open(VERI, 'w', encoding='utf-8').write(s[:i] + blok + s[j:])
    return blok.count('ad_en:'), blok.count('grup_en:')


# ------------------------------------------------------------- 2. bayraklar
def tr_bayrak():
    """Turk bayragi — 3:2, hilal + yildiz (yildiz noktalari hesaplanir)."""
    import math
    cx, cy, R, r = 19.6, 10.0, 2.3, 2.3 * 0.382
    pts = []
    for k in range(10):
        a = math.radians(-90 + k * 36)
        rad = R if k % 2 == 0 else r
        pts.append('%.2f,%.2f' % (cx + rad * math.cos(a), cy + rad * math.sin(a)))
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 20">'
            '<rect width="30" height="20" fill="#E30A17"/>'
            '<circle cx="12" cy="10" r="5" fill="#fff"/>'
            '<circle cx="13.7" cy="10" r="4" fill="#E30A17"/>'
            '<polygon points="%s" fill="#fff"/></svg>') % ' '.join(pts)


def gb_bayrak():
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 30">'
            '<clipPath id="c"><path d="M30,15 h30 v15 z v15 h-30 z h-30 v-15 z v-15 h30 z"/></clipPath>'
            '<rect width="60" height="30" fill="#012169"/>'
            '<path d="M0,0 L60,30 M60,0 L0,30" stroke="#fff" stroke-width="6"/>'
            '<path d="M0,0 L60,30 M60,0 L0,30" clip-path="url(#c)" stroke="#C8102E" stroke-width="4"/>'
            '<path d="M30,0 v30 M0,15 h60" stroke="#fff" stroke-width="10"/>'
            '<path d="M30,0 v30 M0,15 h60" stroke="#C8102E" stroke-width="6"/></svg>')


def veri_url(svg):
    return 'data:image/svg+xml;base64,' + base64.b64encode(svg.encode('utf-8')).decode('ascii')


# --------------------------------------------------------------- 3. kabuk
CSS_IM = '/* === GN-DIL: bayrakli dil secici === */'
CSS_SON = '/* === GN-DIL son === */'
CSS = CSS_IM + '''
/* Tek bayrak dugmesi; tiklaninca altinda kucuk liste acilir (combo gibi). */
.ust{position:relative;z-index:60}
.dilsec{position:relative;display:inline-flex;align-items:center;flex:none}
.dilsec .simdi{display:inline-flex;align-items:center;gap:3px;padding:3px 4px;border:0;
  border-radius:6px;background:none;cursor:pointer;color:inherit;font:inherit;flex:none}
.dilsec .simdi:hover{background:rgba(255,255,255,.16)}
.dilsec .simdi .ok{font-size:8px;opacity:.8;line-height:1}
.dilsec .bayrak{width:18px;min-width:18px;height:12px;border-radius:2px;overflow:hidden;
  display:block;flex:none;box-shadow:0 0 0 1px rgba(255,255,255,.40)}
.dilsec .bayrak img{width:18px;height:12px;display:block;object-fit:cover}
.dilmenu{position:absolute;top:calc(100% + 7px);right:0;z-index:9999;min-width:136px;
  background:#fff;border:1px solid #b9c6d4;border-radius:6px;padding:4px;
  box-shadow:0 12px 30px rgba(20,40,70,.26);display:none;
  font:12px "Segoe UI",Tahoma,sans-serif;color:#1f2d3a}
.dilmenu.on{display:block}
.dilmenu .sec{display:flex;align-items:center;gap:8px;padding:6px 8px;border-radius:4px;
  cursor:pointer;white-space:nowrap}
.dilmenu .sec:hover{background:#e6f0fb}
.dilmenu .sec.on{font-weight:600}
.dilmenu .sec .bayrak{width:18px;min-width:18px;height:12px;border-radius:2px;overflow:hidden;
  display:block;flex:none;box-shadow:0 0 0 1px rgba(20,40,70,.25)}
.dilmenu .sec .bayrak img{width:18px;height:12px;display:block;object-fit:cover}
.dilmenu .sec .tk{margin-left:auto;color:#2e7d46;font-weight:bold}
body.koyu .dilmenu{background:#1f2733;border-color:#33404f;color:#dfe6ee;
  box-shadow:0 12px 30px rgba(0,0,0,.55)}
body.koyu .dilmenu .sec:hover{background:#2a3646}
body.koyu .dilmenu .sec .tk{color:#57c07d}
''' + CSS_SON

# Yalniz HTML'de sabit duran metinler (data-en ile degistirilir)
DASH_ANAHTAR = {
 'Çalışma alanı', '⌘ Komut paleti',
 'Ctrl+K ile her ekrana, karta ve aksiyona tek satırdan ulaş.',
 '💰 Bugünkü ciro', '📑 Açık teklif', '🎯 Huni (ağırlıklı)', '🏦 Kredi borcu',
 '▲ %12,4 · dün 357.700 ₺', "18 teklif · 4'ü bu hafta doluyor",
 '11 açık fırsat', '3 gecikmiş taksit · 246.960 ₺',
 'satıra tıkla → ilgili ekran', '🎯 Satış hunisi',
 'Yeni', 'İlk görüşme', 'İhtiyaç analizi', 'Teklif', 'Kazanıldı',
 'Şimdi', 'Bekliyor',
 }

JS_IM = '/* === GN-DIL JS: Turkce (varsayilan) / Ingilizce === */'
JS_SON = '/* === GN-DIL JS son === */'

# Kabuk metinleri. Anahtar = Turkce karsilik (kaynakta okunur kalsin diye).
SOZLUK = {
    'Ara ya da komut yaz…': 'Search or type a command…',
    'Genel': 'General',
    'Gentegre Yapay Zeka': 'Gentegre AI',
    'Mesajlar': 'Messages',
    'Açık / koyu tema': 'Light / dark theme',
    'Bildirimler': 'Notifications',
    'Yardım': 'Help',
    'Kullanıcı Ayarları': 'User Settings',
    'Ekran, kayıt ya da komut…': 'Screen, record or command…',
    '＋ Yeni': '＋ New',
    '✎ Düzenle': '✎ Edit',
    '🖨️ Yazdır': '🖨️ Print',
    '▶ Listele': '▶ Run',
    '— Aksiyon Seç —': '— Select Action —',
    'Uygula': 'Apply',
    'Bu listede ara…': 'Search this list…',
    '▤ Liste': '▤ List',
    '▦ Grup': '▦ Group',
    '📊 Analiz': '📊 Analytics',
    '▦ Grid': '▦ Grid',
    'Grid menüsü — filtre satırı, sıralama, kolon ekle/çıkar, aktarım, görünüm kaydet':
        'Grid menu — filter row, sorting, add/remove columns, export, save view',
    'Grid menüsü — filtre, sıralama, kolon, aktarım':
        'Grid menu — filter, sorting, columns, export',
    'Grid menüsü': 'Grid menu',
    'Dökümler': 'Reports',
    'liste': 'list', 'döküm': 'report', 'ayar': 'settings', 'işlem': 'action',
    'Ekranlar': 'Screens', 'Aksiyonlar': 'Actions', 'Ayarlar': 'Settings',
    'Ekran': 'Screen', 'Aksiyon': 'Action', 'Ayar': 'Setting',
    'kart aç': 'open card', 'görünüm': 'appearance',
    'Temayı değiştir': 'Toggle theme',
    'Yeni cari': 'New account', 'Yeni stok kartı': 'New item',
    'Yeni satış faturası': 'New sales invoice', 'Yeni teklif': 'New quotation',
    'Yeni servis fişi': 'New service ticket', 'Yeni DÖF': 'New CAPA',
    'ekranı henüz tasarlanmadı.': 'screen has not been designed yet.',
    'Delphi karşılığı: ': 'Delphi counterpart: ',
    '⚠ Ekran dosyası açılamadı': '⚠ Screen file could not be opened',
    ' bulunamadı.': ' not found.',
    'Türkçe': 'Turkish', 'İngilizce': 'English',
    'Krediler': 'Loans', 'Çek / Senet': 'Cheque / Note',
    'Servis': 'Service', 'Kalite': 'Quality', 'Stok': 'Inventory',
    'Çalışma alanı': 'Workspace',
    '⌘ Komut paleti': '⌘ Command palette',
    'Ctrl+K ile her ekrana, karta ve aksiyona tek satırdan ulaş.':
        'Reach every screen, card and action from one line with Ctrl+K.',
    'Ana Sayfa': 'Home',
    'Info — Log Satırları': 'Info — Log Rows',
    'Excel’den Veri Al': 'Import from Excel',
    'Seçili Satırları Sil': 'Delete Selected Rows',
    'Modül İşlemleri': 'Module Actions',
    'Veri Alma ve Silme': 'Import and Delete',
    'Info': 'Info',
    '💰 Bugünkü ciro': "💰 Today's revenue",
    '📑 Açık teklif': '📑 Open quotations',
    '🎯 Huni (ağırlıklı)': '🎯 Pipeline (weighted)',
    '🏦 Kredi borcu': '🏦 Loan debt',
    '▲ %12,4 · dün 357.700 ₺': '▲ 12.4% · yesterday ₺357,700',
    "18 teklif · 4'ü bu hafta doluyor": '18 quotations · 4 expire this week',
    '11 açık fırsat': '11 open opportunities',
    '3 gecikmiş taksit · 246.960 ₺': '3 overdue instalments · ₺246,960',
    'satıra tıkla → ilgili ekran': 'click a row → related screen',
    '📅 Bugün': '📅 Today',
    '🎯 Satış hunisi': '🎯 Sales funnel',
    'Yeni': 'New',
    'İlk görüşme': 'First meeting',
    'İhtiyaç analizi': 'Needs analysis',
    'Teklif': 'Quotation',
    'Kazanıldı': 'Won',
    'Şimdi': 'Now',
    'Bekliyor': 'Pending',
    'Otel perde yenileme — teknik şartname sunumu': 'Hotel curtain renewal — technical spec presentation',
    'Plaza mefruşat teklifi revizesi': 'Plaza furnishing quotation revision',
    'İş Bankası kredi 17. taksit': 'İş Bankası loan · instalment 17',
    'Kasa sayımı ve POS mutabakatı': 'Cash count and POS reconciliation',
    '09:30 · Görüşme · FIR.2026/014': '09:30 · Meeting · OPP.2026/014',
    '11:00 · Teklif · TKF.2026/0231': '11:00 · Quotation · QTN.2026/0231',
    '14:00 · Ödeme · KRD.2025/014': '14:00 · Payment · LON.2025/014',
    '17:00 · Gün sonu': '17:00 · End of day',
    'Gecikmiş kredi taksiti': 'Overdue loan instalment',
    'Karşılıksız / protestolu kıymet': 'Bounced / protested instrument',
    'Geçerliliği bu hafta dolan': 'Expiring this week',
    'Termini geçmiş servis fişi': 'Overdue service ticket',
    'Kritik seviyenin altında': 'Below critical level',
    'Açık DÖF ve sapma': 'Open CAPA and deviations',
    'Kredi': 'Loan',
    'Çek / Senet': 'Cheque / Note',
    'Servis': 'Service',
    'Stok': 'Inventory',
    'Kalite': 'Quality',
}


def kabuk_yamasi():
    s = io.open(KABUK, encoding='utf-8').read()

    def sok(t, im, son):
        if im not in t:
            return t
        b = t.index(im); e = t.index(son, b) + len(son)
        while b > 0 and t[b - 1] == '\n': b -= 1
        while e < len(t) and t[e] == '\n': e += 1
        return t[:b] + '\n' + t[e:]

    s = sok(s, CSS_IM, CSS_SON)
    s = sok(s, JS_IM, JS_SON)
    s = re.sub(r'\n *<!-- GN-DIL -->.*?<!-- GN-DIL son -->', '', s, flags=re.S)

    # --- CSS: son </style>'dan once
    i = s.rindex('</style>', 0, s.index('</head>'))
    s = s[:i] + CSS + '\n' + s[i:]

    # --- tek bayrak dugmesi + acilir liste: "?" isaretinin SAGINA
    ank = '    <span class="ib" title="Yardım">?</span>\n'
    assert s.count(ank) == 1, 'yardim dugmesi bulunamadi'
    bayrak = ('    <!-- GN-DIL -->\n'
              '    <span class="dilsec" id="dilSec">\n'
              '      <button type="button" class="simdi" id="dilDugme" title="Dil / Language"'
              ' aria-haspopup="listbox" aria-expanded="false">'
              '<span class="bayrak"><img id="dilBayrak" src="%s" alt="TR"></span>'
              '<span class="ok">\u25be</span></button>\n'
              '      <div class="dilmenu" id="dilMenu" role="listbox">\n'
              '        <div class="sec on" data-dil="tr" role="option" aria-selected="true">'
              '<span class="bayrak"><img src="%s" alt=""></span><span>T\u00fcrk\u00e7e</span>'
              '<span class="tk">\u2713</span></div>\n'
              '        <div class="sec" data-dil="en" role="option" aria-selected="false">'
              '<span class="bayrak"><img src="%s" alt=""></span><span>English</span>'
              '<span class="tk"></span></div>\n'
              '      </div>\n'
              '    </span>\n'
              '    <!-- GN-DIL son -->\n') % (veri_url(tr_bayrak()), veri_url(tr_bayrak()),
                                              veri_url(gb_bayrak()))
    s = s.replace(ank, ank + bayrak, 1)

    # --- JS: ana blogun sonuna (kurNav/bolumSec tanimli olduktan sonra)
    js = JS_IM + '''
(function(){
  var SOZ = ''' + json.dumps(SOZLUK, ensure_ascii=False) + ''';
  var BAYRAK = {tr:''' + json.dumps(veri_url(tr_bayrak())) + ''',
                en:''' + json.dumps(veri_url(gb_bayrak())) + '''};
  /* Kabuk metni cevirisi. Anahtar Turkce; karsiligi yoksa metin aynen kalir,
     boylece sozluge eklenmemis bir yazi kaybolmaz. */
  window.T  = function(tr){ return DIL === 'en' ? (SOZ[tr] || tr) : tr; };
  /* Dilden bagimsiz Ingilizce karsilik — data-en niteligi uretmek icin. */
  window.EN = function(tr){ return SOZ[tr] || tr; };
  /* Modul / bolum adi: gentegre_data.js icindeki ad_en / grup_en alanlari. */
  window.AD  = function(x){ return (DIL === 'en' && x && x.ad_en)   ? x.ad_en   : (x ? x.ad : ''); };
  window.GRP = function(x){ return (DIL === 'en' && x && x.grup_en) ? x.grup_en : (x ? x.grup : ''); };

  function yaz(){
    document.documentElement.lang = DIL;
    var q = function(s){ return document.querySelector(s); };
    var e;
    e = q('#araAc span');  if (e) e.textContent = T('Ara ya da komut yaz…');
    e = q('#ustAi');       if (e) e.title = T('Gentegre Yapay Zeka');
    e = q('#ustMesaj');    if (e) e.title = T('Mesajlar');
    e = q('#temaDugme');   if (e) e.title = T('Açık / koyu tema');
    e = q('#kpGiris');     if (e) e.placeholder = T('Ekran, kayıt ya da komut…');
    var ib = document.querySelectorAll('.ustsag .ib');
    if (ib[1]) ib[1].title = T('Bildirimler');
    if (ib[2]) ib[2].title = T('Yardım');
    e = q('#kulAvatar');
    if (e) e.title = T('Kullanıcı Ayarları') + ' — Mehmet Yıldız';
    var bay = document.getElementById('dilBayrak');
    if (bay){ bay.src = BAYRAK[DIL]; bay.alt = DIL.toUpperCase(); }
    document.querySelectorAll('#dilMenu .sec').forEach(function(x){
      var se = x.dataset.dil === DIL;
      x.classList.toggle('on', se);
      x.querySelector('.tk').textContent = se ? '\u2713' : '';
      x.setAttribute('aria-selected', se ? 'true' : 'false');
    });
    /* data-en tasiyan sabit ogeler (yan panel, gosterge paneli) */
    document.querySelectorAll('[data-en]').forEach(function(x){
      if (x.dataset.tr == null) x.dataset.tr = x.innerHTML;
      x.innerHTML = (DIL === 'en') ? x.dataset.en : x.dataset.tr;
    });
    /* menu, baslik, arac cubugu ve cipler yeniden cizilsin */
    if (typeof kurNav === 'function') kurNav();
    if (typeof bolumSec === 'function' && typeof aktifBolum !== 'undefined') bolumSec(aktifBolum);
    /* ekranlar ileride cevap verebilsin diye haber ver */
    document.querySelectorAll('.sf iframe,.kwin iframe').forEach(function(fr){
      try{ fr.contentWindow.postMessage({gentegre:'dil', dil:DIL}, '*'); }catch(x){}
    });
  }

  window.dilAyar = function(d){
    DIL = (d === 'en') ? 'en' : 'tr';
    try{ localStorage.setItem('gnDil', DIL); }catch(x){}
    yaz();
  };

  var dg = document.getElementById('dilDugme'), dm = document.getElementById('dilMenu');
  function menuKapa(){ if (dm){ dm.classList.remove('on'); dg.setAttribute('aria-expanded','false'); } }
  if (dg && dm){
    dg.addEventListener('click', function(ev){
      ev.stopPropagation();
      var ac = !dm.classList.contains('on');
      dm.classList.toggle('on', ac);
      dg.setAttribute('aria-expanded', ac ? 'true' : 'false');
    });
    dm.addEventListener('click', function(ev){
      ev.stopPropagation();
      var x = ev.target.closest('.sec'); if (!x) return;
      menuKapa(); dilAyar(x.dataset.dil);
    });
    document.addEventListener('click', menuKapa);
    document.addEventListener('keydown', function(e){ if (e.key === 'Escape') menuKapa(); });
  }
  yaz();
})();
''' + JS_SON

    ank2 = "document.getElementById('temaDugme').addEventListener('click',function(){ temaAyar(tema==='acik'?'koyu':'acik'); });"
    assert s.count(ank2) == 1, 'tema olayi bulunamadi'
    s = s.replace(ank2, ank2 + '\n\n' + js, 1)

    # --- DIL degiskeni: aktifModul satirinin yanina
    ad = "var aktifModul='giris', aktifBolum='home', tema='acik';"
    assert s.count(ad) == 1
    s = s.replace(ad, ad + "\n/* Dil: Turkce varsayilan; secim tarayicida saklanir (GN-DIL) */\n"
                       "var DIL='tr'; try{ DIL=localStorage.getItem('gnDil')==='en'?'en':'tr'; }catch(e){}", 1)

    # --- kabuk metinlerini T()/AD()/GRP() uzerinden gecir
    degis = [
      # yan menu
      ("'<span class=\"ic\">'+m.ic+'</span><span>'+(m.ad==='Gen'?'Genel':m.ad)+'</span><span class=\"ok\">›</span>'",
       "'<span class=\"ic\">'+m.ic+'</span><span>'+(m.ad==='Gen'?T('Genel'):AD(m))+'</span><span class=\"ok\">›</span>'"),
      ("a.appendChild(el('div','agrp','<span>'+(b.gic||'📁')+'</span><span>'+b.grup+'</span>'));",
       "a.appendChild(el('div','agrp','<span>'+(b.gic||'📁')+'</span><span>'+GRP(b)+'</span>'));"),
      ("var rz=b.tur==='liste'?'liste':b.tur==='dokum'?'döküm':b.tur==='ayar'?'ayar':b.tur==='islem'?'işlem':'';",
       "var rz=b.tur==='liste'?T('liste'):b.tur==='dokum'?T('döküm'):b.tur==='ayar'?T('ayar'):b.tur==='islem'?T('işlem'):'';"),
      ("'<span>'+b.ic+'</span><span>'+b.ad+'</span><span class=\"rz\">'+rz+'</span>'",
       "'<span>'+b.ic+'</span><span>'+AD(b)+'</span><span class=\"rz\">'+rz+'</span>'"),
      # baslik / kirintili yol
      ("document.getElementById('kirin').innerHTML=(m.ad==='Gen'?'Genel':m.ad)+' <span class=\"ay2\">›</span> '+b.ad;",
       "document.getElementById('kirin').innerHTML=(m.ad==='Gen'?T('Genel'):AD(m))+' <span class=\"ay2\">›</span> '+AD(b);"),
      ("document.getElementById('sayfaAd').textContent=b.ad;",
       "document.getElementById('sayfaAd').textContent=AD(b);"),
      ("sh.appendChild(el('div','kyok','<span class=\"bk\">'+b.ic+'</span><b>'+b.ad+'</b> ekranı henüz tasarlanmadı.<br>'+\n"
       "        '<span style=\"font-size:12px\">Delphi karşılığı: '+(b.yol||'')+'</span>'));",
       "sh.appendChild(el('div','kyok','<span class=\"bk\">'+b.ic+'</span><b>'+AD(b)+'</b> '+T('ekranı henüz tasarlanmadı.')+'<br>'+\n"
       "        '<span style=\"font-size:12px\">'+T('Delphi karşılığı: ')+(b.yol||'')+'</span>'));"),
      # arac cubugu
      ("k.appendChild(el('div','d bir','▶ Listele'));", "k.appendChild(el('div','d bir',T('▶ Listele')));"),
      ("k.appendChild(el('div','d','🖨️ Yazdır'));", "k.appendChild(el('div','d',T('🖨️ Yazdır')));"),
      ("var yeni=el('div','d bir'+(liste?'':' pas'),'＋ Yeni');",
       "var yeni=el('div','d bir'+(liste?'':' pas'),T('＋ Yeni'));"),
      ("var duz=el('div','d'+(liste?'':' pas'),'✎ Düzenle');",
       "var duz=el('div','d'+(liste?'':' pas'),T('✎ Düzenle'));"),
      ("var yaz=el('div','d','🖨️ Yazdır');", "var yaz=el('div','d',T('🖨️ Yazdır'));"),
      # cipler
      ("var s='<option value=\"\">— Aksiyon Seç —</option>';",
       "var s='<option value=\"\">'+T('— Aksiyon Seç —')+'</option>';"),
      ("uyg.className='uygd'; uyg.id='aksUygula'; uyg.textContent='Uygula'; uyg.disabled=true;",
       "uyg.className='uygd'; uyg.id='aksUygula'; uyg.textContent=T('Uygula'); uyg.disabled=true;"),
      ("var gs=el('div','gara','🔎 <input placeholder=\"Bu listede ara…\"><span class=\"say\"></span>');",
       "var gs=el('div','gara','🔎 <input placeholder=\"'+T('Bu listede ara…')+'\"><span class=\"say\"></span>');"),
      ("['liste|▤ Liste','grup|▦ Grup','analiz|📊 Analiz'].forEach(function(x){\n    var p=x.split('|'), d=el('div','cip'+(p[0]==='liste'?' on':''),p[1]);",
       "['liste|▤ Liste','grup|▦ Grup','analiz|📊 Analiz'].forEach(function(x){\n    var p=x.split('|'), d=el('div','cip'+(p[0]==='liste'?' on':''),T(p[1]));"),
      ("var gd=el('div','cip grid yok','▦ Grid'); gd.id='gridCip';",
       "var gd=el('div','cip grid yok',T('▦ Grid')); gd.id='gridCip';"),
      ("gd.title='Grid menüsü — filtre satırı, sıralama, kolon ekle/çıkar, aktarım, görünüm kaydet';",
       "gd.title=T('Grid menüsü — filtre satırı, sıralama, kolon ekle/çıkar, aktarım, görünüm kaydet');"),
      ("g0.title = d.ozet ? 'Grid menüsü · '+d.ozet : 'Grid menüsü — filtre, sıralama, kolon, aktarım'; }",
       "g0.title = d.ozet ? T('Grid menüsü')+' · '+d.ozet : T('Grid menüsü — filtre, sıralama, kolon, aktarım'); }"),
      ("if(d.gentegre==='dokum') document.getElementById('sayfaAd').textContent='Dökümler · '+d.ad;",
       "if(d.gentegre==='dokum') document.getElementById('sayfaAd').textContent=T('Dökümler')+' · '+d.ad;"),
      # komut paleti
      ("l.push({tip:'Ekran',ic:b.ic,ad:b.ad,yn:(m.ad==='Gen'?'Genel':m.ad),mod:m.id,bol:b.id}); }); });",
       "l.push({tip:'Ekran',ic:b.ic,ad:AD(b),yn:(m.ad==='Gen'?T('Genel'):AD(m)),mod:m.id,bol:b.id}); }); });"),
      ("].forEach(function(a){ l.push({tip:'Aksiyon',ic:a[0],ad:a[1],yn:'kart aç',mod:a[2],bol:a[3],yeni:1}); });",
       "].forEach(function(a){ l.push({tip:'Aksiyon',ic:a[0],ad:T(a[1]),yn:T('kart aç'),mod:a[2],bol:a[3],yeni:1}); });"),
      ("l.push({tip:'Ayar',ic:'🌙',ad:'Temayı değiştir',yn:'görünüm',tema:1});",
       "l.push({tip:'Ayar',ic:'🌙',ad:T('Temayı değiştir'),yn:T('görünüm'),tema:1});"),
      ("kpL.appendChild(el('div','kpb',x.tip==='Ekran'?'Ekranlar':x.tip==='Aksiyon'?'Aksiyonlar':'Ayarlar')); son=x.tip; }",
       "kpL.appendChild(el('div','kpb',x.tip==='Ekran'?T('Ekranlar'):x.tip==='Aksiyon'?T('Aksiyonlar'):T('Ayarlar'))); son=x.tip; }"),
      # varsayilan aksiyon listesi
      ("var AKS_VARSAYILAN_UST = [{id:'info', ad:'Info — Log Satırları', ic:'ℹ', grup:'Info'}];",
       "var AKS_VARSAYILAN_UST = [{id:'info', adT:'Info — Log Satırları', ic:'ℹ', grupT:'Info'}];"),
      ("  {id:'excelal', ad:'Excel’den Veri Al', ic:'📥', grup:'Veri Alma ve Silme'},",
       "  {id:'excelal', adT:'Excel’den Veri Al', ic:'📥', grupT:'Veri Alma ve Silme'},"),
      ("  {id:'sil', ad:'Seçili Satırları Sil', ic:'🗑', grup:'Veri Alma ve Silme', tehlike:true}",
       "  {id:'sil', adT:'Seçili Satırları Sil', ic:'🗑', grupT:'Veri Alma ve Silme', tehlike:true}"),
      ("    return {id:'arac'+i, ad:a, ic:'▸', grup:'Modül İşlemleri'}; });",
       "    return {id:'arac'+i, ad:T(a), ic:'▸', grup:T('Modül İşlemleri')}; });"),
      ("  return AKS_VARSAYILAN_UST.concat(orta, AKS_VARSAYILAN_ALT);",
       "  var ct=function(x){ return {id:x.id, ad:x.ad||T(x.adT), ic:x.ic,\n"
       "      grup:x.grup||T(x.grupT), tehlike:x.tehlike}; };\n"
       "  return AKS_VARSAYILAN_UST.map(ct).concat(orta, AKS_VARSAYILAN_ALT.map(ct));"),
      # ajanda + uyari satirlari (JS ile uretiliyor)
      ("'<span class=\"nk '+u[0]+'\"></span><span class=\"ad\">'+u[2]+'<small>'+u[1]+'</small></span>'+",
       "'<span class=\"nk '+u[0]+'\"></span><span class=\"ad\" data-en=\"'+\n"
       "      (EN(u[2])+'<small>'+EN(u[1])+'</small>').replace(/&/g,'&amp;').replace(/\"/g,'&quot;')+\n"
       "      '\">'+u[2]+'<small>'+u[1]+'</small></span>'+"),
    ]
    bulunamayan = []
    for a, b in degis:
        if a in s:
            s = s.replace(a, b, 1)
        elif b not in s:
            bulunamayan.append(a[:60])
    if bulunamayan:
        raise SystemExit('KALIP BULUNAMADI:\n  ' + '\n  '.join(bulunamayan))


    # --- sabit ogelere data-en ekle (yan panel + gosterge paneli) ---
    def isaretle(t, ic, en):
        """<tag ...>ic</tag> kalibindaki etikete data-en ekler."""
        hedef = '>' + ic + '<'
        i = t.find(hedef)
        if i < 0:
            return t, False
        # ondeki etiketin '>' konumu = i
        if ' data-en=' in t[t.rfind('<', 0, i):i]:
            return t, True
        ek = ' data-en="%s"' % en.replace('&', '&amp;').replace('"', '&quot;')
        return t[:i] + ek + t[i:], True

    atlanan = []
    for tr, en in SOZLUK.items():
        if tr not in DASH_ANAHTAR:
            continue
        s2, ok = isaretle(s, tr, en)
        if ok: s = s2
        else: atlanan.append(tr)
    if atlanan:
        print('  data-en eklenemeyen (JS icinde uretiliyor olabilir):', len(atlanan))


    # --- ajanda satirlari (ic ice <small> tasidigi icin ayri ele alinir) ---
    import re as _re
    def ajanda(t):
        kal = _re.compile(r'<span class="ad">([^<]+)<small>([^<]+)</small></span>')
        def yer(m):
            a_en = SOZLUK.get(m.group(1), m.group(1))
            b_en = SOZLUK.get(m.group(2), m.group(2))
            nit = (a_en + '<small>' + b_en + '</small>').replace('&', '&amp;').replace('"', '&quot;')
            return '<span class="ad" data-en="%s">%s<small>%s</small></span>' % (nit, m.group(1), m.group(2))
        return kal.sub(yer, t)
    s = ajanda(s)
    s = s.replace('<h3>⚠ Dikkat gerektirenler <span class="sg"',
                  '<h3 data-en=\'⚠ Needs attention <span class="sg">click a row → related screen</span>\'>'
                  '⚠ Dikkat gerektirenler <span class="sg"')
    s = s.replace('<h3>📅 Bugün <span class="sg">Ayşe Demir</span></h3>',
                  '<h3 data-en=\'📅 Today <span class="sg">Ayşe Demir</span>\'>'
                  '📅 Bugün <span class="sg">Ayşe Demir</span></h3>')

    io.open(KABUK, 'w', encoding='utf-8').write(s)
    return len(degis)


if __name__ == '__main__':
    a, g = veri_yamasi()
    n = kabuk_yamasi()
    print('gentegre_data.js : %d ad_en, %d grup_en' % (a, g))
    print('gentegre_v4_web  : %d kalip cevrildi, sozlukte %d girdi' % (n, len(SOZLUK)))
