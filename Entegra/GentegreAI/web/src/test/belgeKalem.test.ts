import { describe, it, expect } from 'vitest';
import {
  iadeSatirlari, kampanyaFiyatiUygula, paketIcerigiUygula, sonAnahtar,
  stokSecimindenKalem,
} from '../sayfalar/belgeKalem';
import {
  yanittanSatirlar, satirTutari, adetKaydir, iskonatoMetni, bosSatir,
} from '../sayfalar/belgeSatir';
import type { SatirDurumu } from '../sayfalar/belgeSatir';
import type { IadeSatiri } from '../bilesenler/belge/IadeSatirPenceresi';

/** Kisa yoldan satir kurar - testler yalniz ilgilendikleri alani verir. */
const satir = (p: Partial<SatirDurumu>): SatirDurumu => ({
  anahtar: 1, satirTur: 1, stokId: null, hizmetId: null, stokKodu: '', stokAdi: '',
  adet: '1', birimFiyat: '', fiyatDovizi: '', dovizFiyat: '', kur: '1',
  iskonto: '0', iskonto2: '0', kdv: '20', aciklama: '', izlemeKodu: '',
  izleme: 0, izlemler: [], ...p,
});

describe('sonAnahtar', () => {
  it('en buyuk anahtari bulur, bos listede 0 doner', () => {
    expect(sonAnahtar([satir({ anahtar: 3 }), satir({ anahtar: 9 })])).toBe(9);
    expect(sonAnahtar([])).toBe(0);
  });
});

describe('stokSecimindenKalem', () => {
  it('stok secimini kaleme cevirir', () => {
    const k = stokSecimindenKalem({
      id: 4, tip: 'stok', kod: 'K1', ad: 'Kalem', kdv: 10, izleme: 2,
      anaBirimKod: 1, anaBirim: 'Adet', paket: 0, fiyat: 250, fiyatDovizi: 'USD',
    }, 7, 'TL');
    expect(k).toMatchObject({
      anahtar: 7, satirTur: 1, stokId: 4, hizmetId: null, izleme: 2,
      birimCarpan: 1, fiyatDovizi: 'USD', birimFiyat: '250',
    });
  });

  it('hizmet secimini hizmet satiri yapar', () => {
    const k = stokSecimindenKalem({ id: 8, tip: 'hizmet', kod: 'H', ad: 'Nakliye' }, 2, 'TL');
    expect(k).toMatchObject({ satirTur: 2, hizmetId: 8, stokId: null, izleme: 0, birim: 0 });
  });

  it('KDV ve para birimi icin varsayilana duser', () => {
    const k = stokSecimindenKalem({ id: 1, tip: 'stok', kod: 'A', ad: 'A' }, 1, 'TL');
    expect(k.kdv).toBe('20');
    expect(k.fiyatDovizi).toBe('TL');
  });

  it('KDV 0 gecerli bir degerdir (varsayilana DUSMEZ)', () => {
    expect(stokSecimindenKalem({ id: 1, tip: 'stok', kod: 'A', ad: 'A', kdv: 0 }, 1, 'TL').kdv)
      .toBe('0');
  });

  it('paket bayragini tasir', () => {
    expect(stokSecimindenKalem({ id: 1, tip: 'stok', kod: 'P', ad: 'P', paket: 1 }, 1, 'TL').paket)
      .toBe(true);
  });
});

describe('paketIcerigiUygula (124)', () => {
  const paket = satir({ anahtar: 5, adet: '2', stokKodu: 'PKT', paket: true });
  const mevcut = [paket, satir({ anahtar: 6, paketAnahtar: 5 }), satir({ anahtar: 7 })];
  const icerik = [{ stokId: 11, kod: 'A', ad: 'A malı', adet: 3, kdv: 20, fiyat: 10 }];

  it('onceki icerigi temizler, yenisini paketin ALTINA koyar', () => {
    const s = paketIcerigiUygula(mevcut, paket, icerik);
    expect(s.some(x => x.anahtar === 6)).toBe(false);       // eski icerik gitti
    expect(s.findIndex(x => x.stokId === 11)).toBe(1);      // paketin hemen altinda
    expect(s.at(-1)!.anahtar).toBe(7);                      // digerleri yerinde
  });

  it('icerik adedini paket adediyle carpar', () => {
    // 2 paket x 3 adet = 6
    expect(paketIcerigiUygula(mevcut, paket, icerik).find(x => x.stokId === 11)!.adet).toBe('6');
  });

  it('icerigi pakete baglar ve aciklama yazar', () => {
    const i = paketIcerigiUygula(mevcut, paket, icerik).find(x => x.stokId === 11)!;
    expect(i.paketAnahtar).toBe(5);
    expect(i.aciklama).toContain('PKT');
  });

  it('ondalikli paket adedini cozer', () => {
    const yarim = { ...paket, adet: '1,5' };
    expect(paketIcerigiUygula([yarim], yarim, icerik).find(x => x.stokId === 11)!.adet).toBe('4.5');
  });

  it('paket listede yoksa icerigi sona ekler', () => {
    const s = paketIcerigiUygula([satir({ anahtar: 7 })], paket, icerik);
    expect(s.at(-1)!.stokId).toBe(11);
  });
});

