import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — OLAY BİLDİRİMİ + RİSK KAYDI (db/1052), mockuplar
 * `Ekranlar/Kalite/kalite_olay_bildirim.html`, `kalite_risk_yonetimi.html`.
 * Sade: liste + generic kart; listeden DÖF açılır (kaynakTur 2 / 4).
 */
export const KYS_OLAY_RISK_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-olay', rota: 'kys-olay', baslik: '⚠️ Olay / Uygunsuzluk Bildirimleri',
    yol: 'Kalite › Olay Bildirimleri · Her çalışan bildirebilir · anonim seçenekli',
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
    kaynak: 'kys-risk', rota: 'kys-risk', baslik: 'Riskler',
    yol: 'Kalite › Riskler',
    kartYolu: '/kys-risk', kartBaslik: 'Risk',
    aksiyonEkrani: 'kys-risk-liste',
    cipler: [
      // Mockup Kalite2/risk_listesi.html (1062): Açık · Yüksek · Gözden geçirme vakti · Tümü.
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'icinde', deger: [1, 2] } },
      { ad: 'Yüksek',     filtre: { alan: 'seviye', op: 'buyukEsit', deger: 3 } },
      { ad: 'Gözden geçirme vakti', filtre: { alan: 'gozdenGecirmeGecti', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Riskler', ic: '🎯', yetkiKodu: 'kys.risk', menuSira: 50,
  },
];
