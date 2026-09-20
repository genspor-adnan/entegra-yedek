using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÜN SONU ÖZETİ VE GÖNDERİM ORANI (884 — KTS maddeleri H13 / D24).
///
/// <para>Ekran iki soruyu birden cevaplar: "gün sonu gönderiliyor mu" ve
/// "gönderim oranı %95-103 aralığında mı". İkisi ayrı ekranda olsaydı,
/// oranı düşük bir günün gün sonu kaydına bakmak için ekran değiştirmek
/// gerekirdi.</para>
/// </summary>
public static class EnabizGunSonuUclari
{
    public sealed record HesapIstegi(string? Tarih, int? SubeId, bool? PaketUret);
    /// <summary>Ay sonu isteği (885): yıl + ay.</summary>
    public sealed record AyIstegi(int? Yil, int? Ay, int? SubeId, bool? PaketUret);

    /// <summary>Bakanlığın beklediği aralık - ekran bunun dışını kırmızı gösterir.</summary>
    private const decimal AltSinir = 95m;
    private const decimal UstSinir = 103m;

    public static void EnabizGunSonuUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/enabiz/gun-sonu").WithTags("e-Nabız").RequireAuthorization();

        // ------------------------------------------------------- pano ----
        grup.MapGet("/", async (
            string? bas, string? bit, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Gor);
            var baslangic = DateOnly.TryParse(bas, out var b1) ? b1
                : DateOnly.FromDateTime(DateTime.Now.AddDays(-14));
            var bitis = DateOnly.TryParse(bit, out var b2) ? b2 : DateOnly.FromDateTime(DateTime.Now);

            await using var b = await veri.AcAsync(iptal);
            var gunler = await b.ListeAsync("""
                select g.id, g.tarih, g.sube_id, g.durum, g.hesap_zamani,
                       coalesce(p.paket_no, ''), p.durum as paket_durum,
                       (select count(*) from public.enabiz_gun_sonu_satir s where s.gun_sonu_id = g.id)::int,
                       (select coalesce(sum(s.sayi), 0) from public.enabiz_gun_sonu_satir s
                         where s.gun_sonu_id = g.id)::int
                  from public.enabiz_gun_sonu g
                  left join public.enabiz_paket p on p.id = g.paket_id
                 where g.tarih between @p0 and @p1
                   and (@p2 = 0 or g.sube_id = @p2)
                 order by g.tarih desc
                """, null, [baslangic, bitis, baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt64(0), tarih = o.GetDateTime(1), subeId = o.GetInt32(2),
                durum = (int)o.GetInt16(3), hesapZamani = o.GetDateTime(4),
                paketNo = o.GetString(5),
                paketDurum = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6),
                olcut = o.GetInt32(7), toplam = o.GetInt32(8),
            }, iptal);

            // GÖNDERİM ORANI: gün ve paket türü bazında üretilen/gönderilen.
            var oranlar = await b.ListeAsync("""
                select tarih, uss_paket_kodu, uretilen, gonderilen, bekleyen, hatali,
                       coalesce(oran, 0)
                  from public.v_enabiz_gonderim_orani
                 where tarih between @p0 and @p1
                 order by tarih desc, uss_paket_kodu
                """, null, [baslangic, bitis], o => new
            {
                tarih = o.GetDateTime(0), paketKodu = o.GetString(1), uretilen = o.GetInt32(2),
                gonderilen = o.GetInt32(3), bekleyen = o.GetInt32(4), hatali = o.GetInt32(5),
                oran = o.GetDecimal(6),
            }, iptal);

            var toplamUretilen = oranlar.Sum(x => x.uretilen);
            var toplamGonderilen = oranlar.Sum(x => x.gonderilen);
            var genelOran = toplamUretilen == 0 ? 0m
                : Math.Round(100m * toplamGonderilen / toplamUretilen, 1);

