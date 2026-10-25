using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATIŞ / ALIŞ İCMALİ (mockup Ekranlar/İcmal/satis_icmali.html, alis_icmali.html - kullanıcı
/// 25.10.2026, kararlar mockup altında).
///
/// <para><b>Küme:</b> kesin (durum 0; "taslak dahil" ile 1) satış faturası / fişi (15, 16) ya da
/// alış faturası / fişi (11, 12) + aynı türlerin iadeleri (tipi 2). İrsaliye (14 / 10) sayılmaz:
/// irsaliyeden türeyen fatura böylece BİR KEZ sayılır; faturası kesilmemiş irsaliye Dikkat'te.
/// Gelen konsinye (109) ve gelen e-Fatura kutusunda bekleyen (henüz kaydedilmemiş) fatura alışa
/// GİRMEZ - ikincisi Dikkat'te ayrı listelenir.</para>
///
/// <para><b>Tutar:</b> belgenin dip toplamı - `belge.matrah` (KDV hariç) / `belge.genel_toplam`
/// (KDV dahil), ikisi de fn_belge_diptoplam'ın yazdığı (BelgeDeposu.ToplamlariYazAsync). Ekran ve
/// bu uç satır toplamı YENİDEN HESAPLAMAZ: kalem / kategori kırılımında belgenin dip toplamı
/// satırlara satır tutarı oranında DAĞITILIR (toplamı birebir belge toplamıdır). İskonto =
/// satırın adet × birim fiyatı − tutarı (İskonto İcmali ile aynı formül); brüt = net + iskonto.</para>
///
/// <para><b>Döviz (karar 25.10.2026):</b> rakamlar TL, belgenin kendi kuruyla (faturanın yasal
/// TL tutarı). Tek döviz seçilirse yalnız o dövizdeki belgeler o dövizin cinsinden (TL / belge
/// kuru) - karışık para toplanmaz. Para birimi tablosu: döviz tutarı, ortalama kur, TL karşılığı;
/// bugünkü kurla değer ve kur farkı yalnız AÇIK alacak / borç için (v_cari_ekstre döviz
/// bakiyesi) - tahsil / ödeme edilenin kur farkı gerçekleşmiştir.</para>
///
/// <para><b>Satış:</b> temsilci BELGEDEN (belge.satici_id; yoksa "(temsilcisiz)" - cari
/// kartındaki temsilciye düşülmez). Brüt kâr = net satış − satılan malın ortalama maliyeti
/// (fn_uretim_stok_maliyeti - Stok Değer İcmali ile aynı); hizmet satırında maliyet 0. Tahsil
/// edilen / vadesi geçen: belgenin cari hareketinin FIFO ile açık kalan kısmı (Cari İcmali ile
/// aynı kural).</para>
///
/// <para><b>Alış:</b> hizmet alımları dahil (karar 25.10.2026; Stok / Hizmet / İkisi süzgeci).
/// Fiyat gelişimi aynı kalem + aynı tedarikçi + aynı para biriminde dönemin ilk ve son birim
/// fiyatı (dövizli kalemde döviz fiyatı - kur etkisi fiyat artışı sayılmaz). Teslim süresi =
/// alış siparişi (9) → mal kabul (belge_satinalma.ilk_teslim, yoksa siparişten türeyen ilk
/// giriş belgesi).</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı,
/// cari kayıt kapsamı (baglam.Kapsam) uygulanır.
/// </summary>
public static class TicariIcmalUclari
{
    /// <summary>Ekran kodları (migration ayrı) - haklarını satış / alış fatura listesinden kopyalar.</summary>
    private const string KodSatis = "satis.icmali";
    private const string KodAlis = "alis.icmali";

    private static readonly int[] SatisTurleri = [15, 16];
    private static readonly int[] AlisTurleri = [11, 12];

    // ================================================================ kayıtlar ===

    private sealed record Bel(int Id, int Tur, int Tipi, string No, DateTime Tarih, int TarafId, string Cari,
        bool Musteri, bool Tedarikci, int SaticiId, string Satici, int SubeId, int DepoId, string Depo,
        decimal Matrah, decimal Genel, string Para, decimal Kur, int EDurum, int ESonuc, int Durum)
    {
        public bool Iade => Tipi == 2;
    }

    private sealed record Sat(int BelgeId, int StokId, int HizmetId, int MasrafId, string Kod, string Ad,
        string Kategori, string Kok, decimal Miktar, decimal Tutar, decimal Kdvli, decimal Isk, bool Uygun);

    /// <summary>İcmalin bir kalemi: belge dip toplamının bu satıra düşen payı (görünen para
    ///   biriminde, KDV kipinde). Satırsız belge tek kalemdir (S null).</summary>
    private sealed record Kalem(Bel B, Sat? S, decimal Net, decimal Isk, decimal Maliyet, decimal NetTl)
    {
        public string Anahtar => S is null ? "b" + B.Id
            : S.StokId > 0 ? "s" + S.StokId : S.HizmetId > 0 ? "h" + S.HizmetId : S.MasrafId > 0 ? "m" + S.MasrafId : "a" + S.Ad;
    }

    /// <summary>Gösterim kipi. Para "" = TL karşılığı (bütün belgeler), dolu = yalnız o döviz.</summary>
    private sealed record Kip(bool KdvDahil, bool IadeDus, string Para, string Yerel)
    {
        public bool Dovizli => Para.Length > 0;
    }

    private sealed record Donem(DateTime Bas, DateTime Bit, DateTime KBas, DateTime KBit, string Karsi, int Gun);

    /// <summary>Brüt / iskonto / iade / maliyet birikimi. Net = brüt − iskonto − (iade).</summary>
    private sealed class Top
    {
        public decimal Brut, Isk, Iade, Mal, IadeMal;
        public readonly HashSet<int> Belge = [];
        public readonly HashSet<int> IadeBelge = [];

        public void Ekle(Kalem k)
        {
            if (k.B.Iade) { Iade += k.Net; IadeMal += k.Maliyet; IadeBelge.Add(k.B.Id); }
            else { Brut += k.Net + k.Isk; Isk += k.Isk; Mal += k.Maliyet; Belge.Add(k.B.Id); }
        }

        public decimal Net(bool iadeDus) => Brut - Isk - (iadeDus ? Iade : 0);
        public decimal Maliyet(bool iadeDus) => Mal - (iadeDus ? IadeMal : 0);
        public decimal Kar(bool iadeDus) => Net(iadeDus) - Maliyet(iadeDus);
    }

    private static Top Topla(IEnumerable<Kalem> l)
    {
        var t = new Top();
        foreach (var k in l) t.Ekle(k);
        return t;
    }

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal? Degisim(decimal simdi, decimal once)
        => once > 0.005m ? Math.Round(100m * (simdi - once) / once, 1) : null;
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static decimal? Marj(Top t, bool iadeDus)
        => Math.Abs(t.Net(iadeDus)) > 0.005m ? Math.Round(100m * t.Kar(iadeDus) / t.Net(iadeDus), 1) : null;
    /// <summary>İade belgesi neti düşürür; "iadeleri düş" kapalıysa nete girmez.</summary>
    private static decimal Isaret(Bel b, Kip kip) => b.Iade ? (kip.IadeDus ? -1m : 0m) : 1m;
    private static decimal Carp(Bel b, Kip kip) => kip.Dovizli ? (b.Kur > 0 ? 1m / b.Kur : 0m) : 1m;
    private static decimal BelgeTl(Bel b, Kip kip) => kip.KdvDahil ? b.Genel : b.Matrah;

    // ================================================================== SQL ===

    /// <summary>Belge kümesi. @p0 bas · @p1 bit (dahil) · @p2 türler · @p3 taslak dahil · @p4 kullanıcının
    ///   şubeleri · @p5 seçili şube (0 tümü) · @p6 cari kayıt kapsamı · @p7 depo yönü (1 çıkış, 2 giriş).
    ///   KUR: yerel para 1; dövizli belgede belgenin kuru (rapor dövizi belgenin dövizi ise), değilse
    ///   o günün kuru.</summary>
    private const string BelgeKume = """
        with bk as materialized (
            select b.id, b.tur::int as tur, coalesce(b.tipi, 0)::int as tipi, coalesce(b.belge_no, '') as belge_no,
                   b.belge_tarihi::date as tarih, coalesce(b.taraf_id, 0) as taraf_id,
                   coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200) as cari,
                   coalesce(t.musteri, 0)::int as musteri, coalesce(t.tedarikci, 0)::int as tedarikci,
                   coalesce(b.satici_id, 0) as satici_id,
                   coalesce(public.fn_taraf_ad(sp.unvan, sp.ad, sp.soyad)::varchar(160), '')::varchar(160) as satici,
                   coalesce(b.sube_id, 0) as sube_id,
                   coalesce(case when @p7 = 1 then b.cikis_depo_id else b.giris_depo_id end, 0) as depo_id,
                   coalesce(b.matrah, 0) as matrah, coalesce(b.genel_toplam, 0) as genel,
                   p.para,
                   case when p.para = p.yerel then 1::numeric
                        when public.fn_doviz_iso(coalesce(nullif(btrim(b.rapor_dovizi), ''), p.para)) = p.para
                             and coalesce(b.doviz_kuru, 0) > 0 then b.doviz_kuru
                        else coalesce(public.fn_doviz_kur_getir(p.para, b.belge_tarihi::date, 2::smallint),
                                      nullif(b.doviz_kuru, 0), 1::numeric) end as kur,
                   coalesce(b.efatura_durum, 0)::int as edurum, coalesce(b.efatura_sonuc, 0)::int as esonuc,
                   coalesce(b.durum, 0)::int as durum
              from public.belge b
              cross join lateral (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel) y
              cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), y.yerel))::varchar(6) as para,
                                         y.yerel) p
              left join public.taraf t on t.id = b.taraf_id
              left join public.taraf sp on sp.id = b.satici_id
             where b.tur = any(@p2::int[])
               and (b.durum = 0 or (@p3 = 1 and b.durum = 1))
               and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
               and (b.sube_id is null or b.sube_id = any(@p4::int[]))
               and (@p5 = 0 or b.sube_id = @p5)
               and (cardinality(@p6::int[]) = 0 or b.taraf_id = any(@p6::int[]))
        )
        """;

    private const string BelgeSorgusu = BelgeKume + """
        select bk.id, bk.tur, bk.tipi, bk.belge_no, bk.tarih, bk.taraf_id, bk.cari, bk.musteri, bk.tedarikci,
               bk.satici_id, bk.satici, bk.sube_id, bk.depo_id, coalesce(d.ad, ''), bk.matrah, bk.genel, bk.para,
               bk.kur, bk.edurum, bk.esonuc, bk.durum
          from bk
          left join public.depo d on d.id = bk.depo_id
         order by bk.tarih, bk.id
        """;

    /// <summary>Trend süzgeci (BelgeKume'ye ek): @p8 temsilci (0 tümü, -1 temsilcisiz) · @p9 para ('' tümü).</summary>
    private const string TrendKume = BelgeKume + """
        ,
        kb as (
            select bk.* from bk
             where (@p9 = '' or bk.para = @p9)
               and (@p8 = 0 or (@p8 = -1 and bk.satici_id = 0) or (@p8 > 0 and bk.satici_id = @p8))
        )
        """;

    /// <summary>Aylık belge toplamı (dip toplamdan). @p10 KDV dahil.</summary>
    private const string TrendBelgeSorgusu = TrendKume + """
        select date_trunc('month', kb.tarih)::date, (kb.tipi = 2), count(*)::int,
               coalesce(sum((case when @p10 = 1 then kb.genel else kb.matrah end)
                            / (case when @p9 = '' then 1::numeric else nullif(kb.kur, 0) end)), 0)
          from kb
         group by 1, 2
        """;

    /// <summary>Aylık satılan miktar (stok bazında) - brüt kâr için maliyetle çarpılır.</summary>
    private const string TrendMiktarSorgusu = TrendKume + """
        select date_trunc('month', kb.tarih)::date, (kb.tipi = 2), s.stok_id,
               coalesce(sum(coalesce(s.miktar, 0) / (case when @p9 = '' then 1::numeric else nullif(kb.kur, 0) end)), 0)
          from kb
          join public.belge_satir s on s.belge_id = kb.id
         where s.stok_id is not null
         group by 1, 2, 3
        """;

    /// <summary>Belge satırları. @p0 belge id'leri · @p1 kategori (alt dallarıyla, 0 tümü) · @p2 kalem
    ///   (0 ikisi, 1 stok, 2 hizmet). Süzgeç satırı ATMAZ, `uygun` ile işaretler: belgenin dip toplamı
    ///   satırlara bütün satırların tutarı oranında dağıtılır. Kategori kökü kırılım için.</summary>
    private const string SatirSorgusu = """
        with recursive kok as (
            select k.id, k.id as kok_id, 0 as d from public.kategori k where coalesce(k.ust_id, 0) = 0
            union all
            select k.id, kok.kok_id, kok.d + 1 from public.kategori k join kok on k.ust_id = kok.id where kok.d < 30
        ),
        dal as (
            select k.id, 0 as d from public.kategori k where @p1 > 0 and k.id = @p1
            union all
            select k.id, dal.d + 1 from public.kategori k join dal on k.ust_id = dal.id where dal.d < 30
        )
        select s.belge_id, coalesce(s.stok_id, 0), coalesce(s.hizmet_id, 0), coalesce(s.masraf_id, 0),
               coalesce(st.kod, hz.kod, ms.kod, '')::varchar(80),
               coalesce(nullif(st.ad, ''), nullif(hz.ad, ''), nullif(ms.ad, ''), nullif(left(s.aciklama, 120), ''), '(açıklama)')::varchar(200),
               case when s.stok_id is null then '(hizmet)'
                    else coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '(kategorisiz)') end::varchar(200),
               case when s.stok_id is null then '(hizmet)'
                    else coalesce(nullif(btrim(coalesce(kk.kod, '') || ' ' || coalesce(kk.ad, '')), ''), '(kategorisiz)') end::varchar(200),
               coalesce(s.miktar, 0), coalesce(s.tutar, 0),
               case when coalesce(s.tutar_kdvli, 0) <> 0 then s.tutar_kdvli
                    else coalesce(s.tutar, 0) * (1 + coalesce(s.kdv, 0) / 100.0) end,
               greatest(round(coalesce(s.adet, 0) * coalesce(s.birim_fiyat, 0), 2) - coalesce(s.tutar, 0), 0),
               coalesce((@p2 = 0 or (@p2 = 1 and s.stok_id is not null) or (@p2 = 2 and s.stok_id is null))
                        and (@p1 = 0 or st.kategori in (select id from dal)), false)
          from public.belge_satir s
          left join public.stok st on st.id = s.stok_id
          left join public.hizmet hz on hz.id = s.hizmet_id
          left join public.masraf ms on ms.id = s.masraf_id
          left join public.kategori k on k.id = st.kategori
          left join kok on kok.id = k.id
          left join public.kategori kk on kk.id = kok.kok_id
         where s.belge_id = any(@p0::int[])
         order by s.belge_id, s.sira, s.id
        """;

    /// <summary>FIFO açık kalemler (Cari İcmali ile aynı kural): karşı yöndeki hareket önce vadesi en
    ///   eski kalemi kapatır. @p0 cari id'leri. Satır: cari, belge, vade, açık borç (alacağımız),
    ///   açık alacak (borcumuz) - TL.</summary>
    private const string AcikSorgusu = """
        with h as materialized (
            select e.id, e.taraf_id, coalesce(e.belge_id, 0) as belge_id,
                   coalesce(e.yerel_borc, 0) as yb, coalesce(e.yerel_alacak, 0) as ya,
                   coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => coalesce(tm.vade_gun, 0)::int)) as vade
              from public.v_cari_ekstre e
              left join public.taraf_musteri tm on tm.id = e.taraf_id
             where e.bakiye_dahil = 1 and e.taraf_id = any(@p0::int[])
        ),
        f as (
            select h.*,
                   sum(h.yb) over (partition by h.taraf_id order by h.vade, h.id) as bir_b,
                   sum(h.ya) over (partition by h.taraf_id order by h.vade, h.id) as bir_a,
                   sum(h.yb) over (partition by h.taraf_id) as top_b,
                   sum(h.ya) over (partition by h.taraf_id) as top_a
              from h
        ),
        a as (
            select f.taraf_id, f.belge_id, f.vade::date as vade,
                   least(f.yb, greatest(0, f.bir_b - f.top_a)) as acik_b,
                   least(f.ya, greatest(0, f.bir_a - f.top_b)) as acik_a
              from f
        )
        select a.taraf_id, a.belge_id, a.vade, a.acik_b, a.acik_a
          from a
         where a.acik_b > 0.005 or a.acik_a > 0.005
        """;

    /// <summary>Cari × para birimi açık bakiyesi (kendi dövizinde + TL karşılığı). @p0 cari id'leri.</summary>
    private const string DovizAcikSorgusu = """
        select public.fn_doviz_iso(coalesce(nullif(btrim(e.doviz_cinsi), ''), public.fn_yerel_para()))::varchar(6),
               e.taraf_id, sum(e.borc - e.alacak), sum(e.yerel_borc - e.yerel_alacak)
          from public.v_cari_ekstre e
         where e.bakiye_dahil = 1 and e.taraf_id = any(@p0::int[])
         group by 1, 2
        having abs(sum(e.borc - e.alacak)) >= 0.005
        """;

    /// <summary>Faturası kesilmemiş irsaliyeler (satır kalan miktarı açık). Tutar = belgenin dip toplamının
    ///   açık satırlara düşen payı. @p0 tür · @p1 bit · @p2 şubeler · @p3 şube · @p4 kapsam.</summary>
    private const string FaturasizSorgusu = """
        with x as (
            select s.belge_id, sum(coalesce(s.tutar, 0)) as top,
                   sum(case when coalesce(s.miktar, 0) > 0
                            then coalesce(s.tutar, 0) * least(greatest(coalesce(s.kalan_miktar, 0), 0), s.miktar) / s.miktar
                            else 0 end) as acik
              from public.belge_satir s
              join public.belge b on b.id = s.belge_id
             where b.tur = @p0 and b.durum = 0 and b.belge_tarihi < @p1::date + 1
               and (b.sube_id is null or b.sube_id = any(@p2::int[]))
               and (@p3 = 0 or b.sube_id = @p3)
               and (cardinality(@p4::int[]) = 0 or b.taraf_id = any(@p4::int[]))
             group by s.belge_id
            having bool_or(coalesce(s.kalan_miktar, 0) > 0)
        )
        select b.id, coalesce(b.belge_no, ''), b.belge_tarihi::date, coalesce(b.taraf_id, 0),
               coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               case when x.top <> 0 then round(coalesce(b.matrah, 0) * x.acik / x.top, 2) else 0 end
          from x
          join public.belge b on b.id = x.belge_id
          left join public.taraf t on t.id = b.taraf_id
         order by b.belge_tarihi, b.id
        """;

    // ============================================================= okuyucular ===

    private static Task<List<Bel>> BelgelerAsync(NpgsqlConnection b, DateTime bas, DateTime bit, int[] turler,
        int taslak, int[] subeler, int sube, int[] kapsam, int depoYonu, CancellationToken iptal)
        => b.ListeAsync(BelgeSorgusu, null, [bas, bit, turler, taslak, subeler, sube, kapsam, depoYonu], o => new Bel(
            o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetDateTime(4), o.GetInt32(5), o.GetString(6),
            o.GetInt32(7) == 1, o.GetInt32(8) == 1, o.GetInt32(9), o.GetString(10), o.GetInt32(11), o.GetInt32(12),
            o.GetString(13), o.GetDecimal(14), o.GetDecimal(15), o.GetString(16), o.GetDecimal(17),
            o.GetInt32(18), o.GetInt32(19), o.GetInt32(20)), iptal);

    private static async Task<List<Sat>> SatirlarAsync(NpgsqlConnection b, IEnumerable<int> belgeIdleri, int kategori,
        int kalem, CancellationToken iptal)
    {
        var dizi = belgeIdleri.Distinct().ToArray();
        if (dizi.Length == 0) return [];
        return await b.ListeAsync(SatirSorgusu, null, [dizi, kategori, kalem], o => new Sat(
            o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetString(4), o.GetString(5), o.GetString(6),
            o.GetString(7), o.GetDecimal(8), o.GetDecimal(9), o.GetDecimal(10), o.GetDecimal(11), o.GetBoolean(12)), iptal);
    }

    /// <summary>Ortalama birim maliyet - StokIcmalUclari.MaliyetAsync("ort") ile aynı fonksiyon.</summary>
    private static async Task<Dictionary<int, decimal>> MaliyetAsync(NpgsqlConnection b, IEnumerable<int> idler,
        CancellationToken iptal)
    {
        var dizi = idler.Where(x => x > 0).Distinct().ToArray();
        if (dizi.Length == 0) return new();
        var l = await b.ListeAsync("""
            select x.id, coalesce(public.fn_uretim_stok_maliyeti(x.id), 0) from unnest(@p0::int[]) as x(id)
            """, null, [dizi], o => (id: o.GetInt32(0), m: o.GetDecimal(1)), iptal);
        return l.ToDictionary(x => x.id, x => x.m);
    }

    /// <summary>Kalemler: belge dip toplamı satırlara satır tutarı (KDV dahilde KDV'li tutar) oranında dağıtılır.</summary>
    private static List<Kalem> Kalemler(List<Bel> belgeler, List<Sat> satirlar, Dictionary<int, decimal> maliyet,
        Kip kip, bool satirSuzgecli)
    {
        var gruplar = satirlar.GroupBy(s => s.BelgeId).ToDictionary(g => g.Key, g => g.ToList());
        var l = new List<Kalem>();
        foreach (var b in belgeler)
        {
            var carp = Carp(b, kip);
            var belgeTl = BelgeTl(b, kip);
            var kdvOran = kip.KdvDahil && b.Matrah != 0 ? b.Genel / b.Matrah : 1m;
            if (!gruplar.TryGetValue(b.Id, out var ss) || ss.Count == 0)
            {
                if (!satirSuzgecli) l.Add(new Kalem(b, null, belgeTl * carp, 0, 0, belgeTl));
                continue;
            }
            var payda = kip.KdvDahil ? ss.Sum(x => x.Kdvli) : ss.Sum(x => x.Tutar);
            foreach (var s in ss.Where(x => x.Uygun))
            {
                var pay = payda != 0 ? (kip.KdvDahil ? s.Kdvli : s.Tutar) / payda : 1m / ss.Count;
                var tl = belgeTl * pay;
                var mal = s.StokId > 0 && maliyet.TryGetValue(s.StokId, out var m) ? s.Miktar * m : 0m;
                l.Add(new Kalem(b, s, tl * carp, s.Isk * kdvOran * carp, mal * carp, tl));
            }
        }
        return l;
    }

    /// <summary>Carinin dövizli belgeleri (TL karşılığı kipinde rozet): para → döviz tutarı.</summary>
    private static List<object> DovizRozet(IEnumerable<Kalem> l, Kip kip)
    {
        if (kip.Dovizli) return [];
        return l.Where(k => k.B.Para != kip.Yerel && k.B.Kur > 0).GroupBy(k => k.B.Para)
            .Select(g => (object)new { para = g.Key, tutar = R(g.Sum(k => Isaret(k.B, kip) * k.NetTl / k.B.Kur)) })
            .ToList();
    }

    /// <summary>Para birimi tablosu (her zaman TL karşılığı kümesinden). satis: açık ALACAK (alış kuru),
    ///   alış: açık BORÇ (satış kuru); kur farkı = açığın bugünkü kurla değeri − defterdeki TL karşılığı.</summary>
    private static async Task<object> ParaTablosuAsync(NpgsqlConnection b, List<Bel> kume, Func<Bel, decimal> tlTutar,
        Kip kip, bool satis, DateTime bugun, CancellationToken iptal)
    {
        decimal Tl(Bel x) => tlTutar(x) * Isaret(x, kip);
        var tarafIdleri = kume.Select(x => x.TarafId).Where(x => x > 0).Distinct().ToArray();
        var acik = tarafIdleri.Length == 0 ? []
            : await b.ListeAsync(DovizAcikSorgusu, null, [tarafIdleri],
                o => (para: o.GetString(0), taraf: o.GetInt32(1), doviz: o.GetDecimal(2), yerel: o.GetDecimal(3)), iptal);
        var toplamTl = kume.Sum(Tl);
        var satirlar = new List<object>();
        decimal topBugun = 0, topFark = 0;
        foreach (var g in kume.GroupBy(x => x.Para).OrderBy(x => x.Key == kip.Yerel ? 0 : 1).ThenBy(x => x.Key))
        {
            var tl = g.Sum(Tl);
            if (g.Key == kip.Yerel)
            {
                satirlar.Add(new
                {
                    para = g.Key, yerel = true, belge = g.Count(), doviz = (decimal?)null, ortKur = (decimal?)null,
                    tl = R(tl), pay = Yuzde(tl, toplamTl), acikDoviz = (decimal?)null, bugunkuKur = (decimal?)null,
                    acikBugun = (decimal?)null, kurFarki = (decimal?)null,
                });
                continue;
            }
            var dvz = g.Where(x => x.Kur > 0).Sum(x => Tl(x) / x.Kur);
            var ac = acik.Where(a => a.para == g.Key && (satis ? a.doviz > 0 : a.doviz < 0)).ToList();
            var acikDoviz = ac.Sum(a => Math.Abs(a.doviz));
            var acikYerel = ac.Sum(a => satis ? a.yerel : -a.yerel);
            var kur = await b.TekDegerAsync<decimal?>("select public.fn_doviz_kur_getir(@p0, @p1::date, @p2::smallint)", null,
                [g.Key, bugun, satis ? 2 : 1], iptal);
            decimal? bugunDeger = null;
            decimal? fark = null;
            if (acikDoviz <= 0) bugunDeger = 0m;
            else if (kur is { } kr)
            {
                bugunDeger = R(acikDoviz * kr);
                fark = R(acikDoviz * kr - acikYerel);
            }
            topBugun += bugunDeger ?? 0; topFark += fark ?? 0;
            satirlar.Add(new
            {
                para = g.Key, yerel = false, belge = g.Count(), doviz = (decimal?)R(dvz),
                ortKur = dvz != 0 ? Math.Round(tl / dvz, 4) : (decimal?)null,
                tl = R(tl), pay = Yuzde(tl, toplamTl), acikDoviz = (decimal?)R(acikDoviz), bugunkuKur = kur,
                acikBugun = bugunDeger, kurFarki = fark,
            });
        }
        return new
        {
            satirlar,
            toplam = new { belge = kume.Count, tl = R(toplamTl), acikBugun = R(topBugun), kurFarki = R(topFark) },
        };
    }

    private static async Task<object> FaturasizAsync(NpgsqlConnection b, int tur, DateTime bit, int[] subeler, int sube,
        int[] kapsam, DateTime bugun, CancellationToken iptal)
    {
        var l = await b.ListeAsync(FaturasizSorgusu, null, [tur, bit, subeler, sube, kapsam], o => new
        {
            id = o.GetInt32(0), no = o.GetString(1), tarih = o.GetDateTime(2), cariId = o.GetInt32(3), cari = o.GetString(4),
            tutar = o.GetDecimal(5), gun = (int)(bugun - o.GetDateTime(2).Date).TotalDays,
        }, iptal);
        return new
        {
            sayi = l.Count, tutar = R(l.Sum(x => x.tutar)),
            liste = l.OrderByDescending(x => x.gun).Take(100).ToList(),
        };
    }

    private static Donem DonemCoz(DateTime? bas, DateTime? bit, string? karsi, bool yilBasi)
    {
        var bugun = Saat.Bugun.Date;
        var bitis = (bit ?? bugun).Date;
        var baslangic = (bas ?? (yilBasi ? new DateTime(bitis.Year, 1, 1) : new DateTime(bitis.Year, bitis.Month, 1))).Date;
        if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
        if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
        var gun = (int)(bitis - baslangic).TotalDays + 1;
        // KARŞILAŞTIRMA: geçen yılın aynı dönemi (varsayılan) ya da hemen önceki eşit uzunlukta dönem.
        var k = karsi == "od" ? "od" : "gy";
        var (kb, kbt) = k == "od" ? (baslangic.AddDays(-gun), baslangic.AddDays(-1)) : (baslangic.AddYears(-1), bitis.AddYears(-1));
        return new Donem(baslangic, bitis, kb, kbt, k, gun);
    }

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    private static async Task<Kip> KipCozAsync(NpgsqlConnection b, int? kdv, int? iade, string? para, CancellationToken iptal)
    {
        var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, [], iptal) ?? "TL";
        var p = string.IsNullOrWhiteSpace(para) ? ""
            : await b.TekDegerAsync<string>("select public.fn_doviz_iso(@p0)::varchar(6)", null, [para.Trim()], iptal) ?? "";
        if (p == yerel) p = "";
        return new Kip((kdv ?? 0) == 1, (iade ?? 1) == 1, p, yerel);
    }

    /// <summary>
    /// AKTARILAN TAHAKKUK (25.10.2026): Delphi'den gelen geçmiş faturalar web'e satırsız
    /// "Satış / Alış Tahakkuku" (17 / 13) olarak aktarıldı - tutarları yalnız cari hareketinde.
    /// Satırı olmadığı için icmale (ürün, maliyet, KDV hariç tutar) GİRMEZ; ekran boş görünüp
    /// yanıltmasın diye dönemdeki adedi ve cari tutarı (KDV dahil) ayrıca bildirilir.
    /// </summary>
    private static async Task<object> TahakkukAsync(NpgsqlConnection b, int tur, DateTime bas, DateTime bit,
        int[] subeler, CancellationToken iptal)
    {
        var l = await b.ListeAsync("""
            select count(distinct e.belge_id)::int,
                   coalesce(sum(case when @p0 = 17 then e.yerel_borc - e.yerel_alacak else e.yerel_alacak - e.yerel_borc end), 0)
              from public.v_mali_hareket_ek e
             where e.hesap_turu = 'C' and e.tur = @p0 and e.islem_durum in (1, 2)
               and e.islem_tarihi >= @p1::date and e.islem_tarihi < @p2::date + 1
               and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p3::int[]))
            """, null, [tur, bas, bit, subeler], o => new { belge = o.GetInt32(0), tutar = Math.Round(o.GetDecimal(1), 2) }, iptal);
        return l.FirstOrDefault() ?? new { belge = 0, tutar = 0m };
    }

    public static void TicariIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/ticari-icmal").WithTags("Satış / Alış İcmali").RequireAuthorization();

        // ================================================================= SATIŞ ===
        grup.MapGet("/satis", async (DateTime? bas, DateTime? bit, string? karsi, int? sube, int? temsilci, string? para,
                                     int? kdv, int? iade, int? taslak,
                                     VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodSatis, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var d = DonemCoz(bas, bit, karsi, false);
            var bugun = Saat.Bugun.Date;
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var tsl = (taslak ?? 0) == 1 ? 1 : 0;
            var tms = temsilci ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var kip = await KipCozAsync(b, kdv, iade, para, iptal);

            var hamCari = await BelgelerAsync(b, d.Bas, d.Bit, SatisTurleri, tsl, subeler, s0, kapsam, 1, iptal);
            var hamOnce = await BelgelerAsync(b, d.KBas, d.KBit, SatisTurleri, tsl, subeler, s0, kapsam, 1, iptal);
            // Seçim listeleri süzülmemiş kümeden (temsilci / para seçince liste daralmasın).
            var temsilciler = hamCari.GroupBy(x => x.SaticiId).OrderBy(g => g.Key == 0 ? 1 : 0).ThenBy(g => g.First().Satici)
                .Select(g => new { id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().Satici }).ToList();
            bool TemsilciUyar(Bel x) => tms == 0 || (tms == -1 ? x.SaticiId == 0 : x.SaticiId == tms);
            var kume = hamCari.Where(TemsilciUyar).ToList();                       // para tablosu (TL karşılığı)
            var belgeler = kume.Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();
            var oncekiBelge = hamOnce.Where(TemsilciUyar).Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();
            var paralar = hamCari.Select(x => x.Para).Where(p => p != kip.Yerel).Distinct().OrderBy(p => p).ToList();

            var satirlar = await SatirlarAsync(b, belgeler.Select(x => x.Id), 0, 0, iptal);
            var oncekiSatir = await SatirlarAsync(b, oncekiBelge.Select(x => x.Id), 0, 0, iptal);

            // ------------------------------------------------------- trend (12 ay) --
            var m0 = new DateTime(d.Bit.Year, d.Bit.Month, 1).AddMonths(-11);
            object?[] Tp(DateTime tb, DateTime tbit) => [tb, tbit, SatisTurleri, tsl, subeler, s0, kapsam, 1, tms, kip.Para, kip.KdvDahil ? 1 : 0];
            var trB = await b.ListeAsync(TrendBelgeSorgusu, null, Tp(m0, d.Bit),
                o => (ay: o.GetDateTime(0), iade: o.GetBoolean(1), adet: o.GetInt32(2), tutar: o.GetDecimal(3)), iptal);
            var trBk = await b.ListeAsync(TrendBelgeSorgusu, null, Tp(m0.AddYears(-1), d.Bit.AddYears(-1)),
                o => (ay: o.GetDateTime(0), iade: o.GetBoolean(1), adet: o.GetInt32(2), tutar: o.GetDecimal(3)), iptal);
            var trM = await b.ListeAsync(TrendMiktarSorgusu, null, Tp(m0, d.Bit),
                o => (ay: o.GetDateTime(0), iade: o.GetBoolean(1), stok: o.GetInt32(2), miktar: o.GetDecimal(3)), iptal);

            var maliyet = await MaliyetAsync(b, satirlar.Select(x => x.StokId).Concat(oncekiSatir.Select(x => x.StokId))
                                               .Concat(trM.Select(x => x.stok)), iptal);
            var kalemler = Kalemler(belgeler, satirlar, maliyet, kip, false);
            var onceki = Kalemler(oncekiBelge, oncekiSatir, maliyet, kip, false);
            var top = Topla(kalemler);
            var net = top.Net(kip.IadeDus);
            var oncekiNet = Topla(onceki).Net(kip.IadeDus);

            // ------------------------------------------- FIFO: tahsil / vadesi geçen --
            var tarafIdleri = belgeler.Select(x => x.TarafId).Where(x => x > 0).Distinct().ToArray();
            var acik = tarafIdleri.Length == 0 ? []
                : await b.ListeAsync(AcikSorgusu, null, [tarafIdleri],
                    o => (taraf: o.GetInt32(0), belge: o.GetInt32(1), vade: o.GetDateTime(2), b: o.GetDecimal(3), a: o.GetDecimal(4)), iptal);
            var acikBelge = acik.Where(x => x.belge > 0).GroupBy(x => x.belge).ToDictionary(g => g.Key, g => g.Sum(x => x.b));
            var gecikenBelge = acik.Where(x => x.belge > 0 && x.vade.Date < bugun).GroupBy(x => x.belge).ToDictionary(g => g.Key, g => g.Sum(x => x.b));
            decimal Tahsil(Bel x) => x.Iade ? 0 : Math.Max(0, x.Genel - acikBelge.GetValueOrDefault(x.Id)) * Carp(x, kip);
            var vadesiGecen = belgeler.Where(x => !x.Iade).Sum(x => gecikenBelge.GetValueOrDefault(x.Id) * Carp(x, kip));

            var ilkSatis = tarafIdleri.Length == 0 ? []
                : await b.ListeAsync("""
                    select b.taraf_id, min(b.belge_tarihi)::date from public.belge b
                     where b.tur = any(@p0::int[]) and b.durum = 0 and coalesce(b.tipi, 0) <> 2 and b.taraf_id = any(@p1::int[])
                     group by 1
                    """, null, [SatisTurleri, tarafIdleri], o => (id: o.GetInt32(0), ilk: o.GetDateTime(1)), iptal);
            var yeniler = ilkSatis.Where(x => x.ilk.Date >= d.Bas).Select(x => x.id).ToHashSet();

            var faturasiz = await FaturasizAsync(b, 14, d.Bit, subeler, s0, kapsam, bugun, iptal);

            // ---------------------------------------------------------- özet --
            var satisBelge = belgeler.Where(x => !x.Iade).ToList();
            var ozet = new
            {
                net = R(net), brut = R(top.Brut), iskonto = R(top.Isk), iade = R(top.Iade), iadeBelge = top.IadeBelge.Count,
                karsiNet = R(oncekiNet), degisim = Degisim(net, oncekiNet),
                belge = satisBelge.Count, fatura = satisBelge.Count(x => x.Tur == 15), fis = satisBelge.Count(x => x.Tur == 16),
                musteri = satisBelge.Select(x => x.TarafId).Distinct().Count(),
                yeniMusteri = satisBelge.Select(x => x.TarafId).Distinct().Count(yeniler.Contains),
                maliyet = R(top.Maliyet(kip.IadeDus)), kar = R(top.Kar(kip.IadeDus)), marj = Marj(top, kip.IadeDus),
                iskontoOran = Yuzde(top.Isk, top.Brut), iadeOran = Yuzde(top.Iade, top.Brut - top.Isk),
                vadesiGecen = R(vadesiGecen),
            };

            // ------------------------------------------------- müşteri bazında --
            var oncekiCari = onceki.GroupBy(k => k.B.TarafId).ToDictionary(g => g.Key, g => Topla(g).Net(kip.IadeDus));
            var musteriler = kalemler.GroupBy(k => k.B.TarafId).Select(g =>
            {
                var t = Topla(g);
                var n = t.Net(kip.IadeDus);
                var var0 = oncekiCari.TryGetValue(g.Key, out var once);
                var ilk = g.First().B;
                var tm = g.GroupBy(k => k.B.SaticiId).OrderByDescending(x => x.Sum(k => k.Net))
                    .Select(x => x.Key == 0 ? "(temsilcisiz)" : x.First().B.Satici).Distinct().ToList();
                var bl = g.GroupBy(k => k.B.Id).Select(x => new
                {
                    id = x.Key, no = x.First().B.No, tarih = x.First().B.Tarih, tutar = R(x.Sum(k => k.Net)), iade = x.First().B.Iade,
                }).OrderBy(x => x.tarih).ToList();
                return new
                {
                    id = g.Key, ad = ilk.Cari, musteri = ilk.Musteri, tedarikci = ilk.Tedarikci,
                    temsilci = string.Join(" · ", tm.Take(2)) + (tm.Count > 2 ? " …" : ""),
                    belge = t.Belge.Count + t.IadeBelge.Count, brut = R(t.Brut), iskonto = R(t.Isk), iade = R(t.Iade), net = R(n),
                    gecenYil = var0 ? R(once) : (decimal?)null, degisim = Degisim(n, once),
                    yeni = yeniler.Contains(g.Key) || (!var0 && n > 0.005m),
                    kar = R(t.Kar(kip.IadeDus)), marj = Marj(t, kip.IadeDus), pay = Yuzde(n, net),
                    doviz = DovizRozet(g, kip), belgeSayisi = bl.Count, belgeler = bl.Take(60).ToList(),
                };
            }).OrderByDescending(x => x.net).ToList();
            var enBuyukCari = musteriler.Count > 0 ? Math.Max(musteriler.Max(x => x.net), 0.01m) : 1m;
            var musteriSatirlari = musteriler.Select(x => new
            {
                x.id, x.ad, x.musteri, x.tedarikci, x.temsilci, x.belge, x.brut, x.iskonto, x.iade, x.net, x.gecenYil, x.degisim,
                x.yeni, x.kar, x.marj, x.pay, cubuk = Yuzde(Math.Max(x.net, 0), enBuyukCari), dusukMarj = x.marj is < 15m,
                x.doviz, x.belgeSayisi, x.belgeler,
            }).ToList();
            var musteriToplam = new
            {
                musteri = musteriler.Count, belge = top.Belge.Count + top.IadeBelge.Count, brut = R(top.Brut), iskonto = R(top.Isk),
                iade = R(top.Iade), net = R(net), gecenYil = R(oncekiNet), degisim = Degisim(net, oncekiNet),
                kar = R(top.Kar(kip.IadeDus)), marj = Marj(top, kip.IadeDus),
            };

            // ---------------------------------------------------- ürün bazında --
            var stokIdleri = kalemler.Where(k => k.S is { StokId: > 0 }).Select(k => k.S!.StokId).Distinct().ToArray();
            var listeFiyat = stokIdleri.Length == 0 ? []
                : await b.ListeAsync("""
                    select x.id, coalesce(f.fiyat, 0),
                           public.fn_doviz_iso(coalesce(nullif(btrim(f.doviz_cinsi), ''), public.fn_yerel_para()))::varchar(6)
                      from unnest(@p0::int[]) as x(id)
                      left join lateral (select * from public.fn_stok_kart_fiyat(x.id, 1::smallint) limit 1) f on true
                    """, null, [stokIdleri], o => (id: o.GetInt32(0), fiyat: o.GetDecimal(1), para: o.GetString(2)), iptal);
            var listeSoz = listeFiyat.ToDictionary(x => x.id, x => (x.fiyat, x.para));
            var urunler = kalemler.Where(k => k.S is not null).GroupBy(k => k.Anahtar).Select(g =>
            {
                var s1 = g.First().S!;
                var t = Topla(g);
                var n = t.Net(kip.IadeDus);
                var miktar = g.Sum(k => (k.B.Iade ? (kip.IadeDus ? -1m : 0m) : 1m) * k.S!.Miktar);
                decimal? ort = miktar != 0 ? Math.Round(n / miktar, 2) : null;
                decimal? liste = s1.StokId > 0 && listeSoz.TryGetValue(s1.StokId, out var lf) && lf.fiyat > 0
                                 && lf.para == (kip.Dovizli ? kip.Para : kip.Yerel) ? lf.fiyat : null;
                var dagilim = g.GroupBy(k => k.B.TarafId).Select(x => new
                {
                    id = x.Key, ad = x.First().B.Cari,
                    miktar = x.Sum(k => (k.B.Iade ? (kip.IadeDus ? -1m : 0m) : 1m) * k.S!.Miktar),
                    net = R(Topla(x).Net(kip.IadeDus)),
                }).OrderByDescending(x => x.net).ToList();
                var marj = Marj(t, kip.IadeDus);
                return new
                {
                    anahtar = g.Key, stokId = s1.StokId, hizmet = s1.StokId == 0, kod = s1.Kod, ad = s1.Ad, kategori = s1.Kategori,
                    miktar, net = R(n), ortFiyat = ort, listeFiyati = liste,
                    maliyet = s1.StokId > 0 ? R(t.Maliyet(kip.IadeDus)) : (decimal?)null,
                    kar = R(t.Kar(kip.IadeDus)), marj,
                    musteri = dagilim.Count,
                    // KDV dahil kipinde liste fiyatı (KDV hariç) ile karşılaştırılmaz.
                    dusukFiyat = !kip.KdvDahil && liste is > 0m && ort is { } o2 && o2 < liste.Value * 0.9m,
                    eksiMarj = marj is < 0m,
                    musteriler = dagilim.Take(15).ToList(),
                };
            }).OrderByDescending(x => x.net).ToList();

            // ------------------------------------------------------------ trend --
            decimal TrNet(List<(DateTime ay, bool iade, int adet, decimal tutar)> l, DateTime ay)
                => l.Where(x => x.ay == ay && !x.iade).Sum(x => x.tutar) - (kip.IadeDus ? l.Where(x => x.ay == ay && x.iade).Sum(x => x.tutar) : 0);
            decimal TrMal(DateTime ay) => trM.Where(x => x.ay == ay)
                .Sum(x => (x.iade ? (kip.IadeDus ? -1m : 0m) : 1m) * x.miktar * maliyet.GetValueOrDefault(x.stok));
            var aylarHam = Enumerable.Range(0, 12).Select(i =>
            {
                var ay = m0.AddMonths(i);
                var n = TrNet(trB, ay);
                var gy = TrNet(trBk, ay.AddYears(-1));
                var kar = n - TrMal(ay);
                return new
                {
                    ay, net = R(n), gecenYil = R(gy), degisim = Degisim(n, gy),
                    belge = trB.Where(x => x.ay == ay && !x.iade).Sum(x => x.adet), kar = R(kar),
                    marj = Math.Abs(n) > 0.005m ? Math.Round(100m * kar / n, 1) : (decimal?)null,
                    kismiGun = ay.Year == d.Bit.Year && ay.Month == d.Bit.Month && d.Bit.Day < DateTime.DaysInMonth(ay.Year, ay.Month)
                        ? d.Bit.Day : (int?)null,
                };
            }).ToList();
            var enBuyukAy = Math.Max(aylarHam.Count > 0 ? aylarHam.Max(x => x.net) : 0, 0.01m);
            var aylar = aylarHam.Select(x => new { x.ay, x.net, x.gecenYil, x.degisim, x.belge, x.kar, x.marj, x.kismiGun, cubuk = Yuzde(Math.Max(x.net, 0), enBuyukAy) }).ToList();
            var gunler = d.Gun <= 62
                ? Enumerable.Range(0, d.Gun).Select(i =>
                {
                    var g = d.Bas.AddDays(i);
                    var kg = d.Karsi == "od" ? g.AddDays(-d.Gun) : g.AddYears(-1);
                    var t = Topla(kalemler.Where(k => k.B.Tarih == g));
                    var tk = Topla(onceki.Where(k => k.B.Tarih == kg));
                    var n = t.Net(kip.IadeDus);
                    return new
                    {
                        tarih = g, karsiTarih = kg, net = R(n), karsi = R(tk.Net(kip.IadeDus)), degisim = Degisim(n, tk.Net(kip.IadeDus)),
                        belge = t.Belge.Count, kar = R(t.Kar(kip.IadeDus)), marj = Marj(t, kip.IadeDus),
                    };
                }).ToList()
                : null;

            // -------------------------------------------------------- kırılımlar --
            var subeAd = baglam.Subeler.GroupBy(s => s.Id).ToDictionary(g => g.Key, g => g.First().Ad);
            static string TurAdi(Bel x) => (x.Tur == 16 ? "Satış Fişi"
                : x.EDurum is 1 or 2 ? "Satış Faturası (e-Fatura)"
                : x.EDurum is 11 or 12 ? "Satış Faturası (e-Arşiv)" : "Satış Faturası (e-Belgesiz)") + (x.Iade ? " · iade" : "");
            var kirilim = new
            {
                temsilci = kalemler.GroupBy(k => k.B.SaticiId).Select(g =>
                {
                    var t = Topla(g);
                    return new
                    {
                        id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().B.Satici, net = R(t.Net(kip.IadeDus)),
                        musteri = g.Select(k => k.B.TarafId).Distinct().Count(), marj = Marj(t, kip.IadeDus),
                        tahsil = R(g.Select(k => k.B).DistinctBy(x => x.Id).Sum(Tahsil)),
                    };
                }).OrderByDescending(x => x.net).ToList(),
                kategori = kalemler.GroupBy(k => k.S?.Kok ?? "(satırsız)").Select(g =>
                {
                    var t = Topla(g);
                    return new { ad = g.Key, net = R(t.Net(kip.IadeDus)), pay = Yuzde(t.Net(kip.IadeDus), net), marj = Marj(t, kip.IadeDus) };
                }).OrderByDescending(x => x.net).ToList(),
                subeDepo = kalemler.GroupBy(k => (k.B.SubeId, k.B.Depo)).Select(g => new
                {
                    ad = (g.Key.SubeId == 0 ? "(şubesiz)" : subeAd.GetValueOrDefault(g.Key.SubeId) ?? $"Şube {g.Key.SubeId}")
                         + " · " + (g.Key.Depo.Length > 0 ? g.Key.Depo : "(depo yok)"),
                    net = R(Topla(g).Net(kip.IadeDus)), belge = g.Select(k => k.B.Id).Distinct().Count(),
                }).OrderByDescending(x => x.net).ToList(),
                belgeTuru = kalemler.GroupBy(k => TurAdi(k.B)).Select(g => new
                {
                    ad = g.Key, net = R(g.Sum(k => (k.B.Iade ? -1m : 1m) * k.Net)), belge = g.Select(k => k.B.Id).Distinct().Count(),
                }).OrderByDescending(x => x.net).ToList(),
                para = await ParaTablosuAsync(b, kume, x => BelgeTl(x, kip), kip, true, bugun, iptal),
            };

            // ------------------------------------------------------------ dikkat --
            var cariNet = kalemler.GroupBy(k => k.B.TarafId).ToDictionary(g => g.Key, g => Topla(g).Net(kip.IadeDus));
            var dikkat = new
            {
                zarar = kalemler.Where(k => k.S is { StokId: > 0, Miktar: > 0m } && !k.B.Iade && k.Maliyet > 0)
                    .Select(k => new
                    {
                        belgeId = k.B.Id, belgeNo = k.B.No, tarih = k.B.Tarih, cariId = k.B.TarafId, cari = k.B.Cari,
                        stokId = k.S!.StokId, kod = k.S.Kod, urun = k.S.Ad, miktar = k.S.Miktar,
                        // Fiyat satırın kendi KDV hariç tutarından (KDV kipinden bağımsız).
                        fiyat = Math.Round(k.S.Tutar * Carp(k.B, kip) / k.S.Miktar, 2),
                        maliyet = Math.Round(k.Maliyet / k.S.Miktar, 2),
                        zarar = R(k.Maliyet - k.S.Tutar * Carp(k.B, kip)),
                    })
                    .Where(x => x.fiyat < x.maliyet - 0.005m).OrderByDescending(x => x.zarar).Take(50).ToList(),
                dusen = onceki.GroupBy(k => k.B.TarafId).Select(g =>
                {
                    var once = Topla(g).Net(kip.IadeDus);
                    var simdi = cariNet.GetValueOrDefault(g.Key);
                    return new { id = g.Key, ad = g.First().B.Cari, simdi = R(simdi), once = R(once), degisim = Degisim(simdi, once), kayip = simdi <= 0.005m };
                }).Where(x => x.once > 0.005m && (x.kayip || x.degisim < -20)).OrderBy(x => x.simdi - x.once).Take(50).ToList(),
                irsaliye = faturasiz,
                ebelge = belgeler.Where(x => x.Tur == 15 && x.Durum == 0 && x.EDurum is not (2 or 12))
                    .OrderBy(x => x.Tarih).Take(100)
                    .Select(x => new
                    {
                        id = x.Id, no = x.No, cariId = x.TarafId, cari = x.Cari, tarih = x.Tarih, iade = x.Iade,
                        durum = x.EDurum == 0 ? "e-Belge hazırlanmadı" : x.ESonuc == 3 ? "gönderim hatası" : "hazırlandı · gönderilmedi",
                    }).ToList(),
            };

            return Results.Ok(new
            {
                bas = d.Bas, bit = d.Bit, karsi = new { tur = d.Karsi, bas = d.KBas, bit = d.KBit }, gun = d.Gun,
                kdvDahil = kip.KdvDahil, iadeDus = kip.IadeDus, taslak = tsl == 1, para = kip.Para, yerelPara = kip.Yerel,
                sube = s0, temsilci = tms,
                ozet, aktarimTahakkuk = await TahakkukAsync(b, 17, d.Bas, d.Bit, subeler, iptal),
                musteriler = musteriSatirlari, musteriToplam, urunler,
                trend = new { aylar, gunler }, kirilim, dikkat,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(), temsilciler, paralar,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================================== ALIŞ ===
        grup.MapGet("/alis", async (DateTime? bas, DateTime? bit, string? karsi, int? sube, int? kategori, string? kalem,
                                    string? para, int? kdv, int? iade, int? taslak,
                                    VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(KodAlis, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var d = DonemCoz(bas, bit, karsi, true);
            var bugun = Saat.Bugun.Date;
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var tsl = (taslak ?? 0) == 1 ? 1 : 0;
            var k0 = kategori ?? 0;
            var kalemKod = kalem switch { "stok" => 1, "hizmet" => 2, _ => 0 };
            var satirSuzgecli = k0 > 0 || kalemKod > 0;
            await using var b = await veri.AcAsync(iptal);
            var kip = await KipCozAsync(b, kdv, iade, para, iptal);

            var hamCari = await BelgelerAsync(b, d.Bas, d.Bit, AlisTurleri, tsl, subeler, s0, kapsam, 2, iptal);
            var hamOnce = await BelgelerAsync(b, d.KBas, d.KBit, AlisTurleri, tsl, subeler, s0, kapsam, 2, iptal);
            var paralar = hamCari.Select(x => x.Para).Where(p => p != kip.Yerel).Distinct().OrderBy(p => p).ToList();
            var belgeler = hamCari.Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();
            var oncekiBelge = hamOnce.Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();
            // AY TRENDİ geçen yılla: karşılaştırma "önceki dönem" ise geçen yıl ayrıca okunur.
            var gyBelge = d.Karsi == "gy" ? oncekiBelge
                : (await BelgelerAsync(b, d.Bas.AddYears(-1), d.Bit.AddYears(-1), AlisTurleri, tsl, subeler, s0, kapsam, 2, iptal))
                    .Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();

            // Satırlar süzülmemiş (bütün paralar) kümeden: para tablosu TL karşılığı kipinde hepsini gösterir.
            var satirlar = await SatirlarAsync(b, hamCari.Select(x => x.Id), k0, kalemKod, iptal);
            var oncekiSatir = await SatirlarAsync(b, oncekiBelge.Select(x => x.Id), k0, kalemKod, iptal);
            var gySatir = d.Karsi == "gy" ? oncekiSatir : await SatirlarAsync(b, gyBelge.Select(x => x.Id), k0, kalemKod, iptal);
            var bos = new Dictionary<int, decimal>();
            var kalemler = Kalemler(belgeler, satirlar, bos, kip, satirSuzgecli);
            var tlKalem = Kalemler(hamCari, satirlar, bos, kip with { Para = "" }, satirSuzgecli);
            var tlBelge = tlKalem.GroupBy(k => k.B.Id).ToDictionary(g => g.Key, g => g.Sum(k => k.NetTl));
            var tlKume = tlKalem.Select(k => k.B).DistinctBy(x => x.Id).ToList();
            var onceki = Kalemler(oncekiBelge, oncekiSatir, bos, kip, satirSuzgecli);
            var gyKalem = d.Karsi == "gy" ? onceki : Kalemler(gyBelge, gySatir, bos, kip, satirSuzgecli);
            var top = Topla(kalemler);
            var net = top.Net(kip.IadeDus);
            var oncekiNet = Topla(onceki).Net(kip.IadeDus);
            // Süzgeçli kipte belge, süzgece uyan satırı varsa kümededir.
            var kumeBelge = kalemler.Select(k => k.B).DistinctBy(x => x.Id).ToList();

            // ---------------------------------------------- FIFO: açık borç / vade --
            var tarafIdleri = kumeBelge.Select(x => x.TarafId).Where(x => x > 0).Distinct().ToArray();
            var acik = tarafIdleri.Length == 0 ? []
                : await b.ListeAsync(AcikSorgusu, null, [tarafIdleri],
                    o => (taraf: o.GetInt32(0), belge: o.GetInt32(1), vade: o.GetDateTime(2), b: o.GetDecimal(3), a: o.GetDecimal(4)), iptal);
            // Açık borç = carinin bakiyesi (FIFO açıklarının farkı) - TL.
            var acikBorc = acik.GroupBy(x => x.taraf).ToDictionary(g => g.Key, g => Math.Max(0, g.Sum(x => x.a) - g.Sum(x => x.b)));
            var vadeSiniri = bugun.AddDays(30);
            var vadesiGelen = acik.Where(x => x.a > 0.005m && x.vade.Date <= vadeSiniri).ToList();

            // ------------------------------------------------------ teslim süresi --
            var teslimler = await b.ListeAsync("""
                with sp as (
                    select b.id, coalesce(b.taraf_id, 0) as taraf_id, b.belge_tarihi::date as tarih, bsa.ilk_teslim
                      from public.belge b
                      left join public.belge_satinalma bsa on bsa.id = b.id
                     where b.tur = 9 and b.durum = 0 and b.belge_tarihi < @p1::date + 1
                       and (b.sube_id is null or b.sube_id = any(@p2::int[]))
                       and (@p3 = 0 or b.sube_id = @p3)
                ),
                gr as (
                    select ks.belge_id as sip_id, min(hb.belge_tarihi)::date as ilk
                      from public.belge_satir hs
                      join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
                      join public.belge hb on hb.id = hs.belge_id
                     where hb.tur in (10, 11, 12) and hb.durum = 0 and ks.belge_id in (select id from sp)
                     group by 1
                )
                select sp.id, sp.taraf_id, sp.tarih, coalesce(sp.ilk_teslim, gr.ilk)
                  from sp left join gr on gr.sip_id = sp.id
                 where coalesce(sp.ilk_teslim, gr.ilk) >= @p0::date and coalesce(sp.ilk_teslim, gr.ilk) <= @p1::date
                """, null, [d.Bas, d.Bit, subeler, s0],
                o => (id: o.GetInt32(0), taraf: o.GetInt32(1), gun: Math.Max(0, (int)(o.GetDateTime(3).Date - o.GetDateTime(2).Date).TotalDays)), iptal);
            var teslimCari = teslimler.GroupBy(x => x.taraf).ToDictionary(g => g.Key, g => Math.Round((decimal)g.Average(x => x.gun), 1));

            // ------------------------------------------- satılan / SMM / stokta --
            var hareket = await b.ListeAsync("""
                select date_trunc('month', h.tarih)::date, h.stok_id, coalesce(sum(h.cikan - h.giren), 0)
                  from public.v_stok_hareket h
                  join public.belge bl on bl.id = h.belge_id
                 where h.tur in (14, 15, 16) and h.tarih >= @p0::date and h.tarih <= @p1::date
                   and (bl.sube_id is null or bl.sube_id = any(@p2::int[]))
                   and (@p3 = 0 or bl.sube_id = @p3)
                 group by 1, 2
                """, null, [d.Bas, d.Bit, subeler, s0],
                o => (ay: o.GetDateTime(0), stok: o.GetInt32(1), miktar: o.GetDecimal(2)), iptal);
            var stokIdleri = kalemler.Where(k => k.S is { StokId: > 0 }).Select(k => k.S!.StokId).Distinct().ToArray();
            var stokta = stokIdleri.Length == 0 ? new Dictionary<int, decimal>()
                : (await b.ListeAsync("""
                    select sd.stok_id, coalesce(sum(sd.kalan), 0)
                      from public.stok_durum sd
                      join public.depo dp on dp.id = sd.depo_id
                     where sd.stok_id = any(@p0::int[])
                       and (dp.sube_id is null or dp.sube_id = any(@p1::int[]))
                       and (@p2 = 0 or dp.sube_id = @p2)
                     group by 1
                    """, null, [stokIdleri, subeler, s0], o => (id: o.GetInt32(0), m: o.GetDecimal(1)), iptal))
                  .ToDictionary(x => x.id, x => x.m);
            var satilan = hareket.GroupBy(x => x.stok)
                .ToDictionary(g => g.Key, g => g.Sum(x => x.miktar));
            // Satılan = dönemde (dönem başından) satış çıkışı - iade; aylık SMM ile aynı kaynak (v_stok_hareket).

            // ------------------------------------------------------------ özet --
            var alisBelge = kumeBelge.Where(x => !x.Iade).ToList();
            var tedarikciNet = kalemler.GroupBy(k => k.B.TarafId).Select(g => Topla(g).Net(kip.IadeDus)).OrderByDescending(x => x).ToList();

            // ------------------------------------------------------ fiyat gelişimi --
            // Birim fiyat: satırın kendi KDV hariç tutarı / miktar; dövizli belgede döviz cinsinden (÷ belge kuru).
            decimal BirimFiyat(Kalem k) => k.S!.Tutar / k.S.Miktar / (k.B.Para != kip.Yerel && k.B.Kur > 0 ? k.B.Kur : 1m);
            // Etki görünen para biriminde: TL kipinde dövizli kalem belge kuruyla TL'ye çevrilir.
            decimal EtkiCarpani(Kalem k) => !kip.Dovizli && k.B.Para != kip.Yerel ? k.B.Kur : 1m;
            var fiyatlar = kalemler.Where(k => k.S is { Miktar: > 0m } && !k.B.Iade && k.S.Tutar > 0)
                .GroupBy(k => (k.Anahtar, k.B.TarafId, k.B.Para))
                .Where(g => g.Select(k => k.B.Id).Distinct().Count() >= 2)
                .Select(g =>
                {
                    var sirali = g.OrderBy(k => k.B.Tarih).ThenBy(k => k.B.Id).ToList();
                    var ilk = sirali[0];
                    var son = sirali[^1];
                    var ilkF = Math.Round(BirimFiyat(ilk), 4);
                    var sonF = Math.Round(BirimFiyat(son), 4);
                    var sonraki = sirali.Where(k => k.B.Id != ilk.B.Id).ToList();
                    var etki = sonraki.Sum(k => (sonF - ilkF) * k.S!.Miktar * EtkiCarpani(k));
                    var tutar = g.Sum(k => k.Net);
                    return new
                    {
                        anahtar = g.Key.Anahtar, stokId = ilk.S!.StokId, kod = ilk.S.Kod, ad = ilk.S.Ad, tedarikciId = g.Key.TarafId,
                        tedarikci = ilk.B.Cari, para = g.Key.Para, ilkFiyat = ilkF, ilkTarih = ilk.B.Tarih, sonFiyat = sonF,
                        sonTarih = son.B.Tarih, degisim = ilkF > 0 ? Math.Round(100m * (sonF - ilkF) / ilkF, 1) : 0m,
                        etki = R(etki), tutar = R(tutar), alis = g.Select(k => k.B.Id).Distinct().Count(),
                    };
                }).OrderByDescending(x => x.degisim).ThenByDescending(x => x.etki).ToList();
            var fiyatTutar = fiyatlar.Sum(x => x.tutar);
            var agirlikliDegisim = fiyatTutar != 0 ? Math.Round(fiyatlar.Sum(x => x.degisim * x.tutar) / fiyatTutar, 1) : (decimal?)null;

            var ozet = new
            {
                net = R(net), brut = R(top.Brut), iskonto = R(top.Isk), iade = R(top.Iade), iadeBelge = top.IadeBelge.Count,
                karsiNet = R(oncekiNet), degisim = Degisim(net, oncekiNet),
                belge = alisBelge.Count, fatura = alisBelge.Count(x => x.Tur == 11), fis = alisBelge.Count(x => x.Tur == 12),
                tedarikci = alisBelge.Select(x => x.TarafId).Distinct().Count(),
                ilk3Pay = Yuzde(tedarikciNet.Take(3).Sum(), net),
                fiyatArtisi = agirlikliDegisim, fiyatKalem = fiyatlar.Count,
                teslimGun = teslimler.Count > 0 ? Math.Round((decimal)teslimler.Average(x => x.gun), 1) : (decimal?)null,
                teslimSiparis = teslimler.Count,
                vadesiGelen = R(vadesiGelen.Sum(x => x.a)), vadesiGelenGecmis = R(vadesiGelen.Where(x => x.vade.Date < bugun).Sum(x => x.a)),
                stokNet = R(Topla(kalemler.Where(k => k.S is { StokId: > 0 })).Net(kip.IadeDus)),
                hizmetNet = R(Topla(kalemler.Where(k => k.S is { StokId: 0 })).Net(kip.IadeDus)),
            };

            // ------------------------------------------------ tedarikçi bazında --
            var oncekiCari = onceki.GroupBy(k => k.B.TarafId).ToDictionary(g => g.Key, g => Topla(g).Net(kip.IadeDus));
            var tedHam = kalemler.GroupBy(k => k.B.TarafId).Select(g =>
            {
                var t = Topla(g);
                var n = t.Net(kip.IadeDus);
                var var0 = oncekiCari.TryGetValue(g.Key, out var once);
                var ilk = g.First().B;
                var kat = g.GroupBy(k => k.S?.Kok ?? "(satırsız)").Select(x => new { ad = x.Key, net = R(Topla(x).Net(kip.IadeDus)) })
                    .OrderByDescending(x => x.net).Take(6).ToList();
                return new
                {
                    id = g.Key, ad = ilk.Cari, musteri = ilk.Musteri, tedarikci = ilk.Tedarikci,
                    belge = t.Belge.Count + t.IadeBelge.Count, brut = R(t.Brut), iskonto = R(t.Isk), iade = R(t.Iade), net = R(n),
                    gecenYil = var0 ? R(once) : (decimal?)null, degisim = Degisim(n, once), pay = Yuzde(n, net),
                    teslimGun = teslimCari.TryGetValue(g.Key, out var tg) ? tg : (decimal?)null,
                    acikBorc = R(acikBorc.GetValueOrDefault(g.Key)),
                    sonAlis = g.Where(k => !k.B.Iade).Select(k => k.B.Tarih).DefaultIfEmpty().Max(),
                    doviz = DovizRozet(g, kip), kategoriler = kat,
                };
            }).OrderByDescending(x => x.net).ToList();
            var enBuyukTed = tedHam.Count > 0 ? Math.Max(tedHam.Max(x => x.net), 0.01m) : 1m;
            var tedarikciler = tedHam.Select(x => new
            {
                x.id, x.ad, x.musteri, x.tedarikci, x.belge, x.brut, x.iskonto, x.iade, x.net, x.gecenYil, x.degisim, x.pay,
                x.teslimGun, gecTeslim = x.teslimGun is > 10m, x.acikBorc,
                sonAlis = x.sonAlis == default ? (DateTime?)null : x.sonAlis, x.doviz, x.kategoriler,
                cubuk = Yuzde(Math.Max(x.net, 0), enBuyukTed),
            }).ToList();
            var tedarikciToplam = new
            {
                tedarikci = tedHam.Count, belge = top.Belge.Count + top.IadeBelge.Count, brut = R(top.Brut), iskonto = R(top.Isk),
                iade = R(top.Iade), net = R(net), gecenYil = R(oncekiNet), degisim = Degisim(net, oncekiNet),
                teslimGun = ozet.teslimGun, acikBorc = R(tedHam.Sum(x => x.acikBorc)),
            };

            // ---------------------------------------------------- ürün bazında --
            var urunler = kalemler.Where(k => k.S is not null).GroupBy(k => k.Anahtar).Select(g =>
            {
                var s1 = g.First().S!;
                var t = Topla(g);
                var n = t.Net(kip.IadeDus);
                var miktar = g.Sum(k => (k.B.Iade ? (kip.IadeDus ? -1m : 0m) : 1m) * k.S!.Miktar);
                var alim = g.Where(k => !k.B.Iade && k.S!.Miktar > 0).OrderBy(k => k.B.Tarih).ThenBy(k => k.B.Id).ToList();
                // Birim fiyatlar görünen para biriminde, KDV kipinde (dip toplamdan düşen pay / miktar).
                var birimler = alim.Select(k => k.Net / k.S!.Miktar).ToList();
                var dagilim = g.GroupBy(k => k.B.TarafId).Select(x =>
                {
                    var al = x.Where(k => !k.B.Iade && k.S!.Miktar > 0).ToList();
                    var mk = al.Sum(k => k.S!.Miktar);
                    return new { id = x.Key, ad = x.First().B.Cari, miktar = mk, ortFiyat = mk > 0 ? Math.Round(al.Sum(k => k.Net) / mk, 2) : (decimal?)null };
                }).OrderByDescending(x => x.miktar).ToList();
                var enUcuz = dagilim.Where(x => x.ortFiyat > 0).Select(x => x.ortFiyat).DefaultIfEmpty(null).Min();
                return new
                {
                    anahtar = g.Key, stokId = s1.StokId, hizmet = s1.StokId == 0, kod = s1.Kod, ad = s1.Ad, kategori = s1.Kategori,
                    miktar, net = R(n), ortFiyat = miktar != 0 ? Math.Round(n / miktar, 2) : (decimal?)null,
                    enDusuk = birimler.Count > 0 ? Math.Round(birimler.Min(), 2) : (decimal?)null,
                    enYuksek = birimler.Count > 0 ? Math.Round(birimler.Max(), 2) : (decimal?)null,
                    sonFiyat = birimler.Count > 0 ? Math.Round(birimler[^1], 2) : (decimal?)null,
                    tedarikci = dagilim.Count,
                    satilan = s1.StokId > 0 ? satilan.GetValueOrDefault(s1.StokId) : (decimal?)null,
                    stokta = s1.StokId > 0 ? stokta.GetValueOrDefault(s1.StokId) : (decimal?)null,
                    tedarikciler = dagilim.Select(x => new
                    {
                        x.id, x.ad, x.miktar, x.ortFiyat,
                        fark = enUcuz is > 0m && x.ortFiyat is { } ofy ? Math.Round(100m * (ofy - enUcuz.Value) / enUcuz.Value, 1) : (decimal?)null,
                        enUcuz = dagilim.Count > 1 && x.ortFiyat == enUcuz,
                    }).ToList(),
                };
            }).OrderByDescending(x => x.net).ToList();

            // ---------------------------------------------------------- ay trendi --
            var maliyet = await MaliyetAsync(b, hareket.Select(x => x.stok), iptal);
            var ilkAy = new DateTime(d.Bas.Year, d.Bas.Month, 1);
            var sonAy = new DateTime(d.Bit.Year, d.Bit.Month, 1);
            var ayListe = new List<DateTime>();
            for (var a = ilkAy; a <= sonAy; a = a.AddMonths(1)) ayListe.Add(a);
            if (ayListe.Count > 36) ayListe = ayListe.Skip(ayListe.Count - 36).ToList();
            var aylarHam = ayListe.Select(ay =>
            {
                bool Ayda(Kalem k, DateTime a) => k.B.Tarih.Year == a.Year && k.B.Tarih.Month == a.Month;
                var t = Topla(kalemler.Where(k => Ayda(k, ay)));
                var n = t.Net(kip.IadeDus);
                var gy = Topla(gyKalem.Where(k => Ayda(k, ay.AddYears(-1)))).Net(kip.IadeDus);
                var stokAlis = Topla(kalemler.Where(k => Ayda(k, ay) && k.S is { StokId: > 0 })).Net(kip.IadeDus);
                // SMM yalnız TL kipinde (ortalama maliyet TL'dir); tek döviz seçiliyken anlamsız.
                decimal? smm = kip.Dovizli ? null : R(hareket.Where(x => x.ay == ay).Sum(x => x.miktar * maliyet.GetValueOrDefault(x.stok)));
                return new
                {
                    ay, net = R(n), gecenYil = R(gy), degisim = Degisim(n, gy), stokAlis = R(stokAlis), smm,
                    fark = smm is { } sm ? R(stokAlis - sm) : (decimal?)null,
                    kismiGun = ay.Year == d.Bit.Year && ay.Month == d.Bit.Month && d.Bit.Day < DateTime.DaysInMonth(ay.Year, ay.Month)
                        ? d.Bit.Day : (int?)null,
                };
            }).ToList();
            var enBuyukAy = Math.Max(aylarHam.Count > 0 ? aylarHam.Max(x => x.net) : 0, 0.01m);
            var aylar = aylarHam.Select(x => new { x.ay, x.net, x.gecenYil, x.degisim, x.stokAlis, x.smm, x.fark, x.kismiGun, cubuk = Yuzde(Math.Max(x.net, 0), enBuyukAy) }).ToList();

            // ---------------------------------------------------------- dikkat --
            // Sözleşme fiyatının üstünde alış: yürürlükteki (durum 1) tedarikçi sözleşmesinin kalem fiyatı.
            var sozlesmeler = tarafIdleri.Length == 0 ? []
                : await b.ListeAsync("""
                    select z.firma_id, coalesce(f.stok_id, 0), coalesce(f.hizmet_id, 0), coalesce(f.birim_fiyat, 0),
                           public.fn_doviz_iso(coalesce(nullif(btrim(f.doviz), ''), public.fn_yerel_para()))::varchar(6),
                           coalesce(f.gecerli_bas, z.baslangic), coalesce(f.gecerli_son, z.bitis), coalesce(z.sozlesme_no, '')
                      from public.tedarikci_sozlesme_fiyat f
                      join public.tedarikci_sozlesme z on z.id = f.sozlesme_id
                     where z.durum = 1 and z.firma_id = any(@p0::int[]) and coalesce(f.birim_fiyat, 0) > 0
                    """, null, [tarafIdleri], o => (firma: o.GetInt32(0), stok: o.GetInt32(1), hizmet: o.GetInt32(2), fiyat: o.GetDecimal(3),
                        para: o.GetString(4), bas: o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                        bit: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6), no: o.GetString(7)), iptal);
            var sozlesmeUstu = kalemler.Where(k => k.S is { Miktar: > 0m } && !k.B.Iade && k.S.Tutar > 0)
                .Select(k =>
                {
                    var z = sozlesmeler.FirstOrDefault(x => x.firma == k.B.TarafId
                        && ((k.S!.StokId > 0 && x.stok == k.S.StokId) || (k.S.HizmetId > 0 && x.hizmet == k.S.HizmetId))
                        && (x.bas is null || x.bas.Value.Date <= k.B.Tarih) && (x.bit is null || x.bit.Value.Date >= k.B.Tarih));
                    if (z.fiyat <= 0) return null;
                    // Sözleşme dövizinde karşılaştır: TL sözleşme - TL birim; dövizli - aynı dövizdeki belge.
                    decimal? fiyat = z.para == kip.Yerel ? (decimal?)(k.S!.Tutar / k.S.Miktar)
                                   : z.para == k.B.Para && k.B.Kur > 0 ? (decimal?)(k.S!.Tutar / k.S.Miktar / k.B.Kur) : null;
                    if (fiyat is not { } f || f <= z.fiyat + 0.005m) return null;
                    return new
                    {
                        belgeId = k.B.Id, belgeNo = k.B.No, tarih = k.B.Tarih, cariId = k.B.TarafId, cari = k.B.Cari,
                        kod = k.S!.Kod, urun = k.S.Ad, para = z.para, fiyat = Math.Round(f, 2), sozlesme = Math.Round(z.fiyat, 2),
                        sozlesmeNo = z.no, fark = Math.Round(100m * (f - z.fiyat) / z.fiyat, 1),
                    };
                }).Where(x => x is not null).Select(x => x!).OrderByDescending(x => x.fark).Take(50).ToList();

            // Aynı kalemde daha ucuz tedarikçi (son 90 gün, TL belgeler, iade hariç).
            var son90 = await b.ListeAsync("""
                select coalesce(s.stok_id, 0), coalesce(s.hizmet_id, 0),
                       max(coalesce(nullif(st.ad, ''), nullif(hz.ad, ''), ''))::varchar(200), coalesce(b.taraf_id, 0),
                       max(coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''))::varchar(200),
                       sum(s.tutar) / nullif(sum(s.miktar), 0), sum(s.miktar)
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                  left join public.stok st on st.id = s.stok_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                  left join public.taraf t on t.id = b.taraf_id
                 where b.tur in (11, 12) and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                   and s.miktar > 0 and s.tutar > 0 and (s.stok_id is not null or s.hizmet_id is not null)
                   and b.belge_tarihi >= @p0::date - 89 and b.belge_tarihi < @p0::date + 1
                   and public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), public.fn_yerel_para()))
                       = public.fn_doviz_iso(public.fn_yerel_para())
                   and (b.sube_id is null or b.sube_id = any(@p1::int[]))
                   and (@p2 = 0 or b.sube_id = @p2)
                   and (cardinality(@p3::int[]) = 0 or b.taraf_id = any(@p3::int[]))
                 group by 1, 2, 4
                """, null, [d.Bit, subeler, s0, kapsam], o => (stok: o.GetInt32(0), hizmet: o.GetInt32(1), ad: o.GetString(2),
                    taraf: o.GetInt32(3), cari: o.GetString(4), fiyat: o.IsDBNull(5) ? 0m : o.GetDecimal(5), miktar: o.GetDecimal(6)), iptal);
            var ucuz = son90.GroupBy(x => (x.stok, x.hizmet)).Where(g => g.Count() > 1).SelectMany(g =>
            {
                var enU = g.Where(x => x.fiyat > 0).OrderBy(x => x.fiyat).First();
                return g.Where(x => x.taraf != enU.taraf && x.fiyat > enU.fiyat * 1.03m).Select(x => new
                {
                    stokId = g.Key.stok, urun = x.ad, alinanId = x.taraf, alinan = x.cari, fiyat = Math.Round(x.fiyat, 2), miktar = x.miktar,
                    ucuzId = enU.taraf, ucuz = enU.cari, ucuzFiyat = Math.Round(enU.fiyat, 2),
                    fark = Math.Round(100m * (x.fiyat - enU.fiyat) / enU.fiyat, 1),
                    kayip = R((x.fiyat - enU.fiyat) * x.miktar),
                });
            }).OrderByDescending(x => x.kayip).Take(50).ToList();

            var geciken = await b.ListeAsync("""
                select b.id, coalesce(b.belge_no, ''), coalesce(b.taraf_id, 0),
                       coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
                       coalesce(bsa.soz_teslim, min(s.teslim_tarihi)::date), coalesce(sum(s.kalan_miktar), 0), b.belge_tarihi::date
                  from public.belge b
                  join public.belge_satir s on s.belge_id = b.id
                  left join public.belge_satinalma bsa on bsa.id = b.id
                  left join public.taraf t on t.id = b.taraf_id
                 where b.tur = 9 and b.durum = 0 and coalesce(s.kalan_miktar, 0) > 0
                   and (b.sube_id is null or b.sube_id = any(@p1::int[]))
                   and (@p2 = 0 or b.sube_id = @p2)
                   and (cardinality(@p3::int[]) = 0 or b.taraf_id = any(@p3::int[]))
                 group by b.id, b.belge_no, b.taraf_id, b.taraf_unvan, t.unvan, t.ad, t.soyad, bsa.soz_teslim, b.belge_tarihi
                having coalesce(bsa.soz_teslim, min(s.teslim_tarihi)::date) < @p0::date
                 order by 5
                 limit 100
                """, null, [bugun, subeler, s0, kapsam], o => new
                {
                    id = o.GetInt32(0), no = o.GetString(1), cariId = o.GetInt32(2), cari = o.GetString(3), termin = o.GetDateTime(4),
                    acikMiktar = o.GetDecimal(5), siparisTarihi = o.GetDateTime(6), gecikme = (int)(bugun - o.GetDateTime(4).Date).TotalDays,
                }, iptal);

            // GELEN e-FATURA KUTUSUNDA BEKLEYEN (karar 25.10.2026): kaydedilmemiş (belge_id boş), kullanım
            //   dışı değil, reddedilmemiş - alışa SAYILMAZ (cari / stok etkisi yok), yalnız listelenir.
            var gelen = await b.ListeAsync("""
                select e.id, coalesce(e.taraf_id, 0),
                       coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''), e.gonderici_unvan, '')::varchar(200),
                       coalesce(e.belge_no, ''), e.belge_tarihi, coalesce(e.tutar, 0), coalesce(e.para_birimi, ''),
                       coalesce(e.ekleme_tarihi::date, e.belge_tarihi), public.fn_ebelge_tur_adi(e.belge_turu)
                  from public.e_belge e
                  left join public.taraf t on t.id = e.taraf_id
                 where e.yon = 2 and e.belge_turu in (1, 2) and e.belge_id is null and coalesce(e.tasnif, 1) = 1
                   and coalesce(e.durum, 0) <> 102 and e.iptal_tarihi is null
                   and (e.sube_id is null or e.sube_id = any(@p0::int[]))
                   and (@p1 = 0 or e.sube_id = @p1)
                 order by coalesce(e.ekleme_tarihi::date, e.belge_tarihi) nulls last
                 limit 200
                """, null, [subeler, s0], o => new
                {
                    id = o.GetInt32(0), cariId = o.GetInt32(1), cari = o.GetString(2), no = o.GetString(3),
                    tarih = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4), tutar = o.GetDecimal(5), para = o.GetString(6),
                    bekleyen = o.IsDBNull(7) ? (int?)null : (int)(bugun - o.GetDateTime(7).Date).TotalDays, tur = o.GetString(8),
                }, iptal);

            var dikkat = new
            {
                sozlesmeUstu, ucuz,
                irsaliye = await FaturasizAsync(b, 10, d.Bit, subeler, s0, kapsam, bugun, iptal),
                geciken, gelen,
                gelenTutar = R(gelen.Sum(x => x.tutar)),
            };

            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                bas = d.Bas, bit = d.Bit, karsi = new { tur = d.Karsi, bas = d.KBas, bit = d.KBit }, gun = d.Gun,
                kdvDahil = kip.KdvDahil, iadeDus = kip.IadeDus, taslak = tsl == 1, para = kip.Para, yerelPara = kip.Yerel,
                sube = s0, kategori = k0, kalem = kalemKod switch { 1 => "stok", 2 => "hizmet", _ => "hepsi" },
                aktarimTahakkuk = await TahakkukAsync(b, 13, d.Bas, d.Bit, subeler, iptal),
                ozet, tedarikciler, tedarikciToplam,
                paraTablosu = await ParaTablosuAsync(b, tlKume, x => tlBelge.GetValueOrDefault(x.Id), kip, false, bugun, iptal),
                urunler,
                fiyat = new { satirlar = fiyatlar.Take(300).ToList(), kalem = fiyatlar.Count, agirlikliDegisim, etki = R(fiyatlar.Sum(x => x.etki)) },
                trend = new { aylar },
                dikkat,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(), paralar, kategoriler,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
