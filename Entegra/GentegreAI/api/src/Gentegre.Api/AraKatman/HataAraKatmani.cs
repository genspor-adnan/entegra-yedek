using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// API §1.2: her hata ayni govdeyi doner. Kullaniciya kod + izlemeNo gider;
/// mesaj/yigin yalniz hata_log'da kalir (SUNUCU hatasinda ic ayrinti SIZDIRILMAZ).
/// </summary>
public sealed class HataAraKatmani
{
    private readonly RequestDelegate _sonraki;
    private readonly ILogger<HataAraKatmani> _gunluk;

    public HataAraKatmani(RequestDelegate sonraki, ILogger<HataAraKatmani> gunluk)
    {
        _sonraki = sonraki;
        _gunluk = gunluk;
    }

    public async Task InvokeAsync(HttpContext ctx, GunlukDeposu gunlukDeposu)
    {
        var izlemeNo = Izleme.YeniNo();
        ctx.Items["izlemeNo"] = izlemeNo;
        ctx.Response.Headers["X-Izleme-No"] = izlemeNo;

        try
        {
            await _sonraki(ctx);
        }
        catch (Exception hata)
        {
            await YazAsync(ctx, hata, izlemeNo, gunlukDeposu);
        }
    }

    private async Task YazAsync(HttpContext ctx, Exception hata, string izlemeNo, GunlukDeposu depo)
    {
        var (kod, mesaj, govde) = Coz(hata, izlemeNo);
        var durum = HataKodu.HttpDurumu(kod);

        if (durum >= 500)
            _gunluk.LogError(hata, "Beklenmeyen hata {IzlemeNo} {Yol}", izlemeNo, ctx.Request.Path);
        else
            _gunluk.LogInformation("{Kod} {IzlemeNo} {Yol}: {Mesaj}", kod, izlemeNo, ctx.Request.Path, mesaj);

        await depo.HataYazAsync(
            izlemeNo, kod, durum, ctx.Request.Path, ctx.Request.Method, mesaj,
            durum >= 500 ? hata.ToString() : "", durum >= 500 ? (hata.StackTrace ?? "") : "",
            KullaniciId(ctx), null, Ip(ctx), null, ctx.RequestAborted);

        if (ctx.Response.HasStarted) return;

        ctx.Response.Clear();
        ctx.Response.StatusCode = durum;
        ctx.Response.ContentType = "application/json; charset=utf-8";
        await ctx.Response.WriteAsync(JsonSerializer.Serialize(govde, JsonAyarlari.Secenekler));
    }

    private static (string Kod, string Mesaj, HataYaniti Govde) Coz(Exception hata, string izlemeNo)
    {
        // Veritabani kisit ihlalleri kullaniciya anlamli mesaj olarak doner (500 degil).
        if (hata is PostgresException pg && VeriHatasi.Cevir(pg) is { } cevrilmis)
            hata = cevrilmis;

        if (hata is GentegreHatasi g)
        {
            return (g.Kod, g.Message, new HataYaniti
            {
                Hata = new HataGovdesi
                {
                    Kod = g.Kod,
                    Mesaj = g.Message,
                    IzlemeNo = izlemeNo,
                    Alanlar = g.Alanlar,
                    CakisanAlanlar = g.CakisanAlanlar,
                    GuncelDeger = g.GuncelDeger,
                    Engel = g.Engel
                }
            });
        }

        // Beklenmeyen: ic ayrinti kullaniciya GITMEZ, izleme no ile log'a bakilir.
        return (HataKodu.Sunucu, hata.Message, new HataYaniti
        {
            Hata = new HataGovdesi
            {
                Kod = HataKodu.Sunucu,
                Mesaj = "Beklenmeyen bir hata olustu. Destek icin izleme numarasini bildirin.",
                IzlemeNo = izlemeNo
            }
        });
    }

    private static int? KullaniciId(HttpContext ctx)
        => int.TryParse(ctx.User.FindFirst(Talep.KullaniciId)?.Value, out var i) ? i : null;

    private static string Ip(HttpContext ctx)
        => ctx.Connection.RemoteIpAddress?.ToString() ?? "";
}

public static class JsonAyarlari
{
    public static readonly JsonSerializerOptions Secenekler = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DictionaryKeyPolicy = null,          // satir anahtarlari katalogdaki adlar - DOKUNMA
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
    };
}
