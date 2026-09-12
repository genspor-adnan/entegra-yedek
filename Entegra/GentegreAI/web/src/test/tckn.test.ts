import { describe, it, expect } from 'vitest';
import { tcknGecerliMi, bicimHatasi } from '../bilesenler/alanBicim';

/**
 * TCKN DOĞRULAMASI (NVİ algoritması) - sunucudaki `KimlikDogrulama` ile aynı
 * kural. Kuralın iki tarafta da bulunması bilinçli: sunucu sahibi, ekran
 * kullanıcıyı kaydetmeden önce uyarır. Test ikisinin AYNI cevabı verdiği
 * durumları sabitler.
 */
describe('TCKN doğrulaması', () => {
  it('boş değer geçerli sayılır (kimliği belirsiz hasta)', () => {
    expect(tcknGecerliMi('')).toBe(true);
    expect(tcknGecerliMi('   ')).toBe(true);
  });

  it('algoritmaya uyan numara geçerli', () => {
    // Kurgusal ama algoritmaya uygun numaralar (10. ve 11. hane hesaplanmış).
    expect(tcknGecerliMi('10000000146')).toBe(true);
    expect(tcknGecerliMi('19191919190')).toBe(true);
  });

  it('doğrulama hanesi tutmayan numara reddedilir', () => {
    expect(tcknGecerliMi('10000000148')).toBe(false);   // 11. hane yanlış
    expect(tcknGecerliMi('10000000156')).toBe(false);   // 10. hane yanlış
  });

  it('biçim kuralları: 11 hane, rakam, ilk hane sıfır olamaz', () => {
    expect(tcknGecerliMi('1000000014')).toBe(false);    // 10 hane
    expect(tcknGecerliMi('100000001466')).toBe(false);  // 12 hane
    expect(tcknGecerliMi('1000000014A')).toBe(false);   // harf
    expect(tcknGecerliMi('01234567890')).toBe(false);   // sıfırla başlıyor
  });

  it('bicimHatasi yalnız tckn kuralında konuşur', () => {
    expect(bicimHatasi('tckn', '10000000146')).toBeNull();
    expect(bicimHatasi('tckn', '11111111111')).not.toBeNull();
    // Kuralı olmayan alanda hiçbir şey söylemez.
    expect(bicimHatasi(null, '11111111111')).toBeNull();
    expect(bicimHatasi(undefined, 'abc')).toBeNull();
  });
});
