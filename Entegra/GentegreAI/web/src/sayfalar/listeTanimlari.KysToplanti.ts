import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — TOPLANTILAR ve KARAR TAKİBİ (db/1053, sade) — mockup
 * `Ekranlar/Kalite/kalite_ygg_toplanti.html` (yalnız toplantı / karar çekirdeği).
 *
 * Toplantı kartı generic: tarih, komite (boş = YGG), yer, gündem ve
 * katılımcılar metin; altında Kararlar tablosu. Karar Takibi aynı kararların
 * açık olanlarla açılan listesi (geciken rozetli).
 */
export const KYS_TOPLANTI_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-toplanti', rota: 'kys-toplanti', aksiyonEkrani: 'kys-toplanti-liste', baslik: 'Kalite Toplantıları (Komite / YGG)',
    yol: 'Kalite › Toplantılar',
    kartYolu: '/kys-toplanti', kartBaslik: 'Toplantı',
    tarihAlani: 'tarih',
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Toplantılar', ic: '🏛️', yetkiKodu: 'kys.toplanti', menuSira: 70,
  },
  {
    kaynak: 'kys-karar', rota: 'kys-karar', aksiyonEkrani: 'kys-karar-liste', baslik: 'Karar Takibi',
    yol: 'Kalite › Karar Takibi',
    kartYolu: '/kys-karar', kartBaslik: 'Karar',
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Gecikti', filtre: { alan: 'durumAdi', op: 'esit', deger: 'Gecikti' } },
      { ad: 'Tamam',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Karar Takibi', ic: '📌', yetkiKodu: 'kys.karar', menuSira: 71,
  },
];
