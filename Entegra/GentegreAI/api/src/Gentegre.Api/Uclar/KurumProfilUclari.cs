using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KURUM PROFILI (359) - Yönetim &gt; Kurum Profili. Subenin profili +
/// tip/modul kataloglari + kurulum adimlarinin canli durumu (490).
/// </summary>
public static class KurumProfilUclari
{
    /// <summary>Kategori aciklik istegi (527).</summary>
    public sealed record KategoriIstegi(int Id, int Aktif);

    public sealed record ProfilIstegi(
        int? UrunModu, string? KurumTipi, string? AltTip, string? Basamak, string? TesisKodu,
        int? SubeYapisi, int? HekimSayisi, int? UniteSayisi, string? Dil, string? ParaBirimi,
        Dictionary<string, int>? Moduller,
        /// <summary>Hangi subenin profili (364). Verilmezse AKTIF sube; 0 = kurum geneli.</summary>
        int? SubeId);

    public static void KurumProfilUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-profil").WithTags("KurumProfil").RequireAuthorization();

        // OKUMA yetki istemez: modul gorunurlugu ekranlarin DAVRANISINI belirler
        //   (menu, kart sekmeleri) - ayar okumasiyla ayni gerekce.
        // `sube` verilmezse AKTIF SUBE okunur; 0 acikca verilirse kurum geneli.
        grup.MapGet("/", async (
            int? sube, BaglamCozucu cozucu, KurumProfilDeposu depo, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var subeId = sube ?? baglam.SubeId ?? 0;
            var (profil, tipler, moduller, matris, kurulum, entegrasyonlar, kategoriler) =
                await depo.OkuAsync(subeId, iptal);
            return Results.Ok(new { profil, tipler, moduller, matris, kurulum, entegrasyonlar,
                                    kategoriler, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------ kategoriler ----
        // PUT /api/kurum-profil/kategori  { "id": 7, "aktif": 0 }
        //
        // KATEGORI ANAHTAR, HIZMET ONU IZLER (527, kullanici: "ikisi de pasif
        //   olsun veya aktif"): kategori kapaninca altindaki hizmet/stoklar da
        //   kapanir - yayilimi DB tetigi yapar, burada tek satir yazilir.
        grup.MapPut("/kategori", async (
            KategoriIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var etkilenen = await baglanti.CalistirAsync(
                "update public.kategori set aktif = @p1 where id = @p0 and aktif <> @p1",
                null, [istek.Id, istek.Aktif == 0 ? 0 : 1], iptal);
            if (etkilenen == 0 && !await baglanti.TekDegerAsync<bool>(
                    "select exists (select 1 from public.kategori where id = @p0)",
                    null, [istek.Id], iptal))
                throw GentegreHatasi.Bulunamadi("Kategori bulunamadı.");

            return Results.Ok(new { istek.Id, istek.Aktif, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/kurum-profil/kategori-uygula  -> secili tipin onerilen seti
        grup.MapPost("/kategori-uygula", async (
            BaglamCozucu cozucu, KurumProfilDeposu depo, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            var (profil, _, _, _, _, _, _) = await depo.OkuAsync(baglam.SubeId ?? 0, iptal);
            await using var baglanti = await veri.AcAsync(iptal);
            var degisen = await baglanti.TekDegerAsync<int>(
                "select public.fn_kurum_kategori_uygula(@p0)", null, [profil.KurumTipi], iptal);

            return Results.Ok(new
            {
                kurumTipi = profil.KurumTipi, degisen,
                mesaj = $"{profil.KurumTipi} profiline göre {degisen} kategori güncellendi.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        grup.MapPut("/", async (
            ProfilIstegi istek, BaglamCozucu cozucu, KurumProfilDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);

            // Eksik alanlar MEVCUT degeri korur: ekran tek sekmeyi kaydederken
            //   otekilerin degerini sifirlamasin.
            // Hedef sube: istekte gelen, yoksa aktif sube (0 = kurum geneli).
            var subeId = istek.SubeId ?? baglam.SubeId ?? 0;
            var (mevcut, _, _, _, _, _, _) = await depo.OkuAsync(subeId, iptal);
            var yeni = new KurumProfil(
                istek.UrunModu    ?? mevcut.UrunModu,
                istek.KurumTipi   ?? mevcut.KurumTipi,
                istek.AltTip      ?? mevcut.AltTip,
                istek.Basamak     ?? mevcut.Basamak,
                istek.TesisKodu   ?? mevcut.TesisKodu,
                istek.SubeYapisi  ?? mevcut.SubeYapisi,
                istek.HekimSayisi ?? mevcut.HekimSayisi,
                istek.UniteSayisi ?? mevcut.UniteSayisi,
                istek.Dil         ?? mevcut.Dil,
                istek.ParaBirimi  ?? mevcut.ParaBirimi,
                istek.Moduller    ?? mevcut.Moduller,
                subeId);

            var sonuc = await depo.YazAsync(yeni, baglam.Yazma, iptal);
            return Results.Ok(new { profil = sonuc, izlemeNo = baglam.IzlemeNo });
        });
    }
}
