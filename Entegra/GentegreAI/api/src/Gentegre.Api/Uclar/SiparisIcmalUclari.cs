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
/// SİPARİŞ İCMALİ (mockup Ekranlar/İcmal/siparis_icmali.html - kullanıcı 25.10.2026, kararlar
/// mockup altında). "Kime ne söz verdik, ne kadarını teslim ettik, neyi geciktiriyoruz,
/// elimizdeki stok yetecek mi?" İki yön tek uç: satış (19, başvuru tipi 30 HARİÇ) / alış (9).
///
/// <para><b>Açıklık:</b> Açık Satır Listesi ile AYNI kural - satır <c>v_belge_acik_satir</c>'da
/// varsa açıktır (kalan_miktar &gt; 0, belge kesin; kalan_miktar dönüşüm tetiğinin yazdığı
/// sayaç). Ekran ikinci bir kural yazmaz. "Kalanı kapat" ile kapatılan satır
/// (<c>siparis_satir_kapanis</c>) icmalde kapalıdır; sipariş belgesi değişmez.</para>
///
/// <para><b>Teslim:</b> siparişten türeyen (belge_satir.kaynak_tur = 30, kaynak_id = sipariş
/// satırı) KESİN irsaliye / fatura / fiş satırlarının miktarı; taslak hedef teslim sayılmaz
/// (ayrıca "taslak" olarak döner), tahakkuk mal teslimi değildir.</para>
///
/// <para><b>Tutar:</b> sipariş belgesinin dip toplamı (belge.matrah, KDV hariç;
/// fn_belge_diptoplam'ın yazdığı) satırlara satır tutarı oranında DAĞITILIR (Satış / Alış
/// İcmali ile aynı); kalan / teslim / iptal tutarı = satırın payı × miktar oranı. Satır
/// toplamı yeniden hesaplanmaz. Döviz: TL belgenin kuruyla; tek döviz seçilirse yalnız o
/// dövizdeki siparişler o dövizin cinsinden. Temsilci BELGEDEN (belge.satici_id).</para>
///
/// <para><b>Termin (karar 25.10.2026):</b> satırın teslim tarihi; yoksa (alışta) siparişin
/// sözleşmeli teslim tarihi (belge_satinalma.soz_teslim); ikisi de yoksa "termini
/// yazılmamış" - gecikme hesabına girmez. ZAMANINDA son sevke göre (satır tamamlandığı gün);
/// ilk sevk ortalama teslim süresinde. OTIF = zamanında VE tam (kalanı kapatılan eksiktir).</para>
///
/// <para><b>Stok karşılama (satış, karar 25.10.2026):</b> eldeki = sipariş deposundaki kalan −
/// SKT'si geçmiş lot; rezerve edilmiş miktar önce kendi satırını karşılar, kalan serbest
/// stok açık siparişlere termin sırasıyla (ilk termin ilk alır) dağıtılır, sonra yoldaki
/// (açık alış siparişi, aynı açıklık kuralı). Alış yönünde yerine "Gelecek mal".</para>
///
/// <para><b>Konsinye (karar 25.10.2026):</b> 119 / 109 belgeler `konsinye=1` ile ayrı rozetle
/// girer (varsayılan hariç); satış değildir - açık sipariş tutarına, termine, teslim
/// performansına ve stok karşılamaya katılmaz.</para>
///
/// <para><b>Tedarikçi skoru (alış):</b> v_tedarikci_skor'dan (satınalma skor olayları) okunur,
/// icmal yeniden hesaplamaz.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı,
/// cari kayıt kapsamı (baglam.Kapsam) uygulanır.
/// </summary>
public static class SiparisIcmalUclari
{
    /// <summary>Ekran kodu (1176) - hakları Satış Siparişi Listesi'nden kopyalanır.</summary>
    private const string Kod = "siparis.icmali";

    /// <summary>islem_log.tablo_id - belge (BelgeDeposu.LogTabloBelge ile aynı).</summary>
    private const int LogTabloBelge = 30;

    private const int SatisSiparisi = 19;
    private const int AlisSiparisi = 9;
    private const int BasvuruTipi = 30;
    private static readonly int[] SatisTeslim = [14, 15, 16];
    private static readonly int[] AlisTeslim = [10, 11, 12];
    private const decimal Eps = 0.0001m;

    public sealed record KapatSatiri(int SatirId, decimal? Kalan);
    public sealed record KapatIstegi(List<KapatSatiri>? Satirlar, string? Neden);

    // ================================================================ kayıtlar ===

    /// <summary>Sipariş satırı. NetTl = belge dip toplamının (matrah) bu satıra düşen payı (TL).</summary>
    private sealed record Sat(int Id, int BelgeId, int Tur, string No, DateTime Tarih, int TarafId, string Cari,
        bool Musteri, bool Tedarikci, int SaticiId, string Satici, int SubeId, int DepoId, string Depo,
        int StokId, int HizmetId, string KalemKod, string Ad, string Kategori, string Kok,
        decimal Miktar, decimal NetTl, string Para, decimal Kur, DateTime? Termin, bool TerminSatirda,
        bool AcikKural, decimal KalanMiktar, decimal Rezerve, decimal Teslim, DateTime? IlkTeslim, DateTime? SonTeslim,
        decimal Taslak, decimal? KapananMiktar, string KapanisNeden, DateTime? KapanisTarih, string Kapatan, bool Uygun)
    {
        public bool Konsinye => Tur is 109 or 119;
        public bool Kapatildi => KapanisTarih is not null;
        /// <summary>Açık Satır Listesi kuralı + kapanış kaydı yok.</summary>
        public bool AcikMi => AcikKural && !Kapatildi;
        public decimal Kalan => AcikMi ? Math.Max(KalanMiktar, 0) : 0;
        public decimal Kapanan => Kapatildi ? KapananMiktar ?? 0 : 0;
        public string Durum => Kapatildi ? "iptal" : AcikMi ? (Teslim > Eps ? "kismi" : "acik") : "kapali";
        public decimal Oran(decimal m) => Miktar > 0 ? Math.Min(Math.Max(m, 0), Miktar) / Miktar : 0;
        public string Anahtar => StokId > 0 ? "s" + StokId : HizmetId > 0 ? "h" + HizmetId : "a" + Ad;

        /// <summary>Teslim performansına giren kapanmış satır (konsinye hariç).</summary>
        public bool Performans => !AcikMi && !Konsinye && (Kapatildi || (Teslim > Eps && SonTeslim is not null));
        /// <summary>Satırın tamamlandığı gün: son kesin sevk; kalanı kapatılanda kapanış günü.</summary>
        public DateTime? Bitis => Kapatildi ? KapanisTarih : SonTeslim;
        public bool Tam => !Kapatildi && Teslim >= Miktar - Eps;
        public bool Zamaninda => Termin is { } t && SonTeslim is { } s && s <= t;
        public bool Otif => Tam && Zamaninda;
    }

    private sealed record Kip(string Para, string Yerel)
    {
        public bool Dovizli => Para.Length > 0;
    }

    private sealed record Karsilama(string Durum, decimal Eksik, decimal Yolda);

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
    private static decimal? Oran(int a, int b) => b > 0 ? Math.Round(100m * a / b, 1) : null;
    private static decimal? Ort(IEnumerable<double> l)
    {
        var d = l.ToList();
        return d.Count > 0 ? Math.Round((decimal)d.Average(), 1) : null;
    }

    // ================================================================== SQL ===

