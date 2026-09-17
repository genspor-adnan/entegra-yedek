// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import type { SatirDurumu } from '../sayfalar/belgeSatir';
import { bosSatir } from '../sayfalar/belgeSatir';

vi.mock('../api/istemci', () => ({ api: {
  paketIcerigi: vi.fn(async () => []),
} }));

const { useKalemAkisi } = await import('../sayfalar/belgeKarti/useKalemAkisi');

/**
 * ÜCRET SATIRI DÜZENLENİNCE GRİD HEMEN DOĞRU OLMALI (787).
 *
 * Kullanıcı: *"ücret satırını çift tıklayıp adet veya fiyat değişince satırın
 * hemen refresh olması gerekir"*.
 *
 * GERÇEK VAKA: miktar 1 → 4 yapıldı; grid miktarı 4 gösterdi ama TUTAR
 * 2.000,00'de kaldı. Sebep: başvuruda gridin tutar kolonu KAYITLI satırda
 * sunucunun yazdığı dağılım kovalarından ölçekleniyor (602) ve kovalar hâlâ
 * 1 adetlikti. Düzenlenen satırın kovaları düşürülüyor: satır önce kendi brüt
 * tutarını gösterir, ardından önizleme ucu yeni dağılımı getirir (önizleme
 * zaten "dağılımı olmayan" satırlar için çalışıyor).
 *
 * ELLE girilmiş dağılım korunur - onu kullanıcı yazdı.
 */
const kur = (satirlar: SatirDurumu[]) => {
  const setSatirlar = vi.fn();
  const kanca = renderHook(() => useKalemAkisi({
    satirlar,
    setSatirlar: (f: (s: SatirDurumu[]) => SatirDurumu[]) => setSatirlar(f(satirlar)),
    setKalem: vi.fn(), setKalemDegisti: vi.fn(), setHata: vi.fn(),
    yerelPara: 'TL', raporDovizi: 'TL', setRaporDovizi: vi.fn(), setBelgeKuru: vi.fn(),
    cariId: 42, odeyenKurumId: 7, fiyatListesiId: null, kampanyaId: null,
    basvuruBilgi: {}, alisMi: false,
  }));
  return { ...kanca, setSatirlar };
};

const dagilim = (elle: number) => ({
  rota: 1, sgk: 0, oss: 0, hastaProvizyon: 0, hastaEkKatki: 2000,
  sgkKatilimPayi: 0, elle,
}) as unknown as SatirDurumu['dagilim'];

describe('kalem güncellemesi (787)', () => {
  it('düzenlenen satırın BAYAT kovaları düşürülür', () => {
    const eski: SatirDurumu = { ...bosSatir(1), stokAdi: 'Muayene', hizmetId: 5,
                                adet: '1', birimFiyat: '2000', dagilim: dagilim(0) };
    const { result, setSatirlar } = kur([eski]);

    act(() => { result.current.kalemKaydet({ ...eski, adet: '4' }) });

    const yazilan = setSatirlar.mock.calls[0][0] as SatirDurumu[];
    expect(yazilan[0].adet).toBe('4');
    // Kova düşürülmezse grid tutarı 1 adetlik kovadan ölçeklenir ve
    //   "miktar 4 · tutar 2.000" gibi kendi içinde tutarsız bir satır çizilir.
    expect(yazilan[0].dagilim).toBeUndefined();
  });

  it('ELLE girilmiş dağılım KORUNUR', () => {
    const eski: SatirDurumu = { ...bosSatir(1), stokAdi: 'Muayene', hizmetId: 5,
                                adet: '1', birimFiyat: '2000', dagilim: dagilim(1) };
    const { result, setSatirlar } = kur([eski]);

    act(() => { result.current.kalemKaydet({ ...eski, adet: '2' }) });

    const yazilan = setSatirlar.mock.calls[0][0] as SatirDurumu[];
    expect(yazilan[0].dagilim).toBeDefined();
    expect(Number(yazilan[0].dagilim?.elle)).toBe(1);
  });

  it('YENİ satır (dağılımsız) olduğu gibi yazılır', () => {
    const { result, setSatirlar } = kur([]);
    const yeni: SatirDurumu = { ...bosSatir(1), stokAdi: 'Tetkik', hizmetId: 9,
                                adet: '1', birimFiyat: '100' };

    act(() => { result.current.kalemKaydet(yeni) });

    const yazilan = setSatirlar.mock.calls[0][0] as SatirDurumu[];
    expect(yazilan).toHaveLength(1);
    expect(yazilan[0].stokAdi).toBe('Tetkik');
  });
});
