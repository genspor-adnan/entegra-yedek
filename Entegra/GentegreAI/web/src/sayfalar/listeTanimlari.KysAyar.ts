import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * KURUMSAL KALİTE — AYARLAR + KALİTE DOKÜMANLARI (db/1048, 1049).
 * Mockuplar Ekranlar/Kalite/kalite_ayarlar.html, kalite_dokuman_yonetimi.html.
 *
 * KALİTE DOKÜMANLARI ayrı ekran DEĞİL (kullanıcı 12.10.2026: "yalnız doküman
 * kartını yapma.. onu doküman modülünden kullanalım"): doküman modülünün
 * listesi ve kartı, "Kalite Dokümanları" kategori ağacına süzülü. Yükleme,
 * sürüm, onaya gönderme, yayın, paylaşım doküman kartından / aksiyonlarından.
 * Sunucu listesi `dokuman` yetkisini ister - kalite menüsü (kys.dokuman)
 * görünür ama doküman yetkisi olmayan kullanıcı listeyi açamaz.
 *
 * Ayarlar: birim kalite sorumluları ve komiteler (+ üyeler) generic liste + kart,
 * Birim sorumluları kys.ayar, komiteler kys.komite (1054).
 */
const KALITE_KOKU = 'Kalite Dokümanları';

export const KYS_AYAR_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'dokuman', rota: 'kys-dokuman', baslik: 'Kalite Dokümanları',
    yol: 'Kalite › Kalite Dokümanları',
    kartYolu: '/kys-dokuman', kartBaslik: 'Doküman',
    aksiyonEkrani: 'dokuman-liste',
    tarihAlani: 'eklemeTarihi',
    // Kategori YOLU kökle başlar (431 tetiği "Kalite Dokümanları › Prosedür" yazar).
    sabitFiltre: { alan: 'kategoriAdi', op: 'baslar', deger: KALITE_KOKU },
    kolonSirasi: ['dosyaTipi', 'kod', 'ad', 'kategoriAdi', 'surumNo', 'sahipAdi', 'gecerliBit', 'degistirmeTarihi', 'durumAdi'],
    kolonBasliklari: { kategoriAdi: 'Tür', surumNo: 'Rev.' },
    gizliKolonlar: ['kaynakYolu', 'boyutKb', 'paylasimSayisi'],
    cipler: [
      { ad: 'Yürürlükte',     filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Taslak',         filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Onay bekliyor',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Arşiv',          filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Prosedür', ayracOnce: true, filtre: { alan: 'kategoriAdi', op: 'esit', deger: `${KALITE_KOKU} › Prosedür` } },
      { ad: 'Talimat',        filtre: { alan: 'kategoriAdi', op: 'esit', deger: `${KALITE_KOKU} › Talimat` } },
      { ad: 'Form',           filtre: { alan: 'kategoriAdi', op: 'esit', deger: `${KALITE_KOKU} › Form` } },
      { ad: 'Liste',          filtre: { alan: 'kategoriAdi', op: 'esit', deger: `${KALITE_KOKU} › Liste` } },
      { ad: 'Plan',           filtre: { alan: 'kategoriAdi', op: 'esit', deger: `${KALITE_KOKU} › Plan` } },
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
