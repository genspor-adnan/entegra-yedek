import { describe, it, expect } from 'vitest';
import { liradsTablosu, liradsUygula } from './lirads';

const ALANLAR = [
  { alanKod: 'lezyon_cap' },
  { alanKod: 'aphe', secenekler: 'Yok|Var' }, { alanKod: 'washout', secenekler: 'Yok|Var' },
  { alanKod: 'kapsul', secenekler: 'Yok|Var' }, { alanKod: 'buyume', secenekler: 'Yok|Var' },
  { alanKod: 'ozel', secenekler: 'Yok|LR-1|LR-2|LR-M|LR-TIV|LR-NC' },
  { alanKod: 'lirads', secenekler: 'LR-1|LR-2|LR-3|LR-4|LR-5|LR-M|LR-TIV|LR-NC' },
];

describe('LI-RADS v2018 tanı tablosu (1380)', () => {
  // liradsTablosu(aphe, cap, washout, kapsul, buyume)
  it('APHE yok', () => {
    expect(liradsTablosu(false, 15, false, false, false)).toBe(3);
    expect(liradsTablosu(false, 15, true, false, false)).toBe(3);
    expect(liradsTablosu(false, 15, true, true, false)).toBe(4);
    expect(liradsTablosu(false, 25, false, false, false)).toBe(3);
    expect(liradsTablosu(false, 25, false, true, false)).toBe(4);
  });
  it('APHE var < 10 mm', () => {
    expect(liradsTablosu(true, 8, false, false, false)).toBe(3);
    expect(liradsTablosu(true, 8, true, false, false)).toBe(4);
    expect(liradsTablosu(true, 8, true, true, true)).toBe(4);
  });
  it('APHE var 10-19 mm: tek bulgu kapsülse LR-4, washout / büyümeyse LR-5', () => {
    expect(liradsTablosu(true, 15, false, false, false)).toBe(3);
    expect(liradsTablosu(true, 15, false, true, false)).toBe(4);
    expect(liradsTablosu(true, 15, true, false, false)).toBe(5);
    expect(liradsTablosu(true, 15, false, false, true)).toBe(5);
    expect(liradsTablosu(true, 15, false, true, true)).toBe(5);
  });
  it('APHE var >= 20 mm', () => {
    expect(liradsTablosu(true, 20, false, false, false)).toBe(4);
    expect(liradsTablosu(true, 32, false, true, false)).toBe(5);
  });
  it('alanlara yazılır; özel kategori tabloyu geçer; ilgisiz değişiklik elle seçimi korur', () => {
    let d: Record<string, string> = { aphe: 'Var', lezyon_cap: '15', washout: 'Var' };
    d = liradsUygula(ALANLAR, d, 'washout');
    expect(d.lirads).toBe('LR-5');
    d = liradsUygula(ALANLAR, { ...d, ozel: 'LR-M' }, 'ozel');
    expect(d.lirads).toBe('LR-M');
    expect(liradsUygula(ALANLAR, { ...d, lirads: 'LR-4' }, 'segment').lirads).toBe('LR-4');
    // APHE ya da çap yoksa (özel kategori de yoksa) yazılmaz.
    expect(liradsUygula(ALANLAR, { washout: 'Var' }, 'washout').lirads).toBeUndefined();
  });
});
