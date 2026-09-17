using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEKNİK SERVİS UÇLARI (773) — çağrı · iş emri · ziyaret.
///
/// ============ ÜÇ KATMAN, ÜÇ AYRI SORU =================================
/// <list type="bullet">
///   <item><b>Çağrı</b> müşterinin aramasıdır; SLA saati onunla başlar ve
///   atanmamış çağrıda da işler - kimsenin işi olmaması taahhüdü durdurmaz.</item>
///   <item><b>İş emri</b> o çağrıyı kapatmak için yapılan iştir.</item>
///   <item><b>Ziyaret</b> bir gidiştir; bir çağrının birden çok ziyareti olur.
///   İkinci ziyaret ücretsiz bir yoldur ve ancak ayrı kayıtsa ölçülebilir.</item>
/// </list>
///
/// ============ TEK İŞ EMRİ, İKİ SAHİPLİK ===============================
/// İç iş kurumun demirbaşıdır (ücret yok, maliyet birime); dış iş müşterinin
/// cihazıdır (ücretli, faturaya döner). Aynı tablo, aynı akış - değişen tek
/// şey paranın kime yazıldığı.
///
/// ============ KAPANIŞ BİR KAPIDIR =====================================
/// Emanet cihaz iade edilmeden ve ziyaret imzalanmadan iş emri kapanmaz.
/// Kapanan iş emriyle unutulan emanet, envanterde "depoda" yazan ama sahada
/// duran cihaz demektir.
/// </summary>
public static class TeknikServisUclari
{
    /// <summary>islem_log.tablo_id — demirbas_is_emri (1224, 752'den beri).</summary>
    private const int LogIsEmri = 1224;
    /// <summary>islem_log.tablo_id — servis_cagri (773).</summary>
    private const int LogCagri = 1316;
    /// <summary>islem_log.tablo_id — servis_ziyaret (773).</summary>
    private const int LogZiyaret = 1317;
    /// <summary>islem_log.tablo_id — servis_emanet (773).</summary>
    private const int LogEmanet = 1318;

    private const short IcIs = 1, DisIs = 2;
    // servis_cagri.durum
    private const short CagriAcik = 0, CagriAtandi = 1, CagriParca = 4,
                        CagriCozuldu = 5, CagriIptal = 8;
    // servis_ziyaret.sonuc
    private const short ZiyaretSuruyor = 0, ZiyaretCozuldu = 1;

    public sealed class CagriIstegi
    {
        public int TarafId { get; set; }
        public int? TarafCihazId { get; set; }
        public int? SozlesmeId { get; set; }
        public string? CihazMetni { get; set; }
        public string? Sikayet { get; set; }
        public short? KapsamTur { get; set; }
        public short? Oncelik { get; set; }
        public string? Bildiren { get; set; }
        public string? Telefon { get; set; }
    }