describe('iadeSatirlari (132)', () => {
  const kaynak = [{
    satirId: 42, belgeId: 1, belgeNo: 'FTR-1', belgeTarihi: '2026-01-01', satirTur: 1,
    stokId: 3, stokKodu: 'S1', stokAdi: 'Stok', hizmetId: null, aciklama: '',
    miktar: 5, iadeMiktar: 0, kalanMiktar: 5, secilenMiktar: '2',
    birim: 1, birimFiyat: 100, iskonto: 10, kdv: 20, izleme: 0, izlemeKodu: '',
  }] as IadeSatiri[];

  it('kaynak satir bagini ve fiyati korur', () => {
    const s = iadeSatirlari(kaynak, 9)[0];
    expect(s).toMatchObject({
      anahtar: 10, kaynakSatirId: 42, adet: '2', birimFiyat: '100', iskonto: '10', kdv: '20',
    });
    expect(s.aciklama).toContain('FTR-1');
  });

  it('secilen miktar yoksa KALANIN tamamini alir', () => {
    const [{ secilenMiktar: _, ...eksik }] = kaynak;
    expect(iadeSatirlari([eksik as IadeSatiri], 0)[0].adet).toBe('5');
  });

  it('hizmet satirini tur 2 yapar', () => {
    const h = { ...kaynak[0], stokId: null, hizmetId: 4, stokAdi: null, aciklama: 'Montaj' };
    const s = iadeSatirlari([h as IadeSatiri], 0)[0];
    expect(s.satirTur).toBe(2);
    expect(s.stokAdi).toBe('Montaj');
  });
});

describe('yanittanSatirlar', () => {
  const yanit = [{
    id: 71, tur: 1, stokId: 5, stokKodu: 'ST', stokAdi: 'Stok Adı',
    teslimTarihi: '2026-09-01T00:00:00', adet: 2, miktar: 24, birimCarpan: 12, birim: 3,
    birimFiyat: 50, dovizCinsi: '', dovizKuru: 1, iskonto: 5, kdv: 20, izleme: 2,
    izlemler: [{ lotNo: 'L1', miktar: 24, sonKullanmaTarihi: '2027-01-01T00:00:00' }],
  }];

  it('sunucu satirini kart satirina cevirir', () => {
    const s = yanittanSatirlar(yanit, 'TL')[0];
    expect(s).toMatchObject({ anahtar: 1, satirId: 71, stokId: 5, kdv: '20' });
  });

  it('AMBALAJDA girilen adedi gosterir, ana birim miktarini degil (143)', () => {
    const s = yanittanSatirlar(yanit, 'TL')[0];
    expect(s.adet).toBe('2');            // 2 kutu
    expect(s.birimCarpan).toBe(12);      // x12 = 24 adet
  });

  // 368: kalem tarihi artik SAATLI (belge_satir.teslim_tarihi timestamp) -
  //   basvuruda "islem ne zaman yapildi" demek. Gun bazli eski kayitlar 00:00
  //   ile geliyor; datetime-local girdisi 16 karakter ister.
  it('kalem tarihini SAATIYLE tasir (368)', () => {
    expect(yanittanSatirlar(yanit, 'TL')[0].teslimTarihi).toBe('2026-09-01T00:00');
  });

  it('bos para birimini yerel paraya dusurur', () => {
    expect(yanittanSatirlar(yanit, 'TL')[0].fiyatDovizi).toBe('TL');
    expect(yanittanSatirlar([{ ...yanit[0], dovizCinsi: 'EUR' }], 'TL')[0].fiyatDovizi).toBe('EUR');
  });

  it('lot dagilimini tasir ve tarihleri kirpar', () => {
    const z = yanittanSatirlar(yanit, 'TL')[0].izlemler[0];
    expect(z).toMatchObject({ lotNo: 'L1', miktar: '24', sonKullanmaTarihi: '2027-01-01' });
  });

  it('stok adi bossa hizmet/masraf adina duser', () => {
    // "??" degil "||": sunucu bos alani '' donduruyor.
    expect(yanittanSatirlar([{ id: 2, tur: 2, hizmetAdi: 'Nakliye', stokAdi: '' }], 'TL')[0].stokAdi)
      .toBe('Nakliye');
  });

  it('yeni satirda satirId undefined kalir', () => {
    expect(yanittanSatirlar([{ tur: 1, stokAdi: 'X' }], 'TL')[0].satirId).toBeUndefined();
  });

  it('bos yanitta bos liste', () => {
    expect(yanittanSatirlar(undefined, 'TL')).toEqual([]);
  });
});

