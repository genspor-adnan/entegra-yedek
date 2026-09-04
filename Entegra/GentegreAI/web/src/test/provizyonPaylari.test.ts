import { describe, it, expect } from 'vitest';
import { karsilamaUygula, katilimUygula } from '../sayfalar/belgeKarti/provizyonPaylari';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * Pay hesabi PARA hesabidir: yanlisi kuruma fazla / hastadan eksik yazar ve
 * hata ancak faturalamada goze carpar. Iki modun da kenar durumlari burada.
 */
const satir = (y: Partial<SatirDurumu> = {}): SatirDurumu =>
  ({ ...bosSatir(1), hizmetId: 900, satirTur: 2,
     adet: '1', birimFiyat: '1000', kdv: '10', ...y });

const say = (v?: string) => Number(v ?? '0');

describe('karsilamaUygula (289 - özel sigorta)', () => {
  it('%80 karsilamada kurum 800, hasta 200', () => {
    const { satirlar, toplamHasta, toplamKurum } = karsilamaUygula([satir()], 80);
    expect(say(satirlar[0].kurumTutar)).toBe(800);
    expect(say(satirlar[0].hastaTutar)).toBe(200);
    expect(toplamKurum).toBe(800);
    expect(toplamHasta).toBe(200);
  });

  it('%0 verilince TAMAMI hastaya yazilir (kendi öder)', () => {
    const { satirlar } = karsilamaUygula([satir()], 0);
    expect(say(satirlar[0].kurumTutar)).toBe(0);
    expect(say(satirlar[0].hastaTutar)).toBe(1000);
  });

  it('oran sinirlanir: 150 -> %100, -20 -> %0', () => {
    expect(say(karsilamaUygula([satir()], 150).satirlar[0].kurumTutar)).toBe(1000);
    expect(say(karsilamaUygula([satir()], -20).satirlar[0].kurumTutar)).toBe(0);
  });

  it('IKI PAYIN TOPLAMI satir tutarina esittir (kurus kaybi yok)', () => {
    // 333,33 x %33 -> kurum 110,00 (yuvarlanir), hasta KALAN olmali.
    const s = satir({ birimFiyat: '333.33' });
    const { satirlar } = karsilamaUygula([s], 33);
    const toplam = say(satirlar[0].kurumTutar) + say(satirlar[0].hastaTutar);
    expect(toplam).toBeCloseTo(333.33, 2);
  });

  it('iskontolu satirda INDIRIMLI tutar bolunur', () => {
    const s = satir({ birimFiyat: '1000', iskonto: '10' });   // 900
    const { satirlar } = karsilamaUygula([s], 50);
    expect(say(satirlar[0].kurumTutar)).toBe(450);
    expect(say(satirlar[0].hastaTutar)).toBe(450);
  });

  it('adet carpani hesaba girer', () => {
    const { satirlar } = karsilamaUygula([satir({ adet: '3' })], 100);
    expect(say(satirlar[0].kurumTutar)).toBe(3000);
  });

  it('uygulanan oran satirda saklanir (kart tekrar acilinca gorunur)', () => {
    expect(karsilamaUygula([satir()], 70).satirlar[0].karsilama).toBe('70');
  });
});

describe('katilimUygula (291 - SGK katılım payı)', () => {
  it('elle girilen katki hastaya, kalani kuruma', () => {
    const { satirlar, toplamHasta } = katilimUygula([satir()], 45);
    expect(say(satirlar[0].hastaTutar)).toBe(45);
    expect(say(satirlar[0].kurumTutar)).toBe(955);
    expect(toplamHasta).toBe(45);
  });

  it('elle verilmezse SATIRIN KENDI katilim payi kullanilir', () => {
    const s = satir({ katkiTutar: '20' });
    const { satirlar } = katilimUygula([s], null);
    expect(say(satirlar[0].hastaTutar)).toBe(20);
    expect(say(satirlar[0].kurumTutar)).toBe(980);
  });

  it('katilim payi satir tutarini ASAMAZ (ucuz kalem)', () => {
    const ucuz = satir({ birimFiyat: '30' });
    const { satirlar } = katilimUygula([ucuz], 45);
    expect(say(satirlar[0].hastaTutar)).toBe(30);
    expect(say(satirlar[0].kurumTutar)).toBe(0);
  });

  it('karsilama orani SIFIRLANIR (iki mod karismasin)', () => {
    const s = satir({ karsilama: '80' });
    expect(katilimUygula([s], 10).satirlar[0].karsilama).toBe('0');
  });

  it('cok satirda toplamlar birikir', () => {
    const { toplamHasta, toplamKurum } =
      katilimUygula([satir(), satir({ birimFiyat: '500' })], 25);
    expect(toplamHasta).toBe(50);          // 25 + 25
    expect(toplamKurum).toBe(1450);        // 975 + 475 (1000 ve 500 TL satir)
  });
});
