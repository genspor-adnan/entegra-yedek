import { describe, expect, it } from 'vitest';
import { dolulukRozeti, omurRozeti, yuzde } from '../sayfalar/sterilIcmal/sterilIcmalOrtak';

describe('sterilizasyon icmali', () => {
  it('doluluk rozeti', () => {
    expect(dolulukRozeti(null)).toEqual({ ad: 'kapasite tanımsız', renk: 'pas' });
    expect(dolulukRozeti(95).renk).toBe('kir');
    expect(dolulukRozeti(75.4)).toEqual({ ad: '%75,4', renk: 'ok' });
    expect(dolulukRozeti(30).renk).toBe('sari');
  });
  it('set ömrü rozeti', () => {
    expect(omurRozeti(179, 200).renk).toBe('sari');
    expect(omurRozeti(190, 200).renk).toBe('kir');
    expect(omurRozeti(100, 400)).toEqual({ ad: '100 / 400', renk: 'ok' });
    expect(omurRozeti(null, 400).ad).toBe('—');
    expect(yuzde(98.25)).toBe('%98,3');
  });
});