describe('satir hesaplari (onizleme)', () => {
  it('iskonto CARPIMSAL uygulanir - sunucudaki sirayla', () => {
    // 10 x 100 = 1000 -> %10 -> 900 -> %5 -> 855
    expect(satirTutari(10, 100, '10', '5')).toBeCloseTo(855, 2);
  });

  it('once adet x fiyat yuvarlanir', () => {
    expect(satirTutari(3, 33.333, '0', '0')).toBeCloseTo(100, 2);
  });

  it('adet kaydirma 1"in altina inmez', () => {
    expect(adetKaydir('1', -1)).toBe('1');
    expect(adetKaydir('2', -1)).toBe('1');
    expect(adetKaydir('2,5', 1)).toBe('3,50');
  });

  it('iskonto metni tek/cift kademeyi ayirir', () => {
    expect(iskonatoMetni({ iskonto: '10', iskonto2: '0' })).toBe('%10');
    expect(iskonatoMetni({ iskonto: '10', iskonto2: '5' })).toBe('%10 + %5');
    expect(iskonatoMetni({ iskonto: '0', iskonto2: '0' })).toBe('');
  });
});

describe('KDV DAHIL liste fiyati (kullanici)', () => {
  it('dahil listede brut fiyat MATRAHA cevrilerek yazilir', () => {
    // Sunucu kdvDahil'i bastan beri donuyordu ama ekran yok sayiyordu: 120 TL
    //   brut fiyat dogrudan matrah yazilinca kalem %20 pahali kaydediliyordu.
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '20' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 120, kdvDahil: 1 });
    expect(Number(y.birimFiyat)).toBeCloseTo(100, 4);
    expect(y.kdvDahil).toBe(1);
  });

  it('HARIC listede fiyat oldugu gibi kalir', () => {
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '20' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 120, kdvDahil: 0 });
    expect(Number(y.birimFiyat)).toBe(120);
    expect(y.kdvDahil).toBe(0);
  });

  it('kdvDahil HIC gelmezse haric varsayilir - eski davranis korunur', () => {
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '20' };
    expect(Number(kampanyaFiyatiUygula(s, { fiyat: 120 }).birimFiyat)).toBe(120);
  });
});

describe('SGK (SUT) bedeli - 483', () => {
  // Kullanici: "basvuru ekledim, TSS olarak. Bana sadece bir defa sigorta
  //   ucretini sordu; oysa SGK SUT fiyatini da bulup atmasi gerekirdi. Eger
  //   yoksa ekrandan onu almasi gerekir."
  it('TSS rotasinda SUT listesi bossa kutu ACILIR ve bedel bos gelir', () => {
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '0' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 2000, rota: 3, sgkGerekli: true });
    expect(y.sgkGerekli).toBe(true);
    expect(y.sgkListeBulundu).toBe(false);
    expect(y.sgkListe).toBe('');
  });

  it('SUT listesinde fiyat varsa bedel HAZIR gelir', () => {
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '0' };
    const y = kampanyaFiyatiUygula(s, {
      fiyat: 2000, rota: 3, sgkGerekli: true, sgkFiyat: 800 });
    expect(y.sgkListeBulundu).toBe(true);
    expect(Number(y.sgkListe)).toBe(800);
  });

  it('SUT listesi KDV DAHIL ise bedel matraha inilir', () => {
    // Kovalar KDV haric saklanir: brut 960 / 1,20 = 800.
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '20' };
    const y = kampanyaFiyatiUygula(s, {
      fiyat: 2000, rota: 3, sgkGerekli: true, sgkFiyat: 960, sgkKdvDahil: 1 });
    expect(Number(y.sgkListe)).toBeCloseTo(800, 4);
  });

  it('OSS rotasinda kutu ACILMAZ - o satirda SGK payi yok', () => {
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '0' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 1000, rota: 2, sgkGerekli: false });
    expect(y.sgkGerekli).toBeFalsy();
  });

  it('rota degisip SGK payi kalkinca eski bedel satirdan SILINIR', () => {
    // Karma sozlesmede "SGK katkisi kullanilsin" kapatilirsa rota 2'ye doner:
    //   satirda kalan SUT bedeli hayalet bir SGK payi uretirdi.
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '0',
                sgkGerekli: true, sgkListe: '800' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 4200, rota: 2, sgkGerekli: false });
    expect(y.sgkGerekli).toBe(false);
    expect(y.sgkListe).toBe('');
  });

  it('kullanicinin ELLE girdigi bedel, liste bos donunce korunur', () => {
    // Kalem yeniden fiyatlaninca (liste degisti, kurum degisti) SUT listesi
    //   yine bos donuyor - ekranda yazili olan silinmemeli.
    const s = { ...bosSatir(1), hizmetId: 900, kdv: '0',
                sgkGerekli: true, sgkListe: '800' };
    const y = kampanyaFiyatiUygula(s, { fiyat: 2500, rota: 3, sgkGerekli: true });
    expect(y.sgkListe).toBe('800');
  });
});
