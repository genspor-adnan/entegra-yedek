import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * ACİL SERVİS — db/716, mockup'lar `Ekranlar/Acil/*.html`.
 *
 * TRİYAJ ve TAKİP AYNI KAYNAK, AYRI EKRAN. İkisi de `acilBasvuru` okur ama
 * farklı soru soruyor: triyaj ekranı "sırada kim var", takip panosu "içeride
 * kim ne bekliyor". Tek ekranda birleştirseydik, hasta kabul eden kişi 23
 * satırlık içeri listesini, panoya bakan kişi de triyaj kuyruğunu görmek
 * zorunda kalırdı. Ayrım `acik` çipiyle yapılır - sunucuda tek kaynak.
 *
 * VARSAYILAN SIRALAMA TRİYAJA GÖRE (kaynak tanımında). Geliş sırası
 * listelenseydi ekran, yapılması gereken işin tersini gösterirdi.
 *
 * AKIŞ DÜĞMELERİ (716 uçları) EKRANA GÖRE AYRILDI: triyaj ekranında hastayı
 * sıraya sokanlar (triyaj · yatak · hekim gördü), panoda içerideki hastayı
 * ilerletenler (çağrı · çıkış kararı). Aynı kaynağı okuyan iki ekranın aynı
 * düğme setini taşıması, her iki kullanıcıyı da diğerinin düğmelerini eleyerek
 * çalışmaya zorlardı.
 *
 * TRİYAJ DÜŞÜRME ayrı yetki ve gerekçe ister; kararı sunucu verir.
 *
 * ÜRÜN MODU 2 (HBYS).
 */
export const ACIL_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'acilBasvuru', rota: 'acil-triyaj',
    baslik: 'Acil — Triyaj ve Kabul',
    yol: 'Acil › Triyaj ve Kabul',
    kartYolu: '/acil-basvuru', kartBaslik: 'Acil Hasta Kartı',
    aksiyonEkrani: 'acil-triyaj-liste',
    tarihAlani: 'girisZamani',
    cipler: [
      // Triyaj bekleyen = henüz düzey verilmemiş (0).
      { ad: 'Triyaj bekleyen', filtre: { alan: 'triyaj', op: 'esit', deger: 0 } },
      { ad: 'Kırmızı',  filtre: { alan: 'triyaj', op: 'esit', deger: 1 } },
      { ad: 'Turuncu',  filtre: { alan: 'triyaj', op: 'esit', deger: 2 } },
      { ad: 'Acilde',   filtre: { alan: 'acik', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Acil', menuAd: 'Triyaj ve Kabul', ic: '🚨',
    yetkiKodu: 'acil.triyaj', menuSira: 10,
  },
  {
    kaynak: 'acilBasvuru', rota: 'acil-takip',
    baslik: 'Acil — Takip Panosu',
    yol: 'Acil › Takip Panosu',
    kartYolu: '/acil-basvuru', kartBaslik: 'Acil Hasta Kartı',
    aksiyonEkrani: 'acil-takip-liste',
    // Pano AÇIK hastaları gösterir; çıkanlar "Tümü" ile görünür.
    cipler: [
      { ad: 'Acilde',       filtre: { alan: 'acik', op: 'esit', deger: 1 } },
      { ad: 'Kimliksiz',    filtre: { alan: 'kimliksiz', op: 'esit', deger: 1 } },
      { ad: 'Adli vaka',    filtre: { alan: 'adliVaka', op: 'esit', deger: 1 } },
      { ad: 'Yatış bekleyen', filtre: { alan: 'cikisSekli', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Acil', menuAd: 'Takip Panosu', ic: '📺',
    yetkiKodu: 'acil.pano', menuSira: 20,
  },
  {
    kaynak: 'acilCagri', rota: 'acil-cagri',
    baslik: 'Acil — Çağrılar',
    yol: 'Acil › Çağrılar',
    aksiyonEkrani: 'acil-cagri-liste',
    tarihAlani: 'cagriZamani',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Yanıt yok', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Mavi kod',  filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Acil', menuAd: 'Çağrılar', ic: '📞',
    yetkiKodu: 'acil.pano', menuSira: 30,
  },
  {
    kaynak: 'acilYatak', rota: 'acil-yatak',
    baslik: 'Acil Yatakları',
    yol: 'Acil › Yataklar',
    kartYolu: '/acil-yatak', kartBaslik: 'Acil Yatağı',
    aksiyonEkrani: 'acil-yatak-liste',
    cipler: [
      { ad: 'Boş',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Dolu',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Acil', menuAltGrup: 'Ayarlar', menuAd: 'Yataklar', ic: '🛏️',
    yetkiKodu: 'acil.yatak', menuSira: 90,
  },
];
