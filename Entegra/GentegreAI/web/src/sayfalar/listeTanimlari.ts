import type { Kosul } from '../api/sozlesme';

/**
 * LISTE EKRANLARININ TANIM TABLOSU.
 *
 * Menu, rotalar ve grid AYNI tablodan uretilir - yeni bir liste eklemek icin
 * tek yer yeter. Liste.tsx bu tanimlari tuketen bilesendir; veri buradadir
 * (dosya 1028 satira ulasinca ikisi ayrildi).
 */
/**
 * Kasa listesindeki "＋ Tahsilat" / "－ Ödeme" dugmelerinin ARAC menusu.
 * Kodlar kasa_islem_turu.kod ile birebir: tahsilat 21/22/25, odeme 31/32/35.
 *
 * CEK / SENET (23/24/33/34) SIMDILIK YOK: bu turlerin sablonu 'ceksenet'
 * bacagi istiyor ve o bacak cek/senet KAYDINA baglaniyor (vade, seri,
 * kesideci) - kayit ekrani Kasa planinin F5 fazinda gelecek. Menude durup
 * kaydedilemeyen (422) bir secenek gostermek yerine F5'te eklenecek.
 */
/**
 * "⇢ Dönüştür" alt menusu (kullanici): hedefi LISTEDE secmek, karti actiktan
 * sonra combo'dan secmekten hizli. Secim karta KILITLI gider - kullanici zaten
 * kararini vermistir, kartta ikinci kez sormak hata kapisi acar.
 *
 * Kod bicimi "belge.donustur.<hedef tur>"; hedef turler BelgeDonusumModali'ndaki
 * HEDEFLER ile ayni (satis siparisi 19 -> 14/15/16/13).
 */
export const DONUSUM_MENUSU: Record<string, { kod: string; ad: string }[]> = {
  'belge.donustur': [
    { kod: 'belge.donustur.14', ad: '🚚 İrsaliye' },
    { kod: 'belge.donustur.15', ad: '🧾 Fatura' },
    { kod: 'belge.donustur.16', ad: '🧮 Fiş' },
    { kod: 'belge.donustur.13', ad: '📑 Tahakkuk' },
  ],
};

export const KASA_ARAC_MENUSU: Record<string, { kod: string; ad: string }[]> = {
  'kasa.tahsilat.yeni': [
    { kod: 'kasa.yeni.21', ad: '💵 Nakit' },
    { kod: 'kasa.yeni.22', ad: '🏦 Banka' },
    { kod: 'kasa.yeni.25', ad: '💳 POS' },
    // Cek/senet ayri turlerdir (23/24) ve portfoyde ayri izlenir; belge
    //   kartinin Tahsilat sekmesinde de ayni iki dugme var.
    { kod: 'kasa.yeni.23', ad: '🧾 Çek' },
    { kod: 'kasa.yeni.24', ad: '📜 Senet' },
  ],
  'kasa.odeme.yeni': [
    { kod: 'kasa.yeni.31', ad: '💵 Nakit' },
    { kod: 'kasa.yeni.32', ad: '🏦 Banka' },
    { kod: 'kasa.yeni.35', ad: '💳 POS / Kredi Kartı' },
    { kod: 'kasa.yeni.33', ad: '🧾 Çek' },
    { kod: 'kasa.yeni.34', ad: '📜 Senet' },
  ],
};

export interface ListeTanimi {
  kaynak: string;
  baslik: string;
  yol: string;
  /** Yalniz bu urun modunda gorunur (215): 2 = GenoTIP AI (HBYS). Bos = ortak. */
  urunModu?: number;
  /** Kart ekrani olan kaynaklarda cift tik karta gider. */
  kartYolu?: string;
  /**
   * Kart baslıgı. Verilmezse liste basligindan turetilir (sondaki -ler/-lar
   * atilir). "Radyoloji Çalışma Listesi" gibi baslikta bu turetme ise yaramaz:
   * kart tek bir ISTEM'i gosterir, listenin adini tasimamali.
   */
  kartBaslik?: string;
  aksiyonEkrani?: string;
  /** e-Belge menusu KUTUSUNUN basligi ("E-Fatura" / "E-İrsaliye"). Verilmezse
      kutu cizilmez. Ekran adi ayirt etmiyor: 'belge-liste' satis fisi /
      tahakkuk / alis faturasi listelerinde de kullaniliyor. */
  ebelgeMenusu?: string;
  toplam?: string[];
  /** `rota` verilen cip FILTRE degil GECIS'tir: tiklaninca o listeye gidilir
      (Alis Faturalari > "Gelen Kutusu"). Ayni serit, farkli kaynak. */
  /** `kosul: 'ebelge'` verilen cip YALNIZ e-Fatura mukellefinde cizilir
      (sunucu e-Belge aksiyonu donduruyorsa). */
  cipler?: { ad: string; filtre?: Kosul; rota?: string; kosul?: 'ebelge' }[];
  /** Rotasi var ama MENUDE gorunmez (baska bir listenin sekmesinden girilir). */
  menuGizli?: boolean;
  /** Mockup'ta olup backend'i henuz olmayan kart sekmeleri (or. stok: "ÜTS Bilgileri"). */
  yerTutucuSekmeler?: string[];
  /** Mockup'taki "Genel" sekmesindeki bos "Resim" kutusu (IMAJ→DOSYA hic baglanmadi). */
  resimYerTutucu?: boolean;
  /** Verilirse (ör. islem-log > "bilgi") satir bu alaniyla "İçerik" penceresinde gosterilir. */
  icerikAlani?: string;
  icerikBaslik?: string;
  /** Kosulsuz sunucu filtresi (ör. Tedarikci Listesi: tedarikci=1) - cip/arama filtreleriyle
      AND'lenir. Ayni kaynagi (ör. 'cari') farkli görünümlerde tekrar kullanmak icin. */
  sabitFiltre?: Kosul;
  /** Verilirse rota (URL/route path) `kaynak` yerine bunu kullanir - ayni kaynagi
      ("cari") birden fazla ekranda (Musteri/Tedarikci) farkli URL'lerle kullanmak icin. */
  rota?: string;
  /** Yeni kayitta mantik alanlara ekrana ozel varsayilan (ör. Tedarikci Listesi ->
      tedarikci:true, musteri:false) - GenForm'a gecirilir. */
  yeniKayitVarsayilanlari?: Record<string, boolean | number | string>;
  /** Ekstre ekranlari: URL'deki ?<alan>=<id> sorgu parametresi sunucu filtresine
      cevrilir (ör. /hesap-ekstre?hesapId=12). Parametre yoksa liste TUM kayitlari
      gosterir - bos ekran yerine "hepsi" daha kullanisli. */
  urlFiltreAlani?: string;
  /** Kart generic GenForm degil, kendi sayfasi (ör. kasa-islem): Liste modal ACMAZ,
      rotayi App.tsx kendisi tanimlar. Cift tik yine kartYolu'na gider. */
  ozelKart?: boolean;
  /** Bu ekranda kart uzerinde CIZILMEYECEK alanlar (ör. Aday kartinda "Kod"). */
  gizliKartAlanlari?: string[];
  /** Bu ekranda acilmayacak kart sekmeleri (ör. Aday kartinda "Fatura Bilgileri"). */
  gizliKartSekmeleri?: string[];
  /** Bu ekranda ONE alinacak kolon sirasi (soldan saga). */
  kolonSirasi?: string[];
  /** Bu ekranda zorunlu sayilacak kart alanlari (ör. Aday: Temsilci). */
  zorunluKartAlanlari?: string[];
  /** Menude grup ICINDEKI sira (kucuk once). Verilmeyen ogeler sonda, tanim
      sirasinda kalir - menu sirasi tanim dosyasindaki yere bagli olmasin. */
  menuSira?: number;
  /** "Yeni" aksiyonunda belge kartinin acilacagi tur (ör. Siparisler -> 19).
      Verilmezse kart kendi varsayilanini (satis faturasi) kullanir. */
  yeniBelgeTuru?: number;
  /** Menude grubun ICINDE ikinci bir kirilim (ör. Yönetim › Ayarlar › Stok Ayarları). */
  menuAltGrup?: string;
  /** Cip seridine "📄 Ekstre" dugmesi ekler: secili satirin ekstresi AYNI
      ekranda acilir (grid ekstre kaynagina doner), cip'e basinca liste geri gelir. */
  ekstre?: { kaynak: string; alan: string; baslik: string; tarihAlani?: string };
  /** Liste ekraninda tarih araligi filtresi (cip seridinde iki tarih kutusu). */
  tarihAlani?: string;
  /** Bu ekranda gizlenecek kolonlar (ör. Satis Faturalari'nda tur / turAdi). */
  gizliKolonlar?: string[];
  /** ☰/🕓/⭐ (Tum/Son/Sik) ikonlarini gizle (ÜTS listeleri). */
  aramaGorunumGizli?: boolean;
  /** Arac cubugu dugmesine acilir alt menu: aksiyon kodu -> secenekler. */
  altSecenekler?: Record<string, { kod: string; ad: string }[]>;
  /** Liste DEGIL, kendi sayfasi olan menu ogesi (ör. Stok Ayarları: sekmeli ekran).
      App.tsx rotayi kendisi tanimlar; buradaki `kaynak` yalnizca anahtar/rota icindir. */
  ozelSayfa?: boolean;
}

