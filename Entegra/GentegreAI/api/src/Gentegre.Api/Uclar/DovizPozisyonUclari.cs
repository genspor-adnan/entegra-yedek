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
/// DÖVİZ POZİSYONU / KUR FARKI İCMALİ `/api/doviz-pozisyon` (1186 - mockup Ekranlar/İcmal/doviz_pozisyon_icmali.html,
/// kararlar 25.10.2026). "Dövizde ne kadar açığız, kur artarsa ne kaybederiz, bu ay kur farkından ne kazandık,
/// kime kur farkı faturası kesmeliyiz?"
///
/// <para><b>Pozisyon</b> döviz bazında: döviz kasa + döviz banka (hesap ekstresi / v_hesap_bakiye ile AYNI küme:
/// v_mali_hareket_ek, hesap_ekstre 1, islem_durum 2) + dövizli cari alacak − dövizli cari borç (Cari Ekstre /
/// Cari İcmali kümesi: v_cari_ekstre, bakiye_dahil 1, hareketin KENDİ dövizi) + portföydeki döviz çek (Müşteri Risk /
/// Çek-Senet kuralı: alınan, durum 10/30/40, vadesi gelmemiş) − kredi / kredi kartı hesapları. Açık sipariş
/// (v_belge_acik_satir, satış 19 varlık / alış 9 yükümlülük) şeritte isteğe bağlı, varsayılan KAPALI.</para>
///
/// <para><b>Kur farkı</b> Cari İcmali'nin FIFO kapama kuralıyla (<see cref="CariIcmalUclari.Kume"/>: aynı cari +
/// döviz içinde borç ve alacak kalemleri vade, id sırasıyla birbirini kapatır). Kapanan her parça için
/// kur farkı = döviz tutar × (alacak kaleminin kuru − borç kaleminin kuru); kalemin kuru = TL karşılığı / döviz tutarı.
/// Kapanış günü = iki kalemin geç olanı; dönem içinde kapananlar "gerçekleşen". Açık kalan kalemlerin kayıtlı TL'si
/// ile bugünkü kurdaki TL'si arasındaki fark "değerleme" - yalnız bilgi, kayda geçmez.</para>
///
/// <para><b>Kur farkı faturası</b> OTOMATİK KESİLMEZ (karar): satış faturasını kapatan tahsilatta lehte fark öneri olarak
/// listelenir; kullanıcı `finans.kur_farki` aksiyonuyla "kesildi" (kesilen satış faturası) ya da "gerek yok" işaretler
/// (kur_farki_takip, islem_log). Aleyhte fark yalnız bilgi (alacak dekontu önerisi).</para>
///
/// <para><b>Kur</b> public.doviz_kur (fn_doviz_kur_getir: o güne kadarki son kur); değerleme türü Genel Ayarlar
/// `finans.degerleme_kuru` (ALIS | EFEKTIF | SATIS, boş = döviz alış), şeritten değiştirilebilir. Kuru o günden eski
/// olan döviz rozetle işaretlenir. Şube süzgeci kasa / banka / çek / siparişe (kullanıcının şubeleri), cari kayıt
/// kapsamı (baglam.Kapsam) cari kümesine uygulanır. Rakamlar sunucuda; ekran toplamaz.</para>
/// </summary>
public static class DovizPozisyonUclari
{
    /// <summary>Ekran kodu (1186) - hakları finans.cari_icmali'nden.</summary>
    private const string Kod = "finans.doviz_pozisyon";

    /// <summary>Kur farkı satırını "kesildi / gerek yok" işaretleme aksiyonu (1186).</summary>
    private const string AksiyonKurFarki = "finans.kur_farki";

    /// <summary>islem_log.tablo_id - kur_farki_takip (yeni numara, katalog / uç sabitlerinde boş).</summary>
    private const int LogTabloKurFarki = 1761;

    private static readonly int[] SatisTurleri = [15, 16, 17];
    private static readonly int[] AlisTurleri = [11, 12, 13];
    private static readonly decimal[] Senaryolar = [-5m, 5m, 10m, 20m];

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public sealed record KurFarkiIstegi(int TarafId, int BelgeId, string? KapamaAnahtar, string? Doviz, decimal TutarDoviz,
        decimal FaturaKuru, decimal KapamaKuru, decimal KurFarki, short Durum, string? KesilenBelgeNo, string? Aciklama);

    // ================================================================= kur seçimi ===

    /// <summary>Değerleme kuru türü → fn_doviz_kur_getir yönü (1 satış · 2 alış · 4 efektif alış).</summary>
    private static (string kod, short yon, string ad) KurTuru(string? s) => (s ?? "").Trim().ToUpperInvariant() switch
    {
        "SATIS" or "SATIŞ" => ("satis", 1, "TCMB döviz satış"),
        "EFEKTIF" or "EFEKTİF" => ("efektif", 4, "TCMB efektif alış"),
        _ => ("alis", 2, "TCMB döviz alış"),
    };

    // ================================================================ sorgular ===

