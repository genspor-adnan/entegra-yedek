using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// YATAN HASTA / SERVİS DÖNEM İCMALİ (mockup Ekranlar/İcmal/yatan_hasta_icmali.html,
/// kullanıcı 10.10.2026: "yatan hasta icmalini kodla").
///
/// <para><b>Tutarlar yatış hizmet icmaliyle (YatanUclari.Icmal) AYNI kuralla:</b>
/// ciro = dönem tarihli yatak / refakat tahakkuku + dönemde uygulanan ilaç +
/// dönemde başlayan tetkik / görüntüleme order'ı, fiyat fn_belge_kalem_fiyati.
/// Kurum / hasta: ödeyen kurumu olmayan yatışta hepsi hasta payı; kurumu
/// varsa yalnız refakat (kaynak 2) hasta payı - SUT kesin cevabı Medula'nın.</para>
///
/// <para><b>Gün sayımı:</b> hasta-gün = döneme düşen gece (yatış günü sayılır,
/// çıkış günü sayılmaz; hâlâ yatan için bugün dahil). Doluluk = hasta-gün /
/// (servisin aktif yatağı × gün). ALOS = dönemde taburcu olanların toplam
/// günü / taburcu (aynı gün çıkış 1 gün). İptal yatış (durum 0) hariç.</para>
///
/// <para><b>Açık hesap</b> = dönemde taburcu + (faturalanmamış tahakkuk / ilaç
/// VAR ya da kurumlu yatışta provizyon YOK). Tahsilat yatışa bağlı tutulmadığı
/// için "hasta payı tahsil edilmedi" ayrımı yapılmaz. Kapalı yatak-gün için
/// yatak durum geçmişi tutulmuyor - yalnız bugün kapalı olan yatak sayısı.</para>
/// </summary>
public static class YatanDonemIcmalUclari
{
    /// <summary>Ekran kodu (1028) - haklarını yatan.icmal'dan kopyalar.</summary>
    private const string Kod = "yatan.donem_icmal";

    private sealed record Yatis(
        int Id, string ProtokolNo, int HastaId, string Hasta, int ServisId, string Servis, int HekimId, string Hekim,
        DateTime Giris, DateTime? Cikis, short Durum, string Odeyen, bool KurumVar, bool ProvizyonVar, string Tani, string TaniAd,
        decimal Ciro, decimal Refakat, decimal Faturasiz, decimal ToplamTum);

    public static void YatanDonemIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/yatan-icmal").WithTags("Yatan Hasta İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? servis,
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
            await using var b = await veri.AcAsync(iptal);

