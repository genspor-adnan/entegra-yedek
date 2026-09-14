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
    kaynak: 'mesajlar', rota: 'mesajlar', baslik: 'Mesajlar',
    yol: 'İletişim & AI › Mesajlar', ozelSayfa: true,
    menuGrup: 'İletişim & AI', menuAd: 'Mesajlar', ic: '💬',
    yetkiKodu: 'mesaj', menuSira: 10,
  },
  {
    kaynak: 'yapay-zeka', rota: 'yapay-zeka', baslik: 'Yapay Zeka',
    yol: 'İletişim & AI › Yapay Zeka', ozelSayfa: true,
    menuGrup: 'İletişim & AI', menuAd: 'Yapay Zeka', ic: '✨',
    yetkiKodu: 'ai', menuSira: 20,
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
    // Randevu Ayarlari (243): gun/saat duzeni + Bölümler sekmesi (251).
    kaynak: 'randevu-ayarlar', ozelSayfa: true, baslik: 'Randevu Ayarları',
    yol: 'Randevu › Randevu Ayarları',
    urunModu: 2,
    menuGrup: 'Randevu', menuAd: 'Randevu Ayarları', ic: '⚙️',
    yetkiKodu: 'randevu', menuSira: 11,
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
    menuGrup: 'Kayıt Kabul', menuAd: 'Hasta Listesi', ic: '🏥', yetkiKodu: 'personel',
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
    menuGrup: 'Kayıt Kabul', menuAd: 'Başvurular', ic: '📝', yetkiKodu: 'belge',
    menuSira: 30,
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
    menuGrup: 'Cari', menuAltGrup: 'Sigorta',
    menuAd: 'Provizyonlar', ic: '🛡️', yetkiKodu: 'sigorta', menuSira: 11,
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
    menuGrup: 'Cari', menuAltGrup: 'Sigorta',
    menuAd: 'Kurum Hesapları', ic: '🔌', yetkiKodu: 'sigorta', menuSira: 12,
  },
  {
    // KOD ESLEME (430): kanonik deger <-> saglayici degeri. Yeni sirket
    //   baglanirken doldurulan TEK tablo; sema ve ekran degismez.
    kaynak: 'sigorta-kod-esleme', rota: 'sigorta-kod-esleme',
    baslik: 'Sigorta Kod Eşleme', yol: 'Cari › Sigorta › Kod Eşleme',
    kartYolu: '/sigorta-kod-esleme', kartBaslik: 'Kod Eşlemesi',
    aksiyonEkrani: 'sigorta-kod-esleme-liste',
    urunModu: 2, modul: 'muayene',
    menuGrup: 'Cari', menuAltGrup: 'Sigorta',
    menuAd: 'Kod Eşleme', ic: '🔤', yetkiKodu: 'sigorta', menuSira: 13,
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
    menuGrup: 'Cari', menuAltGrup: 'Sigorta',
    menuAd: 'İstek Günlüğü', ic: '🧾', yetkiKodu: 'sigorta', menuSira: 14,
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
    menuAd: 'Cihazlar', ic: '🔌', yetkiKodu: 'cihaz', menuSira: 15,
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
    menuAd: 'Cihaz Mesajları', ic: '📡', yetkiKodu: 'cihaz', menuSira: 17,
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
    menuSira: 68, menuGrup: 'Stok & Hizmet', menuAltGrup: 'İTS',
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
    menuSira: 70, menuGrup: 'Muayene', menuAd: 'Hakedişlerim', ic: '💰',
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
    urunModu: 2, modul: 'muayene',
    menuSira: 40, menuGrup: 'Muayene', menuAd: 'Tıbbi Özet', ic: '📖', yetkiKodu: 'muayene',
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
    urunModu: 2, modul: 'muayene',
    menuSira: 50, menuGrup: 'Muayene', menuAd: 'Kronik Tanılar', ic: '🩹', yetkiKodu: 'muayene',
  },
  {
    // GECMIS OLAYLAR (420) - ameliyat / girisim / yatis / asi / travma.
    kaynak: 'hasta-gecmis', rota: 'hasta-gecmis', baslik: 'Geçmiş Olaylar',
    yol: 'Muayene › Geçmiş Olaylar',
    kartYolu: '/hasta-gecmis', kartBaslik: 'Geçmiş Olay',
    aksiyonEkrani: 'cari-liste',
    tarihAlani: 'tarih',
    urunModu: 2, modul: 'muayene',
    menuSira: 60, menuGrup: 'Muayene', menuAd: 'Geçmiş Olaylar', ic: '🏥', yetkiKodu: 'muayene',
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
    urunModu: 2, modul: 'muayene',
    menuSira: 70, menuGrup: 'Muayene', menuAd: 'Alerjiler', ic: '⚠️', yetkiKodu: 'muayene',
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
    urunModu: 2, modul: 'muayene',
    menuSira: 80, menuGrup: 'Muayene', menuAd: 'Kullanılan İlaçlar', ic: '🧾', yetkiKodu: 'muayene',
  },
  {
    // MUAYENE SABLONLARI (411) - brans/kisisel fizik muayene sablonlari.
    //   Alanlar kartin "Alanlar" detayinda; sablon uygulaninca her alan bir
    //   bulgu satiri olarak acilir ve "normal" isaretlenir.
    kaynak: 'muayene-sablon', rota: 'muayene-sablon', baslik: 'Muayene Şablonları',
    yol: 'Muayene › Muayene Ayarları › Muayene Şablonları',
    kartYolu: '/muayene-sablon', kartBaslik: 'Muayene Şablonu',
    aksiyonEkrani: 'cari-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'muayene',
    menuSira: 90, menuGrup: 'Muayene', menuAltGrup: 'Muayene Ayarları',
    menuAd: 'Muayene Şablonları', ic: '📋', yetkiKodu: 'muayene',
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
    menuSira: 92, menuGrup: 'Muayene', menuAltGrup: 'Muayene Ayarları',
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
    menuSira: 20, menuGrup: 'Muayene', menuAd: 'Çalışma Listesi', ic: '📋', yetkiKodu: 'muayene',
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
    menuSira: 10, menuGrup: 'Muayene', menuAd: 'Muayeneler', ic: '🩺', yetkiKodu: 'muayene',
  },
];
