import { describe, it, expect } from 'vitest';
import { yerelGun } from '../bilesenler/bicim';
import { isoGun } from '../sayfalar/hasta/icmal/icmalOrtak';

/**
 * YEREL GÜN (19.11.2026, gece testi yakaladı): `toISOString().slice(0, 10)` UTC'dir - Türkiye'de (UTC+3) 00:00-03:00
 * arası ve yerel gece yarısında kurulan tarihlerde bir önceki günü veriyordu (takvim "bugün", gün sonu, servis
 * çizelgesi ‹ ›, devir formu gün ekleme). Yerel gün, saatten bağımsız takvim günüdür.
 */
describe('yerelGun', () => {
  it('yerel gece yarısı ve gece 00:30 aynı takvim günü', () => {
    expect(yerelGun(new Date(2026, 10, 20, 0, 0))).toBe('2026-11-20');
    expect(yerelGun(new Date(2026, 10, 20, 0, 30))).toBe('2026-11-20');
    expect(yerelGun(new Date(2026, 10, 20, 23, 59))).toBe('2026-11-20');
    expect(isoGun(new Date(2026, 0, 1, 0, 5))).toBe('2026-01-01');
  });

  it('gün ekleme (yerel gece yarısından) bir sonraki günü verir', () => {
    const d = new Date('2026-11-20T00:00:00'); d.setDate(d.getDate() + 1);
    expect(yerelGun(d)).toBe('2026-11-21');
  });
});
