/**
 * LISTE AKSIYON MODULLERININ ORTAK PARCALARI.
 *
 * Laboratuvar ailesindeki bes modul (lab · mikro · genetik · kalite kontrol ·
 * dis lab) ayni baglami ve ayni sayi okuyucusunu tekrar tekrar tanimliyordu.
 */

/** Aksiyonun ekrandan istedigi iki sey: listeyi tazele, bir yola git. */
export interface AksiyonBaglami {
  tazele(): void;
  git(yol: string): void;
}

/**
 * Kullanicinin yazdigi sayiyi okur. Bos birakilan alan `undefined` doner -
 * sunucuya "0" gondermek "olcum sifir" demektir, oysa kullanici girmemistir.
 * Virgul de kabul edilir: Turkce klavyede ondalik ayraci odur.
 */
export function sayiOku(metin: string | null | undefined): number | undefined {
  if (!metin || metin.trim() === '') return undefined;
  const d = Number(metin.trim().replace(',', '.'));
  return Number.isFinite(d) ? d : undefined;
}
