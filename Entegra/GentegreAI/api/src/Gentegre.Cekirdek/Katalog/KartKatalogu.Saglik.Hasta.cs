namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HASTA KAYITLARI — reçete, alerji, kullanılan ilaç, kronik tanı, geçmiş olay.
///
/// KartKatalogu.Saglik.cs dosyasindan ayrildi: tek dosyada 1448 satiri buluyordu ve
/// bir kart tanimi otekine karisiyordu. Kod degismedi, yalniz yer
/// degistirdi - sinif `partial`, uyeler ayni sinifin uyesi.
/// </summary>
public static partial class KartKatalogu
{
    /// <summary>
    /// REÇETE KARTI (413) — ilaçlar detayda.
    ///
    /// İmza ve Medula alanları SALT OKUNUR: reçetenin imzalanması bir düğmenin
    /// işidir (uç), elle "imzalı" yazmak belgeyi sahte yapardı.
    /// </summary>
    private static KartTanimi ReceteKarti() => new(
        Ad: "recete",
        YetkiKodu: "muayene",
        Tablo: "public.recete",
        LogTabloId: 969,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1,
            ["tur"] = (short)0,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("muayeneId", "muayene_id", "sayi", Zorunlu: true,
                Baslik: "Muayene Id", Grup: "Kimlik"),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kimlik"),
            new("hekimId", "hekim_id", "kod", KodTablosu: "public.v_personel_lookup",
                Baslik: "Hekim", Grup: "Kimlik"),
            new("tur", "tur", "kod", SabitKodlar: ReceteTuruKodlari,
                Baslik: "Reçete Türü", Grup: "Kimlik"),
            new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200,
                Baslik: "Açıklama", Grup: "Kimlik"),
            new("durum", "durum", "kod", SabitKodlar: ReceteDurumKodlari, Yazilabilir: false,
                Baslik: "Durum", Grup: "Kimlik"),
            // Imza ve Medula: DUGMENIN yazdigi alanlar.
            new("receteNo", "recete_no", "metin", EnFazlaUzunluk: 20, Yazilabilir: false,
                Baslik: "Reçete No", Grup: "Gönderim"),
            new("imzaZamani", "imza_zamani", "tarih", Yazilabilir: false,
                Baslik: "İmza", Grup: "Gönderim"),
            new("medulaGonderim", "medula_gonderim", "tarih", Yazilabilir: false,
                Baslik: "Medula Gönderim", Grup: "Gönderim"),
            new("medulaSonuc", "medula_sonuc", "metin", EnFazlaUzunluk: 200,
                Yazilabilir: false, Baslik: "Medula Sonucu", Grup: "Gönderim")
        },
        Detaylar: new DetayTanimi[]
        {
            new("ilaclar", "public.recete_satir", "recete_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Baslik: "Sıra"),
                new("ilacBarkod", "ilac_barkod", "metin", Zorunlu: true, EnFazlaUzunluk: 20,
                    Baslik: "Barkod"),
                // Ad KOPYA: katalog guncellenince eski recetenin metni
                //   degismemeli - recete tarihte donmus bir belgedir.
                new("ilacAd", "ilac_ad", "metin", EnFazlaUzunluk: 200, Baslik: "İlaç"),
                new("doz", "doz", "metin", EnFazlaUzunluk: 20, Baslik: "Doz"),
                new("periyot", "periyot", "metin", EnFazlaUzunluk: 20, Baslik: "Periyot"),
                new("sureGun", "sure_gun", "sayi", Baslik: "Süre (gün)"),
                new("kutu", "kutu", "sayi", Baslik: "Kutu"),
                new("aciklama", "aciklama", "metin", EnFazlaUzunluk: 200, Baslik: "Tarif"),
                // Uyari GECILDIYSE metni kalir: hekimin neyi gorup gectigini
                //   sonradan bilmek, uyariyi hic gostermemekten onemli.
                new("etkilesimUyari", "etkilesim_uyari", "metin", EnFazlaUzunluk: 200,
                    Yazilabilir: false, Baslik: "Uyarı"),
            }, SubeKolonu: null, Sirala: "sira asc, id asc",
               Baslik: "İlaçlar", LogTabloId: 970)
        });

    /// <summary>HASTA ALERJİSİ KARTI (413) — etken madde bazlı.</summary>
    private static KartTanimi HastaAlerjiKarti() => new(
        Ad: "hasta-alerji",
        YetkiKodu: "muayene",
        Tablo: "public.hasta_alerji",
        LogTabloId: 971,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1, ["siddet"] = (short)1, ["kaynak"] = (short)1, ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Kayıt"),
            new("tur", "tur", "kod", SabitKodlar: AlerjiTuruKodlari, Baslik: "Tür",
                Grup: "Kayıt"),
            new("etken", "etken", "metin", EnFazlaUzunluk: 200,
                Baslik: "Etken / Ürün", Grup: "Kayıt"),
            // KONTROLUN ASIL ANAHTARI: marka degil etken madde.
            new("etkenMadde", "etken_madde", "metin", EnFazlaUzunluk: 200,
                Baslik: "Etken Madde", Grup: "Kayıt"),
            new("reaksiyon", "reaksiyon", "metin", EnFazlaUzunluk: 200,
                Baslik: "Reaksiyon", Grup: "Kayıt"),
            new("siddet", "siddet", "kod", SabitKodlar: AlerjiSiddetKodlari,
                Baslik: "Şiddet", Grup: "Kayıt"),
            new("kaynak", "kaynak", "kod", SabitKodlar: KayitKaynakKodlari,
                Baslik: "Kaynak", Grup: "Kayıt"),
            new("dogrulandi", "dogrulandi", "mantik", Baslik: "Doğrulandı", Grup: "Kayıt"),
            new("kayitMuayeneId", "kayit_muayene_id", "sayi",
                Baslik: "Kayıt Muayenesi", Grup: "Kayıt"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kayıt")
        });

    /// <summary>HASTA İLACI KARTI (413) — kullanılan ilaç, reçeteden bağımsız.</summary>
    private static KartTanimi HastaIlacKarti() => new(
        Ad: "hasta-ilac",
        YetkiKodu: "muayene",
        Tablo: "public.hasta_ilac",
        LogTabloId: 972,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["kaynak"] = (short)2, ["uyum"] = (short)1, ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "İlaç"),
            new("ilacBarkod", "ilac_barkod", "metin", EnFazlaUzunluk: 20,
                Baslik: "Barkod", Grup: "İlaç"),
            new("ilacAd", "ilac_ad", "metin", EnFazlaUzunluk: 200, Baslik: "İlaç",
                Grup: "İlaç"),
            new("etkenMadde", "etken_madde", "metin", EnFazlaUzunluk: 200,
                Baslik: "Etken Madde", Grup: "İlaç"),
            new("doz", "doz", "metin", EnFazlaUzunluk: 20, Baslik: "Doz", Grup: "Kullanım"),
            new("periyot", "periyot", "metin", EnFazlaUzunluk: 20, Baslik: "Periyot",
                Grup: "Kullanım"),
            new("baslangic", "baslangic", "tarih", Baslik: "Başlangıç", Grup: "Kullanım"),
            new("bitis", "bitis", "tarih", Baslik: "Bitiş", Grup: "Kullanım"),
            new("kaynak", "kaynak", "kod", SabitKodlar: IlacKaynakKodlari,
                Baslik: "Kaynak", Grup: "Kullanım"),
            new("uyum", "uyum", "kod", SabitKodlar: IlacUyumKodlari,
                Baslik: "Uyum", Grup: "Kullanım"),
            new("aktif", "aktif", "mantik", Baslik: "Aktif", Grup: "Kullanım")
        });

    /// <summary>HASTA KRONİK TANISI KARTI (420).</summary>
    private static KartTanimi HastaKronikTaniKarti() => new(
        Ad: "hasta-kronik",
        YetkiKodu: "muayene",
        Tablo: "public.hasta_kronik_tani",
        LogTabloId: 973,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["kaynak"] = (short)2,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Tanı"),
            new("icdKod", "icd_kod", "kod", Zorunlu: true,
                KodTablosu: "public.v_icd_lookup", AramaKaynagi: "icd",
                Baslik: "ICD-10", Grup: "Tanı"),
            // Ad KOPYA: katalog guncellenirse ozetteki metin degismesin.
            new("taniAd", "tani_ad", "metin", EnFazlaUzunluk: 300, Baslik: "Tanı",
                Grup: "Tanı"),
            new("baslangic", "baslangic", "tarih", Baslik: "Başlangıç", Grup: "Takip"),
            new("bitis", "bitis", "tarih", Baslik: "Bitiş (remisyon)", Grup: "Takip"),
            new("takipHekimId", "takip_hekim_id", "kod",
                KodTablosu: "public.v_personel_lookup", Baslik: "Takip Eden", Grup: "Takip"),
            new("durum", "durum", "kod", SabitKodlar: KronikDurumKodlari,
                Baslik: "Durum", Grup: "Takip"),
            new("kaynak", "kaynak", "kod", SabitKodlar: TibbiKaynakKodlari,
                Baslik: "Kaynak", Grup: "Takip"),
            new("kayitMuayeneId", "kayit_muayene_id", "sayi", Baslik: "Kayıt Muayenesi",
                Grup: "Takip"),
            new("notMetni", "not_metni", "metin", EnFazlaUzunluk: 300, Baslik: "Not",
                Grup: "Takip")
        });

    /// <summary>HASTA GEÇMİŞ OLAYI KARTI (420) — ameliyat · aşı · yatış.</summary>
    private static KartTanimi HastaGecmisOlayKarti() => new(
        Ad: "hasta-gecmis",
        YetkiKodu: "muayene",
        Tablo: "public.hasta_gecmis_olay",
        LogTabloId: 974,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["tur"] = (short)1, ["kaynak"] = (short)2,
        },
        Alanlar: new KartAlani[]
        {
            new("id", "id", "sayi", Yazilabilir: false),
            new("hastaId", "hasta_id", "kod", Zorunlu: true,
                KodTablosu: "public.v_hasta_lookup", AramaKaynagi: "hasta",
                Baslik: "Hasta", Grup: "Olay"),
            new("tur", "tur", "kod", SabitKodlar: GecmisOlayTuruKodlari, Baslik: "Tür",
                Grup: "Olay"),
            new("ad", "ad", "metin", Zorunlu: true, EnFazlaUzunluk: 200, Baslik: "Olay",
                Grup: "Olay"),
            new("kod", "kod", "metin", EnFazlaUzunluk: 20, Baslik: "Kod (SUT / aşı)",
                Grup: "Olay"),
            new("tarih", "tarih", "tarih", Baslik: "Tarih", Grup: "Olay"),
            new("kurum", "kurum", "metin", EnFazlaUzunluk: 120, Baslik: "Kurum", Grup: "Olay"),
            new("notMetni", "not_metni", "metin", EnFazlaUzunluk: 400, Baslik: "Not",
                Grup: "Olay"),
            new("kaynak", "kaynak", "kod", SabitKodlar: TibbiKaynakKodlari, Baslik: "Kaynak",
                Grup: "Olay")
        });

    /// <summary>
    /// DOKÜMAN KARTI (419) — meta düzenleme, sürümler, günlük.
    ///
    /// YENİ KAYIT BURADAN AÇILMAZ: doküman bir DOSYADIR, önce içerik yüklenir
    /// (kart galerisi ya da doküman listesi "Yükle") ve kaynak+kaynak_id o
    /// anda belirlenir. Boş bir doküman satırı açmak, içeriği olmayan bir
    /// başlık bırakırdı.
    ///
    /// İçerik alanları (hash, boyut, sürüm no, durum) SALT OKUNUR: onları
    /// değiştiren şey sürüm/onay döngüsüdür, elle yazmak başlığı gerçek
    /// dosyadan koparırdı.
    /// </summary>
}
