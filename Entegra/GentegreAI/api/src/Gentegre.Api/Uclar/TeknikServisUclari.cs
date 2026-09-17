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

        // ----------------------------------------- ziyaret (mobil) ----
        // TEKNİSYENİN TELEFONUNDAKİ EKRAN tek çağrıda dolar: sahada bağlantı
        //   zayıf, iki istek atmak ekranı yarım bırakırdı. Adres ve telefon da
        //   burada - teknisyen "nereye gideceğim, kimi arayacağım" için başka
        //   ekrana bakmasın.
        grup.MapGet("/ziyaret/{id:long}", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Gor);

            var z = await ZiyaretOkuAsync(veri, id, iptal);
            if (z is null) throw GentegreHatasi.Bulunamadi("Ziyaret bulunamadı.");
            return Results.Ok(new { ziyaret = z, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------ periyodik üretim ----
        // ELLE TETİKLEME: iş günde bir kendiliğinden çalışır; bu uç yeni
        //   sözleşme bağlandığında beklemeden ilk bakımı açmak ve denemek
        //   için. Aynı fonksiyonu çağırır - ikinci bir üretim yolu yazmak,
        //   iki yolun farklı satır üretmesi demekti.
        grup.MapPost("/periyodik-uret", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            var s = await baglanti.TekAsync("""
                select uretilen, atlanan from public.fn_servis_periyodik_uret(30)
                """, null, [],
                o => new { uretilen = o.Sayi("uretilen"), atlanan = o.Sayi("atlanan") },
                iptal);

            return Results.Ok(new
            {
                s?.uretilen, s?.atlanan,
                mesaj = (s?.uretilen ?? 0) == 0
                    ? "Sırası gelen periyodik bakım yok."
                    : $"{s!.uretilen} periyodik bakım iş emri açıldı "
                      + "(kapsam: sözleşme - ücretlendirilmez, maliyeti ölçülür).",
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ---------------------------------------------------- çizelge ----
        // GÜNLÜK TEKNİSYEN ÇİZELGESİ (775): kim, hangi saatte, nerede.
        //
        //   Satırlar ziyareti OLMAYAN teknisyeni de içerir - çizelgenin asıl
        //   sorusu "kimde boş kapasite var". Yalnız dolu satırları göstermek,
        //   iş atanacak kişiyi ekrandan silerdi.
        grup.MapGet("/cizelge", async (
            DateOnly? tarih, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("servis", Islem.Gor);

            var gun = tarih ?? DateOnly.FromDateTime(DateTime.Today);

            await using var baglanti = await veri.AcAsync(iptal);

            var teknisyenler = await baglanti.ListeAsync("""
                select taraf_id, ad, gorev, rol_adi
                  from public.v_servis_teknisyen
                 order by ad
                """, null, [], o => new
                {
                    id = o.Sayi("taraf_id"),
                    ad = o.Metin("ad"),
                    gorev = o.Metin("gorev"),
                    rolAdi = o.Metin("rol_adi"),
                }, iptal);

            var ziyaretler = await baglanti.ListeAsync("""
                select id, is_emri_id, is_emri_no, cagri_no, cagri_id,
                       teknisyen_id, teknisyen_adi, taraf_adi, cihaz, bolge,
                       bas, bit, sonuc, yol_km, arac, mesai_disi, oncelik,
                       sahiplik, sla_asildi, yapilan
                  from public.v_servis_cizelge
                 where bas >= @p0::date and bas < (@p0::date + 1)
                 order by teknisyen_id nulls last, bas
                """, null, [gun], o => new
                {
                    id = o.GetInt64(0),
                    isEmriId = o.GetInt64(1),
                    isEmriNo = o.Metin("is_emri_no"),
                    cagriNo = o.Metin("cagri_no"),
                    teknisyenId = o.IsDBNull(o.GetOrdinal("teknisyen_id"))
                        ? (int?)null : o.Sayi("teknisyen_id"),
                    teknisyenAdi = o.Metin("teknisyen_adi"),
                    tarafAdi = o.Metin("taraf_adi"),
                    cihaz = o.Metin("cihaz"),
                    bolge = o.Metin("bolge"),
                    bas = o.GetFieldValue<DateTimeOffset>(o.GetOrdinal("bas")),
                    bit = o.GetFieldValue<DateTimeOffset>(o.GetOrdinal("bit")),
                    sonuc = o.Sayi("sonuc"),
                    yolKm = o.GetDecimal(o.GetOrdinal("yol_km")),
                    arac = o.Metin("arac"),
                    mesaiDisi = o.Sayi("mesai_disi"),
                    oncelik = o.Sayi("oncelik"),
                    sahiplik = o.Sayi("sahiplik"),
                    slaAsildi = o.Sayi("sla_asildi"),
                    yapilan = o.Metin("yapilan"),
                }, iptal);

            // ATANMAMIŞ ÇAĞRI ÇİZELGENİN YANINDA DURUR: kimsenin işi değil ama
            //   SLA saati işliyor. Çizelgeye bakan kişi boş kapasiteyi görüp
            //   buradan atar - iki ekran arasında gidip gelmesin.
            var atanmamis = await baglanti.ListeAsync("""
                select c.id, c.cagri_no, c.taraf_adi, c.cihaz, c.sla_kalan_dk,
                       c.oncelik, c.bolge
                  from public.v_servis_cagri c
                 where c.durum = 0
                 order by c.sla_kalan_dk nulls last, c.acilis
                 limit 20
                """, null, [], o => new
                {
                    id = o.GetInt64(0),
                    cagriNo = o.Metin("cagri_no"),
                    tarafAdi = o.Metin("taraf_adi"),
                    cihaz = o.Metin("cihaz"),
                    slaKalanDk = o.IsDBNull(o.GetOrdinal("sla_kalan_dk"))
                        ? (int?)null : o.Sayi("sla_kalan_dk"),
                    oncelik = o.Sayi("oncelik"),
                    bolge = o.Metin("bolge"),
                }, iptal);

            return Results.Ok(new
            {
                tarih = gun,
                teknisyenler,
                ziyaretler,
                atanmamis,
                ozet = new
                {
                    ziyaret = ziyaretler.Count,
                    suren = ziyaretler.Count(z => z.sonuc == 0),
                    cozuldu = ziyaretler.Count(z => z.sonuc == 1),
                    cozulemedi = ziyaretler.Count(z => z.sonuc == 2),
                    // YOL TOPLAMI: günün gerçek maliyeti - çizelgede boş
                    //   görünen saatlerin nereye gittiğini bu sayı söyler.
                    yolKm = ziyaretler.Sum(z => z.yolKm),
                    atanmamis = atanmamis.Count,
                    teknisyen = teknisyenler.Count,
                },
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

    /// <summary>
    /// Mobil ziyaret ekranının tek sorgusu: ziyaret + iş emri + çağrı + müşteri
    /// iletişimi + o ziyarette kullanılan parçalar.
    /// </summary>
    private static async Task<object?> ZiyaretOkuAsync(
        VeriKaynagi veri, long id, CancellationToken iptal)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        var z = await baglanti.TekAsync("""
            select z.id, z.is_emri_id, z.sira, z.varis, z.ayrilis, z.plan_zamani,
                   z.yol_km, z.arac, z.mesai_disi, z.yapilan, z.sonuc,
                   z.sonuc_metni, z.imza_alindi, z.imza_notu, z.iscilik_saat,
                   z.tutar,
                   e.is_emri_no, e.sahiplik, e.kapsam_tur, e.ariza_metni,
                   e.toplam_tutar,
                   coalesce(g.cagri_no, '')   as cagri_no,
                   coalesce(g.sikayet, '')    as sikayet,
                   coalesce(g.telefon, '')    as telefon,
                   coalesce(g.bildiren, '')   as bildiren,
                   coalesce(mt.unvan, d.ad, '') as taraf_adi,
                   coalesce(nullif(tc.ad, ''), nullif(g.cihaz_metni, ''), d.ad, '')
                                              as cihaz,
                   -- ADRES ÖNCE CİHAZIN: aynı müşterinin iki şubesi olabilir
                   --   ve cihaz hangisindeyse teknisyen oraya gider. Yoksa
                   --   carinin adres kaydına düşülür (`taraf_adres`; `taraf`
                   --   tablosunda adres kolonu YOK).
                   coalesce(nullif(tc.adres, ''), nullif(ta.adres, ''), '')
                                              as adres,
                   coalesce(tc.seri_no, '')   as seri_no
              from public.servis_ziyaret z
              join public.demirbas_is_emri e on e.id = z.is_emri_id
              left join public.servis_cagri g on g.id = e.cagri_id
              left join public.taraf mt on mt.id = e.musteri_taraf_id
              left join public.taraf_cihaz tc on tc.id = e.taraf_cihaz_id
              left join lateral (select a.adres from public.taraf_adres a
                                  where a.taraf_id = e.musteri_taraf_id
                                  order by a.tur, a.id limit 1) ta on true
              left join public.demirbas d on d.id = e.demirbas_id
             where z.id = @p0
            """, null, [id], o => new
            {
                id = o.GetInt64(0),
                isEmriId = o.GetInt64(1),
                sira = o.Sayi("sira"),
                varis = o.IsDBNull(o.GetOrdinal("varis")) ? (DateTimeOffset?)null
                    : o.GetFieldValue<DateTimeOffset>(o.GetOrdinal("varis")),
                ayrilis = o.IsDBNull(o.GetOrdinal("ayrilis")) ? (DateTimeOffset?)null
                    : o.GetFieldValue<DateTimeOffset>(o.GetOrdinal("ayrilis")),
                yolKm = o.GetDecimal(o.GetOrdinal("yol_km")),
                arac = o.Metin("arac"),
                mesaiDisi = o.Sayi("mesai_disi"),
                yapilan = o.Metin("yapilan"),
                sonuc = o.Sayi("sonuc"),
                sonucMetni = o.Metin("sonuc_metni"),
                imzaAlindi = o.Sayi("imza_alindi"),
                imzaNotu = o.Metin("imza_notu"),
                iscilikSaat = o.GetDecimal(o.GetOrdinal("iscilik_saat")),
                tutar = o.GetDecimal(o.GetOrdinal("tutar")),
                isEmriNo = o.Metin("is_emri_no"),
                sahiplik = o.Sayi("sahiplik"),
                kapsamTur = o.Sayi("kapsam_tur"),
                arizaMetni = o.Metin("ariza_metni"),
                toplamTutar = o.GetDecimal(o.GetOrdinal("toplam_tutar")),
                cagriNo = o.Metin("cagri_no"),
                sikayet = o.Metin("sikayet"),
                telefon = o.Metin("telefon"),
                bildiren = o.Metin("bildiren"),
                tarafAdi = o.Metin("taraf_adi"),
                cihaz = o.Metin("cihaz"),
                adres = o.Metin("adres"),
                seriNo = o.Metin("seri_no"),
            }, iptal);
        if (z is null) return null;

        var parcalar = await baglanti.ListeAsync("""
            select p.id, p.parca_no, p.ad, p.miktar, p.birim_fiyat, p.iade_durum
              from public.demirbas_is_emri_parca p
             where p.ziyaret_id = @p0
             order by p.id
            """, null, [id], o => new
            {
                id = o.GetInt64(0),
                parcaNo = o.Metin("parca_no"),
                ad = o.Metin("ad"),
                miktar = o.GetDecimal(o.GetOrdinal("miktar")),
                birimFiyat = o.GetDecimal(o.GetOrdinal("birim_fiyat")),
                iadeDurum = o.Sayi("iade_durum"),
            }, iptal);

        return new { z.id, z.isEmriId, z.sira, z.varis, z.ayrilis, z.yolKm,
                     z.arac, z.mesaiDisi, z.yapilan, z.sonuc, z.sonucMetni,
                     z.imzaAlindi, z.imzaNotu, z.iscilikSaat, z.tutar,
                     z.isEmriNo, z.sahiplik, z.kapsamTur, z.arizaMetni,
                     z.toplamTutar, z.cagriNo, z.sikayet, z.telefon, z.bildiren,
                     z.tarafAdi, z.cihaz, z.adres, z.seriNo, parcalar };
    }
}