import { describe, expect, it } from 'vitest';
import { basvuruDurumu, hareketleriKur, odemeRozeti } from '../sayfalar/hasta/icmal/icmalOrtak';
import type { IcmalBasvuru, IcmalTahsilat } from '../api/uclar/hastaIcmal';

// Hasta icmali (10.10.2026): hareket özeti ve rozetler saf hesaptır.
const b = (o: Partial<IcmalBasvuru>): IcmalBasvuru => ({
  id: 1, no: 'B1', tarih: '2026-09-01T10:00:00Z', iptal: false, bolum: 'Dahiliye', hekim: '', kurum: 'SGK',
  toplam: 1000, iskonto: 0, kurumPayi: 600, hastaPayi: 400, tahsil: 0, kalan: 400, ...o,
});
const t = (o: Partial<IcmalTahsilat>): IcmalTahsilat => ({
  id: 1, makbuzNo: 'M1', tarih: '2026-09-02T10:00:00Z', basvuruId: 1, basvuruNo: 'B1', tur: 'Nakit Tahsilat',
  grup: 'tahsilat', iade: false, tutar: 300, iptal: false, banko: '', hesapTuru: 'K', ...o,
});

describe('hasta icmali', () => {
  it('hareket özeti: hasta payı borç, tahsilat alacak, iade borç; yürüyen bakiye', () => {
    const h = hareketleriKur({
      basvurular: [b({})],
      tahsilatlar: [t({}), t({ id: 2, makbuzNo: 'M2', tarih: '2026-09-03T10:00:00Z', iade: true, tutar: 50 })],
    });
    expect(h.map(x => [x.borc, x.alacak, x.bakiye])).toEqual([[400, 0, 400], [0, 300, 100], [50, 0, 150]]);
  });

  it('iptal başvuru ve iptal tahsilat harekete girmez; kurum payı borç yazılmaz', () => {
    const h = hareketleriKur({
      basvurular: [b({}), b({ id: 2, no: 'B2', iptal: true })],
      tahsilatlar: [t({ iptal: true })],
    });
    expect(h).toHaveLength(1);
    expect(h[0].borc).toBe(400);
  });

  it('durum ve ödeme rozetleri', () => {
    expect(basvuruDurumu({ iptal: false, kalan: 0, tahsil: 400 }).ad).toBe('Kapandı');
    expect(basvuruDurumu({ iptal: false, kalan: 100, tahsil: 300 }).ad).toBe('Kısmi');
    expect(basvuruDurumu({ iptal: false, kalan: 400, tahsil: 0 }).ad).toBe('Açık');
    expect(basvuruDurumu({ iptal: true, kalan: 400, tahsil: 0 }).ad).toBe('İptal');
    expect(odemeRozeti(t({ hesapTuru: 'P' })).ad).toBe('POS');
    expect(odemeRozeti(t({ iade: true })).ad).toBe('iade');
  });
});
