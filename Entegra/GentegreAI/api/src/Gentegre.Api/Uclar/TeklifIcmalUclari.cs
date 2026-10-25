using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TEKLİF / FIRSAT DÖNÜŞÜM İCMALİ (1186, mockup Ekranlar/İcmal/teklif_donusum_icmali.html - kullanıcı
/// 25.10.2026, kararlar mockup altında). "Verdiğimiz tekliflerin ne kadarı satışa dönüyor, nerede
/// kaybediyoruz, hangi teklif takip bekliyor?"
///
/// <para><b>Küme:</b> satış teklifi (belge tur 18), belge iptali (durum 2) hariç, teklif tarihi dönem içinde.
/// Teklif akış durumu `belge.teklif_durum` (1 Hazırlanıyor · 2 Sunuldu · 3 Kabul · 4 Red = kaybedildi ·
/// 5 İptal); iptal teklif dönüşüm paydasına girmez. Tutar = belge dip toplamı (`matrah`, KDV hariç, TL -
/// dövizli teklif teklif tarihindeki belge kuruyla, karar). Temsilci belgeden (`satici_id`).</para>
///
/// <para><b>Dönüşüm:</b> teklif satırından türeyen satır (kaynak_tur 30 bağı, belge dönüşüm izi) - sipariş
/// (19), irsaliye (14) ya da fatura (15/16). Satırın dönen oranı = türeyen miktar / teklif miktarı (en çok 1);
/// teklifin dönen tutarı = dip toplamın satır tutarı payıyla ağırlıklı dönen kısmı. Bazı satırlar döndüyse
/// "kısmen", hepsi döndüyse "siparişe döndü". Faturalandı: zincirde (en çok 3 adım) kesin satış faturası.</para>
///
/// <para><b>Süre (karar 25.10.2026):</b> geçerlilik = belge_tarihi + vade_gun (teklif kartı "Geçerlilik
/// Süresi"). Süresi dolan, hiç satırı dönmemiş teklif gece kendiliğinden "kaybedildi · süre doldu" olur
/// (<see cref="Servisler.TeklifSureIscisi"/>, neden 9, kullanıcı sistem). Takip listesi süresi 7 gün içinde
/// dolacak ya da 7 gündür hareketsiz açık teklifleri gösterir.</para>
///
/// <para><b>Kaybedildi işaretle:</b> `satis.teklif_kayip` aksiyonu; neden (kod listesi teklif.kayip_nedeni,
/// 9 sistemin) zorunlu, rakip ve rakip fiyatı isteğe bağlı; belge logu (tablo 30) alan bazlı. Kısmen dönmüş
/// teklif kaybedildi yapılamaz.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı, cari kayıt
/// kapsamı (baglam.Kapsam) uygulanır.
/// </summary>
public static class TeklifIcmalUclari
{
    /// <summary>Ekran kodu (1186) - hakları satış teklifi listesinden (belge.satis).</summary>
    private const string Kod = "satis.teklif_icmali";
    /// <summary>Kaybedildi işaretleme aksiyonu (1186).</summary>
    private const string AksiyonKayip = "satis.teklif_kayip";
    /// <summary>islem_log.tablo_id - belge (BelgeDeposu.LogTabloBelge ile aynı).</summary>
    public const int LogTabloBelge = 30;

    public const int TurTeklif = 18;
    /// <summary>Sistemin yazdığı neden: süre doldu (kod listesi teklif.kayip_nedeni).</summary>
    public const short NedenSureDoldu = 9;
    /// <summary>Takip penceresi: süresi bu kadar gün içinde dolacak ya da bu kadar gündür hareketsiz.</summary>
    private const int TakipGun = 7;
    /// <summary>Çok teklif alıp az siparişe dönen müşteri: en az bu kadar teklif ve tutarca bu yüzdenin altında.</summary>
    private const int DusukDonusumTeklif = 5;
    private const decimal DusukDonusumYuzde = 25m;

    private static readonly int[] DonusHedefTurleri = [19, 14, 15, 16];
    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public sealed record KayipIstegi(int BelgeId, short Neden, string? Rakip, decimal? RakipFiyat, string? Aciklama);

    // ================================================================ kayıtlar ===

    private sealed record Tek(int Id, string No, DateTime Tarih, int TarafId, string Cari, bool Musteri, bool Tedarikci,
        int SaticiId, string Satici, int SubeId, decimal Matrah, short Durum, int VadeGun, string Revize,
        short? KayipNeden, string Rakip, decimal? RakipFiyat, DateTime? KayipAn, int? KayipKim, DateTime SonHareket, string Konu)
    {
        public DateTime? Gecerlilik => VadeGun > 0 ? Tarih.AddDays(VadeGun) : null;
    }

    /// <summary>Teklif satırı + dönüş izi. Donen: türeyen miktar (en çok teklif miktarı).</summary>
    private sealed record Sat(int BelgeId, int SatirId, decimal Miktar, decimal Tutar, decimal Brut, string Kategori,
        decimal Donen, DateTime? IlkDonus, DateTime? IlkFatura)
    {
        public decimal Oran => Miktar > 0 ? Math.Min(Donen / Miktar, 1m) : Donen > 0 ? 1m : 0m;
    }

    /// <summary>Teklifin hesaplanmış görünümü (bütün sekmeler bundan beslenir).</summary>
    private sealed record Hal(Tek T, List<Sat> Satirlar, decimal DonenTutar, decimal DonenOran, decimal Brut, decimal Isk,
        DateTime? IlkDonus, DateTime? IlkFatura, string Durum)
    {
        public bool Iptal => Durum == "iptal";
        public bool Kayip => Durum == "kaybedildi";
        public bool Dondu => Durum is "dondu" or "kismen";
        public bool Bekliyor => Durum is "bekliyor" or "kabul" or "suresi_doldu";
    }

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static decimal? YuzdeN(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : null;
    private static decimal? Ort(IEnumerable<int> l) { var x = l.ToList(); return x.Count > 0 ? Math.Round((decimal)x.Average(), 1) : null; }

    public static string DurumAdi(string d) => d switch
    {
        "kaybedildi" => "kaybedildi", "iptal" => "iptal", "dondu" => "siparişe döndü", "kismen" => "kısmen döndü",
        "kabul" => "kabul · sipariş bekliyor", "suresi_doldu" => "süresi doldu", "hazirlaniyor" => "hazırlanıyor", _ => "bekliyor",
    };

    /// <summary>
    /// DURUM KURALI (saf, test edilir): iptal (5) · kaybedildi (4) · satırların hepsi döndüyse "dondu", bir kısmı
    /// "kismen" · kabul (3) ama dönüş yok "kabul" · geçerliliği dolmuş ama gece işi henüz çevirmemiş
    /// "suresi_doldu" · hazırlanıyor (1) "hazirlaniyor" · diğer "bekliyor".
    /// </summary>
    public static string DurumBul(short teklifDurum, decimal donenOran, DateTime? gecerlilik, DateTime bugun)
    {
        if (teklifDurum == 5) return "iptal";
        if (teklifDurum == 4) return "kaybedildi";
        if (donenOran >= 0.999m) return "dondu";
        if (donenOran > 0m) return "kismen";
        if (teklifDurum == 3) return "kabul";
        if (gecerlilik is { } g && g.Date < bugun.Date) return "suresi_doldu";
        return teklifDurum == 1 ? "hazirlaniyor" : "bekliyor";
    }

    /// <summary>Gece işinin seçim kuralı (saf, test edilir): açık (1/2), geçerlilik süresi tanımlı ve geçmiş, hiç dönüş yok.</summary>
    public static bool SuresiDolarMi(short teklifDurum, int vadeGun, DateTime belgeTarihi, bool donusVar, DateTime bugun)
        => teklifDurum is 1 or 2 && vadeGun > 0 && !donusVar && belgeTarihi.Date.AddDays(vadeGun) < bugun.Date;

    // ================================================================== SQL ===

    /// <summary>Teklifler. @p0 bas · @p1 bit (dahil) · @p2 kullanıcının şubeleri · @p3 seçili şube (0 tümü) ·
    ///   @p4 cari kayıt kapsamı · @p5 1 = AÇIK teklifler (tarih süzgeçsiz, takip listesi).</summary>
    private const string TeklifSorgusu = """
        select b.id, coalesce(nullif(b.belge_no, ''), '#' || b.id)::varchar(60), b.belge_tarihi::date, coalesce(b.taraf_id, 0),
               coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               coalesce(t.musteri, 0)::int, coalesce(t.tedarikci, 0)::int,
               coalesce(b.satici_id, 0), coalesce(public.fn_taraf_ad(sp.unvan, sp.ad, sp.soyad)::varchar(160), '')::varchar(160),
               coalesce(b.sube_id, 0), coalesce(b.matrah, 0), coalesce(b.teklif_durum, 1)::smallint, coalesce(b.vade_gun, 0)::int,
               coalesce(b.revize_no, '')::varchar(20), b.teklif_kayip_nedeni, coalesce(b.teklif_rakip, '')::varchar(120),
               b.teklif_rakip_fiyat, b.teklif_kayip_an, b.teklif_kayip_kim,
               coalesce(b.degistirme_tarihi, b.ekleme_tarihi, b.belge_tarihi)::timestamp,
               coalesce(b.teklif_konusu, '')::varchar(200)
          from public.belge b
          left join public.taraf t on t.id = b.taraf_id
          left join public.taraf sp on sp.id = b.satici_id
         where b.tur = 18 and b.durum <> 2
           and (@p5 = 1 or (b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1))
           and (@p5 = 0 or (coalesce(b.teklif_durum, 1) in (1, 2, 3) and b.belge_tarihi >= @p0::date - 730))
           and (b.sube_id is null or b.sube_id = any(@p2::int[]))
           and (@p3 = 0 or b.sube_id = @p3)
           and (cardinality(@p4::int[]) = 0 or b.taraf_id = any(@p4::int[]))
         order by b.belge_tarihi desc, b.id desc
        """;

    /// <summary>Teklif satırları + dönüş izi. @p0 teklif id'leri. Zincir kaynak_tur 30 bağıyla en çok 3 adım
    ///   (teklif → sipariş → irsaliye → fatura); iptal belge sayılmaz. İlk adımdaki sipariş / irsaliye / fatura
    ///   miktarı "dönen"dir; zincirin herhangi bir adımındaki kesin satış faturası "faturalandı".</summary>
    private const string SatirSorgusu = """
        with recursive zincir as (
            select s.id as kok, s.id as sid, 0 as d from public.belge_satir s where s.belge_id = any(@p0::int[])
            union all
            select z.kok, h.id, z.d + 1 from zincir z
              join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = z.sid
             where z.d < 3
        ),
        iz as (
            select z.kok,
                   sum(case when z.d = 1 and hb.tur = any(@p1::int[]) then coalesce(h.miktar, 0) else 0 end) as donen,
                   min(case when z.d = 1 and hb.tur = any(@p1::int[]) then hb.belge_tarihi::date end) as ilk_donus,
                   min(case when hb.tur in (15, 16) and hb.durum = 0 and coalesce(hb.tipi, 0) <> 2 then hb.belge_tarihi::date end) as ilk_fatura
              from zincir z
              join public.belge_satir h on h.id = z.sid
              join public.belge hb on hb.id = h.belge_id and hb.durum <> 2
             where z.d > 0
             group by z.kok
        )
        select s.belge_id, s.id, coalesce(s.miktar, 0), coalesce(s.tutar, 0),
               greatest(round(coalesce(s.adet, 0) * coalesce(s.birim_fiyat, 0), 2), coalesce(s.tutar, 0)),
               case when s.stok_id is null then '(hizmet)'
                    else coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '(kategorisiz)') end::varchar(200),
               coalesce(iz.donen, 0), iz.ilk_donus, iz.ilk_fatura
          from public.belge_satir s
          left join public.stok st on st.id = s.stok_id
          left join public.kategori k on k.id = st.kategori
          left join iz on iz.kok = s.id
         where s.belge_id = any(@p0::int[])
         order by s.belge_id, s.sira, s.id
        """;

    private static async Task<List<Tek>> TekliflerAsync(NpgsqlConnection b, DateTime bas, DateTime bit, int[] subeler, int sube,
        int[] kapsam, bool acik, CancellationToken iptal)
        => await b.ListeAsync(TeklifSorgusu, null, [bas, bit, subeler, sube, kapsam, acik ? 1 : 0], o => new Tek(
            o.GetInt32(0), o.GetString(1), o.GetDateTime(2), o.GetInt32(3), o.GetString(4), o.GetInt32(5) == 1, o.GetInt32(6) == 1,
            o.GetInt32(7), o.GetString(8), o.GetInt32(9), o.GetDecimal(10), o.GetInt16(11), o.GetInt32(12), o.GetString(13),
            o.IsDBNull(14) ? null : o.GetInt16(14), o.GetString(15), o.IsDBNull(16) ? null : o.GetDecimal(16),
            o.IsDBNull(17) ? null : o.GetDateTime(17), o.IsDBNull(18) ? null : o.GetInt32(18), o.GetDateTime(19), o.GetString(20)), iptal);

    private static async Task<List<Sat>> SatirlarAsync(NpgsqlConnection b, IEnumerable<int> idler, CancellationToken iptal)
    {
        var dizi = idler.Distinct().ToArray();
        if (dizi.Length == 0) return [];
        return await b.ListeAsync(SatirSorgusu, null, [dizi, DonusHedefTurleri], o => new Sat(
            o.GetInt32(0), o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3), o.GetDecimal(4), o.GetString(5),
            o.GetDecimal(6), o.IsDBNull(7) ? null : o.GetDateTime(7), o.IsDBNull(8) ? null : o.GetDateTime(8)), iptal);
    }

    /// <summary>Teklifin dönen tutarı: dip toplamın satır tutarı payıyla ağırlıklı dönen kısmı. Satırsız teklif dönmemiş sayılır.</summary>
    private static List<Hal> Hesapla(IEnumerable<Tek> teklifler, List<Sat> satirlar, DateTime bugun)
    {
        var gruplar = satirlar.GroupBy(s => s.BelgeId).ToDictionary(g => g.Key, g => g.ToList());
        var l = new List<Hal>();
        foreach (var t in teklifler)
        {
            var ss = gruplar.TryGetValue(t.Id, out var x) ? x : [];
            var payda = ss.Sum(s => s.Tutar);
            decimal oran;
            if (ss.Count == 0) oran = 0m;
            else if (payda != 0) oran = ss.Sum(s => s.Tutar * s.Oran) / payda;
            else oran = ss.Average(s => s.Oran);
            var brut = ss.Sum(s => s.Brut);
            var isk = Math.Max(brut - payda, 0m);
            var ilkDonus = ss.Where(s => s.IlkDonus is not null).Select(s => s.IlkDonus).Min();
            var ilkFatura = ss.Where(s => s.IlkFatura is not null).Select(s => s.IlkFatura).Min();
            var durum = DurumBul(t.Durum, Math.Round(oran, 4), t.Gecerlilik, bugun);
            l.Add(new Hal(t, ss, R(t.Matrah * oran), Math.Round(oran, 4), brut, isk, ilkDonus, ilkFatura, durum));
        }
        return l;
    }

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    private static async Task<Dictionary<short, string>> NedenlerAsync(NpgsqlConnection b, NpgsqlTransaction? tx, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select d.deger, d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
             where l.kod = 'teklif.kayip_nedeni' and d.dil in (0, -1) and coalesce(d.aktif, 1) = 1
             order by d.sira, d.deger
            """, tx, [], o => (deger: (short)o.GetInt32(0), ad: o.GetString(1)), iptal);
        var s = new Dictionary<short, string>();
        foreach (var x in l) s.TryAdd(x.deger, x.ad);
        return s;
    }

    // ================================================================= uçlar ===

    public static void TeklifIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/teklif-icmal").WithTags("Teklif Dönüşüm İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? sube, int? temsilci,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var tms = temsilci ?? 0;
            bool TemsilciUyar(Tek x) => tms == 0 || (tms == -1 ? x.SaticiId == 0 : x.SaticiId == tms);

            await using var b = await veri.AcAsync(iptal);
            var donemHam = await TekliflerAsync(b, baslangic, bitis, subeler, s0, kapsam, false, iptal);
            var acikHam = await TekliflerAsync(b, bugun, bugun, subeler, s0, kapsam, true, iptal);
            var temsilciSecim = donemHam.Concat(acikHam).GroupBy(x => x.SaticiId).OrderBy(g => g.Key == 0 ? 1 : 0).ThenBy(g => g.First().Satici)
                .Select(g => new { id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().Satici }).ToList();
            var donem = donemHam.Where(TemsilciUyar).ToList();
            var acik = acikHam.Where(TemsilciUyar).ToList();
            var satirlar = await SatirlarAsync(b, donem.Select(x => x.Id).Concat(acik.Select(x => x.Id)), iptal);
            var haller = Hesapla(donem, satirlar, bugun);
            var aciklar = Hesapla(acik, satirlar, bugun);
            var nedenler = await NedenlerAsync(b, null, iptal);
            string NedenAdi(short? n) => n is { } k ? nedenler.TryGetValue(k, out var a) ? a : $"#{k}" : "(neden girilmemiş)";
            var gecerli = haller.Where(h => !h.Iptal).ToList();

            // ---------------------------------------------------------- özet --
            var tutar = gecerli.Sum(h => h.T.Matrah);
            var donenler = gecerli.Where(h => h.Dondu).ToList();
            var kayiplar = gecerli.Where(h => h.Kayip).ToList();
            var bekleyen = gecerli.Where(h => h.Bekliyor).ToList();
            var sureDolan = kayiplar.Where(h => h.T.KayipNeden == NedenSureDoldu).ToList();
            var dolacak = aciklar.Where(h => h.Bekliyor && h.Durum != "suresi_doldu" && h.T.Gecerlilik is { } g
                                            && (g - bugun).TotalDays is >= 0 and <= TakipGun).ToList();
            var donusGun = donenler.Where(h => h.IlkDonus is not null).Select(h => (int)(h.IlkDonus!.Value - h.T.Tarih).TotalDays).ToList();

            var firsat = await b.ListeAsync("""
                select f.id, coalesce(f.durum, 1)::int, coalesce(f.asama, 1)::int,
                       coalesce(f.tahmini_tutar, 0) * case when coalesce(nullif(btrim(f.doviz_cinsi), ''), 'TL') in ('TL', 'TRY')
                                                           then 1 else coalesce(nullif(f.doviz_kuru, 0), 1) end,
                       coalesce(f.olasilik, 0)::int, coalesce(f.sorumlu_id, 0)
                  from public.firsat f
                 where f.ekleme_tarihi >= @p0::date and f.ekleme_tarihi < @p1::date + 1
                   and (f.sube_id is null or f.sube_id = any(@p2::int[]))
                   and (@p3 = 0 or f.sube_id = @p3)
                   and (cardinality(@p4::int[]) = 0 or f.taraf_id = any(@p4::int[]))
                """, null, [baslangic, bitis, subeler, s0, kapsam],
                o => (id: o.GetInt32(0), durum: o.GetInt32(1), asama: o.GetInt32(2), tutar: o.GetDecimal(3), olasilik: o.GetInt32(4), sorumlu: o.GetInt32(5)), iptal);
            var firsatK = firsat.Where(f => tms == 0 || (tms == -1 ? f.sorumlu == 0 : f.sorumlu == tms)).ToList();
            var firsatAcik = firsatK.Where(f => f.durum == 1).ToList();

            var ozet = new
            {
                teklif = gecerli.Count, tutar = R(tutar), iptal = haller.Count(h => h.Iptal),
                donenAdet = donenler.Count, donenTutar = R(donenler.Sum(h => h.DonenTutar)),
                donusumTutar = Yuzde(donenler.Sum(h => h.DonenTutar), tutar), donusumAdet = Yuzde(donenler.Count, gecerli.Count),
                kaybedilenAdet = kayiplar.Count, kaybedilenTutar = R(kayiplar.Sum(h => h.T.Matrah)), kayipOran = Yuzde(kayiplar.Sum(h => h.T.Matrah), tutar),
                bekleyenAdet = bekleyen.Count, bekleyenTutar = R(bekleyen.Sum(h => h.T.Matrah)),
                ortDonusGun = Ort(donusGun),
                ortIskonto = Yuzde(gecerli.Sum(h => h.Isk), gecerli.Sum(h => h.Brut)),
                kazanilanIskonto = Yuzde(donenler.Sum(h => h.Isk), donenler.Sum(h => h.Brut)),
                firsat = new
                {
                    adet = firsatK.Count, acik = firsatAcik.Count, acikTutar = R(firsatAcik.Sum(f => f.tutar)),
                    agirlikli = R(firsatAcik.Sum(f => f.tutar * f.olasilik / 100m)),
                },
                sureDolanAdet = sureDolan.Count, sureDolanTutar = R(sureDolan.Sum(h => h.T.Matrah)),
                dolacakAdet = dolacak.Count, dolacakTutar = R(dolacak.Sum(h => h.T.Matrah)),
            };

            // ---------------------------------------------------------- huni --
            var sunulan = gecerli.Where(h => h.T.Durum is 2 or 3 or 4 || h.Dondu || h.T.Revize.Length > 0).ToList();
            var faturalanan = donenler.Where(h => h.IlkFatura is not null).ToList();
            var faturaGun = faturalanan.Where(h => h.IlkDonus is not null)
                .Select(h => (int)(h.IlkFatura!.Value - h.IlkDonus!.Value).TotalDays).Where(g => g >= 0).ToList();
            var huni = new List<object>
            {
                new { asama = "Fırsat açıldı", adet = firsatK.Count, tutar = R(firsatK.Sum(f => f.tutar)), gecis = (decimal?)null, ortGun = (decimal?)null },
                new { asama = "Teklif verildi", adet = gecerli.Count, tutar = R(tutar), gecis = YuzdeN(gecerli.Count, firsatK.Count), ortGun = (decimal?)null },
                new { asama = "Sunuldu / müzakere", adet = sunulan.Count, tutar = R(sunulan.Sum(h => h.T.Matrah)), gecis = YuzdeN(sunulan.Count, gecerli.Count), ortGun = (decimal?)null },
                new { asama = "Siparişe döndü", adet = donenler.Count, tutar = R(donenler.Sum(h => h.DonenTutar)), gecis = YuzdeN(donenler.Count, sunulan.Count), ortGun = Ort(donusGun) },
                new { asama = "Faturalandı", adet = faturalanan.Count, tutar = R(faturalanan.Sum(h => h.DonenTutar)), gecis = YuzdeN(faturalanan.Count, donenler.Count), ortGun = Ort(faturaGun) },
            };

            // ------------------------------------------------------- teklifler --
            object TeklifGorunumu(Hal h) => new
            {
                id = h.T.Id, no = h.T.No, tarih = h.T.Tarih, tarafId = h.T.TarafId, cari = h.T.Cari, musteri = h.T.Musteri, tedarikci = h.T.Tedarikci,
                temsilci = h.T.SaticiId == 0 ? "(temsilcisiz)" : h.T.Satici, tutar = R(h.T.Matrah),
                iskonto = Yuzde(h.Isk, h.Brut), gecerlilik = h.T.Gecerlilik, revize = h.T.Revize, konu = h.T.Konu,
                durum = h.Durum, durumAdi = h.Kayip ? $"kaybedildi · {NedenAdi(h.T.KayipNeden).ToLower(Tr)}" : DurumAdi(h.Durum),
                donenTutar = h.DonenTutar, donenOran = Math.Round(100m * h.DonenOran, 1), ilkDonus = h.IlkDonus,
                kayipNeden = h.T.KayipNeden, rakip = h.T.Rakip, rakipFiyat = h.T.RakipFiyat, sistem = h.Kayip && h.T.KayipKim == 0,
            };
            var teklifler = haller.Select(TeklifGorunumu).Take(1000).ToList();

            // ------------------------------------------------------- temsilci --
            object TemsilciSatiri(IGrouping<int, Hal> g)
            {
                var gg = g.Where(h => !h.Iptal).ToList();
                var t = gg.Sum(h => h.T.Matrah);
                var dn = gg.Where(h => h.Dondu).ToList();
                return new
                {
                    id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().T.Satici,
                    teklif = gg.Count, tutar = R(t), donen = R(dn.Sum(h => h.DonenTutar)), donusum = Yuzde(dn.Sum(h => h.DonenTutar), t),
                    donusumAdet = Yuzde(dn.Count, gg.Count),
                    kayip = R(gg.Where(h => h.Kayip).Sum(h => h.T.Matrah)), ortIskonto = Yuzde(gg.Sum(h => h.Isk), gg.Sum(h => h.Brut)),
                    ortGun = Ort(dn.Where(h => h.IlkDonus is not null).Select(h => (int)(h.IlkDonus!.Value - h.T.Tarih).TotalDays)),
                    bekleyen = R(gg.Where(h => h.Bekliyor).Sum(h => h.T.Matrah)),
                };
            }
            var temsilciler = haller.GroupBy(h => h.T.SaticiId).OrderByDescending(g => g.Where(h => !h.Iptal).Sum(h => h.T.Matrah))
                .Select(TemsilciSatiri).ToList();
            var temsilciToplam = new
            {
                teklif = gecerli.Count, tutar = R(tutar), donen = R(donenler.Sum(h => h.DonenTutar)),
                donusum = Yuzde(donenler.Sum(h => h.DonenTutar), tutar), kayip = R(kayiplar.Sum(h => h.T.Matrah)),
                ortIskonto = ozet.ortIskonto, ortGun = ozet.ortDonusGun, bekleyen = R(bekleyen.Sum(h => h.T.Matrah)),
            };

            // -------------------------------------------------------- müşteri --
            var cariIdleri = gecerli.Select(h => h.T.TarafId).Where(x => x > 0).Distinct().ToArray();
            var sonSiparis = cariIdleri.Length == 0 ? new Dictionary<int, DateTime>()
                : (await b.ListeAsync("""
                    select b.taraf_id, max(b.belge_tarihi)::date from public.belge b
                     where b.tur = 19 and b.durum <> 2 and b.taraf_id = any(@p0::int[]) group by 1
                    """, null, [cariIdleri], o => (id: o.GetInt32(0), t: o.GetDateTime(1)), iptal)).ToDictionary(x => x.id, x => x.t);
            var musteriler = gecerli.GroupBy(h => h.T.TarafId).Select(g =>
            {
                var t = g.Sum(h => h.T.Matrah);
                var dn = g.Where(h => h.Dondu).Sum(h => h.DonenTutar);
                var oran = Yuzde(dn, t);
                var ilk = g.First().T;
                return new
                {
                    id = g.Key, ad = ilk.Cari, musteri = ilk.Musteri, tedarikci = ilk.Tedarikci,
                    teklif = g.Count(), tutar = R(t), donen = R(dn), donusum = oran,
                    kayip = R(g.Where(h => h.Kayip).Sum(h => h.T.Matrah)),
                    sonTeklif = g.Max(h => h.T.Tarih), sonSiparis = sonSiparis.TryGetValue(g.Key, out var ss) ? ss : (DateTime?)null,
                    dusuk = g.Count() >= DusukDonusumTeklif && oran < DusukDonusumYuzde,
                };
            }).OrderByDescending(x => x.dusuk).ThenByDescending(x => x.tutar).ToList();

            // ------------------------------------------------------- kategori --
            var kategoriler = gecerli.SelectMany(h =>
            {
                var payda = h.Satirlar.Sum(s => s.Tutar);
                return h.Satirlar.Select(s => (kat: s.Kategori, tutar: payda != 0 ? h.T.Matrah * s.Tutar / payda : 0m,
                                               donen: (payda != 0 ? h.T.Matrah * s.Tutar / payda : 0m) * s.Oran,
                                               brut: s.Brut, isk: Math.Max(s.Brut - s.Tutar, 0m)));
            }).GroupBy(x => x.kat).Select(g => new
            {
                ad = g.Key, satir = g.Count(), tutar = R(g.Sum(x => x.tutar)), donen = R(g.Sum(x => x.donen)),
                donusum = Yuzde(g.Sum(x => x.donen), g.Sum(x => x.tutar)), ortIskonto = Yuzde(g.Sum(x => x.isk), g.Sum(x => x.brut)),
            }).OrderByDescending(x => x.tutar).ToList();

            // ---------------------------------------------------- kayıp nedeni --
            var kayipTutar = kayiplar.Sum(h => h.T.Matrah);
            var kayipSatirlari = kayiplar.GroupBy(h => h.T.KayipNeden ?? 0).Select(g =>
            {
                var t = g.Sum(h => h.T.Matrah);
                var rakipler = g.Where(h => h.T.Rakip.Length > 0).GroupBy(h => h.T.Rakip.Trim())
                    .OrderByDescending(r => r.Count()).Select(r => $"{r.Key} ({r.Count()})").Take(4).ToList();
                var fark = g.Where(h => h.T.RakipFiyat is > 0).Select(h => 100m * (h.T.Matrah - h.T.RakipFiyat!.Value) / h.T.RakipFiyat!.Value).ToList();
                return new
                {
                    neden = (int)g.Key, ad = g.Key == 0 ? "(neden girilmemiş)" : NedenAdi((short)g.Key), adet = g.Count(), tutar = R(t),
                    pay = Yuzde(t, kayipTutar), rakipler = string.Join(", ", rakipler),
                    ortFiyatFark = fark.Count > 0 ? Math.Round(fark.Average(), 1) : (decimal?)null,
                };
            }).OrderByDescending(x => x.tutar).ToList();

            // ----------------------------------------------------- takip bekleyen --
            var takip = aciklar.Where(h => h.Bekliyor && h.Durum != "suresi_doldu").Select(h =>
            {
                var kalan = h.T.Gecerlilik is { } g ? (int)(g - bugun).TotalDays : (int?)null;
                var hareketsiz = (int)(bugun - h.T.SonHareket.Date).TotalDays;
                var yakin = kalan is >= 0 and <= TakipGun;
                return (h, kalan, hareketsiz, yakin, uygun: yakin || hareketsiz >= TakipGun);
            }).Where(x => x.uygun).OrderBy(x => x.kalan ?? int.MaxValue).ThenByDescending(x => x.hareketsiz).Select(x => new
            {
                id = x.h.T.Id, no = x.h.T.No, tarih = x.h.T.Tarih, tarafId = x.h.T.TarafId, cari = x.h.T.Cari,
                musteri = x.h.T.Musteri, tedarikci = x.h.T.Tedarikci,
                temsilci = x.h.T.SaticiId == 0 ? "(temsilcisiz)" : x.h.T.Satici, tutar = R(x.h.T.Matrah),
                gecerlilik = x.h.T.Gecerlilik, kalanGun = x.kalan, hareketsizGun = x.hareketsiz,
                durum = x.kalan == 0 ? "bugun" : x.kalan == 1 ? "yarin" : x.yakin ? "yakin" : "hareketsiz",
                durumAdi = x.kalan == 0 ? "bugün son gün" : x.kalan == 1 ? "yarın kayba düşer" : x.yakin ? $"{x.kalan} gün kaldı" : $"{x.hareketsiz} gündür hareketsiz",
            }).ToList();

            var otomatik = await AyarDeposu.OndalikAsync(b, null, "teklif.otomatik_kayip", iptal) is not 0m;

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, bugun, sube = s0, temsilci = tms, takipGun = TakipGun,
                ozet, huni, teklifler, teklifSayi = haller.Count, temsilciler, temsilciToplam, musteriler, kategoriler,
                kayiplar = kayipSatirlari, kayipToplam = new { adet = kayiplar.Count, tutar = R(kayipTutar) }, takip,
                esik = new { dusukTeklif = DusukDonusumTeklif, dusukYuzde = DusukDonusumYuzde },
                otomatikKayip = otomatik,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    temsilciler = temsilciSecim,
                    kayipNedenleri = nedenler.Where(x => x.Key != NedenSureDoldu).Select(x => new { id = (int)x.Key, ad = x.Value }).ToList(),
                },
                yetkiler = new { kayip = baglam.Yetkiler.AksiyonVar(AksiyonKayip) && baglam.SubeYazma },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ========================================================= KAYBEDİLDİ İŞARETLE ===
        // Neden zorunlu (9 "süre doldu" sistemindir), rakip / fiyat isteğe bağlı. Kısmen dönmüş teklif kaybedilemez.
        grup.MapPost("/kayip", async (KayipIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                       HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonKayip);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var rakip = (istek.Rakip ?? "").Trim();
            if (rakip.Length > 120) throw GentegreHatasi.Dogrulama("Rakip en fazla 120 karakter.", new AlanHatasi("rakip", "En fazla 120 karakter."));
            if (istek.RakipFiyat is < 0 or > 999_999_999_999m)
                throw GentegreHatasi.Dogrulama("Rakip fiyatı geçersiz.", new AlanHatasi("rakipFiyat", "0 ya da daha büyük olmalı."));
            var aciklama = (istek.Aciklama ?? "").Trim();
            if (aciklama.Length > 300) throw GentegreHatasi.Dogrulama("Açıklama en fazla 300 karakter.", new AlanHatasi("aciklama", "En fazla 300 karakter."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var nedenler = await NedenlerAsync(b, tx, iptal);
            if (istek.Neden == NedenSureDoldu || !nedenler.ContainsKey(istek.Neden))
                throw GentegreHatasi.Dogrulama("Kayıp nedeni seçilmeli.", new AlanHatasi("neden", "Listeden bir neden seçin."));

            var tl = await b.ListeAsync("""
                select b.id, coalesce(b.tur, 0)::int, coalesce(b.durum, 0)::int, coalesce(b.teklif_durum, 1)::int, coalesce(b.sube_id, 0),
                       coalesce(b.taraf_id, 0), b.teklif_kayip_nedeni, coalesce(b.teklif_rakip, ''), b.teklif_rakip_fiyat,
                       exists (select 1 from public.belge_satir s
                                 join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = s.id
                                 join public.belge hb on hb.id = h.belge_id and hb.durum <> 2
                                where s.belge_id = b.id)
                  from public.belge b where b.id = @p0
                   for update of b
                """, tx, [istek.BelgeId], o => (id: o.GetInt32(0), tur: o.GetInt32(1), durum: o.GetInt32(2), td: o.GetInt32(3),
                    sube: o.GetInt32(4), taraf: o.GetInt32(5), neden: o.IsDBNull(6) ? (short?)null : o.GetInt16(6),
                    rakip: o.GetString(7), fiyat: o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8), donus: o.GetBoolean(9)), iptal);
            if (tl.Count == 0) throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");
            var t = tl[0];
            if ( t.tur != TurTeklif || t.durum == 2) throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");
            if (t.sube > 0 && baglam.Subeler.All(x => x.Id != t.sube)) throw GentegreHatasi.Yasak("Bu şubenin teklifini değiştirme yetkiniz yok.");
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(t.taraf)) throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");
            if (t.td == 4) throw GentegreHatasi.IsKurali("Teklif zaten kaybedildi.");
            if (t.td == 5) throw GentegreHatasi.IsKurali("İptal edilmiş teklif kaybedildi yapılamaz.");
            if (t.donus) throw GentegreHatasi.IsKurali("Teklifin satırları siparişe dönmüş; kaybedildi yapılamaz.");

            var fiyat = istek.RakipFiyat is { } f ? Math.Round(f, 2) : (decimal?)null;
            await b.CalistirAsync("""
                update public.belge set teklif_durum = 4, teklif_kayip_nedeni = @p1, teklif_rakip = @p2, teklif_rakip_fiyat = @p3::numeric,
                                        teklif_kayip_an = now(), teklif_kayip_kim = @p4, degistiren = @p4, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [t.id, istek.Neden, rakip, fiyat, baglam.KullaniciId], iptal);
            var fark = LogDeposu.Fark(
                new Dictionary<string, object?> { ["teklifDurum"] = t.td, ["teklifKayipNedeni"] = t.neden is { } n0 ? (int)n0 : null,
                                                  ["teklifRakip"] = t.rakip, ["teklifRakipFiyat"] = Sayi(t.fiyat) },
                new Dictionary<string, object?> { ["teklifDurum"] = 4, ["teklifKayipNedeni"] = (int)istek.Neden,
                                                  ["teklifRakip"] = rakip, ["teklifRakipFiyat"] = Sayi(fiyat) })
                ?? new Dictionary<string, string>();
            fark["aksiyon"] = "teklif-kaybedildi";
            fark["neden"] = nedenler[istek.Neden];
            if (aciklama.Length > 0) fark["aciklama"] = aciklama;
            fark["kaynak"] = "teklif-icmali";
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, t.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                               tarafId: t.taraf > 0 ? t.taraf : null, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { belgeId = t.id, durum = "kaybedildi", izlemeNo = baglam.IzlemeNo });
        });
    }

    private static string? Sayi(decimal? d) => d is { } x ? x.ToString("0.00", CultureInfo.InvariantCulture) : null;

    // ============================================================ GECE İŞİ ===

    /// <summary>
    /// SÜRESİ DOLAN TEKLİFLER (karar 25.10.2026): açık (1/2) teklifin geçerliliği (belge_tarihi + vade_gun) ŞUBENİN
    /// gününe göre geçtiyse ve hiçbir satırı siparişe / irsaliyeye / faturaya dönmediyse teklif_durum 4, neden 9
    /// "Süre doldu", kim 0 (sistem). Kısmen dönmüş teklif dokunulmaz. Ayar `teklif.otomatik_kayip` 0 ise iş yapmaz.
    /// Her teklif belge logu (tablo 30, kullanıcı 0) alır. Dönüş: kayba çevrilen teklif sayısı.
    /// </summary>
    public static async Task<int> SuresiDolanlariKapatAsync(VeriKaynagi veri, LogDeposu log, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        if (await AyarDeposu.OndalikAsync(b, null, "teklif.otomatik_kayip", iptal) is 0m) return 0;
        await using var tx = await b.BeginTransactionAsync(iptal);
        var kapanan = await b.ListeAsync("""
            with aday as (
                select b.id, coalesce(b.teklif_durum, 1)::int as eski, coalesce(b.sube_id, 0) as sube, coalesce(b.taraf_id, 0) as taraf
                  from public.belge b
                  left join public.sube s on s.id = b.sube_id
                 where b.tur = 18 and b.durum <> 2 and coalesce(b.teklif_durum, 1) in (1, 2) and coalesce(b.vade_gun, 0) > 0
                   and b.belge_tarihi::date + b.vade_gun
                       < (now() at time zone coalesce(nullif(btrim(s.zaman_dilimi), ''), 'Europe/Istanbul'))::date
                   and not exists (select 1 from public.belge_satir ts
                                     join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = ts.id
                                     join public.belge hb on hb.id = h.belge_id and hb.durum <> 2
                                    where ts.belge_id = b.id)
                   for update of b skip locked
            )
            update public.belge b
               set teklif_durum = 4, teklif_kayip_nedeni = 9, teklif_kayip_kim = 0, teklif_kayip_an = now(),
                   degistiren = 0, degistirme_tarihi = now()
              from aday a
             where b.id = a.id
            returning b.id, a.eski, a.sube, a.taraf
            """, tx, [], o => (id: o.GetInt32(0), eski: o.GetInt32(1), sube: o.GetInt32(2), taraf: o.GetInt32(3)), iptal);
        foreach (var k in kapanan)
        {
            var fark = LogDeposu.Fark(
                new Dictionary<string, object?> { ["teklifDurum"] = k.eski, ["teklifKayipNedeni"] = null },
                new Dictionary<string, object?> { ["teklifDurum"] = 4, ["teklifKayipNedeni"] = (int)NedenSureDoldu })
                ?? new Dictionary<string, string>();
            fark["aksiyon"] = "teklif-suresi-doldu";
            fark["neden"] = "Süre doldu";
            fark["kaynak"] = "teklif-sure-iscisi";
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, k.id, 0, k.sube > 0 ? k.sube : null, "", fark,
                               tarafId: k.taraf > 0 ? k.taraf : null, iptal: iptal);
        }
        await tx.CommitAsync(iptal);
        return kapanan.Count;
    }
}
