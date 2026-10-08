import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';
import { LISTELER } from './Liste';
import { menuSatirlariKur, type MenuSatiri } from './kabuk/menuAgaci';
import { BOLGE_HBYS } from './kabuk/menuBolgeleri';
import { DUGUM } from './kabuk/menuDuzenHarita';
import { grupKodu, ogeKoduBaglamli, cakisanKaynaklar, MENU_DUZEN_OLAYI,
         type MenuDuzenSatiri } from './kabuk/menuDuzeni';

/**
 * MENÜ DÜZENİ (979, mockup `Ekranlar/Ayarlar/menu_duzenleme_v2.html`).
 *
 * Menü ağacı KODDAN kurulur; bu ekran kurumun <b>farkını</b> düzenler ve
 * sunucuda `menu_duzen` olarak saklar. Satırı olmayan düğüm varsayılan yerinde
 * çıkar - yeni bir modül eklendiğinde şube düzeni onu gizlemez.
 *
 * <b>Gizlemek yetki değildir:</b> menüden kaldırılan ekran, yetkisi olan
 * kullanıcıya adresten yine açılır. Ekranda bu uyarı yazılı durur.
 */
type Dugum = {
  tur: 'bolge' | 'grup' | 'ekran';
  kod: string;
  /** Koddaki ad (çevrilmemiş olabilir) - "sistem adı" olarak gösterilir. */
  sistemAd: string;
  ad: string;
  ikon?: string;
  ustKod?: string;
  /** Koddaki doğal sıra (menuSira) - düzen sırası boşsa bu geçerli. */
  sira?: number;
  /** Ekranın modül kodu (kurum profilinde açılıp kapanan paket). */
  modul?: string;
  /** Rotadaki grup süzgeci - "Dökümler" gibi PAYLAŞILAN ekranlarda dolu. */
  suzgec?: string;
  derinlik: number;
  /** Ekran düğümünde rota - "nereye gider" sütunu. */
  yol?: string;
};

/**
 * `gomulu`: Kurum Profili'nin "Menü Düzeni" sekmesinde çizilirken ekranın
 * kendi başlığı ve yol çizgisi gizlenir - kart zaten "Kurum Profili › Menü
 * Düzeni" diyor, ikinci başlık ekranı ikiye bölüyordu.
 */
/**
 * Rotadaki grup süzgeci: `/dokumler?grup=Randevu` → "Randevu".
 *
 * "Dökümler" ve benzeri PAYLAŞILAN ekranlar her grubun altında aynı rotaya
 * gider; hangi grubun verisini açtığını yalnız bu süzgeç söyler. Düzen ekranı
 * bunu yazar - kullanıcı başlığı taşırken neyi taşıdığını görsün.
 */
/**
 * İÇ DÜĞÜM KODU = TÜR + VERİTABANI KODU.
 *
 * "Yönetim" hem bir BÖLGE hem bir GRUP adı (kullanıcı 07.10.2026: *"aktif
 * bölgede yönetim bölge altında yönetim grup yok ama ana menüde var"*). Ağaç
 * düğümleri yalnız adla anahtarlandığında ikisi tek düğüme düşüyor, grup
 * düzenleme ekranından kayboluyordu. İç anahtar türü de taşır; veritabanına
 * yazılırken tür ayrı alanda (`dugumTur`) gittiği için ön ek atılır.
 */
const TUR_ONEK = { bolge: 'b', grup: 'g', ekran: 'e' } as const;
const icKod = (tur: keyof typeof TUR_ONEK, dbKod: string) => `${TUR_ONEK[tur]}|${dbKod}`;
/** İç koddan veritabanı kodu (`g|Yönetim` → `Yönetim`). */
const dbKod = (ic: string) => (ic.length > 1 && ic[1] === '|' ? ic.slice(2) : ic);
const turNo = (tur: 'bolge' | 'grup' | 'ekran') =>
  tur === 'bolge' ? DUGUM.bolge : tur === 'grup' ? DUGUM.grup : DUGUM.ekran;
/** Üst düğümün türü sabittir: ekranın üstü grup, grubun üstü bölge. */
const ustTuru = (tur: 'bolge' | 'grup' | 'ekran') => (tur === 'ekran' ? 'grup' : 'bolge');

function suzgecCoz(yol: string): string | undefined {
  const e = /[?&]grup=([^&]+)/.exec(yol);
  return e ? decodeURIComponent(e[1]) : undefined;
}

