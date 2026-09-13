using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ KURUM NUMUNESİ - BAŞVURUSUZ İSTEM (637).
///
/// İstem ya bir BAŞVURUYA ya bir DIŞ KURUMA bağlıdır; kararı servis verir
/// (`LabServisi.IstemAcAsync`). Veritabanı kısıtı DAHA DAR bir söz tutar:
/// kaynağı "dış kurum" (4) olan istem gönderen kurumu YAZMIŞ olmalı - fatura
/// ona kesilir, sonuç ona teslim edilir.
///
/// <para><b>Kısıt neden dar:</b> "belgesiz istem yasak" konulamıyor. Sistemde
/// 134 belgesiz istem var (göç) ve mikrobiyoloji / genetik test düzenekleri de
/// belgesiz istem kuruyor - geniş kısıt göçü ve 22 testi düşürüyordu. Bu test
/// dar kısıtın gerçekten işlediğini doğrular: "not valid" yazıp doğrulamamak,
/// kuralın hiç işlemediğini fark etmemek olurdu.</para>
/// </summary>
public sealed class DisKurumNumunesiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [Fact]
    public async Task Kaynak_dis_kurum_ise_GONDEREN_KURUM_zorunlu()
    {
        if (!_olgu.Baglandi(nameof(Kaynak_dis_kurum_ise_GONDEREN_KURUM_zorunlu))) return;
        var veri = _olgu.Gerekli();

        var tanimli = await veri.TekDegerAsync<int>("""
            select count(*) from pg_constraint
             where conrelid = 'public.lab_istem'::regclass
               and conname = 'ck_lab_istem_dis_kurum'
            """, null, CancellationToken.None);
        Assert.Equal(1, tanimli);

        // Kaynak 4 ama kurum YOK: reddedilmeli.
        var hata = await Assert.ThrowsAnyAsync<Exception>(async () =>
            await veri.CalistirAsync("""
                insert into public.lab_istem
                       (taraf_id, sube_id, istem_no, bolum, durum, kaynak)
                values (0, 0, 'TEST-637-KURUMSUZ', 1, 1, 4)
                """, null, CancellationToken.None));
        Assert.Contains("ck_lab_istem_dis_kurum", hata.Message,
                        StringComparison.OrdinalIgnoreCase);

        // Yazılmadığını da doğrula: mesaj doğru ama satır kalmış olsaydı test
        //   yeşil görünüp veriyi kirletirdi.
        Assert.Equal(0, await veri.TekDegerAsync<int>(
            "select count(*) from public.lab_istem where istem_no = 'TEST-637-KURUMSUZ'",
            null, CancellationToken.None));
    }

    /// <summary>
    /// BELGESİZ İSTEM YASAK DEĞİL: kısıt yalnız kaynak 4'e bakar. Göç
    /// satırları ve öteki modüllerin düzenekleri yerinde kalmalı - geniş bir
    /// kısıt eklendiğinde tam burası kırılmıştı.
    /// </summary>
    [Fact]
    public async Task Belgesiz_istem_KAYNAK_1_ISE_kabul_edilir()
    {
        if (!_olgu.Baglandi(nameof(Belgesiz_istem_KAYNAK_1_ISE_kabul_edilir))) return;
        var veri = _olgu.Gerekli();

        await veri.CalistirAsync("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak)
            values (0, 0, 'TEST-637-BELGESIZ', 1, 1, 1)
            """, null, CancellationToken.None);
        try
        {
            Assert.Equal(1, await veri.TekDegerAsync<int>(
                "select count(*) from public.lab_istem where istem_no = 'TEST-637-BELGESIZ'",
                null, CancellationToken.None));
        }
        finally
        {
            // Test kendi satirini TEMIZLER: paylasilan veriyi kirletmez.
            await veri.CalistirAsync(
                "delete from public.lab_istem where istem_no = 'TEST-637-BELGESIZ'",
                null, CancellationToken.None);
        }
    }
}