            // Döneme dokunan yatışlar (+ tekrar yatış için 30 gün öncesi).
            var hepsi = await b.ListeAsync("""
                select y.id, coalesce(nullif(y.dosya_no, ''), be.belge_no, y.id::varchar), y.hasta_id,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(y.departman_id, 0), coalesce(d.ad, 'Servis belirsiz'),
                       coalesce(y.hekim_id, 0), coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       y.giris_tarihi, y.cikis_tarihi, coalesce(y.durum, 1)::smallint,
                       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), ''), coalesce(y.odeyen_kurum_id, 0) > 0,
                       coalesce(y.provizyon_no, '') <> '', coalesce(y.yatis_tani_kodu, ''), coalesce(i.ad, ''),
                       -- DÖNEM cirosu: tahakkuk + ilaç + tetkik (YatanUclari.Icmal ile aynı kural)
                       coalesce((select sum(th.tutar) from public.yatis_tahakkuk th
                                  where th.yatis_id = y.id and th.tarih >= @p0 and th.tarih < @p1), 0)
                       + coalesce((select sum(coalesce(kf.fiyat, 0)) from public.order_uygulama u
                                    join public.yatis_order od on od.id = u.order_id
                                    left join lateral (select f.fiyat from public.fn_belge_kalem_fiyati(y.hasta_id, 2::smallint, null,
                                                       od.hizmet_id, current_date) f limit 1) kf on od.hizmet_id is not null
                                   where od.yatis_id = y.id and u.durum = 2 and u.uygulanan >= @p0 and u.uygulanan < @p1), 0)
                       + coalesce((select sum(coalesce(kf.fiyat, 0)) from public.yatis_order od
                                    left join lateral (select f.fiyat from public.fn_belge_kalem_fiyati(y.hasta_id, 2::smallint, null,
                                                       od.hizmet_id, current_date) f limit 1) kf on od.hizmet_id is not null
                                   where od.yatis_id = y.id and od.tur in (3, 4, 5) and od.durum <> 0
                                     and od.baslangic >= @p0 and od.baslangic < @p1), 0),
                       coalesce((select sum(th.tutar) from public.yatis_tahakkuk th
                                  where th.yatis_id = y.id and th.kaynak = 2 and th.tarih >= @p0 and th.tarih < @p1), 0),
                       -- AÇIK HESAP için yatışın TAMAMI: faturalanmamış tahakkuk + uygulanmış ilaç
                       coalesce((select sum(th.tutar) from public.yatis_tahakkuk th
                                  where th.yatis_id = y.id and th.belge_satir_id is null), 0),
                       coalesce((select sum(th.tutar) from public.yatis_tahakkuk th where th.yatis_id = y.id), 0)
                  from public.yatis y
                  left join public.belge be on be.id = y.belge_id
                  left join public.taraf t on t.id = y.hasta_id
                  left join public.departman d on d.id = y.departman_id
                  left join public.taraf h on h.id = y.hekim_id
                  left join public.taraf k on k.id = y.odeyen_kurum_id
                  left join public.icd i on i.kod = y.yatis_tani_kodu
                 where coalesce(y.durum, 1) <> 0
                   and y.giris_tarihi < @p1 and (y.cikis_tarihi is null or y.cikis_tarihi >= @p2)
                   and (@p3 = 0 or y.sube_id is null or y.sube_id = @p3)
                """, null, [baslangic, bitis, baslangic.AddDays(-30), sube], o => new Yatis(
                    o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetString(3), o.GetInt32(4), o.GetString(5),
                    o.GetInt32(6), o.GetString(7), o.GetDateTime(8), o.IsDBNull(9) ? null : o.GetDateTime(9), o.GetInt16(10),
                    o.GetString(11), o.GetBoolean(12), o.GetBoolean(13), o.GetString(14), o.GetString(15),
                    o.GetDecimal(16), o.GetDecimal(17), o.GetDecimal(18), o.GetDecimal(19)), iptal);

            // Servis yatakları (aktif) ve bugün kapalı olanlar.
            var yataklar = (await b.ListeAsync("""
                select coalesce(o.departman_id, 0), count(*)::int, count(*) filter (where yk.durum = 5)::int
                  from public.yatak yk join public.oda o on o.id = yk.oda_id
                 where coalesce(yk.aktif, 1) = 1 and coalesce(o.aktif, 1) = 1
                   and (@p0 = 0 or yk.sube_id is null or yk.sube_id = @p0)
                 group by 1
                """, null, [sube], x => (servis: x.GetInt32(0), yatak: x.GetInt32(1), kapali: x.GetInt32(2)), iptal))
                .ToDictionary(x => x.servis);

            var gunSayisi = (bitis - baslangic).Days;
            // Gece sayısı: [giriş günü, çıkış günü) ∩ [a, b); hâlâ yatan için bugün dahil.
            int Gece(Yatis y, DateTime a, DateTime son)
            {
                var g = y.Giris.ToLocalTime().Date;
                var c = y.Cikis?.ToLocalTime().Date ?? bugun.AddDays(1);
                var ilk = g > a ? g : a; var sonr = c < son ? c : son;
                return Math.Max(0, (sonr - ilk).Days);
            }
            int ToplamGun(Yatis y) => Math.Max(1, ((y.Cikis?.ToLocalTime().Date ?? bugun) - y.Giris.ToLocalTime().Date).Days);
            bool Donemde(DateTime t) => t >= baslangic && t < bitis;
            bool Taburcu(Yatis y) => y.Cikis is { } c && Donemde(c.ToLocalTime()) && y.Durum is 4 or 5;

