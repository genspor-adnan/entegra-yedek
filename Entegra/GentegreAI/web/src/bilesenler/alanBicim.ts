/** Eposta/telefon alanlari icin ortak dogrulama + bicimlendirme (GenForm + IlgiliKisiler). */

export const EPOSTA_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function epostaGecerliMi(deger: string): boolean {
  return deger === '' || EPOSTA_REGEX.test(deger);
}

// Telefon GOSTERIMI burada degil `bicim.ts` icindeki `telefonBicimle`dedir.
//   Burada bir ikinci bicimleyici daha vardi ("0532 418 77 20") ve cagrilmiyordu;
//   iki farkli cikti tek alan icin kafa karistiriciydi - silindi.

/**
 * Alan/kolon adindan TELEFON tanima (genel kural): telefon nerede gecerse
 * gecsin ayni bicim ve ayni dogrulama uygulanir - her ekranda tek tek liste
 * tutmak bir yeni alanda unutulur.
 */
export const telefonAlaniMi = (ad: string) => /telefon|ceptel|gsm|faks/i.test(ad);

/**
 * TELEFON DOGRULAMASI (genel kural). Bos deger gecerlidir - telefon zorunlu
 * degil; girildiyse ANLAMLI olmali.
 *
 * TURKIYE (+90 ya da ulke kodsuz yazim): 10 hane ve 2-5 ile baslar
 * (5xx cep, 2xx/3xx/4xx sabit). "0" onegi kabul edilir, temizlenir.
 * DIGER ULKELER: bicim ulkeden ulkeye degisir - yalniz makul uzunluk (6-15
 * rakam) aranir; daha katisi yanlis yere "hata" derdi.
 */
export function telefonGecerliMi(deger: string): boolean {
  const metin = (deger ?? '').trim();
  if (!metin) return true;

  const rakam = metin.replace(/\D/g, '');
  if (!rakam) return false;

  const yerelMi = !metin.startsWith('+') || rakam.startsWith('90');
  if (yerelMi) {
    let on = rakam.startsWith('90') ? rakam.slice(2) : rakam;
    if (on.length === 11 && on.startsWith('0')) on = on.slice(1);
    return on.length === 10 && /^[2-5]/.test(on);
  }
  return rakam.length >= 6 && rakam.length <= 15;
}

/**
 * T.C. KİMLİK NUMARASI (NVİ algoritması) - sunucudaki `KimlikDogrulama` ile
 * AYNI kural. İki yerde durmasının sebebi: sunucu kuralın sahibi (istek
 * doğrudan API'ye de gelebilir), ekran ise kullanıcıyı kaydetmeye kadar
 * bekletmemek için aynı kontrolü anında yapar.
 *
 * BOŞ DEĞER GEÇERLİ: zorunluluk ayrı bir karardır (kimliği belirsiz hasta
 * TCKN'siz açılır).
 */
export function tcknGecerliMi(deger: string): boolean {
  const s = (deger ?? '').trim();
  if (s.length === 0) return true;
  if (!/^[1-9][0-9]{10}$/.test(s)) return false;

  const h = [...s].map(Number);
  const tek = h[0] + h[2] + h[4] + h[6] + h[8];
  const cift = h[1] + h[3] + h[5] + h[7];
  const onuncu = (((tek * 7) - cift) % 10 + 10) % 10;
  if (onuncu !== h[9]) return false;

  const ilkOn = h.slice(0, 10).reduce((t, x) => t + x, 0);
  return ilkOn % 10 === h[10];
}

/** Alanın biçim kuralı - geçersizse mesaj, geçerliyse null. */
export function bicimHatasi(dogrulama: string | null | undefined,
                            deger: string): string | null {
  if (dogrulama !== 'tckn') return null;
  return tcknGecerliMi(deger)
    ? null
    : 'T.C. kimlik numarası geçersiz - 11 hane olmalı ve doğrulama hanesi tutmalı.';
}
