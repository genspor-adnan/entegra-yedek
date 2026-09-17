import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * İŞYERİ HEKİMLİĞİ (İSG / OSGB) MODÜLÜ — db/741, mockuplar `Ekranlar/ISG/*.html`.
 *
 * İş birimi FİRMA → ÇALIŞAN → EK-2 MUAYENE (form motoru) → PERİYODİK TAKVİM
 * → ZİYARET → OLAY. Menü sırası günün akışı: Firma Panosu → Periyodik Takvim
 * → Çalışanlar → Ek-2 Muayeneler → Ziyaretler → Olaylar → Firmalar (tanım).
 * Çalışan kartı özel modal (ozelKart); firma kartı generic (bölümler detayı).
 */
export const ISG_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'isg-pano', ozelSayfa: true, baslik: 'Firma Panosu', yol: 'İşyeri Hekimliği › Firma Panosu',
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Firma Panosu', ic: '🏭', yetkiKodu: 'isg.pano', menuSira: 10,
  },
  {
    kaynak: 'isg-takvim', ozelSayfa: true, baslik: 'Periyodik Muayene Takvimi', yol: 'İşyeri Hekimliği › Periyodik Takvim',
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Periyodik Takvim', ic: '📅', yetkiKodu: 'isg.takvim', menuSira: 20,
  },
  {
    kaynak: 'isg-calisan', rota: 'isg-calisan', aksiyonEkrani: 'isg-calisan-liste', baslik: 'Çalışanlar',
    yol: 'İşyeri Hekimliği › Çalışanlar',
    kartYolu: '/isg-calisan', kartBaslik: 'Çalışan Kartı', ozelKart: true,
    cipler: [
      { ad: 'Aktif',         filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Vadesi geçen',  filtre: { alan: 'kalanGun', op: 'kucuk', deger: 0 } },
      { ad: 'Koşullu',       filtre: { alan: 'sonKanaat', op: 'esit', deger: 2 } },
      { ad: 'Açık muayene',  filtre: { alan: 'acikMuayene', op: 'buyuk', deger: 0 } },
      { ad: 'Ayrılan',       filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Çalışanlar', ic: '👷', yetkiKodu: 'isg.calisan', menuSira: 30,
  },
  {
    // GENERIC ÇALIŞAN KARTI (menüde gizli): özel modal görüntüler; alan
    //   düzenleme ve aşı detayı GenForm'da. Yeni çalışan buradan açılır,
    //   kaydedince özel karta geçer (ListeKarti).
    kaynak: 'isg-calisan', rota: 'isg-calisan-kart', aksiyonEkrani: 'isg-calisan-liste', baslik: 'Çalışan (kart)',
    yol: 'İşyeri Hekimliği › Çalışan',
    kartYolu: '/isg-calisan-kart', kartBaslik: 'Çalışan',
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Çalışan (kart)', menuGizli: true, ic: '👷', yetkiKodu: 'isg.calisan', menuSira: 31,
  },
  {
    kaynak: 'isg-muayene', rota: 'isg-muayene', aksiyonEkrani: 'isg-muayene-liste', baslik: 'Ek-2 Muayeneleri',
    yol: 'İşyeri Hekimliği › Ek-2 Muayeneleri',
    kartYolu: '/isg-muayene', kartBaslik: 'Ek-2 Muayene',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlandı', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Koşullu',    filtre: { alan: 'kanaat', op: 'esit', deger: 2 } },
      { ad: 'Çalışamaz',  filtre: { alan: 'kanaat', op: 'esit', deger: 3 } },
      { ad: 'İşe giriş',  filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Ek-2 Muayeneleri', ic: '🩺', yetkiKodu: 'isg.muayene', menuSira: 40,
  },
  {
    kaynak: 'isg-ziyaret', rota: 'isg-ziyaret', aksiyonEkrani: 'isg-ziyaret-liste', baslik: 'İşyeri Ziyaretleri',
    yol: 'İşyeri Hekimliği › Ziyaretler',
    kartYolu: '/isg-ziyaret', kartBaslik: 'Ziyaret Tutanağı',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Termin geçen', filtre: { alan: 'terminGecti', op: 'esit', deger: 1 } },
      { ad: 'Saha',         filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Kurul',        filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Eğitim',       filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Ziyaretler', ic: '🧾', yetkiKodu: 'isg.ziyaret', menuSira: 50,
  },
  {
    kaynak: 'isg-olay', rota: 'isg-olay', aksiyonEkrani: 'isg-olay-liste', baslik: 'İş Kazası ve Olaylar',
    yol: 'İşyeri Hekimliği › Olaylar',
    kartYolu: '/isg-olay', kartBaslik: 'Olay / İş Kazası',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık',         filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'SGK gecikti',  filtre: { alan: 'sgkGecikti', op: 'esit', deger: 1 } },
      { ad: 'İş kazası',    filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Meslek hast.', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAd: 'Olaylar (Kaza · Bildirim)', ic: '🚨', yetkiKodu: 'isg.olay', menuSira: 60,
  },
  {
    kaynak: 'isg-firma', rota: 'isg-firma', aksiyonEkrani: 'isg-firma-liste', baslik: 'Firmalar (İşverenler)',
    yol: 'İşyeri Hekimliği › Ayarlar › Firmalar',
    kartYolu: '/isg-firma', kartBaslik: 'Firma',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Çok tehlikeli', filtre: { alan: 'tehlike', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'isg',
    menuGrup: 'İşyeri Hekimliği', menuAltGrup: 'Ayarlar', menuAd: 'Firmalar (işveren, bölüm)', ic: '🏢', yetkiKodu: 'isg.firma', menuSira: 90,
  },
];
