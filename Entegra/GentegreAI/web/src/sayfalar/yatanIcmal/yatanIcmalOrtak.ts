/** Yatan hasta icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Doluluk: %85 ve üstü sıkışık, %50 altı düşük. */
export function dolulukRozeti(d: number | null | undefined): Rozet {
  if (d == null) return { ad: '—', renk: 'pas' };
  const m = `%${d.toFixed(1).replace('.', ',')}`;
  if (d >= 85) return { ad: `${m} sıkışık`, renk: 'kir' };
  if (d < 50) return { ad: `${m} düşük`, renk: 'sari' };
  return { ad: `${m} normal`, renk: 'ok' };
}

export const DURUM: Record<string, Rozet> = {
  yatiyor: { ad: 'Yatıyor', renk: 'mavi' },
  acik: { ad: 'Taburcu · hesap açık', renk: 'kir' },
  kapandi: { ad: 'Kapandı', renk: 'ok' },
};

/** Açık hesap bekleme günü rozeti. */
export function beklemeRozeti(gun: number): Rozet {
  if (gun > 30) return { ad: `${gun} gün`, renk: 'kir' };
  if (gun > 14) return { ad: `${gun} gün`, renk: 'sari' };
  return { ad: `${gun} gün`, renk: 'pas' };
}

export const gunMetni = (n: number | null | undefined) => (n == null ? '—' : n.toFixed(1).replace('.', ','));
