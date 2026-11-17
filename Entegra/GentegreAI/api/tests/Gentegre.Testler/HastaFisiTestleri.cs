using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// HASTA FİŞİ (128, db/1360 - kullanıcı 17.11.2026: "hasta tahakkuk ile kurum tahakkuk tamamen farklı.. hasta
/// tahakkukta takip yok.. sadece belge ile kapatmak için", "evet, hasta fişi yap, eskileri de çevir"): başvurunun hasta
/// payı tahakkuka çevrilirken sunucu hedefi Hasta Fişi yapar (17 yalnız kurum payı); Hasta Fişi başvurunun hasta payı
/// dışında kesilemez. Mevcut başvurulardan biri kullanılır; oluşan belge silinir (dönüşüm sayaçları geri döner).
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class HastaFisiTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    private async Task<HttpClient> IstemciAsync(TestDunyasi d)
    {
        var rol = await d.RolAsync("hfis", "belge:gedk", "belge.donustur", "belge.satis.fis:gedk", "belge.satis.tahakkuk:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        return api.Istemci(access, Merkez);
    }

    /// <summary>Hasta payı açık (en az 20 TL) kesinleşmiş başvuru satırı: (başvuru, satır, hasta).</summary>
    private async Task<(int Basvuru, int Satir, int Hasta)?> AcikHastaPayiAsync()
    {
        var r = await api.Veri.TekAsync<int[]>("""
        select b.id, s.id, b.taraf_id
          from public.belge b
          join public.belge_satir s on s.belge_id = b.id
          join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
         where b.tur = 19 and b.tipi = 30 and b.durum = 0 and b.sube_id = @p0
           and dg.hasta_provizyon - dg.hasta_provizyon_kapatilan >= 20
         order by b.id limit 1
        """, [Merkez], o => new[] { o.GetInt32(0), o.GetInt32(1), o.GetInt32(2) });
        return r is null ? null : (r[0], r[1], r[2]);
    }

    [VtFact]
    public async Task Basvuruda_hasta_payi_tahakkuku_Hasta_Fisi_olur_kurum_takibine_girmez()
    {
        var acik = await AcikHastaPayiAsync();
        Assert.True(acik is not null, "Test veritabanında hasta payı açık başvuru yok.");
        var (basvuru, satir, hasta) = acik!.Value;
        await using var d = new TestDunyasi(api.Veri);
        var istemci = await IstemciAsync(d);

        // Eski davranışla aynı istek: hedef 17 (tahakkuk), pay 1 (hasta).
        var y = await istemci.PostAsJsonAsync($"/api/belge/{basvuru}/donustur", new
        {
            hedefTur = 17, pay = 1,
            satirlar = new[] { new { satirId = satir, miktar = 0m, tutar = 10m } },
        });
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {await y.Content.ReadAsStringAsync()}");
        var yeni = (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("belge").GetProperty("id").GetInt32();
        d.Temizle($"delete from public.mali_hareket where belge_id = {yeni}");
        d.Temizle($"delete from public.belge_satir where belge_id = {yeni}");
        d.Temizle($"delete from public.belge where id = {yeni}");
        try
        {
            Assert.Equal(128, await api.Veri.TekDegerAsync<int>("select tur::int from public.belge where id = @p0", [yeni]));
            Assert.Equal(hasta, await api.Veri.TekDegerAsync<int>("select taraf_id from public.belge where id = @p0", [yeni]));
            // Muhasebesi satış gibi: hasta carisi borçlanır, hareket de 128 taşır.
            Assert.True(await api.Veri.TekDegerAsync<int>(
                "select count(*)::int from public.mali_hareket where belge_id = @p0 and tur = 128 and borc > 0", [yeni]) > 0);
            Assert.Equal("Hasta Fişi", await api.Veri.TekDegerAsync<string>(
                "select public.fn_belge_kisa_adi(tur, tipi)::text from public.belge where id = @p0", [yeni]));
        }
        finally
        {
            // Silme dönüşüm sayaçlarını da geri alır (başvuru bir sonraki koşuya açık kalır).
            var sil = await istemci.DeleteAsync($"/api/belge/{yeni}");
            Assert.True(sil.IsSuccessStatusCode, $"{(int)sil.StatusCode} {await sil.Content.ReadAsStringAsync()}");
        }
    }

    [VtFact]
    public async Task Hasta_Fisi_kurum_payindan_kesilemez()
    {
        var acik = await AcikHastaPayiAsync();
        Assert.True(acik is not null, "Test veritabanında hasta payı açık başvuru yok.");
        var (basvuru, satir, _) = acik!.Value;
        await using var d = new TestDunyasi(api.Veri);
        var istemci = await IstemciAsync(d);

        var y = await istemci.PostAsJsonAsync($"/api/belge/{basvuru}/donustur", new
        {
            hedefTur = 128, pay = 2,
            satirlar = new[] { new { satirId = satir, miktar = 0m, tutar = 10m } },
        });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, y.StatusCode);
        var hata = (await y.Content.ReadFromJsonAsync<JsonElement>()).GetProperty("hata").GetProperty("mesaj").GetString();
        Assert.Contains("Hasta Fişi", hata);
    }
}
