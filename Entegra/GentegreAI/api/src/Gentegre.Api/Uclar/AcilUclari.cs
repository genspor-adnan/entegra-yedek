using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ACİL SERVİS İŞ AKIŞI UÇLARI (716 tabloları).
///
/// Dördü de kayıt yazmaktan fazlasını yapıyor ve bu yüzden kartın "alanı
/// güncelle" modeline sığmıyor:
///   triyaj  - düşürme ayrı yetki ister, gerekçe geçmişe yazılır
///   hekim   - "ilk gördü" damgası bir kez yazılır, hedef süresi hesaplanır
///   yatak   - iki tabloyu birden değiştirir (başvuru + yatak durumu)
///   çıkış   - tanı zorunluluğu, sevk yetkisi ve yatak boşaltma birlikte
///
/// KAPI SAATİ HİÇ DEĞİŞMEZ (716): bütün süreler ondan hesaplanır, uçların
/// hiçbiri `giris_zamani`e dokunmaz. Triyaj saati de İLK triyajda yazılır -
/// düzey sonradan değişse bile kapı-triyaj süresi kaymaz, yoksa kötüleşen her
/// hasta "hemen triyaj edilmiş" gibi görünürdü.
///
/// YATAK DURUMU ELLE DEĞİL AKIŞLA DEĞİŞİR: başvuru yatağa bağlanınca dolu,
/// hasta çıkınca TEMİZLİKTE olur (boş değil - temizlenmemiş yatağa hasta
/// yollamak panonun yalan söylemesi demektir).
/// </summary>
public static class AcilUclari
{
    /// <summary>islem_log.tablo_id - KartKatalogu.Acil ile aynı.</summary>
    private const int LogTabloBasvuru = 1160;
    private const int LogTabloCagri = 1161;
    private const int LogTabloYatak = 1163;

    public sealed class TriyajIstegi
    {
        /// <summary>1 kırmızı · 2 turuncu · 3 sarı · 4 yeşil · 5 mavi.</summary>
        public short Duzey { get; set; }
        public string? Gerekce { get; set; }
        /// <summary>Triyajla birlikte yatak verilecekse (resüsitasyon hemen alınır).</summary>
        public int? YatakId { get; set; }
    }

    public sealed class HekimIstegi
    {
        public int? HekimId { get; set; }
        public DateTime? Zaman { get; set; }
    }

    public sealed class YatakIstegi
    {
        /// <summary>Boş/null ise yatak BOŞALTILIR.</summary>
        public int? YatakId { get; set; }
    }

    public sealed class CikisIstegi
    {
        /// <summary>1 taburcu · 2 servise yatış · 3 yoğun bakım · 4 sevk · 5 ölüm · 6 kendi isteğiyle · 7 ameliyathane.</summary>
        public short CikisSekli { get; set; }
        public string CikisTani { get; set; } = "";
        public int? HedefBolumId { get; set; }
        public string? CikisNotu { get; set; }
        public DateTime? Zaman { get; set; }
    }

    public sealed class CagriIstegi
    {
        public short Tur { get; set; } = 1;
        public int? HedefBolumId { get; set; }
        public int? HedefKisiId { get; set; }
        public string? NotMetni { get; set; }
    }

    public sealed class CagriYanitIstegi
    {
        /// <summary>1 yanıtlandı · 2 kapandı · 3 yanıt yok (tekrar çağrıldı).</summary>
        public short Durum { get; set; } = 1;
        public int? YanitlayanId { get; set; }
        public string? NotMetni { get; set; }
    }

    public static void AcilUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/acil").WithTags("Acil Servis").RequireAuthorization();

