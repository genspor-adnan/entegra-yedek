import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * STERİLİZASYON MODÜLÜ — db/868, mockuplar `Ekranlar/Dis Klinigi/dis_steril_*.html`.
 *
 * Günün akışı: Sterilizasyon Panosu (cihazlar, döngü aç, hazırlama, uyarılar) →
 * Döngü Kartı (`/steril-dongu/:id`, özel modal: yük, indikatör, parametre, serbest
 * bırakma, etiket) → Steril Depo (paketler) → Kullanım (seansta okutma) →
 * İzlenebilirlik · Geri Çağırma · Kayıt Defteri; Ayarlar: cihaz, program, set,
 * birim, bakım, test takvimi, kurallar.
 */
export const STERIL_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'steril-pano', ozelSayfa: true, baslik: 'Sterilizasyon Panosu', yol: 'Sterilizasyon › Pano',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Sterilizasyon Panosu', ic: '🧪', yetkiKodu: 'steril.pano', menuSira: 10,
  },
  {
    kaynak: 'steril-dongu', rota: 'steril-dongu', aksiyonEkrani: 'steril-dongu-liste', baslik: 'Döngüler',
    yol: 'Sterilizasyon › Döngüler',
    kartYolu: '/steril-dongu', kartBaslik: 'Döngü', ozelKart: true,
    tarihAlani: 'baslama',
    cipler: [
      { ad: 'Çalışıyor / bekliyor', filtre: { alan: 'durum', op: 'icinde', deger: [2, 3] } },
      { ad: 'Karantina', filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Serbest', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Başarısız', filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Test', filtre: { alan: 'durum', op: 'esit', deger: 8 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Döngüler', ic: '♨️', yetkiKodu: 'steril.dongu', menuSira: 20,
  },
  {
    kaynak: 'steril-paket', rota: 'steril-paket', aksiyonEkrani: 'steril-paket-liste', baslik: 'Steril Depo · Paketler',
    yol: 'Sterilizasyon › Steril Depo',
    cipler: [
      { ad: 'Steril', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Karantina', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Sterilde', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Bloke', filtre: { alan: 'durum', op: 'esit', deger: 7 } },
      { ad: 'Kullanıldı', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Steril Depo · Paketler', ic: '📦', yetkiKodu: 'steril.birim', menuSira: 30,
  },
  {
    kaynak: 'steril-birim', rota: 'steril-birim', aksiyonEkrani: 'steril-birim-liste', baslik: 'Setler · Döner Aletler',
    yol: 'Sterilizasyon › Setler · Döner Aletler',
    kartYolu: '/steril-birim', kartBaslik: 'Birim (set / döner alet)',
    cipler: [
      { ad: 'Hazırlıkta', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3, 4, 10] } },
      { ad: 'Steril depoda', filtre: { alan: 'durum', op: 'esit', deger: 7 } },
      { ad: 'Kullanımda', filtre: { alan: 'durum', op: 'esit', deger: 8 } },
      { ad: 'Arızalı', filtre: { alan: 'durum', op: 'esit', deger: 9 } },
      { ad: 'Döner aletler', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Setler · Döner Aletler', ic: '🧰', yetkiKodu: 'steril.birim', menuSira: 40,
  },
  {
    kaynak: 'steril-kullanim', rota: 'steril-kullanim', aksiyonEkrani: 'steril-kullanim-liste', baslik: 'Kullanım Kayıtları',
    yol: 'Sterilizasyon › Kullanım Kayıtları',
    tarihAlani: 'zaman',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Kullanım Kayıtları', ic: '🦷', yetkiKodu: 'steril.izleme', menuSira: 50,
  },
  {
    kaynak: 'steril-izleme', ozelSayfa: true, baslik: 'İzlenebilirlik · Geri Çağırma', yol: 'Sterilizasyon › İzlenebilirlik',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'İzlenebilirlik · Kayıt Defteri', ic: '🔍', yetkiKodu: 'steril.izleme', menuSira: 60,
  },
  {
    kaynak: 'steril-geri-cagirma', rota: 'steril-geri-cagirma', aksiyonEkrani: 'steril-geri-cagirma-liste', baslik: 'Geri Çağırmalar',
    yol: 'Sterilizasyon › Geri Çağırmalar',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAd: 'Geri Çağırmalar', menuGizli: true, ic: '🚨', yetkiKodu: 'steril.izleme', menuSira: 61,
  },
  {
    kaynak: 'steril-set', rota: 'steril-set', aksiyonEkrani: 'steril-set-liste', baslik: 'Set Tanımları',
    yol: 'Sterilizasyon › Ayarlar › Set Tanımları',
    kartYolu: '/steril-set', kartBaslik: 'Set tanımı',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAltGrup: 'Ayarlar', menuAd: 'Set tanımları (içerik)', ic: '📋', yetkiKodu: 'steril.birim', menuSira: 90,
  },
  {
    kaynak: 'steril-cihaz', rota: 'steril-cihaz', aksiyonEkrani: 'steril-cihaz-liste', baslik: 'Cihazlar',
    yol: 'Sterilizasyon › Ayarlar › Cihazlar',
    kartYolu: '/steril-cihaz', kartBaslik: 'Cihaz',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAltGrup: 'Ayarlar', menuAd: 'Cihazlar', ic: '⚙️', yetkiKodu: 'steril.ayar', menuSira: 91,
  },
  {
    kaynak: 'steril-program', rota: 'steril-program', aksiyonEkrani: 'steril-program-liste', baslik: 'Programlar',
    yol: 'Sterilizasyon › Ayarlar › Programlar',
    kartYolu: '/steril-program', kartBaslik: 'Program',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAltGrup: 'Ayarlar', menuAd: 'Programlar', ic: '🌡', yetkiKodu: 'steril.ayar', menuSira: 92,
  },
  {
    kaynak: 'steril-bakim', rota: 'steril-bakim', aksiyonEkrani: 'steril-bakim-liste', baslik: 'Bakım · Validasyon',
    yol: 'Sterilizasyon › Ayarlar › Bakım',
    kartYolu: '/steril-bakim', kartBaslik: 'Bakım kaydı',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAltGrup: 'Ayarlar', menuAd: 'Bakım · Validasyon', ic: '🔧', yetkiKodu: 'steril.ayar', menuSira: 93,
  },
  {
    kaynak: 'steril-ayar', ozelSayfa: true, baslik: 'Test Takvimi · Kurallar', yol: 'Sterilizasyon › Ayarlar › Test Takvimi · Kurallar',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Sterilizasyon', menuAltGrup: 'Ayarlar', menuAd: 'Test takvimi · Kurallar', ic: '📅', yetkiKodu: 'steril.ayar', menuSira: 94,
  },
];
