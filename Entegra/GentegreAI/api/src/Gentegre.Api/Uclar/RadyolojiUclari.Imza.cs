using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RAPOR e-İMZA (1337, kullanıcı 13.11.2026): "Onayla ve İmzala" EIMZA hesabı aktifken buradan geçer.
///
/// İKİ ADIM (kod incelemesi 14.11.2026: imzalanan belge rapor numarasını taşımalı):
///   1. POST /rapor/{id}/imza-hazirla  → kilit / sürüm / onaylanabilirlik denetimi, RESMİ RAPOR NO ataması (durum
///      değişmez, kilit konmaz). Yeni sürüm döner; hekim çıktıyı bu sürümle çizer ve imzalar.
///   2. POST /rapor/{id}/imzala        → (istemci kipi) tarayıcının GenSigner'dan aldığı imzalı XML; (sunucu kipi)
///      rapor HTML'i + PIN, API sunucudaki GenSigner'a imzalatır. İmzalı XML biçimsel doğrulanır (ds:Signature var,
///      enveloping belge = gönderilen HTML), doküman deposuna yazılır ve rapor ONAYLANIR (durum 3 + kilit, istem 5,
///      bildirim, log - durum ucuyla aynı yardımcılar). İmza ile onay aynı işlemde: imzasız onay / onaysız imza kalmaz.
///
/// Bilinçli sınır: belgede onaylayan adı / onay zamanı yoktur (onay imzayla aynı anda oluşur); imzalayan kimliği ve
/// zamanı XAdES SigningTime + sertifikada durur.
/// </summary>
public static partial class RadyolojiUclari
{
    public const string ImzaDokumanKaynagi = "radyoloji-rapor";
    /// <summary>İmzalanacak HTML sınırı: doküman deposu 5 MB; XAdES sarmalı (base64 + imza) ~%40 büyütür.</summary>
    private const int ImzaBelgeAzami = 3 * 1024 * 1024;

    public sealed record ImzaIstegi(
        /// <summary>İmzalanan belge: raporun çıktı HTML'i (stil gömülü, tek dosya).</summary>
        string Html,
        string? MimeType,
        EImzaServisi.KartSecimi Sertifika,
        /// <summary>İstemci kipi: tarayıcının GenSigner'dan aldığı imzalı XML (base64).</summary>
        string? ImzaBase64,
        /// <summary>Sunucu kipi: kart PIN'i - yalnız GenSigner'a iletilir, hiçbir yere yazılmaz.</summary>
        string? Pin);

