using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// CARİ KODU GRUPTAN (1191, kullanıcı 26.10.2026): Delphi kod grubu gibi - yeni kartta kod boşsa
/// rolün grubundaki en büyük sayısal son parça + 1, mevcut hane sayısında. Tedarikçi müşteri bayrağını da
/// taşıdığı için önce tedarikçi grubuna bakılır; grup ayarı yoksa null (kod = kayıt no). İşlem içinde, geri alınır.
/// </summary>
public sealed class CariKodGrubuTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Grubun_siradaki_kodu_hane_korunarak_verilir()
    {
        if (!_olgu.Baglandi(nameof(Grubun_siradaki_kodu_hane_korunarak_verilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var iptal = CancellationToken.None;

        async Task<int> Taraf(string kod, int musteri, int tedarikci) =>
            await b.TekDegerAsync<int>(
                "insert into taraf (unvan, kod, musteri, tedarikci, sube_id) values ('_kod_grubu_test', @p0, @p1, @p2, 1) returning id",
                t, [kod, (short)musteri, (short)tedarikci], iptal);
        async Task<string?> Kod(int id) =>
            await b.TekDegerAsync<string>("select public.fn_taraf_kod_uret(@p0)", t, [id], iptal);
        async Task Ayar(string anahtar, string deger) =>
            await b.TekDegerAsync<int>(
                "insert into referans (anahtar, deger) values (@p0, @p1) on conflict (anahtar) do update set deger = excluded.deger returning 1",
                t, [anahtar, deger], iptal);

        await Ayar("cari.kod_grubu_musteri", "");
        await Ayar("cari.kod_grubu_tedarikci", "");
        var bos = await Taraf("", 1, 0);
        Assert.Null(await Kod(bos));                                    // grup yok: ID

        await Ayar("cari.kod_grubu_musteri", "990.77.");                // sondaki nokta yok sayılır
        await Ayar("cari.kod_grubu_tedarikci", "990.78");
        await Taraf("990.77.0041", 1, 0);
        await Taraf("990.77.9X", 1, 0);                                 // sayısal olmayan son parça sayılmaz
        await Taraf("990.770.999", 1, 0);                               // başka grup
        Assert.Equal("990.77.0042", await Kod(await Taraf("", 1, 0)));
        Assert.Equal("990.78.001", await Kod(await Taraf("", 1, 1)));   // tedarikçi (müşteri bayrağı da var), boş grup: 3 hane
        Assert.Null(await Kod(await Taraf("", 0, 0)));                  // rolsüz (kişi vb.)

        await t.RollbackAsync();
    }
}
