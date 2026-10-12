import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — TEDARİKÇİ DEĞERLENDİRME (db/1057), mockup
 * `Ekranlar/Kalite2/tedarikci.html` (sade, ISO 9001 md. 8.4).
 * Satır = tedarikçinin son değerlendirmesi; kart = değerlendirme kaydı
 * (generic). Satırdan "Yeniden değerlendir" ve "DÖF aç" (kaynakTur 8).
 * Onaylı Tedarikçi Listesi = "Onaylı" çipi + liste yazdır.
 */
export const KYS_TEDARIKCI_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-tedarikci', rota: 'kys-tedarikci', aksiyonEkrani: 'kys-tedarikci-liste',
    baslik: '🚚 Tedarikçi Değerlendirme',
    yol: 'Kalite › Tedarikçi Değerlendirme · ISO 9001 · 8.4 dış tedarikçi kontrolü · yılda 1',
    kartYolu: '/kys-tedarikci', kartBaslik: 'Tedarikçi Değerlendirmesi',
    cipler: [
      { ad: 'Onaylı',              filtre: { alan: 'sonuc', op: 'esit', deger: 1 } },
      { ad: 'Şartlı',              filtre: { alan: 'sonuc', op: 'esit', deger: 2 } },
      { ad: 'Değerlendirme vakti', filtre: { alan: 'vakti', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Tedarikçi Değerlendirme', ic: '🚚', yetkiKodu: 'kys.tedarikci', menuSira: 100,
  },
];
