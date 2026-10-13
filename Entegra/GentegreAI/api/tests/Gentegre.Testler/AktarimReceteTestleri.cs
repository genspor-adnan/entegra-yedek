using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - REÇETE (1083): URETIMRECETE (+DETAY, +OPR) -> ürün ağacı.
///
/// Delphi modelinin web'e doğru çevrildiğini korur: mamulün kendi satırı (ANAURUN,
/// +1) bileşen değildir, bileşen miktarı eksi gelir; TUR 0 pasif reçetedir; yarı
/// mamul bileşen kendi ağacına bağlanır; operasyon süresi saatten dakikaya; pakette
/// olmayan detay silinir; aynı paket ikinci kez hiçbir şey yazmaz. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimReceteTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    private const string Stoklar = """
        {"U": {"STOKLAR": [
          {"id": 990002001, "kod": "AKT-MAMUL", "stokadi": "Aktarım mamul", "durum": 1},
          {"id": 990002002, "kod": "AKT-YARI",  "stokadi": "Aktarım yarı mamul", "durum": 1},
          {"id": 990002003, "kod": "AKT-HAM",   "stokadi": "Aktarım hammadde", "durum": 1}]}}
        """;

    // Mamul reçetesi: mamul satırı (+1), yarı mamul (-2), hammadde (-0.5), operasyon 1 saat 30 dk.
    // Yarı mamul reçetesi: hammadde (-3). Pasif (TUR 0) ikinci mamul reçetesi.
    private const string Receteler = """
        {"U": {
          "URETIMRECETE": [
            {"id": 990002101, "kod": "AKT-R-MAMUL", "ad": "Mamul reçetesi", "stokid": 990002001, "tur": 2},
            {"id": 990002102, "kod": "AKT-R-YARI",  "ad": "Yarı mamul reçetesi", "stokid": 990002002, "tur": 2},
            {"id": 990002103, "kod": "AKT-R-ESKI",  "ad": "Eski mamul reçetesi", "stokid": 990002001, "tur": 0}],
          "URETIMRECETEDETAY": [
            {"id": 990002201, "uretimreceteid": 990002101, "tur": 1, "urunid": 990002001, "miktar": 1, "anaurun": 1, "birim": 3},
            {"id": 990002202, "uretimreceteid": 990002101, "tur": 1, "urunid": 990002002, "miktar": -2, "anaurun": 0, "sira": 1},
            {"id": 990002203, "uretimreceteid": 990002101, "tur": 1, "urunid": 990002003, "miktar": -0.5, "anaurun": 0, "sira": 2},
            {"id": 990002204, "uretimreceteid": 990002102, "tur": 1, "urunid": 990002003, "miktar": -3, "anaurun": 0}],
          "URETIMRECETEOPR": [
            {"id": 990002301, "uretimreceteid": 990002101, "konusu": "Tornalama", "kaynak": 990002401,
             "sure": "1899-12-30T01:30:00", "sira": 1, "kalite": 1}]}}
        """;

    [VtFact]
    public async Task Recete_mamul_satiri_bilesen_degil_yari_mamul_baglanir_tekrar_yazmaz()
    {
        if (!_olgu.Baglandi(nameof(Recete_mamul_satiri_bilesen_degil_yari_mamul_baglanir_tekrar_yazmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await AktarAsync(b, t, "fn_aktar_stok", Stoklar);
        var im = await AktarAsync(b, t, "fn_aktar_is_merkezi", """
            {"U": {"LOKASYON": [
              {"id": 990002401, "kod": "AKT-CNC", "aciklama": "Aktarım CNC", "durum": 1, "tur": 7},
              {"id": 990002402, "kod": "AKT-RAF", "aciklama": "Depo rafı", "durum": 1, "tur": 1}]}}
            """);
        Assert.Equal(1, Sayi(im, "is_merkezi"));          // raf (TUR 1) iş merkezi değil

        var ilk = await AktarAsync(b, t, "fn_aktar_recete", Receteler);
        Assert.Equal(3, Sayi(ilk, "agac"));
        Assert.Equal(3, Sayi(ilk, "satir"));              // mamulün kendi satırı yok
        Assert.Equal(1, Sayi(ilk, "cikti_satiri"));
        Assert.Equal(1, Sayi(ilk, "operasyon"));

        const string agac = "select id from public.urun_agaci where aktarim_kaynak = 1 and aktarim_tablo = 'URETIMRECETE' and aktarim_id = ";
        var mamul = await b.TekDegerAsync<int>(agac + "990002101", t, [], ct);
        var yari = await b.TekDegerAsync<int>(agac + "990002102", t, [], ct);

        // Aktif reçete varsayılan, TUR 0 pasif ve varsayılan değil.
        Assert.Equal("0/1", await b.TekDegerAsync<string>(
            "select durum || '/' || varsayilan from public.urun_agaci where id = @p0", t, [mamul], ct));
        Assert.Equal("1/0", await b.TekDegerAsync<string>(
            "select durum || '/' || varsayilan from public.urun_agaci where aktarim_kaynak = 1 and aktarim_id = 990002103", t, [], ct));

        // Bileşen miktarı pozitif; yarı mamul satırı kendi ağacına bağlı (tur 4).
        Assert.Equal($"2.000000/4/{yari}", await b.TekDegerAsync<string>("""
            select miktar || '/' || tur || '/' || coalesce(alt_agac_id::text, '-') from public.urun_agaci_satir
             where aktarim_kaynak = 1 and aktarim_id = 990002202
            """, t, [], ct));
        Assert.Equal("0.500000/1/-", await b.TekDegerAsync<string>("""
            select miktar || '/' || tur || '/' || coalesce(alt_agac_id::text, '-') from public.urun_agaci_satir
             where aktarim_kaynak = 1 and aktarim_id = 990002203
            """, t, [], ct));

        // Operasyon: 01:30 = 90 dk, iş merkezi LOKASYON'dan.
        Assert.Equal("90.00/AKT-CNC/1", await b.TekDegerAsync<string>("""
            select o.birim_sure_dk || '/' || m.kod || '/' || o.kalite_kontrol
              from public.urun_agaci_operasyon o join public.is_merkezi m on m.id = o.is_merkezi_id
             where o.aktarim_kaynak = 1 and o.aktarim_id = 990002301
            """, t, [], ct));

        // Aynı paket: hiçbir şey yazılmaz.
        var ikinci = await AktarAsync(b, t, "fn_aktar_recete", Receteler);
        Assert.Equal(0, Sayi(ikinci, "agac") + Sayi(ikinci, "satir") + Sayi(ikinci, "operasyon")
                        + Sayi(ikinci, "satir_silinen") + Sayi(ikinci, "yari_mamul") + Sayi(ikinci, "varsayilan"));

        // Hammadde satırı Delphi'de silindi: reçete yeniden gelir, satır web'de de silinir.
        var azaltilmis = Receteler.Replace("""
            {"id": 990002203, "uretimreceteid": 990002101, "tur": 1, "urunid": 990002003, "miktar": -0.5, "anaurun": 0, "sira": 2},
            """, "");
        Assert.NotEqual(Receteler, azaltilmis);
        var ucuncu = await AktarAsync(b, t, "fn_aktar_recete", azaltilmis);
        Assert.Equal(1, Sayi(ucuncu, "satir_silinen"));
        Assert.Equal(1L, await b.TekDegerAsync<long>(
            "select count(*) from public.urun_agaci_satir where agac_id = @p0", t, [mamul], ct));

        // Reçete silindi: pasif, varsayılan düşer.
        await AktarAsync(b, t, "fn_aktar_recete", """{"D": {"URETIMRECETE": [990002101]}}""");
        Assert.Equal("1/0", await b.TekDegerAsync<string>(
            "select durum || '/' || varsayilan from public.urun_agaci where id = @p0", t, [mamul], ct));
        await t.RollbackAsync();
    }
}
