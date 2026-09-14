import { describe, it, expect } from 'vitest';
import {
  type FiyatGirdisi, brutBirimFiyat, fiyattanOran, gosterimTabani,
  hedefBirimFiyat, iskontoKarsiligi, iskontoTabani, iskontoluBirim,
  iskontoVarMi, oranKirp,
} from '../sayfalar/belgeKarti/kalemFiyat';

/**
 * KALEM PENCERESİ FİYAT MATEMATİĞİ.
 *
 * Kural bileşenin içinde dururken üç hata buradan çıktı ("%10'u neden 16,67",
 * "birim fiyat boş geldi", 500 → 500,01). Saf modüle taşındı; testler o üç
 * durumu da kapsıyor - aynı hata sessizce geri gelmesin.
 */

/** Başvuru kalemi: KDV dahil çalışır, matrah 1.818,1818 (brüt 2.000). */
const temel: FiyatGirdisi = {
  fiyat: 1818.1818, brutMetni: '2.000,00', kdv: 10, kdvDahil: true,
  sgkKilitli: false, katkiTutar: null, iskonto: '0', iskonto2: '0',
};

describe('kalem fiyat matematigi', () => {
  it('gosterim tabani DAHIL modda BRUTTUR - sagdaki kutu da ondan hesaplar', () => {
    expect(gosterimTabani(temel)).toBeCloseTo(2000, 2);
    // "200'un %10'u neden 16,67": oran brut tabana isler, matraha degil.
    expect(iskontoKarsiligi({ ...temel, iskonto: '10' })).toBeCloseTo(200, 2);
    expect(hedefBirimFiyat({ ...temel, iskonto: '10' })).toBeCloseTo(1800, 2);
  });

  it('HARIC modda taban matrahtir', () => {
    const haric = { ...temel, kdvDahil: false };
    expect(gosterimTabani(haric)).toBeCloseTo(1818.1818, 4);
    expect(iskontoKarsiligi({ ...haric, iskonto: '10' })).toBeCloseTo(181.81818, 4);
  });

  it('brut metin BOSSA matrahtan turetilir (kuru satirda kutu bos kalmasin)', () => {
    // 3990'daki satirin sekli: kutu metni yok, yalniz matrah var.
    expect(brutBirimFiyat({ ...temel, brutMetni: '' })).toBeCloseTo(2000, 2);
    expect(brutBirimFiyat({ ...temel, brutMetni: undefined })).toBeCloseTo(2000, 2);
  });

  it('SAF SGK: iskonto SUT bedeline degil HASTA KATKISINA isler', () => {
    const sgk: FiyatGirdisi = { ...temel, sgkKilitli: true, katkiTutar: '500' };
    expect(iskontoTabani(sgk)).toBeCloseTo(500, 2);
    expect(gosterimTabani(sgk)).toBeCloseTo(550, 2);        // katki + %10 KDV
    expect(iskontoKarsiligi({ ...sgk, iskonto: '20' })).toBeCloseTo(110, 2);
  });

  it('hedef fiyattan orana: 2.000 -> 1.800 = %10', () => {
    expect(fiyattanOran(temel, 1800)).toBeCloseTo(10, 4);
  });

  it('hedef fiyat asil fiyattan BUYUKSE oran 0 - bu kutudan zam yapilamaz', () => {
    expect(fiyattanOran(temel, 2500)).toBe(0);
    expect(fiyattanOran(temel, 0)).toBe(0);
    // Taban sifirsa (fiyatsiz satir) oran uretilemez - bolme hatasi da olmaz.
    expect(fiyattanOran({ ...temel, fiyat: 0, brutMetni: '' }, 100)).toBe(0);
  });

  it('oran tavani ve %100 siniri her yoldan gecer', () => {
    expect(oranKirp(80, 25)).toBe(25);
    expect(oranKirp(-5, 25)).toBe(0);
    expect(oranKirp(250, 1000)).toBe(100);
  });

  it('iskontolu birim satir yuvarlamasiyla ayni - kurus artigi birakmaz', () => {
    const on = { ...temel, iskonto: '10' };
    expect(iskontoluBirim(on)).toBeCloseTo(1800, 2);
    expect(iskontoVarMi(on)).toBe(true);
    expect(iskontoVarMi(temel)).toBe(false);
  });
});
