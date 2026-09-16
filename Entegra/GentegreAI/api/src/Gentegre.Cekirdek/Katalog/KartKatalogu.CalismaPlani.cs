namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// HEKİM ÇALIŞMA PLANI (711) kartları: şablon (tekrar eden kural) ve istisna.
/// Bayrak yerine geçen model - hekim "randevu verilebilir" = aktif şablonu var.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogCalismaSablon  = 1170;
    private const int LogCalismaIstisna = 1171;

    private static KartTanimi CalismaSablonKarti() => new(
        Ad: "calisma-sablon",
        YetkiKodu: "randevu.plan",
        Tablo: "public.hekim_calisma_sablon",
        LogTabloId: LogCalismaSablon,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["ad"] = "Standart hafta", ["gunler"] = "1,2,3,4,5", ["bas1"] = "09:00", ["bit1"] = "12:30",
            ["bas2"] = "13:30", ["bit2"] = "17:00", ["slotDk"] = (short)15, ["kanallar"] = "B,P,C",
            ["tekrar"] = (short)1, ["gecerliBas"] = "@simdi", ["aktif"] = (short)1,
        },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",            "sayi",  Yazilabilir: false),
            new("hekimId",      "hekim_id",      "kod",   Zorunlu: true, KodTablosu: "public.v_personel_lookup", Baslik: "Hekim", Grup: "Kimlik"),
            new("departmanId",  "departman_id",  "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm", Grup: "Kimlik"),
            new("subeId",       "sube_id",       "kod",   KodTablosu: "public.v_sube_lookup", Baslik: "Şube (boş = tümü)", Grup: "Kimlik"),
            new("ad",           "ad",            "metin", EnFazlaUzunluk: 80, Baslik: "Şablon Adı", Grup: "Kimlik"),
            new("aktif",        "aktif",         "mantik", Baslik: "Aktif", Grup: "Kimlik"),
            // Günler: "1,2,3,4,5" (1 Pzt … 7 Paz) - randevu.calisma_gunleri ile aynı biçim.
            new("gunler",       "gunler",        "metin", Zorunlu: true, EnFazlaUzunluk: 20, Baslik: "Günler (1 Pzt … 7 Paz)", Grup: "Saat"),
            new("bas1",         "bas1",          "metin", Zorunlu: true, EnFazlaUzunluk: 5, Baslik: "Sabah Başlangıç", Grup: "Saat"),
            new("bit1",         "bit1",          "metin", Zorunlu: true, EnFazlaUzunluk: 5, Baslik: "Sabah Bitiş", Grup: "Saat"),
            new("bas2",         "bas2",          "metin", EnFazlaUzunluk: 5, Baslik: "Öğleden Sonra Başlangıç", Grup: "Saat"),
            new("bit2",         "bit2",          "metin", EnFazlaUzunluk: 5, Baslik: "Öğleden Sonra Bitiş", Grup: "Saat"),
            new("slotDk",       "slot_dk",       "sayi",  Zorunlu: true, Baslik: "Slot (dk)", Grup: "Saat"),
            new("kanallar",     "kanallar",      "metin", EnFazlaUzunluk: 20, Baslik: "Kanallar (B banko · P portal · C çağrı)", Grup: "Kanal & Kota"),
            new("gunlukKota",   "gunluk_kota",   "sayi",  Baslik: "Günlük Kota (0 = sınırsız)", Grup: "Kanal & Kota"),
            new("portalYuzde",  "portal_yuzde",  "sayi",  Baslik: "Portal Payı %", Grup: "Kanal & Kota"),
            new("kontrolYuzde", "kontrol_yuzde", "sayi",  Baslik: "Kontrol Hastası Payı %", Grup: "Kanal & Kota"),
            new("tekrar",       "tekrar",        "kod",   KodListesi: "calisma.tekrar", Baslik: "Tekrar", Grup: "Geçerlilik"),
            new("gecerliBas",   "gecerli_bas",   "tarih", Zorunlu: true, Baslik: "Başlangıç", Grup: "Geçerlilik"),
            new("gecerliBit",   "gecerli_bit",   "tarih", Baslik: "Bitiş (boş = süresiz)", Grup: "Geçerlilik"),
            new("aciklama",     "aciklama",      "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama", Grup: "Geçerlilik"),
        });

    private static KartTanimi CalismaIstisnaKarti() => new(
        Ad: "calisma-istisna",
        YetkiKodu: "randevu.plan",
        Tablo: "public.hekim_calisma_istisna",
        LogTabloId: LogCalismaIstisna,
        SubeKolonu: null,
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["durum"] = (short)1, ["basTarih"] = "@simdi", ["bitTarih"] = "@simdi" },
        Alanlar: new KartAlani[]
        {
            new("id",           "id",            "sayi",  Yazilabilir: false),
            new("hekimId",      "hekim_id",      "kod",   Zorunlu: true, KodTablosu: "public.v_personel_lookup", Baslik: "Hekim", Grup: "Kimlik"),
            new("tur",          "tur",           "kod",   Zorunlu: true, KodListesi: "calisma.istisna_tur", Baslik: "Tür", Grup: "Kimlik"),
            new("departmanId",  "departman_id",  "kod",   KodTablosu: "public.v_departman_lookup", Baslik: "Bölüm (boş = tümü)", Grup: "Kimlik"),
            new("subeId",       "sube_id",       "kod",   KodTablosu: "public.v_sube_lookup", Baslik: "Şube (boş = tümü)", Grup: "Kimlik"),
            new("durum",        "durum",         "kod",   SabitKodlar: new Dictionary<string, string> { ["0"] = "Bekliyor", ["1"] = "Onaylı", ["2"] = "İptal" }, Baslik: "Durum", Grup: "Kimlik"),
            new("basTarih",     "bas_tarih",     "tarih", Zorunlu: true, Baslik: "Başlangıç", Grup: "Tarih & Saat"),
            new("bitTarih",     "bit_tarih",     "tarih", Zorunlu: true, Baslik: "Bitiş", Grup: "Tarih & Saat"),
            new("saatBas",      "saat_bas",      "metin", EnFazlaUzunluk: 5, Baslik: "Saat Başlangıç (saat değişikliği / ek mesai)", Grup: "Tarih & Saat"),
            new("saatBit",      "saat_bit",      "metin", EnFazlaUzunluk: 5, Baslik: "Saat Bitiş", Grup: "Tarih & Saat"),
            new("slotDk",       "slot_dk",       "sayi",  Baslik: "Slot (dk)", Grup: "Tarih & Saat"),
            new("kanallar",     "kanallar",      "metin", EnFazlaUzunluk: 20, Baslik: "Kanallar", Grup: "Tarih & Saat"),
            new("aciklama",     "aciklama",      "metin", EnFazlaUzunluk: 300, Baslik: "Açıklama / neden", Grup: "Tarih & Saat"),
        });
}
