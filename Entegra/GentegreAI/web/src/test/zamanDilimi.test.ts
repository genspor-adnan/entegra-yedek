import { describe, expect, it, beforeEach } from 'vitest';
import { subeAyariniKur } from '../bilesenler/subeAyari';
import { gunMetni, tarihSaat } from '../bilesenler/bicim';

/**
 * ZAMAN DAMGASI GÖSTERİMİ (667 + 666).
 *
 * Sunucu artık AN gönderiyor ("2026-09-14T20:29:59Z"); ekran onu ŞUBENİN saat
 * diliminde göstermeli. Buradaki hata "işlem 3 saat önce yapılmış görünüyor"
 * ya da gece yarısı çevresinde "bir gün önce" olarak sahaya çıkar.
 */
const sube = (zamanDilimi: string) => ({
  id: 1, ad: 'Test', varsayilan: true, yazma: true,
  ulkeKod: 'TR', telefonKodu: '+90', zamanDilimi, paraBirimi: 'TRY',
});

describe('tarihSaat - zaman dilimi', () => {
  beforeEach(() => subeAyariniKur(sube('Europe/Istanbul')));

  it('UTC an, Istanbul subesinde +3 gosterilir', () => {
    expect(tarihSaat('2026-09-14T20:29:59Z')).toBe('14.09.2026 23:29');
  });

  it('ayni an Berlin subesinde +2 (yaz saati) gosterilir', () => {
    subeAyariniKur(sube('Europe/Berlin'));
    expect(tarihSaat('2026-09-14T20:29:59Z')).toBe('14.09.2026 22:29');
  });

  // Kis: Berlin +1. Yaz saatini "sabit fark" ile cozmeye calisan her yaklasim
  //   yilda iki kez yanlis olur - Intl takvimi bilir.
  it('kisin Berlin +1 olur (sabit fark degil)', () => {
    subeAyariniKur(sube('Europe/Berlin'));
    expect(tarihSaat('2026-01-14T20:29:59Z')).toBe('14.01.2026 21:29');
  });

  it('gece yarisini asan an DOGRU GUNU gosterir', () => {
    // 22:30 UTC = Istanbul'da ertesi gun 01:30.
    expect(tarihSaat('2026-09-14T22:30:00Z')).toBe('15.09.2026 01:30');
    expect(gunMetni('2026-09-14T22:30:00Z')).toBe('15.09.2026');
  });

  // Dilimsiz degerler GUNDUR (dogum tarihi, vade): Date'e cevirip kaydirmak
  //   dogum gununu bir gun geri alirdi.
  it('zaman dilimi olmayan deger oldugu gibi okunur', () => {
    expect(gunMetni('1985-01-01')).toBe('01.01.1985');
    expect(tarihSaat('2026-09-14T14:30:00')).toBe('14.09.2026 14:30');
  });

  it('bos deger', () => {
    expect(gunMetni(null)).toBe('—');
    expect(tarihSaat(null)).toBe('');
  });
});
