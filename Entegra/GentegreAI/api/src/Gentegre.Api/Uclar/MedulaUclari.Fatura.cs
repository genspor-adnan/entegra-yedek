using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FATURA & DÖNEM (707) — mockup <c>medula_fatura_donem.html</c>.
///
/// <para>Takip başına fatura: yerel tutar başvuru satırlarından, Medula tutarı
/// kapıdan. Fark eşiği (<c>medula.tutar_fark_esigi</c>) aşılırsa fatura
/// "kaydedildi" kalır ama döneme ALINMAZ - fark kesinti demektir, önce
/// karşılaştırılır. Dönem sonlandırma ay başına tek adım, geri alınamaz,
/// ayrı aksiyon yetkisi (<c>medula.donem</c>); engeller (hizmet kaydı eksik,
/// hatalı, fark) kalkmadan uç reddeder.</para>
/// </summary>
public static partial class MedulaUclari
{
    public sealed record FaturaKaydetIstegi(int? FaturaTuru);
    public sealed record TopluFaturaIstegi(int? Yil, int? Ay, int? EnFazla);
    public sealed record ItirazIstegi(string Metin);
    public sealed record KesintiSonucIstegi(bool Kabul, decimal? IadeTutar);
    public sealed record KesintiIstegi(int MedulaFaturaId, string? SutKodu, string? KesintiKodu, string? Aciklama, decimal Tutar);

