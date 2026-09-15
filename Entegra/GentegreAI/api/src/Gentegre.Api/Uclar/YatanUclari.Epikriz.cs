using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// EPİKRİZ, ÇIKIŞ REÇETESİ VE KONTROL RANDEVUSU (mockup
/// <c>Ekranlar/Yatan/taburcu_epikriz.html</c>).
///
/// <para><b>Epikriz yatış boyunca birikir, çıkış saatinde sıfırdan
/// yazılmaz.</b> Altı günlük seyri son anda hatırlamak, epikrizi "yatırıldı,
/// tedavi edildi, taburcu edildi" cümlesine indirger. Bu yüzden kayıt taburcu
/// ekranında da, yatış kartının Epikriz sekmesinde de AYNI satırdır
/// (<c>epikriz</c>, yatış başına tek).</para>
///
/// <para><b>Tetkik özeti DERLENMİŞ TASLAKTIR:</b> lab ve görüntüleme
/// sonuçlarından üretilir ama hekim düzenleyene kadar epikrize girmiş sayılmaz
/// — bu yüzden taslak ayrı döner, kaydedilen alanın üstüne yazılmaz.</para>
///
/// <para><b>Çıkış reçetesi evde kullandığı ilaçlarla birlikte çıkar:</b> yalnız
/// yeni yazılanları göstermek, hastanın kendi ilacını kesip kesmeyeceğini
/// belirsiz bırakır. Aday liste yatışın ilaç order'larından gelir; hekim
/// hangisinin devam edeceğini işaretler.</para>
///
/// <para><b>Kontrol randevusu taburcuyla birlikte AÇILIR:</b> "on gün sonra
/// gelin" denip randevu verilmeyen hastanın yarısı gelmez. Randevu
/// <c>public.randevu</c>'ya yazılır — ikinci bir "kontrol" kaydı tutmak,
/// takvimde görünmeyen bir randevu üretirdi.</para>
/// </summary>
public static partial class YatanUclari
{
    public sealed record EpikrizIstegi(
        string? Sikayet, string? Hikaye, string? Bulgular, string? TetkikOzet,
        string? Tedavi, string? Seyir, string? Oneriler,
        DateTime? KontrolTarihi, int? KontrolBolumId,
        IReadOnlyList<CikisIlaci>? CikisIlaclari);

    /// <summary>Çıkış reçetesi satırı: kaynak 1 yatış tedavisi · 2 yeni · 3 evde kullandığı.</summary>
    public sealed record CikisIlaci(string Ad, string Doz, string Yol, string Sure,
                                    string Not, short Kaynak);

