import { describe, expect, it } from 'vitest';
import { dakika, dolulukRozeti, hucreYogunluk, noShowRozeti, sayi, yuzde } from '../sayfalar/randevuIcmal/randevuIcmalOrtak';

describe('randevu / poliklinik icmali', () => {
  it('doluluk rozeti', () => {
    expect(dolulukRozeti(null)).toEqual({ ad: 'plan yok', renk: 'pas' });
    expect(dolulukRozeti(64)).toEqual({ ad: '%64,0 düşük', renk: 'sari' });
    expect(dolulukRozeti(84.6)).toEqual({ ad: '%84,6', renk: 'ok' });
    expect(dolulukRozeti(97).renk).toBe('kir');
  });
  it('no-show rozeti', () => {
    expect(noShowRozeti(17.7).renk).toBe('kir');
    expect(noShowRozeti(11.5).renk).toBe('sari');
    expect(noShowRozeti(6.6)).toEqual({ ad: '%6,6', renk: 'ok' });
    expect(noShowRozeti(undefined).ad).toBe('—');
  });
  it('biçimler', () => {
    expect(yuzde(78.46)).toBe('%78,5');
    expect(sayi(5196)).toBe('5.196');
    expect(dakika(null)).toBe('—');
    expect(hucreYogunluk(120)).toBe(1);
    expect(hucreYogunluk(null)).toBeNull();
  });
});
