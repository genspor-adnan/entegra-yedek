import { describe, it, expect } from 'vitest';
import { iskontoEkranLimiti } from '../sayfalar/belgeKartiKurallari';

/**
 * İSKONTO EKRAN LİMİTİ (661 + 783).
 *
 * İki ayrı sınır var ve ikisi de geçerli: rolün TAVANI ("en çok % kaç") ve
 * kurumun ONAY EŞİĞİ ("bunun üstü onay ister, tavanın ne olursa olsun").
 * Küçüğü geçerli - yoksa tavanı %100 olan "İskonto Onaylayanlar" rolü (663)
 * sınırsız indirimi tek başına, onay zincirine hiç düşmeden yapardı. Kural
 * sunucuda tetikle korunuyor; buradaki hesap kullanıcıyı reddedilecek bir
 * oranı yazmaktan kurtarır.
 */
describe('iskontoEkranLimiti (783)', () => {
  it('eşik tavandan KÜÇÜKSE eşik geçerli', () => {
    expect(iskontoEkranLimiti(100, 10)).toBe(10);
    expect(iskontoEkranLimiti(25, 10)).toBe(10);
  });

  it('eşik tavandan BÜYÜKSE tavan geçerli - eşik kimseyi genişletmez', () => {
    expect(iskontoEkranLimiti(5, 10)).toBe(5);
  });

  it('eşik 0 / tanımsızsa kural kapalı: tavan aynen', () => {
    expect(iskontoEkranLimiti(30, 0)).toBe(30);
    expect(iskontoEkranLimiti(30)).toBe(30);
    expect(iskontoEkranLimiti(30, null)).toBe(30);
  });

  it('iskonto yetkisi yoksa (tavan 0) eşik onu açmaz', () => {
    expect(iskontoEkranLimiti(0, 10)).toBe(0);
  });
});
