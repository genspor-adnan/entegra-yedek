using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUMSAL KALİTE — GENEL AYARLAR (1069, mockup Ekranlar/Kalite2/ayarlar.html "Genel").
///
/// Dört ayar, referans anahtarlarında: DÖF varsayılan termini (gün), risk skoru
/// renk eşikleri (düşük / orta / yüksek üst sınırları), genel kalite sorumlusu
/// (personel) ve olay bildiriminde anonim seçeneği. Genel /api/ayar ucu "ayar"
/// yetkisi ister; bunlar kalite ekranının parçası, kys.ayar ile değişir.
/// OKUMA: kys.ayar ya da kys.olay - olay kartı anonim seçeneğini buradan okur.
/// Değişiklik alan alan loglanır; hiçbir şey değişmediyse log yok.
/// </summary>
public static class KysAyarUclari
{
    private const int LogKysAyar = 1403;

    public sealed record KysAyar(int DofTerminGun, int RiskDusuk, int RiskOrta, int RiskYuksek,
                                 int? GenelSorumluId, bool OlayAnonim);

    private static readonly string[] Anahtarlar =
    [
        "kys.dof_termin_gun", "kys.risk_esik_dusuk", "kys.risk_esik_orta", "kys.risk_esik_yuksek",
        "kys.genel_sorumlu_id", "kys.olay_anonim",
    ];

    public static void KysAyarUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kys-ayar").WithTags("Kurumsal Kalite").RequireAuthorization();

        grup.MapGet("/", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("kys.ayar", Islem.Gor) && !baglam.Yetkiler.Var("kys.olay", Islem.Gor))
                baglam.YetkiIste("kys.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var a = await OkuAsync(b, iptal);
            return Results.Ok(new
            {
                a.DofTerminGun, a.RiskDusuk, a.RiskOrta, a.RiskYuksek, a.GenelSorumluId, a.OlayAnonim,
                duzenle = baglam.Yetkiler.Var("kys.ayar", Islem.Degistir),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPut("/", async (KysAyar istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kys.ayar", Islem.Degistir);
            if (istek.DofTerminGun is < 1 or > 365)
                throw GentegreHatasi.Dogrulama("DÖF termini 1-365 gün olmalı.", new AlanHatasi("dofTerminGun", "1-365"));
            if (!(istek.RiskDusuk >= 1 && istek.RiskDusuk < istek.RiskOrta && istek.RiskOrta < istek.RiskYuksek && istek.RiskYuksek < 25))
                throw GentegreHatasi.Dogrulama("Eşikler artan olmalı: düşük < orta < yüksek < 25.",
                    new AlanHatasi("riskDusuk", "düşük < orta < yüksek < 25"));

            await using var b = await veri.AcAsync(iptal);
            if (istek.GenelSorumluId is { } sid && !await b.TekDegerAsync<bool>(
                    "select exists (select 1 from public.taraf where id = @p0 and personel = 1)", null, [sid], iptal))
                throw GentegreHatasi.Dogrulama("Genel kalite sorumlusu personel olmalı.", new AlanHatasi("genelSorumluId", "personel değil"));

            var eski = await OkuAsync(b, iptal);
            var yeni = new Dictionary<string, string>
            {
                ["kys.dof_termin_gun"] = istek.DofTerminGun.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["kys.risk_esik_dusuk"] = istek.RiskDusuk.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["kys.risk_esik_orta"] = istek.RiskOrta.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["kys.risk_esik_yuksek"] = istek.RiskYuksek.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ["kys.genel_sorumlu_id"] = istek.GenelSorumluId?.ToString(System.Globalization.CultureInfo.InvariantCulture) ?? "",
                ["kys.olay_anonim"] = istek.OlayAnonim ? "1" : "0",
            };
            var eskiHarita = Harita(eski);
            var fark = Anahtarlar.Where(k => eskiHarita[k] != yeni[k])
                                 .ToDictionary(k => k, k => (object)new { eski = eskiHarita[k], yeni = yeni[k] });
            if (fark.Count > 0)
            {
                await using var tx = await b.BeginTransactionAsync(iptal);
                foreach (var k in fark.Keys)
                    await b.CalistirAsync("""
                        insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
                        values (@p0, @p1, 'sayi', 'firma', @p2, now()::timestamp)
                        on conflict (anahtar) do update
                           set deger = excluded.deger, degistiren = excluded.degistiren,
                               degistirme_tarihi = excluded.degistirme_tarihi, guncelleme = now()::timestamp
                        """, tx, [k, yeni[k], baglam.KullaniciId], iptal);
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogKysAyar, 0,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark, iptal: iptal);
                await tx.CommitAsync(iptal);
            }
            var son = await OkuAsync(b, iptal);
            return Results.Ok(new
            {
                son.DofTerminGun, son.RiskDusuk, son.RiskOrta, son.RiskYuksek, son.GenelSorumluId, son.OlayAnonim,
                duzenle = true, izlemeNo = baglam.IzlemeNo,
            });
        });
    }

    private static Dictionary<string, string> Harita(KysAyar a) => new()
    {
        ["kys.dof_termin_gun"] = a.DofTerminGun.ToString(System.Globalization.CultureInfo.InvariantCulture),
        ["kys.risk_esik_dusuk"] = a.RiskDusuk.ToString(System.Globalization.CultureInfo.InvariantCulture),
        ["kys.risk_esik_orta"] = a.RiskOrta.ToString(System.Globalization.CultureInfo.InvariantCulture),
        ["kys.risk_esik_yuksek"] = a.RiskYuksek.ToString(System.Globalization.CultureInfo.InvariantCulture),
        ["kys.genel_sorumlu_id"] = a.GenelSorumluId?.ToString(System.Globalization.CultureInfo.InvariantCulture) ?? "",
        ["kys.olay_anonim"] = a.OlayAnonim ? "1" : "0",
    };

    private static async Task<KysAyar> OkuAsync(Npgsql.NpgsqlConnection b, CancellationToken iptal)
    {
        var d = new Dictionary<string, string>();
        await using (var komut = b.Komut("select anahtar, deger from public.referans where anahtar = any(@p0)", null,
                                         (object?)Anahtarlar))
        await using (var o = await komut.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) d[o.GetString(0)] = o.GetString(1);
        int Sayi(string k, int v) => d.TryGetValue(k, out var s) && int.TryParse(s, out var n) ? n : v;
        return new KysAyar(
            Sayi("kys.dof_termin_gun", 30), Sayi("kys.risk_esik_dusuk", 4), Sayi("kys.risk_esik_orta", 9),
            Sayi("kys.risk_esik_yuksek", 14),
            d.TryGetValue("kys.genel_sorumlu_id", out var g) && int.TryParse(g, out var gi) ? gi : null,
            !d.TryGetValue("kys.olay_anonim", out var an) || an != "0");
    }
}
