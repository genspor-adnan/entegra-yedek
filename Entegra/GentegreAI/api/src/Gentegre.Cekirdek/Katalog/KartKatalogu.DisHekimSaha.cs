namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DIŞ DOKTOR SAHA KARTLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §2 / §5): temsilcinin ziyaret
/// kartı ve doktorun talep kartı. İkisi de jenerik GenForm; ziyaret kartında talepler ve yorumlar grid detayı.
/// Kaynak adı = liste kaynağı (dis-hekim-ziyaret / dis-hekim-talep), yetki kodu liste ile aynı (menü = yetki, 1003).
/// </summary>
public static partial class KartKatalogu
{
    internal static readonly Dictionary<string, string> ZiyaretDurumKodlari = new()
    {
        ["0"] = "Planlı", ["1"] = "Yapıldı", ["2"] = "İptal",
    };

    internal static readonly Dictionary<string, string> MemnuniyetKodlari = new()
    {
        ["0"] = "—", ["1"] = "1 · Çok kötü", ["2"] = "2 · Kötü", ["3"] = "3 · Orta", ["4"] = "4 · İyi", ["5"] = "5 · Çok iyi",
    };

    internal static readonly Dictionary<string, string> TalepOncelikKodlari = new()
    {
        ["1"] = "Normal", ["2"] = "Yüksek", ["3"] = "Acil",
    };

    /// <summary>Ziyaret sıklığı (hafta). Eski HBYS ZIYARETSURESI ay cinsindendi (1 2 3 4 6 12) - ×4.</summary>
    internal static readonly Dictionary<string, string> ZiyaretSikligiKodlari = new()
    {
        ["0"] = "Planlanmaz", ["2"] = "2 haftada bir", ["4"] = "4 haftada bir", ["8"] = "8 haftada bir",
        ["12"] = "3 ayda bir", ["16"] = "4 ayda bir", ["26"] = "6 ayda bir", ["52"] = "Yılda bir",
    };

    internal static readonly Dictionary<string, string> HaftaGunuKodlari = new()
    {
        ["0"] = "—", ["1"] = "Pazartesi", ["2"] = "Salı", ["3"] = "Çarşamba", ["4"] = "Perşembe",
        ["5"] = "Cuma", ["6"] = "Cumartesi", ["7"] = "Pazar",
    };

    private static KartAlani[] TalepAlanlari(bool hekimli) =>
    [
        new("id",        "id",         "sayi",  Yazilabilir: false),
        .. (hekimli
            ? new KartAlani[] { new("hekimId", "hekim_id", "kod", Zorunlu: true, KodTablosu: "public.v_dis_hekim_lookup",
                                    AramaKaynagi: "dis-hekim", Baslik: "Dış Doktor", Grup: "Talep") }
            : []),
        new("tur",       "tur",        "kod",   Zorunlu: true, KodListesi: "dis_hekim.talep_turu", Baslik: "Tür", Grup: "Talep"),
        new("talep",     "talep",      "metin", Zorunlu: true, EnFazlaUzunluk: 500, Baslik: "Talep", Grup: "Talep", TekSatir: true),
        new("oncelik",   "oncelik",    "kod",   SabitKodlar: TalepOncelikKodlari, Baslik: "Öncelik", Grup: "Talep"),
        new("sorumluId", "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Talep"),
        new("termin",    "termin",     "tarih", Baslik: "Termin", Grup: "Talep"),
        new("durum",     "durum",      "kod",   KodListesi: "dis_hekim.talep_durumu", Baslik: "Durum", Grup: "Talep"),
        new("sonuc",     "sonuc",      "metin", EnFazlaUzunluk: 500, Baslik: "Sonuç / Yanıt", Grup: "Talep", TekSatir: true),
        new("gorevId",   "gorev_id",   "sayi",  Yazilabilir: false, Baslik: "Görev No", Grup: "Talep"),
        new("kapanma",   "kapanma",    "zaman", Yazilabilir: false, Baslik: "Kapanma", Grup: "Talep"),
    ];