    /// <summary>
    /// Sipariş satırları. @p0 türler · @p1 yükleme başı · @p2 bit (dahil) · @p3 kullanıcının şubeleri ·
    /// @p4 seçili şube (0 tümü) · @p5 cari kapsamı · @p6 teslim sayılan hedef türler · @p7 depo yönü
    /// (1 çıkış, 2 giriş) · @p8 trend başı · @p9 kategori (alt dallarıyla, 0 tümü).
    /// YÜKLEME: dönemin siparişleri (trend için 12 ay) + tarihi ne olursa olsun HÂLÂ AÇIK satırlar
    /// (stok karşılama, ay sonu açık) + trend içinde sevk görmüş eski satırlar. Kategori süzgeci
    /// satırı ATMAZ, `uygun` ile işaretler (dağıtım bütün satırlar üzerinden).
    /// </summary>
    private const string SatirSorgusu = """
        with recursive kok as (
            select k.id, k.id as kok_id, 0 as d from public.kategori k where coalesce(k.ust_id, 0) = 0
            union all
            select k.id, kok.kok_id, kok.d + 1 from public.kategori k join kok on k.ust_id = kok.id where kok.d < 30
        ),
        dal as (
            select k.id, 0 as d from public.kategori k where @p9 > 0 and k.id = @p9
            union all
            select k.id, dal.d + 1 from public.kategori k join dal on k.ust_id = dal.id where dal.d < 30
        )
        select s.id, s.belge_id, b.tur::int, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi::date,
               coalesce(b.taraf_id, 0),
               coalesce(nullif(btrim(b.taraf_unvan), ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
               coalesce(t.musteri, 0)::int, coalesce(t.tedarikci, 0)::int,
               coalesce(b.satici_id, 0), coalesce(public.fn_taraf_ad(sp.unvan, sp.ad, sp.soyad)::varchar(160), '')::varchar(160),
               coalesce(b.sube_id, 0), coalesce(dx.depo_id, 0), coalesce(d.ad, '')::varchar(120),
               coalesce(s.stok_id, 0), coalesce(s.hizmet_id, 0),
               coalesce(st.kod, hz.kod, ms.kod, '')::varchar(80),
               coalesce(nullif(st.ad, ''), nullif(hz.ad, ''), nullif(ms.ad, ''), nullif(left(s.aciklama, 120), ''), '(açıklama)')::varchar(200),
               case when s.stok_id is null then '(hizmet)'
                    else coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '(kategorisiz)') end::varchar(200),
               case when s.stok_id is null then '(hizmet)'
                    else coalesce(nullif(btrim(coalesce(kk.kod, '') || ' ' || coalesce(kk.ad, '')), ''), '(kategorisiz)') end::varchar(200),
               coalesce(s.miktar, 0), coalesce(s.tutar, 0), coalesce(b.matrah, 0), coalesce(pd.payda, 0), coalesce(pd.adet, 0)::int,
               p.para,
               case when p.para = p.yerel then 1::numeric
                    when public.fn_doviz_iso(coalesce(nullif(btrim(b.rapor_dovizi), ''), p.para)) = p.para
                         and coalesce(b.doviz_kuru, 0) > 0 then b.doviz_kuru
                    else coalesce(public.fn_doviz_kur_getir(p.para, b.belge_tarihi::date, 2::smallint),
                                  nullif(b.doviz_kuru, 0), 1::numeric) end,
               coalesce(s.teslim_tarihi::date, bsa.soz_teslim), s.teslim_tarihi is not null,
               v.satir_id is not null, coalesce(s.kalan_miktar, 0), coalesce(s.rezerve, 0),
               coalesce(h.teslim, 0), h.ilk, h.son, coalesce(h.taslak, 0),
               kp.miktar, coalesce(kp.neden, '')::varchar(400), kp.ekleme_tarihi::date, coalesce(ku.ad, '')::varchar(160),
               coalesce(@p9 = 0 or st.kategori in (select id from dal), false)
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
          cross join lateral (select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel) y
          cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), y.yerel))::varchar(6) as para,
                                     y.yerel) p
          cross join lateral (select case when @p7 = 1 then coalesce(s.cikis_depo_id, b.cikis_depo_id)
                                          else coalesce(s.giris_depo_id, b.giris_depo_id) end as depo_id) dx
          cross join lateral (select sum(x.tutar) as payda, count(*) as adet from public.belge_satir x where x.belge_id = b.id) pd
          left join public.depo d on d.id = dx.depo_id
          left join public.belge_satinalma bsa on bsa.id = b.id
          left join public.taraf t on t.id = b.taraf_id
          left join public.taraf sp on sp.id = b.satici_id
          left join public.stok st on st.id = s.stok_id
          left join public.hizmet hz on hz.id = s.hizmet_id
          left join public.masraf ms on ms.id = s.masraf_id
          left join public.kategori k on k.id = st.kategori
          left join kok on kok.id = k.id
          left join public.kategori kk on kk.id = kok.kok_id
          left join public.v_belge_acik_satir v on v.satir_id = s.id
          left join public.siparis_satir_kapanis kp on kp.belge_satir_id = s.id
          left join public.v_kullanici_lookup ku on ku.id = kp.ekleyen
          left join lateral (
                select sum(hs.miktar) filter (where hb.durum = 0 and hb.tur = any(@p6::int[])) as teslim,
                       min(hb.belge_tarihi::date) filter (where hb.durum = 0 and hb.tur = any(@p6::int[])) as ilk,
                       max(hb.belge_tarihi::date) filter (where hb.durum = 0 and hb.tur = any(@p6::int[])) as son,
                       sum(hs.miktar) filter (where hb.durum = 1) as taslak
                  from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                 where hs.kaynak_tur = 30 and hs.kaynak_id > 0 and hs.kaynak_id = s.id and coalesce(hb.tipi, 0) <> 2) h on true
         where b.tur = any(@p0::int[]) and b.durum = 0
           and not (b.tur = 19 and coalesce(b.tipi, 0) = 30)
           and b.belge_tarihi < @p2::date + 1
           and (b.belge_tarihi >= @p1::date or v.satir_id is not null or h.son >= @p8::date)
           and (b.sube_id is null or b.sube_id = any(@p3::int[]))
           and (@p4 = 0 or b.sube_id = @p4)
           and (cardinality(@p5::int[]) = 0 or b.taraf_id = any(@p5::int[]))
         order by b.belge_tarihi, b.id, s.sira, s.id
        """;

    /// <summary>Aylık kesin sevk (trend): @p0 sipariş satırları · @p1 teslim türleri · @p2 trend başı.</summary>
    private const string SevkSorgusu = """
        select hs.kaynak_id, date_trunc('month', hb.belge_tarihi::date)::date, sum(hs.miktar)
          from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
         where hs.kaynak_tur = 30 and hs.kaynak_id > 0 and hs.kaynak_id = any(@p0::int[])
           and hb.durum = 0 and hb.tur = any(@p1::int[]) and coalesce(hb.tipi, 0) <> 2
           and hb.belge_tarihi >= @p2::date
         group by 1, 2
        """;

    /// <summary>Stok × depo: kalan, rezerve, SKT'si geçmiş lot. Depo 0 = kullanıcının şubelerindeki
    ///   bütün etkin depolar (deposuz sipariş). @p0 stok · @p1 depo (eş diziler) · @p2 şubeler · @p3 bugün.</summary>
    private const string StokDurumSorgusu = """
        select x.stok_id, x.depo_id, coalesce(sum(sd.kalan), 0), coalesce(sum(sd.rezerve), 0), coalesce(sum(skt.m), 0)
          from unnest(@p0::int[], @p1::int[]) as x(stok_id, depo_id)
          left join public.depo d on (x.depo_id > 0 and d.id = x.depo_id)
                                  or (x.depo_id = 0 and d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p2::int[])))
          left join public.stok_durum sd on sd.stok_id = x.stok_id and sd.depo_id = d.id
          left join lateral (
                select sum(ld.kalan) as m
                  from public.stok_lot_durum ld join public.stok_seri_lot l on l.id = ld.seri_lot_id
                 where ld.stok_id = x.stok_id and ld.depo_id = d.id and ld.kalan > 0
                   and l.son_kullanma_tarihi is not null and l.son_kullanma_tarihi::date < @p3::date) skt on true
         group by 1, 2
        """;

