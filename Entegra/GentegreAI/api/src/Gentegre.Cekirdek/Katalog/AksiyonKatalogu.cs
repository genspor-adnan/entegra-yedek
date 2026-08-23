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
            ["hasta-liste"] = new AksiyonTanimi[]
            {
                new("hasta.yeni",    "＋ Yeni",     "hasta", Kisayol: "Ctrl+N",
                    KaynakKodu: "personel", Islem: Islem.Ekle, Sira: 10),
                new("hasta.duzenle", "✎ Düzenle",   "hasta", Kisayol: "Enter",
                    KaynakKodu: "personel", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("hasta.sil",     "Sil",         "hasta", Hedef: "sagtus,palet", Kisayol: "Del",
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

            // Hesap ekranlari (Kasa / Banka / POS / Kredi Karti / Kredi) - hepsi
            //   ayni 'hesap' kaynagi, tur'e gore ayri liste.
            ["hesap-liste"] = new AksiyonTanimi[]
            {
                new("hesap.yeni",    "＋ Ekle",     "hesap", Kisayol: "Ctrl+N",
                    KaynakKodu: "hesap", Islem: Islem.Ekle, Sira: 10),
                new("hesap.duzenle", "✎ Düzenle",   "hesap", Kisayol: "Enter",
                    KaynakKodu: "hesap", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("hesap.sil",     "🗑 Sil",      "hesap", Kisayol: "Del",
                    KaynakKodu: "hesap", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                // Secili hesabin EKSTRESI: /hesap-ekstre?hesapId=<id> (v_hesap_ekstre,
                //   yurumeli bakiye). Liste tarafinda urlFiltreAlani zaten hazir.
                new("hesap.ekstre",  "📄 Ekstre",   "hesap", Kisayol: "Ctrl+E",
                    KaynakKodu: "hesap", Islem: Islem.Gor, KayitGerekir: true, Sira: 40),
                new("genel.yazdir",  "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Cek / Senet portfoyu. Cek uzerindeki ISLEMLER (tahsil/ciro/bozdurma)
            //   kasa turleriyle yapilir - Kasa planinin F5 fazinda baglanacak;
            //   burada simdilik kart islemleri var.
            ["cek-senet-liste"] = new AksiyonTanimi[]
            {
                new("cek-senet.yeni",    "＋ Ekle",     "cek-senet", Kisayol: "Ctrl+N",
                    KaynakKodu: "cek_senet", Islem: Islem.Ekle, Sira: 10),
                new("cek-senet.duzenle", "✎ Düzenle",   "cek-senet", Kisayol: "Enter",
                    KaynakKodu: "cek_senet", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("cek-senet.sil",     "🗑 Sil",      "cek-senet", Kisayol: "Del",
                    KaynakKodu: "cek_senet", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
                new("genel.yazdir",      "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Stok Ayarlari > Depolar sekmesi.
            ["depo-liste"] = new AksiyonTanimi[]
            {
                new("depo.yeni",    "＋ Ekle",   "depo", Kisayol: "Ctrl+N",
                    KaynakKodu: "stok", Islem: Islem.Ekle, Sira: 10),
                new("depo.duzenle", "✎ Düzenle", "depo", Kisayol: "Enter",
                    KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
                new("depo.sil",     "🗑 Sil",    "depo", Kisayol: "Del",
                    KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            },

            ["belge-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",  "＋ Yeni",      "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",    "Belgeyi Ac",   "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.kesinlestir", "Kesinlestir", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 30),
                new("belge.donustur", "⇢ Dönüştür", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 35),
                new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                new("ebelge.gonder", "e-Fatura Gonder", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 50),
                new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Siparis listesi: buradan irsaliye/faturaya donusum yapilir (F8).
            //   Ayni 'belge' kaynagi, tur in (9,19) sabit filtresiyle.
            ["siparis-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",     "＋ Yeni Sipariş", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",       "Aç",              "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.donustur", "⇢ Dönüştür",      "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                new("belge.iptal",    "İptal Et",        "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
                new("genel.yazdir",   "🖨️ Yazdır",    "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            // Irsaliye listesi (Ekranlar/satis_irsaliye_listesi.html aksiyonlari).
            //   Ucu olan ucu calisir: ac, donustur, yeni. Digerleri yetkiye bagli
            //   gorunur ama tiklaninca "henuz baglanmadi" der.
            ["irsaliye-liste"] = new AksiyonTanimi[]
            {
                new("belge.yeni",     "＋ Yeni İrsaliye", "belge", Kisayol: "Ctrl+N",
                    KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
                new("belge.ac",       "İrsaliyeyi Aç",    "belge", Kisayol: "Enter",
                    KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("belge.donustur", "🧾 Faturaya Dönüştür", "belge",
                    AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
                new("ebelge.gonder",  "📨 e-İrsaliye Gönder", "ebelge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 40),
                new("belge.iptal",    "✖ İrsaliyeyi İptal Et", "belge", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 50),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
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

            // ---------------------------------------------------------- kasa ----
            // "Yeni" tek dugme degil, tur GRUBU basina bir giris: tahsilat ile
            //   odeme ayni ekrandir ama kullanicinin kafasinda ayri islemdir.
            ["kasa-liste"] = new AksiyonTanimi[]
            {
                new("kasa.tahsilat.yeni", "＋ Tahsilat", "kasa", Kisayol: "Ctrl+N",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
                new("kasa.odeme.yeni",    "－ Ödeme",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 20),
                new("kasa.virman.yeni",   "⇄ Virman",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 22),
                new("kasa.doviz.yeni",    "💱 Döviz",    "kasa",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 24),
                new("kasa.plan.yeni",     "📅 Plan",     "kasa", Hedef: "araccubugu,palet",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 26),
                new("kasa.ac",            "Aç",          "kasa", Kisayol: "Enter",
                    KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
                new("kasa.kesinlestir",   "Kesinleştir", "kasa", Hedef: "araccubugu,sagtus,palet",
                    AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 40),
                new("kasa.iptal",         "İptal Et",    "kasa", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 50),
                new("kasa.sil",           "Sil",         "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 60),
                new("kasa.fis-gor",       "Muhasebe Fişi", "muhasebe", Hedef: "sagtus,palet",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 70),
                new("genel.yazdir",       "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["kasa-kart"] = new AksiyonTanimi[]
            {
                new("kasa.kesinlestir", "Kesinleştir", "kasa",
                    AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 10),
                new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                    AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 15),
                new("kasa.fis-gor",     "Muhasebe Fişi", "muhasebe",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("kasa.iptal",       "İptal Et",    "kasa", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 30),
                new("kasa.sil",         "Sil",         "kasa", Hedef: "sagtus,palet",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
            },

            // Acik planlar: buradan "Gerceklestir" ile tahsilat/odeme uretilir.
            //   Plan kaydin KENDISI degismez (K10) - yeni bir islem acilir.
            ["plan-liste"] = new AksiyonTanimi[]
            {
                new("kasa.plan.yeni",    "📅 Yeni Plan", "kasa", Kisayol: "Ctrl+N",
                    KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
                new("kasa.ac",           "Aç",           "kasa", Kisayol: "Enter",
                    KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
                new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                    AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 30),
                new("kasa.sil",          "Sil",          "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                    KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
                new("genel.yazdir",      "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
            },

            ["fis-liste"] = new AksiyonTanimi[]
            {
                new("fis.ac",         "Aç",           "muhasebe", Kisayol: "Enter",
                    KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
                new("fis.ters-kayit", "Ters Kayıt",   "muhasebe", Hedef: "sagtus,palet",
                    AksiyonYetkisi: "fis.ters-kayit", KayitGerekir: true, Sira: 20),
                new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                    AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
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
