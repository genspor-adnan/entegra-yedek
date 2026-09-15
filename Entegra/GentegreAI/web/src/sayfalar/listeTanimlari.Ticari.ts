import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Satış, alış, kasa ve banka listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
export const TICARI_LISTELERI: ListeGirdisi[] = [
  {
    // SATIS TEKLIFI (216, Ekranlar/teklif_listesi.html): belge turu 18 -
    //   stok/cari/fis ETKILEMEZ, kalem/toplam altyapisi belgeden. Mockup'taki
    //   revizyon/onay akisi ileride; ilk surum ekle/ac/sil.
    kaynak: 'belge', rota: 'teklif', baslik: 'Satış Teklifleri', yol: 'Satis › Satış Teklifleri',
    aksiyonEkrani: 'teklif-liste', yeniBelgeTuru: 18,
    // Teklif yalniz Gentegre AI (ERP) modunda (kullanici).
    urunModu: 1,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 18 },
    // e-Fatura/kapanma teklif icin anlamsiz.
    // 'kaynak' teklifte anlamsiz (zincirin BASI); belge durum rozeti (Pasif)
    //   yerine teklif akisinin "Durumu" kolonu gosterilir (kullanici).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'kapanmaAdi', 'kapanmaDurum',
                    'kaynak', 'durumAdi', 'durum', 'tipi', 'belgeSeri', 'tarafId'],
    // Sira (kullanici): Satış Temsilcisi | Durumu | Belge No en solda.
    //   kolonSirasi ayni zamanda ZORUNLU gorunurluk: kayitli kolon secimi
    //   'belge' kaynagini fatura/siparis listeleriyle paylasiyor - Durumu ve
    //   Temsilci onsuz hic cikmazdi.
    kolonSirasi: ['saticiAdi', 'teklifKonusu', 'teklifDurumAdi', 'belgeNo', 'belgeTarihi', 'tarafUnvan'],
    toplam: ['genelToplam'],
    // Durum cipleri (kullanici): arama editinin altinda Tumu + teklif akisi.
    cipler: [
      { ad: 'Tümü' },
      { ad: 'Hazırlanıyor', filtre: { alan: 'teklifDurum', op: 'esit', deger: 1 } },
      { ad: 'Sunuldu',      filtre: { alan: 'teklifDurum', op: 'esit', deger: 2 } },
      { ad: 'Kabul',        filtre: { alan: 'teklifDurum', op: 'esit', deger: 3 } },
      { ad: 'Red',          filtre: { alan: 'teklifDurum', op: 'esit', deger: 4 } },
      { ad: 'İptal',        filtre: { alan: 'teklifDurum', op: 'esit', deger: 5 } },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Teklifleri', ic: '📄', yetkiKodu: 'belge', menuSira: 10,
  },
  {
    // Siparisler AYNI 'belge' kaynagi, tur in (9,19) sabit filtresiyle (Musteri/
    //   Tedarikci deseni). "Kalan" takibi belge_satir.kapatilan_miktar uzerinden;
    //   "Dönüştür" aksiyonu secili siparisten irsaliye/fatura uretir (F8).
    // GenoTIP'te bu liste GORUNMEZ: ayni tur orada "Başvurular" ekraniyla
    //   yonetilir (279) - iki menu ayni belgeleri iki adla gostermesin.
    kaynak: 'belge', rota: 'siparis', baslik: 'Satış Siparişleri', yol: 'Satis › Satış Siparişleri',
    aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 19, urunModu: 1,
    // Menude "Satis Siparisleri" seciliyse liste de yalniz SATIS siparisi (19)
    //   gostersin; tur kolonlari o yuzden gereksiz (alis siparisi ayri ekran).
    sabitFiltre: { op: 'and', kosullar: [
      { alan: 'tur', op: 'esit', deger: 19 },
      // Hasta basvurulari (tipi 30) ERP siparis listesinde GORUNMEZ (301).
      { alan: 'tipi', op: 'esitDegil', deger: 30 },
    ] },
    // e-Fatura durumu SIPARISTE anlamsiz (siparis e-Belge degil).
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuSira: 20, menuAd: 'Satış Siparişleri', ic: '📋', yetkiKodu: 'belge',
  },
  {
    // Satis irsaliyeleri (Ekranlar/satis_irsaliye_listesi.html): AYRI kaynak
    //   ('irsaliye') - sevkiyat odakli kolonlar (arac/sofor, cikis deposu,
    //   kaynak siparis, faturalama durumu). Ekran satisa daraltir (tur=14).
    kaynak: 'irsaliye', rota: 'satis-irsaliye', baslik: 'Satış İrsaliyeleri',
    yol: 'Satis › Irsaliyeler', aksiyonEkrani: 'irsaliye-liste',
    ebelgeMenusu: 'E-İrsaliye',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 14 },
    yeniBelgeTuru: 14,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuSira: 30, menuAd: 'Satış İrsaliyeleri', ic: '🚚', yetkiKodu: 'belge',
  },
  {
    // "Satış" grubu, Cari'nin HEMEN ALTINDA (kullanici istegi) - "Belgeler" ayni kaynak/
    // ekran, sadece grup+menu adi degisti (filtre/kapsam AYNI - hala hem satis hem alis
    // faturalarini gosterir, cip'lerle (Tumu/Satis/Alis) secilir; "kopyala" DENMEDI).
    // Menude "Satis Faturalari" seciliyken liste de YALNIZ satis faturasi
    //   gostermeli (irsaliye/alis karisinca kullanici hangi ekranda oldugunu
    //   kaybediyordu) ve baslik menu adiyla ayni olmali.
    kaynak: 'belge', baslik: 'Satış Faturaları', yol: 'Satis › Satış Faturaları',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 15, ebelgeMenusu: 'E-Fatura',
    // Tur / Belge Turu kolonlari bu ekranda ayni degeri tekrarliyor (hepsi
    //   satis faturasi) - iade ayrimi cip seridinde zaten var.
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    // Yalniz SATIS FATURASI (15). 16 "Satis Fisi" ayri ekran; iade ise ayri tur
    //   degil, belge.tipi = 2 - cipler onu kullanir.
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 15 },
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    // ERP'de Satış grubunda (bu tanım). HBYS'de o grubun tamamı gizli -
    //   aşağıdaki ikiz tanıma bak.
    urunModu: 1,
    menuGrup: 'Satış', menuSira: 40, menuAd: 'Satış Faturaları', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // HBYS'DE DE FATURA KESİLİR (kullanıcı: "satış faturaları için menü
    //   göremedim"). `erp_satis` modülü hastane profilinde KAPALI olduğu için
    //   Satış grubunun tamamı gizleniyordu - oysa hastane hastaya ve kuruma
    //   fatura keser; ekran vardı, menüde girişi yoktu.
    //
    // AYNI EKRAN, ayrı tanım: rota farklı olmak ZORUNDA (aynı rotayı ikinci
    //   kez kaydetmek React Router'da sessizce ilkini kazandırır) ve modül
    //   bağı yok - fatura ticari bir eklenti değil, kurumun temel işi.
    //   Yeri Kurumlar & Sigorta: hastanede fatura kuruma/hastaya kesilir,
    //   kurum icmalleriyle aynı yerde aranır.
    kaynak: 'belge', rota: 'fatura', baslik: 'Faturalar',
    yol: 'Kurumlar & Sigorta › Faturalar',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 15, ebelgeMenusu: 'E-Fatura',
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 15 },
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    urunModu: 2, modul: '',
    menuGrup: 'Kurumlar & Sigorta', menuSira: 60, menuAd: 'Faturalar',
    ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // GELEN e-BELGE KUTUSU (187): bize kesilen e-Fatura / e-Arsiv belgeleri.
    //   Kart YOK - belge bizim degil; cift tik gonderenin goruntusunu acar.
    kaynak: 'gelen-belge', rota: 'gelen-belge', baslik: 'Gelen Kutusu',
    yol: 'Alis › Gelen Kutusu', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    cipler: [
      { ad: 'Yanıt Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 100 } },
      { ad: 'Kabul',          filtre: { alan: 'durum', op: 'esit', deger: 101 } },
      { ad: 'Red',            filtre: { alan: 'durum', op: 'esit', deger: 102 } },
      { ad: 'Tumu' },
      // Geri donus: iki liste tek ekranin iki sekmesi gibi calissin.
      { ad: '🧾 Alış Faturaları', rota: 'alis-fatura' },
    ],
    // MENUDE YOK (kullanici): Alis Faturalari > "Gelen Kutusu" sekmesinden
    //   girilir; menude ikinci bir giris ayni ekrani iki yerde gosterirdi.
    menuGizli: true,
    menuGrup: 'Alış', menuSira: 10, menuAd: 'Gelen Kutusu', ic: '📥', yetkiKodu: 'belge',
  },
  {
    // SATIS FISI (tur 16): perakende/pesin satis. Fatura ile ayni kart ve ayni
    //   akis - fark yalniz belge turu ve numara serisi. Muhasebe fisi URETIR
    //   (kasa_islem_turu.fis_mi = 1), belge fisleme F7'de baglanacak.
    kaynak: 'belge', rota: 'satis-fisi', baslik: 'Satış Fişleri',
    yol: 'Satis › Satış Fişleri', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 16,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 16 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fiş',  filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Satış', menuSira: 50, menuAd: 'Satış Fişleri', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // TAHAKKUK (17 satis / 13 alis - 334: kucuk kod ALIS, buyuk kod SATIS):
    //   cari bakiyeyi ve ekstreyi etkiler ama MUHASEBE FISI URETMEZ (db/098)
    //   - gerceklesen islem geldiginde muhasebe onunla yazilir. Stok da
    //   etkilemez.
    kaynak: 'belge', rota: 'tahakkuk', baslik: 'Satış Tahakkukları',
    yol: 'Satis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 17,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 17 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Satış', menuSira: 60, menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    // SATIS KONSINYE (tur 119 Giden Konsinye): musteriye BIRAKILAN mal.
    //   Stok ve cari etkiler; satildikca faturaya donusur (F8 zinciri).
    kaynak: 'belge', rota: 'satis-konsinye', baslik: 'Satış Konsinyeler',
    yol: 'Satis › Konsinye', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 119,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 119 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
    ],
    // Yalniz HBYS (kullanici): konsinye takibi tibbi malzeme/implant akisinda
    //   kullaniliyor, ERP kurulumunda menude yer kaplamasin.
    urunModu: 2, menuAd: 'Satış Konsinyeler', menuGizli: true, ic: '📦', yetkiKodu: 'belge',
  },
  // ------------------------------------------------------------- ALIS ----
  //  Satis tarafinin birebir karsiligi: ayni 'belge' kaynagi, ayni kart, yalniz
  //  tur farkli (9/10/11/12/17/109). Kartta cari etiketi "Tedarikçi" olur.
  {
    kaynak: 'belge', rota: 'alis-siparis', baslik: 'Alış Siparişleri',
    yol: 'Alis › Siparişler', aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 9,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 9 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuSira: 20, menuAd: 'Alış Siparişleri', ic: '📋', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-irsaliye', baslik: 'Alış İrsaliyeleri',
    yol: 'Alis › İrsaliyeler', aksiyonEkrani: 'irsaliye-liste', yeniBelgeTuru: 10,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 10 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuSira: 30, menuAd: 'Alış İrsaliyeleri', ic: '🚛', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-fatura', baslik: 'Alış Faturaları',
    yol: 'Alis › Faturalar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 11,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 11 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      // Bize KESILEN e-Faturalar (187): ayni serit, ayri kaynak. Alis
      //   faturasi olarak islenecek belgeler once burada gorunur.
      { ad: '📥 Gelen Kutusu', rota: 'gelen-belge', kosul: 'ebelge' },
    ],
    menuGrup: 'Stok & Hizmet', menuSira: 65, menuAd: 'Alış Faturaları', ic: '🧾',
    yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-fisi', baslik: 'Alış Fişleri',
    yol: 'Alis › Fişler', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 12,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 12 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    menuGrup: 'Alış', menuSira: 50, menuAd: 'Alış Fişleri', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // ALIS tarafi: alis tahakkuku (13) - tedarikciye borc.
    kaynak: 'belge', rota: 'borc-tahakkuk', baslik: 'Alış Tahakkukları',
    yol: 'Alis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 13,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 13 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Alış', menuSira: 60, menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    kaynak: 'belge', rota: 'alis-konsinye', baslik: 'Alış Konsinyeler',
    yol: 'Alis › Konsinye', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 109,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 109 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Alış', menuSira: 70, menuAd: 'Alış Konsinyeler', ic: '📦', yetkiKodu: 'belge',
  },
  {
    // "Hangi siparisin nesi teslim edilmedi" - satir bazli acik liste.
    kaynak: 'belge-acik-satir', baslik: 'Açık Sipariş Satırları', yol: 'Satis › Acik Satirlar',
    toplam: ['miktar', 'kapatilanMiktar', 'kalanMiktar'],
    menuGrup: 'Satış', menuSira: 70, menuAd: 'Açık Satırlar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    // Kasa alt sisteminin ANA ekrani (F2): makbuz seviyesindeki islemler.
    //   Karti generic GenForm degil, kendi sayfasi (KasaIslemKarti) - tur sablonu,
    //   bacaklar ve muhasebe fisi paneli generic karta sigmiyor.
    kaynak: 'kasa-islem', baslik: 'Kasa İşlemleri', yol: 'Kasa › İşlemler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'kasa-liste',
    toplam: ['yerelTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Tahsilat', filtre: { alan: 'turGrup', op: 'esit', deger: 'tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turGrup', op: 'esit', deger: 'odeme' } },
      { ad: 'Taslak',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Plan',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      // Dagitilmamis tahsilat (322): satira baglanmamis para - avans olarak
      //   duruyor ve prim tetiklemiyor demektir.
      { ad: 'Dağıtılmamış', filtre: { alan: 'dagitilmamis', op: 'buyuk', deger: 0 } },
    ],
    menuGrup: 'Finans', menuSira: 10, menuAd: 'Kasa İşlemleri', ic: '🧾', yetkiKodu: 'kasa_islem',
  },
  {
    // Acik planlar (v_plan_vade): beklenen tahsilat/odemeler, en yakin vade ustte.
    //   "Gerceklestir" plan kaydini DEGISTIRMEZ - yeni bir islem acar (K10).
    kaynak: 'plan-vade', baslik: 'Vade / Planlar', yol: 'Kasa › Vadeler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'plan-liste',
    toplam: ['tutar', 'gerceklesenTutar', 'kalanTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Vadesi Geçmiş', filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      { ad: 'Tahsilat', filtre: { alan: 'turAdi', op: 'icerir', deger: 'Tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turAdi', op: 'icerir', deger: 'Ödeme' } },
    ],
    menuGrup: 'Finans', menuSira: 70, menuAd: 'Vade / Planlar', ic: '📅', yetkiKodu: 'kasa_islem',
  },
  {
    // "Kasa" grubu, Satış'in HEMEN ALTINDA (kullanici istegi) - "Cari Hareketleri"
    // (mali-hareket) yeniden adlandirildi: hem sayfa basligi hem menu adi "Kasa
    // Hareketleri" oldu (Satış'in aksine kullanici burada baslik metnini ACIKCA verdi).
    kaynak: 'mali-hareket', baslik: 'Kasa Hareketleri', yol: 'Kasa › Hareketler',
    toplam: ['borc', 'alacak'], menuAd: 'Kasa Hareketleri', menuGizli: true, ic: '💰', yetkiKodu: 'mali_hareket',
  },
  // --- Hesaplar: TEK kaynak ('hesap'), tur'e gore 5 ayri ekran. Musteri/Tedarikci
  //     deseninin aynisi: sabitFiltre + rota + yeniKayitVarsayilanlari.
  {
    kaynak: 'hesap', rota: 'kasa-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Kasalar', yol: 'Kasa › Kasa Hesaplari',
    kartYolu: '/kasa-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'K' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 20, menuAd: 'Kasa Hesapları', ic: '💵', yetkiKodu: 'hesap',
  },
  // --- BANKA grubu (kullanici istegi): banka tarafi Kasa'dan ayrildi. Kaynak
  //     yine tek 'hesap' tablosu, tur'e gore ayri ekranlar.
  {
    kaynak: 'hesap', rota: 'banka-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Banka Hesapları', yol: 'Banka › Hesaplar',
    kartYolu: '/banka-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'B' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 30, menuAd: 'Banka Hesapları', ic: '🏦', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Krediler', yol: 'Banka › Krediler',
    kartYolu: '/kredi-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'R' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 35, menuAd: 'Krediler', ic: '🏛️', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'pos-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'POS Hesapları', yol: 'Banka › POS',
    kartYolu: '/pos-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'P' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 40, menuAd: 'POS', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-karti', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Kredi Kartları', yol: 'Banka › Kredi Kartlari',
    kartYolu: '/kredi-karti', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'V' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 50, menuAd: 'Kredi Kartı', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    // BANKA TANIMLARI (db/109): hesap ve cek/senet kartlarindaki banka secimini
    //   besler. Subeler ayri ekran degil, banka kartinin detay tablosu.
    kaynak: 'banka', baslik: 'Banka Tanımları', yol: 'Banka › Tanımlar',
    kartYolu: '/banka', aksiyonEkrani: 'banka-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuSira: 91, menuAltGrup: 'Ayarlar', menuAd: 'Banka Tanımları', ic: '🏛️', yetkiKodu: 'hesap',
  },
  // CEK ve SENET AYRI listeler (kullanici karari): ayni `cek-senet` kaynagi,
  //   sabit filtre tur=1 / tur=2. Ikisi ayni tabloda durur cunku portfoy,
  //   ciro ve tahsil akislari birebir aynidir - degisen yalnizca kagit turu.
  {
    kaynak: 'cek-senet', rota: 'cek', baslik: 'Çekler', yol: 'Banka › Çekler',
    // kartYolu ROTA ile ayni olmali: kart rotasi `/${rota}/:id` uretiliyor.
    //   '/cek-senet' yazilinca "Ekle" tanimsiz rotaya gidip panele dusuyordu.
    kartYolu: '/cek', aksiyonEkrani: 'cek-senet-liste',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { tur: 1 },
    gizliKolonlar: ['tur', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['tutar'],
    cipler: [
      { ad: 'Portföy', filtre: { alan: 'durum', op: 'esit', deger: 10 } },
      { ad: 'Tahsilde', filtre: { alan: 'durum', op: 'esit', deger: 30 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'icinde', deger: [50, 70] } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuSira: 60, menuAd: 'Çek Listesi', ic: '📃', yetkiKodu: 'cek_senet',
  },
  {
    kaynak: 'cek-senet', rota: 'senet', baslik: 'Senetler', yol: 'Banka › Senetler',
    kartYolu: '/senet', aksiyonEkrani: 'cek-senet-liste',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 2 },
    yeniKayitVarsayilanlari: { tur: 2 },
    gizliKolonlar: ['tur', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['tutar'],
    cipler: [
      { ad: 'Portföy', filtre: { alan: 'durum', op: 'esit', deger: 10 } },
      { ad: 'Tahsilde', filtre: { alan: 'durum', op: 'esit', deger: 30 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'icinde', deger: [50, 70] } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuSira: 65, menuAd: 'Senet Listesi', ic: '🧾', yetkiKodu: 'cek_senet',
  },
  {
    // Yuruyen bakiyeli ekstre: hesap secimi URL'den gelir (?hesapId=), grid
    //   sabit tarih sirasinda kalir (bakiye kolonu siralanamaz - sunucu tarafi).
    kaynak: 'hesap-ekstre', baslik: 'Hesap Ekstresi', yol: 'Kasa › Hesap Ekstresi',
    // Para birimi gruplu (111): her grubun ara toplami + en altta genel toplam.
    //   Yerel kolonlar da toplanir - genel toplam ancak yerel parada anlamli.
    urlFiltreAlani: 'hesapId', toplam: ['giris', 'cikis', 'yerelBorc', 'yerelAlacak'],
    menuGrup: 'Finans', menuSira: 76, menuAd: 'Hesap Ekstresi', ic: '📈', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'cari-ekstre', baslik: 'Cari Ekstre', yol: 'Kasa › Cari Ekstre',
    urlFiltreAlani: 'tarafId', toplam: ['borc', 'alacak', 'yerelBorc', 'yerelAlacak'],
    menuGrup: 'Finans', menuSira: 74, menuAd: 'Cari Ekstre', ic: '🧮', yetkiKodu: 'mali_hareket',
  },
  {
    kaynak: 'masraf', baslik: 'Masraflar', yol: 'Stok › Masraflar', cipler: DURUM_CIPLERI,
    menuGrup: 'Finans', menuSira: 72, menuAd: 'Masraf Listesi', ic: '🧾', yetkiKodu: 'masraf',
  },
];
