using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STOK İCMALLERİ - ikinci üçlü (1174, kullanıcı 25.10.2026 - mockup
/// Ekranlar/Stok/stok_hareket_icmali.html, stok_olu_stok_icmali.html, stok_kritik_stok_icmali.html).
///
/// <para><b>Stok Hareket</b> `/api/stok-icmal/hareket`: dönem başı devir ve dönem sonu kalan
/// Stok Değer İcmali'nin "tarih itibarıyla" bakiyesiyle aynı sorgudan (stok_durum - sonraki
/// hareketler); arası v_stok_hareket'in hareket türüne (iade ve sayım fişi ayrı) göre
/// toplamı. Depolar arası transfer ayrı tutulur (tüm depolarda toplamı sıfırdır).</para>
///
/// <para><b>Ölü Stok / Devir Hızı</b> `/api/stok-icmal/olu`: eşikten (90 / 180 / 365 gün)
/// uzun süre çıkış görmemiş bakiyeli kalemler + eritme önerisi; devir = 12 aylık çıkış /
/// ay sonu bakiyelerinin ortalaması; ABC (çıkış tutarı %80 / %95) × hız; son 6 ay sonunun
/// ölü stok değeri.</para>
///
/// <para><b>Kritik Stok</b> `/api/stok-icmal/kritik`: depo bazında asgari (stok_durum.min_stok,
/// yoksa stok.min_stok) altına düşenler, stokta olmayan ve tedarik süresinden önce bitecek
/// kalemler; hedef ve eşik kuralı fn_kritik_stok_talep (732) ile aynı. Yolda = açık satınalma
/// talebi + açık alış siparişi. Tüketimden min / max önerisi (günlük ortalama × tedarik +
/// %95 emniyet stoku). İki yazan uç: seçilenlerden taslak satınalma talebi ve min / max
/// önerisini uygulama (stok kartının limit yazıcısıyla aynı - loglu).</para>
/// </summary>
public static partial class StokIcmalUclari
{
    private const string KodHareket = "stok.hareket_icmali";
    private const string KodOlu = "stok.olu_stok_icmali";
    private const string KodKritik = "stok.kritik_stok_icmali";

    public sealed record TalepSatiri(int StokId, decimal Miktar);
    public sealed record TalepIstegi(int DepoId, List<TalepSatiri>? Satirlar, string? Aciklama);
    public sealed record LimitSatiri(int StokId, decimal? Min, decimal? Max);
    public sealed record LimitTopluIstegi(int DepoId, List<LimitSatiri>? Satirlar);

    /// <summary>İade satırı mı: tipi 2, ama giriş / çıkış fişi, transfer gibi iadesi olmayan türlerde
    ///   tipi 2 anlam taşımaz (web belgeTuru.ts IADESIZ_TURLER ile aynı küme).</summary>
    private static readonly HashSet<int> IadesizTurler = [9, 18, 19, 20, 105, 3, 4];
    private static bool Iade(int tur, int tipi) => tipi == 2 && !IadesizTurler.Contains(tur);

    private static async Task<object> SecimListeleriAsync(NpgsqlConnection b, int[] subeler, CancellationToken iptal)
    {
        var kategoriler = await b.ListeAsync("""
            select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
              from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
            """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
        var depoListesi = await b.ListeAsync("""
            select d.id, coalesce(d.ad, '') from public.depo d
             where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
            """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
        return new { kategoriler, depoListesi };
    }

    private static void EkUclariEkle(RouteGroupBuilder grup)
    {
        // ============================================================== HAREKET ===
        grup.MapGet("/hareket", async (DateTime? bas, DateTime? bit, int? depo, int? kategori, int? stokId, int? tutar,
                                       VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodHareket, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var bitis = (bit ?? bugun).Date;
            if (bitis > bugun) bitis = bugun;
            var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            var subeler = Subeler(baglam);
            var d0 = depo ?? 0;
            var k0 = kategori ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var devirSatir = await BakiyeAsync(b, baslangic.AddDays(-1), d0, k0, 1, subeler, iptal);
            var kalanSatir = await BakiyeAsync(b, bitis, d0, k0, 1, subeler, iptal);
            object?[] p = [baslangic, d0, k0, 1, subeler, bitis];

            // Dönem hareketleri: stok × depo × tür × iade × sayım fişi toplamı.
            var hareket = await b.ListeAsync(Suzgec + """
                ,
                h as (
                    select h.stok_id, h.depo_id, h.tur, coalesce(bl.tipi, 0) as tipi, h.tarih, h.giren, h.cikan, h.belge_id,
                           exists (select 1 from public.stok_sayim y
                                    where y.giris_belge_id = h.belge_id or y.cikis_belge_id = h.belge_id) as sayim
                      from public.v_stok_hareket h
                      join public.belge bl on bl.id = h.belge_id
                      join dp on dp.id = h.depo_id
                      join st on st.id = h.stok_id
                     where h.tarih >= @p0::date and h.tarih <= @p5::date
                )
                select h.stok_id, st.kod, st.ad, st.kat, st.birim, h.depo_id, dp.ad, h.tur, h.tipi, h.sayim,
                       sum(h.giren), sum(h.cikan), count(*)::int,
                       coalesce((select t.ad from public.kasa_islem_turu t where t.kod = h.tur), 'Tür ' || h.tur)
                  from h
                  join st on st.id = h.stok_id
                  join dp on dp.id = h.depo_id
                 group by h.stok_id, st.kod, st.ad, st.kat, st.birim, h.depo_id, dp.ad, h.tur, h.tipi, h.sayim
                """, null, p, o => new
                {
                    stokId = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), kat = o.GetString(3), birim = o.GetString(4),
                    depoId = o.GetInt32(5), depo = o.GetString(6), tur = o.GetInt32(7), tipi = Convert.ToInt32(o.GetValue(8)),
                    sayim = o.GetBoolean(9), giren = o.GetDecimal(10), cikan = o.GetDecimal(11), adet = o.GetInt32(12),
                    turAd = o.GetString(13),
                }, iptal);

            var tutarMi = (tutar ?? 0) == 1;
            var maliyet = tutarMi
                ? await MaliyetAsync(b, devirSatir.Select(x => x.StokId).Concat(kalanSatir.Select(x => x.StokId))
                                              .Concat(hareket.Select(x => x.stokId)), "ort", iptal)
                : new Dictionary<int, decimal>();
            decimal F(int id) => tutarMi ? (maliyet.TryGetValue(id, out var m) ? m : 0) : 1m;
            decimal Y(decimal v) => Math.Round(v, tutarMi ? 2 : 4);

            // KOLON ANAHTARI: tür (+ "i" iade, "s" sayım fişi). Sayım fişi Giriş/Çıkış Fişi türündedir
            //   ama kayıp-kaçak sorusu için ayrı sütundur.
            static string Anahtar(int tur, int tipi, bool sayim) => sayim ? "sayim" : tur + (Iade(tur, tipi) ? "i" : "");

            // TUTAR KURALI (karar 25.10.2026): GİRİŞ belgenin kendi fiyatıyla (alış faturası / irsaliyesi /
            //   fişi, gelen konsinye, üretim girişi, giriş fişi ve sayım fazlası - satır tutarı, TL, KDV hariç),
            //   ÇIKIŞ ve iade / transfer ortalama maliyetle; devir ve kalan stok değeri (ortalama maliyet).
            //   Fiyatı olmayan giriş satırı ortalama maliyete düşer. Aradaki fark "değerleme farkı"dır.
            var belgeTutari = tutarMi
                ? (await b.ListeAsync(Suzgec + """
                    ,
                    g as (
                        select bs.stok_id,
                               coalesce(bs.giris_depo_id, bl.giris_depo_id, bs.cikis_depo_id, bl.cikis_depo_id) as depo_id,
                               bl.tur, coalesce(bl.tipi, 0) as tipi, coalesce(bs.tutar, 0) as tutar,
                               exists (select 1 from public.stok_sayim y
                                        where y.giris_belge_id = bl.id or y.cikis_belge_id = bl.id) as sayim
                          from public.belge_satir bs
                          join public.belge bl on bl.id = bs.belge_id
                          join public.kasa_islem_turu k on k.kod = bl.tur and k.stok_etkiler = 1
                         where bs.tur = 1 and bs.stok_id is not null and bs.stok_durum_degis = 1 and bl.durum = 0
                           and bl.tur <> 20 and not public.fn_belge_cikis_mi(bl.tur, bl.tipi)
                           and bl.belge_tarihi::date >= @p0::date and bl.belge_tarihi::date <= @p5::date
                    )
                    select g.stok_id, g.depo_id, g.tur, g.tipi, g.sayim, sum(g.tutar)
                      from g join dp on dp.id = g.depo_id join st on st.id = g.stok_id
                     group by 1, 2, 3, 4, 5
                    """, null, p, o => (stok: o.GetInt32(0), depo: o.GetInt32(1), tur: o.GetInt32(2),
                        tipi: Convert.ToInt32(o.GetValue(3)), sayim: o.GetBoolean(4), tutar: o.GetDecimal(5)), iptal))
                  .ToDictionary(x => (x.stok, x.depo, x.tur, x.tipi, x.sayim), x => x.tutar)
                : new Dictionary<(int, int, int, int, bool), decimal>();
            static bool BelgeFiyatli(int tur, int tipi, bool sayim)
                => sayim || (!Iade(tur, tipi) && tur is 3 or 10 or 11 or 12 or 109 or 122);
            var hv = hareket.Select(x =>
            {
                var gv = x.giren;
                var cv = x.cikan;
                if (tutarMi)
                {
                    var ort = F(x.stokId);
                    gv = x.tur != 20 && BelgeFiyatli(x.tur, x.tipi, x.sayim)
                         && belgeTutari.TryGetValue((x.stokId, x.depoId, x.tur, x.tipi, x.sayim), out var bt) && bt > 0
                        ? bt : x.giren * ort;
                    cv = x.cikan * ort;
                }
                return new { x.stokId, x.kod, x.ad, x.kat, x.birim, x.depoId, x.depo, x.tur, x.tipi, x.sayim,
                             x.giren, x.cikan, x.adet, x.turAd, gv, cv };
            }).ToList();
            // Dönem tablosu için birim değer (stok × tür): dönem toplamları stok tablosuyla aynı çıksın.
            var birimDeger = hv.GroupBy(x => (x.stokId, x.tur, x.tipi, x.sayim)).ToDictionary(g => g.Key, g => (
                giris: g.Sum(x => x.giren) is var gm and > 0 ? g.Sum(x => x.gv) / gm : F(g.Key.stokId),
                cikis: g.Sum(x => x.cikan) is var cm and > 0 ? g.Sum(x => x.cv) / cm : F(g.Key.stokId)));
            var kolonlar = hareket.Where(x => x.tur != 20)
                .SelectMany(x => new[]
                {
                    x.giren > 0 ? (yon: "giris", anahtar: Anahtar(x.tur, x.tipi, x.sayim), x.tur, ad: x.sayim ? "Sayım fazlası" : Iade(x.tur, x.tipi) ? x.turAd + " (iade)" : x.turAd) : default,
                    x.cikan > 0 ? (yon: "cikis", anahtar: Anahtar(x.tur, x.tipi, x.sayim), x.tur, ad: x.sayim ? "Sayım eksiği" : Iade(x.tur, x.tipi) ? x.turAd + " (iade)" : x.turAd) : default,
                })
                .Where(x => x.yon is not null)
                .Distinct()
                .OrderBy(x => x.yon == "giris" ? 0 : 1).ThenBy(x => x.anahtar == "sayim" ? 1 : 0).ThenBy(x => x.tur).ThenBy(x => x.anahtar)
                .Select(x => new { x.yon, x.anahtar, x.ad })
                .ToList();

            var idler = devirSatir.Select(x => x.StokId).Concat(kalanSatir.Select(x => x.StokId)).Concat(hareket.Select(x => x.stokId)).Distinct();
            var bilgi = devirSatir.Concat(kalanSatir).GroupBy(x => x.StokId).ToDictionary(g => g.Key, g => g.First());
            var hBilgi = hareket.GroupBy(x => x.stokId).ToDictionary(g => g.Key, g => g.First());

            var stoklar = idler.Select(id =>
            {
                var h = hv.Where(x => x.stokId == id && x.tur != 20).ToList();
                var tr = hv.Where(x => x.stokId == id && x.tur == 20).ToList();
                var f = F(id);
                var giris = kolonlar.Where(k => k.yon == "giris").ToDictionary(k => k.anahtar,
                    k => Y(h.Where(x => Anahtar(x.tur, x.tipi, x.sayim) == k.anahtar).Sum(x => x.gv)));
                var cikis = kolonlar.Where(k => k.yon == "cikis").ToDictionary(k => k.anahtar,
                    k => Y(h.Where(x => Anahtar(x.tur, x.tipi, x.sayim) == k.anahtar).Sum(x => x.cv)));
                var depoIdleri = devirSatir.Where(x => x.StokId == id).Select(x => x.DepoId)
                    .Concat(kalanSatir.Where(x => x.StokId == id).Select(x => x.DepoId))
                    .Concat(hareket.Where(x => x.stokId == id).Select(x => x.depoId)).Distinct();
                var depolar = depoIdleri.Select(dId => new
                {
                    depoId = dId,
                    depo = kalanSatir.Concat(devirSatir).FirstOrDefault(x => x.DepoId == dId)?.Depo
                           ?? hareket.First(x => x.depoId == dId).depo,
                    devir = Y(devirSatir.Where(x => x.StokId == id && x.DepoId == dId).Sum(x => x.Miktar) * f),
                    giris = Y(h.Where(x => x.depoId == dId).Sum(x => x.gv)),
                    cikis = Y(h.Where(x => x.depoId == dId).Sum(x => x.cv)),
                    transfer = Y(tr.Where(x => x.depoId == dId).Sum(x => x.gv - x.cv)),
                    kalan = Y(kalanSatir.Where(x => x.StokId == id && x.DepoId == dId).Sum(x => x.Miktar) * f),
                }).OrderBy(x => x.depo).ToList();
                var (kod, ad, kat, birim) = bilgi.TryGetValue(id, out var bi) ? (bi.Kod, bi.Ad, bi.Kategori, bi.Birim)
                    : (hBilgi[id].kod, hBilgi[id].ad, hBilgi[id].kat, hBilgi[id].birim);
                var devir = Y(devirSatir.Where(x => x.StokId == id).Sum(x => x.Miktar) * f);
                return new
                {
                    id, kod, ad, kategori = kat, birim, devir, giris, cikis,
                    girisToplam = giris.Values.Sum(), cikisToplam = cikis.Values.Sum(),
                    transferGiren = Y(tr.Sum(x => x.gv)), transferCikan = Y(tr.Sum(x => x.cv)),
                    kalan = Y(kalanSatir.Where(x => x.StokId == id).Sum(x => x.Miktar) * f),
                    hareket = h.Sum(x => x.adet) + tr.Sum(x => x.adet),
                    eksiyeDustu = devir >= 0 && kalanSatir.Where(x => x.StokId == id).Sum(x => x.Miktar) < 0,
                    depolar,
                };
            }).Where(x => x.hareket > 0 || stokId is > 0 && x.id == stokId).OrderByDescending(x => x.cikisToplam).ThenBy(x => x.ad).ToList();

            // Tüm bakiyeli stoklar devir / kalan toplamında (hareket görmeyenler dahil) - Stok Değer İcmali ile aynı.
            var devirToplam = Y(devirSatir.Sum(x => x.Miktar * F(x.StokId)));
            var kalanToplam = Y(kalanSatir.Sum(x => x.Miktar * F(x.StokId)));
            var sayimNet = Y(hv.Where(x => x.sayim).Sum(x => x.gv - x.cv));
            var girisToplam = Y(hv.Where(x => x.tur != 20).Sum(x => x.gv));
            var cikisToplam = Y(hv.Where(x => x.tur != 20).Sum(x => x.cv));
            var transferNet = Y(hv.Where(x => x.tur == 20).Sum(x => x.gv - x.cv));
            var ozet = new
            {
                devir = devirToplam, kalan = kalanToplam,
                giris = girisToplam, cikis = cikisToplam,
                transfer = Y(hv.Where(x => x.tur == 20).Sum(x => x.cv)),
                sayimNet, sayimFazla = Y(hv.Where(x => x.sayim).Sum(x => x.gv)),
                sayimEksik = Y(hv.Where(x => x.sayim).Sum(x => x.cv)),
                // DEĞERLEME FARKI (yalnız tutarda): kalan − (devir + giriş − çıkış ± transfer). Girişler belge
                //   fiyatıyla, devir / kalan ortalama maliyetle olduğu için sıfır olmaz; miktarda 0'dır.
                degerlemeFarki = Y(kalanToplam - (devirToplam + girisToplam - cikisToplam + transferNet)),
                kalem = stoklar.Count(x => x.hareket > 0),
                bakiyeliKalem = kalanSatir.Select(x => x.StokId).Distinct().Count(),
                belge = await b.TekDegerAsync<int>(Suzgec + """
                    select count(distinct h.belge_id)::int from public.v_stok_hareket h
                      join dp on dp.id = h.depo_id join st on st.id = h.stok_id
                     where h.tarih >= @p0::date and h.tarih <= @p5::date
                    """, null, p, iptal),
                eksiyeDusen = stoklar.Count(x => x.eksiyeDustu),
                gun = (int)(bitis - baslangic).TotalDays + 1,
            };

            // ------------------------------------------- tür × dönem (hafta / ay) --
            var aylik = (bitis - baslangic).TotalDays > 62;
            var donemler = await b.ListeAsync(Suzgec + $"""
                ,
                h as (
                    select h.tur, coalesce(bl.tipi, 0) as tipi, h.giren, h.cikan, h.belge_id, h.stok_id,
                           date_trunc('{(aylik ? "month" : "week")}', h.tarih)::date as donem,
                           exists (select 1 from public.stok_sayim y
                                    where y.giris_belge_id = h.belge_id or y.cikis_belge_id = h.belge_id) as sayim
                      from public.v_stok_hareket h
                      join public.belge bl on bl.id = h.belge_id
                      join dp on dp.id = h.depo_id
                      join st on st.id = h.stok_id
                     where h.tarih >= @p0::date and h.tarih <= @p5::date
                )
                select donem, tur, tipi, sayim, stok_id, sum(giren), sum(cikan), count(distinct belge_id)::int
                  from h group by 1, 2, 3, 4, 5
                """, null, p, o => new
                {
                    donem = o.GetDateTime(0), tur = o.GetInt32(1), tipi = Convert.ToInt32(o.GetValue(2)), sayim = o.GetBoolean(3),
                    stokId = o.GetInt32(4), giren = o.GetDecimal(5), cikan = o.GetDecimal(6), belge = o.GetInt32(7),
                }, iptal);
            var donemListesi = donemler.Select(x => x.donem).Distinct().OrderBy(x => x).ToList();
            decimal DonemDeger(int stok, int tur, int tipi, bool sayim, bool giris, decimal miktar)
                => !tutarMi ? miktar
                 : birimDeger.TryGetValue((stok, tur, tipi, sayim), out var bd) ? miktar * (giris ? bd.giris : bd.cikis)
                 : miktar * F(stok);
            var turDonem = kolonlar.Select(k => new
            {
                k.yon, k.anahtar, k.ad,
                hucreler = donemListesi.Select(dn => Y(donemler.Where(x => x.donem == dn && x.tur != 20 && Anahtar(x.tur, x.tipi, x.sayim) == k.anahtar)
                    .Sum(x => DonemDeger(x.stokId, x.tur, x.tipi, x.sayim, k.yon == "giris", k.yon == "giris" ? x.giren : x.cikan)))).ToList(),
                toplam = Y(donemler.Where(x => x.tur != 20 && Anahtar(x.tur, x.tipi, x.sayim) == k.anahtar)
                    .Sum(x => DonemDeger(x.stokId, x.tur, x.tipi, x.sayim, k.yon == "giris", k.yon == "giris" ? x.giren : x.cikan))),
                belge = donemler.Where(x => x.tur != 20 && Anahtar(x.tur, x.tipi, x.sayim) == k.anahtar && (k.yon == "giris" ? x.giren : x.cikan) > 0).Sum(x => x.belge),
            }).ToList();
            var transferDonem = donemListesi.Select(dn => Y(donemler.Where(x => x.donem == dn && x.tur == 20).Sum(x => x.cikan * F(x.stokId)))).ToList();

            // ------------------------------------------------------ depo akışı --
            var depoAkis = kalanSatir.Select(x => (x.DepoId, x.Depo)).Concat(devirSatir.Select(x => (x.DepoId, x.Depo)))
                .Concat(hareket.Select(x => (DepoId: x.depoId, Depo: x.depo))).Distinct()
                .Select(dp => new
                {
                    depoId = dp.DepoId, depo = dp.Depo,
                    devir = Y(devirSatir.Where(x => x.DepoId == dp.DepoId).Sum(x => x.Miktar * F(x.StokId))),
                    giris = Y(hv.Where(x => x.depoId == dp.DepoId && x.tur != 20).Sum(x => x.gv)),
                    cikis = Y(hv.Where(x => x.depoId == dp.DepoId && x.tur != 20).Sum(x => x.cv)),
                    transfer = Y(hv.Where(x => x.depoId == dp.DepoId && x.tur == 20).Sum(x => x.gv - x.cv)),
                    kalan = Y(kalanSatir.Where(x => x.DepoId == dp.DepoId).Sum(x => x.Miktar * F(x.StokId))),
                }).OrderBy(x => x.depo).ToList();

            var transferler = await b.ListeAsync(Suzgec + """
                select coalesce(bs.cikis_depo_id, bl.cikis_depo_id), coalesce(cd.ad, ''),
                       coalesce(bs.giris_depo_id, bl.giris_depo_id), coalesce(gd.ad, ''),
                       bs.stok_id, sum(case when coalesce(bs.miktar, 0) <> 0 then bs.miktar else coalesce(bs.adet, 0) end),
                       count(distinct bl.id)::int
                  from public.belge_satir bs
                  join public.belge bl on bl.id = bs.belge_id
                  join st on st.id = bs.stok_id
                  left join public.depo cd on cd.id = coalesce(bs.cikis_depo_id, bl.cikis_depo_id)
                  left join public.depo gd on gd.id = coalesce(bs.giris_depo_id, bl.giris_depo_id)
                 where bl.tur = 20 and bl.durum = 0 and bs.tur = 1 and bs.stok_durum_degis = 1
                   and bl.belge_tarihi::date >= @p0::date and bl.belge_tarihi::date <= @p5::date
                   and (coalesce(bs.cikis_depo_id, bl.cikis_depo_id) in (select id from dp)
                        or coalesce(bs.giris_depo_id, bl.giris_depo_id) in (select id from dp))
                 group by 1, 2, 3, 4, 5
                """, null, p, o => new
                {
                    cikisId = o.IsDBNull(0) ? 0 : o.GetInt32(0), cikis = o.GetString(1),
                    girisId = o.IsDBNull(2) ? 0 : o.GetInt32(2), giris = o.GetString(3),
                    stokId = o.GetInt32(4), miktar = o.GetDecimal(5), fis = o.GetInt32(6),
                }, iptal);
            var transferMatrisi = transferler.GroupBy(x => (x.cikisId, x.cikis, x.girisId, x.giris)).Select(g => new
            {
                g.Key.cikisId, g.Key.cikis, g.Key.girisId, g.Key.giris,
                miktar = Y(g.Sum(x => x.miktar * F(x.stokId))), fis = g.Sum(x => x.fis),
            }).OrderByDescending(x => x.miktar).ToList();

            // ----------------------------------------------------------- ekstre --
            object? ekstre = null;
            if (stokId is > 0)
            {
                var sid = stokId.Value;
                var satirlar = await b.ListeAsync(Suzgec + """
                    select h.tarih, h.belge_id, h.tur, coalesce(bl.tipi, 0),
                           coalesce((select t.ad from public.kasa_islem_turu t where t.kod = h.tur), 'Tür ' || h.tur),
                           coalesce(bl.belge_no, ''), coalesce(public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::varchar(160), ''),
                           coalesce(bl.aciklama, ''), dp.ad, h.giren, h.cikan,
                           coalesce((select string_agg(distinct coalesce(nullif(l.lot_no, ''), nullif(l.seri_no, ''), '?')
                                             || coalesce(' · ' || to_char(l.son_kullanma_tarihi, 'MM.YYYY'), ''), ', ')
                                       from public.stok_izleme i join public.stok_seri_lot l on l.id = i.seri_lot_id
                                      where i.belge_id = h.belge_id and i.stok_id = h.stok_id), '')
                      from public.v_stok_hareket h
                      join dp on dp.id = h.depo_id
                      join public.belge bl on bl.id = h.belge_id
                      left join public.taraf tr on tr.id = bl.taraf_id
                     where h.stok_id = @p6 and h.tarih >= @p0::date and h.tarih <= @p5::date
                     order by h.tarih, h.belge_id, h.cikan
                     limit 3000
                    """, null, [.. p, sid], o => new
                    {
                        tarih = o.GetDateTime(0), belgeId = o.GetInt32(1), tur = o.GetInt32(2), tipi = Convert.ToInt32(o.GetValue(3)),
                        turAd = o.GetString(4), belgeNo = o.GetString(5), cari = o.GetString(6), aciklama = o.GetString(7),
                        depo = o.GetString(8), giren = o.GetDecimal(9), cikan = o.GetDecimal(10), lot = o.GetString(11),
                    }, iptal);
                var st0 = await b.TekAsync("""
                    select s.id, coalesce(s.kod, ''), coalesce(s.ad, '') from public.stok s where s.id = @p0
                    """, null, [sid], o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2) }, iptal);
                var bakiye = devirSatir.Where(x => x.StokId == sid).Sum(x => x.Miktar);
                var devir0 = bakiye;
                var hareketler = satirlar.Select(x =>
                {
                    bakiye += x.giren - x.cikan;
                    return new
                    {
                        x.tarih, x.belgeId, x.tur, belge = Iade(x.tur, x.tipi) ? x.turAd + " (iade)" : x.turAd,
                        x.belgeNo, x.cari, x.aciklama, x.depo, x.giren, x.cikan, bakiye, x.lot,
                    };
                }).ToList();
                ekstre = new
                {
                    stok = st0, devir = devir0, hareketler,
                    giren = satirlar.Sum(x => x.giren), cikan = satirlar.Sum(x => x.cikan), kalan = bakiye,
                    sinirli = satirlar.Count >= 3000,
                };
            }

            var secim = await SecimListeleriAsync(b, subeler, iptal);
            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, birim = tutarMi ? "tutar" : "miktar", depo = d0, ozet, kolonlar, stoklar,
                donemTuru = aylik ? "ay" : "hafta", donemler = donemListesi, turDonem, transferDonem,
                depoAkis, transferMatrisi, ekstre, secim, izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================================= ÖLÜ ===
        grup.MapGet("/olu", async (DateTime? tarih, int? esik, string? hareket, int? depo, int? kategori,
                                   VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodOlu, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var t = (tarih ?? bugun).Date;
            if (t > bugun) t = bugun;
            var e = esik is 90 or 180 or 365 ? esik.Value : 180;
            var herHareket = hareket == "her";
            var subeler = Subeler(baglam);
            var d0 = depo ?? 0;
            var k0 = kategori ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var satirlar = await BakiyeAsync(b, t, d0, k0, 0, subeler, iptal);
            var maliyet = await MaliyetAsync(b, satirlar.Select(x => x.StokId), "ort", iptal);
            decimal M(int id) => maliyet.TryGetValue(id, out var m) ? m : 0;
            object?[] p = [t, d0, k0, 0, subeler, e];

            // AY SONU NETLERİ (son 13 ay): ay sonu bakiyesi = bugünkü bakiye - o ay sonundan sonraki hareketler.
            var aylikNet = await b.ListeAsync(Suzgec + """
                select h.stok_id, date_trunc('month', h.tarih)::date, sum(h.giren - h.cikan)
                  from public.v_stok_hareket h
                  join dp on dp.id = h.depo_id join st on st.id = h.stok_id
                 where h.tarih > (@p0::date - interval '13 months') and h.tarih <= @p0::date
                 group by 1, 2
                """, null, p, o => (stok: o.GetInt32(0), ay: o.GetDateTime(1), net: o.GetDecimal(2)), iptal);
            var ayBas = new DateTime(t.Year, t.Month, 1);
            var aySonlari = Enumerable.Range(1, 12).Select(i => ayBas.AddMonths(-i + 1).AddDays(-1)).ToList();   // son 12 ay sonu (yeniden eskiye)
            var bugunBakiye = satirlar.GroupBy(x => x.StokId).ToDictionary(g => g.Key, g => g.Sum(x => x.Miktar));
            decimal AySonuBakiye(int stok, DateTime me)
                => (bugunBakiye.TryGetValue(stok, out var bb) ? bb : 0) - aylikNet.Where(x => x.stok == stok && x.ay > me).Sum(x => x.net);

            // AY SONU İTİBARIYLA SON HAREKET (trend: son 6 ay sonu + bugün).
            var trendNoktalari = aySonlari.Take(6).Reverse().Append(t).ToList();
            var sonHareket = await b.ListeAsync(Suzgec + """
                select h.stok_id, m.me::date, max(h.tarih) filter (where h.cikan > 0 and h.tur <> 20),
                       max(h.tarih) filter (where h.giren > 0)
                  from unnest(@p6::date[]) as m(me)
                  join public.v_stok_hareket h on h.tarih <= m.me
                  join dp on dp.id = h.depo_id join st on st.id = h.stok_id
                 group by 1, 2
                """, null, [.. p, trendNoktalari.ToArray()], o => (stok: o.GetInt32(0), me: o.GetDateTime(1),
                    cikis: o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2), giris: o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3)), iptal);

            DateTime? Referans(DateTime? sonGiris, DateTime? sonCikis)
                => herHareket ? (sonCikis > sonGiris ? sonCikis : sonGiris ?? sonCikis) : sonCikis ?? sonGiris;
            bool OluMu(DateTime an, DateTime? sonGiris, DateTime? sonCikis)
                => Referans(sonGiris, sonCikis) is not { } r || (an - r.Date).TotalDays > e;

            // En yakın SKT (bugünkü lot defteri) ve son 90 günde başka depoda çıkış (transfer önerisi).
            var skt = await b.ListeAsync(Suzgec + """
                select ld.stok_id, min(l.son_kullanma_tarihi)
                  from public.stok_lot_durum ld
                  join dp on dp.id = ld.depo_id join st on st.id = ld.stok_id
                  join public.stok_seri_lot l on l.id = ld.seri_lot_id
                 where ld.kalan > 0 and l.son_kullanma_tarihi is not null
                 group by 1
                """, null, p, o => (stok: o.GetInt32(0), skt: o.GetDateTime(1)), iptal);
            var sktS = skt.ToDictionary(x => x.stok, x => x.skt);
            var c90 = await b.ListeAsync("""
                select h.stok_id, h.depo_id, coalesce(d.ad, ''), sum(h.cikan)
                  from public.v_stok_hareket h
                  join public.depo d on d.id = h.depo_id
                 where h.tarih > @p0::date - 90 and h.tarih <= @p0::date and h.tur <> 20 and h.cikan > 0
                   and (d.sube_id is null or d.sube_id = any(@p1::int[]))
                 group by 1, 2, 3
                """, null, [t, subeler], o => (stok: o.GetInt32(0), depo: o.GetInt32(1), ad: o.GetString(2), cikan: o.GetDecimal(3)), iptal);

            var stoklar = satirlar.GroupBy(x => x.StokId).Select(g =>
            {
                var ilk = g.First();
                var miktar = g.Sum(x => x.Miktar);
                var bm = M(g.Key);
                var r = Referans(ilk.SonGiris, ilk.SonCikis);
                int? gun = r is { } rr ? (int)(t - rr.Date).TotalDays : null;
                var bakiyeler = aySonlari.Take(11).Select(me => Math.Max(0, AySonuBakiye(g.Key, me))).Append(Math.Max(0, miktar)).ToList();
                var ortalama = bakiyeler.Average();
                var devir = ortalama > 0.00001m ? Math.Round(ilk.Cikan12 / ortalama, 2) : 0m;
                var olu = miktar > 0 && OluMu(t, ilk.SonGiris, ilk.SonCikis);
                return new
                {
                    id = g.Key, ilk.Kod, ilk.Ad, kategori = ilk.Kategori, ilk.Birim, ilk.Izleme,
                    miktar, birimMaliyet = bm, tutar = Math.Round(miktar * bm, 2),
                    sonGiris = ilk.SonGiris, sonCikis = ilk.SonCikis, gun, hicCikmadi = ilk.SonCikis is null,
                    enYakinSkt = sktS.TryGetValue(g.Key, out var s) ? s : (DateTime?)null,
                    cikan12 = ilk.Cikan12, cikanTutar12 = Math.Round(ilk.Cikan12 * bm, 2),
                    ortalamaStok = Math.Round(ortalama, 2), devir, devirGun = devir > 0 ? (int?)Math.Round(365 / devir) : null,
                    olu, yavas = miktar > 0 && !olu && gun is { } gg && gg > e / 2,
                    depolar = g.Select(x => new { depoId = x.DepoId, depo = x.Depo, miktar = x.Miktar }).ToList(),
                };
            }).Where(x => x.miktar > 0).ToList();

            // ABC: 12 aylık çıkış tutarına göre (A ilk %80, B %95'e kadar, C kalan; çıkışı olmayan C).
            var toplamCikis = stoklar.Sum(x => x.cikanTutar12);
            var abc = new Dictionary<int, string>();
            decimal birikim = 0;
            foreach (var x in stoklar.OrderByDescending(x => x.cikanTutar12))
            {
                var once = toplamCikis > 0 ? birikim / toplamCikis : 1;
                abc[x.id] = x.cikanTutar12 <= 0 ? "C" : once < 0.80m ? "A" : once < 0.95m ? "B" : "C";
                birikim += x.cikanTutar12;
            }
            string Sinif(dynamic x) => x.olu ? "olu" : x.devir >= 6m ? "hizli" : x.devir >= 2m ? "normal" : "yavas";

            // ÖNERİ (mockup sırası): SKT eşikten önce → iade/imha · başka depoda çıkıyor → transfer ·
            //   son alış 12 aydan yeni → tedarikçiye iade · maliyetsiz → sayımla doğrula · kalan → kampanya.
            var oluler = stoklar.Where(x => x.olu).OrderByDescending(x => x.tutar).ToList();
            var sonAlis = await TaslakTalep.SonAlisAsync(b, null, oluler.Select(x => x.id), iptal);
            var oluListesi = oluler.Select(x =>
            {
                var tutulanDepolar = x.depolar.Select(dd => dd.depoId).ToHashSet();
                var baska = c90.Where(c => c.stok == x.id && !tutulanDepolar.Contains(c.depo)).OrderByDescending(c => c.cikan).FirstOrDefault();
                sonAlis.TryGetValue(x.id, out var sa);
                var (oneri, oneriNot) =
                    x.enYakinSkt is { } sk && (sk.Date - t).TotalDays <= e ? ("skt", $"SKT {sk:MM.yyyy} - eşikten önce doluyor")
                    : baska.stok != 0 ? ("transfer", $"{baska.ad}: son 90 gün {baska.cikan:0.##} çıkış")
                    : sa.Tedarikci is { Length: > 0 } && (t - sa.Tarih.Date).TotalDays <= 365 ? ("iade", $"{sa.Tedarikci} · {sa.Tarih:dd.MM.yyyy}")
                    : x.birimMaliyet == 0 ? ("sayim", "maliyet yok - sayımla doğrulayın")
                    : ("kampanya", x.hicCikmadi ? "girişten beri hiç çıkmadı" : "");
                return new
                {
                    x.id, x.Kod, x.Ad, x.kategori, x.Birim, x.miktar, x.birimMaliyet, x.tutar, x.sonGiris, x.sonCikis, x.gun,
                    x.hicCikmadi, x.enYakinSkt, x.depolar, oneri, oneriNot, abc = abc[x.id],
                    tedarikci = sa.Tedarikci ?? "", sonAlisTarihi = sa.Tedarikci is null ? (DateTime?)null : sa.Tarih,
                    transferDepoId = oneri == "transfer" ? baska.depo : (int?)null,
                };
            }).ToList();

            var devirListesi = stoklar.OrderByDescending(x => x.tutar).Select(x => new
            {
                x.id, x.Kod, x.Ad, x.kategori, x.miktar, x.tutar, x.ortalamaStok, x.cikan12, x.devir, x.devirGun,
                sinif = Sinif(x), abc = abc[x.id],
            }).ToList();

            string[] siniflar = ["hizli", "normal", "yavas", "olu"];
            var matris = new[] { "A", "B", "C" }.Select(a => new
            {
                abc = a,
                hucreler = siniflar.Select(sn =>
                {
                    var l = stoklar.Where(x => abc[x.id] == a && Sinif(x) == sn).ToList();
                    return new { sinif = sn, kalem = l.Count, tutar = l.Sum(x => x.tutar) };
                }).ToList(),
            }).ToList();
            var pareto = new[] { "A", "B", "C" }.Select(a =>
            {
                var l = stoklar.Where(x => abc[x.id] == a).ToList();
                return new
                {
                    abc = a, kalem = l.Count,
                    kalemOran = stoklar.Count > 0 ? Math.Round(100m * l.Count / stoklar.Count, 1) : 0,
                    cikisOran = toplamCikis > 0 ? Math.Round(100m * l.Sum(x => x.cikanTutar12) / toplamCikis, 1) : 0,
                };
            }).ToList();

            // ------------------------------------------------------- trend --
            HashSet<int> OluKumesi(DateTime me) => sonHareket.Where(x => x.me.Date == me.Date).Select(x => x.stok)
                .Concat(bugunBakiye.Keys).Distinct()
                .Where(id =>
                {
                    var bak = me.Date == t ? (bugunBakiye.TryGetValue(id, out var bb) ? bb : 0) : AySonuBakiye(id, me);
                    if (bak <= 0) return false;
                    var sh = sonHareket.FirstOrDefault(x => x.stok == id && x.me.Date == me.Date);
                    return OluMu(me, sh.giris, sh.cikis);
                }).ToHashSet();
            var trend = trendNoktalari.Select(me =>
            {
                var kume = OluKumesi(me);
                decimal Bak(int id) => me.Date == t ? (bugunBakiye.TryGetValue(id, out var bb) ? bb : 0) : AySonuBakiye(id, me);
                var deger = Math.Round(bugunBakiye.Keys.Union(aylikNet.Select(x => x.stok)).Sum(id => Math.Max(0, Bak(id)) * M(id)), 2);
                var olu = Math.Round(kume.Sum(id => Bak(id) * M(id)), 2);
                return new { tarih = me, olu, kalem = kume.Count, deger, oran = deger > 0 ? Math.Round(100 * olu / deger, 1) : 0 };
            }).ToList();
            var onceki = OluKumesi(trendNoktalari[^2]);
            var simdi = stoklar.Where(x => x.olu).Select(x => x.id).ToHashSet();

            var deger = stoklar.Sum(x => x.tutar);
            var oluDeger = oluler.Sum(x => x.tutar);
            var cikanToplamMaliyet = stoklar.Sum(x => x.cikanTutar12);
            var ortalamaDeger = stoklar.Sum(x => x.ortalamaStok * x.birimMaliyet);
            var genelDevir = ortalamaDeger > 0 ? Math.Round(cikanToplamMaliyet / ortalamaDeger, 1) : 0m;
            var ozet = new
            {
                deger, oluDeger, oluKalem = oluler.Count, oluOran = deger > 0 ? Math.Round(100 * oluDeger / deger, 1) : 0,
                devir = genelDevir, devirGun = genelDevir > 0 ? (int?)Math.Round(365 / genelDevir) : null,
                hicCikmayan = oluler.Count(x => x.hicCikmadi), hicCikmayanDeger = oluler.Where(x => x.hicCikmadi).Sum(x => x.tutar),
                yavasKalem = stoklar.Count(x => x.yavas), yavasDeger = stoklar.Where(x => x.yavas).Sum(x => x.tutar),
                oluSktYakin = oluler.Count(x => x.enYakinSkt is { } s && (s.Date - t).TotalDays <= e),
                oluSktYakinDeger = oluler.Where(x => x.enYakinSkt is { } s && (s.Date - t).TotalDays <= e).Sum(x => x.tutar),
                aKalem = stoklar.Count(x => abc[x.id] == "A"), kalem = stoklar.Count,
                buDonemDusen = simdi.Count(id => !onceki.Contains(id)), buDonemCikan = onceki.Count(id => !simdi.Contains(id)),
                oncekiOran = trend.Count > 1 ? trend[^2].oran : 0,
            };

            var secim = await SecimListeleriAsync(b, subeler, iptal);
            return Results.Ok(new
            {
                tarih = t, esik = e, hareket = herHareket ? "her" : "cikis", depo = d0, ozet, oluler = oluListesi,
                devir = devirListesi, matris, pareto, trend, secim, izlemeNo = baglam.IzlemeNo,
            });
        });

        // ============================================================== KRİTİK ===
        grup.MapGet("/kritik", async (int? depo, int? kategori, int? gun, int? tedarik, int? tip,
                                      VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodKritik, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var g0 = gun is 30 or 60 or 90 or 180 ? gun.Value : 90;
            var td = tedarik is >= 1 and <= 120 ? tedarik.Value : 7;
            var subeler = Subeler(baglam);
            var d0 = depo ?? 0;
            var k0 = kategori ?? 0;
            await using var b = await veri.AcAsync(iptal);
            // STOK TİPİ SÜZGECİ (karar 25.10.2026): ticari mal / hammadde / demo… - -1 = tipi tanımsız.
            object?[] p = [bugun, d0, k0, 0, subeler, g0, tip ?? 0];

            var kat = await b.TekDegerAsync<decimal?>("""
                select nullif(regexp_replace(deger, '[^0-9.]', '', 'g'), '')::numeric
                  from public.referans where anahtar = 'satinalma.kritik_hedef_kat'
                """, null, [], iptal) ?? 2m;
            kat = Math.Max(kat, 1);
            var otomatik = await b.TekDegerAsync<string>(
                "select coalesce(nullif(btrim(deger), ''), '0') from public.referans where anahtar = 'satinalma.kritik_stok_aktif'",
                null, [], iptal) == "1";

            // STOK × DEPO: eldeki (kalan - rezerve), eşik ve hedef (732 kuralı), yolda (açık talep + açık sipariş),
            //   son N gün çıkışı ve günlük çıkışların kare toplamı (dalgalanma için). Transfer çıkışı da
            //   deponun tüketimidir.
            var satirlar = await b.ListeAsync(Suzgec + """
                ,
                gunluk as (
                    select h.stok_id, h.depo_id, h.tarih, sum(h.cikan) as c
                      from public.v_stok_hareket h join dp on dp.id = h.depo_id join st on st.id = h.stok_id
                     where h.tarih > @p0::date - @p5 and h.tarih <= @p0::date and h.cikan > 0
                     group by 1, 2, 3
                ),
                tk as (
                    select stok_id, depo_id, sum(c) as c, sum(c * c) as c2 from gunluk group by 1, 2
                ),
                talep as (
                    select ts.stok_id, t.sube_id, sum(ts.miktar) as m, string_agg(distinct coalesce(t.talep_no, '#' || t.id) || ' · ' ||
                           case t.durum when 0 then 'taslak' when 1 then 'onayda' when 2 then 'onaylandı' else 'teklifte' end, ', ') as ad
                      from public.satinalma_talep_satir ts join public.satinalma_talep t on t.id = ts.talep_id
                     where t.durum in (0, 1, 2, 4) and ts.stok_id is not null and ts.belge_satir_id is null
                     group by 1, 2
                ),
                siparis as (
                    select bs.stok_id, coalesce(bs.giris_depo_id, bl.giris_depo_id) as depo_id, bl.sube_id,
                           sum(case when coalesce(bs.miktar, 0) <> 0 then bs.miktar else coalesce(bs.adet, 0) end) as m,
                           string_agg(distinct coalesce(nullif(bl.belge_no, ''), '#' || bl.id), ', ') as ad
                      from public.belge_satir bs
                      join public.belge bl on bl.id = bs.belge_id
                      join public.belge_satinalma bsa on bsa.id = bl.id
                     where bl.tur = 9 and coalesce(bsa.takip_durum, 0) in (0, 1) and bs.stok_id is not null
                     group by 1, 2, 3
                ),
                -- SKT'Sİ 30 GÜN İÇİNDE DOLAN (ya da geçmiş) LOT (karar 25.10.2026): satılamayacak mal
                --   eldekinden düşülür ve ayrı sütunda görünür.
                skt as (
                    select ld.stok_id, ld.depo_id, sum(ld.kalan) as m
                      from public.stok_lot_durum ld
                      join public.stok_seri_lot l on l.id = ld.seri_lot_id
                     where ld.kalan > 0 and l.son_kullanma_tarihi is not null
                       and l.son_kullanma_tarihi::date <= @p0::date + 30
                     group by 1, 2
                )
                select sd.stok_id, st.kod, st.ad, st.kat, st.birim, sd.depo_id, dp.ad,
                       sd.kalan - coalesce(sd.rezerve, 0) as eldeki,
                       coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0)) as esik,
                       nullif(sd.max_stok, 0) as azami, sd.min_stok as dmin, sd.max_stok as dmax,
                       coalesce(tk.c, 0), coalesce(tk.c2, 0),
                       coalesce(ta.m, 0) + coalesce(si.m, 0) as yolda,
                       coalesce(ta.ad, ''), coalesce(si.ad, ''), coalesce(d.sube_id, 0), coalesce(skt.m, 0)
                  from public.stok_durum sd
                  join st on st.id = sd.stok_id
                  join dp on dp.id = sd.depo_id
                  join public.stok s on s.id = sd.stok_id
                  join public.depo d on d.id = sd.depo_id
                  left join tk on tk.stok_id = sd.stok_id and tk.depo_id = sd.depo_id
                  left join talep ta on ta.stok_id = sd.stok_id and ta.sube_id = coalesce(d.sube_id, 0)
                  left join siparis si on si.stok_id = sd.stok_id
                                      and (si.depo_id = sd.depo_id or (si.depo_id is null and si.sube_id = d.sube_id))
                  left join skt on skt.stok_id = sd.stok_id and skt.depo_id = sd.depo_id
                 where @p6 = 0 or (@p6 = -1 and coalesce(s.tipi, 0) not in
                                     (select kd.deger from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                                       where kl.kod = 'stok.tipi'))
                       or coalesce(s.tipi, 0) = @p6
                """, null, p, o => new
                {
                    stokId = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), kategori = o.GetString(3), birim = o.GetString(4),
                    depoId = o.GetInt32(5), depo = o.GetString(6), eldeki = o.GetDecimal(7),
                    esik = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8), azami = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                    dmin = o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10), dmax = o.IsDBNull(11) ? (decimal?)null : o.GetDecimal(11),
                    cikan = o.GetDecimal(12), cikan2 = o.GetDecimal(13), yolda = o.GetDecimal(14),
                    talep = o.GetString(15), siparis = o.GetString(16), subeId = o.GetInt32(17),
                    sktYakinHam = o.GetDecimal(18),
                }, iptal);

            var maliyet = await MaliyetAsync(b, satirlar.Select(x => x.stokId), "ort", iptal);
            var hesap = satirlar.Select(ham =>
            {
                // SKT yakın lot eldekinden düşülür (eldekinden fazlası düşülmez).
                var sktYakin = Math.Min(ham.sktYakinHam, Math.Max(0, ham.eldeki));
                var x = ham with { eldeki = ham.eldeki - sktYakin };
                var gunluk = x.cikan / g0;
                // DALGALANMA: günlük çıkışın standart sapması (çıkışsız günler 0 sayılır).
                var varyans = Math.Max(0, (double)(x.cikan2 / g0) - (double)(gunluk * gunluk));
                var sigma = (decimal)Math.Sqrt(varyans);
                var oneriMin = gunluk > 0 ? Math.Ceiling(gunluk * td + 1.65m * sigma * (decimal)Math.Sqrt(td)) : 0;
                var oneriMax = gunluk > 0 ? Math.Ceiling(oneriMin + 30 * gunluk) : 0;
                var hedef = x.azami ?? (x.esik is { } es ? es * kat : (decimal?)null);
                decimal? yeter = gunluk > 0 ? Math.Round((x.eldeki + x.yolda) / gunluk, 1) : null;
                var kritik = x.esik is > 0 && x.eldeki <= x.esik;
                var yok = x.eldeki <= 0 && x.cikan > 0;
                var tukeniyor = yeter is { } y && y <= td;
                // SİPARİŞ: hedefe tamamlar (732); eşik tanımsızsa önerilen max hedeftir.
                var hedefSiparis = hedef ?? (oneriMax > 0 ? oneriMax : (decimal?)null);
                var siparis = hedefSiparis is { } hs ? Math.Ceiling(Math.Max(0, hs - x.eldeki - x.yolda)) : 0;
                return new
                {
                    x.stokId, x.kod, x.ad, x.kategori, x.birim, x.depoId, x.depo, x.subeId, x.eldeki, min = x.esik, max = x.azami,
                    x.dmin, x.dmax, hedef, x.yolda, x.talep, x.siparis, cikan = x.cikan, gunluk = Math.Round(gunluk, 2),
                    sigma = Math.Round(sigma, 2), yeter, kritik, yok, tukeniyor, oneriMin, oneriMax, siparisMiktar = siparis, sktYakin,
                    birimMaliyet = maliyet.TryGetValue(x.stokId, out var m) ? m : 0,
                };
            }).ToList();

            var liste = hesap.Where(x => x.kritik || x.yok || x.tukeniyor).ToList();
            var sonAlis = await TaslakTalep.SonAlisAsync(b, null, liste.Select(x => x.stokId)
                .Concat(hesap.Where(x => x.max is > 0 && x.eldeki > x.max).Select(x => x.stokId)), iptal);

            // ABC (depo içinde, son N gün çıkış tutarına göre) - öneri sekmesi ve "A sınıfı min'siz" uyarısı.
            var abc = new Dictionary<(int, int), string>();
            foreach (var dg in hesap.GroupBy(x => x.depoId))
            {
                var top = dg.Sum(x => x.cikan * x.birimMaliyet);
                decimal bir = 0;
                foreach (var x in dg.OrderByDescending(x => x.cikan * x.birimMaliyet))
                {
                    var once = top > 0 ? bir / top : 1;
                    var t0 = x.cikan * x.birimMaliyet;
                    abc[(x.stokId, x.depoId)] = t0 <= 0 ? "C" : once < 0.80m ? "A" : once < 0.95m ? "B" : "C";
                    bir += t0;
                }
            }

            // DİĞER DEPODA VAR: aynı stok başka depoda kendi eşiğinin üstünde.
            var tumDepolar = await b.ListeAsync("""
                select sd.stok_id, sd.depo_id, coalesce(d.ad, ''),
                       sd.kalan - coalesce(sd.rezerve, 0) - coalesce(nullif(sd.min_stok, 0), nullif(s.min_stok, 0), 0)
                  from public.stok_durum sd
                  join public.depo d on d.id = sd.depo_id
                  join public.stok s on s.id = sd.stok_id
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[]))
                   and sd.stok_id = any(@p1::int[])
                """, null, [subeler, liste.Select(x => x.stokId).Distinct().ToArray()],
                o => (stok: o.GetInt32(0), depo: o.GetInt32(1), ad: o.GetString(2), fazla: o.GetDecimal(3)), iptal);

            var kritikler = liste.Select(x =>
            {
                sonAlis.TryGetValue(x.stokId, out var sa);
                var baska = tumDepolar.Where(z => z.stok == x.stokId && z.depo != x.depoId && z.fazla > 0)
                                      .OrderByDescending(z => z.fazla).FirstOrDefault();
                var fiyat = sa.Tedarikci is null ? x.birimMaliyet : sa.Fiyat;
                return new
                {
                    x.stokId, x.kod, x.ad, x.kategori, x.birim, x.depoId, x.depo, x.eldeki, x.yolda, x.min, x.max, x.gunluk, x.yeter,
                    x.kritik, x.yok, x.tukeniyor, x.sktYakin, siparis = x.siparisMiktar, fiyat, tutar = Math.Round(x.siparisMiktar * fiyat, 2),
                    tedarikci = sa.Tedarikci ?? "", sonAlisTarihi = sa.Tedarikci is null ? (DateTime?)null : sa.Tarih,
                    x.talep, siparisNo = x.siparis, minTanimsiz = x.min is null,
                    baskaDepo = baska.stok != 0 ? baska.ad : "", baskaDepoId = baska.stok != 0 ? baska.depo : (int?)null,
                    baskaFazla = baska.stok != 0 ? baska.fazla : 0,
                };
            }).OrderBy(x => x.yeter ?? (x.eldeki <= 0 ? -1 : 9999)).ThenBy(x => x.ad).ToList();

            // TÜKENME TAKVİMİ: bugün / 7 / 14 / 30 gün içinde biten (günlük çıkışı olan) kalemler.
            (string ad, Func<decimal, bool> f)[] dilimler =
            [
                ("Bugün (stok yok)", y => y <= 0), ("1 – 7 gün", y => y > 0 && y <= 7),
                ("8 – 14 gün", y => y > 7 && y <= 14), ("15 – 30 gün", y => y > 14 && y <= 30),
            ];
            var takvim = dilimler.Select(dl =>
            {
                var l = hesap.Where(x => x.gunluk > 0 && x.yeter is { } y && dl.f(y)).OrderBy(x => x.yeter).ToList();
                return new
                {
                    dl.ad, kalem = l.Count, tedarikIcinde = l.Count(x => x.yeter <= td),
                    ornekler = l.Take(8).Select(x => new { x.kod, x.ad, x.depo, x.yeter, x.yolda }).ToList(),
                };
            }).ToList();

            var oneriler = hesap.Where(x => x.cikan > 0).OrderBy(x => abc[(x.stokId, x.depoId)]).ThenByDescending(x => x.cikan * x.birimMaliyet)
                .Select(x => new
                {
                    x.stokId, x.kod, x.ad, x.depoId, x.depo, abc = abc[(x.stokId, x.depoId)], x.gunluk, x.sigma, tedarik = td,
                    min = x.dmin, max = x.dmax, kartMin = x.min, x.oneriMin, x.oneriMax, x.eldeki,
                }).ToList();
            var cikissiz = hesap.Count(x => x.cikan <= 0);

            var maxUstu = hesap.Where(x => x.max is > 0 && x.eldeki > x.max).Select(x =>
            {
                var fazla = x.eldeki - x.max!.Value;
                var kritikBaska = liste.FirstOrDefault(z => z.stokId == x.stokId && z.depoId != x.depoId);
                return new
                {
                    x.stokId, x.kod, x.ad, x.depoId, x.depo, x.eldeki, x.max, fazla, tutar = Math.Round(fazla * x.birimMaliyet, 2),
                    fazlaGun = x.gunluk > 0 ? (int?)Math.Round(fazla / x.gunluk) : null,
                    oneri = kritikBaska is not null ? "transfer" : "durdur", oneriDepo = kritikBaska?.depo ?? "",
                    acikTalep = x.talep.Length > 0 || x.siparis.Length > 0,
                };
            }).OrderByDescending(x => x.tutar).ToList();

            var ozet = new
            {
                kritik = liste.Count(x => x.kritik), yok = liste.Count(x => x.yok), tukeniyor = liste.Count(x => x.tukeniyor),
                yolda = liste.Count(x => x.yolda > 0), siparisTutar = kritikler.Sum(x => x.tutar), siparisKalem = kritikler.Count(x => x.siparis > 0),
                minTanimsiz = hesap.Count(x => x.min is null), satir = hesap.Count,
                minTanimsizA = hesap.Count(x => x.min is null && abc[(x.stokId, x.depoId)] == "A"),
                maxUstu = maxUstu.Count, maxUstuTutar = maxUstu.Sum(x => x.tutar),
                baskaDepoda = kritikler.Count(x => x.baskaDepoId is not null),
                otomatikTalep = otomatik, hedefKat = kat, cikissiz,
                sktYakinKalem = hesap.Count(x => x.sktYakin > 0), sktYakinMiktar = hesap.Sum(x => x.sktYakin),
            };
            var tipler = await b.ListeAsync("""
                select kd.deger, kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                 where kl.kod = 'stok.tipi' and kd.dil = 0 order by kd.deger
                """, null, [], o => new { id = Convert.ToInt32(o.GetValue(0)), ad = o.GetString(1) }, iptal);

            var secim = await SecimListeleriAsync(b, subeler, iptal);
            return Results.Ok(new
            {
                depo = d0, gun = g0, tedarik = td, tip = tip ?? 0, tipler, ozet, kritikler, takvim, oneriler, maxUstu, secim, izlemeNo = baglam.IzlemeNo,
                yetkiler = new
                {
                    talep = baglam.Yetkiler.Var("satinalma.talep", Islem.Ekle),
                    limit = baglam.Yetkiler.Var("stok", Islem.Degistir),
                },
            });
        });

        // ---------------------------------------------- seçilenlerden talep --
        // TASLAK satınalma talebi (durum 0): onaya insan gönderir - fn_kritik_stok_talep ile aynı
        //   kaynak (2 kritik stok, kaynak_tur 918 depo). Açık talebi olan kalem ATLANIR (aynı malı iki kez istememek).
        grup.MapPost("/kritik/talep", async (TalepIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                             HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodKritik, Islem.Gor);
            baglam.YetkiIste("satinalma.talep", Islem.Ekle);
            var satirlar = TaslakTalep.Suz(istek.Satirlar, x => x.StokId, x => x.Miktar);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var (subeId, depoAd) = await TaslakTalep.DepoAsync(b, islem, baglam, istek.DepoId, iptal);
            var departman = await b.TekDegerAsync<int?>(
                "select nullif(regexp_replace(deger, '\\D', '', 'g'), '')::integer from public.referans where anahtar = 'satinalma.kritik_departman'",
                islem, [], iptal);
            var sonuc = await TaslakTalep.AcAsync(b, islem, log, baglam, subeId, depoAd, istek.DepoId,
                satirlar.Select(x => new TaslakTalep.Kalem(x.StokId, x.Miktar)).ToList(),
                new TaslakTalep.Tanim(Kaynak: 2, KaynakTur: 918, KaynakId: istek.DepoId, DepartmanId: departman,
                    GerekceOnEki: "Kritik stok", Icmal: "Kritik Stok İcmali", MiktarNotu: "miktar: hedef seviye - eldeki - yolda",
                    NotEki: "", LogKaynak: "stok-kritik-icmali"),
                istek.Aciklama, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id = sonuc.Id, talepNo = sonuc.TalepNo, kalem = sonuc.Kalem, atlanan = sonuc.Atlananlar.Count,
                atlananlar = sonuc.Atlananlar, izlemeNo = baglam.IzlemeNo,
            });
        });

        // ------------------------------------------ min / max önerisini uygula --
        // Stok kartının "Stok Durumu" sekmesindeki limit yazıcısının AYNISI (loglu, depo bazında);
        //   kart genelindeki stok.min_stok'a dokunulmaz.
        grup.MapPost("/kritik/limit", async (LimitTopluIstegi istek, BaglamCozucu cozucu, StokDurumDeposu depoYazici,
                                             VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodKritik, Islem.Gor);
            baglam.YetkiIste("stok", Islem.Degistir);
            var satirlar = (istek.Satirlar ?? []).Where(x => x.StokId > 0).ToList();
            if (satirlar.Count == 0) throw GentegreHatasi.Dogrulama("Uygulanacak satır seçilmedi.");
            if (satirlar.Count > 1000) throw GentegreHatasi.Dogrulama("Tek seferde en çok 1000 satır.");
            await using (var b = await veri.AcAsync(iptal))
            {
                var depoSube = await b.TekAsync("select d.sube_id from public.depo d where d.id = @p0", null, [istek.DepoId],
                    o => new { sube = o.IsDBNull(0) ? (int?)null : o.GetInt32(0) }, iptal);
                if (depoSube is null || depoSube.sube is { } ds && !baglam.Subeler.Any(s => s.Id == ds))
                    throw GentegreHatasi.Bulunamadi("Depo bulunamadı.");
            }
            foreach (var x in satirlar)
                await depoYazici.LimitYazAsync(x.StokId, istek.DepoId, x.Min, x.Max, baglam.Yazma, iptal);
            return Results.Ok(new { yazilan = satirlar.Count, izlemeNo = baglam.IzlemeNo });
        });
    }
}
