import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';
import { AGAC_VARSAYILAN_CIPLER, EMIR_VARSAYILAN_CIPLER, FIS_VARSAYILAN_CIPLER } from './uretim/uretimListeSeviye';

/**
 * Stok, hizmet ve üretim listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const STOK_LISTELERI: ListeGirdisi[] = [
  {
    // Kullanici: "Stok altına Stok Listesi [taşı]" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'stok', baslik: 'Stok Listesi', yol: 'Stok › Stok Karti', kartYolu: '/stok',
    aksiyonEkrani: 'stok-liste', cipler: DURUM_CIPLERI,
    // Kategori KOD'un SOLUNDA (kullanici) - hizmet listesiyle ayni duzen.
    // Kisa Ad, Ad'in SOLUNDA (552 - hizmet listesiyle ayni duzen).
    // Stok Adı Kısa Ad'ın SOLUNDA (kullanıcı 02.11.2026: "kısa ad ile stok adı yer değiş").
    kolonSirasi: ['kategori', 'kod', 'ad', 'kisaAd', 'kalan', 'anaBirim', 'durum'],
    // Ciplerin sagina STOK kategori agaci (1 = stok, 346).
    kategoriSuzgeci: 1,
    kategoriSuzgecAlani: 'kategoriId',
    // Mockup'ta (stok_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    //   Stok Durumu icin gercek tablo (stok_durum) var ama PK'si (stok_id,depo_id) -
    //   detay tablosu id kolonu varsayar, o yuzden bu da simdilik yer tutucu.
    // 'ÜTS Bilgileri' artik yer tutucu DEGIL - stok_uts (119) detayi olarak geliyor.
    // Sıra stok_karti_v2.html (02.11.2026): ... ÜTS · Ürün Ağacı / BOM · Stok Durumu · Hareketler · Resim / Doküman · Ek Alanlar.
    yerTutucuSekmeler: ['Stok Durumu', 'Hareketler', 'Ürün Ağacı / BOM', 'Resim / Doküman', 'Ek Alanlar'],
    // Ürün Ağacı / BOM Hareketler'in sağında (kullanıcı 02.11.2026).
    // ÜRÜN AĞACI / BOM YALNIZ ERP'DE (kullanıcı 02.11.2026: "sadece erp modundayken Reçete sekmesi görünmelidir";
    //   başlık "Reçete" -> "Ürün Ağacı / BOM" - HBYS'de reçete ilaç reçetesi demek).
    erpSekmeleri: ['Ürün Ağacı / BOM'],
    resimYerTutucu: true,
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Listesi', ic: '📦', yetkiKodu: 'stok.liste',
    menuSira: 10,
  },
  {
    // Hizmetler KASA'dan STOK menusune alindi (kullanici): hizmet de belgede
    //   satilan bir kalem - stokla ayni yerde aranir. Masraf Listesi kasada
    //   kaldi: o satis kalemi degil, gider kalemi.
    // kartYolu + aksiyonEkrani (kullanici): ekle/duzenle deseni - hizmet karti
    //   generic GenForm ile acilir, aksiyonlar hizmet-liste Crud'undan gelir.
    kaynak: 'hizmet', baslik: 'Hizmet Listesi', yol: 'Stok › Hizmet Listesi', kartYolu: '/hizmet',
    aksiyonEkrani: 'hizmet-liste', cipler: DURUM_CIPLERI,
    // Kartta Hatırlat yok (kullanıcı 09.11.2026); başlık kipli şerit + ✎ (KIPLI_SERITLER / KIPLI_GOVDE_KARTLAR).
    kartHatirlatYok: true,
    // Ciplerin sagina KATEGORI AGACI combosu (kullanici): secilen dal alt
    //   agaciyla birlikte suzer.
    kategoriSuzgeci: 2,
    // Kategori KOD'un SOLUNDA (kullanici): listede once "hangi grup", sonra
    //   kod ve ad okunuyor.
    // Hizmet Adı ÖNCE, Kısa Ad SAĞINDA (kullanıcı 25.10.2026: "kısa ad ve Hizmet Adı yer değiştir"; 549'da tersiydi).
    // ESKİ KOD (1222): SKRS eşleme masasında Bakanlık koduna çevrilen hizmet eski koduyla da bulunur.
    kolonSirasi: ['kategoriAdi', 'kod', 'ad', 'kisaAd', 'eskiKodlar', 'standartAdi', 'durum'],
    aramaEkAlanlari: ['eskiKodlar'],
    menuGrup: 'Stok & Hizmet', menuAd: 'Hizmet Listesi', ic: '🛠️', yetkiKodu: 'hizmet.liste',
    menuSira: 20,
  },
  {
    // SKRS EŞLEME MASASI (1222, mockup Ekranlar/Aktarim/skrs_esleme_masasi.html; kullanıcı 01.11.2026: "eski
    //   müşterilerde gelişigüzel hizmet listeleri.. bakanlığın (SKRS) standardına oturtmak istiyorum"). Satır = aktarılmış
    //   eski hizmet; sağda Bakanlık (SUT) adayları ve karar, araç çubuğunda toplu onay / Uygula. Kartı yok.
    //   Yetki: hizmet kartını değiştirebilen (kullanıcı kararı) - menü hizmet kodunun Gör'ü.
    kaynak: 'aktarim-esleme-hizmet', rota: 'skrs-esleme',
    baslik: 'SKRS Eşleme Masası', yol: 'Stok & Hizmet › SKRS Eşleme Masası',
    // Çip sırası EslemeSeridi kutularıyla aynı (1 bekleyen · 3 onaylı · 4 aday yok · 5 kuruma özel · 6 uygulanan
    //   · 7 yön ailesi).
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Bekleyen', filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 0 }, { alan: 'uygulandi', op: 'esit', deger: 0 }] } },
      { ad: '⚠ Bakılmalı', filtre: { alan: 'guvenKod', op: 'buyuk', deger: 1 } },
      { ad: 'Onaylı', filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 1 }, { alan: 'uygulandi', op: 'esit', deger: 0 }] } },
      { ad: 'Aday yok', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Kuruma özel', filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 2 }, { alan: 'uygulandi', op: 'esit', deger: 0 }] } },
      { ad: 'Uygulanan', filtre: { alan: 'uygulandi', op: 'esit', deger: 1 } },
      { ad: 'Yön ailesi', filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 4 }, { alan: 'uygulandi', op: 'esit', deger: 0 }] } },
      { ad: 'RAD', filtre: { alan: 'tur', op: 'esit', deger: 'RAD' }, ayracOnce: true },
      { ad: 'LAB', filtre: { alan: 'tur', op: 'esit', deger: 'LAB' } },
      { ad: 'Diğer', filtre: { alan: 'tur', op: 'esit', deger: 'DIGER' } },
    ],
    gizliKolonlar: ['durum', 'uygulandi', 'guvenKod', 'modalite', 'kayitId', 'notlar', 'adayKod'],
    kolonSirasi: ['tur', 'eskiKod', 'eskiAd', 'kullanim', 'adayAd', 'adayPuan', 'dikkat', 'aile', 'durumAdi', 'secilenKod', 'secilenAd'],
    urunModu: 2,
    menuGrup: 'Stok & Hizmet', menuAd: 'SKRS Eşleme Masası', ic: '🧭', yetkiKodu: 'hizmet',
    menuSira: 25,
  },
  // SKRS EŞLEME MASASI - BÖLÜM / BRANŞ (1224): masanın diğer sekmeleri (menüde ayrı satır yok; masanın üstündeki
  //   sekme şeridinden açılır). Eski POLIKLINIK -> SKRS kodlu bölüm, eski UZMANLIK -> SKRS branş.
  ...(['bolum', 'brans'] as const).map(l => ({
    kaynak: `aktarim-esleme-${l}`, rota: `skrs-esleme-${l}`,
    baslik: 'SKRS Eşleme Masası', yol: `Stok & Hizmet › SKRS Eşleme Masası › ${l === 'bolum' ? 'Bölüm' : 'Branş'}`,
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Bekleyen', filtre: { op: 'and' as const, kosullar: [{ alan: 'durum', op: 'esit' as const, deger: 0 }, { alan: 'uygulandi', op: 'esit' as const, deger: 0 }] } },
      { ad: '⚠ Bakılmalı', filtre: { alan: 'guvenKod', op: 'buyuk' as const, deger: 1 } },
      { ad: 'Onaylı', filtre: { op: 'and' as const, kosullar: [{ alan: 'durum', op: 'esit' as const, deger: 1 }, { alan: 'uygulandi', op: 'esit' as const, deger: 0 }] } },
      { ad: 'Aday yok', filtre: { alan: 'durum', op: 'esit' as const, deger: 3 } },
      { ad: 'Yok sayılan', filtre: { op: 'and' as const, kosullar: [{ alan: 'durum', op: 'esit' as const, deger: 2 }, { alan: 'uygulandi', op: 'esit' as const, deger: 0 }] } },
      { ad: 'Uygulanan', filtre: { alan: 'uygulandi', op: 'esit' as const, deger: 1 } },
    ],
    gizliKolonlar: ['durum', 'uygulandi', 'guvenKod', 'secilenKod'],
    kolonSirasi: ['eskiAd', 'kullanim', 'adayAd', 'adayPuan', 'notlar', 'durumAdi', 'secilenAd'],
    urunModu: 2, menuGizli: true,
    menuGrup: 'Stok & Hizmet', menuAd: `SKRS Eşleme Masası (${l === 'bolum' ? 'bölüm' : 'branş'})`, ic: '🧭', yetkiKodu: 'hizmet',
  })),
  {
    // SATIS FIYAT LISTELERI (201): liste bir KURALDIR (taban liste x carpan ->
    //   yuvarlama), satirlari o kuralin materyalize halidir. "⟳ Listeyi Üret"
    //   satirlari yeniden yazar; MANUEL girilen satirlar korunur.
    kaynak: 'fiyat-listesi', baslik: 'Fiyat Listeleri', yol: 'Yönetim › Fiyat Listeleri',
    kartYolu: '/fiyat-listesi', aksiyonEkrani: 'fiyat-listesi-liste', cipler: DURUM_CIPLERI,
    // KART (kullanıcı 09.11.2026: "fiyat liste kartında hatırlat butonu kaldır, yerine edit moda geçirmek için
    //   kalem ekle"): Hatırlat yok; başlık kipli şerit (KartKimlikSeridi KIPLI_SERITLER), ✎ başlığın sağ üst köşesinde.
    kartHatirlatYok: true,
    // KOLON SIRASI (kullanici): Liste Adı · Tarife · Başlama · Bitiş · Yön ·
    //   KDV · Durum · Satır · Varsayılan.
    //
    //   Sirayi EKRAN soyluyor cunku kolon tercihi tarayicida saklaniyor ve
    //   SAKLANAN LISTE her seyi belirliyor: katalogda sonradan eklenen bir
    //   kolon (Tarife, 518'de geldi) eski tercihte olmadigi icin hic
    //   gorunmuyordu. `kolonSirasi`nda adi gecen kolon, tercih ne derse desin
    //   en solda ve bu sirada cizilir.
    kolonSirasi: ['ad', 'tarifeTipiAdi', 'baslangic', 'bitis', 'yon',
                  'kdvDahil', 'durumAdi', 'satirSayisi', 'varsayilan'],
    // Menude STOK & HIZMET grubunda, KATEGORILER'in (25) hemen ardinda
    //   (kullanici): fiyat listesi de stok/hizmetin tanim ekrani - Yonetim
    //   altinda ararken bulunmuyordu.
    menuGrup: 'Kurumlar & Sigorta', menuAltGrup: 'Ayarlar', menuAd: 'Fiyat Listeleri',
    ic: '🏷️', yetkiKodu: 'fiyat_listesi.liste', menuSira: 91, erp: { grup: 'Satış' },
  },
  {
    // Liste SATIRLARI ayri ekran: bir listenin binlerce satiri kart icinde
    //   rahat gezilmiyor. Menude gizli - listeden "Satırları Aç" ile gelinir.
    kaynak: 'fiyat-listesi-satir', baslik: 'Fiyat Listesi Satırları',
    yol: 'Yönetim › Fiyat Listesi Satırları', aksiyonEkrani: 'fiyat-listesi-satir-liste',
    urlFiltreAlani: 'listeId', menuGizli: true, yetkiKodu: 'fiyat_listesi.liste', menuAd: 'Fiyat Listesi Satırları', ic: '🏷️',
  },
  {
    // ÜTS askidaki/gelen urunler (223): karsi kurumlarin bize VERDIGI tekil
    //   urunler. "Askıdakileri Getir" ÜTS'den senkronlar; satirdan "Alma
    //   Bildirimi Yap" ile alinir (askı adeti duser).
    kaynak: 'uts-envanter', baslik: 'ÜTS Askıdaki Ürün Listesi',
    yol: 'Stok › ÜTS Askıdaki Ürün Listesi', aksiyonEkrani: 'uts-envanter-liste',
    aramaGorunumGizli: true,
    cipler: [
      { ad: 'Askıda',   filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Alındı',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kayboldu', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    // Uc UTS ekrani "Stok & Hizmet > ÜTS" alt menusunde toplanir (kullanici).
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Gelen / Askıdakiler', ic: '🪝',
    yetkiKodu: 'uts', menuSira: 110,
  },
  {
    // ÜTS bildirim gecmisi (223): gonderilen alma/verme/kullanim bildirimleri,
    //   ham istek/cevap JSON'u Icerik penceresinde.
    kaynak: 'uts-bildirim', baslik: 'ÜTS Bildirimi Listesi',
    yol: 'Stok › ÜTS Bildirimi Listesi', aksiyonEkrani: 'uts-bildirim-liste',
    tarihAlani: 'tarih', icerikAlani: 'cevapJson', icerikBaslik: 'ÜTS Cevabı',
    aramaGorunumGizli: true,
    // "＋ Bildirim" dugmesine asagi acilir menu (kullanici).
    altSecenekler: {
      'uts.bildirim-menu': [
        { kod: 'uts.verme',    ad: '➤ Verme' },
        { kod: 'uts.kullanim', ad: '🧑‍⚕️ Kullanım' },
        { kod: 'uts.uretim',   ad: '🏭 Üretim' },
        { kod: 'uts.ithalat',  ad: '🚢 İthalat' },
        { kod: 'uts.hek',      ad: '⚠️ Kayıp / HEK' },
        { kod: 'uts.imha',     ad: '🔥 İmha / Bertaraf' },
      ],
    },
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Başarılı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Hatalı',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'İptal',    filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Bildirim Listesi', ic: '📡',
    yetkiKodu: 'uts.bildirim', menuSira: 111,
  },
  {
    // ÜTS urun sorgu (223): UNO/LNO/SNO ile ÜTS'den canli tekil urun sorgusu.
    //   Liste degil, kendi sayfasi (App.tsx rotayi tanimlar).
    kaynak: 'uts-sorgu', ozelSayfa: true, baslik: 'ÜTS Ürün Sorgu',
    yol: 'Stok › ÜTS Ürün Sorgu',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Ürün Sorgu', ic: '🔍',
    yetkiKodu: 'uts.sorgu', menuSira: 112,
  },
  {
    // STOKTAN TALEP (tur 105): bir birim depodan mal ISTER. Stok ve cari
    //   ETKILEMEZ - asil hareketi, talep karsilaninca kesilen transfer yapar.
    //   Kart transferin kardesi: para yok, e-Belge yok; teslim eden yerine
    //   TALEP EDEN sorulur.
    kaynak: 'stok-talep', baslik: 'Stoktan Talep Listesi',
    yol: 'Stok › Stoktan Talep', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 105,
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'kapanmaDurum', op: 'esitDegil', deger: 2 } },
      { ad: 'Karşılanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stoktan Talep', ic: '📥', yetkiKodu: 'belge.stok',
    menuSira: 30,
  },
  {
    // DEPOLAR ARASI TRANSFER (tur 20): cari YOK, para YOK - tek satir cikis
    //   deposundan duser, giris deposuna eklenir. Kart BelgeKarti'nin transfer
    //   dalidir (fiyat/KDV/e-Belge sutunlari gizli).
    // kartYolu YOK: kart generic GenForm degil BelgeKarti (modal) - onSatirAc
    //   'stok-transfer' kaynagini da belge kartina yonlendirir.
    kaynak: 'stok-transfer', baslik: 'Stok Transferi Listesi',
    yol: 'Stok › Stok Transfer', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 20,
    cipler: [{ ad: 'Tumu' }],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Transfer', ic: '🔄', yetkiKodu: 'belge.stok.transfer',
    menuSira: 40,
  },
  {
    // GIRIS FISI (3) / CIKIS FISI (4): irsaliye gibi stok oynatan ama CARISIZ
    //   belgeler - fire, sarf, imha, sayim farki. Muhasebe fisi URETIRLER
    //   (kasa_islem_turu.fis_mi=1, F7'de baglanacak). TIPI fisin sebebidir.
    // MENÜ ADI = LİSTE ADI (kullanıcı 09.11.2026): menüde ve sekme başlığında "Giriş Fişi Listesi" /
    //   "Çıkış Fişi Listesi" (tahakkuk listeleriyle aynı kalıp, 1276); EN/DE çevirisi 1279.
    kaynak: 'giris-fis', baslik: 'Giriş Fişi Listesi', yol: 'Stok › Giriş Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 3,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fire',          filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'Sayım Fazlası', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Giriş Fişi Listesi', ic: '📗', yetkiKodu: 'belge.stok.giris',
    menuSira: 50,
  },
  {
    kaynak: 'cikis-fis', baslik: 'Çıkış Fişi Listesi', yol: 'Stok › Çıkış Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 4,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Sarf',         filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'İmha',         filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      { ad: 'Sayım Eksiği', filtre: { alan: 'tipi', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Çıkış Fişi Listesi', ic: '📕', yetkiKodu: 'belge.stok.cikis',
    menuSira: 60,
  },
  {
    // STOK SAYIMI (1169, sade sürüm - mockup Ekranlar/Stok/stok_sayim_karti_ver2.html).
    //   Kart ÖZEL (okutma + sayılan grid'i); farklar Giriş (Sayım Fazlası) / Çıkış
    //   (Sayım Eksiği) fişleriyle kapanır - Delphi'deki elle düzeltmenin otomatik hali.
    kaynak: 'stok-sayim', rota: 'stok-sayim', baslik: 'Stok Sayımları', yol: 'Stok › Stok Sayımları',
    kartYolu: '/stok-sayim', kartBaslik: 'Sayım', ozelKart: true,
    aksiyonEkrani: 'stok-sayim-liste',
    toplam: ['fazlaTutar', 'eksikTutar'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Sayımları', ic: '🧮', yetkiKodu: 'stok.sayim.liste',
    menuSira: 65,
  },
  {
    // STOK İCMALLERİ (1173, mockup Ekranlar/Stok/stok_*_icmali.html): stok değeri, SKT / lot,
    //   sayım farkı - özel sayfa, rakamlar StokIcmalUclari'ndan. Menüde Stok & Hizmet › İcmaller
    //   alt başlığı, Dökümler'den (80) hemen önce (75-79.5).
    kaynak: 'stok-deger-icmali', rota: 'stok-deger-icmali', ozelSayfa: true,
    baslik: 'Stok Değer İcmali', yol: 'Stok & Hizmet › İcmaller › Stok Değer İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 75, menuAd: 'Stok Değer İcmali', ic: '@icmal', yetkiKodu: 'stok.deger_icmali',
  },
  {
    kaynak: 'stok-skt-icmali', rota: 'stok-skt-icmali', ozelSayfa: true,
    baslik: 'SKT / Lot İcmali', yol: 'Stok & Hizmet › İcmaller › SKT / Lot İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 76, menuAd: 'SKT / Lot İcmali', ic: '@icmal', yetkiKodu: 'stok.skt_icmali',
  },
  {
    kaynak: 'stok-sayim-fark-icmali', rota: 'stok-sayim-fark-icmali', ozelSayfa: true,
    baslik: 'Sayım Fark İcmali', yol: 'Stok & Hizmet › İcmaller › Sayım Fark İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 77, menuAd: 'Sayım Fark İcmali', ic: '@icmal', yetkiKodu: 'stok.sayim_fark_icmali',
  },
  {
    // İKİNCİ ÜÇLÜ (1174, mockup Ekranlar/Stok/stok_hareket_icmali.html, stok_olu_stok_icmali.html,
    //   stok_kritik_stok_icmali.html) - rakamlar StokIcmalUclari.Ek'ten.
    kaynak: 'stok-hareket-icmali', rota: 'stok-hareket-icmali', ozelSayfa: true,
    baslik: 'Stok Hareket İcmali', yol: 'Stok & Hizmet › İcmaller › Stok Hareket İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 78, menuAd: 'Stok Hareket İcmali', ic: '@icmal', yetkiKodu: 'stok.hareket_icmali',
  },
  {
    kaynak: 'stok-olu-stok-icmali', rota: 'stok-olu-stok-icmali', ozelSayfa: true,
    baslik: 'Ölü Stok / Devir Hızı İcmali', yol: 'Stok & Hizmet › İcmaller › Ölü Stok / Devir Hızı İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 79, menuAd: 'Ölü Stok / Devir Hızı İcmali', ic: '@icmal', yetkiKodu: 'stok.olu_stok_icmali',
  },
  {
    kaynak: 'stok-kritik-stok-icmali', rota: 'stok-kritik-stok-icmali', ozelSayfa: true,
    baslik: 'Kritik Stok İcmali', yol: 'Stok & Hizmet › İcmaller › Kritik Stok İcmali',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'İcmaller', menuSira: 79.5, menuAd: 'Kritik Stok İcmali', ic: '@icmal', yetkiKodu: 'stok.kritik_stok_icmali',
  },
  {
    // URUN AGACLARI (BOM / recete) - 429.
    //   Ayni kod birden cok SURUMLE listelenir: eski surum silinmez, pasiflesir
    //   (acik emirler kendi surumunde yasar). Bu yuzden varsayilan sirama
    //   kod + surum, cipler de surum degil DURUM uzerinden.
    // "Ürün Ağacı (Reçete) Listesi" (kullanıcı 04.11.2026): KOBİ kullanıcısı "reçete" der, BOM demez.
    kaynak: 'urun-agaci', rota: 'urun-agaci', baslik: 'Ürün Ağacı (Reçete) Listesi',
    yol: 'Üretim › Ürün Ağacı (Reçete) Listesi',
    kartYolu: '/urun-agaci', kartBaslik: 'Ürün Ağacı (Reçete)',
    aksiyonEkrani: 'urun-agaci-liste',
    // Cipler seviyeye göre (1257, uretimListeSeviye): burası standart kümesi, seviye yüklenince değişir.
    cipler: AGAC_VARSAYILAN_CIPLER,
    toplam: ['maliyetMalzeme', 'maliyetIscilik', 'maliyetToplam'],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'Ürün Ağacı (Reçete) Listesi', menuSira: 20,
    ic: '🌳', yetkiKodu: 'uretim.urun_agaci.liste',
    // EKLER / ÇİZİM (mockup urun_agaci_karti_v2.html): teknik çizim, montaj talimatı - stok kartındaki galeri deseni.
    yerTutucuSekmeler: ['Resim / Doküman'], resimYerTutucu: true,
  },
  {
    // URETIM EMIRLERI (429).
    //   "Geciken" cipi SAKLANAN bir alana degil, hesaplanan `gecikti`
    //   kolonuna bakar: gecikme termin ile bugunun farkidir, her gece bir isin
    //   guncellemesi gerekseydi is calismadigi gun liste yalan soylerdi.
    kaynak: 'uretim-emri', rota: 'uretim-emri', baslik: 'Üretim Emiri Listesi',
    yol: 'Üretim › Üretim Emiri Listesi',
    kartYolu: '/uretim-emri', kartBaslik: 'Üretim Emri',
    aksiyonEkrani: 'uretim-emri-liste',
    tarihAlani: 'termin',
    // SEVİYEYE GÖRE (1254, uretim_emri_listesi_v2.html): cipler / kolonlar / araç düğmeleri uretimListeSeviye.ts'ten;
    //   buradaki standart küme seviye yüklenene kadar çizilir. Üst panel (özet kutuları) listeEkranlari PANELLER'de.
    cipler: EMIR_VARSAYILAN_CIPLER,
    toplam: ['adet', 'uretilenAdet', 'gercekToplam'],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'Üretim Emiri Listesi', menuSira: 10,
    ic: '🏭', yetkiKodu: 'uretim.liste',
  },
  {
    // ÜRETİM FİŞLERİ (1253, mockup Ekranlar/Uretim/uretim_fisi.html + uretim_basit.html). Kart ÖZEL
    //   (UretimFisiKarti): mamul bandı, gruplu kalem ızgarası (sarf · gider · fire · çıktı), seviyeye göre sekmeler.
    //   Gerçekleşmiş fiş silinmez: Sil = ters kayıt (kartta). Durum adı seviyeye göre (2: Stoğa işlendi / Karantina).
    kaynak: 'uretim-fisi', rota: 'uretim-fisi', baslik: 'Üretim Fişi Listesi',
    yol: 'Üretim › Üretim Fişi Listesi',
    kartYolu: '/uretim-fisi', kartBaslik: 'Üretim Fişi', ozelKart: true,
    aksiyonEkrani: 'uretim-fisi-liste',
    tarihAlani: 'bas',
    // İlk cip TÜMÜ: kaydedilen fiş hemen listede görünsün (taslak ayrı cip). Seviyeye göre küme (denetimlide
    //   Kalite bekleyen / Serbest / Reddedilen) uretimListeSeviye.ts'ten (1254).
    cipler: FIS_VARSAYILAN_CIPLER,
    toplam: ['miktar', 'toplam'],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'Üretim Fişi Listesi', menuSira: 15,
    ic: '🧾', yetkiKodu: 'uretim.fis.liste',
  },
  {
    // IS MERKEZLERI (429) - saat ucreti iscilik maliyetinin kaynagi.
    kaynak: 'is-merkezi', rota: 'is-merkezi', baslik: 'İş Merkezi Listesi',
    yol: 'Üretim › İş Merkezi Listesi',
    kartYolu: '/is-merkezi', kartBaslik: 'İş Merkezi',
    aksiyonEkrani: 'is-merkezi-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Fason', filtre: { alan: 'fason', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAltGrup: 'Ayarlar', menuAd: 'İş Merkezi Listesi', menuSira: 90,
    ic: '⚙️', yetkiKodu: 'uretim.is_merkezi.liste',
  },
  {
    // ÜRETİM AYARLARI (1262): seviye (basit / standart / denetimli) + "Üretim emri kullan". Kullanıcı 04.11.2026:
    //   Genel Ayarlar › Üretim sekmesi buraya taşındı - modülün ayarı kendi grubunda (kasa / stok / demirbaş deseni).
    kaynak: 'uretim-ayarlar', rota: 'uretim-ayarlar', ozelSayfa: true,
    baslik: 'Üretim Ayarları', yol: 'Üretim › Ayarlar › Üretim Ayarları',
    modul: 'uretim',
    menuGrup: 'Üretim', menuAltGrup: 'Ayarlar', menuAd: 'Üretim Ayarları', menuSira: 95,
    ic: '🛠️', yetkiKodu: 'uretim.ayar',
  },
  {
    // ÜRETİM İCMALİ (1176, mockup Ekranlar/İcmal/uretim_icmali.html).
    kaynak: 'uretim-icmali', rota: 'uretim-icmali', ozelSayfa: true,
    baslik: 'Üretim İcmali', yol: 'Üretim › İcmaller › Üretim İcmali',
    modul: 'uretim',
    menuGrup: 'Üretim', menuAltGrup: 'İcmaller', menuAd: 'Üretim İcmali', menuSira: 80,
    ic: '@icmal', yetkiKodu: 'uretim.icmali',
  },
];
