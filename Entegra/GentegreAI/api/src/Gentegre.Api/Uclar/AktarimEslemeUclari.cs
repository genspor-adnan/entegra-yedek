using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SKRS EŞLEME MASASI (1222, mockup Ekranlar/Aktarim/skrs_esleme_masasi.html). Eski HBYS'den aktarılan hizmetler
/// Bakanlık (SUT) listesine bağlanır: masa doldurulur (adaylar fn_skrs_hizmet_adaylari), her satıra karar verilir
/// (onayla / kuruma özel / aday yok), toplu onay yalnız YÜKSEK güvenli ve "dikkat"siz önerilere, Uygula önce önizler.
/// Kullanıcı kararı (01.11.2026): eşlemeyi hizmet kartını DEĞİŞTİREBİLEN onaylar - bütün yazma uçları hizmet Değiştir.
/// </summary>
public static class AktarimEslemeUclari
{
    public sealed record KararIstegi(short Durum, string? Kod, string? Not);

    /// <summary>Masa listeleri (1222 hizmet, 1224 bölüm / branş).</summary>
    private static string Liste(string? liste) => liste switch
    {
        null or "" or "hizmet" => "hizmet",
        "bolum" => "bolum",
        "brans" => "brans",
        _ => throw GentegreHatasi.Dogrulama("Bilinmeyen eşleme listesi."),
    };
    public sealed record TopluOnayIstegi(decimal? Esik, List<int>? Idler);

    public static void AktarimEslemeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/aktarim/esleme").WithTags("Aktarım eşleme").RequireAuthorization();

