using Gentegre.Cekirdek;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Kasa (mali) islem uclari - API §9.
///
/// Yetki: kaynak "kasa_islem" + aksiyon yetkileri (kasa.kesinlestir / kasa.iptal).
/// Sube kapsami: baska subenin islemi GORUNMEZ (404 - varligi bile sizmaz).
/// </summary>
public static class KasaUclari
{
    /// <summary>islem_log.tablo_id - kasa_islem (908; KartKatalogu.Izin notu: 907 hasta, 908 kasa islemi).</summary>
    private const int LogTabloKasa = 908;

    /// <summary>
    /// TAHSILAT DAGITIMI (321): odemenin hangi belge satirina, hangi paya
    /// (1 hasta / 2 kurum) ne kadar gittigi. Otomatik = sunucu kalanlari
    /// siraya gore kapatir.
    /// </summary>
    public sealed record DagitimSatiri(int BelgeSatirId, short Pay, decimal Tutar);
    public sealed record DagitimIstegi(int? BelgeId, bool Otomatik,
                                       IReadOnlyList<DagitimSatiri>? Satirlar);

    /// <summary>
    /// AVANS MAHSUBU (322): hastanin onceden yatirdigi, henuz hicbir satira
    /// baglanmamis tahsilatin bu belgenin satirlarina dagitilmasi. Prim
    /// "tahsil edildikce" dogdugu icin mahsup edilmeyen avans primi de
    /// tetiklemez - bu yuzden ekranda gorunur olmasi gerekiyor.
    /// </summary>
    /// <param name="Tutar">
    /// KISMI MAHSUP (783, kullanici: "avans kullan dedigimde tutari sorsun,
    /// kismi kullanabileyim"): bu belgeye EN COK bu kadar avans sayilir.
    /// Verilmezse avansin tamami (eski davranis) dagitilir.
    /// </param>
    public sealed record MahsupIstegi(int BelgeId, IReadOnlyList<int>? IslemIdler,
                                      decimal? Tutar = null);

    /// <summary>
    /// AVANS MAHSUBUNU GERI AL (785, kullanici: "ücreti tekrar girip avans
    /// kullandım ama silmek istiyorum"): belgeye sayilan avans geri alinir,
    /// avansin kalani artar. Avansin KENDISI (kasa islemi) durur - para
    /// hastadan alinmisti, silinecek olan yalnizca bu belgeye sayilmasidir.
    /// </summary>
    public sealed record MahsupIptalIstegi(int BelgeId, int KasaIslemId);

