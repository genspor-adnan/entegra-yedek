import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * GÖZ (OFTALMOLOJİ) MODÜLÜ — db/691, tasarım notu
 * `Ekranlar/Goz/goz_sureci.html`, mockuplar `Ekranlar/Goz/*.html`.
 *
 * Modül genel muayenenin ÜSTÜNE oturur: tanı, e-reçete, tahakkuk ve "Tamamla"
 * akışı Muayene modülünde kalır. Buradaki ekranlar gözün kendi sorularını
 * sorar — hasta hangi istasyonda bekliyor, hangi çekim değerlendirilmedi,
 * hangi enjeksiyonun sırası geldi, hangi glokom hastası kontrolünü kaçırdı.
 *
 * Menü sırası ünitenin gün akışıdır: Ünite Akışı → Muayeneler → Görüntüleme →
 * İşlemler → Reçeteler → Takip → (Ayarlar) Cihazlar. Alfabetik dizmek,
 * günün ilk açılan ekranını listenin ortasına düşürürdü.
 *
 * ÜRÜN MODU 2 (HBYS): göz kliniği ERP kurulumunda yoktur - rotası da
 * açılmaz (`App.tsx` liste döngüsü `urunModu`ya bakar).
 */
export const GOZ_LISTELERI: ListeGirdisi[] = [
  {
    // ÜNİTE AKIŞI (691) - modülün giriş ekranı, mockup goz_hasta_listesi.html.
    //   Satır = hastanın AÇIK istasyonu. Ünitede iş hastanın kendisinden çok
    //   NEREDE beklediğiyle yönetilir: dilatasyon damlası damlatılan hasta
    //   yirmi dakika "görünmez" olur ve o süre hekimin sırasını bozar.
    kaynak: 'goz-akis', rota: 'goz-akis', aksiyonEkrani: 'goz-akis-liste', baslik: 'Göz Ünitesi Akışı',
    yol: 'Göz › Ünite Akışı',
    tarihAlani: 'istasyonGiris',
    // Çipler ünitenin istasyonları: hangi masada kimin işi var.
    cipler: [
      { ad: 'Ön Tetkik',    filtre: { alan: 'istasyon', op: 'esit', deger: 2 } },
      { ad: 'Muayene',      filtre: { alan: 'istasyon', op: 'esit', deger: 3 } },
      { ad: 'Görüntüleme',  filtre: { alan: 'istasyon', op: 'esit', deger: 4 } },
      { ad: 'Karar / İşlem',filtre: { alan: 'istasyon', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Ünite Akışı', ic: '🚦', yetkiKodu: 'goz', menuSira: 10,
  },
  {
    // GÖZ MUAYENELERİ - yapılmış ziyaretler. Listede OD/OS BCVA ve GİB durur:
    //   bir göz muayenesini hatırlatan iki sayı bunlardır.
    kaynak: 'goz-muayene', rota: 'goz-muayene', aksiyonEkrani: 'goz-muayene-liste', baslik: 'Göz Muayeneleri',
    yol: 'Göz › Muayeneler',
    kartYolu: '/goz-muayene', kartBaslik: 'Göz Muayenesi',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Tam',      filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Kontrol',  filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Postop',   filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Tarama',   filtre: { alan: 'tur', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Muayeneler', ic: '👁️', yetkiKodu: 'goz.muayene', menuSira: 20,
  },
  {
    // GÖRÜNTÜLEME - OCT, görme alanı, biyometri, fundus foto TEK listede:
    //   hekimin sorusu "bugün hangi çekimler değerlendirilmedi"; cihaz başına
    //   ayrı liste bu soruyu cihaz sayısına bölerdi.
    kaynak: 'goz-goruntuleme', rota: 'goz-goruntuleme', aksiyonEkrani: 'goz-goruntuleme-liste', baslik: 'Göz Görüntüleme',
    yol: 'Göz › Görüntüleme & Testler',
    kartYolu: '/goz-goruntuleme', kartBaslik: 'Göz Görüntüleme',
    tarihAlani: 'istemZamani',
    cipler: [
      { ad: 'İstendi',          filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Çekildi',          filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Değerlendirildi',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Görüntüleme & Testler', ic: '🔬', yetkiKodu: 'goz.goruntuleme',
    menuSira: 30,
  },
  {
    // İŞLEMLER - enjeksiyon / lazer / ameliyat tek listede: ünitenin günlük
    //   planı "on enjeksiyon, üç lazer, iki fako" diye okunur.
    kaynak: 'goz-islem', rota: 'goz-islem', aksiyonEkrani: 'goz-islem-liste', baslik: 'Göz İşlemleri',
    yol: 'Göz › İşlemler',
    kartYolu: '/goz-islem', kartBaslik: 'Göz İşlemi',
    tarihAlani: 'planlananTarih',
    cipler: [
      { ad: 'Planlı',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Hazır',      filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Uygulandı',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Enjeksiyon', filtre: { alan: 'tur',   op: 'esit', deger: 1 } },
      { ad: 'Ameliyat',   filtre: { alan: 'tur',   op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'İşlemler', ic: '💉', yetkiKodu: 'goz.islem', menuSira: 40,
  },
  {
    // GÖZLÜK REÇETELERİ - reçete muayenenin alanı değil kendi kaydı: hastaya
    //   verilir, optikte kullanılır, geçerlilik süresi ve SGK hakkı vardır.
    kaynak: 'goz-gozluk-recete', rota: 'goz-gozluk-recete', aksiyonEkrani: 'goz-gozluk-recete-liste', baslik: 'Gözlük Reçeteleri',
    yol: 'Göz › Gözlük Reçeteleri',
    kartYolu: '/goz-gozluk-recete', kartBaslik: 'Gözlük Reçetesi',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Taslak',         filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İmzalandı',      filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Optiğe verildi', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Gözlük Reçeteleri', ic: '👓', yetkiKodu: 'goz.recete', menuSira: 50,
  },
  {
    // HASTALIK TAKİBİ - bu liste "kim geldi"yi değil KİM GELMEDİ'yi sorar:
    //   glokom sessiz ilerler, kaçırılan kontrol yıllar sonra görme kaybıyla
    //   fark edilir. Varsayılan sıralama sonraki kontrol tarihi.
    kaynak: 'goz-takip', rota: 'goz-takip', aksiyonEkrani: 'goz-takip-liste', baslik: 'Göz Hastalık Takibi',
    yol: 'Göz › Hastalık Takibi',
    kartYolu: '/goz-takip', kartBaslik: 'Göz Hastalık Takibi',
    tarihAlani: 'sonrakiKontrol',
    cipler: [
      { ad: 'Glokom',     filtre: { alan: 'hastalik', op: 'esit', deger: 1 } },
      { ad: 'Diyabetik retinopati', filtre: { alan: 'hastalik', op: 'esit', deger: 2 } },
      { ad: 'AMD',        filtre: { alan: 'hastalik', op: 'esit', deger: 3 } },
      { ad: 'Progresyon', filtre: { alan: 'progresyon', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Hastalık Takibi', ic: '📈', yetkiKodu: 'goz.takip', menuSira: 60,
  },
  {
    // GÖZ HASTA ÖZETİ - satır bir HASTA, kayıt değil. Göz hekiminin hastayı
    //   ilk gördüğünde sorduğu soru sabittir: "iki gözde ne kadar görüyor,
    //   basınç kaç, hangi takipte?" - cevap yedi tabloda dağılmış durumda ve
    //   her kart açılışında tek tek gezmek muayenenin ilk iki dakikasını veri
    //   aramaya harcamak demek.
    // AYRINTI ALT PANELDE (Liste.tsx): ziyaretler, işlemler, reçeteler ve
    //   RNFL trendi seçili satırın altında açılır - ayrı ekran açmak, hekimi
    //   listeden koparırdı.
    kaynak: 'goz-hasta-ozet', rota: 'goz-hasta-ozet', aksiyonEkrani: 'goz-hasta-ozet-liste', baslik: 'Göz Hasta Özeti',
    yol: 'Göz › Hasta Özeti',
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Hasta Özeti', ic: '🧿', yetkiKodu: 'goz', menuSira: 15,
  },
  {
    // KONTAKT LENS gözlükten AYRI liste: kontakt lens reçetesi bir OTURUŞ
    //   DENEMESİDİR - aynı hastaya üç farklı eğrilik denenir ve hangisinin
    //   oturduğu satırda yazar. Aynı listede dursalardı "hangisi verildi"
    //   sorusu iki farklı anlama gelirdi.
    kaynak: 'goz-kontakt-lens', rota: 'goz-kontakt-lens', aksiyonEkrani: 'goz-kontakt-lens-liste', baslik: 'Kontakt Lens',
    yol: 'Göz › Kontakt Lens',
    kartYolu: '/goz-kontakt-lens', kartBaslik: 'Kontakt Lens',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Deneme',   filtre: { alan: 'deneme', op: 'esit', deger: 1 } },
      { ad: 'Reçete',   filtre: { alan: 'deneme', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAd: 'Kontakt Lens', ic: '🔵', yetkiKodu: 'goz.recete', menuSira: 55,
  },
  {
    // İŞLEM PROTOKOLLERİ AYARDIR: postop kontrol planı bir ŞABLON - işleme
    //   bağlanınca randevular ve damla şeması ondan üretilir.
    kaynak: 'goz-islem-protokol', rota: 'goz-islem-protokol', aksiyonEkrani: 'goz-islem-protokol-liste', baslik: 'İşlem Protokolleri',
    yol: 'Göz › Ayarlar › İşlem Protokolleri',
    kartYolu: '/goz-islem-protokol', kartBaslik: 'İşlem Protokolü',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAltGrup: 'Ayarlar', menuAd: 'İşlem Protokolleri', ic: '📋',
    yetkiKodu: 'goz.islem', menuSira: 91,
  },
  {
    // CİHAZ MESAJLARI bir İŞ KUYRUĞUDUR, hata günlüğü değil: hasta eşleşmesi
    //   tutmayan ölçüm kimseye yazılmaz ve burada bekler. KART YOK - satır
    //   cihazdan gelen ham kayıt, elle düzeltilecek veri değil.
    kaynak: 'goz-cihaz-mesaj', rota: 'goz-cihaz-mesaj', aksiyonEkrani: 'goz-cihaz-mesaj-liste', baslik: 'Cihaz Mesajları',
    yol: 'Göz › Ayarlar › Cihaz Mesajları',
    tarihAlani: 'zaman',
    cipler: [
      { ad: 'Sahipsiz', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Hata',     filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAltGrup: 'Ayarlar', menuAd: 'Cihaz Mesajları', ic: '📡',
    yetkiKodu: 'goz.cihaz', menuSira: 92,
  },
  {
    // CİHAZLAR AYARLARIN ALTINDA: günlük iş değil kurulum işi. Lab cihaz
    //   katmanıyla aynı entegrasyon modeli (dinleyici + ham mesaj + eşleme).
    kaynak: 'goz-cihaz', rota: 'goz-cihaz', aksiyonEkrani: 'goz-cihaz-liste', baslik: 'Göz Cihazları',
    yol: 'Göz › Ayarlar › Cihazlar',
    kartYolu: '/goz-cihaz', kartBaslik: 'Göz Cihazı',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAltGrup: 'Ayarlar', menuAd: 'Cihazlar', ic: '🛠️',
    yetkiKodu: 'goz.cihaz', menuSira: 90,
  },
  {
    // DİKTE SÖZLÜĞÜ (705): terim, sesli komut ve sık cümle VERİDİR - yeni bir
    //   kısaltma için sürüm çıkmak gerekmesin diye buradan yönetilir. Kurum
    //   satırını değiştirmek herkesin diktesini etkilediği için ayrı yetki.
    kaynak: 'dikte-terim', rota: 'dikte-terim', aksiyonEkrani: 'dikte-terim-liste',
    baslik: 'Dikte Sözlüğü',
    yol: 'Göz › Ayarlar › Dikte Sözlüğü',
    kartYolu: '/dikte-terim', kartBaslik: 'Dikte Terimi',
    cipler: [
      { ad: 'Terim', filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Komut', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Sık cümle', filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Göz', menuAltGrup: 'Ayarlar', menuAd: 'Dikte Sözlüğü', ic: '🎙',
    yetkiKodu: 'goz.dikte_sozluk', menuSira: 94,
  },
];
