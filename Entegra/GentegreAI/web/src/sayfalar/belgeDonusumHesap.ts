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
  // INCE KOVA (470): 1 hasta provizyon · 2 SGK · 3 sigorta/kurum · 4 hasta ek
  //   katkisi. Sunucu bu kodlarla calisiyor ("Bu satırın SGK payı zaten
  //   kapatılmış" hatasi, kaba 2 = kurum varsayimindan doguyordu). Kova
  //   alanlari yoksa (eski yanit) kaba kurum/hasta ikilisine duser.
  const ince = p === 1 ? s.hastaProvizyonKalan
             : p === 2 ? s.sgkKalan
             : p === 3 ? s.ossKalan
             : p === 4 ? s.hastaEkKatkiKalan : undefined;
  if (ince !== undefined) return Number(ince ?? 0);

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

/**
 * Matrahtan satirin KDV DAHIL tutari - SUNUCUYLA AYNI kural: KDV once kurusa
 * yuvarlanir, sonra matraha eklenir (BelgeHesap).
 */
export const dahilTutar = (s: AcikSatir, matrah: number) =>
  matrah + Math.round(matrah * Number(s.kdv ?? 0)) / 100;

/**
 * KURUS FARKINI TAMAMLAR (kullanici: "POS 75.000, satis fisi 74.999,99").
 *
 * `matrahaCevir` her satirda KURUSA ASAGI yuvarlar - amaci fisin tahsil
 * edilenden FAZLA cikmamasi. Bedeli, satir sayisi kadar kurusluk bir eksiktir
 * ve toplamda gozle gorunur: 75.000 cekilmisken fis 74.999,99 kesiliyordu.
 *
 * Burasi eksigi geri koyar: satirlara sirayla birer kurus matrah eklenir,
 * yalniz eklenen kurus hedefi ASMADIGI surece. Boylece fis tahsil edileni
 * birebir tutar, asla gecmez.
 */
export function kurusTamamla(
  secim: { s: AcikSatir; matrah: number }[], hedefDahil: number,
): void {
  let toplam = secim.reduce((t, x) => t + dahilTutar(x.s, x.matrah), 0);
  for (const x of secim) {
    while (hedefDahil - toplam >= 0.005) {
      const yeniMatrah = Math.round((x.matrah + 0.01) * 100) / 100;
      const artis = dahilTutar(x.s, yeniMatrah) - dahilTutar(x.s, x.matrah);
      if (toplam + artis > hedefDahil + 0.005) break;   // hedefi asma
      x.matrah = yeniMatrah;
      toplam += artis;
    }
  }
}