    /// <summary>
    /// Bir kasa isleminin DAGITILMAMIS kismini belgenin acik satirlarina
    /// siraya gore yazar (once hasta payi - kasadan gelen para cogunlukla
    /// hastanindir, kurum payi icmalle kapanir). Mevcut dagitim satirlari
    /// KORUNUR: mahsup ekleme islemidir, yeniden yazma degil.
    /// </summary>
    private static async Task<decimal> AvansDagitAsync(NpgsqlConnection baglanti,
        LogDeposu log, IstekBaglami baglam, int kasaIslemId, int belgeId,
        CancellationToken iptal, decimal? azami = null)
    {
        var kullaniciId = baglam.KullaniciId;
        // DURUM KOŞULLU (kod inceleme 30.10.2026 K15): okuma, kilit ve yazma TEK
        //   transaction. Kasa islemi satiri `for update` ile kilitlenir - ayni
        //   avansi iki istek ayni anda mahsup etmesin; yalniz GERCEKLESMIS (2)
        //   isleme dagitim yazilir (taslak / plan / iptal para degildir).
        await using var tx = await baglanti.BeginTransactionAsync(iptal);
        var durum = await baglanti.TekDegerAsync<int?>(
            "select coalesce(k.durum, 0) from public.kasa_islem k where k.id = @p0 for update",
            tx, [kasaIslemId], iptal)
            ?? throw GentegreHatasi.Bulunamadi("Kasa işlemi bulunamadı.");
        if (durum != KasaDurum.Gerceklesti)
            throw GentegreHatasi.IsKurali("Yalnız gerçekleşmiş kasa işlemi mahsup edilir.");

        var kalanTutar = await baglanti.TekDegerAsync<decimal>("""
            select coalesce(v.dagitilmamis, 0) from public.v_kasa_islem_dagitim v
             where v.kasa_islem_id = @p0
            """, tx, [kasaIslemId], iptal);
        // KISMI MAHSUP (783): kullanicinin verdigi tutar TAVANDIR - avansta
        //   daha cok para olsa bile yalniz bu kadari bu belgeye sayilir.
        if (azami is { } tavan) kalanTutar = Math.Min(kalanTutar, tavan);
        if (kalanTutar <= 0) return 0;

        var acik = await baglanti.ListeAsync("""
            select t.satir_id as "satirId",
                   t.hasta_provizyon_kalan as "hastaProvizyonKalan",
                   t.hasta_ek_katki_kalan as "hastaEkKatkiKalan",
                   t.sgk_katilim_kalan as "sgkKatilimKalan",
                   t.oss_kalan as "ossKalan", t.sgk_kalan as "sgkKalan"
              from public.v_belge_satir_tahsilat t
             where t.belge_id = @p0
               and (t.hasta_provizyon_kalan + t.hasta_ek_katki_kalan
                  + t.sgk_katilim_kalan + t.oss_kalan + t.sgk_kalan) > 0
             order by t.sira, t.satir_id
            """, tx, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

        decimal yazilan = 0;

        // FIFO SIRASI (470) KOVA ONCELIKLI (kullanici: hastadan alinan 500 TL'nin
        //   300'u kurumun ÖSS kovasina yazilmisti): once HASTANIN odedigi
        //   kovalar - provizyon payi, ek katki, sonra SGK katilim payi
        //   (emanet); kurum kovalari (sigorta, SGK) en sonda, cunku onlar
        //   tahakkuk/faturayla kapanir, kasadan degil.
        //
        //   DIS DONGU KOVA, IC DONGU SATIR: eskiden tersiydi ve ILK SATIRIN
        //   hasta kovasi dolunca ayni satirin KURUM kovasina geciyordu -
        //   sonraki satirlarin hasta payi acik dururken hastanin verdigi para
        //   kurumun borcuna sayiliyordu.
        var kovaAlani = new (short Pay, string Alan)[]
        {
            (1, "hastaProvizyonKalan"), (4, "hastaEkKatkiKalan"),
            (5, "sgkKatilimKalan"), (3, "ossKalan"), (2, "sgkKalan"),
        };

        foreach (var (pay, alan) in kovaAlani)
        {
            if (kalanTutar <= 0) break;
            foreach (var sa in acik)
            {
                if (kalanTutar <= 0) break;
                var satirId = Convert.ToInt32(sa["satirId"]);
                var payKalan = Convert.ToDecimal(sa[alan]);
                if (payKalan <= 0) continue;
                var tutar = Math.Round(Math.Min(payKalan, kalanTutar), 2);
                if (tutar <= 0) continue;

                // Ayni islem + satir + pay icin satir varsa UZERINE EKLE:
                //   kismi mahsup ikinci kez calistirilabilir olmali.
                await baglanti.CalistirAsync("""
                    insert into public.kasa_islem_dagitim
                           (kasa_islem_id, belge_satir_id, pay, tutar, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4)
                    on conflict (kasa_islem_id, belge_satir_id, pay)
                    do update set tutar = public.kasa_islem_dagitim.tutar + excluded.tutar
                    """, tx, [kasaIslemId, satirId, pay, tutar, kullaniciId], iptal);

                kalanTutar -= tutar;
                yazilan += tutar;
            }
        }

        // BELGE BAGI YAZILMIYOR (781, kullanici: "avanstan kullan dedigimde
        //   tur AVANS olmali... bugun nakit girisi yok"): 322 burada avansin
        //   `belge_id`sini dolduruyordu ve belgenin tahsilat listesi o kasa
        //   islemini kendi turu/tarihi/TAM tutariyla gosteriyordu. "Hangi
        //   belgeye ne kadar sayildi" bilgisi DAGITIM satirlarinda duruyor;
        //   liste `v_belge_tahsilat` ile oradan okuyor ("Avans Kullanımı").

        // SGK KATILIM PAYI EMANETI (473): tahsil edilen katilim payi hastanin
        //   borcundan dusmez, SGK'ya aittir - hasta carisinden SGK carisine
        //   virman yazilir. Fonksiyon toplami kendisi okur; katilim yoksa
        //   hicbir sey yapmaz.
        await baglanti.CalistirAsync(
            "select public.fn_sgk_katilim_emanet_yaz(@p0)", tx, [kasaIslemId], iptal);

        // DENETIM IZI (K15): mahsup kasa isleminin dagitimini degistirir - log ayni tx'te.
        if (yazilan > 0)
            await log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, kasaIslemId,
                kullaniciId, baglam.SubeId, baglam.Ip,
                new { aksiyon = "avans-mahsup", belgeId, dagitilan = yazilan }, iptal: iptal);

        await tx.CommitAsync(iptal);
        return yazilan;
    }


    public static void KasaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kasa-islem").WithTags("Kasa").RequireAuthorization();

