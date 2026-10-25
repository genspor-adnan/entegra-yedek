/** Türkçe duyarsız arama metni: "İstem" yazan "istem"i bulsun (komut paleti + cariKomutu). */
const TR_HARF = 'çğıöşüâîû';
const ASCII_HARF = 'cgiosuaiu';
export function paletSadelestir(metin: string) {
  let sonuc = '';
  for (const h of metin.toLocaleLowerCase('tr')) {
    const i = TR_HARF.indexOf(h);
    sonuc += i >= 0 ? ASCII_HARF[i] : h;
  }
  return sonuc;
}
