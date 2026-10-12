/** Ameliyathane icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toFixed(1).replace('.', ',')}`);

/** Dakika → "1 sa 50 dk" / "45 dk". */
export function sureMetni(dk: number | null | undefined): string {
  if (dk == null) return '—';
  const m = Math.round(dk);
  return m >= 60 ? `${Math.floor(m / 60)} sa ${String(m % 60).padStart(2, '0')} dk` : `${m} dk`;
}

/** Dakika → tam saat ("112 sa"); kapasite / kullanım sütunları. */
export const saatMetni = (dk: number) => `${Math.round(dk / 60).toLocaleString('tr-TR')} sa`;

/** Salon doluluğu: %85 üstü sıkışık, %40 altı boş; mesai tanımsızsa gri. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: '—', renk: 'pas' };
  const m = yuzde(d);
  return d >= 85 ? { ad: m, renk: 'kir' } : d < 40 ? { ad: m, renk: 'sari' } : { ad: m, renk: 'ok' };
}

/** Plan sapması (yüzde): %10 üstü kırmızı, %5 üstü sarı, altı yeşil. */
export function sapmaRozeti(s: number | null | undefined): Rozet {
  if (s == null) return { ad: '—', renk: 'pas' };
  const a = Math.abs(s);
  return { ad: yuzde(s), renk: a > 10 ? 'kir' : a > 5 ? 'sari' : 'ok' };
}

/** Vaka sapması (dakika) metni: "+40 dk" / "-10 dk". */
export const dkFark = (n: number | null | undefined) => (n == null ? '—' : `${n > 0 ? '+' : n < 0 ? '−' : '±'}${Math.abs(n)} dk`);

/** Marj: %70 altı sarı, %50 altı kırmızı (implantlı ortopedi doğal olarak düşük). */
export function marjRozeti(m: number | null | undefined): Rozet {
  if (m == null) return { ad: '—', renk: 'pas' };
  return { ad: yuzde(m), renk: m < 50 ? 'kir' : m < 70 ? 'sari' : 'ok' };
}

/** İlk vaka zamanında: "16 / 22 · %73". */
export function ilkVakaMetni(zamaninda: number, toplam: number): string {
  if (!toplam) return '—';
  return `${zamaninda} / ${toplam} · %${Math.round((100 * zamaninda) / toplam)}`;
}
