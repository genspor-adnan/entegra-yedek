using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// eMAR — ORDER VE İLAÇ UYGULAMA (698, mockup
/// <c>Ekranlar/Yatan/order_ilac_uygulama.html</c>).
///
/// <para><b>Order bir TALİMAT, uygulama bir OLAY.</b> "Günde 2×1 IV" tek
/// satırdır; 08:00'de verilmiş, 16:00'da gecikmiş olabilir. Bu yüzden çizelge
/// iki tablodan okunur: satır order, hücre o saatin uygulaması.</para>
///
/// <para><b>Uygulama satırları ÖNCEDEN üretilir</b> (698 tetikleyicisi):
/// plan görünmeden takip olmaz. Satır uygulama anında üretilseydi atlanmış doz
/// hiç var olmaz, ekran yalnız verilenleri gösterirdi.</para>
///
/// <para><b>Beş doğru barkodla yapılır</b> (doğru hasta · ilaç · doz · yol ·
/// zaman). Barkodsuz uygulama ENGELLENMEZ — acil durumda hemşireyi ekrana
/// kilitlemek hastaya zarar verir — ama kayıt <c>elle_dogrulandi</c> olarak
/// işaretlenir: ikisi aynı şey değildir ve denetimde de öyle görünmelidir.</para>
///
/// <para><b>Atlanan doz sebepsiz olmaz</b> ve <b>silinmez</b>: "hasta
/// reddetti", "damar yolu yok", "NPO" üçü de klinik bilgidir; silinen satır ise
/// "verilmedi mi, hiç planlanmadı mı" sorusunu cevapsız bırakır.</para>
/// </summary>
public static partial class YatanUclari
{
    /// <summary>Doz uygulama (mockup: uygulama penceresi).</summary>
    public sealed record DozUygulaIstegi(string? Barkod, bool ElleDogrulandi,
                                         decimal? Miktar, string? GecikmeNedeni,
                                         DateTime? UygulananZaman);

    /// <summary>Atlanan doz — sebep ZORUNLU.</summary>
    public sealed record DozAtlaIstegi(string AtlamaNedeni, bool HastaReddetti);

    private static void EmarUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------- eMAR çizelgesi ----
        // TEK İSTEK: order satırları + o günün dozları + özet sayaçlar.
        //   Üçü aynı anda görünüyor; ayrı isteklere bölmek çizelgeyi yarım
        //   çizdirirdi.
        grup.MapGet("/emar", async (
            int yatisId, DateOnly? gun, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Gor);

            var tarih = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);

