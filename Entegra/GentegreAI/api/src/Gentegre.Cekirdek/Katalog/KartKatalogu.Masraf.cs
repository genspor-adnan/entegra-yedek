namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MASRAF BEYANI VE BELGE TALEBİ KARTLARI (764 / 765).
/// </summary>
public static partial class KartKatalogu
{
    internal static readonly Dictionary<string, string> MasrafBeyanDurumKodlari = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Onaylandı",
        ["3"] = "Reddedildi", ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> MasrafBelgeTuruKodlari = new()
    {
        ["1"] = "Fatura", ["2"] = "Fiş / Perakende Satış Belgesi",
        ["3"] = "e-Arşiv Fatura", ["4"] = "Bilet", ["5"] = "Gider Pusulası",
        ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> BelgeTalepDurumu = new()
    {
        ["0"] = "Taslak", ["1"] = "Onayda", ["2"] = "Hazırlanacak",
        ["3"] = "Reddedildi", ["4"] = "Hazırlandı", ["5"] = "Teslim Edildi",
        ["8"] = "İptal",
    };

    internal static readonly Dictionary<string, string> BelgeTalepTuru = new()
    {
        ["1"] = "Çalışma Belgesi", ["2"] = "Maaş Yazısı", ["3"] = "Vize Yazısı",
        ["4"] = "SGK Hizmet Dökümü", ["9"] = "Diğer",
    };

    internal static readonly Dictionary<string, string> BelgeTeslimSekli = new()
    {
        ["1"] = "Elden", ["2"] = "e-Posta", ["3"] = "Kargo",
    };

    // ------------------------------------------------------ masraf beyanı ----
    private static KartTanimi PersonelMasraf() => new(
        Ad: "personelMasraf",
        YetkiKodu: "ik.masraf",
        Tablo: "public.personel_masraf",
        LogTabloId: 1312,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("beyanNo", "beyan_no", "metin", Yazilabilir: false, Baslik: "Beyan No",
                Grup: "Beyan", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "Beyan", KodTablosu: "public.v_personel_lookup"),
            new("beyanTarihi", "beyan_tarihi", "tarih", Baslik: "Beyan Tarihi",
                Grup: "Beyan"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Beyan",
                EnFazlaUzunluk: 300),
            // TOPLAM SATIRLARDAN TÜRETİLİR (db tetiği): elle yazılamaz, yoksa
            //   onay ölçüsü belgelerle tutmaz.
            new("toplamTutar", "toplam_tutar", "para", Yazilabilir: false,
                Baslik: "Toplam Tutar", Grup: "Beyan"),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Beyan", SabitKodlar: MasrafBeyanDurumKodlari),
            new("redNeden", "red_neden", "metin", Yazilabilir: false,
                Baslik: "Red Nedeni", Grup: "Sonuç", EnFazlaUzunluk: 300),
            new("iptalNeden", "iptal_neden", "metin", Yazilabilir: false,
                Baslik: "İptal Nedeni", Grup: "Sonuç", EnFazlaUzunluk: 300),
        },
        Detaylar: new DetayTanimi[]
        {
            // HARCAMALAR YAZILABİLİR: beyanın kendisi bu satırlardır. Taslak
            //   dışında değişiklik db tetiğiyle engelleniyor (764) - kart
            //   salt okunur yapılsaydı taslakta da yazılamazdı.
            new("harcamalar", "public.personel_masraf_satir", "beyan_id", new KartAlani[]
            {
                new("id", "id", "sayi", Yazilabilir: false),
                new("sira", "sira", "sayi", Yazilabilir: false, Baslik: "Sıra"),
                new("masrafId", "masraf_id", "kod", Baslik: "Gider Kalemi",
                    KodTablosu: "public.v_masraf_lookup"),
                new("harcamaTarihi", "harcama_tarihi", "tarih", Baslik: "Harcama"),
                new("belgeTuru", "belge_turu", "kod", Baslik: "Belge Türü",
                    SabitKodlar: MasrafBelgeTuruKodlari),
                // BELGESİZ SATIR YOK: db kısıtı da korur.
                new("belgeNo", "belge_no", "metin", Zorunlu: true,
                    Baslik: "Fatura/Fiş No", EnFazlaUzunluk: 60),
                new("tutar", "tutar", "para", Zorunlu: true, Baslik: "Tutar"),
                new("kdvTutar", "kdv_tutar", "para", Baslik: "KDV"),
                new("aciklama", "aciklama", "metin", Baslik: "Açıklama",
                    EnFazlaUzunluk: 300),
            }, Sirala: "sira, id", Baslik: "Harcamalar",
               SubeKolonu: null, LogTabloId: 1313),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0, ["beyan_tarihi"] = "@simdi",
        });

