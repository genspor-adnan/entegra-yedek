import { describe, expect, it } from 'vitest';
import { belgeGovdesi, type BelgeGirdisi } from '../sayfalar/belgeKaydet';

/**
 * KVKK SMS ALANLARI GÖVDEYE GİRMEZ (1352, 17.11.2026): kvkkSmsTarihi / kvkkOnayKodu yalnız kendi uçlarından yazılır.
 * Gövdede kalınca sunucu "Bilinmeyen belge alanı" ile başvuru kaydını reddediyordu.
 */
describe('başvuru gövdesi - KVKK SMS alanları', () => {
  it('kvkkSmsTarihi ve kvkkOnayKodu gönderilmez, kvkkOnay / etkOnay gönderilir', () => {
    const girdi = {
      tur: 19, cari: { id: 5, unvan: 'H' }, tarih: '2026-11-17', basvuruMu: true,
      basvuruAlanlari: { kvkkOnay: 4, etkOnay: 4, kvkkOnayKodu: '123456', kvkkSmsTarihi: '2026-11-17T10:00:00Z' },
    } as unknown as BelgeGirdisi;
    const g = belgeGovdesi(girdi, [], false) as { belge: Record<string, unknown> };
    expect(g.belge.kvkkOnay).toBe(4);
    expect(g.belge.etkOnay).toBe(4);
    expect('kvkkOnayKodu' in g.belge).toBe(false);
    expect('kvkkSmsTarihi' in g.belge).toBe(false);
  });
});
