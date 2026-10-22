import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * PERSONEL BELGE TAKİBİ (db/1135) — mockup `Ekranlar/IK/personel_belge_takibi.html`.
 *
 * Tek menü girdisi (ik.belge_takip.liste): "Belge Takibi" personel başına tek
 * satır (id = personel id, çift tık personel kartı - kartın "Belgeler"
 * sekmesi). "Belge Türleri" aynı ekranın sekmesi (rotalı cip).
 * Mockup (2): üstte sayaç şeridi (BelgeTakipOzetSeridi - kutular çip sırasına
 * bağlı: 0 eksik/doldu, 1 yaklaşan, 2 tümü), "📤 Seçililere hatırlat" (1137),
 * varsayılan "yalnız eksiği olanlar".
 */
const AKTIF = { alan: 'aktif', op: 'esit' as const, deger: 1 };

const SEKMELER = [
  { ad: '📋 Belge Takibi', rota: 'personel-belge-ozet', sekme: true },
  { ad: '🗂 Belge Türleri', rota: 'personel-belge-turu', sekme: true },
];

export const PERSONEL_BELGE_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'personel-belge-ozet', rota: 'personel-belge-ozet', baslik: 'Belge Takibi',
    yol: 'İK › Belge Takibi', aksiyonEkrani: 'personel-belge-ozet-liste',
    kartYolu: '/personel', kartBaslik: 'Personel',
    cipler: [
      { ad: 'Eksiği olanlar', filtre: { op: 'or', kosullar: [
        { alan: 'eksik', op: 'buyuk', deger: 0 }, { alan: 'doldu', op: 'buyuk', deger: 0 }] } },
      { ad: 'Yaklaşan', filtre: { alan: 'yaklasan', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
      ...SEKMELER,
    ],
    menuGrup: 'İK', menuAd: 'Belge Takibi', ic: '📎',
    yetkiKodu: 'ik.belge_takip.liste', modul: 'ik', menuSira: 17,
  },
  {
    // Mockup personel_belge_turu.html (1): sayaç kartları (BelgeTuruOzetSeridi - kutu sırası çip
    //   sırasıdır: 0 aktif, 1 zorunlu, 2 süreli, 3 eksiği olan, 4 isteğe bağlı), grup çipleri
    //   (onCipler, ana çiple AND'lenir), grup başlıklı grid (sunucu GrupKolonu), pasif satır soluk.
    kaynak: 'personel-belge-turu', rota: 'personel-belge-turu', aksiyonEkrani: 'personel-belge-turu-liste',
    baslik: 'Belge Türleri', yol: 'İK › Belge Takibi › Belge Türleri',
    kartYolu: '/personel-belge-turu', kartBaslik: 'Belge Türü', grupBirimi: 'tür',
    cipler: [
      { ad: 'Aktif', filtre: AKTIF },
      { ad: 'Zorunlu', filtre: { op: 'and', kosullar: [AKTIF, { alan: 'kapsamli', op: 'esit', deger: 1 }] } },
      { ad: 'Süreli', filtre: { op: 'and', kosullar: [AKTIF, { alan: 'sureli', op: 'esit', deger: 1 }] } },
      { ad: 'Eksiği olan', filtre: { op: 'and', kosullar: [AKTIF, { op: 'or', kosullar: [
        { alan: 'eksik', op: 'buyuk', deger: 0 }, { alan: 'doldu', op: 'buyuk', deger: 0 }] }] } },
      { ad: 'İsteğe bağlı', filtre: { op: 'and', kosullar: [AKTIF, { alan: 'kapsamli', op: 'esit', deger: 0 }] } },
      { ad: 'Pasifler', filtre: { alan: 'aktif', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
      ...SEKMELER,
    ],
    onCipler: [
      { ad: 'Tüm gruplar' },
      { ad: 'Kimlik / işe giriş', filtre: { alan: 'grup', op: 'esit', deger: 1 } },
      { ad: 'Mesleki', filtre: { alan: 'grup', op: 'esit', deger: 2 } },
      { ad: 'Sağlık / İSG', filtre: { alan: 'grup', op: 'esit', deger: 3 } },
      { ad: 'İdari', filtre: { alan: 'grup', op: 'esit', deger: 4 } },
      { ad: 'Diğer', filtre: { alan: 'grup', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'İK', menuAd: 'Belge Türleri', menuGizli: true, ic: '🗂',
    yetkiKodu: 'ik.belge_takip.liste', modul: 'ik',
  },
];
