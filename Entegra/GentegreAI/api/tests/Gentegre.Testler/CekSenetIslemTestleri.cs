using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// ÇEK / SENET PORTFÖY İŞLEMLERİ (1386; kullanıcı 20.11.2026: "işlem buton ve altında menüyü de ekle", "çek/senet
/// hareketleri aynı delphi erp deki çek/senet hareketleri gibi olmalı"). Delphi kuralları: işlem durumuna göre,
/// tarih son hareketten önce olamaz, ciro carinin borcu (kasa 52), portföye geri alma tersi (23), tahsil para
/// hesabına (51), son hareket geri alınır (kasa işlemi iptal), giriş hareketi geri alınmaz.
/// Her test kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class CekSenetIslemTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [Fact]
    public void Delphi_menusu_durumlara_gore()
    {
        string[] Kodlar(int yon, int durum) => CekSenetIslemleri.Yapilabilir(yon, durum).Select(k => k.Kod).ToArray();
        Assert.Equal(["cirola", "teminat-cari", "teminat-banka", "takas", "icra", "karsiliksiz", "tahsil", "iade"], Kodlar(1, 10));
        Assert.Equal(["portfoye-al"], Kodlar(1, 20));                      // cirolu: yalnız portföye al
        Assert.Equal(["portfoye-al", "tahsil"], Kodlar(1, 30));            // takas: portföye al, tahsil
        Assert.Empty(Kodlar(1, 50));                                       // tahsil edildi: son
        Assert.Equal(["odendi", "iade-al"], Kodlar(2, 10));
        Assert.Equal(["saticiya-ver", "iptal"], Kodlar(2, 70));
    }

    private static async Task<(int Cek, int Sahip, int Ciro, int Hesap, YazmaBaglami Baglam)> HazirlaAsync(
        NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>("select id from public.sube order by id limit 1", t, [], CancellationToken.None);
        var kullanici = await b.TekDegerAsync<int>("select id from public.v_kullanici_lookup order by id limit 1", t, [], CancellationToken.None);
        var sahip = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, grup, durum, sube_id) values ('TEST CEK SAHIBI', 1, 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var ciro = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, grup, durum, sube_id) values ('TEST CIRO ALICI', 1, 1, @p0) returning id",
            t, [sube], CancellationToken.None);
        var hesap = await b.TekDegerAsync<int>(
            "select id from public.hesap where coalesce(doviz_cinsi, 'TL') in ('TL', 'TRY', '') order by id limit 1",
            t, [], CancellationToken.None);
        var cek = await b.TekDegerAsync<int>("""
            insert into public.cek_senet (tur, yon, durum, taraf_id, tarih, vade, tutar, doviz_cinsi, doviz_kuru,
                                          yerel_tutar, seri_no, sube_id, ekleyen)
            values (1, 1, 10, @p0, current_date - 3, current_date + 30, 1000, 'TL', 1, 1000, 'TST-CS-1386', @p1, @p2)
            returning id
            """, t, [sahip, sube, kullanici], CancellationToken.None);
        // GİRİŞ HAREKETİ TETİKTEN (1387, Delphi "Yeni Çek" satırı) - tek satır.
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.cek_senet_hareket where cek_senet_id = @p0 and islem = 130 and eski_durum = 0",
            t, [cek], CancellationToken.None));
        return (cek, sahip, ciro, hesap, new YazmaBaglami(kullanici, sube, "127.0.0.1"));
    }

    private static Task<List<IDictionary<string, object?>>> CekAsync(NpgsqlConnection b, NpgsqlTransaction t, int id)
        => b.ListeAsync("select durum, ciro_taraf_id, hesap_id from public.cek_senet where id = @p0",
                        t, [id], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

    private static Task<List<IDictionary<string, object?>>> KasaAsync(NpgsqlConnection b, NpgsqlTransaction t, int id)
        => b.ListeAsync("select tur, durum, taraf_id, hesap_id, tutar from public.kasa_islem where id = @p0",
                        t, [id], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);

    [VtFact]
    public async Task Ciro_portfoye_al_geri_al_ve_tahsil()
    {
        if (!_olgu.Baglandi(nameof(Ciro_portfoye_al_geri_al_ve_tahsil))) return;
        var veri = _olgu.Gerekli();
        var depo = new KasaDeposu(veri, new LogDeposu());
        await using var b = await veri.AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (cek, _, ciroAlici, hesap, baglam) = await HazirlaAsync(b, t);
        var bugun = Saat.BugunDilim(null);

        // CİRO: carinin borcu (52), kıymet ciro edildi.
        var ciro = await depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("cirola", bugun.AddDays(-2), ciroAlici, null, "CB-1", "test"), baglam);
        var c = (await CekAsync(b, t, cek))[0];
        Assert.Equal(20, Convert.ToInt32(c["durum"]));
        Assert.Equal(ciroAlici, Convert.ToInt32(c["ciro_taraf_id"]));
        var k = (await KasaAsync(b, t, ciro.KasaIslemId!.Value))[0];
        Assert.Equal(52, Convert.ToInt32(k["tur"]));
        Assert.Equal(2, Convert.ToInt32(k["durum"]));
        Assert.Equal(ciroAlici, Convert.ToInt32(k["taraf_id"]));
        Assert.Equal(1000m, Convert.ToDecimal(k["tutar"]));

        // TARİH son hareketten önce olamaz.
        await Assert.ThrowsAsync<GentegreHatasi>(() => depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("portfoye-al", bugun.AddDays(-3), null, null, null, null), baglam));

        // Cirolu çek tahsil edilemez (Delphi menüsü).
        await Assert.ThrowsAsync<GentegreHatasi>(() => depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("tahsil", bugun, null, hesap, null, null), baglam));

        // PORTFÖYE AL: ciro alıcısının alacağı (23), ciro edilen temizlenir.
        var geri = await depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("portfoye-al", bugun, null, null, null, null), baglam);
        c = (await CekAsync(b, t, cek))[0];
        Assert.Equal(10, Convert.ToInt32(c["durum"]));
        Assert.Null(c["ciro_taraf_id"]);
        k = (await KasaAsync(b, t, geri.KasaIslemId!.Value))[0];
        Assert.Equal(23, Convert.ToInt32(k["tur"]));
        Assert.Equal(ciroAlici, Convert.ToInt32(k["taraf_id"]));

        // SON HAREKETİ GERİ AL: portföye alma geri alınır - kasa işlemi iptal, kıymet yine cirolu.
        await depo.CekSenetGeriAlAsync(b, t, cek, baglam);
        c = (await CekAsync(b, t, cek))[0];
        Assert.Equal(20, Convert.ToInt32(c["durum"]));
        Assert.Equal(ciroAlici, Convert.ToInt32(c["ciro_taraf_id"]));
        Assert.Equal(3, Convert.ToInt32((await KasaAsync(b, t, geri.KasaIslemId!.Value))[0]["durum"]));

        // Ciroyu da geri al, sonra tahsil: para hesabına (51), cari yok.
        await depo.CekSenetGeriAlAsync(b, t, cek, baglam);
        Assert.Equal(10, Convert.ToInt32((await CekAsync(b, t, cek))[0]["durum"]));
        var tahsil = await depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("tahsil", bugun, null, hesap, null, null), baglam);
        c = (await CekAsync(b, t, cek))[0];
        Assert.Equal(50, Convert.ToInt32(c["durum"]));
        Assert.Equal(hesap, Convert.ToInt32(c["hesap_id"]));
        k = (await KasaAsync(b, t, tahsil.KasaIslemId!.Value))[0];
        Assert.Equal(51, Convert.ToInt32(k["tur"]));
        Assert.Equal(hesap, Convert.ToInt32(k["hesap_id"]));
        Assert.Null(k["taraf_id"]);

        // Görünüm: Delphi kolonları - işlem yeri, makbuz no.
        var v = await b.ListeAsync(
            "select islem, islem_yeri, belge_no from public.v_cek_senet_hareket where cek_senet_id = @p0 order by tarih, id",
            t, [cek], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);
        Assert.Equal([130, 133], v.Select(x => Convert.ToInt32(x["islem"])).ToArray());
        Assert.Equal("TEST CEK SAHIBI", v[0]["islem_yeri"]?.ToString());

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Giris_hareketi_geri_alinmaz_takas_kasasiz()
    {
        if (!_olgu.Baglandi(nameof(Giris_hareketi_geri_alinmaz_takas_kasasiz))) return;
        var veri = _olgu.Gerekli();
        var depo = new KasaDeposu(veri, new LogDeposu());
        await using var b = await veri.AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var (cek, _, _, hesap, baglam) = await HazirlaAsync(b, t);

        await Assert.ThrowsAsync<GentegreHatasi>(() => depo.CekSenetGeriAlAsync(b, t, cek, baglam));

        // TAKAS: kasa işlemi yok, kıymet bankada; makbuz / bordro no elle.
        var s = await depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("takas", null, null, hesap, "BRD-7", null), baglam);
        Assert.Null(s.KasaIslemId);
        var c = (await CekAsync(b, t, cek))[0];
        Assert.Equal(30, Convert.ToInt32(c["durum"]));
        Assert.Equal(hesap, Convert.ToInt32(c["hesap_id"]));
        Assert.Equal("BRD-7", await b.TekDegerAsync<string>(
            "select belge_no from public.v_cek_senet_hareket where id = @p0", t, [s.HareketId], CancellationToken.None));
        // İŞLEM YERİ kasasız harekette hesap adı (1388 - fn_taraf_ad '' dönüyordu).
        Assert.Equal(await b.TekDegerAsync<string>("select ad from public.hesap where id = @p0", t, [hesap], CancellationToken.None),
                     await b.TekDegerAsync<string>("select islem_yeri from public.v_cek_senet_hareket where id = @p0", t,
                                                   [s.HareketId], CancellationToken.None));

        // Takastaki çek tahsil: hesap verilmezse takas bankası.
        var th = await depo.CekSenetIslemAsync(b, t, cek,
            new KasaDeposu.CekSenetIslemIstegi("tahsil", null, null, null, null, null), baglam);
        Assert.Equal(hesap, Convert.ToInt32((await KasaAsync(b, t, th.KasaIslemId!.Value))[0]["hesap_id"]));

        await t.RollbackAsync();
    }
}
