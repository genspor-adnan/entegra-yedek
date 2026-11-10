using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ DOKTOR ZİYARETİ + TALEP (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): temsilci boşsa şube
/// temsilcisi yazılır, yapılan ziyaretin sonraki tarihi temsilciye hatırlatma açar (bir kez), talep ziyaretten
/// hekim / şubeyi alır ve kapanınca damgalanır, görünümler ad / kod çözer.
/// </summary>
public sealed class DisHekimZiyaretTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static Task<int> KisiAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube, short disHekim, string ad)
        => b.TekDegerAsync<int>(
            "with y as (insert into public.taraf (unvan, ad, kod, personel, sube_id) "
            + "          values ('', @p3, @p1, 1, @p0) returning id) "
            + "insert into public.taraf_personel (id, dis_hekim, sube_id) "
            + "select y.id, @p2, @p0 from y returning id",
            t, [sube, "DZT" + Guid.NewGuid().ToString("N")[..8], disHekim, ad], Iptal);

    [VtFact(DisplayName = "Ziyaret: temsilci şube temsilcisinden, sonraki tarih hatırlatma açar, talep hekimi ziyaretten alır")]
    public async Task ZiyaretVeTalepAkisi()
    {
        if (!_olgu.Baglandi(nameof(ZiyaretVeTalepAkisi))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var hekim = await KisiAsync(b, t, sube, 1, "Dr Ziyaret");
        var temsilci = await KisiAsync(b, t, sube, 0, "Temsilci");
        await b.CalistirAsync(
            "insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic) values (@p0, @p1, @p2, date '2026-01-01')",
            t, [hekim, sube, temsilci], Iptal);

        // Temsilci verilmedi, hatırlat açık, sonraki tarih var -> tetik temsilciyi ve hatırlatmayı yazar.
        var ziyaret = await b.TekDegerAsync<int>("""
            insert into public.dis_hekim_ziyaret (hekim_id, sube_id, tarih, tur, amac, sonuc, durum, notu, sonraki_tarih, hatirlat)
            values (@p0, @p1, now(), 1, 1, 1, 1, 'Tanışma; broşür bırakıldı', current_date + 28, 1) returning id
            """, t, [hekim, sube], Iptal);
        var z = await b.TekAsync("select temsilci_id, hatirlatma_id from public.dis_hekim_ziyaret where id = @p0",
                                 t, [ziyaret], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal(temsilci, Convert.ToInt32(z!["temsilci_id"]));
        var hatirlatmaId = Convert.ToInt32(z["hatirlatma_id"]);
        Assert.True(hatirlatmaId > 0);
        var h = await b.TekAsync("select sahip_id, kaynak, kaynak_id, baslik from public.hatirlatma where id = @p0",
                                 t, [hatirlatmaId], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal(temsilci, Convert.ToInt32(h!["sahip_id"]));
        Assert.Equal("dis_hekim_ziyaret", Convert.ToString(h["kaynak"]));
        Assert.Equal(ziyaret, Convert.ToInt32(h["kaynak_id"]));
        Assert.StartsWith("Ziyaret:", Convert.ToString(h["baslik"]));
        // İkinci güncelleme ikinci hatırlatma AÇMAZ.
        await b.CalistirAsync("update public.dis_hekim_ziyaret set notu = notu || '.' where id = @p0", t, [ziyaret], Iptal);
        Assert.Equal(1, await b.TekDegerAsync<int>(
            "select count(*)::int from public.hatirlatma where kaynak = 'dis_hekim_ziyaret' and kaynak_id = @p0", t, [ziyaret], Iptal));

        // Talep ziyaretten: hekim / şube ziyaretten; kapanınca damga.
        var talep = await b.TekDegerAsync<int>("""
            insert into public.dis_hekim_talep (ziyaret_id, sube_id, tur, talep, oncelik, termin)
            values (@p0, 0, 2, 'Acil hastaya aynı gün MR', 3, current_date - 1) returning id
            """, t, [ziyaret], Iptal);
        var tl = await b.TekAsync(
            "select hekim_id, sube_id, durum, kapanma, gecikme_gun, oncelik_ad, temsilci_id from public.v_dis_hekim_talep where id = @p0",
            t, [talep], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal(hekim, Convert.ToInt32(tl!["hekim_id"]));
        Assert.Equal(sube, Convert.ToInt32(tl["sube_id"]));
        Assert.Equal(1, Convert.ToInt32(tl["gecikme_gun"]));
        Assert.Equal("Acil", Convert.ToString(tl["oncelik_ad"]));
        Assert.Equal(temsilci, Convert.ToInt32(tl["temsilci_id"]));
        Assert.True(tl["kapanma"] is null or DBNull);
        await b.CalistirAsync("update public.dis_hekim_talep set durum = 3, sonuc = 'slot açıldı' where id = @p0", t, [talep], Iptal);
        Assert.False(await b.TekDegerAsync<object>("select kapanma from public.dis_hekim_talep where id = @p0", t, [talep], Iptal) is DBNull or null);

        // Ziyaret görünümü: adlar ve talep sayısı.
        var v = await b.TekAsync(
            "select hekim_ad, temsilci_ad, tur_ad, amac_ad, sonuc_ad, talep_sayisi, acik_talep from public.v_dis_hekim_ziyaret where id = @p0",
            t, [ziyaret], OkuyucuGenisletmeleri.Sozluk, Iptal)!;
        Assert.Equal("Yüz yüze", Convert.ToString(v!["tur_ad"]));
        Assert.Equal("Rutin ziyaret", Convert.ToString(v["amac_ad"]));
        Assert.Equal("Görüşüldü", Convert.ToString(v["sonuc_ad"]));
        Assert.Equal(1, Convert.ToInt32(v["talep_sayisi"]));
        Assert.Equal(0, Convert.ToInt32(v["acik_talep"]));
        Assert.Contains("Temsilci", Convert.ToString(v["temsilci_ad"]));
        await t.RollbackAsync();
    }
}
