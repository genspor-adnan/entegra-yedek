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

        // GET /istem/{id}/kart-detay - İSTEM KARTI (mockup radyoloji_istem_karti.html)
        //   başlık + istem bilgisi + çekim/görüntü alanları tek çağrıda. Akış
        //   şeridi /akis, kontrol listesi /kontrol'den gelir.
        grup.MapGet("/istem/{id:int}/kart-detay", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);

            var kart = await baglanti.TekAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum, i.oncelik,
                       i.modalite,
                       case i.modalite when 1 then 'BT' when 2 then 'MR' when 3 then 'USG'
                            when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA'
                            when 7 then 'Anjiyo' when 8 then 'Skopi' else '' end as "modaliteAdi",
                       coalesce(dd.ad,'') as "durumAdi",
                       coalesce(od.ad,'') as "oncelikAdi",
                       i.hasta_id as "hastaId",
                       coalesce(nullif(trim(h.ad||' '||h.soyad),''), h.unvan, '') as "hastaAdi",
                       case coalesce(th.cinsiyet,0) when 1 then 'E' when 2 then 'K' else '' end as cinsiyet,
                       case when th.dogum_tarihi is null then null
                            else extract(year from age(th.dogum_tarihi))::int end as yas,
                       coalesce(h.telefon,'') as telefon,
                       coalesce(hz.kod,'') as "tetkikKodu", coalesce(hz.ad,'') as "tetkikAdi",
                       coalesce(nullif(ih.unvan,''), nullif(i.dis_hekim_ad,''), '') as "isteyenHekim",
                       coalesce(ik.unvan,'') as "isteyenKurum",
                       i.belge_id as "belgeId", coalesce(b.belge_no,'') as protokol, b.belge_tarihi as "protokolTarihi",
                       coalesce(i.on_tani,'') as "onTani", coalesce(i.klinik_bilgi,'') as "klinikBilgi",
                       coalesce(ok.unvan,'') as "odeyenKurum",
                       coalesce(cz.ad,'') as cihaz, coalesce(cz.kod,'') as "cihazKodu",
                       coalesce(tk.unvan,'') as tekniker,
                       i.cekim_tarihi as "cekimTarihi",
                       i.kontrast, coalesce(i.kontrast_ml,0) as "kontrastMl",
                       coalesce(i.seri_sayisi,0) as "seriSayisi", coalesce(i.goruntu_sayisi,0) as "goruntuSayisi",
                       i.dlp, i.ctdi, coalesce(i.study_uid,'') as "studyUid"
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.taraf_hasta th on th.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.taraf ih on ih.id = i.istek_hekim_id
                  left join public.taraf ik on ik.id = i.istek_kurum_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                  left join public.radyoloji_cihaz cz on cz.id = i.cihaz_id
                  left join public.taraf tk on tk.id = i.tekniker_id
                  left join public.kod_deger dd on dd.deger = i.durum and dd.dil = 0
                        and dd.liste_id = (select id from public.kod_liste where kod = 'rad.istem_durum')
                  left join public.kod_deger od on od.deger = i.oncelik and od.dil = 0
                        and od.liste_id = (select id from public.kod_liste where kod = 'rad.oncelik')
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");
            return Results.Ok(kart);
        });

        // PUT /istem/{id} - İSTEM KARTI düzenlenebilir alanları (mockup).
        //   Hasta/tetkik/ödeyen kurum başvurudan gelir, BURADA DEĞİŞMEZ; yalnız
        //   klinik alanlar + çekim/görüntü bilgisi güncellenir.
        grup.MapPut("/istem/{id:int}", async (
            int id, IstemGuncelleIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            var n = await baglanti.CalistirAsync("""
                update public.radyoloji_istem
                   set klinik_bilgi = @p1, on_tani = @p2, oncelik = @p3,
                       kontrast = @p4, kontrast_ml = @p5,
                       seri_sayisi = @p6, goruntu_sayisi = @p7,
                       degistiren = @p8, degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, null,
                [id, istek.KlinikBilgi ?? "", istek.OnTani ?? "", (short)(istek.Oncelik ?? 1),
                 (short)(istek.Kontrast ?? 0), istek.KontrastMl,
                 istek.SeriSayisi, istek.GoruntuSayisi, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");
            return Results.Ok(new { id, mesaj = "İstem güncellendi.", izlemeNo = baglam.IzlemeNo });
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
