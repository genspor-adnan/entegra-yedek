using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

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

    public sealed class TasiIstegi
    {
        public long[]? Idler { get; set; }
        public int Hedef { get; set; }
    }

    public sealed class YanitIstegi
    {
        public bool Kabul { get; set; }
        public string? Aciklama { get; set; }
    }


    /// <summary>KAYIT KAPSAMI (K26): kimlikli uçlar gelen belgeyi liste kaynağının (şube) kuralıyla açar.</summary>
    private const string GelenKaynagi = "gelen-belge";
    private const string GelenYok = "Gelen belge bulunamadı.";

    private static Gentegre.Veri.Depolar.YazmaBaglami Baglam(dynamic baglam, HttpContext ctx)
        => new(baglam.KullaniciId, (int?)baglam.SubeId, BaglamCozucu.IpCoz(ctx));

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

            var bitis = istek?.Bitis ?? Saat.Bugun;
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
            long id, BaglamCozucu cozucu, EBelgeGelen gelen, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            // KAYIT KAPSAMI (K26): gelen belge aktif şubenin olmalı (liste kuralı).
            await erisim.IsteAsync(baglam, GelenKaynagi, id, GelenYok, iptal);
            var xml = await gelen.IcerikIndirAsync(id, baglam.SubeId, baglam.KullaniciId, iptal);
            return Results.Ok(new { ubl = xml, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/gelen-belge/{id}/mesajlar - gelen belgenin gecmisi (189).
        grup.MapGet("/{id:long}/mesajlar", async (
            long id, BaglamCozucu cozucu, Gentegre.Veri.VeriKaynagi veri, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            // KAYIT KAPSAMI (K26): gelen belge aktif şubenin olmalı.
            await erisim.IsteAsync(baglam, GelenKaynagi, id, GelenYok, iptal);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = new Npgsql.NpgsqlCommand(
                "select sira, tarih, olay, durum, kod, aciklama from public.fn_gelen_mesajlar(@p0) order by sira",
                baglanti);
            komut.Parameters.AddWithValue("p0", id);

            var liste = new List<object>();
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                liste.Add(new
                {
                    sira = o.GetInt32(0),
                    tarih = o.IsDBNull(1) ? (DateTime?)null : o.GetDateTime(1),
                    olay = o.IsDBNull(2) ? "" : o.GetString(2),
                    durum = o.IsDBNull(3) ? "" : o.GetString(3),
                    kod = o.IsDBNull(4) ? "" : o.GetString(4),
                    aciklama = o.IsDBNull(5) ? "" : o.GetString(5),
                });

            return Results.Ok(new { mesajlar = liste, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gelen-belge/tasi - Delphi "'Gelen Kutusu'na / 'Kullanım Dışı'na Taşı"
        //   (1037). Sisteme (2) yalniz aktarimla gecilir; aktarilmis belge geri tasinmaz.
        grup.MapPost("/tasi", async (TasiIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
                                     HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            if (istek.Hedef is not (1 or 3))
                throw GentegreHatasi.Dogrulama("Hedef 1 (Gelen Kutusu) ya da 3 (Kullanım Dışı) olmalı.");
            var idler = (istek.Idler ?? []).Distinct().Take(500).ToArray();
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.e_belge set tasnif = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where yon = 2 and id = any(@p0) and coalesce(belge_id, 0) = 0 and tasnif <> @p1
                   and (@p3 = 0 or coalesce(sube_id, 0) in (0, @p3))
                """, null, [idler, (short)istek.Hedef, baglam.KullaniciId, baglam.SubeId ?? 0], iptal);
            var ad = istek.Hedef == 1 ? "Gelen Kutusu" : "Kullanım Dışı";
            return Results.Ok(new { tasinan = n, mesaj = $"{n} belge '{ad}'na taşındı."
                + (n < idler.Length ? $" {idler.Length - n} belge atlandı (zaten orada ya da alış faturasına aktarılmış)." : ""),
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gelen-belge/{id}/yanit - kabul / red.
        //   KABUL edilen belge ALIS FATURASINA da aktarilir (kullanici: "onaydan
        //   sonra ana listeye gecsin"): kutuda kalan belge muhasebeye girmez,
        //   cari borcu ancak fatura kaydiyla dogar. Aktarim hatasi yaniti GERI
        //   ALDIRMAZ - yanit GIB'e gitti, geri alinamaz; kullaniciya sebep
        //   soylenir ve "Faturaya Aktar" ile elle tekrarlanabilir.
        grup.MapPost("/{id:long}/yanit", async (
            long id, YanitIstegi istek, BaglamCozucu cozucu, EBelgeGelen gelen,
            GelenBelgeAktar aktar, KayitErisimi erisim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            // KAYIT KAPSAMI (K26): gelen belge aktif şubenin olmalı (`/tasi` ile aynı süzgeç).
            await erisim.IsteAsync(baglam, GelenKaynagi, id, GelenYok, iptal);
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
                    ek = " Ancak alış belgesine aktarılamadı: " + h.Message;
                }
            }

            return Results.Ok(new { s.Basarili, mesaj = s.Mesaj + ek, belgeId,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/gelen-belge/{id}/aktar - alis faturasi olustur.
        //   Yanit gerektirmeyen belgeler (temel fatura, e-Arsiv) ve kabulde
        //   aktarim basarisiz kalan belgeler icin ayri adim.
        grup.MapPost("/{id:long}/aktar", async (
            long id, BaglamCozucu cozucu, GelenBelgeAktar aktar, KayitErisimi erisim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);
            // KAYIT KAPSAMI (K26): gelen belge aktif şubenin olmalı.
            await erisim.IsteAsync(baglam, GelenKaynagi, id, GelenYok, iptal);
            var a = await aktar.AktarAsync(id, Baglam(baglam, ctx), iptal);
            return Results.Ok(new { a.BelgeId, a.BelgeNo, a.SatirSayisi, a.EslesenStok,
                                    a.Mesaj, izlemeNo = baglam.IzlemeNo });
        });
    }
}
