using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ECZANE / İLAÇ TÜKETİM İCMALİ (mockup Ekranlar/İcmal/eczane_ilac_icmali.html,
/// kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para><b>Tüketim</b> (ilaç = ilaç kataloğuna bağlı stok, <c>ilac.stok_id</c>):
///   yatan - uygulanmış ilaç / serum dozu (<c>order_uygulama</c> durum 2, order türü 1-2;
///           stok hazırlanan dozdan, yoksa order'ın ilacından), servis = yatışın servisi;
///   ameliyat - ameliyat sarfındaki ilaç stoğu, servis = "Ameliyathane";
///   ayaktan / acil - başvuruya yazılmış ilaç satırı (aynı başvuruda aynı stok için
///           uygulama / ameliyat kaydı yoksa), servis = başvurunun bölümü.
/// Ayrı bir hareket defteri yok (722 kararı) - icmal kaynak kayıtlardan HESAPLANIR.</para>
///
/// <para><b>Faturalanmayan (kaçak adayı):</b> başvuru + stok bazında uygulanan miktar,
///   başvurudaki aynı stok satırının miktarından fazlaysa fark. Ameliyatta "faturaya
///   = 0" (pakete dahil) olan sarf beklenen miktara girmez. Order'ı stoğa bağlanmamış
///   ilaç (serbest yazılan order) faturayla eşleştirilemez - ayrı sayılır, kaçak sayılmaz.
///   Fark tutarı faturadaki birim fiyattan, fatura satırı yoksa fiyat listesinden
///   (fn_belge_kalem_fiyati). Nedeni sistem bilmez - liste kontrol içindir.</para>
///
/// <para><b>Maliyet</b> fn_uretim_stok_maliyeti (giriş belgelerinden ağırlıklı ortalama).
///   Miad v_eczane_miad (90 gün), iade eczane_iade, imha eczane_imha_satir, İTS
///   its_bildirim (iptal ve test bildirimi sayılmaz). Hasta kimliği dönmez - yalnız
///   protokol no ve sayılar.</para>
/// </summary>
public static class EczaneIcmalUclari
{
    /// <summary>Ekran kodu (1042) - haklarını eczane.miad'dan kopyalar.</summary>
    private const string Kod = "eczane.icmal";

    private static readonly Dictionary<short, string> ItsTurleri = new()
    {
        [1] = "Mal alım (kabul)", [2] = "Tüketim (hasta)", [3] = "İade", [4] = "Deaktivasyon (imha)", [5] = "Transfer",
    };
    private static readonly Dictionary<short, string> HataSiniflari = new() { [1] = "veri", [2] = "servis", [3] = "yetki" };
    private static readonly Dictionary<short, string> IadeKararlari = new()
    {
        [0] = "Karar bekliyor", [1] = "Stoğa geri alındı", [2] = "İmha", [3] = "Kontrollü kasaya",
    };

    private sealed record Tuketim(int BelgeId, string Protokol, int HastaId, int ServisId, string Servis, int StokId, string Ad,
        string Etken, decimal Miktar, decimal Beklenen, int Uygulama, DateTime? Son, string Kaynak, decimal FaturaMiktar,
        decimal FaturaTutar, decimal BirimMaliyet, decimal ListeFiyati);

    public static void EczaneIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/eczane-icmal").WithTags("Eczane / İlaç İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? servis, int? depo,
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

            // Tüketim: başvuru × servis × stok gruplanmış; fatura eşleşmesi aynı sorguda.
            var tumu = await b.ListeAsync("""
                with ist as (select distinct stok_id from public.ilac where stok_id is not null),
                uyg as (
                    select y.belge_id, y.hasta_id, coalesce(nullif(y.dosya_no, ''), '') as protokol, coalesce(y.departman_id, 0) as servis_id,
                           coalesce(z.stok_id, il.stok_id) as stok_id, coalesce(nullif(il.ad, ''), od.ad) as ad,
                           coalesce(nullif(z.miktar, 0), 1) as miktar, u.uygulanan as zaman, 1 as faturalanir, 'uygulama' as kaynak
                      from public.order_uygulama u
                      join public.yatis_order od on od.id = u.order_id
                      join public.yatis y on y.id = od.yatis_id
                      left join public.ilac il on il.id = od.ilac_id
                      left join lateral (select z.stok_id, z.miktar from public.eczane_doz z
                                          where z.uygulama_id = u.id and z.durum not in (8, 9) order by z.id desc limit 1) z on true
                     where u.durum = 2 and od.tur in (1, 2) and u.uygulanan >= @p0 and u.uygulanan < @p1
                       and (@p2 = 0 or coalesce(y.sube_id, 0) in (0, @p2))
                    union all
                    select am.belge_id, am.hasta_id, coalesce(am.ameliyat_no, ''), -1, a.stok_id, coalesce(a.ad, ''), a.miktar,
                           coalesce(am.bitis_zamani, am.plan_baslangic, a.ekleme_tarihi), coalesce(a.faturaya, 1), 'ameliyat'
                      from public.ameliyat_sarf a
                      join public.ameliyat am on am.id = a.ameliyat_id
                     where a.stok_id in (select stok_id from ist)
                       and coalesce(am.bitis_zamani, am.plan_baslangic, a.ekleme_tarihi) >= @p0
                       and coalesce(am.bitis_zamani, am.plan_baslangic, a.ekleme_tarihi) < @p1
                       and (@p2 = 0 or coalesce(am.sube_id, 0) in (0, @p2))),
                fat as (
                    select st.belge_id, st.stok_id, sum(coalesce(nullif(st.miktar, 0), st.adet)) as miktar, sum(st.tutar) as tutar
                      from public.belge_satir st
                     where st.stok_id in (select stok_id from ist)
                       and st.belge_id in (select belge_id from uyg where belge_id is not null
                                           union
                                           select be.id from public.belge be
                                            where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                                              and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                                              and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2)))
                     group by st.belge_id, st.stok_id),
                grp as (
                    select coalesce(u.belge_id, 0) as belge_id, max(u.hasta_id) as hasta_id, max(u.protokol) as protokol, u.servis_id,
                           coalesce(u.stok_id, 0) as stok_id, max(u.ad) as ad, sum(u.miktar) as miktar,
                           coalesce(sum(u.miktar) filter (where u.faturalanir = 1), 0) as beklenen,
                           count(*)::int as uygulama, max(u.zaman) as son, min(u.kaynak) as kaynak
                      from uyg u group by coalesce(u.belge_id, 0), u.servis_id, coalesce(u.stok_id, 0)
                    union all
                    select f.belge_id, coalesce(bb.hasta_id, be.taraf_id), '', coalesce(bb.bolum_id, 0), f.stok_id, '', f.miktar, f.miktar,
                           1, be.belge_tarihi, 'fatura'
                      from fat f
                      join public.belge be on be.id = f.belge_id
                      left join public.belge_basvuru bb on bb.id = be.id
                     where be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                       and not exists (select 1 from uyg u where u.belge_id = f.belge_id and u.stok_id = f.stok_id))
                select g.belge_id, coalesce(nullif(be.belge_no, ''), nullif(g.protokol, ''), ''), coalesce(g.hasta_id, 0), g.servis_id,
                       case when g.servis_id = -1 then 'Ameliyathane' else coalesce(d.ad, 'Servis belirsiz') end,
                       g.stok_id, coalesce(nullif(s.ad, ''), nullif(g.ad, ''), 'Stoğa bağlanmamış ilaç'),
                       coalesce((select il.etken_madde from public.ilac il
                                  where il.stok_id = g.stok_id and coalesce(il.etken_madde, '') <> '' limit 1), ''),
                       g.miktar, g.beklenen, g.uygulama, g.son, g.kaynak, coalesce(f.miktar, 0), coalesce(f.tutar, 0),
                       case when g.stok_id > 0 then coalesce(public.fn_uretim_stok_maliyeti(g.stok_id), 0) else 0 end,
                       case when g.stok_id > 0 and coalesce(f.miktar, 0) < g.beklenen and coalesce(f.miktar, 0) = 0 then
                            coalesce((select k.fiyat from public.fn_belge_kalem_fiyati(g.hasta_id, 2::smallint, g.stok_id, null, current_date) k
                                       limit 1), 0)
                            else 0 end
                  from grp g
                  left join fat f on f.belge_id = g.belge_id and f.stok_id = g.stok_id
                  left join public.belge be on be.id = g.belge_id
                  left join public.departman d on d.id = g.servis_id
                  left join public.stok s on s.id = g.stok_id
                """, null, [baslangic, bitis, sube], o => new Tuketim(o.GetInt32(0), o.GetString(1), o.GetInt32(2), o.GetInt32(3),
                    o.GetString(4), o.GetInt32(5), o.GetString(6), o.GetString(7), o.GetDecimal(8), o.GetDecimal(9), o.GetInt32(10),
                    o.IsDBNull(11) ? null : o.GetDateTime(11), o.GetString(12), o.GetDecimal(13), o.GetDecimal(14), o.GetDecimal(15),
                    o.GetDecimal(16)), iptal);
            var servisAdlari = tumu.Select(t => new { id = t.ServisId, ad = t.Servis }).DistinctBy(x => x.id).OrderBy(x => x.ad).ToList();
            var tuketim = tumu.Where(t => servis is not (> 0 or -1) || t.ServisId == servis).ToList();

            var miadHam = await b.ListeAsync("""
                select m.stok_id, coalesce(m.ad, ''), coalesce(m.lot_no, ''), coalesce(dp.ad, ''), m.depo_id, m.skt, m.kalan_gun, m.miktar,
                       round(m.miktar * coalesce(public.fn_uretim_stok_maliyeti(m.stok_id), 0), 2), m.gunluk_tuketim
                  from public.v_eczane_miad m
                  left join public.depo dp on dp.id = m.depo_id
                 where m.kalan_gun <= 90 and exists (select 1 from public.ilac il where il.stok_id = m.stok_id)
                   and (@p0 = 0 or coalesce(dp.sube_id, 0) in (0, @p0))
                 order by m.skt
                """, null, [sube], o => (stok: o.GetInt32(0), ad: o.GetString(1), lot: o.GetString(2), depo: o.GetString(3),
                    depoId: o.GetInt32(4), skt: o.GetDateTime(5), kalanGun: o.GetInt32(6), miktar: o.GetDecimal(7), tutar: o.GetDecimal(8),
                    gunluk: o.GetDecimal(9)), iptal);
            var depoAdlari = miadHam.Select(m => new { id = m.depoId, ad = m.depo }).DistinctBy(x => x.id).OrderBy(x => x.ad).ToList();

            var iadeler = await b.ListeAsync("""
                select coalesce(i.departman_id, 0), coalesce(d.ad, 'Servis belirsiz'), coalesce(nullif(i.ad, ''), s.ad, ''), i.miktar,
                       round(i.miktar * case when i.stok_id is not null then coalesce(public.fn_uretim_stok_maliyeti(i.stok_id), 0) else 0 end, 2),
                       coalesce(i.karar, 0)::smallint, coalesce(i.ambalaj_acik, 0) = 1, coalesce(i.sulandirildi, 0) = 1,
                       coalesce(i.soguk_zincir_bozuk, 0) = 1, coalesce(i.iade_neden, ''), i.ekleme_tarihi
                  from public.eczane_iade i
                  left join public.departman d on d.id = i.departman_id
                  left join public.stok s on s.id = i.stok_id
                 where i.ekleme_tarihi >= @p0 and i.ekleme_tarihi < @p1 and (@p2 = 0 or coalesce(i.sube_id, 0) in (0, @p2))
                 order by i.ekleme_tarihi
                """, null, [baslangic, bitis, sube], o => (servisId: o.GetInt32(0), servis: o.GetString(1), ad: o.GetString(2),
                    miktar: o.GetDecimal(3), tutar: o.GetDecimal(4), karar: o.GetInt16(5), ambalaj: o.GetBoolean(6), sulandi: o.GetBoolean(7),
                    soguk: o.GetBoolean(8), neden: o.GetString(9), tarih: o.GetDateTime(10)), iptal);
            var imha = (await b.ListeAsync("""
                select coalesce(sum(st.tutar), 0), coalesce(sum(st.miktar), 0), count(distinct im.id)::int
                  from public.eczane_imha im join public.eczane_imha_satir st on st.imha_id = im.id
                 where im.tarih >= @p0::date and im.tarih < @p1::date and (@p2 = 0 or coalesce(im.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => (tutar: o.GetDecimal(0), miktar: o.GetDecimal(1), tutanak: o.GetInt32(2)), iptal))[0];

            var its = await b.ListeAsync("""
                select bi.id, coalesce(bi.tur, 0)::smallint, coalesce(bi.durum, 0)::smallint, coalesce(be.belge_no, ''),
                       coalesce((select coalesce(s.ad, '') from public.its_bildirim_satir x left join public.stok s on s.id = x.stok_id
                                  where x.bildirim_id = bi.id order by x.id limit 1), ''),
                       coalesce((select x.seri_no from public.its_bildirim_satir x where x.bildirim_id = bi.id order by x.id limit 1), ''),
                       (select count(*) from public.its_bildirim_satir x where x.bildirim_id = bi.id)::int,
                       coalesce(bi.hata_kodu, ''), coalesce(bi.hata_mesaj, ''), coalesce(bi.hata_sinifi, 0)::smallint,
                       coalesce(bi.deneme, 0)::smallint, coalesce(bi.islem_tarihi::timestamp, bi.ekleme_tarihi::timestamp)
                  from public.its_bildirim bi
                  left join public.belge be on be.id = bi.belge_id
                 where coalesce(bi.islem_tarihi::timestamp, bi.ekleme_tarihi::timestamp) >= @p0
                   and coalesce(bi.islem_tarihi::timestamp, bi.ekleme_tarihi::timestamp) < @p1
                   and coalesce(bi.durum, 0) <> 5 and coalesce(bi.test_mi, 0) = 0
                   and (@p2 = 0 or coalesce(bi.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => (id: o.GetInt32(0), tur: o.GetInt16(1), durum: o.GetInt16(2), protokol: o.GetString(3),
                    ilac: o.GetString(4), seri: o.GetString(5), kalem: o.GetInt32(6), hataKodu: o.GetString(7), mesaj: o.GetString(8),
                    sinif: o.GetInt16(9), deneme: o.GetInt16(10), tarih: o.GetDateTime(11)), iptal);

            // ------------------------------------------------- satır hesapları --
            static decimal R(decimal x) => Math.Round(x, 2, MidpointRounding.ToEven);
            decimal Maliyet(Tuketim t) => R(t.Miktar * t.BirimMaliyet);
            decimal FatMiktar(Tuketim t) => Math.Min(t.FaturaMiktar, t.Miktar);
            decimal FatTutar(Tuketim t) => t.FaturaMiktar > 0 ? R(t.FaturaTutar * FatMiktar(t) / t.FaturaMiktar) : 0m;
            bool Eslesir(Tuketim t) => t.StokId > 0;
            decimal Eksik(Tuketim t) => Eslesir(t) ? Math.Max(0, t.Beklenen - t.FaturaMiktar) : 0m;
            decimal SatisBirim(Tuketim t) => t.FaturaMiktar > 0 ? t.FaturaTutar / t.FaturaMiktar : t.ListeFiyati;
            decimal EksikTutar(Tuketim t) => R(Eksik(t) * SatisBirim(t));
            static decimal? Oran(decimal pay, decimal payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;

            object Topla(IReadOnlyCollection<Tuketim> l)
            {
                var maliyet = l.Sum(Maliyet); var fat = l.Sum(FatTutar); var kacak = l.Sum(EksikTutar);
                var hasta = l.Where(t => t.HastaId > 0).Select(t => t.HastaId).Distinct().Count();
                return new
                {
                    hasta, kalem = l.Where(t => t.StokId > 0).Select(t => t.StokId).Distinct().Count(), miktar = l.Sum(t => t.Miktar),
                    maliyet, faturalanan = fat, faturalanmayan = kacak, faturalanmayanAdet = l.Sum(Eksik),
                    kacakOrani = Oran(kacak, fat + kacak), hastaBasi = hasta > 0 ? R(maliyet / hasta) : 0m,
                };
            }

            // ------------------------------------------------------------ servisler --
            var iadeServis = iadeler.GroupBy(i => i.servisId).ToDictionary(g => g.Key, g => g.Sum(i => i.tutar));
            var toplamMaliyet = tuketim.Sum(Maliyet);
            var servisler = tuketim.GroupBy(t => (t.ServisId, t.Servis)).Select(g =>
            {
                var l = g.ToList();
                return new
                {
                    id = g.Key.ServisId, ad = g.Key.Servis, ozet = Topla(l),
                    iade = iadeServis.GetValueOrDefault(g.Key.ServisId),
                    pay = Oran(l.Sum(Maliyet), toplamMaliyet),
                    enCok = l.Where(t => t.StokId > 0).GroupBy(t => t.Ad).Select(x => new { ad = x.Key, miktar = x.Sum(t => t.Miktar), maliyet = x.Sum(Maliyet) })
                        .OrderByDescending(x => x.maliyet).Take(3).ToList(),
                    maliyet = l.Sum(Maliyet),
                };
            }).OrderByDescending(x => x.maliyet).ToList();

            // --------------------------------------------------------------- ilaçlar --
            var ilaclar = tuketim.GroupBy(t => (t.StokId, t.Ad)).Select(g =>
            {
                var l = g.ToList();
                return new
                {
                    stokId = g.Key.StokId, ad = g.Key.Ad, etken = l.First().Etken, servis = l.Select(t => t.ServisId).Distinct().Count(),
                    miktar = l.Sum(t => t.Miktar), birimMaliyet = R(l.First().BirimMaliyet), maliyet = l.Sum(Maliyet),
                    faturalanan = l.Sum(FatTutar), faturalanmayan = l.Sum(EksikTutar), faturalanmayanAdet = l.Sum(Eksik),
                    eslesmez = g.Key.StokId == 0,
                };
            }).OrderByDescending(x => x.maliyet).ThenBy(x => x.ad).ToList();

            // -------------------------------------------------------- faturalanmayan --
            var faturasiz = tuketim.Where(t => Eksik(t) > 0).Select(t => new
            {
                tarih = t.Son, protokol = t.Protokol, servis = t.Servis, ilac = t.Ad, adet = Eksik(t), uygulanan = t.Beklenen,
                faturada = t.FaturaMiktar, tutar = EksikTutar(t), fiyatYok = SatisBirim(t) == 0, kaynak = t.Kaynak, belgeId = t.BelgeId,
                neden = t.BelgeId == 0 ? "yatışın başvurusu yok" : t.FaturaMiktar > 0 ? "faturada eksik" : "faturada yok",
            }).OrderByDescending(x => x.tutar).ThenBy(x => x.tarih).ToList();

            // ------------------------------------------------------------------ miad --
            var bugun = DateTime.Today;
            var miad = miadHam.Where(m => depo is not > 0 || m.depoId == depo).Select(m => new
            {
                m.ad, m.lot, m.depo, m.skt, m.kalanGun, m.miktar, m.tutar, m.gunluk,
                durum = m.kalanGun < 0 ? "dolmuş" : m.kalanGun <= 30 ? "30" : "90",
                tuketilir = m.kalanGun >= 0 && m.gunluk > 0 && m.gunluk * m.kalanGun >= m.miktar,
            }).ToList();

            var iadeListe = iadeler.Where(i => servis is not (> 0 or -1) || i.servisId == servis).Select(i => new
            {
                i.tarih, i.servis, ilac = i.ad, i.miktar, i.tutar, karar = IadeKararlari.GetValueOrDefault(i.karar, "Karar bekliyor"),
                kararKod = i.karar,
                gerekce = string.Join(" · ", new[] { i.ambalaj ? "açık ambalaj" : "", i.sulandi ? "sulandırıldı" : "",
                    i.soguk ? "soğuk zincir" : "", i.neden }.Where(x => x.Length > 0)),
            }).ToList();

            // ------------------------------------------------------------------- İTS --
            var itsOzet = its.GroupBy(x => x.tur).OrderBy(g => g.Key).Select(g => new
            {
                tur = ItsTurleri.GetValueOrDefault(g.Key, "Diğer"), bildirim = g.Count(), basarili = g.Count(x => x.durum == 3),
                hatali = g.Count(x => x.durum == 4), bekleyen = g.Count(x => x.durum is 0 or 1 or 2),
                basari = Oran(g.Count(x => x.durum == 3), g.Count(x => x.durum is 3 or 4)),
            }).ToList();
            var itsHatali = its.Where(x => x.durum == 4).OrderBy(x => x.tarih).Select(x => new
            {
                x.id, x.tarih, tur = ItsTurleri.GetValueOrDefault(x.tur, "Diğer"), x.protokol, x.ilac, x.seri, x.kalem, x.hataKodu, x.mesaj,
                sinif = HataSiniflari.GetValueOrDefault(x.sinif, "—"), x.deneme,
            }).ToList();

            var tumOzet = Topla(tuketim);
            var ozet = new
            {
                cikis = tuketim.Sum(t => t.Miktar), kalem = tuketim.Select(t => (t.ServisId, t.StokId)).Distinct().Count(),
                ilac = tuketim.Where(t => t.StokId > 0).Select(t => t.StokId).Distinct().Count(), servis = servisler.Count,
                maliyet = toplamMaliyet, faturalanan = tuketim.Sum(FatTutar),
                faturaAdetOrani = Oran(tuketim.Where(Eslesir).Sum(FatMiktar), tuketim.Where(Eslesir).Sum(t => t.Beklenen)),
                faturalanmayan = tuketim.Sum(EksikTutar), faturalanmayanAdet = tuketim.Sum(Eksik), faturalanmayanKayit = faturasiz.Count,
                eslesmeyen = tuketim.Where(t => !Eslesir(t)).Sum(t => t.Uygulama),
                hasta = tuketim.Where(t => t.HastaId > 0).Select(t => t.HastaId).Distinct().Count(),
                hastaBasi = tuketim.Any(t => t.HastaId > 0)
                    ? R(toplamMaliyet / tuketim.Where(t => t.HastaId > 0).Select(t => t.HastaId).Distinct().Count()) : 0m,
                miadDolmus = miad.Count(m => m.durum == "dolmuş"), miad30 = miad.Count(m => m.durum == "30"), miad90 = miad.Count(m => m.durum == "90"),
                miadDolmusTutar = miad.Where(m => m.durum == "dolmuş").Sum(m => m.tutar), miad30Tutar = miad.Where(m => m.durum == "30").Sum(m => m.tutar),
                miadTutar = miad.Sum(m => m.tutar),
                itsBildirim = its.Count, itsHatali = its.Count(x => x.durum == 4), itsBekleyen = its.Count(x => x.durum is 0 or 1 or 2),
                itsBasarili = its.Count(x => x.durum == 3),
                itsBasari = Oran(its.Count(x => x.durum == 3), its.Count(x => x.durum is 3 or 4)),
                iade = iadeListe.Sum(i => i.tutar), iadeAdet = iadeListe.Sum(i => i.miktar), iadeKayit = iadeListe.Count,
                imha = imha.tutar, imhaTutanak = imha.tutanak, bugun,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, toplam = tumOzet, servisler, ilaclar,
                ilacToplam = new
                {
                    miktar = ilaclar.Sum(x => x.miktar), maliyet = ilaclar.Sum(x => x.maliyet), faturalanan = ilaclar.Sum(x => x.faturalanan),
                    faturalanmayan = ilaclar.Sum(x => x.faturalanmayan),
                },
                faturasiz, miad, iadeler = iadeListe, itsOzet, itsHatali,
                servisAdlari, depoAdlari,
            });
        });
    }
}
