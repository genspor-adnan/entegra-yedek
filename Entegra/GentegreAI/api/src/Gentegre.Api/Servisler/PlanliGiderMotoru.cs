using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PLANLI GİDER MOTORU (1177) - tanımları okur, dönemleri <see cref="PlanliGiderHesap"/> ile
/// TEK YERDEN türetir; dondurma, eşleştirme, hatırlatma ve Nakit Akış İcmali kalemleri buradan.
/// Uçlar (PlanliGiderUclari), işçi (PlanliGiderIscisi) ve FinansIcmalUclari aynı kodu çağırır.
///
/// <para><b>Dondurma</b>: tarihi geçmiş ya da eşleşmiş dönemin satırı yoksa açılır, plan_tarihi /
/// plan_tutar o günkü hesapla yazılır; dolu olan ezilmez. PUT tanımı değiştirmeden ÖNCE dondurur.</para>
///
/// <para><b>Eşleştirme</b> adayları: kesin kasa / banka ödemesi (tediye 31-36), kesin alış faturası
/// (11, iade değil) ve İŞLENMEMİŞ banka hareketi (ödeme hesabında çıkış). Aynı cari (varsa) + aynı
/// masraf kalemi (varsa), plan tarihi ± eslesGun, tutar ± eslesYuzde (fatura brütle karşılaştırılır:
/// stopaj faturada düşülmez). Başka döneme eşleşmiş kayıt seçilemez. Tek seçilebilir aday +
/// eslesOtomatik → otomatik (loglu). Banka hareketiyle eşleşen dönem "beklemede"dir; hareket Banka
/// Hareketleri'nde işlenince eşleşme kendiliğinden o kasa işlemine taşınır.</para>
///
/// <para><b>Hatırlatma</b>: hatirlatmaGun &gt; 0 ise plan tarihinden o kadar gün önce sorumluya bir
/// kez; gecikince plan tarihinden sonraki ilk 5 gün her gün bir kez (en çok 5). Dönem başına günde
/// bir (planli_gider_donem.hatirlatildi). Bitişe 90 gün kala sorumluya bir kez yenileme hatırlatması.
/// Bildirim kuyruğu (kaynak_tur 1722 dönem, 1720 tanım).</para>
/// </summary>
public static class PlanliGiderMotoru
{
    /// <summary>islem_log.tablo_id. Sözleşme taslağındaki 1390-1393 Patoloji'nin (KartKatalogu.Patoloji) -
    ///   LogTabloIdTestleri deseniyle boş blok 1720-1723 alındı (1723 kategori kartı).</summary>
    public const int LogTanim = 1720;
    public const int LogArtis = 1721;
    public const int LogDonem = 1722;

    /// <summary>Kasa / banka ödemesi türleri (tediye).</summary>
    public static readonly int[] TediyeTurleri = [31, 32, 33, 34, 35, 36];

    // =================================================================== modeller ===

    public sealed record Tanim(
        int Id, int SubeId, string Ad, long? KategoriId, string KategoriKod, string KategoriAd, int Durum,
        int? TarafId, string Taraf, int? MasrafId, string Masraf, int? MasrafMerkeziId, int? SorumluId,
        string ReferansNo, string Aciklama, int TutarTur, int OrtalamaDonem, string HesapKaynak, decimal Tutar,
        string Doviz, decimal KdvOran, decimal StopajOran, int Periyot, int OdemeGunu, int TatilKural,
        DateTime Baslangic, DateTime? Bitis, int? DonemSayisi, int HatirlatmaGun, int? OdemeHesapId,
        string OdemeHesap, string OdemeHesapTur, int SonOdemeGunu, int OdemeYontem, string KarsiIban,
        string OdemeAciklama, int EslesGun, decimal EslesYuzde, int EslesOtomatik, int Ekleyen, string EkleyenAd,
        DateTime EklemeTarihi, DateTime? DegistirmeTarihi, string Surum, string MasrafMerkezi = "", string Sorumlu = "",
        string Sube = "")
    {
        public PlanliGiderTanimi Kural => new(Periyot, OdemeGunu, TatilKural, Baslangic, Bitis, DonemSayisi,
            TutarTur, OrtalamaDonem, Tutar, KdvOran, StopajOran);

        /// <summary>Durum aktif ve bitişi geçmemiş (karar: bitişten sonra kendiliğinden pasif).</summary>
        public bool AktifMi(DateTime bugun) => Durum == 1 && (Bitis is null || Bitis.Value.Date >= bugun.Date);
    }

    public sealed record Satir(
        long Id, int TanimId, DateTime Vade, DateTime? PlanTarihi, decimal? PlanTutar, int Durum, decimal? ElleTutar,
        string EslesenTur, long? EslesenId, decimal? EslesenTutar, DateTime? EslesenTarih, int Otomatik,
        string Aciklama, DateTime? Hatirlatildi, string EslesenNo, bool BankaBekliyor, DateTime? EslesenVade,
        int Degistiren, DateTime? DegistirmeTarihi)
    {
        public PlanliGiderSatiri Cekirdek => new(Vade, PlanTarihi, PlanTutar, Durum, ElleTutar, EslesenTutar, EslesenTarih);
    }

    public sealed record Artis(long Id, int TanimId, DateTime Gecerlilik, int Tur, decimal Deger, string Aciklama)
    {
        public PlanliGiderArtisi Cekirdek => new(Gecerlilik, Tur, Deger);
    }

    /// <summary>Yüklenmiş tanımlar + artışları + dönem satırları + tatiller + hesaplanan değerler.</summary>
    public sealed class Paket
    {
        public List<Tanim> Tanimlar { get; init; } = [];
        public ILookup<int, Artis> Artislar { get; init; } = Array.Empty<Artis>().ToLookup(x => x.TanimId);
        public ILookup<int, Satir> Satirlar { get; init; } = Array.Empty<Satir>().ToLookup(x => x.TanimId);
        /// <summary>(şube, gün) → tatil adı; şube 0 = genel.</summary>
        public Dictionary<(int, DateTime), string> Tatiller { get; init; } = [];
        /// <summary>Şube → KDV İcmali'nden hesaplanan son dönem ödenecek KDV.</summary>
        public Dictionary<int, decimal> Kdv { get; init; } = [];
        public DateTime Bugun { get; init; }

