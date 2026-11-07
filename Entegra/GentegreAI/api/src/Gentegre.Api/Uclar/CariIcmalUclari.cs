using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// CARİ İCMALİ `/api/cari-icmali` (mockup Ekranlar/İcmal/cari_icmali.html, kullanıcı
/// 23.10.2026: "tek ekran olsun" - müşteri ve tedarikçi birlikte).
///
/// <para>Cari başına: devir (dönem başından önceki bakiye), dönem borç / alacak,
/// bakiye, yaşlandırma (FIFO - karşı yöndeki hareket önce vadesi en eski kalemi
/// kapatır; vade = hareketin plan tarihi, yoksa işlem + carinin vade günü),
/// en eski gecikme, son hareket / tahsilat, döviz bakiyeleri. Küme Kasa › Cari
/// Ekstre ile aynı (v_cari_ekstre, bakiyeye dahil satırlar); tutarlar hareketin
/// kendi kuruyla TL karşılığı.</para>
///
/// <para>Grup: yalnız müşteri → Müşteriler, yalnız tedarikçi → Tedarikçiler; ikisi
/// birden ise bakiyenin yönü (borçlu → Müşteriler) - tek satır, iki kez sayılmaz.
/// Personel cari hesapları kapsam dışı. Özet, yaşlandırma, kırılım ve dikkat
/// listeleri sunucuda; ekran hesap yapmaz.</para>
/// </summary>
public static class CariIcmalUclari
{
    /// <summary>Ekran kodu (1154) - haklarını kasa.finans'tan kopyalar.</summary>
    private const string Kod = "finans.cari_icmali";
    /// <summary>Kuruş farkı kapatma aksiyonu (1269).</summary>
    private const string AksiyonKurusKapat = "finans.kurus_kapat";
    /// <summary>Kasa işlem türleri (1269): 60 gider (müşteri borcu silinir), 62 gelir (cari alacağı silinir).</summary>
    private const int TurKurusGider = 60, TurKurusGelir = 62;
    private const decimal VarsayilanEsik = 0.10m;

    /// <summary>Ekranda önizlenen cariler (TarafIdler) kapatılır; eşik ve küçük kuralı sunucuda, tek yerde.</summary>
    public sealed record KurusKapatIstegi(DateTime? Tarih, int? GiderId, int? GelirId, string? Aciklama,
                                          string? Kapsam, int? Temsilci, int[]? TarafIdler);

    /// <summary>
    /// KÜÇÜK BAKİYE kuralı (tek yer, sunucu): 0,005 &lt; |TL bakiye| &lt; eşik ve açık DÖVİZ bakiyesi yok - döviz
    /// bakiyesi açık cari "kuruş" değildir. Satırda `kucuk` bayrağı olarak gider; ekran süzer, kapatma bunu yazar.
    /// </summary>
    private static bool Kucuk(Cari c, decimal esik) =>
        Math.Abs(c.Bakiye) > 0.005m && Math.Abs(c.Bakiye) < esik && !DovizAcik(c.Doviz);

    /// <summary>"USD:120;TL:0.03" dizisinde TL dışı sıfırdan farklı bakiye var mı.</summary>
    private static bool DovizAcik(string doviz) => doviz.Split(';', StringSplitOptions.RemoveEmptyEntries).Any(p =>
    {
        var i = p.IndexOf(':');
        if (i <= 0) return false;
        var kod = p[..i];
        return kod is not ("TL" or "TRY")
            && decimal.TryParse(p[(i + 1)..], System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var v) && Math.Abs(v) > 0.005m;
    });

    private static async Task<decimal> EsikAsync(Npgsql.NpgsqlConnection b, CancellationToken iptal)
    {
        var e = await AyarDeposu.OndalikAsync(b, null, "cari.icmal_esik", iptal);
        return e is > 0 ? e.Value : VarsayilanEsik;
    }