    private static void EpikrizUclariniEkle(RouteGroupBuilder grup)
    {
        // ----------------------------------------------- epikriz + taslaklar ----
        grup.MapGet("/{yatisId:int}/epikriz", async (
            int yatisId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var epikriz = await baglanti.TekAsync("""
                select e.id, e.sikayet, e.hikaye, e.bulgular, e.tetkik_ozet, e.tedavi,
                       e.seyir, e.oneriler, e.cikis_ilaclari::text, e.kontrol_tarihi,
                       e.kontrol_bolum_id, e.imza_durum, e.imza_zamani,
                       coalesce(d.ad, '') as kontrol_bolum
                  from public.epikriz e
                  left join public.departman d on d.id = e.kontrol_bolum_id
                 where e.yatis_id = @p0
                """, null, [yatisId], o => new
            {
                id = o.GetInt32(0),
                sikayet = o.GetString(1),
                hikaye = o.GetString(2),
                bulgular = o.GetString(3),
                tetkikOzet = o.GetString(4),
                tedavi = o.GetString(5),
                seyir = o.GetString(6),
                oneriler = o.GetString(7),
                cikisIlaclari = o.GetString(8),
                kontrolTarihi = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                kontrolBolumId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10),
                imzaDurum = (int)o.GetInt16(11),
                imzaZamani = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
                kontrolBolum = o.GetString(13),
            }, iptal);

            // TETKİK ÖZETİ TASLAĞI: yatış boyunca istenen tetkik ve
            //   görüntülemelerin satır satır dökümü. Hekim kopyalar, düzeltir,
            //   kısaltır - biz onun yerine "yorum" yazmıyoruz, yalnız ne
            //   istendiğini hatırlatıyoruz.
            var taslakSatirlari = await baglanti.ListeAsync("""
                select od.baslangic, od.ad,
                       case od.tur when 3 then 'tetkik' when 4 then 'görüntüleme'
                                   when 5 then 'konsültasyon' else '' end as tur_ad,
                       od.durum
                  from public.yatis_order od
                 where od.yatis_id = @p0 and od.tur in (3, 4, 5) and od.durum <> 0
                 order by od.baslangic
                """, null, [yatisId], o => new
            {
                tarih = o.GetDateTime(0),
                ad = o.GetString(1),
                turAd = o.GetString(2),
                durum = (int)o.GetInt16(3),
            }, iptal);

            var taslak = string.Join("\n", taslakSatirlari.Select(t =>
                $"{t.tarih:dd.MM} {t.ad} ({t.turAd})"
                + (t.durum == 1 ? " — sonuç bekleniyor" : "")));

            // ÇIKIŞ REÇETESİ ADAYLARI: yatışta verilen ilaçlar. "Evde
            //   kullandığı" ilaçlar da listede olmalı ama onları hasta
            //   kartından bilmiyoruz - hekim elle ekler; alan bunu söylüyor.
            var ilacAdaylari = await baglanti.ListeAsync("""
                select od.ad, coalesce(od.doz::text, '') as doz, coalesce(k.ad, '') as yol,
                       od.siklik, od.durum,
                       (select count(*) from public.order_uygulama u
                         where u.order_id = od.id and u.durum = 2)::int as verilen
                  from public.yatis_order od
                  left join public.kod_deger k on k.deger = od.yol
                   and k.liste_id = (select l.id from public.kod_liste l
                                      where l.kod = 'yatan.order_yol')
                 where od.yatis_id = @p0 and od.tur = 1 and od.durum <> 0
                 order by od.ad
                """, null, [yatisId], o => new
            {
                ad = o.GetString(0),
                doz = o.GetString(1),
                yol = o.GetString(2),
                siklik = o.GetString(3),
                durum = (int)o.GetInt16(4),
                verilen = o.GetInt32(5),
            }, iptal);

            return Results.Ok(new { epikriz, tetkikTaslak = taslak, ilacAdaylari });
        });

