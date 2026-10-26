import { beforeEach, describe, expect, it, vi } from 'vitest';

// KAYITLI BELGE İKİNCİ KEZ EKLENMEZ (26.10.2026): hazırlanmış e-Arşiv faturada Kaydet aynı faturayı yeniden
//   eklemeye çalışıyor, lot ikinci kez düşülmeye kalkıyordu.
const ekle = vi.fn(), guncelle = vi.fn();
vi.mock('../api/istemci', () => ({ api: { belgeEkle: (...a: unknown[]) => ekle(...a), belgeGuncelle: (...a: unknown[]) => guncelle(...a) } }));
vi.mock('../bilesenler/mesaj', () => ({ mesaj: vi.fn() }));
vi.mock('../sayfalar/belgeKaydet', () => ({
  belgeDogrula: () => null, belgeGovdesi: () => ({}), doluSatirlar: (s: unknown[]) => s,
}));

const { belgeKaydetmeKur } = await import('../sayfalar/belgeKarti/useBelgeKaydetme');

function baglam(o: { etkinBelgeId: number | null; duzenlenebilir: boolean; sonucId?: number }) {
  const setAcilanId = vi.fn();
  const b = {
    girdiKur: () => ({}) as never, satirlar: [], setSatirlar: vi.fn(), taslak: false, yerelPara: 'TL',
    etkinBelgeId: o.etkinBelgeId, duzenlenebilir: o.duzenlenebilir, basvuruMu: false,
    sonuc: o.sonucId ? ({ belge: { id: o.sonucId } } as never) : null,
    setSonuc: vi.fn(), setHata: vi.fn(), setAlanHatalari: vi.fn(), setKaydediyor: vi.fn(),
    kalemDegisti: false, setKalemDegisti: vi.fn(), setAcilanId, imzayiTemizle: vi.fn(), kapat: vi.fn(),
  };
  return { kes: belgeKaydetmeKur(b), setAcilanId };
}

describe('belge kaydetme - çift kayıt yok', () => {
  beforeEach(() => {
    ekle.mockReset().mockResolvedValue({ belge: { id: 99 }, satirlar: [] });
    guncelle.mockReset().mockResolvedValue({ belge: { id: 7 }, satirlar: [] });
  });

  it('kilitli kayıtlı belgede yazma yok, mevcut kimlik döner', async () => {
    const { kes } = baglam({ etkinBelgeId: 7, duzenlenebilir: false, sonucId: 7 });
    expect(await kes(false)).toBe(7);
    expect(ekle).not.toHaveBeenCalled();
    expect(guncelle).not.toHaveBeenCalled();
  });

  it('kimliği kartta olmayan kaydedilmiş belge eklenmez, kart kayıtlı moda geçer', async () => {
    const { kes, setAcilanId } = baglam({ etkinBelgeId: null, duzenlenebilir: false, sonucId: 7 });
    expect(await kes(false)).toBe(7);
    expect(ekle).not.toHaveBeenCalled();
    expect(setAcilanId).toHaveBeenCalledWith(7);
  });

  it('düzenlenebilir kayıtlı belge güncellenir', async () => {
    const { kes } = baglam({ etkinBelgeId: 7, duzenlenebilir: true, sonucId: 7 });
    await kes(false);
    expect(guncelle).toHaveBeenCalledTimes(1);
    expect(ekle).not.toHaveBeenCalled();
  });

  it('yeni belge eklenir ve açık kalan kart kayıtlı moda geçer', async () => {
    const { kes, setAcilanId } = baglam({ etkinBelgeId: null, duzenlenebilir: false });
    expect(await kes(false)).toBe(99);
    expect(ekle).toHaveBeenCalledTimes(1);
    expect(setAcilanId).toHaveBeenCalledWith(99);
  });
});
