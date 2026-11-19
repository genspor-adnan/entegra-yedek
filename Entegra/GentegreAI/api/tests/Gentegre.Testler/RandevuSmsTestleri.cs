using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Veri.Depolar;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// RANDEVU SMS (1382, kullanıcı 19.11.2026: "randevu kartına SMS Gönder Check ekle.. şubeye özgü olsun mesaj.. istersek
/// mesajı değiştirebilelim.. 1 gün kala hatırlatma mesajı göndereceğiz opsiyonel olarak").
/// Bilgi SMS'i şube metniyle ve ŞUBE YEREL saatiyle gider, aynı saate ikinci kez gitmez, saat değişince yeniden gider,
/// kartta değiştirilen metin bir kez kullanılır; hatırlatma şube ayarıyla N saat önceye planlanır, her kayıtta tazelenir,
/// kartta kaldırılınca konmaz. Önizleme ucu aynı metni üretir.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RandevuSmsTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Bilgi_ve_hatirlatma_sube_metniyle_kuyruga_girer()
    {
        await using var d = new TestDunyasi(api.Veri);
        // Şube ayarı: önceki hâl geri yazılır.
        var onceki = await api.Veri.TekDegerAsync<string>(
            "select row_to_json(a)::text from public.randevu_sms_ayar a where sube_id = @p0", [Merkez]);
        d.Temizle(onceki is null
            ? $"delete from public.randevu_sms_ayar where sube_id = {Merkez}"
            : $"delete from public.randevu_sms_ayar where sube_id = {Merkez}; insert into public.randevu_sms_ayar select * from json_populate_record(null::public.randevu_sms_ayar, '{onceki.Replace("'", "''")}'::json)");
        await api.Veri.CalistirAsync("""
            insert into public.randevu_sms_ayar (sube_id, bilgi_sablon, hatirlatma_acik, hatirlatma_saat, hatirlatma_sablon)
            values (@p0, 'Bilgi {hasta} {tarih} {saat}', 1, 24, 'Hatirlat {hasta} {saat}')
            on conflict (sube_id) do update set bilgi_sablon = excluded.bilgi_sablon, hatirlatma_acik = 1, hatirlatma_saat = 24,
                   hatirlatma_sablon = excluded.hatirlatma_sablon
            """, [Merkez]);
        var dilim = await api.Veri.TekDegerAsync<string>("select coalesce(nullif(zaman_dilimi, ''), 'Europe/Istanbul') from public.sube where id = @p0", [Merkez]) ?? "Europe/Istanbul";
        var tz = TimeZoneInfo.FindSystemTimeZoneById(dilim);

        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id, cep_tel) values (@p0, 1, @p1, '05551112233') returning id",
            [d.Onek + " Hasta", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        d.Temizle($"delete from public.bildirim where kaynak_tur = 4 and kaynak_id in (select id from public.randevu where hasta_id = {hasta})");
        d.Temizle($"delete from public.randevu where hasta_id = {hasta}");

        // KART UCUNDAN (RandevuKendiIstegiTestleri deseni): aktif bölüm / hekim, uzak gelecek; saat ŞUBE yerel saati.
        var rol = await d.RolAsync("rsms", "randevu:ged");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);
        var bolum = await api.Veri.TekDegerAsync<int>("select coalesce(min(id), 0) from public.v_randevu_bolum_lookup where aktif = 1", null);
        var hekim = await api.Veri.TekDegerAsync<int>("select coalesce(min(id), 0) from public.v_hekim_lookup where aktif = 1", null);
        Assert.True(bolum > 0 && hekim > 0, "test DB'de aktif bölüm / hekim yok");
        var yerel = DateTime.UtcNow.Date.AddDays(403).AddHours(10);              // 10:00 şube saati
        var utc = TimeZoneInfo.ConvertTimeToUtc(DateTime.SpecifyKind(yerel, DateTimeKind.Unspecified), tz);
        var yk = await h.PostAsJsonAsync("/api/kart/randevu", new { kart = new
            { hastaId = hasta, baslangic = yerel.ToString("yyyy-MM-ddTHH:mm:ss"), sureDk = 15, durum = 1, tip = 3, kaynak = 1,
              bolum, hekimId = hekim, smsGonder = true, smsHatirlatma = true } });
        var yj = await yk.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(yk.IsSuccessStatusCode, yj.ToString());
        var rid = (int)yj.GetProperty("kart").GetProperty("id").GetInt64();

        var sms = new RandevuHatirlatmasi(api.Veri, new BildirimDeposu(api.Veri), NullLogger<RandevuHatirlatmasi>.Instance);
        Task Tazele() => sms.TazeleAsync(rid, 0, CancellationToken.None);
        Task<int> Say(string kod, string? durumlar = null) => api.Veri.TekDegerAsync<int>($"""
            select count(*)::int from public.bildirim b join public.bildirim_sablon s on s.id = b.sablon_id
             where b.kaynak_tur = 4 and b.kaynak_id = @p0 and s.kod = @p1 {(durumlar is null ? "" : $"and b.durum in ({durumlar})")}
            """, [rid, kod]);
        Task<string> SonGovde(string kod) => api.Veri.TekDegerAsync<string>("""
            select b.govde from public.bildirim b join public.bildirim_sablon s on s.id = b.sablon_id
             where b.kaynak_tur = 4 and b.kaynak_id = @p0 and s.kod = @p1 order by b.id desc limit 1
            """, [rid, kod])!;
        var ad = d.Onek + " Hasta";

        // 1) Kart kaydı (KartUclari -> TazeleAsync): bilgi (yerel saat) + hatırlatma (24 saat önce).
        Assert.Equal($"Bilgi {ad} {yerel:dd.MM.yyyy} 10:00", await SonGovde("randevu.bilgi"));
        Assert.Equal($"Hatirlat {ad} 10:00", await SonGovde("randevu.hatirlatma_sube"));
        Assert.Equal(utc.AddHours(-24), await api.Veri.TekDegerAsync<DateTime>("""
            select b.planlanan from public.bildirim b join public.bildirim_sablon s on s.id = b.sablon_id
             where b.kaynak_id = @p0 and b.kaynak_tur = 4 and s.kod = 'randevu.hatirlatma_sube' order by b.id desc limit 1
            """, [rid]));

        // 2) Aynı saatle yeniden kayıt: bilgi ikinci kez gitmez; hatırlatma tazelenir (eski iptal, tek bekleyen).
        await Tazele();
        Assert.Equal(1, await Say("randevu.bilgi"));
        Assert.Equal(1, await Say("randevu.hatirlatma_sube", "1, 4"));

        // 3) Saat değişti + kartta elle metin: yeni bilgi elle metinle, metin sonra temizlenir.
        await api.Veri.CalistirAsync("update public.randevu set baslangic = baslangic + interval '1 hour', sms_metni = 'Elle yazilan' where id = @p0", [rid]);
        await Tazele();
        Assert.Equal(2, await Say("randevu.bilgi"));
        Assert.Equal("Elle yazilan", await SonGovde("randevu.bilgi"));
        Assert.Equal("", await api.Veri.TekDegerAsync<string>("select sms_metni from public.randevu where id = @p0", [rid]));
        Assert.Equal($"Hatirlat {ad} 11:00", await SonGovde("randevu.hatirlatma_sube"));

        // 4) Hatırlatma kartta kaldırıldı: bekleyen hatırlatma kalmaz.
        await api.Veri.CalistirAsync("update public.randevu set sms_hatirlatma = 0 where id = @p0", [rid]);
        await Tazele();
        Assert.Equal(0, await Say("randevu.hatirlatma_sube", "1, 4"));

        // 5) Önizleme ucu aynı metni üretir (kartın kaydedilmemiş saatiyle, şube yerel saati).
        var y = await h.PostAsJsonAsync("/api/randevu/sms-onizleme",
            new { randevuId = (int?)null, hastaId = hasta, baslangic = yerel.ToString("yyyy-MM-ddT10:00"), bolum, hekimId = hekim });
        var j = await y.Content.ReadFromJsonAsync<JsonElement>();
        Assert.True(y.IsSuccessStatusCode, j.ToString());
        Assert.Equal($"Bilgi {ad} {yerel:dd.MM.yyyy} 10:00", j.GetProperty("bilgi").GetString());
        Assert.True(j.GetProperty("telefonVar").GetBoolean());
        Assert.True(j.GetProperty("hatirlatmaAcik").GetBoolean());
    }
}
