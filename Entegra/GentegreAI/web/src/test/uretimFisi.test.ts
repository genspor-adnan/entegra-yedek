import { describe, expect, it } from 'vitest';
import { type FisSatiri, fisDurumAdi, fisMaliyeti, fisSatirlariniOranla } from '../api/uclar/uretimFisi';

// ÜRETİM FİŞİ (1253) - istemci tarafı maliyet ÖNİZLEMESİ sunucudaki GerceklestirAsync ile aynı formül (IAS 2):
//   ana ürün maliyeti = malzeme + işçilik / gider + normal fire − yan ürün; anormal fire mamule yüklenmez.
const s = (grup: 1 | 2 | 3 | 4, miktar: number, birimMaliyet: number, ek: Partial<FisSatiri> = {}): FisSatiri => ({
  sira: 0, grup, stokId: 1, stokKod: 'K', stokAd: 'A', izleme: 0, anaUrun: false, birimIhtiyac: 0, planMiktar: miktar, miktar,
  birim: 0, birimAdi: '', birimMaliyet, tutar: 0, elleMaliyet: false, fireTuru: 1, izlemler: null, aciklama: '', depoKalan: -1, ...ek,
});

describe('üretim fişi maliyeti (IAS 2)', () => {
  it('malzeme + işçilik + normal fire − yan ürün, anormal fire gidere', () => {
    const m = fisMaliyeti([
      s(1, 26, 2410), s(1, 2.5, 3200),                         // 62.660 + 8.000
      s(2, 12.5, 420),                                         // 5.250
      s(3, 1, 2410),                                           // normal fire 2.410
      s(3, 1, 500, { fireTuru: 2 }),                           // anormal 500 (gidere)
      s(4, 25, 0, { anaUrun: true }), s(4, 1.8, 605),          // yan ürün 1.089
    ]);
    expect(m.malzeme).toBe(70660);
    expect(m.iscilik).toBe(5250);
    expect(m.fireNormal).toBe(2410);
    expect(m.fireAnormal).toBe(500);
    expect(m.yanUrun).toBe(1089);
    expect(m.anaMaliyet).toBe(70660 + 5250 + 2410 - 1089);
    expect(m.birim).toBe(Math.round((70660 + 5250 + 2410 - 1089) / 25 * 1e4) / 1e4);
  });
  it('ana ürün yoksa birim 0', () => expect(fisMaliyeti([s(1, 1, 10)]).birim).toBe(0));
});

describe('miktar değişince oranlama (basit seviye)', () => {
  const l = [s(1, 0.7, 18000, { birimIhtiyac: 0.035 }), s(1, 5, 10, { birimIhtiyac: 0, aciklama: 'elle' }), s(2, 1, 6000), s(4, 20, 0, { anaUrun: true })];
  it('ağaçtan gelen sarf ve ana ürün oranlanır, elle eklenen ve elle gider kalır', () => {
    const y = fisSatirlariniOranla(l, 15);
    expect(y[0].miktar).toBe(0.525);
    expect(y[1].miktar).toBe(5);
    expect(y[2].miktar).toBe(1); expect(y[2].birimMaliyet).toBe(6000);
    expect(y[3].miktar).toBe(15);
  });
  it('ağaçtan gelen işçilik ana ürün oranıyla ölçeklenir: basit tek tutar, standart saat', () => {
    const tek = fisSatirlariniOranla([s(2, 1, 2400, { aciklama: 'operasyon: ağaçtan (8 saat)' }), s(4, 10, 0, { anaUrun: true })], 5);
    expect(tek[0].birimMaliyet).toBe(1200); expect(tek[0].tutar).toBe(1200);
    const saat = fisSatirlariniOranla([s(2, 8, 300, { birimAdi: 'Saat', aciklama: 'operasyon: Montaj' }), s(4, 10, 0, { anaUrun: true })], 20);
    expect(saat[0].miktar).toBe(16); expect(saat[0].tutar).toBe(4800);
  });
  it('oranlanan sarfın lot seçimi sıfırlanır', () => {
    const y = fisSatirlariniOranla([s(1, 2, 1, { birimIhtiyac: 1, izlemler: [{ seriLotId: 3, miktar: 2 }] })], 3);
    expect(y[0].izlemler).toBeNull();
  });
});

describe('fiş durum adı seviyeye göre', () => {
  it('2 basit / standartta stoğa işlendi, denetimlide karantina', () => {
    expect(fisDurumAdi(2, 'basit')).toBe('Stoğa işlendi');
    expect(fisDurumAdi(2, 'denetimli')).toBe('Karantina');
    expect(fisDurumAdi(3, 'denetimli')).toBe('Serbest');
    expect(fisDurumAdi(0, 'standart')).toBe('Ters kayıt');
  });
});
