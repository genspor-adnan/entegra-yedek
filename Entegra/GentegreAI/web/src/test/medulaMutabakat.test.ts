import { describe, expect, it } from 'vitest';
import { faturaDurumRozeti, gecenAyYilAy, huniYuzde, itirazRozeti, nedenRozeti } from '../sayfalar/medula/mutabakat/mutabakatOrtak';

describe('medula mutabakat icmali', () => {
  it('faturasız nedeni ve yapılacak iş', () => {
    expect(nedenRozeti('hazir')).toMatchObject({ ad: 'Faturaya hazır', yapilacak: 'Faturala' });
    expect(nedenRozeti('hizmet_yok').renk).toBe('kir');
    expect(nedenRozeti('cikis_yok').ad).toBe('Takip çıkışı yok');
  });

  it('kod listesi rozetleri icmal renklerine', () => {
    expect(faturaDurumRozeti(6)).toEqual({ ad: 'Ödendi', renk: 'ok' });
    expect(faturaDurumRozeti(1).renk).toBe('pas');
    expect(itirazRozeti({ itirazDurum: 1 }).ad).toBe('İtiraz bekliyor');
    expect(itirazRozeti({ itirazDurum: 2 }).renk).toBe('ok');
  });

  it('huni yüzdesi ve varsayılan dönem', () => {
    expect(huniYuzde(3, 4)).toBe(75);
    expect(huniYuzde(0, 0)).toBe(0);
    expect(gecenAyYilAy(new Date(2026, 0, 10))).toEqual({ yil: 2025, ay: 12 });
  });
});
