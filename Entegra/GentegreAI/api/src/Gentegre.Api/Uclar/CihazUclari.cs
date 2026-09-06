using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// CİHAZ UÇLARI — v1 (432).
///
/// <para><b>Ham mesaj ucu (/mesaj) İSTEMCİ İÇİN DEĞİL:</b> ağa doğrudan
/// bağlanamayan cihazların önüne konan küçük aracılar (masaüstü köprü) ve
/// TEST içindir. Cihazların çoğu MLLP dinleyicisine ya da izlenen klasöre
/// yazar.</para>
/// </summary>
public static class CihazUclari
{
    public sealed record MesajIstegi(int CihazId, string Ham, string? Kaynak);

    public static void CihazUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/cihaz").WithTags("Cihaz").RequireAuthorization();

        // POST /api/cihaz/mesaj - ham mesajı kuyruğa al
        grup.MapPost("/mesaj", async (
            MesajIstegi istek, BaglamCozucu cozucu, CihazServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cihaz", Islem.Ekle);

            if (string.IsNullOrWhiteSpace(istek.Ham))
                throw GentegreHatasi.Dogrulama("Mesaj boş.",
                    [new("ham", "Cihaz mesajı gerekli.")]);

            var sonuc = await servis.AlAsync(istek.CihazId, istek.Ham,
                                             istek.Kaynak ?? "el ile", iptal);
            return Results.Ok(new { sonuc.MesajId, sonuc.Durum, sonuc.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/cihaz/mesaj/{id}/yeniden-isle - sürücü düzeltildikten sonra
        grup.MapPost("/mesaj/{id:long}/yeniden-isle", async (
            long id, BaglamCozucu cozucu, CihazServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cihaz.isle", Islem.Degistir);

            var sonuc = await servis.YenidenIsleAsync(id, iptal);
            return Results.Ok(new { id, sonuc.Durum, sonuc.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/cihaz/mesaj/{id} - ham metin + çözümlenmiş kalemler
        grup.MapGet("/mesaj/{id:long}", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cihaz", Islem.Gor);

            var m = await veri.TekAsync("""
                select m.id, c.kod, c.ad, m.protokol, m.mesaj_tipi, m.kontrol_no,
                       m.ornek_no, m.istem_no, m.hasta_no, m.cihaz_zamani, m.ham,
                       m.kaynak, m.durum, m.hata, m.ekleme_tarihi
                  from public.cihaz_mesaj m join public.cihaz c on c.id = m.cihaz_id
                 where m.id = @p0
                """, [id],
                o => new { Id = o.GetInt64(0), CihazKod = o.GetString(1),
                           CihazAd = o.GetString(2), Protokol = o.GetString(3),
                           MesajTipi = o.GetString(4), KontrolNo = o.GetString(5),
                           OrnekNo = o.GetString(6), IstemNo = o.GetString(7),
                           HastaNo = o.GetString(8),
                           CihazZamani = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                           Ham = o.GetString(10), Kaynak = o.GetString(11),
                           Durum = o.GetInt16(12), Hata = o.GetString(13),
                           EklemeTarihi = o.GetDateTime(14) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Mesaj bulunamadı.");

            var kalemler = await veri.ListeAsync("""
                select sira, test_kodu, test_adi, deger, sayisal, birim, referans,
                       isaret, durum, olcum_zamani
                  from public.cihaz_mesaj_kalem where mesaj_id = @p0 order by sira, id
                """, [id],
                o => new { Sira = o.GetInt32(0), TestKodu = o.GetString(1),
                           TestAdi = o.GetString(2), Deger = o.GetString(3),
                           Sayisal = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                           Birim = o.GetString(5), Referans = o.GetString(6),
                           Isaret = o.GetString(7), Durum = o.GetString(8),
                           OlcumZamani = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9) },
                iptal);

            return Results.Ok(new { mesaj = m, kalemler, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/cihaz/klasor-tara - izlenen klasörleri şimdi tara
        grup.MapPost("/klasor-tara", async (
            BaglamCozucu cozucu, CihazServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cihaz.isle", Islem.Degistir);

            var (okunan, hatali) = await servis.KlasorleriTaraAsync(iptal);
            return Results.Ok(new { okunan, hatali,
                mesaj = $"{okunan} dosya alındı, {hatali} hata.",
                izlemeNo = baglam.IzlemeNo });
        });
    }
}