    /// <summary>Kuruş farkı kalemleri (Genel Ayarlar): gider masraf no, gelir hizmet no; 0 = seçilmemiş.</summary>
    private static async Task<(int Gider, int Gelir)> KalemlerAsync(Npgsql.NpgsqlConnection b, CancellationToken iptal) =>
        ((int)(await AyarDeposu.OndalikAsync(b, null, "cari.kurus_gider_id", iptal) ?? 0),
         (int)(await AyarDeposu.OndalikAsync(b, null, "cari.kurus_gelir_id", iptal) ?? 0));

    /// <summary>
    /// HBYS'DE YALNIZ TEDARİKÇİ (kullanıcı 23.10.2026): müşteri tarafı orada hasta ve anlaşmalı kurumdur - kendi
    /// icmalleri var. Kapsam sunucuda sabitlenir: (sadeceTedarikci, kapsamKod 0 hepsi / 1 müşteri / 2 tedarikçi).
    /// </summary>
    private static async Task<(bool SadeceTedarikci, int KapsamKod)> KapsamAsync(Npgsql.NpgsqlConnection b, string? kapsam, CancellationToken iptal)
    {
        var sadeceTedarikci = await b.TekDegerAsync<int>("select public.fn_urun_modu(0)::int", null, [], iptal) == 2;
        return (sadeceTedarikci, sadeceTedarikci ? 2 : kapsam switch { "musteri" => 1, "tedarikci" => 2, _ => 0 });
    }

    private const string Satis = "15, 16, 17";
    private const string Alis = "11, 12, 13";

    /// <summary>Ortak küme: carinin seçimi (tr), hareketler (h), FIFO açık kalemler (acik).
    ///   @p0 bas · @p1 bit (dahil) · @p2 kapsam 0/1/2 · @p3 temsilci · @p4 kayıt kapsamı · @p5 pasif dahil.
    ///   Müşteri Risk İcmali (1178) ödeme davranışını AYNI kapama kuralıyla bundan türetir.</summary>
    internal const string Kume = $"""
        with tr as materialized (
            select t.id, t.musteri, t.tedarikci, t.durum, t.temsilci, t.kategori,
                   coalesce(t.kod, '') as kod,
                   coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad,
                   coalesce(tm.vade_gun, 0) as vade_gun, coalesce(t.risk_limit, 0) as risk_limiti
              from public.taraf t
              left join public.taraf_musteri tm on tm.id = t.id
             where (t.musteri = 1 or t.tedarikci = 1) and t.personel = 0
               and (@p2 = 0 or (@p2 = 1 and t.musteri = 1) or (@p2 = 2 and t.tedarikci = 1))
               and (@p3 = 0 or t.temsilci = @p3)
               and (cardinality(@p4::int[]) = 0 or t.id = any(@p4::int[]))
               and (@p5 = 1 or t.durum = 1)
        ),
        h as materialized (
            select e.id, e.taraf_id, e.tur, e.islem_tarihi, e.doviz_cinsi, e.borc, e.alacak,
                   e.yerel_borc, e.yerel_alacak, coalesce(e.belge_no, '') as belge_no, coalesce(e.tur_adi, '') as tur_adi,
                   coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => tr.vade_gun)) as vade
              from public.v_cari_ekstre e
              join tr on tr.id = e.taraf_id
             where e.bakiye_dahil = 1 and e.islem_tarihi < (@p1::date + 1)
        ),
        fifo as (
            select h.taraf_id, h.vade, h.yerel_borc, h.yerel_alacak, h.belge_no, h.tur_adi,
                   sum(h.yerel_borc)   over (partition by h.taraf_id order by h.vade, h.id) as bir_borc,
                   sum(h.yerel_alacak) over (partition by h.taraf_id order by h.vade, h.id) as bir_alacak,
                   sum(h.yerel_borc)   over (partition by h.taraf_id) as top_borc,
                   sum(h.yerel_alacak) over (partition by h.taraf_id) as top_alacak
              from h
        ),
        -- Borç kaleminin açık kısmı = min(borç, max(0, vadeye göre birikimli borç - toplam alacak)); alacak simetrik.
        acik as (
            select f.taraf_id, f.vade, f.belge_no, f.tur_adi,
                   least(f.yerel_borc,   greatest(0, f.bir_borc   - f.top_alacak)) as acik_borc,
                   least(f.yerel_alacak, greatest(0, f.bir_alacak - f.top_borc))   as acik_alacak
              from fifo f
        )
        """;

