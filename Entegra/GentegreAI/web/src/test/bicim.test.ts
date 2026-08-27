import { describe, it, expect } from 'vitest';
import { ApiHatasi, hataMetni } from '../api/sozlesme';
import { gunMetni, kidemMetni, sayiOku, tutarMetni, tarihSaat, hamSayi, bugunIso } from '../bilesenler/bicim';

import { tariheEkle } from '../sayfalar/belgeSatir';

describe('hataMetni', () => {
  const hata = (kod: string, mesaj: string) =>
    new ApiHatasi(422, { kod, mesaj } as unknown as ConstructorParameters<typeof ApiHatasi>[1]);

  it('sunucu mesajini oldugu gibi gosterir', () => {
    expect(hataMetni(hata('IS_KURALI', 'Kilitli döneme işlem yazılamaz.')))
      .toBe('Kilitli döneme işlem yazılamaz.');
  });

  it('istenirse kodu one ekler', () => {
    expect(hataMetni(hata('DOGRULAMA', 'Cari zorunlu.'), true)).toBe('DOGRULAMA: Cari zorunlu.');
  });

  it('duz Error ve metni de okur', () => {
    expect(hataMetni(new Error('ağ hatası'))).toBe('ağ hatası');
    expect(hataMetni('bir şey')).toBe('bir şey');
  });

  it('nesneyi "[object Object]" birakmaz... ama en azindan cokmez', () => {
    expect(typeof hataMetni({ a: 1 })).toBe('string');
  });
});

describe('sayiOku / tutarMetni', () => {
  it('EKRAN bicimini cozer: nokta binlik, virgul ondalik', () => {
    expect(sayiOku('1.234,56')).toBe(1234.56);
    expect(sayiOku('1500')).toBe(1500);
    expect(sayiOku('0,5')).toBe(0.5);
  });

  it('bos/gecersiz girdide 0 doner', () => {
    expect(sayiOku('')).toBe(0);
    expect(sayiOku('abc')).toBe(0);
  });

  it('HAM ondaligi ekran bicimine cevirir', () => {
    expect(tutarMetni('1234.5600')).toBe('1234,56');
    expect(tutarMetni(1234.5)).toBe('1234,50');
    expect(tutarMetni('')).toBe('');
    expect(tutarMetni(null)).toBe('');
  });

  it('GIDIS-DONUS bozulmaz: ham -> ekran -> sayi', () => {
    // Ham deger dogrudan sayiOku'ya verilirse nokta BINLIK sayilir ve tutar
    //   100 katina cikar; kayitli kasa islemi acilip yeniden kaydedilince
    //   yasanan gercek hata buydu. tutarMetni araya girmek zorunda.
    for (const ham of ['1234.56', '0.50', '99999.99', '1500']) {
      expect(sayiOku(tutarMetni(ham))).toBeCloseTo(Number(ham), 2);
    }
    expect(sayiOku('1234.56')).not.toBe(1234.56);   // dogrudan verilirse bozulur
  });
});

/**
 * `hamSayi` SUNUCUDAN gelen degeri cozer: orada nokta ONDALIK ayracidir.
 * `sayiOku` ile ayni fonksiyon olamaz - ayni girdide farkli sonuc vermeleri
 * GEREKIR; ikisini birlestirmek yukaridaki 100-kat hatasini geri getirir.
 */
describe('hamSayi', () => {
  it('nokta ONDALIK sayilir (sayiOku ile ayni degil)', () => {
    expect(hamSayi('1234.56')).toBe(1234.56);
    expect(hamSayi('1234,56')).toBe(1234.56);   // virgul de kabul
    expect(hamSayi('1234.56')).not.toBe(sayiOku('1234.56'));
  });

  it('sayi/null/bos girdide cokmez', () => {
    expect(hamSayi(1234.56)).toBe(1234.56);
    expect(hamSayi(null)).toBe(0);
    expect(hamSayi(undefined)).toBe(0);
    expect(hamSayi('')).toBe(0);
    expect(hamSayi('abc')).toBe(0);
  });
});

