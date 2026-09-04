import { describe, it, expect } from 'vitest';
import {
  kdvCarpan, payKalan, payKalanDahil, tahsilDahil, onerilenTutar, matrahaCevir,
} from '../sayfalar/belgeDonusumHesap';
import type { AcikSatir } from '../api/sozlesme';

/**
 * TUTAR BAZLI DONUSUM HESABI (352).
 *
 * "Tahsil edilen KADAR fis" kurali PARA kuralidir ve iki yonu de yanlis olur:
 * fazla kesilirse belge tahsil edilenden cok kapanir (acik borc eksiye duser),
 * eksik kesilirse kurus acikta kalir. Sunucu matrahi 2 HANEYE yuvarlar,
 * ekran KDV DAHIL calisir - cevrim burada tek yerde yapiliyor.
 */
const satir = (y: Partial<AcikSatir> = {}): AcikSatir => ({
  satirId: 1, sira: 1, satirTur: 2, hizmetId: 900,
  miktar: 1, kapatilanMiktar: 0, kalanMiktar: 1,
  birimFiyat: 1000, iskonto: 0, kdv: 10,
  kurumTutar: 0, hastaTutar: 1000, kurumKalan: 0, hastaKalan: 1000,
  tutar: 1000, tutarKalan: 1000,
  hastaTahsilMatrah: 0, kurumTahsilMatrah: 0,
  ...y,
} as AcikSatir);

describe('matrahaCevir - sunucunun 2 haneli matrahiyla uyum', () => {
  it('500 TL tahsilat FAZLA fise donmez: matrah asagi yuvarlanir', () => {
    // 500 / 1,10 = 454,5454...  Sunucu 4 haneli 454,5455'i 454,55 yazip
    //   KDV'yi onun uzerinden hesapliyor ve fis 500,01 cikiyordu.
    const m = matrahaCevir(satir(), 500);
    expect(m).toBe(454.54);
    expect(Number((m * 1.1).toFixed(2))).toBeLessThanOrEqual(500);
  });

  it('sonuc her zaman KURUS (2 hane) - sunucu zaten kirpar', () => {
    for (const t of [500, 333.33, 1234.56, 0.05])
      expect(matrahaCevir(satir(), t)).toBe(
        Math.round(matrahaCevir(satir(), t) * 100) / 100);
  });

  it('KDV YOK ise tutar aynen matrahtir', () => {
    expect(matrahaCevir(satir({ kdv: 0 }), 500)).toBe(500);
  });

  it('TAHAKKUKTA kalanin tamami gonderilir - matrah BIREBIR geri doner', () => {
    // Kalan matrah 454,55 -> dahil 500,005 -> geri 454,55 olmali; kayan
    //   nokta artigi bir kurus asagi kaydirmamali.
    const s = satir({ hastaTutar: 454.55, hastaKalan: 454.55,
                      tutar: 454.55, tutarKalan: 454.55 });
    expect(matrahaCevir(s, payKalanDahil(s, 1))).toBe(454.55);
  });
});

describe('onerilenTutar - hangi belgeye ne kadar', () => {
  it('TAHAKKUKTA (17) kalanin TAMAMI onerilir, tahsilat sorulmaz', () => {
    expect(onerilenTutar(satir(), 17, 1)).toBeCloseTo(1100, 2);
  });

  it('FISTE tahsil edilen kadar - tahsilat yoksa 0 (donusum yapilmaz)', () => {
    expect(onerilenTutar(satir(), 16, 1)).toBe(0);
    expect(onerilenTutar(satir({ hastaTahsilMatrah: 454.55 }), 16, 1))
      .toBeCloseTo(500.005, 2);
  });

  it('tahsilat KALANDAN COKSA kalan ile sinirlanir (fazla fis kesilmez)', () => {
    const s = satir({ hastaKalan: 100, hastaTahsilMatrah: 900 });
    expect(onerilenTutar(s, 16, 1)).toBeCloseTo(110, 2);
  });
});

describe('pay hesabi', () => {
  it('KDV carpani satirin oranindan gelir', () => {
    expect(kdvCarpan(satir({ kdv: 20 }))).toBe(1.2);
    expect(kdvCarpan(satir({ kdv: 0 }))).toBe(1);
  });

  it('PAYSIZ satirda (289 oncesi kayit) satirin acik tutari kullanilir', () => {
    const s = satir({ kurumTutar: 0, hastaTutar: 0, hastaKalan: 0, tutarKalan: 750 });
    expect(payKalan(s, 1)).toBe(750);
  });

  it('paylasimli satirda secilen payin kalani gelir', () => {
    const s = satir({ kurumTutar: 800, hastaTutar: 200,
                      kurumKalan: 800, hastaKalan: 200 });
    expect(payKalan(s, 1)).toBe(200);
    expect(payKalan(s, 2)).toBe(800);
  });

  it('tahsil edilen tutar KDV DAHIL karsiligiyla okunur (dagitim tabani)', () => {
    expect(tahsilDahil(satir({ hastaTahsilMatrah: 100 }), 1)).toBeCloseTo(110, 4);
    expect(tahsilDahil(satir({ kurumTahsilMatrah: 200 }), 2)).toBeCloseTo(220, 4);
  });
});
