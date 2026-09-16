using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖNDERİM KUYRUĞU & AYARLAR (707) — mockup <c>medula_kuyruk.html</c>.
/// Bekleyen / hatalı / tamamlanan satırlar, günlük özet, hata kodu dağılımı,
/// hesap ve bağlantı testi. İstek/yanıt gövdesi yalnız <c>medula.ayar</c>
/// yetkisiyle okunur (kişisel veri).
/// </summary>
public static partial class MedulaUclari
{
    public sealed record KuyrukGonderIstegi(bool? HatalilarDa, int? EnFazla);

    private static void KuyrukUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/kuyruk", async (
            int? durum, string? q, int? enFazla, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            var kosul = durum switch
            {
                1 => "q.durum in (1, 2)", 4 => "q.durum in (4, 5)", 3 => "q.durum = 3", _ => "1 = 1",
            };
            var arama = "%" + (q ?? "").Trim() + "%";
            var satirlar = await KuyrukListesiAsync(b,
                kosul + " and (q.sube_id = @p0 or @p0 = 0) and (q.hasta_adi ilike @p1 or q.islem ilike @p1 or q.sonuc_kod ilike @p1 or q.sonuc_mesaj ilike @p1)",
                [sube, arama], Math.Clamp(enFazla ?? 200, 1, 1000), iptal);

            var ozet = await b.TekAsync("""
                select count(*) filter (where ekleme_tarihi >= current_date)::int as bugun,
                       count(*) filter (where durum in (1, 2))::int as bekleyen,
                       count(*) filter (where durum = 4)::int as hata,
                       count(*) filter (where durum = 5)::int as elle,
                       count(*) filter (where ekleme_tarihi >= current_date and durum = 3)::int as bugun_kabul,
                       coalesce(round(avg(sure_ms) filter (where ekleme_tarihi >= current_date and gonderim is not null))::int, 0) as ort_ms,
                       min(sonraki_deneme) filter (where durum = 1) as sonraki,
                       max(gonderim) filter (where durum = 3) as son_kabul
                  from public.medula_kuyruk where (sube_id = @p0 or @p0 = 0)
                """, null, [sube], o => new
            {
                bugun = o.GetInt32(0), bekleyen = o.GetInt32(1), hata = o.GetInt32(2), elle = o.GetInt32(3), bugunKabul = o.GetInt32(4),
                ortMs = o.GetInt32(5), sonraki = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                sonKabul = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
            }, iptal);

            var servisler = await b.ListeAsync("""
                select islem, count(*)::int, count(*) filter (where durum = 3)::int, count(*) filter (where durum in (4, 5))::int,
                       coalesce(round(avg(sure_ms) filter (where gonderim is not null))::int, 0)
                  from public.medula_kuyruk where ekleme_tarihi >= current_date and (sube_id = @p0 or @p0 = 0)
                 group by islem order by 2 desc
                """, null, [sube], o => new { islem = o.GetString(0), cagri = o.GetInt32(1), kabul = o.GetInt32(2), hata = o.GetInt32(3), ortMs = o.GetInt32(4) }, iptal);

            var hataKodlari = await b.ListeAsync("""
                select sonuc_kod, max(sonuc_mesaj), count(*)::int
                  from public.medula_kuyruk where durum in (4, 5) and sonuc_kod <> '' and ekleme_tarihi >= date_trunc('month', now())
                   and (sube_id = @p0 or @p0 = 0)
                 group by sonuc_kod order by 3 desc limit 20
                """, null, [sube], o => new { kod = o.GetString(0), mesaj = o.GetString(1), adet = o.GetInt32(2) }, iptal);

            var hesap = await b.TekAsync("""
                select id, coalesce(kurum_kodu, ''), coalesce(kullanici_adi, ''), coalesce(url, ''), coalesce(test_url, ''), coalesce(test_mi, 1),
                       son_kullanim, coalesce(son_sonuc, ''), sube_id
                  from public.entegrasyon_hesap where kod = 'MEDULA' order by (sube_id = @p0) desc, id limit 1
                """, null, [sube], o => new
            {
                id = o.GetInt32(0), tesisKodu = o.GetString(1), kullaniciAdi = o.GetString(2), url = o.GetString(3), testUrl = o.GetString(4),
                testMi = o.GetInt16(5) == 1, sonKullanim = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), sonSonuc = o.GetString(7),
                subeId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
            }, iptal);

            var ayarlar = await b.ListeAsync("select anahtar, deger, tip, coalesce(aciklama, '') from public.referans where anahtar like 'medula.%' order by anahtar",
                null, [], o => new { anahtar = o.GetString(0), deger = o.GetString(1), tip = o.GetString(2), aciklama = o.GetString(3) }, iptal);

            return Results.Ok(new { satirlar, ozet, servisler, hataKodlari, hesap, ayarlar });
        });

        grup.MapGet("/kuyruk/{id:long}/govde", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.ayar", Islem.Gor);
            var g = await veri.TekAsync("select istek::text, coalesce(yanit::text, ''), servis, islem from public.medula_kuyruk where id = @p0", [id],
                o => new { istek = o.GetString(0), yanit = o.GetString(1), servis = o.GetString(2), islem = o.GetString(3) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(g);
        });

        grup.MapPost("/kuyruk/gonder", async (
            KuyrukGonderIstegi? istek, MedulaServisi medula, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Degistir);
            var s = await medula.KuyrukCalistirAsync(Math.Clamp(istek?.EnFazla ?? 100, 1, 500), baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                istek?.HatalilarDa ?? false, iptal, hemen: true);
            return Results.Ok(new { s.denenen, s.kabul, s.bekleyen, s.hata, s.aciklama });
        });

        grup.MapPost("/kuyruk/{id:long}/tekrar", async (
            long id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var s = await medula.DeneAsync(b, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        grup.MapPost("/kuyruk/{id:long}/iptal", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Degistir);
            var n = await veri.CalistirAsync("update public.medula_kuyruk set durum = 6, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum in (1, 4, 5)",
                [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yalnız bekleyen / hatalı satır iptal edilir.");
            return Results.NoContent();
        });

        // Bağlantı testi: kapıya "mustehaklikSorgu" değil, hafif bir yoklama - simülasyonda ayar/hesap durumu.
        grup.MapPost("/hesap/test", async (
            IMedulaKapisi kapi, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var basla = DateTime.UtcNow;
            try
            {
                var y = await kapi.CagirAsync(b, "hastaCikisKayit", System.Text.Json.JsonDocument.Parse("{}").RootElement, null, null, null, iptal);
                await b.CalistirAsync("update public.entegrasyon_hesap set son_kullanim = now(), son_sonuc = @p0 where kod = 'MEDULA'", null, ["test: " + y.Kod], iptal);
                return Results.Ok(new { acik = true, kod = y.Kod, mesaj = y.Mesaj, sureMs = (int)(DateTime.UtcNow - basla).TotalMilliseconds, simulasyon = kapi is MedulaSimulasyonKapisi });
            }
            catch (Exception h)
            {
                await b.CalistirAsync("update public.entegrasyon_hesap set son_kullanim = now(), son_sonuc = @p0 where kod = 'MEDULA'", null, ["hata: " + h.Message], iptal);
                return Results.Ok(new { acik = false, kod = "2001", mesaj = h.Message, sureMs = (int)(DateTime.UtcNow - basla).TotalMilliseconds, simulasyon = kapi is MedulaSimulasyonKapisi });
            }
        });
    }
}
