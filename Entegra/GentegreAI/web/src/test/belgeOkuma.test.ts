import { describe, it, expect } from 'vitest';
import { yanittanBaslik, yanittanBasvuruBilgi } from '../sayfalar/belgeKarti/belgeOkuma';

/**
 * SUNUCU YANITI -> KART DURUMU cevrimi.
 *
 * Cevrim hatalari SESSIZDIR: yanlis kirpilmis bir tarih ya da `null` yerine
 * yazilmis bir `0` ekranda dogru gorunur, hata ancak belge yeniden
 * kaydedilince (kaymis saat, yanlis kurum, kaybolmus depo) ortaya cikar.
 */
const bos = { tur: 15, tarafId: 5, tarafUnvan: 'Ali Veli' };

describe('yanittanBaslik - tarih', () => {
  it('16 karaktere kirpilir (datetime-local kutusu saniye kabul etmez)', () => {
    const d = yanittanBaslik({ ...bos, belgeTarihi: '2026-09-04T10:30:59.123' }, 'TRY');
    expect(d.tarih).toBe('2026-09-04T10:30');
  });

  it('BOS tarihli (eski/dis kaynakli) belgede SIMDIKI AN gelir - alan bos kalmaz', () => {
    const d = yanittanBaslik({ ...bos, belgeTarihi: null }, 'TRY');
    expect(d.tarih).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/);
  });

  it('sevk tarihi yoksa BOS METIN olur (null degil - kutu kontrollu kalsin)', () => {
    expect(yanittanBaslik(bos, 'TRY').sevkTarihi).toBe('');
    expect(yanittanBaslik({ ...bos, irsaliyeTarihi: '2026-09-04T08:00:00' }, 'TRY').sevkTarihi)
      .toBe('2026-09-04T08:00');
  });
});

describe('yanittanBaslik - depo (transfer takasi)', () => {
  const depolu = { cikisDepoId: 1, cikisDepoAdi: 'Ana', girisDepoId: 2, girisDepoAdi: 'Şube' };

  it('TRANSFERDE (20) depo CIKIS deposudur, giris ayri alanda durur', () => {
    const d = yanittanBaslik({ ...bos, tur: 20, ...depolu }, 'TRY');
    expect(d.depo).toEqual({ id: 1, ad: 'Ana' });
    expect(d.girisDepo).toEqual({ id: 2, ad: 'Şube' });
  });

  it('ALIS belgesinde GIRIS deposu tek depo alanina yansir', () => {
    const d = yanittanBaslik({ ...bos, tur: 11, ...depolu }, 'TRY');
    expect(d.depo).toEqual({ id: 2, ad: 'Şube' });
    expect(d.girisDepo).toBeNull();
  });

  it('SATISTA giris yoksa cikis deposu kullanilir', () => {
    const d = yanittanBaslik({ ...bos, cikisDepoId: 1, cikisDepoAdi: 'Ana' }, 'TRY');
    expect(d.depo).toEqual({ id: 1, ad: 'Ana' });
  });

  it('depo hic yoksa null - 0 kimlikli sahte depo uretilmez', () => {
    expect(yanittanBaslik(bos, 'TRY').depo).toBeNull();
  });
});

describe('yanittanBaslik - kimlikler', () => {
  it('fiyat listesi 0 ise NULL (liste yok) - combo bos gorunsun', () => {
    expect(yanittanBaslik({ ...bos, fiyatListesiId: 0 }, 'TRY').fiyatListesiId).toBeNull();
    expect(yanittanBaslik({ ...bos, fiyatListesiId: 7 }, 'TRY').fiyatListesiId).toBe(7);
  });

  it('secilmemis kimlik NULL kalir, 0a dusmez', () => {
    const d = yanittanBaslik(bos, 'TRY');
    expect(d.odeyenKurumId).toBeNull();
    expect(d.bolumId).toBeNull();
    expect(d.personelId).toBeNull();
    expect(d.kampanyaId).toBeNull();
  });

  it('kisi alanlari ad ile birlikte cozulur, kimlik yoksa null', () => {
    const d = yanittanBaslik({ ...bos, saticiId: 9, saticiAdi: 'Zeynep' }, 'TRY');
    expect(d.satici).toEqual({ id: 9, ad: 'Zeynep' });
    expect(d.teslimEden).toBeNull();
  });
});

