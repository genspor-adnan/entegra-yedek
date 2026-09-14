import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * İK, doküman ve yönetim listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const YONETIM_LISTELERI: ListeGirdisi[] = [
  {
    // Kullanici: "İK altına Personel Listesi taşı" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'personel', baslik: 'Personel', yol: 'IK › Personel', kartYolu: '/personel',
    aksiyonEkrani: 'personel-liste', cipler: DURUM_CIPLERI,
    // Ham bolum id API'den geliyor (basvuruda personel -> bolum doldurmak icin)
    //   ama gridde gorunmesin: orada departmanAdi var.
    gizliKolonlar: ['departmanId', 'rolId'],
    // Serit suzgecleri (kullanici: "aktif/pasif/durum saginda Bolum agac combo
    //   ve Rol combo"): ikisi de cip ve arama ile AND'lenir.
    bolumSuzgeci: true, rolSuzgeci: true,
    menuGrup: 'İK', menuAd: 'Personel Listesi', ic: '🧑‍🤝‍🧑', yetkiKodu: 'personel', menuSira: 10,
  },
  // PRIM (kullanici): ana menude kendi basina grup degil, IK'nin ALTINDA
  //   ve Personel Listesi'nden SONRA. menuSira 20/30/40 personelin 10'unun
  //   ardina dizer; grubun menudeki yeri IK'nin ilk ogesinden (personel) gelir.
  {
    // PRİM PLANLARI (324): kampanyanın prim karşılığı - kapsam + oran
    //   satırları. Satırda hedef, BELGE TÜRÜ ve PAY birlikte kriter.
    kaynak: 'prim-plani', rota: 'prim-plani',
    baslik: 'Prim Planları', yol: 'Prim › Planlar',
    kartYolu: '/prim-plani', kartBaslik: 'Prim Planı',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    gizliKolonlar: ['baz', 'hekimTipi', 'aciklama'],
    menuGrup: 'İK', menuAltGrup: 'Prim', menuAd: 'Prim Planları', ic: '🎯',
    yetkiKodu: 'prim', menuSira: 20, urunModu: 2,
  },
  {
    // HAKEDİŞ SATIRLARI (324): "hangi tahsilattan, hangi kaleme, hangi rolle".
    //   Prim tahsil edildikçe doğduğu için satırın tarihi TAHSİLAT tarihidir.
    kaynak: 'hakedis-satir', rota: 'hakedis-satir',
    baslik: 'Hakediş Satırları', yol: 'Prim › Hakediş Satırları',
    aksiyonEkrani: 'hakedis-liste',
    kartYolu: undefined,
    // Kapatılmış dönemin satırlarına başlıktan geçilir: /hakedis-satir?hakedisId=7
    urlFiltreAlani: 'hakedisId',
    tarihAlani: 'tarih',
    // Acilista bulunulan AY (kullanici): tum zamanlarin satirlari bir arada
    //   anlamsizdi - hakedis zaten ay ay kapanir.
    tarihVarsayilan: 'buAy',
    primSuzgeci: true,
    toplam: ['tutar'],
    gizliKolonlar: ['rol', 'pay', 'durum', 'tarafId', 'hakedisId', 'belgeSatirId',
                    'payYuzde'],
    // Durum (330/339): kesin = gelir belgesine (tahakkuk/fiş/fatura) dönüşmüş;
    //   onaylı = kilitli; ödendi = hakedişi ödenmiş. "Taslak" (durum 1) ÇİPİ
    //   YOK: 339'dan beri gelir belgesi olmadan prim satırı hiç üretilmiyor.
    cipler: [
      { ad: 'Kesin',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Onaylı', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Ödendi', filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      // ROL ISARETI (363): kisinin BUGUN o rolde isareti yoksa satir burada
      //   toplanir - isaret kaldirilmis ya da yanlis role prim dogmus demektir.
      { ad: 'İşaret yok', filtre: { alan: 'rolIsaretli', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAltGrup: 'Prim', menuAd: 'Hakediş Satırları', ic: '🧾',
    yetkiKodu: 'prim', menuSira: 30, urunModu: 2,
  },
  {
    // HAKEDİŞLER (324): kapatılmış dönemler. Kapanan satır DONDURULUR -
    //   sonradan çıkan fark sonraki döneme düzeltme olarak girer.
    kaynak: 'hakedis', rota: 'hakedis',
    baslik: 'Hakedişler', yol: 'Prim › Hakedişler',
    aksiyonEkrani: 'hakedis-donem',
    tarihAlani: 'donemBitis',
    toplam: ['toplam'],
    gizliKolonlar: ['durum', 'tarafId', 'kasaIslemId', 'aciklama', 'eklemeTarihi'],
    cipler: [
      { ad: 'Kesinleşmiş', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Ödendi',      filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'İK', menuAltGrup: 'Prim', menuAd: 'Hakedişler', ic: '💰',
    yetkiKodu: 'prim', menuSira: 40, urunModu: 2,
  },
  {
    // DEMIRBAS (216, Ekranlar/demirbas_listesi.html) - ana menude IK'nin
    //   ALTINDA TEK BASINA (kullanici; grupsuz duz oge). Iki modda ORTAK.
    kaynak: 'demirbas', baslik: 'Demirbaş', yol: 'Demirbaş',
    kartYolu: '/demirbas', aksiyonEkrani: 'demirbas-liste', cipler: DURUM_CIPLERI,
    yerTutucuSekmeler: ['Zimmet Geçmişi', 'Bakım / Servis', 'Amortisman'],
    menuAd: 'Demirbaş', ic: '🖥️', yetkiKodu: 'demirbas',
  },
  {
    // DOKUMAN ANA MENUSU (419) - kullanici: "ana menulerde Demirbastan
    //   sonraya tasi". Grup sirasi TANIM DIZISINDEKI ilk ogeden geldigi icin
    //   konum burada belirlenir; asagi/yukari tasimak menuyu degistirir.
    // DOKUMAN LISTESI - KAYNAK USTU gorunum. Kart galerileri ayni
    //   tabloyu gormeye devam eder; burasi klasor/tur/surum/durum ile kurum
    //   genelinde bakilan liste.
    kaynak: 'dokuman', rota: 'dokuman', baslik: 'Dokümanlar',
    yol: 'Doküman › Dokümanlar',
    // Cift tiklama kartı acar (kullanici). Kart YENI KAYIT ACMAZ: dokuman bir
    //   DOSYADIR, once icerik yuklenir ve kaynak o anda belirlenir.
    kartYolu: '/dokuman', kartBaslik: 'Doküman',
    aksiyonEkrani: 'dokuman-liste',
    tarihAlani: 'eklemeTarihi',
    // CIP SERIDI MOCKUPTAN: Aktif · Taslak · Onay bekliyor · Arşiv ·
    //   Paylaşılmış · Tümü ("Süresi dolacak" sunucu tarafi gorece tarih
    //   suzgeci ister - cip sabit deger tasiyor, o yuzden burada yok).
    cipler: [
      { ad: 'Aktif',         filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Taslak',        filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Onay bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Arşiv',         filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Paylaşılmış',   filtre: { alan: 'paylasimSayisi', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    // ORTAK MOD (kullanici): urunModu VERILMEZ - dokuman yonetimi hem ERP
    //   hem HBYS'de ayni; moda baglamak, ayni tabloyu bir urunde gorunmez
    //   kilardi.
    menuGrup: 'Doküman', menuAd: 'Dokümanlar', ic: '🗄️', yetkiKodu: 'dokuman',
  },
  {
    // DOKUMAN ONAY KUYRUGU (419) - satir = ADIM, dokuman degil: ayni dokuman
    //   iki adimda iki farkli kisiyi bekliyor olabilir.
    kaynak: 'dokuman-onay', rota: 'dokuman-onay', baslik: 'Doküman Onay Kuyruğu',
    yol: 'Doküman › Onay Kuyruğu',
    aksiyonEkrani: 'dokuman-onay-liste',
    tarihAlani: 'baslama',
    menuGrup: 'Doküman', menuAd: 'Onay Kuyruğu', ic: '✅', yetkiKodu: 'dokuman.onayla',
  },
  {
    // DOKUMAN KATEGORILERI (419/431) - agac yapili; surumlu mu, hangi akis,
    //   hangi gizlilik. Stok/hizmet kategorisiyle ayni desen.
    kaynak: 'dokuman-kategori', rota: 'dokuman-kategori',
    baslik: 'Doküman Kategorileri', yol: 'Doküman › Ayarlar › Kategoriler',
    kartYolu: '/dokuman-kategori', kartBaslik: 'Doküman Kategorisi',
    aksiyonEkrani: 'dokuman-kategori-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Doküman', menuAltGrup: 'Ayarlar',
    menuAd: 'Kategoriler', ic: '🏷️', yetkiKodu: 'dokuman',
  },
  {
    // DOKUMAN KLASORLERI (419) - kurumsal agac; kaynak klasorleri SANAL
    //   (kaynak+kaynak_id'den turer, klasor kaydi gerekmez).
    kaynak: 'dokuman-klasor', rota: 'dokuman-klasor', baslik: 'Doküman Klasörleri',
    yol: 'Doküman › Ayarlar › Klasörler',
    kartYolu: '/dokuman-klasor', kartBaslik: 'Doküman Klasörü',
    aksiyonEkrani: 'dokuman-klasor-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Doküman', menuAltGrup: 'Ayarlar',
    menuAd: 'Klasörler', ic: '🗂️', yetkiKodu: 'dokuman',
  },
  {
    // Kullanici: "e-Belge'yi de bir Yönetim altına".
    kaynak: 'e-belge', baslik: 'e-Belge Kuyrugu', yol: 'e-Belge › Kuyruk',
    // Kullanici: "e-Belge menusunu Satis ana menu altinda en sona tasi" -
    //   gonderilen belgelerin kuyrugu satis akisinin devami.
    menuGrup: 'Satış', menuAd: 'e-Belge', ic: '📨', yetkiKodu: 'e_belge',
    menuSira: 999,
  },
  {
    // Kullanici: "Yönetim altına Roller ve İşlem Günlüğü al".
    kaynak: 'islem-log', baslik: 'Islem Gunlugu', yol: 'Yonetim › Islem Gunlugu',
    icerikAlani: 'bilgi', icerikBaslik: 'Log İçeriği',
    // Islem tipi cipleri + tarih araligi (kullanici). Filtre ham kod
    //   kolonuyla (islemTipiKod) - gorunen "İşlem" SQL case metni.
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Ekleme',     filtre: { alan: 'islemTipiKod', op: 'esit', deger: 1 } },
      { ad: 'Değişiklik', filtre: { alan: 'islemTipiKod', op: 'esit', deger: 2 } },
      { ad: 'Silme',      filtre: { alan: 'islemTipiKod', op: 'esit', deger: 0 } },
    ],
    tarihAlani: 'tarih',
    menuGrup: 'Yönetim', menuAd: 'İşlem Günlüğü', ic: '📋', yetkiKodu: 'islem_log',
  },
  {
    // GIRIS KAYITLARI (674, kullanici: "login bilgileri de log da tutulsun").
    //   Kayit zaten tutuluyordu (giris_denemesi); bu ekran onu OKUNUR yapar.
    //   Basarisiz denemeler de listelenir - ayni koda arka arkaya gelen
    //   "parola hatali" satirlari deneme-yanilma, ayni IP'den farkli kodlar
    //   tarama demektir; yalniz basarililari gostermek bakilmasi gereken tek
    //   seyi gizlerdi.
    kaynak: 'giris-log', baslik: 'Giriş Kayıtları',
    yol: 'Yönetim › Giriş Kayıtları',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Başarılı',  filtre: { alan: 'basarili', op: 'esit', deger: 1 } },
      { ad: 'Başarısız', filtre: { alan: 'basarili', op: 'esit', deger: 0 } },
    ],
    gizliKolonlar: ['kullaniciId'],
    menuGrup: 'Yönetim', menuAd: 'Giriş Kayıtları', ic: '🔑', yetkiKodu: 'islem_log',
  },
  {
    // ONAM METINLERI (398, Faz 0): metin + surum. Teletip, genetik, girisimsel
    //   islem ve KVKK aydinlatmasi ayni tablodan beslenir - her modul kendi
    //   onam kopyasini yazmasin diye ortak platformda.
    kaynak: 'onam-metni', baslik: 'Onam Metinleri', yol: 'Yonetim › Onam Metinleri',
    kartYolu: '/onam-metni', cipler: DURUM_CIPLERI,
    menuGrup: 'Yönetim', menuAltGrup: 'Ortak Platform',
    menuAd: 'Onam Metinleri', ic: '📜', yetkiKodu: 'onam',
  },
  {
    // VERILEN ONAMLAR (398): salt gorunum - onam kart ekranindan degil, akisin
    //   icinden (hasta kabul, teletip gorusmesi) alinir.
    kaynak: 'onam', baslik: 'Onamlar', yol: 'Yonetim › Onamlar',
    aksiyonEkrani: 'cikti-liste', tarihAlani: 'tarih',
    menuGrup: 'Yönetim', menuAltGrup: 'Ortak Platform',
    menuAd: 'Onam Kayıtları', ic: '✍️', yetkiKodu: 'onam',
  },
  {
    // BILDIRIM SABLONLARI (399): kod SABIT (kodla cagrilir), metin serbest.
    kaynak: 'bildirim-sablon', baslik: 'Bildirim Şablonları',
    yol: 'Yonetim › Bildirim Şablonları', kartYolu: '/bildirim-sablon',
    aksiyonEkrani: 'bildirim-sablon-liste',
    cipler: DURUM_CIPLERI,
    menuGrup: 'Yönetim', menuAltGrup: 'Ortak Platform',
    menuAd: 'Bildirim Şablonları', ic: '💬', yetkiKodu: 'bildirim_sablon',
  },
  {
    // BILDIRIM KUYRUGU (399): "gitti mi" sorusunun TEK yeri. Cipler durum
    //   kolonundan degil kendi kodlarindan - bildirim.durum alti degerli.
    kaynak: 'bildirim', baslik: 'Bildirim Kuyruğu', yol: 'Yonetim › Bildirim Kuyruğu',
    aksiyonEkrani: 'bildirim-liste', tarihAlani: 'planlanan',
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Kuyrukta',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Gönderildi',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Hata',        filtre: { alan: 'durum', op: 'esit', deger: 4 } },
    ],
    menuGrup: 'Yönetim', menuAltGrup: 'Ortak Platform',
    menuAd: 'Bildirim Kuyruğu', ic: '📨', yetkiKodu: 'bildirim',
  },
  {
    // ZAMANLI ISLER (405): TITCK haftalik guncelleme gibi kendiliginden
    //   calisan isler. Kart yalniz ZAMANLAMAYI duzenler - isin kendisi kodda.
    kaynak: 'zamanli-is', baslik: 'Zamanlanmış İşler',
    yol: 'Yonetim › Ortak Platform › Zamanlanmış İşler', kartYolu: '/zamanli-is',
    aksiyonEkrani: 'zamanli-is-liste',
    menuGrup: 'Yönetim', menuAltGrup: 'Ortak Platform',
    menuAd: 'Zamanlanmış İşler', ic: '⏱️', yetkiKodu: 'zamanli_is',
  },
  {
    // KLINIK KATALOGLAR (400): durum + dosyadan yukleme. Liste degil,
    //   ozel sayfa - iki katalog ve iki dosya kutusu.
    kaynak: 'katalog-ayarlar', rota: 'katalog-ayarlar', baslik: 'Klinik Kataloglar',
    yol: 'Muayene › Muayene Ayarları › Klinik Kataloglar', ozelSayfa: true,
    // ICD-10 ve ilac katalogunun DURUM/YUKLEME ekrani: ikisi de Muayene
    //   Ayarlari altinda oldugu icin kurulum ekrani da orada (kullanici).
    menuSira: 96, menuGrup: 'Muayene', menuAltGrup: 'Muayene Ayarları',
    menuAd: 'Klinik Kataloglar', ic: '📚', yetkiKodu: 'katalog', urunModu: 2,
  },
  {
    // ICD-10 (400): senkron doldurur, ekran SALT GORUNUM - elle tani kodu
    //   yazmak katalogu bozar (e-Nabiz ve provizyon ayni kodu bekler).
    kaynak: 'icd', baslik: 'ICD-10 Tanı Kataloğu',
    yol: 'Muayene › Muayene Ayarları › ICD-10 Tanı',
    aksiyonEkrani: 'cikti-liste',
    // AYARLARIN ALTINDA (kullanici): katalog SALT GORUNUM, senkron doldurur -
    //   hekimin gunluk isi degil, kurulum tarafi.
    menuSira: 94, menuGrup: 'Muayene', menuAltGrup: 'Muayene Ayarları',
    menuAd: 'ICD-10 Tanı', ic: '🩺', yetkiKodu: 'katalog', urunModu: 2,
  },
  {
    // ILAC (400): barkod birincil; e-Recete ve sarf bunu okur.
    kaynak: 'ilac', baslik: 'İlaç Kataloğu', yol: 'Muayene › İlaç Kataloğu',
    aksiyonEkrani: 'ilac-liste',
    // MUAYENE ALTINDA, AYARLARIN USTUNDE (kullanici): ilac katalogu recete
    //   yazan hekimin gunluk baktigi liste - ayar degil, calisma ekrani.
    menuSira: 85, menuGrup: 'Muayene',
    // Ikon Receteler ile ayni 💊 idi (kullanici); 📖 de Tibbi Ozet'te kullaniliyor.
    menuAd: 'İlaç Kataloğu', ic: '📕', yetkiKodu: 'katalog', urunModu: 2,
  },
  {
    // Rol'un durum kolonu "durum" degil "aktif" - DURUM_CIPLERI (alan:'durum') buraya
    //   UYMAZ, kullanilmadi (yoksa "Bilinmeyen alan: durum" 400 verirdi).
    kaynak: 'rol', baslik: 'Roller', yol: 'IK › Roller ve Yetkiler', kartYolu: '/rol',
    aksiyonEkrani: 'rol-liste',
    // ROLLER IK ALTINDA, PERSONELDEN SONRA (kullanici). Rol bir YETKI kaydi
    //   olsa da gunluk kullanimda personelin ozelligi gibi okunuyor: "kim ne
    //   yapabilir" sorusu personel listesinin hemen yanindan cevaplaniyor.
    //   menuSira 15: Personel Listesi (10) ile Prim grubunun (20+) arasi.
    menuGrup: 'İK', menuAd: 'Roller', ic: '🛡️', yetkiKodu: 'rol', menuSira: 15,
  },
  {
    // FIRMA / SUBE BILGILERI - mockup: Ekranlar/firma_bilgileri.html.
    //   e-Belgede GONDERICI TARAF buradan okunur (unvan, VKN, vergi dairesi,
    //   adres, gonderici etiketi). Cok subeli firmada fatura hangi subeden
    //   kesildiyse ONUN bilgileri gider.
    //   Duz liste DEGIL (ozelSayfa): ekran tek firmayi anlatir, subeler onun
    //   altinda bir tablodur (165 / FirmaBilgileri.tsx).
    kaynak: 'sube', baslik: 'Firma Bilgileri', yol: 'Yonetim › Firma Bilgileri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAd: 'Firma Bilgileri', ic: '🏢', yetkiKodu: 'sube',
  },
  {
    // KURUM PROFILI (489) - Firma Bilgileri'nin sekmesiydi, kullanici menude
    //   AYRI SATIR istedi: kurulumun kendisini (urun modu, kurum tipi, acik
    //   moduller, kayit/ucretlendirme) belirledigi icin sube kimliginin ic
    //   sekmesi olarak durmasi onu gizliyordu. Yetki kodu 'sube' KALDI -
    //   ekrani goren kitle degismesin.
    kaynak: 'kurum-profili', baslik: 'Kurum Profili', yol: 'Yonetim › Kurum Profili',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAd: 'Kurum Profili', ic: '🏥', yetkiKodu: 'sube',
  },
  {
    // Firma geneli DAVRANIS ayarlari (public.referans). Liste degil (ozelSayfa).
    kaynak: 'genel-ayarlar', baslik: 'Genel Ayarlar', yol: 'Yonetim › Ayarlar › Genel',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Genel', menuSira: 1,
    ic: '⚙️', yetkiKodu: 'ayar',
  },
  {
    // KAYIT KABUL ayarlari (kullanici): Genel / Hasta / Başvuru sekmeleri.
    //   Basvuru sekmesindeki "Tahsilatta POS" ayari POS tahsilatindan sonra
    //   satis fisi kesilip kesilmeyecegini belirler.
    kaynak: 'kayit-kabul-ayarlar', baslik: 'Kayıt Kabul Ayarları',
    yol: 'Yonetim › Modül Ayarları › Kayit Kabul', ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Kayıt Kabul', menuSira: 2,
    ic: '🩺', yetkiKodu: 'ayar', urunModu: 2,
  },
  {
    // Sekmeli AYAR ekrani - liste degil (ozelSayfa): Genel + Depolar. Menude
    //   Yönetim grubunun altinda "Ayarlar" alt basligiyla toplanir.
    kaynak: 'stok-ayarlar', baslik: 'Stok Ayarları', yol: 'Yonetim › Ayarlar › Stok Ayarlari',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Stok Ayarları', menuSira: 3,
    ic: '📦', yetkiKodu: 'stok',
  },
  {
    // Kasa modulu ayarlari (149) - simdilik tek sekme: duzeltme gun siniri.
    kaynak: 'kasa-ayarlar', baslik: 'Kasa Ayarları', yol: 'Yonetim › Ayarlar › Kasa',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Kasa', menuSira: 4,
    ic: '💵', yetkiKodu: 'kasa_islem',
  },
  {
    // Satis belgesi ayarlari: Genel + e-Belge (e-Belge yalniz GIDEN belgede).
    kaynak: 'satis-ayarlar', baslik: 'Satış Belgeleri', yol: 'Yonetim › Ayarlar › Satış Belgeleri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Satış Belgeleri', menuSira: 5,
    ic: '🧾', yetkiKodu: 'belge',
  },
  // İK AYARLARI EKRANI KALDIRILDI (kullanici: "İK Ayarlarinda bolum ve gorevi
  //   kaldir"). Ekranin TEK icerigi `taraf.departman` ve `taraf.gorev` kod
  //   listeleriydi; ikisi de "Yönetim › Bölüm / Görev" ekranindaki GERCEK
  //   tablolarin (departman, personel_gorev) kopyasiydi. Ayni seyi iki yerde
  //   tanimlatmak, hangisinin gecerli oldugunu belirsiz birakiyordu.
  {
    // EXCEL'DEN ICERI ALMA (548) - dort adimli sihirbaz, liste degil.
    //   Menude "Modül Ayarları"nin altinda degil, kendi basligi altinda:
    //   ayar degil VERI ISI - cari/stok/hizmet kartlarini yaziyor.
    kaynak: 'iceri-alma', rota: 'iceri-alma', baslik: "Excel'den İçeri Alma",
    yol: 'Yonetim › Veri Aktarımı › İçeri Alma', ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Veri Aktarımı', menuAd: "Excel'den İçeri Alma",
    menuSira: 1, ic: '⬆', yetkiKodu: 'ayar',
  },
  {
    // Alis belgesi ayarlari: yalniz Genel - alis faturasini GIB'e biz gondermeyiz.
    kaynak: 'alis-ayarlar', baslik: 'Alış Belgeleri', yol: 'Yonetim › Ayarlar › Alış Belgeleri',
    ozelSayfa: true,
    menuGrup: 'Yönetim', menuAltGrup: 'Modül Ayarları', menuAd: 'Alış Belgeleri', menuSira: 6,
    ic: '📥', yetkiKodu: 'belge',
  },
];