    // ------------------------------------------------------- belge talebi ----
    private static KartTanimi PersonelBelgeTalep() => new(
        Ad: "personelBelgeTalep",
        YetkiKodu: "ik.belge_talep",
        Tablo: "public.personel_belge_talep",
        LogTabloId: 1314,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("talepNo", "talep_no", "metin", Yazilabilir: false, Baslik: "Talep No",
                Grup: "Talep", EnFazlaUzunluk: 30),
            new("tarafId", "taraf_id", "sayi", Zorunlu: true, Baslik: "Personel",
                Grup: "Talep", KodTablosu: "public.v_personel_lookup"),
            new("talepTarihi", "talep_tarihi", "tarih", Baslik: "Talep Tarihi",
                Grup: "Talep"),
            new("tur", "tur", "kod", Zorunlu: true, Baslik: "Belge Türü",
                Grup: "Talep", SabitKodlar: BelgeTalepTuru),
            // AMAÇ YAZININ METNİNİ BELİRLER: vize yazısı İngilizce ve maaş
            //   bilgili olur, çalışma belgesi olmayabilir.
            new("amac", "amac", "metin", Zorunlu: true, Baslik: "Amaç (ne için)",
                Grup: "Talep", EnFazlaUzunluk: 200),
            new("muhatap", "muhatap", "metin", Baslik: "Muhatap (boş = ilgili makama)",
                Grup: "Talep", EnFazlaUzunluk: 200),
            new("adet", "adet", "sayi", Baslik: "Nüsha", Grup: "Talep"),
            new("teslimSekli", "teslim_sekli", "kod", Baslik: "Teslim Şekli",
                Grup: "Talep", SabitKodlar: BelgeTeslimSekli),
            new("durum", "durum", "kod", Yazilabilir: false, Baslik: "Durum",
                Grup: "Talep", SabitKodlar: BelgeTalepDurumu),
            new("otomatikOnay", "otomatik_onay", "mantik", Yazilabilir: false,
                Baslik: "Otomatik onaylandı", Grup: "Hazırlık"),
            new("hazirlayanId", "hazirlayan_id", "kod", Yazilabilir: false,
                Baslik: "Hazırlayan", Grup: "Hazırlık",
                KodTablosu: "public.v_kullanici_lookup"),
            new("hazirlamaTarihi", "hazirlama_tarihi", "zaman", Yazilabilir: false,
                Baslik: "Hazırlama", Grup: "Hazırlık"),
            new("teslimTarihi", "teslim_tarihi", "zaman", Yazilabilir: false,
                Baslik: "Teslim", Grup: "Hazırlık"),
            new("aciklama", "aciklama", "metin", Baslik: "Açıklama", Grup: "Hazırlık",
                EnFazlaUzunluk: 300),
            new("redNeden", "red_neden", "metin", Yazilabilir: false,
                Baslik: "Red Nedeni", Grup: "Hazırlık", EnFazlaUzunluk: 300),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = 0, ["tur"] = 1, ["adet"] = 1, ["teslim_sekli"] = 1,
            ["talep_tarihi"] = "@simdi",
        });
}
