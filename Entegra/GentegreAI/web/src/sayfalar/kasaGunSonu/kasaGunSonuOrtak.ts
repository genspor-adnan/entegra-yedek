/** Kasa gün sonu ekranının saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Fark rozeti: 0 tuttu, eksi kırmızı, artı sarı; sayım yoksa gri. */
export function farkRozeti(fark: number | null | undefined, fmt: (n: number) => string): Rozet {
  if (fark == null) return { ad: 'sayım yok', renk: 'pas' };
  if (Math.abs(fark) < 0.005) return { ad: '0,00 · tuttu', renk: 'ok' };
  return fark < 0 ? { ad: fmt(fark), renk: 'kir' } : { ad: `+${fmt(fark)}`, renk: 'sari' };
}

/** "1.234,56" / "1234.56" / "" → sayı (boş = null). */
export function tutarCoz(metin: string): number | null {
  const m = metin.trim().replace(/\s|₺/g, '');
  if (!m) return null;
  const n = Number(m.includes(',') ? m.replace(/\./g, '').replace(',', '.') : m);
  return Number.isFinite(n) ? n : null;
}

/** ISO gün kaydırma (yerel saat). */
export function gunKaydir(iso: string, n: number): string {
  const d = new Date(`${iso}T00:00:00`); d.setDate(d.getDate() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
