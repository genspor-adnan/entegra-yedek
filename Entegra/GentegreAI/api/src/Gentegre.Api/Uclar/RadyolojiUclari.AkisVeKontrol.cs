using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÖDEYİCİ, akış şeridi ve kontrol listesi.
///
/// Uclar RadyolojiUclari.cs dosyasindan ayrildi: tek dosyada 1956 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class RadyolojiUclari
{
    private static void AkisVeKontrolEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------ hastanin odeyicisi ----
        // Kabul ekrani (mockup: "Ödeyen Kurum" + "Poliçe No") hastanin AKTIF
        //   policesini onden doldurmali - kabul masasi her seferinde kurumu
        //   elle aramasin. Hasta kartinin detay uctan okunmasi ayni bilgiyi
        //   dolayli getirirdi; tek satirlik cevap yeter.
        grup.MapGet("/hasta/{id:int}/odeme", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var odeme = await baglanti.TekAsync("""
                select k.kurum_id as "kurumId",
                       coalesce(t.unvan, '') as "kurumAd",
                       coalesce(k.police_no, '') as "policeNo"
                  from public.taraf_hasta_kurum k
                  left join public.taraf t on t.id = k.kurum_id
                 where k.hasta_id = @p0 and coalesce(k.aktif, 1) = 1
                 order by k.id desc
                 limit 1
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(odeme ?? new Dictionary<string, object?>());
        });

        // ------------------------------------------- akis / ozet seridi ----
        // Mockup radyoloji_istem_karti.html: ustte "Istem -> Randevu -> Cekim ->
        //   Raporlaniyor -> Onay -> Teslim" seridi ve alttaki ozet (bekleme
        //   suresi, rapor durumu, olusturan). Bes ayri tablodan okunur; tek
        //   uc olmasi kartin acilista tek istek atmasini saglar.
        grup.MapGet("/istem/{id:int}/akis", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var akis = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum,
                       i.ekleme_tarihi as "istemZamani",
                       rv.baslangic as "randevuZamani",
                       i.cekim_tarihi as "cekimZamani",
                       r.yazma_tarihi as "raporZamani",
                       r.onay_tarihi as "onayZamani",
                       (select max(t.teslim_zamani) from public.radyoloji_teslim t
                         where t.istem_id = i.id) as "teslimZamani",
                       coalesce(r.durum, 0) as "raporDurum",
                       coalesce(r.rapor_no, '') as "raporNo",
                       coalesce(ry.unvan, '') as "raporYazan",
                       coalesce(ek.unvan, '') as "olusturan",
                       -- BEKLEME (kalite gostergesi): istemden cekime kac dakika.
                       case when i.cekim_tarihi is null then null
                            else round(extract(epoch from
                                 (i.cekim_tarihi - i.ekleme_tarihi)) / 60)::int end as "beklemeDk"
                  from public.radyoloji_istem i
                  left join public.randevu rv on rv.id = i.randevu_id
                  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
                  -- Kullanici kaydi taraf ile AYNI id: taraf_kullanici 1:1
                  --   uzantidir, ayri bir "kullanici" tablosu yok.
                  left join public.taraf ry on ry.id = r.yazan_id
                  left join public.taraf ek on ek.id = i.ekleyen
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Istem bulunamadi.");

            return Results.Ok(akis);
        });

        // ------------------------------------------ kontrol listesi (310) ----
        // Sorular MODALITEYE gore gelir; yanit varsa uzerine binmis olarak.
        grup.MapGet("/istem/{id:int}/kontrol", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var sorular = await baglanti.ListeAsync("""
                select s.id as "soruId", s.soru, s.yanit_tipi as "yanitTipi",
                       s.zorunlu, coalesce(k.yanit, '') as yanit,
                       k.kayit_zamani as "kayitZamani",
                       coalesce(p.unvan, '') as "kaydeden"
                  from public.radyoloji_istem i
                  join public.radyoloji_kontrol_soru s
                    on s.aktif = 1 and (s.modalite is null or s.modalite = i.modalite)
                  left join public.radyoloji_kontrol k on k.soru_id = s.id and k.istem_id = i.id
                  left join public.taraf p on p.id = k.kaydeden
                 where i.id = @p0
                 order by s.sira, s.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { sorular });
        });

        // Yanitlar TOPLU yazilir: kullanici listeyi bir kerede doldurur, her
        //   kutu icin ayri istek atmak yarim kalmis kayit birakirdi.
        grup.MapPost("/istem/{id:int}/kontrol", async (
            int id, KontrolIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            foreach (var y in istek.Yanitlar ?? [])
            {
                var yanit = (y.Yanit ?? "").Trim();
                if (yanit.Length == 0)
                {
                    // Bos yanit = "yanitlanmadi": kayit SILINIR, boylece zorunlu
                    //   soru tetigi (310) yine devrede kalir.
                    await baglanti.CalistirAsync(
                        "delete from public.radyoloji_kontrol where istem_id = @p0 and soru_id = @p1",
                        islem, [id, y.SoruId], iptal);
                    continue;
                }

                await baglanti.CalistirAsync("""
                    insert into public.radyoloji_kontrol
                        (istem_id, soru_id, yanit, kaydeden, kayit_zamani)
                    values (@p0, @p1, @p2, @p3, (now())::timestamp)
                    on conflict (istem_id, soru_id) do update
                       set yanit = excluded.yanit, kaydeden = excluded.kaydeden,
                           kayit_zamani = excluded.kayit_zamani
                    """, islem, [id, y.SoruId, yanit, baglam.KullaniciId], iptal);
            }

            await islem.CommitAsync(iptal);
            return Results.Ok(new { kaydedildi = true });
        });
    }
}
