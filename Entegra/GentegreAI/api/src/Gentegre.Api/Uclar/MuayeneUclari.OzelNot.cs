using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KENDİME NOT (1098) — bkz. <c>MuayeneUclari</c>.
///
/// <para>Not hekim-hasta çiftine bağlıdır; muayene yalnız hastayı bulmak için
/// kullanılır. Kullanıcı <b>oturumdan</b> gelir, istekten alınmaz: başkasının
/// notunu okumanın yolu yoktur. Boş metin satırı siler.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void OzelNotUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/ozel-not - oturumdaki kullanıcının bu hastaya notu
        grup.MapGet("/{id:int}/ozel-not", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var baglanti = await veri.AcAsync(iptal);
            var satir = await baglanti.ListeAsync(
                "select n.metin, n.degistirme_tarihi as \"degistirme\" " +
                "  from public.muayene m " +
                "  join public.hekim_ozel_not n on n.hasta_id = m.taraf_id and n.kullanici_id = @p1 " +
                " where m.id = @p0",
                null, [id, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var s = satir.FirstOrDefault();
            return Results.Ok(new { metin = s?["metin"] ?? "", degistirme = s?["degistirme"] });
        });

        // PUT /api/muayene/{id}/ozel-not - yaz (boş metin = sil)
        grup.MapPut("/{id:int}/ozel-not", async (
            int id, OzelNotIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // YAZMA = DEĞİŞTİR (kod inceleme 30.10.2026 K16): not yazmak salt okuma yetkisiyle yürüyordu.
            baglam.YetkiIste("muayene", Islem.Degistir);
            var metin = (istek.Metin ?? "").Trim();
            if (metin.Length > 4000)
                throw GentegreHatasi.Dogrulama("Not en fazla 4000 karakter olabilir.",
                    [new("metin", "En fazla 4000 karakter.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            var hastaId = await baglanti.TekDegerAsync<int?>(
                "select taraf_id from public.muayene where id = @p0", null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi();

            if (metin.Length == 0)
                await baglanti.CalistirAsync(
                    "delete from public.hekim_ozel_not where kullanici_id = @p0 and hasta_id = @p1",
                    null, [baglam.KullaniciId, hastaId], iptal);
            else
                await baglanti.CalistirAsync(
                    "insert into public.hekim_ozel_not (kullanici_id, hasta_id, metin) values (@p0, @p1, @p2) " +
                    "on conflict (kullanici_id, hasta_id) do update set metin = excluded.metin, degistirme_tarihi = now()",
                    null, [baglam.KullaniciId, hastaId, metin], iptal);

            return Results.Ok(new { metin, izlemeNo = baglam.IzlemeNo });
        });
    }

    public sealed record OzelNotIstegi(string? Metin);
}
