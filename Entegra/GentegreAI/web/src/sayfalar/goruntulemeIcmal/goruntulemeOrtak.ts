/** Görüntüleme icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Marj: maliyet tanımsızsa yanıltıcı %100 yerine "maliyet yok". Eşik %90 yeşil, %80 sarı. */
export function grMarjRozeti(marj: number | null | undefined, maliyet: number): Rozet {
  if (marj == null) return { ad: '—', renk: 'pas' };
  const m = `%${marj.toFixed(1).replace('.', ',')}`;
  if (maliyet <= 0) return { ad: 'maliyet yok', renk: 'pas' };
  if (marj < 0) return { ad: `${m} zarar`, renk: 'kir' };
  if (marj < 80) return { ad: m, renk: 'kir' };
  if (marj < 90) return { ad: m, renk: 'sari' };
  return { ad: m, renk: 'ok' };
}

/** Doluluk rozeti: %85 üstü sıkışık, %40 altı boş. */
export function dolulukRozeti(d: number): Rozet {
  const m = `%${d.toFixed(1).replace('.', ',')}`;
  if (d >= 85) return { ad: m, renk: 'kir' };
  if (d < 40) return { ad: m, renk: 'sari' };
  return { ad: m, renk: 'ok' };
}
