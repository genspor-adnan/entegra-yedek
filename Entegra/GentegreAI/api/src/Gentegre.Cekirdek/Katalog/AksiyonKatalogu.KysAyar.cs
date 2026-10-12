using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1049) — ayar listelerinin aksiyonları; Kalite Dokümanları
/// (1068) kendi kaynağıyla, doküman yükle / aç aksiyonlarını kullanır.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysAyar(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        // KALİTE DOKÜMANLARI (1068, mockup): yükleme ve açma Doküman modülünün
        //   aksiyonları (doküman yetkisi); "Tüm Dokümanlar" Doküman listesine gider.
        s["kys-dokuman-liste"] =
        [
            new("dokuman.yukle", "⬆ Doküman Yükle", "dokuman", Hedef: "araccubugu,palet",
                KaynakKodu: "dokuman", Islem: Islem.Ekle, Sira: 5),
            new("dokuman.ac", "⬇ Aç / İndir", "dokuman", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "dokuman", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("kys.dokuman-tumu", "🗄️ Tüm Dokümanlar", "kys", KaynakKodu: "dokuman", Sira: 40),
            Yazdir(),
        ];
        s["kys-birim-sorumlu-liste"] = Crud("kys-birim-sorumlu", "kys", "kys.ayar", ekleAdi: "＋ Sorumlu ata", yazdir: false);
        // Komite silinmez (kart SilmeYok) - pasife alınır.
        s["kys-komite-liste"] = Crud("kys-komite", "kys", "kys.komite", ekleAdi: "＋ Komite", yazdir: false, sil: false);
    }
}
