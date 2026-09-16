import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * ECZANE — db/722, mockup'lar `Ekranlar/Eczane/*.html`.
 *
 * YEDİ EKRAN, YEDİ SORU:
 *   Eczacı Kontrolü   "hangi order'da sorun var, karar verildi mi"
 *   Ünite Doz         "hangi doz hazır, hangisi teslim edilmedi"
 *   Hazırlama         "kemoterapi/TPN sırası ne durumda"
 *   İade              "servisten dönen ilaç stoğa girer mi"
 *   İmha              "ne imha edildi, tutanağı nerede"
 *   Kontrollü Defter  "kırmızı/yeşil reçeteli ilaç nerede"
 *   Miad & Tüketim    "ne zaman ne bitecek, ne iade edilmeli"
 *
 * MİAD EKRANI TARİHE DEĞİL TÜKETİME DE BAKAR (`v_eczane_miad`): günlük 6
 * giden bir kalem 14 gün kala iade edilmez, tüketilir. "Kalan gün"e göre
 * uyarmak, kullanılacak ilacı geri göndertirdi.
 *
 * KONTROLLÜ DEFTER SALT OKUNUR: satır silinemez (722 tetiği), düzeltme ayrı
 * satırla yapılır - listede kart açılmaz, yazma işi kendi ucundan geçer.
 *
 * ÜRÜN MODU 2 (HBYS).
 */
export const ECZANE_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'eczaneKontrol', rota: 'eczane-kontrol',
    baslik: 'Eczacı Kontrolü',
    yol: 'Eczane › Eczacı Kontrolü',
    kartYolu: '/eczane-kontrol', kartBaslik: 'Eczacı Kontrolü',
    aksiyonEkrani: 'eczane-kontrol-liste',
    cipler: [
      // KARAR BEKLEYEN EN ÜSTTE: eczacının günü burada başlar.
      { ad: 'Karar bekleyen', filtre: { alan: 'karar', op: 'esit', deger: 0 } },
      { ad: 'Yüksek düzey',   filtre: { alan: 'duzey', op: 'esit', deger: 3 } },
      { ad: 'Durdurulan',     filtre: { alan: 'karar', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'Eczacı Kontrolü', ic: '⚕️',
    yetkiKodu: 'eczane.order', menuSira: 10,
  },
  {
    kaynak: 'eczaneDoz', rota: 'eczane-doz',
    baslik: 'Ünite Doz',
    yol: 'Eczane › Ünite Doz',
    kartYolu: '/eczane-doz', kartBaslik: 'Ünite Doz',
    aksiyonEkrani: 'eczane-doz-liste',
    cipler: [
      { ad: 'Hazırlanacak',  filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Hazırlandı',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kontrol edildi', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Teslim edildi', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'Ünite Doz', ic: '💊',
    yetkiKodu: 'eczane.doz', menuSira: 20,
  },
  {
    kaynak: 'eczaneHazirlama', rota: 'eczane-hazirlama',
    baslik: 'Hazırlama (Kemoterapi / TPN)',
    yol: 'Eczane › Hazırlama',
    kartYolu: '/eczane-hazirlama', kartBaslik: 'Hazırlama',
    aksiyonEkrani: 'eczane-hazirlama-liste',
    tarihAlani: 'planlanan',
    cipler: [
      { ad: 'Sırada',        filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      // ÖN KOŞUL: hasta gelmeden / lab çıkmadan hazırlanmaz - hazırlanıp
      //   iptal edilen kemoterapi çöpe gider.
      { ad: 'Ön koşul',      filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Doz onayında',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Hazırlanıyor',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Hazır',         filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'Hazırlama', ic: '🧪',
    yetkiKodu: 'eczane.hazirlama', menuSira: 30,
  },
  {
    kaynak: 'eczaneIade', rota: 'eczane-iade',
    baslik: 'Servis İadeleri',
    yol: 'Eczane › İadeler',
    kartYolu: '/eczane-iade', kartBaslik: 'İade',
    aksiyonEkrani: 'eczane-iade-liste',
    cipler: [
      { ad: 'Karar bekleyen', filtre: { alan: 'karar', op: 'esit', deger: 0 } },
      { ad: 'Stoğa kabul',    filtre: { alan: 'karar', op: 'esit', deger: 1 } },
      { ad: 'İmhaya',         filtre: { alan: 'karar', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'İadeler', ic: '↩️',
    yetkiKodu: 'eczane.iade', menuSira: 40,
  },
  {
    kaynak: 'eczaneImha', rota: 'eczane-imha',
    baslik: 'İmha Tutanakları',
    yol: 'Eczane › İmha',
    kartYolu: '/eczane-imha', kartBaslik: 'İmha Tutanağı',
    aksiyonEkrani: 'eczane-imha-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık',            filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Komisyon onayladı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İmha edildi',     filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'İmha', ic: '🗑',
    yetkiKodu: 'eczane.imha', menuSira: 50,
  },
  {
    // KART YOK (kartYolu verilmedi): defter satırı silinemez ve düzeltme ayrı
    //   satırla yapılır - generic kartın "düzenle/sil" modeli buraya uymaz.
    kaynak: 'kontrolluDefter', rota: 'kontrollu-defter',
    baslik: 'Kontrollü İlaç Defteri',
    yol: 'Eczane › Kontrollü Defter',
    aksiyonEkrani: 'kontrollu-defter-liste',
    tarihAlani: 'zaman',
    cipler: [
      { ad: 'Kırmızı reçete', filtre: { alan: 'receteRenk', op: 'esit', deger: 1 } },
      { ad: 'Yeşil reçete',   filtre: { alan: 'receteRenk', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'Kontrollü Defter', ic: '📕',
    yetkiKodu: 'eczane.kontrollu', menuSira: 60,
  },
  {
    kaynak: 'eczaneMiad', rota: 'eczane-miad',
    baslik: 'Miad & Tüketim',
    yol: 'Eczane › Miad & Tüketim',
    aksiyonEkrani: 'eczane-miad-liste',
    // ÖNERİ KOLONU SQL'DE HESAPLANIR (kalan gün + günlük tüketim) ama
    //   metindir, süzülemez: çipler ölçülebilir alan olan `kalanGun`a
    //   bakar - ekran ikinci bir eşik uydurmasın diye eşikler önerininkiyle
    //   aynı (0 ve 90 gün).
    cipler: [
      { ad: 'Miadı geçti', filtre: { alan: 'kalanGun', op: 'kucuk', deger: 0 } },
      { ad: '90 gün altı', filtre: { alan: 'kalanGun', op: 'kucukEsit', deger: 90 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Eczane', menuAd: 'Miad & Tüketim', ic: '⏳',
    yetkiKodu: 'stok', menuSira: 70,
  },
];
