namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KURUMSAL KALİTE (1049) — ayar listelerinin aksiyonları. Kalite Dokümanları
/// listesi kendi ekranını açmaz: doküman listesinin aksiyon ekranını
/// ("dokuman-liste": yükle, düzenle, aç, paylaş...) kullanır.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleKysAyar(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {
        s["kys-birim-sorumlu-liste"] = Crud("kys-birim-sorumlu", "kys", "kys.ayar", ekleAdi: "＋ Sorumlu ata", yazdir: false);
        // Komite silinmez (kart SilmeYok) - pasife alınır.
        s["kys-komite-liste"] = Crud("kys-komite", "kys", "kys.komite", ekleAdi: "＋ Komite", yazdir: false, sil: false);
    }
}
