// @vitest-environment jsdom
import { describe, expect, it, vi, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * WEB İNCELEMESİ 18.11.2026 - belge kartında üst üste binen işlemler:
 *  4 hızlı iki seçim aynı satır anahtarını almaz (ilk kalem kaybolmaz) ·
 *  5 yeniden fiyatlama en son çağrıyı uygular ve arada eklenen satırı silmez ·
 *  7 satırlar yeniden numaralanınca eski seçim başka satırı göstermez.
 */
const bekleyenler: Array<(v: unknown) => void> = [];
const fiyatKalem = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  hizmetUygunluk: async () => ({ mesaj: '', istisna: false }),
  fiyatKalem: (...a: unknown[]) => fiyatKalem(...a),
  paketIcerigi: async () => [],
  aramaIsaretle: async () => undefined,
  liste: async () => ({ satirlar: [] }),
  fiyatKampanya: async () => ({ kampanyaId: null, ad: '', kod: '' }),
  belgeVarsayilanListe: async () => ({ listeId: null }),
} }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: vi.fn(), metinSor: vi.fn(), onay: async () => true,
  guvenli: (f: () => Promise<void>) => f(),
}));

const { useKalemAkisi } = await import('../sayfalar/belgeKarti/useKalemAkisi');
const { useBelgeFiyatlandirma } = await import('../sayfalar/belgeKarti/useBelgeFiyatlandirma');
const { useSatirSecimi } = await import('../sayfalar/belgeKarti/useSatirSecimi');

/** setSatirlar taklidi: fonksiyonel güncellemeleri sırayla uygular, son hali tutar. */
function durum(ilk: SatirDurumu[]) {
  let s = ilk;
  const set = vi.fn((d: SatirDurumu[] | ((o: SatirDurumu[]) => SatirDurumu[])) => { s = typeof d === 'function' ? d(s) : d });
  return { set, oku: () => s };
}

beforeEach(() => { fiyatKalem.mockReset(); bekleyenler.length = 0 });

describe('4 · hızlı iki seçim', () => {
  it('fiyat istekleri sürerken iki seçim iki AYRI satır olur', async () => {
    fiyatKalem.mockImplementation(() => new Promise(r => bekleyenler.push(r)));
    const d = durum([]);
    const { result } = renderHook(() => useKalemAkisi({
      satirlar: [], setSatirlar: d.set, setKalem: vi.fn(), setKalemDegisti: vi.fn(), setHata: vi.fn(),
      yerelPara: 'TL', raporDovizi: 'TL', setRaporDovizi: vi.fn(), setBelgeKuru: vi.fn(),
      cariId: null, odeyenKurumId: null, fiyatListesiId: 3, kampanyaId: null,
      basvuruBilgi: {}, alisMi: false,
    }));
    let a!: Promise<boolean>, b!: Promise<boolean>;
    await act(async () => {
      a = result.current.stokSecildi({ id: 1, tip: 'stok', ad: 'A', fiyat: 10 }, true);
      b = result.current.stokSecildi({ id: 2, tip: 'stok', ad: 'B', fiyat: 20 }, true);
      await Promise.resolve(); await Promise.resolve();
      bekleyenler.forEach(r => r({ fiyat: 50 }));
      await Promise.all([a, b]);
    });
    expect(d.oku().map(x => x.stokId)).toEqual([1, 2]);                      // eskiden yalnız [2]
    expect(new Set(d.oku().map(x => x.anahtar)).size).toBe(2);
  });
});

describe('5 · yeniden fiyatlama', () => {
  it('yavaş dönen ESKİ liste yeni listenin fiyatını ezmez, arada eklenen satır kalır', async () => {
    const satir = { ...bosSatir(1), hizmetId: 900, adet: '1', birimFiyat: '100' };
    const d = durum([satir]);
    const { result } = renderHook(() => useBelgeFiyatlandirma({
      belgeId: undefined, tur: 19, alisMi: false, cariId: 7, odeyenKurumId: null,
      satirlar: [satir], setSatirlar: d.set,
    }));
    const cevap: Record<number, (v: unknown) => void> = {};
    fiyatKalem.mockImplementation((_k: unknown, o: { listeId: number }) => new Promise(r => { cevap[o.listeId] = r }));
    let eski!: Promise<void>, yeni!: Promise<void>;
    await act(async () => {
      eski = result.current.satirlariYenidenFiyatla(1, null, 'listeden');
      yeni = result.current.satirlariYenidenFiyatla(2, null, 'listeden');
      await Promise.resolve();
      cevap[2]({ fiyat: 222 });
      await yeni;
      d.set(s => [...s, { ...bosSatir(2), hizmetId: 901, birimFiyat: '5' }]);   // kullanıcı satır ekledi
      cevap[1]({ fiyat: 111 });
      await eski;
    });
    expect(d.oku().map(x => [x.anahtar, x.birimFiyat])).toEqual([[1, '222'], [2, '5']]);   // eskiden [[1,'111']]
  });
});

describe('7 · seçim yeniden numaralanmada', () => {
  it('kimliği değişen anahtar seçimden düşer, silme yanlış satıra gitmez', () => {
    const ilk = [{ ...bosSatir(1), satirId: 11, hizmetId: 1 }, { ...bosSatir(2), satirId: 12, hizmetId: 2 },
                 { ...bosSatir(3), satirId: 13, hizmetId: 3 }];
    const { result, rerender } = renderHook(({ s }) => useSatirSecimi(s, vi.fn(), vi.fn()), { initialProps: { s: ilk } });
    act(() => result.current.satirTikla(2, { shiftKey: false, ctrlKey: false, metaKey: false }));   // satır 13
    expect([...result.current.seciliSatirlar]).toEqual([3]);
    // Kayıt / tazeleme: boş satır 2 düştü, sunucu satırları yeniden numaralandı - anahtar 3 artık başka satır.
    const sonra = [{ ...bosSatir(1), satirId: 11, hizmetId: 1 }, { ...bosSatir(2), satirId: 13, hizmetId: 3 },
                   { ...bosSatir(3), satirId: 14, hizmetId: 4 }];
    rerender({ s: sonra });
    expect(result.current.seciliSatirlar.size).toBe(0);                                           // eskiden {3} = 14
  });

  it('satırlar değişmezse seçim kalır', () => {
    const ilk = [{ ...bosSatir(1), satirId: 11, hizmetId: 1 }, { ...bosSatir(2), satirId: 12, hizmetId: 2 }];
    const { result, rerender } = renderHook(({ s }) => useSatirSecimi(s, vi.fn(), vi.fn()), { initialProps: { s: ilk } });
    act(() => result.current.satirTikla(1, { shiftKey: false, ctrlKey: false, metaKey: false }));
    rerender({ s: ilk.map(x => ({ ...x })) });
    expect([...result.current.seciliSatirlar]).toEqual([2]);
  });
});
