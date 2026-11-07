import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import { type CariYon, type KasaArac, KASA_ARACLARI, type SeciliCari, cariIslemHedefi } from './cariKomutu';
import { paletSadelestir } from './paletMetin';

/**
 * REZERVE KELİMELER (kullanıcı 06.11.2026, mockup Ekranlar/AI/ai_rezerve_kelimeler.html): "tahsilat", "sipariş",
 * "fatura kes", "ödeme"… yazılınca palet ekran eşleşmesinin ÜSTÜNE iş seçeneklerini koyar (Yeni tahsilat · Kayıtlı
 * tahsilat kartı · Tahsilat / Ödeme İcmali…). Kullanıcı: "prompt'u basit tutalım - palette yalnız 1. aşama".
 *
 *   1. palet: iş seçenekleri (bu dosya)                       -> "Yeni tahsilat" seçilir
 *   1b. HBYS: palette KİMDEN (hasta / anlaşmalı kurum / diğer cari; kullanıcı 06.11.2026 "1. ve 2. aşama prompt ile")
 *   2. palet kapanır, jenerik taraf arama penceresi (Kabuk)  -> cari / hasta / kurum seçilir
 *   3. TÜR MODALI (Kabuk, sekme açılmadan)                     -> nakit / havale / POS / çek / senet / plan
 *   4. kart kendi sekmesinde ön dolu açılır, kayıt kartın Kaydet'iyle
 * Her aşamada Esc / Kapat / Vazgeç akışı iptal eder (kullanıcı).
 *
 * Ön dolum: tutar = cümlede yazılan ("5000 tahsilat"), yoksa ERP kuralı carinin açık borcu (bakiye > 0; ödemede
 * alacağı). Cümlede araç varsa ("nakit tahsilat") tür modalı atlanır. Seçenekler yalnız MENÜDE olan ekranlara çizilir
 * (yetki = menü, 1003). Sözlük şimdilik istemcide (ilk küme).
 */
export type NiyetKelime = 'tahsilat' | 'odeme' | 'siparis' | 'fatura' | 'irsaliye' | 'stok' | 'musteri' | 'tedarikci';
export type AkisIslem = 'tahsilat' | 'odeme' | 'plan' | 'siparis' | 'fatura' | 'irsaliye';
/** Plan (Kasa listesi "📅 Plan"): cari seçildikten sonra tür modalı tahsilat planı (61) / ödeme planı (71) sorar. */
export const PLAN_TURLERI = [
  { tur: 61, ad: 'Tahsilat Planı', ikon: '🗓️' },
  { tur: 71, ad: 'Ödeme Planı', ikon: '🗓️' },
];
/** Arama penceresinin kaynağı: cari (müşteri / tedarikçi), hasta (HBYS: açık başvurusu), anlaşmalı kurum. */
export type Kimden = 'cari' | 'hasta' | 'kurum';

/** `kimden` verilmezse palet sorar (HBYS "Yeni tahsilat"). */
export interface AkisTanimi { islem: AkisIslem; kimden?: Kimden; yon?: CariYon }

/** Palet 1b aşaması (HBYS): kimden - alt alta. */
export const KIMDEN_SECENEKLERI: { kod: Kimden; ad: string; ikon: string; aciklama: string }[] = [
  { kod: 'hasta', ad: 'Hasta', ikon: '🧑', aciklama: 'açık başvurunun hasta payı' },
  { kod: 'kurum', ad: 'Anlaşmalı kurum', ikon: '🏛️', aciklama: 'kurum faturası / hakediş' },
  { kod: 'cari', ad: 'Diğer cari', ikon: '👥', aciklama: 'müşteri / firma' },
];
export interface NiyetSecenek {
  kod: string; ad: string; ikon: string;
  /** Menüde olması gereken liste rotası (yoksa seçenek çizilmez). */
  liste: string;
  /** Doğrudan gidilecek yol (akışsız seçenek). */
  yol?: string;
  /** "Yeni …": arama penceresi + kart. */
  akis?: AkisTanimi;
}
export interface NiyetTanimi {
  kelime: NiyetKelime;
  /** Sadeleştirilmiş eş anlamlılar (tek ya da iki sözcük). */
  esAnlam: string[];
  secenekler: NiyetSecenek[];
  /** HBYS'de (ürün modu 2) seçenekler farklıysa. */
  hbys?: NiyetSecenek[];
}

