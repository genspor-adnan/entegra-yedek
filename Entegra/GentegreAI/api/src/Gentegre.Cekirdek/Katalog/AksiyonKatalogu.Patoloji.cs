using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// PATOLOJİ AKSİYONLARI (1104). Vaka adımları: hazırlandı → pakete ekle →
/// (gönderimde kurye / lab teslim) → lab kabul (lab vaka no) → rapor (kartta,
/// elle ya da entegrasyonla) → hekim gördü. Ek inceleme onayı ayrı yetki.
/// Uçlar: PatolojiUclari (/api/patoloji).
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EklePatoloji(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["patoloji-vaka-liste"] =
        [
            .. Crud("patoloji-vaka", "patoloji-vaka", "patoloji.vaka", ekleAdi: "＋ Yeni Patoloji İstemi"),
            new("patoloji.hazirlandi", "🏷 Hazırlandı", "patoloji-vaka", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.vaka", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40,
                Ipucu: "Kaplar etiketlendi, gönderime hazır"),
            new("patoloji.pakete-ekle", "📦 Pakete Ekle", "patoloji-vaka", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.gonderim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41,
                Ipucu: "Seçili dış lab vakalarını o labın açık gönderim paketine ekler"),
            new("patoloji.lab-kabul", "📥 Lab Kabul", "patoloji-vaka", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.vaka", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42,
                Ipucu: "Lab teslim aldı, vaka numarasını döndü - TAT başlar"),
            new("patoloji.gordum", "👁 Gördüm", "patoloji-vaka", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.vaka", Islem: Islem.Gor, KayitGerekir: true, Sira: 43,
                Ipucu: "İsteyen hekim raporu gördü / okudu"),
            new("patoloji.ek-onayla", "✔ Ek İncelemeyi Onayla", "patoloji-vaka", Hedef: "sagtus,palet",
                KaynakKodu: "patoloji.vaka", AksiyonYetkisi: "patoloji.ek-onay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50),
            new("patoloji.ek-reddet", "✖ Ek İncelemeyi Reddet", "patoloji-vaka", Hedef: "sagtus,palet",
                KaynakKodu: "patoloji.vaka", AksiyonYetkisi: "patoloji.ek-onay", Islem: Islem.Degistir, KayitGerekir: true, Sira: 51),
            new("patoloji.ret", "⛔ Reddedildi", "patoloji-vaka", Hedef: "sagtus,palet",
                KaynakKodu: "patoloji.vaka", Islem: Islem.Degistir, KayitGerekir: true, Sira: 52,
                Ipucu: "Lab / kabul numuneyi reddetti (uygunsuz, eksik)"),
            new("patoloji.paketten-cikar", "↩ Paketten Çıkar", "patoloji-vaka", Hedef: "sagtus,palet",
                KaynakKodu: "patoloji.gonderim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 53),
        ];

        s["patoloji-gonderim-liste"] =
        [
            .. Crud("patoloji-gonderim", "patoloji-gonderim", "patoloji.gonderim", ekleAdi: "＋ Yeni Gönderim"),
            new("patoloji.laba-ilet", "📤 Laba İlet", "patoloji-gonderim", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.gonderim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40,
                Ipucu: "İstem bilgisi laba iletildi (entegrasyon yoksa basılı form / portal)"),
            new("patoloji.kurye", "🚚 Kurye Teslim Aldı", "patoloji-gonderim", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.gonderim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41),
            new("patoloji.lab-teslim", "📦 Lab Teslim Aldı", "patoloji-gonderim", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "patoloji.gonderim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42),
        ];

        s["patoloji-materyal-tipi-liste"] = Crud("patoloji-materyal-tipi", "patoloji-materyal-tipi", "patoloji.tanim.materyal");
        s["patoloji-boya-liste"] = Crud("patoloji-boya", "patoloji-boya", "patoloji.tanim.boya");
        s["patoloji-ret-nedeni-liste"] = Crud("patoloji-ret-nedeni", "patoloji-ret-nedeni", "patoloji.tanim.ret");
    }
}
