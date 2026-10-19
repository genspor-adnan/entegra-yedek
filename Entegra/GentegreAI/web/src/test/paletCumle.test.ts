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
  });
  it('kalıp değilse null', () => {
    expect(cumleCoz('hasta listesi')).toBeNull();
    expect(cumleCoz('ab hasta')).toBeNull();
    expect(cumleCoz('randevu')).toBeNull();
  });
});
