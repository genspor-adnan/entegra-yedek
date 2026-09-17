using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MASRAF BEYANI UÇLARI (764) — cepten yapılan iş harcamasının geri ödeme
/// talebi.
///
/// ============ BAŞLIK + SATIR =========================================
/// Bir beyan birden çok fişi taşır: bir saha ziyaretinde taksi, otopark ve
/// yemek ayrı belgelerdir ama tek onaya gider. Her fiş ayrı beyan olsaydı
/// âmir günde on kez aynı kararı verirdi.
///
/// ============ BELGESİZ SATIR YOK =====================================
/// "Fatura/fiş karşılığında" kuralın kendisi: `belge_no` zorunlu (db kısıtı
/// da korur). Beyan bir harcama iddiası değil, belgeye dayanan bir talep.
///
/// ============ ÖDEME BU MODÜLDE DEĞİL =================================
/// Kullanıcı kararı (17.09.2026): zincir "onaylandı" ile biter, ödemeyi
/// muhasebe kendi akışında yapar. Avanstaki gibi bir "Öde" aksiyonu YOK -
/// olmayan bir ödeme izini varmış gibi göstermektense hiç göstermemek
/// doğru.
/// </summary>
public static class MasrafBeyaniUclari
{
    /// <summary>islem_log.tablo_id — personel_masraf / satır.</summary>
    private const int LogBeyan = 1312;
    private const int LogSatir = 1313;

    private const short Taslak = 0, Onayda = 1, Onaylandi = 2, Reddedildi = 3,
                        Iptal = 8;