        // Masayı doldur / adayları tazele (karar verilmiş satıra dokunmaz).
        grup.MapPost("/doldur", async (string? liste, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Degistir);
            baglam.YazmaIste();
            var l = Liste(liste);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.TekDegerAsync<int?>(l == "hizmet" ? "select public.fn_aktarim_esleme_doldur()"
                                                           : "select public.fn_aktarim_esleme_doldur_metin(@p0)", null, [l], iptal) ?? 0;
            return Results.Ok(new { satir = n, izlemeNo = baglam.IzlemeNo });
        });

        // Satırın adayları + seçili karar (sağ panel).
        grup.MapGet("/{id:int}", async (int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satir = await b.TekAsync("""
                select e.id, e.kayit_id as "kayitId", e.eski_kod as "eskiKod", e.eski_ad as "eskiAd", e.tur, e.modalite,
                       e.kullanim, e.adaylar::text as adaylar, coalesce(e.aile::text, '') as aile, e.durum, e.uygulandi, coalesce(e.secilen_kod, '') as "secilenKod",
                       coalesce(ss.ad, dp.ad, bk.ad, '') as "secilenAd", e.notlar, e.liste,
                       (select count(*) from public.fiyat_listesi_satir f where f.hizmet_id = e.kayit_id)::int as "fiyatSatiri",
                       coalesce((select string_agg(x.eski_kod || ' · ' || x.eski_ad, ' | ') from public.aktarim_esleme x
                                  where x.liste = 'hizmet' and x.id <> e.id and x.secilen_kod is not null
                                    and x.secilen_kod = coalesce(e.secilen_kod, e.adaylar->0->>'kod')), '') as "ayniKodlu"
                  from public.aktarim_esleme e
                  left join public.skrs_sut ss on e.liste = 'hizmet' and ss.kod = e.secilen_kod
                  left join public.departman dp on e.liste = 'bolum' and e.secilen_kod ~ '^[0-9]+$' and dp.id = e.secilen_kod::int
                  left join lateral (select d.ad from public.kod_deger d join public.kod_liste kl on kl.id = d.liste_id
                                      where e.liste = 'brans' and kl.kod = 'hekim.brans' and d.dil = 0
                                        and d.deger::text = e.secilen_kod limit 1) bk on true
                 where e.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Eşleme satırı bulunamadı.");
            return Results.Ok(new { satir, izlemeNo = baglam.IzlemeNo });
        });

        // Karar: 0 bekliyor · 1 onayla (kod zorunlu, SUT'ta olmalı) · 2 kuruma özel · 3 aday yok
        //   · 4 yön ailesi (1232; kod ailenin bir üyesi - en az iki yönlü SUT ailesi olmalı).
        grup.MapPost("/{id:int}/karar", async (int id, KararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Degistir);
            baglam.YazmaIste();
            if (istek.Durum is < 0 or > 4) throw GentegreHatasi.Dogrulama("Geçersiz karar.");
            var kod = (istek.Kod ?? "").Trim();
            await using var b = await veri.AcAsync(iptal);
            if (istek.Durum == 1)
            {
                if (kod == "") throw GentegreHatasi.Dogrulama("Onay için hedef seçin.");
                var l = await b.TekDegerAsync<string?>("select liste from public.aktarim_esleme where id = @p0", null, [id], iptal)
                        ?? throw GentegreHatasi.Bulunamadi("Eşleme satırı bulunamadı.");
                var sorgu = l switch
                {
                    "bolum" => "select 1 from public.departman where id::text = @p0",
                    "brans" => "select 1 from public.kod_deger d join public.kod_liste kl on kl.id = d.liste_id where kl.kod = 'hekim.brans' and d.deger::text = @p0",
                    _ => "select 1 from public.skrs_sut where kod = @p0",
                };
                var var_ = await b.TekDegerAsync<int?>(sorgu, null, [kod], iptal);
                if (var_ is null) throw GentegreHatasi.Dogrulama($"Bakanlık listesinde yok: {kod}");
            }
            if (istek.Durum == 4)
            {
                if (kod == "") throw GentegreHatasi.Dogrulama("Yön ailesi için ailenin bir SUT kodunu seçin.");
                var yonSayisi = await b.TekDegerAsync<int?>(
                    "select count(distinct yon)::int from public.fn_skrs_yon_ailesi(@p0)", null, [kod], iptal) ?? 0;
                if (yonSayisi < 2)
                    throw GentegreHatasi.Dogrulama($"{kod} yönlü bir SUT ailesine ait değil (Sağ / Sol kodu yok).");
            }
            var n = await b.CalistirAsync("""
                update public.aktarim_esleme
                   set durum = @p1, secilen_kod = case when @p1 in (1, 4) then @p2 else null end,
                       notlar = left(coalesce(@p3, notlar), 300),
                       onaylayan = case when @p1 in (1, 2, 4) then @p4 end, onay_tarihi = case when @p1 in (1, 2, 4) then now() end
                 where id = @p0 and uygulandi = 0
                """, null, [id, istek.Durum, kod, istek.Not, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.Dogrulama("Satır bulunamadı ya da zaten uygulandı.");
            return Results.Ok(new { izlemeNo = baglam.IzlemeNo });
        });

        // Toplu onay: yalnız bekleyen, "dikkat"siz ve ilk adayı eşik üstü olanlar (idler verilirse onlarla sınırlı).
        //   Yön ailesi önerisi olan satır (1232) tek yönlü koda DEĞİL aileye onaylanır - "taraf seçimi" uyarısı engel değil.
        grup.MapPost("/toplu-onay", async (string? liste, TopluOnayIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Degistir);
            baglam.YazmaIste();
            var esik = Math.Clamp(istek.Esik ?? 0.8m, 0.5m, 1m);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.aktarim_esleme
                   set durum = case when aile is not null then 4 else 1 end,
                       secilen_kod = coalesce(aile->>'seed', adaylar->0->>'kod'), onaylayan = @p1, onay_tarihi = now()
                 where liste = @p3 and uygulandi = 0 and durum = 0
                   and (adaylar->0->>'dikkat' is null or aile is not null) and coalesce((adaylar->0->>'puan')::numeric, 0) >= @p0
                   and (@p2::int[] is null or id = any (@p2::int[]))
                """, null, [esik, baglam.KullaniciId, istek.Idler is { Count: > 0 } l ? l.ToArray() : null, Liste(liste)], iptal);
            return Results.Ok(new { onaylanan = n, izlemeNo = baglam.IzlemeNo });
        });

        // Bakanlıkta ara: kod başı ya da sadeleştirilmiş ad benzerliği (tür süzgeçli).
        grup.MapGet("/sut-ara", async (string? q, string? tur, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Gor);
            var ara = (q ?? "").Trim();
            if (ara.Length < 2) return Results.Ok(new { satirlar = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select s.kod, s.ad, s.tip,
                       greatest(case when s.kod ilike @p0 || '%' then 1 else 0 end,
                                similarity(public.fn_skrs_sade(s.ad), public.fn_skrs_sade(@p0)))::numeric(4,2) as puan
                  from public.skrs_sut s
                 where coalesce(s.aktif, 1) = 1
                   and (s.kod ilike @p0 || '%' or public.fn_skrs_sade(s.ad) % public.fn_skrs_sade(@p0)
                        or public.fn_skrs_sade(s.ad) like '%' || public.fn_skrs_sade(@p0) || '%')
                   and case upper(coalesce(@p1, ''))
                         when 'RAD' then s.tip = 'Tetkik ve Radyoloji Bilgileri'
                         when 'LAB' then s.tip = 'Tahlil İşlemleri'
                         else coalesce(s.tip, '') <> 'Malzemeler' end
                 order by puan desc, s.kod limit 25
                """, null, [ara, tur], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // Bölüm / branş hedef arama (1224).
        grup.MapGet("/hedef-ara", async (string? liste, string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Gor);
            var l = Liste(liste);
            var ara = (q ?? "").Trim();
            if (ara.Length < 2 || l == "hizmet") return Results.Ok(new { satirlar = Array.Empty<object>() });
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync(l == "bolum" ? """
                select d.id::text as kod, d.ad || coalesce(' · ' || nullif(d.kod, ''), '') as ad,
                       similarity(public.fn_skrs_sade(d.ad), public.fn_skrs_sade(@p0))::numeric(4,2) as puan
                  from public.departman d
                 where coalesce(d.durum, 1) = 1 and (public.fn_skrs_sade(d.ad) like '%' || public.fn_skrs_sade(@p0) || '%'
                       or public.fn_skrs_sade(d.ad) % public.fn_skrs_sade(@p0))
                 order by puan desc, d.ad limit 25
                """ : """
                select d.deger::text as kod, d.ad, similarity(public.fn_skrs_sade(d.ad), public.fn_skrs_sade(@p0))::numeric(4,2) as puan
                  from public.kod_deger d join public.kod_liste kl on kl.id = d.liste_id
                 where kl.kod = 'hekim.brans' and d.dil = 0
                   and (public.fn_skrs_sade(d.ad) like '%' || public.fn_skrs_sade(@p0) || '%'
                        or public.fn_skrs_sade(d.ad) % public.fn_skrs_sade(@p0) or d.deger::text = @p0)
                 order by puan desc, d.ad limit 25
                """, null, [ara], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // Önizleme: uygulanınca ne olur (sayılar).
        grup.MapGet("/onizleme", async (string? liste, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                with u as (select * from public.aktarim_esleme where liste = @p0 and uygulandi = 0)
                select count(*) filter (where durum = 1)::int as onayli,
                       count(*) filter (where durum = 4)::int as aile,
                       count(*) filter (where durum = 2)::int as ozel,
                       count(*) filter (where durum = 0)::int as bekleyen,
                       count(*) filter (where durum = 3)::int as "adayYok",
                       (count(*) filter (where durum = 1) - count(distinct secilen_kod) filter (where durum = 1))::int
                         + (select count(*) from u where durum = 1 and exists (select 1 from public.hizmet h
                              where h.standart = 1 and h.sut_kodu = u.secilen_kod and coalesce(h.durum, 1) = 1))::int as birlesen,
                       coalesce(sum(kullanim) filter (where durum = 1), 0)::int as "belgeSatiri",
                       (select count(*) from public.aktarim_esleme where liste = @p0 and uygulandi = 1)::int as uygulanmis
                  from u
                """, null, [Liste(liste)], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { onizleme = o, izlemeNo = baglam.IzlemeNo });
        });

        // Uygula: onaylılar SUT'a (yerinde), kuruma özeller işaretlenir; aynı SUT'a düşen birleşir (silme yok).
        grup.MapPost("/uygula", async (string? liste, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("hizmet", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var l = Liste(liste);
            var sonuc = await b.TekDegerAsync<string?>(l == "hizmet" ? "select public.fn_aktarim_esleme_uygula(@p0)::text"
                                                                     : "select public.fn_aktarim_esleme_uygula_metin(@p1, @p0)::text", islem,
                [baglam.KullaniciId, l], iptal) ?? "{}";
            await log.YazAsync(b, islem, LogIslemi.Degistir, 921, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { skrsEsleme = sonuc, liste = l }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { sonuc, izlemeNo = baglam.IzlemeNo });
        });
    }
}