    /// <summary>Açık sipariş kalanı stok bazında - Açık Satır Listesi kuralı (v_belge_acik_satir) +
    ///   kapanış kaydı yok. @p0 tür · @p1 stoklar · @p2 şubeler. Alış siparişinde "yoldaki".</summary>
    private const string AcikKalanSorgusu = """
        select v.stok_id, sum(v.kalan_miktar), min(coalesce(bs.teslim_tarihi::date, bsa.soz_teslim)),
               string_agg(distinct coalesce(nullif(v.belge_no, ''), '#' || v.belge_id), ', ')
          from public.v_belge_acik_satir v
          join public.belge b on b.id = v.belge_id
          join public.belge_satir bs on bs.id = v.satir_id
          left join public.belge_satinalma bsa on bsa.id = v.belge_id
         where v.belge_tur = @p0 and v.stok_id = any(@p1::int[])
           and not (b.tur = 19 and coalesce(b.tipi, 0) = 30)
           and (v.sube_id is null or v.sube_id = any(@p2::int[]))
           and not exists (select 1 from public.siparis_satir_kapanis kp where kp.belge_satir_id = v.satir_id)
         group by 1
        """;

    // ============================================================= yardımcılar ===

    private static async Task<List<Sat>> SatirlarAsync(NpgsqlConnection b, int[] turler, DateTime yukBas, DateTime bit,
        int[] subeler, int sube, int[] kapsam, int[] teslimTur, int depoYonu, DateTime m0, int kategori, CancellationToken iptal)
        => await b.ListeAsync(SatirSorgusu, null, [turler, yukBas, bit, subeler, sube, kapsam, teslimTur, depoYonu, m0, kategori], o =>
        {
            DateTime? T(int i) => o.IsDBNull(i) ? null : o.GetDateTime(i);
            var miktar = o.GetDecimal(20);
            var tutar = o.GetDecimal(21);
            var matrah = o.GetDecimal(22);
            var payda = o.GetDecimal(23);
            var adet = o.GetInt32(24);
            // DAĞITIM: belge dip toplamı satır tutarı oranında (Satış / Alış İcmali ile aynı).
            var net = payda != 0 ? matrah * tutar / payda : adet > 0 ? matrah / adet : 0m;
            return new Sat(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetDateTime(4), o.GetInt32(5), o.GetString(6),
                o.GetInt32(7) == 1, o.GetInt32(8) == 1, o.GetInt32(9), o.GetString(10), o.GetInt32(11), o.GetInt32(12),
                o.GetString(13), o.GetInt32(14), o.GetInt32(15), o.GetString(16), o.GetString(17), o.GetString(18), o.GetString(19),
                miktar, net, o.GetString(25), o.GetDecimal(26), T(27), o.GetBoolean(28),
                o.GetBoolean(29), o.GetDecimal(30), o.GetDecimal(31), o.GetDecimal(32), T(33), T(34), o.GetDecimal(35),
                o.IsDBNull(36) ? null : o.GetDecimal(36), o.GetString(37), T(38), o.GetString(39), o.GetBoolean(40));
        }, iptal);

    private static async Task<Kip> KipCozAsync(NpgsqlConnection b, string? para, CancellationToken iptal)
    {
        var yerel = await b.TekDegerAsync<string>("select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6)", null, [], iptal) ?? "TL";
        var p = string.IsNullOrWhiteSpace(para) ? ""
            : await b.TekDegerAsync<string>("select public.fn_doviz_iso(@p0)::varchar(6)", null, [para.Trim()], iptal) ?? "";
        if (p == yerel) p = "";
        return new Kip(p, yerel);
    }

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    /// <summary>
    /// STOK KARŞILAMA (karar 25.10.2026). Stok × depo kümesinde: satırın kendi rezervesi önce,
    /// sonra serbest stok (kalan − SKT geçmiş − rezerve) termin sırasıyla (ilk termin ilk alır),
    /// sonra yoldaki (açık alış siparişi) - stok bazında, gruplar ilk termin sırasıyla.
    /// </summary>
    private static (Dictionary<int, Karsilama> satir, List<(Sat ilk, decimal acik, decimal eldeki, decimal rezerve,
        decimal yoldaki, string yoldakiNo, decimal yoldanAlinan, decimal eksik, DateTime? ilkTermin, int satirSayisi)> grup)
        KarsilamaHesapla(List<Sat> acik, Dictionary<(int, int), (decimal kalan, decimal rezerve, decimal skt)> durum,
            Dictionary<int, (decimal m, DateTime? termin, string no)> yolda)
    {
        var sonuc = new Dictionary<int, Karsilama>();
        var gruplar = new List<(Sat, decimal, decimal, decimal, decimal, string, decimal, decimal, DateTime?, int)>();
        var yolHavuz = yolda.ToDictionary(x => x.Key, x => x.Value.m);
        static (DateTime, DateTime, int) Sira(Sat x) => (x.Termin ?? DateTime.MaxValue, x.Tarih, x.Id);
        foreach (var g in acik.GroupBy(x => (x.StokId, x.DepoId)).OrderBy(k => k.Min(x => Sira(x))))
        {
            var (kalan, rezerve, skt) = durum.GetValueOrDefault(g.Key);
            var serbest = Math.Max(kalan - skt - rezerve, 0);
            decimal yoldanAlinan = 0, eksikTop = 0;
            foreach (var x in g.OrderBy(Sira))
            {
                var kendi = Math.Min(Math.Max(x.Rezerve, 0), x.Kalan);
                var ihtiyac = x.Kalan - kendi;
                var stoktan = Math.Min(serbest, ihtiyac);
                serbest -= stoktan; ihtiyac -= stoktan;
                var havuz = yolHavuz.GetValueOrDefault(x.StokId);
                var yoldan = Math.Min(havuz, ihtiyac);
                if (yoldan > 0) yolHavuz[x.StokId] = havuz - yoldan;
                ihtiyac -= yoldan;
                yoldanAlinan += yoldan; eksikTop += ihtiyac;
                var d = ihtiyac > Eps ? "eksik" : yoldan > Eps ? "yolda" : kendi > Eps && stoktan <= Eps ? "rezerve" : "var";
                sonuc[x.Id] = new Karsilama(d, ihtiyac > Eps ? ihtiyac : 0, yoldan);
            }
            var y = yolda.GetValueOrDefault(g.Key.StokId);
            gruplar.Add((g.OrderBy(Sira).First(), g.Sum(x => x.Kalan), kalan - skt, rezerve, y.m, y.no ?? "",
                yoldanAlinan, eksikTop, g.Min(x => x.Termin), g.Count()));
        }
        return (sonuc, gruplar);
    }

    private static string TerminKovasi(Sat x, DateTime bugun)
    {
        if (x.Termin is not { } t) return "yok";
        var gun = (t.Date - bugun).Days;
        return gun < 0 ? "gecen" : gun < 7 ? "h1" : gun < 14 ? "h2" : gun < 21 ? "h3" : gun < 28 ? "h4" : "sonra";
    }