const KASA_LISTE = '/kasa-islem';
const ICMAL = '/tahsilat-odeme-icmali';

export const NIYETLER: NiyetTanimi[] = [
  {
    kelime: 'tahsilat', esAnlam: ['tahsilat', 'tahsil', 'tahsil et', 'para al', 'makbuz', 'tahsilat al'],
    secenekler: [
      { kod: 'yeni', ad: 'Yeni tahsilat', ikon: '💵', liste: KASA_LISTE, akis: { islem: 'tahsilat', kimden: 'cari' } },
      { kod: 'kayitli', ad: 'Kayıtlı tahsilat kartı', ikon: '📂', liste: KASA_LISTE, yol: KASA_LISTE },
      { kod: 'icmal', ad: 'Tahsilat / Ödeme İcmali', ikon: '📊', liste: ICMAL, yol: ICMAL },
    ],
    // HBYS (kullanıcı 06.11.2026: "tahsilat yazılırsa hasta / dış kurum / sigorta önce bilinmeli"): kimden, seçenek satırı.
    hbys: [
      { kod: 'yeni', ad: 'Yeni tahsilat', ikon: '💵', liste: KASA_LISTE, akis: { islem: 'tahsilat' } },
      { kod: 'banko', ad: 'Banko oturumu', ikon: '🏦', liste: '/banko-oturum', yol: '/banko-oturum' },
      { kod: 'kayitli', ad: 'Kayıtlı tahsilat kartı', ikon: '📂', liste: KASA_LISTE, yol: KASA_LISTE },
      { kod: 'icmal', ad: 'Tahsilat / Ödeme İcmali', ikon: '📊', liste: ICMAL, yol: ICMAL },
    ],
  },
  {
    kelime: 'odeme', esAnlam: ['odeme', 'ode', 'odeme yap', 'tediye'],
    secenekler: [
      { kod: 'yeni', ad: 'Yeni ödeme', ikon: '💸', liste: KASA_LISTE, akis: { islem: 'odeme', kimden: 'cari' } },
      { kod: 'kayitli', ad: 'Kayıtlı ödeme kartı', ikon: '📂', liste: KASA_LISTE, yol: KASA_LISTE },
      { kod: 'icmal', ad: 'Tahsilat / Ödeme İcmali', ikon: '📊', liste: ICMAL, yol: ICMAL },
      { kod: 'vade', ad: 'Vadesi gelen ödemeler', ikon: '📅', liste: '/plan-vade', yol: '/plan-vade' },
    ],
  },
  {
    kelime: 'siparis', esAnlam: ['siparis', 'sip', 'yeni siparis', 'siparis ac', 'siparis al'],
    secenekler: [
      { kod: 'satis', ad: 'Yeni satış siparişi', ikon: '📋', liste: '/siparis', akis: { islem: 'siparis', kimden: 'cari', yon: 'satis' } },
      { kod: 'alis', ad: 'Yeni alış siparişi', ikon: '📋', liste: '/alis-siparis', akis: { islem: 'siparis', kimden: 'cari', yon: 'alis' } },
      { kod: 'satis-liste', ad: 'Satış Siparişi Listesi', ikon: '📋', liste: '/siparis', yol: '/siparis' },
      { kod: 'alis-liste', ad: 'Alış Siparişi Listesi', ikon: '📋', liste: '/alis-siparis', yol: '/alis-siparis' },
    ],
  },
  {
    kelime: 'fatura', esAnlam: ['fatura', 'fat', 'fatura kes', 'faturala', 'yeni fatura', 'fat kes'],
    secenekler: [
      { kod: 'satis', ad: 'Yeni satış faturası', ikon: '🧾', liste: '/belge', akis: { islem: 'fatura', kimden: 'cari', yon: 'satis' } },
      { kod: 'alis', ad: 'Yeni alış faturası', ikon: '🧾', liste: '/alis-fatura', akis: { islem: 'fatura', kimden: 'cari', yon: 'alis' } },
      { kod: 'satis-liste', ad: 'Satış Faturası Listesi', ikon: '🧾', liste: '/belge', yol: '/belge' },
      { kod: 'alis-liste', ad: 'Alış Faturası Listesi', ikon: '🧾', liste: '/alis-fatura', yol: '/alis-fatura' },
      { kod: 'eicmal', ad: 'e-Fatura İcmali', ikon: '📨', liste: '/efatura-icmali', yol: '/efatura-icmali' },
    ],
  },
  {
    kelime: 'irsaliye', esAnlam: ['irsaliye', 'irs', 'sevk', 'sevk et', 'yeni irsaliye'],
    secenekler: [
      { kod: 'satis', ad: 'Yeni satış irsaliyesi', ikon: '🚚', liste: '/satis-irsaliye', akis: { islem: 'irsaliye', kimden: 'cari', yon: 'satis' } },
      { kod: 'alis', ad: 'Yeni alış irsaliyesi', ikon: '🚚', liste: '/alis-irsaliye', akis: { islem: 'irsaliye', kimden: 'cari', yon: 'alis' } },
      { kod: 'satis-liste', ad: 'Satış İrsaliyesi Listesi', ikon: '🚚', liste: '/satis-irsaliye', yol: '/satis-irsaliye' },
      { kod: 'alis-liste', ad: 'Alış İrsaliyesi Listesi', ikon: '🚚', liste: '/alis-irsaliye', yol: '/alis-irsaliye' },
    ],
  },
  {
    kelime: 'stok', esAnlam: ['stok', 'urun', 'stok karti', 'yeni stok'],
    secenekler: [
      { kod: 'yeni', ad: 'Yeni stok kartı', ikon: '📦', liste: '/stok', yol: '/stok/yeni' },
      { kod: 'liste', ad: 'Stok Listesi', ikon: '📦', liste: '/stok', yol: '/stok' },
    ],
  },
  {
    kelime: 'musteri', esAnlam: ['musteri', 'yeni musteri'],
    secenekler: [
      { kod: 'yeni', ad: 'Yeni müşteri kartı', ikon: '👥', liste: '/cari', yol: '/cari/yeni' },
      { kod: 'liste', ad: 'Müşteri Listesi', ikon: '👥', liste: '/cari', yol: '/cari' },
      { kod: 'icmal', ad: 'Cari İcmali', ikon: '📊', liste: '/cari-icmali', yol: '/cari-icmali' },
    ],
  },
  {
    kelime: 'tedarikci', esAnlam: ['tedarikci', 'yeni tedarikci'],
    secenekler: [
      { kod: 'yeni', ad: 'Yeni tedarikçi kartı', ikon: '🤝', liste: '/tedarikci', yol: '/tedarikci/yeni' },
      { kod: 'liste', ad: 'Tedarikçi Listesi', ikon: '🤝', liste: '/tedarikci', yol: '/tedarikci' },
    ],
  },
];

