using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// SAHA PERFORMANSI UCU (1292, mockup temsilci_ziyaret.html §6): dönemdeki radyoloji istemi hekim ve temsilci satırına
/// gönderim olarak düşer (temsilci = başvurunun satici_id'si, 1287 tetiğiyle dolar), yapılan ziyaret sayılır, önceki
/// dönemle değişim hesaplanır. Uç yalnız okur; yetki dis_doktor.performans.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class SahaPerformansTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Gonderim_ve_ziyaret_temsilci_ve_doktor_satirina_duser()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("sahaperf", "dis_doktor.performans");
        var (kId, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(kId, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        var istemci = api.Istemci(access, Merkez);

        async Task<int> Kisi(short dis, string ad) => await api.Veri.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, durum, sube_id) values ('', @p2, @p0, 1, 1, @p1) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) select y.id, @p3, @p1 from y returning id",
            [d.Onek + ad[..3], Merkez, d.Onek + " " + ad, dis]);
        var hekim = await Kisi(1, "Hekim");
        var temsilci = await Kisi(0, "Temsilci");
        foreach (var id in new[] { hekim, temsilci })
        {
            d.Temizle($"delete from public.taraf_personel where id = {id}");
            d.Temizle($"delete from public.taraf where id = {id}");
        }
        await api.Veri.CalistirAsync(
            "insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')",
            [hekim, Merkez, temsilci]);
        d.Temizle($"delete from public.dis_hekim_temsilci where hekim_id = {hekim}");

        var hasta = await api.Veri.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) values ('SAHA HASTA', @p0, 1, @p1) returning id", [d.Onek + "H", Merkez]);
        d.Temizle($"delete from public.taraf where id = {hasta}");
        var hizmet = await api.Veri.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) values (@p0, 'SAHA MR', 1, 2, @p1) returning id", [d.Onek + "Z", Merkez]);
        d.Temizle($"delete from public.hizmet where id = {hizmet}");
        var belge = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge (tur, tipi, taraf_id, belge_tarihi, belge_dovizi, doviz_kuru, sube_id, durum, belge_no) "
            + "values (15, 1, @p0, current_date, 'TL', 1, @p1, 0, @p2) returning id", [hasta, Merkez, d.Onek]);
        d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {belge}");
        d.Temizle($"delete from public.belge_satir_rol where belge_satir_id in (select id from public.belge_satir where belge_id = {belge})");
        d.Temizle($"delete from public.radyoloji_istem where belge_satir_id in (select id from public.belge_satir where belge_id = {belge})");
        d.Temizle($"delete from public.belge_satir where belge_id = {belge}");
        d.Temizle($"delete from public.belge where id = {belge}");
        var satir = await api.Veri.TekDegerAsync<int>(
            "insert into public.belge_satir (belge_id, sira, tur, hizmet_id, miktar, adet, birim_fiyat, tutar, kdv, doviz_cinsi, sube_id) "
            + "values (@p0, 1, 2, @p1, 1, 1, 900, 900, 20, 'TL', @p2) returning id", [belge, hizmet, Merkez]);
        await api.Veri.CalistirAsync("""
            insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, belge_satir_id, istek_hekim_id)
            values (@p0, @p1, @p2, 2, @p3, 1, @p4, @p5)
            """, [Merkez, hasta, hizmet, Guid.NewGuid().ToString("N")[..12], satir, hekim]);
        await api.Veri.CalistirAsync("""
            insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, durum, sonuc, hatirlat)
            values (@p0, @p1, @p2, now(), 1, 1, 0)
            """, [hekim, temsilci, Merkez]);
        d.Temizle($"delete from public.dis_hekim_ziyaret where hekim_id = {hekim}");

        var bas = DateTime.Today.AddDays(-15).ToString("yyyy-MM-dd");
        var bit = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd");
        var y = await istemci.GetAsync($"/api/dis-hekim/performans?bas={bas}&bit={bit}&sube={Merkez}");
        var govde = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {govde}");
        var j = JsonDocument.Parse(govde).RootElement;

        var t = j.GetProperty("temsilciler").EnumerateArray().FirstOrDefault(x => x.GetProperty("id").GetInt32() == temsilci);
        Assert.NotEqual(JsonValueKind.Undefined, t.ValueKind);
        Assert.Equal(1, t.GetProperty("gonderim").GetInt32());
        Assert.Equal(1, t.GetProperty("ziyaret").GetInt32());
        Assert.Equal(1, t.GetProperty("aktifHekim").GetInt32());
        Assert.Equal(900m, t.GetProperty("tutar").GetDecimal());

        var dr = j.GetProperty("doktorlar").EnumerateArray().FirstOrDefault(x => x.GetProperty("id").GetInt32() == hekim);
        Assert.NotEqual(JsonValueKind.Undefined, dr.ValueKind);
        Assert.Equal(1, dr.GetProperty("gonderim").GetInt32());
        Assert.Contains("MR", dr.GetProperty("modaliteler").GetString());
        Assert.Equal(1, dr.GetProperty("ziyaret").GetInt32());
        Assert.True(j.GetProperty("ozet").GetProperty("gonderim").GetInt32() >= 1);
    }
}
