import { describe, expect, it } from 'vitest';
import { ebelgeDosyaAdi, ebelgeTurAdi } from '../sayfalar/ebelgeIslem';
import type { ListeSatiri } from '../api/sozlesme';

/**
 * KAYDET dosya adi kurali (kullanici): "<tür adı> <belge no> <cari adı ilk 2 kelime>".
 * PDF / HTML / XML adimlarinin hepsi bu adi kullanir; giden ve gelen belge ayni.
 */
describe('ebelgeDosyaAdi', () => {
  it('tür + belge no + carinin ilk iki kelimesi', () => {
    expect(ebelgeDosyaAdi('e-Arşiv', 'GNY2026000000009', '3EKSEN TEKNOLOJİ LTD.ŞTİ.'))
      .toBe('e-Arşiv GNY2026000000009 3EKSEN TEKNOLOJİ');
  });

  it('rozetteki onay isareti ada girmez', () => {
    expect(ebelgeDosyaAdi('e-Fatura ✓', 'DEF2026000000001', 'MATEK A.Ş.'))
      .toBe('e-Fatura DEF2026000000001 MATEK A.Ş.');
  });

  it('dosya sisteminde yasakli karakterler temizlenir, Türkçe harf korunur', () => {
    expect(ebelgeDosyaAdi('e-İrsaliye', 'GIR/2026:0001', 'ÖZ*GÜR "İNŞAAT" A.Ş.'))
      .toBe('e-İrsaliye GIR 2026 0001 ÖZ GÜR');
  });

  it('cari tek kelimeyse oldugu gibi kalir', () => {
    expect(ebelgeDosyaAdi('e-Arşiv', 'A1', 'Trendyol')).toBe('e-Arşiv A1 Trendyol');
  });

  it('hepsi bossa bos ad uretmez', () => {
    expect(ebelgeDosyaAdi('', '', '')).toBe('belge');
  });
});

describe('ebelgeTurAdi', () => {
  const satir = (x: Record<string, unknown>) => x as unknown as ListeSatiri;

  it('gelen kutusunda belgeTuruAdi kolonu', () => {
    expect(ebelgeTurAdi(satir({ belgeTuruAdi: 'e-Fatura' }))).toBe('e-Fatura');
  });

  it('satis faturasinda efatura rozeti', () => {
    expect(ebelgeTurAdi(satir({ efatura: 'e-Arşiv ✓' }))).toBe('e-Arşiv ✓');
  });

  it('irsaliyede eIrsaliye rozeti', () => {
    expect(ebelgeTurAdi(satir({ eIrsaliye: 'e-İrsaliye' }))).toBe('e-İrsaliye');
  });

  // "Kağıt" bir e-Belge turu DEGIL: hazirlanmamis belgede dosya adina girmemeli.
  it('kagit/bilinmiyor degeri tur sayilmaz', () => {
    expect(ebelgeTurAdi(satir({ efatura: 'Kağıt' }))).toBe('e-Belge');
    expect(ebelgeTurAdi(satir({ efatura: 'Bilinmiyor' }))).toBe('e-Belge');
  });
});
