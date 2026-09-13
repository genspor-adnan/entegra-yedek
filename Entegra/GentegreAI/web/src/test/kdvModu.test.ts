import { describe, it, expect } from 'vitest';
import { baslangicBrutMetni, kdvCarpani, matraha, bruta, moduCevir, payBrute } from '../sayfalar/belgeKarti/kdvModu';

/**
 * KDV DAHIL / HARIC GIRIS MODU.
 *
 * Belgede saklanan birim fiyat HER ZAMAN MATRAHTIR; fiyat listeleri ise iki
 * turlu tutulur. Cevrim yapilmazsa %20 KDV'li bir kalem dogrudan %20 sapar ve
 * hata ancak faturada goze carpar - sessiz PARA hatasi.
 */
describe('kdvCarpani', () => {
  it('%20 -> 1,20', () => {
    expect(kdvCarpani(20)).toBe(1.2);
    expect(kdvCarpani('10')).toBe(1.1);
  });

  it('VERGISIZ (0 / bos / gecersiz) carpan 1 - bolme kazasi olmasin', () => {
    expect(kdvCarpani(0)).toBe(1);
    expect(kdvCarpani(null)).toBe(1);
    expect(kdvCarpani('')).toBe(1);
    expect(kdvCarpani('abc')).toBe(1);
    expect(kdvCarpani(-5)).toBe(1);
  });
});

describe('brut <-> matrah', () => {
  it('120 brut / %20 = 100 matrah', () => {
    expect(matraha(120, 20)).toBe(100);
    expect(bruta(100, 20)).toBe(120);
  });

  it('DORT HANE saklanir - erken yuvarlama toplamda kurus kaydirir', () => {
    // 100 / 1,18 = 84,745762...  ->  84,7458
    expect(matraha(100, 18)).toBeCloseTo(84.7458, 4);
    expect(matraha(100, 18)).not.toBe(84.75);
  });

  it('gidip gelince deger korunur (kurus altinda)', () => {
    const m = matraha(1000, 10);
    expect(bruta(m, 10)).toBeCloseTo(1000, 2);
  });

  it('vergisiz kalemde iki yon de ayni sayiyi verir', () => {
    expect(matraha(250, 0)).toBe(250);
    expect(bruta(250, 0)).toBe(250);
  });
});

describe('moduCevir - kutudaki metni karsi moda cevirir', () => {
  it('HARIC -> DAHIL: yazilan matrah brute yukselir', () => {
    expect(moduCevir('100', 20, true)).toBe('120');
  });

  it('DAHIL -> HARIC: yazilan brut matraha duser', () => {
    expect(moduCevir('120', 20, false)).toBe('100');
  });

  it('BOS metin bos kalir - kutu kendiliginden dolmasin', () => {
    expect(moduCevir('', 20, true)).toBe('');
    expect(moduCevir('   ', 20, false)).toBe('');
  });

  it('YARIM YAZIM oldugu gibi kalir - "12," yazarken kutu bozulmasin', () => {
    expect(moduCevir('12,', 20, true)).toBe('12,');
    expect(moduCevir('abc', 20, true)).toBe('abc');
  });

  it('VIRGULLU giris nokta gibi okunur', () => {
    expect(moduCevir('100,5', 0, true)).toBe('100.5');
  });
});

describe('payBrute - kurum / hasta payi gosterimi', () => {
  it('MATRAH payi satirin brut oraniyla cevrilir', () => {
    // 114377: tutar 2.000 matrah / 2.200 brut; kurum 1.600 -> 1.760.
    expect(payBrute(1600, 2000, 2200)).toBe(1760);
    expect(payBrute(400, 2000, 2200)).toBe(440);
  });

  it('iki pay toplami BRUT TUTARA esit kalir', () => {
    const brut = payBrute(1600, 2000, 2200) + payBrute(400, 2000, 2200);
    expect(brut).toBe(2200);
  });

  it('KDV orani DEGIL tutar orani kullanilir - iskontolu satirda da tutar', () => {
    // Iskonto brut tutara zaten islenmis: 1.000 matrah / 1.045 brut (%10 KDV,
    //   %5 iskonto sonrasi) -> yarim pay 522,50.
    expect(payBrute(500, 1000, 1045)).toBe(522.5);
  });

  it('tutar 0 ise deger AYNEN doner (bos satir)', () => {
    expect(payBrute(400, 0, 0)).toBe(400);
  });
});

