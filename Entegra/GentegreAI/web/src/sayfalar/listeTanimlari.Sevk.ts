import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * SEVK (1110) - mockup Ekranlar/Muayene/sevk_listesi_v2.html · sevk_karti_v2.html (sade).
 * Muayene grubunda; Giden / Gelen sekmeleri ve kısa ön izleme Liste'de (SevkPanelleri).
 */
export const SEVK_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'sevk', rota: 'sevk', baslik: 'Sevk Listesi',
    yol: 'Muayene › Sevk Listesi',
    kartYolu: '/sevk', kartBaslik: 'Sevk', yeniSekmede: 'Yeni Sevk Kartı',
    // YENİ / DÜZENLE / SİL (kullanıcı 15.10.2026): AksiyonKatalogu "sevk-liste".
    aksiyonEkrani: 'sevk-liste',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'acik', op: 'esit', deger: 1 } },
      { ad: 'Kurum dışı', filtre: { alan: 'tur', op: 'esit', deger: 1 } },
      { ad: 'Kurum içi', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Yatış', filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'icinde', deger: [3, 0] } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 26, menuGrup: 'Muayene', menuAd: 'Sevk Listesi', ic: '↗️', yetkiKodu: 'muayene.sevk',
  },
];
