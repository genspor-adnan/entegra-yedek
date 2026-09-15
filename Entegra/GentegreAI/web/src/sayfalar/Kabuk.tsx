import { useEffect, useState } from 'react';
import { sonMenuGorunen } from './menuSonKullanilan';
import { useMenuTercihleri, useKullaniciAyari } from './kabuk/useMenuTercihleri';
import { DILLER } from '../bilesenler/diller';
import { KullaniciAyarlari } from '../bilesenler/KullaniciAyarlari';
import { useProfilResmi } from '../bilesenler/profilResmi';
import { modulAcikMi } from './listeTanimlari';
import { TEMA_ADI, TEMA_IKON, temaOku, temaSonraki, temaUygula, type Tema }
  from '../bilesenler/tema';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { ZilPaneli } from '../bilesenler/ZilPaneli';
import { Bayrak } from '../bilesenler/Bayrak';
import { c, cm, ceviriYukle, ceviriDinle } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';
import { urunAdi, modUyar } from '../api/sozlesme';
import { AiRehberPaneli } from '../bilesenler/AiRehberPaneli';
import { LISTELER } from './Liste';

interface MenuOgesi {
  yol: string;
  ad: string;
  ic: string;
  rz: string;
  grup?: string;
  /** Grubun CEVRILMEMIS adi: sira tablosu dilden bagimsiz eslessin. */
  grupHam?: string;
  altGrup?: string;
  /** Grup ICINDEKI sira (kucuk once). Gruplarin kendi sirasi degismez. */
  sira?: number;
}

/**
 * ANA MENU GRUP SIRASI (kullanici) — HASTA AKISINA gore: kayit kabul, muayene,
 * sonra tetkik (laboratuvar, radyoloji), sonra bildirim. Grup sirasi eskiden
 * `listeTanimlari` dizisindeki ILK ogeden geliyordu; sirayi degistirmek icin
 * tanim bloklarini dosyada tasimak gerekiyordu ve Cari, Muayene'nin onune
 * dusuyordu.
 *
 * Ad CEVRILMEMIS yazilir (grupHam): dil degisince sira degismemeli. Listede
 * OLMAYAN grup, tanim sirasindaki yerini korur ve bu listedekilerden SONRA
 * gelir; Yonetim her zaman en sondadir (asagida).
 */
/**
 * MENU SIRASI (plan: dokuman/11_MENU_DUZENI_PLANI.md · mockup
 * Ekranlar/Ayarlar/menu_duzeni.html).
 *
 * TEK LISTE, iki urun: sira hasta akisini ve ticari akisi UST USTE koyar -
 * urun modu ve modul suzmesi hangi grubun cizilecegine zaten karar veriyor
 * (HBYS'de Satis/Alis/Uretim yok, ERP'de klinik gruplar yok). Iki ayri liste
 * tutmak, ortak gruplarin (Finans, Stok, Muhasebe, Yonetim) sirasini iki
 * yerde bakim etmek demekti.
 *
 * 18 grup -> 15: Kasa+Banka = Finans · Cari+CRM = Cari & CRM · Dokuman ve
 * Roller Yonetim altina · Mesajlar/AI ust cubuga (arac, is akisi degil).
 */
const GRUP_SIRA_HBYS = [
  // hasta akisi
  // GOZ MUAYENEDEN SONRA (kullanici istegi): goz poliklinigi gunluk is hacmi
  //   en yuksek dallardan biri; menude ayaktan hasta akisinin hemen ardinda
  //   duruyor. Yatan hasta ise onun yerine (lab/radyoloji sonrasina) gecti -
  //   yatis gun boyu acik kalan bir ekran degil, gune birkac kez girilen bir
  //   is; sik acilan dalin ustte olmasi tiklama sayisini dusuruyor.
  'Randevu', 'Kayıt Kabul', 'Muayene', 'Göz', 'Laboratuvar', 'Radyoloji', 'Yatan Hasta',
  'Kurumlar & Sigorta', 'e-Nabız',
  // PARA HEMEN ARKASINDA (kullanici): hastanin isi bittiginde sira tahsilata
  //   gelir - vezne gun boyu Finans'a girip cikar, listenin dibinde olmamali.
  'Finans',
  // malzeme - kayit
  // Cari & CRM HBYS'de de var (tedarikci, kisi, gorev): listede YOKSA en dibe
  //   dusuyordu - Yonetim'in bile altina. Yeri stok ile muhasebe arasi.
  // DOKUMAN KENDI ANA GRUBU ve DEMIRBASTAN ONCE (kullanici): Yonetim altina
  //   alt-grup olarak konunca ana menuden kayboldu - kurum dokumani gunluk
  //   is, ayar degil.
  'Stok & Hizmet', 'Cari & CRM', 'Muhasebe', 'İK & Prim', 'Doküman', 'Demirbaş',
];