    /// <summary>Dövizli cari hareketleri - Cari İcmali kümesi (<see cref="CariIcmalUclari.Kume"/> ile aynı seçim ve vade).
    ///   @p0 bitiş (dahil) · @p1 kayıt kapsamı.</summary>
    private const string CariHareketSorgusu = """
        with y as materialized (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel)
        select e.id, e.taraf_id, e.tur, e.islem_tarihi::date,
               coalesce(e.plan_tarihi, e.islem_tarihi + make_interval(days => coalesce(tm.vade_gun, 0)))::date as vade,
               public.fn_doviz_iso(coalesce(nullif(btrim(e.doviz_cinsi), ''), 'TL'))::varchar(6) as para,
               coalesce(e.borc, 0), coalesce(e.alacak, 0), coalesce(e.yerel_borc, 0), coalesce(e.yerel_alacak, 0),
               coalesce(e.belge_id, 0), coalesce(e.kasa_islem_id, 0), coalesce(nullif(e.belge_no, ''), e.islem_no, ''),
               coalesce(e.tur_adi, ''), coalesce(e.doviz_kuru, 0)
          from public.v_cari_ekstre e
          join public.taraf t on t.id = e.taraf_id
          left join public.taraf_musteri tm on tm.id = t.id
          cross join y
         where e.bakiye_dahil = 1 and e.islem_tarihi < (@p0::date + 1)
           and (t.musteri = 1 or t.tedarikci = 1) and t.personel = 0
           and (cardinality(@p1::int[]) = 0 or t.id = any(@p1::int[]))
           and public.fn_doviz_iso(coalesce(nullif(btrim(e.doviz_cinsi), ''), 'TL')) <> y.yerel
        """;

    /// <summary>Döviz kasa / banka / kredi bakiyeleri - v_hesap_bakiye kümesi, döviz kırılımlı. @p0 tarih · @p1 şubeler.</summary>
    private const string HesapSorgusu = """
        with y as materialized (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel)
        select x.tur, x.para, sum(x.b), sum(x.yb), count(distinct x.hesap_id)::int
          from (select upper(btrim(h.tur)) as tur, h.id as hesap_id,
                       public.fn_doviz_iso(coalesce(nullif(btrim(m.doviz_cinsi), ''), nullif(btrim(h.doviz_cinsi), ''), 'TL'))::varchar(6) as para,
                       m.borc - m.alacak as b, m.yerel_borc - m.yerel_alacak as yb
                  from public.hesap h
                  join public.v_mali_hareket_ek m on m.hesap_id = h.id and m.hesap_ekstre = 1 and m.islem_durum = 2
                 where m.islem_tarihi < (@p0::date + 1)
                   and (h.sube_id is null or h.sube_id = any(@p1::int[]))) x
          cross join y
         where x.para <> y.yerel
         group by x.tur, x.para
        having abs(sum(x.b)) >= 0.005
        """;

    /// <summary>Portföydeki döviz çek / senet (alınan, durum 10/30/40, vadesi gelmemiş). @p0 tarih · @p1 şubeler.</summary>
    private const string CekSorgusu = """
        with y as materialized (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel)
        select public.fn_doviz_iso(coalesce(nullif(btrim(c.doviz_cinsi), ''), 'TL'))::varchar(6) as para,
               sum(c.tutar), sum(coalesce(nullif(c.yerel_tutar, 0), c.tutar * nullif(c.doviz_kuru, 0), 0)), count(*)::int
          from public.cek_senet c cross join y
         where c.yon = 1 and c.durum in (10, 30, 40) and c.vade >= @p0::date
           and (cardinality(@p1::int[]) = 0 or c.sube_id = any(@p1::int[]))
           and public.fn_doviz_iso(coalesce(nullif(btrim(c.doviz_cinsi), ''), 'TL')) <> y.yerel
         group by 1
        """;

    /// <summary>Açık dövizli sipariş kalanı (Açık Satır Listesi kuralı). 19 satış (varlık) · 9 alış (yükümlülük).
    ///   @p0 tarih · @p1 şubeler.</summary>
    private const string SiparisSorgusu = """
        with y as materialized (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel)
        select a.belge_tur::int, public.fn_doviz_iso(coalesce(nullif(btrim(a.belge_dovizi), ''), 'TL'))::varchar(6) as para,
               sum(coalesce(a.tutar_kalan, 0)), count(distinct a.belge_id)::int
          from public.v_belge_acik_satir a cross join y
         where a.belge_tur in (9, 19) and a.belge_tarihi < (@p0::date + 1)
           and (a.sube_id is null or a.sube_id = any(@p1::int[]))
           and public.fn_doviz_iso(coalesce(nullif(btrim(a.belge_dovizi), ''), 'TL')) <> y.yerel
         group by 1, 2
        having abs(sum(coalesce(a.tutar_kalan, 0))) >= 0.005
        """;

    /// <summary>Döviz kurları: istenen gün için seçili türde son kur ve o kurun günü. @p0 dövizler · @p1 tarih · @p2 yön.</summary>
    private const string KurSorgusu = """
        select d.para, public.fn_doviz_kur_getir(d.para, @p1::date, @p2::smallint),
               (select max(k.tarih) from public.doviz_kur k where k.doviz_cinsi = d.para and k.tarih <= @p1::date)
          from unnest(@p0::text[]) as d(para)
        """;

    /// <summary>Kur geçmişi: son 10 kur günü + önceki ay sonu (değerleme kuru). @p0 dövizler · @p1 tarih · @p2 yön.</summary>
    private const string KurGecmisiSorgusu = """
        with g as (
            select distinct k.tarih from public.doviz_kur k
             where k.doviz_cinsi = any(@p0::text[]) and k.tarih <= @p1::date
             order by k.tarih desc limit 10
        ),
        ay as (select (date_trunc('month', @p1::date) - interval '1 day')::date as tarih)
        select x.tarih, d.para, public.fn_doviz_kur_getir(d.para, x.tarih, @p2::smallint), x.ay_sonu
          from (select tarih, false as ay_sonu from g
                union
                select tarih, true from ay where not exists (select 1 from g where g.tarih = ay.tarih)) x
          cross join unnest(@p0::text[]) as d(para)
         order by x.tarih desc, d.para
        """;

