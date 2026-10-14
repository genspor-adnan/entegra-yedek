import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * DİŞ KLİNİĞİ MODÜLÜ — db/706, tasarım notu
 * `Ekranlar/Dis Klinigi/dis_sureci.html`, mockuplar aynı klasörde.
 *
 * İş birimi TEDAVİ PLANIDIR: muayene bulguları odontograma işlenir, plan
 * satırları fiyatlanır ve seanslara bölünür, her seansta yapılan işlem
 * ücretlenir. Menü sırası günün akışı: Günlük Akış → Hastalar (odontogram)
 * → Tedavi Planları → Seanslar → Lab İş Emirleri → Ödeme Planları →
 * (Ayarlar) Ünitler / Laboratuvarlar.
 *
 * ÜRÜN MODU 2 (HBYS): diş kliniği ERP kurulumunda yoktur; modül `dis`
 * kurum profilinde kapalıysa grup hiç çizilmez.
 */
export const DIS_LISTELERI: ListeGirdisi[] = [
  {
    // GÜNLÜK AKIŞ - özel sayfa (DisGunlukAkis.tsx): ünit × saat çizelgesi +
    //   liste. Ayrı randevu takvimi DEĞİL, Randevu modülünün diş görünümü.
    kaynak: 'dis-akis', rota: 'dis-akis', ozelSayfa: true, baslik: 'Diş Kliniği Günlük Akış',
    yol: 'Diş › Günlük Akış',
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Günlük Akış', ic: '🪑', yetkiKodu: 'dis', menuSira: 10,
  },
  {
    // HASTALAR - satır bir hastadır; çift tık odontogram + plan kartını
    //   (özel sayfa /dis-hasta/:id) açar.
    kaynak: 'dis-hasta', rota: 'dis-hasta', aksiyonEkrani: 'dis-hasta-liste', baslik: 'Diş Hastası Listesi',
    yol: 'Diş › Hasta Listesi',
    kartYolu: '/dis-hasta', kartBaslik: 'Diş Hasta Kartı', ozelKart: true,
    tarihAlani: 'sonSeans',
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Aktif planı olan', filtre: { alan: 'aktifPlanNo', op: 'bosDegil', deger: '' } },
    ],
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Hasta Listesi (Odontogram)', ic: '🦷', yetkiKodu: 'dis.hasta', menuSira: 20,
  },
  {
    kaynak: 'dis-plan', rota: 'dis-plan', aksiyonEkrani: 'dis-plan-liste', baslik: 'Tedavi Planı Listesi',
    yol: 'Diş › Tedavi Planı Listesi',
    kartYolu: '/dis-plan', kartBaslik: 'Tedavi Planı', ozelKart: true,
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Taslak',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Sunuldu',    filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Onaylı',     filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Sürüyor',    filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tamamlandı', filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    toplam: ['toplam', 'indirim', 'net', 'yapilanTutar', 'tahsil', 'bakiye'],
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Tedavi Planı Listesi', ic: '📋', yetkiKodu: 'dis.plan', menuSira: 30,
  },
  {
    kaynak: 'dis-seans', rota: 'dis-seans', aksiyonEkrani: 'dis-seans-liste', baslik: 'Seans Listesi',
    yol: 'Diş › Seans Listesi',
    kartYolu: '/dis-seans', kartBaslik: 'Seans Kaydı', ozelKart: true,
    tarihAlani: 'baslangic',
    cipler: [
      { ad: 'Açık',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Bitti', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Seans Listesi', ic: '⏱️', yetkiKodu: 'dis.seans', menuSira: 40,
  },
  {
    // LAB İŞ EMİRLERİ - varsayılan sıralama gecikenler üstte (görünüm).
    kaynak: 'dis-lab-isemri', rota: 'dis-lab-isemri', aksiyonEkrani: 'dis-lab-isemri-liste',
    baslik: 'Lab İş Emiri Listesi', yol: 'Diş › Protez Laboratuvarı',
    kartYolu: '/dis-lab-isemri', kartBaslik: 'Lab İş Emri',
    tarihAlani: 'gonderim',
    cipler: [
      { ad: 'Ölçü bekliyor', filtre: { alan: 'asama', op: 'esit', deger: 1 } },
      { ad: 'Labda',         filtre: { alan: 'asama', op: 'icinde', deger: [2, 3, 4] } },
      { ad: 'Geldi · prova', filtre: { alan: 'asama', op: 'icinde', deger: [5, 6, 7] } },
      { ad: 'Gecikti',       filtre: { alan: 'gecikti', op: 'esit', deger: 1 } },
      { ad: 'Teslim edildi', filtre: { alan: 'asama', op: 'esit', deger: 8 } },
      { ad: 'Tümü' },
    ],
    toplam: ['labFiyat'],
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Lab İş Emiri Listesi', ic: '🧪', yetkiKodu: 'dis.lab', menuSira: 50,
  },
  {
    kaynak: 'dis-odeme-plani', rota: 'dis-odeme-plani', aksiyonEkrani: 'dis-odeme-plani-liste',
    baslik: 'Ödeme Planı Listesi', yol: 'Diş › Ödeme Planı Listesi',
    kartYolu: '/dis-odeme-plani', kartBaslik: 'Ödeme Planı',
    tarihAlani: 'ilkVade',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlandı', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    toplam: ['toplam', 'pesinat', 'odenen'],
    urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Ödeme Planı Listesi', ic: '💳', yetkiKodu: 'dis.odeme', menuSira: 60,
  },
  {
    kaynak: 'dis-unit', rota: 'dis-unit', aksiyonEkrani: 'dis-unit-liste', baslik: 'Ünit Listesi',
    yol: 'Diş › Ayarlar › Ünit Listesi',
    kartYolu: '/dis-unit', kartBaslik: 'Ünit',
    urunModu: 2,
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Ünit Listesi', ic: '🪑', yetkiKodu: 'dis.unit', menuSira: 90,
  },
  {
    kaynak: 'dis-lab', rota: 'dis-lab', aksiyonEkrani: 'dis-lab-liste', baslik: 'Laboratuvar Listesi',
    yol: 'Diş › Ayarlar › Laboratuvar Listesi',
    kartYolu: '/dis-lab', kartBaslik: 'Laboratuvar',
    urunModu: 2,
    menuGrup: 'Diş', menuAltGrup: 'Ayarlar', menuAd: 'Laboratuvar Listesi', ic: '🏭', yetkiKodu: 'dis.unit.lab', menuSira: 91,
  },
  {
    // DİŞ İCMALİ (1041, mockup İcmal/dis_icmali.html): hekim ciro / sarf / lab / kâr, plan hunisi,
    //   yarım kalan planlar, işlem türleri, lab ve ünite doluluğu.
    kaynak: 'dis-icmal', rota: 'dis-icmal', ozelSayfa: true, baslik: 'Diş İcmali',
    yol: 'Diş › Diş İcmali', urunModu: 2,
    menuGrup: 'Diş', menuAd: 'Diş İcmali', ic: '@icmal', yetkiKodu: 'dis.icmal', menuSira: 70,
  },
];