    public static void SiparisIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/siparis-icmal").WithTags("Sipariş İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (string? yon, DateTime? bas, DateTime? bit, string? durum, string? termin, int? sube, int? depo,
                                int? temsilci, int? kategori, string? para, int? konsinye,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");
            var satis = yon != "alis";
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
            var dr = durum is "acik" or "kismi" or "kapali" or "iptal" or "tumu" ? durum : "acikkismi";
            var tr = termin is "gecen" or "hafta" or "ay" or "yok" ? termin : "";
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var kapsam = baglam.Kapsam.ToArray();
            var d0 = depo ?? 0;
            var tms = temsilci ?? 0;
            var k0 = kategori ?? 0;
            var kons = (konsinye ?? 0) == 1;
            var m0 = new DateTime(bitis.Year, bitis.Month, 1).AddMonths(-11);
            var yukBas = baslangic < m0 ? baslangic : m0;
            var turler = satis ? (kons ? new[] { SatisSiparisi, 119 } : new[] { SatisSiparisi })
                                : (kons ? new[] { AlisSiparisi, 109 } : new[] { AlisSiparisi });
            var teslimTur = satis ? SatisTeslim : AlisTeslim;

            await using var b = await veri.AcAsync(iptal);
            var kip = await KipCozAsync(b, para, iptal);
            var tum = await SatirlarAsync(b, turler, yukBas, bitis, subeler, s0, kapsam, teslimTur, satis ? 1 : 2, m0, k0, iptal);

            decimal Carp(Sat x) => kip.Dovizli ? (x.Kur > 0 ? 1m / x.Kur : 0m) : 1m;
            decimal Tl(Sat x) => x.NetTl * Carp(x);
            decimal KalanT(Sat x) => Tl(x) * x.Oran(x.Kalan);
            decimal TeslimT(Sat x) => Tl(x) * x.Oran(x.Teslim);
            decimal IptalT(Sat x) => Tl(x) * x.Oran(x.Kapanan);
            bool TemsilciUyar(Sat x) => tms == 0 || (tms == -1 ? x.SaticiId == 0 : x.SaticiId == tms);
            bool Donemde(Sat x) => x.Tarih >= baslangic && x.Tarih <= bitis;
            bool DepoUyar(Sat x) => d0 == 0 || x.DepoId == d0;

            // Seçim listeleri süzülmemiş dönem kümesinden (temsilci / para seçince liste daralmasın).
            var donemHam = tum.Where(x => Donemde(x) && x.Uygun && DepoUyar(x)).ToList();
            var temsilciler = donemHam.GroupBy(x => x.SaticiId).OrderBy(g => g.Key == 0 ? 1 : 0).ThenBy(g => g.First().Satici)
                .Select(g => new { id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().Satici }).ToList();
            var paralar = donemHam.Select(x => x.Para).Where(p => p != kip.Yerel).Distinct().OrderBy(p => p).ToList();
            var paraKumesi = donemHam.Where(TemsilciUyar).ToList();                       // para tablosu (TL karşılığı)
            var P = paraKumesi.Where(x => !kip.Dovizli || x.Para == kip.Para).ToList();   // dönem kümesi
            var Pn = P.Where(x => !x.Konsinye).ToList();                                   // konsinye hariç
            var acikP = Pn.Where(x => x.AcikMi).ToList();

            // ------------------------------------------------- stok karşılama (satış) --
            var karsilama = new Dictionary<int, Karsilama>();
            var karsilamaGrup = new List<object>();
            var eksikKok = new Dictionary<string, int>();
            int karsilanamayan = 0;
            var yetkiTalep = baglam.Yetkiler.Var("satinalma.talep", Islem.Ekle) && baglam.Yetkiler.Var("stok.kritik_stok_icmali", Islem.Gor);
            if (satis)
            {
                var acikStoklu = tum.Where(x => x.AcikMi && x.StokId > 0 && !x.Konsinye && x.Uygun && DepoUyar(x)).ToList();
                var ciftler = acikStoklu.Select(x => (x.StokId, x.DepoId)).Distinct().ToList();
                var durumlar = ciftler.Count == 0 ? []
                    : await b.ListeAsync(StokDurumSorgusu, null,
                        [ciftler.Select(x => x.StokId).ToArray(), ciftler.Select(x => x.DepoId).ToArray(), subeler, bugun],
                        o => (stok: o.GetInt32(0), depo: o.GetInt32(1), kalan: o.GetDecimal(2), rezerve: o.GetDecimal(3), skt: o.GetDecimal(4)), iptal);
                var stoklar = acikStoklu.Select(x => x.StokId).Distinct().ToArray();
                var yolda = stoklar.Length == 0 ? []
                    : await b.ListeAsync(AcikKalanSorgusu, null, [AlisSiparisi, stoklar, subeler],
                        o => (stok: o.GetInt32(0), m: o.GetDecimal(1), termin: o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2), no: o.IsDBNull(3) ? "" : o.GetString(3)), iptal);
                var (ks, kg) = KarsilamaHesapla(acikStoklu,
                    durumlar.ToDictionary(x => (x.stok, x.depo), x => (x.kalan, x.rezerve, x.skt)),
                    yolda.ToDictionary(x => x.stok, x => (x.m, x.termin, x.no)));
                karsilama = ks;
                karsilanamayan = kg.Count(x => x.eksik > Eps);
                foreach (var g in kg.Where(x => x.eksik > Eps))
                    eksikKok[g.ilk.Kok] = eksikKok.GetValueOrDefault(g.ilk.Kok) + 1;
                karsilamaGrup = kg.Where(x => x.eksik > Eps || x.yoldanAlinan > Eps)
                    .OrderByDescending(x => x.eksik).ThenBy(x => x.ilkTermin ?? DateTime.MaxValue)
                    .Select(x => (object)new
                    {
                        stokId = x.ilk.StokId, kod = x.ilk.KalemKod, ad = x.ilk.Ad, depoId = x.ilk.DepoId,
                        depo = x.ilk.DepoId == 0 ? "(depo yok - şubelerin bütün depoları)" : x.ilk.Depo,
                        acik = x.acik, eldeki = x.eldeki, rezerve = x.rezerve, yoldaki = x.yoldaki, yoldakiNo = x.yoldakiNo,
                        yoldanAlinan = x.yoldanAlinan, eksik = x.eksik, ilkTermin = x.ilkTermin,
                        gecti = x.ilkTermin is { } it && it.Date < bugun, satir = x.satirSayisi,
                        oneri = x.eksik > Eps ? "talep" : "yolda",
                        talepAcilir = x.eksik > Eps && x.ilk.DepoId > 0 && yetkiTalep,
                    }).ToList();
            }

            // ---------------------------------------------- satır görünümü --
            object SatirNesnesi(Sat x)
            {
                var k = karsilama.GetValueOrDefault(x.Id);
                return new
                {
                    satirId = x.Id, belgeId = x.BelgeId, tur = x.Tur, no = x.No, tarih = x.Tarih, tarafId = x.TarafId, cari = x.Cari,
                    stokId = x.StokId, kod = x.KalemKod, urun = x.Ad, hizmet = x.StokId == 0, kategori = x.Kok,
                    miktar = x.Miktar, teslim = x.Teslim, kalan = x.Kalan, taslak = x.Taslak, kapanan = x.Kapanan,
                    tutar = R(Tl(x)), kalanTutar = R(KalanT(x)),
                    termin = x.Termin, terminSatirda = x.TerminSatirda,
                    gun = x.Termin is { } t && x.AcikMi && !x.Konsinye ? (int?)(bugun - t.Date).Days : null,
                    kova = x.AcikMi && !x.Konsinye ? TerminKovasi(x, bugun) : "",
                    stokDurum = x.StokId == 0 ? "hizmet" : k?.Durum ?? "", eksik = k?.Eksik ?? 0m,
                    durum = x.Durum, konsinye = x.Konsinye, para = x.Para,
                    doviz = x.Para != kip.Yerel && !kip.Dovizli && x.Kur > 0 ? R(x.NetTl * x.Oran(x.Kalan) / x.Kur) : (decimal?)null,
                    temsilci = x.SaticiId == 0 ? "(temsilcisiz)" : x.Satici, depo = x.Depo,
                    kapanis = x.Kapatildi ? new { neden = x.KapanisNeden, tarih = x.KapanisTarih, kapatan = x.Kapatan } : null,
                    donusebilir = x.AcikMi && !x.Konsinye,
                };
            }

