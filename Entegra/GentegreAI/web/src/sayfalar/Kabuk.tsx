import { useEffect, useState } from 'react';
import { sonMenuEkle, sonMenuGorunen } from './menuSonKullanilan';
import { modulAcikMi } from './listeTanimlari';
import { TEMA_ADI, TEMA_IKON, temaOku, temaSonraki, temaUygula, type Tema }
  from '../bilesenler/tema';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { Bayrak } from '../bilesenler/Bayrak';
import { cm, ceviriYukle, ceviriDinle } from '../dil/ceviri';
import { api } from '../api/istemci';
import { useOturum } from '../kimlik/OturumBaglami';
import { urunAdi } from '../api/sozlesme';
import { LISTELER } from './Liste';

interface MenuOgesi {
  yol: string;
  ad: string;
  ic: string;
  rz: string;
  grup?: string;
  altGrup?: string;
  /** Grup ICINDEKI sira (kucuk once). Gruplarin kendi sirasi degismez. */
  sira?: number;
}

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
  // Klinik moduller (360): kurum profilinde kapaliysa menude hic gorunmezler.
  'Muayene': '🩺',
  'Laboratuvar': '🧪',
  'Cari':    '🤝',
  'Satış':   '🛍️',
  'Alış':    '🛒',
  'Kasa':    '💵',
  'Banka':   '🏦',
  'CRM':     '📈',
  'Stok & Hizmet': '📦',
  // Muhasebe ana menusu (kullanici): Stok'tan sonra gelir - hesap plani, fisler,
  //   fis satirlari, masraf merkezleri ve islem turleri Yonetim'den buraya alindi.
  'Muhasebe': '📚',
  'İK':      '👥',
  'Yönetim': '🛠️',
};

/** ALT GRUP ikonu: ikinci seviye eskiden HEP ⚙️ ciziyordu, ayar olmayan alt
    gruplarda yanlis okunuyordu (kullanici: Prim'in logosu % olsun). Tabloda
    olmayan alt grup eskisi gibi ⚙️ kalir. */
const ALTGRUP_IKON: Record<string, string> = {
  'Prim': '%',
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
  'Accounting': '📚', 'Buchhaltung': '📚',
  'HR': '👥', 'Personal': '👥',
  'Administration': '🛠️', 'Verwaltung': '🛠️',
};

/** Arayuz dilleri - db/081: taraf_kullanici.dil (0 TR / 1 EN / 2 DE).
    Bayrak SVG cizilir (<Bayrak dil=…/>): Windows'ta bayrak EMOJISI yok, emoji
    kullanildiginda kullanici "TR"/"GB"/"DE" harflerini goruyordu. */
const DILLER = [
  { deger: 0, ad: 'Türkçe' },
  { deger: 1, ad: 'English' },
  { deger: 2, ad: 'Deutsch' },
] as const;

