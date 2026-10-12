import { describe, expect, it } from 'vitest';
import {
  dkFark, dolulukRozeti, ilkVakaMetni, marjRozeti, sapmaRozeti, sureMetni, yuzde,
} from '../sayfalar/ameliyathaneIcmal/ameliyathaneIcmalOrtak';

describe('ameliyathane icmali', () => {
  it('süre ve fark metni', () => {
    expect(sureMetni(110)).toBe('1 sa 50 dk');
    expect(sureMetni(45)).toBe('45 dk');
    expect(sureMetni(null)).toBe('—');
    expect(dkFark(40)).toBe('+40 dk');
    expect(dkFark(-10)).toBe('−10 dk');
    expect(dkFark(0)).toBe('±0 dk');
  });
  it('doluluk / sapma / marj rozetleri', () => {
    expect(dolulukRozeti(null)).toEqual({ ad: '—', renk: 'pas' });
    expect(dolulukRozeti(90).renk).toBe('kir');
    expect(dolulukRozeti(56.7)).toEqual({ ad: '%56,7', renk: 'ok' });
    expect(dolulukRozeti(13.9).renk).toBe('sari');
    expect(sapmaRozeti(-12).renk).toBe('kir');
    expect(sapmaRozeti(6.6).renk).toBe('sari');
    expect(sapmaRozeti(2.6).renk).toBe('ok');
    expect(marjRozeti(60.9).renk).toBe('sari');
    expect(marjRozeti(-5).renk).toBe('kir');
    expect(marjRozeti(null).ad).toBe('—');
    expect(yuzde(76.94)).toBe('%76,9');
  });
  it('ilk vaka metni', () => {
    expect(ilkVakaMetni(16, 22)).toBe('16 / 22 · %73');
    expect(ilkVakaMetni(0, 0)).toBe('—');
  });
});
