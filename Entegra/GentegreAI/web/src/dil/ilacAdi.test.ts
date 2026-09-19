import { describe, expect, it, beforeAll } from 'vitest';
import { ceviriYukle, ilacAdi } from './ceviri';

/**
 * İLAÇ ADI MOTORU (856) - marka ve doz DEĞİŞMEMELİ, yalnız farmasötik form
 * çevrilmeli. Sözlük sunucudan indiği için fetch taklit edilir.
 */
const SOZLUK = {
  ilac: {
    'film kapli tablet': 'film-coated tablet',
    'tablet': 'tablet',
    'adet': 'units',
    'enjeksiyonluk cozelti': 'solution for injection',
    'enjeksiyonluk cozelti iceren flakon': 'vial containing solution for injection',
    'flakon': 'vial',
    'iceren': 'containing',
    'parasetamol': 'paracetamol',
    'hidroklorotiyazid': 'hydrochlorothiazide',
    'telmisartan': 'telmisartan',
    'sodyum': 'sodium',
    'asetat': 'acetate',
    'trihidrat': 'trihydrate',
  },
};

beforeAll(async () => {
  globalThis.fetch = (async () =>
    ({ ok: true, json: async () => ({ sozluk: SOZLUK }) })) as unknown as typeof fetch;
  await ceviriYukle(1);
});

describe('ilacAdi', () => {
  it('marka ve dozu bırakır, formu çevirir', () => {
    expect(ilacAdi('MEDOVIR 100 MG FİLM KAPLI TABLET, 28 ADET'))
      .toBe('MEDOVIR 100 MG FILM-COATED TABLET, 28 UNITS');
  });

  it('Türkçe harf yazım farkını (FILM/FİLM) yakalar', () => {
    expect(ilacAdi('X 5 MG FILM KAPLI TABLET')).toBe('X 5 MG FILM-COATED TABLET');
  });

  it('en uzun ifadeyi seçer - sözcük sözcük çevirmez', () => {
    expect(ilacAdi('Y 1 G ENJEKSİYONLUK ÇÖZELTİ İÇEREN FLAKON'))
      .toBe('Y 1 G VIAL CONTAINING SOLUTION FOR INJECTION');
  });

  it('etken maddeyi tam ad olarak çevirir', () => {
    expect(ilacAdi('Parasetamol')).toBe('Paracetamol');
  });

  it('bileşen ayracı + ile de böler', () => {
    expect(ilacAdi('telmisartan+hidroklorotiyazid'))
      .toBe('telmisartan+hydrochlorothiazide');
  });

  it('tuz/hidrat sözcüklerini sözcük sözcük çözer', () => {
    expect(ilacAdi('sodyum asetat trihidrat')).toBe('sodium acetate trihydrate');
  });

  it('sözlükte olmayanı aynen bırakır', () => {
    expect(ilacAdi('ZZZBRAND 10 MG GARIP FORM')).toBe('ZZZBRAND 10 MG GARIP FORM');
  });

  it('Türkçede metni değiştirmez', async () => {
    await ceviriYukle(0);
    expect(ilacAdi('MEDOVIR 100 MG FİLM KAPLI TABLET, 28 ADET'))
      .toBe('MEDOVIR 100 MG FİLM KAPLI TABLET, 28 ADET');
    await ceviriYukle(1);
  });
});
