import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * PERSONEL BELGE TAKİBİ (db/1135) — mockup `Ekranlar/IK/personel_belge_takibi.html`.
 *
 * Tek menü girdisi (ik.belge_takip.liste): "Belge Takibi" personel başına tek
 * satır (id = personel id, çift tık personel kartı - kartın "Belgeler" ve
 * "Belge Durumu" sekmeleri). "Belge Türleri" aynı ekranın sekmesi (rotalı cip).
 */
const SEKMELER = [
  { ad: '📋 Belge Takibi', rota: 'personel-belge-ozet', sekme: true },
  { ad: '🗂 Belge Türleri', rota: 'personel-belge-turu', sekme: true },
];

export const PERSONEL_BELGE_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'personel-belge-ozet', rota: 'personel-belge-ozet', baslik: 'Belge Takibi',
    yol: 'İK › Belge Takibi',
    kartYolu: '/personel', kartBaslik: 'Personel',
    cipler: [
      { ad: 'Eksik / süresi dolan', filtre: { op: 'or', kosullar: [
        { alan: 'eksik', op: 'buyuk', deger: 0 }, { alan: 'doldu', op: 'buyuk', deger: 0 }] } },
      { ad: 'Yaklaşan', filtre: { alan: 'yaklasan', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
      ...SEKMELER,
    ],
    menuGrup: 'İK', menuAd: 'Belge Takibi', ic: '📎',
    yetkiKodu: 'ik.belge_takip.liste', modul: 'ik', menuSira: 17,
  },
  {
    kaynak: 'personel-belge-turu', rota: 'personel-belge-turu', aksiyonEkrani: 'personel-belge-turu-liste',
    baslik: 'Belge Türleri', yol: 'İK › Belge Takibi › Belge Türleri',
    kartYolu: '/personel-belge-turu', kartBaslik: 'Belge Türü',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
      ...SEKMELER,
    ],
    menuGrup: 'İK', menuAd: 'Belge Türleri', menuGizli: true, ic: '🗂',
    yetkiKodu: 'ik.belge_takip.liste', modul: 'ik',
  },
];