    // ================================================================= FIFO ===

    private sealed record Kalem(int Id, int TarafId, int Tur, DateTime Tarih, DateTime Vade, string Para, decimal Doviz, decimal Yerel,
        int BelgeId, int KasaIslemId, string No, string TurAdi, decimal SatirKuru)
    {
        /// <summary>Kalemin kendi kuru: TL karşılığı / döviz tutarı (yoksa satırın kuru).</summary>
        public decimal Kur => Doviz > 0 ? Yerel / Doviz : SatirKuru;
        public string Anahtar => KasaIslemId > 0 ? $"k{KasaIslemId}" : BelgeId > 0 ? $"b{BelgeId}" : $"e{Id}";
        /// <summary>Borç kalemi mi (cari bize borçlandı: satış faturası, ödememiz) - değilse alacak kalemi.</summary>
        public bool BorcMu { get; init; }
    }

    /// <summary>FIFO kapanan parça: borç kalemi (B) ile alacak kalemi (A) arasında `Tutar` döviz.</summary>
    private sealed record Parca(Kalem B, Kalem A, decimal Tutar)
    {
        public DateTime Kapanis => B.Tarih > A.Tarih ? B.Tarih : A.Tarih;
        /// <summary>Bizim lehimize TL: alacak kaleminin kuru − borç kaleminin kuru (müşteri: tahsil − fatura; tedarikçi: fatura − ödeme).</summary>
        public decimal Fark => Math.Round(Tutar * (A.Kur - B.Kur), 2);
    }

    /// <summary>Açık kalan kalem parçası (FIFO sonrası).</summary>
    private sealed record Acik(Kalem K, decimal Kalan, bool Borc);

    /// <summary>
    /// Cari İcmali FIFO kuralı (<see cref="CariIcmalUclari.Kume"/>): aynı cari + döviz içinde borç ve alacak kalemleri
    /// (vade, id) sırasıyla birbirini kapatır. Kapanan parçalar ve açık kalanlar döner.
    /// </summary>
    private static (List<Parca> parcalar, List<Acik> aciklar) Fifo(IEnumerable<Kalem> kalemler)
    {
        var parcalar = new List<Parca>();
        var aciklar = new List<Acik>();
        foreach (var g in kalemler.GroupBy(k => (k.TarafId, k.Para)))
        {
            var bl = g.Where(k => k.BorcMu && k.Doviz > 0.005m).OrderBy(k => k.Vade).ThenBy(k => k.Id).ToList();
            var al = g.Where(k => !k.BorcMu && k.Doviz > 0.005m).OrderBy(k => k.Vade).ThenBy(k => k.Id).ToList();
            int bi = 0, ai = 0;
            decimal bk = bl.Count > 0 ? bl[0].Doviz : 0, ak = al.Count > 0 ? al[0].Doviz : 0;
            while (bi < bl.Count && ai < al.Count)
            {
                var m = Math.Min(bk, ak);
                parcalar.Add(new Parca(bl[bi], al[ai], m));
                bk -= m; ak -= m;
                if (bk <= 0.005m && ++bi < bl.Count) bk = bl[bi].Doviz;
                if (ak <= 0.005m && ++ai < al.Count) ak = al[ai].Doviz;
            }
            for (var x = bi; x < bl.Count; x++) aciklar.Add(new Acik(bl[x], x == bi ? bk : bl[x].Doviz, true));
            for (var x = ai; x < al.Count; x++) aciklar.Add(new Acik(al[x], x == ai ? ak : al[x].Doviz, false));
        }
        return (parcalar, aciklar);
    }

    private static decimal R(decimal x) => Math.Round(x, 2);

    // =================================================================== uçlar ===

    public static void DovizPozisyonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var uc = yol.MapGroup("/api/doviz-pozisyon").WithTags("Döviz Pozisyonu / Kur Farkı İcmali").RequireAuthorization();