    private static void ImzaEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------------------- 1. hazırlık: rapor no + sürüm --
        grup.MapPost("/rapor/{id:int}/imza-hazirla", async (
            int id, string? surum, BaglamCozucu cozucu, VeriKaynagi veri, EImzaServisi eimza, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_onayla");
            var ayar = await eimza.AyarAsync(baglam.SubeId, iptal);
            if (!ayar.Aktif) throw GentegreHatasi.IsKurali("e-İmza hesabı tanımlı değil (Ayarlar › Entegrasyon Hesapları › EIMZA).");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            await RaporKilitleAsync(baglanti, islem, id, surum, iptal);
            var engel = await baglanti.TekDegerAsync<string>(
                "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", islem, [id], iptal) ?? "";
            if (engel.Length > 0) throw GentegreHatasi.IsKurali(engel);
            // RESMİ RAPOR NO imzadan ÖNCE (303 kuralı onayda verirdi): imzalı belge numarayı taşısın. Numara verilen
            //   rapor imzalanmadan kalırsa boşluk olur - vazgeçilen imza nadir, numarasız imzalı belge kabul edilemez.
            var sonuc = await baglanti.TekAsync("""
                update public.radyoloji_rapor
                   set rapor_no = case when coalesce(rapor_no, '') = '' then public.fn_radyoloji_rapor_no() else rapor_no end
                 where id = @p0
                returning rapor_no, xmin::text
                """, islem, [id], o => new { RaporNo = o.GetString(0), Surum = o.GetString(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
            await islem.CommitAsync(iptal);
            return Results.Ok(new { raporNo = sonuc.RaporNo, surum = sonuc.Surum, kip = ayar.Kip });
        });

        // ------------------------------------------------------------------------- 2. imza + onay --
        grup.MapPost("/rapor/{id:int}/imzala", async (
            int id, string? surum, ImzaIstegi govde, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            EImzaServisi eimza, DokumanDeposu dokuman, EnabizPaketUretici enabiz, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_onayla");
            if (string.IsNullOrWhiteSpace(govde.Html))
                throw GentegreHatasi.Dogrulama("İmzalanacak rapor belgesi boş.", new AlanHatasi("html", "Zorunlu."));
            if (govde.Sertifika is null || string.IsNullOrWhiteSpace(govde.Sertifika.Serial))
                throw GentegreHatasi.Dogrulama("Sertifika seçilmedi.", new AlanHatasi("sertifika", "Zorunlu."));

            var ayar = await eimza.AyarAsync(baglam.SubeId, iptal);
            if (!ayar.Aktif) throw GentegreHatasi.IsKurali("e-İmza hesabı tanımlı değil (Ayarlar › Entegrasyon Hesapları › EIMZA).");

            var belge = Encoding.UTF8.GetBytes(govde.Html);
            // BOYUT imzadan / parse'tan ÖNCE (kod incelemesi): kart boşuna imza atmasın, büyük XML belleğe alınmasın.
            if (belge.Length > ImzaBelgeAzami)
                throw GentegreHatasi.IsKurali("Rapor belgesi 3 MB'ı aşıyor; rapordaki resimleri küçültün.");
            if (ayar.Kip != EImzaServisi.KipSunucu && (govde.ImzaBase64?.Length ?? 0) > ImzaBelgeAzami * 2)
                throw GentegreHatasi.IsKurali("İmzalı belge 5 MB'ı aşıyor; rapordaki resimleri küçültün.");

            // ÖN DENETİM (kod incelemesi): kilitli / eski sürümlü rapor için karta imza attırılmaz, doküman yazılmaz.
            //   Asıl denetim aşağıda satır kilidi altında yinelenir.
            await RaporOnKontrolAsync(veri, id, surum, iptal);

            var mime = string.IsNullOrWhiteSpace(govde.MimeType) ? "text/html" : govde.MimeType.Trim();
            byte[] imzaXml;
            if (ayar.Kip == EImzaServisi.KipSunucu)
            {
                if (string.IsNullOrEmpty(govde.Pin))
                    throw GentegreHatasi.Dogrulama("Kart PIN'i girilmeli.", new AlanHatasi("pin", "Zorunlu."));
                imzaXml = await eimza.ImzalaAsync(ayar, belge, mime, govde.Sertifika, govde.Pin, iptal);
            }
            else
            {
                imzaXml = EImzaServisi.Base64Coz(govde.ImzaBase64);
            }
            var hata = EImzaServisi.Dogrula(imzaXml, belge);
            if (hata.Length > 0) throw GentegreHatasi.IsKurali("İmza doğrulanamadı: " + hata);

            var raporNo = await veri.TekDegerAsync<string>(
                "select coalesce(rapor_no, '') from public.radyoloji_rapor where id = @p0", [id], iptal) ?? "";
            var dosyaAdi = $"e-imza {(raporNo.Length > 0 ? raporNo : "rapor-" + id)}.xml";
            // Doküman önce (kendi bağlantısında); onay düşerse aşağıda geri alınır.
            var dokumanlar = await dokuman.EkleAsync(ImzaDokumanKaynagi, id, dosyaAdi, "application/xml", imzaXml,
                                                     false, baglam.Yazma, iptal);
            var dokumanId = dokumanlar.Count > 0 ? dokumanlar.Max(d => d.Id) : 0;
            var ozet = Convert.ToHexString(SHA256.HashData(belge));
            var sertifikaMetni = Kisalt(string.Join(" · ", new[] { govde.Sertifika.Cn ?? "", govde.Sertifika.Serial }
                                                              .Where(s => s.Length > 0)), 200);

            try
            {
                await using var baglanti = await veri.AcAsync(iptal);
                await using var islem = await baglanti.BeginTransactionAsync(iptal);
                var istemId = await RaporKilitleAsync(baglanti, islem, id, surum, iptal);
                await RaporOnaylaAsync(baglanti, islem, id, istemId, baglam, iptal);
                await baglanti.CalistirAsync("""
                    update public.radyoloji_rapor
                       set imza_zamani = now(), imzalayan_id = @p1, imza_sertifika = @p2, imza_dokuman_id = @p3, imza_ozet = @p4
                     where id = @p0
                    """, islem, [id, baglam.KullaniciId, sertifikaMetni, dokumanId, ozet], iptal);
                await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRapor, id,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["durum"] = "Onaylandı", ["e-imza"] = sertifikaMetni },
                    iptal: iptal);
                await islem.CommitAsync(iptal);
            }
            catch
            {
                // ONAY DÜŞTÜ (ör. 312 tetiği: çekim öncesi kontrol eksik): imzalı XML sahipsiz kalmasın - yazılan doküman
                //   geri alınır; hekim sorunu giderip yeniden imzalar.
                if (dokumanId > 0)
                    try { await dokuman.SilAsync(dokumanId, baglam.Yazma, CancellationToken.None); } catch { /* asıl hata raporlanır */ }
                throw;
            }

            var paket = await EnabizPaketiAsync(enabiz, ctx, id, baglam, iptal);
            return Results.Ok(new { tamam = true, paket, dokumanId, imzaSertifika = sertifikaMetni });
        });
    }

