import { describe, expect, it } from 'vitest';
import { ayAraligi, degisimRozeti } from '../sayfalar/performans/performansOrtak';

describe('hekim performans', () => {
  it('değişim rozeti eşiği ±%5', () => {
    expect(degisimRozeti(null)).toEqual({ ad: 'yeni', renk: 'pas' });
    expect(degisimRozeti(12.5)).toEqual({ ad: '▲ %12,5', renk: 'ok' });
    expect(degisimRozeti(-8).renk).toBe('kir');
    expect(degisimRozeti(2).renk).toBe('sari');
  });
  it('ay aralığı (şubat, artık yıl değil)', () => {
    expect(ayAraligi(2026, 2)).toEqual({ bas: '2026-02-01', bit: '2026-02-28' });
    expect(ayAraligi(2026, 12)).toEqual({ bas: '2026-12-01', bit: '2026-12-31' });
  });
});
