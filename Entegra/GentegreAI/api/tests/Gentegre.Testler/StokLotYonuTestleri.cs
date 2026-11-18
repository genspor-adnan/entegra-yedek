using System.Net.Http.Json;
using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// STOK / BELGE İNCELEMESİ 18.11.2026 bulgu 1-4 (1368) ve 5, 7-10 (1369): lot bakiyesi stokla aynı yön ve depoda yürür.
///  1 taslak lot bakiyesine dokunmaz, kesinleşince işlenir, silinince iz kalmaz · 2 satış / alış iadesinde lot
///  stokla aynı yönde · 3 korunan satırlı belge düzenlenince lot erimez · 4 iki depolu giriş belgesinin geri alması
///  yazıldığı depodan. Sonra: tüketilmiş giriş düzenlenince tüketim yeni izleme taşınır · transfer
///  (ters yönlü iki satır) geri alınır · sayım fişi sayımın şubesine yazılır.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class StokLotYonuTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private static readonly string Tarih = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:00");

    private sealed record Ortam(HttpClient H, int DepoA, int DepoB, int Stok, int Tedarikci, int Musteri, int Kullanici = 0, string Kod = "");

    private async Task<Ortam> OrtamAsync(TestDunyasi d, int izleme = 2)
    {
        var rol = await d.RolAsync("stoklot", "belge:gedk", "belge.alis.irsaliye:gedk", "belge.satis.irsaliye:gedk", "belge.satis.fatura:gedk", "stok:g",
                                  "belge.stok.transfer:gedk", "belge.stok.giris:gedk", "belge.stok.cikis:gedk", "stok.sayim:gedk");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        async Task<int> Depo(string ad)
        {
            var id = await api.Veri.TekDegerAsync<int>(
                "insert into public.depo (ad, durum, sube_id) values (@p0, 1, @p1) returning id", [d.Onek + ad, Merkez]);
            d.Temizle($"delete from public.stok_durum where depo_id = {id}");
            d.Temizle($"delete from public.stok_lot_durum where depo_id = {id}");
            d.Temizle($"delete from public.depo where id = {id}");
            return id;
        }
        var a = await Depo(" A");
        var b = await Depo(" B");
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, @p2, @p3) returning id",
            [d.Onek + "-LOT", d.Onek + " lotlu stok", (short)izleme, Merkez]);
        d.Temizle($"delete from public.stok_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok_lot_durum where stok_id = {stok}");
        d.Temizle($"delete from public.stok_seri_lot where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        async Task<int> Taraf(string rolKolon)
        {
            var id = await api.Veri.TekDegerAsync<int>(
                $"insert into public.taraf (unvan, {rolKolon}, durum, sube_id) values (@p0, 1, 1, @p1) returning id",
                [d.Onek + " " + rolKolon, Merkez]);
            d.Temizle($"delete from public.taraf where id = {id}");
            return id;
        }
        return new Ortam(api.Istemci(access, Merkez), a, b, stok, await Taraf("tedarikci"), await Taraf("musteri"), u, kod);
    }

    private async Task<int> YazAsync(TestDunyasi d, Ortam o, object belge, object[] satirlar, bool taslak = false, int? id = null)
    {
        var govde = new { surum = id is null ? null : await Surum(id.Value), belge, satirlar, secenekler = new { taslak } };
        var y = id is null ? await o.H.PostAsJsonAsync("/api/belge/", govde) : await o.H.PutAsJsonAsync($"/api/belge/{id}", govde);
        var g = await y.Content.ReadAsStringAsync();
        Assert.True(y.IsSuccessStatusCode, $"{(int)y.StatusCode} {g}");
        var yeni = JsonDocument.Parse(g).RootElement.GetProperty("belge").GetProperty("id").GetInt32();
        if (id is null)
        {
            d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {yeni}");
            d.Temizle($"delete from public.mali_hareket where belge_id = {yeni}");
            d.Temizle($"delete from public.stok_izleme where belge_id = {yeni}");
            d.Temizle($"delete from public.belge_satir where belge_id = {yeni}");
            d.Temizle($"delete from public.belge where id = {yeni}");
        }
        return yeni;
    }

    private Task<string> Surum(int id) => api.Veri.TekDegerAsync<string>("select xmin::text from public.belge where id = @p0", [id])!;

    private Task<decimal> Lot(Ortam o, int depo) => api.Veri.TekDegerAsync<decimal>(
        "select coalesce(sum(kalan), 0) from public.stok_lot_durum where stok_id = @p0 and depo_id = @p1", [o.Stok, depo]);

    private Task<decimal> Stok(Ortam o, int depo) => api.Veri.TekDegerAsync<decimal>(
        "select coalesce(sum(kalan), 0) from public.stok_durum where stok_id = @p0 and depo_id = @p1", [o.Stok, depo]);

    private object AlisIrsaliyesi(Ortam o, string no, int tipi = 1, int? cikisDepo = null)
        => new { tur = 10, tipi, belgeTarihi = Tarih, tarafId = o.Tedarikci, girisDepoId = o.DepoA, cikisDepoId = cikisDepo, belgeNo = no };

    private static object LotSatiri(int stok, decimal adet, object izlem, int? id = null)
        => new { satirId = id, tur = 1, stokId = stok, adet, miktar = adet, birimFiyat = 10, izlemler = new[] { izlem } };

    [VtFact]
    public async Task Taslak_lot_bakiyesine_dokunmaz_kesinlesince_islenir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var satir = new[] { LotSatiri(o.Stok, 10, new { lotNo = "L-TSL", miktar = 10 }) };

        var id = await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: true);
        Assert.Equal(0m, await Lot(o, o.DepoA));                       // eskiden 10 (stok 0)
        await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: true, id: id);
        Assert.Equal(0m, await Lot(o, o.DepoA));                       // eskiden 20
        await YazAsync(d, o, AlisIrsaliyesi(o, "TS" + d.Onek[^6..]), satir, taslak: false, id: id);
        Assert.Equal(10m, await Lot(o, o.DepoA));
        Assert.Equal(10m, await Stok(o, o.DepoA));

        var sil = await o.H.DeleteAsync($"/api/belge/{id}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(0m, await Lot(o, o.DepoA));
        Assert.Equal(0m, await Stok(o, o.DepoA));
    }

    [VtFact]
    public async Task Iadede_lot_stokla_ayni_yonde()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        await YazAsync(d, o, AlisIrsaliyesi(o, "GR" + d.Onek[^6..]), [LotSatiri(o.Stok, 10, new { lotNo = "L-IAD", miktar = 10 })]);
        var lot = await api.Veri.TekDegerAsync<int>(
            "select id from public.stok_seri_lot where stok_id = @p0 and lot_no = 'L-IAD'", [o.Stok]);
        Assert.Equal(10m, await Lot(o, o.DepoA));

        // Satış İADESİ (14, tipi 2): mal GİRER - istemci lotu stoktakilerden SEÇER (seriLotId).
        var iade = await YazAsync(d, o,
            new { tur = 14, tipi = 2, belgeTarihi = Tarih, tarafId = o.Musteri, cikisDepoId = o.DepoA },
            [LotSatiri(o.Stok, 3, new { seriLotId = lot, miktar = 3 })]);
        Assert.Equal(13m, await Stok(o, o.DepoA));
        Assert.Equal(13m, await Lot(o, o.DepoA));                      // eskiden 7 (lot düşüyordu)

        // Alış İADESİ (10, tipi 2): mal ÇIKAR - istemci lotu giriş penceresinden YAZAR (lotNo).
        await YazAsync(d, o, AlisIrsaliyesi(o, "AI" + d.Onek[^6..], tipi: 2),
            [LotSatiri(o.Stok, 2, new { lotNo = "L-IAD", miktar = 2 })]);
        Assert.Equal(11m, await Stok(o, o.DepoA));
        Assert.Equal(11m, await Lot(o, o.DepoA));                      // eskiden 15 (lot ekleniyordu)

        // İadeyi silmek yazdığını geri alır.
        var sil = await o.H.DeleteAsync($"/api/belge/{iade}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(8m, await Stok(o, o.DepoA));
        Assert.Equal(8m, await Lot(o, o.DepoA));
    }

    [VtFact]
    public async Task Korunan_satirli_belge_duzenlenince_lot_erimez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var no = "KR" + d.Onek[^6..];
        var id = await YazAsync(d, o, AlisIrsaliyesi(o, no), [LotSatiri(o.Stok, 5, new { lotNo = "L-KOR", miktar = 5 })]);
        var satirId = await api.Veri.TekDegerAsync<int>("select id from public.belge_satir where belge_id = @p0", [id]);
        // ÜTS bildirimi satırı korur (silinip yeniden yazılmaz).
        var uts = await api.Veri.TekDegerAsync<int>("""
            insert into public.uts_bildirim (id, tur, sube_id, belge_satir_id)
            values ((select coalesce(max(id), 0) + 1 from public.uts_bildirim), 1, 1, @p0) returning id
            """, [satirId]);
        d.Temizle($"delete from public.uts_bildirim where id = {uts}");
        Assert.Equal(5m, await Lot(o, o.DepoA));

        var satir = new[] { LotSatiri(o.Stok, 5, new { lotNo = "L-KOR", miktar = 5 }, satirId) };
        await YazAsync(d, o, AlisIrsaliyesi(o, no), satir, id: id);
        await YazAsync(d, o, AlisIrsaliyesi(o, no), satir, id: id);
        Assert.Equal(5m, await Stok(o, o.DepoA));
        Assert.Equal(5m, await Lot(o, o.DepoA));                       // eskiden her kayıtta -5
    }

    [VtFact]
    public async Task Iki_depolu_giris_belgesi_yazdigi_depodan_geri_alinir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        var id = await YazAsync(d, o, AlisIrsaliyesi(o, "ID" + d.Onek[^6..], cikisDepo: o.DepoB),
            [new { tur = 1, stokId = o.Stok, adet = 10, miktar = 10, birimFiyat = 10 }]);
        Assert.Equal(10m, await Stok(o, o.DepoA));
        var sil = await o.H.DeleteAsync($"/api/belge/{id}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(0m, await Stok(o, o.DepoA));                      // eskiden A'da +10 kalıyordu
        Assert.Equal(0m, await Stok(o, o.DepoB));                      // ve B -10'a düşüyordu
    }

    private object SatisIrsaliyesi(Ortam o, int tipi = 1)
        => new { tur = 14, tipi, belgeTarihi = Tarih, tarafId = o.Musteri, cikisDepoId = o.DepoA };

    [VtFact]
    public async Task Taslaktan_kesine_belge_numara_alir_ve_tur_degismez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        await YazAsync(d, o, AlisIrsaliyesi(o, "NG" + d.Onek[^6..]), [new { tur = 1, stokId = o.Stok, adet = 10, miktar = 10, birimFiyat = 10 }]);
        var satir = new[] { new { tur = 1, stokId = o.Stok, adet = 2, miktar = 2, birimFiyat = 15 } };
        var id = await YazAsync(d, o, SatisIrsaliyesi(o), satir, taslak: true);
        Assert.Equal("", await api.Veri.TekDegerAsync<string>("select coalesce(belge_no, '') from public.belge where id = @p0", [id]));
        await YazAsync(d, o, SatisIrsaliyesi(o), satir, taslak: false, id: id);
        Assert.NotEqual("", await api.Veri.TekDegerAsync<string>("select coalesce(belge_no, '') from public.belge where id = @p0", [id]));

        // 7) PUT türü değiştiremez (irsaliye -> fatura): dönüşüm kuralları atlanırdı.
        var y = await o.H.PutAsJsonAsync($"/api/belge/{id}", new
        {
            surum = await Surum(id), satirlar = satir,
            belge = new { tur = 15, tipi = 1, belgeTarihi = Tarih, tarafId = o.Musteri, cikisDepoId = o.DepoA },
        });
        Assert.Equal(System.Net.HttpStatusCode.UnprocessableEntity, y.StatusCode);
        Assert.Equal(14, await api.Veri.TekDegerAsync<int>("select tur::int from public.belge where id = @p0", [id]));
    }

    [VtFact]
    public async Task Stok_hareketi_iade_yonunu_ve_depo_bakiyesini_tutar()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        await YazAsync(d, o, AlisIrsaliyesi(o, "HR" + d.Onek[^6..], cikisDepo: o.DepoB),
            [new { tur = 1, stokId = o.Stok, adet = 10, miktar = 10, birimFiyat = 10 }]);
        await YazAsync(d, o, SatisIrsaliyesi(o, tipi: 2), [new { tur = 1, stokId = o.Stok, adet = 3, miktar = 3, birimFiyat = 10 }]);
        Assert.Equal(13m, await Stok(o, o.DepoA));

        var h = await o.H.GetFromJsonAsync<JsonElement>($"/api/kart/stok/{o.Stok}/hareket?bas=2000-01-01");
        Assert.Equal(13m, h.GetProperty("kapanis").GetDecimal());                     // eskiden iade çıkış: 10 - 3
        var yonler = h.GetProperty("satirlar").EnumerateArray().Select(x => x.GetProperty("yon").GetString()).ToList();
        Assert.Equal(["giris", "giris"], yonler);                                   // iki depolu giriş "transfer" değil
    }

    [VtFact]
    public async Task Yan_okuma_uclari_sube_kapisindan_gecer()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        var baskaSube = await api.Veri.TekDegerAsync<int>("select id from public.sube where id <> @p0 order by id limit 1", [Merkez]);
        var baska = await api.Veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, durum, belge_tarihi, taraf_id, sube_id, belge_no, kdv_durum, belge_dovizi, rapor_dovizi, doviz_kuru)
            values (14, 1, 0, now(), @p0, @p1, 'SUBEB', 'Hariç', 'TL', 'TL', 1) returning id
            """, [o.Musteri, baskaSube]);
        d.Temizle($"delete from public.belge where id = {baska}");
        foreach (var yol in new[] { "acik-satirlar", "donusumler", "diptoplam" })
            Assert.Equal(System.Net.HttpStatusCode.NotFound, (await o.H.GetAsync($"/api/belge/{baska}/{yol}")).StatusCode);
        Assert.Equal(System.Net.HttpStatusCode.BadRequest, (await o.H.GetAsync("/api/belge/iade-satirlari?tarafId=0")).StatusCode);
    }

    [VtFact]
    public async Task Cikis_duzenlenip_silinince_kaynak_girisin_kalani_geri_verilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var giris = await YazAsync(d, o, AlisIrsaliyesi(o, "KZ" + d.Onek[^6..]), [LotSatiri(o.Stok, 10, new { lotNo = "L-KZ", miktar = 10 })]);
        var lot = await api.Veri.TekDegerAsync<int>("select id from public.stok_seri_lot where stok_id = @p0 and lot_no = 'L-KZ'", [o.Stok]);
        Task<decimal> KaynakKalan() => api.Veri.TekDegerAsync<decimal>(
            "select kalan from public.stok_izleme where belge_id = @p0", [giris]);

        var satir = new[] { LotSatiri(o.Stok, 4, new { seriLotId = lot, miktar = 4 }) };
        var cikis = await YazAsync(d, o, SatisIrsaliyesi(o), satir);
        Assert.Equal(6m, await KaynakKalan());
        await YazAsync(d, o, SatisIrsaliyesi(o), satir, id: cikis);
        await YazAsync(d, o, SatisIrsaliyesi(o), satir, id: cikis);
        Assert.Equal(6m, await KaynakKalan());                                     // eskiden her kayıtta -4 (0'a iner)
        var sil = await o.H.DeleteAsync($"/api/belge/{cikis}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(10m, await KaynakKalan());
        Assert.Equal(10m, await Lot(o, o.DepoA));
    }

    [VtFact]
    public async Task Tuketilmis_giris_duzenlenince_tuketim_yeni_izleme_tasinir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d);
        using var _ = o.H;
        var no = "TT" + d.Onek[^6..];
        var giris = await YazAsync(d, o, AlisIrsaliyesi(o, no), [LotSatiri(o.Stok, 10, new { lotNo = "L-TT", miktar = 10 })]);
        var lot = await api.Veri.TekDegerAsync<int>("select id from public.stok_seri_lot where stok_id = @p0 and lot_no = 'L-TT'", [o.Stok]);
        var cikis = await YazAsync(d, o, SatisIrsaliyesi(o), [LotSatiri(o.Stok, 4, new { seriLotId = lot, miktar = 4 })]);

        // Giriş düzenlenir (miktar 12): izlem yeni kimlikle yazılır, tüketim (4) taşınır.
        await YazAsync(d, o, AlisIrsaliyesi(o, no), [LotSatiri(o.Stok, 12, new { lotNo = "L-TT", miktar = 12 })], id: giris);
        var (yeniId, kalan) = (await api.Veri.TekDegerAsync<int>("select id from public.stok_izleme where belge_id = @p0", [giris]),
                               await api.Veri.TekDegerAsync<decimal>("select kalan from public.stok_izleme where belge_id = @p0", [giris]));
        Assert.Equal(8m, kalan);                                                    // eskiden 12 (aynı mal yeniden tüketilebilir)
        Assert.Equal(yeniId, await api.Veri.TekDegerAsync<int>(
            "select (kaynak_dagilim -> 0 ->> 'id')::int from public.stok_izleme where belge_id = @p0", [cikis]));
        Assert.Equal(yeniId, await api.Veri.TekDegerAsync<int>(
            "select donus_id from public.stok_izleme where belge_id = @p0", [cikis]));

        var sil = await o.H.DeleteAsync($"/api/belge/{cikis}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal(12m, await api.Veri.TekDegerAsync<decimal>("select kalan from public.stok_izleme where belge_id = @p0", [giris]));
        Assert.Equal(12m, await Lot(o, o.DepoA));
    }

    [VtFact]
    public async Task Ters_yonlu_iki_satirli_transfer_geri_alinir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        await YazAsync(d, o, AlisIrsaliyesi(o, "AT" + d.Onek[^6..]), [new { tur = 1, stokId = o.Stok, adet = 10, miktar = 10, birimFiyat = 10 }]);
        Task<string?> Durum(int depo) => api.Veri.TekDegerAsync<string>(
            "select giren::numeric(10,0) || '/' || cikan::numeric(10,0) || '/' || kalan::numeric(10,0) from public.stok_durum where stok_id = @p0 and depo_id = @p1",
            [o.Stok, depo]);
        Assert.Equal("10/0/10", await Durum(o.DepoA));
        // Aynı stok iki satırda ters yönde: A→B 3 (başlık), B→A 2 (satır deposu). Geri almada çıkış ve varış
        //   güncellemeleri aynı stok_durum satırlarına düşer - eskiden tek komutta biri kayboluyordu.
        var tr = await YazAsync(d, o, new { tur = 20, tipi = 1, belgeTarihi = Tarih, cikisDepoId = o.DepoA, girisDepoId = o.DepoB,
                  teslimEdenId = o.Tedarikci, teslimAlanId = o.Musteri },
            [new { tur = 1, stokId = o.Stok, adet = 3, miktar = 3, birimFiyat = 10 },
             new { tur = 1, stokId = o.Stok, adet = 2, miktar = 2, birimFiyat = 10, cikisDepoId = o.DepoB, girisDepoId = o.DepoA }]);
        Assert.Equal("12/3/9", await Durum(o.DepoA));
        Assert.Equal("3/2/1", await Durum(o.DepoB));
        var sil = await o.H.DeleteAsync($"/api/belge/{tr}");
        Assert.True(sil.IsSuccessStatusCode, await sil.Content.ReadAsStringAsync());
        Assert.Equal("10/0/10", await Durum(o.DepoA));
        Assert.Equal("0/0/0", await Durum(o.DepoB));
    }

    [VtFact]
    public async Task Sayim_fisi_sayimin_subesine_yazilir()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        var diger = await api.Veri.TekDegerAsync<int>("select min(id) from public.sube where id <> @p0", [Merkez]);
        await d.SubeVerAsync(o.Kullanici, diger, yazma: true);          // kullanıcı iki şubeye erişir, aktif şube Merkez
        // Sayım DİĞER şubede açılmış (oturum açmak ilk oturumu düşürür - başlık doğrudan yazılır).
        var sayim = await api.Veri.TekDegerAsync<int>("""
            insert into public.stok_sayim (sube_id, depo_id, kapsam, aciklama, ekleyen, sayim_no)
            values (@p0, @p1, 2, '', @p2, @p3) returning id
            """, [diger, o.DepoB, o.Kullanici, "SYM-" + d.Onek[^6..]]);
        await api.Veri.CalistirAsync(
            "insert into public.stok_sayim_satir (sayim_id, stok_id, sistem, sayilan) values (@p0, @p1, 0, 3)", [sayim, o.Stok]);

        var kapat = await o.H.PostAsync($"/api/stok-sayim/{sayim}/kapat", null);   // Merkez oturumundan kapatılır
        var kG = await kapat.Content.ReadAsStringAsync();
        var fis = kapat.IsSuccessStatusCode ? JsonDocument.Parse(kG).RootElement.GetProperty("girisBelgeId").GetInt32() : 0;
        if (fis > 0)
        {
            d.Temizle($"delete from public.islem_log where tablo_id = 30 and kayit_id = {fis}");
            d.Temizle($"delete from public.stok_izleme where belge_id = {fis}");
            d.Temizle($"delete from public.belge_satir where belge_id = {fis}");
            d.Temizle($"delete from public.belge where id = {fis}");
        }
        d.Temizle($"delete from public.islem_log where tablo_id = 1620 and kayit_id = {sayim}");
        d.Temizle($"delete from public.stok_sayim_satir where sayim_id = {sayim}");
        d.Temizle($"delete from public.stok_sayim where id = {sayim}");
        Assert.True(kapat.IsSuccessStatusCode, kG);
        Assert.Equal(diger, await api.Veri.TekDegerAsync<int>("select sube_id from public.belge where id = @p0", [fis]));   // eskiden Merkez
    }

    /// <summary>WEB İNCELEMESİ 18.11.2026 (2): belge PUT'u sürüm denetler - eski sürümle kayıt 409, satırlar değişmez.</summary>
    [VtFact]
    public async Task Belge_PUT_eski_surumle_409_doner_satirlar_ezilmez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var o = await OrtamAsync(d, izleme: 0);
        using var _ = o.H;
        var no = "SR" + d.Onek[^6..];
        object Satir(decimal m) => new { tur = 1, stokId = o.Stok, adet = m, miktar = m, birimFiyat = 10 };
        var id = await YazAsync(d, o, AlisIrsaliyesi(o, no), [Satir(5)]);
        var eskiSurum = await Surum(id);

        // Öteki kullanıcı kaydetti (güncel sürümle).
        await YazAsync(d, o, AlisIrsaliyesi(o, no), [Satir(5), Satir(7)], id: id);
        // Bu kullanıcı eski kopyasıyla kaydediyor.
        var y = await o.H.PutAsJsonAsync($"/api/belge/{id}",
            new { surum = eskiSurum, belge = AlisIrsaliyesi(o, no), satirlar = new[] { Satir(5) }, secenekler = new { taslak = false } });
        Assert.Equal(System.Net.HttpStatusCode.Conflict, y.StatusCode);                          // eskiden 200, satır 7 silinirdi
        Assert.Equal(2L, await api.Veri.TekDegerAsync<long>("select count(*) from public.belge_satir where belge_id = @p0", [id]));
        Assert.Equal(12m, await Stok(o, o.DepoA));

        // Sürüm gönderilmezse (iç akış / eski istemci) denetim yok.
        var z = await o.H.PutAsJsonAsync($"/api/belge/{id}",
            new { belge = AlisIrsaliyesi(o, no), satirlar = new[] { Satir(5), Satir(7) }, secenekler = new { taslak = false } });
        Assert.True(z.IsSuccessStatusCode, await z.Content.ReadAsStringAsync());
    }
}
