import { describe, it, expect } from 'vitest';
import { KYS_EGITIM_LISTELERI } from '../sayfalar/listeTanimlari.KysEgitim';

/** KURUMSAL KALİTE — Eğitim (1056 / 1065): tek menü girdisi (sekmeli özel sayfa), listeler gizli. */
describe('kys eğitim listeleri', () => {
  it('kys.egitim menüde yalnız bir ekran açar', () => {
    const gorunen = KYS_EGITIM_LISTELERI.filter(l => !l.menuGizli);
    expect(gorunen.map(l => l.kaynak)).toEqual(['kys-egitimler']);
    expect(gorunen[0].ozelSayfa).toBe(true);
    // 1131: liste ekranlari kys.egitim.liste (yalniz Gor), kart kys.egitim.
    expect(KYS_EGITIM_LISTELERI.every(l => l.yetkiKodu === 'kys.egitim.liste' && l.modul === 'kys')).toBe(true);
  });

  it('her sekme var olan bir listeye gider ve ilk cip süzgeçtir', () => {
    const rotalar = new Set(KYS_EGITIM_LISTELERI.map(l => l.rota));
    for (const l of KYS_EGITIM_LISTELERI.filter(x => !x.ozelSayfa)) {
      const sekmeler = (l.cipler ?? []).filter(c => c.sekme);
      expect(sekmeler.map(c => c.rota)).toEqual(['kys-egitim', 'kys-egitim-eksik', 'kys-zorunlu-egitim']);
      sekmeler.forEach(c => expect(rotalar.has(c.rota)).toBe(true));
      expect(l.cipler?.[0]?.sekme).toBeFalsy();
    }
  });

  it('eğitim kartı özel kart (grup = birden çok personel_egitim satırı)', () => {
    const e = KYS_EGITIM_LISTELERI.find(l => l.kaynak === 'kys-egitim')!;
    expect(e.ozelKart).toBe(true);
    expect(e.kartYolu).toBe('/kys-egitim');
  });
});
