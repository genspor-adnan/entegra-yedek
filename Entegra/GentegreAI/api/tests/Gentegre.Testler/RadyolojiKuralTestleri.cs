using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// RADYOLOJİ İSTEMİNİN HİZMETİ (459) — çalışma listesinde modalitesi boş,
/// hiçbir cihaza gönderilemeyen satırlar birikmişti.
///
/// Kural üç giriş yolunda da (kart · muayene · toplu kabul) geçerli olsun
/// diye veritabanı tetiğinde duruyor; testler tetiği doğrular - uygulama
/// katmanı atlansa bile bozuk kayıt oluşmamalı.
/// </summary>
public class RadyolojiKuralTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public RadyolojiKuralTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    /// <summary>Modalitesi verilen (ya da olmayan) bir hizmetin id'si.</summary>
    private async Task<int> HizmetAsync(bool modaliteli)
        => await _olgu.Gerekli().TekDegerAsync<int>(
            "select coalesce(min(id), 0) from public.hizmet "
            + (modaliteli ? "where coalesce(modalite, 0) > 0" : "where coalesce(modalite, 0) = 0"));

    [Fact]
    public async Task Modalitesiz_hizmetle_istem_ACILAMAZ()
    {
        if (!_olgu.Baglandi(nameof(Modalitesiz_hizmetle_istem_ACILAMAZ))) return;
        var veri = _olgu.Gerekli();
        var hizmet = await HizmetAsync(modaliteli: false);
        var hasta = await veri.TekDegerAsync<int>(
            "select coalesce(min(id), 0) from public.taraf where hasta = 1");
        if (hizmet == 0 || hasta == 0) return;

        // Laboratuvar tetkiki radyoloji kuyruğuna düşerse hiçbir cihazda
        //   çekilemez ve MWL'e gönderilemez.
        var h = await Assert.ThrowsAsync<PostgresException>(() => veri.CalistirAsync("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, durum, oncelik, accession_no)
            values (1, @p0, @p1, 1, 1, 'TEST-459')
            """, [hasta, hizmet]));
        Assert.Contains("radyoloji tetkiki degil", h.MessageText, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Modalite_HIZMETTEN_kopyalanir()
    {
        if (!_olgu.Baglandi(nameof(Modalite_HIZMETTEN_kopyalanir))) return;
        var veri = _olgu.Gerekli();
        var hizmet = await HizmetAsync(modaliteli: true);
        var hasta = await veri.TekDegerAsync<int>(
            "select coalesce(min(id), 0) from public.taraf where hasta = 1");
        if (hizmet == 0 || hasta == 0) return;

        // Muayeneden açılan istemde modalite hiç yazılmıyordu; liste "Mod."
        //   kolonunu boş gösteriyordu. Tetik hizmetten kopyalar.
        var id = await veri.TekDegerAsync<int>("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, durum, oncelik, accession_no)
            values (1, @p0, @p1, 1, 1, 'TEST-459')
            returning id
            """, [hasta, hizmet]);
        try
        {
            var mod = await veri.TekDegerAsync<int>(
                "select coalesce(modalite, 0) from public.radyoloji_istem where id = @p0", [id]);
            Assert.True(mod > 0, "modalite hizmetten kopyalanmadı");
        }
        finally
        {
            await veri.CalistirAsync("delete from public.radyoloji_istem where id = @p0", [id]);
        }
    }
}
