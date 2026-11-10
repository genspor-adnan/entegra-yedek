using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DIŞ DOKTOR SAHA UÇLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): talebi kapat / göreve çevir,
/// ziyareti "gördüm" işaretle. Kart / liste jenerik; burada yalnız kartın yazamadığı geçişler var.
/// </summary>
public static class DisHekimUclari
{
    public sealed record TalepKapatIstegi(short Durum, string? Sonuc);
    public sealed record GoreveCevirIstegi(int? SorumluId, DateTime? Termin);
    public sealed record PlanUretIstegi(DateOnly HaftaBas, int? TemsilciId, int? GunBasi, bool? Grupla);
    public sealed record TasiIstegi(DateTime Tarih);
    public sealed record PlanlaIstegi(int HekimId, DateTime Tarih, int? TemsilciId);

    private const int LogTalep = 1782;
    private const int LogZiyaret = 1781;

    public static void DisHekimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis-hekim").WithTags("Dış Doktor").RequireAuthorization();

        // ------------------------------------------------ talep kapat / ret --
        grup.MapPost("/talep/{id:int}/kapat", async (int id, TalepKapatIstegi istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);
            if (istek.Durum is not (3 or 4))
                throw GentegreHatasi.Dogrulama("Durum 3 (Kapandı) ya da 4 (Ret) olmalı.", new AlanHatasi("durum", "Geçersiz."));

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var sayi = await b.CalistirAsync("""
                update public.dis_hekim_talep
                   set durum = @p1, sonuc = case when coalesce(@p2, '') <> '' then @p2 else sonuc end,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2)
                """, islem, [id, istek.Durum, istek.Sonuc ?? "", baglam.KullaniciId], iptal);
            if (sayi == 0) throw GentegreHatasi.IsKurali("Talep bulunamadı ya da zaten kapalı.");
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTalep, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aksiyon"] = istek.Durum == 3 ? "kapat" : "ret", ["sonuc"] = istek.Sonuc ?? "" },
                iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = istek.Durum == 3 ? "Talep kapatıldı." : "Talep reddedildi.", izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ göreve çevir --
        //   Talep kurumdaki bir kişinin işidir: gorev kaydı açılır (sorumlu, termin, hekim taraf olarak), talep
        //   kaydı göreve bağlanır. İkinci çağrı aynı görevi döndürür - iki görev açılmaz.
        grup.MapPost("/talep/{id:int}/goreve-cevir", async (int id, GoreveCevirIstegi? istek, VeriKaynagi veri,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var t = await b.TekAsync("""
                select t.id, t.hekim_id, t.talep, t.tur_ad, t.sorumlu_id, t.termin, t.gorev_id, t.hekim_ad, t.durum
                  from public.v_dis_hekim_talep t where t.id = @p0
                """, islem, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");
            if (t["gorev_id"] is long mevcut && mevcut > 0)
                return Results.Ok(new { gorevId = mevcut, mesaj = $"Talep zaten #{mevcut} numaralı göreve bağlı.", izlemeNo = baglam.IzlemeNo });
            if (Convert.ToInt32(t["durum"]) is 3 or 4)
                throw GentegreHatasi.IsKurali("Kapalı talep göreve çevrilmez.");

            var sorumlu = istek?.SorumluId ?? (t["sorumlu_id"] is int s ? s : baglam.KullaniciId);
            var termin = istek?.Termin ?? (t["termin"] is DateTime d ? d : (DateTime?)null);
            var konu = $"{t["tur_ad"]}: {t["hekim_ad"]}";
            var gorevId = await b.TekDegerAsync<long>("""
                insert into public.gorev (konu, aciklama, tur, oncelik, durum, sorumlu_id, acan_id, taraf_id, termin, sube_id, ekleyen)
                values (@p0, @p1, 1, 2, 0, @p2, @p3, @p4, @p5, @p6, @p3)
                returning id
                """, islem, [konu.Length > 200 ? konu[..200] : konu, Convert.ToString(t["talep"]) ?? "", sorumlu, baglam.KullaniciId,
                             t["hekim_id"], termin, baglam.SubeId ?? 0], iptal);
            await b.CalistirAsync("""
                update public.dis_hekim_talep
                   set gorev_id = @p1, sorumlu_id = coalesce(sorumlu_id, @p2), termin = coalesce(termin, @p3::date),
                       degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, gorevId, sorumlu, termin, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogTalep, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aksiyon"] = "goreve-cevir", ["gorevId"] = gorevId.ToString() }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { gorevId, mesaj = $"Görev #{gorevId} açıldı.", izlemeNo = baglam.IzlemeNo });
        });

        // ================================================ HAFTALIK PLAN (1290, mockup §3) ==
        //   Temsilci: oturum kullanıcısı (dis_hekim_temsilci'de temsilciyse) ya da seçilen; yönetici hepsini görür.
        grup.MapGet("/plan", async (DateOnly? hafta, int? temsilciId, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.plan", Islem.Gor);
            var bugun = DateOnly.FromDateTime(DateTime.Today);
            var bas = hafta ?? bugun.AddDays(-(((int)bugun.DayOfWeek + 6) % 7));
            await using var b = await veri.AcAsync(iptal);
            var temsilciler = await b.ListeAsync("""
                select distinct t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad
                  from public.taraf t
                 where t.personel = 1 and coalesce(t.durum, 1) = 1
                   and (exists (select 1 from public.dis_hekim_temsilci d where d.temsilci_id = t.id and coalesce(d.aktif, 1) = 1)
                        or exists (select 1 from public.dis_hekim_ziyaret z where z.temsilci_id = t.id))
                   and (@p0 is null or t.sube_id = @p0 or exists (select 1 from public.dis_hekim_temsilci d where d.temsilci_id = t.id and d.sube_id = @p0))
                 order by 2
                """, null, [baglam.SubeId], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            // ROL KAPSAMI: saha temsilcisi yalnız kendisini görür (RolKapsami); sorumlu / yönetici seçer.
            var dar = RolKapsami.Dar(KaynakKatalogu.Bul("dis-hekim-ziyaret")?.RolKosullari, baglam.RolKodlari);
            if (dar) temsilciler = temsilciler.Where(x => x.id == baglam.KullaniciId).ToList();
            var secili = dar ? baglam.KullaniciId
                : temsilciId ?? (temsilciler.Any(x => x.id == baglam.KullaniciId) ? baglam.KullaniciId : (temsilciler.FirstOrDefault()?.id ?? 0));
            var ziyaretler = await b.ListeAsync("""
                select z.id, z.tarih, z.hekim_id, z.hekim_ad, z.hekim_ilce, z.hekim_kurum, z.durum, z.oneri, z.sonuc_ad,
                       z.acik_talep, z.notu, z.amac_ad, z.tur_ad
                  from public.v_dis_hekim_ziyaret z
                 where z.temsilci_id = @p0 and z.tarih >= @p1::date and z.tarih < (@p1::date + 7) and z.durum in (0, 1)
                 order by z.tarih
                """, null, [secili, bas], OkuyucuGenisletmeleri.Sozluk, iptal);
            var vade = await b.TekAsync("""
                select count(*) filter (where gecikme_gun > 0)::int as geciken,
                       count(*) filter (where siklik_hafta > 0 and vade_tarihi <= @p1::date + 6 and planli_ziyaret_id is null)::int as planlanacak,
                       count(*) filter (where gonderim_dusen = 1)::int as dusen,
                       count(*) filter (where acik_talep > 0)::int as talepli
                  from public.v_dis_hekim_ziyaret_vade where temsilci_id = @p0
                """, null, [secili, bas], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { haftaBas = bas, temsilciId = secili, temsilciler, ziyaretler, vade, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/plan/uret", async (PlanUretIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Ekle);
            var temsilci = RolKapsami.Dar(KaynakKatalogu.Bul("dis-hekim-ziyaret")?.RolKosullari, baglam.RolKodlari)
                ? baglam.KullaniciId : istek.TemsilciId ?? baglam.KullaniciId;
            if (baglam.SubeId is null) throw GentegreHatasi.IsKurali("Plan üretmek için şube seçili olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var sayi = await b.TekDegerAsync<int>(
                "select public.fn_dis_hekim_plan_uret(@p0, @p1, @p2, @p3, @p4, @p5)", null,
                [temsilci, baglam.SubeId.Value, istek.HaftaBas, istek.GunBasi ?? 6, istek.Grupla ?? true, baglam.KullaniciId], iptal);
            return Results.Ok(new { sayi, mesaj = sayi == 0 ? "Bu hafta vadesi dolan, planı olmayan hekim yok." : $"{sayi} öneri ziyaret açıldı; onaylayın ya da taşıyın.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/ziyaret/{id:int}/tasi", async (int id, TasiIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var sayi = await b.CalistirAsync(
                "update public.dis_hekim_ziyaret set tarih = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0 and durum = 0",
                islem, [id, istek.Tarih, baglam.KullaniciId], iptal);
            if (sayi == 0) throw GentegreHatasi.IsKurali("Yalnız planlı (yapılmamış) ziyaret taşınır.");
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogZiyaret, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["aksiyon"] = "tasi", ["tarih"] = istek.Tarih.ToString("yyyy-MM-dd HH:mm") }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = "Ziyaret taşındı.", izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/ziyaret/{id:int}/onayla", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var sayi = await b.CalistirAsync(
                "update public.dis_hekim_ziyaret set oneri = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and oneri = 1",
                null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { mesaj = sayi > 0 ? "Öneri plana alındı." : "Zaten planda.", izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/ziyaret/{id:int}/iptal", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            // ÖNERİ SİLİNİR (hiç olmamış gibi), kullanıcının planı İPTAL olur (iz kalır).
            var silinen = await b.CalistirAsync("delete from public.dis_hekim_ziyaret where id = @p0 and durum = 0 and oneri = 1", islem, [id], iptal);
            var iptalEdilen = silinen > 0 ? 0 : await b.CalistirAsync(
                "update public.dis_hekim_ziyaret set durum = 2, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and durum = 0",
                islem, [id, baglam.KullaniciId], iptal);
            if (silinen + iptalEdilen == 0) throw GentegreHatasi.IsKurali("Yalnız planlı ziyaret iptal edilir.");
            if (iptalEdilen > 0)
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogZiyaret, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["aksiyon"] = "iptal" }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = silinen > 0 ? "Öneri kaldırıldı." : "Planlı ziyaret iptal edildi.", izlemeNo = baglam.IzlemeNo });
        });

        // Vade listesinden tek hekime planlı ziyaret.
        grup.MapPost("/planla", async (PlanlaIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Ekle);
            if (baglam.SubeId is null) throw GentegreHatasi.IsKurali("Şube seçili olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, oneri, hatirlat, notu, ekleyen)
                values (@p0, @p1, @p2, @p3, 1, 1, 0, 0, 0, 0, '', @p4) returning id
                """, null, [istek.HekimId, istek.TemsilciId, baglam.SubeId.Value, istek.Tarih, baglam.KullaniciId], iptal);
            return Results.Ok(new { id, mesaj = "Ziyaret planlandı.", izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ ziyaret gördüm (yönetici) --
        grup.MapPost("/ziyaret/{id:int}/goruldu", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var sayi = await b.CalistirAsync("""
                update public.dis_hekim_ziyaret set goruldu_id = @p1, goruldu_zamani = now()
                 where id = @p0 and goruldu_id is null
                """, islem, [id, baglam.KullaniciId], iptal);
            if (sayi > 0)
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogZiyaret, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string> { ["aksiyon"] = "goruldu" }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = sayi > 0 ? "Görüldü olarak işaretlendi." : "Zaten görülmüş.", izlemeNo = baglam.IzlemeNo });
        });
    }
}
