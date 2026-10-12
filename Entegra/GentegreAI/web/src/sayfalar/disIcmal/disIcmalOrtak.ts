/** Diş icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);
export const yuzdeTam = (n: number | null | undefined) => (n == null ? '—' : `%${Math.round(n)}`);

/** Brüt marj: %80 üstü iyi, %60 altı uyarı. */
export function marjRozeti(m: number | null | undefined): Rozet {
  if (m == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(m), renk: m >= 80 ? 'ok' : m < 60 ? 'kir' : 'sari' };
}

/** Ünite doluluğu: %85 üstü sıkışık, %40 altı boş. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(d), renk: d >= 85 ? 'kir' : d < 40 ? 'sari' : 'ok' };
}

/** Yarım kalan: 90+ gün kırmızı, 60+ sarı. */
export function gunRozeti(gun: number): Rozet {
  return { ad: `${gun} gün`, renk: gun >= 90 ? 'kir' : gun >= 60 ? 'sari' : 'pas' };
}
