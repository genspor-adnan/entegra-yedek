using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// AMELİYATHANE İCMALİ (mockup Ekranlar/İcmal/ameliyathane_icmali.html,
/// kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para><b>Vaka</b> = ameliyat.durum 4 (bitti); 8 iptal ayrı sayılır. Dönem = salona alma
/// (yoksa plan başlangıcı), şubenin saat diliminde. Plan dışı (acil) doluluğa girer,
/// plan sapmasına ve ilk vaka hesabına girmez.</para>
///
/// <para><b>Masa süresi</b> = salona_alma → salondan_cikis; plan = plan_sure_dk; sapma =
/// (Σ gerçek − Σ plan) / Σ plan. <b>Doluluk</b> = mesai içi masa süresi / (iş günü ×
/// salon mesaisi); mesai ameliyat_salon.mesai_bas / mesai_bit (1040), iş günü pzt-cuma.
/// <b>İlk vaka zamanında</b> = salonun günün ilk planlı vakası plan başlangıcından en
/// çok 10 dk sonra salona alındı. <b>Devir</b> = aynı salonda bir vakanın çıkışı ile
/// sonrakinin alınması arası (0-240 dk).</para>
///
/// <para><b>Ciro</b> = ameliyatın işlem ve sarf satırlarının başvurudaki ücret satırları
/// (belge_satir_id, iptal belge hariç). <b>Maliyet</b> = ameliyat_sarf.miktar ×
/// fn_uretim_stok_maliyeti; implant ayrı. <b>Faturaya girmeyen sarf</b> = faturaya = 1
/// ama belge_satir_id boş. <b>Ertelenen</b> = iptal edilen ve aynı talepten sonra yeni
/// ameliyat planlanan vaka (ayrı durum kodu yok).</para>
///
/// <para>Hasta kimliği yok: ameliyatlar protokol (başvuru belge no) ile gösterilir.</para>
/// </summary>
public static class AmeliyathaneIcmalUclari
{
    /// <summary>Ekran kodu (1040) - haklarını ameliyathane.plan'dan kopyalar.</summary>
    private const string Kod = "ameliyathane.icmal";

    private sealed record Ameliyat(long Id, string Protokol, int SalonId, DateTime? Plan, DateTime? Alma, DateTime? Cikis,
        int PlanDk, short Durum, bool PlanDisi, string IptalNeden, int CerrahId, int AnesteziId, string Islem, decimal Ciro, bool Ertelendi)
    {
        public bool Bitti => Durum == 4;
        public int? MasaDk => Alma is { } a && Cikis is { } c && c > a ? (int)Math.Round((c - a).TotalMinutes) : null;
        public DateTime? Tarih => Alma ?? Plan;
    }

    private sealed record Sarf(long AmeliyatId, bool Implant, bool Faturasiz, decimal Maliyet);

