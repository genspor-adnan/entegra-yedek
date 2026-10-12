import { describe, expect, it } from 'vitest';
import { dolulukRozeti, gunRozeti, marjRozeti, yuzde, yuzdeTam } from '../sayfalar/disIcmal/disIcmalOrtak';

describe('diş icmali', () => {
  it('marj rozeti', () => {
    expect(marjRozeti(null)).toEqual({ ad: '—', renk: 'pas' });
    expect(marjRozeti(83).renk).toBe('ok');
    expect(marjRozeti(70.8)).toEqual({ ad: '%70,8', renk: 'sari' });
    expect(marjRozeti(55).renk).toBe('kir');
  });
  it('doluluk ve gün rozeti', () => {
    expect(dolulukRozeti(57.1)).toEqual({ ad: '%57,1', renk: 'ok' });
    expect(dolulukRozeti(90).renk).toBe('kir');
    expect(dolulukRozeti(30).renk).toBe('sari');
    expect(gunRozeti(118).renk).toBe('kir');
    expect(gunRozeti(66)).toEqual({ ad: '66 gün', renk: 'sari' });
    expect(gunRozeti(47).renk).toBe('pas');
    expect(yuzde(null)).toBe('—');
    expect(yuzdeTam(66.33)).toBe('%66');
  });
});
