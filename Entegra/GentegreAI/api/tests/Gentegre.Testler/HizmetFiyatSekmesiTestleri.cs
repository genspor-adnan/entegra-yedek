using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// HİZMET KARTI FİYATLAR SEKMESİ = FİYAT LİSTESİ SATIRLARI (09.11.2026, stok kartıyla aynı desen; mockup
/// Ekranlar/Stok/hizmet_karti_baslik_kip.html). Eski hizmet_fiyat detayı kalktı.
///  · Meta: kimlik sırası Kod · Hizmet Adı · Kısa Ad · Kategori · Durum; her AKTİF liste yeni kartta ön satır, pasif gelmez.
///  · Kayıt: fiyatı boş bırakılan ön satır YAZILMAZ, dolu olan fiyat_listesi_satir'a hizmet_id + manuel (yazım 1) gider.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HizmetFiyatSekmesiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<int> ListeAsync(TestDunyasi d, string ad, short yon, short durum)
    {
        var id = await api.Veri.TekDegerAsync<int>("""
            insert into public.fiyat_listesi (ad, yon, durum, kdv_dahil, tarife_tipi, sube_id, baslangic, bitis, aciklama)
            values (@p0, @p1, @p2, 0, 0, @p3, date '2000-01-01', date '2099-12-31', 'test') returning id
            """, [d.Onek + " " + ad, yon, durum, Merkez]);
        d.Temizle($"delete from public.fiyat_listesi_satir where liste_id = {id}");
        d.Temizle($"delete from public.fiyat_listesi where id = {id}");
        return id;
    }

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("hizmetfiyat", ["hizmet:ged", "fiyat_listesi.liste:g"]);
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    [VtFact]
    public async Task Meta_kimlik_sirasi_ve_aktif_listeler_on_satir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var aktif = await ListeAsync(d, "Satış Listesi", 2, 1);
        var pasif = await ListeAsync(d, "Pasif Alış", 1, 0);
        var istemci = await IstemciAsync(d);

        var y = await istemci.GetAsync("/api/kart/hizmet/alanlar");
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        using var j = JsonDocument.Parse(govde);

        // Kimlik grubu sırası: Kod · Hizmet Adı · Kısa Ad · Kategori · Durum.
        var kimlik = j.RootElement.GetProperty("alanlar").EnumerateArray()
            .Where(a => a.TryGetProperty("grup", out var g) && g.GetString() == "Kimlik")
            .Select(a => a.GetProperty("ad").GetString()).ToList();
        Assert.Equal(["kod", "ad", "kisaAd", "kategori", "durum"], kimlik);

        var fiyatlar = j.RootElement.GetProperty("detaylar").EnumerateArray().First(x => x.GetProperty("ad").GetString() == "fiyatlar");
        Assert.True(fiyatlar.GetProperty("gridKipi").GetBoolean());
        Assert.True(fiyatlar.GetProperty("anindaKaydet").GetBoolean());
        Assert.Equal("fiyat", fiyatlar.GetProperty("bosAtlaAlani").GetString());
        var listeIdleri = fiyatlar.GetProperty("yeniSatirlar").EnumerateArray()
            .Select(s => s.GetProperty("listeId").GetInt32()).ToList();
        Assert.Contains(aktif, listeIdleri);
        Assert.DoesNotContain(pasif, listeIdleri);
    }

    [VtFact]
    public async Task Bos_on_satir_yazilmaz_dolu_satir_hizmet_id_ile_manuel_yazilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var aktif = await ListeAsync(d, "Satış Listesi", 2, 1);
        var ikinci = await ListeAsync(d, "İkinci Liste", 2, 1);
        var istemci = await IstemciAsync(d);
        var kategori = await api.Veri.TekDegerAsync<int>(
            "select min(id) from public.v_hizmet_kategori_lookup where aktif = 1", null);

        var y = await istemci.PostAsJsonAsync("/api/kart/hizmet", new
        {
            kart = new { ad = d.Onek + " fiyat sekmesi hizmeti", durum = 1, kdv = 10, birim = 51, kategori },
            detaylar = new
            {
                fiyatlar = new
                {
                    eklenen = new object[]
                    {
                        new { listeId = aktif, fiyat = 80m, dovizCinsi = "TL", birim = 51, durum = 1 },
                        new { listeId = ikinci, fiyat = "", dovizCinsi = "TL", birim = 51, durum = 1 },   // boş ön satır
                    },
                },
            },
        });
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, govde);
        var hizmetId = JsonDocument.Parse(govde).RootElement.GetProperty("kart").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.fiyat_listesi_satir where hizmet_id = {hizmetId}");
        d.Temizle($"delete from public.hizmet where id = {hizmetId}");

        var satirlar = await api.Veri.ListeAsync(
            "select liste_id, fiyat, yazim, stok_id from public.fiyat_listesi_satir where hizmet_id = @p0 order by liste_id",
            [hizmetId], o => (Liste: o.GetInt32(0), Fiyat: o.GetDecimal(1), Yazim: o.GetInt16(2), StokBos: o.IsDBNull(3)));
        var tek = Assert.Single(satirlar);
        Assert.Equal(aktif, tek.Liste);
        Assert.Equal(80m, tek.Fiyat);
        Assert.Equal((short)1, tek.Yazim);
        Assert.True(tek.StokBos);
    }
}
