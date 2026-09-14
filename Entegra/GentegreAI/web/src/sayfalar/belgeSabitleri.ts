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

// Tarih/sayi bicimleyicileri `bilesenler/bicim.ts` icinde toplandi
//   (yerelAnMetni, bugunIso, sayiOku, tutarMetni, tarihSaat). Burada
//   duruyorlardi ve ekranlar bir kismini bicim.ts'ten, bir kismini buradan
//   aliyordu - ayni isin iki evi vardi.

/**
 * FATURA TIPI (db/130 kod listesi belge.fatura_tipi) - faturanin cinsi.
 * Kodlar GIB / muhasebe alisilmis numaralariyla birebir; iade (2) zaten
 * belge.tipi'nde bu numarayla tutuluyordu.
 */
export const FATURA_TIPLERI: { deger: number; ad: string }[] = [
  { deger: 1,  ad: 'Alış / Satış' },
  { deger: 2,  ad: 'İade' },
  { deger: 3,  ad: 'Fiyat Farkı' },
  { deger: 4,  ad: 'S. Meslek Makbuzu' },
  { deger: 5,  ad: 'Kur Farkı' },
  { deger: 6,  ad: 'İthalat' },
  { deger: 7,  ad: 'Kira' },
  { deger: 8,  ad: 'Gider Pusulası' },
  { deger: 9,  ad: 'İhraç Kayıtlı' },
  { deger: 22, ad: 'Tevkifatlı' },
  { deger: 24, ad: 'KDV İstisna' },
  { deger: 25, ad: 'SGK' },
  { deger: 26, ad: 'İhracat' },
];

/**
 * HASTA BASVURUSU belge tipi (301). Basvuru ile satis siparisi AYNI TURDUR
 * (tur 19) - ayirt eden tek sey bu: basvuru `tipi = 30`, ERP siparisi
 * `tipi = 1`. Boylece rapor/SQL/dis entegrasyon belge_basvuru uzantisina
 * JOIN atmadan hangisi oldugunu bilir.
 *
 * NEDEN 2 DEGIL: "sipariste iade olmaz, 2 bosta" dogru bir gozlem ama
 * `tipi = 2`yi TURE BAKMADAN iade sayan sorgular var (db/132, db/133:
 * "bu satirdan iade edilen miktar" hesabi). Teklif -> siparis donusumunde
 * basvuru bir teklif satirindan turedigi icin o teklif "iade edilmis"
 * gorunurdu. 30 hicbir yerde kullanilmiyor.
 */
export const BASVURU_TIPI = 30;

/**
 * IRSALIYE TIPI - irsaliyede fatura tiplerinin cogu anlamsiz (fiyat farki,
 * tevkifat, SGK...); mal ya gider ya GERI GELIR. Ayni alan (belge.tipi) ve ayni
 * iade numarasi (2) kullanilir.
 */
export const IRSALIYE_TIPLERI: { deger: number; ad: string }[] = [
  { deger: 1, ad: 'Normal' },
  { deger: 2, ad: 'İade' },
];

/** Belge dovizi secenekleri (kart komboları). */
export const DOVIZ_KODLARI = ['TL', 'USD', 'EUR', 'GBP'];

/**
 * IADE / IPTAL NEDENLERI (kullanici: tahsilat sekmesinde iade tutarinin
 * altinda combo). Serbest metin DEGIL kod: "fazla tahsilat" ile "fazla
 * alindi" ayni sey ama rapor ikisini ayri sayardi; ayrica bazi nedenler
 * (hizmet verilmedi) hizmet satirini da ilgilendirir.
 *
 * Kod aciklamaya yazilir - ayri bir kolon eklemeden neden kasa ekstresinde
 * ve denetim izinde okunur.
 */
export const IADE_NEDENLERI: { kod: string; ad: string }[] = [
  { kod: 'fazla',   ad: 'Fazla tahsilat' },
  { kod: 'yanlis',  ad: 'Yanlış tahsilat (başka hasta / kasa)' },
  { kod: 'hizmet',  ad: 'Hizmet verilmedi' },
  { kod: 'vazgec',  ad: 'Hasta vazgeçti' },
  { kod: 'sikayet', ad: 'Şikâyet telafisi' },
  { kod: 'kurum',   ad: 'Kurum karşıladı (provizyon sonradan onaylandı)' },
  // PARA USTU de bir iadedir (kullanici): 100 USD alinip 10'u geri verilir.
  //   Ayri bir dugme ve ayri bir akis yerine BURADA duruyor - kasadan cikan
  //   para her iki durumda da ayni satiri yaziyor, yalniz sebebi farkli.
  { kod: 'ustu',    ad: 'Para üstü' },
  { kod: 'diger',   ad: 'Diğer' },
];

