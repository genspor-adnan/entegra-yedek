using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTA KAYDI — mükerrer kontrolü. Kullanıcı: "yeni hasta eklerken kimlik no
/// aynı ise eklenmez, diğer kayıt getirilir; telefon aynı ise uyarı verilir,
/// istenirse devam edilip eklenebilir."
///
///   GET /api/hasta/mukerrer?vkno=&amp;cepTel=&amp;haric=   kimlik eşleşmesi (tek kayıt) +
///                                                  telefon eşleşmeleri (en çok 5)
///
/// İki kural iki yerde:
///  - KİMLİK = ENGEL: ekran kaydetmeden önce sorar ve mevcut kartı açar; ekran
///    atlasa bile kart ucu (<see cref="KimlikMukerrerKuraliAsync"/>) kaydı reddeder.
///  - TELEFON = UYARI: yalnız ekranda sorulur (aile bireyleri aynı numarayı
///    paylaşır; sunucu engellemez).
///
/// Eşleşme yalnız hasta kayıtlarında (taraf.hasta = 1); cari/personel aynı
/// kimliği taşıyabilir, hasta kartı onları açamaz. Telefon son 10 hane ile
/// karşılaştırılır (0 / +90 öneki fark yaratmaz), cep ve sabit hattın ikisine bakar.
/// </summary>
public static class HastaUclari
{
    /// <summary>Kimlik / telefon mükerrer kontrolü yapılan kartlar.</summary>
    private static readonly HashSet<string> HastaKartlari = ["hasta", "hasta-aday"];

    public sealed record MukerrerKayit(int Id, string Ad, string Kod, DateTime? DogumTarihi);
    public sealed record MukerrerYaniti(MukerrerKayit? Kimlik, IReadOnlyList<MukerrerKayit> Telefon);

    private const string KayitSecimi = """
        select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, ''), coalesce(t.kod, ''), h.dogum_tarihi
          from public.taraf t left join public.taraf_hasta h on h.id = t.id
         where t.hasta = 1 and (@p1::int is null or t.id <> @p1)
        """;

    public static void HastaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hasta").WithTags("Hasta").RequireAuthorization();

        grup.MapGet("/mukerrer", async (string? vkno, string? cepTel, int? haric, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hasta", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kimlik = await KimlikBulAsync(b, vkno, haric, iptal);
            var telefon = await TelefonBulAsync(b, cepTel, haric, iptal);
            return Results.Ok(new MukerrerYaniti(kimlik, telefon));
        });
    }

    /// <summary>
    /// Kart ucu (ekle / güncelle) için sert kural: aynı kimlik numaralı başka bir
    /// hasta varsa kayıt yazılmaz; hata kimlik alanını işaretler ve mevcut kaydı söyler.
    /// </summary>
    public static async Task KimlikMukerrerKuraliAsync(KartTanimi tanim, IDictionary<string, object?> degerler, VeriKaynagi veri, long? haricId, CancellationToken iptal)
    {
        if (!HastaKartlari.Contains(tanim.Ad)) return;
        if (!degerler.TryGetValue("vkno", out var v) || string.IsNullOrWhiteSpace(v?.ToString())) return;
        await using var b = await veri.AcAsync(iptal);
        var mevcut = await KimlikBulAsync(b, v!.ToString(), haricId is null ? null : (int)haricId, iptal);
        if (mevcut is null) return;
        throw GentegreHatasi.Dogrulama(
            $"Bu kimlik numarası ile kayıtlı hasta var: {mevcut.Ad} (dosya {mevcut.Kod}, #{mevcut.Id}). Yeni kayıt açılmaz, o kart kullanılır.",
            new AlanHatasi("vkno", $"Kayıtlı: {mevcut.Ad} (#{mevcut.Id})"));
    }

    private static async Task<MukerrerKayit?> KimlikBulAsync(NpgsqlConnection b, string? vkno, int? haric, CancellationToken iptal)
    {
        var kimlik = (vkno ?? "").Trim();
        if (kimlik == "") return null;
        return await b.TekAsync(KayitSecimi + " and t.vkno = @p0 order by t.id limit 1", null, [kimlik, haric], Oku, iptal);
    }

    private static async Task<IReadOnlyList<MukerrerKayit>> TelefonBulAsync(NpgsqlConnection b, string? tel, int? haric, CancellationToken iptal)
    {
        var anahtar = TelAnahtar(tel);
        if (anahtar.Length < 7) return [];
        return await b.ListeAsync(KayitSecimi + """
             and (right(regexp_replace(coalesce(t.cep_tel, ''), '\D', '', 'g'), 10) = @p0
               or right(regexp_replace(coalesce(t.telefon, ''), '\D', '', 'g'), 10) = @p0)
            order by t.id limit 5
            """, null, [anahtar, haric], Oku, iptal);
    }

    private static MukerrerKayit Oku(NpgsqlDataReader o)
        => new(o.GetInt32(0), o.GetString(1), o.GetString(2), o.IsDBNull(3) ? null : o.GetDateTime(3));

    /// <summary>Rakam dışı atılır, son 10 hane (fn_cagri_tel_anahtar ile aynı kural).</summary>
    private static string TelAnahtar(string? tel)
    {
        var d = new string((tel ?? "").Where(char.IsDigit).ToArray());
        return d.Length > 10 ? d[^10..] : d;
    }
}
