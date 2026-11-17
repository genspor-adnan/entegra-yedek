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

    public sealed record KvkkKodIstegi(string? Kod);

    /// <summary>Hastanın bir başvurudaki KVKK kaydı (kvkk-durum).</summary>
    private sealed record KvkkKaydi(int KvkkOnay, int EtkOnay, DateTime Tarih, string BelgeNo, string Sube, string Kod);

    /// <summary>Şablon gövdesine kodu yazar: @ONAYKODU ve {{onay_kodu}} ikisi de desteklenir.</summary>
    public static string MetniDoldur(string govde, string kod) =>
        govde.Replace("@ONAYKODU", kod, StringComparison.OrdinalIgnoreCase)
             .Replace("{{onay_kodu}}", kod, StringComparison.OrdinalIgnoreCase)
             .Replace("{{ONAYKODU}}", kod, StringComparison.OrdinalIgnoreCase);

    public static void BasvuruKvkkUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/basvuru").WithTags("Başvuru · KVKK").RequireAuthorization();

        // KVKK ONAY DURUMU (1353, kullanıcı 17.11.2026: "her şube için ayrı KVKK onayı al" / "X gün sonra tekrar KVKK
        //   onayı al"; mockup Ekranlar/Kayıt Kabul/kvkk_onay_gecerlilik.html). Hastanın bu başvuru dışındaki SON KVKK
        //   kaydına bakılır (şube bazlıysa yalnız bu şube; iptal başvuru sayılmaz):
        //     gecerli       - son kayıt SMS (4) / ıslak imza (3) ve süre içinde → yeni başvuruda KVKK/ETK onunla dolar
        //     suresi_doldu  - son kayıt onay ama X gün geçti
        //     reddetti      - son kayıt Hasta Reddetti (1) - ret taşınmaz, yeniden sorulur
        //     baska_sube    - bu şubede kayıt yok, başka şubede onay var (şube bazlı ayar açık)
        //     yok           - hiç kayıt yok
        grup.MapGet("/kvkk-durum", async (
            int hastaId, int? haricBelgeId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var subeBazli = (await AyarDeposu.MetinAsync(b, null, "basvuru.kvkk_sube_bazli", "0", iptal)).Trim() == "1";
            var gun = int.TryParse((await AyarDeposu.MetinAsync(b, null, "basvuru.kvkk_gecerlilik_gun", "0", iptal)).Trim(), out var g) && g > 0 ? g : 0;
            const string Sorgu = """
                select bb.kvkk_onay::int, coalesce(bb.etk_onay, 0)::int, bl.belge_tarihi::date, coalesce(bl.belge_no, ''),
                       coalesce(s.ad, ''), coalesce(bb.kvkk_onay_kodu, '')
                  from public.belge bl
                  join public.belge_basvuru bb on bb.id = bl.id
                  left join public.sube s on s.id = bl.sube_id
                 where bl.tur = 19 and bl.durum <> 6
                   and coalesce(bb.hasta_id, bl.taraf_id) = @p0
                   and bb.kvkk_onay is not null
                   and bl.id <> @p1
                   and (not @p2 or bl.sube_id = @p3)
                   {0}
                 order by bl.belge_tarihi desc, bl.id desc
                 limit 1
                """;
            static KvkkKaydi Oku(Npgsql.NpgsqlDataReader o) => new(o.GetInt32(0), o.GetInt32(1),
                o.GetFieldValue<DateTime>(2), o.GetString(3), o.GetString(4), o.GetString(5));
            var sube = (short)(baglam.SubeId ?? 0);
            var son = await b.TekAsync(string.Format(Sorgu, ""), null, [hastaId, haricBelgeId ?? 0, subeBazli, sube],
                Oku, iptal);

            if (son is null)
            {
                // Bu şubede kayıt yok: şube bazlıysa başka şubedeki onay bilgi olarak söylenir.
                if (subeBazli)
                {
                    var diger = await b.TekAsync(string.Format(Sorgu, "and bb.kvkk_onay in (3, 4)"), null,
                        [hastaId, haricBelgeId ?? 0, false, sube], Oku, iptal);
                    if (diger is not null)
                        return Results.Ok(new { durum = "baska_sube", kvkkOnay = diger.KvkkOnay, etkOnay = diger.EtkOnay,
                            tarih = diger.Tarih.ToString("yyyy-MM-dd"), belgeNo = diger.BelgeNo, sube = diger.Sube });
                }
                return Results.Ok(new { durum = "yok" });
            }
            var tarih = son.Tarih.ToString("yyyy-MM-dd");
            if (son.KvkkOnay is 1 or 2)
                return Results.Ok(new { durum = "reddetti", kvkkOnay = son.KvkkOnay, etkOnay = son.EtkOnay, tarih,
                                        belgeNo = son.BelgeNo, sube = son.Sube });
            var bitis = gun > 0 ? son.Tarih.AddDays(gun) : (DateTime?)null;
            var durum = bitis is null || bitis.Value.Date >= DateTime.Today ? "gecerli" : "suresi_doldu";
            return Results.Ok(new { durum, kvkkOnay = son.KvkkOnay, etkOnay = son.EtkOnay, tarih, belgeNo = son.BelgeNo,
                                    sube = son.Sube, kod = son.Kod, bitis = bitis?.ToString("yyyy-MM-dd"), gun });
        });

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

        // ONAY KODU GİR (kullanıcı 17.11.2026: "onay kodu girme modal'i gelsin ve hastanın gönderdiği onay kodunu
        //   kontrol etsin.. tamamsa onay kodu alanına kaydetsin.. kvkk ve etk combolarda sms ile onay alındı seçilsin").
        //   Kodu YALNIZ bu uç yazar; eşleşmeyi ve KVKK/ETK = 4'ü DB tetiği (tg_belge_basvuru_kvkk_kod) de uygular.
        grup.MapPost("/{belgeId:int}/kvkk-kod", async (
            int belgeId, KvkkKodIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("belge", Islem.Degistir);
            baglam.YazmaIste();
            var kod = new string((istek.Kod ?? "").Where(char.IsDigit).ToArray());
            if (kod.Length == 0) throw GentegreHatasi.IsKurali("Onay kodunu girin.");
            await using var b = await veri.AcAsync(iptal);

            var durum = await b.TekAsync("""
                select bl.sube_id, bb.kvkk_sms_kod
                  from public.belge bl join public.belge_basvuru bb on bb.id = bl.id
                 where bl.id = @p0 and bl.tur = 19
                """, null, [belgeId], o => new { Sube = o.GetInt16(0), Gonderilen = o.IsDBNull(1) ? null : o.GetString(1) }, iptal)
                ?? throw GentegreHatasi.IsKurali("Başvuru bulunamadı.");
            if (durum.Sube != baglam.SubeId)
                throw GentegreHatasi.Yasak("Başvuru başka şubede.");
            if (durum.Gonderilen is null)
                throw GentegreHatasi.IsKurali("Bu başvuru için KVKK onay SMS'i gönderilmemiş - önce \"SMS Gönder\".");
            if (kod != durum.Gonderilen)
                throw GentegreHatasi.IsKurali("Onay kodu hatalı - hastaya gönderilen kodla eşleşmiyor.");

            await using var tx = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("update public.belge_basvuru set kvkk_onay_kodu = @p1 where id = @p0",
                tx, [belgeId, kod], iptal);
            await log.YazAsync(b, tx, LogIslemi.Degistir, 30, belgeId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["kvkkOnayKodu"] = "doğrulandı", ["kvkkOnay"] = "4", ["etkOnay"] = "4" }, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { kod, kvkkOnay = 4, etkOnay = 4 });
        });
    }
}
