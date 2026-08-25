import type { KartAlanMeta } from '../api/sozlesme';

/**
 * KART DEGISIKLIGI - ne degisti, ne gonderilecek.
 *
 * Iki soru ayni normalizasyona dayanir ve kart ekraninin en kritik iki karari:
 *   1) "kullanici bir sey degistirdi mi?" (kapatirken soru sorulsun mu),
 *   2) "sunucuya hangi alanlar gidecek?" (§3.2: alan gondermemek = degistirme).
 *
 * `kartDogrulama.ts` ile ayni desen: karar saf, ekran yalnizca uygular.
 */

/** Bos sayilan degerler - null / undefined / '' ayni seydir. */
const bos = (v: unknown) => v === null || v === undefined || v === '';

/**
 * Iki deger AYNI MI - alan tipine gore normalize ederek.
 *
 * GENEL KURAL (kullanici): hicbir sey degistirmeden kapatan kullaniciya
 * "kaydedilsin mi?" SORULMAZ. Katı (!==) karsilastirma bunu yapamiyordu - ayni
 * deger farkli YAZIMLARLA geliyor ve sahte fark uretiyordu:
 *
 *   kur      sunucudan "1.000000", ekranda '1'      (doviz efekti yazar)
 *   tutar    "1500.0000" vs "1500"
 *   kod      sayi 1 vs metin "1"
 *   bos alan null / undefined / ''
 */
export function alanEsit(alan: { tip: string }, x: unknown, y: unknown): boolean {
  if (alan.tip === 'mantik') return Boolean(x) === Boolean(y);
  if (bos(x) && bos(y)) return true;
  if (bos(x) !== bos(y)) return false;
  if (alan.tip === 'sayi' || alan.tip === 'para' || alan.tip === 'kod') {
    const sx = Number(String(x).replace(',', '.'));
    const sy = Number(String(y).replace(',', '.'));
    // Kod alanlari HARF de tasiyabilir ('K'/'B'); sayi degilse metne duser.
    if (Number.isFinite(sx) && Number.isFinite(sy)) return sx === sy;
  }
  if (alan.tip === 'tarih' || alan.tip === 'zaman') {
    // "2026-08-25T00:00:00" ile "2026-08-25" ayni gunu anlatir; zaman alaninda
    //   dakikaya kadar bakilir.
    const n = alan.tip === 'zaman' ? 16 : 10;
    return String(x).slice(0, n) === String(y).slice(0, n);
  }
  return String(x).trim() === String(y).trim();
}

/** Kart alanlarindan herhangi biri ilk halinden farkli mi. */
export function kartDegistiMi(
  alanlar: readonly KartAlanMeta[] | undefined,
  deger: Record<string, unknown>,
  ilkDeger: Record<string, unknown>,
): boolean {
  return alanlar?.some(a =>
    a.yazilabilir && a.ad !== 'id' && !alanEsit(a, deger[a.ad], ilkDeger[a.ad])) ?? false;
}

/**
 * Sunucuya gidecek govde - yalniz DEGISEN alanlar (§3.2).
 *
 * YENI kayitta bos birakilan alan HIC GONDERILMEZ - null gondermek NOT NULL +
 * varsayilanli kolonlarda (durum, bayraklar) kaydi patlatiyordu. Bos
 * gonderilmeyince veritabani varsayilani devreye girer. DUZENLEMEDE ise bos
 * deger anlamlidir: kullanici alani temizlemis olabilir -> null.
 */
export function degisenAlanlar({ alanlar, deger, ilkDeger, yeniMi, varsayilanlar }: {
  alanlar: readonly KartAlanMeta[] | undefined;
  deger: Record<string, unknown>;
  ilkDeger: Record<string, unknown>;
  yeniMi: boolean;
  varsayilanlar?: Record<string, unknown>;
}): Record<string, unknown> {
  const govde: Record<string, unknown> = {};
  alanlar?.forEach(a => {
    if (!a.yazilabilir || a.ad === 'id') return;
    const yeni = deger[a.ad];

    if (yeniMi) {
      if (a.tip === 'mantik') {
        if (yeni) { govde[a.ad] = true; return }
        // EKRAN varsayilani alani acikca FALSE yaptiysa bunu SUNUCUYA SOYLE:
        //   sessizce atlanirsa katalog varsayilani devreye girer ve Aday
        //   Musterisi "musteri" olarak, Tedarikci de "musteri+tedarikci"
        //   olarak kaydedilirdi (rol bayraklari birbirine karisiyordu).
        if (varsayilanlar && a.ad in varsayilanlar) govde[a.ad] = false;
        return;
      }
      if (bos(yeni)) return;
      govde[a.ad] = yeni;
      return;
    }

    if (yeni === ilkDeger[a.ad]) return;
    govde[a.ad] = a.tip === 'mantik' ? Boolean(yeni) : (yeni === '' ? null : yeni);
  });
  return govde;
}
