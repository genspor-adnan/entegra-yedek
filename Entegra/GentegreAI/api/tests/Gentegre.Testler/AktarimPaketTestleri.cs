using System.Net;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - PAKET (1086): <c>fn_aktar_paket</c> sırayı kendisi kurar (belge
/// carisiyle aynı pakette gelse de cari önce yazılır), tamamlanmış paket kimliği
/// ikinci kez uygulanmaz, CT versiyonu geri gitmez ve yalnız uygulanan adımların
/// tablolarında ilerler; hatalı adım ve sonrası durur, hata kuyruğunda deneme
/// sayılır, adım düzelince kapanır. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimPaketTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> PaketAsync(NpgsqlConnection b, NpgsqlTransaction t, int ajan, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               "select public.fn_aktar_paket(@p0, @p1::jsonb)::text", t, [ajan, paket], CancellationToken.None) ?? "{}")!;

    private static Task<long?> VersiyonAsync(NpgsqlConnection b, NpgsqlTransaction t, string tablo)
        => b.TekDegerAsync<long?>("select versiyon from public.aktarim_durum where tablo = @p0", t, [tablo], CancellationToken.None);

    private const string Cari = """{"id": 990005201, "kod": "AKT-P-CARI", "firma": "Aktarım Paket Carisi", "durum": 1, "vno": "9900000041"}""";
    private const string Fatura = """
        {"id": 990005301, "tur": 15, "tipi": 1, "rehberid": 990005201, "faturatarih": "2026-06-01T10:00:00",
         "faturano": "PKT-1", "fatura_tutari": 100}
        """;

    [VtFact]
    public async Task Paket_sirayi_kurar_tekrari_uygulamaz_versiyon_geri_gitmez_hatali_adimda_durur()
    {
        if (!_olgu.Baglandi(nameof(Paket_sirayi_kurar_tekrari_uygulamaz_versiyon_geri_gitmez_hatali_adimda_durur))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await b.CalistirAsync("delete from public.aktarim_durum", t, [], ct);
        await b.CalistirAsync("update public.aktarim_hata set cozulme = now() where cozulme is null", t, [], ct);
        var anahtar = await b.TekDegerAsync<string>("select public.fn_aktarim_ajan_ekle('test ajanı')", t, [], ct);
        var ajan = await b.TekDegerAsync<int>("select public.fn_aktarim_ajan_bul(@p0)", t, [anahtar], ct);
        Assert.Null(await b.TekDegerAsync<int?>("select public.fn_aktarim_ajan_bul('yanlis')", t, [], ct));

        // Belge carisinden ÖNCE yazılmış pakette bile cari önce işlenir.
        var ilkPaket = $$$"""
            {"paket": "tp-1", "V": {"REHBER": 100, "FATBASLIK": 50, "KASALAR": 7},
             "U": {"FATBASLIK": [{{{Fatura}}}], "REHBER": [{{{Cari}}}]}}
            """;
        var ilk = await PaketAsync(b, t, ajan, ilkPaket);
        Assert.Null(ilk["hata"]);
        Assert.Equal(1, ilk["sonuc"]!["fn_aktar_belge"]!["belge"]!.GetValue<int>());
        Assert.Equal("Aktarım Paket Carisi", await b.TekDegerAsync<string>("""
            select t.unvan from public.belge x join public.taraf t on t.id = x.taraf_id
             where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = 990005301
            """, t, [], ct));
        Assert.Equal(100L, await VersiyonAsync(b, t, "REHBER"));
        Assert.Equal(50L, await VersiyonAsync(b, t, "FATBASLIK"));
        Assert.Equal(7L, await VersiyonAsync(b, t, "KASALAR"));     // verisiz versiyon da ilerler

        // Aynı paket kimliği: uygulanmaz, kayıtlı sonuç döner.
        var tekrar = await PaketAsync(b, t, ajan, ilkPaket);
        Assert.True(tekrar["tekrar"]!.GetValue<bool>());
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.aktarim_paket where ajan_id = @p0", t, [ajan], ct));

        // Eski versiyonlu paket versiyonu geri götürmez.
        await PaketAsync(b, t, ajan, $$$"""{"paket": "tp-2", "V": {"REHBER": 90}, "U": {"REHBER": [{{{Cari}}}]}}""");
        Assert.Equal(100L, await VersiyonAsync(b, t, "REHBER"));

        // Bozuk cari: cari adımı ve SONRAKİ belge adımı uygulanmaz; önceki depo adımı uygulanır.
        var bozuk = $$$"""
            {"paket": "tp-3", "V": {"DEPOLAR": 5, "REHBER": 200, "FATBASLIK": 60},
             "U": {"DEPOLAR": [{"id": 990005001, "depoadi": "Aktarım paket deposu", "durum": 1}],
                   "REHBER": [{"id": "bozuk", "kod": "X"}],
                   "FATBASLIK": [{{{Fatura.Replace("PKT-1", "PKT-2")}}}]}}
            """;
        var hatali = await PaketAsync(b, t, ajan, bozuk);
        Assert.Equal("fn_aktar_cari", hatali["hata"]!["adim"]!.GetValue<string>());
        Assert.Equal(5L, await VersiyonAsync(b, t, "DEPOLAR"));
        Assert.Equal(100L, await VersiyonAsync(b, t, "REHBER"));
        Assert.Equal(50L, await VersiyonAsync(b, t, "FATBASLIK"));
        Assert.Equal("PKT-1", await b.TekDegerAsync<string>(
            "select belge_no from public.belge where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = 990005301",
            t, [], ct));
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.depo where aktarim_kaynak = 1 and aktarim_tablo = 'DEPOLAR' and aktarim_id = 990005001",
            t, [], ct));

        // Hatalı paket tamamlanmadı: aynı kimlik yeniden UYGULANIR, deneme artar.
        await PaketAsync(b, t, ajan, bozuk);
        Assert.Equal(2, await b.TekDegerAsync<int>(
            "select deneme from public.aktarim_hata where adim = 'fn_aktar_cari' and cozulme is null", t, [], ct));

        // Düzelen cari: hata kapanır, versiyonlar ilerler.
        Assert.Null((await PaketAsync(b, t, ajan, $$$"""
            {"paket": "tp-4", "V": {"REHBER": 200, "FATBASLIK": 60}, "U": {"REHBER": [{{{Cari}}}]}}
            """))["hata"]);
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.aktarim_hata where adim = 'fn_aktar_cari' and cozulme is null", t, [], ct));
        Assert.Equal(60L, await VersiyonAsync(b, t, "FATBASLIK"));

        // Bilinmeyen tablo: hiçbir şey yazılmadan reddedilir.
        var ex = await Assert.ThrowsAsync<PostgresException>(() =>
            PaketAsync(b, t, ajan, """{"paket": "tp-5", "U": {"BILINMEYEN": [{"id": 1}]}}"""));
        Assert.StartsWith("AKTARIM_TABLO", ex.MessageText);
        await t.RollbackAsync();
    }
}

