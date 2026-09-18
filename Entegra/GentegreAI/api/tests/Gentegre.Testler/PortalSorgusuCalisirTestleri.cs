using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PORTAL EKRANLARININ SQL'İ GERÇEKTEN ÇALIŞIYOR MU.
///
/// <para><b>Neden var:</b> 824'te yazılan <c>kurum-belge</c> kaynağı olmayan
/// bir tabloya join'liyordu (<c>public.belge_turu</c>). Kolon adlarını
/// kontrol eden testler bunu göremedi çünkü <b>sorgu hiç çalıştırılmıyordu</b>;
/// hata ancak tarayıcıda "Faturalarım" açılınca 500 olarak göründü.</para>
///
/// <para>Bu sınıf katalogdaki her portal kaynağı için üretilen SQL'i
/// veritabanına <c>limit 0</c> ile gönderir: satır okunmaz, yalnız tablo ve
/// kolonların var olduğu doğrulanır. Menüde duran her ekran açılabilmelidir -
/// açılmayan ekran, her zaman hata veren düğmedir.</para>
/// </summary>
public sealed class PortalSorgusuCalisirTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    public static TheoryData<short> PortalTurleri()
        => new(PortalKapsam.DisDoktor, PortalKapsam.DisKurum, PortalKapsam.Hasta);

    [Theory(DisplayName = "Portal kaynaklarının SQL'i veritabanında çalışır")]
    [MemberData(nameof(PortalTurleri))]
    public async Task Portal_kaynaklari_calisir(short portalTuru)
    {
        if (!_olgu.Baglandi($"{nameof(Portal_kaynaklari_calisir)}({portalTuru})")) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // Kapsam kimliği gerçek bir kayıt olmak zorunda değil: sorgu satır
        //   döndürmeyecek, yalnız PLANLANACAK (tablo/kolon doğrulaması).
        const int kullanici = 1;
        var hatalar = new List<string>();

        var kaynaklar = KaynakKatalogu.PortalKaynaklari(portalTuru);
        // BOŞ LİSTE YEŞİL SAYILMAZ: kapsam kuralları bir gün başka bir yere
        //   taşınırsa bu test sessizce hiçbir şey denemez hale gelirdi.
        Assert.NotEmpty(kaynaklar);

        foreach (var ad in kaynaklar)
        {
            var kaynak = KaynakKatalogu.Bul(ad)!;
            var kolonlar = kaynak.Kolonlar.Where(k => k.Varsayilan).ToList();
            if (kolonlar.Count == 0) continue;

            var parca = new SorguUretici(kaynak, portalTuru, kullanici)
                .Satirlar(new ListeIstegi(), kolonlar, null, null, kullanici);

            await using var komut = new NpgsqlCommand($"select * from ({parca.Sql}) x limit 0", b);
            for (var i = 0; i < parca.Parametreler.Count; i++)
                komut.Parameters.AddWithValue($"p{i}", parca.Parametreler[i] ?? DBNull.Value);
            try
            {
                await using var oku = await komut.ExecuteReaderAsync(Iptal);
            }
            catch (PostgresException h)
            {
                // Tek tek patlamak yerine HEPSİNİ topla: bir ekranı düzeltip
                //   testi yeniden çalıştırıp ötekini görmek yerine liste gelsin.
                hatalar.Add($"{ad} ({portalTuru}): {h.SqlState} {h.MessageText}");
            }
        }

        Assert.True(hatalar.Count == 0, string.Join("\n", hatalar));
    }
}