            bool DurumUyar(Sat x) => dr switch
            {
                "acik" => x.Durum == "acik", "kismi" => x.Durum == "kismi", "kapali" => x.Durum == "kapali",
                "iptal" => x.Durum == "iptal", "tumu" => true, _ => x.AcikMi,
            };
            bool TerminUyar(Sat x) => tr switch
            {
                "gecen" => x.AcikMi && x.Termin is { } t && t.Date < bugun,
                "hafta" => x.Termin is { } t2 && t2.Date >= bugun && t2.Date < bugun.AddDays(7),
                "ay" => x.Termin is { } t3 && t3.Date >= bugun && t3.Date < bugun.AddDays(30),
                "yok" => x.Termin is null,
                _ => true,
            };
            var listeKumesi = P.Where(x => DurumUyar(x) && TerminUyar(x)).OrderBy(x => x.Termin ?? DateTime.MaxValue).ThenBy(x => x.Tarih)
                .ThenBy(x => x.Id).ToList();

            // ------------------------------------------------------------- özet --
            var gecen = acikP.Where(x => x.Termin is { } t && t.Date < bugun).ToList();
            var perf = Pn.Where(x => x.Performans).ToList();
            var perfTerminli = perf.Where(x => x.Termin is not null).ToList();
            var teslimSuresi = Pn.Where(x => x.IlkTeslim is not null).Select(x => (x.IlkTeslim!.Value - x.Tarih).TotalDays).ToList();
            var iptalEdilen = Pn.Where(x => x.Kapatildi).ToList();
            var konsAcik = P.Where(x => x.Konsinye && x.AcikMi).ToList();
            var toplamMiktar = Pn.Sum(x => x.Miktar);

            // --------------------------------------------- trend (12 ay) + geçen ay OTIF --
            var trendKume = tum.Where(x => x.Uygun && DepoUyar(x) && TemsilciUyar(x) && !x.Konsinye
                                           && (!kip.Dovizli || x.Para == kip.Para)).ToList();
            var sevk = trendKume.Count == 0 ? []
                : await b.ListeAsync(SevkSorgusu, null, [trendKume.Select(x => x.Id).ToArray(), teslimTur, m0],
                    o => (satir: o.GetInt32(0), ay: o.GetDateTime(1), miktar: o.GetDecimal(2)), iptal);
            var sevkSatir = sevk.GroupBy(x => x.satir).ToDictionary(g => g.Key, g => g.ToList());
            var trendSoz = trendKume.ToDictionary(x => x.Id);
            decimal AcikMiktarAySonu(Sat x, DateTime ay, DateTime son)
            {
                // Sonraki aylarda gelen sevk, toplam kesin teslimden düşülür (o gün teslim edilmiş olan).
                var sonra = sevkSatir.TryGetValue(x.Id, out var l) ? l.Where(z => z.ay > ay).Sum(z => z.miktar) : 0m;
                var teslimEdilen = x.Teslim - sonra;
                var kapanan = x.Kapatildi && x.KapanisTarih <= son ? x.Kapanan : 0m;
                // Kuralla kapanmış (tahakkuk / taslak dönüşümle) ve kesin teslimi eksik kalan kısım, kapandığı gün kapalı.
                if (!x.AcikMi && !x.Kapatildi && (x.SonTeslim ?? x.Tarih) <= son) kapanan += Math.Max(x.Miktar - x.Teslim, 0);
                return Math.Min(Math.Max(x.Miktar - teslimEdilen - kapanan, 0), x.Miktar);
            }
            var aylarHam = Enumerable.Range(0, 12).Select(i =>
            {
                var ay = m0.AddMonths(i);
                var son = ay.AddMonths(1).AddDays(-1);
                if (son > bitis) son = bitis;
                var siparis = trendKume.Where(x => x.Tarih >= ay && x.Tarih <= son).Sum(Tl);
                var sevkTutar = sevk.Where(z => z.ay == ay && trendSoz.ContainsKey(z.satir))
                    .Sum(z => { var x = trendSoz[z.satir]; return x.Miktar > 0 ? Tl(x) * Math.Min(z.miktar, x.Miktar) / x.Miktar : 0m; });
                var aySonuAcik = trendKume.Where(x => x.Tarih <= son && x.Miktar > 0)
                    .Sum(x => Tl(x) * AcikMiktarAySonu(x, ay, son) / x.Miktar);
                var biten = trendKume.Where(x => x.Performans && x.Termin is not null && x.Bitis is { } bt && bt >= ay && bt <= son).ToList();
                var ilk = trendKume.Where(x => x.IlkTeslim is { } it && it >= ay && it <= son).Select(x => (x.IlkTeslim!.Value - x.Tarih).TotalDays);
                return new
                {
                    ay, siparis = R(siparis), sevk = R(sevkTutar), aySonuAcik = R(aySonuAcik),
                    otif = Oran(biten.Count(x => x.Otif), biten.Count), kapanan = biten.Count, ortTeslim = Ort(ilk),
                    kismiGun = ay.Year == bitis.Year && ay.Month == bitis.Month && bitis.Day < DateTime.DaysInMonth(ay.Year, ay.Month)
                        ? bitis.Day : (int?)null,
                };
            }).ToList();
            var enBuyukAy = Math.Max(aylarHam.Count > 0 ? aylarHam.Max(x => x.siparis) : 0, 0.01m);
            var aylar = aylarHam.Select(x => new
            {
                x.ay, x.siparis, x.sevk, x.aySonuAcik, x.otif, x.kapanan, x.ortTeslim, x.kismiGun, cubuk = Yuzde(Math.Max(x.siparis, 0), enBuyukAy),
            }).ToList();
            var gecenAy = aylarHam.Count >= 2 ? aylarHam[^2].otif : null;

            var ozet = new
            {
                acikTutar = R(acikP.Sum(KalanT)), acikSiparis = acikP.Select(x => x.BelgeId).Distinct().Count(),
                acikSatir = acikP.Count, kismiSatir = acikP.Count(x => x.Teslim > Eps),
                gecenSatir = gecen.Count, gecenTutar = R(gecen.Sum(KalanT)),
                enEskiGecikme = gecen.Count > 0 ? gecen.Max(x => (bugun - x.Termin!.Value.Date).Days) : 0,
                otif = Oran(perfTerminli.Count(x => x.Otif), perfTerminli.Count), kapananSatir = perfTerminli.Count,
                terminsizKapanan = perf.Count - perfTerminli.Count, otifGecenAy = gecenAy,
                ortTeslim = Ort(teslimSuresi),
                donusum = toplamMiktar > 0 ? Math.Round(100m * Pn.Sum(x => Math.Min(x.Teslim, x.Miktar)) / toplamMiktar, 1) : (decimal?)null,
                karsilanamayan,
                gelecekTutar = satis ? 0m : R(acikP.Sum(KalanT)), gelecekKalem = satis ? 0 : acikP.Where(x => x.StokId > 0).Select(x => x.StokId).Distinct().Count(),
                iptalTutar = R(iptalEdilen.Sum(IptalT)), iptalSatir = iptalEdilen.Count,
                terminsizAcik = acikP.Count(x => x.Termin is null),
                siparisTutar = R(Pn.Sum(Tl)), teslimTutar = R(Pn.Sum(TeslimT)), siparis = Pn.Select(x => x.BelgeId).Distinct().Count(),
                konsinyeSatir = konsAcik.Count, konsinyeTutar = R(konsAcik.Sum(KalanT)),
                taslakSatir = acikP.Count(x => x.Taslak > Eps),
            };

