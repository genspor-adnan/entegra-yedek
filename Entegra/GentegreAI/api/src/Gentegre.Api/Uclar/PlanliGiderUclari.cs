using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;
using static Gentegre.Api.Servisler.PlanliGiderMotoru;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PLANLI GİDER `/api/planli-gider` (1177, mockup Ekranlar/ERP/planli_gider.html +
/// planli_gider_karti.html; kararlar 25.10.2026 mockup notlarında). Sözleşme
/// dokuman/01_API_SOZLESMELERI.md §9.24.
///
/// <para>TANIM bir kuraldır; DÖNEMLER takvimden türetilir (<see cref="PlanliGiderHesap"/>, motor
/// <see cref="PlanliGiderMotoru"/>). Saklanan yalnız istisna (atla, elle tutar), gerçekleşme
/// (eşleşme) ve dondurulmuş plan. Hiçbir kasa / banka işlemi ya da fatura kendiliğinden oluşmaz:
/// "Ödeme Oluştur" TASLAK tediye açar (kasa_islem Ekle ayrıca istenir).</para>
///
/// <para>Yetki `finans.planli_gider` (Gör / Ekle / Değiştir / Sil). Şube: tanım aktif şubeye
/// damgalanır; liste aktif şubenin tanımlarıdır, kart kullanıcının şubelerinden okunur, yazma
/// yalnız tanımın kendi şubesinde. Rakamlar sunucuda; ekran toplamaz.</para>
///
/// <para>Ödenecek yer (karar 25.10.2026, kullanıcı): yalnız TEDARİKÇİ (taraf.tedarikci = 1);
/// zorunlu, tek istisna kategori 'vergi_sgk'.</para>
/// </summary>
public static partial class PlanliGiderUclari
{
    private const string Kod = "finans.planli_gider";

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    private static string? T(DateTime? d) => d?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    private static decimal R(decimal d) => PlanliGiderHesap.Yuvarla(d);

    private static DateTime VadeCoz(string? vade)
        => DateTime.TryParseExact(vade ?? "", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d)
            ? d.Date
            : throw GentegreHatasi.Dogrulama("Dönem (vade) yyyy-AA-gg biçiminde olmalı.", new AlanHatasi("vade", "Geçersiz tarih."));

    private static int AktifSube(IstekBaglami baglam)
        => baglam.SubeId is > 0 ? baglam.SubeId.Value : throw GentegreHatasi.Yasak("Aktif şube yok.");

    /// <summary>Tanım dövizlerinin bugünkü kuru; kur yoksa 1 (tutar TL sayılmaz - kurYok işaretlenir).</summary>
    private static async Task<(string Yerel, Func<string, decimal, decimal> Tl)> KurlarAsync(NpgsqlConnection b,
        IEnumerable<string> dovizler, DateTime bugun, CancellationToken iptal)
    {
        var yerel = await b.TekDegerAsync<string>("select public.fn_yerel_para()", null, [], iptal) ?? "TL";
        var liste = dovizler.Where(x => x != yerel && x != "").Distinct().ToArray();
        var kurlar = liste.Length == 0 ? new Dictionary<string, decimal?>()
            : (await b.ListeAsync("""
                select x.c, public.fn_doviz_kur_getir(x.c, @p1::date, 2::smallint) from unnest(@p0::text[]) as x(c)
                """, null, [liste, bugun], o => (c: o.GetString(0), k: o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1)), iptal))
              .ToDictionary(x => x.c, x => x.k);
        return (yerel, (doviz, tutar) => doviz == yerel || doviz == "" ? tutar : R(tutar * (kurlar.GetValueOrDefault(doviz) ?? 1m)));
    }

    /// <summary>Tek tanım: kullanıcının şubelerinden biri değilse 404 (var olmayanla aynı).</summary>
    private static async Task<(Paket P, Tanim T)> TanimAsync(NpgsqlConnection b, NpgsqlTransaction? tx, IstekBaglami baglam,
        int id, DateTime bugun, CancellationToken iptal, bool yazma = false)
    {
        var p = await YukleAsync(b, tx, [id], [], bugun, iptal, kilitle: yazma);
        var t = p.Tanimlar.FirstOrDefault();
        if (t is null || baglam.Subeler.All(s => s.Id != t.SubeId)) throw GentegreHatasi.Bulunamadi("Planlı gider bulunamadı.");
        if (yazma && t.SubeId != baglam.SubeId)
            throw GentegreHatasi.Yasak("Bu tanım başka bir şubenin; değiştirmek için o şubeye geçin.");
        return (p, t);
    }

    /// <summary>Kartın / listenin dönem ufku: bitişe kadar (en az bugün + 24 ay).</summary>
    private static DateTime KartUfku(Tanim t, DateTime bugun)
        => t.Bitis is { } bt && bt > Ufuk(bugun) ? bt : Ufuk(bugun);

    private static (string Durum, int Gun) Durum(PlanliGiderDonemi d, Satir? s, DateTime bugun)
        => PlanliGiderHesap.Durum(d, bugun, s?.BankaBekliyor == true);

    /// <summary>Gecikmiş: geçmiş, eşleşmemiş, atlanmamış ve tanım açıldıktan sonra planlanmış.</summary>
    private static bool Gecikmis(PlanliGiderDonemi d, Tanim t, DateTime bugun)
        => !d.Atlandi && !d.Eslesti && d.PlanTarihi < bugun && d.PlanTarihi >= t.EklemeTarihi.Date;

    private static string ArtisRozeti(IEnumerable<Artis> artislar, DateTime bugun)
    {
        var a = artislar.Where(x => x.Gecerlilik.Date > bugun).OrderBy(x => x.Gecerlilik).FirstOrDefault();
        if (a is null) return "";
        var ne = a.Tur == 1 ? "+%" + a.Deger.ToString("0.##", Tr) : "yeni tutar " + a.Deger.ToString("#,##0.00", Tr);
        return $"{PlanliGiderHesap.AyAdi(a.Gecerlilik.Month)} {a.Gecerlilik.Year}: {ne}";
    }

    public static void PlanliGiderUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/planli-gider").WithTags("Planlı Giderler").RequireAuthorization();

        // ================================================================ LİSTE ===
        grup.MapGet("/", async (string? durum, string? cip, long? kategori, int? hesap, string? ara,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu ekran portalda kullanılamaz.");
            var sube = AktifSube(baglam);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            var p = await YukleAsync(b, null, null, [sube], bugun, iptal);
            var (yerel, tl) = await KurlarAsync(b, p.Tanimlar.Select(t => t.Doviz), bugun, iptal);
            var ayBas = new DateTime(bugun.Year, bugun.Month, 1);
            var aySon = ayBas.AddMonths(1).AddDays(-1);
            var ufuk = bugun.AddMonths(13);

            var hesaplar = new List<(Tanim t, List<PlanliGiderDonemi> d, bool aktif, decimal aylikTl)>();
            foreach (var t in p.Tanimlar)
            {
                var donemler = p.Donemler(t, t.Bitis is { } bt && bt > ufuk ? bt : ufuk);
                var aktif = t.AktifMi(bugun);
                var ref0 = donemler.FirstOrDefault(d => d.PlanTarihi >= bugun && !d.Atlandi) ?? donemler.LastOrDefault();
                var donemTl = tl(t.Doviz, ref0?.Plan ?? PlanliGiderHesap.Nakit(t.Tutar, t.KdvOran, t.StopajOran));
                hesaplar.Add((t, donemler, aktif, aktif ? PlanliGiderHesap.Aylik(t.Periyot, donemTl) : 0));
            }

            // ------------------------------------------------------------ özet --
            var aktifler = hesaplar.Where(x => x.aktif).ToList();
            var aylik = aktifler.Sum(x => x.aylikTl);
            var otuz = aktifler.SelectMany(x => x.d.Where(d => !d.Atlandi && !d.Eslesti && d.PlanTarihi >= bugun
                                                              && d.PlanTarihi <= bugun.AddDays(30))
                .Select(d => (x.t.Ad, tl: tl(x.t.Doviz, d.Plan)))).ToList();
            var enBuyuk = otuz.OrderByDescending(x => x.tl).FirstOrDefault();
            var gecikmis = aktifler.SelectMany(x => x.d.Where(d => Gecikmis(d, x.t, bugun)).Select(d => tl(x.t.Doviz, d.Plan))).ToList();
            var tahminiAylik = aktifler.Where(x => x.t.TutarTur is 2 or 3 or 4).Sum(x => x.aylikTl);
            var buAy = aktifler.Select(x => (x.t, d: x.d.Where(d => !d.Atlandi && d.PlanTarihi >= ayBas && d.PlanTarihi <= aySon).ToList()))
                .Where(x => x.d.Count > 0).ToList();
            var alti = aktifler.SelectMany(x => x.d.Where(d => d.Satir?.Durum is 3 or 4 && d.Satir.EslesenTutar is not null
                                                              && d.PlanTarihi >= bugun.AddMonths(-6) && d.PlanTarihi <= bugun)
                .Select(d => (plan: tl(x.t.Doviz, d.Plan), gercek: tl(x.t.Doviz, d.Satir!.EslesenTutar!.Value)))).ToList();
            var altiPlan = alti.Sum(x => x.plan);
            var ozet = new
            {
                aylik = R(aylik),
                sonraki30 = R(otuz.Sum(x => x.tl)), sonraki30Donem = otuz.Count,
                enBuyuk = otuz.Count == 0 ? null : new { ad = enBuyuk.Ad, tutar = enBuyuk.tl },
                gecikmis = R(gecikmis.Sum()), gecikmisDonem = gecikmis.Count,
                tahminiPay = aylik > 0 ? Math.Round(100m * tahminiAylik / aylik, 0) : 0m,
                buAyPlan = R(buAy.Sum(x => x.d.Sum(d => tl(x.t.Doviz, d.Plan)))),
                buAyOdenen = R(buAy.Sum(x => x.d.Where(d => d.Eslesti && d.Satir!.EslesenTutar is not null)
                    .Sum(d => tl(x.t.Doviz, d.Satir!.EslesenTutar!.Value)))),
                buAyOdenenTanim = buAy.Count(x => x.d.All(d => d.Eslesti)),
                buAyTanim = buAy.Count,
                planGercekFark6Ay = altiPlan > 0 ? Math.Round(100m * (alti.Sum(x => x.gercek) - altiPlan) / altiPlan, 1) : (decimal?)null,
            };

            // ------------------------------------------------------------ süzgeç --
            var dk = durum is "pasif" or "tumu" ? durum : "aktif";
            var aranan = (ara ?? "").Trim();
            bool Uyar((Tanim t, List<PlanliGiderDonemi> d, bool aktif, decimal aylikTl) x)
            {
                if (dk == "aktif" && !x.aktif) return false;
                if (dk == "pasif" && x.aktif) return false;
                if (kategori is > 0 && x.t.KategoriId != kategori) return false;
                if (hesap is > 0 && x.t.OdemeHesapId != hesap) return false;
                if (aranan.Length > 0 && !(x.t.Ad + " " + x.t.Taraf + " " + x.t.ReferansNo + " " + x.t.Masraf + " " + x.t.KategoriAd)
                        .Contains(aranan, StringComparison.CurrentCultureIgnoreCase)) return false;
                return cip switch
                {
                    "buay" => x.d.Any(d => !d.Atlandi && d.PlanTarihi >= ayBas && d.PlanTarihi <= aySon),
                    "gecikmis" => x.d.Any(d => Gecikmis(d, x.t, bugun)),
                    "degisken" => x.t.TutarTur is 2 or 3,
                    "hesaplanan" => x.t.TutarTur == 4,
                    "dovizli" => x.t.Doviz != yerel,
                    "bitiyor" => x.t.Bitis is { } bt && bt.Date >= bugun && bt.Date <= bugun.AddDays(90),
                    _ => true,
                };
            }

            var satirlar = hesaplar.Where(Uyar).Select(x =>
            {
                var t = x.t;
                var sonraki = x.d.FirstOrDefault(d => d.PlanTarihi >= bugun && !d.Atlandi && !d.Eslesti);
                var ref0 = x.d.FirstOrDefault(d => d.PlanTarihi >= bugun && !d.Atlandi) ?? x.d.LastOrDefault();
                var bu = x.d.FirstOrDefault(d => Gecikmis(d, t, bugun))
                         ?? x.d.FirstOrDefault(d => d.PlanTarihi >= ayBas && d.PlanTarihi <= aySon)
                         ?? x.d.LastOrDefault(d => d.PlanTarihi <= bugun);
                object? buDonem = null;
                if (bu is not null)
                {
                    var s = p.Satirlar[t.Id].FirstOrDefault(r => r.Vade.Date == bu.Vade);
                    var (dr, gun) = Durum(bu, s, bugun);
                    var not = dr switch
                    {
                        "faturalandi" => s!.EslesenNo + (s.EslesenVade is { } v ? " · vade " + v.ToString("dd.MM.yyyy") : ""),
                        "beklemede" => "banka hareketi işlenmedi",
                        "atlandi" => s?.Aciklama ?? "",
                        "odendi" or "gec" or "erken" => s?.EslesenNo ?? "",
                        _ => "",
                    };
                    buDonem = new { durum = dr, tarih = T(bu.Eslesti && s?.EslesenTarih is { } et ? et : bu.PlanTarihi), gun, not };
                }
                var tutar = ref0?.Plan ?? PlanliGiderHesap.Nakit(t.Tutar, t.KdvOran, t.StopajOran);
                int? kalan = t.Bitis is not null || t.DonemSayisi is > 0
                    ? x.d.Count(d => d.PlanTarihi >= bugun && !d.Atlandi && !d.Eslesti) : null;
                return new
                {
                    id = t.Id, ad = t.Ad, kategori = t.KategoriAd, kategoriId = t.KategoriId, taraf = t.Taraf, tarafId = t.TarafId,
                    masraf = t.Masraf, periyot = t.Periyot, periyotMetni = PlanliGiderHesap.PeriyotMetni(t.Kural),
                    tutar, tutarTl = tl(t.Doviz, tutar), doviz = t.Doviz,
                    kdvHaric = ref0?.KdvHaric ?? t.Tutar, kdvOran = t.KdvOran, tutarTur = t.TutarTur,
                    tutarTurAdi = t.TutarTur == 4 ? (t.HesapKaynak == "kdv" ? "KDV İcmali'nden" : t.HesapKaynak == "sgk" ? "SGK son 3 ödeme ort." : "Hesaplanan")
                        : t.TutarTur == 2 ? $"Son {t.OrtalamaDonem} dönem ort." : PlanliGiderHesap.TutarTurAdi(t.TutarTur),
                    tahmini = ref0?.Tahmini ?? (t.TutarTur is 2 or 3 or 4),
                    artisRozet = ArtisRozeti(p.Artislar[t.Id], bugun),
                    hesap = t.OdemeHesap, hesapId = t.OdemeHesapId, yontem = PlanliGiderHesap.YontemAdi(t.OdemeYontem),
                    sonraki = T(sonraki?.PlanTarihi), buDonem, durum = x.aktif ? "aktif" : "pasif", bitis = T(t.Bitis), kalanDonem = kalan,
                };
            }).ToList();

            var kategoriler = await b.ListeAsync("""
                select id, ad from public.planli_gider_kategori where aktif = 1 order by sira, ad
                """, null, [], o => new { id = o.GetInt64(0), ad = o.GetString(1) }, iptal);
            var hesapSecim = await b.ListeAsync("""
                select h.id, h.ad, h.tur from public.hesap h
                 where h.tur in ('K', 'B', 'V') and coalesce(h.durum, 1) = 1 and (h.sube_id is null or h.sube_id = 0 or h.sube_id = @p0)
                 order by h.tur, h.ad
                """, null, [sube], o => new { id = o.GetInt32(0), ad = o.GetString(1), tur = o.GetString(2) }, iptal);

            return Results.Ok(new
            {
                ozet, satirlar,
                toplam = new { aylik = R(aylik), aktif = aktifler.Count, pasif = hesaplar.Count - aktifler.Count },
                secim = new { kategoriler, hesaplar = hesapSecim },
                yetkiler = Yetkiler(baglam),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // =============================================================== TAKVİM ===
        grup.MapGet("/takvim", async (int? ay, string? gorunum, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
                                      CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var sube = AktifSube(baglam);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var n = ay is >= 1 and <= 24 ? ay.Value : 12;
            var hesapGorunum = gorunum == "hesap";
            await using var b = await veri.AcAsync(iptal);
            var p = await YukleAsync(b, null, null, [sube], bugun, iptal);
            var (_, tl) = await KurlarAsync(b, p.Tanimlar.Select(t => t.Doviz), bugun, iptal);
            var bas = new DateTime(bugun.Year, bugun.Month, 1);
            var son = bas.AddMonths(n).AddDays(-1);
            var aylar = Enumerable.Range(0, n).Select(i => bas.AddMonths(i)).ToList();
            var kolonlar = new Dictionary<string, string>();
            var hucre = aylar.Select(_ => new Dictionary<string, decimal>()).ToList();
            var sabit = new decimal[n]; var tahmini = new decimal[n]; var hesaplanan = new decimal[n];
            // Kolon sırası: kategori sırası / hesap adı.
            var kategoriSira = await b.ListeAsync("select kod, sira from public.planli_gider_kategori", null, [],
                o => (kod: o.GetString(0), sira: (int)o.GetInt16(1)), iptal);
            var sira = kategoriSira.ToDictionary(x => x.kod, x => x.sira);
            foreach (var t in p.Tanimlar.Where(t => t.AktifMi(bugun) || (t.Durum == 1 && t.Bitis >= bas)))
            {
                var anahtar = hesapGorunum ? (t.OdemeHesapId?.ToString(CultureInfo.InvariantCulture) ?? "") : t.KategoriKod;
                var ad = hesapGorunum ? (t.OdemeHesap.Length > 0 ? t.OdemeHesap : "Hesapsız") : (t.KategoriAd.Length > 0 ? t.KategoriAd : "Kategorisiz");
                foreach (var d in p.Donemler(t, son).Where(d => !d.Atlandi && d.PlanTarihi >= bas && d.PlanTarihi <= son))
                {
                    var i = (d.PlanTarihi.Year - bas.Year) * 12 + d.PlanTarihi.Month - bas.Month;
                    if (i < 0 || i >= n) continue;
                    var v = tl(t.Doviz, d.Plan);
                    kolonlar.TryAdd(anahtar, ad);
                    hucre[i][anahtar] = hucre[i].GetValueOrDefault(anahtar) + v;
                    if (t.TutarTur == 4) hesaplanan[i] += v; else if (t.TutarTur is 2 or 3) tahmini[i] += v; else sabit[i] += v;
                }
            }
            var kolonListe = kolonlar.OrderBy(k => hesapGorunum ? 0 : sira.GetValueOrDefault(k.Key, 999)).ThenBy(k => k.Value, StringComparer.Create(Tr, true))
                .Select(k => new { anahtar = k.Key, ad = k.Value }).ToList();
            return Results.Ok(new
            {
                aylar = aylar.Select((a, i) => new
                {
                    ay = a.ToString("yyyy-MM", CultureInfo.InvariantCulture),
                    toplam = R(sabit[i] + tahmini[i] + hesaplanan[i]), sabit = R(sabit[i]), tahmini = R(tahmini[i]), hesaplanan = R(hesaplanan[i]),
                    kirilim = hucre[i].ToDictionary(x => x.Key, x => R(x.Value)),
                }).ToList(),
                kolonlar = kolonListe,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // =========================================================== KATEGORİLER ===
        grup.MapGet("/kategoriler", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await KategorilerAsync(b, null, null, iptal));
        });

        // ================================================================= KART ===
        grup.MapGet("/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu ekran portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await KartYanitiAsync(b, null, baglam, id, iptal));
        });

        YazmaUclariniEkle(grup);
        DonemUclariniEkle(grup);
    }

    private static object Yetkiler(IstekBaglami baglam) => new
    {
        ekle = baglam.Yetkiler.Var(Kod, Islem.Ekle) && baglam.SubeYazma,
        degistir = baglam.Yetkiler.Var(Kod, Islem.Degistir) && baglam.SubeYazma,
        sil = baglam.Yetkiler.Var(Kod, Islem.Sil) && baglam.SubeYazma,
        odeme = baglam.Yetkiler.Var("kasa_islem", Islem.Ekle) && baglam.SubeYazma,
    };

    private static async Task<List<object>> KategorilerAsync(NpgsqlConnection b, NpgsqlTransaction? tx, long? dahil,
        CancellationToken iptal)
        => await b.ListeAsync("""
            select k.id, k.kod, k.ad, k.masraf_id, coalesce(nullif(concat_ws(' · ', nullif(m.kod, ''), m.ad), ''), ''),
                   k.tutar_tur::int, k.hesap_kaynak, k.tatil_kural::int, k.hatirlatma_gun::int
              from public.planli_gider_kategori k left join public.masraf m on m.id = k.masraf_id
             where k.aktif = 1 or k.id = @p0
             order by k.sira, k.ad
            """, tx, [dahil ?? 0L], o => (object)new
            {
                id = o.GetInt64(0), kod = o.GetString(1), ad = o.GetString(2), masrafId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                masraf = o.GetString(4), tutarTur = o.GetInt32(5), hesapKaynak = o.GetString(6), tatilKural = o.GetInt32(7),
                hatirlatmaGun = o.GetInt32(8),
            }, iptal);

    /// <summary>Kart yanıtı (GET ve 409'un güncel hâli). id 0 = yeni kayıt varsayılanları.</summary>
    private static async Task<object> KartYanitiAsync(NpgsqlConnection b, NpgsqlTransaction? tx, IstekBaglami baglam, int id,
        CancellationToken iptal)
    {
        var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
        var yetkiler = new
        {
            degistir = baglam.Yetkiler.Var(Kod, id == 0 ? Islem.Ekle : Islem.Degistir) && baglam.SubeYazma,
            sil = id != 0 && baglam.Yetkiler.Var(Kod, Islem.Sil) && baglam.SubeYazma,
            odeme = id != 0 && baglam.Yetkiler.Var("kasa_islem", Islem.Ekle) && baglam.SubeYazma,
        };
        if (id == 0)
        {
            return new
            {
                kart = new
                {
                    id = 0, ad = "", kategoriId = (long?)null, durum = 1, tarafId = (int?)null, taraf = "", masrafId = (int?)null, masraf = "",
                    masrafMerkeziId = (int?)null, masrafMerkezi = "", sorumluId = (int?)baglam.KullaniciId, sorumlu = "", referansNo = "", aciklama = "",
                    tutarTur = 1, ortalamaDonem = 3, hesapKaynak = "", tutar = 0m, doviz = "TL", kdvOran = 0m, stopajOran = 0m,
                    periyot = 2, odemeGunu = 1, tatilKural = 2, baslangic = T(bugun), bitis = (string?)null, donemSayisi = (int?)null,
                    hatirlatmaGun = 0, odemeHesapId = (int?)null, odemeHesap = "", odemeYontem = 1, karsiIban = "", odemeAciklama = "",
                    eslesGun = 7, eslesYuzde = 5m, eslesOtomatik = 1, subeId = baglam.SubeId, sube = baglam.AktifSube?.Ad ?? "", ekleyen = 0, ekleyenAd = "",
                    eklemeTarihi = (string?)null, degistirmeTarihi = (string?)null, surum = "",
                },
                artislar = Array.Empty<object>(),
                ozet = (object?)null,
                donemler = Array.Empty<object>(),
                onizleme = new { tutarlar = Array.Empty<object>(), tarihler = Array.Empty<object>() },
                kategoriler = await KategorilerAsync(b, tx, null, iptal),
                uyarilar = Array.Empty<object>(),
                zaman = Array.Empty<object>(),
                yetkiler, izlemeNo = baglam.IzlemeNo,
            };
        }

        var (p, t) = await TanimAsync(b, tx, baglam, id, bugun, iptal);
        var donemler = p.Donemler(t, KartUfku(t, bugun));
        var satirlar = p.SatirSozlugu(t.Id);
        var artislar = p.Artislar[t.Id].OrderBy(a => a.Gecerlilik).ToList();
        Satir? S(PlanliGiderDonemi d) => satirlar.GetValueOrDefault(d.Vade);
        var sinirli = t.Bitis is not null || t.DonemSayisi is > 0;

        // ------------------------------------------------------------- dönemler --
        var donemListe = donemler.Select(d =>
        {
            var s = S(d);
            var (dr, gun) = Durum(d, s, bugun);
            decimal? gercek = d.Eslesti ? s!.EslesenTutar : null;
            return new
            {
                vade = T(d.Vade), planTarihi = T(d.PlanTarihi), kaydirildi = d.Kaydirildi, kaydirmaNedeni = d.KaydirmaNedeni,
                plan = d.Plan, gercek, fark = gercek is { } g ? R(g - d.Plan) : (decimal?)null,
                odemeTarihi = d.Eslesti ? T(s!.EslesenTarih) : null,
                eslesen = d.Eslesti && s!.EslesenId is { } eid ? new
                {
                    tur = s.EslesenTur, id = eid, no = s.EslesenNo,
                    metin = s.EslesenTur == "fatura" && s.EslesenVade is { } v ? "vade " + v.ToString("dd.MM.yyyy")
                          : s.BankaBekliyor ? "banka hareketi işlenmedi" : s.Otomatik == 1 ? "otomatik" : "elle",
                } : null,
                otomatik = s?.Otomatik == 1, durum = dr, gun, elleTutar = s?.ElleTutar, aciklama = s?.Aciklama ?? "",
                dondurulmus = d.Dondurulmus,
            };
        }).ToList();

        // ---------------------------------------------------------------- özet --
        var sonraki = donemler.FirstOrDefault(d => d.PlanTarihi >= bugun && !d.Atlandi && !d.Eslesti);
        var ref0 = sonraki ?? donemler.LastOrDefault(d => !d.Atlandi);
        var buYil = donemler.Where(d => !d.Atlandi && d.PlanTarihi.Year == bugun.Year && d.PlanTarihi <= bugun).ToList();
        var odenen = donemler.Where(d => d.Satir?.Durum == 3 && d.Satir.EslesenTutar is not null && S(d)?.BankaBekliyor != true).ToList();
        var gecikmeler = odenen.Select(d => Math.Max(0, ((d.Satir!.EslesenTarih ?? d.PlanTarihi).Date - d.PlanTarihi).Days)).ToList();
        var yirmiIki = donemler.Where(d => d.Eslesti && d.Satir!.EslesenTutar is not null
                                           && d.PlanTarihi >= bugun.AddMonths(-12) && d.PlanTarihi <= bugun).ToList();
        var gelecek = donemler.Where(d => d.PlanTarihi >= bugun && !d.Atlandi && !d.Eslesti).ToList();
        var ozet = new
        {
            donemTutari = ref0?.Plan ?? 0m, kdvHaric = ref0?.KdvHaric ?? t.Tutar, kdv = ref0?.Kdv ?? 0m, stopaj = ref0?.Stopaj ?? 0m,
            sonraki = sonraki is null ? null : new
            {
                tarih = T(sonraki.PlanTarihi), gun = (sonraki.PlanTarihi - bugun).Days, gunAdi = PlanliGiderHesap.GunAdi(sonraki.PlanTarihi),
            },
            buYilOdenen = R(buYil.Where(d => d.Eslesti).Sum(d => d.Satir!.EslesenTutar ?? 0)),
            buYilPlan = R(buYil.Sum(d => d.Plan)),
            buYilDonem = buYil.Count, buYilOdenenDonem = buYil.Count(d => d.Eslesti),
            kalanTaahhut = sinirli ? R(gelecek.Sum(d => d.Plan)) : (decimal?)null,
            kalanDonem = sinirli ? gelecek.Count : (int?)null,
            toplamDonem = sinirli ? donemler.Count(d => !d.Atlandi) : (int?)null,
            zamanindaOran = gecikmeler.Count > 0 ? Math.Round(100m * gecikmeler.Count(g => g == 0) / gecikmeler.Count, 0) : (decimal?)null,
            ortGecikme = gecikmeler.Count > 0 ? Math.Round((decimal)gecikmeler.Average(), 1) : (decimal?)null,
            planGercekFark12 = yirmiIki.Count > 0 ? R(yirmiIki.Sum(d => d.Satir!.EslesenTutar!.Value - d.Plan)) : (decimal?)null,
        };

        // ------------------------------------------------------------ önizleme --
        var onizleme = new
        {
            tutarlar = gelecek.Take(12).Select(d => new { vade = T(d.Vade), tutar = d.Plan, artis = d.Artis }).ToList(),
            tarihler = gelecek.Take(8).Select(d => new { tarih = T(d.PlanTarihi), kaydirildi = d.Kaydirildi, neden = d.KaydirmaNedeni }).ToList(),
        };

        // ------------------------------------------------------------- uyarılar --
        var uyarilar = new List<object>();
        var gec = donemler.Where(d => Gecikmis(d, t, bugun)).ToList();
        if (gec.Count > 0)
            uyarilar.Add(new { seviye = "kir", metin = $"{gec.Count} dönem gecikti, eşleşen ödeme yok: "
                + string.Join(", ", gec.Take(4).Select(d => DonemAdi(d.Vade))) + (gec.Count > 4 ? "…" : "") + "." });
        if (t.Bitis is { } bt)
        {
            if (bt.Date < bugun)
                uyarilar.Add(new { seviye = "mavi", metin = $"Bitiş tarihi {bt:dd.MM.yyyy} geçti: tanım pasif sayılır, Nakit Akış İcmali'nde görünmez." });
            else if ((bt.Date - bugun).Days <= 90)
                uyarilar.Add(new { seviye = "sari", metin = $"Sözleşme {bt:dd.MM.yyyy}'de bitiyor ({gelecek.Count} dönem kaldı). Yenilemek için kartı kopyalayın." });
        }
        if (t.TarafId is null && t.KategoriKod != "vergi_sgk")
            uyarilar.Add(new { seviye = "sari", metin = "Ödenecek yer (tedarikçi) seçilmemiş." });
        if (t.OdemeHesapId is null)
            uyarilar.Add(new { seviye = "sari", metin = "Ödeme hesabı seçilmemiş: Ödeme Oluştur ve banka hareketi eşleşmesi çalışmaz." });
        if (donemler.Any(d => S(d)?.BankaBekliyor == true))
            uyarilar.Add(new { seviye = "mavi", metin = "İşlenmemiş banka hareketiyle eşleşen dönem beklemede: Banka Hareketleri'nde işlenince eşleşme kesinleşir." });
        if (t.TutarTur is 2 or 3 && !donemler.Any(d => d.Eslesti))
            uyarilar.Add(new { seviye = "mavi", metin = "Henüz gerçekleşen ödeme yok: tahmin tanımdaki tutardan." });
        if (t.TutarTur == 4 && t.HesapKaynak == "kdv")
        {
            var ga = new DateTime(bugun.Year, bugun.Month, 1).AddMonths(-1);
            uyarilar.Add(new { seviye = "mavi", metin = $"KDV İcmali {DonemAdi(ga)} ödenecek KDV: {p.Kdv.GetValueOrDefault(t.SubeId).ToString("#,##0.00", Tr)} (sonraki aylara aynı tutar, tahmini)." });
        }
        var gelecekArtis = artislar.FirstOrDefault(a => a.Gecerlilik.Date > bugun);
        if (gelecekArtis is not null)
            uyarilar.Add(new { seviye = "mavi", metin = $"{gelecekArtis.Gecerlilik:dd.MM.yyyy} tarihinden itibaren artış: {ArtisRozeti([gelecekArtis], bugun)}." });

        // --------------------------------------------------------- zaman çizgisi --
        var zaman = new List<(DateTime tarih, string metin, string tur)>();
        foreach (var d in donemler.Where(d => d.Eslesti))
        {
            var s = S(d)!;
            var (dr, gun) = Durum(d, s, bugun);
            var ay = PlanliGiderHesap.AyAdi(d.Vade.Month) + " " + d.Vade.Year;
            var metin = dr switch
            {
                "faturalandi" => $"{ay} faturalandı · {s.EslesenNo}",
                "beklemede" => $"{ay} banka hareketiyle eşleşti (beklemede)",
                "gec" => $"{ay} geç ödendi (+{gun} gün)",
                "erken" => $"{ay} ödendi (erken)",
                _ => $"{ay} ödendi",
            } + (s.Otomatik == 1 ? " · otomatik eşleşme" : " · elle");
            zaman.Add((s.EslesenTarih ?? d.PlanTarihi, metin, dr == "gec" ? "kir" : "ok"));
        }
        foreach (var d in gec) zaman.Add((d.PlanTarihi, $"{DonemAdi(d.Vade)} gecikti", "kir"));
        foreach (var d in donemler.Where(d => d.Atlandi)) zaman.Add((d.PlanTarihi, $"{DonemAdi(d.Vade)} atlandı", ""));
        foreach (var a in artislar.Where(a => a.Gecerlilik.Date <= bugun))
            zaman.Add((a.Gecerlilik, "Artış uygulandı: " + (a.Tur == 1 ? "%" + a.Deger.ToString("0.##", Tr) : "yeni tutar " + a.Deger.ToString("#,##0.00", Tr)), ""));
        zaman.Add((t.EklemeTarihi, "Tanım oluşturuldu", ""));

        // ------------------------------------------------------------- artışlar --
        decimal h = t.Tutar;
        var artisListe = artislar.Select(a =>
        {
            h = a.Tur == 2 ? R(a.Deger) : R(h * (1m + a.Deger / 100m));
            return new { id = a.Id, gecerlilik = T(a.Gecerlilik), tur = a.Tur, deger = a.Deger, aciklama = a.Aciklama,
                         yeniKdvHaric = h, uygulandi = a.Gecerlilik.Date <= bugun };
        }).ToList();

        return new
        {
            kart = KartAlanlari(t),
            surum = t.Surum,
            artislar = artisListe, ozet, donemler = donemListe, onizleme,
            kategoriler = await KategorilerAsync(b, tx, t.KategoriId, iptal),
            uyarilar,
            zaman = zaman.OrderByDescending(z => z.tarih).Take(12).Select(z => new { tarih = T(z.tarih), z.metin, z.tur }).ToList(),
            yetkiler = new
            {
                yetkiler.degistir, sil = yetkiler.sil && !donemler.Any(d => d.Eslesti),
                yetkiler.odeme,
            },
            izlemeNo = baglam.IzlemeNo,
        };
    }

    private static object KartAlanlari(Tanim t) => new
    {
        id = t.Id, ad = t.Ad, kategoriId = t.KategoriId, durum = t.Durum, tarafId = t.TarafId, taraf = t.Taraf,
        masrafId = t.MasrafId, masraf = t.Masraf, masrafMerkeziId = t.MasrafMerkeziId, masrafMerkezi = t.MasrafMerkezi, sorumluId = t.SorumluId, sorumlu = t.Sorumlu,
        referansNo = t.ReferansNo, aciklama = t.Aciklama, tutarTur = t.TutarTur, ortalamaDonem = t.OrtalamaDonem,
        hesapKaynak = t.HesapKaynak, tutar = t.Tutar, doviz = t.Doviz, kdvOran = t.KdvOran, stopajOran = t.StopajOran,
        periyot = t.Periyot, odemeGunu = t.OdemeGunu, tatilKural = t.TatilKural, baslangic = T(t.Baslangic), bitis = T(t.Bitis),
        donemSayisi = t.DonemSayisi, hatirlatmaGun = t.HatirlatmaGun, odemeHesapId = t.OdemeHesapId, odemeHesap = t.OdemeHesap, odemeYontem = t.OdemeYontem,
        karsiIban = t.KarsiIban, odemeAciklama = t.OdemeAciklama, eslesGun = t.EslesGun, eslesYuzde = t.EslesYuzde,
        eslesOtomatik = t.EslesOtomatik, subeId = t.SubeId, sube = t.Sube, ekleyen = t.Ekleyen, ekleyenAd = t.EkleyenAd,
        eklemeTarihi = T(t.EklemeTarihi), degistirmeTarihi = T(t.DegistirmeTarihi is { } dt ? Saat.Gun(dt) : null), surum = t.Surum,
    };
}
