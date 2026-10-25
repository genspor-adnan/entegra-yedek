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
/// KÂRLILIK İCMALİ (mockup Ekranlar/İcmal/karlilik_icmali.html - kullanıcı 25.10.2026, kararlar
/// mockup altında). "Kimden, hangi üründen, hangi temsilciyle para kazanıyoruz; nerede iskonto
/// kârı yiyor; zararına satış var mı?" Satış İcmali ciroyu anlatır, burada eksen KÂR.
///
/// <para><b>Küme:</b> Satış İcmali ile aynı - kesin satış faturası / fişi (15, 16) + iadeleri
/// (tipi 2); irsaliye sayılmaz (irsaliyeden türeyen fatura bir kez sayılır). Delphi'den satırsız
/// aktarılan tahakkuk (17) icmale girmez, `aktarimTahakkuk` bilgi olarak döner.</para>
///
/// <para><b>Tutar:</b> belgenin dip toplamı (`belge.matrah`, KDV hariç - fn_belge_diptoplam'ın
/// yazdığı) satırlara satır tutarı oranında DAĞITILIR; satır hesabı yeniden yapılmaz. İskonto =
/// satırın adet × birim fiyatı − tutarı (İskonto İcmali ile aynı).</para>
///
/// <para><b>Maliyet (karar 25.10.2026):</b> SATIŞ ANINDAKİ ortalama maliyet - satırın stoktan
/// çıktığı güne kadarki giriş belgelerinin ağırlıklı ortalaması (fn_uretim_stok_maliyeti ile aynı
/// formül ve aynı giriş türleri, yalnız tarihle sınırlı); giriş yoksa kartın alış fiyatı (aynı
/// fonksiyonun yedeği). Fatura irsaliyeden türemişse (satır kaynak_tur 30 → irsaliye satırı)
/// maliyet irsaliyenin çıkış günündendir. "maliyet=bugun" yalnız bilgi içindir (bugünkü
/// ortalama); A4 her zaman satış anıyla basılır (`a4` bloğu ayrıca hesaplanır).</para>
///
/// <para><b>Maliyetsiz (karar):</b> stok satırında o gün ortalama da kart fiyatı da yoksa
/// maliyet 0 sayılır, satır kâra yazılır ama "maliyetsiz" işaretlenir; maliyetsiz=haric ile
/// bütün toplamlardan çıkar (KPI'daki sayı yine gösterilir). Hizmet / masraf satırında maliyet 0
/// ("hizmet"), maliyetsiz sayılmaz.</para>
///
/// <para><b>İade (karar):</b> iade satırı iade edilen satışın maliyetiyle eksi yazılır: iade
/// belgesinin bağlı satışı (belge.iade_belge_id, aynı stok satırı; ya da satır kaynak_tur 30 →
/// satış faturası satırı) varsa o satışın çıkış günündeki maliyet, yoksa iade günündeki
/// ortalama.</para>
///
/// <para><b>İki seviye (karar):</b> maliyet altı = `zarar` (kırmızı, Zararlı Satışlar sekmesi);
/// hedef marjın altı = `hedef_alti` (sarı rozet). Hedef marj Genel Ayarlar `satis.hedef_marj`,
/// boşsa %15.</para>
///
/// Temsilci belgeden (belge.satici_id). Döviz: TL karşılığı belge kuruyla; tek döviz seçilirse
/// yalnız o dövizdeki belgeler o dövizin cinsinden, maliyet de aynı belge kuruyla çevrilir (marj
/// TL'dekiyle aynı kalır). Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının
/// şubeleriyle sınırlı, cari kayıt kapsamı (baglam.Kapsam) uygulanır.
/// </summary>
public static class KarlilikIcmalUclari
{
    /// <summary>Ekran kodu (1176) - haklarını satış fatura listesinden kopyalar.</summary>
    private const string Kod = "satis.karlilik_icmali";

    private static readonly int[] SatisTurleri = [15, 16];
    /// <summary>Ortalama maliyetin giriş türleri - fn_uretim_stok_maliyeti ile aynı.</summary>
    private static readonly int[] GirisTurleri = [3, 10, 11, 12, 109, 122];

    private const decimal VarsayilanHedefMarj = 15m;
    /// <summary>Ciro × marj matrisinin marj eşikleri (mockup: düşük &lt; %25, orta %25-35, yüksek &gt; %35).</summary>
    private const decimal DusukMarj = 25m, YuksekMarj = 35m;
    /// <summary>Zararlı satır neden tahmini: iskonto bu yüzdeden büyükse "yüksek iskonto".</summary>
    private const decimal YuksekIskonto = 20m;

    // ================================================================ kayıtlar ===

    private sealed record Bel(int Id, int Tur, int Tipi, string No, DateTime Tarih, int TarafId, string Cari,
        bool Musteri, bool Tedarikci, int SaticiId, string Satici, int SubeId, int DepoId, string Depo,
        decimal Matrah, decimal Genel, string Para, decimal Kur)
    {
        public bool Iade => Tipi == 2;
    }

    /// <summary>Belge satırı. MaliyetTarihi: maliyetin okunacağı gün; MaliyetKaynagi 0 satış anı ·
    ///   1 irsaliyenin çıkış anı · 2 iade: bağlı satışın anı · 3 iade: iade anı.</summary>
    private sealed record Sat(int BelgeId, int StokId, int HizmetId, int MasrafId, string Kod, string Ad,
        string Kategori, string Kok, decimal Miktar, decimal Tutar, decimal Isk, bool Uygun,
        DateTime MaliyetTarihi, int MaliyetKaynagi);

    /// <summary>İcmalin bir kalemi: belge dip toplamının bu satıra düşen payı (görünen para biriminde,
    ///   KDV hariç). Kaynak: ort · kart · yok (maliyetsiz) · hizmet · satirsiz.</summary>
    private sealed record Kalem(Bel B, Sat? S, decimal Net, decimal Isk, decimal Maliyet, decimal NetTl, decimal Birim, string Kaynak)
    {
        public bool Hizmet => S is not null && S.StokId == 0;
        public bool Maliyetsiz => Kaynak is "yok" or "satirsiz";
        public string Anahtar => S is null ? "b" + B.Id
            : S.StokId > 0 ? "s" + S.StokId : S.HizmetId > 0 ? "h" + S.HizmetId : S.MasrafId > 0 ? "m" + S.MasrafId : "a" + S.Ad;
    }

