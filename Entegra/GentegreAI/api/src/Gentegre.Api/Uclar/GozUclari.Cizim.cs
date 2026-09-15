using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ ŞEMASI — ÇİZİM (705), mockup <c>Ekranlar/Goz/goz_semasi.html</c>.
///
/// <para><b>Çizim ölçüm değildir.</b> C/D oranı, GİB, görme yine kendi
/// tablolarına yazılır; şema onların yerini almaz, <i>yerini</i> gösterir.
/// "Saat 11'de kanama" cümlesi, aynı hastayı altı ay sonra gören ikinci hekim
/// için ancak şemayla birlikte anlam taşır.</para>
///
/// <para><b>İşaret ayrı satırdır.</b> Çizimi tek bir SVG metni olarak saklamak
/// kolay olurdu ama o zaman "periferik yırtığı olan hastalar" sorusu resimden
/// cevaplanamazdı. SVG sunumdur; aranabilir olan
/// <c>goz_cizim_isaret</c> satırlarıdır.</para>
///
/// <para><b>Saat ve metin SUNUCUDA hesaplanır.</b> Ekran tıklanan noktayı
/// (0–1 arası oran) gönderir; saat kadranı ve üretilen cümle burada üretilir.
/// İki ekran (kart, yazdırma) aynı çizimden farklı cümle üretmesin diye kural
/// tek yerde durur — ve OD saat yönünde, OS ters numaralanır: sağ/sol
/// karışması çizimin kendisinde engellenmeli.</para>
///
/// <para><b>Üretilen metin öneridir.</b> Hekim onaylamadan hiçbir bulgu alanına
/// geçmez; yazma işi ortak <c>/muayene/{id}/bulgu-metni</c> ucundan yürür —
/// dikte ile aynı kural, aynı kapı.</para>
/// </summary>
public static partial class GozUclari
{
    /// <summary>Çizim logu muayene kaydına düşer: çizim muayenenin parçasıdır.</summary>
    private const int LogTabloCizim = 955;

    /// <summary>Şema türü: 1 ön segment · 2 fundus · 3 periferi · 4 kapak.</summary>
    private static readonly string[] SemaAdlari =
        ["", "Ön segment", "Fundus", "Periferi", "Kapak / adneks"];

    /// <summary>
    /// DAMGA PALETİ SUNUCUDAN GELİR: hangi işaret hangi şemada kullanılır,
    /// hangi renkle çizilir ve cümlede nasıl okunur — üçü aynı yerde durmalı.
    /// Paleti ekrana gömmek, yeni bir işaret türü için iki dosya (ve iki
    /// dağıtım) demekti.
    /// </summary>
    private sealed record DamgaTanimi(
        int Tur, string Ad, string Simge, string Renk, int[] Semalar, string Cumle);

    private static readonly DamgaTanimi[] Damgalar =
    [
        new(1,  "Retina kanaması",     "●", "#b3261e", [2, 3], "nokta retina kanaması"),
        new(2,  "Sert eksuda",         "▲", "#8a6218", [2, 3], "sert eksuda"),
        new(3,  "Yumuşak eksuda (CWS)","☁", "#6b7a8b", [2, 3], "yumuşak eksuda"),
        new(4,  "Drusen",              "•", "#d9a12b", [2],    "drusen"),
        new(5,  "Mikroanevrizma",      "◍", "#2e7d46", [2, 3], "mikroanevrizma"),
        new(6,  "Laser spotu",         "✳", "#6a3fb5", [2, 3], "laser spotu"),
        new(7,  "Yırtık / delik",      "⌇", "#b3261e", [2, 3], "retina yırtığı"),
        new(8,  "Dekolman alanı",      "▨", "#2f6db3", [2, 3], "dekolman alanı"),
        new(9,  "Disk kanaması",       "◔", "#b3261e", [2],    "disk kanaması"),
        new(10, "PPA (beta)",          "◌", "#8a6218", [2],    "beta PPA"),
        new(11, "Pterjiyum",           "◣", "#b3261e", [1],    "pterjiyum"),
        new(12, "Kornea lekesi",       "◆", "#6b7a8b", [1],    "kornea lekesi"),
        new(13, "Kornea boyanması",    "⁙", "#2e7d46", [1],    "fluoresein boyanması"),
        new(14, "Katarakt",            "◎", "#8a6218", [1],    "lens opasitesi"),
        new(15, "Sineşi",              "⌒", "#6a3fb5", [1],    "sineşi"),
        new(16, "Serbest çizim",       "✎", "#1f2d3a", [1, 2, 3, 4], "işaretli alan"),
    ];