            // ------------------------------------------------- cari bazında --
            var toplamKalan = acikP.Sum(KalanT);
            var tedSkor = new Dictionary<int, (decimal skor, long gecikme)>();
            if (!satis)
            {
                var tIdler = P.Select(x => x.TarafId).Where(x => x > 0).Distinct().ToArray();
                if (tIdler.Length > 0)
                    tedSkor = (await b.ListeAsync("""
                        select s.firma_id, coalesce(s.skor, 100), coalesce(s.gecikme, 0) from public.v_tedarikci_skor s where s.firma_id = any(@p0::int[])
                        """, null, [tIdler], o => (id: o.GetInt32(0), skor: o.GetDecimal(1), gecikme: o.GetInt64(2)), iptal))
                        .ToDictionary(x => x.id, x => (x.skor, x.gecikme));
            }
            var cariler = P.GroupBy(x => x.TarafId).Select(g =>
            {
                var ilk = g.First();
                var n = g.Where(x => !x.Konsinye).ToList();
                var ac = n.Where(x => x.AcikMi).ToList();
                var pf = n.Where(x => x.Performans && x.Termin is not null).ToList();
                var tm = g.GroupBy(x => x.SaticiId).OrderByDescending(x => x.Sum(KalanT))
                    .Select(x => x.Key == 0 ? "(temsilcisiz)" : x.First().Satici).Distinct().ToList();
                var kalan = ac.Sum(KalanT);
                return new
                {
                    id = g.Key, ad = ilk.Cari, musteri = ilk.Musteri, tedarikci = ilk.Tedarikci,
                    temsilci = string.Join(" · ", tm.Take(2)) + (tm.Count > 2 ? " …" : ""),
                    siparis = n.Select(x => x.BelgeId).Distinct().Count(), acikSatir = ac.Count,
                    siparisTutar = R(n.Sum(Tl)), teslimTutar = R(n.Sum(TeslimT)), kalanTutar = R(kalan),
                    gecenTutar = R(ac.Where(x => x.Termin is { } t && t.Date < bugun).Sum(KalanT)),
                    otif = Oran(pf.Count(x => x.Otif), pf.Count), pay = Yuzde(kalan, toplamKalan),
                    doviz = kip.Dovizli ? [] : ac.Where(x => x.Para != kip.Yerel && x.Kur > 0).GroupBy(x => x.Para)
                        .Select(x => new { para = x.Key, tutar = R(x.Sum(z => z.NetTl * z.Oran(z.Kalan) / z.Kur)) }).ToList(),
                    konsinyeTutar = R(g.Where(x => x.Konsinye && x.AcikMi).Sum(KalanT)),
                    skor = tedSkor.TryGetValue(g.Key, out var sk) ? sk.skor : (decimal?)null,
                    acikSatirlar = g.Where(x => x.AcikMi).OrderBy(x => x.Termin ?? DateTime.MaxValue).Take(40).Select(SatirNesnesi).ToList(),
                    acikSatirSayisi = g.Count(x => x.AcikMi),
                };
            }).Where(x => x.siparis > 0 || x.konsinyeTutar > 0).OrderByDescending(x => x.kalanTutar).ThenBy(x => x.ad).ToList();
            var enBuyukCari = cariler.Count > 0 ? Math.Max(cariler.Max(x => x.kalanTutar), 0.01m) : 1m;
            var cariSatirlari = cariler.Select(x => new
            {
                x.id, x.ad, x.musteri, x.tedarikci, x.temsilci, x.siparis, x.acikSatir, x.siparisTutar, x.teslimTutar, x.kalanTutar,
                x.gecenTutar, x.otif, x.pay, cubuk = Yuzde(Math.Max(x.kalanTutar, 0), enBuyukCari), x.doviz, x.konsinyeTutar, x.skor,
                x.acikSatirlar, x.acikSatirSayisi,
            }).ToList();
            var cariToplam = new
            {
                cari = cariler.Count, siparis = ozet.siparis, acikSatir = acikP.Count, siparisTutar = ozet.siparisTutar,
                teslimTutar = ozet.teslimTutar, kalanTutar = ozet.acikTutar, gecenTutar = ozet.gecenTutar, otif = ozet.otif,
            };

            // ---------------------------------------------------- termin takvimi --
            (string k, string ad, DateTime? b1, DateTime? b2)[] kovalar =
            [
                ("gecen", "Geçmiş (termini geçen)", null, bugun.AddDays(-1)),
                ("h1", "", bugun, bugun.AddDays(6)), ("h2", "", bugun.AddDays(7), bugun.AddDays(13)),
                ("h3", "", bugun.AddDays(14), bugun.AddDays(20)), ("h4", "", bugun.AddDays(21), bugun.AddDays(27)),
                ("sonra", "Daha sonra", bugun.AddDays(28), null), ("yok", "Termini yazılmamış", null, null),
            ];
            var takvimHam = kovalar.Select(kv =>
            {
                var l = acikP.Where(x => TerminKovasi(x, bugun) == kv.k).ToList();
                return new
                {
                    kova = kv.k, ad = kv.ad.Length > 0 ? kv.ad : $"{kv.b1:dd.MM} – {kv.b2:dd.MM}", bas = kv.b1, bit = kv.b2,
                    satir = l.Count, miktar = l.Sum(x => x.Kalan), tutar = R(l.Sum(KalanT)),
                    hazir = satis ? l.Count(x => karsilama.GetValueOrDefault(x.Id)?.Durum is "var" or "rezerve") : (int?)null,
                    eksik = satis ? l.Count(x => karsilama.GetValueOrDefault(x.Id)?.Durum == "eksik") : (int?)null,
                    hizmet = l.Count(x => x.StokId == 0),
                };
            }).ToList();
            var enBuyukKova = Math.Max(takvimHam.Count > 0 ? takvimHam.Max(x => x.tutar) : 0, 0.01m);
            var takvim = takvimHam.Select(x => new { x.kova, x.ad, x.bas, x.bit, x.satir, x.miktar, x.tutar, x.hazir, x.eksik, x.hizmet,
                cubuk = Yuzde(x.tutar, enBuyukKova) }).ToList();

            // ------------------------------------------------- teslim performansı --
            object PerfSatiri(IEnumerable<Sat> l0)
            {
                var l = l0.ToList();
                var t = l.Where(x => x.Termin is not null).ToList();
                var gec = t.Where(x => x.Tam && !x.Zamaninda).ToList();
                return new
                {
                    kapanan = t.Count, zamaninda = t.Count(x => x.Otif), gec = gec.Count, eksik = t.Count(x => !x.Tam),
                    terminsiz = l.Count - t.Count, otif = Oran(t.Count(x => x.Otif), t.Count),
                    ortGecikme = Ort(t.Where(x => x.SonTeslim is { } s && s > x.Termin!.Value)
                                     .Select(x => (x.SonTeslim!.Value - x.Termin!.Value).TotalDays)),
                    ortTeslim = Ort(l.Where(x => x.IlkTeslim is not null).Select(x => (x.IlkTeslim!.Value - x.Tarih).TotalDays)),
                };
            }
            var performans = perf.GroupBy(x => x.TarafId).Select(g => new
            {
                id = g.Key, ad = g.First().Cari, musteri = g.First().Musteri, tedarikci = g.First().Tedarikci,
                deger = PerfSatiri(g), say = g.Count(x => x.Termin is not null),
                skor = tedSkor.TryGetValue(g.Key, out var sk) ? sk.skor : (decimal?)null,
                skorGecikme = tedSkor.TryGetValue(g.Key, out var sk2) ? sk2.gecikme : (long?)null,
            }).OrderByDescending(x => x.say).ThenBy(x => x.ad).ToList();

