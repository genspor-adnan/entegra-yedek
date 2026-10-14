using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KALİTE PANOSU (Kurumsal Kalite 1055, mockup Ekranlar/Kalite2/kalite_panosu.html,
/// kullanıcı 12.10.2026: "Kalite 2 ile devam et"). Sade: yedi sayı + bana düşenler.
///
/// <para><b>Sayılar</b> (aktif şube, şubesiz kayıt dahil):
/// açık DÖF (durum &lt; 5) ve vadesi geçeni; değerlendirilecek olay (yeni +
/// değerlendirmede); bu ay planlanan denetim ve yapılanı; yüksek risk (seviye
/// yüksek / çok yüksek, açık ya da önlemde); hedef dışı gösterge / aktif gösterge;
/// kalibrasyonu 30 gün içinde dolan / geçen ölçüm cihazı (demirbaş: periyodu ya da
/// geçerlilik tarihi olan aktif kayıt - 723/728 "tâbi" ölçütü); eksik zorunlu
/// eğitim (eğitim dilimi <c>v_kalite_egitim_eksik</c> görünümünü kurduysa).</para>
///
/// <para><b>Bana düşenler</b>: oturumdaki kullanıcının (taraf) sorumlusu olduğu açık
/// DÖF, sürmekte olan DÖF faaliyeti, planlı iç denetim (baş denetçi), açık karar ve
/// kalite sorumlusu / yedeği olduğu birimin değerlendirilecek olayları. Termin
/// sıralı, en çok 50. Olay açıklaması kısaltılır, bildiren hiç gösterilmez (anonim).</para>
/// </summary>
public static class KysPanoUclari
{
    private const string Kod = "kys.pano";

    public static void KysPanoUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kys-pano").WithTags("Kalite Panosu").RequireAuthorization();

        grup.MapGet("/", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var sube = baglam.SubeId ?? 0;
            var ben = baglam.KullaniciId;
            await using var b = await veri.AcAsync(iptal);

            var s = (await b.ListeAsync("""
                select
                  (select count(*) from public.kalite_dof d
                    where d.durum < 5 and (@p0 = 0 or d.sube_id in (0, @p0)))::int,
                  (select count(*) from public.kalite_dof d
                    where d.durum < 5 and d.termin < current_date and (@p0 = 0 or d.sube_id in (0, @p0)))::int,
                  (select count(*) from public.kalite_olay o
                    where o.durum in (1, 2) and (@p0 = 0 or o.sube_id in (0, @p0)))::int,
                  (select count(*) from public.kalite_denetim d
                    where date_trunc('month', d.plan_tarih) = date_trunc('month', current_date)
                      and (@p0 = 0 or d.sube_id in (0, @p0)))::int,
                  (select count(*) from public.kalite_denetim d
                    where date_trunc('month', d.plan_tarih) = date_trunc('month', current_date) and d.durum = 2
                      and (@p0 = 0 or d.sube_id in (0, @p0)))::int,
                  (select count(*) from public.kalite_risk r
                    where r.durum in (1, 2) and public.fn_kys_risk_seviye(r.skor) >= 3
                      and (@p0 = 0 or r.sube_id in (0, @p0)))::int,
                  (select count(*) from public.v_kalite_gosterge g
                    where g.aktif = 1 and g.durum_adi = 'Hedef dışı' and (@p0 = 0 or g.sube_id in (0, @p0)))::int,
                  (select count(*) from public.v_kalite_gosterge g
                    where g.aktif = 1 and (@p0 = 0 or g.sube_id in (0, @p0)))::int,
                  (select count(*) from public.demirbas d
                    where d.durum = 1 and (d.kalibrasyon_periyot_ay > 0 or d.kalibrasyon_gecerlilik is not null)
                      and d.kalibrasyon_gecerlilik between current_date and current_date + 30
                      and (@p0 = 0 or d.sube_id in (0, @p0)))::int,
                  (select count(*) from public.demirbas d
                    where d.durum = 1 and (d.kalibrasyon_periyot_ay > 0 or d.kalibrasyon_gecerlilik is not null)
                      and (d.kalibrasyon_gecerlilik is null or d.kalibrasyon_gecerlilik < current_date)
                      and (@p0 = 0 or d.sube_id in (0, @p0)))::int
                """, null, [sube], o => new int[]
                {
                    o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetInt32(4),
                    o.GetInt32(5), o.GetInt32(6), o.GetInt32(7), o.GetInt32(8), o.GetInt32(9),
                }, iptal))[0];

            // Eksik zorunlu eğitim: eğitim dilimi görünümü yoksa 0. Kişi sayısı -
            //   görünüm kişi kolonu taşıyorsa ayrık kişi, yoksa satır.
            var egitimKolonu = await b.TekDegerAsync<string>("""
                select case when to_regclass('public.v_kalite_egitim_eksik') is null then null
                            else coalesce((select c.column_name::text from information_schema.columns c
                                            where c.table_schema = 'public' and c.table_name = 'v_kalite_egitim_eksik'
                                              and c.column_name in ('personel_id', 'taraf_id')
                                            order by c.column_name limit 1), '') end
                """, null, null, iptal);
            var eksikEgitim = egitimKolonu is null ? 0
                : await b.TekDegerAsync<int>(egitimKolonu == ""
                    ? "select count(*)::int from public.v_kalite_egitim_eksik"
                    : $"select count(distinct {egitimKolonu})::int from public.v_kalite_egitim_eksik", null, null, iptal);

            var bana = await b.ListeAsync("""
                select * from (
                  select 'DÖF'::text as tur, d.id, d.no::text, d.tanim::text as is_, coalesce(dp.ad, '')::text as birim,
                         d.termin, '/kys-dof/' || d.id as yol
                    from public.kalite_dof d
                    left join public.departman dp on dp.id = d.departman_id
                   where d.sorumlu_id = @p1 and d.durum < 5 and (@p0 = 0 or d.sube_id in (0, @p0))
                  union all
                  select 'Faaliyet', d.id, d.no::text, f.faaliyet::text, coalesce(dp.ad, '')::text,
                         f.termin, '/kys-dof/' || d.id
                    from public.kalite_dof_faaliyet f
                    join public.kalite_dof d on d.id = f.dof_id
                    left join public.departman dp on dp.id = d.departman_id
                   where f.sorumlu_id = @p1 and f.durum < 2 and d.durum < 5 and (@p0 = 0 or d.sube_id in (0, @p0))
                  union all
                  select 'Denetim', d.id, d.no::text, coalesce(nullif(d.kapsam, ''), 'İç denetim')::text, coalesce(dp.ad, '')::text,
                         d.plan_tarih, '/kys-denetim/' || d.id
                    from public.kalite_denetim d
                    left join public.departman dp on dp.id = d.departman_id
                   where d.bas_denetci_id = @p1 and d.durum = 1 and (@p0 = 0 or d.sube_id in (0, @p0))
                  union all
                  select 'Karar', k.id, (coalesce(km.kod, 'YGG') || ' ' || to_char(t.tarih, 'DD.MM.YYYY'))::text, k.karar::text, ''::text,
                         k.termin, '/kys-karar/' || k.id
                    from public.kalite_karar k
                    join public.kalite_toplanti t on t.id = k.toplanti_id
                    left join public.kalite_komite km on km.id = t.komite_id
                   where k.sorumlu_id = @p1 and k.durum = 1 and (@p0 = 0 or k.sube_id in (0, @p0))
                  union all
                  select 'Olay', o.id, o.no::text, ('Değerlendir: ' || left(o.aciklama, 120))::text, coalesce(dp.ad, '')::text,
                         null::date, '/kys-olay/' || o.id
                    from public.kalite_olay o
                    join public.kalite_birim_sorumlu bs on bs.departman_id = o.departman_id and bs.aktif = 1
                                                       and (@p1 in (bs.sorumlu_id, bs.yedek_id))
                                                       and bs.sube_id in (0, o.sube_id)
                    left join public.departman dp on dp.id = o.departman_id
                   where o.durum in (1, 2) and (@p0 = 0 or o.sube_id in (0, @p0))
                ) x
                order by x.termin nulls last, x.tur, x.no
                limit 50
                """, null, [sube, ben], o => new
                {
                    tur = o.GetString(0),
                    id = o.GetInt32(1),
                    no = o.IsDBNull(2) ? "" : o.GetString(2),
                    @is = o.IsDBNull(3) ? "" : o.GetString(3),
                    birim = o.GetString(4),
                    termin = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                    gecikti = !o.IsDBNull(5) && Saat.Gun(o.GetDateTime(5)) < Saat.Bugun,
                    yol = o.GetString(6),
                }, iptal);

            // Başlıktaki "Kalite Sorumlusu: …" (mockup) - Ayarlar › Genel (1069).
            var sorumlu = await b.TekDegerAsync<string>("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')
                  from public.referans r join public.taraf t on t.id = nullif(r.deger, '')::integer
                 where r.anahtar = 'kys.genel_sorumlu_id'
                """, null, [], iptal);

            return Results.Ok(new
            {
                bugun = Saat.Bugun,
                kaliteSorumlusu = sorumlu ?? "",
                ozet = new
                {
                    acikDof = s[0], vadesiGecenDof = s[1], olay = s[2], denetimAy = s[3], denetimYapilan = s[4],
                    yuksekRisk = s[5], hedefDisi = s[6], hedefToplam = s[7], kalibrasyonYaklasan = s[8],
                    kalibrasyonGecen = s[9], eksikEgitim,
                },
                banaDusenler = bana,
            });
        });
    }
}
