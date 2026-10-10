import { describe, expect, it } from 'vitest';
import type { KurumDonemIcmali, KurumIcmali } from '../api/uclar/kurumIcmal';
import { donemAdimlari, gecenAy, icmalRozeti, provizyonRozeti } from '../sayfalar/kurum/icmal/kurumIcmalOrtak';

const icmal = (durum: number, faturaTutari = 0, tahsil = 0): KurumDonemIcmali => ({
  id: 1, kurumId: 5, kurum: 'K', donemBas: '2026-09-01', donemBit: '2026-09-30', durum,
  toplam: 100, belgeId: durum === 2 ? 9 : null, faturaNo: '', faturaTarihi: null, faturaTutari, tahsil,
});
const v = (icmaller: KurumDonemIcmali[], acik = 0) =>
  ({ icmaller, ozet: { acikKurumPayi: acik } as KurumIcmali['ozet'] });
const durumlar = (x: ReturnType<typeof donemAdimlari>) => x.map(a => a.durum);

describe('kurum icmali', () => {
  it('dönem adımları icmal ve faturaya göre ilerler', () => {
    expect(durumlar(donemAdimlari(v([], 50)))).toEqual(['simdi', 'bekliyor', 'bekliyor', 'bekliyor']);
    expect(durumlar(donemAdimlari(v([icmal(1)])))).toEqual(['bitti', 'simdi', 'bekliyor', 'bekliyor']);
    expect(durumlar(donemAdimlari(v([icmal(2, 100, 40)])))).toEqual(['bitti', 'bitti', 'simdi', 'bekliyor']);
    expect(durumlar(donemAdimlari(v([icmal(2, 100, 100)])))).toEqual(['bitti', 'bitti', 'bitti', 'bitti']);
  });

  it('icmalden sonra açık kurum payı kaldıysa dönem kesinleşmiş sayılmaz', () => {
    expect(durumlar(donemAdimlari(v([icmal(1)], 25)))).toEqual(['simdi', 'bekliyor', 'bekliyor', 'bekliyor']);
  });

  it('rozetler ve varsayılan dönem', () => {
    expect(provizyonRozeti(-1)).toBeNull();
    expect(provizyonRozeti(2)?.ad).toBe('Red');
    expect(icmalRozeti(0).ad).toBe('Açık');
    expect(icmalRozeti(2).ad).toBe('Faturalandı');
    expect(gecenAy(new Date(2026, 0, 15))).toEqual({ bas: '2025-12-01', bit: '2025-12-31' });
  });
});
