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
    public sealed record MahsupIstegi(int BelgeId, IReadOnlyList<int>? IslemIdler);

    /// <summary>
    /// Bir kasa isleminin DAGITILMAMIS kismini belgenin acik satirlarina
    /// siraya gore yazar (once hasta payi - kasadan gelen para cogunlukla
    /// hastanindir, kurum payi icmalle kapanir). Mevcut dagitim satirlari
    /// KORUNUR: mahsup ekleme islemidir, yeniden yazma degil.
    /// </summary>
    private static async Task<decimal> AvansDagitAsync(NpgsqlConnection baglanti,
        int kasaIslemId, int belgeId, int kullaniciId, CancellationToken iptal)
    {
        var kalanTutar = await baglanti.TekDegerAsync<decimal>("""
            select coalesce(v.dagitilmamis, 0) from public.v_kasa_islem_dagitim v
             where v.kasa_islem_id = @p0
            """, null, [kasaIslemId], iptal);
        if (kalanTutar <= 0) return 0;

        var acik = await baglanti.ListeAsync("""
            select t.satir_id as "satirId", t.hasta_kalan as "hastaKalan",
                   t.kurum_kalan as "kurumKalan"
              from public.v_belge_satir_tahsilat t
             where t.belge_id = @p0 and (t.hasta_kalan + t.kurum_kalan) > 0
             order by t.sira, t.satir_id
            """, null, [belgeId], Satir, iptal);

        decimal yazilan = 0;
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        foreach (var sa in acik)
        {
            if (kalanTutar <= 0) break;
            var satirId = Convert.ToInt32(sa["satirId"]);

            foreach (var (pay, payKalan) in new[]
                     { ((short)1, Convert.ToDecimal(sa["hastaKalan"])),
                       ((short)2, Convert.ToDecimal(sa["kurumKalan"])) })
            {
                if (kalanTutar <= 0 || payKalan <= 0) continue;
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

        // Avans belgeye BAGLANIR: "bu para hangi belgeye sayildi" sorusunun
        //   cevabi kasa isleminin kendisinde de dursun (belgesiz tahsilat).
        if (yazilan > 0)
            await baglanti.CalistirAsync("""
                update public.kasa_islem set belge_id = coalesce(belge_id, @p1)
                 where id = @p0
                """, tx, [kasaIslemId, belgeId], iptal);

        await tx.CommitAsync(iptal);
        return yazilan;
    }

    /// <summary>Okuyucu satiri -> sozluk (kolon adlari JSON alan adi olur).</summary>
    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
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
            var kur = await depo.KurAsync(cins, tarih ?? DateTime.Today, yon ?? 1, iptal);
            // Istenen tarihe kur yoksa onceki en yakin gun kullanilir; hangi gun
            //   oldugu de doner - ekran "bugunun kuru" diye eski kur gostermesin.
            var kurTarihi = await depo.KurTarihiAsync(cins, tarih ?? DateTime.Today, iptal);
            return Results.Ok(new
            {
                dovizCinsi = cins,
                tarih = (tarih ?? DateTime.Today).Date,
                kurTarihi,
                kur,
                izlemeNo = baglam.IzlemeNo
            });
        }).RequireAuthorization().WithTags("Kasa");

        // POST /api/kasa-islem
        grup.MapPost("/", async (
            KasaIslemYazmaIstegi istek, BaglamCozucu cozucu, KasaDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Ekle);

            // Kesin kayit ayni anda kesinlestirme demektir - ayri yetki ister.
            if (!istek.Secenekler.Taslak && !istek.Secenekler.Plan)
                baglam.AksiyonIste("kasa.kesinlestir");

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
                       t.tutar, t.hasta_tutar as "hastaTutar", t.kurum_tutar as "kurumTutar",
                       t.hasta_tahsil as "hastaTahsil", t.kurum_tahsil as "kurumTahsil",
                       t.hasta_kalan as "hastaKalan", t.kurum_kalan as "kurumKalan",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 1
                                    and d.kasa_islem_id = @p1), 0) as "buIslemHasta",
                       coalesce((select sum(d.tutar) from public.kasa_islem_dagitim d
                                  where d.belge_satir_id = t.satir_id and d.pay = 2
                                    and d.kasa_islem_id = @p1), 0) as "buIslemKurum"
                  from public.v_belge_satir_tahsilat t
                 where t.belge_id = @p0
                """, null, [belgeId, kasaIslemId ?? 0], Satir, iptal);

            var belge = await baglanti.TekAsync("""
                select b.belge_no as "belgeNo", b.genel_toplam as "genelToplam",
                       coalesce(bb.odeyen_kurum_id, 0) as "odeyenKurumId"
                  from public.belge b
                  -- 1:1 uzanti (belge_basvuru.id = belge.id): odeyen kurum
                  --   burada durur, belge basliginda degil.
                  left join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, null, [belgeId], Satir, iptal);

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
            int id, DagitimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var islem = await baglanti.TekAsync("""
                select k.tutar, k.belge_id as "belgeId", coalesce(k.durum, 0) as durum
                  from public.kasa_islem k where k.id = @p0
                """, null, [id], Satir, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kasa işlemi bulunamadı.");

            var belgeId = istek.BelgeId ?? (islem["belgeId"] is null ? 0
                                            : Convert.ToInt32(islem["belgeId"]));
            if (belgeId <= 0)
                throw GentegreHatasi.IsKurali(
                    "Dağıtım için işlemin bağlı olduğu belge gerekli.");

            var tutar = Convert.ToDecimal(islem["tutar"]);

            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync(
                "delete from public.kasa_islem_dagitim where kasa_islem_id = @p0",
                tx, [id], iptal);

            var yazilacak = new List<(int SatirId, short Pay, decimal Tutar)>();

            if (istek.Otomatik)
            {
                // FIFO: satir sirasina gore once HASTA payi, sonra kurum payi.
                //   Hasta once cunku kasadan gelen tahsilat cogunlukla hastanin;
                //   kurum payi icmalle kapanir.
                var acik = await baglanti.ListeAsync("""
                    select t.satir_id as "satirId", t.hasta_kalan as "hastaKalan",
                           t.kurum_kalan as "kurumKalan"
                      from public.v_belge_satir_tahsilat t
                     where t.belge_id = @p0
                     order by t.sira, t.satir_id
                    """, null, [belgeId], Satir, iptal);

                var kalanTutar = tutar;
                foreach (var sa in acik)
                {
                    if (kalanTutar <= 0) break;
                    var satirId = Convert.ToInt32(sa["satirId"]);
                    foreach (var (pay, kalan) in new[]
                             { ((short)1, Convert.ToDecimal(sa["hastaKalan"])),
                               ((short)2, Convert.ToDecimal(sa["kurumKalan"])) })
                    {
                        if (kalanTutar <= 0 || kalan <= 0) continue;
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

            // Belgesiz tahsilat dagitilinca belgeye BAGLANIR (322): avansin
            //   hangi belgeye sayildigi kasa isleminden de okunabilsin.
            if (yazilacak.Count > 0)
                await baglanti.CalistirAsync("""
                    update public.kasa_islem set belge_id = coalesce(belge_id, @p1)
                     where id = @p0
                    """, tx, [id, belgeId], iptal);

            await tx.CommitAsync(iptal);

            var toplam = yazilacak.Sum(x => x.Tutar);
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
                """, null, [tarafId], Satir, iptal);

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
            MahsupIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kasa_islem", Islem.Degistir);

            if (istek.BelgeId <= 0)
                throw GentegreHatasi.IsKurali("Mahsup için belge gerekli.");

            await using var baglanti = await veri.AcAsync(iptal);

            var tarafId = await baglanti.TekDegerAsync<int?>(
                "select taraf_id from public.belge where id = @p0", null, [istek.BelgeId], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

            var islemler = await baglanti.ListeAsync("""
                select a.kasa_islem_id as "id", a.dagitilmamis
                  from public.v_taraf_avans a
                 where a.taraf_id = @p0
                   and (@p1::int[] is null or a.kasa_islem_id = any(@p1))
                 order by a.islem_tarihi
                """, null,
                [tarafId, istek.IslemIdler is { Count: > 0 } ? istek.IslemIdler.ToArray() : null],
                Satir, iptal);

            decimal toplam = 0;
            var sayac = 0;

            foreach (var isl in islemler)
            {
                var islemId = Convert.ToInt32(isl["id"]);

                // Belgede kalan yoksa devam etmenin anlami yok: sonraki avans
                //   da dagitilamaz, bosuna sorgu olur.
                var kalanVar = await baglanti.TekDegerAsync<decimal>("""
                    select coalesce(sum(t.hasta_kalan + t.kurum_kalan), 0)
                      from public.v_belge_satir_tahsilat t where t.belge_id = @p0
                    """, null, [istek.BelgeId], iptal);
                if (kalanVar <= 0) break;

                var dagitilan = await AvansDagitAsync(baglanti, islemId, istek.BelgeId,
                                                      baglam.KullaniciId, iptal);
                if (dagitilan > 0) { toplam += dagitilan; sayac++; }
            }

            return Results.Ok(new { dagitilan = toplam, islemSayisi = sayac });
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
        "kuponTuruId" or "belgeId" or "planIslemId" or "subeId" or "girisKaynak" => "sayi",

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
