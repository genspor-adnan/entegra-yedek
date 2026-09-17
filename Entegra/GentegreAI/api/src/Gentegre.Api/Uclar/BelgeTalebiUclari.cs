using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BELGE TALEBİ UÇLARI (765) — personelin İK'dan resmî yazı talebi.
///
/// ============ ASIL İŞ ONAY DEĞİL, HAZIRLAMAK =========================
/// İzin/avans/masrafta karar zordur. Burada karar kolay: çalışan
/// çalışıyorsa belge verilir. Zor olan işin kendisi - yazının hazırlanması,
/// imzalanması, teslimi. Bu yüzden durum onayla bitmiyor:
///
///     talep → (onay) → HAZIRLANACAK → hazırlandı → teslim edildi
///
/// Onayı sonun işareti sayan bir tasarım, personelin belgeyi ne zaman
/// alacağını cevapsız bırakırdı - oysa sorduğu tam olarak budur.
///
/// ============ OTOMATİK ONAY AYARLA ===================================
/// `ik.belge_talep_otomatik` açıkken (varsayılan) zincir HİÇ KURULMAZ ve
/// talep onaylı doğar. Boş bir zincir yazıp hemen kapatmak, gelen kutusunu
/// kimsenin bakmadığı satırlarla doldururdu.
///
/// Red yolu her iki hâlde de açık: otomatik onay "hiç reddedilemez" demek
/// değil - deneme süresindeki personele kredi yazısı vermemek gibi haklı
/// gerekçeler var, İK hazırlık aşamasında gerekçesiyle reddedebilir.
/// </summary>
public static class BelgeTalebiUclari
{
    /// <summary>islem_log.tablo_id — personel_belge_talep.</summary>
    private const int LogTalep = 1314;

    private const short Taslak = 0, Onayda = 1, Hazirlanacak = 2, Reddedildi = 3,
                        Hazirlandi = 4, TeslimEdildi = 5, Iptal = 8;

