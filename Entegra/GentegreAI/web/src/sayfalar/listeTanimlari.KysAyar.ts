import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — AYARLAR + KALİTE DOKÜMANLARI (db/1048, 1049).
 * Mockuplar Ekranlar/Kalite/kalite_ayarlar.html, kalite_dokuman_yonetimi.html.
 *
 * KALİTE DOKÜMANLARI (1068, mockup Kalite2/kalite_dokumanlari.html): kendi
 * listesi (v_kalite_dokuman, kys.dokuman yetkisi) - "Kalite Dokümanları"
 * kategori ağacı. Kart yeniden yazılmaz (kullanıcı 12.10.2026: "doküman
 * kartını doküman modülünden kullanalım"): satır Doküman modülünün kartını
 * açar; sürüm, onay, yayın, paylaşım orada. Yükle / Aç doküman yetkisi ister.
 *
 * Ayarlar: birim kalite sorumluları ve komiteler (+ üyeler) generic liste + kart,
 * Birim sorumluları kys.ayar, komiteler kys.komite (1054).
 */
export const KYS_AYAR_LISTELERI: ListeGirdisi[] = [
  {
    // 1068 (mockup Kalite2/kalite_dokumanlari.html): kendi kaynağı (v_kalite_dokuman,
    //   kys.dokuman yetkisi); kart Doküman modülünün kartı.
    kaynak: 'kys-dokuman', rota: 'kys-dokuman', baslik: 'Kalite Dokümanları',
    yol: 'Kalite › Kalite Dokümanları · Doküman modülünün kalite kategorileri',
    kartYolu: '/dokuman', kartBaslik: 'Doküman',
    aksiyonEkrani: 'kys-dokuman-liste',
    cipler: [
      { ad: 'Yürürlükte',           filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Onay bekliyor',        filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Gözden geçirme vakti', filtre: { alan: 'gozdenGecti', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Kalite', menuAd: 'Kalite Dokümanları', modul: 'kys', ic: '📚', yetkiKodu: 'kys.dokuman', menuSira: 15,
  },
  {
    kaynak: 'kys-birim-sorumlu', rota: 'kys-birim-sorumlu', baslik: 'Birim Kalite Sorumluları',
    yol: 'Kalite › Ayarlar › Birim Sorumluları',
    kartYolu: '/kys-birim-sorumlu', kartBaslik: 'Birim Kalite Sorumlusu',
    aksiyonEkrani: 'kys-birim-sorumlu-liste',
    cipler: [
      { ad: 'Aktif',      filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Sorumlusuz', filtre: { alan: 'sorumluYok', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Kalite', menuAltGrup: 'Ayarlar', menuAd: 'Birim Sorumluları', modul: 'kys', ic: '👤',
    yetkiKodu: 'kys.ayar', menuSira: 210,
  },
  {
    kaynak: 'kys-komite', rota: 'kys-komite', baslik: 'Komiteler',
    yol: 'Kalite › Ayarlar › Komiteler',
    kartYolu: '/kys-komite', kartBaslik: 'Komite',
    aksiyonEkrani: 'kys-komite-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Kalite', menuAltGrup: 'Ayarlar', menuAd: 'Komiteler', modul: 'kys', ic: '👥',
    yetkiKodu: 'kys.komite', menuSira: 220,
  },
];