/**
 * `bugunIso` YEREL gunu vermeli. `toISOString()` UTC'ye cevirdigi icin TR'de
 * saat 03:00'ten sonraki anlarda bir SONRAKI gunu yaziyordu - bes ekranda
 * (belge donusum tarihi, stok hareket bitis tarihi, kasa tarihi, doviz kuru
 * tarihi, CSV dosya adi) bu hata duruyordu.
 */
describe('bugunIso', () => {
  it('yerel gunu verir, UTC gunu degil', () => {
    // TR (UTC+3) gece yarisindan hemen sonra: UTC'de HALA onceki gun.
    const geceYarisi = new Date(2026, 7, 25, 0, 30, 0);
    expect(bugunIso(geceYarisi)).toBe('2026-08-25');
    expect(geceYarisi.toISOString().slice(0, 10)).not.toBe('2026-08-25');
  });

  it('ay ve gunu iki hane yazar', () => {
    expect(bugunIso(new Date(2026, 0, 5))).toBe('2026-01-05');
  });
});

describe('gunMetni', () => {
  it('ISO tarihi gun.ay.yil yapar', () => {
    expect(gunMetni('2026-08-25T14:05:00')).toBe('25.08.2026');
    expect(gunMetni('2026-08-25')).toBe('25.08.2026');
  });

  it('GECE YARISINA yakin saatte gunu kaydirmaz', () => {
    // new Date(...).toLocaleDateString saat dilimine gore bir gun oteye
    //   atabiliyordu; metinden kesmek bunu tumuyle onler.
    expect(gunMetni('2026-08-25T23:30:00')).toBe('25.08.2026');
    expect(gunMetni('2026-08-25T00:30:00')).toBe('25.08.2026');
  });

  it('bos degerde tire', () => {
    expect(gunMetni(null)).toBe('—');
    expect(gunMetni('')).toBe('—');
  });
});

describe('tarihSaat', () => {
  it('saat varsa gosterir, 00:00 ise gizler', () => {
    expect(tarihSaat('2026-08-23T14:05:00')).toBe('23.08.2026 14:05');
    expect(tarihSaat('2026-08-23T00:00:00')).toBe('23.08.2026');
    expect(tarihSaat('')).toBe('');
  });
});

describe('kidemMetni', () => {
  /** Bugunden geriye yil/ay giden bir ISO tarihi uretir. */
  const geriye = (yil: number, ay: number) => {
    const t = new Date();
    t.setFullYear(t.getFullYear() - yil);
    t.setMonth(t.getMonth() - ay);
    return t.toISOString().slice(0, 10);
  };

  it('yil ve ay birlikte yazilir', () => {
    expect(kidemMetni(geriye(3, 2))).toBe('3 yıl 2 ay');
  });

  it('bir yildan az kidem yalniz ay', () => {
    expect(kidemMetni(geriye(0, 5))).toBe('5 ay');
  });

  it('gelecek tarih ve bos girdi null', () => {
    const gelecek = new Date();
    gelecek.setFullYear(gelecek.getFullYear() + 1);
    expect(kidemMetni(gelecek.toISOString().slice(0, 10))).toBeNull();
    expect(kidemMetni('')).toBeNull();
    expect(kidemMetni('gecersiz')).toBeNull();
  });
});

describe('tariheEkle (raf omru)', () => {
  it('gun / ay / yil birimlerini uygular', () => {
    expect(tariheEkle('2026-01-31', 1, 1, 1)).toBe('2026-02-01');   // gun
    expect(tariheEkle('2026-01-15', 6, 2, 1)).toBe('2026-07-15');   // ay
    expect(tariheEkle('2026-01-15', 2, 3, 1)).toBe('2028-01-15');   // yil
  });

  it('ters yonde SKT"den uretim tarihini bulur', () => {
    expect(tariheEkle('2026-07-15', 6, 2, -1)).toBe('2026-01-15');
  });

  it('gecersiz girdide bos doner', () => {
    expect(tariheEkle('', 5, 1, 1)).toBe('');
    expect(tariheEkle('2026-01-15', 0, 1, 1)).toBe('');
  });
});
