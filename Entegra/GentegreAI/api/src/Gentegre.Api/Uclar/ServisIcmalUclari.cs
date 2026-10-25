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
/// TEKNİK SERVİS İCMALİ (mockup Ekranlar/İcmal/teknik_servis_icmali.html - kullanıcı 25.10.2026,
/// kararlar mockup altında; 1176).
///
/// <para><b>Üç katman (773):</b> çağrı (SLA ölçülür) → iş emri (iş ve tutar) → ziyaret (bir gidiş).
/// Dönem ÇAĞRININ AÇILIŞINA göre süzülür; o çağrının iş emirleri ve ziyaretleri tarihinden bağımsız
/// onunla gelir (çağrı ayın 30'unda açılıp 2'sinde kapandıysa tek çağrıdır). Çağrısı olmayan iş emri
/// (iç iş / demirbaş arızası, elle açılmış dış iş) kendi çağrısı sayılır: açılış = bildirim, ilk yanıt =
/// ilk müdahale, kapanış = tamamlanma; SLA'sı yoktur. "Şu an" tabloları (açık çağrı, emanet,
/// faturalanmamış) dönemden bağımsızdır.</para>
///
/// <para><b>Ciro (karar 25.10.2026):</b> ücretli (1) + üretici garantisi (3) - ikisi de faturalanır.
/// Sözleşme (2) ve kendi garantimiz (4) ciro DEĞİLDİR, "servis maliyeti"nde izlenir (iç iş de
/// maliyettir). Tutar hiçbir kapsamda sıfırlanmaz (773): iş emrinin işçilik / parça / diğer
/// tutarı fn_servis_is_emri_topla'nın yazdığıdır, burada yeniden hesaplanmaz.</para>
///
/// <para><b>SLA:</b> sla_bitis çağrının açılışında yazılır (fn_servis_sla_bitis). İhlal = ilk yanıt
/// sla_bitis'ten sonra, ya da yanıt yok ve süre geçti (açıksa şimdi, kapandıysa kapanış).</para>
///
/// <para><b>İlk ziyarette çözüm:</b> çağrının sonuçlanmış (çözüldü / çözülemedi / parça bekliyor)
/// İLK ziyareti "çözüldü" ise. <b>Tekrar arıza (karar):</b> aynı cihazın (taraf_cihaz) önceki
/// çağrısının kapanışından sonra `servis.tekrar_ariza_gun` (boşsa 30) gün içinde açılan yeni çağrı -
/// farklı arıza da olsa. Teknisyen tablosunda önceki çağrıyı kapatan teknisyene yazılır.</para>
///
/// <para><b>Arıza (karar):</b> iş emrinin arıza kodu (servis_ariza_kodu, isteğe bağlı) varsa koddan;
/// kodsuz (eski) kayıt arıza metninden (küçük harf, boşluk sadeleşmiş ilk 60 karakter) gruplanır.</para>
///
/// <para><b>İşçilik (karar):</b> faturada / ciroda tarife (ziyaret tutarı → iş emrinin işçilik tutarı);
/// sözleşme kârlılığında personel saat maliyeti = taraf_personel.net_maas / 225 (aylık çalışma saati)
/// × ziyaretin işçilik saati. Maaşı ya da saati girilmemiş ziyarette tarife kullanılır ve satırda
/// rozetle belirtilir.</para>
///
/// Rakamlar sunucuda; ekran hesap yapmaz. Şube süzgeci kullanıcının şubeleriyle sınırlı, cari
/// kayıt kapsamı (baglam.Kapsam) müşteriye uygulanır.
/// </summary>
public static class ServisIcmalUclari
{
    /// <summary>Ekran kodu (1176) - haklarını servis.is_emri'den kopyalar.</summary>
    private const string Kod = "servis.icmali";

    /// <summary>Aylık çalışma saati (45 saat × 5 hafta): personel saat maliyeti = net maaş / 225.</summary>
    private const decimal AylikSaat = 225m;

    private static readonly Dictionary<short, string> KapsamAdlari = new()
    {
        [1] = "Ücretli", [2] = "Sözleşme", [3] = "Üretici garantisi", [4] = "Kendi garantimiz",
    };
    private static readonly Dictionary<short, string> KapsamKime = new()
    {
        [1] = "müşteriye fatura", [2] = "sözleşme kârlılığına", [3] = "üreticiye fatura (gelir)", [4] = "garanti gideri",
    };
    /// <summary>Çağrı durumu (servis_cagri.durum). 6 = iç işte "dış serviste" (iş emri durum 4).</summary>
    private static readonly Dictionary<short, string> CagriDurumlari = new()
    {
        [0] = "Açık (atanmamış)", [1] = "Atandı", [2] = "Yolda", [3] = "Yerinde", [4] = "Parça bekliyor",
        [6] = "Dış serviste (iç iş)",
    };
    private static readonly Dictionary<short, string> IsEmriDurumlari = new()
    {
        [0] = "açık", [1] = "atandı", [2] = "sürüyor", [3] = "parça bekliyor", [4] = "dış serviste",
        [5] = "tamamlandı", [8] = "iptal",
    };
    private static readonly Dictionary<short, string> ZiyaretSonuclari = new()
    {
        [0] = "sürüyor", [1] = "çözüldü", [2] = "çözülemedi", [3] = "parça bekliyor", [4] = "iptal",
    };
    private static readonly Dictionary<short, string> OncelikAdlari = new()
    {
        [1] = "Kritik", [2] = "Yüksek", [3] = "Normal", [4] = "Düşük",
    };
    private static readonly Dictionary<short, string> SozlesmeKapsamlari = new()
    {
        [1] = "işçilik", [2] = "işçilik + yol", [3] = "tam kapsam",
    };

    // ================================================================ kayıtlar ===

    /// <summary>Çağrı ya da (çağrısız iş emrinde) iş emrinin kendisi. Anahtar "c{id}" / "e{id}".</summary>
    private sealed record Cagri(string Anahtar, long Id, bool IsEmriKendisi, string No, int SubeId, int TarafId,
        string Taraf, int CihazId, string Cihaz, string Marka, string Model, short Kapsam, short Oncelik, short Durum,
        DateTime Acilis, DateTime? SlaBitis, DateTime? IlkYanit, DateTime? Kapanis, int SozlesmeId, bool Donemde,
        short Sahiplik)
    {
        public bool Acik => Durum < 5;
        public bool Iptal => Durum == 8;
        public string MarkaModel => (Marka + " " + Model).Trim();
    }

    private sealed record IsEmri(long Id, long CagriId, string No, short Sahiplik, short Kapsam, short Durum,
        decimal Iscilik, decimal Parca, decimal Diger, decimal Toplam, int BelgeId, int SozlesmeId, long ArizaKoduId,
        string ArizaKod, string ArizaAd, string ArizaMetni, int YapanId)
    {
        public string CagriAnahtar => CagriId > 0 ? "c" + CagriId : "e" + Id;
        /// <summary>Ciro = dış iş, ücretli ya da üretici garantisi (karar 25.10.2026).</summary>
        public bool Ciro => Sahiplik == 2 && Kapsam is 1 or 3;
    }

    private sealed record Ziyaret(long Id, long IsEmriId, int Sira, int TeknisyenId, DateTime? Varis, DateTime? Ayrilis,
        short Sonuc, decimal Saat, decimal Tutar, decimal YolKm, bool Imza, short? Puan)
    {
        /// <summary>Sonuçlanmış gidiş (çözüldü / çözülemedi / parça bekliyor).</summary>
        public bool Sonuclu => Sonuc is 1 or 2 or 3;
        public DateTime Sira0 => Varis ?? Ayrilis ?? DateTime.MaxValue;
    }

