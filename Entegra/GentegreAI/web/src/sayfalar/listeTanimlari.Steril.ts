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
// Menüde AYRI GRUP DEĞİL: Diş grubunun 'Sterilizasyon' alt grubu (70-76); ayar listeleri Diş › Ayarlar'a (95-99)
//   (kullanıcı: "diş altında sterilizasyon yok"). Modül 'steril' ayrı kalır.
export const STERIL_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'steril-pano', ozelSayfa: true, baslik: 'Sterilizasyon Panosu', yol: 'Diş › Sterilizasyon › Pano',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Sterilizasyon Panosu', ic: '🧪', yetkiKodu: 'steril.pano', menuSira: 70,
  },
  {
    kaynak: 'steril-dongu', rota: 'steril-dongu', aksiyonEkrani: 'steril-dongu-liste', baslik: 'Döngüler',
    yol: 'Diş › Sterilizasyon › Döngüler',
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
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Döngüler', ic: '♨️', yetkiKodu: 'steril.dongu', menuSira: 71,
  },
  {
    // GENERİC DÖNGÜ KARTI (menüde gizli): parametre / not / indikatör düzeltme ve silme GenForm'da;
    //   özel kart (/steril-dongu/:id) "Düzenle" ile buraya gelir.
    kaynak: 'steril-dongu', rota: 'steril-dongu-kart', aksiyonEkrani: 'steril-dongu-liste', baslik: 'Döngü (kart)',
    yol: 'Diş › Sterilizasyon › Döngü',
    kartYolu: '/steril-dongu-kart', kartBaslik: 'Döngü',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Döngü (kart)', menuGizli: true, ic: '♨️', yetkiKodu: 'steril.dongu', menuSira: 77,
  },
  {
    kaynak: 'steril-paket', rota: 'steril-paket', aksiyonEkrani: 'steril-paket-liste', baslik: 'Steril Depo · Paketler',
    yol: 'Diş › Sterilizasyon › Steril Depo',
    cipler: [
      { ad: 'Steril', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Karantina', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Sterilde', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Bloke', filtre: { alan: 'durum', op: 'esit', deger: 7 } },
      { ad: 'Kullanıldı', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Steril Depo · Paketler', ic: '📦', yetkiKodu: 'steril.birim', menuSira: 72,
  },
  {
    kaynak: 'steril-birim', rota: 'steril-birim', aksiyonEkrani: 'steril-birim-liste', baslik: 'Setler · Döner Aletler',
    yol: 'Diş › Sterilizasyon › Setler · Döner Aletler',
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
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Setler · Döner Aletler', ic: '🧰', yetkiKodu: 'steril.birim', menuSira: 73,
  },
  {
    kaynak: 'steril-kullanim', rota: 'steril-kullanim', aksiyonEkrani: 'steril-kullanim-liste', baslik: 'Kullanım Kayıtları',
    yol: 'Diş › Sterilizasyon › Kullanım Kayıtları',
    tarihAlani: 'zaman',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Kullanım Kayıtları', ic: '🦷', yetkiKodu: 'steril.izleme', menuSira: 74,
  },
  {
    kaynak: 'steril-izleme', ozelSayfa: true, baslik: 'İzlenebilirlik · Geri Çağırma', yol: 'Diş › Sterilizasyon › İzlenebilirlik',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'İzlenebilirlik · Kayıt Defteri', ic: '🔍', yetkiKodu: 'steril.izleme', menuSira: 75,
  },
  {
    kaynak: 'steril-geri-cagirma', rota: 'steril-geri-cagirma', aksiyonEkrani: 'steril-geri-cagirma-liste', baslik: 'Geri Çağırmalar',
    yol: 'Diş › Sterilizasyon › Geri Çağırmalar',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Sterilizasyon', menuAd: 'Geri Çağırmalar', menuGizli: true, ic: '🚨', yetkiKodu: 'steril.izleme', menuSira: 76,
  },
  {
    kaynak: 'steril-set', rota: 'steril-set', aksiyonEkrani: 'steril-set-liste', baslik: 'Set Tanımları',
    yol: 'Diş › Sterilizasyon › Ayarlar › Set Tanımları',
    kartYolu: '/steril-set', kartBaslik: 'Set tanımı',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Set tanımları (içerik)', ic: '📋', yetkiKodu: 'steril.birim', menuSira: 95,
  },
  {
    kaynak: 'steril-cihaz', rota: 'steril-cihaz', aksiyonEkrani: 'steril-cihaz-liste', baslik: 'Cihazlar',
    yol: 'Diş › Sterilizasyon › Ayarlar › Cihazlar',
    kartYolu: '/steril-cihaz', kartBaslik: 'Cihaz',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Cihazlar', ic: '⚙️', yetkiKodu: 'steril.ayar', menuSira: 96,
  },
  {
    kaynak: 'steril-program', rota: 'steril-program', aksiyonEkrani: 'steril-program-liste', baslik: 'Programlar',
    yol: 'Diş › Sterilizasyon › Ayarlar › Programlar',
    kartYolu: '/steril-program', kartBaslik: 'Program',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Programlar', ic: '🌡', yetkiKodu: 'steril.ayar', menuSira: 97,
  },
  {
    kaynak: 'steril-bakim', rota: 'steril-bakim', aksiyonEkrani: 'steril-bakim-liste', baslik: 'Bakım · Validasyon',
    yol: 'Diş › Sterilizasyon › Ayarlar › Bakım',
    kartYolu: '/steril-bakim', kartBaslik: 'Bakım kaydı',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Bakım · Validasyon', ic: '🔧', yetkiKodu: 'steril.ayar', menuSira: 98,
  },
  {
    kaynak: 'steril-ayar', ozelSayfa: true, baslik: 'Test Takvimi · Kurallar', yol: 'Diş › Sterilizasyon › Ayarlar › Test Takvimi · Kurallar',
    urunModu: 2, modul: 'steril',
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Test takvimi · Kurallar', ic: '📅', yetkiKodu: 'steril.ayar', menuSira: 99,
  },
];
