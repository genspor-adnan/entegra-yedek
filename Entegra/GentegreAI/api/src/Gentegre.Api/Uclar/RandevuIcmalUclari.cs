using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RANDEVU / POLİKLİNİK İCMALİ (mockup Ekranlar/İcmal/randevu_poliklinik_icmali.html,
/// kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para><b>Randevu</b> (yalnız hekim randevusu; cihaz / ünite randevusu poliklinik değildir),
/// dönem = randevu saati şubenin yerel saatinde: durum 1 planlandı · 2 geldi · 3 gelmedi ·
/// 4 iptal. Verilen = iptal dışı (1-3); no-show = gelmedi / verilen; iptal doluluğa girmez.
/// Poliklinik = randevu.bolum (departman).</para>
///
/// <para><b>Slot</b> = çalışma planı (<c>fn_hekim_calisma_bloklari</c>): her blok slot_dk'lık
/// dilimlere bölünür; izin / kongre / kapalı gün slot üretmez (fonksiyon kırpar).
/// Doluluk = verilen / slot. Kanal ve tip süzgeci slota ve randevusuz muayeneye uygulanmaz.</para>
///
/// <para><b>Bekleme</b> = randevu saati → muayene.baslangic (muayene.randevu_id ile; yalnız gelen,
/// erken başlayan 0). Randevusuz muayene = randevu_id boş muayene (muayene_tarihi dönemde).
/// Önceki gelmeme = aynı hastanın son 6 ayda gelmediği randevu sayısı.</para>
///
/// <para>Hasta adı yalnız ekrandaki Gelmeyenler listesinde (TC yok); A4'te hasta bilgisi yok.</para>
/// </summary>
public static class RandevuIcmalUclari
{
    /// <summary>Ekran kodu (1046) - haklarını randevu'dan kopyalar.</summary>
    private const string Kod = "randevu.icmal";

    private sealed record Rv(int Id, int Hekim, int Bolum, string BolumAd, string HekimAd, DateTime Yerel, short Durum, short Tip,
                             short Kaynak, DateTime Verilme, double? BeklemeDk, string Hasta, int Onceki);
    private sealed record Slot(int Hekim, string HekimAd, int Bolum, string BolumAd, DateTime Gun, int Dow, int Saat, int Adet);

    private static readonly string[] GunAdlari = ["", "Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    public static void RandevuIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/randevu-icmal").WithTags("Randevu / Poliklinik İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? bolum, int? hekim, int? kanal, int? tip,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var kodlar = await b.ListeAsync("""
                select l.kod, d.deger, d.ad
                  from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                 where l.kod in ('randevu.kaynak', 'randevu.tip') and d.dil = 0
                """, null, [], o => (liste: o.GetString(0), deger: o.GetInt32(1), ad: o.GetString(2)), iptal);
            string KodAd(string liste, int deger) =>
                kodlar.Where(k => k.liste == liste && k.deger == deger).Select(k => k.ad).FirstOrDefault() ?? (deger == 0 ? "Belirsiz" : $"Kod {deger}");

            // Randevular: dönem yerel saatte; kaba ön süzme indeks için ±1 gün.
            var tum = await b.ListeAsync("""
                select r.id, r.hekim_id, coalesce(r.bolum, 0)::int, coalesce(d.ad, 'Bölüm belirtilmemiş'),
                       public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), x.yerel, r.durum, r.tip, r.kaynak,
                       r.ekleme_tarihi at time zone x.tz,
                       (select extract(epoch from (min(m.baslangic) - r.baslangic)) / 60.0
                          from public.muayene m where m.randevu_id = r.id and m.baslangic is not null)::float8,
                       case when r.durum = 3 then public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) else '' end,
                       case when r.durum = 3 then (select count(*) from public.randevu o
                                                    where o.hasta_id = r.hasta_id and o.durum = 3 and o.baslangic < r.baslangic
                                                      and o.baslangic >= r.baslangic - interval '6 months')::int else 0 end
                  from public.randevu r
                  join public.sube sb on sb.id = r.sube_id
                  cross join lateral (select coalesce(nullif(sb.zaman_dilimi, ''), 'Europe/Istanbul') as tz) z
                  cross join lateral (select r.baslangic at time zone z.tz as yerel, z.tz) x
                  left join public.departman d on d.id = r.bolum
                  left join public.taraf h on h.id = r.hekim_id
                  left join public.taraf p on p.id = r.hasta_id
                 where r.hekim_id is not null and (@p2 = 0 or r.sube_id = @p2)
                   and r.baslangic >= @p0 - interval '1 day' and r.baslangic < @p1 + interval '1 day'
                   and x.yerel >= @p0 and x.yerel < @p1
                """, null, [baslangic, bitis, sube], o => new Rv(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetString(4),
                    o.GetDateTime(5), o.GetInt16(6), o.GetInt16(7), o.GetInt16(8), o.GetDateTime(9), o.IsDBNull(10) ? null : o.GetDouble(10),
                    o.GetString(11), o.GetInt32(12)), iptal);

            // Slotlar: plan blokları slot_dk dilimlerine; (hekim, bölüm, gün, saat) başına adet.
            var slotlar = await b.ListeAsync("""
                select f.hekim_id, f.hekim, coalesce(f.departman_id, 0), coalesce(nullif(f.departman, ''), 'Bölüm belirtilmemiş'), f.gun,
                       extract(isodow from f.gun)::int, extract(hour from s)::int, count(*)::int
                  from public.fn_hekim_calisma_bloklari(@p0, @p1::date, @p2::date, null, null) f
                  cross join lateral generate_series(f.gun + f.saat_bas, f.gun + f.saat_bit - make_interval(mins => f.slot_dk::int),
                                                     make_interval(mins => f.slot_dk::int)) s
                 where f.saat_bas is not null and f.saat_bit > f.saat_bas and coalesce(f.slot_dk, 0) > 0
                 group by 1, 2, 3, 4, 5, 6, 7
                """, null, [sube, baslangic, sonGun], o => new Slot(o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetString(3),
                    o.GetDateTime(4), o.GetInt32(5), o.GetInt32(6), o.GetInt32(7)), iptal);
            // Kapanış günleri (izin / kongre / kapalı): hekim başına gün sayısı.
            var kapanislar = await b.ListeAsync("""
                select distinct f.hekim_id, f.gun
                  from public.fn_hekim_calisma_bloklari(@p0, @p1::date, @p2::date, null, null) f
                 where f.saat_bas is null and f.kaynak in (3, 4)
                """, null, [sube, baslangic, sonGun], o => (hekim: o.GetInt32(0), gun: o.GetDateTime(1)), iptal);
            // Muayeneler: bölüm × hekim × randevusuz.
            var muayeneler = await b.ListeAsync("""
                select coalesce(m.bolum_id, 0), coalesce(m.personel_id, 0), m.randevu_id is null, count(*)::int
                  from public.muayene m
                  left join public.sube sb on sb.id = m.sube_id
                 where (@p2 = 0 or coalesce(m.sube_id, 0) in (0, @p2))
                   and m.muayene_tarihi >= @p0 - interval '1 day' and m.muayene_tarihi < @p1 + interval '1 day'
                   and (m.muayene_tarihi at time zone coalesce(nullif(sb.zaman_dilimi, ''), 'Europe/Istanbul')) >= @p0
                   and (m.muayene_tarihi at time zone coalesce(nullif(sb.zaman_dilimi, ''), 'Europe/Istanbul')) < @p1
                 group by 1, 2, 3
                """, null, [baslangic, bitis, sube], o => (bolum: o.GetInt32(0), hekim: o.GetInt32(1), randevusuz: o.GetBoolean(2),
                    adet: o.GetInt32(3)), iptal);

            // Süzgeç seçenekleri süzülmemiş veriden.
            var bolumAdlari = tum.Select(r => (id: r.Bolum, ad: r.BolumAd)).Concat(slotlar.Select(s => (id: s.Bolum, ad: s.BolumAd)))
                .DistinctBy(x => x.id).OrderBy(x => x.ad).Select(x => new { x.id, x.ad }).ToList();
            var hekimAdlari = tum.Select(r => (id: r.Hekim, ad: r.HekimAd)).Concat(slotlar.Select(s => (id: s.Hekim, ad: s.HekimAd)))
                .DistinctBy(x => x.id).OrderBy(x => x.ad).Select(x => new { x.id, x.ad }).ToList();
            var kanalAdlari = kodlar.Where(k => k.liste == "randevu.kaynak").OrderBy(k => k.deger).Select(k => new { id = k.deger, k.ad }).ToList();
            var tipAdlari = kodlar.Where(k => k.liste == "randevu.tip").OrderBy(k => k.deger).Select(k => new { id = k.deger, k.ad }).ToList();

            var rv = tum.Where(r => (bolum is not > 0 || r.Bolum == bolum) && (hekim is not > 0 || r.Hekim == hekim)
                                    && (kanal is not > 0 || r.Kaynak == kanal) && (tip is not > 0 || r.Tip == tip)).ToList();
            var sl = slotlar.Where(s => (bolum is not > 0 || s.Bolum == bolum) && (hekim is not > 0 || s.Hekim == hekim)).ToList();
            var mu = muayeneler.Where(m => (bolum is not > 0 || m.bolum == bolum) && (hekim is not > 0 || m.hekim == hekim)).ToList();

            static decimal? Oran(int pay, int payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;
            static int? OrtDk(IEnumerable<Rv> l)
            {
                var dk = l.Where(r => r.Durum == 2 && r.BeklemeDk != null).Select(r => Math.Max(0, r.BeklemeDk!.Value)).ToList();
                return dk.Count > 0 ? (int)Math.Round(dk.Average()) : null;
            }
            static bool Verilen(Rv r) => r.Durum is 1 or 2 or 3;

            // Ortak satır: slot / verilen / gelen / gelmeyen / iptal / randevusuz / bekleme / ilk-kontrol.
            object Satir(IReadOnlyCollection<Rv> r, int slot, int randevusuz, int muayene)
            {
                var verilen = r.Count(Verilen); var gelmeyen = r.Count(x => x.Durum == 3);
                return new
                {
                    slot, verilen, bos = Math.Max(0, slot - verilen), doluluk = Oran(verilen, slot), gelen = r.Count(x => x.Durum == 2),
                    gelmeyen, bekleyen = r.Count(x => x.Durum == 1), noShow = Oran(gelmeyen, verilen), iptal = r.Count(x => x.Durum == 4),
                    randevusuz, muayene, ortBeklemeDk = OrtDk(r),
                    uzunBekleme = r.Count(x => x.Durum == 2 && x.BeklemeDk is > 30),
                    ilk = r.Count(x => x.Durum == 2 && x.Tip == 1), kontrol = r.Count(x => x.Durum == 2 && x.Tip == 2),
                };
            }

            // ----------------------------------------------------------- hekimler --
            var hekimAnahtar = rv.Select(r => (bolum: r.Bolum, hekim: r.Hekim, bolumAd: r.BolumAd, hekimAd: r.HekimAd))
                .Concat(sl.Select(s => (bolum: s.Bolum, hekim: s.Hekim, bolumAd: s.BolumAd, hekimAd: s.HekimAd)))
                .DistinctBy(x => (x.bolum, x.hekim)).ToList();
            var hekimler = hekimAnahtar.Select(k =>
            {
                var r = rv.Where(x => x.Bolum == k.bolum && x.Hekim == k.hekim).ToList();
                var s = sl.Where(x => x.Bolum == k.bolum && x.Hekim == k.hekim).ToList();
                var gun = s.Select(x => x.Gun).Distinct().Count();
                var izin = kapanislar.Where(x => x.hekim == k.hekim).Select(x => x.gun).Distinct().Count();
                var rsz = mu.Where(m => m.bolum == k.bolum && m.hekim == k.hekim && m.randevusuz).Sum(m => m.adet);
                var muay = mu.Where(m => m.bolum == k.bolum && m.hekim == k.hekim).Sum(m => m.adet);
                return new
                {
                    k.bolum, k.hekim, k.bolumAd, k.hekimAd, gun, izin,
                    gunBasi = gun > 0 ? Math.Round((decimal)muay / gun, 1) : (decimal?)null,
                    deger = Satir(r, s.Sum(x => x.Adet), rsz, muay),
                    _verilen = r.Count(Verilen), _slot = s.Sum(x => x.Adet),
                };
            }).OrderByDescending(h => h._slot > 0 ? (decimal)h._verilen / h._slot : -1).ThenBy(h => h.hekimAd).ToList();

            // -------------------------------------------------------- poliklinikler --
            var poliklinikler = hekimler.GroupBy(h => (h.bolum, h.bolumAd)).Select(g =>
            {
                var r = rv.Where(x => x.Bolum == g.Key.bolum).ToList();
                var muay = mu.Where(m => m.bolum == g.Key.bolum).ToList();
                return new
                {
                    id = g.Key.bolum, ad = g.Key.bolumAd, hekimSayisi = g.Count(),
                    deger = Satir(r, sl.Where(x => x.Bolum == g.Key.bolum).Sum(x => x.Adet), muay.Where(m => m.randevusuz).Sum(m => m.adet), muay.Sum(m => m.adet)),
                    hekimler = g.Select(h => new { h.hekim, h.hekimAd, h.gun, h.izin, h.deger }).ToList(),
                };
            }).OrderBy(p => p.ad).ToList();
            // Plan / randevu dışında kalan bölümlerin randevusuz muayenesi de toplama girer.
            var randevusuzT = mu.Where(m => m.randevusuz).Sum(m => m.adet);
            var muayeneT = mu.Sum(m => m.adet);
            var toplam = Satir(rv, sl.Sum(x => x.Adet), randevusuzT, muayeneT);

            // -------------------------------------------------------------- kanallar --
            var kanallar = rv.GroupBy(r => r.Kaynak).Select(g =>
            {
                var v = g.Where(Verilen).ToList(); var gm = g.Count(x => x.Durum == 3);
                var one = v.Select(x => (x.Yerel - x.Verilme).TotalDays).Where(x => x >= 0).ToList();
                return new
                {
                    id = (int)g.Key, ad = KodAd("randevu.kaynak", g.Key), kayit = g.Count(), pay = Oran(g.Count(), rv.Count), verilen = v.Count,
                    gelen = g.Count(x => x.Durum == 2), gelmeyen = gm, noShow = Oran(gm, v.Count), iptal = g.Count(x => x.Durum == 4),
                    ortOneAlmaGun = one.Count > 0 ? Math.Round((decimal)one.Average(), 1) : (decimal?)null,
                };
            }).OrderByDescending(k => k.kayit).ToList();
            var tumOne = rv.Where(Verilen).Select(x => (x.Yerel - x.Verilme).TotalDays).Where(x => x >= 0).ToList();
            var kanalToplam = new
            {
                kayit = rv.Count, verilen = rv.Count(Verilen), gelen = rv.Count(x => x.Durum == 2), gelmeyen = rv.Count(x => x.Durum == 3),
                noShow = Oran(rv.Count(x => x.Durum == 3), rv.Count(Verilen)), iptal = rv.Count(x => x.Durum == 4),
                ortOneAlmaGun = tumOne.Count > 0 ? Math.Round((decimal)tumOne.Average(), 1) : (decimal?)null,
            };

            // ----------------------------------------------------------- gün × saat --
            var vr = rv.Where(Verilen).ToList();
            var gunler = sl.Select(s => s.Dow).Concat(vr.Select(r => DowOf(r.Yerel))).Distinct().OrderBy(x => x).ToList();
            var saatler = sl.Select(s => s.Saat).Concat(vr.Select(r => r.Yerel.Hour)).Distinct().OrderBy(x => x).ToList();
            var gunSaat = new
            {
                gunler = gunler.Select(d => new { dow = d, ad = GunAdlari[d], gunSayisi = sl.Where(s => s.Dow == d).Select(s => s.Gun).Distinct().Count(),
                                                  verilen = vr.Count(r => DowOf(r.Yerel) == d) }).ToList(),
                satirlar = saatler.Select(h => new
                {
                    saat = $"{h:00}:00–{h + 1:00}:00",
                    verilen = vr.Count(r => r.Yerel.Hour == h),
                    hucreler = gunler.Select(d =>
                    {
                        var slot = sl.Where(s => s.Dow == d && s.Saat == h).Sum(s => s.Adet);
                        var c = vr.Where(r => DowOf(r.Yerel) == d && r.Yerel.Hour == h).ToList();
                        var gm = c.Count(r => r.Durum == 3);
                        return new { slot, verilen = c.Count, doluluk = Oran(c.Count, slot), gelmeme = Oran(gm, c.Count) };
                    }).ToList(),
                }).ToList(),
                toplam = vr.Count,
            };

            // ------------------------------------------------------------- bekleme --
            var bekleme = rv.Where(r => r.Durum == 2 && r.BeklemeDk != null).Select(r => Math.Max(0, r.BeklemeDk!.Value)).ToList();
            // Dilim: (ad, alt sınır hariç, üst sınır dahil); ilk dilim 0 dahil.
            (string ad, double alt, double ust)[] dilimler =
                [("0–10 dk", -1, 10), ("11–20 dk", 10, 20), ("21–30 dk", 20, 30), ("31–45 dk", 30, 45), ("45 dk üstü", 45, double.MaxValue)];
            var beklemeDagilimi = dilimler.Select(d =>
            {
                var n = bekleme.Count(x => x > d.alt && x <= d.ust);
                return new { d.ad, hasta = n, pay = Oran(n, bekleme.Count) };
            }).ToList();

            // ---------------------------------------------------------- gelmeyenler --
            var gelmeyenler = rv.Where(r => r.Durum == 3).OrderByDescending(r => r.Onceki).ThenBy(r => r.Yerel).Take(500).Select(r => new
            {
                r.Id, no = $"R-{r.Id}", tarih = r.Yerel, hasta = r.Hasta, poliklinik = r.BolumAd, hekim = r.HekimAd,
                kanal = KodAd("randevu.kaynak", r.Kaynak), tip = KodAd("randevu.tip", r.Tip), onceki = r.Onceki, verilme = r.Verilme,
            }).ToList();

            var ozet = new
            {
                kayit = rv.Count, verilen = rv.Count(Verilen), gelen = rv.Count(x => x.Durum == 2), gelmeyen = rv.Count(x => x.Durum == 3),
                bekleyen = rv.Count(x => x.Durum == 1), iptal = rv.Count(x => x.Durum == 4),
                gelenOran = Oran(rv.Count(x => x.Durum == 2), rv.Count(Verilen)), noShow = Oran(rv.Count(x => x.Durum == 3), rv.Count(Verilen)),
                iptalOran = Oran(rv.Count(x => x.Durum == 4), rv.Count), slot = sl.Sum(x => x.Adet),
                doluluk = Oran(rv.Count(Verilen), sl.Sum(x => x.Adet)), bos = Math.Max(0, sl.Sum(x => x.Adet) - rv.Count(Verilen)),
                ortBeklemeDk = OrtDk(rv), uzunBekleme = rv.Count(x => x.Durum == 2 && x.BeklemeDk is > 30),
                beklemeOlculen = bekleme.Count,
                randevusuz = randevusuzT, muayene = muayeneT,
                ilk = rv.Count(x => x.Durum == 2 && x.Tip == 1), kontrol = rv.Count(x => x.Durum == 2 && x.Tip == 2),
                ilkOran = Oran(rv.Count(x => x.Durum == 2 && x.Tip == 1), rv.Count(x => x.Durum == 2 && x.Tip is 1 or 2)),
                kontrolOran = Oran(rv.Count(x => x.Durum == 2 && x.Tip == 2), rv.Count(x => x.Durum == 2 && x.Tip is 1 or 2)),
                poliklinik = poliklinikler.Count, hekim = hekimler.Count, kanal = kanallar.Count,
                ucuncuGelmeme = rv.Count(x => x.Durum == 3 && x.Onceki >= 2), gelmeyenToplam = rv.Count(x => x.Durum == 3),
                calismaGunu = sl.Select(s => s.Gun).Distinct().Count(),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, poliklinikler, toplam,
                hekimler = hekimler.Select(h => new { h.bolum, h.hekim, h.bolumAd, h.hekimAd, h.gun, h.izin, h.gunBasi, h.deger }),
                kanallar, kanalToplam, gunSaat, beklemeDagilimi, gelmeyenler,
                bolumAdlari, hekimAdlari, kanalAdlari, tipAdlari,
            });
        });
    }

    /// <summary>ISO hafta günü (1 Pazartesi … 7 Pazar).</summary>
    private static int DowOf(DateTime t) => t.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)t.DayOfWeek;
}
