using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TELERADYOLOJİ PANOSU (801) — mockup `Ekranlar/Teleradyoloji/telerad_pano.html`.
///
/// Modülün "bugün ne durumdayız" ekranı: SLA uyumu, bekleyen iş, kurum ve
/// modalite kırılımı, radyolog yükü, saatlik yığılma.
///
/// <b>Sayılar SUNUCUDA, tek uçtan.</b> Kalan dakika ve SLA riski zaten
/// `v_telerad_istek` içinde hesaplanıyor; pano da aynı görünümü okur.
/// İstemci kendi "şimdi"siyle yeniden hesaplasaydı liste ile pano aynı iş
/// için iki farklı sayı gösterirdi. Altı ayrı istek yerine tek uç: ekranın
/// yarısı dolu yarısı boş görünmesin.
///
/// <b>Yeni tablo yok.</b> Panonun ✔ işaretli panellerinin tamamı mevcut
/// görünüm üzerinde sayım/ortalamadır (mockup'taki veri durumu işaretleri).
/// Nöbet, hakediş ve dönem faturası panelleri o işler yapılmadığı için burada
/// da YOK - uydurma sayı göstermek panoyu güvenilmez kılar.
/// </summary>
public static class TeleradUclari
{
    public static void TeleradUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/telerad").WithTags("Teleradyoloji").RequireAuthorization();

