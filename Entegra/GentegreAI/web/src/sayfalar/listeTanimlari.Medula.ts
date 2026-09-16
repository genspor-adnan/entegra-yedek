import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * MEDULA (SGK) MENÜSÜ — db/707, mockup'lar `Ekranlar/Medula/*.html`.
 *
 * Günün sırası: Hasta Kabul / Provizyon → Takipler → Hizmet Kayıtları →
 * e-Reçete / e-Rapor → Fatura & Dönem → (raporlar) Faturalar · Dönemler ·
 * Kesintiler → Gönderim Kuyruğu & Ayarlar. Özel sayfalar `/api/medula`
 * uçlarından okur; listeler generic.
 *
 * ÜRÜN MODU 2 (HBYS). Modül kapısı yok: SGK'lı hasta kabul eden her HBYS
 * kurumunda görünür; hesap tanımlı değilse kuyruk ekranı bunu söyler.
 */
export const MEDULA_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'medula-kabul', rota: 'medula-kabul', ozelSayfa: true, baslik: 'Medula Hasta Kabul / Provizyon',
    yol: 'Medula › Hasta Kabul', urunModu: 2,
    menuGrup: 'Medula', menuAd: 'Hasta Kabul / Provizyon', ic: '🪪', yetkiKodu: 'medula.provizyon', menuSira: 10,
  },
  {
    // KAYIT KABUL'DEN DE (menü V2): banko SGK'lı hastayı kabul ederken Medula
    //   grubuna gitmesin. Ekran TEK (`/medula-kabul`), bu satır yalnız
    //   BAĞLANTIDIR (menuYol; App.tsx rota açmaz) - Dökümler deseni.
    kaynak: 'medula-kabul', rota: 'medula-kabul', ozelSayfa: true, baslik: 'Medula Hasta Kabul / Provizyon',
    yol: 'Kayıt Kabul › Medula Kabul', urunModu: 2, menuYol: '/medula-kabul',
    menuGrup: 'Kayıt Kabul', menuAd: 'Medula Kabul', ic: '🪪', yetkiKodu: 'medula.provizyon', menuSira: 25,
  },
  {
    kaynak: 'medula-takip', rota: 'medula-takip', aksiyonEkrani: 'medula-takip-liste', baslik: 'Medula Takipleri',
    yol: 'Medula › Takipler', tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık takip',      filtre: { alan: 'acik', op: 'esit', deger: 1 } },
      { ad: 'Fatura bekleyen', filtre: { alan: 'faturasiz', op: 'esit', deger: 1 } },
      { ad: 'Reddedilen',      filtre: { alan: 'sgkDurum', op: 'esit', deger: 2 } },
      { ad: 'Provizyonsuz',    filtre: { alan: 'sgkDurum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'Takipler', ic: '📋', yetkiKodu: 'medula', menuSira: 20,
  },
  {
    kaynak: 'medula-islem', rota: 'medula-islem', aksiyonEkrani: 'medula-islem-liste', baslik: 'Medula Hizmet Kayıtları',
    yol: 'Medula › Hizmet Kayıtları', tarihAlani: 'tarih',
    cipler: [
      { ad: 'Hatalı',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kabul',    filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Ücretli',  filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    toplam: ['tutar'],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'Hizmet Kayıtları', ic: '🧾', yetkiKodu: 'medula.hizmet', menuSira: 30,
  },
  {
    // e-REÇETE: reçete listesinin Medula görünümü - imzala, gönder, sil.
    kaynak: 'recete', rota: 'medula-recete', aksiyonEkrani: 'medula-recete-liste', baslik: 'e-Reçete (Medula)',
    yol: 'Medula › e-Reçete', kartYolu: '/medula-recete', kartBaslik: 'Reçete', tarihAlani: 'tarih',
    cipler: [
      { ad: 'Taslak',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İmzalı',       filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Medula Kabul', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'e-Reçete', ic: '💊', yetkiKodu: 'medula.recete', menuSira: 40,
  },
  {
    kaynak: 'medula-rapor', rota: 'medula-rapor', aksiyonEkrani: 'medula-rapor-liste', baslik: 'e-Rapor (Medula)',
    yol: 'Medula › e-Rapor', kartYolu: '/medula-rapor', kartBaslik: 'Rapor', tarihAlani: 'baslangic',
    cipler: [
      { ad: 'Taslak',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Medula Kabul', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Hata',         filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'e-Rapor', ic: '📄', yetkiKodu: 'medula.recete', menuSira: 45,
  },
  {
    kaynak: 'medula-fatura-donem', rota: 'medula-fatura-donem', ozelSayfa: true, baslik: 'Medula Fatura & Dönem',
    yol: 'Medula › Fatura & Dönem', urunModu: 2,
    menuGrup: 'Medula', menuAd: 'Fatura & Dönem', ic: '🧮', yetkiKodu: 'medula.fatura', menuSira: 50,
  },
  {
    kaynak: 'medula-fatura', rota: 'medula-fatura', aksiyonEkrani: 'medula-fatura-liste', baslik: 'Medula Faturaları',
    yol: 'Medula › Faturalar', kartYolu: '/medula-fatura', kartBaslik: 'Medula Faturası', tarihAlani: 'tarih',
    cipler: [
      { ad: 'Kaydedildi',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Dönemde',      filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Dönem kapandı',filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Fark var',     filtre: { alan: 'fark', op: 'esitDegil', deger: 0 } },
      { ad: 'Tümü' },
    ],
    toplam: ['yerelTutar', 'medulaTutar', 'katilim', 'kesinti'],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'Faturalar', ic: '🧾', yetkiKodu: 'medula.fatura', menuSira: 60,
  },
  {
    kaynak: 'medula-donem', rota: 'medula-donem', aksiyonEkrani: 'medula-donem-liste', baslik: 'Medula Dönemleri',
    yol: 'Medula › Dönemler', kartYolu: '/medula-donem', kartBaslik: 'Dönem',
    toplam: ['toplam', 'kesinti', 'net', 'odenen', 'kalan'],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'Dönemler', ic: '📅', yetkiKodu: 'medula.fatura', menuSira: 65,
  },
  {
    kaynak: 'medula-kesinti', rota: 'medula-kesinti', aksiyonEkrani: 'medula-kesinti-liste', baslik: 'Medula Kesintileri',
    yol: 'Medula › Kesinti / İtiraz', kartYolu: '/medula-kesinti', kartBaslik: 'Kesinti', tarihAlani: 'itirazZaman',
    cipler: [
      { ad: 'İtiraz edilmedi', filtre: { alan: 'itirazDurum', op: 'esit', deger: 0 } },
      { ad: 'İtiraz bekliyor', filtre: { alan: 'itirazDurum', op: 'esit', deger: 1 } },
      { ad: 'Sonuçlanan',      filtre: { alan: 'itirazDurum', op: 'icinde', deger: [2, 3] } },
      { ad: 'Tümü' },
    ],
    toplam: ['tutar', 'iade'],
    urunModu: 2, menuGrup: 'Medula', menuAd: 'Kesinti / İtiraz', ic: '⚖️', yetkiKodu: 'medula.fatura', menuSira: 70,
  },
  {
    kaynak: 'medula-kuyruk-ayar', rota: 'medula-kuyruk-ayar', ozelSayfa: true, baslik: 'Medula Gönderim Kuyruğu & Ayarlar',
    yol: 'Medula › Gönderim Kuyruğu', urunModu: 2,
    menuGrup: 'Medula', menuAd: 'Gönderim Kuyruğu & Ayarlar', ic: '📡', yetkiKodu: 'medula', menuSira: 80,
  },
  {
    kaynak: 'medula-kuyruk', rota: 'medula-kuyruk', aksiyonEkrani: 'medula-kuyruk-liste', baslik: 'Medula Çağrı Günlüğü',
    yol: 'Medula › Çağrı Günlüğü', tarihAlani: 'zaman',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'icinde', deger: [1, 2] } },
      { ad: 'Hatalı',    filtre: { alan: 'durum', op: 'icinde', deger: [4, 5] } },
      { ad: 'Kabul',     filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, menuGrup: 'Medula', menuAltGrup: 'Ayarlar', menuAd: 'Çağrı Günlüğü', ic: '🗂️', yetkiKodu: 'medula', menuSira: 90,
  },
];
