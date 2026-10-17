using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SERİ RANDEVU (kullanıcı 17.10.2026: "özellikle FTR için çoklu randevu (5-10-15 seans) nasıl
/// verebilirim" → "önce erteleme, sonra FTR ve genel tekrarla").
///
/// Tek uç, iki kaynak: kayıtlı bir randevunun TEKRARI (kaynakRandevuId) ya da FTR PROGRAMININ
/// seansları (ftrProgramId - her randevuya bağlı bir ftr_seans açılır). Kural kaynağı veritabanı
/// tetikleridir (çakışma, mesai, izin): her tarih kendi kayıt noktasında (savepoint) denenir,
/// reddedilen satır geri alınır ve aynı gün için ilk uygun saat ÖNERİLİR. Önizlemede (kaydet=false)
/// işlem en sonda bütünüyle geri alınır - ekranda görünen sonuç kaydın göreceği sonuçtur.
/// FTR'de kabin kapasitesi de denetlenir (aynı saatte kabindeki planlı seans sayısı).
/// </summary>
public static partial class RandevuUclari
{
    private const int LogFtrProgram = 1182;
    private const int LogFtrSeans = 1185;

    /// <summary>Baslangiclar şubenin yerel saatinde. Boş alanlar kaynaktan (randevu / program) gelir.</summary>
    public sealed record SeriIstegi(List<DateTime> Baslangiclar, bool Kaydet, int? KaynakRandevuId = null,
        int? FtrProgramId = null, int? HekimId = null, int? KabinId = null, short? SureDk = null,
        SeriSablonGirdi? Sablon = null);

    /// <summary>
    /// KAYDEDİLMEMİŞ KARTIN DEĞERLERİ (kullanıcı 17.10.2026: "ilk randevu ile birlikte 5 seans tekrarlı
    /// randevu vermek istiyorum ama ilk randevuyu kaydetmeden tekrarlı çıkmadı"): yalnız ÖNİZLEME için -
    /// kayıtta önce ilk randevu yazılır, tekrarlar onun üzerinden (kaynakRandevuId) açılır.
    /// </summary>
    public sealed record SeriSablonGirdi(int HastaId, int? HekimId = null, int? CihazId = null, short? Bolum = null,
        int? HizmetId = null, short? SureDk = null, int? GonderenId = null, short? Tip = null, short? Kaynak = null,
        string? Aciklama = null);

    private sealed record SeriSablon(int SubeId, short Bolum, int? HekimId, int HastaId, short SureDk, string Aciklama,
        int? HizmetId, short Tip, short Kaynak, int? CihazId, int? GonderenId, int? KabinId);

    private static void SeriUcunuEkle(RouteGroupBuilder grup)
    {
        grup.MapPost("/seri", async (
            SeriIstegi istek, VeriKaynagi veri, LogDeposu log, KayitErisimi erisim,
            Servisler.RandevuHatirlatmasi hatirlatma, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("randevu", Islem.Ekle);
            if (istek.FtrProgramId is not null) baglam.YetkiIste("ftr.program", Islem.Degistir);
            if ((istek.KaynakRandevuId is not null ? 1 : 0) + (istek.FtrProgramId is not null ? 1 : 0)
                + (istek.Sablon is not null ? 1 : 0) != 1)
                throw GentegreHatasi.Dogrulama("Kaynak randevu, FTR programı ya da randevu değerleri verilmeli.");
            if (istek.Sablon is not null && istek.Kaydet)
                throw GentegreHatasi.Dogrulama("Kaydedilmemiş randevunun tekrarı önce randevu kaydedilerek yazılır.");
            var tarihler = (istek.Baslangiclar ?? []).Distinct().Order().ToList();
            if (tarihler.Count == 0) throw GentegreHatasi.Dogrulama("Tarih yok.");
            if (tarihler.Count > 60) throw GentegreHatasi.Dogrulama("Tek seferde en çok 60 randevu.");
            if (istek.KaynakRandevuId is int kr && !await erisim.GorunurAsync(baglam, "randevu", kr, iptal))
                throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");

            await using var b = await veri.AcAsync(iptal);
            var s = istek.Sablon is { } g
                ? new SeriSablon(baglam.SubeId ?? 0, g.Bolum ?? 0, g.HekimId, g.HastaId, g.SureDk ?? 15, (g.Aciklama ?? "").Trim(),
                                 g.HizmetId, g.Tip ?? 1, g.Kaynak ?? 1, g.CihazId, g.GonderenId, null)
                : await SablonOkuAsync(b, istek, iptal);
            var dilim = await b.TekDegerAsync<string>(
                "select coalesce((select nullif(zaman_dilimi, '') from public.sube where id = @p0), 'Europe/Istanbul')",
                null, [s.SubeId], iptal) ?? "Europe/Istanbul";
            var simdi = await b.TekDegerAsync<DateTime>($"select (now() at time zone '{dilim.Replace("'", "")}')::timestamp", null, [], iptal);

            await using var islem = await b.BeginTransactionAsync(iptal);
            var siraSon = istek.FtrProgramId is int fp0
                ? await b.TekDegerAsync<int>("select coalesce(max(sira), 0) from public.ftr_seans where program_id = @p0", islem, [fp0], iptal)
                : 0;

            // Bir saati dener: kabin, randevu (tetikler), FTR seansı. Başarısızsa kayıt noktasına döner.
            async Task<(bool tamam, string mesaj, int id)> Dene(DateTime t, bool kalici)
            {
                if (t < simdi.AddMinutes(-5)) return (false, "Geçmiş saat.", 0);
                await islem.SaveAsync("seri", iptal);
                try
                {
                    if (istek.FtrProgramId is not null && s.KabinId is int kabin)
                    {
                        var dolu = await b.TekDegerAsync<bool>("""
                            select count(*) >= coalesce((select nullif(kapasite, 0) from public.ftr_kabin where id = @p0), 1)
                              from public.ftr_seans x join public.ftr_program p on p.id = x.program_id
                             where x.kabin_id = @p0 and x.tarih = @p1::date and x.durum in (1, 2) and x.saat <> ''
                               and x.saat::time < (@p2::time + make_interval(mins => @p3))
                               and (x.saat::time + make_interval(mins => p.seans_sure_dk)) > @p2::time
                            """, islem, [kabin, t.Date, t.ToString("HH:mm"), (int)s.SureDk], iptal);
                        if (dolu) { await islem.RollbackAsync("seri", iptal); return (false, "Kabin bu saatte dolu.", 0); }
                    }
                    var id = await b.TekDegerAsync<int>($"""
                        insert into public.randevu
                               (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk, durum, aciklama, hizmet_id, tip, kaynak,
                                cihaz_id, gonderen_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4::timestamp at time zone '{dilim.Replace("'", "")}', @p5, 1, @p6, @p7, @p8, @p9,
                                @p10, @p11, @p12)
                        returning id
                        """, islem, [s.SubeId, s.Bolum, s.HekimId, s.HastaId, t, s.SureDk, s.Aciklama, s.HizmetId, s.Tip, s.Kaynak,
                                     s.CihazId, s.GonderenId, baglam.KullaniciId], iptal);
                    if (istek.FtrProgramId is int fp && kalici)
                        await b.CalistirAsync("""
                            insert into public.ftr_seans (sube_id, program_id, sira, tarih, saat, fizyoterapist_id, kabin_id, randevu_id, durum, ekleyen)
                            values (@p0, @p1, @p2, @p3::date, @p4, @p5, @p6, @p7, 1, @p8)
                            """, islem, [s.SubeId, fp, (short)(siraSon + 1), t.Date, t.ToString("HH:mm"), s.HekimId, s.KabinId, id,
                                         baglam.KullaniciId], iptal);
                    if (kalici) await islem.ReleaseAsync("seri", iptal);
                    else await islem.RollbackAsync("seri", iptal);
                    return (true, "", id);
                }
                catch (PostgresException h)
                {
                    await islem.RollbackAsync("seri", iptal);
                    return (false, h.SqlState == "23505" ? "Doktorun bu saatte başka randevusu var." : h.MessageText, 0);
                }
            }

            var satirlar = new List<object>();
            var olusan = new List<int>();
            foreach (var t in tarihler)
            {
                var (tamam, mesaj, id) = await Dene(t, true);
                if (tamam)
                {
                    siraSon++;
                    olusan.Add(id);
                    satirlar.Add(new { baslangic = t.ToString("yyyy-MM-ddTHH:mm"), tamam = true, mesaj = "", oneri = (string?)null });
                    continue;
                }
                // ÖNERİ: aynı gün, 15 dk (kısa randevuda 10 dk) adımla ileri; en çok 24 deneme, 21:00'e kadar.
                //   Denemeler geri alınır. Adım sabit: süreden türeyen adım "11:06" gibi saatler öneriyordu.
                string? oneri = null;
                var adim = s.SureDk >= 30 ? 15 : 10;
                for (var (i, c) = (1, t.AddMinutes(adim)); i <= 24 && c.Date == t.Date && c.Hour < 21; i++, c = c.AddMinutes(adim))
                {
                    if ((await Dene(c, false)).tamam) { oneri = c.ToString("HH:mm"); break; }
                }
                satirlar.Add(new { baslangic = t.ToString("yyyy-MM-ddTHH:mm"), tamam = false, mesaj, oneri });
            }

            if (!istek.Kaydet || olusan.Count == 0)
            {
                await islem.RollbackAsync(iptal);
                return Results.Ok(new { kaydedildi = false, uygun = olusan.Count, satirlar });
            }

            foreach (var id in olusan)
                await log.YazAsync(b, islem, LogIslemi.Ekle, LogRandevu, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { seri = istek.KaynakRandevuId ?? (object?)null, ftrProgram = istek.FtrProgramId }, tarafId: s.HastaId, iptal: iptal);
            if (istek.FtrProgramId is int fpr)
            {
                await b.CalistirAsync("""
                    update public.ftr_program set durum = case when durum = 1 then 2 else durum end,
                           fizyoterapist_id = coalesce(@p1, fizyoterapist_id), kabin_id = coalesce(@p2, kabin_id),
                           degistiren = @p3, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [fpr, istek.HekimId, istek.KabinId, baglam.KullaniciId], iptal);
                await log.YazAsync(b, islem, LogIslemi.Degistir, LogFtrProgram, fpr, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { seansPlanlandi = olusan.Count, randevulu = true }, tarafId: s.HastaId, iptal: iptal);
            }
            await islem.CommitAsync(iptal);
            foreach (var id in olusan) await hatirlatma.TazeleAsync(id, baglam.KullaniciId, iptal);
            return Results.Ok(new { kaydedildi = true, uygun = olusan.Count, satirlar });
        });
    }

    /// <summary>Şablon: kaynak randevunun alanları ya da FTR programı (doktor = fizyoterapist, yoksa program hekimi).</summary>
    private static async Task<SeriSablon> SablonOkuAsync(NpgsqlConnection b, SeriIstegi istek, CancellationToken iptal)
    {
        if (istek.KaynakRandevuId is int rid)
        {
            var r = await b.TekAsync("""
                select sube_id, bolum, hekim_id, hasta_id, sure_dk, aciklama, hizmet_id, tip, kaynak, cihaz_id, gonderen_id, durum
                  from public.randevu where id = @p0
                """, null, [rid], o => new
            {
                s = new SeriSablon(o.GetInt32(0), o.GetInt16(1), o.IsDBNull(2) ? null : o.GetInt32(2), o.GetInt32(3),
                    o.GetInt16(4), o.GetString(5), o.IsDBNull(6) ? null : o.GetInt32(6), o.GetInt16(7), o.GetInt16(8),
                    o.IsDBNull(9) ? null : o.GetInt32(9), o.IsDBNull(10) ? null : o.GetInt32(10), null),
                durum = o.GetInt16(11),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Randevu bulunamadı.");
            return r.s with { SureDk = istek.SureDk ?? r.s.SureDk, HekimId = istek.HekimId ?? r.s.HekimId };
        }

        var p = await b.TekAsync("""
            select p.sube_id, p.hasta_id, coalesce(@p1, p.fizyoterapist_id, p.hekim_id), p.seans_sure_dk, p.program_no,
                   coalesce(@p2, p.kabin_id), p.durum,
                   coalesce((select t.departman from public.taraf t where t.id = coalesce(@p1, p.fizyoterapist_id, p.hekim_id)), 0)
              from public.ftr_program p where p.id = @p0
            """, null, [istek.FtrProgramId, istek.HekimId, istek.KabinId], o => new
        {
            subeId = o.GetInt32(0), hastaId = o.GetInt32(1), hekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
            sure = o.GetInt16(3), no = o.GetString(4), kabinId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
            durum = o.GetInt16(6), bolum = Convert.ToInt16(o.GetValue(7)),
        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Program bulunamadı.");
        if (p.durum >= 4) throw GentegreHatasi.IsKurali("Kapanmış program planlanmaz.");
        if (p.hekimId is null) throw GentegreHatasi.IsKurali("Programda fizyoterapist ya da hekim yok - önce programa fizyoterapist seçin.");
        if (p.bolum == 0) throw GentegreHatasi.IsKurali("Fizyoterapistin bölümü (departman) tanımlı değil - personel kartından bölüm seçin.");
        return new SeriSablon(p.subeId, p.bolum, p.hekimId, p.hastaId, istek.SureDk ?? p.sure, $"FTR {p.no}".Trim(),
            null, 1, 1, null, null, p.kabinId);
    }
}
