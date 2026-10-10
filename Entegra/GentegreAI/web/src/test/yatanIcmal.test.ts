import { describe, expect, it } from 'vitest';
import { beklemeRozeti, dolulukRozeti, gunMetni } from '../sayfalar/yatanIcmal/yatanIcmalOrtak';

describe('yatan hasta icmali', () => {
  it('doluluk rozeti: %85 sıkışık, %50 altı düşük', () => {
    expect(dolulukRozeti(95.8)).toEqual({ ad: '%95,8 sıkışık', renk: 'kir' });
    expect(dolulukRozeti(80.2).renk).toBe('ok');
    expect(dolulukRozeti(16.5).ad).toBe('%16,5 düşük');
    expect(dolulukRozeti(null).ad).toBe('—');
  });
  it('bekleme ve gün biçimi', () => {
    expect(beklemeRozeti(37).renk).toBe('kir');
    expect(beklemeRozeti(20).renk).toBe('sari');
    expect(beklemeRozeti(3).renk).toBe('pas');
    expect(gunMetni(3.94)).toBe('3,9');
  });
});
