import { describe, it, expect } from 'vitest';
import { amniyonSinifi, hadlockAgirlik, obstetrikUygula } from './obstetrik';

const ALANLAR = [
  { alanKod: 'bpd' }, { alanKod: 'hc' }, { alanKod: 'ac' }, { alanKod: 'fl' }, { alanKod: 'efw' },
  { alanKod: 'afi' }, { alanKod: 'sdp' },
  { alanKod: 'amniyon', secenekler: 'Normal|Oligohidramnios|Polihidramnios' },
];

describe('obstetrik USG hesabı (1379)', () => {
  it('Hadlock HC+AC+FL: miada yakın fetüs ~3,5 kg', () => {
    // log10 = 1.326 - 0.00326·35·7.5 + 0.0107·34 + 0.0438·35 + 0.158·7.5 = 3.5520 -> 3565 g
    expect(hadlockAgirlik({ hc: 340, ac: 350, fl: 75 })).toBe(3565);
  });
  it('HC yoksa BPD+AC+FL, o da yoksa AC+FL formülü; AC ya da FL yoksa hesap yok', () => {
    const bpd = hadlockAgirlik({ bpd: 90, ac: 300, fl: 65 })!;
    const acfl = hadlockAgirlik({ ac: 300, fl: 65 })!;
    expect(bpd).toBeGreaterThan(2000); expect(bpd).toBeLessThan(2800);
    expect(acfl).toBeGreaterThan(2000); expect(acfl).toBeLessThan(2800);
    expect(hadlockAgirlik({ hc: 300, ac: 300 })).toBeNull();
  });
  it('amniyon ACOG eşikleri', () => {
    expect(amniyonSinifi(5, null)).toBe(1);          // AFI <= 5 oligo
    expect(amniyonSinifi(null, 1.8)).toBe(1);        // en derin cep < 2
    expect(amniyonSinifi(24, null)).toBe(2);         // AFI >= 24 poli
    expect(amniyonSinifi(null, 8)).toBe(2);
    expect(amniyonSinifi(12, 5)).toBe(0);
    expect(amniyonSinifi(null, null)).toBeNull();
  });
  it('yalnız girdi değişince yazar; sonuç seçeneklerden', () => {
    let d: Record<string, string> = { hc: '340', ac: '350', fl: '75' };
    d = obstetrikUygula(ALANLAR, d, 'fl');
    expect(d.efw).toBe('3565');
    d = obstetrikUygula(ALANLAR, { ...d, afi: '3,5' }, 'afi');
    expect(d.amniyon).toBe('Oligohidramnios');
    // Hekim sonucu elle değiştirdi, ilgisiz alan değişti: dokunulmaz.
    const elle = obstetrikUygula(ALANLAR, { ...d, amniyon: 'Normal', efw: '3400' }, 'plasenta');
    expect(elle.amniyon).toBe('Normal'); expect(elle.efw).toBe('3400');
  });
});
