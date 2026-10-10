/** Hekim performans icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Önceki döneme göre değişim: +%5 üstü yeşil, −%5 altı kırmızı, arası nötr. */
export function degisimRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: 'yeni', renk: 'pas' };
  const m = `${d > 0 ? '▲' : d < 0 ? '▼' : ''} %${Math.abs(d).toFixed(1).replace('.', ',')}`;
  if (d >= 5) return { ad: m, renk: 'ok' };
  if (d <= -5) return { ad: m, renk: 'kir' };
  return { ad: m, renk: 'sari' };
}

export const AY_KISA = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

/** Ay başı / sonu (yerel): ay kaydırma ve varsayılan dönem. */
export function ayAraligi(yil: number, ay: number): { bas: string; bit: string } {
  const f = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  return { bas: f(new Date(yil, ay - 1, 1)), bit: f(new Date(yil, ay, 0)) };
}
