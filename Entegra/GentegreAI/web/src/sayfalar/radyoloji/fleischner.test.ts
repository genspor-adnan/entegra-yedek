import { describe, expect, it } from 'vitest';
import { fleischnerOnerisi, fleischnerUygula } from './fleischner';

// 1220 + 1221 paket seçenekleri (sıra hesap içindir).
const alanlar = [
  { alanKod: 'nodul', secenekler: 'Yok|Tek|Multiple' },
  { alanKod: 'nodul_tip', secenekler: 'Solid|Parsiyel solid|Saf buzlu cam' },
  { alanKod: 'nodul_cap' }, { alanKod: 'solid_komp' },
  { alanKod: 'risk', secenekler: 'Düşük risk|Yüksek risk' },
  { alanKod: 'fleischner', secenekler: 'Rutin takip gerekmez|12. ayda isteğe bağlı BT|6-12. ayda BT, sonra 18-24. ayda BT düşünülebilir|'
    + '3-6. ayda BT, sonra 18-24. ayda BT|3. ayda BT, PET-BT ya da biyopsi düşünülmeli|6-12. ayda BT, kalıcıysa 5 yıla kadar 2 yılda bir BT|'
    + '3-6. ayda BT, kalıcı ve solid kısım 6 mm altıysa 5 yıl yıllık BT|Kriter uygulanmaz (tarama, kanser öyküsü, 35 yaş altı)|'
    + '3-6. ayda BT, stabilse 2. ve 4. yılda BT düşünülebilir|3-6. ayda BT, sonraki yönetim en şüpheli nodüle göre' },
];
const o = (nodul: string, tip: string, cap: string, ek: Record<string, string> = {}) =>
  fleischnerOnerisi(alanlar, { nodul, nodul_tip: tip, nodul_cap: cap, ...ek });

describe('Fleischner 2017', () => {
  it('solid tek', () => {
    expect(o('Tek', 'Solid', '4', { risk: 'Düşük risk' })).toBe(0);
    expect(o('Tek', 'Solid', '4', { risk: 'Yüksek risk' })).toBe(1);
    expect(o('Tek', 'Solid', '4')).toBeNull();          // risk grubu gerekli
    expect(o('Tek', 'Solid', '7')).toBe(2);
    expect(o('Tek', 'Solid', '8')).toBe(2);
    expect(o('Tek', 'Solid', '9')).toBe(4);
  });
  it('solid çoklu', () => {
    expect(o('Multiple', 'Solid', '5', { risk: 'Yüksek risk' })).toBe(1);
    expect(o('Multiple', 'Solid', '7')).toBe(3);
    expect(o('Multiple', 'Solid', '12')).toBe(3);
  });
  it('subsolid', () => {
    expect(o('Tek', 'Saf buzlu cam', '5')).toBe(0);
    expect(o('Tek', 'Saf buzlu cam', '6')).toBe(5);
    expect(o('Tek', 'Parsiyel solid', '8', { solid_komp: '4' })).toBe(6);
    expect(o('Tek', 'Parsiyel solid', '10', { solid_komp: '6' })).toBe(4);
    expect(o('Multiple', 'Saf buzlu cam', '4')).toBe(8);
    expect(o('Multiple', 'Parsiyel solid', '7')).toBe(9);
  });
  it('uygula: girdi değişince yazar, elle seçime dokunmaz', () => {
    const d = { nodul: 'Tek', nodul_tip: 'Solid', nodul_cap: '9' };
    expect(fleischnerUygula(alanlar, d, 'nodul_cap').fleischner).toBe('3. ayda BT, PET-BT ya da biyopsi düşünülmeli');
    const elle = { ...d, fleischner: 'Kriter uygulanmaz (tarama, kanser öyküsü, 35 yaş altı)' };
    expect(fleischnerUygula(alanlar, elle, 'fleischner')).toBe(elle);
  });
});
