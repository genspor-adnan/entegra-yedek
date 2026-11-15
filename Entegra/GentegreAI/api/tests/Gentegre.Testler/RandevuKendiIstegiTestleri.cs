using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// RANDEVUDA KENDİ İSTEĞİ (1346; kullanıcı 15.11.2026: "randevu kartında gönderen yoksa başvuru gibi Kendi İsteği
/// check olmalı"): kart meta'sı işareti karşıt alanıyla (gonderenId) verir ve yeni kayıtta 1 açar; gönderen seçili
/// kayıtta sunucu işareti 0'a çeker (iki bilgi aynı anda doğru olamaz); gönderen boşsa işaret korunur.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class RandevuKendiIstegiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("rvki", ["randevu:ged"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private async Task<int> TarafAsync(TestDunyasi d, string ek, string rolKolonu)
    {
        var id = await api.Veri.TekDegerAsync<int>(
            $"insert into public.taraf (unvan, {rolKolonu}, sube_id) values (@p0, 1, 1) returning id",
            [d.Onek + " " + ek]);
        d.Temizle($"delete from public.randevu where hasta_id = {id} or gonderen_id = {id}");
        d.Temizle($"delete from public.taraf where id = {id}");
        return id;
    }

    private static async Task<JsonElement> JsonAsync(HttpResponseMessage y)
    {
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        return JsonDocument.Parse(govde).RootElement.Clone();
    }

    [VtFact]
    public async Task Meta_karsit_alani_verir_ve_yeni_kayitta_isaretli_acar()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var j = await JsonAsync(await h.GetAsync("/api/kart/randevu/alanlar"));
        var alan = j.GetProperty("alanlar").EnumerateArray()
                    .FirstOrDefault(a => a.GetProperty("ad").GetString() == "kendiIstegi");
        // Alan gönderen kapısına bağlı: kapı kapalı kurulumda meta'da hiç yoktur - o zaman yalnız varsayılan denetlenir.
        if (alan.ValueKind == JsonValueKind.Object)
            Assert.Equal("gonderenId", alan.GetProperty("karsitAlan").GetString());
        Assert.Equal(1, j.GetProperty("varsayilanlar").GetProperty("kendiIstegi").GetInt32());
        // KURUM VARSAYILANI (1347, "default ücretli olsun"): tür 1 Özel kurum id'si sorguyla gelir.
        var ozel = await api.Veri.TekDegerAsync<int?>(
            "select t.id from public.taraf t join public.taraf_kurum k on k.id = t.id where t.kurum = 1 and k.anlasmali = 1 and k.tur = 1 and t.durum = 1 order by t.id limit 1", null);
        if (ozel is { } o)
            Assert.Equal(o, j.GetProperty("varsayilanlar").GetProperty("kurumId").GetInt32());
    }

    [VtFact]
    public async Task Gonderen_seciliyse_isaret_sunucuda_sifirlanir_bos_ise_korunur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var hasta = await TarafAsync(d, "hasta", "hasta");
        var gonderen = await TarafAsync(d, "gonderen", "personel");
        // Ayrı saatler: aynı hekime aynı saatte ikinci randevu "başka randevusu var" (IS_KURALI) ile düşer.
        var baslangic = DateTime.UtcNow.Date.AddDays(400).AddHours(9).ToString("yyyy-MM-ddTHH:mm:ss");
        var baslangic2 = DateTime.UtcNow.Date.AddDays(400).AddHours(11).ToString("yyyy-MM-ddTHH:mm:ss");
        // Tıp merkezi / hastane kurulumunda bölüm ve doktor zorunlu (randevu.bolum_doktor kapısı): mevcutlardan seçilir.
        var bolum = await api.Veri.TekDegerAsync<int>("select coalesce(min(id), 0) from public.v_randevu_bolum_lookup where aktif = 1", null);
        var hekim = await api.Veri.TekDegerAsync<int>("select coalesce(min(id), 0) from public.v_hekim_lookup where aktif = 1", null);
        Assert.True(bolum > 0 && hekim > 0, "test DB'de aktif bölüm / hekim yok");

        var y1 = await JsonAsync(await h.PostAsJsonAsync("/api/kart/randevu", new { kart = new
            { hastaId = hasta, baslangic, sureDk = 15, durum = 1, tip = 3, kaynak = 1, bolum, hekimId = hekim, gonderenId = gonderen, kendiIstegi = true } }));
        var id1 = y1.GetProperty("kart").GetProperty("id").GetInt32();
        Assert.Equal(0, await api.Veri.TekDegerAsync<int>("select kendi_istegi from public.randevu where id = @p0", [id1]));

        var y2 = await JsonAsync(await h.PostAsJsonAsync("/api/kart/randevu", new { kart = new
            { hastaId = hasta, baslangic = baslangic2, sureDk = 15, durum = 1, tip = 3, kaynak = 1, bolum, hekimId = hekim, kendiIstegi = true } }));
        var id2 = y2.GetProperty("kart").GetProperty("id").GetInt32();
        Assert.Equal(1, await api.Veri.TekDegerAsync<int>("select kendi_istegi from public.randevu where id = @p0", [id2]));
    }
}