    /// <summary>Gösterim kipi. Para "" = TL karşılığı (bütün belgeler), dolu = yalnız o döviz.</summary>
    private sealed record Kip(bool IadeDus, string Para, string Yerel)
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

    /// <summary>
    /// MALİYET DEFTERİ: stok başına günlük giriş toplamları (birikimli). Satış anındaki ortalama =
    /// o güne kadarki Σtutar / Σmiktar (fn_uretim_stok_maliyeti'nin formülü, tarihle sınırlı);
    /// bugünkü = bütün girişler (fonksiyonun kendisi). Giriş yoksa kartın alış fiyatı (aynı yedek).
    /// </summary>
    private sealed class MaliyetDefteri
    {
        private readonly Dictionary<int, List<(DateTime Gun, decimal GunM, decimal GunT, decimal KumM, decimal KumT)>> giris = new();
        private readonly Dictionary<int, decimal> kart = new();

        public static async Task<MaliyetDefteri> OkuAsync(NpgsqlConnection b, IEnumerable<int> idler, CancellationToken iptal)
        {
            var d = new MaliyetDefteri();
            var dizi = idler.Where(x => x > 0).Distinct().ToArray();
            if (dizi.Length == 0) return d;
            var satirlar = await b.ListeAsync("""
                select bs.stok_id, b.belge_tarihi::date, sum(bs.miktar), sum(bs.tutar)
                  from public.belge_satir bs
                  join public.belge b on b.id = bs.belge_id
                 where bs.stok_id = any(@p0::int[]) and bs.miktar > 0 and b.tur = any(@p1::int[])
                 group by 1, 2
                """, null, [dizi, GirisTurleri],
                o => (id: o.GetInt32(0), gun: o.GetDateTime(1), m: o.GetDecimal(2), t: o.GetDecimal(3)), iptal);
            foreach (var g in satirlar.GroupBy(x => x.id))
            {
                decimal km = 0, kt = 0;
                var l = new List<(DateTime Gun, decimal GunM, decimal GunT, decimal KumM, decimal KumT)>();
                foreach (var x in g.OrderBy(x => x.gun))
                {
                    km += x.m; kt += x.t;
                    l.Add((x.gun.Date, x.m, x.t, km, kt));
                }
                d.giris[g.Key] = l;
            }
            var kartlar = await b.ListeAsync("""
                select distinct on (f.stok_id) f.stok_id, f.fiyat
                  from public.stok_fiyat f
                 where f.stok_id = any(@p0::int[]) and f.satis = 0 and f.fiyat > 0
                 order by f.stok_id, f.id
                """, null, [dizi], o => (id: o.GetInt32(0), f: o.GetDecimal(1)), iptal);
            foreach (var x in kartlar) d.kart[x.id] = x.f;
            return d;
        }

        /// <summary>Gün sonu itibarıyla son giriş günü indeksi (yoksa -1).</summary>
        private static int Bul(List<(DateTime Gun, decimal GunM, decimal GunT, decimal KumM, decimal KumT)> l, DateTime gun)
        {
            int alt = 0, ust = l.Count - 1, bulunan = -1;
            while (alt <= ust)
            {
                var o = (alt + ust) / 2;
                if (l[o].Gun <= gun) { bulunan = o; alt = o + 1; } else ust = o - 1;
            }
            return bulunan;
        }

        /// <summary>O günkü birim maliyet ve kaynağı (ort · kart · yok).</summary>
        public (decimal Birim, string Kaynak) Ani(int stok, DateTime gun)
        {
            if (giris.TryGetValue(stok, out var l))
            {
                var i = Bul(l, gun.Date);
                if (i >= 0 && l[i].KumM > 0 && l[i].KumT > 0) return (Math.Round(l[i].KumT / l[i].KumM, 4), "ort");
            }
            return kart.TryGetValue(stok, out var f) && f > 0 ? (f, "kart") : (0m, "yok");
        }

        public (decimal Birim, string Kaynak) Bugun(int stok) => Ani(stok, DateTime.MaxValue.Date);

        /// <summary>Son alış birim fiyatı (o güne kadarki son giriş günü), TL.</summary>
        public decimal? SonAlis(int stok, DateTime gun)
        {
            if (!giris.TryGetValue(stok, out var l)) return null;
            var i = Bul(l, gun.Date);
            return i >= 0 && l[i].GunM > 0 ? Math.Round(l[i].GunT / l[i].GunM, 4) : null;
        }
    }

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static decimal? Marj(Top t, bool iadeDus)
        => Math.Abs(t.Net(iadeDus)) > 0.005m ? Math.Round(100m * t.Kar(iadeDus) / t.Net(iadeDus), 1) : null;
    private static decimal? Puan(decimal? simdi, decimal? once) => simdi is { } a && once is { } b ? Math.Round(a - b, 1) : null;
    /// <summary>İade belgesi miktarı / neti düşürür; "iadeleri düş" kapalıysa sayılmaz.</summary>
    private static decimal Isaret(Bel b, Kip kip) => b.Iade ? (kip.IadeDus ? -1m : 0m) : 1m;
    private static decimal Carp(Bel b, Kip kip) => kip.Dovizli ? (b.Kur > 0 ? 1m / b.Kur : 0m) : 1m;

    /// <summary>İki seviye: "zarar" (maliyet altı, kırmızı) · "hedef_alti" (hedef marjın altı, sarı) · "".</summary>
    private static string Seviye(decimal kar, decimal? marj, decimal hedef)
        => kar < -0.005m ? "zarar" : marj is { } m && m < hedef ? "hedef_alti" : "";

    /// <summary>ABC: değere göre sıralı birikim - önceki birikim %80'in altındaysa A, %95'in altındaysa B,
    ///   kalan (ve sıfır / eksi) C.</summary>
    private static Dictionary<int, string> Abc(IEnumerable<(int Id, decimal Deger)> l)
    {
        var liste = l.OrderByDescending(x => x.Deger).ToList();
        var top = liste.Where(x => x.Deger > 0).Sum(x => x.Deger);
        var s = new Dictionary<int, string>();
        decimal bir = 0;
        foreach (var x in liste)
        {
            if (x.Deger <= 0 || top <= 0) { s[x.Id] = "C"; continue; }
            var once = 100m * bir / top;
            s[x.Id] = once < 80m ? "A" : once < 95m ? "B" : "C";
            bir += x.Deger;
        }
        return s;
    }

