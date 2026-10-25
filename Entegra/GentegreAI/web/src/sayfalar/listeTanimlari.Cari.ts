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
    // KURUM İCMALİ EKRANI (10.10.2026, mockup İcmal/kurum_icmal.html):
    //   dönemin kurum başvuruları, kurum payı, kesinti, icmal/fatura durumu.
    //   İcmal oluşturma / faturalama aşağıdaki listeyle aynı uçlar (289).
    kaynak: 'kurum-icmali', rota: 'kurum-icmali', ozelSayfa: true,
    baslik: 'Kurum İcmali', yol: 'Kurumlar & Sigorta › Kurum İcmali',
    urunModu: 2,
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Kurum İcmali', ic: '@icmal', yetkiKodu: 'kurum.icmal_ozet',
    menuSira: 19,
  },
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
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Kurum İcmalleri', ic: '🧾', yetkiKodu: 'kurum.icmal',
    menuSira: 20,
    // VER2 (kullanıcı 10.10.2026: "ver2 yi kodla"): liste Kurum İcmali
    //   ekranının "İcmaller" sekmesi oldu - menüde tek giriş kalır. Kayıt
    //   yetki kodu (matris) için duruyor; rota açmaz, eski adres App.tsx'te
    //   sekmeye yönlenir.
    menuGizli: true, menuYol: '/kurum-icmali?sekme=icmaller',
  },
  {
    // Kaynak id, API route ve yetki kodu 'cari' KALDI - Musteri Listesi kendi URL'ini
    // ('/cari') korur (eski link/rota kirilmasin); Tedarikci Listesi asagida AYNI
    // kaynagi farkli `rota` ile kullanir. Ekran artik SADECE musteri=1 gosterir
    // (sabitFiltre) - Tedarikci Listesi ayrildigi icin "ikisi birden" gorunumu gerekmiyor.
    kaynak: 'cari', baslik: 'Müşteri Listesi', yol: 'Cari › Müşteri Listesi', kartYolu: '/cari',
    // VER3 (1150, mockup musteri_listesi_ver3.html): durum ciplerinin yaninda
    //   AKILLI CIPLER - her biri sunucuda kolon kosulu. Gosterge seridinin
    //   kutulari bu ciplerin INDEKSINI acar (MusteriGostergesi.CIP) - sira
    //   degisirse orasi da degismeli.
    aksiyonEkrani: 'cari-liste', cipler: [
      ...(DURUM_CIPLERI ?? []),
      { ad: 'Borçlu', filtre: { alan: 'bakiye', op: 'buyuk', deger: 0.005 }, ayracOnce: true },
      { ad: 'Vadesi geçen', filtre: { alan: 'vadesiGecen', op: 'buyuk', deger: 0.005 } },
      { ad: 'Limit aşan', filtre: { alan: 'riskYuzde', op: 'buyuk', deger: 100 } },
      { ad: 'Satış yok 90+ gün', filtre: { op: 'and', kosullar: [
        { alan: 'durum', op: 'esit', deger: 1 }, { alan: 'sonSatisGun', op: 'buyukEsit', deger: 90 }] } },
      { ad: 'Dövizli', filtre: { alan: 'dovizli', op: 'esit', deger: 1 } },
    ],
    // Para kolonlari ERP'nin sorusuna gore (mockup): bakiye (B/A, doviz alti),
    //   vadesi gecen, risk limiti kullanimi, son satistan bu yana gun, 12 ay
    //   egri. Iletisim kolonlari onizleme panelinde - kolon seciciden acilir.
    kolonSirasi: ['kod', 'unvan', 'ilgiliKisi', 'il', 'temsilci', 'bakiye', 'vadesiGecen', 'riskYuzde',
                  'sonSatisGun', 'ciroEgri', 'efatura', 'durum'],
    gizliKolonlar: ['vkno', 'telefon', 'eposta', 'adres', 'ilce', 'musteri', 'tedarikci'],
    toplam: ['bakiye', 'vadesiGecen'],
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi', yeniSekme: true },
    sabitFiltre: { alan: 'musteri', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: true, tedarikci: false },
    // Mockup'ta (cari_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    // EKSTRE SEKMESİ YOK (kullanıcı 23.10.2026): kartın üstündeki "📄 Ekstre" Kasa › Cari Ekstre'yi açar.
    // "Mali Durum" yer tutucusu yerine Finansal sekmesi (kart eklentisi, Ver3).
    // BANKA / IBAN artık gerçek sekme (1153, taraf_banka).
    yerTutucuSekmeler: ['Yorum / Medya', 'Ek Alanlar'],
    // Fiyat listeleri "Satış Koşulları" grubunda ama Satış & Risk sekmesinde çizilir (1152).
    //   Satınalma Koşulları (1162) tedarikçi kartının sekmesi.
    gizliKartSekmeleri: ['Satış Koşulları'], gizliDetaylar: ['satinalmaKosul'],
    // Yalniz ERP (kullanici): HBYS'de musterinin karsiligi HASTA listesidir,
    //   iki liste ayni tarafi iki adla gostermesin.
    urunModu: 1,
    menuGrup: 'Cari & CRM', menuAd: 'Müşteri Listesi', ic: '👥', yetkiKodu: 'cari.liste',
    menuSira: 10,
  },
  {
    // Musteri Listesi'nin BIREBIR kopyasi (kullanici istegi) - ayni kaynak ('cari'),
    // ayni kart, farkli `rota`/kartYolu ('/tedarikci') + ters sabitFiltre.
    kaynak: 'cari', rota: 'tedarikci', baslik: 'Tedarikçi Listesi', yol: 'Cari › Tedarikçi Listesi',
    kartYolu: '/tedarikci',
    // VER3 (1162, mockup tedarikci_listesi_ver3.html): yön ters - bakiye çoğunlukla A (biz borçluyuz).
    //   Akıllı çipler v_cari_ozet'in tedarikçi sütunları; gösterge şeridi İNDEKSLE açar
    //   (MusteriPanelleri.TED_CIP) - sıra değişirse orası da değişmeli.
    aksiyonEkrani: 'cari-liste', cipler: [
      ...(DURUM_CIPLERI ?? []),
      { ad: 'Borçlu olduğumuz', filtre: { alan: 'bakiye', op: 'kucuk', deger: -0.005 }, ayracOnce: true },
      { ad: 'Vadesi geçen ödeme', filtre: { alan: 'vadesiGecenOdeme', op: 'buyuk', deger: 0.005 } },
      { ad: '30 günde ödenecek', filtre: { alan: 'odenecek30', op: 'buyuk', deger: 0.005 } },
      { ad: 'Alım yok 90+ gün', filtre: { op: 'and', kosullar: [
        { alan: 'durum', op: 'esit', deger: 1 }, { alan: 'sonAlisGun', op: 'buyukEsit', deger: 90 }] } },
      { ad: 'Dövizli', filtre: { alan: 'dovizli', op: 'esit', deger: 1 } },
    ],
    kolonSirasi: ['kod', 'unvan', 'ilgiliKisi', 'il', 'temsilci', 'bakiye', 'vadesiGecenOdeme', 'odenecek30',
                  'sonAlisGun', 'alisEgri', 'onayDurumu', 'efatura', 'durum'],
    kolonBasliklari: { temsilci: 'Satınalmacı', bakiye: 'Bakiye (A = borcumuz)' },
    gizliKolonlar: ['vkno', 'telefon', 'eposta', 'adres', 'ilce', 'musteri', 'tedarikci', 'vadesiGecen', 'riskYuzde', 'sonSatisGun', 'ciroEgri'],
    toplam: ['bakiye', 'vadesiGecenOdeme', 'odenecek30'],
    // Cari ekstresi ayni gridde (hesap ekranlarindaki desen): cip seridinde
    //   "📄 Ekstre", secili carinin hareketleri, cipe basinca liste geri gelir.
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Cari Ekstre',
              tarihAlani: 'islemTarihi', yeniSekme: true },
    sabitFiltre: { alan: 'tedarikci', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: false, tedarikci: true },
    // EKSTRE SEKMESİ YOK (kullanıcı 23.10.2026): kartın üstündeki "📄 Ekstre" Kasa › Cari Ekstre'yi açar.
    // "Mali Durum" yer tutucusu yerine Finansal sekmesi (kart eklentisi, Ver3).
    // BANKA / IBAN artık gerçek sekme (1153, taraf_banka).
    yerTutucuSekmeler: ['Yorum / Medya', 'Ek Alanlar'],
    // Tedarikçi kartı (1162): Satış & Risk yerine Satınalma Koşulları (taraf_tedarikci).
    gizliKartSekmeleri: ['Satış Koşulları'], gizliDetaylar: ['satisKosul'],
    menuGrup: 'Stok & Hizmet', menuSira: 70, menuAd: 'Tedarikçi Listesi',
    ic: '🚚', yetkiKodu: 'cari.tedarikci.liste',   // 1003: menü yeri kendi kodu
  },
  {
    // ANLASMALI KURUMLAR (249, kullanici: "cari altina musteri benzeri Kurumlar
    //   menusu liste ve karti olustur"). Kurum da bir cari - hastanin odemesini
    //   ustlenen taraf; sozlesme suresi/turu ve fiyat politikasi kartinda.
    // Ad "Anlaşmalı Kurumlar" (kullanici): liste yalniz hastanin odemesini
    //   ustlenen ya da tarife anlasmasi olan kurumlari tutar - "Kurumlar"
    //   tek basina her tuzel kisiyi cagristiriyordu.
    kaynak: 'kurum', baslik: 'Anlaşmalı Kurum Listesi', yol: 'Cari › Anlaşmalı Kurum Listesi',
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
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Anlaşmalı Kurum Listesi', ic: '🏛️', yetkiKodu: 'kurum.liste',
  },
  {
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi; GenGrid zaten duz grid (mockup'taki sag "Secili Kisi" paneli hic
    // yapilmadi, ozel bir "sadelestirme" gerekmedi).
    kaynak: 'kisi', baslik: 'Kisi Listesi', yol: 'Cari › Kisi Listesi', kartYolu: '/kisi',
    aksiyonEkrani: 'kisi-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Cari & CRM', menuAd: 'Kişi Listesi', ic: '🧑', yetkiKodu: 'cari.kisi.liste',
    menuSira: 30,
  },
  {
    // DIS DOKTORLAR (305, kullanici): goruntuleme merkezine hasta GONDEREN
    //   kurum disi hekimler. Personel listesiyle ayni tabloyu okur
    //   (taraf + taraf_personel), ayirt eden dis_hekim = 1 - ayri tablo acmak
    //   ad/telefon/adres alanlarini ikinci kez tanimlamak olurdu.
    //   YALNIZ HBYS: ERP kurulumunda sevk eden hekim kavrami yok.
    kaynak: 'dis-hekim', baslik: 'Dış Doktor Listesi', yol: 'Cari › Dış Doktor Listesi',
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
    menuGrup: 'Kurumlar & Sigorta', menuAd: 'Dış Doktor Listesi', ic: '🩺', yetkiKodu: 'dis_doktor.liste',
    menuSira: 50,
    urunModu: 2,
  },
  {
    kaynak: 'proje', baslik: 'Proje Listesi', yol: 'CRM › Proje Listesi', kartYolu: '/proje',
    aksiyonEkrani: 'proje-liste',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    // Grup CRM: musteri iliskileri basligi altinda projeler (kullanici karari).
    menuGrup: 'Cari & CRM', menuAd: 'Proje Listesi', ic: '📁', yetkiKodu: 'proje.liste', menuSira: 60,
  },
  {
    // GOREV / HATIRLATMA / TAKVIM (db/108) - ana sayfa panelini besleyen kayitlar.
    kaynak: 'gorev', baslik: 'Görev Listesi', yol: 'CRM › Görev Listesi', kartYolu: '/gorev',
    aksiyonEkrani: 'gorev-liste',
    cipler: [
      { ad: 'Bekleyen',  filtre: { alan: 'durum', op: 'kucukEsit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Cari & CRM', menuAd: 'Görev Listesi', ic: '✅', yetkiKodu: 'gorev.liste', menuSira: 70,
  },
  {
    // SATIS FIRSATI (db/121, mockup firsat_karti/firsat_listesi.html) - teklif
    //   ONCESI surec. Cipler huninin durumu: acik firsatlar, kazanilan, kaybedilen.
    kaynak: 'firsat', baslik: 'Satış Fırsatı Listesi', yol: 'CRM › Satış Fırsatı Listesi',
    kartYolu: '/firsat', aksiyonEkrani: 'firsat-liste',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kazanılan',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Kaybedilen',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tumu' },
    ],
    toplam: ['tahminiTutar', 'agirlikliTutar'],
    yerTutucuSekmeler: ['Teklifler', 'Yorum / Medya', 'Ek Alanlar'],
    menuGrup: 'Cari & CRM', menuAd: 'Satış Fırsatı Listesi', ic: '🎯', yetkiKodu: 'firsat.liste', menuSira: 50,
  },
  {
    // ADAY MÜŞTERİLER (db/122): henuz musteri olmayan firmalar. AYNI taraf
    //   tablosu - anlasma saglaninca kayit tasinmaz, yalniz bayrak degisir
    //   (musteri=1, aday=0) ve Musteri Listesi'nde gorunmeye baslar.
    // Kaynak ve yetki AYRI ('aday'): satici rolu CRM'i gorurken Cari
    //   listelerini gormesin (kullanici).
    kaynak: 'aday', baslik: 'Aday Müşteri Listesi',
    yol: 'CRM › Aday Müşteri Listesi', kartYolu: '/aday', aksiyonEkrani: 'aday-liste',
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
    menuGrup: 'Cari & CRM', menuAd: 'Aday Müşteri Listesi', ic: '🌱', yetkiKodu: 'aday.liste', menuSira: 40,
  },
  {
    // KATEGORILER (270/345): stok VE hizmet ayni agaci kullanir (sinirsiz
    //   derinlik) ama ekran IKI BOLMELI - solda stok, sagda hizmet
    //   kategorileri; "ortak" tur iki tarafta da gorunur (ozelSayfa).
    kaynak: 'kategori', baslik: 'Kategori Listesi', yol: 'Yönetim › Kategori Listesi',
    ozelSayfa: true,
    // Menude STOK & HIZMET grubunda, Hizmet Listesi'nin (20) hemen ardinda
    //   (kullanici): kategori bu iki listenin siniflandirmasi - Yonetim
    //   altinda ararken kimse bulamiyordu.
    menuGrup: 'Stok & Hizmet', menuAltGrup: 'Ayarlar', menuAd: 'Kategori Listesi', ic: '🌳', yetkiKodu: 'stok.kategori',
    menuSira: 200,
  },
  {
    kaynak: 'hesap-plani', baslik: 'Hesap Planı', yol: 'Yonetim › Hesap Plani',
    kartYolu: '/hesap-plani',
    cipler: [
      { ad: 'Çalışan', filtre: { alan: 'calisirMi', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Muhasebe', menuAltGrup: 'Ayarlar', menuAd: 'Hesap Planı', ic: '📒', yetkiKodu: 'hesap_plani.liste',
    menuSira: 90,
  },
  {
    // Muhasebe fisleri: kasa islemi/belge kesinlestikce OTOMATIK uretilir; buradan
    //   yalniz izlenir (elle fis girisi F4/F7 kapsaminda degil).
    kaynak: 'muhasebe-fis', baslik: 'Muhasebe Fişi Listesi', yol: 'Yonetim › Muhasebe Fisleri',
    aksiyonEkrani: 'fis-liste', toplam: ['toplamBorc', 'toplamAlacak'],
    cipler: [
      { ad: 'Kayıtlı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Muhasebe', menuAd: 'Muhasebe Fişi Listesi', ic: '📕', yetkiKodu: 'muhasebe_fis',
    menuSira: 10,
  },
  {
    // YIL SONU / BAŞI DEVRİ (1155, mockup Ekranlar/Muhasebe/yil_sonu_devir.html): beş adımlı
    //   sihirbaz - ön kontrol, değerleme, kapanış, yeni yıl, açılış & kilit.
    kaynak: 'yil-devri', rota: 'yil-devri', ozelSayfa: true,
    baslik: 'Yıl Sonu Devri', yol: 'Muhasebe › Yıl Sonu Devri',
    menuGrup: 'Muhasebe', menuSira: 90, menuAd: 'Yıl Sonu Devri', ic: '🗓️', yetkiKodu: 'muhasebe.yil_devri',
  },
  {
    kaynak: 'muhasebe-fis-satir', baslik: 'Fiş Satırı Listesi', yol: 'Yonetim › Fis Satirlari',
    // Belgeden "Muhasebe Fişini Aç" bu ekrana fisId ile gelir.
    urlFiltreAlani: 'fisId',
    toplam: ['borc', 'alacak'], menuAd: 'Fiş Satırı Listesi', menuGizli: true, ic: '📗', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'masraf-merkezi', baslik: 'Masraf Merkezi Listesi', yol: 'Yonetim › Masraf Merkezi Listesi',
    kartYolu: '/masraf-merkezi', cipler: DURUM_CIPLERI,
    menuGrup: 'Muhasebe', menuAltGrup: 'Ayarlar', menuAd: 'Masraf Merkezi Listesi', ic: '🏷️', yetkiKodu: 'masraf_merkezi.liste',
    menuSira: 91,
  },
  {
    // Islem turu katalogu: kasa hareketlerinin ekstre/fis davranisini VERI olarak
    //   tasir (bkz. 073). Salt gorunum - duzenleme yonetici isi, kart yok.
    kaynak: 'kasa-islem-turu', baslik: 'İşlem Türü Listesi', yol: 'Yonetim › Islem Turleri',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuAltGrup: 'Ayarlar', menuAd: 'İşlem Türü Listesi', ic: '⚙️', yetkiKodu: 'kasa_islem_turu',
    menuSira: 93,
  },
  {
    // KAMPANYALAR (268, kullanici: "ayarlara liste ve kart olarak ekle"):
    //   fiyat listesi uzerine isleyen indirim kurallari; kurum sozlesmesinde
    //   secilir.
    kaynak: 'kampanya', baslik: 'Kampanya Listesi', yol: 'Stok & Hizmet › Kampanya Listesi',
    kartYolu: '/kampanya', aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Menude FIYAT LISTELERININ (27) hemen ardinda (kullanici): kampanya
    //   fiyat listesi uzerine isleyen bir kural - ikisi yan yana okunur,
    //   Yonetim altinda ararken bulunmuyordu.
    // Kampanya fiyat listesi UZERINE isleyen bir kural: hemen arkasinda durur.
    menuGrup: 'Kurumlar & Sigorta', menuAltGrup: 'Ayarlar', menuAd: 'Kampanya Listesi',
    ic: '🏷️', yetkiKodu: 'fiyat_listesi.kampanya.liste', menuSira: 92, erpMenuGrup: 'Satış',
  },
  {
    // DEPARTMANLAR (251): personel departmani ve randevu bolumu AYNI tablo -
    //   "Randevu Bölümü" isaretli olanlar randevu kartinin Bölüm listesinde.
    // 255: iki bolmeli ozel ekran (solda departman, sagda gorev) - duz liste
    //   degil; kullanici "Departman listesi ekranini 2'ye bol" dedi.
    kaynak: 'departman', baslik: 'Bölüm / Görev', yol: 'Yönetim › Bölüm / Görev',
    ozelSayfa: true,
    menuGrup: 'İK', menuSira: 20, menuAd: 'Bölüm / Görev', ic: '🏢', yetkiKodu: 'personel.bolum',
  },
];
