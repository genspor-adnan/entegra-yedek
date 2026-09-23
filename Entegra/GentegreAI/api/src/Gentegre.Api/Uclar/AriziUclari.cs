using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ARIZA / TALEP (hizmet masası, 911). Demirbaş-bağımsız genel arıza bildirimi:
///   * <b>Herkes</b> self-servis talep açar (yetki <c>ariza.talep</c>) - kategori
///     seçer, sistem SORUMLU EKİBE yönlendirir.
///   * <b>Ekip</b> (yetki <c>ariza</c>) devralır → çözer → kapatır.
/// Liste ve kart KaynakKatalogu üzerinden; buradaki uçlar AKIŞ aksiyonlarıdır.
/// </summary>
public static class AriziUclari
{
    public sealed record TalepIstegi(short Kategori, string Aciklama, string? Konum,
                                     short? Oncelik, int? DemirbasId);
    public sealed record AtaIstegi(int SorumluId);
    public sealed record CozIstegi(string Notu);

    public static void ArizaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ariza").WithTags("Arıza / Talep").RequireAuthorization();

        // SEÇENEKLER: self-servis form kategori + öncelik listeleri (kod_deger).
        //   Liste DB'de tek yerde; formda sabitlenirse ikisi bir gün ayrışır.
        grup.MapGet("/secenekler", async (VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            Task<List<object>> Liste(string liste) => b.ListeAsync("""
                    select d.deger, d.ad
                      from public.kod_deger d
                      join public.kod_liste l on l.id = d.liste_id
                     where l.kod = @p0 and d.dil = 0 and d.deger > 0
                     order by d.deger
                    """, null, [liste],
                r => (object)new { deger = r.GetInt32(0), ad = r.GetString(1) }, iptal);
            return Results.Ok(new { kategoriler = await Liste("ariza.kategori"),
                                    oncelikler = await Liste("ariza.oncelik") });
        });

        // SELF-SERVİS AÇIŞ: herkes (ariza.talep). Kategori -> ekip yönlendirmesi
        //   fn_ariza_talep_ac içinde; talep_eden = oturum kişisi.
        grup.MapPost("/talep", async (TalepIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza.talep", Islem.Ekle);
            if (istek.Kategori <= 0) throw GentegreHatasi.IsKurali("Arıza kategorisi seçilmeli.");
            if (string.IsNullOrWhiteSpace(istek.Aciklama)) throw GentegreHatasi.IsKurali("Açıklama zorunlu.");

            await using var b = await veri.AcAsync(iptal);
            var id = await b.TekDegerAsync<int>("""
                select public.fn_ariza_talep_ac(@p0::smallint, @p1, @p2, @p3::smallint, @p4, @p5, @p6)
                """, null,
                [istek.Kategori, istek.Aciklama.Trim(), istek.Konum?.Trim() ?? "",
                 istek.Oncelik ?? (short)2, istek.DemirbasId, baglam.KullaniciId, baglam.SubeId ?? 0], iptal);
            var no = await b.TekDegerAsync<string>(
                "select talep_no from public.ariza_talep where id = @p0", null, [id], iptal);
            return Results.Ok(new { id, talepNo = no, mesaj = $"Arıza kaydı açıldı: {no}",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // EKİP DEVRALIR: sorumlu = ben, durum İşlemde (yetki ariza).
        grup.MapPost("/{id:int}/devral", async (int id, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.ariza_talep
                   set sorumlu_id = @p1, durum = 3, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum in (1,2)
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Talep zaten devralınmış ya da kapanmış.");
            return Results.Ok(new { id, mesaj = "Talep devralındı (İşlemde).", izlemeNo = baglam.IzlemeNo });
        });

        // ATA: başka bir personele ata, durum Atandı (yetki ariza).
        grup.MapPost("/{id:int}/ata", async (int id, AtaIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            if (istek.SorumluId <= 0) throw GentegreHatasi.IsKurali("Sorumlu personel seçilmeli.");
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.ariza_talep
                   set sorumlu_id = @p1, durum = case when durum < 2 then 2 else durum end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum not in (5,0)
                """, null, [id, istek.SorumluId, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Kapanmış talep atanamaz.");
            return Results.Ok(new { id, mesaj = "Sorumlu atandı.", izlemeNo = baglam.IzlemeNo });
        });

        // ÇÖZ: durum Çözüldü, çözüm notu (yetki ariza).
        grup.MapPost("/{id:int}/coz", async (int id, CozIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            if (string.IsNullOrWhiteSpace(istek.Notu)) throw GentegreHatasi.IsKurali("Çözüm notu zorunlu.");
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.ariza_talep
                   set durum = 4, cozum_notu = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum not in (5,0)
                """, null, [id, istek.Notu.Trim(), baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Talep kapanmış ya da iptal.");
            return Results.Ok(new { id, mesaj = "Talep çözüldü.", izlemeNo = baglam.IzlemeNo });
        });

        // KAPAT: durum Kapandı (yetki ariza).
        grup.MapPost("/{id:int}/kapat", async (int id, VeriKaynagi veri,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ariza", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.ariza_talep
                   set durum = 5, kapanis_tarihi = now(), degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum not in (5,0)
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Talep zaten kapalı.");
            return Results.Ok(new { id, mesaj = "Talep kapatıldı.", izlemeNo = baglam.IzlemeNo });
        });
    }
}