    // ================================================================== SQL ===

    /// <summary>Belge kümesi. @p0 bas · @p1 bit (dahil) · @p2 türler · @p3 kullanıcının şubeleri · @p4 seçili
    ///   şube (0 tümü) · @p5 cari kayıt kapsamı. KUR: TicariIcmalUclari ile aynı (yerel 1; dövizli belgede
    ///   belgenin kuru, rapor dövizi belgenin dövizi değilse o günün kuru).</summary>
    private const string BelgeSorgusu = """
        select b.id, b.tur::int, coalesce(b.tipi, 0)::int, coalesce(b.belge_no, ''),
               b.belge_tarihi::date, coalesce(b.taraf_id, 0),
               coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               coalesce(t.musteri, 0)::int, coalesce(t.tedarikci, 0)::int,
               coalesce(b.satici_id, 0),
               coalesce(public.fn_taraf_ad(sp.unvan, sp.ad, sp.soyad)::varchar(160), '')::varchar(160),
               coalesce(b.sube_id, 0), coalesce(b.cikis_depo_id, 0), coalesce(d.ad, '')::varchar(120),
               coalesce(b.matrah, 0), coalesce(b.genel_toplam, 0),
               p.para,
               case when p.para = p.yerel then 1::numeric
                    when public.fn_doviz_iso(coalesce(nullif(btrim(b.rapor_dovizi), ''), p.para)) = p.para
                         and coalesce(b.doviz_kuru, 0) > 0 then b.doviz_kuru
                    else coalesce(public.fn_doviz_kur_getir(p.para, b.belge_tarihi::date, 2::smallint),
                                  nullif(b.doviz_kuru, 0), 1::numeric) end
          from public.belge b
          cross join lateral (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel) y
          cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), y.yerel))::varchar(6) as para,
                                     y.yerel) p
          left join public.taraf t on t.id = b.taraf_id
          left join public.taraf sp on sp.id = b.satici_id
          left join public.depo d on d.id = b.cikis_depo_id
         where b.tur = any(@p2::int[])
           and b.durum = 0
           and b.belge_tarihi >= @p0::date and b.belge_tarihi < @p1::date + 1
           and (b.sube_id is null or b.sube_id = any(@p3::int[]))
           and (@p4 = 0 or b.sube_id = @p4)
           and (cardinality(@p5::int[]) = 0 or b.taraf_id = any(@p5::int[]))
         order by b.belge_tarihi, b.id
        """;

    /// <summary>Belge satırları + maliyet günü. @p0 belge id'leri · @p1 kategori (alt dallarıyla, 0 tümü) ·
    ///   @p2 kalem (0 hepsi, 1 yalnız stok). Süzgeç satırı ATMAZ, `uygun` ile işaretler (dip toplam bütün
    ///   satırlara dağıtılır). Maliyet günü: satışta irsaliyeden türemişse irsaliyenin günü; iadede bağlı
    ///   satışın (iade_belge_id'nin aynı stok satırı ya da kaynak satış satırı) günü, yoksa iade günü.</summary>
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
               greatest(round(coalesce(s.adet, 0) * coalesce(s.birim_fiyat, 0), 2) - coalesce(s.tutar, 0), 0),
               coalesce((@p2 = 0 or s.stok_id is not null)
                        and (@p1 = 0 or st.kategori in (select id from dal)), false),
               case when coalesce(b.tipi, 0) = 2 then coalesce(io.tarih, kf.tarih, ki.tarih, b.belge_tarihi::date)
                    else coalesce(ki.tarih, b.belge_tarihi::date) end,
               (case when coalesce(b.tipi, 0) = 2 then (case when io.tarih is not null or kf.tarih is not null then 2 else 3 end)
                     when ki.tarih is not null then 1 else 0 end)::int
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
          left join public.stok st on st.id = s.stok_id
          left join public.hizmet hz on hz.id = s.hizmet_id
          left join public.masraf ms on ms.id = s.masraf_id
          left join public.kategori k on k.id = st.kategori
          left join kok on kok.id = k.id
          left join public.kategori kk on kk.id = kok.kok_id
          left join lateral (
              select kb.belge_tarihi::date as tarih
                from public.belge_satir ks join public.belge kb on kb.id = ks.belge_id
               where s.kaynak_tur = 30 and ks.id = s.kaynak_id and kb.tur = 14
               limit 1) ki on true
          left join lateral (
              select kb.belge_tarihi::date as tarih
                from public.belge_satir ks join public.belge kb on kb.id = ks.belge_id
               where s.kaynak_tur = 30 and ks.id = s.kaynak_id and kb.tur in (15, 16) and coalesce(kb.tipi, 0) <> 2
               limit 1) kf on true
          left join lateral (
              select coalesce(ki2.belge_tarihi, ob.belge_tarihi)::date as tarih
                from public.belge ob
                join public.belge_satir os on os.belge_id = ob.id
                left join public.belge_satir ks on os.kaynak_tur = 30 and ks.id = os.kaynak_id
                left join public.belge ki2 on ki2.id = ks.belge_id and ki2.tur = 14
               where coalesce(b.tipi, 0) = 2 and ob.id = b.iade_belge_id and os.stok_id = s.stok_id
               order by os.sira, os.id
               limit 1) io on true
         where s.belge_id = any(@p0::int[])
         order by s.belge_id, s.sira, s.id
        """;

    /// <summary>FIFO açık kalemler - TicariIcmalUclari / Cari İcmali ile aynı kural. @p0 cari id'leri.</summary>
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
                   sum(h.yb) over (partition by h.taraf_id) as top_b,
                   sum(h.ya) over (partition by h.taraf_id) as top_a
              from h
        )
        select f.belge_id, least(f.yb, greatest(0, f.bir_b - f.top_a))
          from f
         where f.belge_id > 0 and least(f.yb, greatest(0, f.bir_b - f.top_a)) > 0.005
        """;

