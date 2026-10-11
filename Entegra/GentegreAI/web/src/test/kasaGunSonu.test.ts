import { describe, expect, it } from 'vitest';
import { farkRozeti, gunKaydir, tutarCoz } from '../sayfalar/kasaGunSonu/kasaGunSonuOrtak';

const f = (n: number) => n.toFixed(2).replace('.', ',');
describe('kasa gün sonu', () => {
  it('fark rozeti', () => {
    expect(farkRozeti(null, f)).toEqual({ ad: 'sayım yok', renk: 'pas' });
    expect(farkRozeti(0, f).renk).toBe('ok');
    expect(farkRozeti(-50, f)).toEqual({ ad: '-50,00', renk: 'kir' });
    expect(farkRozeti(20, f)).toEqual({ ad: '+20,00', renk: 'sari' });
  });
  it('tutar çözme ve gün kaydırma', () => {
    expect(tutarCoz('1.234,56')).toBe(1234.56);
    expect(tutarCoz('500')).toBe(500);
    expect(tutarCoz('12.5')).toBe(12.5);
    expect(tutarCoz('')).toBeNull();
    expect(tutarCoz('abc')).toBeNull();
    expect(gunKaydir('2026-10-01', -1)).toBe('2026-09-30');
    expect(gunKaydir('2026-12-31', 1)).toBe('2027-01-01');
  });
});
