using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BİLDİRİMİ ZORUNLU BULAŞICI HASTALIK — BZBH (882, KTS maddesi H5).
///
/// <para><b>Taslak kendiliğinden açılır, bildirim elle tamamlanır.</b>
/// Muayene tamamlanırken tanılar BZBH listesiyle eşleştirilir ve eşleşen
/// her tanı için bekleyen bir bildirim satırı açılır. 214 paketinin iki
/// zorunlu alanı (vaka tipi ve klinik belirti başlangıcı) tanıdan
/// çıkarılamaz - onları hekim girer, paket ancak o zaman üretilir.</para>
///
/// <para><b>Bildirim silinmez, vazgeçilir.</b> "Bu tanı yanlıştı, bildirim
/// gerekmiyor" kararı da kayıttır: denetimde "açılmış ama gönderilmemiş"
/// bildirimin neden gönderilmediği sorulur.</para>
/// </summary>
public static class BzbhUclari
{
    private const int LogTabloBzbh = 1145;

    public sealed record BildirimIstegi(int? VakaTipi, string? BelirtiTarihi, string? Not);

    public static void BzbhUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/bzbh").WithTags("BZBH").RequireAuthorization();

        // ------------------------------------------------------- pano ----
        // Bekleyen bildirimler + gecikenler. Enfeksiyon kontrol biriminin
        //   günlük ekranı: Grup A'da süre 24 saat ve gecikme denetimde
        //   ilk sorulan şeydir.
        grup.MapGet("/pano", async (
            int? durum, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bzbh", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync(Secim + """
                 where (cast(@p0 as smallint) is null or v.durum = @p0)
                   and (@p1 = 0 or v.sube_id = @p1)
                 order by v.durum, v.gecikti desc, v.id desc
                 limit 300
                """, null, [durum, baglam.SubeId ?? 0], Oku, iptal);
            var sayac = await b.TekAsync("""
                select count(*) filter (where durum = 0)::int as bekleyen,
                       count(*) filter (where durum = 0 and gecikti = 1)::int as geciken,
                       count(*) filter (where durum = 1)::int as bildirilen
                  from public.v_bzbh_bildirim
                 where (@p0 = 0 or sube_id = @p0)
                """, null, [baglam.SubeId ?? 0],
                o => new { bekleyen = o.GetInt32(0), geciken = o.GetInt32(1),
                           bildirilen = o.GetInt32(2) }, iptal);
            return Results.Ok(new { bildirimler = liste, sayac });
        });

        grup.MapGet("/bildirim/{id:long}", async (
            long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bzbh", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kayit = await b.TekAsync(Secim + " where v.id = @p0", null, [id], Oku, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Bildirim bulunamadı.");
            return Results.Ok(new { bildirim = kayit });
        });

        // ----------------------------------------------------- bildir ----
        // 214 paketini üretir. Zorunlu alanlar BURADA durdurur: eksik
        //   gönderilen paket USS'den geri döner ve bildirim gitmemiş olur -
        //   hata hekime saatler sonra kuyruk ekranında görünürdü.
        grup.MapPost("/bildirim/{id:long}/bildir", async (
            long id, BildirimIstegi? istek, VeriKaynagi veri, EnabizPaketUretici uretici,
            LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bzbh", Islem.Degistir);
            baglam.AksiyonIste("bzbh.bildir");

            await using var baglanti = await veri.AcAsync(iptal);
            var kayit = await baglanti.TekAsync("""
                select b.durum, b.hasta_id, b.belge_id, b.icd_kod,
                       coalesce(b.vaka_tipi, 0) as vaka_tipi, b.belirti_tarihi,
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.belge_id), '') as takip
                  from public.bzbh_bildirim b where b.id = @p0
                """, null, [id], o => new
            {
                durum = o.GetInt16(0), hastaId = o.GetInt32(1),
                belgeId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                icd = o.GetString(3), vakaTipi = o.GetInt32(4),
                belirti = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                takip = o.GetString(6),
            }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Bildirim bulunamadı.");
            if (kayit.durum == 1) throw GentegreHatasi.IsKurali("Bildirim zaten gönderildi.");

            // İstekle gelen alanlar önce yazılır (kart "kaydet + bildir"i tek
            //   düğmede yapıyor); sonra eksik kontrolü aynı satırdan okunur.
            if (istek is not null)
                await baglanti.CalistirAsync("""
                    update public.bzbh_bildirim
                       set vaka_tipi = coalesce(cast(@p1 as smallint), vaka_tipi),
                           belirti_tarihi = coalesce(cast(@p2 as date), belirti_tarihi),
                           not_metin = coalesce(nullif(@p3, ''), not_metin),
                           degistiren = @p4, degistirme_tarihi = now()
                     where id = @p0
                    """, null, [id, istek.VakaTipi, istek.BelirtiTarihi, istek.Not ?? "",
                                baglam.KullaniciId], iptal);

            var son = await baglanti.TekAsync("""
                select coalesce(vaka_tipi, 0), belirti_tarihi from public.bzbh_bildirim
                 where id = @p0
                """, null, [id],
                o => new { vaka = o.GetInt32(0),
                           belirti = o.IsDBNull(1) ? (DateTime?)null : o.GetDateTime(1) }, iptal)!;

            var eksik = new List<AlanHatasi>();
            if (son.vaka == 0) eksik.Add(new("vakaTipi", "Vaka tipi seçilmeli (şüpheli / olası / kesin)."));
            if (son.belirti is null) eksik.Add(new("belirtiTarihi", "Klinik belirtilerin başladığı tarih zorunlu."));
            if (kayit.icd.Trim().Length == 0) eksik.Add(new("icdKod", "Tanı (ICD-10) boş."));
            if (kayit.takip.Trim().Length == 0)
                eksik.Add(new("takip",
                    "Başvurunun e-Nabız takip numarası (SYSTakipNo) henüz gelmedi; "
                    + "hasta kaydı USS'ye gittikten sonra bildirilebilir."));
            if (eksik.Count > 0)
                throw GentegreHatasi.Dogrulama(
                    "Bildirim gönderilemez: " + string.Join(" ", eksik.Select(x => x.Mesaj)),
                    [.. eksik]);

            var s = await uretici.UretAsync("BZBH_BILDIRIM", (int)id, baglam.KullaniciId, iptal)
                ?? throw GentegreHatasi.IsKurali(
                    "214 paketi üretilemedi (paket türü kapalı olabilir).");

            await baglanti.CalistirAsync("""
                update public.bzbh_bildirim
                   set durum = 1, bildirim_zamani = now(),
                       paket_id = (select p.id from public.enabiz_paket p where p.paket_no = @p1),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, s.PaketNo, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloBzbh, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip,
                new { bildirildi = true, paket = s.PaketNo, icd = kayit.icd, vaka = son.vaka },
                tarafId: kayit.hastaId, iptal: iptal);

            return Results.Ok(new { id, paketNo = s.PaketNo, eksikler = s.Eksikler,
                                    mesaj = s.Eksikler.Count == 0
                                        ? $"Bildirim gönderim kuyruğuna alındı ({s.PaketNo})."
                                        : $"Paket üretildi ({s.PaketNo}) ama eksik alan var: "
                                          + string.Join(", ", s.Eksikler) });
        });

        // ---------------------------------------------------- vazgeç ----
        grup.MapPost("/bildirim/{id:long}/vazgec", async (
            long id, BildirimIstegi? istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bzbh", Islem.Degistir);
            var gerekce = (istek?.Not ?? "").Trim();
            if (gerekce.Length == 0)
                throw GentegreHatasi.Dogrulama(
                    "Vazgeçme gerekçesi zorunlu - denetimde \"neden bildirilmedi\" sorulur.",
                    [new("not", "Gerekçe yazılmalı.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            var kayit = await baglanti.TekAsync(
                "select durum, hasta_id from public.bzbh_bildirim where id = @p0",
                null, [id], o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Bildirim bulunamadı.");
            if (kayit.durum == 1)
                throw GentegreHatasi.IsKurali("Gönderilmiş bildirimden vazgeçilemez.");

            await baglanti.CalistirAsync("""
                update public.bzbh_bildirim
                   set durum = 2, not_metin = @p1, degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, gerekce, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloBzbh, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { vazgecildi = true, gerekce },
                tarafId: kayit.hastaId, iptal: iptal);
            return Results.Ok(new { durum = 2 });
        });

        // ------------------------------------------------ vaka tipleri ----
        grup.MapGet("/vaka-tipleri", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("bzbh", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select d.deger, d.ad from public.kod_deger d
                  join public.kod_liste l on l.id = d.liste_id
                 where l.kod = 'bzbh.vaka_tipi' and d.aktif = 1 order by d.sira
                """, null, [], o => new { kod = (int)o.GetInt16(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { tipler = liste });
        });
    }

    /// <summary>
    /// TANIDAN BİLDİRİM TASLAĞI (882). Muayene tamamlanırken çağrılır.
    ///
    /// <para>Her BZBH tanısı için bir satır; aynı muayene + aynı ICD için
    /// ikinci satır açılmaz (benzersiz kısıt). Muayene iki kez tamamlanırsa
    /// mükerrer bildirim doğurmaz.</para>
    ///
    /// <para><b>Sessizdir:</b> taslak açılamazsa muayene tamamlanması
    /// DÜŞMEZ - bildirim ikincil iştir, klinik kaydın şartı değil.</para>
    /// </summary>
    public static async Task<int> TaslakAcAsync(NpgsqlConnection baglanti, int muayeneId,
                                                int kullaniciId, CancellationToken iptal)
        => await baglanti.TekDegerAsync<int>("""
            with tanilar as (
              select t.icd_kod, m.taraf_id, m.belge_id, m.personel_id, m.sube_id,
                     coalesce(m.tamamlanma, m.bitis, now()) as tani_zamani,
                     (public.fn_bzbh_hastalik(t.icd_kod)).id as hastalik_id
                from public.tani t
                join public.muayene m on m.id = t.muayene_id
               where t.muayene_id = @p0 and coalesce(t.icd_kod, '') <> ''
            )
            insert into public.bzbh_bildirim
                   (sube_id, hasta_id, muayene_id, belge_id, hastalik_id, icd_kod,
                    hekim_id, tani_zamani, durum, ekleyen)
            select coalesce(sube_id, 0), taraf_id, @p0, belge_id, hastalik_id, icd_kod,
                   personel_id, tani_zamani, 0, @p1
              from tanilar
             where hastalik_id is not null
            on conflict (muayene_id, icd_kod) do nothing
            returning 1
            """, null, [muayeneId, kullaniciId], iptal);

    private const string Secim = """
        select v.id, v.hasta_id, v.hasta_adi, v.hasta_kimlik, v.muayene_id, v.icd_kod, v.icd_adi,
               v.hastalik_adi, v.grup, v.grup_adi, v.sure_saat, v.hekim_adi, v.tani_zamani,
               v.vaka_tipi, v.vaka_tipi_adi, v.belirti_tarihi, v.durum, v.durum_adi,
               v.bildirim_zamani, v.paket_no, v.not_metin, v.gecikti
          from public.v_bzbh_bildirim v
        """;

    private static object Oku(NpgsqlDataReader o) => new
    {
        id = o.GetInt64(0), hastaId = o.GetInt32(1), hasta = o.GetString(2),
        hastaKimlik = o.GetString(3),
        muayeneId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
        icdKod = o.GetString(5), icdAdi = o.GetString(6), hastalik = o.GetString(7),
        grup = (int)o.GetInt16(8), grupAdi = o.GetString(9), sureSaat = (int)o.GetInt16(10),
        hekim = o.GetString(11),
        taniZamani = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
        vakaTipi = o.IsDBNull(13) ? (int?)null : (int)o.GetInt16(13),
        vakaTipiAdi = o.GetString(14),
        belirtiTarihi = o.IsDBNull(15) ? (DateTime?)null : o.GetDateTime(15),
        durum = (int)o.GetInt16(16), durumAdi = o.GetString(17),
        bildirimZamani = o.IsDBNull(18) ? (DateTime?)null : o.GetDateTime(18),
        paketNo = o.GetString(19), not_ = o.GetString(20), gecikti = o.GetInt16(21) == 1,
    };
}
