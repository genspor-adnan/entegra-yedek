import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * BİYOMEDİKAL — db/723, mockup'lar `Ekranlar/Demirbas/*.html`.
 *
 * MEVCUT "Demirbaş" GRUBUNA EKLENDİ, yeni grup açılmadı: hastanedeki cihaz da
 * bir demirbaştır. Ayrı grup, aynı envanteri iki menü dalına bölerdi.
 *
 * ÜÇ EKRAN, ÜÇ SORU:
 *   Cihaz Envanteri   "hangi cihaz hazır, kalibrasyonu ne zaman doluyor"
 *   Kalibrasyon       "ölçüm doğru mu, sertifika geçerli mi"
 *   İş Emri           "ne bozuk, ne kadar durdu, kim bakıyor"
 *
 * "HAZIR" TEK YERDE TANIMLI (`v_demirbas_durum`): arızasız **ve** kalibrasyonu
 * geçerli. Çalışan ama kalibrasyonu geçmiş cihaz kullanılabilirlik sayısına
 * girmez - ölçtüğü değere güvenilmiyor.
 *
 * BAKIM ve ARIZA TEK LİSTEDE (tür süzer): ikisi de "cihazda yapılan iş"tir -
 * aynı duruş, aynı parça, aynı geçmiş. Ayırsaydık "bu cihaz ne sıklıkla
 * bozuluyor" sorusu iki listeden toplanırdı.
 *
 * ÜRÜN MODU 2 (HBYS): klinik mühendislik ERP kurulumunda çizilmez. Grup
 * modüle bağlı değil - ERP demirbaş ekranı her kurulumda açık kalmalı.
 */
export const BIYOMEDIKAL_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'demirbasCihaz', rota: 'demirbas-cihaz',
    baslik: 'Cihaz Envanteri',
    yol: 'Demirbaş › Cihaz Envanteri',
    // KART, ERP DEMİRBAŞ KARTININ KENDİSİ: klinik mühendislik alanları o
    //   kartta `UrunModu: 2` ile açılır - ikinci bir kart, aynı satırın iki
    //   düzenleme ekranı demek olurdu.
    kartYolu: '/demirbas', kartBaslik: 'Cihaz',
    aksiyonEkrani: 'demirbas-cihaz-liste',
    cipler: [
      { ad: 'Hazır değil',       filtre: { alan: 'hazir', op: 'esit', deger: 0 } },
      { ad: 'Arızalı',           filtre: { alan: 'arizali', op: 'esit', deger: 1 } },
      // KALİBRASYON GÜNÜ İŞARETLİ: negatif = süresi geçti.
      { ad: 'Kalibrasyonu geçti', filtre: { alan: 'kalibrasyonGun', op: 'kucuk', deger: 0 } },
      { ad: '30 gün içinde',     filtre: { alan: 'kalibrasyonGun', op: 'kucukEsit', deger: 30 } },
      { ad: 'Yaşam desteği',     filtre: { alan: 'riskSinifi', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Demirbaş', menuAd: 'Cihaz Envanteri', ic: '🩺',
    yetkiKodu: 'demirbas.envanter', menuSira: 20,
  },
  {
    kaynak: 'demirbasKalibrasyon', rota: 'demirbas-kalibrasyon',
    baslik: 'Kalibrasyon & Güvenlik Testi',
    yol: 'Demirbaş › Kalibrasyon',
    kartYolu: '/demirbas-kalibrasyon', kartBaslik: 'Kalibrasyon',
    aksiyonEkrani: 'demirbas-kalibrasyon-liste',
    tarihAlani: 'tarih',
    // AÇILIŞ ÇİPİ SONUÇLANMAMIŞ ÖLÇÜM: "Uygunsuz" ile açsaydık ekran çoğu gün
    //   boş gelir, "Kalibrasyonu Tamamla" düğmesi de basılacak satırı bulamazdı.
    cipler: [
      { ad: 'Açık',      filtre: { alan: 'sonuc', op: 'esit', deger: 0 } },
      { ad: 'Uygunsuz',  filtre: { alan: 'sonuc', op: 'esit', deger: 2 } },
      { ad: 'Şartlı',    filtre: { alan: 'sonuc', op: 'esit', deger: 3 } },
      { ad: 'Kalibrasyon', filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      // EST ayrı soru: "doğru ölçüyor mu" değil, "hastayı çarpar mı".
      { ad: 'Güvenlik testi', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Demirbaş', menuAd: 'Kalibrasyon', ic: '📐',
    yetkiKodu: 'demirbas.kalibrasyon', menuSira: 30,
  },
  {
    kaynak: 'demirbasIsEmri', rota: 'demirbas-is-emri',
    baslik: 'İş Emirleri (Bakım & Arıza)',
    yol: 'Demirbaş › İş Emirleri',
    kartYolu: '/demirbas-is-emri', kartBaslik: 'İş Emri',
    aksiyonEkrani: 'demirbas-is-emri-liste',
    tarihAlani: 'bildirimZamani',
    cipler: [
      { ad: 'Açık',          filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Kritik',        filtre: { alan: 'oncelik', op: 'esit', deger: 1 } },
      { ad: 'Arıza',         filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Periyodik bakım', filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      // HASTA ETKİLENDİYSE bu bir iş emri değil, aynı zamanda olay bildirimi.
      { ad: 'Hasta etkilendi', filtre: { alan: 'hastaEtkilendi', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Demirbaş', menuAd: 'İş Emirleri', ic: '🛠',
    yetkiKodu: 'demirbas.isemri', menuSira: 40,
  },
];
