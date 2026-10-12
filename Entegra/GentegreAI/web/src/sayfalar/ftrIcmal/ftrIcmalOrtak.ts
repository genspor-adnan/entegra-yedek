/** FTR icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);
export const ondalik = (n: number | null | undefined) => (n == null ? '—' : n.toFixed(1).replace('.', ','));
export const saat = (n: number) => `${ondalik(n)} sa`;

/** VAS değişimi: düşüş (negatif) iyidir; "−4,2" biçiminde. */
export const vasFark = (n: number | null | undefined) =>
  n == null ? '—' : `${n < 0 ? '−' : n > 0 ? '+' : ''}${Math.abs(n).toFixed(1).replace('.', ',')}`;

/** Devam oranı: %90 üstü iyi, %80 altı kötü. */
export function devamRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(d), renk: d >= 90 ? 'ok' : d < 80 ? 'kir' : 'sari' };
}

/** Kabin doluluğu: %85 üstü sıkışık, %30 altı boş. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(d), renk: d >= 85 ? 'kir' : d < 30 ? 'sari' : 'ok' };
}

/** Kür durumu rozeti. */
export function durumRozeti(kod: number, ad: string): Rozet {
  const renk = kod === 4 ? 'ok' : kod === 5 ? 'kir' : kod === 3 ? 'sari' : 'mavi';
  return { ad, renk };
}

/** Tedavi yanıtı rozeti. */
export function yanitRozeti(y: string): Rozet | null {
  if (!y) return null;
  return { ad: y, renk: y === 'İyi yanıt' ? 'ok' : y === 'Kısmi yanıt' ? 'sari' : 'kir' };
}
