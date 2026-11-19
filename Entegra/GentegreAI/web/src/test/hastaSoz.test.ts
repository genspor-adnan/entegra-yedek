import { describe, it, expect } from 'vitest';
import { sozNotu, sozRozeti, type HastaSoz } from '../bilesenler/borc/hastaSoz';

/** ÖDEME SÖZÜ / PLANI rozet ve tahsilat notu (19.11.2026): kalan, plan taksiti, tutulan gösterilmez. */
const soz = (k: Partial<HastaSoz>): HastaSoz => ({ id: 1, tur: 2, tutar: 1250, vade: '2026-11-25', durum: 'bekliyor', ...k });

describe('sozRozeti / sozNotu', () => {
  it('söz: kalan, tutulmadı, tutuldu', () => {
    expect(sozRozeti(soz({}))!.ad).toMatch(/Söz 25\.11 · 1\.250/);
    expect(sozRozeti(soz({ odenen: 850, kalan: 400 }))!.ad).toMatch(/kalan 400,00 .* \/ 1\.250/);
    const r = sozRozeti(soz({ durum: 'tutulmadi', odenen: 850, kalan: 400 }))!;
    expect(r.sinif).toBe('hata');
    expect(r.ad).toMatch(/tutulmadı \(25\.11\) · kalan 400/);
    expect(sozRozeti(soz({ durum: 'tutuldu' }))).toBeNull();
    expect(sozNotu(soz({ durum: 'tutuldu' }))).toBe('');
  });

  it('plan: ödenen taksit, sonraki, gecikme', () => {
    const p = soz({ tur: 3, taksitSayisi: 3, odenenTaksit: 1, sonrakiVade: '2026-12-05', sonrakiTutar: 300 });
    expect(sozRozeti(p)!.ad).toMatch(/Plan 1\/3 · sonraki 05\.12 \(300/);
    expect(sozNotu(p)).toMatch(/1\/3 taksit ödendi, sonraki 05\.12/);
    expect(sozRozeti({ ...p, durum: 'tutulmadi', gecikenTaksit: 2 })!.ad).toMatch(/2 taksit gecikti · 1\/3/);
  });
});