            // --------------------------------------------------- gelecek mal (alış) --
            List<object> gelecek = [];
            if (!satis)
            {
                var acikStok = acikP.Where(x => x.StokId > 0).ToList();
                var stoklar = acikStok.Select(x => x.StokId).Distinct().ToArray();
                var satisBekleyen = stoklar.Length == 0 ? []
                    : await b.ListeAsync(AcikKalanSorgusu, null, [SatisSiparisi, stoklar, subeler],
                        o => (stok: o.GetInt32(0), m: o.GetDecimal(1)), iptal);
                var eldeki = stoklar.Length == 0 ? []
                    : await b.ListeAsync("""
                        select sd.stok_id, coalesce(sum(sd.kalan - coalesce(sd.rezerve, 0)), 0)
                          from public.stok_durum sd join public.depo d on d.id = sd.depo_id
                         where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) and sd.stok_id = any(@p1::int[])
                         group by 1
                        """, null, [subeler, stoklar], o => (stok: o.GetInt32(0), m: o.GetDecimal(1)), iptal);
                var sb = satisBekleyen.ToDictionary(x => x.stok, x => x.m);
                var el = eldeki.ToDictionary(x => x.stok, x => x.m);
                gelecek = [.. acikStok.GroupBy(x => x.StokId).Select(g =>
                {
                    var ilk = g.OrderBy(x => x.Termin ?? DateTime.MaxValue).First();
                    var kalan = g.Sum(x => x.Kalan);
                    var bekleyen = sb.GetValueOrDefault(g.Key);
                    var elde = el.GetValueOrDefault(g.Key);
                    return new
                    {
                        stokId = g.Key, kod = ilk.KalemKod, ad = ilk.Ad, kategori = ilk.Kok, kalan, tutar = R(g.Sum(KalanT)),
                        ilkTermin = g.Min(x => x.Termin), geciken = g.Count(x => x.Termin is { } t && t.Date < bugun),
                        tedarikciler = string.Join(", ", g.Select(x => x.Cari).Distinct().Take(3)) + (g.Select(x => x.Cari).Distinct().Count() > 3 ? " …" : ""),
                        siparisler = string.Join(", ", g.Select(x => x.No).Distinct().Take(4)),
                        eldeki = elde, satisBekleyen = bekleyen,
                        // Bekleyen satış siparişi eldekiyle karşılanamıyorsa bu mal beklenen maldır.
                        bekleniyor = bekleyen > elde + Eps,
                    };
                }).OrderBy(x => x.ilkTermin ?? DateTime.MaxValue).Cast<object>()];
            }

            // -------------------------------------------------------- kırılımlar --
            var bugunKur = new Dictionary<string, decimal?>();
            foreach (var pr in paraKumesi.Where(x => !x.Konsinye && x.Para != kip.Yerel).Select(x => x.Para).Distinct())
                bugunKur[pr] = await b.TekDegerAsync<decimal?>("select public.fn_doviz_kur_getir(@p0, @p1::date, @p2::smallint)", null,
                    [pr, bugun, satis ? 2 : 1], iptal);
            var subeAd = baglam.Subeler.GroupBy(s => s.Id).ToDictionary(g => g.Key, g => g.First().Ad);
            var paraAcik = paraKumesi.Where(x => !x.Konsinye).ToList();
            var paraSatirlari = paraAcik.GroupBy(x => x.Para).OrderBy(g => g.Key == kip.Yerel ? 0 : 1).ThenBy(g => g.Key).Select(g =>
            {
                var ac = g.Where(x => x.AcikMi).ToList();
                var acikTl = ac.Sum(x => x.NetTl * x.Oran(x.Kalan));
                var yerel = g.Key == kip.Yerel;
                var acikDoviz = yerel ? (decimal?)null : ac.Where(x => x.Kur > 0).Sum(x => x.NetTl * x.Oran(x.Kalan) / x.Kur);
                var kur = yerel ? null : bugunKur.GetValueOrDefault(g.Key);
                // SİPARİŞ KURU: açık kısmın ağırlıklı kuru; açık yoksa siparişlerin ortalama kuru.
                decimal? sipKur = null;
                if (!yerel)
                {
                    if (acikDoviz is > 0) sipKur = Math.Round(acikTl / acikDoviz.Value, 4);
                    else if (g.Any(x => x.Kur > 0)) sipKur = Math.Round(g.Where(x => x.Kur > 0).Average(x => x.Kur), 4);
                }
                decimal? acikBugun = null;
                if (acikDoviz is { } a2 && kur is { } kr) acikBugun = R(a2 * kr);
                return new
                {
                    para = g.Key, yerel, siparis = g.Select(x => x.BelgeId).Distinct().Count(),
                    siparisTl = R(g.Sum(x => x.NetTl)), acikDoviz = acikDoviz is { } ad ? R(ad) : (decimal?)null,
                    siparisKuru = sipKur, acikTl = R(acikTl), bugunkuKur = kur, acikBugun,
                };
            }).ToList();
            var kirilim = new
            {
                temsilci = Pn.GroupBy(x => x.SaticiId).Select(g =>
                {
                    var ac = g.Where(x => x.AcikMi).ToList();
                    var pf = g.Where(x => x.Performans && x.Termin is not null).ToList();
                    return new
                    {
                        id = g.Key == 0 ? -1 : g.Key, ad = g.Key == 0 ? "(temsilcisiz)" : g.First().Satici,
                        acikTutar = R(ac.Sum(KalanT)), gecenTutar = R(ac.Where(x => x.Termin is { } t && t.Date < bugun).Sum(KalanT)),
                        otif = Oran(pf.Count(x => x.Otif), pf.Count), cari = g.Select(x => x.TarafId).Distinct().Count(),
                    };
                }).OrderByDescending(x => x.acikTutar).ToList(),
                kategori = acikP.GroupBy(x => x.Kok).Select(g => new
                {
                    ad = g.Key, acikTutar = R(g.Sum(KalanT)), pay = Yuzde(g.Sum(KalanT), toplamKalan),
                    eksikKalem = satis && g.Key != "(hizmet)" ? eksikKok.GetValueOrDefault(g.Key) : (int?)null,
                }).OrderByDescending(x => x.acikTutar).ToList(),
                subeDepo = acikP.GroupBy(x => (x.SubeId, x.Depo)).Select(g => new
                {
                    ad = (g.Key.SubeId == 0 ? "(şubesiz)" : subeAd.GetValueOrDefault(g.Key.SubeId) ?? $"Şube {g.Key.SubeId}")
                         + " · " + (g.Key.Depo.Length > 0 ? g.Key.Depo : "(depo yok)"),
                    acikTutar = R(g.Sum(KalanT)), satir = g.Count(),
                }).OrderByDescending(x => x.acikTutar).ToList(),
                para = new
                {
                    satirlar = paraSatirlari,
                    toplam = new
                    {
                        siparis = paraAcik.Select(x => x.BelgeId).Distinct().Count(), siparisTl = R(paraAcik.Sum(x => x.NetTl)),
                        acikTl = R(paraAcik.Where(x => x.AcikMi).Sum(x => x.NetTl * x.Oran(x.Kalan))),
                    },
                },
            };

