using System.Net;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K69: "bugün" sayan uçlar sabit <c>'Europe/Istanbul'</c> yerine ŞUBENİN saat
/// dilimini (<c>sube.zaman_dilimi</c> → <c>fn_sube_zaman_dilimi</c>, 1097) kullanmalı. Dilimi geçici olarak New York
/// yapılan şubede, New York gece yarısından bir dakika ÖNCE alınan paket İstanbul gününe göre çoğu saatte "bugün"dür
/// ama şubeye göre "dün"dür - Aktarım Durumu'nun "bugün" kutusu onu saymamalı.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K69SaatDilimiTestleri(ApiSunucuOlgusu api)
{
    /// <summary>Dilimi geçici değiştirilen şube: Merkez (1) değil, diğer testlerin "bugün"ü etkilenmesin.</summary>
    private const int Ankara = 3;
    private const string NewYork = "America/New_York";
    private const string Istanbul = "Europe/Istanbul";

    /// <summary>Verilen dilimde günün başlangıcı (UTC an); <paramref name="p"/> dilim adını taşıyan parametre.</summary>
    private static string GunBasi(string p) => $"date_trunc('day', now() at time zone {p}) at time zone {p}";
    private static readonly string GunBasiSql = GunBasi("@p1");

    [VtFact]
    public async Task Aktarim_durumu_bugunu_subenin_saat_diliminde_sayar()
    {
        await using var d = new TestDunyasi(api.Veri);

        // Şubenin dilimi geçici olarak New York; test sonunda eski değer geri yazılır.
        var eskiDilim = await api.Veri.TekDegerAsync<string>(
            "select zaman_dilimi from public.sube where id = @p0", [Ankara]) ?? Istanbul;
        d.Temizle($"update public.sube set zaman_dilimi = '{eskiDilim.Replace("'", "''")}' where id = {Ankara}");
        await api.Veri.CalistirAsync("update public.sube set zaman_dilimi = @p1 where id = @p0", [Ankara, NewYork]);

        var ajan = await api.Veri.TekDegerAsync<int>(
            "insert into public.aktarim_ajan (ad, anahtar_ozet) values (@p0, @p1) returning id",
            [d.Onek + " ajan", (d.Onek + Guid.NewGuid().ToString("N") + Guid.NewGuid().ToString("N"))[..64]]);
        try
        {
            // New York gününün başlangıcı (UTC an): bir paket hemen SONRA (şubeye göre bugün), biri hemen ÖNCE (dün).
            var eklenen = await api.Veri.CalistirAsync($$"""
                insert into public.aktarim_paket (ajan_id, paket_no, alinma, sure_ms, durum, ozet)
                select @p0, 'k69-sonra', g + interval '1 minute', 10, 1, '{}'::jsonb from (select {{GunBasiSql}} as g) x
                union all
                select @p0, 'k69-once',  g - interval '1 minute', 10, 1, '{}'::jsonb from (select {{GunBasiSql}} as g) x
                """, [ajan, NewYork]);
            Assert.Equal(2, eklenen);

            // Kendi paketlerimiz: şube diliminde 1, İstanbul diliminde 1 DEĞİL (gündüz 2, 21:00-04:00 UTC arası 0) -
            //   yani dilim seçimi sonucu değiştiriyor; test bu sayede anlamlı.
            var kendiNy = await api.Veri.TekDegerAsync<long>(
                $"select count(*) from public.aktarim_paket where ajan_id = @p0 and alinma >= {GunBasiSql}", [ajan, NewYork]);
            var kendiIst = await api.Veri.TekDegerAsync<long>(
                $"select count(*) from public.aktarim_paket where ajan_id = @p0 and alinma >= {GunBasiSql}", [ajan, Istanbul]);
            Assert.Equal(1, kendiNy);
            Assert.NotEqual(1, kendiIst);

            // Uç tabloyu şube süzgeci olmadan sayar: beklenen, aynı dilimle hesaplanan toplam.
            var beklenen = await api.Veri.TekDegerAsync<long>(
                $"select count(*) from public.aktarim_paket where alinma >= {GunBasi("@p0")}", [NewYork]);

            var rol = await d.RolAsync("aktarim", "aktarim.durum:g");
            var (kullanici, kod) = await d.KullaniciAsync(rol, Ankara);
            await d.SubeVerAsync(kullanici, Ankara, yazma: false, varsayilan: true);
            var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
            using var h = api.Istemci(access, Ankara);

            var y = await h.GetAsync("/api/aktarim-yonetim/durum");
            Assert.Equal(HttpStatusCode.OK, y.StatusCode);
            using var govde = JsonDocument.Parse(await y.Content.ReadAsStringAsync());
            var paket = govde.RootElement.GetProperty("bugun").GetProperty("paket").GetInt64();
            Assert.Equal(beklenen, paket);
        }
        finally
        {
            // Ajan fikstürü açıkça temizlenir (AktarimPaketTestleri ile aynı sıra); hata gizlenmez.
            await api.Veri.CalistirAsync("delete from public.aktarim_paket where ajan_id = @p0", [ajan]);
            await api.Veri.CalistirAsync("delete from public.aktarim_ajan where id = @p0", [ajan]);
        }
    }
}
