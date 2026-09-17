using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İZİN UÇLARI (743).
///
/// ============ İZİN BİR TALEPTİR, KAYIT DEĞİL ==========================
/// `personel_izin` 052'den beri vardı ama bir kayıt defteriydi: "onaylı"
/// yazılabiliyordu, kimin onayladığı hiçbir yerde durmuyordu. Artık izin
/// onay omurgasından (738) geçiyor - âmir, İK, gerekirse üst yönetim.
///
/// ============ GÜN SAYISINI SUNUCU HESAPLAR ============================
/// Başlangıç ve bitişten hesaplanır (`fn_izin_gun`); istemciden gelen gün
/// sayısına güvenilmez. İki yerde hesaplansaydı ekranın gösterdiği ile
/// bakiyeden düşen farklı olabilirdi - ve fark kimsenin dikkatini
/// çekmeden bakiyeyi eritirdi.
///
/// ============ BAKİYE AŞIMI ENGEL DEĞİL, BASAMAK =======================
/// Hakkı olmayan personele izin vermek yasak değil: ücretsiz izin ya da
/// avans izin olur. Ama bu AYRI BİR KARARDIR - engellemek yerine zincire
/// "bakiye aşımı" bayrağıyla İK basamağı ekleniyor.
/// </summary>
public static class IzinUclari
{
    /// <summary>islem_log.tablo_id - personel_izin.</summary>
    private const int LogIzin = 904;
    /// <summary>islem_log.tablo_id - resmi_tatil.</summary>
    // 1262 (756): 906 Acil Durum Kişi'nin, 749'da yanlışlıkla alınmıştı.
    private const int LogTatil = 1262;

    private const short Taslak = 0, Onayda = 1, Onayli = 2,
                        Reddedildi = 3, Iptal = 4;

    public sealed class IzinIstegi
    {
        public int TarafId { get; set; }
        /// <summary>1 yıllık · 2 mazeret · 3 rapor · 4 ücretsiz · 9 diğer</summary>
        public short Tur { get; set; } = 1;
        public DateOnly? Baslangic { get; set; }
        public DateOnly? Bitis { get; set; }
        public bool IsGunu { get; set; }
        public string? Aciklama { get; set; }
        public string? BelgeNo { get; set; }
        public int? YerineId { get; set; }
    }

    public sealed class IzinKararIstegi
    {
        public string? Gerekce { get; set; }
    }

    public static void IzinUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ik").WithTags("İzin").RequireAuthorization();

