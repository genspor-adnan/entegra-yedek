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
/// MÜŞTERİ RİSK / LİMİT İCMALİ `/api/musteri-risk-icmal` (1178 - mockup Ekranlar/İcmal/musteri_risk_icmali.html,
/// kararlar 25.10.2026). "Kime ne kadar açığız, kim limitini aştı, kime mal göndermeye devam etmeliyiz?"
///
/// <para><b>Risk</b> = açık cari bakiye + portföydeki müşteri çek / senedi + faturasız irsaliye + açık satış
/// siparişi - bileşenlerin kuralı TEK yerde: <see cref="MusteriRiskDeposu"/> (satış belgesi kaydındaki limit
/// kontrolü de aynı sorguyu çalıştırır). Vadesi geçen / yaşlandırma / temsilci Cari İcmali'nin satırlarından
/// (<see cref="CariIcmalUclari.CarilarAsync"/>), ödeme süresi Cari İcmali'nin FIFO kapama kuralından
/// (<see cref="CariIcmalUclari.Kume"/>: fatura → onu kapatan tahsilat).</para>
///
/// <para><b>Limit</b> taraf.risk_limit (null = TANIMSIZ, limitsiz değil), kendi dövizinde; TL karşılığı bugünkü kurla.
/// <b>Skor</b> A–D sabit ağırlıklı, yalnız bilgi (<see cref="MusteriRiskKurali.SkorHesapla"/>). <b>Bloke</b> icmal
/// KOYMAZ, önerir (<see cref="MusteriRiskKurali.BlokeOnerisi"/>); koyma / kaldırma, limit ve teminat değişikliği
/// `cari.risk_limit` aksiyonu ile, neden zorunlu, islem_log'a alan bazlı yazılır.</para>
///
/// <para>Şube süzgeci çek / irsaliye / sipariş bileşenine (kullanıcının şubeleri), cari kayıt kapsamı (baglam.Kapsam)
/// müşteri kümesine uygulanır. Rakamlar sunucuda; ekran toplamaz.</para>
/// </summary>
public static class MusteriRiskIcmalUclari
{
    /// <summary>Ekran kodu (1178) - hakları finans.cari_icmali'nden.</summary>
    private const string Kod = "finans.musteri_risk_icmali";

    /// <summary>Limit / teminat / sevk blokesi değiştirme aksiyonu (1178).</summary>
    private const string AksiyonLimit = "cari.risk_limit";

    /// <summary>islem_log.tablo_id - cari (KartKatalogu.Cari LogTabloId) ve taraf_teminat (yeni, 1730).</summary>
    private const int LogTabloCari = 71;
    private const int LogTabloTeminat = 1730;

    /// <summary>Tek müşterinin toplam riskteki payı bu eşiği aşarsa yoğunlaşma rozeti (mockup: %15).</summary>
    private const decimal YogunlasmaEsik = 15m;

    /// <summary>Kart DovizKodlari ile aynı küme.</summary>
    private static readonly HashSet<string> Dovizler = new(StringComparer.Ordinal) { "TL", "USD", "EUR", "GBP", "CHF", "JPY" };

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public static string TeminatTurAdi(int tur) => tur switch
    {
        1 => "Teminat mektubu", 2 => "İpotek", 3 => "Çek / senet", 4 => "Nakit", _ => "Diğer",
    };

    public sealed record LimitIstegi(int TarafId, decimal? Limit, string? Doviz, string? RiskGrubu, string? Neden, string? Surum);
    public sealed record BlokeIstegi(int TarafId, bool Bloke, string? Neden);
    public sealed record TeminatIstegi(int TarafId, short Tur, decimal Tutar, string? Doviz, DateTime? Baslangic, DateTime? Bitis,
        string? Aciklama, string? Surum);

    // ================================================================ sorgular ===

    /// <summary>
    /// ÖDEME DAVRANIŞI (son 12 ay) - Cari İcmali'nin kümesi ve FIFO sırası (vade, id): her borç kalemini, birikimli
    /// alacağı onun birikimli borcuna ilk yetişen alacak kalemi kapatır; kapanış tarihi = o alacağın işlem günü.
    /// Satış borçları (15, 16, 17). Ölçüye giren kalem: kapanmış ya da vadesi geçmiş açık (açık kalanın gecikmesi
    /// bugüne kadar). @p0–@p5 <see cref="CariIcmalUclari.Kume"/> · @p6 12 ay öncesi.
    /// </summary>
    internal const string OdemeSorgusu = CariIcmalUclari.Kume + """
        ,
        bk as (
            select h.taraf_id, h.id, h.tur, h.islem_tarihi::date as tarih, h.vade::date as vade,
                   round(sum(h.yerel_borc) over (partition by h.taraf_id order by h.vade, h.id), 2) as bir
              from h where h.yerel_borc > 0.005
        ),
        ak as (
            select h.taraf_id, h.islem_tarihi::date as tarih,
                   round(sum(h.yerel_alacak) over (partition by h.taraf_id order by h.vade, h.id), 2) as bir,
                   row_number() over (partition by h.taraf_id order by h.vade, h.id) as rn
              from h where h.yerel_alacak > 0.005
        ),
        akis as (
            select x.taraf_id, x.tur, x.tarih, x.vade, x.k,
                   count(*) filter (where x.k = 1) over (partition by x.taraf_id order by x.bir, x.k, x.sira
                                                         rows between unbounded preceding and current row) as ak_once
              from (select bk.taraf_id, bk.id::bigint as sira, bk.tur::int as tur, bk.tarih, bk.vade, bk.bir, 0 as k from bk
                    union all
                    select ak.taraf_id, ak.rn, 0, ak.tarih, null::date, ak.bir, 1 from ak) x
        ),
        kp as (
            select a.taraf_id, a.tarih, a.vade, ak.tarih as kapanis,
                   (ak.tarih is not null or a.vade < @p1::date) as olcu
              from akis a
              left join ak on ak.taraf_id = a.taraf_id and ak.rn = a.ak_once + 1
             where a.k = 0 and a.tur in (15, 16, 17) and a.tarih >= @p6::date
        )
        select kp.taraf_id, count(*)::int,
               round(avg(kp.vade - kp.tarih), 1),
               round(avg(greatest(kp.kapanis - kp.tarih, 0)) filter (where kp.kapanis is not null), 1),
               round(avg(greatest(coalesce(kp.kapanis, @p1::date) - kp.vade, 0)) filter (where kp.olcu), 1),
               round(100.0 * count(*) filter (where kp.kapanis is not null and kp.kapanis <= kp.vade)
                     / nullif(count(*) filter (where kp.olcu), 0), 1),
               round(avg(greatest(coalesce(kp.kapanis, @p1::date) - kp.vade, 0)) filter (where kp.olcu and kp.tarih >= @p1::date - 90), 1),
               round(avg(greatest(coalesce(kp.kapanis, @p1::date) - kp.vade, 0)) filter (where kp.olcu and kp.tarih < @p1::date - 90), 1)
          from kp
         group by kp.taraf_id
        """;

