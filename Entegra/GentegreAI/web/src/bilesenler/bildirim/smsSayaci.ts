/**
 * SMS SAYACI (mockup bildirim_sablonu_karti.html): karakter, kodlama ve parça (ücretlenen SMS) sayısı.
 * GSM 03.38 temel tablosunda OLMAYAN Türkçe harfler (ı ğ ş İ Ğ Ş ç) mesajı UCS-2'ye geçirir: tek SMS 70, parça 67
 * karakter. Aksi halde 7-bit: tek SMS 160, parça 153. (ö ü Ö Ü Ç temel tabloda var.)
 */
export interface SmsOlcusu { karakter: number; ucs2: boolean; tekSms: number; adet: number }

export function smsOlc(metin: string): SmsOlcusu {
  const ucs2 = /[ığşİĞŞç]/.test(metin) || /[^\u0000-ÿ€]/.test(metin.replace(/[ığşİĞŞç]/g, ''));
  const karakter = [...metin].length;
  const tekSms = ucs2 ? 70 : 160, parca = ucs2 ? 67 : 153;
  return { karakter, ucs2, tekSms, adet: karakter === 0 ? 0 : karakter <= tekSms ? 1 : Math.ceil(karakter / parca) };
}

/** Değişkenleri örnek değerle doldurur: {{ad}} ve @AD (büyük harf) yazımlarının ikisi de. */
export function sablonDoldur(metin: string, degerler: Record<string, string>): string {
  let m = metin;
  for (const [ad, deger] of Object.entries(degerler)) {
    m = m.split(`{{${ad}}}`).join(deger);
    m = m.replace(new RegExp(`@${ad.toUpperCase()}`, 'gi'), deger);
  }
  return m;
}

/** Metinde geçen değişken adları (yazım: {{ad}} ya da @AD). */
export function metindekiDegiskenler(metin: string): string[] {
  const s = new Set<string>();
  for (const m of metin.matchAll(/\{\{\s*([A-Za-z_][\w.]*)\s*\}\}/g)) s.add(m[1]);
  for (const m of metin.matchAll(/@([A-ZÇĞİÖŞÜ][A-ZÇĞİÖŞÜ_0-9]+)/g)) s.add(m[1]);
  return [...s];
}
