import { describe, expect, it } from 'vitest';
import { dkMetni, slaRozeti, sureMetni, yuzde } from '../sayfalar/cagriIcmal/cagriIcmalOrtak';

describe('çağrı merkezi icmali', () => {
  it('süre biçimi', () => {
    expect(sureMetni(35)).toBe('35 sn');
    expect(sureMetni(221)).toBe('3 dk 41 sn');
    expect(sureMetni(4140)).toBe('1 sa 09 dk');
    expect(sureMetni(null)).toBe('—');
    expect(dkMetni(120)).toBe('2 sa 00 dk');
  });
  it('SLA rozeti hedefe göre', () => {
    expect(slaRozeti(85.9, 80).renk).toBe('ok');
    expect(slaRozeti(73.6, 80)).toEqual({ ad: '%73,6', renk: 'sari' });
    expect(slaRozeti(60, 80).renk).toBe('kir');
    expect(yuzde(91.7)).toBe('%91,7');
  });
});
