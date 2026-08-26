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
            // Mockup sirasi: Ünvan · Kısa Ad · Firma Türü · VKN · Vergi Dairesi ·
            //   Ticaret Sicil · Mersis · NACE · Kuruluş · Sermaye · Oda · Oda Sicil.
            // UNVAN e-Belgede gorunen resmi addir; "ad" ic kullanim icin kisa ad.
            new("unvan", "unvan", "metin", Zorunlu: true, EnFazlaUzunluk: 200,
                Baslik: "Ünvan", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("ad",    "ad",    "metin", Zorunlu: true, EnFazlaUzunluk: 60,
                Baslik: "Kısa Ad", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("firmaTuru", "firma_turu", "kod", KodListesi: "sube.firma_turu",
                Baslik: "Firma Türü", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
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
            new("mersisNo",       "mersis_no",        "metin", EnFazlaUzunluk: 20,
                Baslik: "Mersis No", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("naceKodu",      "nace_kodu",      "metin", EnFazlaUzunluk: 20,
                Baslik: "NACE Kodu", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("kurulusTarihi", "kurulus_tarihi", "tarih",
                Baslik: "Kuruluş Tarihi", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("sermaye",       "sermaye",        "para",
                Baslik: "Sermaye", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("ticaretOdasi",  "ticaret_odasi",  "metin", EnFazlaUzunluk: 120,
                Baslik: "Ticaret Odası", Grup: "Kimlik", AltGrup: "Firma Kimliği"),
            new("odaSicilNo",    "oda_sicil_no",   "metin", EnFazlaUzunluk: 40,
                Baslik: "Oda Sicil No", Grup: "Kimlik", AltGrup: "Firma Kimliği"),

            // ------------------------------------------------- Kimlik / Kayıt
            // Kartin kendi kayit alanlari. Mockup'taki "Kayıt Bilgisi" kutusu
            //   (kayit tarihi / doluluk cubugu) ve "Faaliyet" kutusu kullanici
            //   karariyla ALINMADI.
            new("kod",   "kod",   "metin", EnFazlaUzunluk: 20,
                Baslik: "Firma Kodu", Grup: "Kimlik", AltGrup: "Kayıt"),
            new("varsayilan", "varsayilan", "mantik",
                Baslik: "Varsayılan Şube", Grup: "Kimlik", AltGrup: "Kayıt"),
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
            new("bolge",      "bolge",      "metin", EnFazlaUzunluk: 60,
                Baslik: "Bölge", Grup: "Adres", AltGrup: "Merkez Adresi"),

            new("telefon", "telefon", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon", Grup: "Adres", AltGrup: "İletişim"),
            new("telefon2", "telefon2", "metin", EnFazlaUzunluk: 30,
                Baslik: "Telefon 2", Grup: "Adres", AltGrup: "İletişim"),
            new("gsm",      "gsm",      "metin", EnFazlaUzunluk: 30,
                Baslik: "GSM", Grup: "Adres", AltGrup: "İletişim"),
            new("eposta",  "eposta",  "metin", EnFazlaUzunluk: 120,
                Baslik: "E-posta", Grup: "Adres", AltGrup: "İletişim"),
            new("muhasebeEposta", "muhasebe_eposta", "metin", EnFazlaUzunluk: 120,
                Baslik: "Muhasebe E-postası", Grup: "Adres", AltGrup: "İletişim"),
            // KEP resmi bildirim adresi - e-Belge ve yasal yazismada kullanilir.
            new("kepAdresi", "kep_adresi", "metin", EnFazlaUzunluk: 120,
                Baslik: "KEP Adresi", Grup: "Adres", AltGrup: "İletişim"),
            new("web",       "web",        "metin", EnFazlaUzunluk: 200,
                Baslik: "Web Sitesi", Grup: "Adres", AltGrup: "İletişim"),

            // --------------------------------------------------------- e-Belge
            // Alias gonderici etiketidir, mukellef bayraklari hangi belgeyi
            //   kesebilecegimizi soyler.
            // KIMLIK KAYNAGI (169): sube kendi VKN'siyle mi gonderiyor, merkezin
            //   kimligiyle mi. Alias ve Mersis/sicil de bu secimi izler - GIB posta
            //   kutusu VKN'ye bagli oldugu icin ikisi ayrilamaz.
            new("ebelgeKimlik", "ebelge_kimlik", "kod", KodListesi: "sube.ebelge_kimlik",
                Baslik: "Gönderici Kimliği", Grup: "e-Belge"),
            new("ustSubeId",    "ust_sube_id",   "kod", KodTablosu: "public.sube",
                Baslik: "Bağlı Olduğu Merkez", Grup: "e-Belge"),
            new("efaturaAlias",      "efatura_alias",       "metin", EnFazlaUzunluk: 500,
                Baslik: "e-Fatura Gönderici Etiketi", Grup: "e-Belge"),
            new("ebelgeSeri",        "ebelge_seri",         "metin", EnFazlaUzunluk: 3,
                Baslik: "Varsayılan Seri", Grup: "e-Belge"),
            new("efaturaMukellef",   "efatura_mukellef",    "mantik",
                Baslik: "e-Fatura Mükellefi", Grup: "e-Belge"),
            new("earsivMukellef",    "earsiv_mukellef",     "mantik",
                Baslik: "e-Arşiv Mükellefi", Grup: "e-Belge"),
            new("eirsaliyeMukellef", "eirsaliye_mukellef",  "mantik",
                Baslik: "e-İrsaliye Mükellefi", Grup: "e-Belge")
        },
        SilmeEngelleri: new[]
        {
            new SilmeEngeli("public.belge", "sube_id", "Bu şubede belge var, silinemez."),
            new SilmeEngeli("public.kullanici_sube", "sube_id", "Bu şubeye bağlı kullanıcı var, silinemez.")
        });
}
