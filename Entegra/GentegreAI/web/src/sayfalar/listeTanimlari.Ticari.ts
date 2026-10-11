import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Satış, alış, kasa ve banka listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
/** Alis faturasi / gelen belge ANA SEKMELERI (Delphi UFaturalar, 1037). */
const GELEN_SEKMELERI = [
  { ad: 'Sistem', rota: 'alis-fatura', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Gelen Kutusu', rota: 'gelen-belge', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Kullanım Dışı', rota: 'gelen-belge-disi', sekme: true, kosul: 'ebelge' as const },
];

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
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'kapanmaAdi', 'kapanmaDurum',
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
    menuGrup: 'Satış', menuAd: 'Satış Teklifleri', ic: '📄', yetkiKodu: 'belge.satis', menuSira: 10,
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
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuSira: 20, menuAd: 'Satış Siparişleri', ic: '📋', yetkiKodu: 'belge.satis.siparis',
  },
  {
    // Satis irsaliyeleri (Ekranlar/satis_irsaliye_listesi.html): AYRI kaynak
    //   ('irsaliye') - sevkiyat odakli kolonlar (arac/sofor, cikis deposu,
    //   kaynak siparis, faturalama durumu). Ekran satisa daraltir (tur=14).
    kaynak: 'irsaliye', rota: 'satis-irsaliye', baslik: 'Satış İrsaliyeleri',
    yol: 'Satis › Irsaliyeler', aksiyonEkrani: 'irsaliye-liste',
    // e-İrsaliye menüsü YOK (11.10.2026): giden e-Belge yeniden yazılırken kapsam e-Fatura + e-Arşiv.
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 14 },
    yeniBelgeTuru: 14,
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuSira: 30, menuAd: 'Satış İrsaliyeleri', ic: '🚚', yetkiKodu: 'belge.satis.irsaliye',
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
    menuGrup: 'Satış', menuSira: 40, menuAd: 'Satış Faturaları', ic: '🧾', yetkiKodu: 'belge.satis.fatura',
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
    // AD "Satış Faturaları" (kullanici 11.10.2026: "Faturalar (liste) rename Satış Faturaları").
    kaynak: 'belge', rota: 'fatura', baslik: 'Satış Faturaları',
    yol: 'Kurumlar & Sigorta › Satış Faturaları',
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
    menuGrup: 'Kurumlar & Sigorta', menuSira: 60, menuAd: 'Satış Faturaları',
    ic: '🧾', yetkiKodu: 'belge.kurum_fatura',   // 1003: Satış grubundan ayrı kod
  },
  {
    // GELEN e-BELGE KUTUSU (187): bize kesilen e-Fatura / e-Arsiv belgeleri.
    //   Kart YOK - belge bizim degil; cift tik gonderenin goruntusunu acar.
    // DELPHI SEKMELERI (1037, kullanici: "delphi gibi sekmeli olsun"): Alis Faturalari
    //   ekraninin ana sekmeleri Sistem | Gelen Kutusu | Kullanim Disi; Gelen Kutusu'nun
    //   alt sekmeleri Alindi | Yanit Bekleyen | Hata/Red | Suresi Gecen (Delphi
    //   _GelenSekmeUygula). Modul suzgeci YOK (modul: ''): hastane de tedarikciden
    //   e-Fatura alir - HBYS'de ekran acilmiyordu.
    kaynak: 'gelen-belge', rota: 'gelen-belge', baslik: 'Gelen Kutusu',
    yol: 'Alış Faturaları › Gelen Kutusu', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    sabitFiltre: { alan: 'tasnif', op: 'esit', deger: 1 },
    cipler: [
      { ad: 'Alındı' },
      { ad: 'Yanıt Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 100 } },
      { ad: 'Hata/Red',       filtre: { alan: 'durum', op: 'esit', deger: 102 } },
      { ad: 'Süresi Geçen',   filtre: { alan: 'suresiGecti', op: 'esit', deger: 1 } },
      ...GELEN_SEKMELERI,
    ],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 66, menuAd: 'Gelen Kutusu', ic: '📥', yetkiKodu: 'belge.alis_fatura',
  },
  {
    // KULLANIM DISI (1037, Delphi 'Kullanım Dışı'na Taşı): islenmeyecek gelen belgeler.
    kaynak: 'gelen-belge', rota: 'gelen-belge-disi', baslik: 'Kullanım Dışı',
    yol: 'Alış Faturaları › Kullanım Dışı', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    sabitFiltre: { alan: 'tasnif', op: 'esit', deger: 3 },
    cipler: [{ ad: 'Tümü' }, ...GELEN_SEKMELERI],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 67, menuAd: 'Kullanım Dışı', ic: '📥', yetkiKodu: 'belge.alis_fatura',
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
    menuGrup: 'Satış', menuSira: 50, menuAd: 'Satış Fişleri', ic: '🧾', yetkiKodu: 'belge.satis.fis',
  },
  {
    // TAHAKKUK (17 satis / 13 alis - 334: kucuk kod ALIS, buyuk kod SATIS):
    //   cari bakiyeyi ve ekstreyi etkiler ama MUHASEBE FISI URETMEZ (db/098)
    //   - gerceklesen islem geldiginde muhasebe onunla yazilir. Stok da
    //   etkilemez.
    kaynak: 'belge', rota: 'tahakkuk', baslik: 'Satış Tahakkukları',
    yol: 'Satis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 17,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 17 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Satış', menuSira: 60, menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge.satis.tahakkuk',
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
    urunModu: 2, menuAd: 'Satış Konsinyeler', menuGizli: true, ic: '📦', yetkiKodu: 'belge.satis',
  },
  // ------------------------------------------------------------- ALIS ----
  //  Satis tarafinin birebir karsiligi: ayni 'belge' kaynagi, ayni kart, yalniz
  //  tur farkli (9/10/11/12/17/109). Kartta cari etiketi "Tedarikçi" olur.
  {
    kaynak: 'belge', rota: 'alis-siparis', baslik: 'Alış Siparişleri',
    yol: 'Alis › Siparişler', aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 9,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 9 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuSira: 20, menuAd: 'Alış Siparişleri', ic: '📋', yetkiKodu: 'belge.alis',
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
    menuGrup: 'Alış', menuSira: 30, menuAd: 'Alış İrsaliyeleri', ic: '🚛', yetkiKodu: 'belge.alis.irsaliye',
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
      // Bize KESILEN e-Faturalar (187/1037): Delphi gibi ANA SEKMELER (Sistem =
      //   bu liste). Sube mukellef degilse cizilmez.
      ...GELEN_SEKMELERI,
    ],
    menuGrup: 'Stok & Hizmet', menuSira: 65, menuAd: 'Alış Faturaları', ic: '🧾',
    yetkiKodu: 'belge.alis_fatura',   // 1003: Alış grubundan ayrı kod
  },
  {
    kaynak: 'belge', rota: 'alis-fisi', baslik: 'Alış Fişleri',
    yol: 'Alis › Fişler', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 12,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 12 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    menuGrup: 'Alış', menuSira: 50, menuAd: 'Alış Fişleri', ic: '🧾', yetkiKodu: 'belge.alis.fis',
  },
  {
    // ALIS tarafi: alis tahakkuku (13) - tedarikciye borc.
    kaynak: 'belge', rota: 'borc-tahakkuk', baslik: 'Alış Tahakkukları',
    yol: 'Alis › Tahakkuklar', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 13,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 13 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Alış', menuSira: 60, menuAd: 'Tahakkuklar', ic: '📑', yetkiKodu: 'belge.alis.tahakkuk',
  },
  {
    kaynak: 'belge', rota: 'alis-konsinye', baslik: 'Alış Konsinyeler',
    yol: 'Alis › Konsinye', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 109,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 109 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Alış', menuSira: 70, menuAd: 'Alış Konsinyeler', ic: '📦', yetkiKodu: 'belge.alis.konsinye',
  },
  {
    // "Hangi siparisin nesi teslim edilmedi" - satir bazli acik liste.
    kaynak: 'belge-acik-satir', baslik: 'Açık Sipariş Satırları', yol: 'Satis › Acik Satirlar',
    toplam: ['miktar', 'kapatilanMiktar', 'kalanMiktar'],
    menuGrup: 'Satış', menuSira: 70, menuAd: 'Açık Satırlar', ic: '📑', yetkiKodu: 'belge.satis.acik_satir',
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
    menuGrup: 'Finans', menuSira: 10, menuAd: 'Kasa İşlemleri', ic: '🧾', yetkiKodu: 'kasa.finans',
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
    menuGrup: 'Finans', menuSira: 70, menuAd: 'Vade / Planlar', ic: '📅', yetkiKodu: 'kasa.finans.vade',
  },
  {
    // ALACAK YAŞLANDIRMA (1019, mockup İcmal/alacak_yaslandirma.html): hasta
    //   ve kurum açık bakiyeleri gün dilimlerinde. Yalnız HBYS (hasta / kurum
    //   payı kavramı).
    kaynak: 'alacak-yaslandirma', rota: 'alacak-yaslandirma', ozelSayfa: true,
    baslik: 'Alacak Yaşlandırma', yol: 'Finans › Alacak Yaşlandırma', urunModu: 2,
    menuGrup: 'Finans', menuSira: 72, menuAd: 'Alacak Yaşlandırma', ic: '@icmal', yetkiKodu: 'finans.alacak_yaslandirma',
  },
  {
    // HASTA BAŞI MALİYET (1024, mockup İcmal/hasta_basi_maliyet_icmali.html):
    //   başvuru başına ciro - düşülen sarf / ilaç, hizmet ve bölüm kârlılığı.
    kaynak: 'maliyet-icmali', rota: 'maliyet-icmali', ozelSayfa: true,
    baslik: 'Hasta Başı Maliyet', yol: 'Finans › Hasta Başı Maliyet', urunModu: 2,
    menuGrup: 'Finans', menuSira: 73, menuAd: 'Hasta Başı Maliyet', ic: '@icmal', yetkiKodu: 'maliyet.hasta_basi',
  },
  {
    // FATURA / e-BELGE İCMALİ (1035, mockup İcmal/fatura_ebelge_icmali.html): e-belgeler türe /
    //   seriye göre, GİB'e gitmeyen / hatalı / 7 günü aşan, KDV özeti, alıcı / seri, iade / iptal.
    //   ERP ve HBYS'de (fatura iki üründe de kesilir).
    kaynak: 'efatura-icmal', rota: 'efatura-icmal', ozelSayfa: true,
    baslik: 'Fatura / e-Belge İcmali', yol: 'Finans › Fatura / e-Belge İcmali',
    menuGrup: 'Finans', menuSira: 74, menuAd: 'Fatura / e-Belge İcmali', ic: '@icmal', yetkiKodu: 'efatura.icmal',
  },
  {
    // KASA / GÜN SONU MUTABAKATI (1030, mockup İcmal/kasa_gun_sonu_mutabakati.html): kasalar,
    //   POS, banka; beklenen / sayılan / fark, fark açıklaması, Günü Kapat (kasa kilidi).
    kaynak: 'kasa-gun-sonu', rota: 'kasa-gun-sonu', ozelSayfa: true,
    baslik: 'Kasa / Gün Sonu Mutabakatı', yol: 'Finans › Kasa / Gün Sonu', urunModu: 2,
    menuGrup: 'Finans', menuSira: 70, menuAd: 'Kasa / Gün Sonu', ic: '@icmal', yetkiKodu: 'kasa.gun_sonu',
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
    menuGrup: 'Finans', menuSira: 20, menuAd: 'Kasa Hesapları', ic: '💵', yetkiKodu: 'hesap.tanim',
  },
  // --- BANKOLAR (985, Ekranlar/Kayit Kabul/banko_tanimi_v2.html): kasa /
  //     karsilama NOKTASI - kasasi, POS'u ve donanimi olan fiziksel yer.
  //
  //     MENU GRUBU "KAYIT KABUL" (kullanici 08.10.2026: "bankolar menusunu
  //     Kayit Kabul de Basvurular dan sonraya al"): banko kayit kabulun
  //     fiziksel noktasi; gorevli gun boyu Hasta Listesi ve Basvurular ile
  //     birlikte kullaniyor - Finans grubunda aramak gereksiz gezinmeydi.
  //     Siralar Basvurular'in (20) ardinda: 22 tanim, 23 oturum (gizli),
  //     24 onay kuyrugu, 25 oturum gecmisi (Medula Kabul ile ayni sira;
