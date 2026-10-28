import { type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Laboratuvar: istem, numune, sonuç, mikrobiyoloji, genetik, kalite kontrol.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const LAB_LISTELERI: ListeGirdisi[] = [
  {
    // LABORATUVAR ISTEMLERI (360): biyokimya / mikrobiyoloji / genetik.
    //   Satir = istem; testler ve sonuclari kartin "Testler" detayinda.
    // ISTEM ve NUMUNE KABUL MENUNUN EN USTUNDE (kullanici): gunun isi
    //   bunlardan baslar; dal basliklari (Biyokimya/Mikrobiyoloji/Genetik)
    //   10-34, kalan ortak akis 50+.
    kaynak: 'lab-istem', rota: 'lab-istem', baslik: 'Laboratuvar İstemi Listesi',
    yol: 'Laboratuvar › Laboratuvar İstemi Listesi',
    kartYolu: '/lab-istem', kartBaslik: 'Laboratuvar İstemi',
    // 433'e kadar aksiyonlar 'cari-liste'den geliyordu (kopyala-yapistir
    //   kalintisi): listede lab isine ait tek dugme yoktu.
    aksiyonEkrani: 'lab-istem-liste',
    // GUNLUK EKRAN: acilista BUGUN. Banko gunun istemleriyle calisir;
    //   tum gecmisi birlikte gostermek listeyi kullanilamaz yapiyordu.
    //   STANDART TARIH KUTULARI (kullanici 28.10.2026): hazir aralik combosu
    //   yerine Doktor Bekleme / Basvuru / Radyoloji listeleriyle ayni iki kutu.
    tarihAlani: 'istemTarihi', tarihVarsayilan: 'bugun',
    // CIPLER = mockup lab_istem_numune_kabul.html arama seridi: bankonun
    //   sorusu "hangi tup bekliyor", "hangisi reddedildi". Sonuc asamalari
    //   (Calisiliyor / Sonuclandi / Onaylandi) Sonuclar ekraninin isi;
    //   burada ACIL ve DIS ISTEM one cikar - ikisi de siraya girmez.
    cipler: [
      { ad: 'Numune Bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kabul Edildi',    filtre: { alan: 'durum', op: 'buyukEsit', deger: 2 } },
      { ad: 'Ret',             filtre: { alan: 'retSayisi', op: 'buyuk', deger: 0 } },
      { ad: 'Acil',            filtre: { alan: 'oncelik', op: 'esit', deger: 3 } },
      { ad: 'Dış İstem',       filtre: { alan: 'disIstem', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    // AD + İKON (kullanıcı 27.10.2026): menü ve sekmede "Laboratuvar İstemi Listesi", ikon erlenmeyer (@erlen).
    menuGrup: 'Laboratuvar', menuAd: 'Laboratuvar İstemi Listesi', menuSira: 10,
    // Erlenmeyer (kullanıcı 27.10.2026; önce enjektör 💉): grup ikonu tüp (🧪), istem satırı ayrışıyor.
    ic: '@erlen', yetkiKodu: 'lab.liste',
  },
  {
    // NUMUNE KABUL (433): laboratuvarin giris kapisi. Varsayilan cip
    //   "Kabul Bekleyen": kabul edilmemis tup TAT saatini baslatmaz, ekran
    //   acilir acilmaz o kuyruk gorunmeli.
    kaynak: 'lab-numune', rota: 'lab-numune', baslik: 'Numune Kabul',
    yol: 'Laboratuvar › Numune Kabul',
    aksiyonEkrani: 'lab-numune-liste',
    tarihAlani: 'alimZamani',
    cipler: [
      { ad: 'Kabul Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Etiketlendi',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Kabul',          filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Reddedilen',     filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Numune Kabul', menuSira: 20,
    ic: '🩸', yetkiKodu: 'lab.numune',
  },
  {
    // SONUC ONAY KUYRUGU (433): panik ve delta uyarilari once gorunsun diye
    //   ayri cipler; oto-onaylanan temiz sonuclar kuyrukta hic beklemez.
    kaynak: 'lab-sonuc', rota: 'lab-sonuc', baslik: 'Sonuç Onay Kuyruğu',
    yol: 'Laboratuvar › Sonuç Listesi',
    aksiyonEkrani: 'lab-sonuc-liste',
    tarihAlani: 'olcumZamani',
    cipler: [
      { ad: 'Onay Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Panik',         filtre: { alan: 'panik', op: 'esit', deger: 1 } },
      { ad: 'Delta Uyarı',   filtre: { alan: 'deltaUyari', op: 'esit', deger: 1 } },
      // NUMUNE UYGUNSUZ (444): hemoliz/lipemi/ikter eşiğini aşan sonuçlar -
      //   uzman bakmadan yayınlanmazlar, kuyrukta ayrı görünmeliler.
      { ad: 'Numune Uygunsuz', filtre: { alan: 'indeksDurum', op: 'icinde', deger: [1, 2] } },
      { ad: 'Teknik Onay',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Onaylı',        filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Sonuç Listesi', menuSira: 30,
    ic: '📊', yetkiKodu: 'lab.sonuc',
  },
  {
    // TETKIK KATALOGU (433): referans araligi OLMAYAN tetkik bayrak
    //   uretemez - "Referans" kolonu bu eksigi listede gosterir.
    kaynak: 'lab-tetkik', rota: 'lab-tetkik', baslik: 'Tetkik Kataloğu',
    yol: 'Laboratuvar › Tetkik Kataloğu',
    kartYolu: '/lab-tetkik', kartBaslik: 'Tetkik',
    aksiyonEkrani: 'lab-tetkik-liste',
    cipler: [
      { ad: 'Aktif',    filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Oto Onay', filtre: { alan: 'otoOnay', op: 'esit', deger: 1 } },
      { ad: 'Pasif',    filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    // BOLUM SUZGECI + BOLUME GORE GRUPLAMA (492, mockup lab_tetkik_katalogu):
    //   katalog bolum bolum okunur - biyokimyaci kendi tetkiklerini arar.
    //   Gruplama baslangic degeridir; kullanici uc-nokta menusunden degistirir.
    kodSuzgeci: { alan: 'bolum', etiket: 'Tüm Bölümler' },
    varsayilanGrup: 'bolumAdi',
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Tetkik Kataloğu', menuSira: 200,
    ic: '📚', yetkiKodu: 'lab.tetkik.liste',
  },
  {
    // PANELLER (433): istemde tek kalemde acilan tetkik gruplari.
    kaynak: 'lab-panel', rota: 'lab-panel', baslik: 'Lab Paneli Listesi',
    yol: 'Laboratuvar › Panel Listesi',
    kartYolu: '/lab-panel', kartBaslik: 'Panel',
    aksiyonEkrani: 'lab-panel-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Panel Listesi', menuSira: 201,
    ic: '🧬', yetkiKodu: 'lab.tetkik.panel.liste',
  },
  {
    // PANİK DEĞERLER (894, KTS L2): açık panikler, en uzun bekleyen üstte.
    //   Panoda yalnız SAYI vardı; "hangisi, kaç dakikadır" görünmüyordu.
    //   Kayıt bildirimle değil OKUMA-GERİ teyidiyle kapanır.
    kaynak: 'lab-panik', rota: 'lab-panik', baslik: 'Panik Değer Listesi',
    yol: 'Laboratuvar › Panik Değer Listesi',
    aksiyonEkrani: 'lab-panik-liste',
    tarihAlani: 'olcumZamani',
    cipler: [
      { ad: 'Bildirilmedi', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Teyit bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Yükseltilen', filtre: { alan: 'yukseltme', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Panik Değer Listesi', menuSira: 30,
    ic: '\u{1F6A8}', yetkiKodu: 'lab.panik',
  },
  {
    // TEKRAR TALEPLERİ (891, KTS L8): "bu tetkiki tekrar çalışın" talebi
    //   artık elektronik. Kuyruk yalnız İPTAL edilir - "karşılandı"yı
    //   sistem yazar (aynı satıra yeni sonuç girilince); elle kapatma
    //   düğmesi, çalışılmadan kapatılmış talepler üretirdi.
    kaynak: 'lab-tekrar', rota: 'lab-tekrar', baslik: 'Tekrar Talebi Listesi',
    yol: 'Laboratuvar › Tekrar Talebi Listesi',
    aksiyonEkrani: 'lab-tekrar-liste',
    tarihAlani: 'istekZamani',
    cipler: [
      { ad: 'Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Yeni numune', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      { ad: 'Karşılanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'İptal', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Tekrar Talebi Listesi', menuSira: 35,
    ic: '\u{1F501}', yetkiKodu: 'lab.tekrar',
  },
  {
    // NUMUNE ARŞİVİ (890, KTS L13): "tüp nerede" ve "ne zamana kadar
    //   duracak". Özel sayfa, çünkü iş ızgara üzerinden yapılıyor -
    //   kutunun gözlerini satır/sütun olarak görmeden tüp yerleştirilemez;
    //   jenerik liste bunu çizemez.
    kaynak: 'lab-arsiv-pano', rota: 'lab-arsiv', ozelSayfa: true,
    baslik: 'Numune Arşivi', yol: 'Laboratuvar › Numune Arşivi',
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Numune Arşivi', menuSira: 40,
    ic: '\u{1F9CA}', yetkiKodu: 'lab.arsiv',
  },
  {
    // ARŞİV KAYITLARI (890): arşivdekiler + ÇIKMIŞ/İMHA edilmişler. Pano
    //   "şu an nerede" der; bu liste "hangi tüp ne zaman çıkarıldı, kim
    //   imha etti" sorusunun - denetimde sorulanın - cevabıdır.
    kaynak: 'lab-arsiv', rota: 'lab-arsiv-kayit', baslik: 'Arşiv Kaydı Listesi',
    yol: 'Laboratuvar › Arşiv Kaydı Listesi',
    tarihAlani: 'girisZamani',
    cipler: [
      { ad: 'Arşivde', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Süresi dolan', filtre: { alan: 'kalanGun', op: 'kucukEsit', deger: 0 } },
      { ad: 'Çıkarılan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'İmha edilen', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Arşiv Kaydı Listesi', menuSira: 41,
    ic: '\u{1F4E6}', yetkiKodu: 'lab.arsiv.kayit',
  },
  {
    // ARŞİV KONUMLARI (890): ünite > raf > kutu. Izgara (satır × sütun)
    //   yalnız kutuda anlamlı - kart bunu söylüyor, veritabanı da tutuyor.
    kaynak: 'lab-arsiv-konum', rota: 'lab-arsiv-konum', baslik: 'Arşiv Konumu Listesi',
    yol: 'Laboratuvar › Ayarlar › Arşiv Konumu Listesi',
    kartYolu: '/lab-arsiv-konum', kartBaslik: 'Arşiv konumu',
    cipler: [
      { ad: 'Kutular', filtre: { alan: 'tur', op: 'esit', deger: 3 } },
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Arşiv Konumu Listesi',
    menuSira: 204,
    ic: '\u{1F5C4}', yetkiKodu: 'lab.arsiv_konum.liste',
  },
  {
    // SAKLAMA SÜRELERİ (890): imha hedefi buradan hesaplanır. Politika
    //   yoksa süre yazılmaz - uydurulmuş bir tarih, saklanması gereken
    //   numuneyi erken imha ettirirdi.
    kaynak: 'lab-saklama-politika', rota: 'lab-saklama-politika',
    baslik: 'Numune Saklama Süresi Listesi',
    yol: 'Laboratuvar › Ayarlar › Saklama Süresi Listesi',
    kartYolu: '/lab-saklama-politika', kartBaslik: 'Saklama süresi',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Saklama Süresi Listesi',
    menuSira: 205,
    ic: '⏳', yetkiKodu: 'lab.saklama_politika.liste',
  },
  {
    // NUMUNE RET KRİTERLERİ (879, KTS L6): laboratuvar kendi kabul/ret
    //   ölçütlerini tanımlar. Kod uzayı 433 ile aynı - geçmiş numunelerin
    //   ret nedeni bu satırlara bağlı, kod değiştirilmez.
    kaynak: 'lab-ret-nedeni', rota: 'lab-ret-nedeni', baslik: 'Numune Ret Kriteri Listesi',
    yol: 'Laboratuvar › Ayarlar › Numune Ret Kriteri Listesi',
    kartYolu: '/lab-ret-nedeni', kartBaslik: 'Ret kriteri',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Hastaya mesaj', filtre: { alan: 'hastaBilgilendir', op: 'esit', deger: 1 } },
      { ad: 'Kabulde de seçilir', filtre: { alan: 'kabuldeSecilebilir', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Numune Ret Kriteri Listesi',
    menuSira: 203,
    ic: '\u26D4', yetkiKodu: 'lab.ret_nedeni.liste',
  },
  {
    // AKILCI TEST İSTEM KURALLARI (873): Bakanlık listesi + SKRS süresi; kurum düzeltir.
    kaynak: 'lab-akilci-kural', rota: 'lab-akilci-kural', baslik: 'Akılcı İstem Kuralı Listesi',
    yol: 'Laboratuvar › Ayarlar › Akılcı İstem Kuralı Listesi',
    kartYolu: '/lab-akilci-kural', kartBaslik: 'Akılcı istem kuralı',
    aksiyonEkrani: 'lab-akilci-kural-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Süre kısıtlı', filtre: { alan: 'sureGun', op: 'buyuk', deger: 0 } },
      { ad: 'Branş kısıtlı', filtre: { alan: 'tumBranslar', op: 'esit', deger: 0 } },
      { ad: 'Yalnız 3. basamak', filtre: { alan: 'basamak', op: 'esit', deger: 3 } },
      { ad: 'Refleks', filtre: { alan: 'refleks', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Akılcı İstem Kuralı Listesi', menuSira: 202,
    ic: '📏', yetkiKodu: 'lab.tetkik.akilci_kural.liste',
  },
  {
    // REFLEKS TEST KURALLARI (873 §6): eşik aşılınca ikincil tetkik otomatik eklenir.
    kaynak: 'lab-refleks-kural', rota: 'lab-refleks-kural', baslik: 'Refleks Test Kuralı Listesi',
    yol: 'Laboratuvar › Ayarlar › Refleks Test Kuralı Listesi',
    kartYolu: '/lab-refleks-kural', kartBaslik: 'Refleks kuralı',
    aksiyonEkrani: 'lab-refleks-kural-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Refleks Test Kuralı Listesi', menuSira: 203,
    ic: '🔁', yetkiKodu: 'lab.tetkik.refleks_kural.liste',
  },
  {
    // AKILCI İSTEM KARARLARI (873): hekim gerekçeleri / vazgeçmeler / refleks-reflektif izi.
    kaynak: 'lab-akilci-gerekce', rota: 'lab-akilci-gerekce', baslik: 'Akılcı İstem Kararı Listesi',
    yol: 'Laboratuvar › Akılcı İstem Kararı Listesi',
    aksiyonEkrani: 'lab-akilci-gerekce-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Gerekçeli devam', filtre: { alan: 'karar', op: 'esit', deger: 'devam' } },
      { ad: 'Vazgeçme', filtre: { alan: 'karar', op: 'esit', deger: 'iptal' } },
      { ad: 'Refleks', filtre: { alan: 'kuralTuru', op: 'esit', deger: 'refleks' } },
      { ad: 'Reflektif', filtre: { alan: 'kuralTuru', op: 'esit', deger: 'reflektif' } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Akılcı İstem Kararı Listesi', menuSira: 35,
    ic: '📋', yetkiKodu: 'lab.akilci_karar',
  },
  {
    // KULTUR CALISMA LISTESI (436) - mikrobiyolojinin gunluk ekrani.
    //   Varsayilan cip "Okuma Zamani Geldi": 24 saatlik plakayi 3. gunde
    //   okumak negatif raporu guvenilmez yapar, gecikme once gorunmeli.
    kaynak: 'lab-kultur', rota: 'lab-kultur', baslik: 'Kültür Çalışma Listesi',
    yol: 'Laboratuvar › Mikrobiyoloji › Kültür Çalışma Listesi',
    aksiyonEkrani: 'lab-kultur-liste',
    tarihAlani: 'ekimZamani',
    cipler: [
      // VARSAYILAN "Açık Kültürler": ekran acilir acilmaz masadaki isi
      //   gostermeli. "Okuma Zamani Geldi" cipi dogru ama cogu saat bos
      //   doner - ilk acilista bos liste, ekrani calismiyor gosterir.
      { ad: 'Açık Kültürler', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3, 4, 5, 6] } },
      { ad: 'Okuma Zamanı Geldi', filtre: { alan: 'okumaGecikmeDk', op: 'buyukEsit', deger: 0 } },
      { ad: 'İnkübasyon',   filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Üreme',        filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Antibiyogram', filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Rapor Bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Kritik',       filtre: { alan: 'kritik', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Mikrobiyoloji', menuAd: 'Kültür Çalışma Listesi', menuSira: 110,
    ic: '🦠', yetkiKodu: 'lab.kultur',
  },
  {
    // GENETIK VAKA LISTESI (439) - laboratuvarin gunluk ekrani.
    //   Varsayilan cip "Acik Vakalar": onaylanmis vaka masada is degildir.
    kaynak: 'lab-genetik-vaka', rota: 'lab-genetik-vaka',
    baslik: 'Genetik Vaka Listesi', yol: 'Laboratuvar › Genetik › Vaka Listesi',
    aksiyonEkrani: 'lab-genetik-liste',
    tarihAlani: 'eklemeTarihi',
    cipler: [
      { ad: 'Açık Vakalar', filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3, 4, 5, 6] } },
      // ONAM EKSIK ayri cip: rapor asamasina gelmis vakanin haftalarca
      //   suren isi, onam eksikligi yuzunden bekler.
      { ad: 'Onam Eksik',   filtre: { alan: 'tesadufiBulgu', op: 'esit', deger: 0 } },
      { ad: 'Analiz',       filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Doğrulama',    filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Rapor Bekliyor', filtre: { alan: 'durum', op: 'esit', deger: 6 } },
      { ad: 'Onaylı',       filtre: { alan: 'durum', op: 'esit', deger: 7 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Vaka Listesi', menuSira: 120,
    ic: '🧬', yetkiKodu: 'lab.genetik',
  },
  {
    // VARYANT HAVUZU (439): ACMG kanitlari ve sinif birlikte durur -
    //   "neden patojenik" sorusu listeden cevaplanir.
    kaynak: 'lab-varyant', rota: 'lab-varyant', baslik: 'Varyant Listesi',
    yol: 'Laboratuvar › Genetik › Varyant Listesi',
    aksiyonEkrani: 'lab-varyant-liste',
    cipler: [
      { ad: 'Raporlanan', filtre: { alan: 'raporla', op: 'esit', deger: 1 } },
      { ad: 'Patojenik',  filtre: { alan: 'sinif', op: 'icinde', deger: [4, 5] } },
      { ad: 'VUS',        filtre: { alan: 'sinif', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Varyant Listesi', menuSira: 121,
    ic: '🔬', yetkiKodu: 'lab.genetik.varyant',
  },
  {
    // DIZILEME RUN'LARI (439): kontroller gecmediyse run raporlanamaz.
    kaynak: 'lab-genetik-run', rota: 'lab-genetik-run', baslik: 'Dizileme Run Listesi',
    yol: 'Laboratuvar › Genetik › Dizileme Run Listesi',
    aksiyonEkrani: 'lab-genetik-run-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3] } },
      { ad: 'Tamamlanan',  filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Dizileme Run Listesi', menuSira: 122,
    ic: '📚', yetkiKodu: 'lab.genetik.run',
  },
  {
    // KK OLCUMLERI (442) - laboratuvarin gunluk kontrol defteri.
    //   Varsayilan cip "Ret / Uyari": kapatilmamis ret once gorunmeli,
    //   cunku o testin hasta sonuclari oto-onaya girmiyor.
    kaynak: 'lab-kk-olcum', rota: 'lab-kk-olcum', baslik: 'Kalite Kontrol (İKK)',
    yol: 'Laboratuvar › Biyokimya › Kalite Kontrol',
    aksiyonEkrani: 'lab-kk-liste',
    tarihAlani: 'olcumZamani',
    cipler: [
      { ad: 'Ret / Uyarı', filtre: { alan: 'durum', op: 'icinde', deger: [2, 3] } },
      { ad: 'Ret',         filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      { ad: 'Kabul',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Kalite Kontrol', menuSira: 100,
    ic: '📉', yetkiKodu: 'lab.kk',
  },
  {
    // DIS KALITE (442): donem bazli, SDI ile degerlendirilir.
    kaynak: 'lab-dkk', rota: 'lab-dkk', baslik: 'Dış Kalite (DKK)',
    yol: 'Laboratuvar › Biyokimya › Dış Kalite',
    kartYolu: '/lab-dkk', kartBaslik: 'DKK Sonucu',
    aksiyonEkrani: 'lab-dkk-liste',
    cipler: [
      { ad: 'Uyarı / Red', filtre: { alan: 'degerlendirme', op: 'icinde', deger: [2, 3] } },
      { ad: 'Kabul',       filtre: { alan: 'degerlendirme', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Dış Kalite', menuSira: 102,
    ic: '🌍', yetkiKodu: 'lab.kk.dkk.liste',
  },
  {
    // KONTROL LOTLARI (442): hedef/SD lot basinadir, kart detayinda.
    kaynak: 'lab-kk-lot', rota: 'lab-kk-lot', baslik: 'Kontrol Lotu Listesi',
    yol: 'Laboratuvar › Biyokimya › Kontrol Lotu Listesi',
    kartYolu: '/lab-kk-lot', kartBaslik: 'Kontrol Lotu',
    aksiyonEkrani: 'lab-kk-lot-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Kontrol Lotu Listesi', menuSira: 101,
    ic: '🧴', yetkiKodu: 'lab.kk.lot.liste',
  },
  {
    // DIS LAB GONDERIMLERI (445) - numune binadan cikinca elimizdeki tek iz.
    //   Varsayilan cip "Acik": sonucu bekleyen gonderim masadaki istir.
    kaynak: 'lab-dis-gonderim', rota: 'lab-dis-gonderim',
    baslik: 'Dış Lab Gönderimi Listesi', yol: 'Laboratuvar › Dış Lab Gönderimi Listesi',
    aksiyonEkrani: 'lab-dis-gonderim-liste',
    tarihAlani: 'gonderimZamani',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3, 4] } },
      { ad: 'Hazırlanıyor',filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Yolda',       filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Sonuçlandı',  filtre: { alan: 'durum', op: 'esit', deger: 5 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAd: 'Dış Lab Gönderimi Listesi', menuSira: 40,
    // Kurye motoru (kullanici): numune kutusu degil, YOLDAKI numune anlatiliyor.
    ic: '🏍️', yetkiKodu: 'lab.dislab',
  },
  {
    // DIS LABORATUVARLAR (445): cari bagi + anlasmali test listesi kartta.
    kaynak: 'lab-dis-lab', rota: 'lab-dis-lab', baslik: 'Dış Laboratuvar Listesi',
    yol: 'Laboratuvar › Dış Laboratuvar Listesi',
    kartYolu: '/lab-dis-lab', kartBaslik: 'Dış Laboratuvar',
    aksiyonEkrani: 'lab-dis-lab-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Dış Laboratuvar Listesi', menuSira: 210,
    ic: '🏥', yetkiKodu: 'lab.dislab.tanim.liste',
  },
  {
    // SERUM INDEKSI ESIKLERI (444): test bazli HIL sinirlari. Potasyum
    //   hemolizden 20 indekste etkilenir, sodyum 200'de bile etkilenmez.
    kaynak: 'lab-indeks-esik', rota: 'lab-indeks-esik',
    baslik: 'Serum İndeksi Eşiki Listesi', yol: 'Laboratuvar › Biyokimya › Serum İndeksi',
    kartYolu: '/lab-indeks-esik', kartBaslik: 'Serum İndeksi Eşiği',
    aksiyonEkrani: 'lab-indeks-esik-liste',
    cipler: [
      { ad: 'Hemoliz', filtre: { alan: 'indeks', op: 'esit', deger: 1 } },
      { ad: 'Lipemi',  filtre: { alan: 'indeks', op: 'esit', deger: 2 } },
      { ad: 'İkter',   filtre: { alan: 'indeks', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Serum İndeksi', menuSira: 202,
    ic: '🩸', yetkiKodu: 'lab.tetkik.indeks.liste',
  },
  {
    // WESTGARD KURAL SETI (442): tetkik bos = varsayilan set.
    kaynak: 'lab-kk-kural', rota: 'lab-kk-kural', baslik: 'Westgard Kuralı Listesi',
    yol: 'Laboratuvar › Biyokimya › Westgard Kuralı Listesi',
    kartYolu: '/lab-kk-kural', kartBaslik: 'Westgard Kuralı',
    aksiyonEkrani: 'lab-kk-kural-liste',
    cipler: [
      { ad: 'Ret Kuralları', filtre: { alan: 'davranis', op: 'esit', deger: 2 } },
      { ad: 'Uyarı',         filtre: { alan: 'davranis', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Westgard Kuralı Listesi', menuSira: 203,
    ic: '⚙️', yetkiKodu: 'lab.kk.kural.liste',
  },
  {
    // CIHAZ OLAYLARI (442): LJ'deki kaymanin nedeni cogu zaman burada.
    kaynak: 'lab-cihaz-olay', rota: 'lab-cihaz-olay', baslik: 'Cihaz Olayı Listesi',
    yol: 'Laboratuvar › Biyokimya › Cihaz Olayı Listesi',
    kartYolu: '/lab-cihaz-olay', kartBaslik: 'Cihaz Olayı',
    aksiyonEkrani: 'lab-cihaz-olay-liste',
    tarihAlani: 'zaman',
    cipler: [
      { ad: 'Kalibrasyon', filtre: { alan: 'olay', op: 'esit', deger: 1 } },
      { ad: 'Reaktif Lot', filtre: { alan: 'olay', op: 'esit', deger: 3 } },
      { ad: 'Arıza',       filtre: { alan: 'olay', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Cihaz Olayı Listesi', menuSira: 105,
    ic: '🔧', yetkiKodu: 'lab.kk.cihaz_olay.liste',
  },
  {
    // GEN KATALOGU (439): transkript zorunlu - HGVS gosterimi ona goredir.
    kaynak: 'lab-gen', rota: 'lab-gen', baslik: 'Gen Kataloğu',
    yol: 'Laboratuvar › Genetik › Gen Listesi',
    kartYolu: '/lab-gen', kartBaslik: 'Gen',
    aksiyonEkrani: 'lab-gen-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Gen Listesi', menuSira: 208,
    ic: '🧬', yetkiKodu: 'lab.gen.liste',
  },
  {
    // GENETIK PANEL KATALOGU (439): gen listesi raporun ekidir.
    kaynak: 'lab-genetik-panel', rota: 'lab-genetik-panel',
    baslik: 'Genetik Paneli Listesi', yol: 'Laboratuvar › Genetik › Genetik Paneli Listesi',
    kartYolu: '/lab-genetik-panel', kartBaslik: 'Genetik Paneli',
    aksiyonEkrani: 'lab-genetik-panel-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Genetik Paneli Listesi', menuSira: 209,
    ic: '🗂️', yetkiKodu: 'lab.gen.panel.liste',
  },
  {
    // ORGANIZMA KATALOGU (436): rapor ve direnc surveyansi buna dayanir.
    kaynak: 'lab-organizma', rota: 'lab-organizma', baslik: 'Organizma Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Organizma Listesi',
    kartYolu: '/lab-organizma', kartBaslik: 'Organizma',
    aksiyonEkrani: 'lab-organizma-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Bildirimi Zorunlu', filtre: { alan: 'bildirimiZorunlu', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Organizma Listesi', menuSira: 205,
    ic: '🧫', yetkiKodu: 'lab.mikro.liste',
  },
  {
    // ANTIBIYOTIK KATALOGU (436): "basamak" kademeli bildirimi yonetir.
    kaynak: 'lab-antibiyotik', rota: 'lab-antibiyotik', baslik: 'Antibiyotik Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Antibiyotik Listesi',
    kartYolu: '/lab-antibiyotik', kartBaslik: 'Antibiyotik',
    aksiyonEkrani: 'lab-antibiyotik-liste',
    cipler: [
      { ad: '1. Basamak', filtre: { alan: 'basamak', op: 'esit', deger: 1 } },
      { ad: '2. Basamak', filtre: { alan: 'basamak', op: 'esit', deger: 2 } },
      { ad: 'Kısıtlı',    filtre: { alan: 'basamak', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Antibiyotik Listesi', menuSira: 206,
    ic: '💊', yetkiKodu: 'lab.mikro.antibiyotik.liste',
  },
  {
    // BESIYERI KATALOGU (436): okuma plani buradaki saatlerden kurulur.
    kaynak: 'lab-besiyeri', rota: 'lab-besiyeri', baslik: 'Besiyeri Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Besiyeri Listesi',
    kartYolu: '/lab-besiyeri', kartBaslik: 'Besiyeri',
    aksiyonEkrani: 'lab-besiyeri-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Besiyeri Listesi', menuSira: 207,
    ic: '🧪', yetkiKodu: 'lab.mikro.besiyeri.liste',
  },
  {
    // CIHAZ TEST ESLEME (434): kayit YALNIZ cihaz kodu tetkik kodundan
    //   farkliysa gerekir; listenin bos olmasi normaldir.
    kaynak: 'lab-cihaz-esleme', rota: 'lab-cihaz-esleme',
    baslik: 'Cihaz Test Eşleme',
    yol: 'Laboratuvar › Biyokimya › Cihaz Eşleme',
    kartYolu: '/lab-cihaz-esleme', kartBaslik: 'Cihaz Test Eşlemesi',
    aksiyonEkrani: 'lab-cihaz-esleme-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Cihaz Eşleme', menuSira: 204,
    ic: '🔌', yetkiKodu: 'lab.cihaz.liste',
  },
  {
    // LABORATUVAR İCMALİ (1026, mockup İcmal/laboratuvar_icmali.html): tetkik
    //   adet / ciro / reaktif maliyeti / marj, cihaz, dış lab, TAT, numune ret.
    kaynak: 'lab-icmal', rota: 'lab-icmal', ozelSayfa: true,
    baslik: 'Laboratuvar İcmali', yol: 'Laboratuvar › Laboratuvar İcmali',
    menuGrup: 'Laboratuvar', menuAd: 'Laboratuvar İcmali', ic: '@icmal',
    yetkiKodu: 'lab.icmal', menuSira: 45, urunModu: 2, modul: 'lab',
  },
];
