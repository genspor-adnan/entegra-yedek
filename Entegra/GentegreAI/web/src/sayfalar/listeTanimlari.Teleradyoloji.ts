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
    // KART (798): cift tik istegi acar. Kart rotasi LISTE ROTASINDAN turetilir
    //   (/teleradyoloji/:id) - farkli yazilirsa cift tik tanimsiz rotaya gider.
    kartYolu: '/teleradyoloji', kartBaslik: 'Teleradyoloji İsteği',
    // ARAC CUBUGU (799): `aksiyonEkrani` verilmeyince GenGrid cubugu HIC
    //   cizmiyor - ekranda ne "Yeni İstek" ne de akis dugmeleri vardi, istek
    //   yalnizca cift tikla acilabiliyordu. 797'de dagitilan `telerad.ata` /
    //   `telerad.teslim` yetkilerinin karsiligi da bu katalogda.
    aksiyonEkrani: 'telerad-istek-liste',
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
    // PANO (801): modülün "bugün ne durumdayız" ekranı - liste değil
    //   (ozelSayfa). Sayaçlar çalışma listesine kendi çipiyle götürür.
    //   Mockup `telerad_pano.html`; yalnız verisi HAZIR paneller çizilir
    //   (nöbet/hakediş/dönem faturası yapılmadı, uydurma sayı yok).
    kaynak: 'telerad-pano', rota: 'telerad-pano', ozelSayfa: true,
    baslik: 'Teleradyoloji Panosu', yol: 'Teleradyoloji › Pano',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Telerad Panosu',
    ic: '📊', menuSira: 38, yetkiKodu: 'teleradyoloji',
    modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // KURUMLAR: cari kartına bağlı teleradyoloji ilişkisi (yön, DICOM AE,
    //   teslim kanalı). "Kurum var ama sözleşmesi yok" en sık eksiklik
    //   olduğu için aktif sözleşme sayısı listede.
    kaynak: 'telerad-kurum', rota: 'telerad-kurum', baslik: 'Teleradyoloji Kurumları',
    yol: 'Teleradyoloji › Kurumlar',
    // KART (800): kurum ve sözleşme yalnız göç/betikle açılabiliyordu - iş
    //   ilişkisi ekrandan hiç kurulamıyordu. Kart rotası liste rotasından
    //   türetilir (/telerad-kurum/:id).
    kartYolu: '/telerad-kurum', kartBaslik: 'Teleradyoloji Kurumu',
    aksiyonEkrani: 'telerad-kurum-liste',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Telerad Kurumları',
    ic: '🏥', menuSira: 42, yetkiKodu: 'teleradyoloji.kurum', modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // NÖBET ÇİZELGESİ (801): "şu an kim iş başında". Poliklinik çalışma
    //   planından (718) AYRI - radyolog evden okur, vardiya gece yarısını
    //   geçer. Otomatik dağıtımın girdisi: hedefi "o anki nöbetçi" olan
    //   kural buraya bakar.
    kaynak: 'telerad-nobet', rota: 'telerad-nobet', baslik: 'Teleradyoloji Nöbet Çizelgesi',
    yol: 'Teleradyoloji › Nöbet',
    kartYolu: '/telerad-nobet', kartBaslik: 'Nöbet',
    aksiyonEkrani: 'telerad-nobet-liste',
    cipler: [
      { ad: 'Şimdi', filtre: { alan: 'suAn', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Nöbet Çizelgesi',
    ic: '🌙', menuSira: 46, yetkiKodu: 'teleradyoloji.nobet',
    modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // ATAMA KURALLARI (801): "hangi iş kime". Sıra KARAR sırasıdır - ilk uyan
    //   kural kazanır, liste de o sırada okunur.
    kaynak: 'telerad-kural', rota: 'telerad-kural', baslik: 'Teleradyoloji Atama Kuralları',
    yol: 'Teleradyoloji › Atama Kuralları',
    kartYolu: '/telerad-kural', kartBaslik: 'Atama Kuralı',
    aksiyonEkrani: 'telerad-kural-liste',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Atama Kuralları',
    ic: '🤖', menuSira: 48, yetkiKodu: 'teleradyoloji.kural',
    modul: 'teleradyoloji', urunModu: 2,
  },
  {
    // SÖZLEŞMELER: dönem, ücret modeli, tarife ve SLA süreleri. İsteğe
    //   KOPYALANIR (db/797) - sözleşme sonradan değişince geçmiş isteğin sözü
    //   değişmesin.
    kaynak: 'telerad-sozlesme', rota: 'telerad-sozlesme', baslik: 'Teleradyoloji Sözleşmeleri',
    yol: 'Teleradyoloji › Sözleşmeler',
    kartYolu: '/telerad-sozlesme', kartBaslik: 'Teleradyoloji Sözleşmesi',
    aksiyonEkrani: 'telerad-sozlesme-liste',
    menuGrup: 'Radyoloji', menuAltGrup: 'Teleradyoloji', menuAd: 'Telerad Sözleşmeleri',
    ic: '📜', menuSira: 44, yetkiKodu: 'teleradyoloji.sozlesme', modul: 'teleradyoloji', urunModu: 2,
  },
];
