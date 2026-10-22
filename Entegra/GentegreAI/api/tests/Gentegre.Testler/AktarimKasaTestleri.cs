using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - KASA (1085): cari satırı tek hareket; hesap satırı kasa_islem + 2 bacak
/// (081 modeli: hesap bacağı işaret ters, karşı bacak C / M / '-'), başlık dengeli.
/// "Tanımsız Cari" (REHBER 0) yalnız belge başlığında ve kasa cari satırında kart olur;
/// hesap hareketinde 0 hâlâ "karşı taraf yok". Alış belgesi cariyi tedarikçi yapar.
/// Aynı paket ikinci kez hiçbir şey yazmaz. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimKasaTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    // Cari satırı (Tanımsız Cari'ye), kasadan nakit tahsilat (cari), masraf ödemesi (cari yok).
    private const string Kasa = """
        {"U": {"KASA": [
          {"id": 990004101, "tur": 2, "hesapturu": "", "rehberid": 0, "borc": 500, "alacak": 0, "kur": "TL",
           "doviz_tutari": 500, "islemtarihi": "2026-01-01T00:00:00"},
          {"id": 990004102, "tur": 21, "hesapturu": "K", "hesapid": 990004001, "rehberid": 990004201,
           "borc": 0, "alacak": 1280, "kur": "TL", "doviz_tutari": 1280, "islemtarihi": "2026-03-02T11:00:00"},
          {"id": 990004103, "tur": 32, "hesapturu": "K", "hesapid": 990004001, "rehberid": 0, "masrafid": 32004,
           "borc": 0, "alacak": 75, "kur": "TL", "doviz_tutari": 75, "islemtarihi": "2026-03-03T11:00:00"}]}}
        """;

    [VtFact]
    public async Task Kasa_hesap_satiri_iki_bacak_dengeli_tanimsiz_cari_yalniz_cari_satirinda()
    {
        if (!_olgu.Baglandi(nameof(Kasa_hesap_satiri_iki_bacak_dengeli_tanimsiz_cari_yalniz_cari_satirinda))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": 990004201, "kod": "AKT-K-CARI", "firma": "Aktarım Kasa Carisi", "durum": 1,
                               "vno": "9900000031"}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_hesap", """
            {"U": {"KASALAR": [{"id": 990004001, "kasakodu": "AKT-K-KASA", "kasaadi": "Aktarım kasası", "kur": "TL", "durum": 1}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_kalem", """
            {"U": {"MASRAFGELIR": [{"id": 32004, "gelirmi": 0, "kod": "AKT-K-GIDER", "ad": "Aktarım gideri", "durum": 1}]}}
            """);

        var ilk = await AktarAsync(b, t, "fn_aktar_kasa", Kasa);
        Assert.Equal(1, Sayi(ilk, "cari"));
        Assert.Equal(2, Sayi(ilk, "islem"));
        Assert.Equal(2, Sayi(ilk, "bacak1"));
        Assert.Equal(2, Sayi(ilk, "bacak2"));

        // Cari satırı Tanımsız Cari kartına.
        Assert.Equal("Tanımsız Cari/500.0000", await b.TekDegerAsync<string>("""
            select t.unvan || '/' || m.borc from public.mali_hareket m join public.taraf t on t.id = m.taraf_id
             where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA' and m.aktarim_id = 990004101
            """, t, [], ct));

        // Tahsilat: kasa bacağı BORÇ (işaret ters), cari bacağı Delphi'deki gibi ALACAK; dengeli.
        Assert.Equal("K:1280.0000/0.0000 C:0.0000/1280.0000", await b.TekDegerAsync<string>("""
            select string_agg(m.hesap_turu || ':' || m.borc || '/' || m.alacak, ' ' order by m.sira)
              from public.mali_hareket m join public.kasa_islem i on i.id = m.kasa_islem_id
             where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA' and i.aktarim_id = 990004102
            """, t, [], ct));

        // Masraf ödemesi: karşı bacak kalem (M), Delphi 0 Tanımsız Cari'ye GİTMEZ.
        Assert.Equal("K:- M:AKT-K-GIDER", await b.TekDegerAsync<string>("""
            select string_agg(m.hesap_turu || ':' || coalesce(x.kod, '-'), ' ' order by m.sira)
              from public.mali_hareket m join public.kasa_islem i on i.id = m.kasa_islem_id
              left join public.masraf x on x.id = m.masraf_id
             where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA' and i.aktarim_id = 990004103
               and m.taraf_id is null
            """, t, [], ct));

        Assert.Equal(0L, await b.TekDegerAsync<long>("""
            select count(*) from (select i.id from public.kasa_islem i join public.mali_hareket m on m.kasa_islem_id = i.id
                                   where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA'
                                   group by i.id having sum(m.yerel_borc) <> sum(m.yerel_alacak)) x
            """, t, [], ct));

        // Aynı paket: hiçbir şey yazılmaz.
        var ikinci = await AktarAsync(b, t, "fn_aktar_kasa", Kasa);
        Assert.Equal(0, Sayi(ikinci, "cari") + Sayi(ikinci, "islem") + Sayi(ikinci, "bacak1") + Sayi(ikinci, "bacak2"));

        // Silinen tahsilat: başlık ve bacaklar gider.
        await AktarAsync(b, t, "fn_aktar_kasa", """{"D": {"KASA": [990004102]}}""");
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.kasa_islem where aktarim_kaynak = 1 and aktarim_tablo = 'KASA' and aktarim_id = 990004102",
            t, [], ct));
        await t.RollbackAsync();
    }

    // 1142: TL tahsilat, cari dolar ekstreli (EKSTREDEKULLAN=1, DOVIZ_KURU $); web'de karşılığı
    // olmayan iki Delphi türü - 81 Kupon Virmanı (yalnız cari) ve 37 Kasa Eksiği (kasa, cari yok).
    private const string KasaDoviz = """
        {"U": {"KASA": [
          {"id": 990004111, "tur": 21, "hesapturu": "K", "hesapid": 990004001, "rehberid": 990004201,
           "borc": 0, "alacak": 4000, "kur": "TL", "doviz_kuru": "$", "doviz_tutari": 100, "ekstredekullan": 1,
           "islemtarihi": "2026-03-04T11:00:00"},
          {"id": 990004112, "tur": 81, "hesapturu": "", "rehberid": 990004201, "borc": 250, "alacak": 0,
           "kur": "TL", "aciklama": "kupon", "islemtarihi": "2026-03-05T11:00:00"},
          {"id": 990004113, "tur": 37, "hesapturu": "K", "hesapid": 990004001, "rehberid": 0, "borc": 30,
           "alacak": 0, "kur": "TL", "islemtarihi": "2026-03-06T11:00:00"}]}}
        """;

    [VtFact]
    public async Task Cari_bacagi_ekstre_dovizinde_bilinmeyen_tur_en_yakin_web_turune()
    {
        if (!_olgu.Baglandi(nameof(Cari_bacagi_ekstre_dovizinde_bilinmeyen_tur_en_yakin_web_turune))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": 990004201, "kod": "AKT-K-CARI", "firma": "Aktarım Kasa Carisi", "durum": 1,
                               "vno": "9900000031"}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_hesap", """
            {"U": {"KASALAR": [{"id": 990004001, "kasakodu": "AKT-K-KASA", "kasaadi": "Aktarım kasası", "kur": "TL", "durum": 1}]}}
            """);

        var sonuc = await AktarAsync(b, t, "fn_aktar_kasa", KasaDoviz);
        Assert.Equal(2, Sayi(sonuc, "tur_eslenen"));
        Assert.Equal(0, Sayi(sonuc, "tursuz"));

        // Kasa bacağı TL'de (4000), cari bacağı dolarda 100 ALACAK; TL karşılığı iki bacakta aynı.
        Assert.Equal("K:TL:4000.0000/0.0000:4000.0000 C:USD:0.0000/100.0000:4000.0000", await b.TekDegerAsync<string>("""
            select string_agg(m.hesap_turu || ':' || m.doviz_cinsi || ':' || m.borc || '/' || m.alacak || ':'
                              || (m.yerel_borc + m.yerel_alacak), ' ' order by m.sira)
              from public.mali_hareket m join public.kasa_islem i on i.id = m.kasa_islem_id
             where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'KASA' and i.aktarim_id = 990004111
            """, t, [], ct));

        // 81 yalnız cari satırı -> Cari Virman (49), Delphi tür adı açıklamada; tutar aynen.
        Assert.Equal("49/250.0000/[Delphi: Kupon Virmanı] kupon", await b.TekDegerAsync<string>("""
            select m.tur || '/' || m.borc || '/' || m.aciklama from public.mali_hareket m
             where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'KASA' and m.aktarim_id = 990004112
            """, t, [], ct));
        // 37 kasadan çıkış (borç) -> Nakit Ödeme (31).
        Assert.Equal(31, await b.TekDegerAsync<int>(
            "select tur from public.kasa_islem where aktarim_kaynak = 1 and aktarim_tablo = 'KASA' and aktarim_id = 990004113",
            t, [], ct));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Alis_belgesi_Tanimsiz_Cari_ye_baglanir_carisi_tedarikci_olur()
    {
        if (!_olgu.Baglandi(nameof(Alis_belgesi_Tanimsiz_Cari_ye_baglanir_carisi_tedarikci_olur))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": 990004202, "kod": "AKT-K-TED", "firma": "Aktarım Tedarikçisi", "durum": 1,
                               "vno": "9900000032"}]}}
            """);
        var sonuc = await AktarAsync(b, t, "fn_aktar_belge", """
            {"U": {"FATBASLIK": [
              {"id": 990004301, "tur": 11, "tipi": 1, "rehberid": 0, "faturatarih": "2026-04-01T10:00:00",
               "faturano": "GIDER-1", "fatura_tutari": 1000},
              {"id": 990004302, "tur": 11, "tipi": 1, "rehberid": 990004202, "faturatarih": "2026-04-02T10:00:00",
               "faturano": "ALIS-1", "fatura_tutari": 250}]}}
            """);
        Assert.Equal(2, Sayi(sonuc, "cari"));

        Assert.Equal("Tanımsız Cari/1000.0000", await b.TekDegerAsync<string>("""
            select t.unvan || '/' || m.alacak from public.mali_hareket m join public.taraf t on t.id = m.taraf_id
             where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK' and m.aktarim_id = 990004301
            """, t, [], ct));
        Assert.Equal(1, await b.TekDegerAsync<short>(
            "select tedarikci from public.taraf where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = 990004202",
            t, [], ct));
        await t.RollbackAsync();
    }
}
