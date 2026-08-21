using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Bir aksiyonun tanimi (API §7). Arac cubugu, sag tus menusu ve komut paleti
/// AYNI KATALOGDAN uretilir - Delphi'de bu uc yer ayri ayri kodlaniyordu ve
/// zamanla birbirinden ayrisiyordu.
/// </summary>
public sealed record AksiyonTanimi(
    string Kod,                    // "belge.yeni", "ebelge.gonder"
    string Ad,
    string Grup,
    /// <summary>Hangi yuzeyde gorunur: araccubugu | sagtus | palet (virgullu).</summary>
    string Hedef = "araccubugu,sagtus,palet",
    string? Kisayol = null,
    /// <summary>Kaynak yetkisi (or. "cari") + islem. Null ise AksiyonYetkisi bakilir.</summary>
    string? KaynakKodu = null,
    Islem Islem = Islem.Gor,
    /// <summary>Aksiyon yetkisi kodu (yetki tablosunda tur = 1).</summary>
    string? AksiyonYetkisi = null,
    /// <summary>Kayit secilmeden calismaz (sag tus / liste secimi).</summary>
    bool KayitGerekir = false,
    int Sira = 0);

/// <summary>Ekran basina aksiyon listesi.</summary>
public static class AksiyonKatalogu
{
    private static readonly Dictionary<string, IReadOnlyList<AksiyonTanimi>> Ekranlar =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["cari-liste"] = new AksiyonTanimi[]
            {
                new("cari.yeni",    "＋ Yeni",     "kart", Kisayol: "Ctrl+N",
                    KaynakKodu: "cari", Islem: Islem.Ekle, Sira: 10),
                new("cari.duzenle", "✎ Düzenle",   "kart", Kisayol: "Enter",
                    KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("cari.sil",     "Sil",         "kart", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["kisi-liste"] = new AksiyonTanimi[]
            {
                new("kisi.yeni",    "＋ Yeni",     "kisi", Kisayol: "Ctrl+N",
                    KaynakKodu: "cari", Islem: Islem.Ekle, Sira: 10),
                new("kisi.duzenle", "✎ Düzenle",   "kisi", Kisayol: "Enter",
                    KaynakKodu: "cari", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("kisi.sil",     "Sil",         "kisi", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },
            ["rol-liste"] = new AksiyonTanimi[]
            {
                new("rol.yeni",    "＋ Yeni",     "rol", Kisayol: "Ctrl+N",
                    KaynakKodu: "rol", Islem: Islem.Ekle, Sira: 10),
                new("rol.duzenle", "✎ Düzenle",   "rol", Kisayol: "Enter",
                    KaynakKodu: "rol", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("rol.sil",     "Sil",         "rol", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "rol", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            },
            ["personel-liste"] = new AksiyonTanimi[]
            {
                new("personel.yeni",    "＋ Yeni",     "personel", Kisayol: "Ctrl+N",
                    KaynakKodu: "personel", Islem: Islem.Ekle, Sira: 10),
                new("personel.duzenle", "✎ Düzenle",   "personel", Kisayol: "Enter",
                    KaynakKodu: "personel", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("personel.sil",     "Sil",         "personel", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "personel", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["stok-liste"] = new AksiyonTanimi[]
            {
                new("stok.yeni",    "＋ Yeni",     "stok", Kisayol: "Ctrl+N",
                    KaynakKodu: "stok", Islem: Islem.Ekle, Sira: 10),
                new("stok.duzenle", "✎ Düzenle",   "stok", Kisayol: "Enter",
                    KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("stok.sil",     "Sil",         "stok", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["belge-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",  "＋ Yeni",      "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",    "Belgeyi Ac",   "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.kesinlestir", "Kesinlestir", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 30),
                new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                new("ebelge.gonder", "e-Fatura Gonder", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 50),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["belge-kart"] = new AksiyonTanimi[]
            {
                new("belge.kesinlestir", "Kesinlestir", "belge",
                    AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 10),
                new("ebelge.gonder", "e-Fatura Gonder", "ebelge",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 20),
                new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 30),
            },

            ["cari-kart"] = new AksiyonTanimi[]
            {
                new("cari.sil", "Sil", "kart", Hedef: "araccubugu,palet",
                    KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
            },

            ["stok-kart"] = new AksiyonTanimi[]
            {
                new("stok.sil", "Sil", "stok", Hedef: "araccubugu,palet",
                    KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
            },
        };

    public static IReadOnlyList<AksiyonTanimi>? Ekran(string ad)
        => Ekranlar.TryGetValue(ad, out var liste) ? liste : null;

    public static IEnumerable<string> EkranAdlari => Ekranlar.Keys;

    /// <summary>Aksiyon kullanicinin yetkisine giriyor mu (§7: yetkisiz aksiyon HIC donmez).</summary>
    public static bool Yetkili(AksiyonTanimi aksiyon, YetkiSeti yetkiler)
    {
        if (aksiyon.KaynakKodu is { } kaynak) return yetkiler.Var(kaynak, aksiyon.Islem);
        if (aksiyon.AksiyonYetkisi is { } kod) return yetkiler.AksiyonVar(kod);
        return true;
    }
}
