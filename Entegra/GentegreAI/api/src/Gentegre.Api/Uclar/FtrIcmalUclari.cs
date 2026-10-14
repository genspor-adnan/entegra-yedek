using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FTR İCMALİ (mockup Ekranlar/İcmal/ftr_icmali.html, kullanıcı 12.10.2026:
/// "icmalleri yap").
///
/// <para><b>Kür</b> = dönemde en az bir seansı (yapıldı / yarım / gelmedi / iptal) olan ya da
/// dönemde tamamlanan ftr_program (taslak hariç). <b>Seans</b> = durumu Yapıldı (3) veya
/// Yarım (6) olan ftr_seans; Gelmedi (4) / İptal (5) ayrı sayılır. Devam oranı =
/// yapılan ÷ (yapılan + gelmedi) - merkez kaynaklı iptal devama girmez.</para>
///
/// <para><b>Ciro</b> = seansın başvuru satırı (ftr_seans.belge_satir_id) tutarı; kurum payı
/// satırın dağılımından (sgk + oss, satır tutarını aşamaz). Satıra bağlanmamış seansın
/// cirosu 0'dır (tahmin edilmez). Ödeyen = programın ödeyen kurumunun türü
/// (taraf_kurum.tur: 3 SGK, 2 ÖSS, 4 kurumu öder; yoksa Özel).</para>
///
/// <para><b>Klinik sonuç</b> yalnız dönemde Tamamlanan (4) kürlerde: kür başı (ölçek aşama 1)
/// → kür sonu (aşama 3) ortalaması, VAS hariç ölçekler; yanıt ftr_program.yanit; VAS = ilk
/// yapılan seansın vas_once → son seansın vas_sonra. <b>Ara değerlendirme gecikti</b> =
/// yapılan seans ≥ ara_degerlendirme_seans ama aşama 2 ölçek yok.</para>
///
/// <para><b>Kabin doluluğu</b>: seansın kabini (yoksa programın) × seans süresi
/// (başlangıç-bitiş, 5 dk'dan kısaysa programın seans süresi); kapasite = iş günü
/// (Pzt-Cmt) × 9 saat × kabin kapasitesi. Hasta kimliği yok: kürler Program / Protokol No ile.</para>
/// </summary>
public static class FtrIcmalUclari
{
    /// <summary>Ekran kodu (1043) - haklarını ftr.seans'tan (FTR Panosu) kopyalar.</summary>
    private const string Kod = "ftr.icmal";
    private const int GunlukSaat = 9;

    /// <summary>Kür sonunda skorun YÜKSELMESİ iyileşme olan ölçekler (KOOS, Barthel, Berg, SF-12, Constant, Lysholm).</summary>
    private static readonly HashSet<short> YuksekIyi = [7, 8, 9, 10, 11, 12];

    private static readonly Dictionary<short, string> DurumAdlari = new()
    {
        [1] = "Taslak", [2] = "Sürüyor", [3] = "Ara değerlendirme", [4] = "Tamamlandı", [5] = "Sonlandırıldı",
    };
    private static readonly Dictionary<short, string> YanitAdlari = new() { [1] = "İyi yanıt", [2] = "Kısmi yanıt", [3] = "Yanıtsız" };

    /// <summary>Ödeyen kodu (süzgeç) ve adı - taraf_kurum.tur'dan.</summary>
    private static (string kod, string ad) Odeyen(short tur) => tur switch
    {
        3 => ("sgk", "SGK (Medula)"), 2 => ("oss", "ÖSS"), 4 => ("kurum", "Kurum"), _ => ("ozel", "Özel"),
    };

    private sealed record Kur(int Id, string ProgramNo, string ProtokolNo, short Bolge, string BolgeAd, string Icd, string Tani,
        short KurumTur, string KurumAd, int FztId, int Plan, int Yapilan, int RaporHak, int KalanHak, int AraSeans, short Durum,
        short? Yanit, DateTime? Bitis, int KabinId, int SureDk, bool AraVar, short? VasIlk, short? VasSon);

    private sealed record Seans(int Id, int ProgramId, short Durum, int FztId, int KabinId, int SureDk, decimal Ciro, decimal Kurum);

    public static void FtrIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ftr-icmal").WithTags("FTR İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? fzt, short? bolge, string? odeyen,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var bugun = Saat.Bugun;
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            // KÜRLER: dönemde seansı olan ya da dönemde tamamlanan programlar.
            var kurlerHam = await b.ListeAsync("""
                select p.id, p.program_no, coalesce(be.belge_no, ''), p.bolge, coalesce(kd.ad, ''), p.icd_kod, p.tani_ad,
                       coalesce(tk.tur, 1)::smallint, coalesce(public.fn_taraf_ad(ok.unvan, ok.ad, ok.soyad)::varchar(120), ''),
                       coalesce(p.fizyoterapist_id, 0), p.seans_sayisi::int, p.yapilan_seans::int, p.rapor_seans_hakki::int, p.kalan_hak::int,
                       p.ara_degerlendirme_seans::int, p.durum, p.yanit, p.bitis, coalesce(p.kabin_id, 0), p.seans_sure_dk::int,
                       exists (select 1 from public.ftr_olcek o where o.program_id = p.id and o.asama = 2),
                       (select s.vas_once from public.ftr_seans s where s.program_id = p.id and s.durum in (3, 6) and s.vas_once is not null
                         order by s.sira, s.tarih limit 1),
                       (select s.vas_sonra from public.ftr_seans s where s.program_id = p.id and s.durum in (3, 6) and s.vas_sonra is not null
                         order by s.sira desc, s.tarih desc limit 1)
                  from public.ftr_program p
                  left join public.belge be on be.id = p.belge_id
                  left join public.taraf ok on ok.id = p.odeyen_kurum_id
                  left join public.taraf_kurum tk on tk.id = p.odeyen_kurum_id
                  left join public.kod_liste kl on kl.kod = 'ftr.bolge'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = p.bolge
                 where p.durum <> 1 and (@p2 = 0 or coalesce(p.sube_id, 0) in (0, @p2))
                   and (exists (select 1 from public.ftr_seans s where s.program_id = p.id and s.durum in (3, 4, 5, 6)
                                   and s.tarih >= @p0::date and s.tarih < @p1::date)
                        or (p.durum = 4 and p.bitis >= @p0::date and p.bitis < @p1::date))
                """, null, [baslangic, bitis, sube], o => new Kur(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt16(3), o.GetString(4),
                    o.GetString(5), o.GetString(6), o.GetInt16(7), o.GetString(8), o.GetInt32(9), o.GetInt32(10), o.GetInt32(11), o.GetInt32(12),
                    o.GetInt32(13), o.GetInt32(14), o.GetInt16(15), o.IsDBNull(16) ? null : o.GetInt16(16), o.IsDBNull(17) ? null : o.GetDateTime(17),
                    o.GetInt32(18), o.GetInt32(19), o.GetBoolean(20), o.IsDBNull(21) ? null : o.GetInt16(21), o.IsDBNull(22) ? null : o.GetInt16(22)), iptal);

            // SEANSLAR (dönemde): fizyoterapist / kabin seanstan, yoksa programdan; ciro başvuru satırından.
            var seanslarHam = await b.ListeAsync("""
                select s.id, s.program_id, s.durum, coalesce(s.fizyoterapist_id, p.fizyoterapist_id, 0), coalesce(s.kabin_id, p.kabin_id, 0),
                       case when s.baslangic is not null and s.bitis is not null and s.bitis - s.baslangic >= interval '5 minute'
                            then round(extract(epoch from s.bitis - s.baslangic) / 60)::int else p.seans_sure_dk::int end,
                       coalesce(st.tutar, 0),
                       least(greatest(coalesce(dg.kurum, 0), 0), greatest(coalesce(st.tutar, 0), 0))
                  from public.ftr_seans s
                  join public.ftr_program p on p.id = s.program_id
                  left join public.belge_satir st on st.id = s.belge_satir_id
                  left join lateral (select sum(coalesce(x.sgk, 0) + coalesce(x.oss, 0)) as kurum
                                       from public.belge_satir_dagilim x where x.belge_satir_id = st.id) dg on true
                 where s.tarih >= @p0::date and s.tarih < @p1::date and p.durum <> 1
                   and (@p2 = 0 or coalesce(p.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => new Seans(o.GetInt32(0), o.GetInt32(1), o.GetInt16(2), o.GetInt32(3), o.GetInt32(4),
                    o.GetInt32(5), o.GetDecimal(6), o.GetDecimal(7)), iptal);

            // SÜZGEÇLER: bölge / ödeyen programdan, fizyoterapist seanstan (ya da programdan).
            var kurler = kurlerHam.Where(k => (bolge is not > 0 || k.Bolge == bolge)
                                           && (string.IsNullOrEmpty(odeyen) || Odeyen(k.KurumTur).kod == odeyen)).ToList();
            var kurIdler = kurler.Select(k => k.Id).ToHashSet();
            var seanslar = seanslarHam.Where(s => kurIdler.Contains(s.ProgramId) && (fzt is not > 0 || s.FztId == fzt)).ToList();
            if (fzt is > 0)
            {
                var fztKur = seanslar.Select(s => s.ProgramId).ToHashSet();
                kurler = kurler.Where(k => fztKur.Contains(k.Id) || k.FztId == fzt).ToList();
                kurIdler = kurler.Select(k => k.Id).ToHashSet();
            }
            var kurMap = kurler.ToDictionary(k => k.Id);
            static bool Yapildi(Seans s) => s.Durum is 3 or 6;
            var yapilan = seanslar.Where(Yapildi).ToList();

            var olcekler = await b.ListeAsync("""
                select o.program_id, o.olcek, coalesce(kd.ad, ''), o.asama, avg(o.skor)::numeric(10,2)
                  from public.ftr_olcek o
                  left join public.kod_liste kl on kl.kod = 'ftr.olcek'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = o.olcek
                 where o.program_id = any(@p0) and o.asama in (1, 3) and o.olcek <> 1
                 group by o.program_id, o.olcek, kd.ad, o.asama
                """, null, [kurIdler.ToArray()], o => (program: o.GetInt32(0), olcek: o.GetInt16(1), ad: o.GetString(2), asama: o.GetInt16(3),
                    skor: o.GetDecimal(4)), iptal);

            var uygulamalar = await b.ListeAsync("""
                select u.seans_id, coalesce(nullif(trim(u.ad), ''), 'Adsız uygulama'), coalesce(nullif(trim(u.cihaz_ad), ''), ''), u.sure_dk::int
                  from public.ftr_seans_uygulama u where u.seans_id = any(@p0) and u.yapildi = 1
                """, null, [yapilan.Select(s => s.Id).ToArray()], o => (seans: o.GetInt32(0), ad: o.GetString(1), cihaz: o.GetString(2),
                    sure: o.GetInt32(3)), iptal);

            var kabinTanim = await b.ListeAsync("""
                select k.id, k.ad, coalesce(kd.ad, ''), greatest(k.kapasite, 1)::int, coalesce(k.cihazlar, '')
                  from public.ftr_kabin k
                  join public.ftr_unite u on u.id = k.unite_id
                  left join public.kod_liste kl on kl.kod = 'ftr.kabin_tur'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = k.tur
                 where coalesce(k.aktif, 1) = 1 and (@p0 = 0 or coalesce(u.sube_id, 0) in (0, @p0))
                 order by k.tur, k.kod, k.ad
                """, null, [sube], o => (id: o.GetInt32(0), ad: o.GetString(1), tur: o.GetString(2), kapasite: o.GetInt32(3),
                    cihazlar: o.GetString(4)), iptal);

            var fztIdler = kurlerHam.Select(k => k.FztId).Concat(seanslarHam.Select(s => s.FztId)).Where(x => x > 0).Distinct().ToArray();
            var fztAdlari = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') from public.taraf t where t.id = any(@p0)
                """, null, [fztIdler], o => (id: o.GetInt32(0), ad: o.GetString(1)), iptal)).ToDictionary(x => x.id, x => x.ad);
            string FztAd(int id) => id > 0 ? fztAdlari.GetValueOrDefault(id, $"#{id}") : "Atanmamış";

            static decimal? Oran(decimal pay, decimal payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;
            static decimal? Ort(IEnumerable<decimal> v) { var l = v.ToList(); return l.Count > 0 ? Math.Round(l.Average(), 1) : null; }
            static decimal? VasFark(Kur k) => k.VasIlk is { } i && k.VasSon is { } s ? s - i : null;
            bool Donemde(DateTime? t) => t is { } x && x >= baslangic && x < bitis;
            bool AraGecikti(Kur k) => k.AraSeans > 0 && k.Plan > k.AraSeans && k.Yapilan >= k.AraSeans && !k.AraVar;
            var tamamlanan = kurler.Where(k => k.Durum == 4 && Donemde(k.Bitis)).ToList();

            // ------------------------------------------------------- fizyoterapistler --
            var fztler = seanslar.GroupBy(s => s.FztId).Select(g =>
            {
                var y = g.Where(Yapildi).ToList(); var gelmedi = g.Count(s => s.Durum == 4);
                var kids = g.Select(s => s.ProgramId).Distinct().Select(id => kurMap[id]).ToList();
                var biten = kids.Where(k => k.Durum == 4 && Donemde(k.Bitis)).ToList();
                return new
                {
                    id = g.Key, ad = FztAd(g.Key), kur = kids.Count, aktif = kids.Count(k => k.Durum is 2 or 3), seans = y.Count,
                    yarim = g.Count(s => s.Durum == 6), gelmedi, devam = Oran(y.Count, y.Count + gelmedi),
                    sureSaat = Math.Round(y.Sum(s => s.SureDk) / 60m, 1), ciro = y.Sum(s => s.Ciro), bitenKur = biten.Count,
                    vasDusus = Ort(biten.Select(VasFark).Where(x => x != null).Select(x => x!.Value)),
                    bolgeler = kids.GroupBy(k => k.BolgeAd).Select(x => new { ad = x.Key, adet = x.Count() }).OrderByDescending(x => x.adet).ToList(),
                };
            }).OrderByDescending(x => x.seans).ToList();

            // ------------------------------------------------------------------ kürler --
            var seansKur = seanslar.ToLookup(s => s.ProgramId);
            var kurListe = kurler.OrderBy(k => k.Durum switch { 5 => 0, 2 => 1, 3 => 2, _ => 3 }).ThenBy(k => k.ProgramNo).Select(k =>
            {
                var ss = seansKur[k.Id].ToList();
                var od = Odeyen(k.KurumTur);
                return new
                {
                    k.Id, programNo = k.ProgramNo, protokolNo = k.ProtokolNo, bolge = k.BolgeAd, icd = k.Icd, tani = k.Tani,
                    odeyen = od.ad, odeyenKod = od.kod, kurum = k.KurumAd, fizyoterapist = FztAd(k.FztId),
                    plan = k.Plan, yapilanToplam = k.Yapilan, donem = ss.Count(Yapildi), gelmedi = ss.Count(s => s.Durum == 4),
                    kalanHak = od.kod == "sgk" ? k.KalanHak : (int?)null, durum = DurumAdlari.GetValueOrDefault(k.Durum, ""), durumKod = k.Durum,
                    yanit = k.Durum == 4 && k.Yanit is { } yn ? YanitAdlari.GetValueOrDefault(yn, "") : "", araGecikti = AraGecikti(k),
                    ciro = ss.Where(Yapildi).Sum(s => s.Ciro),
                };
            }).ToList();

            // ----------------------------------------------------------------- ödeyen --
            var ciroT = yapilan.Sum(s => s.Ciro);
            var odeyenler = kurler.GroupBy(k => Odeyen(k.KurumTur)).Select(g =>
            {
                var ids = g.Select(k => k.Id).ToHashSet();
                var y = yapilan.Where(s => ids.Contains(s.ProgramId)).ToList();
                var ciro = y.Sum(s => s.Ciro); var kurum = y.Sum(s => s.Kurum);
                var sgk = g.Key.kod == "sgk";
                return new
                {
                    kod = g.Key.kod, ad = g.Key.ad, kur = g.Count(), seans = y.Count, seansUcreti = y.Count > 0 ? Math.Round(ciro / y.Count, 2) : 0m,
                    ciro, kurum, hasta = ciro - kurum,
                    raporKullanilan = sgk ? g.Sum(k => Math.Max(0, k.RaporHak - k.KalanHak)) : (int?)null,
                    raporHak = sgk ? g.Sum(k => k.RaporHak) : (int?)null, ciroPayi = Oran(ciro, ciroT),
                };
            }).OrderBy(x => x.kod switch { "sgk" => 0, "oss" => 1, "kurum" => 2, _ => 3 }).ToList();

            // ----------------------------------------------------------- klinik sonuç --
            var olcekMap = olcekler.ToLookup(o => o.program);
            var klinik = tamamlanan.GroupBy(k => k.BolgeAd).Select(g =>
            {
                // Bölgenin en çok kullanılan ölçeği (kür başı + kür sonu ikisi de olan kürlerde).
                var ciftler = g.SelectMany(k => olcekMap[k.Id].GroupBy(o => (o.olcek, o.ad))
                        .Where(x => x.Any(o => o.asama == 1) && x.Any(o => o.asama == 3))
                        .Select(x => (x.Key.olcek, x.Key.ad, bas: x.First(o => o.asama == 1).skor, son: x.First(o => o.asama == 3).skor))).ToList();
                var enCok = ciftler.GroupBy(c => (c.olcek, c.ad)).OrderByDescending(x => x.Count()).FirstOrDefault();
                decimal? olBas = enCok != null ? Math.Round(enCok.Average(c => c.bas), 1) : null;
                decimal? olSon = enCok != null ? Math.Round(enCok.Average(c => c.son), 1) : null;
                decimal? iyilesme = olBas is > 0 && olSon != null
                    ? Math.Round(100m * (YuksekIyi.Contains(enCok!.Key.olcek) ? olSon.Value - olBas.Value : olBas.Value - olSon.Value) / olBas.Value, 1) : null;
                var vaslar = g.Where(k => k.VasIlk != null && k.VasSon != null).ToList();
                var yanitli = g.Count(k => k.Yanit is 1 or 2 or 3);
                return new
                {
                    bolge = g.Key, olcek = enCok?.Key.ad ?? "", kur = g.Count(),
                    vasBas = vaslar.Count > 0 ? Math.Round((decimal)vaslar.Average(k => k.VasIlk!.Value), 1) : (decimal?)null,
                    vasSon = vaslar.Count > 0 ? Math.Round((decimal)vaslar.Average(k => k.VasSon!.Value), 1) : (decimal?)null,
                    olcekBas = olBas, olcekSon = olSon, iyilesme,
                    iyi = g.Count(k => k.Yanit == 1), kismi = g.Count(k => k.Yanit == 2), yanitsiz = g.Count(k => k.Yanit == 3),
                    iyiOran = Oran(g.Count(k => k.Yanit == 1), yanitli),
                };
            }).OrderByDescending(x => x.kur).ToList();
            var araGereken = kurler.Where(k => k.AraSeans > 0 && k.Plan > k.AraSeans && k.Yapilan >= k.AraSeans).ToList();
            var araDegerlendirme = new { gereken = araGereken.Count, yapildi = araGereken.Count(k => k.AraVar), gecikti = araGereken.Count(k => !k.AraVar) };

            // ------------------------------------------------------ uygulama / kabin --
            var seansMap = yapilan.ToDictionary(s => s.Id);
            var kabinTur = kabinTanim.ToDictionary(k => k.id, k => k.tur);
            var uygToplamDk = uygulamalar.Sum(u => u.sure);
            var uygListe = uygulamalar.GroupBy(u => (u.ad, u.cihaz)).Select(g => new
            {
                ad = g.Key.ad, cihaz = g.Key.cihaz,
                yer = string.Join(", ", g.Select(u => kabinTur.GetValueOrDefault(seansMap.GetValueOrDefault(u.seans)?.KabinId ?? 0, "")).Where(x => x != "").Distinct()),
                adet = g.Count(), ortDk = (int)Math.Round(g.Average(u => (decimal)u.sure)), sureSaat = Math.Round(g.Sum(u => u.sure) / 60m, 1),
                pay = Oran(g.Sum(u => u.sure), uygToplamDk),
            }).OrderByDescending(x => x.sureSaat).ToList();

            var isGunu = Enumerable.Range(0, (bitis - baslangic).Days).Count(i => baslangic.AddDays(i).DayOfWeek != DayOfWeek.Sunday);
            var kabinler = kabinTanim.Select(k =>
            {
                var dk = yapilan.Where(s => s.KabinId == k.id).Sum(s => s.SureDk);
                var kap = isGunu * GunlukSaat * k.kapasite;
                return new
                {
                    k.id, k.ad, k.tur, k.cihazlar, seans = yapilan.Count(s => s.KabinId == k.id), kullanimSaat = Math.Round(dk / 60m, 1),
                    kapasiteSaat = kap, doluluk = Oran(dk / 60m, kap),
                };
            }).ToList();
            var kabinsiz = yapilan.Count(s => s.KabinId == 0 || !kabinTur.ContainsKey(s.KabinId));
            var kullanimT = kabinler.Sum(k => k.kullanimSaat); var kapasiteT = kabinler.Sum(k => k.kapasiteSaat);

            // ----------------------------------------------------------------- özet --
            var gelmediT = seanslar.Count(s => s.Durum == 4);
            var kurumT = yapilan.Sum(s => s.Kurum);
            var sgkSeans = yapilan.Count(s => kurMap.TryGetValue(s.ProgramId, out var k) && Odeyen(k.KurumTur).kod == "sgk");
            var sgkCiro = yapilan.Where(s => kurMap.TryGetValue(s.ProgramId, out var k) && Odeyen(k.KurumTur).kod == "sgk").Sum(s => s.Ciro);
            var yanitliT = tamamlanan.Count(k => k.Yanit is 1 or 2 or 3);
            var ozet = new
            {
                kur = kurler.Count, suren = kurler.Count(k => k.Durum is 2 or 3), biten = tamamlanan.Count, yarida = kurler.Count(k => k.Durum == 5),
                seans = yapilan.Count, sureSaat = Math.Round(yapilan.Sum(s => s.SureDk) / 60m, 1), yarim = seanslar.Count(s => s.Durum == 6), planli = seanslar.Count(s => s.Durum is 1 or 2),
                gelmedi = gelmediT, iptal = seanslar.Count(s => s.Durum == 5), devam = Oran(yapilan.Count, yapilan.Count + gelmediT),
                kurBasiSeans = tamamlanan.Count > 0 ? Math.Round((decimal)tamamlanan.Average(k => k.Yapilan), 1) : (decimal?)null,
                ciro = ciroT, kurum = kurumT, hasta = ciroT - kurumT, ciroluSeans = yapilan.Count(s => s.Ciro != 0),
                medulaSeansPayi = Oran(sgkSeans, yapilan.Count), medulaCiroPayi = Oran(sgkCiro, ciroT),
                iyiYanit = Oran(tamamlanan.Count(k => k.Yanit == 1), yanitliT),
                vasDusus = Ort(tamamlanan.Select(VasFark).Where(x => x != null).Select(x => x!.Value)),
                kabinDoluluk = Oran(kullanimT, kapasiteT), kabin = kabinler.Count, kabinsizSeans = kabinsiz, isGunu,
                araGecikti = araDegerlendirme.gecikti,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, fizyoterapistler = fztler, kurler = kurListe, odeyenler,
                odeyenToplam = new { kur = kurler.Count, seans = yapilan.Count, ciro = ciroT, kurum = kurumT, hasta = ciroT - kurumT },
                klinik, araDegerlendirme, uygulamalar = uygListe,
                uygulamaToplam = new { adet = uygulamalar.Count, sureSaat = Math.Round(uygToplamDk / 60m, 1) },
                kabinler, kabinToplam = new { kullanimSaat = kullanimT, kapasiteSaat = kapasiteT, doluluk = ozet.kabinDoluluk },
                fizyoterapistAdlari = fztIdler.Select(id => new { id, ad = FztAd(id) }).OrderBy(x => x.ad),
                bolgeAdlari = kurlerHam.GroupBy(k => k.Bolge).Select(g => new { id = (int)g.Key, ad = g.First().BolgeAd }).OrderBy(x => x.ad),
            });
        });
    }
}
