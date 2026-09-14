using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

public static class BelgeUclari
{
    public static void BelgeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/belge").WithTags("Belge").RequireAuthorization();

        // POST /api/belge - yeni belge (sozlesme §4)
        grup.MapPost("/", async (
            BelgeYazmaIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);

            var belge = BaslikDegerleri(istek.Belge);
            BelgeTarihiSaatle(belge);
            var satirlar = istek.Satirlar ?? new List<Dictionary<string, JsonElement>>();
            UygunlukZorlamaYetkisi(baglam, satirlar);

            var (id, uyarilar) = await depo.KaydetAsync(belge, satirlar, istek.Secenekler,
                baglam.Yazma, iptal);

            await ctx.RequestServices
                     .GetRequiredService<Servisler.EnabizTetikleyici>()
                     .BasvuruKaydedildiAsync(id, baglam.KullaniciId, iptal);

            // UCRETLENDIRILMIS TETKIK ICIN ISTEM ACILIR (kullanici): tetkik
            //   ucret satiri olarak giriliyor, istem ayri bir adimdi ve
            //   atlanınca tetkik laboratuvara hic dusmuyordu - hastadan para
            //   alinmis, tup istenmemis oluyordu. Zaten istemi olan tetkik
            //   ikinci kez istenmez.
            await ctx.RequestServices
                     .GetRequiredService<Servisler.LabServisi>()
                     .BasvurudanIstemTamamlaAsync(id, baglam, iptal);

            var kayit = await depo.OkuAsync(id, iptal)
                        ?? throw GentegreHatasi.Bulunamadi();

            return Results.Created($"/api/belge/{id}", new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------- basvuru suzgecleri ----
        // GET /api/belge/basvuru-suzgec?bas=&bit=
        //
        // Basvuru listesi seridindeki Odeyen / Bolum / Doktor combolarini
        // doldurur. Kullanici: "bu filtrelere o tarih araligindaki yer alan
        // item'lar gelsin" - secenekler tanim tablolarindan degil, ARALIKTAKI
        // BASVURULARDAN uretilir, boylece secilince bos liste veren secenek
        // gorunmez. Tarih uclari bossa sinir yoktur.
        //
        // Bolum/doktor ada cozen kolonlarla AYNI kuralla okunur: once belgenin
        // kendi basvuru satiri, yoksa belgeye bagli randevu.
        // ---------------------------------------------- basvuru combolari
        // BASVURU EKRANININ SECENEK LISTELERI TEK UCTAN (kullanici: "banko
        //   gorevlisi olarak girdim... odeyen kurum listesi gelmedi combo").
        //
        // Ekran bu listeleri KART KAYNAKLARINDAN cekiyordu (/api/liste/kurum,
        //   departman, depo) ve her biri KENDI kaynak yetkisini istiyor. Banko
        //   rolunde "kurum" / "depo" gor yetkisi yok - liste 403 donuyor, kart
        //   da hatayi yutup combo'yu BOS birakiyordu: gorevli basvuruyu
        //   acamiyor, sebebini de goremiyordu.
        //
        // COMBO DOLDURMAK KART YETKISI DEGILDIR: basvuru acabilen kisi odeyen
        //   kurumu secebilmeli. Uc yalniz KIMLIK + AD dondurur (kartin ic
        //   bilgisi degil) ve `belge` gor yetkisiyle calisir.
        grup.MapGet("/basvuru-kaynaklari", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // ODEYEN KURUMLAR: anlasmali kurumlar (taraf.kurum = 1), tum
            //   cariler degil. `tur` ekranda rotayi belirler (Özel/SGK/ÖSS).
            var kurumlar = await baglanti.ListeAsync("""
                select t.id, t.unvan as ad, coalesce(k.tur, 0) as tur
                  from public.taraf t
                  left join public.taraf_kurum k on k.id = t.id
                 where t.kurum = 1 and t.durum = 1
                 order by t.unvan
                """, null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1), tur = o.GetInt32(2) },
                iptal);

            // BOLUMLER: randevu verilebilen birimler - randevu ekraniyla ayni
            //   kume. Alt birim onekini ("— Dahiliye") ekran kirpiyordu;
            //   burada ham ad doner.
            var bolumler = await baglanti.ListeAsync("""
                select d.id, d.ad
                  from public.departman d
                 where d.durum = 1 and d.randevu_verilebilir = 1
                 order by d.ad
                """, null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            // DEPOLAR: aktif depolar, AKTIF SUBENIN - baska subenin deposuna
            //   cikis yapilamaz (sube 0 = tum subeler icin ortak depo).
            var depolar = await baglanti.ListeAsync("""
                select d.id, d.ad
                  from public.depo d
                 where d.durum = 1
                   and (@p0 = 0 or coalesce(d.sube_id, 0) in (0, @p0))
                 order by d.ad
                """, null, [baglam.SubeId ?? 0],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            // FIYAT LISTELERI: belgenin YONUNDEKI aktif listeler. Bu combo da
            //   `fiyat_listesi` gor yetkisi istiyordu - banko rolunde liste
            //   bostu ve basvuru kesilemiyordu. Liste SECMEK belgenin adimi;
            //   listeyi YONETMEK ayri yetkidir.
            var fiyatListeleri = await baglanti.ListeAsync("""
                select f.id, f.ad, f.yon, coalesce(f.tarife_tipi, 0) as tarife_tipi
                  from public.fiyat_listesi f
                 where f.durum = 1
                 order by f.ad
                """, null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1),
                           yon = (int)o.GetInt16(2), tarifeTipi = (int)o.GetInt16(3) }, iptal);

            return Results.Ok(new { kurumlar, bolumler, depolar, fiyatListeleri,
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/basvuru-suzgec", async (
            DateTime? bas, DateTime? bit, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);


            // Basvuru = tur 19 + tipi 30 (liste tanimindaki sabit filtrenin ayni).
            //   Ad cozumu her sorguda KENDI join'i ile: ortak bir FROM parcasi
            //   uc farkli tabloya (kurum / departman / hekim) baglanamaz.
            //   Ust sinir gun SONUNA kadar kapsar (< bit + 1): belge_tarihi
            //   saat de tasir, `<= bit` o gunun ogleden sonrasini disarida
            //   birakirdi.
            const string suz = """
                 where b.tur = 19 and b.tipi = 30
                   and (@p0::date is null or b.belge_tarihi >= @p0::date)
                   and (@p1::date is null or b.belge_tarihi < @p1::date + 1)
                """;

            var odeyenler = await baglanti.ListeAsync($"""
                select bb.odeyen_kurum_id as id, min(ok.unvan) as ad, count(*) as adet
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                  join public.taraf ok on ok.id = bb.odeyen_kurum_id
                {suz}
                 group by bb.odeyen_kurum_id
                 order by min(ok.unvan)
                """, null, [bas, bit], OkuyucuGenisletmeleri.Sozluk, iptal);

            var bolumler = await baglanti.ListeAsync($"""
                select x.bolum_id as id, min(d.ad) as ad, count(*) as adet
                  from (select coalesce(bb.bolum_id, r.bolum) as bolum_id
                          from public.belge b
                          left join public.belge_basvuru bb on bb.id = b.id
                          left join lateral (select r.bolum from public.randevu r
                                              where r.belge_id = b.id
                                              order by r.id limit 1) r on true
                        {suz}) x
                  join public.departman d on d.id = x.bolum_id
                 group by x.bolum_id
                 order by min(d.ad)
                """, null, [bas, bit], OkuyucuGenisletmeleri.Sozluk, iptal);

            var doktorlar = await baglanti.ListeAsync($"""
                select x.hekim_id as id, min(hk.unvan) as ad, count(*) as adet
                  from (select coalesce(bb.personel_id, r.hekim_id) as hekim_id
                          from public.belge b
                          left join public.belge_basvuru bb on bb.id = b.id
                          left join lateral (select r.hekim_id from public.randevu r
                                              where r.belge_id = b.id
                                              order by r.id limit 1) r on true
                        {suz}) x
                  join public.taraf hk on hk.id = x.hekim_id
                 group by x.hekim_id
                 order by min(hk.unvan)
                """, null, [bas, bit], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { odeyenler, bolumler, doktorlar });
        });

