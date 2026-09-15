import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Cari, CRM ve muhasebe listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const CARI_LISTELERI: ListeGirdisi[] = [
  {
    // KURUM ICMALI (289): SGK payi tek tek faturalanmaz, donem sonu toplanip
    //   tek fatura kesilir. Liste donemleri ve durumlarini gosterir.
    kaynak: 'kurum-icmal', rota: 'kurum-icmal', baslik: 'Kurum İcmalleri',
    yol: 'Cari › Kurum İcmalleri', aksiyonEkrani: 'icmal-liste',
    cipler: [
      { ad: 'Hazırlanıyor', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    toplam: ['toplam'],
    // Yalniz HBYS: donem icmali odeyen kurum (SGK/OSS) akisinin parcasi,
    //   ERP kurulumunda karsiligi yok (kullanici).
    urunModu: 2,
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Kurum İcmalleri', ic: '🧾', yetkiKodu: 'kurum',
    menuSira: 20,
  },
  {
    // Kaynak id, API route ve yetki kodu 'cari' KALDI - Musteri Listesi kendi URL'ini
    // ('/cari') korur (eski link/rota kirilmasin); Tedarikci Listesi asagida AYNI
    // kaynagi farkli `rota` ile kullanir. Ekran artik SADECE musteri=1 gosterir
    // (sabitFiltre) - Tedarikci Listesi ayrildigi icin "ikisi birden" gorunumu gerekmiyor.
    kaynak: 'cari', baslik: 'Müşteriler', yol: 'Cari › Müşteriler', kartYolu: '/cari',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi' },
    sabitFiltre: { alan: 'musteri', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: true, tedarikci: false },
    // Mockup'ta (cari_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    // Yalniz ERP (kullanici): HBYS'de musterinin karsiligi HASTA listesidir,
    //   iki liste ayni tarafi iki adla gostermesin.
    urunModu: 1,
    menuGrup: 'Cari & CRM', menuAd: 'Müşteri Listesi', ic: '👥', yetkiKodu: 'cari',
    menuSira: 10,
  },
  {
    // Musteri Listesi'nin BIREBIR kopyasi (kullanici istegi) - ayni kaynak ('cari'),
    // ayni kart, farkli `rota`/kartYolu ('/tedarikci') + ters sabitFiltre.
    kaynak: 'cari', rota: 'tedarikci', baslik: 'Tedarikçiler', yol: 'Cari › Tedarikçiler',
    kartYolu: '/tedarikci',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi' },
    sabitFiltre: { alan: 'tedarikci', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: false, tedarikci: true },
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    menuGrup: 'Stok & Hizmet', menuSira: 70, menuAd: 'Tedarikçiler',
    ic: '🚚', yetkiKodu: 'cari',
  },
  {
    // ANLASMALI KURUMLAR (249, kullanici: "cari altina musteri benzeri Kurumlar
    //   menusu liste ve karti olustur"). Kurum da bir cari - hastanin odemesini
    //   ustlenen taraf; sozlesme suresi/turu ve fiyat politikasi kartinda.
    // Ad "Anlaşmalı Kurumlar" (kullanici): liste yalniz hastanin odemesini
    //   ustlenen ya da tarife anlasmasi olan kurumlari tutar - "Kurumlar"
    //   tek basina her tuzel kisiyi cagristiriyordu.
    kaynak: 'kurum', baslik: 'Anlaşmalı Kurumlar', yol: 'Cari › Anlaşmalı Kurumlar',
    kartYolu: '/kurum',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Kurum Ekstresi',
              tarihAlani: 'islemTarihi' },
    yeniKayitVarsayilanlari: { kurum: true, musteri: true },
    // Yalniz HBYS: anlasmali kurum (odeyen taraf) kavrami HBYS'ye ozgu.
    urunModu: 2,
    // Cari grubunun EN USTU (kullanici): HBYS'de en cok girilen liste.
    //   Sirasiz ogeler 900+ ile diziliyor, 10 hepsinin onune gecer.
    menuSira: 10,
    // Ham tur kolonu API'den geliyor (basvuru "Ödeyen Tipi" suzmesi icin) ama
    //   gridde gorunmesin - turAdi zaten var.
    gizliKolonlar: ['tur'],
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Anlaşmalı Kurumlar', ic: '🏛️', yetkiKodu: 'kurum',
  },
  {
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi; GenGrid zaten duz grid (mockup'taki sag "Secili Kisi" paneli hic
    // yapilmadi, ozel bir "sadelestirme" gerekmedi).
    kaynak: 'kisi', baslik: 'Kisiler', yol: 'Cari › Kisiler', kartYolu: '/kisi',
    aksiyonEkrani: 'kisi-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Cari & CRM', menuAd: 'Kişi Listesi', ic: '🧑', yetkiKodu: 'cari',
    menuSira: 30,
  },
  {
    // DIS DOKTORLAR (305, kullanici): goruntuleme merkezine hasta GONDEREN
    //   kurum disi hekimler. Personel listesiyle ayni tabloyu okur
    //   (taraf + taraf_personel), ayirt eden dis_hekim = 1 - ayri tablo acmak
    //   ad/telefon/adres alanlarini ikinci kez tanimlamak olurdu.
    //   YALNIZ HBYS: ERP kurulumunda sevk eden hekim kavrami yok.
    kaynak: 'dis-hekim', baslik: 'Dış Doktorlar', yol: 'Cari › Dış Doktorlar',
    kartYolu: '/dis-hekim', kartBaslik: 'Dış Doktor',
    aksiyonEkrani: 'dis-hekim-liste', cipler: DURUM_CIPLERI,
    // Tescil no ve e-posta KARTTA kalir, listede yer kaplamasin (kullanici).
    //   BRANS DA listede YOK (kullanici): bolum zaten var, hekimin dali
    //   kartta okunur - iki benzer kolon yan yana satiri uzatiyordu.
    gizliKolonlar: ['brans', 'bransAdi', 'telefonHam', 'tescilNo', 'eposta'],
    // Kolon sirasi TAM verilir: temsilci DURUM'un solunda olsun istendi ve
    //   kaydedilmis kolon tercihi olan kullanicida yeni kolon hic gorunmezdi.
    //   Bölüm AD SOYADIN SAGINDA (kullanici): hekimi once hangi bolume
    //   gonderdigiyle ariyoruz, brans ondan sonra gelir.
    kolonSirasi: ['unvan', 'departmanAdi', 'kurum', 'cepTel',
                  'istemSayisi', 'sonIstem', 'temsilci', 'durum'],
    // GONDERIM GECMISI sekmesi katalog detayi DEGIL (kullanici: "frame kaldir,
    //   readonly gengrid yap"): sekme yer tutucu olarak acilir, icini
    //   KartGrupSekmesi salt okunur GenGrid ile doldurur.
    yerTutucuSekmeler: ['Gönderim Geçmişi'],
    // Hekim Bilgisi ARTIK GENEL SEKMESINDE (kullanici): ayri sekme olarak da
    //   gorunmesi ayni kutuyu iki yere koymak olurdu.
    gizliKartSekmeleri: ['Hekim Bilgisi'],
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Dış Doktorlar', ic: '🩺', yetkiKodu: 'personel',
    menuSira: 50,
    urunModu: 2,
  },
  {
    kaynak: 'proje', baslik: 'Projeler', yol: 'CRM › Projeler', kartYolu: '/proje',
    aksiyonEkrani: 'proje-liste',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    // Grup CRM: musteri iliskileri basligi altinda projeler (kullanici karari).
    menuGrup: 'Cari & CRM', menuAd: 'Projeler', ic: '📁', yetkiKodu: 'proje', menuSira: 60,
  },
  {
    // GOREV / HATIRLATMA / TAKVIM (db/108) - ana sayfa panelini besleyen kayitlar.
    kaynak: 'gorev', baslik: 'Görevler', yol: 'CRM › Görevler', kartYolu: '/gorev',
    aksiyonEkrani: 'gorev-liste',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Cari & CRM', menuAd: 'Görevler', ic: '✅', yetkiKodu: 'gorev', menuSira: 70,
  },
  {
    // SATIS FIRSATI (db/121, mockup firsat_karti/firsat_listesi.html) - teklif
    //   ONCESI surec. Cipler huninin durumu: acik firsatlar, kazanilan, kaybedilen.
    kaynak: 'firsat', baslik: 'Satış Fırsatları', yol: 'CRM › Satış Fırsatları',
    kartYolu: '/firsat', aksiyonEkrani: 'firsat-liste',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kazanılan',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kaybedilen',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tumu' },
    ],
    toplam: ['tahminiTutar', 'agirlikliTutar'],
    yerTutucuSekmeler: ['Teklifler', 'Yorum / Medya', 'Ek Alanlar'],
    menuGrup: 'Cari & CRM', menuAd: 'Satış Fırsatları', ic: '🎯', yetkiKodu: 'firsat', menuSira: 50,
  },
  {
    // ADAY MÜŞTERİLER (db/122): henuz musteri olmayan firmalar. AYNI taraf
    //   tablosu - anlasma saglaninca kayit tasinmaz, yalniz bayrak degisir
    //   (musteri=1, aday=0) ve Musteri Listesi'nde gorunmeye baslar.
    // Kaynak ve yetki AYRI ('aday'): satici rolu CRM'i gorurken Cari
    //   listelerini gormesin (kullanici).
    kaynak: 'aday', baslik: 'Aday Müşteriler',
    yol: 'CRM › Aday Müşteriler', kartYolu: '/aday', aksiyonEkrani: 'aday-liste',
    sabitFiltre: { alan: 'aday', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { aday: true, musteri: false, tedarikci: false },
    // Bu ekrandaki her kayit ADAY: "Musteri"/"Tedarikci" kolonlari hep bos,
    //   yer kaplamaktan baska ise yaramiyor.
    //   VKN, e-Fatura ve Adres yok: aday henuz faturalanmiyor, adres kartta.
    gizliKolonlar: ['musteri', 'tedarikci', 'vkno', 'efatura', 'adres', 'teklifDurumAdi', 'teklifDurum'],
    // Once SAHIBI ve turu: kimin adayi, hangi kategoride.
    kolonSirasi: ['temsilci', 'kategori', 'unvan', 'telefon', 'eposta', 'ilce', 'il', 'kod', 'durum'],
    cipler: DURUM_CIPLERI,
    // ADAY KARTI SADE (kullanici karari): aday henuz musteri degil - fatura
    //   unvani/vergi dairesi, mali durum ve ek alanlar musteri olunca anlamli.
    //   Kod da gizli: aday icin kod uydurmak gereksiz, kaydedince id atanir.
    //   Musteri/Tedarikci kutulari da yok: aday henuz ikisi de degil, rol
    //   donusumde (Müşteriye Dönüştür) belirlenir.
    //   "Aday" kutusu da gizli: bu ekrandaki her kayit zaten aday, kutu bilgi
    //   vermiyor ama yanlislikla kapatilirsa kayit listeden DUSER.
    //   Cep telefonu ve Web de yok: adayda tek telefon + e-posta yeter,
    //   ayrinti musteri olunca girilir.
    gizliKartAlanlari: ['kod', 'musteri', 'tedarikci', 'aday', 'cepTel', 'epostaWeb'],
    gizliKartSekmeleri: ['Adres / Fatura Bilgisi'],
    //   Temsilci ZORUNLU: sahipsiz aday takipsiz kalir (varsayilan karti acan
    //   kullanici). Musteri kartinda zorunlu DEGIL - eski kayitlarin cogunda bos.
    zorunluKartAlanlari: ['temsilci'],
    yerTutucuSekmeler: ['Yorum / Medya'],
    menuGrup: 'Cari & CRM', menuAd: 'Aday Müşteriler', ic: '🌱', yetkiKodu: 'aday', menuSira: 40,
  },
  {
    // KATEGORILER (270/345): stok VE hizmet ayni agaci kullanir (sinirsiz
    //   derinlik) ama ekran IKI BOLMELI - solda stok, sagda hizmet
    //   kategorileri; "ortak" tur iki tarafta da gorunur (ozelSayfa).
    kaynak: 'kategori', baslik: 'Kategoriler', yol: 'Yönetim › Kategoriler',
    ozelSayfa: true,
    // Menude STOK & HIZMET grubunda, Hizmet Listesi'nin (20) hemen ardinda
    //   (kullanici): kategori bu iki listenin siniflandirmasi - Yonetim
    //   altinda ararken kimse bulamiyordu.
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'Ayarlar', menuAd: 'Kategoriler', ic: '🌳', yetkiKodu: 'stok',
    menuSira: 200,
  },
  {
    kaynak: 'hesap-plani', baslik: 'Hesap Planı', yol: 'Yonetim › Hesap Plani',
    kartYolu: '/hesap-plani',
    cipler: [
      { ad: 'Çalışan', filtre: { alan: 'calisirMi', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Muhasebe', menuAltGrup: 'Ayarlar', menuAd: 'Hesap Planı', ic: '📒', yetkiKodu: 'hesap_plani',
    menuSira: 90,
  },
  {
    // Muhasebe fisleri: kasa islemi/belge kesinlestikce OTOMATIK uretilir; buradan
    //   yalniz izlenir (elle fis girisi F4/F7 kapsaminda degil).
    kaynak: 'muhasebe-fis', baslik: 'Muhasebe Fişleri', yol: 'Yonetim › Muhasebe Fisleri',
    aksiyonEkrani: 'fis-liste', toplam: ['toplamBorc', 'toplamAlacak'],
    cipler: [
      { ad: 'Kayıtlı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Muhasebe', menuAd: 'Muhasebe Fişleri', ic: '📕', yetkiKodu: 'muhasebe_fis',
    menuSira: 10,
  },
  {
    kaynak: 'muhasebe-fis-satir', baslik: 'Fiş Satırları', yol: 'Yonetim › Fis Satirlari',
    // Belgeden "Muhasebe Fişini Aç" bu ekrana fisId ile gelir.
    urlFiltreAlani: 'fisId',
    toplam: ['borc', 'alacak'], menuAd: 'Fiş Satırları', menuGizli: true, ic: '📗', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'masraf-merkezi', baslik: 'Masraf Merkezleri', yol: 'Yonetim › Masraf Merkezleri',
    kartYolu: '/masraf-merkezi', cipler: DURUM_CIPLERI,
    menuGrup: 'Muhasebe', menuAltGrup: 'Ayarlar', menuAd: 'Masraf Merkezleri', ic: '🏷️', yetkiKodu: 'masraf_merkezi',
    menuSira: 91,
  },
  {
    // Islem turu katalogu: kasa hareketlerinin ekstre/fis davranisini VERI olarak
    //   tasir (bkz. 073). Salt gorunum - duzenleme yonetici isi, kart yok.
    kaynak: 'kasa-islem-turu', baslik: 'İşlem Türleri', yol: 'Yonetim › Islem Turleri',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuAltGrup: 'Ayarlar', menuAd: 'İşlem Türleri', ic: '⚙️', yetkiKodu: 'kasa_islem_turu',
    menuSira: 93,
  },
  {
    // KAMPANYALAR (268, kullanici: "ayarlara liste ve kart olarak ekle"):
    //   fiyat listesi uzerine isleyen indirim kurallari; kurum sozlesmesinde
    //   secilir.
    kaynak: 'kampanya', baslik: 'Kampanyalar', yol: 'Stok & Hizmet › Kampanyalar',
    kartYolu: '/kampanya', aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Menude FIYAT LISTELERININ (27) hemen ardinda (kullanici): kampanya
    //   fiyat listesi uzerine isleyen bir kural - ikisi yan yana okunur,
    //   Yonetim altinda ararken bulunmuyordu.
    // Kampanya fiyat listesi UZERINE isleyen bir kural: hemen arkasinda durur.
    menuGrup: 'Kurumlar & Sigorta', menuAltGrup: 'Ayarlar', menuAd: 'Kampanyalar',
    ic: '🏷️', yetkiKodu: 'fiyat_listesi', menuSira: 92,
  },
  {
    // DEPARTMANLAR (251): personel departmani ve randevu bolumu AYNI tablo -
    //   "Randevu Bölümü" isaretli olanlar randevu kartinin Bölüm listesinde.
    // 255: iki bolmeli ozel ekran (solda departman, sagda gorev) - duz liste
    //   degil; kullanici "Departman listesi ekranini 2'ye bol" dedi.
    kaynak: 'departman', baslik: 'Bölüm / Görev', yol: 'Yönetim › Bölüm / Görev',
    ozelSayfa: true,
    menuGrup: 'İK & Prim', menuSira: 20, menuAd: 'Bölüm / Görev', ic: '🏢', yetkiKodu: 'personel',
  },
];
