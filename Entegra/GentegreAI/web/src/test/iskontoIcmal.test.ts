import { describe, expect, it } from 'vitest';
import { kaynakRozeti, oranMetni } from '../sayfalar/iskontoIcmal/iskontoIcmalOrtak';

describe('iskonto icmali', () => {
  it('kaynak rozetleri', () => {
    expect(kaynakRozeti('talep').ad).toBe('Onaylı talep');
    expect(kaynakRozeti('banko')).toEqual({ ad: 'Banko (talepsiz)', renk: 'sari' });
    expect(kaynakRozeti('karma').renk).toBe('mor');
  });
  it('oran metni', () => {
    expect(oranMetni(15.94)).toBe('%15,9');
    expect(oranMetni(10)).toBe('%10,0');
  });
});
