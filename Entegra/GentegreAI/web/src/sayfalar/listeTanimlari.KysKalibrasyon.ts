import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — ÖLÇÜM CİHAZLARI & KALİBRASYON (db/1058, sade), mockup
 * `Ekranlar/Kalite2/kalibrasyon.html` (ISO 9001 7.1.5).
 * Satır = kalibrasyona tâbi demirbaş; ayrı envanter yok. Kart cihazı açar,
 * "Kalibrasyon kayıtları" sekmesine satır eklenir. Sabit Varlıklar ›
 * Kalibrasyon (demirbas.kalibrasyon) ayrı ekran, ayrı kod.
 */
export const KYS_KALIBRASYON_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-kalibrasyon', rota: 'kys-kalibrasyon', baslik: 'Ölçüm Cihazları & Kalibrasyon',
    yol: 'Kalite › Kalibrasyon',
    kartYolu: '/kys-kalibrasyon', kartBaslik: 'Kalibrasyon',
    aksiyonEkrani: 'kys-kalibrasyon-liste',
    // Açılış "30 gün içinde": geçmiş + yaklaşan birlikte (durum 2 ve 3).
    cipler: [
      { ad: '30 gün içinde', filtre: { alan: 'durum', op: 'buyukEsit', deger: 2 } },
      { ad: 'Süresi geçti',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Kalibrasyon', ic: '📏', yetkiKodu: 'kys.kalibrasyon', menuSira: 110,
  },
];