            var depoListesi = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.depo d
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            var siparisTur = satis ? SatisSiparisi : AlisSiparisi;
            return Results.Ok(new
            {
                yon = satis ? "satis" : "alis", bas = baslangic, bit = bitis, bugun, durum = dr, termin = tr, sube = s0, depo = d0,
                temsilci = tms, kategori = k0, para = kip.Para, yerelPara = kip.Yerel, konsinye = kons,
                ozet, cariler = cariSatirlari, cariToplam,
                satirSayisi = listeKumesi.Count, satirlar = listeKumesi.Take(1000).Select(SatirNesnesi).ToList(),
                takvim, performans, performansToplam = PerfSatiri(perf),
                karsilama = karsilamaGrup, gelecek,
                trend = new { aylar }, kirilim,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(), depolar = depoListesi,
                    temsilciler, paralar, kategoriler,
                },
                yetkiler = new
                {
                    // İRSALİYEYE DÖNÜŞTÜR = mevcut dönüşüm ucunun kapıları + irsaliye türünde ekleme.
                    donustur = baglam.Yetkiler.Var("belge", Islem.Ekle) && baglam.Yetkiler.AksiyonVar("belge.donustur")
                               && BelgeUclari.TurIzinli(baglam, satis ? 14 : 10, 0, Islem.Ekle) && baglam.SubeYazma,
                    // KALANI KAPAT (karar 25.10.2026) = sipariş belgesinin Değiştir yetkisi.
                    kapat = BelgeUclari.TurIzinli(baglam, siparisTur, 1, Islem.Degistir) && baglam.SubeYazma,
                    // SATINALMA TALEBİ = Kritik Stok İcmali'nin talep ucu (aynı kapılar).
                    talep = satis && yetkiTalep && baglam.SubeYazma,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ============================================================ KALANI KAPAT ===
        // Açık sipariş satırının kalanını iptal eder: neden zorunlu, loglanır. SİPARİŞ BELGESİ DEĞİŞMEZ
        //   (karar 25.10.2026) - kapanış ayrı kayıttır (siparis_satir_kapanis), teslim edilmiş kısma
        //   dokunulmaz. Yetki: sipariş belgesinin Değiştir yetkisi. EŞZAMANLILIK: satırlar kilitlenir
        //   (for update) ve istemcinin gördüğü kalan, güncel kalanla karşılaştırılır - arada teslim
        //   girdiyse 409 + güncel kalanlar.
        grup.MapPost("/kapat", async (KapatIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YazmaIste();
            var neden = (istek.Neden ?? "").Trim();
            if (neden.Length < 3)
                throw GentegreHatasi.Dogrulama("Kapatma nedeni yazılmalı.", new AlanHatasi("neden", "En az 3 karakter."));
            if (neden.Length > 400) neden = neden[..400];
            var secilen = (istek.Satirlar ?? []).Where(x => x.SatirId > 0).GroupBy(x => x.SatirId).Select(g => g.Last()).ToList();
            if (secilen.Count == 0)
                throw GentegreHatasi.Dogrulama("Kapatılacak satır seçilmedi.", new AlanHatasi("satirlar", "Boş bırakılamaz."));
            if (secilen.Count > 500) throw GentegreHatasi.Dogrulama("Tek seferde en çok 500 satır kapatılır.");

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);

            var satirlar = await b.ListeAsync("""
                select s.id, s.belge_id, b.tur::int, coalesce(b.tipi, 0)::int, coalesce(b.durum, 0)::int, coalesce(b.sube_id, 0),
                       coalesce(b.taraf_id, 0), coalesce(nullif(b.belge_no, ''), '#' || b.id),
                       coalesce(s.miktar, 0), coalesce(s.kalan_miktar, 0),
                       exists (select 1 from public.v_belge_acik_satir v where v.satir_id = s.id),
                       exists (select 1 from public.siparis_satir_kapanis kp where kp.belge_satir_id = s.id),
                       coalesce((select sum(hs.miktar) from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                                  where hs.kaynak_tur = 30 and hs.kaynak_id > 0 and hs.kaynak_id = s.id and hb.durum = 0
                                    and coalesce(hb.tipi, 0) <> 2), 0),
                       coalesce(st.kod, hz.kod, ''), s.stok_id
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                  left join public.stok st on st.id = s.stok_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                 where s.id = any(@p0::int[])
                   for update of s
                """, tx, [secilen.Select(x => x.SatirId).ToArray()], o => new
                {
                    id = o.GetInt32(0), belgeId = o.GetInt32(1), tur = o.GetInt32(2), tipi = o.GetInt32(3), durum = o.GetInt32(4),
                    subeId = o.GetInt32(5), tarafId = o.GetInt32(6), no = o.GetString(7), miktar = o.GetDecimal(8), kalan = o.GetDecimal(9),
                    acik = o.GetBoolean(10), kapali = o.GetBoolean(11), teslim = o.GetDecimal(12), kod = o.GetString(13),
                    stokId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14),
                }, iptal);
            var soz = satirlar.ToDictionary(x => x.id);

            var cakisan = new List<object>();
            foreach (var x in secilen)
            {
                if (!soz.TryGetValue(x.SatirId, out var s)) throw GentegreHatasi.Bulunamadi($"Satır bulunamadı: {x.SatirId}");
                if (!baglam.Subeler.Any(z => z.Id == s.subeId)) throw GentegreHatasi.Bulunamadi($"Satır bulunamadı: {x.SatirId}");
                if (baglam.Kapsam.Count > 0 && !baglam.Kapsam.Contains(s.tarafId)) throw GentegreHatasi.Bulunamadi($"Satır bulunamadı: {x.SatirId}");
                var ad = $"{s.no} · {(s.kod.Length > 0 ? s.kod : "#" + s.id)}";
                if (!(s.tur == SatisSiparisi && s.tipi != BasvuruTipi) && s.tur != AlisSiparisi)
                    throw GentegreHatasi.IsKurali($"{ad}: yalnız satış / alış siparişi satırının kalanı kapatılır.");
                if (!BelgeUclari.TurIzinli(baglam, s.tur, s.tipi, Islem.Degistir))
                    throw GentegreHatasi.Yasak("Bu sipariş türünde değiştirme yetkiniz yok.");
                if (s.durum != 0) throw GentegreHatasi.IsKurali($"{ad}: yalnız kesinleşmiş siparişin kalanı kapatılır.");
                // Yazma aktif şubede (dönüşüm ve eşleşme "Bağla" ile aynı).
                if (baglam.SubeId is { } aktif && s.subeId != 0 && s.subeId != aktif)
                    throw GentegreHatasi.IsKurali($"{ad}: sipariş başka bir şubenin; o şubeye geçip kapatın.");
                if (s.kapali) throw GentegreHatasi.IsKurali($"{ad}: satırın kalanı zaten kapatılmış.");
                if (!s.acik) throw GentegreHatasi.IsKurali($"{ad}: satırın açık kalanı yok.");
                if (x.Kalan is { } gorulen && Math.Abs(gorulen - s.kalan) > Eps)
                    cakisan.Add(new { satirId = s.id, kalan = s.kalan, teslim = s.teslim });
            }
            if (cakisan.Count > 0) throw GentegreHatasi.Cakisma(new { satirlar = cakisan }, ["kalan"]);

            foreach (var g in satirlar.GroupBy(x => x.belgeId))
            {
                var satirLog = new List<string>();
                foreach (var s in g)
                {
                    var n = await b.CalistirAsync("""
                        insert into public.siparis_satir_kapanis (belge_id, belge_satir_id, miktar, teslim, neden, sube_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, @p5, @p6)
                        on conflict (belge_satir_id) do nothing
                        """, tx, [s.belgeId, s.id, s.kalan, s.teslim, neden, baglam.SubeId ?? s.subeId, baglam.KullaniciId], iptal);
                    if (n == 0) throw GentegreHatasi.IsKurali($"{s.no}: satırın kalanı zaten kapatılmış.");
                    satirLog.Add(string.Create(CultureInfo.InvariantCulture, $"{s.id} ({(s.kod.Length > 0 ? s.kod : "#" + s.id)} kalan {s.kalan})"));
                }
                var ilk = g.First();
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, g.Key, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["aksiyon"] = "siparis-kalan-kapat",
                        ["satirlar"] = string.Join("; ", satirLog),
                        ["kapananMiktar"] = LogDeposu.Metin(g.Sum(x => x.kalan)),
                        ["neden"] = neden,
                        ["belgeDegismedi"] = "kapanış ayrı kayıt (siparis_satir_kapanis)",
                        ["kaynak"] = "siparis-icmali",
                    }, tarafId: ilk.tarafId, stokId: g.Count() == 1 ? ilk.stokId : null, iptal: iptal);
            }

            await tx.CommitAsync(iptal);
            return Results.Ok(new
            {
                kapatilan = satirlar.Count,
                belgeler = satirlar.GroupBy(x => x.belgeId).Select(g => new { id = g.Key, no = g.First().no, satir = g.Count() }).ToList(),
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
