import { describe, expect, it } from 'vitest';
import { bicimHatasi, ibanGecerliMi } from '../bilesenler/alanBicim';

/** IBAN DOĞRULAMASI (1153, cari Banka / IBAN): ISO 13616 mod-97 - sunucu KimlikDogrulama.IbanGecerli ile aynı. */
describe('ibanGecerliMi', () => {
  it('geçerli TR ve yabancı IBAN (boşluklu da)', () => {
    expect(ibanGecerliMi('TR330006100519786457841326')).toBe(true);
    expect(ibanGecerliMi('TR33 0006 1005 1978 6457 8413 26')).toBe(true);
    expect(ibanGecerliMi('DE89370400440532013000')).toBe(true);
    expect(ibanGecerliMi('')).toBe(true);
  });
  it('kontrol hanesi, uzunluk ya da biçim bozuksa geçersiz', () => {
    expect(ibanGecerliMi('TR330006100519786457841327')).toBe(false);
    expect(ibanGecerliMi('TR33000610051978645784132')).toBe(false);
    expect(ibanGecerliMi('1234')).toBe(false);
    expect(ibanGecerliMi('TR33-0006-1005')).toBe(false);
  });
  it('alan biçim kuralı "iban" mesaj verir', () => {
    expect(bicimHatasi('iban', 'TR330006100519786457841326')).toBeNull();
    expect(bicimHatasi('iban', 'TR000006100519786457841326')).toContain('IBAN geçersiz');
  });
});
