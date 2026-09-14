import { subeAyari } from './subeAyari';
/**
 * TELEFONDA ÜLKE KODU AYRI ALAN (kullanıcı: "+90 ayrı olsun").
 *
 * Saklama biçimi DEĞİŞMEDİ: veritabanında tek metin durur ("+90 555 123 45 67").
 * Ayrım yalnız EKRANDA - kolonu ikiye bölmek, telefonu okuyan her sorguyu
 * (esnek giriş, SMS, hasta iletişimi) aynı anda değiştirmeyi gerektirirdi.
 *
 * Kullanıcı kutuya ülke kodunu yeniden yazmak zorunda kalmasın diye numara
 * alanına yapıştırılan "+90..." / "0090..." / "0532..." biçimleri de ayrıştırılır.
 */

/**
 * Kurumda karşılaşılan kodlar; liste kısa tutuldu - uzun liste seçimi yavaşlatır.
 *
 * Kutuda ÜLKE HARFİ SOLDA gösterilir (kullanıcı: "+90 solunda TR şeklinde"):
 * "TR +90". Yalnız numara gösterilince +31/+32/+33 birbirine karışıyordu;
 * harf, kodu okumadan tanımayı sağlar.
 */
export const ULKE_KODLARI = [
  { iso: 'TR', kod: '+90',  ad: 'Türkiye' },
  { iso: 'DE', kod: '+49',  ad: 'Almanya' },
  { iso: 'GB', kod: '+44',  ad: 'Birleşik Krallık' },
  { iso: 'NL', kod: '+31',  ad: 'Hollanda' },
  { iso: 'BE', kod: '+32',  ad: 'Belçika' },
  { iso: 'AT', kod: '+43',  ad: 'Avusturya' },
  { iso: 'CH', kod: '+41',  ad: 'İsviçre' },
  { iso: 'FR', kod: '+33',  ad: 'Fransa' },
  { iso: 'RU', kod: '+7',   ad: 'Rusya' },
  { iso: 'UA', kod: '+380', ad: 'Ukrayna' },
  { iso: 'AZ', kod: '+994', ad: 'Azerbaycan' },
  { iso: 'IQ', kod: '+964', ad: 'Irak' },
  { iso: 'SY', kod: '+963', ad: 'Suriye' },
  { iso: 'SA', kod: '+966', ad: 'S. Arabistan' },
  { iso: 'US', kod: '+1',   ad: 'ABD / Kanada' },
  { iso: 'AF', kod: '+93',  ad: 'Afganistan' },
] as const;

/** Kutuda gorunen etiket: "TR +90". Saklanan deger yalniz KODDUR (+90). */
export function ulkeEtiketi(kod: string): string {
  const u = ULKE_KODLARI.find(x => x.kod === kod);
  return u ? `${u.iso} ${u.kod}` : kod;
}

/**
 * Kutunun ACILIS kodu AKTIF SUBEDEN gelir (666): Berlin subesinde her numaraya
 * "+90" yazdirmak, ilk yazilan telefonu yanlis ulkeye baglardi. Sube bilgisi
 * yoksa +90.
 */
export function varsayilanUlke(): string {
  return subeAyari().telefonKodu || '+90';
}

/** Geriye donuk ad - sabit gereken yerler (test, ilk deger) icin. */
export const VARSAYILAN_ULKE = '+90';

export interface TelefonParcasi { ulke: string; numara: string }

/**
 * Tek metni ülke kodu + numara olarak ayırır.
 *  "+90 555 123 45 67" → { +90, "555 123 45 67" }
 *  "0090 532..."       → { +90, "532..." }
 *  "0532 111 22 33"    → { +90, "532 111 22 33" }   (baştaki 0 atılır)
 *  ""                  → { +90, "" }
 * Tanınmayan kod gelirse metin OLDUĞU GİBİ numara alanına konur - veriyi
 * "düzeltmek" uğruna kaybetmek, yanlış numaradan beter.
 */
export function telefonAyir(ham: string): TelefonParcasi {
  const m = (ham ?? '').trim();
  if (m === '') return { ulke: varsayilanUlke(), numara: '' };

  // "00" ile baslayan uluslararasi bicim "+" ile aynidir.
  const d = m.startsWith('00') ? '+' + m.slice(2) : m;

  if (d.startsWith('+')) {
    // En UZUN eslesen kod alinir: +9 ile +90 ve +994 karismasin.
    const kod = [...ULKE_KODLARI]
      .map(u => u.kod)
      .filter(k => d.startsWith(k))
      .sort((a, b) => b.length - a.length)[0];
    if (kod) return { ulke: kod, numara: d.slice(kod.length).trim() };
    return { ulke: varsayilanUlke(), numara: d };    // taninmayan kod: dokunma
  }

  // Yerel bicim: bastaki 0 sube kodu degil, ulke ici onektir.
  // Yerel yazim: hangi ulkenin "yerel"i oldugunu SUBE soyler.
  return { ulke: varsayilanUlke(), numara: d.replace(/^0+/, '').trim() };
}

/** Ekrandaki iki alanı saklanan tek metne çevirir. Numara boşsa metin de boştur. */
export function telefonBirlestir(p: TelefonParcasi): string {
  const n = (p.numara ?? '').trim();
  if (n === '') return '';                  // yalniz ulke kodu telefon degildir
  return `${p.ulke || varsayilanUlke()} ${n}`.trim();
}
