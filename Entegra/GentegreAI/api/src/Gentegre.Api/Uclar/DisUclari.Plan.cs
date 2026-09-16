using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEDAVİ PLANI UÇLARI (706) — mockup <c>dis_hasta_karti_v5.html</c> plan
/// tablosu + <c>dis_muayene_tedavi_plani.html</c> proforma/onay sekmesi.
///
/// <para><b>"Yapıldı" tek tıkla iki kayıttır:</b> plan satırı tamamlanır VE
/// başvuruya ücret satırı düşer VE odontogramda planlanan işaret tamamlanana
/// döner. Üçünü ayrı ayrı yapmak, birinin unutulduğu yarım kayıtlar
/// üretirdi.</para>
///
/// <para><b>Ücret satırı başvuru ister.</b> Hastanın o gün açık başvurusu
/// (tür 19) yoksa ücret yazılmaz ve uç bunu SÖYLER - sessizce ücretsiz iş
/// bırakmak vezneye görünmeyen borç demek. Seans kartı başvuruyu randevudan
/// taşır; doğrudan hasta kartından yapıldı işaretlenirse günün açık başvurusu
/// aranır.</para>
/// </summary>
public static partial class DisUclari
{
    public sealed record PlanSatirIstegi(int? PlanId, int DisNo, string? Yuzeyler, int HizmetId,
                                         int? SeansSayisi, decimal? Iskonto, int? Faz, int? HekimId,
                                         string? DisNolar, string? Aciklama);
    public sealed record YapildiIstegi(int? SeansId, int? BelgeId);
    public sealed record OdemePlaniIstegi(decimal? Pesinat, int? TaksitSayisi, DateOnly? IlkVade, int? OdemeYontemi);