describe('yanittanBaslik - belge.tipi iki ekranda farkli okunur (130)', () => {
  it('FATURADA 0 anlamsiz: varsayilan "Alış / Satış" (1) gosterilir', () => {
    expect(yanittanBaslik({ ...bos, tipi: 0 }, 'TRY').faturaTipi).toBe(1);
    expect(yanittanBaslik({ ...bos, tipi: 2 }, 'TRY').faturaTipi).toBe(2);
  });

  it('STOK FISINDE 0 gecerlidir (tipsiz fis) - oldugu gibi kalir', () => {
    expect(yanittanBaslik({ ...bos, tipi: 0 }, 'TRY').fisTipi).toBe(0);
    expect(yanittanBaslik({ ...bos, tipi: 2 }, 'TRY').fisTipi).toBe(2);
  });
});

describe('yanittanBaslik - doviz zinciri', () => {
  it('kendi alani > bir ustteki > yerel para', () => {
    expect(yanittanBaslik({ ...bos, raporDovizi: 'USD' }, 'TRY').raporDovizi).toBe('USD');
    expect(yanittanBaslik({ ...bos, belgeDovizi: 'EUR' }, 'TRY').raporDovizi).toBe('EUR');
    expect(yanittanBaslik(bos, 'TRY').raporDovizi).toBe('TRY');
    expect(yanittanBaslik({ ...bos, raporDovizi: 'USD' }, 'TRY').ekstreDovizi).toBe('USD');
    expect(yanittanBaslik({ ...bos, ekstreDovizi: 'GBP', raporDovizi: 'USD' }, 'TRY')
      .ekstreDovizi).toBe('GBP');
  });

  it('BOS METIN de yerel paraya duser (sunucu bos kolon dondurebilir)', () => {
    expect(yanittanBaslik({ ...bos, raporDovizi: '' }, 'TRY').raporDovizi).toBe('TRY');
  });
});

describe('yanittanBasvuruBilgi', () => {
  it('DURUM alanlari 0a duser (provizyon alinmadi), SECIM alanlari null kalir', () => {
    const b = yanittanBasvuruBilgi({});
    expect(b.sgkDurum).toBe(0);
    expect(b.ossDurum).toBe(0);
    expect(b.sgkMustehaklik).toBe(0);
    expect(b.sgkSevkli).toBe(0);
    expect(b.basvuruTuru).toBeNull();
    expect(b.sgkProvizyonTipi).toBeNull();
    expect(b.sgkTakipTuru).toBeNull();
  });

  it('provizyon tarihleri dakikaya kirpilir, YOKSA null (bos metin degil)', () => {
    const b = yanittanBasvuruBilgi({ sgkProvizyonTarihi: '2026-09-04T09:15:30' });
    expect(b.sgkProvizyonTarihi).toBe('2026-09-04T09:15');
    expect(b.sgkGecerlilik).toBeNull();
  });

  it('mustehaklik ZAMANI salt okunur: kirpilmadan tasinir', () => {
    const b = yanittanBasvuruBilgi({ sgkMustehaklikZaman: '2026-09-04T09:15:30.500' });
    expect(b.sgkMustehaklikZaman).toBe('2026-09-04T09:15:30.500');
  });

  it('karsilama/tutar METNE cevrilir - 0 degeri KAYBOLMAZ', () => {
    const b = yanittanBasvuruBilgi({ sgkKarsilama: 0, ossTutar: 125.5 });
    expect(b.sgkKarsilama).toBe('0');
    expect(b.ossTutar).toBe('125.5');
    expect(yanittanBasvuruBilgi({}).sgkKarsilama).toBe('');
  });

  it('metin alanlari null gelirse BOS METIN olur (kutu kontrolsuz kalmasin)', () => {
    const b = yanittanBasvuruBilgi({ sgkTakipNo: null, ossPoliceNo: 'P-1' });
    expect(b.sgkTakipNo).toBe('');
    expect(b.ossPoliceNo).toBe('P-1');
  });
});