        public Func<DateTime, string?> Tatil(int sube) => d =>
            Tatiller.TryGetValue((sube, d.Date), out var a) || Tatiller.TryGetValue((0, d.Date), out a) ? a : null;

        public Dictionary<DateTime, Satir> SatirSozlugu(int tanimId)
            => Satirlar[tanimId].GroupBy(s => s.Vade.Date).ToDictionary(g => g.Key, g => g.First());

        public decimal? HesapDegeri(Tanim t)
            => t.TutarTur == 4 && t.HesapKaynak == "kdv" ? Kdv.GetValueOrDefault(t.SubeId) : null;

        /// <summary>Tanımın dönemleri (tek kaynak). Ufuk: bitiş varsa bitiş, yoksa verilen ufuk.</summary>
        public List<PlanliGiderDonemi> Donemler(Tanim t, DateTime ufuk)
        {
            var satirlar = SatirSozlugu(t.Id).ToDictionary(x => x.Key, x => x.Value.Cekirdek);
            return PlanliGiderHesap.Donemler(t.Kural, Artislar[t.Id].Select(a => a.Cekirdek).ToList(), satirlar,
                Tatil(t.SubeId), ufuk, HesapDegeri(t));
        }
    }

    // ===================================================================== okuma ===

    private const string TanimSorgusu = """
        select g.id, g.sube_id, g.ad, g.kategori_id, coalesce(k.kod, ''), coalesce(k.ad, ''), g.durum::int,
               g.taraf_id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''),
               g.masraf_id, coalesce(nullif(concat_ws(' · ', nullif(m.kod, ''), m.ad), ''), ''),
               g.masraf_merkezi_id, g.sorumlu_id, g.referans_no, g.aciklama, g.tutar_tur::int, g.ortalama_donem::int,
               g.hesap_kaynak, g.tutar, g.doviz, g.kdv_oran, g.stopaj_oran, g.periyot::int, g.odeme_gunu::int,
               g.tatil_kural::int, g.baslangic, g.bitis, g.donem_sayisi::int, g.hatirlatma_gun::int, g.odeme_hesap_id,
               coalesce(h.ad, ''), coalesce(h.tur, ''), coalesce(h.son_odeme_gunu, 0)::int, g.odeme_yontem::int,
               g.karsi_iban, g.odeme_aciklama, g.esles_gun::int, g.esles_yuzde, g.esles_otomatik::int, g.ekleyen,
               coalesce(public.fn_taraf_ad(e.unvan, e.ad, e.soyad)::varchar(200), ''), g.ekleme_tarihi,
               g.degistirme_tarihi, g.xmin::text, coalesce(mm.ad, ''),
               coalesce(public.fn_taraf_ad(so.unvan, so.ad, so.soyad)::varchar(200), ''), coalesce(sb.ad, '')
          from public.planli_gider g
          left join public.planli_gider_kategori k on k.id = g.kategori_id
          left join public.taraf t on t.id = g.taraf_id
          left join public.masraf m on m.id = g.masraf_id
          left join public.hesap h on h.id = g.odeme_hesap_id
          left join public.taraf e on e.id = g.ekleyen
          left join public.masraf_merkezi mm on mm.id = g.masraf_merkezi_id
          left join public.taraf so on so.id = g.sorumlu_id
          left join public.sube sb on sb.id = g.sube_id
        """;

    private static Tanim TanimOku(NpgsqlDataReader o)
    {
        int? I(int i) => o.IsDBNull(i) ? null : Convert.ToInt32(o.GetValue(i));
        DateTime? T(int i) => o.IsDBNull(i) ? null : o.GetDateTime(i);
        return new Tanim(o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.IsDBNull(3) ? null : o.GetInt64(3), o.GetString(4),
            o.GetString(5), o.GetInt32(6), I(7), o.GetString(8), I(9), o.GetString(10), I(11), I(12), o.GetString(13),
            o.GetString(14), o.GetInt32(15), o.GetInt32(16), o.GetString(17), o.GetDecimal(18), o.GetString(19),
            o.GetDecimal(20), o.GetDecimal(21), o.GetInt32(22), o.GetInt32(23), o.GetInt32(24), o.GetDateTime(25), T(26),
            I(27), o.GetInt32(28), I(29), o.GetString(30), o.GetString(31), o.GetInt32(32), o.GetInt32(33), o.GetString(34),
            o.GetString(35), o.GetInt32(36), o.GetDecimal(37), o.GetInt32(38), o.GetInt32(39), o.GetString(40),
            Saat.Gun(o.GetDateTime(41)), o.IsDBNull(42) ? null : o.GetDateTime(42), o.GetString(43),
            o.GetString(44), o.GetString(45), o.GetString(46));
    }

