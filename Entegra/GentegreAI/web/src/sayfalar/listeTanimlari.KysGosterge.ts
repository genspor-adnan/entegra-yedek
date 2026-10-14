import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — POLİTİKA & HEDEFLER (db/1053 + 1059, sade) — mockup
 * `Ekranlar/Kalite2/hedefler.html`. Üstte politika & kapsam şeridi
 * (KysPolitikaSeridi), altta hedef / gösterge tablosu; hedef dışı satırdan
 * "DÖF aç" (kaynak 7). Müşteri memnuniyeti ayrı ekran değil, bir hedef satırı.
 *
 * Liste son dönem değerini ve hedefte / hedef dışı durumunu gösterir; generic
 * kart (kod, ad, formül, hedef, yön, periyot, birim, sorumlu) altında Dönem
 * değerleri tablosu. Klinik Kalite göstergeleri ayrı menüde (Klinik Kalite).
 */
export const KYS_GOSTERGE_LISTELERI: ListeGirdisi[] = [
  // MENÜ GİRİŞİ (1063, mockup Kalite2/hedefler.html): Hedefler + Politika & Kapsam
  //   sekmeli özel sayfa (KysHedefler). Aşağıdaki generic liste menüde görünmez;
  //   hedef kartı (/kys-gosterge/:id) ve dönem değerleri onunla açılır.
  {
    kaynak: 'kys-hedefler', rota: 'kys-hedefler', ozelSayfa: true, baslik: 'Kalite Politikası & Hedef Listesi',
    yol: 'Kalite › Politika & Hedefler',
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Politika & Hedefler', ic: '📈', yetkiKodu: 'kys.gosterge', menuSira: 60,
  },
  {
    kaynak: 'kys-gosterge', rota: 'kys-gosterge', aksiyonEkrani: 'kys-gosterge-liste', baslik: 'Kalite Politikası & Hedef Listesi',
    yol: 'Kalite › Politika & Hedefler',
    kartYolu: '/kys-gosterge', kartBaslik: 'Hedef',
    cipler: [
      { ad: 'Aktif',      filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Hedef dışı', filtre: { alan: 'durumAdi', op: 'esit', deger: 'Hedef dışı' } },
      { ad: 'Veri yok',   filtre: { alan: 'durumAdi', op: 'esit', deger: 'Veri yok' } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Hedef Listesi', menuGizli: true, ic: '📈', yetkiKodu: 'kys.gosterge', menuSira: 61,
  },
];
