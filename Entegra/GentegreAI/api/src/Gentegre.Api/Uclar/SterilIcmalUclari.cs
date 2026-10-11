using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STERİLİZASYON İCMALİ (mockup Ekranlar/İcmal/sterilizasyon_icmali.html,
/// kullanıcı 11.10.2026: "sterilizasyon icmalini kodla").
///
/// <para><b>Döngü</b> (steril_dongu, başlama dönemde): durum 4 serbest · 5 karantina ·
/// 6 başarısız · 7 iptal · 8 test. Sterilizasyon döngüsü = otoklav (cihaz türü 1),
/// yıkama döngüsü = yıkayıcı-dezenfektör / ultrasonik (2, 3). Doluluk = döngüye
/// bağlı paket / (yük kapasitesi × test dışı döngü); yük kapasitesi cihaz kartında
/// (1032) - girilmemiş cihazda doluluk hesaplanmaz.</para>
///
/// <para><b>Paket:</b> üretilen = paketleme dönemde; kullanılan = kullanım okutması
/// dönemde (bölüm = kullanım kaydındaki ünite metni); süresi dolan = SKT dönemde
/// geçen ve "süresi doldu" (6) ya da hâlâ "steril" (3) duran (işlenmemiş!).
/// Set ömrü = birimin döngü sayısı ↔ üretici eşiği, yoksa setin eşiği; %90 üstü uyarı.</para>
///
/// <para>Hasta bilgisi yok: geri çağırmada yalnız sayılar (hasta listesi kayıtta).</para>
/// </summary>
public static class SterilIcmalUclari
{
    /// <summary>Ekran kodu (1032) - haklarını steril.pano'dan kopyalar.</summary>
    private const string Kod = "steril.icmal";

    private static readonly Dictionary<short, string> CihazTurleri = new()
    {
        [1] = "Buharlı otoklav", [2] = "Yıkayıcı-dezenfektör", [3] = "Ultrasonik yıkayıcı", [4] = "Kapatma makinesi",
        [5] = "İnkübatör", [6] = "Etiket yazıcı", [7] = "Yağlama cihazı",
    };
    private static readonly Dictionary<short, string> IndikatorTurleri = new()
    {
        [1] = "Bowie-Dick", [2] = "Helix / PCD", [3] = "Sınıf 4 (paket içi)", [4] = "Sınıf 5 entegratör", [5] = "Sınıf 6 emülatör",
        [6] = "Biyolojik", [7] = "Vakum (sızdırmazlık)",
    };
    private static readonly Dictionary<short, string> PaketTurleri = new()
    {
        [1] = "Kağıt-plastik", [2] = "Kağıt-plastik çift kat", [3] = "Tekstil çift kat", [4] = "Konteyner", [5] = "Paketsiz",
    };

    private sealed record Dongu(int Id, int CihazId, int SayacNo, string Program, DateTime Baslama, DateTime? Bitis, short Durum, string HataKodu, string Not);

    public static void SterilIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/steril-icmal").WithTags("Sterilizasyon İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? cihaz, int? set,
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

            var cihazlarTanim = await b.ListeAsync("""
                select c.id, coalesce(c.ad, ''), coalesce(c.tur, 0)::smallint, coalesce(c.marka_model, ''), c.yuk_kapasite,
                       c.son_validasyon, c.son_bakim, coalesce(c.durum, 1)::smallint
                  from public.steril_cihaz c
                 where (@p0 = 0 or coalesce(c.sube_id, 0) in (0, @p0)) and c.tur in (1, 2, 3)
                 order by c.tur, c.ad
                """, null, [sube], o => (id: o.GetInt32(0), ad: o.GetString(1), tur: o.GetInt16(2), model: o.GetString(3),
                    kapasite: o.IsDBNull(4) ? (int?)null : o.GetInt16(4), validasyon: o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                    bakim: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), durum: o.GetInt16(7)), iptal);

            var donguler = await b.ListeAsync("""
                select d.id, d.cihaz_id, coalesce(d.sayac_no, 0), coalesce(p.ad, 'Program belirsiz'), d.baslama, d.bitis,
                       coalesce(d.durum, 0)::smallint, coalesce(d.hata_kodu, ''), coalesce(nullif(d.karar_notu, ''), d.bd_onay_notu, '')
                  from public.steril_dongu d
                  left join public.steril_program p on p.id = d.program_id
                 where d.baslama >= @p0 and d.baslama < @p1 and (@p2 = 0 or coalesce(d.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => new Dongu(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3),
                    o.GetDateTime(4), o.IsDBNull(5) ? null : o.GetDateTime(5), o.GetInt16(6), o.GetString(7), o.GetString(8)), iptal);
            if (cihaz is > 0) donguler = donguler.Where(d => d.CihazId == cihaz).ToList();

            // Paketler: dönemde üretilen + dönemde kullanılan + SKT'si dönemde geçen + şu an karantinada.
            var paketler = await b.ListeAsync("""
                select p.id, coalesce(p.barkod, ''), coalesce(p.dongu_id, 0), coalesce(b.set_id, 0), coalesce(s.ad, coalesce(b.ad, 'Set dışı')),
                       coalesce(s.implant, 0) = 1, p.paketleme_zamani, p.skt, coalesce(p.raf, ''), coalesce(p.durum, 0)::smallint,
                       coalesce(p.paket_tur, s.paket_tur, 0)::smallint
                  from public.steril_paket p
                  left join public.steril_birim b on b.id = p.birim_id
                  left join public.steril_set s on s.id = b.set_id
                 where (@p2 = 0 or coalesce(p.sube_id, 0) in (0, @p2))
                   and ((p.paketleme_zamani >= @p0 and p.paketleme_zamani < @p1)
                        or (p.skt >= @p0::date and p.skt < @p1::date)
                        or p.durum = 2
                        or exists (select 1 from public.steril_paket_kullanim k where k.paket_id = p.id and k.zaman >= @p0 and k.zaman < @p1))
                """, null, [baslangic, bitis, sube], o => (id: o.GetInt32(0), barkod: o.GetString(1), dongu: o.GetInt32(2), set: o.GetInt32(3),
                    setAd: o.GetString(4), implant: o.GetBoolean(5), paketleme: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                    skt: o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7), raf: o.GetString(8), durum: o.GetInt16(9), tur: o.GetInt16(10)), iptal);
            var kullanimlar = await b.ListeAsync("""
                select k.paket_id, coalesce(nullif(trim(k.unite), ''), 'Bölüm belirtilmemiş'), k.zaman, coalesce(k.belge_id, 0), coalesce(k.taraf_id, 0)
                  from public.steril_paket_kullanim k
                 where k.zaman >= @p0 and k.zaman < @p1 and (@p2 = 0 or coalesce(k.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis, sube], o => (paket: o.GetInt32(0), bolum: o.GetString(1), zaman: o.GetDateTime(2),
                    belge: o.GetInt32(3), taraf: o.GetInt32(4)), iptal);
            var indikatorler = await b.ListeAsync("""
                select i.dongu_id, coalesce(i.tur, 0)::smallint, coalesce(i.sonuc, 0)::smallint, coalesce(i.lot, ''), coalesce(i.notu, ''),
                       i.okuma_zamani, i.inkubasyon_bitis
                  from public.steril_dongu_indikator i where i.dongu_id = any(@p0)
                """, null, [donguler.Select(d => d.Id).ToArray()], o => (dongu: o.GetInt32(0), tur: o.GetInt16(1), sonuc: o.GetInt16(2),
                    lot: o.GetString(3), not: o.GetString(4), okuma: o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                    inkubasyon: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6)), iptal);
            var setler = await b.ListeAsync("""
                select s.id, coalesce(s.kod, ''), coalesce(s.ad, ''), coalesce(s.paket_tur, 0)::smallint, coalesce(s.dongu_esigi, 0),
                       coalesce(s.min_stok, 0), coalesce(s.implant, 0) = 1,
                       (select count(*) from public.steril_birim b where b.set_id = s.id and coalesce(b.aktif, 1) = 1)::int,
                       (select round(avg(b.dongu_sayisi))::int from public.steril_birim b where b.set_id = s.id and coalesce(b.aktif, 1) = 1),
                       (select count(*) from public.steril_birim b where b.set_id = s.id and coalesce(b.aktif, 1) = 1
                           and coalesce(nullif(b.uretici_esigi, 0), s.dongu_esigi, 0) > 0
                           and b.dongu_sayisi >= 0.9 * coalesce(nullif(b.uretici_esigi, 0), s.dongu_esigi))::int,
                       (select count(*) from public.steril_paket p join public.steril_birim b on b.id = p.birim_id
                         where b.set_id = s.id and p.durum = 3)::int
                  from public.steril_set s where coalesce(s.aktif, 1) = 1 order by s.ad
                """, null, [], o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), tur: o.GetInt16(3), esik: o.GetInt32(4),
                    minStok: o.GetInt32(5), implant: o.GetBoolean(6), birim: o.GetInt32(7), omur: o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                    esigeYakin: o.GetInt32(9), depoda: o.GetInt32(10)), iptal);
            var geriCagirmalar = await b.ListeAsync("""
                select g.id, coalesce(c.ad, ''), coalesce(td.sayac_no, g.tetik_dongu_id, 0), g.ekleme_tarihi,
                       coalesce(g.etkilenen_dongu, 0), coalesce(g.etkilenen_paket, 0), coalesce(g.kullanilan_paket, 0),
                       coalesce(g.hasta_sayisi, 0), coalesce(g.durum, 1)::smallint, g.kapanis, coalesce(g.aciklama, '')
                  from public.steril_geri_cagirma g
                  left join public.steril_cihaz c on c.id = g.cihaz_id
                  left join public.steril_dongu td on td.id = g.tetik_dongu_id
                 where ((g.ekleme_tarihi >= @p0 and g.ekleme_tarihi < @p1) or g.durum = 1)
                   and (@p2 = 0 or coalesce(g.sube_id, 0) in (0, @p2))
                 order by g.ekleme_tarihi
                """, null, [baslangic, bitis, sube], o => new
            {
                id = o.GetInt32(0), cihaz = o.GetString(1), tetikDongu = o.GetInt32(2), tarih = o.GetDateTime(3), dongu = o.GetInt32(4),
                paket = o.GetInt32(5), kullanilan = o.GetInt32(6), hasta = o.GetInt32(7), acik = o.GetInt16(8) == 1,
                kapanis = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9), aciklama = o.GetString(10),
            }, iptal);

            bool Donemde(DateTime? t) => t is { } x && x >= baslangic && x < bitis;
            var uretilen = paketler.Where(p => Donemde(p.paketleme) && (set is not > 0 || p.set == set)).ToList();
            var kumeKullanim = kullanimlar.Where(k => set is not > 0 || paketler.Any(p => p.id == k.paket && p.set == set)).ToList();
            var paketDongu = uretilen.GroupBy(p => p.dongu).ToDictionary(g => g.Key, g => g.Count());

            // ------------------------------------------------------------ cihazlar --
            static int? Ort(IEnumerable<int> v) { var l = v.ToList(); return l.Count > 0 ? (int)Math.Round(l.Average()) : null; }
            var cihazlar = cihazlarTanim.Where(c => cihaz is not > 0 || c.id == cihaz).Select(c =>
            {
                var d = donguler.Where(x => x.CihazId == c.id).ToList();
                var yuk = d.Where(x => x.Durum != 8).ToList();
                var yuklenen = yuk.Sum(x => paketDongu.GetValueOrDefault(x.Id));
                var kapasite = c.kapasite is > 0 ? c.kapasite.Value * yuk.Count : (int?)null;
                var validasyonGecikti = c.tur == 1 && (c.validasyon is null || c.validasyon.Value.AddYears(1) < bugun);
                return new
                {
                    c.id, c.ad, tur = CihazTurleri.GetValueOrDefault(c.tur, ""), sterilizasyon = c.tur == 1, model = c.model,
                    dongu = yuk.Count, serbest = d.Count(x => x.Durum == 4), karantina = d.Count(x => x.Durum == 5),
                    basarisiz = d.Count(x => x.Durum is 6 or 7), test = d.Count(x => x.Durum == 8),
                    yuklenen, kapasite, yukKapasite = c.kapasite,
                    doluluk = kapasite is > 0 ? Math.Round(100m * yuklenen / kapasite.Value, 1) : (decimal?)null,
                    ortSureDk = Ort(d.Where(x => x.Bitis != null).Select(x => (int)Math.Round((x.Bitis!.Value - x.Baslama).TotalMinutes))),
                    validasyon = c.validasyon, validasyonGecikti, sonBakim = c.bakim,
                    programlar = d.GroupBy(x => x.Program).Select(g => new { ad = g.Key, adet = g.Count() }).OrderByDescending(x => x.adet).ToList(),
                };
            }).ToList();

            // -------------------------------------------------------------- setler --
            var setListe = setler.Where(s => set is not > 0 || s.id == set).Select(s =>
            {
                var ur = uretilen.Count(p => p.set == s.id);
                var kul = kumeKullanim.Count(k => paketler.Any(p => p.id == k.paket && p.set == s.id));
                return new
                {
                    s.id, s.kod, s.ad, s.implant, paketTur = PaketTurleri.GetValueOrDefault(s.tur, ""), s.birim, uretilen = ur,
                    birimBasi = s.birim > 0 ? Math.Round((decimal)ur / s.birim, 1) : 0m, kullanilan = kul, omur = s.omur, esik = s.esik,
                    s.esigeYakin, s.depoda, s.minStok, stokAz = s.minStok > 0 && s.depoda < s.minStok,
                };
            }).ToList();

            // --------------------------------------------------------- indikatörler --
            var indOzet = indikatorler.GroupBy(i => i.tur).Select(g => new
            {
                tur = IndikatorTurleri.GetValueOrDefault(g.Key, "Diğer"), okuma = g.Count(), gecti = g.Count(i => i.sonuc == 1),
                kaldi = g.Count(i => i.sonuc == 2), bekliyor = g.Count(i => i.sonuc is 0 or 3),
                basari = g.Count(i => i.sonuc is 1 or 2) > 0 ? Math.Round(100m * g.Count(i => i.sonuc == 1) / g.Count(i => i.sonuc is 1 or 2), 1) : (decimal?)null,
            }).OrderBy(x => x.tur).ToList();
            var dongMap = donguler.ToDictionary(d => d.Id);
            var cihazAd = cihazlarTanim.ToDictionary(c => c.id, c => c.ad);
            var basarisizInd = indikatorler.Where(i => i.sonuc == 2).Select(i =>
            {
                dongMap.TryGetValue(i.dongu, out var d);
                return new
                {
                    tarih = i.okuma ?? d?.Baslama, cihaz = d != null ? cihazAd.GetValueOrDefault(d.CihazId, "") : "", dongu = d?.SayacNo ?? i.dongu,
                    tur = IndikatorTurleri.GetValueOrDefault(i.tur, "Diğer"), i.lot,
                    aksiyon = string.Join(" · ", new[] { d?.HataKodu ?? "", d?.Not ?? "", i.not }.Where(x => !string.IsNullOrWhiteSpace(x))),
                };
            }).OrderBy(x => x.tarih).ToList();

            // ----------------------------------------- karantina / süresi dolan --
            var karantina = paketler.Where(p => p.durum == 2 && (set is not > 0 || p.set == set)).GroupBy(p => (p.dongu, p.setAd)).Select(g =>
            {
                dongMap.TryGetValue(g.Key.dongu, out var d);
                var bi = indikatorler.Where(i => i.dongu == g.Key.dongu && i.tur == 6).Select(i => i.inkubasyon).Max();
                return new { dongu = d?.SayacNo ?? g.Key.dongu, cihaz = d != null ? cihazAd.GetValueOrDefault(d.CihazId, "") : "", set = g.Key.setAd, paket = g.Count(), biBitis = bi };
            }).ToList();
            var suresiDolan = paketler.Where(p => p.skt is { } k && k >= baslangic && k < bitis && p.durum is 3 or 6 && (set is not > 0 || p.set == set))
                .OrderBy(p => p.skt).Select(p => new
                {
                    p.barkod, set = p.setAd, p.raf, skt = p.skt,
                    durum = p.durum == 6 ? "yeniden işlendi" : p.skt < bugun ? "süresi geçti · depoda (işlenmeli)" : "dolacak",
                    islenmedi = p.durum == 3 && p.skt < bugun,
                }).ToList();

            // -------------------------------------------------------------- bölümler --
            var bolumler = kumeKullanim.GroupBy(k => k.bolum).Select(g =>
            {
                var pk = g.Select(k => paketler.FirstOrDefault(p => p.id == k.paket)).Where(p => p.id > 0).ToList();
                var bekleme = g.Select(k => paketler.FirstOrDefault(p => p.id == k.paket)).Where(p => p.paketleme != null)
                    .Zip(g.Where(k => paketler.Any(p => p.id == k.paket && p.paketleme != null)), (p, k) => (k.zaman - p.paketleme!.Value).TotalDays).ToList();
                return new
                {
                    bolum = g.Key, paket = g.Count(), setCesidi = pk.Select(p => p.set).Distinct().Count(), implant = pk.Count(p => p.implant),
                    hasta = g.Select(k => k.belge > 0 ? $"b{k.belge}" : k.taraf > 0 ? $"t{k.taraf}" : null).Where(x => x != null).Distinct().Count(),
                    ortBeklemeGun = bekleme.Count > 0 ? Math.Round((decimal)bekleme.Average(), 1) : (decimal?)null,
                    setler = pk.GroupBy(p => p.setAd).Select(x => new { ad = x.Key, adet = x.Count() }).OrderByDescending(x => x.adet).ToList(),
                };
            }).OrderByDescending(x => x.paket).ToList();

            var steriller = cihazlar.Where(c => c.sterilizasyon).ToList();
            var kapT = cihazlar.Where(c => c.kapasite is > 0).Sum(c => c.kapasite!.Value);
            var yukT = cihazlar.Where(c => c.kapasite is > 0).Sum(c => c.yuklenen);
            var ozet = new
            {
                sterilDongu = steriller.Sum(c => c.dongu), serbest = steriller.Sum(c => c.serbest), test = cihazlar.Sum(c => c.test),
                yikamaDongu = cihazlar.Where(c => !c.sterilizasyon).Sum(c => c.dongu),
                doluluk = kapT > 0 ? Math.Round(100m * yukT / kapT, 1) : (decimal?)null, yuklenen = yukT, kapasite = kapT,
                kapasitesiz = cihazlar.Count(c => c.yukKapasite is not > 0 && c.dongu > 0),
                uretilen = uretilen.Count, setTuru = uretilen.Select(p => p.set).Distinct().Count(),
                birim = setler.Sum(s => s.birim), kullanilan = kumeKullanim.Count, bolum = bolumler.Count,
                depoda = setler.Sum(s => s.depoda),
                indikatorOkuma = indikatorler.Count, indikatorBasarisiz = indikatorler.Count(i => i.sonuc == 2),
                karantina = karantina.Sum(k => k.paket),
                geriCagrilanPaket = geriCagirmalar.Sum(g => g.paket), geriKullanilmis = geriCagirmalar.Sum(g => g.kullanilan),
                acikGeriCagirma = geriCagirmalar.Count(g => g.acik),
                suresiDolan = suresiDolan.Count(p => p.durum != "dolacak"), islenmemis = suresiDolan.Count(p => p.islenmedi),
                esigeYakin = setler.Sum(s => s.esigeYakin),
                validasyonGeciken = cihazlar.Where(c => c.validasyonGecikti).Select(c => c.ad).ToList(),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, cihazlar, setler = setListe, indikatorOzet = indOzet,
                basarisizIndikatorler = basarisizInd, geriCagirmalar, karantina, suresiDolan, bolumler,
                cihazAdlari = cihazlarTanim.Select(c => new { c.id, c.ad }), setAdlari = setler.Select(s => new { s.id, s.ad }),
            });
        });
    }
}