        // ===================================================================== GET ===
        uc.MapGet("/", async (DateTime? tarih, string? donem, string? kur, int? sube, int? siparis, int? cek,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var gun = (tarih ?? bugun).Date;
            if (gun > bugun) gun = bugun;
            if (gun.Year < 2000) throw GentegreHatasi.Dogrulama("Tarih geçersiz.");

            // Kur farkı dönemi: "yyyy-MM" (boş = tarihin ayı); bitiş = ay sonu ya da tarih.
            DateTime donemBas;
            if (string.IsNullOrWhiteSpace(donem)) donemBas = new DateTime(gun.Year, gun.Month, 1);
            else if (!DateTime.TryParseExact(donem.Trim() + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out donemBas))
                throw GentegreHatasi.Dogrulama("Dönem 'yyyy-AA' olmalı.");
            var donemBit = donemBas.AddMonths(1).AddDays(-1);
            if (donemBit > gun) donemBit = gun;
            if (donemBas > gun) throw GentegreHatasi.Dogrulama("Dönem tarihten sonra olamaz.");

            var tumSubeler = baglam.Subeler.Select(s => s.Id).ToArray();
            int[] subeler;
            if (sube is > 0)
            {
                if (!tumSubeler.Contains(sube.Value)) throw GentegreHatasi.Bulunamadi("Şube bulunamadı.");
                subeler = [sube.Value];
            }
            else subeler = tumSubeler;
            var siparisDahil = (siparis ?? 0) == 1;
            var cekDahil = (cek ?? 1) != 0;

            await using var b = await veri.AcAsync(iptal);
            var ayar = await AyarDeposu.MetinAsync(b, null, "finans.degerleme_kuru", "", iptal);
            var kt = KurTuru(string.IsNullOrWhiteSpace(kur) ? ayar : kur);
            var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::text", null, [], iptal) ?? "TL";

            // ------------------------------------------------------------ veriler --
            var kalemler = await b.ListeAsync(CariHareketSorgusu, null, [gun, baglam.Kapsam.ToArray()], o =>
            {
                var borc = o.GetDecimal(6); var alacak = o.GetDecimal(7);
                var bm = borc - alacak >= 0;
                return new Kalem(o.GetInt32(0), o.GetInt32(1), o.GetInt16(2), o.GetDateTime(3), o.GetDateTime(4), o.GetString(5),
                    Math.Abs(borc - alacak), Math.Abs(o.GetDecimal(8) - o.GetDecimal(9)), o.GetInt32(10), o.GetInt32(11),
                    o.GetString(12), o.GetString(13), o.GetDecimal(14)) { BorcMu = bm };
            }, iptal);
            var hesaplar = await b.ListeAsync(HesapSorgusu, null, [gun, subeler],
                o => (tur: o.GetString(0).Trim(), para: o.GetString(1), doviz: o.GetDecimal(2), yerel: o.GetDecimal(3), adet: o.GetInt32(4)), iptal);
            // Çek ve sipariş her zaman okunur (küçük küme); pozisyona girişi şerit seçimine bağlı.
            var cekler = await b.ListeAsync(CekSorgusu, null, [gun, subeler],
                o => (para: o.GetString(0), doviz: o.GetDecimal(1), yerel: o.GetDecimal(2), adet: o.GetInt32(3)), iptal);
            var siparisler = await b.ListeAsync(SiparisSorgusu, null, [gun, subeler],
                o => (tur: o.GetInt32(0), para: o.GetString(1), doviz: o.GetDecimal(2), adet: o.GetInt32(3)), iptal);

            var (parcalar, aciklar) = Fifo(kalemler);

            // Dövizler: hareketi olan + kur tablosundakiler (sıra USD, EUR, GBP, sonra alfabetik).
            var tanimli = await b.ListeAsync("select distinct doviz_cinsi from public.doviz_kur where doviz_cinsi is not null", null, [],
                o => o.GetString(0), iptal);
            string[] oncelik = ["USD", "EUR", "GBP"];
            var dovizler = kalemler.Select(k => k.Para).Concat(hesaplar.Select(h => h.para))
                .Concat(cekDahil ? cekler.Select(c => c.para) : []).Concat(siparisDahil ? siparisler.Select(s => s.para) : []).Concat(tanimli.Where(d => oncelik.Contains(d)))
                .Where(d => d != yerel && d.Length > 0).Distinct()
                .OrderBy(d => Array.IndexOf(oncelik, d) is var i && i >= 0 ? i : 99).ThenBy(d => d, StringComparer.Ordinal).ToArray();

            var kurlar = (await b.ListeAsync(KurSorgusu, null, [dovizler, gun, kt.yon],
                o => (para: o.GetString(0), kur: o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                      kurGun: o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2)), iptal)).ToDictionary(x => x.para);
            decimal? Kur(string p) => kurlar.TryGetValue(p, out var k) ? k.kur : null;
            decimal Tl(string p, decimal doviz, decimal yedekYerel) => Kur(p) is { } k ? R(doviz * k) : R(yedekYerel);

            // ------------------------------------------------------------ pozisyon --
            var satirlar = new List<(string anahtar, string kalem, bool varlik, Dictionary<string, decimal> tutar, decimal tl, int adet)>();
            void Satir(string anahtar, string kalem, bool varlik, IEnumerable<(string para, decimal doviz, decimal yerel, int adet)> x)
            {
                var liste = x.ToList();
                var tutar = liste.GroupBy(y => y.para).ToDictionary(g => g.Key, g => R(g.Sum(y => y.doviz)));
                var tl = R(liste.Sum(y => Tl(y.para, y.doviz, y.yerel)));
                satirlar.Add((anahtar, kalem, varlik, tutar, tl, liste.Sum(y => y.adet)));
            }
            var kasaTur = new[] { "K", "H" };
            var bankaTur = new[] { "B", "P" };
            Satir("kasa", "Kasa (döviz kasaları)", true, hesaplar.Where(h => kasaTur.Contains(h.tur)).Select(h => (h.para, h.doviz, h.yerel, h.adet)));
            Satir("banka", "Banka (döviz hesapları)", true, hesaplar.Where(h => bankaTur.Contains(h.tur)).Select(h => (h.para, h.doviz, h.yerel, h.adet)));

            // Cari bakiye: cari + döviz başına açık borç (alacağımız) − açık alacak (borcumuz) - FIFO açıkları = bakiye.
            var cariBakiye = aciklar.GroupBy(a => (a.K.TarafId, a.K.Para)).Select(g => new
            {
                g.Key.TarafId, g.Key.Para,
                doviz = R(g.Sum(a => a.Borc ? a.Kalan : -a.Kalan)),
                yerel = R(g.Sum(a => (a.Borc ? a.Kalan : -a.Kalan) * a.K.Kur)),
            }).Where(x => Math.Abs(x.doviz) >= 0.005m).ToList();
            Satir("alacak", "Müşteri alacağı (dövizli cari)", true, cariBakiye.Where(x => x.doviz > 0).Select(x => (x.Para, x.doviz, x.yerel, 1)));
            if (cekDahil)
                Satir("cek", "Portföydeki döviz çek / senet", true, cekler.Select(c => (c.para, c.doviz, c.yerel, c.adet)));
            if (siparisDahil)
                Satir("satisSiparis", "Açık satış siparişi (gelecek)", true,
                    siparisler.Where(s => s.tur == 19).Select(s => (s.para, s.doviz, s.doviz * (Kur(s.para) ?? 0), s.adet)));
            Satir("borc", "Tedarikçi borcu (dövizli cari)", false, cariBakiye.Where(x => x.doviz < 0).Select(x => (x.Para, x.doviz, x.yerel, 1)));
            Satir("kredi", "Döviz kredisi / kredi kartı", false, hesaplar.Where(h => h.tur is "R" or "V").Select(h => (h.para, h.doviz, h.yerel, h.adet)));
            if (siparisDahil)
                Satir("alisSiparis", "Açık alış siparişi (gelecek)", false,
                    siparisler.Where(s => s.tur == 9).Select(s => (s.para, -s.doviz, -s.doviz * (Kur(s.para) ?? 0), s.adet)));
            // Diğer hesap türleri (döviz) varlık sayılır.
            var digerHesap = hesaplar.Where(h => !kasaTur.Contains(h.tur) && !bankaTur.Contains(h.tur) && h.tur is not ("R" or "V")).ToList();
            if (digerHesap.Count > 0)
                Satir("digerHesap", "Diğer döviz hesapları", true, digerHesap.Select(h => (h.para, h.doviz, h.yerel, h.adet)));

            Dictionary<string, decimal> Topla(Func<(string anahtar, string kalem, bool varlik, Dictionary<string, decimal> tutar, decimal tl, int adet), bool> f)
                => dovizler.ToDictionary(d => d, d => R(satirlar.Where(f).Sum(s => s.tutar.GetValueOrDefault(d))));
            var varlik = Topla(s => s.varlik);
            var yukumluluk = Topla(s => !s.varlik);
            var net = dovizler.ToDictionary(d => d, d => R(varlik[d] + yukumluluk[d]));
            var varlikTl = R(satirlar.Where(s => s.varlik).Sum(s => s.tl));
            var yukumlulukTl = R(satirlar.Where(s => !s.varlik).Sum(s => s.tl));
            var netTl = R(varlikTl + yukumlulukTl);
            var netDovizTl = dovizler.ToDictionary(d => d, d => Kur(d) is { } k ? R(net[d] * k) : 0m);

            // ------------------------------------------------------- cari bazında --
            var tarafAdlari = (await b.ListeAsync("""
                select t.id, coalesce(t.kod, ''), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), t.musteri, t.tedarikci
                  from public.taraf t where t.id = any(@p0::int[])
                """, null, [kalemler.Select(k => k.TarafId).Distinct().ToArray()],
                o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2), musteri: o.GetInt16(3) == 1, tedarikci: o.GetInt16(4) == 1), iptal))
                .ToDictionary(x => x.id);
            string Ad(int id) => tarafAdlari.TryGetValue(id, out var t) ? t.ad : $"#{id}";
            var cariler = cariBakiye.Select(x =>
            {
                var t = tarafAdlari.GetValueOrDefault(x.TarafId);
                var ortKur = x.doviz != 0 ? Math.Round(x.yerel / x.doviz, 4) : 0;
                var bugunTl = Kur(x.Para) is { } k ? R(x.doviz * k) : (decimal?)null;
                return new
                {
                    tarafId = x.TarafId, kod = t.kod ?? "", ad = Ad(x.TarafId), musteri = t.musteri, tedarikci = t.tedarikci,
                    doviz = x.Para, bakiye = x.doviz, ortKur, bugunKur = Kur(x.Para), kayitliTl = x.yerel, bugunTl,
                    fark = bugunTl is { } bt ? R(bt - x.yerel) : (decimal?)null,
                };
            }).OrderByDescending(x => Math.Abs(x.fark ?? 0)).ThenBy(x => x.ad, StringComparer.Create(Tr, true)).ToList();
            var cariDegerleme = R(cariler.Sum(c => c.fark ?? 0));

            // ---------------------------------------------------------- kur farkı --
            var donemParca = parcalar.Where(p => p.Kapanis >= donemBas && p.Kapanis <= donemBit).ToList();
            bool Satis(Kalem k) => SatisTurleri.Contains(k.Tur);
            bool Alis(Kalem k) => AlisTurleri.Contains(k.Tur);
            // Tahsilat: satış faturası (borç) ödeme dışı bir alacakla kapandı. Ödeme: alış faturası (alacak) bir borçla kapandı.
            var tahsilat = donemParca.Where(p => Satis(p.B) && !Satis(p.A) && !Alis(p.A)).ToList();
            var odeme = donemParca.Where(p => Alis(p.A) && !Satis(p.B) && !Alis(p.B)).ToList();
            var diger = donemParca.Except(tahsilat).Except(odeme).ToList();
            object Kaynak(string ad, List<Parca> l, string not) => new
            {
                kaynak = ad, gelir = R(l.Where(p => p.Fark > 0).Sum(p => p.Fark)), gider = R(-l.Where(p => p.Fark < 0).Sum(p => p.Fark)),
                net = R(l.Sum(p => p.Fark)), adet = l.Count, not,
            };
            var hesapDegerleme = R(hesaplar.Where(h => h.tur is not ("R" or "V")).Sum(h => Kur(h.para) is { } k ? h.doviz * k - h.yerel : 0));
            var gerceklesen = R(donemParca.Sum(p => p.Fark));
            var kurFarkiSatirlari = new List<object>
            {
                Kaynak("Tahsilat (dövizli alacak kapandı)", tahsilat, "lehte fark için kur farkı faturası kesilebilir"),
                Kaynak("Ödeme (dövizli borç kapandı)", odeme, "lehte fark: tedarikçiden kur farkı faturası beklenir"),
            };
            if (diger.Count > 0) kurFarkiSatirlari.Add(Kaynak("Diğer kapamalar (iade, mahsup)", diger, "iade / mahsup ile kapanan kalemler"));
            kurFarkiSatirlari.Add(new
            {
                kaynak = "Döviz kasa / banka değerlemesi", gelir = Math.Max(hesapDegerleme, 0), gider = Math.Max(-hesapDegerleme, 0),
                net = hesapDegerleme, adet = hesaplar.Count, not = "bilgi - bugünkü kur ile kayıtlı TL farkı",
            });
            kurFarkiSatirlari.Add(new
            {
                kaynak = "Açık cari değerlemesi", gelir = R(cariler.Where(c => c.fark > 0).Sum(c => c.fark ?? 0)),
                gider = R(-cariler.Where(c => c.fark < 0).Sum(c => c.fark ?? 0)), net = cariDegerleme, adet = cariler.Count,
                not = "bilgi - kayda geçmez",
            });

            // ------------------------------------------------- kur farkı faturası --
            var takip = (await b.ListeAsync("""
                select k.id, k.belge_id, k.kapama_anahtar, k.durum, coalesce(k.kesilen_belge_id, 0),
                       coalesce((select nullif(x.belge_no, '') from public.belge x where x.id = k.kesilen_belge_id), ''),
                       k.aciklama, k.ekleme_tarihi,
                       coalesce((select public.fn_taraf_ad(p.unvan, p.ad, p.soyad)::varchar(120) from public.taraf p where p.id = k.ekleyen), '')
                  from public.kur_farki_takip k where k.belge_id = any(@p0::int[])
                """, null, [tahsilat.Select(p => p.B.BelgeId).Where(x => x > 0).Distinct().ToArray()],
                o => (id: o.GetInt64(0), belgeId: o.GetInt32(1), anahtar: o.GetString(2), durum: (int)o.GetInt16(3), kesilenId: o.GetInt32(4),
                      kesilenNo: o.GetString(5), aciklama: o.GetString(6), an: o.GetDateTime(7), kim: o.GetString(8)), iptal))
                .ToDictionary(x => (x.belgeId, x.anahtar));
            var ihracat = (await b.ListeAsync("select id from public.belge where id = any(@p0::int[]) and coalesce(senaryo, 0) = 3", null,
                [tahsilat.Select(p => p.B.BelgeId).Distinct().ToArray()], o => o.GetInt32(0), iptal)).ToHashSet();
            var faturalar = tahsilat.Where(p => p.B.BelgeId > 0)
                .GroupBy(p => (p.B.BelgeId, p.A.Anahtar))
                .Select(g =>
                {
                    var f = g.First();
                    var tutar = R(g.Sum(p => p.Tutar));
                    var fark = R(g.Sum(p => p.Fark));
                    var tk = takip.TryGetValue((f.B.BelgeId, f.A.Anahtar), out var t) ? t : default;
                    var durum = tk.id > 0 ? (tk.durum == 1 ? "kesildi" : "gerekYok") : fark > 0 ? "oneri" : "aleyhte";
                    return new
                    {
                        tarafId = f.B.TarafId, cari = Ad(f.B.TarafId), belgeId = f.B.BelgeId, belgeNo = f.B.No, belgeTarihi = f.B.Tarih,
                        kapamaAnahtar = f.A.Anahtar, kapamaNo = f.A.No, kapamaTur = f.A.TurAdi, kapamaTarihi = f.Kapanis,
                        doviz = f.B.Para, tutarDoviz = tutar, faturaKuru = Math.Round(f.B.Kur, 4), kapamaKuru = Math.Round(f.A.Kur, 4),
                        kurFarki = fark, durum, ihracat = ihracat.Contains(f.B.BelgeId),
                        takipId = tk.id > 0 ? tk.id : (long?)null, kesilenBelgeId = tk.kesilenId > 0 ? tk.kesilenId : (int?)null,
                        kesilenBelgeNo = tk.kesilenNo, takipAciklama = tk.aciklama, takipAn = tk.id > 0 ? tk.an : (DateTime?)null, takipKim = tk.kim,
                    };
                })
                .Where(x => Math.Abs(x.kurFarki) >= 0.01m)
                .OrderBy(x => x.durum == "oneri" ? 0 : x.durum == "aleyhte" ? 1 : 2).ThenByDescending(x => Math.Abs(x.kurFarki))
                .ToList();
            var oneriler = faturalar.Where(f => f.durum == "oneri").ToList();

            // ------------------------------------------------------- vade takvimi --
            (string kod, string ad)[] dilimler = [("gecmis", "Vadesi geçmiş"), ("d30", "0–30 gün"), ("d60", "31–60 gün"), ("d90", "61–90 gün"), ("d90p", "90+ gün")];
            string Dilim(DateTime vade) => (vade - gun).TotalDays switch
            {
                < 0 => "gecmis", <= 30 => "d30", <= 60 => "d60", <= 90 => "d90", _ => "d90p",
            };
            var vade = dilimler.Select(d =>
            {
                var l = aciklar.Where(a => Dilim(a.K.Vade) == d.kod).ToList();
                var alacak = dovizler.ToDictionary(p => p, p => R(l.Where(a => a.Borc && a.K.Para == p).Sum(a => a.Kalan)));
                var borc = dovizler.ToDictionary(p => p, p => R(-l.Where(a => !a.Borc && a.K.Para == p).Sum(a => a.Kalan)));
                var netD = dovizler.ToDictionary(p => p, p => R(alacak[p] + borc[p]));
                return new { dilim = d.kod, ad = d.ad, alacak, borc, net = netD, netTl = R(dovizler.Sum(p => netD[p] * (Kur(p) ?? 0))) };
            }).ToList();
            var gelecekBorc = aciklar.Where(a => !a.Borc && a.K.Vade >= gun).ToList();
            var borcTl = gelecekBorc.Sum(a => a.Kalan * (Kur(a.K.Para) ?? a.K.Kur));
            int? ortVadeGun = borcTl > 0 ? (int)Math.Round(gelecekBorc.Sum(a => (decimal)(a.K.Vade - gun).TotalDays * a.Kalan * (Kur(a.K.Para) ?? a.K.Kur)) / borcTl) : null;
            var enYakin = gelecekBorc.GroupBy(a => (a.K.Vade, a.K.Para)).OrderBy(g => g.Key.Vade)
                .Select(g => new { tarih = g.Key.Vade, doviz = g.Key.Para, tutar = R(g.Sum(a => a.Kalan)) }).FirstOrDefault();

            // ---------------------------------------------------------- duyarlılık --
            var duyarlilik = Senaryolar.Select(y => new
            {
                yuzde = y,
                senaryo = y < 0 ? $"Kurlar %{-y} düşer" : $"Kurlar %{y} artar",
                etkiler = dovizler.ToDictionary(d => d, d => R(netDovizTl[d] * y / 100)),
                toplam = R(dovizler.Sum(d => netDovizTl[d] * y / 100)),
            }).ToList();

            // ---------------------------------------------------------- kur geçmişi --
            var gecmisHam = await b.ListeAsync(KurGecmisiSorgusu, null, [dovizler, gun, kt.yon],
                o => (tarih: o.GetDateTime(0), para: o.GetString(1), kur: o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2), aySonu: o.GetBoolean(3)), iptal);
            var kurGecmisi = gecmisHam.GroupBy(x => x.tarih).OrderByDescending(g => g.Key)
                .Select(g => new { tarih = g.Key, aySonu = g.Any(x => x.aySonu) || g.Key == new DateTime(g.Key.Year, g.Key.Month, 1).AddMonths(1).AddDays(-1),
                                   kurlar = g.Where(x => x.kur is not null).ToDictionary(x => x.para, x => x.kur!.Value) })
                .ToList();

            var kurListesi = dovizler.Select(d =>
            {
                var k = kurlar.GetValueOrDefault(d);
                return new { doviz = d, kur = k.kur, kurTarihi = k.kurGun, eski = k.kurGun is { } kg && kg.Date < gun, yok = k.kur is null };
            }).ToList();

            return Results.Ok(new
            {
                tarih = gun, donem = donemBas.ToString("yyyy-MM", CultureInfo.InvariantCulture), donemBas, donemBit,
                kurTuru = kt.kod, kurAdi = kt.ad, sube = sube ?? 0, siparisDahil, cekDahil, yerel,
                dovizler, kurlar = kurListesi,
                ozet = new
                {
                    netTl, varlikTl, yukumlulukTl, net, netDovizTl,
                    artis10 = R(dovizler.Sum(d => netDovizTl[d]) * 0.10m),
                    gerceklesen, cariDegerleme, hesapDegerleme, degerleme = R(cariDegerleme + hesapDegerleme),
                    faturaAdet = oneriler.Select(f => f.tarafId).Distinct().Count(), faturaSatir = oneriler.Count,
                    faturaTutar = R(oneriler.Sum(f => f.kurFarki)),
                    ortVadeGun, enYakinBorc = enYakin, dovizliCari = cariler.Select(c => c.tarafId).Distinct().Count(),
                    kurYok = kurListesi.Count(k => k.yok), kurEski = kurListesi.Count(k => k.eski),
                },
                pozisyon = new
                {
                    satirlar = satirlar.Where(s => s.tutar.Values.Any(v => Math.Abs(v) >= 0.005m) || s.anahtar is "kasa" or "banka" or "alacak" or "borc")
                        .Select(s => new { s.anahtar, s.kalem, s.varlik, tutar = dovizler.ToDictionary(d => d, d => s.tutar.GetValueOrDefault(d)), s.tl, s.adet }),
                    varlik, yukumluluk, net, varlikTl, yukumlulukTl, netTl,
                },
                cariler,
                kurFarki = new { satirlar = kurFarkiSatirlari, gerceklesen },
                faturalar,
                vade,
                duyarlilik,
                kurGecmisi,
                secim = new { subeler = baglam.Subeler.Select(s => new { s.Id, s.Ad }) },
                yetkiler = new { kurFarki = baglam.Yetkiler.AksiyonVar(AksiyonKurFarki) && baglam.SubeYazma },
            });
        });

        // ========================================================== KUR FARKI İŞARET ===
        uc.MapPost("/kur-farki", async (KurFarkiIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                          HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonKurFarki);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            if (istek.Durum is not (1 or 2)) throw GentegreHatasi.Dogrulama("Durum 1 (kesildi) ya da 2 (gerek yok) olmalı.");
            var anahtar = (istek.KapamaAnahtar ?? "").Trim();
            if (anahtar.Length is 0 or > 60) throw GentegreHatasi.Dogrulama("Kapama anahtarı geçersiz.");
            var doviz = (istek.Doviz ?? "").Trim().ToUpperInvariant();
            if (doviz.Length is 0 or > 6) throw GentegreHatasi.Dogrulama("Döviz geçersiz.");
            var aciklama = (istek.Aciklama ?? "").Trim();
            if (aciklama.Length > 300) throw GentegreHatasi.Dogrulama("Açıklama en fazla 300 karakter.");
            if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(istek.TarafId)) throw GentegreHatasi.Bulunamadi("Cari bulunamadı.");

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var fatura = (await b.ListeAsync("""
                select b.id, coalesce(b.taraf_id, 0), b.tur, coalesce(nullif(b.belge_no, ''), '#' || b.id) from public.belge b where b.id = @p0
                """, tx, [istek.BelgeId], o => (id: o.GetInt32(0), taraf: o.GetInt32(1), tur: (int)o.GetInt16(2), no: o.GetString(3)), iptal))
                .FirstOrDefault();
            if (fatura.id == 0 || fatura.taraf != istek.TarafId || !SatisTurleri.Contains(fatura.tur))
                throw GentegreHatasi.Bulunamadi("Satış faturası bulunamadı.");

            int? kesilenId = null;
            var kesilenNo = (istek.KesilenBelgeNo ?? "").Trim();
            if (istek.Durum == 1)
            {
                if (kesilenNo.Length == 0) throw GentegreHatasi.Dogrulama("Kesilen kur farkı faturasının numarası girilmeli.",
                    new AlanHatasi("kesilenBelgeNo", "Boş bırakılamaz."));
                kesilenId = await b.TekDegerAsync<int?>("""
                    select b.id from public.belge b
                     where b.taraf_id = @p0 and b.tur = 15 and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                       and (b.belge_no = @p1 or (coalesce(b.belge_seri, '') || coalesce(b.belge_no, '')) = @p1 or b.id::text = @p1)
                     order by b.belge_tarihi desc limit 1
                    """, tx, [istek.TarafId, kesilenNo], iptal);
                if (kesilenId is null)
                    throw GentegreHatasi.Dogrulama($"Bu cariye kesilmiş '{kesilenNo}' numaralı satış faturası bulunamadı.",
                        new AlanHatasi("kesilenBelgeNo", "Fatura bulunamadı."));
            }

            var varOlan = await b.TekDegerAsync<long?>(
                "select id from public.kur_farki_takip where belge_id = @p0 and kapama_anahtar = @p1 for update", tx, [istek.BelgeId, anahtar], iptal);
            if (varOlan is not null) throw GentegreHatasi.IsKurali("Bu kapama için kur farkı zaten işaretlenmiş; önce işareti geri alın.");

            var id = await b.TekDegerAsync<long>("""
                insert into public.kur_farki_takip (taraf_id, belge_id, kapama_anahtar, doviz, tutar_doviz, fatura_kuru, kapama_kuru,
                                                    kur_farki, durum, kesilen_belge_id, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                returning id
                """, tx, [istek.TarafId, istek.BelgeId, anahtar, doviz, R(istek.TutarDoviz), Math.Round(istek.FaturaKuru, 6),
                          Math.Round(istek.KapamaKuru, 6), R(istek.KurFarki), istek.Durum, (object?)kesilenId ?? DBNull.Value, aciklama,
                          baglam.KullaniciId], iptal);
            await log.YazAsync(b, tx, LogIslemi.Ekle, LogTabloKurFarki, (int)id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["fatura"] = fatura.no, ["kapama"] = anahtar, ["doviz"] = doviz,
                    ["kurFarki"] = R(istek.KurFarki).ToString(CultureInfo.InvariantCulture),
                    ["durum"] = istek.Durum == 1 ? "kesildi" : "gerek-yok", ["kesilenFatura"] = kesilenNo, ["aciklama"] = aciklama,
                    ["kaynak"] = "doviz-pozisyon",
                }, tarafId: istek.TarafId, iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { id, kesilenBelgeId = kesilenId, izlemeNo = baglam.IzlemeNo });
        });

        // ======================================================= KUR FARKI GERİ AL ===
        uc.MapDelete("/kur-farki/{id:long}", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                                     HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste(AksiyonKurFarki);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var k = (await b.ListeAsync("""
                select k.id, k.taraf_id, k.belge_id, k.kapama_anahtar, k.durum, k.kur_farki, coalesce(k.kesilen_belge_id, 0), k.aciklama
                  from public.kur_farki_takip k where k.id = @p0 for update
                """, tx, [id], o => (id: o.GetInt64(0), taraf: o.GetInt32(1), belge: o.GetInt32(2), anahtar: o.GetString(3),
                                     durum: (int)o.GetInt16(4), fark: o.GetDecimal(5), kesilen: o.GetInt32(6), aciklama: o.GetString(7)), iptal))
                .FirstOrDefault();
            if (k.id == 0 || (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(k.taraf)))
                throw GentegreHatasi.Bulunamadi("Kayıt bulunamadı.");
            // Silme logu silmeden ÖNCE, tam satırla.
            await log.YazAsync(b, tx, LogIslemi.Sil, LogTabloKurFarki, (int)k.id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["belgeId"] = k.belge.ToString(CultureInfo.InvariantCulture), ["kapama"] = k.anahtar,
                    ["durum"] = k.durum == 1 ? "kesildi" : "gerek-yok", ["kurFarki"] = k.fark.ToString(CultureInfo.InvariantCulture),
                    ["kesilenBelgeId"] = k.kesilen.ToString(CultureInfo.InvariantCulture), ["aciklama"] = k.aciklama,
                    ["kaynak"] = "doviz-pozisyon",
                }, tarafId: k.taraf, iptal: iptal);
            await b.CalistirAsync("delete from public.kur_farki_takip where id = @p0", tx, [id], iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { silindi = true, izlemeNo = baglam.IzlemeNo });
        });
    }
}
