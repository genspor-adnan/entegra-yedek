using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖRÜNTÜLEME (RADYOLOJİ) İCMALİ (mockup Ekranlar/İcmal/goruntuleme_icmali.html,
/// kullanıcı 10.10.2026: "görüntüleme icmalini kodla").
///
/// <para><b>Birim = çekim</b> (radyoloji_istem kaynak 1 iç · 3 dışarıya
/// raporlatılan; iptal hariç). Yalnız tür 19 başvuruya bağlı istemler, iptal
/// başvuru hariç. Tarih = çekim tarihi (çekilmemişse istem tarihi).</para>
///
/// <para><b>Ciro:</b> istemin başvuru satırı; satır bağı yoksa başvurunun aynı
/// hizmetli satırları, o hizmetteki istemlere bölünür (aynı satır iki kez
/// sayılmaz). Kurum payı satır dağılımından.</para>
///
/// <para><b>Maliyet:</b> kontrast / sarf = radyoloji_sarf × stok maliyeti
/// (fn_uretim_stok_maliyeti); dışarıya raporlatılan çekimde teleradyoloji
/// ücreti (telerad_istek.ucret). Gelen teleradyoloji geliri ciroya
/// KATILMAZ - kendi faturasıyla izlenir, ayrı sekmede.</para>
///
/// <para><b>Rapor süresi:</b> çekim → ilk onaylı rapor. Hedef ayardan
/// (radyoloji.rapor_hedef_dk rutin, radyoloji.rapor_hedef_acil_dk acil);
/// teleradyolojide sözleşmenin SLA bitişi.</para>
/// </summary>
public static class GoruntulemeIcmalUclari
{
    /// <summary>Ekran kodu (1027) - haklarını radyoloji.rapor_onay'dan kopyalar.</summary>
    private const string Kod = "radyoloji.icmal";

    private static readonly Dictionary<short, string> Modaliteler = new()
    {
        [1] = "BT", [2] = "MR", [3] = "USG", [4] = "Röntgen", [5] = "Mamografi",
        [6] = "DEXA", [7] = "Anjiyo", [8] = "Skopi",
    };
    private static string ModaliteAdi(short m) => Modaliteler.TryGetValue(m, out var a) ? a : "Diğer";

    private sealed record Cekim(
        int Id, int BelgeId, string ProtokolNo, DateTime Tarih, int HastaId, short Modalite, short Kaynak, short Oncelik,
        int HizmetId, string HizmetKod, string HizmetAd, string SutKodu, int BelgeSatirId, bool Kontrast,
        int CihazId, decimal Sarf, DateTime? Cekildi, DateTime? RaporOnay, int RaporlayanId, string Raporlayan,
        int TeleradKurumId, string TeleradKurum, decimal TeleradUcret, DateTime? SlaBitis,
        int Kritik, int Revizyon, int Konsultasyon);

    public static void GoruntulemeIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/goruntuleme-icmal").WithTags("Görüntüleme İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, short? modalite, short? raporlayan,
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

            var ayar = (await b.ListeAsync("""
                select anahtar, nullif(deger, '')::int from public.referans
                 where anahtar in ('radyoloji.rapor_hedef_dk', 'radyoloji.rapor_hedef_acil_dk')
                """, null, [], o => (k: o.GetString(0), v: o.IsDBNull(1) ? 0 : o.GetInt32(1)), iptal)).ToDictionary(x => x.k, x => x.v);
            var hedefRutin = ayar.GetValueOrDefault("radyoloji.rapor_hedef_dk", 1440);
            var hedefAcil = ayar.GetValueOrDefault("radyoloji.rapor_hedef_acil_dk", 60);

            var hepsi = await b.ListeAsync("""
                select r.id, be.id, coalesce(be.belge_no, ''), coalesce(r.cekim_tarihi, r.ekleme_tarihi), coalesce(r.hasta_id, 0),
                       coalesce(nullif(r.modalite, 0), h.modalite, 0)::smallint, coalesce(r.kaynak, 1)::smallint,
                       coalesce(r.oncelik, 1)::smallint, coalesce(r.hizmet_id, 0), coalesce(h.kod, ''), coalesce(h.ad, ''),
                       coalesce(h.sut_kodu, ''), coalesce(r.belge_satir_id, 0), coalesce(r.kontrast, 0) > 0,
                       coalesce(r.cihaz_id, 0),
                       coalesce((select sum(s.miktar * public.fn_uretim_stok_maliyeti(s.stok_id))
                                   from public.radyoloji_sarf s where s.istem_id = r.id), 0),
                       r.cekim_tarihi, rp.onay_tarihi, coalesce(rp.onaylayan_id, 0),
                       coalesce(public.fn_taraf_ad(rt.unvan, rt.ad, rt.soyad)::varchar(120), ''),
                       coalesce(ti.kurum_id, 0), coalesce(public.fn_taraf_ad(kt.unvan, kt.ad, kt.soyad)::varchar(120), ''),
                       coalesce(ti.ucret, 0), ti.sla_bitis::timestamptz,
                       (select count(*)::int from public.radyoloji_kritik_bulgu k where k.istem_id = r.id),
                       (select count(*)::int from public.radyoloji_rapor x where x.istem_id = r.id and x.ust_rapor_id is not null),
                       (select count(*)::int from public.radyoloji_konsultasyon x where x.istem_id = r.id)
                  from public.radyoloji_istem r
                  join public.belge be on be.id = r.belge_id
                  left join public.hizmet h on h.id = r.hizmet_id
                  left join lateral (
                      select x.onay_tarihi, x.onaylayan_id from public.radyoloji_rapor x
                       where x.istem_id = r.id and x.durum = 3 and x.ust_rapor_id is null
                       order by x.onay_tarihi limit 1) rp on true
                  left join public.taraf rt on rt.id = rp.onaylayan_id
                  left join lateral (
                      select t.kurum_id, t.ucret, t.sla_bitis from public.telerad_istek t
                       where t.yon = 2 and t.durum <> 0
                         and (t.id = r.telerad_istek_id or t.radyoloji_istem_id = r.id)
                       order by t.id desc limit 1) ti on true
                  left join public.telerad_kurum tk on tk.id = ti.kurum_id
                  left join public.taraf kt on kt.id = tk.taraf_id
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                   and r.durum <> 0 and coalesce(r.kaynak, 1) in (1, 3)
                   and coalesce(r.cekim_tarihi, r.ekleme_tarihi) >= @p0 and coalesce(r.cekim_tarihi, r.ekleme_tarihi) < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => new Cekim(
                    o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetDateTime(3), o.GetInt32(4), o.GetInt16(5), o.GetInt16(6),
                    o.GetInt16(7), o.GetInt32(8), o.GetString(9), o.GetString(10), o.GetString(11), o.GetInt32(12), o.GetBoolean(13),
                    o.GetInt32(14), o.GetDecimal(15), o.IsDBNull(16) ? null : o.GetDateTime(16), o.IsDBNull(17) ? null : o.GetDateTime(17),
                    o.GetInt32(18), o.GetString(19), o.GetInt32(20), o.GetString(21), o.GetDecimal(22),
                    o.IsDBNull(23) ? null : o.GetDateTime(23), o.GetInt32(24), o.GetInt32(25), o.GetInt32(26)), iptal);

            // Raporlayan süzgeci: 1 iç radyolog · 2 teleradyoloji (dışarıya raporlatılan).
            var cekimler = hepsi.Where(x => (modalite is not > 0 || x.Modalite == modalite)
                                         && (raporlayan is not > 0 || (raporlayan == 2) == (x.Kaynak == 3 || x.TeleradKurumId > 0))).ToList();

            // FATURA: satır bağı varsa o satır; yoksa (başvuru, hizmet) satırları o hizmetteki istemlere bölünür.
            var belgeIdler = cekimler.Select(x => x.BelgeId).Distinct().ToArray();
            var satirlar = await b.ListeAsync("""
                select st.id, st.belge_id, coalesce(st.hizmet_id, 0), st.tutar,
                       least(greatest(coalesce((select sum(coalesce(x.sgk, 0) + coalesce(x.oss, 0))
                                                  from public.belge_satir_dagilim x where x.belge_satir_id = st.id), 0), 0),
                             greatest(st.tutar, 0))
                  from public.belge_satir st where st.belge_id = any(@p0)
                """, null, [belgeIdler], o => (id: o.GetInt32(0), belge: o.GetInt32(1), hizmet: o.GetInt32(2),
                    tutar: o.GetDecimal(3), kurum: o.GetDecimal(4)), iptal);
            var satirById = satirlar.ToDictionary(x => x.id);
            var bagliSatirlar = cekimler.Where(x => x.BelgeSatirId > 0).Select(x => x.BelgeSatirId).ToHashSet();
            var hizmetHavuzu = satirlar.Where(x => !bagliSatirlar.Contains(x.id)).GroupBy(x => (x.belge, x.hizmet))
                .ToDictionary(g => g.Key, g => (tutar: g.Sum(x => x.tutar), kurum: g.Sum(x => x.kurum)));
            var havuzPay = cekimler.Where(x => x.BelgeSatirId == 0).GroupBy(x => (x.BelgeId, x.HizmetId)).ToDictionary(g => g.Key, g => g.Count());

            (decimal ciro, decimal kurum) Fatura(Cekim c)
            {
                if (c.BelgeSatirId > 0)
                    return satirById.TryGetValue(c.BelgeSatirId, out var s) ? (s.tutar, s.kurum) : (0m, 0m);
                if (!hizmetHavuzu.TryGetValue((c.BelgeId, c.HizmetId), out var h)) return (0m, 0m);
                var n = havuzPay.GetValueOrDefault((c.BelgeId, c.HizmetId), 1);
                return (Math.Round(h.tutar / n, 2), Math.Round(h.kurum / n, 2));
            }

            var birimler = cekimler.Select(c =>
            {
                var (ciro, kurum) = Fatura(c);
                var telerad = c.Kaynak == 3 || c.TeleradKurumId > 0;
                int? sure = c.Cekildi != null && c.RaporOnay != null && c.RaporOnay > c.Cekildi
                    ? (int)Math.Round((c.RaporOnay.Value - c.Cekildi.Value).TotalMinutes) : null;
                var hedef = telerad && c.SlaBitis != null && c.Cekildi != null
                    ? (int)Math.Round((c.SlaBitis.Value - c.Cekildi.Value).TotalMinutes)
                    : c.Oncelik >= 2 ? hedefAcil : hedefRutin;
                return new
                {
                    C = c, Ciro = ciro, Kurum = kurum, Telerad = telerad, Sure = sure, Hedef = hedef,
                    Asim = sure != null && hedef > 0 && sure > hedef ? sure - hedef : null,
                    Maliyet = c.Sarf + c.TeleradUcret, Bekleyen = c.Cekildi != null && c.RaporOnay == null,
                };
            }).ToList();

            static decimal? Marj(decimal ciro, decimal maliyet) => ciro > 0 ? Math.Round(100 * (ciro - maliyet) / ciro, 1) : null;
            static decimal? Ort(IEnumerable<int?> v) { var l = v.Where(x => x != null).Select(x => (decimal)x!.Value).ToList();
                return l.Count > 0 ? Math.Round(l.Average(), 0) : null; }

            var modaliteler = birimler.GroupBy(x => x.C.Modalite).Select(g =>
            {
                var ciro = g.Sum(x => x.Ciro); var sarf = g.Sum(x => x.C.Sarf); var tel = g.Sum(x => x.C.TeleradUcret);
                return new
                {
                    modalite = g.Key, ad = ModaliteAdi(g.Key), cekim = g.Count(), ciro, kurum = g.Sum(x => x.Kurum),
                    kurumYuzde = ciro > 0 ? Math.Round(100 * g.Sum(x => x.Kurum) / ciro, 0) : 0m,
                    kontrastli = g.Count(x => x.C.Kontrast), sarf, telerad = tel, kar = ciro - sarf - tel, marj = Marj(ciro, sarf + tel),
                    ortRapor = Ort(g.Select(x => x.Sure)), asan = g.Count(x => x.Asim != null),
                    enCok = g.GroupBy(x => x.C.HizmetId).OrderByDescending(h => h.Count()).Take(3)
                             .Select(h => new { ad = h.First().C.HizmetAd, adet = h.Count(), ciro = h.Sum(x => x.Ciro) }).ToList(),
                };
            }).OrderByDescending(x => x.ciro).ToList();

            var tetkikler = birimler.GroupBy(x => x.C.HizmetId).Select(g =>
            {
                var f = g.First().C; var ciro = g.Sum(x => x.Ciro); var mal = g.Sum(x => x.Maliyet); var n = g.Count();
                return new
                {
                    hizmetId = g.Key, kod = f.SutKodu != "" ? f.SutKodu : f.HizmetKod, ad = f.HizmetAd, modalite = ModaliteAdi(f.Modalite),
                    adet = n, ciro, ortFiyat = n > 0 ? Math.Round(ciro / n, 2) : 0m, sarfCekim = n > 0 ? Math.Round(g.Sum(x => x.C.Sarf) / n, 2) : 0m,
                    maliyet = mal, marj = Marj(ciro, mal), faturasiz = g.Count(x => x.Ciro == 0),
                };
            }).OrderByDescending(x => x.ciro).ToList();

            var raporlayanlar = birimler.Where(x => x.C.RaporOnay != null || x.Telerad)
                .GroupBy(x => x.Telerad ? (tur: "telerad", id: x.C.TeleradKurumId) : (tur: "ic", id: x.C.RaporlayanId)).Select(g =>
                {
                    var f = g.First();
                    return new
                    {
                        tur = g.Key.tur, id = g.Key.id,
                        ad = g.Key.tur == "telerad" ? (f.C.TeleradKurum != "" ? f.C.TeleradKurum : "Teleradyoloji (kurum belirsiz)")
                                                    : (f.C.Raporlayan != "" ? f.C.Raporlayan : "Raporlayan belirsiz"),
                        rapor = g.Count(x => x.C.RaporOnay != null), bekleyen = g.Count(x => x.Bekleyen),
                        ortSure = Ort(g.Select(x => x.Sure)), asan = g.Count(x => x.Asim != null),
                        kritik = g.Sum(x => x.C.Kritik), revizyon = g.Sum(x => x.C.Revizyon), ikinciOkuma = g.Sum(x => x.C.Konsultasyon),
                    };
                }).OrderByDescending(x => x.rapor).ToList();

            // CİHAZ: kapasite = çalışma günleri × (mesai - öğle) - kapatmalar; kullanım = çekim × varsayılan süre.
            var cihazIdler = birimler.Where(x => x.C.CihazId > 0).Select(x => x.C.CihazId).Distinct().ToArray();
            var cihazTanim = await b.ListeAsync("""
                select c.id, c.ad, coalesce(c.modalite, 0)::smallint, coalesce(c.baslangic_saat, ''), coalesce(c.bitis_saat, ''),
                       coalesce(c.ogle_baslangic, ''), coalesce(c.ogle_bitis, ''), coalesce(c.varsayilan_sure, c.slot_dk, 0)::int,
                       coalesce(c.calisma_gunleri, '')
                  from public.radyoloji_cihaz c
                 where c.id = any(@p0) or (coalesce(c.durum, 1) = 1 and (@p1 = 0 or coalesce(c.sube_id, 0) in (0, @p1)))
                """, null, [cihazIdler, sube], o => (id: o.GetInt32(0), ad: o.GetString(1), modalite: o.GetInt16(2),
                    bas: o.GetString(3), bit: o.GetString(4), ob: o.GetString(5), oe: o.GetString(6), sure: o.GetInt32(7),
                    gunler: o.GetString(8)), iptal);
            var kapatmalar = await b.ListeAsync("""
                select cihaz_id, greatest(baslangic, @p1::timestamptz), least(coalesce(bitis, @p2::timestamptz), @p2::timestamptz)
                  from public.radyoloji_cihaz_kapatma
                 where cihaz_id = any(@p0) and baslangic < @p2 and coalesce(bitis, @p2) > @p1
                """, null, [cihazTanim.Select(x => x.id).ToArray(), baslangic, bitis],
                o => (id: o.GetInt32(0), bas: o.GetDateTime(1), bit: o.GetDateTime(2)), iptal);

            static int Dk(string s) => TimeSpan.TryParse(s, out var t) ? (int)t.TotalMinutes : 0;
            var cihazlar = cihazTanim.Where(t => modalite is not > 0 || t.modalite == modalite).Select(t =>
            {
                var gunler = t.gunler.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                                     .Select(x => int.TryParse(x, out var n) ? n : 0).ToHashSet();
                var gunluk = Math.Max(0, Dk(t.bit) - Dk(t.bas) - Math.Max(0, Dk(t.oe) - Dk(t.ob)));
                var isGunu = 0;
                for (var d = baslangic; d < bitis; d = d.AddDays(1))
                    if (gunler.Count == 0 || gunler.Contains(d.DayOfWeek == DayOfWeek.Sunday ? 7 : (int)d.DayOfWeek)) isGunu++;
                var kp = kapatmalar.Where(k => k.id == t.id).ToList();
                var kapaliDk = kp.Sum(k => Math.Min(gunluk * Math.Max(1, (k.bit.Date - k.bas.Date).Days + 1), (k.bit - k.bas).TotalMinutes));
                var kapasite = Math.Max(0, gunluk * isGunu - (int)kapaliDk);
                var g = birimler.Where(x => x.C.CihazId == t.id).ToList();
                var kullanim = g.Count * t.sure;
                return new
                {
                    t.id, t.ad, modalite = ModaliteAdi(t.modalite), cekim = g.Count, kullanimSaat = Math.Round(kullanim / 60m, 1),
                    kapasiteSaat = Math.Round(kapasite / 60m, 1), doluluk = kapasite > 0 ? Math.Round(100m * kullanim / kapasite, 1) : 0m,
                    kapaliGun = kp.SelectMany(k => Enumerable.Range(0, (k.bit.Date - k.bas.Date).Days + 1).Select(i => k.bas.Date.AddDays(i)))
                                  .Where(d => d < bitis).Distinct().Count(),
                    sarf = g.Sum(x => x.C.Sarf), sarfCekim = g.Count > 0 ? Math.Round(g.Sum(x => x.C.Sarf) / g.Count, 2) : 0m,
                    kapasiteDk = kapasite, kullanimDk = kullanim,
                };
            }).OrderByDescending(x => x.cekim).ToList();
            var cihazsiz = birimler.Count(x => x.C.CihazId == 0);

            // TELERADYOLOJİ - giden: dışarıya raporlatılan çekimler; gelen: bize raporlatan kurumlar (ciroya katılmaz).
            var giden = birimler.Where(x => x.Telerad).GroupBy(x => x.C.TeleradKurumId).Select(g => new
            {
                kurumId = g.Key, ad = g.First().C.TeleradKurum != "" ? g.First().C.TeleradKurum : "Kurum belirsiz", cekim = g.Count(),
                birimUcret = g.Count() > 0 ? Math.Round(g.Sum(x => x.C.TeleradUcret) / g.Count(), 2) : 0m, maliyet = g.Sum(x => x.C.TeleradUcret),
            }).OrderByDescending(x => x.maliyet).ToList();
            var gelen = await b.ListeAsync("""
                select t.kurum_id, coalesce(public.fn_taraf_ad(kt.unvan, kt.ad, kt.soyad)::varchar(120), ''), count(*)::int,
                       coalesce(sum(t.ucret), 0), count(*) filter (where t.onay_zamani is not null)::int,
                       count(*) filter (where coalesce(t.sla_asildi, 0) = 1)::int
                  from public.telerad_istek t
                  left join public.telerad_kurum tk on tk.id = t.kurum_id
                  left join public.taraf kt on kt.id = tk.taraf_id
                 where t.yon = 1 and t.durum <> 0 and t.gelis_zamani >= @p0 and t.gelis_zamani < @p1
                   and (@p2 = 0 or coalesce(t.sube_id, 0) in (0, @p2))
                 group by 1, 2 order by 4 desc, 3 desc
                """, null, [baslangic, bitis, sube], o => new
            {
                kurumId = o.GetInt32(0), ad = o.GetString(1) == "" ? "Kurum belirsiz" : o.GetString(1), cekim = o.GetInt32(2),
                gelir = o.GetDecimal(3), raporlanan = o.GetInt32(4), slaAsan = o.GetInt32(5),
            }, iptal);

            var hedefAsanlar = birimler.Where(x => x.Asim != null).OrderByDescending(x => x.Asim).Take(50).Select(x => new
            {
                x.C.BelgeId, protokolNo = x.C.ProtokolNo, tarih = x.C.Tarih, tetkik = x.C.HizmetAd, modalite = ModaliteAdi(x.C.Modalite),
                hedef = x.Hedef, gercek = x.Sure, asim = x.Asim,
            }).ToList();

            var ciroT = birimler.Sum(x => x.Ciro); var sarfT = birimler.Sum(x => x.C.Sarf); var telT = birimler.Sum(x => x.C.TeleradUcret);
            var kapT = cihazlar.Sum(x => x.kapasiteDk); var kulT = cihazlar.Sum(x => x.kullanimDk);
            var ozet = new
            {
                cekim = birimler.Count, hasta = birimler.Select(x => x.C.HastaId).Distinct().Count(),
                ciro = ciroT, kurum = birimler.Sum(x => x.Kurum), hastaPayi = ciroT - birimler.Sum(x => x.Kurum),
                sarf = sarfT, kontrastli = birimler.Count(x => x.C.Kontrast), teleradMaliyet = telT,
                kar = ciroT - sarfT - telT, marj = Marj(ciroT, sarfT + telT),
                ortRapor = Ort(birimler.Select(x => x.Sure)), asan = birimler.Count(x => x.Asim != null),
                bekleyen = birimler.Count(x => x.Bekleyen), giden = birimler.Count(x => x.Telerad),
                gelen = gelen.Sum(x => x.cekim), gelenGelir = gelen.Sum(x => x.gelir),
                teleradNet = gelen.Sum(x => x.gelir) - telT,
                doluluk = kapT > 0 ? Math.Round(100m * kulT / kapT, 1) : (decimal?)null, cihazsiz,
                faturasiz = birimler.Count(x => x.Ciro == 0), sarfsiz = birimler.Count(x => x.C.Sarf == 0),
                hedefRutin, hedefAcil,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, modaliteler, tetkikler, raporlayanlar, cihazlar,
                teleradGiden = giden, teleradGelen = gelen, hedefAsanlar,
                modaliteAdlari = Modaliteler.Select(x => new { id = x.Key, ad = x.Value }),
            });
        });
    }
}
