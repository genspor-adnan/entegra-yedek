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
                         where s.muayene_id = m.id and s.sonuc_durum in (0, 1))
                  from public.muayene m where m.id = @p0 for update
                """, islem, [id], o => new
                {
                    Durum = o.GetInt16(0),
                    BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    Sikayet = o.GetString(2), Karar = o.GetString(3),
                    AnaTani = o.GetInt64(4), BekleyenIstem = o.GetInt64(5),
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

            // Bekleyen istem varsa hekim bunu BILMELI: sonuc gelmeden kapanan
            //   muayenede tetkik sahipsiz kalir. Engel degil, uyari.
            var uyari = m.BekleyenIstem > 0
                ? $"{m.BekleyenIstem} istem hala sonuc bekliyor."
                : null;
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
                    values (@p0, @p1, @p2, @p3, @p8, 1, @p4, @p5, @p6, @p7, @p7, '')
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

            var muayeneId = b.MuayeneId ?? await baglanti.TekDegerAsync<int>("""
                insert into public.muayene (belge_id, taraf_id, sube_id, bolum_id, personel_id,
                                            muayene_tarihi, tur, durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, now(), 1, 1, @p5)
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
    /// e-NABIZ KUYRUK İŞLEMLERİ (415).
    ///
    /// Paket satırını ELLE DÜZELTMEK yok: eksik kaynakta düzeltilir ve paket
    /// kaynaktan yeniden üretilir. Paketi elle düzeltmek, gönderilen veriyle
    /// kayıttaki veriyi birbirinden ayırırdı - USS'ye giden ile hastanın
    /// dosyasındaki farklı olurdu.
    /// </summary>
    public static void EnabizUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/enabiz").WithTags("e-Nabız").RequireAuthorization();

        // GET /api/enabiz/paket/{id} - PAKET KARTI (454).
        //
        // Kuyrukta "Eksik Alan" yazan satirin cevabi burada: hangi USS alani
        //   bos, hangi kaynak kolondan gelmesi gerekiyordu, kacinci denemede
        //   ne hatasi alindi. SALT OKUNUR: paket elle duzeltilmez, kaynak
        //   duzeltilip yeniden uretilir.
        grup.MapGet("/paket/{id:long}", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var paket = await baglanti.TekAsync("""
                select p.id, p.paket_no as "paketNo", t.kod as "turKod", t.ad as "turAdi",
                       t.uss_paket_kodu as "ussPaket", t.uss_surum as "ussSurum",
                       p.islem, p.kaynak_tur as "kaynakTur", p.kaynak_id as "kaynakId",
                       coalesce(h.unvan, '') as "hastaAdi", p.hasta_id as "hastaId",
                       coalesce(k.ad, '') as "hekimAdi",
                       p.olay_tarihi as "olayTarihi", p.uretim_tarihi as "uretimTarihi",
                       p.son_tarih as "sonTarih", p.planlanan, p.durum, p.deneme,
                       p.son_deneme as "sonDeneme", p.uss_paket_id as "ussPaketId",
                       p.hata_kodu as "hataKodu", p.hata_mesaj as "hataMesaj",
                       p.hata_sinifi as "hataSinifi", p.icerik_hash as "icerikHash",
                       p.onceki_paket_id as "oncekiPaketId",
                       t.zorunlu_alanlar as "zorunluAlanlar"
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                  left join public.taraf h on h.id = p.hasta_id
                  left join public.v_personel_lookup k on k.id = p.hekim_id
                 where p.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            if (paket is null)
                return Results.NotFound(new { hata = new
                    { kod = "BULUNAMADI", mesaj = "Paket bulunamadı." } });

            // ALANLAR: gecersiz olanlar USTTE - ekranin isi eksigi gostermek.
            var alanlar = await baglanti.ListeAsync("""
                select a.uss_alan as "ussAlan", a.deger, a.kaynak_alan as "kaynakAlan",
                       a.skrs_liste as "skrsListe", a.gecerli, a.sorun, a.sira
                  from public.enabiz_paket_alan a
                 where a.paket_id = @p0
                 order by a.gecerli asc, a.sira, a.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var denemeler = await baglanti.ListeAsync("""
                select g.zaman, g.ortam, g.http_kod as "httpKod", g.sonuc,
                       g.uss_kod as "ussKod", g.uss_mesaj as "ussMesaj",
                       g.sure_ms as "sureMs"
                  from public.enabiz_gonderim g
                 where g.paket_id = @p0
                 order by g.zaman desc, g.id desc
                 limit 20
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { paket, alanlar, denemeler, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/enabiz/veri-kalitesi?ay=YYYY-MM - UYUM PANOSU (454).
        //
        // Mockup: Ekranlar/E-Nabiz/enabiz_veri_kalitesi.html. Soru sunucuda
        //   cevaplanir: alti ayri istek atmak ekranin yarisini bos gosterirdi.
        grup.MapGet("/veri-kalitesi", async (
            string? ay, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            // Donem: "2026-09" -> ayin ilk gunu. Verilmezse icinde bulundugumuz ay.
            var bas = DateTime.TryParse((ay ?? "") + "-01", out var d)
                ? new DateTime(d.Year, d.Month, 1)
                : new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var son = bas.AddMonths(1);

            await using var baglanti = await veri.AcAsync(iptal);

            var sayac = await baglanti.TekAsync("""
                select count(*) as "uretilen",
                       count(*) filter (where p.durum = 3) as "gonderilen",
                       count(*) filter (where p.durum = 3 and p.deneme <= 1) as "ilkDenemede",
                       -- SURE SINIRI: paketin son_tarih'i gecmeden gonderildi mi?
                       count(*) filter (where p.durum = 3 and p.son_tarih is not null
                                          and p.son_deneme <= p.son_tarih) as "suredeGiden",
                       count(*) filter (where p.durum = 3 and p.son_tarih is not null)
                           as "sureOlculen",
                       count(*) filter (where p.durum = 4) as "hatali",
                       count(*) filter (where p.durum = 0) as "eksikAlanli",
                       count(*) filter (where p.durum in (1, 2)) as "bekleyen"
                  from public.enabiz_paket p
                 where p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                   and (@p2 = 0 or p.sube_id = @p2)
                """, null, [bas, son, baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ESLENMEMIS KOD: gecersiz alanin SKRS listesi varsa eksik olan bir
            //   kod eslemesidir - "kod eslemeye git" isaretini bu sayi verir.
            var eslemeEksik = await baglanti.ListeAsync("""
                select a.skrs_liste as "skrsListe", count(distinct a.deger) as "adet"
                  from public.enabiz_paket_alan a
                  join public.enabiz_paket p on p.id = a.paket_id
                 where a.gecerli = 0 and coalesce(a.skrs_liste, '') <> ''
                   and p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by a.skrs_liste order by 2 desc limit 10
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            var turler = await baglanti.ListeAsync("""
                select t.kod, t.ad, t.uss_paket_kodu as "ussPaket",
                       count(p.id) as "uretilen",
                       count(p.id) filter (where p.durum = 3) as "gonderilen",
                       count(p.id) filter (where p.durum = 4) as "hatali",
                       count(p.id) filter (where p.durum = 0) as "eksik"
                  from public.enabiz_paket_turu t
                  left join public.enabiz_paket p on p.paket_turu_id = t.id
                       and p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by t.id, t.kod, t.ad, t.uss_paket_kodu, t.aktif
                 order by t.aktif desc, count(p.id) desc, t.ad
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            // EN SIK HATA: kok neden burada gorunur - ayni hata yuz paketi
            //   birden dusuruyorsa duzeltilecek tek yer vardir.
            var hatalar = await baglanti.ListeAsync("""
                select coalesce(nullif(p.hata_kodu, ''), 'BILINMIYOR') as "kod",
                       max(p.hata_mesaj) as "mesaj", p.hata_sinifi as "sinif",
                       count(*) as "adet"
                  from public.enabiz_paket p
                 where p.durum = 4 and p.uretim_tarihi >= @p0 - interval '30 days'
                 group by 1, p.hata_sinifi order by count(*) desc limit 8
                """, null, [bas], OkuyucuGenisletmeleri.Sozluk, iptal);

            // ALAN BAZINDA EKSIK: "neyi duzeltirsem kac paket kurtulur".
            var eksikAlanlar = await baglanti.ListeAsync("""
                select a.uss_alan as "ussAlan", max(a.kaynak_alan) as "kaynakAlan",
                       max(a.sorun) as "sorun", count(distinct a.paket_id) as "paket"
                  from public.enabiz_paket_alan a
                  join public.enabiz_paket p on p.id = a.paket_id
                 where a.gecerli = 0 and p.durum in (0, 4)
                 group by a.uss_alan order by count(distinct a.paket_id) desc limit 10
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var hekimler = await baglanti.ListeAsync("""
                select coalesce(k.ad, '(hekimsiz)') as "hekim",
                       count(*) as "paket",
                       count(*) filter (where p.durum = 0) as "eksik",
                       count(*) filter (where p.durum = 3) as "gonderilen"
                  from public.enabiz_paket p
                  left join public.v_personel_lookup k on k.id = p.hekim_id
                 where p.uretim_tarihi >= @p0 and p.uretim_tarihi < @p1
                 group by 1 having count(*) filter (where p.durum = 0) > 0
                 order by 3 desc limit 10
                """, null, [bas, son], OkuyucuGenisletmeleri.Sozluk, iptal);

            var gunluk = await baglanti.ListeAsync("""
                -- generate_series TIMESTAMPTZ uretir; gun aritmetigi icin DATE'e
                --   cevrilir (timestamptz + integer diye bir islec yok).
                select g.gun as "gun",
                       count(p.id) as "uretilen",
                       count(p.id) filter (where p.durum = 3) as "gonderilen",
                       count(p.id) filter (where p.durum = 4) as "hatali"
                  from (select d::date as gun
                          from generate_series(current_date - 13, current_date,
                                               interval '1 day') d) g
                  left join public.enabiz_paket p
                         on p.uretim_tarihi >= g.gun and p.uretim_tarihi < g.gun + 1
                 group by g.gun order by g.gun
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                donem = bas.ToString("yyyy-MM"),
                sayac, turler, hatalar, eksikAlanlar, eslemeEksik, hekimler, gunluk,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/enabiz/paket/{id}/yeniden-uret
        grup.MapPost("/paket/{id:long}/yeniden-uret", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.EnabizPaketUretici enabiz, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var p = await veri.TekAsync("""
                select t.kod, p.kaynak_id, p.durum
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0
                """, [id],
                o => new { Kod = o.GetString(0), KaynakId = o.GetInt32(1),
                           Durum = o.GetInt16(2) }, iptal);

            if (p is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Paket bulunamadi." } });
            if (p.Durum == 3)
                throw GentegreHatasi.IsKurali(
                    "Gonderilmis paket yeniden uretilemez; duzeltme icin guncelleme paketi gerekir.");

            // ESKI PAKET IPTAL EDILIR, yenisi acilir: ayni kaynaktan iki
            //   bekleyen paket kalirsa USS'ye ayni olay iki kez giderdi.
            await veri.CalistirAsync("""
                update public.enabiz_paket set durum = 5, degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);

            var s = await enabiz.UretAsync(p.Kod, p.KaynakId, baglam.KullaniciId, iptal);
            return Results.Ok(new { eskiPaket = id, yeni = s?.PaketNo ?? "",
                                    durum = s?.Durum ?? (short)0,
                                    eksikler = s?.Eksikler ?? [],
                                    mesaj = s is null ? "Paket uretilemedi."
                                          : s.Durum == 0
                                              ? "Paket uretildi ama zorunlu alan hala eksik."
                                              : "Paket yeniden uretildi, kuyrukta.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/enabiz/paket/{id}/gonder - "Şimdi Gönder" (elle)
        //   Zamanlayıcıyı beklemeden denemek için. Hesap tanımlı değilse
        //   sonuç bunu SÖYLER; sahte başarı yok.
        grup.MapPost("/paket/{id:long}/gonder", async (
            long id, BaglamCozucu cozucu, Servisler.EnabizGonderimi gonderim,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var s = await gonderim.CalistirAsync(1, id, baglam.KullaniciId, iptal);
            return Results.Ok(new { id, s.Alinan, s.Gonderilen, s.Hatali,
                                    mesaj = s.Aciklama, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/enabiz/paket/{id}/iptal
        grup.MapPost("/paket/{id:long}/iptal", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.enabiz_paket set durum = 5, degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali(
                    "Yalniz bekleyen, eksik ya da hatali paket iptal edilebilir.");

            return Results.Ok(new { id, mesaj = "Paket iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
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
