using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

using static Gentegre.Testler.AktarimTestYardimcisi;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - ÜRETİM FİŞİ (1261): aktarımın tür 6 "Üretim" belgesi (eksi satırlar sarf, artı satır mamul)
/// fn_aktarim_uretim_fisi_kur ile uretim_fisi başlığı + satırlarına dönüşür; belge fişe bağlanır (kaynak_tur 61),
/// sarf ve giriş belgesi AYNI belge, maliyet Delphi değerleri (yeniden hesaplanmaz), mamulsüz / taslak belge atlanır,
/// ikinci çağrı hiçbir şey yazmaz. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimUretimFisiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private const string Stoklar = """
        {"U": {"STOKLAR": [
          {"id": 990006001, "kod": "AKT-UF-MAMUL", "stokadi": "Aktarım üretim mamulü", "durum": 1},
          {"id": 990006002, "kod": "AKT-UF-HAM1",  "stokadi": "Aktarım hammadde 1", "durum": 1},
          {"id": 990006003, "kod": "AKT-UF-HAM2",  "stokadi": "Aktarım hammadde 2", "durum": 1}]}}
        """;

    // 990006101: Delphi üretim fişi - iki sarf (eksi), bir mamul (artı; Delphi maliyeti 820 ≠ Σ sarf 889).
    // 990006102: artı satırı yok (mamul belirsiz) - atlanır.
    // 990006103: taslak (DURUM 1) - atlanır.
    private const string Belgeler = """
        {"U": {
          "FATBASLIK": [
            {"id": 990006101, "tur": 6, "tipi": 1, "rehberid": -1, "faturatarih": "2026-05-10T09:00:00",
             "eklemetarihi": "2026-05-10T09:05:00", "faturano": "AKT006101", "girisdepo": 1, "cikisdepo": 1,
             "fatura_tutari": 820.04, "aciklama": "Delphi üretimi"},
            {"id": 990006102, "tur": 6, "tipi": 1, "rehberid": -1, "faturatarih": "2026-05-11T09:00:00",
             "faturano": "AKT006102", "girisdepo": 1, "cikisdepo": 1},
            {"id": 990006103, "tur": 6, "tipi": 1, "rehberid": -1, "faturatarih": "2026-05-12T09:00:00",
             "faturano": "AKT006103", "girisdepo": 1, "cikisdepo": 1, "durum": 1}],
          "FATURA": [
            {"id": 990006301, "fatbasid": 990006101, "tur": 1, "urunid": 990006002, "adet": -4, "miktar": -4, "birim": 1,
             "birimfiyat": 0.8, "tutar": -3.2},
            {"id": 990006302, "fatbasid": 990006101, "tur": 1, "urunid": 990006003, "adet": -2, "miktar": -2, "birim": 1,
             "birimfiyat": 442.97, "tutar": -885.94},
            {"id": 990006303, "fatbasid": 990006101, "tur": 1, "urunid": 990006001, "adet": 1, "miktar": 1, "birim": 1,
             "birimfiyat": 820.04, "tutar": 820.04},
            {"id": 990006304, "fatbasid": 990006102, "tur": 1, "urunid": 990006002, "adet": -1, "miktar": -1, "birim": 1,
             "birimfiyat": 1, "tutar": -1},
            {"id": 990006305, "fatbasid": 990006103, "tur": 1, "urunid": 990006001, "adet": 1, "miktar": 1, "birim": 1,
             "birimfiyat": 5, "tutar": 5}]}}
        """;

    [VtFact]
    public async Task Tur6_belge_uretim_fisine_donusur_belge_baglanir_maliyet_Delphiden_tekrar_yazmaz()
    {
        if (!_olgu.Baglandi(nameof(Tur6_belge_uretim_fisine_donusur_belge_baglanir_maliyet_Delphiden_tekrar_yazmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], ct);
        await AktarAsync(b, t, "fn_aktar_stok", Stoklar);
        await AktarAsync(b, t, "fn_aktar_belge", Belgeler);
        Assert.Equal(3, await b.TekDegerAsync<long>(
            "select count(*) from public.belge where tur = 6 and aktarim_tablo = 'FATBASLIK' and aktarim_id between 990006101 and 990006103",
            t, [], ct));

        var ilk = await CalistirAsync(b, t, "fn_aktarim_uretim_fisi_kur");
        // Paket dışı (gerçek kurulumdan kalan) belgeler de sayılabilir; bu paketin kayıtları satır bazında doğrulanır.
        Assert.True(Sayi(ilk, "fis_eklenen") >= 1);
        Assert.True(Sayi(ilk, "mamulsuz_atlanan") >= 1);
        Assert.True(Sayi(ilk, "taslak_atlanan") >= 1);

        // Başlık: ana ürün, miktar, durum 2, seviye aktarim, sarf = giriş = aynı belge, Delphi maliyeti.
        Assert.Equal("AKT006101|2|aktarim|AKT-UF-MAMUL|1.000000|889.1400|820.0400|820.0400|ayni|Delphi üretimi",
            await b.TekDegerAsync<string>("""
                select f.no || '|' || f.durum || '|' || f.seviye || '|' || st.kod || '|' || f.uretilen || '|' || f.malzeme || '|' ||
                       f.toplam || '|' || f.birim_maliyet || '|' ||
                       case when f.sarf_belge_id = f.giris_belge_id and f.fire_belge_id is null then 'ayni' else 'farkli' end || '|' || f.aciklama
                  from public.uretim_fisi f join public.stok st on st.id = f.stok_id
                 where f.aktarim_tablo = 'FATBASLIK' and f.aktarim_id = 990006101
                """, t, [], ct));

        // Satırlar: grup 1 sarf (mutlak miktar / tutar), grup 4 ana ürün; belge satırına bağlı.
        Assert.Equal("1:AKT-UF-HAM1:4.000000:3.2000:0 1:AKT-UF-HAM2:2.000000:885.9400:0 4:AKT-UF-MAMUL:1.000000:820.0400:1",
            await b.TekDegerAsync<string>("""
                select string_agg(s.grup || ':' || st.kod || ':' || s.miktar || ':' || s.tutar || ':' || s.ana_urun, ' ' order by s.grup, s.sira, s.id)
                  from public.uretim_fisi_satir s
                  join public.uretim_fisi f on f.id = s.fis_id
                  join public.stok st on st.id = s.stok_id
                 where f.aktarim_tablo = 'FATBASLIK' and f.aktarim_id = 990006101
                   and s.belge_satir_id in (select bs.id from public.belge_satir bs join public.belge bb on bb.id = bs.belge_id
                                             where bb.aktarim_tablo = 'FATBASLIK' and bb.aktarim_id = 990006101)
                """, t, [], ct));

        // Belge fişe bağlı (kaynak_tur 61 = fiş); fişin "Belgeler" sorgusu onu bulur.
        Assert.Equal(1L, await b.TekDegerAsync<long>("""
            select count(*) from public.belge bb join public.uretim_fisi f on f.id = bb.kaynak_id and bb.kaynak_tur = 61
             where bb.aktarim_tablo = 'FATBASLIK' and bb.aktarim_id = 990006101 and f.aktarim_id = 990006101
            """, t, [], ct));

        // Mamulsüz ve taslak belgeye fiş açılmaz.
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.uretim_fisi where aktarim_tablo = 'FATBASLIK' and aktarim_id in (990006102, 990006103)", t, [], ct));

        // Mamulün son / ortalama maliyeti Delphi üretim girişini görür (tür 6 artı satır).
        Assert.Equal(820.04m, await b.TekDegerAsync<decimal>(
            "select public.fn_uretim_stok_son_maliyeti((select id from public.stok where kod = 'AKT-UF-MAMUL' order by id desc limit 1))", t, [], ct));

        // İkinci çağrı: bu paket için hiçbir şey yazmaz.
        var once = await b.TekDegerAsync<long>("select count(*) from public.uretim_fisi where aktarim_tablo = 'FATBASLIK'", t, [], ct);
        var iki = await CalistirAsync(b, t, "fn_aktarim_uretim_fisi_kur");
        Assert.Equal(0, Sayi(iki, "fis_eklenen"));
        Assert.Equal(once, await b.TekDegerAsync<long>("select count(*) from public.uretim_fisi where aktarim_tablo = 'FATBASLIK'", t, [], ct));

        await t.RollbackAsync(ct);
    }
}
