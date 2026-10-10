import { describe, expect, it } from 'vitest';
import { gun, labMarjRozeti, sure, yuzde } from '../sayfalar/labIcmal/labIcmalOrtak';

describe('laboratuvar icmali', () => {
  it('süre biçimi', () => {
    expect(sure(52)).toBe('52 dk');
    expect(sure(132)).toBe('2 sa 12 dk');
    expect(sure(2880)).toBe('2,0 gün');
    expect(sure(null)).toBe('—');
    expect(gun(4)).toBe('4,0 gün');
  });
  it('marj: maliyet tanımsızsa %100 göstermez', () => {
    expect(labMarjRozeti(100, 0).ad).toBe('maliyet yok');
    expect(labMarjRozeti(-10.5, 100)).toEqual({ ad: '%-10,5 zarar', renk: 'kir' });
    expect(labMarjRozeti(86.1, 50).renk).toBe('ok');
    expect(yuzde(72.34)).toBe('%72,3');
  });
});
