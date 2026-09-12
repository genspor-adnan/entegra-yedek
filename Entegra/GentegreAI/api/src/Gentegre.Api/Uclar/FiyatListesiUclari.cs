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
    /// <summary>Kopyalama istegi (540): ad verilmezse "Kopya &lt;ad&gt;".</summary>
    public sealed record KopyaIstegi(string? Ad);

    /// <summary>islem_log.tablo_id - KartKatalogu.FiyatListesi ile AYNI kod olmali.</summary>
    private const int LogTabloFiyatListesi = 923;

    /// <param name="Stok">Stok kalemleri fiyatlansin mi (varsayilan evet).</param>
    /// <param name="Hizmet">Hizmet kalemleri fiyatlansin mi (varsayilan evet).</param>
    public sealed record UretimIstegi(bool? Stok, bool? Hizmet);

    public sealed record UretimSonucu(int Eklenen, int Guncellenen, int Korunan,
                                      int Fiyatsiz, string Mesaj);

    /// <summary>
    /// TOPLU SATIR DEGERI (kullanici: "modalde seçili satıra / kategoriye /
    /// tüm listeye uygula"). Kapsam SUNUCUDA cozulur: satir gridi 200'erlik
    /// sayfalarla geliyor, "tüm listeye" istemcide yalnizca yuklu sayfayi
    /// degistirirdi - 14 bin satirlik listede sessiz bir yalan olurdu.
    /// </summary>
    /// <param name="Islem">carpan · katki · fiyat-yuzde</param>
    /// <param name="Deger">carpan sayisi · katki orani · yuzde (mutlak deger)</param>
    /// <param name="Kapsam">secili · kategori · tumu</param>
    /// <param name="SatirIdler">Kapsam "secili" iken satir id'leri.</param>
    /// <param name="KategoriId">Kapsam "kategori" iken dal (alt agac dahil).</param>
    /// <param name="Yon">fiyat-yuzde: artir · azalt</param>
    public sealed record TopluDegerIstegi(string Islem, decimal Deger, string Kapsam,
                                          int[]? SatirIdler, int? KategoriId, string? Yon);

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
        // ARAMA EKRANI FIYAT SUTUNU (495, kullanici: "stok/hizmet/ilaç arama
        //   ekranında fiyatları göreyim"): 25 satirlik arama sonucunun
        //   fiyatlari TEK istekte cozulur - satir basina ayri cagri arama
        //   penceresini kullanilamaz hale getirirdi.
        // ------------------------------------------------------- kopyala ----
        // POST /api/fiyat-listesi/{id}/kopyala
        //
        // "Listeyi Üret" 539'da anlamini yitirdi (taban liste zinciri kalkti);
        //   gercek ihtiyac var olan tarifeden yeni tarife turetmek: 2027
        //   listesi, kuruma ozel liste... Fiyatlar tasinir, sonra topluca
        //   zamlanir. KOPYA BAGIMSIZDIR - kaynak sonradan degisse etkilenmez.
        yol.MapPost("/api/fiyat-listesi/{id:int}/kopyala", async (
            int id, KopyaIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);

            await using var kontrol = baglanti.Komut(
                "select ad, coalesce(sube_id, 0) from public.fiyat_listesi where id = @p0",
                null, id);
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

            var yeniId = await baglanti.TekDegerAsync<int>(
                "select public.fn_fiyat_listesi_kopyala(@p0, @p1, @p2)",
                null, [id, istek?.Ad, baglam.KullaniciId], iptal);

            var satir = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.fiyat_listesi_satir where liste_id = @p0",
                null, [yeniId], iptal);

            return Results.Ok(new
            {
                id = yeniId,
                mesaj = $"\"{ad}\" kopyalandı - {satir:N0} satır.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------- SKRS'den SUT tazeleme ----
        // POST /api/fiyat-listesi/{id}/sut-guncelle
        //
        // SUT fiyati elle degismez (518/533 kilidi) - tek mesru yazma yolu
        //   budur. Fonksiyon SERVISE GITMEZ, `skrs_sut` ambarini okur (520):
        //   servis cagrisi yavas ve kesilebilir, ambar doluyken liste
        //   saniyeler icinde tazelenir.
        yol.MapPost("/api/fiyat-listesi/{id:int}/sut-guncelle", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            // Liste SUT tarifesinde mi: baska tarifenin fiyatini SKRS ile
            //   ezmek, elle girilmis Ozel fiyatlari sessizce silerdi.
            await using var kontrol = baglanti.Komut(
                "select ad, tarife_tipi, coalesce(sube_id, 0) "
                + "  from public.fiyat_listesi where id = @p0", null, id);
            string ad;
            int tip, subeId;
            await using (var o = await kontrol.ExecuteReaderAsync(iptal))
            {
                if (!await o.ReadAsync(iptal)) return Results.NotFound();
                ad = o.GetString(0);
                tip = o.GetInt16(1);
                subeId = o.GetInt32(2);
            }
            if (tip != 3)
                throw GentegreHatasi.IsKurali(
                    "SKRS güncellemesi yalnız SUT tarifesindeki listede yapılır.");
            if (subeId != 0 && baglam.SubeId is { } aktif && subeId != aktif)
                throw GentegreHatasi.Yasak("Bu liste başka bir şubeye ait.");

            await using var komut = baglanti.Komut(
                "select guncellenen, eslesmeyen, ambar from public.fn_fiyat_sut_yukle(@p0)",
                null, id);
            int guncellenen = 0, eslesmeyen = 0, ambar = 0;
            await using (var o = await komut.ExecuteReaderAsync(iptal))
                if (await o.ReadAsync(iptal))
                {
                    guncellenen = o.GetInt32(0);
                    eslesmeyen = o.GetInt32(1);
                    ambar = o.GetInt32(2);
                }

            return Results.Ok(new
            {
                liste = ad, guncellenen, eslesmeyen, ambar,
                mesaj = guncellenen == 0
                    ? $"Fiyatlar zaten güncel ({ambar:N0} SKRS kaydı tarandı)."
                    : $"{guncellenen:N0} satırın fiyatı SKRS'den güncellendi."
                      + (eslesmeyen > 0 ? $" {eslesmeyen:N0} satırın SKRS karşılığı yok." : ""),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // --------------------------------------------------- toplu deger ----
        // POST /api/fiyat-listesi/{id}/toplu-deger
        //
        // Carpan / Katki / Fiyat Güncelle pencerelerinin "uygula" dugmeleri.
        //   Kapsam ucu SUNUCUDA: satir gridi 200'erlik sayfalarla geliyor;
        //   "kategoriye" ya da "tüm listeye" uygula istemcide yalnizca yuklu
        //   sayfayi degistirirdi.
        // TARIFE KURALI BURADA DA ISLER (ekran gizlemesine guvenilmez):
        //   carpan yalniz TTB'de, katki TTB/SUT'ta, yuzde yalniz Özel'de.
        //   SUT fiyatinin tek mesru yazma yolu SKRS tazelemesidir (518/533).
        yol.MapPost("/api/fiyat-listesi/{id:int}/toplu-deger", async (
            int id, TopluDegerIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Degistir);

            var islem = (istek.Islem ?? "").Trim().ToLowerInvariant();
            var kapsam = (istek.Kapsam ?? "").Trim().ToLowerInvariant();
            if (islem is not ("carpan" or "katki" or "fiyat-yuzde"))
                throw GentegreHatasi.Dogrulama("Bilinmeyen toplu işlem.");
            if (kapsam is not ("secili" or "kategori" or "tumu"))
                throw GentegreHatasi.Dogrulama("Bilinmeyen kapsam.");
            if (istek.Deger <= 0)
                throw GentegreHatasi.Dogrulama("Değer sıfırdan büyük olmalı.");

            await using var baglanti = await veri.AcAsync(iptal);

            await using var kontrol = baglanti.Komut(
                "select ad, tarife_tipi, coalesce(sube_id, 0) "
                + "  from public.fiyat_listesi where id = @p0", null, id);
            string listeAdi;
            int tip, subeId;
            await using (var o = await kontrol.ExecuteReaderAsync(iptal))
            {
                if (!await o.ReadAsync(iptal)) return Results.NotFound();
                listeAdi = o.GetString(0);
                tip = o.GetInt16(1);
                subeId = o.GetInt32(2);
            }
            if (subeId != 0 && baglam.SubeId is { } aktif && subeId != aktif)
                throw GentegreHatasi.Yasak("Bu liste başka bir şubeye ait.");

            if (islem == "carpan" && tip != 2)
                throw GentegreHatasi.IsKurali("Çarpan yalnız TTB/HUV tarifesinde yazılır.");
            if (islem == "katki" && tip is not (2 or 3))
                throw GentegreHatasi.IsKurali("Katkı yalnız TTB/HUV ve SUT tarifesinde yazılır.");
            if (islem == "fiyat-yuzde" && tip != 1)
                throw GentegreHatasi.IsKurali(
                    "Yüzdeyle fiyat güncelleme yalnız Özel tarifede yapılır. "
                    + "TTB fiyatı katsayı × çarpandan, SUT fiyatı SKRS'den doğar.");

            // ATAMA: istemcideki kuralin AYNISI (tarifeKurallari.ts) - iki
            //   yerde iki sonuc cikmasin. Yuvarlama iki hane.
            var atama = islem switch
            {
                // Katsayi ya da carpan yoksa fiyat DOKUNULMAZ: 0 fiyat yazmak
                //   satiri sessizce bedelsiz yapardi (ttbFiyatTuret ile ayni).
                "carpan" => "carpan = @p1, "
                          + "fiyat = case when coalesce(taban_fiyat, 0) > 0 "
                          + "             then round(coalesce(taban_fiyat, 0) * @p1, 2) "
                          + "             else fiyat end",
                "katki" => "katki_tutar = round(coalesce(fiyat, 0) * @p1, 2)",
                // Eksiye dusmesin: %120 azalt negatif fiyat uretirdi.
                _ => "fiyat = greatest(0, round(coalesce(fiyat, 0) * @p1, 2))",
            };
            // Yuzde katsayiya cevrilir; yon istemciden gelir ama DEGER hep pozitif.
            var deger = islem == "fiyat-yuzde"
                ? 1 + (string.Equals(istek.Yon, "azalt", StringComparison.OrdinalIgnoreCase)
                       ? -istek.Deger : istek.Deger) / 100m
                : istek.Deger;
            if (islem == "fiyat-yuzde" && deger < 0) deger = 0m;

            int etkilenen;
            if (kapsam == "kategori")
            {
                if (istek.KategoriId is not > 0)
                    throw GentegreHatasi.Dogrulama("Kategori seçilmedi.");
                // Dal ALT AGACIYLA birlikte: "Tahlil" secen kullanici
                //   altindaki Biyokimya/Hormon satirlarini da kastediyor.
                await using var komut = baglanti.Komut(
                    "with recursive dal as ("
                    + "    select @p2::integer as id "
                    + "    union all "
                    + "    select k.id from public.kategori k join dal d on k.ust_id = d.id) "
                    + "update public.fiyat_listesi_satir s set " + atama
                    + " where s.liste_id = @p0 "
                    + "   and coalesce("
                    + "        (select h.kategori from public.hizmet h where h.id = s.hizmet_id), "
                    + "        (select t.kategori from public.stok   t where t.id = s.stok_id)) "
                    + "       in (select id from dal)",
                    null, id, deger, istek.KategoriId.Value);
                etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            }
            else if (kapsam == "secili")
            {
                var idler = (istek.SatirIdler ?? []).Where(x => x > 0).Distinct().ToArray();
                if (idler.Length == 0)
                    throw GentegreHatasi.Dogrulama("Seçili satır yok.");
                await using var komut = baglanti.Komut(
                    "update public.fiyat_listesi_satir s set " + atama
                    + " where s.liste_id = @p0 and s.id = any(@p2)",
                    null, id, deger, idler);
                etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            }
            else
            {
                await using var komut = baglanti.Komut(
                    "update public.fiyat_listesi_satir s set " + atama
                    + " where s.liste_id = @p0", null, id, deger);
                etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            }

            var isAdi = islem switch
            {
                "carpan" => $"çarpan {istek.Deger:0.####}",
                "katki" => $"katkı oranı {istek.Deger:0.####}",
                _ => $"fiyat %{istek.Deger:0.##} "
                     + (string.Equals(istek.Yon, "azalt", StringComparison.OrdinalIgnoreCase)
                        ? "azaltma" : "artırma"),
            };
            var kapsamAdi = kapsam switch
            {
                "secili" => "seçili satırlar",
                "kategori" => "seçili kategori",
                _ => "listenin tamamı",
            };
            var mesaj = etkilenen == 0
                ? $"Değişen satır yok ({kapsamAdi})."
                : $"{etkilenen:N0} satıra uygulandı - {isAdi} · {kapsamAdi}.";

            // TOPLU FIYAT DEGISIMI LOGLANIR: tek satirlik duzeltmeden farkli
            //   olarak binlerce satiri birden degistiriyor - "bu listeye ne
            //   oldu" sorusu sonradan cevaplanabilmeli.
            await log.YazAsync(baglanti, null!, LogIslemi.Degistir, LogTabloFiyatListesi, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["toplu"] = mesaj }, iptal: iptal);

            return Results.Ok(new
            {
                liste = listeAdi, etkilenen, mesaj, izlemeNo = baglam.IzlemeNo
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        yol.MapPost("/api/fiyat-listesi/{id:int}/fiyatlar", async (
            int id, TopluFiyatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("fiyat_listesi", Islem.Gor);

            var kalemler = (istek.Kalemler ?? []).Take(200).ToList();
            await using var baglanti = await veri.AcAsync(iptal);
            var sonuc = new List<object>(kalemler.Count);
            foreach (var k in kalemler)
            {
                if ((k.StokId is null or 0) == (k.HizmetId is null or 0)) continue;
                var stok = k.StokId is 0 ? null : k.StokId;
                var hizmet = k.HizmetId is 0 ? null : k.HizmetId;
                var f = await ListeFiyatiAsync(baglanti, id, stok, hizmet, iptal);
                // SUT BEDELI (602): sozlesme verildiyse cozulur. Ayni yardimci
                //   (`SutBedeliAsync`) kalem ucunun kullandigidir - listede
                //   gorulen rakam, kalem secilince cikanla ayni olsun.
                var sut = (istek.SozlesmeId is > 0 || istek.KurumId is > 0)
                    ? await SutBedeliAsync(baglanti, istek.SozlesmeId, istek.KurumId,
                                           istek.SgkKullan, stok, hizmet, iptal)
                    : SutBedeli.Yok;
                sonuc.Add(new
                {
                    stokId = k.StokId, hizmetId = k.HizmetId,
                    fiyat = f.Fiyat, dovizCinsi = f.DovizCinsi, kdvDahil = f.KdvDahil,
                    // SGK'nin odedigi bedel - rota SGK payi tasimiyorsa null.
                    sgkFiyat = sut.SgkGerekli ? sut.SgkFiyat : null,
                    // KATKI DA DONER (602, kullanici: "stok hizmet arama
                    //   listesinde Katkı fiyatı da göster"): TTB/SUT tarifesinde
                    //   hastanin odeyecegi tutar budur ve secim YAPILMADAN
                    //   gorunmeli. `ListeFiyatiAsync` zaten cozuyordu, tekil uc
                    //   de donuyordu - yalniz toplu uc birakmisti.
                    katki = f.Katki,
                });
            }
            return Results.Ok(new { listeId = id, satirlar = sonuc });
        }).WithTags("FiyatListesi").RequireAuthorization();

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
            // KATILIM PAYI (291) fiyatla BIRLIKTE doner: islem secilince hem SUT
            //   bedeli hem hastadan alinacak katki tek istekte gelsin.
            var f = await ListeFiyatiAsync(baglanti, id,
                stokId is 0 ? null : stokId, hizmetId is 0 ? null : hizmetId, iptal);

            return Results.Ok(new
            {
                fiyat = f.Fiyat, dovizCinsi = f.DovizCinsi, kdvDahil = f.KdvDahil,
                kaynak = f.Kaynak, katki = f.Katki,
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

            // ODEME ROTASI ayni cevapta (478): ekran "bu kurumda pay nasil
            //   bolunur" bilgisini kampanyayla BIRLIKTE ogrensin. Rota
            //   SOZLESMEDEN cikar (tur + alt kurum); eski `paylasim_modu`
            //   kolonu dustu - kurumun tek bir pay kurali yok, sozlesmesi var.
            short rota = 1;
            decimal varsayilanKarsilama = 0;
            int? sozlesme = null;
            if (kurumId is > 0)
            {
                await using var pk = baglanti.Komut(
                    "select s.id, public.fn_dagilim_rota(k.tur, s.alt_kurum, 1::smallint), " +
                    "       s.varsayilan_karsilama " +
                    "  from public.taraf_kurum k " +
                    "  left join public.kurum_sozlesme s " +
                    "         on s.id = public.fn_kurum_sozlesme_sec(k.id) " +
                    " where k.id = @p0", null, kurumId);
                await using var po = await pk.ExecuteReaderAsync(iptal);
                if (await po.ReadAsync(iptal))
                {
                    sozlesme = po.IsDBNull(0) ? null : po.GetInt32(0);
                    rota = po.IsDBNull(1) ? (short)1 : po.GetInt16(1);
                    varsayilanKarsilama = po.IsDBNull(2) ? 0 : po.GetDecimal(2);
                }
            }

            return Results.Ok(new { kampanyaId, kod, ad, fiyatListesiId = kampanyaListesi,
                                    rota, sozlesmeId = sozlesme, varsayilanKarsilama });
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
            int? sozlesmeId, short? sgkKullan,
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
            var liste = bazListe is { } bl
                ? await ListeFiyatiAsync(baglanti, bl, stok, hizmet, iptal)
                : ListeFiyati.Bos;
            var bazFiyat   = liste.Fiyat;
            var dovizCinsi = liste.DovizCinsi;
            var kdvDahil   = liste.KdvDahil;
            var kaynak     = liste.Kaynak;
            var katki      = liste.Katki;

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

            // 4) SGK (SUT) BEDELI (483). TSS / Karma / SGK rotalarinda satirda
            //    IKI fiyat calisir: SGK'nin odedigi SUT bedeli ve tarife bedeli.
            //    Ekran yalniz tarife bedelini soruyordu; SUT listesi bossa SGK
            //    payi sessizce sifir kaliyordu (kullanici: "sgk sut fiyatini da
            //    bulup atmasi gerekirdi, yoksa ekrandan almasi gerekir").
            //    Burada bulunani doneriz, BULAMAZSAK ekran sorar.
            var sut = await SutBedeliAsync(baglanti, sozlesmeId, kurumId, sgkKullan,
                                           stok, hizmet, iptal);

            return Results.Ok(new
            {
                fiyat,
                bazFiyat,
                dovizCinsi,
                kdvDahil,
                kaynak = satirId is null ? kaynak : "kampanya",
                // Katilim payi (291): SGK modunda hasta payi bu tutardir.
                katki,
                kampanyaId,
                listeId = bazListe,
                satirId,
                tip,
                iskontoTipi,
                iskonto,
                // --- SGK / SUT (483) ---
                rota = sut.Rota,
                // SGK payi bu rotada var mi: ekran SUT kutusunu buna gore acar.
                sgkGerekli = sut.SgkGerekli,
                // Cozulen SUT bedeli - null ise LISTEDE YOK, ekran soracak.
                sgkFiyat = sut.SgkFiyat,
                sgkListesiId = sut.SgkListesiId,
                sgkKdvDahil = sut.SgkKdvDahil,
                // SUT listesinin katilim payi (hastadan alinir, ciro disi).
                sgkKatilim = sut.SgkKatilim,
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ------------------------------------------- belgenin varsayilan listesi ----
        // Belge acilirken hangi liste gelecek: belge TURUNUN yonune gore
        //   carinin listesi, yoksa o yonun varsayilani.
        // SOZLESME (588): basvuruda police SECILIYSE tarife ONDAN cikar -
        //   kurumun birden fazla policesi varsa (ÖSS + TSS + Karma) kurum
        //   basina secim yapilamiyor, secili police ise kesin bilgidir.
        yol.MapGet("/api/belge/varsayilan-liste", async (
            int tur, int tarafId, int? kurumId, int? sozlesmeId,
            BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                select l.id, l.ad, l.yon, l.kdv_dahil
                  from public.fiyat_listesi l
                 where l.id = public.fn_belge_varsayilan_liste(@p0, @p1, current_date, @p2, @p3)
                """, null, tur, tarafId, kurumId is 0 ? null : kurumId,
                     sozlesmeId is 0 ? null : sozlesmeId);

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
    /// Kalemin SGK (SUT) tarafi - 483. `SgkFiyat` null ise SOZLESMENIN SUT
    /// LISTESINDE O KALEM YOK: ekran bedeli kullanicidan ister, yoksa SGK payi
    /// sifir kalir ve tutarin tamami sigortaya/hastaya yazilir.
    /// </summary>
    private sealed record SutBedeli(
        short Rota, bool SgkGerekli, decimal? SgkFiyat, int? SgkListesiId,
        short SgkKdvDahil, decimal SgkKatilim)
    {
        /// <summary>Kurum/sozlesme yok: ozel hasta - SGK payi da yok.</summary>
        public static SutBedeli Yok => new(1, false, null, null, 0, 0m);
    }

    /// <summary>
    /// Sozlesmenin SUT listesinden kalemin SGK bedelini cozer (483).
    ///
    /// Rota SOZLESMEDEN cikar (kurum turu + alt kurum + "SGK katkisi
    /// kullanilsin"); SGK payi yalniz TSS (3), Karma (4) ve SGK (5)
    /// rotalarinda vardir. Oteki rotalarda kutu hic acilmaz - olmayan bir
    /// bedeli sormak, kullaniciyi yanlis yere sayi yazmaya davet eder.
    /// </summary>
    private static async Task<SutBedeli> SutBedeliAsync(
        Npgsql.NpgsqlConnection baglanti, int? sozlesmeId, int? kurumId,
        short? sgkKullan, int? stokId, int? hizmetId, CancellationToken iptal)
    {
        if (sozlesmeId is not > 0 && kurumId is not > 0) return SutBedeli.Yok;

        short rota = 1;
        int? sutListesi = null;
        await using (var komut = baglanti.Komut(
            "select public.fn_dagilim_rota(k.tur, coalesce(s.alt_kurum, 0)::smallint, " +
            "                              coalesce(@p2, 1)::smallint), " +
            "       s.sgk_fiyat_listesi_id " +
            "  from public.kurum_sozlesme s " +
            "  join public.taraf_kurum k on k.id = s.kurum_id " +
            " where s.id = coalesce(@p0, public.fn_kurum_sozlesme_sec(@p1))",
            null, sozlesmeId is 0 ? null : sozlesmeId, kurumId is 0 ? null : kurumId,
            sgkKullan))
        {
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) return SutBedeli.Yok;
            rota       = o.IsDBNull(0) ? (short)1 : o.GetInt16(0);
            sutListesi = o.IsDBNull(1) ? null : o.GetInt32(1);
        }

        var gerekli = rota is 3 or 4 or 5;
        if (!gerekli) return new SutBedeli(rota, false, null, sutListesi, 0, 0m);
        if (sutListesi is not { } liste)
            // Sozlesmede SUT listesi hic secilmemis: bedel yalniz ekrandan gelebilir.
            return new SutBedeli(rota, true, null, null, 0, 0m);

        var f = await ListeFiyatiAsync(baglanti, liste, stokId, hizmetId, iptal);
        // Fiyat 0 da "yok" sayilir: SUT listesinde 0 TL'lik satir, unutulmus
        //   satirdir - kullaniciya sorulmasi dogru olan durumdur.
        var fiyat = f.Fiyat is > 0 ? f.Fiyat : null;
        return new SutBedeli(rota, true, fiyat, liste, f.KdvDahil, f.Katki);
    }

    /// <summary>Listeden cozulen fiyat + katilim payi (291).</summary>
    private sealed record ListeFiyati(
        decimal? Fiyat, string DovizCinsi, short KdvDahil, string Kaynak, decimal Katki)
    {
        public static ListeFiyati Bos => new(null, "", 0, "yok", 0m);
    }

    /// <summary>
    /// Bir kalemin LISTE fiyatini ve KATILIM PAYINI tek sorguda cozer.
    ///
    /// Iki uc de (tek kalem sorgusu ve kampanyali kalem ucu) ayni ikiliye
    /// ihtiyac duyuyor; sorguyu iki yerde tutmak katki zincirini (291) birinde
    /// guncelleyip digerinde unutmaya davetti.
    /// </summary>
    /// <summary>Toplu fiyat sorgusu (495) - arama ekraninin fiyat sutunu.</summary>
    public sealed class TopluFiyatIstegi
    {
        public List<TopluFiyatKalemi>? Kalemler { get; set; }
        /// <summary>
        /// SUT BEDELI ICIN SOZLESME (602, kullanici: "stok hizmet arama
        /// listesinde Katkı ve sut fiyatı da göster"). Verilirse her satirin
        /// SGK bedeli de cozulur - arama listesindeki "Fiyat" BELGENIN
        /// listesinden gelir ve TSS'de o TTB tarifesidir, SUT hic gorunmezdi.
        /// Verilmezse SUT kolonu bos doner, eski davranis surer.
        /// </summary>
        public int? SozlesmeId { get; set; }
        public int? KurumId { get; set; }
        public short? SgkKullan { get; set; }
    }

    public sealed class TopluFiyatKalemi
    {
        public int? StokId { get; set; }
        public int? HizmetId { get; set; }
    }

    private static async Task<ListeFiyati> ListeFiyatiAsync(
        Npgsql.NpgsqlConnection baglanti, int listeId, int? stokId, int? hizmetId,
        CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            // ROUND(...,4): turetilmis listede carpan bolunemeyen bir ondalik
            //   uretebiliyor (900 x 0,8 / 1,10 gibi) ve ham numeric
            //   System.Decimal'e sigmiyordu ("Numeric value does not fit").
            //   Para alanlari zaten dort haneyle saklanir.
            "select round(f.fiyat, 4) as fiyat, f.doviz_cinsi, f.kdv_dahil, f.kaynak, " +
            "       public.fn_fiyat_listesi_katki(@p0, @p1, @p2) as katki " +
            "  from public.fn_fiyat_listesi_fiyat(@p0, @p1, @p2) f",
            null, listeId, stokId, hizmetId);

        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) return ListeFiyati.Bos;

        return new ListeFiyati(
            o.IsDBNull(0) ? null : o.GetDecimal(0),
            o.IsDBNull(1) ? "" : o.GetString(1),
            o.IsDBNull(2) ? (short)0 : o.GetInt16(2),
            o.IsDBNull(3) ? "" : o.GetString(3),
            o.IsDBNull(4) ? 0m : o.GetDecimal(4));
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