    private static void PlanUclariniEkle(RouteGroupBuilder grup)
    {
        // --------------------------------------------------- plan satırı ekle ----
        // Plan yoksa TASLAK plan açılır; hasta kartından "seçili dişe işlem
        //   ekle" bu uçtan geçer. Fiyat listeden, yüzey/diş odontograma
        //   "planlanan" olarak işlenir.
        grup.MapPost("/hasta/{hastaId:int}/plan-satir", async (
            int hastaId, PlanSatirIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Ekle);
            DisNoDogrula(istek.DisNo, sifirOlur: true);
            var yuzey = YuzeyNormalle(istek.Yuzeyler);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var plan = istek.PlanId is int pid
                ? await baglanti.TekAsync("""
                    select id, durum, fiyat_listesi_id, hekim_id from public.dis_tedavi_plani
                     where id = @p0 and hasta_id = @p1
                    """, islem, [pid, hastaId],
                    o => new { id = o.GetInt32(0), durum = o.GetInt16(1),
                               listeId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                               hekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal)
                  ?? throw GentegreHatasi.Bulunamadi("Plan bulunamadı.")
                : await baglanti.TekAsync("""
                    select id, durum, fiyat_listesi_id, hekim_id from public.dis_tedavi_plani
                     where hasta_id = @p0 and durum in (1, 2, 3, 4) order by id desc limit 1
                    """, islem, [hastaId],
                    o => new { id = o.GetInt32(0), durum = o.GetInt16(1),
                               listeId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                               hekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal);

            if (plan is not null && plan.durum is 5 or 6 or 7)
                throw GentegreHatasi.IsKurali("Kapanmış plana satır eklenmez; yeni plan açın.");

            var listeId = await VarsayilanFiyatListesiAsync(baglanti, plan?.listeId, iptal)
                ?? throw GentegreHatasi.IsKurali("Fiyat listesi bulunamadı.");

            int planId; string planNo;
            if (plan is null)
            {
                planNo = await baglanti.TekDegerAsync<string>("select public.fn_dis_no_uret('TP')", islem, [], iptal) ?? "";
                planId = await baglanti.TekDegerAsync<int>("""
                    insert into public.dis_tedavi_plani
                           (sube_id, plan_no, hasta_id, hekim_id, fiyat_listesi_id, durum, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, 1, @p5) returning id
                    """, islem, [baglam.SubeId ?? 0, planNo, hastaId, istek.HekimId, listeId, baglam.KullaniciId], iptal);
                await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloPlan, planId,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { planNo }, tarafId: hastaId, iptal: iptal);
            }
            else
            {
                planId = plan.id;
                planNo = "";
            }

            // Hizmet: yalnız diş işlemi. Fiyat listeden, seans sayısı ve
            //   ücretlendirme kuralı hizmet kartındaki varsayılandan.
            var hizmet = await baglanti.TekAsync("""
                select h.id, h.ad, coalesce(f.fiyat, 0) as fiyat, h.standart_seans, h.lab_gerekir,
                       h.ucret_kurali, h.dis_onam_tur, h.dis_islem
                  from public.hizmet h
                  left join lateral public.fn_fiyat_listesi_fiyat(@p1, null, h.id) f on true
                 where h.id = @p0
                """, islem, [istek.HizmetId, listeId], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), fiyat = o.GetDecimal(2),
                seans = o.GetInt16(3), lab = o.GetInt16(4), kural = o.GetInt16(5),
                onam = o.GetInt16(6), disIslem = o.GetInt16(7),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hizmet bulunamadı.");
            if (hizmet.disIslem != 1)
                throw GentegreHatasi.IsKurali($"'{hizmet.ad}' diş işlemi olarak işaretli değil (hizmet kartı › Diş işlemi).");

            var iskonto = Math.Max(0, istek.Iskonto ?? 0);
            if (iskonto > hizmet.fiyat) throw GentegreHatasi.Dogrulama("İndirim fiyatı aşamaz.");
            var seansSayisi = (short)Math.Max(1, istek.SeansSayisi ?? hizmet.seans);

            var satirId = await baglanti.TekDegerAsync<int>("""
                insert into public.dis_tedavi_plani_satir
                       (plan_id, faz, sira, dis_no, dis_nolar, yuzeyler, hizmet_id, hekim_id,
                        seans_sayisi, liste_fiyat, iskonto, net, ucret_kurali, lab_gerekir, onam_tur,
                        durum, aciklama, sube_id, ekleyen)
                select @p0, @p1,
                       coalesce((select max(s.sira) from public.dis_tedavi_plani_satir s where s.plan_id = @p0), 0) + 1,
                       @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p8 - @p9, @p10, @p11, @p12, 1, @p13, @p14, @p15
                returning id
                """, islem, [planId, (short)(istek.Faz ?? 2), istek.DisNo, istek.DisNolar ?? "", yuzey,
                             hizmet.id, istek.HekimId ?? plan?.hekimId, seansSayisi, hizmet.fiyat, iskonto,
                             hizmet.kural, hizmet.lab, hizmet.onam, istek.Aciklama ?? "",
                             baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

            // Odontogram: planlanan işaret (katman 2). Ağız geneli (0) işaretlenmez.
            if (istek.DisNo > 0)
                await KatmanYazAsync(baglanti, islem, baglam, hastaId, istek.DisNo, yuzey, 2, 0, satirId, null, iptal);

            await baglanti.CalistirAsync("select public.fn_dis_plan_toplam_tazele(@p0)", islem, [planId], iptal);
            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloPlanSatir, satirId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = hizmet.ad, disNo = istek.DisNo, yuzey, net = hizmet.fiyat - iskonto },
                ustTabloId: LogTabloPlan, ustKayitId: planId, tarafId: hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { planId, planNo, satirId, satirlar = await PlanSatirlariAsync(baglanti, planId, iptal) });
        });

        // ------------------------------------------------- satırı iptal et ----
        grup.MapPost("/plan-satir/{id:int}/iptal", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var s = await SatirOkuAsync(baglanti, islem, id, iptal);
            if (s.durum == 3) throw GentegreHatasi.IsKurali("Yapılmış satır iptal edilmez.");
            await baglanti.CalistirAsync("""
                update public.dis_tedavi_plani_satir set durum = 4, degistiren = @p1, degistirme_tarihi = now() where id = @p0;
                update public.dis_odontogram set aktif = 0, degistiren = @p1, degistirme_tarihi = now()
                 where plan_satir_id = @p0 and katman = 2 and aktif = 1;
                """, islem, [id, baglam.KullaniciId], iptal);
            await baglanti.CalistirAsync("select public.fn_dis_plan_toplam_tazele(@p0)", islem, [s.planId], iptal);
            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloPlanSatir, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "İptal" },
                ustTabloId: LogTabloPlan, ustKayitId: s.planId, tarafId: s.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { satirlar = await PlanSatirlariAsync(baglanti, s.planId, iptal) });
        });

        // ------------------------------------------------------- yapıldı ----
        grup.MapPost("/plan-satir/{id:int}/yapildi", async (
            int id, YapildiIstegi? istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var sonuc = await SatirYapildiAsync(baglanti, islem, log, baglam, id, istek?.SeansId, istek?.BelgeId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                sonuc.uyari, sonuc.ucret,
                satirlar = await PlanSatirlariAsync(baglanti, sonuc.planId, iptal),
            });
        });

        // ------------------------------------------------ hastaya sun / onay ----
        grup.MapPost("/plan/{id:int}/sun", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(baglanti, id, iptal);
            if (p.durum != 1) throw GentegreHatasi.IsKurali("Yalnız taslak plan sunulur.");
            if (p.satir == 0) throw GentegreHatasi.IsKurali("Boş plan sunulmaz; önce işlem ekleyin.");
            // Proforma no = plan no'nun PF hâli; geçerlilik 30 gün (kurum ayarı
            //   gelene kadar tek yerde).
            await baglanti.CalistirAsync("""
                update public.dis_tedavi_plani
                   set durum = 2, proforma_no = replace(plan_no, 'TP-', 'PF-'),
                       gecerlilik_bitis = coalesce(gecerlilik_bitis, current_date + 30),
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { durum = "Sunuldu" }, tarafId: p.hastaId, iptal: iptal);
            return Results.Ok(new { durum = 2 });
        });

        grup.MapPost("/plan/{id:int}/onayla", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.plan", Islem.Degistir);
            baglam.AksiyonIste("dis.plan.onayla");
            await using var baglanti = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(baglanti, id, iptal);
            if (p.durum is not (1 or 2)) throw GentegreHatasi.IsKurali("Plan zaten onaylı ya da kapanmış.");
            if (p.satir == 0) throw GentegreHatasi.IsKurali("Boş plan onaylanmaz.");
            await baglanti.CalistirAsync("""
                update public.dis_tedavi_plani
                   set durum = 3, hasta_onay_zamani = now(), onay_yontemi = 'ıslak',
                       proforma_no = case when proforma_no = '' then replace(plan_no, 'TP-', 'PF-') else proforma_no end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0;
                update public.dis_tedavi_plani_satir set hasta_onayli = 1 where plan_id = @p0 and durum <> 4;
                """, null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloPlan, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { durum = "Onaylı" }, tarafId: p.hastaId, iptal: iptal);
            return Results.Ok(new { durum = 3 });
        });

        // ------------------------------------------------- ödeme planı üret ----
        // Peşinat + eşit taksit; ilk vade verilmezse bugün. Var olan ödeme planı
        //   EZİLMEZ: taksit ödenmişse yeniden üretmek para izini bozar.
        grup.MapPost("/plan/{id:int}/odeme-plani", async (
            int id, OdemePlaniIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.odeme", Islem.Ekle);
            await using var baglanti = await veri.AcAsync(iptal);
            var p = await PlanOkuAsync(baglanti, id, iptal);
            var varOlan = await baglanti.TekDegerAsync<int?>(
                "select id from public.dis_odeme_plani where plan_id = @p0", null, [id], iptal);
            if (varOlan is not null) throw GentegreHatasi.IsKurali("Bu planın ödeme planı zaten var; taksitleri karttan düzenleyin.");
            var taksit = Math.Clamp(istek.TaksitSayisi ?? 1, 1, 36);
            var pesinat = Math.Max(0, istek.Pesinat ?? 0);
            if (pesinat > p.net) throw GentegreHatasi.Dogrulama("Peşinat plan netini aşamaz.");
            var kalan = p.net - pesinat;
            var taksitTutar = Math.Round(kalan / taksit, 2, MidpointRounding.ToEven);
            var ilkVade = istek.IlkVade ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);

            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var opId = await baglanti.TekDegerAsync<int>("""
                insert into public.dis_odeme_plani
                       (sube_id, plan_id, toplam, pesinat, taksit_sayisi, taksit_tutar, ilk_vade, odeme_yontemi, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8) returning id
                """, islem, [baglam.SubeId ?? 0, id, p.net, pesinat, (short)taksit, taksitTutar, ilkVade,
                             (short)(istek.OdemeYontemi ?? 1), baglam.KullaniciId], iptal);
            var sira = 0;
            if (pesinat > 0)
                await baglanti.CalistirAsync("""
                    insert into public.dis_odeme_taksit (odeme_plani_id, sira, vade, tutar, sube_id, ekleyen)
                    values (@p0, 0, @p1, @p2, @p3, @p4)
                    """, islem, [opId, ilkVade, pesinat, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            // Son taksit yuvarlama farkını taşır: toplam nete eşit çıksın.
            var dagitilan = 0m;
            for (var i = 1; i <= taksit; i++)
            {
                sira = i;
                var tutar = i == taksit ? kalan - dagitilan : taksitTutar;
                dagitilan += tutar;
                await baglanti.CalistirAsync("""
                    insert into public.dis_odeme_taksit (odeme_plani_id, sira, vade, tutar, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5)
                    """, islem, [opId, (short)i, ilkVade.AddMonths(i - 1), tutar, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            }
            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, 1138, opId, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { planNo = p.planNo, taksit, pesinat }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = opId, taksit = sira, taksitTutar, pesinat });
        });
    }

    private sealed record SatirBilgi(int id, int planId, int hastaId, short durum, int disNo, string yuzey,
                                     int hizmetId, string islemAdi, decimal net, short seansSayisi,
                                     short yapilanSeans, short kural, short? sonucKod, decimal kdv, int? planListeId);

    private static async Task<SatirBilgi> SatirOkuAsync(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        int id, CancellationToken iptal)
        => await baglanti.TekAsync("""
            select s.id, s.plan_id, p.hasta_id, s.durum, s.dis_no, s.yuzeyler, s.hizmet_id, h.ad, s.net,
                   s.seans_sayisi, s.yapilan_seans, s.ucret_kurali, h.odontogram_sonuc_kod, coalesce(h.kdv, 0),
                   p.fiyat_listesi_id
              from public.dis_tedavi_plani_satir s
              join public.dis_tedavi_plani p on p.id = s.plan_id
              join public.hizmet h on h.id = s.hizmet_id
             where s.id = @p0
            """, islem, [id], o => new SatirBilgi(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt16(3),
                o.GetInt16(4), o.GetString(5), o.GetInt32(6), o.GetString(7), o.GetDecimal(8), o.GetInt16(9),
                o.GetInt16(10), o.GetInt16(11), o.IsDBNull(12) ? null : o.GetInt16(12), o.GetDecimal(13),
                o.IsDBNull(14) ? null : o.GetInt32(14)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Plan satırı bulunamadı.");

    private sealed record PlanBilgi(int id, int hastaId, short durum, int satir, decimal net, string planNo);

    private static async Task<PlanBilgi> PlanOkuAsync(NpgsqlConnection baglanti, int id, CancellationToken iptal)
        => await baglanti.TekAsync("""
            select p.id, p.hasta_id, p.durum,
                   (select count(*) from public.dis_tedavi_plani_satir s where s.plan_id = p.id and s.durum <> 4)::int,
                   p.net, p.plan_no
              from public.dis_tedavi_plani p where p.id = @p0
            """, null, [id], o => new PlanBilgi(o.GetInt32(0), o.GetInt32(1), o.GetInt16(2), o.GetInt32(3),
                                                o.GetDecimal(4), o.GetString(5)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Plan bulunamadı.");

    /// <summary>
    /// Satırı tamamlar: durum 3, odontogram tamamlanan + sonuç kodu, başvuruya
    /// ücret satırı, plan durumu. Seans bitirme de buradan geçer.
    /// </summary>
    private static async Task<(int planId, string? uyari, decimal ucret)> SatirYapildiAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, LogDeposu log, IstekBaglami baglam,
        int satirId, int? seansId, int? belgeId, CancellationToken iptal)
    {
        var s = await SatirOkuAsync(baglanti, islem, satirId, iptal);
        if (s.durum == 3) throw GentegreHatasi.IsKurali("Satır zaten yapıldı.");
        if (s.durum == 4) throw GentegreHatasi.IsKurali("İptal satır yapıldı işaretlenmez.");

        await baglanti.CalistirAsync("""
            update public.dis_tedavi_plani_satir
               set durum = 3, yapilan_seans = seans_sayisi, tamamlanma = now(),
                   degistiren = @p1, degistirme_tarihi = now()
             where id = @p0;
            update public.dis_odontogram set aktif = 0, degistiren = @p1, degistirme_tarihi = now()
             where plan_satir_id = @p0 and katman = 2 and aktif = 1;
            """, islem, [satirId, baglam.KullaniciId], iptal);

        if (s.disNo > 0)
        {
            await KatmanYazAsync(baglanti, islem, baglam, s.hastaId, s.disNo, s.yuzey, 3, s.sonucKod ?? 0, satirId, seansId, iptal);
            // Hizmet "dişi şuna çevirir" diyorsa mevcut durum da döner (kron → 30).
            if (s.sonucKod is short kod)
                await BulguYazAsync(baglanti, islem, baglam, s.hastaId, s.disNo, s.yuzey, kod, 5, s.islemAdi,
                    null, seansId, satirId, 1, iptal);
        }

        // Ücret satırı: seansın başvurusu ya da günün açık başvurusu.
        string? uyari = null; decimal ucret = 0;
        var basvuru = belgeId ?? (seansId is int sid
            ? await baglanti.TekDegerAsync<int?>("select belge_id from public.dis_seans where id = @p0", islem, [sid], iptal)
            : null);
        basvuru ??= await baglanti.TekDegerAsync<int?>("""
            select b.id from public.belge b
             where b.tur = @p1 and b.taraf_id = @p0 and b.durum = 0
               and b.belge_tarihi >= current_date - 1
             order by b.id desc limit 1
            """, islem, [s.hastaId, BasvuruTuru], iptal);

        if (basvuru is null)
        {
            // Başvurusuz "yapıldı": ücret satırı başvuru ister → burada açılır
            //   (ödeyen hastanın kayıtlı kurumu). Sessizce ücretsiz iş
            //   bırakmak vezneye görünmeyen borç demekti.
            var acilan = await BasvuruAcAsync(baglanti, islem, log, baglam, s.hastaId, null, iptal);
            basvuru = acilan.BelgeId;
            uyari = $"Bugün açık başvuru yoktu; {acilan.BelgeNo} açıldı (ödeyen: {acilan.Odeyen})"
                  + (acilan.Sgk ? " - Medula provizyonu bekliyor." : ".");
            if (seansId is int sid0)
                await baglanti.CalistirAsync("update public.dis_seans set belge_id = @p1 where id = @p0 and belge_id is null",
                    islem, [sid0, basvuru], iptal);
        }

        if (basvuru is int bid)
        {
            // Zaten bu satırdan doğmuş ücret varsa ikinci kez yazılmaz.
            var var = await baglanti.TekDegerAsync<int?>(
                "select id from public.belge_satir where plan_satir_id = @p0 limit 1", islem, [satirId], iptal);
            if (var is null)
            {
                var brut = s.net;
                var kdvOran = s.kdv;
                var satirNo = await baglanti.TekDegerAsync<int>("""
                    insert into public.belge_satir
                           (belge_id, sira, tur, hizmet_id, aciklama, miktar, adet, birim,
                            birim_fiyat, kdv, tutar, tutar_kdvli, birim_fiyat_kdvli,
                            doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru, teslim_tarihi,
                            plan_satir_id, seans_id, dis_no, sube_id, ekleyen)
                    values (@p0,
                            coalesce((select max(bs.sira) from public.belge_satir bs where bs.belge_id = @p0), 0) + 1,
                            2, @p1, @p2, 1, 1, 0,
                            round(@p3 / (1 + @p4 / 100.0), 6), @p4, round(@p3 / (1 + @p4 / 100.0), 2), @p3, round(@p3, 4),
                            'TL', round(@p3 / (1 + @p4 / 100.0), 6), round(@p3 / (1 + @p4 / 100.0), 2), 1, now(),
                            @p5, @p6, @p7, @p8, @p9)
                    returning id
                    """, islem, [bid, s.hizmetId, s.disNo > 0 ? $"Diş {s.disNo}{(s.yuzey != "" ? " " + s.yuzey : "")}" : "",
                                 brut, kdvOran, satirId, seansId, s.disNo > 0 ? (short?)s.disNo : null,
                                 baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
                await baglanti.CalistirAsync("""
                    update public.belge b
                       set matrah = k.matrah, kdv_tutari = k.kdv, genel_toplam = k.brut,
                           degistiren = @p1, degistirme_tarihi = now()
                      from (select coalesce(sum(tutar), 0) as matrah,
                                   coalesce(sum(tutar_kdvli), 0) - coalesce(sum(tutar), 0) as kdv,
                                   coalesce(sum(tutar_kdvli), 0) as brut
                              from public.belge_satir where belge_id = @p0) k
                     where b.id = @p0
                    """, islem, [bid, baglam.KullaniciId], iptal);
                if (seansId is int sid2)
                    await baglanti.CalistirAsync("""
                        update public.dis_seans_islem set belge_satir_id = @p1, tamamlandi = 1
                         where seans_id = @p0 and plan_satir_id = @p2 and belge_satir_id is null
                        """, islem, [sid2, satirNo, satirId], iptal);
                ucret = brut;
            }
        }

        // Plan durumu: ilk yapılan satırla "sürüyor", hepsi bitince "tamamlandı".
        await baglanti.CalistirAsync("""
            update public.dis_tedavi_plani p
               set durum = case when not exists (select 1 from public.dis_tedavi_plani_satir x
                                                  where x.plan_id = p.id and x.durum in (1, 2, 5)) then 5
                                when p.durum in (1, 2, 3) then 4 else p.durum end,
                   degistiren = @p1, degistirme_tarihi = now()
             where p.id = @p0
            """, islem, [s.planId, baglam.KullaniciId], iptal);

        await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloPlanSatir, satirId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new { durum = "Yapıldı", islem = s.islemAdi, disNo = s.disNo, ucret, basvuru },
            ustTabloId: LogTabloPlan, ustKayitId: s.planId, tarafId: s.hastaId, iptal: iptal);

        return (s.planId, uyari, ucret);
    }
}
