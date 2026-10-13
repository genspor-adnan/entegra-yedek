using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - SALT OKUNUR KİP (1089): veri_kaynagi = delphi iken aktarılan
/// satır web'den değişmez / silinmez, aktarılan kaynakta yeni kayıt açılmaz (cari
/// rolü dahil), stok bakiyesine yazılmaz - hata GK422 (API 422). Aktarım (fn_aktar_paket)
/// geçer; web'in kendi taraf kaydı (personel) açılır; veri_kaynagi = web iken kural yok.
/// İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimSaltOkunurTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Savepoint içinde çalıştırır; GK422 bekleniyorsa mesajı döner, yoksa null.</summary>
    private static async Task<string?> RedAsync(NpgsqlConnection b, NpgsqlTransaction t, string sql)
    {
        await t.SaveAsync("sn");
        try
        {
            await b.CalistirAsync(sql, t, [], CancellationToken.None);
            await t.ReleaseAsync("sn");
            return null;
        }
        catch (PostgresException e) when (e.SqlState == "GK422")
        {
            await t.RollbackAsync("sn");
            return e.MessageText;
        }
    }

    [VtFact]
    public async Task Delphi_kipinde_aktarilan_veri_web_den_degismez_aktarim_gecer()
    {
        if (!_olgu.Baglandi(nameof(Delphi_kipinde_aktarilan_veri_web_den_degismez_aktarim_gecer))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync("update public.kurum_profil set veri_kaynagi = 'delphi' where sube_id = 0", t, [], ct);
        var anahtar = await b.TekDegerAsync<string>("select public.fn_aktarim_ajan_ekle('salt okunur testi')", t, [], ct);
        var ajan = await b.TekDegerAsync<int>("select public.fn_aktarim_ajan_bul(@p0)", t, [anahtar], ct);

        // Aktarım oturumu geçer.
        var sonuc = await b.TekDegerAsync<string>("select public.fn_aktar_paket(@p0, @p1::jsonb)->>'hata'", t, [ajan, """
            {"paket": "so-1", "U": {"REHBER": [{"id": 990006201, "kod": "AKT-SO-CARI", "firma": "Salt Okunur Carisi", "durum": 1}]}}
            """], ct);
        Assert.Null(sonuc);
        // Aynı işlemde devam ettiğimiz için aktarım oturumunu kapat (API'de her paket ayrı işlem).
        await b.CalistirAsync("select set_config('gentegre.aktarim', '', true)", t, [], ct);

        const string cari = "public.taraf where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = 990006201";
        Assert.Contains("Delphi", await RedAsync(b, t, $"update {cari.Replace("public.taraf where", "public.taraf set unvan = 'x' where")}"));
        Assert.NotNull(await RedAsync(b, t, $"delete from {cari}"));
        Assert.NotNull(await RedAsync(b, t, $"insert into public.taraf_adres (taraf_id, adres) select id, 'web adresi' from {cari}"));
        Assert.Contains("yeni cariyi", await RedAsync(b, t,
            "insert into public.taraf (kod, unvan, durum, musteri, tedarikci, sube_id) values ('AKT-SO-YENI', 'Web carisi', 1, 1, 0, 1)"));
        Assert.NotNull(await RedAsync(b, t,
            "insert into public.depo (ad, durum, varsayilan, sube_id) values ('Web deposu (aktarım testi)', 1, 0, 1)"));
        Assert.NotNull(await RedAsync(b, t, "update public.stok_durum set min_stok = min_stok where stok_id = (select min(stok_id) from public.stok_durum)"));

        // Web'in kendi kaydı: personel / kişi açılır, ama cari rolü verilemez.
        Assert.Null(await RedAsync(b, t,
            "insert into public.taraf (kod, unvan, durum, musteri, tedarikci, sube_id) values ('AKT-SO-PER', 'Web personeli', 1, 0, 0, 1)"));
        Assert.NotNull(await RedAsync(b, t, "update public.taraf set musteri = 1 where kod = 'AKT-SO-PER'"));

        // Kip web: kural yok.
        await b.CalistirAsync("update public.kurum_profil set veri_kaynagi = 'web' where sube_id = 0", t, [], ct);
        Assert.Null(await RedAsync(b, t, $"update {cari.Replace("public.taraf where", "public.taraf set unvan = 'Web düzeltti' where")}"));
        await t.RollbackAsync();
    }
}
