using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MENÜ DÜZENİ (979, mockup <c>Ekranlar/Ayarlar/menu_duzenleme_v2.html</c>).
///
/// <para><b>Sunucu menüyü BİLMEZ:</b> ağacın kendisi istemci kodundadır
/// (<c>listeTanimlari*.ts</c> + <c>kabuk/menuBolgeleri.ts</c>). Bu uç yalnız
/// kurumun yaptığı <b>farkı</b> saklar ve geri verir; istemci varsayılan ağacı
/// kurar, farkı üstüne uygular. Tam ağacı sunucuya kopyalamak, her yeni ekranda
/// iki yeri birden güncellemek (ve unutulduğunda ekranın hiç görünmemesi)
/// demekti.</para>
///
/// <para><b>Yerleşim, erişim değil:</b> burada gizlenen ekran yetkisi olan
/// kullanıcıya adresten yine açılır - erişim <c>yetki</c> tablosunun işidir.
/// Bu yüzden kaydetme <c>menu.duzen</c> yetkisi ister, okuma herkese açıktır
/// (kendi menüsünü çizebilmesi için).</para>
/// </summary>
public static class MenuDuzenUclari
{
    /// <param name="DugumTur">1 bölge · 2 grup · 3 alt başlık · 4 ekran.</param>
    /// <param name="SistemKod">Değişmez kimlik (ekranda liste kaynağı, grupta çevrilmemiş ad).</param>
    public sealed record DuzenSatiri(
        short DugumTur, string SistemKod, string? UstKod, short? Sira,
        string? GorunenAd, string? Ikon, short Gizli, short AcilistaAcik,
        string? DisBaglanti);

    public sealed record DuzenKaydet(int? SubeId, IReadOnlyList<DuzenSatiri> Satirlar);

    public static void MenuDuzenUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/menu-duzen").WithTags("Menü Düzeni")
                      .RequireAuthorization();

