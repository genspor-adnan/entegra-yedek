using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DIŞ DOKTOR SAHA UÇLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): talebi kapat / göreve çevir,
/// ziyareti "gördüm" işaretle. Kart / liste jenerik; burada yalnız kartın yazamadığı geçişler var.
/// </summary>
public static class DisHekimUclari
{
    public sealed record TalepKapatIstegi(short Durum, string? Sonuc);
    public sealed record GoreveCevirIstegi(int? SorumluId, DateTime? Termin);

    private const int LogTalep = 1782;
    private const int LogZiyaret = 1781;

    public static void DisHekimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis-hekim").WithTags("Dış Doktor").RequireAuthorization();

        // ------------------------------------------------ talep kapat / ret --
        grup.MapPost("/talep/{id:int}/kapat", async (int id, TalepKapatIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);
            if (istek.Durum is not (3 or 4))
                throw GentegreHatasi.Dogrulama("Durum 3 (Kapandı) ya da 4 (Ret) olmalı.", new AlanHatasi("durum", "Geçersiz."));

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var sayi = await b.CalistirAsync("""
                update public.dis_hekim_talep
                   set durum = @p1, sonuc = case when coalesce(@p2, '') <> '' then @p2 else sonuc end,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2)
                """, islem, [id, istek.Durum, istek.Sonuc ?? "", baglam.KullaniciId], iptal);
            if (sayi == 0) throw GentegreHatasi.IsKurali("Talep bulunamadı ya da zaten kapalı.");
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTalep, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aksiyon"] = istek.Durum == 3 ? "kapat" : "ret", ["sonuc"] = istek.Sonuc ?? "" },
                iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = istek.Durum == 3 ? "Talep kapatıldı." : "Talep reddedildi.", izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ göreve çevir --
        //   Talep kurumdaki bir kişinin işidir: gorev kaydı açılır (sorumlu, termin, hekim taraf olarak), talep
        //   kaydı göreve bağlanır. İkinci çağrı aynı görevi döndürür - iki görev açılmaz.
        grup.MapPost("/talep/{id:int}/goreve-cevir", async (int id, GoreveCevirIstegi? istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var t = await b.TekAsync("""
                select t.id, t.hekim_id, t.talep, t.tur_ad, t.sorumlu_id, t.termin, t.gorev_id, t.hekim_ad, t.durum
                  from public.v_dis_hekim_talep t where t.id = @p0
                """, islem, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");
            if (t["gorev_id"] is long mevcut && mevcut > 0)
                return Results.Ok(new { gorevId = mevcut, mesaj = $"Talep zaten #{mevcut} numaralı göreve bağlı.", izlemeNo = baglam.IzlemeNo });
            if (Convert.ToInt32(t["durum"]) is 3 or 4)
                throw GentegreHatasi.IsKurali("Kapalı talep göreve çevrilmez.");

            var sorumlu = istek?.SorumluId ?? (t["sorumlu_id"] is int s ? s : baglam.KullaniciId);
            var termin = istek?.Termin ?? (t["termin"] is DateTime d ? d : (DateTime?)null);
            var konu = $"{t["tur_ad"]}: {t["hekim_ad"]}";
            var gorevId = await b.TekDegerAsync<long>("""
                insert into public.gorev (konu, aciklama, tur, oncelik, durum, sorumlu_id, acan_id, taraf_id, termin, sube_id, ekleyen)
                values (@p0, @p1, 1, 2, 0, @p2, @p3, @p4, @p5, @p6, @p3)
                returning id
                """, islem, [konu.Length > 200 ? konu[..200] : konu, Convert.ToString(t["talep"]) ?? "", sorumlu, baglam.KullaniciId,
                             t["hekim_id"], termin, baglam.SubeId ?? 0], iptal);
            await b.CalistirAsync("""
                update public.dis_hekim_talep
                   set gorev_id = @p1, sorumlu_id = coalesce(sorumlu_id, @p2), termin = coalesce(termin, @p3::date),
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, gorevId, sorumlu, termin, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTalep, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aksiyon"] = "goreve-cevir", ["gorevId"] = gorevId.ToString() }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { gorevId, mesaj = $"Görev #{gorevId} açıldı.", izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ ziyaret gördüm (yönetici) --
        grup.MapPost("/ziyaret/{id:int}/goruldu", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var sayi = await b.CalistirAsync("""
                update public.dis_hekim_ziyaret set goruldu_id = @p1, goruldu_zamani = now()
                 where id = @p0 and goruldu_id is null
                """, islem, [id, baglam.KullaniciId], iptal);
            if (sayi > 0)
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogZiyaret, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["aksiyon"] = "goruldu" }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = sayi > 0 ? "Görüldü olarak işaretlendi." : "Zaten görülmüş.", izlemeNo = baglam.IzlemeNo });
        });
    }
}
