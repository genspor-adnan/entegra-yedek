import { describe, expect, it } from 'vitest';
import { iadeTipiMi } from '../sayfalar/belgeTuru';

/**
 * `tipi = 2` her türde iade DEĞİL (sunucu BelgeYonuTestleri'nin web eşi). Kullanıcı
 * 24.10.2026: tipi 2 (Sayım Fazlası) giriş fişine satır eklerken "iade edilecek
 * kalemler" penceresi açıldı.
 */
describe('iadeTipiMi', () => {
  it.each([
    [3, 2, false],    // giriş fişi · sayım fazlası
    [4, 2, false],    // çıkış fişi · imha
    [19, 2, false],   // başvuru
    [20, 2, false],   // transfer
    [15, 2, true],    // satış iadesi
    [11, 2, true],    // alış iadesi
    [15, 1, false],
  ])('tür %i tipi %i -> %s', (tur, tipi, beklenen) => expect(iadeTipiMi(tur, tipi)).toBe(beklenen));
});
