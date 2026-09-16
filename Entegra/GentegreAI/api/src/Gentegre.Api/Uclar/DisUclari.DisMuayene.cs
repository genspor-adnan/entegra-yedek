using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DİŞ MUAYENESİ / DENTAL ANAMNEZ (kullanıcı: "dental anamnez nereden
/// girilecek"). <c>dis_muayene</c> için ayrı liste/kart yok; hasta kartı
/// (odontogram) başlığındaki alan doğrudan düzenlenir. Hastanın SON diş
/// muayene satırı güncellenir, yoksa yeni satır açılır (muayene bağı yok -
/// genel muayene kullanılmayan diş kurulumu için).
/// </summary>
public static partial class DisUclari
{
    public sealed record DisMuayeneIstegi(string? DentalAnamnez, bool? Bruksizm, bool? Sigara, string? HijyenDurum,
                                          string? TmeBulgu, int? OkluzyonSinif, int? Dentisyon);

    private static void DisMuayeneUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapPatch("/hasta/{hastaId:int}/dis-muayene", async (
            int hastaId, DisMuayeneIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.hasta", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sonId = await b.TekDegerAsync<int?>(
                "select id from public.dis_muayene where hasta_id = @p0 order by id desc limit 1", null, [hastaId], iptal);
            int id;
            if (sonId is int s)
            {
                id = s;
                await b.CalistirAsync("""
                    update public.dis_muayene
                       set dental_anamnez = coalesce(@p1, dental_anamnez),
                           bruksizm = coalesce(@p2, bruksizm), sigara = coalesce(@p3, sigara),
                           hijyen_durum = coalesce(@p4, hijyen_durum), tme_bulgu = coalesce(@p5, tme_bulgu),
                           okluzyon_sinif = coalesce(@p6, okluzyon_sinif), dentisyon = coalesce(@p7, dentisyon),
                           degistiren = @p8, degistirme_tarihi = now()
                     where id = @p0
                    """, null, [id, g.DentalAnamnez, g.Bruksizm is bool bk ? (short)(bk ? 1 : 0) : null,
                                g.Sigara is bool sg ? (short)(sg ? 1 : 0) : null, g.HijyenDurum, g.TmeBulgu,
                                g.OkluzyonSinif is int ok ? (short)ok : null, g.Dentisyon is int dn ? (short)dn : null,
                                baglam.KullaniciId], iptal);
            }
            else
            {
                var hastaMi = await b.TekDegerAsync<int?>("select 1 from public.taraf where id = @p0 and hasta = 1", null, [hastaId], iptal);
                if (hastaMi is null) throw GentegreHatasi.Dogrulama("Hasta bulunamadı.");
                id = await b.TekDegerAsync<int>("""
                    insert into public.dis_muayene (sube_id, hasta_id, dental_anamnez, bruksizm, sigara, hijyen_durum, tme_bulgu,
                                                    okluzyon_sinif, dentisyon, ekleyen)
                    values (@p0, @p1, coalesce(@p2, ''), coalesce(@p3, 0), coalesce(@p4, 0), coalesce(@p5, ''), coalesce(@p6, ''),
                            coalesce(@p7, 0), coalesce(@p8, 1), @p9) returning id
                    """, null, [baglam.SubeId ?? 0, hastaId, g.DentalAnamnez, g.Bruksizm is bool bk ? (short)(bk ? 1 : 0) : null,
                                g.Sigara is bool sg ? (short)(sg ? 1 : 0) : null, g.HijyenDurum, g.TmeBulgu,
                                g.OkluzyonSinif is int ok ? (short)ok : null, g.Dentisyon is int dn ? (short)dn : null,
                                baglam.KullaniciId], iptal);
            }
            await log.YazAsync(LogIslemi.Degistir, LogTabloDisMuayene, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { g.DentalAnamnez, g.Bruksizm, g.Sigara, g.HijyenDurum }, tarafId: hastaId, iptal: iptal);
            return Results.Ok(new { id });
        });
    }
}
