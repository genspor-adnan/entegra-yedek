using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// e-REÇETE / e-RAPOR (707) — mockup <c>medula_recete_rapor.html</c>.
///
/// <para>Reçete yerelde yazılır (413); "imzala" durumu 2 yapar ve imza
/// özetini (hash) yazar; "gönder" Medula'ya (kuyruk). Kabul edilen reçete
/// değiştirilemez: düzeltme = sil + yeni. Alerji engeli YERELDE ve gönderimden
/// önce: hastanın aktif alerji etkeni reçete satırındaki ilaç adı / etken
/// maddede geçiyorsa gönderim durur (Medula bunu sormaz).</para>
/// </summary>
public static partial class MedulaUclari
{
    public sealed record RaporIstegi(int HastaId, int? MuayeneId, int? BelgeId, int? HekimId, int? RaporTuru,
                                     string IcdKod, string? Tani, DateOnly? Baslangic, DateOnly? Bitis, bool? Heyet,
                                     string? Aciklama, RaporSatirIstegi[]? Satirlar);
    public sealed record RaporSatirIstegi(string EtkenMadde, string? Form, string? Doz, string? Gunluk, string? Aciklama);

    private static void ReceteUclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/recete/{id:int}/imzala", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.recete", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("select durum, hasta_id from public.recete where id = @p0", null, [id],
                o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            if (r.durum != 1) throw GentegreHatasi.IsKurali("Yalnız taslak reçete imzalanır.");
            var ilac = await b.TekDegerAsync<int>("select count(*)::int from public.recete_satir where recete_id = @p0", null, [id], iptal);
            if (ilac == 0) throw GentegreHatasi.IsKurali("Reçetede ilaç yok.");
            var engel = await AlerjiEngeliAsync(b, id, r.hastaId, iptal);
            if (engel is not null) throw GentegreHatasi.IsKurali(engel);
            // İmza özeti: satırların metni + zaman. Gerçek e-imza (akıllı kart) istemci
            //   tarafında; sunucu özeti saklar ki sonradan "ne imzalandı" okunsun.
            var metin = await b.TekDegerAsync<string>("""
                select string_agg(ilac_barkod || '|' || ilac_ad || '|' || doz || '|' || periyot, ';' order by sira, id)
                  from public.recete_satir where recete_id = @p0
                """, null, [id], iptal) ?? "";
            var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(metin + "|" + DateTime.UtcNow.Ticks)))[..32];
            await b.CalistirAsync("update public.recete set durum = 2, imza_zamani = now(), imza_hash = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                null, [id, hash, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, 413, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { imza = hash }, tarafId: r.hastaId, iptal: iptal);
            return Results.Ok(new { durum = 2, imzaHash = hash });
        });

        grup.MapPost("/recete/{id:int}/gonder", async (
            int id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.recete", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("""
                select r.durum, r.hasta_id, r.muayene_id, m.belge_id, r.recete_no, r.tur, coalesce(p.tescil_no, '')
                  from public.recete r left join public.muayene m on m.id = r.muayene_id
                  left join public.taraf_personel p on p.id = r.hekim_id where r.id = @p0
                """, null, [id], o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1),
                    muayeneId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), belgeId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                    no = o.GetString(4), tur = o.GetInt16(5), tescil = o.GetString(6) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            if (r.durum == 3) throw GentegreHatasi.IsKurali("Reçete zaten Medula'da kabul edilmiş.");
            if (r.durum != 2) throw GentegreHatasi.IsKurali("Önce reçeteyi imzalayın.");
            var engel = await AlerjiEngeliAsync(b, id, r.hastaId, iptal);
            if (engel is not null) throw GentegreHatasi.IsKurali(engel);
            var takip = r.belgeId is int bid ? await b.TekDegerAsync<string>("select coalesce(sgk_takip_no, '') from public.belge_provizyon where id = @p0", null, [bid], iptal) : "";
            var ilaclar = await b.ListeAsync("select ilac_barkod, ilac_ad, doz, periyot, kutu, sure_gun from public.recete_satir where recete_id = @p0 order by sira, id",
                null, [id], o => new { barkod = o.GetString(0), ad = o.GetString(1), doz = o.GetString(2), periyot = o.GetString(3),
                                       kutu = o.IsDBNull(4) ? 1 : Convert.ToInt32(o.GetValue(4)), sure = o.IsDBNull(5) ? 0 : Convert.ToInt32(o.GetValue(5)) }, iptal);
            var s = await medula.CagirAsync("ReceteIslemleri", "eReceteKayit", "recete", id, r.hastaId, r.belgeId,
                new { receteNo = r.no, takipNo = takip ?? "", receteTuru = r.tur, hekimTescil = r.tescil, ilaclar },
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, 4, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj, yanit = s.Yanit });
        });

        grup.MapPost("/recete/{id:int}/sil", async (
            int id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.recete", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("select durum, hasta_id, medula_recete_no from public.recete where id = @p0", null, [id],
                o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1), no = o.GetString(2) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            if (r.durum != 3) throw GentegreHatasi.IsKurali("Yalnız Medula'da kabul edilmiş reçete silinir; taslak/imzalı reçete karttan iptal edilir.");
            var s = await medula.CagirAsync("ReceteIslemleri", "eReceteSil", "recete", id, r.hastaId, null,
                new { eReceteNo = r.no }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 4, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        // ---------------------------------------------------------------- rapor ----
        grup.MapPost("/rapor", async (
            RaporIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.recete", Islem.Ekle);
            if (string.IsNullOrWhiteSpace(istek.IcdKod)) throw GentegreHatasi.Dogrulama("Rapor tanısı (ICD-10) gerekli.");
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var id = await b.TekDegerAsync<int>("""
                insert into public.medula_rapor (sube_id, hasta_id, muayene_id, belge_id, hekim_id, rapor_turu, icd_kod, tani, baslangic, bitis, heyet, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12) returning id
                """, islem, [baglam.SubeId ?? 0, istek.HastaId, istek.MuayeneId, istek.BelgeId, istek.HekimId,
                             (short)(istek.RaporTuru ?? 1), istek.IcdKod.Trim(), istek.Tani ?? "",
                             istek.Baslangic ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun),
                             istek.Bitis ?? DateOnly.FromDateTime(Gentegre.Cekirdek.Saat.Bugun.AddYears(1)),
                             (short)(istek.Heyet == true ? 1 : 0), istek.Aciklama ?? "", baglam.KullaniciId], iptal);
            foreach (var s in istek.Satirlar ?? [])
                await b.CalistirAsync("""
                    insert into public.medula_rapor_satir (rapor_id, etken_madde, form, doz, gunluk, aciklama, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7)
                    """, islem, [id, s.EtkenMadde, s.Form ?? "", s.Doz ?? "", s.Gunluk ?? "", s.Aciklama ?? "", baglam.SubeId ?? 0, baglam.KullaniciId], iptal);
            await log.YazAsync(b, islem, LogIslemi.Ekle, MedulaServisi.LogTabloRapor, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { istek.IcdKod, tur = istek.RaporTuru }, tarafId: istek.HastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/rapor/{id:int}/gonder", async (
            int id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.recete", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var r = await b.TekAsync("select hasta_id, belge_id, durum, icd_kod, rapor_turu, baslangic, bitis from public.medula_rapor where id = @p0", null, [id],
                o => new { hastaId = o.GetInt32(0), belgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), durum = o.GetInt16(2),
                           icd = o.GetString(3), tur = o.GetInt16(4), bas = o.GetDateTime(5), bit = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            if (r.durum == 3) throw GentegreHatasi.IsKurali("Rapor zaten kabul edilmiş.");
            var satirlar = await b.ListeAsync("select etken_madde, form, doz, gunluk from public.medula_rapor_satir where rapor_id = @p0", null, [id],
                o => new { etken = o.GetString(0), form = o.GetString(1), doz = o.GetString(2), gunluk = o.GetString(3) }, iptal);
            await b.CalistirAsync("update public.medula_rapor set durum = 2, degistirme_tarihi = now() where id = @p0 and durum = 1", null, [id], iptal);
            var s = await medula.CagirAsync("RaporIslemleri", "raporKayit", "medula_rapor", id, r.hastaId, r.belgeId,
                new { raporTuru = r.tur, icdKod = r.icd, baslangic = r.bas, bitis = r.bit, satirlar },
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, 4, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj, yanit = s.Yanit });
        });
    }

    /// <summary>Hastanın aktif alerji etkeni reçetedeki ilaç adında / etken maddede geçiyorsa engel metni.</summary>
    private static async Task<string?> AlerjiEngeliAsync(Npgsql.NpgsqlConnection b, int receteId, int hastaId, CancellationToken iptal)
    {
        var eslesen = await b.TekDegerAsync<string>("""
            select string_agg(distinct s.ilac_ad || ' ↔ ' || coalesce(nullif(a.etken, ''), a.etken_madde), ', ')
              from public.recete_satir s
              join public.hasta_alerji a on a.hasta_id = @p1 and a.aktif = 1
             where s.recete_id = @p0
               and (
                 (a.etken_madde <> '' and (s.ilac_ad ilike '%' || a.etken_madde || '%'))
                 or (a.etken <> '' and (s.ilac_ad ilike '%' || a.etken || '%'))
                 or (a.etken ilike '%penisilin%' and (s.ilac_ad ilike '%amoksisilin%' or s.ilac_ad ilike '%ampisilin%' or s.ilac_ad ilike '%penisilin%'))
               )
            """, null, [receteId, hastaId], iptal);
        return string.IsNullOrEmpty(eslesen) ? null : $"Alerji engeli: {eslesen}. İlacı değiştirin; gönderim durduruldu.";
    }
}