        // GET /api/belge/{id}
        grup.MapGet("/{id:int}", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();

            // Hareket kaynagi: baska subenin belgesi gosterilmez (API §8).
            if (baglam.SubeId is not null &&
                kayit.Belge.TryGetValue("subeId", out var belgeSube) && belgeSube is not null &&
                Convert.ToInt32(belgeSube) != baglam.SubeId.Value)
                throw GentegreHatasi.Bulunamadi();

            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/acik-satirlar - donusturulmeyi bekleyen satirlar
        grup.MapGet("/{id:int}/acik-satirlar", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(new
            {
                satirlar = await depo.AcikSatirlarAsync(id, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // PUT /api/belge/{id} - kayitli belgeyi duzenler (135). Kilit kurallari
        //   depoda: e-Belge gonderilmis / faturalanmis / duzenleme suresi gecmis.
        grup.MapPut("/{id:int}", async (
            int id, BelgeYazmaIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var belge = BaslikDegerleri(istek.Belge);
            var satirlar = istek.Satirlar ?? new List<Dictionary<string, JsonElement>>();
            UygunlukZorlamaYetkisi(baglam, satirlar);

            var (belgeId, uyarilar) = await depo.GuncelleAsync(id, belge, satirlar,
                istek.Secenekler, baglam.Yazma,
                iptal);

            // GUNCELLEMEDE DE (602): basvurunun bolumu/kurumu sonradan
            //   girilmis olabilir - paket o an tamamlanir. "Ayni icerik ->
            //   ayni paket" kurali mukerrer satir acmaz.
            await ctx.RequestServices
                     .GetRequiredService<Servisler.EnabizTetikleyici>()
                     .BasvuruKaydedildiAsync(belgeId, baglam.KullaniciId, iptal);

            // Guncellemede de: sonradan eklenen tetkik icin istem acilir.
            await ctx.RequestServices
                     .GetRequiredService<Servisler.LabServisi>()
                     .BasvurudanIstemTamamlaAsync(belgeId, baglam, iptal);

            var kayit = await depo.OkuAsync(belgeId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo,
            });
        });

        // GET /api/belge/iade-satirlari - iade faturasinda "onceki alinanlar" (132).
        //   Cari zorunlu: iade her zaman BIR CARIYE kesilir, tum firmanin gecmisi
        //   listelenmez. belgeId verilirse yalniz o belgeden iade edilir.
        grup.MapGet("/iade-satirlari", async (
            int tarafId, int? belgeId, string? ara, string? turler,
            BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            // turler: "14,119" gibi virgullu liste - iade IRSALIYESI yalniz
            //   irsaliye satirlarini, iade FATURASI fatura satirlarini gorsun.
            var turDizi = (turler ?? "")
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Select(x => int.TryParse(x, out var n) ? n : 0)
                .Where(x => x > 0).ToArray();
            return Results.Ok(new
            {
                satirlar = await depo.IadeSatirlariAsync(tarafId, belgeId, ara, turDizi, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/dagit - satirlarin ODEME DAGILIMINI tazele (472).
        //   Kural SUNUCUDA: rota sozlesmeden, fiyatlar SUT/TTB listelerinden.
        //   Istemci yalnizca "yeniden hesapla" der; provizyon tutari verirse
        //   liste fiyati yerine ONAYLANAN gecer.
        grup.MapPost("/{id:int}/dagit", async (
            int id, DagitIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var satirlar = await veri.ListeAsync(
                "select id from public.belge_satir where belge_id = @p0 order by sira, id",
                [id], o => o.GetInt32(0), iptal);
            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali("Belgede satır yok.");

            // ELLE sabitlenmis dagilima fonksiyon zaten dokunmaz; burada da
            //   ayrica sorgulamaya gerek yok - tek kural tek yerde.
            var prov = istek?.SgkProvizyon?
                .Where(x => x.SatirId > 0).ToDictionary(x => x.SatirId, x => x) ?? [];

            foreach (var satirId in satirlar)
            {
                prov.TryGetValue(satirId, out var p);
                await veri.CalistirAsync(
                    // Katki (6. parametre) BURADA GECILMEZ: provizyon
                    //   tazelemesi hasta katilim payini degistirmez - elle
                    //   girilmisse bayragiyla korunur (586).
                    "select public.fn_belge_satir_dagilim_tazele(@p0, @p1, @p2, @p3, @p4, null)",
                    [satirId, p?.Tutar, istek?.OssProvizyon,
                     p?.SgkListe, p?.HuvListe], iptal);
                if (p?.ProvizyonNo is { Length: > 0 } no)
                    await veri.CalistirAsync(
                        "update public.belge_satir_dagilim " +
                        "   set sgk_provizyon_no = @p1, sgk_provizyon_durum = 1, " +
                        "       degistirme_tarihi = now() " +
                        " where belge_satir_id = @p0", [satirId, no], iptal);
            }

            // Rota 3/5'te satir tutari kovalardan yeniden dogar: belge dip
            //   toplami da tazelenmeli, yoksa baslik eski tutari gosterir.
            await veri.CalistirAsync("select public.fn_belge_diptoplam(@p0)", [id], iptal);

            return Results.Ok(new { id, satir = satirlar.Count,
                mesaj = $"{satirlar.Count} satırın ödeme dağılımı yenilendi.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/belge/dagilim-onizleme - KAYDEDILMEMIS satirin dagilimi.
        //
        // Kullanici: "kaydetmeden ucret satirinin sagindaki + detay butonu
        //   gelmiyor, oysa ben ekledigimde hemen detay ne diye gormek
        //   istiyorum." Kovalar `belge_satir_dagilim`de yasiyor ve ancak
        //   kayitla doguyordu; gride yeni eklenen satirda dagilim yoktu.
        //
        // HESAP AYNI YERDE (594): uc, saf `fn_dagilim_coz`u cagiran
        //   `fn_dagilim_onizle`ye gider - kayitli satirin gectigi fonksiyonun
        //   ta kendisi. Bu yuzden onizlemede gorulen rakam, kaydedince
        //   degismez. Hicbir sey YAZILMAZ.
        grup.MapPost("/dagilim-onizleme", async (
            DagilimOnizlemeIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            var satirlar = istek?.Satirlar ?? [];
            if (satirlar.Count == 0)
                return Results.Ok(new { satirlar = Array.Empty<object>(), izlemeNo = baglam.IzlemeNo });

            var sonuc = new List<object>(satirlar.Count);
            await using var baglanti = await veri.AcAsync(iptal);

            foreach (var r in satirlar)
            {
                await using var komut = baglanti.Komut("""
                    select rota, tutar, sgk, oss, hasta_provizyon, hasta_ek_katki,
                           sgk_katilim_payi, sgk_liste, huv_liste
                      from public.fn_dagilim_onizle(@p0, @p1, @p2, @p3, @p4, @p5, @p6,
                                                    @p7, @p8, @p9, @p10, @p11, @p12, @p13)
                    """, null,
                    istek!.OdeyenKurumId, istek.SozlesmeId is 0 ? null : istek.SozlesmeId,
                    istek.AltKurum, (short)(istek.SgkKullan ?? 1), (short)(istek.Emekli ?? 0),
                    r.StokId is 0 ? null : r.StokId, r.HizmetId is 0 ? null : r.HizmetId,
                    r.Miktar, r.Tutar, (short)r.Kdv, r.Iskonto ?? 0m, r.Iskonto2 ?? 0m,
                    r.SgkListe, r.KatkiTutar);

                await using var o = await komut.ExecuteReaderAsync(iptal);
                if (!await o.ReadAsync(iptal)) continue;

                sonuc.Add(new
                {
                    anahtar = r.Anahtar,
                    rota = (int)o.GetInt16(0),
                    tutar = o.GetDecimal(1),
                    sgk = o.GetDecimal(2),
                    oss = o.GetDecimal(3),
                    hastaProvizyon = o.GetDecimal(4),
                    hastaEkKatki = o.GetDecimal(5),
                    sgkKatilimPayi = o.GetDecimal(6),
                    sgkListe = o.GetDecimal(7),
                    huvListe = o.GetDecimal(8),
                });
            }

            return Results.Ok(new { satirlar = sonuc, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/kurum/{id}/sozlesmeler - basvuru kartinin sozlesme secicisi.
        //   YETKI `belge` GOR (kullanici: banko rolunde odeyen kurum/sozlesme
        //   combolari bostu): sozlesme secmek basvurunun bir adimi, cari
        //   kartini yonetmek degil. `cari` gor istemek, banko gorevlisine
        //   musteri kartlarini acmak pahasina calisan bir ekran demekti.
        yol.MapGet("/api/kurum/{id:int}/sozlesmeler", async (
            int id, DateOnly? tarih, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            var gun = tarih ?? DateOnly.FromDateTime(DateTime.Now);
            var satirlar = await veri.ListeAsync("""
                select s.id, s.ad, s.alt_kurum, s.sozlesme_no, s.durum,
                       coalesce(d.ad, '') as alt_kurum_adi,
                       s.fiyat_listesi_id, s.sgk_fiyat_listesi_id, s.sgk_kurum_id,
                       s.varsayilan_karsilama, k.tur,
                       public.fn_dagilim_rota(k.tur, s.alt_kurum, 1::smallint) as rota
                  from public.kurum_sozlesme s
                  join public.taraf_kurum k on k.id = s.kurum_id
                  left join public.kod_deger d
                         on d.deger = s.alt_kurum and d.dil = 0
                        and d.liste_id = (select l.id from public.kod_liste l
                                           where l.kod = 'kurum.alt_kurum')
                 where s.kurum_id = @p0 and s.durum = 1
                   and (s.baslangic is null or s.baslangic <= @p1)
                   and (s.bitis is null or s.bitis >= @p1)
                 order by s.alt_kurum, s.id
                """, [id, gun],
                o => new { id = o.GetInt32(0), ad = o.GetString(1),
                           altKurum = o.GetInt16(2), sozlesmeNo = o.GetString(3),
                           durum = o.GetInt16(4), altKurumAdi = o.GetString(5),
                           fiyatListesiId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
                           sgkFiyatListesiId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                           sgkKurumId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                           varsayilanKarsilama = o.GetDecimal(9),
                           tur = o.GetInt16(10), rota = o.GetInt16(11) }, iptal);

            return Results.Ok(new { kurumId = id, sozlesmeler = satirlar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/belge/{id}/rezerve - siparis satirlarini depoda ayir (142)
        grup.MapPost("/{id:int}/rezerve", async (
            int id, RezerveIstegi? istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Rezervasyon stok/cari YAZMAZ, yalniz "soz verildi" isareti koyar:
            //   belgeyi degistirme yetkisi yeterli.
            baglam.YetkiIste("belge", Islem.Degistir);

            var ac = istek?.Ac ?? true;
            var adet = await depo.RezerveAsync(id, ac,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = new[] { ac ? $"{adet} satır rezerve edildi." : "Rezervasyon kaldırıldı." },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // DELETE /api/belge/{id} - belgeyi sil (181). Kesin/izli belgede
        //   IPTAL kullanilir; on-kosullar veritabaninda (fn_belge_silinebilir),
        //   arayuz ve uc AYNI cevabi alsin diye.
        grup.MapDelete("/{id:int}", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Sil);

            var mesaj = await depo.SilAsync(id,
                baglam.Yazma, iptal);
            return Results.Ok(new { mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/belge/{id}/ebelge-hazirla - belgeyi e-Belge kuyruguna al (163)
        grup.MapPost("/{id:int}/ebelge-hazirla", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, EBelgeSorgu sorgu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            // MUKELLEFIYETI TAZELE (185): e-Fatura mi e-Arsiv mi karari buna
            //   bagli. Sorgu gerekmiyorsa (taze bilgi) ag turu atilmaz.
            await sorgu.MukellefiyetTazeleAsync(id, baglam.KullaniciId, iptal);

            var (eBelgeId, tur, no, seri, uyari) = await depo.EBelgeHazirlaAsync(id,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            var turAdi = tur switch { 1 => "e-Fatura", 2 => "e-Arşiv", 7 => "e-İrsaliye", _ => "e-Belge" };
            var mesajlar = new List<string> { $"{turAdi} hazırlandı — {seri} / {no} (kayıt #{eBelgeId})." };
            if (!string.IsNullOrWhiteSpace(uyari)) mesajlar.Add(uyari);

            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = mesajlar,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/ebelge-onizle - onizleme HTML'i (178).
        //   Gonderim GEREKMEZ: kullanici "ne gidecek" sorusunu gondermeden
        //   gormek istiyor. Resmi goruntu entegratordeki XSLT ile uretilir.
        grup.MapGet("/{id:int}/ebelge-onizle", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var html = await depo.EBelgeHtmlAsync(id, iptal);
            return Results.Ok(new { html, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/belge/ebelge-toplu - secili belgeleri toplu hazirla/gonder (183).
        //   SINIR 100 KAYIT: gonderim belge basina saniyeler suruyor; sinirsiz
        //   liste istegi zaman asimina dusurur ve yarim kalan is belirsiz olur.
        grup.MapPost("/ebelge-toplu", async (
            TopluIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            EBelgeGonderimi gonderim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var idler = (istek?.Belgeler ?? Array.Empty<int>()).Distinct().ToList();
            if (idler.Count == 0)
                throw GentegreHatasi.Dogrulama("Belge seçilmemiş.");
            if (idler.Count > 100)
                throw GentegreHatasi.IsKurali(
                    $"En fazla 100 belge işlenebilir (seçilen: {idler.Count}).");

            var yazma = baglam.Yazma;

            if (string.Equals(istek!.Islem, "hazirla", StringComparison.OrdinalIgnoreCase))
            {
                var sonuc = await depo.EBelgeTopluHazirlaAsync(idler, yazma, iptal);
                return Results.Ok(new { sonuclar = sonuc, izlemeNo = baglam.IzlemeNo });
            }

            if (string.Equals(istek.Islem, "gonder", StringComparison.OrdinalIgnoreCase))
            {
                // Gonderim HTTP: tek tek, sirayla. Paralel gondermek entegratorde
                //   hiz sinirina takiliyor ve hangi belgenin hangi hatayi aldigi
                //   karisiyor.
                var sonuc = new List<BelgeDeposu.TopluSonuc>();
                foreach (var id in idler)
                {
                    try
                    {
                        var g = await gonderim.GonderAsync(id, baglam.KullaniciId, null, iptal);
                        sonuc.Add(new BelgeDeposu.TopluSonuc(id, true, g.BelgeNo, g.Mesaj));
                    }
                    catch (GentegreHatasi h)
                    {
                        sonuc.Add(new BelgeDeposu.TopluSonuc(id, false, "", h.Message));
                    }
                }
                return Results.Ok(new { sonuclar = sonuc, izlemeNo = baglam.IzlemeNo });
            }

            throw GentegreHatasi.Dogrulama($"Bilinmeyen toplu işlem: {istek.Islem}");
        });

        // POST /api/belge/{id}/ebelge-durum - GIB durumunu entegratorden cek.
        //   Gonderimden sonra durum kendiliginden degismiyordu; "gonderdim, ne
        //   oldu?" sorusunun cevabi buradan gelir.
        grup.MapPost("/{id:int}/ebelge-durum", async (
            int id, BaglamCozucu cozucu, EBelgeSorgu sorgu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var d = await sorgu.DurumSorgulaAsync(id, baglam.KullaniciId, iptal);
            return Results.Ok(new { d.BelgeNo, d.Kod, d.Aciklama, d.Degisti,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/belge/{id}/ebelge-alici - gonderimden once alici adresi (184).
        //   e-ARSIVDE alias alani ALICI E-POSTASIDIR: bos ise arayuz sorar,
        //   varsayilan olarak carinin e-postasi onerilir (Delphi ile ayni akis).
        grup.MapGet("/{id:int}/ebelge-alici", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var a = await depo.EBelgeAliciAsync(id, iptal);
            return Results.Ok(new { a.BelgeTuru, a.Alias, a.OnerilenMail, a.TarafUnvan,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/belge/{id}/ebelge-ubl - UBL-XML + goruntuleme XSLT'si (182).
        //   "XML Kaydet" ve XSLT'li on izleme bunu kullanir.
        grup.MapGet("/{id:int}/ebelge-ubl", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var (ubl, xslt, ad) = await depo.EBelgeUblAsync(id, iptal);
            return Results.Ok(new { ubl, xslt, dosyaAdi = ad, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/belge/{id}/ebelge-govde - gonderilecek/gonderilen GOVDE.
        //   "XML Kaydet" bunu kullanir: izibiz JSON tabanli calistigi icin
        //   elimizdeki resmi icerik gonderim govdesidir (UBL'i entegrator kurar).
        grup.MapGet("/{id:int}/ebelge-govde", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var (bicim, govde, ad) = await depo.EBelgeGovdeAsync(id, iptal);
            return Results.Ok(new { bicim, govde, dosyaAdi = ad, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/belge/{id}/ebelge-mesajlar - hazirlama/gonderim/GIB gecmisi (178).
        grup.MapGet("/{id:int}/ebelge-mesajlar", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(new { mesajlar = await depo.EBelgeMesajlarAsync(id, iptal),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/belge/{id}/ebelge-gonder - hazirlanmis belgeyi entegratore yolla
        //   Yetki: DEGISTIR yetmez - gonderim GERI ALINAMAZ (GIB'e giden belge
        //   iptal edilmez, yalniz iade faturasiyla duzeltilir).
        grup.MapPost("/{id:int}/ebelge-gonder", async (
            int id, GonderimIstegi? istek, BaglamCozucu cozucu, BelgeDeposu depo,
            EBelgeGonderimi gonderim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var sonuc = await gonderim.GonderAsync(id, baglam.KullaniciId,
                                                   istek?.AliciAlias, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            var mesajlar = new List<string>
            {
                $"Gönderildi — {sonuc.BelgeNo} ({sonuc.Entegrator}, HTTP {sonuc.HttpKodu}). {sonuc.Mesaj}"
            };
            if (!string.IsNullOrWhiteSpace(sonuc.Uuid)) mesajlar.Add($"UUID: {sonuc.Uuid}");

            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge, Satirlar = kayit.Satirlar, DipToplam = kayit.DipToplam,
                Uyarilar = mesajlar, IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/ebelge-sifirla - hazirlanmis e-Belgeyi geri al (164)
        grup.MapPost("/{id:int}/ebelge-sifirla", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var mesaj = await depo.EBelgeSifirlaAsync(id,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge, Satirlar = kayit.Satirlar, DipToplam = kayit.DipToplam,
                Uyarilar = new[] { mesaj }, IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/ebelge-seri - baska seriye tasi (164)
        grup.MapPost("/{id:int}/ebelge-seri", async (
            int id, EBelgeSeriIstegi? istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            var (no, seri) = await depo.EBelgeSeriDegistirAsync(id, istek?.Seri,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge, Satirlar = kayit.Satirlar, DipToplam = kayit.DipToplam,
                Uyarilar = new[] { $"Seri {seri} olarak değişti — yeni numara {no}." },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/termin - satirlarin teslim tarihini guncelle (140)
        grup.MapPost("/{id:int}/termin", async (
            int id, TerminIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Termin degisikligi tutar/stok/cari etkilemez: belgeyi DEGISTIRME
            //   yetkisi yeterli, ayri bir aksiyon istenmiyor.
            baglam.YetkiIste("belge", Islem.Degistir);

            var secilen = (istek?.Satirlar ?? new List<TerminSatiri>())
                .Where(s => s.SatirId > 0)
                .Select(s => (s.SatirId, s.TeslimTarihi))
                .ToList();

            var adet = await depo.TerminGuncelleAsync(id, secilen,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = new[] { $"{adet} satırın teslim tarihi güncellendi." },
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // POST /api/belge/{id}/donustur - siparis -> irsaliye -> fatura
        grup.MapPost("/{id:int}/donustur", async (
            int id, DonusumIstegi istek, BaglamCozucu cozucu, BelgeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Ekle);
            baglam.AksiyonIste("belge.donustur");

            if (istek is null || istek.HedefTur <= 0)
                throw GentegreHatasi.Dogrulama("Hedef belge türü seçilmeli.",
                    new AlanHatasi("hedefTur", "Zorunlu."));

            var secilen = (istek.Satirlar ?? new List<DonusumSatiri>())
                .Where(s => s.SatirId > 0 && (s.Miktar > 0 || (s.Tutar ?? 0) > 0))
                .Select(s => (s.SatirId, s.Miktar, s.Tutar, s.TutarKdvli))
                .ToList();

            var (yeniId, uyarilar) = await depo.DonusturAsync(id, istek.HedefTur, secilen,
                istek.BelgeTarihi, istek.Taslak,
                baglam.Yazma, iptal,
                istek.BelgeNo, (short)(istek.Pay ?? 0));

            // KALANI TAHAKKUKA CEVIR (352): "300'u fis, 700'u tahakkuk" tek
            //   tiklamayla. Ilk donusum bitince ayni satirlarin acik kalan
            //   HASTA payi satis tahakkukuna (17) cevrilir. Ikinci adim ayri
            //   transaction'dir: basarisiz olursa ilk belge durur, kullanici
            //   uyariyla gorur ve kalanı elle donusturur.
            if (istek.KalaniTahakkuk && istek.HedefTur != 17)
            {
                var secilenIdler = secilen.Select(s => s.SatirId).ToHashSet();
                var kalanlar = (await depo.AcikSatirlarAsync(id, iptal))
                    .Where(s => secilenIdler.Contains(Convert.ToInt32(s["satirId"]))
                                && Convert.ToDecimal(s["hastaKalan"] ?? 0m) > 0)
                    .Select(s => (Convert.ToInt32(s["satirId"]),
                                  Convert.ToDecimal(s["kalanMiktar"] ?? 0m),
                                  (decimal?)Convert.ToDecimal(s["hastaKalan"] ?? 0m),
                                  // Kalan TAHAKKUKA giderken brut secimi yok:
                                  //   hedef zaten "Dahil" belge, matrahtan turer.
                                  (decimal?)null))
                    .ToList();
                if (kalanlar.Count > 0)
                {
                    try
                    {
                        var (tahakkukId, _) = await depo.DonusturAsync(id, 17, kalanlar,
                            istek.BelgeTarihi, istek.Taslak, baglam.Yazma, iptal, null, 1);
                        uyarilar.Add($"Kalan tutar satış tahakkukuna çevrildi (belge {tahakkukId}).");
                    }
                    catch (GentegreHatasi h)
                    {
                        uyarilar.Add($"Kalan tutar tahakkuka çevrilemedi: {h.Message}");
                    }
                }
            }

            var kayit = await depo.OkuAsync(yeniId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Created($"/api/belge/{yeniId}", new BelgeYaniti
            {
                Belge = kayit.Belge,
                Satirlar = kayit.Satirlar,
                DipToplam = kayit.DipToplam,
                Uyarilar = uyarilar,
                IzlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/donusumler - bu belgeden turetilmis belgeler
        grup.MapGet("/{id:int}/donusumler", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(new
            {
                belgeler = await depo.DonusumlerAsync(id, iptal),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // GET /api/belge/{id}/diptoplam - ekranin alt toplam seridi
        grup.MapGet("/{id:int}/diptoplam", async (
            int id, BaglamCozucu cozucu, BelgeDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { dipToplam = kayit.DipToplam, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Siparis/irsaliye donusum istegi (F8). Miktar KISMI olabilir.</summary>
    public sealed class DonusumIstegi
    {
        public int HedefTur { get; set; }
        public List<DonusumSatiri>? Satirlar { get; set; }
        public DateTime? BelgeTarihi { get; set; }
        public bool Taslak { get; set; }

        /// <summary>Alis faturasinda TEDARIKCININ numarasi - sayac uretmez.</summary>
        public string? BelgeNo { get; set; }

        /// <summary>
        /// ODEME PAYLASIMI (289): 0/bos tum satir · 1 yalniz HASTA payi ·
        /// 2 yalniz KURUM payi. Kurum payinda hedef belgenin carisi odeyen
        /// kurumdur - fatura sigortaya/SGK'ya kesilir.
        /// </summary>
        public int? Pay { get; set; }

        /// <summary>
        /// TUTAR BAZLI donusumde (352) ilk belge kesildikten sonra satirlarin
        /// acik kalan hasta payini satis tahakkukuna (17) cevir - "tahsil
        /// edilen kadar fis, kalani tahakkuk" tek adimda.
        /// </summary>
        public bool KalaniTahakkuk { get; set; }
    }

    public sealed class DonusumSatiri
    {
        public int SatirId { get; set; }
        public decimal Miktar { get; set; }

        /// <summary>
        /// TUTAR BAZLI KISMI DONUSUM (352): verilirse satirdan miktar degil bu
        /// TUTAR (KDV haric matrah) kadar donusturulur - or. 1000 TL'lik
        /// kalemin tahsil edilen 300 TL'si satis fisine. Pay verilmemisse
        /// hasta payi (1) sayilir; kalan tutar kaynakta acik kalir.
        /// </summary>
        public decimal? Tutar { get; set; }

        /// <summary>
        /// Ayni secimin KDV DAHIL karsiligi (kullanici: "500 TL fiş girdim ama
        /// 499,99 kesti"). Verilirse hedef satirin brut fiyati BUNDAN yazilir;
        /// matrah brutten turetildigi icin girilen rakam birebir tutar.
        /// Verilmezse eski davranis: brut, kaynagin oranindan turetilir.
        /// </summary>
        public decimal? TutarKdvli { get; set; }
    }

    /// <summary>Rezervasyon istegi - 142. Ac=false rezervi kaldirir.</summary>
    /// <summary>
    /// Dağılım tazeleme isteği (472). İstemci KURAL göndermez - yalnız
    /// provizyonun ONAYLADIĞI tutarı; kovalara nasıl dağılacağını rota bilir.
    /// </summary>
    public sealed class DagitIstegi
    {
        public List<SgkProvizyonSatiri>? SgkProvizyon { get; set; }
        /// <summary>Sigortanın onayladığı tutar (satır bazlı değilse belge geneli).</summary>
        public decimal? OssProvizyon { get; set; }
    }

    public sealed class SgkProvizyonSatiri
    {
        public int SatirId { get; set; }
        public decimal? Tutar { get; set; }
        public string? ProvizyonNo { get; set; }
        /// <summary>
        /// SUT bedeli EKRANDAN (483). Sözleşmenin SUT listesinde satır yoksa
        /// SGK payı sessizce sıfır kalıyordu; kullanıcı bedeli buradan verir ve
        /// dağılımda SABİTLENİR - sonraki tazelemeler listeden gelenle ezmez.
        /// Provizyonun ONAYLADIĞI tutar (<see cref="Tutar"/>) bundan ayrıdır:
        /// o gelirse SUT bedelinin yerine geçer.
        /// </summary>
        public decimal? SgkListe { get; set; }
        /// <summary>Tarife (TTB/HUV) bedeli ekrandan (483) - liste boşsa.</summary>
        public decimal? HuvListe { get; set; }
    }

    /// <summary>
    /// Kaydedilmemiş satırların dağılım önizlemesi (594). İstemci KURAL
    /// göndermez: başvurunun kimliği (ödeyen kurum / sözleşme / alt kurum /
    /// emekli) ve satırın sayıları gider, kovaları sunucu hesaplar.
    /// </summary>
    public sealed class DagilimOnizlemeIstegi
    {
        public int OdeyenKurumId { get; set; }
        public int? SozlesmeId { get; set; }
        public int? AltKurum { get; set; }
        public int? SgkKullan { get; set; }
        public int? Emekli { get; set; }
        public List<DagilimOnizlemeSatiri> Satirlar { get; set; } = [];
    }

    public sealed class DagilimOnizlemeSatiri
    {
        /// <summary>Gridin satır anahtarı - yanıt bununla eşleşir (satır henüz ID'siz).</summary>
        public string Anahtar { get; set; } = "";
        public int? StokId { get; set; }
        public int? HizmetId { get; set; }
        public decimal Miktar { get; set; }
        /// <summary>Satır tutarı - MATRAH (kovalar KDV hariç tutulur).</summary>
        public decimal Tutar { get; set; }
        public int Kdv { get; set; }
        public decimal? Iskonto { get; set; }
        public decimal? Iskonto2 { get; set; }
        /// <summary>Ekrandan girilen SUT bedeli (matrah); yoksa listeden okunur.</summary>
        public decimal? SgkListe { get; set; }
        /// <summary>Ekrandan girilen katkı - BİRİM başına, matrah.</summary>
        public decimal? KatkiTutar { get; set; }
    }

    public sealed class RezerveIstegi
    {
        public bool Ac { get; set; } = true;
    }

    /// <summary>e-Belge seri degistirme istegi - 164. Seri bos ise siradaki kural.</summary>
    public sealed class EBelgeSeriIstegi
    {
        public string? Seri { get; set; }
    }

    /// <summary>Gonderim istegi: e-Arsivde alici e-postasi (184).</summary>
    public sealed class GonderimIstegi
    {
        public string? AliciAlias { get; set; }
    }

    /// <summary>Toplu e-Belge istegi (183): islem "hazirla" ya da "gonder".</summary>
    public sealed class TopluIstegi
    {
        public int[]? Belgeler { get; set; }
        public string Islem { get; set; } = "";
    }

    /// <summary>Termin (teslim tarihi) guncelleme istegi - 140.</summary>
    public sealed class TerminIstegi
    {
        public List<TerminSatiri>? Satirlar { get; set; }
    }

    public sealed class TerminSatiri
    {
        public int SatirId { get; set; }
        /// <summary>Bos (null) = termin kaldirildi, tarih belirsiz.</summary>
        public DateTime? TeslimTarihi { get; set; }
    }

    /// <summary>
    /// YENI belgede tarih SAATIYLE yazilir (kullanici: "başvuruda yeni
    /// ücretlendirme yaparken sipariş tarihine tarih saat mutlaka gelmeli").
    ///
    /// Tarih hic gelmediyse ya da BUGUNUN gece yarisi (00:00) olarak geldiyse
    /// (tarih-only gonderen cagrilar: randevudan basvuru, radyoloji istemi,
    /// dis sistemler) o anki saat damgalanir. Gecmis bir gunun 00:00'i ELLE
    /// secilmis kabul edilir ve dokunulmaz.
    /// </summary>
    /// <summary>
    /// CİNSİYET/YAŞ KURALINI AŞMA YETKİSİ (482).
    ///
    /// Kuralın gerçek istisnaları var (erkekte meme kanseri şüphesi, yaşı
    /// belirsiz hasta) - bu yüzden gerekçeli geçişe izin verilir. Ama gerekçe
    /// yazmak herkesin işi değil: hizmet tanımını değiştirebilen kişi kuralı
    /// aşabilir de. Gerekçe satırda kalır; kim, neden zorladı görünür.
    /// </summary>
    private static void UygunlukZorlamaYetkisi(
        IstekBaglami baglam, IEnumerable<Dictionary<string, JsonElement>> satirlar)
    {
        var zorlayan = satirlar.Any(x =>
            x.TryGetValue("uygunlukNotu", out var v)
            && v.ValueKind == JsonValueKind.String
            && !string.IsNullOrWhiteSpace(v.GetString()));
        if (zorlayan) baglam.YetkiIste("hizmet", Islem.Degistir);
    }

    private static void BelgeTarihiSaatle(Dictionary<string, object?> belge)
    {
        var simdi = DateTime.Now;
        if (!belge.TryGetValue("belgeTarihi", out var deger) || deger is null)
        {
            belge["belgeTarihi"] = simdi;
            return;
        }
        if (deger is DateTime t && t.TimeOfDay == TimeSpan.Zero && t.Date == simdi.Date)
            belge["belgeTarihi"] = simdi;
    }

    /// <summary>
    /// Baslik alanlarini dogrular ve DB degerlerine cevirir. Dongu ORTAK
    /// (BaslikDogrulayici); burada yalnizca belgeye ozgu alan tablolari var.
    /// </summary>
    private static Dictionary<string, object?> BaslikDegerleri(Dictionary<string, JsonElement>? gelen)
        => BaslikDogrulayici.Cevir(gelen, BaslikTipi, Uzunluk, "belge alani");

    private static string? BaslikTipi(string ad) => ad switch
    {
        "tur" or "tipi" or "tarafId" or "tarafAdresId" or "kocanNo" or "girisDepoId" or
        "cikisDepoId" or "subeId" or "projeId" or "vadeGun" or "durum" or "senaryo" or
        "saticiId" or "teslimSekli" or "merkezId" or "tasiyiciId" or "teslimEdenId" or
        // Belgenin fiyat listesi (205): acilista cariden cozulur, kullanici
        //   degistirirse satirlar EKRANDA yeniden fiyatlanir (BelgeKarti.listeDegisti).
        // Basvuruda (249) vade yerine ODEYEN KURUM secilir - anlasmali kurum id'si.
        // Belgeye isleyen kampanya (274): liste BAZ fiyati, kampanya INDIRIMI
        //   verir - ikisi birlikte saklanir, biri otekinin yerine gecmez.
        // Basvuru uzantisi (296): basvurulan BOLUM ve karsilayan HEKIM -
        //   belge_basvuru tablosuna yazilir (ana belgede kolonlari yok).
        "teslimAlanId" or "fiyatListesiId" or "teklifDurum" or "odeyenKurumId" or
        // SOZLESME / ALT KURUM / SGK KATKISI (469): odeme rotasinin girdileri.
        // EMEKLI (590) da buraya ait: 0/1 isaret, SGK katilim payini sifirlar.
        //   Listeye eklenmeyince kart "Bilinmeyen belge alani: emekli" ile
        //   422 doner ve BASVURU HIC KAYDEDILEMEZDI.
        "sozlesmeId" or "altKurum" or "sgkKullan" or "emekli" or
        // HASTA (658): basvurunun CARISI odeyen olabilir (dis kurum numunesi -
        //   fatura kuruma kesilir), hasta ayri kolonda durur. Yazma haritasi
        //   (BelgeDeposu.Yazma: hastaId -> hasta_id) ve okuma zaten vardi;
        //   yalniz BU listeye eklenmemisti ve kart "Bilinmeyen belge alani:
        //   hastaId" ile 422 alip ucret satiri EKLEYEMIYORDU.
        "hastaId" or
        // Basvuru sekmesi (298) - kod/sayi alanlari.
        "kampanyaId" or "bolumId" or "personelId" or "basvuruTuru" or "gelisSekli"
        or "gelisNedeni" or "oda"
        // Kendi istegiyle geldi (370) - 0/1 isaret.
        or "kendiIstegi"
        // Provizyon (299) - kod/sayi alanlari (SGK ve ozel sigorta ayri).
        or "sgkDurum" or "sgkProvizyonTipi" or "sgkTakipTuru" or "sgkMustehaklik"
        or "sgkSevkli" or "ossDurum" or "ossKurumId"
            => "sayi",

        // Provizyon oran/tutarlari (299) - iki odeyici icin ayri.
        "dovizKuru" or "sgkKarsilama" or "sgkTutar"
        or "ossKarsilama" or "ossTutar" => "para",

        // Provizyon TARIHLERI (300) elle girilebilir - MEDULA baglanana kadar
        // kayit kabul yaziyor, servis geldiginde uzerine yazacak.
        "belgeTarihi" or "irsaliyeTarihi"
        or "sgkGecerlilik" or "sgkProvizyonTarihi" or "sgkTakipTarihi"
        or "ossGecerlilik" or "ossProvizyonTarihi" => "tarih",

        "tarafUnvan" or "tarafVkno" or "tarafVd" or "tarafAdres" or "tarafIlce" or "tarafIl" or
        "belgeSeri" or "belgeNo" or "irsaliyeNo" or "kdvDurum" or "belgeDovizi" or
        "dovizCinsi" or "kur" or "raporDovizi" or "ekstreDovizi" or "aciklama" or "ozelKod" or
        // Teklif revize no (220) - serbest metin.
        "revizeNo" or "teklifKonusu" or "teklifTeslim" or
        "gondericiUnvan" or "gondericiVkno" or "gondericiAlias" or
        // Basvuru sekmesi (298) - metin alanlari.
        "aracPlaka" or "soforAd" or "soforTckn"
        or "siraNo" or "refakatci"
        // Ambulans (300) - basvuru uzantisinda.
        or "ambulansHastaNo" or "ambulansBileklikNo"
        // Provizyon (299) - metin alanlari.
        or "sgkProvizyonNo" or "sgkRedNedeni" or "sgkSigortaTuru"
        or "sgkBasvuruNo" or "sgkTakipNo"
        or "sgkTesisKodu" or "sgkSevkKurum"
        or "ossProvizyonNo" or "ossRedNedeni" or "ossPoliceNo" or "ossHasarNo" or "ossBrans"
        or "provizyonAciklama" => "metin",

        _ => null
    };

    /// <summary>Belge basligindaki metin alanlarinin DB uzunluklari.</summary>
    private static int? Uzunluk(string ad) => ad switch
    {
        "belgeSeri" or "belgeDovizi" or "kur" or "raporDovizi" or "ekstreDovizi" or "kdvDurum" => 5,
        "dovizCinsi" => 6,
        "belgeNo" or "irsaliyeNo" or "tarafVkno" => 20,
        // Provizyon/ambulans numaralari (299-300) - hepsi varchar(40).
        "sgkProvizyonNo" or "sgkBasvuruNo" or "sgkTakipNo" or "sgkTesisKodu"
        or "ossProvizyonNo" or "ossPoliceNo" or "ossHasarNo"
        or "ambulansHastaNo" or "ambulansBileklikNo" => 40,
        "tarafIlce" or "tarafIl" or "tarafVd" or "gondericiVkno" => 60,
        "ozelKod" => 20,
        "tarafUnvan" or "gondericiUnvan" => 200,
        "tarafAdres" => 300,
        "gondericiAlias" => 500,
        _ => null
    };

}
