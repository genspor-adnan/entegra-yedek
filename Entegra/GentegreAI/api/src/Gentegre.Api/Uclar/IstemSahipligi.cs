using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSTEMİ SİLME / İPTAL KAPISI (kullanıcı 15.10.2026: "dr olarak kendi istediğim tetkikleri
/// silmek istedim ama yetki yok diyor.. başkasının isteği olursa silemem").
///
/// <para>Modül yetkisi olan (lab, radyoloji, göz, patoloji personeli) eskisi gibi siler.
/// Olmayan hekim yalnız MUAYENE yetkisiyle ve yalnız KENDİ açtığı istemi siler - istemi açan
/// muayene_istem.ekleyen'dir (muayeneden istem ucu yazar) - ve istem başvuruya henüz
/// işlenmemiş olmalı (serbest = 0). Başkasının ya da işlenmiş istem modülde / bankoda iptal edilir.</para>
/// </summary>
internal static class IstemSahipligi
{
    /// <param name="muayeneden">Muayene ekranından mı (kullanıcı: "başvuru kaydı yapıldıysa buradan hiç
    /// kimse silemez") - öyleyse başvuruya işlenmiş istem modül yetkisi olana da reddedilir.</param>
    public static async Task IsteAsync(IstekBaglami baglam, NpgsqlConnection b, string modulYetki, Islem islem,
                                       string hedefTablo, int hedefId, bool muayeneden, CancellationToken iptal)
    {
        if (muayeneden && await IslendiMiAsync(b, hedefTablo, hedefId, iptal))
            throw GentegreHatasi.IsKurali("Bu istem başvuruya işlendi (kaydı yapıldı); muayeneden silinemez - banko ya da ilgili birim iptal eder.");
        if (baglam.Yetkiler.Var(modulYetki, islem))
        {
            baglam.YazmaIste();
            return;
        }
        baglam.YetkiIste("muayene", Islem.Degistir);
        var ekleyen = await b.TekDegerAsync<int?>(
            "select ekleyen from public.muayene_istem where hedef_tablo = @p0 and hedef_id = @p1 order by id limit 1",
            null, [hedefTablo, hedefId], iptal);
        if (ekleyen != baglam.KullaniciId)
            throw GentegreHatasi.Yasak("Yalnız kendi istediğiniz istemi silebilirsiniz; bu istemi başka bir hekim açtı.");
        // BAŞVURUYA İŞLENMEMİŞ OLMALI (kullanıcı: "eğer ben istemişsem ve başvuruda kaydı yapılmamışsa
        //   silinebilir"): serbest = 0 banko kaydı bekliyor; 1 = başvuruya işlendi ya da acil/yatan
        //   olduğu için modül çalışmaya başlayabilir - o istemi modül / banko iptal eder.
        //   Tablo adı yukarıdaki sabit listeden gelir (çağıranlar sabit yazar), istekten gelmez.
        if (await IslendiMiAsync(b, hedefTablo, hedefId, iptal))
            throw GentegreHatasi.IsKurali("Bu istem başvuruya işlendi (kaydı yapıldı); silinemez - banko ya da ilgili birim iptal eder.");
    }

    private static async Task<bool> IslendiMiAsync(NpgsqlConnection b, string hedefTablo, int hedefId, CancellationToken iptal)
    {
        if (!SerbestTablolari.Contains(hedefTablo))
            throw new InvalidOperationException($"Bilinmeyen istem tablosu: {hedefTablo}");
        var serbest = await b.TekDegerAsync<short?>(
            $"select serbest from public.{hedefTablo} where id = @p0", null, [hedefId], iptal);
        return serbest == 1;
    }

    private static readonly HashSet<string> SerbestTablolari =
        ["lab_istem", "radyoloji_istem", "goz_goruntuleme", "pat_vaka"];
}
