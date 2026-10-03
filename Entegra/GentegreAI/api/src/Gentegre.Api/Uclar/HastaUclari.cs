using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TARAF (hasta / personel) MÜKERRER KONTROLÜ. Kullanıcı kuralı:
///   * KİMLİK NO = ENGEL: aynı kimlik no ile AKTİF kayıt varsa yeni kayıt
///     AÇILMAZ; kullanıcıya "mevcut karta geçilsin mi" sorulur. Diğer kayıt
///     PASİF ise aynı kimlik no ile yeni kayıt eklenebilir.
///   * TELEFON = UYARI · E-POSTA = UYARI: aynı olan aktif kayıt varsa uyarılır;
///     kullanıcı "evet" derse aynı telefon/e-posta ile kayıt eklenebilir
///     (aile bireyleri aynı numarayı/adresi paylaşır).
///
///   GET /api/hasta/mukerrer?rol=hasta|personel&amp;vkno=&amp;cepTel=&amp;eposta=&amp;haric=
///
/// Kimlik engeli sunucuda da uygulanır (<see cref="KimlikMukerrerKuraliAsync"/>):
/// ekran atlasa bile kart ucu aynı kimlikli AKTİF kaydı reddeder. Eşleşme rol
/// içinde kalır (hasta hastayla, personel personelle); cari/hasta/personel aynı
/// kimliği taşıyabilir. Telefon/e-posta son 10 hane / küçük harf ile karşılaştırılır.
/// </summary>
public static class HastaUclari
{
    // Kart adı -> taraf rol kolonu (mükerrer bu rol içinde aranır).
    private static string? RolKolonu(string kartAd) => kartAd switch
    {
        "hasta" or "hasta-aday" => "hasta",
        "personel" or "dis-hekim" => "personel",
        _ => null,
    };
    private static string? RolAdi(string rolKolonu) => rolKolonu switch
    {
        "hasta" => "hasta", "personel" => "personel", _ => null,
    };

    public sealed record MukerrerKayit(int Id, string Ad, string Kod, DateTime? DogumTarihi);
    public sealed record MukerrerYaniti(MukerrerKayit? Kimlik, IReadOnlyList<MukerrerKayit> Telefon,
                                        IReadOnlyList<MukerrerKayit> Eposta);

    // AKTİF kayıtlar (durum = 1): pasif kayıt ne engeller ne uyarır.
    private static string KayitSecimi(string rolKol) => $"""
        select t.id, coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(t.kod, ''), h.dogum_tarihi
          from public.taraf t left join public.taraf_hasta h on h.id = t.id
         where t.{rolKol} = 1 and coalesce(t.durum, 0) = 1 and (@p1::int is null or t.id <> @p1)
        """;

    public static void HastaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hasta").WithTags("Hasta").RequireAuthorization();

        grup.MapGet("/mukerrer", async (string? rol, string? vkno, string? cepTel, string? eposta,
            int? haric, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var rolKol = (rol == "personel") ? "personel" : "hasta";
            baglam.YetkiIste(rolKol == "personel" ? "personel" : "hasta", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kimlik = await KimlikBulAsync(b, rolKol, vkno, haric, iptal);
            var telefon = await TelefonBulAsync(b, rolKol, cepTel, haric, iptal);
            var epostaL = await EpostaBulAsync(b, rolKol, eposta, haric, iptal);
            return Results.Ok(new MukerrerYaniti(kimlik, telefon, epostaL));
        });
    }

    /// <summary>
    /// Kart ucu (ekle / güncelle) SERT KURALI: aynı kimlik numaralı başka bir
    /// AKTİF hasta/personel varsa kayıt yazılmaz. Pasif kayıt engellemez.
    /// </summary>
    public static async Task KimlikMukerrerKuraliAsync(KartTanimi tanim, IDictionary<string, object?> degerler, VeriKaynagi veri, long? haricId, CancellationToken iptal)
    {
        var rolKol = RolKolonu(tanim.Ad);
        if (rolKol is null) return;
        if (!degerler.TryGetValue("vkno", out var v) || string.IsNullOrWhiteSpace(v?.ToString())) return;
        await using var b = await veri.AcAsync(iptal);
        var mevcut = await KimlikBulAsync(b, rolKol, v!.ToString(), haricId is null ? null : (int)haricId, iptal);
        if (mevcut is null) return;
        var ad = RolAdi(rolKol) == "personel" ? "personel" : "hasta";
        throw GentegreHatasi.Dogrulama(
            $"Bu kimlik numarası ile kayıtlı AKTİF {ad} var: {mevcut.Ad} (dosya {mevcut.Kod}, #{mevcut.Id}). "
            + "Yeni kayıt açılmaz - mevcut karta geçin. (Diğer kayıt pasifse aynı kimlikle eklenebilir.)",
            new AlanHatasi("vkno", $"Kayıtlı: {mevcut.Ad} (#{mevcut.Id})"));
    }

    private static async Task<MukerrerKayit?> KimlikBulAsync(NpgsqlConnection b, string rolKol, string? vkno, int? haric, CancellationToken iptal)
    {
        var kimlik = (vkno ?? "").Trim();
        if (kimlik == "") return null;
        return await b.TekAsync(KayitSecimi(rolKol) + " and t.vkno = @p0 order by t.id limit 1", null, [kimlik, haric], Oku, iptal);
    }

    private static async Task<IReadOnlyList<MukerrerKayit>> TelefonBulAsync(NpgsqlConnection b, string rolKol, string? tel, int? haric, CancellationToken iptal)
    {
        var anahtar = TelAnahtar(tel);
        if (anahtar.Length < 7) return [];
        return await b.ListeAsync(KayitSecimi(rolKol) + """
             and (right(regexp_replace(coalesce(t.cep_tel, ''), '\D', '', 'g'), 10) = @p0
               or right(regexp_replace(coalesce(t.telefon, ''), '\D', '', 'g'), 10) = @p0)
            order by t.id limit 5
            """, null, [anahtar, haric], Oku, iptal);
    }

    private static async Task<IReadOnlyList<MukerrerKayit>> EpostaBulAsync(NpgsqlConnection b, string rolKol, string? eposta, int? haric, CancellationToken iptal)
    {
        var e = (eposta ?? "").Trim().ToLowerInvariant();
        if (e.Length < 5 || !e.Contains('@')) return [];
        return await b.ListeAsync(KayitSecimi(rolKol) + " and lower(trim(coalesce(t.eposta, ''))) = @p0 order by t.id limit 5",
            null, [e, haric], Oku, iptal);
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
