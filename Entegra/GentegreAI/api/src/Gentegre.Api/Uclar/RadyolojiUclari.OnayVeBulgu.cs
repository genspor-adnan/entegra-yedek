using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÖN RAPOR / ONAY, addendum, kritik bulgu, teslim, konsültasyon.
///
/// Uclar RadyolojiUclari.cs dosyasindan ayrildi: tek dosyada 1956 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class RadyolojiUclari
{
    private static void OnayVeBulguEkle(RouteGroupBuilder grup)
    {
        // --------------------------------------------------- ön rapor / onay ----
        // İki aşama: asistan ÖN RAPOR gönderir (durum 2), uzman ONAYLAR
        //   (durum 3 + kilit). Onay ön koşulları veritabanında (284).
        grup.MapPost("/rapor/{id:int}/durum", async (
            int id, string hedef, string? surum, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, Gentegre.Api.Servisler.EnabizPaketUretici enabiz,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // HEDEF BEYAZ LİSTE (kod inceleme raporu 28.10.2026 B06): tanımsız hedef "ön rapor" koluna düşüyordu.
            var onayMi = string.Equals(hedef, "onay", StringComparison.OrdinalIgnoreCase);
            if (!onayMi && !string.Equals(hedef, "on-rapor", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.Dogrulama("Geçersiz hedef: onay ya da on-rapor olmalı.", new AlanHatasi("hedef", "Geçersiz."));
            baglam.AksiyonIste(onayMi ? "rad.rapor_onayla" : "rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // SATIR KİLİDİ (B04 / B06): istem ve rapor kilitlenir; kilit ve onay uygunluğu KİLİDİN ALTINDA denetlenir -
            //   denetim ile yazım arasında başka bir kayıt / onay araya giremez.
            var istemId = await baglanti.TekDegerAsync<int?>(
                "select istem_id from public.radyoloji_rapor where id = @p0", islem, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
            await baglanti.CalistirAsync("select 1 from public.radyoloji_istem where id = @p0 for update",
                islem, [istemId], iptal);
            var satir = await baglanti.TekAsync(
                "select coalesce(kilit, 0)::int, xmin::text from public.radyoloji_rapor where id = @p0 for update",
                islem, [id], o => new { Kilit = o.GetInt32(0), Surum = o.GetString(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
            if (satir.Kilit == 1)
                throw GentegreHatasi.IsKurali("Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");
            // SÜRÜM (kod inceleme raporu 28.10.2026, ikinci tur P2): onaylanan / uzmana giden metin, isteyenin
            //   GÖRDÜĞÜ (kendi kaydettiği) metin olmalı. Arada başkası kaydettiyse 409 - sürümsüz istek de.
            if (surum != satir.Surum)
                throw GentegreHatasi.Cakisma(new { surum = satir.Surum });
            if (onayMi)
            {
                var engel = await baglanti.TekDegerAsync<string>(
                    "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", islem, [id], iptal) ?? "";
                if (engel.Length > 0) throw GentegreHatasi.IsKurali(engel);
            }

            if (onayMi)
            {
                // RESMI RAPOR NUMARASI onayda atanir (303): taslak asamasinda
                //   vermek, vazgecilen raporlarda numara boslugu birakirdi.
                //   Zaten numarali rapor (yeniden onay) numarasini KORUR.
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now()::timestamp,
                           rapor_no = case when rapor_no = ''
                                           then public.fn_radyoloji_rapor_no()
                                           else rapor_no end,
                           degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 5 where id = @p0", islem, [istemId], iptal);
            }
            else
            {
                // Etkilenen satır yoksa istem ve log DEĞİŞMEZ (B06) - kilitli rapor yukarıda zaten reddedildi.
                var degisen = await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set durum = 2, degistiren = @p1, degistirme_tarihi = now()::timestamp
                     where id = @p0 and coalesce(kilit, 0) = 0
                    """, islem, [id, baglam.KullaniciId], iptal);
                if (degisen != 1)
                    throw GentegreHatasi.IsKurali("Rapor ön rapora geçirilemedi (kilitli ya da bulunamadı).");
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set durum = 4 where id = @p0", islem, [istemId], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRapor, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["durum"] = onayMi ? "Onaylandı" : "Ön rapor" },
                iptal: iptal);

            await islem.CommitAsync(iptal);

            // e-NABIZ 409 RADYOLOJI SONUC (883, KTS H10/D19): paket ONAY
            //   sonrasi uretilir - onaylanmamis rapor hastanin dosyasina
            //   girmez, e-Nabiz'a hic girmemeli. Uretim SESSIZDIR: e-Nabiz
            //   ikincil is, raporun onayi onun basarisina bagli degil.
            object? paket = null;
            if (onayMi)
            {
                try
                {
                    var s = await enabiz.UretAsync("RADYOLOJI_SONUC", id, baglam.KullaniciId, iptal);
                    if (s is not null) paket = new { s.PaketNo, s.Durum, s.Eksikler };
                }
                catch (Exception h)
                {
                    ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                       .CreateLogger("enabiz").LogError(h,
                           "e-Nabiz radyoloji sonuc paketi uretilemedi (rapor {Id})", id);
                }
            }

            return Results.Ok(new { tamam = true, paket });
        });

        // -------------------------------------------------------- addendum ----
        // Onaylı rapor kilitlidir; düzeltme AYRI kayıt olarak eklenir ve
        //   orijinal metin korunur.
        grup.MapPost("/rapor/{id:int}/addendum", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_rapor
                       (istem_id, sablon_id, sablon_surum, durum, ust_rapor_id,
                        yazan_id, yazma_tarihi, ekleyen)
                select r.istem_id, r.sablon_id, r.sablon_surum, 1, r.id, @p1, now()::timestamp, @p1
                  from public.radyoloji_rapor r where r.id = @p0
                returning id
                """, null, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                values (@p0, 1, 'Ek Rapor', '', 1)
                """, null, [yeni], iptal);

            return Results.Ok(new { raporId = yeni });
        });

        // ---------------------------------------------------- kritik bulgu ----
        grup.MapPost("/istem/{id:int}/kritik-bulgu", async (
            int id, KritikIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_kritik_bulgu
                       (istem_id, rapor_id, bulgu, bildiren_id, bildirilen_ad, yol,
                        geri_bildirim, ekleyen, teyit_alindi,
                        kapatan_id, kapatma_zamani)
                select @p0,
                       (select id from public.radyoloji_rapor
                         where istem_id = @p0 and ust_rapor_id is null),
                       @p1, @p2, @p3, @p4, @p5, @p2, coalesce(@p6, 0),
                       case when @p7 then @p2 end,
                       case when @p7 then now()::timestamp end
                """, islem, [id, istek.Bulgu ?? "", baglam.KullaniciId,
                             istek.BildirilenAd ?? "", istek.Yol, istek.GeriBildirim ?? "",
                             istek.TeyitAlindi, istek.Kapat], iptal);

            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set kritik = 1 where id = @p0", islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });

        // KRITIK BULGU TAKIBINI KAPAT (318): bildirim yapildi ve karsi taraf
        //   teyit etti - takip listesinden duser. Bildirim kaydi yoksa
        //   kapatilacak bir sey de yok: once bildirim yazilmali.
        grup.MapPost("/istem/{id:int}/kritik-kapat", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.TekDegerAsync<int?>("""
                update public.radyoloji_kritik_bulgu
                   set teyit_alindi = 1, kapatan_id = @p1,
                       kapatma_zamani = now()::timestamp
                 where id = (select max(k.id) from public.radyoloji_kritik_bulgu k
                              where k.istem_id = @p0)
                returning id
                """, null, [id, baglam.KullaniciId], iptal);

            if (etkilenen is null)
                throw GentegreHatasi.IsKurali(
                    "Bu istemde bildirim kaydı yok - önce kritik bulgu bildirimini kaydedin.");

            return Results.Ok(new { tamam = true });
        });

        // -------------------------------------------------- sonuç teslimi ----
        // Film / CD / basılı raporun kime verildiği. Hasta dışında biri
        //   alıyorsa YAKINLIK ve kimlik doğrulaması kayda geçer: sonuç kişisel
        //   sağlık verisidir, "kime verdik" sorusunun cevabı belgede durmalı.
        grup.MapPost("/istem/{id:int}/teslim", async (
            int id, TeslimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.teslim");

            if (string.IsNullOrWhiteSpace(istek.AlanAd))
                throw GentegreHatasi.Dogrulama("Teslim alan kişi yazılmalı.",
                    new AlanHatasi("alanAd", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            // Onaylı rapor varsa teslime BAĞLANIR: hangi rapor sürümünün
            //   verildiği sonradan sorulabiliyor (addendum sonrası önemli).
            var raporId = await baglanti.TekDegerAsync<int?>("""
                select max(id) from public.radyoloji_rapor
                 where istem_id = @p0 and durum = 3
                """, null, [id], iptal);

            await baglanti.CalistirAsync("""
                insert into public.radyoloji_teslim
                    (istem_id, rapor_id, tur, teslim_zamani, teslim_eden_id,
                     alan_ad, alan_yakinlik, kimlik_dogrulandi, aciklama, ekleyen,
                     rapor_verildi, film_verildi, cd_verildi, dijital_verildi)
                values (@p0, @p1, @p2, now()::timestamp, @p3, @p4, @p5, @p6, @p7, @p3,
                        coalesce(@p8, 0), coalesce(@p9, 0),
                        coalesce(@p10, 0), coalesce(@p11, 0))
                """, null,
                [id, raporId, istek.Tur, baglam.KullaniciId, istek.AlanAd,
                 istek.AlanYakinlik ?? "", istek.KimlikDogrulandi, istek.Aciklama ?? "",
                 istek.RaporVerildi, istek.FilmVerildi,
                 istek.CdVerildi, istek.DijitalVerildi], iptal);

            return Results.Ok(new { tamam = true });
        });

        grup.MapGet("/istem/{id:int}/teslimler", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await baglanti.ListeAsync("""
                select t.id, t.tur, t.teslim_zamani as "teslimZamani",
                       coalesce(public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120), '') as "teslimEden", t.alan_ad as "alanAd",
                       t.alan_yakinlik as "alanYakinlik",
                       t.kimlik_dogrulandi as "kimlikDogrulandi", t.aciklama
                  from public.radyoloji_teslim t
                  left join public.taraf p on p.id = t.teslim_eden_id
                 where t.istem_id = @p0 order by t.id desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal));
        });

        // ------------------------------------------------- konsültasyon ----
        // İkinci görüş: raporu yazan radyolog başka bir hekimin/kurumun
        //   görüşünü ister. İstek ve DÖNEN GÖRÜŞ aynı uçtan yazılır - görüş
        //   dolu gelirse kayıt "döndü" (durum 2) sayılır; ayrı bir "cevapla"
        //   ucu, aynı satırın iki sahibi olması demekti.
        grup.MapPost("/istem/{id:int}/konsultasyon", async (
            int id, KonsultasyonIstegi istek, int? konsultasyonId,
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);

            if (konsultasyonId is int kid && kid > 0)
            {
                if (string.IsNullOrWhiteSpace(istek.Gorus))
                    throw GentegreHatasi.Dogrulama("Görüş metni boş olamaz.",
                        new AlanHatasi("gorus", "Zorunlu."));
                await baglanti.CalistirAsync("""
                    update public.radyoloji_konsultasyon
                       set gorus = @p1, durum = 2, donus_zamani = now()::timestamp,
                           degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, null, [kid, istek.Gorus, baglam.KullaniciId], iptal);
                return Results.Ok(new { id = kid });
            }

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Konsültasyon gerekçesi yazılmalı.",
                    new AlanHatasi("gerekce", "Zorunlu."));

            var raporId = await baglanti.TekDegerAsync<int?>(
                "select max(id) from public.radyoloji_rapor where istem_id = @p0",
                null, [id], iptal);

            var yeni = await baglanti.TekDegerAsync<int>("""
                insert into public.radyoloji_konsultasyon
                    (istem_id, rapor_id, hekim_id, kurum_id, durum,
                     gonderim_zamani, gerekce, ekleyen, tip, acil)
                values (@p0, @p1, @p2, @p3, 1, now()::timestamp, @p4, @p5,
                        coalesce(@p6, 1), coalesce(@p7, 0))
                returning id
                """, null,
                [id, raporId, istek.HekimId, istek.KurumId, istek.Gerekce,
                 baglam.KullaniciId, istek.Tip, istek.Acil], iptal);

            return Results.Ok(new { id = yeni });
        });

        grup.MapGet("/istem/{id:int}/konsultasyonlar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await baglanti.ListeAsync("""
                select k.id, k.durum, k.gerekce, k.gorus,
                       k.gonderim_zamani as "gonderimZamani", k.donus_zamani as "donusZamani",
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as "hekim", coalesce(public.fn_taraf_ad(kr.unvan, kr.ad, kr.soyad)::varchar(120), '') as "kurum"
                  from public.radyoloji_konsultasyon k
                  left join public.taraf h on h.id = k.hekim_id
                  left join public.taraf kr on kr.id = k.kurum_id
                 where k.istem_id = @p0 order by k.id desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal));
        });
    }
}
