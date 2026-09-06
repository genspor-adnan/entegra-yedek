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

                hedefId = await baglanti.TekDegerAsync<int>("""
                    insert into public.radyoloji_istem
                           (sube_id, belge_id, hasta_id, hizmet_id, durum, oncelik,
                            istek_hekim_id, on_tani, klinik_bilgi, aciklama, accession_no)
                    values (@p0, @p1, @p2, @p3, 1, @p4, @p5, @p6, @p7, @p7, '')
                    returning id
                    """, islem,
                    [m.SubeId, m.BelgeId, m.HastaId, istek.HizmetId,
                     (short)(istek.Aciliyet ?? 1), m.HekimId, m.OnTani,
                     istek.Aciklama ?? "", istek.Aciklama ?? ""], iptal);
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
