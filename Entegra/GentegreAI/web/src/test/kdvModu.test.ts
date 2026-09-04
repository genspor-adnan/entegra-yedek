import { describe, it, expect } from 'vitest';
import { kdvCarpani, matraha, bruta, moduCevir } from '../sayfalar/belgeKarti/kdvModu';

/**
 * KDV DAHIL / HARIC GIRIS MODU.
 *
 * Belgede saklanan birim fiyat HER ZAMAN MATRAHTIR; fiyat listeleri ise iki
 * turlu tutulur. Cevrim yapilmazsa %20 KDV'li bir kalem dogrudan %20 sapar ve
 * hata ancak faturada goze carpar - sessiz PARA hatasi.
 */
describe('kdvCarpani', () => {
  it('%20 -> 1,20', () => {
    expect(kdvCarpani(20)).toBe(1.2);
    expect(kdvCarpani('10')).toBe(1.1);
  });

  it('VERGISIZ (0 / bos / gecersiz) carpan 1 - bolme kazasi olmasin', () => {
    expect(kdvCarpani(0)).toBe(1);
    expect(kdvCarpani(null)).toBe(1);
    expect(kdvCarpani('')).toBe(1);
    expect(kdvCarpani('abc')).toBe(1);
    expect(kdvCarpani(-5)).toBe(1);
  });
});

describe('brut <-> matrah', () => {
  it('120 brut / %20 = 100 matrah', () => {
    expect(matraha(120, 20)).toBe(100);
    expect(bruta(100, 20)).toBe(120);
  });

  it('DORT HANE saklanir - erken yuvarlama toplamda kurus kaydirir', () => {
    // 100 / 1,18 = 84,745762...  ->  84,7458
    expect(matraha(100, 18)).toBeCloseTo(84.7458, 4);
    expect(matraha(100, 18)).not.toBe(84.75);
  });

  it('gidip gelince deger korunur (kurus altinda)', () => {
    const m = matraha(1000, 10);
    expect(bruta(m, 10)).toBeCloseTo(1000, 2);
  });

  it('vergisiz kalemde iki yon de ayni sayiyi verir', () => {
    expect(matraha(250, 0)).toBe(250);
    expect(bruta(250, 0)).toBe(250);
  });
});

describe('moduCevir - kutudaki metni karsi moda cevirir', () => {
  it('HARIC -> DAHIL: yazilan matrah brute yukselir', () => {
    expect(moduCevir('100', 20, true)).toBe('120');
  });

  it('DAHIL -> HARIC: yazilan brut matraha duser', () => {
    expect(moduCevir('120', 20, false)).toBe('100');
  });

  it('BOS metin bos kalir - kutu kendiliginden dolmasin', () => {
    expect(moduCevir('', 20, true)).toBe('');
    expect(moduCevir('   ', 20, false)).toBe('');
  });

  it('YARIM YAZIM oldugu gibi kalir - "12," yazarken kutu bozulmasin', () => {
    expect(moduCevir('12,', 20, true)).toBe('12,');
    expect(moduCevir('abc', 20, true)).toBe('abc');
  });

  it('VIRGULLU giris nokta gibi okunur', () => {
    expect(moduCevir('100,5', 0, true)).toBe('100.5');
  });
});