        // GET /api/kasa-islem-turu - ekran tur sekmeleri + bacak sablonu
        yol.MapGet("/api/kasa-islem-turu", async (
            BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);
            return Results.Ok(new { turler = await depo.TurlerAsync(iptal), izlemeNo = baglam.IzlemeNo });
        }).RequireAuthorization().WithTags("Kasa");

        // GET /api/referans/doviz-kur?cins=USD&tarih=2026-08-22&yon=1
        // GET /api/kasa/kullanici-kasasi - nakit islemde acilacak kasa (196).
        //   Once kullaniciya ATANMIS kasa, yoksa subenin VARSAYILAN kasasi.
        //   Karar veritabaninda (fn_kullanici_kasa) - ayni kural baska bir
        //   ekranda ikinci kez yazilmasin.
        yol.MapGet("/api/kasa/kullanici-kasasi", async (
            string? tur, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = new Npgsql.NpgsqlCommand(
                "select hesap_id, ad, doviz_cinsi, kendi_kasasi from public.fn_kullanici_kasa(@p0, @p1, @p2)",
                baglanti);
            komut.Parameters.AddWithValue("p0", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p1", (object?)baglam.SubeId ?? DBNull.Value);
            komut.Parameters.AddWithValue("p2", string.IsNullOrWhiteSpace(tur) ? "K" : tur);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                return Results.Ok(new { hesapId = (int?)null, izlemeNo = baglam.IzlemeNo });

            return Results.Ok(new
            {
                hesapId = o.GetInt32(0),
                ad = o.IsDBNull(1) ? "" : o.GetString(1),
                dovizCinsi = o.IsDBNull(2) ? "TL" : o.GetString(2),
                kendiKasasi = !o.IsDBNull(3) && o.GetBoolean(3),
                izlemeNo = baglam.IzlemeNo,
            });
        }).RequireAuthorization().WithTags("Kasa");

        yol.MapGet("/api/referans/doviz-kur", async (
            string cins, DateTime? tarih, int? yon,
            BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kur = await depo.KurAsync(cins, tarih ?? Saat.Bugun, yon ?? 1, iptal);
            // Istenen tarihe kur yoksa onceki en yakin gun kullanilir; hangi gun
            //   oldugu de doner - ekran "bugunun kuru" diye eski kur gostermesin.
            var kurTarihi = await depo.KurTarihiAsync(cins, tarih ?? Saat.Bugun, iptal);
            return Results.Ok(new
            {
                dovizCinsi = cins,
                tarih = (tarih ?? Saat.Bugun).Date,
                kurTarihi,
                kur,
                izlemeNo = baglam.IzlemeNo
            });
        }).RequireAuthorization().WithTags("Kasa");

        // POST /api/kasa-islem
        grup.MapPost("/", async (
            KasaIslemYazmaIstegi istek, BaglamCozucu cozucu, KasaDeposu depo, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);

            // Kesin kayit ayni anda kesinlestirme demektir - ayri yetki ister.
            //   BANKO ISTISNASI (kullanici 09.10.2026: "hasan olarak basvuruya
            //   ucret ve nakit tahsilat ekle"): banko gorevlisinin isi "fis ve
            //   tahsilat" ama `kasa.kesinlestir` (her taslak kasa islemini
            //   kesinlestirme) yalniz sorumluda. ACIK BANKO OTURUMU olan
            //   kullanici BELGEYE BAGLI tahsilatini kesin kaydedebilir - denetim
            //   oturumda: islem oturuma yazilir (997), gun sonunu sorumlu onaylar.
            if (!istek.Secenekler.Taslak && !istek.Secenekler.Plan
                && !(istek.Secenekler.BelgeId is > 0
                     && await veri.TekDegerAsync<long?>("select public.fn_banko_acik_oturum(@p0)",
                            [baglam.KullaniciId], iptal) is not null))
                baglam.AksiyonIste("kasa.kesinlestir");
            baglam.YazmaIste();

            var (id, uyarilar) = await depo.KaydetAsync(
                BaslikDegerleri(istek.Islem), istek.Bacaklar, istek.Secenekler,
                baglam.Yazma, iptal,
                istek.CekSenet);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.Uyarilar = uyarilar;
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Created($"/api/kasa-islem/{id}", kayit);
        });

        // PUT /api/kasa-islem/{id} - yalniz taslak / plan
        grup.MapPut("/{id:int}", async (
            int id, KasaIslemYazmaIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            if (!istek.Secenekler.Taslak && !istek.Secenekler.Plan)
                baglam.AksiyonIste("kasa.kesinlestir");

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var uyarilar = await depo.GuncelleAsync(id, BaslikDegerleri(istek.Islem), istek.Bacaklar,
                istek.Secenekler, istek.Surum,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.Uyarilar = uyarilar;
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // GET /api/kasa-islem/{id}
        grup.MapGet("/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);

            var kayit = await SubeKontrolAsync(depo, id, baglam, iptal);
            await arama.IsaretleAsync(baglam.KullaniciId, "kasa-islem", id, iptal);

            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // -------------------------------------------- tahsilat dagitimi ----
        // GET /api/kasa-islem/dagitim-satirlari?belgeId=&kasaIslemId=
        //   Tahsilatin hangi SATIRA gittigini secmek icin belgenin satirlari:
        //   pay bazinda (hasta/kurum) tahsil edilen ve kalan. Kart heniz
        //   kaydedilmemis olabilecegi icin kasaIslemId opsiyonel - verilirse o
        //   islemin mevcut dagitimi da doner (duzenleme).
        grup.MapGet("/dagitim-satirlari", async (
            int belgeId, int? kasaIslemId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select t.satir_id as "satirId", t.sira, t.kalem, t.kalem_kod as "kalemKod",
                       t.tutar, t.rota,
                       -- BES KOVA (470): her biri ayri satirda tahsil edilir.
                       t.hasta_provizyon_tutar as "hastaProvizyonTutar",
                       t.hasta_ek_katki_tutar  as "hastaEkKatkiTutar",
                       t.sgk_katilim_tutar     as "sgkKatilimTutar",
                       t.oss_tutar             as "ossTutar",
                       t.sgk_tutar             as "sgkTutar",
                       t.hasta_provizyon_tahsil as "hastaProvizyonTahsil",
                       t.hasta_ek_katki_tahsil  as "hastaEkKatkiTahsil",
                       t.sgk_katilim_tahsil     as "sgkKatilimTahsil",
                       t.oss_tahsil             as "ossTahsil",
                       t.sgk_tahsil             as "sgkTahsil",
                       t.hasta_provizyon_kalan as "hastaProvizyonKalan",
                       t.hasta_ek_katki_kalan  as "hastaEkKatkiKalan",
                       t.sgk_katilim_kalan     as "sgkKatilimKalan",
                       t.oss_kalan             as "ossKalan",
                       t.sgk_kalan             as "sgkKalan",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 1
                                    and d.kasa_islem_id = @p1), 0) as "buIslem1",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 2
                                    and d.kasa_islem_id = @p1), 0) as "buIslem2",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 3
                                    and d.kasa_islem_id = @p1), 0) as "buIslem3",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 4
                                    and d.kasa_islem_id = @p1), 0) as "buIslem4",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 5
                                    and d.kasa_islem_id = @p1), 0) as "buIslem5"
                  from public.v_belge_satir_tahsilat t
                 where t.belge_id = @p0
                """, null, [belgeId, kasaIslemId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            var belge = await baglanti.TekAsync("""
                select b.belge_no as "belgeNo", b.genel_toplam as "genelToplam",
                       coalesce(bb.odeyen_kurum_id, 0) as "odeyenKurumId"
                  from public.belge b
                  -- 1:1 uzanti (belge_basvuru.id = belge.id): odeyen kurum
                  --   burada durur, belge basliginda degil.
                  left join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, null, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { belge, satirlar });
        });

        // POST /api/kasa-islem/{id}/dagitim
        //   Dagitim TOPLU yazilir: once bu islemin satirlari silinir, sonra
        //   gelenler yazilir - kismi guncelleme iki kaynagi (silinen/eklenen)
        //   ayri ayri dogrulamak demekti. Asim kurallari veritabani tetiginde.
        //
        //   otomatik = true: sunucu kalan tutarlari SIRAYLA kapatir (en kucuk
        //   sira once). Radyoloji kabulu gibi tek tikla akislar bunu kullanir -
        //   kullanici dagitim ekranini hic gormeden dogru satira yazilir.
        grup.MapPost("/{id:int}/dagitim", async (
            int id, DagitimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, KasaDeposu depo,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            // SUBE KAPSAMI (kod inceleme 30.10.2026 K15): baska subenin islemi
            //   dosyadaki oteki uclar gibi 404 - varligi bile sizmaz.
            await SubeKontrolAsync(depo, id, baglam, iptal);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            // DURUM KOŞULLU (K15): satir `for update` kilitlenir, yalniz GERCEKLESMIS
            //   (2) isleme dagitim yazilir - taslak / plan / iptal edilmis islemin
            //   parasi yoktur, dagitimi da olmaz.
            var islem = await baglanti.TekAsync("""
                select k.tutar, k.belge_id as "belgeId", coalesce(k.durum, 0) as durum
                  from public.kasa_islem k where k.id = @p0
                   for update
                """, tx, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kasa işlemi bulunamadı.");
            if (Convert.ToInt32(islem["durum"]) != KasaDurum.Gerceklesti)
                throw GentegreHatasi.IsKurali(
                    "Yalnız gerçekleşmiş kasa işlemine dağıtım yazılır; taslak / plan / iptal edilmiş işlem dağıtılamaz.");

            var belgeId = istek.BelgeId ?? (islem["belgeId"] is null ? 0
                                            : Convert.ToInt32(islem["belgeId"]));
            if (belgeId <= 0)
                throw GentegreHatasi.IsKurali(
                    "Dağıtım için işlemin bağlı olduğu belge gerekli.");

            var tutar = Convert.ToDecimal(islem["tutar"]);

            // ELLE DAGITIMDA SATIR KIMLIKLERI BELGEYE AIT OLMALI (K15): istemciden
            //   gelen belge_satir_id baska bir belgenin satiri olabilir - tetik
            //   yalniz pay sinirina bakar, belgeyi bilmez. Uymayan kimlik 400.
            if (!istek.Otomatik && istek.Satirlar is { Count: > 0 })
            {
                var istenen = istek.Satirlar.Where(s => s.Tutar > 0)
                                   .Select(s => s.BelgeSatirId).Distinct().ToArray();
                if (istenen.Length > 0)
                {
                    var bulunan = await baglanti.ListeAsync(
                        "select id from public.belge_satir where id = any(@p0::int[]) and belge_id = @p1",
                        tx, [istenen, belgeId], o => o.GetInt32(0), iptal);
                    var yabanci = istenen.Except(bulunan).ToArray();
                    if (yabanci.Length > 0)
                        throw GentegreHatasi.Dogrulama(
                            "Dağıtım satırı bu belgeye ait değil.",
                            new AlanHatasi("satirlar",
                                $"Belgeye ait olmayan satır: {string.Join(", ", yabanci)}."));
                }
            }

            await baglanti.CalistirAsync(
                "delete from public.kasa_islem_dagitim where kasa_islem_id = @p0",
                tx, [id], iptal);

            var yazilacak = new List<(int SatirId, short Pay, decimal Tutar)>();

            if (istek.Otomatik)
            {
                // FIFO: satir sirasina gore once HASTANIN odedigi kovalar
                //   (provizyon payi, ek katki, katilim payi), sonra kurum
                //   kovalari. Kasadan gelen para cogunlukla hastanindir; SGK
                //   ve sigorta paylari icmal/faturayla kapanir.
                var acik = await baglanti.ListeAsync("""
                    select t.satir_id as "satirId",
                           t.hasta_provizyon_kalan as "p1", t.hasta_ek_katki_kalan as "p4",
                           t.sgk_katilim_kalan as "p5", t.oss_kalan as "p3",
                           t.sgk_kalan as "p2"
                      from public.v_belge_satir_tahsilat t
                     where t.belge_id = @p0
                     order by t.sira, t.satir_id
                    """, tx, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

                // DIS DONGU KOVA, IC DONGU SATIR (kullanici: hastadan alinan
                //   500 TL'nin 300'u kurumun ÖSS kovasina yaziliyordu).
                //   Eskiden tersiydi: ILK SATIRIN hasta kovasi dolunca ayni
                //   satirin KURUM kovasina geciliyor, sonraki satirlarin hasta
                //   payi acik dururken hastanin verdigi para kurumun borcuna
                //   sayiliyordu. Kurum kovalari icmal/faturayla kapanir; kasadan
                //   ancak HEPSININ hasta payi bittikten sonra dokunulur.
                var kalanTutar = tutar;
                foreach (var pay in new short[] { 1, 4, 5, 3, 2 })
                {
                    if (kalanTutar <= 0) break;
                    foreach (var sa in acik)
                    {
                        if (kalanTutar <= 0) break;
                        var satirId = Convert.ToInt32(sa["satirId"]);
                        var kalan = Convert.ToDecimal(sa[$"p{pay}"]);
                        if (kalan <= 0) continue;
                        var pay_tutar = Math.Min(kalan, kalanTutar);
                        yazilacak.Add((satirId, pay, Math.Round(pay_tutar, 2)));
                        kalanTutar -= pay_tutar;
                    }
                }
            }
            else
            {
                foreach (var sa in istek.Satirlar ?? [])
                    if (sa.Tutar > 0)
                        yazilacak.Add((sa.BelgeSatirId, sa.Pay, sa.Tutar));
            }

            foreach (var y in yazilacak)
                await baglanti.CalistirAsync("""
                    insert into public.kasa_islem_dagitim
                           (kasa_islem_id, belge_satir_id, pay, tutar, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4)
                    """, tx, [id, y.SatirId, y.Pay, y.Tutar, baglam.KullaniciId], iptal);

            // SGK KATILIM PAYI EMANETI (473): dagitim degistiyse virman da
            //   yeniden hesaplanir - fonksiyon toplami kendisi okur.
            await baglanti.CalistirAsync(
                "select public.fn_sgk_katilim_emanet_yaz(@p0)", tx, [id], iptal);

            // BELGE BAGI YAZILMIYOR (781): 322'de avansin `belge_id`si
            //   mahsupta doldruluyordu; sonuc, belgenin tahsilat listesinde
            //   avansin KENDI kasa islemini "Nakit Tahsilat · avansin alindigi
            //   gun · TAM tutar" olarak gostermekti (kullanici: "bugun kasaya
            //   nakit girisi yok"). Avansin hangi belgeye ne kadar sayildigi
            //   zaten DAGITIM satirlarinda; tek bir `belge_id` avans iki
            //   basvuruya bolununce de yaniltiyordu. Liste artik
            //   `v_belge_tahsilat` uzerinden dagitimi okuyor.

            var toplam = yazilacak.Sum(x => x.Tutar);
            // DENETIM IZI (K15): dagitim kasa isleminin "hangi satira ne kadar"
            //   bilgisini degistirir - log ayni tx'te, yazim ile birlikte.
            await log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { aksiyon = "dagitim", belgeId, otomatik = istek.Otomatik,
                      dagitilan = toplam, satirSayisi = yazilacak.Count }, iptal: iptal);

            await tx.CommitAsync(iptal);

            return Results.Ok(new
            {
                dagitilan = toplam,
                // Dagitilmayan kisim AVANS'tir: hastanin ileride yapilacak
                //   tetkigi icin birakilmis olabilir - hata degil, bilgi.
                avans = Math.Max(0, tutar - toplam),
                satirSayisi = yazilacak.Count,
            });
        });

        // GET /api/kasa-islem/avans?tarafId=&belgeId=
        //   Carinin DAGITILMAMIS tahsilatlari. belgeId verilirse o belgeye
        //   zaten dagitilmis olanlar da (kismi) listede kalir - kullanici
        //   kalanini gorup mahsup edebilsin.
        grup.MapGet("/avans", async (
            int tarafId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select a.kasa_islem_id as "kasaIslemId", a.islem_tarihi as "islemTarihi",
                       a.islem_adi as "islemAdi", a.tutar, a.dagitilan,
                       a.dagitilmamis, a.belge_id as "belgeId"
                  from public.v_taraf_avans a
                 where a.taraf_id = @p0
                 order by a.islem_tarihi
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                satirlar,
                toplam = satirlar.Sum(x => Convert.ToDecimal(x["dagitilmamis"])),
            });
        });

        // POST /api/kasa-islem/avans-mahsup
        //   Secilen (ya da carinin tum) dagitilmamis tahsilatlarini belgenin
        //   acik satirlarina siraya gore dagitir. Her islem KENDI dagitim
        //   satirlarini yazar; islem belgeye bagli degilse bag da kurulur -
        //   avans artik "hangi belgeye sayildi" sorusuna cevap verir.
        //
        //   PRIM TARIHI: dagitim tarihi degil, kasa isleminin ISLEM TARIHI
        //   gecerlidir (kullanici karari) - hakedis parayi girdigi gune yazar.
        grup.MapPost("/avans-mahsup", async (
            MahsupIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, KasaDeposu depo,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);

            if (istek.BelgeId <= 0)
                throw GentegreHatasi.IsKurali("Mahsup için belge gerekli.");

            // SUBE KAPSAMI (kod inceleme 30.10.2026 K15): istemcinin SECTIGI avans
            //   islemleri dosyadaki oteki uclar gibi sube kontrolunden gecer -
            //   baska subenin islemi 404. Secim yoksa liste zaten subeyle suzulur.
            if (istek.IslemIdler is { Count: > 0 })
                foreach (var secilen in istek.IslemIdler.Distinct())
                    await SubeKontrolAsync(depo, secilen, baglam, iptal);

            await using var baglanti = await veri.AcAsync(iptal);

            var belge = await baglanti.TekAsync(
                "select taraf_id, sube_id from public.belge where id = @p0", null, [istek.BelgeId],
                o => new { tarafId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), subeId = o.GetInt32(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");
            // Belge de hareket kaynagi: baska subenin belgesi yokmus gibi (API §8).
            if (baglam.SubeId is { } sube && belge.subeId != sube)
                throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");
            var tarafId = belge.tarafId ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

            var islemler = await baglanti.ListeAsync("""
                select a.kasa_islem_id as "id", a.dagitilmamis
                  from public.v_taraf_avans a
                  join public.kasa_islem k on k.id = a.kasa_islem_id
                 where a.taraf_id = @p0
                   and (@p1::int[] is null or a.kasa_islem_id = any(@p1))
                   and (@p2::int is null or k.sube_id = @p2)
                 order by a.islem_tarihi
                """, null,
                [tarafId, istek.IslemIdler is { Count: > 0 } ? istek.IslemIdler.ToArray() : null, baglam.SubeId],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            decimal toplam = 0;
            var sayac = 0;
            // KALAN BUTCE (783): istenen tutar birden fazla avansa yayilabilir
            //   (hasta iki kez avans birakmis olabilir) - her dagitimdan sonra
            //   butceden dusulur, bitince durulur.
            var butce = istek.Tutar is > 0 ? istek.Tutar : null;
            if (istek.Tutar is <= 0)
                throw GentegreHatasi.IsKurali("Mahsup tutarı sıfırdan büyük olmalı.");

            foreach (var isl in islemler)
            {
                if (butce is <= 0) break;
                var islemId = Convert.ToInt32(isl["id"]);

                // Belgede kalan yoksa devam etmenin anlami yok: sonraki avans
                //   da dagitilamaz, bosuna sorgu olur.
                var kalanVar = await baglanti.TekDegerAsync<decimal>("""
                    select coalesce(sum(t.hasta_provizyon_kalan + t.hasta_ek_katki_kalan
                                      + t.sgk_katilim_kalan + t.oss_kalan
                                      + t.sgk_kalan), 0)
                      from public.v_belge_satir_tahsilat t where t.belge_id = @p0
                    """, null, [istek.BelgeId], iptal);
                if (kalanVar <= 0) break;

                var dagitilan = await AvansDagitAsync(baglanti, log, baglam, islemId, istek.BelgeId,
                                                      iptal, butce);
                if (dagitilan > 0)
                {
                    toplam += dagitilan; sayac++;
                    if (butce is { } b) butce = b - dagitilan;
                }
            }

            return Results.Ok(new { dagitilan = toplam, islemSayisi = sayac });
        });

        // POST /api/kasa-islem/avans-mahsup/iptal
        //   Bir avansin BU BELGEYE yapilmis mahsubunu geri alir: dagitim
        //   satirlari silinir, avansin kalani geri doner.
        grup.MapPost("/avans-mahsup/iptal", async (
            MahsupIptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, KasaDeposu depo,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);

            if (istek.BelgeId <= 0 || istek.KasaIslemId <= 0)
                throw GentegreHatasi.IsKurali("Geri alınacak avans mahsubu belirtilmeli.");

            // SUBE KAPSAMI (kod inceleme 30.10.2026 K15): baska subenin avansi 404.
            await SubeKontrolAsync(depo, istek.KasaIslemId, baglam, iptal);

            await using var baglanti = await veri.AcAsync(iptal);
            // OKUMA + SILME TEK TRANSACTION (K15): kasa islemi satiri kilitlenir;
            //   iki istek ayni mahsubu ayni anda geri alamaz, "geri alinan" tutar
            //   gercekten silinen tutardir.
            await using var tx = await baglanti.BeginTransactionAsync(iptal);
            await baglanti.CalistirAsync("select 1 from public.kasa_islem where id = @p0 for update",
                                         tx, [istek.KasaIslemId], iptal);

            // SILINEN TUTAR once okunur: kullaniciya "ne kadar geri dondu"
            //   soylenecek ve silme sonrasi bu bilgi kalmaz.
            var tutar = await baglanti.TekDegerAsync<decimal>("""
                select coalesce(sum(d.tutar), 0)
                  from public.kasa_islem_dagitim d
                  join public.belge_satir bs on bs.id = d.belge_satir_id
                 where d.kasa_islem_id = @p0 and bs.belge_id = @p1
                """, tx, [istek.KasaIslemId, istek.BelgeId], iptal);

            if (tutar <= 0)
                throw GentegreHatasi.IsKurali("Bu belgeye yapılmış bir avans mahsubu yok.");

            // YALNIZ BU BELGENIN dagitimlari silinir: ayni avans baska bir
            //   basvuruya da sayilmis olabilir, onun mahsubu yerinde kalir.
            //   Hakedis satirlari dagitima CASCADE bagli - onlar da duser.
            await baglanti.CalistirAsync("""
                delete from public.kasa_islem_dagitim d
                 using public.belge_satir bs
                 where bs.id = d.belge_satir_id
                   and d.kasa_islem_id = @p0 and bs.belge_id = @p1
                """, tx, [istek.KasaIslemId, istek.BelgeId], iptal);

            await log.YazAsync(baglanti, tx, LogIslemi.Degistir, LogTabloKasa, istek.KasaIslemId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { aksiyon = "avans-mahsup-iptal", belgeId = istek.BelgeId, geriAlinan = tutar }, iptal: iptal);
            await tx.CommitAsync(iptal);

            return Results.Ok(new { geriAlinan = tutar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/kasa-islem/{id}/kesinlestir
        grup.MapPost("/{id:int}/kesinlestir", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            baglam.AksiyonIste("kasa.kesinlestir");
            await SubeKontrolAsync(depo, id, baglam, iptal);

            await depo.KesinlestirAsync(id, baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(kayit);
        });

        // POST /api/kasa-islem/{id}/iptal
        grup.MapPost("/{id:int}/iptal", async (
            int id, IptalIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);
            baglam.AksiyonIste("kasa.iptal");

            if (string.IsNullOrWhiteSpace(istek?.Sebep))
                throw GentegreHatasi.Dogrulama("İptal sebebi yazılmalı.",
                    new AlanHatasi("sebep", "Zorunlu."));

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var tersId = await depo.IptalAsync(id, istek.Sebep, istek.Tarih,
                baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Ok(new { islem = kayit.Islem, tersIslemId = tersId, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/kasa-islem/{id}/gerceklestir - plandan tahsilat/odeme uret
        grup.MapPost("/{id:int}/gerceklestir", async (
            int id, GerceklestirIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);
            baglam.AksiyonIste("kasa.gerceklestir");

            if (istek is null || istek.HesapId <= 0)
                throw GentegreHatasi.Dogrulama("Tahsilat/ödeme hesabı seçilmeli.",
                    new AlanHatasi("hesapId", "Zorunlu."));

            await SubeKontrolAsync(depo, id, baglam, iptal);

            var yeniId = await depo.PlanGerceklestirAsync(id, istek.HesapId, istek.Tutar,
                istek.Tarih, istek.Tur, baglam.Yazma, iptal);

            var kayit = await depo.OkuAsync(yeniId, iptal) ?? throw GentegreHatasi.Bulunamadi();
            kayit.IzlemeNo = baglam.IzlemeNo;
            return Results.Created($"/api/kasa-islem/{yeniId}", kayit);
        });

        // DELETE /api/kasa-islem/{id} - yalniz taslak / plan (DB trigger de korur)
        grup.MapDelete("/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Sil);
            await SubeKontrolAsync(depo, id, baglam, iptal);

            await depo.SilAsync(id, baglam.Yazma, iptal);
            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muhasebe/fis/{id}
        yol.MapGet("/api/muhasebe/fis/{id:int}", async (
            int id, BaglamCozucu cozucu, KasaDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muhasebe_fis", Islem.Gor);
            var fis = await depo.FisOkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();
            return Results.Ok(new { fis, izlemeNo = baglam.IzlemeNo });
        }).RequireAuthorization().WithTags("Kasa");
    }

    public sealed class IptalIstegi
    {
        public string Sebep { get; set; } = "";
        public DateTime? Tarih { get; set; }
    }

    /// <summary>Tutar bos ise planin KALANI gerceklesir; tur bos ise hesap turunden secilir.</summary>
    public sealed class GerceklestirIstegi
    {
        public int HesapId { get; set; }
        public decimal? Tutar { get; set; }
        public DateTime? Tarih { get; set; }
        public int? Tur { get; set; }
    }

    /// <summary>Baska subenin islemi yokmus gibi davranir (API §8).</summary>
    private static async Task<KasaIslemYaniti> SubeKontrolAsync(
        KasaDeposu depo, int id, IstekBaglami baglam, CancellationToken iptal)
    {
        var kayit = await depo.OkuAsync(id, iptal) ?? throw GentegreHatasi.Bulunamadi();

        var kapsam = baglam.SubeId;
        if (kapsam is not null &&
            kayit.Islem.TryGetValue("subeId", out var sube) && sube is not null &&
            Convert.ToInt32(sube) != kapsam.Value)
            throw GentegreHatasi.Bulunamadi();

        return kayit;
    }

    /// <summary>Sunucunun kendi belirledigi alanlar - istekte gelemez.</summary>
    private static readonly HashSet<string> SunucuAlanlari = new(StringComparer.Ordinal)
        { "yerelTutar", "durum", "islemNo", "gerceklesenTutar", "muhasebeFisId" };

    /// <summary>
    /// Baslik alan beyaz listesi - dongu ORTAK (BaslikDogrulayici); istemciden
    /// gelen ad hicbir zaman SQL'e girmez.
    /// </summary>
    private static Dictionary<string, object?> BaslikDegerleri(Dictionary<string, JsonElement>? gelen)
        => BaslikDogrulayici.Cevir(gelen, BaslikTipi, Uzunluk, "kasa işlemi alanı", SunucuAlanlari);

    private static string? BaslikTipi(string ad) => ad switch
    {
        "tur" or "tarafId" or "karsiTarafId" or "hesapId" or "karsiHesapId" or "masrafId" or
        "hizmetId" or "projeId" or "merkezId" or "cekSenetId" or "krediTaksitId" or
        "kuponTuruId" or "belgeId" or "planIslemId" or "subeId" or "girisKaynak" or
        // AVANS DAMGASI (779): hasta avansi olarak alinan tahsilat. Yazma
        //   beyaz listesine eklemek yetmiyor - baslik dogrulayicisi katalogda
        //   olmayan adi REDDEDIYOR (tasarim): iki liste de bilmeli.
        "avans" or "avansKaynakId" or
        // POS TERMINALI (997): tahsilat ekrani bankonun POS'unu yazar; yazma
        //   haritasinda vardi, burada yoktu - POS tahsilati "Bilinmeyen kasa
        //   islemi alani: bankoPosId" ile reddediliyordu (kullanici 09.10.2026).
        "bankoPosId" => "sayi",

        "tutar" or "dovizKuru" or "karsiTutar" or "karsiKur" or "masrafTutar" => "para",

        "islemTarihi" or "planTarihi" => "tarih",

        "makbuzNo" or "dovizCinsi" or "karsiDovizCinsi" or "ekstreDovizi" or
        "tarafUnvan" or "aciklama" => "metin",

        _ => null
    };

    private static int? Uzunluk(string ad) => ad switch
    {
        "dovizCinsi" or "karsiDovizCinsi" or "ekstreDovizi" => 6,
        "makbuzNo" => 30,
        "tarafUnvan" or "aciklama" => 200,
        _ => null
    };

}
