import type { OdemeDurumu, SevkEden } from '../../api/uclar/sevkEden';

/** Sevk eden icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

export function odemeRozeti(d: OdemeDurumu): Rozet {
  switch (d) {
    case 'odendi': return { ad: 'Ödendi', renk: 'ok' };
    case 'listede': return { ad: 'Ödeme listesinde', renk: 'mavi' };
    case 'onayli': return { ad: 'Onaylı · listeye alınacak', renk: 'mor' };
    case 'hesaplandi': return { ad: 'Hesaplandı · onay bekliyor', renk: 'sari' };
    case 'taslak': return { ad: 'Taslak · fatura bekliyor', renk: 'pas' };
    default: return { ad: 'Komisyon yok', renk: 'pas' };
  }
}

export function turRozeti(t: SevkEden['tur']): Rozet {
  if (t === 'dis') return { ad: 'Dış hekim', renk: 'mavi' };
  if (t === 'kurum') return { ad: 'Kurum adına', renk: 'mor' };
  return { ad: 'İç personel', renk: 'pas' };
}

/** Prim satırı durumu (hakedis_satir.durum). */
export const SATIR_DURUM: Record<number, Rozet> = {
  1: { ad: 'Taslak', renk: 'pas' }, 2: { ad: 'Kesin', renk: 'sari' },
  3: { ad: 'Onaylı', renk: 'mor' }, 4: { ad: 'Ödendi', renk: 'ok' },
};

/** Sevk sayısı değişimi: yeni / ▲ / ▼. */
export function sevkDegisimi(x: Pick<SevkEden, 'yeni' | 'degisim'>): Rozet {
  if (x.yeni) return { ad: 'yeni', renk: 'mavi' };
  const d = x.degisim ?? 0;
  const m = `${d > 0 ? '▲' : d < 0 ? '▼' : ''} %${Math.abs(d).toFixed(0)}`;
  return d >= 10 ? { ad: m, renk: 'ok' } : d <= -10 ? { ad: m, renk: 'kir' } : { ad: m, renk: 'sari' };
}
