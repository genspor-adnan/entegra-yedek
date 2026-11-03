using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>Ctrl+K hızlı bul: ad ile kayıt (5 tür) ve düz VKN / TCKN. Ortak tipler ve kurallar GundemUclari.cs'de.</summary>
public static partial class GundemUclari
{
    private static void HizliBulUclari(IEndpointRouteBuilder yol)
    {
        // GET /api/hizli-bul/kayit-ad?q= - Ctrl+K AD İLE KAYIT (katman 1). Cari aramasının (cari-ad) genişletilmiş hali:
        //   müşteri, tedarikçi, kişi, personel, hasta - her tür KENDİ yetkisiyle (cari · cari.tedarikci · cari.kisi ·
        //   personel · hasta). Her kelime ünvan / ad / soyad / kod içinde (fn_ara_metin, liste aramasıyla aynı). Yalnız aktif
        //   kayıt; başı eşleşen önce. Telefon / kimlik no DÖNMEZ (palet satırında gerekmiyor).
        yol.MapGet("/api/hizli-bul/kayit-ad", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kelimeler = (q ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(k => k.Length >= 2).Take(4).ToList();
            if (kelimeler.Count == 0 || kelimeler.Sum(k => k.Length) < 3)
                return Results.Ok(new { kayitlar = Array.Empty<object>() });

            // Tür -> taraf rol kolonu + yetki. Yetkisi olmayan tür sorguya hiç girmez.
            var turler = new List<(string Tur, string Kolon)>();
            if (baglam.Yetkiler.Var("cari", Islem.Gor)) turler.Add(("musteri", "musteri"));
            if (baglam.Yetkiler.Var("cari.tedarikci", Islem.Gor) || baglam.Yetkiler.Var("cari", Islem.Gor)) turler.Add(("tedarikci", "tedarikci"));
            if (baglam.Yetkiler.Var("cari.kisi", Islem.Gor)) turler.Add(("kisi", "kisi"));
            if (baglam.Yetkiler.Var("personel", Islem.Gor)) turler.Add(("personel", "personel"));
            if (baglam.Yetkiler.Var("hasta", Islem.Gor)) turler.Add(("hasta", "hasta"));
            if (turler.Count == 0) return Results.Ok(new { kayitlar = Array.Empty<object>() });

            var kosul = string.Join(" and ", kelimeler.Select((_, i) =>
                $"public.fn_ara_metin(coalesce(t.unvan, '') || ' ' || coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '') || ' ' || coalesce(t.kod, '')) like '%' || public.fn_ara_metin(@p{i + 1}) || '%'"));
            // Tür birleşimi: her tür kendi alt sorgusu, kendi sınırıyla (müşteri çoksa personel düşmesin).
            //   Aynı kişi iki rolde olabilir (müşteri + tedarikçi) - her rol ayrı satır, ilk geçen kalır.
            var parcalar = turler.Select(t => $$"""
                (select '{{t.Tur}}' as tur, t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '') as ad,
                        coalesce(t.kod, '') as kod, t.musteri = 1 as musteri, t.tedarikci = 1 as tedarikci,
                        case '{{t.Tur}}'
                          when 'personel' then coalesce(t.gorev, '')
                          when 'kisi' then coalesce((select public.fn_taraf_ad(b.unvan, b.ad, b.soyad)::varchar(160)
                                                       from public.taraf b where b.id = t.bag_id), '')
                          when 'hasta' then coalesce(extract(year from age(t.d_tarih))::int || ' yaş', '')
                          else coalesce((select a.il from public.taraf_adres a where a.taraf_id = t.id
                                          order by a.varsayilan desc, a.id limit 1), '') end as bilgi,
                        (public.fn_ara_metin(coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''))
                           like public.fn_ara_metin(@p1) || '%') as basi
                   from public.taraf t
                  where t.{{t.Kolon}} = 1 and coalesce(t.durum, 1) = 1
                    and (cardinality(@p0::int[]) = 0 or t.id = any(@p0::int[]))
                    and {{kosul}}
                  order by 8 desc, t.id desc
                  limit {{TurBasinaSatir}})
                """);
            var sql = string.Join("\nunion all\n", parcalar);
            var kapsam = baglam.Kapsam.Count > 0 ? baglam.Kapsam.ToArray() : [];
            var l = await veri.ListeAsync(sql, [kapsam, .. kelimeler.Cast<object?>()],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), kod = o.GetString(3),
                           musteri = o.GetBoolean(4), tedarikci = o.GetBoolean(5), bilgi = o.GetString(6) }, iptal);
            return Results.Ok(new { kayitlar = l });
        }).RequireAuthorization().WithTags("Hızlı bul");

        // GET /api/hizli-bul/vergi-no?q= - Ctrl+K DÜZ VKN / TCKN (kullanıcı 03.11.2026: "prompt'a vkno girdim hiç bir bilgi
        //   gelmedi .. 10 ise müş/ted/anlaşmalı kurum .. 11 hane hasta/personel olabilir .. 11 haneli müşteri de olabilir
        //   bireysel .. tc no ya fatura kesmiş olabilir"). Numaraya kayıtlı müşteri / tedarikçi / kurum kartı (her rol ayrı
        //   satır, kendi yetkisiyle; PASİF dahil - kart yeniden etkinleştirilir) + o numaraya kesilmiş SON satış belgeleri
        //   (kartı olmayan nihai tüketici / bireysel). Hasta / personel 11 hanesi paletin kimlik niyetinde (ayrı uç).
        yol.MapGet("/api/hizli-bul/vergi-no", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var no = new string((q ?? "").Where(char.IsDigit).ToArray());
            if (no.Length is not (10 or 11) || no.Distinct().Count() == 1)
                return Results.Ok(new { kayitlar = Array.Empty<object>(), belgeler = Array.Empty<object>() });
            var roller = new List<string>();
            if (baglam.Yetkiler.Var("cari", Islem.Gor)) roller.Add("musteri");
            if (baglam.Yetkiler.Var("cari.tedarikci", Islem.Gor) || baglam.Yetkiler.Var("cari", Islem.Gor)) roller.Add("tedarikci");
            if (baglam.Yetkiler.Var("kurum", Islem.Gor) || baglam.Yetkiler.Var("kurum.liste", Islem.Gor)) roller.Add("kurum");
            var kapsam = baglam.Kapsam.Count > 0 ? baglam.Kapsam.ToArray() : [];
            await using var b = await veri.AcAsync(iptal);
            List<object> kayitlar = roller.Count == 0 ? [] : [.. await b.ListeAsync("""
                select r.tur, t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), coalesce(t.kod, ''),
                       coalesce(t.durum, 1)::int, t.musteri = 1, t.tedarikci = 1
                  from public.taraf t
                  cross join lateral (values ('musteri', t.musteri), ('tedarikci', t.tedarikci), ('kurum', t.kurum)) r(tur, var)
                 where regexp_replace(coalesce(t.vkno, ''), '[^0-9]', '', 'g') = @p0
                   and r.var = 1 and r.tur = any(@p1::text[])
                   and (cardinality(@p2::int[]) = 0 or t.id = any(@p2::int[]))
                 order by (coalesce(t.durum, 1) = 1) desc, t.id
                 limit 6
                """, null, [no, roller.ToArray(), kapsam],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), kod = o.GetString(3), durum = o.GetInt32(4),
                           musteri = o.GetBoolean(5), tedarikci = o.GetBoolean(6) }, iptal)];
            List<object> belgeler = !baglam.Yetkiler.Var("belge.satis.fatura", Islem.Gor) && !baglam.Yetkiler.Var("belge.satis", Islem.Gor) ? [] :
                [.. await b.ListeAsync("""
                    select b.id, b.tur::int, coalesce(b.belge_no, ''), b.belge_tarihi, coalesce(b.taraf_unvan, ''), coalesce(b.genel_toplam, 0)
                      from public.belge b
                     where regexp_replace(coalesce(b.taraf_vkno, ''), '[^0-9]', '', 'g') = @p0
                       and b.tur in (14, 15, 16, 19) and b.durum <> 2 and coalesce(b.tipi, 0) <> 30
                       and (cardinality(@p1::int[]) = 0 or b.taraf_id = any(@p1::int[]))
                     order by b.belge_tarihi desc, b.id desc
                     limit 3
                    """, null, [no, kapsam],
                    o => new { id = o.GetInt32(0), tur = o.GetInt32(1), no = o.GetString(2), tarih = o.GetDateTime(3),
                               unvan = o.GetString(4), tutar = o.GetDecimal(5) }, iptal)];
            return Results.Ok(new { kayitlar, belgeler });
        }).RequireAuthorization().WithTags("Hızlı bul");
    }
}
