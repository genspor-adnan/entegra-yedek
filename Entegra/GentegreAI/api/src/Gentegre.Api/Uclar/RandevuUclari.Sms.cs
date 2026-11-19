using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RANDEVU SMS (1382, kullanıcı 19.11.2026: "randevu kartına SMS Gönder Check ekle.. şubeye özgü olsun mesaj..
/// istersek mesajı değiştirebilelim.. 1 gün kala hatırlatma mesajı göndereceğiz opsiyonel olarak").
///   POST /api/randevu/sms-onizleme - kartın (kaydedilmemiş) alanlarıyla gönderilecek bilgi metni; hatırlatma açık mı.
///   GET/PUT /api/randevu/sms-ayar  - aktif şubenin bilgi / hatırlatma metni ve hatırlatma açık / saat.
/// Metin hazırlama RandevuHatirlatmasi'nda - önizleme ile gönderilen SMS aynı yerden geçer.
/// </summary>
public static partial class RandevuUclari
{
    public sealed record SmsOnizlemeIstegi(int? RandevuId, int? HastaId, DateTime? Baslangic, int? Bolum, int? HekimId);
    public sealed record SmsAyarIstegi(string? BilgiSablon, bool HatirlatmaAcik, short HatirlatmaSaat, string? HatirlatmaSablon);

    /// <summary>islem_log tablo kimliği - şube kartı (KartKatalogu.Firma LogTabloId).</summary>
    private const int LogTabloSube = 1276;

    private static void SmsUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/sms-onizleme", async (
            SmsOnizlemeIstegi istek, VeriKaynagi veri, Servisler.RandevuHatirlatmasi sms, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            // Kayıtlı randevuda şube ve "bu saate bilgi gitti mi" kayıttan; yeni kartta aktif şube.
            var kayit = istek.RandevuId is > 0
                ? await veri.TekAsync("""
                    select coalesce(sube_id, 0), sms_bilgi_baslangic, baslangic from public.randevu where id = @p0
                    """, [istek.RandevuId], o => new
                    {
                        Sube = o.GetInt32(0), Gitti = o.IsDBNull(1) ? (DateTime?)null : o.GetDateTime(1), Bas = o.GetDateTime(2),
                    }, iptal)
                : null;
            var sube = kayit?.Sube is > 0 ? kayit.Sube : baglam.SubeId ?? 0;
            var baslangic = istek.Baslangic ?? kayit?.Bas ?? DateTime.Now;
            var (degerler, telefon) = await sms.VeriAsync(sube, istek.HastaId, baslangic, istek.Bolum, istek.HekimId, iptal);
            var ayar = sube > 0 ? await sms.SubeAyariAsync(sube, iptal) : null;
            var bilgi = Servisler.RandevuHatirlatmasi.Doldur(
                ayar?.BilgiSablon is { Length: > 0 } b ? b : Servisler.RandevuHatirlatmasi.VarsayilanBilgi, degerler);
            // Bilgi bu randevu saati için gitmiş mi: kayıtlı saat değişmediyse yeniden gitmez (kart bunu söyler).
            var saatAyni = kayit is not null && (istek.Baslangic is null
                || Math.Abs((Saat.AnOlarak(kayit.Bas) - Saat.UtcYap(istek.Baslangic.Value)).TotalMinutes) < 1);
            return Results.Ok(new
            {
                bilgi,
                telefonVar = Servisler.RandevuHatirlatmasi.Rakamlar(telefon).Length >= 10,
                hatirlatmaAcik = ayar?.HatirlatmaAcik ?? false,
                hatirlatmaSaat = ayar?.HatirlatmaSaat ?? 24,
                bilgiGitti = saatAyni && kayit!.Gitti is not null && kayit.Gitti == kayit.Bas,
            });
        });

        grup.MapGet("/sms-ayar", async (
            VeriKaynagi veri, Servisler.RandevuHatirlatmasi sms, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Gor);
            var aktif = baglam.SubeId ?? 0;
            var ayar = aktif > 0 ? await sms.SubeAyariAsync(aktif, iptal) : null;
            return Results.Ok(new
            {
                subeId = baglam.SubeId,
                bilgiSablon = ayar?.BilgiSablon ?? "",
                hatirlatmaAcik = ayar?.HatirlatmaAcik ?? false,
                hatirlatmaSaat = ayar?.HatirlatmaSaat ?? 24,
                hatirlatmaSablon = ayar?.HatirlatmaSablon ?? "",
                varsayilanBilgi = Servisler.RandevuHatirlatmasi.VarsayilanBilgi,
                varsayilanHatirlatma = Servisler.RandevuHatirlatmasi.VarsayilanHatirlatma,
                degiskenler = Servisler.RandevuHatirlatmasi.Degiskenler.Select(d => new { ad = d.Ad, aciklama = d.Aciklama }),
            });
        });

        grup.MapPut("/sms-ayar", async (
            SmsAyarIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Randevu › Ayarlar › Çalışma Şablonları ekranının yetkisi.
            baglam.YetkiIste("randevu.plan.sablon", Islem.Degistir);
            baglam.YazmaIste();
            var sube = baglam.SubeId ?? 0;
            if (sube <= 0) throw GentegreHatasi.IsKurali("Aktif şube yok.");
            var bilgi = (istek.BilgiSablon ?? "").Trim();
            var hatir = (istek.HatirlatmaSablon ?? "").Trim();
            if (bilgi.Length > 500 || hatir.Length > 500)
                throw GentegreHatasi.Dogrulama("Mesaj en çok 500 karakter olabilir.");
            if (istek.HatirlatmaSaat is < 1 or > 168)
                throw GentegreHatasi.Dogrulama("Hatırlatma 1 ile 168 saat önce olabilir.", new AlanHatasi("hatirlatmaSaat", "1-168"));
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                insert into public.randevu_sms_ayar (sube_id, bilgi_sablon, hatirlatma_acik, hatirlatma_saat, hatirlatma_sablon,
                                                     degistiren, degistirme_tarihi)
                values (@p0, @p1, @p2, @p3, @p4, @p5, now())
                on conflict (sube_id) do update
                   set bilgi_sablon = excluded.bilgi_sablon, hatirlatma_acik = excluded.hatirlatma_acik,
                       hatirlatma_saat = excluded.hatirlatma_saat, hatirlatma_sablon = excluded.hatirlatma_sablon,
                       degistiren = excluded.degistiren, degistirme_tarihi = now()
                """, islem, [sube, bilgi, (short)(istek.HatirlatmaAcik ? 1 : 0), istek.HatirlatmaSaat, hatir, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloSube, sube, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["Randevu SMS"] = $"hatırlatma {(istek.HatirlatmaAcik ? $"açık ({istek.HatirlatmaSaat} sa)" : "kapalı")}",
                    ["Bilgi metni"] = bilgi.Length > 0 ? bilgi : "(varsayılan)",
                    ["Hatırlatma metni"] = hatir.Length > 0 ? hatir : "(varsayılan)",
                }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });
    }
}
