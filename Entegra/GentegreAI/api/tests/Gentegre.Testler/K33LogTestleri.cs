using System.Net;

namespace Gentegre.Testler;

/// <summary>
/// KOD İNCELEME RAPORU 30.10.2026 — K33: silme logu <c>DELETE</c>'ten ÖNCE, silinen satırın TAM
/// hâliyle (yalnız kimlik değil) ve silme ile AYNI transaction'da yazılır (Delphi ULog kuralı,
/// "Geri Al" bunu okur). Burada üç özel uç sınanır: laboratuvar istemi (961, tetkik satırları
/// <c>__detaylar</c> altında), radyoloji istemi (940) ve diş seansının işlem satırı (1133 → üst 1132).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class K33LogTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private const int LogLabIstem = 961, LogRadyolojiIstem = 940, LogDisSeans = 1132, LogDisSeansIslem = 1133;

    private async Task<int> HastaAsync(TestDunyasi d)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, hasta, sube_id) values (@p0, 1, @p1) returning id",
            [d.Onek + " hasta " + Guid.NewGuid().ToString("N")[..4], Merkez]);
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private async Task<int> HizmetAsync(TestDunyasi d, bool radyoloji)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) values (@p0, @p1, @p2, @p3, @p4) returning id",
            [d.Onek.ToUpperInvariant() + Guid.NewGuid().ToString("N")[..4], d.Onek + " hizmet",
             (short)(radyoloji ? 1 : 0), radyoloji ? (short)1 : null, Merkez]);
        d.Temizle($"delete from public.hizmet where id = {id}");
        return id;
    }

    /// <summary>Verilen yetkilerle Merkez'de çalışan, yazma hakkı olan kullanıcı.</summary>
    private async Task<HttpClient> IstemciAsync(TestDunyasi d, params string[] yetkiler)
    {
        var rol = await d.RolAsync("k33", yetkiler);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private Task<int> LogSayisiAsync(int tabloId, long kayitId, string ekKosul = "")
        => api.Veri.TekDegerAsync<int>($"""
            select count(*)::int from public.islem_log
             where tablo_id = @p0 and kayit_id = @p1 and islem_tipi = 0 and bilgi is not null {ekKosul}
            """, [tabloId, kayitId]);

    [VtFact]
    public async Task Lab_istemi_silinirken_tam_satir_ve_tetkikler_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var tetkik = await api.Veri.TekDegerAsync<int>(
            "insert into public.lab_tetkik (kod, ad) values (@p0, @p1) returning id",
            [d.Onek.ToUpperInvariant(), d.Onek + " tetkik"]);
        d.Temizle($"delete from public.lab_tetkik where id = {tetkik}");
        var istemNo = d.Onek + "-" + Guid.NewGuid().ToString("N")[..6];
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, @p1, @p2, 1, 1, 3, 1) returning id
            """, [hasta, Merkez, istemNo]);
        var satir = await api.Veri.TekDegerAsync<int>(
            "insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira) values (@p0, @p1, 1, 10) returning id",
            [istem, tetkik]);
        d.Temizle($"delete from public.islem_log where tablo_id = {LogLabIstem} and kayit_id = {istem}");
        d.Temizle($"delete from public.lab_istem_satir where istem_id = {istem}");
        d.Temizle($"delete from public.lab_istem where id = {istem}");
        using var h = await IstemciAsync(d, "lab:gk", "hasta:g");

        var y = await h.DeleteAsync($"/api/lab/istem/{istem}");
        Assert.True(y.StatusCode == HttpStatusCode.OK, await y.Content.ReadAsStringAsync());
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.lab_istem where id = @p0", [istem]));

        // Silme logu: tam satır (istem_no, taraf_id) + tetkik satırları __detaylar altında; taraf_id hastaya bağlı.
        Assert.Equal(1, await LogSayisiAsync(LogLabIstem, istem, $"""
            and bilgi ->> 'istem_no' = '{istemNo}'
            and (bilgi ->> 'taraf_id')::int = {hasta}
            and taraf_id = {hasta}
            and jsonb_array_length(bilgi -> '__detaylar' -> 'tetkikler') = 1
            and (bilgi -> '__detaylar' -> 'tetkikler' -> 0 ->> 'id')::int = {satir}
            """));
    }

    [VtFact]
    public async Task Radyoloji_istemi_silinirken_tam_satir_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var hizmet = await HizmetAsync(d, radyoloji: true);
        var accession = Guid.NewGuid().ToString("N")[..12];
        var istem = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum)
            values (@p0, @p1, @p2, 1, @p3, 1) returning id
            """, [Merkez, hasta, hizmet, accession]);
        d.Temizle($"delete from public.islem_log where tablo_id = {LogRadyolojiIstem} and kayit_id = {istem}");
        d.Temizle($"delete from public.radyoloji_istem where id = {istem}");
        using var h = await IstemciAsync(d, "radyoloji:gk", "hasta:g");

        var y = await h.DeleteAsync($"/api/radyoloji/istem/{istem}");
        Assert.True(y.StatusCode == HttpStatusCode.OK, await y.Content.ReadAsStringAsync());
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.radyoloji_istem where id = @p0", [istem]));

        Assert.Equal(1, await LogSayisiAsync(LogRadyolojiIstem, istem, $"""
            and bilgi ->> 'accession_no' = '{accession}'
            and (bilgi ->> 'hizmet_id')::int = {hizmet}
            and taraf_id = {hasta}
            """));
    }

    [VtFact]
    public async Task Dis_seans_islemi_silinirken_tam_satir_ust_seansa_bagli_loglanir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var hasta = await HastaAsync(d);
        var hizmet = await HizmetAsync(d, radyoloji: false);
        var seans = await api.Veri.TekDegerAsync<int>(
            "insert into public.dis_seans (sube_id, hasta_id, durum) values (@p0, @p1, 1) returning id",
            [Merkez, hasta]);
        var islem = await api.Veri.TekDegerAsync<int>("""
            insert into public.dis_seans_islem (seans_id, hizmet_id, dis_no, yuzeyler, sube_id)
            values (@p0, @p1, 36, 'O', @p2) returning id
            """, [seans, hizmet, Merkez]);
        d.Temizle($"delete from public.islem_log where tablo_id in ({LogDisSeans}, {LogDisSeansIslem}) and (kayit_id in ({seans}, {islem}) or ust_kayit_id = {seans})");
        d.Temizle($"delete from public.dis_seans where id = {seans}");
        using var h = await IstemciAsync(d, "dis.seans:gd", "hasta:g");

        var y = await h.DeleteAsync($"/api/dis/seans/islem/{islem}");
        Assert.True(y.StatusCode == HttpStatusCode.NoContent, await y.Content.ReadAsStringAsync());
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>(
            "select count(*)::int from public.dis_seans_islem where id = @p0", [islem]));

        // Detay satırı kendi log satırını alır, ust_tablo_id / ust_kayit_id ile seansa bağlanır.
        Assert.Equal(1, await LogSayisiAsync(LogDisSeansIslem, islem, $"""
            and ust_tablo_id = {LogDisSeans} and ust_kayit_id = {seans}
            and (bilgi ->> 'hizmet_id')::int = {hizmet}
            and bilgi ->> 'dis_no' = '36' and bilgi ->> 'yuzeyler' = 'O'
            and taraf_id = {hasta}
            """));
    }
}