            // GÜN SINIRI KURUM SAATİNDE: veritabanı UTC çalışıyor, ekran
            //   Türkiye saatini gösteriyor. `planlanan::date = gün` demek,
            //   gece 00:00-03:00 arası dozları BİR ÖNCEKİ günün çizelgesine
            //   düşürüyordu (ekranda 01:00 yazan doz dünün tablosunda
            //   görünüyordu). Aralık, günün yerel 00:00'ının UTC karşılığından
            //   başlar.
            var dilim = Gentegre.Cekirdek.Saat.Dilim(null);
            var gunBas = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(tarih.ToDateTime(TimeOnly.MinValue),
                                     DateTimeKind.Unspecified), dilim);
            var gunSon = gunBas.AddDays(1);

            await using var baglanti = await veri.AcAsync(iptal);

            var orderlar = await baglanti.ListeAsync("""
                select od.id, od.tur, od.ad, od.doz, od.birim, od.yol, od.siklik,
                       od.saatler::text, od.baslangic, od.bitis, od.durum,
                       od.sozel_order, od.onay_tarihi,
                       coalesce(h.unvan, '')  as hekim,
                       coalesce(ky.ad, '')    as yol_ad,
                       coalesce(kt.ad, '')    as tur_ad,
                       -- SON UYGULAYAN çizelgenin son sütunu: "kim verdi"
                       --   sorusu vizitte de nöbet devrinde de soruluyor.
                       -- DIŞ COALESCE ŞART: alt sorgu HİÇ SATIR dönmezse
                       --   (henüz uygulama yok) sonuç NULL olur; içerideki
                       --   coalesce yalnız satır varken çalışır.
                       coalesce((select coalesce(t.unvan, '')
                          from public.order_uygulama u2
                          left join public.taraf t on t.id = u2.uygulayan_id
                         where u2.order_id = od.id and u2.uygulanan is not null
                         order by u2.uygulanan desc limit 1), '') as son_uygulayan
                  from public.yatis_order od
                  left join public.taraf h on h.id = od.hekim_id
                  left join public.kod_deger ky on ky.deger = od.yol
                   and ky.liste_id = (select l.id from public.kod_liste l
                                       where l.kod = 'yatan.order_yol')
                  left join public.kod_deger kt on kt.deger = od.tur
                   and kt.liste_id = (select l.id from public.kod_liste l
                                       where l.kod = 'yatan.order_tur')
                 where od.yatis_id = @p0
                   and (od.durum = 1
                        -- Kapanmış order da GÜNÜN çizelgesinde kalır: o gün
                        --   verilen dozun satırı kaybolursa çizelge geçmişi
                        --   yanlış gösterir.
                        or exists (select 1 from public.order_uygulama u3
                                    where u3.order_id = od.id
                                      and u3.planlanan >= @p1 and u3.planlanan < @p2))
                 order by od.tur, od.ad
                """, null, [yatisId, gunBas, gunSon], o => new
            {
                id = o.GetInt32(0),
                tur = (int)o.GetInt16(1),
                ad = o.GetString(2),
                doz = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                birim = o.GetString(4),
                yol = o.IsDBNull(5) ? (int?)null : (int)o.GetInt16(5),
                siklik = o.GetString(6),
                saatler = o.GetString(7),
                baslangic = o.GetDateTime(8),
                bitis = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                durum = (int)o.GetInt16(10),
                sozelOrder = o.GetInt16(11) == 1,
                imzali = !o.IsDBNull(12),
                hekim = o.GetString(13),
                yolAd = o.GetString(14),
                turAd = o.GetString(15),
                sonUygulayan = o.GetString(16),
            }, iptal);

            var dozlar = await baglanti.ListeAsync("""
                select u.id, u.order_id, u.planlanan, u.uygulanan, u.durum,
                       u.atlama_nedeni, u.gecikme_nedeni, u.miktar, u.barkod,
                       u.elle_dogrulandi, coalesce(t.unvan, '') as uygulayan
                  from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                  left join public.taraf t on t.id = u.uygulayan_id
                 where od.yatis_id = @p0
                   and u.planlanan >= @p1 and u.planlanan < @p2
                 order by u.planlanan, u.id
                """, null, [yatisId, gunBas, gunSon], o => new
            {
                id = o.GetInt64(0),
                orderId = o.GetInt32(1),
                planlanan = o.GetDateTime(2),
                uygulanan = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
                durum = (int)o.GetInt16(4),
                atlamaNedeni = o.GetString(5),
                gecikmeNedeni = o.GetString(6),
                miktar = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7),
                barkod = o.GetString(8),
                elleDogrulandi = o.GetInt16(9) == 1,
                uygulayan = o.GetString(10),
            }, iptal);

            // ÖZET SAYAÇLAR sunucuda: ekran aynı satırları ikinci kez sayıp
            //   kendi "geciken" tanımını üretmesin.
            var ozet = new
            {
                toplam = dozlar.Count,
                uygulanan = dozlar.Count(d => d.durum == 2),
                bekleyen = dozlar.Count(d => d.durum == 1),
                geciken = dozlar.Count(d => d.durum == 5),
                atlanan = dozlar.Count(d => d.durum is 3 or 4),
                barkodsuz = dozlar.Count(d => d.durum == 2 && d.elleDogrulandi),
                imzasizSozel = orderlar.Count(o => o.sozelOrder && !o.imzali && o.durum == 1),
            };

            return Results.Ok(new { gun = tarih, orderlar, dozlar, ozet });
        });

        // --------------------------------------------------- doz uygulandı ----
        grup.MapPost("/doz/{id:long}/uygula", async (
            long id, DozUygulaIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var doz = await baglanti.TekAsync("""
                select u.durum, u.planlanan, od.ad, od.yatis_id
                  from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                 where u.id = @p0
                """, null, [id], o => new
            {
                durum = o.GetInt16(0),
                planlanan = o.GetDateTime(1),
                ad = o.GetString(2),
                yatisId = o.GetInt32(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Doz kaydı bulunamadı.");

            if (doz.durum == 2)
                throw GentegreHatasi.IsKurali("Bu doz zaten uygulanmış.");

            var zaman = istek.UygulananZaman ?? DateTime.Now;

            // GECİKME SEBEBİ: 30 dakikayı geçen dozda sorulur. "Neden geç
            //   verildi" sorusunun cevabı sonradan hatırlanmaz; şimdi
            //   yazılmazsa hiç yazılmaz.
            var gecikti = zaman > doz.planlanan.AddMinutes(30);
            if (gecikti && string.IsNullOrWhiteSpace(istek.GecikmeNedeni))
                throw GentegreHatasi.Dogrulama(
                    "Doz gecikmiş: gecikme sebebi yazılmalı.",
                    new AlanHatasi("gecikmeNedeni", "Zorunlu."));

            // BARKODSUZ UYGULAMA ENGELLENMEZ ama işaretlenir: acil durumda
            //   hemşireyi ekrana kilitlemek hastaya zarar verir. "Elle
            //   doğrulandı" ile barkodlu kaydı aynı göstermek ise kontrolü
            //   kâğıt üstünde bırakırdı.
            var elle = istek.ElleDogrulandi || string.IsNullOrWhiteSpace(istek.Barkod);

            await baglanti.CalistirAsync("""
                update public.order_uygulama
                   set durum = 2, uygulanan = @p1, uygulayan_id = @p2,
                       miktar = coalesce(@p3, miktar),
                       barkod = coalesce(@p4, ''),
                       elle_dogrulandi = @p5,
                       gecikme_nedeni = coalesce(@p6, gecikme_nedeni),
                       atlama_nedeni = '',
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, null,
                [id, zaman, baglam.KullaniciId, istek.Miktar, istek.Barkod?.Trim(),
                 (short)(elle ? 1 : 0), istek.GecikmeNedeni?.Trim()], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, doz.yatisId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    doz = doz.ad,
                    planlanan = doz.planlanan,
                    uygulanan = zaman,
                    dogrulama = elle ? "elle" : "barkod",
                }, iptal: iptal);

            return Results.Ok(new { id, durum = 2, elleDogrulandi = elle, gecikti });
        });

        // ------------------------------------------------------ doz atlandı ----
        grup.MapPost("/doz/{id:long}/atla", async (
            long id, DozAtlaIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan.order", Islem.Degistir);

            // SEBEP ZORUNLU: "hasta reddetti", "damar yolu yok", "NPO" - üçü de
            //   klinik bilgidir ve bir sonraki dozun kararını değiştirir.
            if (string.IsNullOrWhiteSpace(istek.AtlamaNedeni))
                throw GentegreHatasi.Dogrulama("Atlama sebebi yazılmalı.",
                    new AlanHatasi("atlamaNedeni", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);

            var doz = await baglanti.TekAsync("""
                select u.durum, u.planlanan, od.ad, od.yatis_id
                  from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                 where u.id = @p0
                """, null, [id], o => new
            {
                durum = o.GetInt16(0),
                planlanan = o.GetDateTime(1),
                ad = o.GetString(2),
                yatisId = o.GetInt32(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Doz kaydı bulunamadı.");

            if (doz.durum == 2)
                throw GentegreHatasi.IsKurali(
                    "Uygulanmış doz atlanmış yapılamaz; düzeltme için kayıt notu girin.");

            // 4 = Hasta reddetti, 3 = Atlandı. Ayrı durum: hastanın reddi
            //   hemşirenin atlamasıyla aynı şey değildir ve hekime farklı bir
            //   şey söyler.
            var yeni = (short)(istek.HastaReddetti ? 4 : 3);

            await baglanti.CalistirAsync("""
                update public.order_uygulama
                   set durum = @p1, atlama_nedeni = @p2, uygulayan_id = @p3,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, yeni, istek.AtlamaNedeni.Trim(), baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, doz.yatisId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { doz = doz.ad, planlanan = doz.planlanan, atlandi = istek.AtlamaNedeni },
                iptal: iptal);

            return Results.Ok(new { id, durum = yeni });
        });

        // ------------------------------------------- sözel order imzalama ----
        // Sözel order UYGULANIR ama imzasız kalmaz: hekim imzalayana kadar
        //   kırmızı rozetle taşınır ve taburcuyu engeller. İmza AYRI YETKİDİR
        //   (`yatan.order.imza`) - uygulayan hemşire kendi imzalayamaz.
        grup.MapPost("/order/{id:int}/imzala", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.order.imza");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.yatis_order
                   set onay_hekim_id = @p1, onay_tarihi = now(),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and sozel_order = 1 and onay_tarihi is null
                """, null, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Order sözel değil ya da zaten imzalı.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatisOrder, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { imza = "Sözel order imzalandı" }, iptal: iptal);

            return Results.Ok(new { id, imzali = true });
        });
    }
}
