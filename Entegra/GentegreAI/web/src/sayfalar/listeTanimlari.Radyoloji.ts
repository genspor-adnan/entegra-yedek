import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Radyoloji: çalışma listesi, şablonlar, protokoller, cihazlar.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const RADYOLOJI_LISTELERI: ListeGirdisi[] = [
  {
    // RADYOLOJI CALISMA LISTESI (283): modulun giris ekrani - rapor yazma,
    //   PACS acma ve onay buradan baslar. Cipler gunun isini bolumler:
    //   once cekilecekler, sonra raporlanacaklar, sonra onay bekleyenler.
    kaynak: 'radyoloji-istem', rota: 'radyoloji', baslik: 'Radyoloji Çalışma Listesi',
    yol: 'Radyoloji › Çalışma Listesi',
    // Kart rotasi LISTE ROTASINDAN turetilir (/radyoloji/:id) - kartYolu farkli
    //   yazilirsa cift tik tanimsiz rotaya gider ve ana sayfaya duser.
    kartYolu: '/radyoloji', kartBaslik: 'Radyoloji İstemi',
    // Cekim oncesi kontrol listesi (310) kart DETAYI degil: sorular
    //   modaliteye gore uretilir, satir ekle/sil'li grid yanlis olurdu.
    yerTutucuSekmeler: ['Kontrol Listesi'],
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
    // EN USTTE (kullanici): radyolojinin gunluk isi burada - istem de
    //   bu ekranin arac cubugundan acilir (ayri istem ekrani yok).
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
    menuGrup: 'Radyoloji', menuAltGrup: 'Ayarlar', menuAd: 'Rapor Şablonları', ic: '📄', yetkiKodu: 'radyoloji',
    menuSira: 90,
  },
  {
    // ÇEKİM PROTOKOLÜ (314): tetkikin nasıl çekileceği - süre randevu
    //   kapasitesini, hazırlık metni hastaya verilen talimatı, özel uyarı
    //   da çekim öncesi sorulması gerekeni besler. Protokolü olmayan
    //   tetkikte modalite varsayılanı (311) devreye girer.
    kaynak: 'radyoloji-protokol', baslik: 'Çekim Protokolleri',
    yol: 'Radyoloji › Çekim Protokolleri',
    kartYolu: '/radyoloji-protokol', kartBaslik: 'Çekim Protokolü',
    aksiyonEkrani: 'cari-liste',
    gizliKolonlar: ['modalite', 'hizmetId', 'hazirlikMetni', 'ozelUyari'],
    menuGrup: 'Radyoloji', menuSira: 91, menuAltGrup: 'Ayarlar', menuAd: 'Çekim Protokolleri', ic: '⚙️',
    yetkiKodu: 'radyoloji', urunModu: 2,
  },
  {
    // CİHAZLAR (283/315): radyolojinin kaynağı - randevu ona verilir, MWL
    //   ona iner, çekim onda yapılır. Kart randevu ayarlarını (mesai, slot,
    //   çalışma günü) ve kapatma/bakım takvimini taşır.
    kaynak: 'radyoloji-cihaz', baslik: 'Cihazlar',
    yol: 'Radyoloji › Cihazlar',
    kartYolu: '/radyoloji-cihaz', kartBaslik: 'Radyoloji Cihazı',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    gizliKolonlar: ['modalite', 'subeId'],
    menuGrup: 'Radyoloji', menuSira: 92, menuAltGrup: 'Ayarlar', menuAd: 'Cihazlar', ic: '🖥️',
    yetkiKodu: 'radyoloji', urunModu: 2,
  },
  {
    // RADYOLOJİ PANOSU (320): modülün "bugün ne durumdayız" ekranı. Liste
    //   değil (ozelSayfa) - sayaç, doluluk ve uyarı kutularından oluşur;
    //   her sayaç ilgili listeye götürür.
    kaynak: 'radyoloji-pano', rota: 'radyoloji-pano', ozelSayfa: true,
    baslik: 'Radyoloji Panosu', yol: 'Radyoloji › Pano',
    urunModu: 2,
    menuGrup: 'Radyoloji', menuAd: 'Pano', ic: '📊',
    yetkiKodu: 'radyoloji', menuSira: 20,
  },
  {
    // KRİTİK BULGU TAKİBİ (318): hasta güvenliği listesi. Satır bildirim
    //   kaydı değil, kritik işaretli İSTEM - "işaretlendi ama haber
    //   verilmedi" boşluğu tam da burada görünür.
    kaynak: 'radyoloji-kritik', rota: 'radyoloji-kritik',
    baslik: 'Kritik Bulgular', yol: 'Radyoloji › Kritik Bulgular',
    aksiyonEkrani: 'radyoloji-kritik-liste',
    // Cift tik ISTEM kartini acar: bu listelerin kendi karti yok, satirin
    //   kimligi zaten istem_id (kart rotasi radyoloji listesine gider).
    kartYolu: '/radyoloji', kartBaslik: 'Radyoloji İstemi',
    gizliKolonlar: ['modalite', 'takipDurum', 'bildirimId', 'hastaId', 'istemId'],
    cipler: [
      { ad: 'Bildirilmedi',   filtre: { alan: 'takipDurum', op: 'esit', deger: 1 } },
      { ad: 'Teyit Bekleyen', filtre: { alan: 'takipDurum', op: 'esit', deger: 2 } },
      // Teyit ALINDI ama takip kapatilmadi: is bitmis sayilmaz - kapatma
      //   ayri bir adim (kapatan kisi ve zamani kayda gecer).
      { ad: 'Teyitli',        filtre: { alan: 'takipDurum', op: 'esit', deger: 3 } },
      { ad: 'Kapatılan',      filtre: { alan: 'takipDurum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Radyoloji', menuAd: 'Kritik Bulgular', ic: '🚨',
    yetkiKodu: 'radyoloji', menuSira: 30,
  },
  {
    // KONSÜLTASYON TAKİBİ (318): cevap bekleyen ikinci görüşler. Cevaplanmayan
    //   konsültasyon raporu da askıda tutar.
    kaynak: 'radyoloji-konsultasyon', rota: 'radyoloji-konsultasyon',
    baslik: 'Konsültasyonlar', yol: 'Radyoloji › Konsültasyonlar',
    aksiyonEkrani: 'radyoloji-konsultasyon-liste',
    // Cift tik ISTEM kartini acar: bu listelerin kendi karti yok, satirin
    //   kimligi zaten istem_id (kart rotasi radyoloji listesine gider).
    kartYolu: '/radyoloji', kartBaslik: 'Radyoloji İstemi',
    gizliKolonlar: ['tip', 'durum', 'hekimId', 'hastaId', 'istemId'],
    cipler: [
      { ad: 'Bekleyen',   filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Cevaplanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Radyoloji', menuAd: 'Konsültasyonlar', ic: '🧑‍⚕️',
    yetkiKodu: 'radyoloji', menuSira: 40,
  },
  {
    // SONUÇ TESLİM TAKİBİ (318): raporu onaylı ama alınmamış işler. "Hastanın
    //   raporu hazır mı, alındı mı" sorusunun ekranı.
    kaynak: 'radyoloji-teslim', rota: 'radyoloji-teslim',
    baslik: 'Sonuç Teslim', yol: 'Radyoloji › Sonuç Teslim',
    aksiyonEkrani: 'radyoloji-teslim-liste',
    // Cift tik ISTEM kartini acar: bu listelerin kendi karti yok, satirin
    //   kimligi zaten istem_id (kart rotasi radyoloji listesine gider).
    kartYolu: '/radyoloji', kartBaslik: 'Radyoloji İstemi',
    gizliKolonlar: ['modalite', 'takipDurum', 'hastaId', 'istemId'],
    cipler: [
      { ad: 'Teslim Bekleyen', filtre: { alan: 'takipDurum', op: 'esit', deger: 1 } },
      { ad: 'Teslim Edilen',   filtre: { alan: 'takipDurum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Radyoloji', menuAd: 'Sonuç Teslim', ic: '📦',
    yetkiKodu: 'radyoloji', menuSira: 50,
  },
  // ===================================================================
  //  e-NABIZ ana menusu (kullanici): RADYOLOJIDEN SONRA gelir.
  //
  //  Grup sirasi dizideki ILK ogeden geldigi icin bu blok Radyoloji ile Cari
  //  arasinda durur. Kuyruk eskiden Yonetim › Ortak Platform altindaydi;
  //  e-Nabiz gunluk isleyen bir akis (paket uretimi, gonderim, hata takibi),
  //  ayarlar menusunun dibinde aranmamali.
  // ===================================================================
];
