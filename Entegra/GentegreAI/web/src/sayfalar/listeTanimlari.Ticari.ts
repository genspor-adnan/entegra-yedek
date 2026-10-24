import { DURUM_CIPLERI, type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * Satış, alış, kasa ve banka listeleri.
 *
 * `listeTanimlari.ts` 2.525 satırdı ve tek dizi 2.283 satır tutuyordu;
 * bir listenin nerede bittiğini görmek aradığını bulmaktan uzun
 * sürüyordu. Tanımlar değişmedi, yalnız yer değiştirdi - dizi sırası
 * da birebir korundu (ana dosya parçaları sırayla birleştirir).
 */
/**
 * SATIS FATURASI ANA SEKMELERI (Delphi UFaturalar PageControlTur, giden 15; kullanici
 * 11.10.2026: "satış faturaları listesi de delphi gibi sekmeli olsun"): Tumu | Taslak
 * (e-Belge hazirlanmadi) | Hazir | Gonderilmis. Delphi'nin Gonderilmis alt sekmelerinden
 * Bekleyen / Suresi Gecen giden belgede izlenmiyor; Hata/Red alt cipte (gonderim hatasi).
 */
const SATIS_FATURA_SEKMELERI = [
  { ad: 'Tümü', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Taslak', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'esit' as const, deger: 0 } },
  { ad: 'Hazır', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'icinde' as const, deger: [1, 11] } },
  { ad: 'Gönderilmiş', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'icinde' as const, deger: [2, 12] } },
];

/** Satis irsaliyesi e-Irsaliye sekmeleri (e-Irsaliye entegrasyonu, 11.10.2026): 51 hazir, 52 gonderildi. */
const SATIS_IRSALIYE_SEKMELERI = [
  { ad: 'Tümü', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Taslak', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'esit' as const, deger: 0 } },
  { ad: 'Hazır', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'esit' as const, deger: 51 } },
  { ad: 'Gönderilmiş', sekme: true, kosul: 'ebelge' as const, filtre: { alan: 'efaturaKodu', op: 'esit' as const, deger: 52 } },
];

