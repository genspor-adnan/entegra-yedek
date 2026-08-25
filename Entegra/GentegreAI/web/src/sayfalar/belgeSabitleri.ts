/**
 * BELGE KARTI SABITLERI - senaryo/teslim/fis tipi listeleri, sekme tablosu ve
 * ayar varsayilanlari.
 *
 * Kart dosyasi 1800 satiri asinca veri ile ekran ayrildi: burada is mantigi YOK,
 * yalnizca sabit tablolar ve kucuk bicimleyiciler.
 */
/**
 * Yerel para birimi. SIMDILIK sabit - opsiyona (kurulus ayari) baglanacak;
 * mali_hareket/muhasebe tarafinda da ayni kavram "yerel tutar" olarak geciyor.
 */
/**
 * Yerel (defter) para birimi VARSAYILANI. Gercek deger Genel Ayarlar'dan gelir
 * (`genel.yerel_para`, db/106) - ayar yuklenene kadar bu kullanilir. Kalem
 * penceresi "bu fiyat doviz mi" kararini buna gore verir.
 */
export const YEREL_PARA_VARSAYILAN = 'TL';

/**
 * Belge tarihi penceresi (GENEL KURAL, tum belge turleri): ileri tarih YOK,
 * N gunden eski YOK. N = Yönetim › Ayarlar › Genel'deki "geriye dönük gün"
 * (db/102, varsayilan 7; 0 = sinir yok). Ayar yuklenene kadar bu varsayilan
 * kullanilir. Sunucu da ayni kurali uygular (BelgeDeposu.BelgeTarihiKontrolAsync) -
 * buradaki sinirlar yalniz kullaniciyi erken uyarmak icindir.
 */
export const GERIYE_GUN_VARSAYILAN = 7;

/** datetime-local kutusunun bekledigi YEREL "YYYY-MM-DDTHH:mm" (UTC'ye kaymaz). */
export const yerelAnMetni = (d: Date) => {
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`
       + `T${p(d.getHours())}:${p(d.getMinutes())}`;
};

/** Senaryo comboSU - SENARYO_ADI ile ayni kodlar, GIB profil sirasinda. */
export const SENARYO_SECENEK = [
  { deger: 1, ad: 'Temel Fatura' },
  { deger: 2, ad: 'Ticari Fatura' },
  { deger: 3, ad: 'İhracat' },
  { deger: 7, ad: 'Kamu' },
  { deger: 8, ad: 'İlaç / Tıbbi Cihaz' },
];

/** Baslikta gosterilen e-Belge tipi: irsaliye / ihracat / normal fatura. */
export function eBelgeTipi(tur: number, senaryo: number): string {
  if (tur === 10 || tur === 14) return 'e-İrsaliye';
  if (senaryo === 3) return 'e-Fatura (İhracat)';
  return 'e-Fatura (Mükellef)';
}






export const LOOKUP_DEPO = [{ ad: 'ad', baslik: 'Depo', genis: true }];

/** Teslim sekli (088 kod listesi belge.teslim_sekli) - e-Irsaliye'de GIB bekler. */
export const TESLIM_SEKLI: { deger: number; ad: string }[] = [
  { deger: 0, ad: 'Belirtilmemiş' },
  { deger: 1, ad: 'Alıcı adresine teslim' },
  { deger: 2, ad: 'Alıcı kendi aracıyla' },
  { deger: 3, ad: 'Kargo / nakliye firması' },
  { deger: 4, ad: 'Depoda teslim' },
  { deger: 5, ad: 'Yurt dışı sevk' },
];

/**
 * Stok fisi TIPLERI (db/101 kod_deger ile birebir). Fisin SEBEBI: muhasebe
 * hesabi buna gore secilecek (F7) - "Diğer" disindakiler ayri gider/gelir
 * hesabina gider.
 */
export const GIRIS_FIS_TIPLERI = [
  { deger: 1, ad: 'Fire' },
  { deger: 2, ad: 'Sayım Fazlası' },
  { deger: 9, ad: 'Diğer' },
] as const;

export const CIKIS_FIS_TIPLERI = [
  { deger: 1, ad: 'Sarf' },
  { deger: 2, ad: 'İmha (Bozuk / SKT Geçmiş)' },
  { deger: 3, ad: 'Kayıp' },
  { deger: 4, ad: 'Fire' },
  { deger: 5, ad: 'Sayım Eksiği' },
  { deger: 9, ad: 'Diğer' },
] as const;

export const KAPANMA_ETIKET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Faturalanmadı', sinif: 'uyari' },
  1: { ad: 'Kısmi faturalandı', sinif: '' },
  2: { ad: 'Faturalandı', sinif: 'olumlu' },
};

/** Kart sekmeleri (mockup satis_irsaliye_karti.html / satis_faturasi.html .tabs).
    `irsaliye:true` yalniz irsaliyede, `faturaYok:true` faturada GIZLENIR,
    `faturaMi:true` yalniz faturada gorunur. */
export const SEKMELER: {
  anahtar: string; baslik: string;
  irsaliye?: boolean; faturaYok?: boolean; faturaMi?: boolean;
}[] = [
  { anahtar: 'kalem',    baslik: 'Kalemler' },
  { anahtar: 'tasiyici', baslik: 'Taşıyıcı / Sevkiyat', irsaliye: true },
  { anahtar: 'ebelge',   baslik: 'e-Belge' },
  // Faturada "Faturalama" (bu belgeden turetilenler) anlamsiz - fatura zincirin
  //   SONU. Mockup'ta (satis_faturasi.html) onun yerinde TAHSILAT var.
  { anahtar: 'fatura',   baslik: 'Faturalama', faturaYok: true },
  { anahtar: 'tahsilat', baslik: 'Tahsilat',   faturaMi: true },   // alista "Ödeme" olur
  { anahtar: 'imza',     baslik: 'İmza / Teslim', irsaliye: true },
  { anahtar: 'yorum',    baslik: 'Yorum / Medya' },
];
