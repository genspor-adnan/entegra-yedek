import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * TÜRKİYE KLİNİK KALİTE PROGRAMI — db/711, mockup'lar `Ekranlar/Kalite/*.html`.
 *
 * Kaynak: SHGM "Klinik Kalite Ölçme ve Değerlendirme Rehberi (S. 1.1)",
 * Mart 2021. 16 sağlık olgusu · 217 gösterge · 5.377 kod satırı.
 *
 * ÜÇ EKRAN, ÜÇ SORU:
 *   Göstergeler   "hangi göstergeler var, hedefleri ne"  (rehberin kataloğu)
 *   Dönem Sonuçları "bu dönem nasıldık"                   (kurumun ölçümü)
 *   Kod Havuzu    "bu ICD/SUT/ATC kodu hangi göstergeyi besliyor" (ters yön)
 *
 * Kod Havuzu ayrı ekrandır çünkü sorduğu soru diğerlerinin TERSİ. Gösterge
 * kartı "bu göstergede hangi kodlar var" der; kodlama ekibinin sorusu ise
 * "şu kodu yazarsam hangi göstergeyi etkilerim" ve bu, kartlar arasında
 * gezinerek yanıtlanamaz.
 *
 * ÜRÜN MODU 2 (HBYS): klinik kalite yalnız sağlık kuruluşunu ilgilendirir.
 *
 * MENÜDE AYRI "Kalite" ANA GRUBU AÇILMADI, Yönetim > Kalite alt grubu
 * kullanıldı: `menuDuzeni` testi ana grup sayısına tavan koyuyor (HBYS 13 ·
 * ERP 10 + ortak) ve her ana grubun sonunda Dökümler bağlantısı istiyor.
 * Yönetim ayrıca hiçbir kuruluma kapatılamayan gruptur - klinik kalite de
 * kapatılabilir bir modül değil.
 */
export const KLINIK_KALITE_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'klinikGosterge', rota: 'klinik-gosterge', aksiyonEkrani: 'klinik-gosterge-liste',
    baslik: 'Klinik Kalite Göstergeleri',
    yol: 'Yönetim › Kalite › Klinik Kalite Göstergeleri',
    kartYolu: '/klinik-gosterge', kartBaslik: 'Gösterge Kartı',
    cipler: [
      { ad: 'Otomatik',   filtre: { alan: 'otomatik', op: 'esit', deger: 1 } },
      { ad: 'Elle giriş', filtre: { alan: 'otomatik', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yönetim', menuAltGrup: 'Kalite', menuAd: 'Klinik Kalite Göstergeleri',
    ic: '📐', yetkiKodu: 'klinik_kalite.olgu', menuSira: 60,
  },
  {
    kaynak: 'klinikGostergeDonem', rota: 'klinik-gosterge-donem',
    aksiyonEkrani: 'klinik-kalite-donem-liste',
    baslik: 'Klinik Kalite Dönem Sonuçları',
    yol: 'Yönetim › Kalite › Klinik Kalite Dönem Sonuçları',
    kartYolu: '/klinik-gosterge-donem', kartBaslik: 'Dönem Ölçümü',
    cipler: [
      { ad: 'Taslak',     filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Kesinleşti', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Elle girilen', filtre: { alan: 'kaynak', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yönetim', menuAltGrup: 'Kalite', menuAd: 'Klinik Kalite Dönem Sonuçları',
    ic: '📊', yetkiKodu: 'klinik_kalite.donem', menuSira: 61,
  },
  {
    kaynak: 'klinikGostergeKod', rota: 'klinik-gosterge-kod',
    baslik: 'Klinik Kalite Kod Havuzu',
    yol: 'Yönetim › Kalite › Klinik Kalite Kod Havuzu',
    // KART YOK: kod listesi rehberden gelir, kurum düzenlemez. Düzenlenebilir
    //   bir kart açmak kıyaslamayı bozmanın en kısa yolu olurdu.
    cipler: [
      { ad: 'ICD-10', filtre: { alan: 'tip', op: 'esit', deger: 'icd10' } },
      { ad: 'SUT',    filtre: { alan: 'tip', op: 'esit', deger: 'sut' } },
      { ad: 'ATC',    filtre: { alan: 'tip', op: 'esit', deger: 'atc' } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Yönetim', menuAltGrup: 'Kalite', menuAd: 'Klinik Kalite Kod Havuzu',
    ic: '🔤', yetkiKodu: 'klinik_kalite', menuSira: 62,
  },
];
