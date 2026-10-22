import { describe, expect, it } from 'vitest';
import { cumleCoz, kimlikNiyetCoz } from '../sayfalar/kabuk/KomutPaleti';

/**
 * CTRL+K KİMLİK / TELEFON NİYETİ (kullanıcı 22.10.2026: "ctrl k aramada kimlikno/telno verip yeni
 * hasta/yeni başvuru/yeni personel diyebilirim yoksa yeni kart oluşturmalı").
 */
describe('kimlikNiyetCoz', () => {
  it('TC + niyet', () => {
    expect(kimlikNiyetCoz('12345678901 yeni hasta')).toEqual({ rakam: '12345678901', tur: 'tc', niyet: 'hasta' });
    expect(kimlikNiyetCoz('yeni personel 12345678901')?.niyet).toBe('personel');
    expect(kimlikNiyetCoz('12345678901 başvuru')?.niyet).toBe('basvuru');
    expect(kimlikNiyetCoz('12345678901 kabul')?.niyet).toBe('basvuru');
  });

  it('niyet sözcüğünün ilk 3 harfi yeter, "yeni" ve "kartı aç" isteğe bağlı', () => {
    expect(kimlikNiyetCoz('12345678901 has')?.niyet).toBe('hasta');
    expect(kimlikNiyetCoz('12345678901 baş')?.niyet).toBe('basvuru');
    expect(kimlikNiyetCoz('12345678901 per')?.niyet).toBe('personel');
    expect(kimlikNiyetCoz('12345678901 yeni hasta kartı aç')?.niyet).toBe('hasta');
  });

  it('niyetsiz numara: üç seçenek (niyet null)', () => {
    expect(kimlikNiyetCoz('12345678901')).toEqual({ rakam: '12345678901', tur: 'tc', niyet: null });
  });

  it('telefon yazımları: boşluklu, 0 / 90 / +90 önekli', () => {
    for (const y of ['5324445566', '0532 444 55 66', '+90 532 444 55 66', '905324445566', '(0532) 444-55-66'])
      expect(kimlikNiyetCoz(`${y} yeni personel`)?.tur).toBe('tel');
  });

  it('0 ile başlayan 11 hane TC değil telefondur', () => {
    expect(kimlikNiyetCoz('05324445566')?.tur).toBe('tel');
  });

  it('TC ya da cep olmayan numara kimlik komutu değildir (eski numara araması sürer)', () => {
    expect(kimlikNiyetCoz('A/00000041')).toBeNull();      // dosya no
    expect(kimlikNiyetCoz('2124445566 hasta')).toBeNull(); // sabit hat (5 ile başlamaz)
    expect(kimlikNiyetCoz('123456 hasta')).toBeNull();     // kısa
    expect(kimlikNiyetCoz('hasta listesi')).toBeNull();     // numara yok
  });

  it('tanınmayan sözcük varsa kimlik komutu değil', () => {
    expect(kimlikNiyetCoz('12345678901 randevu')).toBeNull();
    expect(kimlikNiyetCoz('12345678901 xy')).toBeNull();
  });

  it('kimlik niyeti cümle komutuyla çakışır; palet önce kimliği dener', () => {
    // cumleCoz bu metni "ad + modül" sanar - KomutPaleti kimlik niyeti varken cümle komutunu çalıştırmaz.
    expect(cumleCoz('11111111110 yeni hasta')).not.toBeNull();
    expect(kimlikNiyetCoz('11111111110 yeni hasta')).not.toBeNull();
  });
});
