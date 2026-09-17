using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSKONTO ONAYI (662) — kayıt kabul talep eder, yetkili zilden onaylar.
///
/// İki taraf, iki yetki:
///   · talep açmak  — başvuru satırını görebilen herkes (indirim İSTEMEK
///     yetki gerektirmez; yetki gereken şey onu VERMEKtir),
///   · onay / ret   — `basvuru.iskonto` ve TAVANI talebi karşılayan kullanıcı.
///     Tavanı yetmeyen kişi talebi listesinde HİÇ görmez: göremediği bir şeyi
///     onaylayamaz, gördüğü ama basamadığı düğme ise onu sunucudan ret yemeye
///     gönderirdi.
///
/// ============ KARAR BURADA DEĞİL (754) ===============================
/// Talep artık onay omurgasında yürüyor (`belge.iskonto`, kaynak_tur 1256)
/// ve karar `/api/onay/kayit/1256/{id}/karar` ucundan veriliyor. Burada
/// ikinci bir karar ucu BIRAKMADIK: iki yol olsaydı biri zinciri yürütüp
/// öteki doğrudan `fn_iskonto_talep_karar` çağırır, sıradaki basamak hiç
/// sorulmadan talep kapanırdı.
///
/// Talep AÇMAK burada kalıyor - zinciri o başlatıyor.
/// </summary>
public static class IskontoOnayUclari
{
    /// <summary>`islem_log.tablo_id` — omurganın kaynak türü (754).</summary>
    public const int KaynakIskonto = 1256;

    /// <summary>Kalem bazli oran (673): her satirin kendi yuzdesi.</summary>
    public sealed record TalepKalemi(int SatirId, decimal Oran);
    public sealed record TalepIstegi(int BelgeId, decimal Oran, string Gerekce,
                                     IReadOnlyList<TalepKalemi> Kalemler);

    public static void IskontoOnayUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/iskonto-talep").WithTags("İskonto")
                      .RequireAuthorization();

        // Belgenin talepleri (ücret sekmesinde durum rozetleri için).
        grup.MapGet("/belge/{belgeId:int}", async (
            int belgeId, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            return Results.Ok(await depo.BelgeTalepleriAsync(belgeId, iptal));
        });

        // ZİL: bu kullanıcının onayına düşen bekleyen talepler.
        grup.MapGet("/bekleyenler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Yetkisi olmayana BOŞ liste - hata değil: zil herkeste var.
            if (baglam.Yetkiler.AksiyonDegeri("basvuru.iskonto") <= 0)
                return Results.Ok(Array.Empty<object>());
            // SÜZGEÇ OMURGADAN (754): yalnız sırası bu kullanıcıda olan talep.
            return Results.Ok(await depo.BekleyenlerAsync(
                baglam.SubeId ?? 0, baglam.KullaniciId, iptal));
        });

        // ISKONTO ONAY EKRANI (666): sonuclanan talepler - denetim izi.
        grup.MapGet("/gecmis", async (
            int? gun, BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // ONAY EKRANININ KENDI YETKISI (685): denetim izini gormek belge
            //   gormekten ayri bir istir - kayit kabul gorevlisi basvuruyu
            //   gorur ama kimin neyi onayladigini gormesi gerekmez.
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.GecmisAsync(
                baglam.SubeId ?? 0, Math.Clamp(gun ?? 1, 1, 90), iptal));
        });

        // YETKI LIMITLERI (666): rol tavanlari - onay ekraninin limit sekmesi.
        grup.MapGet("/limitler", async (
            BaglamCozucu cozucu, IskontoTalepDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("iskonto_onay", Islem.Gor);
            return Results.Ok(await depo.LimitlerAsync(iptal));
        });

        // TALEP AÇMAK = ZİNCİRİ BAŞLATMAK (754): ikisi aynı işlemde olur.
        grup.MapPost("/", async (
            TalepIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            if (istek.Kalemler.Count == 0)
                throw GentegreHatasi.Dogrulama("Onaya gönderilecek satır seçilmeli.",
                    new AlanHatasi("kalemler", "En az bir satır seçin."));
            if (!(istek.Oran > 0))
                throw GentegreHatasi.Dogrulama("İskonto oranı sıfırdan büyük olmalı.",
                    new AlanHatasi("oran", "Sıfırdan büyük olmalı."));
            if (istek.Gerekce.Trim().Length == 0)
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce", "Zorunlu."));

            // BASLIK ORANI = en yuksek kalem orani: eşik kontrolü onunla
            //   olculur, istemcinin gonderdigi degere guvenilmez.
            var enYuksek = istek.Kalemler.Max(k => k.Oran);
            var satirIdler = istek.Kalemler.Select(k => k.SatirId).ToList();

            await using var baglanti = await veri.AcAsync(iptal);

            var bayraklar = new List<string>();
            if (await IskontoTalepDeposu.TekrarIndirimMiAsync(
                    baglanti, null, satirIdler, iptal))
                bayraklar.Add("tekrar_iskonto");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await IskontoTalepDeposu.TalepAcAsync(baglanti, islem,
                istek.BelgeId, enYuksek, istek.Gerekce,
                istek.Kalemler.Select(k => (k.SatirId, k.Oran)).ToList(),
                baglam.KullaniciId, baglam.SubeId ?? 0, iptal);

            // ÖLÇÜ = ORAN (yüzde), tutar değil: aynı %30 küçük ve büyük
            //   başvuruda kurumun fiyat politikasına aynı ölçüde dokunur.
            var zincir = await onay.BaslatAsync(baglanti, islem, "belge.iskonto",
                id, enYuksek, bayraklar, baglam, iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            return Results.Ok(new
            {
                id, oran = enYuksek, bayraklar,
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // KARAR UCU YOK: `/api/onay/kayit/1256/{id}/karar` (754). Kısmi onay
        //   orada `olcu` alanıyla verilir - ölçü düşünce gerekmeyen ileri
        //   basamaklar atlanır.
    }
}