    public sealed class IsEmriIstegi
    {
        /// <summary>Verilmezse çağrının sahibi/cihazı devralınır.</summary>
        public short? Tur { get; set; }
        public int? YapanId { get; set; }
        public DateOnly? Planlanan { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class ZiyaretIstegi
    {
        public int? TeknisyenId { get; set; }
        public DateTimeOffset? PlanZamani { get; set; }
        public string? Arac { get; set; }
    }

    public sealed class ZiyaretKapatIstegi
    {
        public string? Yapilan { get; set; }
        public short? Sonuc { get; set; }
        public string? SonucMetni { get; set; }
        public decimal? YolKm { get; set; }
        public decimal? IscilikSaat { get; set; }
        public decimal? Tutar { get; set; }
        public bool ImzaAlindi { get; set; }
        public string? ImzaNotu { get; set; }
        public bool MesaiDisi { get; set; }
    }

    public sealed class EmanetIstegi
    {
        public int? TarafId { get; set; }
        public int? DemirbasId { get; set; }
        public string? CihazMetni { get; set; }
        public string? Aciklama { get; set; }
    }

    public sealed class TeslimIstegi { public string? Not { get; set; } }

    public static void TeknikServisUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/servis").WithTags("Teknik Servis")
                      .RequireAuthorization();

        // ------------------------------------------------------- çağrı ----
        // SLA AÇILIŞTA YAZILIR, atama beklenmez. Sözleşme varsa onun saati,
        //   yoksa kurum varsayılanı; ayar da yoksa SLA YOKTUR - uydurulmuş bir
        //   taahhüt, tutulmadığında kimsenin sözünü vermediği bir borç yaratır.
        grup.MapPost("/cagri", async (
            CagriIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Ekle);

            if (istek.TarafId <= 0)
                throw GentegreHatasi.Dogrulama("Müşteri zorunlu.",
                    new AlanHatasi("tarafId", "Çağrı bir cariye açılır."));
            if (string.IsNullOrWhiteSpace(istek.Sikayet))
                throw GentegreHatasi.Dogrulama("Şikâyet zorunlu.",
                    new AlanHatasi("sikayet",
                        "Müşterinin ne anlattığı yazılmadan çağrı açılmaz."));

            await using var baglanti = await veri.AcAsync(iptal);

            // SÖZLEŞME VERİLMEDİYSE CİHAZINKİ: kullanıcı her çağrıda sözleşme
            //   seçmek zorunda kalmamalı, ama SLA yanlış hesaplanmamalı.
            var sozlesme = istek.SozlesmeId;
            if (sozlesme is null && istek.TarafCihazId is > 0)
                sozlesme = await baglanti.TekDegerAsync<int?>("""
                    select sozlesme_id from public.taraf_cihaz where id = @p0
                    """, null, [istek.TarafCihazId], iptal);
            sozlesme ??= await baglanti.TekDegerAsync<int?>("""
                select id from public.servis_sozlesme
                 where taraf_id = @p0 and durum = 1
                   and current_date between baslangic and bitis
                 order by bitis desc limit 1
                """, null, [istek.TarafId], iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await baglanti.TekDegerAsync<long>("""
                insert into public.servis_cagri
                       (cagri_no, sube_id, taraf_id, taraf_cihaz_id, sozlesme_id,
                        cihaz_metni, sikayet, kapsam_tur, oncelik, bildiren,
                        telefon, durum, ekleyen, sla_bitis)
                values (public.fn_numara_kimlik_uret(909, @p1, 'servis_cagri',
                                                     'cagri_no'),
                        @p1, @p0, @p2, @p3, @p4, @p5, coalesce(@p6, 1),
                        coalesce(@p7, 3), @p8, @p9, 0, @p10,
                        public.fn_servis_sla_bitis(@p3, now()))
                returning id
                """, islem,
                [istek.TarafId, baglam.SubeId ?? 0, istek.TarafCihazId, sozlesme,
                 istek.CihazMetni ?? "", istek.Sikayet, istek.KapsamTur,
                 istek.Oncelik, istek.Bildiren ?? "", istek.Telefon ?? "",
                 baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogCagri, (int)id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.TarafId, istek.Sikayet, sozlesmeId = sozlesme }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var y = await baglanti.TekAsync("""
                select cagri_no, sla_bitis, sla_kalan_dk, kapsam_adi
                  from public.v_servis_cagri where id = @p0
                """, null, [id],
                o => new
                {
                    cagriNo = o.Metin("cagri_no"),
                    slaBitis = o.IsDBNull(o.GetOrdinal("sla_bitis"))
                        ? (DateTimeOffset?)null
                        : o.GetFieldValue<DateTimeOffset>(o.GetOrdinal("sla_bitis")),
                    slaKalanDk = o.IsDBNull(o.GetOrdinal("sla_kalan_dk"))
                        ? (int?)null : o.Sayi("sla_kalan_dk"),
                    kapsam = o.Metin("kapsam_adi"),
                }, iptal);

            return Results.Ok(new
            {
                id, y?.cagriNo, y?.slaBitis, y?.slaKalanDk, y?.kapsam,
                sozlesmeId = sozlesme,
                mesaj = y?.slaBitis is null
                    ? "Çağrı açıldı. Sözleşme ve varsayılan SLA yok - taahhüt süresi işlemiyor."
                    : $"Çağrı açıldı. SLA: {y.slaBitis:dd.MM.yyyy HH:mm}",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------ çağrıdan iş emri ----
        // İş emri çağrının KOPYASI DEĞİL, çocuğudur: sahip, cihaz ve kapsam
        //   çağrıdan devralınır ki iki kayıt farklı şey söylemesin.
        grup.MapPost("/cagri/{id:long}/is-emri", async (
            long id, IsEmriIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);

            var g = await baglanti.TekAsync("""
                select taraf_id, taraf_cihaz_id, sozlesme_id, kapsam_tur,
                       oncelik, sikayet, durum, sube_id
                  from public.servis_cagri where id = @p0
                """, null, [id],
                o => new
                {
                    TarafId = o.Sayi("taraf_id"),
                    CihazId = o.IsDBNull(o.GetOrdinal("taraf_cihaz_id"))
                        ? (int?)null : o.Sayi("taraf_cihaz_id"),
                    SozlesmeId = o.IsDBNull(o.GetOrdinal("sozlesme_id"))
                        ? (int?)null : o.Sayi("sozlesme_id"),
                    Kapsam = (short)o.Sayi("kapsam_tur"),
                    Oncelik = (short)o.Sayi("oncelik"),
                    Sikayet = o.Metin("sikayet"),
                    Durum = (short)o.Sayi("durum"),
                    SubeId = o.Sayi("sube_id"),
                }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");

            if (g.Durum is CagriIptal)
                throw GentegreHatasi.IsKurali("İptal edilmiş çağrıya iş emri açılamaz.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var isEmriId = await baglanti.TekDegerAsync<long>("""
                insert into public.demirbas_is_emri
                       (sube_id, sahiplik, cagri_id, musteri_taraf_id,
                        taraf_cihaz_id, sozlesme_id, kapsam_tur, tur, oncelik,
                        ariza_metni, yapan_id, planlanan, aciklama, ekleyen,
                        durum, is_emri_no)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, coalesce(@p7, 2),
                        @p8, @p9, @p10, @p11, @p12, @p13, 0,
                        -- 914 = "İş Emri No" (731); servis iş emri de aynı
                        --   diziden kesilir.
                        public.fn_numara_kimlik_uret(
                            914, @p0, 'demirbas_is_emri', 'is_emri_no'))
                returning id
                """, islem,
                [g.SubeId, DisIs, id, g.TarafId, g.CihazId, g.SozlesmeId, g.Kapsam,
                 istek.Tur, g.Oncelik, g.Sikayet, istek.YapanId,
                 istek.Planlanan, istek.Aciklama ?? "", baglam.KullaniciId], iptal);

            // ÇAĞRI "ATANDI"YA GEÇER: iş emri açmak, çağrının artık bir sahibi
            //   olduğu anlamına gelir. İlk yanıt zamanı da burada damgalanır -
            //   taahhüdün ölçüldüğü an budur.
            await baglanti.CalistirAsync("""
                update public.servis_cagri
                   set durum = case when durum = 0 then @p2 else durum end,
                       ilk_yanit = coalesce(ilk_yanit, now()),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId, CagriAtandi], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogIsEmri,
                (int)isEmriId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { cagriId = id, sahiplik = DisIs, istek.YapanId }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var no = await baglanti.TekDegerAsync<string>(
                "select is_emri_no from public.demirbas_is_emri where id = @p0",
                null, [isEmriId], iptal);

            return Results.Ok(new
            {
                id = isEmriId, isEmriNo = no, cagriId = id,
                mesaj = "İş emri açıldı, çağrı atandı olarak işaretlendi.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ----------------------------------------------------- ziyaret ----
        // Ziyaret AÇILIR (varış), sonra KAPANIR (ayrılış + sonuç + imza).
        //   Tek çağrıda yazmak, teknisyenin cihazın başında değil akşam
        //   ofiste doldurduğu bir kayıt üretirdi.
        grup.MapPost("/is-emri/{id:long}/ziyaret", async (
            long id, ZiyaretIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<short?>(
                "select durum from public.demirbas_is_emri where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");
            if (durum >= 5)
                throw GentegreHatasi.IsKurali("Kapanmış iş emrine ziyaret eklenemez.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var ziyaretId = await baglanti.TekDegerAsync<long>("""
                insert into public.servis_ziyaret
                       (is_emri_id, sira, teknisyen_id, plan_zamani, varis,
                        arac, ekleyen)
                values (@p0,
                        coalesce((select max(sira) from public.servis_ziyaret
                                   where is_emri_id = @p0), 0) + 1,
                        @p1, @p2, case when @p2::timestamptz is null then now() end,
                        @p3, @p4)
                returning id
                """, islem,
                [id, istek.TeknisyenId, istek.PlanZamani, istek.Arac ?? "",
                 baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogZiyaret,
                (int)ziyaretId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { isEmriId = id, istek.TeknisyenId, planli = istek.PlanZamani },
                iptal: iptal);

            await islem.CommitAsync(iptal);

            var sira = await baglanti.TekDegerAsync<int>(
                "select sira from public.servis_ziyaret where id = @p0",
                null, [ziyaretId], iptal);

            return Results.Ok(new
            {
                id = ziyaretId, sira, isEmriId = id,
                mesaj = istek.PlanZamani is null
                    ? $"{sira}. ziyaret başladı."
                    : $"{sira}. ziyaret planlandı.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ---------------------------------------------- ziyareti kapat ----
        // İMZASIZ ZİYARET KAPANMAZ: yerinde yapılan işin tek kanıtı müşterinin
        //   onayıdır. Alınamıyorsa GEREKÇE yazılır - kural esner ama iz kalır.
        grup.MapPost("/ziyaret/{id:long}/kapat", async (
            long id, ZiyaretKapatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Yapilan))
                throw GentegreHatasi.Dogrulama("Yapılan iş yazılmalı.",
                    new AlanHatasi("yapilan",
                        "Ne yapıldığı yazılmadan ziyaret kapanmaz."));
            if (!istek.ImzaAlindi && string.IsNullOrWhiteSpace(istek.ImzaNotu))
                throw GentegreHatasi.Dogrulama("İmza ya da gerekçe gerekli.",
                    new AlanHatasi("imzaNotu",
                        "Müşteri imzası alınamadıysa sebebi yazılmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var z = await baglanti.TekAsync("""
                select z.is_emri_id as "isEmriId", z.sonuc, e.cagri_id as "cagriId"
                  from public.servis_ziyaret z
                  join public.demirbas_is_emri e on e.id = z.is_emri_id
                 where z.id = @p0
                """, null, [id],
                o => new
                {
                    IsEmriId = o.GetInt64(0),
                    Sonuc = (short)o.Sayi("sonuc"),
                    CagriId = o.IsDBNull(2) ? (long?)null : o.GetInt64(2),
                }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Ziyaret bulunamadı.");

            if (z.Sonuc != ZiyaretSuruyor)
                throw GentegreHatasi.IsKurali("Bu ziyaret zaten kapatılmış.");

            var sonuc = istek.Sonuc ?? ZiyaretCozuldu;

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.servis_ziyaret
                   set ayrilis = now(), yapilan = @p1, sonuc = @p2,
                       sonuc_metni = @p3, yol_km = coalesce(@p4, yol_km),
                       iscilik_saat = coalesce(@p5, iscilik_saat),
                       tutar = coalesce(@p6, tutar),
                       imza_alindi = @p7, imza_notu = @p8, mesai_disi = @p9,
                       varis = coalesce(varis, now()),
                       degistiren = @p10, degistirme_tarihi = now()
                 where id = @p0
                """, islem,
                [id, istek.Yapilan, sonuc, istek.SonucMetni ?? "", istek.YolKm,
                 istek.IscilikSaat, istek.Tutar, istek.ImzaAlindi ? 1 : 0,
                 istek.ImzaNotu ?? "", istek.MesaiDisi ? 1 : 0,
                 baglam.KullaniciId], iptal);

            // ÇAĞRI ZİYARETİN SONUCUNU İZLER: çözüldüyse kapanır, parça
            //   bekliyorsa o duruma geçer. Çözülemeyen ziyaret çağrıyı AÇIK
            //   bırakır - ikinci gidiş gerekiyor demektir ve "ilk gidişte
            //   çözüm" ölçüsü tam burada düşer.
            if (z.CagriId is not null)
            {
                await baglanti.CalistirAsync("""
                    update public.servis_cagri
                       set durum = case when @p1 = 1 then @p3
                                        when @p1 = 3 then @p4
                                        else durum end,
                           kapanis = case when @p1 = 1 then now() else kapanis end,
                           degistiren = @p2, degistirme_tarihi = now()
                     where id = @p0
                    """, islem,
                    [z.CagriId, sonuc, baglam.KullaniciId, CagriCozuldu, CagriParca],
                    iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogZiyaret,
                (int)id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { sonuc, imza = istek.ImzaAlindi, istek.YolKm }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var t = await baglanti.TekDegerAsync<decimal>(
                "select toplam_tutar from public.demirbas_is_emri where id = @p0",
                null, [z.IsEmriId], iptal);

            return Results.Ok(new
            {
                durum = sonuc, toplamTutar = t,
                mesaj = sonuc == ZiyaretCozuldu
                    ? "Ziyaret kapandı, çağrı çözüldü."
                    : "Ziyaret kapandı; çağrı açık kaldı - ikinci gidiş gerekiyor.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------------ emanet ----
        grup.MapPost("/is-emri/{id:long}/emanet", async (
            long id, EmanetIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var sahip = await baglanti.TekDegerAsync<int?>("""
                select musteri_taraf_id from public.demirbas_is_emri where id = @p0
                """, null, [id], iptal);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var emanetId = await baglanti.TekDegerAsync<long>("""
                insert into public.servis_emanet
                       (emanet_no, sube_id, is_emri_id, taraf_id, demirbas_id,
                        cihaz_metni, aciklama, durum, ekleyen)
                values (public.fn_numara_kimlik_uret(918, @p1, 'servis_emanet',
                                                     'emanet_no'),
                        @p1, @p0, coalesce(@p2, @p3), @p4, @p5, @p6, 1, @p7)
                returning id
                """, islem,
                [id, baglam.SubeId ?? 0, istek.TarafId, sahip, istek.DemirbasId,
                 istek.CihazMetni ?? "", istek.Aciklama ?? "", baglam.KullaniciId],
                iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogEmanet,
                (int)emanetId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { isEmriId = id, istek.DemirbasId, istek.CihazMetni }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var no = await baglanti.TekDegerAsync<string>(
                "select emanet_no from public.servis_emanet where id = @p0",
                null, [emanetId], iptal);

            return Results.Ok(new
            {
                id = emanetId, emanetNo = no,
                mesaj = "Emanet cihaz verildi. İade edilmeden iş emri kapanmaz.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        grup.MapPost("/emanet/{id:long}/iade", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var d = await baglanti.TekDegerAsync<short?>(
                "select durum from public.servis_emanet where id = @p0",
                null, [id], iptal)
                ?? throw GentegreHatasi.Bulunamadi("Emanet kaydı bulunamadı.");
            if (d != 1) throw GentegreHatasi.IsKurali("Bu emanet zaten iade edilmiş.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            await baglanti.CalistirAsync("""
                update public.servis_emanet
                   set durum = 2, iade = now(),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogEmanet,
                (int)id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = 2 }, iptal: iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { durum = 2, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------ teslim ----
        // KAPANIŞ BİR KAPIDIR (mockup'ın statusbar kuralı): açık emanet ya da
        //   kapanmamış ziyaret varken iş emri teslim edilemez.
        grup.MapPost("/is-emri/{id:long}/teslim", async (
            long id, TeslimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("servis.teslim");

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select e.durum, e.sahiplik, e.toplam_tutar as "toplamTutar",
                       e.cagri_id as "cagriId",
                       (select count(*) from public.servis_emanet m
                         where m.is_emri_id = e.id and m.durum = 1) as "acikEmanet",
                       (select count(*) from public.servis_ziyaret z
                         where z.is_emri_id = e.id and z.sonuc = 0) as "acikZiyaret",
                       (select count(*) from public.servis_ziyaret z
                         where z.is_emri_id = e.id) as "ziyaret"
                  from public.demirbas_is_emri e where e.id = @p0
                """, null, [id],
                o => new
                {
                    Durum = (short)o.Sayi("durum"),
                    Sahiplik = (short)o.Sayi("sahiplik"),
                    Toplam = o.GetDecimal(o.GetOrdinal("toplamTutar")),
                    CagriId = o.IsDBNull(o.GetOrdinal("cagriId"))
                        ? (long?)null : o.GetInt64(o.GetOrdinal("cagriId")),
                    AcikEmanet = o.Sayi("acikEmanet"),
                    AcikZiyaret = o.Sayi("acikZiyaret"),
                    Ziyaret = o.Sayi("ziyaret"),
                }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İş emri bulunamadı.");

            if (k.Durum >= 5)
                throw GentegreHatasi.IsKurali("Bu iş emri zaten kapanmış.");
            if (k.AcikEmanet > 0)
                throw GentegreHatasi.IsKurali(
                    $"Açık emanet cihaz var ({k.AcikEmanet} adet) - iade alınmadan "
                  + "iş emri kapanmaz. Kapanan iş emriyle unutulan emanet, "
                  + "envanterde \"depoda\" yazan ama sahada duran cihaz demektir.");
            if (k.AcikZiyaret > 0)
                throw GentegreHatasi.IsKurali(
                    $"Kapatılmamış ziyaret var ({k.AcikZiyaret} adet) - "
                  + "önce ziyaretleri sonuçlandırın.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.demirbas_is_emri
                   set durum = 5, tamamlanma = now(),
                       aciklama = case when coalesce(nullif(@p2, ''), '') = ''
                                       then aciklama
                                       else trim(both ' ' from coalesce(aciklama, '')
                                            || case when coalesce(nullif(aciklama, ''), '') <> ''
                                                    then ' · ' else '' end || @p2) end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId, istek.Not ?? ""], iptal);

            if (k.CagriId is not null)
            {
                await baglanti.CalistirAsync("""
                    update public.servis_cagri
                       set durum = @p2, kapanis = coalesce(kapanis, now()),
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0 and durum < 5
                    """, islem, [k.CagriId, baglam.KullaniciId, CagriCozuldu], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogIsEmri,
                (int)id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = 5, k.Toplam, ziyaret = k.Ziyaret }, iptal: iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                durum = (short)5, toplamTutar = k.Toplam, ziyaret = k.Ziyaret,
                // Fatura AYRI adımdır: teslim ile tahsil aynı an değildir.
                mesaj = k.Sahiplik == DisIs
                    ? "Teslim edildi. Fatura ayrı adımdır - kalemler belgeye aktarılır."
                    : "Teslim edildi. İç iş: maliyet birime yazılır, fatura kesilmez.",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------ cihaz parkı ----
        // Servis geçmişiyle birlikte: "bu cihaz kaç kez bozuldu, hangisi
        //   sözleşme dışında" sorusu tek çağrıda cevaplanır.
        grup.MapGet("/cihaz-parki/{tarafId:int}", async (
            int tarafId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis.cihaz", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select id, ad, marka_model, seri_no, kurulum_tarihi, garanti_bitis,
                       garanti_durum, sozlesme_id, sozlesme_bitis, cagri_sayisi,
                       bolge, durum
                  from public.v_taraf_cihaz
                 where taraf_id = @p0
                 order by durum desc, ad
                """, null, [tarafId], o => new
                {
                    id = o.Sayi("id"),
                    ad = o.Metin("ad"),
                    markaModel = o.Metin("marka_model"),
                    seriNo = o.Metin("seri_no"),
                    garantiDurum = o.Sayi("garanti_durum"),
                    sozlesmeId = o.IsDBNull(o.GetOrdinal("sozlesme_id"))
                        ? (int?)null : o.Sayi("sozlesme_id"),
                    cagriSayisi = o.Sayi("cagri_sayisi"),
                    bolge = o.Metin("bolge"),
                    durum = o.Sayi("durum"),
                }, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });
    }
}
