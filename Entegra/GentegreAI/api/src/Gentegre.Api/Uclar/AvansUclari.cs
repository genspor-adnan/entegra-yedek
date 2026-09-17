using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// AVANS UÇLARI (753) — talep, onay, ödeme ve mahsup.
///
/// ============ BORDRO YOK, MAHSUP KENDİ PLANINDA ======================
/// Bu kurulumda bordro modülü yok: ne maaş tutarı ne bordro satırı var.
/// Mahsubu "bordroya yazarız" diye kurgulamak, olmayan bir tabloya yaslanan
/// ve ilk maaş döneminde kırılan bir akış üretirdi. Onun yerine avans
/// taksit taksit bölünüyor, her kesinti işaretlendikçe kalan düşüyor.
///
/// ============ ÖDEME KASADAN GEÇER ====================================
/// Avans ödemesi bir kasa/banka hareketidir ve `kasa_islem` zaten var.
/// İkinci bir ödeme tablosu açsaydık kasa bakiyesi avansı görmez,
/// mutabakat tutmazdı. Avansta yalnız BAĞ duruyor (`odeme_islem_id`).
///
/// ============ ÖDEME ONAYDAN SONRA ====================================
/// Onaylanmamış avans ödenemez - ödeyip sonra onaylatmak, onayı süse
/// çevirir. Ödendikten sonra iptal de edilemez: para çıkmıştır, geri almak
/// ayrı bir işlemdir (tahsilat).
/// </summary>
public static class AvansUclari
{
    /// <summary>islem_log.tablo_id - personel_avans.</summary>
    // 1257/1258 (755): 907 = Hasta Bilgisi, 908 = Kasa İşlemi. 753 bu iki
    //   numarayı gasp etmişti; avans logu hasta kaydı diye yazılıyordu.
    private const int LogAvans = 1257;
    private const int LogKesinti = 1258;

    private const short Taslak = 0, Onayda = 1, Onaylandi = 2, Reddedildi = 3,
                        Odendi = 4, Kapandi = 5, Iptal = 8;