/**
 * ERP'de sira TICARI AKISTIR: cari -> satis -> alis -> stok -> uretim -> para.
 * Finans burada AKISIN SONUNDA durur; HBYS'de hasta akisinin hemen arkasinda.
 * Tek liste ikisini birden veremiyordu - ayni grubun yeri urune gore farkli.
 */
const GRUP_SIRA_ERP = [
  'Cari & CRM', 'Satış', 'Alış', 'Stok & Hizmet', 'Üretim',
  'Finans', 'Muhasebe', 'İK & Prim', 'Doküman', 'Demirbaş',
];

type MenuSatiri =
  | { tur: 'duz'; m: MenuOgesi }
  | { tur: 'grup'; ad: string; alt: MenuOgesi[] };

/** Sira korunarak grupla: her benzersiz grup adi ILK gorundugu yerde acilir. */
function grupla(liste: MenuOgesi[], sec: (m: MenuOgesi) => string | undefined): MenuSatiri[] {
  const satirlar: MenuSatiri[] = [];
  const indeks = new Map<string, number>();
  liste.forEach(m => {
    const ad = sec(m);
    if (!ad) { satirlar.push({ tur: 'duz', m }); return }
    if (!indeks.has(ad)) {
      indeks.set(ad, satirlar.length);
      satirlar.push({ tur: 'grup', ad, alt: [] });
    }
    (satirlar[indeks.get(ad)!] as { tur: 'grup'; ad: string; alt: MenuOgesi[] }).alt.push(m);
  });
  return satirlar;
}

/**
 * Uygulama kabugu — ana mockup (Ekranlar/gentegre_v4_web.html, "Konsept C") duzeni:
 *   ust (56px): marka + genel arama (Ctrl+K) + ikonlar + kullanici
 *   govde: yan (250px menu, altta komut paleti ipucu) + ana (sayfa icerigi)
 *
 * Menu kullanicinin YETKISINE gore uretilir; yetkisiz modul hic cizilmez.
 */
/**
 * Ana menu grup ikonlari. Hepsi ayni kart ikonuydu (📇) - gruplar birbirinden
 * ayirt edilemiyordu. Grup adi ANAHTAR: yeni grup eklenirse buraya bir satir.
 * Listede olmayan grup icin notr klasor cizilir.
 */
const GRUP_IKON: Record<string, string> = {
  'Randevu': '📅',
  'Kayıt Kabul': '🚑',
  'Radyoloji': '☢️',
  'Göz': '👁️',
  'Yatan Hasta': '🛏️',
  // e-Nabiz (kullanici): Radyolojiden sonra ayri ana menu. Bayrak emojisi
  //   Windows'ta harf olarak ciziliyordu; "nabiz" = atan kalp.
  'e-Nabız': '💓',
  // Klinik moduller (360): kurum profilinde kapaliysa menude hic gorunmezler.
  'Muayene': '🩺',
  'Laboratuvar': '🧪',
  // Cari + CRM tek grup (plan): ayni kisiler iki yerde araniyordu.
  'Cari & CRM': '🤝',
  'Satış':   '🛍️',
  'Alış':    '🛒',
  // Kasa + Banka = Finans (plan): "tahsilat nerede" sorusu iki gruba
  //   bakilarak cevaplaniyordu.
  'Finans':  '💰',
  // HBYS'te "Cari" yabanci bir sozcuk; kurum/sigorta ekranlari kendi grubunda.
  'Kurumlar & Sigorta': '🏛️',
  'Üretim':  '🏭',
  'Stok & Hizmet': '📦',
  // Muhasebe ana menusu (kullanici): Stok'tan sonra gelir - hesap plani, fisler,
  //   fis satirlari, masraf merkezleri ve islem turleri Yonetim'den buraya alindi.
  'Muhasebe': '⚖️',
  'İK & Prim': '👥',
  // Gemi dumeni (kullanici, ucuncu deneme): Unicode'da GERCEK bir gemi
  //   dumeni emojisi YOK. Denenenler: ☸️ (dharma cakri - dini sembol),
  //   🛞 (tekerlek - lastik gibi cizilir). ⎈ (U+2388) anlamca dogru ama
  //   cogu yazi tipinde bos kare. Pusula denizcilik cagrisimini koruyor
  //   ve her platformda ayni cizilir.
  'Yönetim': '🧭',
};

