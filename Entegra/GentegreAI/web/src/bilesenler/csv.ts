/**
 * CSV URETIMI - Excel/TR uyumlu.
 *
 * Iki kural Excel'in Turkce kurulumu icin ZORUNLU:
 *   1. Alan ayraci NOKTALI VIRGUL. Virgul kullanilirsa Excel butun satiri tek
 *      hucreye koyar (TR yerelinde liste ayraci ';' dir).
 *   2. Dosya UTF-8 BOM ile baslar. BOM yoksa Excel dosyayi ANSI sanar ve
 *      Turkce karakterler bozulur.
 *
 * Iki ekranda (liste disa aktarimi, stok hareket sekmesi) ayri ayri yazilmisti;
 * kacirma kurallari bile farkliydi (biri her alani tirnakliyor, oteki yalniz
 * gerekeni). Tek dogru davranis: yalniz gerekeni tirnakla - dosya kucuk kalir,
 * sayilar Excel'de sayi olarak acilir.
 */

/** UTF-8 BOM - Excel'in dosyayi UTF-8 saymasi icin. */
const BOM = '﻿';

/**
 * Alanda ayrac/tirnak/satir sonu varsa tirnakla, ictekileri ikile.
 * FORMÜL ENJEKSİYONU (kod inceleme 30.10.2026 K90): `=`, `@` ya da rakamla sürmeyen `+`/`-` ile başlayan
 * metin Excel'de formül olur (=HYPERLINK, =cmd|…); başına kesme konur. Negatif sayılar ("-5", "-1.250,00")
 * dokunulmaz.
 */
const kacir = (deger: unknown) => {
  let m = String(deger ?? '');
  if (/^[=@]|^[+-](?![\d.,\s])|^[\t\r]/.test(m)) m = "'" + m;
  return /[";\r\n']/.test(m) ? `"${m.replace(/"/g, '""')}"` : m;
};

/** Baslik satiri + veri satirlarindan CSV metni (BOM dahil). */
export function csvMetni(basliklar: readonly unknown[], satirlar: readonly (readonly unknown[])[]): string {
  const tumu = [basliklar, ...satirlar].map(s => s.map(kacir).join(';'));
  return BOM + tumu.join('\r\n');
}

/** CSV icin MIME tipi - `dosyaIndir` ile birlikte kullanilir. */
export const CSV_TIPI = 'text/csv;charset=utf-8';