    private const string CariSorgusu = Kume + $"""
        ,
        yas as (
            select a.taraf_id,
                   sum(a.acik_borc - a.acik_alacak) filter (where a.vade >= current_date) as gelmemis,
                   sum(a.acik_borc - a.acik_alacak) filter (where a.vade < current_date and a.vade >= current_date - 30) as d30,
                   sum(a.acik_borc - a.acik_alacak) filter (where a.vade < current_date - 30 and a.vade >= current_date - 60) as d60,
                   sum(a.acik_borc - a.acik_alacak) filter (where a.vade < current_date - 60 and a.vade >= current_date - 90) as d90,
                   sum(a.acik_borc - a.acik_alacak) filter (where a.vade < current_date - 90) as d90p,
                   max(current_date - a.vade::date) filter (where (a.acik_borc + a.acik_alacak) > 0.005
                                                              and a.vade < current_date) as en_eski
              from acik a group by a.taraf_id
        ),
        top as (
            select h.taraf_id,
                   sum(h.yerel_borc - h.yerel_alacak) filter (where h.islem_tarihi < @p0::date) as devir,
                   sum(h.yerel_borc)   filter (where h.islem_tarihi >= @p0::date) as donem_borc,
                   sum(h.yerel_alacak) filter (where h.islem_tarihi >= @p0::date) as donem_alacak,
                   sum(h.yerel_borc - h.yerel_alacak) as bakiye,
                   sum(h.yerel_borc - h.yerel_alacak) filter (where h.islem_tarihi >= @p0::date and h.tur in ({Satis})) as satis,
                   sum(h.yerel_alacak - h.yerel_borc) filter (where h.islem_tarihi >= @p0::date and h.tur in ({Alis})) as alis,
                   sum(h.yerel_alacak) filter (where h.islem_tarihi >= @p0::date and h.tur not in ({Satis}, {Alis})) as tahsilat,
                   sum(h.yerel_borc)   filter (where h.islem_tarihi >= @p0::date and h.tur not in ({Satis}, {Alis})) as odeme,
                   max(h.islem_tarihi) as son_hareket,
                   max(h.islem_tarihi) filter (where h.yerel_alacak > 0 and h.tur not in ({Satis}, {Alis})) as son_tahsilat
              from h group by h.taraf_id
        ),
        dvz as (
            select x.taraf_id, string_agg(x.doviz_cinsi || ':' || x.b::text, ';' order by x.doviz_cinsi) as doviz
              from (select h.taraf_id, h.doviz_cinsi, sum(h.borc - h.alacak) as b
                      from h group by 1, 2 having abs(sum(h.borc - h.alacak)) >= 0.005) x
             group by x.taraf_id
        )
        select tr.id, tr.kod, tr.ad, tr.musteri, tr.tedarikci, tr.durum, coalesce(tr.temsilci, 0),
               coalesce((select public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) from public.taraf p where p.id = tr.temsilci), ''),
               coalesce((select k.ad from public.kategori k where k.id = tr.kategori), ''),
               coalesce((select ta.il from public.taraf_adres ta where ta.taraf_id = tr.id and ta.varsayilan = 1 limit 1), ''),
               coalesce(top.devir, 0), coalesce(top.donem_borc, 0), coalesce(top.donem_alacak, 0), coalesce(top.bakiye, 0),
               coalesce(top.satis, 0), coalesce(top.alis, 0), coalesce(top.tahsilat, 0), coalesce(top.odeme, 0),
               coalesce(yas.gelmemis, 0), coalesce(yas.d30, 0), coalesce(yas.d60, 0), coalesce(yas.d90, 0), coalesce(yas.d90p, 0),
               coalesce(yas.en_eski, 0), top.son_hareket, top.son_tahsilat, tr.risk_limiti, coalesce(dvz.doviz, '')
          from tr
          left join top on top.taraf_id = tr.id
          left join yas on yas.taraf_id = tr.id
          left join dvz on dvz.taraf_id = tr.id
         order by tr.ad
        """;