/** Araç sözcükleri (sadeleştirilmiş) -> kasa aracı; yazıldıysa karttaki tür modalı atlanır. */
const ARAC_SOZ: [string, KasaArac][] = [
  ['nakit', 'nakit'], ['nak', 'nakit'], ['pesin', 'nakit'],
  ['havale', 'havale'], ['hav', 'havale'], ['eft', 'havale'], ['banka', 'havale'],
  ['pos', 'kart'], ['kredi', 'kart'], ['kart', 'kart'],
  ['cek', 'cek'], ['senet', 'senet'], ['plan', 'plan'],
];
const DOLGU = new Set(['yeni', 'ac', 'olustur', 'yap', 'et', 'al', 'kes', 'ile', 'icin', 'tl', 'lira']);

export interface NiyetCozumu {
  niyet: NiyetTanimi;
  /** Cümlede yazılan araç ("nakit tahsilat") ve tutar ("5000 tahsilat"). */
  arac?: KasaArac; tutar?: number;
}

/** Türkçe sayı ("5.000,50" / "5000" / "5000,5") -> number; değilse null. */
function tutarCoz(s: string): number | null {
  if (!/^\d[\d.]*(,\d{1,2})?$/.test(s)) return null;
  const n = Number(s.replace(/\./g, '').replace(',', '.'));
  return Number.isFinite(n) && n > 0 ? n : null;
}

