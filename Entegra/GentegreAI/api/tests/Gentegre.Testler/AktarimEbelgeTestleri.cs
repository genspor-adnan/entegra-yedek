using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - e-BELGE SÜREKLİ ADIM (1265): <c>fn_aktar_ebelge</c> paket biçimiyle EBELGE +
/// EBELGEMESAJ (GENDEPO) satırlarını belgeye bağlı <c>e_belge</c> / <c>e_belge_mesaj</c> yapar; belgesi
/// web'de olmayan satır yazılmaz; ikinci çalıştırma hiçbir şey yazmaz; pakette olmayan mesaj silinir;
/// D e-belgeyi mesajlarıyla siler; 14. adım ve mutabakat kimliği tanımlıdır. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimEbelgeTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> FnAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private const int CariId = 990006201, BelgeId = 990006301, EbelgeId = 990006401;
    private const long MesajId = (long)EbelgeId * 10;

    private sealed record EBelgeSatiri(long Id, int BelgeId, short Durum, short Tur, string No, string Xml, byte[]? Zip);

    /// <summary>EBELGE (belgeli + belgesiz) ve mesajları; <paramref name="ikinciMesaj"/> hata mesajını da ekler.</summary>
    private static string EbelgePaketi(int durum, bool ikinciMesaj)
    {
        var ebelge1 = "{\"id\": " + EbelgeId + ", \"fatbaslikid\": " + BelgeId + ", \"rehberid\": " + CariId
            + ", \"belgeturu\": 151, \"yon\": 1, \"uuid\": \"7f9d2a1c-aaaa-4bbb-8ccc-990006401001\", \"belgeno\": \"AKT2026000000001\""
            + ", \"gondericialias\": \"urn:mail:gonderici@test\", \"alicialias\": \"urn:mail:alici@test\", \"durum\": " + durum
            + ", \"api_json\": \"\", \"ubl_xml\": \"<Invoice/>\", \"ekleyen\": 1, \"eklemetarihi\": \"2026-06-02T09:00:00\""
            + ", \"servis_durum_kodu\": \"SUCCEED\", \"servis_durum_adi\": \"Başarılı\", \"ubl_xml_zip\": \"\\\\x1f8b0800\"}";
        var ebelge2 = "{\"id\": " + (EbelgeId + 1) + ", \"fatbaslikid\": 1, \"rehberid\": " + CariId
            + ", \"belgeturu\": 151, \"yon\": 1, \"uuid\": \"7f9d2a1c-aaaa-4bbb-8ccc-990006401002\", \"belgeno\": \"AKT2026000000002\", \"durum\": 2}";
        var mesaj1 = "{\"id\": " + MesajId + ", \"ebelgeid\": " + EbelgeId + ", \"yon\": 1, \"islemturu\": 2, \"mesajtipi\": 1"
            + ", \"mesaj\": \"Gönderildi\", \"httpkodu\": 200, \"serviskodu\": \"OK\", \"eklemetarihi\": \"2026-06-02T09:00:05\"}";
        var mesaj2 = "{\"id\": " + (MesajId + 1) + ", \"ebelgeid\": " + EbelgeId + ", \"yon\": 1, \"islemturu\": 3, \"mesajtipi\": 2"
            + ", \"mesaj\": \"\", \"hatakodu\": \"E-1\", \"hatamesaji\": \"Deneme hatası\", \"httpkodu\": 500, \"eklemetarihi\": \"2026-06-02T09:01:00\"}";
        return "{\"U\": {\"EBELGE\": [" + ebelge1 + ", " + ebelge2 + "], \"EBELGEMESAJ\": [" + mesaj1
            + (ikinciMesaj ? ", " + mesaj2 : "") + "]}}";
    }

    [VtFact]
    public async Task Ebelge_belgeye_baglanir_belgesiz_atlanir_tekrar_yazmaz_mesaj_toplami_ve_D_calisir()
    {
        if (!_olgu.Baglandi(nameof(Ebelge_belgeye_baglanir_belgesiz_atlanir_tekrar_yazmaz_mesaj_toplami_ve_D_calisir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // 14. adım ve mutabakat kimliği tanımlı.
        Assert.Equal(14, await b.TekDegerAsync<int>(
            "select sira from public.fn_aktarim_adimlari() where fonksiyon = 'fn_aktar_ebelge'", t, [], ct));
        Assert.Equal("EBELGE", await b.TekDegerAsync<string>(
            "select public.fn_aktarim_mutabakat('EBELGE', array[]::bigint[])->>'tablo'", t, [], ct));

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await FnAsync(b, t, "fn_aktar_cari",
            "{\"U\": {\"REHBER\": [{\"id\": " + CariId + ", \"kod\": \"AKT-EB-CARI\", \"firma\": \"Aktarım e-Belge Carisi\", \"durum\": 1, \"vno\": \"9900000042\"}]}}");
        await FnAsync(b, t, "fn_aktar_belge",
            "{\"U\": {\"FATBASLIK\": [{\"id\": " + BelgeId + ", \"tur\": 15, \"tipi\": 1, \"rehberid\": " + CariId
            + ", \"faturatarih\": \"2026-06-01T10:00:00\", \"faturano\": \"AKT2026000000001\", \"fatura_tutari\": 118, \"kdv_tutari\": 18"
            + ", \"efaturadurum\": 2, \"senaryo\": 1}]}}");

        // 1) ilk paket: belgeli satır yazılır, belgesiz (fatbaslikid 1) atlanır, mesajlar bağlanır.
        var ilk = await FnAsync(b, t, "fn_aktar_ebelge", EbelgePaketi(2, ikinciMesaj: true));
        Assert.Equal(1, ilk["eklenen"]!.GetValue<int>());
        Assert.Equal(1, ilk["belgesiz"]!.GetValue<int>());
        Assert.Equal(2, ilk["mesaj"]!.GetValue<int>());
        var e = await b.TekAsync<EBelgeSatiri>("""
            select x.id, x.belge_id, x.durum, x.belge_turu, x.belge_no, x.ubl_xml, x.ubl_xml_zip
              from public.e_belge x where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'EBELGE' and x.aktarim_id = @p0
            """, t, [(long)EbelgeId], o => new EBelgeSatiri(o.GetInt64(0), o.GetInt32(1), o.GetInt16(2), o.GetInt16(3),
                                                                 o.GetString(4), o.GetString(5), o.IsDBNull(6) ? null : (byte[])o.GetValue(6)), ct);
        Assert.NotNull(e);
        Assert.Equal(2, e.Durum);                         // e-Fatura gönderildi -> 2
        Assert.Equal(1, e.Tur);
        Assert.Equal("AKT2026000000001", e.No);
        Assert.Equal("<Invoice/>", e.Xml);
        Assert.Equal(new byte[] { 0x1f, 0x8b, 0x08, 0x00 }, e.Zip);
        Assert.Equal(e.BelgeId, await b.TekDegerAsync<int>(
            "select id from public.belge where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = @p0", t, [(long)BelgeId], ct));
        Assert.Equal(2L, await b.TekDegerAsync<long>(
            "select count(*) from public.e_belge_mesaj where e_belge_id = @p0", t, [e.Id], ct));
        Assert.Equal(9, await b.TekDegerAsync<short>(
            "select tip from public.e_belge_mesaj where aktarim_tablo = 'EBELGEMESAJ' and aktarim_id = @p0", t, [MesajId + 1], ct));
        // Belgenin kendi görünümü: e_belge artık var (EFaturaServisi.GorunumVerisiAsync e_belge'siz sayma kuralı düşer).
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.e_belge where belge_id = @p0 and yon = 1", t, [e.BelgeId], ct));

        // 2) aynı paket: hiçbir şey yazılmaz.
        var ikinci = await FnAsync(b, t, "fn_aktar_ebelge", EbelgePaketi(2, ikinciMesaj: true));
        Assert.Equal(0, ikinci["eklenen"]!.GetValue<int>());
        Assert.Equal(0, ikinci["guncellenen"]!.GetValue<int>());
        Assert.Equal(0, ikinci["mesaj"]!.GetValue<int>());

        // 3) toplam kuralı: paketten düşen mesaj silinir; durum değişikliği güncellenir.
        var ucuncu = await FnAsync(b, t, "fn_aktar_ebelge", EbelgePaketi(1, ikinciMesaj: false));
        Assert.Equal(1, ucuncu["guncellenen"]!.GetValue<int>());
        Assert.Equal(1, ucuncu["mesaj_silinen"]!.GetValue<int>());
        Assert.Equal(1, await b.TekDegerAsync<short>("select durum from public.e_belge where id = @p0", t, [e.Id], ct));
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.e_belge_mesaj where e_belge_id = @p0", t, [e.Id], ct));

        // 4) D: e-belge mesajlarıyla silinir; mutabakatta artık "eksik".
        var sil = await FnAsync(b, t, "fn_aktar_ebelge", "{\"D\": {\"EBELGE\": [" + EbelgeId + "]}}");
        Assert.Equal(1, sil["silinen"]!.GetValue<int>());
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.e_belge where id = @p0", t, [e.Id], ct));
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.e_belge_mesaj where e_belge_id = @p0", t, [e.Id], ct));
        var m = JsonNode.Parse(await b.TekDegerAsync<string>(
            "select public.fn_aktarim_mutabakat('EBELGE', array[@p0::bigint])::text", t, [(long)EbelgeId], ct) ?? "{}")!;
        Assert.Single(m["eksik"]!.AsArray());
    }
}
