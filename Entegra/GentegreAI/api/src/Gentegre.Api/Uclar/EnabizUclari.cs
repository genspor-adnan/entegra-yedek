using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// e-NABIZ UÇLARI — kuyruk kartı, veri kalitesi, yeniden üretim, gönderim,
/// iptal.
///
/// Muayene uçlarıyla aynı dosyadaydı; oysa ayrı bir API grubudur
/// (<c>/api/enabiz</c>), muayeneden başka kaynaklardan da beslenir (başvuru,
/// çıkış) ve muayene dosyasını 1.400 satıra çıkarıyordu. Kod değişmedi,
/// yalnız kendi dosyasına taşındı.
/// </summary>
public static class EnabizUclari
{
    public static void EnabizUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/enabiz").WithTags("e-Nabız").RequireAuthorization();

        // GET /api/enabiz/paket/{id} - PAKET KARTI (454).
        //
        // Kuyrukta "Eksik Alan" yazan satirin cevabi burada: hangi USS alani
        //   bos, hangi kaynak kolondan gelmesi gerekiyordu, kacinci denemede
        //   ne hatasi alindi. SALT OKUNUR: paket elle duzeltilmez, kaynak
        //   duzeltilip yeniden uretilir.
        grup.MapGet("/paket/{id:long}", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var paket = await baglanti.TekAsync("""
                select p.id, p.paket_no as "paketNo", t.kod as "turKod", t.ad as "turAdi",
                       t.uss_paket_kodu as "ussPaket", t.uss_surum as "ussSurum",
                       p.islem, p.kaynak_tur as "kaynakTur", p.kaynak_id as "kaynakId",
                       coalesce(h.unvan, '') as "hastaAdi", p.hasta_id as "hastaId",
                       coalesce(k.ad, '') as "hekimAdi",
                       p.olay_tarihi as "olayTarihi", p.uretim_tarihi as "uretimTarihi",
                       p.son_tarih as "sonTarih", p.planlanan, p.durum, p.deneme,
                       p.son_deneme as "sonDeneme", p.uss_paket_id as "ussPaketId",
                       p.hata_kodu as "hataKodu", p.hata_mesaj as "hataMesaj",
                       p.hata_sinifi as "hataSinifi", p.icerik_hash as "icerikHash",
                       p.onceki_paket_id as "oncekiPaketId",
                       t.zorunlu_alanlar as "zorunluAlanlar"
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                  left join public.taraf h on h.id = p.hasta_id
                  left join public.v_personel_lookup k on k.id = p.hekim_id
                 where p.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (paket is null)
                return Results.NotFound(new { hata = new
                    { kod = "BULUNAMADI", mesaj = "Paket bulunamadı." } });

            // ALANLAR: gecersiz olanlar USTTE - ekranin isi eksigi gostermek.
            var alanlar = await baglanti.ListeAsync("""
                select a.uss_alan as "ussAlan", a.deger, a.kaynak_alan as "kaynakAlan",
                       a.skrs_liste as "skrsListe", a.gecerli, a.sorun, a.sira
                  from public.enabiz_paket_alan a
                 where a.paket_id = @p0
                 order by a.gecerli asc, a.sira, a.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var denemeler = await baglanti.ListeAsync("""
                select g.zaman, g.ortam, g.http_kod as "httpKod", g.sonuc,
                       g.uss_kod as "ussKod", g.uss_mesaj as "ussMesaj",
                       g.sure_ms as "sureMs"
                  from public.enabiz_gonderim g
                 where g.paket_id = @p0
                 order by g.zaman desc, g.id desc
                 limit 20
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { paket, alanlar, denemeler, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/enabiz/veri-kalitesi?ay=YYYY-MM - UYUM PANOSU (454).
        //
        // Mockup: Ekranlar/E-Nabiz/enabiz_veri_kalitesi.html. Soru sunucuda
        //   cevaplanir: alti ayri istek atmak ekranin yarisini bos gosterirdi.
        grup.MapGet("/veri-kalitesi", async (
            string? ay, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            // Donem: "2026-09" -> ayin ilk gunu. Verilmezse icinde bulundugumuz ay.
            var bas = DateTime.TryParse((ay ?? "") + "-01", out var d)
                ? new DateTime(d.Year, d.Month, 1)
                : new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var son = bas.AddMonths(1);

            await using var baglanti = await veri.AcAsync(iptal);

            var sayac = await baglanti.TekAsync("""
                select count(*) as "uretilen",
                       count(*) filter (where p.durum = 3) as "gonderilen",
                       count(*) filter (where p.durum = 3 and p.deneme <= 1) as "ilkDenemede",
                       -- SURE SINIRI: paketin son_tarih'i gecmeden gonderildi mi?
                       count(*) filter (where p.durum = 3 and p.son_tarih is not null
                                          and p.son_deneme <= p.son_tarih) as "suredeGiden",
                       count(*) filter (where p.durum = 3 and p.son_tarih is not null)
                           as "sureOlculen",
                       count(*) filter (where p.durum = 4) as "hatali",
                       count(*) filter (where p.durum = 0) as "eksikAlanli",
                       count(*) filter (where p.durum in (1, 2)) as "bekleyen"
                  from public.enabiz_paket p
                 where p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                   and (@p2 = 0 or p.sube_id = @p2)
                """, null, [bas, son, baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ESLENMEMIS KOD: gecersiz alanin SKRS listesi varsa eksik olan bir
            //   kod eslemesidir - "kod eslemeye git" isaretini bu sayi verir.
            var eslemeEksik = await baglanti.ListeAsync("""
                select a.skrs_liste as "skrsListe", count(distinct a.deger) as "adet"
                  from public.enabiz_paket_alan a
                  join public.enabiz_paket p on p.id = a.paket_id
                 where a.gecerli = 0 and coalesce(a.skrs_liste, '') <> ''
                   and p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by a.skrs_liste order by 2 desc limit 10
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            var turler = await baglanti.ListeAsync("""
                select t.kod, t.ad, t.uss_paket_kodu as "ussPaket",
                       count(p.id) as "uretilen",
                       count(p.id) filter (where p.durum = 3) as "gonderilen",
                       count(p.id) filter (where p.durum = 4) as "hatali",
                       count(p.id) filter (where p.durum = 0) as "eksik"
                  from public.enabiz_paket_turu t
                  left join public.enabiz_paket p on p.paket_turu_id = t.id
                       and p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by t.id, t.kod, t.ad, t.uss_paket_kodu, t.aktif
                 order by t.aktif desc, count(p.id) desc, t.ad
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            // EN SIK HATA: kok neden burada gorunur - ayni hata yuz paketi
            //   birden dusuruyorsa duzeltilecek tek yer vardir.
            var hatalar = await baglanti.ListeAsync("""
                select coalesce(nullif(p.hata_kodu, ''), 'BILINMIYOR') as "kod",
                       max(p.hata_mesaj) as "mesaj", p.hata_sinifi as "sinif",
                       count(*) as "adet"
                  from public.enabiz_paket p
                 where p.durum = 4 and p.uretim_tarihi >= @p0 - interval '30 days'
                 group by 1, p.hata_sinifi order by count(*) desc limit 8
                """, null, [bas], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ALAN BAZINDA EKSIK: "neyi duzeltirsem kac paket kurtulur".
            var eksikAlanlar = await baglanti.ListeAsync("""
                select a.uss_alan as "ussAlan", max(a.kaynak_alan) as "kaynakAlan",
                       max(a.sorun) as "sorun", count(distinct a.paket_id) as "paket"
                  from public.enabiz_paket_alan a
                  join public.enabiz_paket p on p.id = a.paket_id
                 where a.gecerli = 0 and p.durum in (0, 4)
                 group by a.uss_alan order by count(distinct a.paket_id) desc limit 10
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var hekimler = await baglanti.ListeAsync("""
                select coalesce(k.ad, '(hekimsiz)') as "hekim",
                       count(*) as "paket",
                       count(*) filter (where p.durum = 0) as "eksik",
                       count(*) filter (where p.durum = 3) as "gonderilen"
                  from public.enabiz_paket p
                  left join public.v_personel_lookup k on k.id = p.hekim_id
                 where p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by 1 having count(*) filter (where p.durum = 0) > 0
                 order by 3 desc limit 10
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gunluk = await baglanti.ListeAsync("""
                -- generate_series TIMESTAMPTZ uretir; gun aritmetigi icin DATE'e
                --   cevrilir (timestamptz + integer diye bir islec yok).
                select g.gun as "gun",
                       count(p.id) as "uretilen",
                       count(p.id) filter (where p.durum = 3) as "gonderilen",
                       count(p.id) filter (where p.durum = 4) as "hatali"
                  from (select d::date as gun
                          from generate_series(current_date - 13, current_date,
                                               interval '1 day') d) g
                  left join public.enabiz_paket p
                         on p.uretim_tarihi >= g.gun and p.uretim_tarihi < g.gun + 1
                 group by g.gun order by g.gun
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                donem = bas.ToString("yyyy-MM"),
                sayac, turler, hatalar, eksikAlanlar, eslemeEksik, hekimler, gunluk,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/enabiz/paket/{id}/yeniden-uret
        grup.MapPost("/paket/{id:long}/yeniden-uret", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var p = await veri.TekAsync("""
                select t.kod, p.kaynak_id, p.durum
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0
                """, [id],
                o => new { Kod = o.GetString(0), KaynakId = o.GetInt32(1),
                           Durum = o.GetInt16(2) }, iptal);

            if (p is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Paket bulunamadi." } });
            if (p.Durum == 3)
                throw GentegreHatasi.IsKurali(
                    "Gonderilmis paket yeniden uretilemez; duzeltme icin guncelleme paketi gerekir.");

            // ESKI PAKET IPTAL EDILIR, yenisi acilir: ayni kaynaktan iki
            //   bekleyen paket kalirsa USS'ye ayni olay iki kez giderdi.
            await veri.CalistirAsync("""
                update public.enabiz_paket set durum = 5, degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);

            var s = await enabiz.UretAsync(p.Kod, p.KaynakId, baglam.KullaniciId, iptal);
            return Results.Ok(new { eskiPaket = id, yeni = s?.PaketNo ?? "",
                                    durum = s?.Durum ?? (short)0,
                                    eksikler = s?.Eksikler ?? [],
                                    mesaj = s is null ? "Paket uretilemedi."
                                          : s.Durum == 0
                                              ? "Paket uretildi ama zorunlu alan hala eksik."
                                              : "Paket yeniden uretildi, kuyrukta.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/enabiz/paket/{id}/gonder - "Şimdi Gönder" (elle)
        //   Zamanlayıcıyı beklemeden denemek için. Hesap tanımlı değilse
        //   sonuç bunu SÖYLER; sahte başarı yok.
        grup.MapPost("/paket/{id:long}/gonder", async (
            long id, BaglamCozucu cozucu, Servisler.EnabizGonderimi gonderim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var s = await gonderim.CalistirAsync(1, id, baglam.KullaniciId, iptal);
            return Results.Ok(new { id, s.Alinan, s.Gonderilen, s.Hatali,
                                    mesaj = s.Aciklama, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/enabiz/paket/{id}/iptal
        //
        // IKI AYRI IPTAL (602). Paketin GONDERILIP GONDERILMEDIGINE gore:
        //
        //  · HENUZ GITMEDIYSE (durum 0 bekleyen / 1 eksik / 4 hatali) is
        //    yereldir: paket durum 5'e cekilir, USS'nin haberi olmaz.
        //
        //  · GONDERILDIYSE (durum 3) yerel isaret YETMEZ - veri USS'de durur.
        //    Kilavuzun karsiligi ayri bir PAKETTIR: 301 Hasta Kayit Silme,
        //    govdesinde 101'in dondurdugu SYSTakipNo ile
        //    (dokuman/09_ENABIZ_USS_SEMASI.md). Burada o paket URETILIR ve
        //    kuyruga girer; gonderim isi onu yollayinca USS kaydi silinir.
        //    Kaynak paket, silme paketi BASARIYLA gidene kadar durum 3'te
        //    kalir - "iptal edildi" demek, iptalin USS'ye ulastigini bilmeden
        //    yanlis olurdu.
        grup.MapPost("/paket/{id:long}/iptal", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici uretici,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var p = await veri.TekAsync("""
                select p.durum, p.kaynak_id, coalesce(p.sys_takip_no, ''),
                       coalesce(t.uss_paket_kodu, '')
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0
                """, [id],
                o => new { Durum = o.GetInt16(0), Kaynak = o.GetInt32(1),
                           Takip = o.GetString(2), Kod = o.GetString(3) }, iptal);
            if (p is null) return Results.NotFound();

            // --- GONDERILMIS PAKET: USS'ye SILME paketi gonderilir ---
            if (p.Durum == 3)
            {
                // HER PAKETIN KENDI SILME KARSILIGI (628):
                //   101 hasta kaydi -> 301 Hasta Kayit Silme
                //   102 islem        -> 302 Hizmet Silme
                // Otekiler (103 muayene, 106 cikis) icin USS'de silme paketi
                //   YOK - onlar kaynagi duzeltip yeniden gonderilerek
                //   guncellenir.
                var silmeKodu = p.Kod switch
                {
                    "101" => "HASTA_KABUL_SIL",
                    "102" => "HASTA_ISLEM_SIL",
                    _ => "",
                };
                if (silmeKodu.Length == 0)
                    throw GentegreHatasi.IsKurali(
                        $"Gonderilmis {p.Kod} paketinin USS'de silme karsiligi yok; "
                        + "kaynagi duzeltip yeniden gonderin.");
                if (p.Takip.Length == 0)
                    throw GentegreHatasi.IsKurali(
                        "Paketin SYS takip numarasi yok - USS'de hangi kaydin "
                        + "silinecegi bilinemez. Once gonderim yanitini tazeleyin.");

                var silme = await uretici.UretAsync(silmeKodu, p.Kaynak,
                                                    baglam.KullaniciId, iptal);
                if (silme is null)
                    throw GentegreHatasi.IsKurali("Silme paketi uretilemedi.");

                // URETICI MEVCUDU DA DONDURUR (ayni icerik -> ayni paket).
                //   Donen paket ZATEN GONDERILMISSE kuyruga hicbir sey
                //   girmedi; "kuyruga alindi" demek kullaniciyi bekleyen bir
                //   is oldugu sanisina birakirdi.
                if (silme.Durum is 3 or 6)
                    return Results.Ok(new
                    {
                        id, silmePaketId = silme.PaketId, silmePaketNo = silme.PaketNo,
                        mesaj = $"Bu kayit icin silme paketi ({(p.Kod == "102" ? "302" : "301")}) "
                              + $"zaten gonderilmis ({silme.PaketNo}). Yeni bir istek uretilmedi.",
                        izlemeNo = baglam.IzlemeNo
                    });

                // Silme paketi kaynagin takip numarasini TASIR: govde ondan
                //   uretiliyor (EnabizGonderimi.XmlUretAsync, 605).
                await veri.CalistirAsync("""
                    update public.enabiz_paket set sys_takip_no = @p1
                     where id = @p0 and sys_takip_no = ''
                    """, [silme.PaketId, p.Takip], iptal);

                return Results.Ok(new
                {
                    id,
                    silmePaketId = silme.PaketId,
                    silmePaketNo = silme.PaketNo,
                    mesaj = $"Silme paketi ({(p.Kod == "102" ? "302" : "301")}) kuyruga "
                          + "alindi. USS kaydi, paket gonderildikten sonra silinir.",
                    izlemeNo = baglam.IzlemeNo
                });
            }

            // --- HENUZ GITMEMIS PAKET: yerel iptal yeter ---
            var etkilenen = await veri.CalistirAsync("""
                update public.enabiz_paket set durum = 5, degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali(
                    "Bu durumdaki paket iptal edilemez.");

            return Results.Ok(new { id, mesaj = "Paket iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