        grup.MapGet("/pano", async (
            DateTime? gun, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // LİSTE İLE AYNI YETKİ: pano listenin özetidir, ayrı bir kapı değil.
            baglam.YetkiIste("teleradyoloji", Islem.Gor);

            var tarih = (gun ?? DateTime.Today).Date;
            await using var baglanti = await veri.AcAsync(iptal);

            // --------------------------------------------------- sayaçlar ----
            // BEKLEYEN = durum <= 3 (görüntü bekleniyor · sırada · atandı):
            //   radyolog listesinin başından alır, hepsi "bizde iş var"
            //   demektir. SLA aşımı bunların ALT KÜMESİ - ayrı sayılır ki
            //   "37 bekliyor" ile "3'ü gecikti" aynı bakışta görünsün.
            var sayaclar = await baglanti.TekAsync("""
                select
                  (select count(*) from public.v_telerad_istek i
                    where i.durum between 1 and 3
                      and (@p1::int is null or i.sube_id = @p1))            as "bekleyen",
                  (select count(*) from public.v_telerad_istek i
                    where i.durum between 1 and 3 and i.oncelik = 3
                      and (@p1::int is null or i.sube_id = @p1))            as "bekleyenAcil",
                  (select count(*) from public.v_telerad_istek i
                    where i.durum < 6 and i.durum > 0 and i.sla_riskli = 1
                      and (@p1::int is null or i.sube_id = @p1))            as "slaKacan",
                  (select count(*) from public.v_telerad_istek i
                    where i.durum = 4
                      and (@p1::int is null or i.sube_id = @p1))            as "okunuyor",
                  (select count(*) from public.v_telerad_istek i
                    where i.gelis_zamani::date = @p0
                      and (@p1::int is null or i.sube_id = @p1))            as "bugunGelen",
                  (select count(*) from public.v_telerad_istek i
                    where i.onay_zamani::date = @p0
                      and (@p1::int is null or i.sube_id = @p1))            as "bugunOnaylanan",
                  (select count(*) from public.v_telerad_istek i
                    where i.durum = 6
                      and (@p1::int is null or i.sube_id = @p1))            as "teslimBekleyen",
                  (select count(*) from public.v_telerad_istek i
                    where i.durum = 8
                      and (@p1::int is null or i.sube_id = @p1))            as "ekGoruntu",
                  -- Görüntüsü gelmemiş istek: SLA saati HENÜZ İŞLEMİYOR ama
                  --   gönderen kurum bekliyor; bizim tarafta yapılacak iş yok.
                  (select count(*) from public.v_telerad_istek i
                    where i.durum = 1
                      and (@p1::int is null or i.sube_id = @p1))            as "goruntuBekleyen"
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // AY ÖZETİ: SLA uyumu ve ortalama süre tek günde küçük kurumda
            //   anlamsız dalgalanır - son 30 gün.
            var ay = await baglanti.TekAsync("""
                with k as (
                  select i.*
                    from public.v_telerad_istek i
                   where i.durum > 0
                     and (@p1::int is null or i.sube_id = @p1)
                     and coalesce(i.gelis_zamani, i.cekim_zamani)
                         >= (@p0::date - interval '30 day')
                )
                select
                  (select count(*) from k)                                  as "istek",
                  (select count(*) from k where k.onay_zamani is not null)  as "onaylanan",
                  -- SLA UYUMU: SÖZÜ OLAN işler üzerinden. Sözleşmesi olmayan
                  --   (sla_dk = 0) istek için "uyduk" demek uydurma olurdu.
                  (select count(*) from k where k.sla_dk > 0
                                            and k.onay_zamani is not null)  as "sozluOnaylanan",
                  (select count(*) from k where k.sla_dk > 0
                                            and k.onay_zamani is not null
                                            and k.sla_asildi = 0)           as "slaUyan",
                  -- RAPOR SÜRESİ görüntünün geldiği andan onaya: SLA'nın
                  --   ölçtüğü süre budur (istek açılışı değil).
                  coalesce((select avg(extract(epoch from
                             (k.onay_zamani - k.gelis_zamani)) / 60)
                              from k where k.onay_zamani is not null
                                       and k.gelis_zamani is not null), 0)::int as "ortRaporDk",
                  coalesce((select avg(extract(epoch from
                             (k.onay_zamani - k.gelis_zamani)) / 60)
                              from k where k.onay_zamani is not null
                                       and k.gelis_zamani is not null
                                       and k.oncelik = 3), 0)::int          as "ortAcilDk",
                  -- OKUMA SÜRESİ (799 damgası): "sırada bekledi" ile
                  --   "radyolog okudu" ancak bu damga varsa ayrılır.
                  coalesce((select avg(extract(epoch from
                             (k.onay_zamani - k.okuma_bas)) / 60)
                              from k where k.onay_zamani is not null
                                       and k.okuma_bas is not null), 0)::int as "ortOkumaDk",
                  -- TETKİK ÜCRETİ TOPLAMI - dönem faturası DEĞİL: fatura
                  --   modeli (aylık sabit + aşım) ayrı bir iş, burada
                  --   isteklere yazılmış ücretlerin toplamı duruyor.
                  coalesce((select sum(k.ucret) from k), 0)                 as "ucretToplam"
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ------------------------------------------------ kurum kırılımı ----
            var kurumlar = await baglanti.ListeAsync("""
                select i.kurum_id                                           as "kurumId",
                       i.kurum_adi                                          as "kurumAdi",
                       count(*)                                             as "istek",
                       count(*) filter (where i.durum between 1 and 3)      as "bekleyen",
                       count(*) filter (where i.sla_dk > 0
                                          and i.onay_zamani is not null)    as "sozlu",
                       count(*) filter (where i.sla_dk > 0
                                          and i.onay_zamani is not null
                                          and i.sla_asildi = 0)             as "slaUyan",
                       coalesce(avg(extract(epoch from
                         (i.onay_zamani - i.gelis_zamani)) / 60)
                         filter (where i.onay_zamani is not null
                                   and i.gelis_zamani is not null), 0)::int as "ortRaporDk",
                       coalesce(sum(i.ucret), 0)                            as "ucret"
                  from public.v_telerad_istek i
                 where i.durum > 0
                   and (@p1::int is null or i.sube_id = @p1)
                   and coalesce(i.gelis_zamani, i.cekim_zamani) >= (@p0::date - interval '30 day')
                 group by i.kurum_id, i.kurum_adi
                 order by 3 desc
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // --------------------------------------------- modalite dağılımı ----
            // Modalite ADI çalışma listesindeki ifadeyle AYNI (KaynakKatalogu):
            //   iki ekran aynı tetkike iki ad yazmasın.
            var modalite = await baglanti.ListeAsync("""
                select i.modalite,
                       case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG'
                            when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA'
                            when 7 then 'Anjiyo' when 8 then 'Skopi' else '—' end as "modaliteAdi",
                       count(*)                                             as "adet",
                       coalesce(avg(extract(epoch from
                         (i.onay_zamani - i.gelis_zamani)) / 60)
                         filter (where i.onay_zamani is not null
                                   and i.gelis_zamani is not null), 0)::int as "ortRaporDk"
                  from public.v_telerad_istek i
                 where i.durum > 0
                   and (@p1::int is null or i.sube_id = @p1)
                   and coalesce(i.gelis_zamani, i.cekim_zamani) >= (@p0::date - interval '30 day')
                 group by i.modalite
                 order by 3 desc
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ------------------------------------------------- radyolog yükü ----
            // "Bende" = atanmış ve henüz onaylanmamış iş. Vardiya ve hakediş
            //   sütunları YOK: nöbet çizelgesi ve Prim bağı yapılmadı.
            var radyologlar = await baglanti.ListeAsync("""
                select i.atanan_radyolog_id                                 as "radyologId",
                       i.radyolog_adi                                       as "radyologAdi",
                       count(*) filter (where i.durum between 3 and 5)      as "bende",
                       count(*) filter (where i.onay_zamani::date = @p0)    as "bugunOnaylanan",
                       count(*) filter (where i.durum < 6 and i.durum > 0
                                          and i.sla_riskli = 1)             as "slaKacan",
                       coalesce(avg(extract(epoch from
                         (i.onay_zamani - i.gelis_zamani)) / 60)
                         filter (where i.onay_zamani is not null
                                   and i.gelis_zamani is not null), 0)::int as "ortRaporDk"
                  from public.v_telerad_istek i
                 where i.durum > 0 and i.atanan_radyolog_id is not null
                   and (@p1::int is null or i.sube_id = @p1)
                   and coalesce(i.gelis_zamani, i.cekim_zamani) >= (@p0::date - interval '30 day')
                 group by i.atanan_radyolog_id, i.radyolog_adi
                 order by 3 desc, 4 desc
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ---------------------------------------------- saatlik yığılma ----
            // Geliş ve onay saatleri: akşam/gece yığılması nöbet ve otomatik
            //   dağıtım kuralının (faz 2) ilk girdisidir. SAAT SUNUCUDA
            //   üretilir - istemci kendi saat dilimiyle kaydırmasın.
            var saatler = await baglanti.ListeAsync("""
                with s as (select generate_series(0, 23) as saat)
                select s.saat,
                       (select count(*) from public.v_telerad_istek i
                         where i.gelis_zamani::date = @p0
                           and extract(hour from i.gelis_zamani) = s.saat
                           and (@p1::int is null or i.sube_id = @p1))       as "gelen",
                       (select count(*) from public.v_telerad_istek i
                         where i.onay_zamani::date = @p0
                           and extract(hour from i.onay_zamani) = s.saat
                           and (@p1::int is null or i.sube_id = @p1))       as "onaylanan"
                  from s order by s.saat
                """, null, [tarih, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                tarih = tarih.ToString("yyyy-MM-dd"),
                sayaclar, ay, kurumlar, modalite, radyologlar, saatler,
            });
        });
    }
}