    public sealed class TalepIstegi
    {
        public int TarafId { get; set; }
        public short? Tur { get; set; }
        public string? Amac { get; set; }
        public string? Muhatap { get; set; }
        public short? Adet { get; set; }
        public short? TeslimSekli { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class GerekceIstegi { public string? Gerekce { get; set; } }

    public static void BelgeTalebiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik").WithTags("Belge Talebi").RequireAuthorization();

        // ------------------------------------------------------- talep ----
        grup.MapPost("/belge-talep", async (
            TalepIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_talep", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Personel zorunlu.",
                    new AlanHatasi("tarafId", "Belge talebi bir personele açılır."));
            // AMAÇ ZORUNLU: yazının METNİ amaca göre değişir (vize yazısı
            //   İngilizce ve maaş bilgili, çalışma belgesi olmayabilir).
            //   Amaçsız talep, İK'ya "ne yazayım" sorusu bıraktırır.
            if (string.IsNullOrWhiteSpace(istek.Amac))
                throw GentegreHatasi.Dogrulama("Amaç zorunlu.",
                    new AlanHatasi("amac",
                        "Belge ne için isteniyor (banka kredisi, vize…)?"));

            await using var baglanti = await veri.AcAsync(iptal);

            var otomatik = await baglanti.TekDegerAsync<string?>("""
                select deger from public.referans
                 where anahtar = 'ik.belge_talep_otomatik'
                """, null, [], iptal);
            var otoAcik = (otomatik ?? "1").Trim() != "0";

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // NUMARA AÇILIŞTA KESİLİR (767): belge talebinin taslağı yok -
            //   kayıt açıldığı anda sürece giriyor (otomatik onayda doğrudan
            //   hazırlık kuyruğuna, kapalıyken İK onayına). Avans/masrafta
            //   numara onaya gönderirken kesiliyor çünkü orada taslak var.
            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.personel_belge_talep
                       (taraf_id, sube_id, tur, amac, muhatap, adet, teslim_sekli,
                        durum, otomatik_onay, aciklama, ekleyen, talep_no)
                values (@p0, @p1, coalesce(@p2, 1), @p3, @p4, coalesce(@p5, 1),
                        coalesce(@p6, 1), @p7, @p8, @p9, @p10,
                        public.fn_numara_kimlik_uret(
                            908, @p1, 'personel_belge_talep', 'talep_no'))
                returning id
                """, islem,
                [istek.TarafId, baglam.SubeId ?? 0, istek.Tur, istek.Amac,
                 istek.Muhatap ?? "", istek.Adet, istek.TeslimSekli,
                 otoAcik ? Hazirlanacak : Onayda, otoAcik ? (short)1 : (short)0,
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            object? basamaklar = null;
            long? onayId = null;

            if (!otoAcik)
            {
                var zincir = await onay.BaslatAsync(baglanti, islem,
                    "personel.belge_talep", id, 0m, [], baglam, iptal,
                    sahipTarafId: istek.TarafId);
                onayId = zincir.OnayId;
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol });
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.TarafId, istek.Tur, istek.Amac, otomatik = otoAcik },
                iptal: iptal);

            await islem.CommitAsync(iptal);

            if (onayId is not null)
            {
                try
                {
                    await haber.SiradakiniBildirAsync(baglanti, onayId.Value,
                        baglam.KullaniciId, baglam.SubeId, iptal);
                }
                catch (Exception) { /* zincir kuruldu; bildirim onu düşürmez */ }
            }

            return Results.Ok(new
            {
                id,
                durum = otoAcik ? Hazirlanacak : Onayda,
                otomatikOnay = otoAcik,
                basamaklar,
                mesaj = otoAcik
                    ? "Talep otomatik onaylandı; İK hazırlık kuyruğuna düştü."
                    : "Talep İK onayına gönderildi.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // --------------------------------------------------- hazırlandı ----
        grup.MapPost("/belge-talep/{id:int}/hazirla", async (
            int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_talep", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<short?>(
                "select durum from public.personel_belge_talep where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge talebi bulunamadı.");

            // ONAYSIZ HAZIRLANMAZ: hazırlık onayın yerine geçmez.
            if (durum != Hazirlanacak)
                throw GentegreHatasi.IsKurali(
                    "Yalnız onaylanmış (hazırlanacak) talep hazırlanabilir.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.personel_belge_talep
                   set durum = @p1, hazirlayan_id = @p2, hazirlama_tarihi = now(),
                       aciklama = case when coalesce(nullif(@p3, ''), '') = ''
                                       then aciklama
                                       else trim(both ' ' from coalesce(aciklama, '')
                                            || case when coalesce(nullif(aciklama, ''), '') <> ''
                                                    then ' · ' else '' end || @p3) end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Hazirlandi, baglam.KullaniciId,
                             istek.Gerekce ?? ""], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Hazirlandi }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = Hazirlandi, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------ teslim ----
        grup.MapPost("/belge-talep/{id:int}/teslim", async (
            int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.belge_talep", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<short?>(
                "select durum from public.personel_belge_talep where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge talebi bulunamadı.");

            if (durum != Hazirlandi)
                throw GentegreHatasi.IsKurali(
                    "Yalnız hazırlanmış belge teslim edilebilir.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.personel_belge_talep
                   set durum = @p1, teslim_tarihi = now(),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, TeslimEdildi, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = TeslimEdildi, not = istek.Gerekce }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = TeslimEdildi, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------------------- ret ----
        // OTOMATİK ONAYDA DA REDDEDİLEBİLİR: zincir kurulmamış olsa bile
        //   İK hazırlık aşamasında haklı bir gerekçeyle durdurabilir.
        grup.MapPost("/belge-talep/{id:int}/reddet", async (
            int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("ik.belge_talep_onay");

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce",
                        "Ret gerekçesi personele söylenecek."));

            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<short?>(
                "select durum from public.personel_belge_talep where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Belge talebi bulunamadı.");

            if (durum is TeslimEdildi or Reddedildi or Iptal)
                throw GentegreHatasi.IsKurali("Bu talep zaten sonuçlanmış.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // Zincir varsa (otomatik onay kapalıyken) o da kapanır.
            await Servisler.OnayMotoru.IptalAsync(baglanti, islem, LogTalep, id,
                "Belge talebi reddedildi", iptal);

            await baglanti.CalistirAsync("""
                update public.personel_belge_talep
                   set durum = @p1, red_neden = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Reddedildi, istek.Gerekce, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTalep, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Reddedildi, istek.Gerekce }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = Reddedildi, izlemeNo = baglam.IzlemeNo });
        });
    }
}
