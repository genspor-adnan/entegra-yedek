import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Mesaj, randevu, kayıt kabul, sigorta ve muayene listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const KLINIK_LISTELERI: ListeGirdisi[] = [
  {
    // AŞI UYGULAMALARI (898, KTS H10 / USS 207): hasta bazlı kayıt.
    //   Uygulama HASTA KARTINDAN yapılır (doz numarasını sunucu hesaplıyor);
    //   bu liste kayıtların dökümü ve e-Nabız durumu için.
    kaynak: 'asi-uygulama', rota: 'asi-uygulama', baslik: 'Aşı Uygulamaları',
    yol: 'Muayene › Aşı Uygulamaları',
    tarihAlani: 'uygulamaZamani',
    cipler: [
      { ad: 'Uygulanan', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İptal', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'asi',
    // YENİ MENÜ GRUBU AÇILMADI: grup tavanı dolu (30) ve aşı zaten
    //   poliklinikte uygulanıyor - "Muayene" grubunun içinde duruyor.
    menuGrup: 'Muayene', menuAd: 'Aşı Uygulamaları', menuSira: 40,
    ic: '\u{1F489}', yetkiKodu: 'asi',
  },
  {
    // GEBELİK DOSYALARI (900, KTS H10): izlem buna bağlanır; aynı hastada
    //   aynı anda tek açık dosya olur.
    kaynak: 'gebelik', rota: 'gebelik', baslik: 'Gebelik Dosyaları',
    yol: 'Muayene › Gebelik Dosyaları',
    cipler: [
      { ad: 'Devam eden', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Riskli', filtre: { alan: 'riskDurumu', op: 'esit', deger: 1 } },
      { ad: 'Sonuçlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'gebe',
    menuGrup: 'Muayene', menuAd: 'Gebelik Dosyaları', menuSira: 47,
    ic: '\u{1F930}', yetkiKodu: 'gebe.dosya',
  },
  {
    // GEBE İZLEMLERİ (900 / USS 221): kilo KİLOGRAM - 209'daki gram
    //   çevrimi burada yok.
    kaynak: 'gebe-izlem', rota: 'gebe-izlem', baslik: 'Gebe İzlemleri',
    yol: 'Muayene › Gebe İzlemleri',
    tarihAlani: 'izlemTarihi',
    cipler: [
      { ad: 'Geçerli', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Riskli', filtre: { alan: 'riskSayisi', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'gebe',
    menuGrup: 'Muayene', menuAd: 'Gebe İzlemleri', menuSira: 48,
    ic: '\u{1FAC4}', yetkiKodu: 'gebe.izlem',
  },
  {
    // GEBELİK SONUÇLARI (902 / USS 224): doğum, düşük ya da tıbbi tahliye.
    //   Kayıt dosyayı kapatır ve paketi doğurur.
    kaynak: 'gebelik-sonuc', rota: 'gebelik-sonuc', baslik: 'Gebelik Sonuçları',
    yol: 'Muayene › Gebelik Sonuçları',
    tarihAlani: 'sonlanmaTarihi',
    cipler: [
      { ad: 'Geçerli', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'gebe',
    menuGrup: 'Muayene', menuAd: 'Gebelik Sonuçları', menuSira: 49,
    ic: '\u{1F476}‍⚕️', yetkiKodu: 'gebe.sonuc',
  },
  {
    // ÇOCUK İZLEMLERİ (899, KTS H10 / USS 209): persentil kolonları eğri
    //   verisi yüklüyse dolu gelir - boş persentil "hesaplanamadı" demektir.
    kaynak: 'cocuk-izlem', rota: 'cocuk-izlem', baslik: 'Çocuk İzlemleri',
    yol: 'Muayene › Çocuk İzlemleri',
    tarihAlani: 'izlemTarihi',
    cipler: [
      { ad: 'Geçerli', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İptal', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'cocuk',
    menuGrup: 'Muayene', menuAd: 'Çocuk İzlemleri', menuSira: 45,
    ic: '\u{1F476}', yetkiKodu: 'cocuk.izlem',
  },
  {
    // BÜYÜME EĞRİSİ (LMS) VERİSİ: WHO/Bakanlık tabloları buraya yüklenir.
    //   Tablo boşken persentil hesaplanmaz - uydurulmuş eğri, sağlıklı
    //   çocuğu "geri kalmış" gösterebilirdi.
    kaynak: 'cocuk-buyume-lms', rota: 'cocuk-buyume-lms',
    baslik: 'Büyüme Eğrisi (LMS)',
    yol: 'Muayene › Ayarlar › Büyüme Eğrisi',
    urunModu: 2, modul: 'cocuk',
    menuGrup: 'Muayene', menuAltGrup: 'Ayarlar', menuAd: 'Büyüme Eğrisi (LMS)',
    menuSira: 82,
    ic: '\u{1F4C8}', yetkiKodu: 'cocuk.buyume_lms',
  },
  {
    // AŞI KATALOĞU: SKRS kodu olmayan aşı e-Nabız'a gönderilemez; liste
    //   kodu kolon olarak gösteriyor ki eksik fark edilsin.
    kaynak: 'asi', rota: 'asi', baslik: 'Aşı Kataloğu',
    yol: 'Muayene › Ayarlar › Aşı Kataloğu',
    kartYolu: '/asi', kartBaslik: 'Aşı',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'asi',
    menuGrup: 'Muayene', menuAltGrup: 'Ayarlar', menuAd: 'Aşı Kataloğu',
    menuSira: 80,
    ic: '\u{1F48A}', yetkiKodu: 'asi.katalog',
  },
  {
    kaynak: 'mesajlar', rota: 'mesajlar', baslik: 'Mesajlar',
    yol: 'İletişim & AI › Mesajlar', ozelSayfa: true, menuAd: 'Mesajlar', menuGizli: true, ic: '💬',
    yetkiKodu: 'mesaj',
  },
  {
    kaynak: 'yapay-zeka', rota: 'yapay-zeka', baslik: 'Yapay Zeka',
    yol: 'İletişim & AI › Yapay Zeka', ozelSayfa: true, menuAd: 'Yapay Zeka', menuGizli: true, ic: '✨',
    yetkiKodu: 'ai',
  },
  {
    // RANDEVU kendi menu grubu (kullanici: "Randevu diye yeni menu olustur,
    //   Kayıt Kabul menusunun ust tarafina; icine Randevu ve Randevu Ayarlarini
    //   al; bunlar hbys icin gecerli"). Grup sirasi bu dizideki ILK gorulme
    //   sirasindan gelir - bu yuzden Hasta/Kayıt Kabul girdisinden ONCE durur.
    kaynak: 'randevu', baslik: 'Randevular', yol: 'Randevu › Randevular',
    kartYolu: '/randevu', aksiyonEkrani: 'randevu-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Planlandı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Geldi',     filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Gelmedi',   filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'İptal',     filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Randevu', menuAd: 'Randevular', ic: '📅', yetkiKodu: 'randevu',
    menuSira: 10,
  },
  {
    // CALISMA PLANI (711, mockup hekim_calisma_plani.html): hekim x sube x bolum x
    //   gun/saat x kanal; haftalik plan sablondan turer, "randevu verilebilir"
    //   bayraklarinin yerini aldi.
    kaynak: 'calisma-plani', ozelSayfa: true, baslik: 'Çalışma Planları',
    yol: 'Randevu › Çalışma Planları',
    urunModu: 2,
    menuGrup: 'Randevu', menuAd: 'Çalışma Planları', ic: '🗓', yetkiKodu: 'randevu.plan', menuSira: 20,
  },
  {
    kaynak: 'calisma-sablon', rota: 'calisma-sablon', aksiyonEkrani: 'calisma-sablon-liste', baslik: 'Çalışma Şablonları',
    yol: 'Randevu › Çalışma Şablonları',
    kartYolu: '/calisma-sablon', kartBaslik: 'Çalışma Şablonu',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Randevu', menuAltGrup: 'Ayarlar', menuAd: 'Çalışma Şablonları', ic: '📋', yetkiKodu: 'randevu.plan', menuSira: 80,
  },
  {
    kaynak: 'calisma-istisna', rota: 'calisma-istisna', aksiyonEkrani: 'calisma-istisna-liste', baslik: 'İzin & İstisnalar',
    yol: 'Randevu › İzin & İstisnalar',
    kartYolu: '/calisma-istisna', kartBaslik: 'Çalışma İstisnası',
    tarihAlani: 'basTarih',
    cipler: [
      { ad: 'Onaylı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2,
    menuGrup: 'Randevu', menuAltGrup: 'Ayarlar', menuAd: 'İzin & İstisnalar', ic: '🏖', yetkiKodu: 'randevu.plan', menuSira: 85,
  },
  {
    // Randevu Ayarlari (243): gun/saat duzeni + Bölümler sekmesi (251).
    kaynak: 'randevu-ayarlar', ozelSayfa: true, baslik: 'Randevu Ayarları',
    yol: 'Randevu › Randevu Ayarları',
    urunModu: 2,
    menuGrup: 'Randevu', menuAltGrup: 'Ayarlar', menuAd: 'Randevu Ayarları', ic: '⚙️',
    yetkiKodu: 'randevu', menuSira: 90,
  },
  {
    // Tek ogeli grup (kullanici: "Cari menu ustune Hasta menusu ac, altina Hasta
    // Listesi ekle") - Cari grubunun HEMEN USTUNDE, ayni acilir-kapanir desende.
    kaynak: 'hasta', baslik: 'Hastalar', yol: 'Hasta › Hastalar', kartYolu: '/hasta',
    aksiyonEkrani: 'hasta-liste', cipler: DURUM_CIPLERI,
    // Acik borc HASTA SERIDI icin katalogda duruyor (basvuru kartinin
    //   ustundeki serit onu okuyor) ama gridde gosterilmez.
    //   KURUM (sigortaAdi) ARTIK GORUNUR (kullanici: "son basvuru soluna
    //   Kurumu ekle") - katalogda da Son Basvuru'nun oncesine alindi.
    gizliKolonlar: ['acikBorc'],
    // Hasta da bir TARAF - cari ekstresi aynen gecerli (hasta hesabi hareketleri).
    ekstre: { kaynak: 'cari-ekstre', alan: 'tarafId', baslik: 'Hasta Ekstresi',
              tarihAlani: 'islemTarihi',
              kolonBasliklari: { belgeNo: 'Protokol No' } },
    // Kayit Kabul YALNIZ GenoTIP AI'da (kullanici, 215) - diger moduller ortak.
    // HASTA LISTESI BASVURULARDAN ONCE (kullanici): kayit kabulde is once
    //   hastayi bulmakla baslar - basvuru ondan sonra acilir.
    // HASTANIN KENDI YETKISI (684): liste `personel` yetkisine bagliydi -
    //   banko gorevlisine hasta listesi vermek icin personel ozluk kayitlarini
    //   da acmak gerekiyordu, matriste de "Kayit Kabul > Personel" gorunuyordu.
    menuGrup: 'Kayıt Kabul', menuAd: 'Hasta Listesi', ic: '🤕', yetkiKodu: 'hasta',
    menuSira: 10,
    urunModu: 2,
  },
  {
    // BASVURU (246/279, kullanici: "basvurudaki islemler normal alinan
    //   siparislerimizdir"): AYRI TUR DEGIL - satis siparisinin (19) GenoTIP
    //   ekranidir. Ayni belge ERP kurulumunda "Satış Siparişleri" listesinde
    //   gorunur; iki liste ayni turu gostermesin diye ikisi de urunModu ile
    //   suzulur.
    kaynak: 'belge', rota: 'basvuru', baslik: 'Başvurular',
    yol: 'Kayıt Kabul › Başvurular',
    aksiyonEkrani: 'basvuru-liste', yeniBelgeTuru: 19,
    // BASVURU ile SATIS SIPARISI ayni turdur (19); ayirt eden belge TIPIDIR
    //   (301): basvuru 30, ERP siparisi 1. urunModu zaten iki ekrani ayri
    //   kurulumlara veriyor ama filtre veriye de dayansin - ayni veritabanina
    //   iki modla bakildiginda listeler karismasin.
    sabitFiltre: { op: 'and', kosullar: [
      { alan: 'tur', op: 'esit', deger: 19 },
      { alan: 'tipi', op: 'esit', deger: 30 },
    ] },
    // Basvuru e-Belge degil; tur kolonlari da tek turlu listede gereksiz.
    //   'durum' (Durum Kodu) siparis listesinden miras: basvuruda anlami yok,
    //   hepsi ayni degeri gosterip "Pasif" gibi okunuyordu (kullanici).
    //   'kaynak' (donusum zincirinde onceki belge) da gizli: basvuru zincirin
    //   BASI, kolon hep bos duruyordu. 'tipi'/'kapanmaDurum' ham KOD
    //   kolonlaridir (filtre icin) - okunur karsiliklari zaten var (kullanici).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum',
    //   'subeId' (Şube Kodu) ve 'vadeGun' de gizli: sube ADI zaten var, vade
    //   basvuruda yok - yerine Ödeyen Kurum kullaniliyor (kullanici).
    //   'senaryoAdi'/'senaryo' e-Fatura kavrami - basvuruda karsiligi yok.
                    'durum', 'durumAdi', 'kaynak', 'tipi', 'kapanmaDurum',
    //   'belgeSeri' DB'de duruyor (numara benzersizligi seri+no ikilisinde) ama
    //   listede hic gosterilmez - kolon menusunde de cikmaz (kullanici).
    //   Kalan ham/ERP kolonlari da basvuruda okunmuyor: Cari Id, Açık/Kapalı
    //   Kodu, Ort. Maliyet ve Tipi (fatura/irsaliye alt turu).
                    'subeId', 'vadeGun', 'senaryoAdi', 'senaryo', 'belgeSeri',
    //   Matrah/KDV basvuruda okunmuyor: hastaya soylenen rakam GENEL TOPLAM,
    //   yaninda ne kadari tahsil edildigi (kullanici).
                    'tarafId', 'acikKapali', 'maliyetOrt', 'tipiAdi',
                    'odeyenKurumId', 'bolumId', 'doktorId', 'tahsilatDurum',
                    'matrah', 'kdvTutari'],
    // Kaynak kolonunun yerine ODEYEN KURUM / POLIKLINIK / DOKTOR (kullanici).
    //   SERI listede yok ama katalogda DURUYOR: gizliKolonlar'a konsa kolon
    //   menusunden de kaybolurdu - gerektiginde kullanici acar.
    //   Sira: once belgenin kimligi (no, tarih, hasta), sonra basvuru bilgisi
    //   (odeyen kurum, poliklinik, hekim) - kullanici.
    //   TAMAMLANMA CIZGISI PROTOKOL NO'NUN SOLUNDA (kullanici; onceki karar
    //   sagindaydi, degisti): rozet cizgiye donunce gozun once tarayacagi
    //   sey "nerede kaldi" oldu - protokol numarasi aranan degil, bulunan
    //   satirda okunan bir bilgi.
    //   SOZLESME kurumun HEMEN SAGINDA (kullanici): ayni sigortayla ÖSS /
    //   TSS / Karma police ayri sartlarla calisir, odeme rotasini o belirler.
    //   HASTA kolonu CARI DEGIL (658, kullanici: "basvuru 3990 da hasta adi
    //   yok"): dis kurum numunesinde cari GONDEREN KURUMDUR, hasta ayri
    //   alanda durur. "Cari" kolonu listede kalir ama hasta kendi
    //   kolonundan okunur - ikisi ayni sey degil.
    kolonSirasi: ['belgeTarihi', 'tamamlanma', 'belgeNo', 'hastaAdi',
                  'odeyenKurumAdi', 'sozlesmeAdi', 'poliklinik', 'doktor',
                  'genelToplam', 'tahsilat'],
    // TAHSILAT da toplanir (kullanici): "ne kadari geldi" sorusu genel
    //   toplamin yaninda okunsun - ikisinin farki gunun acik borcudur.
    toplam: ['genelToplam', 'tahsilat'],
    // CIP YOK (kullanici): Acik/Kismi/Kapanan cipleri yerine seritte uc
    //   combo - Tamamlanma, Tahsilat ve Donusum. Eski cipler Donusum
    //   combosunun secenekleri oldu.

    // "Tümü"nun saginda ayracla: tarih araligi, Odeyen, Bolum agaci, Doktor
    //   (kullanici). Ham id kolonlari gizli tutulur - suzme ADA gore
    //   calisamaz (ayni adli kurum / unvan degisikligi filtreyi kaydirir).
    basvuruSuzgeci: true,
    // Basvuruda belge numarasi PROTOKOL NUMARASIDIR (kullanici); kart da
    //   oyle adlandiriyor. Katalogda "Belge No" kalir - ayni kaynagi 13
    //   liste paylasiyor.
    //   "Ödeyen Kurum" da bu ekranda yalnizca KURUM (kullanici) - basvuruda
    //   zaten odemeyi ustlenen kurumdan baskasi yazilmiyor.
    //   "Cari" ise burada HASTA (kullanici): kayit kabulde belgenin tarafi
    //   her zaman hastadir, "Cari" ERP dilidir.
    kolonBasliklari: { belgeNo: 'Protokol No', odeyenKurumAdi: 'Kurum' },
    urunModu: 2,
    menuGrup: 'Kayıt Kabul', menuAd: 'Başvurular', ic: '♿', yetkiKodu: 'belge',
    menuSira: 20,
  },
  {
    // ISKONTO ONAYI (666): bankonun limitini asan iskonto taleplerinin
    //   yetkiliye dustugu kuyruk. Liste DEGIL (ozelSayfa) - sayac, kuyruk,
    //   karar paneli ve analiz sekmelerinden olusur. Zil ayni isi TEK talep
    //   icin yapar; burasi kuyrugun kendisidir.
    kaynak: 'iskonto-onay', rota: 'iskonto-onay', ozelSayfa: true,
    baslik: 'İskonto Onayı', yol: 'Kayıt Kabul › İskonto Onayı',
    urunModu: 2,
    // KENDI YETKISI (685, kullanici: "kayit kabul altina sirayla hasta
    //   listesi, basvurular ve iskonto onayi gelmeli"): ekran `belge`
    //   yetkisine bagliydi, matriste basvurularla TEK satira dusuyordu.
    //   Onay kuyrugunu gormek belge gormekten ayri bir istir - kararin
    //   TAVANI ayrica `basvuru.iskonto` aksiyonundan gelir.
    menuGrup: 'Kayıt Kabul', menuAd: 'İskonto Onayı', ic: '✅',
    yetkiKodu: 'iskonto_onay', menuSira: 30,
  },
  {
    // HASTA AVANSLARI (779, kullanici: "hastadan alinan avans tahsilati
    //   takibi yapabilmeliyiz").
    //
    //   Ayni para Kasa Islemleri listesinde "Dagitilmamis" cipiyle de
    //   goruluyordu, ama finans diliyle ve butun carilerle birlikte. Kayit
    //   kabulun sordugu soru daha dar: HANGI HASTANIN ne kadar avansi kaldi.
    //   Bu yuzden ayri bir ekran - ayni veriye hasta kiriliminda bakar.
    kaynak: 'hasta-avans', rota: 'hasta-avans', baslik: 'Hasta Avansları',
    yol: 'Kayıt Kabul › Hasta Avansları',
    aksiyonEkrani: 'avans-liste',
    // Kart YOK: avansin kendisi bir kasa islemi, "Aç" onu modalde acar.
    tarihAlani: 'islemTarihi',
    cipler: [
      // Acik avans = KALAN parasi olan; kayit kabulun gunluk sorusu budur.
      { ad: 'Açık', filtre: { alan: 'kalan', op: 'buyuk', deger: 0 } },
      { ad: 'Kullanıldı', filtre: { alan: 'kalan', op: 'esit', deger: 0 } },
      // IADE (780): parasi hastaya GERI ODENEN avanslar - "kullanildi" ile
      //   ayni kutuda durmamali, biri hizmete sayildi oteki kasadan cikti.
      { ad: 'İade', filtre: { alan: 'iade', op: 'buyuk', deger: 0 } },
      { ad: 'Tümü' },
    ],
    toplam: ['alinan', 'kullanilan', 'iade', 'kalan'],
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Kayıt Kabul', menuAd: 'Hasta Avansları', ic: '💰',
    yetkiKodu: 'kasa_islem', menuSira: 35,
  },
  // RADYOLOJI grubu ana menude KAYIT KABUL ile CRM ARASINDA (kullanici):
  //   grup sirasi bu dizideki ILK gorulme sirasindan gelir.
  {
    // SIGORTA PROVIZYONLARI (430). Provizyon burada ALINMAZ - basvuru
    //   kartindan alinir (kalemler orada); bu ekran takip ve duzeltmedir.
    kaynak: 'sigorta-provizyon', rota: 'sigorta-provizyon',
    baslik: 'Sigorta Provizyonları', yol: 'Cari › Sigorta › Provizyonlar',
    aksiyonEkrani: 'sigorta-provizyon-liste',
    tarihAlani: 'provizyonTarihi',
    cipler: [
      { ad: 'Onaylı',      filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Kısmi',       filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Red',         filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Gönderildi',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    toplam: ['talepToplam', 'sirketPayi', 'hastaPayi'],
    urunModu: 2, modul: 'muayene',
    // SIGORTA CARI ALTINDA, KURUMLAR'IN ARDINDA (kullanici): sigorta sirketi
    //   bir CARI kayittir; ayarlari da o kartin yaninda aranir.
    //   YALNIZ HBYS (urunModu 2): ozel saglik sigortasi ERP kurulumunda yok.
    menuGrup: 'Kayıt Kabul',
    menuAd: 'Provizyonlar', ic: '🛡️', yetkiKodu: 'sigorta', menuSira: 40,
  },
  {
    // KURUM HESAPLARI (430): hangi sigorta sirketi hangi saglayici uzerinden.
    //   Parola/istemci sirri BURADA GORUNMEZ - entegrasyon hesabi kartinda.
    kaynak: 'sigorta-hesap', rota: 'sigorta-hesap', baslik: 'Sigorta Hesapları',
    yol: 'Cari › Sigorta › Kurum Hesapları',
    kartYolu: '/sigorta-hesap', kartBaslik: 'Sigorta Hesabı',
    aksiyonEkrani: 'sigorta-hesap-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Kurumlar & Sigorta',
    menuAd: 'Kurum Hesapları', ic: '🔌', yetkiKodu: 'sigorta', menuSira: 30,
  },
  {
    // KOD ESLEME (430): kanonik deger <-> saglayici degeri. Yeni sirket
    //   baglanirken doldurulan TEK tablo; sema ve ekran degismez.
    kaynak: 'sigorta-kod-esleme', rota: 'sigorta-kod-esleme',
    baslik: 'Sigorta Kod Eşleme', yol: 'Cari › Sigorta › Kod Eşleme',
    kartYolu: '/sigorta-kod-esleme', kartBaslik: 'Kod Eşlemesi',
    aksiyonEkrani: 'sigorta-kod-esleme-liste',
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Kurumlar & Sigorta', menuAltGrup: 'Ayarlar',
    menuAd: 'Kod Eşleme', ic: '🔤', yetkiKodu: 'sigorta', menuSira: 90,
  },
  {
    // ISTEK GUNLUGU (430): "biz ne gonderdik, onlar ne dedi". Ihtilafta kanit.
    kaynak: 'sigorta-istek-log', rota: 'sigorta-istek-log',
    baslik: 'Sigorta İstek Günlüğü', yol: 'Cari › Sigorta › İstek Günlüğü',
    aksiyonEkrani: 'sigorta-istek-log-liste',
    tarihAlani: 'tarih',
    icerikAlani: 'yanitMetni', icerikBaslik: 'Servis Yanıtı',
    cipler: [
      { ad: 'Hatalı',   filtre: { alan: 'basarili', op: 'esit', deger: 0 } },
      { ad: 'Başarılı', filtre: { alan: 'basarili', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Kurumlar & Sigorta',
    menuAd: 'İstek Günlüğü', ic: '🧾', yetkiKodu: 'sigorta', menuSira: 40,
  },
  {
    // CIHAZLAR (432) - laboratuvar/goz/goruntuleme cihazlarinin baglanti
    //   tanimi. Randevu tarafindaki radyoloji_cihaz'dan AYRI: o cekim
    //   planlamasi, bu entegrasyon kaydi.
    kaynak: 'cihaz', rota: 'cihaz', baslik: 'Cihazlar',
    yol: 'Laboratuvar › Biyokimya › Cihazlar',
    kartYolu: '/cihaz', kartBaslik: 'Cihaz',
    aksiyonEkrani: 'cihaz-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    // Kullanici: "cihazlar menusunu laboratuvar altina sona al" - cihaz
    //   entegrasyonunu gunluk kullanan lab teknisyeni; Yonetim altinda
    //   ayri bir grupta durmasi onu her seferinde menu degistirmeye
    //   zorluyordu. Sira lab ekranlarinin ARDINDAN (70/80).
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya',
    menuAd: 'Cihazlar', ic: '🔌', yetkiKodu: 'cihaz', menuSira: 103,
  },
  {
    // CIHAZ MESAJLARI (432) - gelen ham mesajlar. Ham metin "İçerik"
    //   penceresinde okunur: cozumleme hatasinda bakilacak tek yer orasi.
    kaynak: 'cihaz-mesaj', rota: 'cihaz-mesaj', baslik: 'Cihaz Mesajları',
    yol: 'Laboratuvar › Biyokimya › Cihaz Mesajları',
    aksiyonEkrani: 'cihaz-mesaj-liste',
    tarihAlani: 'eklemeTarihi',
    icerikAlani: 'ham', icerikBaslik: 'Ham Cihaz Mesajı',
    cipler: [
      { ad: 'Hata',       filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Çözümlendi', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'İşlendi',    filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya',
    menuAd: 'Cihaz Mesajları', ic: '📡', yetkiKodu: 'cihaz', menuSira: 104,
  },
  {
    // ITS BILDIRIM KUYRUGU (427) - ilac karekod bildirimleri.
    //   UTS ile KARISTIRILMAZ: UTS tibbi cihaz, ITS ilac; ayri kurum, ayri
    //   servis, ayri ekran.
    kaynak: 'its-bildirim', rota: 'its-bildirim', baslik: 'İTS Bildirimleri',
    yol: 'Stok & Hizmet › İTS › Bildirimler',
    aksiyonEkrani: 'its-liste',
    tarihAlani: 'islemTarihi',
    cipler: [
      { ad: 'Bekleyen',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Gönderildi',  filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Hatalı',      filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    // ITS, UTS'nin HEMEN ONUNDE (kullanici): ikisi ayri kurum ve ayri servis
    //   (ITS ilac, UTS tibbi cihaz) ama ayni is - karekod bildirimi; yan yana
    //   dururlar. Sira 68: UTS alt grubu 70'ten basliyor.
    menuSira: 100, menuGrup: 'Stok & Hizmet', menuAltGrup: 'İTS',
    menuAd: 'Bildirimler', ic: '💊', yetkiKodu: 'stok',
  },
  {
    // RECETELER (413) - muayenede yazilan ilaclar. Recete bir BELGEDIR:
    //   imzalaninca degismez, ilac adi satira kopyalanir.
    kaynak: 'recete', rota: 'recete', baslik: 'Reçeteler',
    yol: 'Muayene › Reçeteler',
    kartYolu: '/recete', kartBaslik: 'Reçete',
    aksiyonEkrani: 'cari-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Taslak',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'İmzalı',       filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Medula Kabul', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 30, menuGrup: 'Muayene', menuAd: 'Reçeteler', ic: '💊', yetkiKodu: 'muayene',
  },
  {
    // HAKEDISLERIM (mockup Ekranlar/Muayene/hekim_hakedislerim.html):
    //   hekimin KENDI prim dokumu. Liste degil ozel sayfa - ozet kutulari,
    //   kaynak kirilimi ve gruplu dokum bir grid'e sigmaz.
    //   Yetki `prim.kendi`: sunucu satirlari oturumun kisisine suzer.
    //   Butun kisileri goren ekran Prim modulunde ve `prim` yetkisinde -
    //   herkesin primini birbirine gostermemek icin ayri yetki.
    kaynak: 'hakedisim', rota: 'hakedisim', ozelSayfa: true,
    baslik: 'Hakedişlerim', yol: 'Muayene › Hakedişlerim',
    urunModu: 2, modul: 'muayene',
    menuSira: 40, menuGrup: 'Muayene', menuAd: 'Hakedişlerim', ic: '💰',
    yetkiKodu: 'prim.kendi',
  },
  {
    // PRIM SATIRLARI (kullanici: "hakedislerim menusunden ONCE prim satirlari
    //   menusu, sadece giren doktorun primleri"): AYNI self-scoped endpoint
    //   (/api/prim/hakedisim - taraf_id oturumdan) ve AYNI sayfa; yalnizca
    //   menude Hakedislerim'in ustunde (menuSira 38 < 40) ayri giris. Baskasinin
    //   primi gorunmez cunku sunucu suzgeci oturumun kisisidir.
    kaynak: 'prim-satirlari', rota: 'prim-satirlari', ozelSayfa: true,
    baslik: 'Prim Satırları', yol: 'Muayene › Prim Satırları',
    urunModu: 2, modul: 'muayene',
    menuSira: 38, menuGrup: 'Muayene', menuAd: 'Prim Satırları', ic: '📄',
    yetkiKodu: 'prim.kendi',
  },
  {
    // TIBBI OZET (420) - hasta basina tek satir: alerji / kronik / ilac.
    //   Muayene kartinin ust seridi ve bu ekran AYNI kaynagi okur; iki ayri
    //   sorgu, iki farkli "aktif ilac" tanimi uretirdi.
    kaynak: 'hasta-tibbi-ozet', rota: 'hasta-tibbi-ozet', baslik: 'Tıbbi Özet',
    yol: 'Muayene › Tıbbi Özet',
    aksiyonEkrani: 'cikti-liste',
    tarihAlani: 'sonMuayene',
    urunModu: 2, modul: 'muayene', menuAd: 'Tıbbi Özet', menuGizli: true, ic: '📖', yetkiKodu: 'muayene',
  },
  {
    // KRONIK TANILAR (420) - muayenede "kronik" isaretlenen tani buraya
    //   TETIKLE duser; hekime "bir de tibbi ozete ekle" dedirtmek,
    //   unutuldugunda sonraki hekimin eksik bilgiyle karar vermesi demekti.
    kaynak: 'hasta-kronik', rota: 'hasta-kronik', baslik: 'Kronik Tanılar',
    yol: 'Muayene › Kronik Tanılar',
    kartYolu: '/hasta-kronik', kartBaslik: 'Kronik Tanı',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Geçmiş', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene', menuAd: 'Kronik Tanılar', menuGizli: true, ic: '🩹', yetkiKodu: 'muayene',
  },
  {
    // GECMIS OLAYLAR (420) - ameliyat / girisim / yatis / asi / travma.
    kaynak: 'hasta-gecmis', rota: 'hasta-gecmis', baslik: 'Geçmiş Olaylar',
    yol: 'Muayene › Geçmiş Olaylar',
    kartYolu: '/hasta-gecmis', kartBaslik: 'Geçmiş Olay',
    aksiyonEkrani: 'cari-liste',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'muayene', menuAd: 'Geçmiş Olaylar', menuGizli: true, ic: '🏥', yetkiKodu: 'muayene',
  },
  {
    // HASTA ALERJILERI (413) - ETKEN MADDE bazli. Marka uzerinden tutmak
    //   ayni etkeni tasiyan baska markayi kacirirdi.
    kaynak: 'hasta-alerji', rota: 'hasta-alerji', baslik: 'Hasta Alerjileri',
    yol: 'Muayene › Alerjiler',
    kartYolu: '/hasta-alerji', kartBaslik: 'Alerji Kaydı',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene', menuAd: 'Alerjiler', menuGizli: true, ic: '⚠️', yetkiKodu: 'muayene',
  },
  {
    // HASTANIN KULLANDIGI ILACLAR (413) - recete satirlarinin kopyasi DEGIL:
    //   hasta baska kurumdan aldigini da kullanir, bizim yazdigimizin bir
    //   kismini kullanmaz. Etkilesim kontrolu KULLANILANA bakar.
    kaynak: 'hasta-ilac', rota: 'hasta-ilac', baslik: 'Kullanılan İlaçlar',
    yol: 'Muayene › Kullanılan İlaçlar',
    kartYolu: '/hasta-ilac', kartBaslik: 'İlaç Kaydı',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene', menuAd: 'Kullanılan İlaçlar', menuGizli: true, ic: '🧾', yetkiKodu: 'muayene',
  },
  {
    // MUAYENE SABLONLARI (411) - brans/kisisel fizik muayene sablonlari.
    //   Alanlar kartin "Alanlar" detayinda; sablon uygulaninca her alan bir
    //   bulgu satiri olarak acilir ve "normal" isaretlenir.
    kaynak: 'muayene-sablon', rota: 'muayene-sablon', baslik: 'Muayene Şablonları',
    yol: 'Muayene › Muayene Ayarları › Muayene Şablonları',
    // ÖZEL SAYFA (mockup muayene_sablonlari.html): iki panel + 6 sekme -
    //   generic liste/kart yerine MuayeneSablonlari bileşeni.
    ozelSayfa: true,
    kartYolu: '/muayene-sablon', kartBaslik: 'Muayene Şablonu',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 90, menuGrup: 'Muayene', menuAltGrup: 'Ayarlar',
    menuAd: 'Muayene Şablonları', ic: '📋', yetkiKodu: 'muayene',
  },
  {
    // BZBH BILDIRIM PANOSU (882, KTS H5): ozel sayfa - bekleyen vaka
    //   bildirimleri, vaka tipi/belirti tarihi girisi ve 214 gonderimi.
    kaynak: 'bzbh', ozelSayfa: true, baslik: 'BZBH Bildirimleri',
    yol: 'Muayene \u203a BZBH Bildirimleri',
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Muayene', menuAd: 'BZBH Bildirimleri', ic: '\ud83e\udda0',
    yetkiKodu: 'bzbh', menuSira: 45,
  },
  {
    // BZBH HASTALIK LISTESI (882): ICD onekiyle eslesen bildirimi zorunlu
    //   hastaliklar. Tohum liste teblige gore dogrulanmayi bekler.
    kaynak: 'bzbh-hastalik', rota: 'bzbh-hastalik', baslik: 'BZBH Hastalık Listesi',
    yol: 'Muayene \u203a Muayene Ayarları \u203a BZBH Hastalık Listesi',
    kartYolu: '/bzbh-hastalik', kartBaslik: 'BZBH hastalığı',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Grup A', filtre: { alan: 'grup', op: 'esit', deger: 1 } },
      { ad: 'Doğrulanmamış', filtre: { alan: 'dogrulandi', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Muayene', menuAltGrup: 'Ayarlar', menuAd: 'BZBH Hastalık Listesi',
    ic: '\ud83e\uddec', yetkiKodu: 'bzbh.hastalik', menuSira: 95,
  },
  {
    // METIN MAKROLARI (411) - kisayoldan hazir metin. Sablon ALAN tanimlar,
    //   makro METIN uretir: biri yapiyi, oteki hizi cozer.
    kaynak: 'metin-makro', rota: 'metin-makro', baslik: 'Metin Makroları',
    yol: 'Muayene › Muayene Ayarları › Metin Makroları',
    kartYolu: '/metin-makro', kartBaslik: 'Metin Makrosu',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 91, menuGrup: 'Muayene', menuAltGrup: 'Ayarlar',
    menuAd: 'Metin Makroları', ic: '⌨️', yetkiKodu: 'muayene',
  },
  {
    // HEKIM CALISMA LISTESI (410, Faz 1) - hekimin gun icindeki isi.
    //   Satir = BASVURU (belge tur 19), muayene henuz acilmamis olabilir;
    //   "Muayeneye Al" onu acar. Ayri bir liste tablosu YOK - kayit kabulun
    //   actigi basvurudan turer, yoksa ayni hasta iki yerde iki durumda
    //   gorunurdu.
    kaynak: 'hekim-listesi', rota: 'hekim-listesi', baslik: 'Hekim Çalışma Listesi',
    yol: 'Muayene › Çalışma Listesi',
    aksiyonEkrani: 'hekim-liste',
    tarihAlani: 'saat',
    cipler: [
      { ad: 'Bekleyen',       filtre: { alan: 'durumKod', op: 'esit', deger: 0 } },
      { ad: 'Çağrıldı',       filtre: { alan: 'durumKod', op: 'esit', deger: 1 } },
      { ad: 'Muayenede',      filtre: { alan: 'durumKod', op: 'esit', deger: 2 } },
      { ad: 'Sonuç Bekleyen', filtre: { alan: 'durumKod', op: 'esit', deger: 3 } },
      { ad: 'Tamamlanan',     filtre: { alan: 'durumKod', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 10, menuGrup: 'Muayene', menuAd: 'Çalışma Listesi', ic: '📋', yetkiKodu: 'muayene',
  },
  {
    // MUAYENE (409, Faz 1): tip merkezindeki uzman hekim muayenesi -
    //   basvurudan dogar; anamnez, vital, sablonlu bulgu, ICD-10 tani ve
    //   istemler kartin sekmelerinde. Cipler gunun isini bolumler: once
    //   hekimin siradaki isi (acik), sonra sonuc bekleyenler.
    kaynak: 'muayene', rota: 'muayene', baslik: 'Muayeneler',
    yol: 'Muayene › Muayeneler',
    kartYolu: '/muayene', kartBaslik: 'Muayene',
    // KART IZGARASINDAN CIKANLAR (kullanici): hasta, basvuru protokol id,
    //   muayene no ve kayit tarihi BAGLAM SERIDINDE zaten var; durum ise
    //   baslik rozetine tasindi. Izgara boylece yalnizca hekimin YAZDIGI
    //   alanlarla kaliyor (tur, bolum, hekim, sure). randevuId de cikti: ham id
    //   hekime bir sey soylemiyor. Kalan alanlar (Tur, Bolum, Hekim, Baslama,
    //   Bitis, isteyen muayene) kart govdesinde degil, baglam seridindeki
    //   "Bugun" kutusundan acilan pencerede (Liste.seritSarmalayici).
    gizliKartAlanlari: ['tarafId', 'durum', 'belgeId', 'muayeneNo', 'muayeneTarihi',
                        'randevuId'],
    aksiyonEkrani: 'muayene-liste',
    tarihAlani: 'muayeneTarihi',
    cipler: [
      { ad: 'Açık',            filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Sonuç Bekleyen',  filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tamamlanan',      filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 20, menuGrup: 'Muayene', menuAd: 'Muayeneler', ic: '🩺', yetkiKodu: 'muayene',
  },
];
