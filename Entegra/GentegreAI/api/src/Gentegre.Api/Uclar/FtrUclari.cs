using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FTR MODÜLÜ (719) — liste/kart dışı uçlar: program kartı (tek soruda
/// uygulamalar, egzersiz, seanslar, ölçekler), seans açma / bitirme /
/// gelmedi, seansları planlama, ünite panosu. Mockuplar Ekranlar/FTR.
/// </summary>
public static class FtrUclari
{
    private const int LogProgram = 1182;
    private const int LogSeans   = 1185;

    public sealed record SeansAcIstegi(int? KabinId, int? FizyoterapistId);
    public sealed record SeansGuncelleIstegi(int? VasOnce, int? VasSonra, string? EvUyum, string? UygulamaNotu, string? Komplikasyon,
                                             string? HastayaTalimat, int? KabinId, int? FizyoterapistId, bool? Imza);
    public sealed record SeansUygulamaIstegi(bool? Yapildi, int? SureDk, string? Neden, string? Parametre, string? CihazAd);
    public sealed record SeansYarimIstegi(string Neden);
    public sealed record PlanlaIstegi(string? Saat, int? KabinId, int? FizyoterapistId, bool? MevcutlariSil);
    public sealed record SonlandirIstegi(int? Yanit, string? Not);
    public sealed record UygulamaEkleIstegi(int? HizmetId, string? Ad, int? SureDk, string? Parametre, string? CihazAd, string? BolgeMetin, int? SeansBas, int? SeansBit);

    public static void FtrUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ftr").WithTags("FTR").RequireAuthorization();

        // ------------------------------------------------------ program kartı ----
        grup.MapGet("/program/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var program = await b.TekAsync("select row_to_json(p)::text from public.v_ftr_program p where p.id = @p0", null, [id],
                o => o.GetString(0), iptal) ?? throw GentegreHatasi.Bulunamadi("Program bulunamadı.");
            var uygulamalar = await b.ListeAsync("""
                select u.id, u.sira, u.hizmet_id, coalesce(nullif(u.ad, ''), h.ad, ''), coalesce(h.sut_kodu, ''), u.bolge_metin, u.sure_dk, u.parametre, u.cihaz_ad,
                       u.seans_bas, u.seans_bit, u.not_metin
                  from public.ftr_program_uygulama u left join public.hizmet h on h.id = u.hizmet_id
                 where u.program_id = @p0 order by u.sira, u.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), sira = (int)o.GetInt16(1), hizmetId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), ad = o.GetString(3),
                sutKodu = o.GetString(4), bolgeMetin = o.GetString(5), sureDk = (int)o.GetInt16(6), parametre = o.GetString(7), cihazAd = o.GetString(8),
                seansBas = (int)o.GetInt16(9), seansBit = o.IsDBNull(10) ? (int?)null : (int)o.GetInt16(10), notMetin = o.GetString(11),
            }, iptal);
            var egzersizler = await b.ListeAsync("""
                select e.id, e.sira, e.ad, e.set_tekrar, e.yer, e.asama_bas, e.asama_bit, e.not_metin
                  from public.ftr_program_egzersiz e where e.program_id = @p0 order by e.sira, e.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), sira = (int)o.GetInt16(1), ad = o.GetString(2), setTekrar = o.GetString(3), yer = (int)o.GetInt16(4),
                asamaBas = (int)o.GetInt16(5), asamaBit = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6), notMetin = o.GetString(7),
            }, iptal);
            var seanslar = await b.ListeAsync("""
                select s.id, s.sira, s.tarih, s.saat, s.fizyoterapist_adi, s.kabin_adi, s.vas_once, s.vas_sonra, s.durum, s.durum_adi,
                       s.uygulama_sayisi, s.yapilan_uygulama, s.sure_dk, s.kabin_id, s.fizyoterapist_id
                  from public.v_ftr_seans s where s.program_id = @p0 order by s.sira, s.tarih
                """, null, [id], o => new
            {
                id = o.GetInt32(0), sira = (int)o.GetInt16(1), tarih = o.GetFieldValue<DateOnly>(2), saat = o.GetString(3), fizyoterapist = o.GetString(4),
                kabin = o.GetString(5), vasOnce = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6), vasSonra = o.IsDBNull(7) ? (int?)null : (int)o.GetInt16(7),
                durum = (int)o.GetInt16(8), durumAdi = o.GetString(9), uygulamaSayisi = o.GetInt32(10), yapilanUygulama = o.GetInt32(11), sureDk = o.GetInt32(12),
                kabinId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13), fizyoterapistId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14),
            }, iptal);
            var olcekler = await b.ListeAsync("""
                select o.id, o.tarih, o.olcek, o.olcek_adi, o.asama, o.asama_adi, o.skor, o.hedef, o.not_metin
                  from public.v_ftr_olcek o
                 where o.program_id = @p0 or (o.degerlendirme_id = (select degerlendirme_id from public.ftr_program where id = @p0) and o.program_id is null)
                 order by o.olcek, o.tarih, o.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), tarih = o.GetFieldValue<DateOnly>(1), olcek = (int)o.GetInt16(2), olcekAdi = o.GetString(3), asama = (int)o.GetInt16(4),
                asamaAdi = o.GetString(5), skor = o.GetDecimal(6), hedef = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7), notMetin = o.GetString(8),
            }, iptal);
            var kabinler = await b.ListeAsync("select id, ad from public.v_ftr_kabin_lookup where aktif = 1 order by ad", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var gunluk = await b.ListeAsync("""
                select g.tarih, coalesce(k.ad, ''), g.islem_tipi, g.tablo_id, coalesce(g.bilgi::text, '')
                  from public.islem_log g left join public.v_kullanici_lookup k on k.id = g.kullanici_id
                 where (g.tablo_id = 1182 and g.kayit_id = @p0)
                    or (g.tablo_id = 1185 and g.kayit_id in (select s.id from public.ftr_seans s where s.program_id = @p0))
                 order by g.tarih desc, g.id desc limit 40
                """, null, [id], o => new { tarih = o.GetDateTime(0), kullanici = o.GetString(1), islemTipi = (int)o.GetInt16(2), tabloId = o.GetInt32(3), bilgi = o.GetString(4) }, iptal);
            return Results.Text($$"""{"program":{{program}},"uygulamalar":{{System.Text.Json.JsonSerializer.Serialize(uygulamalar)}},"egzersizler":{{System.Text.Json.JsonSerializer.Serialize(egzersizler)}},"seanslar":{{System.Text.Json.JsonSerializer.Serialize(seanslar)}},"olcekler":{{System.Text.Json.JsonSerializer.Serialize(olcekler)}},"kabinler":{{System.Text.Json.JsonSerializer.Serialize(kabinler)}},"gunluk":{{System.Text.Json.JsonSerializer.Serialize(gunluk)}}}""", "application/json");
        });

        // Uygulama ekle (SUT hizmetinden ya da serbest) - program kartından.
        grup.MapPost("/program/{id:int}/uygulama", async (int id, UygulamaEkleIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await ProgramOkuAsync(b, id, iptal);
            if (p.durum >= 4) throw GentegreHatasi.IsKurali("Kapanmış programa uygulama eklenmez.");
            if (g.HizmetId is null && string.IsNullOrWhiteSpace(g.Ad)) throw GentegreHatasi.Dogrulama("Uygulama seçin ya da ad yazın.");
            var yeniId = await b.TekDegerAsync<int>("""
                insert into public.ftr_program_uygulama (program_id, sira, hizmet_id, ad, bolge_metin, sure_dk, parametre, cihaz_ad, seans_bas, seans_bit, sube_id, ekleyen)
                values (@p0, (select coalesce(max(sira), 0) + 1 from public.ftr_program_uygulama where program_id = @p0), @p1,
                        coalesce(@p2, (select ad from public.hizmet where id = @p1), ''), coalesce(@p3, ''), coalesce(@p4, 15), coalesce(@p5, ''), coalesce(@p6, ''),
                        coalesce(@p7, 1), @p8, @p9, @p10) returning id
                """, null, [id, g.HizmetId, g.Ad, g.BolgeMetin, g.SureDk is int s ? (short)s : null, g.Parametre, g.CihazAd,
                            g.SeansBas is int sb ? (short)sb : null, g.SeansBit is int sbt ? (short)sbt : null, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogProgram, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { uygulamaEklendi = yeniId, g.HizmetId, g.Ad }, tarafId: p.hastaId, iptal: iptal);
            return Results.Ok(new { id = yeniId });
        });
        grup.MapDelete("/program/uygulama/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("delete from public.ftr_program_uygulama where id = @p0", null, [id], iptal);
            return Results.NoContent();
        });

        // Seansları planla: sıklığa göre hafta içi günler (5: Pzt–Cum, 3: Pzt/Çar/Cum, 2: Sal/Per, 1: Pzt).
        grup.MapPost("/program/{id:int}/planla", async (int id, PlanlaIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var p = await ProgramOkuAsync(b, id, iptal);
            if (p.durum >= 4) throw GentegreHatasi.IsKurali("Kapanmış program planlanmaz.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            if (g.MevcutlariSil == true)
                await b.CalistirAsync("delete from public.ftr_seans where program_id = @p0 and durum = 1", islem, [id], iptal);
            var varOlan = await b.ListeAsync("select sira from public.ftr_seans where program_id = @p0", islem, [id], o => (int)o.GetInt16(0), iptal);
            var gunler = p.siklik switch { >= 5 => new[] { 1, 2, 3, 4, 5 }, 4 => new[] { 1, 2, 4, 5 }, 3 => new[] { 1, 3, 5 }, 2 => new[] { 2, 4 }, _ => new[] { 1 } };
            var tarih = p.baslangic > DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun) ? p.baslangic : DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var eklenen = 0; var sira = 1; var guvenlik = 0;
            while (sira <= p.seansSayisi && guvenlik++ < 400)
            {
                var isoGun = (int)tarih.DayOfWeek == 0 ? 7 : (int)tarih.DayOfWeek;
                if (gunler.Contains(isoGun))
                {
                    if (!varOlan.Contains(sira))
                    {
                        await b.CalistirAsync("""
                            insert into public.ftr_seans (sube_id, program_id, sira, tarih, saat, fizyoterapist_id, kabin_id, durum, ekleyen)
                            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p7)
                            """, islem, [baglam.SubeId ?? 0, id, (short)sira, tarih, g.Saat ?? p.saat, g.FizyoterapistId ?? p.fizyoterapistId, g.KabinId ?? p.kabinId, baglam.KullaniciId], iptal);
                        eklenen++;
                    }
                    sira++;
                }
                tarih = tarih.AddDays(1);
            }
            await b.CalistirAsync("update public.ftr_program set durum = case when durum = 1 then 2 else durum end, fizyoterapist_id = coalesce(@p1, fizyoterapist_id), kabin_id = coalesce(@p2, kabin_id), degistiren = @p3, degistirme_tarihi = now() where id = @p0",
                islem, [id, g.FizyoterapistId, g.KabinId, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogProgram, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { seansPlanlandi = eklenen }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { eklenen });
        });

        // Programı sonlandır / kür sonu.
        grup.MapPost("/program/{id:int}/sonlandir", async (int id, SonlandirIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Degistir);
            baglam.AksiyonIste("ftr.program.sonlandir");
            await using var b = await veri.AcAsync(iptal);
            var p = await ProgramOkuAsync(b, id, iptal);
            if (p.durum >= 4) throw GentegreHatasi.IsKurali("Program zaten kapalı.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            var iptalSeans = await b.CalistirAsync("update public.ftr_seans set durum = 5 where program_id = @p0 and durum in (1, 2)", islem, [id], iptal);
            var tamam = p.yapilan >= p.seansSayisi;
            await b.CalistirAsync("""
                update public.ftr_program set durum = @p1, bitis = current_date, yanit = coalesce(@p2, yanit), sonuc_notu = coalesce(@p3, sonuc_notu),
                       degistiren = @p4, degistirme_tarihi = now() where id = @p0
                """, islem, [id, (short)(tamam ? 4 : 5), g.Yanit is int y ? (short)y : null, g.Not, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogProgram, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = tamam ? "Tamamlandı" : "Sonlandırıldı", iptalSeans, g.Yanit }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = tamam ? 4 : 5, iptalSeans });
        });

        // ---------------------------------------------------------- seans ----
        // Bugünkü seansı aç: planlı seans varsa onu başlatır, yoksa sıradaki numarayla yeni seans; uygulamalar programdan kopyalanır.
        grup.MapPost("/program/{id:int}/seans-ac", async (int id, SeansAcIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var p = await ProgramOkuAsync(b, id, iptal);
            if (p.durum >= 4) throw GentegreHatasi.IsKurali("Kapanmış programa seans açılmaz.");
            var bugun = DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            var acik = await b.TekDegerAsync<int?>("select id from public.ftr_seans where program_id = @p0 and durum = 2 limit 1", null, [id], iptal);
            if (acik is int a) return Results.Ok(new { id = a, mevcut = true });
            await using var islem = await b.BeginTransactionAsync(iptal);
            var seansId = await b.TekDegerAsync<int?>("select id from public.ftr_seans where program_id = @p0 and durum = 1 and tarih <= @p1 order by sira limit 1", islem, [id, bugun], iptal);
            if (seansId is null)
            {
                var sira = await b.TekDegerAsync<int>("select coalesce(max(sira), 0) + 1 from public.ftr_seans where program_id = @p0 and durum in (2, 3, 6)", islem, [id], iptal);
                if (sira > p.seansSayisi) throw GentegreHatasi.IsKurali($"Program {p.seansSayisi} seanslık; hepsi yapıldı.");
                seansId = await b.TekDegerAsync<int>("""
                    insert into public.ftr_seans (sube_id, program_id, sira, tarih, saat, fizyoterapist_id, kabin_id, durum, baslangic, ekleyen)
                    values (@p0, @p1, @p2, @p3, to_char(now(), 'HH24:MI'), @p4, @p5, 2, now(), @p6) returning id
                    """, islem, [baglam.SubeId ?? 0, id, (short)sira, bugun, g.FizyoterapistId ?? p.fizyoterapistId, g.KabinId ?? p.kabinId, baglam.KullaniciId], iptal);
            }
            else
                await b.CalistirAsync("""
                    update public.ftr_seans set durum = 2, baslangic = now(), tarih = @p1, fizyoterapist_id = coalesce(@p2, fizyoterapist_id), kabin_id = coalesce(@p3, kabin_id),
                           degistiren = @p4, degistirme_tarihi = now() where id = @p0
                    """, islem, [seansId, bugun, g.FizyoterapistId, g.KabinId, baglam.KullaniciId], iptal);
            // Uygulamalar programdan (seans aralığına göre) kopyalanır - yoksa.
            await b.CalistirAsync("""
                insert into public.ftr_seans_uygulama (seans_id, program_uygulama_id, ad, sure_dk, parametre, cihaz_ad, sube_id, ekleyen)
                select @p0, u.id, coalesce(nullif(u.ad, ''), h.ad, ''), u.sure_dk, u.parametre, u.cihaz_ad, @p2, @p3
                  from public.ftr_program_uygulama u left join public.hizmet h on h.id = u.hizmet_id
                  join public.ftr_seans s on s.id = @p0
                 where u.program_id = @p1 and s.sira between u.seans_bas and coalesce(u.seans_bit, 999)
                   and not exists (select 1 from public.ftr_seans_uygulama x where x.seans_id = @p0 and x.program_uygulama_id = u.id)
                 order by u.sira
                """, islem, [seansId, id, baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            await b.CalistirAsync("update public.ftr_program set durum = case when durum = 1 then 2 else durum end where id = @p0", islem, [id], iptal);
            await log.YazAsync(b, islem, LogIslemi.Ekle, LogSeans, seansId.Value, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { program = p.programNo }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = seansId.Value, mevcut = false });
        });

        grup.MapGet("/seans/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var seans = await b.TekAsync("select row_to_json(s)::text from public.v_ftr_seans s where s.id = @p0", null, [id], o => o.GetString(0), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            var program = await b.TekAsync("select row_to_json(p)::text from public.v_ftr_program p where p.id = (select program_id from public.ftr_seans where id = @p0)", null, [id], o => o.GetString(0), iptal) ?? "null";
            var uygulamalar = await b.ListeAsync("""
                select x.id, x.ad, x.sure_dk, x.parametre, x.cihaz_ad, x.yapildi, x.baslangic, x.bitis, x.neden, x.program_uygulama_id
                  from public.ftr_seans_uygulama x where x.seans_id = @p0 order by x.id
                """, null, [id], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), sureDk = (int)o.GetInt16(2), parametre = o.GetString(3), cihazAd = o.GetString(4), yapildi = o.GetInt16(5) == 1,
                baslangic = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), bitis = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7), neden = o.GetString(8),
                programUygulamaId = o.IsDBNull(9) ? (int?)null : o.GetInt32(9),
            }, iptal);
            var egzersizler = await b.ListeAsync("""
                select e.id, e.ad, e.set_tekrar, e.yer, e.asama_bas, e.asama_bit from public.ftr_program_egzersiz e
                 where e.program_id = (select program_id from public.ftr_seans where id = @p0) order by e.sira, e.id
                """, null, [id], o => new { id = o.GetInt32(0), ad = o.GetString(1), setTekrar = o.GetString(2), yer = (int)o.GetInt16(3), asamaBas = (int)o.GetInt16(4), asamaBit = o.IsDBNull(5) ? (int?)null : (int)o.GetInt16(5) }, iptal);
            var onceki = await b.TekAsync("""
                select s.sira, s.tarih, s.vas_once, s.vas_sonra, s.uygulama_notu from public.ftr_seans s
                 where s.program_id = (select program_id from public.ftr_seans where id = @p0) and s.id <> @p0 and s.durum = 3 order by s.sira desc limit 1
                """, null, [id], o => new { sira = (int)o.GetInt16(0), tarih = o.GetFieldValue<DateOnly>(1), vasOnce = o.IsDBNull(2) ? (int?)null : (int)o.GetInt16(2), vasSonra = o.IsDBNull(3) ? (int?)null : (int)o.GetInt16(3), not = o.GetString(4) }, iptal);
            var kabinler = await b.ListeAsync("select id, ad from public.v_ftr_kabin_lookup where aktif = 1 order by ad", null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Text($$"""{"seans":{{seans}},"program":{{program}},"uygulamalar":{{System.Text.Json.JsonSerializer.Serialize(uygulamalar)}},"egzersizler":{{System.Text.Json.JsonSerializer.Serialize(egzersizler)}},"onceki":{{System.Text.Json.JsonSerializer.Serialize(onceki)}},"kabinler":{{System.Text.Json.JsonSerializer.Serialize(kabinler)}},"simdi":"{{DateTime.UtcNow:O}}"}""", "application/json");
        });

        grup.MapPatch("/seans/{id:int}", async (int id, SeansGuncelleIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var durum = await b.TekDegerAsync<short?>("select durum from public.ftr_seans where id = @p0", null, [id], iptal) ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (durum is 3 or 5) throw GentegreHatasi.IsKurali("Kapanmış seans değiştirilmez.");
            await b.CalistirAsync("""
                update public.ftr_seans
                   set vas_once = coalesce(@p1, vas_once), vas_sonra = coalesce(@p2, vas_sonra), ev_uyum = coalesce(@p3, ev_uyum),
                       uygulama_notu = coalesce(@p4, uygulama_notu), komplikasyon = coalesce(@p5, komplikasyon), hastaya_talimat = coalesce(@p6, hastaya_talimat),
                       kabin_id = coalesce(@p7, kabin_id), fizyoterapist_id = coalesce(@p8, fizyoterapist_id), imza = coalesce(@p9, imza),
                       degistiren = @p10, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.VasOnce is int vo ? (short)vo : null, g.VasSonra is int vs ? (short)vs : null, g.EvUyum, g.UygulamaNotu, g.Komplikasyon, g.HastayaTalimat,
                            g.KabinId, g.FizyoterapistId, g.Imza is bool im ? (short)(im ? 1 : 0) : null, baglam.KullaniciId], iptal);
            return Results.Ok(new { id });
        });

        grup.MapPatch("/seans/uygulama/{id:int}", async (int id, SeansUygulamaIstegi g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("""
                update public.ftr_seans_uygulama
                   set yapildi = coalesce(@p1, yapildi),
                       baslangic = case when @p1 = 1 and baslangic is null then now() else baslangic end,
                       bitis = case when @p1 = 1 then now() else bitis end,
                       sure_dk = coalesce(@p2, sure_dk), neden = coalesce(@p3, neden), parametre = coalesce(@p4, parametre), cihaz_ad = coalesce(@p5, cihaz_ad),
                       degistiren = @p6, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, g.Yapildi is bool y ? (short)(y ? 1 : 0) : null, g.SureDk is int s ? (short)s : null, g.Neden, g.Parametre, g.CihazAd, baglam.KullaniciId], iptal);
            return Results.Ok(new { id });
        });

        // Seansı bitir: yapıldı, program sayaçları, ara değerlendirme / tamamlanma.
        grup.MapPost("/seans/{id:int}/bitir", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Degistir);
            baglam.AksiyonIste("ftr.seans.bitir");
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("select program_id, durum, sira from public.ftr_seans where id = @p0", null, [id],
                o => new { programId = o.GetInt32(0), durum = o.GetInt16(1), sira = (int)o.GetInt16(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (s.durum is 3 or 5) throw GentegreHatasi.IsKurali("Seans zaten kapalı.");
            var p = await ProgramOkuAsync(b, s.programId, iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("update public.ftr_seans set durum = 3, bitis = now(), baslangic = coalesce(baslangic, now() - interval '30 minute'), degistiren = @p1, degistirme_tarihi = now() where id = @p0",
                islem, [id, baglam.KullaniciId], iptal);
            var yapilan = await b.TekDegerAsync<int>("select count(*) from public.ftr_seans where program_id = @p0 and durum = 3", islem, [s.programId], iptal);
            var yeniDurum = yapilan >= p.seansSayisi ? 4 : (p.araSeans > 0 && yapilan == p.araSeans ? 3 : 2);
            await b.CalistirAsync("""
                update public.ftr_program set yapilan_seans = @p1, durum = @p2, bitis = case when @p2 = 4 then current_date else bitis end,
                       kalan_hak = greatest(0, kalan_hak - 1), degistiren = @p3, degistirme_tarihi = now() where id = @p0
                """, islem, [s.programId, (short)yapilan, (short)yeniDurum, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Yapıldı", seans = $"{yapilan}/{p.seansSayisi}" }, tarafId: p.hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { yapilan, seansSayisi = p.seansSayisi, programDurum = yeniDurum,
                uyari = yeniDurum == 3 ? "Ara değerlendirme seansına ulaşıldı - uzman değerlendirmesi bekleniyor." : yeniDurum == 4 ? "Kür tamamlandı - kür sonu ölçekleri ve raporu girin." : null });
        });

        grup.MapPost("/seans/{id:int}/gelmedi", async (int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync("select program_id, durum from public.ftr_seans where id = @p0", null, [id], o => new { programId = o.GetInt32(0), durum = o.GetInt16(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Seans bulunamadı.");
            if (s.durum != 1) throw GentegreHatasi.IsKurali("Yalnız planlı seans 'gelmedi' olur.");
            await using var islem = await b.BeginTransactionAsync(iptal);
            // Gelmeyen seans YAKILMAZ: sırası korunur, aynı sıra numarasıyla yeni planlı seans en sona eklenir (program uzar).
            await b.CalistirAsync("update public.ftr_seans set durum = 4, degistiren = @p1, degistirme_tarihi = now() where id = @p0", islem, [id, baglam.KullaniciId], iptal);
            var devamsiz = await b.TekDegerAsync<int>("update public.ftr_program set devamsiz = devamsiz + 1 where id = @p0 returning devamsiz", islem, [s.programId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Degistir, LogSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Gelmedi", devamsiz }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { devamsiz, uyari = devamsiz >= 3 ? "3+ devamsızlık: uzmana bildirildi." : null });
        });

        grup.MapPost("/seans/{id:int}/yarim", async (int id, SeansYarimIstegi g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("update public.ftr_seans set durum = 6, bitis = now(), yarim_neden = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0 and durum = 2",
                null, [id, g.Neden, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogSeans, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { durum = "Yarım", g.Neden }, iptal: iptal);
            return Results.Ok(new { id });
        });

        // -------------------------------------------------------- ünite panosu ----
        grup.MapGet("/pano", async (int? uniteId, DateOnly? gun, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.seans", Islem.Gor);
            var g = gun ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun);
            await using var b = await veri.AcAsync(iptal);
            var uniteler = await b.ListeAsync("select id, kod, ad from public.ftr_unite where aktif = 1 order by kod", null, [], o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2) }, iptal);
            var u = uniteId ?? uniteler.FirstOrDefault()?.id ?? 0;
            var kabinler = await b.ListeAsync("select id, kod, ad, tur, kapasite, cihazlar, aktif from public.ftr_kabin where unite_id = @p0 order by tur, kod", null, [u],
                o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), tur = (int)o.GetInt16(3), kapasite = (int)o.GetInt16(4), cihazlar = o.GetString(5), aktif = o.GetInt16(6) == 1 }, iptal);
            var seanslar = await b.ListeAsync("""
                select s.id, s.program_id, s.program_no, s.hasta_id, s.hasta_adi, s.bolge_adi, s.sira, s.seans_sayisi, s.saat, s.baslangic, s.bitis,
                       s.fizyoterapist_id, s.fizyoterapist_adi, s.kabin_id, s.kabin_adi, s.durum, s.durum_adi, s.uygulama_sayisi, s.yapilan_uygulama, s.vas_once,
                       (select x.ad from public.ftr_seans_uygulama x where x.seans_id = s.id and x.yapildi = 0 order by x.id limit 1) as sonraki_uygulama,
                       (select string_agg(x.ad, ' · ' order by x.id) from public.ftr_seans_uygulama x where x.seans_id = s.id and x.yapildi = 1) as yapilanlar
                  from public.v_ftr_seans s
                 where s.tarih = @p0 and s.durum <> 5
                 order by s.saat, s.id
                """, null, [g], o => new
            {
                id = o.GetInt32(0), programId = o.GetInt32(1), programNo = o.GetString(2), hastaId = o.GetInt32(3), hasta = o.GetString(4), bolge = o.GetString(5),
                sira = (int)o.GetInt16(6), seansSayisi = (int)o.GetInt16(7), saat = o.GetString(8), baslangic = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                bitis = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), fizyoterapistId = o.IsDBNull(11) ? (int?)null : o.GetInt32(11), fizyoterapist = o.GetString(12),
                kabinId = o.IsDBNull(13) ? (int?)null : o.GetInt32(13), kabin = o.GetString(14), durum = (int)o.GetInt16(15), durumAdi = o.GetString(16),
                uygulamaSayisi = o.GetInt32(17), yapilanUygulama = o.GetInt32(18), vasOnce = o.IsDBNull(19) ? (int?)null : (int)o.GetInt16(19),
                sonrakiUygulama = o.Metin("sonraki_uygulama"), yapilanlar = o.Metin("yapilanlar"),
            }, iptal);
            var fizyoterapistler = await b.ListeAsync("""
                select t.id, t.unvan, (select count(*) from public.ftr_seans s where s.fizyoterapist_id = t.id and s.tarih = @p0 and s.durum <> 5)::int,
                       (select count(*) from public.ftr_seans s where s.fizyoterapist_id = t.id and s.tarih = @p0 and s.durum = 3)::int,
                       (select count(*) from public.ftr_seans s where s.fizyoterapist_id = t.id and s.tarih = @p0 and s.durum = 2)::int
                  from public.taraf t where t.id in (select fizyoterapist_id from public.ftr_seans where tarih = @p0 and fizyoterapist_id is not null
                                                     union select fizyoterapist_id from public.ftr_program where durum in (2, 3) and fizyoterapist_id is not null)
                 order by t.unvan
                """, null, [g], o => new { id = o.GetInt32(0), ad = o.GetString(1), bugun = o.GetInt32(2), yapilan = o.GetInt32(3), suren = o.GetInt32(4) }, iptal);
            return Results.Ok(new { gun = g, uniteId = u, uniteler, kabinler, seanslar, fizyoterapistler, simdi = DateTime.UtcNow });
        });

        // FTR uygulaması (hizmet) arama.
        grup.MapGet("/uygulamalar", async (string? q, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ftr.program", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select h.id, coalesce(h.sut_kodu, ''), h.kod, h.ad, coalesce(h.standart_seans, 1)
                  from public.hizmet h
                 where h.ftr_uygulama = 1 and h.durum = 1
                   and (@p0 = '' or h.ad ilike '%' || @p0 || '%' or h.sut_kodu ilike @p0 || '%' or h.kod ilike @p0 || '%')
                 order by h.sut_kodu, h.ad limit 60
                """, null, [q ?? ""], o => new { id = o.GetInt32(0), sutKodu = o.GetString(1), kod = o.GetString(2), ad = o.GetString(3), standartSeans = Convert.ToInt32(o.GetValue(4)) }, iptal);
            return Results.Ok(new { satirlar = liste });
        });
    }

    private sealed record ProgramBilgi(int id, int hastaId, string programNo, short durum, int seansSayisi, int siklik, DateOnly baslangic, string saat, int? fizyoterapistId, int? kabinId, int yapilan, int araSeans);
    private static async Task<ProgramBilgi> ProgramOkuAsync(NpgsqlConnection b, int id, CancellationToken iptal)
        => await b.TekAsync("""
            select id, hasta_id, program_no, durum, seans_sayisi, siklik_haftalik, baslangic, saat, fizyoterapist_id, kabin_id, yapilan_seans, ara_degerlendirme_seans
              from public.ftr_program where id = @p0
            """, null, [id], o => new ProgramBilgi(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetInt16(3), o.GetInt16(4), o.GetInt16(5),
                o.GetFieldValue<DateOnly>(6), o.GetString(7), o.IsDBNull(8) ? null : o.GetInt32(8), o.IsDBNull(9) ? null : o.GetInt32(9), o.GetInt16(10), o.GetInt16(11)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Program bulunamadı.");
}
