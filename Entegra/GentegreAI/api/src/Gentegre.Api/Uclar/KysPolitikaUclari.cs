using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUMSAL KALİTE — POLİTİKA &amp; KAPSAM (1059, mockup Ekranlar/Kalite2/hedefler.html).
///
/// ISO 9001 4.3 / 5.2: politika ve kapsam TEK METİN, kayıt değil - dört
/// referans anahtarı (kys.politika, kys.kapsam, kys.politika_onaylayan,
/// kys.politika_tarih). Genel /api/ayar ucu kullanılmadı: o uç metin ayarları
/// BÜYÜK HARFE çevirir (seri / kod ayarları için) ve "ayar" yetkisi ister;
/// politika "Politika &amp; Hedefler" ekranının parçası, kys.gosterge ile
/// okunur / değiştirilir.
/// </summary>
public static class KysPolitikaUclari
{
    private const int LogKysPolitika = 1490;

    private static readonly (string Anahtar, string Alan, int EnFazla)[] Alanlar =
    [
        ("kys.politika",           "politika",   4000),
        ("kys.kapsam",             "kapsam",     2000),
        ("kys.politika_onaylayan", "onaylayan",  120),
        ("kys.politika_tarih",     "tarih",      40),
        ("kys.politika_yayin",     "yayin",      200),   // 1063, mockup "Yayın"
    ];

    public sealed record KysPolitika(string Politika, string Kapsam, string Onaylayan, string Tarih, string? Yayin = null);

    public static void KysPolitikaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kys-politika").WithTags("Kurumsal Kalite").RequireAuthorization();

        grup.MapGet("/", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.gosterge", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var d = await OkuAsync(baglanti, iptal);
            return Results.Ok(new
            {
                politika = d.Politika, kapsam = d.Kapsam, onaylayan = d.Onaylayan, tarih = d.Tarih, yayin = d.Yayin ?? "",
                duzenle = baglam.Yetkiler.Var("kys.gosterge", Islem.Degistir),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPut("/", async (KysPolitika istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.gosterge", Islem.Degistir);

            var yeni = new Dictionary<string, string>
            {
                ["kys.politika"] = (istek?.Politika ?? "").Trim(),
                ["kys.kapsam"] = (istek?.Kapsam ?? "").Trim(),
                ["kys.politika_onaylayan"] = (istek?.Onaylayan ?? "").Trim(),
                ["kys.politika_tarih"] = (istek?.Tarih ?? "").Trim(),
                ["kys.politika_yayin"] = (istek?.Yayin ?? "").Trim(),
            };
            foreach (var (anahtar, alan, enFazla) in Alanlar)
                if (yeni[anahtar].Length > enFazla)
                    throw GentegreHatasi.Dogrulama($"En fazla {enFazla} karakter olabilir.",
                        new AlanHatasi(alan, $"En fazla {enFazla} karakter."));

            await using var baglanti = await veri.AcAsync(iptal);
            var eski = await OkuAsync(baglanti, iptal);
            var eskiHarita = new Dictionary<string, string>
            {
                ["kys.politika"] = eski.Politika, ["kys.kapsam"] = eski.Kapsam,
                ["kys.politika_onaylayan"] = eski.Onaylayan, ["kys.politika_tarih"] = eski.Tarih,
                ["kys.politika_yayin"] = eski.Yayin ?? "",
            };

            // Değişiklik logu alan alan; hiçbir şey değişmediyse satır yok (ULog kuralı).
            var fark = Alanlar.Where(a => eskiHarita[a.Anahtar] != yeni[a.Anahtar])
                              .ToDictionary(a => a.Alan, a => (object)new { eski = eskiHarita[a.Anahtar], yeni = yeni[a.Anahtar] });
            if (fark.Count > 0)
            {
                await using var islem = await baglanti.BeginTransactionAsync(iptal);
                foreach (var (anahtar, _, _) in Alanlar)
                    await baglanti.CalistirAsync("""
                        insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
                        values (@p0, @p1, 'metin', 'firma', @p2, now()::timestamp)
                        on conflict (anahtar) do update
                           set deger = excluded.deger, degistiren = excluded.degistiren,
                               degistirme_tarihi = excluded.degistirme_tarihi, guncelleme = now()::timestamp
                        """, islem, [anahtar, yeni[anahtar], baglam.KullaniciId], iptal);
                await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogKysPolitika, 0,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark, iptal: iptal);
                await islem.CommitAsync(iptal);
            }

            return Results.Ok(new
            {
                politika = yeni["kys.politika"], kapsam = yeni["kys.kapsam"],
                onaylayan = yeni["kys.politika_onaylayan"], tarih = yeni["kys.politika_tarih"], yayin = yeni["kys.politika_yayin"],
                duzenle = true, izlemeNo = baglam.IzlemeNo,
            });
        });
    }

    private static async Task<KysPolitika> OkuAsync(Npgsql.NpgsqlConnection baglanti, CancellationToken iptal)
    {
        var d = new Dictionary<string, string>();
        await using (var komut = baglanti.Komut(
            "select anahtar, deger from public.referans where anahtar = any(@p0)", null,
            (object?)Alanlar.Select(a => a.Anahtar).ToArray()))
        await using (var o = await komut.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) d[o.GetString(0)] = o.GetString(1);
        string Al(string k) => d.TryGetValue(k, out var v) ? v : "";
        return new KysPolitika(Al("kys.politika"), Al("kys.kapsam"), Al("kys.politika_onaylayan"), Al("kys.politika_tarih"), Al("kys.politika_yayin"));
    }
}
