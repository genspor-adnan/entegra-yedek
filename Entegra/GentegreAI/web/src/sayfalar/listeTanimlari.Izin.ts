import type { ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * İZİN LİSTELERİ (743).
 *
 * İKİ EKRAN, İKİ SORU: "kim ne zaman izinli" (talepler) ve "kimin kaç günü
 * kaldı" (bakiye). İkisini tek listede birleştirmek, izin döneminde İK'nın
 * baktığı sayıyı taleplerin arasına gömerdi.
 *
 * MODÜL KAPISI `ik`: personeli olmayan kurum yok ama modülü kapatan kurum
 * olabilir (izni kâğıtla yürüten küçük işletme).
 */
export const IZIN_LISTELERI: ListeGirdisi[] = [
  {
    kaynak: 'personelIzin', rota: 'personel-izin',
    baslik: 'İzin Talepleri',
    yol: 'İK › İzinler',
    // ÖZEL KART (959, mockup Ekranlar/IK/izin_talep_karti.html): sayfalar/ik/IzinTalepKarti.
    kartYolu: '/personel-izin', kartBaslik: 'İzin Talebi', ozelKart: true,
    aksiyonEkrani: 'personel-izin-liste',
    tarihAlani: 'baslangicTarihi',
    // İLK ÇİP AÇIK OLANLAR: listenin günlük iş kümesi taslak ve onaydaki
    //   talepler. "Onaylı" ile açsaydık yeni talep hiç görünmez ve tam da
    //   ona basılacak "Onaya Gönder" düğmesi erişilemez olurdu.
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Onayda',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Onaylı',     filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      // ÇAKIŞAN İZİN: aynı âmire bağlı başka personel de aynı günlerde
      //   izinliyse ekip boşalır - onaylayanın asıl sorusu budur.
      { ad: 'Çakışan',    filtre: { alan: 'cakisanIzin', op: 'buyuk', deger: 0 } },
      { ad: 'Onay gecikti', filtre: { alan: 'onayGecikmeGun', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'İzinler', ic: '🌴',
    yetkiKodu: 'ik.izin', modul: 'ik', menuSira: 10,
  },
  {
    kaynak: 'izinBakiye', rota: 'izin-bakiye',
    baslik: 'İzin Bakiyeleri',
    yol: 'İK › İzin Bakiyesi',
    aksiyonEkrani: 'izin-bakiye-liste',
    cipler: [
      { ad: 'Kullanılabilir', filtre: { alan: 'kalan', op: 'buyuk', deger: 0 } },
      // İŞE GİRİŞ YOK: hakkı sıfır DEĞİL, bilinmiyor. Bu personelin izni
      //   hiç hesaplanamaz - çip eksik veriyi görünür kılar.
      { ad: 'İşe giriş girilmemiş', filtre: { alan: 'hakYok', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'İzin Bakiyesi', ic: '📊',
    yetkiKodu: 'ik.izin', modul: 'ik', menuSira: 11,
  },
  {
    // AVANS (753): talep → onay → ödeme → mahsup. Listenin asıl sorusu
    //   "ne kadarı geri geldi" - kesilen/kalan ve geciken taksit sütunları
    //   olmadan ödenmiş avans izlenemez.
    kaynak: 'personelAvans', rota: 'personel-avans',
    baslik: 'Personel Avansları',
    yol: 'İK › Avanslar',
    // ÖZEL KART (960, mockup Ekranlar/IK/avans_karti.html): sayfalar/ik/AvansKarti.
    kartYolu: '/personel-avans', kartBaslik: 'Personel Avansı', ozelKart: true,
    aksiyonEkrani: 'personel-avans-liste',
    tarihAlani: 'talepTarihi',
    cipler: [
      { ad: 'Açık',     filtre: { alan: 'durum', op: 'kucukEsit', deger: 2 } },
      { ad: 'Onayda',   filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Ödenecek', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Mahsupta', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      // GECİKEN KESİNTİ: dönemi geçmiş ama kesilmemiş mahsup unutulmuştur;
      //   personel ayrılırsa tahsil edilemez.
      { ad: 'Kesinti gecikti', filtre: { alan: 'gecikenTaksit', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'Avanslar', ic: '💸',
    yetkiKodu: 'ik.avans', modul: 'ik', menuSira: 14,
  },
  {
    // MASRAF BEYANI (764): cepten yapılan iş harcamasının geri ödeme talebi.
    //   Listenin asıl sorusu "ne kadar ve kaç belge" - tutar tek başına
    //   beyanı anlatmaz; 3.000 TL / 1 belge ile 3.000 TL / 12 belge farklı
    //   şeylerdir. ÖDEME BU LİSTEDE YOK: zincir onayla biter.
    kaynak: 'personelMasraf', rota: 'personel-masraf',
    baslik: 'Masraf Beyanları',
    yol: 'İK › Masraf Beyanları',
    // ÖZEL KART (961, mockup Ekranlar/IK/masraf_karti.html): sayfalar/ik/MasrafKarti.
    kartYolu: '/personel-masraf', kartBaslik: 'Masraf Beyanı', ozelKart: true,
    aksiyonEkrani: 'personel-masraf-liste',
    tarihAlani: 'beyanTarihi',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Taslak',     filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Onayda',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Onaylandı',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Reddedildi', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'Masraf Beyanları', ic: '🧾',
    yetkiKodu: 'ik.masraf', modul: 'ik', menuSira: 15,
  },
  {
    // BELGE TALEBİ (765): çalışma/maaş/vize yazısı. Asıl iş onay değil
    //   HAZIRLAMAK - ilk çip "Hazırlanacak", çünkü İK'nın ekranı açma
    //   sebebi odur. Bekleme günü teslime kadar işler.
    kaynak: 'personelBelgeTalep', rota: 'personel-belge-talep',
    baslik: 'Belge Talepleri',
    yol: 'İK › Belge Talepleri',
    // ÖZEL KART (962, mockup Ekranlar/IK/belge_talep_karti.html): sayfalar/ik/BelgeTalepKarti.
    kartYolu: '/personel-belge-talep', kartBaslik: 'Belge Talebi', ozelKart: true,
    aksiyonEkrani: 'personel-belge-talep-liste',
    tarihAlani: 'talepTarihi',
    cipler: [
      { ad: 'Hazırlanacak', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Onayda',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Hazırlandı',   filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Teslim edildi', filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Reddedildi',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'Belge Talepleri', ic: '📄',
    yetkiKodu: 'ik.belge_talep', modul: 'ik', menuSira: 16,
  },
  {
    // RESMÎ TATİL (749): iş günü hesabının dayandığı takvim. İK
    //   altında, çünkü izin gününü de vardiyayı da bu liste belirler.
    kaynak: 'resmiTatil', rota: 'resmi-tatil',
    baslik: 'Resmî Tatiller',
    yol: 'İK › Resmî Tatiller',
    kartYolu: '/resmi-tatil', kartBaslik: 'Resmî Tatil',
    aksiyonEkrani: 'resmi-tatil-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Aktif',      filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      // DİNÎ BAYRAMLAR elle girilir; çip "bu yıl girilmiş mi" sorusunu
      //   tek bakışta yanıtlar - girilmemişse iş günü hesabı eksik kalır.
      { ad: 'Dinî',       filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      // DOĞRULANMADI: dinî bayram tohumu takvim hesabıdır, Diyanet ilanı
      //   değil. Bu çip "hangi tarihler hâlâ kontrol bekliyor" sorusunu
      //   yanıtlar - bayram yaklaşınca bakılacak tek yer burası.
      { ad: 'Doğrulanmadı', filtre: { alan: 'dogrulandi', op: 'esit', deger: 0 } },
      // YEREL: yalnız bir şubeyi bağlayan tatil (kurtuluş günü).
      { ad: 'Yerel',      filtre: { alan: 'yerel', op: 'esit', deger: 1 } },
      { ad: 'Yarım gün',  filtre: { alan: 'yarimGun', op: 'esit', deger: 1 } },
      { ad: 'Hafta sonuna denk', filtre: { alan: 'haftaSonu', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAd: 'Resmî Tatiller', ic: '📅',
    yetkiKodu: 'ik.tatil', modul: 'ik', menuSira: 13,
  },
  {
    // HAKEDİŞ AYRI EKRAN ve ayrı yetki: bakiyeyi okumak bir iş, hakkı
    //   değiştirmek başka bir iştir - ek gün vermek kurumun kararıdır.
    kaynak: 'personelIzinHak', rota: 'personel-izin-hak',
    baslik: 'İzin Hakedişleri',
    yol: 'İK › İzin Hakedişi',
    kartYolu: '/personel-izin-hak', kartBaslik: 'İzin Hakedişi',
    aksiyonEkrani: 'personel-izin-hak-liste',
    menuGrup: 'İK', menuAd: 'İzin Hakedişi', ic: '🧮',
    yetkiKodu: 'ik.izin_hak', modul: 'ik', menuSira: 12, menuGizli: true,
  },
];
