/**
 * "SON ARANAN" / "SIK ARANAN" SIRASI - arama pencereleri icin ortak kural.
 *
 * Pencereler birden cok kaynagi (stok + hizmet, musteri + kisi + hasta) AYRI
 * isteklerle cekip tek listede gosteriyor. Her istek kendi icinde dogru sirali
 * gelir ama birlestirme sirayi bozuyordu: liste ya ada gore yeniden siralaniyor
 * ya da kaynaklar ust uste ekleniyordu - kullanici en son sectigi kaydi en
 * ustte goremiyordu ("son eklenene basinca en ustte o gelmedi").
 *
 * Sunucu son/sik gorunumunde siralama anahtarlarini da doner
 * (`aramaSonTarih`, `aramaSay` - SorguUretici). Burasi birlesik listeyi ayni
 * kurala gore yeniden sirlar: SON = en yeni once, SIK = en cok kullanilan
 * once (esitlikte yine en yeni).
 */
export type AramaGorunumu = 'tum' | 'son' | 'sik';

/** Sunucunun son/sik gorunumunde ekledigi siralama alanlari. */
export interface AramaSiraAlanlari {
  aramaSonTarih?: unknown;
  aramaSay?: unknown;
}

const zaman = (r: AramaSiraAlanlari) => {
  const t = Date.parse(String(r.aramaSonTarih ?? ''));
  return Number.isFinite(t) ? t : 0;
};
const say = (r: AramaSiraAlanlari) => Number(r.aramaSay ?? 0);

export function aramaSirala<T extends AramaSiraAlanlari>(
  satirlar: T[], gorunum: AramaGorunumu, adAlani = 'ad',
): T[] {
  const s = [...satirlar];
  if (gorunum === 'son') return s.sort((a, b) => zaman(b) - zaman(a));
  if (gorunum === 'sik') return s.sort((a, b) => say(b) - say(a) || zaman(b) - zaman(a));
  const ad = (r: T) => String((r as Record<string, unknown>)[adAlani] ?? '');
  return s.sort((a, b) => ad(a).localeCompare(ad(b), 'tr'));
}
