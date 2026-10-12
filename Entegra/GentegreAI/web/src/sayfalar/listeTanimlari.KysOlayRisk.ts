import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — OLAY BİLDİRİMİ + RİSK KAYDI (db/1052), mockuplar
 * `Ekranlar/Kalite/kalite_olay_bildirim.html`, `kalite_risk_yonetimi.html`.
 * Sade: liste + generic kart; listeden DÖF açılır (kaynakTur 2 / 4).
 */
export const KYS_OLAY_RISK_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-olay', rota: 'kys-olay', baslik: 'Olay Bildirimleri',
    yol: 'Kalite › Olay Bildirimleri',
    kartYolu: '/kys-olay', kartBaslik: 'Olay Bildirimi',
    aksiyonEkrani: 'kys-olay-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Yeni',            filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Değerlendirmede', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kapandı',         filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Olay Bildirimleri', ic: '⚠️', yetkiKodu: 'kys.olay', menuSira: 20,
  },
  {
    kaynak: 'kys-risk', rota: 'kys-risk', baslik: 'Risk Kaydı',
    yol: 'Kalite › Risk Kaydı',
    kartYolu: '/kys-risk', kartBaslik: 'Risk',
    aksiyonEkrani: 'kys-risk-liste',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Önlemde',    filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Yüksek +',   filtre: { alan: 'seviye', op: 'buyukEsit', deger: 3 } },
      { ad: 'Kapandı',    filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Risk Kaydı', ic: '🎯', yetkiKodu: 'kys.risk', menuSira: 50,
  },
];
