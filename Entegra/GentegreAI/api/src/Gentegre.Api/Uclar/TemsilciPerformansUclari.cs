using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEMSİLCİ PERFORMANS İCMALİ `/api/temsilci-performans` (mockup Ekranlar/İcmal/temsilci_performans_icmali.html,
/// kullanıcı 25.10.2026, göç 1186). "Hangi temsilci hedefinde, kim kârlı satıyor, kimin müşterisi ödemiyor, prim ne
/// çıkıyor?"
///
/// <para><b>Temsilci (karar 25.10.2026):</b> FATURADAN - belge.satici_id. Cari başka temsilciye geçse de eski faturalar
/// eski temsilcide kalır. Faturada temsilci yoksa "(temsilcisiz)" satırı (id -1): toplama girer, prime / hedefe girmez.</para>
///
/// <para><b>Ciro / brüt kâr / tahsil edilen:</b> Kârlılık İcmali'nin kuralı (<see cref="KarlilikIcmalUclari.BelgeKarlariAsync"/>):
/// kesin satış faturası / fişi, KDV hariç dip toplam, satış anı maliyeti; tahsil edilen = dönem faturalarının KDV dahil
/// tutarından FIFO'da açık kalmayan kısım. İkinci hesap yok.</para>
///
/// <para><b>Müşterinin temsilcisi</b> (portföy, tahsilat kalitesi): son 12 ayın faturalarında en çok ciroyu yapan
/// temsilci; 12 ayda satış yoksa önceki 12 ayın. Vadesi geçen / 90+ Cari İcmali'nin yaşlandırması (FIFO), ödeme
/// süresi ve skor Müşteri Risk İcmali'nin ödeme davranışı sorgusu ve skor kuralı.</para>
///
/// <para><b>Hedef:</b> temsilci_hedef (temsilci × ay × ölçüt: 1 ciro · 2 brüt kâr · 3 tahsilat · 4 yeni müşteri); dönemin
/// aylarının toplamı. Ay sonu tahmini: dönem bugünü içeriyorsa gerçekleşen × dönem günü / geçen gün (doğrusal).</para>
///
/// <para><b>Aktivite:</b> görev kayıtları (sorumlu = temsilci): 3 görüşme / aktivite, 4 toplantı, 1 / 9 görev. Teklif: tür 18,
/// iptal hariç. <b>Prim:</b> Prim Planı motorunun yazdığı hakediş satırları (hakedis_satir) - icmal hesaplamaz, gösterir.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı, cari kayıt kapsamı uygulanır.
/// </summary>
public static class TemsilciPerformansUclari
{
    /// <summary>Ekran kodu (1186) - hakları Kârlılık İcmali'nden (yalnız Gör).</summary>
    private const string Kod = "satis.temsilci_performans";

    /// <summary>Hedef tanımlama aksiyonu (1186) - hakları prim.plan Değiştir'den.</summary>
    private const string AksiyonHedef = "satis.temsilci_hedef";

    /// <summary>islem_log.tablo_id - temsilci_hedef (yeni numara, 1186).</summary>
    private const int LogTabloHedef = 1762;

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    private static readonly Dictionary<int, string> OlcutAdlari = new()
    {
        [1] = "Ciro", [2] = "Brüt kâr", [3] = "Tahsilat", [4] = "Yeni müşteri",
    };

    public sealed record HedefIstegi(int TemsilciId, DateTime Donem, short Olcut, decimal? Hedef);

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal? Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : null;

    /// <summary>Temsilcinin dönem toplamı (iade "düşülsün" seçiliyse net ve maliyetten çıkar).</summary>
    private sealed class Top
    {
        public decimal Brut, Isk, Net, Mal, Tahsil;
        public readonly HashSet<int> Musteri = [];

        public void Ekle(KarlilikIcmalUclari.BelgeKari k, bool iadeDus)
        {
            if (k.Iade)
            {
                if (!iadeDus) return;
                Net -= k.Net; Mal -= k.Maliyet;
                return;
            }
            Brut += k.Brut; Isk += k.Isk; Net += k.Net; Mal += k.Maliyet; Tahsil += k.Tahsil;
            if (k.TarafId > 0) Musteri.Add(k.TarafId);
        }

        public decimal Kar => Net - Mal;
    }

    private static (DateTime bas, DateTime bit) DonemCoz(string? kip, DateTime? tarih, DateTime bugun)
    {
        var t = (tarih ?? bugun).Date;
        return kip switch
        {
            "yil" => (new DateTime(t.Year, 1, 1), new DateTime(t.Year, 12, 31)),
            "ceyrek" => (new DateTime(t.Year, (t.Month - 1) / 3 * 3 + 1, 1), new DateTime(t.Year, (t.Month - 1) / 3 * 3 + 1, 1).AddMonths(3).AddDays(-1)),
            _ => (new DateTime(t.Year, t.Month, 1), new DateTime(t.Year, t.Month, 1).AddMonths(1).AddDays(-1)),
        };
    }

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    // ================================================================ sorgular ===

    /// <summary>Carinin ilk satışı (kesin satış faturası / fişi, iade hariç) ve o faturanın temsilcisi. @p0 şubeler.</summary>
    private const string IlkSatisSorgusu = """
        select distinct on (b.taraf_id) b.taraf_id, b.belge_tarihi::date, coalesce(b.satici_id, 0)
          from public.belge b
         where b.tur in (15, 16) and b.durum = 0 and coalesce(b.tipi, 0) <> 2 and coalesce(b.taraf_id, 0) > 0
           and (b.sube_id is null or b.sube_id = any(@p0::int[]))
         order by b.taraf_id, b.belge_tarihi, b.id
        """;

    /// <summary>Teklif sayısı (tür 18, iptal hariç) temsilci başına. @p0 bas · @p1 bit · @p2 şubeler · @p3 şube.</summary>
    private const string TeklifSorgusu = """
        select coalesce(b.satici_id, 0), count(*)::int
          from public.belge b
         where b.tur = 18 and b.durum <> 2 and coalesce(b.teklif_durum, 1) <> 5
           and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
           and (b.sube_id is null or b.sube_id = any(@p2::int[])) and (@p3 = 0 or b.sube_id = @p3)
         group by 1
        """;

    /// <summary>Görev / aktivite (sorumlu = temsilci). Dönemdekiler türüne göre; açık ve geciken bugün itibarıyla.
    ///   @p0 bas · @p1 bit · @p2 şubeler · @p3 şube.</summary>
    private const string AktiviteSorgusu = """
        select g.sorumlu_id,
               count(*) filter (where g.tur = 3 and coalesce(g.baslangic, g.ekleme_tarihi) >= @p0::date
                                and coalesce(g.baslangic, g.ekleme_tarihi) < @p1::date + 1)::int,
               count(*) filter (where g.tur = 4 and coalesce(g.baslangic, g.ekleme_tarihi) >= @p0::date
                                and coalesce(g.baslangic, g.ekleme_tarihi) < @p1::date + 1)::int,
               count(*) filter (where g.tur in (1, 9) and coalesce(g.baslangic, g.ekleme_tarihi) >= @p0::date
                                and coalesce(g.baslangic, g.ekleme_tarihi) < @p1::date + 1)::int,
               count(*) filter (where g.durum in (0, 1) and g.tur <> 2)::int,
               count(*) filter (where g.durum in (0, 1) and g.tur <> 2 and g.termin < now())::int
          from public.gorev g
         where coalesce(g.sorumlu_id, 0) > 0
           and (g.sube_id is null or g.sube_id = any(@p2::int[])) and (@p3 = 0 or g.sube_id = @p3)
         group by g.sorumlu_id
        """;

    /// <summary>Prim Planı hakediş satırları (iptal hariç) dönemde, kişi başına durumlara göre. @p0 bas · @p1 bit.</summary>
    private const string PrimSorgusu = """
        select hs.taraf_id,
               coalesce(string_agg(distinct p.ad, ', '), '')::varchar(300),
               coalesce(sum(hs.tutar) filter (where hs.durum = 1), 0),
               coalesce(sum(hs.tutar) filter (where hs.durum = 2), 0),
               coalesce(sum(hs.tutar) filter (where hs.durum = 3), 0),
               coalesce(sum(hs.tutar) filter (where hs.durum = 4), 0),
               coalesce(sum(hs.tutar), 0)
          from public.hakedis_satir hs
          left join public.prim_plani p on p.id = hs.plan_id
         where hs.durum <> 0 and hs.tarih >= @p0::date and hs.tarih < @p1::date + 1
         group by hs.taraf_id
        """;

    /// <summary>Temsilci adları (temsilci = taraf). @p0 id'ler.</summary>
    private const string AdSorgusu = """
        select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '')::varchar(160)
          from public.taraf t where t.id = any(@p0::int[])
        """;

    // ================================================================== uçlar ===

    public static void TemsilciPerformansUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/temsilci-performans").WithTags("Temsilci Performans İcmali").RequireAuthorization();

        grup.MapGet("/", async (string? kip, DateTime? tarih, int? sube, int? iade,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var k = kip is "ceyrek" or "yil" ? kip : "ay";
            var (bas, bit) = DonemCoz(k, tarih, bugun);
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var iadeDus = (iade ?? 1) == 1;

            await using var b = await veri.AcAsync(iptal);

            // TEK OKUMA: dönem + gidişat (6 ay + geçen yılın aynı ayı) + portföy (24 ay).
            var bitAy = new DateTime(bit.Year, bit.Month, 1);
            var ref12 = (bit < bugun ? bit : bugun);                                // portföy "bugün"ü: dönem sonu ya da bugün
            var gBas = new[] { bas, bitAy.AddMonths(-12), ref12.AddDays(-730) }.Min();
            var belgeler = await KarlilikIcmalUclari.BelgeKarlariAsync(b, gBas, bit, subeler, s0, kapsam, iptal);
            var donem = belgeler.Where(x => x.Tarih >= bas && x.Tarih <= bit).ToList();

            // ------------------------------------------------- temsilci satırları --
            int Tid(int satici) => satici > 0 ? satici : -1;
            var tops = new Dictionary<int, Top>();
            Top TopAl(int id) => tops.TryGetValue(id, out var t) ? t : tops[id] = new Top();
            foreach (var x in donem) TopAl(Tid(x.SaticiId)).Ekle(x, iadeDus);

            var hedefSatirlari = await b.ListeAsync("""
                select h.temsilci_id, h.olcut::int, sum(h.hedef)
                  from public.temsilci_hedef h
                 where h.donem >= @p0::date and h.donem <= @p1::date
                 group by 1, 2
                """, null, [new DateTime(bas.Year, bas.Month, 1), bit], o => (id: o.GetInt32(0), olcut: o.GetInt32(1), hedef: o.GetDecimal(2)), iptal);
            foreach (var h in hedefSatirlari) TopAl(h.id);

            // Yeni müşteri: ilk satışı dönemde olan cari, o ilk faturanın temsilcisine.
            var ilkSatis = await b.ListeAsync(IlkSatisSorgusu, null, [subeler],
                o => (taraf: o.GetInt32(0), tarih: o.GetDateTime(1).Date, satici: o.GetInt32(2)), iptal);
            var kapsamKume = kapsam.ToHashSet();
            var yeniler = ilkSatis.Where(x => x.tarih >= bas && x.tarih <= bit && (kapsamKume.Count == 0 || kapsamKume.Contains(x.taraf)))
                .GroupBy(x => Tid(x.satici)).ToDictionary(g => g.Key, g => g.Count());

            var teklifler = (await b.ListeAsync(TeklifSorgusu, null, [bas, bit, subeler, s0],
                o => (id: o.GetInt32(0), n: o.GetInt32(1)), iptal)).ToDictionary(x => Tid(x.id), x => x.n);

            // Müşterinin temsilcisi: son 12 ayın en çok ciro yapanı; yoksa önceki 12 ayın.
            var son12 = belgeler.Where(x => !x.Iade && x.TarafId > 0 && x.Tarih > ref12.AddDays(-365) && x.Tarih <= ref12).ToList();
            var once12 = belgeler.Where(x => !x.Iade && x.TarafId > 0 && x.Tarih > ref12.AddDays(-730) && x.Tarih <= ref12.AddDays(-365)).ToList();
            static Dictionary<int, int> Baskin(IEnumerable<KarlilikIcmalUclari.BelgeKari> l, Func<int, int> tid)
                => l.GroupBy(x => x.TarafId).ToDictionary(g => g.Key,
                    g => tid(g.GroupBy(x => x.SaticiId).OrderByDescending(s => s.Sum(x => x.Net)).First().Key));
            var cariTemsilci = Baskin(once12, Tid);
            foreach (var (c, t) in Baskin(son12, Tid)) cariTemsilci[c] = t;

            // Cari İcmali satırları (yaşlandırma, limit) ve ödeme davranışı (Müşteri Risk İcmali'nin sorguları).
            var yilOnce = bugun.AddYears(-1);
            object?[] p = [yilOnce, bugun, 1, 0, kapsam, 1];
            var carilar = (await CariIcmalUclari.CarilarAsync(b, p, iptal)).ToDictionary(c => c.Id);
            var odeme = (await b.ListeAsync(MusteriRiskIcmalUclari.OdemeSorgusu, null, [.. p, yilOnce], o =>
            {
                decimal? D(int i) => o.IsDBNull(i) ? null : o.GetDecimal(i);
                return (id: o.GetInt32(0), fatura: o.GetInt32(1), ortOdeme: D(3), gecikme: D(4), zamaninda: D(5));
            }, iptal)).ToDictionary(x => x.id);
            var atananlar = cariTemsilci.Keys.ToArray();
            var karsiliksiz = atananlar.Length == 0 ? new Dictionary<int, int>()
                : (await b.ListeAsync(MusteriRiskIcmalUclari.KarsiliksizSorgusu, null, [atananlar, bugun, subeler],
                    o => (id: o.GetInt32(0), son12: o.GetInt32(2)), iptal)).ToDictionary(x => x.id, x => x.son12);
            foreach (var t in cariTemsilci.Values.Distinct()) TopAl(t);

            var adlar = (await b.ListeAsync(AdSorgusu, null, [tops.Keys.Where(x => x > 0).ToArray()],
                o => (id: o.GetInt32(0), ad: o.GetString(1)), iptal)).ToDictionary(x => x.id, x => x.ad);
            string Ad(int id) => id == -1 ? "(temsilcisiz)" : adlar.GetValueOrDefault(id, $"#{id}");

            var aktiviteler = (await b.ListeAsync(AktiviteSorgusu, null, [bas, bit, subeler, s0], o => (
                id: o.GetInt32(0), gorusme: o.GetInt32(1), toplanti: o.GetInt32(2), gorev: o.GetInt32(3),
                acik: o.GetInt32(4), geciken: o.GetInt32(5)), iptal)).ToDictionary(x => x.id);

            // ------------------------------------------------------------ hedef --
            var gecenGun = bugun >= bas && bugun <= bit ? (bugun - bas).Days + 1 : 0;
            var toplamGun = (bit - bas).Days + 1;
            decimal Gercek(int id, int olcut) => olcut switch
            {
                1 => R(TopAl(id).Net), 2 => R(TopAl(id).Kar), 3 => R(TopAl(id).Tahsil), _ => yeniler.GetValueOrDefault(id),
            };
            decimal? Tahmin(decimal g, int olcut) => gecenGun > 0
                ? (olcut == 4 ? Math.Round(g * toplamGun / gecenGun, 0) : R(g * toplamGun / gecenGun)) : null;
            var hedefler = hedefSatirlari.Where(h => h.id > 0).Select(h =>
            {
                var g = Gercek(h.id, h.olcut);
                return new
                {
                    temsilciId = h.id, temsilci = Ad(h.id), olcut = h.olcut, olcutAdi = OlcutAdlari.GetValueOrDefault(h.olcut, ""),
                    hedef = R(h.hedef), gerceklesen = g, oran = Yuzde(g, h.hedef), kalan = R(Math.Max(0, h.hedef - g)),
                    tahmin = Tahmin(g, h.olcut),
                };
            }).OrderBy(x => x.temsilci, StringComparer.Create(Tr, true)).ThenBy(x => x.olcut).ToList();
            var ciroHedef = hedefSatirlari.Where(h => h.olcut == 1).ToDictionary(h => h.id, h => h.hedef);

            // ------------------------------------------------------------- özet --
            var temsilciler = tops.Select(kv =>
            {
                var t = kv.Value;
                var musteriler = donem.Where(x => Tid(x.SaticiId) == kv.Key && x.TarafId > 0).GroupBy(x => x.TarafId).Select(g =>
                {
                    var c = new Top(); foreach (var x in g) c.Ekle(x, iadeDus);
                    return new { id = g.Key, ad = g.First().Cari, net = R(c.Net), kar = R(c.Kar) };
                }).OrderByDescending(x => x.net).Take(8).ToList();
                decimal? hc = ciroHedef.TryGetValue(kv.Key, out var hv) ? hv : null;
                return new
                {
                    id = kv.Key, ad = Ad(kv.Key), ciro = R(t.Net), kar = R(t.Kar), marj = Yuzde(t.Kar, t.Net),
                    tahsilat = R(t.Tahsil),
                    vadesiGecen = R(carilar.Values.Where(c => cariTemsilci.GetValueOrDefault(c.Id) == kv.Key).Sum(c => Math.Max(c.VadesiGecen, 0))),
                    aktifMusteri = t.Musteri.Count, yeniMusteri = yeniler.GetValueOrDefault(kv.Key),
                    iskonto = R(t.Isk), iskontoOran = Yuzde(t.Isk, t.Brut), teklif = teklifler.GetValueOrDefault(kv.Key),
                    hedefCiro = hc is { } h1 ? R(h1) : (decimal?)null, hedefOran = hc is { } h2 ? Yuzde(t.Net, h2) : null,
                    musteriler,
                };
            })
            .Where(x => x.id == -1 ? Math.Abs(x.ciro) >= 0.005m : true)
            .Where(x => Math.Abs(x.ciro) >= 0.005m || x.hedefCiro is not null || x.vadesiGecen > 0.005m || x.yeniMusteri > 0 || x.teklif > 0)
            .OrderBy(x => x.id == -1 ? 1 : 0).ThenByDescending(x => x.ciro).ToList();
            var temsilcili = temsilciler.Where(x => x.id > 0).ToList();
            var toplam = new
            {
                ciro = R(temsilciler.Sum(x => x.ciro)), kar = R(temsilciler.Sum(x => x.kar)),
                marj = Yuzde(temsilciler.Sum(x => x.kar), temsilciler.Sum(x => x.ciro)),
                tahsilat = R(temsilciler.Sum(x => x.tahsilat)), vadesiGecen = R(temsilciler.Sum(x => x.vadesiGecen)),
                aktifMusteri = donem.Where(x => !x.Iade && x.TarafId > 0).Select(x => x.TarafId).Distinct().Count(),
                yeniMusteri = temsilciler.Sum(x => x.yeniMusteri), iskonto = R(temsilciler.Sum(x => x.iskonto)),
                iskontoOran = Yuzde(temsilciler.Sum(x => x.iskonto), tops.Values.Sum(x => x.Brut)),
                teklif = temsilciler.Sum(x => x.teklif),
            };
            var ciroTemsilcili = R(temsilcili.Sum(x => x.ciro));
            var hedefToplam = ciroHedef.Where(h => h.Key > 0).Sum(h => h.Value);

            // -------------------------------------------------------- gidişat --
            var aylar = Enumerable.Range(0, 6).Select(i => bitAy.AddMonths(i - 5)).ToList();
            var gecenYilAy = bitAy.AddYears(-1);
            decimal AyNet(int id, DateTime ay)
            {
                var t = new Top();
                foreach (var x in belgeler.Where(x => Tid(x.SaticiId) == id && x.Tarih >= ay && x.Tarih < ay.AddMonths(1))) t.Ekle(x, iadeDus);
                return R(t.Net);
            }
            var gidisat = new
            {
                aylar,
                gecenYilAy,
                satirlar = temsilciler.Select(x =>
                {
                    var degerler = aylar.Select(a => AyNet(x.id, a)).ToList();
                    var gy = AyNet(x.id, gecenYilAy);
                    var gyVar = belgeler.Any(y => Tid(y.SaticiId) == x.id && y.Tarih >= gecenYilAy && y.Tarih < gecenYilAy.AddMonths(1));
                    return new
                    {
                        x.id, x.ad, degerler, gecenYil = gyVar ? gy : (decimal?)null,
                        degisim = gyVar && gy != 0 ? Math.Round(100m * (degerler[^1] - gy) / Math.Abs(gy), 1) : (decimal?)null,
                    };
                }).ToList(),
            };

            // ---------------------------------------------------------- portföy --
            var son90 = belgeler.Where(x => !x.Iade && x.TarafId > 0 && x.Tarih > ref12.AddDays(-90) && x.Tarih <= ref12)
                .Select(x => x.TarafId).ToHashSet();
            var son12Kume = son12.Select(x => x.TarafId).ToHashSet();
            var donemAlan = donem.Where(x => !x.Iade && x.TarafId > 0).Select(x => x.TarafId).ToHashSet();
            var portfoy = temsilciler.Select(x =>
            {
                var cariler = cariTemsilci.Where(c => c.Value == x.id).Select(c => c.Key).ToList();
                var ciro12 = son12.Where(y => cariTemsilci.GetValueOrDefault(y.TarafId) == x.id).GroupBy(y => y.TarafId)
                    .Select(g => g.Sum(y => y.Net)).OrderByDescending(v => v).ToList();
                var top12 = ciro12.Sum();
                return new
                {
                    x.id, x.ad, musteri = cariler.Count,
                    buDonemAlan = cariler.Count(donemAlan.Contains),
                    almayan90 = cariler.Count(c => son12Kume.Contains(c) && !son90.Contains(c)),
                    kaybedilen = cariler.Count(c => !son12Kume.Contains(c)),
                    ilk5Pay = top12 > 0 ? Math.Round(100m * ciro12.Take(5).Sum() / top12, 1) : (decimal?)null,
                    limitAsan = cariler.Count(c => carilar.TryGetValue(c, out var cr) && cr.RiskYuzde > 100),
                };
            }).ToList();

            // ---------------------------------------------------- tahsilat kalitesi --
            var tahsilat = temsilciler.Select(x =>
            {
                var cariler = cariTemsilci.Where(c => c.Value == x.id).Select(c => c.Key).ToList();
                var od = cariler.Where(odeme.ContainsKey).Select(c => odeme[c]).ToList();
                decimal? Agirlik(Func<(int id, int fatura, decimal? ortOdeme, decimal? gecikme, decimal? zamaninda), decimal?> f)
                {
                    var l = od.Where(o => f(o) is not null && o.fatura > 0).ToList();
                    var n = l.Sum(o => o.fatura);
                    return n > 0 ? Math.Round(l.Sum(o => f(o)!.Value * o.fatura) / n, 1) : null;
                }
                var zamaninda = Agirlik(o => o.zamaninda);
                var gecikme = Agirlik(o => o.gecikme);
                var ks = cariler.Sum(c => karsiliksiz.GetValueOrDefault(c));
                var skor = MusteriRiskKurali.SkorHesapla(zamaninda, gecikme, ks, null);
                return new
                {
                    x.id, x.ad, x.tahsilat, ortTahsilGun = Agirlik(o => o.ortOdeme), ortGecikme = gecikme, zamaninda,
                    x.vadesiGecen,
                    d90p = R(carilar.Values.Where(c => cariTemsilci.GetValueOrDefault(c.Id) == x.id).Sum(c => Math.Max(c.D90p, 0))),
                    karsiliksiz = ks, skor = skor?.Harf, skorPuan = skor?.Puan,
                };
            }).ToList();

            // --------------------------------------------------------- aktivite --
            var aktivite = temsilciler.Where(x => x.id > 0).Select(x =>
            {
                var a = aktiviteler.TryGetValue(x.id, out var v) ? v : (id: x.id, gorusme: 0, toplanti: 0, gorev: 0, acik: 0, geciken: 0);
                var temas = a.gorusme + a.toplanti;
                return new
                {
                    x.id, x.ad, a.gorusme, a.toplanti, a.gorev, acikGorev = a.acik, gecikenGorev = a.geciken, x.teklif,
                    temasBasinaCiro = temas > 0 ? R(x.ciro / temas) : (decimal?)null,
                };
            }).ToList();

            // ------------------------------------------------------------- prim --
            var planVar = await b.TekDegerAsync<bool>("select exists (select 1 from public.prim_plani where coalesce(durum, 1) = 1)", null, [], iptal);
            var primler = (await b.ListeAsync(PrimSorgusu, null, [bas, bit], o => (
                id: o.GetInt32(0), plan: o.GetString(1), taslak: o.GetDecimal(2), kesin: o.GetDecimal(3),
                onayli: o.GetDecimal(4), odendi: o.GetDecimal(5), toplam: o.GetDecimal(6)), iptal)).ToDictionary(x => x.id);
            var primSatirlari = temsilciler.Where(x => x.id > 0 && primler.ContainsKey(x.id)).Select(x =>
            {
                var pr = primler[x.id];
                return new
                {
                    x.id, x.ad, pr.plan, taslak = R(pr.taslak), kesin = R(pr.kesin), onayli = R(pr.onayli), odendi = R(pr.odendi),
                    toplam = R(pr.toplam),
                };
            }).ToList();

            return Results.Ok(new
            {
                kip = k, bas, bit, bugun, sube = s0, iadeDus,
                ozet = new
                {
                    ciro = ciroTemsilcili, temsilcisizCiro = R(temsilciler.Where(x => x.id == -1).Sum(x => x.ciro)),
                    hedef = hedefToplam > 0 ? R(hedefToplam) : (decimal?)null,
                    hedefOran = hedefToplam > 0 ? Yuzde(ciroTemsilcili, hedefToplam) : null,
                    kar = R(temsilcili.Sum(x => x.kar)), marj = Yuzde(temsilcili.Sum(x => x.kar), ciroTemsilcili),
                    tahsilat = R(temsilcili.Sum(x => x.tahsilat)), tahsilatOran = Yuzde(temsilcili.Sum(x => x.tahsilat), ciroTemsilcili),
                    vadesiGecen = R(temsilciler.Sum(x => x.vadesiGecen)),
                    vadesiGecenMusteri = carilar.Values.Count(c => c.VadesiGecen > 0.005m && cariTemsilci.ContainsKey(c.Id)),
                    yeniMusteri = temsilciler.Sum(x => x.yeniMusteri),
                    iskontoOran = toplam.iskontoOran, teklif = toplam.teklif,
                    prim = primSatirlari.Count > 0 ? R(primSatirlari.Sum(x => x.toplam)) : (decimal?)null,
                },
                temsilciler, toplam, hedefler, tahminVar = gecenGun > 0, gidisat, portfoy, tahsilat, aktivite,
                prim = new
                {
                    planVar, satirlar = primSatirlari,
                    toplam = new
                    {
                        taslak = R(primSatirlari.Sum(x => x.taslak)), kesin = R(primSatirlari.Sum(x => x.kesin)),
                        onayli = R(primSatirlari.Sum(x => x.onayli)), odendi = R(primSatirlari.Sum(x => x.odendi)),
                        toplam = R(primSatirlari.Sum(x => x.toplam)),
                    },
                },
                hedefYetkisi = baglam.Yetkiler.AksiyonVar(AksiyonHedef),
                secim = new { subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList() },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ========================================================= HEDEFLER (ay) ===
        grup.MapGet("/hedef", async (DateTime? ay, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var a = ay ?? bugun;
            var donem = new DateTime(a.Year, a.Month, 1);
            await using var b = await veri.AcAsync(iptal);
            // Seçilebilir temsilci: aktif personel + son 12 ayda faturada satıcı olan (personel olmasa da).
            var temsilciler = await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '')::varchar(160)
                  from public.taraf t
                 where (t.personel = 1 and t.durum = 1)
                    or t.id in (select distinct b.satici_id from public.belge b
                                 where b.tur in (15, 16) and coalesce(b.satici_id, 0) > 0 and b.belge_tarihi >= @p0::date - 365)
                    or t.id in (select h.temsilci_id from public.temsilci_hedef h where h.donem = @p0::date)
                 order by 2
                """, null, [donem], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var hedefler = await b.ListeAsync("""
                select h.temsilci_id, h.olcut::int, h.hedef from public.temsilci_hedef h where h.donem = @p0::date order by 1, 2
                """, null, [donem], o => new { temsilciId = o.GetInt32(0), olcut = o.GetInt32(1), hedef = o.GetDecimal(2) }, iptal);
            return Results.Ok(new
            {
                donem, temsilciler, hedefler,
                olcutler = OlcutAdlari.Select(x => new { id = x.Key, ad = x.Value }).ToList(),
                yetki = baglam.Yetkiler.AksiyonVar(AksiyonHedef), izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPut("/hedef", async (HedefIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                       HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonHedef);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            if (!OlcutAdlari.ContainsKey(istek.Olcut))
                throw GentegreHatasi.Dogrulama("Ölçüt geçersiz.", new AlanHatasi("olcut", "1 ciro, 2 brüt kâr, 3 tahsilat, 4 yeni müşteri."));
            if (istek.Hedef is < 0 or > 999_999_999_999m)
                throw GentegreHatasi.Dogrulama("Hedef geçersiz.", new AlanHatasi("hedef", "0 ya da daha büyük olmalı (boş = hedefi kaldır)."));
            if (istek.Olcut == 4 && istek.Hedef is { } hy && hy != Math.Round(hy))
                throw GentegreHatasi.Dogrulama("Yeni müşteri hedefi tam sayı olmalı.", new AlanHatasi("hedef", "Tam sayı girin."));
            if (istek.Donem.Year is < 2000 or > 2100) throw GentegreHatasi.Dogrulama("Dönem geçersiz.", new AlanHatasi("donem", "Ay seçin."));
            var donem = new DateTime(istek.Donem.Year, istek.Donem.Month, 1);
            var yeni = istek.Hedef is { } hd && hd > 0 ? Math.Round(hd, 2) : (decimal?)null;

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var bulundu = await b.TekDegerAsync<int>("select count(*)::int from public.taraf where id = @p0", tx, [istek.TemsilciId], iptal);
            if (bulundu == 0) throw GentegreHatasi.Bulunamadi("Temsilci bulunamadı.");
            var eski = await b.TekAsync("""
                select id, hedef from public.temsilci_hedef where temsilci_id = @p0 and donem = @p1::date and olcut = @p2 for update
                """, tx, [istek.TemsilciId, donem, istek.Olcut], o => new Tuple<long, decimal>(o.GetInt64(0), o.GetDecimal(1)), iptal);
            if (eski is null && yeni is null) { await tx.RollbackAsync(iptal); return Results.Ok(new { degisti = false, izlemeNo = baglam.IzlemeNo }); }
            if (eski is not null && yeni == eski.Item2) { await tx.RollbackAsync(iptal); return Results.Ok(new { degisti = false, izlemeNo = baglam.IzlemeNo }); }

            long kayit;
            short islem;
            if (yeni is null)
            {
                await b.CalistirAsync("delete from public.temsilci_hedef where id = @p0", tx, [eski!.Item1], iptal);
                kayit = eski.Item1; islem = LogIslemi.Sil;
            }
            else if (eski is null)
            {
                kayit = await b.TekDegerAsync<long>("""
                    insert into public.temsilci_hedef (temsilci_id, donem, olcut, hedef, ekleyen)
                    values (@p0, @p1::date, @p2, @p3, @p4) returning id
                    """, tx, [istek.TemsilciId, donem, istek.Olcut, yeni.Value, baglam.KullaniciId], iptal);
                islem = LogIslemi.Ekle;
            }
            else
            {
                await b.CalistirAsync("""
                    update public.temsilci_hedef set hedef = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0
                    """, tx, [eski.Item1, yeni.Value, baglam.KullaniciId], iptal);
                kayit = eski.Item1; islem = LogIslemi.Degistir;
            }
            static string? Sayi(decimal? d) => d?.ToString("0.##", CultureInfo.InvariantCulture);
            var bilgi = new Dictionary<string, string?>
            {
                ["temsilciId"] = istek.TemsilciId.ToString(CultureInfo.InvariantCulture),
                ["donem"] = donem.ToString("yyyy-MM", CultureInfo.InvariantCulture),
                ["olcut"] = istek.Olcut.ToString(CultureInfo.InvariantCulture),
                ["hedef"] = Sayi(yeni), ["eskiHedef"] = Sayi(eski?.Item2), ["kaynak"] = "temsilci-performans",
            };
            await log.YazAsync(b, tx, islem, LogTabloHedef, kayit, baglam.KullaniciId, baglam.SubeId, baglam.Ip, bilgi,
                               tarafId: istek.TemsilciId, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { degisti = true, izlemeNo = baglam.IzlemeNo });
        });
    }
}