    public static void AmeliyathaneIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ameliyathane-icmal").WithTags("Ameliyathane İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? salon, string? brans,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Gentegre.Cekirdek.Saat.Bugun.Year, Gentegre.Cekirdek.Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var salonlar = await b.ListeAsync("""
                select s.id, coalesce(s.kod, ''), coalesce(s.ad, ''), coalesce(d.ad, coalesce(s.ozellik, '')),
                       coalesce(nullif(s.mesai_bas, ''), '08:00'), coalesce(nullif(s.mesai_bit, ''), '17:00'), coalesce(s.acil_ayrilmis, 0) = 1
                  from public.ameliyat_salon s
                  left join public.departman d on d.id = s.departman_id
                 where (@p0 = 0 or coalesce(s.sube_id, 0) in (0, @p0)) and coalesce(s.aktif, 1) = 1
                 order by s.sira, s.ad
                """, null, [sube], o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), brans: o.GetString(3),
                    mesaiBas: Saat(o.GetString(4), 8 * 60), mesaiBit: Saat(o.GetString(5), 17 * 60), acil: o.GetBoolean(6)), iptal);

            // Saat dilimi: şubenin (yoksa İstanbul) - dönem ve mesai yerel saatle karşılaştırılır.
            var tumu = await b.ListeAsync("""
                with a as (
                  select a.*, coalesce((select nullif(sb.zaman_dilimi, '') from public.sube sb where sb.id = a.sube_id), 'Europe/Istanbul') as tz
                    from public.ameliyat a
                   where (@p2 = 0 or coalesce(a.sube_id, 0) in (0, @p2))
                )
                select a.id, coalesce(nullif(be.belge_no, ''), a.ameliyat_no, ''), coalesce(a.salon_id, 0),
                       a.plan_baslangic at time zone a.tz, a.salona_alma at time zone a.tz, a.salondan_cikis at time zone a.tz,
                       coalesce(a.plan_sure_dk, 0)::int, coalesce(a.durum, 0)::smallint, coalesce(a.plan_disi, 0) = 1, coalesce(a.iptal_neden, ''),
                       coalesce(a.cerrah_id, 0), coalesce(a.anestezi_id, 0),
                       coalesce((select hz.ad from public.ameliyat_islem i join public.hizmet hz on hz.id = i.hizmet_id
                                  where i.ameliyat_id = a.id order by i.tur, i.sira, i.id limit 1),
                                (select hz.ad from public.ameliyat_talep t join public.hizmet hz on hz.id = t.hizmet_id where t.id = a.talep_id),
                                'İşlem belirtilmemiş'),
                       coalesce((select sum(bs.tutar) from public.belge_satir bs join public.belge bb on bb.id = bs.belge_id
                                  where bb.durum <> 6
                                    and bs.id in (select i.belge_satir_id from public.ameliyat_islem i where i.ameliyat_id = a.id
                                                  union select s.belge_satir_id from public.ameliyat_sarf s where s.ameliyat_id = a.id)), 0),
                       a.durum = 8 and a.talep_id is not null
                         and exists (select 1 from public.ameliyat y where y.talep_id = a.talep_id and y.id > a.id and y.durum <> 8)
                  from a
                  left join public.belge be on be.id = a.belge_id
                 where coalesce(a.salona_alma, a.plan_baslangic) at time zone a.tz >= @p0
                   and coalesce(a.salona_alma, a.plan_baslangic) at time zone a.tz < @p1
                   and a.durum in (4, 8)
                """, null, [baslangic, bitis, sube], o => new Ameliyat(o.GetInt64(0), o.GetString(1), o.GetInt32(2),
                    o.IsDBNull(3) ? null : o.GetDateTime(3), o.IsDBNull(4) ? null : o.GetDateTime(4), o.IsDBNull(5) ? null : o.GetDateTime(5),
                    o.GetInt32(6), o.GetInt16(7), o.GetBoolean(8), o.GetString(9), o.GetInt32(10), o.GetInt32(11), o.GetString(12),
                    o.GetDecimal(13), o.GetBoolean(14)), iptal);

            // Kişiler (cerrah / anestezi) ve branşları: kod listesi 'hekim.brans' yalnız sayısal kodda çözülür.
            var kisiIdleri = tumu.SelectMany(a => new[] { a.CerrahId, a.AnesteziId }).Where(x => x > 0).Distinct().ToArray();
            var kisiler = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                                  where kl.kod = 'hekim.brans' and tp.brans ~ '^[0-9]+$' and kd.deger = tp.brans::integer limit 1),
                                nullif(tp.brans, ''), '')
                  from public.taraf t
                  left join public.taraf_personel tp on tp.id = t.id
                 where t.id = any(@p0)
                """, null, [kisiIdleri], o => (id: o.GetInt32(0), ad: o.GetString(1), brans: o.GetString(2)), iptal))
                .ToDictionary(k => k.id);
            string Ad(int id) => id > 0 && kisiler.TryGetValue(id, out var k) ? k.ad : "Belirtilmemiş";
            string Brans(int id) => id > 0 && kisiler.TryGetValue(id, out var k) && k.brans != "" ? k.brans : "Branş belirtilmemiş";

            // Süzgeç: salon ve cerrah branşı. Seçenekler süzgeçten ÖNCE çıkarılır.
            var bransAdlari = tumu.Select(a => Brans(a.CerrahId)).Distinct().OrderBy(x => x).ToList();
            var amel = tumu.Where(a => (salon is not > 0 || a.SalonId == salon)
                                       && (string.IsNullOrWhiteSpace(brans) || Brans(a.CerrahId) == brans)).ToList();

            var sarflar = await b.ListeAsync("""
                select s.ameliyat_id, coalesce(s.implant, 0) = 1, coalesce(s.faturaya, 1) = 1 and s.belge_satir_id is null,
                       round(coalesce(s.miktar, 0) * coalesce(public.fn_uretim_stok_maliyeti(s.stok_id), 0), 2)
                  from public.ameliyat_sarf s
                 where s.ameliyat_id = any(@p0)
                """, null, [amel.Select(a => a.Id).ToArray()], o => new Sarf(o.GetInt64(0), o.GetBoolean(1), o.GetBoolean(2), o.GetDecimal(3)), iptal);
            var sarfAm = sarflar.GroupBy(s => s.AmeliyatId).ToDictionary(g => g.Key, g => (
                sarf: g.Where(s => !s.Implant).Sum(s => s.Maliyet), implant: g.Where(s => s.Implant).Sum(s => s.Maliyet),
                faturasiz: g.Where(s => s.Faturasiz).Sum(s => s.Maliyet), faturasizAdet: g.Count(s => s.Faturasiz)));
            decimal SarfT(Ameliyat a) => sarfAm.TryGetValue(a.Id, out var s) ? s.sarf + s.implant : 0m;
            static decimal? Marj(decimal ciro, decimal maliyet) => ciro > 0 ? Math.Round(100m * (ciro - maliyet) / ciro, 1) : null;
            static decimal? Sapma(IEnumerable<Ameliyat> l)
            {
                var p = l.Where(a => !a.PlanDisi && a.PlanDk > 0 && a.MasaDk != null).ToList();
                var plan = p.Sum(a => a.PlanDk);
                return plan > 0 ? Math.Round(100m * (p.Sum(a => a.MasaDk!.Value) - plan) / plan, 1) : null;
            }
            static int? Ort(IEnumerable<int> v) { var l = v.ToList(); return l.Count > 0 ? (int)Math.Round(l.Average()) : null; }

            var biten = amel.Where(a => a.Bitti).ToList();
            var iptaller = amel.Where(a => a.Durum == 8).ToList();
            var isGunu = Enumerable.Range(0, (sonGun - baslangic).Days + 1).Select(i => baslangic.AddDays(i))
                .Count(g => g.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday));
            var salonMap = salonlar.ToDictionary(s => s.id);

            // Mesai içi masa süresi (yalnız iş günü, alma gününün mesai penceresi).
            int MesaiIci(Ameliyat a)
            {
                if (a.Alma is not { } al || a.Cikis is not { } ci || ci <= al) return 0;
                if (al.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday) return 0;
                var (mb, me) = salonMap.TryGetValue(a.SalonId, out var s) ? (s.mesaiBas, s.mesaiBit) : (8 * 60, 17 * 60);
                var b0 = al.Date.AddMinutes(mb); var b1 = al.Date.AddMinutes(me);
                var x0 = al > b0 ? al : b0; var x1 = ci < b1 ? ci : b1;
                return x1 > x0 ? (int)Math.Round((x1 - x0).TotalMinutes) : 0;
            }

            // İlk vaka ve devir: salon × gün.
            var gunler = biten.Where(a => a.Alma != null).GroupBy(a => (a.SalonId, gun: a.Alma!.Value.Date)).ToList();
            var ilkVaka = gunler.Select(g => g.Where(a => !a.PlanDisi && a.Plan != null).OrderBy(a => a.Plan).FirstOrDefault())
                .Where(a => a != null).Select(a => (a!.SalonId, a.CerrahId, zamaninda: a.Alma <= a.Plan!.Value.AddMinutes(10))).ToList();
            var devirler = gunler.SelectMany(g =>
            {
                var s = g.Where(a => a.Cikis != null).OrderBy(a => a.Alma).ToList();
                return s.Zip(s.Skip(1), (o, n) => (g.Key.SalonId, dk: (int)Math.Round((n.Alma!.Value - o.Cikis!.Value).TotalMinutes)))
                    .Where(x => x.dk is >= 0 and <= 240);
            }).ToList();

            // ------------------------------------------------------------ salonlar --
            var salonIdleri = salonlar.Select(s => s.id).Union(amel.Select(a => a.SalonId)).Where(id => salon is not > 0 || id == salon).ToList();
            var salonListe = salonIdleri.Select(id =>
            {
                salonMap.TryGetValue(id, out var s);
                var v = biten.Where(a => a.SalonId == id).ToList();
                var kapasite = s.id > 0 ? isGunu * Math.Max(0, s.mesaiBit - s.mesaiBas) : 0;
                var kullanim = v.Sum(a => MesaiIci(a));
                var ilk = ilkVaka.Where(x => x.SalonId == id).ToList();
                return new
                {
                    id, kod = s.id > 0 ? s.kod : "", ad = s.id > 0 ? s.ad : "Salon belirtilmemiş", brans = s.id > 0 ? s.brans : "",
                    vaka = v.Count, planDisi = v.Count(a => a.PlanDisi), kullanimDk = kullanim, kapasiteDk = kapasite,
                    doluluk = kapasite > 0 ? Math.Round(100m * kullanim / kapasite, 1) : (decimal?)null,
                    ortSureDk = Ort(v.Where(a => a.MasaDk != null).Select(a => a.MasaDk!.Value)),
                    ortPlanDk = Ort(v.Where(a => !a.PlanDisi && a.PlanDk > 0).Select(a => a.PlanDk)),
                    sapma = Sapma(v), ilkVakaZamaninda = ilk.Count(x => x.zamaninda), ilkVaka = ilk.Count,
                    ortDevirDk = Ort(devirler.Where(x => x.SalonId == id).Select(x => x.dk)),
                    iptal = iptaller.Count(a => a.SalonId == id), ciro = v.Sum(a => a.Ciro),
                    cerrahlar = v.GroupBy(a => a.CerrahId).Select(g => new { ad = Ad(g.Key), adet = g.Count() }).OrderByDescending(x => x.adet).ToList(),
                };
            }).Where(s => s.vaka > 0 || s.iptal > 0 || salonMap.ContainsKey(s.id)).ToList();

            // ------------------------------------------------------------ cerrahlar --
            var cerrahlar = amel.GroupBy(a => a.CerrahId).Select(g =>
            {
                var v = g.Where(a => a.Bitti).ToList();
                var ciro = v.Sum(a => a.Ciro);
                return new
                {
                    id = g.Key, ad = Ad(g.Key), brans = Brans(g.Key), vaka = v.Count,
                    masaDk = v.Sum(a => a.MasaDk ?? 0), sapma = Sapma(v),
                    gecIlkVaka = ilkVaka.Count(x => x.CerrahId == g.Key && !x.zamaninda), iptal = g.Count(a => a.Durum == 8),
                    ciro, marj = Marj(ciro, v.Sum(a => SarfT(a))),
                };
            }).Where(c => c.vaka > 0 || c.iptal > 0).OrderByDescending(c => c.ciro).ThenByDescending(c => c.vaka).ToList();

            var anestezi = biten.Where(a => a.AnesteziId > 0).GroupBy(a => a.AnesteziId).Select(g => new
            {
                id = g.Key, ad = Ad(g.Key), vaka = g.Count(), sureDk = g.Sum(a => a.MasaDk ?? 0),
            }).OrderByDescending(x => x.sureDk).ToList();
            var anesteziz = biten.Count(a => a.AnesteziId == 0);

            // ----------------------------------------------------------- ameliyatlar --
            string SalonKod(int id) => salonMap.TryGetValue(id, out var s) ? (s.kod != "" ? s.kod : s.ad) : "—";
            var ameliyatlar = biten.OrderBy(a => a.Tarih).ThenBy(a => a.SalonId).Select(a =>
            {
                var s = sarfAm.GetValueOrDefault(a.Id);
                var maliyet = s.sarf + s.implant;
                return new
                {
                    a.Id, tarih = a.Tarih, protokol = a.Protokol, salon = SalonKod(a.SalonId), ameliyat = a.Islem, cerrah = Ad(a.CerrahId),
                    planDk = a.PlanDk > 0 ? a.PlanDk : (int?)null, gercekDk = a.MasaDk,
                    sapmaDk = a.PlanDk > 0 && a.MasaDk != null ? a.MasaDk - a.PlanDk : null,
                    ciro = a.Ciro, sarf = maliyet, marj = Marj(a.Ciro, maliyet), acil = a.PlanDisi, faturasizSarf = s.faturasizAdet > 0,
                };
            }).ToList();

            // ------------------------------------------------------ ameliyat türleri --
            var turler = biten.GroupBy(a => a.Islem).Select(g =>
            {
                var ciro = g.Sum(a => a.Ciro);
                var sarf = g.Sum(a => sarfAm.GetValueOrDefault(a.Id).sarf);
                var implant = g.Sum(a => sarfAm.GetValueOrDefault(a.Id).implant);
                return new
                {
                    ad = g.Key, brans = g.GroupBy(a => Brans(a.CerrahId)).OrderByDescending(x => x.Count()).First().Key, adet = g.Count(),
                    ciro, sarf, implant, vakaBasi = Math.Round((sarf + implant) / g.Count(), 2), brutKar = ciro - sarf - implant,
                    marj = Marj(ciro, sarf + implant), ortSureDk = Ort(g.Where(a => a.MasaDk != null).Select(a => a.MasaDk!.Value)),
                };
            }).OrderBy(t => t.marj ?? decimal.MaxValue).ThenByDescending(t => t.adet).ToList();

            // ------------------------------------------------- faturaya girmeyen sarf --
            var faturasiz = biten.Where(a => sarfAm.GetValueOrDefault(a.Id).faturasizAdet > 0).OrderBy(a => a.Tarih).Select(a =>
            {
                var s = sarfAm[a.Id];
                return new
                {
                    a.Id, tarih = a.Tarih, protokol = a.Protokol, ameliyat = a.Islem, cerrah = Ad(a.CerrahId),
                    toplamSarf = s.sarf + s.implant, faturasiz = s.faturasiz, kalem = s.faturasizAdet,
                };
            }).ToList();

            // ----------------------------------------------------- iptal / ertelenen --
            var iptalListe = iptaller.OrderBy(a => a.Tarih).Select(a => new
            {
                a.Id, tarih = a.Tarih, protokol = a.Protokol, salon = SalonKod(a.SalonId), ameliyat = a.Islem, cerrah = Ad(a.CerrahId),
                neden = a.IptalNeden.Trim() is { Length: > 0 } n ? n : "Neden yazılmamış", ertelendi = a.Ertelendi,
            }).ToList();
            var nedenler = iptalListe.GroupBy(x => x.neden).Select(g => new
            {
                neden = g.Key, adet = g.Count(), pay = Math.Round(100m * g.Count() / iptalListe.Count, 1),
            }).OrderByDescending(x => x.adet).ToList();

            var kapT = salonListe.Sum(s => s.kapasiteDk);
            var kulT = salonListe.Sum(s => s.kullanimDk);
            var ciroT = biten.Sum(a => a.Ciro);
            var sarfT = biten.Sum(a => sarfAm.GetValueOrDefault(a.Id).sarf);
            var implantT = biten.Sum(a => sarfAm.GetValueOrDefault(a.Id).implant);
            var ozet = new
            {
                ameliyat = biten.Count, planDisi = biten.Count(a => a.PlanDisi), salon = salonListe.Count(s => s.vaka > 0),
                kullanimDk = kulT, kapasiteDk = kapT, doluluk = kapT > 0 ? Math.Round(100m * kulT / kapT, 1) : (decimal?)null, isGunu,
                ortSureDk = Ort(biten.Where(a => a.MasaDk != null).Select(a => a.MasaDk!.Value)),
                ortPlanDk = Ort(biten.Where(a => !a.PlanDisi && a.PlanDk > 0).Select(a => a.PlanDk)), sapma = Sapma(biten),
                ilkVakaZamaninda = ilkVaka.Count(x => x.zamaninda), ilkVaka = ilkVaka.Count,
                ilkVakaOrani = ilkVaka.Count > 0 ? Math.Round(100m * ilkVaka.Count(x => x.zamaninda) / ilkVaka.Count, 1) : (decimal?)null,
                gecIlkVaka = ilkVaka.Count(x => !x.zamaninda),
                ortDevirDk = Ort(devirler.Select(x => x.dk)), devir = devirler.Count,
                ciro = ciroT, sarf = sarfT, implant = implantT, brutKar = ciroT - sarfT - implantT, marj = Marj(ciroT, sarfT + implantT),
                iptal = iptaller.Count, ertelenen = iptaller.Count(a => a.Ertelendi),
                iptalOrani = biten.Count + iptaller.Count > 0 ? Math.Round(100m * iptaller.Count / (biten.Count + iptaller.Count), 1) : (decimal?)null,
                faturasizVaka = faturasiz.Count, faturasizTutar = faturasiz.Sum(f => f.faturasiz),
                cerrah = cerrahlar.Count(c => c.vaka > 0), anestezi = anestezi.Count, anestezisiz = anesteziz,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, salonlar = salonListe, cerrahlar, anestezi, ameliyatlar, turler,
                faturasizSarf = faturasiz, iptaller = iptalListe, iptalNedenleri = nedenler,
                salonAdlari = salonlar.Select(s => new { s.id, ad = s.kod != "" && s.kod != s.ad ? $"{s.ad} ({s.kod})" : s.ad }),
                branslar = bransAdlari,
            });
        });
    }

    /// <summary>'HH:MM' → gün içi dakika; bozuksa varsayılan.</summary>
    internal static int Saat(string s, int varsayilan)
    {
        var p = s.Split(':');
        return p.Length == 2 && int.TryParse(p[0], out var h) && int.TryParse(p[1], out var m) && h is >= 0 and <= 24 && m is >= 0 and < 60
            ? h * 60 + m : varsayilan;
    }
}
