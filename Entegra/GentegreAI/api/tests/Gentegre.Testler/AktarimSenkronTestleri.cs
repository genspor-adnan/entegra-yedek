using Gentegre.Veri;
using Npgsql;

using static Gentegre.Testler.AktarimTestYardimcisi;

namespace Gentegre.Testler;

/// <summary>
/// AKTARIM İNCELEMESİ 18.11.2026 (1370) - sürekli senkron: (1) Delphi'de silinen belge web'de bağlı kayıt varsa
/// silinmez, iptal (6) olur - adım düşmez · (6) transferin varış lot satırı her pakette kurulur / güncellenir /
/// silinir · (7) Delphi iptali (DURUM 6) üretim fişini ters kayda çevirir, maliyet ortalamasına girmez ·
/// (2) elle yapılmış şube eşlemesi ezilmez, kopya şube açılmaz · (8, 1371) satırsız tahakkukun satırı her pakette
/// yeniden yazılmaz, değişince güncellenir. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimSenkronTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Ct = CancellationToken.None;

    private static async Task TanimlarAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        await b.CalistirAsync(
            "update public.aktarim_ayar set deger = '2026-01-01' where anahtar = 'hareket_baslangic'", t, [], Ct);
        await AktarAsync(b, t, "fn_aktar_depo", """
            {"U": {"DEPOLAR": [
              {"id": 29701, "depoadi": "AKT-S Depo A", "durum": 1, "varsayilan": 0, "subeid": -1},
              {"id": 29702, "depoadi": "AKT-S Depo B", "durum": 1, "varsayilan": 0, "subeid": -1}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": 990007201, "kod": "AKT-S-CARI", "firma": "Aktarım Senkron Carisi", "durum": 1}]}}
            """);
        await AktarAsync(b, t, "fn_aktar_stok", """
            {"U": {
              "STOKLAR": [{"id": 990007301, "kod": "AKT-S-STOK", "stokadi": "Aktarım senkron stoğu", "durum": 1},
                          {"id": 990007302, "kod": "AKT-S-MAMUL", "stokadi": "Aktarım senkron mamulü", "durum": 1}],
              "STOKSERILOT": [{"id": 990007351, "stokid": 990007301, "lotno": "AKT-S-LOT"}]}}
            """);
    }

    private static Task<int> WebIdAsync(NpgsqlConnection b, NpgsqlTransaction t, string tablo, string aktarimTablo, long id)
        => b.TekDegerAsync<int>($"select id from public.{tablo} where aktarim_kaynak = 1 and aktarim_tablo = @p0 and aktarim_id = @p1",
                                t, [aktarimTablo, id], Ct);

    [VtFact]
    public async Task Silinen_belge_web_kaydina_bagliysa_iptal_olur_adim_dusmez()
    {
        if (!_olgu.Baglandi(nameof(Silinen_belge_web_kaydina_bagliysa_iptal_olur_adim_dusmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync(Ct);
        await using var t = await b.BeginTransactionAsync();
        await TanimlarAsync(b, t);
        await AktarAsync(b, t, "fn_aktar_belge", """
            {"U": {
              "FATBASLIK": [
                {"id": 990007101, "tur": 15, "tipi": 1, "rehberid": 990007201, "faturatarih": "2026-06-01T10:00:00", "fatura_tutari": 100},
                {"id": 990007102, "tur": 15, "tipi": 1, "rehberid": 990007201, "faturatarih": "2026-06-02T10:00:00", "fatura_tutari": 50}],
              "FATURA": [
                {"id": 990007111, "fatbasid": 990007101, "tur": 1, "urunid": 990007301, "miktar": 1, "birimfiyat": 100, "tutar": 100},
                {"id": 990007112, "fatbasid": 990007102, "tur": 1, "urunid": 990007301, "miktar": 1, "birimfiyat": 50, "tutar": 50}]}}
            """);
        var bagli = await WebIdAsync(b, t, "belge", "FATBASLIK", 990007101);
        var bagsiz = await WebIdAsync(b, t, "belge", "FATBASLIK", 990007102);
        // Web'de bu belgeye bağlı bir kayıt (sayım fişi bağı - FK, ON DELETE yok).
        await b.CalistirAsync("""
            insert into public.stok_sayim (sube_id, depo_id, kapsam, aciklama, ekleyen, sayim_no, durum, giris_belge_id)
            values (1, (select min(id) from public.depo), 2, '', 0, 'AKT-S-SYM', 1, @p0)
            """, t, [bagli], Ct);

        var sonuc = await AktarAsync(b, t, "fn_aktar_belge", """{"D": {"FATBASLIK": [990007101, 990007102]}}""");
        Assert.Equal("[990007101]", sonuc["silinemeyen_iptal"]!.ToJsonString());               // eskiden FK hatası, adım düşerdi
        Assert.Equal(6, await b.TekDegerAsync<int>("select durum::int from public.belge where id = @p0", t, [bagli], Ct));
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.mali_hareket where belge_id = @p0", t, [bagli], Ct));        // cari etkisi kalktı
        Assert.Equal(0L, await b.TekDegerAsync<long>("select count(*) from public.belge where id = @p0", t, [bagsiz], Ct));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Transfer_varis_lotu_surekli_senkronda_kurulur_guncellenir_silinir()
    {
        if (!_olgu.Baglandi(nameof(Transfer_varis_lotu_surekli_senkronda_kurulur_guncellenir_silinir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(Ct);
        await using var t = await b.BeginTransactionAsync();
        await TanimlarAsync(b, t);
        static string Paket(int adet) => $$$"""
            {"U": {
              "FATBASLIK": [{"id": 990007401, "tur": 20, "tipi": 1, "rehberid": 0, "faturatarih": "2026-06-03T10:00:00",
                             "cikisdepo": 29701, "girisdepo": 29702}],
              "FATURA": [{"id": 990007411, "fatbasid": 990007401, "tur": 1, "urunid": 990007301, "miktar": {{{adet}}},
                          "birimfiyat": 0, "tutar": 0}],
              "STOKIZLEME": [{"id": 990007421, "stokid": 990007301, "serilotid": 990007351, "baslikid": 990007401,
                              "satirid": 990007411, "belgetur": 20, "izlemtur": 2, "adet": {{{adet}}}}]}}
            """;
        var depoB = await WebIdAsync(b, t, "depo", "DEPOLAR", 29702);
        var stok = await WebIdAsync(b, t, "stok", "STOKLAR", 990007301);
        Task<decimal> LotB() => b.TekDegerAsync<decimal>(
            "select coalesce(sum(kalan), 0) from public.stok_lot_durum where stok_id = @p0 and depo_id = @p1", t, [stok, depoB], Ct);

        await AktarAsync(b, t, "fn_aktar_belge", Paket(5));
        Assert.Equal(5m, await LotB());                                                         // eskiden 0 (varış hiç yazılmıyordu)
        await AktarAsync(b, t, "fn_aktar_belge", Paket(3));
        Assert.Equal(3m, await LotB());                                                         // düzenleme varışa yansır
        await AktarAsync(b, t, "fn_aktar_belge", """{"D": {"FATBASLIK": [990007401]}}""");
        Assert.Equal(0m, await LotB());
        Assert.Equal(0L, await b.TekDegerAsync<long>(
            "select count(*) from public.stok_izleme where aktarim_tablo = 'STOKIZLEME_VARIS' and aktarim_id = 990007421", t, [], Ct));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Delphi_iptali_uretim_fisini_ters_kayda_cevirir_maliyete_girmez()
    {
        if (!_olgu.Baglandi(nameof(Delphi_iptali_uretim_fisini_ters_kayda_cevirir_maliyete_girmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync(Ct);
        await using var t = await b.BeginTransactionAsync();
        await TanimlarAsync(b, t);
        static string Paket(int durum) => $$$"""
            {"U": {
              "FATBASLIK": [{"id": 990007501, "tur": 6, "tipi": 1, "rehberid": 0, "faturatarih": "2026-06-04T10:00:00",
                             "cikisdepo": 29701, "girisdepo": 29701, "durum": {{{durum}}}, "faturano": "AKT-S-URT-1"}],
              "FATURA": [
                {"id": 990007511, "fatbasid": 990007501, "tur": 1, "urunid": 990007301, "miktar": -2, "birimfiyat": 10, "tutar": -20},
                {"id": 990007512, "fatbasid": 990007501, "tur": 1, "urunid": 990007302, "miktar": 1, "birimfiyat": 777, "tutar": 777}]}}
            """;
        var mamul = await WebIdAsync(b, t, "stok", "STOKLAR", 990007302);
        Task<string?> Fis() => b.TekDegerAsync<string>(
            "select durum::text from public.uretim_fisi where aktarim_tablo = 'FATBASLIK' and aktarim_id = 990007501", t, [], Ct);
        Task<decimal> Maliyet() => b.TekDegerAsync<decimal>("select public.fn_uretim_stok_maliyeti(@p0)", t, [mamul], Ct);

        await AktarAsync(b, t, "fn_aktar_belge", Paket(0));
        Assert.Equal("2", await Fis());                                                          // sürekli senkronda fiş kuruldu
        Assert.Equal(777m, await Maliyet());
        await AktarAsync(b, t, "fn_aktar_belge", Paket(6));
        Assert.Equal("0", await Fis());                                                          // eskiden 2 (gerçekleşti)
        Assert.Equal(0m, await Maliyet());                                                       // iptal giriş ortalamada değil
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Elle_sube_eslemesi_ezilmez_kopya_sube_acilmaz()
    {
        if (!_olgu.Baglandi(nameof(Elle_sube_eslemesi_ezilmez_kopya_sube_acilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(Ct);
        await using var t = await b.BeginTransactionAsync();
        // Aktarım bağı olmayan bir web şubesi; Delphi SUBEID -77 kullanıcı tarafından ona eşlenmiş.
        var sube = await b.TekDegerAsync<int>(
            "insert into public.sube (kod, ad, unvan, aktif, varsayilan, ekleyen) values ('AKTS77', 'Elle eşlenen', '', 1, 0, 0) returning id",
            t, [], Ct);
        await b.CalistirAsync("insert into public.aktarim_sube_esleme (delphi_sube_id, sube_id) values (-77, @p0)", t, [sube], Ct);
        var once = await b.TekDegerAsync<long>("select count(*) from public.sube", t, [], Ct);

        await AktarAsync(b, t, "fn_aktar_cari", """
            {"U": {"REHBER": [{"id": -77, "kod": "S77", "firma": "Delphi Şube 77", "durum": 1}]}}
            """);
        Assert.Equal(once, await b.TekDegerAsync<long>("select count(*) from public.sube", t, [], Ct));   // eskiden +1 kopya
        Assert.Equal(sube, await b.TekDegerAsync<int>(
            "select sube_id from public.aktarim_sube_esleme where delphi_sube_id = -77", t, [], Ct));       // eskiden kopyaya ezilirdi
        Assert.Equal("-77/Delphi Şube 77", await b.TekDegerAsync<string>(
            "select aktarim_id || '/' || unvan from public.sube where id = @p0", t, [sube], Ct));           // eşlenen şubeye bağlandı
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Satirsiz_tahakkuk_satiri_her_pakette_yeniden_yazilmaz()
    {
        if (!_olgu.Baglandi(nameof(Satirsiz_tahakkuk_satiri_her_pakette_yeniden_yazilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(Ct);
        await using var t = await b.BeginTransactionAsync();
        await TanimlarAsync(b, t);
        static string Paket(int tutar) => $$$"""
            {"U": {"FATBASLIK": [{"id": 990007601, "tur": 13, "tipi": 1, "rehberid": 990007201,
                                  "faturatarih": "2026-06-05T10:00:00", "aciklama": "Kira tahakkuku", "fatura_tutari": {{{tutar}}}}]}}
            """;
        Task<string?> Satir() => b.TekDegerAsync<string>(
            "select id || '/' || tutar::numeric(10,0) from public.belge_satir where aktarim_tablo = 'FATBASLIK_TK' and aktarim_id = 990007601",
            t, [], Ct);

        await AktarAsync(b, t, "fn_aktar_belge", Paket(100));
        var ilk = await Satir();
        Assert.EndsWith("/100", ilk);
        await AktarAsync(b, t, "fn_aktar_belge", Paket(100));
        Assert.Equal(ilk, await Satir());                                                       // eskiden yeni kimlik
        await AktarAsync(b, t, "fn_aktar_belge", Paket(150));
        Assert.Equal(ilk!.Split('/')[0] + "/150", await Satir());                               // aynı satır güncellendi
        await t.RollbackAsync();
    }
}
