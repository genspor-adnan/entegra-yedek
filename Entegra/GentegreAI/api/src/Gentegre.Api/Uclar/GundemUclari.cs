using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÜNDEM ve KAYIT ÖNERİLERİ (kullanıcı 03.11.2026, mockup Ekranlar/ana_sayfa_yz_komut.html - katman 1 ve 2):
/// "kullanıcının rolüne göre yönlendirmesi gerek.. bugünkü işlerim .. 'Demir' yazarsa Demir İnşaat (Müş), Demir Medikal (Ted),
/// Demir Eren (Kişi), Demir Öztürk (Personel) gelse, seçince önerileri listelese".
///
/// <para><b>Tek motor, rol + yetki:</b> ERP / HBYS ayrımı yok. Her kart, her öneri ve her aranan kayıt türü bir yetki
/// koduna bağlı; yetkisi olmayana sorgu hiç çalışmaz, satır hiç dönmez (istemci gizlemez). Kullanıcı: "yetkisi yoksa fatura
/// kesemez".</para>
/// <para><b>YZ yok:</b> bu uçlar kural ve sayımdır - ücretsiz, denetlenebilir. Serbest soru (katman 3) ayrı.</para>
/// </summary>
public static partial class GundemUclari
{
    /// <summary>Ad aramasında tür başına en çok satır (toplam 5 tür).</summary>
    private const int TurBasinaSatir = 3;

    public static void GundemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        HizliBulUclari(yol);     // GundemUclari.HizliBul.cs - ad ile kayıt, düz VKN / TCKN
        GundemKartUcu(yol);      // GundemUclari.Kartlar.cs  - /api/gundem
        KayitOneriUcu(yol);      // GundemUclari.Oneriler.cs - /api/gundem/kayit
    }

    /// <summary>Faturası kesilmemiş irsaliye: kesin irsaliyenin en az bir satırında kesin hedef belgelere (kaynak_tur = 30)
    ///   aktarılmamış miktar kaldıysa - İrsaliye-Fatura Eşleşme icmalinin kuralı. @p0 belge türü · @p1 şubeler.</summary>
    private const string IrsaliyeSql = """
        select count(*)::int, coalesce(sum(b.genel_toplam), 0), coalesce(max(current_date - b.belge_tarihi::date), 0)::int
          from public.belge b
         where b.tur = @p0 and b.durum = 0
           and (b.sube_id is null or cardinality(@p1::int[]) = 0 or b.sube_id = any(@p1::int[]))
           and exists (select 1 from public.belge_satir s where s.belge_id = b.id and s.miktar > 0
                         and s.miktar - coalesce((select sum(hs.miktar) from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                                                   where hs.kaynak_tur = 30 and hs.kaynak_id = s.id and hb.durum = 0), 0) > 0.0001)
        """;

    private static readonly System.Globalization.CultureInfo Tr = new("tr-TR");
    private static string Para(decimal d) => d.ToString("N2", Tr);

    private sealed record Cari7(decimal Odeme7, int OdemeCari, decimal OdemeGecen, decimal TahsilBugun, decimal TahsilGecen,
        int TahsilGecenCari, int EnEskiGun, int Risk90, int RiskAsan, decimal Tahsil7, string OdemeIlk3);

    public sealed record GundemSatiri(string Ad, string Deger);
    public sealed record GundemEylemi(string Ad, string Yol);
    public sealed record GundemKarti(string Kod, string Baslik, string Ikon, string Sayi, string Ton,
        List<GundemSatiri> Satirlar, string Yol, List<GundemEylemi> Eylemler);
    public sealed record KayitOzeti(string Etiket, string Deger, string? Ton = null);
    public sealed record KayitEylemi(string Ad, string Yol, bool Birincil = false);
    public sealed record KayitOnerisi(string Kod, string Ikon, string Ad, string Neden, List<KayitEylemi> Eylemler);
}
