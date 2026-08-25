import { describe, it, expect } from 'vitest';
import { alanEsit, degisenAlanlar, kartDegistiMi } from '../bilesenler/kartDegisim';
import type { KartAlanMeta } from '../api/sozlesme';

/**
 * GENEL KURAL (kullanici): "duzenle ile karta girip hicbir sey degistirmeden
 * kapatirsan degisiklik kaydetme sorusu sorma."
 *
 * Kurali bozan sey KATI (!==) karsilastirmaydi: ayni deger farkli yazimlarla
 * geliyor ve sahte fark uretiyordu. Asagidaki her vaka gercek bir kaynaktan
 * geliyor - regresyon olursa kullanici yine bosuna soru gorur.
 */
const alan = (tip: string) => ({ tip });

describe('alanEsit - sahte farklar', () => {
  it('sunucu ondaligi ile ekran yazimi ayni sayilir', () => {
    expect(alanEsit(alan('para'), '1.000000', '1')).toBe(true);   // doviz efekti yazar
    expect(alanEsit(alan('para'), '1500.0000', '1500')).toBe(true);
    expect(alanEsit(alan('sayi'), 12, '12')).toBe(true);
  });

  it('kod alaninda sayi/metin ayrimi yok, harfli kod metne duser', () => {
    expect(alanEsit(alan('kod'), 1, '1')).toBe(true);
    expect(alanEsit(alan('kod'), 'K', 'B')).toBe(false);
    expect(alanEsit(alan('kod'), 'K', 'K')).toBe(true);
  });

  it('bos degerin uc yazimi ayni', () => {
    expect(alanEsit(alan('metin'), null, '')).toBe(true);
    expect(alanEsit(alan('metin'), undefined, null)).toBe(true);
    expect(alanEsit(alan('metin'), '', undefined)).toBe(true);
  });

  it('bos ile dolu AYRI', () => {
    expect(alanEsit(alan('metin'), '', 'X')).toBe(false);
    expect(alanEsit(alan('sayi'), null, 0)).toBe(false);
  });

  it('tarih gune, zaman dakikaya kadar bakar', () => {
    expect(alanEsit(alan('tarih'), '2026-08-25T00:00:00', '2026-08-25')).toBe(true);
    expect(alanEsit(alan('zaman'), '2026-08-25T14:30:00', '2026-08-25T14:30')).toBe(true);
    expect(alanEsit(alan('zaman'), '2026-08-25T14:30', '2026-08-25T14:31')).toBe(false);
  });

  it('mantik alaninda false/undefined ayni', () => {
    expect(alanEsit(alan('mantik'), false, undefined)).toBe(true);
    expect(alanEsit(alan('mantik'), true, false)).toBe(false);
  });

  it('GERCEK farki kacirmaz', () => {
    expect(alanEsit(alan('para'), '1500', '1600')).toBe(false);
    expect(alanEsit(alan('metin'), 'Ahmet', 'Mehmet')).toBe(false);
  });

  it('metinde bas/son bosluk fark degildir', () => {
    expect(alanEsit(alan('metin'), ' Ahmet ', 'Ahmet')).toBe(true);
  });
});

const ALANLAR = [
  { ad: 'id', tip: 'sayi', yazilabilir: true },
  { ad: 'ad', tip: 'metin', yazilabilir: true },
  { ad: 'kur', tip: 'para', yazilabilir: true },
  { ad: 'musteri', tip: 'mantik', yazilabilir: true },
  { ad: 'olusturan', tip: 'metin', yazilabilir: false },
] as unknown as KartAlanMeta[];

describe('kartDegistiMi', () => {
  it('yalniz yazim farki varsa DEGISMEDI der', () => {
    expect(kartDegistiMi(ALANLAR,
      { ad: 'X', kur: '1', musteri: false },
      { ad: 'X', kur: '1.000000', musteri: undefined })).toBe(false);
  });

  it('gercek degisikligi yakalar', () => {
    expect(kartDegistiMi(ALANLAR, { ad: 'Y' }, { ad: 'X' })).toBe(true);
  });

  it('salt okunur alani ve id"yi saymaz', () => {
    expect(kartDegistiMi(ALANLAR, { olusturan: 'a', id: 1 }, { olusturan: 'b', id: 2 })).toBe(false);
  });

  it('meta yoksa degismedi sayar', () => {
    expect(kartDegistiMi(undefined, { ad: 'X' }, {})).toBe(false);
  });
});

describe('degisenAlanlar', () => {
  it('YENI kayitta bos alani hic gondermez', () => {
    // null gondermek NOT NULL + varsayilanli kolonlarda kaydi patlatiyordu.
    const g = degisenAlanlar({
      alanlar: ALANLAR, deger: { ad: 'Yeni', kur: '' }, ilkDeger: {}, yeniMi: true,
    });
    expect(g).toEqual({ ad: 'Yeni' });
  });

  it('YENI kayitta EKRANIN acikca false yaptigi bayragi gonderir', () => {
    // Sessizce atlanirsa katalog varsayilani devreye girip Tedarikci
    //   "musteri+tedarikci" olarak kaydediliyordu.
    const g = degisenAlanlar({
      alanlar: ALANLAR, deger: { ad: 'T', musteri: false }, ilkDeger: {},
      yeniMi: true, varsayilanlar: { musteri: false },
    });
    expect(g.musteri).toBe(false);
  });

  it('YENI kayitta ekran istemedigi bayragi atlar', () => {
    const g = degisenAlanlar({
      alanlar: ALANLAR, deger: { ad: 'T', musteri: false }, ilkDeger: {}, yeniMi: true,
    });
    expect(g).not.toHaveProperty('musteri');
  });

  it('DUZENLEMEDE temizlenen alan null gider', () => {
    const g = degisenAlanlar({
      alanlar: ALANLAR, deger: { ad: '', kur: '2' }, ilkDeger: { ad: 'X', kur: '2' },
      yeniMi: false,
    });
    expect(g.ad).toBeNull();
    expect(g).not.toHaveProperty('kur');       // degismeyen alan gonderilmez
  });

  it('id ve salt okunur alan govdeye girmez', () => {
    const g = degisenAlanlar({
      alanlar: ALANLAR, deger: { id: 9, olusturan: 'ben', ad: 'Y' },
      ilkDeger: { id: 1, olusturan: 'o', ad: 'X' }, yeniMi: false,
    });
    expect(g).toEqual({ ad: 'Y' });
  });
});