    /// <summary>Karşılıksız / protestolu müşteri evrakı (Çek / Senet İcmali kuralı: durum 60 ya da 134 hareketi):
    ///   müşteri başına toplam ve son 12 ay. @p0 taraflar · @p1 bugün · @p2 şubeler.</summary>
    internal const string KarsiliksizSorgusu = """
        select c.taraf_id, count(*)::int, (count(*) filter (where coalesce(ks.t, c.vade) >= @p1::date - 365))::int,
               max(extract(year from coalesce(ks.t, c.vade)))::int
          from public.cek_senet c
          left join lateral (select max(h.tarih) as t from public.cek_senet_hareket h
                              where h.cek_senet_id = c.id and h.islem = 134) ks on true
         where c.yon = 1 and c.taraf_id = any(@p0::int[]) and c.sube_id = any(@p2::int[])
           and (c.durum = 60 or ks.t is not null)
         group by c.taraf_id
        """;

    /// <summary>Keşideci adına göre karşılıksız geçmişi (Çek / Senet İcmali "keşideci" sekmesiyle aynı sorgu). @p0 şubeler.</summary>
    private const string KesideciKarsiliksizSorgusu = """
        select coalesce(nullif(btrim(c.kesideci), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''),
               count(*)::int,
               max(extract(year from coalesce((select max(h.tarih) from public.cek_senet_hareket h
                                                where h.cek_senet_id = c.id and h.islem = 134), c.vade)))::int
          from public.cek_senet c
          left join public.taraf t on t.id = c.taraf_id
         where c.yon = 1 and c.sube_id = any(@p0::int[])
           and (c.durum = 60 or exists (select 1 from public.cek_senet_hareket h
                                         where h.cek_senet_id = c.id and h.islem = 134))
         group by 1
        """;

    /// <summary>Riske giren müşteri çekleri (risk sorgusunun çek kümesi) - müşteri × keşideci × banka.
    ///   @p0 taraflar · @p1 bugün · @p2 şubeler (boş = hepsi).</summary>
    private const string CekSorgusu = """
        with y as materialized (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel)
        select c.taraf_id, coalesce(btrim(c.kesideci), ''),
               coalesce(nullif(btrim(bk.kisa_ad), ''), nullif(btrim(bk.ad), ''), btrim(c.banka_adi), ''),
               count(*)::int, sum(d.deger), min(c.vade), max(c.vade),
               coalesce(sum(d.deger) filter (where c.vade < @p1::date + 8), 0)
          from public.cek_senet c
          cross join y
          left join public.banka bk on bk.id = c.banka_id
          cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(c.doviz_cinsi), ''), 'TL'))::varchar(6) as para) p
          cross join lateral (select case when p.para = y.yerel then c.tutar
                                          else round(c.tutar * coalesce(public.fn_doviz_kur_getir(p.para, @p1::date, 2::smallint),
                                                                       nullif(c.doviz_kuru, 0), 1), 2) end as deger) d
         where c.yon = 1 and c.durum in (10, 30, 40) and c.vade >= @p1::date
           and c.taraf_id = any(@p0::int[])
           and (cardinality(@p2::int[]) = 0 or c.sube_id = any(@p2::int[]))
         group by 1, 2, 3
         order by 5 desc
        """;

    /// <summary>Teminatlar (bugün geçerli olanlar işaretli). @p0 taraflar · @p1 bugün.</summary>
    private const string TeminatSorgusu = """
        select tt.id, tt.taraf_id, tt.tur, tt.tutar, coalesce(nullif(btrim(tt.doviz), ''), 'TL'), tt.baslangic, tt.bitis,
               coalesce(tt.aciklama, ''),
               (tt.baslangic is null or tt.baslangic <= @p1::date) and (tt.bitis is null or tt.bitis >= @p1::date),
               coalesce(k.ad, '')::varchar(160), tt.ekleme_tarihi, tt.xmin::text
          from public.taraf_teminat tt
          left join public.v_kullanici_lookup k on k.id = tt.ekleyen
         where tt.taraf_id = any(@p0::int[])
         order by tt.taraf_id, (tt.bitis is null or tt.bitis >= @p1::date) desc, tt.tutar desc, tt.id
        """;

    /// <summary>Son limit değişikliği (islem_log: cari tablosu, `riskLimit` alanı). @p0 taraflar.</summary>
    private const string SonLimitSorgusu = """
        select distinct on (l.kayit_id) l.kayit_id::int, l.tarih, coalesce(k.ad, '')::varchar(160)
          from public.islem_log l
          left join public.v_kullanici_lookup k on k.id = l.kullanici_id
         where l.tablo_id = 71 and l.islem_tipi = 2 and l.kayit_id = any(@p0::int[]) and l.bilgi ? 'riskLimit'
         order by l.kayit_id, l.tarih desc
        """;

    private sealed record Odeme(int Fatura, decimal? OrtVade, decimal? OrtOdeme, decimal? OrtGecikme, decimal? Zamaninda,
        decimal? SonGecikme, decimal? OncekiGecikme)
    {
        /// <summary>Son 90 günün gecikmesi önceki dönemden 3 günden fazla iyi → ↗, kötü → ↘.</summary>
        public string Egilim => SonGecikme is { } s && OncekiGecikme is { } o
            ? (s < o - 3 ? "iyilesiyor" : s > o + 3 ? "kotulesiyor" : "sabit") : "";
    }