    /// <summary>Aktarılan satış tahakkuku (17) ay ay - TicariIcmalUclari.TahakkukAsync ile aynı kaynak.
    ///   @p0 bas · @p1 bit · @p2 şubeler · @p3 seçili şube.</summary>
    private const string TahakkukSorgusu = """
        select date_trunc('month', e.islem_tarihi)::date, count(distinct e.belge_id)::int,
               coalesce(sum(e.yerel_borc - e.yerel_alacak), 0)
          from public.v_mali_hareket_ek e
         where e.hesap_turu = 'C' and e.tur = 17 and e.islem_durum in (1, 2)
           and e.islem_tarihi >= @p0::date and e.islem_tarihi < @p1::date + 1
           and (coalesce(e.sube_id, 0) = 0 or e.sube_id = any(@p2::int[]))
           and (@p3 = 0 or e.sube_id = @p3)
         group by 1
        """;

    // ============================================================= okuyucular ===

    private static Task<List<Bel>> BelgelerAsync(NpgsqlConnection b, DateTime bas, DateTime bit, int[] subeler, int sube,
        int[] kapsam, CancellationToken iptal)
        => b.ListeAsync(BelgeSorgusu, null, [bas, bit, SatisTurleri, subeler, sube, kapsam], o => new Bel(
            o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetDateTime(4).Date, o.GetInt32(5), o.GetString(6),
            o.GetInt32(7) == 1, o.GetInt32(8) == 1, o.GetInt32(9), o.GetString(10), o.GetInt32(11), o.GetInt32(12),
            o.GetString(13), o.GetDecimal(14), o.GetDecimal(15), o.GetString(16), o.GetDecimal(17)), iptal);

