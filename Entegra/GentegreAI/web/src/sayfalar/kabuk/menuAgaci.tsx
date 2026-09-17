/**
 * MENU AGACI (saf): liste tanimlarindan yetkili/acik ogeleri suzer, grup ve
 * alt-gruba toplar, gruplari urune gore siralar. React'siz - Kabuk yalniz
 * cizer. Kabuk.tsx'ten cikarildi (kullanici: "refaktor"): 800 satirlik kabuk
 * icinde menu kurulumu, bolge/alan mantigi ve ust serit ayni dosyadaydi.
 */
import { cm } from '../../dil/ceviri';
import { modUyar } from '../../api/sozlesme';
import { modulAcikMi } from '../listeTanimlari';
import { GRUP_SIRA_HBYS } from './menuBolgeleri';
import type { LISTELER } from '../Liste';

export interface MenuOgesi {
  yol: string;
  ad: string;
  ic: string;
  rz: string;
  grup?: string;
  /** Grubun CEVRILMEMIS adi: sira tablosu dilden bagimsiz eslessin. */
  grupHam?: string;
  /** Ogenin CEVRILMEMIS adi: grupsuz duz oge (Demirbas) bolgesini adiyla bulur. */
  adHam?: string;
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
// GRUP_SIRA_HBYS artik kabuk/menuBolgeleri.ts'te: HBYS gruplari 7 BOLGE altinda
//   (V2, mockup Ekranlar/Dashboard/hastane_menu_v2.html); sira bolgelerin
//   duzlestirilmis halidir, iki yerde bakim edilmez.

/**
 * ERP'de sira TICARI AKISTIR: cari -> satis -> alis -> stok -> uretim -> para.
 * Finans burada AKISIN SONUNDA durur; HBYS'de hasta akisinin hemen arkasinda.
 * Tek liste ikisini birden veremiyordu - ayni grubun yeri urune gore farkli.
 */
export const GRUP_SIRA_ERP = [
  'Cari & CRM', 'Satış', 'Alış', 'Stok & Hizmet', 'Üretim',
  'Finans', 'Muhasebe', 'İK & Prim', 'Doküman', 'Demirbaş',
];

export type MenuSatiri =
  | { tur: 'duz'; m: MenuOgesi }
  | { tur: 'grup'; ad: string; alt: MenuOgesi[] };

/** Sira korunarak grupla: her benzersiz grup adi ILK gorundugu yerde acilir. */
/**
 * Menu ikonu: emoji metni ya da ozel isaret. `@hilal` KIRMIZI HILAL (kullanici:
 * "kayit kabul logosu kirmizi hilal ay olsun") - emoji setinde kirmizi hilal
 * yok, ☪ renksiz/mor ciziliyor; SVG ile boyanir.
 */
export function MenuIkon({ ic }: { ic: string }) {
  // '@ameliyathane' (kullanici: "ameliyathane resmi olsun"): emoji seti
  //   ameliyat masasi tasimiyor - lamba + masa cizimi.
  if (ic === '@ameliyathane')
    return (
      <span className="ic ic-hilal" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="16" height="16">
          <path d="M12 2v3" stroke="#5b6670" strokeWidth="1.6" strokeLinecap="round" />
          <path d="M6.5 8.5a5.5 3 0 0 1 11 0z" fill="#f2c94c" stroke="#b8860b" strokeWidth=".8" />
          <rect x="4" y="13" width="16" height="3.2" rx="1" fill="#2f6db3" />
          <path d="M9 12.2c1.2-1.6 4.8-1.6 6 0" stroke="#2e7d46" strokeWidth="1.6" strokeLinecap="round" fill="none" />
          <path d="M6.5 16.2v4M17.5 16.2v4M5 20.2h3M16 20.2h3" stroke="#5b6670" strokeWidth="1.4" strokeLinecap="round" />
        </svg>
      </span>
    );
  if (ic === '@hilal')
    return (
      <span className="ic ic-hilal" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="15" height="15">
          <path fill="#d32f2f" d="M12 3 A9 9 0 1 0 12 21 A11 11 0 0 1 12 3 Z" />
        </svg>
      </span>
    );
  return <span className="ic">{ic}</span>;
}

export function grupla(liste: MenuOgesi[], sec: (m: MenuOgesi) => string | undefined): MenuSatiri[] {
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
export const GRUP_IKON: Record<string, string> = {
  'Randevu': '📅',
  'Kayıt Kabul': '🚑',
  // Kullanici: Acil grubu Triyaj girdisiyle ayni ikon.
  'Acil': '🚨',
  'Ameliyathane': '@ameliyathane',
  'Radyoloji': '☢️',
  'Göz': '👁️',
  'Diş': '🦷',
  'FTR': '🏃',
  'İşyeri Hekimliği': '👷',
  'Medula': '🏛️',
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
export const ALTGRUP_IKON: Record<string, string> = {
  'Prim': '%',
  // Her grubun SON alt grubu "Ayarlar" (plan kural 2): gunluk is listeleri
  //   ustte, tanimlar ve ayarlar altta - hangi grupta olursan ol ayni desen.
  'Ayarlar': '⚙️',
  // FORM MOTORU (740): Yönetim › Formlar alt grubu.
  'Formlar': '🗂',
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
export const GRUP_IKON_CEV: Record<string, string> = {
  'Appointments': '📅', 'Termine': '📅',
  'Admissions': '🚑', 'Aufnahme': '🚑',
  'Emergency': '🚨', 'Notaufnahme': '🚨',
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


/**
 * Menu satirlari: yetki + urun modu + kurum modulu suzgecinden gecen ogeler,
 * gruplanmis ve siralanmis. Her cizimde yeniden kurulur (dil degisince adlar
 * degisir; ucuz).
 */
export function menuSatirlariKur(
  listeler: typeof LISTELER,
  yetki: (kod: string) => boolean,
  urunModu: number | undefined,
  moduller: string[] | undefined,
): MenuSatiri[] {
  // Menu, liste tanimlarindan uretilir; yetkisiz modul hic cizilmez. menuGrup verilen
  //   ogeler ("Cari" -> Musteri/Tedarikci/Kisi Listesi) acilir-kapanir bir ana menu
  //   altinda TOPLANIR; menuGrup'suz ogeler eskisi gibi duz sirada kalir.
  const yetkiliListeler = listeler.filter(l => yetki(l.yetkiKodu) && !l.menuGizli
    // Urun modu suzmesi (215): Kayit Kabul yalniz GenoTIP AI'da.
    && (!l.urunModu || modUyar(l.urunModu, urunModu))
    // MODUL suzmesi (359): kurum profilinde kapali modulun menusu cizilmez.
    && modulAcikMi(l, moduller));
  const ogeler: MenuOgesi[] =
    yetkiliListeler.map(l => ({
      yol: l.menuYol ?? `/${l.rota ?? l.kaynak}`, ad: cm(l.menuAd), ic: l.ic,
      rz: l.ozelSayfa ? 'ayar' : 'liste',
      grup: l.menuGrup ? cm(l.menuGrup) : undefined,
      grupHam: l.menuGrup,
      adHam: l.menuAd,
      altGrup: l.menuAltGrup ? cm(l.menuAltGrup) : undefined,
      sira: l.menuSira,
    }));

  // Iki seviye: grup (Cari, Kasa, Yönetim…) ve grubun icinde alt grup
  //   (Yönetim › Ayarlar). Ayni yardimci iki seviyede de kullanilir.
  const satirlar = grupla(ogeler, m => m.grup);
  // YONETIM HER ZAMAN EN SONDA (kullanici): grup sirasi tanim dizisindeki ILK
  //   ogeden gelir, Yonetim'in ilk ogesi (Kampanyalar) dizinin ortasinda oldugu
  //   icin menunun ortasina dusuyordu. Ayarlar/roller gibi seyrek kullanilan
  //   ekranlar en altta olsun diye grup burada sona alinir - dil degisince ad
  //   da degistiginden cevirili adlar da kontrol edilir.
  // GRUP SIRASI: once GRUP_SIRA'daki duzen, sonra listede olmayanlar kendi
  //   sirasinda. Duz ogeler (grubu olmayan, or. Ana Sayfa) YERINDE kalir -
  //   yalniz grup satirlari kendi aralarinda siralanir.
  // Urun modu 2 = HBYS (GenoTIP AI); otekiler ticari sirayi kullanir.
  const grupSirasi = urunModu === 2 ? GRUP_SIRA_HBYS : GRUP_SIRA_ERP;
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
  return satirlar;
}
