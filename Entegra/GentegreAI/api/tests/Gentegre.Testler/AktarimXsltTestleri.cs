using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - e-BELGE XSLT ŞABLONLARI (1266): <c>fn_aktar_xslt</c> DOKUMLER (GRUBU XSLT) satırını
/// dokuman (ebelge-xslt, tür / yön RAPORID'den) + dokuman_icerik (sha256 BÜYÜK hex) yapar; tür-yön için ilk şablon
/// varsayılan olur, web'de seçilmiş varsayılan korunur; içerik değişince hash / boyut güncellenir; XSLT olmayan ve
/// bilinmeyen RAPORID atlanır; D siler. Ayrıca 1267: satırlı belge silinemez (fn_belge_silinebilir).
/// İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimXsltTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> FnAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private const int XsltId = 990007001;

    private static string Paket(string icerik, int raporid = 2, string grubu = "XSLT", int varsayilan = 0)
        => "{\"U\": {\"DOKUMLER\": [{\"id\": " + XsltId + ", \"raporadi\": \"Test e-Fatura XSLT\", \"grubu\": \"" + grubu
           + "\", \"raporid\": " + raporid + ", \"varsayilan\": " + varsayilan + ", \"sql\": \"" + icerik
           + "\", \"durum\": 1, \"eklemetarihi\": \"2026-06-01T09:00:00\"},"
           + "{\"id\": " + (XsltId + 1) + ", \"raporadi\": \"Rapor\", \"grubu\": \"RAPOR\", \"raporid\": 0, \"sql\": \"select 1\"},"
           + "{\"id\": " + (XsltId + 2) + ", \"raporadi\": \"Bilinmeyen tür\", \"grubu\": \"XSLT\", \"raporid\": 99, \"sql\": \"<x/>\"}]}}";

    [VtFact]
    public async Task Xslt_dokumana_yazilir_varsayilan_kurali_icerik_guncellenir_D_siler()
    {
        if (!_olgu.Baglandi(nameof(Xslt_dokumana_yazilir_varsayilan_kurali_icerik_guncellenir_D_siler))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        Assert.Equal(15, await b.TekDegerAsync<int>(
            "select sira from public.fn_aktarim_adimlari() where fonksiyon = 'fn_aktar_xslt'", t, [], ct));
        // Varsayılan kuralı deterministik olsun: bu tür-yön için mevcut varsayılan yok sayılır (işlem içinde).
        await b.CalistirAsync("update public.dokuman set varsayilan = 0 where kaynak = 'ebelge-xslt' and kaynak_id = 1 and yon = 2", t, [], ct);

        var ilk = await FnAsync(b, t, "fn_aktar_xslt", Paket("<xsl:stylesheet version=\\\"1.0\\\"/>"));
        Assert.Equal(1, ilk["eklenen"]!.GetValue<int>());
        Assert.Equal(2, ilk["atlanan"]!.GetValue<int>());          // RAPOR grubu + bilinmeyen RAPORID
        Assert.Equal(1, ilk["varsayilan_atanan"]!.GetValue<int>());
        var d = await b.TekAsync<DokumanSatiri>("""
            select d.id, d.kaynak_id, d.yon, d.varsayilan, d.belge_turu, d.hash, d.boyut, d.content_type,
                   convert_from(i.icerik, 'UTF8')
              from public.dokuman d join public.dokuman_icerik i on i.hash = d.hash
             where d.kaynak = 'ebelge-xslt' and d.aktarim_kaynak = 1 and d.aktarim_tablo = 'DOKUMLER' and d.aktarim_id = @p0
            """, t, [(long)XsltId], o => new DokumanSatiri(o.GetInt32(0), o.GetInt32(1), o.GetInt16(2), o.GetInt16(3),
                                                           o.GetString(4), o.GetString(5), o.GetInt32(6), o.GetString(7), o.GetString(8)), ct);
        Assert.NotNull(d);
        Assert.Equal(1, d.KaynakId);                                 // RAPORID 2 -> e-Fatura giden
        Assert.Equal(2, d.Yon);
        Assert.Equal(1, d.Varsayilan);
        Assert.Equal("e-Fatura", d.BelgeTuru);
        Assert.Equal("application/xslt+xml", d.ContentType);
        Assert.Equal(d.Hash, d.Hash.ToUpperInvariant());
        Assert.Contains("stylesheet", d.Icerik);
        // Web'in okuduğu yol (EFaturaServisi.XsltAsync) aynı satırı görür.
        Assert.Contains("stylesheet", await b.TekDegerAsync<string>("""
            select convert_from(di.icerik, 'UTF8') from public.dokuman x join public.dokuman_icerik di on di.hash = x.hash
             where x.kaynak = 'ebelge-xslt' and x.kaynak_id = 1 and coalesce(x.yon, 0) in (0, 2)
             order by x.varsayilan desc, x.id limit 1
            """, t, [], ct));

        // Aynı paket: değişiklik yok.
        var ikinci = await FnAsync(b, t, "fn_aktar_xslt", Paket("<xsl:stylesheet version=\\\"1.0\\\"/>"));
        Assert.Equal(0, ikinci["eklenen"]!.GetValue<int>() + ikinci["guncellenen"]!.GetValue<int>());

        // İçerik değişti: yeni içerik satırı, dokuman hash / boyut güncellenir; varsayılan korunur.
        await b.CalistirAsync("update public.dokuman set varsayilan = 0 where id = @p0", t, [d.Id], ct);
        var ucuncu = await FnAsync(b, t, "fn_aktar_xslt", Paket("<xsl:stylesheet version=\\\"2.0\\\"/>"));
        Assert.Equal(1, ucuncu["guncellenen"]!.GetValue<int>());
        Assert.Equal(1, ucuncu["icerik"]!.GetValue<int>());
        var yeniHash = await b.TekDegerAsync<string>("select hash from public.dokuman where id = @p0", t, [d.Id], ct);
        Assert.NotEqual(d.Hash, yeniHash);
        // Varsayılanı kullanıcı kaldırmıştı, şablon tek olduğu için kural yeniden varsayılan yapar.
        Assert.Equal(1, await b.TekDegerAsync<short>("select varsayilan from public.dokuman where id = @p0", t, [d.Id], ct));

        // Grup XSLT olmaktan çıktı -> silinir; D de siler.
        var dort = await FnAsync(b, t, "fn_aktar_xslt", Paket("<x/>", grubu: "RAPOR"));
        Assert.Equal(1, dort["silinen"]!.GetValue<int>());
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.dokuman where id = @p0", t, [d.Id], ct));
        var bes = await FnAsync(b, t, "fn_aktar_xslt", "{\"D\": {\"DOKUMLER\": [" + XsltId + "]}}");
        Assert.Equal(0, bes["silinen"]!.GetValue<int>());
    }

    private sealed record DokumanSatiri(int Id, int KaynakId, short Yon, short Varsayilan, string BelgeTuru, string Hash,
                                        int Boyut, string ContentType, string Icerik);

    /// <summary>1267: satırı olan belge (her tür) silinemez; satırsız silinebilir.</summary>
    [VtFact]
    public async Task Satirli_belge_silinemez()
    {
        if (!_olgu.Baglandi(nameof(Satirli_belge_silinemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await FnAsync(b, t, "fn_aktar_cari",
            "{\"U\": {\"REHBER\": [{\"id\": 990007201, \"kod\": \"AKT-XS-CARI\", \"firma\": \"Satırlı Belge Carisi\", \"durum\": 1}]}}");
        // Sipariş (tur 19): fatura değil - kural yine de geçerli (kullanıcı: "tüm belgeler").
        await FnAsync(b, t, "fn_aktar_belge",
            "{\"U\": {\"FATBASLIK\": [{\"id\": 990007301, \"tur\": 19, \"tipi\": 1, \"rehberid\": 990007201, \"faturatarih\": \"2026-06-01T10:00:00\","
            + " \"faturano\": \"SB-1\", \"fatura_tutari\": 100}],"
            + " \"FATURA\": [{\"id\": 990007401, \"fatbasid\": 990007301, \"tur\": 0, \"urunid\": 0, \"aciklama\": \"Satır\","
            + " \"adet\": 1, \"miktar\": 1, \"birimfiyat\": 100, \"tutar\": 100, \"kdv\": 20, \"sira\": 1}]}}");
        var belgeId = await b.TekDegerAsync<int>(
            "select id from public.belge where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = 990007301", t, [], ct);
        Assert.True(await b.TekDegerAsync<long>("select count(*) from public.belge_satir where belge_id = @p0", t, [belgeId], ct) > 0);
        Assert.Contains("Satırları olan belge silinemez",
            await b.TekDegerAsync<string>("select public.fn_belge_silinebilir(@p0)", t, [belgeId], ct));

        await b.CalistirAsync("delete from public.belge_satir where belge_id = @p0", t, [belgeId], ct);
        Assert.Equal("", await b.TekDegerAsync<string>("select public.fn_belge_silinebilir(@p0)", t, [belgeId], ct));
    }
}