    private sealed record Parca(long IsEmriId, long ZiyaretId, int StokId, string Kod, string Ad, decimal Miktar,
        decimal BirimFiyat, short IadeDurum, int Gun)
    {
        public decimal Tutar => Miktar * BirimFiyat;
        public string Anahtar => StokId > 0 ? "s" + StokId : "p" + Kod.ToUpperInvariant() + "|" + Ad.ToUpperInvariant();
    }

    private static decimal R(decimal d) => Math.Round(d, 2);
    private static decimal R1(decimal d) => Math.Round(d, 1);
    private static decimal? Yuzde(int a, int b) => b > 0 ? Math.Round(100m * a / b, 1) : null;
    private static decimal SaatFark(DateTime bas, DateTime bit) => (decimal)(bit - bas).TotalHours;
    private static decimal? Ort(IEnumerable<decimal> l)
    {
        var x = l.ToList();
        return x.Count > 0 ? R1(x.Average()) : null;
    }
    private static decimal? Medyan(IEnumerable<decimal> l)
    {
        var x = l.OrderBy(v => v).ToList();
        if (x.Count == 0) return null;
        var m = x.Count / 2;
        return R1(x.Count % 2 == 1 ? x[m] : (x[m - 1] + x[m]) / 2);
    }

    /// <summary>SLA ihlali: ilk yanıt (yoksa açıkta şimdi, kapanmışta kapanış) sla_bitis'ten sonra.</summary>
    private static bool Ihlal(Cagri c, DateTime simdi) => Gecikme(c, simdi) is > 0;

    /// <summary>SLA'yı aşan saat (aşmadıysa ≤ 0); SLA yoksa null.</summary>
    private static decimal? Gecikme(Cagri c, DateTime simdi)
    {
        if (c.SlaBitis is not { } s || c.Iptal) return null;
        var yanit = c.IlkYanit ?? (c.Acik ? simdi : c.Kapanis ?? simdi);
        return SaatFark(s, yanit);
    }