    /// <summary>Kaydetme isteği: bir gözün bir şeması, işaretleriyle birlikte.</summary>
    public sealed record CizimIstegi(
        int Goz, int SemaTuru, string? Svg, string? Aciklama, CizimIsaretIstegi[]? Isaretler);

    public sealed record CizimIsaretIstegi(
        int Sekil, int Tur, decimal? X, decimal? Y, decimal? BoyutDd,
        string? Renk, string? Yol, string? Aciklama);

    private static void CizimUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------ çizimleri oku ----
        grup.MapGet("/muayene/{id:int}/cizim", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var m = await baglanti.TekAsync("""
                select gm.hasta_id, t.unvan, (mu.tamamlanma is not null) as kapali,
                       gm.dilate, mu.muayene_tarihi
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                  join public.taraf t on t.id = gm.hasta_id
                 where gm.id = @p0
                """, null, [id], o => new
            {
                hastaId = o.GetInt32(0),
                hasta = o.GetString(1),
                kapali = o.GetBoolean(2),
                dilate = o.GetInt16(3) == 1,
                tarih = o.GetDateTime(4),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            var cizimler = await baglanti.ListeAsync("""
                select c.id, c.goz, c.sema_turu, c.surum, c.kilitli, c.svg,
                       c.uretilen_metin, c.aciklama,
                       coalesce(c.degistirme_tarihi, c.ekleme_tarihi) as zaman,
                       coalesce(t.unvan, '') as kullanici
                  from public.goz_cizim c
                  left join public.taraf t on t.id = c.ekleyen
                 where c.goz_muayene_id = @p0
                 order by c.goz, c.sema_turu, c.surum desc
                """, null, [id], o => new
            {
                id = o.GetInt64(0),
                goz = (int)o.GetInt16(1),
                semaTuru = (int)o.GetInt16(2),
                surum = o.GetInt32(3),
                kilitli = o.GetInt16(4) == 1,
                svg = o.GetString(5),
                uretilenMetin = o.GetString(6),
                aciklama = o.GetString(7),
                zaman = o.GetDateTime(8),
                kullanici = o.GetString(9),
            }, iptal);

            var isaretler = await baglanti.ListeAsync("""
                select i.id, i.cizim_id, i.sekil, i.tur, i.x, i.y, i.saat,
                       i.boyut_dd, i.renk, i.yol, i.aciklama, i.sira
                  from public.goz_cizim_isaret i
                  join public.goz_cizim c on c.id = i.cizim_id
                 where c.goz_muayene_id = @p0
                 order by i.cizim_id, i.sira, i.id
                """, null, [id], o => new
            {
                id = o.GetInt64(0),
                cizimId = o.GetInt64(1),
                sekil = (int)o.GetInt16(2),
                tur = (int)o.GetInt16(3),
                x = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                y = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                saat = o.IsDBNull(6) ? (int?)null : o.GetInt16(6),
                boyutDd = o.IsDBNull(7) ? (decimal?)null : o.GetDecimal(7),
                renk = o.GetString(8),
                yol = o.GetString(9),
                aciklama = o.GetString(10),
                sira = o.GetInt32(11),
            }, iptal);

            // GÜNCEL SÜRÜM ile GEÇMİŞ ayrı döner: ekran güncelini çizer,
            //   geçmişi liste olarak gösterir. Tek liste verip "en büyük
            //   sürümü sen bul" demek, aynı kuralı iki yere yazmak olurdu.
            var guncel = cizimler
                .GroupBy(c => (c.goz, c.semaTuru))
                .Select(g => g.First())
                .Select(c => new
                {
                    c.id, c.goz, c.semaTuru, c.surum, c.kilitli, c.svg,
                    c.uretilenMetin, c.aciklama, c.zaman, c.kullanici,
                    isaretler = isaretler.Where(i => i.cizimId == c.id).ToArray(),
                })
                .ToArray();

            return Results.Ok(new
            {
                muayeneKapali = m.kapali,
                m.hasta, m.hastaId, m.dilate, m.tarih,
                semalar = guncel,
                gecmis = cizimler.Select(c => new
                    { c.id, c.goz, c.semaTuru, c.surum, c.kilitli, c.zaman, c.kullanici }),
                // Palet ve şema adları sunucudan: ekran ne çizeceğini
                //   uydurmaz, verileni çizer.
                damgalar = Damgalar.Select(d => new
                    { d.Tur, d.Ad, d.Simge, d.Renk, d.Semalar }),
                semaAdlari = SemaAdlari.Select((a, i) => new { tur = i, ad = a })
                                       .Where(x => x.tur > 0),
                hedefler = BulguHedefleri.Select(h => new { h.Kod, h.Ad, h.GozGerekir }),
            });
        });

        // --------------------------------------------------- çizimi kaydet ----
        grup.MapPost("/muayene/{id:int}/cizim", async (
            int id, CizimIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);

            if (istek.Goz is not (1 or 2))
                throw GentegreHatasi.Dogrulama("Çizim tek göz için kaydedilir (OD ya da OS).");
            if (istek.SemaTuru < 1 || istek.SemaTuru >= SemaAdlari.Length)
                throw GentegreHatasi.Dogrulama("Bilinmeyen şema türü.");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var kapali = await baglanti.TekDegerAsync<bool>("""
                select (mu.tamamlanma is not null)
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, islem, [id], iptal);

            // TAMAMLANMIŞ MUAYENENİN ÇİZİMİ DEĞİŞMEZ: ona dayanan rapor,
            //   epikriz ve reçeteyle tutarsızlığa düşmesin. Düzeltme yeni
            //   muayenede, "önceki çizimden başla" ile yapılır.
            if (kapali)
                throw GentegreHatasi.IsKurali("Muayene tamamlanmış; çizim değiştirilemez.");

            var isaretler = istek.Isaretler ?? [];
            var metin = UretilenMetin(istek.Goz, istek.SemaTuru, isaretler);

            // Açık (kilitlenmemiş) sürüm varsa ÜZERİNE yazılır: her kaydetme
            //   yeni sürüm açsaydı, bir muayenede otuz sürüm birikirdi.
            var cizimId = await baglanti.TekDegerAsync<long?>("""
                select id from public.goz_cizim
                 where goz_muayene_id = @p0 and goz = @p1 and sema_turu = @p2
                   and kilitli = 0
                 order by surum desc limit 1
                """, islem, [id, istek.Goz, istek.SemaTuru], iptal);

            if (cizimId is null)
            {
                cizimId = await baglanti.TekDegerAsync<long>("""
                    insert into public.goz_cizim
                        (goz_muayene_id, goz, sema_turu, surum, svg, uretilen_metin,
                         aciklama, sube_id, ekleyen)
                    values (@p0, @p1, @p2,
                            coalesce((select max(surum) + 1 from public.goz_cizim
                                       where goz_muayene_id = @p0 and goz = @p1
                                         and sema_turu = @p2), 1),
                            @p3, @p4, @p5, @p6, @p7)
                    returning id
                    """, islem,
                    [id, istek.Goz, istek.SemaTuru, istek.Svg ?? "", metin,
                     istek.Aciklama ?? "", baglam.SubeId, baglam.KullaniciId], iptal);
            }
            else
            {
                await baglanti.CalistirAsync("""
                    update public.goz_cizim
                       set svg = @p1, uretilen_metin = @p2, aciklama = @p3,
                           degistiren = @p4, degistirme_tarihi = now()
                     where id = @p0
                    """, islem,
                    [cizimId.Value, istek.Svg ?? "", metin, istek.Aciklama ?? "",
                     baglam.KullaniciId], iptal);

                // İşaretler TOPTAN yenilenir: çizim bir bütündür, satır satır
                //   fark almak (hangi işaret taşındı, hangisi silindi) hem
                //   karmaşık hem de kullanıcının gördüğüyle aynı şey değil.
                await baglanti.CalistirAsync(
                    "delete from public.goz_cizim_isaret where cizim_id = @p0",
                    islem, [cizimId.Value], iptal);
            }

            var sira = 0;
            foreach (var i in isaretler)
            {
                var saat = SaatHesapla(istek.Goz, i.X, i.Y);
                await baglanti.CalistirAsync("""
                    insert into public.goz_cizim_isaret
                        (cizim_id, sekil, tur, x, y, saat, boyut_dd, renk, yol,
                         aciklama, sira, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                    """, islem,
                    [cizimId.Value, i.Sekil <= 0 ? 1 : i.Sekil, i.Tur,
                     i.X, i.Y, saat, i.BoyutDd, i.Renk ?? "", i.Yol ?? "",
                     i.Aciklama ?? "", sira++, baglam.KullaniciId], iptal);
            }

            await islem.CommitAsync(iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloCizim, (int)cizimId.Value,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    durum = "Göz şeması kaydedildi",
                    sema = SemaAdlari[istek.SemaTuru],
                    goz = istek.Goz == 1 ? "OD" : "OS",
                    isaret = isaretler.Length,
                }, iptal: iptal);

            return Results.Ok(new
            {
                cizimId = cizimId.Value,
                isaret = isaretler.Length,
                uretilenMetin = metin,
            });
        });

        // ------------------------------------------ önceki çizimden başla ----
        grup.MapPost("/muayene/{id:int}/cizim/onceki-kopyala", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var bu = await baglanti.TekAsync("""
                select gm.hasta_id, mu.muayene_tarihi, (mu.tamamlanma is not null)
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, islem, [id], o => new
            {
                hastaId = o.GetInt32(0),
                tarih = o.GetDateTime(1),
                kapali = o.GetBoolean(2),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            if (bu.kapali)
                throw GentegreHatasi.IsKurali("Muayene tamamlanmış; çizim değiştirilemez.");

            var onceki = await baglanti.TekDegerAsync<int?>("""
                select gm.id
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.hasta_id = @p0 and gm.id <> @p1 and mu.muayene_tarihi < @p2
                   and exists (select 1 from public.goz_cizim c where c.goz_muayene_id = gm.id)
                 order by mu.muayene_tarihi desc
                 limit 1
                """, islem, [bu.hastaId, id, bu.tarih], iptal);

            if (onceki is null)
                throw GentegreHatasi.IsKurali("Bu hastanın çizimli önceki muayenesi yok.");

            // ZATEN ÇİZİM OLAN ŞEMA ATLANIR: bugün çizilmiş bir şemayı eski
            //   çizimle ezmek, hekimin yaptığı işi silmektir.
            var kopyalanan = await baglanti.TekDegerAsync<int>("""
                with kaynak as (
                    select distinct on (c.goz, c.sema_turu)
                           c.id, c.goz, c.sema_turu, c.svg, c.uretilen_metin
                      from public.goz_cizim c
                     where c.goz_muayene_id = @p1
                     order by c.goz, c.sema_turu, c.surum desc
                ),
                yeni as (
                    insert into public.goz_cizim
                        (goz_muayene_id, goz, sema_turu, surum, svg, uretilen_metin,
                         aciklama, sube_id, ekleyen)
                    select @p0, k.goz, k.sema_turu, 1, k.svg, k.uretilen_metin,
                           'Önceki muayeneden kopyalandı', @p2, @p3
                      from kaynak k
                     where not exists (select 1 from public.goz_cizim v
                                        where v.goz_muayene_id = @p0
                                          and v.goz = k.goz and v.sema_turu = k.sema_turu)
                    returning id, goz, sema_turu
                ),
                isaret as (
                    insert into public.goz_cizim_isaret
                        (cizim_id, sekil, tur, x, y, saat, boyut_dd, renk, yol,
                         aciklama, sira, ekleyen)
                    select y.id, i.sekil, i.tur, i.x, i.y, i.saat, i.boyut_dd,
                           i.renk, i.yol, i.aciklama, i.sira, @p3
                      from yeni y
                      join kaynak k on k.goz = y.goz and k.sema_turu = y.sema_turu
                      join public.goz_cizim_isaret i on i.cizim_id = k.id
                    returning 1
                )
                select (select count(*) from yeni)::int
                """, islem, [id, onceki.Value, baglam.SubeId, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                id,
                oncekiId = onceki.Value,
                kopyalanan,
                aciklama = kopyalanan == 0
                    ? "Bu muayenede zaten çizim var; eski çizim üzerine yazılmadı."
                    : $"{kopyalanan} şema önceki muayeneden getirildi; "
                      + "bugünkü bulguya göre düzeltilmeli.",
            });
        });
    }

    /// <summary>
    /// SAAT KADRANI konumdan hesaplanır. OD'de saat yönünde, OS'de ters
    /// numaralanır — fundus görüntüsünde nazal taraf iki gözde karşılıklıdır;
    /// aynı numarayı kullanmak sağ/sol karışmasının en sessiz yoludur.
    /// </summary>
    private static short? SaatHesapla(int goz, decimal? x, decimal? y)
    {
        if (x is null || y is null) return null;
        var dx = (double)x.Value - 0.5;
        var dy = 0.5 - (double)y.Value;                 // SVG'de y aşağı büyür
        if (Math.Abs(dx) < 0.02 && Math.Abs(dy) < 0.02) return null;  // merkez

        var aci = Math.Atan2(dx, dy) * 180 / Math.PI;   // 12 yönü 0°
        if (aci < 0) aci += 360;
        if (goz == 2) aci = 360 - aci;                  // OS aynadır
        var saat = (int)Math.Round(aci / 30);
        if (saat is 0 or 12) return 12;
        return (short)saat;
    }

    /// <summary>
    /// ÇİZİMDEN CÜMLE. Aynı türden işaretler tek cümlede toplanır ("saat 11 ve
    /// 7 hizasında nokta retina kanaması") - her işarete ayrı cümle yazmak,
    /// epikrizde okunmayan bir liste üretirdi. Metin ÖNERİDİR: tanı koymaz,
    /// yalnız çizileni okur.
    /// </summary>
    private static string UretilenMetin(int goz, int semaTuru, CizimIsaretIstegi[] isaretler)
    {
        if (isaretler.Length == 0) return "";

        var cumleler = new List<string>();
        foreach (var kume in isaretler.GroupBy(i => i.Tur).OrderBy(g => g.Key))
        {
            var tanim = Damgalar.FirstOrDefault(d => d.Tur == kume.Key);
            if (tanim is null) continue;

            var saatler = kume.Select(i => SaatHesapla(goz, i.X, i.Y))
                              .Where(s => s is not null)
                              .Select(s => s!.Value)
                              .Distinct()
                              .OrderBy(s => s)
                              .ToArray();

            var metin = new StringBuilder();
            if (saatler.Length > 0)
            {
                metin.Append("Saat ");
                metin.Append(string.Join(", ", saatler.Take(saatler.Length - 1)));
                if (saatler.Length > 1) metin.Append(" ve ");
                metin.Append(saatler[^1]);
                metin.Append(" hizasında ");
            }
            else
            {
                metin.Append("Merkezi alanda ");
            }

            metin.Append(tanim.Cumle);
            if (kume.Count() > saatler.Length && saatler.Length > 0)
                metin.Append(" (birden çok odak)");
            cumleler.Add(metin.ToString() + ".");
        }

        var bas = SemaAdlari[semaTuru];
        return cumleler.Count == 0 ? "" : $"{bas}: " + string.Join(" ", cumleler);
    }
}
