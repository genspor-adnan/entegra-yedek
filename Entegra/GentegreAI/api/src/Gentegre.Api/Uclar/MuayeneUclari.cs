using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE AKIŞI (409, Faz 1) — hekimin iki düğmesi.
///
/// Kartın alanlarını kaydetmek genel kart ucundan yürür; burada olan şey
/// DURUM GEÇİŞİdir ve geçişin kuralları vardır:
///
/// <para><b>Muayeneye Al</b> başlangıç zamanını yazar. Bu zaman USS "Muayene
/// Başlangıç" alanıdır ve kartın açılma zamanıyla aynı değildir: kart sabah
/// açılıp hasta öğleden sonra girebilir. İkinci kez basmak zamanı EZMEZ -
/// yoksa "hasta ne zaman girdi" sorusunun cevabı her tıklamada değişirdi.</para>
///
/// <para><b>Tamamla</b> kaydı kilitler, başvuruyu tahakkuka döndürür ve
/// e-Nabız kuyruğuna atar. Bu yüzden eksik kayıtta reddedilir: ana tanı,
/// şikayet ve karar zorunludur. Kontrolü gönderim anına bırakmak, hatayı
/// hekim ekrandan ayrıldıktan çok sonra geri getirirdi.</para>
/// </summary>
public static class MuayeneUclari
{
    public static void MuayeneUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/muayene").WithTags("Muayene").RequireAuthorization();

