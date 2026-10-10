import { describe, expect, it } from 'vitest';
import { dolulukRozeti, grMarjRozeti } from '../sayfalar/goruntulemeIcmal/goruntulemeOrtak';

describe('görüntüleme icmali', () => {
  it('marj rozeti: maliyet yoksa %100 göstermez, eşikler 90 / 80', () => {
    expect(grMarjRozeti(100, 0).ad).toBe('maliyet yok');
    expect(grMarjRozeti(92, 10).renk).toBe('ok');
    expect(grMarjRozeti(85.1, 10)).toEqual({ ad: '%85,1', renk: 'sari' });
    expect(grMarjRozeti(-3, 10).renk).toBe('kir');
    expect(grMarjRozeti(null, 0).ad).toBe('—');
  });
  it('doluluk rozeti', () => {
    expect(dolulukRozeti(90).renk).toBe('kir');
    expect(dolulukRozeti(59.5)).toEqual({ ad: '%59,5', renk: 'ok' });
    expect(dolulukRozeti(20).renk).toBe('sari');
  });
});
