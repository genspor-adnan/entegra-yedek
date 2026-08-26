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
                Baslik: "e-SMM Mükellefi", Grup: "e-Belge", AltGrup: "Mükellefiyet")
        },
        // Subenin depolari - kartin "Depolar" sekmesinde, bayrakla ayni yerde
        //   (kullanici). Depo bakimi Stok menusunde de duruyor; burasi subeye
        //   ait olanlari gosterir ve yenisini buradan acmayi saglar.
        Detaylar: new[]
        {
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
