import { describe, it, expect, vi, beforeEach } from 'vitest';

/**
 * RANDEVU PANOSU (19.11.2026): kes = aynı randevuyu yeni saate / sütuna taşır; kopyala = aynı hastaya yeni randevu,
 * durum / belge bağı / SMS damgası taşınmaz.
 */
const kartOku = vi.fn(), kartGuncelle = vi.fn(), kartEkle = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  kartOku: (...a: unknown[]) => kartOku(...a),
  kartGuncelle: (...a: unknown[]) => kartGuncelle(...a),
  kartEkle: (...a: unknown[]) => kartEkle(...a),
} }));
const { randevuYapistir } = await import('../sayfalar/liste/randevuPano');

const kaynak = { surum: 's1', id: 5, hastaId: 9, sureDk: 20, tip: 1, kaynak: 2, bolum: 3, hekimId: 4, cihazId: null,
                 hizmetId: 11, gonderenId: 12, kendiIstegi: 0, kurumId: 13, aciklama: 'not', smsGonder: 1, smsHatirlatma: 0,
                 durum: 2, belgeId: 777, smsBilgiBaslangic: '2026-11-20T07:00:00Z', baslangic: '2026-11-20T07:00:00Z' };

describe('randevuYapistir', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    kartOku.mockResolvedValue({ kart: kaynak });
    kartGuncelle.mockResolvedValue({ kart: { id: 5 } });
    kartEkle.mockResolvedValue({ kart: { id: 99 } });
  });

  it('kes: aynı kaydı yeni saate ve hedef doktor + bölüme taşır', async () => {
    const id = await randevuYapistir({ mod: 'kes', id: 5, hasta: 'A', saat: '' },
                                     { baslangic: '2026-11-21T10:00', hekimId: 8, bolum: 6 });
    expect(id).toBe(5);
    expect(kartEkle).not.toHaveBeenCalled();
    expect(kartGuncelle).toHaveBeenCalledWith('randevu', 5,
      { surum: 's1', kart: { baslangic: '2026-11-21T10:00', hekimId: 8, bolum: 6 } });
  });

  it('kopyala: yeni randevu, planlandı; durum / belge / SMS damgası kopyalanmaz; düz sütunda kaynak aynı', async () => {
    const id = await randevuYapistir({ mod: 'kopyala', id: 5, hasta: 'A', saat: '' }, { baslangic: '2026-11-22T09:30' });
    expect(id).toBe(99);
    const kart = kartEkle.mock.calls[0][1].kart;
    expect(kart).toMatchObject({ durum: 1, baslangic: '2026-11-22T09:30', hastaId: 9, sureDk: 20, hekimId: 4, bolum: 3,
                                 hizmetId: 11, gonderenId: 12, kurumId: 13, aciklama: 'not', smsGonder: 1, smsHatirlatma: 0 });
    expect(kart).not.toHaveProperty('belgeId');
    expect(kart).not.toHaveProperty('smsBilgiBaslangic');
    expect(kart).not.toHaveProperty('cihazId');
    expect(kartGuncelle).not.toHaveBeenCalled();
  });

  it('kopyala cihaz sütununa: cihaz hedeften', async () => {
    await randevuYapistir({ mod: 'kopyala', id: 5, hasta: 'A', saat: '' }, { baslangic: '2026-11-22T09:30', cihazId: 3 });
    expect(kartEkle.mock.calls[0][1].kart.cihazId).toBe(3);
  });
});
