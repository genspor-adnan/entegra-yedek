import { describe, expect, it } from 'vitest';
import { adimOzeti, bayraklariAyir } from '../bilesenler/onay/OnayAkisPanelleri';
import type { AkisDenemeAdimi } from '../api/uclar/onay';

// ONAY AKIŞI KARTI zincir önizlemesi (mockup Ekranlar/Onay/onay_akis_karti.html, 10.11.2026): deneme satırının rozeti.
const a = (y: Partial<AkisDenemeAdimi>): AkisDenemeAdimi =>
  ({ sira: 1, ad: 'Birim Sorumlusu', sahipTuru: 1, rol: 1, kullaniciId: null, sureGun: 3, esikAlt: null, bayrak: '', eImza: 0, ...y });
const rol = (r: number) => ({ 1: 'Birim sorumlusu', 4: 'Mali işler' }[r] ?? `rol ${r}`);

describe('adimOzeti', () => {
  it('rol basamağı, koşulsuz', () => {
    expect(adimOzeti(a({}), rol)).toBe('1. Birim Sorumlusu (Birim sorumlusu)');
  });
  it('eşik Türkçe binlik ayraçla', () => {
    expect(adimOzeti(a({ sira: 3, ad: 'Mali İşler', rol: 4, esikAlt: 50000 }), rol)).toBe('3. Mali İşler (Mali işler) ≥ 50.000');
  });
  it('bayrak ve sahip türleri', () => {
    expect(adimOzeti(a({ sira: 4, ad: 'Mali İşler (bütçe)', rol: 4, bayrak: 'butce' }), rol)).toBe('4. Mali İşler (bütçe) (Mali işler) ⚑ butce');
    expect(adimOzeti(a({ sahipTuru: 2 }), rol)).toContain('(kullanıcı)');
    expect(adimOzeti(a({ sahipTuru: 4 }), rol)).toContain('(kayıt sahibi)');
  });
});

describe('bayraklariAyir', () => {
  it('virgül ve boşluk ayraç, boşlar atılır', () => {
    expect(bayraklariAyir(' butce, butce_asildi  garanti ')).toEqual(['butce', 'butce_asildi', 'garanti']);
    expect(bayraklariAyir('')).toEqual([]);
  });
});

describe('adimOzeti eşik 0', () => {
  it('eşik 0 koşulsuz sayılır ("≥ 0" yazılmaz)', () => {
    expect(adimOzeti(a({ sira: 2, ad: 'Satınalma', rol: 2, esikAlt: 0 }), rol)).toBe('2. Satınalma (rol 2)');
  });
});
