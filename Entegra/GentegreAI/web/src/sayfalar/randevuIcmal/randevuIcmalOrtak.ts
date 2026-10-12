/** Randevu / poliklinik icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);
export const sayi = (n: number | null | undefined) => (n == null ? '—' : n.toLocaleString('tr-TR'));
export const dakika = (n: number | null | undefined) => (n == null ? '—' : `${n} dk`);

/** Slot doluluğu: %75 altı düşük (boş slot çok), %95 üstü sıkışık; slot tanımsızsa gri. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: 'plan yok', renk: 'pas' };
  const m = yuzde(d);
  return d >= 95 ? { ad: m, renk: 'kir' } : d < 75 ? { ad: `${m} düşük`, renk: 'sari' } : { ad: m, renk: 'ok' };
}

/** No-show (gelmeme): %15 üstü kırmızı, %10 üstü sarı. */
export function noShowRozeti(n: number | null | undefined): Rozet {
  if (n == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(n), renk: n > 15 ? 'kir' : n > 10 ? 'sari' : 'ok' };
}

/** Gün × saat hücresi zemin yoğunluğu (0-1); slotsuz hücre null. */
export function hucreYogunluk(doluluk: number | null | undefined): number | null {
  if (doluluk == null) return null;
  return Math.max(0, Math.min(1, doluluk / 100));
}
