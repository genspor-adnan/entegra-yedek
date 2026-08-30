using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FIYAT LISTESI uclari (201/202/205/207).
///
/// Listenin kendisi ve satirlari GENERIC kart uclarindan yonetilir
/// (/api/kart/fiyat-listesi); buradakiler kart sozlesmesine sigmayan isler:
/// listeyi URETMEK, tek kalemin fiyatini SORMAK, belge acilisinda varsayilan
/// listeyi COZMEK ve Excel sablon indirme / iceri alma.
/// </summary>
public static class FiyatListesiUclari
{
    /// <summary>islem_log.tablo_id - KartKatalogu.FiyatListesi ile AYNI kod olmali.</summary>
    private const int LogTabloFiyatListesi = 923;

    /// <param name="Stok">Stok kalemleri fiyatlansin mi (varsayilan evet).</param>
    /// <param name="Hizmet">Hizmet kalemleri fiyatlansin mi (varsayilan evet).</param>
    public sealed record UretimIstegi(bool? Stok, bool? Hizmet);

    public sealed record UretimSonucu(int Eklenen, int Guncellenen, int Korunan,
                                      int Fiyatsiz, string Mesaj);

    public static void FiyatListesiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // ------------------------------------------------------------ uret ----
        // Listeyi MATERYALIZE eder. Ayri yetki (fiyat_listesi.uret): binlerce
        //   satir yazar ve taban liste degistiyse fiyatlari toptan degistirir.
        yol.MapPost("/api/fiyat-listesi/{id:int}/uret", async (
            int id, UretimIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("fiyat_listesi.uret");

            await using var baglanti = await veri.AcAsync(iptal);

            // Liste var mi + hangi subeye ait: baska subenin listesini uretmek
            //   sessiz bir veri sizintisi olurdu.
            await using var kontrol = baglanti.Komut(
                "select ad, coalesce(sube_id, 0) from public.fiyat_listesi where id = @p0", null, id);
            string ad;
            int subeId;
            await using (var o = await kontrol.ExecuteReaderAsync(iptal))
            {
                if (!await o.ReadAsync(iptal)) return Results.NotFound();
                ad = o.GetString(0);
                subeId = o.GetInt32(1);
            }
            if (subeId != 0 && baglam.SubeId is { } aktif && subeId != aktif)
                throw GentegreHatasi.Yasak("Bu liste başka bir şubeye ait.");

            await using var komut = baglanti.Komut(
                "select eklenen, guncellenen, korunan, fiyatsiz from public.fn_fiyat_listesi_uret(@p0, @p1, @p2, @p3)",
                null, id, baglam.KullaniciId, istek?.Stok ?? true, istek?.Hizmet ?? true);

            await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("Liste üretilemedi.");

            var sonuc = new UretimSonucu(
                okuyucu.GetInt32(0), okuyucu.GetInt32(1), okuyucu.GetInt32(2), okuyucu.GetInt32(3),
                "");
            await okuyucu.CloseAsync();

            // Fiyati cozulemeyen kalem sayisi SESSIZ GECILMEZ: kullanici "liste
            //   hazir" sanip eksik listeyle satisa cikmasin.
            var mesaj = $"\"{ad}\": {sonuc.Eklenen} yeni, {sonuc.Guncellenen} güncellenen satır.";
            if (sonuc.Korunan > 0) mesaj += $" {sonuc.Korunan} manuel satır korundu.";
            if (sonuc.Fiyatsiz > 0) mesaj += $" {sonuc.Fiyatsiz} kalem fiyatı çözülemediği için atlandı.";

            await log.YazAsync(baglanti, null!, LogIslemi.Degistir, LogTabloFiyatListesi, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["uretim"] = mesaj }, iptal: iptal);

            return Results.Ok(sonuc with { Mesaj = mesaj });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ------------------------------------------------------------ fiyat ----
        // Tek kalemin liste fiyati. Liste HENUZ URETILMEMIS olsa da cevap
        //   doner - kural zincirle isletilir (onizleme icin).
        yol.MapGet("/api/fiyat-listesi/{id:int}/fiyat", async (
            int id, int? stokId, int? hizmetId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Gor);

            if ((stokId is null or 0) == (hizmetId is null or 0))
                throw GentegreHatasi.Dogrulama("stokId ya da hizmetId'den TAM BIRI verilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "select fiyat, doviz_cinsi, kdv_dahil, kaynak from public.fn_fiyat_listesi_fiyat(@p0, @p1, @p2)",
                null, id, stokId is 0 ? null : stokId, hizmetId is 0 ? null : hizmetId);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                return Results.Ok(new { fiyat = (decimal?)null, dovizCinsi = "", kdvDahil = 0, kaynak = "yok" });

            return Results.Ok(new
            {
                fiyat = o.IsDBNull(0) ? (decimal?)null : o.GetDecimal(0),
                dovizCinsi = o.IsDBNull(1) ? "" : o.GetString(1),
                kdvDahil = o.IsDBNull(2) ? 0 : o.GetInt16(2),
                kaynak = o.IsDBNull(3) ? "" : o.GetString(3),
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ------------------------------------------------- gecerli kampanya ----
        // Belge basligindaki KAMPANYA ROZETI (274). Kalem eklenmeden once de
        //   gorunmesi gerektigi icin fiyat ucundan ayri: kart acilir acilmaz
        //   "hangi anlasma yuruyor" yazar.
        yol.MapGet("/api/fiyat/kampanya", async (
            int? tarafId, int? kurumId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var (kampanyaId, _, kod, ad, kampanyaListesi) =
                await KampanyaCozAsync(baglanti, tarafId, kurumId, iptal);

            return Results.Ok(new { kampanyaId, kod, ad, fiyatListesiId = kampanyaListesi });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // --------------------------------------------------- kampanyali fiyat ----
        // KALEM FIYATI (272/274): carinin - basvuruda ODEYEN KURUMUN - gecerli
        //   kampanyasi varsa kalem fiyati o kampanyanin kurallarindan gecer.
        //   Baz fiyat once LISTEDEN cozulur (kampanyanin kendi listesi > verilen
        //   liste), sonra indirim islenir. Iki asamayi tek uca koymak sart:
        //   istemci iki ayri istekle ayni sonucu kurmaya calisirsa fiyat listesi
        //   ile kampanya arasindaki bag (kampanya.fiyat_listesi_id) kacar.
        yol.MapGet("/api/fiyat/kalem", async (
            int? tarafId, int? kurumId, int? stokId, int? hizmetId, int? listeId,
            BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            if ((stokId is null or 0) == (hizmetId is null or 0))
                throw GentegreHatasi.Dogrulama("stokId ya da hizmetId'den TAM BIRI verilmeli.");

            var stok   = stokId   is 0 ? null : stokId;
            var hizmet = hizmetId is 0 ? null : hizmetId;

            await using var baglanti = await veri.AcAsync(iptal);

            // 1) Gecerli kampanya ve kampanyanin baz listesi.
            var (kampanyaId, _, _, _, kampanyaListesi) =
                await KampanyaCozAsync(baglanti, tarafId, kurumId, iptal);

            // Baz liste: ACIKCA verilen liste kazanir, yoksa kampanyanin kendi
            //   listesi. Belge basligi zaten kampanyanin listesine gecirilir
            //   (BelgeKarti) - kullanici oradan baskasini secerse SECIMI gecerli
            //   olmali, kampanya listesi onu sessizce geri almamali.
            var bazListe = (listeId is 0 ? null : listeId) ?? kampanyaListesi;

            // 2) Baz fiyat: liste kurali (liste yoksa fiyat da yok - kampanya
            //    yuzdesi bos fiyat uzerinde anlamsiz, TUTAR tipi yine calisir).
            decimal? bazFiyat = null;
            var dovizCinsi = "";
            short kdvDahil = 0;
            var kaynak = "yok";
            if (bazListe is { } bl)
            {
                await using var f = baglanti.Komut(
                    "select fiyat, doviz_cinsi, kdv_dahil, kaynak " +
                    "  from public.fn_fiyat_listesi_fiyat(@p0, @p1, @p2)",
                    null, bl, stok, hizmet);
                await using var o = await f.ExecuteReaderAsync(iptal);
                if (await o.ReadAsync(iptal))
                {
                    bazFiyat   = o.IsDBNull(0) ? null : o.GetDecimal(0);
                    dovizCinsi = o.IsDBNull(1) ? "" : o.GetString(1);
                    kdvDahil   = o.IsDBNull(2) ? (short)0 : o.GetInt16(2);
                    kaynak     = o.IsDBNull(3) ? "" : o.GetString(3);
                }
            }

            // 3) Kampanya indirimi.
            decimal? fiyat = bazFiyat;
            int? satirId = null;
            short? tip = null, iskontoTipi = null;
            decimal? iskonto = null;
            if (kampanyaId is { } kid)
            {
                await using var kf = baglanti.Komut(
                    "select fiyat, satir_id, tip, iskonto_tipi, iskonto " +
                    "  from public.fn_kampanya_fiyat(@p0, @p1, @p2, @p3)",
                    null, kid, stok, hizmet, bazFiyat);
                await using var o = await kf.ExecuteReaderAsync(iptal);
                if (await o.ReadAsync(iptal))
                {
                    fiyat       = o.IsDBNull(0) ? bazFiyat : o.GetDecimal(0);
                    satirId     = o.IsDBNull(1) ? null : o.GetInt32(1);
                    tip         = o.IsDBNull(2) ? null : o.GetInt16(2);
                    iskontoTipi = o.IsDBNull(3) ? null : o.GetInt16(3);
                    iskonto     = o.IsDBNull(4) ? null : o.GetDecimal(4);
                }
            }

            return Results.Ok(new
            {
                fiyat,
                bazFiyat,
                dovizCinsi,
                kdvDahil,
                kaynak = satirId is null ? kaynak : "kampanya",
                kampanyaId,
                listeId = bazListe,
                satirId,
                tip,
                iskontoTipi,
                iskonto,
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ------------------------------------------- belgenin varsayilan listesi ----
        // Belge acilirken hangi liste gelecek: belge TURUNUN yonune gore
        //   carinin listesi, yoksa o yonun varsayilani.
        yol.MapGet("/api/belge/varsayilan-liste", async (
            int tur, int tarafId, int? kurumId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                select l.id, l.ad, l.yon, l.kdv_dahil
                  from public.fiyat_listesi l
                 where l.id = public.fn_belge_varsayilan_liste(@p0, @p1, current_date, @p2)
                """, null, tur, tarafId, kurumId is 0 ? null : kurumId);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                return Results.Ok(new { listeId = (int?)null, ad = "", yon = 0, kdvDahil = 0 });

            return Results.Ok(new
            {
                listeId = (int?)o.GetInt32(0), ad = o.GetString(1),
                yon = (int)o.GetInt16(2), kdvDahil = (int)o.GetInt16(3),
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // NOT (208): /api/belge/{id}/fiyatlandir ucu ve fn_belge_fiyatlandir
        //   KALDIRILDI. fn durum=0'i "kesin" sanip TUM normal belgeleri
        //   reddediyordu ve yalniz birim_fiyat yazip toplamlari bayat
        //   birakiyordu - satir matematigi (banker's rounding, ic yuvarlama)
        //   BelgeHesap'ta, PG'de kurus paritesiyle tekrarlanamaz. Liste
        //   degisiminde fiyatlar artik EKRANDA yenilenir, Kaydet toplamlariyla
        //   birlikte kalicilastirir (BelgeKarti.listeDegisti).

        // ------------------------------------------------------------ sablon ----
        // Excel sablonu. `dolu=1` MEVCUT satirlari doldurur: gercek akis
        //   "indir -> Excel'de duzelt -> geri yukle"dir ve disari verilenle
        //   iceri alinan AYNI sutun duzenini kullanir (tek sozlesme).
        yol.MapGet("/api/fiyat-listesi/{id:int}/sablon", async (
            int id, int? dolu, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var liste = await ListeBulAsync(baglanti, id, baglam, iptal);
            if (liste is null) return Results.NotFound();

            byte[] icerik;
            if (dolu == 1)
            {
                var satirlar = new List<IReadOnlyList<object?>>();
                await using var komut = baglanti.Komut("""
                    select case when v.stok_id is not null then v.kod else '' end,
                           case when v.hizmet_id is not null then v.kod else '' end,
                           v.ad, v.fiyat, v.doviz_cinsi,
                           case when v.kdv_dahil = 1 then 'Dahil' else 'Hariç' end,
                           coalesce(kd.ad, ''),
                           case when v.durum = 1 then 'Aktif' else 'Pasif' end
                      from public.v_fiyat_listesi_satir v
                      left join public.kod_liste kl on kl.kod = 'stok.ana_birim'
                      left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = v.birim
                     where v.liste_id = @p0
                     order by v.kod
                    """, null, id);
                await using var o = await komut.ExecuteReaderAsync(iptal);
                while (await o.ReadAsync(iptal))
                    satirlar.Add(new object?[]
                    {
                        o.GetString(0), o.GetString(1), o.GetString(2), o.GetDecimal(3),
                        o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7),
                    });
                icerik = ExcelOkuma.Yaz("Fiyat Listesi", FiyatListesiIceriAl.SablonBasliklari, satirlar);
            }
            else
            {
                icerik = FiyatListesiIceriAl.BosSablon();
            }

            var dosyaAdi = (dolu == 1 ? liste.Value.Ad : "Fiyat Listesi Şablonu") + ".xlsx";
            return Results.File(icerik,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", dosyaAdi);
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ---------------------------------------------------------- iceri al ----
        // Excel'den satir alma. Iki yetki birden: `veri.iceri-al` (jenerik kapi)
        //   + listenin kendisinde Degistir - kapi tek basina yazdirmaz.
        yol.MapPost("/api/fiyat-listesi/{id:int}/iceri-al", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");
            baglam.YetkiIste("fiyat_listesi", Islem.Degistir);

            var form = await ctx.Request.ReadFormAsync(iptal);
            var dosya = form.Files.GetFile("dosya")
                ?? throw GentegreHatasi.Dogrulama("Dosya gönderilmedi.",
                       new AlanHatasi("dosya", "Bir .xlsx dosyası seçin."));
            if (dosya.Length > ExcelOkuma.AzamiBoyut)
                throw GentegreHatasi.Dogrulama(
                    $"Dosya {ExcelOkuma.AzamiBoyut / 1024 / 1024} MB sınırını aşıyor.",
                    new AlanHatasi("dosya", "Dosya çok büyük."));

            await using var baglanti = await veri.AcAsync(iptal);
            var liste = await ListeBulAsync(baglanti, id, baglam, iptal);
            if (liste is null) return Results.NotFound();

            ExcelOkuma.Sayfa sayfa;
            await using (var akis = dosya.OpenReadStream())
                sayfa = ExcelOkuma.Oku(akis);

            var sonuc = await FiyatListesiIceriAl.CalistirAsync(
                baglanti, id, liste.Value.KdvDahil, sayfa, baglam.KullaniciId, iptal);

            if (sonuc.ToplamHata > 0)
            {
                // YA HEP YA HIC: hicbir sey yazilmadi; kullanici Excel'i
                //   duzeltip ayni dosyayi yeniden yukler.
                var govde = new
                {
                    hata = new
                    {
                        kod = "DOGRULAMA",
                        mesaj = $"{sonuc.ToplamHata} satır hatalı; HİÇBİR satır alınmadı. " +
                                "Hataları düzeltip dosyayı yeniden yükleyin.",
                        izlemeNo = baglam.IzlemeNo,
                        satirHatalari = sonuc.Hatalar,
                        toplamHata = sonuc.ToplamHata,
                    },
                };
                return Results.Json(govde, statusCode: 422);
            }

            var mesaj = $"\"{liste.Value.Ad}\": {sonuc.Eklenen} yeni, {sonuc.Guncellenen} güncellenen satır " +
                        $"({dosya.FileName}).";
            await log.YazAsync(baglanti, null!, LogIslemi.Degistir, 924, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["iceriAl"] = mesaj }, iptal: iptal);

            return Results.Ok(new { sonuc.Eklenen, sonuc.Guncellenen, sonuc.Toplam, mesaj });
        }).WithTags("FiyatListesi").RequireAuthorization();
    }

    /// <summary>
    /// Liste basligini okur ve SUBE SIZINTISINI keser: baska subenin listesi
    /// yokmus gibi (404) davranir. Uc uctan cagrilan ortak kontrol.
    /// </summary>
    private static async Task<(string Ad, short KdvDahil)?> ListeBulAsync(
        Npgsql.NpgsqlConnection baglanti, int id, IstekBaglami baglam, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            "select ad, kdv_dahil, coalesce(sube_id, 0) from public.fiyat_listesi where id = @p0",
            null, id);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) return null;
        var subeId = o.GetInt32(2);
        if (subeId != 0 && baglam.SubeId is { } aktif && subeId != aktif)
            throw GentegreHatasi.Yasak("Bu liste başka bir şubeye ait.");
        return (o.GetString(0), o.GetInt16(1));
    }

    /// <summary>
    /// Yururlukteki KAMPANYA (274). Basvuruda ODEYEN KURUM varsa kampanya ONUN
    /// sozlesmesinden gelir - odemeyi yapan taraf fiyati belirler; yoksa carinin
    /// kendi kampanyasi, o da yoksa genel kampanya (fn_taraf_kampanya).
    /// </summary>
    private static async Task<(int? Id, int? TarafId, string Kod, string Ad, int? FiyatListesiId)>
        KampanyaCozAsync(Npgsql.NpgsqlConnection baglanti, int? tarafId, int? kurumId,
                         CancellationToken iptal)
    {
        var taraf = kurumId is > 0 ? kurumId : tarafId is > 0 ? tarafId : null;

        await using var komut = baglanti.Komut("""
            select k.id, k.kod, k.ad, k.fiyat_listesi_id
              from public.kampanya k
             where k.id = public.fn_taraf_kampanya(@p0)
            """, null, taraf);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) return (null, taraf, "", "", null);

        return (o.GetInt32(0), taraf, o.GetString(1), o.GetString(2),
                o.IsDBNull(3) ? null : o.GetInt32(3));
    }
}