export function MenuDuzeni({ gomulu, kaydetBagla }: {
  gomulu?: boolean;
  /**
   * GÖMÜLÜ MODDA KAYDETMEYİ EBEVEYN YAPAR (kullanıcı 08.10.2026: "tek kaydet
   * uygulama yeterli"). Ekran kendi Kaydet düğmesini çizmez; kaydetme
   * fonksiyonunu buradan verir, Kurum Profili'nin ana Kaydet'i çağırır.
   *
   * Fonksiyon bir ref üzerinden veriliyor: `kaydet` her render'da yeniden
   * kuruluyor ve doğrudan geçirmek ebeveyni her render'da güncellemeye
   * zorlardı.
   */
  kaydetBagla?: (fn: (() => Promise<void>) | null) => void;
} = {}) {
  const { kullanici, yetki } = useOturum();
  const duzenleyebilir = yetki('menu.duzen', 'degistir');
  const [subeId, setSubeId] = useState<number>(kullanici?.subeId ?? 0);
  const [duzen, setDuzen] = useState<MenuDuzenSatiri[]>([]);
  const [subeyeOzel, setSubeyeOzel] = useState(0);
  const [secili, setSecili] = useState<string | null>(null);
  const [surukle, setSurukle] = useState<string | null>(null);
  /**
   * AĞAÇ KATLANIR, VARSAYILAN KAPALI (kullanıcı 06.10.2026: "grup kapanır
   * açılır olsun", "gruplar kapalı olsun default"): tam menü ~330 düğüm -
   * hepsi açıkken aranan satır ekrana sığmıyordu.
   */
  const dosyaGirdi = useRef<HTMLInputElement>(null);
  const aktarimGirdi = useRef<HTMLInputElement>(null);
  const [acik, setAcik] = useState<Record<string, boolean>>({});
  const [pasifAcik, setPasifAcik] = useState<Record<string, boolean>>({});
  /** Sunucudaki hal: kaydedilmemiş değişiklik var mı, buradan anlaşılır. */
  const [sunucudaki, setSunucudaki] = useState<MenuDuzenSatiri[]>([]);
  const acikMi = (kod: string) => acik[kod] === true;
  const ac = (kod: string) => setAcik(o => ({ ...o, [kod]: !o[kod] }));
  const [mesaj, setMesaj] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  // Varsayılan ağaç: menüyü çizen AYNI kuruluş (menuSatirlariKur) - ekranda
  //   başka bir sıralama göstermek, kaydedilen düzenin menüde farklı çıkması
  //   demekti.
  const satirlar: MenuSatiri[] = useMemo(
    () => menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller),
    [yetki, kullanici?.urunModu, kullanici?.moduller]);

  const bolgeli = kullanici?.urunModu === 2 && kullanici?.menuBolgeli === 1;

  /** Ağacı düz listeye açar: bölge › grup › ekran (mockup soldaki ağaç). */
  const dugumler: Dugum[] = useMemo(() => {
    const d: Dugum[] = [];
    // ÇAKIŞAN KAYNAK GRUP BAĞLAMI ALIR: "Dökümler" her grubun altında aynı
    //   `dokumler` kaynağıyla duruyor; tek kod sayıldığında ağaç ve önizleme
    //   aynı React anahtarını tekrarlıyor, grup başlıkları düşüyor ve satırlar
    //   çiftleniyordu - bir grubun Dökümler'ini gizlemek hepsini gizlerdi.
    const cakisan = cakisanKaynaklar(satirlar);
    // AYNI GRUPTA AYNI EKRAN İKİ KEZ geçebiliyor (menü tanımındaki tekrar):
    //   grup bağlamı bile kodu benzersiz yapmaz, ağaç o düğümü kendi altına
    //   alıp özyinelemeye girerdi. Tekrara sayı eklenir - kod yine
    //   KARARLIDIR (menü tanımının sırası değişmedikçe aynı kalır).
    const sayac = new Map<string, number>();
    const benzersiz = (kod: string) => {
      const n = (sayac.get(kod) ?? 0) + 1;
      sayac.set(kod, n);
      return n === 1 ? kod : `${kod}#${n}`;
    };
    const gruplar = satirlar.filter(s => s.tur === 'grup') as Extract<MenuSatiri, { tur: 'grup' }>[];
    const duzOgeler = satirlar.filter(s => s.tur === 'duz') as Extract<MenuSatiri, { tur: 'duz' }>[];

    const grupEkle = (sat: Extract<MenuSatiri, { tur: 'grup' }>, ustIc?: string) => {
      const kod = grupKodu(sat);
      const ic = icKod('grup', kod);
      d.push({ tur: 'grup', kod: ic, sistemAd: kod, ad: sat.ad,
               ustKod: ustIc, derinlik: ustIc ? 2 : 1 });
      sayac.set(kod, 1);
      for (const m of sat.alt)
        d.push({
          tur: 'ekran', kod: icKod('ekran', benzersiz(ogeKoduBaglamli(m, kod, cakisan))),
          sistemAd: m.adHam ?? m.ad, ad: m.ad, sira: m.sira,
          modul: m.modul, suzgec: suzgecCoz(m.yol),
          ikon: m.ic, ustKod: ic, derinlik: ustIc ? 3 : 2, yol: m.yol,
        });
    };

    if (bolgeli) {
      for (const b of BOLGE_HBYS) {
        d.push({ tur: 'bolge', kod: icKod('bolge', b.ad), sistemAd: b.ad,
                 ad: c(b.ad), derinlik: 1 });
        for (const g of b.gruplar) {
          const sat = gruplar.find(x => grupKodu(x) === g);
          if (sat) grupEkle(sat, icKod('bolge', b.ad));
        }
      }
      // Bölgeye yazılmamış grup: Yönetim bölgesinin altına düşer (menuBolgeleri
      //   kuralı) - burada da aynı yere konur ki ekran menüyle aynı şeyi göstersin.
      const yazilanlar = new Set(BOLGE_HBYS.flatMap(b => b.gruplar));
      for (const sat of gruplar)
        if (!yazilanlar.has(grupKodu(sat)))
          grupEkle(sat, icKod('bolge', BOLGE_HBYS[BOLGE_HBYS.length - 1].ad));
    } else {
      for (const sat of gruplar) grupEkle(sat);
    }
    for (const s of duzOgeler)
      d.push({
        tur: 'ekran',
        kod: icKod('ekran', benzersiz(ogeKoduBaglamli(s.m, undefined, cakisan))),
        sistemAd: s.m.adHam ?? s.m.ad, ad: s.m.ad,
        modul: s.m.modul, suzgec: suzgecCoz(s.m.yol),
        ikon: s.m.ic, derinlik: 1, yol: s.m.yol,
      });
    return d;
  }, [satirlar, bolgeli]);

  useEffect(() => {
    let iptal = false;
    setYukleniyor(true);
    api.menuDuzen(subeId || undefined)
      .then(y => { if (!iptal) { setDuzen(y.satirlar); setSunucudaki(y.satirlar);
                                 setSubeyeOzel(y.subeyeOzel) } })
      .catch(h => { if (!iptal) setMesaj(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [subeId]);

  /**
   * Düğümün düzen kaydı. Arama TÜR + VERİTABANI KODU ile: "Yönetim" hem bölge
   * hem grup adı, yalnız kodla aranınca birinin kaydı diğerininmiş gibi
   * okunuyordu.
   */
  const fark = (icKodu: string) => {
    const tur = icKodu[0] === 'b' ? DUGUM.bolge : icKodu[0] === 'g' ? DUGUM.grup : DUGUM.ekran;
    const kod = dbKod(icKodu);
    return duzen.find(x => x.sistemKod === kod && x.dugumTur === tur);
  };

  /**
   * KAYDEDİLMEMİŞ DEĞİŞİKLİK VAR MI?
   *
   * Ekranda yapılan her şey önce yerel durumda birikiyor; menü ancak *Kaydet &
   * Uygula* ile değişiyor. Bu rozet olmadığında "düzenleme ekranı ile ana menü
   * aynı değil" denen durum aslında kaydedilmemiş değişiklik oluyordu.
   */
  const kirli = useMemo(() => {
    const anahtar = (r: MenuDuzenSatiri) => [r.sistemKod, r.ustKod ?? '', r.sira ?? '',
      r.gorunenAd ?? '', r.ikon ?? '', r.gizli, r.acilistaAcik].join('');
    const a = duzen.map(anahtar).sort();
    const b = sunucudaki.map(anahtar).sort();
    return a.length !== b.length || a.some((x, i) => x !== b[i]);
  }, [duzen, sunucudaki]);
  /**
   * BASAMAKLI GİZLEME (kullanıcı 06.10.2026): "grup görünmez yapılırsa
   * altındakiler de görünmez olur, görünür yapılırsa altındakiler görünür".
   *
   * Alt düğümün KENDİ kaydı yazılmaz - üstünü takip eder. Böylece grubu geri
   * açınca altındakiler kendiliğinden döner; alt satırlara tek tek "gizli"
   * yazılsaydı grup açıldığında hepsi gizli kalırdı.
   */
  /**
   * Düğümün ETKİN üstü: kurum taşıdıysa yeni başlık, yoksa koddaki.
   * BOŞ DİZE = EN ÜST (kök seviye): kurum grubu bölge dışına çıkarmış.
   */
  const etkinUst = (dugum: Dugum): string | undefined => {
    const u = fark(dugum.kod)?.ustKod;
    if (u === '') return undefined;                    // kurum en üste almış
    // Kayıttaki üst VERİTABANI kodudur; iç koda çevrilir. Üst türü sabit:
    //   ekranın üstü grup, grubun üstü bölge.
    if (u != null) return icKod(ustTuru(dugum.tur), u);
    return dugum.ustKod ?? undefined;
  };

  const ustGizli = (dugum: Dugum): boolean => {
    let kod = etkinUst(dugum);
    const gorulen = new Set<string>();
    while (kod && !gorulen.has(kod)) {
      gorulen.add(kod);
      if (fark(kod)?.gizli === 1) return true;
      const ust = dugumler.find(x => x.kod === kod);
      kod = ust ? etkinUst(ust) : undefined;
    }
    return false;
  };
  /** Ekranda gizli görünür mü: kendi işareti ya da üstünden miras. */
  const gizliMi = (dugum: Dugum) => fark(dugum.kod)?.gizli === 1 || ustGizli(dugum);
  const seciliDugum = dugumler.find(x => x.kod === secili) ?? null;

  /** Farkı günceller: değer varsayılana döndüyse satır SİLİNİR (fark kalmasın). */
  const farkYaz = (dugum: Dugum, parca: Partial<MenuDuzenSatiri>) => {
    setDuzen(onceki => {
      const tur = turNo(dugum.tur);
      const kod = dbKod(dugum.kod);
      const mevcut = onceki.find(x => x.sistemKod === kod && x.dugumTur === tur);
      const birlesik = { ...mevcut, ...parca };
      const yeni: MenuDuzenSatiri = {
        dugumTur: tur,
        sistemKod: kod,
        sira: null, gorunenAd: '', ikon: '', gizli: 0, acilistaAcik: 0,
        ...birlesik,
        // ÜST KOD DAİMA VERİTABANI BİÇİMİNDE (07.10.2026 hatası): çağıranlar
        //   (üst başlık seçimi, sürükleme) İÇ KOD veriyor (`b|Yönetim`) ve
        //   `...parca` onu ham geçirdiği için önek veritabanına yazılıyordu.
        //   Ağaçta `b|Yönetim` diye üst olmadığından o grup menüden
        //   kayboluyordu. Normalleştirme tek yerde, burada.
        ustKod: birlesik.ustKod !== undefined
          ? (birlesik.ustKod != null ? dbKod(birlesik.ustKod) : null)
          : (dugum.ustKod != null ? dbKod(dugum.ustKod) : null),
      };
      // ÜST BAŞLIK DEĞİŞİKLİĞİ DE BİR FARKTIR: kayıt yalnız varsayılanla aynıysa
      //   düşer. Taşınan ekran (ustKod başka grup) bu kontrolde boş sayılırsa
      //   kaydetmeden siliniyordu.
      // '' (en üst) de bir taşımadır: null'a eşitlenirse kayıt boş sayılıp
      //   silinir ve grup bölgesine geri düşerdi.
      const tasindi = (yeni.ustKod ?? null)
                      !== (dugum.ustKod != null ? dbKod(dugum.ustKod) : null);
      const bos = yeni.gizli === 0 && yeni.acilistaAcik === 0 && !tasindi
        && !yeni.gorunenAd && !yeni.ikon && (yeni.sira === null || yeni.sira === undefined);
      const kalan = onceki.filter(x => !(x.sistemKod === kod && x.dugumTur === tur));
      return bos ? kalan : [...kalan, yeni];
    });
  };

  /**
   * Düğümün taşınabileceği üst başlıklar: ekran GRUPLARA, grup (bölgeli
   * düzende) BÖLGELERE taşınır. Bölge düğümünün üstü yoktur - liste boş döner
   * ve alan salt okunur kalır.
   */
  const ustSecenekleri = (dugum: Dugum): string[] => {
    if (dugum.tur === 'ekran')
      return dugumler.filter(x => x.tur === 'grup').map(x => x.kod);
    // GRUP BÖLGE DIŞINA DA ÇIKAR: boş dize "en üst" demek - grup bölgelerin
    //   üstünde, derinlik 1'de çizilir (kullanıcı: "derinlik 2 olan bir grubu
    //   en üste derinlik 1'e alamadım").
    if (dugum.tur === 'grup' && bolgeli)
      return ['', ...dugumler.filter(x => x.tur === 'bolge').map(x => x.kod)];
    return [];
  };

  /** Seçili düğümün ikonu yüklenmiş görsel mi (emoji ise metin kutusu çizilir). */
  const ikonGorsel = seciliDugum && (fark(seciliDugum.kod)?.ikon ?? '').startsWith('data:image/')
    ? fark(seciliDugum.kod)!.ikon! : '';

  /**
   * İKON YÜKLEME (980): seçilen görsel tarayıcıda 64x64 PNG'ye küçültülür.
   * Ham dosyayı göndermek 2 MB'lık bir fotoğrafı menüye koymak demekti;
   * küçültme sunucu sınırının (64 KB) altında kalmayı da garantiler.
   */
  const ikonYukle = (dosya: File | undefined) => {
    if (!dosya || !seciliDugum) return;
    const oku = new FileReader();
    oku.onload = () => {
      const im = new Image();
      im.onload = () => {
        const tuval = document.createElement('canvas');
        tuval.width = 64; tuval.height = 64;
        const ctx = tuval.getContext('2d');
        if (!ctx) return;
        // ORAN KORUNUR: kare olmayan logo ezilmesin - ortalanır.
        const olcek = Math.min(64 / im.width, 64 / im.height);
        const g = im.width * olcek, y = im.height * olcek;
        ctx.drawImage(im, (64 - g) / 2, (64 - y) / 2, g, y);
        const veri = tuval.toDataURL('image/png');
        if (veri.length > 65536) { setMesaj(c('Görsel çok büyük.')); return }
        farkYaz(seciliDugum, { ikon: veri });
      };
      im.src = String(oku.result);
    };
    oku.readAsDataURL(dosya);
    if (dosyaGirdi.current) dosyaGirdi.current.value = '';
  };

  /**
   * YERLEŞİM: düzen farkı UYGULANMIŞ ağaç - taşıma ve sıra burada görünür.
   *
   * <b>Hem sol ağaç hem önizleme bunu kullanır</b> (kullanıcı 07.10.2026:
   * "sürükle bırak yapıyorum değişmiyor"): ağaç koddaki sırayı çiziyordu, yani
   * sürükleme kaydı yazılıyor ama ekranda hiçbir şey kıpırdamıyordu. Tek
   * yerleşim, iki görünümün aynı şeyi göstermesini garanti eder.
   *
   * Sıra anahtarı: kurumun verdiği sıra > koddaki menuSira > ağaçtaki yer.
   */
  const yerlesim = useMemo(() => {
    const dogal = new Map(dugumler.map((d, i) => [d.kod, i]));
    const siraNo = (d: Dugum) =>
      fark(d.kod)?.sira ?? d.sira ?? ((dogal.get(d.kod) ?? 0) + 1) * 1000;
    // Gizliler DE yerleşimde durur: sol ağaç onları 🚫 ile çizmeli, süzme
    //   yalnız önizlemede yapılır.
    const cocuklar = (ust: string | undefined) => dugumler
      .filter(d => etkinUst(d) === ust)
      .sort((a, b) => siraNo(a) - siraNo(b) || (dogal.get(a.kod)! - dogal.get(b.kod)!));
    const cikti: { d: Dugum; derinlik: number }[] = [];
    // ÇİZİLEN HER DÜĞÜM BİR KEZ: kurum bir düğümü kendi alt ağacına taşırsa
    //   (ya da iki düğüm aynı kodu taşırsa) özyineleme kendini yer. Önizleme
    //   bunu sessizce keser - düzenleme ekranı çökmemeli.
    const gezildi = new Set<string>();
    const gez = (ust: string | undefined, derinlik: number) => {
      if (derinlik > 6) return;
      for (const c of cocuklar(ust)) {
        if (gezildi.has(c.kod)) continue;
        gezildi.add(c.kod);
        cikti.push({ d: c, derinlik });
        gez(c.kod, derinlik + 1);
      }
    };
    gez(undefined, 1);
    return cikti;
  }, [dugumler, duzen]);

  /**
   * PASİF MENÜ (kullanıcı 07.10.2026): "kullanmayacaklarımı sağdaki pasif
   * menüye taşısam, sadece kullanacağım aktifler sol menüde kalsa; ihtiyaç
   * olduğunda sağdan sola taşıyıp yerine yerleştirsem".
   *
   * Sağ panel artık önizleme değil, **gizlenenlerin listesi**: aktif menüden
   * çıkarılan düğümler oraya düşer, sürükleyerek geri alınır. Gizleme modeli
   * aynı (`gizli = 1`) - değişen yalnız nasıl gösterildiği.
   */
  const pasifSatirlari = useMemo(() => {
    const derinlikH = new Map(yerlesim.map(({ d, derinlik }) => [d.kod, derinlik]));
    const cikti: { d: Dugum; derinlik: number; baslik?: boolean }[] = [];
    const eklendi = new Set<string>();
    /**
     * ÜST BAŞLIK PASİFTE DE ÇİZİLİR (kullanıcı 07.10.2026: "bir ekranı
     * aktiften pasife aldığımda o ekranın üst menüsü yoksa pasifte üst menü
     * oluşturup altına girsin").
     *
     * Tek bir ekranı pasife almak onu köksüz bırakıyordu: listede "Dökümler"
     * yazıyor, hangi grubun dökümü olduğu görünmüyordu. Üst zincir YER
     * GÖSTERGESİ olarak eklenir (`baslik`) - o başlık aktif menüde duruyor,
     * burada yalnız ekranın nereden geldiğini söyler: sürüklenmez, geri
     * alınmaz, yalnız katlanır.
     */
    const ustEkle = (d: Dugum) => {
      const u = etkinUst(d);
      if (!u) return;
      const ust = dugumler.find(x => x.kod === u);
      if (!ust) return;
      ustEkle(ust);
      if (eklendi.has(ust.kod)) return;
      eklendi.add(ust.kod);
      cikti.push({ d: ust, derinlik: derinlikH.get(ust.kod) ?? 1, baslik: !gizliMi(ust) });
    };
    for (const { d, derinlik } of yerlesim) {
      if (!gizliMi(d)) continue;
      ustEkle(d);
      if (eklendi.has(d.kod)) continue;
      eklendi.add(d.kod);
      cikti.push({ d, derinlik });
    }
    return cikti;
  }, [yerlesim, duzen]);

  /**
   * Pasif menüde açık başlıklar. Varsayılan KAPALI: pasife alınan bir bölge
   * altındaki onlarca satırı birden açmak listeyi okunmaz yapıyordu.
   */
  const pasifAcikMi = (kod: string) => pasifAcik[kod] === true;
  const pasifAc = (kod: string) =>
    setPasifAcik(o => ({ ...o, [kod]: !pasifAcikMi(kod) }));

  /** Pasif panelde çizilecek satırlar: üst zinciri kapalıysa gösterilmez. */
  const pasifGorunur = pasifSatirlari.filter(({ d }) => {
    let k = etkinUst(d);
    const gorulen = new Set<string>();
    while (k && !gorulen.has(k)) {
      gorulen.add(k);
      // Üst, pasif listesinde yer gösterge satırı olarak da olabilir; listede
      //   hiç yoksa zincir orada biter.
      if (!pasifSatirlari.some(x => x.d.kod === k)) break;
      if (!pasifAcikMi(k)) return false;
      const ust = dugumler.find(x => x.kod === k);
      k = ust ? etkinUst(ust) : undefined;
    }
    return true;
  });

  /** Sol ağaç: AKTİF menü - gizlenenler burada çizilmez, pasif panelde durur. */
  const agacSatirlari = yerlesim.filter(({ d }) => !gizliMi(d)).filter(({ d }) => {
    let k = etkinUst(d);
    const gorulen = new Set<string>();
    while (k && !gorulen.has(k)) {
      gorulen.add(k);
      if (!acikMi(k)) return false;
      const ust = dugumler.find(x => x.kod === k);
      k = ust ? etkinUst(ust) : undefined;
    }
    return true;
  });

  /**
   * KAYDEDİLECEK SATIRLAR = kurumun düzenlemeleri + TÜRETİLMİŞ ERİŞİM KAPILARI.
   *
   * Gizlemek erişimi kapatır (kullanıcı 07.10.2026: "Erişimi KAPATIR: adresi
   * bilen yetkili kullanıcı ekranı açamaz"). Kapı sunucuda, ekranın liste/kart
   * KAYNAK adıyla çalışıyor; ağaçta ise kod grup bağlamlı olabiliyor
   * (`Randevu/dokumler`) ve bir grubu gizlemek alt satırlara kayıt YAZMIYOR
   * (grup geri açılınca hepsi dönsün diye). Bu ikisini şurada birleştiriyoruz:
   * kaydederken, menüde <b>görünür tek girişi kalmayan</b> her ekran kaynağı
   * için sade kodlu bir gizli satır üretilir - sunucu kapısı onu görür.
   *
   * Bir ekranın iki grupta kısayolu varsa ve biri açıksa kapı YAZILMAZ: ekran
   * menüde duruyor, erişimi kapatmak yanlış olurdu.
   *
   * Türetilmiş satırlar her kaydetmede baştan hesaplanır; önce bir öncekiler
   * atılır, yoksa grup geri açıldığında eski kapı kaydı ekranı kapalı tutardı.
   */
  const kaydedilecek = (): MenuDuzenSatiri[] => {
    const sade = (ic: string) => dbKod(ic).split('/').pop()!.replace(/#\d+$/, '');
    // Kurumun kendi satırları: ağaçta karşılığı olanlar + kurumun ürettiği
    //   düğümler (alt başlık / dış bağlantı, dugumTur 3). Eşleşme TÜR + KOD.
    const kendi = duzen.filter(x => x.dugumTur === DUGUM.altBaslik
      || dugumler.some(d => dbKod(d.kod) === x.sistemKod && turNo(d.tur) === x.dugumTur));
    const kapiliKodlar = new Set(
      kendi.filter(x => x.dugumTur === DUGUM.ekran).map(x => x.sistemKod));

    const toplam = new Map<string, { hepsi: number; gizliSay: number }>();
    for (const d of dugumler) {
      if (d.tur !== 'ekran') continue;
      const k = sade(d.kod);
      const o = toplam.get(k) ?? { hepsi: 0, gizliSay: 0 };
      o.hepsi += 1;
      if (gizliMi(d)) o.gizliSay += 1;
      toplam.set(k, o);
    }
    const turetilmis: MenuDuzenSatiri[] = [];
    for (const [k, o] of toplam) {
      if (o.gizliSay < o.hepsi) continue;        // bir yerde görünüyor
      if (kapiliKodlar.has(k)) continue;         // kurum zaten kendisi yazmış
      turetilmis.push({
        dugumTur: DUGUM.ekran, sistemKod: k, ustKod: null, sira: null,
        gorunenAd: '', ikon: '', gizli: 1, acilistaAcik: 0,
      });
    }
    return [...kendi, ...turetilmis];
  };

  const kaydet = async () => {
    if (!subeId) { setMesaj(c('Şube seçili değil.')); return }
    try {
      const gonderilen = kaydedilecek();
      const y = await api.menuDuzenKaydet(subeId, gonderilen);
      setDuzen(gonderilen);
      setSunucudaki(gonderilen);
      setSubeyeOzel(y.satir);
      // ANA MENÜ ANINDA GEÇERLİ: kabuk bu olayı dinliyor ve düzeni yeniden
      //   okuyor - kurum değişikliğini görmek için sayfayı yenilemesin.
      window.dispatchEvent(new Event(MENU_DUZEN_OLAYI));
      setMesaj(c('Kaydedildi') + ` · ${y.satir} ${c('değişiklik')}`);
    } catch (h) { setMesaj(hataMetni(h)) }
  };

  // ---------------------------------------------------------------- AKTARIM
  /**
   * DIŞA / İÇE AKTARIM (kullanıcı 07.10.2026: "bu menüyü export/import
   * yapalım"): bir şubede kurulan düzen dosyaya yazılır, başka şubeye ya da
   * başka kuruluma yüklenir. Taşınan şey yalnız FARK - menü ağacının kendisi
   * koddan geldiği için dosya kuruluma özel ekran listesi taşımaz.
   */
  const AKTARIM_SURUM = 1;

  const disaAktar = () => {
    const paket = {
      tur: 'gentegre-menu-duzeni',
      surum: AKTARIM_SURUM,
      tarih: new Date().toISOString(),
      // Bilgi amaçlı: hangi şubeden alındı, hangi üründe kuruldu. Yüklerken
      //   ZORLAYICI değil - aynı düzen başka şubeye de yüklenebilmeli.
      subeId, subeAd: (kullanici?.subeler ?? []).find(x => x.id === subeId)?.ad ?? '',
      urunModu: kullanici?.urunModu ?? 0,
      satirlar: duzen,
    };
    const dosya = new Blob([JSON.stringify(paket, null, 2)],
                           { type: 'application/json' });
    const url = URL.createObjectURL(dosya);
    const a = document.createElement('a');
    a.href = url;
    a.download = `menu-duzeni-${paket.subeAd || subeId}-${new Date()
      .toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    setMesaj(c('Dışa aktarıldı') + ` · ${duzen.length} ${c('satır')}`);
  };

  const iceAktar = (dosya: File | undefined) => {
    if (!dosya) return;
    const oku = new FileReader();
    oku.onload = () => {
      try {
        const paket = JSON.parse(String(oku.result));
        if (paket?.tur !== 'gentegre-menu-duzeni' || !Array.isArray(paket.satirlar))
          throw new Error(c('Bu dosya bir menü düzeni yedeği değil.'));
        if (Number(paket.surum) > AKTARIM_SURUM)
          throw new Error(c('Dosya daha yeni bir sürümden; önce uygulamayı güncelleyin.'));
        // BU KURULUMDA OLMAYAN EKRAN ATLANIR: başka kurulumda tanımlı bir
        //   ekranın satırını saklamak, menüyü sessizce bozmak olurdu. Kurumun
        //   kendi ürettiği düğümler (alt başlık / dış bağlantı) kodda
        //   karşılığı olmadığı için muaf.
        const gecerli: MenuDuzenSatiri[] = [];
        let atlanan = 0;
        for (const r of paket.satirlar as MenuDuzenSatiri[]) {
          if (!r || typeof r.sistemKod !== 'string' || r.dugumTur < 1 || r.dugumTur > 4) {
            atlanan += 1; continue;
          }
          if (r.dugumTur !== 3 && !dugumler.some(d => d.kod === r.sistemKod)) {
            atlanan += 1; continue;
          }
          gecerli.push({ ...r, gizli: r.gizli === 1 ? 1 : 0 });
        }
        setDuzen(gecerli);
        setMesaj(`${c('İçe aktarıldı')} · ${gecerli.length} ${c('satır')}`
          + (atlanan > 0 ? ` · ${atlanan} ${c('satır bu kurulumda yok, atlandı')}` : '')
          + ` · ${c('geçerli olması için Kaydet & Uygula')}`);
      } catch (h) {
        setMesaj(h instanceof Error ? h.message : c('Dosya okunamadı.'));
      }
    };
    oku.readAsText(dosya);
    if (aktarimGirdi.current) aktarimGirdi.current.value = '';
  };

  // Kaydetme fonksiyonu ebeveyne BİR KEZ verilir, içeriği ref'ten okunur.
  const kaydetRef = useRef(kaydet);
  kaydetRef.current = kaydet;
  useEffect(() => {
    if (!kaydetBagla) return;
    kaydetBagla(() => kaydetRef.current());
    return () => kaydetBagla(null);
  }, [kaydetBagla]);

  const sifirla = async () => {
    if (!subeId) return;
    try {
      await api.menuDuzenSifirla(subeId);
      setDuzen([]); setSunucudaki([]); setSubeyeOzel(0);
      setMesaj(c('Varsayılan düzene dönüldü.'));
    } catch (h) { setMesaj(hataMetni(h)) }
  };

  /** Aktiften PASİFE: panelin üstüne bırakılan düğüm gizlenir. */
  const pasifeBirak = () => {
    if (!surukle) return;
    const kaynak = dugumler.find(x => x.kod === surukle);
    setSurukle(null);
    if (!kaynak || !duzenleyebilir) return;
    if (gizliMi(kaynak)) return;              // zaten pasifte
    farkYaz(kaynak, { gizli: 1 });
    setMesaj(`${c('Pasife alındı')}: ${fark(kaynak.kod)?.gorunenAd || kaynak.ad}`);
  };

  /**
   * Sürükle-bırak: aynı üstteki kardeşler arasında SIRA değiştirir.
   * PASİFTEN GELEN düğüm ayrıca aktife alınır ve hedefin üst başlığına
   * taşınır - kullanıcı "yerine yerleştirsem kaydırarak" dediği için bırakılan
   * nokta hem görünürlüğü hem sırayı belirler.
   */
  const birak = (hedef: Dugum) => {
    if (!surukle || surukle === hedef.kod) { setSurukle(null); return }
    const kaynak = dugumler.find(x => x.kod === surukle);
    if (kaynak && gizliMi(kaynak) && kaynak.tur === hedef.tur) {
      setSurukle(null);
      // Önce aktife al ve hedefin üstüne taşı; sıra bir sonraki adımda
      //   kardeşler yeniden numaralanırken verilir.
      farkYaz(kaynak, { gizli: 0, ustKod: etkinUst(hedef) ?? '' });
      setMesaj(`${c('Aktife alındı')}: ${fark(kaynak.kod)?.gorunenAd || kaynak.ad}`);
      return;
    }
    setSurukle(null);
    if (!kaynak) return;

    // BAŞKA BAŞLIĞA SÜRÜKLEME (kullanıcı 07.10.2026: "grup ya da bölge
    //   taşıdığımda alt alanları ile birlikte taşınmalıdır"): eskiden yalnız
    //   kardeş sırası değişiyordu, başka bölgeye bırakmak uyarı veriyordu.
    //
    //   ALT ÖĞELER KENDİLİĞİNDEN GELİR: ekranın üstü GRUP kodudur, grubun üstü
    //   bölge adıdır - taşınan düğümün kodu değişmediği için zinciri koparan
    //   bir şey yok. Bu yüzden yalnız taşınan düğüme satır yazılır; alt
    //   satırlara yazmak, üstü geri taşındığında onları yerinde bırakırdı.
    const hedefUst = etkinUst(hedef);
    const yeniUst = kaynak.tur === hedef.tur ? hedefUst          // kardeş olarak araya gir
      : kaynak.tur === 'ekran' && hedef.tur === 'grup' ? hedef.kod   // grubun altına
      : kaynak.tur === 'grup' && hedef.tur === 'bolge' ? hedef.kod   // bölgenin altına
      : undefined;
    if (yeniUst === undefined && kaynak.tur !== hedef.tur) {
      setMesaj(c('Bu düğüm oraya taşınamaz: ekran bir gruba, grup bir bölgeye taşınır.'));
      return;
    }
    if (kaynak.tur !== hedef.tur) {
      farkYaz(kaynak, { ustKod: yeniUst ?? '' });
      setMesaj(`${fark(kaynak.kod)?.gorunenAd || kaynak.ad} → ${
        fark(hedef.kod)?.gorunenAd || hedef.ad}`);
      return;
    }
    // Aynı tür ama BAŞKA üst: önce taşı, sonra hedefin kardeşleri arasında
    //   sırala - bırakılan nokta sırayı da belirlesin.
    const tasiniyor = etkinUst(kaynak) !== hedefUst;
    if (tasiniyor) farkYaz(kaynak, { ustKod: hedefUst ?? '' });
    // KARDEŞ SIRASI YERLEŞİMDEN: koddaki dizi sırası değil, ekranda GÖRÜLEN
    //   sıra - yoksa bir kez sürükledikten sonraki her sürükleme eski sıraya
    //   göre hesaplanıp düğümü geri atardı.
    const kardes = yerlesim.map(({ d }) => d)
      .filter(x => x.tur === kaynak.tur
                   && (x.kod === kaynak.kod || etkinUst(x) === hedefUst));
    const sira = kardes.map(x => x.kod).filter(k => k !== kaynak.kod);
    const i = sira.indexOf(hedef.kod);
    sira.splice(i < 0 ? sira.length : i, 0, kaynak.kod);
    setDuzen(onceki => {
      let sonuc = [...onceki];
      sira.forEach((ic, indeks) => {
        const d = dugumler.find(x => x.kod === ic)!;
        const tur = turNo(d.tur);
        const kod = dbKod(ic);
        const mevcut = sonuc.find(x => x.sistemKod === kod && x.dugumTur === tur);
        const ustIc = ic === kaynak.kod ? hedefUst : (etkinUst(d) ?? undefined);
        const yeni: MenuDuzenSatiri = {
          dugumTur: tur,
          sistemKod: kod,
          gorunenAd: '', ikon: '', gizli: 0, acilistaAcik: 0,
          ...mevcut,
          // Taşınan düğümün üstü HEDEFİN üstüdür (mevcut kayıt eski üstü
          //   taşıyor olabilir: `...mevcut` onu geri yazardı).
          ustKod: ustIc != null ? dbKod(ustIc) : (ic === kaynak.kod ? '' : mevcut?.ustKod ?? null),
          sira: (indeks + 1) * 10,
        };
        sonuc = [...sonuc.filter(x => !(x.sistemKod === kod && x.dugumTur === tur)), yeni];
      });
      return sonuc;
    });
  };

  return (
    <div className="mn-ekran">
      <div className="mn-ust">
        {!gomulu && <>
          <h2>{c('Menü Düzeni')}</h2>
          <span className="sonuk">{c('Yönetim › Ayarlar › Menü Düzeni')}</span>
        </>}
        <span className="mn-bosluk" />
        <select className="mn-inp" value={subeId} onChange={e => setSubeId(Number(e.target.value))}>
          {(kullanici?.subeler ?? []).map(s => <option key={s.id} value={s.id}>{c(s.ad, 'kod')}</option>)}
        </select>
        <span className={`rozet ${subeyeOzel > 0 ? 'olumlu' : 'gri'}`}>
          {subeyeOzel > 0 ? `${c('şubeye özel')} · ${subeyeOzel}` : c('varsayılan düzen')}
        </span>
        {/* KAYDEDİLMEDİ ROZETİ: ekrandaki düzen henüz menüye uygulanmadı. */}
        {kirli && <span className="rozet uyari" title={c('Menüye uygulanması için kaydedin')}>
          {c('kaydedilmedi')}</span>}
        {/* GÖMÜLÜ MODDA KENDİ KAYDET'İ YOK: Kurum Profili'nin ana "Kaydet &
            Uygula" düğmesi menü düzenini de kaydeder. İki kaydet düğmesi,
            hangisinin neyi kaydettiği sorusunu doğuruyordu. "Varsayılana dön"
            de orada gereksiz: düzeni sıfırlamak ayrı ekrandan yapılır. */}
        {!gomulu && (
          <>
            <button type="button" className={`d birincil${kirli ? ' mn-bekleyen' : ''}`}
                    disabled={!duzenleyebilir}
                    onClick={() => void kaydet()}>💾 {c('Kaydet & Uygula')}</button>
            <button type="button" className="d" disabled={!duzenleyebilir || subeyeOzel === 0}
                    onClick={() => void sifirla()}>⤾ {c('Varsayılana dön')}</button>
          </>
        )}
        {/* AKTARIM: düzen JSON dosyası olarak alınır, başka şubeye / kuruluma
            yüklenir. İçe aktarım yalnız EKRANA yüklenir - geçerli olması için
            Kaydet & Uygula gerekir, yanlış dosya menüyü sessizce değiştirmesin. */}
        <button type="button" className="d" onClick={disaAktar}
                title={c('Düzeni JSON dosyası olarak indir')}>⬇ {c('Dışa aktar')}</button>
        <input ref={aktarimGirdi} type="file" accept="application/json,.json" hidden
               onChange={e => iceAktar(e.target.files?.[0])} />
        <button type="button" className="d" disabled={!duzenleyebilir}
                onClick={() => aktarimGirdi.current?.click()}
                title={c('JSON dosyasından yükle (Kaydet & Uygula ile geçerli olur)')}>
          ⬆ {c('İçe aktar')}</button>
      </div>

      {mesaj && <div className="mn-mesaj">{mesaj}</div>}
      {/* KURAL (kullanıcı 07.10.2026): gizlemek ERİŞİMİ DE KAPATIR - adresi
          bilen yetkili kullanıcı da açamaz (sunucu kapısı: liste ve kart uçları
          403 döner). Yetki kaydı silinmez: gizlilik kalkınca ekran eski
          yetkileriyle geri gelir. */}
      <div className="mn-uyari">{c('Gizlenen ekran menüde, Ctrl+K aramasında ve yetki '
        + 'matrisinde görünmez. Erişimi KAPATIR: adresi bilen yetkili kullanıcı da ekranı '
        + 'açamaz. Yetki kaydı silinmez - ekranı yeniden gösterince eski yetkileriyle döner.')}</div>

      <div className="mn-govde">
        {/* AĞAÇ */}
        <div className="mn-agac">
          <div className="mn-agac-bas">{c('Sürükleyerek sırala · göz ile gizle')}
            <span className="sonuk"> · {dugumler.length} {c('düğüm')}</span>
            <span className="mn-bosluk" />
            <button type="button" className="d mini" onClick={() => setAcik(
              Object.fromEntries(dugumler.filter(x => dugumler.some(y => etkinUst(y) === x.kod))
                                         .map(x => [x.kod, true])))}>⤢ {c('Tümünü aç')}</button>
            <button type="button" className="d mini" onClick={() => setAcik({})}>⤡ {c('Kapat')}</button>
          </div>
          {yukleniyor && <div className="sonuk" style={{ padding: 10 }}>{c('yükleniyor')}…</div>}
          {agacSatirlari.map(({ d, derinlik }) => {
            // Bu listede yalnız AKTİF düğümler var (gizliler pasif panelde),
            //   bu yüzden ayrı bir "gizli" durumu çizilmiyor.
            const f = fark(d.kod);
            return (
              <div key={d.kod}
                   className={`mn-dugum d${derinlik}${secili === d.kod ? ' sec' : ''}`
                              + `${surukle === d.kod ? ' surukle' : ''}`}
                   draggable={duzenleyebilir}
                   onDragStart={() => setSurukle(d.kod)}
                   onDragOver={e => e.preventDefault()}
                   onDrop={() => birak(d)}
                   onClick={() => setSecili(d.kod)}>
                <span className="tut">⠿</span>
                {dugumler.some(x => etkinUst(x) === d.kod) ? (
                  <button type="button" className="d mini mn-ok"
                          title={acikMi(d.kod) ? c('Kapat') : c('Aç')}
                          onClick={e => { e.stopPropagation(); ac(d.kod) }}>
                    {acikMi(d.kod) ? '▾' : '▸'}</button>
                ) : <span className="mn-ok-bos" />}
                {d.ikon && <span className="ikon">{d.ikon}</span>}
                <span className="ad">{f?.gorunenAd || d.ad}</span>
                <span className="sag">
                  <span className="rozet gri">{c(d.tur === 'bolge' ? 'bölge' : d.tur === 'grup' ? 'grup' : 'ekran')}</span>
                  {/* SAĞA OK = PASİFE AL (kullanıcı 07.10.2026: "aktif menüde göz
                      yerine sağa ok tuşu ikon yap"): aktif ağaçta yalnız görünen
                      düğümler var, düğmenin tek işi onları sağdaki pasif menüye
                      göndermek - göz ikonu iki yönlüydü ve bu panelde yönün
                      hangisi olduğu belirsizdi. */}
                  <button type="button" className="d mini mn-pasife"
                          disabled={!duzenleyebilir}
                          title={c('Pasif menüye al')}
                          onClick={e => { e.stopPropagation(); farkYaz(d, { gizli: 1 }) }}>
                    →</button>
                </span>
              </div>
            );
          })}
        </div>

        {/* ÖZELLİKLER */}
        <div className="mn-ozellik">
          {!seciliDugum ? (
            <div className="sonuk">{c('Düzenlemek için soldan bir düğüm seçin.')}</div>
          ) : (
            <>
              <h5>{c('Seçili düğüm')} · {c(seciliDugum.tur === 'bolge' ? 'bölge'
                : seciliDugum.tur === 'grup' ? 'grup' : 'ekran')}</h5>
              <div className="mn-izgara">
                <label className="mn-kutu"><span>{c('Sistem adı (değişmez)')}</span>
                  <div className="mn-inp pasif">{seciliDugum.sistemAd}</div></label>
                <label className="mn-kutu"><span>{c('Görünen ad')}</span>
                  <input className="mn-inp" disabled={!duzenleyebilir}
                         value={fark(seciliDugum.kod)?.gorunenAd ?? ''}
                         placeholder={seciliDugum.ad}
                         onChange={e => farkYaz(seciliDugum, { gorunenAd: e.target.value })} /></label>
                {/* İKON: emoji metni YA DA yüklenen görsel (980, kullanıcı
                    "ikon da yükleyebilirim"). Görsel seçilince 64x64 PNG'ye
                    küçültülüp `data:` URL olarak saklanır - ayrı dosya deposu
                    menüyü her çizimde bir sorgu daha pahalı yapardı. */}
                <label className="mn-kutu"><span>{c('İkon')}</span>
                  <div className="mn-ikon-satir">
                    {ikonGorsel ? (
                      <img src={ikonGorsel} alt="" className="mn-ikon-onizle" />
                    ) : (
                      <input className="mn-inp" disabled={!duzenleyebilir}
                             value={fark(seciliDugum.kod)?.ikon ?? ''}
                             placeholder={seciliDugum.ikon ?? '—'}
                             onChange={e => farkYaz(seciliDugum, { ikon: e.target.value })} />
                    )}
                    <input ref={dosyaGirdi} type="file" accept="image/*" hidden
                           onChange={e => ikonYukle(e.target.files?.[0])} />
                    <button type="button" className="d mini" disabled={!duzenleyebilir}
                            onClick={() => dosyaGirdi.current?.click()}
                            title={c('Görsel yükle (en çok 64 KB, 64x64 ölçülür)')}>⬆</button>
                    {(fark(seciliDugum.kod)?.ikon ?? '') !== '' && (
                      <button type="button" className="d mini" disabled={!duzenleyebilir}
                              onClick={() => farkYaz(seciliDugum, { ikon: '' })}
                              title={c('İkonu varsayılana döndür')}>↺</button>
                    )}
                  </div></label>
                {/* ÜST BAŞLIK DEĞİŞTİRİLEBİLİR (kullanıcı 06.10.2026): ekran başka
                    grubun, grup da başka bölgenin altına taşınabilir. Seçenekler
                    ağacın kendisinden gelir - elle kod yazdırmak, var olmayan bir
                    başlığa taşıyıp ekranı menüden düşürmek demekti.
                    "en üst" seçimi BOŞ DİZE gönderir ve aynen saklanır: `|| null`
                    yazıldığında kayıt boş sayılıp siliniyor, grup bölgesine geri
                    dönüyordu. */}
                <label className="mn-kutu"><span>{c('Üst başlık')}</span>
                  {ustSecenekleri(seciliDugum).length === 0 ? (
                    <div className="mn-inp pasif">{seciliDugum.ustKod ? c(seciliDugum.ustKod) : '—'}</div>
                  ) : (
                    <select className="mn-inp" disabled={!duzenleyebilir}
                            // DEĞER DE İÇ KOD (07.10.2026 hatası): seçenekler iç
                            //   kod (`b|Yönetim`), değer ise veritabanı kodu
                            //   (`Yönetim`) olarak veriliyordu; eşleşmeyince
                            //   tarayıcı ilk seçeneği ("en üst") gösteriyor ve
                            //   grup bölge altındayken kök gibi görünüyordu.
                            value={etkinUst(seciliDugum) ?? ''}
                            onChange={e => farkYaz(seciliDugum, { ustKod: e.target.value })}>
                      {ustSecenekleri(seciliDugum).map(u => (
                        <option key={u || '-kok-'} value={u}>
                          {/* ETİKET VERİTABANI KODU: değer iç kod (`b|Yönetim`)
                              ama kullanıcı "b|" önekini görmemeli. */}
                          {u === '' ? `— ${c('en üst')} —` : c(dbKod(u))}</option>
                      ))}
                    </select>
                  )}</label>
                <label className="mn-kutu"><span>{c('Sıra')}</span>
                  {/* SIRA ELLE DE GİRİLİR: sürüklemek bitişik taşımak için iyi,
                      "en sona al" için on kez sürüklemek gerekiyordu. Boş = varsayılan. */}
                  <input className="mn-inp" type="number" disabled={!duzenleyebilir}
                         value={fark(seciliDugum.kod)?.sira ?? ''}
                         placeholder={c('varsayılan')}
                         onChange={e => farkYaz(seciliDugum,
                           { sira: e.target.value === '' ? null : Number(e.target.value) })} /></label>
                <label className="mn-kutu"><span>{c('Derinlik')}</span>
                  <div className="mn-inp pasif">{seciliDugum.derinlik}</div></label>
                <label className="mn-kutu"><span>{c('Durum')}</span>
                  <select className="mn-inp"
                          disabled={!duzenleyebilir || (fark(seciliDugum.kod)?.gizli !== 1 && ustGizli(seciliDugum))}
                          value={fark(seciliDugum.kod)?.gizli === 1 ? '1' : '0'}
                          onChange={e => farkYaz(seciliDugum, { gizli: Number(e.target.value) })}>
                    <option value="0">{c('Görünür')}</option>
                    <option value="1">{c('Gizli')}</option>
                  </select></label>
                {/* HANGİ MODÜLE AİT (kullanıcı 07.10.2026: "eğer önemliyse hangi
                    modüle ait olduğunu gösteren bir alan ekle"): paylaşılan
                    ekranlarda - Dökümler, Ayarlar - başlığın hangi veriyi
                    açtığı yalnız bu iki alandan anlaşılır. */}
                {seciliDugum.tur === 'ekran' && (
                  <label className="mn-kutu"><span>{c('Modül')}</span>
                    <div className="mn-inp pasif">{seciliDugum.modul
                      ? c(seciliDugum.modul, 'kod') : c('modülsüz (her kurulumda)')}</div></label>
                )}
                {seciliDugum.suzgec && (
                  <label className="mn-kutu"><span>{c('Veri süzgeci')}</span>
                    <div className="mn-inp pasif" title={c('Bu başlık taşındığında süzgeç de '
                      + 'yeni grubuna çevrilir')}>{c('grup')} = {c(seciliDugum.suzgec)}</div></label>
                )}
                {seciliDugum.yol && (
                  <label className="mn-kutu"><span>{c('Rota')}</span>
                    <div className="mn-inp pasif">{seciliDugum.yol}</div></label>
                )}
              </div>
              <div className="mn-bilgi">{c('Sistem adı değişmez: rota, yetki ve kod eşlemesi ona bağlıdır. '
                + 'Değiştirilen yalnız görünen addır. Sıra sürükleyerek değişir; boş bırakılan alan '
                + 'varsayılana döner ve kayıttan düşer.')}</div>
            </>
          )}
        </div>

        {/* PASİF MENÜ: aktif menüden çıkarılanlar. Panelin ÜSTÜNE bırakmak
            gizler, oradan sol ağaçtaki bir satırın üstüne bırakmak geri alır
            ve o sıraya yerleştirir. Sol menünün görünümünde çizilir -
            kullanıcı aynı menüyü iki kutuda görsün. */}
        <div className={`mn-onizle${surukle ? ' mn-hedef' : ''}`}
             onDragOver={e => { if (surukle) e.preventDefault() }}
             onDrop={() => pasifeBirak()}>
          <div className="mn-onizle-bas">{c('Pasif menü')}
            <span className="sonuk"> · {pasifSatirlari.length}</span>
          </div>
          {pasifSatirlari.length === 0 && (
            <div className="mn-pasif-bos">
              {c('Kullanmadığınız başlıkları buraya sürükleyin.')}
            </div>
          )}
          {pasifGorunur.map(({ d, derinlik, baslik }) => {
            const ad = fark(d.kod)?.gorunenAd || d.ad;
            const ik = fark(d.kod)?.ikon || d.ikon;
            // Üstü gizli olan satır KENDİ başına geri alınamaz: önce üst
            //   başlığı aktife taşınmalı, yoksa menüde yeri olmayan bir ekran
            //   "aktif" sayılırdı.
            // `baslik` = düğümün kendisi AKTİF, burada yalnız yer göstergesi.
            const mirasla = !baslik && fark(d.kod)?.gizli !== 1;
            const cocukVar = pasifSatirlari.some(x => etkinUst(x.d) === d.kod);
            const tasinabilir = duzenleyebilir && !mirasla && !baslik;
            return (
              <div key={`p-${d.kod}`}
                   className={`mn-oge d${derinlik}${mirasla ? ' mn-miras' : ''}`
                              + `${baslik ? ' mn-yer' : ''}`}
                   draggable={tasinabilir}
                   onDragStart={() => setSurukle(d.kod)}
                   title={baslik ? c('Bu başlık aktif menüde - burada yalnız yerini gösterir')
                          : mirasla ? c('Üst başlığı pasifte - önce onu aktife taşıyın')
                                    : c('Aktif menüdeki yerine sürükleyin')}>
                {/* BÖLGE VE GRUPLAR AÇILIR-KAPANIR (kullanıcı 07.10.2026):
                    pasife alınan bir bölge altındaki her şeyi getiriyor
                    (onlarca satır); kapalı başlık listeyi okunur tutuyor. */}
                {cocukVar ? (
                  <button type="button" className="d mini mn-ok"
                          title={pasifAcikMi(d.kod) ? c('Kapat') : c('Aç')}
                          onClick={e => { e.stopPropagation(); pasifAc(d.kod) }}>
                    {pasifAcikMi(d.kod) ? '▾' : '▸'}</button>
                ) : <span className="mn-ok-bos" />}
                {tasinabilir && <span className="tut">⠿</span>}
                {ik && (ik.startsWith('data:image/')
                  ? <img src={ik} alt="" className="ic-gorsel" />
                  : <span>{ik}</span>)} {ad}
                {!mirasla && !baslik && (
                  <button type="button" className="d mini mn-geri"
                          disabled={!duzenleyebilir}
                          title={c('Aktif menüye al')}
                          onClick={() => farkYaz(d, { gizli: 0 })}>←</button>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
