using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - CARİ ve DEPO (1081, dokuman/18 §11 adım 3).
///
/// Paket ajanın göndereceği biçimdedir: {"U": {"REHBER": [...], ...}, "D": {...}},
/// satır anahtarları MSSQL kolon adlarının küçük harflisi. Her test bir işlem
/// içinde çalışır ve geri alınır; sahte Delphi kimlikleri gerçek veriyle
/// çakışmasın diye çok yüksek seçilir.
///
/// Eşdeğerlik (BILIM'in tamamı ↔ göç sonucu) ayrıca db/araclar/aktarim_esdegerlik.sql
/// ile ölçülür; burada davranış kuralları sabitlenir.
/// </summary>
public sealed class AktarimCariDepoTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private const int Cari = 990_000_001;
    private const int Iletisim = 990_000_101;

    private static string Paket(string firma = "TEST AKTARIM A.Ş.", string vkno = "9900000011",
                                string tel = "0212 555 00 00", bool iletisimli = true)
    {
        var u = new JsonObject
        {
            ["REHBER"] = new JsonArray(new JsonObject
            {
                ["id"] = Cari, ["kod"] = "AKT-TEST-1", ["firma"] = firma, ["durum"] = 1,
                ["subeid"] = -1, ["eklemetarihi"] = "2026-10-01T09:30:00",
            }),
            ["REHBERILETISIM"] = iletisimli
                ? new JsonArray(new JsonObject
                  {
                      ["id"] = Iletisim, ["rehberid"] = Cari, ["ad"] = "Merkez",
                      ["varsayilan"] = 1, ["aktif"] = 1, ["subeid"] = -1,
                  })
                : new JsonArray(),
            ["REHBERBILGI"] = new JsonArray(
                new JsonObject { ["id"] = 990_000_201, ["yeri"] = 2, ["yer_id"] = Cari, ["sira"] = 1,
                                 ["etiket"] = "Vergi No", ["bilgi"] = vkno },
                new JsonObject { ["id"] = 990_000_202, ["yeri"] = 1, ["yer_id"] = Iletisim, ["sira"] = 1,
                                 ["etiket"] = "Adres", ["bilgi"] = "Test Cad. No:1" },
                new JsonObject { ["id"] = 990_000_203, ["yeri"] = 1, ["yer_id"] = Iletisim, ["sira"] = 2,
                                 ["etiket"] = "İş Tel", ["bilgi"] = tel }),
        };
        return new JsonObject { ["U"] = u }.ToJsonString();
    }

    private static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    /// <summary>TekAsync başvuru tipi ister (tuple kabul etmez).</summary>
    private sealed record KartSatiri(string Unvan, string Vkno, string Tel, short Musteri, int Sube, long Adres);

    [VtFact]
    public async Task Cari_eklenir_tekrar_gelince_yazilmaz_degisince_guncellenir()
    {
        if (!_olgu.Baglandi(nameof(Cari_eklenir_tekrar_gelince_yazilmaz_degisince_guncellenir))) return;
        var veri = _olgu.Gerekli();
        await using var b = await veri.AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        var ilk = await AktarAsync(b, t, "fn_aktar_cari", Paket());
        Assert.Equal(1, Sayi(ilk, "taraf"));
        Assert.Equal(1, Sayi(ilk, "adres"));

        var kart = await b.TekAsync("""
            select t.unvan, t.vkno, t.telefon, t.musteri, t.durum, t.sube_id,
                   (select count(*) from public.taraf_adres a where a.taraf_id = t.id and a.aktif = 1)
              from public.taraf t where t.aktarim_kaynak = 1 and t.aktarim_tablo = 'REHBER' and t.aktarim_id = @p0
            """, t, [Cari], o => new KartSatiri(o.GetString(0), o.GetString(1), o.GetString(2),
                                                 o.GetInt16(3), o.GetInt32(5), o.GetInt64(6)), ct);
        Assert.NotNull(kart);
        Assert.Equal("TEST AKTARIM A.Ş.", kart!.Unvan);
        Assert.Equal("9900000011", kart!.Vkno);
        Assert.Equal("0212 555 00 00", kart!.Tel);    // varsayılan lokasyondan
        Assert.Equal(1, kart!.Musteri);
        Assert.Equal(1, kart!.Adres);
        Assert.True(kart!.Sube > 0);                  // SUBEID -1 -> varsayılan şube

        // Aynı paket: hiçbir şey yazılmaz (degistirme_tarihi tetiği boşuna çalışmaz).
        var ikinci = await AktarAsync(b, t, "fn_aktar_cari", Paket());
        Assert.Equal(0, Sayi(ikinci, "taraf"));
        Assert.Equal(0, Sayi(ikinci, "adres"));

        // Değişiklik yansır.
        var ucuncu = await AktarAsync(b, t, "fn_aktar_cari", Paket(firma: "TEST AKTARIM LTD.", tel: "0212 555 11 11"));
        Assert.Equal(1, Sayi(ucuncu, "taraf"));
        Assert.Equal("TEST AKTARIM LTD.", await b.TekDegerAsync<string>(
            "select unvan from public.taraf where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = @p0",
            t, [Cari], ct));

        // Delphi'de silinen adres -> pasif (belgede kullanılmış olabilir).
        var dorduncu = await AktarAsync(b, t, "fn_aktar_cari", Paket(iletisimli: false));
        Assert.Equal(1, Sayi(dorduncu, "adres_pasif"));

        // Delphi'de silinen cari -> pasif.
        var sil = await AktarAsync(b, t, "fn_aktar_cari", "{\"D\": {\"REHBER\": [" + Cari + "]}}");
        Assert.Equal(1, Sayi(sil, "taraf_pasif"));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Web_in_personel_karti_Delphi_verisiyle_ezilmez()
    {
        if (!_olgu.Baglandi(nameof(Web_in_personel_karti_Delphi_verisiyle_ezilmez))) return;
        var veri = _olgu.Gerekli();
        await using var b = await veri.AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await AktarAsync(b, t, "fn_aktar_cari", Paket());
        await b.CalistirAsync("""
            update public.taraf set personel = 1, unvan = 'Dr.'
             where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = @p0
            """, t, [Cari], ct);

        var sonuc = await AktarAsync(b, t, "fn_aktar_cari", Paket(firma: "BAŞKA AD"));
        Assert.Equal(1, Sayi(sonuc, "web_sahipli"));
        Assert.Equal(0, Sayi(sonuc, "taraf"));
        Assert.Equal("Dr.", await b.TekDegerAsync<string>(
            "select unvan from public.taraf where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = @p0",
            t, [Cari], ct));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Birden_cok_varsayilan_depoda_en_kucuk_Delphi_kimligi_kazanir()
    {
        if (!_olgu.Baglandi(nameof(Birden_cok_varsayilan_depoda_en_kucuk_Delphi_kimligi_kazanir))) return;
        var veri = _olgu.Gerekli();
        await using var b = await veri.AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // BILIM'de 4 varsayılan depo var; web tek varsayılan kabul eder.
        var sonuc = await AktarAsync(b, t, "fn_aktar_depo", """
            {"U": {"DEPOLAR": [
              {"id": 990000003, "depoadi": "AKT Depo C", "durum": 1, "varsayilan": 1, "subeid": -1},
              {"id": 990000001, "depoadi": "AKT Depo A", "durum": 1, "varsayilan": 1, "subeid": -1},
              {"id": 990000002, "depoadi": "AKT Depo B", "durum": 1, "varsayilan": 0, "subeid": -1,
               "sonsayimtarihi": "1900-01-01T00:00:00"}]}}
            """);
        Assert.Equal(3, Sayi(sonuc, "depo"));
        Assert.Equal(990000001L, await b.TekDegerAsync<long>(
            "select aktarim_id from public.depo where varsayilan = 1", t, [], ct));
        // Delphi "boş tarih" (1900) boş kalır.
        Assert.Null(await b.TekDegerAsync<DateTime?>(
            "select son_sayim_tarihi from public.depo where aktarim_kaynak = 1 and aktarim_id = 990000002", t, [], ct));

        // Varsayılan depo Delphi'de silinirse önce varsayılanlığı kalkar, sonra pasifleşir.
        var sil = await AktarAsync(b, t, "fn_aktar_depo", """{"D": {"DEPOLAR": [990000001]}}""");
        Assert.Equal(1, Sayi(sil, "depo_pasif"));

        await t.RollbackAsync();
    }
}
