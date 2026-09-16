import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * FTR (FİZİK TEDAVİ VE REHABİLİTASYON) MODÜLÜ — db/719, mockuplar
 * `Ekranlar/FTR/*.html`.
 *
 * İş birimi TEDAVİ PROGRAMI (KÜR): uzman değerlendirmesi → program (SUT
 * uygulamaları, seans sayısı, sıklık, fizyoterapist, kabin) → seanslar →
 * ara / kür sonu değerlendirme. Menü sırası günün akışı: Ünite Panosu →
 * Değerlendirmeler → Programlar → Seanslar → Ölçekler → (Ayarlar) Üniteler.
 * Program ve seans kartları özel modal (ozelKart).
 */
export const FTR_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'ftr-pano', ozelSayfa: true, baslik: 'Ünite Panosu', yol: 'FTR › Ünite Panosu',
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Ünite Panosu', ic: '🏥', yetkiKodu: 'ftr.seans', menuSira: 10,
  },
  {
    kaynak: 'ftr-degerlendirme', rota: 'ftr-degerlendirme', aksiyonEkrani: 'ftr-degerlendirme-liste', baslik: 'FTR Değerlendirmeleri',
    yol: 'FTR › Değerlendirmeler',
    kartYolu: '/ftr-degerlendirme', kartBaslik: 'FTR Değerlendirme',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Değerlendirmeler', ic: '🩺', yetkiKodu: 'ftr.degerlendirme', menuSira: 20,
  },
  {
    kaynak: 'ftr-program', rota: 'ftr-program', aksiyonEkrani: 'ftr-program-liste', baslik: 'Tedavi Programları (Kür)',
    yol: 'FTR › Tedavi Programları',
    kartYolu: '/ftr-program', kartBaslik: 'Tedavi Programı', ozelKart: true,
    tarihAlani: 'baslangic',
    cipler: [
      { ad: 'Sürüyor',      filtre: { alan: 'durum', op: 'icinde', deger: [2, 3] } },
      { ad: 'Taslak',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlandı',   filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Sonlandırıldı', filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Tedavi Programları', ic: '📋', yetkiKodu: 'ftr.program', menuSira: 30,
  },
  {
    // GENERIC PROGRAM KARTI (menude gizli): ozel modal goruntuler/planlar,
    //   alan duzenleme ve egzersiz/uygulama detaylari GenForm'da. Yeni program
    //   buradan acilir, kaydedince ozel karta gecer (ListeKarti).
    kaynak: 'ftr-program', rota: 'ftr-program-kart', aksiyonEkrani: 'ftr-program-liste', baslik: 'Tedavi Programı (kart)',
    yol: 'FTR › Tedavi Programı',
    kartYolu: '/ftr-program-kart', kartBaslik: 'Tedavi Programı',
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Tedavi Programı (kart)', menuGizli: true, ic: '📋', yetkiKodu: 'ftr.program', menuSira: 31,
  },
  {
    kaynak: 'ftr-seans', rota: 'ftr-seans', aksiyonEkrani: 'ftr-seans-liste', baslik: 'Seanslar',
    yol: 'FTR › Seanslar',
    kartYolu: '/ftr-seans', kartBaslik: 'Seans Uygulama', ozelKart: true,
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Sürüyor', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Planlı',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Yapıldı', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Gelmedi', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Seanslar', ic: '🏃', yetkiKodu: 'ftr.seans', menuSira: 40,
  },
  {
    kaynak: 'ftr-olcek', rota: 'ftr-olcek', aksiyonEkrani: 'ftr-olcek-liste', baslik: 'Ölçekler',
    yol: 'FTR › Ölçekler',
    kartYolu: '/ftr-olcek', kartBaslik: 'Ölçek Kaydı',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAd: 'Ölçekler', ic: '📈', yetkiKodu: 'ftr.olcek', menuSira: 50,
  },
  {
    kaynak: 'ftr-unite', rota: 'ftr-unite', aksiyonEkrani: 'ftr-unite-liste', baslik: 'Üniteler & Kabinler',
    yol: 'FTR › Ayarlar › Üniteler',
    kartYolu: '/ftr-unite', kartBaslik: 'FTR Ünitesi',
    urunModu: 2, modul: 'ftr',
    menuGrup: 'FTR', menuAltGrup: 'Ayarlar', menuAd: 'Üniteler & Kabinler', ic: '🚪', yetkiKodu: 'ftr.unite', menuSira: 90,
  },
];
