import { describe, expect, it } from 'vitest';
import { telefonAyir, telefonBirlestir } from '../bilesenler/telefon';

/**
 * TELEFON ÜLKE KODU AYRIMI (kullanıcı: "+90 ayrı olsun").
 *
 * Saklanan biçim tek metin; ayrım ekranda yapılıyor. Buradaki hatalar
 * "numaram kayboldu" ya da "+90+90 555..." olarak görünür.
 */
describe('telefonAyir', () => {
  it('uluslararasi bicimi ayirir', () => {
    expect(telefonAyir('+90 555 123 45 67'))
      .toEqual({ ulke: '+90', numara: '555 123 45 67' });
  });

  it('00 oneki + ile aynidir', () => {
    expect(telefonAyir('0090 532 111 22 33'))
      .toEqual({ ulke: '+90', numara: '532 111 22 33' });
  });

  it('yerel bicimde bastaki sifir atilir', () => {
    expect(telefonAyir('0532 111 22 33'))
      .toEqual({ ulke: '+90', numara: '532 111 22 33' });
  });

  it('bos deger varsayilan ulkeyle doner', () => {
    expect(telefonAyir('')).toEqual({ ulke: '+90', numara: '' });
  });

  // +9 / +90 / +994 karismasin: EN UZUN eslesen kod kazanir.
  it('en uzun eslesen ulke kodu secilir', () => {
    expect(telefonAyir('+994 50 123 45 67'))
      .toEqual({ ulke: '+994', numara: '50 123 45 67' });
    expect(telefonAyir('+7 912 345 67 89'))
      .toEqual({ ulke: '+7', numara: '912 345 67 89' });
  });

  it('taninmayan kod KAYBOLMAZ, numara alaninda durur', () => {
    expect(telefonAyir('+61 400 000 000'))
      .toEqual({ ulke: '+90', numara: '+61 400 000 000' });
  });
});

describe('telefonBirlestir', () => {
  it('kod ile numarayi birlestirir', () => {
    expect(telefonBirlestir({ ulke: '+90', numara: '555 123 45 67' }))
      .toBe('+90 555 123 45 67');
  });

  // Yalniz ulke kodu telefon DEGILDIR: "+90" kaydedip sonra "numarasi var"
  //   sanmak, SMS kuyrugunu bos numaralarla doldururdu.
  it('numara bossa metin de bos doner', () => {
    expect(telefonBirlestir({ ulke: '+90', numara: '   ' })).toBe('');
  });

  it('ayirma ve birlestirme birbirini bozmaz', () => {
    const ham = '+49 171 2345678';
    expect(telefonBirlestir(telefonAyir(ham))).toBe(ham);
  });
});

/**
 * ŞUBEYE GÖRE YEREL AYAR (666): telefon kodu ve TCKN/telefon kontrolü aktif
 * şubeden gelir. Buradaki hata "Alman hastanın kaydı hiç açılmıyor" ya da
 * tersine "yanlış TCKN sessizce kabul ediliyor" olarak görünür.
 */
describe('sube yerel ayari', () => {
  const sube = (ulkeKod: string, telefonKodu: string) => ({
    id: 1, ad: 'Test', varsayilan: true, yazma: true,
    ulkeKod, telefonKodu, zamanDilimi: 'Europe/Istanbul', paraBirimi: 'TRY',
  });

  it('TR subede TCKN ve Turkiye telefon bicimi KONTROL EDILIR', async () => {
    const { subeAyariniKur, yerelTurkiye } = await import('../bilesenler/subeAyari');
    const { bicimHatasi, telefonGecerliMi } = await import('../bilesenler/alanBicim');
    subeAyariniKur(sube('TR', '+90'));

    expect(yerelTurkiye()).toBe(true);
    expect(bicimHatasi('tckn', '11111111111')).not.toBeNull();   // dogrulama hanesi tutmaz
    expect(telefonGecerliMi('123')).toBe(false);
  });

  it('TR DISI subede TCKN ve telefon bicim kontrolu YAPILMAZ', async () => {
    const { subeAyariniKur, yerelTurkiye, paraSimgesi } = await import('../bilesenler/subeAyari');
    const { bicimHatasi, telefonGecerliMi } = await import('../bilesenler/alanBicim');
    subeAyariniKur({ ...sube('DE', '+49'), paraBirimi: 'EUR' });

    expect(yerelTurkiye()).toBe(false);
    // Alman hastanin kimlik numarasi NVI algoritmasini saglamaz - kayit acilmali.
    expect(bicimHatasi('tckn', '11111111111')).toBeNull();
    expect(telefonGecerliMi('171 2345678')).toBe(true);
    // Simge de subeden: Berlin subesinde "₺" yazmak yanlis tutar okuturdu.
    expect(paraSimgesi()).toBe('€');
  });

  it('Afgan Afganisi (AFN) simgesi ve +93 kodu taninir', async () => {
    const { subeAyariniKur, paraSimgesi } = await import('../bilesenler/subeAyari');
    const { telefonAyir } = await import('../bilesenler/telefon');
    subeAyariniKur({ ...sube('AF', '+93'), paraBirimi: 'AFN' });
    expect(paraSimgesi()).toBe('؋');
    expect(telefonAyir('+93 70 123 4567'))
      .toEqual({ ulke: '+93', numara: '70 123 4567' });
  });

  it('telefon kutusunun acilis kodu subeden gelir', async () => {
    const { subeAyariniKur } = await import('../bilesenler/subeAyari');
    const { telefonAyir } = await import('../bilesenler/telefon');
    subeAyariniKur(sube('DE', '+49'));
    expect(telefonAyir('')).toEqual({ ulke: '+49', numara: '' });
    subeAyariniKur(sube('TR', '+90'));
    expect(telefonAyir('')).toEqual({ ulke: '+90', numara: '' });
  });
});