    private static async Task<List<Sat>> SatirlarAsync(NpgsqlConnection b, IEnumerable<int> belgeIdleri, int kategori,
        int kalem, CancellationToken iptal)
    {
        var dizi = belgeIdleri.Distinct().ToArray();
        if (dizi.Length == 0) return [];
        return await b.ListeAsync(SatirSorgusu, null, [dizi, kategori, kalem], o => new Sat(
            o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3), o.GetString(4), o.GetString(5), o.GetString(6),
            o.GetString(7), o.GetDecimal(8), o.GetDecimal(9), o.GetDecimal(10), o.GetBoolean(11),
            o.GetDateTime(12).Date, o.GetInt32(13)), iptal);
    }

    /// <summary>Kalemler: belge dip toplamı (KDV hariç) satırlara satır tutarı oranında dağıtılır; maliyet =
    ///   miktar × satırın maliyet günündeki birim maliyet (hizmet / masraf 0).</summary>
    private static List<Kalem> Kalemler(List<Bel> belgeler, List<Sat> satirlar,
        Func<int, DateTime, (decimal, string)> birim, Kip kip, bool satirSuzgecli)
    {
        var gruplar = satirlar.GroupBy(s => s.BelgeId).ToDictionary(g => g.Key, g => g.ToList());
        var l = new List<Kalem>();
        foreach (var b in belgeler)
        {
            var carp = Carp(b, kip);
            if (!gruplar.TryGetValue(b.Id, out var ss) || ss.Count == 0)
            {
                if (!satirSuzgecli) l.Add(new Kalem(b, null, b.Matrah * carp, 0, 0, b.Matrah, 0, "satirsiz"));
                continue;
            }
            var payda = ss.Sum(x => x.Tutar);
            foreach (var s in ss.Where(x => x.Uygun))
            {
                var pay = payda != 0 ? s.Tutar / payda : 1m / ss.Count;
                var tl = b.Matrah * pay;
                var (bm, kaynak) = s.StokId == 0 ? (0m, "hizmet") : birim(s.StokId, s.MaliyetTarihi);
                l.Add(new Kalem(b, s, tl * carp, s.Isk * carp, s.Miktar * bm * carp, tl, bm * carp, kaynak));
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

    private static Donem DonemCoz(DateTime? bas, DateTime? bit, string? karsi)
    {
        var bugun = Saat.Bugun.Date;
        var bitis = (bit ?? bugun).Date;
        var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
        if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
        if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
        var gun = (int)(bitis - baslangic).TotalDays + 1;
        // KARŞILAŞTIRMA (mockup): önceki eşit uzunlukta dönem (varsayılan) ya da geçen yılın aynı dönemi.
        var k = karsi == "gy" ? "gy" : "od";
        var (kb, kbt) = k == "od" ? (baslangic.AddDays(-gun), baslangic.AddDays(-1)) : (baslangic.AddYears(-1), bitis.AddYears(-1));
        return new Donem(baslangic, bitis, kb, kbt, k, gun);
    }

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    private static async Task<Kip> KipCozAsync(NpgsqlConnection b, int? iade, string? para, CancellationToken iptal)
    {
        var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, [], iptal) ?? "TL";
        var p = string.IsNullOrWhiteSpace(para) ? ""
            : await b.TekDegerAsync<string>("select public.fn_doviz_iso(@p0)::varchar(6)", null, [para.Trim()], iptal) ?? "";
        if (p == yerel) p = "";
        return new Kip((iade ?? 1) == 1, p, yerel);
    }

    /// <summary>Hedef marj (Genel Ayarlar `satis.hedef_marj`, yüzde); boş / okunamazsa %15.</summary>
    private static async Task<decimal> HedefMarjAsync(NpgsqlConnection b, CancellationToken iptal)
    {
        var ayar = (await AyarDeposu.MetinAsync(b, null, "satis.hedef_marj", "", iptal)).Trim().Replace(',', '.').TrimStart('%');
        return decimal.TryParse(ayar, NumberStyles.Number, CultureInfo.InvariantCulture, out var h) && h >= 0 && h <= 100
            ? h : VarsayilanHedefMarj;
    }

    public static void KarlilikIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/karlilik-icmal").WithTags("Kârlılık İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? karsi, int? sube, int? temsilci, int? kategori,
                                string? para, int? iade, int? hizmet, string? maliyetsiz, string? maliyet,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var d = DonemCoz(bas, bit, karsi);
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var tms = temsilci ?? 0;
            var k0 = kategori ?? 0;
            var hizmetDahil = (hizmet ?? 1) == 1;
            var haric = maliyetsiz == "haric";
            var bugunKipi = maliyet == "bugun";
            var satirSuzgecli = k0 > 0 || !hizmetDahil;
            await using var b = await veri.AcAsync(iptal);
            var kip = await KipCozAsync(b, iade, para, iptal);
            var hedef = await HedefMarjAsync(b, iptal);

            // Tek okuma: dönem + karşılaştırma + 12 aylık trend aralığı.
            var m0 = new DateTime(d.Bit.Year, d.Bit.Month, 1).AddMonths(-11);
            var genBas = m0 < d.KBas ? m0 : d.KBas;
            var ham = await BelgelerAsync(b, genBas, d.Bit, subeler, s0, kapsam, iptal);
            bool CariMi(Bel x) => x.Tarih >= d.Bas && x.Tarih <= d.Bit;
            var hamCari = ham.Where(CariMi).ToList();
            // Seçim listeleri süzülmemiş dönem kümesinden (seçince liste daralmasın).
            var temsilciSecim = hamCari.GroupBy(x => x.SaticiId).OrderBy(g => g.Key == 0 ? 1 : 0).ThenBy(g => g.First().Satici)
                .Select(g => new { id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().Satici }).ToList();
            var paralar = hamCari.Select(x => x.Para).Where(p => p != kip.Yerel).Distinct().OrderBy(p => p).ToList();
            bool TemsilciUyar(Bel x) => tms == 0 || (tms == -1 ? x.SaticiId == 0 : x.SaticiId == tms);
            var kume = ham.Where(TemsilciUyar).ToList();                                   // bütün paralar (para tablosu)
            var gorunen = kume.Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();

            var satirlar = await SatirlarAsync(b, kume.Select(x => x.Id), k0, hizmetDahil ? 0 : 1, iptal);
            var defter = await MaliyetDefteri.OkuAsync(b, satirlar.Select(x => x.StokId), iptal);
            Func<int, DateTime, (decimal, string)> birim = bugunKipi
                ? (s, _) => defter.Bugun(s)
                : (s, g) => defter.Ani(s, g);
            List<Kalem> Suz(IEnumerable<Kalem> l) => haric ? l.Where(k => !k.Maliyetsiz).ToList() : l.ToList();

            var tum = Kalemler(gorunen, satirlar, birim, kip, satirSuzgecli);
            var tumCari = tum.Where(k => CariMi(k.B)).ToList();                            // maliyetsiz sayımı için (süzgeçsiz)
            var kalemler = Suz(tumCari);
            var onceki = Suz(tum.Where(k => k.B.Tarih >= d.KBas && k.B.Tarih <= d.KBit));
            var trendKalem = Suz(tum.Where(k => k.B.Tarih >= m0));
            var tlKalem = kip.Dovizli
                ? Suz(Kalemler(kume.Where(CariMi).ToList(), satirlar, birim, kip with { Para = "" }, satirSuzgecli))
                : kalemler;
            // A4 HER ZAMAN satış anıyla (karar 25.10.2026).
            var a4Kalem = bugunKipi
                ? Suz(Kalemler(gorunen.Where(CariMi).ToList(), satirlar, (s, g) => defter.Ani(s, g), kip, satirSuzgecli))
                : kalemler;

            var top = Topla(kalemler);
            var net = top.Net(kip.IadeDus);
            var kar = top.Kar(kip.IadeDus);
            var marj = Marj(top, kip.IadeDus);
            var oncekiTop = Topla(onceki);
            var oncekiMarj = Marj(oncekiTop, kip.IadeDus);

            // ---------------------------------------------------- zararlı satırlar --
            var stokIdleri = kalemler.Where(k => k.S is { StokId: > 0 }).Select(k => k.S!.StokId).Distinct().ToArray();
            var listeFiyat = stokIdleri.Length == 0 ? []
                : await b.ListeAsync("""
                    select x.id, coalesce(f.fiyat, 0),
                           public.fn_doviz_iso(coalesce(nullif(btrim(f.doviz_cinsi), ''), public.fn_yerel_para()))::varchar(6)
                      from unnest(@p0::int[]) as x(id)
                      left join lateral (select * from public.fn_stok_kart_fiyat(x.id, 1::smallint) limit 1) f on true
                    """, null, [stokIdleri], o => (id: o.GetInt32(0), fiyat: o.GetDecimal(1), para: o.GetString(2)), iptal);
            var gorunenPara = kip.Dovizli ? kip.Para : kip.Yerel;
            var listeSoz = listeFiyat.Where(x => x.fiyat > 0 && x.para == gorunenPara).ToDictionary(x => x.id, x => x.fiyat);
            static bool ZararliMi(Kalem k) => !k.B.Iade && k.S is { StokId: > 0, Miktar: > 0m } && !k.Maliyetsiz
                                             && k.Net < k.Maliyet - 0.005m;
            var zararlar = kalemler.Where(ZararliMi).Select(k =>
            {
                var s = k.S!;
                var iskYuzde = k.Net + k.Isk > 0 ? Math.Round(100m * k.Isk / (k.Net + k.Isk), 1) : 0m;
                var netFiyat = Math.Round(k.Net / s.Miktar, 2);
                decimal? liste = listeSoz.TryGetValue(s.StokId, out var lf) ? lf : null;
                var sonAlis = defter.SonAlis(s.StokId, s.MaliyetTarihi) is { } sa ? sa * Carp(k.B, kip) : (decimal?)null;
                var neden = iskYuzde > YuksekIskonto ? "yuksek_iskonto"
                    : liste is { } lst && sonAlis is { } son && son > lst ? "maliyet_arti" : "";
                return new
                {
                    belgeId = k.B.Id, belgeNo = k.B.No, tarih = k.B.Tarih, cariId = k.B.TarafId, cari = k.B.Cari,
                    temsilci = k.B.SaticiId == 0 ? "(temsilcisiz)" : k.B.Satici,
                    stokId = s.StokId, kod = s.Kod, urun = s.Ad, miktar = s.Miktar,
                    netFiyat, maliyet = Math.Round(k.Birim, 2), fark = R(k.Net - k.Maliyet), iskonto = iskYuzde,
                    listeFiyati = liste, sonAlis = sonAlis is { } x ? Math.Round(x, 2) : (decimal?)null,
                    neden, nedenAdi = neden switch { "yuksek_iskonto" => "yüksek iskonto", "maliyet_arti" => "maliyet arttı, fiyat eski", _ => "" },
                };
            }).OrderBy(x => x.fark).ToList();

            // ------------------------------------------------- müşteri bazında --
            var oncekiCari = onceki.GroupBy(k => k.B.TarafId).ToDictionary(g => g.Key, g => Marj(Topla(g), kip.IadeDus));
            var musteriHam = kalemler.GroupBy(k => k.B.TarafId).Select(g =>
            {
                var t = Topla(g);
                return (id: g.Key, g, t, net: t.Net(kip.IadeDus), kar: t.Kar(kip.IadeDus));
            }).ToList();
            var abcKar = Abc(musteriHam.Select(x => (x.id, x.kar)));
            var abcCiro = Abc(musteriHam.Select(x => (x.id, x.net)));
            var enBuyukKar = musteriHam.Count > 0 ? Math.Max(musteriHam.Max(x => x.kar), 0.01m) : 1m;
            var musteriler = musteriHam.Select(x =>
            {
                var ilk = x.g.First().B;
                var mj = Marj(x.t, kip.IadeDus);
                var varOnce = oncekiCari.TryGetValue(x.id, out var om);
                var tm = x.g.GroupBy(k => k.B.SaticiId).OrderByDescending(y => y.Sum(k => k.Net))
                    .Select(y => y.Key == 0 ? "(temsilcisiz)" : y.First().B.Satici).Distinct().ToList();
                var urunDagilim = x.g.Where(k => k.S is not null).GroupBy(k => k.Anahtar).Select(y =>
                {
                    var ty = Topla(y);
                    return new
                    {
                        anahtar = y.Key, ad = y.First().S!.Ad, miktar = y.Sum(k => Isaret(k.B, kip) * k.S!.Miktar),
                        net = R(ty.Net(kip.IadeDus)), kar = R(ty.Kar(kip.IadeDus)), marj = Marj(ty, kip.IadeDus),
                        maliyetsiz = y.Any(k => k.Maliyetsiz),
                    };
                }).OrderByDescending(y => y.net).ToList();
                return new
                {
                    id = x.id, ad = ilk.Cari, musteri = ilk.Musteri, tedarikci = ilk.Tedarikci,
                    temsilci = string.Join(" · ", tm.Take(2)) + (tm.Count > 2 ? " …" : ""),
                    net = R(x.net), maliyet = R(x.t.Maliyet(kip.IadeDus)), kar = R(x.kar), marj = mj,
                    oncekiMarj = varOnce ? om : null, yeni = !varOnce, marjDegisim = varOnce ? Puan(mj, om) : null,
                    iskonto = R(x.t.Isk), abc = abcKar.GetValueOrDefault(x.id, "C"), karPayi = Yuzde(x.kar, kar),
                    cubuk = Yuzde(Math.Max(x.kar, 0), enBuyukKar), seviye = Seviye(x.kar, mj, hedef),
                    maliyetsiz = x.g.Count(k => k.Maliyetsiz && !k.B.Iade), zararli = x.g.Count(ZararliMi),
                    doviz = DovizRozet(x.g, kip), urunSayisi = urunDagilim.Count, urunler = urunDagilim.Take(15).ToList(),
                };
            }).OrderByDescending(x => x.kar).ToList();
            var musteriToplam = new
            {
                musteri = musteriler.Count, net = R(net), maliyet = R(top.Maliyet(kip.IadeDus)), kar = R(kar), marj,
                oncekiMarj, iskonto = R(top.Isk),
            };

            // ---------------------------------------------------- ürün bazında --
            var oncekiUrun = onceki.Where(k => k.S is not null).GroupBy(k => k.Anahtar)
                .ToDictionary(g => g.Key, g => Marj(Topla(g), kip.IadeDus));
            var urunler = kalemler.Where(k => k.S is not null).GroupBy(k => k.Anahtar).Select(g =>
            {
                var s1 = g.First().S!;
                var t = Topla(g);
                var n = t.Net(kip.IadeDus);
                var mlyt = t.Maliyet(kip.IadeDus);
                var k1 = t.Kar(kip.IadeDus);
                var miktar = g.Sum(k => Isaret(k.B, kip) * k.S!.Miktar);
                var mj = Marj(t, kip.IadeDus);
                var hz = s1.StokId == 0;
                var msz = g.Count(k => k.Maliyetsiz);
                var kaynak = hz ? "hizmet" : msz == g.Count() ? "maliyetsiz" : msz > 0 ? "kismi"
                    : g.Any(k => k.Kaynak == "kart") ? "kart" : "ortalama";
                var dagilim = g.GroupBy(k => k.B.TarafId).Select(x => new
                {
                    id = x.Key, ad = x.First().B.Cari, miktar = x.Sum(k => Isaret(k.B, kip) * k.S!.Miktar),
                    net = R(Topla(x).Net(kip.IadeDus)), kar = R(Topla(x).Kar(kip.IadeDus)),
                }).OrderByDescending(x => x.net).ToList();
                return new
                {
                    anahtar = g.Key, stokId = s1.StokId, hizmet = hz, kod = s1.Kod, ad = s1.Ad, kategori = s1.Kategori,
                    miktar, ortSatis = miktar != 0 ? Math.Round(n / miktar, 2) : (decimal?)null,
                    ortMaliyet = !hz && kaynak != "maliyetsiz" && miktar != 0 ? Math.Round(mlyt / miktar, 2) : (decimal?)null,
                    net = R(n), maliyet = R(mlyt), kar = R(k1), marj = mj,
                    oncekiMarj = oncekiUrun.GetValueOrDefault(g.Key), marjDegisim = Puan(mj, oncekiUrun.GetValueOrDefault(g.Key)),
                    maliyetKaynagi = kaynak, seviye = hz ? "" : Seviye(k1, mj, hedef), zararli = g.Count(ZararliMi),
                    musteri = dagilim.Count, musteriler = dagilim.Take(15).ToList(),
                };
            }).OrderByDescending(x => x.kar).ToList();

            // ------------------------------------------------------- temsilci --
            var tarafIdleri = kalemler.Select(k => k.B.TarafId).Where(x => x > 0).Distinct().ToArray();
            var acik = tarafIdleri.Length == 0 ? []
                : await b.ListeAsync(AcikSorgusu, null, [tarafIdleri], o => (belge: o.GetInt32(0), b: o.GetDecimal(1)), iptal);
            var acikBelge = acik.GroupBy(x => x.belge).ToDictionary(g => g.Key, g => g.Sum(x => x.b));
            decimal Tahsil(Bel x) => x.Iade ? 0 : Math.Max(0, x.Genel - acikBelge.GetValueOrDefault(x.Id)) * Carp(x, kip);
            var temsilciler = kalemler.GroupBy(k => k.B.SaticiId).Select(g =>
            {
                var t = Topla(g);
                var mj = Marj(t, kip.IadeDus);
                return new
                {
                    id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().B.Satici,
                    musteri = g.Select(k => k.B.TarafId).Distinct().Count(),
                    net = R(t.Net(kip.IadeDus)), kar = R(t.Kar(kip.IadeDus)), marj = mj,
                    iskonto = R(t.Isk), iskontoOran = Yuzde(t.Isk, t.Brut), zararli = g.Count(ZararliMi),
                    tahsil = R(g.Select(k => k.B).DistinctBy(x => x.Id).Sum(Tahsil)), seviye = Seviye(t.Kar(kip.IadeDus), mj, hedef),
                };
            }).OrderByDescending(x => x.net).ToList();
            var temsilciToplam = new
            {
                musteri = musteriler.Count, net = R(net), kar = R(kar), marj, iskonto = R(top.Isk),
                iskontoOran = Yuzde(top.Isk, top.Brut), zararli = zararlar.Count, tahsil = R(temsilciler.Sum(x => x.tahsil)),
            };

            // -------------------------------------------------------- kırılımlar --
            var subeAd = baglam.Subeler.GroupBy(s => s.Id).ToDictionary(g => g.Key, g => g.First().Ad);
            var paraSatirlari = tlKalem.GroupBy(k => k.B.Para).OrderBy(g => g.Key == kip.Yerel ? 0 : 1).ThenBy(g => g.Key).Select(g =>
            {
                var t = Topla(g);
                var yerel = g.Key == kip.Yerel;
                return new
                {
                    para = g.Key, yerel, belge = g.Select(k => k.B.Id).Distinct().Count(),
                    doviz = yerel ? (decimal?)null : R(g.Where(k => k.B.Kur > 0).Sum(k => Isaret(k.B, kip) * k.NetTl / k.B.Kur)),
                    tl = R(t.Net(kip.IadeDus)), tlMaliyet = R(t.Maliyet(kip.IadeDus)), marj = Marj(t, kip.IadeDus),
                };
            }).ToList();
            var tlTop = Topla(tlKalem);
            var kirilim = new
            {
                kategori = kalemler.GroupBy(k => k.S?.Kok ?? "(satırsız)").Select(g =>
                {
                    var t = Topla(g);
                    var mj = Marj(t, kip.IadeDus);
                    return new
                    {
                        ad = g.Key, net = R(t.Net(kip.IadeDus)), kar = R(t.Kar(kip.IadeDus)), marj = mj, pay = Yuzde(t.Kar(kip.IadeDus), kar),
                        seviye = g.Key == "(hizmet)" ? "" : Seviye(t.Kar(kip.IadeDus), mj, hedef),
                    };
                }).OrderByDescending(x => x.net).ToList(),
                subeDepo = kalemler.GroupBy(k => (k.B.SubeId, k.B.Depo)).Select(g =>
                {
                    var t = Topla(g);
                    return new
                    {
                        ad = (g.Key.SubeId == 0 ? "(şubesiz)" : subeAd.GetValueOrDefault(g.Key.SubeId) ?? $"Şube {g.Key.SubeId}")
                             + " · " + (g.Key.Depo.Length > 0 ? g.Key.Depo : "(depo yok)"),
                        net = R(t.Net(kip.IadeDus)), kar = R(t.Kar(kip.IadeDus)), marj = Marj(t, kip.IadeDus),
                    };
                }).OrderByDescending(x => x.net).ToList(),
                para = new
                {
                    satirlar = paraSatirlari,
                    toplam = new
                    {
                        belge = tlKalem.Select(k => k.B.Id).Distinct().Count(), tl = R(tlTop.Net(kip.IadeDus)),
                        tlMaliyet = R(tlTop.Maliyet(kip.IadeDus)), marj = Marj(tlTop, kip.IadeDus),
                    },
                },
            };

            // ---------------------------------------------------- ciro × marj --
            var marjSiniflari = new[] { "dusuk", "orta", "yuksek" };
            string MarjSinifi(decimal? m) => m is null or < DusukMarj ? "dusuk" : m <= YuksekMarj ? "orta" : "yuksek";
            var musteriSinif = musteriler.Where(m => m.net > 0.005m)
                .Select(m => (m, ciro: abcCiro.GetValueOrDefault(m.id, "C"), ms: MarjSinifi(m.marj))).ToList();
            var hucreHam = (from c in new[] { "A", "B", "C" }
                            from ms in marjSiniflari
                            let l = musteriSinif.Where(x => x.ciro == c && x.ms == ms).Select(x => x.m).OrderByDescending(x => x.net).ToList()
                            select (c, ms, l)).ToList();
            var enBuyukHucre = Math.Max(hucreHam.Select(h => h.l.Sum(x => x.net)).DefaultIfEmpty(0m).Max(), 0.01m);
            var matris = hucreHam.Select(h =>
            {
                var n = h.l.Sum(x => x.net);
                var o = n / enBuyukHucre;
                return new
                {
                    ciro = h.c, marj = h.ms, musteri = h.l.Count, net = R(n), kar = R(h.l.Sum(x => x.kar)),
                    isi = h.l.Count == 0 ? 0 : o > 0.6m ? 4 : o > 0.3m ? 3 : o > 0.1m ? 2 : 1,
                    oneri = (h.c, h.ms) switch
                    {
                        ("A", "dusuk") => "fiyat görüşmesi", ("A", "orta") => "koru", ("C", "dusuk") => "iskonto gözden geçir",
                        ("C", "yuksek") => "büyütülebilir", _ => "",
                    },
                    musteriler = h.l.Take(50).Select(x => new { x.id, x.ad, x.net, x.kar, x.marj }).ToList(),
                };
            }).ToList();

            // ------------------------------------------------------------ trend --
            var trendTahakkuk = await b.ListeAsync(TahakkukSorgusu, null, [m0, d.Bit, subeler, s0],
                o => (ay: o.GetDateTime(0).Date, belge: o.GetInt32(1), tutar: o.GetDecimal(2)), iptal);
            var donemTahakkuk = await b.ListeAsync(TahakkukSorgusu, null, [d.Bas, d.Bit, subeler, s0],
                o => (ay: o.GetDateTime(0).Date, belge: o.GetInt32(1), tutar: o.GetDecimal(2)), iptal);
            var aylarHam = Enumerable.Range(0, 12).Select(i =>
            {
                var ay = m0.AddMonths(i);
                var l = trendKalem.Where(k => k.B.Tarih.Year == ay.Year && k.B.Tarih.Month == ay.Month).ToList();
                var t = Topla(l);
                var th = trendTahakkuk.Where(x => x.ay == ay).Sum(x => x.belge);
                return new
                {
                    ay, net = R(t.Net(kip.IadeDus)), maliyet = R(t.Maliyet(kip.IadeDus)), kar = R(t.Kar(kip.IadeDus)),
                    marj = Marj(t, kip.IadeDus), iskontoOran = Yuzde(t.Isk, t.Brut),
                    maliyetsiz = l.Count(k => k.Maliyetsiz && !k.B.Iade), belge = t.Belge.Count,
                    aktarim = th, aktarimSatirYok = th > 0 && l.Count == 0,
                    kismiGun = ay.Year == d.Bit.Year && ay.Month == d.Bit.Month && d.Bit.Day < DateTime.DaysInMonth(ay.Year, ay.Month)
                        ? d.Bit.Day : (int?)null,
                };
            }).ToList();
            var enBuyukAy = Math.Max(aylarHam.Count > 0 ? aylarHam.Max(x => x.kar) : 0, 0.01m);
            var aylar = aylarHam.Select(x => new
            {
                x.ay, x.net, x.maliyet, x.kar, x.marj, x.iskontoOran, x.maliyetsiz, x.belge, x.aktarim, x.aktarimSatirYok, x.kismiGun,
                cubuk = Yuzde(Math.Max(x.kar, 0), enBuyukAy),
            }).ToList();

            // ---------------------------------------------------------- özet --
            var maliyetsizKalem = tumCari.Where(k => k.Maliyetsiz && !k.B.Iade).ToList();
            var hizmetKalem = kalemler.Where(k => k.Hizmet).ToList();
            var hizmetNet = Topla(hizmetKalem).Net(kip.IadeDus);
            var satisBelge = kalemler.Where(k => !k.B.Iade).Select(k => k.B).DistinctBy(x => x.Id).ToList();
            var ozet = new
            {
                net = R(net), maliyet = R(top.Maliyet(kip.IadeDus)), kar = R(kar), marj,
                karsiKar = R(oncekiTop.Kar(kip.IadeDus)), karsiMarj = oncekiMarj, marjFark = Puan(marj, oncekiMarj),
                iskonto = R(top.Isk), iskontoKarOran = Yuzde(top.Isk, kar), iade = R(top.Iade), iadeMaliyet = R(top.IadeMal),
                belge = satisBelge.Count, iadeBelge = top.IadeBelge.Count, musteri = satisBelge.Select(x => x.TarafId).Distinct().Count(),
                kalem = kalemler.Where(k => k.S is not null).Select(k => k.Anahtar).Distinct().Count(),
                zararli = new
                {
                    satir = zararlar.Count, tutar = R(zararlar.Sum(x => x.fark)), musteri = zararlar.Select(x => x.cariId).Distinct().Count(),
                },
                maliyetsiz = new
                {
                    satir = maliyetsizKalem.Count, net = R(maliyetsizKalem.Sum(k => k.Net)), haric,
                    urun = maliyetsizKalem.Select(k => k.Anahtar).Distinct().Count(),
                },
                hizmet = new { net = R(hizmetNet), pay = Yuzde(hizmetNet, net), dahil = hizmetDahil },
            };

            // ------------------------------------------------- A4 (satış anı) --
            var a4Top = Topla(a4Kalem);
            var a4Musteri = a4Kalem.GroupBy(k => k.B.TarafId).Select(g =>
            {
                var t = Topla(g);
                return new
                {
                    id = g.Key, ad = g.First().B.Cari, net = R(t.Net(kip.IadeDus)), maliyet = R(t.Maliyet(kip.IadeDus)),
                    kar = R(t.Kar(kip.IadeDus)), marj = Marj(t, kip.IadeDus),
                };
            }).OrderByDescending(x => x.net).ToList();
            var a4Maliyetsiz = haric ? 0m : a4Kalem.Where(k => k.Maliyetsiz && !k.B.Iade).Sum(k => k.Net);
            var a4 = new
            {
                musteriler = a4Musteri,
                toplam = new
                {
                    net = R(a4Top.Net(kip.IadeDus)), maliyet = R(a4Top.Maliyet(kip.IadeDus)), maliyetsizNet = R(a4Maliyetsiz),
                    kar = R(a4Top.Kar(kip.IadeDus)), marj = Marj(a4Top, kip.IadeDus), musteri = a4Musteri.Count,
                    kalem = a4Kalem.Where(k => k.S is not null).Select(k => k.Anahtar).Distinct().Count(),
                },
                doviz = paraSatirlari.Where(p => !p.yerel && p.doviz is not null).Select(p => new { p.para, tutar = p.doviz }).ToList(),
            };

            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                bas = d.Bas, bit = d.Bit, karsi = new { tur = d.Karsi, bas = d.KBas, bit = d.KBit }, gun = d.Gun,
                iadeDus = kip.IadeDus, hizmetDahil, maliyetsizHaric = haric, maliyetKipi = bugunKipi ? "bugun" : "satis",
                para = kip.Para, yerelPara = kip.Yerel, sube = s0, temsilci = tms, kategori = k0,
                hedefMarj = hedef, esik = new { dusukMarj = DusukMarj, yuksekMarj = YuksekMarj, yuksekIskonto = YuksekIskonto },
                ozet,
                aktarimTahakkuk = new { belge = donemTahakkuk.Sum(x => x.belge), tutar = R(donemTahakkuk.Sum(x => x.tutar)) },
                musteriler, musteriToplam, urunler, temsilciler, temsilciToplam, kirilim,
                zararli = new { satirlar = zararlar.Take(300).ToList(), sayi = zararlar.Count, tutar = R(zararlar.Sum(x => x.fark)) },
                matris, trend = new { aylar }, a4,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    temsilciler = temsilciSecim, paralar, kategoriler,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
