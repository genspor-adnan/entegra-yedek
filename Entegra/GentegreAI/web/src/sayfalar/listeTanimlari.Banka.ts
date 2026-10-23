import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * BANKA HAREKETLERİ — db/1157, mockup `Ekranlar/ERP/banka_hareketleri.html`.
 *
 * Bankadan çekilen hareket (Garanti BBVA API / benzetim) öneriyle kasa işlemine
 * çevrilir: üstte hesap + "Bankadan Çek" + sayaçlar, sağda seçili hareketin kararı.
 * Eşleştirme kuralları Entegrasyonlar altında (mockup: "kurallar Entegrasyonlar'da").
 */
export const BANKA_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'banka-hareket', baslik: 'Banka Hareketleri', yol: 'Banka › Hareketler',
    aksiyonEkrani: 'banka-hareket-liste', urlFiltreAlani: 'hesapId',
    cipler: [
      { ad: 'Bekleyen',       filtre: { alan: 'durum', op: 'icinde', deger: [0, 1, 4] } },
      { ad: 'Öneri hazır',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Seçim bekliyor', filtre: { alan: 'durum', op: 'icinde', deger: [0, 4] } },
      { ad: 'Gelen',          filtre: { alan: 'tutar', op: 'buyuk', deger: 0 } },
      { ad: 'İşlendi',        filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Yoksayılan',     filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    kolonSirasi: ['islemTarihi', 'aciklama', 'karsiAd', 'tutar', 'bakiye', 'oneriMetni', 'oneriNeden', 'durumAdi'],
    toplam: ['gelen', 'giden'],
    menuGrup: 'Finans', menuSira: 32, menuAd: 'Banka Hareketleri', ic: '🔄', yetkiKodu: 'banka.hareket',
  },
  {
    kaynak: 'banka-kural', baslik: 'Banka Eşleştirme Kuralları', yol: 'Yönetim › Ayarlar › Entegrasyonlar',
    aksiyonEkrani: 'banka-kural-liste', kartYolu: '/banka-kural', kartBaslik: 'Eşleştirme Kuralı',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Banka Eşleştirme Kuralları', menuSira: 42, ic: '🧩', yetkiKodu: 'banka.kural',
  },
];
