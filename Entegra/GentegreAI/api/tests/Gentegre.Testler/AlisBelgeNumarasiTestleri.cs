using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// ALIŞ BELGESİ TEDARİKÇİ NUMARASI (12.11.2026; kullanıcı: "alış irs girip kaydettim geri açtığımda irs no boş geldi",
/// "tekrar girip kaydet dediğimde de zaten kayıtlı belge diyor", "diğer alış belgeleri için de kontrol et", "aynı
/// tedarikçiden aynı belge türünden aynı numara girilemez"). Dört dış numaralı tür (10 irsaliye, 11 fatura, 12 fiş,
/// 109 konsinye giriş): okumada numara döner, aynı numarayla düzenleme serbest (kendisi mükerrer sayılmaz), numara
/// düzeltilebilir, aynı tedarikçi + aynı tür + aynı numara 422, başka türde aynı numara serbest.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class AlisBelgeNumarasiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private static readonly string Tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("alisno", "belge:gedk", "belge.alis.irsaliye:gedk", "belge.alis_fatura:gedk",
                                   "belge.alis.fis:gedk", "belge.alis.konsinye:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    private static async Task<string> MesajAsync(HttpResponseMessage y)
    {
        var g = await y.Content.ReadAsStringAsync();
        return JsonDocument.Parse(g).RootElement.TryGetProperty("hata", out var h) ? h.GetProperty("mesaj").GetString() ?? "" : g;
    }

    [VtTheory]
    [InlineData(10)]
    [InlineData(11)]
    [InlineData(12)]
    [InlineData(109)]
    public async Task Tedarikci_numarasi_okunur_duzenlenir_mukerrer_engellenir(int tur)
    {
        await using var d = new TestDunyasi(api.Veri);
        var h = await IstemciAsync(d);
        var depo = await api.Veri.TekDegerAsync<int>(
            "insert into public.depo (ad, durum, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " Depo", Merkez]);
        d.Temizle($"delete from public.stok_durum where depo_id = {depo}");
        d.Temizle($"delete from public.depo where id = {depo}");
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-STK", d.Onek + " alış stoğu", Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        var tedarikci = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, tedarikci, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + " Tedarikçi", Merkez]);
        d.Temizle($"delete from public.taraf where id = {tedarikci}");
        var satirlar = new[] { new { tur = 1, stokId = stok, adet = 2, miktar = 2, birimFiyat = 10 } };
        object Belge(string no) => new { tur, tipi = 1, belgeTarihi = Tarih, tarafId = tedarikci, girisDepoId = depo, belgeNo = no };
        var no = "TT" + d.Onek[^6..];

        async Task<int> Yaz(string n)
        {
            var y = await h.PostAsJsonAsync("/api/belge/", new { belge = Belge(n), satirlar });
            var g = await y.Content.ReadAsStringAsync();
            Assert.True(y.IsSuccessStatusCode, $"tür {tur}: {(int)y.StatusCode} {g}");
            var id = JsonDocument.Parse(g).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
            d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {id}");
            d.Temizle($"delete from public.mali_hareket where belge_id = {id}");
            d.Temizle($"delete from public.stok_izleme where belge_id = {id}");
            d.Temizle($"delete from public.belge_satir where belge_id = {id}");
            d.Temizle($"delete from public.belge where id = {id}");
            return id;
        }
        async Task<string> Oku(int id)
        {
            var g = await h.GetStringAsync($"/api/belge/{id}");
            return JsonDocument.Parse(g).RootElement.GetProperty("belge").GetProperty("belgeNo").ToString();
        }
        Task<string> Surum(int id) => api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [id])!;

        var id = await Yaz(no);
        Assert.Equal(no, await Oku(id));                                                   // açılışta numara gelir

        // Aynı numarayla yeniden kaydet - kendisi mükerrer sayılmaz.
        var p1 = await h.PutAsJsonAsync($"/api/belge/{id}", new { surum = await Surum(id), belge = Belge(no), satirlar });
        Assert.True(p1.IsSuccessStatusCode, $"tür {tur}: {(int)p1.StatusCode} {await p1.Content.ReadAsStringAsync()}");

        // Numara düzeltilebilir (yazım hatası).
        var p2 = await h.PutAsJsonAsync($"/api/belge/{id}", new { surum = await Surum(id), belge = Belge(no + "X"), satirlar });
        Assert.True(p2.IsSuccessStatusCode, $"tür {tur}: {(int)p2.StatusCode} {await p2.Content.ReadAsStringAsync()}");
        Assert.Equal(no + "X", await Oku(id));

        // Aynı tedarikçi + aynı tür + aynı numara: yeni belge de, başka belgenin düzenlemesi de 422.
        var ikinci = await h.PostAsJsonAsync("/api/belge/", new { belge = Belge(no + "X"), satirlar });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, ikinci.StatusCode);
        Assert.Contains("zaten", await MesajAsync(ikinci));
        var baska = await Yaz(no + "Y");
        var p3 = await h.PutAsJsonAsync($"/api/belge/{baska}", new { surum = await Surum(baska), belge = Belge(no + "X"), satirlar });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, p3.StatusCode);

        // Eski mükerrer (Delphi aktarımı): numarası değişmeden düzenlenebilir.
        await api.Veri.CalistirAsync("update public.belge set belge_no = @p1 where id = @p0", [baska, no + "X"]);
        var p5 = await h.PutAsJsonAsync($"/api/belge/{baska}", new { surum = await Surum(baska), belge = Belge(no + "X"), satirlar });
        Assert.True(p5.IsSuccessStatusCode, $"tür {tur}: {(int)p5.StatusCode} {await p5.Content.ReadAsStringAsync()}");

        // Başka türde aynı numara serbest (irsaliye no = fatura no olabilir).
        var digerTur = tur == 10 ? 11 : 10;
        var y4 = await h.PostAsJsonAsync("/api/belge/", new
        {
            belge = new { tur = digerTur, tipi = 1, belgeTarihi = Tarih, tarafId = tedarikci, girisDepoId = depo, belgeNo = no + "X" }, satirlar,
        });
        var g4 = await y4.Content.ReadAsStringAsync();
        Assert.True(y4.IsSuccessStatusCode, $"tür {digerTur}: {(int)y4.StatusCode} {g4}");
        var id4 = JsonDocument.Parse(g4).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {id4}");
        d.Temizle($"delete from public.mali_hareket where belge_id = {id4}");
        d.Temizle($"delete from public.stok_izleme where belge_id = {id4}");
        d.Temizle($"delete from public.belge_satir where belge_id = {id4}");
        d.Temizle($"delete from public.belge where id = {id4}");
    }
}
