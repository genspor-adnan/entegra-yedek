namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ÇEK / SENET PORTFÖY İŞLEMLERİ (1386; kullanıcı 20.11.2026: "işlem buton ve altında menüyü de ekle", "çek/senet
/// hareketleri aynı delphi erp deki çek/senet hareketleri gibi olmalı").
///
/// Delphi UCekListeFrame (PopupMenuOlustur / CekIslemleriClick) birebir: alınan kıymette Cirola, Teminata Ver
/// (Cariye / Bankaya), Takasa Ver, İcraya Ver, Karşılıksız İşaretle, Tahsil Et, İade Et, Portföye Al; verilen
/// kıymette Ödemesini Yap, İade Al, Satıcıya Ver, İptal Et. Hangi durumdan hangisinin yapılabildiği de Delphi'nin
/// menüsüdür. Hareket kodları web'in kodlarıdır (1147 aktarımı Delphi CEKHAREKET.ISLEM'i bunlara eşledi).
///
/// MUHASEBE Delphi'nin cari kuralıyla (1147): ciro, cariye teminat, icra ve iade carinin BORCU (kasa 52 / 56 -
/// cari B, portföy A); portföye geri alma / verilenin iadesi önceki cari etkinin TERSİ (kasa 23 / 24 - portföy B,
/// cari A); tahsil (51 / 53) ve ödeme (55) para hesabına. Takas, bankaya teminat, karşılıksız ve iptal yalnız durum
/// (Delphi de kasa / cari yazmaz).
/// </summary>
public static class CekSenetIslemleri
{
    /// <summary>Kullanıcıdan istenen hedef: cari seçimi, para / banka hesabı seçimi ya da hiçbiri.</summary>
    public const string HedefCari = "cari", HedefHesap = "hesap", HedefYok = "";

    /// <param name="Kod">İstekteki işlem anahtarı.</param>
    /// <param name="Ad">Menü yazısı (Delphi başlığı); "…" pencere açılır demek.</param>
    /// <param name="Ikon">Menü simgesi.</param>
    /// <param name="Yon">1 alınan · 2 verilen.</param>
    /// <param name="Durumlar">İşlemin yapılabildiği mevcut durumlar.</param>
    /// <param name="YeniDurum">cek_senet.durum (10 portföy, 20 ciro, 30 takas, 40 teminat, 50 tahsil / ödendi,
    /// 60 karşılıksız / icra, 70 iade, 0 iptal).</param>
    /// <param name="Hareket">cek_senet_hareket.islem.</param>
    /// <param name="KasaCek">Çekte yazılan kasa işlem türü (0 yok; -1 = önceki cari etkinin tersi gerekiyorsa 23/24).</param>
    /// <param name="KasaSenet">Senette yazılan kasa işlem türü.</param>
    /// <param name="Ayrac">Menüde bu maddeden önce ayraç.</param>
    public sealed record Kural(string Kod, string Ad, string Ikon, int Yon, int[] Durumlar, int YeniDurum, int Hareket,
                              string Hedef, int KasaCek, int KasaSenet, bool Ayrac = false);

    /// <summary>Önceki cari etkiyi tersine çevir (portföye geri alma / verilenin iadesi).</summary>
    public const int KasaTers = -1;

    public static readonly IReadOnlyList<Kural> Kurallar = new Kural[]
    {
        // ---- ALINAN (Delphi 130-139) ----
        new("portfoye-al", "Portföye Al", "↩", 1, [20, 30, 40, 60, 70], 10, 130, HedefYok,   KasaTers, KasaTers),
        new("cirola", "Cirola…", "➡", 1, [10], 20, 131, HedefCari,  52, 52, Ayrac: true),
        new("teminat-cari", "Teminata Ver › Cariye…", "🔒", 1, [10], 40, 137, HedefCari,  52, 52),
        new("teminat-banka", "Teminata Ver › Bankaya…", "🔒", 1, [10], 40, 137, HedefHesap, 0, 0),
        new("takas", "Takasa Ver…", "🏦", 1, [10], 30, 132, HedefHesap, 0, 0),
        new("icra", "İcraya Ver…", "⚖", 1, [10], 60, 140, HedefCari,  52, 52),
        new("karsiliksiz", "Karşılıksız İşaretle", "⚠", 1, [10], 60, 134, HedefYok,   0, 0),
        new("tahsil", "Tahsil Et…", "💵", 1, [10, 30, 60], 50, 133, HedefHesap, 51, 53, Ayrac: true),
        new("iade", "İade Et", "↪", 1, [10], 70, 135, HedefYok,   56, 56),
        // ---- VERİLEN (Delphi 140-149) ----
        new("odendi", "Ödemesini Yap…", "💵", 2, [10], 50, 136, HedefHesap, 55, 55),
        new("iade-al", "İade Al", "↩", 2, [10], 70, 135, HedefYok,   KasaTers, KasaTers, Ayrac: true),
        new("saticiya-ver", "Satıcıya Ver", "➡", 2, [70], 10, 130, HedefYok,   33, 34),
        new("iptal", "İptal Et", "✖", 2, [70], 0,  139, HedefYok,   0, 0),
    };

    public static Kural? Bul(string? kod) => Kurallar.FirstOrDefault(k => k.Kod == kod);

    /// <summary>Kıymetin yönüne ve durumuna göre yapılabilecek işlemler (Delphi menüsü).</summary>
    public static IEnumerable<Kural> Yapilabilir(int yon, int durum)
        => Kurallar.Where(k => k.Yon == yon && k.Durumlar.Contains(durum));

    /// <summary>Kasa türü: tersine çevirme 23 (çek) / 24 (senet) - portföy B, cari A.</summary>
    public static int KasaTuru(Kural k, bool senet) => senet ? k.KasaSenet : k.KasaCek;
}