        // POST /api/muayene/{id}/al - "Muayeneye Al"
        // GET /api/muayene/ozet?gun=YYYY-MM-DD - LISTE OZET SERIDI (461)
        //
        // Mockup `muayene_listesi.html` ustundeki alti kutu: poliklinigin o
        //   gunku hali. Tek uctan gelir - alti ayri istek ekranin yarisini
        //   dolu yarisini bos gosterirdi (radyoloji/lab panosu deseni).
        //
        // SAYILAR SUBEYE SUZULUR: baska subenin poliklinigi bu ekranin isi
        //   degil; yetki katmani zaten subeyi baglama koyuyor.
        grup.MapGet("/ozet", async (
            string? gun, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            var tarih = DateTime.TryParse(gun, out var t) ? t.Date : DateTime.Today;
            var sube = baglam.SubeId ?? 0;

            await using var baglanti = await veri.AcAsync(iptal);

            var sayac = await baglanti.TekAsync("""
                select
                  count(*)                                        as "muayene",
                  count(*) filter (where m.durum = 1)             as "acik",
                  count(*) filter (where m.durum = 2)             as "tamamlanan",
                  -- ORTALAMA SURE yalniz TAMAMLANANLARDA anlamli: acik
                  --   muayenenin suresi "simdiye kadar" demek, ortalamayi
                  --   suni sekilde buyutur.
                  coalesce(round(avg(extract(epoch from (m.tamamlanma - m.baslangic)) / 60)
                           filter (where m.durum = 2 and m.baslangic is not null
                                     and m.tamamlanma is not null)), 0) as "ortDk",
                  -- BEKLEYEN: muayeneye hic alinmamis kayit (baslangic bos).
                  count(*) filter (where m.baslangic is null and m.durum = 1) as "bekleyen",
                  coalesce(max(extract(epoch from (now() - m.ekleme_tarihi)) / 60)
                           filter (where m.baslangic is null and m.durum = 1), 0)::int
                                                                  as "enUzunBeklemeDk",
                  -- TANI GIRILMEMIS: tamamlanmis ama tanisi olmayan muayene -
                  --   basvuru tahakkuka dusmez, e-Nabiz paketi eksik alanda kalir.
                  count(*) filter (where m.durum = 2 and not exists
                      (select 1 from public.tani ta where ta.muayene_id = m.id))
                                                                  as "tanisiz"
                  from public.muayene m
                 where m.muayene_tarihi >= @p0 and m.muayene_tarihi < @p0 + interval '1 day'
                   and (@p1 = 0 or m.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SONUC: bugun ONAYLANAN lab satiri ve raporlanan radyoloji -
            //   "sonuc geldi" bilgisi hekimin siradaki isini belirler.
            var sonuc = await baglanti.TekAsync("""
                select
                  (select count(*) from public.lab_sonuc s
                    where s.onay_zamani >= @p0 and s.onay_zamani < @p0 + interval '1 day') as "lab",
                  (select count(*) from public.radyoloji_rapor r
                    where r.onay_tarihi >= @p0
                      and r.onay_tarihi < @p0 + interval '1 day') as "radyoloji",
                  (select count(*) from public.lab_istem_satir ls
                     join public.lab_istem li on li.id = ls.istem_id
                    where ls.durum in (1, 2) and li.istem_tarihi >= @p0 - interval '7 days')
                                                                             as "bekleyenTetkik"
                """, null, [tarih], OkuyucuGenisletmeleri.Sozluk, iptal);

            // e-NABIZ: bugunku muayene paketleri (kaynak_tur = 2) kacinci
            //   gonderildi. Bildirim yukumlulugu gun icinde izlenmeli.
            var enabiz = await baglanti.TekAsync("""
                select count(*) as "toplam",
                       count(*) filter (where p.durum = 3) as "gonderilen"
                  from public.enabiz_paket p
                 where p.kaynak_tur = 2 and p.uretim_tarihi >= @p0
                   and p.uretim_tarihi < @p0 + interval '1 day'
                   and (@p1 = 0 or p.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            var randevu = await baglanti.TekAsync("""
                select count(*) as "randevu",
                       count(*) filter (where r.durum = 4) as "gelmedi"
                  from public.randevu r
                 where r.baslangic >= @p0 and r.baslangic < @p0 + interval '1 day'
                   and (@p1 = 0 or r.sube_id = @p1)
                """, null, [tarih, sube], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                gun = tarih.ToString("yyyy-MM-dd"),
                sayac, sonuc, enabiz, randevu, izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPost("/{id:int}/al", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            // coalesce: ikinci tikta zaman EZILMEZ.
            var zaman = await veri.TekDegerAsync<DateTime?>("""
                update public.muayene
                   set baslangic = coalesce(baslangic, now()),
                       durum = case when durum = 0 then 1 else durum end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning baslangic
                """, [id, baglam.KullaniciId], iptal);

            if (zaman is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            return Results.Ok(new { id, baslangic = zaman,
                                    mesaj = $"Muayeneye alindi ({zaman:HH:mm}).",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/tamamla
        grup.MapPost("/{id:int}/tamamla", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.durum, m.belge_id, btrim(m.sikayet), btrim(m.karar),
                       (select count(*) from public.tani t
                         where t.muayene_id = m.id and t.tur = 1),
                       (select count(*) from public.muayene_istem s
                         where s.muayene_id = m.id and s.sonuc_durum in (0, 1)),
                       -- e-NABIZ 103/106'NIN ZORUNLU ALANLARI (628):
                       --   baslangic zamani, cikis sekli ve basvurunun
                       --   SYS takip numarasi.
                       (m.baslangic is not null),
                       coalesce(public.fn_skrs_kod('cikis.sekli', m.cikis_sekli), ''),
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = m.belge_id), '')
                  from public.muayene m where m.id = @p0 for update
                """, islem, [id], o => new
                {
                    Durum = o.GetInt16(0),
                    BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    Sikayet = o.GetString(2), Karar = o.GetString(3),
                    AnaTani = o.GetInt64(4), BekleyenIstem = o.GetInt64(5),
                    Baslatildi = o.GetBoolean(6), CikisKodu = o.GetString(7),
                    Takip = o.GetString(8),
                }, iptal);

            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Muayene zaten tamamlanmis.");

            // TAMAMLAMA KURALI (muayene sureci, adim 10). Eksikler TEK SEFERDE
            //   sayilir: hekime "once tani gir", sonra "sikayet de lazim"
            //   demek ekrani iki kez kapattirirdi.
            var eksikler = new List<AlanHatasi>();
            if (m.AnaTani == 0) eksikler.Add(new("tanilar", "Ana tani zorunlu."));
            if (m.Sikayet.Length == 0) eksikler.Add(new("sikayet", "Sikayet zorunlu."));
            if (m.Karar.Length == 0) eksikler.Add(new("karar", "Degerlendirme / plan zorunlu."));

            // e-NABIZ'IN ZORUNLU ALANLARI DA BURADA DURDURUR (628).
            //
            // 103 ve 106 muayene tamamlanirken uretilir; USS o paketleri
            //   eksik alanla REDDEDIYOR ve hata hekime SAATLER SONRA, kuyruk
            //   ekraninda donuyordu - o sirada muayene kilitli ve duzeltmek
            //   icin geri acmak gerekiyor. Kontrol tamamlama anina alindi:
            //     · MUAYENE_BASLANGIC_TARIHI (103) -> muayeneye alinmis olmali
            //     · CIKIS_SEKLI (106)              -> SKRS listesinde gecerli kod
            //   Gercek vaka: CIKIS_SEKLI bos gonderildi, "E1014 ... eksik
            //   elemanlar var: CIKIS_SEKLI" (paket 652).
            if (!m.Baslatildi)
                eksikler.Add(new("baslangic",
                    "Muayene baslatilmamis - 'Muayeneye Al' ile baslangic zamani yazilmali."));
            if (m.CikisKodu.Length == 0)
                eksikler.Add(new("cikisSekli",
                    "Cikis sekli secilmeli (e-Nabiz cikis bildiriminin zorunlu alani)."));
            if (eksikler.Count > 0)
                throw GentegreHatasi.Dogrulama(
                    "Muayene tamamlanamaz: " + string.Join(" ", eksikler.Select(x => x.Mesaj)),
                    [.. eksikler]);

            await baglanti.CalistirAsync("""
                update public.muayene
                   set durum = 3, bitis = coalesce(bitis, now()), tamamlanma = now(),
                       tamamlayan_id = @p1, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // e-NABIZ 103 + 106 KUYRUGA (415). Gonderim USS kapisi acilinca;
            //   uretim simdi yapilir, yoksa kapi acildiginda gecmis veri
            //   kaybolurdu. Paket uretimi muayeneyi TAMAMLAMAYI DUSURMEZ:
            //   e-Nabiz bir bildirim yoludur, klinik kaydin sarti degil.
            var paketler = new List<object>();
            try
            {
                foreach (var kod in new[] { "MUAYENE", "HASTA_CIKIS" })
                {
                    var s = await enabiz.UretAsync(kod, id, baglam.KullaniciId, iptal);
                    if (s is not null)
                        paketler.Add(new { kod, s.PaketNo, s.Durum, s.Eksikler });
                }
            }
            catch (Exception h)
            {
                ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                   .CreateLogger("enabiz").LogError(h,
                       "e-Nabiz paketi uretilemedi (muayene {Id})", id);
            }

            // UYARILAR: ENGEL DEGIL, cunku ikisi de HEKIMIN ELINDE DEGIL.
            //
            // · Bekleyen istem: sonuc gelmeden kapanan muayenede tetkik
            //   sahipsiz kalir - ama sonucu bekletmek hekimin isi degil.
            // · SYS takip numarasi: 103/106 paketleri onu TASIMAK ZORUNDA
            //   (USS "E1004 SYSTakipNo bos olamaz" der) ve numara hasta
            //   kaydinin (101) USS'ye GONDERILMESIYLE gelir. Gonderim ayri
            //   bir is; muayeneyi kilitlemek, klinik kaydi e-Nabiz kuyruguna
            //   bagimli yapardi. Paketler uretilir, numara gelince
            //   gonderilir - hekim yalnizca BILIR.
            var uyarilar = new List<string>();
            if (m.BekleyenIstem > 0)
                uyarilar.Add($"{m.BekleyenIstem} istem hala sonuc bekliyor.");
            if (m.Takip.Length == 0)
                uyarilar.Add("Hasta kaydi (101) henuz e-Nabiz'a gonderilmemis - "
                           + "muayene ve cikis paketleri takip numarasi gelene kadar "
                           + "kuyrukta bekler.");
            var uyari = uyarilar.Count > 0 ? string.Join(" ", uyarilar) : null;
            return Results.Ok(new { id, m.BelgeId, uyari, paketler,
                                    mesaj = "Muayene tamamlandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/sablon/{sablonId} - şablonu muayeneye uygula
        //   Şablon alanları bulgu satırı olarak AÇILIR ve hepsi "normal"
        //   işaretlenir. Hekimin işi böylece "hepsini yaz" değil "sapanı
        //   düzelt" olur - poliklinikte fark buradadır.
        //   Var olan bulgular KORUNUR: şablon değiştirmek yazılmış bulguyu
        //   silmemeli.
        grup.MapPost("/{id:int}/sablon/{sablonId:int}", async (
            int id, int sablonId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var varMi = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.muayene where id = @p0", islem, [id], iptal);
            if (varMi == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            var acilan = await baglanti.CalistirAsync("""
                insert into public.muayene_bulgu (muayene_id, sablon_alan_id, normal)
                select @p0, a.id, 1
                  from public.muayene_sablon_alan a
                 where a.sablon_id = @p1
                on conflict (muayene_id, sablon_alan_id) do nothing
                """, islem, [id, sablonId], iptal);

            await baglanti.CalistirAsync("""
                update public.muayene
                   set sablon_id = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, sablonId, baglam.KullaniciId], iptal);

            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, sablonId, acilan, bulguOzet = ozet,
                                    mesaj = $"{acilan} alan sablondan acildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/sekme-verisi - mockup'taki e-Reçete, Sevk /
        //   Konsültasyon, İşlem & Ücret ve Geçmiş sekmelerinin verisi.
        //
        //   TEK UÇ: dördü de aynı muayenenin çevresindeki kayıtlar ve hepsi
        //   sekme değiştikçe ayrı ayrı istenirse kart açılışı dört ek gidiş
        //   dönüş yapar. Yetki muayene üzerinden çözülür; her sorgu ya
        //   muayenenin kendisine ya da başvurusuna bağlıdır.
        grup.MapGet("/{id:int}/sekme-verisi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var m = await baglanti.TekAsync(
                "select m.belge_id, m.taraf_id, m.ust_muayene_id " +
                "  from public.muayene m where m.id = @p0",
                null, [id],
                o => new { BelgeId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0),
                           HastaId = o.GetInt32(1),
                           UstId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadi.");

            // e-REÇETE: reçete başlıkları + satırları. İlaç adı satırda SAKLI
            //   (ilaç kataloğu değişse bile yazılan ilaç değişmemeli).
            var receteler = await baglanti.ListeAsync(
                "select r.id, r.recete_no as \"receteNo\", r.tur, r.durum, " +
                "       r.aciklama, r.imza_zamani as \"imzaZamani\", " +
                "       r.medula_gonderim as \"medulaGonderim\", " +
                "       r.medula_sonuc as \"medulaSonuc\", r.ekleme_tarihi as \"tarih\", " +
                "       coalesce(p.ad, '') as hekim, " +
                "       (select count(*) from public.recete_satir s where s.recete_id = r.id) as ilac " +
                "  from public.recete r " +
                "  left join public.v_personel_lookup p on p.id = r.hekim_id " +
                " where r.muayene_id = @p0 order by r.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var receteSatirlari = await baglanti.ListeAsync(
                "select s.recete_id as \"receteId\", s.ilac_barkod as \"barkod\", " +
                "       s.ilac_ad as \"ilac\", s.doz, s.periyot, s.kullanim_sekli as \"kullanim\", " +
                "       s.sure_gun as \"sureGun\", s.kutu, s.aciklama, " +
                "       s.etkilesim_uyari as \"uyari\" " +
                "  from public.recete_satir s " +
                "  join public.recete r on r.id = s.recete_id " +
                " where r.muayene_id = @p0 order by s.recete_id desc, s.sira, s.id",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KONSÜLTASYON: bu muayeneden İSTENEN muayeneler (ust_muayene_id)
            //   ve varsa bu muayeneyi İSTEYEN muayene.
            var konsultasyonlar = await baglanti.ListeAsync(
                "select k.id, coalesce(d.ad, '') as bolum, coalesce(p.ad, '') as hekim, " +
                "       k.muayene_tarihi as tarih, k.durum, " +
                // SORU isteyen hekimin cumlesi, YANIT cevaplayanin karari:
                //   ikisi de alt muayenede durur (465) - yaniti "sonuc geldi
                //   mi" diye ayri bir yerde aramak gerekmesin.
                "       coalesce(k.konsultasyon_soru, '') as soru, " +
                "       coalesce(nullif(k.karar, ''), '') as yanit, " +
                "       k.tamamlanma as \"yanitZamani\", " +
                "       coalesce((select i.ad from public.tani t " +
                "                   join public.icd i on i.kod = t.icd_kod " +
                "                  where t.muayene_id = k.id and t.tur = 1 limit 1), '') as \"anaTani\" " +
                "  from public.muayene k " +
                "  left join public.v_departman_lookup d on d.id = k.bolum_id " +
                "  left join public.v_personel_lookup p on p.id = k.personel_id " +
                " where k.ust_muayene_id = @p0 order by k.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // İŞLEM & ÜCRET: başvuru belgesinin satırları - muayene, tetkik ve
            //   işlemlerin ücreti başvuruda toplanır (tahakkuk oradan çıkar).
            var islemler = m.BelgeId is null
                ? new List<IDictionary<string, object>>()
                : await baglanti.ListeAsync(
                    "select bs.id, coalesce(h.kod, '') as kod, " +
                    "       coalesce(h.ad, coalesce(st.ad, '')) as ad, " +
                    "       bs.adet, bs.birim_fiyat as \"birimFiyat\", bs.iskonto, " +
                    "       bs.tutar, bs.kdv, " +
                    "       bs.aciklama " +
                    "  from public.belge_satir bs " +
                    "  left join public.hizmet h on h.id = bs.hizmet_id " +
                    "  left join public.stok st on st.id = bs.stok_id " +
                    " where bs.belge_id = @p0 order by bs.sira, bs.id",
                    null, [m.BelgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // GEÇMİŞ: aynı hastanın diğer muayeneleri (en yeni önce).
            var gecmis = await baglanti.ListeAsync(
                "select g.id, g.muayene_tarihi as tarih, coalesce(d.ad, '') as bolum, " +
                "       coalesce(p.ad, '') as hekim, g.durum, " +
                "       coalesce(nullif(g.sikayet, ''), '') as sikayet, " +
                // OZET: hekimin KARARI (yoksa sikayet). Mockup "DM kontrolu;
                //   HbA1c 7,4; doz artirildi" - bir satirda o muayenenin ne
                //   oldugunu soyleyen metin.
                "       coalesce(nullif(g.karar, ''), nullif(g.sikayet, ''), '') as ozet, " +
                // TANILAR: tum ICD kodlari (ana tani once) - "E11.9 · I10".
                "       coalesce((select string_agg(t2.icd_kod, ' · ' order by t2.tur, t2.sira, t2.id) " +
                "                   from public.tani t2 where t2.muayene_id = g.id), '') as tanilar, " +
                "       coalesce((select i.ad from public.tani t " +
                "                   join public.icd i on i.kod = t.icd_kod " +
                "                  where t.muayene_id = g.id and t.tur = 1 limit 1), '') as \"anaTani\" " +
                "  from public.muayene g " +
                "  left join public.v_departman_lookup d on d.id = g.bolum_id " +
                "  left join public.v_personel_lookup p on p.id = g.personel_id " +
                " where g.taraf_id = @p1 and g.id <> @p0 " +
                " order by g.muayene_tarihi desc, g.id desc limit 50",
                null, [id, m.HastaId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // RECETENIN TANISI muayenenin tanisidir (mockup e-Recete basligi):
            //   ayri sorulacak bir sey degil - ana tani once.
            var tanilar = await baglanti.TekDegerAsync<string>(
                "select coalesce(string_agg(t.icd_kod, ' · ' order by t.tur, t.sira, t.id), '') " +
                "  from public.tani t where t.muayene_id = @p0", null, [id], iptal);

            return Results.Ok(new { muayeneId = id, belgeId = m.BelgeId,
                                    ustMuayeneId = m.UstId, tanilar,
                                    receteler, receteSatirlari, konsultasyonlar,
                                    islemler, gecmis, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/onceki-kopyala/{kaynakId}
        //   Mockup Geçmiş panelindeki "↺ kopyala": kronik hastanın önceki
        //   muayenesinden anamnez ve tanılar bu muayeneye taşınır.
        //
        //   BOŞ ALAN DOLDURULUR, YAZILAN EZİLMEZ: hekim şikâyeti yazdıktan
        //   sonra kopyalarsa kendi cümlesini kaybetmemeli. Tanılarda aynı ICD
        //   zaten varsa atlanır; ana tanı varken gelenler EK tanı olur.
        //
        //   FİZİK MUAYENE VE VİTAL KOPYALANMAZ: onlar O GÜNÜN ölçümüdür;
        //   geçen muayenenin bulgusunu bugüne yazmak kayıt uydurmaktır.
        grup.MapPost("/{id:int}/onceki-kopyala/{kaynakId:int}", async (
            int id, int kaynakId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            if (id == kaynakId)
                throw GentegreHatasi.Dogrulama("Muayene kendinden kopyalanamaz.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AYNI HASTA ŞARTI: başka hastanın anamnezini bu karta taşımak
            //   hasta karıştırmanın en sessiz yoludur.
            var ayniHasta = await baglanti.TekDegerAsync<int>(
                "select case when (select taraf_id from public.muayene where id = @p0) " +
                "          = (select taraf_id from public.muayene where id = @p1) " +
                "       then 1 else 0 end", islem, [id, kaynakId], iptal);
            if (ayniHasta != 1)
                throw GentegreHatasi.IsKurali("Kaynak muayene bu hastaya ait degil.");

            await baglanti.CalistirAsync(
                "update public.muayene m " +
                "   set sikayet = case when coalesce(trim(m.sikayet), '') = '' " +
                "                      then k.sikayet else m.sikayet end, " +
                "       hikaye = case when coalesce(trim(m.hikaye), '') = '' " +
                "                     then k.hikaye else m.hikaye end, " +
                "       ozgecmis_notu = case when coalesce(trim(m.ozgecmis_notu), '') = '' " +
                "                            then k.ozgecmis_notu else m.ozgecmis_notu end, " +
                "       soygecmis_notu = case when coalesce(trim(m.soygecmis_notu), '') = '' " +
                "                             then k.soygecmis_notu else m.soygecmis_notu end, " +
                "       aliskanlik_notu = case when coalesce(trim(m.aliskanlik_notu), '') = '' " +
                "                              then k.aliskanlik_notu else m.aliskanlik_notu end, " +
                "       degistiren = @p2, degistirme_tarihi = now() " +
                "  from public.muayene k " +
                " where m.id = @p0 and k.id = @p1",
                islem, [id, kaynakId, baglam.KullaniciId], iptal);

            var anaVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and tur = 1",
                islem, [id], iptal);

            var taniEklenen = await baglanti.CalistirAsync(
                "insert into public.tani (muayene_id, icd_kod, tur, kesinlik, kronik, " +
                "                         not_metni, ekleyen) " +
                "select @p0, t.icd_kod, " +
                "       case when @p2 > 0 then 2 else t.tur end, " +
                "       t.kesinlik, t.kronik, t.not_metni, @p3 " +
                "  from public.tani t " +
                " where t.muayene_id = @p1 " +
                "   and not exists (select 1 from public.tani v " +
                "                    where v.muayene_id = @p0 and v.icd_kod = t.icd_kod) " +
                " order by t.tur, t.sira, t.id",
                islem, [id, kaynakId, anaVar, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, kaynakId, taniEklenen,
                                    mesaj = $"Onceki muayeneden anamnez kopyalandi"
                                          + (taniEklenen > 0 ? $", {taniEklenen} tani eklendi." : "."),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/raporlar - kartın raporları (imza seçimi için)
        grup.MapGet("/{id:int}/raporlar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync(
                "select r.id, r.tur, r.alt_tur as \"altTur\", r.baslangic, r.bitis, r.gun, " +
                "       r.icd_kod as \"icdKod\", r.aciklama, r.durum, " +
                "       r.imza_zamani as \"imzaZamani\" " +
                "  from public.muayene_rapor r where r.muayene_id = @p0 " +
                " order by r.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { id, raporlar = satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/rapor/{raporId}/imzala
        //   İMZA RAPORU KİLİTLER: imzalanan metin SGK'ya giden metindir.
        //   EKSİK RAPOR İMZALANMAZ: tür, başlangıç, gün ve tanı olmadan
        //   rapor Medula'da reddedilir - hatayı imza anında söylemek, günler
        //   sonra "rapor geçersiz" yanıtı almaktan iyidir.
        grup.MapPost("/rapor/{raporId:int}/imzala", async (
            int raporId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var r = await baglanti.TekAsync(
                "select durum, coalesce(tur, 0), baslangic, coalesce(gun, 0), " +
                "       coalesce(icd_kod, '') " +
                "  from public.muayene_rapor where id = @p0 for update",
                islem, [raporId],
                o => new { Durum = o.GetInt16(0), Tur = o.GetInt16(1),
                           Baslangic = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                           Gun = o.GetInt16(3), Icd = o.GetString(4) }, iptal);
            if (r is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Rapor bulunamadi." } });
            if (r.Durum != 1)
                throw GentegreHatasi.IsKurali("Rapor zaten imzalanmis ya da iptal.");

            var eksik = new List<string>();
            if (r.Tur == 0) eksik.Add("tür");
            if (r.Baslangic is null) eksik.Add("başlangıç tarihi");
            if (r.Gun <= 0) eksik.Add("süre (gün)");
            if (r.Icd.Trim().Length == 0) eksik.Add("tanı (ICD-10)");
            if (eksik.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Rapor imzalanamaz - eksik: " + string.Join(", ", eksik) + ".");

            await baglanti.CalistirAsync(
                "update public.muayene_rapor " +
                "   set durum = 2, imza_zamani = now(), imzalayan = @p1, " +
                "       degistiren = @p1, degistirme_tarihi = now() " +
                " where id = @p0", islem, [raporId, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { raporId, mesaj = "Rapor imzalandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/tanilar - kartın tanı satırları (araç
        //   çubuğundaki "sil" için: hangi satırın kaldırılacağı SUNUCUDAN
        //   gelen listeden seçilir, ekranın elindeki taslaktan değil).
        grup.MapGet("/{id:int}/tanilar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync(
                "select t.id, t.icd_kod, coalesce(i.ad, '') as ad, t.tur " +
                "  from public.tani t " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where t.muayene_id = @p0 " +
                " order by t.tur asc, t.sira asc, t.id asc",
                null, [id],
                o => new { id = o.GetInt32(0), kod = o.GetString(1),
                           ad = o.GetString(2), tur = o.GetInt16(3) }, iptal);

            return Results.Ok(new { id, tanilar = satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/muayene/{id}/tani/{taniId} - tanı satırını kaldır
        //   Kart üzerinden de silinebilir; araç çubuğundaki sil AYNI ucu
        //   kullanır ki silme izi (log) tek yoldan geçsin.
        grup.MapDelete("/{id:int}/tani/{taniId:int}", async (
            int id, int taniId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var silinen = await baglanti.CalistirAsync(
                "delete from public.tani where id = @p0 and muayene_id = @p1",
                null, [taniId, id], iptal);
            if (silinen == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Tani satiri bulunamadi." } });

            return Results.Ok(new { id, taniId, mesaj = "Tani kaldirildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/tani-onerileri - mockup "⭐ Sık kullandıklarım"
        //   ve "🕘 Önceki tanılar" listeleri.
        //
        //   ÖNCEKİ: bu HASTANIN başka muayenelerinde yazılmış tanılar. Kronik
        //   hastada tanı her muayenede yeniden yazılıyordu; kod aramak yerine
        //   listeden seçmek hem hızlı hem de kodun aynı kalmasını sağlıyor
        //   (aynı hastalık iki ayrı ICD ile yazılınca rapor ikiye bölünür).
        //   SIK: bu HEKİMİN son 90 günde en çok yazdığı kodlar - poliklinikte
        //   tanı dağılımı dardır, ilk beş kod işin çoğunu görür.
        grup.MapGet("/{id:int}/tani-onerileri", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var onceki = await baglanti.ListeAsync(
                "select t.icd_kod, coalesce(i.ad, '') as ad, max(t.kronik) as kronik, " +
                "       max(m.muayene_tarihi)::date::text as son " +
                "  from public.tani t " +
                "  join public.muayene m on m.id = t.muayene_id " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where m.taraf_id = (select taraf_id from public.muayene where id = @p0) " +
                "   and m.id <> @p0 " +
                " group by t.icd_kod, i.ad " +
                " order by max(m.muayene_tarihi) desc limit 20",
                null, [id],
                o => new { kod = o.GetString(0), ad = o.GetString(1),
                           kronik = o.GetInt32(2), son = o.GetString(3) }, iptal);

            var sik = await baglanti.ListeAsync(
                "select t.icd_kod, coalesce(i.ad, '') as ad, count(*)::int as adet " +
                "  from public.tani t " +
                "  join public.muayene m on m.id = t.muayene_id " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where m.personel_id = (select personel_id from public.muayene where id = @p0) " +
                "   and m.muayene_tarihi >= now() - interval '90 days' " +
                " group by t.icd_kod, i.ad " +
                " order by count(*) desc, max(m.muayene_tarihi) desc limit 15",
                null, [id],
                o => new { kod = o.GetString(0), ad = o.GetString(1), adet = o.GetInt32(2) }, iptal);

            return Results.Ok(new { id, onceki, sik, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/tani/{icdKod} - listeden seçilen tanıyı ekle
        //   Ana tanı ZATEN VARSA yeni satır EK tanı olur: ana tanıyı sessizce
        //   değiştirmek, tamamlama ve e-Nabız 103 paketinin dayandığı kaydı
        //   hekime sormadan oynatmak demekti.
        grup.MapPost("/{id:int}/tani/{icdKod}", async (
            int id, string icdKod, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var kodVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.icd where kod = @p0", islem, [icdKod], iptal);
            if (kodVar == 0)
                throw GentegreHatasi.Dogrulama($"ICD kodu bulunamadi: {icdKod}");

            var zaten = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and icd_kod = @p1",
                islem, [id, icdKod], iptal);
            if (zaten > 0)
                return Results.Ok(new { id, icdKod, eklendi = false,
                                        mesaj = "Bu tani zaten listede.",
                                        izlemeNo = baglam.IzlemeNo });

            var anaVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and tur = 1",
                islem, [id], iptal);

            await baglanti.CalistirAsync(
                "insert into public.tani (muayene_id, icd_kod, tur, kesinlik, ekleyen) " +
                "values (@p0, @p1, @p2, 1, @p3)",
                islem, [id, icdKod, anaVar > 0 ? 2 : 1, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, icdKod, eklendi = true,
                                    mesaj = anaVar > 0 ? "Ek tani eklendi." : "Ana tani eklendi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/tumu-normal - açık bulgu satırlarını "normal"
        //   işaretle (mockup muayene_karti.html "Tümü normal işaretle").
        //   Hekim yalnızca SAPANI yazar; normalleri tek tek işaretlemek
        //   poliklinikte en çok tekrarlanan tıklamaydı.
        //   BULGU METNİ YAZILMIŞ SATIRA DOKUNULMAZ: "normal" demek yazılmış
        //   patolojik bulguyu geçersiz kılardı - orası hekimin kararı.
        grup.MapPost("/{id:int}/tumu-normal", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var varMi = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.muayene where id = @p0", islem, [id], iptal);
            if (varMi == 0) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            var isaretlenen = await baglanti.CalistirAsync(
                "update public.muayene_bulgu set normal = 1 " +
                " where muayene_id = @p0 and coalesce(normal, 0) = 0 " +
                "   and coalesce(trim(deger_metin), '') = ''",
                islem, [id], iptal);

            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, isaretlenen, bulguOzet = ozet,
                                    mesaj = isaretlenen == 0
                                        ? "Isaretlenecek bos bulgu satiri yok."
                                        : $"{isaretlenen} sistem normal isaretlendi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/ozet-derle - bulgulardan metin üret
        //   Rapora ve e-Nabız 103'e giden metin BUDUR. Hekim üzerine yazabilir;
        //   derleme metni EZER çünkü çağıran zaten "bulgulardan yeniden üret"
        //   demektedir.
        grup.MapPost("/{id:int}/ozet-derle", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var ozet = await OzetDerleAsync(baglanti, islem, id, iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, bulguOzet = ozet, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/istem - muayeneden istem aç
        //   Asıl kayıt MODÜL TABLOSUNDA açılır (radyoloji_istem); muayene_istem
        //   bağ ve durum satırıdır. Modülü atlayıp yalnız bağ satırı yazmak,
        //   radyolojinin çalışma listesinde görünmeyen bir istem üretirdi.
        grup.MapPost("/{id:int}/istem", async (
            int id, IstemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.LabServisi lab, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.taraf_id, m.belge_id, m.personel_id, m.sube_id, m.durum,
                       coalesce((select t.icd_kod from public.tani t
                                  where t.muayene_id = m.id and t.tur = 1 limit 1), '')
                  from public.muayene m where m.id = @p0
                """, islem, [id], o => new
                {
                    HastaId = o.GetInt32(0),
                    BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    HekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    SubeId = o.GetInt32(3), Durum = o.GetInt16(4), OnTani = o.GetString(5),
                }, iptal);

            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Tamamlanmis muayeneye istem eklenemez.");

            string hedefTablo = "";
            int? hedefId = null;

            // GORUNTULEME: radyoloji istemi acilir. On tani ve klinik bilgi
            //   BIRLIKTE gider - radyolog "neden cekiyoruz" bilmeden rapor
            //   yazamaz.
            if (istek.Tur == 2)
            {
                if (istek.HizmetId is not > 0)
                    throw GentegreHatasi.Dogrulama("Goruntuleme istemi icin hizmet secilmeli.",
                        [new("hizmetId", "Tetkik (hizmet) secin.")]);

                // HIZMET RADYOLOJI TETKIKI OLMALI (459). Kart ekraninda tetkik
                //   listesi zaten radyolojiyle sinirli; ACIK KAPI BURASIYDI -
                //   muayeneden gonderilen hizmet id serbestti ve laboratuvar
                //   tetkiki ("17-KETOSTEROİD") radyoloji kuyruguna dusuyordu.
                //   Modalite = tetkikin cihaz ailesi; sifirsa istem hicbir
                //   cihaza gonderilemez (MWL "hangi cihaz" sorusunu cevapsiz
                //   birakir). Ayni kural DB tetiginde de var - bu kontrol
                //   kullaniciya ANLASILIR mesaj vermek icin.
                var modalite = await baglanti.TekDegerAsync<int>(
                    "select coalesce(modalite, 0) from public.hizmet where id = @p0",
                    islem, [istek.HizmetId], iptal);
                if (modalite <= 0)
                    throw GentegreHatasi.Dogrulama(
                        "Secilen tetkik radyoloji tetkiki degil (hizmet kartinda modalite yok).",
                        [new("hizmetId", "Radyoloji tetkiki secin ya da hizmet kartina "
                                         + "modalite girin.")]);

                hedefId = await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_istem
                           (sube_id, belge_id, hasta_id, hizmet_id, modalite, durum, oncelik,
                            istek_hekim_id, on_tani, klinik_bilgi, aciklama, accession_no)
                    values (@p0, @p1, @p2, @p3, @p8, 1, @p4, @p5, @p6, @p7, @p7,
                            public.fn_numara_kimlik_uret(903, @p0, 'radyoloji_istem',
                                                         'accession_no', current_date))
                    returning id
                    """, islem,
                    [m.SubeId, m.BelgeId, m.HastaId, istek.HizmetId,
                     (short)(istek.Aciliyet ?? 1), m.HekimId, m.OnTani,
                     istek.Aciklama ?? "", istek.Aciklama ?? "", (short)modalite], iptal);
                hedefTablo = "radyoloji_istem";
            }

            // LABORATUVAR (433): asil kayit lab_istem'de acilir; tup plani ve
            //   barkodlar orada uretilir. Muayeneden istenen tetkigin numune
            //   plani olmadan acilmasi, kan alma biriminde "hangi tup" sorusunu
            //   cevapsiz birakirdi.
            if (istek.Tur == 1)
            {
                if (m.BelgeId is not > 0)
                    throw GentegreHatasi.IsKurali(
                        "Laboratuvar istemi icin muayenenin basvurusu olmali.");

                var satirlar = new List<Servisler.LabServisi.IstemSatiriIstegi>();
                foreach (var t in istek.TetkikIdler ?? [])
                    satirlar.Add(new(t, null));
                foreach (var p in istek.PanelIdler ?? [])
                    satirlar.Add(new(null, p));
                if (satirlar.Count == 0)
                    throw GentegreHatasi.Dogrulama("Laboratuvar istemi icin tetkik secilmeli.",
                        [new("tetkikIdler", "En az bir tetkik ya da panel secin.")]);

                // Lab istemi KENDI islemini acar; bag satiri onun ardindan
                //   yazilir - lab istemi acilamazsa bag satiri da olusmaz.
                await islem.CommitAsync(iptal);
                hedefId = await lab.IstemAcAsync(m.BelgeId.Value, satirlar,
                    (short)(istek.Aciliyet ?? 1), istek.Aciklama ?? "", m.OnTani,
                    baglam, iptal);
                hedefTablo = "lab_istem";

                var bagId = await veri.TekDegerAsync<int>("""
                    insert into public.muayene_istem
                           (muayene_id, tur, hedef_tablo, hedef_id, aciliyet,
                            sonuc_durum, ekleyen)
                    values (@p0, 1, 'lab_istem', @p1, @p2, 0, @p3)
                    returning id
                    """,
                    [id, hedefId, (short)(istek.Aciliyet ?? 0), baglam.KullaniciId], iptal);

                return Results.Ok(new { istemId = bagId, hedefTablo, hedefId,
                                        mesaj = "Laboratuvar istemi acildi, barkodlar uretildi.",
                                        izlemeNo = baglam.IzlemeNo });
            }

            var istemId = await baglanti.TekDegerAsync<int>("""
                insert into public.muayene_istem
                       (muayene_id, tur, hedef_tablo, hedef_id, aciliyet, sonuc_durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 0, @p5)
                returning id
                """, islem,
                [id, (short)istek.Tur, hedefTablo, hedefId, (short)(istek.Aciliyet ?? 0),
                 baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // Muayene durumu (sonuc bekliyor) TETIKLE yansiyor (418): modul
            //   kodlarina "muayene_istem'i de guncelle" satiri eklemek, birini
            //   unutunca sessizce bozulan bir bag birakirdi.
            return Results.Ok(new { istemId, hedefTablo, hedefId,
                                    mesaj = hedefTablo.Length > 0
                                        ? "Istem acildi ve modul calisma listesine dustu."
                                        : "Istem kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/istem/{id}/gordu - hekim sonucu gördü
        //   Panik değer teyidi ve "sonuç bekliyor" rozetinin kapanması bunun
        //   üzerinden yürür: sonucun gelmesi ile hekimin görmesi ayrı olaylar.
        grup.MapPost("/istem/{id:int}/gordu", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            var zaman = await veri.TekDegerAsync<DateTime?>("""
                update public.muayene_istem
                   set hekim_gordu = coalesce(hekim_gordu, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning hekim_gordu
                """, [id, baglam.KullaniciId], iptal);

            if (zaman is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Istem bulunamadi." } });

            return Results.Ok(new { id, hekimGordu = zaman, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/sira/cagir - "Sıradakini Çağır" / seçili hastayı çağır
        //   Sıra kuralı SQL'de (fn_siradaki_hasta): önce öncelik, sonra kayıt
        //   sırası. İstemcinin sırayı hesaplaması, iki hekimin aynı anda
        //   basmasında aynı hastayı iki kez çağırmak olurdu.
        grup.MapPost("/sira/cagir", async (
            CagirIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var belgeId = istek?.BelgeId ?? 0;
            if (belgeId == 0)
            {
                var hekim = istek?.HekimId ?? 0;
                if (hekim == 0)
                    throw GentegreHatasi.Dogrulama("Hekim secilmeli.",
                        [new("hekimId", "Siradakini cagirmak icin hekim gerekli.")]);

                belgeId = await baglanti.TekDegerAsync<int>(
                    "select coalesce(public.fn_siradaki_hasta(@p0, @p1), 0)",
                    islem, [hekim, baglam.SubeId], iptal);
                if (belgeId == 0)
                    return Results.Ok(new { belgeId = 0, mesaj = "Bekleyen hasta yok.",
                                            izlemeNo = baglam.IzlemeNo });
            }

            // Cagirma zamani IKINCI TIKTA EZILMEZ: bekleme suresi olcusu
            //   cagirma anindan hesaplaniyor, tekrar cagirmak onu bozmamali.
            //   Tekrar cagirma yine de anons icin gecerli bir istektir.
            var kayit = await baglanti.TekAsync("""
                update public.belge_basvuru bb
                   set cagirma_zamani = coalesce(bb.cagirma_zamani, now()),
                       cagiran_id = coalesce(bb.cagiran_id, @p1),
                       degistiren = @p1, degistirme_tarihi = now()
                 where bb.id = @p0
                returning bb.cagirma_zamani, bb.sira_no,
                          (select t.unvan from public.belge b
                             join public.taraf t on t.id = b.taraf_id where b.id = bb.id)
                """, islem, [belgeId, baglam.KullaniciId], o => new
                {
                    Zaman = o.GetDateTime(0), SiraNo = o.GetString(1),
                    Hasta = o.IsDBNull(2) ? "" : o.GetString(2),
                }, iptal);

            if (kayit is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Basvuru bulunamadi." } });

            await islem.CommitAsync(iptal);

            // Bekleme ekraninda KISALTILMIS ad gosterilir (KVKK): salonda
            //   herkesin duydugu bir listede tam ad okunmamali.
            return Results.Ok(new { belgeId, kayit.SiraNo, cagirma = kayit.Zaman,
                                    hasta = kayit.Hasta, ekranAdi = AdiKisalt(kayit.Hasta),
                                    mesaj = $"{kayit.Hasta} cagrildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/basvuru/{belgeId}/al - "Muayeneye Al"
        //   Muayene kaydi YOKSA ACILIR: hekim once "muayene ekle" deyip sonra
        //   hastayi secmek zorunda kalmasin - kart basvurudan turer.
        grup.MapPost("/basvuru/{belgeId:int}/al", async (
            int belgeId, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.taraf_id, bb.personel_id, bb.bolum_id, b.sube_id,
                       (select m.id from public.muayene m
                         where m.belge_id = b.id and m.ust_muayene_id is null)
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0 and b.tur = 19
                 for update of b
                """, islem, [belgeId], o => new
                {
                    TarafId = o.GetInt32(0),
                    PersonelId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    BolumId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    SubeId = o.GetInt32(3),
                    MuayeneId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                }, iptal);

            if (b is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Basvuru bulunamadi." } });

            // MUAYENE NO AYARDAN (634): `numara_sablonu` tur 902 satiri varsa
            //   numara verilir, yoksa BOS kalir - bugunku davranis. Kolon
            //   bastan beri vardi ama hic doldurulmuyordu; numarasi olmayan
            //   bir alana kendiliginden numara basmak, kurumun istemedigi bir
            //   kimligi kayitlara yazmak olurdu.
            var muayeneId = b.MuayeneId ?? await baglanti.TekDegerAsync<int>("""
                insert into public.muayene (belge_id, taraf_id, sube_id, bolum_id, personel_id,
                                            muayene_tarihi, tur, durum, ekleyen, muayene_no)
                values (@p0, @p1, @p2, @p3, @p4, now(), 1, 1, @p5,
                        public.fn_numara_kimlik_uret(902, @p2, 'muayene', 'muayene_no', current_date))
                returning id
                """, islem, [belgeId, b.TarafId, b.SubeId, b.BolumId, b.PersonelId,
                             baglam.KullaniciId], iptal);

            // Cagirilmadan "Muayeneye Al" denirse cagirma zamani da yazilir:
            //   hasta zaten iceride, bekleme suresi o an bitmistir.
            await baglanti.CalistirAsync("""
                update public.belge_basvuru
                   set cagirma_zamani = coalesce(cagirma_zamani, now()),
                       cagiran_id = coalesce(cagiran_id, @p1)
                 where id = @p0
                """, islem, [belgeId, baglam.KullaniciId], iptal);

            var baslangic = await baglanti.TekDegerAsync<DateTime>("""
                update public.muayene
                   set baslangic = coalesce(baslangic, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning baslangic
                """, islem, [muayeneId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // e-NABIZ 101 HASTA KAYIT: kabul paketi. Basvuru acilirken degil
            //   MUAYENEYE ALINIRKEN uretilir - kayit kabulde hekim/klinik
            //   henuz kesin degil, paket eksik alanla acilirdi.
            try { await enabiz.UretAsync("HASTA_KABUL", belgeId, baglam.KullaniciId, iptal); }
            catch (Exception h)
            {
                ctx.RequestServices.GetRequiredService<ILoggerFactory>()
                   .CreateLogger("enabiz").LogError(h,
                       "e-Nabiz 101 paketi uretilemedi (basvuru {Id})", belgeId);
            }

            return Results.Ok(new { belgeId, muayeneId, baslangic,
                                    yeni = b.MuayeneId is null,
                                    mesaj = $"Muayeneye alindi ({baslangic:HH:mm}).",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }


    /// <summary>
    /// Bulgulardan MUAYENE ÖZETİ metnini derler ve karta yazar.
    ///
    /// Kural: alan "normal" işaretliyse şablonun hazır cümlesi, değilse
    /// hekimin yazdığı metin. Sistem başlığı (grup) satırın önüne düşer -
    /// rapor okunurken hangi sistemin anlatıldığı belli olsun.
    ///
    /// Boş bırakılan ve normal işaretlenmemiş alan metne HİÇ GİRMEZ: "Batın:"
    /// diye boş bir satır, muayene edilmediğini değil özensizliği gösterirdi.
    /// </summary>
    private static async Task<string> OzetDerleAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction islem, int muayeneId, CancellationToken iptal)
    {
        var satirlar = await baglanti.ListeAsync("""
            select coalesce(nullif(a.grup, ''), a.ad) as baslik,
                   case when b.normal = 1 and a.normal_metni <> '' then a.normal_metni
                        else coalesce(nullif(btrim(b.deger_metin), ''),
                                      case when b.deger_sayi is null then ''
                                           else b.deger_sayi::text || ' ' || a.birim end) end,
                   case b.taraf when 1 then 'Sag' when 2 then 'Sol'
                                when 3 then 'Bilateral' else '' end
              from public.muayene_bulgu b
              join public.muayene_sablon_alan a on a.id = b.sablon_alan_id
             where b.muayene_id = @p0
             order by a.sira asc, a.id asc
            """, islem, [muayeneId],
            o => (Baslik: o.GetString(0), Deger: o.GetString(1), Taraf: o.GetString(2)),
            iptal);

        var metin = string.Join("\n", satirlar
            .Where(x => x.Deger.Trim().Length > 0)
            .Select(x => x.Taraf.Length > 0
                ? $"{x.Baslik} ({x.Taraf}): {x.Deger}"
                : $"{x.Baslik}: {x.Deger}"));

        await baglanti.CalistirAsync(
            "update public.muayene set bulgu_ozet = @p1 where id = @p0",
            islem, [muayeneId, metin], iptal);
        return metin;
    }

    /// <summary>
    /// Muayeneden açılan istem.
    ///
    /// <c>Tur</c>: 1 lab · 2 görüntüleme · 3 konsültasyon · 4 işlem · 5 dış tetkik.
    /// Görüntülemede <c>HizmetId</c> zorunlu - radyoloji istemi hizmetsiz açılamaz.
    /// </summary>
    public sealed record IstemIstegi(int Tur, int? HizmetId, int? Aciliyet, string? Aciklama,
                                     int[]? TetkikIdler, int[]? PanelIdler);

    /// <summary>İstek gövdesi: belge verilmezse hekimin SIRADAKİ hastası çağrılır.</summary>
    public sealed record CagirIstegi(int? BelgeId, int? HekimId);

    /// <summary>
    /// Bekleme ekranı için adı kısaltır: "Ayşe Yılmaz" → "A. Y***".
    ///
    /// Salonda herkesin gördüğü bir ekranda tam ad okunmamalı; çağrılan kişi
    /// kendini tanısın yeter.
    /// </summary>
    private static string AdiKisalt(string ad)
    {
        var parcalar = (ad ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries);
        if (parcalar.Length == 0) return "";
        var bas = string.Join(" ", parcalar[..^1].Select(x => x[..1] + "."));
        var son = parcalar[^1];
        return (bas.Length > 0 ? bas + " " : "") + son[..1] + new string('*', Math.Min(3, son.Length));
    }
}
