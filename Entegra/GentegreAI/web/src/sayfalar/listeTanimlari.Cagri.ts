import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * ÇAĞRI MERKEZİ MODÜLÜ — db/839, mockuplar `Ekranlar/CagriMerkezi/*.html`.
 *
 * Günün akışı: Operatör Panosu (gelen çağrı, arayan tanıma, hızlı işlem, kayıt)
 * → Geri Arama · Kampanya (giden) → Çağrı Kayıtları → Süpervizör Panosu →
 * Kalite; Ayarlar alt grubu: konu ağacı, kuyruklar, agentlar, santral / IVR.
 * Çağrı kartı özel sayfa (`/cagri/:id`); düzenleme generic kart (`/cagri-kart`).
 */
export const CAGRI_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'cagri-pano', ozelSayfa: true, baslik: 'Operatör Panosu', yol: 'Çağrı Merkezi › Operatör Panosu',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Operatör Panosu', ic: '🎧', yetkiKodu: 'cagri.pano', menuSira: 10,
  },
  {
    kaynak: 'cagri-giden', ozelSayfa: true, baslik: 'Giden Arama · Kampanya', yol: 'Çağrı Merkezi › Giden Arama',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Giden Arama · Kampanya', ic: '📤', yetkiKodu: 'cagri.giden', menuSira: 20,
  },
  {
    kaynak: 'cagri', rota: 'cagri', aksiyonEkrani: 'cagri-liste', baslik: 'Çağrı Kayıtları',
    yol: 'Çağrı Merkezi › Çağrı Kayıtları',
    kartYolu: '/cagri', kartBaslik: 'Çağrı Kartı', ozelKart: true,
    tarihAlani: 'baslama',
    cipler: [
      { ad: 'Kayıt bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Kaçan',          filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Geri aranacak',  filtre: { alan: 'sonuc', op: 'esit', deger: 2 } },
      { ad: 'Gelen',          filtre: { alan: 'yon', op: 'esit', deger: 1 } },
      { ad: 'Giden',          filtre: { alan: 'yon', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Çağrı Kayıtları', ic: '📞', yetkiKodu: 'cagri.kayit', menuSira: 30,
  },
  {
    // GENERIC ÇAĞRI KARTI (menüde gizli): alan düzenleme (konu / sonuç / not) ve
    //   ilgili kayıt / olay detayları GenForm'da; özel kart (/cagri/:id) buraya "Düzenle" ile gelir.
    kaynak: 'cagri', rota: 'cagri-kart', aksiyonEkrani: 'cagri-liste', baslik: 'Çağrı (kart)',
    yol: 'Çağrı Merkezi › Çağrı',
    kartYolu: '/cagri-kart', kartBaslik: 'Çağrı',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Çağrı (kart)', menuGizli: true, ic: '📞', yetkiKodu: 'cagri.kayit', menuSira: 31,
  },
  {
    kaynak: 'cagri-kampanya', rota: 'cagri-kampanya', aksiyonEkrani: 'cagri-kampanya-liste', baslik: 'Kampanyalar',
    yol: 'Çağrı Merkezi › Kampanyalar',
    kartYolu: '/cagri-kampanya', kartBaslik: 'Kampanya',
    cipler: [
      { ad: 'Çalışıyor', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Taslak',    filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Kampanyalar', ic: '📣', yetkiKodu: 'cagri.kampanya', menuSira: 40,
  },
  {
    kaynak: 'cagri-kampanya-kisi', rota: 'cagri-kampanya-kisi', aksiyonEkrani: 'cagri-kampanya-kisi-liste', baslik: 'Kampanya Kişileri',
    yol: 'Çağrı Merkezi › Kampanya Kişileri',
    cipler: [
      { ad: 'Aranacak',    filtre: { alan: 'aranacak', op: 'esit', deger: 1 } },
      { ad: 'Bekliyor',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Ulaşılamadı', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tamamlandı',  filtre: { alan: 'durum', op: 'buyuk', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Kampanya Kişileri', menuGizli: true, ic: '👥', yetkiKodu: 'cagri.kampanya', menuSira: 41,
  },
  {
    kaynak: 'cagri-supervizor', ozelSayfa: true, baslik: 'Süpervizör Panosu', yol: 'Çağrı Merkezi › Süpervizör Panosu',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Süpervizör Panosu', ic: '📊', yetkiKodu: 'cagri.supervizor', menuSira: 50,
  },
  {
    kaynak: 'cagri-kalite', rota: 'cagri-kalite', aksiyonEkrani: 'cagri-kalite-liste', baslik: 'Kalite Değerlendirmeleri',
    yol: 'Çağrı Merkezi › Kalite',
    kartYolu: '/cagri-kalite', kartBaslik: 'Kalite değerlendirmesi',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAd: 'Kalite Değerlendirmeleri', ic: '⭐', yetkiKodu: 'cagri.kalite', menuSira: 60,
  },
  {
    kaynak: 'cagri-konu', rota: 'cagri-konu', aksiyonEkrani: 'cagri-konu-liste', baslik: 'Konu Ağacı',
    yol: 'Çağrı Merkezi › Ayarlar › Konu Ağacı',
    kartYolu: '/cagri-konu', kartBaslik: 'Konu',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAltGrup: 'Ayarlar', menuAd: 'Konu ağacı & SLA', ic: '🗂', yetkiKodu: 'cagri.ayar', menuSira: 90,
  },
  {
    kaynak: 'cagri-kuyruk', rota: 'cagri-kuyruk', aksiyonEkrani: 'cagri-kuyruk-liste', baslik: 'Kuyruklar',
    yol: 'Çağrı Merkezi › Ayarlar › Kuyruklar',
    kartYolu: '/cagri-kuyruk', kartBaslik: 'Kuyruk',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAltGrup: 'Ayarlar', menuAd: 'Kuyruklar & SLA', ic: '👥', yetkiKodu: 'cagri.ayar', menuSira: 91,
  },
  {
    kaynak: 'cagri-agent', rota: 'cagri-agent', aksiyonEkrani: 'cagri-agent-liste', baslik: 'Agentlar',
    yol: 'Çağrı Merkezi › Ayarlar › Agentlar',
    kartYolu: '/cagri-agent', kartBaslik: 'Agent',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAltGrup: 'Ayarlar', menuAd: 'Agentlar (dahili)', ic: '🎧', yetkiKodu: 'cagri.ayar', menuSira: 92,
  },
  {
    kaynak: 'cagri-santral', ozelSayfa: true, baslik: 'Santral · IVR · Kanallar', yol: 'Çağrı Merkezi › Ayarlar › Santral',
    urunModu: 2, modul: 'cagri',
    menuGrup: 'Çağrı Merkezi', menuAltGrup: 'Ayarlar', menuAd: 'Santral · IVR · Kanallar', ic: '⚙️', yetkiKodu: 'cagri.ayar', menuSira: 93,
  },
];