/**
 * ISKONTO GEREKCELERI (mockup: iskonto_talep_penceresi.html). Serbest metin
 * DEGIL kod: "personel yakini" ile "personelin annesi" ayni sey ama rapor
 * ikisini ayri sayardi. Aciklama ayrica yazilir - kategori NIYE, aciklama
 * AYRINTIDIR.
 */
export const ISKONTO_GEREKCELERI: { kod: string; ad: string }[] = [
  { kod: 'personel',  ad: 'Personel yakını' },
  { kod: 'sosyal',    ad: 'Sosyal endikasyon' },
  { kod: 'sikayet',   ad: 'Şikâyet telafisi' },
  { kod: 'kampanya',  ad: 'Kampanya / paket' },
  { kod: 'anlasma',   ad: 'Kurum anlaşması' },
  { kod: 'yuvarlama', ad: 'Yuvarlama' },
  { kod: 'diger',     ad: 'Diğer' },
];

export const iskontoGerekceAdi = (kod: string) =>
  ISKONTO_GEREKCELERI.find(x => x.kod === kod)?.ad ?? kod;

/** Iade neden kodunun okunur adi - aciklamaya bu yazilir. */
export const iadeNedenAdi = (kod: string) =>
  IADE_NEDENLERI.find(x => x.kod === kod)?.ad ?? kod;

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
  // DIL BIRLIGI (kullanici): durum/filtre adi DONUSUM, eylem BELGE KES.
  //   Eski "Faturalandı" yaniltiyordu - hedef fis ya da tahakkuk da
  //   olabiliyor, ikisi de fatura degil.
  0: { ad: 'Belge Kesilmedi', sinif: 'uyari' },
  1: { ad: 'Kısmi Kesildi', sinif: '' },
  2: { ad: 'Belge Kesildi', sinif: 'olumlu' },
};

/** Kart sekmeleri (mockup satis_irsaliye_karti.html / satis_faturasi.html .tabs).
    `irsaliye:true` yalniz irsaliyede, `faturaYok:true` faturada GIZLENIR,
    `faturaMi:true` yalniz faturada gorunur. */
export const SEKMELER: {
  anahtar: string; baslik: string;
  irsaliye?: boolean; faturaYok?: boolean; faturaMi?: boolean;
  /** YALNIZ BASVURUDA cizilir (298): kayit kabul akisina ozel sekmeler. */
  basvuru?: boolean;
}[] = [
  // BASVURU (298, Ekranlar/kayit_kabul_basvuru.html): kabul bilgileri
  //   Ücretlendirme'nin SOLUNDA - once "kim, neden, hangi klinige geldi",
  //   sonra ucret.
  { anahtar: 'basvuru',  baslik: 'Başvuru', basvuru: true },
  { anahtar: 'kalem',    baslik: 'Kalemler' },
  // PROVIZYON, ÜCRETLENDIRME'NIN HEMEN SAGINDA (kullanici; onceki karar "en
  //   sonda" idi, degisti). Provizyon gunluk akisin disinda bir ek degil,
  //   ucretin devami: hangi kalemin ne kadarini kurum odeyecek sorusunun
  //   cevabi ve istek de o kalemler uzerinden gidiyor (hospitalRowNumber =
  //   belge_satir.id). Yorum/Doküman'in arkasina atilinca kalemleri girip
  //   provizyona gecmek serittte bastan sona yolculuk oluyordu.
  { anahtar: 'provizyon', baslik: 'Provizyon', basvuru: true },
  { anahtar: 'tasiyici', baslik: 'Taşıyıcı / Sevkiyat', irsaliye: true },
  { anahtar: 'ebelge',   baslik: 'e-Belge' },
  // TAHSILAT, Faturalama'nin SOLUNDA (kullanici): siparis once tahsil edilir
  //   (avans), sonra faturalanir - sekme sirasi bu akisi izlesin.
  //   Faturada "Faturalama" (bu belgeden turetilenler) zaten anlamsiz - fatura
  //   zincirin SONU (faturaYok).
  { anahtar: 'tahsilat', baslik: 'Tahsilat',   faturaMi: true },   // alista "Ödeme" olur
  { anahtar: 'fatura',   baslik: 'Belgeye Dönüşüm', faturaYok: true },
  { anahtar: 'imza',     baslik: 'İmza / Teslim', irsaliye: true },
  // "Yorum / Medya" -> "Resim / Doküman" (kullanici, 218).
  { anahtar: 'yorum',    baslik: 'Resim / Doküman' },
  // Gecmis EN SONDA: hastanin oykusu, gunluk kabul akisinin disinda.
  { anahtar: 'gecmis',    baslik: 'Önceki Başvurular', basvuru: true },
];

/** Teklif durumu (218) - belge.teklif_durum kod uzayi. */
export const TEKLIF_DURUMLARI: Record<string, string> = {
  '1': 'Hazırlanıyor', '2': 'Sunuldu', '3': 'Kabul', '4': 'Red', '5': 'İptal',
};

// sayiOku / tutarMetni de bicim.ts'e tasindi (yukaridaki nota bakin).
