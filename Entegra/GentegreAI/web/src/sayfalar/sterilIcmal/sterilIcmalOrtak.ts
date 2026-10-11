/** Sterilizasyon icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);

/** Doluluk: %90 üstü sıkışık, %50 altı boş; kapasite tanımsızsa gri. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: 'kapasite tanımsız', renk: 'pas' };
  const m = yuzde(d);
  return d >= 90 ? { ad: m, renk: 'kir' } : d < 50 ? { ad: m, renk: 'sari' } : { ad: m, renk: 'ok' };
}

/** Set ömrü: ortalama döngü / eşik; %90 üstü uyarı. */
export function omurRozeti(omur: number | null | undefined, esik: number): Rozet {
  if (omur == null) return { ad: '—', renk: 'pas' };
  if (!esik) return { ad: `${omur} / —`, renk: 'pas' };
  const o = omur / esik;
  return { ad: `${omur} / ${esik}`, renk: o >= 0.9 ? 'kir' : o >= 0.75 ? 'sari' : 'ok' };
}
