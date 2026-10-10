/** Laboratuvar icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Dakika → "52 dk" / "2 sa 12 dk" / "2,0 gün". */
export function sure(dk: number | null | undefined): string {
  if (dk == null) return '—';
  if (dk >= 1440) return `${(dk / 1440).toFixed(1).replace('.', ',')} gün`;
  if (dk >= 60) return `${Math.floor(dk / 60)} sa ${String(Math.round(dk % 60)).padStart(2, '0')} dk`;
  return `${Math.round(dk)} dk`;
}

export function gun(g: number | null | undefined): string {
  return g == null ? '—' : `${g.toFixed(1).replace('.', ',')} gün`;
}

/** Marj: maliyet tanımsızsa yanıltıcı %100 yerine "maliyet yok". */
export function labMarjRozeti(marj: number | null | undefined, maliyet: number): Rozet {
  if (marj == null) return { ad: '—', renk: 'pas' };
  const m = `%${marj.toFixed(1).replace('.', ',')}`;
  if (maliyet <= 0) return { ad: 'maliyet yok', renk: 'pas' };
  if (marj < 0) return { ad: `${m} zarar`, renk: 'kir' };
  if (marj < 50) return { ad: m, renk: 'sari' };
  return { ad: m, renk: 'ok' };
}

export function yuzde(n: number | null | undefined): string {
  return n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`;
}
