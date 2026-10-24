import { basHarfler as basHarfHesapla } from '../bilesenler/basHarfler';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { mesaj } from '../bilesenler/mesaj';
import { useMenuTercihleri, useKullaniciAyari } from './kabuk/useMenuTercihleri';
import { DILLER } from '../bilesenler/diller';
import { KullaniciAyarlari, type AyarSekmesi } from '../bilesenler/KullaniciAyarlari';
import { useProfilResmi } from '../bilesenler/profilResmi';
import { useSubeLogo } from '../bilesenler/subeLogo';
import { menuSatirlariKur } from './kabuk/menuAgaci';
import { menuDuzeniUygula, MENU_DUZEN_OLAYI, type MenuDuzenSatiri } from './kabuk/menuDuzeni';
import { YanMenu } from './kabuk/YanMenu';
import { KomutPaleti } from './kabuk/KomutPaleti';
import { TEMA_ADI, TEMA_IKON, temaOku, temaSonraki, temaUygula, type Tema }
  from '../bilesenler/tema';
import { NavLink, Outlet, useLocation, useNavigate, useNavigationType, useOutlet } from 'react-router-dom';
import { useEkranSekmeleri } from './kabuk/EkranSekmeleri';
import { PALET_AC_OLAYI, PALET_GIT_OLAYI } from './Baslangic';
import type { GostergePaneliOzet } from '../api/uclar/gosterge';
import { gorunumOku, GORUNUM_OLAYI } from '../bilesenler/gorunum';
import { menuYolu, yolEslesir } from '../bilesenler/taleplerim/personelTalebi';
import { TaleplerimBaglami, TaleplerimPaneli, KullaniciMenusu, BanaGelenlerPaneli } from '../bilesenler/taleplerim/TaleplerimPaneli';
import { useTaleplerimOzeti } from '../bilesenler/taleplerim/useTaleplerimOzeti';
import { YeniTalepKatmani } from '../bilesenler/taleplerim/YeniTalepModali';
import { TalepBildirimleri } from '../bilesenler/taleplerim/TalepBildirimleri';
import { HatirlatmaYoneticisi } from '../bilesenler/hatirlatma/HatirlatmaYoneticisi';
import { hatirlatmaPenceresiAc } from '../bilesenler/hatirlatma/hatirlatmaDeposu';
import { IskontoKararKatmani } from '../bilesenler/taleplerim/GelenIsler';
import { DuyuruKatmani } from '../bilesenler/duyuru/DuyuruOrtak';
import { Bayrak } from '../bilesenler/Bayrak';
import { c, ceviriYukle, ceviriDinle } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';
import { urunAdi } from '../api/sozlesme';
import { AiRehberPaneli, YARDIM_AC_OLAYI } from '../bilesenler/AiRehberPaneli';
import { LISTELER } from './Liste';
import { TarafArama } from '../bilesenler/TarafArama';

import { kartAdi, kartSekmeYolu, kartSekmesiVar, yeniSekmeBasligi, type ListeGirdisi } from './listeTanimlari.Ortak';
import { OZEL_KART_SEKME_YOLLARI } from './ozelKartSekmeleri';
import { KayitArama } from '../bilesenler/KayitArama';
import { StokAramaPenceresi } from '../bilesenler/StokAramaPenceresi';

/** Komut paletinde "Kayıtlı ... Kartı" - yol değil, arama penceresini açar: `#kayitli:<kart yolu>`. */
const KAYITLI_ONEK = '#kayitli:';
/** Palet işlemi: yeni kişisel hatırlatma penceresi (rota değil). */
const HATIRLATMA_YENI = '#hatirlatma:yeni';
/** Hasta ve başvuru: genel HASTA araması (başvuruda hastanın son başvurusu); boş palette hep görünür. */
// Muayene (kullanıcı 15.10.2026): hasta aranır, hastanın SON muayenesi açılır.
const SABIT_ARAMA: Record<string, 'hasta' | 'basvuru' | 'muayene'> = { '/hasta': 'hasta', '/basvuru': 'basvuru', '/muayene': 'muayene' };
/** Stok ve hizmet: belgedeki genel stok arama penceresi (kart açma kipi). */
const STOK_ARAMA: Record<string, 'stok' | 'hizmet'> = { '/stok': 'stok', '/hizmet': 'hizmet' };
/** KAYITLI PERSONEL KARTI (kullanıcı 17.10.2026): liste tablosu değil jenerik personel araması. */
const KISI_ARAMA: Record<string, string> = { '/personel': 'personel' };
/** Kartı sekmede açılan listeler, kart yolu başına bir tane. */
const kartListeleri = LISTELER.filter(l => kartSekmesiVar(l) && !l.menuYol)
  .filter((l, i, a) => a.findIndex(x => kartSekmeYolu(x) === kartSekmeYolu(l)) === i);
