import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * PATOLOJİ (1104) - "Tanı & Tetkik" bölgesinde Laboratuvar ve Radyoloji'nin yanında.
 * Mockup: Ekranlar/Patoloji/patoloji_sureci.html (Menü & modüller).
 *
 * TEK GRUP, İKİ İŞ YERİ: dış lab ve kurum içi vakalar aynı listede; "Nerede"
 * vakanın alanıdır, menünün değil. Kurum içi ekranları (kabul, makroskopi, doku
 * lab, patolog listesi, arşiv) aşama 2'de 'patoloji_ic' modülüyle eklenir.
 */
export const PATOLOJI_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'patoloji-vaka', rota: 'patoloji-vaka', baslik: 'Patoloji Vaka Listesi',
    yol: 'Patoloji › Patoloji Vaka Listesi',
    kartYolu: '/patoloji-vaka', kartBaslik: 'Patoloji Vakası', yeniSekmede: 'Yeni Patoloji İstemi Kartı',
    aksiyonEkrani: 'patoloji-vaka-liste',
    tarihAlani: 'istemZamani',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] } },
      { ad: '🏠 Kurum içi', filtre: { alan: 'calismaYeri', op: 'esit', deger: 2 } },
      { ad: '🚚 Dış lab', filtre: { alan: 'calismaYeri', op: 'esit', deger: 1 } },
      { ad: 'TAT aşan', filtre: { alan: 'tatAsti', op: 'esit', deger: 1 } },
      { ad: 'Ek onay bekleyen', filtre: { alan: 'ekOnayBekleyen', op: 'buyuk', deger: 0 } },
      { ad: 'Rapor geldi · görülmedi', filtre: { alan: 'durum', op: 'esit', deger: 11 } },
      { ad: 'Kapandı', filtre: { alan: 'durum', op: 'icinde', deger: [12, 90, 0] } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAd: 'Patoloji Vaka Listesi', menuSira: 10,
    ic: '🔬', yetkiKodu: 'patoloji.vaka',
  },
  {
    kaynak: 'patoloji-gonderim', rota: 'patoloji-gonderim', baslik: 'Dış Lab Gönderim Listesi',
    yol: 'Patoloji › Dış Lab Gönderim Listesi',
    kartYolu: '/patoloji-gonderim', kartBaslik: 'Dış Lab Gönderimi',
    aksiyonEkrani: 'patoloji-gonderim-liste',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2] } },
      { ad: 'Hazırlanıyor', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Yolda', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Lab teslim aldı', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'İletim hatası', filtre: { alan: 'iletimDurumu', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAd: 'Dış Lab Gönderim Listesi', menuSira: 20,
    ic: '🚚', yetkiKodu: 'patoloji.gonderim',
  },
  {
    // DIŞ LABORATUVARLAR: Lab ile ORTAK kart (aynı lab hem biyokimya hem patoloji);
    //   bu ekran yalnız patoloji hizmeti verenleri gösterir.
    kaynak: 'lab-dis-lab', rota: 'patoloji-dis-lab', baslik: 'Dış Laboratuvar Listesi',
    yol: 'Patoloji › Dış Laboratuvar Listesi',
    kartYolu: '/patoloji-dis-lab', kartBaslik: 'Dış Laboratuvar',
    aksiyonEkrani: 'lab-dis-lab-liste',
    cipler: [
      { ad: 'Patoloji', filtre: { alan: 'patoloji', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAltGrup: 'Ayarlar', menuAd: 'Dış Laboratuvar Listesi', menuSira: 210,
    ic: '🏥', yetkiKodu: 'patoloji.dislab',
  },
  {
    kaynak: 'patoloji-materyal-tipi', rota: 'patoloji-materyal-tipi', baslik: 'Materyal Tipi Listesi',
    yol: 'Patoloji › Ayarlar › Materyal Tipi Listesi',
    kartYolu: '/patoloji-materyal-tipi', kartBaslik: 'Materyal Tipi',
    aksiyonEkrani: 'patoloji-materyal-tipi-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'aktif', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAltGrup: 'Ayarlar', menuAd: 'Materyal Tipi Listesi', menuSira: 220,
    ic: '🧫', yetkiKodu: 'patoloji.tanim.materyal',
  },
  {
    kaynak: 'patoloji-boya', rota: 'patoloji-boya', baslik: 'Boya ve Antikor Listesi',
    yol: 'Patoloji › Ayarlar › Boya ve Antikor Listesi',
    kartYolu: '/patoloji-boya', kartBaslik: 'Boya / Antikor',
    aksiyonEkrani: 'patoloji-boya-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'İHK', filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Özel boya', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAltGrup: 'Ayarlar', menuAd: 'Boya ve Antikor Listesi', menuSira: 230,
    ic: '🎨', yetkiKodu: 'patoloji.tanim.boya',
  },
  {
    kaynak: 'patoloji-ret-nedeni', rota: 'patoloji-ret-nedeni', baslik: 'Ret Nedeni Listesi',
    yol: 'Patoloji › Ayarlar › Ret Nedeni Listesi',
    kartYolu: '/patoloji-ret-nedeni', kartBaslik: 'Ret Nedeni',
    aksiyonEkrani: 'patoloji-ret-nedeni-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'patoloji',
    menuGrup: 'Patoloji', menuAltGrup: 'Ayarlar', menuAd: 'Ret Nedeni Listesi', menuSira: 240,
    ic: '⛔', yetkiKodu: 'patoloji.tanim.ret',
  },
];
