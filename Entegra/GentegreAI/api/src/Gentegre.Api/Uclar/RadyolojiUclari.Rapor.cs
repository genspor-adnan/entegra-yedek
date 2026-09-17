using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RAPOR EKRANI, çıktısı ve taslak kaydetme.
///
/// Uclar RadyolojiUclari.cs dosyasindan ayrildi: tek dosyada 1956 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class RadyolojiUclari
{
    private static void RaporEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------- rapor ekranı ----
        // Ekranın ihtiyacı olan HER ŞEY tek istekte: istem + hasta + tetkik,
        //   rapor (varsa bölümleriyle), uygun şablonlar, makrolar, skor
        //   tanımları ve hastanın önceki tetkikleri. Beş ayrı istek atmak
        //   ekranı açılışta yavaşlatır ve yarı dolu göstermeye açık bırakır.
        grup.MapGet("/istem/{id:int}/rapor", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum, i.oncelik, i.modalite,
                       i.hasta_id as "hastaId", coalesce(h.unvan, '') as "hastaAdi",
                       coalesce(hs.cinsiyet, 0) as cinsiyet, hs.dogum_tarihi as "dogumTarihi",
                       i.hizmet_id as "hizmetId",
                       coalesce(hz.kod, '') as "tetkikKodu", coalesce(hz.ad, '') as "tetkikAdi",
                       i.on_tani as "onTani", i.klinik_bilgi as "klinikBilgi",
                       coalesce(ih.unvan, nullif(i.dis_hekim_ad, ''), '') as "isteyen",
                       i.cekim_tarihi as "cekimTarihi", i.kritik,
                       coalesce(cz.ad, '') as "cihazAdi",
                       i.seri_sayisi as "seriSayisi", i.goruntu_sayisi as "goruntuSayisi",
                       i.study_uid as "studyUid",
                       i.belge_id as "belgeId", coalesce(ok.unvan, '') as "odeyenKurum"
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta hs on hs.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            var hizmetId = Convert.ToInt32(istem["hizmetId"] ?? 0);
            var hastaId  = Convert.ToInt32(istem["hastaId"] ?? 0);

            var rapor = await baglanti.TekAsync("""
                select r.id, r.sablon_id as "sablonId", r.sablon_surum as "sablonSurum",
                       r.durum, r.kilit, r.ust_rapor_id as "ustRaporId",
                       coalesce(yz.unvan, '') as "yazan", r.yazma_tarihi as "yazmaTarihi",
                       coalesce(on_.unvan, '') as "onaylayan", r.onay_tarihi as "onayTarihi"
                  from public.radyoloji_rapor r
                  left join public.taraf yz on yz.id = r.yazan_id
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where r.istem_id = @p0 and r.ust_rapor_id is null
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var bolumler = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select b.id, b.sira, b.baslik, b.metin, b.yazdir,
                           coalesce(sb.zorunlu, 0) as zorunlu
                      from public.radyoloji_rapor_bolum b
                      join public.radyoloji_rapor r on r.id = b.rapor_id
                      left join public.radyoloji_sablon_bolum sb
                             on sb.sablon_id = r.sablon_id and sb.baslik = b.baslik
                     where b.rapor_id = @p0 order by b.sira
                    """, null, [Convert.ToInt32(rapor["id"])], OkuyucuGenisletmeleri.Sozluk, iptal);

            var alanlar = rapor is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", deger
                      from public.radyoloji_rapor_alan where rapor_id = @p0 order by id
                    """, null, [Convert.ToInt32(rapor["id"])], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Şablonlar: önce tetkike bağlı olanlar, sonra aynı modalitenin
            //   genel şablonları (tetkike özel yoksa hekim yine bir şey bulsun).
            var sablonlar = await baglanti.ListeAsync("""
                select s.id, s.kod, s.ad, s.surum, s.varsayilan,
                       case when s.hizmet_id = @p0 then 1 else 0 end as "tetkigeOzel"
                  from public.radyoloji_sablon s
                 where s.durum = 1
                   and (s.hizmet_id = @p0
                        or (s.hizmet_id is null and s.modalite = @p1))
                 order by "tetkigeOzel" desc, s.varsayilan desc, s.ad
                """, null, [hizmetId, Convert.ToInt32(istem["modalite"] ?? 0)], OkuyucuGenisletmeleri.Sozluk, iptal);

            var sablonId = rapor?["sablonId"] as int?
                        ?? (sablonlar.Count > 0 ? Convert.ToInt32(sablonlar[0]["id"]) : (int?)null);

            var makrolar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select kisayol, ad, metin, hedef_bolum as "hedefBolum"
                      from public.radyoloji_sablon_makro where sablon_id = @p0 order by id
                    """, null, [sablonId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);

            var skorlar = sablonId is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select alan_kod as "alanKod", alan_ad as "alanAd", tip, secenekler,
                           zorunlu, rapora_bas as "raporaBas"
                      from public.radyoloji_sablon_alan where sablon_id = @p0 order by sira
                    """, null, [sablonId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Önceki tetkikler: karşılaştırma bölümü bunlardan yazılır.
            var gecmis = await baglanti.ListeAsync("""
                select i.id, i.accession_no as "accessionNo", coalesce(hz.ad, '') as "tetkikAdi",
                       coalesce(i.cekim_tarihi, i.ekleme_tarihi) as tarih,
                       coalesce(on_.unvan, '') as "raporlayan",
                       coalesce((select left(b.metin, 120) from public.radyoloji_rapor_bolum b
                                  join public.radyoloji_rapor r2 on r2.id = b.rapor_id
                                 where r2.istem_id = i.id and b.baslik ilike '%sonu%'
                                 order by b.sira limit 1), '') as "ozet"
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.radyoloji_rapor r on r.istem_id = i.id and r.ust_rapor_id is null
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where i.hasta_id = @p0 and i.id <> @p1 and i.durum > 0
                 order by coalesce(i.cekim_tarihi, i.ekleme_tarihi) desc limit 8
                """, null, [hastaId, id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var kritikler = await baglanti.ListeAsync("""
                select bulgu, bildirilen_ad as "bildirilenAd", yol,
                       bildirim_zamani as "bildirimZamani", geri_bildirim as "geriBildirim"
                  from public.radyoloji_kritik_bulgu where istem_id = @p0 order by id desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { istem, rapor, bolumler, alanlar, sablonlar, makrolar,
                                    skorlar, gecmis, kritikler });
        });

        // ------------------------------------------------- rapor ÇIKTISI ----
        // Hastaya verilen belge (mockup: radyoloji_rapor_onizleme.html). Yazma
        //   ekranından AYRI uç: çıktının ihtiyacı şablon/makro/skor değil,
        //   KURUM ANTETİ, kimlik satırları, basılacak bölümler ve imzadır.
        //
        // Yalnız `yazdir = 1` bölümler döner: şablonda ekrana konan ama
        //   hastaya basılmayan bölümler (ör. teknisyen notu) çıktıya girmez.
        grup.MapGet("/rapor/{id:int}/cikti", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var rapor = await baglanti.TekAsync("""
                select r.id, r.rapor_no as "raporNo", r.durum, r.kilit,
                       r.ust_rapor_id as "ustRaporId",
                       coalesce(yz.unvan, '') as "yazan", r.yazma_tarihi as "yazmaTarihi",
                       coalesce(on_.unvan, '') as "onaylayan", r.onay_tarihi as "onayTarihi",
                       i.id as "istemId", i.accession_no as "accessionNo",
                       i.modalite, i.cekim_tarihi as "cekimTarihi",
                       i.on_tani as "onTani", i.klinik_bilgi as "klinikBilgi",
                       i.kontrast, coalesce(cz.ad, '') as "cihazAdi",
                       coalesce(hz.kod, '') as "tetkikKodu", coalesce(hz.ad, '') as "tetkikAdi",
                       coalesce(h.unvan, '') as "hastaAdi", coalesce(h.kod, '') as "hastaNo",
                       coalesce(h.vkno, '') as "hastaTc",
                       hs.dogum_tarihi as "dogumTarihi", coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(ih.unvan, nullif(i.dis_hekim_ad, ''), '') as "isteyen",
                       coalesce(ik.unvan, '') as "isteyenKurum",
                       coalesce(b.belge_no, '') as "protokolNo",
                       coalesce(ok.unvan, '') as "odeyenKurum"
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                  left join public.taraf yz on yz.id = r.yazan_id
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta hs on hs.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.taraf ik on ik.id = i.istek_kurum_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where r.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");

            var bolumler = await baglanti.ListeAsync("""
                select sira, baslik, metin
                  from public.radyoloji_rapor_bolum
                 where rapor_id = @p0 and coalesce(yazdir, 1) = 1
                   and coalesce(metin, '') <> ''
                 order by sira
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // Skor/ölçüm alanları rapora BASILACAK olanlarla sınırlı.
            var alanlar = await baglanti.ListeAsync("""
                select a.alan_ad as "alanAd", a.deger
                  from public.radyoloji_rapor_alan a
                  join public.radyoloji_rapor r on r.id = a.rapor_id
                  left join public.radyoloji_sablon_alan sa
                         on sa.sablon_id = r.sablon_id and sa.alan_kod = a.alan_kod
                 where a.rapor_id = @p0
                   and coalesce(sa.rapora_bas, 1) = 1
                   and coalesce(a.deger, '') <> ''
                 order by a.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // EK RAPORLAR (addendum): orijinalin altında, tarihleriyle basılır -
            //   düzeltme ayrı kayıttır, orijinal metin değişmez.
            var ekler = await baglanti.ListeAsync("""
                select r.id, r.rapor_no as "raporNo", r.onay_tarihi as "onayTarihi",
                       coalesce(on_.unvan, '') as "onaylayan",
                       coalesce((select string_agg(b.metin, E'\n' order by b.sira)
                                   from public.radyoloji_rapor_bolum b
                                  where b.rapor_id = r.id and coalesce(b.yazdir, 1) = 1), '') as metin
                  from public.radyoloji_rapor r
                  left join public.taraf on_ on on_.id = r.onaylayan_id
                 where r.ust_rapor_id = @p0
                 order by r.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ANTET: raporun ait olduğu şube (kurum kimliği hastaya verilen
            //   belgede zorunlu). Şube yoksa varsayılan şube kullanılır.
            var kurum = await baglanti.TekAsync("""
                select a.unvan, a.adres, a.ilce, a.il, a.telefon,
                       a.mersis_no as "mersisNo", a.vkno, a.vd,
                       a.logo_dokuman_id as "logoDokumanId"
                  from public.v_sube_antet a
                 where a.sube_id = coalesce(
                           (select i.sube_id from public.radyoloji_istem i
                              join public.radyoloji_rapor r on r.istem_id = i.id
                             where r.id = @p0),
                           (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { rapor, bolumler, alanlar, ekler, kurum });
        });

        // ------------------------------------------------- taslak kaydet ----
        // Rapor yoksa açılır, varsa güncellenir. Bölümler TOPLU yazılır
        //   (sil+yaz): sıra ve başlık şablondan gelir, kısmi güncelleme
        //   ikisini ayrıştırırdı.
        grup.MapPost("/istem/{id:int}/rapor", async (
            int id, RaporIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var mevcut = await baglanti.TekDegerAsync<int?>(
                "select id from public.radyoloji_rapor where istem_id = @p0 and ust_rapor_id is null",
                islem, [id], iptal);

            // KİLİT: onaylı rapor değiştirilemez - düzeltme addendum'dur.
            var kilit = mevcut is null ? 0 : await baglanti.TekDegerAsync<int>(
                "select coalesce(kilit, 0) from public.radyoloji_rapor where id = @p0",
                islem, [mevcut.Value], iptal);
            if (kilit == 1)
                throw GentegreHatasi.IsKurali(
                    "Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");

            int raporId;
            if (mevcut is null)
            {
                raporId = Convert.ToInt32(await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_rapor
                           (istem_id, sablon_id, sablon_surum, durum, yazan_id, yazma_tarihi, ekleyen)
                    select @p0, @p1,
                           coalesce((select surum from public.radyoloji_sablon where id = @p1), 1),
                           1, @p2, now()::timestamp, @p2
                    returning id
                    """, islem, [id, istek.SablonId, baglam.KullaniciId], iptal));
            }
            else
            {
                raporId = mevcut.Value;
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set sablon_id = coalesce(@p1, sablon_id),
                           degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, [raporId, istek.SablonId, baglam.KullaniciId], iptal);
            }

            if (istek.Bolumler is { Count: > 0 })
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_bolum where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var b in istek.Bolumler)
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin, yazdir)
                        values (@p0, @p1, @p2, @p3, @p4)
                        """, islem, [raporId, (short)b.Sira, b.Baslik, b.Metin ?? "", b.Yazdir], iptal);
            }

            if (istek.Alanlar is not null)
            {
                await baglanti.CalistirAsync(
                    "delete from public.radyoloji_rapor_alan where rapor_id = @p0",
                    islem, [raporId], iptal);
                foreach (var a in istek.Alanlar.Where(x => !string.IsNullOrWhiteSpace(x.Deger)))
                    await baglanti.CalistirAsync("""
                        insert into public.radyoloji_rapor_alan (rapor_id, alan_kod, alan_ad, deger)
                        values (@p0, @p1, @p2, @p3)
                        """, islem, [raporId, a.AlanKod, a.AlanAd ?? "", a.Deger], iptal);
            }

            if (istek.Kritik is { } kritik)
                await baglanti.CalistirAsync(
                    "update public.radyoloji_istem set kritik = @p1 where id = @p0",
                    islem, [id, kritik], iptal);

            // İstem "Raporlanıyor"a geçer (henüz çekilmemişse dokunulmaz).
            await baglanti.CalistirAsync(
                "update public.radyoloji_istem set durum = 3 where id = @p0 and durum = 2",
                islem, [id], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { raporId });
        });
    }
}