        // ------------------------------------------------------------ oku ----
        // Kullanıcı kendi menüsünü çizerken de bu ucu çağırır: yetki ARANMAZ
        //   (yetki arasaydı menü yalnız yöneticide düzenli görünürdü). Şube
        //   bağlamdan gelir; başka şubenin düzenini okumak için menu.duzen.
        grup.MapGet("/", async (int? subeId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var hedef = subeId ?? baglam.SubeId;
            if (subeId is not null && subeId != baglam.SubeId)
                baglam.YetkiIste("menu.duzen", Islem.Gor);

            await using var b = await veri.AcAsync(iptal);
            // ŞUBE SATIRI KURUM GENELİNİ EZER: aynı sistem_kod için iki satır
            //   varsa (biri sube_id null) şubeninki kazanır - `distinct on`
            //   sıralaması bunu yapıyor.
            var satirlar = await b.ListeAsync("""
                select distinct on (d.sistem_kod)
                       d.dugum_tur as "dugumTur", d.sistem_kod as "sistemKod",
                       d.ust_kod as "ustKod", d.sira,
                       coalesce(d.gorunen_ad, '') as "gorunenAd",
                       coalesce(d.ikon, '')       as ikon,
                       d.gizli, d.acilista_acik as "acilistaAcik",
                       coalesce(d.dis_baglanti, '') as "disBaglanti",
                       case when d.sube_id is null then 0 else 1 end as "subeyeOzel"
                  from public.menu_duzen d
                 where d.sube_id is null or d.sube_id = @p0
                 order by d.sistem_kod, d.sube_id nulls last
                """, null, [hedef], OkuyucuGenisletmeleri.Sozluk, iptal);

            // TekAsync basvuru turu istiyor (T : class): sayiyi sozluk olarak oku.
            var sayim = await b.TekAsync("""
                select count(*) as say from public.menu_duzen where sube_id = @p0
                """, null, [hedef], OkuyucuGenisletmeleri.Sozluk, iptal);
            var subeyeOzel = Convert.ToInt64(sayim?["say"] ?? 0L);

            return Results.Ok(new
            {
                subeId = hedef, satirlar,
                // Kaç satırın şubeye ait olduğu ekranda "şubeye özel düzen"
                //   rozetini belirler; 0 ise kurum geneli / kod varsayılanı.
                subeyeOzel,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ---------------------------------------------------------- kaydet ----
        /* TAMAMINI DEĞİŞTİRİR (şube başına): ekran farkların tamamını gönderir,
           sunucu o şubenin satırlarını silip yenisini yazar. Satır satır
           güncelleme, silinen bir değişikliği (geri alınan ad) tespit etmek
           için ayrı bir "silinenler" listesi taşımayı gerektirirdi. */
        grup.MapPut("/", async (DuzenKaydet istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("menu.duzen", Islem.Degistir);
            baglam.YazmaIste();
            var hedef = istek.SubeId ?? baglam.SubeId
                ?? throw GentegreHatasi.Dogrulama("Şube seçili değil.");

            foreach (var s in istek.Satirlar)
            {
                if (string.IsNullOrWhiteSpace(s.SistemKod))
                    throw GentegreHatasi.Dogrulama("Sistem kodu boş olan satır var.");
                if (s.DugumTur is < 1 or > 4)
                    throw GentegreHatasi.Dogrulama($"Geçersiz düğüm türü: {s.DugumTur}");
                // ALT BAŞLIK ve DIŞ BAĞLANTI kurumun ürettiği düğümlerdir:
                //   kodda karşılığı yok, adsız kalırsa menüde boş satır olur.
                if (s.DugumTur == 3 && string.IsNullOrWhiteSpace(s.GorunenAd))
                    throw GentegreHatasi.Dogrulama("Alt başlığın adı zorunludur.");
                // İKON GÖRSELİ (980): emoji ya da küçük `data:` URL'i. Kolon metin
                //   olduğu için sınır BURADA: menü her çizimde okunuyor, büyük
                //   görsel bütün menüyü yavaşlatırdı.
                if (s.Ikon is { Length: > 65536 })
                    throw GentegreHatasi.Dogrulama("İkon görseli en çok 64 KB olabilir.");
                if (s.Ikon is { Length: > 16 } g
                    && !g.StartsWith("data:image/", StringComparison.OrdinalIgnoreCase))
                    throw GentegreHatasi.Dogrulama(
                        "İkon ya kısa bir simge metni ya da data:image/... görseli olmalı.");
            }

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);

            await b.CalistirAsync("delete from public.menu_duzen where sube_id = @p0",
                islem, [hedef], iptal);

            foreach (var s in istek.Satirlar)
                await b.CalistirAsync("""
                    insert into public.menu_duzen
                           (sube_id, dugum_tur, sistem_kod, ust_kod, sira, gorunen_ad,
                            ikon, gizli, acilista_acik, dis_baglanti, ekleyen)
                    values (@p0, @p1, @p2, nullif(@p3, ''), @p4, nullif(@p5, ''),
                            nullif(@p6, ''), @p7, @p8, nullif(@p9, ''), @p10)
                    """, islem,
                    [hedef, s.DugumTur, s.SistemKod.Trim(), s.UstKod ?? "", s.Sira,
                     s.GorunenAd ?? "", s.Ikon ?? "", s.Gizli, s.AcilistaAcik,
                     s.DisBaglanti ?? "", baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);
            // ÖNBELLEK HEMEN DÜŞER: yöneticinin kaydettiği gizleme bir dakika
            //   beklemeden geçerli olsun (kapı bu kümeden okuyor).
            MenuDuzenDeposu.Temizle(hedef);

            // MENÜ DÜZENİ DENETLENİR: bir ekranın menüden kaldırıldığı sonradan
            //   "neden göremiyorum" sorusunun cevabıdır.
            await log.YazAsync(LogIslemi.Degistir, LogTabloMenuDuzen, hedef,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { satir = istek.Satirlar.Count, sube = hedef }, iptal: iptal);

            return Results.Ok(new { subeId = hedef, satir = istek.Satirlar.Count, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------- varsayılana dön ----
        grup.MapDelete("/", async (int? subeId, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("menu.duzen", Islem.Sil);
            baglam.YazmaIste();
            var hedef = subeId ?? baglam.SubeId
                ?? throw GentegreHatasi.Dogrulama("Şube seçili değil.");

            await using var b = await veri.AcAsync(iptal);
            var silinen = await b.CalistirAsync(
                "delete from public.menu_duzen where sube_id = @p0", null, [hedef], iptal);
            MenuDuzenDeposu.Temizle(hedef);

            await log.YazAsync(LogIslemi.Sil, LogTabloMenuDuzen, hedef,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "Varsayılana döndürüldü", silinen }, iptal: iptal);

            return Results.Ok(new { subeId = hedef, silinen, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Menü düzeni log tablo kimliği (ISLEMLOG).</summary>
    private const int LogTabloMenuDuzen = 979;
}
