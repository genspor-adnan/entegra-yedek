import type { AcikSatir } from '../api/sozlesme';

/**
 * TUTAR BAZLI DONUSUM HESABI (352) - dönüşüm modali ile otomatik POS fişi
 * AYNI kurali kullansin diye ortak dosyada.
 *
 * EKRAN KDV DAHIL calisir (kullanici: "10.000 TL kdv dahil işlem; sadece
 * faturaya/fişe geçince kdv hariç"); pay tutarlari ve API ise MATRAH ister.
 * Cevrim burada tek yerde yapilir.
 */

/** Satirin KDV carpani (1,20 gibi). */
export const kdvCarpan = (s: AcikSatir) => 1 + Number(s.kdv ?? 0) / 100;

/**
 * Secilen payin (1 hasta / 2 kurum) KALAN matrahi. Eski satirda (289 oncesi)
 * pay tutari hic yazilmamis olabilir: o zaman satirin acik kalan tutari doner -
 * sunucu donusumde satiri hasta payi olarak isaretler.
 */
export function payKalan(s: AcikSatir, pay: number) {
  const p = pay || 1;
  const k = Number((p === 2 ? s.kurumKalan : s.hastaKalan) ?? 0);
  const paylasimsiz = Number(s.kurumTutar ?? 0) + Number(s.hastaTutar ?? 0) === 0;
  return paylasimsiz ? Number(s.tutarKalan ?? 0) : k;
}

/** Kalanin KDV DAHIL karsiligi - ekranda gosterilen ve girilen tutar budur. */
export const payKalanDahil = (s: AcikSatir, pay: number) => payKalan(s, pay) * kdvCarpan(s);

/** Tahsil edilmis tutar (KDV dahil): dagitim tabani zaten KDV dahildir (323). */
export const tahsilDahil = (s: AcikSatir, pay: number) =>
  Number(((pay || 1) === 2 ? s.kurumTahsilMatrah : s.hastaTahsilMatrah) ?? 0) * kdvCarpan(s);

/**
 * Satira onerilen tutar (KDV dahil): tahakkukta (17) kalanin TAMAMI,
 * fis/faturada TAHSIL EDILEN kadari - "tahsil edilen kadar satış fişi,
 * kalanı tahakkuk" (kullanici).
 */
export function onerilenTutar(s: AcikSatir, hedefTur: number, pay: number) {
  const kalan = payKalanDahil(s, pay);
  if (hedefTur === 17) return kalan;
  return Math.max(0, Math.min(kalan, tahsilDahil(s, pay)));
}

/**
 * KDV dahil ekran tutarindan API'nin bekledigi MATRAHI uretir.
 *
 * KURUSA ASAGI yuvarlanir, dorde degil: sunucu matrahi 2 haneye yuvarlayip
 * KDV'yi ONUN uzerinden hesapliyor. 4 haneli matrah gonderilince 500,00 TL
 * tahsilat icin 454,5455 gidiyor, sunucu 454,55 yaziyor ve fis 500,01 TL
 * cikiyordu - TAHSIL EDILENDEN FAZLA. Kural "tahsil edilen KADAR" oldugu
 * icin sapma asagi olmali: 1 kurus acik kalir, belge fazla kapanmaz.
 *
 * Kayan nokta artigi (500,005 / 1,1 = 454,55000000000007) asagi yuvarlamayi
 * bir kurus asagi kaydirmasin diye once 6 haneye yuvarlanir - tahakkukta
 * kalanin TAMAMI gonderildiginde matrah birebir geri donmeli.
 */
export const matrahaCevir = (s: AcikSatir, dahilTutar: number) =>
  Math.floor(Number((dahilTutar / kdvCarpan(s)).toFixed(6)) * 100) / 100;