//     ad sirasina gore diziliyor, banko ailesi bitisik kaliyor).
  //     Kart generic: tanim + POS + donanim sekmeleri KartKatalogu.Banko'dan
  //     geliyor, ozel sayfa gerektiren bir sey yok.
  //
  //     BANKO TANIMINDA KULLANICI YOK (kullanici 08.10.2026): kim calisacagi
  //     oturum acilisinda belirlenir - bu yuzden listede "yetkili" sutunu da
  //     yok, acik oturum sutunu oturum altyapisiyla gelecek.
  {
    kaynak: 'banko', rota: 'banko', aksiyonEkrani: 'banko-liste',
    baslik: 'Bankolar', yol: 'Kasa › Bankolar',
    kartYolu: '/banko', kartBaslik: 'Banko',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'aktif', op: 'esit', deger: 0 } },
      // ARIZALI POS'U OLAN BANKO: tahsilat ekraninda o cihaz listelenmez,
      //   yani banko eksik kapasiteyle calisiyordur - teknige dusen is.
      { ad: "Arızalı POS'u olan", filtre: { alan: 'posArizali', op: 'buyuk', deger: 0 } },
      { ad: 'Danışma (kasasız)', filtre: { alan: 'tur', op: 'esit', deger: 2 } },
      // CANLI OTURUM (kullanıcı 09.10.2026): şu an çalışan bankolar.
      { ad: 'Oturum açık', filtre: { alan: 'oturumDurum', op: 'esit', deger: 2 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Finans', menuSira: 45, menuAd: 'Bankolar', ic: '🏧',
    yetkiKodu: 'banko',
    // OTURUMLAR SEKMESİ (mockup banko_tanimi_v2.html, kullanıcı 09.10.2026):
    //   bankonun vardiya geçmişi - içi GenForm'da salt okunur GenGrid.
    yerTutucuSekmeler: ['Oturumlar'],
  },
  // --- BANKO OTURUMU (987, vardiya): akis ekrani ve sorumlu onay kuyrugu.
  //     ozelSayfa - kolonlu liste degil, durum makinesi olan bir akis.
  // BANKO OTURUMU MENUDE YOK (kullanici 08.10.2026: "bankolar dan secilerek
  //   Oturum Ac butonuyla girilsin"): akis Bankolar listesinden modal olarak
  //   acilir. Rota duruyor (/banko-oturum) - adres cubugundan acmak ve
  //   tutanak donusu oradan calisiyor, ama menude ikinci bir giris yok:
  //   gorevli bankosunu secmeden oturum acamaz.
  {
    kaynak: 'banko-oturum', rota: 'banko-oturum', ozelSayfa: true,
    baslik: 'Banko Oturumu', yol: 'Kasa › Banko Oturumu',
    menuGizli: true,
    menuGrup: 'Kayıt Kabul', menuSira: 23, menuAd: 'Banko Oturumu', ic: '🔓',
    yetkiKodu: 'banko_oturum',
  },
  {
    kaynak: 'banko-onay', rota: 'banko-onay', ozelSayfa: true,
    baslik: 'Banko Onay Kuyruğu', yol: 'Kasa › Banko Onayları',
    menuGrup: 'Kayıt Kabul', menuSira: 24, menuAd: 'Banko Onayları', ic: '✅',
    yetkiKodu: 'banko_onay',
  },
  // --- BANKO OTURUM GECMISI (987): vardiya kayitlari. Fark egilimi buradan
  //     okunur - ayni gorevlide tekrarlayan noksan egitim/denetim konusudur.
  {
    kaynak: 'bankoOturum', rota: 'banko-oturumlar', aksiyonEkrani: 'banko-oturum-liste',
    baslik: 'Banko Oturumları', yol: 'Kasa › Banko Oturumları',
    tarihAlani: 'acilisTs',
    toplam: ['nakitTahsilat', 'posTutar', 'kapanisFark'],
    cipler: [
      { ad: 'Açık', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Onay bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Teslimde', filtre: { alan: 'durum', op: 'esit', deger: 3 } },
      // FARKLI KAPANIS: sifirdan farkli fark - denetimin ilk baktigi yer.
      { ad: 'Farklı kapanan', filtre: { alan: 'kapanisFark', op: 'esitDegil', deger: 0 } },
      { ad: 'Tümü' },
    ],
    menuGrup: 'Kayıt Kabul', menuSira: 24, menuAd: 'Banko Oturumları', ic: '📋',
    yetkiKodu: 'banko_oturum',
  },
  // --- VEZNE İCMALİ (1016, mockup İcmal/vezne_icmali.html): şubenin bütün
  //     bankolarının günü tek ekranda - vezne sorumlusunun gün sonu özeti.
  {
    kaynak: 'vezne-icmali', rota: 'vezne-icmali', ozelSayfa: true,
    baslik: 'Vezne İcmali', yol: 'Kayıt Kabul › Vezne İcmali',
    menuGrup: 'Kayıt Kabul', menuSira: 25, menuAd: 'Vezne İcmali', ic: '@icmal',
    yetkiKodu: 'banko.vezne_icmal',
  },
  // --- BANKA grubu (kullanici istegi): banka tarafi Kasa'dan ayrildi. Kaynak
  //     yine tek 'hesap' tablosu, tur'e gore ayri ekranlar.
  {
    kaynak: 'hesap', rota: 'banka-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Banka Hesapları', yol: 'Banka › Hesaplar',
    kartYolu: '/banka-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'B' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 30, menuAd: 'Banka Hesapları', ic: '🏦', yetkiKodu: 'hesap.tanim.banka',
  },
  {
    kaynak: 'hesap', rota: 'kredi-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Krediler', yol: 'Banka › Krediler',
    kartYolu: '/kredi-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'R' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 35, menuAd: 'Krediler', ic: '🏛️', yetkiKodu: 'hesap.tanim.kredi',
  },
  {
    kaynak: 'hesap', rota: 'pos-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'POS Hesapları', yol: 'Banka › POS',
    kartYolu: '/pos-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'P' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 40, menuAd: 'POS', ic: '💳', yetkiKodu: 'hesap.tanim.pos',
  },
  {
    kaynak: 'hesap', rota: 'kredi-karti', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi' }, baslik: 'Kredi Kartları', yol: 'Banka › Kredi Kartlari',
    kartYolu: '/kredi-karti', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'V' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 50, menuAd: 'Kredi Kartı', ic: '💳', yetkiKodu: 'hesap.tanim.kredi_karti',
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
    menuGrup: 'Finans', menuSira: 91, menuAltGrup: 'Ayarlar', menuAd: 'Banka Tanımları', ic: '🏛️', yetkiKodu: 'hesap.tanim.banka_tanim',
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
    menuGrup: 'Finans', menuSira: 65, menuAd: 'Senet Listesi', ic: '🧾', yetkiKodu: 'cek_senet.senet',
  },
  {
    // Yuruyen bakiyeli ekstre: hesap secimi URL'den gelir (?hesapId=), grid
    //   sabit tarih sirasinda kalir (bakiye kolonu siralanamaz - sunucu tarafi).
    kaynak: 'hesap-ekstre', baslik: 'Hesap Ekstresi', yol: 'Kasa › Hesap Ekstresi',
    // Para birimi gruplu (111): her grubun ara toplami + en altta genel toplam.
    //   Yerel kolonlar da toplanir - genel toplam ancak yerel parada anlamli.
    urlFiltreAlani: 'hesapId', toplam: ['giris', 'cikis', 'yerelBorc', 'yerelAlacak'],
    menuGrup: 'Finans', menuSira: 76, menuAd: 'Hesap Ekstresi', ic: '📈', yetkiKodu: 'hesap.tanim.ekstre',
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
