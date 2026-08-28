namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// FIRMA / SUBE KARTI - e-Belgede GONDERICI TARAF.
///
/// Belge GIB'e giderken gonderen bilgileri buradan okunur: unvan, VKN, vergi
/// dairesi, adres, iletisim, Mersis / ticaret sicil. Alanlar `sube` tablosunda
/// ZATEN vardi ama duzenlenecek bir ekran yoktu - Merkez subede unvan ve VKN
/// disinda her sey bostu ve e-Belge gonderimi bu yuzden yapilamazdi.
///
/// SUBE BAZLI (firma geneli ayar DEGIL): cok subeli firmada fatura hangi
/// subeden kesildiyse ONUN adresi ve alias'i gider. Tek subeli kurulumda da
/// aynen calisir - Merkez tek kayittir.
///
/// BLOK DUZENI mockup'tan (Ekranlar/firma_bilgileri.html, "Kimlik" sekmesi):
///   Kimlik      -> "Firma Kimliği" + "Kayıt" alt gruplari
///   Adres       -> "Merkez Adresi" + "İletişim"
///   e-Belge     -> mukellefiyet, gonderici kimligi (169) ve etiket
///
/// Mockup'taki "Yetkili / İmza", "Faaliyet" ve "Kayıt Bilgisi" bloklari
/// BILEREK YOK: kullanici istemedi.
/// </summary>
public static partial class KartKatalogu
{
    private static KartTanimi Sube() => new(
        Ad: "sube",
        YetkiKodu: "sube",
        Tablo: "public.sube",
        LogTabloId: 923,
        // Subenin KENDISI sube kolonu tasimaz - kayit zaten subedir.
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1, ["varsayilan"] = (short)0, ["ulke"] = "Türkiye",
            ["efaturaMukellef"] = (short)0, ["earsivMukellef"] = (short)0,
            ["eirsaliyeMukellef"] = (short)0,
            // Yeni sube MERKEZIN mali ayarlarini kullanir (192) - ayri VKN
            //   alinca kullanici bayragi kaldirip kendi ayarini girer.
            ["merkezMaliKullan"] = (short)1,
            ["merkezGorselKullan"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),

            // ------------------------------------------- Kimlik / Firma Kimliği
            // Mockup sirasi: Ünvan · Kısa Ad · VKN · Vergi Dairesi ·
            //   Ticaret Sicil · Oda · Oda Sicil; Mersis ve NACE "Kayıt" altinda.
            // UNVAN e-Belgede gorunen resmi addir; "ad" ic kullanim icin kisa ad.
            new("unvan", "unvan", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Ünvan", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("ad",    "ad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Kısa Ad", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            // VKN ZORUNLU (mockup'ta kirmizi cerceve): e-Belge, tahakkuk ve resmi
            //   yazismalarin tamami buna bagli.
            new("vkno",  "vkno",  "metin", Zorunlu: true, EnFazlaUzunluk: 11,
                Baslik: "VKN / TCKN", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("vd",    "vd",    "metin", EnFazlaUzunluk: 60,
                Baslik: "Vergi Dairesi", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            // Ticaret sicil ve Mersis mockup'ta KIMLIK kutusunda (e-Belge sekmesinde
            //   degil): ikisi de firmanin resmi kimligi, e-Belge onlari kullanir.
            new("ticaretSicilNo", "ticaret_sicil_no", "metin", EnFazlaUzunluk: 30,
                Baslik: "Ticaret Sicil No", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("ticaretOdasi",  "ticaret_odasi",  "metin", EnFazlaUzunluk: 120,
                Baslik: "Ticaret Odası", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("odaSicilNo",    "oda_sicil_no",   "metin", EnFazlaUzunluk: 40,
                Baslik: "Oda Sicil No", Grup: "Kimlik", AltGrup: "Firma Kimliği"),

            // ------------------------------------------------- Kimlik / Kayıt
            // Kartin kendi kayit alanlari. Mockup'taki "Kayıt Bilgisi" kutusu
            //   (kayit tarihi / doluluk cubugu) ve "Faaliyet" kutusu kullanici
            //   karariyla ALINMADI.
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan Şube", Grup: "Kimlik", AltGrup: "Kayıt"),
            new("firmaTuru", "firma_turu", "kod", KodListesi: "sube.firma_turu",
                Baslik: "Firma Türü", Grup: "Kimlik", AltGrup: "Kayıt"),
            new("kod",   "kod",   "metin", EnFazlaUzunluk: 20,
                Baslik: "Firma Kodu", Grup: "Kimlik", AltGrup: "Kayıt"),
            // Mersis ve NACE resmi SICIL bilgisi: unvan/VKN gibi her belgede
            //   kullanilmaz, kayit bilgisiyle birlikte durur (kullanici).
            new("mersisNo", "mersis_no", "metin", EnFazlaUzunluk: 20,
                Baslik: "Mersis No", Grup: "Kimlik", AltGrup: "Kayıt"),
            new("naceKodu", "nace_kodu", "metin", EnFazlaUzunluk: 20,
                Baslik: "NACE Kodu", Grup: "Kimlik", AltGrup: "Kayıt"),
            new("aktif",      "aktif",      "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik", AltGrup: "Kayıt"),

            // ----------------------------------------------------------- Adres
            new("adres",      "adres",      "metin", EnFazlaUzunluk: 300,
                Baslik: "Adres", Grup: "Adres", AltGrup: "Merkez Adresi"),
            new("ilce",       "ilce",       "metin", EnFazlaUzunluk: 60,
                Baslik: "İlçe", Grup: "Adres", AltGrup: "Merkez Adresi"),
            new("il",         "il",         "metin", EnFazlaUzunluk: 60,
                Baslik: "İl", Grup: "Adres", AltGrup: "Merkez Adresi"),
            new("ulke",       "ulke",       "metin", EnFazlaUzunluk: 60,
                Baslik: "Ülke", Grup: "Adres", AltGrup: "Merkez Adresi"),
            new("postaKodu",  "posta_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "Posta Kodu", Grup: "Adres", AltGrup: "Merkez Adresi"),

            new("telefon", "telefon", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon", Grup: "Adres", AltGrup: "İletişim"),
            new("gsm",      "gsm",      "metin", EnFazlaUzunluk: 30,
                Baslik: "GSM", Grup: "Adres", AltGrup: "İletişim"),
            new("eposta",  "eposta",  "metin", EnFazlaUzunluk: 120,
                Baslik: "E-posta", Grup: "Adres", AltGrup: "İletişim"),
            // KEP resmi bildirim adresi - e-Belge ve yasal yazismada kullanilir.
            new("kepAdresi", "kep_adresi", "metin", EnFazlaUzunluk: 120,
                Baslik: "KEP Adresi", Grup: "Adres", AltGrup: "İletişim"),
            new("web",       "web",        "metin", EnFazlaUzunluk: 200,
                Baslik: "Web Sitesi", Grup: "Adres", AltGrup: "İletişim"),

            // -------------------------------------------------------- Depolar
            // Bayrak SUBEDE, depoda degil: "bu sube hangi depolari kullanir"
            //   karari subenin ozelligi. Isaretliyse sube KENDI depolarini
            //   tutmaz, merkezinkileri kullanir (174) - depo listesi de
            //   gosterilmez.
            new("merkezDepoKullan", "merkez_depo_kullan", "mantik",
                Baslik: "Merkez deposunu kullan", Grup: "Depolar"),

            // --------------------------------------------------------- e-Belge
            // Alias gonderici etiketidir, mukellef bayraklari hangi belgeyi
            //   kesebilecegimizi soyler.
            // KIMLIK KAYNAGI (169): sube kendi VKN'siyle mi gonderiyor, merkezin
            //   kimligiyle mi. Alias ve Mersis/sicil de bu secimi izler - GIB posta
            //   kutusu VKN'ye bagli oldugu icin ikisi ayrilamaz.
            new("ebelgeKimlik", "ebelge_kimlik", "kod", KodListesi: "sube.ebelge_kimlik",
                Baslik: "Gönderici Kimliği", Grup: "e-Belge", AltGrup: "Gönderici"),
            new("ustSubeId",    "ust_sube_id",   "kod", KodTablosu: "public.sube",
                Baslik: "Bağlı Olduğu Merkez", Grup: "e-Belge", AltGrup: "Gönderici"),
            // MUKELLEF HESABI (171): entegrator baglantisi mukellefe aittir -
            //   ayri VKN'li sube ayri kullanici/sifre ile baglanir. Onceden firma
            //   geneli ayardaydi, cok mukellefli kurulum mumkun degildi.
            new("entegratorId",  "entegrator_id", "kod",
                KodTablosu: "public.v_ebelge_entegrator_lookup",
                Baslik: "Entegratör", Grup: "e-Belge", AltGrup: "Mükellef Hesabı"),
            new("entegratorKullanici", "entegrator_kullanici", "metin", EnFazlaUzunluk: 120,
                Baslik: "Kullanıcı", Grup: "e-Belge", AltGrup: "Mükellef Hesabı"),
            new("entegratorSifre",     "entegrator_sifre",     "metin", EnFazlaUzunluk: 200,
                Baslik: "Şifre", Grup: "e-Belge", AltGrup: "Mükellef Hesabı"),
            // Test ortami SUBE BAZLI: bir mukellef canliya gecmisken yeni acilan
            //   sube hala testte olabilir.
            new("testOrtami",    "test_ortami",    "mantik",
                Baslik: "Test Ortamı", Grup: "e-Belge", AltGrup: "Test Ortamı"),
            new("testKullanici", "test_kullanici", "metin", EnFazlaUzunluk: 120,
                Baslik: "Test Kullanıcısı", Grup: "e-Belge", AltGrup: "Test Ortamı"),
            new("testSifre",     "test_sifre",     "metin", EnFazlaUzunluk: 200,
                Baslik: "Test Şifresi", Grup: "e-Belge", AltGrup: "Test Ortamı"),

            new("efaturaAlias",      "efatura_alias",       "metin", EnFazlaUzunluk: 500,
                Baslik: "e-Fatura Gönderici Etiketi", Grup: "e-Belge", AltGrup: "Gönderici"),
            new("ebelgeSeri",        "ebelge_seri",         "metin", EnFazlaUzunluk: 3,
                Baslik: "Varsayılan Seri", Grup: "e-Belge", AltGrup: "Gönderici"),
            new("efaturaMukellef",   "efatura_mukellef",    "mantik",
                Baslik: "e-Fatura Mükellefi", Grup: "e-Belge", AltGrup: "Mükellefiyet"),
            new("earsivMukellef",    "earsiv_mukellef",     "mantik",
                Baslik: "e-Arşiv Mükellefi", Grup: "e-Belge", AltGrup: "Mükellefiyet"),
            new("eirsaliyeMukellef", "eirsaliye_mukellef",  "mantik",
                Baslik: "e-İrsaliye Mükellefi", Grup: "e-Belge", AltGrup: "Mükellefiyet"),
            // Mukellefiyet bayragi ayni zamanda TUR SEKMESININ gorunurlugunu
            //   belirler (172): mukellefi olmadigimiz turun ayarlari cizilmez.
            new("esmmMukellef",      "esmm_mukellef",       "mantik",
                Baslik: "e-SMM Mükellefi", Grup: "e-Belge", AltGrup: "Mükellefiyet"),

            // ------------------------------------------------------------ Mali
            // MOCKUP: Ekranlar/firma_bilgileri.html › Mali sekmesi.
            //
            // ŞUBE BAZLI MI? Ayrim "sube ayri VKN tasiyor mu" sorusuna bagli ve
            //   bu semada tasiyabiliyor. Bu yuzden ayarlar SUBEDE durur ve
            //   "Merkezin mali ayarlarini kullan" isaretliyse merkezden okunur
            //   (fn_sube_mali) - e-Belge'deki merkez kimligi deseninin aynisi.
            //
            //   Defter turu, KDV/gecici vergi donemi, amortisman, para birimi,
            //   ondalik ve yuvarlama HER ZAMAN merkezden gelir: iki sube farkli
            //   ondalikla calisirsa ayni fiste iki yuvarlama cikar, mizan tutmaz.
            //   Bu alanlar sube kartinda da gorunur ama etkin deger merkezinkidir.
            new("merkezMaliKullan", "merkez_mali_kullan", "mantik",
                Baslik: "Merkezin mali ayarlarını kullan", Grup: "Mali", AltGrup: "Ayar Kaynağı"),

            new("defterTuru",        "defter_turu",         "kod", KodListesi: "mali.defter_turu",
                Baslik: "Defter Tutma Şekli", Grup: "Mali", AltGrup: "Mali Dönem"),
            new("kdvDonem",          "kdv_donem",           "kod", KodListesi: "mali.kdv_donem",
                Baslik: "KDV Dönemi", Grup: "Mali", AltGrup: "Mali Dönem"),
            new("geciciVergiDonem",  "gecici_vergi_donem",  "kod", KodListesi: "mali.gecici_donem",
                Baslik: "Geçici Vergi Dönemi", Grup: "Mali", AltGrup: "Mali Dönem"),
            new("donemDisiEngelle",  "donem_disi_engelle",  "mantik",
                Baslik: "Dönem dışı tarihe belge kaydını engelle", Grup: "Mali", AltGrup: "Mali Dönem"),
            new("devirFisiOtomatik", "devir_fisi_otomatik", "mantik",
                Baslik: "Yıl sonu devir fişini otomatik üret", Grup: "Mali", AltGrup: "Mali Dönem"),

            new("muhasebeEntegrasyon", "muhasebe_entegrasyon", "mantik",
                Baslik: "Muhasebe entegrasyonu açık", Grup: "Mali", AltGrup: "Muhasebe Entegrasyonu"),
            new("fisUretim",         "fis_uretim",          "kod", KodListesi: "mali.fis_uretim",
                Baslik: "Fiş Üretim Şekli", Grup: "Mali", AltGrup: "Muhasebe Entegrasyonu"),
            new("fisBirlestirme",    "fis_birlestirme",     "kod", KodListesi: "mali.fis_birlestirme",
                Baslik: "Fiş Birleştirme", Grup: "Mali", AltGrup: "Muhasebe Entegrasyonu"),
            new("masrafMerkeziKullan", "masraf_merkezi_kullan", "mantik",
                Baslik: "Masraf merkezi kullanılıyor", Grup: "Mali", AltGrup: "Muhasebe Entegrasyonu"),
            new("yuvarlamaHesapId",  "yuvarlama_hesap_id",  "kod",
                KodTablosu: "public.v_hesap_plani_lookup",
                Baslik: "Yuvarlama Hesabı", Grup: "Mali", AltGrup: "Muhasebe Entegrasyonu"),

            new("amortismanYontem",  "amortisman_yontem",   "kod", KodListesi: "mali.amortisman_yontem",
                Baslik: "Yöntem", Grup: "Mali", AltGrup: "Amortisman"),
            new("amortismanKist",    "amortisman_kist",     "kod", KodListesi: "mali.amortisman_kist",
                Baslik: "Kıst Uygulaması", Grup: "Mali", AltGrup: "Amortisman"),
            new("amortismanPeriyot", "amortisman_periyot",  "kod", KodListesi: "mali.amortisman_periyot",
                Baslik: "Hesaplama Periyodu", Grup: "Mali", AltGrup: "Amortisman"),
            new("amortismanEnflasyon", "amortisman_enflasyon", "mantik",
                Baslik: "Enflasyon düzeltmesi uygula", Grup: "Mali", AltGrup: "Amortisman"),
            new("birikmisAmortismanHesapId", "birikmis_amortisman_hesap_id", "kod",
                KodTablosu: "public.v_hesap_plani_lookup",
                Baslik: "Birikmiş Amortisman Hesabı", Grup: "Mali", AltGrup: "Amortisman"),
            new("amortismanGiderHesapId",    "amortisman_gider_hesap_id",    "kod",
                KodTablosu: "public.v_hesap_plani_lookup",
                Baslik: "Gider Hesabı", Grup: "Mali", AltGrup: "Amortisman"),
            new("amortismanYilsonuFis", "amortisman_yilsonu_fis", "mantik",
                Baslik: "Yıl sonunda amortisman fişini otomatik oluştur", Grup: "Mali", AltGrup: "Amortisman"),

            new("varsayilanKdv",     "varsayilan_kdv",      "sayi",
                Baslik: "Varsayılan KDV (%)", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("tevkifatModu",      "tevkifat_modu",       "kod", KodListesi: "mali.tevkifat_modu",
                Baslik: "Tevkifat", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("yerelPara",         "yerel_para",          "metin", EnFazlaUzunluk: 5,
                Baslik: "Para Birimi", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("dovizVarsayilan",   "doviz_varsayilan",    "metin", EnFazlaUzunluk: 5,
                Baslik: "Döviz Birimi", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("tutarOndalik",      "tutar_ondalik",       "sayi",
                Baslik: "Tutar Ondalık", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("fiyatOndalik",      "fiyat_ondalik",       "sayi",
                Baslik: "Birim Fiyat Ondalık", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),
            new("yuvarlamaAdim",     "yuvarlama_adim",      "para",
                Baslik: "Yuvarlama Adımı", Grup: "Mali", AltGrup: "Vergi & Yuvarlama"),

            // ---------------------------------------------------- Logo & Kaşe
            // MOCKUP: firma_bilgileri.html › "Logo & Kaşe".
            //   Gorsellerin KENDISI kolon degil DOKUMAN (193): kaynak='sube',
            //   belge_turu 'Logo' | 'Kaşe' | 'İmza'. Uc ayri bytea kolonu acmak
            //   yerine hash-dedup / boyut denetimi / log hazir olan altyapi
            //   kullanilir; sekmede galeri cizilir.
            //   MERKEZ / SUBE ayrimi burada da var (kullanici): sube kendi
            //   gorsellerini kullanmiyorsa merkezinki basilir (fn_sube_gorsel).
            new("merkezGorselKullan", "merkez_gorsel_kullan", "mantik",
                Baslik: "Merkezin logo / kaşesini kullan",
                Grup: "Logo & Kaşe", AltGrup: "Görsel Kaynağı"),
            new("kasePdfBas",   "kase_pdf_bas",   "mantik",
                Baslik: "e-Arşiv PDF çıktısına kaşe + imza bas",
                Grup: "Logo & Kaşe", AltGrup: "Çıktı Ayarları"),
            new("kaseKagitBas", "kase_kagit_bas", "mantik",
                Baslik: "Kağıt çıktılarda da kaşe görünsün",
                Grup: "Logo & Kaşe", AltGrup: "Çıktı Ayarları"),
            new("antetSablonu", "antet_sablonu",  "metin", EnFazlaUzunluk: 80,
                Baslik: "Antet Şablonu", Grup: "Logo & Kaşe", AltGrup: "Çıktı Ayarları")
        },
        // Subenin depolari - kartin "Depolar" sekmesinde, bayrakla ayni yerde
        //   (kullanici). Depo bakimi Stok menusunde de duruyor; burasi subeye
        //   ait olanlari gosterir ve yenisini buradan acmayi saglar.
        Detaylar: new[]
        {
            // ÜTS hesabi (223) - sube bazli (kullanici: "e-fatura gibi hem
            //   merkez hem subeye ozel"): subenin kaydi yoksa fn_uts_hesap
            //   varsayilan subenin (merkez) hesabina duser. Tek satirlik form
            //   (stok_uts deseni). TOKEN e-imza ile ÜTS arayuzunde uretilir ve
            //   buraya kullanici yapistirir - koda/loga asla yazilmaz.
            new DetayTanimi("uts", "public.uts_hesap", "sube_id", new KartAlani[]
            {
                new("aktif",       "aktif",         "mantik",
                    Baslik: "ÜTS Hesabı Aktif"),
                new("testOrtami",  "test_ortami",   "mantik",
                    Baslik: "Test Ortamı"),
                new("kurumNo",     "kurum_no",      "metin", EnFazlaUzunluk: 30,
                    Baslik: "Kurum No (canlı)"),
                new("token",       "token",         "metin", EnFazlaUzunluk: 4000,
                    Baslik: "Sistem Token'ı (canlı)"),
                new("testKurumNo", "test_kurum_no", "metin", EnFazlaUzunluk: 30,
                    Baslik: "Test Kurum No"),
                new("testToken",   "test_token",    "metin", EnFazlaUzunluk: 4000,
                    Baslik: "Test Token'ı")
            }, Sirala: "sube_id", SubeKolonu: null, LogTabloId: 930, Baslik: "ÜTS"),

            new DetayTanimi(
                Ad: "depolar",
                Tablo: "public.depo",
                UstKolon: "sube_id",
                Baslik: "Depolar",
                LogTabloId: 925,
                // Depo kaydinin sube kolonu ZATEN ust bagdir; ikinci kez yazilmaz.
                SubeKolonu: null,
                Sirala: "ad",
                Alanlar: new KartAlani[]
                {
                    new("id", "id", "sayi", Yazilabilir: false),
                    new("ad",  "ad",  "metin", Zorunlu: true, EnFazlaUzunluk: 50, Baslik: "Depo Adı"),
                    new("tip", "tip", "kod", SabitKodlar: DepoTipleri, Baslik: "Tipi"),
                    new("varsayilan", "varsayilan", "mantik", Baslik: "Varsayılan"),
                    new("maliyetiEtkilesin", "maliyeti_etkilesin", "mantik",
                        Baslik: "Maliyeti Etkilesin"),
                    new("durum", "durum", "kod", SabitKodlar: DurumKodlari, Baslik: "Durum")
                })
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge", "sube_id", "Bu şubede belge var, silinemez."),
            new SilmeEngeli("public.kullanici_sube", "sube_id", "Bu şubeye bağlı kullanıcı var, silinemez.")
        });
}