    private static KartTanimi DisHekimZiyaret() => new(
        Ad: "dis-hekim-ziyaret",
        YetkiKodu: "dis_doktor.ziyaret",
        Tablo: "public.dis_hekim_ziyaret",
        LogTabloId: 1781,
        SubeKolonu: "sube_id",
        Alanlar: new KartAlani[]
        {
            new("id",         "id",          "sayi",  Yazilabilir: false),
            new("hekimId",    "hekim_id",    "kod",   Zorunlu: true, KodTablosu: "public.v_dis_hekim_lookup",
                AramaKaynagi: "dis-hekim", Baslik: "Dış Doktor", Grup: "Kimlik"),
            // TEMSİLCİ boş bırakılırsa tetik şube temsilcisini yazar (1287).
            new("temsilciId", "temsilci_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Temsilci", Grup: "Kimlik"),
            new("tarih",      "tarih",       "zaman", Zorunlu: true, Baslik: "Tarih / Saat", Grup: "Kimlik"),
            new("tur",        "tur",         "kod",   Zorunlu: true, KodListesi: "dis_hekim.ziyaret_turu", Baslik: "Tür", Grup: "Kimlik"),
            new("durum",      "durum",       "kod",   SabitKodlar: ZiyaretDurumKodlari, Baslik: "Durum", Grup: "Kimlik"),

            new("amac",       "amac",        "kod",   KodListesi: "dis_hekim.ziyaret_amaci", Baslik: "Amaç", Grup: "Görüşme"),
            new("sonuc",      "sonuc",       "kod",   KodListesi: "dis_hekim.ziyaret_sonucu", Baslik: "Sonuç", Grup: "Görüşme"),
            new("sureDk",     "sure_dk",     "sayi",  Baslik: "Süre (dk)", Grup: "Görüşme"),
            new("memnuniyet", "memnuniyet",  "kod",   SabitKodlar: MemnuniyetKodlari, Baslik: "Memnuniyet", Grup: "Görüşme"),
            new("notu",       "notu",        "metin", EnFazlaUzunluk: 4000, Baslik: "Görüşme Notu", Grup: "Görüşme"),
            new("konular",    "konular",     "metin", EnFazlaUzunluk: 300, Baslik: "Görüşülen Konular", Grup: "Görüşme"),
            new("rakip",      "rakip",       "metin", EnFazlaUzunluk: 200, Baslik: "Rakip Baskısı", Grup: "Görüşme"),
            new("materyal",   "materyal",    "metin", EnFazlaUzunluk: 300, Baslik: "Bırakılan Materyal", Grup: "Görüşme"),

            new("sonrakiTarih", "sonraki_tarih", "tarih", Baslik: "Sonraki Ziyaret", Grup: "Sonraki Adım"),
            new("hatirlat",   "hatirlat",    "mantik", Baslik: "Hatırlat", Grup: "Sonraki Adım"),
            new("hatirlatmaId", "hatirlatma_id", "sayi", Yazilabilir: false, Baslik: "Hatırlatma No", Grup: "Sonraki Adım"),

            // MOBİL DAMGA (eski HBYS BASTARIH / BITTARIH / BASYERXY): telefondan dolar, masaüstünde okunur.
            new("basZamani",  "bas_zamani",  "zaman",   Baslik: "Başlangıç", Grup: "Mobil"),
            new("bitZamani",  "bit_zamani",  "zaman",   Baslik: "Bitiş", Grup: "Mobil"),
            new("basEnlem",   "bas_enlem",   "ondalik", Baslik: "Başlangıç Enlem", Grup: "Mobil"),
            new("basBoylam",  "bas_boylam",  "ondalik", Baslik: "Başlangıç Boylam", Grup: "Mobil"),
            new("bitEnlem",   "bit_enlem",   "ondalik", Baslik: "Bitiş Enlem", Grup: "Mobil"),
            new("bitBoylam",  "bit_boylam",  "ondalik", Baslik: "Bitiş Boylam", Grup: "Mobil"),
            new("mobil",      "mobil",       "mantik",  Yazilabilir: false, Baslik: "Mobilden", Grup: "Mobil"),
            // YÖNETİCİ GÖRDÜ (eski ZIYARETGORULDUMOBIL): uçtan yazılır, kartta okunur.
            new("gorulduAd",
                "(select public.fn_taraf_ad(g.unvan, g.ad, g.soyad)::varchar(120) from public.taraf g where g.id = dis_hekim_ziyaret.goruldu_id)",
                "metin", Yazilabilir: false, Baslik: "Gören Yönetici", Grup: "Mobil"),
            new("gorulduZamani", "goruldu_zamani", "zaman", Yazilabilir: false, Baslik: "Görülme", Grup: "Mobil"),
        },
        Detaylar: new[]
        {
            // DOKTORUN TALEPLERİ: ziyaretten doğar; hekim / şube ziyaretten (tetik).
            new DetayTanimi("talepler", "public.dis_hekim_talep", "ziyaret_id", TalepAlanlari(hekimli: false),
                Sirala: "durum, termin nulls last, id", SubeKolonu: "sube_id", LogTabloId: 1782, Baslik: "Doktorun Talepleri",
                YeniSatirVarsayilanlari: new Dictionary<string, object?> { ["durum"] = (short)1, ["oncelik"] = (short)1, ["tur"] = (short)9 },
                BosAtlaAlani: "talep", GridKipi: true, AnindaKaydet: true),
            // YORUMLAR (yönetici ↔ temsilci): kim yazdı, ne zaman - uçtan değil karttan.
            new DetayTanimi("yorumlar", "public.dis_hekim_ziyaret_yorum", "ziyaret_id", new KartAlani[]
            {
                new("id",        "id",     "sayi",  Yazilabilir: false),
                new("yazanAd",
                    "(select public.fn_taraf_ad(y.unvan, y.ad, y.soyad)::varchar(120) from public.taraf y where y.id = dis_hekim_ziyaret_yorum.ekleyen)",
                    "metin", Yazilabilir: false, Baslik: "Yazan"),
                new("eklemeTarihi", "ekleme_tarihi", "zaman", Yazilabilir: false, Baslik: "Zaman"),
                new("yorum",     "yorum",  "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Yorum", TekSatir: true),
            }, Sirala: "id", SubeKolonu: null, LogTabloId: 1783, Baslik: "Yorumlar",
               BosAtlaAlani: "yorum", GridKipi: true, AnindaKaydet: true),
        },
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["tur"] = (short)1, ["amac"] = (short)1, ["sonuc"] = (short)1, ["hatirlat"] = (short)1,
        });

    private static KartTanimi DisHekimTalep() => new(
        Ad: "dis-hekim-talep",
        YetkiKodu: "dis_doktor.talep",
        Tablo: "public.dis_hekim_talep",
        LogTabloId: 1782,
        SubeKolonu: "sube_id",
        Alanlar: TalepAlanlari(hekimli: true),
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["durum"] = (short)1, ["oncelik"] = (short)1, ["tur"] = (short)9,
        });
}
