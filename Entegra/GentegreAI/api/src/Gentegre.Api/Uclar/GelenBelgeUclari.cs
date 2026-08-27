using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GELEN e-BELGE uclari (187): kutuyu yenile, icerigi indir, kabul/red yanitla.
/// Yetki e-Belge gonderimiyle AYNI kodu kullanir (ebelge.gonder) - e-Belge
/// yetkisi olan kullanici kutuyu da yonetir; ayri bir yetki turetmek matrisi
/// bir satir daha buyutur, karsiligi yok.
/// </summary>
public static class GelenBelgeUclari
{
    public sealed class KutuIstegi
    {
        public DateTime? Baslangic { get; set; }
        public DateTime? Bitis { get; set; }
    }

    public sealed class YanitIstegi
    {
        public bool Kabul { get; set; }
        public string? Aciklama { get; set; }
    }

    private static Gentegre.Veri.Depolar.YazmaBaglami Baglam(dynamic baglam, HttpContext ctx)
        => new(baglam.KullaniciId, (int?)baglam.SubeId,
               ctx.Connection.RemoteIpAddress?.ToString() ?? "");

    public static void GelenBelgeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/gelen-belge").WithTags("GelenBelge").RequireAuthorization();

        // POST /api/gelen-belge/kutu-yenile - entegrator kutusunu tara ve kaydet.
        //   Varsayilan aralik SON 30 GUN: kullanici tarih girmeden tiklayabilsin.
        grup.MapPost("/kutu-yenile", async (
            KutuIstegi? istek, BaglamCozucu cozucu, EBelgeGelen gelen,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var bitis = istek?.Bitis ?? DateTime.Today;
            var baslangic = istek?.Baslangic ?? bitis.AddDays(-30);

            var s = await gelen.KutuCekAsync(baslangic, bitis, baglam.SubeId,
                                             baglam.KullaniciId, iptal);
            return Results.Ok(new
            {
                s.Okunan, s.Yeni, s.Guncellenen,
                mesaj = s.Okunan == 0
                        ? "Bu aralıkta gelen belge yok."
                        : $"{s.Okunan} belge okundu ({s.Yeni} yeni, {s.Guncellenen} güncellendi).",
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // GET /api/gelen-belge/{id}/ubl - UBL XML (ilk cagride entegratorden indirilir).
        grup.MapGet("/{id:long}/ubl", async (
            long id, BaglamCozucu cozucu, EBelgeGelen gelen,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var xml = await gelen.IcerikIndirAsync(id, baglam.SubeId, baglam.KullaniciId, iptal);
            return Results.Ok(new { ubl = xml, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gelen-belge/{id}/yanit - kabul / red.
        //   KABUL edilen belge ALIS FATURASINA da aktarilir (kullanici: "onaydan
        //   sonra ana listeye gecsin"): kutuda kalan belge muhasebeye girmez,
        //   cari borcu ancak fatura kaydiyla dogar. Aktarim hatasi yaniti GERI
        //   ALDIRMAZ - yanit GIB'e gitti, geri alinamaz; kullaniciya sebep
        //   soylenir ve "Faturaya Aktar" ile elle tekrarlanabilir.
        grup.MapPost("/{id:long}/yanit", async (
            long id, YanitIstegi istek, BaglamCozucu cozucu, EBelgeGelen gelen,
            GelenBelgeAktar aktar, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            var s = await gelen.YanitlaAsync(id, istek.Kabul, istek.Aciklama ?? "",
                                             baglam.SubeId, baglam.KullaniciId, iptal);

            string ek = "";
            int? belgeId = null;
            if (istek.Kabul)
            {
                try
                {
                    var a = await aktar.AktarAsync(id, Baglam(baglam, ctx), iptal);
                    belgeId = a.BelgeId;
                    ek = " " + a.Mesaj;
                }
                catch (Exception h)
                {
                    ek = " Ancak alış faturasına aktarılamadı: " + h.Message;
                }
            }

            return Results.Ok(new { s.Basarili, mesaj = s.Mesaj + ek, belgeId,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gelen-belge/{id}/aktar - alis faturasi olustur.
        //   Yanit gerektirmeyen belgeler (temel fatura, e-Arsiv) ve kabulde
        //   aktarim basarisiz kalan belgeler icin ayri adim.
        grup.MapPost("/{id:long}/aktar", async (
            long id, BaglamCozucu cozucu, GelenBelgeAktar aktar,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);
            var a = await aktar.AktarAsync(id, Baglam(baglam, ctx), iptal);
            return Results.Ok(new { a.BelgeId, a.BelgeNo, a.SatirSayisi, a.EslesenStok,
                                    a.Mesaj, izlemeNo = baglam.IzlemeNo });
        });
    }
}
