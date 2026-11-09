import { describe, expect, it, vi } from 'vitest';
import { bosSatir } from '../sayfalar/belgeSatir';
import { dovizKuruUygula } from '../sayfalar/belgeKalem';

// DÖVİZLİ LİSTE FİYATI -> YEREL FİYAT (kullanıcı 09.11.2026, satış teklifi #10302): EUR fiyatlı stok hızlı eklenince
//   (fiyat penceresi açılmadan) kur 1 kalıyor, TL birim fiyat EUR tutarına eşit kaydediliyordu. Kur artık stok
//   seçilirken çekilir; bütün belge kartları aynı yolu (stokSeciminiCoz) kullanır.
const dovizKur = vi.fn(async (_c?: string, _t?: string, _y?: number) => ({ dovizCinsi: 'EUR', tarih: '2026-11-09', kurTarihi: '2026-10-24', kur: 55.5997 }));
vi.mock('../api/istemci', () => ({
  api: {
    aramaIsaretle: vi.fn(),
    fiyatKalem: vi.fn(async () => ({ fiyat: 150, dovizCinsi: 'EUR', kdvDahil: 0 })),
    dovizKur: (cins: string, tarih: string, yon: number) => { dovizKur(cins, tarih, yon); return dovizKur.mock.results.at(-1)!.value },
  },
}));
import { stokSeciminiCoz } from '../sayfalar/belgeKarti/stokSecimi';

describe('dövizli liste fiyatı kuru', () => {
  it('dovizKuruUygula: yerel fiyat = döviz fiyatı × kur (2 hane), kur satıra yazılır', () => {
    const s = dovizKuruUygula({ ...bosSatir(1), dovizFiyat: '150', birimFiyat: '150', fiyatDovizi: 'EUR' }, 55.5997);
    expect(s.kur).toBe('55.5997');
    expect(s.birimFiyat).toBe('8339.96');
    expect(dovizKuruUygula({ ...bosSatir(1), dovizFiyat: '150' }, 0).birimFiyat).toBe('');
  });

  it('stokSeciminiCoz: EUR liste fiyatı pencere açılmadan da TL karşılığıyla gelir, kur belge tarihinden', async () => {
    const yeni = await stokSeciminiCoz({ tip: 'stok', id: 15, kod: 'X', ad: 'Cihaz' }, {
      satirlar: [], yerelPara: 'TL', tarafId: 5, odeyenKurumId: null, fiyatListesiId: 2, kampanyaId: null,
      basvuruBilgi: {} as never, belgeTarihi: '2026-11-09T16:45', alisMi: false,
    });
    expect(yeni.fiyatDovizi).toBe('EUR');
    expect(yeni.dovizFiyat).toBe('150');
    expect(yeni.kur).toBe('55.5997');
    expect(yeni.birimFiyat).toBe('8339.96');
    expect(dovizKur).toHaveBeenCalledWith('EUR', '2026-11-09', 1);
  });

  it('yerel parada liste fiyatı: kur çekilmez', async () => {
    dovizKur.mockClear();
    const { api } = await import('../api/istemci');
    (api.fiyatKalem as ReturnType<typeof vi.fn>).mockResolvedValueOnce({ fiyat: 200, dovizCinsi: 'TL', kdvDahil: 0 });
    const yeni = await stokSeciminiCoz({ tip: 'stok', id: 16, kod: 'Y', ad: 'Sarf' }, {
      satirlar: [], yerelPara: 'TL', tarafId: 5, odeyenKurumId: null, fiyatListesiId: 2, kampanyaId: null,
      basvuruBilgi: {} as never, belgeTarihi: '2026-11-09', alisMi: false,
    });
    expect(yeni.birimFiyat).toBe('200');
    expect(dovizKur).not.toHaveBeenCalled();
  });
});