describe('baslangicBrutMetni - kalem penceresi acilis fiyati', () => {
  it('basvuruda kart fiyati (kdvDahil bayragi YOK) brute cevrilir', () => {
    // ILAC/STOK kart fiyatiyla gelen kalem: satirda matrah durur, bayrak 0.
    //   Basvuruda kutu dahil modda acildigi icin brut gosterilmeli - eskiden
    //   bos kaliyordu ("fiyat gelmedi").
    expect(baslangicBrutMetni({ birimFiyat: '135', kdv: 10 }, true)).toBe('148.5');
  });

  it('fiyat listesinden gelen kalem (kdvDahil=1) basvuru disinda da dolar', () => {
    expect(baslangicBrutMetni({ birimFiyat: '100', kdv: 20, kdvDahil: 1 }, false))
      .toBe('120');
  });

  it('dahil modda degilse BOS - kutu haric fiyati gosterir', () => {
    expect(baslangicBrutMetni({ birimFiyat: '100', kdv: 20 }, false)).toBe('');
  });

  it('dovizli kalemde doviz fiyati okunur', () => {
    expect(baslangicBrutMetni(
      { birimFiyat: '100', dovizFiyat: '10', fiyatDovizi: 'USD', kdv: 20 }, true))
      .toBe('12');
  });

  it('fiyatsiz kalem bos kalir', () => {
    expect(baslangicBrutMetni({ birimFiyat: '', kdv: 10 }, true)).toBe('');
  });
});

/**
 * KURUS GERI GELMEZ (kullanici: "fiyat ekranina 500 girdim, onizlemede
 * 500,01 gorundu; kaydedince gridde de 500,01").
 *
 * Dahil modunda yazilan sayi BRUTTUR. Matraha cevrilip satir tutari
 * yuvarlaninca (%10'da 500 -> 454,5455 -> 454,55) ters yone gitmek kurusu
 * geri getirmiyor: 454,55 x 1,10 = 500,005 -> 500,01. Onizleme, kalem
 * gridi ve dip toplam artik brutu TABAN alir; sunucu da ayni kurali izler
 * (dip toplamda KDV = brut tutar - matrah tutar).
 *
 * 1000 TL bu hatayi GIZLIYORDU (909,09 x 1,10 = 999,999 -> 1000,00) - hatayi
 * gorunur kilan tutari da birlikte tutmak, duzeltmenin geri alinmasini
 * zorlastirir.
 */
describe('brut <-> matrah cevriminde kurus kaymasi', () => {
  const satirTutariniYuvarla = (n: number) => Math.round(n * 100) / 100;

  it('%10 KDV, 500 TL brut: satir tutarini carpmak 500,01 verir - brut taban 500,00', () => {
    // ESKI YOL: once SATIR TUTARI yuvarlanir (2 hane), sonra KDV orani
    //   uygulanir. Kurus tam burada kayboluyor.
    const satirMatrah = satirTutariniYuvarla(matraha(500, 10));   // 454,55
    expect(satirTutariniYuvarla(satirMatrah * 1.1)).toBeCloseTo(500.01, 2);
    // YENI YOL: brut fiyat taban, yuvarlama ONA uygulanir.
    expect(satirTutariniYuvarla(bruta(matraha(500, 10), 10))).toBeCloseTo(500, 2);
  });

  it('1000 TL ayni oranda dogru cikiyordu - hata her tutarda gorunmuyor', () => {
    const satirMatrah = satirTutariniYuvarla(matraha(1000, 10));  // 909,09
    expect(satirTutariniYuvarla(satirMatrah * 1.1)).toBeCloseTo(1000, 2);
    expect(satirTutariniYuvarla(bruta(matraha(1000, 10), 10))).toBeCloseTo(1000, 2);
  });

  it('%20 KDV, 500 TL brut de brut tabanla birebir doner', () => {
    expect(satirTutariniYuvarla(bruta(matraha(500, 20), 20))).toBeCloseTo(500, 2);
  });
});
