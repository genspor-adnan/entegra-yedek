using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - DİLİM 2 (1082): döviz, kalem, stok, hesap.
///
/// Eşdeğerlik testinin (db/araclar/aktarim_esdegerlik.sql) bulduğu hataların
/// tekrar etmemesi için: Delphi '$' -> ISO (aynı günün kuru iki satır olmasın),
/// tarih kolonu saat dilimine girmez (gün kaymasın), Delphi 0 = "yok", web'in
/// barkodu / kodu ezilmez. İşlem içinde çalışır, geri alınır.
/// </summary>
public sealed class AktarimStokKalemHesapTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> AktarAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    [VtFact]
    public async Task Doviz_Delphi_sembolu_ISO_olur_ayni_gun_tek_satir()
    {
        if (!_olgu.Baglandi(nameof(Doviz_Delphi_sembolu_ISO_olur_ayni_gun_tek_satir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // 1901'de kimsenin kuru yok - gerçek veriyle çakışmaz. Aynı gün iki saat: en geç kazanır.
        var ilk = await AktarAsync(b, t, "fn_aktar_doviz", """
            {"U": {"DOVIZ": [
              {"cinsi": "$", "tarih": "1901-06-03T09:00:00", "alis": 1.10, "satis": 1.20},
              {"cinsi": "$", "tarih": "1901-06-03T15:30:00", "alis": 1.11, "satis": 1.21}]}}
            """);
        Assert.Equal(1, Sayi(ilk, "doviz"));
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.doviz_kur where doviz_cinsi = '$'", t, [], ct));
        Assert.Equal(1.11m, await b.TekDegerAsync<decimal>(
            "select alis from public.doviz_kur where doviz_cinsi = 'USD' and tarih = date '1901-06-03'", t, [], ct));

        // Aynı veri tekrar: yazılmaz.
        var ikinci = await AktarAsync(b, t, "fn_aktar_doviz", """
            {"U": {"DOVIZ": [{"cinsi": "$", "tarih": "1901-06-03T15:30:00", "alis": 1.11, "satis": 1.21}]}}
            """);
        Assert.Equal(0, Sayi(ikinci, "doviz"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Kalem_GELIRMI_ye_gore_hizmet_ya_da_masraf_olur_fiyati_ISO()
    {
        if (!_olgu.Baglandi(nameof(Kalem_GELIRMI_ye_gore_hizmet_ya_da_masraf_olur_fiyati_ISO))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // MASRAFGELIR.ID Delphi'de smallint - kimlik 32767'yi aşamaz.
        var sonuc = await AktarAsync(b, t, "fn_aktar_kalem", """
            {"U": {"MASRAFGELIR": [
                {"id": 32001, "gelirmi": 1, "kod": "AKT-GELIR", "ad": "Aktarim gelir kalemi", "durum": 1},
                {"id": 32002, "gelirmi": 0, "kod": "AKT-GIDER", "ad": "Aktarim gider kalemi", "durum": 1}],
                   "FIYATLAR": [
                {"id": 990000601, "hizmetid": 32001, "fiyatadi": 1, "fiyat": 250, "kur": "€"}]}}
            """);
        Assert.Equal(1, Sayi(sonuc, "hizmet"));
        Assert.Equal(1, Sayi(sonuc, "masraf"));
        Assert.Equal(1, Sayi(sonuc, "hizmet_fiyat"));
        Assert.Equal("EUR", await b.TekDegerAsync<string>("""
            select f.doviz_cinsi from public.hizmet_fiyat f
              join public.hizmet h on h.id = f.hizmet_id
             where h.aktarim_kaynak = 1 and h.aktarim_tablo = 'MASRAFGELIR' and h.aktarim_id = 32001
            """, t, [], ct));
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.masraf where aktarim_kaynak = 1 and aktarim_id = 32001", t, [], ct));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Stok_web_barkodunu_ezmez_seri_lot_tarihi_kaymaz()
    {
        if (!_olgu.Baglandi(nameof(Stok_web_barkodunu_ezmez_seri_lot_tarihi_kaymaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // Web'de (ör. ilaç kataloğu) zaten bir stokta duran barkod.
        var webBarkod = await b.TekDegerAsync<string>(
            "select barkod from public.stok_barkod where aktarim_kaynak is null order by id limit 1", t, [], ct);
        var barkodlar = new JsonArray(new JsonObject
            { ["id"] = 990000801, ["stokid"] = 990000701, ["barkod"] = "AKT-BARKOD-1", ["varsayilan"] = 1 });
        if (webBarkod is not null)
            barkodlar.Add(new JsonObject { ["id"] = 990000802, ["stokid"] = 990000701, ["barkod"] = webBarkod });

        var paket = new JsonObject { ["U"] = new JsonObject
        {
            ["STOKLAR"] = new JsonArray(new JsonObject
                { ["id"] = 990000701, ["kod"] = "AKT-STOK-1", ["stokadi"] = "Aktarım test stoğu", ["durum"] = 1 }),
            ["STOKBARKOD"] = barkodlar,
            ["STOKFIYAT"] = new JsonArray(new JsonObject
                { ["id"] = 990000901, ["stokid"] = 990000701, ["fiyatadi"] = 1, ["fiyat"] = 10, ["kur"] = "$", ["satis"] = 1 }),
            ["STOKSERILOT"] = new JsonArray(new JsonObject
                { ["id"] = 990000951, ["stokid"] = 990000701, ["lotno"] = "L1", ["skt"] = "2027-03-31T00:00:00" }),
        }}.ToJsonString();

        var sonuc = await AktarAsync(b, t, "fn_aktar_stok", paket);
        Assert.Equal(1, Sayi(sonuc, "stok"));
        Assert.Equal(1, Sayi(sonuc, "barkod"));
        if (webBarkod is not null) Assert.Equal(1, Sayi(sonuc, "barkod_cakisma"));
        Assert.Equal("USD", await b.TekDegerAsync<string>(
            "select doviz_cinsi from public.stok_fiyat where aktarim_kaynak = 1 and aktarim_id = 990000901", t, [], ct));
        // İstanbul gece yarısı UTC'de önceki gündür - tarih kolonu kaymamalı. Gün, oturumun
        //   (şubenin, 1097) saat diliminde okunur: saklanan an yerel gece yarısıdır.
        Assert.Equal(new DateTime(2027, 3, 31), await b.TekDegerAsync<DateTime>(
            "select son_kullanma_tarihi::date from public.stok_seri_lot where aktarim_kaynak = 1 and aktarim_id = 990000951",
            t, [], ct));

        // Tekrar: hiçbir şey yazılmaz.
        var ikinci = await AktarAsync(b, t, "fn_aktar_stok", paket);
        Assert.Equal(0, Sayi(ikinci, "stok") + Sayi(ikinci, "barkod") + Sayi(ikinci, "fiyat") + Sayi(ikinci, "seri_lot"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Hesap_kodu_web_e_aitse_atlanir_Delphi_0_bos_sayilir()
    {
        if (!_olgu.Baglandi(nameof(Hesap_kodu_web_e_aitse_atlanir_Delphi_0_bos_sayilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        var webKasa = await b.TekDegerAsync<string>(
            "select kod from public.hesap where tur = 'K' and kod <> '' and aktarim_kaynak is null order by id limit 1", t, [], ct);
        var kasalar = new JsonArray(new JsonObject
            { ["id"] = 990001001, ["kasakodu"] = "AKT-K1", ["kasaadi"] = "Aktarım kasası", ["kur"] = "€",
              ["durum"] = 1, ["rehberid"] = 0 });
        if (webKasa is not null)
            kasalar.Add(new JsonObject { ["id"] = 990001002, ["kasakodu"] = webKasa, ["kasaadi"] = "Çakışan", ["durum"] = 1 });

        var sonuc = await AktarAsync(b, t, "fn_aktar_hesap",
            new JsonObject { ["U"] = new JsonObject { ["KASALAR"] = kasalar } }.ToJsonString());
        Assert.Equal(1, Sayi(sonuc, "hesap"));
        if (webKasa is not null) Assert.Equal(1, Sayi(sonuc, "cakisma"));

        var satir = await b.TekAsync(
            "select doviz_cinsi, sorumlu_id from public.hesap where aktarim_kaynak = 1 and aktarim_tablo = 'KASALAR' and aktarim_id = 990001001",
            t, [], o => new HesapSatiri(o.GetString(0), o.IsDBNull(1) ? null : o.GetInt32(1)), ct);
        Assert.Equal("EUR", satir!.Doviz);
        Assert.Null(satir.Sorumlu);                        // REHBERID 0 = sorumlu yok
        await t.RollbackAsync();
    }

    private sealed record HesapSatiri(string Doviz, int? Sorumlu);
}