        // ----------------------------------------------------- epikriz yazma ----
        // TEK SATIR (yatış başına): "upsert". İki epikriz, iki farklı çıkış
        //   özeti demektir; hangisinin hastaya verildiği anlaşılmaz.
        grup.MapPost("/{yatisId:int}/epikriz", async (
            int yatisId, EpikrizIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Degistir);

            var ilaclar = JsonSerializer.Serialize(istek.CikisIlaclari ?? []);

            await using var baglanti = await veri.AcAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                insert into public.epikriz
                    (sube_id, yatis_id, sikayet, hikaye, bulgular, tetkik_ozet, tedavi,
                     seyir, oneriler, cikis_ilaclari, kontrol_tarihi, kontrol_bolum_id,
                     ekleyen)
                values (@p1, @p0, coalesce(@p2, ''), coalesce(@p3, ''), coalesce(@p4, ''),
                        coalesce(@p5, ''), coalesce(@p6, ''), coalesce(@p7, ''),
                        coalesce(@p8, ''), @p9::jsonb, @p10, @p11, @p12)
                on conflict (yatis_id) do update
                   set sikayet = excluded.sikayet, hikaye = excluded.hikaye,
                       bulgular = excluded.bulgular, tetkik_ozet = excluded.tetkik_ozet,
                       tedavi = excluded.tedavi, seyir = excluded.seyir,
                       oneriler = excluded.oneriler,
                       cikis_ilaclari = excluded.cikis_ilaclari,
                       kontrol_tarihi = excluded.kontrol_tarihi,
                       kontrol_bolum_id = excluded.kontrol_bolum_id,
                       degistiren = @p12, degistirme_tarihi = now()
                returning id
                """, null,
                [yatisId, baglam.SubeId ?? 0, istek.Sikayet, istek.Hikaye, istek.Bulgular,
                 istek.TetkikOzet, istek.Tedavi, istek.Seyir, istek.Oneriler, ilaclar,
                 istek.KontrolTarihi, istek.KontrolBolumId, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, yatisId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { epikriz = "kaydedildi", kontrol = istek.KontrolTarihi }, iptal: iptal);

            return Results.Ok(new { id });
        });

        // --------------------------------------------------- epikriz imzası ----
        // İMZA AYRI ADIM: taslak epikriz taburcuyu durdurmaz ama imzalı epikriz
        //   hekimin sorumluluğudur. İkisini tek kaydetmeye bağlamak, her
        //   düzeltmeyi "imza" saymak olurdu.
        grup.MapPost("/{yatisId:int}/epikriz/imzala", async (
            int yatisId, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.taburcu");

            var etkilenen = await veri.CalistirAsync("""
                update public.epikriz
                   set imza_durum = 1, imza_zamani = now(),
                       degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and imza_durum = 0
                """, new object?[] { yatisId, baglam.KullaniciId }, iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Epikriz yok ya da zaten imzalı.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, yatisId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { epikriz = "imzalandı" }, iptal: iptal);

            return Results.Ok(new { yatisId, imzali = true });
        });
    }

    /// <summary>
    /// KONTROL RANDEVUSUNU AÇAR (taburcu akışının parçası).
    ///
    /// Epikrizde kontrol tarihi varsa ve o gün için hastanın randevusu YOKSA
    /// açılır. "On gün sonra gelin" denip randevu verilmeyen hastanın yarısı
    /// gelmiyor; randevuyu taburcuya bağlamak, bu adımın unutulmasını
    /// engelliyor.
    ///
    /// Saat 10:00 varsayılan: kontrol randevusu poliklinik akışına girer ve
    /// kesin saati sekreterlik kaydırır. Saat sormak, taburcu ekranını
    /// randevu ekranına çevirirdi.
    /// </summary>
    private static async Task<int?> KontrolRandevusuAcAsync(
        Npgsql.NpgsqlConnection baglanti, Npgsql.NpgsqlTransaction islem,
        int yatisId, int hastaId, int subeId, int kullaniciId, CancellationToken iptal)
    {
        // HEKİM ZORUNLU (randevu kuralı: hekim ya da cihaz). Kontrol
        //   randevusu yatışın SORUMLU HEKİMİNE açılır; epikrizde başka bölüm
        //   seçilmişse bölüm oradan gelir. Yatışın hekimi yoksa randevu
        //   AÇILMAZ ve taburcu bundan dolayı durmaz - randevusu olmayan
        //   taburcu, taburcu olmayan hastadan iyidir; eksiklik yanıtta döner.
        var kontrol = await baglanti.TekAsync("""
            select e.kontrol_tarihi, e.kontrol_bolum_id, y.hekim_id, y.departman_id
              from public.epikriz e
              join public.yatis y on y.id = e.yatis_id
             where e.yatis_id = @p0 and e.kontrol_tarihi is not null
            """, islem, [yatisId], o => new
        {
            tarih = o.GetDateTime(0),
            bolumId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
            hekimId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
            departmanId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
        }, iptal);

        if (kontrol is null || kontrol.hekimId is null) return null;

        // AYNI GÜN İKİNCİ RANDEVU AÇILMAZ: taburcu iki kez denenirse hasta
        //   takvimde iki kez görünürdü.
        var varOlan = await baglanti.TekDegerAsync<int?>("""
            select id from public.randevu
             where hasta_id = @p0 and baslangic::date = @p1::date and durum <> 0
             limit 1
            """, islem, [hastaId, kontrol.tarih], iptal);
        if (varOlan is int mevcut) return mevcut;

        return await baglanti.TekDegerAsync<int>("""
            insert into public.randevu
                (sube_id, bolum, hekim_id, hasta_id, baslangic, sure_dk, durum,
                 aciklama, ekleyen)
            values (@p0, coalesce(@p1, @p5, 0)::smallint, @p6, @p2,
                    (@p3::date + time '10:00'), 15, 1, 'Taburcu kontrol randevusu', @p4)
            returning id
            """, islem,
            [subeId, kontrol.bolumId, hastaId, kontrol.tarih, kullaniciId,
             kontrol.departmanId, kontrol.hekimId],
            iptal);
    }
}
