using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STOK İCMALLERİ (1173, kullanıcı 24.10.2026 - mockup Ekranlar/Stok/stok_deger_icmali.html,
/// stok_skt_icmali.html, stok_sayim_fark_icmali.html; "genel uygulanan sistem ne ise").
///
/// <para><b>Stok Değer</b> `/api/stok-icmal/deger`: tarih itibarıyla depo bakiyesi (bugün =
/// stok_durum; geçmiş tarih = stok_durum - o tarihten sonraki hareketler, v_stok_hareket)
/// x birim maliyet. Değerleme: ortalama maliyet (giriş belgelerinin ağırlıklı ortalaması,
/// fn_uretim_stok_maliyeti - üretim maliyetiyle aynı), son alış ya da kart satış fiyatı.
/// Hareketsizlik son çıkıştan; devir hızı 12 aylık çıkış / bugünkü stok.</para>
///
/// <para><b>SKT / Lot</b> `/api/stok-icmal/skt`: lot defteri (stok_lot_durum) + SKT
/// (stok_seri_lot). Tutar lot kalanı x stokun ortalama maliyeti (lot bazında maliyet yok).
/// Öneri: SKT geçmiş → imha / iade; aynı stok-depoda daha geç SKT'li lottan son 90 günde
/// çıkış varsa → FEFO; son 90 günün çıkış hızı lotu SKT'ye kadar bitirmiyorsa → satış hızı
/// yetmez.</para>
///
/// <para><b>Sayım Fark</b> `/api/stok-icmal/sayim-fark`: stok_sayim / _satir (1169). Tutar
/// = fark x satırın sayım anındaki birim maliyeti - kapanan sayımda kesilen fişlerle aynı.
/// Doğruluk = sayılan satırlardan sistemle aynı çıkanların oranı.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Depo süzgeci kullanıcının şubeleriyle sınırlı.
/// </summary>
public static partial class StokIcmalUclari
{
    private const string KodDeger = "stok.deger_icmali";
    private const string KodSkt = "stok.skt_icmali";
    private const string KodFark = "stok.sayim_fark_icmali";

    /// <summary>Ortak süzgeç: kategori alt ağacı (dal), stoklar (st), depolar (dp).
    ///   @p1 depo · @p2 kategori · @p3 pasif dahil · @p4 kullanıcının şubeleri.</summary>
    private const string Suzgec = """
        with recursive dal as (
            select k.id from public.kategori k where @p2 > 0 and k.id = @p2
            union all
            select k.id from public.kategori k join dal on k.ust_id = dal.id
        ),
        st as materialized (
            select s.id, coalesce(s.kod, '') as kod, coalesce(s.ad, '') as ad, coalesce(s.izleme, 0)::int as izleme,
                   coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '(kategorisiz)') as kat,
                   coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim), '') as birim
              from public.stok s
              left join public.kategori k on k.id = s.kategori
             where (@p3 = 1 or s.durum = 1)
               and (@p2 = 0 or s.kategori in (select id from dal))
        ),
        dp as materialized (
            select d.id, coalesce(d.ad, '') as ad, d.son_sayim_tarihi
              from public.depo d
             where (@p1 = 0 or d.id = @p1)
               and (d.sube_id is null or d.sube_id = any(@p4::int[]))
        )
        """;

    /// <summary>Tarih itibarıyla stok × depo bakiyesi + son giriş / çıkış + 12 ay çıkış. @p0 tarih.</summary>
    private const string BakiyeSorgusu = Suzgec + """
        ,
        sonra as (
            select h.stok_id, h.depo_id, sum(h.giren - h.cikan) as net
              from public.v_stok_hareket h where h.tarih > @p0::date group by 1, 2
        ),
        bak as (
            select sd.stok_id, sd.depo_id, sd.kalan - coalesce(so.net, 0) as miktar
              from public.stok_durum sd
              join dp on dp.id = sd.depo_id
              join st on st.id = sd.stok_id
              left join sonra so on so.stok_id = sd.stok_id and so.depo_id = sd.depo_id
        ),
        hk as (
            select h.stok_id,
                   max(h.tarih) filter (where h.giren > 0) as son_giris,
                   max(h.tarih) filter (where h.cikan > 0 and h.tur <> 20) as son_cikis,
                   coalesce(sum(h.cikan) filter (where h.tarih > @p0::date - 365 and h.tur <> 20), 0) as cikan12
              from public.v_stok_hareket h
              join dp on dp.id = h.depo_id
             where h.tarih <= @p0::date
             group by 1
        )
        select st.id, st.kod, st.ad, st.kat, st.izleme, st.birim, bak.depo_id, dp.ad, bak.miktar,
               hk.son_giris, hk.son_cikis, coalesce(hk.cikan12, 0)
          from bak
          join st on st.id = bak.stok_id
          join dp on dp.id = bak.depo_id
          left join hk on hk.stok_id = st.id
         where abs(bak.miktar) > 0.00001
        """;

    private sealed record Bakiye(int StokId, string Kod, string Ad, string Kategori, int Izleme, string Birim,
        int DepoId, string Depo, decimal Miktar, DateTime? SonGiris, DateTime? SonCikis, decimal Cikan12);

    private static object?[] Parametre(object tarih, int depo, int kategori, int pasif, int[] subeler)
        => [tarih, depo, kategori, pasif, subeler];

    private static Task<List<Bakiye>> BakiyeAsync(NpgsqlConnection b, DateTime tarih, int depo, int kategori,
        int pasif, int[] subeler, CancellationToken iptal)
        => b.ListeAsync(BakiyeSorgusu, null, Parametre(tarih, depo, kategori, pasif, subeler), o => new Bakiye(
            o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetInt32(4), o.GetString(5),
            o.GetInt32(6), o.GetString(7), o.GetDecimal(8),
            o.IsDBNull(9) ? null : o.GetDateTime(9), o.IsDBNull(10) ? null : o.GetDateTime(10), o.GetDecimal(11)), iptal);

    /// <summary>Birim maliyet: ort (ağırlıklı ortalama) · son (son alış, yoksa ortalama) · satis (kart satış fiyatı).</summary>
    private static async Task<Dictionary<int, decimal>> MaliyetAsync(NpgsqlConnection b, IEnumerable<int> idler,
        string yontem, CancellationToken iptal)
    {
        var dizi = idler.Distinct().ToArray();
        if (dizi.Length == 0) return new();
        var ifade = yontem switch
        {
            "son" => """
                coalesce((select round(bs.tutar / bs.miktar, 4)
                            from public.belge_satir bs join public.belge b on b.id = bs.belge_id
                           where bs.stok_id = x.id and bs.miktar > 0 and bs.tutar > 0 and b.durum = 0
                             and b.tur in (3, 10, 11, 12, 109, 122)
                           order by b.belge_tarihi desc, b.id desc limit 1),
                         public.fn_uretim_stok_maliyeti(x.id), 0)
                """,
            "satis" => "coalesce((select f.fiyat from public.fn_stok_kart_fiyat(x.id, 1::smallint) f), 0)",
            _ => "coalesce(public.fn_uretim_stok_maliyeti(x.id), 0)",
        };
        var l = await b.ListeAsync($"select x.id, {ifade} from unnest(@p0::int[]) as x(id)", null, [dizi],
            o => (id: o.GetInt32(0), m: o.GetDecimal(1)), iptal);
        return l.ToDictionary(x => x.id, x => x.m);
    }

    private static int[] Subeler(IstekBaglami baglam) => baglam.Subeler.Select(s => s.Id).ToArray();

    public static void StokIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/stok-icmal").WithTags("Stok İcmalleri").RequireAuthorization();
        EkUclariEkle(grup);   // hareket · ölü stok · kritik stok (1174)

        // ================================================================ DEĞER ===
        grup.MapGet("/deger", async (DateTime? tarih, int? depo, int? kategori, string? yontem, int? pasif,
                                     VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodDeger, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var t = (tarih ?? bugun).Date;
            if (t > bugun) t = bugun;
            var ynt = yontem is "son" or "satis" ? yontem : "ort";
            var subeler = Subeler(baglam);
            await using var b = await veri.AcAsync(iptal);

            var satirlar = await BakiyeAsync(b, t, depo ?? 0, kategori ?? 0, pasif ?? 0, subeler, iptal);
            // ÖNCEKİ AY SONU: aynı küme bir ay geri - "değer bu ay ne kadar değişti".
            var aySonu = new DateTime(t.Year, t.Month, 1).AddDays(-1);
            var onceki = await BakiyeAsync(b, aySonu, depo ?? 0, kategori ?? 0, pasif ?? 0, subeler, iptal);
            var maliyet = await MaliyetAsync(b, satirlar.Select(x => x.StokId).Concat(onceki.Select(x => x.StokId)), ynt, iptal);
            decimal M(int id) => maliyet.TryGetValue(id, out var m) ? m : 0;

            // LOT KIRILIMI yalnız BUGÜN için (lot defteri anlık bakiyedir, geriye sarılmaz).
            var lotlar = t == bugun
                ? await b.ListeAsync(Suzgec + """
                    select ld.stok_id, ld.depo_id, coalesce(nullif(l.lot_no, ''), nullif(l.seri_no, ''), '') as lot,
                           l.son_kullanma_tarihi, ld.kalan
                      from public.stok_lot_durum ld
                      join dp on dp.id = ld.depo_id
                      join st on st.id = ld.stok_id
                      join public.stok_seri_lot l on l.id = ld.seri_lot_id
                     where ld.kalan <> 0
                     order by l.son_kullanma_tarihi nulls last
                    """, null, Parametre(t, depo ?? 0, kategori ?? 0, pasif ?? 0, subeler), o => (
                        stok: o.GetInt32(0), depo: o.GetInt32(1), lot: o.GetString(2),
                        skt: o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3), kalan: o.GetDecimal(4)), iptal)
                : [];

            var stoklar = satirlar.GroupBy(x => x.StokId).Select(g =>
            {
                var ilk = g.First();
                var miktar = g.Sum(x => x.Miktar);
                var bm = M(g.Key);
                var lot = lotlar.Where(l => l.stok == g.Key).ToList();
                var lotToplam = lot.Sum(l => l.kalan);
                return new
                {
                    id = g.Key, ilk.Kod, ilk.Ad, kategori = ilk.Kategori, ilk.Izleme, ilk.Birim,
                    miktar, birimMaliyet = bm, tutar = Math.Round(miktar * bm, 2),
                    sonGiris = ilk.SonGiris, sonCikis = ilk.SonCikis, cikan12 = ilk.Cikan12,
                    // HAREKETSİZ = son hareketten (giriş ya da çıkış) bu yana; hiç hareket yoksa null.
                    hareketsizGun = (ilk.SonCikis > ilk.SonGiris ? ilk.SonCikis : ilk.SonGiris ?? ilk.SonCikis) is { } sh
                        ? (int)(t - sh.Date).TotalDays : (int?)null,
                    depolar = g.Select(x => new { depoId = x.DepoId, depo = x.Depo, miktar = x.Miktar }).ToList(),
                    lotlar = lot.Select(l => new { l.lot, l.skt, l.kalan, depoId = l.depo }).ToList(),
                    lotsuz = ilk.Izleme != 0 && t == bugun ? miktar - lotToplam : 0m,
                };
            }).OrderByDescending(x => x.tutar).ToList();

            var toplam = stoklar.Sum(x => x.tutar);
            bool Hareketsiz(int? gun) => gun is null || gun > 180;
            var oncekiDeger = onceki.GroupBy(x => x.StokId).Sum(g => Math.Round(g.Sum(x => x.Miktar) * M(g.Key), 2));
            var ozet = new
            {
                deger = toplam, kalem = stoklar.Count,
                aktifStok = await b.TekDegerAsync<int>("select count(*)::int from public.stok where durum = 1", null, [], iptal),
                miktar = stoklar.Sum(x => x.miktar),
                lotluKalem = stoklar.Count(x => x.Izleme != 0),
                lotluDeger = stoklar.Where(x => x.Izleme != 0).Sum(x => x.tutar),
                lotSayisi = lotlar.Count,
                hareketsizDeger = stoklar.Where(x => x.tutar > 0 && Hareketsiz(x.hareketsizGun)).Sum(x => x.tutar),
                hareketsizKalem = stoklar.Count(x => x.tutar > 0 && Hareketsiz(x.hareketsizGun)),
                maliyetsiz = stoklar.Count(x => x.miktar > 0 && x.birimMaliyet == 0),
                eksiKalem = stoklar.Count(x => x.miktar < 0), eksiMiktar = stoklar.Where(x => x.miktar < 0).Sum(x => x.miktar),
                oncekiAySonu = aySonu, oncekiDeger,
            };

            // ------------------------------------------------ kategori × depo --
            var depolar = satirlar.Select(x => new { id = x.DepoId, ad = x.Depo }).Distinct().OrderBy(x => x.ad).ToList();
            var katDepo = satirlar.GroupBy(x => x.Kategori).Select(g => new
            {
                kategori = g.Key,
                hucreler = depolar.Select(d => Math.Round(g.Where(x => x.DepoId == d.id).Sum(x => x.Miktar * M(x.StokId)), 2)).ToList(),
                toplam = Math.Round(g.Sum(x => x.Miktar * M(x.StokId)), 2),
                kalem = g.Select(x => x.StokId).Distinct().Count(),
            }).OrderByDescending(x => x.toplam).ToList();

            // ---------------------------------------------------- stok yaşı --
            (string ad, Func<int?, bool> f)[] dilim =
            [
                ("0 – 30 gün", g => g is <= 30), ("31 – 90 gün", g => g is > 30 and <= 90),
                ("91 – 180 gün", g => g is > 90 and <= 180), ("180+ gün / hiç çıkmadı", g => g is null or > 180),
            ];
            var yas = dilim.Select(d =>
            {
                var l = stoklar.Where(x => x.tutar > 0 && d.f(x.hareketsizGun)).ToList();
                return new { d.ad, tutar = l.Sum(x => x.tutar), kalem = l.Count };
            }).ToList();
            var devir = stoklar.GroupBy(x => x.kategori).Select(g =>
            {
                var stokDeger = g.Sum(x => x.tutar);
                var cikanDeger = g.Sum(x => x.cikan12 * x.birimMaliyet);
                var d = stokDeger > 0.005m ? Math.Round(cikanDeger / stokDeger, 1) : 0m;
                return new { kategori = g.Key, devir = d, gun = d > 0 ? (int?)Math.Round(365 / d) : null, stokDeger };
            }).Where(x => x.stokDeger > 0.005m).OrderByDescending(x => x.stokDeger).Take(15).ToList();

            // -------------------------------------------------------- dikkat --
            var dikkat = new
            {
                eksi = satirlar.Where(x => x.Miktar < 0).OrderBy(x => x.Miktar).Take(50)
                    .Select(x => new { id = x.StokId, x.Kod, x.Ad, x.Depo, x.Miktar, x.SonCikis }).ToList(),
                maliyetsiz = stoklar.Where(x => x.miktar > 0 && x.birimMaliyet == 0).OrderByDescending(x => x.miktar).Take(50)
                    .Select(x => new { x.id, x.Kod, x.Ad, x.miktar, x.sonGiris }).ToList(),
                lotUyumsuz = stoklar.Where(x => x.Izleme != 0 && Math.Abs(x.lotsuz) > 0.00001m).OrderByDescending(x => Math.Abs(x.lotsuz)).Take(50)
                    .Select(x => new { x.id, x.Kod, x.Ad, x.miktar, lotToplam = x.miktar - x.lotsuz, x.lotsuz }).ToList(),
                hareketsiz = stoklar.Where(x => x.tutar > 0 && Hareketsiz(x.hareketsizGun)).OrderByDescending(x => x.tutar).Take(20)
                    .Select(x => new { x.id, x.Kod, x.Ad, x.tutar, x.sonCikis, x.hareketsizGun }).ToList(),
            };

            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var depoListesi = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.depo d
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                tarih = t, bugun = t == bugun, yontem = ynt, ozet, stoklar, depolar, katDepo, yas, devir, dikkat,
                kategoriler, depoListesi, izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================================== SKT ===
        grup.MapGet("/skt", async (DateTime? tarih, int? ufuk, int? depo, int? kategori,
                                   VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodSkt, Islem.Gor);
            var r = (tarih ?? Saat.Bugun).Date;
            var u = ufuk is 30 or 90 or 180 or 365 ? ufuk.Value : 180;
            var subeler = Subeler(baglam);
            await using var b = await veri.AcAsync(iptal);
            object?[] p = [r, depo ?? 0, kategori ?? 0, 0, subeler];

            var lotlar = await b.ListeAsync(Suzgec + """
                ,
                lot as (
                    select ld.stok_id, ld.depo_id, ld.seri_lot_id, ld.kalan,
                           coalesce(nullif(l.lot_no, ''), nullif(l.seri_no, ''), '') as lot,
                           l.uretim_tarihi, l.son_kullanma_tarihi as skt
                      from public.stok_lot_durum ld
                      join dp on dp.id = ld.depo_id
                      join st on st.id = ld.stok_id
                      join public.stok_seri_lot l on l.id = ld.seri_lot_id
                     where ld.kalan <> 0
                ),
                -- FEFO: aynı stok-depoda SON 90 GÜNDE çıkışı olan en geç SKT'li lot (tükenmiş olsa da).
                --   Bu lottan daha erken SKT'li lot hâlâ duruyorsa "önce bunu çıkar".
                fe as (
                    select i.stok_id, i.depo_id, max(l.son_kullanma_tarihi) as max_skt
                      from public.stok_izleme i
                      join public.stok_seri_lot l on l.id = i.seri_lot_id
                     where i.ekleme_tarihi > @p0::date - 90
                       and (i.belge_tur in (14, 15, 16, 119, 4, 29, 133) or (i.belge_tur = 20 and coalesce(i.donus_id, 0) = 0))
                     group by 1, 2
                ),
                c90 as (
                    select h.stok_id, h.depo_id, sum(h.cikan) as cikan
                      from public.v_stok_hareket h
                     where h.tarih > @p0::date - 90 and h.tarih <= @p0::date and h.tur <> 20
                     group by 1, 2
                )
                select lot.stok_id, st.kod, st.ad, st.kat, st.izleme, lot.depo_id, dp.ad, lot.seri_lot_id, lot.lot,
                       lot.uretim_tarihi, lot.skt, lot.kalan, coalesce(c90.cikan, 0),
                       coalesce(lot.skt < fe.max_skt, false) as fefo
                  from lot
                  join st on st.id = lot.stok_id
                  join dp on dp.id = lot.depo_id
                  left join c90 on c90.stok_id = lot.stok_id and c90.depo_id = lot.depo_id
                  left join fe on fe.stok_id = lot.stok_id and fe.depo_id = lot.depo_id
                """, null, p, o => new
                {
                    stokId = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), kategori = o.GetString(3),
                    izleme = o.GetInt32(4), depoId = o.GetInt32(5), depo = o.GetString(6), seriLotId = o.GetInt32(7),
                    lot = o.GetString(8), uretim = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                    skt = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), kalan = o.GetDecimal(11),
                    cikan90 = o.GetDecimal(12), fefo = o.GetBoolean(13),
                }, iptal);

            var maliyet = await MaliyetAsync(b, lotlar.Select(x => x.stokId), "ort", iptal);
            var satirlar = lotlar.Select(x =>
            {
                var bm = maliyet.TryGetValue(x.stokId, out var m) ? m : 0;
                int? gun = x.skt is { } s ? (int)(s.Date - r).TotalDays : null;
                var gunluk = x.cikan90 / 90m;
                var artan = gun is > 0 && x.kalan > 0 ? Math.Max(0, Math.Round(x.kalan - gunluk * gun.Value, 1)) : 0m;
                var oneri = x.kalan < 0 ? "eksi"
                          : gun is null ? "sktsiz"
                          : gun < 0 ? "imha"
                          : x.fefo ? "fefo"
                          : gun <= u && artan > 0 ? "hiz"
                          : gun <= u ? "takip" : "";
                return new
                {
                    x.stokId, x.kod, x.ad, x.kategori, x.izleme, x.depoId, x.depo, x.seriLotId, x.lot, x.uretim, x.skt,
                    kalanGun = gun, x.kalan, birimMaliyet = bm, tutar = Math.Round(x.kalan * bm, 2),
                    x.cikan90, tahminiArtan = artan, oneri,
                };
            }).ToList();

            var pozitif = satirlar.Where(x => x.kalan > 0).ToList();
            object Kutu(Func<int?, bool> f)
            {
                var l = pozitif.Where(x => f(x.kalanGun)).ToList();
                return new { tutar = l.Sum(x => x.tutar), lot = l.Count, miktar = l.Sum(x => x.kalan) };
            }
            // LOTSUZ BAKİYE: izlemli stokta depo bakiyesi - lot toplamı (bugün).
            var lotsuz = await b.ListeAsync(Suzgec + """
                select st.id, st.kod, st.ad, dp.ad, sd.kalan,
                       coalesce((select sum(ld.kalan) from public.stok_lot_durum ld
                                  where ld.stok_id = st.id and ld.depo_id = dp.id), 0) as lot_toplam
                  from public.stok_durum sd
                  join st on st.id = sd.stok_id and st.izleme <> 0
                  join dp on dp.id = sd.depo_id
                """, null, p, o => new
                {
                    stokId = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), depo = o.GetString(3),
                    stok = o.GetDecimal(4), lotToplam = o.GetDecimal(5),
                }, iptal);
            var lotsuzlar = lotsuz.Where(x => Math.Abs(x.stok - x.lotToplam) > 0.00001m)
                .Select(x => new { x.stokId, x.kod, x.ad, x.depo, x.stok, x.lotToplam, lotsuz = x.stok - x.lotToplam })
                .OrderByDescending(x => Math.Abs(x.lotsuz)).ToList();

            var ozet = new
            {
                gecmis = Kutu(g => g < 0), gun30 = Kutu(g => g is >= 0 and <= 30), gun90 = Kutu(g => g is > 30 and <= 90),
                gun180 = Kutu(g => g is > 90 and <= 180), ufukOtesi = Kutu(g => g > 180), sktsiz = Kutu(g => g is null),
                lotluDeger = pozitif.Sum(x => x.tutar), lotluKalem = pozitif.Select(x => x.stokId).Distinct().Count(),
                lotSayisi = pozitif.Count,
                eksiLot = satirlar.Count(x => x.kalan < 0), eksiMiktar = satirlar.Where(x => x.kalan < 0).Sum(x => x.kalan),
                lotsuzKalem = lotsuzlar.Count,
            };

            // ------------------------------------------------- aylık takvim --
            var sinir = r.AddDays(u);
            var aylar = pozitif.Where(x => x.skt is { } s && s.Date >= r && s.Date <= sinir)
                .GroupBy(x => new DateTime(x.skt!.Value.Year, x.skt.Value.Month, 1))
                .OrderBy(g => g.Key)
                .Select(g =>
                {
                    var enb = g.OrderByDescending(x => x.tutar).First();
                    return new { ay = g.Key, lot = g.Count(), miktar = g.Sum(x => x.kalan), tutar = g.Sum(x => x.tutar),
                                 enBuyuk = $"{enb.kod} · {enb.lot} · {enb.kalan:0.##}" };
                }).ToList();
            var gecmisL = pozitif.Where(x => x.kalanGun < 0).ToList();
            var otesiL = pozitif.Where(x => x.skt is { } s && s.Date > sinir).ToList();
            var takvim = new
            {
                gecmis = new { lot = gecmisL.Count, miktar = gecmisL.Sum(x => x.kalan), tutar = gecmisL.Sum(x => x.tutar),
                               enBuyuk = gecmisL.OrderByDescending(x => x.tutar).Select(x => $"{x.kod} · {x.lot} · {x.kalan:0.##}").FirstOrDefault() ?? "" },
                aylar,
                otesi = new { lot = otesiL.Count, tutar = otesiL.Sum(x => x.tutar) },
            };

            // Ufuk içindeki (ve geçmiş) lotlar SKT'ye göre - Lot Bazında sekmesi.
            var ufuktaki = satirlar.Where(x => x.kalan > 0 && x.kalanGun is { } g && g <= u)
                .OrderBy(x => x.skt).ToList();
            var stoklar = satirlar.GroupBy(x => x.stokId).Select(g =>
            {
                var ilk = g.First();
                var poz = g.Where(x => x.kalan > 0).ToList();
                return new
                {
                    ilk.stokId, ilk.kod, ilk.ad, ilk.izleme, lot = poz.Count, toplam = poz.Sum(x => x.kalan),
                    enYakin = poz.Where(x => x.skt != null).Min(x => x.skt),
                    yakin90 = poz.Where(x => x.kalanGun is >= 0 and <= 90).Sum(x => x.kalan),
                    gecmis = poz.Where(x => x.kalanGun < 0).Sum(x => x.kalan),
                    lotsuz = lotsuzlar.Where(z => z.stokId == g.Key).Sum(z => z.lotsuz),
                    lotlar = g.OrderBy(x => x.skt).Select(x => new { x.lot, x.skt, x.kalan, x.depo }).ToList(),
                };
            }).OrderBy(x => x.enYakin ?? DateTime.MaxValue).ToList();

            var dikkat = new
            {
                eksi = satirlar.Where(x => x.kalan < 0).OrderBy(x => x.kalan).Take(50)
                    .Select(x => new { x.stokId, x.kod, x.ad, x.lot, x.skt, x.kalan, x.depo }).ToList(),
                lotsuz = lotsuzlar.Take(50).ToList(),
                sktsiz = satirlar.Where(x => x.skt == null && x.kalan > 0 && x.izleme is 3 or 4 or 5).Take(50)
                    .Select(x => new { x.stokId, x.kod, x.ad, x.lot, x.kalan, x.depo }).ToList(),
                hiz = satirlar.Where(x => x.oneri == "hiz").OrderByDescending(x => x.tahminiArtan * x.birimMaliyet).Take(50)
                    .Select(x => new { x.stokId, x.kod, x.ad, x.lot, x.skt, x.kalan, x.cikan90, x.tahminiArtan }).ToList(),
            };

            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var depoListesi = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.depo d
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                tarih = r, ufuk = u, ozet, takvim, lotlar = ufuktaki, stoklar, dikkat, kategoriler, depoListesi,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // =========================================================== SAYIM FARK ===
        grup.MapGet("/sayim-fark", async (DateTime? bas, DateTime? bit, int? depo, int? kategori, int? acik,
                                          VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodFark, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            var subeler = Subeler(baglam);
            await using var b = await veri.AcAsync(iptal);
            object?[] p = [baslangic, depo ?? 0, kategori ?? 0, 1, subeler, bitis, acik ?? 0];

            var sayimlar = await b.ListeAsync(Suzgec + """
                select y.id, y.sayim_no, y.sayim_tarihi, y.depo_id, dp.ad, y.kapsam, coalesce(k.ad, ''), y.durum,
                       y.giris_belge_id, coalesce(gb.belge_no, ''), y.cikis_belge_id, coalesce(cb.belge_no, '')
                  from public.stok_sayim y
                  join dp on dp.id = y.depo_id
                  left join public.kategori k on k.id = y.kategori_id
                  left join public.belge gb on gb.id = y.giris_belge_id
                  left join public.belge cb on cb.id = y.cikis_belge_id
                 where y.sube_id = any(@p4::int[])
                   and y.sayim_tarihi >= @p0::date and y.sayim_tarihi < @p5::date + 1
                   and (@p6 = 1 or y.durum = 1)
                 order by y.sayim_tarihi desc
                """, null, p, o => new
                {
                    id = o.GetInt32(0), no = o.GetString(1), tarih = o.GetDateTime(2), depoId = o.GetInt32(3), depo = o.GetString(4),
                    kapsam = Convert.ToInt32(o.GetValue(5)), kategoriAdi = o.GetString(6), durum = Convert.ToInt32(o.GetValue(7)),
                    girisId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8), girisNo = o.GetString(9),
                    cikisId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10), cikisNo = o.GetString(11),
                }, iptal);
            var sayimIdleri = sayimlar.Select(x => x.id).ToArray();

            var satirlar = await b.ListeAsync(Suzgec + """
                select ss.sayim_id, ss.stok_id, st.kod, st.ad, st.kat, st.izleme, ss.seri_lot_id,
                       coalesce(nullif(l.lot_no, ''), nullif(l.seri_no, ''), '') as lot,
                       ss.sistem, ss.sayilan, ss.birim_maliyet, ss.sayan, ss.sayim_zamani
                  from public.stok_sayim_satir ss
                  join st on st.id = ss.stok_id
                  left join public.stok_seri_lot l on l.id = ss.seri_lot_id
                 where ss.sayim_id = any(@p7::int[])
                """, null, [.. p, sayimIdleri], o => new
                {
                    sayimId = o.GetInt32(0), stokId = o.GetInt32(1), kod = o.GetString(2), ad = o.GetString(3), kategori = o.GetString(4),
                    izleme = o.GetInt32(5), seriLotId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6), lot = o.GetString(7),
                    sistem = o.GetDecimal(8), sayilan = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                    birimMaliyet = o.GetDecimal(10), sayan = o.GetInt32(11),
                    zaman = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
                }, iptal);

            var sayilan = satirlar.Where(x => x.sayilan != null).Select(x => new
            {
                x.sayimId, x.stokId, x.kod, x.ad, x.kategori, x.izleme, x.seriLotId, x.lot, x.sistem, sayilan = x.sayilan!.Value,
                x.birimMaliyet, x.sayan, fark = x.sayilan!.Value - x.sistem,
                tutar = Math.Round((x.sayilan!.Value - x.sistem) * x.birimMaliyet, 2),
            }).ToList();
            var farkli = sayilan.Where(x => Math.Abs(x.fark) > 0.00001m).ToList();

            var sayimSatirlari = sayimlar.Select(y =>
            {
                var tum = satirlar.Count(x => x.sayimId == y.id);
                var s = sayilan.Where(x => x.sayimId == y.id).ToList();
                var f = s.Where(x => Math.Abs(x.fark) > 0.00001m).ToList();
                return new
                {
                    y.id, y.no, y.tarih, y.depoId, y.depo,
                    kapsam = y.kapsam == 0 ? "Tüm depo" : y.kapsam == 1 ? $"Kategori: {y.kategoriAdi}" : "Seçili stoklar",
                    y.durum, satir = tum, sayilan = s.Count, farkVar = f.Count,
                    fazla = f.Where(x => x.tutar > 0).Sum(x => x.tutar), eksik = f.Where(x => x.tutar < 0).Sum(x => x.tutar),
                    net = f.Sum(x => x.tutar), y.girisId, y.girisNo, y.cikisId, y.cikisNo,
                    farklar = f.OrderBy(x => x.tutar).Take(20).Select(x => new { x.kod, x.ad, x.lot, x.fark, x.tutar }).ToList(),
                };
            }).ToList();

            // ------------------------------------------------- kalem bazında --
            var kalemler = farkli.GroupBy(x => x.stokId).Select(g =>
            {
                var ilk = g.First();
                var sayimSayisi = sayilan.Where(x => x.stokId == g.Key).Select(x => x.sayimId).Distinct().Count();
                // Sayım başına stok net farkı: lot satırları toplanır.
                var sayimNet = g.GroupBy(x => x.sayimId).Select(s => new { s.Key, net = s.Sum(x => x.fark), tutar = s.Sum(x => x.tutar) }).ToList();
                var eksikSayim = sayimNet.Count(s => s.net < -0.00001m);
                var lotKarisik = sayimNet.Any(s => Math.Abs(s.net) <= 0.00001m);
                var son = sayimlar.Where(y => sayimNet.Any(s => s.Key == y.id)).OrderByDescending(y => y.tarih).First();
                return new
                {
                    ilk.stokId, ilk.kod, ilk.ad, ilk.kategori, ilk.izleme, sayim = sayimSayisi,
                    farkCikan = sayimNet.Count(s => Math.Abs(s.net) > 0.00001m),
                    toplamFark = g.Sum(x => x.fark), net = g.Sum(x => x.tutar),
                    sonTarih = son.tarih, sonFark = sayimNet.First(s => s.Key == son.id).net,
                    durum = eksikSayim >= 2 ? "tekrar" : lotKarisik ? "lot" : "tek",
                };
            }).OrderBy(x => x.net).ToList();

            // ------------------------------------------------------ kırılım --
            var sayanAdlari = await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
                  from public.taraf t where t.id = any(@p0::int[])
                """, null, [sayilan.Select(x => x.sayan).Distinct().ToArray()],
                o => (id: o.GetInt32(0), ad: o.GetString(1)), iptal);
            var kirilim = new
            {
                kategori = sayilan.GroupBy(x => x.kategori).Select(g => new
                {
                    ad = g.Key, sayilan = g.Count(), farkKalem = g.Count(x => Math.Abs(x.fark) > 0.00001m),
                    net = g.Sum(x => x.tutar),
                    dogruluk = g.Any() ? Math.Round(100m * g.Count(x => Math.Abs(x.fark) <= 0.00001m) / g.Count(), 1) : 0,
                }).OrderBy(x => x.net).ToList(),
                depo = sayimSatirlari.GroupBy(x => x.depo).Select(g => new
                {
                    ad = g.Key, sayim = g.Count(), fazla = g.Sum(x => x.fazla), eksik = g.Sum(x => x.eksik), net = g.Sum(x => x.net),
                    son = g.Max(x => x.tarih),
                }).ToList(),
                sayan = sayilan.GroupBy(x => x.sayan).Select(g => new
                {
                    ad = g.Key == 0 ? "(belirsiz)" : sayanAdlari.FirstOrDefault(s => s.id == g.Key).ad ?? $"#{g.Key}",
                    satir = g.Count(), farkCikan = g.Count(x => Math.Abs(x.fark) > 0.00001m),
                }).OrderByDescending(x => x.satir).ToList(),
            };

            // -------------------------------------------------------- dikkat --
            var depolar = await b.ListeAsync(Suzgec + """
                select dp.id, dp.ad, dp.son_sayim_tarihi from dp
                """, null, p, o => new { id = o.GetInt32(0), ad = o.GetString(1),
                                         son = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2) }, iptal);
            var dikkat = new
            {
                tekrar = kalemler.Where(x => x.durum == "tekrar").Take(50)
                    .Select(x => new { x.stokId, x.kod, x.ad, x.farkCikan, x.sayim, x.toplamFark, x.net }).ToList(),
                yuksek = farkli.OrderBy(x => -Math.Abs(x.tutar)).Take(10)
                    .Select(x => new { sayim = sayimlar.First(y => y.id == x.sayimId).no, x.kod, x.ad, x.lot, x.fark, x.tutar }).ToList(),
                lotsuz = farkli.Where(x => x.izleme != 0 && x.seriLotId == null)
                    .Select(x => new { sayim = sayimlar.First(y => y.id == x.sayimId).no, x.kod, x.ad, x.sistem, x.sayilan, x.fark }).ToList(),
                sayilmayan = depolar.Select(d => new
                {
                    d.id, d.ad, son = d.son is { } s && s.Year > 1900 ? s : (DateTime?)null,
                    gun = d.son is { } s2 && s2.Year > 1900 ? (int?)(bugun - s2.Date).TotalDays : null,
                }).Where(d => d.gun is null || d.gun > 180).OrderByDescending(d => d.gun ?? int.MaxValue).ToList(),
            };

            var ozet = new
            {
                sayim = sayimlar.Count, kapanan = sayimlar.Count(x => x.durum == 1), acik = sayimlar.Count(x => x.durum == 0),
                sayilanSatir = sayilan.Count,
                dogruluk = sayilan.Count > 0 ? Math.Round(100m * sayilan.Count(x => Math.Abs(x.fark) <= 0.00001m) / sayilan.Count, 1) : (decimal?)null,
                fazla = farkli.Where(x => x.tutar > 0).Sum(x => x.tutar), fazlaKalem = farkli.Count(x => x.fark > 0),
                eksik = farkli.Where(x => x.tutar < 0).Sum(x => x.tutar), eksikKalem = farkli.Count(x => x.fark < 0),
                net = farkli.Sum(x => x.tutar),
                tekrar = kalemler.Count(x => x.durum == "tekrar"), lotsuzFark = dikkat.lotsuz.Count,
            };

            var depoListesi = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.depo d
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, acikDahil = (acik ?? 0) == 1, ozet, sayimlar = sayimSatirlari, kalemler, kirilim, dikkat,
                depoListesi, kategoriler, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
