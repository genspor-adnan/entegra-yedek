import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * YATAN HASTA MODÜLÜ — db/695-696, mockuplar `Ekranlar/Yatan/*.html`.
 *
 * Yatan hasta, ayaktan hastanın uzun hâli değildir: ayaktanda iş bir muayeneyle
 * başlar ve aynı gün biter; yatanda iş SAAT SAAT SÜREN BİR İZLEMDİR. Ekranlar
 * bu yüzden dört soruya göre ayrıldı — "serviste kim yatıyor", "yer var mı",
 * "hangi doz gecikti", "hangi talimat imzasız".
 *
 * Menü sırası günün akışı: Yatan Hastalar → Yatak Panosu → Order → Doz Kuyruğu
 * → (Ayarlar) Odalar / Yataklar.
 *
 * ÜRÜN MODU 2 (HBYS): klinik yatış ERP kurulumunda yoktur - rotası da açılmaz.
 */
export const YATAN_LISTELERI: ListeGirdisi[] = [
  {
    // YATAN HASTALAR - modülün ana çalışma ekranı. Hekim vizitte, hemşire
    //   nöbet devrinde, başhemşire yatak planlarken aynı listeye bakar;
    //   üçünün de ilk sorusu "kim, nerede, kaçıncı gün".
    kaynak: 'yatan', rota: 'yatan', baslik: 'Yatan Hastalar',
    yol: 'Yatan Hasta › Servis Listesi',
    kartYolu: '/yatan', kartBaslik: 'Yatış',
    tarihAlani: 'girisTarihi', aksiyonEkrani: 'yatan-liste',
    cipler: [
      { ad: 'Yatakta',          filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Yatış kabul',      filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Taburcu planlı',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Taburcu',          filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'Yatan Hastalar', ic: '🛏️',
    yetkiKodu: 'yatan', menuSira: 10,
  },
  {
    // YATAK PANOSU - "yer var mı" sorusu. Satır YATAKTIR, hasta değil:
    //   doluluk, temizlik ve kapalı yatak yatağın kendi durumudur.
    //   Kanban görünümü üst panelde (Liste.tsx).
    kaynak: 'yatak', rota: 'yatak', baslik: 'Yatak Panosu',
    yol: 'Yatan Hasta › Yatak Panosu',
    kartYolu: '/yatak', kartBaslik: 'Yatak', aksiyonEkrani: 'yatak-liste',
    cipler: [
      { ad: 'Boş',              filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Dolu',             filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Temizlik bekleyen',filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Kapalı',           filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Bugün boşalacak',  filtre: { alan: 'bugunBosalacak', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'Yatak Panosu', ic: '🗺️',
    yetkiKodu: 'yatan', menuSira: 20,
  },
  {
    // ORDER'LAR - servis genelinde açık talimatlar. Listenin iki işi:
    //   İMZASIZ SÖZEL ORDER'ları ve süresi dolan talimatları göstermek.
    //   Tek hastanın order'ı yatış kartında okunur.
    kaynak: 'yatis-order', rota: 'yatis-order', baslik: 'Order Listesi',
    yol: 'Yatan Hasta › Order',
    kartYolu: '/yatis-order', kartBaslik: 'Order',
    tarihAlani: 'baslangic', aksiyonEkrani: 'yatis-order-liste',
    cipler: [
      { ad: 'Aktif',           filtre: { alan: 'durum',   op: 'esit', deger: 1 } },
      { ad: 'İmzasız sözel',   filtre: { alan: 'imzasiz', op: 'esit', deger: 1 } },
      { ad: 'İlaç',            filtre: { alan: 'tur',     op: 'esit', deger: 1 } },
      { ad: 'Tetkik',          filtre: { alan: 'tur',     op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'Order', ic: '🩺',
    yetkiKodu: 'yatan.order', menuSira: 30,
  },
  {
    // DOZ KUYRUĞU (eMAR) - "hangi doz ne zaman, verildi mi". Satır PLANLANAN
    //   DOZDUR ve order kaydedilirken önceden üretilir: plan görünmeden takip
    //   olmaz, sonradan üretilen satır atlanmış dozu gizler.
    kaynak: 'order-uygulama', rota: 'order-uygulama', baslik: 'Doz Kuyruğu',
    yol: 'Yatan Hasta › İlaç Uygulama',
    // DOZ SATIRI ELLE AÇILMAZ/SİLİNMEZ: plan order'dan üretilir (698).
    //   Listede yalnız "uygulandı" ve "atlandı" var - kart yolu da yok.
    tarihAlani: 'planlanan', aksiyonEkrani: 'order-uygulama-liste',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Geciken',   filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Uygulandı', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Atlanan',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'İlaç Uygulama', ic: '💊',
    yetkiKodu: 'yatan.order', menuSira: 40,
  },
  {
    // HEMŞİRE İZLEMİ - servis genelinde ÖLÇÜM satırları. Listenin işi eşiği
    //   aşan ölçümü yüzeye çıkarmak (erken uyarı ≥ 5 satırı kırmızı);
    //   tek hastanın eğrisi üstteki nöbet panelinde okunur.
    kaynak: 'yatis-izlem', rota: 'yatis-izlem', baslik: 'Hemşire İzlem',
    yol: 'Yatan Hasta › İzlem',
    // ÖLÇÜM VE GÖZLEM HUKUKİ KAYITTIR: düzeltilmez, silinmez - yanlış kayıt
    //   yeni bir satırla düzeltilir. Kart yolu yok, CRUD yok; giriş üstteki
    //   nöbet panelinden yapılır.
    tarihAlani: 'zaman', aksiyonEkrani: 'yatis-izlem-liste',
    cipler: [
      { ad: 'Bugün' },
      { ad: 'Eşiği aşan', filtre: { alan: 'erkenUyari', op: 'buyukEsit', deger: 5 } },
      { ad: 'Bildirilmemiş', filtre: { alan: 'bildirildi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'Hemşire İzlem', ic: '📋',
    yetkiKodu: 'yatan.izlem', menuSira: 35,
  },
  {
    // HİZMET İCMALİ - "bu yatış ne kadar tuttu, ne faturalandı". Satır GÜN
    //   SONU TAHAKKUKUDUR; tek yatışın tam icmali üstteki panelde okunur.
    kaynak: 'yatis-tahakkuk', rota: 'yatis-tahakkuk', baslik: 'Hizmet İcmali',
    yol: 'Yatan Hasta › Hizmet İcmali',
    // TAHAKKUK ELLE GİRİLMEZ, gün sonu işinden düşer: elle giriş açık olsaydı
    //   aynı gün hem otomatik hem elle iki kez faturalanırdı.
    tarihAlani: 'tarih', aksiyonEkrani: 'yatis-tahakkuk-liste',
    cipler: [
      { ad: 'Faturalanmamış', filtre: { alan: 'faturalandi', op: 'esit', deger: 0 } },
      { ad: 'Faturalanan',    filtre: { alan: 'faturalandi', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    toplam: ['tutar'],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAd: 'Hizmet İcmali', ic: '🧾',
    yetkiKodu: 'yatan', menuSira: 50,
  },
  {
    // ODALAR AYARLARIN ALTINDA: kurulum işi. Kural odanın (cinsiyet,
    //   izolasyon, ücret sınıfı), yatak odanın içinde.
    kaynak: 'oda', rota: 'oda', baslik: 'Odalar',
    yol: 'Yatan Hasta › Ayarlar › Odalar',
    kartYolu: '/oda', kartBaslik: 'Oda', aksiyonEkrani: 'oda-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yatan Hasta', menuAltGrup: 'Ayarlar', menuAd: 'Odalar', ic: '🚪',
    yetkiKodu: 'yatan.yatak', menuSira: 90,
  },
];
