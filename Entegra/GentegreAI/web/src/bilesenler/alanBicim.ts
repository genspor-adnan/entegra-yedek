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
