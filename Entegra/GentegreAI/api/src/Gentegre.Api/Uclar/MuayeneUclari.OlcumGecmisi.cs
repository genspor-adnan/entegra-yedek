using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÖLÇÜM GEÇMİŞİ GRAFİĞİ (mockup muayene_karti_v7) — bkz. <c>MuayeneUclari</c>.
///
/// <para>Hekim bir vitali ya da tahlili seçer, hastanın BÜTÜN geçmiş ölçümleri
/// tarih sırasıyla gelir. Vital adı sunucudaki sabit listeden kolona çevrilir;
/// istekten SQL'e metin girmez. Tahlilde yalnız <b>onaylı</b> sonuç gelir -
/// laboratuvarın doğrulamadığı değer eğriye girerse hekim ona göre karar verir.</para>
/// </summary>
public static partial class MuayeneUclari
{
    /// <summary>Vital → kolon(lar), birim, referans aralığı (TA çift seri).</summary>
    private static readonly Dictionary<string, (string Ad, string Kolon, string? Kolon2, string Birim,
        decimal Alt, decimal Ust, decimal? Alt2, decimal? Ust2)> VitalSerileri = new(StringComparer.Ordinal)
    {
        ["ta"]      = ("Tansiyon", "sistolik", "diyastolik", "mmHg", 90, 140, 60, 90),
        ["nabiz"]   = ("Nabız", "nabiz", null, "/dk", 60, 100, null, null),
        ["spo2"]    = ("SpO₂", "spo2", null, "%", 95, 100, null, null),
        ["ates"]    = ("Ateş", "ates", null, "°C", 36, 37.5m, null, null),
        ["solunum"] = ("Solunum", "solunum", null, "/dk", 12, 20, null, null),
        ["agri"]    = ("Ağrı (VAS)", "agri_vas", null, "/10", 0, 3, null, null),
        ["kilo"]    = ("Kilo", "kilo_kg", null, "kg", 0, 0, null, null),
        ["bki"]     = ("BKİ", "bki", null, "kg/m²", 18.5m, 25, null, null),
        ["glukoz"]  = ("Parmak glukoz", "glukoz_parmak", null, "mg/dL", 70, 140, null, null),
    };

