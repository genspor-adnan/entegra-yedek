using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MASRAF İCMALİ (mockup Ekranlar/İcmal/masraf_icmali.html - kullanıcı 25.10.2026, kararlar mockup
/// altında, migration 1178). "Paramız nereye gidiyor, geçen yıla ve plana göre nerede artıyor, hangi
/// merkez ne harcıyor?"
///
/// <para><b>Küme (tek kural, üç kaynak):</b></para>
/// <list type="number">
/// <item><b>Belge:</b> kesin (durum 0; "taslak dahil" ile 1) alış faturası / alış fişi / gider pusulası
///   (11, 12, 8) + iadeleri (tipi 2, eksi) - yalnız STOKSUZ satırlar (hizmet / masraf satırı). Stoklu mal
///   alımı gider DEĞİLDİR (stoğa girer, satılınca SMM olur - Kârlılık İcmali; karar 25.10.2026).
///   Satır tutarı belgenin dip toplamının (belge.matrah / genel_toplam, fn_belge_diptoplam'ın yazdığı)
///   satıra düşen payıdır - Satış / Alış İcmali ile aynı dağıtım; satır yeniden hesaplanmaz.
///   Kalem: satırın masraf_id'si, yoksa belge başlığının masraf_id'si.</item>
/// <item><b>Kasa / banka:</b> <c>v_masraf_ekstre</c> (077) - gerçekleşmiş kasa işleminin masraf
///   bacağı (hesap_turu 'M'); gider = yerel borç − yerel alacak. Kalemsiz masraf bacağı görünüme
///   girmediği için AYNI tabandan (v_mali_hareket_ek, hesap_turu 'M', kalem yok) "atanmamış" olarak
///   eklenir. Hizmet kalemli bacak gelir kalemidir, gidere girmez. Cariye yapılan ödemenin kendisi gider
///   DEĞİLDİR (cari bacağı; gideri faturası taşır) - aynı gider iki yoldan sayılmaz. Personel maaşı
///   (bordro yok, karar 25.10.2026) tediyenin masraf bacağıyla, ödeme tarihine göre girer.</item>
/// <item><b>Personel masraf beyanı:</b> onaylanmış (durum 2) beyanın satırları, harcama tarihine göre
///   (KDV hariç = tutar − kdv_tutar). Ödeme bu modülde değildir (764), çift sayım olmaz.</item>
/// <item><b>Amortisman</b> (karar 25.10.2026, varsayılan dahil): <c>v_demirbas_amortisman</c>'ın yıllık
///   payı döneme GÜN oranında bölünür; ayrı "Amortisman" üst kalemi, nakit çıkışı yoktur.</item>
/// </list>
///
/// <para><b>Ağaç:</b> üst kalem = masraf.ust_id zincirinin kökü; muhasebe kodu gösterilir, gruplama
/// ağaca göre. Merkez: satırın merkez_id'si, yoksa belge başlığının; o da yoksa "(merkez atanmamış)" -
/// tahmin edilip dağıtılmaz.</para>
///
/// <para><b>Plan:</b> Planlı Giderler'in dönem planları (PlanliGiderMotoru / PlanliGiderHesap - tek
/// kaynak), plan tarihi dönemde olanlar, atlanan dönem hariç; gerçek = aynı masraf kalemindeki gider.
/// Tanım eklenmeden önceki (dondurulmamış, eşleşmemiş) dönem plan sayılmaz (Nakit Akış ile aynı).</para>
///
/// <para><b>Gider / Ciro:</b> ciro = Satış İcmali'nin net satışı (kesin satış faturası / fişi 15, 16
/// belge.matrah, iade düşülmüş, TL); oran her zaman KDV hariç giderle.</para>
///
/// <para><b>Eylem:</b> POST /ata - seçili belge satırına / kasa masraf bacağına masraf kalemi atar
/// (belge Değiştir; kasa bacağı ayrıca kasa_islem Değiştir), loglu. Kapanmış muhasebe döneminde
/// REDDEDİLİR (karar 25.10.2026: kapanmış dönemde yalnız görüntüler).</para>
///
/// Rakamlar sunucuda; ekran toplamaz. Şube süzgeci kullanıcının şubeleriyle sınırlı, cari kayıt
/// kapsamı (baglam.Kapsam) belge kaynaklı satırlara uygulanır.
/// </summary>
public static class MasrafIcmalUclari
{
    private const string Kod = "finans.masraf_icmali";

    /// <summary>islem_log.tablo_id - belge (BelgeDeposu) ve kasa işlemi (KasaDeposu) ile aynı.</summary>
    private const int LogTabloBelge = 30;
    private const int LogTabloKasa = 908;

    private static readonly int[] GiderTurleri = [11, 12, 8];

    /// <summary>Sanal kalemler: kalemi atanmamış gider ve demirbaş amortismanı.</summary>
    public const int KalemAtanmamis = -1;
    public const int KalemAmortisman = -2;
    private const int KolonDiger = -9;

    public sealed record AtaSatiri(string Kaynak, int Id);
    public sealed record AtaIstegi(int MasrafId, List<AtaSatiri>? Satirlar);

    // ================================================================ kayıtlar ===

    private sealed record Gider(string Kaynak, long SatirId, int BelgeId, string No, string KaynakAdi, DateTime Tarih,
        int TarafId, string Taraf, string Aciklama, int MasrafId, int MerkezId, int SubeId, decimal Haric, decimal Dahil,
        int KdvOran, bool Iade, int Durum, bool HizmetBagli, bool Fis, bool Delphi, bool GunKapali)
    {
        private decimal Isaret => Iade ? -1m : 1m;
        public decimal Tutar(bool kdvDahil) => Isaret * (kdvDahil ? Dahil : Haric);
        public decimal Kdv => Isaret * (Dahil - Haric);
        /// <summary>Kalem kimliği: masraf id · -1 atanmamış · -2 amortisman.</summary>
        public int Kalem => Kaynak == "amortisman" ? KalemAmortisman : MasrafId > 0 ? MasrafId : KalemAtanmamis;
    }

    private sealed record Masraf(int Id, string Kod, string Ad, int UstId, bool Baslik, string MuhKodu, bool Aktif);
    private sealed record Merkez(int Id, string Kod, string Ad, int UstId, bool Aktif);
    private sealed record Donem(DateTime Bas, DateTime Bit, DateTime KBas, DateTime KBit, string Karsi, int Gun);

    /// <summary>Süzgeç. Kalem / merkez: 0 tümü · -1 atanmamış · (kalem) -2 amortisman · &gt;0 alt dallarıyla.</summary>
    private sealed record Suzgec(int Sube, int Merkez, int Kalem, bool KdvDahil, bool Plan, bool Taslak, bool Amortisman);

    /// <summary>Kalem ağacı + merkezler: kök (üst kalem), alt küme, ad.</summary>
    private sealed class Agac
    {
        public required Dictionary<int, Masraf> Masraflar { get; init; }
        public required Dictionary<int, Merkez> Merkezler { get; init; }

        public int Ust(int kalem)
        {
            if (kalem <= 0) return kalem;
            var id = kalem;
            for (var i = 0; i < 30 && Masraflar.TryGetValue(id, out var m) && m.UstId > 0 && m.UstId != id; i++) id = m.UstId;
            return id;
        }

        public string Ad(int kalem) => kalem switch
        {
            KalemAtanmamis => "Diğer (kalem atanmamış)",
            KalemAmortisman => "Amortisman",
            _ => Masraflar.TryGetValue(kalem, out var m) ? m.Ad : $"#{kalem}",
        };

        public string KodAdi(int kalem) => kalem > 0 && Masraflar.TryGetValue(kalem, out var m) ? m.Kod : "";
        public string Muh(int kalem) => kalem > 0 && Masraflar.TryGetValue(kalem, out var m) ? m.MuhKodu : "";

        public string MerkezAdi(int id) => id <= 0 ? "(merkez atanmamış)" : Merkezler.TryGetValue(id, out var m) ? m.Ad : $"#{id}";

        public static HashSet<int> AltKume<T>(int kok, IEnumerable<T> l, Func<T, int> id, Func<T, int> ust)
        {
            var cocuk = l.ToLookup(ust, id);
            var k = new HashSet<int> { kok };
            var sira = new Queue<int>([kok]);
            while (sira.Count > 0 && k.Count < 100000)
                foreach (var c in cocuk[sira.Dequeue()])
                    if (k.Add(c)) sira.Enqueue(c);
            return k;
        }
    }

    // ================================================================== SQL ===

    /// <summary>Gider kümesi. @p0 bas · @p1 bit (dahil) · @p2 kullanıcının şubeleri · @p3 seçili şube (0 tümü) ·
    ///   @p4 taslak dahil · @p5 cari kayıt kapsamı · @p6 gider belge türleri. Sütunlar <see cref="Gider"/> sırasıyla;
    ///   12 KDV hariç, 13 KDV dahil (ikisi de işaretsiz - iade C# tarafında eksi).</summary>
    private const string GiderSorgusu = """
        with bk as materialized (
            select b.id, b.tur::int as tur, coalesce(b.tipi, 0)::int as tipi,
                   coalesce(nullif(b.belge_no, ''), '#' || b.id)::varchar(60) as no,
                   b.belge_tarihi::date as tarih, coalesce(b.taraf_id, 0) as taraf_id,
                   coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200) as cari,
                   coalesce(b.matrah, 0)::numeric as matrah, coalesce(b.genel_toplam, 0)::numeric as genel,
                   b.masraf_id as bmasraf, coalesce(b.merkez_id, 0) as bmerkez, coalesce(b.sube_id, 0) as sube_id,
                   coalesce(b.durum, 0)::int as durum, (coalesce(b.aktarim_kaynak, 0) = 1) as aktarim
              from public.belge b
              left join public.taraf t on t.id = b.taraf_id
             where b.tur = any(@p6::int[])
               and (b.durum = 0 or (@p4 = 1 and b.durum = 1))
               and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
               and (b.sube_id is null or b.sube_id = any(@p2::int[]))
               and (@p3 = 0 or b.sube_id = @p3)
               and (cardinality(@p5::int[]) = 0 or b.taraf_id = any(@p5::int[]))
        ),
        st as (
            select s.id, s.belge_id, s.stok_id, s.hizmet_id, s.masraf_id, s.merkez_id, s.aciklama, s.kdv,
                   coalesce(s.aktarim_kaynak, 0) as aktarim_kaynak, coalesce(s.tutar, 0)::numeric as tutar,
                   (case when coalesce(s.tutar_kdvli, 0) <> 0 then s.tutar_kdvli
                         else coalesce(s.tutar, 0) * (1 + coalesce(s.kdv, 0) / 100.0) end)::numeric as kdvli
              from public.belge_satir s
             where s.belge_id in (select bk.id from bk)
        ),
        pay as (
            select st.belge_id, sum(st.tutar) as top, sum(st.kdvli) as topk from st group by st.belge_id
        )
        select 'belge'::varchar(12), st.id::bigint, bk.id, bk.no,
               ((case bk.tur when 11 then 'Alış faturası' when 12 then 'Alış fişi' else 'Gider pusulası' end)
                || (case when bk.tipi = 2 then ' · iade' else '' end))::varchar(80),
               bk.tarih, bk.taraf_id, bk.cari,
               coalesce(nullif(left(btrim(st.aciklama), 200), ''), hz.ad, ms.ad, '')::varchar(200),
               coalesce(st.masraf_id, bk.bmasraf, 0), coalesce(nullif(st.merkez_id, 0), nullif(bk.bmerkez, 0), 0), bk.sube_id,
               (case when p.top <> 0 then bk.matrah * st.tutar / p.top else 0 end)::numeric,
               (case when p.topk <> 0 then bk.genel * st.kdvli / p.topk else 0 end)::numeric,
               coalesce(st.kdv, 0)::int, bk.tipi = 2, bk.durum,
               st.hizmet_id is not null,
               exists (select 1 from public.muhasebe_fis f where f.kaynak_tur = 2 and f.kaynak_id = bk.id and f.durum = 1),
               (bk.aktarim or st.aktarim_kaynak = 1) and public.fn_veri_kaynagi_delphi(),
               false
          from st
          join bk on bk.id = st.belge_id
          join pay p on p.belge_id = st.belge_id
          left join public.hizmet hz on hz.id = st.hizmet_id
          left join public.masraf ms on ms.id = st.masraf_id
         where st.stok_id is null
        union all
        select 'kasa'::varchar(12), e.id::bigint, coalesce(mh.kasa_islem_id, 0),
               coalesce(nullif(e.islem_no, ''), nullif(mh.belge_no, ''), '#' || coalesce(mh.kasa_islem_id, e.id))::varchar(60),
               coalesce(e.tur_adi, '')::varchar(80), e.islem_tarihi::date, coalesce(e.taraf_id, 0),
               coalesce(e.taraf_unvan, '')::varchar(200), coalesce(e.aciklama, '')::varchar(200),
               coalesce(e.masraf_id, 0), coalesce(e.merkez_id, 0), coalesce(e.sube_id, 0),
               (coalesce(e.yerel_borc, 0) - coalesce(e.yerel_alacak, 0))::numeric,
               (coalesce(e.yerel_borc, 0) - coalesce(e.yerel_alacak, 0))::numeric,
               0, false, 2, false,
               exists (select 1 from public.muhasebe_fis f where f.kaynak_tur = 1 and f.kaynak_id = mh.kasa_islem_id and f.durum = 1),
               coalesce(mh.aktarim_kaynak, 0) = 1 and public.fn_veri_kaynagi_delphi(),
               coalesce(public.fn_kasa_gun_kapali(mh.sube_id, mh.islem_tarihi), false)
          from (
                -- KALEMLİ: v_masraf_ekstre (077) - masraf ekstresiyle aynı küme.
                select x.id, x.islem_no, x.tur_adi, x.islem_tarihi, x.taraf_id, x.taraf_unvan, x.aciklama,
                       x.masraf_id, x.merkez_id, x.sube_id, x.yerel_borc, x.yerel_alacak
                  from public.v_masraf_ekstre x
                 where x.masraf_id is not null
                union all
                -- KALEMSİZ masraf bacağı: v_masraf_ekstre'nin tabanı (v_mali_hareket_ek), aynı durum kuralı.
                select x.id, x.islem_no, x.tur_adi, x.islem_tarihi, x.taraf_id, x.taraf_unvan, x.aciklama,
                       x.masraf_id, x.merkez_id, x.sube_id, x.yerel_borc, x.yerel_alacak
                  from public.v_mali_hareket_ek x
                 where x.hesap_turu = 'M' and x.masraf_id is null and x.hizmet_id is null and x.islem_durum = 2
               ) e
          join public.mali_hareket mh on mh.id = e.id
         where e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
           and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p2::int[]))
           and (@p3 = 0 or e.sube_id = @p3)
        union all
        select 'beyan'::varchar(12), s.id::bigint, p.id,
               (coalesce(nullif(p.beyan_no, ''), '#' || p.id) || ' · ' || s.belge_no)::varchar(60),
               'Masraf beyanı'::varchar(80), s.harcama_tarihi, 0,
               coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               coalesce(nullif(btrim(s.aciklama), ''), nullif(btrim(p.konu), ''), '')::varchar(200),
               coalesce(s.masraf_id, 0), 0, p.sube_id,
               (s.tutar - s.kdv_tutar)::numeric, s.tutar::numeric,
               0, false, 2, false, false, false, false
          from public.personel_masraf p
          join public.personel_masraf_satir s on s.beyan_id = p.id
          left join public.taraf t on t.id = p.taraf_id
         where p.durum = 2
           and s.harcama_tarihi >= @p0::date and s.harcama_tarihi <= @p1::date
           and p.sube_id = any(@p2::int[])
           and (@p3 = 0 or p.sube_id = @p3)
        """;

    /// <summary>Demirbaş yıllık amortismanı (v_demirbas_amortisman, 1006). @p0 ilk yıl · @p1 son yıl ·
    ///   @p2 şubeler · @p3 şube.</summary>
    private const string AmortismanSorgusu = """
        select a.demirbas_id, coalesce(nullif(d.kod, ''), '#' || d.id)::varchar(60), coalesce(d.ad, '')::varchar(200),
               coalesce(d.sube_id, 0), a.yil, coalesce(a.amortisman, 0)::numeric
          from public.v_demirbas_amortisman a
          join public.demirbas d on d.id = a.demirbas_id
         where a.yil between @p0 and @p1
           and d.sube_id = any(@p2::int[])
           and (@p3 = 0 or d.sube_id = @p3)
        """;

    /// <summary>
    /// CİRO = Satış İcmali'nin net satışı (TicariIcmalUclari, TL kipi, iade düşülmüş): kesin (durum 0)
    /// satış faturası / fişi (15, 16) belge.matrah toplamı − iadeleri. Satırsız belge de dip toplamıyla
    /// girer (orada da öyle). @p0 bas · @p1 bit · @p2 şubeler · @p3 şube · @p4 kapsam.
    /// </summary>
    private const string CiroSorgusu = """
        select coalesce(sum(case when coalesce(b.tipi, 0) = 2 then -1 else 1 end * coalesce(b.matrah, 0)), 0)::numeric
          from public.belge b
         where b.tur in (15, 16) and b.durum = 0
           and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
           and (b.sube_id is null or b.sube_id = any(@p2::int[]))
           and (@p3 = 0 or b.sube_id = @p3)
           and (cardinality(@p4::int[]) = 0 or b.taraf_id = any(@p4::int[]))
        """;

    // ============================================================= yardımcılar ===

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal? Degisim(decimal simdi, decimal once)
        => Math.Abs(once) > 0.005m ? Math.Round(100m * (simdi - once) / Math.Abs(once), 1) : null;
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static DateTime AyBasi(DateTime d) => new(d.Year, d.Month, 1);
    private static string Tarih(DateTime d) => d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static Donem DonemCoz(DateTime? bas, DateTime? bit, string? karsi, DateTime bugun)
    {
        var bitis = (bit ?? bugun).Date;
        var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
        if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
        if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
        var gun = (int)(bitis - baslangic).TotalDays + 1;
        // KARŞILAŞTIRMA: geçen yılın aynı dönemi (varsayılan, mockup) ya da hemen önceki eşit uzunlukta dönem.
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

    private static Gider GiderOku(NpgsqlDataReader o) => new(
        o.GetString(0), o.GetInt64(1), o.GetInt32(2), o.GetString(3), o.GetString(4), o.GetDateTime(5).Date, o.GetInt32(6),
        o.GetString(7), o.GetString(8), o.GetInt32(9), o.GetInt32(10), o.GetInt32(11), o.GetDecimal(12), o.GetDecimal(13),
        o.GetInt32(14), o.GetBoolean(15), o.GetInt32(16), o.GetBoolean(17), o.GetBoolean(18), o.GetBoolean(19), o.GetBoolean(20));

    /// <summary>Dönemin gider satırları (+ amortisman dahilse demirbaş başına ay payı). Süzgeçsiz.</summary>
    private static async Task<List<Gider>> GiderlerAsync(NpgsqlConnection b, DateTime bas, DateTime bit, int[] subeler, int s0,
        bool taslak, int[] kapsam, bool amortisman, CancellationToken iptal)
    {
        var l = await b.ListeAsync(GiderSorgusu, null, [bas, bit, subeler, s0, taslak ? 1 : 0, kapsam, GiderTurleri], GiderOku, iptal);
        if (!amortisman) return l;
        var am = await b.ListeAsync(AmortismanSorgusu, null, [bas.Year, bit.Year, subeler, s0], o => (
            id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), sube: o.GetInt32(3), yil: o.GetInt32(4), tutar: o.GetDecimal(5)), iptal);
        // GÜN ORANI: yıllık amortisman yılın gün sayısına bölünür; dönem / ay kesişimindeki gün kadarı yazılır.
        foreach (var a in am)
        {
            if (a.tutar == 0) continue;
            var yilBas = new DateTime(a.yil, 1, 1);
            var yilGun = DateTime.IsLeapYear(a.yil) ? 366m : 365m;
            for (var ay = 0; ay < 12; ay++)
            {
                var ab = yilBas.AddMonths(ay);
                var ason = ab.AddMonths(1).AddDays(-1);
                var k1 = ab < bas ? bas : ab;
                var k2 = ason > bit ? bit : ason;
                if (k2 < k1) continue;
                var gun = (decimal)((k2 - k1).TotalDays + 1);
                var tutar = R(a.tutar * gun / yilGun);
                if (tutar == 0) continue;
                l.Add(new Gider("amortisman", a.id, a.id, a.kod, "Amortisman (nakit çıkışı yok)", k1, 0, "", a.ad, 0, 0, a.sube,
                    tutar, tutar, 0, false, 2, false, false, false, false));
            }
        }
        return l;
    }

    private static async Task<Agac> AgacAsync(NpgsqlConnection b, CancellationToken iptal)
    {
        var masraflar = await b.ListeAsync("""
            select m.id, coalesce(m.kod, ''), coalesce(m.ad, ''), coalesce(m.ust_id, 0), coalesce(m.baslik_mi, 0) = 1,
                   coalesce(m.muh_kodu, ''), coalesce(m.durum, 0) = 1
              from public.masraf m
            """, null, [], o => new Masraf(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt32(3), o.GetBoolean(4),
                o.GetString(5), o.GetBoolean(6)), iptal);
        var merkezler = await b.ListeAsync("""
            select m.id, coalesce(m.kod, ''), coalesce(m.ad, ''), coalesce(m.ust_id, 0), coalesce(m.durum, 0) = 1
              from public.masraf_merkezi m
            """, null, [], o => new Merkez(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt32(3), o.GetBoolean(4)), iptal);
        return new Agac { Masraflar = masraflar.ToDictionary(x => x.Id), Merkezler = merkezler.ToDictionary(x => x.Id) };
    }

    /// <summary>Süzgeç yüklemi: kalem (alt dallarıyla) + merkez (alt dallarıyla).</summary>
    private static Func<Gider, bool> Suzucu(Agac a, Suzgec s)
    {
        HashSet<int>? kalemler = s.Kalem > 0 ? Agac.AltKume(s.Kalem, a.Masraflar.Values, x => x.Id, x => x.UstId) : null;
        HashSet<int>? merkezler = s.Merkez > 0 ? Agac.AltKume(s.Merkez, a.Merkezler.Values, x => x.Id, x => x.UstId) : null;
        return g =>
            (s.Kalem == 0 || (s.Kalem < 0 ? g.Kalem == s.Kalem : kalemler!.Contains(g.Kalem)))
            && (s.Merkez == 0 || (s.Merkez < 0 ? g.MerkezId == 0 : merkezler!.Contains(g.MerkezId)));
    }

    /// <summary>Uç parametrelerinden ortak hazırlık: dönem, süzgeç, ağaç, kümeler.</summary>
    private sealed class Hazirlik
    {
        public required Donem D { get; init; }
        public required Suzgec S { get; init; }
        public required DateTime Bugun { get; init; }
        public required Agac A { get; init; }
        public required int[] Subeler { get; init; }
        public required int[] Kapsam { get; init; }
        public required DateTime AcikDonemBasi { get; init; }
        /// <summary>Dönem içindeki süzülmüş gider.</summary>
        public required List<Gider> Cari { get; init; }
        /// <summary>Olağan dışı artış penceresi (son tam ay − 8 ay … bitiş) + dönem, süzülmüş.</summary>
        public required List<Gider> Genis { get; init; }
        public required DateTime TamAy { get; init; }
        public decimal T(Gider g) => g.Tutar(S.KdvDahil);
    }

    private static async Task<Hazirlik> HazirlaAsync(NpgsqlConnection b, IstekBaglami baglam, DateTime? bas, DateTime? bit,
        string? karsi, int? sube, int? merkez, int? kalem, int? kdv, int? plan, int? taslak, int? amortisman, CancellationToken iptal)
    {
        var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
        var d = DonemCoz(bas, bit, karsi, bugun);
        var s = new Suzgec(SubeCoz(baglam, sube), merkez ?? 0, kalem ?? 0, (kdv ?? 0) == 1, (plan ?? 1) == 1,
            (taslak ?? 0) == 1, (amortisman ?? 1) == 1);
        var subeler = baglam.Subeler.Select(x => x.Id).ToArray();
        var kapsam = baglam.Kapsam.ToArray();
        var agac = await AgacAsync(b, iptal);
        var uyar = Suzucu(agac, s);

        // Olağan dışı artış: son 3 TAM ay ortalaması önceki 6 ayınkiyle (içinde bulunulan ay yarımsa sayılmaz).
        var bitAy = AyBasi(d.Bit);
        var tamAy = d.Bit == bitAy.AddMonths(1).AddDays(-1) ? bitAy : bitAy.AddMonths(-1);
        var genisBas = tamAy.AddMonths(-8) < d.Bas ? tamAy.AddMonths(-8) : d.Bas;
        var genis = (await GiderlerAsync(b, genisBas, d.Bit, subeler, s.Sube, s.Taslak, kapsam, s.Amortisman, iptal)).Where(uyar).ToList();
        var cari = genis.Where(g => g.Tarih >= d.Bas && g.Tarih <= d.Bit).ToList();
        return new Hazirlik
        {
            D = d, S = s, Bugun = bugun, A = agac, Subeler = subeler, Kapsam = kapsam,
            AcikDonemBasi = await MuhasebeDonemi.AcikDonemBasiAsync(b, null, bugun, iptal),
            Cari = cari, Genis = genis, TamAy = tamAy,
        };
    }

    /// <summary>Satırın kalem atamasına engeli (boş = atanabilir). Yetki ayrıca (yetkiler.ata).</summary>
    private static string AtamaEngeli(Gider g, DateTime acikDonemBasi, bool kasaYetki)
    {
        if (g.Kaynak == "amortisman") return "Amortisman demirbaş kartından gelir.";
        if (g.Kaynak == "beyan") return "Masraf beyanının kalemi beyan kartında düzeltilir.";
        if (g.HizmetBagli) return "Satır bir hizmet kartına bağlı; belgede satırı masraf satırına çevirin.";
        if (g.Delphi) return "Delphi ERP'den gelen kayıt; değişikliği Delphi'de yapın.";
        if (g.Tarih < acikDonemBasi)
            return $"Kapanmış muhasebe dönemi ({acikDonemBasi.AddDays(-1):dd.MM.yyyy} ve öncesi); yalnız görüntülenir.";
        if (g.Kaynak == "kasa" && g.GunKapali) return "Kasa günü kapalı; Gün Sonu ekranından açılmadan değiştirilemez.";
        if (g.Kaynak == "kasa" && !kasaYetki) return "Kasa işlemi değiştirme yetkiniz yok.";
        return "";
    }

    private static object DetaySatiri(Gider g, Hazirlik h, bool kasaYetki) => new
    {
        kaynak = g.Kaynak, satirId = g.SatirId, belgeId = g.BelgeId, no = g.No, kaynakAdi = g.KaynakAdi, tarih = Tarih(g.Tarih),
        tarafId = g.TarafId, taraf = g.Taraf, aciklama = g.Aciklama, kalemId = g.Kalem, kalem = h.A.Ad(g.Kalem),
        kalemKod = h.A.KodAdi(g.Kalem), ustKalem = h.A.Ad(h.A.Ust(g.Kalem)), merkezId = g.MerkezId, merkez = h.A.MerkezAdi(g.MerkezId),
        haric = R(g.Tutar(false)), kdv = R(g.Kdv), tutar = R(h.T(g)), kdvOran = g.KdvOran, iade = g.Iade, taslak = g.Durum == 1,
        fis = g.Fis, atamaEngeli = AtamaEngeli(g, h.AcikDonemBasi, kasaYetki),
    };

    // ================================================================== uçlar ===

    public static void MasrafIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/masraf-icmal").WithTags("Masraf İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? karsi, int? sube, int? merkez, int? kalem, int? kdv,
                                int? plan, int? taslak, int? amortisman,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var h = await HazirlaAsync(b, baglam, bas, bit, karsi, sube, merkez, kalem, kdv, plan, taslak, amortisman, iptal);
            var d = h.D;
            var s = h.S;
            var a = h.A;
            var uyar = Suzucu(a, s);

            var karsiKume = (await GiderlerAsync(b, d.KBas, d.KBit, h.Subeler, s.Sube, s.Taslak, h.Kapsam, s.Amortisman, iptal))
                .Where(uyar).ToList();
            var gyBas = d.Bas.AddYears(-1);
            var gyBit = d.Bit.AddYears(-1);
            var gecenYil = d.Karsi == "gy" ? karsiKume
                : (await GiderlerAsync(b, gyBas, gyBit, h.Subeler, s.Sube, s.Taslak, h.Kapsam, s.Amortisman, iptal)).Where(uyar).ToList();

            var esik = await AyarDeposu.OndalikAsync(b, null, "masraf.artis_esik_yuzde", iptal) ?? 25m;
            if (esik <= 0) esik = 25m;
            var mukerrerGun = (int)Math.Round(await AyarDeposu.OndalikAsync(b, null, "masraf.mukerrer_gun", iptal) ?? 1m);
            if (mukerrerGun < 0) mukerrerGun = 1;

            var cari = h.Cari;
            var top = cari.Sum(h.T);
            var karsiTop = karsiKume.Sum(h.T);
            var haricTop = cari.Sum(g => g.Tutar(false));

            // ------------------------------------------------------- aylar --
            var aylarListe = new List<DateTime>();
            for (var ay = AyBasi(d.Bas); ay <= d.Bit; ay = ay.AddMonths(1)) aylarListe.Add(ay);
            if (aylarListe.Count > 36) aylarListe = aylarListe.Skip(aylarListe.Count - 36).ToList();
            var ayAdedi = Math.Max(aylarListe.Count, 1);
            var ayTutar = cari.GroupBy(g => AyBasi(g.Tarih)).ToDictionary(g => g.Key, g => g.Sum(h.T));
            var gyAyTutar = gecenYil.GroupBy(g => AyBasi(g.Tarih).AddYears(1)).ToDictionary(g => g.Key, g => g.Sum(h.T));

            // ------------------------------------------------------- plan (Planlı Giderler) --
            var paket = await PlanliGiderMotoru.YukleAsync(b, null, null, s.Sube > 0 ? [s.Sube] : h.Subeler, h.Bugun, iptal);
            var tanimliKalem = paket.Tanimlar.Where(t => t.MasrafId is > 0).Select(t => t.MasrafId!.Value).ToHashSet();
            var kalemKume = s.Kalem > 0 ? Agac.AltKume(s.Kalem, a.Masraflar.Values, x => x.Id, x => x.UstId) : null;
            var merkezKume = s.Merkez > 0 ? Agac.AltKume(s.Merkez, a.Merkezler.Values, x => x.Id, x => x.UstId) : null;
            bool TanimUyar(PlanliGiderMotoru.Tanim t)
                => t.MasrafId is > 0
                   && (s.Kalem == 0 || (s.Kalem > 0 && kalemKume!.Contains(t.MasrafId!.Value)))
                   && (s.Merkez == 0 || (s.Merkez < 0 ? (t.MasrafMerkeziId ?? 0) == 0 : merkezKume!.Contains(t.MasrafMerkeziId ?? 0)));
            var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, [], iptal) ?? "TL";
            var kurlar = new Dictionary<string, decimal>();
            var uyarilar = new List<string>();
            async Task<decimal> KurAsync(string doviz)
            {
                if (kurlar.TryGetValue(doviz, out var k)) return k;
                var iso = await b.TekDegerAsync<string>("select public.fn_doviz_iso(@p0)::varchar(6)", null, [doviz], iptal) ?? doviz;
                if (iso == yerel) k = 1m;
                else
                {
                    k = await b.TekDegerAsync<decimal?>("select public.fn_doviz_kur_getir(@p0, @p1::date, 2::smallint)", null,
                        [iso, h.Bugun], iptal) ?? 1m;
                    uyarilar.Add($"{iso} planlı giderler bugünkü kurla ({k.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"))}) TL'ye çevrildi.");
                }
                kurlar[doviz] = k;
                return k;
            }

            var planAy = new Dictionary<DateTime, decimal>();
            var planGrup = new List<(int MasrafId, List<PlanliGiderMotoru.Tanim> Tanimlar, decimal Plan, int Donem, int Eslesen,
                int Odenmemis, bool Tahmini)>();
            foreach (var g in paket.Tanimlar.Where(TanimUyar).GroupBy(t => t.MasrafId!.Value))
            {
                decimal pl = 0; int dn = 0, es = 0, od = 0; var th = false;
                foreach (var t in g)
                {
                    var kur = await KurAsync(t.Doviz);
                    foreach (var p0 in paket.Donemler(t, d.Bit))
                    {
                        if (p0.Atlandi) continue;
                        var gun = p0.PlanTarihi.Date;
                        if (gun < d.Bas || gun > d.Bit) continue;
                        // Tanım yokken "planlanmış" sayılmaz; pasif tanım yalnız dondurulmuş / eşleşmiş dönemiyle.
                        if (!p0.Dondurulmus && !p0.Eslesti && (t.Durum != 1 || gun < t.EklemeTarihi.Date)) continue;
                        var tutar = (s.KdvDahil ? p0.KdvHaric + p0.Kdv : p0.KdvHaric) * kur;
                        pl += tutar; dn++;
                        if (p0.Eslesti) es++;
                        else if (gun < h.Bugun) od++;
                        if (p0.Tahmini) th = true;
                        var ay = AyBasi(gun);
                        planAy[ay] = planAy.GetValueOrDefault(ay) + tutar;
                    }
                }
                if (dn > 0) planGrup.Add((g.Key, g.ToList(), pl, dn, es, od, th));
            }
            // Gerçek = aynı masraf kalemi (kalem başlıksa alt dallarıyla).
            HashSet<int> PlanKalemleri(int masrafId)
                => a.Masraflar.TryGetValue(masrafId, out var m) && m.Baslik
                    ? Agac.AltKume(masrafId, a.Masraflar.Values, x => x.Id, x => x.UstId) : [masrafId];
            var planKume = planGrup.SelectMany(x => PlanKalemleri(x.MasrafId)).ToHashSet();
            var planSatirlari = planGrup.Select(x =>
            {
                var kume = PlanKalemleri(x.MasrafId);
                var gercek = cari.Where(g => kume.Contains(g.Kalem)).Sum(h.T);
                var fark = gercek - x.Plan;
                var fy = x.Plan != 0 ? Math.Round(100m * fark / x.Plan, 1) : (decimal?)null;
                var (durum, durumAdi) =
                    x.Odenmemis > 0 && fark < 0 ? ("odenmedi", $"{x.Odenmemis} dönem ödenmedi")
                    : fy is { } f1 && Math.Abs(f1) <= 5m ? ("planinda", "planında")
                    : fark > 0 ? (x.Tahmini ? ("tahmin", "tahmin düşük · ort. güncellenir") : ("artis", "plan dışı artış"))
                    : ("alti", "planın altında");
                return new
                {
                    masrafId = x.MasrafId, ad = string.Join(" · ", x.Tanimlar.Select(t => t.Ad).Distinct()),
                    tanimlar = x.Tanimlar.Select(t => new { id = t.Id, ad = t.Ad }).ToList(),
                    kalem = a.Ad(x.MasrafId), kod = a.KodAdi(x.MasrafId),
                    plan = R(x.Plan), gercek = R(gercek), fark = R(fark), farkYuzde = fy,
                    donem = x.Donem, eslesen = x.Eslesen, odenmemis = x.Odenmemis, tahmini = x.Tahmini, durum, durumAdi,
                };
            }).OrderByDescending(x => Math.Abs(x.fark)).ToList();
            var planTop = planSatirlari.Sum(x => x.plan);
            var planGercekTop = planSatirlari.Sum(x => x.gercek);
            var planAyGercek = cari.Where(g => planKume.Contains(g.Kalem)).GroupBy(g => AyBasi(g.Tarih)).ToDictionary(g => g.Key, g => g.Sum(h.T));

            // ------------------------------------------------------- olağan dışı artış (üst kalem) --
            var son3 = Enumerable.Range(0, 3).Select(i => h.TamAy.AddMonths(-i)).ToHashSet();
            var once6 = Enumerable.Range(3, 6).Select(i => h.TamAy.AddMonths(-i)).ToHashSet();
            var artis = h.Genis.Where(g => g.Kalem != KalemAmortisman).GroupBy(g => a.Ust(g.Kalem)).Select(g =>
            {
                var s3 = g.Where(x => son3.Contains(AyBasi(x.Tarih))).Sum(h.T) / 3m;
                var o6 = g.Where(x => once6.Contains(AyBasi(x.Tarih))).Sum(h.T) / 6m;
                return (ust: g.Key, s3, o6, oran: o6 > 0.005m ? Math.Round(100m * (s3 - o6) / o6, 1) : (decimal?)null);
            }).Where(x => x.oran is { } o && o > esik).ToDictionary(x => x.ust);

            // ------------------------------------------------------- kalem ağacı --
            var karsiUst = karsiKume.GroupBy(g => a.Ust(g.Kalem)).ToDictionary(g => g.Key, g => g.Sum(h.T));
            var karsiAlt = karsiKume.GroupBy(g => g.Kalem).ToDictionary(g => g.Key, g => g.Sum(h.T));
            var cariUst = cari.GroupBy(g => a.Ust(g.Kalem)).ToDictionary(g => g.Key, g => g.ToList());
            var ustAnahtar = cariUst.Keys.Union(karsiUst.Keys).ToList();
            var kalemler = ustAnahtar.Select(u =>
            {
                var l = cariUst.GetValueOrDefault(u) ?? [];
                var t = l.Sum(h.T);
                var k = karsiUst.GetValueOrDefault(u);
                var altlar = l.Select(g => g.Kalem).Concat(karsiKume.Where(g => a.Ust(g.Kalem) == u).Select(g => g.Kalem)).Distinct()
                    .Select(id =>
                    {
                        var at = l.Where(g => g.Kalem == id).Sum(h.T);
                        var ak = karsiAlt.GetValueOrDefault(id);
                        return new
                        {
                            id, kod = a.KodAdi(id), ad = a.Ad(id), muhKodu = a.Muh(id), tutar = R(at), karsi = R(ak),
                            degisim = Degisim(at, ak), pay = Yuzde(at, top), aylikOrt = R(at / ayAdedi),
                            satir = l.Count(g => g.Kalem == id), dogrudan = id == u,
                        };
                    }).OrderByDescending(x => x.tutar).ToList();
                artis.TryGetValue(u, out var ar);
                return new
                {
                    id = u, kod = a.KodAdi(u), ad = a.Ad(u), muhKodu = a.Muh(u), tutar = R(t), karsi = R(k), degisim = Degisim(t, k),
                    pay = Yuzde(t, top), aylikOrt = R(t / ayAdedi), satir = l.Count,
                    artis = ar.oran, nakitDisi = u == KalemAmortisman, atanmamis = u == KalemAtanmamis,
                    plani = planKume.Overlaps(altlar.Select(x => x.id)),
                    altlar,
                };
            }).OrderBy(x => x.atanmamis ? 2 : x.nakitDisi ? 1 : 0).ThenByDescending(x => x.tutar).ToList();

            // ------------------------------------------------------- merkez × üst kalem --
            var kolonlar = kalemler.Where(x => !x.atanmamis && x.tutar != 0).OrderByDescending(x => x.tutar).Take(6)
                .Select(x => (id: x.id, ad: x.ad)).ToList();
            var kolonId = kolonlar.Select(x => x.id).ToHashSet();
            int Kolon(Gider g) { var u = a.Ust(g.Kalem); return kolonId.Contains(u) ? u : KolonDiger; }
            var kolonSirasi = kolonlar.Select(x => x.id).Append(KolonDiger).ToList();
            decimal[] Hucreler(IEnumerable<Gider> l)
            {
                var gr = l.GroupBy(Kolon).ToDictionary(g => g.Key, g => g.Sum(h.T));
                return kolonSirasi.Select(k => R(gr.GetValueOrDefault(k))).ToArray();
            }
            var merkezSatirlari = cari.GroupBy(g => g.MerkezId).Select(g =>
            {
                var t = g.Sum(h.T);
                return new { id = g.Key <= 0 ? -1 : g.Key, ad = a.MerkezAdi(g.Key), hucreler = Hucreler(g), toplam = R(t), pay = Yuzde(t, top) };
            }).OrderBy(x => x.id == -1 ? 1 : 0).ThenByDescending(x => x.toplam).ToList();

            // ------------------------------------------------------- trend --
            var enBuyukAy = Math.Max(aylarListe.Count > 0 ? aylarListe.Max(x => ayTutar.GetValueOrDefault(x)) : 0, 0.01m);
            var trend = aylarListe.Select(ay =>
            {
                var t = ayTutar.GetValueOrDefault(ay);
                var gy = gyAyTutar.GetValueOrDefault(ay);
                decimal? pl = s.Plan && planGrup.Count > 0 ? R(planAy.GetValueOrDefault(ay)) : null;
                decimal? pg = pl is null ? null : R(planAyGercek.GetValueOrDefault(ay));
                return new
                {
                    ay = Tarih(ay), tutar = R(t), gecenYil = R(gy), degisim = Degisim(t, gy), plan = pl, planGercek = pg,
                    planFark = pl is { } p1 && pg is { } g1 ? R(g1 - p1) : (decimal?)null,
                    kismiGun = ay.Year == d.Bit.Year && ay.Month == d.Bit.Month && d.Bit.Day < DateTime.DaysInMonth(ay.Year, ay.Month)
                        ? d.Bit.Day : (int?)null,
                    cubuk = Yuzde(Math.Max(t, 0), enBuyukAy),
                };
            }).ToList();

            // ------------------------------------------------------- tedarikçi --
            var karsiCari = karsiKume.Where(g => g.TarafId > 0).GroupBy(g => g.TarafId).ToDictionary(g => g.Key, g => g.Sum(h.T));
            var tedarikciler = cari.Where(g => g.TarafId > 0).GroupBy(g => g.TarafId).Select(g =>
            {
                var t = g.Sum(h.T);
                var var0 = karsiCari.TryGetValue(g.Key, out var k);
                var ana = g.GroupBy(x => x.Kalem).OrderByDescending(x => x.Sum(h.T)).First().Key;
                return new
                {
                    id = g.Key, ad = g.First().Taraf, anaKalem = a.Ad(ana), anaKalemId = ana, tutar = R(t),
                    belge = g.Select(x => (x.Kaynak, x.BelgeId)).Distinct().Count(),
                    karsi = var0 ? R(k) : (decimal?)null, degisim = Degisim(t, k), pay = Yuzde(t, top),
                };
            }).OrderByDescending(x => x.tutar).ToList();

            // ------------------------------------------------------- dikkat --
            var dikkat = new List<object>();
            var atanmamis = cari.Where(g => g.Kalem == KalemAtanmamis).ToList();
            if (atanmamis.Count > 0)
                dikkat.Add(new
                {
                    tur = "atanmamis", turAdi = "Kalem atanmamış", kayit = $"{atanmamis.Count} satır", tarih = (string?)null,
                    aciklama = $"Hizmet / masraf satırında ya da masraf bacağında kalem yok → \"Diğer\"e düştü ({R(atanmamis.Sum(h.T)).ToString("N2", CultureInfo.GetCultureInfo("tr-TR"))} ₺)",
                    oneri = "\"Masraf kalemi ata…\" (toplu)", kalemId = KalemAtanmamis, belgeler = Array.Empty<object>(),
                });
            foreach (var (u, x) in artis.OrderByDescending(kv => kv.Value.oran))
                dikkat.Add(new
                {
                    tur = "artis", turAdi = "Olağan dışı artış", kayit = $"{a.Ad(u)} {a.KodAdi(u)}".Trim(),
                    tarih = (string?)$"{h.TamAy.AddMonths(-2):MM.yyyy}–{h.TamAy:MM.yyyy}",
                    aciklama = $"Son 3 ay ortalaması önceki 6 ayın %{x.oran!.Value.ToString("0.#", CultureInfo.GetCultureInfo("tr-TR"))} üstünde",
                    oneri = "Anlaşma / fatura kontrolü", kalemId = u, belgeler = Array.Empty<object>(),
                });
            // MÜKERRER: aynı cari + aynı belge tutarı (KDV dahil) ± mukerrerGun gün, farklı belge.
            var belgeTop = cari.Where(g => g.Kaynak == "belge" && g.TarafId > 0 && !g.Iade).GroupBy(g => g.BelgeId)
                .Select(g => (id: g.Key, no: g.First().No, taraf: g.First().TarafId, ad: g.First().Taraf, tarih: g.First().Tarih,
                    tutar: R(g.Sum(x => x.Dahil)))).Where(x => x.tutar > 0).ToList();
            var mukerrer = 0;
            foreach (var gr in belgeTop.GroupBy(x => (x.taraf, x.tutar)))
            {
                var l = gr.OrderBy(x => x.tarih).ToList();
                for (var i = 1; i < l.Count && mukerrer < 50; i++)
                {
                    if ((l[i].tarih - l[i - 1].tarih).TotalDays > mukerrerGun) continue;
                    mukerrer++;
                    dikkat.Add(new
                    {
                        tur = "mukerrer", turAdi = "Mükerrer şüphesi", kayit = $"{l[i - 1].no} / {l[i].no}", tarih = (string?)Tarih(l[i].tarih),
                        aciklama = $"{l[i].ad}: aynı tutar ({gr.Key.tutar.ToString("N2", CultureInfo.GetCultureInfo("tr-TR"))}), {(l[i].tarih == l[i - 1].tarih ? "aynı gün" : $"{(l[i].tarih - l[i - 1].tarih).TotalDays:0} gün arayla")}",
                        oneri = "Belgeleri karşılaştır", kalemId = 0,
                        belgeler = new object[] { new { id = l[i - 1].id, no = l[i - 1].no }, new { id = l[i].id, no = l[i].no } },
                    });
                }
            }
            // KDV ORANI FARKLI: aynı kalem + aynı cari, en son belgenin oranı öncekilerin en sık oranından farklı.
            foreach (var gr in h.Genis.Where(g => g.Kaynak == "belge" && g.MasrafId > 0 && g.TarafId > 0 && !g.Iade)
                         .GroupBy(g => (g.MasrafId, g.TarafId)))
            {
                var sonTarih = gr.Max(x => x.Tarih);
                if (sonTarih < d.Bas) continue;
                var son = gr.Where(x => x.Tarih == sonTarih).ToList();
                var once = gr.Where(x => x.Tarih < sonTarih).ToList();
                if (once.Select(x => x.BelgeId).Distinct().Count() < 2) continue;
                var mod = once.GroupBy(x => x.KdvOran).OrderByDescending(x => x.Count()).First().Key;
                var sonOran = son.GroupBy(x => x.KdvOran).OrderByDescending(x => x.Count()).First().Key;
                if (sonOran == mod) continue;
                dikkat.Add(new
                {
                    tur = "kdv", turAdi = "KDV oranı farklı", kayit = $"{a.Ad(gr.Key.MasrafId)} · {son[0].Taraf}", tarih = (string?)Tarih(sonTarih),
                    aciklama = $"Önceki belgeler %{mod}, son belge ({son[0].No}) %{sonOran}", oneri = "Faturayı kontrol et",
                    kalemId = gr.Key.MasrafId, belgeler = new object[] { new { id = son[0].BelgeId, no = son[0].No } },
                });
            }
            // PLANDA YOK: en az 3 ayda tekrarlayan, planlı gider tanımı olmayan kalem (planlı gider hiç kullanılmıyorsa sorulmaz).
            if (paket.Tanimlar.Count > 0)
                foreach (var x in cari.Where(g => g.MasrafId > 0 && !tanimliKalem.Contains(g.MasrafId)).GroupBy(g => g.MasrafId)
                             .Where(g => g.Select(y => AyBasi(y.Tarih)).Distinct().Count() >= 3)
                             .Select(g => (id: g.Key, tutar: g.Sum(h.T))).OrderByDescending(g => g.tutar).Take(10))
                    dikkat.Add(new
                    {
                        tur = "plansiz", turAdi = "Planda yok", kayit = $"{a.Ad(x.id)} {a.KodAdi(x.id)}".Trim(), tarih = (string?)null,
                        aciklama = $"Dönemde {R(x.tutar).ToString("N2", CultureInfo.GetCultureInfo("tr-TR"))} ₺, tekrarlayan gider; planlı gider tanımı yok",
                        oneri = "Planlı gider tanımla?", kalemId = x.id, belgeler = Array.Empty<object>(),
                    });

            // ------------------------------------------------------- özet --
            var son3Ay = aylarListe.TakeLast(3).ToList();
            var ciro = await b.TekDegerAsync<decimal?>(CiroSorgusu, null, [d.Bas, d.Bit, h.Subeler, s.Sube, h.Kapsam], iptal) ?? 0m;
            var enBuyuk = kalemler.Where(x => !x.atanmamis && !x.nakitDisi).OrderByDescending(x => x.tutar).FirstOrDefault();
            var farkKalem = planSatirlari.Where(x => x.fark > 0).OrderByDescending(x => x.fark).Take(2).Select(x => x.ad).ToList();
            var amTop = cari.Where(g => g.Kalem == KalemAmortisman).Sum(h.T);
            var kasaYetki = baglam.Yetkiler.Var("kasa_islem", Islem.Degistir);
            var ozet = new
            {
                toplam = R(top), karsi = R(karsiTop), degisim = Degisim(top, karsiTop), ay = aylarListe.Count,
                aylikOrt = R(top / ayAdedi),
                son3Ort = son3Ay.Count > 0 ? R(son3Ay.Sum(x => ayTutar.GetValueOrDefault(x)) / son3Ay.Count) : 0m,
                plan = R(planTop), planGercek = R(planGercekTop), planFark = R(planGercekTop - planTop),
                planFarkYuzde = planTop != 0 ? Math.Round(100m * (planGercekTop - planTop) / planTop, 1) : (decimal?)null,
                planTanim = planGrup.Sum(x => x.Tanimlar.Count), planFarkKalemler = farkKalem,
                enBuyuk = enBuyuk is null ? null : new { id = enBuyuk.id, ad = enBuyuk.ad, tutar = enBuyuk.tutar, pay = enBuyuk.pay },
                ciro = R(ciro), giderCiro = ciro > 0.005m ? Math.Round(100m * haricTop / ciro, 1) : (decimal?)null,
                atanmamis = new { satir = atanmamis.Count, tutar = R(atanmamis.Sum(h.T)) },
                satir = cari.Count(g => g.Kaynak != "amortisman"), kalem = cari.Where(g => g.MasrafId > 0).Select(g => g.MasrafId).Distinct().Count(),
                merkez = cari.Where(g => g.MerkezId > 0).Select(g => g.MerkezId).Distinct().Count(),
                amortisman = new { dahil = s.Amortisman, tutar = R(amTop) },
                beyan = R(cari.Where(g => g.Kaynak == "beyan").Sum(h.T)),
                kasa = R(cari.Where(g => g.Kaynak == "kasa").Sum(h.T)),
            };

            var kalemSecim = a.Masraflar.Values.Where(m => m.Aktif).OrderBy(m => m.Kod).ThenBy(m => m.Ad).ToList();
            return Results.Ok(new
            {
                bas = Tarih(d.Bas), bit = Tarih(d.Bit), karsi = new { tur = d.Karsi, bas = Tarih(d.KBas), bit = Tarih(d.KBit) },
                gecenYil = new { bas = Tarih(gyBas), bit = Tarih(gyBit) }, gun = d.Gun,
                sube = s.Sube, merkez = s.Merkez, kalem = s.Kalem, kdvDahil = s.KdvDahil, planKiyas = s.Plan, taslak = s.Taslak,
                amortismanDahil = s.Amortisman, acikDonemBasi = Tarih(h.AcikDonemBasi),
                esik = new { artisYuzde = esik, mukerrerGun },
                ozet,
                kalemler,
                kalemToplam = new { tutar = R(top), karsi = R(karsiTop), degisim = Degisim(top, karsiTop), aylikOrt = R(top / ayAdedi) },
                merkezMatris = new
                {
                    kolonlar = kolonlar.Select(x => new { id = x.id, ad = x.ad }).Append(new { id = KolonDiger, ad = "Diğer" }).ToList(),
                    satirlar = merkezSatirlari,
                    toplam = new { hucreler = Hucreler(cari), toplam = R(top) },
                },
                trend,
                plan = new
                {
                    satirlar = planSatirlari,
                    toplam = new
                    {
                        plan = R(planTop), gercek = R(planGercekTop), fark = R(planGercekTop - planTop),
                        farkYuzde = planTop != 0 ? Math.Round(100m * (planGercekTop - planTop) / planTop, 1) : (decimal?)null,
                        tanim = planGrup.Sum(x => x.Tanimlar.Count),
                    },
                },
                tedarikciler,
                dikkat,
                uyarilar,
                secim = new
                {
                    subeler = baglam.Subeler.Select(x => new { id = x.Id, ad = x.Ad }).ToList(),
                    merkezler = a.Merkezler.Values.Where(m => m.Aktif).OrderBy(m => m.Ad).Select(m => new { id = m.Id, ad = m.Ad }).ToList(),
                    // Ağaç: üst kalemler ve altları (süzgeç alt dallarıyla süzer).
                    kalemler = kalemSecim.Where(m => m.UstId == 0 || !a.Masraflar.ContainsKey(m.UstId))
                        .SelectMany(k => new[] { new { id = k.Id, ad = $"{k.Kod} {k.Ad}".Trim(), derinlik = 0, baslik = k.Baslik } }
                            .Concat(kalemSecim.Where(m => m.Id != k.Id && a.Ust(m.Id) == k.Id)
                                .Select(m => new { id = m.Id, ad = $"{m.Kod} {m.Ad}".Trim(), derinlik = 1, baslik = m.Baslik })))
                        .ToList(),
                    // "Masraf kalemi ata": başlık olmayan aktif kalemler.
                    atanabilir = kalemSecim.Where(m => !m.Baslik).Select(m => new
                    {
                        id = m.Id, kod = m.Kod, ad = m.Ad, ust = m.UstId > 0 && m.UstId != m.Id ? a.Ad(a.Ust(m.Id)) : "",
                    }).ToList(),
                },
                yetkiler = new
                {
                    // ATA = belge değiştirme (EslesmeIcmal "Bağla" ile aynı kapı); kasa bacağı ayrıca kasa_islem Değiştir.
                    ata = baglam.Yetkiler.Var("belge", Islem.Degistir) && baglam.SubeYazma,
                    kasaAta = kasaYetki && baglam.Yetkiler.Var("belge", Islem.Degistir) && baglam.SubeYazma,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================================ DETAY ===
        // Belge Detayı sekmesi: kalem / merkez / tedarikçi tıklamasıyla süzülmüş gider satırları.
        //   ust: üst kalem (-1 atanmamış, -2 amortisman) · alt: kalem (tam eşleşme) · dmerkez: merkez satırı
        //   (-1 atanmamış, tam eşleşme) · tedarikci: cari.
        grup.MapGet("/detay", async (DateTime? bas, DateTime? bit, string? karsi, int? sube, int? merkez, int? kalem, int? kdv,
                                     int? taslak, int? amortisman, int? ust, int? alt, int? dmerkez, int? tedarikci,
                                     VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            await using var b = await veri.AcAsync(iptal);
            var h = await HazirlaAsync(b, baglam, bas, bit, karsi, sube, merkez, kalem, kdv, 1, taslak, amortisman, iptal);
            var a = h.A;
            var l = h.Cari.AsEnumerable();
            var basliklar = new List<string>();
            if (ust is { } u && u != 0) { l = l.Where(g => a.Ust(g.Kalem) == u); basliklar.Add($"{a.Ad(u)} {a.KodAdi(u)}".Trim()); }
            if (alt is { } al && al != 0) { l = l.Where(g => g.Kalem == al); basliklar.Add($"{a.Ad(al)} {a.KodAdi(al)}".Trim()); }
            if (dmerkez is { } dm && dm != 0) { l = l.Where(g => dm < 0 ? g.MerkezId == 0 : g.MerkezId == dm); basliklar.Add(a.MerkezAdi(dm)); }
            if (tedarikci is > 0) { l = l.Where(g => g.TarafId == tedarikci.Value); basliklar.Add(h.Cari.FirstOrDefault(g => g.TarafId == tedarikci.Value)?.Taraf ?? ""); }
            var liste = l.OrderByDescending(g => g.Tarih).ThenByDescending(g => g.SatirId).ToList();
            var kasaYetki = baglam.Yetkiler.Var("kasa_islem", Islem.Degistir);
            return Results.Ok(new
            {
                baslik = basliklar.Count > 0 ? string.Join(" · ", basliklar.Where(x => x.Length > 0)) : "Bütün giderler",
                sayi = liste.Count,
                toplam = new { haric = R(liste.Sum(g => g.Tutar(false))), kdv = R(liste.Sum(g => g.Kdv)), tutar = R(liste.Sum(h.T)) },
                atanabilir = liste.Count(g => AtamaEngeli(g, h.AcikDonemBasi, kasaYetki).Length == 0),
                satirlar = liste.Take(2000).Select(g => DetaySatiri(g, h, kasaYetki)).ToList(),
                acikDonemBasi = Tarih(h.AcikDonemBasi),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // =================================================================== ATA ===
        // Seçili gider satırlarına masraf kalemi atar. Belge satırı: masraf_id + tur 3 (masraf satırı -
        //   BelgeDeposu'nun tur/bağ kuralı: tur 3 ↔ masrafId); hizmet kartına bağlı satır atanmaz (bir satır tek
        //   bağ taşır, ck_belge_satir_urun). Kasa: masraf bacağı (mali_hareket hesap_turu 'M') + işlemin
        //   başlığı (kasa_islem.masraf_id - bacak yeniden üretilirse aynı kalem gelsin). Tutar, cari ve stok
        //   değişmez. KAPANMIŞ DÖNEM reddedilir (karar 25.10.2026). Loglu (belge 30 / kasa 908).
        grup.MapPost("/ata", async (AtaIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste("belge", Islem.Degistir);
            if (!baglam.SubeYazma) throw GentegreHatasi.Yasak("Aktif şubede değişiklik yetkiniz yok.");
            var satirlar = (istek.Satirlar ?? []).Where(x => x.Id > 0).ToList();
            if (istek.MasrafId <= 0) throw GentegreHatasi.Dogrulama("Masraf kalemi seçilmeli.", new AlanHatasi("masrafId", "Zorunlu."));
            if (satirlar.Count == 0) throw GentegreHatasi.Dogrulama("Atanacak satır seçilmedi.", new AlanHatasi("satirlar", "Boş bırakılamaz."));
            if (satirlar.Count > 500) throw GentegreHatasi.Dogrulama("Tek seferde en çok 500 satır atanır.");
            if (satirlar.Any(x => x.Kaynak is not ("belge" or "kasa")))
                throw GentegreHatasi.IsKurali("Yalnız belge satırına ve kasa masraf bacağına kalem atanır (masraf beyanı kendi kartında, amortisman demirbaşta).");
            var belgeIdleri = satirlar.Where(x => x.Kaynak == "belge").Select(x => x.Id).Distinct().ToArray();
            var kasaIdleri = satirlar.Where(x => x.Kaynak == "kasa").Select(x => x.Id).Distinct().ToArray();
            if (kasaIdleri.Length > 0) baglam.YetkiIste("kasa_islem", Islem.Degistir);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);

            var masraf = await b.TekAsync("""
                select m.id, coalesce(m.kod, ''), coalesce(m.ad, ''), coalesce(m.baslik_mi, 0)::int, coalesce(m.durum, 0)::int
                  from public.masraf m where m.id = @p0
                """, tx, [istek.MasrafId], o => new { id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                    baslik = o.GetInt32(3), durum = o.GetInt32(4) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Masraf kalemi bulunamadı.");
            if (masraf.baslik == 1) throw GentegreHatasi.IsKurali($"{masraf.ad} bir başlık (üst kalem); alt kalemlerinden birini seçin.");
            if (masraf.durum != 1) throw GentegreHatasi.IsKurali($"{masraf.ad} pasif bir masraf kalemi.");
            var masrafAdi = $"{masraf.kod} {masraf.ad}".Trim();
            var acikDonemBasi = await MuhasebeDonemi.AcikDonemBasiAsync(b, tx, bugun, iptal);
            var kapanis = acikDonemBasi.AddDays(-1).ToString("dd.MM.yyyy", CultureInfo.InvariantCulture);
            var uyarilar = new List<string>();

            // ------------------------------------------------------ 1) belge satırları --
            var bs = await b.ListeAsync("""
                select s.id, s.belge_id, s.stok_id is not null, s.hizmet_id is not null, coalesce(s.masraf_id, 0), s.tur::int,
                       b.tur::int, coalesce(b.tipi, 0)::int, coalesce(b.durum, 0)::int, b.sube_id, b.belge_tarihi,
                       coalesce(nullif(b.belge_no, ''), '#' || b.id), coalesce(b.taraf_id, 0),
                       (coalesce(s.aktarim_kaynak, 0) = 1 or coalesce(b.aktarim_kaynak, 0) = 1) and public.fn_veri_kaynagi_delphi(),
                       exists (select 1 from public.muhasebe_fis f where f.kaynak_tur = 2 and f.kaynak_id = b.id and f.durum = 1)
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                 where s.id = any(@p0::int[])
                   for update of s
                """, tx, [belgeIdleri], o => (id: o.GetInt32(0), belgeId: o.GetInt32(1), stoklu: o.GetBoolean(2), hizmet: o.GetBoolean(3),
                    eski: o.GetInt32(4), satirTur: o.GetInt32(5), tur: o.GetInt32(6), tipi: o.GetInt32(7), durum: o.GetInt32(8),
                    sube: o.IsDBNull(9) ? (int?)null : o.GetInt32(9), tarih: o.GetDateTime(10), no: o.GetString(11), taraf: o.GetInt32(12),
                    delphi: o.GetBoolean(13), fis: o.GetBoolean(14)), iptal);
            if (bs.Count != belgeIdleri.Length) throw GentegreHatasi.Bulunamadi("Seçili belge satırlarından biri bulunamadı.");
            foreach (var x in bs)
            {
                var ad = $"{x.no} satır #{x.id}";
                if (x.sube is { } sb && !baglam.Subeler.Any(y => y.Id == sb)) throw GentegreHatasi.Bulunamadi("Belge satırı bulunamadı.");
                if (!GiderTurleri.Contains(x.tur)) throw GentegreHatasi.IsKurali($"{ad}: yalnız alış faturası / fişi / gider pusulası satırı.");
                if (x.durum is not (0 or 1)) throw GentegreHatasi.IsKurali($"{ad}: iptal edilmiş belge.");
                if (x.stoklu) throw GentegreHatasi.IsKurali($"{ad}: stoklu satır gider değildir (stoğa girer); kalem atanmaz.");
                if (x.hizmet) throw GentegreHatasi.IsKurali($"{ad}: satır bir hizmet kartına bağlı; belgede satırı masraf satırına çevirin.");
                if (x.delphi) throw GentegreHatasi.IsKurali($"{ad}: Delphi ERP'den gelen kayıt; değişikliği Delphi'de yapın.");
                if (baglam.SubeId is { } aktif && x.sube is { } bsb && bsb != aktif)
                    throw GentegreHatasi.IsKurali($"{ad}: belge başka bir şubenin; o şubeye geçip atayın.");
                if (!BelgeUclari.TurIzinli(baglam, x.tur, x.tipi, Islem.Degistir))
                    throw GentegreHatasi.Yasak("Bu belge türünde değiştirme yetkiniz yok.");
                if (Saat.Gun(x.tarih) < acikDonemBasi)
                    throw GentegreHatasi.IsKurali($"{ad}: kapanmış muhasebe döneminde ({kapanis} ve öncesi) kalem atanamaz; yalnız görüntülenir.",
                        new { kod = "KAPANMIS_DONEM", kapanmisDonem = true, acikDonemBasi = Tarih(acikDonemBasi), belgeNo = x.no });
            }

            // ------------------------------------------------------ 2) kasa masraf bacakları --
            var ks = await b.ListeAsync("""
                select mh.id, coalesce(mh.kasa_islem_id, 0), coalesce(mh.hesap_turu, ''), coalesce(mh.masraf_id, 0), mh.hizmet_id is not null,
                       coalesce(ki.durum, 0)::int, coalesce(mh.sube_id, 0), mh.islem_tarihi,
                       coalesce(nullif(ki.islem_no, ''), '#' || coalesce(mh.kasa_islem_id, mh.id)), coalesce(ki.masraf_id, 0),
                       coalesce(mh.aktarim_kaynak, 0) = 1 and public.fn_veri_kaynagi_delphi(),
                       coalesce(public.fn_kasa_gun_kapali(mh.sube_id, mh.islem_tarihi), false),
                       exists (select 1 from public.muhasebe_fis f where f.kaynak_tur = 1 and f.kaynak_id = mh.kasa_islem_id and f.durum = 1),
                       coalesce(ki.kaynak_tur, 0) = 6
                  from public.mali_hareket mh
                  left join public.kasa_islem ki on ki.id = mh.kasa_islem_id
                 where mh.id = any(@p0::int[])
                   for update of mh
                """, tx, [kasaIdleri], o => (id: o.GetInt32(0), kasaId: o.GetInt32(1), hesapTuru: o.GetString(2), eski: o.GetInt32(3),
                    hizmet: o.GetBoolean(4), durum: o.GetInt32(5), sube: o.GetInt32(6), tarih: o.GetDateTime(7), no: o.GetString(8),
                    baslikMasraf: o.GetInt32(9), delphi: o.GetBoolean(10), gunKapali: o.GetBoolean(11), fis: o.GetBoolean(12),
                    disarida: o.GetBoolean(13)), iptal);
            if (ks.Count != kasaIdleri.Length) throw GentegreHatasi.Bulunamadi("Seçili kasa satırlarından biri bulunamadı.");
            foreach (var x in ks)
            {
                var ad = $"{x.no} bacak #{x.id}";
                if (x.sube > 0 && !baglam.Subeler.Any(y => y.Id == x.sube)) throw GentegreHatasi.Bulunamadi("Kasa satırı bulunamadı.");
                if (x.hesapTuru != "M" || x.kasaId <= 0) throw GentegreHatasi.IsKurali($"{ad}: kasa işleminin masraf bacağı değil.");
                if (x.durum != 2 || x.disarida) throw GentegreHatasi.IsKurali($"{ad}: gerçekleşmiş kasa işlemi değil; icmale girmez.");
                if (x.hizmet) throw GentegreHatasi.IsKurali($"{ad}: bacak bir hizmet (gelir) kalemine bağlı.");
                if (x.delphi) throw GentegreHatasi.IsKurali($"{ad}: Delphi ERP'den gelen kayıt; değişikliği Delphi'de yapın.");
                if (baglam.SubeId is { } aktif && x.sube > 0 && x.sube != aktif)
                    throw GentegreHatasi.IsKurali($"{ad}: işlem başka bir şubenin; o şubeye geçip atayın.");
                if (Saat.Gun(x.tarih) < acikDonemBasi)
                    throw GentegreHatasi.IsKurali($"{ad}: kapanmış muhasebe döneminde ({kapanis} ve öncesi) kalem atanamaz; yalnız görüntülenir.",
                        new { kod = "KAPANMIS_DONEM", kapanmisDonem = true, acikDonemBasi = Tarih(acikDonemBasi), belgeNo = x.no });
                if (x.gunKapali) throw GentegreHatasi.IsKurali($"{ad}: kasa günü kapalı; Gün Sonu ekranından açılmadan değiştirilemez.");
            }

            // ------------------------------------------------------ 3) yaz + logla --
            foreach (var x in bs)
                await b.CalistirAsync("""
                    update public.belge_satir set masraf_id = @p1, tur = 3, degistiren = @p2 where id = @p0
                    """, tx, [x.id, istek.MasrafId, baglam.KullaniciId], iptal);
            foreach (var g in bs.GroupBy(x => x.belgeId))
            {
                var ilk = g.First();
                if (ilk.fis) uyarilar.Add($"{ilk.no}: muhasebe fişi var - gider hesabı fişte kendiliğinden değişmez, fişi yeniden oluşturun.");
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, g.Key, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["aksiyon"] = "masraf-kalemi-ata",
                        ["masrafId"] = istek.MasrafId.ToString(CultureInfo.InvariantCulture),
                        ["masraf"] = masrafAdi,
                        ["satirlar"] = string.Join("; ", g.Select(x => string.Create(CultureInfo.InvariantCulture,
                            $"{x.id}: masraf {(x.eski > 0 ? x.eski.ToString(CultureInfo.InvariantCulture) : "-")} -> {istek.MasrafId}, tur {x.satirTur} -> 3"))),
                        ["kaynak"] = "masraf-icmali",
                    }, tarafId: ilk.taraf > 0 ? ilk.taraf : null, iptal: iptal);
            }
            foreach (var g in ks.GroupBy(x => x.kasaId))
            {
                foreach (var x in g)
                    await b.CalistirAsync("update public.mali_hareket set masraf_id = @p1, degistiren = @p2 where id = @p0",
                        tx, [x.id, istek.MasrafId, baglam.KullaniciId], iptal);
                var ilk = g.First();
                if (ilk.baslikMasraf != istek.MasrafId)
                    await b.CalistirAsync("update public.kasa_islem set masraf_id = @p1, degistiren = @p2 where id = @p0",
                        tx, [g.Key, istek.MasrafId, baglam.KullaniciId], iptal);
                if (ilk.fis) uyarilar.Add($"{ilk.no}: muhasebe fişi var - gider hesabı fişte kendiliğinden değişmez, fişi yeniden oluşturun.");
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloKasa, g.Key, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["aksiyon"] = "masraf-kalemi-ata",
                        ["masrafId"] = istek.MasrafId.ToString(CultureInfo.InvariantCulture),
                        ["masraf"] = masrafAdi,
                        ["bacaklar"] = string.Join("; ", g.Select(x => string.Create(CultureInfo.InvariantCulture,
                            $"{x.id}: masraf {(x.eski > 0 ? x.eski.ToString(CultureInfo.InvariantCulture) : "-")} -> {istek.MasrafId}"))),
                        ["baslikMasraf"] = string.Create(CultureInfo.InvariantCulture,
                            $"{(ilk.baslikMasraf > 0 ? ilk.baslikMasraf.ToString(CultureInfo.InvariantCulture) : "-")} -> {istek.MasrafId}"),
                        ["kaynak"] = "masraf-icmali",
                    }, iptal: iptal);
            }

            await tx.CommitAsync(iptal);
            return Results.Ok(new
            {
                atanan = bs.Count + ks.Count, belgeSatiri = bs.Count, kasaBacagi = ks.Count,
                belgeler = bs.Select(x => x.belgeId).Distinct().Count() + ks.Select(x => x.kasaId).Distinct().Count(),
                masraf = new { id = masraf.id, ad = masrafAdi }, uyarilar, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