    public sealed class BeyanIstegi
    {
        public int TarafId { get; set; }
        public DateOnly? BeyanTarihi { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class SatirIstegi
    {
        public int? MasrafId { get; set; }
        public DateOnly? HarcamaTarihi { get; set; }
        public short? BelgeTuru { get; set; }
        public string? BelgeNo { get; set; }
        public decimal Tutar { get; set; }
        public decimal? KdvTutar { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class GerekceIstegi { public string? Gerekce { get; set; } }

    public static void MasrafBeyaniUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik").WithTags("Masraf Beyanı").RequireAuthorization();

        // ------------------------------------------------------- beyan ----
        grup.MapPost("/masraf", async (
            BeyanIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.masraf", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Personel zorunlu.",
                    new AlanHatasi("tarafId", "Masraf bir personele açılır."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.personel_masraf
                       (taraf_id, sube_id, beyan_tarihi, aciklama, durum, ekleyen)
                values (@p0, @p1, coalesce(@p2, current_date), @p3, 0, @p4)
                returning id
                """, islem,
                [istek.TarafId, baglam.SubeId ?? 0,
                 istek.BeyanTarihi?.ToDateTime(TimeOnly.MinValue),
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogBeyan, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.TarafId, istek.Aciklama }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = Taslak, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------- satır ----
        // Satır YALNIZ TASLAKTA eklenir/silinir; db tetiği de korur (764).
        //   Onaya gönderilmiş beyanın tutarı değişirse imza başka bir rakama
        //   verilmiş olurdu.
        grup.MapPost("/masraf/{id:int}/satir", async (
            int id, SatirIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.masraf", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.BelgeNo))
                throw GentegreHatasi.Dogrulama("Belge numarası zorunlu.",
                    new AlanHatasi("belgeNo",
                        "Fatura/fiş numarası olmadan harcama beyan edilemez."));
            if (istek.Tutar <= 0)
                throw GentegreHatasi.Dogrulama("Tutar sıfırdan büyük olmalı.",
                    new AlanHatasi("tutar", "Sıfırdan büyük olmalı."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var satirId = await baglanti.TekDegerAsync<int>("""
                insert into public.personel_masraf_satir
                       (beyan_id, sira, masraf_id, harcama_tarihi, belge_turu,
                        belge_no, tutar, kdv_tutar, aciklama, ekleyen)
                select @p0,
                       coalesce((select max(s.sira) from public.personel_masraf_satir s
                                  where s.beyan_id = @p0), 0) + 1,
                       @p1, coalesce(@p2, current_date), coalesce(@p3, 2),
                       btrim(@p4), @p5, coalesce(@p6, 0), @p7, @p8
                returning id
                """, islem,
                [id, istek.MasrafId,
                 istek.HarcamaTarihi?.ToDateTime(TimeOnly.MinValue),
                 istek.BelgeTuru, istek.BelgeNo, istek.Tutar, istek.KdvTutar,
                 istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            var toplam = await baglanti.TekDegerAsync<decimal>(
                "select toplam_tutar from public.personel_masraf where id = @p0",
                islem, [id], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogSatir, satirId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { beyanId = id, istek.BelgeNo, istek.Tutar }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { satirId, toplamTutar = toplam,
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapDelete("/masraf/satir/{satirId:int}", async (
            int satirId, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.masraf", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var silinen = await baglanti.CalistirAsync(
                "delete from public.personel_masraf_satir where id = @p0",
                islem, [satirId], iptal);
            if (silinen == 0) throw GentegreHatasi.Bulunamadi("Satır bulunamadı.");

            await log.YazAsync(baglanti, islem, LogIslemi.Sil, LogSatir, satirId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { satirId },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { satirId, izlemeNo = baglam.IzlemeNo });
        });

        // -------------------------------------------------- onaya gönder ----
        grup.MapPost("/masraf/{id:int}/gonder", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.masraf", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.taraf_id as "tarafId", m.toplam_tutar as "toplam", m.durum,
                       (select count(*) from public.personel_masraf_satir s
                         where s.beyan_id = m.id) as "satir",
                       p.yonetici_taraf_id as "amirId"
                  from public.personel_masraf m
                  left join public.taraf_personel p on p.id = m.taraf_id
                 where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Masraf beyanı bulunamadı.");

            if (Convert.ToInt16(m["durum"]) >= Onaylandi)
                throw GentegreHatasi.IsKurali("Karara bağlanmış beyan yeniden gönderilemez.");
            // BOŞ BEYAN GÖNDERİLEMEZ: satırsız beyanın tutarı sıfırdır ve
            //   onaylayana "neyi onaylıyorum" sorusunu sordurur.
            if (Convert.ToInt64(m["satir"] ?? 0L) == 0)
                throw GentegreHatasi.IsKurali(
                    "Satırı olmayan masraf beyanı onaya gönderilemez.");
            if (m["amirId"] is null)
                throw GentegreHatasi.IsKurali(
                    "Personelin âmiri tanımlı değil - beyan onaya gönderilemez. "
                    + "Personel kartındaki \"Yönetici\" alanını doldurun.");

            var tarafId = Convert.ToInt32(m["tarafId"]);
            var toplam = Convert.ToDecimal(m["toplam"] ?? 0m);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var zincir = await onay.BaslatAsync(baglanti, islem, "personel.masraf",
                id, toplam, [], baglam, iptal, sahipTarafId: tarafId);

            // NUMARA ONAYA GÖNDERİRKEN KESİLİR (767) - taslakta değil.
            await baglanti.CalistirAsync("""
                update public.personel_masraf set durum = @p1,
                       beyan_no = coalesce(nullif(beyan_no, ''),
                                  public.fn_numara_kimlik_uret(
                                      907, sube_id, 'personel_masraf', 'beyan_no')),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Onayda, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogBeyan, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Onayda, toplam }, iptal: iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            return Results.Ok(new
            {
                durum = Onayda, toplamTutar = toplam,
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- iptal ----
        grup.MapPost("/masraf/{id:int}/iptal", async (
            int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.masraf", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                    new AlanHatasi("gerekce", "İptal gerekçesi yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // BEYAN SİLİNMEZ: "bu harcama talep edilmiş miydi" sorusu
            //   sonradan da sorulur.
            await Servisler.OnayMotoru.IptalAsync(baglanti, islem, LogBeyan, id,
                "Masraf beyanı iptal edildi", iptal);

            await baglanti.CalistirAsync("""
                update public.personel_masraf
                   set durum = @p1, iptal_neden = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Iptal, istek.Gerekce, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogBeyan, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Iptal, istek.Gerekce }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = Iptal, izlemeNo = baglam.IzlemeNo });
        });
    }
}
