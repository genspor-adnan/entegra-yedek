import { describe, expect, it } from 'vitest';
import { alanCumleleri, alanCumlesi } from './raporBicimi';

describe('yapılandırılmış alan cümlesi (1217)', () => {
  const disk = { alanKod: 'l4l5', alanAd: 'L4-L5', kalip: 'L4-L5 düzeyinde {değer} izlenmiştir.' };
  it('değer cümle ortasında küçük harfle', () => {
    expect(alanCumlesi(disk, 'Sağ paramedian protrüzyon')).toBe('L4-L5 düzeyinde sağ paramedian protrüzyon izlenmiştir.');
  });
  it('normal değer: normal kalıbı ya da hiçbir şey', () => {
    expect(alanCumlesi(disk, 'Normal')).toBe('');
    expect(alanCumlesi({ alanKod: 'ocb', alanAd: 'ÖÇB', kalip: 'Ön çapraz bağda {değer} izlenmiştir.',
      sifirKalip: 'Ön çapraz bağ intakttır.' }, 'İntakt')).toBe('Ön çapraz bağ intakttır.');
  });
  it('kısaltma ve baştaki değer olduğu gibi', () => {
    expect(alanCumlesi({ alanKod: 'labrum', alanAd: 'Labrum', kalip: 'Glenoid labrumda {değer} izlenmiştir.' }, 'SLAP lezyonu'))
      .toBe('Glenoid labrumda SLAP lezyonu izlenmiştir.');
    expect(alanCumlesi({ alanKod: 'f', alanAd: 'Foramen', kalip: '{değer} nöral foraminal daralma izlenmiştir.' }, 'Sağda'))
      .toBe('Sağda nöral foraminal daralma izlenmiştir.');
  });
  it('kalıpsız alan ve sıra', () => {
    expect(alanCumleleri([{ alanKod: 'a', alanAd: 'Boyut', birim: 'mm' }, disk], { a: '12', l4l5: 'Ekstrüzyon' }))
      .toEqual(['Boyut: 12 mm.', 'L4-L5 düzeyinde ekstrüzyon izlenmiştir.']);
  });
});

describe('tiroid / karotis cümleleri (1218)', () => {
  it('TI-RADS kısaltma korunur, darlık yüzdeyle başlar', () => {
    expect(alanCumlesi({ alanKod: 't', alanAd: 'TI-RADS', kalip: 'Nodül ACR TI-RADS {değer} kategorisindedir.' }, 'TR4 (orta derecede şüpheli)'))
      .toBe('Nodül ACR TI-RADS TR4 (orta derecede şüpheli) kategorisindedir.');
    expect(alanCumlesi({ alanKod: 'd', alanAd: 'Sağ ICA', kalip: "Sağ ICA'da SRU kriterlerine göre {değer} ile uyumlu bulgular izlenmiştir.",
      sifirKalip: "Sağ ICA'da hemodinamik açıdan anlamlı darlık saptanmamıştır." }, '%50-69 darlık'))
      .toBe("Sağ ICA'da SRU kriterlerine göre %50-69 darlık ile uyumlu bulgular izlenmiştir.");
    expect(alanCumlesi({ alanKod: 'y', alanAd: 'Yer', kalip: 'En belirgin nodül {değer} kesimde yerleşimlidir.' }, 'İstmus'))
      .toBe('En belirgin nodül istmus kesimde yerleşimlidir.');
  });
});

describe('O-RADS / Bosniak cümleleri (1219)', () => {
  it('kategori ve taraf', () => {
    expect(alanCumlesi({ alanKod: 'o', alanAd: 'O-RADS', kalip: 'Lezyon O-RADS US {değer} kategorisindedir.' }, '3 (düşük risk)'))
      .toBe('Lezyon O-RADS US 3 (düşük risk) kategorisindedir.');
    expect(alanCumlesi({ alanKod: 'b', alanAd: 'Bosniak', kalip: '{değer} kategorisinde kistik lezyon.' }, 'Bosniak IIF'))
      .toBe('Bosniak IIF kategorisinde kistik lezyon.');
    expect(alanCumlesi({ alanKod: 'h', alanAd: 'Sağ hidronefroz', kalip: 'Sağ böbrekte {değer} hidronefroz izlenmiştir.' }, 'Grade 2'))
      .toBe('Sağ böbrekte grade 2 hidronefroz izlenmiştir.');
  });
});

describe('Fleischner / beyin MR cümleleri (1220)', () => {
  it('Fazekas baştaki değer, öneri küçük harf', () => {
    expect(alanCumlesi({ alanKod: 'f', alanAd: 'Fazekas',
      kalip: '{değer} ile uyumlu periventriküler ve derin beyaz cevher iskemik-gliotik değişiklikleri izlenmiştir.',
      sifirKalip: 'Beyaz cevherde patolojik sinyal değişikliği izlenmemiştir.' }, 'Fazekas 2'))
      .toBe('Fazekas 2 ile uyumlu periventriküler ve derin beyaz cevher iskemik-gliotik değişiklikleri izlenmiştir.');
    expect(alanCumlesi({ alanKod: 'f', alanAd: 'Fazekas', kalip: 'x', sifirKalip: 'Beyaz cevherde patolojik sinyal değişikliği izlenmemiştir.' },
      'Yok (Fazekas 0)')).toBe('Beyaz cevherde patolojik sinyal değişikliği izlenmemiştir.');
    expect(alanCumlesi({ alanKod: 'fl', alanAd: 'Fleischner', kalip: 'Fleischner 2017 kriterlerine göre: {değer}.' }, 'Rutin takip gerekmez'))
      .toBe('Fleischner 2017 kriterlerine göre: rutin takip gerekmez.');
  });
});
