import { describe, expect, it } from 'vitest';
import { filtreSatiriKosulu, sayiFiltresi } from '../bilesenler/gridSorgu';
import type { KolonMeta } from '../api/sozlesme';

/** SAYISAL BAŞLIK FİLTRESİ (kullanıcı 12.11.2026: stok listesi Kalan kolonunda filtre yoktu). */
describe('sayiFiltresi', () => {
  it('işleçler', () => {
    expect(sayiFiltresi('kalan', '>0')).toEqual({ alan: 'kalan', op: 'buyuk', deger: 0 });
    expect(sayiFiltresi('kalan', '>= 10')).toEqual({ alan: 'kalan', op: 'buyukEsit', deger: 10 });
    expect(sayiFiltresi('kalan', '<5')).toEqual({ alan: 'kalan', op: 'kucuk', deger: 5 });
    expect(sayiFiltresi('kalan', '<=3')).toEqual({ alan: 'kalan', op: 'kucukEsit', deger: 3 });
    expect(sayiFiltresi('kalan', '<>0')).toEqual({ alan: 'kalan', op: 'esitDegil', deger: 0 });
    expect(sayiFiltresi('kalan', '!=0')).toEqual({ alan: 'kalan', op: 'esitDegil', deger: 0 });
    expect(sayiFiltresi('kalan', '7')).toEqual({ alan: 'kalan', op: 'esit', deger: 7 });
    expect(sayiFiltresi('kalan', '-2,5')).toEqual({ alan: 'kalan', op: 'esit', deger: -2.5 });
  });
  it('aralık iki uç dahil, ters yazım düzelir', () => {
    expect(sayiFiltresi('kalan', '10..20')).toEqual({ alan: 'kalan', op: 'arasinda', deger: [10, 20] });
    expect(sayiFiltresi('kalan', '20..10')).toEqual({ alan: 'kalan', op: 'arasinda', deger: [10, 20] });
  });
  it('yarım / bozuk ifade süzmez', () => {
    expect(sayiFiltresi('kalan', '>')).toBeNull();
    expect(sayiFiltresi('kalan', 'abc')).toBeNull();
    expect(sayiFiltresi('kalan', '10..')).toBeNull();
  });
  it('filtre satırı sayısal kolonu da süzer', () => {
    const kolonlar = [{ ad: 'ad', tip: 'metin' }, { ad: 'kalan', tip: 'para' }] as KolonMeta[];
    expect(filtreSatiriKosulu({ ad: 'x', kalan: '>0' }, kolonlar)).toEqual({
      op: 'and', kosullar: [{ alan: 'ad', op: 'icerir', deger: 'x' }, { alan: 'kalan', op: 'buyuk', deger: 0 }],
    });
  });
});