/**
 * "tahsilat", "nakit tahsilat", "fatura kes", "5000 tahsilat": rezerve kelime cümlenin herhangi bir yerinde; kalan
 * sözcükler araç / tutar / dolgu olmalı - tanınmayan sözcük varsa bu bir niyet değil (ad ya da ekran araması sürer).
 */
export function niyetCoz(metin: string): NiyetCozumu | null {
  // Türkçe harfler sadeleştirilir ("sipariş" -> "siparis", "ödeme" -> "odeme"); sözlük sadeleştirilmiş yazılı.
  const sade = paletSadelestir(metin).toLocaleLowerCase('tr')
    .replace(/ş/g, 's').replace(/ç/g, 'c').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ö/g, 'o').replace(/ı/g, 'i').replace(/İ/g, 'i')
    .replace(/[?.!]+$/g, '').trim();
  if (!sade) return null;
  const sozler = sade.split(/\s+/);
  if (sozler.length > 4) return null;
  let niyet: NiyetTanimi | null = null; let kullanilan: number[] = [];
  for (let i = 0; i < sozler.length && !niyet; i++) {
    const iki = i + 1 < sozler.length ? `${sozler[i]} ${sozler[i + 1]}` : '';
    for (const n of NIYETLER) {
      if (iki && n.esAnlam.includes(iki)) { niyet = n; kullanilan = [i, i + 1]; break }
      // Türkçe ekler ("tahsilati", "siparisi", "faturayi"): kök ≥ 4 harf + en çok 3 harf ek; kısa eş anlamlı tam eşleşir.
      if (n.esAnlam.some(e => e.length >= 4 ? sozler[i].startsWith(e) && sozler[i].length - e.length <= 3 : sozler[i] === e)) {
        niyet = n; kullanilan = [i]; break;
      }
    }
  }
  if (!niyet) return null;
  const sonuc: NiyetCozumu = { niyet };
  for (let i = 0; i < sozler.length; i++) {
    if (kullanilan.includes(i)) continue;
    const s = sozler[i];
    const t = tutarCoz(s); if (t !== null) { sonuc.tutar = t; continue }
    const a = ARAC_SOZ.find(([k]) => k === s); if (a) { sonuc.arac = a[1]; continue }
    if (DOLGU.has(s)) continue;
    return null;
  }
  return sonuc;
}

/** Ürün moduna göre seçenekler (HBYS ayrı listesi varsa o). */
export const niyetSecenekleri = (n: NiyetTanimi, urunModu: number | undefined) =>
  urunModu === 2 && n.hbys ? n.hbys : n.secenekler;

/** Palet -> Kabuk: akış, palet `git` yoluna bu önekle kodlanır (ekran yolu değil, arama penceresi açılır). */
export const AKIS_ONEK = '/__akis?';
/** Herhangi bir ekrandan akış başlatma (Kasa İşlemi Listesi "＋ Tahsilat" / "－ Ödeme"): Kabuk dinler. */
export const AKIS_OLAYI = 'gentegre:akis';
export function akisBaslat(a: AkisSonucu) { window.dispatchEvent(new CustomEvent(AKIS_OLAYI, { detail: a })) }
export interface AkisSonucu extends AkisTanimi { kimden: Kimden; arac?: KasaArac; tutar?: number; /** Plan türü (61 / 71). */ tur?: number }

export function akisYolu(a: AkisSonucu): string {
  const p = new URLSearchParams({ islem: a.islem, kimden: a.kimden });
  if (a.yon) p.set('yon', a.yon);
  if (a.arac) p.set('arac', a.arac);
  if (a.tutar) p.set('tutar', String(a.tutar));
  if (a.tur) p.set('tur', String(a.tur));
  return AKIS_ONEK + p.toString();
}
export function akisCoz(yol: string): AkisSonucu | null {
  if (!yol.startsWith(AKIS_ONEK)) return null;
  const p = new URLSearchParams(yol.slice(AKIS_ONEK.length));
  const islem = p.get('islem') as AkisIslem | null, kimden = p.get('kimden') as Kimden | null;
  if (!islem || !kimden) return null;
  const tutar = Number(p.get('tutar') ?? 0), tur = Number(p.get('tur') ?? 0);
  return { islem, kimden, yon: (p.get('yon') as CariYon | null) ?? undefined,
           arac: (p.get('arac') as KasaArac | null) ?? undefined, tutar: tutar > 0 ? tutar : undefined, tur: tur > 0 ? tur : undefined };
}