/** Satis irsaliyesi cipleri: faturalama durumu + e-Irsaliye sekmeleri (iki urunde ayni). */
const SATIS_IRSALIYE_CIPLERI = [
  { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit' as const, deger: 0 } },
  { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit' as const, deger: 1 } },
  { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit' as const, deger: 2 } },
  { ad: 'Tumu' },
  { ad: 'Hata/Red', filtre: { alan: 'efaturaSonucKodu', op: 'esit' as const, deger: 3 }, kosul: 'ebelge' as const },
  ...SATIS_IRSALIYE_SEKMELERI,
];

/** Alis faturasi / gelen belge ANA SEKMELERI (Delphi UFaturalar, 1037). */
const GELEN_SEKMELERI = [
  { ad: 'Sistem', rota: 'alis-fatura', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Gelen Kutusu', rota: 'gelen-belge', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Kullanım Dışı', rota: 'gelen-belge-disi', sekme: true, kosul: 'ebelge' as const },
];

/** Alis irsaliyesi / gelen e-Irsaliye ANA SEKMELERI (e-Irsaliye entegrasyonu, 11.10.2026). */
const GELEN_IRSALIYE_SEKMELERI = [
  { ad: 'Sistem', rota: 'alis-irsaliye', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Gelen Kutusu', rota: 'gelen-irsaliye', sekme: true, kosul: 'ebelge' as const },
  { ad: 'Kullanım Dışı', rota: 'gelen-irsaliye-disi', sekme: true, kosul: 'ebelge' as const },
];

/** Gelen kutusu belge turu suzgeci: fatura kutusu e-Fatura + e-Arsiv (1, 2), irsaliye kutusu 7. */
const gelenSuzgec = (tasnif: number, turler: number[]) => ({
  op: 'and' as const,
  kosullar: [
    { alan: 'tasnif', op: 'esit' as const, deger: tasnif },
    { alan: 'belgeTuru', op: 'icinde' as const, deger: turler },
  ],
});

export const TICARI_LISTELERI: ListeGirdisi[] = [
  {
    // SATIS TEKLIFI (216, Ekranlar/teklif_listesi.html): belge turu 18 -
    //   stok/cari/fis ETKILEMEZ, kalem/toplam altyapisi belgeden. Mockup'taki
    //   revizyon/onay akisi ileride; ilk surum ekle/ac/sil.
    kaynak: 'belge', rota: 'teklif', baslik: 'Satış Teklifi Listesi', yol: 'Satis › Satış Teklifi Listesi',
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
    menuGrup: 'Satış', menuAd: 'Satış Teklifi Listesi', ic: '📄', yetkiKodu: 'belge.satis', menuSira: 10,
  },
  {
    // Siparisler AYNI 'belge' kaynagi, tur in (9,19) sabit filtresiyle (Musteri/
    //   Tedarikci deseni). "Kalan" takibi belge_satir.kapatilan_miktar uzerinden;
    //   "Dönüştür" aksiyonu secili siparisten irsaliye/fatura uretir (F8).
    // GenoTIP'te bu liste GORUNMEZ: ayni tur orada "Başvurular" ekraniyla
    //   yonetilir (279) - iki menu ayni belgeleri iki adla gostermesin.
    kaynak: 'belge', rota: 'siparis', baslik: 'Satış Siparişi Listesi', yol: 'Satis › Satış Siparişi Listesi',
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
    menuGrup: 'Satış', menuSira: 20, menuAd: 'Satış Siparişi Listesi', ic: '📋', yetkiKodu: 'belge.satis.siparis',
  },
  {
    // Satis irsaliyeleri (Ekranlar/satis_irsaliye_listesi.html): AYRI kaynak
    //   ('irsaliye') - sevkiyat odakli kolonlar (arac/sofor, cikis deposu,
    //   kaynak siparis, faturalama durumu). Ekran satisa daraltir (tur=14).
    kaynak: 'irsaliye', rota: 'satis-irsaliye', baslik: 'Satış İrsaliyesi Listesi',
    yol: 'Satis › Irsaliyeler', aksiyonEkrani: 'irsaliye-liste',
    // e-İRSALİYE MENÜSÜ (kullanıcı 11.10.2026: "irsaliyelerin izibiz entegrasyonu"): satış
    //   faturasındaki e-Fatura menüsünün aynısı, çoklu seçimle.
    ebelgeMenusu: 'E-İrsaliye',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 14 },
    // TARIH ARALIGI (kullanici 11.10.2026): faturalardaki hazir aralik combosu, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    yeniBelgeTuru: 14,
    toplam: ['genelToplam'],
    cipler: SATIS_IRSALIYE_CIPLERI,
    // FATURANIN ALTINDA (kullanici 11.10.2026: "Satış Faturası menüsünün altına Satış İrsaliyesi").
    menuGrup: 'Satış', menuSira: 41, menuAd: 'Satış İrsaliyesi Listesi', ic: '🚚', yetkiKodu: 'belge.satis.irsaliye',
  },
  {
    // HBYS IKIZI: Satış grubu (erp_satis) hastanede kapali - irsaliye Kurumlar & Sigorta ›
    //   Satış Faturaları'nın altında (satis faturasi ikiziyle ayni desen; rota farkli olmak zorunda).
    kaynak: 'irsaliye', rota: 'satis-irsaliyeleri', baslik: 'Satış İrsaliyesi Listesi',
    yol: 'Kurumlar & Sigorta › Satış İrsaliyesi Listesi', aksiyonEkrani: 'irsaliye-liste',
    ebelgeMenusu: 'E-İrsaliye',
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 14 },
    // TARIH ARALIGI (kullanici 11.10.2026): faturalardaki hazir aralik combosu, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    yeniBelgeTuru: 14,
    toplam: ['genelToplam'],
    cipler: SATIS_IRSALIYE_CIPLERI,
    urunModu: 2, modul: '',
    // Kendi menu kodu (1038): bir yetki kodu tek menu ekrani acar (menuKoduTekEkran); haklar
    //   belge.satis.irsaliye'den kopyalanir, veri yine o kodla okunur.
    menuGrup: 'Kurumlar & Sigorta', menuSira: 61, menuAd: 'Satış İrsaliyesi Listesi', ic: '🚚', yetkiKodu: 'belge.kurum_irsaliye',
  },
  {
    // "Satış" grubu, Cari'nin HEMEN ALTINDA (kullanici istegi) - "Belgeler" ayni kaynak/
    // ekran, sadece grup+menu adi degisti (filtre/kapsam AYNI - hala hem satis hem alis
    // faturalarini gosterir, cip'lerle (Tumu/Satis/Alis) secilir; "kopyala" DENMEDI).
    // Menude "Satis Faturalari" seciliyken liste de YALNIZ satis faturasi
    //   gostermeli (irsaliye/alis karisinca kullanici hangi ekranda oldugunu
    //   kaybediyordu) ve baslik menu adiyla ayni olmali.
    kaynak: 'belge', baslik: 'Satış Faturası Listesi', yol: 'Satis › Satış Faturası Listesi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 15, ebelgeMenusu: 'E-Fatura',
    // TARIH ARALIGI (kullanici 11.10.2026: "alış ve satış faturalarına tarih aralığı ekle"):
    //   hazir aralik combosu, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    // KOLON SIRASI (kullanici): Tarih · Belge No · Cari en solda.
    // ALICI GRUBU e-Belge'nin yerinde (kullanici 11.10.2026: "e-belge sütununu gizle
    //   onun yerine Alıcı Grubu ekle (Hasta/Kurum/Firma)"); e-Fatura / e-Arşiv ayrimi
    //   Senaryo kolonunda zaten var.
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'tarafUnvan', 'aliciGrubu'],
    // ALICI (kullanici 11.10.2026: "satış faturalarında cari rename Alıcı").
    kolonBasliklari: { tarafUnvan: 'Alıcı' },
    // Tur / Belge Turu kolonlari bu ekranda ayni degeri tekrarliyor (hepsi
    //   satis faturasi) - iade ayrimi cip seridinde zaten var.
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum', 'efaturaDurum'],
    // Yalniz SATIS FATURASI (15). 16 "Satis Fisi" ayri ekran; iade ise ayri tur
    //   degil, belge.tipi = 2 - cipler onu kullanir.
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 15 },
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      { ad: 'Hata/Red', filtre: { alan: 'efaturaSonucKodu', op: 'esit', deger: 3 }, kosul: 'ebelge' },
      // e-FATURA / e-ARSIV (kullanici 11.10.2026): hazirlanmis / gonderilmis belgenin turu
      //   (1/2 e-Fatura, 11/12 e-Arsiv); taslakta tur henuz belli degil. Iki ayrac arasinda
      //   (bu ayrac + tarih kutusununki).
      { ad: 'e-Fatura', filtre: { alan: 'efaturaKodu', op: 'icinde', deger: [1, 2] }, kosul: 'ebelge', ayracOnce: true },
      { ad: 'e-Arşiv',  filtre: { alan: 'efaturaKodu', op: 'icinde', deger: [11, 12] }, kosul: 'ebelge' },
      ...SATIS_FATURA_SEKMELERI,
    ],
    // ERP'de Satış grubunda (bu tanım). HBYS'de o grubun tamamı gizli -
    //   aşağıdaki ikiz tanıma bak.
    urunModu: 1,
    menuGrup: 'Satış', menuSira: 40, menuAd: 'Satış Faturası Listesi', ic: '🧾', yetkiKodu: 'belge.satis.fatura',
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
    kaynak: 'belge', rota: 'fatura', baslik: 'Satış Faturası Listesi',
    yol: 'Kurumlar & Sigorta › Satış Faturası Listesi',
    aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 15, ebelgeMenusu: 'E-Fatura',
    // TARIH ARALIGI (kullanici 11.10.2026: "alış ve satış faturalarına tarih aralığı ekle"):
    //   hazir aralik combosu, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    // KOLON SIRASI (kullanici): Tarih · Belge No · Cari en solda.
    // ALICI GRUBU e-Belge'nin yerinde (kullanici 11.10.2026: "e-belge sütununu gizle
    //   onun yerine Alıcı Grubu ekle (Hasta/Kurum/Firma)"); e-Fatura / e-Arşiv ayrimi
    //   Senaryo kolonunda zaten var.
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'tarafUnvan', 'aliciGrubu'],
    // ALICI (kullanici 11.10.2026: "satış faturalarında cari rename Alıcı").
    kolonBasliklari: { tarafUnvan: 'Alıcı' },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum', 'efaturaDurum'],
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 15 },
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fatura', filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade',   filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
      { ad: 'Hata/Red', filtre: { alan: 'efaturaSonucKodu', op: 'esit', deger: 3 }, kosul: 'ebelge' },
      // e-FATURA / e-ARSIV (kullanici 11.10.2026): hazirlanmis / gonderilmis belgenin turu
      //   (1/2 e-Fatura, 11/12 e-Arsiv); taslakta tur henuz belli degil. Iki ayrac arasinda
      //   (bu ayrac + tarih kutusununki).
      { ad: 'e-Fatura', filtre: { alan: 'efaturaKodu', op: 'icinde', deger: [1, 2] }, kosul: 'ebelge', ayracOnce: true },
      { ad: 'e-Arşiv',  filtre: { alan: 'efaturaKodu', op: 'icinde', deger: [11, 12] }, kosul: 'ebelge' },
      ...SATIS_FATURA_SEKMELERI,
    ],
    urunModu: 2, modul: '',
    menuGrup: 'Kurumlar & Sigorta', menuSira: 60, menuAd: 'Satış Faturası Listesi',
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
    // KOLON SIRASI (kullanici): Tarih · Belge No · Gönderici en solda.
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'gondericiUnvan'],
    yol: 'Alış Faturaları › Gelen Kutusu', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    // Yalniz FATURA kutusu (e-Fatura + e-Arsiv); gelen e-Irsaliye kendi listesinde.
    sabitFiltre: gelenSuzgec(1, [1, 2]),
    cipler: [
      { ad: 'Alındı' },
      { ad: 'Yanıt Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 100 } },
      { ad: 'Hata/Red',       filtre: { alan: 'durum', op: 'esit', deger: 102 } },
      { ad: 'Süresi Geçen',   filtre: { alan: 'suresiGecti', op: 'esit', deger: 1 } },
      ...GELEN_SEKMELERI,
    ],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 67, menuAd: 'Gelen Kutusu', ic: '📥', yetkiKodu: 'belge.alis_fatura',
  },
  {
    // GELEN e-IRSALIYE KUTUSU (kullanici 11.10.2026: "alış/satış irsaliyelerin izibiz
    //   entegrasyonu"): Alış İrsaliyeleri'nin "Gelen Kutusu" sekmesi. Kabul / Red GİB'e
    //   irsaliye yanıtı gönderir; kabul ve "Sistem"e aktarım alış irsaliyesi oluşturur.
    kaynak: 'gelen-belge', rota: 'gelen-irsaliye', baslik: 'Gelen e-İrsaliye Listesi',
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'gondericiUnvan'],
    gizliKolonlar: ['vergiTutar'],
    yol: 'Alış İrsaliyeleri › Gelen Kutusu', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-İrsaliye',
    toplam: ['tutar'],
    sabitFiltre: gelenSuzgec(1, [7]),
    cipler: [
      { ad: 'Alındı' },
      { ad: 'Yanıt Bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 100 } },
      { ad: 'Red',            filtre: { alan: 'durum', op: 'esit', deger: 102 } },
      { ad: 'Süresi Geçen',   filtre: { alan: 'durum', op: 'esit', deger: 103 } },
      ...GELEN_IRSALIYE_SEKMELERI,
    ],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 69, menuAd: 'Gelen e-İrsaliye Listesi', ic: '📥', yetkiKodu: 'belge.alis.irsaliye',
  },
  {
    kaynak: 'gelen-belge', rota: 'gelen-irsaliye-disi', baslik: 'Kullanım Dışı e-İrsaliye Listesi',
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'gondericiUnvan'],
    gizliKolonlar: ['vergiTutar'],
    yol: 'Alış İrsaliyeleri › Kullanım Dışı', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-İrsaliye',
    toplam: ['tutar'],
    sabitFiltre: gelenSuzgec(3, [7]),
    cipler: [{ ad: 'Tümü' }, ...GELEN_IRSALIYE_SEKMELERI],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 70, menuAd: 'Kullanım Dışı e-İrsaliye Listesi', ic: '📥', yetkiKodu: 'belge.alis.irsaliye',
  },
  {
    // KULLANIM DISI (1037, Delphi 'Kullanım Dışı'na Taşı): islenmeyecek gelen belgeler.
    kaynak: 'gelen-belge', rota: 'gelen-belge-disi', baslik: 'Kullanım Dışı',
    // KOLON SIRASI (kullanici): Tarih · Belge No · Gönderici en solda.
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'gondericiUnvan'],
    yol: 'Alış Faturaları › Kullanım Dışı', aksiyonEkrani: 'gelen-belge-liste',
    ebelgeMenusu: 'E-Fatura',
    toplam: ['tutar'],
    sabitFiltre: gelenSuzgec(3, [1, 2]),
    cipler: [{ ad: 'Tümü' }, ...GELEN_SEKMELERI],
    menuGizli: true, modul: '',
    menuGrup: 'Stok & Hizmet', menuSira: 68, menuAd: 'Kullanım Dışı', ic: '📥', yetkiKodu: 'belge.alis_fatura',
  },
  {
    // SATIS FISI (tur 16): perakende/pesin satis. Fatura ile ayni kart ve ayni
    //   akis - fark yalniz belge turu ve numara serisi. Muhasebe fisi URETIR
    //   (kasa_islem_turu.fis_mi = 1), belge fisleme F7'de baglanacak.
    kaynak: 'belge', rota: 'satis-fisi', baslik: 'Satış Fişi Listesi',
    yol: 'Satis › Satış Fişi Listesi', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 16,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 16 },
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Fiş',  filtre: { alan: 'tipi', op: 'esitDegil', deger: 2 } },
      { ad: 'İade', filtre: { alan: 'tipi', op: 'esit', deger: 2 } },
    ],
    menuGrup: 'Satış', menuSira: 50, menuAd: 'Satış Fişi Listesi', ic: '🧾', yetkiKodu: 'belge.satis.fis',
  },
  {
    // TAHAKKUK (17 satis / 13 alis - 334: kucuk kod ALIS, buyuk kod SATIS):
    //   cari bakiyeyi ve ekstreyi etkiler ama MUHASEBE FISI URETMEZ (db/098)
    //   - gerceklesen islem geldiginde muhasebe onunla yazilir. Stok da
    //   etkilemez.
    kaynak: 'belge', rota: 'tahakkuk', baslik: 'Satış Tahakkuku Listesi',
    yol: 'Satis › Tahakkuk Listesi', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 17,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 17 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Satış', menuSira: 60, menuAd: 'Tahakkuk Listesi', ic: '📑', yetkiKodu: 'belge.satis.tahakkuk',
  },
  {
    // SATIS KONSINYE (tur 119 Giden Konsinye): musteriye BIRAKILAN mal.
    //   Stok ve cari etkiler; satildikca faturaya donusur (F8 zinciri).
    kaynak: 'belge', rota: 'satis-konsinye', baslik: 'Satış Konsinye Listesi',
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
    urunModu: 2, menuAd: 'Satış Konsinye Listesi', menuGizli: true, ic: '📦', yetkiKodu: 'belge.satis',
  },
  // ------------------------------------------------------------- ALIS ----
  //  Satis tarafinin birebir karsiligi: ayni 'belge' kaynagi, ayni kart, yalniz
  //  tur farkli (9/10/11/12/17/109). Kartta cari etiketi "Tedarikçi" olur.
  {
    kaynak: 'belge', rota: 'alis-siparis', baslik: 'Alış Siparişi Listesi',
    yol: 'Alis › Sipariş Listesi', aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 9,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 9 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Alış', menuSira: 20, menuAd: 'Alış Siparişi Listesi', ic: '📋', yetkiKodu: 'belge.alis',
  },
  {
    kaynak: 'belge', rota: 'alis-irsaliye', baslik: 'Alış İrsaliyesi Listesi',
    yol: 'Alis › İrsaliyeler', aksiyonEkrani: 'irsaliye-liste', yeniBelgeTuru: 10,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 10 },
    // TARIH ARALIGI (kullanici 11.10.2026): satis irsaliyesiyle ayni, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    // ILGISIZ KOLONLAR GIZLI (kullanici 11.10.2026): alis irsaliyesi giden e-Belge degil
    //   (gelen e-Irsaliye kendi sekmesinde), senaryo/tipi fatura kavrami, hasta HBYS faturasi.
    gizliKolonlar: ['tur', 'turAdi', 'teklifDurumAdi', 'teklifDurum',
                    'efaturaDurum', 'eBelgeDurumAdi', 'senaryoAdi', 'tipiAdi', 'hastaAdi'],
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Faturalanmadı', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',         filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Faturalandı',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
      // DELPHI GIBI SEKMELI (alis faturasiyla ayni): Sistem / Gelen Kutusu / Kullanım Dışı.
      ...GELEN_IRSALIYE_SEKMELERI,
    ],
    // ALIS FATURASININ ALTINDA (kullanici 11.10.2026): Stok & Hizmet - iki urunde de acik.
    menuGrup: 'Stok & Hizmet', menuSira: 66, menuAd: 'Alış İrsaliyesi Listesi', ic: '🚛', yetkiKodu: 'belge.alis.irsaliye',
  },
  {
    kaynak: 'belge', rota: 'alis-fatura', baslik: 'Alış Faturası Listesi',
    // TARIH ARALIGI (kullanici 11.10.2026: "alış ve satış faturalarına tarih aralığı ekle"):
    //   hazir aralik combosu, acilista tum tarihler.
    tarihAlani: 'belgeTarihi', tarihCombo: true, tarihComboVarsayilan: '',
    // KOLON SIRASI (kullanici): Tarih · Belge No · Cari en solda.
    kolonSirasi: ['belgeTarihi', 'belgeNo', 'tarafUnvan'],
    // GONDERICI: alis faturasinda cari fatura kesendir (gelen kutusuyla ayni ad).
    kolonBasliklari: { tarafUnvan: 'Gönderici' },
    yol: 'Alis › Fatura Listesi', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 11,
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
    menuGrup: 'Stok & Hizmet', menuSira: 65, menuAd: 'Alış Faturası Listesi', ic: '🧾',
    yetkiKodu: 'belge.alis_fatura',   // 1003: Alış grubundan ayrı kod
  },
  {
    kaynak: 'belge', rota: 'alis-fisi', baslik: 'Alış Fişi Listesi',
    yol: 'Alis › Fişler', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 12,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 12 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    menuGrup: 'Alış', menuSira: 50, menuAd: 'Alış Fişi Listesi', ic: '🧾', yetkiKodu: 'belge.alis.fis',
  },
  {
    // ALIS tarafi: alis tahakkuku (13) - tedarikciye borc.
    kaynak: 'belge', rota: 'borc-tahakkuk', baslik: 'Alış Tahakkuku Listesi',
    yol: 'Alis › Tahakkuk Listesi', aksiyonEkrani: 'belge-liste', yeniBelgeTuru: 13,
    sabitFiltre: { alan: 'tur', op: 'esit', deger: 13 },
    gizliKolonlar: ['tur', 'turAdi', 'efaturaDurum', 'eBelgeDurumAdi', 'teklifDurumAdi', 'teklifDurum'],
    toplam: ['genelToplam'],
    menuGrup: 'Alış', menuSira: 60, menuAd: 'Tahakkuk Listesi', ic: '📑', yetkiKodu: 'belge.alis.tahakkuk',
  },
  {
    kaynak: 'belge', rota: 'alis-konsinye', baslik: 'Alış Konsinye Listesi',
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
    menuGrup: 'Alış', menuSira: 70, menuAd: 'Alış Konsinye Listesi', ic: '📦', yetkiKodu: 'belge.alis.konsinye',
  },
  {
    // "Hangi siparisin nesi teslim edilmedi" - satir bazli acik liste.
    kaynak: 'belge-acik-satir', baslik: 'Açık Sipariş Satırı Listesi', yol: 'Satis › Acik Satirlar',
    toplam: ['miktar', 'kapatilanMiktar', 'kalanMiktar'],
    menuGrup: 'Satış', menuSira: 70, menuAd: 'Açık Satır Listesi', ic: '📑', yetkiKodu: 'belge.satis.acik_satir',
  },
  {
    // Kasa alt sisteminin ANA ekrani (F2): makbuz seviyesindeki islemler.
    //   Karti generic GenForm degil, kendi sayfasi (KasaIslemKarti) - tur sablonu,
    //   bacaklar ve muhasebe fisi paneli generic karta sigmiyor.
    kaynak: 'kasa-islem', baslik: 'Kasa İşlemi Listesi', yol: 'Kasa › İşlem Listesi',
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
    menuGrup: 'Finans', menuSira: 10, menuAd: 'Kasa İşlemi Listesi', ic: '🧾', yetkiKodu: 'kasa.finans',
  },
  {
    // Acik planlar (v_plan_vade): beklenen tahsilat/odemeler, en yakin vade ustte.
    //   "Gerceklestir" plan kaydini DEGISTIRMEZ - yeni bir islem acar (K10).
    kaynak: 'plan-vade', baslik: 'Vade / Plan Listesi', yol: 'Kasa › Vadeler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'plan-liste',
    toplam: ['tutar', 'gerceklesenTutar', 'kalanTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Vadesi Geçmiş', filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      { ad: 'Tahsilat', filtre: { alan: 'turAdi', op: 'icerir', deger: 'Tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turAdi', op: 'icerir', deger: 'Ödeme' } },
    ],
    menuGrup: 'Finans', menuSira: 70, menuAd: 'Vade / Plan Listesi', ic: '📅', yetkiKodu: 'kasa.finans.vade',
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
    // CARİ İCMALİ (1154, mockup İcmal/cari_icmali.html): müşteri ve tedarikçi bakiyeleri
    //   tek ekranda - devir / dönem / bakiye, yaşlandırma, kırılım, mutabakat mektubu.
    //   ERP ve HBYS (kullanıcı localhost'ta - HBYS - aradı): tedarikçi ve anlaşmalı kurum
    //   cari hesapları HBYS'de de var.
    kaynak: 'cari-icmali', rota: 'cari-icmali', ozelSayfa: true,
    baslik: 'Cari İcmali', yol: 'Finans › Cari İcmali',
    menuGrup: 'Finans', menuSira: 71, menuAd: 'Cari İcmali', ic: '@icmal', yetkiKodu: 'finans.cari_icmali',
  },
  {
    // CARİ DEVİR GİRİŞİ (1156, mockup cari_devir_girisi.html): sisteme geçişte çok carinin
    //   açılış bakiyesi - Excel'den yapıştır, sunucu denetler, hazır satırlar yazılır. Tek cari
    //   için kartın Finansal sekmesi / yeni kart sorusu (CariDevirPenceresi).
    // DEVİR GİRİŞİ - TEK EKRAN (1160, mockup devir_girisi.html): cari + kasa / banka / POS / kredi /
    //   kredi kartı, toplu (Excel) ve karttaki açılış bakiyelerini çevirme. Menü maddesi ESKİ
    //   KODUYLA (cari-devir) kalır - GenProfil menü düzeni kodla tutuyor (Ekstre dersi); adı
    //   "Devir Girişi", yolu /devir (menuYol); eski /cari-devir yönlenir.
    kaynak: 'cari-devir', rota: 'cari-devir', ozelSayfa: true,
    baslik: 'Devir Girişi', yol: 'Finans › Devir Girişi',
    menuYol: '/devir', menuGrup: 'Finans', menuSira: 74, menuAd: 'Devir Girişi', ic: '💼', yetkiKodu: 'finans.devir',
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
    kaynak: 'mali-hareket', baslik: 'Kasa Hareketi Listesi', yol: 'Kasa › Hareketler',
    toplam: ['borc', 'alacak'], menuAd: 'Kasa Hareketi Listesi', menuGizli: true, ic: '💰', yetkiKodu: 'mali_hareket',
  },
  // --- Hesaplar: TEK kaynak ('hesap'), tur'e gore 5 ayri ekran. Musteri/Tedarikci
  //     deseninin aynisi: sabitFiltre + rota + yeniKayitVarsayilanlari.
  {
    kaynak: 'hesap', rota: 'kasa-hesap', aksiyonEkrani: 'hesap-liste',
    // KASA LİSTESİ V3 (1161, mockup kasa_listesi_ver3.html): durum çiplerinin yanında AKILLI
    //   ÇİPLER (v_kasa_ozet kolonları). Gösterge şeridinin kutuları bu çiplerin İNDEKSİNİ açar
    //   (KasaPanelleri.CIP) - sıra değişirse orası da değişmeli.
    cipler: [
      ...(DURUM_CIPLERI ?? []),
      { ad: 'Sayım bekleyen', filtre: { op: 'and', kosullar: [
        { alan: 'durum', op: 'esit', deger: 1 }, { alan: 'sayimZorunlu', op: 'esit', deger: 1 }, { alan: 'bugunSayildi', op: 'esit', deger: 0 }] }, ayracOnce: true },
      { ad: 'Sayım farkı', filtre: { op: 'or', kosullar: [{ alan: 'sonFark', op: 'buyuk', deger: 0.005 }, { alan: 'sonFark', op: 'kucuk', deger: -0.005 }] } },
      { ad: 'Limit aşan', filtre: { alan: 'limitYuzde', op: 'buyuk', deger: 100 } },
      { ad: 'Açık oturum', filtre: { alan: 'acikOturum', op: 'buyuk', deger: 0 } },
      { ad: 'Dövizli', filtre: { alan: 'dovizli', op: 'esit', deger: 1 } },
      { ad: 'Banko kasaları', filtre: { alan: 'altTur', op: 'esit', deger: 101 } },
    ],
    kolonSirasi: ['kod', 'ad', 'atamaAdi', 'dovizCinsi', 'bakiye', 'bugunGiris', 'bugunCikis', 'sonSayim', 'sonFark',
                  'limitYuzde', 'son7', 'durumAdi'],
    gizliKolonlar: ['tur', 'bankaAdi', 'iban', 'hesapNo', 'bagliHesap'],
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi', yeniSekme: true }, baslik: 'Kasa Listesi', yol: 'Kasa › Kasa Hesaplari',
    gizliKartSekmeleri: ['Banka Bağlantısı'],   // 1157: yalnız Banka Hesabı kartında (Limitler / Sayım / Yetkiler 1161 burada)
    // Açılış alanları kartta yok (1160): açılış bakiyesi hesabın devir hareketi (💼 Devir / Açılış).
    // Hesap Türü sorulmaz, arka planda Kasa; "POS / Kart" kutusu yok (kullanıcı 24.10.2026) - banka kartıyla aynı desen.
    yeniKayitVarsayilanlari: { tur: 'K' },
    gizliKartAlanlari: ['tur', 'bankaId', 'bankaSubeId', 'hesapNo', 'iban', 'acilisBakiye', 'acilisTarihi',   // kasa banka bilgisi taşımaz
                        'komisyonOrani', 'komisyonMasrafId', 'komisyonZamani', 'valorGun', 'hesapKesimGunu', 'sonOdemeGunu', 'limitTutar'],
    kartYolu: '/kasa-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'K' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 20, menuAd: 'Kasa Hesabı Listesi', ic: '💵', yetkiKodu: 'hesap.tanim.liste',
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
    baslik: 'Banko Listesi', yol: 'Kasa › Banko Listesi',
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
    menuGrup: 'Finans', menuSira: 45, menuAd: 'Banko Listesi', ic: '🏧',
    yetkiKodu: 'banko.liste',
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
    baslik: 'Banko Oturumu Listesi', yol: 'Kasa › Banko Oturumu Listesi',
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
    menuGrup: 'Kayıt Kabul', menuSira: 24, menuAd: 'Banko Oturumu Listesi', ic: '📋',
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
    kaynak: 'hesap', rota: 'banka-hesap', aksiyonEkrani: 'banka-hesap-liste',
    // Mockup çipleri (şerit kutuları da bunları açar: Aktif 0 · Bağlı 1 · Bekleyeni olan 2 · Dikkat 3).
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Bağlı (API)', filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 1 }, { alan: 'bankaKaynak', op: 'esit', deger: 1 }] } },
      { ad: 'Bekleyeni olan', filtre: { alan: 'bankaBekleyen', op: 'buyuk', deger: 0 } },
      { ad: 'Dikkat', filtre: { alan: 'bankaDikkat', op: 'esit', deger: 1 } },
      { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Tümü' },
    ],
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi', yeniSekme: true }, baslik: 'Banka Hesabı Listesi', yol: 'Banka › Hesaplar',
    kartYolu: '/banka-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'B' },
    gizliKartSekmeleri: ['Limitler & Kurallar', 'Sayım / Gün Sonu'],   // 1161: yalnız Kasa kartında
    // BANKA BAĞLANTISI (1157, mockup banka_hareketleri.html): bağlantı, son çekim, banka bakiyesi, fark, bekleyen.
    kolonSirasi: ['bankaGosterim', 'ad', 'kod', 'iban', 'dovizCinsi', 'bankaBaglanti', 'bankaSonCekim', 'bakiye', 'bankaBakiye',
                  'bankaFark', 'bankaBekleyen', 'bankaDurum'],
    kolonBasliklari: { ad: 'Hesap', bakiye: 'Sistem Bakiyesi' },
    // Banka kartında "POS / Kart" kutusu yok (kullanıcı 23.10.2026) - o alanlar POS / kredi kartı kartlarında.
    // Hesap Türü sorulmaz, arka planda Banka (kullanıcı 23.10.2026).
    yeniKayitVarsayilanlari: { tur: 'B' },
    gizliKartAlanlari: ['tur', 'komisyonOrani', 'komisyonMasrafId', 'komisyonZamani', 'valorGun', 'hesapKesimGunu', 'sonOdemeGunu', 'limitTutar', 'acilisBakiye', 'acilisTarihi'],
    // Mockup: Aktif / Pasif ayrı kolon değil (çipte), TL karşılığı şeritte - toplam satırı yok.
    gizliKolonlar: ['atamaAdi', 'durumAdi', 'yerelBakiye'],
    menuGrup: 'Finans', menuSira: 30, menuAd: 'Banka Hesabı Listesi', ic: '🏦', yetkiKodu: 'hesap.tanim.banka.liste',
  },
  {
    kaynak: 'hesap', rota: 'kredi-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi', yeniSekme: true }, baslik: 'Kredi Listesi', yol: 'Banka › Kredi Listesi',
    gizliKartSekmeleri: ['Banka Bağlantısı', 'Limitler & Kurallar', 'Sayım / Gün Sonu'],   // 1157 / 1161: yalnız Banka / Kasa kartında
    // Hesap Türü sorulmaz, arka planda Kredi (kullanıcı 24.10.2026) - banka / kasa kartıyla aynı desen.
    yeniKayitVarsayilanlari: { tur: 'R' },
    gizliKartAlanlari: ['tur', 'acilisBakiye', 'acilisTarihi'],   // 1160: açılış = devir hareketi
    kartYolu: '/kredi-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'R' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 35, menuAd: 'Kredi Listesi', ic: '🏛️', yetkiKodu: 'hesap.tanim.kredi.liste',
  },
  {
    kaynak: 'hesap', rota: 'pos-hesap', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi', yeniSekme: true }, baslik: 'POS Listesi', yol: 'Banka › POS',
    gizliKartSekmeleri: ['Banka Bağlantısı', 'Limitler & Kurallar', 'Sayım / Gün Sonu'],   // 1157 / 1161: yalnız Banka / Kasa kartında
    // Hesap Türü sorulmaz, arka planda POS (kullanıcı 24.10.2026) - banka / kasa kartıyla aynı desen.
    yeniKayitVarsayilanlari: { tur: 'P' },
    // POS / Kart kutusunda kesim günü / son ödeme / limit yok (kullanıcı 24.10.2026): komisyon ve valör kalır.
    gizliKartAlanlari: ['tur', 'acilisBakiye', 'acilisTarihi',   // 1160: açılış = devir hareketi
                        'hesapKesimGunu', 'sonOdemeGunu', 'limitTutar'],
    kartYolu: '/pos-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'P' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 40, menuAd: 'POS Listesi', ic: '💳', yetkiKodu: 'hesap.tanim.pos.liste',
  },
  {
    kaynak: 'hesap', rota: 'kredi-karti', aksiyonEkrani: 'hesap-liste', cipler: DURUM_CIPLERI,
    ekstre: { kaynak: 'hesap-ekstre', alan: 'hesapId', baslik: 'Hesap Ekstresi',
              tarihAlani: 'islemTarihi', yeniSekme: true }, baslik: 'Kredi Kartı Listesi', yol: 'Banka › Kredi Kartlari',
    gizliKartSekmeleri: ['Banka Bağlantısı', 'Limitler & Kurallar', 'Sayım / Gün Sonu'],   // 1157 / 1161: yalnız Banka / Kasa kartında
    // Hesap Türü sorulmaz, arka planda Kredi Kartı (kullanıcı 24.10.2026) - banka / kasa kartıyla aynı desen.
    yeniKayitVarsayilanlari: { tur: 'V' },
    // POS / Kart kutusunda komisyon ve valör yok (kullanıcı 24.10.2026): kesim günü / son ödeme / limit kalır.
    gizliKartAlanlari: ['tur', 'acilisBakiye', 'acilisTarihi',   // 1160: açılış = devir hareketi
                        'komisyonOrani', 'komisyonMasrafId', 'komisyonZamani', 'valorGun'],
    kartYolu: '/kredi-karti', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'V' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Finans', menuSira: 50, menuAd: 'Kredi Kartı', ic: '💳', yetkiKodu: 'hesap.tanim.kredi_karti.liste',
  },
  {
    // BANKA TANIMLARI (db/109): hesap ve cek/senet kartlarindaki banka secimini
    //   besler. Subeler ayri ekran degil, banka kartinin detay tablosu.
    kaynak: 'banka', baslik: 'Banka Tanımı Listesi', yol: 'Banka › Tanımlar',
    kartYolu: '/banka', aksiyonEkrani: 'banka-liste',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Finans', menuSira: 91, menuAltGrup: 'Ayarlar', menuAd: 'Banka Tanımı Listesi', ic: '🏛️', yetkiKodu: 'hesap.tanim.banka_tanim.liste',
  },
  // CEK ve SENET AYRI listeler (kullanici karari): ayni `cek-senet` kaynagi,
  //   sabit filtre tur=1 / tur=2. Ikisi ayni tabloda durur cunku portfoy,
  //   ciro ve tahsil akislari birebir aynidir - degisen yalnizca kagit turu.
  {
    kaynak: 'cek-senet', rota: 'cek', baslik: 'Çek Listesi', yol: 'Banka › Çek Listesi',
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
    menuGrup: 'Finans', menuSira: 60, menuAd: 'Çek Listesi', ic: '📃', yetkiKodu: 'cek_senet.liste',
  },
  {
    kaynak: 'cek-senet', rota: 'senet', baslik: 'Senet Listesi', yol: 'Banka › Senet Listesi',
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
    menuGrup: 'Finans', menuSira: 65, menuAd: 'Senet Listesi', ic: '🧾', yetkiKodu: 'cek_senet.senet.liste',
  },
  {
    // Yuruyen bakiyeli ekstre: hesap secimi URL'den gelir (?hesapId=), grid
    //   sabit tarih sirasinda kalir (bakiye kolonu siralanamaz - sunucu tarafi).
    // TEK EKSTRE (1158): menüden kalktı (menuGizli - menuGrup'suz öğe düz sırada çizilirdi),
    //   /hesap-ekstre?hesapId= yolu /ekstre?tur=hesap&id= olarak yönlenir (App.tsx). Kaynak
    //   kalır: sekmesiz yerinde-ekstre modu ve eski bağlantılar.
    kaynak: 'hesap-ekstre', rota: 'hesap-ekstre', ozelSayfa: true, menuGizli: true, baslik: 'Hesap Ekstresi', yol: 'Finans › Ekstre',
    urlFiltreAlani: 'hesapId', toplam: ['giris', 'cikis', 'yerelBorc', 'yerelAlacak'],
    menuAd: 'Hesap Ekstresi', ic: '📈', yetkiKodu: 'hesap.tanim.ekstre',
  },
  {
    // EKSTRE - TEK EKRAN (1158, mockup ekstre_tek_ekran.html; kullanıcı: "menüde cari ekstre
    //   rename Ekstre"): menü maddesi ESKİ KAYNAK KODUYLA kalır (GenProfil menü düzenleri ekranı
    //   `cari-ekstre` koduyla tutuyor - yeni kod eklense görünmezdi), adı "Ekstre", hedefi tek
    //   ekran /ekstre (cari, kasa, banka, POS, kredi; devir + yürüyen bakiye, aylık, A4).
    //   /cari-ekstre?tarafId= yolu /ekstre?tur=cari&id= olarak yönlenir (App.tsx). Liste
    //   kaynağı kalır: kart panellerinin "son 5 hareket"i ve hasta / kurum listelerinin yerinde
    //   ekstresi onu okur (sunucu yetkisi mali_hareket).
    kaynak: 'cari-ekstre', rota: 'cari-ekstre', ozelSayfa: true, baslik: 'Ekstre', yol: 'Finans › Ekstre',
    urlFiltreAlani: 'tarafId', toplam: ['borc', 'alacak', 'yerelBorc', 'yerelAlacak'],
    tarihAlani: 'islemTarihi', tarihVarsayilan: 'yilbasindanBugune', aksiyonEkrani: 'cari-ekstre-liste',
    menuYol: '/ekstre', menuGrup: 'Finans', menuSira: 74, menuAd: 'Ekstre', ic: '📄', yetkiKodu: 'finans.ekstre',
  },
  {
    kaynak: 'masraf', baslik: 'Masraf Listesi', yol: 'Stok › Masraf Listesi', cipler: DURUM_CIPLERI,
    menuGrup: 'Finans', menuSira: 72, menuAd: 'Masraf Listesi', ic: '🧾', yetkiKodu: 'masraf',
  },
];
