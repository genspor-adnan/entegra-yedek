import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

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
    kaynak: 'stok', baslik: 'Stoklar', yol: 'Stok › Stok Karti', kartYolu: '/stok',
    aksiyonEkrani: 'stok-liste', cipler: DURUM_CIPLERI,
    // Kategori KOD'un SOLUNDA (kullanici) - hizmet listesiyle ayni duzen.
    // Kisa Ad, Ad'in SOLUNDA (552 - hizmet listesiyle ayni duzen).
    kolonSirasi: ['kategori', 'kod', 'kisaAd', 'ad', 'kalan', 'anaBirim', 'durum'],
    // Ciplerin sagina STOK kategori agaci (1 = stok, 346).
    kategoriSuzgeci: 1,
    kategoriSuzgecAlani: 'kategoriId',
    // Mockup'ta (stok_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    //   Stok Durumu icin gercek tablo (stok_durum) var ama PK'si (stok_id,depo_id) -
    //   detay tablosu id kolonu varsayar, o yuzden bu da simdilik yer tutucu.
    // 'ÜTS Bilgileri' artik yer tutucu DEGIL - stok_uts (119) detayi olarak geliyor.
    yerTutucuSekmeler: ['Reçete', 'Stok Durumu', 'Hareketler', 'Yorum / Medya', 'Ek Alanlar'],
    resimYerTutucu: true,
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Listesi', ic: '📦', yetkiKodu: 'stok',
    menuSira: 10,
  },
  {
    // Hizmetler KASA'dan STOK menusune alindi (kullanici): hizmet de belgede
    //   satilan bir kalem - stokla ayni yerde aranir. Masraf Listesi kasada
    //   kaldi: o satis kalemi degil, gider kalemi.
    // kartYolu + aksiyonEkrani (kullanici): ekle/duzenle deseni - hizmet karti
    //   generic GenForm ile acilir, aksiyonlar hizmet-liste Crud'undan gelir.
    kaynak: 'hizmet', baslik: 'Hizmetler', yol: 'Stok › Hizmetler', kartYolu: '/hizmet',
    aksiyonEkrani: 'hizmet-liste', cipler: DURUM_CIPLERI,
    // Ciplerin sagina KATEGORI AGACI combosu (kullanici): secilen dal alt
    //   agaciyla birlikte suzer.
    kategoriSuzgeci: 2,
    // Kategori KOD'un SOLUNDA (kullanici): listede once "hangi grup", sonra
    //   kod ve ad okunuyor.
    // Kisa Ad, Ad'in SOLUNDA (549, kullanici).
    kolonSirasi: ['kategoriAdi', 'kod', 'kisaAd', 'ad', 'durum'],
    menuGrup: 'Stok & Hizmet', menuAd: 'Hizmet Listesi', ic: '🛠️', yetkiKodu: 'hizmet',
    menuSira: 20,
  },
  {
    // SATIS FIYAT LISTELERI (201): liste bir KURALDIR (taban liste x carpan ->
    //   yuvarlama), satirlari o kuralin materyalize halidir. "⟳ Listeyi Üret"
    //   satirlari yeniden yazar; MANUEL girilen satirlar korunur.
    kaynak: 'fiyat-listesi', baslik: 'Fiyat Listeleri', yol: 'Yönetim › Fiyat Listeleri',
    kartYolu: '/fiyat-listesi', aksiyonEkrani: 'fiyat-listesi-liste', cipler: DURUM_CIPLERI,
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
    menuGrup: 'Stok & Hizmet', menuAd: 'Fiyat Listeleri', ic: '🏷️',
    yetkiKodu: 'fiyat_listesi', menuSira: 27,
  },
  {
    // Liste SATIRLARI ayri ekran: bir listenin binlerce satiri kart icinde
    //   rahat gezilmiyor. Menude gizli - listeden "Satırları Aç" ile gelinir.
    kaynak: 'fiyat-listesi-satir', baslik: 'Fiyat Listesi Satırları',
    yol: 'Yönetim › Fiyat Listesi Satırları', aksiyonEkrani: 'fiyat-listesi-satir-liste',
    urlFiltreAlani: 'listeId', menuGizli: true, yetkiKodu: 'fiyat_listesi',
    menuGrup: 'Yönetim', menuAd: 'Fiyat Listesi Satırları', ic: '🏷️',
  },
  {
    // ÜTS askidaki/gelen urunler (223): karsi kurumlarin bize VERDIGI tekil
    //   urunler. "Askıdakileri Getir" ÜTS'den senkronlar; satirdan "Alma
    //   Bildirimi Yap" ile alinir (askı adeti duser).
    kaynak: 'uts-envanter', baslik: 'ÜTS Askıdaki Ürünler',
    yol: 'Stok › ÜTS Askıdaki Ürünler', aksiyonEkrani: 'uts-envanter-liste',
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
    yetkiKodu: 'uts', menuSira: 70,
  },
  {
    // ÜTS bildirim gecmisi (223): gonderilen alma/verme/kullanim bildirimleri,
    //   ham istek/cevap JSON'u Icerik penceresinde.
    kaynak: 'uts-bildirim', baslik: 'ÜTS Bildirimleri',
    yol: 'Stok › ÜTS Bildirimleri', aksiyonEkrani: 'uts-bildirim-liste',
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
    menuAd: 'Bildirimler', ic: '📡',
    yetkiKodu: 'uts', menuSira: 71,
  },
  {
    // ÜTS urun sorgu (223): UNO/LNO/SNO ile ÜTS'den canli tekil urun sorgusu.
    //   Liste degil, kendi sayfasi (App.tsx rotayi tanimlar).
    kaynak: 'uts-sorgu', ozelSayfa: true, baslik: 'ÜTS Ürün Sorgu',
    yol: 'Stok › ÜTS Ürün Sorgu',
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'ÜTS',
    menuAd: 'Ürün Sorgu', ic: '🔍',
    yetkiKodu: 'uts', menuSira: 72,
  },
  {
    // STOKTAN TALEP (tur 105): bir birim depodan mal ISTER. Stok ve cari
    //   ETKILEMEZ - asil hareketi, talep karsilaninca kesilen transfer yapar.
    //   Kart transferin kardesi: para yok, e-Belge yok; teslim eden yerine
    //   TALEP EDEN sorulur.
    kaynak: 'stok-talep', baslik: 'Stoktan Talepler',
    yol: 'Stok › Stoktan Talep', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 105,
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'kapanmaDurum', op: 'esitDegil', deger: 2 } },
      { ad: 'Karşılanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stoktan Talep', ic: '📥', yetkiKodu: 'belge',
    menuSira: 30,
  },
  {
    // DEPOLAR ARASI TRANSFER (tur 20): cari YOK, para YOK - tek satir cikis
    //   deposundan duser, giris deposuna eklenir. Kart BelgeKarti'nin transfer
    //   dalidir (fiyat/KDV/e-Belge sutunlari gizli).
    // kartYolu YOK: kart generic GenForm degil BelgeKarti (modal) - onSatirAc
    //   'stok-transfer' kaynagini da belge kartina yonlendirir.
    kaynak: 'stok-transfer', baslik: 'Stok Transferleri',
    yol: 'Stok › Stok Transfer', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 20,
    cipler: [{ ad: 'Tumu' }],
    menuGrup: 'Stok & Hizmet', menuAd: 'Stok Transfer', ic: '🔄', yetkiKodu: 'belge',
    menuSira: 40,
  },
  {
    // GIRIS FISI (3) / CIKIS FISI (4): irsaliye gibi stok oynatan ama CARISIZ
    //   belgeler - fire, sarf, imha, sayim farki. Muhasebe fisi URETIRLER
    //   (kasa_islem_turu.fis_mi=1, F7'de baglanacak). TIPI fisin sebebidir.
    kaynak: 'giris-fis', baslik: 'Giriş Fişleri', yol: 'Stok › Giriş Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 3,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fire',          filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'Sayım Fazlası', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Giriş Fişi', ic: '📗', yetkiKodu: 'belge',
    menuSira: 50,
  },
  {
    kaynak: 'cikis-fis', baslik: 'Çıkış Fişleri', yol: 'Stok › Çıkış Fişi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 4,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Sarf',         filtre: { alan: 'tipi', op: 'esit', deger: 1 } },
      { ad: 'İmha',         filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      { ad: 'Sayım Eksiği', filtre: { alan: 'tipi', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'Stok & Hizmet', menuAd: 'Çıkış Fişi', ic: '📕', yetkiKodu: 'belge',
    menuSira: 60,
  },
  {
    // URUN AGACLARI (BOM / recete) - 429.
    //   Ayni kod birden cok SURUMLE listelenir: eski surum silinmez, pasiflesir
    //   (acik emirler kendi surumunde yasar). Bu yuzden varsayilan sirama
    //   kod + surum, cipler de surum degil DURUM uzerinden.
    kaynak: 'urun-agaci', rota: 'urun-agaci', baslik: 'Ürün Ağaçları',
    yol: 'Üretim › Ürün Ağaçları',
    kartYolu: '/urun-agaci', kartBaslik: 'Ürün Ağacı',
    aksiyonEkrani: 'urun-agaci-liste',
    cipler: [
      { ad: 'Aktif',      filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Mamul',      filtre: { alan: 'tur',   op: 'esit', deger: 1 } },
      { ad: 'Yarı Mamul', filtre: { alan: 'tur',   op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    toplam: ['maliyetMalzeme', 'maliyetIscilik', 'maliyetToplam'],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'Ürün Ağaçları', menuSira: 10,
    ic: '🌳', yetkiKodu: 'uretim',
  },
  {
    // URETIM EMIRLERI (429).
    //   "Geciken" cipi SAKLANAN bir alana degil, hesaplanan `gecikti`
    //   kolonuna bakar: gecikme termin ile bugunun farkidir, her gece bir isin
    //   guncellemesi gerekseydi is calismadigi gun liste yalan soylerdi.
    kaynak: 'uretim-emri', rota: 'uretim-emri', baslik: 'Üretim Emirleri',
    yol: 'Üretim › Üretim Emirleri',
    kartYolu: '/uretim-emri', kartBaslik: 'Üretim Emri',
    aksiyonEkrani: 'uretim-emri-liste',
    tarihAlani: 'termin',
    cipler: [
      { ad: 'Taslak',      filtre: { alan: 'durum',   op: 'esit', deger: 1 } },
      { ad: 'Onaylı',      filtre: { alan: 'durum',   op: 'esit', deger: 2 } },
      { ad: 'Üretimde',    filtre: { alan: 'durum',   op: 'esit', deger: 4 } },
      { ad: 'Geciken',     filtre: { alan: 'gecikti', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    toplam: ['adet', 'uretilenAdet', 'gercekToplam'],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'Üretim Emirleri', menuSira: 20,
    ic: '🏭', yetkiKodu: 'uretim',
  },
  {
    // IS MERKEZLERI (429) - saat ucreti iscilik maliyetinin kaynagi.
    kaynak: 'is-merkezi', rota: 'is-merkezi', baslik: 'İş Merkezleri',
    yol: 'Üretim › İş Merkezleri',
    kartYolu: '/is-merkezi', kartBaslik: 'İş Merkezi',
    aksiyonEkrani: 'is-merkezi-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Fason', filtre: { alan: 'fason', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    modul: 'uretim',
    menuGrup: 'Üretim', menuAd: 'İş Merkezleri', menuSira: 30,
    ic: '⚙️', yetkiKodu: 'uretim',
  },
];
