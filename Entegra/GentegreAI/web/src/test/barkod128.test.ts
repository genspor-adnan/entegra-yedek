import { describe, expect, it } from 'vitest';
import { code128Desen, code128Saglama } from '../bilesenler/barkod128';

/**
 * CODE 128 (444) — kodlayıcı doğruluğu.
 *
 * Yanlış sağlama hanesi barkodu OKUNMAZ yapar ve bu sahada "etiket bastı ama
 * cihaz okumuyor" olarak görünür; hata etiketten değil kodlayıcıdan gelir.
 * Bu yüzden sağlama ve set geçişi burada sabitleniyor.
 */
describe('code128', () => {
  it('SET B sağlama hanesi ağırlıklı toplamla hesaplanır', () => {
    // "PJJ123C" · SET B · değerler P=48 J=42 J=42 1=17 2=18 3=19 C=35
    //   104 + 48·1 + 42·2 + 42·3 + 17·4 + 18·5 + 19·6 + 35·7 = 879
    //   879 mod 103 = 55
    const deger = [48, 42, 42, 17, 18, 19, 35];
    expect(code128Saglama(104, deger)).toBe(55);
  });

  it('çift haneli sayıda SET C kullanır (simge sayısı yarıya iner)', () => {
    // 10 hane: start + 5 çift + sağlama + stop + bitiş = 8·11 + 2 modül.
    const desen = code128Desen('2600000001');
    expect(desen.length).toBe(8 * 11 + 2);
    expect(desen.startsWith('11010011100')).toBe(true);   // START C
  });

  it('tek haneli sayıda ilk haneyi SET B ile yazıp C’ye geçer', () => {
    // 11 hane: start B + 1 hane + kod C + 5 çift + sağlama + stop = 10 simge.
    const desen = code128Desen('26000000013');
    expect(desen.length).toBe(10 * 11 + 2);
    expect(desen.startsWith('11010010000')).toBe(true);   // START B
  });

  it('yalnız 1 ve 0 üretir, çift ile başlayıp bitiş çubuğuyla kapanır', () => {
    const desen = code128Desen('26000000013');
    expect(/^[01]+$/.test(desen)).toBe(true);
    expect(desen.startsWith('11')).toBe(true);
    expect(desen.endsWith('11')).toBe(true);
  });

  it('sayısal olmayan metni SET B ile kodlar', () => {
    const desen = code128Desen('LAB-2026/1');
    // 10 karakter → start + 10 + sağlama + stop = 13 simge.
    expect(desen.length).toBe(13 * 11 + 2);
  });

  it('boş metinde çizim yapmaz', () => {
    expect(code128Desen('')).toBe('');
  });
});
