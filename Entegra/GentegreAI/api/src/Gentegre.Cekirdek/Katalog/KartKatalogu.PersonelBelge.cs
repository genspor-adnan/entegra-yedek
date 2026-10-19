namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PERSONEL BELGE TAKİBİ (1135) — belge türü tanım kartı + kapsam (kime zorunlu).
/// Personel kartının "Belgeler" / "Belge Durumu" sekmeleri Personel() kartında.
/// Log 1600 (tür) · 1601 (kapsam) · 1602 (personel belgesi).
/// </summary>
public static partial class KartKatalogu
{
    private const int LogPersonelBelgeTuru = 1600;
    private const int LogPersonelBelgeKapsam = 1601;
    private const int LogPersonelBelge = 1602;

    /// <summary>Belge grubu: listede ve kartta aynı sıra.</summary>
    private static readonly Dictionary<string, string> PersonelBelgeGrupKodlari = new()
    {
        ["1"] = "Kimlik / işe giriş", ["2"] = "Mesleki", ["3"] = "Sağlık / İSG", ["4"] = "İdari", ["5"] = "Diğer",
    };

    private static KartTanimi PersonelBelgeTuruKarti() => new(
        Ad: "personel-belge-turu",
        YetkiKodu: "ik.belge_takip",
        Tablo: "public.personel_belge_turu",
        LogTabloId: LogPersonelBelgeTuru,
        YeniKayitVarsayilanlari: new Dictionary<string, object?>
        {
            ["aktif"] = (short)1, ["grup"] = (short)5, ["hatirlatGun"] = (short)60,
        },
        Alanlar: new KartAlani[]
        {
            new("id",            "id",            "sayi",  Yazilabilir: false),
            new("ad",            "ad",            "metin", Zorunlu: true, EnFazlaUzunluk: 150, Baslik: "Belge adı", Grup: "Belge türü"),
            new("grup",          "grup",          "kod",   SabitKodlar: PersonelBelgeGrupKodlari, Zorunlu: true, Baslik: "Grup", Grup: "Belge türü"),
            new("gecerlilikAy",  "gecerlilik_ay", "sayi",  Baslik: "Geçerlilik, ay (boş = süresiz)", Grup: "Belge türü"),
            new("hatirlatGun",   "hatirlat_gun",  "sayi",  Zorunlu: true, Baslik: "Kaç gün önce uyarılsın", Grup: "Belge türü"),
            new("sira",          "sira",          "sayi",  Baslik: "Sıra", Grup: "Belge türü"),
            new("aktif",         "aktif",         "kod",   SabitKodlar: KysAktifKodlari, Baslik: "Durum", Grup: "Belge türü"),
            new("aciklama",      "aciklama",      "metin", EnFazlaUzunluk: 400, Baslik: "Açıklama", Grup: "Belge türü"),
        },
        Detaylar: new[]
        {
            // KİME ZORUNLU: satırda birim ve/veya görev; ikisi boş satır = tüm personel.
            //   Hiç satır yoksa belge isteğe bağlıdır (girilebilir, eksik sayılmaz).
            new DetayTanimi("kapsam", "public.personel_belge_kapsam", "belge_turu_id", new KartAlani[]
            {
                new("id",          "id",           "sayi", Yazilabilir: false),
                new("departmanId", "departman_id", "kod",  KodTablosu: "public.v_departman_lookup", Baslik: "Birim (boş = hepsi)"),
                new("gorevId",     "gorev_id",     "kod",  KodTablosu: "public.v_gorev_lookup", BagliAlan: "departmanId", Baslik: "Görev (boş = hepsi)"),
            }, SubeKolonu: null, LogTabloId: LogPersonelBelgeKapsam, Baslik: "Kime zorunlu"),
        });
}
