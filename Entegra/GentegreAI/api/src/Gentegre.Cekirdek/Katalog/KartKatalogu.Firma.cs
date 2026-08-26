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

            // ---------------------------------------------------------- Kimlik
            new("kod",   "kod",   "metin", EnFazlaUzunluk: 20,  Baslik: "Kod", Grup: "Kimlik"),
            new("ad",    "ad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Şube Adı", Grup: "Kimlik"),
            // UNVAN e-Belgede gorunen resmi addir; "ad" ic kullanim icin kisa ad.
            new("unvan", "unvan", "metin", EnFazlaUzunluk: 200,
                Baslik: "Resmî Unvan", Grup: "Kimlik"),
            new("vkno",  "vkno",  "metin", EnFazlaUzunluk: 20,
                Baslik: "VKN / TCKN", Grup: "Kimlik"),
            new("vd",    "vd",    "metin", EnFazlaUzunluk: 60,
                Baslik: "Vergi Dairesi", Grup: "Kimlik"),
            new("firmaTuru",     "firma_turu",     "metin", EnFazlaUzunluk: 40,
                Baslik: "Firma Türü", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("naceKodu",      "nace_kodu",      "metin", EnFazlaUzunluk: 20,
                Baslik: "NACE Kodu", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("kurulusTarihi", "kurulus_tarihi", "tarih",
                Baslik: "Kuruluş Tarihi", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("sermaye",       "sermaye",        "para",
                Baslik: "Sermaye", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("ticaretOdasi",  "ticaret_odasi",  "metin", EnFazlaUzunluk: 120,
                Baslik: "Ticaret Odası", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("odaSicilNo",    "oda_sicil_no",   "metin", EnFazlaUzunluk: 40,
                Baslik: "Oda Sicil No", Grup: "Kimlik", AltGrup: "Ticari Kayıt"),
            new("varsayilan", "varsayilan", "mantik", Baslik: "Varsayılan Şube", Grup: "Kimlik"),
            new("aktif",      "aktif",      "kod", SabitKodlar: DurumKodlari,
                Baslik: "Durum", Grup: "Kimlik"),

            // ----------------------------------------------------------- Adres
            new("adres",      "adres",      "metin", EnFazlaUzunluk: 300,
                Baslik: "Adres", Grup: "Adres"),
            new("ilce",       "ilce",       "metin", EnFazlaUzunluk: 60,
                Baslik: "İlçe", Grup: "Adres"),
            new("il",         "il",         "metin", EnFazlaUzunluk: 60,
                Baslik: "İl", Grup: "Adres"),
            new("ulke",       "ulke",       "metin", EnFazlaUzunluk: 60,
                Baslik: "Ülke", Grup: "Adres"),
            new("postaKodu",  "posta_kodu", "metin", EnFazlaUzunluk: 10,
                Baslik: "Posta Kodu", Grup: "Adres"),
            new("bolge",      "bolge",      "metin", EnFazlaUzunluk: 60,
                Baslik: "Bölge", Grup: "Adres"),

            // ------------------------------------------------------- Faaliyet
            new("sektor",         "sektor",          "metin", EnFazlaUzunluk: 120,
                Baslik: "Sektör", Grup: "Faaliyet"),
            new("faaliyetKonusu", "faaliyet_konusu", "metin", EnFazlaUzunluk: 300,
                Baslik: "Faaliyet Konusu", Grup: "Faaliyet"),
            new("calisanSayisi",  "calisan_sayisi",  "sayi",
                Baslik: "Çalışan Sayısı", Grup: "Faaliyet"),
            new("sgkSicilNo",     "sgk_sicil_no",    "metin", EnFazlaUzunluk: 40,
                Baslik: "SGK Sicil No", Grup: "Faaliyet"),

            // ------------------------------------------------------- İletişim
            new("telefon", "telefon", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon", Grup: "İletişim"),
            new("eposta",  "eposta",  "metin", EnFazlaUzunluk: 120,
                Baslik: "E-posta", Grup: "İletişim"),
            new("telefon2", "telefon2", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon 2", Grup: "İletişim"),
            new("gsm",      "gsm",      "metin", EnFazlaUzunluk: 30,
                Baslik: "GSM", Grup: "İletişim"),
            new("muhasebeEposta", "muhasebe_eposta", "metin", EnFazlaUzunluk: 120,
                Baslik: "Muhasebe E-postası", Grup: "İletişim"),
            // KEP resmi bildirim adresi - e-Belge ve yasal yazismada kullanilir.
            new("kepAdresi", "kep_adresi", "metin", EnFazlaUzunluk: 120,
                Baslik: "KEP Adresi", Grup: "İletişim"),
            new("web",     "web",     "metin", EnFazlaUzunluk: 200,
                Baslik: "Web", Grup: "İletişim"),

            // --------------------------------------------------------- e-Belge
            // Bu alanlar GIB'e giden belgede zorunlu ya da belirleyici:
            //   alias gonderici etiketidir, mukellef bayraklari hangi belgeyi
            //   kesebilecegimizi soyler, Mersis/sicil ticari faturada aranir.
            new("efaturaAlias",      "efatura_alias",       "metin", EnFazlaUzunluk: 500,
                Baslik: "e-Fatura Gönderici Etiketi", Grup: "e-Belge"),
            new("ebelgeSeri",        "ebelge_seri",         "metin", EnFazlaUzunluk: 3,
                Baslik: "Varsayılan Seri", Grup: "e-Belge"),
            new("efaturaMukellef",   "efatura_mukellef",    "mantik",
                Baslik: "e-Fatura Mükellefi", Grup: "e-Belge"),
            new("earsivMukellef",    "earsiv_mukellef",     "mantik",
                Baslik: "e-Arşiv Mükellefi", Grup: "e-Belge"),
            new("eirsaliyeMukellef", "eirsaliye_mukellef",  "mantik",
                Baslik: "e-İrsaliye Mükellefi", Grup: "e-Belge"),
            new("mersisNo",          "mersis_no",           "metin", EnFazlaUzunluk: 20,
                Baslik: "Mersis No", Grup: "e-Belge"),
            new("ticaretSicilNo",    "ticaret_sicil_no",    "metin", EnFazlaUzunluk: 30,
                Baslik: "Ticaret Sicil No", Grup: "e-Belge")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge", "sube_id", "Bu şubede belge var, silinemez."),
            new SilmeEngeli("public.kullanici_sube", "sube_id", "Bu şubeye bağlı kullanıcı var, silinemez.")
        });
}
