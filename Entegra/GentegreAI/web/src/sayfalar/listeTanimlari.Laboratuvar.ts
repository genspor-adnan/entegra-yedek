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
    kaynak: 'lab-istem', rota: 'lab-istem', baslik: 'Laboratuvar İstemleri',
    yol: 'Laboratuvar › İstemler',
    kartYolu: '/lab-istem', kartBaslik: 'Laboratuvar İstemi',
    // 433'e kadar aksiyonlar 'cari-liste'den geliyordu (kopyala-yapistir
    //   kalintisi): listede lab isine ait tek dugme yoktu.
    aksiyonEkrani: 'lab-istem-liste',
    // GUNLUK EKRAN: iki tarih kutusu yerine hazir aralik combosu
    //   (kullanici) - acilista BUGUN. Banko gunun istemleriyle calisir;
    //   tum gecmisi birlikte gostermek listeyi kullanilamaz yapiyordu.
    tarihAlani: 'istemTarihi', tarihCombo: true,
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
    menuGrup: 'Laboratuvar', menuAd: 'İstemler', menuSira: 10,
    // Enjektor (kullanici): grup ikonu zaten tup (🧪), istem satiri ayrisiyor.
    ic: '💉', yetkiKodu: 'lab',
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
    yol: 'Laboratuvar › Sonuçlar',
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
    menuGrup: 'Laboratuvar', menuAd: 'Sonuçlar', menuSira: 30,
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
    ic: '📚', yetkiKodu: 'lab.tetkik',
  },
  {
    // PANELLER (433): istemde tek kalemde acilan tetkik gruplari.
    kaynak: 'lab-panel', rota: 'lab-panel', baslik: 'Lab Panelleri',
    yol: 'Laboratuvar › Paneller',
    kartYolu: '/lab-panel', kartBaslik: 'Panel',
    aksiyonEkrani: 'lab-panel-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Paneller', menuSira: 201,
    ic: '🧬', yetkiKodu: 'lab.tetkik',
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
    baslik: 'Genetik Vakalar', yol: 'Laboratuvar › Genetik › Vakalar',
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
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Vakalar', menuSira: 120,
    ic: '🧬', yetkiKodu: 'lab.genetik',
  },
  {
    // VARYANT HAVUZU (439): ACMG kanitlari ve sinif birlikte durur -
    //   "neden patojenik" sorusu listeden cevaplanir.
    kaynak: 'lab-varyant', rota: 'lab-varyant', baslik: 'Varyantlar',
    yol: 'Laboratuvar › Genetik › Varyantlar',
    aksiyonEkrani: 'lab-varyant-liste',
    cipler: [
      { ad: 'Raporlanan', filtre: { alan: 'raporla', op: 'esit', deger: 1 } },
      { ad: 'Patojenik',  filtre: { alan: 'sinif', op: 'icinde', deger: [4, 5] } },
      { ad: 'VUS',        filtre: { alan: 'sinif', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Varyantlar', menuSira: 121,
    ic: '🔬', yetkiKodu: 'lab.genetik',
  },
  {
    // DIZILEME RUN'LARI (439): kontroller gecmediyse run raporlanamaz.
    kaynak: 'lab-genetik-run', rota: 'lab-genetik-run', baslik: 'Dizileme Runları',
    yol: 'Laboratuvar › Genetik › Dizileme Runları',
    aksiyonEkrani: 'lab-genetik-run-liste',
    tarihAlani: 'tarih',
    cipler: [
      { ad: 'Açık',        filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3] } },
      { ad: 'Tamamlanan',  filtre: { alan: 'durum', op: 'esit', deger: 4 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Genetik', menuAd: 'Dizileme Runları', menuSira: 122,
    ic: '📚', yetkiKodu: 'lab.genetik',
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
    ic: '🌍', yetkiKodu: 'lab.kk',
  },
  {
    // KONTROL LOTLARI (442): hedef/SD lot basinadir, kart detayinda.
    kaynak: 'lab-kk-lot', rota: 'lab-kk-lot', baslik: 'Kontrol Lotları',
    yol: 'Laboratuvar › Biyokimya › Kontrol Lotları',
    kartYolu: '/lab-kk-lot', kartBaslik: 'Kontrol Lotu',
    aksiyonEkrani: 'lab-kk-lot-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Kontrol Lotları', menuSira: 101,
    ic: '🧴', yetkiKodu: 'lab.kk',
  },
  {
    // DIS LAB GONDERIMLERI (445) - numune binadan cikinca elimizdeki tek iz.
    //   Varsayilan cip "Acik": sonucu bekleyen gonderim masadaki istir.
    kaynak: 'lab-dis-gonderim', rota: 'lab-dis-gonderim',
    baslik: 'Dış Lab Gönderimleri', yol: 'Laboratuvar › Dış Lab Gönderimleri',
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
    menuGrup: 'Laboratuvar', menuAd: 'Dış Lab Gönderimleri', menuSira: 40,
    // Kurye motoru (kullanici): numune kutusu degil, YOLDAKI numune anlatiliyor.
    ic: '🏍️', yetkiKodu: 'lab.dislab',
  },
  {
    // DIS LABORATUVARLAR (445): cari bagi + anlasmali test listesi kartta.
    kaynak: 'lab-dis-lab', rota: 'lab-dis-lab', baslik: 'Dış Laboratuvarlar',
    yol: 'Laboratuvar › Dış Laboratuvarlar',
    kartYolu: '/lab-dis-lab', kartBaslik: 'Dış Laboratuvar',
    aksiyonEkrani: 'lab-dis-lab-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Dış Laboratuvarlar', menuSira: 210,
    ic: '🏥', yetkiKodu: 'lab.dislab',
  },
  {
    // SERUM INDEKSI ESIKLERI (444): test bazli HIL sinirlari. Potasyum
    //   hemolizden 20 indekste etkilenir, sodyum 200'de bile etkilenmez.
    kaynak: 'lab-indeks-esik', rota: 'lab-indeks-esik',
    baslik: 'Serum İndeksi Eşikleri', yol: 'Laboratuvar › Biyokimya › Serum İndeksi',
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
    ic: '🩸', yetkiKodu: 'lab.tetkik',
  },
  {
    // WESTGARD KURAL SETI (442): tetkik bos = varsayilan set.
    kaynak: 'lab-kk-kural', rota: 'lab-kk-kural', baslik: 'Westgard Kuralları',
    yol: 'Laboratuvar › Biyokimya › Westgard Kuralları',
    kartYolu: '/lab-kk-kural', kartBaslik: 'Westgard Kuralı',
    aksiyonEkrani: 'lab-kk-kural-liste',
    cipler: [
      { ad: 'Ret Kuralları', filtre: { alan: 'davranis', op: 'esit', deger: 2 } },
      { ad: 'Uyarı',         filtre: { alan: 'davranis', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Westgard Kuralları', menuSira: 203,
    ic: '⚙️', yetkiKodu: 'lab.kk',
  },
  {
    // CIHAZ OLAYLARI (442): LJ'deki kaymanin nedeni cogu zaman burada.
    kaynak: 'lab-cihaz-olay', rota: 'lab-cihaz-olay', baslik: 'Cihaz Olayları',
    yol: 'Laboratuvar › Biyokimya › Cihaz Olayları',
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
    menuGrup: 'Laboratuvar', menuAltGrup: 'Biyokimya', menuAd: 'Cihaz Olayları', menuSira: 105,
    ic: '🔧', yetkiKodu: 'lab.kk',
  },
  {
    // GEN KATALOGU (439): transkript zorunlu - HGVS gosterimi ona goredir.
    kaynak: 'lab-gen', rota: 'lab-gen', baslik: 'Gen Kataloğu',
    yol: 'Laboratuvar › Genetik › Genler',
    kartYolu: '/lab-gen', kartBaslik: 'Gen',
    aksiyonEkrani: 'lab-gen-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Genler', menuSira: 208,
    ic: '🧬', yetkiKodu: 'lab.gen',
  },
  {
    // GENETIK PANEL KATALOGU (439): gen listesi raporun ekidir.
    kaynak: 'lab-genetik-panel', rota: 'lab-genetik-panel',
    baslik: 'Genetik Panelleri', yol: 'Laboratuvar › Genetik › Genetik Panelleri',
    kartYolu: '/lab-genetik-panel', kartBaslik: 'Genetik Paneli',
    aksiyonEkrani: 'lab-genetik-panel-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Genetik Panelleri', menuSira: 209,
    ic: '🗂️', yetkiKodu: 'lab.gen',
  },
  {
    // ORGANIZMA KATALOGU (436): rapor ve direnc surveyansi buna dayanir.
    kaynak: 'lab-organizma', rota: 'lab-organizma', baslik: 'Organizma Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Organizmalar',
    kartYolu: '/lab-organizma', kartBaslik: 'Organizma',
    aksiyonEkrani: 'lab-organizma-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Bildirimi Zorunlu', filtre: { alan: 'bildirimiZorunlu', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Organizmalar', menuSira: 205,
    ic: '🧫', yetkiKodu: 'lab.mikro',
  },
  {
    // ANTIBIYOTIK KATALOGU (436): "basamak" kademeli bildirimi yonetir.
    kaynak: 'lab-antibiyotik', rota: 'lab-antibiyotik', baslik: 'Antibiyotik Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Antibiyotikler',
    kartYolu: '/lab-antibiyotik', kartBaslik: 'Antibiyotik',
    aksiyonEkrani: 'lab-antibiyotik-liste',
    cipler: [
      { ad: '1. Basamak', filtre: { alan: 'basamak', op: 'esit', deger: 1 } },
      { ad: '2. Basamak', filtre: { alan: 'basamak', op: 'esit', deger: 2 } },
      { ad: 'Kısıtlı',    filtre: { alan: 'basamak', op: 'esit', deger: 3 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Antibiyotikler', menuSira: 206,
    ic: '💊', yetkiKodu: 'lab.mikro',
  },
  {
    // BESIYERI KATALOGU (436): okuma plani buradaki saatlerden kurulur.
    kaynak: 'lab-besiyeri', rota: 'lab-besiyeri', baslik: 'Besiyeri Kataloğu',
    yol: 'Laboratuvar › Mikrobiyoloji › Besiyerleri',
    kartYolu: '/lab-besiyeri', kartBaslik: 'Besiyeri',
    aksiyonEkrani: 'lab-besiyeri-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tümü' },
    ],
    urunModu: 2, modul: 'lab',
    menuGrup: 'Laboratuvar', menuAltGrup: 'Ayarlar', menuAd: 'Besiyerleri', menuSira: 207,
    ic: '🧪', yetkiKodu: 'lab.mikro',
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
    ic: '🔌', yetkiKodu: 'lab.cihaz',
  },
];
