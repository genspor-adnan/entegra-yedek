import { describe, expect, it } from 'vitest';
import { cariKartGovdesi, cariNiyetCoz } from '../sayfalar/kabuk/cariKomutu';
import { cumleCoz, kimlikNiyetCoz } from '../sayfalar/kabuk/KomutPaleti';

/** Ctrl+K "VKN + müşteri / tedarikçi kartı" (kullanıcı 25.10.2026). */
describe('cari komutu', () => {
  it('kullanıcının örnekleri tanınır', () => {
    for (const m of ['3850065757 müş', '3850065757 müşteri kart', '3850065757 müş kartı aç', '3850065757 musteri olustur',
                     'müş 3850065757 aç', '3850065757 yeni müşteri kartı'])
      expect(cariNiyetCoz(m), m).toEqual({ vkn: '3850065757', rol: 'musteri' });
    for (const m of ['3850065757 ted', '3850065757 tedarikçi kartı oluştur', '3850065757 TED KART AÇ'])
      expect(cariNiyetCoz(m), m).toEqual({ vkn: '3850065757', rol: 'tedarikci' });
    expect(cariNiyetCoz('12345678901 müşteri')).toEqual({ vkn: '12345678901', rol: 'musteri' });
  });

  it('rol yoksa ya da başka sözcük varsa kalıp değil (düz numara araması sürer)', () => {
    for (const m of ['3850065757', '3850065757 kart aç', '3850065757 hasta', '3850065757 mü', '385006575 müş',
                     '385006575712 müş', '3850065757 müş fatura'])
      expect(cariNiyetCoz(m), m).toBeNull();
  });

  it('hasta kimlik / cümle komutlarıyla çakışmaz', () => {
    expect(kimlikNiyetCoz('12345678901 müşteri')).toBeNull();
    expect(cumleCoz('3850065757 ted kart aç')).toBeNull();
    expect(cariNiyetCoz('12345678901 yeni hasta')).toBeNull();
  });

  it('kart gövdesi: rol bayrağı, e-Fatura, posta kutusu, fatura adresi', () => {
    const g = cariKartGovdesi('3850065757', 'tedarikci', {
      bulundu: true, mukellef: true, durum: 'Kayıtlı', unvan: 'ÖRNEK A.Ş.', vergiDairesi: 'Kadıköy',
      il: 'İSTANBUL', ilce: 'KADIKÖY', adres: 'Moda Cd. 1', alias: 'urn:mail:defaultpk@ornek.com', irsaliyeAlias: '', eirsaliye: false,
    }) as unknown as { kart: Record<string, unknown>; detaylar: { adresler: { eklenen: Record<string, unknown>[] } } };
    expect(g.kart).toMatchObject({ unvan: 'ÖRNEK A.Ş.', vkno: '3850065757', vd: 'Kadıköy', musteri: false, tedarikci: true,
                                   efatura: true, aliasEposta: 'urn:mail:defaultpk@ornek.com' });
    expect(g.detaylar.adresler.eklenen[0]).toMatchObject({ tur: 1, il: 'İSTANBUL', varsayilan: true });
  });
});
