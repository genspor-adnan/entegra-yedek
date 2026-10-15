using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KONSÜLTASYON AKSİYONLARI (1107) — mockup konsultasyon_listesi.html araç çubuğu.
/// "Üstlen" YOK (kullanıcı: "üstlenme yerine yanıtlama terimini kullan"): ✋ Yanıtla
/// isteği hekime alır ve yanıt muayenesini açar. Uçlar: KonsultasyonUclari.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKonsultasyon(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["konsultasyon-liste"] =
        [
            // 🗑 Sil araç çubuğunda (kullanıcı 15.10.2026); yalnız taslak istek silinir (db/1111).
            .. Crud("konsultasyon", "konsultasyon", "muayene.konsultasyon", ekleAdi: "＋ Yeni Konsültasyon İsteği",
                    silHedef: null, silIpucu: "Yalnız taslak istek silinir"),
            new("konsultasyon.yanitla", "✋ Yanıtla", "konsultasyon", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene.konsultasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40,
                Ipucu: "İsteği alır ve yanıt muayenesini açar"),
            new("konsultasyon.yonlendir", "↪ Yönlendir", "konsultasyon", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene.konsultasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 41,
                Ipucu: "Başka bölüme / hekime (gerekçeli); süre sıfırlanmaz"),
            new("konsultasyon.reddet", "✕ Reddet", "konsultasyon", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene.konsultasyon", Islem: Islem.Degistir, KayitGerekir: true, Sira: 42,
                Ipucu: "Gerekçeli ret - isteyen hekim bilgilenir"),
            new("konsultasyon.gordum", "👁 Gördüm", "konsultasyon", Hedef: "sagtus,palet",
                KaynakKodu: "muayene.konsultasyon", Islem: Islem.Gor, KayitGerekir: true, Sira: 43,
                Ipucu: "İsteyen hekim yanıtı gördü"),
        ];
    }
}
