// @vitest-environment jsdom
import { describe, it, expect } from 'vitest';
import { act, renderHook } from '@testing-library/react';
import { useBasvuruAlanlari } from '../sayfalar/belgeKarti/useBasvuruAlanlari';

/**
 * BAŞVURU TÜRÜNÜN VARSAYILANI (779).
 *
 * Kullanıcı: *"başvuru türü varsayılan poliklinik olacak boş geçilemeyecek
 * (muayene modülü kullanılıyorsa)"*. Varsayılan üç ayrı kurulumda farklı
 * davranmak zorunda ve üçü de ekranda ancak o kurum profiliyle girilince
 * görülüyor - kural burada sabitlenir:
 *
 *   * muayene modülü açık poliklinik kurumu → Poliklinik (1),
 *   * lab / görüntüleme kurumu → "Laboratuvar / Görüntüleme" (5, 364),
 *   * muayene kapalı ve gönderen modu da yok → hiçbir şey damgalanmaz.
 */
describe('başvuru türü varsayılanı (779)', () => {
  it('muayene modülü açıkken POLİKLİNİK (1) gelir', () => {
    const { result } = renderHook(() =>
      useBasvuruAlanlari({ basvuruMu: true, gonderenModu: false, muayeneAcik: true }));
    expect(result.current.basvuruBilgi.basvuruTuru).toBe(1);
  });

  it('LAB / GÖRÜNTÜLEME kurumunda tür 5 kalır - Poliklinik damgalanmaz', () => {
    const { result } = renderHook(() =>
      useBasvuruAlanlari({ basvuruMu: true, gonderenModu: true, muayeneAcik: true }));
    expect(result.current.basvuruBilgi.basvuruTuru).toBe(5);
  });

  it('muayene modülü KAPALIYKEN tür boş bırakılır', () => {
    // Poliklinik yapmayan kuruma "Poliklinik" yazmak veri uydurmak olurdu.
    const { result } = renderHook(() =>
      useBasvuruAlanlari({ basvuruMu: true, gonderenModu: false, muayeneAcik: false }));
    expect(result.current.basvuruBilgi.basvuruTuru).toBeUndefined();
  });

  it('BAŞVURU DEĞİLSE (ERP siparişi) hiçbir tür yazılmaz', () => {
    const { result } = renderHook(() =>
      useBasvuruAlanlari({ basvuruMu: false, gonderenModu: false, muayeneAcik: true }));
    expect(result.current.basvuruBilgi.basvuruTuru).toBeUndefined();
  });

  it('SUNUCUDAN GELEN tür ezilmez - kayıtlı başvuru açıldığında', () => {
    // Kayıtlı başvuru okunduğunda `basvuruBilgi` tümüyle değişir; varsayılan
    //   efekti yalnız alan BOŞKEN yazar, yoksa "Yatan Hasta" başvurusu karta
    //   her girişte Poliklinik'e dönerdi.
    const { result } = renderHook(() =>
      useBasvuruAlanlari({ basvuruMu: true, gonderenModu: false, muayeneAcik: true }));
    act(() => { result.current.setBasvuruBilgi({ basvuruTuru: 3 }) });
    expect(result.current.basvuruBilgi.basvuruTuru).toBe(3);
  });
});
