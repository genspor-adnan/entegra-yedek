using System.Globalization;
using ClosedXML.Excel;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using Bel = Gentegre.Api.Uclar.KdvIcmalUclari.Bel;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Ba / Bs İCMALİ (mockup Ekranlar/İcmal/ba_bs_icmali.html - kullanıcı 25.10.2026, 1186).
/// "Bu ay Ba / Bs'ye kimler giriyor, tutarlar doğru mu, cari bizimle aynı tutarı mı bildirecek?"
///
/// <para><b>Kural KDV İcmali ile ORTAK</b> (KdvIcmalUclari.BelgeleriOkuAsync / BabsBelgesi / BabsFormu /
/// BabsSiniriAsync - ikinci hesap yok): dönemde (belge tarihi) kesin FATURA (15 / 11); Bs = satış +
/// alış iadesi (düzenlediğimiz), Ba = alış + satış iadesi; tutar KDV hariç saklı matrah (dövizli belgede
/// belge kuruyla TL); sınır Genel Ayarlar `muhasebe.babs_sinir` (boşsa 5.000 TL). Mükellef = şube VKN'si
/// (KDV İcmali ile aynı seçim).</para>
///
/// <para><b>Bu icmale özgü:</b> aynı VKN'li cariler TEK satır (GİB VKN bazında ister; KDV İcmali'nin ön
/// kontrolü cari bazında kalır); VKN'si eksik / hatalı cari kendi satırında, bildirime giremez (Uyarılar).
/// Nihai tüketici (11111111111) Ba / Bs'ye girmez; yurt dışı (2222222222 ya da ihracat senaryosu) ayrı
/// listededir (gümrük beyannamesiyle izlenir).</para>
///
/// <para><b>Mutabakat:</b> "gönder" babs_mutabakat satırını (dönem × form × cari) bizim tutar + belge sayısı
/// ile yazar ve e-posta varsa bildirim kuyruğuna mektup koyar; yanıt (mutabık / fark + carinin tutarı)
/// elle işlenir, loglu. Aksiyon `muhasebe.babs_mutabakat`. Gönderimden sonra tutar değişirse satır
/// "değişti" işaretlenir.</para>
///
/// <para><b>Bilinen eksikler:</b> gider pusulası / serbest meslek makbuzu ayrı belge türü olmadığı için
/// yalnız fatura; e-Beyanname XML'i üretilmez (Excel dökümü verilir); mutabakat yanıtı için tek
/// kullanımlık bağlantı yok.</para>
/// </summary>
public static class BabsIcmalUclari
{
    private const string Kod = "muhasebe.babs_icmali";
    private const string AksiyonMutabakat = "muhasebe.babs_mutabakat";

    /// <summary>islem_log.tablo_id - babs_mutabakat.</summary>
    private const int LogTabloMutabakat = 1771;

    /// <summary>bildirim.kaynak_tur - Ba / Bs mutabakat mektubu.</summary>
    private const short KaynakMutabakat = 71;

    private const string NihaiTuketici = "11111111111";
    private const string YurtDisiVkn = "2222222222";

    public sealed record GonderSatiri(string Form, string Anahtar, string? Eposta);
    public sealed record GonderIstegi(string? Donem, string? Vkn, int? Sube, GonderSatiri[]? Satirlar, bool EpostaGonder);
    public sealed record YanitIstegi(short Yanit, decimal? CarininTutari, int? CarininBelge, string? Not);

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");
    private static decimal R(decimal d) => Math.Round(d, 2);
    private static string AyAdi(DateTime d) => Tr.TextInfo.ToTitleCase(d.ToString("MMMM yyyy", Tr));

    // ================================================================ hesap ===

    /// <summary>Bir form + VKN (ya da VKN'siz cari) grubu.</summary>
    private sealed record Grup(string Form, string Anahtar, string Vkn, string VknDurum, string Unvan, int[] TarafIdler,
        int Belge, decimal Tutar, decimal Iade, bool Ustu, List<Bel> Belgeler);

    private sealed record Hesap(DateTime Bas, DateTime Bit, string Donem, KdvIcmalUclari.Mukellef Muk,
        List<KdvIcmalUclari.Mukellef> Mukellefler, int Sube, decimal Sinir, List<Grup> Gruplar, List<Grup> YurtDisi,
        List<Bel> Nihai, List<Bel> Kesin, List<Bel> Taslak, bool Kapsamli);

