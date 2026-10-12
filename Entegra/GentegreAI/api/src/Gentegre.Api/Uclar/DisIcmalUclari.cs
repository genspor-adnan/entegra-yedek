using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DİŞ İCMALİ (mockup Ekranlar/İcmal/dis_icmali.html, kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para><b>Seans</b> = durumu "Bitti" (2) olan dis_seans, dönem = seans başlangıcı. Hekim seansın,
/// yoksa planın hekimi. <b>İşlem</b> = tamamlanmış dis_seans_islem satırı. <b>Ciro</b> = işlemin başvuru
/// satırı tutarı (belge_satir_id; iptal başvuru 6 sayılmaz) - satırı olmayan işlem "faturasız" sayılır,
/// ciroya 0 girer (tahmin edilmez).</para>
///
/// <para><b>Sarf</b> = dis_seans_sarf.maliyet; seansın işlemlerine ciro oranında (ciro yoksa eşit) dağıtılır.
/// <b>Lab</b> = dis_lab_isemri.lab_fiyat, teslim tarihi dönemde olan iş; plan satırının hizmetine yazılır.
/// Brüt kâr = ciro − sarf − lab.</para>
///
/// <para><b>Plan hunisi:</b> dönemde açılan (taslak hariç) planlar; kabul = Onaylı / Sürüyor / Tamamlandı (3, 4, 5),
/// bekliyor = Sunuldu (2), iptal + süresi doldu (6, 7). Tamamlanma = tamamlandı ÷ kabul.
/// <b>Yarım kalan</b> = Onaylı / Sürüyor plan, son seanstan (yoksa onaydan) 45+ gün geçti. Neden planda yok -
/// açık lab işi › gecikmiş taksit › ertelenen satır sırasıyla çıkarılır, kalanı "Randevu almadı".</para>
///
/// <para><b>Ünite doluluğu</b> = seans süresi ÷ (iş günü Pzt-Cmt × 9 saat; ünitede çalışma saati alanı yok).
/// Hasta kimliği: yarım kalan listesinde ad + soyadın baş harfi; A4'te hasta yok.</para>
/// </summary>
public static class DisIcmalUclari
{
    /// <summary>Ekran kodu (1041) - haklarını dis.odeme'den kopyalar.</summary>
    private const string Kod = "dis.icmal";
    /// <summary>Son seanstan bu kadar gün geçen onaylı plan "yarım kalan" sayılır.</summary>
    private const int YarimKalanGun = 45;
    /// <summary>Ünite çalışma saati (dis_unit'te alan yok; kurum mesaisi 09:00-18:00).</summary>
    private const int UniteSaat = 9;

    private static readonly Dictionary<short, string> Gruplar = new()
    {
        [1] = "Restoratif", [2] = "Endodonti", [3] = "Protetik", [4] = "Cerrahi", [5] = "Periodontal", [6] = "Ortodonti",
        [7] = "Pedodonti", [8] = "Estetik", [9] = "Muayene / görüntüleme",
    };
    private static readonly Dictionary<short, string> LabIsTurleri = new()
    {
        [1] = "Kron", [2] = "Köprü", [3] = "İmplant üstü", [4] = "Total protez", [5] = "Parsiyel protez", [6] = "Ortodonti apareyi",
        [7] = "Gece plağı", [8] = "Diğer",
    };

    private sealed record Seans(int Id, int HekimId, string Hekim, string Brans, int HastaId, int UnitId, int SureDk);
    private sealed record IslemSatiri(int Id, int SeansId, int HizmetId, string Hizmet, short Grup, decimal Ciro, bool Faturali);
    private sealed record LabIs(int Id, int LabId, string Lab, int Sla, short IsTuru, int HizmetId, string Hizmet, short Grup, int HekimId,
                                decimal LabFiyat, decimal HastaFiyat, DateTime? Gonderim, DateTime? Beklenen, DateTime? Teslim, short Asama);
    private sealed record Plan(int Id, string No, int HekimId, string Hekim, decimal Net, short Durum, DateTime Ekleme, decimal Yapilan,
                               DateTime? SonSeans, DateTime Onay, decimal Tahsil, bool LabBekliyor, bool OdemeBekliyor, bool Ertelendi,
                               string Hasta, string Protokol);

    public static void DisIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dis-icmal").WithTags("Diş İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? hekim, short? islemGrubu,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var bugun = DateTime.Today;
            var sube = baglam.SubeId ?? 0;
            var hk = hekim ?? 0;
            var gr = islemGrubu ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var seanslarHam = await b.ListeAsync("""
                select s.id, coalesce(s.hekim_id, p.hekim_id, 0),
                       coalesce(nullif(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), 'Hekim belirtilmemiş'),
                       coalesce(tp.brans, ''), coalesce(s.hasta_id, 0), coalesce(s.unit_id, 0), coalesce(s.sure_dk, 0)::int
                  from public.dis_seans s
                  left join public.dis_tedavi_plani p on p.id = s.plan_id
                  left join public.taraf h on h.id = coalesce(s.hekim_id, p.hekim_id)
                  left join public.taraf_personel tp on tp.id = h.id
                 where s.durum = 2 and s.baslangic >= @p0 and s.baslangic < @p1
                   and (@p2 = 0 or coalesce(s.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => new Seans(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetString(3),
                    o.GetInt32(4), o.GetInt32(5), o.GetInt32(6)), iptal);
            var hekimAdlari = seanslarHam.Where(s => s.HekimId > 0).GroupBy(s => s.HekimId)
                .Select(g => new { id = g.Key, ad = g.First().Hekim }).OrderBy(x => x.ad).ToList();
            var seanslar = seanslarHam.Where(s => hk == 0 || s.HekimId == hk).ToList();

            var islemlerHam = await b.ListeAsync("""
                select i.id, i.seans_id, coalesce(i.hizmet_id, 0), coalesce(hz.ad, 'İşlem belirtilmemiş'),
                       coalesce(hz.dis_islem_grubu, 0)::smallint, coalesce(bs.tutar, 0), bs.id is not null
                  from public.dis_seans_islem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                  left join public.belge_satir bs on bs.id = i.belge_satir_id
                       and not exists (select 1 from public.belge be where be.id = bs.belge_id and be.durum = 6)
                 where i.seans_id = any(@p0) and coalesce(i.tamamlandi, 0) = 1
                """, null, [seanslar.Select(s => s.Id).ToArray()], o => new IslemSatiri(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2),
                    o.GetString(3), o.GetInt16(4), o.GetDecimal(5), o.GetBoolean(6)), iptal);
            var islemler = islemlerHam.Where(i => gr == 0 || i.Grup == gr).ToList();
            // İşlem grubu süzgecinde seans = o gruptan işlem yapılan seans.
            if (gr != 0) { var ids = islemler.Select(i => i.SeansId).ToHashSet(); seanslar = seanslar.Where(s => ids.Contains(s.Id)).ToList(); }

            var sarflar = await b.ListeAsync("""
                select x.seans_id, coalesce(sum(x.maliyet), 0) from public.dis_seans_sarf x where x.seans_id = any(@p0) group by x.seans_id
                """, null, [seanslar.Select(s => s.Id).ToArray()], o => (seans: o.GetInt32(0), maliyet: o.GetDecimal(1)), iptal);

            var labHam = await b.ListeAsync("""
                select l.id, coalesce(l.lab_id, 0), coalesce(d.ad, 'Laboratuvar belirtilmemiş'), coalesce(d.sla_gun, 0)::int,
                       coalesce(l.is_turu, 0)::smallint, coalesce(hz.id, 0), coalesce(hz.ad, ''), coalesce(hz.dis_islem_grubu, 0)::smallint,
                       coalesce(l.hekim_id, ps.hekim_id, p.hekim_id, 0), coalesce(l.lab_fiyat, 0), coalesce(l.hasta_fiyat, 0),
                       l.gonderim_tarihi, l.beklenen_tarih, l.teslim_tarihi, coalesce(l.asama, 1)::smallint
                  from public.dis_lab_isemri l
                  left join public.dis_lab d on d.id = l.lab_id
                  left join public.dis_tedavi_plani_satir ps on ps.id = l.plan_satir_id
                  left join public.dis_tedavi_plani p on p.id = ps.plan_id
                  left join public.hizmet hz on hz.id = ps.hizmet_id
                 where coalesce(l.asama, 1) <> 9 and (@p2 = 0 or coalesce(l.sube_id, 0) in (0, @p2))
                   and ((l.teslim_tarihi >= @p0::date and l.teslim_tarihi < @p1::date)
                        or (l.gonderim_tarihi >= @p0::date and l.gonderim_tarihi < @p1::date)
                        or (l.teslim_tarihi is null and coalesce(l.asama, 1) <> 8 and l.beklenen_tarih < @p1::date))
                """, null, [baslangic, bitis, sube], o => new LabIs(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetInt32(3),
                    o.GetInt16(4), o.GetInt32(5), o.GetString(6), o.GetInt16(7), o.GetInt32(8), o.GetDecimal(9), o.GetDecimal(10),
                    o.IsDBNull(11) ? null : o.GetDateTime(11), o.IsDBNull(12) ? null : o.GetDateTime(12),
                    o.IsDBNull(13) ? null : o.GetDateTime(13), o.GetInt16(14)), iptal);
            var labIsler = labHam.Where(l => (hk == 0 || l.HekimId == hk) && (gr == 0 || l.Grup == gr)).ToList();

            var planlarHam = await b.ListeAsync("""
                select p.id, coalesce(p.plan_no, ''),
                       coalesce(p.hekim_id, (select min(x.hekim_id) from public.dis_tedavi_plani_satir x where x.plan_id = p.id), 0),
                       coalesce(nullif(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), 'Hekim belirtilmemiş'),
                       coalesce(p.net, 0), coalesce(p.durum, 1)::smallint, coalesce(p.ekleme_tarihi, now()),
                       coalesce((select sum(x.net) from public.dis_tedavi_plani_satir x where x.plan_id = p.id and x.durum = 3), 0),
                       (select max(x.baslangic) from public.dis_seans x where x.plan_id = p.id and x.durum = 2),
                       coalesce(p.hasta_onay_zamani, p.ekleme_tarihi, now()),
                       coalesce((select sum(coalesce(t.odenen, 0)) from public.dis_odeme_taksit t
                                   join public.dis_odeme_plani o on o.id = t.odeme_plani_id
                                  where o.plan_id = p.id and coalesce(o.durum, 1) <> 3), 0),
                       exists (select 1 from public.dis_lab_isemri l join public.dis_tedavi_plani_satir x on x.id = l.plan_satir_id
                                where x.plan_id = p.id and l.teslim_tarihi is null and coalesce(l.asama, 1) not in (8, 9)),
                       exists (select 1 from public.dis_odeme_taksit t join public.dis_odeme_plani o on o.id = t.odeme_plani_id
                                where o.plan_id = p.id and coalesce(o.durum, 1) <> 3 and t.vade < current_date
                                  and coalesce(t.odenen, 0) < coalesce(t.tutar, 0)),
                       exists (select 1 from public.dis_tedavi_plani_satir x where x.plan_id = p.id and x.durum = 5),
                       case when coalesce(t.ad, '') <> '' then t.ad || ' ' || left(coalesce(t.soyad, ''), 1) || '.'
                            else split_part(coalesce(t.unvan, ''), ' ', 1) || ' '
                                 || left(regexp_replace(coalesce(t.unvan, ''), '^.*\s', ''), 1) || '.' end,
                       coalesce((select be.belge_no from public.dis_seans x join public.belge be on be.id = x.belge_id
                                  where x.plan_id = p.id order by x.baslangic desc limit 1), '')
                  from public.dis_tedavi_plani p
                  left join public.taraf h on h.id = coalesce(p.hekim_id,
                       (select min(x.hekim_id) from public.dis_tedavi_plani_satir x where x.plan_id = p.id))
                  left join public.taraf t on t.id = p.hasta_id
                 where (@p2 = 0 or coalesce(p.sube_id, 0) in (0, @p2))
                   and ((p.ekleme_tarihi >= @p0 and p.ekleme_tarihi < @p1 and p.durum <> 1) or p.durum in (3, 4))
                """, null, [baslangic, bitis, sube], o => new Plan(o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetString(3),
                    o.GetDecimal(4), o.GetInt16(5), o.GetDateTime(6), o.GetDecimal(7), o.IsDBNull(8) ? null : o.GetDateTime(8),
                    o.GetDateTime(9), o.GetDecimal(10), o.GetBoolean(11), o.GetBoolean(12), o.GetBoolean(13), o.GetString(14),
                    o.GetString(15)), iptal);
            var planlar = planlarHam.Where(p => hk == 0 || p.HekimId == hk).ToList();

            var uniteler = await b.ListeAsync("""
                select u.id, coalesce(u.kod, ''), coalesce(u.ad, '') from public.dis_unit u
                 where coalesce(u.aktif, 1) = 1 and (@p0 = 0 or coalesce(u.sube_id, 0) in (0, @p0))
                 order by u.kod, u.ad
                """, null, [sube], o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2)), iptal);

            // --------------------------------------------------- işlem maliyetleri --
            // Seans sarfı işlemlerine ciro oranında (ciro yoksa eşit) dağıtılır.
            var seansSarf = sarflar.ToDictionary(x => x.seans, x => x.maliyet);
            var islemSarf = new Dictionary<int, decimal>();
            foreach (var g in islemler.GroupBy(i => i.SeansId))
            {
                var toplam = seansSarf.GetValueOrDefault(g.Key);
                var ciro = g.Sum(i => i.Ciro);
                foreach (var i in g) islemSarf[i.Id] = ciro > 0 ? Math.Round(toplam * i.Ciro / ciro, 2) : Math.Round(toplam / g.Count(), 2);
            }
            // İşlemi olmayan seansın sarfı yine hekime yazılır (işlem tablosunda "işlemsiz seans").
            var islemliSeans = islemler.Select(i => i.SeansId).ToHashSet();
            bool Donemde(DateTime? t) => t is { } x && x >= baslangic && x < bitis;
            var teslimLab = labIsler.Where(l => Donemde(l.Teslim)).ToList();
            var seansMap = seanslar.ToDictionary(s => s.Id);

            static decimal? Oran(decimal pay, decimal payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;
            var toplamCiro = islemler.Sum(i => i.Ciro);

            // --------------------------------------------------------- işlem türleri --
            var turAnahtarlari = islemler.Select(i => (i.HizmetId, i.Hizmet, i.Grup))
                .Concat(teslimLab.Where(l => l.HizmetId > 0).Select(l => (l.HizmetId, l.Hizmet, l.Grup))).DistinctBy(x => x.HizmetId).ToList();
            var islemTurleri = turAnahtarlari.Select(k =>
            {
                var l = islemler.Where(i => i.HizmetId == k.HizmetId).ToList();
                var ciro = l.Sum(i => i.Ciro);
                var sarf = l.Sum(i => islemSarf.GetValueOrDefault(i.Id));
                var lab = teslimLab.Where(x => x.HizmetId == k.HizmetId).Sum(x => x.LabFiyat);
                return new
                {
                    hizmetId = k.HizmetId, ad = k.Hizmet, grup = Gruplar.GetValueOrDefault(k.Grup, "Grupsuz"), adet = l.Count, ciro,
                    ortFiyat = l.Count > 0 ? Math.Round(ciro / l.Count, 2) : 0m, sarf, lab, kar = ciro - sarf - lab, marj = Oran(ciro - sarf - lab, ciro),
                    hekim = l.Select(i => seansMap.TryGetValue(i.SeansId, out var s) ? s.HekimId : 0).Distinct().Count(),
                    ciroPayi = Oran(ciro, toplamCiro), faturasiz = l.Count(i => !i.Faturali),
                };
            }).OrderByDescending(x => x.ciro).ThenByDescending(x => x.adet).ToList();

            // ---------------------------------------------------------------- planlar --
            var sunulan = planlar.Where(p => p.Ekleme >= baslangic && p.Ekleme < bitis && p.Durum != 1).ToList();
            static bool Kabul(Plan p) => p.Durum is 3 or 4 or 5;
            object PlanSatiri(string ad, List<Plan> l)
            {
                var kabul = l.Where(Kabul).ToList();
                return new
                {
                    hekim = ad, sunulan = l.Count, tutar = l.Sum(p => p.Net), bekliyor = l.Count(p => p.Durum == 2), kabul = kabul.Count,
                    kabulTutar = kabul.Sum(p => p.Net), kabulYuzde = Oran(kabul.Count, l.Count), suruyor = l.Count(p => p.Durum == 4),
                    tamam = l.Count(p => p.Durum == 5), tamamYuzde = Oran(l.Count(p => p.Durum == 5), kabul.Count),
                    iptal = l.Count(p => p.Durum is 6 or 7), yapilanTutar = kabul.Sum(p => p.Yapilan),
                };
            }
            var planHekim = sunulan.GroupBy(p => (p.HekimId, p.Hekim)).OrderBy(g => g.Key.Hekim).Select(g => PlanSatiri(g.Key.Hekim, g.ToList())).ToList();
            var kabulSay = sunulan.Count(Kabul);
            var tamamSay = sunulan.Count(p => p.Durum == 5);

            var yarimKalan = planlar.Where(p => p.Durum is 3 or 4).Select(p =>
            {
                var son = p.SonSeans ?? p.Onay;
                var gun = (int)(bugun - son.Date).TotalDays;
                var neden = p.LabBekliyor ? "Lab bekliyor" : p.OdemeBekliyor ? "Ödeme bekliyor" : p.Ertelendi ? "Hasta erteledi" : "Randevu almadı";
                return new
                {
                    p.Id, planNo = p.No, protokolNo = p.Protokol, hasta = p.Hasta.Trim(), hekim = p.Hekim, tutar = p.Net, yapilan = p.Yapilan,
                    kalan = p.Net - p.Yapilan, tahsil = p.Tahsil, sonSeans = p.SonSeans, gun, seansYok = p.SonSeans == null, neden,
                };
            }).Where(x => x.gun >= YarimKalanGun).OrderByDescending(x => x.kalan).ToList();

            // ---------------------------------------------------------------- hekimler --
            var hekimIdleri = seanslar.Select(s => (HekimId: s.HekimId, Hekim: s.Hekim, Brans: s.Brans))
                .Concat(teslimLab.Where(l => !seanslar.Any(s => s.HekimId == l.HekimId))
                    .Select(l => (HekimId: l.HekimId, Hekim: planlarHam.FirstOrDefault(p => p.HekimId == l.HekimId)?.Hekim ?? "Hekim belirtilmemiş", Brans: "")))
                .DistinctBy(x => x.HekimId).ToList();
            var hekimler = hekimIdleri.Select(h =>
            {
                var hs = seanslar.Where(s => s.HekimId == h.HekimId).ToList();
                var hsIds = hs.Select(s => s.Id).ToHashSet();
                var hi = islemler.Where(i => hsIds.Contains(i.SeansId)).ToList();
                var ciro = hi.Sum(i => i.Ciro);
                var sarf = hi.Sum(i => islemSarf.GetValueOrDefault(i.Id)) + hs.Where(s => !islemliSeans.Contains(s.Id)).Sum(s => seansSarf.GetValueOrDefault(s.Id));
                var hl = teslimLab.Where(l => l.HekimId == h.HekimId).ToList();
                var lab = hl.Sum(l => l.LabFiyat);
                var hp = sunulan.Where(p => p.HekimId == h.HekimId).ToList();
                var sure = hs.Where(s => s.SureDk > 0).Select(s => s.SureDk).ToList();
                return new
                {
                    id = h.HekimId, ad = h.Hekim, brans = h.Brans, seans = hs.Count, hasta = hs.Select(s => s.HastaId).Distinct().Count(), islem = hi.Count,
                    ciro, sarf, lab, sarfLab = sarf + lab, kar = ciro - sarf - lab, marj = Oran(ciro - sarf - lab, ciro), planKabul = Oran(hp.Count(Kabul), hp.Count),
                    ortSeansDk = sure.Count > 0 ? (int)Math.Round(sure.Average()) : (int?)null, ciroPayi = Oran(ciro, toplamCiro),
                    islemler = hi.GroupBy(i => (i.HizmetId, i.Hizmet, i.Grup)).Select(g =>
                    {
                        var c = g.Sum(i => i.Ciro); var sr = g.Sum(i => islemSarf.GetValueOrDefault(i.Id));
                        var lb = hl.Where(l => l.HizmetId == g.Key.HizmetId).Sum(l => l.LabFiyat);
                        return new { ad = g.Key.Hizmet, grup = Gruplar.GetValueOrDefault(g.Key.Grup, "Grupsuz"), adet = g.Count(), ciro = c, sarf = sr, lab = lb, kar = c - sr - lb };
                    }).OrderByDescending(x => x.ciro).ThenByDescending(x => x.adet).ToList(),
                };
            }).OrderByDescending(x => x.ciro).ThenBy(x => x.ad).ToList();

            // --------------------------------------------------------- laboratuvarlar --
            var laboratuvarlar = labIsler.GroupBy(l => (l.LabId, l.Lab)).Select(g =>
            {
                var gelen = g.Where(l => Donemde(l.Teslim)).ToList();
                var acik = g.Where(l => l.Teslim == null && l.Asama != 8).ToList();
                var gec = gelen.Count(l => l.Beklenen is { } be && l.Teslim > be) + acik.Count(l => l.Beklenen is { } be && be < bugun);
                var anaIs = g.GroupBy(l => l.Hizmet != "" ? l.Hizmet : LabIsTurleri.GetValueOrDefault(l.IsTuru, "Diğer"))
                    .OrderByDescending(x => x.Count()).Select(x => x.Key).FirstOrDefault() ?? "";
                var sureler = gelen.Where(l => l.Gonderim != null).Select(l => (l.Teslim!.Value - l.Gonderim!.Value).TotalDays).ToList();
                return new
                {
                    id = g.Key.LabId, ad = g.Key.Lab, anaIs, isAdet = gelen.Count, acik = acik.Count, labBedeli = gelen.Sum(l => l.LabFiyat),
                    hastaya = gelen.Sum(l => l.HastaFiyat), fark = gelen.Sum(l => l.HastaFiyat - l.LabFiyat), slaGun = g.First().Sla,
                    ortSureGun = sureler.Count > 0 ? Math.Round((decimal)sureler.Average(), 1) : (decimal?)null, gec,
                };
            }).OrderByDescending(x => x.labBedeli).ThenBy(x => x.ad).ToList();

            // ------------------------------------------------------------------ üniteler --
            var isGunu = Enumerable.Range(0, (bitis - baslangic).Days).Select(i => baslangic.AddDays(i)).Count(d => d.DayOfWeek != DayOfWeek.Sunday);
            var kapasiteSaat = isGunu * UniteSaat;
            var uniteAdlari = uniteler.Select(u => (u.id, ad: u.ad != "" ? u.ad : u.kod)).ToList();
            if (seanslar.Any(s => s.UnitId == 0 || !uniteler.Any(u => u.id == s.UnitId))) uniteAdlari.Add((0, "Ünite belirtilmemiş"));
            var uniteListe = uniteAdlari
                .Select(u =>
                {
                    var us = seanslar.Where(s => u.id == 0 ? s.UnitId == 0 || !uniteler.Any(x => x.id == s.UnitId) : s.UnitId == u.id).ToList();
                    var kullanim = Math.Round(us.Sum(s => s.SureDk) / 60m, 1);
                    return new
                    {
                        u.id, u.ad, hekimler = us.Select(s => s.Hekim).Distinct().ToList(), seans = us.Count, kullanimSaat = kullanim,
                        kapasiteSaat = u.id == 0 ? (int?)null : kapasiteSaat, doluluk = u.id == 0 ? null : Oran(kullanim, kapasiteSaat),
                    };
                }).ToList();
            var tanimliUnite = uniteListe.Where(u => u.id > 0).ToList();
            var uniteKullanim = tanimliUnite.Sum(u => u.kullanimSaat);
            var uniteKapasite = kapasiteSaat * tanimliUnite.Count;

            // ------------------------------------------------------------------ toplam --
            var toplamSarf = islemler.Sum(i => islemSarf.GetValueOrDefault(i.Id)) + seanslar.Where(s => !islemliSeans.Contains(s.Id)).Sum(s => seansSarf.GetValueOrDefault(s.Id));
            var toplamLab = teslimLab.Sum(l => l.LabFiyat);
            var sureT = seanslar.Where(s => s.SureDk > 0).Select(s => s.SureDk).ToList();
            var ozet = new
            {
                seans = seanslar.Count, hasta = seanslar.Select(s => s.HastaId).Distinct().Count(),
                hekimHastaToplami = hekimler.Sum(h => h.hasta), islem = islemler.Count, faturasiz = islemler.Count(i => !i.Faturali),
                ciro = toplamCiro, sarf = toplamSarf, lab = toplamLab, sarfLab = toplamSarf + toplamLab, kar = toplamCiro - toplamSarf - toplamLab,
                marj = Oran(toplamCiro - toplamSarf - toplamLab, toplamCiro),
                planSunulan = sunulan.Count, planSunulanTutar = sunulan.Sum(p => p.Net), planKabul = kabulSay,
                planKabulTutar = sunulan.Where(Kabul).Sum(p => p.Net), kabulYuzde = Oran(kabulSay, sunulan.Count),
                planSuruyor = sunulan.Count(p => p.Durum == 4), planTamam = tamamSay, tamamYuzde = Oran(tamamSay, kabulSay),
                planBekliyor = sunulan.Count(p => p.Durum == 2), planIptal = sunulan.Count(p => p.Durum is 6 or 7),
                planYapilanTutar = sunulan.Where(Kabul).Sum(p => p.Yapilan),
                yarimAdet = yarimKalan.Count, yarimTutar = yarimKalan.Sum(y => y.tutar), yarimYapilan = yarimKalan.Sum(y => y.yapilan),
                yarimKalan = yarimKalan.Sum(y => y.kalan), yarimTahsil = yarimKalan.Sum(y => y.tahsil),
                yarimFark = yarimKalan.Sum(y => y.tahsil) - yarimKalan.Sum(y => y.yapilan), yarimGun = YarimKalanGun,
                uniteSayisi = tanimliUnite.Count, uniteKullanim, uniteKapasite, uniteDoluluk = Oran(uniteKullanim, uniteKapasite),
                ortSeansDk = sureT.Count > 0 ? (int)Math.Round(sureT.Average()) : (int?)null, isGunu, uniteSaat = UniteSaat,
                labIs = laboratuvarlar.Sum(l => l.isAdet), labHastaya = laboratuvarlar.Sum(l => l.hastaya), labFark = laboratuvarlar.Sum(l => l.fark),
                labGec = laboratuvarlar.Sum(l => l.gec), labAcik = laboratuvarlar.Sum(l => l.acik),
                islemSarf = islemTurleri.Sum(t => t.sarf), islemLab = islemTurleri.Sum(t => t.lab),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, hekimler, planHekim, yarimKalan, islemTurleri, laboratuvarlar,
                uniteler = uniteListe, hekimAdlari,
                gruplar = Gruplar.Select(x => new { id = x.Key, ad = x.Value }),
            });
        });
    }
}