/** Arama penceresi için taraf süzgeci (cari): tahsilat / satış -> müşteri, ödeme / alış -> tedarikçi. */
export function akisTarafSuzgeci(a: AkisSonucu): Kosul | undefined {
  if (a.kimden !== 'cari' || a.islem === 'plan') return undefined;   // plan: müşteri de tedarikçi de olabilir
  const musteri = a.islem === 'tahsilat' || (a.islem !== 'odeme' && a.yon !== 'alis');
  return { alan: musteri ? 'musteri' : 'tedarikci', op: 'esit', deger: 1 };
}

/** Pencere başlığı / yer tutucu: "Yeni tahsilat · Nakit — müşteri seçin". */
export function akisBasligi(a: AkisSonucu): string {
  const islemAdi: Record<AkisIslem, string> = { tahsilat: 'Yeni tahsilat', odeme: 'Yeni ödeme', plan: 'Yeni plan', siparis: 'Yeni sipariş', fatura: 'Yeni fatura', irsaliye: 'Yeni irsaliye' };
  const parca = [islemAdi[a.islem]];
  if (a.yon) parca.push(a.yon === 'satis' ? 'satış' : 'alış');
  if (a.arac) parca.push(KASA_ARACLARI[a.islem === 'odeme' ? 'odeme' : 'tahsilat'].find(x => x.arac === a.arac)?.ad ?? a.arac);
  const kim = a.kimden === 'hasta' ? 'hasta' : a.kimden === 'kurum' ? 'kurum' : a.islem === 'plan' ? 'cari'
            : akisTarafSuzgeci(a)?.alan === 'tedarikci' ? 'tedarikçi' : 'müşteri';
  return `${parca.join(' · ')} — ${kim} seçin`;
}

/**
 * Seçilen tarafla kartın yolu. Kasa: tür araçtan (3. aşamada seçilmiş olur; yoksa nakit); tutar = cümlede verilen,
 * yoksa ERP kuralı (kullanıcı 06.11.2026): tahsilatta carinin AÇIK BORCU (bakiye > 0), ödemede alacağı.
 * Belgeler cariKomutu ile aynı yol.
 */
export function akisKartYolu(a: AkisSonucu, secilen: { id: number; unvan: string; satir?: ListeSatiri }): string {
  const satir = secilen.satir ?? {};
  if (a.islem === 'plan')
    return `/kasa-islem/yeni?tur=${a.tur ?? 61}&tarafId=${secilen.id}&tarafUnvan=${encodeURIComponent(secilen.unvan)}`;
  if (a.islem === 'tahsilat' || a.islem === 'odeme') {
    const tur = KASA_ARACLARI[a.islem].find(x => x.arac === (a.arac ?? 'nakit'))!.tur;
    const bakiye = Number(satir.bakiye ?? 0);
    const tutar = a.tutar ?? (a.islem === 'tahsilat' ? (bakiye > 0.005 ? bakiye : 0) : (bakiye < -0.005 ? -bakiye : 0));
    return `/kasa-islem/yeni?tur=${tur}&tarafId=${secilen.id}&tarafUnvan=${encodeURIComponent(secilen.unvan)}`
         + (tutar > 0 ? `&tutar=${tutar.toFixed(2)}` : '');
  }
  const c: SeciliCari = {
    id: secilen.id, ad: secilen.unvan, kod: String(satir.kod ?? ''),
    musteri: Number(satir.musteri) === 1, tedarikci: Number(satir.tedarikci) === 1,
  };
  return cariIslemHedefi(c, a.islem, a.yon ?? null).yol;
}
