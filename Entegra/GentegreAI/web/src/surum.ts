/**
 * UYGULAMA SÜRÜMÜ (tek doğruluk kaynağı).
 *
 * Biçim: YIL(2).AY.GÜN.BUILD  (ör. 26.10.17.2094)
 *   - tarih sürümün İÇİNDE; ayrıca sağda tarih GÖSTERİLMEZ.
 *   - BUILD = git commit sayısı (her yayında artar).
 *
 * DERLEMEDE ÜRETİLİR (vite.config.ts `__SURUM__`, 17.10.2026) - elle güncellenmez. Sol menü
 * "Oturum" bölümünde ve ana sayfanın selam satırında görünür.
 */
declare const __SURUM__: string | undefined;
export const SURUM = typeof __SURUM__ === 'string' ? __SURUM__ : '0.0.0.0';
export const SURUM_ETIKET = SURUM;
