using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// STOK KARTI FİYATLAR SEKMESİ = FİYAT LİSTESİ SATIRLARI (kullanıcı 09.11.2026: "yeni stok kartı oluşturduğumda
/// fiyatlar sekmesinde aktif alış/satış fiyatlarına göre satırlar gelmeli", "fiyat adı id yerine anlaşılır olsun").
///  · Meta: her AKTİF liste yeni kartta ön satır (yeniSatirlar), pasif liste gelmez; liste seçeneği yönüyle adlı.
///  · Kayıt: fiyatı boş / 0 bırakılan ön satır YAZILMAZ (BosAtlaAlani), dolu olan fiyat_listesi_satir'a manuel (yazım 1) gider.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class StokFiyatSekmesiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<(int Aktif, int Pasif)> ListelerAsync(TestDunyasi d)
    {
        var aktif = await api.Veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, yon, durum, kdv_dahil, tarife_tipi, sube_id, baslangic, bitis, aciklama)
            values (@p0, 2, 1, 0, 0, @p1, date '2000-01-01', date '2099-12-31', 'test') returning id
            """, [d.Onek + " Satış Listesi", Merkez]);
        var pasif = await api.Veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, yon, durum, kdv_dahil, tarife_tipi, sube_id, baslangic, bitis, aciklama)
            values (@p0, 1, 0, 0, 0, @p1, date '2000-01-01', date '2099-12-31', 'test') returning id
            """, [d.Onek + " Pasif Alış", Merkez]);
        d.Temizle($"delete from public.fiyat_listesi_satir where liste_id in ({aktif}, {pasif})");
        d.Temizle($"delete from public.fiyat_listesi where id in ({aktif}, {pasif})");
        return (aktif, pasif);
    }

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("stokfiyat", ["stok:ged", "fiyat_listesi.liste:g"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Meta_aktif_listeleri_on_satir_olarak_verir_pasifi_vermez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (aktif, pasif) = await ListelerAsync(d);
        var istemci = await IstemciAsync(d);

        var y = await istemci.GetAsync("/api/kart/stok/alanlar");
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        using var j = JsonDocument.Parse(govde);
        var fiyatlar = j.RootElement.GetProperty("detaylar").EnumerateArray().First(x => x.GetString("ad") == "fiyatlar");
        Assert.True(fiyatlar.GetProperty("gridKipi").GetBoolean());
        Assert.Equal("fiyat", fiyatlar.GetProperty("bosAtlaAlani").GetString());
        var listeIdleri = fiyatlar.GetProperty("yeniSatirlar").EnumerateArray()
            .Select(s => s.GetProperty("listeId").GetInt32()).ToList();
        Assert.Contains(aktif, listeIdleri);
        Assert.DoesNotContain(pasif, listeIdleri);
        // Liste seçeneği yönüyle adlı ("Satış · <ad>"), pasif seçenekte yok.
        var listeAlani = fiyatlar.GetProperty("alanlar").EnumerateArray().First(a => a.GetString("ad") == "listeId");
        var kodlar = listeAlani.GetProperty("kodlar");
        Assert.StartsWith("Satış · ", kodlar.GetProperty(aktif.ToString()).GetString());
        Assert.False(kodlar.TryGetProperty(pasif.ToString(), out _));
    }

    [VtFact]
    public async Task Bos_fiyatli_on_satir_yazilmaz_dolu_olan_manuel_satir_olur()
    {
        await using var d = new TestDunyasi(api.Veri);
        var (aktif, _) = await ListelerAsync(d);
        var ikinci = await api.Veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, yon, durum, kdv_dahil, tarife_tipi, sube_id, baslangic, bitis, aciklama)
            values (@p0, 2, 1, 0, 0, @p1, date '2000-01-01', date '2099-12-31', 'test') returning id
            """, [d.Onek + " İkinci Liste", Merkez]);
        d.Temizle($"delete from public.fiyat_listesi_satir where liste_id = {ikinci}");
        d.Temizle($"delete from public.fiyat_listesi where id = {ikinci}");
        var istemci = await IstemciAsync(d);
        var kategori = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.v_stok_kategori_lookup where aktif = 1", null);

        var y = await istemci.PostAsJsonAsync("/api/kart/stok", new
        {
            kart = new { kod = d.Onek + "-SF", ad = d.Onek + " fiyat sekmesi stoğu", durum = 1, izleme = 0, tipi = 1, kdv = 20, kategori },
            detaylar = new
            {
                fiyatlar = new
                {
                    eklenen = new object[]
                    {
                        new { listeId = aktif, fiyat = 125.5m, dovizCinsi = "TL", durum = 1 },
                        new { listeId = ikinci, fiyat = "", dovizCinsi = "TL", durum = 1 },   // boş bırakılan ön satır
                    },
                },
            },
        });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        var stokId = JsonDocument.Parse(govde).RootElement.GetProperty("kart").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.fiyat_listesi_satir where stok_id = {stokId}");
        d.Temizle($"delete from public.stok where id = {stokId}");

        var satirlar = await api.Veri.ListeAsync(
            "select liste_id, fiyat, yazim from public.fiyat_listesi_satir where stok_id = @p0 order by liste_id",
            [stokId], o => (Liste: o.GetInt32(0), Fiyat: o.GetDecimal(1), Yazim: o.GetInt16(2)));
        var tek = Assert.Single(satirlar);
        Assert.Equal(aktif, tek.Liste);
        Assert.Equal(125.5m, tek.Fiyat);
        Assert.Equal((short)1, tek.Yazim);
    }
}

file static class JsonUzanti
{
    public static string? GetString(this JsonElement e, string ad)
        => e.TryGetProperty(ad, out var v) && v.ValueKind == JsonValueKind.String ? v.GetString() : null;
}
