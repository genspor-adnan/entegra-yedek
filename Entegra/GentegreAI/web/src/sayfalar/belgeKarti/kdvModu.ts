/**
 * KDV DAHIL / HARIC GIRIS MODU (kullanici) - saf hesap.
 *
 * Belgede saklanan birim fiyat HER ZAMAN MATRAHTIR (KDV haric): satir
 * matematigi, dip toplam ve e-Belge hep matrah uzerinden calisir. Ama fiyat
 * LISTELERI iki turlu tutulur - `fiyat_listesi.kdv_dahil` - ve kayit kabul
 * memuru elindeki fiyat listesindeki gibi yazmak ister.
 *
 * Bu yuzden pencerede bir GIRIS MODU var: "Dahil" secilince kutuda BRUT fiyat
 * gorunur ve yazilir, saklanan deger matraha cevrilir. Mod, listenin kendi
 * ayarindan gelir; kullanici degistirebilir (liste yanlis kurulmus ya da o
 * kalem istisna olabilir).
 *
 * SESSIZ PARA HATASI RISKI: donusum yapilmazsa %20 KDV'li bir kalemde fiyat
 * dogrudan %20 sapar ve hata ancak faturada goze carpar.
 */

/** KDV carpani: %20 -> 1,20. Gecersiz/eksi oran 1 sayilir (vergisiz). */
export function kdvCarpani(kdvOrani: unknown): number {
  const o = Number(kdvOrani);
  return Number.isFinite(o) && o > 0 ? 1 + o / 100 : 1;
}

/**
 * BRUT -> MATRAH. Kurusun altina inen artiklar saklanir (4 hane): satir
 * matematigi matrah uzerinden yurudugu icin erken yuvarlamak toplamda kurus
 * kaydirir.
 */
export function matraha(brut: number, kdvOrani: unknown): number {
  const c = kdvCarpani(kdvOrani);
  return Math.round(brut / c * 10000) / 10000;
}

/** MATRAH -> BRUT (ekranda gosterilen deger). */
export function bruta(matrah: number, kdvOrani: unknown): number {
  return Math.round(matrah * kdvCarpani(kdvOrani) * 10000) / 10000;
}

/**
 * Metin girdisini karsi moda cevirir; SAYIYA CEVRILEMEYEN metin oldugu gibi
 * kalir - kullanici "12," yazarken ara degerde kutunun icerigi silinmesin.
 */
export function moduCevir(metin: string, kdvOrani: unknown, dahilOldu: boolean): string {
  const s = String(metin ?? '').trim();
  if (s === '') return s;
  // YARIM YAZIM ("12," / "12.") oldugu gibi kalir: `Number("12.")` gecerli bir
  //   sayidir ve cevrilirse kullanicinin yazdigi ayrac silinir - ondalik
  //   girmek imkansizlasirdi.
  if (/[.,]$/.test(s)) return s;
  const n = Number(s.replace(',', '.'));
  if (!Number.isFinite(n)) return s;
  return String(dahilOldu ? bruta(n, kdvOrani) : matraha(n, kdvOrani));
}