    /// <summary>
    /// Tanımları yükler. <paramref name="idler"/> null = <paramref name="subeler"/>'deki bütün tanımlar
    /// (boş dizi = bütün şubeler - işçi). <paramref name="kilitle"/> tanım satırlarını FOR UPDATE alır.
    /// </summary>
    public static async Task<Paket> YukleAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int[]? idler, int[] subeler,
        DateTime bugun, CancellationToken iptal, bool kilitle = false)
    {
        var tanimlar = await b.ListeAsync(TanimSorgusu + """
             where (@p0::int[] is null or g.id = any(@p0::int[]))
               and (cardinality(@p1::int[]) = 0 or g.sube_id = any(@p1::int[]))
             order by g.ad, g.id
            """ + (kilitle ? " for update of g" : ""), tx, [idler, subeler], TanimOku, iptal);
        var tid = tanimlar.Select(t => t.Id).ToArray();
        if (tid.Length == 0) return new Paket { Bugun = bugun };

        var artislar = await b.ListeAsync("""
            select a.id, a.planli_gider_id, a.gecerlilik, a.tur::int, a.deger, a.aciklama
              from public.planli_gider_artis a where a.planli_gider_id = any(@p0::int[]) order by a.gecerlilik
            """, tx, [tid], o => new Artis(o.GetInt64(0), o.GetInt32(1), o.GetDateTime(2), o.GetInt32(3), o.GetDecimal(4),
                o.GetString(5)), iptal);

        var satirlar = await b.ListeAsync("""
            select d.id, d.planli_gider_id, d.vade, d.plan_tarihi, d.plan_tutar, d.durum::int, d.elle_tutar, d.eslesen_tur,
                   d.eslesen_id, d.eslesen_tutar, d.eslesen_tarih, d.eslesme_otomatik::int, d.aciklama, d.hatirlatildi,
                   coalesce(case d.eslesen_tur
                       when 'kasa' then (select coalesce(nullif(ki.islem_no, ''), nullif(ki.makbuz_no, ''), '#' || ki.id)
                                           || coalesce(' · ' || kt.ad, '')
                                           from public.kasa_islem ki left join public.kasa_islem_turu kt on kt.kod = ki.tur
                                          where ki.id = d.eslesen_id)
                       when 'fatura' then (select 'Alış fatura ' || coalesce(nullif(bl.belge_no, ''), '#' || bl.id)
                                             from public.belge bl where bl.id = d.eslesen_id)
                       when 'banka' then (select 'Banka hareketi ' || coalesce(nullif(bh.banka_islem_no, ''), '#' || bh.id)
                                            from public.banka_hareket bh where bh.id = d.eslesen_id)
                   end, ''),
                   (d.eslesen_tur = 'banka' and exists (select 1 from public.banka_hareket bh
                                                        where bh.id = d.eslesen_id and bh.durum <> 2)),
                   case when d.eslesen_tur = 'fatura' then
                       (select (bl.belge_tarihi at time zone public.fn_sube_zaman_dilimi(bl.sube_id))::date + coalesce(bl.vade_gun, 0)
                          from public.belge bl where bl.id = d.eslesen_id) end,
                   d.degistiren, d.degistirme_tarihi
              from public.planli_gider_donem d where d.planli_gider_id = any(@p0::int[]) order by d.vade
            """, tx, [tid], o => new Satir(o.GetInt64(0), o.GetInt32(1), o.GetDateTime(2),
                o.IsDBNull(3) ? null : o.GetDateTime(3), o.IsDBNull(4) ? null : o.GetDecimal(4), o.GetInt32(5),
                o.IsDBNull(6) ? null : o.GetDecimal(6), o.GetString(7), o.IsDBNull(8) ? null : o.GetInt64(8),
                o.IsDBNull(9) ? null : o.GetDecimal(9), o.IsDBNull(10) ? null : o.GetDateTime(10), o.GetInt32(11),
                o.GetString(12), o.IsDBNull(13) ? null : o.GetDateTime(13), o.GetString(14), o.GetBoolean(15),
                o.IsDBNull(16) ? null : o.GetDateTime(16), o.GetInt32(17), o.IsDBNull(18) ? null : o.GetDateTime(18)), iptal);

        // TATİLLER: tam gün, aktif resmi tatil (yarım gün arife iş günüdür) - genel ya da tanımın şubesi.
        var enEski = tanimlar.Min(t => t.Baslangic).AddDays(-30);
        var tatiller = await b.ListeAsync("""
            select v.tarih, coalesce(v.sube_id, 0), v.ad from public.v_resmi_tatil v
             where v.aktif = 1 and coalesce(v.yarim_gun, 0) = 0 and v.tarih >= @p0::date
             order by v.tarih
            """, tx, [enEski], o => (gun: o.GetDateTime(0).Date, sube: o.GetInt32(1), ad: o.GetString(2)), iptal);
        var tatilSozluk = new Dictionary<(int, DateTime), string>();
        foreach (var x in tatiller) tatilSozluk.TryAdd((x.sube, x.gun), x.ad);

        // HESAPLANAN KDV: KDV İcmali'nin son kesin dönemi (geçen ay) - kesin satış KDV'si − alış KDV'si
        //   (iadeler ters), belgelerin SAKLI kdv_tutari'ndan; eksi ise 0 (devreden).
        var kdv = new Dictionary<int, decimal>();
        var kdvSube = tanimlar.Where(t => t.TutarTur == 4 && t.HesapKaynak == "kdv").Select(t => t.SubeId).Distinct().ToArray();
        if (kdvSube.Length > 0)
        {
            var gecenAy = new DateTime(bugun.Year, bugun.Month, 1).AddMonths(-1);
            var l = await b.ListeAsync("""
                select s.id, coalesce((
                    select sum(case when bl.tur in (15, 16) then 1 else -1 end
                             * case when coalesce(bl.tipi, 0) = 2 then -1 else 1 end * coalesce(bl.kdv_tutari, 0))
                      from public.belge bl
                     where bl.tur in (15, 16, 11, 12) and bl.durum = 0 and bl.sube_id = s.id
                       and (bl.belge_tarihi at time zone public.fn_sube_zaman_dilimi(s.id))::date between @p1::date and @p2::date), 0)
                  from unnest(@p0::int[]) as s(id)
                """, tx, [kdvSube, gecenAy, gecenAy.AddMonths(1).AddDays(-1)], o => (s: o.GetInt32(0), k: o.GetDecimal(1)), iptal);
            foreach (var x in l) kdv[x.s] = Math.Max(0, PlanliGiderHesap.Yuvarla(x.k));
        }

        return new Paket
        {
            Tanimlar = tanimlar, Artislar = artislar.ToLookup(x => x.TanimId), Satirlar = satirlar.ToLookup(x => x.TanimId),
            Tatiller = tatilSozluk, Kdv = kdv, Bugun = bugun,
        };
    }

    /// <summary>Tanımın dönem ufku: süresizse bugün + 24 ay (karar), değilse bitiş / dönem sayısı.</summary>
    public static DateTime Ufuk(DateTime bugun) => bugun.Date.AddMonths(24);

    // ================================================================== dondurma ===

    /// <summary>
    /// Tarihi geçmiş ya da eşleşmiş, planı dondurulmamış dönemleri o günkü hesapla dondurur.
    /// Dolu plan ezilmez. Dönüş: dondurulan dönem sayısı.
    /// </summary>
    public static async Task<int> DondurAsync(NpgsqlConnection b, NpgsqlTransaction tx, Paket p, Tanim t, int kullanici,
        CancellationToken iptal)
    {
        var ufuk = p.Bugun.AddDays(1);
        var adaylar = p.Donemler(t, ufuk)
            .Where(d => !d.Dondurulmus && (d.PlanTarihi < p.Bugun || d.Eslesti)).ToList();
        if (adaylar.Count == 0) return 0;
        return await b.CalistirAsync("""
            insert into public.planli_gider_donem (planli_gider_id, vade, plan_tarihi, plan_tutar, ekleyen)
            select @p0, x.v, x.pt, x.pu, @p4 from unnest(@p1::date[], @p2::date[], @p3::numeric[]) as x(v, pt, pu)
            on conflict (planli_gider_id, vade) do update
               set plan_tarihi = coalesce(public.planli_gider_donem.plan_tarihi, excluded.plan_tarihi),
                   plan_tutar  = coalesce(public.planli_gider_donem.plan_tutar, excluded.plan_tutar)
             where public.planli_gider_donem.plan_tutar is null or public.planli_gider_donem.plan_tarihi is null
            """, tx, [t.Id, adaylar.Select(d => d.Vade).ToArray(), adaylar.Select(d => d.PlanTarihi).ToArray(),
                      adaylar.Select(d => d.Plan).ToArray(), kullanici], iptal);
    }

    // ============================================================== eşleştirme ===

    public sealed record Aday(string Tur, long Id, string No, DateTime Tarih, string Taraf, string Masraf, decimal Tutar,
        string Neden, bool Secilebilir, string Engel, DateTime? Vade = null);

    /// <summary>Dönemin eşleşme adayları (seçilemeyenler engeliyle), plan tarihine yakınlık sırasıyla.</summary>
    public static async Task<List<Aday>> AdaylarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, Tanim t,
        PlanliGiderDonemi d, CancellationToken iptal)
    {
        var plan = d.Plan;
        var brut = d.KdvHaric + d.Kdv;                      // fatura stopajı düşmez
        var bas = d.PlanTarihi.AddDays(-t.EslesGun);
        var bit = d.PlanTarihi.AddDays(t.EslesGun);
        var oran = t.EslesYuzde / 100m;
        var liste = new List<Aday>();
        string Neden(DateTime tarih, decimal tutar, decimal hedef)
        {
            var g = (tarih.Date - d.PlanTarihi).Days;
            var parca = new List<string>();
            if (t.TarafId is not null) parca.Add("cari aynı");
            if (t.MasrafId is not null) parca.Add("masraf kalemi aynı");
            parca.Add(Math.Abs(tutar - hedef) < 0.005m ? "tutar birebir"
                : $"tutar %{Math.Round(100m * Math.Abs(tutar - hedef) / Math.Max(hedef, 0.01m), 1)} farklı");
            parca.Add(g == 0 ? "plan günü" : g > 0 ? $"{g} gün sonra" : $"{-g} gün önce");
            return string.Join(" · ", parca);
        }
        // Cari ya da masraf yoksa ödeme hesabı ölçüttür; o da yoksa aday aranmaz (her ödeme aday olurdu).
        var hesapOlcut = t.TarafId is null && t.MasrafId is null;
        if (hesapOlcut && t.OdemeHesapId is null) return liste;

        var kasa = await b.ListeAsync("""
            select ki.id, coalesce(nullif(ki.islem_no, ''), nullif(ki.makbuz_no, ''), '#' || ki.id) || coalesce(' · ' || kt.ad, ''),
                   (ki.islem_tarihi at time zone public.fn_sube_zaman_dilimi(ki.sube_id))::date,
                   coalesce(nullif(ki.taraf_unvan, ''), public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::varchar(200), ''),
                   coalesce(nullif(concat_ws(' · ', nullif(m.kod, ''), m.ad), ''), ''), ki.tutar,
                   (select x.vade from public.planli_gider_donem x
                     where x.eslesen_tur = 'kasa' and x.eslesen_id = ki.id and not (x.planli_gider_id = @p8 and x.vade = @p9::date)),
                   (select g.ad from public.planli_gider_donem x join public.planli_gider g on g.id = x.planli_gider_id
                     where x.eslesen_tur = 'kasa' and x.eslesen_id = ki.id and not (x.planli_gider_id = @p8 and x.vade = @p9::date))
              from public.kasa_islem ki
              left join public.kasa_islem_turu kt on kt.kod = ki.tur
              left join public.taraf tr on tr.id = ki.taraf_id
              left join public.masraf m on m.id = coalesce(ki.masraf_id,
                        (select mh.masraf_id from public.mali_hareket mh where mh.kasa_islem_id = ki.id and mh.masraf_id is not null limit 1))
             where ki.durum = 2 and ki.tur = any(@p0::int[])
               and (ki.islem_tarihi at time zone public.fn_sube_zaman_dilimi(ki.sube_id))::date between @p1::date and @p2::date
               and abs(ki.tutar - @p3) <= @p3 * @p4 + 0.005
               and public.fn_doviz_iso(coalesce(nullif(ki.doviz_cinsi, ''), public.fn_yerel_para()))
                   = public.fn_doviz_iso(@p5::varchar)
               and (@p6::int is null or ki.taraf_id = @p6)
               and (@p7::int is null or ki.masraf_id = @p7
                    or exists (select 1 from public.mali_hareket mh where mh.kasa_islem_id = ki.id and mh.masraf_id = @p7))
               and (not @p10::boolean or ki.hesap_id = @p11)
               and (coalesce(ki.sube_id, 0) = 0 or ki.sube_id = @p12)
             limit 50
            """, tx, [TediyeTurleri, bas, bit, plan, oran, t.Doviz, t.TarafId, t.MasrafId, t.Id, d.Vade, hesapOlcut,
                      t.OdemeHesapId, t.SubeId],
            o => (id: (long)o.GetInt32(0), no: o.GetString(1), tarih: o.GetDateTime(2), taraf: o.GetString(3), masraf: o.GetString(4),
                  tutar: o.GetDecimal(5), baskaVade: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                  baskaAd: o.IsDBNull(7) ? "" : o.GetString(7)), iptal);
        foreach (var k in kasa)
            liste.Add(new Aday("kasa", k.id, k.no, k.tarih, k.taraf, k.masraf, k.tutar, Neden(k.tarih, k.tutar, plan),
                k.baskaVade is null, k.baskaVade is { } bv ? Baska(k.baskaAd, t.Ad, bv) : "", k.baskaVade));

        if (!hesapOlcut || t.TarafId is not null)
        {
            var fatura = await b.ListeAsync("""
                select bl.id, coalesce(nullif(bl.belge_no, ''), '#' || bl.id),
                       (bl.belge_tarihi at time zone public.fn_sube_zaman_dilimi(bl.sube_id))::date,
                       coalesce(nullif(bl.taraf_unvan, ''), public.fn_taraf_ad(tr.unvan, tr.ad, tr.soyad)::varchar(200), ''),
                       coalesce(nullif(concat_ws(' · ', nullif(m.kod, ''), m.ad), ''), ''),
                       case when public.fn_doviz_iso(coalesce(nullif(bl.belge_dovizi, ''), public.fn_yerel_para())) = public.fn_yerel_para()
                            then coalesce(bl.genel_toplam, 0)
                            else round(coalesce(bl.genel_toplam, 0) / nullif(bl.doviz_kuru, 0), 2) end as tutar,
                       (select x.vade from public.planli_gider_donem x
                         where x.eslesen_tur = 'fatura' and x.eslesen_id = bl.id and not (x.planli_gider_id = @p8 and x.vade = @p9::date)),
                       (select g.ad from public.planli_gider_donem x join public.planli_gider g on g.id = x.planli_gider_id
                         where x.eslesen_tur = 'fatura' and x.eslesen_id = bl.id and not (x.planli_gider_id = @p8 and x.vade = @p9::date))
                  from public.belge bl
                  left join public.taraf tr on tr.id = bl.taraf_id
                  left join public.masraf m on m.id = coalesce(bl.masraf_id,
                            (select s.masraf_id from public.belge_satir s where s.belge_id = bl.id and s.masraf_id is not null limit 1))
                 where bl.tur = 11 and bl.durum = 0 and coalesce(bl.tipi, 0) <> 2
                   and (bl.belge_tarihi at time zone public.fn_sube_zaman_dilimi(bl.sube_id))::date between @p1::date and @p2::date
                   and public.fn_doviz_iso(coalesce(nullif(bl.belge_dovizi, ''), public.fn_yerel_para())) = public.fn_doviz_iso(@p5::varchar)
                   and abs(coalesce(bl.genel_toplam, 0) / case when public.fn_doviz_iso(coalesce(nullif(bl.belge_dovizi, ''), public.fn_yerel_para()))
                                                               = public.fn_yerel_para() then 1 else coalesce(nullif(bl.doviz_kuru, 0), 1) end
                           - @p3) <= @p3 * @p4 + 0.005
                   and (@p6::int is null or bl.taraf_id = @p6)
                   and (@p7::int is null or bl.masraf_id = @p7
                        or exists (select 1 from public.belge_satir s where s.belge_id = bl.id and s.masraf_id = @p7))
                   and (bl.sube_id is null or bl.sube_id = @p10)
                 limit 50
                """, tx, [Array.Empty<int>(), bas, bit, brut, oran, t.Doviz, t.TarafId, t.MasrafId, t.Id, d.Vade, t.SubeId],
                o => (id: (long)o.GetInt32(0), no: o.GetString(1), tarih: o.GetDateTime(2), taraf: o.GetString(3), masraf: o.GetString(4),
                      tutar: o.GetDecimal(5), baskaVade: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                      baskaAd: o.IsDBNull(7) ? "" : o.GetString(7)), iptal);
            foreach (var f in fatura)
                liste.Add(new Aday("fatura", f.id, "Alış fatura " + f.no, f.tarih, f.taraf, f.masraf, f.tutar,
                    Neden(f.tarih, f.tutar, brut), f.baskaVade is null, f.baskaVade is { } bv ? Baska(f.baskaAd, t.Ad, bv) : "",
                    f.baskaVade));
        }

        // İŞLENMEMİŞ BANKA HAREKETİ: ödeme hesabındaki çıkış (hesap banka ise).
        if (t.OdemeHesapId is not null)
        {
            var banka = await b.ListeAsync("""
                select bh.id, 'Banka hareketi · bekliyor' || coalesce(' · ' || nullif(bh.banka_islem_no, ''), ''),
                       (bh.islem_tarihi at time zone public.fn_sube_zaman_dilimi(bh.sube_id))::date,
                       coalesce(bh.karsi_ad, ''), abs(bh.tutar), coalesce(bh.karsi_iban, ''),
                       (select x.vade from public.planli_gider_donem x
                         where x.eslesen_tur = 'banka' and x.eslesen_id = bh.id and not (x.planli_gider_id = @p5 and x.vade = @p6::date)),
                       (select g.ad from public.planli_gider_donem x join public.planli_gider g on g.id = x.planli_gider_id
                         where x.eslesen_tur = 'banka' and x.eslesen_id = bh.id and not (x.planli_gider_id = @p5 and x.vade = @p6::date))
                  from public.banka_hareket bh
                 where bh.hesap_id = @p0 and bh.durum in (0, 1, 4) and bh.tutar < 0
                   and (bh.islem_tarihi at time zone public.fn_sube_zaman_dilimi(bh.sube_id))::date between @p1::date and @p2::date
                   and abs(abs(bh.tutar) - @p3) <= @p3 * @p4 + 0.005
                 limit 20
                """, tx, [t.OdemeHesapId, bas, bit, plan, oran, t.Id, d.Vade],
                o => (id: o.GetInt64(0), no: o.GetString(1), tarih: o.GetDateTime(2), taraf: o.GetString(3), tutar: o.GetDecimal(4),
                      iban: o.GetString(5), baskaVade: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                      baskaAd: o.IsDBNull(7) ? "" : o.GetString(7)), iptal);
            static string Iban(string s) => new(s.Where(char.IsLetterOrDigit).Select(char.ToUpperInvariant).ToArray());
            foreach (var h in banka)
            {
                var neden = Neden(h.tarih, h.tutar, plan);
                if (t.KarsiIban.Length > 0 && Iban(h.iban) == Iban(t.KarsiIban)) neden = "karşı IBAN tanımdaki · " + neden;
                liste.Add(new Aday("banka", h.id, h.no, h.tarih, h.taraf, "", h.tutar, neden, h.baskaVade is null,
                    h.baskaVade is { } bv ? Baska(h.baskaAd, t.Ad, bv) : "", h.baskaVade));
            }
        }

        return liste.OrderBy(a => Math.Abs((a.Tarih.Date - d.PlanTarihi).Days)).ThenBy(a => a.Tur).ToList();
    }

    private static string Baska(string ad, string buAd, DateTime vade)
        => (ad == buAd ? "" : ad + " · ") + DonemAdi(vade) + " dönemiyle zaten eşleşmiş — seçilemez";

    public static string DonemAdi(DateTime vade) => PlanliGiderHesap.AyAdi(vade.Month) + " " + vade.Year;

    /// <summary>
    /// Eşleşmeyi yazar (satır yoksa açılır; plan dondurulur) + log (dönem tablosu, tanıma bağlı).
    /// Banka hareketi seçilirse durum 3 + tür 'banka' (yanıtta "beklemede").
    /// </summary>
    public static async Task EslesAsync(NpgsqlConnection b, NpgsqlTransaction tx, LogDeposu log, Tanim t, PlanliGiderDonemi d,
        Aday a, bool otomatik, int kullanici, int? sube, string ip, CancellationToken iptal)
    {
        if (!a.Secilebilir) throw GentegreHatasi.IsKurali(a.Engel.Length > 0 ? a.Engel : "Bu kayıt seçilemez.");
        var durum = a.Tur == "fatura" ? 4 : 3;
        var id = await b.TekDegerAsync<long>("""
            insert into public.planli_gider_donem (planli_gider_id, vade, plan_tarihi, plan_tutar, durum, eslesen_tur, eslesen_id,
                   eslesen_tutar, eslesen_tarih, eslesme_otomatik, ekleyen, degistiren, degistirme_tarihi)
            values (@p0, @p1::date, @p2::date, @p3, @p4, @p5, @p6, @p7, @p8::date, @p9, @p10, @p10, now())
            on conflict (planli_gider_id, vade) do update
               set plan_tarihi = coalesce(public.planli_gider_donem.plan_tarihi, excluded.plan_tarihi),
                   plan_tutar = coalesce(public.planli_gider_donem.plan_tutar, excluded.plan_tutar),
                   durum = excluded.durum, eslesen_tur = excluded.eslesen_tur, eslesen_id = excluded.eslesen_id,
                   eslesen_tutar = excluded.eslesen_tutar, eslesen_tarih = excluded.eslesen_tarih,
                   eslesme_otomatik = excluded.eslesme_otomatik, degistiren = excluded.degistiren, degistirme_tarihi = now()
            returning id
            """, tx, [t.Id, d.Vade, d.PlanTarihi, d.Plan, (short)durum, a.Tur, a.Id, a.Tutar, a.Tarih,
                      (short)(otomatik ? 1 : 0), kullanici], iptal);
        await log.YazAsync(b, tx, LogIslemi.Degistir, LogDonem, id, kullanici, sube, ip, new Dictionary<string, string>
        {
            ["donem"] = DonemAdi(d.Vade), ["vade"] = d.Vade.ToString("yyyy-MM-dd"),
            ["eslesme"] = " -> " + a.No + (otomatik ? " (otomatik)" : " (elle)"),
            ["eslesenTur"] = a.Tur, ["eslesenId"] = LogDeposu.Metin(a.Id), ["eslesenTutar"] = LogDeposu.Metin(a.Tutar),
            ["eslesenTarih"] = a.Tarih.ToString("yyyy-MM-dd"), ["plan"] = LogDeposu.Metin(d.Plan),
        }, LogTanim, t.Id, t.TarafId, iptal: iptal);
    }

    /// <summary>
    /// TOPLU EŞLEŞTİRME (POST /eslestir ve işçi): dondurma + tek aday otomatik eşleşme + banka
    /// hareketi işlenen eşleşmelerin kasa işlemine taşınması + iptal edilen kaydın eşleşmesinin
    /// kaldırılması. <paramref name="subeler"/> boş = bütün şubeler (işçi).
    /// </summary>
    public static async Task<(int Eslesen, int Donduruldu)> EslestirAsync(VeriKaynagi veri, LogDeposu log, int[] subeler,
        int kullanici, int? sube, string ip, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        await using var tx = await b.BeginTransactionAsync(iptal);
        var bugun = Saat.Bugun;

        // 1) Banka hareketi işlendiyse eşleşme o kasa işlemine taşınır (kayıt başka döneme eşleşmemişse).
        var tasinan = await b.ListeAsync("""
            update public.planli_gider_donem d
               set eslesen_tur = 'kasa', eslesen_id = bh.kasa_islem_id, degistirme_tarihi = now()
              from public.banka_hareket bh, public.planli_gider g
             where d.eslesen_tur = 'banka' and bh.id = d.eslesen_id and bh.durum = 2 and bh.kasa_islem_id is not null
               and g.id = d.planli_gider_id and (cardinality(@p0::int[]) = 0 or g.sube_id = any(@p0::int[]))
               and not exists (select 1 from public.planli_gider_donem x where x.eslesen_tur = 'kasa' and x.eslesen_id = bh.kasa_islem_id)
            returning d.id, d.planli_gider_id, d.vade, bh.kasa_islem_id
            """, tx, [subeler], o => (id: o.GetInt64(0), tanim: o.GetInt32(1), vade: o.GetDateTime(2), kasa: o.GetInt32(3)), iptal);
        foreach (var x in tasinan)
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogDonem, x.id, kullanici, sube, ip, new Dictionary<string, string>
            {
                ["donem"] = DonemAdi(x.vade), ["eslesme"] = "banka hareketi -> kasa işlemi #" + x.kasa + " (banka hareketi işlendi)",
            }, LogTanim, x.tanim, iptal: iptal);

        // 2) Eşleşen kayıt iptal edildi / silindi / taslağa döndüyse eşleşme kalkar (loglu).
        var kalkan = await b.ListeAsync("""
            update public.planli_gider_donem d
               set durum = 0, eslesen_tur = '', eslesen_id = null, eslesen_tutar = null, eslesen_tarih = null,
                   eslesme_otomatik = 0, degistirme_tarihi = now()
              from public.planli_gider g
             where g.id = d.planli_gider_id and d.durum in (3, 4) and (cardinality(@p0::int[]) = 0 or g.sube_id = any(@p0::int[]))
               and ((d.eslesen_tur = 'kasa' and not exists (select 1 from public.kasa_islem ki where ki.id = d.eslesen_id and ki.durum = 2))
                 or (d.eslesen_tur = 'fatura' and not exists (select 1 from public.belge bl where bl.id = d.eslesen_id and bl.durum = 0))
                 or (d.eslesen_tur = 'banka' and not exists (select 1 from public.banka_hareket bh where bh.id = d.eslesen_id and bh.durum in (0, 1, 2, 4))))
            returning d.id, d.planli_gider_id, d.vade
            """, tx, [subeler], o => (id: o.GetInt64(0), tanim: o.GetInt32(1), vade: o.GetDateTime(2)), iptal);
        foreach (var x in kalkan)
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogDonem, x.id, kullanici, sube, ip, new Dictionary<string, string>
            {
                ["donem"] = DonemAdi(x.vade), ["eslesme"] = "eşleşen kayıt iptal edildi / silindi -> ",
            }, LogTanim, x.tanim, iptal: iptal);

        // 3) Dondurma + otomatik eşleşme (aktif tanımlar; bitişi geçen de son dönemleri için).
        var p = await YukleAsync(b, tx, null, subeler, bugun, iptal);
        int eslesen = 0, donduruldu = 0;
        foreach (var t in p.Tanimlar.Where(t => t.Durum == 1))
        {
            donduruldu += await DondurAsync(b, tx, p, t, kullanici, iptal);
            if (t.EslesOtomatik != 1) continue;
            // Yalnız tanım açıldıktan sonra planlanan ya da son 120 gündeki dönemler (eski geçmişi tarama).
            var alt = new[] { t.EklemeTarihi.Date.AddDays(-t.EslesGun - 31), bugun.AddDays(-120) }.Min();
            var donemler = p.Donemler(t, bugun.AddDays(t.EslesGun + 1))
                .Where(d => !d.Atlandi && !d.Eslesti && d.PlanTarihi >= alt && d.PlanTarihi <= bugun.AddDays(t.EslesGun)).ToList();
            var kullanilan = new HashSet<(string, long)>();
            foreach (var d in donemler)
            {
                var adaylar = (await AdaylarAsync(b, tx, t, d, iptal)).Where(a => a.Secilebilir && !kullanilan.Contains((a.Tur, a.Id))).ToList();
                if (adaylar.Count != 1) continue;
                await EslesAsync(b, tx, log, t, d, adaylar[0], true, kullanici, sube, ip, iptal);
                kullanilan.Add((adaylar[0].Tur, adaylar[0].Id));
                eslesen++;
            }
        }
        await tx.CommitAsync(iptal);
        return (eslesen, donduruldu);
    }

    // ============================================================== hatırlatma ===

    /// <summary>Sorumluya hatırlatmaları kuyruğa koyar (işçi). Dönüş: kuyruğa giden sayısı.</summary>
    public static async Task<int> HatirlatAsync(VeriKaynagi veri, BildirimDeposu bildirim, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var bugun = Saat.Bugun;
        var p = await YukleAsync(b, null, null, [], bugun, iptal);
        var giden = 0;
        foreach (var t in p.Tanimlar.Where(t => t.AktifMi(bugun) && t.SorumluId is not null))
        {
            var alici = await b.TekAsync("""
                select coalesce(nullif(tk.cep_tel, ''), t.cep_tel, ''), coalesce(nullif(tk.eposta, ''), t.eposta, '')
                  from public.taraf t left join public.taraf_kullanici tk on tk.id = t.id where t.id = @p0
                """, null, [t.SorumluId], o => new { tel = o.GetString(0), eposta = o.GetString(1) }, iptal);
            if (alici is null || (alici.tel.Length == 0 && alici.eposta.Length == 0)) continue;

            async Task<bool> GonderAsync(int kaynakTur, long kaynakId, string konu, string govde)
            {
                var istek = alici.eposta.Length > 0
                    ? new BildirimIstegi(null, BildirimKanali.Eposta, alici.eposta, null, konu, govde, TarafId: t.SorumluId,
                        KullaniciId: t.SorumluId, KaynakTur: (short)kaynakTur, KaynakId: (int)kaynakId, Oncelik: 4)
                    : new BildirimIstegi(null, BildirimKanali.Sms, alici.tel, null, null, konu + ": " + govde, TarafId: t.SorumluId,
                        KullaniciId: t.SorumluId, KaynakTur: (short)kaynakTur, KaynakId: (int)kaynakId, Oncelik: 4);
                return await bildirim.KuyrugaEkleAsync(istek, 0, t.SubeId, iptal) is not null;
            }

            // Bitişe 90 gün: bir kez (kuyrukta aynı tanım için yenileme kaydı yoksa).
            if (t.Bitis is { } bt && (bt.Date - bugun).Days is >= 0 and <= 90
                && !await b.TekDegerAsync<bool>("""
                    select exists (select 1 from public.bildirim where kaynak_tur = @p0 and kaynak_id = @p1)
                    """, null, [(short)LogTanim, (long)t.Id], iptal))
                if (await GonderAsync(LogTanim, t.Id, "Planlı gider sözleşmesi bitiyor: " + t.Ad,
                        $"{t.Ad} tanımının bitişi {bt:dd.MM.yyyy}. Yenilemek için kartı kopyalayın (yeni dönem, yeni tutar).")) giden++;

            if (t.HatirlatmaGun <= 0) continue;
            var donemler = p.Donemler(t, bugun.AddDays(t.HatirlatmaGun + 1))
                .Where(d => !d.Atlandi && !d.Eslesti && d.PlanTarihi >= t.EklemeTarihi.Date).ToList();
            foreach (var d in donemler)
            {
                var kalan = (d.PlanTarihi - bugun).Days;
                var on = kalan >= 0 && kalan <= t.HatirlatmaGun;
                var gec = kalan < 0 && kalan >= -5;
                if (!on && !gec) continue;
                var satir = p.Satirlar[t.Id].FirstOrDefault(s => s.Vade.Date == d.Vade);
                if (satir?.Hatirlatildi is { } h && (h.Date >= bugun || (on && h.Date >= d.PlanTarihi.AddDays(-t.HatirlatmaGun))))
                    continue;   // günde bir; ön hatırlatma dönem başına bir kez
                var tutar = d.Plan.ToString("#,##0.00", System.Globalization.CultureInfo.GetCultureInfo("tr-TR")) + " " + t.Doviz;
                var konu = gec ? $"Planlı gider gecikti: {t.Ad}" : $"Planlı gider yaklaşıyor: {t.Ad}";
                var govde = gec
                    ? $"{t.Ad} · {DonemAdi(d.Vade)} ödemesi {d.PlanTarihi:dd.MM.yyyy} tarihinde planlanmıştı ({-kalan} gün geçti), eşleşen ödeme yok. Tutar {tutar}."
                    : $"{t.Ad} · {DonemAdi(d.Vade)} ödemesi {d.PlanTarihi:dd.MM.yyyy} ({(kalan == 0 ? "bugün" : kalan + " gün sonra")}). Tutar {tutar}.";
                var donemId = await b.TekDegerAsync<long>("""
                    insert into public.planli_gider_donem (planli_gider_id, vade, hatirlatildi) values (@p0, @p1::date, @p2::date)
                    on conflict (planli_gider_id, vade) do update set hatirlatildi = excluded.hatirlatildi
                    returning id
                    """, null, [t.Id, d.Vade, bugun], iptal);
                if (await GonderAsync(LogDonem, donemId, konu, govde)) giden++;
            }
        }
        return giden;
    }

    // ============================================================ nakit akış ===

    /// <summary>Nakit Akış İcmali'nin planlı gider kalemi (çıkış, tanım dövizinde).</summary>
    public sealed record AkisKalemi(int TanimId, string Ad, int TarafId, string Taraf, string Donem, DateTime Vade,
        string Doviz, decimal Tutar, bool Gecmis, bool Tahmini, string Hesap, string Esneklik);

    /// <summary>
    /// Aktif tanımların bugünden <paramref name="son"/>'a kadar EŞLEŞMEMİŞ, atlanmamış dönemleri +
    /// gecikmiş olanlar (geçmiş, eşleşmemiş; yalnız tanım açıldıktan sonra planlanan - eski geçmiş
    /// akışa yığılmasın). Kredi kartı yöntemi: kartın ekstre son ödeme gününe (hesap.son_odeme_gunu).
    /// Dönüş: kalemler + aktif tanım sayısı (uyarı için).
    /// </summary>
    public static async Task<(List<AkisKalemi> Kalemler, int TanimSayisi)> AkisKalemleriAsync(NpgsqlConnection b,
        int[] subeler, int s0, DateTime bugun, DateTime son, CancellationToken iptal)
    {
        int[] sube = s0 > 0 ? [s0] : subeler;
        var p = await YukleAsync(b, null, null, sube, bugun, iptal);
        var kalemler = new List<AkisKalemi>();
        var aktif = p.Tanimlar.Where(t => t.AktifMi(bugun)).ToList();
        foreach (var t in aktif)
            foreach (var d in p.Donemler(t, son))
            {
                if (d.Atlandi || d.Eslesti || d.PlanTarihi > son) continue;
                var gecmis = d.PlanTarihi < bugun;
                if (gecmis && d.PlanTarihi < t.EklemeTarihi.Date) continue;
                var tarih = d.PlanTarihi;
                if (t.OdemeYontem == 3 && t.OdemeHesapTur == "V")
                {
                    var g = t.SonOdemeGunu is >= 1 and <= 31 ? t.SonOdemeGunu : 31;
                    var ekstre = PlanliGiderHesap.AyGunu(tarih.Year, tarih.Month, g);
                    if (ekstre < tarih) { var s = tarih.AddMonths(1); ekstre = PlanliGiderHesap.AyGunu(s.Year, s.Month, g); }
                    tarih = ekstre;
                    if (tarih > son) continue;
                }
                kalemler.Add(new AkisKalemi(t.Id, t.Ad, t.TarafId ?? 0, t.Taraf.Length > 0 ? t.Taraf : t.Ad, DonemAdi(d.Vade),
                    tarih, t.Doviz, d.Plan, gecmis, d.Tahmini, t.OdemeHesap, t.KategoriKod == "vergi_sgk" || t.OdemeYontem == 2
                        ? "ertelenemez" : "pazarlik"));
            }
        return (kalemler, aktif.Count);
    }
}
