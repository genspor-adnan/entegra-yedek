import { type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * TELERADYOLOJİ (797) — dış kurumun görüntüsünü bizim radyologumuzun okuduğu
 * akış. Tasarım: `Ekranlar/Teleradyoloji/`.
 *
 * Üç ekran: **çalışma listesi** (işin kendisi), **kurumlar** ve
 * **sözleşmeler** (işin şartları). Okuma/raporlama ekranı YOK - o iş mevcut
 * radyoloji raporlama ekranıyla yapılır; teleradyoloji isteği iç isteme
 * bağlanır (`radyoloji_istem.telerad_istek_id`).
 *
 * Hepsi `teleradyoloji` modülüne bağlı: modül kapalı kurumda menüde hiç
 * görünmez.
 */
export const TELERADYOLOJI_LISTELERI: ListeGirdisi[] = [
  {
    // ÇALIŞMA LİSTESİ: satır = raporlanacak dış tetkik. Çipler günün işini
    //   bölüyor - mockup'taki şerit (Bekleyen · Bende · Taslak · Onaylı).
    //   "Bende" çipi yok: o süzgeç kullanıcıya bağlı, sunucu tarafında
    //   `atanan_radyolog_id` ile ayrı bir işte çözülecek.
    kaynak: 'telerad-istek', rota: 'teleradyoloji', baslik: 'Teleradyoloji Çalışma Listesi',
    yol: 'Teleradyoloji › Çalışma Listesi',
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'kucukEsit', deger: 3 } },
      { ad: 'Okunuyor', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Taslak',   filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Onaylı',   filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Teslim',   filtre: { alan: 'durum', op: 'esit', deger: 7 } },
      { ad: 'Tümü' },
    ],
    // RADYOLOJININ ALT GRUBU, ayri ana grup DEGIL: teleradyoloji radyolojinin
    //   kendisidir, yalnizca isin KAYNAGI disaridan gelir. Menü grup tavanı
    //   (menuDuzeni testi) da bunu soyluyor - her yeni is kolu bir ana grup
    //   acarsa menü on üç başlıkta kalmaz.
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji',
    menuAd: 'Teleradyoloji Listesi', ic: '🛰', menuSira: 40,
    yetkiKodu: 'teleradyoloji', modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // KURUMLAR: cari kartına bağlı teleradyoloji ilişkisi (yön, DICOM AE,
    //   teslim kanalı). "Kurum var ama sözleşmesi yok" en sık eksiklik
    //   olduğu için aktif sözleşme sayısı listede.
    kaynak: 'telerad-kurum', rota: 'telerad-kurum', baslik: 'Teleradyoloji Kurumları',
    yol: 'Teleradyoloji › Kurumlar',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Telerad Kurumları',
    ic: '🏥', menuSira: 42, yetkiKodu: 'teleradyoloji.kurum', modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // SÖZLEŞMELER: dönem, ücret modeli, tarife ve SLA süreleri. İsteğe
    //   KOPYALANIR (db/797) - sözleşme sonradan değişince geçmiş isteğin sözü
    //   değişmesin.
    kaynak: 'telerad-sozlesme', rota: 'telerad-sozlesme', baslik: 'Teleradyoloji Sözleşmeleri',
    yol: 'Teleradyoloji › Sözleşmeler',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Telerad Sözleşmeleri',
    ic: '📜', menuSira: 44, yetkiKodu: 'teleradyoloji.sozlesme', modul: 'teleradyoloji', urunModu: 2,
  },
];
