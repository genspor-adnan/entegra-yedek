import { describe, expect, it } from 'vitest';
import { adet, itsSinifRozeti, kacakRozeti, miadRozeti, yuzde } from '../sayfalar/eczaneIcmal/eczaneIcmalOrtak';

describe('eczane / ilaç icmali', () => {
  it('kaçak oranı rozeti', () => {
    expect(kacakRozeti(null)).toEqual({ ad: '—', renk: 'pas' });
    expect(kacakRozeti(0.4)).toEqual({ ad: '%0,4', renk: 'ok' });
    expect(kacakRozeti(2.8).renk).toBe('sari');
    expect(kacakRozeti(3.3).renk).toBe('kir');
  });
  it('miad rozeti', () => {
    expect(miadRozeti({ durum: 'dolmuş', tuketilir: false })).toEqual({ ad: 'miadı doldu · imha', renk: 'kir' });
    expect(miadRozeti({ durum: '30', tuketilir: false }).renk).toBe('sari');
    expect(miadRozeti({ durum: '30', tuketilir: true }).renk).toBe('ok');
    expect(miadRozeti({ durum: '90', tuketilir: false }).ad).toBe('≤ 90 gün');
  });
  it('İTS sınıfı ve biçim', () => {
    expect(itsSinifRozeti('yetki').renk).toBe('kir');
    expect(itsSinifRozeti('').ad).toBe('—');
    expect(adet(4)).toBe('4');
    expect(adet(0.5)).toBe('0,50');
    expect(yuzde(98.25)).toBe('%98,3');
  });
});
