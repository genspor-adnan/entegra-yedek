using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - BELGE (1084): FATBASLIK + FATURA + STOKIZLEME, faturanın cari satırı, STOKDURUM.
///
/// Delphi faturaya KASA satırı yazmaz; web ekstresi yalnız mali_hareket okur, cari
/// satırını aktarım yazar: tutar ve dövizi Delphi cari bakiyesindeki gibi (1099:
/// EKSTREDEKULLAN=1 ise DOVIZ_TUTARI/DOVIZ_CINSI, değilse FATURA_TUTARI/KUR); Delphi
/// iadesi (yön türden, 15/2 = alış iadesi) web'de karşı türün iadesi olur. Satış satırında
/// yalnız masraf olarak bilinen kalemin hizmet karşılığı açılır; döviz ISO, KDV'li
/// tutarlar CHECK toleransında; yıl sınırından eski belge atlanır; pakette olmayan
/// satır silinir; aynı paket ikinci kez hiçbir şey yazmaz. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimBelgeTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    private const string Tanimlar = """
        {"U": {
          "STOKLAR": [{"id": 990003001, "kod": "AKT-B-STOK", "stokadi": "Aktarım belge stoğu", "durum": 1}],
          "STOKSERILOT": [{"id": 990003051, "stokid": 990003001, "lotno": "AKT-LOT"}]}}
        """;

    // Satış faturası (USD, ekstrede döviz; iki satır: stok + yalnız masraf olarak bilinen kalem),
    // Delphi iade faturası 15/2 (tedarikçiye iade = web alış iadesi 11/2), yıl sınırından eski bir fatura.
    private const string Belgeler = """
        {"U": {
          "FATBASLIK": [
            {"id": 990003101, "tur": 15, "tipi": 1, "rehberid": 990003201, "faturatarih": "2026-05-04T10:00:00",
             "eklemetarihi": "2026-05-04T10:05:00", "faturano": "AKT2026000000001", "baslik": "Aktarım Müşterisi",
             "fatura_matrahi": 300, "kdv_tutari": 60, "fatura_tutari": 360, "faturadovizi": "$", "rapordoviz": "$",
             "dovizkur": 40, "doviz_tutari": 9, "doviz_cinsi": "$", "ekstredekullan": 1, "kdvdurum": "Haric"},
            {"id": 990003102, "tur": 15, "tipi": 2, "rehberid": 990003201, "faturatarih": "2026-05-06T10:00:00",
             "fatura_tutari": 120, "fatura_matrahi": 100, "kdv_tutari": 20},
            {"id": 990003103, "tur": 15, "tipi": 1, "rehberid": 990003201, "faturatarih": "2025-12-30T10:00:00",
             "fatura_tutari": 50}],
          "FATURA": [
            {"id": 990003301, "fatbasid": 990003101, "tur": 1, "urunid": 990003001, "miktar": 2, "birim": 1,
             "birimfiyat": 100, "tutar": 200, "kdv": 20, "doviz_kuru": "$", "dovizkurdegeri": 40},
            {"id": 990003302, "fatbasid": 990003101, "tur": 0, "urunid": 32003, "miktar": 1,
             "birimfiyat": 100, "tutar": 100, "kdv": 20},
            {"id": 990003303, "fatbasid": 990003102, "tur": 1, "urunid": 990003001, "miktar": 1,
             "birimfiyat": 100, "tutar": 100, "kdv": 20}],
          "STOKIZLEME": [
            {"id": 990003401, "stokid": 990003001, "serilotid": 990003051, "baslikid": 990003101,
             "satirid": 990003301, "belgetur": 15, "izlemtur": 1, "adet": 2}]}}
        """;

    [VtFact]
    public async Task Fatura_cari_satiri_Delphi_bakiyesiyle_iade_karsi_ture_kalem_karsiligi_acilir_tekrar_yazmaz()
    {
        if (!_olgu.Baglandi(nameof(Fatura_cari_satiri_Delphi_bakiyesiyle_iade_karsi_ture_kalem_karsiligi_acilir_tekrar_yazmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": 990003201, "kod": "AKT-B-CARI", "firma": "Aktarım Müşterisi", "durum": 1,
                               "vno": "9900000021"}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_stok", Tanimlar);
        // Delphi'de gider kalemi (GELIRMI 0) - web'de yalnız masraf olarak var.
        await AktarAsync(b, t, "fn_aktar_kalem", """
            {"U": {"MASRAFGELIR": [{"id": 32003, "gelirmi": 0, "kod": "AKT-B-KALEM", "ad": "Aktarım kalemi", "durum": 1}]}}
            """);

        var ilk = await AktarAsync(b, t, "fn_aktar_belge", Belgeler);
        Assert.Equal(2, Sayi(ilk, "belge"));
        Assert.Equal(1, Sayi(ilk, "eski"));                 // 2025 tarihli atlandı
        Assert.Equal(3, Sayi(ilk, "satir"));
        Assert.Equal(1, Sayi(ilk, "kalem_karsilik"));       // satışta kullanılan gider kaleminin hizmeti
        Assert.Equal(1, Sayi(ilk, "izlem"));
        Assert.Equal(2, Sayi(ilk, "cari"));

        const string belge = "select id from public.belge where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = ";
        var fatura = await b.TekDegerAsync<int>(belge + "990003101", t, [], ct);

        // Başlık: ISO, ekstre dövizi EKSTREDEKULLAN=1 -> DOVIZ_CINSI, KDV durumu düzgün.
        Assert.Equal("USD/USD/Hariç", await b.TekDegerAsync<string>(
            "select belge_dovizi || '/' || ekstre_dovizi || '/' || kdv_durum from public.belge where id = @p0", t, [fatura], ct));

        // Cari satırı: ekstre dövizinde 9 USD borç, TL karşılığı 360 (KUR TL -> FATURA_TUTARI).
        Assert.Equal("9.0000/0.0000/360.0000/USD", await b.TekDegerAsync<string>("""
            select borc || '/' || alacak || '/' || yerel_borc || '/' || doviz_cinsi from public.mali_hareket
             where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = 990003101 and hesap_turu = 'C'
            """, t, [], ct));
        // Delphi 15/2 tedarikçiye iade: web'de alış iadesi (11/2), cariyi Delphi'deki gibi
        //   BORÇLANDIRIR; ekstre dövizi KUR (boş = TL).
        Assert.Equal("11/2/120.0000/0.0000/TL", await b.TekDegerAsync<string>("""
            select x.tur || '/' || x.tipi || '/' || m.borc || '/' || m.alacak || '/' || m.doviz_cinsi
              from public.mali_hareket m join public.belge x on x.id = m.belge_id
             where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK' and m.aktarim_id = 990003102
            """, t, [], ct));

        // Satırlar: stok satırının dövizi ve KDV'li tutarı; kalem satırı hizmete bağlı (satış).
        Assert.Equal("USD/40.000000/240.0000", await b.TekDegerAsync<string>("""
            select doviz_cinsi || '/' || doviz_kuru || '/' || tutar_kdvli from public.belge_satir
             where aktarim_kaynak = 1 and aktarim_tablo = 'FATURA' and aktarim_id = 990003301
            """, t, [], ct));
        Assert.Equal("2/AKT-B-KALEM", await b.TekDegerAsync<string>("""
            select s.tur || '/' || h.kod from public.belge_satir s join public.hizmet h on h.id = s.hizmet_id
             where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'FATURA' and s.aktarim_id = 990003302
            """, t, [], ct));

        // Aynı paket: hiçbir şey yazılmaz.
        var ikinci = await AktarAsync(b, t, "fn_aktar_belge", Belgeler);
        Assert.Equal(0, Sayi(ikinci, "belge") + Sayi(ikinci, "satir") + Sayi(ikinci, "izlem") + Sayi(ikinci, "cari")
                        + Sayi(ikinci, "kalem_karsilik") + Sayi(ikinci, "satir_silinen"));

        // Kalem satırı Delphi'de silindi: belge yeniden gelir, satır web'de de gider.
        var azaltilmis = JsonNode.Parse(Belgeler)!;
        var satirlar = azaltilmis["U"]!["FATURA"]!.AsArray();
        satirlar.Remove(satirlar.First(s => s!["id"]!.GetValue<int>() == 990003302));
        Assert.Equal(1, Sayi(await AktarAsync(b, t, "fn_aktar_belge", azaltilmis.ToJsonString()), "satir_silinen"));

        // Belge silindi: cari satırıyla birlikte gider.
        await AktarAsync(b, t, "fn_aktar_belge", """{"D": {"FATBASLIK": [990003101]}}""");
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.mali_hareket where aktarim_kaynak = 1 and aktarim_tablo = 'FATBASLIK' and aktarim_id = 990003101",
            t, [], ct));
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.belge where id = @p0", t, [fatura], ct));
        await t.RollbackAsync();
    }

    // 1088: satış ve iadesi AYNI pakette - iadenin izlemi satışın (yeni yazılan) izlemine döner.
    private const string SatisIade = """
        {"U": {
          "FATBASLIK": [
            {"id": 990003501, "tur": 15, "tipi": 1, "rehberid": 0, "faturatarih": "2026-07-01T10:00:00", "fatura_tutari": 100},
            {"id": 990003502, "tur": 15, "tipi": 2, "rehberid": 0, "faturatarih": "2026-07-02T10:00:00", "fatura_tutari": 100}],
          "FATURA": [
            {"id": 990003511, "fatbasid": 990003501, "tur": 1, "urunid": 990003001, "miktar": 1, "birimfiyat": 100, "tutar": 100},
            {"id": 990003512, "fatbasid": 990003502, "tur": 1, "urunid": 990003001, "miktar": 1, "birimfiyat": 100, "tutar": 100}],
          "STOKIZLEME": [
            {"id": 990003602, "stokid": 990003001, "serilotid": 990003051, "baslikid": 990003502, "satirid": 990003512,
             "belgetur": 15, "izlemtur": 1, "adet": 1, "donusid": 990003601},
            {"id": 990003601, "stokid": 990003001, "serilotid": 990003051, "baslikid": 990003501, "satirid": 990003511,
             "belgetur": 15, "izlemtur": 1, "adet": 1}]}}
        """;

    [VtFact]
    public async Task Ayni_paketteki_donus_izlemi_ilk_geciste_baglanir()
    {
        if (!_olgu.Baglandi(nameof(Ayni_paketteki_donus_izlemi_ilk_geciste_baglanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_stok", Tanimlar);

        var ilk = await AktarAsync(b, t, "fn_aktar_belge", SatisIade);
        Assert.Equal(2, Sayi(ilk, "izlem"));
        Assert.Equal(1, Sayi(ilk, "izlem_donus"));
        Assert.True(await b.TekDegerAsync<bool>("""
            select x.donus_id = w.id from public.stok_izleme x, public.stok_izleme w
             where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'STOKIZLEME' and x.aktarim_id = 990003602
               and w.aktarim_kaynak = 1 and w.aktarim_tablo = 'STOKIZLEME' and w.aktarim_id = 990003601
            """, t, [], ct));

        var ikinci = await AktarAsync(b, t, "fn_aktar_belge", SatisIade);
        Assert.Equal(0, Sayi(ikinci, "izlem") + Sayi(ikinci, "izlem_donus"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Stok_bakiyesi_Delphi_STOKDURUM_aynasi()
    {
        if (!_olgu.Baglandi(nameof(Stok_bakiyesi_Delphi_STOKDURUM_aynasi))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await AktarAsync(b, t, "fn_aktar_stok", Tanimlar);
        await AktarAsync(b, t, "fn_aktar_depo", """
            {"U": {"DEPOLAR": [{"id": 32001, "depoadi": "Aktarım deposu", "durum": 1}]}}
            """);
        const string bakiye = """
            {"U": {"STOKDURUM": [{"stokid": 990003001, "depoid": 32001, "giren": 10, "cikan": 3.5, "kalan": 6.5}]}}
            """;
        Assert.Equal(1, Sayi(await AktarAsync(b, t, "fn_aktar_stok_durum", bakiye), "stok_durum"));
        Assert.Equal(0, Sayi(await AktarAsync(b, t, "fn_aktar_stok_durum", bakiye), "stok_durum"));

        const string kalan = """
            select d.kalan from public.stok_durum d
              join public.stok s on s.id = d.stok_id and s.aktarim_kaynak = 1 and s.aktarim_id = 990003001
            """;
        Assert.Equal(6.5m, await b.TekDegerAsync<decimal>(kalan, t, [], ct));

        await AktarAsync(b, t, "fn_aktar_stok_durum", """{"D": {"STOKDURUM": [{"stokid": 990003001, "depoid": 32001}]}}""");
        Assert.Equal(0m, await b.TekDegerAsync<decimal>(kalan, t, [], ct));
        await t.RollbackAsync();
    }
}