    private static void OlcumGecmisiUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/band - hasta bandının liste satırında olmayan üç bilgisi
        //   (sekmesiz düzen, mockup hasta_bandi): kan grubu, kurum, AYNI AD sayısı
        //   (aynı ad soyadlı başka hasta - yanlış hasta hatasının en sık sebebi).
        grup.MapGet("/{id:int}/band", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satir = (await b.ListeAsync("""
                select (select d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                         where l.kod = 'taraf.kan_grubu' and d.dil = 0 and d.deger = th.kan_grubu) as "kanGrubu",
                       -- KURUM = BU BAŞVURUNUN ödeyen kurumu (kullanıcı 14.10.2026); başvuruda yoksa
                       --   hastanın kayıtlı kurumu. Sözleşme varsa yanında.
                       coalesce(public.fn_taraf_ad(bk.unvan, bk.ad, bk.soyad)::varchar(120),
                                public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '') as kurum,
                       coalesce(sz.ad, '') as sozlesme,
                       (select count(*) from public.taraf o
                         where o.hasta = 1 and o.id <> t.id and coalesce(t.ad, '') <> ''
                           and lower(o.ad) = lower(t.ad) and lower(coalesce(o.soyad, '')) = lower(coalesce(t.soyad, '')))::int as "ayniAd"
                  from public.muayene m
                  join public.taraf t on t.id = m.taraf_id
                  left join public.taraf_hasta th on th.id = t.id
                  left join public.taraf k on k.id = th.kurum_id
                  left join public.belge_basvuru bb on bb.id = m.belge_id
                  left join public.taraf bk on bk.id = bb.odeyen_kurum_id
                  left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
                 where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault();
            return Results.Ok(satir ?? new Dictionary<string, object?>());
        });

        // GET /api/muayene/{id}/son-sonuclar - hastanın her tetkikinin SON onaylı sonucu
        //   (sekmesiz düzenin sağ sütunu, mockup v7). Panik ve bayraklılar önce.
        grup.MapGet("/{id:int}/son-sonuclar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select * from (
                  select distinct on (t.kod) t.kod, t.ad, ls.deger_metin as deger, ls.birim, ls.bayrak,
                         ls.panik, coalesce(ls.olcum_zamani, ls.onay_zamani) as zaman
                    from public.muayene m
                    join public.lab_istem i on i.taraf_id = m.taraf_id and i.durum <> 9
                    join public.lab_istem_satir s on s.istem_id = i.id
                    join public.lab_tetkik t on t.id = s.tetkik_id
                    join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                   where m.id = @p0
                   order by t.kod, coalesce(ls.olcum_zamani, ls.onay_zamani) desc) x
                 order by (x.panik = 1) desc, (coalesce(x.bayrak, '') not in ('', 'N')) desc, x.zaman desc
                 limit 8
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(satirlar);
        });

        // GET /api/muayene/{id}/olcum-gecmisi?vital=ta  |  ?tetkik=<lab_tetkik.kod>
        grup.MapGet("/{id:int}/olcum-gecmisi", async (
            int id, string? vital, string? tetkik, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var hastaId = await b.TekDegerAsync<int?>("select taraf_id from public.muayene where id = @p0",
                              null, [id], iptal) ?? throw GentegreHatasi.Bulunamadi();

            if (!string.IsNullOrEmpty(vital))
            {
                if (!VitalSerileri.TryGetValue(vital, out var v))
                    throw GentegreHatasi.Dogrulama("Bilinmeyen vital.", [new("vital", "Bilinmeyen vital.")]);
                // Kolon adı SABİT LİSTEDEN; değer parametre.
                var noktalar = await b.ListeAsync($"""
                    select x.zaman, x.{v.Kolon}::numeric as deger,
                           {(v.Kolon2 is null ? "null::numeric" : $"x.{v.Kolon2}::numeric")} as deger2,
                           (m.id = @p1) as bu, d.ad as yer
                      from public.muayene_vital x
                      join public.muayene m on m.id = x.muayene_id
                      left join public.departman d on d.id = m.bolum_id
                     where m.taraf_id = @p0 and x.{v.Kolon} is not null
                     order by x.zaman
                    """, null, [hastaId, id], OkuyucuGenisletmeleri.Sozluk, iptal);
                return Results.Ok(new
                {
                    ad = v.Ad, birim = v.Birim,
                    referans = v.Ust > 0 ? new[] { v.Alt, v.Ust } : null,
                    referans2 = v.Alt2 is null ? null : new[] { v.Alt2.Value, v.Ust2!.Value },
                    noktalar,
                });
            }

            if (!string.IsNullOrEmpty(tetkik))
            {
                var satirlar = await b.ListeAsync("""
                    select coalesce(ls.olcum_zamani, ls.onay_zamani) as zaman, ls.deger_metin as metin,
                           ls.birim, ls.referans_alt as "referansAlt", ls.referans_ust as "referansUst",
                           t.ad, (i.belge_id = (select belge_id from public.muayene where id = @p2)) as bu
                      from public.lab_istem i
                      join public.lab_istem_satir s on s.istem_id = i.id
                      join public.lab_tetkik t on t.id = s.tetkik_id
                      join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                     where i.taraf_id = @p0 and i.durum <> 9 and t.kod = @p1
                     order by coalesce(ls.olcum_zamani, ls.onay_zamani)
                    """, null, [hastaId, tetkik, id], OkuyucuGenisletmeleri.Sozluk, iptal);
                // SAYISAL OLMAYAN SONUÇ (pozitif, "<5"...) eğriye girmez, tabloda kalır.
                var noktalar = satirlar.Select(r => new Dictionary<string, object?>
                {
                    ["zaman"] = r["zaman"], ["metin"] = r["metin"], ["bu"] = r["bu"],
                    ["deger"] = decimal.TryParse(Convert.ToString(r["metin"])?.Replace(',', '.'),
                                    NumberStyles.Number, CultureInfo.InvariantCulture, out var d) ? d : null,
                }).ToList();
                var son = satirlar.LastOrDefault();
                return Results.Ok(new
                {
                    ad = son?["ad"] ?? tetkik, birim = son?["birim"] ?? "",
                    referans = son?["referansAlt"] is not null && son?["referansUst"] is not null
                        ? new[] { son["referansAlt"], son["referansUst"] } : null,
                    referans2 = (object?)null,
                    noktalar,
                });
            }

            throw GentegreHatasi.Dogrulama("vital ya da tetkik verin.", [new("vital", "Seri seçilmedi.")]);
        });
    }
}
