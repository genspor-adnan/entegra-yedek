using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LABORATUVAR İCMALİ (mockup Ekranlar/İcmal/laboratuvar_icmali.html,
/// kullanıcı 10.10.2026: "laboratuvar icmalini kodla").
///
/// <para><b>Birim = istem kalemi.</b> Panel tek kalem sayılır: aynı başvuruda
/// panelin tetkikleri tek birimde toplanır (faturada da panel tek satırdır).
/// Kaynak yalnız tür 19 başvuruların istemleri; iptal başvuru ve iptal kalem
/// (durum 0) hariç.</para>
///
/// <para><b>Ciro faturadan, hizmet üzerinden.</b> lab_istem_satir.belge_satir_id
/// boş geliyor; kalem başvurunun AYNI HİZMETLİ satırına bağlanır (panelde
/// panelin hizmeti). Kurum payı o satırların dağılımından (sgk + öss, satır
/// tutarını aşamaz). Faturada karşılığı olmayan kalemin cirosu 0'dır.</para>
///
/// <para><b>Maliyet.</b> İç lab: tetkik tanımındaki test başı maliyet ×
/// (1 + tekrar). Dış lab: gönderim satırının fiyatı, yoksa dış lab fiyat
/// listesi. QC / kalibrasyon brüt kâra girmez.</para>
///
/// <para><b>Süre (TAT).</b> Numune kabul → sonuç onayı; hedef tetkikten (acil
/// istemde acil hedef). Panelde en geç onaylanan tetkik. Özet ortalaması
/// rutin iç lab içindir (mikrobiyoloji ve dış lab hariç).</para>
/// </summary>
public static class LabIcmalUclari
{
    /// <summary>Ekran kodu (1026) - haklarını lab'dan kopyalar.</summary>
    private const string Kod = "lab.icmal";
    private const short Mikrobiyoloji = 4;

    private sealed record Kalem(
        int SatirId, int IstemId, int BelgeId, string ProtokolNo, DateTime Tarih, int HastaId, short Oncelik,
        string BirimAnahtar, string BirimKod, string BirimAd, short Grup, int HizmetId,
        int TetkikId, decimal TestMaliyet, int HedefDk, DateTime? Kabul, DateTime? Onay,
        int CihazId, string CihazAd, int Tekrar, int DisLabId, string DisLabAd, decimal? DisFiyat,
        DateTime? DisGonderim, DateTime? DisSonuc, int BolumId, string BolumAd);

    public static void LabIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/lab-icmal").WithTags("Laboratuvar İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, short? tetkikGrubu, int? bolum,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var hepsi = await b.ListeAsync("""
                select s.id, i.id, be.id, coalesce(be.belge_no, ''), i.istem_tarihi, coalesce(i.taraf_id, 0),
                       coalesce(i.oncelik, 1)::smallint,
                       case when p.id is not null then 'p' || p.id else 't' || coalesce(s.tetkik_id, -s.id) end,
                       coalesce(p.kod, t.kod, s.kod, ''), coalesce(p.ad, t.ad, s.ad, ''),
                       coalesce(p.bolum, t.bolum, 9)::smallint, coalesce(p.hizmet_id, t.hizmet_id, 0),
                       coalesce(s.tetkik_id, 0), coalesce(t.test_basi_maliyet, 0),
                       coalesce(case when i.oncelik = 3 then coalesce(nullif(t.acil_tat_dk, 0), t.hedef_tat_dk)
                                     else t.hedef_tat_dk end, 0),
                       n.kabul_zamani,
                       coalesce(so.onay, case when s.durum = 5 then s.sonuc_tarihi end),
                       coalesce(so.cihaz_id, s.cihaz_id, t.varsayilan_cihaz_id, 0), coalesce(c.ad, ''),
                       (select count(*)::int from public.lab_tekrar_istegi ti
                         where ti.istem_satir_id = s.id and ti.durum <> 3),
                       coalesce(dg.dis_lab_id, 0), coalesce(dl.ad, ''),
                       coalesce(nullif(ds.birim_fiyat, 0), dt.birim_fiyat),
                       dg.gonderim_zamani, ds.sonuc_zamani,
                       coalesce(bb.bolum_id, 0), coalesce(d.ad, '')
                  from public.lab_istem_satir s
                  join public.lab_istem i on i.id = s.istem_id
                  join public.belge be on be.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = be.id
                  left join public.departman d on d.id = bb.bolum_id
                  left join public.lab_tetkik t on t.id = s.tetkik_id
                  left join public.lab_panel p on p.id = s.panel_id
                  left join public.lab_numune n on n.id = s.numune_id
                  left join lateral (
                      select max(ls.onay_zamani) as onay, max(ls.cihaz_id) as cihaz_id
                        from public.lab_sonuc ls where ls.istem_satir_id = s.id) so on true
                  left join public.cihaz c on c.id = coalesce(so.cihaz_id, s.cihaz_id, t.varsayilan_cihaz_id)
                  left join lateral (
                      select x.gonderim_id, x.birim_fiyat, x.sonuc_zamani
                        from public.lab_dis_gonderim_satir x
                       where x.istem_satir_id = s.id order by x.id desc limit 1) ds on true
                  left join public.lab_dis_gonderim dg on dg.id = coalesce(ds.gonderim_id, s.dis_gonderim_id)
                  left join public.lab_dis_lab dl on dl.id = dg.dis_lab_id
                  left join lateral (
                      select x.birim_fiyat from public.lab_dis_test x
                       where x.dis_lab_id = dg.dis_lab_id and x.tetkik_id = s.tetkik_id
                       order by x.id desc limit 1) dt on true
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6 and s.durum <> 0
                   and i.istem_tarihi >= @p0 and i.istem_tarihi < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => new Kalem(
                    o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetDateTime(4), o.GetInt32(5),
                    o.GetInt16(6), o.GetString(7), o.GetString(8), o.GetString(9), o.GetInt16(10), o.GetInt32(11),
                    o.GetInt32(12), o.GetDecimal(13), o.GetInt32(14),
                    o.IsDBNull(15) ? null : o.GetDateTime(15), o.IsDBNull(16) ? null : o.GetDateTime(16),
                    o.GetInt32(17), o.GetString(18), o.GetInt32(19), o.GetInt32(20), o.GetString(21),
                    o.IsDBNull(22) ? null : o.GetDecimal(22),
                    o.IsDBNull(23) ? null : o.GetDateTime(23), o.IsDBNull(24) ? null : o.GetDateTime(24),
                    o.GetInt32(25), o.GetString(26)), iptal);

            // Panel bölümü tetkik kod uzayının dışında olabilir: bilinmeyen kod "Diğer" (9).
            hepsi = hepsi.Select(x => KartKatalogu.LabTetkikBolumleri().Any(k => k.Kod == x.Grup) ? x : x with { Grup = 9 }).ToList();

            // Şerit seçenekleri süzgeçten ÖNCE: süzülen değer listeden düşmesin.
            var bolumAdlari = hepsi.Where(x => x.BolumId > 0).Select(x => new { id = x.BolumId, ad = x.BolumAd })
                                   .DistinctBy(x => x.id).OrderBy(x => x.ad).ToList();
            var kalemler = hepsi.Where(x => (tetkikGrubu is not > 0 || x.Grup == tetkikGrubu)
                                         && (bolum is not > 0 || x.BolumId == bolum)).ToList();

            // FATURA: (başvuru, hizmet) başına satır tutarı ve kurum payı.
            var belgeIdler = kalemler.Select(x => x.BelgeId).Distinct().ToArray();
            var fatura = (await b.ListeAsync("""
                select st.belge_id, st.hizmet_id, sum(st.tutar),
                       sum(least(greatest(coalesce(dg.kurum, 0), 0), greatest(st.tutar, 0)))
                  from public.belge_satir st
                  left join lateral (
                      select sum(coalesce(x.sgk, 0) + coalesce(x.oss, 0)) as kurum
                        from public.belge_satir_dagilim x where x.belge_satir_id = st.id) dg on true
                 where st.belge_id = any(@p0) and st.hizmet_id is not null
                 group by st.belge_id, st.hizmet_id
                """, null, [belgeIdler], o => (belge: o.GetInt32(0), hizmet: o.GetInt32(1),
                    tutar: o.GetDecimal(2), kurum: o.GetDecimal(3)), iptal))
                .ToDictionary(x => (x.belge, x.hizmet));

            // BİRİM: (başvuru, panel ya da tetkik).
            var birimler = kalemler.GroupBy(x => (x.BelgeId, x.BirimAnahtar)).Select(g =>
            {
                var k = g.First();
                fatura.TryGetValue((k.BelgeId, k.HizmetId), out var f);
                var dis = g.Any(x => x.DisLabId > 0);
                var tekrar = g.Sum(x => x.Tekrar);
                var maliyet = g.Sum(x => x.DisLabId > 0 ? x.DisFiyat ?? 0 : x.TestMaliyet * (1 + x.Tekrar));
                var kabul = g.Where(x => x.Kabul != null).Select(x => x.Kabul!.Value).DefaultIfEmpty().Min();
                var onayli = g.All(x => x.Onay != null);
                DateTime? onay = onayli ? g.Max(x => x.Onay) : null;
                int? tat = kabul != default && onay != null && onay > kabul ? (int)Math.Round((onay.Value - kabul).TotalMinutes) : null;
                var hedef = g.Max(x => x.HedefDk);
                return new
                {
                    k.BelgeId, k.ProtokolNo, k.Tarih, k.HastaId, k.IstemId, k.BirimAnahtar, k.BirimKod, k.BirimAd, k.Grup,
                    k.BolumId, k.BolumAd, Ciro = f.tutar, Kurum = f.kurum, Faturali = f.tutar != 0,
                    Dis = dis, DisLabId = g.Max(x => x.DisLabId), DisLabAd = g.Max(x => x.DisLabAd) ?? "",
                    Maliyet = maliyet, Tekrar = tekrar, Tat = tat, Hedef = hedef,
                    Asim = tat != null && hedef > 0 && tat > hedef ? tat - hedef : null,
                    DisGun = g.Where(x => x.DisGonderim != null && x.DisSonuc != null)
                              .Select(x => (decimal?)(decimal)(x.DisSonuc!.Value - x.DisGonderim!.Value).TotalDays).Max(),
                };
            }).ToList();

            static string GrupAdi(short g) => KartKatalogu.LabTetkikBolumAdi(g);
            static decimal? Marj(decimal ciro, decimal maliyet) => ciro > 0 ? Math.Round(100 * (ciro - maliyet) / ciro, 1) : null;
            static decimal? Ort(IEnumerable<int?> v) { var l = v.Where(x => x != null).Select(x => (decimal)x!.Value).ToList();
                return l.Count > 0 ? Math.Round(l.Average(), 0) : null; }

            var tetkikler = birimler.GroupBy(x => x.BirimAnahtar).Select(g =>
            {
                var f = g.First(); var ciro = g.Sum(x => x.Ciro); var mal = g.Sum(x => x.Maliyet); var adet = g.Count();
                return new
                {
                    anahtar = g.Key, kod = f.BirimKod, ad = f.BirimAd, grup = f.Grup, grupAd = GrupAdi(f.Grup),
                    dis = g.Any(x => x.Dis), adet, ciro, kurum = g.Sum(x => x.Kurum),
                    birimFiyat = adet > 0 ? Math.Round(ciro / adet, 2) : 0m,
                    kurumYuzde = ciro > 0 ? Math.Round(100 * g.Sum(x => x.Kurum) / ciro, 0) : 0m,
                    maliyet = mal, testMaliyet = adet > 0 ? Math.Round(mal / adet, 2) : 0m, marj = Marj(ciro, mal),
                    ortTat = Ort(g.Select(x => x.Tat)), disGun = g.Select(x => x.DisGun).Where(x => x != null).DefaultIfEmpty().Average(),
                    tekrar = g.Sum(x => x.Tekrar), asan = g.Count(x => x.Asim != null), faturasiz = g.Count(x => !x.Faturali),
                    bolumler = g.GroupBy(x => x.BolumAd == "" ? "Belirsiz" : x.BolumAd)
                                .Select(h => new { ad = h.Key, adet = h.Count() }).OrderByDescending(h => h.adet).ToList(),
                };
            }).OrderBy(x => x.dis).ThenBy(x => x.grup).ThenByDescending(x => x.ciro).ToList();

            var gruplar = birimler.GroupBy(x => x.Grup).Select(g =>
            {
                var ciro = g.Sum(x => x.Ciro); var mal = g.Sum(x => x.Maliyet);
                return new
                {
                    grup = g.Key, ad = GrupAdi(g.Key), cesit = g.Select(x => x.BirimAnahtar).Distinct().Count(), adet = g.Count(),
                    ciro, kurum = g.Sum(x => x.Kurum), hasta = ciro - g.Sum(x => x.Kurum), maliyet = mal, kar = ciro - mal,
                    marj = Marj(ciro, mal), tekrar = g.Sum(x => x.Tekrar),
                };
            }).OrderByDescending(x => x.ciro).ToList();

            // CİHAZ: test = iç lab tetkik kalemi + tekrar; QC ve arıza dönemden.
            var icKalem = kalemler.Where(x => x.DisLabId == 0).ToList();
            var cihazIdler = icKalem.Where(x => x.CihazId > 0).Select(x => x.CihazId).Distinct().ToArray();
            var qc = (await b.ListeAsync("""
                select cihaz_id, count(*)::int from public.lab_kk_olcum
                 where cihaz_id = any(@p0) and olcum_zamani >= @p1 and olcum_zamani < @p2 group by 1
                """, null, [cihazIdler, baslangic, bitis], o => (id: o.GetInt32(0), n: o.GetInt32(1)), iptal))
                .ToDictionary(x => x.id, x => x.n);
            var ariza = (await b.ListeAsync("""
                select cihaz_id, count(distinct zaman::date)::int from public.lab_cihaz_olay
                 where olay = 4 and cihaz_id = any(@p0) and zaman >= @p1 and zaman < @p2 group by 1
                """, null, [cihazIdler, baslangic, bitis], o => (id: o.GetInt32(0), n: o.GetInt32(1)), iptal))
                .ToDictionary(x => x.id, x => x.n);
            var cihazlar = icKalem.GroupBy(x => x.CihazId).Select(g =>
            {
                var test = g.Sum(x => 1 + x.Tekrar); var reaktif = g.Sum(x => x.TestMaliyet * (1 + x.Tekrar));
                var q = qc.GetValueOrDefault(g.Key);
                return new
                {
                    id = g.Key, ad = g.Key > 0 ? g.First().CihazAd : "Cihaz belirsiz",
                    tetkikler = string.Join(", ", g.Select(x => x.BirimAd).Distinct().Take(6)),
                    grup = GrupAdi(g.GroupBy(x => x.Grup).OrderByDescending(h => h.Count()).First().Key),
                    test, qc = q, qcOrani = test > 0 ? Math.Round(100m * q / test, 1) : 0m,
                    arizaGun = ariza.GetValueOrDefault(g.Key), reaktif,
                    testBasi = test > 0 ? Math.Round(reaktif / test, 2) : 0m,
                };
            }).OrderByDescending(x => x.test).ToList();

            var disLablar = birimler.Where(x => x.Dis).GroupBy(x => x.DisLabId).Select(g =>
            {
                var ciro = g.Sum(x => x.Ciro); var mal = g.Sum(x => x.Maliyet);
                return new
                {
                    id = g.Key, ad = g.Key > 0 ? g.First().DisLabAd : "Dış lab belirsiz",
                    cesit = g.Select(x => x.BirimAnahtar).Distinct().Count(), adet = g.Count(), ciro, maliyet = mal, fark = ciro - mal,
                    ortGun = g.Select(x => x.DisGun).Where(x => x != null).DefaultIfEmpty().Average(),
                    tetkikler = g.GroupBy(x => x.BirimAnahtar).Select(h => new
                    {
                        kod = h.First().BirimKod, ad = h.First().BirimAd, adet = h.Count(), ciro = h.Sum(x => x.Ciro),
                        maliyet = h.Sum(x => x.Maliyet), fark = h.Sum(x => x.Ciro) - h.Sum(x => x.Maliyet),
                        ortGun = h.Select(x => x.DisGun).Where(x => x != null).DefaultIfEmpty().Average(),
                    }).OrderBy(h => h.fark).ToList(),
                };
            }).OrderBy(x => x.fark).ToList();

            // KALİTE / SÜRE - rutin iç lab (mikrobiyoloji ve dış lab hariç).
            var rutin = birimler.Where(x => !x.Dis && x.Grup != Mikrobiyoloji && x.Tat != null).ToList();
            var dagilim = new[] { ("1 saatten kısa", 0, 60), ("1 – 4 saat", 60, 240), ("4 – 24 saat", 240, 1440), ("24 saatten uzun", 1440, int.MaxValue) }
                .Select(a => new { ad = a.Item1, adet = rutin.Count(x => x.Tat >= a.Item2 && x.Tat < a.Item3) }).ToList();
            var asanlar = birimler.Where(x => x.Asim != null).OrderByDescending(x => x.Asim).Take(50).Select(x => new
            {
                x.BelgeId, protokolNo = x.ProtokolNo, tarih = x.Tarih, tetkik = x.BirimAd, bolum = x.BolumAd,
                hedef = x.Hedef, gercek = x.Tat, asim = x.Asim,
            }).ToList();

            // NUMUNE RET: dönem istemlerinin numuneleri (numune bazında).
            var istemIdler = kalemler.Select(x => x.IstemId).Distinct().ToArray();
            var numune = await b.TekAsync("""
                select count(*)::int as toplam, count(*) filter (where coalesce(ret, 0) = 1)::int as ret
                  from public.lab_numune where istem_id = any(@p0) and ana_numune_id is null
                """, null, [istemIdler], o => new { toplam = o.GetInt32(0), ret = o.GetInt32(1) }, iptal);
            var retler = await b.ListeAsync("""
                select coalesce(rn.ad, case n.ret_neden when 2 then 'Hemoliz' when 3 then 'Lipemi' when 4 then 'İkter'
                         when 5 then 'Yetersiz numune' when 6 then 'Pıhtılı numune' when 7 then 'Yanlış tüp'
                         when 8 then 'Etiketsiz / etiket hatası' else 'Diğer' end),
                       coalesce(d.ad, '')
                  from public.lab_numune n
                  left join public.lab_ret_nedeni rn on rn.kod = n.ret_neden
                  left join public.lab_istem i on i.id = n.istem_id
                  left join public.belge_basvuru bb on bb.id = i.belge_id
                  left join public.departman d on d.id = bb.bolum_id
                 where n.istem_id = any(@p0) and coalesce(n.ret, 0) = 1
                """, null, [istemIdler], o => (ad: o.GetString(0), bolum: o.GetString(1)), iptal);
            var retNedenleri = retler.GroupBy(x => x.ad).Select(g => new
            {
                ad = g.Key, adet = g.Count(),
                enCok = g.Where(x => x.bolum != "").GroupBy(x => x.bolum).OrderByDescending(h => h.Count()).Select(h => h.Key).FirstOrDefault() ?? "",
            }).OrderByDescending(x => x.adet).ToList();

            var ciroT = birimler.Sum(x => x.Ciro); var kurumT = birimler.Sum(x => x.Kurum);
            var reaktifT = birimler.Where(x => !x.Dis).Sum(x => x.Maliyet);
            var dis = birimler.Where(x => x.Dis).ToList();
            var icAdet = birimler.Count(x => !x.Dis);
            var ozet = new
            {
                tetkik = birimler.Count, hasta = birimler.Select(x => x.HastaId).Distinct().Count(),
                istem = birimler.Select(x => x.IstemId).Distinct().Count(),
                ciro = ciroT, kurum = kurumT, hastaPayi = ciroT - kurumT, reaktif = reaktifT,
                disAdet = dis.Count, disMaliyet = dis.Sum(x => x.Maliyet), disCiro = dis.Sum(x => x.Ciro),
                kar = ciroT - reaktifT - dis.Sum(x => x.Maliyet), marj = Marj(ciroT, reaktifT + dis.Sum(x => x.Maliyet)),
                tekrar = birimler.Sum(x => x.Tekrar), tekrarOrani = icAdet > 0 ? Math.Round(100m * birimler.Sum(x => x.Tekrar) / icAdet, 1) : 0m,
                numune = numune?.toplam ?? 0, ret = numune?.ret ?? 0, retOrani = numune is { toplam: > 0 } ? Math.Round(100m * numune.ret / numune.toplam, 1) : 0m,
                ortTat = Ort(rutin.Select(x => x.Tat)), rutinAdet = rutin.Count, asan = birimler.Count(x => x.Asim != null),
                faturasiz = birimler.Count(x => !x.Faturali), zarardaDisLab = disLablar.Count(x => x.fark < 0),
                maliyetsiz = birimler.Count(x => !x.Dis && x.Maliyet == 0),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, tetkikler, gruplar, cihazlar, disLablar,
                tatDagilimi = dagilim, asanlar, retNedenleri, bolumAdlari,
                grupAdlari = KartKatalogu.LabTetkikBolumleri().Select(x => new { id = x.Kod, ad = x.Ad }),
            });
        });
    }
}