const DURUM_CIPLERI: ListeTanimi['cipler'] = [
  { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
  { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
  { ad: 'Tumu' },
];

/** Menu + rota kaynagi. Yetki sunucudan gelir; burada yalnizca ekran tanimi var.
    menuGrup verilirse Kabuk.tsx'te ayni gruptaki ogeler "Cari" gibi acilir-kapanir bir
    ana menu altinda TOPLANIR. */
export const LISTELER: (ListeTanimi & { menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string })[] = [
  {
    // RANDEVU kendi menu grubu (kullanici: "Randevu diye yeni menu olustur,
    //   Kayıt Kabul menusunun ust tarafina; icine Randevu ve Randevu Ayarlarini
    //   al; bunlar hbys icin gecerli"). Grup sirasi bu dizideki ILK gorulme
    //   sirasindan gelir - bu yuzden Hasta/Kayıt Kabul girdisinden ONCE durur.
    kaynak: 'randevu', baslik: 'Randevular', yol: 'Randevu › Randevular',
    kartYolu: '/randevu', aksiyonEkrani: 'randevu-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Planlandı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Geldi',     filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Gelmedi',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'İptal',     filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Randevu', menuAd: 'Randevular', ic: '📅', yetkiKodu: 'randevu',
    menuSira: 10,
  },
  {
    // Randevu Ayarlari (243): gun/saat duzeni + Bölümler sekmesi (251).
    kaynak: 'randevu-ayarlar', ozelSayfa: true, baslik: 'Randevu Ayarları',
    yol: 'Randevu › Randevu Ayarları',
    urunModu: 2,
    menuGrup: 'Randevu', menuAd: 'Randevu Ayarları', ic: '⚙️',
    yetkiKodu: 'randevu', menuSira: 11,
  },
  {
    // Tek ogeli grup (kullanici: "Cari menu ustune Hasta menusu ac, altina Hasta
    // Listesi ekle") - Cari grubunun HEMEN USTUNDE, ayni acilir-kapanir desende.
    kaynak: 'hasta', baslik: 'Hastalar', yol: 'Hasta › Hastalar', kartYolu: '/hasta',
    aksiyonEkrani: 'hasta-liste', cipler: DURUM_CIPLERI,
    // Sigorta ve acik borc HASTA SERIDI icin katalogda duruyor (basvuru
    //   kartinin ustundeki serit onlari okuyor); listenin kolon duzeni
    //   kullanicinin belirledigi haliyle kalsin diye gridde gizli.
    gizliKolonlar: ['sigortaAdi', 'acikBorc'],
    // Hasta da bir TARAF - cari ekstresi aynen gecerli (hasta hesabi hareketleri).
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Hasta Ekstresi',
              tarihAlani: 'islemTarihi' },
    // Kayit Kabul YALNIZ GenoTIP AI'da (kullanici, 215) - diger moduller ortak.
    menuGrup: 'Kayıt Kabul', menuAd: 'Hasta Listesi', ic: '🏥', yetkiKodu: 'personel',
    urunModu: 2,
  },
  {
    // BASVURU (246/279, kullanici: "basvurudaki islemler normal alinan
    //   siparislerimizdir"): AYRI TUR DEGIL - satis siparisinin (19) GenoTIP
    //   ekranidir. Ayni belge ERP kurulumunda "Satış Siparişleri" listesinde
    //   gorunur; iki liste ayni turu gostermesin diye ikisi de urunModu ile
    //   suzulur.
    kaynak: 'belge', rota: 'basvuru', baslik: 'Başvurular',
    yol: 'Kayıt Kabul › Başvurular',
    aksiyonEkrani: 'basvuru-liste', yeniBelgeTuru: 19,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 19 },
    // Basvuru e-Belge degil; tur kolonlari da tek turlu listede gereksiz.
    //   'durum' (Durum Kodu) siparis listesinden miras: basvuruda anlami yok,
    //   hepsi ayni degeri gosterip "Pasif" gibi okunuyordu (kullanici).
    //   'kaynak' (donusum zincirinde onceki belge) da gizli: basvuru zincirin
    //   BASI, kolon hep bos duruyordu. 'tipi'/'kapanmaDurum' ham KOD
    //   kolonlaridir (filtre icin) - okunur karsiliklari zaten var (kullanici).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum',
    //   'subeId' (Şube Kodu) ve 'vadeGun' de gizli: sube ADI zaten var, vade
    //   basvuruda yok - yerine Ödeyen Kurum kullaniliyor (kullanici).
    //   'senaryoAdi'/'senaryo' e-Fatura kavrami - basvuruda karsiligi yok.
                    'durum', 'durumAdi', 'kaynak', 'tipi', 'kapanmaDurum',
    //   'belgeSeri' DB'de duruyor (numara benzersizligi seri+no ikilisinde) ama
    //   listede hic gosterilmez - kolon menusunde de cikmaz (kullanici).
    //   Kalan ham/ERP kolonlari da basvuruda okunmuyor: Cari Id, Açık/Kapalı
    //   Kodu, Ort. Maliyet ve Tipi (fatura/irsaliye alt turu).
                    'subeId', 'vadeGun', 'senaryoAdi', 'senaryo', 'belgeSeri',
    //   Matrah/KDV basvuruda okunmuyor: hastaya soylenen rakam GENEL TOPLAM,
    //   yaninda ne kadari tahsil edildigi (kullanici).
                    'tarafId', 'acikKapali', 'maliyetOrt', 'tipiAdi',
                    'matrah', 'kdvTutari'],
    // Kaynak kolonunun yerine ODEYEN KURUM / POLIKLINIK / DOKTOR (kullanici).
    //   SERI listede yok ama katalogda DURUYOR: gizliKolonlar'a konsa kolon
    //   menusunden de kaybolurdu - gerektiginde kullanici acar.
    //   Sira: once belgenin kimligi (no, tarih, hasta), sonra basvuru bilgisi
    //   (odeyen kurum, poliklinik, hekim) - kullanici.
    kolonSirasi: ['belgeNo', 'belgeTarihi', 'tarafUnvan',
                  'odeyenKurumAdi', 'poliklinik', 'doktor',
                  'genelToplam', 'tahsilat'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Kayıt Kabul', menuAd: 'Başvurular', ic: '📝', yetkiKodu: 'belge',
    menuSira: 30,
  },
  // RADYOLOJI grubu ana menude KAYIT KABUL ile CRM ARASINDA (kullanici):
  //   grup sirasi bu dizideki ILK gorulme sirasindan gelir.
  {
    // RADYOLOJI CALISMA LISTESI (283): modulun giris ekrani - rapor yazma,
    //   PACS acma ve onay buradan baslar. Cipler gunun isini bolumler:
    //   once cekilecekler, sonra raporlanacaklar, sonra onay bekleyenler.
    kaynak: 'radyoloji-istem', rota: 'radyoloji', baslik: 'Radyoloji Çalışma Listesi',
    yol: 'Radyoloji › Çalışma Listesi',
    // Kart rotasi LISTE ROTASINDAN turetilir (/radyoloji/:id) - kartYolu farkli
    //   yazilirsa cift tik tanimsiz rotaya gider ve ana sayfaya duser.
    kartYolu: '/radyoloji', kartBaslik: 'Radyoloji İstemi',
    aksiyonEkrani: 'radyoloji-liste',
    tarihAlani: 'saat',
    cipler: [
      { ad: 'Bekleyen Çekim', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Raporlanacak',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Raporlanıyor',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Onay Bekleyen',  filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Onaylandı',      filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    // Nukleer ikon RADYOLOJI ANA MENUSUNUN (Kabuk.GRUP_IKON); calisma listesi
    //   modalitelerin ekranidir (kullanici).
    menuGrup: 'Radyoloji', menuAd: 'Çalışma Listesi', ic: '🖥️', yetkiKodu: 'radyoloji',
    menuSira: 10,
  },
  {
    // RAPOR SABLONLARI (283/288): bolum iskeleti, makrolar ve skor alanlari.
    //   Sablon tetkike baglanir; rapor ekrani varsayilani kendiliginden yukler.
    kaynak: 'radyoloji-sablon', rota: 'radyoloji-sablon',
    baslik: 'Rapor Şablonları', yol: 'Radyoloji › Rapor Şablonları',
    kartYolu: '/radyoloji-sablon', kartBaslik: 'Rapor Şablonu',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Radyoloji', menuAd: 'Rapor Şablonları', ic: '📄', yetkiKodu: 'radyoloji',
    menuSira: 20,
  },
  // CARI grubu ana menude RADYOLOJIDEN SONRA (kullanici).
  {
    // KURUM ICMALI (289): SGK payi tek tek faturalanmaz, donem sonu toplanip
    //   tek fatura kesilir. Liste donemleri ve durumlarini gosterir.
    kaynak: 'kurum-icmal', rota: 'kurum-icmal', baslik: 'Kurum İcmalleri',
    yol: 'Cari › Kurum İcmalleri', aksiyonEkrani: 'icmal-liste',
    cipler: [
      { ad: 'Hazırlanıyor', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    toplam: ['toplam'],
    // Yalniz HBYS: donem icmali odeyen kurum (SGK/OSS) akisinin parcasi,
    //   ERP kurulumunda karsiligi yok (kullanici).
    urunModu: 2,
    menuGrup: 'Cari', menuAd: 'Kurum İcmalleri', ic: '🧾', yetkiKodu: 'kurum',
    menuSira: 45,
  },
  {
    // Kaynak id, API route ve yetki kodu 'cari' KALDI - Musteri Listesi kendi URL'ini
    // ('/cari') korur (eski link/rota kirilmasin); Tedarikci Listesi asagida AYNI
    // kaynagi farkli `rota` ile kullanir. Ekran artik SADECE musteri=1 gosterir
    // (sabitFiltre) - Tedarikci Listesi ayrildigi icin "ikisi birden" gorunumu gerekmiyor.
    kaynak: 'cari', baslik: 'Müşteriler', yol: 'Cari › Müşteriler', kartYolu: '/cari',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi' },
    sabitFiltre: { alan: 'musteri', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: true, tedarikci: false },
    // Mockup'ta (cari_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    // Yalniz ERP (kullanici): HBYS'de musterinin karsiligi HASTA listesidir,
    //   iki liste ayni tarafi iki adla gostermesin.
    urunModu: 1,
    menuGrup: 'Cari', menuAd: 'Müşteri Listesi', ic: '👥', yetkiKodu: 'cari',
  },
  {
    // Musteri Listesi'nin BIREBIR kopyasi (kullanici istegi) - ayni kaynak ('cari'),
    // ayni kart, farkli `rota`/kartYolu ('/tedarikci') + ters sabitFiltre.
    kaynak: 'cari', rota: 'tedarikci', baslik: 'Tedarikçiler', yol: 'Cari › Tedarikçiler',
    kartYolu: '/tedarikci',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi' },
    sabitFiltre: { alan: 'tedarikci', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: false, tedarikci: true },
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    menuGrup: 'Cari', menuAd: 'Tedarikçi Listesi', ic: '🚚', yetkiKodu: 'cari',
  },
  {
    // ANLASMALI KURUMLAR (249, kullanici: "cari altina musteri benzeri Kurumlar
    //   menusu liste ve karti olustur"). Kurum da bir cari - hastanin odemesini
    //   ustlenen taraf; sozlesme suresi/turu ve fiyat politikasi kartinda.
    kaynak: 'kurum', baslik: 'Kurumlar', yol: 'Cari › Kurumlar', kartYolu: '/kurum',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Kurum Ekstresi',
              tarihAlani: 'islemTarihi' },
    yeniKayitVarsayilanlari: { kurum: true, musteri: true },
    // Yalniz HBYS: anlasmali kurum (odeyen taraf) kavrami HBYS'ye ozgu.
    urunModu: 2,
    // Cari grubunun EN USTU (kullanici): HBYS'de en cok girilen liste.
    //   Sirasiz ogeler 900+ ile diziliyor, 10 hepsinin onune gecer.
    menuSira: 10,
    // Ham tur kolonu API'den geliyor (basvuru "Ödeyen Tipi" suzmesi icin) ama
    //   gridde gorunmesin - turAdi zaten var.
    gizliKolonlar: ['tur'],
    menuGrup: 'Cari', menuAd: 'Kurumlar', ic: '🏛️', yetkiKodu: 'kurum',
  },
  {
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi; GenGrid zaten duz grid (mockup'taki sag "Secili Kisi" paneli hic
    // yapilmadi, ozel bir "sadelestirme" gerekmedi).
    kaynak: 'kisi', baslik: 'Kisiler', yol: 'Cari › Kisiler', kartYolu: '/kisi',
    aksiyonEkrani: 'kisi-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Cari', menuAd: 'Kişi Listesi', ic: '🧑', yetkiKodu: 'cari',
  },
  {
    kaynak: 'proje', baslik: 'Projeler', yol: 'CRM › Projeler', kartYolu: '/proje',
    aksiyonEkrani: 'proje-liste',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    // Grup CRM: musteri iliskileri basligi altinda projeler (kullanici karari).
    menuGrup: 'CRM', menuAd: 'Projeler', ic: '📁', yetkiKodu: 'proje', menuSira: 30,
  },
  {
    // GOREV / HATIRLATMA / TAKVIM (db/108) - ana sayfa panelini besleyen kayitlar.
    kaynak: 'gorev', baslik: 'Görevler', yol: 'CRM › Görevler', kartYolu: '/gorev',
    aksiyonEkrani: 'gorev-liste',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'CRM', menuAd: 'Görevler', ic: '✅', yetkiKodu: 'gorev', menuSira: 40,
  },
  {
    // SATIS FIRSATI (db/121, mockup firsat_karti/firsat_listesi.html) - teklif
    //   ONCESI surec. Cipler huninin durumu: acik firsatlar, kazanilan, kaybedilen.
    kaynak: 'firsat', baslik: 'Satış Fırsatları', yol: 'CRM › Satış Fırsatları',
    kartYolu: '/firsat', aksiyonEkrani: 'firsat-liste',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kazanılan',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kaybedilen',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tumu' },
    ],
    toplam: ['tahminiTutar', 'agirlikliTutar'],
    yerTutucuSekmeler: ['Teklifler', 'Yorum / Medya', 'Ek Alanlar'],
    menuGrup: 'CRM', menuAd: 'Satış Fırsatları', ic: '🎯', yetkiKodu: 'firsat', menuSira: 20,
  },
  {
    // ADAY MÜŞTERİLER (db/122): henuz musteri olmayan firmalar. AYNI taraf
    //   tablosu - anlasma saglaninca kayit tasinmaz, yalniz bayrak degisir
    //   (musteri=1, aday=0) ve Musteri Listesi'nde gorunmeye baslar.
    // Kaynak ve yetki AYRI ('aday'): satici rolu CRM'i gorurken Cari
    //   listelerini gormesin (kullanici).
    kaynak: 'aday', baslik: 'Aday Müşteriler',
    yol: 'CRM › Aday Müşteriler', kartYolu: '/aday', aksiyonEkrani: 'aday-liste',
    sabitFiltre: { alan: 'aday', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { aday: true, musteri: false, tedarikci: false },
    // Bu ekrandaki her kayit ADAY: "Musteri"/"Tedarikci" kolonlari hep bos,
    //   yer kaplamaktan baska ise yaramiyor.
    //   VKN, e-Fatura ve Adres yok: aday henuz faturalanmiyor, adres kartta.
    gizliKolonlar: ['musteri', 'tedarikci', 'vkno', 'efatura', 'adres', 'teklifDurumAdi', 'teklifDurum'],
    // Once SAHIBI ve turu: kimin adayi, hangi kategoride.
    kolonSirasi: ['temsilci', 'kategori', 'unvan', 'telefon', 'eposta', 'ilce', 'il', 'kod', 'durum'],
    cipler: DURUM_CIPLERI,
    // ADAY KARTI SADE (kullanici karari): aday henuz musteri degil - fatura
    //   unvani/vergi dairesi, mali durum ve ek alanlar musteri olunca anlamli.
    //   Kod da gizli: aday icin kod uydurmak gereksiz, kaydedince id atanir.
    //   Musteri/Tedarikci kutulari da yok: aday henuz ikisi de degil, rol
    //   donusumde (Müşteriye Dönüştür) belirlenir.
    //   "Aday" kutusu da gizli: bu ekrandaki her kayit zaten aday, kutu bilgi
    //   vermiyor ama yanlislikla kapatilirsa kayit listeden DUSER.
    //   Cep telefonu ve Web de yok: adayda tek telefon + e-posta yeter,
    //   ayrinti musteri olunca girilir.
    gizliKartAlanlari: ['kod', 'musteri', 'tedarikci', 'aday', 'cepTel', 'epostaWeb'],
    gizliKartSekmeleri: ['Fatura Bilgileri'],
    //   Temsilci ZORUNLU: sahipsiz aday takipsiz kalir (varsayilan karti acan
    //   kullanici). Musteri kartinda zorunlu DEGIL - eski kayitlarin cogunda bos.
    zorunluKartAlanlari: ['temsilci'],
    yerTutucuSekmeler: ['Yorum / Medya'],
    menuGrup: 'CRM', menuAd: 'Aday Müşteriler', ic: '🌱', yetkiKodu: 'aday', menuSira: 10,
  },
  {
    // KATEGORILER (270): stok VE hizmet ayni agaci kullanir; sinirsiz derinlik.
    kaynak: 'kategori', baslik: 'Kategoriler', yol: 'Yönetim › Kategoriler',
    kartYolu: '/kategori', aksiyonEkrani: 'cari-liste',
    menuGrup: 'Yönetim', menuAd: 'Kategoriler', ic: '🌳', yetkiKodu: 'stok',
  },
  {
    // KAMPANYALAR (268, kullanici: "ayarlara liste ve kart olarak ekle"):
    //   fiyat listesi uzerine isleyen indirim kurallari; kurum sozlesmesinde
    //   secilir.
    kaynak: 'kampanya', baslik: 'Kampanyalar', yol: 'Yönetim › Kampanyalar',
    kartYolu: '/kampanya', aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Yönetim', menuAd: 'Kampanyalar', ic: '🏷️', yetkiKodu: 'fiyat_listesi',
  },
  {
    // DEPARTMANLAR (251): personel departmani ve randevu bolumu AYNI tablo -
    //   "Randevu Bölümü" isaretli olanlar randevu kartinin Bölüm listesinde.
    // 255: iki bolmeli ozel ekran (solda departman, sagda gorev) - duz liste
    //   degil; kullanici "Departman listesi ekranini 2'ye bol" dedi.
    kaynak: 'departman', baslik: 'Bölüm / Görev', yol: 'Yönetim › Bölüm / Görev',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAd: 'Bölüm / Görev', ic: '🏢', yetkiKodu: 'personel',
  },
  {
    // SATIS TEKLIFI (216, Ekranlar/teklif_listesi.html): belge turu 18 -
    //   stok/cari/fis ETKILEMEZ, kalem/toplam altyapisi belgeden. Mockup'taki
    //   revizyon/onay akisi ileride; ilk surum ekle/ac/sil.
    kaynak: 'belge', rota: 'teklif', baslik: 'Satış Teklifleri', yol: 'Satis › Satış Teklifleri',
    aksiyonEkrani: 'teklif-liste', yeniBelgeTuru: 18,
    // Teklif yalniz Gentegre AI (ERP) modunda (kullanici).
    urunModu: 1,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 18 },
    // e-Fatura/kapanma teklif icin anlamsiz.
    // 'kaynak' teklifte anlamsiz (zincirin BASI); belge durum rozeti (Pasif)
    //   yerine teklif akisinin "Durumu" kolonu gosterilir (kullanici).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'kapanmaAdi', 'kapanmaDurum',
                    'kaynak', 'durumAdi', 'durum', 'tipi', 'belgeSeri', 'tarafId'],
    // Sira (kullanici): Satış Temsilcisi | Durumu | Belge No en solda.
    //   kolonSirasi ayni zamanda ZORUNLU gorunurluk: kayitli kolon secimi
    //   'belge' kaynagini fatura/siparis listeleriyle paylasiyor - Durumu ve
    //   Temsilci onsuz hic cikmazdi.
    kolonSirasi: ['saticiAdi', 'teklifKonusu', 'teklifDurumAdi', 'belgeNo', 'belgeTarihi', 'tarafUnvan'],
    toplam: ['genelToplam'],
    // Durum cipleri (kullanici): arama editinin altinda Tumu + teklif akisi.
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Hazırlanıyor', filtre: { alan: 'teklifDurum', op: 'esit', deger: 1 } },
      { ad: 'Sunuldu',      filtre: { alan: 'teklifDurum', op: 'esit', deger: 2 } },
      { ad: 'Kabul',        filtre: { alan: 'teklifDurum', op: 'esit', deger: 3 } },
      { ad: 'Red',          filtre: { alan: 'teklifDurum', op: 'esit', deger: 4 } },
      { ad: 'İptal',        filtre: { alan: 'teklifDurum', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Teklifleri', ic: '📄', yetkiKodu: 'belge', menuSira: 5,
  },
  {
    // Siparisler AYNI 'belge' kaynagi, tur in (9,19) sabit filtresiyle (Musteri/
    //   Tedarikci deseni). "Kalan" takibi belge_satir.kapatilan_miktar uzerinden;
    //   "Dönüştür" aksiyonu secili siparisten irsaliye/fatura uretir (F8).
    // GenoTIP'te bu liste GORUNMEZ: ayni tur orada "Başvurular" ekraniyla
    //   yonetilir (279) - iki menu ayni belgeleri iki adla gostermesin.
    kaynak: 'belge', rota: 'siparis', baslik: 'Satış Siparişleri', yol: 'Satis › Satış Siparişleri',
    aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 19, urunModu: 1,
    // Menude "Satis Siparisleri" seciliyse liste de yalniz SATIS siparisi (19)
    //   gostersin; tur kolonlari o yuzden gereksiz (alis siparisi ayri ekran).
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 19 },
    // e-Fatura durumu SIPARISTE anlamsiz (siparis e-Belge degil).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Siparişleri', ic: '📋', yetkiKodu: 'belge',
  },
  {
    // Satis irsaliyeleri (Ekranlar/satis_irsaliye_listesi.html): AYRI kaynak
    //   ('irsaliye') - sevkiyat odakli kolonlar (arac/sofor, cikis deposu,
    //   kaynak siparis, faturalama durumu). Ekran satisa daraltir (tur=14).
    kaynak: 'irsaliye', rota: 'satis-irsaliye', baslik: 'Satış İrsaliyeleri',
    yol: 'Satis › Irsaliyeler', aksiyonEkrani: 'irsaliye-liste',
    ebelgeMenusu: 'E-İrsaliye',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 14 },
    yeniBelgeTuru: 14,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuAd: 'Satış İrsaliyeleri', ic: '🚚', yetkiKodu: 'belge',
  },
  {
    // "Satış" grubu, Cari'nin HEMEN ALTINDA (kullanici istegi) - "Belgeler" ayni kaynak/
    // ekran, sadece grup+menu adi degisti (filtre/kapsam AYNI - hala hem satis hem alis
    // faturalarini gosterir, cip'lerle (Tumu/Satis/Alis) secilir; "kopyala" DENMEDI).
    // Menude "Satis Faturalari" seciliyken liste de YALNIZ satis faturasi
    //   gostermeli (irsaliye/alis karisinca kullanici hangi ekranda oldugunu
    //   kaybediyordu) ve baslik menu adiyla ayni olmali.
    kaynak: 'belge', baslik: 'Satış Faturaları', yol: 'Satis › Satış Faturaları',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 15, ebelgeMenusu: 'E-Fatura',
    // Tur / Belge Turu kolonlari bu ekranda ayni degeri tekrarliyor (hepsi
    //   satis faturasi) - iade ayrimi cip seridinde zaten var.
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    // Yalniz SATIS FATURASI (15). 16 "Satis Fisi" ayri ekran; iade ise ayri tur
    //   degil, belge.tipi = 2 - cipler onu kullanir.
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 15 },
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Faturaları', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // GELEN e-BELGE KUTUSU (187): bize kesilen e-Fatura / e-Arsiv belgeleri.
    //   Kart YOK - belge bizim degil; cift tik gonderenin goruntusunu acar.
    kaynak: 'gelen-belge', rota: 'gelen-belge', baslik: 'Gelen Kutusu',
    yol: 'Alis › Gelen Kutusu', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    cipler: [
      { ad: 'Yanıt Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 100 } },
      { ad: 'Kabul',          filtre: { alan: 'durum', op: 'esit', deger: 101 } },
      { ad: 'Red',            filtre: { alan: 'durum', op: 'esit', deger: 102 } },
      { ad: 'Tumu' },
      // Geri donus: iki liste tek ekranin iki sekmesi gibi calissin.
      { ad: '🧾 Alış Faturaları', rota: 'alis-fatura' },
    ],
    // MENUDE YOK (kullanici): Alis Faturalari > "Gelen Kutusu" sekmesinden
    //   girilir; menude ikinci bir giris ayni ekrani iki yerde gosterirdi.
    menuGizli: true,
    menuGrup: 'Alış', menuAd: 'Gelen Kutusu', ic: '📥', yetkiKodu: 'belge',
  },
  {
    // SATIS FISI (tur 16): perakende/pesin satis. Fatura ile ayni kart ve ayni
    //   akis - fark yalniz belge turu ve numara serisi. Muhasebe fisi URETIR
    //   (kasa_islem_turu.fis_mi = 1), belge fisleme F7'de baglanacak.
    kaynak: 'belge', rota: 'satis-fisi', baslik: 'Satış Fişleri',
    yol: 'Satis › Satış Fişleri', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 16,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 16 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fiş',  filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Fişleri', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // TAHAKKUK (13 alacak / 17 borc): cari bakiyeyi ve ekstreyi etkiler ama
    //   MUHASEBE FISI URETMEZ (db/098) - gerceklesen islem geldiginde muhasebe
    //   onunla yazilir. Stok da etkilemez.
    // SATIS tarafi: ALACAK tahakkuku (13). Borc tahakkuku (17) Alis grubunda.
    kaynak: 'belge', rota: 'tahakkuk', baslik: 'Alacak Tahakkukları',
    yol: 'Satis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 13,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 13 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Satış', menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    // SATIS KONSINYE (tur 119 Giden Konsinye): musteriye BIRAKILAN mal.
    //   Stok ve cari etkiler; satildikca faturaya donusur (F8 zinciri).
    kaynak: 'belge', rota: 'satis-konsinye', baslik: 'Satış Konsinyeler',
    yol: 'Satis › Konsinye', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 119,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 119 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
    ],
    // Yalniz HBYS (kullanici): konsinye takibi tibbi malzeme/implant akisinda
    //   kullaniliyor, ERP kurulumunda menude yer kaplamasin.
    urunModu: 2,
    menuGrup: 'Satış', menuAd: 'Satış Konsinyeler', ic: '📦', yetkiKodu: 'belge',
  },
  // ------------------------------------------------------------- ALIS ----
  //  Satis tarafinin birebir karsiligi: ayni 'belge' kaynagi, ayni kart, yalniz
  //  tur farkli (9/10/11/12/17/109). Kartta cari etiketi "Tedarikçi" olur.
  {
    kaynak: 'belge', rota: 'alis-siparis', baslik: 'Alış Siparişleri',
    yol: 'Alis › Siparişler', aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 9,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 9 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuAd: 'Alış Siparişleri', ic: '📋', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-irsaliye', baslik: 'Alış İrsaliyeleri',
    yol: 'Alis › İrsaliyeler', aksiyonEkrani: 'irsaliye-liste', yeniBelgeTuru: 10,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 10 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuAd: 'Alış İrsaliyeleri', ic: '🚛', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-fatura', baslik: 'Alış Faturaları',
    yol: 'Alis › Faturalar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 11,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 11 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      // Bize KESILEN e-Faturalar (187): ayni serit, ayri kaynak. Alis
      //   faturasi olarak islenecek belgeler once burada gorunur.
      { ad: '📥 Gelen Kutusu', rota: 'gelen-belge', kosul: 'ebelge' },
    ],
    menuGrup: 'Alış', menuAd: 'Alış Faturaları', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-fisi', baslik: 'Alış Fişleri',
    yol: 'Alis › Fişler', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 12,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 12 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    menuGrup: 'Alış', menuAd: 'Alış Fişleri', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // ALIS tarafi: BORC tahakkuku (17) - tedarikciye borc.
    kaynak: 'belge', rota: 'borc-tahakkuk', baslik: 'Borç Tahakkukları',
    yol: 'Alis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 17,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 17 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Alış', menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-konsinye', baslik: 'Alış Konsinyeler',
    yol: 'Alis › Konsinye', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 109,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 109 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Alış', menuAd: 'Alış Konsinyeler', ic: '📦', yetkiKodu: 'belge',
  },
  {
    // "Hangi siparisin nesi teslim edilmedi" - satir bazli acik liste.
    kaynak: 'belge-acik-satir', baslik: 'Açık Sipariş Satırları', yol: 'Satis › Acik Satirlar',
    toplam: ['miktar', 'kapatilanMiktar', 'kalanMiktar'],
    menuGrup: 'Satış', menuAd: 'Açık Satırlar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    // Kasa alt sisteminin ANA ekrani (F2): makbuz seviyesindeki islemler.
    //   Karti generic GenForm degil, kendi sayfasi (KasaIslemKarti) - tur sablonu,
    //   bacaklar ve muhasebe fisi paneli generic karta sigmiyor.
    kaynak: 'kasa-islem', baslik: 'Kasa İşlemleri', yol: 'Kasa › İşlemler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'kasa-liste',
    toplam: ['yerelTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Tahsilat', filtre: { alan: 'turGrup', op: 'esit', deger: 'tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turGrup', op: 'esit', deger: 'odeme' } },
      { ad: 'Taslak',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Plan',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
    ],
    menuGrup: 'Kasa', menuAd: 'Kasa İşlemleri', ic: '🧾', yetkiKodu: 'kasa_islem',
  },
  {
    // Acik planlar (v_plan_vade): beklenen tahsilat/odemeler, en yakin vade ustte.
    //   "Gerceklestir" plan kaydini DEGISTIRMEZ - yeni bir islem acar (K10).
    kaynak: 'plan-vade', baslik: 'Vade / Planlar', yol: 'Kasa › Vadeler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'plan-liste',
    toplam: ['tutar', 'gerceklesenTutar', 'kalanTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Vadesi Geçmiş', filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      { ad: 'Tahsilat', filtre: { alan: 'turAdi', op: 'icerir', deger: 'Tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turAdi', op: 'icerir', deger: 'Ödeme' } },
    ],
    menuGrup: 'Kasa', menuAd: 'Vade / Planlar', ic: '📅', yetkiKodu: 'kasa_islem',
  },
  {
    // "Kasa" grubu, Satış'in HEMEN ALTINDA (kullanici istegi) - "Cari Hareketleri"
    // (mali-hareket) yeniden adlandirildi: hem sayfa basligi hem menu adi "Kasa
    // Hareketleri" oldu (Satış'in aksine kullanici burada baslik metnini ACIKCA verdi).
    kaynak: 'mali-hareket', baslik: 'Kasa Hareketleri', yol: 'Kasa › Hareketler',
    toplam: ['borc', 'alacak'],
    menuGrup: 'Kasa', menuAd: 'Kasa Hareketleri', ic: '💰', yetkiKodu: 'mali_hareket',
  },
  // --- Hesaplar: TEK kaynak ('hesap'), tur'e gore 5 ayri ekran. Musteri/Tedarikci
  //     deseninin aynisi: sabitFiltre + rota + yeniKayitVarsayilanlari.
  {
    kaynak: 'hesap', rota: 'kasa-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Kasalar', yol: 'Kasa › Kasa Hesaplari',
    kartYolu: '/kasa-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'K' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'Kasa Hesapları', ic: '💵', yetkiKodu: 'hesap',
  },
  // --- BANKA grubu (kullanici istegi): banka tarafi Kasa'dan ayrildi. Kaynak
  //     yine tek 'hesap' tablosu, tur'e gore ayri ekranlar.
  {
    kaynak: 'hesap', rota: 'banka-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Banka Hesapları', yol: 'Banka › Hesaplar',
    kartYolu: '/banka-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'B' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Banka', menuAd: 'Banka Hesapları', ic: '🏦', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Krediler', yol: 'Banka › Krediler',
    kartYolu: '/kredi-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'R' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Banka', menuAd: 'Krediler', ic: '🏛️', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'pos-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'POS Hesapları', yol: 'Banka › POS',
    kartYolu: '/pos-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'P' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Banka', menuAd: 'POS', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-karti', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Kredi Kartları', yol: 'Banka › Kredi Kartlari',
    kartYolu: '/kredi-karti', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'V' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Banka', menuAd: 'Kredi Kartı', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    // BANKA TANIMLARI (db/109): hesap ve cek/senet kartlarindaki banka secimini
    //   besler. Subeler ayri ekran degil, banka kartinin detay tablosu.
    kaynak: 'banka', baslik: 'Banka Tanımları', yol: 'Banka › Tanımlar',
    kartYolu: '/banka', aksiyonEkrani: 'banka-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Banka', menuAd: 'Banka Tanımları', ic: '🏛️', yetkiKodu: 'hesap',
  },
  // CEK ve SENET AYRI listeler (kullanici karari): ayni `cek-senet` kaynagi,
  //   sabit filtre tur=1 / tur=2. Ikisi ayni tabloda durur cunku portfoy,
  //   ciro ve tahsil akislari birebir aynidir - degisen yalnizca kagit turu.
  {
    kaynak: 'cek-senet', rota: 'cek', baslik: 'Çekler', yol: 'Banka › Çekler',
    // kartYolu ROTA ile ayni olmali: kart rotasi `/${rota}/:id` uretiliyor.
    //   '/cek-senet' yazilinca "Ekle" tanimsiz rotaya gidip panele dusuyordu.
    kartYolu: '/cek', aksiyonEkrani: 'cek-senet-liste',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { tur: 1 },
    gizliKolonlar: ['tur', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['tutar'],
    cipler: [
      { ad: 'Portföy', filtre: { alan: 'durum', op: 'esit', deger: 10 } },
      { ad: 'Tahsilde', filtre: { alan: 'durum', op: 'esit', deger: 30 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'icinde', deger: [50, 70] } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Banka', menuAd: 'Çek Listesi', ic: '📃', yetkiKodu: 'cek_senet',
  },
  {
    kaynak: 'cek-senet', rota: 'senet', baslik: 'Senetler', yol: 'Banka › Senetler',
    kartYolu: '/senet', aksiyonEkrani: 'cek-senet-liste',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 2 },
    yeniKayitVarsayilanlari: { tur: 2 },
    gizliKolonlar: ['tur', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['tutar'],
    cipler: [
      { ad: 'Portföy', filtre: { alan: 'durum', op: 'esit', deger: 10 } },
      { ad: 'Tahsilde', filtre: { alan: 'durum', op: 'esit', deger: 30 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'icinde', deger: [50, 70] } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Banka', menuAd: 'Senet Listesi', ic: '🧾', yetkiKodu: 'cek_senet',
  },
  {
    // Yuruyen bakiyeli ekstre: hesap secimi URL'den gelir (?hesapId=), grid
    //   sabit tarih sirasinda kalir (bakiye kolonu siralanamaz - sunucu tarafi).
    kaynak: 'hesap-ekstre', baslik: 'Hesap Ekstresi', yol: 'Kasa › Hesap Ekstresi',
    // Para birimi gruplu (111): her grubun ara toplami + en altta genel toplam.
    //   Yerel kolonlar da toplanir - genel toplam ancak yerel parada anlamli.
    urlFiltreAlani: 'hesapId', toplam: ['giris', 'cikis', 'yerelBorc', 'yerelAlacak'],
    menuGrup: 'Kasa', menuAd: 'Hesap Ekstresi', ic: '📈', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'cari-ekstre', baslik: 'Cari Ekstre', yol: 'Kasa › Cari Ekstre',
    urlFiltreAlani: 'tarafId', toplam: ['borc', 'alacak', 'yerelBorc', 'yerelAlacak'],
    menuGrup: 'Kasa', menuAd: 'Cari Ekstre', ic: '🧮', yetkiKodu: 'mali_hareket',
  },
  {
    kaynak: 'masraf', baslik: 'Masraflar', yol: 'Stok › Masraflar', cipler: DURUM_CIPLERI,
    menuGrup: 'Kasa', menuAd: 'Masraf Listesi', ic: '🧾', yetkiKodu: 'masraf',
  },
  {
    // Kullanici: "Stok altına Stok Listesi [taşı]" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'stok', baslik: 'Stoklar', yol: 'Stok › Stok Karti', kartYolu: '/stok',
    aksiyonEkrani: 'stok-liste', cipler: DURUM_CIPLERI,
    // Mockup'ta (stok_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    //   Stok Durumu icin gercek tablo (stok_durum) var ama PK'si (stok_id,depo_id) -
    //   detay tablosu id kolonu varsayar, o yuzden bu da simdilik yer tutucu.
    // 'ÜTS Bilgileri' artik yer tutucu DEGIL - stok_uts (119) detayi olarak geliyor.
    yerTutucuSekmeler: ['Reçete', 'Stok Durumu', 'Hareketler', 'Yorum / Medya', 'Ek Alanlar'],
    resimYerTutucu: true,
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Listesi', ic: '📦', yetkiKodu: 'stok',
    menuSira: 10,
  },
  {
    // Hizmetler KASA'dan STOK menusune alindi (kullanici): hizmet de belgede
    //   satilan bir kalem - stokla ayni yerde aranir. Masraf Listesi kasada
    //   kaldi: o satis kalemi degil, gider kalemi.
    // kartYolu + aksiyonEkrani (kullanici): ekle/duzenle deseni - hizmet karti
    //   generic GenForm ile acilir, aksiyonlar hizmet-liste Crud'undan gelir.
    kaynak: 'hizmet', baslik: 'Hizmetler', yol: 'Stok › Hizmetler', kartYolu: '/hizmet',
    aksiyonEkrani: 'hizmet-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Stok & Hizmet', menuAd: 'Hizmet Listesi', ic: '🛠️', yetkiKodu: 'hizmet',
    menuSira: 20,
  },
  {
    // SATIS FIYAT LISTELERI (201): liste bir KURALDIR (taban liste x carpan ->
    //   yuvarlama), satirlari o kuralin materyalize halidir. "⟳ Listeyi Üret"
    //   satirlari yeniden yazar; MANUEL girilen satirlar korunur.
    kaynak: 'fiyat-listesi', baslik: 'Fiyat Listeleri', yol: 'Yönetim › Fiyat Listeleri',
    kartYolu: '/fiyat-listesi', aksiyonEkrani: 'fiyat-listesi-liste', cipler: DURUM_CIPLERI,
    // Kullanici: fiyat listeleri Yonetim altinda (tanim ekrani, gunluk stok isi degil).
    menuGrup: 'Yönetim', menuAd: 'Fiyat Listeleri', ic: '🏷️', yetkiKodu: 'fiyat_listesi',
    menuSira: 950,
  },
  {
    // Liste SATIRLARI ayri ekran: bir listenin binlerce satiri kart icinde
    //   rahat gezilmiyor. Menude gizli - listeden "Satırları Aç" ile gelinir.
    kaynak: 'fiyat-listesi-satir', baslik: 'Fiyat Listesi Satırları',
    yol: 'Yönetim › Fiyat Listesi Satırları', aksiyonEkrani: 'fiyat-listesi-satir-liste',
    urlFiltreAlani: 'listeId', menuGizli: true, yetkiKodu: 'fiyat_listesi',
    menuGrup: 'Yönetim', menuAd: 'Fiyat Listesi Satırları', ic: '🏷️',
  },
  {
    // ÜTS askidaki/gelen urunler (223): karsi kurumlarin bize VERDIGI tekil
    //   urunler. "Askıdakileri Getir" ÜTS'den senkronlar; satirdan "Alma
    //   Bildirimi Yap" ile alinir (askı adeti duser).
    kaynak: 'uts-envanter', baslik: 'ÜTS Askıdaki Ürünler',
    yol: 'Stok › ÜTS Askıdaki Ürünler', aksiyonEkrani: 'uts-envanter-liste',
    aramaGorunumGizli: true,
    cipler: [
      { ad: 'Askıda',   filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Alındı',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kayboldu', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    // Uc UTS ekrani "Stok & Hizmet > ÜTS" alt menusunde toplanir (kullanici).
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Gelen / Askıdakiler', ic: '🩺',
    yetkiKodu: 'uts', menuSira: 70,
  },
  {
    // ÜTS bildirim gecmisi (223): gonderilen alma/verme/kullanim bildirimleri,
    //   ham istek/cevap JSON'u Icerik penceresinde.
    kaynak: 'uts-bildirim', baslik: 'ÜTS Bildirimleri',
    yol: 'Stok › ÜTS Bildirimleri', aksiyonEkrani: 'uts-bildirim-liste',
    tarihAlani: 'tarih', icerikAlani: 'cevapJson', icerikBaslik: 'ÜTS Cevabı',
    aramaGorunumGizli: true,
    // "＋ Bildirim" dugmesine asagi acilir menu (kullanici).
    altSecenekler: {
      'uts.bildirim-menu': [
        { kod: 'uts.verme',    ad: '➤ Verme' },
        { kod: 'uts.kullanim', ad: '🧑‍⚕️ Kullanım' },
        { kod: 'uts.uretim',   ad: '🏭 Üretim' },
        { kod: 'uts.ithalat',  ad: '🚢 İthalat' },
        { kod: 'uts.hek',      ad: '⚠️ Kayıp / HEK' },
        { kod: 'uts.imha',     ad: '🔥 İmha / Bertaraf' },
      ],
    },
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Başarılı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Hatalı',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'İptal',    filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Bildirimler', ic: '📡',
    yetkiKodu: 'uts', menuSira: 71,
  },
  {
    // ÜTS urun sorgu (223): UNO/LNO/SNO ile ÜTS'den canli tekil urun sorgusu.
    //   Liste degil, kendi sayfasi (App.tsx rotayi tanimlar).
    kaynak: 'uts-sorgu', ozelSayfa: true, baslik: 'ÜTS Ürün Sorgu',
    yol: 'Stok › ÜTS Ürün Sorgu',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Ürün Sorgu', ic: '🔍',
    yetkiKodu: 'uts', menuSira: 72,
  },
  {
    // STOKTAN TALEP (tur 105): bir birim depodan mal ISTER. Stok ve cari
    //   ETKILEMEZ - asil hareketi, talep karsilaninca kesilen transfer yapar.
    //   Kart transferin kardesi: para yok, e-Belge yok; teslim eden yerine
    //   TALEP EDEN sorulur.
    kaynak: 'stok-talep', baslik: 'Stoktan Talepler',
    yol: 'Stok › Stoktan Talep', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 105,
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'kapanmaDurum', op: 'esitDegil', deger: 2 } },
      { ad: 'Karşılanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stoktan Talep', ic: '📥', yetkiKodu: 'belge',
    menuSira: 30,
  },
  {
    // DEPOLAR ARASI TRANSFER (tur 20): cari YOK, para YOK - tek satir cikis
    //   deposundan duser, giris deposuna eklenir. Kart BelgeKarti'nin transfer
    //   dalidir (fiyat/KDV/e-Belge sutunlari gizli).
    // kartYolu YOK: kart generic GenForm degil BelgeKarti (modal) - onSatirAc
    //   'stok-transfer' kaynagini da belge kartina yonlendirir.
    kaynak: 'stok-transfer', baslik: 'Stok Transferleri',
    yol: 'Stok › Stok Transfer', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 20,
    cipler: [{ ad: 'Tumu' }],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Transfer', ic: '🔄', yetkiKodu: 'belge',
    menuSira: 40,
  },
  {
    // GIRIS FISI (3) / CIKIS FISI (4): irsaliye gibi stok oynatan ama CARISIZ
    //   belgeler - fire, sarf, imha, sayim farki. Muhasebe fisi URETIRLER
    //   (kasa_islem_turu.fis_mi=1, F7'de baglanacak). TIPI fisin sebebidir.
    kaynak: 'giris-fis', baslik: 'Giriş Fişleri', yol: 'Stok › Giriş Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 3,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fire',          filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'Sayım Fazlası', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Giriş Fişi', ic: '📗', yetkiKodu: 'belge',
    menuSira: 50,
  },
  {
    kaynak: 'cikis-fis', baslik: 'Çıkış Fişleri', yol: 'Stok › Çıkış Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 4,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Sarf',         filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'İmha',         filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      { ad: 'Sayım Eksiği', filtre: { alan: 'tipi', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Çıkış Fişi', ic: '📕', yetkiKodu: 'belge',
    menuSira: 60,
  },
  {
    // Kullanici: "İK altına Personel Listesi taşı" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'personel', baslik: 'Personel', yol: 'IK › Personel', kartYolu: '/personel',
    aksiyonEkrani: 'personel-liste', cipler: DURUM_CIPLERI,
    // Ham bolum id API'den geliyor (basvuruda personel -> bolum doldurmak icin)
    //   ama gridde gorunmesin: orada departmanAdi var.
    gizliKolonlar: ['departmanId'],
    menuGrup: 'İK', menuAd: 'Personel Listesi', ic: '🧑‍🤝‍🧑', yetkiKodu: 'personel',
  },
  {
    // DEMIRBAS (216, Ekranlar/demirbas_listesi.html) - ana menude IK'nin
    //   ALTINDA TEK BASINA (kullanici; grupsuz duz oge). Iki modda ORTAK.
    kaynak: 'demirbas', baslik: 'Demirbaş', yol: 'Demirbaş',
    kartYolu: '/demirbas', aksiyonEkrani: 'demirbas-liste', cipler: DURUM_CIPLERI,
    yerTutucuSekmeler: ['Zimmet Geçmişi', 'Bakım / Servis', 'Amortisman'],
    menuAd: 'Demirbaş', ic: '🖥️', yetkiKodu: 'demirbas',
  },
  {
    // Kullanici: "e-Belge'yi de bir Yönetim altına".
    kaynak: 'e-belge', baslik: 'e-Belge Kuyrugu', yol: 'e-Belge › Kuyruk',
    menuGrup: 'Yönetim', menuAd: 'e-Belge', ic: '📨', yetkiKodu: 'e_belge',
  },
  {
    // Kullanici: "Yönetim altına Roller ve İşlem Günlüğü al".
    kaynak: 'islem-log', baslik: 'Islem Gunlugu', yol: 'Yonetim › Islem Gunlugu',
    icerikAlani: 'bilgi', icerikBaslik: 'Log İçeriği',
    // Islem tipi cipleri + tarih araligi (kullanici). Filtre ham kod
    //   kolonuyla (islemTipiKod) - gorunen "İşlem" SQL case metni.
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Ekleme',     filtre: { alan: 'islemTipiKod', op: 'esit', deger: 1 } },
      { ad: 'Değişiklik', filtre: { alan: 'islemTipiKod', op: 'esit', deger: 2 } },
      { ad: 'Silme',      filtre: { alan: 'islemTipiKod', op: 'esit', deger: 0 } },
    ],
    tarihAlani: 'tarih',
    menuGrup: 'Yönetim', menuAd: 'İşlem Günlüğü', ic: '📋', yetkiKodu: 'islem_log',
  },
  {
    // Muhasebe fisleri: kasa islemi/belge kesinlestikce OTOMATIK uretilir; buradan
    //   yalniz izlenir (elle fis girisi F4/F7 kapsaminda degil).
    kaynak: 'muhasebe-fis', baslik: 'Muhasebe Fişleri', yol: 'Yonetim › Muhasebe Fisleri',
    aksiyonEkrani: 'fis-liste', toplam: ['toplamBorc', 'toplamAlacak'],
    cipler: [
      { ad: 'Kayıtlı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Muhasebe Fişleri', ic: '📕', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'muhasebe-fis-satir', baslik: 'Fiş Satırları', yol: 'Yonetim › Fis Satirlari',
    // Belgeden "Muhasebe Fişini Aç" bu ekrana fisId ile gelir.
    urlFiltreAlani: 'fisId',
    toplam: ['borc', 'alacak'],
    menuGrup: 'Yönetim', menuAd: 'Fiş Satırları', ic: '📗', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'hesap-plani', baslik: 'Hesap Planı', yol: 'Yonetim › Hesap Plani',
    kartYolu: '/hesap-plani',
    cipler: [
      { ad: 'Çalışan', filtre: { alan: 'calisirMi', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Hesap Planı', ic: '📒', yetkiKodu: 'hesap_plani',
  },
  {
    kaynak: 'masraf-merkezi', baslik: 'Masraf Merkezleri', yol: 'Yonetim › Masraf Merkezleri',
    kartYolu: '/masraf-merkezi', cipler: DURUM_CIPLERI,
    menuGrup: 'Yönetim', menuAd: 'Masraf Merkezleri', ic: '🏷️', yetkiKodu: 'masraf_merkezi',
  },
  {
    // Islem turu katalogu: kasa hareketlerinin ekstre/fis davranisini VERI olarak
    //   tasir (bkz. 073). Salt gorunum - duzenleme yonetici isi, kart yok.
    kaynak: 'kasa-islem-turu', baslik: 'İşlem Türleri', yol: 'Yonetim › Islem Turleri',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'İşlem Türleri', ic: '⚙️', yetkiKodu: 'kasa_islem_turu',
  },
  {
    // Rol'un durum kolonu "durum" degil "aktif" - DURUM_CIPLERI (alan:'durum') buraya
    //   UYMAZ, kullanilmadi (yoksa "Bilinmeyen alan: durum" 400 verirdi).
    kaynak: 'rol', baslik: 'Roller', yol: 'Yonetim › Roller ve Yetkiler', kartYolu: '/rol',
    aksiyonEkrani: 'rol-liste',
    menuGrup: 'Yönetim', menuAd: 'Roller', ic: '🛡️', yetkiKodu: 'rol',
  },
  {
    // FIRMA / SUBE BILGILERI - mockup: Ekranlar/firma_bilgileri.html.
    //   e-Belgede GONDERICI TARAF buradan okunur (unvan, VKN, vergi dairesi,
    //   adres, gonderici etiketi). Cok subeli firmada fatura hangi subeden
    //   kesildiyse ONUN bilgileri gider.
    //   Duz liste DEGIL (ozelSayfa): ekran tek firmayi anlatir, subeler onun
    //   altinda bir tablodur (165 / FirmaBilgileri.tsx).
    kaynak: 'sube', baslik: 'Firma Bilgileri', yol: 'Yonetim › Firma Bilgileri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAd: 'Firma Bilgileri', ic: '🏢', yetkiKodu: 'sube',
  },
  {
    // Firma geneli DAVRANIS ayarlari (public.referans). Liste degil (ozelSayfa).
    kaynak: 'genel-ayarlar', baslik: 'Genel Ayarlar', yol: 'Yonetim › Ayarlar › Genel',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'Genel', menuSira: 1,
    ic: '⚙️', yetkiKodu: 'ayar',
  },
  {
    // Sekmeli AYAR ekrani - liste degil (ozelSayfa): Genel + Depolar. Menude
    //   Yönetim grubunun altinda "Ayarlar" alt basligiyla toplanir.
    kaynak: 'stok-ayarlar', baslik: 'Stok Ayarları', yol: 'Yonetim › Ayarlar › Stok Ayarlari',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'Stok Ayarları', menuSira: 2,
    ic: '📦', yetkiKodu: 'stok',
  },
  {
    // Kasa modulu ayarlari (149) - simdilik tek sekme: duzeltme gun siniri.
    kaynak: 'kasa-ayarlar', baslik: 'Kasa Ayarları', yol: 'Yonetim › Ayarlar › Kasa',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'Kasa', menuSira: 3,
    ic: '💵', yetkiKodu: 'kasa_islem',
  },
  {
    // Satis belgesi ayarlari: Genel + e-Belge (e-Belge yalniz GIDEN belgede).
    kaynak: 'satis-ayarlar', baslik: 'Satış Belgeleri', yol: 'Yonetim › Ayarlar › Satış Belgeleri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'Satış Belgeleri', menuSira: 4,
    ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // IK ayarlari (kullanici): Departman + Pozisyon kod listeleri duzenlenir.
    kaynak: 'ik-ayarlar', baslik: 'İK Ayarları', yol: 'Yonetim › Ayarlar › İK',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'İK', menuSira: 6,
    ic: '👥', yetkiKodu: 'personel',
  },
  {
    // Alis belgesi ayarlari: yalniz Genel - alis faturasini GIB'e biz gondermeyiz.
    kaynak: 'alis-ayarlar', baslik: 'Alış Belgeleri', yol: 'Yonetim › Ayarlar › Alış Belgeleri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Ayarlar', menuAd: 'Alış Belgeleri', menuSira: 5,
    ic: '📥', yetkiKodu: 'belge',
  },
];