    // ------------------------------------------------------------ onay yardımcıları (durum ucu ile ortak) --

    /// <summary>Kilitsiz ön denetim: rapor var, kilitli değil, sürüm güncel. İmza / doküman yazımından önce.</summary>
    private static async Task RaporOnKontrolAsync(VeriKaynagi veri, int id, string? surum, CancellationToken iptal)
    {
        var satir = await veri.TekAsync(
            "select coalesce(kilit, 0)::int, xmin::text from public.radyoloji_rapor where id = @p0",
            [id], o => new { Kilit = o.GetInt32(0), Surum = o.GetString(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
        if (satir.Kilit == 1)
            throw GentegreHatasi.IsKurali("Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");
        if (surum != satir.Surum)
            throw GentegreHatasi.Cakisma(new { surum = satir.Surum });
    }

    /// <summary>İstem + rapor satır kilidi; kilitli rapor ve sürüm uyuşmazlığı burada reddedilir. İstem id döner.</summary>
    private static async Task<int> RaporKilitleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem, int id, string? surum,
                                                     CancellationToken iptal)
    {
        var istemId = await baglanti.TekDegerAsync<int?>(
            "select istem_id from public.radyoloji_rapor where id = @p0", islem, [id], iptal)
            ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
        await baglanti.CalistirAsync("select 1 from public.radyoloji_istem where id = @p0 for update", islem, [istemId], iptal);
        var satir = await baglanti.TekAsync(
            "select coalesce(kilit, 0)::int, xmin::text from public.radyoloji_rapor where id = @p0 for update",
            islem, [id], o => new { Kilit = o.GetInt32(0), Surum = o.GetString(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
        if (satir.Kilit == 1)
            throw GentegreHatasi.IsKurali("Rapor onaylanmış ve kilitli; düzeltme için ek rapor (addendum) açın.");
        // SÜRÜM (kod inceleme raporu 28.10.2026, ikinci tur P2): onaylanan metin, isteyenin GÖRDÜĞÜ metin olmalı.
        if (surum != satir.Surum)
            throw GentegreHatasi.Cakisma(new { surum = satir.Surum });
        return istemId;
    }

    /// <summary>Onay: ön koşul fonksiyonu, durum 3 + kilit + rapor no, istem 5, uzman hatırlatması kapanır.</summary>
    private static async Task RaporOnaylaAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem, int id, int istemId,
                                               IstekBaglami baglam, CancellationToken iptal)
    {
        var engel = await baglanti.TekDegerAsync<string>(
            "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", islem, [id], iptal) ?? "";
        if (engel.Length > 0) throw GentegreHatasi.IsKurali(engel);
        // RESMI RAPOR NUMARASI onayda atanir (303): taslak asamasinda vermek, vazgecilen raporlarda numara
        //   boslugu birakirdi. Zaten numarali rapor (yeniden onay / imza-hazirla) numarasini KORUR.
        await baglanti.CalistirAsync("""
            update public.radyoloji_rapor
               set durum = 3, kilit = 1, onaylayan_id = @p1, onay_tarihi = now()::timestamp,
                   rapor_no = case when rapor_no = ''
                                   then public.fn_radyoloji_rapor_no()
                                   else rapor_no end,
                   degistiren = @p1, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, islem, [id, baglam.KullaniciId], iptal);
        await baglanti.CalistirAsync("update public.radyoloji_istem set durum = 5 where id = @p0", islem, [istemId], iptal);
        // Onay geldi: uzmanın "onayınızı bekliyor" hatırlatması kapanır (vekâleten onaylansa da).
        await OnayBildirimiKapatAsync(baglanti, islem, istemId, iptal);
    }

    /// <summary>
    /// e-NABIZ 409 RADYOLOJI SONUC (883, KTS H10/D19): paket ONAY sonrasi uretilir - onaylanmamis rapor hastanin
    /// dosyasina girmez. Uretim SESSIZDIR: e-Nabiz ikincil is, raporun onayi onun basarisina bagli degil.
    /// </summary>
    private static async Task<object?> EnabizPaketiAsync(EnabizPaketUretici enabiz, HttpContext ctx, int id,
                                                         IstekBaglami baglam, CancellationToken iptal)
    {
        try
        {
            var s = await enabiz.UretAsync("RADYOLOJI_SONUC", id, baglam.KullaniciId, iptal);
            return s is null ? null : new { s.PaketNo, s.Durum, s.Eksikler };
        }
        catch (Exception h)
        {
            ctx.RequestServices.GetRequiredService<ILoggerFactory>().CreateLogger("enabiz")
               .LogError(h, "e-Nabiz radyoloji sonuc paketi uretilemedi (rapor {Id})", id);
            return null;
        }
    }
}