/** ALT GRUP ikonu: ikinci seviye eskiden HEP ⚙️ ciziyordu, ayar olmayan alt
    gruplarda yanlis okunuyordu (kullanici: Prim'in logosu % olsun). Tabloda
    olmayan alt grup eskisi gibi ⚙️ kalir. */
const ALTGRUP_IKON: Record<string, string> = {
  'Prim': '%',
  // Her grubun SON alt grubu "Ayarlar" (plan kural 2): gunluk is listeleri
  //   ustte, tanimlar ve ayarlar altta - hangi grupta olursan ol ayni desen.
  'Ayarlar': '⚙️',
  'Güvenlik': '🛡️',
  'Platform': '🧩',
  'Doküman': '📁',
  'Veri Aktarımı': '⬆️',
  // Laboratuvarin uc dali (kullanici): ortak akis (istem, numune, sonuc)
  //   grubun kokunde kalir, dala ozel ekranlar bu basliklarin altinda.
  // Karekod bildirimi iki kurum: ITS ilac, UTS tibbi cihaz - notr disli
  //   ikisini de aynilastiriyordu.
  'İTS': '💊',
  // UTS = tibbi CIHAZ takibi (kullanici): cihaz simgesi - stetoskop muayeneyi,
  //   rontgen goruntulemeyi cagristiriyordu.
  'ÜTS': '🔌',
  'Biyokimya': '⚗️',
  'Mikrobiyoloji': '🦠',
  'Genetik': '🧬',
};

/** Cevrilmis grup adindan ikona: menu adi dile gore degisince Turkce anahtarli
    GRUP_IKON eslesmiyordu (194). Ceviriyi burada TERSINE cevirmek yerine
    cevrilmis adlari da tabloya ekliyoruz - liste kisa ve dil eklendikce buyur. */
const GRUP_IKON_CEV: Record<string, string> = {
  'Appointments': '📅', 'Termine': '📅',
  'Admissions': '🚑', 'Aufnahme': '🚑',
  'Radiology': '☢️', 'Radiologie': '☢️',
  'Examination': '🩺', 'Untersuchung': '🩺',
  'Laboratory': '🧪', 'Labor': '🧪',
  'Accounts': '🤝', 'Geschäftspartner': '🤝',
  'Sales': '🛍️', 'Verkauf': '🛍️',
  'Purchasing': '🛒', 'Einkauf': '🛒',
  'Cash': '💵', 'Kasse': '💵',
  'Bank': '🏦',
  'Items & Services': '📦', 'Artikel & Leistungen': '📦',
  'Accounting': '⚖️', 'Buchhaltung': '⚖️',
  'HR': '👥', 'Personal': '👥',
  'Administration': '🛞', 'Verwaltung': '🛞',
};


