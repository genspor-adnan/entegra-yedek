import { describe, expect, it } from 'vitest';
import { marjRozeti } from '../sayfalar/maliyet/maliyetOrtak';

describe('hasta başı maliyet', () => {
  it('marj rozeti eşikleri', () => {
    expect(marjRozeti(null, true).ad).toBe('—');
    expect(marjRozeti(-5, true)).toEqual({ ad: '%-5,0 zarar', renk: 'kir' });
    expect(marjRozeti(12, true).renk).toBe('sari');
    expect(marjRozeti(35, true).renk).toBe('mavi');
    expect(marjRozeti(80, true).renk).toBe('ok');
  });
  it('maliyet yoksa marj gri ve açıklamalı', () => {
    expect(marjRozeti(100, false)).toEqual({ ad: '%100,0 · maliyet yok', renk: 'pas' });
  });
});