    private static void FaturaUclariniEkle(RouteGroupBuilder grup)
    {
        // Dönem özeti: takip sayıları, fatura durumları, engeller.
        grup.MapGet("/donem", async (
            int? yil, int? ay, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Gor);
            var bugun = Gentegre.Cekirdek.Saat.Bugun;
            var y = yil ?? bugun.Year; var a = ay ?? bugun.Month;
            var bas = new DateTime(y, a, 1); var son = bas.AddMonths(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var esik = await MedulaServisi.AyarAsync(b, "medula.tutar_fark_esigi", 0, iptal);

            var ozet = await b.TekAsync("""
                with t as (
                    select v.* from public.v_medula_takip v
                     where v.belge_tarihi >= @p0 and v.belge_tarihi < @p1 and (v.sube_id = @p2 or @p2 = 0) and v.sgk_durum = 1)
                select count(*)::int as takip,
                       count(*) filter (where medula_fatura_id is not null and fatura_durum in (2, 3, 4, 5, 6))::int as faturali,
                       count(*) filter (where medula_fatura_id is null and sgk_cikis_zaman is not null and kabul_islem > 0)::int as fatura_bekleyen,
                       count(*) filter (where kabul_islem = 0 and satir_sayisi > 0)::int as hizmet_eksik,
                       count(*) filter (where hatali_islem > 0)::int as hatali,
                       count(*) filter (where sgk_cikis_zaman is null)::int as cikissiz,
                       coalesce(sum(yerel_tutar), 0) as yerel_tutar,
                       coalesce(sum(medula_tutar) filter (where fatura_durum in (2, 3, 4, 5, 6)), 0) as medula_tutar,
                       count(*) filter (where medula_fatura_id is not null and abs(yerel_tutar - coalesce(medula_tutar, 0)) > @p3)::int as farkli
                  from t
                """, null, [bas, son, sube, (decimal)esik], o => new
            {
                takip = o.GetInt32(0), faturali = o.GetInt32(1), faturaBekleyen = o.GetInt32(2), hizmetEksik = o.GetInt32(3),
                hatali = o.GetInt32(4), cikissiz = o.GetInt32(5), yerelTutar = o.GetDecimal(6), medulaTutar = o.GetDecimal(7), farkli = o.GetInt32(8),
            }, iptal);

            var donem = await b.TekAsync("""
                select id, fatura_sayisi, toplam, kesinti, odenen, odeme_tarihi, sonlandirma, icmal_no, evrak_gonderim, durum, aciklama
                  from public.medula_donem where sube_id = @p0 and yil = @p1 and ay = @p2 and fatura_turu = 0
                """, null, [sube, (short)y, (short)a], o => new
            {
                id = o.GetInt32(0), faturaSayisi = o.GetInt32(1), toplam = o.GetDecimal(2), kesinti = o.GetDecimal(3), odenen = o.GetDecimal(4),
                odemeTarihi = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), sonlandirma = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                icmalNo = o.GetString(7), evrakGonderim = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8), durum = (int)o.GetInt16(9), aciklama = o.GetString(10),
            }, iptal);

            var donemler = await b.ListeAsync("""
                select id, yil, ay, fatura_sayisi, toplam, kesinti, odenen, odeme_tarihi, sonlandirma, icmal_no, evrak_gonderim, durum
                  from public.medula_donem where (sube_id = @p0 or @p0 = 0) and fatura_turu = 0 order by yil desc, ay desc limit 12
                """, null, [sube], o => new
            {
                id = o.GetInt32(0), yil = (int)o.GetInt16(1), ay = (int)o.GetInt16(2), faturaSayisi = o.GetInt32(3), toplam = o.GetDecimal(4),
                kesinti = o.GetDecimal(5), odenen = o.GetDecimal(6), odemeTarihi = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                sonlandirma = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8), icmalNo = o.GetString(9),
                evrakGonderim = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), durum = (int)o.GetInt16(11),
            }, iptal);

            // Takip listesi: dönemdeki SGK takipleri + fatura durumu (fatura listesi sekmesi).
            var takipler = await b.ListeAsync("""
                select v.belge_id, v.belge_no, v.belge_tarihi, v.hasta_id, v.hasta_adi, coalesce(v.hekim_adi, ''), v.sgk_takip_no,
                       v.sgk_takip_turu, v.sgk_cikis_zaman, v.kabul_islem, v.hatali_islem, v.satir_sayisi, v.yerel_tutar,
                       v.medula_fatura_id, v.medula_fatura_no, v.medula_tutar, v.fatura_durum,
                       (select f.hasta_katilim from public.medula_fatura f where f.id = v.medula_fatura_id) as katilim
                  from public.v_medula_takip v
                 where v.belge_tarihi >= @p0 and v.belge_tarihi < @p1 and (v.sube_id = @p2 or @p2 = 0) and v.sgk_durum = 1
                 order by v.belge_id desc limit 500
                """, null, [bas, son, sube], o => new
            {
                belgeId = o.GetInt32(0), belgeNo = o.GetString(1), tarih = o.GetDateTime(2), hastaId = o.GetInt32(3), hasta = o.GetString(4),
                hekim = o.GetString(5), takipNo = o.Metin("sgk_takip_no"), takipTuru = o.IsDBNull(7) ? (int?)null : (int)o.GetInt16(7),
                cikis = o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8), kabulIslem = o.GetInt32(9), hataliIslem = o.GetInt32(10),
                satirSayisi = o.GetInt32(11), yerelTutar = o.GetDecimal(12),
                faturaId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13), faturaNo = o.Metin("medula_fatura_no"),
                medulaTutar = o.IsDBNull(15) ? (decimal?)null : o.GetDecimal(15), faturaDurum = o.IsDBNull(16) ? (int?)null : (int)o.GetInt16(16),
                katilim = o.IsDBNull(17) ? (decimal?)null : o.GetDecimal(17),
            }, iptal);

            var kesintiler = await b.ListeAsync("""
                select k.id, k.medula_fatura_id, f.medula_fatura_no, t.unvan, f.takip_no, k.sut_kodu, k.kesinti_kodu, k.aciklama, k.tutar,
                       k.itiraz_durum, k.itiraz_zaman, k.sonuc_zaman, k.iade_tutar, dn.yil, dn.ay
                  from public.medula_kesinti k
                  join public.medula_fatura f on f.id = k.medula_fatura_id
                  join public.taraf t on t.id = f.hasta_id
                  left join public.medula_donem dn on dn.id = k.donem_id
                 where (k.sube_id = @p0 or @p0 = 0) order by k.id desc limit 200
                """, null, [sube], o => new
            {
                id = o.GetInt32(0), faturaId = o.GetInt32(1), faturaNo = o.GetString(2), hasta = o.GetString(3), takipNo = o.GetString(4),
                sutKodu = o.GetString(5), kesintiKodu = o.GetString(6), aciklama = o.GetString(7), tutar = o.GetDecimal(8),
                itirazDurum = (int)o.GetInt16(9), itirazZaman = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
                sonucZaman = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11), iadeTutar = o.GetDecimal(12),
                yil = o.IsDBNull(13) ? (int?)null : (int)o.GetInt16(13), ay = o.IsDBNull(14) ? (int?)null : (int)o.GetInt16(14),
            }, iptal);

            return Results.Ok(new { yil = y, ay = a, esik, ozet, donem, donemler, takipler, kesintiler,
                uyariGun = await MedulaServisi.AyarAsync(b, "medula.donem_uyari_gun", 5, iptal) });
        });

        // Takip → fatura kaydı.
        grup.MapPost("/basvuru/{belgeId:int}/fatura-kaydet", async (
            int belgeId, FaturaKaydetIstegi? istek, MedulaServisi medula, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var s = await FaturaKaydetAsync(b, medula, log, baglam, belgeId, istek?.FaturaTuru, iptal);
            return Results.Ok(s);
        });

        // Toplu fatura: çıkışı verilmiş, hizmet kaydı kabul, faturasız takipler.
        grup.MapPost("/fatura/toplu", async (
            TopluFaturaIstegi? istek, MedulaServisi medula, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Ekle);
            var bugun = Gentegre.Cekirdek.Saat.Bugun;
            var bas = new DateTime(istek?.Yil ?? bugun.Year, istek?.Ay ?? bugun.Month, 1); var son = bas.AddMonths(1);
            await using var b = await veri.AcAsync(iptal);
            var ids = await b.ListeAsync("""
                select v.belge_id from public.v_medula_takip v
                 where v.belge_tarihi >= @p0 and v.belge_tarihi < @p1 and (v.sube_id = @p2 or @p2 = 0)
                   and v.sgk_durum = 1 and v.sgk_cikis_zaman is not null and v.kabul_islem > 0 and v.medula_fatura_id is null
                 order by v.belge_id limit @p3
                """, null, [bas, son, baglam.SubeId ?? 0, istek?.EnFazla ?? 200], o => o.GetInt32(0), iptal);
            int kabul = 0, hata = 0;
            foreach (var id in ids)
            {
                var r = await FaturaKaydetAsync(b, medula, log, baglam, id, null, iptal);
                if (r.Kabul) kabul++; else hata++;
            }
            return Results.Ok(new { denenen = ids.Count, kabul, hata });
        });

        grup.MapPost("/fatura/{id:int}/iptal", async (
            int id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            var f = await b.TekAsync("select belge_id, hasta_id, medula_fatura_no, durum from public.medula_fatura where id = @p0", null, [id],
                o => new { belgeId = o.GetInt32(0), hastaId = o.GetInt32(1), no = o.GetString(2), durum = o.GetInt16(3) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            if (f.durum >= 4) throw GentegreHatasi.IsKurali("Dönemi kapanmış fatura iptal edilmez; itiraz / ek dönem.");
            if (f.durum == 1)
            {
                await b.CalistirAsync("update public.medula_fatura set durum = 7, iptal_zaman = now() where id = @p0", null, [id], iptal);
                return Results.Ok(new { Kabul = true, Kod = "", Mesaj = "Taslak fatura iptal edildi." });
            }
            var s = await medula.CagirAsync("FaturaBilgisiKayit", "faturaIptal", "medula_fatura", id, f.hastaId, f.belgeId,
                new { faturaNo = f.no }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 7, iptal);
            return Results.Ok(new { s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        // Dönem sonlandır: engeller kalkmadan reddeder; kabulde faturalar "dönem kapandı".
        grup.MapPost("/donem/{yil:int}/{ay:int}/sonlandir", async (
            int yil, int ay, MedulaServisi medula, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Degistir);
            baglam.AksiyonIste("medula.donem");
            var bas = new DateTime(yil, ay, 1); var son = bas.AddMonths(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var esik = await MedulaServisi.AyarAsync(b, "medula.tutar_fark_esigi", 0, iptal);
            var engel = await b.TekAsync("""
                with t as (select v.* from public.v_medula_takip v
                            where v.belge_tarihi >= @p0 and v.belge_tarihi < @p1 and (v.sube_id = @p2 or @p2 = 0) and v.sgk_durum = 1)
                select count(*) filter (where kabul_islem = 0 and satir_sayisi > 0)::int,
                       count(*) filter (where hatali_islem > 0)::int,
                       count(*) filter (where medula_fatura_id is not null and fatura_durum = 2 and abs(yerel_tutar - coalesce(medula_tutar, 0)) > @p3)::int,
                       count(*) filter (where medula_fatura_id is null and sgk_cikis_zaman is not null and kabul_islem > 0)::int,
                       count(*) filter (where medula_fatura_id is not null and fatura_durum = 3)::int
                  from t
                """, null, [bas, son, sube, (decimal)esik], o => new { hizmetEksik = o.GetInt32(0), hatali = o.GetInt32(1), farkli = o.GetInt32(2),
                                                                         faturasiz = o.GetInt32(3), donemde = o.GetInt32(4) }, iptal)!;
            var engeller = new List<string>();
            if (engel.hizmetEksik > 0) engeller.Add($"{engel.hizmetEksik} takipte hizmet kaydı eksik");
            if (engel.hatali > 0) engeller.Add($"{engel.hatali} takipte hatalı hizmet kaydı");
            if (engel.farkli > 0) engeller.Add($"{engel.farkli} faturada tutar farkı");
            if (engel.faturasiz > 0) engeller.Add($"{engel.faturasiz} takip faturasız");
            if (engeller.Count > 0) throw GentegreHatasi.IsKurali("Dönem sonlandırılamaz: " + string.Join(" · ", engeller) + ".", new { engeller });
            if (engel.donemde == 0) throw GentegreHatasi.IsKurali("Dönemde kaydedilmiş fatura yok.");

            var donemId = await b.TekDegerAsync<int?>("select id from public.medula_donem where sube_id = @p0 and yil = @p1 and ay = @p2 and fatura_turu = 0",
                null, [sube, (short)yil, (short)ay], iptal) ?? throw GentegreHatasi.Bulunamadi("Dönem kaydı yok.");
            var durum = await b.TekDegerAsync<short>("select durum from public.medula_donem where id = @p0", null, [donemId], iptal);
            if (durum >= 2) throw GentegreHatasi.IsKurali("Dönem zaten sonlandırılmış.");
            await b.CalistirAsync("""
                update public.medula_donem d
                   set fatura_sayisi = k.n, toplam = k.t, degistiren = @p1, degistirme_tarihi = now()
                  from (select count(*)::int n, coalesce(sum(medula_tutar), 0) t from public.medula_fatura where donem_id = @p0 and durum = 3) k
                 where d.id = @p0
                """, null, [donemId, baglam.KullaniciId], iptal);
            var s = await medula.CagirAsync("DonemIslemleri", "donemSonlandir", "medula_donem", donemId, null, null,
                new { yil, ay, subeId = sube, faturaSayisi = engel.donemde }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 8, iptal);
            await log.YazAsync(LogIslemi.Degistir, MedulaServisi.LogTabloDonem, donemId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { yil, ay, s.Kod, s.Mesaj }, iptal: iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj, yanit = s.Yanit });
        });

        // ---------------------------------------------------------------- kesinti ----
        grup.MapPost("/kesinti", async (
            KesintiIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var f = await b.TekAsync("select donem_id, hasta_id, durum from public.medula_fatura where id = @p0", null, [istek.MedulaFaturaId],
                o => new { donemId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), hastaId = o.GetInt32(1), durum = o.GetInt16(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Fatura bulunamadı.");
            var id = await b.TekDegerAsync<int>("""
                insert into public.medula_kesinti (sube_id, medula_fatura_id, donem_id, sut_kodu, kesinti_kodu, aciklama, tutar, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7) returning id
                """, null, [baglam.SubeId ?? 0, istek.MedulaFaturaId, f.donemId, istek.SutKodu ?? "", istek.KesintiKodu ?? "", istek.Aciklama ?? "", istek.Tutar, baglam.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.medula_fatura set durum = case when durum in (3, 4) then 5 else durum end where id = @p0;
                update public.medula_donem d set kesinti = (select coalesce(sum(k.tutar), 0) from public.medula_kesinti k where k.donem_id = d.id),
                       durum = case when d.durum = 2 then 3 else d.durum end where d.id = @p1;
                """, null, [istek.MedulaFaturaId, f.donemId], iptal);
            await log.YazAsync(LogIslemi.Ekle, MedulaServisi.LogTabloFatura, istek.MedulaFaturaId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kesinti = id, istek.Tutar, istek.KesintiKodu }, tarafId: f.hastaId, iptal: iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/kesinti/{id:int}/itiraz", async (
            int id, ItirazIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Degistir);
            var n = await veri.CalistirAsync("""
                update public.medula_kesinti set itiraz_durum = 1, itiraz_zaman = now(), itiraz_metni = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and itiraz_durum = 0
                """, [id, istek.Metin ?? "", baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Kesinti bulunamadı ya da zaten itiraz edilmiş.");
            return Results.Ok(new { itirazDurum = 1 });
        });

        grup.MapPost("/kesinti/{id:int}/sonuc", async (
            int id, KesintiSonucIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.fatura", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var k = await b.TekAsync("select tutar, donem_id, itiraz_durum from public.medula_kesinti where id = @p0", null, [id],
                o => new { tutar = o.GetDecimal(0), donemId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), durum = o.GetInt16(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            if (k.durum != 1) throw GentegreHatasi.IsKurali("Sonuç yalnız bekleyen itiraza yazılır.");
            var iade = istek.Kabul ? (istek.IadeTutar ?? k.tutar) : 0m;
            await b.CalistirAsync("""
                update public.medula_kesinti set itiraz_durum = @p1, sonuc_zaman = now(), iade_tutar = @p2, degistiren = @p3, degistirme_tarihi = now() where id = @p0;
                update public.medula_donem d set kesinti = (select coalesce(sum(x.tutar - x.iade_tutar), 0) from public.medula_kesinti x where x.donem_id = d.id) where d.id = @p4;
                """, null, [id, (short)(istek.Kabul ? 2 : 3), iade, baglam.KullaniciId, k.donemId], iptal);
            return Results.Ok(new { itirazDurum = istek.Kabul ? 2 : 3, iade });
        });
    }

    /// <summary>Fatura satırı aç (yoksa), döneme bağla, Medula'ya kaydet, fark eşiğine göre döneme al.</summary>
    private static async Task<MedulaServisi.Sonuc> FaturaKaydetAsync(NpgsqlConnection b, MedulaServisi medula, LogDeposu log,
        IstekBaglami baglam, int belgeId, int? faturaTuru, CancellationToken iptal)
    {
        var bv = await BasvuruOkuAsync(b, belgeId, iptal);
        if (bv.takipNo == "" || bv.sgkDurum != 1) throw GentegreHatasi.IsKurali("Takip açık değil; fatura kesilemez.");
        var mevcut = await b.TekDegerAsync<int?>("select id from public.medula_fatura where belge_id = @p0 and durum <> 7 and durum >= 2", null, [belgeId], iptal);
        if (mevcut is not null) throw GentegreHatasi.IsKurali("Bu takibin faturası zaten kaydedilmiş.");

        var tarih = await b.TekDegerAsync<DateTime>("select belge_tarihi from public.belge where id = @p0", null, [belgeId], iptal);
        var sube = baglam.SubeId ?? 0;
        var donemId = await b.TekDegerAsync<int?>("select id from public.medula_donem where sube_id = @p0 and yil = @p1 and ay = @p2 and fatura_turu = 0",
            null, [sube, (short)tarih.Year, (short)tarih.Month], iptal)
            ?? await b.TekDegerAsync<int>("insert into public.medula_donem (sube_id, yil, ay, ekleyen) values (@p0, @p1, @p2, @p3) returning id",
                null, [sube, (short)tarih.Year, (short)tarih.Month, baglam.KullaniciId], iptal);
        var donemDurum = await b.TekDegerAsync<short>("select durum from public.medula_donem where id = @p0", null, [donemId], iptal);
        if (donemDurum >= 2) throw GentegreHatasi.IsKurali("Dönem sonlandırılmış; bu takip ek döneme girer.");

        var yerel = await b.TekDegerAsync<decimal>("select coalesce(sum(tutar), 0) from public.medula_islem where belge_id = @p0 and durum = 2", null, [belgeId], iptal);
        var tur = (short)(faturaTuru ?? (await b.TekDegerAsync<short?>("select sgk_takip_turu from public.belge_provizyon where id = @p0", null, [belgeId], iptal) ?? 1));
        var faturaId = await b.TekDegerAsync<int?>("select id from public.medula_fatura where belge_id = @p0 and durum = 1", null, [belgeId], iptal)
            ?? await b.TekDegerAsync<int>("""
                insert into public.medula_fatura (sube_id, belge_id, hasta_id, takip_no, fatura_turu, donem_id, fatura_tarihi, yerel_tutar, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, current_date, @p6, @p7) returning id
                """, null, [sube, belgeId, bv.hastaId, bv.takipNo, tur, donemId, yerel, baglam.KullaniciId], iptal);
        await b.CalistirAsync("update public.medula_fatura set yerel_tutar = @p1, donem_id = @p2 where id = @p0", null, [faturaId, yerel, donemId], iptal);

        var s = await medula.CagirAsync("FaturaBilgisiKayit", "faturaKayit", "medula_fatura", faturaId, bv.hastaId, belgeId,
            new { takipNo = bv.takipNo, faturaTuru = tur, yerelTutar = yerel }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 7, iptal);
        if (s.Kabul)
        {
            // Fark eşiği: aşılmadıysa döneme (3), aşıldıysa "kaydedildi" kalır (2) - ekran farkı gösterir.
            var esik = await MedulaServisi.AyarAsync(b, "medula.tutar_fark_esigi", 0, iptal);
            await b.CalistirAsync("""
                update public.medula_fatura set durum = case when abs(yerel_tutar - medula_tutar) <= @p1 then 3 else 2 end where id = @p0;
                update public.medula_donem d set fatura_sayisi = (select count(*) from public.medula_fatura f where f.donem_id = d.id and f.durum in (2, 3)),
                       toplam = (select coalesce(sum(f.medula_tutar), 0) from public.medula_fatura f where f.donem_id = d.id and f.durum in (2, 3))
                 where d.id = @p2;
                """, null, [faturaId, (decimal)esik, donemId], iptal);
        }
        await log.YazAsync(LogIslemi.Ekle, MedulaServisi.LogTabloFatura, faturaId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new { belgeId, s.Kod, s.Mesaj }, tarafId: bv.hastaId, iptal: iptal);
        return s;
    }
}
