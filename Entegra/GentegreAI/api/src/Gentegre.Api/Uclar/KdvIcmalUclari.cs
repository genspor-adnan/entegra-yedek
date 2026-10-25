using System.Globalization;
using System.Text.RegularExpressions;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler.EFatura;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KDV İCMALİ (mockup Ekranlar/İcmal/kdv_icmali.html - kullanıcı 25.10.2026, kararlar mockup
/// altında). BEYANNAME DEĞİLDİR: beyandan önce ön kontrol ve müşavir dökümü.
///
/// <para><b>Mükellef (karar):</b> şubenin VKN'si (sube.vkno, yalnız rakamlar). Aynı VKN'li
/// şubeler TEK icmaldir; şube kırılımı şeritte süzgeçtir. Kullanıcının şubelerinde tek VKN
/// varsa şubesiz belgeler de o mükellefe sayılır; birden çok VKN varsa şubesiz belge
/// hiçbir icmale girmez, Uyarılar'da "mükellef belirlenemedi" olur.</para>
///
/// <para><b>Küme:</b> dönemde (BELGE TARİHİ - karar) kesin satış faturası / fişi (15, 16) ve
/// alış faturası / fişi (11, 12) + aynı türlerin iadeleri (tipi 2). Taslak (durum 1)
/// varsayılan hariç; "taslak=1" ile AYRI blokta döner, ödenecek KDV'ye EKLENMEZ (karar).
/// Satırsız aktarılan tahakkuk (13 / 17) KDV ayrıntısı taşımaz, girmez; adedi bilgi uyarısıdır.
/// Stopaj (ek_vergi &lt; 0, muhtasar) kapsam dışı (karar): yalnız KDV.</para>
///
/// <para><b>Tutar:</b> belgenin SAKLI dip toplamı - `belge.matrah` ve `belge.kdv_tutari`
/// (fn_belge_diptoplam'ın yazdığı, BelgeDeposu.ToplamlariYazAsync; yerel parada = dövizli
/// belgede belge kuruyla TL). Oran kırılımında belge toplamları satırlara DAĞITILIR: matrah
/// satır tutarı, KDV satırın saklı KDV'si (tutar_kdvli − tutar) oranında; kuruş artığı en büyük
/// satıra - kırılımın toplamı birebir belge toplamıdır, satır matematiği yeniden yapılmaz.</para>
///
/// <para><b>Tevkifat:</b> tevkifatlı fatura (tipi 22), KDV'li satır; kod satırdan (yoksa
/// belge_efatura başlığından), oran satırdan (yoksa kodun resmi oranı). Tevkif edilen =
/// satır KDV'si × oran - e-Fatura XML'iyle aynı (EFaturaVerisi, WithholdingTax TaxableAmount =
/// KDV). Alışta sorumlu sıfatıyla KDV-2: hem eklenir hem aynı dönemde indirilir. Satışta
/// alıcının tevkif ettiği kısım hesaplanan KDV'den düşülür.</para>
///
/// <para><b>İstisna:</b> KDV'si sıfır satış satırı; kod e-Fatura ile aynı öncelikle (ihraç
/// kayıtlı / istisna faturasında başlık, sonra satırın kdv_muafiyeti, sonra başlık, ihracat
/// senaryosunda 301). Kodsuz %0 satır Uyarılar'a düşer.</para>
///
/// <para><b>Devreden (karar):</b> önceki ayın icmal sonucundan DEĞİL - muhasebedeki 190
/// bakiyesinden (dönem başına kadar bütün fişler). Muhasebe kullanılmıyorsa (mükellefin
/// şubelerinde 190/191/391 hareketi yok) elle girilen `kdv_devreden` (VKN + dönem başına bir
/// değer, PUT ile, loglu).</para>
///
/// <para><b>Kapanmış dönem (karar):</b> fatura tarihi önceki ay, kaydı bu ay olan alış o ayın
/// icmalindedir; o ay kapanmışsa Uyarılar'da "dönemi kapanmış, bu aya indirilecek" (tutar
/// tahmine katılmaz, bilgi satırı). Kapanış: Genel Ayarlar `muhasebe.donem_kapanis_tarihi`
/// (yoksa içinde bulunulan aydan önceki aylar - Eşleşme İcmali ile aynı kural) ya da
/// muhasebe_donem.kilitli.</para>
///
/// <para><b>Ba / Bs:</b> yalnız fatura (15 / 11, kesin), taraf bazında KDV hariç matrah;
/// Bs = satış + alış iadesi (düzenlediğimiz), Ba = alış + satış iadesi. Sınır Genel Ayarlar
/// `muhasebe.babs_sinir` (boşsa 5.000 TL, karar). Form üretilmez.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı,
/// cari kayıt kapsamı (baglam.Kapsam) uygulanır ve yanıtta işaretlenir.
/// </summary>
public static class KdvIcmalUclari
{
    private const string Kod = "muhasebe.kdv_icmali";

    /// <summary>Devreden yazımı muhasebe yazarlarının kapısıdır: icmal kodu yalnız Gör taşır (1176).</summary>
    private const string KodDevreden = "muhasebe_fis";

    /// <summary>islem_log.tablo_id - kdv_devreden (yeni numara; katalog / uç sabitlerinde boş).</summary>
    private const int LogTabloKdvDevreden = 1717;

    private static readonly int[] SatisTurleri = [15, 16];
    private static readonly int[] AlisTurleri = [11, 12];
    private static readonly int[] Turler = [15, 16, 11, 12];
    private const int TipiIade = 2;
    private const int TipiTevkifat = 22;

    public sealed record DevredenIstegi(string? Vkn, string? Donem, decimal Tutar, string? Aciklama, string? Surum);

    // ================================================================ kayıtlar ===

    private sealed record Bel(int Id, int Tur, int Tipi, string No, DateTime Tarih, int TarafId, string Taraf, string Vkn,
        int SubeId, decimal Matrah, decimal Kdv, int Durum, int EDurum, int ESonuc, int Senaryo, int BasTevkifat,
        int BasIstisna, int IadeBelgeId, string IadeBelgeNo, string Yanit, bool Gelen, bool Fisli, string Para, decimal Kur)
    {
        public bool Satis => Tur is 15 or 16;
        public bool Iade => Tipi == TipiIade;
        public bool Taslak => Durum == 1;
        public bool Fatura => Tur is 15 or 11;
        /// <summary>Bizim düzenlediğimiz fatura: satış ya da alış iadesi (e-Belge bekler, Bs'ye girer).</summary>
        public bool Giden => Fatura && (Tur == 15) != Iade;
        public string ETur => EDurum is 1 or 2 ? "efatura" : EDurum is 11 or 12 ? "earsiv" : Gelen ? "efatura" : "kagit";
        public string Yon => Satis ? (Iade ? "satis-iade" : "satis") : (Iade ? "alis-iade" : "alis");
    }

    private sealed record Sat(int BelgeId, int Id, int Oran, decimal Tutar, decimal KdvAgirlik, int Muafiyet,
        string TevKod, decimal TevOran, string Kod, string Ad, int? KartKdv);

    /// <summary>Belge toplamının bir satıra düşen payı (S null = satırsız belge).</summary>
    private sealed record Kalem(Bel B, Sat? S, int Oran, decimal Matrah, decimal Kdv, decimal Tevkif, string TevKod,
        decimal TevOran, int IstisnaKod);

    private sealed record Mukellef(string Anahtar, string Vkn, string Unvan, List<(int Id, string Ad, bool EBelge)> Subeler);

    /// <summary>Uyarılar sekmesinin satırı. Seviye: kir (beyandan önce düzelt) · sari (kontrol et) · mavi (bilgi).</summary>
    public sealed record UyariSatiri(string Tur, string Seviye, int? BelgeId, string No, DateTime? Tarih, int TarafId,
        string Taraf, string Aciklama, string Oneri, decimal? Tutar);

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static string Rakam(string? s) => new((s ?? "").Where(char.IsDigit).ToArray());
    private static string Ay(DateTime d) => d.ToString("yyyy-MM", CultureInfo.InvariantCulture);

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");
    private static string AyAdi(DateTime d) => Tr.TextInfo.ToTitleCase(d.ToString("MMMM yyyy", Tr));

    // ================================================================== SQL ===

    /// <summary>Belge kümesi. @p0 türler · @p1 bas · @p2 bit (dahil) · @p3 şubeler · @p4 şubesiz dahil ·
    ///   @p5 cari kayıt kapsamı. Taslaklar da gelir (ayrı sayılır).</summary>
    private const string BelgeSorgusu = """
        select b.id, b.tur::int, coalesce(b.tipi, 0)::int, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi::date,
               coalesce(b.taraf_id, 0),
               coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               coalesce(nullif(btrim(b.taraf_vkno), ''), t.vkno, '')::varchar(20),
               coalesce(b.sube_id, 0), coalesce(b.matrah, 0), coalesce(b.kdv_tutari, 0), coalesce(b.durum, 0)::int,
               coalesce(b.efatura_durum, 0)::int, coalesce(b.efatura_sonuc, 0)::int, coalesce(b.senaryo, 0)::int,
               coalesce(ef.tevkifat_kodu, 0)::int, coalesce(ef.istisna_kodu, 0)::int,
               coalesce(b.iade_belge_id, 0), coalesce(nullif(ib.belge_no, ''), case when ib.id is null then '' else '#' || ib.id end),
               coalesce(eb.yk, ''), (gel.id is not null),
               (b.muhasebe_fis_id is not null
                 or exists (select 1 from public.muhasebe_fis f where f.kaynak_tur = 2 and f.kaynak_id = b.id and f.durum = 1)),
               public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), public.fn_yerel_para()))::varchar(6),
               coalesce(b.doviz_kuru, 0)
          from public.belge b
          left join public.taraf t on t.id = b.taraf_id
          left join public.belge_efatura ef on ef.belge_id = b.id
          left join public.belge ib on ib.id = b.iade_belge_id
          left join lateral (select upper(coalesce(e.yanit_durum_kodu, '')) as yk
                               from public.e_belge e where e.belge_id = b.id and e.yon = 1
                              order by e.id desc limit 1) eb on true
          left join lateral (select e.id from public.e_belge e where e.belge_id = b.id and e.yon = 2 limit 1) gel on true
         where b.tur = any(@p0::int[]) and b.durum in (0, 1)
           and b.belge_tarihi >= @p1::date and b.belge_tarihi < @p2::date + 1
           and (b.sube_id = any(@p3::int[]) or (@p4 = 1 and b.sube_id is null))
           and (cardinality(@p5::int[]) = 0 or b.taraf_id = any(@p5::int[]))
         order by b.belge_tarihi, b.id
        """;

    /// <summary>Satırlar. KDV AĞIRLIĞI satırın saklı KDV'si (tutar_kdvli − tutar; 372 öncesi kayıtta
    ///   tutar × oran) - yalnız belge KDV'sini dağıtmak için kullanılır.</summary>
    private const string SatirSorgusu = """
        select s.belge_id, s.id, coalesce(s.kdv, 0)::int, coalesce(s.tutar, 0),
               case when coalesce(s.tutar_kdvli, 0) <> 0 then s.tutar_kdvli - coalesce(s.tutar, 0)
                    else coalesce(s.tutar, 0) * coalesce(s.kdv, 0) / 100.0 end,
               coalesce(s.kdv_muafiyeti, 0)::int, coalesce(btrim(s.tevkifat_kodu), '')::varchar(4), coalesce(s.tevkifat_orani, 0),
               coalesce(st.kod, hz.kod, '')::varchar(80),
               coalesce(nullif(st.ad, ''), nullif(hz.ad, ''), nullif(left(s.aciklama, 120), ''), '(açıklama)')::varchar(200),
               case when s.stok_id is not null then st.kdv::int when s.hizmet_id is not null then hz.kdv::int end
          from public.belge_satir s
          left join public.stok st on st.id = s.stok_id
          left join public.hizmet hz on hz.id = s.hizmet_id
         where s.belge_id = any(@p0::int[])
         order by s.belge_id, s.sira, s.id
        """;

    /// <summary>KDV hesaplarının fiş hareketi. @p0 bas · @p1 bit · @p2 şubeler · @p3 şubesiz dahil.
    ///   Kapanış fişi (tur 5) hariç; ters fiş / iptal edilen ikisi de girer (birbirini sıfırlar).</summary>
    private const string MuhasebeSorgusu = """
        select left(h.kod, 3), (f.kaynak_tur = 2), coalesce(sum(s.borc), 0), coalesce(sum(s.alacak), 0)
          from public.muhasebe_fis_satir s
          join public.muhasebe_fis f on f.id = s.fis_id
          join public.hesap_plani h on h.id = s.hesap_plani_id
         where f.tur <> 5 and f.fis_tarihi >= @p0::date and f.fis_tarihi <= @p1::date
           and (f.sube_id = any(@p2::int[]) or (@p3 = 1 and coalesce(f.sube_id, 0) = 0))
           and (h.kod in ('191', '391', '360') or h.kod like '191.%' or h.kod like '391.%' or h.kod like '360.%')
         group by 1, 2
        """;

    // ============================================================= yardımcılar ===

    /// <summary>Toplamı ağırlıklara göre kuruşla dağıtır; artık en büyük ağırlığa. Ağırlık toplamı
    ///   sıfırsa toplamın tamamı yedek satıra.</summary>
    private static decimal[] Dagit(decimal toplam, IReadOnlyList<decimal> agirlik, int yedek)
    {
        var r = new decimal[agirlik.Count];
        if (r.Length == 0) return r;
        var payda = agirlik.Sum();
        if (payda == 0) { r[Math.Clamp(yedek, 0, r.Length - 1)] = toplam; return r; }
        var buyuk = 0;
        decimal dag = 0;
        for (var i = 0; i < r.Length; i++)
        {
            r[i] = Math.Round(toplam * agirlik[i] / payda, 2);
            dag += r[i];
            if (Math.Abs(agirlik[i]) > Math.Abs(agirlik[buyuk])) buyuk = i;
        }
        r[buyuk] += toplam - dag;
        return r;
    }

    /// <summary>e-Fatura ile aynı öncelik (EFaturaVerisi): istisna / ihraç kayıtlı faturasında başlık,
    ///   sonra satırın kodu (3 haneli), sonra başlık, ihracat senaryosunda 301.</summary>
    private static int IstisnaKodu(Bel b, Sat s)
    {
        var kod = b.Tipi is 9 or 24 ? b.BasIstisna : 0;
        if (kod == 0 && s.Muafiyet >= 101) kod = s.Muafiyet;
        if (kod == 0) kod = b.BasIstisna;
        if (kod == 0 && b.Senaryo == 3) kod = 301;
        return kod;
    }

    private static List<Kalem> Kalemler(IEnumerable<Bel> belgeler, ILookup<int, Sat> satirlar, Dictionary<int, string> tevAd)
    {
        var l = new List<Kalem>();
        foreach (var b in belgeler)
        {
            var ss = satirlar[b.Id].ToList();
            if (ss.Count == 0)
            {
                // Satırsız belge: tek kalem; oran yalnız etiket (saklı toplamdan).
                var oran = b.Matrah != 0 ? (int)Math.Round(b.Kdv / b.Matrah * 100m) : 0;
                l.Add(new Kalem(b, null, oran, b.Matrah, b.Kdv, 0, "", 0, 0));
                continue;
            }
            var enBuyukOran = ss.Select((s, i) => (s.Oran, i)).OrderByDescending(x => x.Oran).First().i;
            var mat = Dagit(b.Matrah, ss.Select(s => s.Tutar).ToList(), 0);
            var kdv = Dagit(b.Kdv, ss.Select(s => s.KdvAgirlik).ToList(), enBuyukOran);
            for (var i = 0; i < ss.Count; i++)
            {
                var s = ss[i];
                var tk = "";
                decimal to = 0, tev = 0;
                if (b.Tipi == TipiTevkifat && kdv[i] > 0)
                {
                    tk = s.TevKod.Length > 0 ? s.TevKod
                        : b.BasTevkifat > 0 ? b.BasTevkifat.ToString(CultureInfo.InvariantCulture) : "";
                    if (tk.Length > 0)
                    {
                        to = s.TevOran > 0 ? s.TevOran
                            : EFaturaVerisi.TevkifatOrani(int.TryParse(tk, out var kn) && tevAd.TryGetValue(kn, out var ad) ? ad : "");
                        tev = Math.Round(kdv[i] * to / 100m, 2, MidpointRounding.AwayFromZero);
                    }
                }
                var ist = kdv[i] == 0 || s.Oran == 0 ? IstisnaKodu(b, s) : 0;
                l.Add(new Kalem(b, s, s.Oran, mat[i], kdv[i], tev, tk, to, ist));
            }
        }
        return l;
    }

    /// <summary>Oran tablosu: oran başına belge, matrah, KDV (+ tevkif edilen).</summary>
    private static object OranTablosu(List<Kalem> l, bool satis)
    {
        var top = l.Sum(k => k.Kdv);
        var satirlar = l.GroupBy(k => k.Oran).OrderByDescending(g => g.Key).Select(g =>
        {
            var kdv = g.Sum(k => k.Kdv);
            var istisna = g.Key == 0 && satis;
            return new
            {
                oran = g.Key, istisna, belge = g.Select(k => k.B.Id).Distinct().Count(), matrah = R(g.Sum(k => k.Matrah)),
                kdv = R(kdv), tevkif = R(g.Sum(k => k.Tevkif)), pay = g.Key == 0 ? (decimal?)null : Yuzde(kdv, top),
                satirsiz = g.Count(k => k.S is null),
            };
        }).ToList();
        return new
        {
            satirlar,
            toplam = new
            {
                belge = l.Select(k => k.B.Id).Distinct().Count(), matrah = R(l.Sum(k => k.Matrah)), kdv = R(top),
                tevkif = R(l.Sum(k => k.Tevkif)),
            },
        };
    }

    /// <summary>Hesap özeti (tahmin). Ödenecek eksiye düşerse sıfırdır, fark sonraki döneme devreder.</summary>
    private static (decimal hesaplanan, decimal satisTevkif, decimal satisIade, decimal indirilecek, decimal alisIade,
        decimal kdv2, decimal sonuc) Hesap(List<Kalem> l)
    {
        decimal S(Func<Kalem, bool> f, Func<Kalem, decimal> v) => l.Where(f).Sum(v);
        var hesaplanan = S(k => k.B.Satis && !k.B.Iade, k => k.Kdv);
        var satisTevkif = S(k => k.B.Satis && !k.B.Iade, k => k.Tevkif);
        var satisIade = S(k => k.B.Satis && k.B.Iade, k => k.Kdv);
        var indirilecek = S(k => !k.B.Satis && !k.B.Iade, k => k.Kdv);
        var alisIade = S(k => !k.B.Satis && k.B.Iade, k => k.Kdv);
        var kdv2 = S(k => !k.B.Satis && !k.B.Iade, k => k.Tevkif);
        // KDV-2 aynı dönemde hem beyan edilir hem indirilir: sonuca etkisi sıfır (iki satır ayrı gösterilir).
        var sonuc = hesaplanan - satisTevkif - satisIade - indirilecek + alisIade + kdv2 - kdv2;
        return (R(hesaplanan), R(satisTevkif), R(satisIade), R(indirilecek), R(alisIade), R(kdv2), R(sonuc));
    }

    /// <summary>
    /// AÇIK DÖNEMİN İLK GÜNÜ (EslesmeIcmalUclari ile aynı kural): `muhasebe.donem_kapanis_tarihi`
    /// (o gün dahil kapalı) varsa ertesi gün; yoksa içinde bulunulan ayın ilk günü.
    /// </summary>
    private static async Task<DateTime> AcikDonemBasiAsync(NpgsqlConnection b, NpgsqlTransaction? tx, DateTime bugun,
        CancellationToken iptal)
    {
        var ayar = (await AyarDeposu.MetinAsync(b, tx, "muhasebe.donem_kapanis_tarihi", "", iptal)).Trim();
        if (ayar.Length > 0 && DateTime.TryParseExact(ayar, ["yyyy-MM-dd", "dd.MM.yyyy", "yyyy-MM-ddTHH:mm:ss"],
                CultureInfo.InvariantCulture, DateTimeStyles.None, out var kapanis))
            return kapanis.Date.AddDays(1);
        return new DateTime(bugun.Year, bugun.Month, 1);
    }

    /// <summary>muhasebe_donem.kilitli = 1 olan aylar ('yyyy-MM').</summary>
    private static async Task<HashSet<string>> KilitliAylarAsync(NpgsqlConnection b, int[] subeler, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select d.yil::int, d.ay::int from public.muhasebe_donem d
             where d.kilitli = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[]))
            """, null, [subeler], o => (yil: o.GetInt32(0), ay: o.GetInt32(1)), iptal);
        return l.Where(x => x.ay is >= 1 and <= 12).Select(x => $"{x.yil:0000}-{x.ay:00}").ToHashSet();
    }

    /// <summary>Kullanıcının şubeleri VKN'ye göre gruplanmış (aynı VKN = tek mükellef).</summary>
    private static async Task<List<Mukellef>> MukelleflerAsync(NpgsqlConnection b, NpgsqlTransaction? tx,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var idler = baglam.Subeler.Select(s => s.Id).Distinct().ToArray();
        if (idler.Length == 0) return [];
        var l = await b.ListeAsync("""
            select s.id, coalesce(s.vkno, ''), coalesce(nullif(btrim(s.unvan), ''), s.ad, ''), coalesce(s.ad, ''),
                   (coalesce(s.efatura_mukellef, 0) > 0 or coalesce(s.earsiv_mukellef, 0) > 0)
              from public.sube s where s.id = any(@p0::int[])
             order by s.id
            """, tx, [idler], o => (id: o.GetInt32(0), vkn: Rakam(o.GetString(1)), unvan: o.GetString(2), ad: o.GetString(3),
                ebelge: o.GetBoolean(4)), iptal);
        return l.GroupBy(x => x.vkn).Select(g => new Mukellef(
                g.Key.Length > 0 ? g.Key : "-", g.Key, g.First().unvan,
                g.Select(x => (x.id, x.ad, x.ebelge)).ToList()))
            .OrderBy(m => m.Vkn.Length == 0 ? 1 : 0).ThenBy(m => m.Unvan, StringComparer.Create(Tr, true)).ToList();
    }

    /// <summary>Mükellefin şubelerinde KDV hesaplarına (190 / 191 / 391) hiç fiş yazılmış mı.</summary>
    private static async Task<bool> MuhasebeVarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int[] subeler, int subesiz,
        DateTime bit, CancellationToken iptal)
        => await b.TekDegerAsync<bool>("""
            select exists (
                select 1 from public.muhasebe_fis_satir s
                  join public.muhasebe_fis f on f.id = s.fis_id
                  join public.hesap_plani h on h.id = s.hesap_plani_id
                 where f.fis_tarihi <= @p0::date
                   and (f.sube_id = any(@p1::int[]) or (@p2 = 1 and coalesce(f.sube_id, 0) = 0))
                   and (h.kod in ('190', '191', '391') or h.kod like '190.%' or h.kod like '191.%' or h.kod like '391.%'))
            """, tx, [bit, subeler, subesiz], iptal);

    private static (DateTime bas, DateTime bit, string ad) DonemCoz(string? donem, DateTime bugun)
    {
        var d = (donem ?? "").Trim();
        if (d.Length == 0) return (new DateTime(bugun.Year, bugun.Month, 1), new DateTime(bugun.Year, bugun.Month, 1).AddMonths(1).AddDays(-1), Ay(bugun));
        if (!Regex.IsMatch(d, @"^\d{4}-\d{2}$") || !DateTime.TryParseExact(d + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var bas) || bas.Year < 2000)
            throw GentegreHatasi.Dogrulama("Dönem yyyy-AA biçiminde olmalı.", new AlanHatasi("donem", "Geçersiz dönem."));
        return (bas, bas.AddMonths(1).AddDays(-1), d);
    }

    private static object? DevredenSatiri((long id, string vkn, string donem, decimal tutar, string aciklama, DateTime? tarih, string surum)? x)
        => x is { } v ? new { v.id, v.vkn, v.donem, v.tutar, v.aciklama, degistirmeTarihi = v.tarih, v.surum } : null;

    private static async Task<(long id, string vkn, string donem, decimal tutar, string aciklama, DateTime? tarih, string surum)?> DevredenOkuAsync(
        NpgsqlConnection b, NpgsqlTransaction? tx, string vkn, string donem, bool kilitle, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select d.id, d.vkn, d.donem::varchar(7), d.tutar, d.aciklama, coalesce(d.degistirme_tarihi, d.ekleme_tarihi), d.xmin::text
              from public.kdv_devreden d where d.vkn = @p0 and d.donem = @p1
            """ + (kilitle ? " for update" : ""), tx, [vkn, donem], o => (id: o.GetInt64(0), vkn: o.GetString(1), donem: o.GetString(2),
                tutar: o.GetDecimal(3), aciklama: o.GetString(4), tarih: o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                surum: o.GetString(6)), iptal);
        return l.Count > 0 ? l[0] : null;
    }

    // ================================================================== uçlar ===

    public static void KdvIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kdv-icmal").WithTags("KDV İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (string? donem, string? vkn, int? sube, string? ebelge, string? tur, int? taslak,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var (bas, bit, donemAdi) = DonemCoz(donem, bugun);
            var eb = ebelge is "efatura" or "earsiv" or "kagit" ? ebelge : "hepsi";
            var bt = tur is "fatura" or "fis" ? tur : "tumu";
            var tsl = (taslak ?? 0) == 1;
            var kapsam = baglam.Kapsam.ToArray();

            await using var b = await veri.AcAsync(iptal);

            // ------------------------------------------------------- mükellef --
            var mukellefler = await MukelleflerAsync(b, null, baglam, iptal);
            if (mukellefler.Count == 0) throw GentegreHatasi.Yasak("Yetkili olduğunuz şube yok.");
            var istenen = (vkn ?? "").Trim();
            var muk = istenen.Length > 0
                ? mukellefler.FirstOrDefault(m => m.Anahtar == (istenen == "-" ? "-" : Rakam(istenen)))
                  ?? throw GentegreHatasi.Bulunamadi("Mükellef bulunamadı.")
                : mukellefler.FirstOrDefault(m => m.Subeler.Any(s => s.Id == baglam.SubeId)) ?? mukellefler[0];
            var s0 = sube ?? 0;
            if (s0 > 0 && muk.Subeler.All(s => s.Id != s0)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
            var mukSubeler = muk.Subeler.Select(s => s.Id).ToArray();
            int[] subeler = s0 > 0 ? [s0] : mukSubeler;
            // Şubesiz belge yalnız tek mükellefte o mükellefindir.
            var subesiz = mukellefler.Count == 1 && s0 == 0 ? 1 : 0;
            var mukSubesiz = mukellefler.Count == 1 ? 1 : 0;

            // ------------------------------------------------------- belgeler --
            var ham = await b.ListeAsync(BelgeSorgusu, null, [Turler, bas, bit, subeler, subesiz, kapsam], o => new Bel(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetDateTime(4), o.GetInt32(5), o.GetString(6),
                Rakam(o.GetString(7)), o.GetInt32(8), o.GetDecimal(9), o.GetDecimal(10), o.GetInt32(11), o.GetInt32(12),
                o.GetInt32(13), o.GetInt32(14), o.GetInt32(15), o.GetInt32(16), o.GetInt32(17), o.GetString(18), o.GetString(19),
                o.GetBoolean(20), o.GetBoolean(21), o.GetString(22), o.GetDecimal(23)), iptal);
            bool Uyar(Bel x) => (eb == "hepsi" || x.ETur == eb) && (bt == "tumu" || (bt == "fatura") == x.Fatura);
            var kesin = ham.Where(x => !x.Taslak && Uyar(x)).ToList();
            var taslaklar = ham.Where(x => x.Taslak && Uyar(x)).ToList();

            var satirIdler = kesin.Concat(tsl ? taslaklar : new List<Bel>()).Select(x => x.Id).Distinct().ToArray();
            var satirlar = satirIdler.Length == 0 ? []
                : await b.ListeAsync(SatirSorgusu, null, [satirIdler], o => new Sat(
                    o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetDecimal(3), o.GetDecimal(4), o.GetInt32(5), o.GetString(6),
                    o.GetDecimal(7), o.GetString(8), o.GetString(9), o.IsDBNull(10) ? null : o.GetInt32(10)), iptal);
            var satirLookup = satirlar.ToLookup(x => x.BelgeId);

            var adlar = await b.ListeAsync("""
                select l.kod, d.deger::int, d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                 where l.kod in ('belge.tevkifat', 'belge.kdv_muafiyeti', 'belge.ihrac_kayitli') and d.dil = 0
                """, null, null, o => (liste: o.GetString(0), kod: o.GetInt32(1), ad: o.GetString(2)), iptal);
            var tevAd = adlar.Where(x => x.liste == "belge.tevkifat").GroupBy(x => x.kod).ToDictionary(g => g.Key, g => g.First().ad);
            string IstisnaAdi(int kod) => adlar.FirstOrDefault(x => x.kod == kod
                && x.liste == (kod is >= 701 and <= 704 ? "belge.ihrac_kayitli" : "belge.kdv_muafiyeti")).ad ?? "(kod listesinde yok)";
            string TevkifatAdi(string kod) => int.TryParse(kod, out var k) && tevAd.TryGetValue(k, out var a) ? a : kod;

            var kalemler = Kalemler(kesin, satirLookup, tevAd);
            var h = Hesap(kalemler);
            var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, null, iptal) ?? "TL";

            // ------------------------------------------------ dönem kapanışı --
            var acikDonemBasi = await AcikDonemBasiAsync(b, null, bugun, iptal);
            var kilitli = await KilitliAylarAsync(b, mukSubeler, iptal);
            bool AyKapali(DateTime ay)
            {
                var ilk = new DateTime(ay.Year, ay.Month, 1);
                return ilk.AddMonths(1) <= acikDonemBasi || kilitli.Contains(Ay(ilk));
            }

            // ------------------------------------------------------- devreden --
            var muhasebeVar = await MuhasebeVarAsync(b, null, mukSubeler, mukSubesiz, bit, iptal);
            decimal? bakiye190 = null;
            if (muhasebeVar)
                bakiye190 = R(await b.TekDegerAsync<decimal>("""
                    select coalesce(sum(s.borc - s.alacak), 0)
                      from public.muhasebe_fis_satir s
                      join public.muhasebe_fis f on f.id = s.fis_id
                      join public.hesap_plani h on h.id = s.hesap_plani_id
                     where f.fis_tarihi < @p0::date
                       and (f.sube_id = any(@p1::int[]) or (@p2 = 1 and coalesce(f.sube_id, 0) = 0))
                       and (h.kod = '190' or h.kod like '190.%')
                    """, null, [bas, mukSubeler, mukSubesiz], iptal));
            var elle = muk.Vkn.Length > 0 ? await DevredenOkuAsync(b, null, muk.Vkn, donemAdi, false, iptal) : null;
            var devredenKaynak = muhasebeVar ? "muhasebe" : elle is not null ? "elle" : "yok";
            var devredenTutar = muhasebeVar ? Math.Max(0, bakiye190 ?? 0) : elle?.tutar ?? 0;
            var ham0 = h.sonuc - devredenTutar;
            var odenecek = Math.Max(0, ham0);
            var sonrakiDevreden = Math.Max(0, -ham0);

            // ------------------------------------------------------ tevkifat --
            var tevkifat = kalemler.Where(k => k.Tevkif > 0 && !k.B.Iade).GroupBy(k => (k.B.Id, k.TevKod))
                .Select(g =>
                {
                    var f = g.First();
                    var kdv = g.Sum(k => k.Kdv);
                    var tev = g.Sum(k => k.Tevkif);
                    return new
                    {
                        belgeId = f.B.Id, no = f.B.No, tarih = f.B.Tarih, tarafId = f.B.TarafId, taraf = f.B.Taraf,
                        yon = f.B.Satis ? "satis" : "alis", kod = f.TevKod, kodAdi = TevkifatAdi(f.TevKod), oran = f.TevOran,
                        matrah = R(g.Sum(k => k.Matrah)), kdv = R(kdv), tevkif = R(tev), odenen = R(kdv - tev),
                    };
                }).OrderBy(x => x.yon == "alis" ? 0 : 1).ThenBy(x => x.tarih).ThenBy(x => x.no).ToList();

            // ------------------------------------------------------- istisna --
            var istisnaKalem = kalemler.Where(k => k.B.Satis && !k.B.Iade && k.S is not null && k.Kdv == 0 && k.Matrah != 0).ToList();
            var istisna = istisnaKalem.Where(k => k.IstisnaKod > 0).GroupBy(k => k.IstisnaKod).OrderBy(g => g.Key).Select(g => new
            {
                kod = g.Key, ad = IstisnaAdi(g.Key), belge = g.Select(k => k.B.Id).Distinct().Count(), matrah = R(g.Sum(k => k.Matrah)),
                doviz = g.Where(k => k.B.Para != yerel && k.B.Kur > 0).GroupBy(k => k.B.Para)
                    .Select(x => new { para = x.Key, tutar = R(x.Sum(k => k.Matrah / k.B.Kur)) }).ToList(),
            }).ToList();
            var kodsuz = istisnaKalem.Where(k => k.IstisnaKod == 0).ToList();

            // ---------------------------------------------------------- iade --
            var iadeler = kesin.Where(x => x.Iade).OrderBy(x => x.Tarih).ThenBy(x => x.No).Select(x => new
            {
                belgeId = x.Id, no = x.No, tarih = x.Tarih, tarafId = x.TarafId, taraf = x.Taraf, yon = x.Satis ? "satis" : "alis",
                iadeEdilenId = x.IadeBelgeId > 0 ? x.IadeBelgeId : (int?)null, iadeEdilenNo = x.IadeBelgeNo,
                matrah = -R(x.Matrah), kdv = -R(x.Kdv), bagsiz = x.IadeBelgeId <= 0,
            }).ToList();

            // --------------------------------------------------------- Ba/Bs --
            var sinirMetin = (await AyarDeposu.MetinAsync(b, null, "muhasebe.babs_sinir", "", iptal)).Trim().Replace(',', '.');
            var sinir = decimal.TryParse(sinirMetin, NumberStyles.Number, CultureInfo.InvariantCulture, out var sn) && sn > 0 ? sn : 5000m;
            static string VknDurum(string v) => v.Length == 0 ? "eksik" : v.Length is 10 or 11 ? "tamam" : "hatali";
            var babs = kesin.Where(x => x.Fatura).GroupBy(x => (form: x.Giden ? "Bs" : "Ba", x.TarafId, x.Vkn))
                .Select(g => new
                {
                    g.Key.form, g.Key.TarafId, taraf = g.First().Taraf, vkn = g.Key.Vkn, belge = g.Count(),
                    tutar = R(g.Sum(x => x.Matrah)), durum = VknDurum(g.Key.Vkn),
                })
                .Where(x => x.tutar >= sinir)
                .OrderBy(x => x.form == "Bs" ? 0 : 1).ThenBy(x => x.durum == "tamam" ? 1 : 0).ThenByDescending(x => x.tutar)
                .Select(x => new { x.form, tarafId = x.TarafId, x.taraf, x.vkn, x.belge, x.tutar, x.durum }).ToList();

            // ------------------------------------------------------ uyarılar --
            var uyarilar = new List<UyariSatiri>();
            void UyariEkle(string tip, string seviye, int? belgeId, string no, DateTime? tarih, int tarafId, string taraf,
                string aciklama, string oneri, decimal? tutar)
                => uyarilar.Add(new UyariSatiri(tip, seviye, belgeId, no, tarih, tarafId, taraf, aciklama, oneri,
                    tutar is { } t ? R(t) : null));
            void Uyari(string tip, string seviye, Bel? x, string aciklama, string oneri, decimal? tutar = null, DateTime? tarih = null)
                => UyariEkle(tip, seviye, x?.Id, x?.No ?? "", tarih ?? x?.Tarih, x?.TarafId ?? 0, x?.Taraf ?? "", aciklama, oneri, tutar);

            var ebelgeSube = muk.Subeler.Where(s => s.EBelge).Select(s => s.Id).ToHashSet();
            var ebelgeMukellef = ebelgeSube.Count > 0;
            foreach (var x in kesin.Where(y => y.Giden))
            {
                var ad = x.EDurum is 11 or 12 ? "e-Arşiv" : "e-Fatura";
                if (x.Yanit is "REJECTED" or "DECLINED" or "PARTIAL_REJECTED")
                    Uyari("gib", "kir", x, $"{ad} ret yanıtı aldı", "Belgeyi aç", x.Kdv);
                else if (x.EDurum is 1 or 11 && x.ESonuc == 3)
                    Uyari("gib", "kir", x, $"{ad} gönderim hatası", "e-Belge'ye git", x.Kdv);
                else if (x.EDurum is 1 or 11)
                    Uyari("gib", "kir", x, $"{ad} hazırlandı, gönderilmedi", "e-Belge'ye git", x.Kdv);
                else if (x.EDurum == 0 && (x.SubeId > 0 ? ebelgeSube.Contains(x.SubeId) : ebelgeMukellef))
                    Uyari("gib", "kir", x, "e-Belge hazırlanmadı (şube e-Belge mükellefi)", "e-Belge'ye git", x.Kdv);
            }
            foreach (var g in kalemler.Where(k => !k.B.Iade && k.S is not null && k.S.Oran == 0 && k.IstisnaKod == 0 && k.Matrah != 0).GroupBy(k => k.B.Id))
            {
                var f = g.First();
                Uyari("kdvsiz", "kir", f.B, $"KDV %0, muafiyet kodu yok ({g.Count()} satır: {string.Join(", ", g.Take(2).Select(k => k.S!.Ad))}{(g.Count() > 2 ? " …" : "")})",
                    "oran ya da kod gir", g.Sum(k => k.Matrah));
            }
            foreach (var g in kalemler.Where(k => k.S is { KartKdv: not null } && !k.B.Iade && k.IstisnaKod == 0
                                                  && k.B.Tipi is not (9 or 24 or 26) && k.B.Senaryo != 3
                                                  && k.S.Oran != k.S.KartKdv && !(k.S.Oran == 0 && k.S.KartKdv == 0))
                                      .GroupBy(k => k.B.Id))
            {
                var s = g.First().S!;
                Uyari("oran", "sari", g.First().B,
                    $"{s.Ad} satırında %{s.Oran} — kartında %{s.KartKdv}{(g.Count() > 1 ? $" (+{g.Count() - 1} satır)" : "")}", "kontrol et");
            }
            foreach (var x in kesin.Where(y => y.Iade && y.IadeBelgeId <= 0))
                Uyari("iade", "sari", x, "İade faturasının orijinal belge bağı yok", "orijinal faturayı bağla", x.Kdv);
            foreach (var x in babs.Where(y => y.durum != "tamam"))
                UyariEkle("babs", "sari", null, "", null, x.tarafId, x.taraf,
                    $"{x.form} sınırını aşıyor ({x.belge} belge · {x.tutar.ToString("N2", Tr)} ₺), VKN / TCKN {(x.durum == "eksik" ? "eksik" : "hatalı")}",
                    "cari kartına vergi no gir", x.tutar);

            // FATURA TARİHİ ÖNCEKİ AY, KAYDI BU AY (karar): belge tarihine yazılır; kapanmış aya düşüyorsa işaret.
            var gecKayit = await b.ListeAsync("""
                select b.id, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi::date, coalesce(b.taraf_id, 0),
                       coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
                       coalesce(b.kdv_tutari, 0), coalesce(b.kayit_tarihi, b.ekleme_tarihi)::date
                  from public.belge b left join public.taraf t on t.id = b.taraf_id
                 where b.tur = any(@p0::int[]) and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                   and b.belge_tarihi < @p1::date
                   and coalesce(b.kayit_tarihi, b.ekleme_tarihi) >= @p1::date and coalesce(b.kayit_tarihi, b.ekleme_tarihi) < @p2::date + 1
                   and (b.sube_id = any(@p3::int[]) or (@p4 = 1 and b.sube_id is null))
                   and (cardinality(@p5::int[]) = 0 or b.taraf_id = any(@p5::int[]))
                 order by b.belge_tarihi, b.id
                 limit 500
                """, null, [AlisTurleri, bas, bit, subeler, subesiz, kapsam], o => new
                {
                    id = o.GetInt32(0), no = o.GetString(1), tarih = o.GetDateTime(2), taraf = o.GetInt32(3), ad = o.GetString(4),
                    kdv = o.GetDecimal(5), kayit = o.GetDateTime(6),
                }, iptal);
            decimal kapanmisIndirilecek = 0;
            foreach (var x in gecKayit)
            {
                var kapali = AyKapali(x.tarih);
                if (kapali) kapanmisIndirilecek += x.kdv;
                UyariEkle("tarih", "sari", x.id, x.no, x.tarih, x.taraf, x.ad,
                    $"fatura tarihi {x.tarih:dd.MM.yyyy}, kayıt {x.kayit:dd.MM.yyyy}" + (kapali
                        ? $" — {AyAdi(x.tarih)} dönemi kapanmış, bu aya indirilecek"
                        : $" — {AyAdi(x.tarih)} icmaline yazıldı (belge tarihi esas)"),
                    kapali ? "müşavire bildir" : $"{AyAdi(x.tarih)} icmalini kontrol et", x.kdv);
            }

            // Şubesiz belge (birden çok mükellefte hiçbirine sayılmaz).
            if (mukellefler.Count > 1 && s0 == 0)
            {
                var n = await b.TekDegerAsync<int>("""
                    select count(*)::int from public.belge b
                     where b.tur = any(@p0::int[]) and b.durum = 0 and b.sube_id is null
                       and b.belge_tarihi >= @p1::date and b.belge_tarihi < @p2::date + 1
                    """, null, [Turler, bas, bit], iptal);
                if (n > 0) Uyari("subesiz", "sari", null, $"Şubesiz {n} belge: mükellef (VKN) belirlenemedi, hiçbir icmale girmedi",
                    "belgeye şube gir", tarih: bas);
            }

            var tahakkuk = await b.ListeAsync("""
                select count(*)::int, coalesce(sum(b.genel_toplam), 0) from public.belge b
                 where b.tur in (13, 17) and b.durum = 0
                   and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
                   and (b.sube_id = any(@p2::int[]) or (@p3 = 1 and b.sube_id is null))
                """, null, [bas, bit, subeler, subesiz], o => (n: o.GetInt32(0), t: o.GetDecimal(1)), iptal);
            if (tahakkuk.Count > 0 && tahakkuk[0].n > 0)
                Uyari("aktarim", "mavi", null, $"Delphi'den satırsız aktarılan {tahakkuk[0].n} tahakkuk bu ayda (KDV ayrıntısı yok, icmale girmez)",
                    "etkisi yok", tahakkuk[0].t, bas);
            if (!tsl && taslaklar.Count > 0)
                Uyari("taslak", "mavi", null, $"{taslaklar.Count} taslak belge bu dönemde — icmale girmedi",
                    "\"Taslaklar dahil\" ile ön izle", tarih: bas);

            // --------------------------------------------------- muhasebe bağı --
            var muh = muhasebeVar
                ? await b.ListeAsync(MuhasebeSorgusu, null, [bas, bit, mukSubeler, mukSubesiz],
                    o => (kok: o.GetString(0), belgeden: o.GetBoolean(1), borc: o.GetDecimal(2), alacak: o.GetDecimal(3)), iptal)
                : [];
            var fislenmemis = kesin.Where(x => !x.Fisli && x.Kdv != 0).ToList();
            object MuhSatir(string kok, string ad, decimal icmal, bool alacakli)
            {
                decimal Hareket(bool belgeden) => muh.Where(m => m.kok == kok && m.belgeden == belgeden)
                    .Sum(m => alacakli ? m.alacak - m.borc : m.borc - m.alacak);
                var belgeden = R(Hareket(true));
                var diger = R(Hareket(false));
                var fark = R(icmal - belgeden);
                return new
                {
                    hesap = kok, ad, icmal = R(icmal), muhasebe = belgeden, diger, fark,
                    durum = Math.Abs(fark) < 0.01m ? "tutuyor" : "fark",
                };
            }
            var muhasebe = new
            {
                kullaniliyor = muhasebeVar,
                satirlar = muhasebeVar
                    ? new List<object>
                    {
                        MuhSatir("391", "Hesaplanan KDV", h.hesaplanan - h.satisTevkif - h.satisIade, true),
                        MuhSatir("191", "İndirilecek KDV", h.indirilecek - h.alisIade, false),
                        MuhSatir("360", "Ödenecek vergi ve fonlar (KDV-2)", h.kdv2, true),
                    }
                    : [],
                fislenmemisSayi = muhasebeVar ? fislenmemis.Count : 0,
                fislenmemis = muhasebeVar
                    ? fislenmemis.Take(200).Select(x => new
                    {
                        belgeId = x.Id, no = x.No, tarih = x.Tarih, tarafId = x.TarafId, taraf = x.Taraf, yon = x.Yon, kdv = R(x.Kdv),
                    }).ToList<object>()
                    : [],
            };

            // ------------------------------------------------------- taslak --
            object? taslakBlok = null;
            if (tsl)
            {
                var tk = Kalemler(taslaklar, satirLookup, tevAd);
                var th = Hesap(tk);
                taslakBlok = new
                {
                    belge = taslaklar.Count, satisBelge = taslaklar.Count(x => x.Satis), alisBelge = taslaklar.Count(x => !x.Satis),
                    th.hesaplanan, th.satisTevkif, th.satisIade, th.indirilecek, th.alisIade, th.kdv2, etki = th.sonuc,
                    satis = OranTablosu(tk.Where(k => k.B.Satis && !k.B.Iade).ToList(), true),
                    alis = OranTablosu(tk.Where(k => !k.B.Satis && !k.B.Iade).ToList(), false),
                };
            }

            // ---------------------------------------------------------- özet --
            var satisK = kalemler.Where(k => k.B.Satis && !k.B.Iade).ToList();
            var alisK = kalemler.Where(k => !k.B.Satis && !k.B.Iade).ToList();
            var uyariSay = uyarilar.GroupBy(u => u.Tur).ToDictionary(g => g.Key, g => g.Count());
            var ozet = new
            {
                hesaplanan = R(h.hesaplanan - h.satisTevkif), hesaplananMatrah = R(satisK.Sum(k => k.Matrah)),
                indirilecek = h.indirilecek, indirilecekMatrah = R(alisK.Sum(k => k.Matrah)),
                tevkifat = h.kdv2, tevkifatBelge = tevkifat.Where(x => x.yon == "alis").Select(x => x.belgeId).Distinct().Count(),
                satisTevkif = h.satisTevkif,
                odenecek = R(odenecek), sonrakiDevreden = R(sonrakiDevreden), devreden = R(devredenTutar), devredenKaynak,
                istisnaMatrah = R(istisna.Sum(x => x.matrah)), istisnaKodlar = istisna.Select(x => x.kod).ToList(),
                iadeKdv = h.satisIade, alisIadeKdv = h.alisIade, iadeBelge = kesin.Count(x => x.Iade),
                satisIadeBelge = kesin.Count(x => x.Iade && x.Satis),
                belge = kesin.Count, satisBelge = kesin.Count(x => x.Satis && !x.Iade), alisBelge = kesin.Count(x => !x.Satis && !x.Iade),
                uyari = uyarilar.Count(u => u.Seviye != "mavi"), uyariKir = uyarilar.Count(u => u.Seviye == "kir"),
                bilgi = uyarilar.Count(u => u.Seviye == "mavi"), uyariSayilari = uyariSay, kapanmisIndirilecek = R(kapanmisIndirilecek),
            };

            var hesap = new
            {
                hesaplanan = h.hesaplanan, satisTevkif = h.satisTevkif, satisIade = h.satisIade, indirilecek = h.indirilecek,
                alisIade = h.alisIade, kdv2 = h.kdv2, kdv2Indirim = h.kdv2, devreden = R(devredenTutar),
                sonuc = h.sonuc, odenecek = R(odenecek), sonrakiDevreden = R(sonrakiDevreden),
                kapanmisIndirilecek = R(kapanmisIndirilecek),
            };

            // ------------------------------------------------- müşavir dökümü --
            var belgeKdv = kalemler.GroupBy(k => k.B.Id).ToDictionary(g => g.Key, g => (tev: g.Sum(k => k.Tevkif),
                oranlar: string.Join(" · ", g.GroupBy(k => k.Oran).OrderByDescending(x => x.Key).Select(x => $"%{x.Key}"))));
            var belgeler = kesin.Take(5000).Select(x => new
            {
                id = x.Id, no = x.No, tarih = x.Tarih, x.Tur, x.Tipi, yon = x.Yon, tarafId = x.TarafId, taraf = x.Taraf, vkn = x.Vkn,
                eTur = x.ETur, matrah = R(x.Matrah), kdv = R(x.Kdv), tevkif = R(belgeKdv.GetValueOrDefault(x.Id).tev),
                oranlar = belgeKdv.GetValueOrDefault(x.Id).oranlar ?? "", para = x.Para, fisli = x.Fisli,
            }).ToList();

            var donemler = Enumerable.Range(0, 24).Select(i =>
            {
                var a = new DateTime(bugun.Year, bugun.Month, 1).AddMonths(-i);
                return new { donem = Ay(a), ad = AyAdi(a), kapali = AyKapali(a) };
            }).ToList();

            var siraliUyari = uyarilar.Select((u, i) => (u, i))
                .OrderBy(x => x.u.Seviye switch { "kir" => 0, "sari" => 1, _ => 2 }).ThenBy(x => x.i)
                .Select(x => x.u).ToList();

            return Results.Ok(new
            {
                donem = donemAdi, donemAd = AyAdi(bas), bas, bit, donemKapali = AyKapali(bas), acikDonemBasi,
                vkn = muk.Anahtar, sube = s0, ebelge = eb, tur = bt, taslak = tsl,
                suzgecli = eb != "hepsi" || bt != "tumu" || s0 > 0, kapsamli = kapsam.Length > 0, yerelPara = yerel,
                mukellef = new { anahtar = muk.Anahtar, vkn = muk.Vkn, unvan = muk.Unvan, subeler = muk.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList() },
                ozet, hesap,
                oran = new { satis = OranTablosu(satisK, true), alis = OranTablosu(alisK, false) },
                devreden = new
                {
                    kaynak = devredenKaynak, tutar = R(devredenTutar), muhasebeKullaniliyor = muhasebeVar, bakiye190,
                    elle = DevredenSatiri(elle), duzenlenebilir = !muhasebeVar && muk.Vkn.Length > 0,
                },
                taslakSayisi = taslaklar.Count, taslakBlok,
                tevkifat = new
                {
                    satirlar = tevkifat,
                    toplam = new
                    {
                        belge = tevkifat.Select(x => x.belgeId).Distinct().Count(), matrah = R(tevkifat.Sum(x => x.matrah)),
                        kdv = R(tevkifat.Sum(x => x.kdv)), tevkif = R(tevkifat.Sum(x => x.tevkif)), odenen = R(tevkifat.Sum(x => x.odenen)),
                    },
                },
                istisna = new
                {
                    satirlar = istisna,
                    toplam = new { belge = istisna.Sum(x => x.belge), matrah = R(istisna.Sum(x => x.matrah)) },
                    kodsuzSatir = kodsuz.Count, kodsuzMatrah = R(kodsuz.Sum(k => k.Matrah)),
                },
                iade = new
                {
                    satirlar = iadeler,
                    toplam = new { belge = iadeler.Count, satisKdv = h.satisIade, alisKdv = h.alisIade, bagsiz = iadeler.Count(x => x.bagsiz) },
                },
                babs = new
                {
                    sinir, satirlar = babs, bs = babs.Count(x => x.form == "Bs"), ba = babs.Count(x => x.form == "Ba"),
                    eksik = babs.Count(x => x.durum != "tamam"),
                },
                uyarilar = siraliUyari.Take(500).ToList(), uyariToplam = uyarilar.Count,
                muhasebe, belgeler, belgeToplam = kesin.Count,
                secim = new
                {
                    mukellefler = mukellefler.Select(m => new
                    {
                        anahtar = m.Anahtar, vkn = m.Vkn, unvan = m.Unvan, subeler = m.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    }).ToList(),
                    donemler,
                },
                yetkiler = new
                {
                    devredenDuzenle = baglam.Yetkiler.Var(KodDevreden, Islem.Degistir) && baglam.SubeYazma && !muhasebeVar && muk.Vkn.Length > 0,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ============================================================ DEVREDEN ===
        grup.MapGet("/devreden", async (string? vkn, string? donem, VeriKaynagi veri, BaglamCozucu cozucu,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var (_, _, donemAdi) = DonemCoz(donem, Saat.BugunDilim(baglam.ZamanDilimi));
            await using var b = await veri.AcAsync(iptal);
            var v = Rakam(vkn);
            var muk = (await MukelleflerAsync(b, null, baglam, iptal)).FirstOrDefault(m => m.Vkn.Length > 0 && m.Vkn == v)
                      ?? throw GentegreHatasi.Bulunamadi("Mükellef bulunamadı.");
            var x = await DevredenOkuAsync(b, null, muk.Vkn, donemAdi, false, iptal);
            return Results.Ok(new { vkn = muk.Vkn, donem = donemAdi, kayit = DevredenSatiri(x), izlemeNo = baglam.IzlemeNo });
        });

        // Elle devreden (muhasebe kullanılmıyorsa). VKN + dönem başına bir değer; upsert, alan bazlı log.
        //   YETKİ: icmal kodu (Gör) + muhasebe_fis Değiştir - icmal kodu 1176'da yalnız Gör taşır (1003
        //   ilkesi: ekran kodu ekranın görünürlüğüdür); devreden beyan sonucunu değiştiren muhasebe
        //   verisidir, muhasebe fişini değiştirebilen rol yazar.
        grup.MapPut("/devreden", async (DevredenIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste(KodDevreden, Islem.Degistir);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            if (string.IsNullOrWhiteSpace(istek.Donem))
                throw GentegreHatasi.Dogrulama("Dönem seçilmeli.", new AlanHatasi("donem", "Zorunlu."));
            var (bas, bit, donemAdi) = DonemCoz(istek.Donem, bugun);
            if (istek.Tutar < 0) throw GentegreHatasi.Dogrulama("Devreden KDV eksi olamaz.", new AlanHatasi("tutar", "0 ya da büyük olmalı."));
            if (istek.Tutar > 9_999_999_999_999m) throw GentegreHatasi.Dogrulama("Tutar çok büyük.", new AlanHatasi("tutar", "Geçersiz."));
            var tutar = Math.Round(istek.Tutar, 2);
            var aciklama = (istek.Aciklama ?? "").Trim();
            if (aciklama.Length > 300) throw GentegreHatasi.Dogrulama("Açıklama en çok 300 karakter.", new AlanHatasi("aciklama", "En çok 300 karakter."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var mukellefler = await MukelleflerAsync(b, tx, baglam, iptal);
            var v = Rakam(istek.Vkn);
            if (v.Length == 0) throw GentegreHatasi.Dogrulama("Mükellefin VKN'si yok: şube kartına vergi numarası girin.", new AlanHatasi("vkn", "Zorunlu."));
            var muk = mukellefler.FirstOrDefault(m => m.Vkn == v) ?? throw GentegreHatasi.Bulunamadi("Mükellef bulunamadı.");
            var mukSubeler = muk.Subeler.Select(s => s.Id).ToArray();
            if (await MuhasebeVarAsync(b, tx, mukSubeler, mukellefler.Count == 1 ? 1 : 0, bit, iptal))
                throw GentegreHatasi.IsKurali("Bu mükellefte muhasebe kullanılıyor: devreden KDV 190 hesabının bakiyesinden gelir, elle girilmez.");

            var eski = await DevredenOkuAsync(b, tx, muk.Vkn, donemAdi, true, iptal);
            var surum = (istek.Surum ?? "").Trim();
            if (eski is { } e0 && surum.Length > 0 && surum != e0.surum)
                throw GentegreHatasi.Cakisma(DevredenSatiri(eski));

            var acikDonemBasi = await AcikDonemBasiAsync(b, tx, bugun, iptal);
            var kapali = bas.AddMonths(1) <= acikDonemBasi;
            if (eski is null)
            {
                var id = await b.TekDegerAsync<long>("""
                    insert into public.kdv_devreden (vkn, donem, tutar, aciklama, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4)
                    returning id
                    """, tx, [muk.Vkn, donemAdi, tutar, aciklama, baglam.KullaniciId], iptal);
                await log.YazAsync(b, tx, LogIslemi.Ekle, LogTabloKdvDevreden, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["vkn"] = muk.Vkn, ["donem"] = donemAdi, ["tutar"] = LogDeposu.Metin(tutar), ["aciklama"] = aciklama,
                        ["kapanmisDonem"] = kapali ? "evet" : "hayır", ["kaynak"] = "kdv-icmali",
                    }, iptal: iptal);
            }
            else
            {
                var e = eski.Value;
                var fark = LogDeposu.Fark(
                    new Dictionary<string, object?> { ["tutar"] = e.tutar, ["aciklama"] = e.aciklama },
                    new Dictionary<string, object?> { ["tutar"] = tutar, ["aciklama"] = aciklama });
                if (fark is not null)
                {
                    await b.CalistirAsync("""
                        update public.kdv_devreden
                           set tutar = @p1, aciklama = @p2, degistiren = @p3, degistirme_tarihi = now()
                         where id = @p0
                        """, tx, [e.id, tutar, aciklama, baglam.KullaniciId], iptal);
                    fark["vkn"] = muk.Vkn;
                    fark["donem"] = donemAdi;
                    fark["kapanmisDonem"] = kapali ? "evet" : "hayır";
                    fark["kaynak"] = "kdv-icmali";
                    await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloKdvDevreden, e.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                        fark, iptal: iptal);
                }
            }

            var yeni = await DevredenOkuAsync(b, tx, muk.Vkn, donemAdi, false, iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { vkn = muk.Vkn, donem = donemAdi, kayit = DevredenSatiri(yeni), kapanmisDonem = kapali, izlemeNo = baglam.IzlemeNo });
        });
    }
}
