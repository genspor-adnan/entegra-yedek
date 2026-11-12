// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { renderHook } from '@testing-library/react';

/**
 * SIFIR FİYAT HIZLI EKLENMEZ (kullanıcı 12.10.2026 başvuru "ücret sıfırsa fiyat ekranı açılsın",
 * 09.11.2026 tekrar: "fiyat sıfırsa ekrandan sormalı"): arama penceresinden Enter / "1 Adet Ekle" ile
 * seçilen kalemin fiyatı yoksa gride düşmez, kalem (fiyat) penceresi açılır. Fiyatı olan kalem
 * pencere açılmadan eklenir.
 */
vi.mock('../api/istemci', () => ({ api: {
  hizmetUygunluk: async () => ({ mesaj: '', istisna: false }),
  fiyatKalem: async () => null,
  paketIcerigi: async () => [],
  aramaIsaretle: async () => undefined,
} }));
vi.mock('../bilesenler/mesaj', () => ({ mesaj: vi.fn(), metinSor: vi.fn() }));

const { useKalemAkisi } = await import('../sayfalar/belgeKarti/useKalemAkisi');

function kur(sifirFiyatSor: boolean, herZamanPencere = false) {
  const setKalem = vi.fn();
  const setSatirlar = vi.fn();
  const { result } = renderHook(() => useKalemAkisi({
    satirlar: [], setSatirlar, setKalem, setKalemDegisti: vi.fn(), setHata: vi.fn(),
    yerelPara: 'TL', raporDovizi: 'TL', setRaporDovizi: vi.fn(), setBelgeKuru: vi.fn(),
    cariId: null, odeyenKurumId: null, fiyatListesiId: null, kampanyaId: null,
    basvuruBilgi: {}, alisMi: false, sifirFiyatSor, herZamanPencere,
  }));
  return { akis: result.current, setKalem, setSatirlar };
}

describe('kalem akışı - sıfır fiyat', () => {
  it('fiyatsız hizmet hızlı eklenmez, fiyat penceresi açılır', async () => {
    const { akis, setKalem, setSatirlar } = kur(true);
    const eklendi = await akis.stokSecildi({ id: 5, tip: 'hizmet', ad: 'Muayene', fiyat: 0 }, true);
    expect(eklendi).toBe(false);
    expect(setKalem).toHaveBeenCalledTimes(1);
    expect(setSatirlar).not.toHaveBeenCalled();
  });

  it('fiyatı olan hizmet pencere açılmadan gride düşer', async () => {
    const { akis, setKalem, setSatirlar } = kur(true);
    const eklendi = await akis.stokSecildi({ id: 5, tip: 'hizmet', ad: 'Muayene', fiyat: 250 }, true);
    expect(eklendi).toBe(true);
    expect(setKalem).not.toHaveBeenCalled();
    expect(setSatirlar).toHaveBeenCalledTimes(1);
  });

  it('transfer / stok fişinde (sifirFiyatSor yok) fiyatsız stok hızlı eklenir', async () => {
    const { akis, setKalem } = kur(false);
    const eklendi = await akis.stokSecildi({ id: 9, tip: 'stok', ad: 'Eldiven', fiyat: 0 }, true);
    expect(eklendi).toBe(true);
    expect(setKalem).not.toHaveBeenCalled();
  });
});

/** ERP SATIŞ / ALIŞ (kullanıcı 12.11.2026): seçim her zaman adet / fiyat penceresini açar; HBYS'de kural aynen. */
describe('kalem akışı - ERP her zaman pencere', () => {
  it('fiyatı olan stok da hızlı eklenmez, pencere açılır', async () => {
    const { akis, setKalem, setSatirlar } = kur(true, true);
    const eklendi = await akis.stokSecildi({ id: 7, tip: 'stok', ad: 'Kalem', fiyat: 40 }, true);
    expect(eklendi).toBe(false);
    expect(setKalem).toHaveBeenCalledTimes(1);
    expect(setSatirlar).not.toHaveBeenCalled();
  });

  it('kural kapalıyken (HBYS) fiyatı olan kalem eskisi gibi hızlı eklenir', async () => {
    const { akis, setKalem, setSatirlar } = kur(true, false);
    const eklendi = await akis.stokSecildi({ id: 7, tip: 'stok', ad: 'Kalem', fiyat: 40 }, true);
    expect(eklendi).toBe(true);
    expect(setKalem).not.toHaveBeenCalled();
    expect(setSatirlar).toHaveBeenCalledTimes(1);
  });
});
