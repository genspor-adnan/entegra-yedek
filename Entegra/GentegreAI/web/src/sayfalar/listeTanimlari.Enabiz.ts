import { type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * e-Nabız: paket kuyruğu ve gönderim listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const ENABIZ_LISTELERI: ListeGirdisi[] = [
  {
    // e-NABIZ GONDERIM KUYRUGU (415) - uretilen paketler ve durumlari.
    //   "Eksik Alan" bir HATA DEGIL: paket uretildi ama zorunlu alani bos
    //   oldugu icin kuyruga girmedi; duzeltilince kaynaktan yeniden uretilir.
    kaynak: 'enabiz-paket', rota: 'enabiz-paket', baslik: 'e-Nabız Kuyruğu',
    // ROTA VE KAYNAK DEGISMEDI: menudeki yeri degisti, adresi degil - eski
    //   link, favori ve rehber adimi kirilmasin.
    yol: 'e-Nabız › Gönderim Kuyruğu',
    aksiyonEkrani: 'enabiz-liste',
    tarihAlani: 'olayTarihi',
    cipler: [
      { ad: 'Eksik Alan',  filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Bekleyen',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Gönderildi',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Hatalı',      filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'enabiz',
    // Bayrak emojisi Windows'ta "TR" harfleri olarak cizilir (dil secicide de
    //   ayni sorun yasanmisti) - gonderim kuyruguna anlamli ikon.
    menuGrup: 'e-Nabız', menuAd: 'Gönderim Kuyruğu', ic: '📤',
    yetkiKodu: 'entegrasyon', menuSira: 20,
  },
  {
    // VERI KALITESI PANOSU (454) - mockup enabiz_veri_kalitesi.html.
    //   Kuyruk "su an ne bekliyor" der; pano "bu ay ne kadarini
    //   gonderebildik, neden gonderemedik" sorusunu cevaplar.
    kaynak: 'enabiz-pano', rota: 'enabiz-pano', ozelSayfa: true,
    baslik: 'e-Nabız Veri Kalitesi', yol: 'e-Nabız › Veri Kalitesi',
    urunModu: 2, modul: 'enabiz',
    menuGrup: 'e-Nabız', menuAd: 'Veri Kalitesi', ic: '📊',
    yetkiKodu: 'entegrasyon', menuSira: 10,
  },
  {
    // KOD ESLEME (454): yerel tanim -> SKRS kodu. Esleme yoksa paket
    //   "eksik alan" ile kuyrukta bekler; USS bilmedigi kodu reddeder.
    kaynak: 'enabiz-kod-esleme', rota: 'enabiz-kod-esleme',
    baslik: 'e-Nabız Kod Eşleme', yol: 'e-Nabız › Kod Eşleme',
    kartYolu: '/enabiz-kod-esleme', kartBaslik: 'Kod Eşleme',
    aksiyonEkrani: 'enabiz-kod-esleme-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'aktif', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'enabiz',
    menuGrup: 'e-Nabız', menuAltGrup: 'Ayarlar', menuAd: 'Kod Eşleme', ic: '🔗',
    yetkiKodu: 'entegrasyon', menuSira: 90,
  },

  // CARI grubu ana menude RADYOLOJIDEN SONRA (kullanici).
];