    /// <summary>Önümüzdeki 8 hafta: vadesi gelecek açık alacak (tahsilat) ve borç (ödeme).</summary>
    private const string NakitSorgusu = Kume + """
        select ((a.vade::date - current_date) / 7)::int as hafta,
               coalesce(sum(a.acik_borc), 0), coalesce(sum(a.acik_alacak), 0)
          from acik a
         where a.vade >= current_date and a.vade < current_date + 56
         group by 1 order by 1
        """;

    /// <summary>Para birimi kırılımı: cari + para başına kendi bakiyesi ve TL karşılığı.</summary>
    private const string ParaSorgusu = Kume + """
        select x.doviz_cinsi, count(*)::int,
               coalesce(sum(x.b) filter (where x.b > 0), 0), coalesce(-sum(x.b) filter (where x.b < 0), 0), coalesce(sum(x.y), 0)
          from (select h.taraf_id, h.doviz_cinsi, sum(h.borc - h.alacak) as b, sum(h.yerel_borc - h.yerel_alacak) as y
                  from h group by 1, 2 having abs(sum(h.borc - h.alacak)) >= 0.005) x
         group by x.doviz_cinsi
         order by (x.doviz_cinsi <> public.fn_yerel_para()), x.doviz_cinsi
        """;

    /// <summary>7 gün içinde vadesi gelen ödemelerimiz (açık alacak kalemi = bizim borcumuz).</summary>
    private const string OdemeSorgusu = Kume + """
        select a.taraf_id, tr.ad, a.vade, a.tur_adi, a.belge_no, a.acik_alacak
          from acik a join tr on tr.id = a.taraf_id
         where a.acik_alacak > 0.005 and a.vade >= current_date and a.vade < current_date + 8
         order by a.vade, a.acik_alacak desc
         limit 50
        """;

    internal sealed record Cari(int Id, string Kod, string Ad, bool Musteri, bool Tedarikci, short Durum,
        int TemsilciId, string Temsilci, string Kategori, string Il,
        decimal Devir, decimal DonemBorc, decimal DonemAlacak, decimal Bakiye,
        decimal Satis, decimal Alis, decimal Tahsilat, decimal Odeme,
        decimal Gelmemis, decimal D30, decimal D60, decimal D90, decimal D90p, int EnEskiGun,
        DateTime? SonHareket, DateTime? SonTahsilat, decimal RiskLimiti, string Doviz, string Grup)
    {
        public decimal VadesiGecen => D30 + D60 + D90 + D90p;
        public decimal? RiskYuzde => RiskLimiti > 0 ? Math.Round(Math.Max(Bakiye, 0) * 100 / RiskLimiti) : null;
    }

    /// <summary>Cari satırları (CariSorgusu) - parametreler <see cref="Kume"/> ile aynı. Müşteri Risk İcmali (1178)
    ///   açık bakiye / yaşlandırma / temsilci için aynı satırları okur, ikinci sorgu yazmaz.</summary>
    internal static Task<List<Cari>> CarilarAsync(Npgsql.NpgsqlConnection b, object?[] p, CancellationToken iptal)
        => b.ListeAsync(CariSorgusu, null, p, o =>
            {
                var musteri = o.GetInt16(3) == 1; var tedarikci = o.GetInt16(4) == 1;
                var bakiye = o.GetDecimal(13);
                var grupAd = musteri && !tedarikci ? "musteri" : !musteri && tedarikci ? "tedarikci"
                           : bakiye > 0.005m ? "musteri" : "tedarikci";
                return new Cari(o.GetInt32(0), o.GetString(1), o.GetString(2), musteri, tedarikci, o.GetInt16(5),
                    o.GetInt32(6), o.GetString(7), o.GetString(8), o.GetString(9),
                    o.GetDecimal(10), o.GetDecimal(11), o.GetDecimal(12), bakiye,
                    o.GetDecimal(14), o.GetDecimal(15), o.GetDecimal(16), o.GetDecimal(17),
                    o.GetDecimal(18), o.GetDecimal(19), o.GetDecimal(20), o.GetDecimal(21), o.GetDecimal(22), o.GetInt32(23),
                    o.IsDBNull(24) ? null : o.GetDateTime(24), o.IsDBNull(25) ? null : o.GetDateTime(25),
                    o.GetDecimal(26), o.GetString(27), grupAd);
            }, iptal);

