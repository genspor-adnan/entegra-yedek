import { describe, expect, it } from 'vitest';
import { basHarfler } from '../bilesenler/basHarfler';

// AVATAR HARF KURALI (03.11.2026): kişi = ad + soyad (ilk + son kelime); kurumsal (müş / ted / kurum) = unvanın 1. + 2. kelimesi.
describe('basHarfler', () => {
  it('kişi: ad + soyad, ünvan atılır', () => {
    expect(basHarfler('Ali Can Yılmaz')).toBe('AY');
    expect(basHarfler('Dr. Osman AKAR')).toBe('OA');
    expect(basHarfler('Prof. Dr. Ayşe Nur Öztürk')).toBe('AÖ');
  });
  it('kurumsal: ilk iki kelime', () => {
    expect(basHarfler('DEMİR İNŞAAT TAAHHÜT A.Ş.', true)).toBe('Dİ');
    expect(basHarfler('Ege Medikal Sanayi Ltd. Şti.', true)).toBe('EM');
    expect(basHarfler('ANKA', true)).toBe('AN');
    expect(basHarfler('', true)).toBe('?');
  });
});
