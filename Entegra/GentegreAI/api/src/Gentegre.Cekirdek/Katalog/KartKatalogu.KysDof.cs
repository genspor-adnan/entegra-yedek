namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE — DÖF kartı (1050, sade): generic kart + faaliyetler detayı.
/// TEK SAYFA (mockup Ekranlar/Kalite2/dof_karti.html): başlık alanları
/// "Kimlik" grubunda (kimlik şeridi), geri kalanı tek "DÖF" grubunda - Sorun /
/// Faaliyetler / Doğrulama sırası web'de (kartOzellestirme + ListeKarti).
/// Numara tablo varsayılanından (fn_kalite_no). Kaynaktan "DÖF Aç" yeni kartı
/// kaynakTur / kaynakId / kaynakNo / departmanId / tanim dolu açar (ListeKarti).
/// Log tablo kodları 1410-1411.
/// </summary>
public static partial class KartKatalogu
{
    private const int LogKysDof = 1410;
    private const int LogKysDofFaaliyet = 1411;

    private static readonly Dictionary<string, string> KysDofSonuclari = new() { ["1"] = "Etkin", ["2"] = "Kısmen etkin", ["3"] = "Etkin değil" };
    private static readonly Dictionary<string, string> KysFaaliyetDurumlari = new() { ["0"] = "Başlamadı", ["1"] = "Sürüyor", ["2"] = "Tamamlandı" };

    private static KartTanimi KysDofKarti() => new(
        Ad: "kys-dof",
        YetkiKodu: "kys.dof",
        Tablo: "public.kalite_dof",
        LogTabloId: LogKysDof,
        SubeKolonu: "sube_id",
        YeniKayitVarsayilanlari: new Dictionary<string, object?> { ["tur"] = (short)1, ["kaynakTur"] = (short)9, ["durum"] = (short)1 },
        Alanlar: new KartAlani[]
        {
            new("id",              "id",               "sayi",  Yazilabilir: false),
            new("no",              "no",               "metin", Yazilabilir: false, Baslik: "DÖF No", Grup: "Kimlik"),
            new("tur",             "tur",              "kod",   Zorunlu: true, SabitKodlar: KaynakKatalogu.KysDofTurleri, Baslik: "Tür", Grup: "Kimlik"),
            new("durum",           "durum",            "kod",   Zorunlu: true, SabitKodlar: KaynakKatalogu.KysDofDurumlari, Baslik: "Durum", Grup: "Kimlik"),
            new("kaynakTur",       "kaynak_tur",       "kod",   Zorunlu: true, SabitKodlar: KaynakKatalogu.KysDofKaynaklari, Baslik: "Kaynak", Grup: "Kimlik"),
            new("kaynakNo",        "kaynak_no",        "metin", EnFazlaUzunluk: 40, Baslik: "Kaynak no", Grup: "Kimlik"),
            new("kaynakId",        "kaynak_id",        "sayi",  Baslik: "Kaynak kayıt Id", Grup: "DÖF"),
            new("departmanId",     "departman_id",     "kod",   Zorunlu: true, KodTablosu: "public.v_departman_lookup", Baslik: "Birim", Grup: "Kimlik"),
            new("sorumluId",       "sorumlu_id",       "kod",   Zorunlu: true, KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu", Grup: "Kimlik"),
            // Termin boş bırakılırsa INSERT tetiği bugün + kys.dof_termin_gun yazar (1059):
            //   katalog varsayılanı sabit, ayardaki gün sayısını okuyamaz.
            new("termin",          "termin",           "tarih", Ipucu: "Boş bırakılırsa ayardaki gün sayısı eklenir.", Baslik: "Termin", Grup: "Kimlik"),
            new("tanim",           "tanim",            "metin", Zorunlu: true, EnFazlaUzunluk: 4000, Baslik: "Sorun nedir?", Grup: "DÖF", AltGrup: "Sorun"),
            new("kokNeden",        "kok_neden",        "metin", EnFazlaUzunluk: 2000, Baslik: "Kök neden", Grup: "DÖF", AltGrup: "Sorun"),
            new("dogrulamaSonuc",  "dogrulama_sonuc",  "kod",   SabitKodlar: KysDofSonuclari, Baslik: "Etkili oldu mu? (doğrulama)", Grup: "DÖF", AltGrup: "Doğrulama"),
            new("dogrulamaTarihi", "dogrulama_tarihi", "tarih", Baslik: "Doğrulama tarihi", Grup: "DÖF", AltGrup: "Doğrulama"),
            // Açan / açılış (mockup "Açan"): kimlik şeridinde salt okunur.
            new("ekleyen",         "ekleyen",          "kod",   Yazilabilir: false, KodTablosu: "public.v_kullanici_lookup", Baslik: "Açan", Grup: "Kimlik"),
            new("eklemeTarihi",    "ekleme_tarihi",    "tarih", Yazilabilir: false, Baslik: "Açılış", Grup: "Kimlik"),
        },
        Detaylar: new DetayTanimi[]
        {
            new("faaliyetler", "public.kalite_dof_faaliyet", "dof_id", new KartAlani[]
            {
                new("id",        "id",         "sayi",  Yazilabilir: false),
                new("faaliyet",  "faaliyet",   "metin", Zorunlu: true, EnFazlaUzunluk: 1000, Baslik: "Faaliyet"),
                new("sorumluId", "sorumlu_id", "kod",   KodTablosu: "public.v_personel_lookup", Baslik: "Sorumlu"),
                new("termin",    "termin",     "tarih", Baslik: "Termin"),
                new("durum",     "durum",      "kod",   SabitKodlar: KysFaaliyetDurumlari, Baslik: "Durum"),
            }, Sirala: "id", Baslik: "Faaliyetler", LogTabloId: LogKysDofFaaliyet),
        });
}