    public static void CariIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/cari-icmali").WithTags("Cari İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? kapsam, int? temsilci, int? pasif,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.Bugun.Date;
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            await using var b = await veri.AcAsync(iptal);
            var (sadeceTedarikci, kapsamKod) = await KapsamAsync(b, kapsam, iptal);
            object?[] p = [baslangic, bitis, kapsamKod, temsilci ?? 0, baglam.Kapsam.ToArray(), pasif ?? 0];

            var carilar = await CarilarAsync(b, p, iptal);
            var nakitHam = await b.ListeAsync(NakitSorgusu, null, p,
                o => (hafta: o.GetInt32(0), tahsilat: o.GetDecimal(1), odeme: o.GetDecimal(2)), iptal);
            var paralar = await b.ListeAsync(ParaSorgusu, null, p, o => new
            {
                doviz = o.GetString(0), cari = o.GetInt32(1), alacak = o.GetDecimal(2), borc = o.GetDecimal(3), yerel = o.GetDecimal(4),
            }, iptal);
            var odemeler = await b.ListeAsync(OdemeSorgusu, null, p, o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), vade = o.GetDateTime(2), turAdi = o.GetString(3),
                belgeNo = o.GetString(4), tutar = o.GetDecimal(5),
            }, iptal);

            // ÇEKLER: kümedeki carilerin müşteri çeki (portföy / tahsilde / teminatta) ve
            //   verdiğimiz, henüz ödenmemiş çekler; haftalık vade dağılımı nakit beklentisine.
            var idler = carilar.Select(c => c.Id).ToArray();
            var cekler = await b.ListeAsync("""
                select c.yon, c.vade, c.yerel_tutar
                  from public.cek_senet c
                 where c.taraf_id = any(@p0)
                   and ((c.yon = 1 and c.durum in (10, 30, 40)) or (c.yon = 2 and c.durum not in (0, 50, 60, 70)))
                """, null, [idler], o => (yon: o.GetInt16(0), vade: o.GetDateTime(1), tutar: o.GetDecimal(2)), iptal);

            // ---------------------------------------------------------- özet --
            var mus = carilar.Where(c => c.Grup == "musteri").ToList();
            var ted = carilar.Where(c => c.Grup == "tedarikci").ToList();
            var alacak = carilar.Where(c => c.Bakiye > 0.005m).Sum(c => c.Bakiye);
            var borc = -carilar.Where(c => c.Bakiye < -0.005m).Sum(c => c.Bakiye);
            var gecenAlacak = carilar.Where(c => c.VadesiGecen > 0.005m).ToList();
            var gecenBorc = carilar.Where(c => c.VadesiGecen < -0.005m).ToList();
            int Agirlikli(List<Cari> l) { var t = l.Sum(c => Math.Abs(c.VadesiGecen)); return t > 0 ? (int)Math.Round(l.Sum(c => Math.Abs(c.VadesiGecen) * c.EnEskiGun) / t) : 0; }
            var ozet = new
            {
                alacak, alacakCari = carilar.Count(c => c.Bakiye > 0.005m),
                borc, borcCari = carilar.Count(c => c.Bakiye < -0.005m),
                net = alacak - borc,
                vadesiGecenAlacak = gecenAlacak.Sum(c => c.VadesiGecen), vadesiGecenAlacakCari = gecenAlacak.Count, vadesiGecenAlacakGun = Agirlikli(gecenAlacak),
                vadesiGecenBorc = -gecenBorc.Sum(c => c.VadesiGecen), vadesiGecenBorcCari = gecenBorc.Count, vadesiGecenBorcGun = Agirlikli(gecenBorc),
                satis = mus.Sum(c => c.Satis), tahsilat = mus.Sum(c => c.Tahsilat),
                alis = ted.Sum(c => c.Alis), odeme = ted.Sum(c => c.Odeme),
                cekAlinan = cekler.Where(c => c.yon == 1).Sum(c => c.tutar), cekAlinanAdet = cekler.Count(c => c.yon == 1),
                cekVerilen = cekler.Where(c => c.yon == 2).Sum(c => c.tutar), cekVerilenAdet = cekler.Count(c => c.yon == 2),
                musteriCari = mus.Count, tedarikciCari = ted.Count,
            };

            // --------------------------------------------------- yaşlandırma --
            object Dilimler(IEnumerable<Cari> l, int isaret)
            {
                var liste = l.ToList();
                (string ad, Func<Cari, decimal> f)[] d =
                [
                    ("Vadesi gelmemiş", c => c.Gelmemis), ("0 – 30 gün", c => c.D30), ("31 – 60 gün", c => c.D60),
                    ("61 – 90 gün", c => c.D90), ("90+ gün", c => c.D90p),
                ];
                return d.Select(x =>
                {
                    var dolu = liste.Select(c => (c, t: x.f(c) * isaret)).Where(y => y.t > 0.005m).ToList();
                    var enb = dolu.OrderByDescending(y => y.t).FirstOrDefault();
                    return new { ad = x.ad, tutar = dolu.Sum(y => y.t), cari = dolu.Count,
                                 enBuyuk = enb.c?.Ad ?? "", enBuyukTutar = enb.t };
                }).ToList();
            }
            var yaslandirma = new
            {
                alacak = Dilimler(carilar.Where(c => c.Bakiye > 0.005m), 1),
                borc = Dilimler(carilar.Where(c => c.Bakiye < -0.005m), -1),
            };

            // ----------------------------------------------- nakit beklentisi --
            var nakit = Enumerable.Range(0, 8).Select(i =>
            {
                var hb = bugun.AddDays(7 * i);
                var n = nakitHam.FirstOrDefault(x => x.hafta == i);
                var cs = cekler.Where(c => c.vade.Date >= hb && c.vade.Date < hb.AddDays(7)).ToList();
                return new { bas = hb, bit = hb.AddDays(6), tahsilat = n.tahsilat, odeme = n.odeme,
                             cekAlinan = cs.Where(c => c.yon == 1).Sum(c => c.tutar),
                             cekVerilen = cs.Where(c => c.yon == 2).Sum(c => c.tutar) };
            }).ToList();

            // ------------------------------------------------------ kırılımlar --
            var kirilim = new
            {
                temsilci = mus.GroupBy(c => c.Temsilci).Select(g => new
                {
                    ad = g.Key, cari = g.Count(), satis = g.Sum(c => c.Satis), tahsilat = g.Sum(c => c.Tahsilat),
                    bakiye = g.Sum(c => c.Bakiye), vadesiGecen = g.Sum(c => Math.Max(c.VadesiGecen, 0)),
                }).OrderByDescending(x => x.bakiye).ToList(),
                kategori = carilar.GroupBy(c => c.Kategori).Select(g => new
                {
                    ad = g.Key, cari = g.Count(), bakiye = g.Sum(c => c.Bakiye), vadesiGecen = g.Sum(c => Math.Max(c.VadesiGecen, 0)),
                }).OrderByDescending(x => Math.Abs(x.bakiye)).ToList(),
                il = carilar.GroupBy(c => c.Il).Select(g => new
                {
                    ad = g.Key, cari = g.Count(), bakiye = g.Sum(c => c.Bakiye), satis = g.Sum(c => c.Satis),
                }).OrderByDescending(x => Math.Abs(x.bakiye)).Take(10).ToList(),
                para = paralar,
            };

            // --------------------------------------------------------- dikkat --
            var dikkat = new
            {
                limit = carilar.Where(c => c.RiskYuzde > 100).OrderByDescending(c => c.RiskYuzde)
                    .Select(c => new { c.Id, c.Ad, c.Bakiye, c.RiskLimiti, yuzde = c.RiskYuzde }).ToList(),
                tahsilatsiz = mus.Where(c => c.Bakiye > 0.005m && (c.SonTahsilat is null || c.SonTahsilat.Value.Date < bugun.AddDays(-90)))
                    .OrderByDescending(c => c.Bakiye).Take(50)
                    .Select(c => new { c.Id, c.Ad, c.Bakiye, c.SonTahsilat, c.Temsilci,
                                       gun = c.SonTahsilat is { } st ? (int)(bugun - st.Date).TotalDays : (int?)null }).ToList(),
                alacakli = carilar.Where(c => c.Musteri && !c.Tedarikci && c.Bakiye < -0.005m).OrderBy(c => c.Bakiye).Take(50)
                    .Select(c => new { c.Id, c.Ad, c.Bakiye, c.SonHareket }).ToList(),
                odemeler,
            };

            var temsilciler = carilar.Where(c => c.TemsilciId > 0).GroupBy(c => c.TemsilciId)
                .Select(g => new { id = g.Key, ad = g.First().Temsilci }).OrderBy(x => x.ad).ToList();

            // KÜÇÜK BAKİYE (1269, kullanıcı 05.11.2026): satırda `kucuk` bayrağı (kural tek yerde, Kucuk); ekran
            //   gizler ve dipte sayar. Kalem adları yalnız kapatma düğmesi çizilecekse okunur (pencere ön dolum).
            var esik = await EsikAsync(b, iptal);
            var kapatabilir = baglam.Yetkiler.AksiyonVar(AksiyonKurusKapat) && baglam.SubeYazma;
            var (giderId, gelirId) = kapatabilir ? await KalemlerAsync(b, iptal) : (0, 0);
            var kalemAdi = async (string tablo, int id) => id > 0
                ? await b.TekDegerAsync<string>($"select coalesce(kod || ' ', '') || ad from public.{tablo} where id = @p0", null, [id], iptal) ?? ""
                : "";
            var kucuk = new
            {
                esik, giderId, gelirId,
                giderAdi = await kalemAdi("masraf", giderId), gelirAdi = await kalemAdi("hizmet", gelirId),
                kapatabilir,
            };

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, sadeceTedarikci,
                kapsam = kapsamKod switch { 1 => "musteri", 2 => "tedarikci", _ => "hepsi" },
                ozet, yaslandirma, nakit, kirilim, dikkat, temsilciler, kucuk,
                carilar = carilar.Select(c => new
                {
                    c.Id, c.Kod, c.Ad, c.Musteri, c.Tedarikci, c.Durum, c.Temsilci, c.Kategori, c.Il,
                    c.Devir, c.DonemBorc, c.DonemAlacak, c.Bakiye, c.VadesiGecen, c.EnEskiGun,
                    c.SonHareket, c.SonTahsilat, c.RiskLimiti, c.RiskYuzde, c.Doviz, c.Grup,
                    c.Gelmemis, c.D30, c.D60, c.D90, c.D90p,
                    kucuk = Kucuk(c, esik),
                }),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ====================================================== KURUŞ FARKI KAPAT (1269) ===
        // Ekranda önizlenen carilere (TarafIdler) bir kasa işlemi: borçluysa 60 (cari alacak + gider), alacaklıysa
        //   62 (cari borç + gelir). Küçük kuralı GET ile aynı (Kucuk) - önizleme ile yazılan küme aynı hesaptır.
        //   Normal kasa işlemi: fişli, loglu, ekstrede görünür, iptal edilebilir. Her cari kendi işleminde
        //   (KasaDeposu.KaydetAsync); biri düşerse öncekiler kalır, sonuç sayar.
        grup.MapPost("/kurus-kapat", async (KurusKapatIstegi istek, VeriKaynagi veri, KasaDeposu kasa, BaglamCozucu cozucu,
                                            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.AksiyonIste(AksiyonKurusKapat);
            baglam.YazmaIste();
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();

            await using var b = await veri.AcAsync(iptal);
            var bugun = Saat.Bugun.Date;
            var tarih = (istek.Tarih ?? bugun).Date;
            if (tarih > bugun) throw GentegreHatasi.Dogrulama("İleri tarihli kapatma yazılamaz.", new AlanHatasi("tarih", "Bugünden ileri olamaz."));
            if (istek.TarafIdler is not { Length: > 0 }) throw GentegreHatasi.Dogrulama("Kapatılacak cari seçilmedi.", new AlanHatasi("tarafIdler", "Zorunlu."));
            var aciklama = (istek.Aciklama ?? "").Trim();
            if (aciklama.Length == 0) aciklama = "Kuruş farkı kapatma";
            if (aciklama.Length > 200) throw GentegreHatasi.Dogrulama("Açıklama en fazla 200 karakter.");

            var (_, kapsamKod) = await KapsamAsync(b, istek.Kapsam, iptal);
            object?[] p = [new DateTime(bugun.Year, 1, 1), bugun, kapsamKod, istek.Temsilci ?? 0, baglam.Kapsam.ToArray(), 0];
            var esik = await EsikAsync(b, iptal);
            var secim = istek.TarafIdler.ToHashSet();
            // Seçim ekranın önizlediği küme; bakiye bu arada değiştiyse (artık küçük değil) o cari yazılmaz.
            var hedef = (await CarilarAsync(b, p, iptal)).Where(c => secim.Contains(c.Id) && Kucuk(c, esik)).ToList();
            if (hedef.Count == 0) throw GentegreHatasi.IsKurali("Eşik altında kapatılacak cari yok.");

            var (ayarGider, ayarGelir) = await KalemlerAsync(b, iptal);
            var giderId = istek.GiderId ?? ayarGider;
            var gelirId = istek.GelirId ?? ayarGelir;
            if (hedef.Any(c => c.Bakiye > 0) && (giderId <= 0
                || await b.TekDegerAsync<int?>("select id from public.masraf where id = @p0", null, [giderId], iptal) is null))
                throw GentegreHatasi.Dogrulama("Borçlu cariler için gider kalemi (masraf) seçilmeli.", new AlanHatasi("giderId", "Zorunlu."));
            if (hedef.Any(c => c.Bakiye < 0) && (gelirId <= 0
                || await b.TekDegerAsync<int?>("select id from public.hizmet where id = @p0", null, [gelirId], iptal) is null))
                throw GentegreHatasi.Dogrulama("Alacaklı cariler için gelir kalemi (hizmet) seçilmeli.", new AlanHatasi("gelirId", "Zorunlu."));

            var yazilan = 0; decimal toplam = 0; var hatalar = new List<string>();
            foreach (var c in hedef)
            {
                var tutar = Math.Abs(Math.Round(c.Bakiye, 2));
                var islem = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = c.Bakiye > 0 ? TurKurusGider : TurKurusGelir,
                    ["islemTarihi"] = tarih.AddHours(12),
                    ["tarafId"] = c.Id,
                    ["tutar"] = tutar,
                    ["dovizCinsi"] = "TL",
                    ["dovizKuru"] = 1m,
                    ["yerelTutar"] = tutar,
                    ["aciklama"] = aciklama,
                    ["girisKaynak"] = 1,
                };
                if (c.Bakiye > 0) islem["masrafId"] = giderId; else islem["hizmetId"] = gelirId;
                try
                {
                    await kasa.KaydetAsync(islem, null, new KasaSecenekleri(), baglam.Yazma, iptal);
                    yazilan++; toplam += c.Bakiye;
                }
                catch (GentegreHatasi h) { hatalar.Add($"{c.Kod} {c.Ad}: {h.Message}"); }
            }
            return Results.Ok(new { yazilan, toplam, hata = hatalar.Count, hatalar = hatalar.Take(10), izlemeNo = baglam.IzlemeNo });
        });
    }
}
