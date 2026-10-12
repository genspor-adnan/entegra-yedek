import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE - İÇ DENETİM (db/1051, sade) — mockup `Ekranlar/Kalite/kalite_ic_denetim.html`.
 * Liste + generic kart (bulgular detayı: majör / minör / gözlem, ISO / SKS maddesi).
 */
export const KYS_DENETIM_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'kys-denetim', rota: 'kys-denetim', baslik: 'İç Denetimler', yol: 'Kalite › İç Denetimler',
    kartYolu: '/kys-denetim', kartBaslik: 'İç Denetim', aksiyonEkrani: 'kys-denetim-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Planlı',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlandı', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'İç Denetimler', ic: '🔎', yetkiKodu: 'kys.denetim', menuSira: 40,
  },
  // DENETİM BULGULARI (1059): kart detay satırında düğme yok - "DÖF aç"
  //   (kaynak 1) bu listenin satır aksiyonu. Menüde görünmez (tek kod tek
  //   menü); denetim listesindeki "📋 Bulgular / DÖF" ?denetimId= ile açar.
  {
    kaynak: 'kys-denetim-bulgu', rota: 'kys-denetim-bulgu', baslik: 'Denetim Bulguları',
    yol: 'Kalite › İç Denetimler › Bulgular', aksiyonEkrani: 'kys-denetim-bulgu-liste',
    urlFiltreAlani: 'denetimId', tarihAlani: 'tarih',
    cipler: [
      { ad: 'DÖF açılmamış', filtre: { alan: 'dofNo', op: 'esit', deger: '' } },
      { ad: 'Majör',          filtre: { alan: 'sinif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    modul: 'kys',
    menuGrup: 'Kalite', menuAd: 'Denetim Bulguları', menuGizli: true, ic: '📋', yetkiKodu: 'kys.denetim', menuSira: 41,
  },
];