    public sealed class AvansIstegi
    {
        public int TarafId { get; set; }
        public decimal Tutar { get; set; }
        public short TaksitSayisi { get; set; } = 1;
        /// <summary>İlk kesinti dönemi "yyyy-MM"; boşsa gelecek ay.</summary>
        public string? IlkDonem { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class AvansOdemeIstegi
    {
        /// <summary>Kasa/banka hesabı.</summary>
        public int HesapId { get; set; }
        /// <summary>31 nakit · 32 havale/EFT (kasa_islem_turu).</summary>
        public short Tur { get; set; } = 32;
        public DateOnly? Tarih { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class KesintiIstegi
    {
        public int KesintiId { get; set; }
        public DateOnly? Tarih { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class GerekceIstegi { public string? Gerekce { get; set; } }

    public static void AvansUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik").WithTags("Avans").RequireAuthorization();

        // ------------------------------------------------------ talep aç ----
        grup.MapPost("/avans", async (
            AvansIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.avans", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Personel zorunlu.",
                    new AlanHatasi("tarafId", "Avans bir personele açılır."));
            if (istek.Tutar <= 0)
                throw GentegreHatasi.Dogrulama("Tutar zorunlu.",
                    new AlanHatasi("tutar", "Avans tutarı sıfırdan büyük olmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var azami = (short)await AyarSayiAsync(baglanti, "ik.avans_azami_taksit", 6, iptal);
            var taksit = istek.TaksitSayisi < 1 ? (short)1 : istek.TaksitSayisi;
            // AZAMİ TAKSİT KURUM AYARI: sınırsız taksit, avansı maaş
            //   kesintisi olmaktan çıkarıp sonu gelmeyen bir borca çevirir.
            if (taksit > azami)
                throw GentegreHatasi.IsKurali(
                    $"Azami taksit {azami} - daha uzun vade kurum ayarından açılır.");

            var p = await baglanti.TekAsync("""
                select t.personel, p.sube_id as "subeId"
                  from public.taraf t
                  left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [istek.TarafId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Personel bulunamadı.");
            if (Convert.ToInt16(p["personel"] ?? (short)0) != 1)
                throw GentegreHatasi.IsKurali("Bu kart personel değil - avans açılamaz.");

            var donem = (istek.IlkDonem ?? "").Trim();
            if (donem.Length == 0)
                donem = DateTime.Today.AddMonths(1).ToString("yyyy-MM");
            if (!System.Text.RegularExpressions.Regex.IsMatch(donem, @"^\d{4}-\d{2}$"))
                throw GentegreHatasi.Dogrulama("Dönem biçimi yyyy-AA olmalı.",
                    new AlanHatasi("ilkDonem", "Örnek: 2026-11"));

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.personel_avans
                       (taraf_id, tutar, taksit_sayisi, ilk_donem, gerekce,
                        durum, talep_tarihi, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 0, current_date, @p5, @p6)
                returning id
                """, islem,
                [istek.TarafId, istek.Tutar, taksit, donem, istek.Gerekce ?? "",
                 baglam.SubeId ?? p["subeId"], baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogAvans, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.TarafId, istek.Tutar, taksit, donem }, iptal: iptal);

            await islem.CommitAsync(iptal);

            // AÇIK AVANS UYARISI: engel değil, ek onay basamağı (bkz. başlık).
            var acik = await AcikAvansAsync(baglanti, istek.TarafId, id, iptal);
            var uyarilar = new List<string>();
            if (acik > 0)
                uyarilar.Add($"Bu personelin {acik} açık avansı var - onaya "
                             + "gönderilirse zincire \"İK (açık avans)\" basamağı eklenir.");

            return Results.Ok(new { id, tutar = istek.Tutar, taksit, ilkDonem = donem,
                                    durum = Taslak, uyarilar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------- onaya gönder ----
        grup.MapPost("/avans/{id:int}/gonder", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.avans", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.taraf_id as "tarafId", a.tutar, a.durum,
                       p.yonetici_taraf_id as "amirId"
                  from public.personel_avans a
                  left join public.taraf_personel p on p.id = a.taraf_id
                 where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Avans bulunamadı.");

            var durum = Convert.ToInt16(a["durum"] ?? (short)0);
            if (durum >= Onaylandi)
                throw GentegreHatasi.IsKurali("Karara bağlanmış avans yeniden gönderilemez.");
            if (a["amirId"] is null)
                throw GentegreHatasi.IsKurali(
                    "Personelin âmiri tanımlı değil - avans onaya gönderilemez. "
                    + "Personel kartındaki \"Yönetici\" alanını doldurun.");

            var tarafId = Convert.ToInt32(a["tarafId"]);
            var tutar = Convert.ToDecimal(a["tutar"] ?? 0m);

            var bayraklar = new List<string>();
            if (await AcikAvansAsync(baglanti, tarafId, id, iptal) > 0)
                bayraklar.Add("acik_avans");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var zincir = await onay.BaslatAsync(baglanti, islem, "personel.avans",
                id, tutar, bayraklar, baglam, iptal, sahipTarafId: tarafId);

            await baglanti.CalistirAsync("""
                update public.personel_avans set durum = @p1,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Onayda, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogAvans, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Onayda, tutar, bayraklar }, iptal: iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            return Results.Ok(new
            {
                durum = Onayda, tutar, bayraklar,
                basamaklar = zincir.Adimlar.Select(a2 => new { a2.Sira, a2.Ad, a2.Rol }),
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- ödeme ----
        // ÖDEME ONAYDAN SONRA: ödeyip sonra onaylatmak onayı süse çevirir.
        grup.MapPost("/avans/{id:int}/ode", async (
            int id, AvansOdemeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // TEK YETKİ: `ik.avans_ode` zaten dar ve adı tam bu işi söylüyor.
            //   Ayrıca `kasa` yetkisi istemek, avans ödeyecek İK personeline
            //   kasa modülünün tamamını açtırmak ya da ödemeyi hiç
            //   yapamamak demekti - kasa işlemini kullanıcı değil sistem
            //   yazıyor, kimse kasa ekranına girmiyor.
            baglam.AksiyonIste("ik.avans_ode");

            if (istek.HesapId <= 0)
                throw GentegreHatasi.Dogrulama("Kasa/banka hesabı zorunlu.",
                    new AlanHatasi("hesapId", "Ödemenin çıkacağı hesap seçilmeli."));

            await using var baglanti = await veri.AcAsync(iptal);

            var a = await baglanti.TekAsync("""
                select a.taraf_id as "tarafId", a.tutar, a.durum, a.taksit_sayisi as "taksit",
                       a.ilk_donem as "ilkDonem", a.odeme_islem_id as "odemeId",
                       a.sube_id as "subeId", coalesce(nullif(t.unvan, ''), '') as ad
                  from public.personel_avans a
                  join public.taraf t on t.id = a.taraf_id
                 where a.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Avans bulunamadı.");

            var durum = Convert.ToInt16(a["durum"] ?? (short)0);
            if (durum != Onaylandi)
                throw GentegreHatasi.IsKurali(durum >= Odendi
                    ? "Bu avans zaten ödenmiş."
                    : "Yalnız ONAYLANMIŞ avans ödenir - önce onay zincirini tamamlayın.");

            var tutar = Convert.ToDecimal(a["tutar"] ?? 0m);
            var tarih = (istek.Tarih ?? DateOnly.FromDateTime(DateTime.Today))
                .ToDateTime(TimeOnly.MinValue);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // KASA İŞLEMİ: ödeme yönü çıkış (tür 31 nakit / 32 havale).
            //   `kaynak_tur`/`kaynak_id` avansı gösterir - kasa ekstresinden
            //   "bu para neydi" sorusu yanıtlanabilsin.
            var islemId = await baglanti.TekDegerAsync<long>("""
                insert into public.kasa_islem
                       (tur, islem_tarihi, durum, taraf_id, hesap_id, doviz_cinsi,
                        tutar, doviz_kuru, yerel_tutar, kaynak_tur, kaynak_id,
                        aciklama, sube_id, ekleyen)
                values (@p0, @p1, 1, @p2, @p3, 'TL', @p4, 1, @p4, @p5, @p6, @p7, @p8, @p9)
                returning id
                """, islem,
                [istek.Tur, tarih, Convert.ToInt32(a["tarafId"]), istek.HesapId, tutar,
                 (short)LogAvans, id,
                 istek.Aciklama ?? $"Personel avansı - {a["ad"]}",
                 baglam.SubeId ?? a["subeId"], baglam.KullaniciId], iptal);

            // MAHSUP PLANI ÖDEMEYLE BİRLİKTE DOĞAR: avans ödenmeden kesinti
            //   planlamak, olmayan bir borcu takvimlemek olurdu.
            var taksit = Convert.ToInt16(a["taksit"] ?? (short)1);
            var ilkDonem = a["ilkDonem"] as string ?? "";
            var bas = DateTime.TryParse(ilkDonem + "-01", out var d0)
                ? d0 : DateTime.Today.AddMonths(1);

            // SON TAKSİT KALANI ALIR: 1000/3 = 333,33 üç kez yazılırsa
            //   1 kuruş açık kalır ve avans hiç kapanmaz.
            var taban = Math.Round(tutar / taksit, 2, MidpointRounding.ToZero);
            for (short i = 1; i <= taksit; i++)
            {
                var t = i == taksit ? tutar - taban * (taksit - 1) : taban;
                await baglanti.CalistirAsync("""
                    insert into public.personel_avans_kesinti
                           (avans_id, sira, donem, tutar, durum, ekleyen)
                    values (@p0, @p1, @p2, @p3, 0, @p4)
                    """, islem,
                    [id, i, bas.AddMonths(i - 1).ToString("yyyy-MM"), t,
                     baglam.KullaniciId], iptal);
            }

            await baglanti.CalistirAsync("""
                update public.personel_avans
                   set durum = @p1, odeme_islem_id = @p2, odeme_tarihi = @p3,
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Odendi, islemId, tarih, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogAvans, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Odendi, tutar, islemId, taksit }, iptal: iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                durum = Odendi, tutar, kasaIslemId = islemId, taksit,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------- kesinti işle ----
        grup.MapPost("/avans/{id:int}/kesinti", async (
            int id, KesintiIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.avans", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            // BEKLEYEN EN ESKİ TAKSİT: sıra atlanmaz - üçüncü ayı kesip
            //   birinciyi açık bırakmak, kalan tutarı doğru ama planı yalan
            //   yapar.
            var k = await baglanti.TekAsync("""
                select k.id, k.sira, k.donem, k.tutar
                  from public.personel_avans_kesinti k
                 where k.avans_id = @p0 and k.durum = 0
                   and (@p1 = 0 or k.id = @p1)
                 order by k.sira limit 1
                """, null, [id, istek.KesintiId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.IsKurali("Bekleyen kesinti yok.");

            var kesintiId = Convert.ToInt32(k["id"]);
            var tarih = (istek.Tarih ?? DateOnly.FromDateTime(DateTime.Today))
                .ToDateTime(TimeOnly.MinValue);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.personel_avans_kesinti
                   set durum = 1, kesinti_tarihi = @p1,
                       aciklama = coalesce(nullif(@p2, ''), aciklama),
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [kesintiId, tarih, istek.Aciklama ?? "",
                             baglam.KullaniciId], iptal);

            // SON TAKSİT KESİLİNCE AVANS KAPANIR: "ödendi" ile "kapandı"
            //   ayrı - biri parayı, öteki borcu anlatır.
            var kalan = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.personel_avans_kesinti
                 where avans_id = @p0 and durum = 0
                """, islem, [id], iptal);

            if (kalan == 0)
                await baglanti.CalistirAsync("""
                    update public.personel_avans set durum = @p1,
                           degistiren = @p2, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, Kapandi, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogKesinti,
                kesintiId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { avansId = id, sira = k["sira"], donem = k["donem"],
                      tutar = k["tutar"], kalanTaksit = kalan },
                LogAvans, id, iptal: iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                kesintiId, sira = k["sira"], donem = k["donem"], tutar = k["tutar"],
                kalanTaksit = kalan, avansDurum = kalan == 0 ? Kapandi : Odendi,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- iptal ----
        grup.MapPost("/avans/{id:int}/iptal", async (
            int id, GerekceIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.avans", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("İptal gerekçesi zorunlu.",
                    new AlanHatasi("gerekce", "Neden iptal edildiği yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<short?>(
                "select durum from public.personel_avans where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Avans bulunamadı.");

            // ÖDENMİŞ AVANS İPTAL EDİLMEZ: para çıkmıştır. Geri almak ayrı
            //   bir işlemdir (tahsilat) ve kasadan geçer.
            if (durum >= Odendi && durum != Iptal)
                throw GentegreHatasi.IsKurali(
                    "Ödenmiş avans iptal edilemez - para çıkmıştır. Geri alım "
                    + "ayrı bir tahsilat işlemidir.");
            if (durum == Iptal)
                throw GentegreHatasi.IsKurali("Avans zaten iptal edilmiş.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await Servisler.OnayMotoru.IptalAsync(baglanti, islem, LogAvans, id,
                "Avans iptal edildi", iptal);

            await baglanti.CalistirAsync("""
                update public.personel_avans
                   set durum = @p1, iptal_neden = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Iptal, istek.Gerekce, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogAvans, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Iptal, gerekce = istek.Gerekce }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = Iptal, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Personelin kapanmamış (ödenmiş ama mahsubu bitmemiş) avansları.</summary>
    private static async Task<int> AcikAvansAsync(
        Npgsql.NpgsqlConnection baglanti, int tarafId, int haric,
        CancellationToken iptal)
        => await baglanti.TekDegerAsync<int>("""
            select count(*) from public.personel_avans a
             where a.taraf_id = @p0 and a.id <> @p1
               and a.durum in (1, 2, 4)
            """, null, [tarafId, haric], iptal);

    private static async Task<decimal> AyarSayiAsync(
        Npgsql.NpgsqlConnection baglanti, string anahtar, decimal varsayilan,
        CancellationToken iptal)
    {
        var m = await AyarDeposu.MetinAsync(baglanti, null, anahtar, "", iptal);
        return decimal.TryParse(m, System.Globalization.NumberStyles.Any,
                   System.Globalization.CultureInfo.InvariantCulture, out var d) && d > 0
            ? d : varsayilan;
    }
}