    private static async Task<Hesap> HesaplaAsync(NpgsqlConnection b, IstekBaglami baglam, string? donem, string? vkn,
        int? sube, CancellationToken iptal)
    {
        var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
        // Varsayılan dönem: GEÇEN AY (Ba / Bs izleyen ayın sonuna kadar bildirilir).
        var (bas, bit, donemAdi) = KdvIcmalUclari.DonemCoz(string.IsNullOrWhiteSpace(donem)
            ? new DateTime(bugun.Year, bugun.Month, 1).AddMonths(-1).ToString("yyyy-MM", CultureInfo.InvariantCulture) : donem, bugun);

        var mukellefler = await KdvIcmalUclari.MukelleflerAsync(b, null, baglam, iptal);
        if (mukellefler.Count == 0) throw GentegreHatasi.Yasak("Yetkili olduğunuz şube yok.");
        var istenen = (vkn ?? "").Trim();
        var muk = istenen.Length > 0
            ? mukellefler.FirstOrDefault(m => m.Anahtar == (istenen == "-" ? "-" : KdvIcmalUclari.Rakam(istenen)))
              ?? throw GentegreHatasi.Bulunamadi("Mükellef bulunamadı.")
            : mukellefler.FirstOrDefault(m => m.Subeler.Any(s => s.Id == baglam.SubeId)) ?? mukellefler[0];
        var s0 = sube ?? 0;
        if (s0 > 0 && muk.Subeler.All(s => s.Id != s0)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        int[] subeler = s0 > 0 ? [s0] : muk.Subeler.Select(s => s.Id).ToArray();
        var subesiz = mukellefler.Count == 1 && s0 == 0 ? 1 : 0;
        var kapsam = baglam.Kapsam.ToArray();

        var ham = await KdvIcmalUclari.BelgeleriOkuAsync(b, KdvIcmalUclari.Turler, bas, bit, subeler, subesiz, kapsam, iptal);
        var kesin = ham.Where(x => !x.Taslak).ToList();
        var faturalar = ham.Where(KdvIcmalUclari.BabsBelgesi).ToList();
        var taslak = ham.Where(x => x.Taslak && x.Fatura && x.Matrah != 0).ToList();
        var sinir = await KdvIcmalUclari.BabsSiniriAsync(b, iptal);

        static bool YurtDisiMi(Bel x) => x.Vkn == YurtDisiVkn || x.Senaryo == 3;
        var nihai = faturalar.Where(x => x.Vkn == NihaiTuketici).ToList();
        var yurtDisiB = faturalar.Where(x => x.Vkn != NihaiTuketici && YurtDisiMi(x)).ToList();
        var yurticiB = faturalar.Where(x => x.Vkn != NihaiTuketici && !YurtDisiMi(x)).ToList();

        List<Grup> Grupla(IEnumerable<Bel> l) => l
            .GroupBy(x =>
            {
                var d = KdvIcmalUclari.VknDurum(x.Vkn);
                return (form: KdvIcmalUclari.BabsFormu(x), anahtar: d == "tamam" ? "v" + x.Vkn : "t" + x.TarafId);
            })
            .Select(g =>
            {
                var ilk = g.OrderByDescending(x => x.Tarih).First();
                var tutar = R(g.Sum(x => x.Matrah));
                return new Grup(g.Key.form, g.Key.anahtar, ilk.Vkn, KdvIcmalUclari.VknDurum(ilk.Vkn), ilk.Taraf,
                    g.Select(x => x.TarafId).Where(t => t > 0).Distinct().ToArray(), g.Count(), tutar,
                    R(g.Where(x => x.Iade).Sum(x => x.Matrah)), tutar >= sinir, g.OrderBy(x => x.Tarih).ThenBy(x => x.No).ToList());
            })
            .OrderBy(x => x.Form == "Ba" ? 0 : 1).ThenByDescending(x => x.Tutar).ToList();

        return new Hesap(bas, bit, donemAdi, muk, mukellefler, s0, sinir, Grupla(yurticiB), Grupla(yurtDisiB),
            nihai, kesin, taslak, kapsam.Length > 0);
    }

    private static async Task<Dictionary<(string form, int tarafId), (long id, short yanit, decimal tutar, int belge, string eposta,
        DateTime? gonderim, decimal? carininTutari, int? carininBelge, DateTime? yanitAn, string yanitNot)>> MutabakatlarAsync(
        NpgsqlConnection b, NpgsqlTransaction? tx, DateTime bas, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select m.id, m.form, m.taraf_id, m.yanit, m.tutar, m.belge_sayisi, m.eposta, m.gonderim_an, m.carinin_tutari,
                   m.carinin_belge, m.yanit_an, m.yanit_not
              from public.babs_mutabakat m where m.donem = @p0::date
            """, tx, [bas], o => (id: o.GetInt64(0), form: o.GetString(1), taraf: o.GetInt32(2), yanit: o.GetInt16(3),
                tutar: o.GetDecimal(4), belge: o.GetInt32(5), eposta: o.GetString(6),
                gonderim: o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                ct: o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8), cb: o.IsDBNull(9) ? (int?)null : o.GetInt32(9),
                yan: o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), not: o.GetString(11)), iptal);
        return l.GroupBy(x => (x.form == "BA" ? "Ba" : "Bs", x.taraf)).ToDictionary(g => g.Key, g =>
        {
            var x = g.First();
            return (x.id, x.yanit, x.tutar, x.belge, x.eposta, x.gonderim, x.ct, x.cb, x.yan, x.not);
        });
    }

    // ================================================================== uçlar ===

    public static void BabsIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/babs-icmal").WithTags("Ba / Bs İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (string? donem, string? vkn, int? sube, VeriKaynagi veri, BaglamCozucu cozucu,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var h = await HesaplaAsync(b, baglam, donem, vkn, sube, iptal);
            var mut = await MutabakatlarAsync(b, null, h.Bas, iptal);

            // Carilerin e-postası (mutabakat mektubu varsayılanı).
            var tarafIdler = h.Gruplar.SelectMany(g => g.TarafIdler).Distinct().ToArray();
            var epostalar = tarafIdler.Length == 0 ? new Dictionary<int, string>()
                : (await b.ListeAsync("select id, coalesce(btrim(eposta), '') from public.taraf where id = any(@p0::int[])",
                    null, [tarafIdler], o => (id: o.GetInt32(0), e: o.GetString(1)), iptal)).ToDictionary(x => x.id, x => x.e);

            object Satir(Grup g, int sira)
            {
                var ilk = g.TarafIdler.FirstOrDefault();
                object? m = null;
                if (ilk > 0 && mut.TryGetValue((g.Form, ilk), out var x))
                    m = new
                    {
                        x.id, x.yanit, gonderimAn = x.gonderim, x.eposta, tutar = x.tutar, belge = x.belge,
                        carininTutari = x.carininTutari, carininBelge = x.carininBelge,
                        fark = x.carininTutari is { } ct ? R(g.Tutar - ct) : (decimal?)null,
                        yanitAn = x.yanitAn, yanitNot = x.yanitNot,
                        degisti = x.gonderim is not null && (x.tutar != g.Tutar || x.belge != g.Belge),
                    };
                return new
                {
                    sira, form = g.Form, anahtar = g.Anahtar, vkn = g.Vkn, vknDurum = g.VknDurum, unvan = g.Unvan,
                    tarafId = ilk, tarafSayisi = g.TarafIdler.Length, belge = g.Belge, tutar = g.Tutar, iade = g.Iade,
                    eposta = g.TarafIdler.Select(t => epostalar.GetValueOrDefault(t, "")).FirstOrDefault(e => e.Contains('@')) ?? "",
                    kalan = g.Ustu ? (decimal?)null : R(h.Sinir - g.Tutar), yakin = !g.Ustu && g.Tutar >= h.Sinir * 0.9m,
                    mutabakat = m,
                };
            }

            var ustu = h.Gruplar.Where(g => g.Ustu).ToList();
            var ba = ustu.Where(g => g.Form == "Ba").Select((g, i) => Satir(g, i + 1)).ToList();
            var bs = ustu.Where(g => g.Form == "Bs").Select((g, i) => Satir(g, i + 1)).ToList();
            var alti = h.Gruplar.Where(g => !g.Ustu).OrderByDescending(g => g.Tutar).ToList();
            var esikAlti = alti.Take(500).Select((g, i) => Satir(g, i + 1)).ToList();

            // ------------------------------------------------------ uyarılar --
            var uyarilar = new List<object>();
            foreach (var g in ustu.Where(z => z.VknDurum != "tamam"))
                uyarilar.Add(new
                {
                    tur = "vkn", seviye = "kir", form = g.Form, tarafId = g.TarafIdler.FirstOrDefault(), unvan = g.Unvan, tutar = g.Tutar,
                    aciklama = g.VknDurum == "eksik" ? "VKN / TCKN boş — bildirime girmez" : $"VKN / TCKN hatalı ({g.Vkn.Length} hane) — bildirime girmez",
                    oneri = "cari kartına vergi no gir",
                });
            foreach (var g in ustu.Where(z => z.VknDurum == "tamam" && z.TarafIdler.Length > 1))
                uyarilar.Add(new
                {
                    tur = "cokcari", seviye = "sari", form = g.Form, tarafId = g.TarafIdler[0], unvan = g.Unvan, tutar = g.Tutar,
                    aciklama = $"Aynı VKN {g.TarafIdler.Length} caride — bildirimde tek satırda toplandı",
                    oneri = "bilgi; mükerrer cari ise birleştir",
                });
            foreach (var g in h.YurtDisi.Where(z => z.Tutar >= h.Sinir))
                uyarilar.Add(new
                {
                    tur = "yurtdisi", seviye = "mavi", form = g.Form, tarafId = g.TarafIdler.FirstOrDefault(), unvan = g.Unvan, tutar = g.Tutar,
                    aciklama = "Yurt dışı — Ba / Bs dışı (gümrük beyannamesi)", oneri = "",
                });
            if (h.Taslak.Count > 0)
                uyarilar.Add(new
                {
                    tur = "taslak", seviye = "sari", form = "", tarafId = 0, unvan = "", tutar = R(h.Taslak.Sum(x => x.Matrah)),
                    aciklama = $"{h.Taslak.Count} taslak fatura bu döneme tarihli — kesinleşmeden Ba / Bs'ye girmez",
                    oneri = "taslakları kesinleştir ya da sil",
                });
            foreach (var g in ustu)
            {
                var ilk = g.TarafIdler.FirstOrDefault();
                if (ilk > 0 && mut.TryGetValue((g.Form, ilk), out var x) && x.gonderim is not null && (x.tutar != g.Tutar || x.belge != g.Belge))
                    uyarilar.Add(new
                    {
                        tur = "degisti", seviye = "sari", form = g.Form, tarafId = ilk, unvan = g.Unvan, tutar = g.Tutar,
                        aciklama = $"Mutabakat gönderildikten sonra tutar değişti ({x.tutar.ToString("N2", Tr)} → {g.Tutar.ToString("N2", Tr)})",
                        oneri = "yeniden gönder",
                    });
            }

            // --------------------------------------------- KDV İcmali ile kıyas --
            // KDV İcmali'nin hesaplanan / indirilecek matrahı (kesin satış 15+16 / alış 11+12, iade hariç) ile
            //   Ba / Bs bileşenlerinin toplamı. Fark sıfırdan farklıysa bir belge iki tarafta farklı sınıflanmıştır.
            object Kiyas(bool satis)
            {
                var yon = h.Kesin.Where(x => x.Satis == satis && !x.Iade).ToList();
                var kdv = R(yon.Sum(x => x.Matrah));
                var fat = yon.Where(x => x.Fatura).ToList();
                decimal Toplam(Func<Bel, bool> f) => R(fat.Where(f).Sum(x => x.Matrah));
                var ustuIdler = ustu.SelectMany(g => g.Belgeler).Select(x => x.Id).ToHashSet();
                var yurtIdler = h.YurtDisi.SelectMany(g => g.Belgeler).Select(x => x.Id).ToHashSet();
                var nihaiIdler = h.Nihai.Select(x => x.Id).ToHashSet();
                var u = Toplam(x => ustuIdler.Contains(x.Id));
                var n = Toplam(x => nihaiIdler.Contains(x.Id));
                var y = Toplam(x => yurtIdler.Contains(x.Id));
                var a = Toplam(x => !ustuIdler.Contains(x.Id) && !nihaiIdler.Contains(x.Id) && !yurtIdler.Contains(x.Id));
                var fis = R(yon.Where(x => !x.Fatura).Sum(x => x.Matrah));
                var top = u + a + n + y + fis;
                return new { kdv, ustu = u, alti = a, nihai = n, yurtDisi = y, fis, toplam = R(top), fark = R(kdv - top) };
            }
            var iadeBs = R(h.Kesin.Where(x => x.Fatura && x.Iade && !x.Satis).Sum(x => x.Matrah));
            var iadeBa = R(h.Kesin.Where(x => x.Fatura && x.Iade && x.Satis).Sum(x => x.Matrah));

            int Yanit(int y) => ustu.Count(g =>
            {
                var ilk = g.TarafIdler.FirstOrDefault();
                return ilk > 0 && mut.TryGetValue((g.Form, ilk), out var x) && x.gonderim is not null && x.yanit == y;
            });
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var sonGun = new DateTime(h.Bas.Year, h.Bas.Month, 1).AddMonths(2).AddDays(-1);
            var donemler = Enumerable.Range(0, 24).Select(i =>
            {
                var a = new DateTime(bugun.Year, bugun.Month, 1).AddMonths(-i);
                return new { donem = a.ToString("yyyy-MM", CultureInfo.InvariantCulture), ad = AyAdi(a) };
            }).ToList();
            var baU = ustu.Where(g => g.Form == "Ba").ToList();
            var bsU = ustu.Where(g => g.Form == "Bs").ToList();

            return Results.Ok(new
            {
                donem = h.Donem, donemAd = AyAdi(h.Bas), bas = h.Bas, bit = h.Bit, sonGun, gecikti = bugun > sonGun,
                vkn = h.Muk.Anahtar, sube = h.Sube, sinir = h.Sinir, kapsamli = h.Kapsamli,
                mukellef = new { anahtar = h.Muk.Anahtar, vkn = h.Muk.Vkn, unvan = h.Muk.Unvan, subeler = h.Muk.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList() },
                ozet = new
                {
                    ba = new { cari = baU.Count, belge = baU.Sum(g => g.Belge), tutar = R(baU.Sum(g => g.Tutar)) },
                    bs = new { cari = bsU.Count, belge = bsU.Sum(g => g.Belge), tutar = R(bsU.Sum(g => g.Tutar)) },
                    esikAlti = new { cari = alti.Count, tutar = R(alti.Sum(g => g.Tutar)), yakin = alti.Count(g => g.Tutar >= h.Sinir * 0.9m) },
                    vknEksik = ustu.Count(g => g.VknDurum != "tamam"),
                    gonderilmedi = ustu.Count(g => g.VknDurum == "tamam" && !(g.TarafIdler.FirstOrDefault() is var t && t > 0
                        && mut.TryGetValue((g.Form, t), out var x) && x.gonderim is not null)),
                    bekleyen = Yanit(0), mutabik = Yanit(1), fark = Yanit(2),
                    yurtDisi = h.YurtDisi.Count, yurtDisiTutar = R(h.YurtDisi.Sum(g => g.Tutar)),
                    nihaiTutar = R(h.Nihai.Sum(x => x.Matrah)), taslak = h.Taslak.Count,
                },
                ba, bs, esikAlti, esikAltiToplam = alti.Count,
                yurtDisi = h.YurtDisi.Select((g, i) => Satir(g, i + 1)).ToList(),
                uyarilar,
                kiyas = new { satis = Kiyas(true), alis = Kiyas(false), iadeBs, iadeBa },
                secim = new
                {
                    mukellefler = h.Mukellefler.Select(m => new
                    {
                        anahtar = m.Anahtar, vkn = m.Vkn, unvan = m.Unvan, subeler = m.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    }).ToList(),
                    donemler,
                },
                yetkiler = new { mutabakat = baglam.Yetkiler.AksiyonVar(AksiyonMutabakat) && baglam.SubeYazma },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================== grubun belgeleri ===
        grup.MapGet("/belgeler", async (string? donem, string? vkn, int? sube, string? form, string? anahtar,
                                        VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var h = await HesaplaAsync(b, baglam, donem, vkn, sube, iptal);
            var g = h.Gruplar.Concat(h.YurtDisi).FirstOrDefault(x => x.Form == form && x.Anahtar == anahtar)
                    ?? throw GentegreHatasi.Bulunamadi("Satır bulunamadı (dönem değişmiş olabilir).");
            return Results.Ok(new
            {
                belgeler = g.Belgeler.Select(x => new
                {
                    id = x.Id, no = x.No, tarih = x.Tarih, tarafId = x.TarafId, taraf = x.Taraf, yon = x.Yon, matrah = R(x.Matrah),
                }).ToList(),
            });
        });

        // ============================================================ DIŞA AKTAR ===
        // Form Ba ve Form Bs ayrı sayfa (.xlsx). e-Beyanname XML'i ÜRETİLMEZ (şema doğrulanmadı) - müşavir /
        //   kullanıcı bu dökümden beyannameyi hazırlar.
        grup.MapGet("/disa-aktar", async (string? donem, string? vkn, int? sube, VeriKaynagi veri, BaglamCozucu cozucu,
                                          HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var h = await HesaplaAsync(b, baglam, donem, vkn, sube, iptal);

            using var kitap = new XLWorkbook();
            foreach (var form in new[] { "Ba", "Bs" })
            {
                var s = kitap.Worksheets.Add("Form " + form);
                s.Style.Font.FontName = "Calibri";
                s.Style.Font.FontSize = 10;
                s.Cell(1, 1).Value = $"FORM {form.ToUpperInvariant()} — {(form == "Ba" ? "MAL VE HİZMET ALIMLARI" : "MAL VE HİZMET SATIŞLARI")}";
                s.Cell(1, 1).Style.Font.Bold = true;
                s.Cell(2, 1).Value = $"Dönem: {AyAdi(h.Bas)} · Mükellef: {h.Muk.Unvan} · VKN {h.Muk.Vkn} · Sınır {h.Sinir.ToString("N2", Tr)} TL (KDV hariç)";
                string[] bas = ["Sıra", "Unvan", "Ülke", "VKN / TCKN", "Belge Sayısı", "Tutar (KDV hariç)", "Durum"];
                for (var i = 0; i < bas.Length; i++)
                {
                    var c = s.Cell(4, i + 1);
                    c.Value = bas[i];
                    c.Style.Font.Bold = true;
                    c.Style.Fill.BackgroundColor = XLColor.FromHtml("#DCE6F1");
                }
                var r = 5;
                var sira = 0;
                foreach (var g in h.Gruplar.Where(x => x.Form == form && x.Ustu))
                {
                    s.Cell(r, 1).Value = ++sira;
                    s.Cell(r, 2).Value = g.Unvan;
                    s.Cell(r, 3).Value = "TR";
                    s.Cell(r, 4).SetValue(g.Vkn);
                    s.Cell(r, 5).Value = g.Belge;
                    s.Cell(r, 6).Value = g.Tutar;
                    s.Cell(r, 6).Style.NumberFormat.Format = "#,##0.00";
                    s.Cell(r, 7).Value = g.VknDurum == "tamam" ? "" : "VKN / TCKN " + (g.VknDurum == "eksik" ? "eksik" : "hatalı") + " — bildirime girmez";
                    r++;
                }
                s.Cell(r, 2).Value = "TOPLAM";
                s.Cell(r, 2).Style.Font.Bold = true;
                s.Cell(r, 5).Value = h.Gruplar.Where(x => x.Form == form && x.Ustu).Sum(x => x.Belge);
                s.Cell(r, 6).Value = R(h.Gruplar.Where(x => x.Form == form && x.Ustu).Sum(x => x.Tutar));
                s.Cell(r, 6).Style.NumberFormat.Format = "#,##0.00";
                s.Columns().AdjustToContents();
            }
            using var akis = new MemoryStream();
            kitap.SaveAs(akis);
            return Results.File(akis.ToArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                $"BaBs_{h.Donem}_{(h.Muk.Vkn.Length > 0 ? h.Muk.Vkn : "mukellef")}.xlsx");
        });

        // ===================================================== MUTABAKAT GÖNDER ===
        // Seçili satırlar için babs_mutabakat (dönem × form × cari) yazılır - tutar ve belge sayısı SUNUCUDA yeniden
        //   hesaplanır, istemcinin rakamı kullanılmaz. Yeniden gönderim yanıtı sıfırlar. e-Posta istenirse ve
        //   adres varsa bildirim kuyruğuna mektup konur (gönderimi BildirimIscisi yapar).
        grup.MapPost("/mutabakat", async (GonderIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                          BildirimDeposu bildirim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.AksiyonIste(AksiyonMutabakat);
            if (!baglam.SubeYazma) throw GentegreHatasi.Yasak("Bu şubede yazma yetkiniz yok.");
            var istenen = istek.Satirlar ?? [];
            if (istenen.Length == 0) throw GentegreHatasi.Dogrulama("Gönderilecek satır seçilmedi.", new AlanHatasi("satirlar", "Zorunlu."));
            if (istenen.Length > 1000) throw GentegreHatasi.Dogrulama("En çok 1.000 satır gönderilebilir.", new AlanHatasi("satirlar", "Çok fazla."));

            await using var b = await veri.AcAsync(iptal);
            var h = await HesaplaAsync(b, baglam, istek.Donem, istek.Vkn, istek.Sube, iptal);
            var kuyruk = new List<(string eposta, string unvan, string form, int tarafId, long id, int belge, decimal tutar)>();
            var atlanan = new List<string>();
            var yazilan = 0;

            await using (var tx = await b.BeginTransactionAsync(iptal))
            {
                foreach (var s in istenen)
                {
                    var g = h.Gruplar.FirstOrDefault(x => x.Form == s.Form && x.Anahtar == s.Anahtar && x.Ustu);
                    if (g is null) { atlanan.Add($"{s.Form} {s.Anahtar}: eşik üstü satır bulunamadı"); continue; }
                    if (g.VknDurum != "tamam") { atlanan.Add($"{g.Unvan}: VKN / TCKN {(g.VknDurum == "eksik" ? "eksik" : "hatalı")}"); continue; }
                    var tarafId = g.TarafIdler.FirstOrDefault();
                    if (tarafId <= 0) { atlanan.Add($"{g.Unvan}: cari yok"); continue; }
                    var eposta = (s.Eposta ?? "").Trim();
                    if (eposta.Length > 300) eposta = eposta[..300];
                    var formDb = g.Form.ToUpperInvariant();

                    var eski = await b.ListeAsync("""
                        select id, tutar, belge_sayisi, eposta, yanit from public.babs_mutabakat
                         where donem = @p0::date and form = @p1 and taraf_id = @p2 for update
                        """, tx, [h.Bas, formDb, tarafId], o => (id: o.GetInt64(0), tutar: o.GetDecimal(1), belge: o.GetInt32(2),
                            eposta: o.GetString(3), yanit: o.GetInt16(4)), iptal);
                    long id;
                    if (eski.Count == 0)
                    {
                        id = await b.TekDegerAsync<long>("""
                            insert into public.babs_mutabakat (donem, form, taraf_id, vkn, belge_sayisi, tutar, eposta, gonderim_an, gonderen)
                            values (@p0::date, @p1, @p2, @p3, @p4, @p5, @p6, now(), @p7) returning id
                            """, tx, [h.Bas, formDb, tarafId, g.Vkn, g.Belge, g.Tutar, eposta, baglam.KullaniciId], iptal);
                        await log.YazAsync(b, tx, LogIslemi.Ekle, LogTabloMutabakat, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                            new Dictionary<string, string>
                            {
                                ["donem"] = h.Donem, ["form"] = formDb, ["vkn"] = g.Vkn, ["belge"] = g.Belge.ToString(CultureInfo.InvariantCulture),
                                ["tutar"] = LogDeposu.Metin(g.Tutar), ["eposta"] = eposta, ["kaynak"] = "babs-icmali",
                            }, tarafId: tarafId, iptal: iptal);
                    }
                    else
                    {
                        var e = eski[0];
                        id = e.id;
                        await b.CalistirAsync("""
                            update public.babs_mutabakat
                               set vkn = @p1, belge_sayisi = @p2, tutar = @p3, eposta = @p4, gonderim_an = now(), gonderen = @p5,
                                   yanit = 0, carinin_tutari = null, carinin_belge = null, yanit_an = null, yanit_not = ''
                             where id = @p0
                            """, tx, [id, g.Vkn, g.Belge, g.Tutar, eposta, baglam.KullaniciId], iptal);
                        var fark = LogDeposu.Fark(
                            new Dictionary<string, object?> { ["tutar"] = e.tutar, ["belge"] = e.belge, ["eposta"] = e.eposta, ["yanit"] = e.yanit },
                            new Dictionary<string, object?> { ["tutar"] = g.Tutar, ["belge"] = g.Belge, ["eposta"] = eposta, ["yanit"] = (short)0 })
                            ?? new Dictionary<string, string>();
                        fark["donem"] = h.Donem;
                        fark["form"] = formDb;
                        fark["islem"] = "yeniden gönderildi";
                        await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloMutabakat, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                            fark, tarafId: tarafId, iptal: iptal);
                    }
                    yazilan++;
                    if (istek.EpostaGonder && eposta.Contains('@'))
                        kuyruk.Add((eposta, g.Unvan, g.Form, tarafId, id, g.Belge, g.Tutar));
                    else if (istek.EpostaGonder)
                        atlanan.Add($"{g.Unvan}: e-posta adresi yok — kayıt yazıldı, mektup çıktıdan verilmeli");
                }
                await tx.CommitAsync(iptal);
            }

            // Kuyruk işlemden SONRA: mektup yazılamazsa mutabakat kaydı geri alınmaz (bildirim ayrı iş).
            var kuyrugaGiden = 0;
            foreach (var k in kuyruk)
            {
                var konu = $"Form {k.form} mutabakatı — {AyAdi(h.Bas)} · {h.Muk.Unvan}";
                var govde =
                    $"Sayın {k.unvan},\n\n" +
                    $"{AyAdi(h.Bas)} dönemi Form {k.form} bildirimimizde firmanız adına {k.belge} adet belge, KDV hariç toplam " +
                    $"{k.tutar.ToString("N2", Tr)} TL yer almaktadır ({(k.form == "Bs" ? "size yaptığımız satışlar" : "sizden yaptığımız alımlar")}).\n\n" +
                    "Kayıtlarınız uyumluysa \"mutabıkız\", farklıysa kendi tutarınızı ve belge sayınızı bu e-postaya yanıt olarak bildirmenizi rica ederiz.\n\n" +
                    $"Saygılarımızla,\n{h.Muk.Unvan}" + (h.Muk.Vkn.Length > 0 ? $" (VKN {h.Muk.Vkn})" : "");
                try
                {
                    if (await bildirim.KuyrugaEkleAsync(new BildirimIstegi(null, BildirimKanali.Eposta, k.eposta, Konu: konu, Govde: govde,
                            TarafId: k.tarafId, KaynakTur: KaynakMutabakat, KaynakId: (int)k.id), baglam.KullaniciId, baglam.SubeId, iptal) is not null)
                        kuyrugaGiden++;
                }
                catch (Exception)
                {
                    atlanan.Add($"{k.unvan}: e-posta kuyruğa alınamadı — kayıt yazıldı");
                }
            }
            return Results.Ok(new { yazilan, eposta = kuyrugaGiden, atlanan, izlemeNo = baglam.IzlemeNo });
        });

        // ====================================================== MUTABAKAT YANIT ===
        // Carinin yanıtı elle işlenir: 1 mutabık · 2 fark var (carinin tutarı zorunlu) · 0 yanıtı geri al.
        grup.MapPut("/mutabakat/{id:long}", async (long id, YanitIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
                                                   LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.AksiyonIste(AksiyonMutabakat);
            if (!baglam.SubeYazma) throw GentegreHatasi.Yasak("Bu şubede yazma yetkiniz yok.");
            if (istek.Yanit is < 0 or > 2) throw GentegreHatasi.Dogrulama("Yanıt 0, 1 ya da 2 olmalı.", new AlanHatasi("yanit", "Geçersiz."));
            if (istek.Yanit == 2 && istek.CarininTutari is null)
                throw GentegreHatasi.Dogrulama("Fark bildiren carinin tutarı girilmeli.", new AlanHatasi("carininTutari", "Zorunlu."));
            if (istek.CarininTutari is < 0 or > 9_999_999_999_999m)
                throw GentegreHatasi.Dogrulama("Tutar geçersiz.", new AlanHatasi("carininTutari", "Geçersiz."));
            if (istek.CarininBelge is < 0 or > 1_000_000)
                throw GentegreHatasi.Dogrulama("Belge sayısı geçersiz.", new AlanHatasi("carininBelge", "Geçersiz."));
            var not = (istek.Not ?? "").Trim();
            if (not.Length > 500) throw GentegreHatasi.Dogrulama("Not en çok 500 karakter.", new AlanHatasi("not", "En çok 500 karakter."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var eski = await b.ListeAsync("""
                select m.taraf_id, m.yanit, m.carinin_tutari, m.carinin_belge, m.yanit_not, m.gonderim_an, m.donem, m.form
                  from public.babs_mutabakat m where m.id = @p0 for update
                """, tx, [id], o => (taraf: o.GetInt32(0), yanit: o.GetInt16(1), ct: o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                    cb: o.IsDBNull(3) ? (int?)null : o.GetInt32(3), not: o.GetString(4), gonderim: !o.IsDBNull(5),
                    donem: o.GetDateTime(6), form: o.GetString(7)), iptal);
            if (eski.Count == 0) throw GentegreHatasi.Bulunamadi("Mutabakat kaydı bulunamadı.");
            var e = eski[0];
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(e.taraf))
                throw GentegreHatasi.Yasak("Bu cariye erişim yetkiniz yok.");
            if (!e.gonderim) throw GentegreHatasi.IsKurali("Önce mutabakat gönderilmeli.");

            decimal? ct = istek.Yanit == 0 ? null : istek.CarininTutari is { } t ? Math.Round(t, 2) : null;
            int? cb = istek.Yanit == 0 ? null : istek.CarininBelge;
            var yeniNot = istek.Yanit == 0 ? "" : not;
            var fark = LogDeposu.Fark(
                new Dictionary<string, object?> { ["yanit"] = e.yanit, ["carininTutari"] = e.ct, ["carininBelge"] = e.cb, ["not"] = e.not },
                new Dictionary<string, object?> { ["yanit"] = istek.Yanit, ["carininTutari"] = ct, ["carininBelge"] = cb, ["not"] = yeniNot });
            if (fark is not null)
            {
                await b.CalistirAsync("""
                    update public.babs_mutabakat
                       set yanit = @p1, carinin_tutari = @p2, carinin_belge = @p3, yanit_not = @p4,
                           yanit_an = case when @p1 = 0 then null else now() end, isleyen = @p5
                     where id = @p0
                    """, tx, [id, istek.Yanit, ct, cb, yeniNot, baglam.KullaniciId], iptal);
                fark["donem"] = e.donem.ToString("yyyy-MM", CultureInfo.InvariantCulture);
                fark["form"] = e.form;
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloMutabakat, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    fark, tarafId: e.taraf, iptal: iptal);
            }
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, yanit = istek.Yanit, izlemeNo = baglam.IzlemeNo });
        });
    }
}