    /// <summary>Arıza grubu: kod varsa kod, yoksa sadeleşmiş arıza metni (karar 25.10.2026).</summary>
    private static (string anahtar, string ad, bool kodlu) Ariza(IsEmri e)
    {
        if (e.ArizaKoduId > 0)
            return ("k" + e.ArizaKoduId, (e.ArizaKod + " · " + e.ArizaAd).Trim(' ', '·'), true);
        var metin = string.Join(' ', e.ArizaMetni.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
        if (metin.Length == 0) return ("-", "(arıza yazılmamış)", false);
        var kisa = metin.Length > 60 ? metin[..60] : metin;
        return ("m" + kisa.ToLower(new CultureInfo("tr-TR")), kisa, false);
    }

    // ================================================================== SQL ===

    /// <summary>Çağrılar + çağrısız iş emirleri. @p0 bas · @p1 bit (dahil) · @p2 kullanıcının şubeleri ·
    ///   @p3 seçili şube (0 tümü) · @p4 cari kayıt kapsamı · @p5 sahiplik (0 ikisi, 1 iç, 2 dış).
    ///   Dönemde açılan + dönemden bağımsız ŞU AN AÇIK olanlar (donemde bayrağıyla).</summary>
    private const string CagriSorgusu = """
        select ('c' || g.id)::text, g.id, false, coalesce(g.cagri_no, '')::text, g.sube_id, g.taraf_id,
               coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')::text,
               coalesce(g.taraf_cihaz_id, 0),
               coalesce(nullif(btrim(coalesce(tc.ad, '')::text), ''), nullif(btrim(g.cihaz_metni::text), ''), '')::text,
               coalesce(tc.marka, '')::text, coalesce(tc.model, '')::text,
               g.kapsam_tur::smallint, g.oncelik::smallint, g.durum::smallint,
               g.acilis, g.sla_bitis, g.ilk_yanit, g.kapanis, coalesce(g.sozlesme_id, 0),
               (g.acilis >= @p0::date and g.acilis < @p1::date + 1), 2::smallint
          from public.servis_cagri g
          left join public.taraf t on t.id = g.taraf_id
          left join public.taraf_cihaz tc on tc.id = g.taraf_cihaz_id
         where @p5 in (0, 2)
           and ((g.acilis >= @p0::date and g.acilis < @p1::date + 1) or g.durum < 5)
           and (g.sube_id = 0 or g.sube_id = any(@p2::int[])) and (@p3 = 0 or g.sube_id = @p3)
           and (cardinality(@p4::int[]) = 0 or g.taraf_id = any(@p4::int[]))
        union all
        select ('e' || e.id)::text, e.id, true, coalesce(e.is_emri_no, '')::text, e.sube_id, coalesce(e.musteri_taraf_id, 0),
               coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, dp.ad::text, '')::text,
               coalesce(e.taraf_cihaz_id, 0),
               coalesce(nullif(btrim(coalesce(tc.ad, '')::text), ''), nullif(btrim(coalesce(d.ad, '')::text), ''), '')::text,
               coalesce(nullif(tc.marka::text, ''), d.marka::text, '')::text, coalesce(nullif(tc.model::text, ''), d.model::text, '')::text,
               e.kapsam_tur::smallint, e.oncelik::smallint,
               (case e.durum when 2 then 3 when 3 then 4 when 4 then 6 else e.durum end)::smallint,
               e.bildirim_zamani, null::timestamptz, e.ilk_mudahale, e.tamamlanma, coalesce(e.sozlesme_id, 0),
               (e.bildirim_zamani >= @p0::date and e.bildirim_zamani < @p1::date + 1), e.sahiplik::smallint
          from public.demirbas_is_emri e
          left join public.taraf t on t.id = e.musteri_taraf_id
          left join public.taraf_cihaz tc on tc.id = e.taraf_cihaz_id
          left join public.demirbas d on d.id = e.demirbas_id
          left join public.departman dp on dp.id = e.departman_id
         where e.cagri_id is null and (@p5 = 0 or e.sahiplik = @p5) and e.durum >= 0
           and ((e.bildirim_zamani >= @p0::date and e.bildirim_zamani < @p1::date + 1) or e.durum < 5)
           and (e.sube_id = 0 or e.sube_id = any(@p2::int[])) and (@p3 = 0 or e.sube_id = @p3)
           and (cardinality(@p4::int[]) = 0 or e.sahiplik = 1 or e.musteri_taraf_id = any(@p4::int[]))
        """;

    /// <summary>İş emirleri: @p0 çağrı id'leri · @p1 (çağrısız) iş emri id'leri.</summary>
    private const string IsEmriSorgusu = """
        select e.id, coalesce(e.cagri_id, 0), coalesce(e.is_emri_no, '')::text, e.sahiplik::smallint, e.kapsam_tur::smallint,
               e.durum::smallint, e.iscilik_tutar, e.parca_tutar, e.diger_tutar, e.toplam_tutar, coalesce(e.belge_id, 0),
               coalesce(e.sozlesme_id, 0), coalesce(e.ariza_kodu_id, 0), coalesce(ak.kod, '')::text, coalesce(ak.ad, '')::text,
               coalesce(e.ariza_metni, '')::text, coalesce(e.yapan_id, 0)
          from public.demirbas_is_emri e
          left join public.servis_ariza_kodu ak on ak.id = e.ariza_kodu_id
         where e.cagri_id = any(@p0::bigint[]) or e.id = any(@p1::bigint[])
        """;

    private const string ZiyaretSorgusu = """
        select z.id, z.is_emri_id, z.sira::int, coalesce(z.teknisyen_id, 0), z.varis, z.ayrilis, z.sonuc::smallint,
               z.iscilik_saat, z.tutar, z.yol_km, z.imza_alindi = 1, z.memnuniyet_puan::smallint
          from public.servis_ziyaret z
         where z.is_emri_id = any(@p0::bigint[])
        """;

    private const string ParcaSorgusu = """
        select p.is_emri_id, coalesce(p.ziyaret_id, 0), coalesce(p.stok_id, 0),
               coalesce(nullif(s.kod::text, ''), p.parca_no::text, '')::text,
               coalesce(nullif(p.ad::text, ''), s.ad::text, '')::text,
               p.miktar, p.birim_fiyat, p.iade_durum::smallint, (current_date - p.ekleme_tarihi::date)::int
          from public.demirbas_is_emri_parca p
          left join public.stok s on s.id = p.stok_id
         where p.is_emri_id = any(@p0::bigint[])
        """;

    /// <summary>Tekrar arıza: @p0 çağrı id'leri · @p1 gün. Aynı cihazın önceki çağrısı, kapanışından
    ///   sonraki @p1 gün içinde bu çağrı açıldıysa; o çağrıyı son "çözüldü" ziyaretiyle kapatan teknisyen.</summary>
    private const string TekrarSorgusu = """
        select c.id, p.id, coalesce(p.cagri_no, '')::text,
               coalesce((select z.teknisyen_id from public.servis_ziyaret z
                           join public.demirbas_is_emri e on e.id = z.is_emri_id
                          where e.cagri_id = p.id and z.teknisyen_id is not null
                          order by (z.sonuc = 1) desc, z.ayrilis desc nulls last, z.id desc
                          limit 1), 0)
          from public.servis_cagri c
          join lateral (select q.id, q.cagri_no from public.servis_cagri q
                         where q.taraf_cihaz_id = c.taraf_cihaz_id and q.id <> c.id and q.durum <> 8
                           and q.kapanis is not null and q.kapanis <= c.acilis
                           and c.acilis < q.kapanis + make_interval(days => @p1)
                         order by q.kapanis desc limit 1) p on true
         where c.id = any(@p0::bigint[]) and c.taraf_cihaz_id is not null
        """;

    // ============================================================= yardımcılar ===

    private static async Task<Dictionary<int, (string ad, decimal saatMaliyet)>> TeknisyenlerAsync(NpgsqlConnection b,
        IEnumerable<int> idler, CancellationToken iptal)
    {
        var dizi = idler.Where(x => x > 0).Distinct().ToArray();
        if (dizi.Length == 0) return new();
        var l = await b.ListeAsync("""
            select x.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')::text, coalesce(p.net_maas, 0)
              from unnest(@p0::int[]) as x(id)
              left join public.taraf t on t.id = x.id
              left join public.taraf_personel p on p.id = x.id
            """, null, [dizi], o => (id: o.GetInt32(0), ad: o.GetString(1), maas: o.GetDecimal(2)), iptal);
        return l.ToDictionary(x => x.id, x => (x.ad.Length > 0 ? x.ad : $"#{x.id}", x.maas > 0 ? x.maas / AylikSaat : 0m));
    }

    /// <summary>Ortalama birim maliyet - Satış / Stok icmalleriyle aynı fonksiyon.</summary>
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

    private static DateTime? Zaman(NpgsqlDataReader o, int i) => o.IsDBNull(i) ? null : o.GetDateTime(i);

    // ================================================================== uç ===

    public static void ServisIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/servis-icmal").WithTags("Teknik Servis İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? sube, int? teknisyen, int? musteri, string? marka,
                                string? model, int? kapsam, int? sahiplik,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            if (baglam.PortalTuru > 0) throw GentegreHatasi.Yasak("Bu icmal portalda kullanılamaz.");

            var bugun = Saat.Bugun.Date;
            var bitis = (bit ?? bugun).Date;
            var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            if ((bitis - baslangic).TotalDays > 3660) throw GentegreHatasi.Dogrulama("Dönem en çok 10 yıl olabilir.");
            var s0 = sube ?? 0;
            if (s0 > 0 && baglam.Subeler.All(x => x.Id != s0)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var cariKapsam = baglam.Kapsam.ToArray();
            var k0 = kapsam is >= 1 and <= 4 ? (short)kapsam.Value : (short)0;
            var tek = teknisyen ?? 0;
            var mus = musteri ?? 0;
            var mrk = (marka ?? "").Trim();
            var mdl = (model ?? "").Trim();
            var simdi = DateTime.UtcNow;

            await using var b = await veri.AcAsync(iptal);

            // SAHİPLİK VARSAYILANI: HBYS'de iç (kurum demirbaşı), ERP'de dış (müşteri cihazı).
            int sah;
            if (sahiplik is 0 or 1 or 2) sah = sahiplik.Value;
            else if (sahiplik == 3) sah = 0;
            else sah = await b.TekDegerAsync<int>("select public.fn_urun_modu(@p0)::int", null, [baglam.SubeId ?? 0], iptal) == 2 ? 1 : 2;

            var tekrarAyar = (await AyarDeposu.MetinAsync(b, null, "servis.tekrar_ariza_gun", "", iptal)).Trim();
            var tekrarGun = int.TryParse(tekrarAyar, NumberStyles.Integer, CultureInfo.InvariantCulture, out var tg) && tg > 0
                ? Math.Min(tg, 365) : 30;

            // ------------------------------------------------------------- okuma --
            var hamCagri = await b.ListeAsync(CagriSorgusu, null, [baslangic, bitis, subeler, s0, cariKapsam, sah], o => new Cagri(
                o.GetString(0), o.GetInt64(1), o.GetBoolean(2), o.GetString(3), o.GetInt32(4), o.GetInt32(5), o.GetString(6),
                o.GetInt32(7), o.GetString(8), o.GetString(9), o.GetString(10), o.GetInt16(11), o.GetInt16(12), o.GetInt16(13),
                o.GetDateTime(14), Zaman(o, 15), Zaman(o, 16), Zaman(o, 17), o.GetInt32(18), o.GetBoolean(19), o.GetInt16(20)), iptal);

            var cagriIdleri = hamCagri.Where(c => !c.IsEmriKendisi).Select(c => c.Id).ToArray();
            var tekIsEmri = hamCagri.Where(c => c.IsEmriKendisi).Select(c => c.Id).ToArray();
            var hamIsEmri = cagriIdleri.Length + tekIsEmri.Length == 0 ? []
                : await b.ListeAsync(IsEmriSorgusu, null, [cagriIdleri, tekIsEmri], o => new IsEmri(
                    o.GetInt64(0), o.GetInt64(1), o.GetString(2), o.GetInt16(3), o.GetInt16(4), o.GetInt16(5), o.GetDecimal(6),
                    o.GetDecimal(7), o.GetDecimal(8), o.GetDecimal(9), o.GetInt32(10), o.GetInt32(11), o.GetInt64(12),
                    o.GetString(13), o.GetString(14), o.GetString(15), o.GetInt32(16)), iptal);
            var isEmriIdleri = hamIsEmri.Select(e => e.Id).ToArray();
            var hamZiyaret = isEmriIdleri.Length == 0 ? []
                : await b.ListeAsync(ZiyaretSorgusu, null, [isEmriIdleri], o => new Ziyaret(
                    o.GetInt64(0), o.GetInt64(1), o.GetInt32(2), o.GetInt32(3), Zaman(o, 4), Zaman(o, 5), o.GetInt16(6),
                    o.GetDecimal(7), o.GetDecimal(8), o.GetDecimal(9), o.GetBoolean(10), o.IsDBNull(11) ? null : o.GetInt16(11)), iptal);
            var hamParca = isEmriIdleri.Length == 0 ? []
                : await b.ListeAsync(ParcaSorgusu, null, [isEmriIdleri], o => new Parca(
                    o.GetInt64(0), o.GetInt64(1), o.GetInt32(2), o.GetString(3), o.GetString(4), o.GetDecimal(5),
                    o.GetDecimal(6), o.GetInt16(7), o.GetInt32(8)), iptal);

            var isEmriCagri = hamIsEmri.GroupBy(e => e.CagriAnahtar).ToDictionary(g => g.Key, g => g.ToList());
            var ziyaretIsEmri = hamZiyaret.GroupBy(z => z.IsEmriId).ToDictionary(g => g.Key, g => g.ToList());
            List<IsEmri> Isler(Cagri c) => isEmriCagri.GetValueOrDefault(c.Anahtar) ?? [];
            List<Ziyaret> Ziyaretler(Cagri c) => Isler(c).SelectMany(e => ziyaretIsEmri.GetValueOrDefault(e.Id) ?? [])
                .Where(z => z.Sonuc != 4).OrderBy(z => z.Sira0).ThenBy(z => z.Id).ToList();

            // Seçim listeleri süzülmemiş kümeden (müşteri / marka seçince liste daralmasın).
            var secimMusteri = hamCagri.Where(c => c.TarafId > 0).GroupBy(c => c.TarafId)
                .Select(g => new { id = g.Key, ad = g.First().Taraf }).OrderBy(x => x.ad).ToList();
            var secimMarka = hamCagri.Where(c => c.Marka.Length + c.Model.Length > 0).GroupBy(c => (c.Marka, c.Model))
                .Select(g => new { marka = g.Key.Marka, model = g.Key.Model }).OrderBy(x => x.marka).ThenBy(x => x.model).ToList();

            // ------------------------------------------------------- süzgeçler --
            bool Uyar(Cagri c)
            {
                if (mus > 0 && c.TarafId != mus) return false;
                if (mrk.Length > 0 && !string.Equals(c.Marka, mrk, StringComparison.OrdinalIgnoreCase)) return false;
                if (mdl.Length > 0 && !string.Equals(c.Model, mdl, StringComparison.OrdinalIgnoreCase)) return false;
                if (k0 > 0 && c.Kapsam != k0 && Isler(c).All(e => e.Kapsam != k0)) return false;
                if (tek > 0 && Isler(c).All(e => e.YapanId != tek) && Ziyaretler(c).All(z => z.TeknisyenId != tek)) return false;
                return true;
            }
            var tumCagri = hamCagri.Where(Uyar).ToList();
            var donem = tumCagri.Where(c => c.Donemde).ToList();
            var gecerli = donem.Where(c => !c.Iptal).ToList();
            var acik = tumCagri.Where(c => c.Acik).ToList();
            // Tutar tarafı: dönem çağrılarının iptal edilmemiş iş emirleri (kapsam süzgeciyle).
            var isler = gecerli.SelectMany(Isler).Where(e => e.Durum != 8 && (k0 == 0 || e.Kapsam == k0)).ToList();
            var isIdSet = isler.Select(e => e.Id).ToHashSet();
            var isMap = isler.ToDictionary(e => e.Id);
            var cagriMap = tumCagri.ToDictionary(c => c.Anahtar);
            var ziyaretler = hamZiyaret.Where(z => isIdSet.Contains(z.IsEmriId) && z.Sonuc != 4).ToList();
            var parcalar = hamParca.Where(p => isIdSet.Contains(p.IsEmriId)).ToList();

            // ------------------------------------------------------ tekrar arıza --
            var tekrarHam = await b.ListeAsync(TekrarSorgusu, null,
                [gecerli.Where(c => !c.IsEmriKendisi && c.CihazId > 0).Select(c => c.Id).ToArray(), tekrarGun],
                o => (cagri: o.GetInt64(0), onceki: o.GetInt64(1), oncekiNo: o.GetString(2), teknisyen: o.GetInt32(3)), iptal);
            var tekrar = tekrarHam.ToDictionary(x => "c" + x.cagri);

            // İlk ziyaret / kapatan teknisyen (çağrı başına).
            var ilkSonuclu = new Dictionary<string, Ziyaret>();
            var ilkZiyaret = new Dictionary<string, Ziyaret>();
            var kapatan = new Dictionary<string, Ziyaret>();
            foreach (var c in gecerli)
            {
                var zl = Ziyaretler(c).Where(z => isIdSet.Contains(z.IsEmriId)).ToList();
                if (zl.Count > 0) ilkZiyaret[c.Anahtar] = zl[0];
                var ilk = zl.FirstOrDefault(z => z.Sonuclu);
                if (ilk is not null) ilkSonuclu[c.Anahtar] = ilk;
                var son = zl.LastOrDefault(z => z.Sonuc == 1);
                if (son is not null && c.Durum == 5) kapatan[c.Anahtar] = son;
            }

            var tekIdler = ziyaretler.Select(z => z.TeknisyenId).Concat(tekrarHam.Select(x => x.teknisyen));
            var servisTeknisyenleri = await b.ListeAsync("select taraf_id, ad::text from public.v_servis_teknisyen order by ad", null, [],
                o => (id: o.GetInt32(0), ad: o.IsDBNull(1) ? "" : o.GetString(1)), iptal);
            var teknisyenler = await TeknisyenlerAsync(b, tekIdler, iptal);
            string TekAd(int id) => id <= 0 ? "(atanmamış)" : teknisyenler.TryGetValue(id, out var t) ? t.ad
                : servisTeknisyenleri.FirstOrDefault(x => x.id == id).ad ?? $"#{id}";

            // ----------------------------------------------------------- özet --
            var olculen = gecerli.Where(c => c.SlaBitis is not null).ToList();
            var ihlalli = olculen.Where(c => Ihlal(c, simdi)).ToList();
            var yanitSaat = gecerli.Where(c => c.IlkYanit is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.IlkYanit!.Value))).ToList();
            var cozumSaat = gecerli.Where(c => c.Durum == 5 && c.Kapanis is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.Kapanis!.Value))).ToList();
            var sonuclanan = gecerli.Count(c => ilkSonuclu.ContainsKey(c.Anahtar));
            var ilkteCozulen = gecerli.Count(c => ilkSonuclu.TryGetValue(c.Anahtar, out var z) && z.Sonuc == 1);
            var ikinciZiyaret = gecerli.Count(c => Ziyaretler(c).Count(z => isIdSet.Contains(z.IsEmriId)) >= 2);
            var cihazli = gecerli.Count(c => c.CihazId > 0);
            var ciroIs = isler.Where(e => e.Ciro).ToList();
            var maliyetIs = isler.Where(e => !e.Ciro).ToList();
            var faturasizHam = await b.ListeAsync("""
                select e.id, coalesce(e.is_emri_no, '')::text, coalesce(e.tamamlanma, e.degistirme_tarihi, e.ekleme_tarihi),
                       coalesce(e.musteri_taraf_id, 0), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')::text,
                       e.kapsam_tur::smallint, e.iscilik_tutar, e.parca_tutar, e.diger_tutar, e.toplam_tutar,
                       (current_date - coalesce(e.tamamlanma, e.degistirme_tarihi, e.ekleme_tarihi)::date)::int,
                       coalesce(tc.marka, '')::text, coalesce(tc.model, '')::text
                  from public.demirbas_is_emri e
                  left join public.taraf t on t.id = e.musteri_taraf_id
                  left join public.taraf_cihaz tc on tc.id = e.taraf_cihaz_id
                 where @p5 in (0, 2) and e.sahiplik = 2 and e.durum = 5 and e.belge_id is null
                   and e.kapsam_tur in (1, 3) and e.toplam_tutar > 0
                   and coalesce(e.tamamlanma, e.degistirme_tarihi, e.ekleme_tarihi) < @p0::date + 1
                   and (e.sube_id = 0 or e.sube_id = any(@p1::int[])) and (@p2 = 0 or e.sube_id = @p2)
                   and (cardinality(@p3::int[]) = 0 or e.musteri_taraf_id = any(@p3::int[]))
                   and (@p4 = 0 or e.musteri_taraf_id = @p4)
                 order by 3
                """, null, [bitis, subeler, s0, cariKapsam, mus, sah], o => new
            {
                id = o.GetInt64(0), no = o.GetString(1), kapanis = o.GetDateTime(2), tarafId = o.GetInt32(3), taraf = o.GetString(4),
                kapsamKod = o.GetInt16(5), iscilik = o.GetDecimal(6), parca = o.GetDecimal(7), diger = o.GetDecimal(8),
                toplam = o.GetDecimal(9), gun = o.GetInt32(10), marka = o.GetString(11), model = o.GetString(12),
            }, iptal);
            var faturasizL = faturasizHam
                .Where(x => (k0 == 0 || x.kapsamKod == k0)
                            && (mrk.Length == 0 || string.Equals(x.marka, mrk, StringComparison.OrdinalIgnoreCase))
                            && (mdl.Length == 0 || string.Equals(x.model, mdl, StringComparison.OrdinalIgnoreCase)))
                .Select(x => new
                {
                    x.id, x.no, x.kapanis, x.tarafId, x.taraf, kapsam = KapsamAdlari.GetValueOrDefault(x.kapsamKod, ""),
                    uretici = x.kapsamKod == 3, iscilik = R(x.iscilik), parca = R(x.parca), diger = R(x.diger), toplam = R(x.toplam), x.gun,
                }).ToList();

            var ozet = new
            {
                cagri = donem.Count, kapanan = donem.Count(c => c.Durum == 5), iptal = donem.Count(c => c.Iptal),
                isEmri = isler.Count, ziyaret = ziyaretler.Count,
                acik = acik.Count, parcaBekliyor = acik.Count(c => c.Durum == 4), atanmamis = acik.Count(c => c.Durum == 0),
                ilkYanitSaat = Ort(yanitSaat), ilkYanitMedyan = Medyan(yanitSaat), cozumSaat = Ort(cozumSaat),
                slaOlculen = olculen.Count, slaIhlal = ihlalli.Count, slaIhlalOran = Yuzde(ihlalli.Count, olculen.Count),
                slaIhlalAcik = ihlalli.Count(c => c.Acik), slaAsanAcik = acik.Count(c => Ihlal(c, simdi)),
                ilkZiyaretCozum = Yuzde(ilkteCozulen, sonuclanan), ilkZiyaretSayi = sonuclanan, ikinciZiyaret,
                tekrarGun, tekrar = tekrar.Count, tekrarOran = Yuzde(tekrar.Count, cihazli),
                ciro = R(ciroIs.Sum(e => e.Toplam)), ciroIscilik = R(ciroIs.Sum(e => e.Iscilik)), ciroParca = R(ciroIs.Sum(e => e.Parca)),
                ciroDiger = R(ciroIs.Sum(e => e.Diger)),
                maliyet = R(maliyetIs.Sum(e => e.Toplam)),
                maliyetSozlesme = R(maliyetIs.Where(e => e.Sahiplik == 2 && e.Kapsam == 2).Sum(e => e.Toplam)),
                maliyetGaranti = R(maliyetIs.Where(e => e.Sahiplik == 2 && e.Kapsam == 4).Sum(e => e.Toplam)),
                maliyetIc = R(maliyetIs.Where(e => e.Sahiplik == 1).Sum(e => e.Toplam)),
                faturasiz = faturasizL.Count, faturasizTutar = R(faturasizL.Sum(x => x.toplam)),
                teknisyen = ziyaretler.Select(z => z.TeknisyenId).Where(x => x > 0).Distinct().Count(),
            };

            // ---------------------------------------------------------- kapsam --
            var kapsamSatir = new List<object>();
            foreach (var k in new short[] { 1, 2, 3, 4 })
            {
                var ie = isler.Where(e => e.Sahiplik == 2 && e.Kapsam == k).ToList();
                var cg = gecerli.Count(c => c.Sahiplik == 2 && c.Kapsam == k);
                if (sah == 1 || (ie.Count == 0 && cg == 0 && k0 > 0 && k != k0)) continue;
                kapsamSatir.Add(new
                {
                    kod = (int)k, ad = $"{k} · {KapsamAdlari[k]}", cagri = cg, isEmri = ie.Count,
                    iscilik = R(ie.Sum(e => e.Iscilik)), parca = R(ie.Sum(e => e.Parca)), diger = R(ie.Sum(e => e.Diger)),
                    toplam = R(ie.Sum(e => e.Toplam)), kime = KapsamKime[k], ciro = k is 1 or 3,
                });
            }
            var icIs = isler.Where(e => e.Sahiplik == 1).ToList();
            if (sah != 2)
                kapsamSatir.Add(new
                {
                    kod = 0, ad = "İç iş (demirbaş)", cagri = gecerli.Count(c => c.Sahiplik == 1), isEmri = icIs.Count,
                    iscilik = R(icIs.Sum(e => e.Iscilik)), parca = R(icIs.Sum(e => e.Parca)), diger = R(icIs.Sum(e => e.Diger)),
                    toplam = R(icIs.Sum(e => e.Toplam)), kime = "birim maliyeti", ciro = false,
                });
            var kapsamToplam = new
            {
                cagri = gecerli.Count, isEmri = isler.Count, iscilik = R(isler.Sum(e => e.Iscilik)), parca = R(isler.Sum(e => e.Parca)),
                diger = R(isler.Sum(e => e.Diger)), toplam = R(isler.Sum(e => e.Toplam)),
            };

            var durumlar = CagriDurumlari.Where(d => d.Key <= 4 || acik.Any(c => c.Durum == d.Key)).Select(d => new
            {
                kod = (int)d.Key, ad = d.Key == 6 ? d.Value : $"{d.Key} · {d.Value}", adet = acik.Count(c => c.Durum == d.Key),
                slaAsan = acik.Count(c => c.Durum == d.Key && Ihlal(c, simdi)),
            }).ToList();

            var oncelikler = gecerli.GroupBy(c => c.Oncelik).OrderBy(g => g.Key).Select(g => new
            {
                kod = (int)g.Key, ad = $"{g.Key} · {OncelikAdlari.GetValueOrDefault(g.Key, "Diğer")}", cagri = g.Count(),
                ilkYanitSaat = Ort(g.Where(c => c.IlkYanit is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.IlkYanit!.Value)))),
                cozumSaat = Ort(g.Where(c => c.Durum == 5 && c.Kapanis is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.Kapanis!.Value)))),
                slaIhlal = g.Count(c => Ihlal(c, simdi)),
            }).ToList();

            // ------------------------------------------------------- teknisyen --
            var parcaZiyaret = parcalar.Where(p => p.ZiyaretId > 0).GroupBy(p => p.ZiyaretId).ToDictionary(g => g.Key, g => g.ToList());
            var tekKumesi = ziyaretler.Select(z => z.TeknisyenId)
                .Concat(ihlalli.Select(c => ilkZiyaret.TryGetValue(c.Anahtar, out var z) ? z.TeknisyenId : 0))
                .Concat(tekrar.Values.Select(x => x.teknisyen)).Distinct().ToList();
            var teknisyenSatir = tekKumesi.Select(t =>
            {
                var zl = ziyaretler.Where(z => z.TeknisyenId == t).ToList();
                var ilkler = ilkSonuclu.Where(kv => kv.Value.TeknisyenId == t).ToList();
                var puanli = zl.Where(z => z.Puan is not null).ToList();
                var ciro = zl.Where(z => isMap[z.IsEmriId].Ciro)
                    .Sum(z => z.Tutar + (parcaZiyaret.GetValueOrDefault(z.Id) ?? []).Sum(p => p.Tutar));
                return new
                {
                    id = t, ad = TekAd(t), ziyaret = zl.Count,
                    cozulen = kapatan.Count(kv => kv.Value.TeknisyenId == t),
                    ilkZiyaretCozum = Yuzde(ilkler.Count(kv => kv.Value.Sonuc == 1), ilkler.Count), ilkZiyaretSayi = ilkler.Count,
                    iscilikSaat = R(zl.Sum(z => z.Saat)), yolKm = R1(zl.Sum(z => z.YolKm)),
                    slaIhlal = ihlalli.Count(c => (ilkZiyaret.TryGetValue(c.Anahtar, out var z) ? z.TeknisyenId : 0) == t),
                    tekrar = tekrar.Values.Count(x => x.teknisyen == t),
                    ciro = R(ciro), imzasiz = zl.Count(z => z.Sonuclu && !z.Imza),
                    memnuniyet = puanli.Count > 0 ? Math.Round((decimal)puanli.Average(z => (int)z.Puan!.Value), 1) : (decimal?)null,
                    puanSayisi = puanli.Count,
                    ziyaretSayisi = zl.Count,
                    ziyaretler = zl.OrderByDescending(z => z.Varis ?? z.Ayrilis).Take(60).Select(z =>
                    {
                        var e = isMap[z.IsEmriId];
                        var c = cagriMap.GetValueOrDefault(e.CagriAnahtar);
                        return new
                        {
                            id = z.Id, isEmriId = e.Id, isEmriNo = e.No, tarih = z.Varis ?? z.Ayrilis, taraf = c?.Taraf ?? "",
                            cihaz = c?.Cihaz ?? "", sonuc = ZiyaretSonuclari.GetValueOrDefault(z.Sonuc, ""), saat = z.Saat,
                            tutar = R(z.Tutar), puan = z.Puan, imzasiz = z.Sonuclu && !z.Imza,
                        };
                    }).ToList(),
                };
            }).OrderBy(x => x.id <= 0 ? 1 : 0).ThenByDescending(x => x.ziyaret).ToList();
            var tumPuan = ziyaretler.Where(z => z.Puan is not null).ToList();
            var teknisyenToplam = new
            {
                ziyaret = ziyaretler.Count, cozulen = kapatan.Count, ilkZiyaretCozum = ozet.ilkZiyaretCozum,
                iscilikSaat = R(ziyaretler.Sum(z => z.Saat)), yolKm = R1(ziyaretler.Sum(z => z.YolKm)), slaIhlal = ihlalli.Count,
                tekrar = tekrar.Count, ciro = R(teknisyenSatir.Sum(x => x.ciro)), imzasiz = ziyaretler.Count(z => z.Sonuclu && !z.Imza),
                memnuniyet = tumPuan.Count > 0 ? Math.Round((decimal)tumPuan.Average(z => (int)z.Puan!.Value), 1) : (decimal?)null,
                puanSayisi = tumPuan.Count,
                // Ziyarete bağlanmamış parça ve "diğer" tutarı teknisyene yazılmaz - ciro kutusuyla farkı bu.
                atanmamisCiro = R(ozet.ciro - teknisyenSatir.Sum(x => x.ciro)),
            };

            // ------------------------------------------------------ cihaz / model --
            var parkHam = sah == 1 ? [] : await b.ListeAsync("""
                select coalesce(c.marka, '')::text, coalesce(c.model, '')::text, count(*)::int
                  from public.taraf_cihaz c
                 where c.durum = 1
                   and (c.sube_id = 0 or c.sube_id = any(@p0::int[])) and (@p1 = 0 or c.sube_id = @p1)
                   and (cardinality(@p2::int[]) = 0 or c.taraf_id = any(@p2::int[])) and (@p3 = 0 or c.taraf_id = @p3)
                 group by 1, 2
                """, null, [subeler, s0, cariKapsam, mus], o => (marka: o.GetString(0), model: o.GetString(1), adet: o.GetInt32(2)), iptal);
            var park = parkHam.GroupBy(x => (x.marka.ToUpperInvariant(), x.model.ToUpperInvariant())).ToDictionary(g => g.Key, g => g.Sum(x => x.adet));
            var parcaIs = parcalar.GroupBy(p => p.IsEmriId).ToDictionary(g => g.Key, g => g.Sum(p => p.Tutar));
            var cihazSatir = gecerli.GroupBy(c => (c.Marka.ToUpperInvariant(), c.Model.ToUpperInvariant())).Select(g =>
            {
                var ilk = g.First();
                var ie = g.SelectMany(c => Isler(c)).Where(e => isIdSet.Contains(e.Id)).ToList();
                var arizalar = ie.Select(Ariza).Where(a => a.anahtar != "-").GroupBy(a => a.anahtar)
                    .OrderByDescending(x => x.Count()).ToList();
                var p = park.GetValueOrDefault(g.Key);
                var cs = g.Where(c => c.Durum == 5 && c.Kapanis is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.Kapanis!.Value)));
                return new
                {
                    marka = ilk.Marka.Length > 0 ? ilk.Marka : ilk.Model.Length > 0 ? "" : "(marka / model yok)", model = ilk.Model,
                    park = p > 0 ? p : (int?)null, cagri = g.Count(), arizaCihaz = p > 0 ? Math.Round((decimal)g.Count() / p, 2) : (decimal?)null,
                    tekrar = g.Count(c => tekrar.ContainsKey(c.Anahtar)),
                    enSikAriza = arizalar.Count > 0 ? arizalar[0].First().ad : "", enSikAdet = arizalar.Count > 0 ? arizalar[0].Count() : 0,
                    enSikKodlu = arizalar.Count > 0 && arizalar[0].First().kodlu,
                    cozumSaat = Ort(cs), parcaTutar = R(ie.Sum(e => parcaIs.GetValueOrDefault(e.Id))),
                };
            }).OrderByDescending(x => x.cagri).ThenBy(x => x.marka).ToList();
            var arizaSatir = isler.Select(e => (e, a: Ariza(e))).Where(x => x.a.anahtar != "-").GroupBy(x => x.a.anahtar).Select(g => new
            {
                ad = g.First().a.ad, kodlu = g.First().a.kodlu, isEmri = g.Count(),
                cagri = g.Select(x => x.e.CagriAnahtar).Distinct().Count(),
                markaModel = string.Join(" · ", g.Select(x => cagriMap.GetValueOrDefault(x.e.CagriAnahtar)?.MarkaModel ?? "")
                    .Where(m => m.Length > 0).GroupBy(m => m).OrderByDescending(m => m.Count()).Take(2).Select(m => m.Key)),
            }).OrderByDescending(x => x.isEmri).Take(50).ToList();
            var kodluIs = isler.Count(e => e.ArizaKoduId > 0);

            // --------------------------------------------------------------- SLA --
            var sozIdleri = gecerli.Where(c => c.SozlesmeId > 0).Select(c => c.SozlesmeId).Distinct().ToArray();
            var sozlesmeler = sah == 1 ? [] : await b.ListeAsync("""
                select s.id, coalesce(nullif(s.sozlesme_no::text, ''), '#' || s.id)::text, s.taraf_id,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')::text, s.kapsam::smallint, s.sla_saat::int,
                       s.baslangic, s.bitis, s.yillik_bedel, s.durum::smallint,
                       (s.baslangic <= @p1::date and s.bitis >= @p0::date and s.durum = 1
                        and (s.sube_id = 0 or s.sube_id = any(@p2::int[])) and (@p3 = 0 or s.sube_id = @p3)
                        and (cardinality(@p4::int[]) = 0 or s.taraf_id = any(@p4::int[])) and (@p5 = 0 or s.taraf_id = @p5))
                  from public.servis_sozlesme s
                  left join public.taraf t on t.id = s.taraf_id
                 where s.id = any(@p6::int[])
                    or (s.baslangic <= @p1::date and s.bitis >= @p0::date and s.durum = 1
                        and (s.sube_id = 0 or s.sube_id = any(@p2::int[])) and (@p3 = 0 or s.sube_id = @p3)
                        and (cardinality(@p4::int[]) = 0 or s.taraf_id = any(@p4::int[])) and (@p5 = 0 or s.taraf_id = @p5))
                 order by 2
                """, null, [baslangic, bitis, subeler, s0, cariKapsam, mus, sozIdleri], o => (
                    id: o.GetInt32(0), no: o.GetString(1), tarafId: o.GetInt32(2), taraf: o.GetString(3), kapsam: o.GetInt16(4),
                    sla: o.GetInt32(5), bas: o.GetDateTime(6), bit: o.GetDateTime(7), bedel: o.GetDecimal(8), durum: o.GetInt16(9),
                    donemde: o.GetBoolean(10)), iptal);
            var sozMap = sozlesmeler.ToDictionary(s => s.id);
            var slaSatir = olculen.GroupBy(c => c.SozlesmeId).Select(g =>
            {
                sozMap.TryGetValue(g.Key, out var s);
                var ih = g.Where(c => Ihlal(c, simdi)).ToList();
                var oran = Yuzde(ih.Count, g.Count()) ?? 0;
                return new
                {
                    sozlesmeId = g.Key, no = g.Key > 0 ? s.no ?? $"#{g.Key}" : "(sözleşmesiz · kurum SLA'sı)",
                    taraf = g.Key > 0 ? s.taraf ?? g.First().Taraf : "",
                    kapsam = g.Key > 0 ? SozlesmeKapsamlari.GetValueOrDefault(s.kapsam, "") : "",
                    slaSaat = g.Key > 0 && s.id > 0 ? s.sla : (int?)null,
                    cagri = g.Count(),
                    ilkYanitSaat = Ort(g.Where(c => c.IlkYanit is not null).Select(c => Math.Max(0, SaatFark(c.Acilis, c.IlkYanit!.Value)))),
                    ihlal = ih.Count, acikIhlal = ih.Count(c => c.Acik),
                    enUzunGecikme = ih.Count > 0 ? R1(ih.Max(c => Gecikme(c, simdi) ?? 0)) : (decimal?)null,
                    durum = ih.Count == 0 ? "uygun" : oran < 10 ? "sinirda" : "ihlal",
                };
            }).OrderByDescending(x => x.ihlal).ThenByDescending(x => x.cagri).ToList();
            var slaIhlalListe = ihlalli.OrderByDescending(c => Gecikme(c, simdi)).Take(100).Select(c => new
            {
                anahtar = c.Anahtar, id = c.Id, no = c.No, taraf = c.Taraf, cihaz = c.Cihaz, acilis = c.Acilis, slaBitis = c.SlaBitis,
                ilkYanit = c.IlkYanit, gecikmeSaat = R1(Gecikme(c, simdi) ?? 0), acik = c.Acik,
                sozlesme = c.SozlesmeId > 0 && sozMap.TryGetValue(c.SozlesmeId, out var s) ? s.no : "",
            }).ToList();

            // -------------------------------------------------------------- parça --
            var maliyet = await MaliyetAsync(b, parcalar.Select(p => p.StokId), iptal);
            var parcaSatir = parcalar.GroupBy(p => p.Anahtar).Select(g =>
            {
                var ilk = g.First();
                decimal Top(Func<Parca, bool> f) => R(g.Where(f).Sum(p => p.Tutar));
                var uretici = g.Where(p => isMap[p.IsEmriId] is { Sahiplik: 2, Kapsam: 3 }).ToList();
                var mal = ilk.StokId > 0 && maliyet.TryGetValue(ilk.StokId, out var m) && m > 0 ? R(g.Sum(p => p.Miktar) * m) : (decimal?)null;
                return new
                {
                    anahtar = g.Key, stokId = ilk.StokId, kod = ilk.Kod, ad = ilk.Ad, miktar = g.Sum(p => p.Miktar), maliyet = mal,
                    tutar = Top(_ => true),
                    faturalanan = Top(p => isMap[p.IsEmriId] is { Ciro: true, BelgeId: > 0 }),
                    faturalanmayan = Top(p => isMap[p.IsEmriId] is { Ciro: true, BelgeId: 0, Durum: 5 }),
                    sozlesmeGaranti = Top(p => !isMap[p.IsEmriId].Ciro),
                    iadeBekliyor = uretici.Count(p => p.IadeDurum == 0), iadeGeciken = uretici.Count(p => p.IadeDurum == 0 && p.Gun > 15),
                    iadeToplandi = uretici.Count(p => p.IadeDurum != 0),
                };
            }).OrderByDescending(x => x.tutar).ToList();
            var parcaToplam = new
            {
                kalem = parcaSatir.Count, miktar = parcaSatir.Sum(x => x.miktar), maliyet = R(parcaSatir.Sum(x => x.maliyet ?? 0)),
                tutar = R(parcaSatir.Sum(x => x.tutar)), faturalanan = R(parcaSatir.Sum(x => x.faturalanan)),
                faturalanmayan = R(parcaSatir.Sum(x => x.faturalanmayan)), sozlesmeGaranti = R(parcaSatir.Sum(x => x.sozlesmeGaranti)),
                iadeBekliyor = parcaSatir.Sum(x => x.iadeBekliyor), iadeGeciken = parcaSatir.Sum(x => x.iadeGeciken),
            };

            // ------------------------------------------------------------- emanet --
            var emanetler = await b.ListeAsync("""
                select m.id, coalesce(m.emanet_no, '')::text, coalesce(m.cihaz_metni, '')::text,
                       coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::text, '')::text, coalesce(m.taraf_id, 0),
                       coalesce(e.id, 0), coalesce(e.is_emri_no, '')::text, m.veris, (current_date - m.veris::date)::int,
                       coalesce(e.durum, -1)::smallint
                  from public.servis_emanet m
                  left join public.demirbas_is_emri e on e.id = m.is_emri_id
                  left join public.taraf t on t.id = m.taraf_id
                 where m.durum = 1
                   and (m.sube_id = 0 or m.sube_id = any(@p0::int[])) and (@p1 = 0 or m.sube_id = @p1)
                   and (@p2 = 0 or coalesce(e.sahiplik, 2) = @p2)
                   and (cardinality(@p3::int[]) = 0 or m.taraf_id is null or m.taraf_id = any(@p3::int[]))
                   and (@p4 = 0 or m.taraf_id = @p4)
                 order by m.veris
                """, null, [subeler, s0, sah, cariKapsam, mus], o =>
            {
                var d = o.GetInt16(9);
                return new
                {
                    id = o.GetInt64(0), no = o.GetString(1), cihaz = o.GetString(2), taraf = o.GetString(3), tarafId = o.GetInt32(4),
                    isEmriId = o.GetInt64(5), isEmriNo = o.GetString(6), veris = o.GetDateTime(7), gun = o.GetInt32(8),
                    isEmriDurum = d == 5 ? "çözüldü · iade bekleniyor" : IsEmriDurumlari.GetValueOrDefault(d, ""),
                    iadeBekleniyor = d == 5,
                };
            }, iptal);

            // ------------------------------------------------- sözleşme kârlılığı --
            var karSozler = sozlesmeler.Where(s => s.donemde).ToList();
            var karIdler = karSozler.Select(s => s.id).ToArray();
            var sozIs = karIdler.Length == 0 ? []
                : await b.ListeAsync("""
                    select e.id, e.sozlesme_id, e.iscilik_tutar, e.parca_tutar, e.diger_tutar
                      from public.demirbas_is_emri e
                     where e.sozlesme_id = any(@p0::int[]) and e.kapsam_tur = 2 and e.durum <> 8 and e.bildirim_zamani < current_date + 1
                    """, null, [karIdler], o => (id: o.GetInt64(0), soz: o.GetInt32(1), isc: o.GetDecimal(2), prc: o.GetDecimal(3),
                        dgr: o.GetDecimal(4)), iptal);
            var sozZiy = sozIs.Count == 0 ? []
                : await b.ListeAsync("""
                    select z.is_emri_id, coalesce(z.teknisyen_id, 0), z.iscilik_saat, z.tutar
                      from public.servis_ziyaret z where z.is_emri_id = any(@p0::bigint[]) and z.sonuc <> 4
                    """, null, [sozIs.Select(x => x.id).ToArray()],
                    o => (isEmri: o.GetInt64(0), tek: o.GetInt32(1), saat: o.GetDecimal(2), tutar: o.GetDecimal(3)), iptal);
            var sozTek = await TeknisyenlerAsync(b, sozZiy.Select(z => z.tek), iptal);
            var sozIsMap = sozIs.ToDictionary(x => x.id, x => x.soz);
            var sozlesmeSatir = karSozler.Select(s =>
            {
                var gun = Math.Max(1, (int)(s.bit.Date - s.bas.Date).TotalDays + 1);
                var gecen = Math.Clamp((int)((bugun < s.bit.Date ? bugun : s.bit.Date) - s.bas.Date).TotalDays + 1, 0, gun);
                var pay = R(s.bedel * gecen / gun);
                var zl = sozZiy.Where(z => sozIsMap.GetValueOrDefault(z.isEmri) == s.id).ToList();
                decimal isc = 0; var tarifeli = 0;
                foreach (var z in zl)
                {
                    var sm = sozTek.TryGetValue(z.tek, out var t) ? t.saatMaliyet : 0m;
                    if (sm > 0 && z.saat > 0) isc += z.saat * sm;
                    else { isc += z.tutar; if (z.tutar != 0 || z.saat > 0) tarifeli++; }
                }
                var il = sozIs.Where(x => x.soz == s.id).ToList();
                // Ziyareti olmayan işçilik (elle yazılmış işçilik tutarı) tarife olarak eklenir.
                var ziyaretsizIsc = il.Where(x => zl.All(z => z.isEmri != x.id)).Sum(x => x.isc);
                if (ziyaretsizIsc != 0) tarifeli++;
                isc += ziyaretsizIsc;
                var prc = il.Sum(x => x.prc);
                var dgr = il.Sum(x => x.dgr);
                var kar = pay - isc - prc - dgr;
                return new
                {
                    id = s.id, no = s.no, tarafId = s.tarafId, taraf = s.taraf, kapsam = SozlesmeKapsamlari.GetValueOrDefault(s.kapsam, ""),
                    bas = s.bas, bit = s.bit, yillikBedel = R(s.bedel), gecenGun = gecen, toplamGun = gun, gecenPay = pay,
                    isEmri = il.Count, iscilik = R(isc), parca = R(prc), diger = R(dgr), kar = R(kar),
                    karOran = pay != 0 ? Math.Round(100m * kar / pay, 1) : (decimal?)null,
                    tarifeli, zarar = kar < 0,
                };
            }).OrderBy(x => x.kar).ToList();
            var sozlesmeToplam = new
            {
                sozlesme = sozlesmeSatir.Count, yillikBedel = R(sozlesmeSatir.Sum(x => x.yillikBedel)), gecenPay = R(sozlesmeSatir.Sum(x => x.gecenPay)),
                iscilik = R(sozlesmeSatir.Sum(x => x.iscilik)), parca = R(sozlesmeSatir.Sum(x => x.parca)), diger = R(sozlesmeSatir.Sum(x => x.diger)),
                kar = R(sozlesmeSatir.Sum(x => x.kar)), zarardaki = sozlesmeSatir.Count(x => x.zarar),
                karOran = sozlesmeSatir.Sum(x => x.gecenPay) != 0
                    ? Math.Round(100m * sozlesmeSatir.Sum(x => x.kar) / sozlesmeSatir.Sum(x => x.gecenPay), 1) : (decimal?)null,
            };

            // ----------------------------------------------------------- seçimler --
            var secimTeknisyen = servisTeknisyenleri.Select(x => (x.id, x.ad))
                .Concat(teknisyenler.Select(kv => (id: kv.Key, ad: kv.Value.ad)))
                .GroupBy(x => x.id).Select(g => new { id = g.Key, ad = g.First().ad }).OrderBy(x => x.ad).ToList();

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, sube = s0, teknisyen = tek, musteri = mus, marka = mrk, model = mdl,
                kapsam = (int)k0, sahiplik = sah, tekrarGun,
                ozet, kapsamlar = kapsamSatir, kapsamToplam, durumlar, oncelikler,
                teknisyenler = teknisyenSatir, teknisyenToplam,
                cihazlar = cihazSatir, arizalar = arizaSatir, arizaKodlu = kodluIs, arizaKodsuz = isler.Count - kodluIs,
                sla = new { satirlar = slaSatir, ihlaller = slaIhlalListe, slasiz = gecerli.Count(c => c.SlaBitis is null && !c.IsEmriKendisi) },
                parcalar = parcaSatir, parcaToplam,
                emanetler,
                sozlesmeler = sozlesmeSatir, sozlesmeToplam,
                faturasiz = new { sayi = faturasizL.Count, tutar = R(faturasizL.Sum(x => x.toplam)), liste = faturasizL.Take(200).ToList() },
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    teknisyenler = secimTeknisyen, musteriler = secimMusteri, markalar = secimMarka,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
