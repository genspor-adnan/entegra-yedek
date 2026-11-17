import { describe, expect, it } from 'vitest';
import { kvkkBilgiSatiri, kvkkKisa } from '../bilesenler/belge/basvuru/kvkkDurumu';

// KVKK onay geçerliliği (1353; mockup Ekranlar/Kayıt Kabul/kvkk_onay_gecerlilik.html).
describe('KVKK onay durumu metinleri', () => {
  it('geçerli onay: kaynak başvuru ve bitiş tarihi', () => {
    const s = kvkkBilgiSatiri({ durum: 'gecerli', kvkkOnay: 4, tarih: '2026-10-08', belgeNo: '000123', sube: 'Koşuyolu', kod: '482913', bitis: '2027-10-08' });
    expect(s?.sinif).toBe('g');
    expect(s?.metin).toContain('08.10.2026');
    expect(s?.metin).toContain('000123');
    expect(s?.metin).toContain("08.10.2027'e kadar");
  });
  it('süresi doldu / başka şube / ret / yok', () => {
    expect(kvkkBilgiSatiri({ durum: 'suresi_doldu', kvkkOnay: 3, tarih: '2025-10-01', belgeNo: '41', gun: 365 })?.sinif).toBe('s');
    expect(kvkkBilgiSatiri({ durum: 'baska_sube', sube: 'Kadıköy', tarih: '2026-11-03' })?.metin).toContain('Kadıköy');
    expect(kvkkBilgiSatiri({ durum: 'reddetti', kvkkOnay: 1, tarih: '2026-11-14', belgeNo: '140' })?.sinif).toBe('k');
    expect(kvkkBilgiSatiri({ durum: 'yok' })?.metin).toContain('onayı yok');
    expect(kvkkBilgiSatiri(null)).toBeNull();
  });
  it('kısa durum: bu başvurunun seçimi önce gelir', () => {
    expect(kvkkKisa(4, { durum: 'suresi_doldu' }).isaret).toBe('✓');
    expect(kvkkKisa(1, null).isaret).toBe('✗');
    expect(kvkkKisa(null, { durum: 'suresi_doldu' }).metin).toContain('Süresi doldu');
    expect(kvkkKisa(null, null).metin).toBe('Onay gerekli');
  });
});