export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, dilDegistir, yetki } = useOturum();
  const konum = useLocation();
  const git = useNavigate();

  // Menu, liste tanimlarindan uretilir; yetkisiz modul hic cizilmez. menuGrup verilen
  //   ogeler ("Cari" -> Musteri/Tedarikci/Kisi Listesi) acilir-kapanir bir ana menu
  //   altinda TOPLANIR; menuGrup'suz ogeler eskisi gibi duz sirada kalir.
  const yetkiliListeler = LISTELER.filter(l => yetki(l.yetkiKodu) && !l.menuGizli
    // Urun modu suzmesi (215): Kayit Kabul yalniz GenoTIP AI'da.
    && (!l.urunModu || l.urunModu === (kullanici?.urunModu ?? 1))
    // MODUL suzmesi (359): kurum profilinde kapali modulun menusu cizilmez.
    && modulAcikMi(l, kullanici?.moduller));
  const moduller: MenuOgesi[] =
    yetkiliListeler.map(l => ({
      yol: `/${l.rota ?? l.kaynak}`, ad: cm(l.menuAd), ic: l.ic,
      rz: l.ozelSayfa ? 'ayar' : 'liste',
      grup: l.menuGrup ? cm(l.menuGrup) : undefined,
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
   * dolu gorunur, tekrar tiklaninca cikar. Kullanici BASINA tarayicida
   * saklanir (localStorage) - sunucu tarafina tasinmasi ileriki is.
   */
  const favoriAnahtar = `favoriler.${kullanici?.id ?? 0}`;
  const [favoriler, setFavoriler] = useState<string[]>([]);
  useEffect(() => {
    try { setFavoriler(JSON.parse(localStorage.getItem(favoriAnahtar) ?? '[]') as string[]) }
    catch { setFavoriler([]) }
  }, [favoriAnahtar]);
  const favoriToggle = (yol: string) => setFavoriler(t => {
    const y = t.includes(yol) ? t.filter(x => x !== yol) : [...t, yol];
    try { localStorage.setItem(favoriAnahtar, JSON.stringify(y)) } catch { /* dolu/kapali depo */ }
    return y;
  });
  /**
   * EN SON KULLANILANLAR (kullanici: "Favori'den sonra 'En Son' ekle, son 10
   * secilmis menu listelensin").
   *
   * Favoriler kullanicinin BILEREK isaretledikleri; bu liste ise kendiliginden
   * birikir - gunun isi hep ayni birkac ekranda geciyor ama hangileri oldugu
   * onceden bilinmiyor. Yol EN BASA yazilir, ayni yol ikinci kez secilince
   * yukari tasinir (kopya birikmez), liste ONDA kirpilir.
   *
   * Favoride ZATEN olan oge burada TEKRARLANMAZ: iki liste ust uste durdugu
   * icin ayni satiri iki kez gostermek menuyu uzatmaktan baska ise yaramaz.
   */
  const sonAnahtar = `sonMenuler.${kullanici?.id ?? 0}`;
  const [sonMenuler, setSonMenuler] = useState<string[]>([]);
  useEffect(() => {
    try { setSonMenuler(JSON.parse(localStorage.getItem(sonAnahtar) ?? '[]') as string[]) }
    catch { setSonMenuler([]) }
  }, [sonAnahtar]);
  const sonKaydet = (yol: string) => setSonMenuler(o => {
    const y = sonMenuEkle(o, yol) as string[];
    if (y === o) return o;                       // degismediyse yazma
    try { localStorage.setItem(sonAnahtar, JSON.stringify(y)) } catch { /* dolu/kapali depo */ }
    return y;
  });

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
            title={favoriler.includes(yol) ? 'Favorilerden çıkar' : 'Favorilere ekle'}
            style={{ border: 0, background: 'transparent', cursor: 'pointer',
                     padding: 0, fontSize: 13, lineHeight: 1 }}
            onClick={e => { e.preventDefault(); e.stopPropagation(); favoriToggle(yol) }}>
      {favoriler.includes(yol) ? '★' : '☆'}
    </button>
  );

  // Acik/kapali durumu kullanici ELLE degistirmedikce, aktif alt-ogeyi iceren grup
  //   otomatik acik gelir (dogrudan /tedarikci gibi bir URL'e gelindiginde de gorunsun).
  const [acikGruplar, setAcikGruplar] = useState<Record<string, boolean>>({});
  const [kullaniciAyariAcik, setKullaniciAyariAcik] = useState(false);
  const [eskiSifre, setEskiSifre] = useState('');
  const [sifre1, setSifre1] = useState('');
  const [sifre2, setSifre2] = useState('');
  const [seciliDil, setSeciliDil] = useState(0);
  const [ayarMesaji, setAyarMesaji] = useState('');
  const [ayarKaydediliyor, setAyarKaydediliyor] = useState(false);
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

  /** Ust seritteki arama kutusu komut paletini acar (paletin kendi kisayolu Ctrl+K). */
  const paletiAc = () =>
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'k', ctrlKey: true, bubbles: true }));

  const ayarKapat = () => {
    setKullaniciAyariAcik(false);
    setAyarMesaji('');
    setEskiSifre('');
    setSifre1('');
    setSifre2('');
  };

  const ayarTamam = async () => {
    setAyarMesaji('');
    if (sifre1 || sifre2 || eskiSifre) {
      if (!eskiSifre) { setAyarMesaji('Mevcut şifre gerekli.'); return }
      if (sifre1.length < 8) { setAyarMesaji('Şifre en az 8 karakter olmalı.'); return }
      if (sifre1 !== sifre2) { setAyarMesaji('Şifreler aynı değil.'); return }
    }

    setAyarKaydediliyor(true);
    try {
      if (seciliDil !== (kullanici?.dil ?? 0)) await dilDegistir(seciliDil);
      if (sifre1 || sifre2 || eskiSifre) {
        await api.parolaDegistir(eskiSifre, sifre1);
        ayarKapat();
        await cikisYap();
        return;
      }
      ayarKapat();
    } catch (e) {
      setAyarMesaji(e instanceof Error ? e.message : 'Kullanıcı ayarları kaydedilemedi.');
    } finally {
      setAyarKaydediliyor(false);
    }
  };

  /** Bayraktan dil degistir - Kullanici Ayarlari'ndaki kutuyla ayni ucu cagirir. */
  async function dilSec(dil: number) {
    if (dil === (kullanici?.dil ?? 0)) return;
    try { await dilDegistir(dil) } catch { /* oturum katmani hatayi gosterir */ }
  }

  useEffect(() => {
    if (kullaniciAyariAcik) setSeciliDil(kullanici?.dil ?? 0);
  }, [kullaniciAyariAcik, kullanici?.dil]);

  useEffect(() => {
    if (!dilMenusu) return;
    const kapat = () => setDilMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [dilMenusu]);

  useEffect(() => {
    if (!kullaniciAyariAcik) return;
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') ayarKapat() };
    window.addEventListener('keydown', esc);
    return () => window.removeEventListener('keydown', esc);
  }, [kullaniciAyariAcik]);

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
             title="Ana sayfa"
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

        <button className="ara" onClick={paletiAc} title="Komut paleti">
          <span>🔍</span>
          <span>Ara ya da komut yaz…</span>
          <kbd>Ctrl K</kbd>
        </button>

        <div className="ustsag">
          {kullanici?.subeYazma === false && <span className="rozet uyari">salt okuma</span>}

          {(kullanici?.subeler.length ?? 0) > 1 && (
            <select
              value={kullanici?.subeId ?? ''}
              onChange={e => void subeDegistir(Number(e.target.value))}
              title="Calisilan sube"
            >
              {kullanici?.subeler.map(s => (
                <option key={s.id} value={s.id}>{s.ad}{s.yazma ? '' : ' (salt okuma)'}</option>
              ))}
            </select>
          )}

          {/* GECE / GUNDUZ: uc durumlu - Sistem, Gündüz, Gece. Secim tarayicida
              saklanir (ayni hesap iki cihazda farkli olabilir). */}
          <button className="ib" title={`Tema — ${TEMA_ADI[tema]} (değiştirmek için tıklayın)`}
                  onClick={() => { const y = temaSonraki(tema); setTema(y); temaUygula(y) }}>
            {TEMA_IKON[tema]}
          </button>

          <button className="ib" title="Bildirimler">🔔</button>

          {/* Dil secimi: zilin saginda bayrak. Kullanici Ayarlari icindeki dil
              kutusuyla AYNI degeri yazar (taraf_kullanici.dil) - burasi kisayol. */}
          <span className="dil-sec" onMouseDown={e => e.stopPropagation()}>
            <button type="button" className="ib" title={`Dil — ${DILLER[kullanici?.dil ?? 0]?.ad ?? ''}`}
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
          <button className="ib" title="Yardim">?</button>
          <button className="ib" title="Cikis" onClick={() => void cikisYap()}>⏻</button>
          <button
            type="button"
            className="avt"
            title={`Kullanıcı Ayarları — ${kullanici?.ad ?? ''}`}
            onClick={() => setKullaniciAyariAcik(true)}
          >
            {basHarfler}
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

      {kullaniciAyariAcik && (
        <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) ayarKapat() }}>
          <div className="kawin kullanici-ayarlari" role="dialog" aria-label="Kullanıcı Ayarları">
            <div className="kabas">
              <span>👤 Kullanıcı Ayarları</span>
              <span className="kapt">Ortak\UKullaniciDuzenle · KULLANICI</span>
            </div>

            <div className="kagov">
              <div className="kagrup">
                <h6>Kimlik <span>kendi hesabınızda salt okunur</span></h6>
                <div className="kasat">
                  <label>Kullanıcı Adı</label>
                  <div className="kaara">
                    <input value={kullanici?.ad ?? ''} disabled />
                    <button className="kabtn" disabled title="Rehberden seç">⋯</button>
                    <span className="karoz">ID {kullanici?.id ?? '-'}</span>
                  </div>
                  <label>Kullanıcı Kodu</label><input value={kullanici?.kod ?? ''} disabled />
                  <label>Rol</label><input value={kullanici?.rolAdi ?? ''} disabled />
                  <label>Kullanıcı Durumu</label><input value="Aktif" disabled />
                  <label>Çalışılan Şube</label><input value={aktifSube?.ad ?? '-'} disabled />
                  <label>Dil</label>
                  {/* Bayrakli secim (kullanici): "Türkçe/English/Deutsch" yerine
                      ust cubuktaki bayrakla AYNI gorsel dil. */}
                  <select value={seciliDil} onChange={e => setSeciliDil(Number(e.target.value))}
                          disabled={ayarKaydediliyor}>
                    {DILLER.map(d => (
                      <option key={d.deger} value={d.deger}>{d.ad}</option>
                    ))}
                  </select>
                  <label>Tema</label>
                  <select value={tema}
                          onChange={e => { const y = e.target.value as Tema;
                                           setTema(y); temaUygula(y) }}>
                    {(['sistem', 'gunduz', 'gece'] as Tema[]).map(t => (
                      <option key={t} value={t}>{TEMA_IKON[t]}  {TEMA_ADI[t]}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="kagrup">
                <h6>Şifre</h6>
                <div className="kasat">
                  <label>Mevcut Şifre</label>
                  <input
                    type="password"
                    value={eskiSifre}
                    onChange={e => setEskiSifre(e.target.value)}
                    disabled={ayarKaydediliyor}
                    autoComplete="current-password"
                  />
                  <label>Yeni Şifre</label>
                  <div className="kaara">
                    <input
                      type="password"
                      value={sifre1}
                      onChange={e => setSifre1(e.target.value)}
                      disabled={ayarKaydediliyor}
                      autoComplete="new-password"
                    />
                    {sifre1 && sifre1 === sifre2 && <span className="kaok">✓</span>}
                  </div>
                  <label>Yeni Şifre (Tekrar)</label>
                  <div className="kaara">
                    <input
                      type="password"
                      value={sifre2}
                      onChange={e => setSifre2(e.target.value)}
                      disabled={ayarKaydediliyor}
                      autoComplete="new-password"
                    />
                    {sifre2 && sifre1 === sifre2 && <span className="kaok">✓</span>}
                  </div>
                </div>
                {ayarMesaji && <div className="kauyari">{ayarMesaji}</div>}
                <div className="kanot">Şifre boş bırakılırsa değiştirilmez. Şifre değişirse oturum kapanır; yeni şifreyle tekrar girilir.</div>
              </div>
            </div>

            {/* STANDART ALT SERIT (kullanici): modallarin ortak deseni -
                solda Iptal (d kapat-dugmesi), sagda birincil Kaydet (d bir). */}
            <div className="kaalt">
              <button className="d kapat-dugmesi" onClick={ayarKapat}
                      disabled={ayarKaydediliyor}>İptal</button>
              <button className="d bir" onClick={() => void ayarTamam()}
                      disabled={ayarKaydediliyor}>
                {ayarKaydediliyor ? 'Kaydediliyor…' : 'Kaydet'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