    private sealed record Teminat(long Id, int TarafId, int Tur, decimal Tutar, string Doviz, DateTime? Baslangic, DateTime? Bitis,
        string Aciklama, bool Aktif, string Ekleyen, DateTime EklemeTarihi, string Surum)
    {
        public string TurAdi => TeminatTurAdi(Tur);
    }

    private static Task<List<Teminat>> TeminatlarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int[] taraflar, DateTime bugun,
        CancellationToken iptal)
        => b.ListeAsync(TeminatSorgusu, tx, [taraflar, bugun.Date], o => new Teminat(
            o.GetInt64(0), o.GetInt32(1), o.GetInt16(2), o.GetDecimal(3), o.GetString(4),
            o.IsDBNull(5) ? null : o.GetDateTime(5), o.IsDBNull(6) ? null : o.GetDateTime(6), o.GetString(7),
            o.GetBoolean(8), o.GetString(9), o.GetDateTime(10), o.GetString(11)), iptal);

    private static string TeminatOzeti(IEnumerable<Teminat> l) => string.Join(" · ", l.Where(t => t.Aktif).Select(t =>
        $"{t.TurAdi} {t.Tutar.ToString("N0", Tr)}{(t.Doviz is "TL" or "TRY" ? "" : " " + t.Doviz)}"));

    /// <summary>Limit durumu: tanimsiz · kurYok · asim · yaklasiyor (≥ %80) · uygun.</summary>
    private static (decimal? kullanim, decimal asim, string durum) LimitDurumu(MusteriRiskDeposu.Satir r, decimal toplam)
    {
        if (r.Limit is null) return (null, 0, "tanimsiz");
        if (r.LimitTl is not { } ltl) return (null, 0, "kurYok");
        var asim = Math.Max(0, toplam - ltl);
        decimal? kullanim = ltl > 0 ? Math.Round(Math.Max(toplam, 0) * 100 / ltl, 1) : null;
        var durum = asim > 0.005m ? "asim" : kullanim >= 80 ? "yaklasiyor" : "uygun";
        return (kullanim, asim, durum);
    }

    // =================================================================== uçlar ===

    public static void MusteriRiskIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var uc = yol.MapGroup("/api/musteri-risk-icmal").WithTags("Müşteri Risk / Limit İcmali").RequireAuthorization();

        // ===================================================================== GET ===
        uc.MapGet("/", async (int? sube, int? temsilci, string? grup, int? cek, int? siparis, int? tanimsiz,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var tumSubeler = baglam.Subeler.Select(s => s.Id).ToArray();
            int[] subeler;
            if (sube is > 0)
            {
                if (!tumSubeler.Contains(sube.Value)) throw GentegreHatasi.Bulunamadi("Şube bulunamadı.");
                subeler = [sube.Value];
            }
            else subeler = tumSubeler;
            var cekDahil = (cek ?? 1) != 0;
            var siparisDahil = (siparis ?? 1) != 0;
            var tanimsizGizle = (tanimsiz ?? 0) == 1;
            var grupSecim = (grup ?? "").Trim();
            if (grupSecim.Length > 60) throw GentegreHatasi.Dogrulama("Risk grubu geçersiz.");
            var yilOnce = bugun.AddYears(-1);

            await using var b = await veri.AcAsync(iptal);

            // MÜŞTERİ KÜMESİ = Cari İcmali'nin müşteri satırları (aktif, kayıt kapsamı, temsilci süzgeci).
            object?[] p = [yilOnce, bugun, 1, temsilci ?? 0, baglam.Kapsam.ToArray(), 0];
            var carilar = (await CariIcmalUclari.CarilarAsync(b, p, iptal)).ToDictionary(c => c.Id);
            var idler = carilar.Keys.ToArray();

            var riskler = await MusteriRiskDeposu.OkuAsync(b, null, idler, bugun, subeler, iptal);
            var odemeler = (await b.ListeAsync(OdemeSorgusu, null, [.. p, yilOnce], o =>
            {
                decimal? D(int i) => o.IsDBNull(i) ? null : o.GetDecimal(i);
                return (id: o.GetInt32(0), od: new Odeme(o.GetInt32(1), D(2), D(3), D(4), D(5), D(6), D(7)));
            }, iptal)).ToDictionary(x => x.id, x => x.od);
            var karsiliksiz = (await b.ListeAsync(KarsiliksizSorgusu, null, [idler, bugun, tumSubeler],
                o => (id: o.GetInt32(0), toplam: o.GetInt32(1), son12: o.GetInt32(2), yil: o.IsDBNull(3) ? (int?)null : o.GetInt32(3)), iptal))
                .ToDictionary(x => x.id);
            var teminatlar = (await TeminatlarAsync(b, null, idler, bugun, iptal)).ToLookup(t => t.TarafId);
            var sonLimit = (await b.ListeAsync(SonLimitSorgusu, null, [idler],
                o => (id: o.GetInt32(0), an: o.GetDateTime(1), kim: o.GetString(2)), iptal)).ToDictionary(x => x.id);

            // ------------------------------------------------------------ satırlar --
            var tumu = riskler.Select(r =>
            {
                var c = carilar[r.TarafId];
                var toplam = r.Toplam(cekDahil, siparisDahil);
                var (kullanim, asim, durum) = LimitDurumu(r, toplam);
                var od = odemeler.GetValueOrDefault(r.TarafId);
                var ks = karsiliksiz.TryGetValue(r.TarafId, out var k) ? k : (id: r.TarafId, toplam: 0, son12: 0, yil: (int?)null);
                var skor = MusteriRiskKurali.SkorHesapla(od?.Zamaninda, od?.OrtGecikme, ks.son12, kullanim);
                int? sonTahsilatGun = c.SonTahsilat is { } st ? (int)(bugun - st.Date).TotalDays : null;
                var oneri = MusteriRiskKurali.BlokeOnerisi(r.SevkBlokesi, kullanim, asim, r.Teminat, Math.Max(c.D90p, 0),
                                                           ks.son12, sonTahsilatGun, r.Bakiye);
                var tem = teminatlar[r.TarafId].ToList();
                var sl = sonLimit.TryGetValue(r.TarafId, out var s) ? s : default;
                return new
                {
                    id = r.TarafId, c.Kod, c.Ad, c.Temsilci, temsilciId = c.TemsilciId, r.RiskGrubu,
                    r.Bakiye, vadesiGecen = Math.Max(c.VadesiGecen, 0), r.Cek, r.CekAdet, r.Cek7Gun, r.Irsaliye, r.IrsaliyeAdet,
                    r.Siparis, r.SiparisAdet, toplam,
                    r.Limit, r.LimitDoviz, r.LimitTl, kullanim, asim, durum,
                    r.Teminat, r.TeminatAdet, teminatOzet = TeminatOzeti(tem), teminatIcinde = asim > 0.005m && r.Teminat >= asim,
                    r.SevkBlokesi, r.BlokeNeden, r.BlokeKim, r.BlokeAn,
                    skor = skor?.Harf, skorPuan = skor?.Puan, r.KurYok, r.Surum,
                    sonLimitAn = sl.id > 0 ? sl.an : (DateTime?)null, sonLimitKim = sl.id > 0 ? sl.kim : null,
                    yas = new
                    {
                        c.Gelmemis, c.D30, c.D60, c.D90, c.D90p, enEskiGun = c.EnEskiGun,
                        enEskiTarih = c.EnEskiGun > 0 ? bugun.AddDays(-c.EnEskiGun) : (DateTime?)null,
                    },
                    odeme = od is null ? null : new
                    {
                        od.Fatura, od.OrtVade, od.OrtOdeme, od.OrtGecikme, od.Zamaninda, od.Egilim,
                    },
                    karsiliksiz = ks.toplam, karsiliksiz12 = ks.son12, karsiliksizYil = ks.yil,
                    c.SonTahsilat, sonTahsilatGun,
                    oneri = oneri is null ? null : new { oneri.Kod, oneri.Ad, nedenler = oneri.Nedenler },
                };
            }).ToList();

            // Seçim listeleri süzgeçten önce: seçili grup listeden düşmesin.
            var riskGruplari = tumu.Select(x => x.RiskGrubu).Where(x => x.Length > 0).Distinct()
                .OrderBy(x => x, StringComparer.Create(Tr, true)).ToList();
            var temsilciler = carilar.Values.Where(c => c.TemsilciId > 0).GroupBy(c => c.TemsilciId)
                .Select(g => new { id = g.Key, ad = g.First().Temsilci }).OrderBy(x => x.ad, StringComparer.Create(Tr, true)).ToList();
            var tanimsizSayisi = tumu.Count(x => x.Limit is null && (Math.Abs(x.toplam) >= 0.005m || x.SevkBlokesi));

            // Listeye giren: riski olan, limiti tanımlı ya da blokeli müşteri.
            var musteriler = tumu
                .Where(x => Math.Abs(x.toplam) >= 0.005m || x.Limit is not null || x.SevkBlokesi)
                .Where(x => grupSecim.Length == 0 || string.Equals(x.RiskGrubu, grupSecim, StringComparison.CurrentCultureIgnoreCase))
                .Where(x => !tanimsizGizle || x.Limit is not null)
                .OrderByDescending(x => x.toplam).ThenBy(x => x.Ad, StringComparer.Create(Tr, true))
                .ToList();

            // ------------------------------------------------------------- özet --
            var toplamRisk = musteriler.Sum(x => x.toplam);
            var bakiye = musteriler.Sum(x => x.Bakiye);
            var vadesiGecen = musteriler.Sum(x => x.vadesiGecen);
            var pozitif = musteriler.Where(x => x.toplam > 0).Sum(x => x.toplam);
            var ilk10 = musteriler.Where(x => x.toplam > 0).Take(10).Sum(x => x.toplam);
            var asanlar = musteriler.Where(x => x.durum == "asim").ToList();
            var ozet = new
            {
                toplamRisk, musteri = musteriler.Count, acikBakiye = bakiye, vadesiGecen,
                vadesiGecenYuzde = bakiye > 0 ? Math.Round(vadesiGecen * 100 / bakiye, 1) : 0,
                vadesiGecenMusteri = musteriler.Count(x => x.vadesiGecen > 0.005m),
                cek = cekDahil ? musteriler.Sum(x => x.Cek) : 0, cekAdet = cekDahil ? musteriler.Sum(x => x.CekAdet) : 0,
                irsaliye = musteriler.Sum(x => x.Irsaliye), siparis = siparisDahil ? musteriler.Sum(x => x.Siparis) : 0,
                limitAsan = asanlar.Count, asimTutar = asanlar.Sum(x => x.asim),
                yaklasan = musteriler.Count(x => x.durum == "yaklasiyor"),
                ilk10Pay = pozitif > 0 ? Math.Round(ilk10 * 100 / pozitif, 1) : 0,
                limitTanimli = musteriler.Count(x => x.Limit is not null), limitTanimsiz = tanimsizSayisi,
                blokeli = musteriler.Count(x => x.SevkBlokesi),
                oneri = musteriler.Count(x => x.oneri is { Kod: "blokele" or "kaldir" }),
                kurYok = musteriler.Count(x => x.KurYok || x.durum == "kurYok"),
                cekRiskli = 0,
            };

            // ---------------------------------------------------------- çek riski --
            var listeIdler = musteriler.Select(x => x.id).ToArray();
            var adlar = musteriler.ToDictionary(x => x.id, x => x.Ad);
            var kesideciKs = (await b.ListeAsync(KesideciKarsiliksizSorgusu, null, [tumSubeler],
                    o => (ad: o.GetString(0), adet: o.GetInt32(1), yil: o.IsDBNull(2) ? (int?)null : o.GetInt32(2)), iptal))
                .GroupBy(x => Anahtar(x.ad)).ToDictionary(g => g.Key, g => (adet: g.Sum(x => x.adet), yil: g.Max(x => x.yil)));
            // Çek bileşeni kapalıysa liste de boş (sorgu aynı kalır, kimlik kümesi boşalır).
            var cekIdler = cekDahil ? listeIdler : Array.Empty<int>();
            var cekRiski = await b.ListeAsync(CekSorgusu, null, [cekIdler, bugun, subeler], o =>
            {
                var tarafId = o.GetInt32(0);
                var cari = adlar.GetValueOrDefault(tarafId, "");
                var kesideci = o.GetString(1).Length > 0 ? o.GetString(1) : cari;
                var ucuncu = o.GetString(1).Length > 0 && Anahtar(o.GetString(1)) != Anahtar(cari);
                var ks = kesideciKs.TryGetValue(Anahtar(kesideci), out var k) ? k : (adet: 0, yil: (int?)null);
                var yedi = o.GetDecimal(7);
                var uyarilar = new List<string>();
                if (ks.adet > 0) uyarilar.Add($"{ks.adet} karşılıksız" + (ks.yil is { } y ? $" (son: {y})" : ""));
                if (ucuncu) uyarilar.Add("müşteri çeki değil — ciro (3. şahıs)");
                if (yedi > 0.005m) uyarilar.Add($"vadesi 7 gün içinde: {yedi.ToString("N2", Tr)}");
                return new
                {
                    tarafId, cari, kesideci, ucuncuKisi = ucuncu, banka = o.GetString(2), adet = o.GetInt32(3), tutar = o.GetDecimal(4),
                    ilkVade = o.GetDateTime(5), sonVade = o.GetDateTime(6), yediGun = yedi,
                    karsiliksiz = ks.adet, karsiliksizYil = ks.yil, uyarilar, riskli = uyarilar.Count > 0,
                };
            }, iptal);
            ozet = ozet with { cekRiskli = cekRiski.Count(x => x.riskli) };

            // ---------------------------------------------------------- listeler --
            var limitAsimi = musteriler.Where(x => x.durum is "asim" or "yaklasiyor")
                .OrderBy(x => x.durum == "asim" ? 0 : 1).ThenByDescending(x => x.kullanim ?? 0)
                .Select(x => new
                {
                    x.id, x.Ad, x.toplam, x.Limit, x.LimitDoviz, x.LimitTl, x.asim, x.kullanim, x.Teminat, x.teminatOzet,
                    x.teminatIcinde, x.sonLimitAn, x.sonLimitKim, x.durum,
                    durumMetni = x.durum == "yaklasiyor" ? "yaklaşıyor"
                        : x.teminatIcinde ? "aşım · teminat içinde"
                        : x.vadesiGecen > 0.005m ? "aşım · vadesi geçen var" : "aşım",
                }).ToList();

            var yaslandirma = musteriler.Where(x => x.vadesiGecen > 0.005m).OrderByDescending(x => x.vadesiGecen)
                .Select(x => new { x.id, x.Ad, x.yas, ortGecikme = x.odeme?.OrtGecikme, x.vadesiGecen }).ToList();
            var yasToplam = new
            {
                gelmemis = yaslandirma.Sum(x => x.yas.Gelmemis), d30 = yaslandirma.Sum(x => x.yas.D30), d60 = yaslandirma.Sum(x => x.yas.D60),
                d90 = yaslandirma.Sum(x => x.yas.D90), d90p = yaslandirma.Sum(x => x.yas.D90p),
                ortGecikme = Agirlikli(yaslandirma.Where(x => x.ortGecikme is not null).Select(x => (x.vadesiGecen, x.ortGecikme!.Value))),
            };

            var odemeDavranisi = musteriler.Where(x => x.odeme is not null)
                .Select(x => new { x.id, x.Ad, x.odeme, x.karsiliksiz12, x.karsiliksiz, x.skor, x.skorPuan, x.kullanim })
                .OrderBy(x => x.skorPuan ?? 101).ThenBy(x => x.Ad, StringComparer.Create(Tr, true)).ToList();

            var kum = 0m;
            var yogunlasma = musteriler.Where(x => x.toplam > 0).Take(10).Select((x, i) =>
            {
                var pay = pozitif > 0 ? Math.Round(x.toplam * 100 / pozitif, 1) : 0;
                kum += pay;
                return new { sira = i + 1, x.id, x.Ad, x.toplam, pay, kumulatif = Math.Round(kum, 1), yuksek = pay >= YogunlasmaEsik };
            }).ToList();

            var oneriSira = new Dictionary<string, int> { ["blokele"] = 0, ["kalsin"] = 1, ["uyar"] = 2, ["kaldir"] = 3 };
            var blokeOnerisi = musteriler.Where(x => x.oneri is not null)
                .OrderBy(x => oneriSira.GetValueOrDefault(x.oneri!.Kod, 9)).ThenByDescending(x => x.toplam)
                .Select(x => new
                {
                    x.id, x.Ad, nedenler = x.oneri!.nedenler, x.toplam, x.asim, x.SevkBlokesi, x.BlokeNeden,
                    oneri = x.oneri.Kod, oneriAd = x.oneri.Ad,
                }).ToList();

            var gruplar = musteriler.Where(x => x.RiskGrubu.Length > 0).GroupBy(x => x.RiskGrubu, StringComparer.CurrentCultureIgnoreCase)
                .Select(g => new
                {
                    ad = g.First().RiskGrubu, musteri = g.Count(), toplam = g.Sum(x => x.toplam),
                    limitTl = g.Any(x => x.LimitTl is not null) ? g.Sum(x => x.LimitTl ?? 0) : (decimal?)null,
                    asan = g.Count(x => x.durum == "asim"),
                }).OrderByDescending(x => x.toplam).ToList();

            return Results.Ok(new
            {
                tarih = bugun, sube = sube ?? 0, temsilci = temsilci ?? 0, grup = grupSecim, cekDahil, siparisDahil, tanimsizGizle,
                davranis = MusteriRiskKurali.EngelKipi(await AyarDeposu.MetinAsync(b, null, "satis.limit_davranis", "", iptal)) ? "engelle" : "uyar",
                ozet, musteriler, limitAsimi, yaslandirma, yasToplam, cekRiski, odemeDavranisi, yogunlasma, blokeOnerisi, gruplar,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { s.Id, s.Ad }).ToList(), temsilciler, riskGruplari,
                },
                yetkiler = new { limit = baglam.Yetkiler.AksiyonVar(AksiyonLimit) && baglam.SubeYazma },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ============================================== tek müşteri (kart / modal) ===
        // Cari kartı "Satış & Risk" sekmesi ve icmalin limit / teminat pencereleri. Risk satış belgesi kontrolüyle
        //   AYNI hesap (şube süzgeçsiz - limit müşterinin toplamına konur). Yetki: cari kartı ya da bu icmal.
        uc.MapGet("/taraf/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("cari", Islem.Gor) && !baglam.Yetkiler.Var(Kod, Islem.Gor)) throw GentegreHatasi.Yasak();
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu özet portalda kullanılamaz.");
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(id)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            await using var b = await veri.AcAsync(iptal);
            var ad = await b.TekDegerAsync<string>("""
                select coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), '') from public.taraf t
                 where t.id = @p0 and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1)
                """, null, [id], iptal) ?? throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
            var r = (await MusteriRiskDeposu.OkuAsync(b, null, [id], bugun, [], iptal)).First();
            var toplam = r.Toplam();
            var (kullanim, asim, durum) = LimitDurumu(r, toplam);
            var tem = await TeminatlarAsync(b, null, [id], bugun, iptal);
            return Results.Ok(new
            {
                tarafId = id, ad, r.Bakiye, r.Cek, r.CekAdet, r.CekIlkVade, r.Irsaliye, r.IrsaliyeAdet, r.Siparis, r.SiparisAdet, toplam,
                r.Limit, r.LimitDoviz, r.LimitTl, kullanim, asim, durum, r.Teminat, r.TeminatAdet, teminatOzet = TeminatOzeti(tem),
                r.SevkBlokesi, r.BlokeNeden, r.BlokeKim, r.BlokeAn, r.RiskGrubu, r.KurYok, r.Surum,
                teminatlar = tem.Select(TeminatGorunumu).ToList(),
                davranis = MusteriRiskKurali.EngelKipi(await AyarDeposu.MetinAsync(b, null, "satis.limit_davranis", "", iptal)) ? "engelle" : "uyar",
                yetkiler = new { limit = baglam.Yetkiler.AksiyonVar(AksiyonLimit) && baglam.SubeYazma },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ============================================================ LİMİT GÜNCELLE ===
        // Limit (null = tanımsız), dövizi ve isteğe bağlı risk grubu. Neden zorunlu; alan bazlı log (hiçbir alan
        //   değişmediyse yazım da log da yok). surum (taraf xmin) verilirse çakışmada 409 + güncel değerler.
        uc.MapPost("/limit", async (LimitIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonLimit);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var neden = NedenIste(istek.Neden);
            if (istek.Limit is < 0 or > 999_999_999_999m)
                throw GentegreHatasi.Dogrulama("Risk limiti geçersiz.", new AlanHatasi("limit", "0 ya da daha büyük olmalı (boş = tanımsız)."));
            var doviz = DovizIste(istek.Doviz, "doviz");
            var riskGrubu = istek.RiskGrubu?.Trim();
            if (riskGrubu is { Length: > 60 })
                throw GentegreHatasi.Dogrulama("Risk grubu en fazla 60 karakter.", new AlanHatasi("riskGrubu", "En fazla 60 karakter."));

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var t = await TarafKilitleAsync(b, tx, baglam, istek.TarafId, iptal);
            if (!string.IsNullOrEmpty(istek.Surum) && istek.Surum != t.Surum)
                throw GentegreHatasi.Cakisma(new { riskLimit = t.Limit, riskLimitDoviz = t.LimitDoviz, riskGrubu = t.RiskGrubu, surum = t.Surum },
                                             ["riskLimit", "riskLimitDoviz", "riskGrubu"]);
            var limit = istek.Limit is { } l ? Math.Round(l, 2) : (decimal?)null;
            var yeniGrup = riskGrubu ?? t.RiskGrubu;
            var fark = LogDeposu.Fark(
                new Dictionary<string, object?> { ["riskLimit"] = Sayi(t.Limit), ["riskLimitDoviz"] = t.LimitDoviz, ["riskGrubu"] = t.RiskGrubu },
                new Dictionary<string, object?> { ["riskLimit"] = Sayi(limit), ["riskLimitDoviz"] = doviz, ["riskGrubu"] = yeniGrup });
            if (fark is null)
            {
                await tx.RollbackAsync(iptal);
                return Results.Ok(new { degisti = false, surum = t.Surum, izlemeNo = baglam.IzlemeNo });
            }
            var surum = await b.TekDegerAsync<string>("""
                update public.taraf set risk_limit = @p1::numeric, risk_limit_doviz = @p2, risk_grubu = @p3, degistiren = @p4
                 where id = @p0
                returning xmin::text
                """, tx, [t.Id, limit, doviz, yeniGrup, baglam.KullaniciId], iptal);
            fark["neden"] = neden;
            fark["kaynak"] = "musteri-risk-icmali";
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloCari, t.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                               tarafId: t.Id, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { degisti = true, surum, izlemeNo = baglam.IzlemeNo });
        });

        // ===================================================== SEVK BLOKESİ KOY / KALDIR ===
        uc.MapPost("/bloke", async (BlokeIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonLimit);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var neden = NedenIste(istek.Neden);

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var t = await TarafKilitleAsync(b, tx, baglam, istek.TarafId, iptal);
            if (t.SevkBlokesi == istek.Bloke)
                throw GentegreHatasi.IsKurali(istek.Bloke ? "Müşteri zaten sevk blokesinde." : "Müşterinin sevk blokesi yok.");
            var yeniNeden = istek.Bloke ? neden : "";
            var surum = await b.TekDegerAsync<string>("""
                update public.taraf set sevk_blokesi = @p1, sevk_blokesi_neden = @p2, sevk_blokesi_kim = @p3,
                                        sevk_blokesi_an = now(), degistiren = @p3
                 where id = @p0
                returning xmin::text
                """, tx, [t.Id, (short)(istek.Bloke ? 1 : 0), yeniNeden, baglam.KullaniciId], iptal);
            var fark = LogDeposu.Fark(
                new Dictionary<string, object?> { ["sevkBlokesi"] = t.SevkBlokesi ? 1 : 0, ["sevkBlokesiNeden"] = t.BlokeNeden },
                new Dictionary<string, object?> { ["sevkBlokesi"] = istek.Bloke ? 1 : 0, ["sevkBlokesiNeden"] = yeniNeden })
                ?? new Dictionary<string, string>();
            fark["neden"] = neden;
            fark["aksiyon"] = istek.Bloke ? "sevk-blokesi-koy" : "sevk-blokesi-kaldir";
            fark["kaynak"] = "musteri-risk-icmali";
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloCari, t.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                               tarafId: t.Id, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { sevkBlokesi = istek.Bloke, surum, izlemeNo = baglam.IzlemeNo });
        });

        // ================================================================ TEMİNAT ===
        uc.MapGet("/teminat", async (int tarafId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("cari", Islem.Gor) && !baglam.Yetkiler.Var(Kod, Islem.Gor)) throw GentegreHatasi.Yasak();
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(tarafId)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
            await using var b = await veri.AcAsync(iptal);
            var tem = await TeminatlarAsync(b, null, [tarafId], Saat.BugunDilim(baglam.ZamanDilimi), iptal);
            return Results.Ok(new
            {
                teminatlar = tem.Select(TeminatGorunumu).ToList(),
                yetkiler = new { limit = baglam.Yetkiler.AksiyonVar(AksiyonLimit) && baglam.SubeYazma },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        uc.MapPost("/teminat", async (TeminatIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                        HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonLimit);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var (doviz, aciklama) = TeminatDogrula(istek);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var t = await TarafKilitleAsync(b, tx, baglam, istek.TarafId, iptal);
            var yeniId = await b.TekDegerAsync<long>("""
                insert into public.taraf_teminat (taraf_id, tur, tutar, doviz, baslangic, bitis, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4::date, @p5::date, @p6, @p7)
                returning id
                """, tx, [t.Id, istek.Tur, Math.Round(istek.Tutar, 2), doviz, istek.Baslangic?.Date, istek.Bitis?.Date, aciklama,
                          baglam.KullaniciId], iptal);
            await log.YazAsync(b, tx, LogIslemi.Ekle, LogTabloTeminat, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                TeminatLogu(t.Id, istek.Tur, Math.Round(istek.Tutar, 2), doviz, istek.Baslangic, istek.Bitis, aciklama),
                ustTabloId: LogTabloCari, ustKayitId: t.Id, tarafId: t.Id, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id = yeniId, izlemeNo = baglam.IzlemeNo });
        });

        uc.MapPut("/teminat/{id:long}", async (long id, TeminatIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonLimit);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            var (doviz, aciklama) = TeminatDogrula(istek);
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var e = await TeminatKilitleAsync(b, tx, baglam, id, iptal);
            if (istek.TarafId > 0 && istek.TarafId != e.TarafId)
                throw GentegreHatasi.Dogrulama("Teminatın carisi değiştirilemez.", new AlanHatasi("tarafId", "Değiştirilemez."));
            if (!string.IsNullOrEmpty(istek.Surum) && istek.Surum != e.Surum)
                throw GentegreHatasi.Cakisma(TeminatGorunumu(e), ["tur", "tutar", "doviz", "baslangic", "bitis", "aciklama"]);
            var tutar = Math.Round(istek.Tutar, 2);
            var fark = LogDeposu.Fark(TeminatLogu(e.TarafId, e.Tur, e.Tutar, e.Doviz, e.Baslangic, e.Bitis, e.Aciklama).ToDictionary(x => x.Key, x => (object?)x.Value),
                                      TeminatLogu(e.TarafId, istek.Tur, tutar, doviz, istek.Baslangic, istek.Bitis, aciklama).ToDictionary(x => x.Key, x => (object?)x.Value));
            if (fark is null)
            {
                await tx.RollbackAsync(iptal);
                return Results.Ok(new { degisti = false, surum = e.Surum, izlemeNo = baglam.IzlemeNo });
            }
            var surum = await b.TekDegerAsync<string>("""
                update public.taraf_teminat
                   set tur = @p1, tutar = @p2, doviz = @p3, baslangic = @p4::date, bitis = @p5::date, aciklama = @p6,
                       degistiren = @p7, degistirme_tarihi = now()
                 where id = @p0
                returning xmin::text
                """, tx, [id, istek.Tur, tutar, doviz, istek.Baslangic?.Date, istek.Bitis?.Date, aciklama, baglam.KullaniciId], iptal);
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloTeminat, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                               ustTabloId: LogTabloCari, ustKayitId: e.TarafId, tarafId: e.TarafId, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { degisti = true, surum, izlemeNo = baglam.IzlemeNo });
        });

        // SİLME: log DELETE'ten ÖNCE, satırın tam hâliyle (proje kuralı - "Geri Al").
        uc.MapDelete("/teminat/{id:long}", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonLimit);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var e = await TeminatKilitleAsync(b, tx, baglam, id, iptal);
            var tam = TeminatLogu(e.TarafId, e.Tur, e.Tutar, e.Doviz, e.Baslangic, e.Bitis, e.Aciklama);
            tam["id"] = e.Id.ToString(CultureInfo.InvariantCulture);
            tam["ekleyen"] = e.Ekleyen;
            tam["eklemeTarihi"] = LogDeposu.Metin(e.EklemeTarihi);
            tam["kaynak"] = "musteri-risk-icmali";
            await log.YazAsync(b, tx, LogIslemi.Sil, LogTabloTeminat, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip, tam,
                               ustTabloId: LogTabloCari, ustKayitId: e.TarafId, tarafId: e.TarafId, iptal: iptal);
            await b.CalistirAsync("delete from public.taraf_teminat where id = @p0", tx, [id], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });
    }

    // ============================================================= yardımcılar ===

    private static string Anahtar(string ad) => (ad ?? "").Trim().ToUpper(Tr);

    private static decimal? Agirlikli(IEnumerable<(decimal agirlik, decimal deger)> l)
    {
        var liste = l.ToList();
        var t = liste.Sum(x => x.agirlik);
        return t > 0 ? Math.Round(liste.Sum(x => x.agirlik * x.deger) / t, 1) : null;
    }

    /// <summary>Log ve karşılaştırma için sayı metni (150000.00 ile 150000 aynı değerdir).</summary>
    private static string Sayi(decimal? d) => d is { } v ? v.ToString("0.##", CultureInfo.InvariantCulture) : "";

    private static string NedenIste(string? neden)
    {
        var n = (neden ?? "").Trim();
        if (n.Length < 3) throw GentegreHatasi.Dogrulama("Neden yazılmalı.", new AlanHatasi("neden", "En az 3 karakter."));
        return n.Length > 300 ? n[..300] : n;
    }

    private static string DovizIste(string? doviz, string alan)
    {
        var d = string.IsNullOrWhiteSpace(doviz) ? "TL" : doviz.Trim().ToUpperInvariant();
        if (d == "TRY") d = "TL";
        if (!Dovizler.Contains(d)) throw GentegreHatasi.Dogrulama("Para birimi geçersiz.", new AlanHatasi(alan, "Tanımsız para birimi."));
        return d;
    }

    private static (string doviz, string aciklama) TeminatDogrula(TeminatIstegi istek)
    {
        if (istek.Tur is not (1 or 2 or 3 or 4 or 9))
            throw GentegreHatasi.Dogrulama("Teminat türü geçersiz.", new AlanHatasi("tur", "Mektup / ipotek / çek-senet / nakit / diğer."));
        if (istek.Tutar <= 0 || istek.Tutar > 999_999_999_999m)
            throw GentegreHatasi.Dogrulama("Teminat tutarı sıfırdan büyük olmalı.", new AlanHatasi("tutar", "Sıfırdan büyük olmalı."));
        if (istek.Baslangic is { } bs && istek.Bitis is { } bt && bt.Date < bs.Date)
            throw GentegreHatasi.Dogrulama("Bitiş tarihi başlangıçtan önce olamaz.", new AlanHatasi("bitis", "Başlangıçtan önce olamaz."));
        var aciklama = (istek.Aciklama ?? "").Trim();
        if (aciklama.Length > 300)
            throw GentegreHatasi.Dogrulama("Açıklama en fazla 300 karakter.", new AlanHatasi("aciklama", "En fazla 300 karakter."));
        return (DovizIste(istek.Doviz, "doviz"), aciklama);
    }

    private static Dictionary<string, string> TeminatLogu(int tarafId, int tur, decimal tutar, string doviz, DateTime? bas, DateTime? bit,
        string aciklama) => new(StringComparer.Ordinal)
    {
        ["tarafId"] = tarafId.ToString(CultureInfo.InvariantCulture),
        ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
        ["tutar"] = Sayi(tutar),
        ["doviz"] = doviz,
        ["baslangic"] = bas?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) ?? "",
        ["bitis"] = bit?.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) ?? "",
        ["aciklama"] = aciklama,
    };

    private static object TeminatGorunumu(Teminat t) => new
    {
        t.Id, t.Tur, t.TurAdi, t.Tutar, t.Doviz, t.Baslangic, t.Bitis, t.Aciklama, t.Aktif, t.Ekleyen, t.EklemeTarihi, t.Surum,
    };

    private sealed record TarafSatiri(int Id, decimal? Limit, string LimitDoviz, string RiskGrubu, bool SevkBlokesi, string BlokeNeden,
        string Surum);

    /// <summary>Carinin satırını kilitler (for update) ve kapsamı denetler: kapsam dışı = 404 (var olmayanla aynı);
    ///   risk limiti / teminat / bloke yalnız müşteri carisine.</summary>
    private static async Task<TarafSatiri> TarafKilitleAsync(NpgsqlConnection b, NpgsqlTransaction tx, IstekBaglami baglam, int tarafId,
        CancellationToken iptal)
    {
        if (tarafId <= 0 || (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(tarafId)))
            throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
        var t = await b.TekAsync("""
            select t.id, t.musteri, t.risk_limit, coalesce(nullif(btrim(t.risk_limit_doviz), ''), 'TL'), coalesce(t.risk_grubu, ''),
                   coalesce(t.sevk_blokesi, 0), coalesce(t.sevk_blokesi_neden, ''), t.xmin::text
              from public.taraf t where t.id = @p0 and (t.musteri = 1 or t.tedarikci = 1 or t.aday = 1)
               for update
            """, tx, [tarafId], o => new
            {
                musteri = o.GetInt16(1) == 1,
                satir = new TarafSatiri(o.GetInt32(0), o.IsDBNull(2) ? null : o.GetDecimal(2), o.GetString(3), o.GetString(4),
                                        o.GetInt16(5) == 1, o.GetString(6), o.GetString(7)),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");
        if (!t.musteri) throw GentegreHatasi.IsKurali("Risk limiti, teminat ve sevk blokesi yalnız müşteri carisinde tutulur.");
        return t.satir;
    }

    private static async Task<Teminat> TeminatKilitleAsync(NpgsqlConnection b, NpgsqlTransaction tx, IstekBaglami baglam, long id,
        CancellationToken iptal)
    {
        var tarafId = await b.TekDegerAsync<int?>("select taraf_id from public.taraf_teminat where id = @p0 for update", tx, [id], iptal)
                      ?? throw GentegreHatasi.Bulunamadi("Teminat bulunamadı.");
        if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(tarafId)) throw GentegreHatasi.Bulunamadi("Teminat bulunamadı.");
        var l = await TeminatlarAsync(b, tx, [tarafId], Saat.BugunDilim(baglam.ZamanDilimi), iptal);
        return l.FirstOrDefault(x => x.Id == id) ?? throw GentegreHatasi.Bulunamadi("Teminat bulunamadı.");
    }
}
