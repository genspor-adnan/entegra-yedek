using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// BAĞLANTI YARDIMCILARI — PARAMETRESİZ SORGU (791).
///
/// Kullanıcı: *"rol kartında bir kullanıcıyı silmek isteyince hata:
/// Beklenmeyen bir hata olustu"* (izleme 01M2SCMS8Q8CVAQZDXY4GMDGFN).
///
/// Kök neden `RolKullaniciDeposu` değildi: `Komut(...)` uzantısı `params
/// object?[] par` alıyor ve `par.Length` okuyordu. `params` dizisi AÇIKÇA
/// `null` geçilebilir - `VeriKaynagi`nin kendi yardımcıları da "parametre yok"
/// için zaten null alıyor. İki tarafın kuralı ayrışınca parametresiz tek bir
/// sorgu (`select id from public.rol where kod = 'atanmamis'`)
/// NullReferenceException veriyordu ve kullanıcıya "beklenmeyen hata" olarak
/// çıkıyordu.
///
/// Test, sorgunun kendisini değil YARDIMCININ SÖZÜNÜ korur: parametresiz sorgu
/// normaldir.
/// </summary>
public sealed class BaglantiYardimcilariTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Parametresiz_sorgu_NULL_dizi_ile_calisir()
    {
        if (!_olgu.Baglandi(nameof(Parametresiz_sorgu_NULL_dizi_ile_calisir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Dört yardımcı da aynı `Komut`u kullanıyor; biri null'a takılırsa
        //   hepsi takılır.
        Assert.Equal(1, await b.TekDegerAsync<int>("select 1", null, null, CancellationToken.None));
        Assert.Equal(0, await b.CalistirAsync(
            "update public.rol set ad = ad where 1 = 0", null, null, CancellationToken.None));
        var liste = await b.ListeAsync("select 1", null, null,
                                       o => o.GetInt32(0), CancellationToken.None);
        Assert.Single(liste);

        // Boş dizi de aynı yoldan geçer (çağrı yerleri iki biçimi de kullanıyor).
        Assert.Equal(1, await b.TekDegerAsync<int>("select 1", null, [], CancellationToken.None));
    }

    [VtFact]
    public async Task Yer_tutucu_rol_DURUYOR()
    {
        if (!_olgu.Baglandi(nameof(Yer_tutucu_rol_DURUYOR))) return;
        var veri = _olgu.Gerekli();

        // Rolden çıkarılan kullanıcı rolsüz bırakılmaz, "Rol Atanmamış"a
        //   düşer. Bu satır silinirse rol kartındaki çıkarma işi iş kuralı
        //   hatasıyla durur - kod bunu bekliyor.
        var id = await veri.TekDegerAsync<int>(
            "select id from public.rol where kod = 'atanmamis'", null, CancellationToken.None);
        Assert.True(id > 0, "Yer tutucu rol (atanmamis) bulunamadı.");
    }
}
