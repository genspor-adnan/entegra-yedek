import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * AMELİYATHANE — db/715, mockup'lar `Ekranlar/Ameliyathane/*.html`.
 *
 * ÜÇ EKRAN, ÜÇ SORU:
 *   Ameliyat Planı  "bugün ne yapacağız / ne oldu"   (gün listesi)
 *   Bekleyen Talepler "sırada kim var, nesi eksik"
 *   Salonlar        ayar
 *
 * ODA × SAAT ÇİZELGESİ AYRI SAYFA (`/ameliyat-cizelge`, 719): generic grid
 * satır çizer, blok çizmez. Liste "hangi vakalar var"ı, çizelge "hangi masa ne
 * zaman boş"u yanıtlıyor - ikisi birbirinin yerine geçmiyor, aynı veriyi iki
 * ayrı soru için diziyorlar.
 *
 * AKIŞ DÜĞMELERİ (719 uçları): salona alma · kesi · bitiş · iptal · not imzalama
 * ve talepten planlama. Sıra kuralı, time-out kapısı ve sayım uyarısı SUNUCUDA;
 * ekran hangi adımın geçerli olduğuna karar vermez - iki yerde karar verilseydi
 * ekranın izin verip sunucunun reddettiği durumlar çıkardı.
 *
 * ÜRÜN MODU 2 (HBYS).
 */
export const AMELIYATHANE_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'ameliyat', rota: 'ameliyat',
    baslik: 'Ameliyat Planı',
    yol: 'Ameliyathane › Ameliyat Planı',
    kartYolu: '/ameliyat', kartBaslik: 'Ameliyat',
    aksiyonEkrani: 'ameliyat-liste',
    tarihAlani: 'planBaslangic',
    cipler: [
      { ad: 'Bugün süren', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Planlandı',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Bitti',       filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      // Plan dışı (acil eklenen) ayrı çip: masa kullanımı raporunda ayrı
      //   sayılır, yoksa "plana uymadık" diye görünür.
      { ad: 'Plan dışı',   filtre: { alan: 'planDisi', op: 'esit', deger: 1 } },
      { ad: 'İptal',       filtre: { alan: 'durum', op: 'esit', deger: 8 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Ameliyathane', menuAd: 'Ameliyat Planı', ic: '🔪',
    yetkiKodu: 'ameliyathane.plan', menuSira: 10,
  },
  {
    // Liste DEĞİL, kendi sayfası (App.tsx rotayı tanımlar). Salon × saat
    //   yerleşimi, gün gezintisi ve akış düğmeleri orada.
    kaynak: 'ameliyat-cizelge', ozelSayfa: true,
    baslik: 'Masa Çizelgesi',
    yol: 'Ameliyathane › Masa Çizelgesi',
    urunModu: 2,
    menuGrup: 'Ameliyathane', menuAd: 'Masa Çizelgesi', ic: '🗓',
    yetkiKodu: 'ameliyathane.plan', menuSira: 5,
  },
  {
    kaynak: 'ameliyatTalep', rota: 'ameliyat-talep',
    baslik: 'Bekleyen Ameliyat Talepleri',
    yol: 'Ameliyathane › Bekleyen Talepler',
    kartYolu: '/ameliyat-talep', kartBaslik: 'Ameliyat Talebi',
    aksiyonEkrani: 'ameliyat-talep-liste',
    cipler: [
      { ad: 'Bekleyen',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      // "Hazır" olmayan talep planlanamaz - masaya alınıp iptal edilmesi en
      //   pahalı hata. Ayrı çip, listeyi açan kişi ne yapacağını görsün.
      { ad: 'Hazır',      filtre: { alan: 'hazir', op: 'esit', deger: 1 } },
      { ad: 'Eksik hazırlık', filtre: { alan: 'hazir', op: 'esit', deger: 0 } },
      { ad: 'Onkolojik',  filtre: { alan: 'oncelik', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Ameliyathane', menuAd: 'Bekleyen Talepler', ic: '📋',
    yetkiKodu: 'ameliyathane.talep', menuSira: 20,
  },
  {
    kaynak: 'ameliyatSalon', rota: 'ameliyat-salon',
    baslik: 'Ameliyathane Salonları',
    yol: 'Ameliyathane › Salonlar',
    kartYolu: '/ameliyat-salon', kartBaslik: 'Salon',
    aksiyonEkrani: 'ameliyat-salon-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Ameliyathane', menuAltGrup: 'Ayarlar', menuAd: 'Salonlar', ic: '🚪',
    yetkiKodu: 'ameliyathane.salon', menuSira: 90,
  },
];
