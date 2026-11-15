import { describe, it, expect } from 'vitest';
import { karsitAlanUygula, karsitDolu } from '../bilesenler/karsitAlan';

// 1346 - randevu: gönderen seçilince "Kendi İsteği" kalkar, gönderen silinince geri gelir (kullanıcı 15.11.2026).
const alanlar = [{ ad: 'gonderenId', karsitAlan: null }, { ad: 'kendiIstegi', karsitAlan: 'gonderenId' }];

describe('karşıt alan (1346)', () => {
  it('karşıt alan dolunca işaret kalkar', () => {
    const d: Record<string, string | boolean> = { kendiIstegi: true, gonderenId: '' };
    karsitAlanUygula(alanlar, d, 'gonderenId', '42');
    expect(d.kendiIstegi).toBe(false);
  });
  it('karşıt alan boşalınca işaret geri gelir', () => {
    const d: Record<string, string | boolean> = { kendiIstegi: false, gonderenId: '42' };
    karsitAlanUygula(alanlar, d, 'gonderenId', '');
    expect(d.kendiIstegi).toBe(true);
  });
  it('başka alan değişince dokunulmaz', () => {
    const d: Record<string, string | boolean> = { kendiIstegi: true, gonderenId: '' };
    karsitAlanUygula(alanlar, d, 'hizmetId', '7');
    expect(d.kendiIstegi).toBe(true);
  });
  it('kutu karşıt alan doluyken kilitli; 0 / boş / false dolu sayılmaz', () => {
    expect(karsitDolu({ karsitAlan: 'gonderenId' }, { gonderenId: '42' })).toBe(true);
    expect(karsitDolu({ karsitAlan: 'gonderenId' }, { gonderenId: '0' })).toBe(false);
    expect(karsitDolu({ karsitAlan: 'gonderenId' }, { gonderenId: '' })).toBe(false);
    expect(karsitDolu({ karsitAlan: 'gonderenId' }, { gonderenId: false })).toBe(false);
    expect(karsitDolu({ karsitAlan: null }, { gonderenId: '42' })).toBe(false);
  });
});
