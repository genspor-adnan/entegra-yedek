using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BEKLEME SALONU EKRANI (976, mockup <c>Ekranlar/Goz/goz_unite_panosu.html</c>
/// araç çubuğundaki "🖥 Bekleme Ekranı").
///
/// <para><b>Ad MASKELİ döner.</b> Ekran bekleme salonunda, herkesin okuyabildiği
/// bir televizyonda duruyor; tam ad yazmak orada bulunan herkese kimin hangi
/// hekime geldiğini söylemek olurdu. Maskeleme SUNUCUDA yapılıyor
/// (<c>v_goz_bekleme_ekrani</c>): istemciye tam ad hiç gitmiyor, çünkü tarayıcı
/// konsolu da salonun bir parçası.</para>
///
/// <para><b>Ekran yalnız OKUR.</b> Çağırma, taşıma, oda atama panoda kalıyor -
/// salondaki ekranda düğme olsaydı, kimsenin sahiplenmediği bir kayıt girişi
/// açılırdı.</para>
///
/// <para><b>Sıra "çağrılanlar" ve "bekleyenler" olarak ikiye ayrılır:</b>
/// çağrılan hasta ekrana bakıp kalkar, bekleyen hasta kuyrukta kaçıncı
/// olduğunu görür. Tek liste olsaydı çağrının kendisi görünmezdi.</para>
/// </summary>
public static partial class GozUclari
{
    /// <summary>Çağrı bu süreden eski ise ekrandan düşer (hasta ya girdi ya gelmedi).</summary>
    private const int CagriGosterimDk = 10;

    private static void PanoUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/bekleme-ekrani", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // ÇAĞRILANLAR: büyük puntoyla en üstte. Son 10 dakika - daha eski
            //   çağrı ekranda kalırsa salon "benim adım hâlâ yazıyor" diye
            //   bekler ve gerçek sıra görünmez olur.
            var cagrilanlar = await baglanti.ListeAsync("""
                select b.istasyon_id, b.maskeli_ad, b.kaynak_adi, b.istasyon,
                       b.hekim_adi, b.cagri_dk, b.dilatasyon_durum
                  from public.v_goz_bekleme_ekrani b
                 where b.cagri_zamani is not null
                   and b.cagri_zamani >= now() - make_interval(mins => @p1)
                   and (@p0::int is null or b.sube_id = @p0)
                 order by b.cagri_zamani desc
                 limit 6
                """, null, [baglam.SubeId, CagriGosterimDk], o => new
            {
                id = o.GetInt32(0),
                ad = o.IsDBNull(1) ? "" : o.GetString(1),
                kaynak = o.GetString(2),
                istasyon = (int)o.GetInt16(3),
                hekim = o.GetString(4),
                cagriDk = o.IsDBNull(5) ? 0 : o.GetInt32(5),
                dilatasyon = (int)o.GetInt16(6),
            }, iptal);

            // BEKLEYENLER: istasyon sırasına göre, en uzun bekleyen başta.
            //   Çağrılmış olan da listede kalır (çağrıldı ama henüz girmedi) -
            //   listeden düşürmek, gelmeyen hastanın sırasını kaybetmesi demek.
            var bekleyenler = await baglanti.ListeAsync("""
                select b.istasyon_id, b.maskeli_ad, b.istasyon, b.kaynak_adi,
                       b.bekleme_dk, b.sira_no, b.hekim_adi, b.dilatasyon_durum,
                       case when b.cagri_zamani is null then 0 else 1 end as cagrildi
                  from public.v_goz_bekleme_ekrani b
                 where (@p0::int is null or b.sube_id = @p0)
                 order by b.istasyon, b.bekleme_dk desc
                 limit 60
                """, null, [baglam.SubeId], o => new
            {
                id = o.GetInt32(0),
                ad = o.IsDBNull(1) ? "" : o.GetString(1),
                istasyon = (int)o.GetInt16(2),
                kaynak = o.GetString(3),
                beklemeDk = o.GetInt32(4),
                siraNo = (int)o.GetInt16(5),
                hekim = o.GetString(6),
                dilatasyon = (int)o.GetInt16(7),
                cagrildi = o.GetInt32(8) == 1,
            }, iptal);

            return Results.Ok(new
            {
                zaman = DateTime.UtcNow,
                cagrilanlar,
                bekleyenler,
                // Dilatasyon sayacı salonda da görünüyor: damlası biten hasta
                //   "beni atladılar mı" diye bankoya gitmesin.
                dilatasyonda = bekleyenler.Count(b => b.dilatasyon > 0),
                dilatasyonHazir = bekleyenler.Count(b => b.dilatasyon == 1),
            });
        });
    }
}
