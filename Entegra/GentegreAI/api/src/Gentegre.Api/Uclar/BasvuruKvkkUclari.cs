using System.Security.Cryptography;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KVKK SMS (1352, kullanıcı 17.11.2026): başvuru kartı "KVKK SMS Gönder" - hastanın cep telefonuna KVKK / ETK onay
/// SMS'i. Metin `basvuru.kvkk_sms` bildirim şablonundan (Yönetim › Bildirim Şablonu Listesi), `@ONAYKODU` /
/// `{{onay_kodu}}` her gönderimde üretilen TEKİL koddur. Hasta kodu söyler, kayıt kabul Başvuru sekmesinde SMS onay
/// kodu kutusuna yazar; doğrulama DB tetiğinde (tg_belge_basvuru_kvkk_kod).
/// </summary>
public static class BasvuruKvkkUclari
{
    public const string SablonKodu = "basvuru.kvkk_sms";

    /// <summary>Şablon gövdesine kodu yazar: @ONAYKODU ve {{onay_kodu}} ikisi de desteklenir.</summary>
    public static string MetniDoldur(string govde, string kod) =>
        govde.Replace("@ONAYKODU", kod, StringComparison.OrdinalIgnoreCase)
             .Replace("{{onay_kodu}}", kod, StringComparison.OrdinalIgnoreCase)
             .Replace("{{ONAYKODU}}", kod, StringComparison.OrdinalIgnoreCase);

    public static void BasvuruKvkkUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/basvuru").WithTags("Başvuru · KVKK").RequireAuthorization();

        grup.MapPost("/{belgeId:int}/kvkk-sms", async (
            int belgeId, VeriKaynagi veri, BaglamCozucu cozucu, BildirimDeposu bildirim, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);

            var hasta = await b.TekAsync("""
                select coalesce(bb.hasta_id, bl.taraf_id), coalesce(t.cep_tel, ''), bl.sube_id
                  from public.belge bl
                  join public.belge_basvuru bb on bb.id = bl.id
                  left join public.taraf t on t.id = coalesce(bb.hasta_id, bl.taraf_id)
                 where bl.id = @p0 and bl.tur = 19
                """, null, [belgeId], o => new { Id = o.GetInt32(0), Cep = o.GetString(1), Sube = o.GetInt16(2) }, iptal)
                ?? throw GentegreHatasi.IsKurali("Başvuru bulunamadı - önce başvuruyu kaydedin.");
            if (hasta.Sube != baglam.SubeId)
                throw GentegreHatasi.Yasak("Başvuru başka şubede - SMS o şubeden gönderilir.");
            if (hasta.Cep.Count(char.IsDigit) < 10)
                throw GentegreHatasi.IsKurali("Hastanın cep telefonu yok - hasta kartına yazın.");

            var govde = await b.TekDegerAsync<string>(
                "select govde from public.bildirim_sablon where kod = @p0 and durum = 1", null, [SablonKodu], iptal);
            if (string.IsNullOrWhiteSpace(govde))
                throw GentegreHatasi.IsKurali("KVKK SMS şablonu (basvuru.kvkk_sms) yok ya da pasif - Bildirim Şablonu Listesi'nden açın.");

            // TEKİL KOD: 6 hane, rastgele; açık (henüz doğrulanmamış) başka başvurunun koduyla çakışmaz.
            string kod;
            var deneme = 0;
            do
            {
                kod = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
                if (++deneme > 20) throw GentegreHatasi.IsKurali("Onay kodu üretilemedi - yeniden deneyin.");
            } while (await b.TekDegerAsync<bool>(
                "select exists (select 1 from public.belge_basvuru where kvkk_sms_kod = @p0)", null, [kod], iptal));

            await using var tx = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.belge_basvuru set kvkk_sms_kod = @p1, kvkk_sms_tarihi = now(), kvkk_onay_kodu = null
                 where id = @p0
                """, tx, [belgeId, kod], iptal);
            try
            {
                await bildirim.KuyrugaEkleAsync(b, tx, new BildirimIstegi(SablonKodu, BildirimKanali.Sms, hasta.Cep,
                    Govde: MetniDoldur(govde, kod), TarafId: hasta.Id, KullaniciId: baglam.KullaniciId,
                    KaynakTur: 30, KaynakId: belgeId, Oncelik: 1), baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (InvalidOperationException h)
            {
                throw GentegreHatasi.IsKurali("SMS gönderilemedi: " + h.Message);
            }
            await log.YazAsync(b, tx, LogIslemi.Degistir, 30, belgeId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["kvkkSms"] = "gönderildi" }, iptal: iptal);
            await tx.CommitAsync(iptal);

            var rakam = new string(hasta.Cep.Where(char.IsDigit).ToArray());
            return Results.Ok(new { gonderildi = true, alici = "***" + rakam[^4..] });
        });
    }
}