        BasvuruUclari(grup);
        CikisUclari(grup);
        CagriUclari(grup);
        YatakUclari(grup);
    }

    // ============================================================== yatak ==
    private static void YatakUclari(RouteGroupBuilder grup)
    {
        // "TEMİZLİK BİTTİ" AYRI BİR OLAY. Çıkışta yatak temizliğe düşüyor;
        //   boşa dönmesi kartı açıp durum kutusunu değiştirmekle de olurdu ama
        //   o zaman kim ne zaman hazır dedi kaydı olmazdı - triyaj masası
        //   hasta yollama kararını bu bilgiye dayandırıyor.
        grup.MapPost("/yatak/{id:int}/temizlendi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.yatak", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            // Dolu yatak "temizlendi" olamaz: içinde hasta varken boşa
            //   çevrilmesi, panoyu iki hastayı aynı yatağa yazacak duruma sokar.
            var dolu = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.acil_basvuru b
                 where b.yatak_id = @p0 and b.cikis_zamani is null
                """, null, [id], iptal);
            if (dolu > 0)
                throw GentegreHatasi.IsKurali("Bu yatakta hasta var; önce çıkışını yapın.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.acil_yatak
                   set durum = 0, degistiren = @p1, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatak, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = 0, islem = "temizlik bitti" }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { durum = 0, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ============================================================ başvuru ==
    private static void BasvuruUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------ süre şeridi ----
        // Kartın ve panonun okuduğu tek hesap (v_acil_sure). İki yerde
        //   hesaplansaydı kapı-hekim panoda 16, raporda 18 dakika çıkardı.
        grup.MapGet("/basvuru/{id:long}/sure", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.basvuru", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var s = await baglanti.TekAsync("""
                select b.id, b.protokol_no as "protokolNo", b.giris_zamani as "girisZamani",
                       b.triyaj, b.triyaj_zamani as "triyajZamani",
                       b.hekim_gorme as "hekimGorme", b.cikis_zamani as "cikisZamani",
                       b.cikis_sekli as "cikisSekli", b.kimliksiz,
                       coalesce(nullif(h.unvan, ''), nullif(b.gecici_ad, ''), '—') as "hastaAd",
                       coalesce(y.kod, '') as yatak,
                       coalesce(hk.unvan, '') as "hekimAd",
                       v.kapi_triyaj_dk as "kapiTriyajDk", v.kapi_hekim_dk as "kapiHekimDk",
                       v.toplam_dk as "toplamDk", v.hedef_dk as "hedefDk",
                       v.hedefe_uyuldu as "hedefeUyuldu",
                       (select count(*) from public.acil_cagri c
                         where c.basvuru_id = b.id and c.durum in (0, 3)) as "acikCagri",
                       (select count(*) from public.acil_bildirim d
                         where d.basvuru_id = b.id and d.durum = 1) as "bekleyenBildirim"
                  from public.acil_basvuru b
                  join public.v_acil_sure v on v.basvuru_id = b.id
                  left join public.taraf h on h.id = b.hasta_id
                  left join public.taraf hk on hk.id = b.hekim_id
                  left join public.acil_yatak y on y.id = b.yatak_id
                 where b.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Acil başvurusu bulunamadı.");

            return Results.Ok(s);
        });

        // ------------------------------------------------------- triyaj ----
        // DÜŞÜRME AYRI YETKİ + GEREKÇE (716 yetkisi acil.triyaj_dusur).
        //   Yükseltme serbesttir: hasta kötüleştiğinde önünde engel olmamalı.
        //   Düşürmek ise hastayı sıranın gerisine atar; kimin hangi gerekçeyle
        //   yaptığı sorulabilir olmalı.
        //
        // GEÇMİŞİ TETİK YAZAR, GEREKÇEYİ BİZ (716): tetik doğrudan SQL ile
        //   yapılan değişikliği bile yakalar, ama gerekçeyi taşıyacak kolon
        //   satırda yok. Güncellemeden sonra o satırın gerekçesini dolduruyoruz.
        grup.MapPost("/basvuru/{id:long}/triyaj", async (
            long id, TriyajIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.triyaj", Islem.Degistir);

            if (istek.Duzey is < 1 or > 5)
                throw GentegreHatasi.Dogrulama("Triyaj düzeyi 1-5 olmalı.",
                    new AlanHatasi("duzey", "Triyaj düzeyi 1-5 olmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.triyaj, b.cikis_zamani as "cikisZamani", b.yatak_id as "yatakId"
                  from public.acil_basvuru b where b.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Acil başvurusu bulunamadı.");

            if (b["cikisZamani"] is not null)
                throw GentegreHatasi.IsKurali("Çıkışı yapılmış hastanın triyajı değiştirilemez.");

            var onceki = Convert.ToInt16(b["triyaj"] ?? (short)0);
            // Sayı BÜYÜDÜKÇE aciliyet AZALIR (1 = kırmızı).
            var dusurme = onceki > 0 && istek.Duzey > onceki;

            if (dusurme)
            {
                baglam.AksiyonIste("acil.triyaj_dusur");
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Triyaj düşürülüyorsa gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Triyaj düşürülüyorsa gerekçe zorunlu."));
            }

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // TRİYAJ SAATİ BİR KEZ (coalesce): kapı-triyaj süresi ilk
            //   değerlendirmenin ölçüsüdür, düzey değişince kaymamalı.
            await baglanti.CalistirAsync("""
                update public.acil_basvuru
                   set triyaj = @p1,
                       triyaj_zamani = coalesce(triyaj_zamani, (now())::timestamp),
                       triyaj_yapan_id = @p2,
                       degistiren = @p2, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, istek.Duzey, baglam.KullaniciId], iptal);

            // Tetiğin az önce yazdığı iz satırına gerekçeyi işle.
            if (!string.IsNullOrWhiteSpace(istek.Gerekce))
                await baglanti.CalistirAsync("""
                    update public.acil_triyaj_gecmis
                       set gerekce = @p1
                     where id = (select max(g.id) from public.acil_triyaj_gecmis g
                                  where g.basvuru_id = @p0)
                    """, islem, [id, istek.Gerekce!.Trim()], iptal);

            if (istek.YatakId is > 0)
                await YatakAtaAsync(baglanti, islem, id, istek.YatakId.Value,
                                    b["yatakId"], baglam.KullaniciId, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBasvuru, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { onceki, yeni = istek.Duzey, dusurme, gerekce = istek.Gerekce },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { triyaj = istek.Duzey, onceki, dusurme, izlemeNo = baglam.IzlemeNo });
        });

        // -------------------------------------------------- hekim gördü ----
        // "İlk gördü" damgası BİR KEZ yazılır: kapı-hekim süresinin ikinci ucu
        //   budur ve hekim değişince yeniden başlamaz. İkinci çağrıda mevcut
        //   damga korunur ve kullanıcıya olduğu gibi söylenir - sessizce
        //   üzerine yazmak, hedef süresi tutturulmuş gibi gösterirdi.
        grup.MapPost("/basvuru/{id:long}/hekim", async (
            long id, HekimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.basvuru", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.hekim_gorme as "hekimGorme", b.cikis_zamani as "cikisZamani",
                       b.triyaj
                  from public.acil_basvuru b where b.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Acil başvurusu bulunamadı.");

            if (b["cikisZamani"] is not null)
                throw GentegreHatasi.IsKurali("Çıkışı yapılmış başvuruda işlem yapılamaz.");

            var zaten = b["hekimGorme"] is not null;

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.acil_basvuru
                   set hekim_id = coalesce(@p1, hekim_id),
                       hekim_gorme = coalesce(hekim_gorme, @p2),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.HekimId ?? baglam.KullaniciId,
                 istek.Zaman ?? DateTime.Now, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBasvuru, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "hekim gördü", zatenVardi = zaten }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var s = await baglanti.TekAsync("""
                select v.kapi_hekim_dk as "kapiHekimDk", v.hedef_dk as "hedefDk",
                       v.hedefe_uyuldu as "hedefeUyuldu"
                  from public.v_acil_sure v where v.basvuru_id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { zatenVardi = zaten, sure = s, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------------- yatak ata / boşalt ----
        grup.MapPost("/basvuru/{id:long}/yatak", async (
            long id, YatakIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.basvuru", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.yatak_id as "yatakId", b.cikis_zamani as "cikisZamani"
                  from public.acil_basvuru b where b.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Acil başvurusu bulunamadı.");

            if (b["cikisZamani"] is not null)
                throw GentegreHatasi.IsKurali("Çıkışı yapılmış başvuruda işlem yapılamaz.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await YatakAtaAsync(baglanti, islem, id, istek.YatakId, b["yatakId"],
                                baglam.KullaniciId, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBasvuru, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { eski = b["yatakId"], yeni = istek.YatakId }, iptal: iptal);

            if (istek.YatakId is > 0)
                await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatak,
                    istek.YatakId.Value, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { durum = 1, basvuruId = id }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { yatakId = istek.YatakId, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ============================================================== çıkış ==
    private static void CikisUclari(RouteGroupBuilder grup)
    {
        // ÇIKIŞ KARARI tek uçtur ve üç şeyi birlikte yapar: tanıyı zorunlu
        //   kılar, sevki ayrı yetkiye bağlar, yatağı serbest bırakır. Ayrı
        //   adımlar olsaydı ilk ikisi yapılıp yatak dolu kalabilirdi - pano
        //   gerçeğin gerisinde kalırdı.
        grup.MapPost("/basvuru/{id:long}/cikis", async (
            long id, CikisIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("acil.cikis");

            if (istek.CikisSekli is < 1 or > 7)
                throw GentegreHatasi.Dogrulama("Çıkış şekli seçilmedi.",
                    new AlanHatasi("cikisSekli", "Çıkış şekli seçilmedi."));

            // SEVK AYRI YETKİ (716): hastayı başka kuruma yollamak kurumun
            //   dışına taşan bir karardır, taburcu değildir.
            if (istek.CikisSekli == 4) baglam.AksiyonIste("acil.sevk");

            // Tanı zorunluluğunu veritabanı da uyguluyor (716 tetiği); buradaki
            //   kontrol kullanıcıya ALAN ADIYLA hata döndürmek için - tetik
            //   hatası ekranda hangi kutunun kırmızı olacağını söyleyemez.
            if (string.IsNullOrWhiteSpace(istek.CikisTani))
                throw GentegreHatasi.Dogrulama(
                    "Çıkış tanısı zorunlu (ön tanı ile dosya kapatılamaz).",
                    new AlanHatasi("cikisTani", "Çıkış tanısı zorunlu."));

            // Yatış ve yoğun bakım kararı hedef bölüm ister: "yatışa karar
            //   verildi ama nereye" yatan hasta tarafında karşılıksız kalır.
            if (istek.CikisSekli is 2 or 3 && istek.HedefBolumId is null or <= 0)
                throw GentegreHatasi.Dogrulama("Yatış için hedef bölüm seçilmeli.",
                    new AlanHatasi("hedefBolumId", "Yatış için hedef bölüm seçilmeli."));

            await using var baglanti = await veri.AcAsync(iptal);

            var b = await baglanti.TekAsync("""
                select b.cikis_zamani as "cikisZamani", b.yatak_id as "yatakId",
                       b.hekim_gorme as "hekimGorme"
                  from public.acil_basvuru b where b.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Acil başvurusu bulunamadı.");

            if (b["cikisZamani"] is not null)
                throw GentegreHatasi.IsKurali("Bu başvurunun çıkışı zaten yapılmış.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.acil_basvuru
                   set cikis_sekli = @p1, cikis_tani = @p2, hedef_bolum_id = @p3,
                       cikis_notu = coalesce(@p4, cikis_notu),
                       cikis_zamani = @p5,
                       degistiren = @p6, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.CikisSekli, istek.CikisTani.Trim(), istek.HedefBolumId,
                 istek.CikisNotu, istek.Zaman ?? DateTime.Now, baglam.KullaniciId], iptal);

            // YATAK BOŞ DEĞİL, TEMİZLİKTE: temizlenmemiş yatağa hasta yollamak
            //   panonun yalan söylemesidir. "Temizlik bitti" ayrı bir olaydır.
            if (b["yatakId"] is not null)
                await baglanti.CalistirAsync("""
                    update public.acil_yatak
                       set durum = 2, degistiren = @p1, degistirme_tarihi = (now())::timestamp
                     where id = @p0
                    """, islem, [b["yatakId"], baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBasvuru, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    cikisSekli = istek.CikisSekli, tani = istek.CikisTani.Trim(),
                    hedefBolumId = istek.HedefBolumId,
                    // Hekim görmeden çıkan hasta olağandışıdır (yeşil alanda
                    //   olabilir); günlükte görünsün ki sorulabilsin.
                    hekimGormeden = b["hekimGorme"] is null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var s = await baglanti.TekAsync("""
                select v.toplam_dk as "toplamDk", v.kapi_hekim_dk as "kapiHekimDk",
                       v.hedefe_uyuldu as "hedefeUyuldu"
                  from public.v_acil_sure v where v.basvuru_id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                cikisSekli = istek.CikisSekli, yatakTemizlige = b["yatakId"] is not null,
                sure = s, izlemeNo = baglam.IzlemeNo
            });
        });
    }

    // ============================================================= çağrı ==
    private static void CagriUclari(RouteGroupBuilder grup)
    {
        // Çağrı AÇMA kartın detayından da yapılabilir; buradaki uç panodan tek
        //   tıkla çağırmak için: mavi kodda kart açıp satır eklemek, ölçtüğümüz
        //   sürenin kendisini uzatır.
        grup.MapPost("/basvuru/{id:long}/cagri", async (
            long id, CagriIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.pano", Islem.Ekle);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var cagriId = await baglanti.TekDegerAsync<long>("""
                insert into public.acil_cagri
                    (basvuru_id, sube_id, tur, hedef_bolum_id, hedef_kisi_id,
                     cagri_zamani, durum, not_metni, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, (now())::timestamp, 0, @p5, @p6)
                returning id
                """, islem,
                [id, baglam.SubeId ?? 0, istek.Tur, istek.HedefBolumId,
                 istek.HedefKisiId, istek.NotMetni ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloCagri, cagriId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { basvuruId = id, tur = istek.Tur }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { cagriId, izlemeNo = baglam.IzlemeNo });
        });

        // YANIT / KAPANIŞ / YANIT YOK tek uçta: üçü de aynı satırın durumunu
        //   ilerletiyor ve aynı sırayı ("yanıt kapanıştan önce gelir")
        //   korumak zorunda.
        grup.MapPost("/cagri/{id:long}/yanit", async (
            long id, CagriYanitIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("acil.pano", Islem.Degistir);

            if (istek.Durum is not (1 or 2 or 3))
                throw GentegreHatasi.Dogrulama("Çağrı durumu 1, 2 ya da 3 olmalı.",
                    new AlanHatasi("durum", "Çağrı durumu 1, 2 ya da 3 olmalı."));

            await using var baglanti = await veri.AcAsync(iptal);

            var c = await baglanti.TekAsync("""
                select c.durum, c.yanit_zamani as "yanitZamani",
                       c.kapanis_zamani as "kapanisZamani"
                  from public.acil_cagri c where c.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çağrı bulunamadı.");

            if (c["kapanisZamani"] is not null)
                throw GentegreHatasi.IsKurali("Bu çağrı zaten kapatılmış.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // YANIT ZAMANI BİR KEZ (coalesce): "çağırdık - geldi" farkı ilk
            //   yanıtın ölçüsüdür; kapanışta yeniden yazılsaydı bekleme süresi
            //   her çağrıda sıfıra yakın görünürdü.
            // TEKRAR ÇAĞRI (3) sayacı artırır - kaç kez çağrıldığı, ne kadar
            //   beklendiği kadar anlamlı.
            await baglanti.CalistirAsync("""
                update public.acil_cagri
                   set durum = @p1,
                       yanit_zamani = case when @p1 in (1, 2)
                                           then coalesce(yanit_zamani, (now())::timestamp)
                                           else yanit_zamani end,
                       kapanis_zamani = case when @p1 = 2 then (now())::timestamp
                                             else kapanis_zamani end,
                       yanitlayan_id = case when @p1 in (1, 2)
                                            then coalesce(yanitlayan_id, @p2)
                                            else yanitlayan_id end,
                       tekrar_sayi = case when @p1 = 3 then tekrar_sayi + 1 else tekrar_sayi end,
                       not_metni = coalesce(@p3, not_metni)
                 where id = @p0
                """, islem,
                [id, istek.Durum, istek.YanitlayanId ?? baglam.KullaniciId,
                 istek.NotMetni], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloCagri, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = istek.Durum }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var y = await baglanti.TekAsync("""
                select c.durum, c.tekrar_sayi as "tekrarSayi",
                       case when c.yanit_zamani is null then null
                            else round(extract(epoch from
                                 (c.yanit_zamani - c.cagri_zamani)) / 60)::int end as "yanitDk"
                  from public.acil_cagri c where c.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { cagri = y, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Yatağı başvuruya bağlar ya da boşaltır; iki tabloyu birlikte günceller.
    ///
    /// ESKİ YATAK TEMİZLİĞE DÜŞER, boşa değil: hasta kalkınca yatak hazır
    /// olmaz. DOLU YATAĞA İKİNCİ HASTA YAZILMAZ - pano en çok bu yüzden
    /// güvenilirliğini kaybeder.
    /// </summary>
    private static async Task YatakAtaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, long basvuruId,
        int? yeniYatakId, object? eskiYatakId, int kullaniciId, CancellationToken iptal)
    {
        if (yeniYatakId is > 0)
        {
            var dolu = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.acil_basvuru b
                 where b.yatak_id = @p0 and b.cikis_zamani is null and b.id <> @p1
                """, islem, [yeniYatakId, basvuruId], iptal);
            if (dolu > 0)
                throw GentegreHatasi.IsKurali("Bu yatakta başka bir hasta var.");
        }

        await baglanti.CalistirAsync("""
            update public.acil_basvuru
               set yatak_id = @p1, degistiren = @p2, degistirme_tarihi = (now())::timestamp
             where id = @p0
            """, islem, [basvuruId, yeniYatakId, kullaniciId], iptal);

        if (eskiYatakId is not null && !Equals(Convert.ToInt32(eskiYatakId), yeniYatakId))
            await baglanti.CalistirAsync("""
                update public.acil_yatak set durum = 2, degistiren = @p1,
                       degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [eskiYatakId, kullaniciId], iptal);

        if (yeniYatakId is > 0)
            await baglanti.CalistirAsync("""
                update public.acil_yatak set durum = 1, degistiren = @p1,
                       degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [yeniYatakId, kullaniciId], iptal);
    }
}
