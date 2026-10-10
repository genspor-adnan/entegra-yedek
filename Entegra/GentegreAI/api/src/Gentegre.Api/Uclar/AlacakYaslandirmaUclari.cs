using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ALACAK YAŞLANDIRMA (mockup Ekranlar/İcmal/alacak_yaslandirma.html,
/// kullanıcı 10.10.2026: "alacak yaşlandırmayı kodla").
///
/// Hastalardan ve ödeyen kurumlardan alınacak açık bakiyeler 0-30 / 31-60 /
/// 61-90 / 90+ gün dilimlerinde. Gün = referans tarihi - açık belgenin
/// tarihi; bir tarafın her açık belgesi KENDİ dilimine düşer.
///
/// <para><b>Kurum alacağı</b> = (1) kesilmiş ama ödenmemiş kurum faturası /
/// tahakkuku - kurum carisinden (v_cari_ekstre); tahsilat önce EN ESKİ borcu
/// kapatır, kalan bakiye en yeni belgelerdendir - artı (2) henüz
/// faturalanmamış kurum payı (belge_satir_dagilim'de kapanmamış SGK + ÖSS
/// payı, başvuru tarihinden). İkisi çakışmaz: faturalanan / tahakkuk edilen
/// pay dağılımda kapanır ve cariye geçer.</para>
///
/// <para><b>Hasta alacağı</b> = başvuru başına hasta payı - net tahsilat;
/// hasta icmaliyle (HastaIcmalUclari) AYNI kural, yalnız başvuru (tür 19),
/// iptal (6) hariç. Avans mahsup edilmedikçe düşülmez.</para>
///
/// Yalnız OKUR. TC gösterilmez (hasta ad + dosya no).
/// </summary>
public static class AlacakYaslandirmaUclari
{
    /// <summary>Ekran kodu (1019) - haklarını kasa.finans'tan kopyalar.</summary>
    private const string Kod = "finans.alacak_yaslandirma";

    /// <summary>Gün → dilim indeksi: 0 (0-30), 1 (31-60), 2 (61-90), 3 (90+).</summary>
    private static int Dilim(int gun) => gun <= 30 ? 0 : gun <= 60 ? 1 : gun <= 90 ? 2 : 3;

    private sealed record Kalem(DateTime Tarih, decimal Tutar);

    /// <summary>Taraf satırı - JSON camelCase (id, ad, d0, d30 ...).</summary>
    private sealed record KurumAlacagi(int Id, string Ad, short Tur, string TurAdi, int AcikBelge,
        decimal Faturali, decimal Faturasiz, decimal D0, decimal D30, decimal D60, decimal D90,
        decimal Toplam, int EnEskiGun, int OrtGun, DateTime? SonTahsilat);
    private sealed record HastaAlacagi(int Id, string Ad, string DosyaNo, int AcikProtokol,
        decimal D0, decimal D30, decimal D60, decimal D90, decimal Toplam, int EnEskiGun, int OrtGun,
        DateTime? SonTahsilat);

    public static void AlacakYaslandirmaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/alacak-yaslandirma").WithTags("Alacak Yaşlandırma").RequireAuthorization();

        grup.MapGet("/", async (DateTime? tarih, string? taraf, short? kurumTuru,
                                VeriKaynagi veri, BaglamCozucu cozucu,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var refTarih = (tarih ?? DateTime.Today).Date;
            var bitis = refTarih.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            var kurumIste = taraf is null or "" or "hepsi" or "kurum";
            var hastaIste = taraf is null or "" or "hepsi" or "hasta";
            var tur = kurumTuru ?? 0;
            await using var b = await veri.AcAsync(iptal);

            int Gun(DateTime d) => Math.Max(0, (int)(refTarih - d.Date).TotalDays);
            decimal[] Dilimle(IEnumerable<Kalem> k)
            {
                var d = new decimal[4];
                foreach (var x in k) d[Dilim(Gun(x.Tarih))] += x.Tutar;
                return d;
            }

            // ------------------------------------------------------- kurumlar --
            var kurumlar = new List<KurumAlacagi>();
            if (kurumIste)
            {
                var kurumBilgi = await b.ListeAsync("""
                    select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.tur,
                           coalesce((select kd.ad from public.kod_deger kd
                                       join public.kod_liste kl on kl.id = kd.liste_id
                                      where kl.kod = 'taraf.kurum_turu' and kd.deger = k.tur), '')
                      from public.taraf_kurum k
                      join public.taraf t on t.id = k.id
                     where k.tur in (2, 3, 4) and (@p0 = 0 or k.tur = @p0)
                    """, null, [tur], o => (id: o.GetInt32(0), ad: o.GetString(1), tur: o.GetInt16(2), turAdi: o.GetString(3)), iptal);
                var idler = kurumBilgi.Select(k => k.id).ToArray();

                // (1) Cari: borç kalemleri ve toplam alacak (referans tarihine kadar).
                var cari = await b.ListeAsync("""
                    select e.taraf_id, e.islem_tarihi, e.yerel_borc, e.yerel_alacak
                      from public.v_cari_ekstre e
                     where e.taraf_id = any(@p0) and e.bakiye_dahil = 1 and e.islem_tarihi < @p1
                       and (@p2 = 0 or e.sube_id is null or e.sube_id = @p2)
                     order by e.taraf_id, e.islem_tarihi, e.id
                    """, null, [idler, bitis, sube], o => (taraf: o.GetInt32(0), tarih: o.GetDateTime(1),
                        borc: o.GetDecimal(2), alacak: o.GetDecimal(3)), iptal);

                // (2) Faturalanmamış kurum payı: kapanmamış SGK + ÖSS payı, başvuru başına.
                var faturasiz = await b.ListeAsync("""
                    select bb.odeyen_kurum_id, be.belge_tarihi,
                           sum(dg.sgk + dg.oss - dg.sgk_kapatilan - dg.oss_kapatilan)
                      from public.belge be
                      join public.belge_basvuru bb on bb.id = be.id
                      join public.belge_satir st on st.belge_id = be.id
                      join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                     where be.tipi = 30 and be.tur = 19 and be.durum = 0
                       and bb.odeyen_kurum_id = any(@p0) and be.belge_tarihi < @p1
                       and (@p2 = 0 or be.sube_id is null or be.sube_id = @p2)
                       and (dg.sgk + dg.oss) > (dg.sgk_kapatilan + dg.oss_kapatilan)
                     group by bb.odeyen_kurum_id, be.id, be.belge_tarihi
                    """, null, [idler, bitis, sube], o => (taraf: o.GetInt32(0), tarih: o.GetDateTime(1), tutar: o.GetDecimal(2)), iptal);

                foreach (var k in kurumBilgi)
                {
                    var satir = cari.Where(c => c.taraf == k.id).ToList();
                    // FIFO: alacak (tahsilat, iade, kesinti) önce en eski borcu kapatır.
                    var kalanAlacak = satir.Sum(c => c.alacak);
                    var acikFatura = new List<Kalem>();
                    foreach (var c in satir.Where(c => c.borc > 0))
                    {
                        var kapanan = Math.Min(kalanAlacak, c.borc);
                        kalanAlacak -= kapanan;
                        if (c.borc - kapanan > 0.005m) acikFatura.Add(new Kalem(c.tarih, c.borc - kapanan));
                    }
                    var acikPay = faturasiz.Where(f => f.taraf == k.id && f.tutar > 0.005m)
                                           .Select(f => new Kalem(f.tarih, f.tutar)).ToList();
                    var hepsi = acikFatura.Concat(acikPay).ToList();
                    var toplam = hepsi.Sum(x => x.Tutar);
                    if (toplam <= 0.005m) continue;
                    var dilim = Dilimle(hepsi);
                    var sonTahsilat = satir.Where(c => c.alacak > 0).Select(c => (DateTime?)c.tarih).Max();
                    kurumlar.Add(new KurumAlacagi(k.id, k.ad, k.tur, k.turAdi,
                        acikFatura.Count + acikPay.Count, acikFatura.Sum(x => x.Tutar), acikPay.Sum(x => x.Tutar),
                        dilim[0], dilim[1], dilim[2], dilim[3], toplam,
                        hepsi.Max(x => Gun(x.Tarih)),
                        // Tutar ağırlıklı ortalama gün.
                        (int)Math.Round(hepsi.Sum(x => x.Tutar * Gun(x.Tarih)) / toplam),
                        sonTahsilat));
                }
            }

            // -------------------------------------------------------- hastalar --
            var hastalar = new List<HastaAlacagi>();
            if (hastaIste)
            {
                var basvurular = await b.ListeAsync("""
                    with bsv as (
                        select be.id, be.belge_tarihi, be.genel_toplam, coalesce(bb.hasta_id, be.taraf_id) as hasta_id
                          from public.belge be
                          join public.belge_basvuru bb on bb.id = be.id
                         where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                           and be.belge_tarihi < @p0
                           and (@p1 = 0 or be.sube_id is null or be.sube_id = @p1))
                    select s.hasta_id, s.id, s.belge_tarihi, s.genel_toplam,
                           coalesce((select sum(coalesce(dg.sgk, 0) + coalesce(dg.oss, 0))
                                       from public.belge_satir st
                                       left join public.belge_satir_dagilim dg on dg.belge_satir_id = st.id
                                      where st.belge_id = s.id), 0),
                           coalesce((select sum(case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end)
                                       from public.kasa_islem ki
                                       join public.kasa_islem_turu kt on kt.kod = ki.tur
                                      where ki.belge_id = s.id and ki.durum <> 9 and ki.islem_tarihi < @p0), 0),
                           (select max(ki.islem_tarihi) from public.kasa_islem ki
                             where ki.belge_id = s.id and ki.durum <> 9 and ki.islem_tarihi < @p0)
                      from bsv s
                    """, null, [bitis, sube], o =>
                {
                    var toplam = o.GetDecimal(3);
                    var kurum = Math.Min(o.GetDecimal(4), toplam);
                    return (hasta: o.IsDBNull(0) ? 0 : o.GetInt32(0), tarih: o.GetDateTime(2),
                            kalan: toplam - kurum - o.GetDecimal(5),
                            sonTahsilat: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6));
                }, iptal);

                var acik = basvurular.Where(x => x.kalan > 0.005m && x.hasta > 0).ToList();
                var hastaIdler = acik.Select(x => x.hasta).Distinct().ToArray();
                var adlar = (await b.ListeAsync("""
                    select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), coalesce(t.kod, '')
                      from public.taraf t where t.id = any(@p0)
                    """, null, [hastaIdler], o => (id: o.GetInt32(0), ad: o.GetString(1), dosyaNo: o.GetString(2)), iptal))
                    .ToDictionary(x => x.id);

                foreach (var g in acik.GroupBy(x => x.hasta))
                {
                    var kalemler = g.Select(x => new Kalem(x.tarih, x.kalan)).ToList();
                    var dilim = Dilimle(kalemler);
                    var toplam = kalemler.Sum(x => x.Tutar);
                    adlar.TryGetValue(g.Key, out var a);
                    hastalar.Add(new HastaAlacagi(g.Key, a.ad ?? "", a.dosyaNo ?? "", kalemler.Count,
                        dilim[0], dilim[1], dilim[2], dilim[3], toplam,
                        kalemler.Max(x => Gun(x.Tarih)),
                        (int)Math.Round(kalemler.Sum(x => x.Tutar * Gun(x.Tarih)) / toplam),
                        // Hastanın bütün başvurularındaki son tahsilat.
                        basvurular.Where(x => x.hasta == g.Key).Select(x => x.sonTahsilat).Max()));
                }
            }

            // ----------------------------------------------------------- özet --
            var ad = new[] { "0 – 30 gün", "31 – 60 gün", "61 – 90 gün", "90+ gün" };
            var kd = new[] { kurumlar.Sum(x => x.D0), kurumlar.Sum(x => x.D30), kurumlar.Sum(x => x.D60), kurumlar.Sum(x => x.D90) };
            var hd = new[] { hastalar.Sum(x => x.D0), hastalar.Sum(x => x.D30), hastalar.Sum(x => x.D60), hastalar.Sum(x => x.D90) };
            var dilimler = Enumerable.Range(0, 4)
                .Select(i => new { ad = ad[i], kurum = kd[i], hasta = hd[i], toplam = kd[i] + hd[i] }).ToList();
            var genel = dilimler.Sum(d => d.toplam);
            var ozet = new
            {
                toplam = genel,
                kurum = kurumlar.Sum(x => x.Toplam), hasta = hastalar.Sum(x => x.Toplam),
                d0 = dilimler[0].toplam, d30 = dilimler[1].toplam, d60 = dilimler[2].toplam, d90 = dilimler[3].toplam,
                enEskiGun = Math.Max(kurumlar.Select(x => x.EnEskiGun).DefaultIfEmpty(0).Max(),
                                     hastalar.Select(x => x.EnEskiGun).DefaultIfEmpty(0).Max()),
                // Tutar ağırlıklı ortalama gün (taraf ortalamalarının ağırlıklı ortalaması).
                ortGun = genel > 0
                    ? (int)Math.Round((kurumlar.Sum(x => x.Toplam * x.OrtGun) + hastalar.Sum(x => x.Toplam * x.OrtGun)) / genel)
                    : 0,
                kurumSayisi = kurumlar.Count, hastaSayisi = hastalar.Count,
                faturasizKurumPayi = kurumlar.Sum(x => x.Faturasiz),
            };

            return Results.Ok(new
            {
                tarih = refTarih, ozet, dilimler,
                kurumlar = kurumlar.OrderByDescending(x => x.Toplam), hastalar = hastalar.OrderByDescending(x => x.Toplam),
            });
        });
    }
}
