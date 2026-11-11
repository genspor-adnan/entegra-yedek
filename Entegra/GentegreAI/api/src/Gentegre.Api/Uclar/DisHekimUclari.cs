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
    public sealed record PlanUretIstegi(DateOnly HaftaBas, int? TemsilciId, int? GunBasi, bool? Grupla, int[]? HekimIdler = null);
    /// <summary>TOPLU PLANLA (mockup v2 çekmece): seçili hedefler bir güne sırayla; saat verilmezse gündeki son ziyaretten sonra.</summary>
    public sealed record PlanlaTopluIstegi(int[] HekimIdler, DateOnly Gun, string? BaslangicSaat, int? AralikDk, int? TemsilciId);
    public sealed record TasiIstegi(DateTime Tarih);
    public sealed record PlanlaIstegi(int HekimId, DateTime Tarih, int? TemsilciId);

    private const int LogTalep = 1782;
    private const int LogZiyaret = 1781;

    public static void DisHekimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis-hekim").WithTags("Saha Ziyareti").RequireAuthorization();

        // ------------------------------------------------ talep kapat / ret --
        grup.MapPost("/talep/{id:int}/kapat", async (int id, TalepKapatIstegi istek, VeriKaynagi veri, KartDeposu kart,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimTalepAdi, baglam, id, iptal);
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
        grup.MapPost("/talep/{id:int}/goreve-cevir", async (int id, GoreveCevirIstegi? istek, VeriKaynagi veri, KartDeposu kart,
            BaglamCozucu cozucu, LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.talep", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimTalepAdi, baglam, id, iptal);

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
        grup.MapGet("/plan", async (DateOnly? hafta, int? temsilciId, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu,
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
            var dar = baglam.DarKapsam(KaynakKatalogu.DisHekimZiyaretTanimi.RolKosullari);
            if (dar) temsilciler = temsilciler.Where(x => x.id == baglam.KullaniciId).ToList();
            var secili = dar ? baglam.KullaniciId
                : temsilciId ?? (temsilciler.Any(x => x.id == baglam.KullaniciId) ? baglam.KullaniciId : (temsilciler.FirstOrDefault()?.id ?? 0));
            // GÜNÜN İŞİ (mockup temsilci_paneli_plan.html): ziyaret satırına hedefin sıra bilgisi (sıklık, son ziyaret,
            //   30 gün gönderim / satış, düşüş) eklenir - tablo kolonları ayrı sorgusuz dolar.
            var ziyaretler = await b.ListeAsync("""
                select z.id, z.tarih, z.hekim_id, z.hekim_ad, z.hekim_ilce, z.hekim_kurum, z.durum, z.oneri, z.sonuc_ad,
                       z.acik_talep, z.notu, z.amac_ad, z.tur_ad,
                       coalesce(vd.siklik_hafta, 0)::int as siklik_hafta, vd.son_ziyaret,
                       coalesce(vd.son30_istem, 0)::int as son30_istem, coalesce(vd.gonderim_dusen, 0)::int as gonderim_dusen
                  from public.v_dis_hekim_ziyaret z
                  left join lateral (select v.* from public.v_dis_hekim_ziyaret_vade v
                                      where v.hekim_id = z.hekim_id and v.temsilci_id = z.temsilci_id
                                      order by (v.sube_id = z.sube_id) desc limit 1) vd on true
                 where z.temsilci_id = @p0 and z.tarih >= @p1::date and z.tarih < (@p1::date + 7) and z.durum in (0, 1)
                 order by z.tarih
                """, null, [secili, bas], OkuyucuGenisletmeleri.Sozluk, iptal);
            // ÖZET KUTULARI (panel §1): bugün planlı / yapılan, bu ay gönderim-satış (HBYS istem ∪ ERP satış, 1297),
            //   hedef sayısı, 60 gün sessiz, yeni, sıklığı tanımsız.
            var ozet = await b.TekAsync("""
                with h as (select hekim_id, max(sessiz_gun) as sessiz, max(yeni_hekim) as yeni, min(siklik_hafta) as siklik
                             from public.v_dis_hekim_ziyaret_vade where temsilci_id = @p0 group by hekim_id),
                     g as (select i.istek_hekim_id as hid, coalesce(i.cekim_tarihi, i.ekleme_tarihi)::date as gun
                             from public.radyoloji_istem i
                            where i.durum > 0 and i.istek_hekim_id is not null
                              and coalesce(i.cekim_tarihi, i.ekleme_tarihi) >= (date_trunc('month', current_date) - interval '1 month')
                           union all
                           select b.taraf_id, b.belge_tarihi::date from public.belge b
                            where b.tur in (15, 16) and coalesce(b.tipi, 0) <> 2 and b.durum = 0 and b.taraf_id is not null
                              and b.belge_tarihi >= (date_trunc('month', current_date) - interval '1 month')::date)
                select (select count(*) from public.dis_hekim_ziyaret z where z.temsilci_id = @p0 and z.tarih::date = current_date and z.durum in (0, 1))::int as bugun_planli,
                       (select count(*) from public.dis_hekim_ziyaret z where z.temsilci_id = @p0 and z.tarih::date = current_date and z.durum = 1)::int as bugun_yapildi,
                       (select count(*) from g join h on h.hekim_id = g.hid where g.gun >= date_trunc('month', current_date)::date)::int as ay_gonderim,
                       (select count(*) from g join h on h.hekim_id = g.hid where g.gun < date_trunc('month', current_date)::date)::int as onceki_ay_gonderim,
                       (select count(*) from h)::int as hedef_sayisi,
                       (select count(*) from h where sessiz >= 60)::int as sessiz_sayisi,
                       (select count(*) from h where yeni = 1)::int as yeni_sayisi,
                       (select count(*) from h where siklik = 0)::int as sikliksiz_sayisi
                """, null, [secili], OkuyucuGenisletmeleri.Sozluk, iptal);
            // HEDEFLER (mockup v2 çekmecesi; kullanıcı 11.11.2026 "Maltepe seçip oradaki durumu görmek istiyorum"):
            //   temsilcinin BÜTÜN hedefleri - hedef başına tek satır (vade görünümü hedef × şube), planlı ziyaret ve sıra
            //   bilgisiyle. Çekmece ilçe rozetlerini hepsinden kurar; ölçüt çipleri (geciken / bu hafta / düşen /
            //   talepli / yeni / planlı / hepsi) istemcide süzer; "Sırası gelenler" sayısı da istemcide.
            var siradakiler = await b.ListeAsync("""
                select * from (
                    select distinct on (v.hekim_id)
                           v.hekim_id, v.hekim_ad, v.hekim_kurum, v.hekim_ilce, v.siklik_hafta, v.son_ziyaret, v.vade_tarihi,
                           v.gecikme_gun, v.acik_talep, v.son30_istem, v.gonderim_dusen, v.sessiz_gun, v.yeni_hekim,
                           v.planli_ziyaret_id, v.planli_tarih,
                           coalesce(p.tercih_gun, t.tercih_gun) as tercih_gun, coalesce(p.tercih_saat, t.tercih_saat) as tercih_saat
                      from public.v_dis_hekim_ziyaret_vade v
                      join public.taraf t on t.id = v.hekim_id
                      left join public.taraf_personel p on p.id = t.id
                     where v.temsilci_id = @p0
                     order by v.hekim_id, (v.planli_ziyaret_id is not null) desc, v.gecikme_gun desc) s
                 order by s.gecikme_gun desc, s.vade_tarihi nulls last, s.hekim_ilce, s.hekim_ad
                """, null, [secili], OkuyucuGenisletmeleri.Sozluk, iptal);
            var vade = await b.TekAsync("""
                select count(*) filter (where gecikme_gun > 0)::int as geciken,
                       count(*) filter (where siklik_hafta > 0 and vade_tarihi <= @p1::date + 6 and planli_ziyaret_id is null)::int as planlanacak,
                       count(*) filter (where gonderim_dusen = 1)::int as dusen,
                       count(*) filter (where acik_talep > 0)::int as talepli
                  from public.v_dis_hekim_ziyaret_vade where temsilci_id = @p0
                """, null, [secili, bas], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { haftaBas = bas, temsilciId = secili, temsilciler, ziyaretler, vade, ozet, siradakiler, izlemeNo = baglam.IzlemeNo });
        });

        // ================================================ TOPLU PLANLA (mockup temsilci_paneli_plan_v2.html) ==
        //   Çekmeceden güne bırakma (tek hedef) ve "Seçilenleri plana ekle" / "ilçeyi güne dağıt" (çok hedef) aynı uç:
        //   saat verilmezse gündeki son planlı ziyaretten + aralık (yoksa 09:00); o gün zaten planlı olan hedef atlanır.
        grup.MapPost("/planla-toplu", async (PlanlaTopluIstegi istek, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Ekle);
            if (baglam.SubeId is null) throw GentegreHatasi.IsKurali("Şube seçili olmalı.");
            var hedefler = (istek.HekimIdler ?? []).Where(x => x > 0).Distinct().ToArray();
            if (hedefler.Length == 0) throw GentegreHatasi.Dogrulama("En az bir hedef seçin.", new AlanHatasi("hekimIdler", "Boş."));
            var dar = baglam.DarKapsam(KaynakKatalogu.DisHekimZiyaretTanimi.RolKosullari);
            if (dar) foreach (var h in hedefler) await RolKapsamKapisi.IsteAsync(kart, "dis-hekim", baglam, h, iptal);
            var temsilci = dar ? baglam.KullaniciId : istek.TemsilciId ?? baglam.KullaniciId;
            var aralik = Math.Clamp(istek.AralikDk ?? 90, 15, 480);

            await using var b = await veri.AcAsync(iptal);
            DateTime zaman;
            if (!string.IsNullOrWhiteSpace(istek.BaslangicSaat) && TimeOnly.TryParse(istek.BaslangicSaat, out var saat))
                zaman = istek.Gun.ToDateTime(saat);
            else
            {
                var son = await b.TekDegerAsync<DateTime>(
                    "select coalesce(max(z.tarih), timestamp '1900-01-01') from public.dis_hekim_ziyaret z"
                    + " where z.temsilci_id = @p0 and z.tarih::date = @p1::date and z.durum in (0, 1)", null, [temsilci, istek.Gun], iptal);
                zaman = son.Year > 1900 ? son.AddMinutes(aralik) : istek.Gun.ToDateTime(new TimeOnly(9, 0));
            }
            var idler = new List<int>(); var atlanan = 0;
            foreach (var h in hedefler)
            {
                var var_ = await b.TekDegerAsync<int>(
                    "select count(*) from public.dis_hekim_ziyaret z where z.hekim_id = @p0 and z.temsilci_id = @p1 and z.tarih::date = @p2::date and z.durum = 0",
                    null, [h, temsilci, istek.Gun], iptal);
                if (var_ > 0) { atlanan++; continue; }
                idler.Add(await b.TekDegerAsync<int>("""
                    insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, oneri, hatirlat, notu, ekleyen)
                    values (@p0, @p1, @p2, @p3, 1, 1, 0, 0, 0, 0, '', @p4) returning id
                    """, null, [h, temsilci, baglam.SubeId.Value, zaman, baglam.KullaniciId], iptal));
                zaman = zaman.AddMinutes(aralik);
            }
            return Results.Ok(new { sayi = idler.Count, atlanan, idler,
                                    mesaj = idler.Count == 0 ? "Seçilenlerin hepsi o gün zaten planlı." : $"{idler.Count} ziyaret planlandı" + (atlanan > 0 ? $", {atlanan} zaten planlıydı." : "."),
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/plan/uret", async (PlanUretIstegi istek, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Ekle);
            var temsilci = baglam.DarKapsam(KaynakKatalogu.DisHekimZiyaretTanimi.RolKosullari)
                ? baglam.KullaniciId : istek.TemsilciId ?? baglam.KullaniciId;
            if (baglam.SubeId is null) throw GentegreHatasi.IsKurali("Plan üretmek için şube seçili olmalı.");
            await using var b = await veri.AcAsync(iptal);
            // SEÇİLİ HEDEFLER (1299, "Haftaya dağıt"): verilirse yalnız onlar, sıra şartı aranmaz.
            var secilen = istek.HekimIdler is { Length: > 0 } hs ? hs.Where(x => x > 0).Distinct().ToArray() : null;
            if (secilen is not null && baglam.DarKapsam(KaynakKatalogu.DisHekimZiyaretTanimi.RolKosullari))
                foreach (var h in secilen) await RolKapsamKapisi.IsteAsync(kart, "dis-hekim", baglam, h, iptal);
            var sayi = await b.TekDegerAsync<int>(
                "select public.fn_dis_hekim_plan_uret(@p0, @p1, @p2, @p3, @p4, @p5, @p6)", null,
                [temsilci, baglam.SubeId.Value, istek.HaftaBas, istek.GunBasi ?? 6, istek.Grupla ?? true, baglam.KullaniciId, secilen], iptal);
            return Results.Ok(new { sayi, mesaj = sayi == 0 ? "Bu hafta sırası gelen, planı olmayan kayıt yok." : $"{sayi} öneri ziyaret açıldı; onaylayın ya da taşıyın.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/ziyaret/{id:int}/tasi", async (int id, TasiIstegi istek, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimZiyaretAdi, baglam, id, iptal);
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

        grup.MapPost("/ziyaret/{id:int}/onayla", async (int id, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimZiyaretAdi, baglam, id, iptal);
            await using var b = await veri.AcAsync(iptal);
            var sayi = await b.CalistirAsync(
                "update public.dis_hekim_ziyaret set oneri = 0, degistiren = @p1, degistirme_tarihi = now() where id = @p0 and oneri = 1",
                null, [id, baglam.KullaniciId], iptal);
            return Results.Ok(new { mesaj = sayi > 0 ? "Öneri plana alındı." : "Zaten planda.", izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/ziyaret/{id:int}/iptal", async (int id, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimZiyaretAdi, baglam, id, iptal);
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
        grup.MapPost("/planla", async (PlanlaIstegi istek, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Ekle);
            if (baglam.SubeId is null) throw GentegreHatasi.IsKurali("Şube seçili olmalı.");
            // ROL KAPSAMI: dar kapsamlı temsilci yalnız KENDİ hekimine, KENDİ adına planlar (/plan/uret ile aynı).
            var dar = baglam.DarKapsam(KaynakKatalogu.DisHekimZiyaretTanimi.RolKosullari);
            if (dar) await RolKapsamKapisi.IsteAsync(kart, "dis-hekim", baglam, istek.HekimId, iptal);
            var temsilci = dar ? baglam.KullaniciId : istek.TemsilciId;
            await using var b = await veri.AcAsync(iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, oneri, hatirlat, notu, ekleyen)
                values (@p0, @p1, @p2, @p3, 1, 1, 0, 0, 0, 0, '', @p4) returning id
                """, null, [istek.HekimId, temsilci, baglam.SubeId.Value, istek.Tarih, baglam.KullaniciId], iptal);
            return Results.Ok(new { id, mesaj = "Ziyaret planlandı.", izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------ ziyaret gördüm (yönetici) --
        grup.MapPost("/ziyaret/{id:int}/goruldu", async (int id, VeriKaynagi veri, KartDeposu kart, BaglamCozucu cozucu, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis_doktor.ziyaret", Islem.Degistir);
            await RolKapsamKapisi.IsteAsync(kart, KartKatalogu.DisHekimZiyaretAdi, baglam, id, iptal);
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
