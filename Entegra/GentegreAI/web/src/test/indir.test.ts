import { describe, it, expect } from 'vitest';
import { dokumanDosyaAdi } from '../bilesenler/indir';

describe('dokumanDosyaAdi - indirme adi', () => {
  it('uzantisiz ada icerik tipinden uzanti ekler', () => {
    // Uzantisiz inen dosyayi isletim sistemi hicbir programla acamiyor.
    expect(dokumanDosyaAdi('PR-07 Numune Kabul Proseduru', 'application/pdf'))
      .toBe('PR-07 Numune Kabul Proseduru.pdf');
  });

  it('var olan uzantiyi TEKRARLAMAZ', () => {
    expect(dokumanDosyaAdi('rapor.pdf', 'application/pdf')).toBe('rapor.pdf');
  });

  it('dosya sisteminde gecersiz karakterleri temizler', () => {
    // Windows: ':' ya da '/' iceren ad indirmeyi sessizce basarisiz yapar.
    expect(dokumanDosyaAdi('12/03 Rapor: son', 'text/plain')).toBe('12-03 Rapor- son.txt');
  });

  it('tip bilinmiyorsa ad oldugu gibi kalir', () => {
    expect(dokumanDosyaAdi('belge', 'application/x-bilinmeyen')).toBe('belge');
  });

  it('ad bossa varsayilan ad', () => {
    expect(dokumanDosyaAdi('', 'image/png')).toBe('dokuman.png');
  });
});
