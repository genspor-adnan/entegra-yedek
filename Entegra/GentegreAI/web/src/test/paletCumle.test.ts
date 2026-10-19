import { describe, it, expect } from 'vitest';
import { cumleCoz } from '../sayfalar/kabuk/KomutPaleti';

/** CÜMLE KOMUTU (19.10.2026): "<ad soyad> <modül> [kartı] [aç]" - Ctrl+K ya da mikrofon. */
describe('palet cümle komutu', () => {
  it('ad ve modül ayrılır; kartı / aç isteğe bağlı', () => {
    expect(cumleCoz('Ercan Temel hasta kartı aç')).toMatchObject({ ad: 'Ercan Temel', modul: 'hasta' });
    expect(cumleCoz('ERcan Temel başvuru kartı aç')).toMatchObject({ ad: 'ERcan Temel', modul: 'basvuru' });
    expect(cumleCoz('ercan temel randevu kartını aç.')).toMatchObject({ ad: 'ercan temel', modul: 'randevu' });
    expect(cumleCoz('Ayşe Can reçete göster')).toMatchObject({ ad: 'Ayşe Can', modul: 'recete' });
    expect(cumleCoz('Ayşe Can tahlil')).toMatchObject({ modul: 'lab' });
    expect(cumleCoz('Ayşe Can muayene getir')).toMatchObject({ modul: 'muayene' });
    // Kısaltma: ilk 3+ harf.
    expect(cumleCoz('erhan savaş ran aç')).toMatchObject({ ad: 'erhan savaş', modul: 'randevu' });
    expect(cumleCoz('erhan savaş baş aç')).toMatchObject({ modul: 'basvuru' });
    expect(cumleCoz('erhan savaş mua')).toMatchObject({ modul: 'muayene' });
    expect(cumleCoz('erhan savaş reç kartı')).toMatchObject({ modul: 'recete' });
    // Ad yerine kimlik no / telefon / dosya no (sunucu numara olarak arar).
    expect(cumleCoz('12345678901 ran aç')).toMatchObject({ ad: '12345678901', modul: 'randevu' });
    expect(cumleCoz('0535 255 87 85 has')).toMatchObject({ ad: '0535 255 87 85', modul: 'hasta' });
    expect(cumleCoz('H-000080 başvuru kartı aç')).toMatchObject({ ad: 'H-000080', modul: 'basvuru' });
  });
  it('kalıp değilse null', () => {
    expect(cumleCoz('hasta listesi')).toBeNull();
    expect(cumleCoz('ab hasta')).toBeNull();
    expect(cumleCoz('randevu')).toBeNull();
    expect(cumleCoz('Ercan Temel')).toBeNull();           // ikinci sözcük modül değil
    expect(cumleCoz('erhan savaş ra')).toBeNull();        // 3 harften kısa
  });
});
