using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATIS FIYAT LISTESI uclari (201/202).
///
/// Listenin kendisi ve satirlari GENERIC kart uclarindan yonetilir
/// (/api/kart/satis-listesi); burada yalnizca kart sozlesmesine sigmayan iki
/// islem var: listeyi URETMEK ve tek kalemin fiyatini SORMAK.
/// </summary>
public static class FiyatListesiUclari
{
    /// <summary>islem_log.tablo_id - KartKatalogu.SatisListesi ile AYNI kod olmali.</summary>
    private const int LogTabloFiyatListesi = 923;

    /// <param name="Stok">Stok kalemleri fiyatlansin mi (varsayilan evet).</param>
    /// <param name="Hizmet">Hizmet kalemleri fiyatlansin mi (varsayilan evet).</param>
    public sealed record UretimIstegi(bool? Stok, bool? Hizmet);

    /// <param name="ListeId">Uygulanacak liste; bos ise belgenin kendi listesi.</param>
    public sealed record FiyatlandirIstegi(int? ListeId);

    public sealed record UretimSonucu(int Eklenen, int Guncellenen, int Korunan,
                                      int Fiyatsiz, string Mesaj);

    public static void FiyatListesiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // ------------------------------------------------------------ uret ----
        // Listeyi MATERYALIZE eder. Ayri yetki (satis_listesi.uret): binlerce
        //   satir yazar ve taban liste degistiyse fiyatlari toptan degistirir.
        yol.MapPost("/api/satis-listesi/{id:int}/uret", async (
            int id, UretimIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("satis_listesi.uret");

            await using var baglanti = await veri.AcAsync(iptal);

            // Liste var mi + hangi subeye ait: baska subenin listesini uretmek
            //   sessiz bir veri sizintisi olurdu.
            await using var kontrol = baglanti.Komut(
                "select ad, coalesce(sube_id, 0) from public.satis_listesi where id = @p0", null, id);
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
                "select eklenen, guncellenen, korunan, fiyatsiz from public.fn_satis_listesi_uret(@p0, @p1, @p2, @p3)",
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
        yol.MapGet("/api/satis-listesi/{id:int}/fiyat", async (
            int id, int? stokId, int? hizmetId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satis_listesi", Islem.Gor);

            if ((stokId is null or 0) == (hizmetId is null or 0))
                throw GentegreHatasi.Dogrulama("stokId ya da hizmetId'den TAM BIRI verilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "select fiyat, doviz_cinsi, kdv_dahil, kaynak from public.fn_satis_listesi_fiyat(@p0, @p1, @p2)",
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

        // ------------------------------------------- belgenin varsayilan listesi ----
        // Belge acilirken hangi liste gelecek: belge TURUNUN yonune gore
        //   carinin listesi, yoksa o yonun varsayilani.
        yol.MapGet("/api/belge/varsayilan-liste", async (
            int tur, int tarafId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                select l.id, l.ad, l.yon, l.kdv_dahil
                  from public.satis_listesi l
                 where l.id = public.fn_belge_varsayilan_liste(@p0, @p1)
                """, null, tur, tarafId);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                return Results.Ok(new { listeId = (int?)null, ad = "", yon = 0, kdvDahil = 0 });

            return Results.Ok(new
            {
                listeId = (int?)o.GetInt32(0), ad = o.GetString(1),
                yon = (int)o.GetInt16(2), kdvDahil = (int)o.GetInt16(3),
            });
        }).WithTags("FiyatListesi").RequireAuthorization();

        // ---------------------------------------------------- belgeyi fiyatla ----
        // Liste degisince TUM satirlar yeniden fiyatlanir. Listede bulunmayan
        //   kalemin satirina DOKUNULMAZ ve sayisi kullaniciya bildirilir -
        //   sessizce 0 TL yazmak faturayi bozardi.
        yol.MapPost("/api/belge/{id:int}/fiyatlandir", async (
            int id, FiyatlandirIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "select degisen, ayni, bulunamayan, liste_adi from public.fn_belge_fiyatlandir(@p0, @p1, @p2)",
                null, id, istek?.ListeId, baglam.KullaniciId);

            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.IsKurali("Belge fiyatlanamadi.");

            var degisen = o.GetInt32(0);
            var ayni = o.GetInt32(1);
            var yok = o.GetInt32(2);
            var listeAdi = o.IsDBNull(3) ? "" : o.GetString(3);

            var mesaj = $"\"{listeAdi}\": {degisen} satırın fiyatı değişti, {ayni} satır aynı kaldı.";
            if (yok > 0) mesaj += $" {yok} kalem listede bulunamadı, fiyatı DEĞİŞMEDİ.";

            return Results.Ok(new { degisen, ayni, bulunamayan = yok, listeAdi, mesaj });
        }).WithTags("FiyatListesi").RequireAuthorization();
    }
}
