import { describe, it, expect } from 'vitest';
import { piradsKategorisi, piradsUygula, prostatHacmi } from './pirads';

const ALANLAR = [
  { alanKod: 'prostat_boyut' }, { alanKod: 'prostat_hacim' }, { alanKod: 'psa' }, { alanKod: 'psad' },
  { alanKod: 'zon', secenekler: 'Periferik zon|Transizyonel zon' },
  { alanKod: 't2', secenekler: '1|2|3|4|5' }, { alanKod: 'dwi', secenekler: '1|2|3|4|5' },
  { alanKod: 'dce', secenekler: 'Negatif|Pozitif' },
  { alanKod: 'pirads', secenekler: 'PI-RADS 1|PI-RADS 2|PI-RADS 3|PI-RADS 4|PI-RADS 5' },
];

describe('PI-RADS v2.1 (1380)', () => {
  it('periferik zon: DWI belirleyici, DWI 3 + DCE pozitif -> 4', () => {
    expect(piradsKategorisi(0, 2, 2, 0)).toBe(2);
    expect(piradsKategorisi(0, 5, 3, 0)).toBe(3);
    expect(piradsKategorisi(0, 5, 3, 1)).toBe(4);
    expect(piradsKategorisi(0, null, 4, null)).toBe(4);
    expect(piradsKategorisi(0, null, 5, 0)).toBe(5);
    expect(piradsKategorisi(0, 4, 3, null)).toBeNull();          // DWI 3'te DCE gerekli
    expect(piradsKategorisi(0, 4, null, 1)).toBeNull();
  });
  it('transizyonel zon: T2 belirleyici, v2.1 yükseltmeleri', () => {
    expect(piradsKategorisi(1, 1, 5, null)).toBe(1);
    expect(piradsKategorisi(1, 2, 3, null)).toBe(2);
    expect(piradsKategorisi(1, 2, 4, null)).toBe(3);             // T2 2 + DWI >= 4
    expect(piradsKategorisi(1, 3, 4, null)).toBe(3);
    expect(piradsKategorisi(1, 3, 5, null)).toBe(4);             // T2 3 + DWI 5
    expect(piradsKategorisi(1, 4, 2, null)).toBe(4);
    expect(piradsKategorisi(1, 5, 1, null)).toBe(5);
    expect(piradsKategorisi(1, 3, null, null)).toBeNull();
  });
  it('hacim elipsoid, PSA yoğunluğu ve kategori alanlara yazılır', () => {
    expect(prostatHacmi('45 x 38 x 40 mm')).toBe(35.6);          // 45*38*40*0.52/1000 = 35.568
    expect(prostatHacmi('4,5x3,8x4 cm')).toBe(35.6);
    expect(prostatHacmi('45x38')).toBeNull();
    let d: Record<string, string> = { psa: '7,2', prostat_boyut: '45x38x40' };
    d = piradsUygula(ALANLAR, d, 'prostat_boyut');
    expect(d.prostat_hacim).toBe('35,6');
    expect(d.psad).toBe('0,20');                                 // 7.2 / 35.6 = 0.202
    d = piradsUygula(ALANLAR, { ...d, zon: 'Periferik zon', dwi: '3', dce: 'Pozitif' }, 'dce');
    expect(d.pirads).toBe('PI-RADS 4');
    // İlgisiz alan: hekimin elle seçimi korunur.
    expect(piradsUygula(ALANLAR, { ...d, pirads: 'PI-RADS 3' }, 'epe').pirads).toBe('PI-RADS 3');
  });
});
