import { useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';
import { Modal } from '../bilesenler/Modal';
import { LISTELER } from './Liste';
import { MenuIkon, menuSatirlariKur, GRUP_IKON, GRUP_IKON_CEV, type MenuSatiri } from './kabuk/menuAgaci';
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
 * KUTU GÖRÜNÜMÜ (kullanıcı 17.10.2026: "genprofil'deki menü düzenini admin home sayfasındaki kutucuklar
 * gibi yap; grup ve satır başlarına check koy; check olanlar o profilde görünecek ve yetki matrisine
 * girecek; grup başı işaretlenince alt satırlar da aynı şekilde işaretlenir; satır tıklanınca özellik
 * modalı açılır - adı, ikonu, grubu vb. değişip kaydedilebilir"). Eski ağaç + pasif menü + sürükle-bırak
 * görünümünün yerini aldı; kayıt modeli (fark satırları, `gizli`, sıra, üst başlık) aynı.
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
  /** Menüdeki alt başlık (ör. Ayarlar) - kutuda okla açılan alt grup (17.10.2026). */
  altGrup?: string;
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
  /** Özellik penceresi açık düğüm (iç kod). */
  const [secili, setSecili] = useState<string | null>(null);
  /** Açık alt gruplar ("grup iç kodu/alt başlık"); varsayılan kapalı. */
  const [acikAlt, setAcikAlt] = useState<Set<string>>(new Set());
  /** Sürüklenen satır ve grubu - yalnız AYNI grup içinde yer değiştirir (17.10.2026). */
  const [surukle, setSurukle] = useState<{ kod: string; grup: string } | null>(null);
  /** Sürüklenen GRUP (kutu başlığından) - gruplar kendi aralarında yer değiştirir (17.10.2026). */
  const [surukleGrup, setSurukleGrup] = useState<string | null>(null);
  const dosyaGirdi = useRef<HTMLInputElement>(null);
  const aktarimGirdi = useRef<HTMLInputElement>(null);
  /** Sunucudaki hal: kaydedilmemiş değişiklik var mı, buradan anlaşılır. */
  const [sunucudaki, setSunucudaki] = useState<MenuDuzenSatiri[]>([]);
  const [mesaj, setMesaj] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  // Varsayılan ağaç: menüyü çizen AYNI kuruluş (menuSatirlariKur) - ekranda
  //   başka bir sıralama göstermek, kaydedilen düzenin menüde farklı çıkması
  //   demekti.
  const satirlar: MenuSatiri[] = useMemo(
    () => menuSatirlariKur(LISTELER, yetki, kullanici?.urunModu, kullanici?.moduller),
    [yetki, kullanici?.urunModu, kullanici?.moduller]);

  /** Ağacı düz listeye açar: grup › ekran (mockup soldaki ağaç). BÖLGELER KALDIRILDI (17.10.2026):
   *  menü tek seviye grup - bu editör GenProfil'de de aynı bileşenle açılır. */
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
          ikon: m.ic, ustKod: ic, derinlik: ustIc ? 3 : 2, yol: m.yol, altGrup: m.altGrup,
        });
    };

    for (const sat of gruplar) grupEkle(sat);
    for (const s of duzOgeler)
      d.push({
        tur: 'ekran',
        kod: icKod('ekran', benzersiz(ogeKoduBaglamli(s.m, undefined, cakisan))),
        sistemAd: s.m.adHam ?? s.m.ad, ad: s.m.ad,
        modul: s.m.modul, suzgec: suzgecCoz(s.m.yol),
        ikon: s.m.ic, derinlik: 1, yol: s.m.yol,
      });
    return d;
  }, [satirlar]);

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
   * Düğümün taşınabileceği üst başlıklar: ekran GRUPLARA taşınır. Grubun üstü yoktur (bölgeler
   * kaldırıldı) - liste boş döner ve alan salt okunur kalır.
   */
  const ustSecenekleri = (dugum: Dugum): string[] => {
    if (dugum.tur === 'ekran')
      return dugumler.filter(x => x.tur === 'grup').map(x => x.kod);
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

  /**
   * GRUP VE SATIR İŞARETİ = GÖRÜNÜRLÜK (`gizli`). İşaretli olan profilde görünür ve yetki matrisine girer.
   * GRUP BAŞI bütün alt satırlara AYNI değeri yazar; grup kapalıyken bir satır işaretlenirse grup da açılır
   * (öteki satırlar kendi işaretinde kalır).
   */
  const grupCocuklari = (g: Dugum) => yerlesim.map(x => x.d).filter(x => etkinUst(x) === g.kod);
  const grupIsaretle = (g: Dugum, gorunur: boolean) => {
    farkYaz(g, { gizli: gorunur ? 0 : 1 });
    for (const ch of grupCocuklari(g)) farkYaz(ch, { gizli: gorunur ? 0 : 1 });
  };
  const satirIsaretle = (s: Dugum, gorunur: boolean) => {
    farkYaz(s, { gizli: gorunur ? 0 : 1 });
    const ustKod = etkinUst(s);
    const ust = ustKod ? dugumler.find(x => x.kod === ustKod) : undefined;
    if (gorunur && ust && fark(ust.kod)?.gizli === 1) {
      farkYaz(ust, { gizli: 0 });
      // Grup açılınca diğer satırlar kendi işaretini korusun: işaretsiz kalanlara açık "gizli" yazılır.
      for (const ch of grupCocuklari(ust))
        if (ch.kod !== s.kod && fark(ch.kod)?.gizli !== 0) farkYaz(ch, { gizli: 1 });
    }
  };
  /**
   * GRUP İÇİ SÜRÜKLE-BIRAK (kullanıcı 17.10.2026: "menüler kendi grup içinde sürükle bırak ile yer
   * değişebilir olsun"): kaynak hedefin önüne girer, grubun bütün satırlarına yeni sıra (10, 20...) yazılır.
   */
  /** `kaynak` tek satır ya da ALT GRUP BLOĞU (`alt:<ad>` - altındaki satırlar birlikte taşınır);
   *  `hedef` satır kodu ya da `alt:<ad>` (o alt grubun ilk satırının önü). */
  const siraDegis = (g: Dugum, kaynak: string, hedef: string) => {
    if (kaynak === hedef) return;
    const cocuk = grupCocuklari(g);
    const coz = (k: string) => k.startsWith('alt:')
      ? cocuk.filter(x => x.altGrup === k.slice(4)).map(x => x.kod) : [k];
    const tasinan = coz(kaynak);
    const hedefIlk = coz(hedef)[0];
    if (!hedefIlk || tasinan.includes(hedefIlk)) return;
    const sira = cocuk.map(x => x.kod).filter(k => !tasinan.includes(k));
    const i = sira.indexOf(hedefIlk);
    sira.splice(i < 0 ? sira.length : i, 0, ...tasinan);
    sira.forEach((k, n) => { const dd = dugumler.find(x => x.kod === k); if (dd) farkYaz(dd, { sira: (n + 1) * 10 }) });
  };
  /** GRUP SÜRÜKLE-BIRAK: kaynak grup hedefin önüne girer, bütün gruplara yeni sıra yazılır. */
  const grupSiraDegis = (kaynakKod: string, hedefKod: string) => {
    if (kaynakKod === hedefKod) return;
    const sira = yerlesim.filter(x => x.derinlik === 1 && x.d.tur === 'grup').map(x => x.d.kod)
      .filter(k => k !== kaynakKod);
    const i = sira.indexOf(hedefKod);
    sira.splice(i < 0 ? sira.length : i, 0, kaynakKod);
    sira.forEach((k, n) => { const dd = dugumler.find(x => x.kod === k); if (dd) farkYaz(dd, { sira: (n + 1) * 10 }) });
  };
  /** Kutular: gruplar sırasıyla; grupsuz (düz) ekranlar en sonda "Diğer" kutusunda. */
  const kutular = useMemo(() => {
    const kok = yerlesim.filter(x => x.derinlik === 1).map(x => x.d);
    const gruplar = kok.filter(x => x.tur === 'grup')
      .map(g => ({ g, satirlar: yerlesim.map(x => x.d).filter(x => etkinUst(x) === g.kod) }));
    const duzler = kok.filter(x => x.tur === 'ekran');
    return { gruplar, duzler };
  }, [yerlesim, duzen]);

  /**
   * AKTİF / PASİF GRUPLAR (kullanıcı 17.10.2026: "kaydet yapıldığında bir grup tümüyle pasifse alt bölgeye
   * kaysın, grup içinden en az 1 menü aktifse üst bölgeye geçsin"). Bölüm KAYDEDİLMİŞ duruma göre
   * belirlenir (yükleme ve Kaydet anında) - düzenlerken kutular yer değiştirmez.
   */
  const [pasifGruplar, setPasifGruplar] = useState<Set<string>>(new Set());
  useEffect(() => {
    setPasifGruplar(new Set(kutular.gruplar
      .filter(({ g, satirlar: s }) => gizliMi(g) || (s.length > 0 && s.every(x => gizliMi(x))))
      .map(x => x.g.kod)));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sunucudaki, dugumler]);

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

      {yukleniyor && <div className="sonuk" style={{ padding: 10 }}>{c('yükleniyor')}…</div>}
      {/* KUTULAR (ana sayfa düzeni): her grup bir kutu; başlıkta ve satırlarda işaret. */}
      {(() => {
      const grupKutusu = ({ g, satirlar: sat }: { g: Dugum; satirlar: Dugum[] }) => {
          const gGorunur = !gizliMi(g);
          const isaretli = sat.filter(s => !gizliMi(s)).length;
          return (
            <div key={g.kod} className={`mn-kutu-grup${gGorunur ? '' : ' kapali'}${surukleGrup === g.kod ? ' surukle' : ''}`}
                 onDragOver={ev => { if (surukleGrup) ev.preventDefault() }}
                 onDrop={() => { if (surukleGrup) grupSiraDegis(surukleGrup, g.kod); setSurukleGrup(null) }}>
              <div className="mn-kb" draggable={duzenleyebilir}
                   onDragStart={ev => { ev.stopPropagation(); setSurukleGrup(g.kod) }}
                   onDragEnd={() => setSurukleGrup(null)}
                   title={duzenleyebilir ? c('Başlıktan sürükleyerek grubun yerini değiştir') : undefined}>
                {duzenleyebilir && <span className="mn-tut">⠿</span>}
                <input type="checkbox" checked={gGorunur} disabled={!duzenleyebilir}
                       ref={el => { if (el) el.indeterminate = gGorunur && isaretli > 0 && isaretli < sat.length }}
                       title={c('Grubu ve bütün satırlarını profilde göster / gizle')}
                       onChange={e => grupIsaretle(g, e.target.checked)} />
                <button type="button" className="mn-ad" onClick={() => setSecili(g.kod)} title={c('Özellikler')}>
                  <MenuIkon ic={fark(g.kod)?.ikon || g.ikon || GRUP_IKON[g.sistemAd] || GRUP_IKON_CEV[g.ad] || '📁'} /> {fark(g.kod)?.gorunenAd || g.ad}
                </button>
                <span className="rozet gri">{isaretli}/{sat.length}</span>
              </div>
              <div className="mn-satirlar">
                {(() => {
                  const satirCiz = (s: Dugum, alt = false) => {
                    const gorunur = !gizliMi(s);
                    return (
                      <div key={s.kod}
                           className={`mn-sat${gorunur ? '' : ' kapali'}${alt ? ' alt' : ''}${surukle?.kod === s.kod ? ' surukle' : ''}`}
                           draggable={duzenleyebilir}
                           onDragStart={() => setSurukle({ kod: s.kod, grup: g.kod })}
                           onDragEnd={() => setSurukle(null)}
                           onDragOver={ev => { if (surukle?.grup === g.kod) ev.preventDefault() }}
                           onDrop={() => { if (surukle?.grup === g.kod) siraDegis(g, surukle.kod, s.kod); setSurukle(null) }}
                           title={duzenleyebilir ? c('Sürükleyerek grup içinde sırala') : undefined}>
                        {duzenleyebilir && <span className="mn-tut">⠿</span>}
                        <input type="checkbox" checked={gorunur} disabled={!duzenleyebilir}
                               onChange={e => satirIsaretle(s, e.target.checked)} />
                        <button type="button" className="mn-ad" onClick={() => setSecili(s.kod)} title={c('Özellikler')}>
                          <MenuIkon ic={fark(s.kod)?.ikon || s.ikon || '•'} /> {fark(s.kod)?.gorunenAd || s.ad}
                          {s.suzgec && <span className="sonuk"> · {c(s.suzgec)}</span>}
                        </button>
                      </div>
                    );
                  };
                  // ALT GRUPLAR (kullanıcı 17.10.2026: "alt grup varsa ok ile açılır kapanır, default kapalı"):
                  //   menüdeki gibi ilk göründüğü yerde tek başlık; başlık işareti altındakileri birlikte işaretler.
                  const sira: (Dugum | string)[] = [];
                  const altlar = new Map<string, Dugum[]>();
                  for (const s of sat) {
                    if (!s.altGrup) { sira.push(s); continue }
                    if (!altlar.has(s.altGrup)) { altlar.set(s.altGrup, []); sira.push(s.altGrup) }
                    altlar.get(s.altGrup)!.push(s);
                  }
                  return sira.map(x => {
                    if (typeof x !== 'string') return satirCiz(x);
                    const liste = altlar.get(x)!, anahtar = `${g.kod}/${x}`, acik = acikAlt.has(anahtar);
                    const isa = liste.filter(s => !gizliMi(s)).length;
                    return (
                      <div key={`a-${x}`}>
                        <div className={`mn-sat${surukle?.kod === `alt:${x}` ? ' surukle' : ''}`}
                             draggable={duzenleyebilir}
                             onDragStart={() => setSurukle({ kod: `alt:${x}`, grup: g.kod })}
                             onDragEnd={() => setSurukle(null)}
                             onDragOver={ev => { if (surukle?.grup === g.kod) ev.preventDefault() }}
                             onDrop={() => { if (surukle?.grup === g.kod) siraDegis(g, surukle.kod, `alt:${x}`); setSurukle(null) }}
                             title={duzenleyebilir ? c('Sürükleyerek alt grubu (altındakilerle) sırala') : undefined}>
                          {duzenleyebilir && <span className="mn-tut">⠿</span>}
                          <input type="checkbox" checked={isa > 0} disabled={!duzenleyebilir}
                                 ref={el => { if (el) el.indeterminate = isa > 0 && isa < liste.length }}
                                 onChange={e => { for (const s of liste) satirIsaretle(s, e.target.checked) }} />
                          <button type="button" className="mn-ad"
                                  onClick={() => setAcikAlt(o => { const y = new Set(o); if (acik) y.delete(anahtar); else y.add(anahtar); return y })}>
                            <span className="ic">{acik ? '▾' : '▸'}</span> {c(x)} <span className="sonuk">({isa}/{liste.length})</span>
                          </button>
                        </div>
                        {acik && liste.map(s => satirCiz(s, true))}
                      </div>
                    );
                  });
                })()}
              </div>
            </div>
          );
        };
      const aktif = kutular.gruplar.filter(x => !pasifGruplar.has(x.g.kod));
      const pasif = kutular.gruplar.filter(x => pasifGruplar.has(x.g.kod));
      return (<>
      <div className="mn-bolum-bas">{c('AKTİF GRUPLAR')} <span className="sonuk">· {aktif.length}</span></div>
      <div className="mn-kutular">
        {aktif.map(grupKutusu)}
        {kutular.duzler.length > 0 && (
          <div className="mn-kutu-grup">
            <div className="mn-kb"><span className="mn-ad">📁 {c('Diğer')}</span></div>
            <div className="mn-satirlar">
              {kutular.duzler.map(s => (
                <div key={s.kod} className={`mn-sat${gizliMi(s) ? ' kapali' : ''}`}>
                  <input type="checkbox" checked={!gizliMi(s)} disabled={!duzenleyebilir}
                         onChange={e => satirIsaretle(s, e.target.checked)} />
                  <button type="button" className="mn-ad" onClick={() => setSecili(s.kod)}>
                    <MenuIkon ic={fark(s.kod)?.ikon || s.ikon || '•'} /> {fark(s.kod)?.gorunenAd || s.ad}
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
      <div className="mn-bolum-bas pasif">{c('PASİF GRUPLAR')} <span className="sonuk">· {pasif.length}</span></div>
      {pasif.length > 0
        ? <div className="mn-kutular">{pasif.map(grupKutusu)}</div>
        : <div className="sonuk" style={{ padding: '6px 2px' }}>{c('Tümüyle pasif grup yok. Bütün menüleri kapatılan grup kaydedilince buraya iner.')}</div>}
      </>);
      })()}

      {/* ÖZELLİK PENCERESİ: satır ya da grup adına tıklanınca. Değişiklik ekranda birikir; menüye
          Kaydet & Uygula (gömülüde Kurum Profili'nin Kaydet'i) ile geçer. */}
      {seciliDugum && (
        <Modal baslik={`${c(seciliDugum.tur === 'grup' ? 'Grup' : 'Ekran')} · ${fark(seciliDugum.kod)?.gorunenAd || seciliDugum.ad}`}
               dar enUst buyutmeYok onKapat={() => setSecili(null)}
               alt={<button type="button" className="d bir" onClick={() => setSecili(null)}>✔ {c('Tamam')}</button>}>
          <div className="mn-izgara">
            <label className="mn-kutu"><span>{c('Sistem adı (değişmez)')}</span>
              <div className="mn-inp pasif">{seciliDugum.sistemAd}</div></label>
            <label className="mn-kutu"><span>{c('Görünen ad')}</span>
              <input className="mn-inp" disabled={!duzenleyebilir}
                     value={fark(seciliDugum.kod)?.gorunenAd ?? ''}
                     placeholder={seciliDugum.ad}
                     onChange={e => farkYaz(seciliDugum, { gorunenAd: e.target.value })} /></label>
            {/* İKON: emoji metni YA DA yüklenen görsel (980) - 64x64 PNG'ye küçültülüp `data:` URL. */}
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
            {/* GRUBU: ekran başka gruba taşınabilir - seçenekler ağacın kendisinden. */}
            <label className="mn-kutu"><span>{c('Grubu')}</span>
              {ustSecenekleri(seciliDugum).length === 0 ? (
                <div className="mn-inp pasif">{seciliDugum.ustKod ? c(dbKod(seciliDugum.ustKod)) : '—'}</div>
              ) : (
                <select className="mn-inp" disabled={!duzenleyebilir}
                        value={etkinUst(seciliDugum) ?? ''}
                        onChange={e => farkYaz(seciliDugum, { ustKod: e.target.value })}>
                  {ustSecenekleri(seciliDugum).map(u => (
                    <option key={u || '-kok-'} value={u}>{u === '' ? `— ${c('en üst')} —` : c(dbKod(u))}</option>
                  ))}
                </select>
              )}</label>
            <label className="mn-kutu"><span>{c('Sıra')}</span>
              <input className="mn-inp" type="number" disabled={!duzenleyebilir}
                     value={fark(seciliDugum.kod)?.sira ?? ''}
                     placeholder={c('varsayılan')}
                     onChange={e => farkYaz(seciliDugum,
                       { sira: e.target.value === '' ? null : Number(e.target.value) })} /></label>
            <label className="mn-kutu"><span>{c('Durum')}</span>
              <select className="mn-inp" disabled={!duzenleyebilir}
                      value={gizliMi(seciliDugum) ? '1' : '0'}
                      onChange={e => seciliDugum.tur === 'grup'
                        ? grupIsaretle(seciliDugum, e.target.value === '0')
                        : satirIsaretle(seciliDugum, e.target.value === '0')}>
                <option value="0">{c('Görünür')}</option>
                <option value="1">{c('Gizli')}</option>
              </select></label>
            {seciliDugum.tur === 'ekran' && (
              <label className="mn-kutu"><span>{c('Modül')}</span>
                <div className="mn-inp pasif">{seciliDugum.modul
                  ? c(seciliDugum.modul, 'kod') : c('modülsüz (her kurulumda)')}</div></label>
            )}
            {seciliDugum.suzgec && (
              <label className="mn-kutu"><span>{c('Veri süzgeci')}</span>
                <div className="mn-inp pasif">{c('grup')} = {c(seciliDugum.suzgec)}</div></label>
            )}
            {seciliDugum.yol && (
              <label className="mn-kutu"><span>{c('Rota')}</span>
                <div className="mn-inp pasif">{seciliDugum.yol}</div></label>
            )}
          </div>
          <div className="mn-bilgi">{c('Sistem adı değişmez: rota, yetki ve kod eşlemesi ona bağlıdır. '
            + 'Boş bırakılan alan varsayılana döner. Değişiklik Kaydet & Uygula ile menüye geçer.')}</div>
        </Modal>
      )}
    </div>
  );
}