/** Listenin menü yolu ve kart sekmesinin yolu (kartYolu yoksa liste rotası - belge kartları). */
const listeYolu = (l: ListeGirdisi) => `/${l.rota ?? l.kaynak}`;

export function Kabuk() {
  const { kullanici, cikisYap, subeDegistir, dilDegistir, yetki } = useOturum();
  const konum = useLocation();
  const git = useNavigate();

  // MENU AGACI (kabuk/menuAgaci): yetki + urun modu + kurum modulu suzgeci,
  //   grup/alt-grup, urune gore grup sirasi - hepsi saf fonksiyonda.
  const kodSatirlari = menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller);
  /**
   * MENÜ DÜZENİ FARKI (979): kurumun bu şube için yaptığı değişiklikler
   * (sıra · görünen ad · ikon · gizleme) koddan kurulan ağacın ÜSTÜNE
   * uygulanır. Fark yoksa ağaç olduğu gibi çizilir - yeni eklenen bir ekran
   * hiçbir şubede kaybolmaz.
   */
  const [menuDuzen, setMenuDuzen] = useState<MenuDuzenSatiri[]>([]);
  useEffect(() => {
    if (!kullanici?.id) return;
    let iptal = false;
    // Düzen okuması YETKİ İSTEMEZ: kullanıcı kendi menüsünü çizebilmeli.
    //   Hata durumunda sessizce varsayılan ağaç kalır - menü hiç çizilmemesindense
    //   düzenlenmemiş çizilsin.
    const oku = () => api.menuDuzen()
      .then(y => { if (!iptal) setMenuDuzen(y.satirlar) }).catch(() => {});
    oku();
    // KAYDET & UYGULA ANINDA GEÇERLİ (kullanıcı 07.10.2026): menü düzeni
    //   ekranı kaydedince bu olayı yayar, sol menü yeniden okur. Yoksa kurum
    //   değişikliği görmek için sayfayı yenilemek zorundaydı.
    window.addEventListener(MENU_DUZEN_OLAYI, oku);
    return () => { iptal = true; window.removeEventListener(MENU_DUZEN_OLAYI, oku) };
  }, [kullanici?.id, kullanici?.subeId]);
  const satirlar = useMemo(() => menuDuzeniUygula(kodSatirlari, menuDuzen),
                           [kodSatirlari, menuDuzen]);


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
  const tercih = useMenuTercihleri(kullanici?.id,
      { aktif: kullanici?.subeId, liste: kullanici?.subeler ?? [], degistir: subeDegistir });
  /** Ekran sayacının son saydığı gezinme (adres anahtarı + ekran). */
  const sayilanAdres = useRef('');

  /**
   * KAYIT NOKTASI ROTA DEGISIMI (menu tiklamasi DEGIL): ayni ekrana favoriden,
   * dogrudan URL'den, geri tusundan ya da bir kart icindeki baglantidan da
   * gelinebiliyor. Menuye onClick baglamak bunlarin cogunu kacirirdi.
   * En UZUN eslesen yol alinir - "/kasa-islem" ile "/kasa" ayni anda eslesirse
   * dogru olan derindeki.
   */
  useEffect(() => {
    const hepsi = satirlar.flatMap(sat => (sat.tur === 'duz' ? [sat.m] : sat.alt));
    const yol = menuYolu(konum.pathname, konum.state);
    const eslesen = hepsi
      .filter(m => yolEslesir(yol, m.yol))
      .sort((a, b) => b.yol.length - a.yol.length)[0];
    // KART ADRESİ LİSTE SAYILMAZ (16.10.2026): "/muayene/19" kayıtlı kart araması ya da bağlantıyla
    //   açılır - "Muayene Listesi" son açılanlara girmesin; kartın kendisi palet işlemiyle yazılır.
    const kartAdresi = !!eslesen && /^\/[^/]+$/.test(yol.slice(eslesen.yol.split('?')[0].length));
    if (eslesen && !kartAdresi) {
      tercih.sonKaydet(eslesen.yol);
      // SAYAÇ ADRES BAŞINA BİR KEZ: effect menü satırları yeniden kurulunca da çalışır; her seferinde
      //   artırmak Kabuk'u yeniden çizip sonsuz döngüye sokuyordu ("Maximum update depth").
      const anahtar = `${konum.key}|${eslesen.yol}`;
      if (sayilanAdres.current !== anahtar) { sayilanAdres.current = anahtar; tercih.sayacArtir(eslesen.yol) }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [konum.pathname, konum.state, satirlar]);

  // KULLANICI AYARLARI PENCERESI (sifre + dil) kendi kancasinda.
  // TALEPLERIM (mockup Ekranlar/Taleplerim): ust serit paneli, avatar menusu
  //   ve Taleplerim sayfasi ayni ozeti okur - tek yerde, 60 sn'de bir.
  const talepOzeti = useTaleplerimOzeti(kullanici?.id);


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
  /**
   * Sol menu acik/kapali. ACILISTA HEP KAPALI (kullanici 17.10.2026: "program açılışta sol menü her
   * zaman kapalı olsun.. istersek açalım"): eskiden son tercih tarayicida saklanip geri yukleniyordu.
   * Oturum icinde ☰ / Ctrl+B ile acilir ve acik kalir; sayfa yeniden acilinca yine kapali baslar.
   */
  const [menuKapaliKalici, setMenuKapaliKalici] = useState(true);
  /**
   * ANA EKRAN v3 TERCİHLERİ (gorunum): ekran sekmeleri ve sol menü davranışı.
   * "Seçince kapansın" (menuSabit=false): menü kapalı başlar, ☰ / Ctrl+B geçici
   * açar, bir ekran seçilince kapanır. Varsayılan "her zaman açık" - bugünkü davranış.
   */
  const [gorunum, setGorunum] = useState(() => gorunumOku());
  useEffect(() => {
    const yenile = () => setGorunum(gorunumOku());
    window.addEventListener(GORUNUM_OLAYI, yenile);
    return () => window.removeEventListener(GORUNUM_OLAYI, yenile);
  }, []);
  const [geciciAcik, setGeciciAcik] = useState(false);
  /** ROL YETKİSİ (1102 kabuk.menu): menüyü görmeyen rol Ctrl+K, Başlangıç ve sekmelerle çalışır. */
  const menuGorur = yetki('kabuk.menu');
  const menuKapali = !menuGorur || (gorunum.menuSabit ? menuKapaliKalici : !geciciAcik);
  const menuCevir = () => {
    if (!menuGorur) return;
    if (!gorunum.menuSabit) { setGeciciAcik(a => !a); return }
    setMenuKapaliKalici(k => !k);
  };
  // Geçici açılan menü ekran seçilince kapanır.
  useEffect(() => { setGeciciAcik(false) }, [konum.key]);
  // Ctrl+B: menüyü aç / kapat (v3 kısayolu).
  useEffect(() => {
    const tus = (e: KeyboardEvent) => {
      if (e.ctrlKey && !e.shiftKey && e.key.toLowerCase() === 'b') { e.preventDefault(); menuCevir() }
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  });

  // EKRAN SEKMELERİ (ana ekran v3): tercih kapalıysa düz <Outlet/> - eski davranış.
  const outlet = useOutlet();
  const navTuru = useNavigationType();
  // GÖSTERGE PANELLERİ (1103): Ctrl+K'da "gösterge" ile ve sekme başlığında adıyla.
  const [paneller, setPaneller] = useState<GostergePaneliOzet[]>([]);
  useEffect(() => {
    if (!kullanici?.id) return;
    void api.gostergeler().then(setPaneller).catch(() => setPaneller([]));
  }, [kullanici?.id, kullanici?.subeId]);
  /** Ctrl+K "Kayıtlı Hasta / Başvuru Kartı": ikisi de hasta araması, seçimden sonrası farklı. */
  const [kayitliArama, setKayitliArama] = useState<'hasta' | 'basvuru' | 'muayene' | null>(null);
  /** Genel "Kayıtlı X Kartı" araması (listenin kendi kaynağı ve kolonları). */
  const [kayitliListe, setKayitliListe] = useState<ListeGirdisi | null>(null);
  /** Kayıtlı personel kartı araması: kart yolu (/personel). */
  const [kisiArama, setKisiArama] = useState<string | null>(null);
  /** "Kayıtlı Stok / Hizmet Kartı": belgedeki genel stok arama penceresi (kart açma kipi). */
  const [stokArama, setStokArama] = useState<'stok' | 'hizmet' | null>(null);
  /** Ekran kullanıcının (yetkili) menüsünde mi. */
  const menudeVar = useCallback((yol: string) => kodSatirlari.some(sat =>
    sat.tur === 'duz' ? sat.m.yol === yol : sat.alt.some(m => m.yol === yol)), [kodSatirlari]);
  const panelEkranlari = useMemo(() => [
    ...paneller.map(p => ({ yol: `/gosterge/${p.kod}`, ad: p.ad, grup: 'Gösterge Panelleri' })),
    // KİŞİSEL HATIRLATICI (1139, kullanıcı 22.10.2026: "ctrl k aramada Hatırlatmalarım da gelsin"): ekran
    //   menüde değil (kullanıcı menüsü / zil), yetki kodu yok - herkese. Yeni hatırlatma işlemi kartı açar.
    { yol: '/hatirlatmalarim', ad: 'Hatırlatmalarım', grup: 'Kullanıcı' },
    { yol: HATIRLATMA_YENI, ad: 'Yeni Hatırlatma', grup: 'Kullanıcı', islem: true, ikon: '⏰' },
    // YENİ / KAYITLI KART (kullanıcı: "aramada hasta ve başvuru kartı deseninde yeni açma ve kayıtlı
    //   getirme olmalı"): kartı sekmede açılan HER liste için iki işlem; yalnız listesi menüsünde olan
    //   (yetkili) kullanıcıya. Aynı kart yolunu paylaşan listelerden ilki. Boş palette yalnız son
    //   açılan / favori listelerinkiler ve hasta-başvuru görünür (KomutPaleti), tamamı aramada.
    ...kartListeleri.filter(l => menudeVar(listeYolu(l))).flatMap(l => {
      const yol = kartSekmeYolu(l), kart = kartAdi(l);
      return [
        { yol: `${yol}/yeni`, ad: yeniSekmeBasligi(l), grup: l.menuGrup ?? '', islem: true, listeYol: listeYolu(l), sabit: !!SABIT_ARAMA[yol] },
        { yol: `${KAYITLI_ONEK}${yol}`, ad: `Kayıtlı ${kart}`, grup: l.menuGrup ?? '', islem: true, ikon: '📂',
          listeYol: listeYolu(l), sabit: !!SABIT_ARAMA[yol] },
      ];
    }),
  ], [paneller, menudeVar]);
  const panelBasliklari = useMemo(() => ({
    ...Object.fromEntries(paneller.map(p => [`/gosterge/${p.kod}`, { ad: p.ad, ikon: p.ikon }])),
  }), [paneller]);
  // KART KENDİ SEKMESİNDE (liste tanımı yeniSekmede): kartYolu -> yeni kayıt sekme başlığı.
  const kartSekmeleri = useMemo(() => {
    const m: Record<string, { ad: string; ikon: string }> = {};
    // Sekme ikonu listenin ikonu (kullanıcı 23.10.2026).
    for (const l of LISTELER) if (kartSekmesiVar(l)) m[kartSekmeYolu(l)] ??= { ad: yeniSekmeBasligi(l), ikon: l.ic };
    // Özel kartlardan sekmede açılanlar (reçete, 15.10.2026) - "yeni" yolu yok, palete girmez.
    for (const [yol, ad] of Object.entries(OZEL_KART_SEKME_YOLLARI)) m[yol] ??= { ad, ikon: '📝' };
    return m;
  }, []);
  const sekme = useEkranSekmeleri({ satirlar, konum, navTuru, outlet, git, ekBasliklar: panelBasliklari, kartSekmeleri });
  /** Palet / kayıtlı arama kart açar: sekmeler açıksa kayıtsız değişiklikli kart korunur. */
  const kartaGit = (yol: string) => gorunum.ekranSekmeleri ? sekme.kartaGit(yol) : git(yol);
  // KART PERDESİ SEKME ÇUBUĞUNUN ALTINDAN BAŞLAR: kart açıkken de sekmeler arasında
  //   geçilebilsin (gizli sekmenin kartı canlı kalır).
  useEffect(() => {
    const kok = document.documentElement;
    if (!gorunum.ekranSekmeleri) { document.body.classList.remove('ekran-sekmeli'); return }
    document.body.classList.add('ekran-sekmeli');
    const olc = () => {
      const c = document.querySelector('.ekran-sekmeleri');
      if (c) kok.style.setProperty('--perde-ust', `${Math.round(c.getBoundingClientRect().bottom)}px`);
    };
    olc();
    const g = new ResizeObserver(olc);
    const c = document.querySelector('.ekran-sekmeleri'); if (c) g.observe(c);
    window.addEventListener('resize', olc);
    return () => { g.disconnect(); window.removeEventListener('resize', olc); document.body.classList.remove('ekran-sekmeli') };
  }, [gorunum.ekranSekmeleri, menuKapali]);
  const aktifSube = kullanici?.subeler.find(s => s.id === kullanici?.subeId);
  // ŞUBE MARKASI (kullanıcı: "başlıktaki merkez combosunu kaldır, onun yerine
  //   şube logo ve adını soldaki GenoTIP AI gibi yaz"): combo yerine logo + ad;
  //   çok şubeli kullanıcıda tıklayınca şube listesi açılır (değiştirme kalır).
  const subeLogo = useSubeLogo(aktifSube?.logoDokumanId);
  const [subeMenusu, setSubeMenusu] = useState(false);
  /** Avatar menüsü ayarları hangi sekmede açıyor (Profilim / Parola değiştir). */
  const [ayarSekmesi, setAyarSekmesi] = useState<AyarSekmesi>('hesap');
  const ayarlariAc = (sekme: AyarSekmesi) => { setAyarSekmesi(sekme); ayar.setAcik(true) };
  const cokSube = (kullanici?.subeler.length ?? 0) > 1;
  useEffect(() => {
    if (!subeMenusu) return;
    const kapat = () => setSubeMenusu(false);
    document.addEventListener('mousedown', kapat);
    return () => document.removeEventListener('mousedown', kapat);
  }, [subeMenusu]);
  // Sekme başlığı ürün adı + şube: HBYS kurulumunda "Gentegre AI" kalıyordu.
  useEffect(() => {
    document.title = `${urunAdi(kullanici?.urunModu)}${aktifSube ? ` · ${aktifSube.ad}` : ''}`;
  }, [kullanici?.urunModu, aktifSube]);
  // Avatar: ünvansız ad + soyad baş harfi (ortak kural, basHarfler.ts).
  const basHarfler = basHarfHesapla(kullanici?.ad);
  // PROFIL FOTOGRAFI: personel kartinin varsayilan resmi (profilResmi.ts) -
  //   yoksa bas harfler. Ayarlar penceresinden yuklenince burada da tazelenir.
  const profilResmi = useProfilResmi(kullanici?.id);

  /**
   * KOMUT PALETI (790) kabukta: ust seritteki kutu da, Ctrl+K de ayni pencereyi
   * acar. Eskiden palet GenGrid'in icindeydi; kutuya basmak sahte bir Ctrl+K
   * olayi yayinliyordu ve LISTE DISINDA (kart, pano, ozel sayfa) hicbir sey
   * olmuyordu - kullanicinin gozunde dugme bozuktu.
   */
  const [paletAcik, setPaletAcik] = useState(false);
  // Başlangıç'taki büyük arama kutusu paleti açar.
  useEffect(() => {
    const ac = () => setPaletAcik(true);
    window.addEventListener(PALET_AC_OLAYI, ac);
    return () => window.removeEventListener(PALET_AC_OLAYI, ac);
  }, []);
  /**
   * PALET İŞLEMİ (ekran ya da "Kayıtlı ... Kartı"). KAYITLI KART ARAMASI SON AÇILANLARA GİRER
   * (kullanıcı 16.10.2026: "aramada kayıtlı muayene kartı seçip açtım, son açılanlara girmedi") -
   * rota değişimi yalnız menü ekranını yazıyordu. Başlangıç'taki son açılan kartı da buradan açar.
   */
  const paletGit = (yol: string) => {
    if (yol === HATIRLATMA_YENI) { hatirlatmaPenceresiAc(); return }
    if (!yol.startsWith(KAYITLI_ONEK)) { kartaGit(yol); return }
    tercih.sonKaydet(yol);
    const kartYol = yol.slice(KAYITLI_ONEK.length);
    if (SABIT_ARAMA[kartYol]) { setKayitliArama(SABIT_ARAMA[kartYol]); return }
    if (STOK_ARAMA[kartYol]) { setStokArama(STOK_ARAMA[kartYol]); return }
    if (KISI_ARAMA[kartYol]) { setKisiArama(kartYol); return }
    setKayitliListe(kartListeleri.find(l => kartSekmeYolu(l) === kartYol) ?? null);
  };
  const paletGitRef = useRef(paletGit);
  paletGitRef.current = paletGit;
  useEffect(() => {
    const f = (e: Event) => { const yol = (e as CustomEvent<string>).detail; if (yol) paletGitRef.current(yol) };
    window.addEventListener(PALET_GIT_OLAYI, f);
    return () => window.removeEventListener(PALET_GIT_OLAYI, f);
  }, []);

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
    <TaleplerimBaglami.Provider value={talepOzeti}>
    <div className={`kabuk${menuKapali ? ' menu-kapali' : ''}`}>
      <header className="ust">
        {/* Menu ac/kapa: markanin SOLUNDA - kapaninca ana alan tam genislige acilir. */}
        {menuGorur && (
          <button className="ib menu-tus" onClick={menuCevir}
                  title={`${menuKapali ? c('Menüyü aç') : c('Menüyü kapat')} (Ctrl+B)`}
                  aria-expanded={!menuKapali}>
            ☰
          </button>
        )}
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

        <button className="ust-ara" onClick={() => setPaletAcik(true)} title={c('Komut paleti')}>
          <span>🔍</span>
          <span>{c('Ara ya da komut yaz…')}</span>
          <kbd>Ctrl K</kbd>
        </button>

        {/* ORTAM ETİKETİ (1008, kullanıcı 10.10.2026: "Canlı / Demo / Eğitim
            Ortamı"): demo / eğitim kurulumunda belirgin - personel pratik
            yaparken gerçek kurulumda olduğunu sanmasın. Canlıda çizilmez. */}
        {kullanici?.ortam === 'demo' && <span className="ust-ortam demo">DEMO ORTAMI</span>}
        {kullanici?.ortam === 'egitim' && <span className="ust-ortam egitim">EĞİTİM ORTAMI</span>}

        {/* Sube markasi ARA KUTUSU ile TEMA dugmesi arasinda ortada (kullanici). */}
        {aktifSube && (
          <span className="sube-marka-kap" onMouseDown={e => e.stopPropagation()}>
            <div className={`marka sube-marka${cokSube ? ' marka-bag' : ''}`}
                 role={cokSube ? 'button' : undefined} tabIndex={cokSube ? 0 : undefined}
                 title={`${c(aktifSube.ad, 'kod')} - ${cokSube ? c('çalışılan şube, değiştirmek için tıklayın') : c('çalışılan şube')}`}
                 onClick={() => cokSube && setSubeMenusu(v => !v)}
                 onKeyDown={e => { if (cokSube && e.key === 'Enter') setSubeMenusu(v => !v) }}>
              <span className="lg">
                {subeLogo
                  ? <img src={subeLogo} alt="" />
                  : <span className="sube-harf">{aktifSube.ad.trim().charAt(0).toLocaleUpperCase('tr')}</span>}
              </span>
              {/* Sube adi EKRANDA cevrilir (855); faturaya giden ad sunucuda
                  Turkce kalir. LOGO VARSA AD YAZILMAZ (kullanici 24.10.2026: "şubenin sadece
                  logosu yeterli, sağında isme gerek yok") - ad ipucunda; logosuz subede ad kalir. */}
              {!subeLogo && c(aktifSube.ad, 'kod')}{cokSube && <span className="sube-ok">▾</span>}
            </div>
            {subeMenusu && (
              <span className="dil-menu sube-menu">
                {kullanici?.subeler.map(s => (
                  <button key={s.id} type="button"
                          className={`dil-oge${s.id === kullanici?.subeId ? ' on' : ''}`}
                          onClick={() => { setSubeMenusu(false); if (s.id !== kullanici?.subeId) void subeDegistir(s.id) }}>
                    {c(s.ad, 'kod')}{s.yazma ? '' : <span className="sonuk"> ({c('salt okuma')})</span>}
                  </button>
                ))}
              </span>
            )}
          </span>
        )}

        <div className="ustsag">
          {kullanici?.subeYazma === false && <span className="rozet uyari">{c('salt okuma')}</span>}

          {/* Dil secimi: temanin solunda bayrak (kullanici). Kullanici Ayarlari icindeki dil
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

          {/* TALEPLERIM (mockup ①): kirmizi rozet = onayimi bekleyen,
              yesil nokta = kendi talebimde yeni hareket. Mesajin yaninda,
              zilden once - her ekranda tek tikla izin/avans/masraf/belge. */}
          <TaleplerimPaneli />

          {/* ZIL = BANA GELENLER: bana gelen ariza, onayimi bekleyen, iskonto
              onayi - tek tik islemle (taleplerim/TaleplerimPaneli). */}
          {/* YENİ HATIRLATMA (mockup kisisel_hatirlatici.html (1)): her ekrandan, Alt+H ile de. */}
          <button type="button" className="ib" title={c('Yeni hatırlatma (Alt+H)')} onClick={() => hatirlatmaPenceresiAc()}>⏰</button>
          <BanaGelenlerPaneli />

          {/* "?" bulunduğu ekranın yardımını açar (AiRehberPaneli dinler). */}
          {yetki('ai.rehber') && (
            <button className="ib" title={c('Bu ekranın yardımı')}
                    onClick={() => window.dispatchEvent(new Event(YARDIM_AC_OLAYI))}>?</button>
          )}
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
          {/* AVATAR MENUSU (mockup ②): Taleplerim + izin bakiyesi + odenecek
              en ustte; Kullanici Ayarlari artik menunun icinde. */}
          <KullaniciMenusu ad={kullanici?.ad ?? ''} rolAdi={kullanici?.rolAdi}
                           avatar={profilResmi ? <img src={profilResmi} alt="" /> : basHarfler}
                           aktifSubeAd={aktifSube?.ad} cokSube={cokSube}
                           onProfil={() => ayarlariAc('hesap')}
                           onAyarlar={() => ayarlariAc('hesap')}
                           onParola={() => ayarlariAc('guvenlik')}
                           // ŞUBE SEÇİM LİSTESİ ÜST ŞERİTTE: şube markası (logo + ad)
                           //   orada duruyor, ikinci bir liste iki ayrı "aktif şube"
                           //   göstergesi olurdu.
                           onSubeDegistir={() => setSubeMenusu(true)}
                           onCikis={() => void cikisYap()} />
        </div>
      </header>

      <div className="govde">
        {menuGorur && <aside className="yan">
          <YanMenu satirlar={satirlar} tercih={tercih}
                   panelYetkisi /* ana sayfa herkese (15.10.2026) */ aktifSubeAd={aktifSube?.ad}
                   kullaniciKod={kullanici?.ad || kullanici?.kod} rolAdi={kullanici?.rolAdi}
                   kurumProfilAdi={kullanici?.kurumTipiAdi} />
        </aside>}

        <main className={`ana${gorunum.ekranSekmeleri ? ' ana-sekmeli' : ''}`} key={ceviriSurumu}>
          {gorunum.ekranSekmeleri ? <>{sekme.cubuk}{sekme.govde}</> : <Outlet />}
        </main>
      </div>

      {/* KULLANICI AYARLARI (669): dort sekmeli pencere ayri bilesende
          (bilesenler/KullaniciAyarlari.tsx). Kabuk'ta gomulu dururken
          Hesabim/Gorunum/Guvenlik/Bildirim sekmeleri kabugu 200 satir daha
          buyutecekti; pencerenin kendi verisi de var (hesap, oturumlar). */}
      <KullaniciAyarlari ayar={ayar} tema={tema} setTema={setTema} c={c} ilkSekme={ayarSekmesi} />

      {/* AI REHBER (447): sag altta, her ekranda. Yol gosterir; kayit
          degistirmez. Yetkisi olmayana hic cizilmez. */}
      {yetki('ai.rehber') && <AiRehberPaneli urunModu={kullanici?.urunModu} />}

      {/* KOMUT PALETI (790): ust seritteki "Ara ya da komut yaz" kutusunun
          karsiligi. Icerigi SOL MENUNUN KENDISI (ayni yetki/modul suzgeci) +
          acik ekranin dugmeleri. */}
      <KomutPaleti satirlar={satirlar} favoriler={tercih.favoriler}
                   sonMenuler={tercih.sonMenuler} ekranSayac={tercih.ekranSayac} acik={paletAcik}
                   onAc={() => setPaletAcik(true)} onKapat={() => setPaletAcik(false)}
                   git={paletGit}
                   ekEkranlar={panelEkranlari} />
      {/* KAYITLI HASTA KARTI (Ctrl+K): genel hasta arama -> kart kendi sekmesinde. */}
      {stokArama && (
        <StokAramaPenceresi etkin kartAc yalnizStok={stokArama === 'stok'} yalnizHizmet={stokArama === 'hizmet'}
                            onKapat={() => setStokArama(null)}
                            onSec={r => { setStokArama(null); kartaGit(`/${r.tip === 'hizmet' ? 'hizmet' : 'stok'}/${r.id}`) }} />
      )}
      {/* KAYITLI PERSONEL KARTI (17.10.2026): jenerik personel araması -> kart kendi sekmesinde. */}
      <TarafArama acik={kisiArama !== null} kaynaklar={kisiArama ? [KISI_ARAMA[kisiArama]] : ['personel']} kartYok
                  yerTutucu={c('Personel ara (ad, sicil, kimlik no, telefon)…')}
                  onKapat={() => setKisiArama(null)}
                  onSec={p => { const yol = kisiArama; setKisiArama(null); if (yol) kartaGit(`${yol}/${p.id}`) }} />
      <KayitArama acik={!!kayitliListe} baslik={kayitliListe ? `Kayıtlı ${kartAdi(kayitliListe)}` : ''}
                  kaynak={kayitliListe?.kaynak ?? ''} sabitFiltre={kayitliListe?.sabitFiltre}
                  onKapat={() => setKayitliListe(null)}
                  onSec={id => { if (kayitliListe) kartaGit(`${kartSekmeYolu(kayitliListe)}/${id}`) }} />
      {/* KAYITLI BAŞVURU KARTI da aynı hasta araması (kullanıcı): seçilen hastanın SON başvurusu açılır. */}
      <TarafArama acik={kayitliArama !== null} kaynaklar={['hasta']} kartYok
                  yerTutucu={c('Hasta ara (ad, dosya no, kimlik no, telefon)…')}
                  onKapat={() => setKayitliArama(null)}
                  onSec={h => {
                    const tur = kayitliArama; setKayitliArama(null);
                    if (tur === 'hasta') { kartaGit(`/hasta/${h.id}`); return }
                    if (tur === 'muayene') {
                      void api.liste('muayene', {
                        sayfa: 1, boyut: 1,
                        sirala: [{ alan: 'muayeneTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
                        filtre: { op: 'and', kosullar: [{ alan: 'hastaId', op: 'esit', deger: h.id }] },
                      }).then(y => {
                        const son = y.satirlar[0];
                        if (son) kartaGit(`/muayene/${son.id}`);
                        else mesaj(c('{0} için kayıtlı muayene yok.').replace('{0}', h.unvan));
                      }).catch(e => mesaj(hataMetni(e)));
                      return;
                    }
                    void api.liste('belge', {
                      sayfa: 1, boyut: 1,
                      sirala: [{ alan: 'belgeTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
                      filtre: { op: 'and', kosullar: [
                        { alan: 'tur', op: 'esit', deger: 19 }, { alan: 'tipi', op: 'esit', deger: 30 },
                        { alan: 'hastaId', op: 'esit', deger: h.id } ] },
                    }).then(y => {
                      const son = y.satirlar[0];
                      if (son) kartaGit(`/basvuru/${son.id}`);
                      else mesaj(c('{0} için kayıtlı başvuru yok.').replace('{0}', h.unvan));
                    }).catch(e => mesaj(hataMetni(e)));
                  }} />

      {/* YENI TALEP PENCERESI: panelden de sayfadan da yeniTalepAc() ile. */}
      <YeniTalepKatmani />
      {/* ANLIK BILDIRIM (gelen_talepler mockup): yeni is acik ekranin sol altina. */}
      <TalepBildirimleri />
      {/* KİŞİSEL HATIRLATICI (1139): kart penceresi, açılır uyarılar, Alt+H. */}
      <HatirlatmaYoneticisi />
      <IskontoKararKatmani />
      {/* DUYURU (957): okuma / yayinla penceresi + kritik duyuru tam ekran. */}
      <DuyuruKatmani />
    </div>
    </TaleplerimBaglami.Provider>
  );
}
