import { describe, it, expect } from 'vitest';
import { satirAcTuru } from '../sayfalar/liste/satirAc';

/**
 * SATIR AÇMA TABLOSU (refaktör B4): Liste.tsx'teki if / else merdiveninin yerine geçti. Buradaki eşleşmeler merdivendeki
 * davranışın aynısıdır - biri değişirse çift tık başka bir ekran açar.
 */
describe('listede satır açma türü', () => {
  it('belge üzerindeki yedi liste belge kartını açar', () => {
    for (const k of ['belge', 'irsaliye', 'stok-transfer', 'stok-talep', 'giris-fis', 'cikis-fis', 'satinalmaSiparis'])
      expect(satirAcTuru(k), k).toBe('belge');
  });
  it('özel pencereli listeler', () => {
    expect(satirAcTuru('kasa-islem')).toBe('kasaIslem');
    expect(satirAcTuru('cari-ekstre')).toBe('cariEkstre');
    expect(satirAcTuru('bankoOturum')).toBe('bankoOturum');
    expect(satirAcTuru('radyoloji-teslim')).toBe('raporTeslim');
    expect(satirAcTuru('gelen-belge')).toBe('gelenBelge');
  });
  it('tabloda olmayan liste kendi kart yoluna gider', () => {
    expect(satirAcTuru('cari')).toBeNull();
    expect(satirAcTuru('hasta')).toBeNull();
    expect(satirAcTuru('toString')).toBeNull();
  });
});
