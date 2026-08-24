/** Eposta/telefon alanlari icin ortak dogrulama + bicimlendirme (GenForm + IlgiliKisiler). */

export const EPOSTA_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function epostaGecerliMi(deger: string): boolean {
  return deger === '' || EPOSTA_REGEX.test(deger);
}

/** "05324187720" / "0532 418 77 20" / "+90 532 418 77 20" -> "0532 418 77 20". Taniyamazsa DOKUNMAZ. */
export function telefonFormatla(ham: string): string {
  const rakam = ham.replace(/\D/g, '');
  if (!rakam) return ham;
  const yerelsiz = rakam.startsWith('90') && rakam.length > 10 ? rakam.slice(2) : rakam;
  const on = yerelsiz.length === 10 ? yerelsiz : yerelsiz.startsWith('0') ? yerelsiz.slice(1) : yerelsiz;
  if (on.length !== 10) return ham;
  return `0${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8, 10)}`;
}

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