/// <summary>
/// Gerçek API süreci: ajan uçları oturum değil makine anahtarı ister; bilinmeyen
/// tablo 400; tamamlanan paketin tekrarı uygulanmaz; durum versiyonu gösterir.
/// API kendi işlemini commit'ler - test kendi satırlarını siler.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class AktarimUcTestleri(ApiSunucuOlgusu api)
{
    [VtFact]
    public async Task Ajan_anahtarsiz_reddedilir_paket_uygulanir_tekrari_uygulanmaz()
    {
        await using var b = await api.Veri.AcAsync(CancellationToken.None);
        var ct = CancellationToken.None;
        var anahtar = (await b.TekDegerAsync<string>("select public.fn_aktarim_ajan_ekle('uç testi')", null, [], ct))!;
        var ajan = await b.TekDegerAsync<int>("select public.fn_aktarim_ajan_bul(@p0)", null, [anahtar], ct);
        var oncekiVersiyon = await b.TekDegerAsync<long?>(
            "select versiyon from public.aktarim_durum where tablo = 'DEPOLAR'", null, [], ct);
        try
        {
            using (var anonim = api.Istemci())
            {
                Assert.Equal(HttpStatusCode.Unauthorized, (await anonim.GetAsync("/api/aktarim/durum")).StatusCode);
                anonim.DefaultRequestHeaders.Add("X-Aktarim-Anahtar", "yanlis-anahtar");
                Assert.Equal(HttpStatusCode.Unauthorized,
                    (await anonim.PostAsync("/api/aktarim/paket", Json("""{"U": {}}"""))).StatusCode);
            }

            using var h = api.Istemci();
            h.DefaultRequestHeaders.Add("X-Aktarim-Anahtar", anahtar);

            var y = await h.PostAsync("/api/aktarim/paket", Json("""{"paket": "ut-0", "U": {"BILINMEYEN": []}}"""));
            Assert.Equal(HttpStatusCode.BadRequest, y.StatusCode);
            Assert.Equal("DOGRULAMA", await ApiSunucuOlgusu.HataKoduAsync(y));

            var versiyon = (oncekiVersiyon ?? 0) + 1;
            var paket = $$$"""
                {"paket": "ut-1", "V": {"DEPOLAR": {{{versiyon}}}},
                 "U": {"DEPOLAR": [{"id": 990005901, "depoadi": "Aktarım uç deposu", "durum": 1}]}}
                """;
            var ilk = await h.PostAsync("/api/aktarim/paket", Json(paket));
            Assert.Equal(HttpStatusCode.OK, ilk.StatusCode);
            var sonuc = await ilk.Content.ReadFromJsonAsync<JsonElement>();
            Assert.Equal(1, sonuc.GetProperty("sonuc").GetProperty("fn_aktar_depo").GetProperty("depo").GetInt32());

            var ikinci = await (await h.PostAsync("/api/aktarim/paket", Json(paket))).Content.ReadFromJsonAsync<JsonElement>();
            Assert.True(ikinci.GetProperty("tekrar").GetBoolean());

            var durum = await h.GetFromJsonAsync<JsonElement>("/api/aktarim/durum");
            Assert.Contains(durum.GetProperty("tablolar").EnumerateArray(),
                x => x.GetProperty("tablo").GetString() == "DEPOLAR" && x.GetProperty("versiyon").GetInt64() == versiyon);
            Assert.Equal(13, durum.GetProperty("adimlar").GetArrayLength());
        }
        finally
        {
            await b.CalistirAsync(
                "delete from public.depo where aktarim_kaynak = 1 and aktarim_tablo = 'DEPOLAR' and aktarim_id = 990005901",
                null, [], ct);
            if (oncekiVersiyon is null)
                await b.CalistirAsync("delete from public.aktarim_durum where tablo = 'DEPOLAR'", null, [], ct);
            else
                await b.CalistirAsync("update public.aktarim_durum set versiyon = @p0 where tablo = 'DEPOLAR'",
                                      null, [oncekiVersiyon], ct);
            await b.CalistirAsync("update public.aktarim_durum set son_paket_id = null where son_paket_id in " +
                                  "(select id from public.aktarim_paket where ajan_id = @p0)", null, [ajan], ct);
            await b.CalistirAsync("delete from public.aktarim_hata where ajan_id = @p0", null, [ajan], ct);
            await b.CalistirAsync("delete from public.aktarim_paket where ajan_id = @p0", null, [ajan], ct);
            await b.CalistirAsync("delete from public.aktarim_ajan where id = @p0", null, [ajan], ct);
        }
    }

    private static StringContent Json(string s) => new(s, Encoding.UTF8, "application/json");
}
