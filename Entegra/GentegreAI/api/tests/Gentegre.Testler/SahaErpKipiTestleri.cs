using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// SAHA ZİYARETİ İKİ KİP (1297; kullanıcı 11.11.2026: "hbys de dış doktorlar, erp de ise müşteriler ziyaret edilir..
/// başlıkları vb buna göre düzenle"): ERP kurulumunda ziyaret / talep listelerinin ve kartlarının "Dış Doktor" başlığı
/// "Müşteri" olur; ziyaret edilen taraf araması (saha-hedef) ERP'de müşteriyi, HBYS'de dış doktoru getirir.
/// Kip test DB'de geçici değiştirilir (kurum_profil.urun_modu), sonunda geri yazılır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class SahaErpKipiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<List<(int Sube, short? Mod)>> KipYazAsync(short kip)
    {
        var eski = await api.Veri.ListeAsync("select sube_id, urun_modu from public.kurum_profil where sube_id in (0, @p0)",
            new object?[] { Merkez }, o => (o.GetInt32(0), o.IsDBNull(1) ? (short?)null : o.GetInt16(1)));
        await api.Veri.CalistirAsync("update public.kurum_profil set urun_modu = @p0 where sube_id in (0, @p1)", [kip, Merkez]);
        return eski;
    }

    private async Task KipGeriAsync(List<(int Sube, short? Mod)> eski)
    {
        foreach (var (sube, mod) in eski)
            await api.Veri.CalistirAsync("update public.kurum_profil set urun_modu = @p0 where sube_id = @p1", [mod, sube]);
    }

    private static async Task<JsonElement> JsonAsync(HttpResponseMessage y)
    {
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        return JsonDocument.Parse(govde).RootElement.Clone();
    }

    private static async Task<string?> BaslikAsync(HttpClient h, string yol, string kume, string ad)
    {
        var j = await JsonAsync(await h.GetAsync(yol));
        return j.GetProperty(kume).EnumerateArray().First(a => a.GetProperty("ad").GetString() == ad).GetProperty("baslik").GetString();
    }

    private static async Task<int> SahaHedefSayisiAsync(HttpClient h, string kod)
    {
        var j = await JsonAsync(await h.PostAsJsonAsync("/api/liste/saha-hedef",
            new { sayfa = 1, boyut = 50, filtre = new { alan = "kod", op = "esit", deger = kod } }));
        return j.GetProperty("satirlar").GetArrayLength();
    }

    [VtFact]
    public async Task Erp_kipinde_musteri_basligi_ve_musteri_aramasi_hbys_kipinde_dis_doktor()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("sahakip", ["dis_doktor.ziyaret:ged", "dis_doktor.talep:g", "dis_doktor.vade:g", "dis_doktor.liste:g", "dis_doktor:g"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var h = api.Istemci(access, Merkez);

        // Ziyaret edilebilecek iki taraf: bir müşteri (ERP), bir dış doktor (HBYS).
        var musteriKod = d.Onek + "M";
        var musteri = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, personel, durum, sube_id) values (@p0, @p1, 1, 0, 1, @p2) returning id",
            [d.Onek + " Müşteri AŞ", musteriKod, Merkez]);
        d.Temizle($"delete from public.taraf where id = {musteri}");
        var hekimKod = d.Onek + "H";
        var hekim = await api.Veri.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, durum, sube_id) values ('', @p1, @p0, 1, 1, @p2) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) select y.id, 1, @p2 from y returning id",
            [hekimKod, d.Onek + " Hekim", Merkez]);
        d.Temizle($"delete from public.taraf_personel where id = {hekim}");
        d.Temizle($"delete from public.taraf where id = {hekim}");

        var eski = await KipYazAsync(1); // ERP
        try
        {
            Assert.Equal("Müşteri", await BaslikAsync(h, "/api/liste/dis-hekim-ziyaret/kolonlar", "kolonlar", "hekimAd"));
            Assert.Equal("Müşteri", await BaslikAsync(h, "/api/liste/dis-hekim-talep/kolonlar", "kolonlar", "hekimAd"));
            Assert.Equal("Satış ↓", await BaslikAsync(h, "/api/liste/dis-hekim-vade/kolonlar", "kolonlar", "gonderimDusen"));
            Assert.Equal("Müşteri", await BaslikAsync(h, "/api/kart/dis-hekim-ziyaret/alanlar", "alanlar", "hekimId"));
            Assert.Equal(1, await SahaHedefSayisiAsync(h, musteriKod));
            Assert.Equal(0, await SahaHedefSayisiAsync(h, hekimKod));

            await KipYazAsync(2); // HBYS
            Assert.Equal("Dış Doktor", await BaslikAsync(h, "/api/liste/dis-hekim-ziyaret/kolonlar", "kolonlar", "hekimAd"));
            Assert.Equal("Gönderim ↓", await BaslikAsync(h, "/api/liste/dis-hekim-vade/kolonlar", "kolonlar", "gonderimDusen"));
            Assert.Equal("Dış Doktor", await BaslikAsync(h, "/api/kart/dis-hekim-ziyaret/alanlar", "alanlar", "hekimId"));
            Assert.Equal(0, await SahaHedefSayisiAsync(h, musteriKod));
            Assert.Equal(1, await SahaHedefSayisiAsync(h, hekimKod));
        }
        finally { await KipGeriAsync(eski); }
    }

    [VtFact]
    public async Task Musteri_ziyareti_vade_gorunumune_satisla_girer()
    {
        await using var d = new TestDunyasi(api.Veri);
        var musteri = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, personel, durum, sube_id, ziyaret_sikligi_hafta) values (@p0, @p1, 1, 0, 1, @p2, 4) returning id",
            [d.Onek + " Müşteri Ltd", d.Onek + "V", Merkez]);
        d.Temizle($"delete from public.taraf where id = {musteri}");
        // Müşteri vade görünümünde (sıklık 4 hafta, hiç ziyaret yok → ekleme tarihinden vade).
        var satir = await api.Veri.TekDegerAsync<int>(
            "select count(*) from public.v_dis_hekim_ziyaret_vade where hekim_id = @p0 and siklik_hafta = 4", [musteri]);
        Assert.Equal(1, satir);
        // Temsilci bağı müşteriye de yazılabilir (tetik: dış doktor YA DA müşteri).
        var (temsilci, _) = await d.KullaniciAsync(await d.RolAsync("sahatem", ["dis_doktor.ziyaret:g"]), Merkez);
        await api.Veri.CalistirAsync("insert into public.taraf_personel (id, dis_hekim, sube_id) values (@p0, 0, @p1) on conflict (id) do nothing", [temsilci, Merkez]);
        d.Temizle($"delete from public.taraf_personel where id = {temsilci}");
        await api.Veri.CalistirAsync("insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')",
            [musteri, Merkez, temsilci]);
        d.Temizle($"delete from public.dis_hekim_temsilci where hekim_id = {musteri}");
        Assert.Equal(temsilci, await api.Veri.TekDegerAsync<int>("select public.fn_dis_hekim_temsilci(@p0, @p1, current_date)", [musteri, Merkez]));
    }
}