        // -------------------------------------------------------- bakiye ----
        grup.MapGet("/personel/{tarafId:int}/izin-bakiye", async (
            int tarafId, int? yil, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.izin", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await BakiyeAsync(baglanti, tarafId, yil, iptal)
                with { IzlemeNo = baglam.IzlemeNo });
        });

        // ---------------------------------------------------- talep aç ----
        grup.MapPost("/izin", async (
            IzinIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.izin", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Personel zorunlu.",
                    new AlanHatasi("tarafId", "İzin bir personele açılır."));
            if (istek.Baslangic is null || istek.Bitis is null)
                throw GentegreHatasi.Dogrulama("Tarih zorunlu.",
                    new AlanHatasi("baslangic", "Başlangıç ve bitiş tarihi girilmeli."));
            if (istek.Bitis < istek.Baslangic)
                throw GentegreHatasi.Dogrulama("Bitiş başlangıçtan önce olamaz.",
                    new AlanHatasi("bitis", "Bitiş tarihi başlangıçtan önce."));

            await using var baglanti = await veri.AcAsync(iptal);

            var p = await baglanti.TekAsync("""
                select coalesce(nullif(t.unvan, ''), '') as ad, t.personel,
                       p.sube_id as "subeId"
                  from public.taraf t
                  left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [istek.TarafId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Personel bulunamadı.");

            if (Convert.ToInt16(p["personel"] ?? (short)0) != 1)
                throw GentegreHatasi.IsKurali("Bu kart personel değil - izin açılamaz.");

            // ÇAKIŞAN İZİN: aynı personelin aynı günlerde ikinci izni olmaz.
            //   Bakiyeyi iki kez düşürür ve hangi iznin geçerli olduğu
            //   belirsiz kalır.
            var cakisan = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.personel_izin i
                 where i.taraf_id = @p0 and i.durum in (0, 1, 2)
                   and i.baslangic_tarihi <= @p2 and i.bitis_tarihi >= @p1
                """, null,
                [istek.TarafId, istek.Baslangic.Value.ToDateTime(TimeOnly.MinValue),
                 istek.Bitis.Value.ToDateTime(TimeOnly.MinValue)], iptal);
            if (cakisan > 0)
                throw GentegreHatasi.IsKurali(
                    "Bu personelin aynı tarihlerde başka bir izni var.");

            // ŞUBE GEÇİLİR (751): yerel tatil (şubenin kurtuluş günü) yalnız
            //   o şubenin hesabından düşmeli. Şubesiz çağırsaydık fonksiyon
            //   yalnız kurum genelini sayar ve yerel tatil hiç düşmezdi.
            var izinSube = baglam.SubeId ?? p["subeId"] as int?;
            var gun = await baglanti.TekDegerAsync<decimal>(
                "select public.fn_izin_gun(@p0::date, @p1::date, @p2::smallint, @p3)",
                null,
                [istek.Baslangic.Value.ToDateTime(TimeOnly.MinValue),
                 istek.Bitis.Value.ToDateTime(TimeOnly.MinValue),
                 (short)(istek.IsGunu ? 1 : 0), izinSube], iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.personel_izin
                       (taraf_id, tur, baslangic_tarihi, bitis_tarihi, gun, is_gunu,
                        aciklama, belge_no, yerine_id, durum, talep_tarihi,
                        sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, 0, current_date,
                        @p9, @p10)
                returning id
                """, islem,
                [istek.TarafId, istek.Tur,
                 istek.Baslangic.Value.ToDateTime(TimeOnly.MinValue),
                 istek.Bitis.Value.ToDateTime(TimeOnly.MinValue),
                 gun, (short)(istek.IsGunu ? 1 : 0), istek.Aciklama ?? "",
                 istek.BelgeNo ?? "", istek.YerineId,
                 baglam.SubeId ?? p["subeId"], baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogIzin, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.TarafId, istek.Tur, gun, durum = Taslak }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var bakiye = await BakiyeAsync(baglanti, istek.TarafId, null, iptal);
            var uyarilar = new List<string>();

            // O TARİHLERDEKİ RANDEVULAR (748): izin onaylanınca hekimin
            //   takvimi kapanır ama VAR OLAN randevular kendiliğinden
            //   taşınmaz. Sayıyı talep anında söylemek, kimin kiminle
            //   konuşacağını belirler; onaylandıktan sonra söylemek
            //   hastanın kapıda öğrenmesi demektir.
            var randevu = await RandevuSayisiAsync(baglanti, istek.TarafId,
                istek.Baslangic.Value, istek.Bitis.Value, iptal);
            if (randevu > 0)
                uyarilar.Add($"Bu tarihlerde {randevu} randevusu var - izin onaylanırsa "
                             + "takvim kapanır ama randevular taşınmaz.");

            if (istek.Tur == 1 && bakiye.Kalan < gun)
                uyarilar.Add($"Bakiye yetersiz: kalan {bakiye.Kalan:N1} gün, "
                             + $"talep {gun:N1} gün. Onaya gönderilirse zincire "
                             + "İK (bakiye aşımı) basamağı eklenir.");
            if (bakiye.HakGun is null)
                uyarilar.Add("Personelin işe giriş tarihi girilmemiş - yıllık izin "
                             + "hakkı hesaplanamıyor.");

            return Results.Ok(new
            {
                id, gun, durum = Taslak, bakiye, uyarilar, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------- millî tatil üret ----
        // YALNIZ MİLLÎ TATİLLER: dinî bayramlar hicrî takvime bağlı ve
        //   Diyanet'in ilanına göre kayar. Algoritmayla üretmiyoruz - bir
        //   gün kayan hesap izin gününü ve bordroyu yanlış hesaplar;
        //   "yaklaşık doğru" bir tatil takvimini kimse kontrol etmez.
        grup.MapPost("/tatil/uret/{yil:int}", async (
            int yil, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.tatil", Islem.Ekle);

            if (yil < 2000 || yil > 2100)
                throw GentegreHatasi.Dogrulama("Geçersiz yıl.",
                    new AlanHatasi("yil", "2000-2100 arası bir yıl verin."));

            await using var baglanti = await veri.AcAsync(iptal);

            var eklenen = await baglanti.TekDegerAsync<int>(
                "select public.fn_resmi_tatil_uret(@p0, @p1)", null,
                [yil, baglam.KullaniciId], iptal);

            var dini = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.resmi_tatil
                 where tur = 2 and extract(year from tarih) = @p0
                """, null, [yil], iptal);

            await log.YazAsync(LogIslemi.Ekle, LogTatil, yil, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { yil, eklenen }, iptal: iptal);

            var uyarilar = new List<string>();
            if (dini == 0)
                uyarilar.Add($"{yil} yılında tanımlı DİNÎ bayram yok. Ramazan ve "
                             + "Kurban bayramları hicrî takvime bağlıdır ve "
                             + "üretilmez - Diyanet takvimine göre elle girin.");

            return Results.Ok(new { yil, eklenen, dini, uyarilar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------- onaya gönder ----
        grup.MapPost("/izin/{id:int}/gonder", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            Servisler.OnayMotoru onay, Servisler.OnayBildirimi haber,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.izin", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var i = await baglanti.TekAsync("""
                select i.taraf_id as "tarafId", i.tur, i.gun, i.durum,
                       i.baslangic_tarihi as "baslangic", i.bitis_tarihi as "bitis",
                       p.yonetici_taraf_id as "amirId",
                       p.ise_giris_tarihi as "iseGiris"
                  from public.personel_izin i
                  left join public.taraf_personel p on p.id = i.taraf_id
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İzin bulunamadı.");

            var durum = Convert.ToInt16(i["durum"] ?? (short)0);
            if (durum is Onayli or Reddedildi or Iptal)
                throw GentegreHatasi.IsKurali("Kapanmış izin onaya gönderilemez.");

            var tarafId = Convert.ToInt32(i["tarafId"]);
            var gun = Convert.ToDecimal(i["gun"] ?? 0m);
            var tur = Convert.ToInt16(i["tur"] ?? (short)1);

            // ÂMİRSİZ PERSONEL: zincirin ilk basamağı kimseye düşmez.
            //   Sessizce geçseydik izin, kimsenin kutusunda görünmeden
            //   İK'ya kalırdı - ve âmirin haberi hiç olmazdı.
            if (i["amirId"] is null)
                throw GentegreHatasi.IsKurali(
                    "Personelin âmiri tanımlı değil - izin onaya gönderilemez. "
                    + "Personel kartındaki \"Yönetici\" alanını doldurun.");

            // BAKİYE AŞIMI BAYRAĞI: engel değil, ek basamak (bkz. başlık).
            var bakiye = await BakiyeAsync(baglanti, tarafId, null, iptal);
            var bayraklar = new List<string>();
            if (tur == 1 && bakiye.Kalan < gun) bayraklar.Add("bakiye_asildi");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var zincir = await onay.BaslatAsync(baglanti, islem, "personel.izin",
                id, gun, bayraklar, baglam, iptal, sahipTarafId: tarafId);

            await baglanti.CalistirAsync("""
                update public.personel_izin
                   set durum = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Onayda, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIzin, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Onayda, gun, bayraklar, basamak = zincir.Adimlar.Count },
                iptal: iptal);

            await islem.CommitAsync(iptal);

            try
            {
                await haber.SiradakiniBildirAsync(baglanti, zincir.OnayId,
                    baglam.KullaniciId, baglam.SubeId, iptal);
            }
            catch (Exception) { /* zincir kuruldu; bildirim hatası onu düşürmez */ }

            var randevu = await RandevuSayisiAsync(baglanti, tarafId,
                DateOnly.FromDateTime(Convert.ToDateTime(i["baslangic"])),
                DateOnly.FromDateTime(Convert.ToDateTime(i["bitis"])), iptal);

            return Results.Ok(new
            {
                durum = Onayda, gun, bayraklar, randevu,
                basamaklar = zincir.Adimlar.Select(a => new { a.Sira, a.Ad, a.Rol }),
                bakiye, izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------- iptal ----
        // ONAYLI İZİN DE İPTAL EDİLİR ama gerekçeyle: personel vazgeçebilir,
        //   kurum geri çağırabilir. Silmek yerine iptal ediyoruz - "bu izin
        //   alınmış mıydı" sorusu sonradan da sorulur.
        grup.MapPost("/izin/{id:int}/iptal", async (
            int id, IzinKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ik.izin", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("İptal gerekçesi zorunlu.",
                    new AlanHatasi("gerekce", "Neden iptal edildiği yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var d = await baglanti.TekDegerAsync<short?>(
                "select durum from public.personel_izin where id = @p0", null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("İzin bulunamadı.");

            if (d == Iptal) throw GentegreHatasi.IsKurali("İzin zaten iptal edilmiş.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // YÜRÜYEN ZİNCİR DE KAPANIR: iptal edilmiş bir iznin onayı
            //   kimsenin kutusunda beklememeli.
            await Servisler.OnayMotoru.IptalAsync(baglanti, islem, LogIzin, id,
                "İzin iptal edildi", iptal);

            await baglanti.CalistirAsync("""
                update public.personel_izin
                   set durum = @p1, iptal_neden = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, Iptal, istek.Gerekce, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIzin, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = Iptal, gerekce = istek.Gerekce }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = Iptal, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Personelin o tarih aralığındaki AÇIK randevuları (1 planlandı, 2 geldi).
    /// İzin onaylanınca takvim kapanır ama var olan randevular taşınmaz -
    /// bunu kimin çözeceği kurumun işi, ama sayının görünmesi bizim işimiz.
    /// </summary>
    private static async Task<int> RandevuSayisiAsync(
        Npgsql.NpgsqlConnection baglanti, int tarafId, DateOnly bas, DateOnly bit,
        CancellationToken iptal)
        => await baglanti.TekDegerAsync<int>("""
            select count(*) from public.randevu r
             where r.hekim_id = @p0 and r.durum in (1, 2)
               and r.baslangic::date between @p1 and @p2
            """, null,
            [tarafId, bas.ToDateTime(TimeOnly.MinValue), bit.ToDateTime(TimeOnly.MinValue)],
            iptal);

    // ========================================================== bakiye ==

    public sealed record BakiyeYaniti(int TarafId, string PersonelAd, short Yil,
        decimal? HakGun, decimal DevirGun, decimal EkGun, decimal KullanilanGun,
        decimal PlanlananGun, decimal OnaydaGun, decimal Kalan, string? Not,
        string IzlemeNo = "");

    /// <summary>
    /// KALAN = hak + devir + ek − kullanılan − planlanan − onayda.
    ///
    /// ONAYDA OLAN DA DÜŞÜLÜR: henüz onaylanmamış bir talep bakiyeyi
    /// taahhüt etmez ama personel ikinci kez aynı günü isteyebilir.
    /// Düşmeseydik iki talep birden onaylanır ve bakiye eksiye düşerdi.
    /// </summary>
    private static async Task<BakiyeYaniti> BakiyeAsync(
        Npgsql.NpgsqlConnection baglanti, int tarafId, int? yil,
        CancellationToken iptal)
    {
        var b = await baglanti.TekAsync("""
            select v.taraf_id as "tarafId", v.personel_ad as "personelAd", v.yil,
                   v.hak_gun as "hakGun", v.devir_gun as "devirGun", v.ek_gun as "ekGun",
                   v.kullanilan_gun as "kullanilanGun", v.planlanan_gun as "planlananGun",
                   v.onayda_gun as "onaydaGun", v.ise_giris_tarihi as "iseGiris"
              from public.v_personel_izin_bakiye v
             where v.taraf_id = @p0 and (@p1::int is null or v.yil = @p1)
             limit 1
            """, null, [tarafId, yil], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Personel bulunamadı.");

        var hak = b["hakGun"] as decimal?;
        var devir = Convert.ToDecimal(b["devirGun"] ?? 0m);
        var ek = Convert.ToDecimal(b["ekGun"] ?? 0m);
        var kul = Convert.ToDecimal(b["kullanilanGun"] ?? 0m);
        var plan = Convert.ToDecimal(b["planlananGun"] ?? 0m);
        var onayda = Convert.ToDecimal(b["onaydaGun"] ?? 0m);

        var not = hak is null
            ? "İşe giriş tarihi girilmemiş - kanunî hak hesaplanamıyor."
            : hak == 0 ? "Bir yılını doldurmamış - yıllık izin hakkı henüz doğmadı."
            : null;

        return new BakiyeYaniti(tarafId, b["personelAd"] as string ?? "",
            Convert.ToInt16(b["yil"] ?? (short)0), hak, devir, ek, kul, plan, onayda,
            (hak ?? 0) + devir + ek - kul - plan - onayda, not);
    }
}
