namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Cari, kisi, personel, hasta ve rol kartlari.
/// </summary>
public static partial class KartKatalogu
{
    // --------------------------------------------------------------- cari ----
    /// <summary>
    /// Aday musteri karti - cari kartinin AYNISI, yalniz YETKI KODU farkli
    /// ('aday'): satici rolu adaylari yonetebilsin ama cari kartlarini
    /// acamasin (kullanici: "sadece crm gelsin").
    /// </summary>
    private static KartTanimi Aday() => Cari() with { Ad = "aday", YetkiKodu = "aday" };

    /// <summary>
    /// DIS HEKIM adres tipleri (305): hekimin bizi ilgilendiren adresleri
    /// muayenehanesi ve calistigi hastanedir - "ev/is" ayrimi burada anlamsiz.
    /// </summary>
    private static readonly Dictionary<string, string> HekimAdresTurKodlari = new()
    {
        ["1"] = "Muayenehane",
        ["2"] = "Hastane",
        ["9"] = "Diğer",
    };

    private static KartTanimi Cari() => new(
        Ad: "cari",
        YetkiKodu: "cari",
        Tablo: "public.taraf",
        LogTabloId: 71,                       // GENINI -11110: 71 = Cari
        // ADAY (122) da bu kartla acilir: sabit kosul adayi disarida birakirsa
        //   kayit yazilir ama geri OKUNAMAZ ("Nullable object must have a
        //   value") - kisi kartinda ayni tuzak yasanmisti.
        SabitKosul: "(musteri = 1 or tedarikci = 1 or aday = 1)",
        SubeKolonu: null,                     // ana veri - subeler arasi ORTAK (019 modeli)
        KapsamKolonu: "id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["musteri"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",          "id",           "sayi",  Yazilabilir: false),
            new("kod",         "kod",          "metin", EnFazlaUzunluk: 20,  Baslik: "Kod",            Grup: "Kimlik"),
            new("unvan",       "unvan",        "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan",  Grup: "Kimlik"),
            // idstrip'ten kaldirildi (mockup'ta da yok, sadece Unvan var) - Fatura Bilgileri'ne dustu.
            new("ad",          "ad",           "metin", EnFazlaUzunluk: 50,  Baslik: "Ad"),
            new("soyad",       "soyad",        "metin", EnFazlaUzunluk: 60,  Baslik: "Soyad"),
            // Roller SEKMESI KALDIRILDI (mockup'ta yok) - Musteri/Tedarikci toolbar'a tasindi
            //   (bkz. GenForm.tsx kaynak==='cari'), Kisi Genel sekmesinde kaldi.
            new("musteri",     "musteri",      "mantik", Baslik: "Musteri"),
            new("tedarikci",   "tedarikci",    "mantik", Baslik: "Tedarikci"),
            // ADAY (122): henuz musteri olmayan firma. Anlasma saglaninca
            //   musteri=1 / aday=0 olur - AYNI kayit, gecmisi (firsat, gorev,
            //   adres, ilgili kisi) yerinde kalir.
            // ADAY kutusu kartta CIZILMEZ (kullanici): adaylik durumu listeden
            //   ("Müşteriye Dönüştür" aksiyonu) yonetilir, kartta elle
            //   isaretlenecek bir sey degil. Alan SILINMEDI, GIZLI: Aday
            //   Musteriler listesi yeni kayitta aday=true gonderiyor ve alan
            //   metadan cikarsa o deger hic yazilmaz - yeni aday, aday
            //   listesinde gorunmezdi.
            new("aday",        "aday",         "mantik", Baslik: "Aday", Gizli: true),
            new("kisi",        "kisi",         "mantik", Baslik: "Kisi"),
            // "Mali" -> "Adres / Fatura Bilgisi" (kullanici: adres de bu sekmede duruyor; AltGrup ile
            //   kutusuna ayrildi: Fatura / Vergi Kimligi + e-Belge Ayarlari. Mockup'taki XSLT/
            //   Alias alanlari (E-Fatura XSLT, E-Irsaliye XSLT, E-Arsiv XSLT, Alias/e-Posta)
            //   backend'de kolon karsiligi yok (taraf tablosunda yok) - eklenmedi.
            new("faturaUnvan", "fatura_unvan", "metin", EnFazlaUzunluk: 200, Baslik: "Fatura Unvani", Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("vkno",        "vkno",         "metin", EnFazlaUzunluk: 20,  Baslik: "Vergi / Kimlik No",     Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("vd",          "vd",           "metin", EnFazlaUzunluk: 60,  Baslik: "Vergi Dairesi",  Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            // ÜTS verme bildiriminde KUN buradan okunur (225).
            new("utsKurumNo",  "uts_kurum_no", "metin", EnFazlaUzunluk: 30,  Baslik: "ÜTS Kurum No",   Grup: "Adres / Fatura Bilgisi", AltGrup: "Fatura / Vergi Kimligi"),
            new("efatura",     "efatura",      "mantik", Baslik: "e-Fatura mukellefi", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new("aliasEposta", "alias_eposta", "metin", EnFazlaUzunluk: 200, Baslik: "Alias / e-Posta", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            // E-POSTA GİTMESİN (1184, kullanıcı 25.10.2026): e-Arşiv faturada e-posta sorulmaz, izibiz'e KAĞIT gider.
            new("earsivEpostaYok", "earsiv_eposta_yok", "mantik", Baslik: "E-Posta gitmesin", Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari",
                Ipucu: "İşaretliyse e-Arşiv faturada e-posta adresi sorulmaz; belge izibiz'e KAĞIT gönderim şekliyle gider."),
            // SON KONTROL (kullanıcı 25.10.2026): son GİB alias sorgusu. e-Fatura alıcısında 30 günden eskiyse, e-Arşiv
            //   alıcısında HER hazırlamada yeniden sorgulanır ve güncellenir (EFaturaServisi.HazirlaAsync "taze"); kart /
            //   Ctrl+K GİB sorgusu da yazar. Elle değişmez.
            // CARİYE ÖZEL DİPNOT (1187): doluysa e-Belge hazırlamada genel sabit notların yerine. Kartta modalla girilir
            //   (KartGrupSekmesi > EBelgeDipnotlari).
            new("efaturaDipnot",   "efatura_dipnot",   "metin", EnFazlaUzunluk: 1000, Baslik: "e-Fatura Dipnotu",
                Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new("eirsaliyeDipnot", "eirsaliye_dipnot", "metin", EnFazlaUzunluk: 1000, Baslik: "e-İrsaliye Dipnotu",
                Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari"),
            new("efaturaSorguTarihi", "efatura_sorgu_tarihi", "zaman", Yazilabilir: false, Baslik: "Son Kontrol",
                Grup: "Adres / Fatura Bilgisi", AltGrup: "e-Belge Ayarlari",
                Ipucu: "Son GİB alias sorgusu. e-Fatura alıcısında 30 günü geçince, e-Arşiv alıcısında her faturada yeniden sorgulanır."),
            // FIYAT LISTESI (204). IKI AYRI ALAN: bir cari hem musteri hem
            //   tedarikci olabiliyor; tek alan olsaydi ayni cariye satarken de
            //   alirken de ayni liste uygulanirdi. Bos ise yonun VARSAYILAN
            //   listesi gecerli - her cariye tek tek atamak gerekmez.
            new("satisFiyatListesiId", "satis_fiyat_listesi_id", "kod",
                KodTablosu: "public.v_fiyat_listesi_satis_lookup",
                // SATIS & RISK sekmesinde (Satış Koşulları kutusu, musteri_karti_ver3.html) cizilir;
                //   grubun kendi sekmesi gizli (listeTanimlari.Cari gizliKartSekmeleri).
                Baslik: "Satış Fiyat Listesi", Grup: "Satış Koşulları"),
            new("alisFiyatListesiId",  "alis_fiyat_listesi_id",  "kod",
                KodTablosu: "public.v_fiyat_listesi_alis_lookup",
                Baslik: "Alış Fiyat Listesi", Grup: "Satış Koşulları"),
            // KAMPANYA (274): listenin YERINE gecmez, USTUNE isler - liste baz
            //   fiyati, kampanya indirimi verir. Bos ise genel kampanya (varsa)
            //   gecerli olur; anlasmali kurumda kampanya sozlesmeden gelir ve
            //   bunu ezer (fn_taraf_kampanya).
            new("kampanyaId", "kampanya_id", "kod",
                KodTablosu: "public.v_kampanya_lookup",
                // SATIŞ KOŞULLARI'NDA (kullanıcı 25.10.2026: "kartta kampanya combo'yu satış koşulları altına al") -
                //   Satış & Risk sekmesinde fiyat listesinin yanında (CariSatisRiskSekmesi).
                Baslik: "Kampanya", Grup: "Satış Koşulları"),
            // MÜŞTERİ RİSKİ (1178, karar R1): limit (null = TANIMSIZ, limitsiz değil) kendi dövizinde, risk grubu,
            //   sevk blokesi ve geçerli teminatların özeti. KARTTA SALT OKUNUR: kart alan bazında aksiyon yetkisi
            //   (cari.risk_limit) tanımıyor - değişiklik Müşteri Risk / Limit İcmali'nden (neden zorunlu, loglu).
            //   "Satış Koşulları" grubunda: Satış & Risk sekmesinin Risk / Limit kutusu çizer (CariSatisRiskSekmesi).
            new("riskLimit",        "risk_limit",         "para",   Yazilabilir: false, Baslik: "Risk Limiti", Grup: "Satış Koşulları",
                Ipucu: "Boş = tanımsız. Müşteri Risk / Limit İcmali'nden değiştirilir."),
            new("riskLimitDoviz",   "risk_limit_doviz",   "kod",    Yazilabilir: false, SabitKodlar: DovizKodlari, Baslik: "Limit Dövizi",
                Grup: "Satış Koşulları"),
            new("riskGrubu",        "risk_grubu",         "metin",  Yazilabilir: false, EnFazlaUzunluk: 60, Baslik: "Risk Grubu",
                Grup: "Satış Koşulları"),
            new("sevkBlokesi",      "sevk_blokesi",       "mantik", Yazilabilir: false, Baslik: "Sevk Blokesi", Grup: "Satış Koşulları"),
            new("sevkBlokesiNeden", "sevk_blokesi_neden", "metin",  Yazilabilir: false, Baslik: "Bloke Nedeni", Grup: "Satış Koşulları"),
            new("teminatOzeti",
                "(select coalesce(string_agg(case tt.tur when 1 then 'Teminat mektubu' when 2 then 'İpotek' when 3 then 'Çek / senet' "
                + "when 4 then 'Nakit' else 'Diğer' end || ' ' || replace(to_char(tt.tutar, 'FM999,999,999,990'), ',', '.') || ' ' || tt.doviz, ' · ' "
                + "order by tt.tutar desc), '') from public.taraf_teminat tt where tt.taraf_id = taraf.id "
                + "and (tt.baslangic is null or tt.baslangic <= current_date) and (tt.bitis is null or tt.bitis >= current_date))",
                "metin", Yazilabilir: false, Baslik: "Teminat", Grup: "Satış Koşulları"),
            // "Iletisim"/"Siniflandirma"/"Diger" SEKME DEGIL - mockup'ta Genel'in alt-kutulari
            //   (Kart Bilgileri / İletişim / Notlar). Grup kaldirildi, AltGrup ile Genel'e katlandi.
            new("telefon",     "telefon",      "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",        AltGrup: "İletişim"),
            new("cepTel",      "cep_tel",      "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",   AltGrup: "İletişim"),
            new("eposta",      "eposta",       "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",        AltGrup: "İletişim"),
            new("epostaWeb",   "eposta_web",   "metin", EnFazlaUzunluk: 200, Baslik: "Web", AltGrup: "İletişim"),
            // "Grup" YERINE Kategori/İlk Temas + Sektor/Alt Sektor + Sinif/Bolge (kullanici)
            //   - GenForm.tsx bu ciftleri AYNI SATIRDA yan yana render eder, sirayla:
            //   Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge, Temsilci/Özel Kod.
            new("kategori",    "kategori",     "kod",   KodListesi: "taraf.kategori",   Baslik: "Kategori",   AltGrup: "Tanımlama"),
            new("ilkTemas",    "ilk_temas",    "kod",   KodListesi: "taraf.ilk_temas",  Baslik: "İlk Temas",  AltGrup: "Tanımlama"),
            new("sektor",      "sektor",       "kod",   KodListesi: "taraf.sektor",     Baslik: "Sektör",     AltGrup: "Tanımlama"),
            new("altSektor",   "alt_sektor",   "kod",   KodListesi: "taraf.alt_sektor", Baslik: "Alt Sektör", AltGrup: "Tanımlama"),
            new("sinif",       "sinif",        "kod",   KodListesi: "taraf.sinif",      Baslik: "Sınıf",      AltGrup: "Tanımlama"),
            new("bolge",       "bolge",        "kod",   KodListesi: "taraf.bolge",      Baslik: "Bölge",      AltGrup: "Tanımlama"),
            // TEMSILCI kimlik seridinde (Unvan'in saginda): "bu cari kimin"
            //   sorusu kartin en ustunde cevaplanmali. Deger PERSONEL taraf
            //   id'sidir - eskiden kod listesi bagli degildi ve ekranda ham
            //   sayi goruluyordu.
            new("temsilci",    "temsilci",     "kod",   KodTablosu: "public.v_personel_lookup",
                                                        Baslik: "Temsilci", Grup: "Kimlik"),
            new("ozelKod",     "ozel_kod",     "metin", EnFazlaUzunluk: 20,  Baslik: "Ozel Kod",       AltGrup: "Tanımlama"),
            new("notlar",      "notlar",       "metin", EnFazlaUzunluk: 1000, Baslik: "Notlar",        AltGrup: "Notlar"),
            new("durum",       "durum",        "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum",    Grup: "Kimlik"),
            new("subeId",      "sube_id",      "sayi",  Yazilabilir: false),
            new("eklemeTarihi","ekleme_tarihi","tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: AdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                // Il ONCE, Ilce SONRA (kullanici: "İl önce ... İlçe sonra") - Ilce'nin
                //   secimi zaten Il'e bagli (cascading), sira da mantiksal olarak boyle.
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),  // yeni tablo - eski karsiligi yok
            // SATIS & RISK (musteri_karti_ver3.html): taraf_musteri 1:1 uzanti. Risk
            //   limiti Musteri Listesi'nin "Risk Limiti %" kolonunu ve "Limit aşan"
            //   cipini, vade gunu vadesi gecen hesabini (v_cari_ozet, 1150) besler:
            //   vadesi olmayan hareketin vadesi = islem tarihi + vade gunu.
            new DetayTanimi("satisKosul", "public.taraf_musteri", "id", new KartAlani[]
            {
                new("id",           "id",            "sayi",    Yazilabilir: false),
                // Satış Koşulları kutusu (1152).
                // İSKONTO ORANI ve PARA BİRİMİ kaldırıldı (kullanıcı 25.10.2026): cariye özel iskonto kampanyayla
                //   verilir ("iskontoyu kampanya ile yaparız"). Kolonlar 1183'te düşürüldü.
                new("vadeGun",      "vade_gun",      "sayi",    Baslik: "Vade (gün)"),
                // ÖDEME ŞEKLİ KALDIRILDI (kullanıcı 25.10.2026, kolon 1181'de düşürüldü).
                new("sevkSekli",    "sevk_sekli",    "kod",     Baslik: "Sevk Şekli", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Kendi aracımız", ["2"] = "Kargo", ["3"] = "Ambar / nakliye", ["4"] = "Müşteri teslim alır" }),
                new("kdvDurumu",    "kdv_durumu",    "kod",     Baslik: "KDV Durumu", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Normal", ["2"] = "KDV istisnalı", ["3"] = "İhraç kayıtlı", ["4"] = "Tam muaf" }),
                new("tevkifat",     "tevkifat",      "kod",     Baslik: "Tevkifat", SabitKodlar: new Dictionary<string, string>
                    { ["0"] = "Yok", ["2"] = "2/10", ["3"] = "3/10", ["4"] = "4/10", ["5"] = "5/10",
                      ["7"] = "7/10", ["9"] = "9/10", ["10"] = "Tam" }),
                // Risk / Limit kutusu - ESKİ alanlar (1152). 1178'de yerini taraf.risk_limit (+ dövizi), taraf_teminat ve
                //   genel `satis.limit_davranis` ayarı aldı: kartta GİZLİ (iki "Risk Limiti" görünmesin). Kolon yerinde;
                //   Müşteri Listesi / Cari İcmali / Ekstre / Devir de 1178'de taraf.risk_limit'e taşındı (o listeler limiti dövizine bakmadan TL bakiyeyle kıyaslar; dövizli limitte doğrusu Müşteri Risk İcmali'nde).
                new("riskLimiti",   "risk_limiti",   "para",    Baslik: "Risk Limiti (eski)", Gizli: true),
                new("riskAsim",     "risk_asim",     "kod",     Baslik: "Aşımda (eski)", Gizli: true, SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Yalnız uyar", ["2"] = "Sevkiyat onaya düşer", ["3"] = "Satış engellenir" }),
                new("teminat",      "teminat",       "metin",   EnFazlaUzunluk: 200, Baslik: "Teminat (eski)", Gizli: true)
            }, SubeKolonu: null, Baslik: "Satış & Risk", LogTabloId: 1385, TekSatir: true),
            // SATINALMA KOŞULLARI (1162 / 1163, mockup tedarikci_karti_ver3.html): taraf_tedarikci (017) 1:1 - müşterideki
            //   Satış & Risk'in karşılığı. Vade günü alış belgelerinin vadesini (v_cari_ozet vadesi geçen ödeme,
            //   30 günde ödenecek) besler. Müşteri listesi sekmeyi gizler.
            new DetayTanimi("satinalmaKosul", "public.taraf_tedarikci", "id", new KartAlani[]
            {
                new("id",                 "id",                    "sayi",    Yazilabilir: false),
                new("vadeGun",            "vade_gun",              "sayi",    Baslik: "Vade (gün)"),
                new("odemeSekli",         "odeme_kosulu",          "kod",     Baslik: "Ödeme Şekli", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Nakit", ["2"] = "Havale / EFT", ["3"] = "Çek", ["4"] = "Senet", ["5"] = "Kredi kartı", ["6"] = "Çek / Havale" }),
                new("odemeGunu",          "odeme_gunu",            "metin",   EnFazlaUzunluk: 60, Baslik: "Ödeme Günü"),
                new("erkenOdemeIskonto",  "erken_odeme_iskonto",   "ondalik", Baslik: "Erken Ödeme İskontosu %"),
                new("erkenOdemeGun",      "erken_odeme_gun",       "sayi",    Baslik: "Erken Ödeme (gün içinde)"),
                new("alisFiyatListesiId", "alis_fiyat_listesi_id", "kod",     KodTablosu: "public.v_fiyat_listesi_lookup", Baslik: "Alış Fiyat Listesi"),
                new("tedarikSuresiGun",   "temin_suresi_gun",      "sayi",    Baslik: "Tedarik Süresi (gün)"),
                new("minSiparis",         "min_siparis",           "para",    Baslik: "Minimum Sipariş"),
                new("teslimSekli",        "teslim_sekli",          "kod",     Baslik: "Teslim Şekli", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Tedarikçi teslim (DAP)", ["2"] = "Kargo", ["3"] = "Ambar / nakliye", ["4"] = "Biz alırız (EXW)" }),
                new("sozlesmeNo",         "sozlesme_no",           "metin",   EnFazlaUzunluk: 40, Baslik: "Sözleşme No"),
                new("sozlesmeBitis",      "sozlesme_bitis",        "tarih",   Baslik: "Sözleşme Bitiş"),
                new("krediLimiti",        "kredi_limiti",          "para",    Baslik: "Bize Tanınan Kredi Limiti"),
                new("onayDurumu",         "onay_durumu",           "kod",     Baslik: "Onay Durumu", SabitKodlar: new Dictionary<string, string>
                    { ["0"] = "—", ["1"] = "A · onaylı", ["2"] = "B", ["3"] = "C · izlemede" }),
                new("tedarikciTuru",      "tedarikci_turu",        "kod",     Baslik: "Tedarikçi Türü", SabitKodlar: new Dictionary<string, string>
                    { ["0"] = "—", ["1"] = "Üretici", ["2"] = "Distribütör", ["3"] = "Toptancı", ["4"] = "Hizmet", ["5"] = "İthalatçı" }),
                new("yerliIthal",         "yerli_ithal",           "kod",     Baslik: "Yerli / İthal", SabitKodlar: new Dictionary<string, string>
                    { ["1"] = "Yerli", ["2"] = "İthal" }),
                new("satinalmaciId",      "satinalmaci_id",        "kod",     KodTablosu: "public.v_personel_lookup", Baslik: "Satınalmacı"),
            }, SubeKolonu: null, Baslik: "Satınalma Koşulları", LogTabloId: 1612, TekSatir: true),
            // BANKA / IBAN (1153, kullanici: "banka Iban ekleyemedim" - sekme yer tutucuydu):
            //   carinin banka hesaplari. IBAN ulke kodu + mod-97 ile denetlenir; tek varsayilan.
            new DetayTanimi("bankalar", "public.taraf_banka", "taraf_id", new KartAlani[]
            {
                new("id",          "id",           "sayi",  Yazilabilir: false),
                new("bankaAdi",    "banka_adi",    "metin", EnFazlaUzunluk: 80,  Baslik: "Banka", Zorunlu: true),
                new("subeAdi",     "sube_adi",     "metin", EnFazlaUzunluk: 80,  Baslik: "Şube"),
                new("iban",        "iban",         "metin", EnFazlaUzunluk: 34,  Baslik: "IBAN",
                    Dogrulama: KimlikDogrulama.IbanTuru),
                new("hesapNo",     "hesap_no",     "metin", EnFazlaUzunluk: 40,  Baslik: "Hesap No"),
                new("dovizCinsi",  "doviz_cinsi",  "kod",   SabitKodlar: DovizKodlari, Baslik: "Para Birimi"),
                new("hesapSahibi", "hesap_sahibi", "metin", EnFazlaUzunluk: 120, Baslik: "Hesap Sahibi"),
                new("aciklama",    "aciklama",     "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama"),
                new("varsayilan",  "varsayilan",   "mantik", Baslik: "Varsayılan"),
                new("aktif",       "aktif",        "mantik", Baslik: "Aktif")
            }, Sirala: "varsayilan desc, id", SubeKolonu: null, Baslik: "Banka / IBAN", LogTabloId: 1386)
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge",        "taraf_id", "Bu cariye ait belge var, silinemez."),
            new SilmeEngeli("public.mali_hareket", "taraf_id", "Bu cariye ait kasa/banka hareketi var, silinemez."),
            // HAREKETLİ CARİ SİLİNMEZ (kullanıcı 26.10.2026: "müş/ted ye ait hareket varsa silme kesinlikle
            //   olmaz"): FK'lar NO ACTION zaten engeller ama genel mesajla - burada sebebi ve adedi ile 422.
            new SilmeEngeli("public.kasa_islem",         "taraf_id",       "Bu cariye ait kasa/banka işlemi var, silinemez."),
            new SilmeEngeli("public.kasa_islem",         "karsi_taraf_id", "Bu cari bir virman/transfer işleminde karşı taraf, silinemez."),
            new SilmeEngeli("public.cek_senet",          "taraf_id",       "Bu cariye ait çek/senet var, silinemez."),
            new SilmeEngeli("public.cek_senet",          "ciro_taraf_id",  "Bu cariye ciro edilmiş çek/senet var, silinemez."),
            new SilmeEngeli("public.cek_senet_hareket",  "taraf_id",       "Bu cariye ait çek/senet hareketi var, silinemez."),
            new SilmeEngeli("public.e_belge",            "taraf_id",       "Bu cariye ait e-belge var, silinemez."),
            new SilmeEngeli("public.muhasebe_fis_satir", "taraf_id",       "Bu cariye ait muhasebe fişi satırı var, silinemez."),
            new SilmeEngeli("public.kredi",              "taraf_id",       "Bu cariye ait kredi var, silinemez."),
            new SilmeEngeli("public.taraf_kullanici",    "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

    // --------------------------------------------------------------- kisi ----
    // kisi_karti.html mockup - kapsam kullaniciyla netlestirildi: TEMEL kimlik/iletisim.
    // Rol/yetki seviyesi/raporladigi kisi/dogum-cinsiyet-medeni durum/dil/iliski skoru/
    // etiket/foto/iletisim gecmisi/ilgili kayitlar/KVKK-izin/notlar-ekler EKLENMEDI -
    // DB'de hicbirinin karsiligi yoktu, tam kapsamli ayri, cok daha buyuk bir is olurdu.
    // Ayni taraf tablosu (kisi=1, bag_id ile sirkete bagli) - unvan (Ad Soyad gorunen adi)
    // 037_kisi_karti.sql'deki trigger ile ad+soyad'dan OTOMATIK uretiliyor, alanda YOK.

    // --------------------------------------------------------------- kisi ----
    // kisi_karti.html mockup - kapsam kullaniciyla netlestirildi: TEMEL kimlik/iletisim.
    // Rol/yetki seviyesi/raporladigi kisi/dogum-cinsiyet-medeni durum/dil/iliski skoru/
    // etiket/foto/iletisim gecmisi/ilgili kayitlar/KVKK-izin/notlar-ekler EKLENMEDI -
    // DB'de hicbirinin karsiligi yoktu, tam kapsamli ayri, cok daha buyuk bir is olurdu.
    // Ayni taraf tablosu (kisi=1, bag_id ile sirkete bagli) - unvan (Ad Soyad gorunen adi)
    // 037_kisi_karti.sql'deki trigger ile ad+soyad'dan OTOMATIK uretiliyor, alanda YOK.
    private static KartTanimi Kisi() => new(
        Ad: "kisi",
        YetkiKodu: "cari",                    // ayri yetki kodu yok - cari yetkisiyle yonetiliyor
        Tablo: "public.taraf",
        LogTabloId: 71,                       // ayni fiziksel tablo - cari ile ayni GENINI kodu
        SabitKosul: "kisi = 1",
        KapsamKolonu: "bag_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["kisi"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            // Ad/Soyad DEGIL, Cari ile ayni desen: "Unvan" tek goruntulenen alan. Ad/Soyad
            //   ayrimi BILEREK yapilmadi - kullanici bunu ileride IK (personel) ve hasta
            //   kartlarina sakladi, kisi kartinda degil (038_kisi_karti_unvan_geri_al.sql).
            // idstrip sirasi kullanici tarafindan belirlendi: Kod, Unvan, Departman, Gorev.
            //   Durum idstrip'ten CIKARILDI (kullanici sonradan Durum'suz istedi) - Is
            //   Bilgileri kutusuna tasindi (Bagli Cari ile birlikte).
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // YeniKayitVarsayilanlari'ndaki "kisi"=1 buraya yazilabilsin diye (alan
            //   tanimsizsa EkleAsync kolonu atlar, DB varsayilanina - 0/false - duser,
            //   sonra SabitKosul "kisi = 1" yeni kaydi bulamaz -> "Nullable ... value" hatasi).
            //   UI'da gorunmez (gizli Set, GenForm.tsx).
            new("kisi",      "kisi",       "mantik", Baslik: "Kisi"),
            new("kod",       "kod",        "metin", EnFazlaUzunluk: 20, Baslik: "Kisi Kodu", Grup: "Kimlik"),
            new("unvan",     "unvan",      "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "Unvan", Grup: "Kimlik"),
            new("departman", "departman",  "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Kimlik"),
            // GÖREV LİSTEDEN (kullanıcı 25.10.2026: "bölüm ve görev listesinin de migrate olması gerekir"): Delphi
            //   cari kişi görevi bir listeydi (GENINI -2205, 1182 ile personel_gorev'e taşındı). Serbest metin
            //   personel kartındaki gibi "Unvan (serbest)" olarak kalır - eski kayıtların yazısı kaybolmasın.
            new("gorevId",   "gorev_id",   "kod",   KodTablosu: "public.v_gorev_lookup", Baslik: "Görev", Grup: "Kimlik"),
            new("gorev",     "gorev",      "metin", EnFazlaUzunluk: 100, Baslik: "Unvan (serbest)", Grup: "Kimlik"),
            // "Is Bilgileri" kutu basligi IPTAL edildi (kullanici) - Bagli Cari/Rol/Durum
            //   AltGrup'suz (adsiz) duz alan olarak kaliyor, idstrip'in hemen altinda.
            new("bagId",     "bag_id",     "kod",   KodTablosu: "public.v_cari_lookup", Baslik: "Bagli Cari"),
            new("rol",       "rol",        "kod",   SabitKodlar: KisiRolKodlari, Baslik: "Rol"),
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum"),
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon",         AltGrup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", EnFazlaUzunluk: 30,  Baslik: "Cep Telefonu",    AltGrup: "İletişim"),
            new("eposta",    "eposta",     "metin", EnFazlaUzunluk: 120, Baslik: "E-posta",         AltGrup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "2. E-posta",      AltGrup: "İletişim"),
            new("subeId",        "sube_id",       "sayi",  Yazilabilir: false),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // kisi_karti.html mockup'taki "Adres" kutusu - Cari ile AYNI taraf_adres tablosu
            //   (taraf_id = bu kisi satirinin id'si, kişi de bir taraf). Ayni LogTabloId (901).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // "Geçmiş" sekmesi (kullanici) - SALT OKUNUR, elle satir eklenmez/silinmez;
            //   KisiDeposu.BaglaAsync/KoparAsync yonetir (041_taraf_gecmis.sql).
            new DetayTanimi("gecmis", "public.taraf_gecmis", "kisi_id", new KartAlani[]
            {
                new("id",             "id",              "sayi", Yazilabilir: false),
                new("cariId",         "cari_id",         "kod",  KodTablosu: "public.v_cari_lookup", Baslik: "Cari"),
                new("baslamaTarihi",  "baslama_tarihi",  "tarih", Baslik: "Başlama"),
                new("bitisTarihi",    "bitis_tarihi",    "tarih", Baslik: "Bitiş")
            }, Sirala: "bitis_tarihi desc nulls first, baslama_tarihi desc", SubeKolonu: null,
               Baslik: "Geçmiş", SaltOkunur: true)
        });

    // ----------------------------------------------------------- personel ----
    // Kisi'den FARKLI: Ad/Soyad KULLANILIYOR (kullanici bunu bilerek IK/hasta kartlarina
    //   saklamisti - 038_kisi_karti_unvan_geri_al.sql yorumu). "unvan" kolonu (taraf'ta
    //   NOT NULL) UI'da hic gorunmez - GenForm.tsx Kaydet'te ad+soyad'dan birlestirilip
    //   gonderilir (KişI'deki gibi bir DB trigger DEGIL - Kişi'de trigger user'in elle
    //   yazdigi Unvan'i sessizce ezme riski tasiyordu; burada unvan zaten hic gosterilip
    //   duzenlenmedigi icin risk yok, DB seviyesinde tetikleyici gerekmiyor).

    // ----------------------------------------------------------- personel ----
    // Kisi'den FARKLI: Ad/Soyad KULLANILIYOR (kullanici bunu bilerek IK/hasta kartlarina
    //   saklamisti - 038_kisi_karti_unvan_geri_al.sql yorumu). "unvan" kolonu (taraf'ta
    //   NOT NULL) UI'da hic gorunmez - GenForm.tsx Kaydet'te ad+soyad'dan birlestirilip
    //   gonderilir (KişI'deki gibi bir DB trigger DEGIL - Kişi'de trigger user'in elle
    //   yazdigi Unvan'i sessizce ezme riski tasiyordu; burada unvan zaten hic gosterilip
    //   duzenlenmedigi icin risk yok, DB seviyesinde tetikleyici gerekmiyor).
    private static KartTanimi Personel() => new(
        Ad: "personel",
        YetkiKodu: "personel",
        Tablo: "public.taraf",
        LogTabloId: 73,                       // eski GENINI TABLOID: IK = 73 (bkz. silme-geri-al-tuzaklari)
        SabitKosul: "personel = 1",
        SubeKolonu: null,                     // Kisi liste kaynagiyla tutarli - ana veri, ortak
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["personel"] = (short)1, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",        "id",         "sayi",  Yazilabilir: false),
            // Kisi'deki "kisi" alani ile ayni sebep: YeniKayitVarsayilanlari'ndaki
            //   "personel"=1 buraya yazilabilsin diye tanimli, UI'da gizli (GenForm.tsx).
            new("personel",  "personel",   "mantik", Baslik: "Personel"),
            // "unvan" UI'da GIZLI (gizli Set, GenForm.tsx). PERSONELDE YALNIZ ONEK
            //   (940, kullanici: "personelde unvan tam adi tutmasin, sadece Dr. veya
            //   Prof.Dr. gibi olsun"): kartin unvan combo'sundan gelir, unvansiz
            //   personelde BOS. Gorunen ad public.fn_taraf_ad(unvan, ad, soyad).
            //   Zorunlu degil; hasta kartinda (tam ad) yeniden zorunlu yapilir.
            new("unvan",     "unvan",      "metin", EnFazlaUzunluk: 120, Baslik: "Unvan"),
            new("kod",       "kod",        "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Sicil No", Grup: "Kimlik"),
            new("ad",        "ad",         "metin", Zorunlu: true, EnFazlaUzunluk: 50, Baslik: "Ad", Grup: "Kimlik"),
            new("soyad",     "soyad",      "metin", Zorunlu: true, EnFazlaUzunluk: 60, Baslik: "Soyad", Grup: "Kimlik"),
            // Departman kod listesi degil TABLO (251): bolum/hekim iliskisi de
            //   buradan kuruluyor - randevu bolumu bir departmandir.
            // BOLUM ve GOREV KILITLI (840, kullanici: "personel kartından işe
            //   giriş/çıkış, bölüm, görev bilgilerini çıkarsak mı"): ilk
            //   kayitta girilir, sonra yalniz KADRO HAREKETI degistirir -
            //   kartta tarihsiz duzeltmek gecmisi sessizce bozardi.
            //   Alan GORUNMEYE DEVAM EDER: "bu kisi hangi bolumde" gunluk
            //   sorudur ve kart onun yeri; ustelik 25 ekran bu kolonlari
            //   okuyor.
            new("departman", "departman",  "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Kimlik",
                YalnizYeniKayitta: true, Ipucu: "Kadro Geçmişi'nden değişir"),
            // RANDEVU VERILEBILIR (252, kullanici: "randevu verilen bolumle
            //   randevu verilen personel bulusmus olur") - departman tarafinda
            //   da ayni bayrak var (251); ikisi kesisince "hekim" cikar.
            // Grup VERILMEZ: "Kimlik" grubu kartin UST SERIDINI besliyor, alan
            //   orada degil İş Bilgileri kutusunda cizilir (252, kullanici).
            // "randevuVerilebilir" KALKTI (711): hekim randevu alir mi = calisma
            //   plani var mi (Randevu › Çalışma Planları). Kolon DB'de duruyor.
            new("durum",     "durum",      "kod",   SabitKodlar: DurumKodlari, Baslik: "Durum", Grup: "Kimlik"),
            // ik_karti.html mockup'ta idstrip'te DEGIL - Görev "Pozisyon" adiyla Genel
            //   sekmesinin "Özet" kutusunda (PersonelKimlikOzet.tsx). TCKN de "Kimlik
            //   Bilgileri" kutusunda - ikisi de adsiz (Grup yok), gizli Set (GenForm.tsx)
            //   ile genel/duz render'dan cikarilip ozel bilesene props olarak geciyor.
            // Pozisyon KOD (236, kullanici: "combo ve ID olarak olsun") - eski
            //   serbest metin kolonu (taraf.gorev) veri olarak duruyor.
            // Gorev artik kod listesi degil TABLO (255) ve DEPARTMANA BAGLI:
            //   secilen departmanin gorevleri + bagimsiz gorevler listelenir
            //   (kullanici: "personel kartinda departmana gore bu gorev listesi
            //   gelecek ve secilecek").
            new("gorevId",   "gorev_id",   "kod",   Zorunlu: true,
                KodTablosu: "public.v_gorev_lookup", BagliAlan: "departman",
                Baslik: "Görev",
                YalnizYeniKayitta: true, Ipucu: "Kadro Geçmişi'nden değişir"),
            new("vkno",      "vkno",       "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Kimlik No"),
            // ik_karti.html mockup'ta İletişim AYRI SEKME (Genel'e gomulu AltGrup DEGIL) -
            //   Grup:"İletişim" bu yuzden AltGrup degil.
            new("telefon",   "telefon",    "metin", EnFazlaUzunluk: 30,  Baslik: "Ev Telefonu",         Grup: "İletişim"),
            new("cepTel",    "cep_tel",    "metin", Zorunlu: true, EnFazlaUzunluk: 30,  Baslik: "Cep",        Grup: "İletişim"),
            new("eposta",    "eposta",     "metin", Zorunlu: true, EnFazlaUzunluk: 120, Baslik: "E-posta (İş)", Grup: "İletişim"),
            new("epostaWeb", "eposta_web", "metin", EnFazlaUzunluk: 200, Baslik: "E-posta (Kişisel)",   Grup: "İletişim"),
            // Diger kartlarda subeId salt-okunur/gizli meta alan - Personel'de kullanici
            //   isteğiyle GERCEK VERI: "Çalıştığı Şube" (kullanici: "taraf subeid de
            //   personelin Çalıştığı Şube yi tut"). Yazilabilir + KodTablosu ile secilebilir;
            //   bos birakilirsa oturumun subesi otomatik yazilir (KartDeposu.EkleAsync).
            new("subeId",        "sube_id",       "kod",   KodTablosu: "public.sube", Baslik: "Çalıştığı Şube"),
            new("eklemeTarihi",  "ekleme_tarihi", "tarih", Yazilabilir: false)
        },
        Detaylar: new[]
        {
            // KADRO GECMISI (840, kullanici: "personel kartına kadro geçmişi
            //   sekmesini de ekle"): kisinin pozisyon defteri. Her satir o
            //   tarihte gecerli TAM pozisyon; kart (taraf_personel) buradan
            //   TURETILIR - satir eklenince DB tetigi ozluk alanlarini yazar.
            //
            //   SILME/EKLEME ACIK ama kolon seti DAR: bolum, sozlesme, karar
            //   numarasi gibi alanlar ayri ekranda (Ik & Prim > Kadro
            //   Hareketleri). Kartta gunluk soru "ne zaman ne oldu" -
            //   on kolonluk grid onu gizlerdi.
            new DetayTanimi("kadro", "public.personel_hareket", "taraf_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("yururluk", "yururluk", "tarih", Zorunlu: true, Baslik: "Yürürlük"),
                new("tur", "tur", "kod", Zorunlu: true, Baslik: "Hareket",
                    SabitKodlar: KaynakKatalogu.KadroTurKodlari),
                // BOLUM + GOREV (842, kullanici: "kadro gecmisine bolum ve gorev
                //   gelmemis"): kartta kilitli olan iki alan BURADAN degisir -
                //   defterde gorunmemeleri sekmeyi iseyaramaz kiliyordu.
                //   Gorev departmana bagli (kartla ayni kural).
                new("departmanId", "departman_id", "kod", Baslik: "Bölüm",
                    KodTablosu: "public.v_departman_lookup"),
                new("gorevId", "gorev_id", "kod", Baslik: "Görev",
                    KodTablosu: "public.v_gorev_lookup", BagliAlan: "departmanId"),
                // ANA ROL (843): gorevin YETKI karsiligi. Kullanici kartinda
                //   personel icin kilitli - tek degistirme yeri burasi.
                new("rolId", "rol_id", "kod", Baslik: "Ana Rol",
                    KodTablosu: "public.v_rol_agac_lookup", Agac: true),
                // Serbest metin unvan: katalog disi kadro unvani icin durur.
                new("gorev", "gorev", "metin", EnFazlaUzunluk: 100, Baslik: "Unvan (serbest)"),
                new("yoneticiTarafId", "yonetici_taraf_id", "kod", Baslik: "Yönetici",
                    KodTablosu: "public.v_personel_grup_lookup", Gruplu: true),
                // SURELI HAREKET: vekalet/aski bitince onceki pozisyon geri gelir.
                new("bitis", "bitis", "tarih", Baslik: "Bitiş (süreli ise)"),
                new("gerekce", "gerekce", "metin", EnFazlaUzunluk: 300, Baslik: "Gerekçe"),
                // KAYNAK OKUNUR: karttan turetilen satiri "elle girildi"
                //   yapmak izi bozardi.
                new("kaynak", "kaynak", "kod", Yazilabilir: false, Baslik: "Kaynak",
                    SabitKodlar: KaynakKatalogu.KadroKaynakKodlari),
            }, Sirala: "yururluk desc, id desc", Baslik: "Kadro Geçmişi",
               LogTabloId: 1325),
            // PRIM ROLLERI (361): kisi hangi rolde prim alabilir. Bir kisi hem
            //   isteyen hem yapan hem uygulayan olabilir - o yuzden GRID, tek
            //   secim degil.
            //
            // DIS HEKIM (808): "Gonderen" ORTUKTUR (Calisma Sekli "Primli"
            //   olan her dis hekim gonderen adayidir), burada yalnizca
            //   "Raporlayan" isaretlenir - teleradyolojide isi disaridan
            //   calisan radyolog yapiyor. Kurali DB dogrular
            //   (tg_taraf_prim_rol_dogrula).
            new DetayTanimi("primRolleri", "public.taraf_prim_rol", "taraf_id", new KartAlani[]
            {
                // ID SART (387): cerceve detay satirlarini `id` ile adresler
                //   (insert'te returning id). Tabloda kolon YOKTU ve grid
                //   "column id does not exist" ile 500 veriyordu.
                new("id", "id", "sayi", Yazilabilir: false),
                new("rol", "rol", "kod", Zorunlu: true, KodListesi: "prim.rol",
                    Baslik: "Prim Rolü"),
                // Onerilen: basvuru hekim combosu ve prim rol modali once
                //   isaretlileri gosterir (uzun listede aranan kisi ustte olsun).
                new("varsayilan", "varsayilan", "mantik", Baslik: "Önerilen"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Açıklama")
            }, SubeKolonu: null, Sirala: "rol", Baslik: "Prim Rolleri", LogTabloId: 1291,
               // SEKME YALNIZ "PRIMLI" PERSONELDE (kullanici): prim almayan
               //   kadrolu personelde bos bir rol gridi gostermek, doldurulacak
               //   bir sey varmis izlenimi veriyordu. Isaret ozluk (1:1
               //   taraf_personel) satirinda oldugu icin kosul DETAY ALANINA
               //   bakar - "ozluk.calismaSekli=3".
               KosulAlani: "ozluk.calismaSekli=3"),
            // Kisi ile AYNI taraf_adres tablosu, AYNI Ev/İş tur listesi (kisisel adres).
            new DetayTanimi("adresler", "public.taraf_adres", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("tur",        "tur",         "kod",   SabitKodlar: KisiAdresTurKodlari, Baslik: "Adres Tipi", Zorunlu: true),
                new("adres",      "adres",       "metin", EnFazlaUzunluk: 300),
                new("il",         "il",          "metin", EnFazlaUzunluk: 60),
                new("ilce",       "ilce",        "metin", EnFazlaUzunluk: 60),
                new("ulke",       "ulke",        "metin", EnFazlaUzunluk: 60),
                new("postaKodu",  "posta_kodu",  "metin", EnFazlaUzunluk: 10),
                new("varsayilan", "varsayilan",  "mantik"),
                new("aktif",      "aktif",       "mantik")
            }, Sirala: "varsayilan desc, id", LogTabloId: 901),
            // ik_karti.html İletişim sekmesi: "Acil Durumda Aranacak Kişiler"
            // REHBERILETISIM (1:N) mockup karsiligi. Ayrı sekme degil, İletişim
            // sekmesinde Ev Adresi'nin altina gomulu grid olarak render edilir.
            // 335: tablo ORTAK (taraf_acil_kisi) - personelin acil kisisi ile
            //   hastanin yakini ayni bilgidir, iki karttan da ayni tabloya yazilir.
            new DetayTanimi("acilKisiler", "public.taraf_acil_kisi", "taraf_id", new KartAlani[]
            {
                new("id",         "id",          "sayi",  Yazilabilir: false),
                new("varsayilan", "varsayilan",  "mantik", Baslik: "★"),
                new("adSoyad",    "ad_soyad",    "metin", EnFazlaUzunluk: 120, Baslik: "Ad Soyad", Zorunlu: true),
                new("yakinlik",   "yakinlik",    "kod",   SabitKodlar: YakinlikKodlari, Baslik: "Yakınlık"),
                new("telefon",    "telefon",     "metin", EnFazlaUzunluk: 30,  Baslik: "Telefon"),
                new("eposta",     "eposta",      "metin", EnFazlaUzunluk: 120, Baslik: "e-Posta"),
                // 374: TC kimlik ya da yabanci kimlik/pasaport - metin, 11 hane
                //   zorunlulugu yok (yakin yabanci olabilir).
                new("kimlikNo",   "kimlik_no",   "metin", EnFazlaUzunluk: 20,  Baslik: "Kimlik No")
            }, Sirala: "varsayilan desc, sira, id", LogTabloId: 906, Baslik: "Acil Durumda Aranacak Kişiler"),
            // Ozluk - taraf_personel 1:1 (id = taraf.id). Kisi'nin TekAdres'i gibi TEK SATIR gosterilir
            //   (TekOzluk.tsx) - satir ekle/sil YOK, tek satir hep var/yok.
            new DetayTanimi("ozluk", "public.taraf_personel", "id", new KartAlani[]
            {
                new("id",                 "id",                  "sayi",  Yazilabilir: false),
                new("dogumTarihi",        "dogum_tarihi",        "tarih", Zorunlu: true, Baslik: "Doğum Tarihi"),
                new("dogumYeri",          "dogum_yeri",          "metin", EnFazlaUzunluk: 60, Baslik: "Doğum Yeri"),
                // Cinsiyet/medeni hal/uyruk KOD LISTESINDEN (609): listelerin
                //   icerigi SKRS'den birebir cekildi, kodda elle yazilmis
                //   kisaltilmis kopya tutmuyoruz. Elle yazilan liste iki
                //   secenekti (Erkek/Kadin); SKRS'de dort - "belirtilmedi"
                //   ve "belirsiz" de gecerli kayit degerleri.
                // ZORUNLU (kullanıcı: "personel kartında cinsiyet zorunlu alan olmalı").
                new("cinsiyet",           "cinsiyet",            "kod",   Zorunlu: true, KodListesi: "hasta.cinsiyet", Baslik: "Cinsiyet"),
                // GIRIS/CIKIS TARIHI KILITLI (840): ikisi de kadro
                //   hareketinin yururlugudur (tur 1 giris, tur 9 cikis).
                //   Kidem ve izin hakki bu tarihten hesaplandigi icin
                //   tarihsiz duzeltme izin bakiyesini de bozardi.
                new("iseGirisTarihi",     "ise_giris_tarihi",    "tarih", Zorunlu: true, Baslik: "İşe Giriş Tarihi",
                    YalnizYeniKayitta: true, Ipucu: "Kadro Geçmişi'nden değişir"),
                new("istenCikisTarihi",   "isten_cikis_tarihi",  "tarih", Baslik: "İşten Çıkış Tarihi",
                    YalnizYeniKayitta: true, Ipucu: "Kadro Geçmişi'nden (İşten çıkış)"),
                new("calismaSekli",       "calisma_sekli",       "kod",   SabitKodlar: CalismaSekliKodlari, Baslik: "Çalışma Şekli"),
                // NET MAAŞ (960): bordro yok - avans kartının "maaşa oranı" paneli için.
                new("netMaas",            "net_maas",            "para",  Baslik: "Aylık Net Maaş", Ipucu: "Avans kartında maaşa oranı için"),
                // Uyruk artik SKRS ULKE KODLARI'ndan secilir (614/615): alan
                //   metin degil kod, degeri MERNIS kodudur ve e-Nabiz'a
                //   ceviri olmadan gider. Serbest metinken "TC", "TR",
                //   "Türkiye" hepsi ayni seyi yaziyordu ve hicbiri USS'nin
                //   kabul ettigi kod degildi.
                new("uyruk",              "uyruk",               "kod",   KodTablosu: "public.v_skrs_ulke_lookup", Baslik: "Uyruğu"),
                new("vardiyaTuru",        "vardiya_turu",        "kod",   SabitKodlar: VardiyaTuruKodlari, Baslik: "Vardiya Türü"),
                new("sgkBaslamaTarihi",   "sgk_baslama_tarihi",  "tarih", Baslik: "SGK Başlama Tarihi"),
                new("medeniHal",          "medeni_hal",          "kod",   KodListesi: "hasta.medeni_hal", Baslik: "Medeni Hal"),
                // taraf.kan_grubu ile AYNI kod_liste (hasta hazirligi icin bosti, 8 standart
                //   kan grubuyla dolduruldu, 049) - ileride Hasta karti da bunu kullanacak.
                new("kanGrubu",           "kan_grubu",           "kod",   KodListesi: "taraf.kan_grubu", Baslik: "Kan Grubu"),
                new("sozlesmeTuru",       "sozlesme_turu",       "kod",   SabitKodlar: SozlesmeTuruKodlari, Baslik: "Sözleşme Türü"),
                new("denemeSuresi",       "deneme_suresi",       "kod",   SabitKodlar: DenemeSuresiKodlari, Baslik: "Deneme Süresi"),
                // ik_karti.html mockup uyum turu (054): SGK Sicil No/Meslek Kodu/Yonetici.
                new("sgkSicilNo",         "sgk_sicil_no",        "metin", EnFazlaUzunluk: 30, Baslik: "SGK Sicil No"),
                new("meslekKodu",         "meslek_kodu",         "kod",   KodTablosu: "public.v_skrs_meslek_lookup", Baslik: "Meslek Kodu"),
                new("yoneticiId",         "yonetici_taraf_id",   "kod",   KodTablosu: "public.v_personel_grup_lookup", Gruplu: true, Baslik: "Yönetici")
            }, Baslik: "Özlük"),
            // ik_karti.html mockup "İzinler" sekmesi (IZIN 1:N) - GERCEK COKLU-SATIR grid,
            //   generic GenDetayTablo (satir ekle/sil) yeterli, ozel bilesen gerekmiyor.
            new DetayTanimi("izinler", "public.personel_izin", "taraf_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("tur",              "tur",               "kod",   SabitKodlar: IzinTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("baslangicTarihi",  "baslangic_tarihi",  "tarih", Zorunlu: true, Baslik: "Başlama"),
                new("bitisTarihi",      "bitis_tarihi",      "tarih", Zorunlu: true, Baslik: "Bitiş"),
                // Gün elle girilmez: baslangic/bitis'ten hesaplanir (iki uc dahil).
                new("gun",              "gun",               "sayi",  Yazilabilir: false, Baslik: "Gün"),
                new("aciklama",         "aciklama",          "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama"),
                new("durum",            "durum",             "kod",   SabitKodlar: IzinDurumuKodlari, Baslik: "Durum")
            }, Sirala: "baslangic_tarihi desc, id desc", LogTabloId: 904, Baslik: "İzinler"),
            // ik_karti.html mockup "Eğitim / Sertifika" sekmesi (PERSONELEGITIM 1:N).
            new DetayTanimi("egitimler", "public.personel_egitim", "taraf_id", new KartAlani[]
            {
                new("id",          "id",          "sayi",  Yazilabilir: false),
                new("tur",         "tur",         "kod",   SabitKodlar: EgitimTuruKodlari, Baslik: "Tür", Zorunlu: true),
                new("ad",          "ad",          "metin", EnFazlaUzunluk: 200, Baslik: "Ad", Zorunlu: true),
                new("kurum",       "kurum",       "metin", EnFazlaUzunluk: 150, Baslik: "Kurum"),
                // Yalnız yıl (2024) veya normal tarih metni (2024-06-15 / 15.06.2024)
                // tutulabilir; DB kolonu 055 ile varchar(10) yapıldı.
                new("tarih",       "tarih",       "metin", EnFazlaUzunluk: 10, Baslik: "Tarih/Yıl"),
                new("gecerlilik",  "gecerlilik",  "metin", EnFazlaUzunluk: 60, Baslik: "Geçerlilik")
            }, Sirala: "tarih desc nulls last, id desc", LogTabloId: 905, Baslik: "Eğitim / Sertifika"),
            // BELGE TAKİBİ (1135, mockup Ekranlar/IK/personel_belge_takibi.html): elindeki özlük belgeleri.
            //   Geçerlilik boş bırakılırsa belge tarihi + türün süresi (tetik).
            new DetayTanimi("belgeler", "public.personel_belge", "taraf_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("belgeTuruId",      "belge_turu_id",     "kod",   KodTablosu: "public.v_personel_belge_turu_lookup", Baslik: "Belge", Zorunlu: true),
                new("belgeTarihi",      "belge_tarihi",      "tarih", Baslik: "Belge tarihi"),
                new("gecerlilikTarihi", "gecerlilik_tarihi", "tarih", Baslik: "Geçerlilik (boş = türden)"),
                new("belgeNo",          "belge_no",          "metin", EnFazlaUzunluk: 60, Baslik: "Belge no"),
                new("aciklama",         "aciklama",          "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama"),
                // 1136: satırın dosyaları sekmenin altındaki panelde (dokuman 'personel-belge').
                new("dosyaSayisi",      "(select count(*)::integer from public.dokuman dk where dk.kaynak = 'personel-belge' and dk.kaynak_id = personel_belge.id)",
                    "sayi", Yazilabilir: false, Baslik: "Dosya"),
            }, Sirala: "belge_tarihi desc nulls last, id desc", LogTabloId: LogPersonelBelge, Baslik: "Belgeler"),
            // DURUM (salt okunur): şablona göre eksik / süresi doldu / yaklaşıyor / tamam.
            //   Ayrı sekme DEĞİL (kullanıcı 22.10.2026 "tek olsun"): Belgeler sekmesinin
            //   üstünde özet + liste olarak çizilir (web PersonelBelgePaneli).
            new DetayTanimi("belgeDurumu", "public.v_personel_belge_durum", "personel_id", new KartAlani[]
            {
                new("id",               "id",                "sayi",  Yazilabilir: false),
                new("belgeTuruId",      "belge_turu_id",     "sayi",  Yazilabilir: false),
                new("belgeId",          "belge_id",          "sayi",  Yazilabilir: false),
                new("durum",            "durum",             "sayi",  Yazilabilir: false),
                new("grup",             "grup",              "sayi",  Yazilabilir: false),
                new("grupAdi",          "grup_adi",          "metin", Yazilabilir: false, Baslik: "Grup"),
                new("belge",            "belge",             "metin", Yazilabilir: false, Baslik: "Belge"),
                new("zorunlu",          "zorunlu",           "mantik", Yazilabilir: false, Baslik: "Zorunlu"),
                new("durumAdi",         "durum_adi",         "metin", Yazilabilir: false, Baslik: "Durum"),
                new("belgeTarihi",      "belge_tarihi",      "tarih", Yazilabilir: false, Baslik: "Belge tarihi"),
                new("gecerlilikTarihi", "gecerlilik_tarihi", "tarih", Yazilabilir: false, Baslik: "Geçerlilik"),
                new("kalanGun",         "kalan_gun",         "sayi",  Yazilabilir: false, Baslik: "Kalan gün"),
                new("dosyaSayisi",      "dosya_sayisi",      "sayi",  Yazilabilir: false, Baslik: "Dosya"),
                new("hatirlatGun",      "(select bt.hatirlat_gun from public.personel_belge_turu bt where bt.id = v_personel_belge_durum.belge_turu_id)",
                    "sayi",  Yazilabilir: false),
            // Sıra = görünümün id'si (grup, tür sırası, ad): mockup grup grup listeler.
            }, Sirala: "id", SubeKolonu: null, SaltOkunur: true, Baslik: "Belge Durumu"),
            // HEKIMIN RANDEVU DUZENI SEKMESI KALDIRILDI: randevu saatleri artik
            //   CALISMA PLANINDAN gelir (hekim_calisma_sablon) - randevu_bolum_ayar
            //   satirlari yalniz plani olmayan doktorun eski yedek duzenidir.
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.taraf_kullanici", "id", "Bu kart bir kullaniciya bagli, silinemez.")
        });

}
