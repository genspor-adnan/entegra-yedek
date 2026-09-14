/**
 * Arayuz dilleri - db/081: taraf_kullanici.dil (0 TR / 1 EN / 2 DE).
 *
 * Kabuk'tan cikarildi (669): hem ust seritteki bayrak menusu hem Kullanici
 * Ayarlari penceresi ayni listeyi okur; Kabuk'tan disa acmak Kabuk <-> pencere
 * dongusu yaratirdi.
 *
 * Bayrak SVG cizilir (<Bayrak dil=…/>): Windows'ta bayrak EMOJISI yok, emoji
 * kullanildiginda kullanici "TR"/"GB"/"DE" harflerini goruyordu.
 */
export const DILLER = [
  { deger: 0, ad: 'Türkçe' },
  { deger: 1, ad: 'English' },
  { deger: 2, ad: 'Deutsch' },
] as const;
