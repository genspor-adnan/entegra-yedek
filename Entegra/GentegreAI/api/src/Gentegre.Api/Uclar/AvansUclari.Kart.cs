using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PERSONEL AVANSI KARTI (960, mockup Ekranlar/IK/avans_karti.html).
///
/// Kartın yan bilgileri tek uçta: personel ve net maaşı, azami taksit, maaşa
/// oran eşiği, diğer açık avanslar (aylık yük + zincire basamak ekler), son
/// 12 ay geçmişi, kesinti planı (ödenmişse gerçek satırlar), ödeme hesapları,
/// akış. Kaydı DEĞİŞTİRMEZ; kart verisi generic kart uçlarından.
/// </summary>
public static partial class AvansUclari
{
    private static void AvansKartUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/avans-baglam", async (int tarafId, int? avansId, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIsteKendi(tarafId, "ik.avans", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var personel = await b.TekAsync("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                       coalesce(p.gorev, '') as gorev, p.net_maas as "netMaas",
                       (select string_agg(d.ad, ', ') from public.departman d
                         where d.id in (select public.fn_kullanici_bolumleri(@p0))) as bolum
                  from public.taraf t left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var azamiTaksit = (int)await AyarSayiAsync(b, "ik.avans_azami_taksit", 6, iptal);
            var oranEsik = await AyarSayiAsync(b, "ik.avans_maas_orani", 25, iptal);

            // DİĞER AÇIK AVANSLAR (onayda, onaylı, ödenmiş-kesintide): aylık yükü
            //   bekleyen ilk taksit, yoksa tutar / taksit.
            var aciklar = await b.ListeAsync("""
                select a.id, coalesce(nullif(a.avans_no, ''), '#' || a.id) as no, a.talep_tarihi as tarih,
                       a.tutar, a.taksit_sayisi as taksit, a.durum,
                       coalesce((select sum(k.tutar) from public.personel_avans_kesinti k
                                  where k.avans_id = a.id and k.durum = 0), a.tutar) as kalan,
                       coalesce((select count(*) from public.personel_avans_kesinti k
                                  where k.avans_id = a.id and k.durum = 0), a.taksit_sayisi) as "kalanTaksit",
                       coalesce((select k.tutar from public.personel_avans_kesinti k
                                  where k.avans_id = a.id and k.durum = 0 order by k.sira limit 1),
                                round(a.tutar / greatest(a.taksit_sayisi, 1), 2)) as aylik
                  from public.personel_avans a
                 where a.taraf_id = @p0 and a.id <> coalesce(@p1, 0) and a.durum in (1, 2, 4)
                 order by a.talep_tarihi desc
                """, null, [tarafId, avansId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gecmis = await b.ListeAsync("""
                select coalesce(nullif(a.avans_no, ''), '#' || a.id) as no, a.talep_tarihi as tarih,
                       a.tutar, a.durum, a.taksit_sayisi as taksit,
                       (select count(*) from public.personel_avans_kesinti k where k.avans_id = a.id and k.durum = 1) as kesilen
                  from public.personel_avans a
                 where a.taraf_id = @p0 and a.id <> coalesce(@p1, 0)
                   and a.talep_tarihi > current_date - interval '12 months'
                 order by a.talep_tarihi desc limit 10
                """, null, [tarafId, avansId], OkuyucuGenisletmeleri.Sozluk, iptal);

            List<IDictionary<string, object?>> kesintiler = [];
            List<IDictionary<string, object?>> akis = [];
            if (avansId is > 0)
            {
                kesintiler = await b.ListeAsync("""
                    select k.id, k.sira, k.donem, k.tutar, k.durum, k.kesinti_tarihi as "kesintiTarihi", k.aciklama
                      from public.personel_avans_kesinti k where k.avans_id = @p0 order by k.sira
                    """, null, [avansId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);
                akis = await b.ListeAsync("""
                    select 0 as sira, 'olustu' as tur, a.ekleme_tarihi as zaman,
                           coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as kim, '' as metin
                      from public.personel_avans a left join public.taraf t on t.id = a.ekleyen
                     where a.id = @p0
                    union all
                    select 1, 'gonderildi', o.baslama, '', (select string_agg(x.ad, ' → ' order by x.sira) from public.onay_adim x where x.onay_id = o.id)
                      from public.onay o where o.kaynak_tur = @p1 and o.kaynak_id = @p0
                    union all
                    select 2 + d.sira, case d.durum when 1 then 'onay' when 2 then 'red' when 3 then 'bilgi'
                                                    when 4 then 'sozlu' when 5 then 'atlandi' end,
                           d.karar_zamani, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                           d.ad || coalesce(' · “' || nullif(d.gerekce, '') || '”', '')
                      from public.onay o join public.onay_adim d on d.onay_id = o.id
                      left join public.taraf t on t.id = d.karar_veren_id
                     where o.kaynak_tur = @p1 and o.kaynak_id = @p0 and d.karar_zamani is not null
                    union all
                    select 80, 'odendi', a.odeme_tarihi::timestamptz, '', 'kasa işlemi #' || a.odeme_islem_id
                      from public.personel_avans a where a.id = @p0 and a.odeme_islem_id is not null
                    union all
                    select 81 + k.sira, 'kesinti', k.kesinti_tarihi::timestamptz, '', k.donem || ' · ' || k.tutar::numeric(18,2)
                      from public.personel_avans_kesinti k where k.avans_id = @p0 and k.durum = 1
                    union all
                    select 99, 'iptal', a.degistirme_tarihi, '', a.iptal_neden
                      from public.personel_avans a where a.id = @p0 and a.durum = 8
                     order by 3 nulls last, 1
                    """, null, [avansId.Value, LogAvans], OkuyucuGenisletmeleri.Sozluk, iptal);
            }

            // ÖDEME HESAPLARI: aktif TL hesaplar (kasa / banka).
            var hesaplar = await b.ListeAsync("""
                select h.id, h.ad from public.hesap h
                 where h.durum = 1 and coalesce(h.doviz_cinsi, 'TL') in ('TL', 'TRY')
                 order by h.ad limit 50
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { personel, azamiTaksit, oranEsik, aciklar, gecmis, kesintiler, akis, hesaplar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/avans/{id:int}/hatirlat", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.OnayBildirimi haber, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await KendiTalebi.IsteAsync(veri, baglam, "select taraf_id from public.personel_avans where id = @p0",
                id, "ik.avans", Islem.Degistir, iptal);
            await using var b = await veri.AcAsync(iptal);
            var onayId = await b.TekDegerAsync<long?>("""
                select o.id from public.onay o where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and o.durum = 0
                 order by o.id desc limit 1
                """, null, [LogAvans, id], iptal)
                ?? throw GentegreHatasi.IsKurali("Bu avans onayda değil.");
            var n = await haber.SiradakiniBildirAsync(b, onayId, baglam.KullaniciId, baglam.SubeId, iptal);
            return Results.Ok(new { bildirim = n, izlemeNo = baglam.IzlemeNo });
        });
    }
}
