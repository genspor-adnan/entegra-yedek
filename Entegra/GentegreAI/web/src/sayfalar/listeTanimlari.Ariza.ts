import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * ARIZA / TALEP (hizmet masası, 911) — demirbaş-bağımsız genel arıza.
 *
 * İKİ EKRAN, İKİ ROL:
 *   Arıza Bildir      HERKES (yetki ariza.talep) — "klima/pencere/PC/masa"
 *                     kategori seçer, sistem sorumlu ekibe yönlendirir.
 *   Arıza Talepleri   EKİP (yetki ariza) — gelen talepleri devralır, çözer,
 *                     kapatır. Serbest kart yok; sabit akış (aksiyonlar uçta).
 *
 * BİYOMEDİKAL "Bakım / Arıza"DAN FARKI: o bir DEMİRBAŞA (tıbbi cihaz) bağlı
 * iş emri; bu, demirbaşı olmayan arıza için. Aynı "Teknik Servis" grubunda
 * (modül `servis`), ekipler ortak.
 */
export const ARIZA_LISTELERI: ListeGirdisi[] = [
  {
    // SELF-SERVİS ÖZEL SAYFA: liste değil form. Menüde grubun EN ÜSTÜnde -
    //   en sık ve en geniş kitlenin kullandığı ekran budur.
    kaynak: 'ariza-bildir', rota: 'ariza-bildir', ozelSayfa: true,
    baslik: 'Arıza Bildir',
    yol: 'Teknik Servis › Arıza Bildir',
    menuGrup: 'Teknik Servis', menuAd: 'Arıza Bildir', ic: '🔧',
    yetkiKodu: 'ariza.talep', modul: 'servis', menuSira: 5,
  },
  {
    kaynak: 'ariza-talep', rota: 'ariza-talep',
    baslik: 'Arıza Talepleri',
    yol: 'Teknik Servis › Arıza Talepleri',
    aksiyonEkrani: 'ariza-talep-liste',
    tarihAlani: 'ekleme',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'kucuk', deger: 4 } },
      { ad: 'Bende',      filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Acil',       filtre: { alan: 'oncelik', op: 'esit', deger: 4 } },
      { ad: 'Çözüldü',    filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Teknik Servis', menuAd: 'Arıza Talepleri', ic: '🧰',
    yetkiKodu: 'ariza', modul: 'servis', menuSira: 8,
  },
  {
    // EKİP ÜYELERİ + NÖBETÇİ (955, mockup Ekranlar/Taleplerim/gelen_talepler.html):
    //   iş kime düşer, acilde kim aranır.
    kaynak: 'ariza-ekipleri', rota: 'ariza-ekipleri', ozelSayfa: true,
    baslik: 'Arıza Ekipleri',
    yol: 'Teknik Servis › Arıza Ekipleri',
    menuGrup: 'Teknik Servis', menuAd: 'Arıza Ekipleri', ic: '👥',
    yetkiKodu: 'ariza', modul: 'servis', menuSira: 9,
  },
];