            return Results.Ok(new
            {
                baslangic, bitis, gunler, oranlar,
                ozet = new
                {
                    toplamUretilen, toplamGonderilen, genelOran,
                    altSinir = AltSinir, ustSinir = UstSinir,
                    aralikta = toplamUretilen > 0 && genelOran >= AltSinir && genelOran <= UstSinir,
                },
            });
        });

        // -------------------------------------------------- gün detayı ----
        grup.MapGet("/{id:long}", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select s.skrs_kod, coalesce(o.ad, ''), s.sayi
                  from public.enabiz_gun_sonu_satir s
                  left join public.enabiz_gun_sonu_olcut o on o.skrs_kod = s.skrs_kod
                 where s.gun_sonu_id = @p0 order by s.skrs_kod
                """, null, [id], o => new
            { skrsKod = (int)o.GetInt16(0), ad = o.GetString(1), sayi = o.GetInt32(2) }, iptal);
            return Results.Ok(new { satirlar });
        });

        // ---------------------------------------------- ay sonu (885) ----
        // 407 tesis toplamını gönderir, 408 aynı ölçütleri KLİNİK kırılımıyla.
        //   Ekran ikisini bir arada gösterir: denetimde "gün sonu / ay sonu
        //   gönderiliyor mu" tek soru gibi sorulur.
        grup.MapGet("/ay", async (
            int? yil, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var aylar = await b.ListeAsync("""
                select a.id, a.yil, a.ay, a.durum, a.hesap_zamani,
                       coalesce(p.paket_no, ''), p.durum as paket_durum,
                       (select count(distinct s.klinik_kodu) from public.enabiz_ay_sonu_satir s
                         where s.ay_sonu_id = a.id)::int,
                       (select count(*) from public.enabiz_ay_sonu_satir s
                         where s.ay_sonu_id = a.id)::int
                  from public.enabiz_ay_sonu a
                  left join public.enabiz_paket p on p.id = a.paket_id
                 where (cast(@p0 as integer) is null or a.yil = @p0)
                   and (@p1 = 0 or a.sube_id = @p1)
                 order by a.yil desc, a.ay desc limit 24
                """, null, [yil, baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt64(0), yil = (int)o.GetInt16(1), ay = (int)o.GetInt16(2),
                durum = (int)o.GetInt16(3), hesapZamani = o.GetDateTime(4),
                paketNo = o.GetString(5),
                paketDurum = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6),
                klinik = o.GetInt32(7), satir = o.GetInt32(8),
            }, iptal);

            // KLİNİK KODU OLMAYAN BÖLÜMLER: işleri 408'e GİRMEZ - eksiklik
            //   ekranda görünsün, sessizce sayı düşürmesin.
            var kodsuz = await b.ListeAsync(
                "select ad, muayene_sayisi from public.v_enabiz_klinik_kodsuz order by muayene_sayisi desc",
                null, [], o => new { ad = o.GetString(0), muayene = o.GetInt32(1) }, iptal);
            return Results.Ok(new { aylar, kodsuzBolumler = kodsuz });
        });

        grup.MapGet("/ay/{id:long}", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select s.klinik_kodu, coalesce(d.ad, ''), s.skrs_kod, coalesce(o.ad, ''), s.sayi
                  from public.enabiz_ay_sonu_satir s
                  left join public.departman d on d.kod = s.klinik_kodu
                  left join public.enabiz_gun_sonu_olcut o on o.skrs_kod = s.skrs_kod
                 where s.ay_sonu_id = @p0 order by s.klinik_kodu, s.skrs_kod
                """, null, [id], o => new
            {
                klinikKodu = o.GetString(0), klinik = o.GetString(1),
                skrsKod = (int)o.GetInt16(2), ad = o.GetString(3), sayi = o.GetInt32(4),
            }, iptal);
            return Results.Ok(new { satirlar });
        });

        grup.MapPost("/ay/hesapla", async (
            AyIstegi? istek, EnabizGunSonuServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Degistir);
            var d = DateTime.Now.AddMonths(-1);
            var yil = istek?.Yil ?? d.Year;
            var ay = istek?.Ay ?? d.Month;
            if (ay is < 1 or > 12) throw GentegreHatasi.Dogrulama("Ay 1-12 arası olmalı.");
            if (new DateTime(yil, ay, 1) > new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1))
                throw GentegreHatasi.Dogrulama("Gelecek bir ayın özeti hesaplanamaz.");

            var s = await servis.AyHesaplaAsync(yil, ay, istek?.SubeId ?? baglam.SubeId ?? 0,
                baglam.KullaniciId, istek?.PaketUret ?? true, iptal);
            return Results.Ok(new { s.AySonuId, s.Yil, s.Ay, s.KlinikSayisi, s.SatirSayisi,
                                    s.PaketNo, mesaj = s.Aciklama });
        });

        // ------------------------------------------------------ hesapla ----
        // Elle tetikleme: zamanlı iş gece çalışır ama geç girilen kayıtlardan
        //   sonra gün yeniden hesaplanabilmeli (satırlar güncellenir).
        grup.MapPost("/hesapla", async (
            HesapIstegi? istek, EnabizGunSonuServisi servis, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.gun_sonu", Islem.Degistir);
            var tarih = DateOnly.TryParse(istek?.Tarih, out var t) ? t
                : DateOnly.FromDateTime(DateTime.Now.AddDays(-1));
            if (tarih > DateOnly.FromDateTime(DateTime.Now))
                throw GentegreHatasi.Dogrulama("Gelecek bir günün gün sonu hesaplanamaz.");

            var s = await servis.HesaplaAsync(tarih, istek?.SubeId ?? baglam.SubeId ?? 0,
                baglam.KullaniciId, istek?.PaketUret ?? true, iptal);
            return Results.Ok(new { s.GunSonuId, tarih = s.Tarih, s.OlcutSayisi, s.ToplamSayi,
                                    s.PaketNo, mesaj = s.Aciklama });
        });
    }
}