            // Tekrar yatış: aynı hastanın önceki çıkışından sonraki 30 gün içinde yeni yatış.
            var tekrarlar = hepsi.Where(y => Donemde(y.Giris.ToLocalTime()) && hepsi.Any(o => o.HastaId == y.HastaId && o.Id != y.Id
                && o.Cikis is { } c && c <= y.Giris && (y.Giris - c).TotalDays <= 30)).Select(y => y.Id).ToHashSet();

            var donem = hepsi.Where(y => Gece(y, baslangic, bitis) > 0 || Donemde(y.Giris.ToLocalTime()) || Taburcu(y)).ToList();
            var servisAdlari = donem.Where(y => y.ServisId > 0).Select(y => new { id = y.ServisId, ad = y.Servis }).DistinctBy(x => x.id).OrderBy(x => x.ad).ToList();
            var kume = donem.Where(y => servis is not > 0 || y.ServisId == servis).ToList();

            decimal Hasta(Yatis y) => y.KurumVar ? y.Refakat : y.Ciro;
            string? AcikNeden(Yatis y) => !Taburcu(y) ? null
                : y.Faturasiz > 0.005m ? "fatura kesilmedi"
                : y.KurumVar && !y.ProvizyonVar ? "provizyon bekliyor" : null;
            static decimal? Oran(int pay, int payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;

            object Ozetle(IEnumerable<Yatis> g, int yatak)
            {
                var l = g.ToList();
                var taburcu = l.Where(Taburcu).ToList();
                var hastaGun = l.Sum(y => Gece(y, baslangic, bitis));
                var acik = l.Where(y => AcikNeden(y) != null).ToList();
                return new
                {
                    yatak, yatis = l.Count(y => Donemde(y.Giris.ToLocalTime())), taburcu = taburcu.Count, hastaGun,
                    doluluk = Oran(hastaGun, yatak * gunSayisi),
                    alos = taburcu.Count > 0 ? Math.Round((decimal)taburcu.Average(ToplamGun), 1) : (decimal?)null,
                    ciro = l.Sum(y => y.Ciro), gunBasi = hastaGun > 0 ? Math.Round(l.Sum(y => y.Ciro) / hastaGun, 2) : 0m,
                    kurum = l.Sum(y => y.Ciro - Hasta(y)), hasta = l.Sum(Hasta),
                    acikAdet = acik.Count, acikTutar = acik.Sum(y => y.Faturasiz > 0.005m ? y.Faturasiz : y.ToplamTum),
                    yatiyor = l.Count(y => y.Cikis == null),
                };
            }

            var servisler = kume.GroupBy(y => (y.ServisId, y.Servis)).Select(g =>
            {
                var yatak = yataklar.GetValueOrDefault(g.Key.ServisId).yatak;
                return new
                {
                    id = g.Key.ServisId, ad = g.Key.Servis, kapaliYatak = yataklar.GetValueOrDefault(g.Key.ServisId).kapali,
                    ozet = Ozetle(g, yatak),
                    doktorlar = g.GroupBy(y => (y.HekimId, y.Hekim)).Select(h => new
                    {
                        id = h.Key.HekimId, ad = h.Key.HekimId > 0 ? h.Key.Hekim : "Doktor belirsiz", ozet = Ozetle(h, 0),
                    }).OrderBy(h => h.ad).ToList(),
                };
            }).OrderBy(x => x.ad).ToList();

            var yatislar = kume.Where(y => Donemde(y.Giris.ToLocalTime())).OrderBy(y => y.Giris).Select(y => new
            {
                y.Id, protokolNo = y.ProtokolNo, hasta = y.Hasta, servis = y.Servis, doktor = y.Hekim, giris = y.Giris, cikis = y.Cikis,
                gun = ToplamGun(y), odeyen = y.KurumVar ? y.Odeyen : "Ücretli", ciro = y.Ciro, tekrar = tekrarlar.Contains(y.Id),
                durum = y.Cikis == null ? "yatiyor" : AcikNeden(y) != null ? "acik" : "kapandi",
            }).ToList();

            var acikHesaplar = kume.Where(y => AcikNeden(y) != null).OrderBy(y => y.Cikis).Select(y => new
            {
                y.Id, protokolNo = y.ProtokolNo, hasta = y.Hasta, servis = y.Servis, odeyen = y.KurumVar ? y.Odeyen : "Ücretli",
                cikis = y.Cikis, bekleme = (bugun - y.Cikis!.Value.ToLocalTime().Date).Days,
                toplam = y.ToplamTum, faturasiz = y.Faturasiz, neden = AcikNeden(y),
            }).ToList();

            // Haftalık doluluk: dönem 7 günlük dilimlere bölünür.
            var haftalar = new List<(DateTime a, DateTime b)>();
            for (var a = baslangic; a < bitis; a = a.AddDays(7)) haftalar.Add((a, a.AddDays(7) < bitis ? a.AddDays(7) : bitis));
            var haftalik = servisler.Select(s =>
            {
                var yatak = yataklar.GetValueOrDefault(s.id).yatak;
                var l = kume.Where(y => y.ServisId == s.id).ToList();
                var hg = l.Sum(y => Gece(y, baslangic, bitis));
                return new
                {
                    s.id, s.ad, yatak,
                    haftalar = haftalar.Select(h => Oran(l.Sum(y => Gece(y, h.a, h.b)), yatak * (h.b - h.a).Days)).ToList(),
                    donem = Oran(hg, yatak * gunSayisi), bosYatakGun = Math.Max(0, yatak * gunSayisi - hg),
                    kapaliYatak = yataklar.GetValueOrDefault(s.id).kapali,
                };
            }).ToList();

            var tanilar = kume.Where(y => Donemde(y.Giris.ToLocalTime()) && y.Tani != "").GroupBy(y => (y.Tani, y.TaniAd))
                .Select(g => new
                {
                    kod = g.Key.Tani, ad = g.Key.TaniAd, adet = g.Count(),
                    alos = Math.Round((decimal)g.Average(ToplamGun), 1), ortTutar = Math.Round(g.Average(y => y.Ciro), 2),
                }).OrderByDescending(x => x.adet).Take(10).ToList();
            var doktorlar = kume.GroupBy(y => (y.HekimId, y.Hekim, y.Servis)).Select(g => new
            {
                ad = g.Key.HekimId > 0 ? g.Key.Hekim : "Doktor belirsiz", servis = g.Key.Servis, ozet = Ozetle(g, 0),
            }).OrderBy(x => x.ad).ToList();

            var toplamYatak = servis is > 0 ? yataklar.GetValueOrDefault(servis.Value).yatak : yataklar.Values.Sum(x => x.yatak);
            var genel = Ozetle(kume, toplamYatak);
            var taburcuSayisi = kume.Count(Taburcu);
            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun, gun = gunSayisi, haftalar = haftalar.Select(h => new { bas = h.a, bit = h.b.AddDays(-1) }) },
                ozet = genel, toplamYatak, kapaliYatak = yataklar.Values.Sum(x => x.kapali),
                devirHizi = toplamYatak > 0 ? Math.Round((decimal)taburcuSayisi / toplamYatak, 1) : 0m,
                tekrarYatis = kume.Count(y => tekrarlar.Contains(y.Id)),
                uzunYatis = kume.Count(y => ToplamGun(y) >= 30),
                servisler, yatislar, acikHesaplar, haftalik, tanilar, doktorlar, servisAdlari,
            });
        });
    }
}
