/**
 * ÇEVİRİ (194) — ana menü ve ekran etiketleri.
 *
 * SÖZLÜK SUNUCUDAN GELİR (`/api/ceviri/{dil}`): koda gömülü ikinci bir sözlük
 * tutulsaydı zamanla veritabanındakiyle ayrışırdı ve yeni çeviri için sürüm
 * çıkmak gerekirdi. Giriş sonrası bir kez indirilir, dil değişince tazelenir.
 *
 * ANAHTAR TÜRKÇE METNİN KENDİSİDİR: çevirisi olmayan metin Türkçe görünür.
 * Yeni ekran eklendiğinde çeviri unutulsa bile ekran boş kalmaz - eksik
 * çeviriler `eksikCeviriler()` ile toplanıp sözlüğe eklenebilir.
 */

export type Kapsam = 'menu' | 'etiket';

type Sozluk = Record<string, Record<string, string>>;

let sozluk: Sozluk = {};
let yukluDil = -1;
/** Çevirisi bulunamayan metinler - sözlüğü tamamlamak için. */
const eksikler = new Set<string>();
const dinleyiciler = new Set<() => void>();

/** Sözlük değişince yeniden çizilmesi gereken bileşenler için. */
export function ceviriDinle(f: () => void): () => void {
  dinleyiciler.add(f);
  return () => { dinleyiciler.delete(f) };
}

/**
 * Dilin sözlüğünü indirir. Türkçe (0) için istek YAPILMAZ: kaynak metin zaten
 * Türkçe, boş sözlükle anahtarın kendisi döner.
 */
export async function ceviriYukle(dil: number): Promise<void> {
  if (dil === yukluDil) return;
  if (!dil) {
    sozluk = {};
    yukluDil = 0;
    dinleyiciler.forEach(f => f());
    return;
  }
  try {
    // Taban adres istemcinin kullandiginin AYNISI olmali: dev sunucusunda
    //   arayuz 3000, API 5180 - goreli yol HTML dondurur, JSON degil.
    const taban = import.meta.env.VITE_API ?? 'http://localhost:5180';
    const y = await fetch(`${taban}/api/ceviri/${dil}`);
    if (!y.ok) throw new Error(String(y.status));
    const d = await y.json() as { sozluk: Sozluk };
    sozluk = d.sozluk ?? {};
    yukluDil = dil;
  } catch {
    // Sözlük inmezse uygulama Türkçe çalışır; dil yüzünden ekran açılmamazlık
    //   etmesin.
    sozluk = {};
    yukluDil = dil;
  }
  dinleyiciler.forEach(f => f());
}

/** Sözlükte birebir arama (ikon/kısayol soyulmuş metin için). */
function bul(m: string, kapsam: Kapsam): string | undefined {
  return sozluk[kapsam]?.[m]
    // Menü adı etiket sözlüğünde de olabilir (ör. "Kasa" hem grup hem etiket).
    ?? sozluk[kapsam === 'menu' ? 'etiket' : 'menu']?.[m];
}

/**
 * Metnin başındaki ikon/işaret ("＋ Yeni", "✎ Düzenle", "🖨️ Yazdır").
 * Aksiyon adları ikonla geliyor; ikon dilden bağımsız, ÇEVRİLEN kısım metin.
 * Sözlüğü "＋ Yeni" gibi ikonlu anahtarlarla doldurmak ikon değişince çeviriyi
 * kırardı - bu yüzden ikon ayrılıp metin çevrilir, sonra baştaki ikon geri konur.
 */
const IKON = /^([^\p{L}\p{N}]+)\s*/u;

/** Menü / etiket çevirisi; yoksa Türkçe metnin kendisi. */
export function c(metin: string | undefined | null, kapsam: Kapsam = 'etiket'): string {
  const m = (metin ?? '').trim();
  if (!m || !yukluDil) return metin ?? '';

  const birebir = bul(m, kapsam);
  if (birebir) return birebir;

  const ikon = IKON.exec(m);
  if (ikon) {
    const govde = m.slice(ikon[0].length);
    const cevrilmis = bul(govde, kapsam);
    if (cevrilmis) return `${ikon[1]} ${cevrilmis}`;
    eksikler.add(`${kapsam}:${govde}`);
    return m;
  }

  eksikler.add(`${kapsam}:${m}`);
  return m;
}

/** Menü kısayolu - `c(x, 'menu')` yerine. */
export const cm = (metin: string | undefined | null) => c(metin, 'menu');

/** Sözlükte karşılığı bulunamayan metinler (geliştirme yardımcısı). */
export function eksikCeviriler(): string[] {
  return [...eksikler].sort();
}

/** Yüklü dil - bileşenler tazeleme anahtarı olarak kullanır. */
export function yukluDilKodu(): number {
  return yukluDil;
}
