using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KİŞİSEL HATIRLATICI (1139, mockup Ekranlar/Kullanici/kisisel_hatirlatici.html, kullanıcı 22.10.2026
/// "mockup'a göre yap"). Kayıt kişiye özel: sahibi ve paylaştıkları görür - yetki kodu yok, her uç
/// görünürlüğü kendisi süzer (<see cref="Gorunur"/>). Başkasına iş vermek Görev'dir.
///
///  · <c>GET    /api/hatirlatma?cip=&amp;ara=</c>   Hatırlatmalarım listesi (açık / gecikmiş / bugün / bu hafta /
///    tekrarlayan / benimle paylaşılan / tamamlanan / tümü).
///  · <c>GET    /api/hatirlatma/ozet</c>          sayaç kartları.
///  · <c>GET    /api/hatirlatma/zil</c>           zil paneli + açılır uyarı: gecikmiş, bugün, yarın.
///  · <c>GET    /api/hatirlatma/takvim?ay=</c>    ayın günlerinde açık hatırlatma sayısı.
///  · <c>GET    /api/hatirlatma/kayit?kaynak=&amp;id=</c>  kartın "⏰ N" rozeti: o kayda bağlı açıklarım.
///  · <c>GET/POST/PUT/DELETE /api/hatirlatma/{id}</c>  kart.
///  · <c>POST   /api/hatirlatma/{id}/tamamla · /ertele · /ac · /kopyala</c>.
///  · <c>GET    /api/hatirlatma/kisiler?ara= · /birimler</c>  paylaşım seçimi.
///
/// Zaman istemciyle ŞUBE YEREL "yyyy-MM-ddTHH:mm" metniyle konuşur, UTC saklanır (1097).
/// </summary>
public static class HatirlatmaUclari
{
    public sealed record HatirlatmaYazma(
        string? Baslik, string? Notu, string? Zaman, int? UyarDk, short? Oncelik, short? Renk, string? Etiket,
        short? Tekrar, short? TekrarAralik, short? TekrarGunler, string? TekrarBitis,
        bool? KanalUygulama, bool? KanalSms, bool? KanalEposta,
        string? Kaynak, int? KaynakId, string? KaynakAd,
        short? Paylasim, int? PaylasimDepartmanId, bool? HerkesKapatir, bool? PaylasilanDuzenler, int[]? Paylasilanlar);
    public sealed record ErteleIstegi(int? Dakika, string? Zaman);

    /// <summary>Kullanıcı @u bu satırı görür mü (sahip · seçilen kişi · birim).</summary>
    private const string Gorunur = """
        (h.sahip_id = @u
         or (h.paylasim = 1 and exists (select 1 from public.hatirlatma_paylasim p where p.hatirlatma_id = h.id and p.kullanici_id = @u))
         or (h.paylasim = 2 and h.paylasim_departman_id = (select t.departman from public.taraf t where t.id = @u)))
        """;
    /// <summary>@u için hâlâ açık mı (kendi işaretini koymadıysa; herkes kapatır ise satır durumu).</summary>
    private const string AcikBenim = """
        (h.durum = 1 and case when h.sahip_id = @u then h.sahip_tamam is null
                              when h.herkes_kapatir = 1 then true
                              else not exists (select 1 from public.hatirlatma_paylasim p
                                                where p.hatirlatma_id = h.id and p.kullanici_id = @u and p.tamamlandi is not null) end)
        """;

    private const string Kolonlar = """
        h.id, h.baslik, h.notu, h.zaman, h.uyar_dk, h.oncelik, h.renk, h.etiket, h.tekrar, h.tekrar_aralik,
        h.tekrar_gunler, h.tekrar_bitis, h.kanal_uygulama, h.kanal_sms, h.kanal_eposta, h.kaynak, h.kaynak_id,
        h.kaynak_ad, h.sahip_id, coalesce(public.fn_taraf_ad(st.unvan, st.ad, st.soyad)::varchar(120), ''),
        {ACIK} as acik, h.tamamlanma, h.ertele_sayisi, h.paylasim
        """;

    private static string Sql(string s) => s.Replace("{GORUNUR}", Gorunur).Replace("{ACIK}", AcikBenim)
        .Replace("{KOLONLAR}", Kolonlar.Replace("{ACIK}", AcikBenim)).Replace("@u", "@p0");

    private static readonly string[] GunAdlari = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"];
    private static readonly string[] GunTamAdlari = ["pazartesi", "salı", "çarşamba", "perşembe", "cuma", "cumartesi", "pazar"];

    /// <summary>"her cuma", "her gün, 31.10'a kadar", "ayın 22. günü" - listede ve kartta aynı metin.</summary>
    public static string TekrarMetni(short tekrar, short aralik, short gunler, DateTime? bitis, DateTime yerel)
    {
        var a = Math.Max((short)1, aralik);
        var m = tekrar switch
        {
            1 => a == 1 ? "her gün" : $"{a} günde bir",
            2 when gunler == 0 => a == 1 ? $"her {GunTamAdlari[((int)yerel.DayOfWeek + 6) % 7]}" : $"{a} haftada bir",
            // Tek gün seçiliyse tam adı ("her cuma"), birden çoksa kısaltmalar ("her Pt, Ça, Cu").
            2 when (gunler & (gunler - 1)) == 0 => $"her {GunTamAdlari[System.Numerics.BitOperations.TrailingZeroCount(gunler)]}",
            2 => "her " + string.Join(", ", Enumerable.Range(0, 7).Where(i => (gunler & (1 << i)) != 0).Select(i => GunAdlari[i])),
            3 => a == 1 ? $"her ay {yerel.Day}." : $"{a} ayda bir, {yerel.Day}.",
            4 => a == 1 ? $"her yıl {yerel:dd.MM}" : $"{a} yılda bir",
            5 => "iş günleri",
            _ => "",
        };
        return m.Length > 0 && bitis is { } b ? $"{m}, {b:dd.MM}'a kadar" : m;
    }

    /// <summary>
    /// TEKRARIN SONRAKİ ZAMANI (yerel saatle): şimdiden sonraki ilk uygun an - kaçırılmış tekrarlar
    /// atlanır (bir hafta açılmayan "her gün" yedi kez sormaz). Bitiş geçildiyse null.
    /// </summary>
    public static DateTime? Sonraki(DateTime yerel, short tekrar, short aralik, short gunler, DateTime? bitis, DateTime simdi)
    {
        if (tekrar == 0) return null;
        var a = Math.Max(1, (int)aralik);
        var z = yerel;
        for (var i = 0; i < 5000; i++)
        {
            z = tekrar switch
            {
                1 => z.AddDays(a),
                2 when gunler != 0 => z.AddDays(1),
                2 => z.AddDays(7 * a),
                3 => z.AddMonths(a),
                4 => z.AddYears(a),
                5 => z.AddDays(1),
                _ => z.AddDays(1),
            };
            var gi = ((int)z.DayOfWeek + 6) % 7;   // 0 Pt .. 6 Pz
            if (tekrar == 2 && gunler != 0 && (gunler & (1 << gi)) == 0) continue;
            if (tekrar == 5 && gi >= 5) continue;
            if (z <= simdi) continue;
            if (bitis is { } b && z.Date > b.Date) return null;
            return z;
        }
        return null;
    }

    private static DateTime YerelOku(string? s, string alan)
    {
        if (string.IsNullOrWhiteSpace(s)
            || !DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var d))
            throw GentegreHatasi.Dogrulama("Tarih ve saat gerekli.", new AlanHatasi(alan, "Geçersiz tarih / saat."));
        return DateTime.SpecifyKind(d, DateTimeKind.Unspecified);
    }

    private static object Satir(NpgsqlDataReader r, int ben, string dilim)
    {
        var utc = r.GetFieldValue<DateTimeOffset>(3).UtcDateTime;
        var yerel = Saat.Yerel(utc, dilim);
        var tekrar = r.GetInt16(8);
        var bitis = r.IsDBNull(11) ? (DateTime?)null : r.GetDateTime(11);
        var acik = r.GetBoolean(20);
        return new
        {
            id = r.GetInt32(0), baslik = r.GetString(1), notu = r.GetString(2),
            zaman = r.GetFieldValue<DateTimeOffset>(3), zamanYerel = yerel.ToString("yyyy-MM-dd'T'HH:mm", CultureInfo.InvariantCulture),
            uyarDk = r.GetInt32(4), uyariZamani = r.GetFieldValue<DateTimeOffset>(3).AddMinutes(-r.GetInt32(4)),
            oncelik = r.GetInt16(5), renk = r.GetInt16(6), etiket = r.GetString(7),
            tekrar, tekrarAralik = r.GetInt16(9), tekrarGunler = r.GetInt16(10),
            tekrarBitis = bitis?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
            tekrarMetni = TekrarMetni(tekrar, r.GetInt16(9), r.GetInt16(10), bitis, yerel),
            kanalUygulama = r.GetInt16(12) == 1, kanalSms = r.GetInt16(13) == 1, kanalEposta = r.GetInt16(14) == 1,
            kaynak = r.GetString(15), kaynakId = r.IsDBNull(16) ? (int?)null : r.GetInt32(16), kaynakAd = r.GetString(17),
            sahipId = r.GetInt32(18), sahip = r.GetString(19), benim = r.GetInt32(18) == ben,
            acik, tamamlanma = r.IsDBNull(21) ? (DateTimeOffset?)null : r.GetFieldValue<DateTimeOffset>(21),
            erteleSayisi = r.GetInt16(22), paylasim = r.GetInt16(23),
            gecikmis = acik && utc < DateTime.UtcNow,
        };
    }

    public static void HatirlatmaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/hatirlatma").WithTags("Hatırlatmalarım").RequireAuthorization();

        // ------------------------------------------------------------ liste --
        grup.MapGet("/", async (string? cip, string? ara, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var kosul = (cip ?? "acik") switch
            {
                "gec" => "{ACIK} and h.zaman < now()",
                "bugun" => "{ACIK} and h.zaman::date = current_date",
                "hafta" => "{ACIK} and h.zaman::date between current_date and current_date + (7 - extract(isodow from current_date))::int",
                "tekrar" => "{ACIK} and h.tekrar > 0",
                "paylasilan" => "h.sahip_id <> @u and {ACIK}",
                "tam" => "not {ACIK}",
                "hep" => "true",
                _ => "{ACIK}",
            };
            var sira = cip == "tam" ? "coalesce(h.tamamlanma, h.zaman) desc" : "h.zaman";
            await using var bg = await veri.AcAsync(iptal);
            var satirlar = await bg.ListeAsync(Sql($$"""
                select {KOLONLAR}
                  from public.hatirlatma h
                  left join public.taraf st on st.id = h.sahip_id
                 where {GORUNUR} and {{kosul}}
                   and (@p1 = '' or h.baslik ilike '%' || @p1 || '%' or h.notu ilike '%' || @p1 || '%'
                        or h.kaynak_ad ilike '%' || @p1 || '%' or h.etiket ilike '%' || @p1 || '%')
                 order by {{sira}}
                 limit 500
                """), null, [b.KullaniciId, (ara ?? "").Trim()], r => Satir(r, b.KullaniciId, b.ZamanDilimi), iptal);
            return Results.Ok(satirlar);
        });

        grup.MapGet("/ozet", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var o = await veri.TekAsync(Sql("""
                select count(*) filter (where {ACIK} and h.zaman < now())::int,
                       count(*) filter (where {ACIK} and h.zaman::date = current_date)::int,
                       count(*) filter (where {ACIK} and h.zaman::date between current_date
                                          and current_date + (7 - extract(isodow from current_date))::int)::int,
                       count(*) filter (where {ACIK} and h.tekrar > 0)::int,
                       count(*) filter (where {ACIK})::int,
                       (select count(*) from public.hatirlatma_hareket x
                         where x.kullanici_id = @u and x.olay = 5 and x.zaman >= date_trunc('month', now()))::int
                  from public.hatirlatma h
                 where {GORUNUR}
                """), [b.KullaniciId], r => new
                {
                    gecikmis = r.GetInt32(0), bugun = r.GetInt32(1), hafta = r.GetInt32(2), tekrar = r.GetInt32(3),
                    acik = r.GetInt32(4), tamamAy = r.GetInt32(5),
                }, iptal);
            return Results.Ok(o);
        });

        // Zil paneli ve açılır uyarı: gecikmiş + bugün + yarın (kısa liste, ikinci istek yok).
        grup.MapGet("/zil", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            var satirlar = await bg.ListeAsync(Sql("""
                select {KOLONLAR}
                  from public.hatirlatma h
                  left join public.taraf st on st.id = h.sahip_id
                 where {GORUNUR} and {ACIK} and h.zaman::date <= current_date + 1
                 order by h.zaman
                 limit 50
                """), null, [b.KullaniciId], r => Satir(r, b.KullaniciId, b.ZamanDilimi), iptal);
            return Results.Ok(satirlar);
        });

        grup.MapGet("/takvim", async (string? ay, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var bas = DateTime.TryParseExact((ay ?? "") + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d)
                ? d : new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            await using var bg = await veri.AcAsync(iptal);
            var gunler = await bg.ListeAsync(Sql("""
                select extract(day from h.zaman)::int, count(*)::int, count(*) filter (where h.zaman < now())::int
                  from public.hatirlatma h
                 where {GORUNUR} and {ACIK} and h.zaman::date >= @p1 and h.zaman::date < @p2
                 group by 1
                """), null, [b.KullaniciId, bas, bas.AddMonths(1)],
                r => new { gun = r.GetInt32(0), adet = r.GetInt32(1), gecikmis = r.GetInt32(2) }, iptal);
            return Results.Ok(gunler);
        });

        grup.MapGet("/kayit", async (string kaynak, int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            var satirlar = await bg.ListeAsync(Sql("""
                select {KOLONLAR}
                  from public.hatirlatma h
                  left join public.taraf st on st.id = h.sahip_id
                 where {GORUNUR} and {ACIK} and h.kaynak = @p1 and h.kaynak_id = @p2
                 order by h.zaman
                 limit 50
                """), null, [b.KullaniciId, kaynak ?? "", id], r => Satir(r, b.KullaniciId, b.ZamanDilimi), iptal);
            return Results.Ok(satirlar);
        });

        // --------------------------------------------------------- paylaşım --
        grup.MapGet("/kisiler", async (string? ara, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(await veri.ListeAsync("""
                select tk.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), tk.kod)
                  from public.taraf_kullanici tk
                  join public.taraf t on t.id = tk.id
                 where tk.aktif = 1 and tk.id <> @p0
                   and (@p1 = '' or public.fn_taraf_ad(t.unvan, t.ad, t.soyad) ilike '%' || @p1 || '%' or tk.kod ilike @p1 || '%')
                 order by 2
                 limit 20
                """, [b.KullaniciId, (ara ?? "").Trim()], r => new { id = r.GetInt32(0), ad = r.GetString(1) }, iptal));
        });

        grup.MapGet("/birimler", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            return Results.Ok(await veri.ListeAsync("""
                select d.id, d.ad from public.departman d where d.durum = 1 order by d.ad
                """, [], r => new { id = r.GetInt32(0), ad = r.GetString(1) }, iptal));
        });

        // ------------------------------------------------------------- kart --
        grup.MapGet("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            var satir = (await bg.ListeAsync(Sql("""
                select {KOLONLAR}, h.paylasim_departman_id, h.herkes_kapatir, h.paylasilan_duzenler,
                       coalesce((select d.ad from public.departman d where d.id = h.paylasim_departman_id), '')
                  from public.hatirlatma h
                  left join public.taraf st on st.id = h.sahip_id
                 where h.id = @p1 and {GORUNUR}
                """), null, [b.KullaniciId, id], r => new
                {
                    satir = Satir(r, b.KullaniciId, b.ZamanDilimi),
                    paylasimDepartmanId = r.IsDBNull(24) ? (int?)null : r.GetInt32(24),
                    herkesKapatir = r.GetInt16(25) == 1, paylasilanDuzenler = r.GetInt16(26) == 1,
                    paylasimDepartman = r.GetString(27),
                }, iptal)).FirstOrDefault() ?? throw GentegreHatasi.Bulunamadi("Hatırlatma bulunamadı.");
            var paylasilanlar = await bg.ListeAsync("""
                select p.kullanici_id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), p.tamamlandi is not null
                  from public.hatirlatma_paylasim p left join public.taraf t on t.id = p.kullanici_id
                 where p.hatirlatma_id = @p0 order by 2
                """, null, [id], r => new { id = r.GetInt32(0), ad = r.GetString(1), tamam = r.GetBoolean(2) }, iptal);
            var hareketler = await bg.ListeAsync("""
                select x.zaman, x.olay, x.ayrinti, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
                  from public.hatirlatma_hareket x left join public.taraf t on t.id = x.kullanici_id
                 where x.hatirlatma_id = @p0 order by x.zaman desc, x.id desc limit 100
                """, null, [id], r => new
                {
                    zaman = r.GetFieldValue<DateTimeOffset>(0),
                    olay = r.GetInt16(1) switch
                    {
                        1 => "Oluşturuldu", 2 => "Değiştirildi", 3 => "Ertelendi", 4 => "Uyarı gönderildi",
                        5 => "Tamamlandı", 6 => "Yeniden açıldı", _ => "",
                    },
                    olayKod = r.GetInt16(1), ayrinti = r.GetString(2), kullanici = r.GetString(3),
                }, iptal);
            return Results.Ok(new
            {
                satir.satir, satir.paylasimDepartmanId, satir.herkesKapatir, satir.paylasilanDuzenler,
                satir.paylasimDepartman, paylasilanlar, hareketler,
            });
        });

        grup.MapPost("/", async (HatirlatmaYazma g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var v = Dogrula(g, b.ZamanDilimi);
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            var id = await bg.TekDegerAsync<int>("""
                insert into public.hatirlatma (sahip_id, baslik, notu, zaman, uyar_dk, oncelik, renk, etiket, tekrar, tekrar_aralik,
                       tekrar_gunler, tekrar_bitis, kanal_uygulama, kanal_sms, kanal_eposta, kaynak, kaynak_id, kaynak_ad,
                       paylasim, paylasim_departman_id, herkes_kapatir, paylasilan_duzenler, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14, @p15, @p16, @p17,
                        @p18, @p19, @p20, @p21, @p22, @p0)
                returning id
                """, islem, [b.KullaniciId, .. v.Parametreler, b.SubeId ?? 0], iptal);
            await PaylasilanlariYaz(bg, islem, id, v.Paylasim == 1 ? v.Paylasilanlar : [], b.KullaniciId, iptal);
            await Hareket(bg, islem, id, 1, v.KaynakAd.Length > 0 ? $"bağlı kayıt: {v.KaynakAd}" : "", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapPut("/{id:int}", async (int id, HatirlatmaYazma g, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var v = Dogrula(g, b.ZamanDilimi);
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            var eski = await Yetki(bg, islem, id, b.KullaniciId, duzenle: true, iptal);
            // Paylaşılan düzenleyebilir ama paylaşımı değiştiremez (sahibin kararı).
            var sahip = eski.SahipId == b.KullaniciId;
            await bg.CalistirAsync("""
                update public.hatirlatma set baslik = @p1, notu = @p2, zaman = @p3, uyar_dk = @p4, oncelik = @p5, renk = @p6,
                       etiket = @p7, tekrar = @p8, tekrar_aralik = @p9, tekrar_gunler = @p10, tekrar_bitis = @p11,
                       kanal_uygulama = @p12, kanal_sms = @p13, kanal_eposta = @p14, kaynak = @p15, kaynak_id = @p16, kaynak_ad = @p17,
                       paylasim = case when @p22 then @p18 else paylasim end,
                       paylasim_departman_id = case when @p22 then @p19 else paylasim_departman_id end,
                       herkes_kapatir = case when @p22 then @p20 else herkes_kapatir end,
                       paylasilan_duzenler = case when @p22 then @p21 else paylasilan_duzenler end,
                       -- zaman ya da uyarı süresi değiştiyse uyarı yeniden gider
                       uyari_gonderildi = case when zaman = @p3 and uyar_dk = @p4 then uyari_gonderildi end,
                       degistiren = @p23, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, .. v.Parametreler, sahip, b.KullaniciId], iptal);
            if (sahip) await PaylasilanlariYaz(bg, islem, id, v.Paylasim == 1 ? v.Paylasilanlar : [], b.KullaniciId, iptal);
            var degisen = new List<string>();
            if (eski.Baslik != v.Baslik) degisen.Add("başlık");
            if (eski.Zaman != v.ZamanUtc) degisen.Add($"zaman → {Saat.Yerel(v.ZamanUtc, b.ZamanDilimi):dd.MM.yyyy HH:mm}");
            if (eski.Notu != v.Notu) degisen.Add("not");
            await Hareket(bg, islem, id, 2, degisen.Count > 0 ? string.Join(" · ", degisen) : "ayarlar", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapDelete("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            var n = await veri.CalistirAsync("delete from public.hatirlatma where id = @p0 and sahip_id = @p1", [id, b.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.Bulunamadi("Hatırlatma bulunamadı ya da size ait değil (yalnız sahibi siler).");
            return Results.NoContent();
        });

        // ----------------------------------------------------------- eylemler --
        grup.MapPost("/{id:int}/tamamla", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            var h = await Yetki(bg, islem, id, b.KullaniciId, duzenle: false, iptal);
            string sonuc;
            // TEKRARLAYAN: tamamlamak bir sonrakini kurar (paylaşımdan bağımsız - tek takvim).
            if (h.Tekrar > 0)
            {
                var simdi = Saat.SimdiDilim(b.ZamanDilimi);
                var sonraki = Sonraki(Saat.Yerel(h.Zaman, b.ZamanDilimi), h.Tekrar, h.TekrarAralik, h.TekrarGunler, h.TekrarBitis, simdi);
                if (sonraki is { } s)
                {
                    await bg.CalistirAsync("""
                        update public.hatirlatma set zaman = @p1, uyari_gonderildi = null, sahip_tamam = null where id = @p0;
                        update public.hatirlatma_paylasim set tamamlandi = null where hatirlatma_id = @p0;
                        """, islem, [id, Saat.UtcYap(s, b.ZamanDilimi)], iptal);
                    sonuc = $"sonraki: {s:dd.MM.yyyy HH:mm}";
                    await Hareket(bg, islem, id, 5, sonuc, b.KullaniciId, iptal);
                    await islem.CommitAsync(iptal);
                    return Results.Ok(new { kapandi = false, sonuc });
                }
            }
            var tek = h.HerkesKapatir || h.Paylasim == 0;
            if (tek)
                await bg.CalistirAsync("update public.hatirlatma set durum = 2, tamamlanma = now() where id = @p0", islem, [id], iptal);
            else if (h.SahipId == b.KullaniciId)
                await bg.CalistirAsync("update public.hatirlatma set sahip_tamam = now() where id = @p0", islem, [id], iptal);
            else
                await bg.CalistirAsync("""
                    insert into public.hatirlatma_paylasim (hatirlatma_id, kullanici_id, tamamlandi) values (@p0, @p1, now())
                    on conflict (hatirlatma_id, kullanici_id) do update set tamamlandi = now()
                    """, islem, [id, b.KullaniciId], iptal);
            // Herkes kendi işaretini koyduysa satır da kapanır (birim paylaşımında sahibin işareti yeter).
            if (!tek)
                await bg.CalistirAsync("""
                    update public.hatirlatma h set durum = 2, tamamlanma = now()
                     where h.id = @p0 and h.sahip_tamam is not null
                       and (h.paylasim = 2 or not exists (select 1 from public.hatirlatma_paylasim p
                                                          where p.hatirlatma_id = h.id and p.tamamlandi is null))
                    """, islem, [id], iptal);
            await Hareket(bg, islem, id, 5, tek ? "" : "kendi işareti", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { kapandi = true, sonuc = "" });
        });

        grup.MapPost("/{id:int}/ac", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            await Yetki(bg, islem, id, b.KullaniciId, duzenle: false, iptal);
            await bg.CalistirAsync("""
                update public.hatirlatma set durum = 1, tamamlanma = null,
                       sahip_tamam = case when sahip_id = @p1 then null else sahip_tamam end where id = @p0;
                update public.hatirlatma_paylasim set tamamlandi = null where hatirlatma_id = @p0 and kullanici_id = @p1;
                """, islem, [id, b.KullaniciId], iptal);
            await Hareket(bg, islem, id, 6, "", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/{id:int}/ertele", async (int id, ErteleIstegi e, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            DateTime yeniUtc;
            if (e.Dakika is { } dk)
            {
                if (dk is < 1 or > 60 * 24 * 365) throw GentegreHatasi.Dogrulama("Erteleme süresi geçersiz.");
                var u = DateTime.UtcNow.AddMinutes(dk);
                yeniUtc = new DateTime(u.Year, u.Month, u.Day, u.Hour, u.Minute, 0, DateTimeKind.Utc);
            }
            else yeniUtc = Saat.UtcYap(YerelOku(e.Zaman, "zaman"), b.ZamanDilimi);
            if (yeniUtc <= DateTime.UtcNow) throw GentegreHatasi.Dogrulama("Erteleme zamanı gelecekte olmalı.", new AlanHatasi("zaman", "Geçmiş zaman."));
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            var h = await Yetki(bg, islem, id, b.KullaniciId, duzenle: false, iptal);
            // Erteleme UYARIYI da erteler: uyarı süresi yeni zamana göre yeniden işler, kısa ertelemede hemen.
            await bg.CalistirAsync("""
                update public.hatirlatma set zaman = @p1, uyari_gonderildi = null, ertele_sayisi = ertele_sayisi + 1,
                       uyar_dk = least(uyar_dk, greatest(0, floor(extract(epoch from (@p1 - now())) / 60)::int)),
                       durum = 1, sahip_tamam = null
                 where id = @p0
                """, islem, [id, yeniUtc], iptal);
            await Hareket(bg, islem, id, 3,
                $"{Saat.Yerel(h.Zaman, b.ZamanDilimi):dd.MM HH:mm} → {Saat.Yerel(yeniUtc, b.ZamanDilimi):dd.MM HH:mm}", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        grup.MapPost("/{id:int}/kopyala", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var b = await cozucu.CozAsync(ctx, iptal);
            await using var bg = await veri.AcAsync(iptal);
            await using var islem = await bg.BeginTransactionAsync(iptal);
            await Yetki(bg, islem, id, b.KullaniciId, duzenle: false, iptal);
            // Kopya KENDİNE ait ve paylaşımsız; zaman geçmişteyse yarın aynı saat.
            var yeni = await bg.TekDegerAsync<int>("""
                insert into public.hatirlatma (sahip_id, baslik, notu, zaman, uyar_dk, oncelik, renk, etiket, tekrar, tekrar_aralik,
                       tekrar_gunler, tekrar_bitis, kanal_uygulama, kanal_sms, kanal_eposta, kaynak, kaynak_id, kaynak_ad, sube_id, ekleyen)
                select @p1, left('Kopya ' || baslik, 200), notu,
                       case when zaman > now() then zaman else (current_date + 1) + (zaman::time) end,
                       uyar_dk, oncelik, renk, etiket, tekrar, tekrar_aralik, tekrar_gunler, tekrar_bitis,
                       kanal_uygulama, kanal_sms, kanal_eposta, kaynak, kaynak_id, kaynak_ad, @p2, @p1
                  from public.hatirlatma where id = @p0
                returning id
                """, islem, [id, b.KullaniciId, b.SubeId ?? 0], iptal);
            await Hareket(bg, islem, yeni, 1, $"#{id} kopyalandı", b.KullaniciId, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id = yeni });
        });
    }

    // ---------------------------------------------------------------- iç --

    private sealed record Dogrulanmis(string Baslik, string Notu, DateTime ZamanUtc, string KaynakAd, short Paylasim,
        int[] Paylasilanlar, object?[] Parametreler);

    private static Dogrulanmis Dogrula(HatirlatmaYazma g, string dilim)
    {
        var baslik = (g.Baslik ?? "").Trim();
        if (baslik.Length == 0) throw GentegreHatasi.Dogrulama("Başlık gerekli.", new AlanHatasi("baslik", "Boş."));
        if (baslik.Length > 200) baslik = baslik[..200];
        var notu = (g.Notu ?? "").Trim();
        if (notu.Length > 2000) notu = notu[..2000];
        var zaman = Saat.UtcYap(YerelOku(g.Zaman, "zaman"), dilim);
        var tekrar = g.Tekrar is >= 0 and <= 5 ? g.Tekrar.Value : (short)0;
        var gunler = (short)((g.TekrarGunler ?? 0) & 127);
        if (tekrar == 2 && gunler == 0) gunler = 0;
        DateTime? bitis = DateTime.TryParse(g.TekrarBitis, CultureInfo.InvariantCulture, DateTimeStyles.None, out var bt) ? bt.Date : null;
        if (tekrar == 0) bitis = null;
        var kanalUyg = g.KanalUygulama ?? true;
        var kanalSms = g.KanalSms ?? false;
        var kanalEp = g.KanalEposta ?? false;
        if (!kanalUyg && !kanalSms && !kanalEp)
            throw GentegreHatasi.Dogrulama("En az bir uyarı kanalı seçin.", new AlanHatasi("kanalUygulama", "Kanal yok."));
        var kaynak = (g.Kaynak ?? "").Trim();
        if (kaynak.Length > 40 || (kaynak.Length > 0 && !kaynak.All(c => char.IsAsciiLetterOrDigit(c) || c is '-' or '_' or '/')))
            throw GentegreHatasi.Dogrulama("Bağlı kayıt türü geçersiz.", new AlanHatasi("kaynak", "Geçersiz."));
        var kaynakId = kaynak.Length > 0 ? g.KaynakId : null;
        if (kaynakId is null) kaynak = "";
        var kaynakAd = kaynak.Length > 0 ? (g.KaynakAd ?? "").Trim() : "";
        if (kaynakAd.Length > 200) kaynakAd = kaynakAd[..200];
        var paylasim = g.Paylasim is >= 0 and <= 2 ? g.Paylasim.Value : (short)0;
        var dep = paylasim == 2 ? g.PaylasimDepartmanId : null;
        if (paylasim == 2 && dep is null) throw GentegreHatasi.Dogrulama("Paylaşılacak birimi seçin.", new AlanHatasi("paylasimDepartmanId", "Seçilmedi."));
        var kisiler = paylasim == 1 ? (g.Paylasilanlar ?? []).Where(x => x > 0).Distinct().Take(100).ToArray() : [];
        if (paylasim == 1 && kisiler.Length == 0) paylasim = 0;
        object?[] p =
        [
            baslik, notu, zaman, Math.Clamp(g.UyarDk ?? 15, 0, 60 * 24 * 30), (short)Math.Clamp((int)(g.Oncelik ?? 2), 1, 3),
            (short)Math.Clamp((int)(g.Renk ?? 0), 0, 4), (g.Etiket ?? "").Trim() is var e && e.Length > 60 ? e[..60] : (g.Etiket ?? "").Trim(),
            tekrar, (short)Math.Clamp((int)(g.TekrarAralik ?? 1), 1, 99), gunler, bitis,
            (short)(kanalUyg ? 1 : 0), (short)(kanalSms ? 1 : 0), (short)(kanalEp ? 1 : 0),
            kaynak, kaynakId, kaynakAd,
            paylasim, dep, (short)((g.HerkesKapatir ?? true) ? 1 : 0), (short)((g.PaylasilanDuzenler ?? false) ? 1 : 0),
        ];
        return new Dogrulanmis(baslik, notu, zaman, kaynakAd, paylasim, kisiler, p);
    }

    private sealed record Mevcut(int SahipId, string Baslik, string Notu, DateTime Zaman, short Tekrar, short TekrarAralik,
        short TekrarGunler, DateTime? TekrarBitis, short Paylasim, bool HerkesKapatir);

    /// <summary>Satırı kilitleyip okur; görmeyen için 404, düzenleyemeyen için 403.</summary>
    private static async Task<Mevcut> Yetki(NpgsqlConnection bg, NpgsqlTransaction islem, int id, int kullanici, bool duzenle,
        CancellationToken iptal)
    {
        var m = (await bg.ListeAsync(Sql("""
            select h.sahip_id, h.baslik, h.notu, h.zaman, h.tekrar, h.tekrar_aralik, h.tekrar_gunler, h.tekrar_bitis,
                   h.paylasim, h.herkes_kapatir, h.paylasilan_duzenler
              from public.hatirlatma h
             where h.id = @p1 and {GORUNUR}
             for update of h
            """), islem, [kullanici, id], r => (m: new Mevcut(r.GetInt32(0), r.GetString(1), r.GetString(2),
                r.GetFieldValue<DateTimeOffset>(3).UtcDateTime, r.GetInt16(4), r.GetInt16(5), r.GetInt16(6),
                r.IsDBNull(7) ? null : r.GetDateTime(7), r.GetInt16(8), r.GetInt16(9) == 1), duzenler: r.GetInt16(10) == 1), iptal))
            .FirstOrDefault();
        if (m.m is null) throw GentegreHatasi.Bulunamadi("Hatırlatma bulunamadı.");
        if (duzenle && m.m.SahipId != kullanici && !m.duzenler)
            throw GentegreHatasi.Yasak("Bu hatırlatmayı yalnız sahibi düzenler (paylaşımda düzenleme izni yok).");
        return m.m;
    }

    private static async Task PaylasilanlariYaz(NpgsqlConnection bg, NpgsqlTransaction islem, int id, int[] kisiler, int sahip,
        CancellationToken iptal)
    {
        var liste = kisiler.Where(x => x != sahip).ToArray();
        await bg.CalistirAsync("""
            delete from public.hatirlatma_paylasim where hatirlatma_id = @p0 and not (kullanici_id = any(@p1));
            insert into public.hatirlatma_paylasim (hatirlatma_id, kullanici_id)
            select @p0, x from unnest(@p1::int[]) x
            on conflict (hatirlatma_id, kullanici_id) do nothing;
            """, islem, [id, liste], iptal);
    }

    private static Task<int> Hareket(NpgsqlConnection bg, NpgsqlTransaction? islem, int id, short olay, string ayrinti, int kullanici,
        CancellationToken iptal)
        => bg.CalistirAsync("""
            insert into public.hatirlatma_hareket (hatirlatma_id, olay, ayrinti, kullanici_id) values (@p0, @p1, left(@p2, 400), @p3)
            """, islem, [id, olay, ayrinti, kullanici], iptal);
}