export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, dilDegistir, yetki } = useOturum();
  const konum = useLocation();
  const git = useNavigate();

  // Menu, liste tanimlarindan uretilir; yetkisiz modul hic cizilmez. menuGrup verilen
  //   ogeler ("Cari" -> Musteri/Tedarikci/Kisi Listesi) acilir-kapanir bir ana menu
  //   altinda TOPLANIR; menuGrup'suz ogeler eskisi gibi duz sirada kalir.
  const yetkiliListeler = LISTELER.filter(l => yetki(l.yetkiKodu) && !l.menuGizli
    // Urun modu suzmesi (215): Kayit Kabul yalniz GenoTIP AI'da.
    && (!l.urunModu || modUyar(l.urunModu, kullanici?.urunModu))
    // MODUL suzmesi (359): kurum profilinde kapali modulun menusu cizilmez.
    && modulAcikMi(l, kullanici?.moduller));
  const moduller: MenuOgesi[] =
    yetkiliListeler.map(l => ({
      yol: l.menuYol ?? `/${l.rota ?? l.kaynak}`, ad: cm(l.menuAd), ic: l.ic,
      rz: l.ozelSayfa ? 'ayar' : 'liste',
      grup: l.menuGrup ? cm(l.menuGrup) : undefined,
      grupHam: l.menuGrup,
      altGrup: l.menuAltGrup ? cm(l.menuAltGrup) : undefined,
      sira: l.menuSira,
    }));

  // Iki seviye: grup (Cari, Kasa, Yönetim…) ve grubun icinde alt grup
  //   (Yönetim › Ayarlar). Ayni yardimci iki seviyede de kullanilir.
  const satirlar = grupla(moduller, m => m.grup);
  // YONETIM HER ZAMAN EN SONDA (kullanici): grup sirasi tanim dizisindeki ILK
  //   ogeden gelir, Yonetim'in ilk ogesi (Kampanyalar) dizinin ortasinda oldugu
  //   icin menunun ortasina dusuyordu. Ayarlar/roller gibi seyrek kullanilan
  //   ekranlar en altta olsun diye grup burada sona alinir - dil degisince ad
  //   da degistiginden cevirili adlar da kontrol edilir.
  // GRUP SIRASI: once GRUP_SIRA'daki duzen, sonra listede olmayanlar kendi
  //   sirasinda. Duz ogeler (grubu olmayan, or. Ana Sayfa) YERINDE kalir -
  //   yalniz grup satirlari kendi aralarinda siralanir.
  // Urun modu 2 = HBYS (GenoTIP AI); otekiler ticari sirayi kullanir.
  const grupSirasi = kullanici?.urunModu === 2 ? GRUP_SIRA_HBYS : GRUP_SIRA_ERP;
  const grupYeri = (sat: MenuSatiri) => {
    if (sat.tur !== 'grup') return -1;
    const ham = sat.alt.find(m => m.grupHam)?.grupHam ?? sat.ad;
    const i = grupSirasi.indexOf(ham);
    return i < 0 ? grupSirasi.length : i;
  };
  const grupSatirlari = satirlar.filter(x => x.tur === 'grup');
  const sirali = [...grupSatirlari]
    .map((sat, i) => ({ sat, i }))
    .sort((a, b) => grupYeri(a.sat) - grupYeri(b.sat) || a.i - b.i)
    .map(x => x.sat);
  let sayac = 0;
  for (let i = 0; i < satirlar.length; i++)
    if (satirlar[i].tur === 'grup') satirlar[i] = sirali[sayac++];

  const YONETIM_ADLARI = ['Yönetim', 'Administration', 'Verwaltung'];
  const yonetimIndeks = satirlar.findIndex(
    s => s.tur === 'grup' && YONETIM_ADLARI.includes(s.ad));
  if (yonetimIndeks >= 0) satirlar.push(...satirlar.splice(yonetimIndeks, 1));
  // Sira YALNIZ grup icinde uygulanir: gruplarin kendi sirasi (Hasta, Cari,
  //   Satis...) tanim sirasindan gelir, menuSira onu kaydirmamali.
  satirlar.forEach(sat => {
    if (sat.tur !== 'grup') return;
    sat.alt = sat.alt
      .map((m, i) => ({ m, i }))
      .sort((a, b) => (a.m.sira ?? 900 + a.i) - (b.m.sira ?? 900 + b.i) || a.i - b.i)
      .map(x => x.m);
  });

  /**
   * FAVORILER (kullanici): alt menu ogelerinin sagindaki yildiz ☆ tiklaninca
   * oge menunun EN USTUNDEKI "Favoriler" bolumune de girer; asil yerinde ★
   * dolu gorunur, tekrar tiklaninca cikar.
   *
   * SUNUCUDA saklanir (397, public.kullanici_tercih): localStorage'ta iken
   * site verisi silinince, baska makineden ya da baska adresten (dev
   * localhost:5173 ile sunucudaki /ai AYRI origin) girilince liste bos
   * geliyordu - kullanicinin gozunde "Favoriler menusu kayboldu".
   * localStorage artik yalniz CEVRIMDISI KOPYA: sunucuya ulasilamazsa menu
   * yine dolu acilir, ilk yazmada sunucu tekrar dogruyu ogrenir.
   */
  // MENU TERCIHLERI (favoriler sunucuda + en son kullanilanlar yerelde)
  //   kendi kancasinda: kabuk/useMenuTercihleri.
  const { favoriler, favoriToggle, sonMenuler, sonKaydet } =
    useMenuTercihleri(kullanici?.id,
      { aktif: kullanici?.subeId, liste: kullanici?.subeler ?? [], degistir: subeDegistir });

  /**
   * KAYIT NOKTASI ROTA DEGISIMI (menu tiklamasi DEGIL): ayni ekrana favoriden,
   * dogrudan URL'den, geri tusundan ya da bir kart icindeki baglantidan da
   * gelinebiliyor. Menuye onClick baglamak bunlarin cogunu kacirirdi.
   * En UZUN eslesen yol alinir - "/kasa-islem" ile "/kasa" ayni anda eslesirse
   * dogru olan derindeki.
   */
  useEffect(() => {
    const hepsi = satirlar.flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt));
    const eslesen = hepsi
      .filter(m => konum.pathname === m.yol || konum.pathname.startsWith(m.yol + '/'))
      .sort((a, b) => b.yol.length - a.yol.length)[0];
    if (eslesen) sonKaydet(eslesen.yol);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [konum.pathname, moduller]);

  /** "liste" rozetinin yerine yildiz: bos = ekle, dolu = cikar. */
  const yildiz = (yol: string) => (
    <button type="button" className="rz"
            title={c(favoriler.includes(yol) ? 'Favorilerden çıkar' : 'Favorilere ekle')}
            style={{ border: 0, background: 'transparent', cursor: 'pointer',
                     padding: 0, fontSize: 13, lineHeight: 1 }}
            onClick={e => { e.preventDefault(); e.stopPropagation(); favoriToggle(yol) }}>
      {favoriler.includes(yol) ? '★' : '☆'}
    </button>
  );

  // Acik/kapali durumu kullanici ELLE degistirmedikce, aktif alt-ogeyi iceren grup
  //   otomatik acik gelir (dogrudan /tedarikci gibi bir URL'e gelindiginde de gorunsun).
  const [acikGruplar, setAcikGruplar] = useState<Record<string, boolean>>({});
  // KULLANICI AYARLARI PENCERESI (sifre + dil) kendi kancasinda.
  const ayar = useKullaniciAyari({
    mevcutDil: kullanici?.dil ?? 0, dilDegistir, cikisYap,
  });
  /** Bayrak dugmesinin acilir listesi. */
  const [dilMenusu, setDilMenusu] = useState(false);
  const [tema, setTema] = useState<Tema>(() => temaOku());
  // DIL (194): sozluk sunucudan iner; degisince menu yeniden cizilsin diye
  //   sayac artirilir (sozluk modul kapsaminda, React state'i degil).
  const [ceviriSurumu, setCeviriSurumu] = useState(0);
  useEffect(() => ceviriDinle(() => setCeviriSurumu(s => s + 1)), []);
  // Sozluk MODUL kapsaminda (React state degil): indiginde React kendiliginden
  //   yeniden cizmez. Menu bu bilesenin icinde oldugu icin state degisimiyle
  //   tazelenir; ANA ALAN (liste/kart) ayri agac - ona `key` verilerek yeniden
  //   kurulur. Dil degisimi nadir ve bilincli bir eylem; sayfa yenilemekle
  //   ayni etkiyi verir ama oturum ve konum korunur.
  useEffect(() => { void ceviriYukle(kullanici?.dil ?? 0) }, [kullanici?.dil]);
  /** Sol menu acik/kapali - tercih tarayicida kalir (dar ekranda kapali calisilir). */
  const [menuKapali, setMenuKapali] = useState<boolean>(() => {
    try { return localStorage.getItem('gentegre.menu') === 'kapali' } catch { return false }
  });
  const menuCevir = () => setMenuKapali(k => {
    try { localStorage.setItem('gentegre.menu', k ? 'acik' : 'kapali') } catch { /* gizli sekme */ }
    return !k;
  });
  const grupAcikMi = (ad: string, alt: typeof moduller) =>
    ad in acikGruplar ? acikGruplar[ad] : alt.some(m => konum.pathname.startsWith(m.yol));

  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  const basHarfler = (kullanici?.ad ?? '?')
    .split(' ').filter(Boolean).slice(0, 2).map(p => p[0]?.toLocaleUpperCase('tr')).join('');
  // PROFIL FOTOGRAFI: personel kartinin varsayilan resmi (profilResmi.ts) -
  //   yoksa bas harfler. Ayarlar penceresinden yuklenince burada da tazelenir.
  const profilResmi = useProfilResmi(kullanici?.id);

  /** Ust seritteki arama kutusu komut paletini acar (paletin kendi kisayolu Ctrl+K). */
  const paletiAc = () =>
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));

  /** Bayraktan dil degistir - Kullanici Ayarlari'ndaki kutuyla ayni ucu cagirir. */
  async function dilSec(dil: number) {
    if (dil === (kullanici?.dil ?? 0)) return;
    try { await dilDegistir(dil) } catch { /* oturum katmani hatayi gosterir */ }
  }

  useEffect(() => {
    if (!dilMenusu) return;
    const kapat = () => setDilMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [dilMenusu]);


  return (
    <div className={`kabuk${menuKapali ? ' menu-kapali' : ''}`}>
      <header className="ust">
        {/* Menu ac/kapa: markanin SOLUNDA - kapaninca ana alan tam genislige acilir. */}
        <button className="ib menu-tus" onClick={menuCevir}
                title={menuKapali ? 'Menüyü aç' : 'Menüyü kapat'}
                aria-expanded={!menuKapali}>
          ☰
        </button>
        <div className="marka marka-bag" role="link" tabIndex={0}
             title={c('Ana sayfa')}
             onClick={() => git('/panel')}
             onKeyDown={e => { if (e.key === 'Enter') git('/panel') }}>
          {/* BASE_URL: uygulama alt yolda yayinda olabilir (/ai). Mutlak "/..." yazmak
              yayinda 404 veriyordu - sunucu kokunde degil /ai altinda duruyor. */}
          <span className="lg">
            <img src={`${import.meta.env.BASE_URL}gentegre-sembol.svg`} alt="Gentegre" />
          </span>
          {/* Marka urun moduna gore (215): ikon ayni, ad degisir. */}
          {urunAdi(kullanici?.urunModu)}
        </div>

        <button className="ust-ara" onClick={paletiAc} title={c('Komut paleti')}>
          <span>🔍</span>
          <span>{c('Ara ya da komut yaz…')}</span>
          <kbd>Ctrl K</kbd>
        </button>

        <div className="ustsag">
          {kullanici?.subeYazma === false && <span className="rozet uyari">{c('salt okuma')}</span>}

          {(kullanici?.subeler.length ?? 0) > 1 && (
            <select
              value={kullanici?.subeId ?? ''}
              onChange={e => void subeDegistir(Number(e.target.value))}
              title={c('Çalışılan şube')}
            >
              {kullanici?.subeler.map(s => (
                <option key={s.id} value={s.id}>{s.ad}{s.yazma ? '' : ' (salt okuma)'}</option>
              ))}
            </select>
          )}

          {/* GECE / GUNDUZ: uc durumlu - Sistem, Gündüz, Gece. Secim tarayicida
              saklanir (ayni hesap iki cihazda farkli olabilir). */}
          <button className="ib" title={`${c('Tema')} — ${c(TEMA_ADI[tema])}`}
                  onClick={() => { const y = temaSonraki(tema); setTema(y); temaUygula(y) }}>
            {TEMA_IKON[tema]}
          </button>

          {/* MESAJLAR ve AI (menu yeniden duzeni, plan kural 6): bunlar ARAC,
              is akisi degil - ana menude iki ogelik bir grup aciyorlardi.
              Ust cubuga alindi; yetkisi/modulu olmayanda hic cizilmez. */}
          {yetki('mesaj') && (
            <NavLink to="/mesajlar" className="ib" title={c('Mesajlar')}>💬</NavLink>
          )}
          {yetki('ai') && (
            <NavLink to="/yapay-zeka" className="ib" title={c('Yapay Zeka')}>✨</NavLink>
          )}

          {/* ZIL (662): onay bekleyen isler - simdilik iskonto onaylari.
              Dugme vardi ama hicbir sey yapmiyordu. */}
          <ZilPaneli c={c} />

          {/* Dil secimi: zilin saginda bayrak. Kullanici Ayarlari icindeki dil
              kutusuyla AYNI degeri yazar (taraf_kullanici.dil) - burasi kisayol. */}
          <span className="dil-sec" onMouseDown={e => e.stopPropagation()}>
            <button type="button" className="ib" title={`${c('Dil')} — ${DILLER[kullanici?.dil ?? 0]?.ad ?? ''}`}
                    onClick={() => setDilMenusu(a => !a)}>
              <Bayrak dil={kullanici?.dil ?? 0} boy={18} />
            </button>
            {dilMenusu && (
              <span className="dil-menu">
                {DILLER.map(d => (
                  <button key={d.deger} type="button"
                          className={`dil-oge${(kullanici?.dil ?? 0) === d.deger ? ' on' : ''}`}
                          onClick={() => { setDilMenusu(false); void dilSec(d.deger) }}>
                    <span className="bayrak"><Bayrak dil={d.deger} /></span> {d.ad}
                  </button>
                ))}
              </span>
            )}
          </span>
          <button className="ib" title={c('Yardım')}>?</button>
          {/* ÇIKIŞ AYIRT EDİLİR (kullanıcı): zil/yardım/dil ikonlarıyla aynı
              görünümdeydi ve başlığı Türkçesizdi ("Cikis"). Yanlışlıkla
              basıldığında oturum kapanan tek düğme bu - komşularından ayrı
              dursun: solunda ince ayraç, üzerine gelince kırmızı vurgu. */}
          <span className="ust-ayrac" aria-hidden="true" />
          {/* ÇIKIŞ İKONU: ⏻ (U+23FB) sistem fontlarında yok, tarayıcı boş kutu
              çiziyordu; yazılı düğme de şeritte fazla yer kapladı (kullanıcı:
              "bu sefer de büyük oldu, ikon haline getir"). Çizim artık inline
              SVG - fonta bağlı değil, komşu ikonlarla aynı 30px kutuda.
              Kırmızı kalır: üst şeritteki tek yıkıcı düğme bu. */}
          <button type="button" className="ib cikis" title={c('Oturumu kapat')}
                  onClick={() => void cikisYap()}>
            <svg viewBox="0 0 24 24" width="16" height="16" aria-hidden="true"
                 fill="none" stroke="currentColor" strokeWidth="2"
                 strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
              <polyline points="16 17 21 12 16 7" />
              <line x1="21" y1="12" x2="9" y2="12" />
            </svg>
          </button>
          <button
            type="button"
            className="avt"
            title={`Kullanıcı Ayarları — ${kullanici?.ad ?? ''}`}
            onClick={() => ayar.setAcik(true)}
          >
            {profilResmi ? <img src={profilResmi} alt="" /> : basHarfler}
          </button>
        </div>
      </header>

      <div className="govde">
        <aside className="yan">
          <div className="yanic">
            {/* Panel menude YOKTU: kullanici bir listeye girince ana sayfaya
                donmenin yolu kalmiyordu. En ustte, gruplarin disinda. */}
            {/* Ana Sayfa da YETKIYE bagli (241, kullanici: "anasayfayi da
                yetkilerde en basa al"). */}
            {yetki('panel') && (
              <NavLink to="/panel"
                       className={() => `mi ${konum.pathname === '/panel' ? 'on' : ''}`}>
                <span className="ic">🏠</span>
                <span>{cm('Ana Sayfa')}</span>
              </NavLink>
            )}

            {/* FAVORI grubu Ana Sayfa'nin ALTINDA (kullanici): yildizlanan ogeler bu
                menunun altinda; diger gruplar gibi acilir-kapanir, varsayilan
                ACIK. Bos ise hic cizilmez. */}
            {favoriler.length > 0 && (
              <div>
                <button type="button" className="mi"
                        style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                        onClick={() => setAcikGruplar(g => ({ ...g, '⭐Favori': !(g['⭐Favori'] ?? true) }))}>
                  <span className="ic">⭐</span>
                  <span>{cm('Favori')}</span>
                  <span className="rz">{(acikGruplar['⭐Favori'] ?? true) ? '▾' : '▸'}</span>
                </button>
                {/* Siralama EKLEME sirasi degil ANA MENU sirasi (kullanici):
                    Musteri Listesi menude tekliften ustteyse favoride de ustte. */}
                {(acikGruplar['⭐Favori'] ?? true) && satirlar
                  .flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt))
                  .filter(m => favoriler.includes(m.yol))
                  .map(m => {
                  const yol = m.yol;
                  return (
                    <NavLink key={`fav-${yol}`} to={yol} style={{ paddingLeft: 34 }}
                             className={() => `mi ${konum.pathname.startsWith(yol) ? 'on' : ''}`}>
                      <span className="ic">{m.ic}</span>
                      <span>{m.ad}</span>
                      {yildiz(yol)}
                    </NavLink>
                  );
                })}
              </div>
            )}

            {/* EN SON: favorilerin HEMEN ALTINDA (kullanici). Favoriler bilerek
                isaretlenir, bu liste kendiliginden birikir - ikisi ust uste
                durunca "hep gittiklerim" ile "bugun gittiklerim" ayni yerde
                olur. Favorideki oge burada TEKRARLANMAZ. */}
            {sonMenuGorunen(sonMenuler, favoriler).length > 0 && (
              <div>
                <button type="button" className="mi"
                        style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                        onClick={() => setAcikGruplar(g => ({ ...g, '🕓En Son': !(g['🕓En Son'] ?? true) }))}>
                  <span className="ic">🕓</span>
                  <span>{cm('En Son')}</span>
                  <span className="rz">{(acikGruplar['🕓En Son'] ?? true) ? '▾' : '▸'}</span>
                </button>
                {/* Siralama SON KULLANIM sirasidir (favorideki gibi menu sirasi
                    DEGIL): en son acilan en ustte - listenin isi zaten "az once
                    neredeydim" sorusuna cevap vermek. */}
                {(acikGruplar['🕓En Son'] ?? true) && sonMenuGorunen(sonMenuler, favoriler)
                  .map(yol => satirlar
                    .flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt))
                    .find(m => m.yol === yol))
                  // Yetkisi kalkan / kaldirilan menu listede kalabilir - cizilmez.
                  .filter((m): m is NonNullable<typeof m> => !!m)
                  .map(m => (
                    <NavLink key={`son-${m.yol}`} to={m.yol} style={{ paddingLeft: 34 }}
                             className={() => `mi ${konum.pathname.startsWith(m.yol) ? 'on' : ''}`}>
                      <span className="ic">{m.ic}</span>
                      <span>{m.ad}</span>
                      {yildiz(m.yol)}
                    </NavLink>
                  ))}
              </div>
            )}

            {/* "Calisma alani" bolum basligi kaldirildi (kullanici). */}
            {satirlar.map(s => s.tur === 'duz' ? (
              <NavLink
                key={s.m.yol}
                to={s.m.yol}
                className={() => `mi ${konum.pathname.startsWith(s.m.yol) ? 'on' : ''}`}
              >
                <span className="ic">{s.m.ic}</span>
                <span>{s.m.ad}</span>
                {yildiz(s.m.yol)}
              </NavLink>
            ) : (
              <div key={s.ad}>
                <button
                  type="button"
                  className="mi"
                  style={{ width: '100%', border: 0, background: 'transparent', cursor: 'pointer' }}
                  onClick={() => setAcikGruplar(g => ({ ...g, [s.ad]: !grupAcikMi(s.ad, s.alt) }))}
                >
                  <span className="ic">{GRUP_IKON[s.ad] ?? GRUP_IKON_CEV[s.ad] ?? '📁'}</span>
                  <span>{s.ad}</span>
                  <span className="rz">{grupAcikMi(s.ad, s.alt) ? '▾' : '▸'}</span>
                </button>
                {grupAcikMi(s.ad, s.alt) && grupla(s.alt, m => m.altGrup).map(a => a.tur === 'duz' ? (
                  <NavLink
                    key={a.m.yol}
                    to={a.m.yol}
                    className={() => `mi ${konum.pathname.startsWith(a.m.yol) ? 'on' : ''}`}
                    style={{ paddingLeft: 34 }}
                  >
                    <span className="ic">{a.m.ic}</span>
                    <span>{a.m.ad}</span>
                    {yildiz(a.m.yol)}
                  </NavLink>
                ) : (
                  // Ikinci seviye (ör. Yönetim › Ayarlar): kendi ac/kapa durumu,
                  //   bir tik daha icerden.
                  <div key={`${s.ad}/${a.ad}`}>
                    <button
                      type="button"
                      className="mi"
                      style={{ width: '100%', border: 0, background: 'transparent',
                               cursor: 'pointer', paddingLeft: 34 }}
                      onClick={() => setAcikGruplar(g => ({
                        ...g, [`${s.ad}/${a.ad}`]: !grupAcikMi(`${s.ad}/${a.ad}`, a.alt) }))}
                    >
                      <span className="ic">{ALTGRUP_IKON[a.ad] ?? '⚙️'}</span>
                      <span>{a.ad}</span>
                      <span className="rz">{grupAcikMi(`${s.ad}/${a.ad}`, a.alt) ? '▾' : '▸'}</span>
                    </button>
                    {grupAcikMi(`${s.ad}/${a.ad}`, a.alt) && a.alt.map(m => (
                      <NavLink
                        key={m.yol}
                        to={m.yol}
                        className={() => `mi ${konum.pathname.startsWith(m.yol) ? 'on' : ''}`}
                        style={{ paddingLeft: 52 }}
                      >
                        <span className="ic">{m.ic}</span>
                        <span>{m.ad}</span>
                        {yildiz(m.yol)}
                      </NavLink>
                    ))}
                  </div>
                ))}
              </div>
            ))}

            <div className="bolum">{cm('Oturum')}</div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">🏢</span>
              <span>{aktifSube?.ad ?? '-'}</span>
            </div>
            <div className="mi" style={{ cursor: 'default' }}>
              <span className="ic">👤</span>
              <span>{kullanici?.kod}</span>
              <span className="rz">{kullanici?.rolAdi}</span>
            </div>
          </div>

        </aside>

        <main className="ana" key={ceviriSurumu}><Outlet /></main>
      </div>

      {/* KULLANICI AYARLARI (669): dort sekmeli pencere ayri bilesende
          (bilesenler/KullaniciAyarlari.tsx). Kabuk'ta gomulu dururken
          Hesabim/Gorunum/Guvenlik/Bildirim sekmeleri kabugu 200 satir daha
          buyutecekti; pencerenin kendi verisi de var (hesap, oturumlar). */}
      <KullaniciAyarlari ayar={ayar} tema={tema} setTema={setTema} c={c} />

      {/* AI REHBER (447): sag altta, her ekranda. Yol gosterir; kayit
          degistirmez. Yetkisi olmayana hic cizilmez. */}
      {yetki('ai.rehber') && <AiRehberPaneli urunModu={kullanici?.urunModu} />}
    </div>
  );
}
