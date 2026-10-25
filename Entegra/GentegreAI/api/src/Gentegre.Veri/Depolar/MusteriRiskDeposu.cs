using System.Globalization;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// MÜŞTERİ RİSKİ (1178, mockup Ekranlar/İcmal/musteri_risk_icmali.html - kararlar 25.10.2026).
///
/// <para><b>Risk</b> = açık cari bakiye + portföydeki müşteri çek / senedi + faturası kesilmemiş
/// irsaliye + açık satış siparişi. Her bileşen KENDİ icmalinin kuralıyla, ikinci kural yazılmadan:</para>
/// <list type="bullet">
/// <item><b>Bakiye</b> - Cari İcmali / Cari Ekstre kümesi: <c>v_cari_ekstre</c>, bakiyeye dahil
///   satırlar, bugüne kadar. Dövizli hareket kendi dövizindeki bakiye × BUGÜNKÜ kur (karar: risk bugünün
///   parasıdır); kur yoksa hareketin kendi kuruyla TL.</item>
/// <item><b>Çek / senet</b> - Çek / Senet İcmali'nin risk kümesi: alınan (yon 1) ve portföyde / tahsilde /
///   teminatta (10, 30, 40) - ciro edilmiş (20) çıkar - ve vadesi gelmemiş. Değer bugünkü kurla, yoksa
///   alış kuruyla (aynı ekranın değer kuralı).</item>
/// <item><b>Faturasız irsaliye</b> - İrsaliye-Fatura Eşleşme kuralı: satış irsaliyesi + giden konsinye
///   (14, 119), kesin, iade (tipi 2) hariç; hiç faturalanmamışsa belge matrahı, kısmi faturalanmışsa
///   satır tutarı × kalan / miktar (kesin hedef satırlar, belge_satir.kaynak_tur = 30). KDV hariç.</item>
/// <item><b>Açık sipariş</b> - Açık Satır Listesi kuralı (<c>v_belge_acik_satir</c>) + "kalanı kapat"
///   kaydı olmayan satır; tutar Sipariş İcmali gibi belge matrahının satıra düşen payı × kalan / miktar.
///   Başvuru (19 / tipi 30) hariç. KDV hariç.</item>
/// </list>
/// <para>Şube süzgeci (boş dizi = süzgeç yok) çek / irsaliye / siparişe uygulanır; cari bakiye
/// şubeler arası ortaktır (Cari İcmali ile aynı). Limit TL karşılığı: limit dövizinin bugünkü kuruyla
/// (dövizli limit kendi dövizinde karşılaştırılır = TL'ye aynı kurla çevrilip).</para>
/// </summary>
public static class MusteriRiskDeposu
{
    /// <summary>@p0 taraf kimlikleri · @p1 bugün · @p2 şubeler (boş = hepsi).</summary>
    public const string RiskSorgusu = """
        with y as materialized (
            select public.fn_doviz_iso(public.fn_yerel_para())::varchar(6) as yerel
        ),
        tr as materialized (
            select t.id, t.risk_limit,
                   public.fn_doviz_iso(coalesce(nullif(btrim(t.risk_limit_doviz), ''), y.yerel))::varchar(6) as limit_doviz,
                   coalesce(t.sevk_blokesi, 0) as sevk_blokesi, coalesce(t.sevk_blokesi_neden, '') as sevk_blokesi_neden,
                   t.sevk_blokesi_kim, t.sevk_blokesi_an, coalesce(t.risk_grubu, '') as risk_grubu, t.xmin::text as surum
              from public.taraf t cross join y
             where t.id = any(@p0::int[])
        ),
        bak as (
            select g.taraf_id,
                   sum(case when g.para = y.yerel then g.yb else coalesce(round(g.b * k.kur, 2), g.yb) end) as bakiye,
                   bool_or(g.para <> y.yerel and k.kur is null) as kur_yok
              from (select e.taraf_id, public.fn_doviz_iso(coalesce(nullif(btrim(e.doviz_cinsi), ''), 'TL'))::varchar(6) as para,
                           sum(e.borc - e.alacak) as b, sum(e.yerel_borc - e.yerel_alacak) as yb
                      from public.v_cari_ekstre e
                     where e.bakiye_dahil = 1 and e.taraf_id = any(@p0::int[]) and e.islem_tarihi < (@p1::date + 1)
                     group by 1, 2) g
              cross join y
              cross join lateral (select case when g.para = y.yerel then 1::numeric
                                              else public.fn_doviz_kur_getir(g.para, @p1::date, 2::smallint) end as kur) k
             group by g.taraf_id
        ),
        cek as (
            select c.taraf_id, count(*)::int as adet, min(c.vade) as ilk_vade, sum(d.deger) as tutar,
                   coalesce(sum(d.deger) filter (where c.vade < @p1::date + 8), 0) as yedi_gun
              from public.cek_senet c
              cross join y
              cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(c.doviz_cinsi), ''), 'TL'))::varchar(6) as para) p
              cross join lateral (select case when p.para = y.yerel then c.tutar
                                              else round(c.tutar * coalesce(public.fn_doviz_kur_getir(p.para, @p1::date, 2::smallint),
                                                                           nullif(c.doviz_kuru, 0), 1), 2) end as deger) d
             where c.yon = 1 and c.durum in (10, 30, 40) and c.vade >= @p1::date
               and c.taraf_id = any(@p0::int[])
               and (cardinality(@p2::int[]) = 0 or c.sube_id = any(@p2::int[]))
             group by c.taraf_id
        ),
        irs_s as (
            select b.id, b.taraf_id, coalesce(b.matrah, 0) as matrah, coalesce(s.miktar, 0) as miktar,
                   coalesce(s.tutar, 0) as tutar, coalesce(h.m, 0) as fm, k.kur
              from public.belge b
              join public.belge_satir s on s.belge_id = b.id
              cross join y
              cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), y.yerel))::varchar(6) as para) p
              cross join lateral (select case when p.para = y.yerel then 1::numeric
                                              else coalesce(public.fn_doviz_kur_getir(p.para, @p1::date, 2::smallint),
                                                            nullif(b.doviz_kuru, 0), 1::numeric) end as kur) k
              left join lateral (select sum(hs.miktar) as m
                                   from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                                  where hs.kaynak_tur = 30 and hs.kaynak_id > 0 and hs.kaynak_id = s.id and hb.durum = 0) h on true
             where b.tur in (14, 119) and b.durum = 0 and coalesce(b.tipi, 0) <> 2
               and b.taraf_id = any(@p0::int[]) and b.belge_tarihi < (@p1::date + 1)
               and (cardinality(@p2::int[]) = 0 or b.sube_id is null or b.sube_id = any(@p2::int[]))
               and coalesce(s.miktar, 0) > 0
        ),
        irs as (
            select x.taraf_id, count(*)::int as adet, sum(round(round(x.acik, 2) * x.kur, 2)) as tutar
              from (select i.id, i.taraf_id, max(i.kur) as kur,
                           case when sum(i.fm) <= 0.0001 then max(i.matrah)
                                else sum(case when i.miktar - i.fm > 0.0001 then i.tutar * (i.miktar - i.fm) / i.miktar else 0 end) end as acik
                      from irs_s i group by i.id, i.taraf_id) x
             where x.acik > 0.005
             group by x.taraf_id
        ),
        sip as (
            select b.taraf_id, count(distinct b.id)::int as adet,
                   round(sum(case when pd.payda <> 0 then coalesce(b.matrah, 0) * coalesce(s.tutar, 0) / pd.payda
                                  when pd.adet > 0 then coalesce(b.matrah, 0) / pd.adet else 0 end
                             * v.kalan_miktar / s.miktar * k.kur), 2) as tutar
              from public.v_belge_acik_satir v
              join public.belge b on b.id = v.belge_id
              join public.belge_satir s on s.id = v.satir_id
              cross join y
              cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(b.belge_dovizi), ''), y.yerel))::varchar(6) as para) p
              cross join lateral (select case when p.para = y.yerel then 1::numeric
                                              else coalesce(public.fn_doviz_kur_getir(p.para, @p1::date, 2::smallint),
                                                            nullif(b.doviz_kuru, 0), 1::numeric) end as kur) k
              cross join lateral (select sum(x.tutar) as payda, count(*) as adet from public.belge_satir x where x.belge_id = b.id) pd
             where v.belge_tur = 19 and coalesce(b.tipi, 0) <> 30
               and v.taraf_id = any(@p0::int[]) and b.taraf_id = any(@p0::int[])
               and (cardinality(@p2::int[]) = 0 or v.sube_id is null or v.sube_id = any(@p2::int[]))
               and coalesce(s.miktar, 0) > 0
               and not exists (select 1 from public.siparis_satir_kapanis kp where kp.belge_satir_id = v.satir_id)
             group by b.taraf_id
        ),
        tem as (
            select tt.taraf_id, count(*)::int as adet,
                   sum(case when p.para = y.yerel then tt.tutar
                            else round(tt.tutar * coalesce(public.fn_doviz_kur_getir(p.para, @p1::date, 2::smallint), 0), 2) end) as tutar
              from public.taraf_teminat tt
              cross join y
              cross join lateral (select public.fn_doviz_iso(coalesce(nullif(btrim(tt.doviz), ''), 'TL'))::varchar(6) as para) p
             where tt.taraf_id = any(@p0::int[])
               and (tt.baslangic is null or tt.baslangic <= @p1::date) and (tt.bitis is null or tt.bitis >= @p1::date)
             group by tt.taraf_id
        )
        select tr.id, coalesce(bak.bakiye, 0), coalesce(bak.kur_yok, false),
               coalesce(cek.tutar, 0), coalesce(cek.adet, 0), cek.ilk_vade, coalesce(cek.yedi_gun, 0),
               coalesce(irs.tutar, 0), coalesce(irs.adet, 0), coalesce(sip.tutar, 0), coalesce(sip.adet, 0),
               tr.risk_limit, tr.limit_doviz,
               case when tr.limit_doviz = y.yerel then 1::numeric
                    else public.fn_doviz_kur_getir(tr.limit_doviz, @p1::date, 2::smallint) end,
               tr.sevk_blokesi, tr.sevk_blokesi_neden, coalesce(ku.ad, '')::varchar(160), tr.sevk_blokesi_an, tr.risk_grubu,
               coalesce(tem.tutar, 0), coalesce(tem.adet, 0), tr.surum
          from tr
          cross join y
          left join bak on bak.taraf_id = tr.id
          left join cek on cek.taraf_id = tr.id
          left join irs on irs.taraf_id = tr.id
          left join sip on sip.taraf_id = tr.id
          left join tem on tem.taraf_id = tr.id
          left join public.v_kullanici_lookup ku on ku.id = tr.sevk_blokesi_kim
        """;

    /// <summary>Bir müşterinin risk bileşenleri (TL, bugünkü kurla) + limit / bloke / teminat.</summary>
    public sealed record Satir(int TarafId, decimal Bakiye, bool KurYok,
        decimal Cek, int CekAdet, DateTime? CekIlkVade, decimal Cek7Gun,
        decimal Irsaliye, int IrsaliyeAdet, decimal Siparis, int SiparisAdet,
        decimal? Limit, string LimitDoviz, decimal? LimitKur,
        bool SevkBlokesi, string BlokeNeden, string BlokeKim, DateTime? BlokeAn, string RiskGrubu,
        decimal Teminat, int TeminatAdet, string Surum)
    {
        /// <summary>Toplam risk; şeritte çek / sipariş bileşeni kapatılabilir (karar 25.10.2026).</summary>
        public decimal Toplam(bool cekDahil = true, bool siparisDahil = true)
            => Bakiye + (cekDahil ? Cek : 0) + Irsaliye + (siparisDahil ? Siparis : 0);

        /// <summary>Limitin TL karşılığı; limit tanımsız ya da limit dövizinin bugünkü kuru yoksa null.</summary>
        public decimal? LimitTl => Limit is { } l && LimitKur is { } k ? Math.Round(l * k, 2) : null;
    }

    public static Task<List<Satir>> OkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int[] taraflar, DateTime bugun,
        int[] subeler, CancellationToken iptal)
        => b.ListeAsync(RiskSorgusu, tx, [taraflar, bugun.Date, subeler], o => new Satir(
            o.GetInt32(0), o.GetDecimal(1), o.GetBoolean(2),
            o.GetDecimal(3), o.GetInt32(4), o.IsDBNull(5) ? null : o.GetDateTime(5), o.GetDecimal(6),
            o.GetDecimal(7), o.GetInt32(8), o.GetDecimal(9), o.GetInt32(10),
            o.IsDBNull(11) ? null : o.GetDecimal(11), o.GetString(12), o.IsDBNull(13) ? null : o.GetDecimal(13),
            o.GetInt16(14) == 1, o.GetString(15), o.GetString(16), o.IsDBNull(17) ? null : o.GetDateTime(17), o.GetString(18),
            o.GetDecimal(19), o.GetInt32(20), o.GetString(21)), iptal);

    /// <summary>Limit / bloke kontrolüne giren satış belgesi: sipariş (başvuru hariç), irsaliye, fatura - iade hariç.
    ///   Tahsilatta kontrol yok (karar 25.10.2026).</summary>
    public static bool KontrolluBelge(int tur, int tipi)
        => tur switch { 19 => tipi is not (30 or 2), 14 or 15 => tipi != 2, _ => false };

    /// <summary>
    /// SATIŞ BELGESİ LİMİT / BLOKE KONTROLÜ (1178) - belgenin KENDİ transaction'ında, yazıldıktan SONRA
    /// çağrılır: risk sorgusu yeni belgeyi de görür (fatura cariyi, irsaliye faturasızı, sipariş açık
    /// satırı büyütür). Ucuz ön eleme: carinin limiti tanımsız ve blokesi yoksa risk sorgusu hiç çalışmaz.
    /// 'uyar' (varsayılan) → uyarı metni döner (yanıtın <c>uyarilar</c>'ına); 'engelle' → 422 IS_KURALI,
    /// yalnız <c>satis.limit_asim</c> yetkilisi uyarıyla geçer. Ayar `satis.limit_davranis`.
    /// </summary>
    public static async Task<string?> BelgeKontrolAsync(NpgsqlConnection b, NpgsqlTransaction tx, int tarafId, int tur,
        int tipi, bool asimYetkisi, DateTime bugun, CancellationToken iptal)
    {
        if (tarafId <= 0 || !KontrolluBelge(tur, tipi)) return null;
        var on = await b.TekAsync("""
            select coalesce(sevk_blokesi, 0) = 1, risk_limit is not null from public.taraf where id = @p0
            """, tx, [tarafId], o => new OnEleme(o.GetBoolean(0), o.GetBoolean(1)), iptal);
        if (on is null || (!on.Bloke && !on.LimitVar)) return null;

        var s = (await OkuAsync(b, tx, [tarafId], bugun, [], iptal)).FirstOrDefault();
        if (s is null) return null;
        var ayar = await AyarDeposu.MetinAsync(b, tx, "satis.limit_davranis", "", iptal);
        var karar = MusteriRiskKurali.LimitKarari(ayar, s.SevkBlokesi, s.BlokeNeden, s.Limit, s.LimitDoviz, s.LimitTl,
                                                 s.Toplam(), asimYetkisi);
        if (karar.Sonuc == MusteriRiskKurali.Sonuc.Engel)
            throw GentegreHatasi.IsKurali(karar.Mesaj, new
            {
                tarafId, risk = s.Toplam(), limit = s.Limit, limitDoviz = s.LimitDoviz, limitTl = s.LimitTl,
                sevkBlokesi = s.SevkBlokesi,
            });
        return karar.Sonuc == MusteriRiskKurali.Sonuc.Uyari ? karar.Mesaj : null;
    }

    private sealed record OnEleme(bool Bloke, bool LimitVar);
}

/// <summary>
/// MÜŞTERİ RİSKİNİN SAF KURALLARI (1178) - veritabanı gerektirmez, birim testi bunları sınar
/// (MusteriRiskKuraliTestleri): satış belgesinde limit / bloke kararı, A–D skoru, sevk blokesi önerisi.
/// </summary>
public static class MusteriRiskKurali
{
    public enum Sonuc { Yok, Uyari, Engel }

    public sealed record Karar(Sonuc Sonuc, string Mesaj);

    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");
    private static string T(decimal n) => n.ToString("N2", Tr);

    /// <summary>`satis.limit_davranis`: 'engelle' (büyük/küçük harf duyarsız - AyarDeposu metni büyük
    ///   harfe çevirir) dışındaki her değer, boş dahil, 'uyar'.</summary>
    public static bool EngelKipi(string? ayar) => string.Equals((ayar ?? "").Trim(), "engelle", StringComparison.OrdinalIgnoreCase);

    /// <summary>
    /// Satış belgesi kaydında karar. Sorun yoksa <see cref="Sonuc.Yok"/>. Sorun = sevk blokesi ya da
    /// (limit tanımlı ve toplam risk &gt; limit). Limit dövizinin kuru yoksa limit karşılaştırılamaz -
    /// kipten bağımsız UYARI (engel bilinmeyen bir sayıya dayanmasın).
    /// </summary>
    public static Karar LimitKarari(string? ayar, bool sevkBlokesi, string? blokeNeden, decimal? limit, string? limitDoviz,
        decimal? limitTl, decimal risk, bool asimYetkisi)
    {
        var sorunlar = new List<string>();
        var bilgi = new List<string>();
        if (sevkBlokesi)
            sorunlar.Add("Müşteri sevk blokesinde" + (string.IsNullOrWhiteSpace(blokeNeden) ? "." : $" ({blokeNeden!.Trim()})."));
        if (limit is { } l)
        {
            var dvz = string.IsNullOrWhiteSpace(limitDoviz) ? "TL" : limitDoviz!.Trim().ToUpperInvariant();
            if (limitTl is not { } ltl)
                bilgi.Add($"Risk limiti ({T(l)} {dvz}) kontrol edilemedi: {dvz} için bugünkü kur yok.");
            else if (risk > ltl + 0.005m)
                sorunlar.Add($"Risk limiti aşılıyor: toplam risk {T(risk)} ₺, limit {T(l)} {dvz}"
                             + (dvz is "TL" or "TRY" ? "" : $" (≈ {T(ltl)} ₺)") + $", aşım {T(risk - ltl)} ₺.");
        }
        if (sorunlar.Count == 0)
            return bilgi.Count == 0 ? new Karar(Sonuc.Yok, "") : new Karar(Sonuc.Uyari, string.Join(" ", bilgi));

        var metin = string.Join(" ", sorunlar.Concat(bilgi));
        if (!EngelKipi(ayar))
            return new Karar(Sonuc.Uyari, metin + " Belge kaydedildi (uyarı).");
        if (asimYetkisi)
            return new Karar(Sonuc.Uyari, metin + " Limit aşımı yetkinizle kaydedildi.");
        return new Karar(Sonuc.Engel, metin + " Belge kaydedilmedi (Genel Ayarlar › satis.limit_davranis = engelle). "
                                      + "Limit aşımında belge kesme yetkisi (satis.limit_asim) olan bir kullanıcı kaydedebilir "
                                      + "ya da Müşteri Risk / Limit İcmali'nden limit / bloke güncellenebilir.");
    }

    public sealed record Skor(int Puan, string Harf);

    /// <summary>
    /// ÖDEME DAVRANIŞI SKORU (karar 25.10.2026, sabit ağırlık): zamanında ödeme % 40 · ortalama gecikme 30 ·
    /// karşılıksız 20 · limit kullanımı 10. Yalnız bilgi - kendi başına bloke koymaz. Ödeme geçmişi yoksa
    /// (son 12 ayda kapanmış ya da vadesi geçmiş fatura yok) skor yok; limit tanımsızsa limit payı düşer,
    /// ağırlıklar kalan bileşenlere oranlanır. Harf: 85+ A · 70+ B · 50+ C · altı D.
    /// </summary>
    public static Skor? SkorHesapla(decimal? zamanindaYuzde, decimal? ortGecikmeGun, int karsiliksiz, decimal? kullanimYuzde)
    {
        if (zamanindaYuzde is null && ortGecikmeGun is null) return null;
        var parcalar = new List<(decimal agirlik, decimal puan)>();
        if (zamanindaYuzde is { } z) parcalar.Add((40, Math.Clamp(z, 0, 100)));
        if (ortGecikmeGun is { } g) parcalar.Add((30, Math.Clamp(100 - g * 100 / 60, 0, 100)));   // 60+ gün = 0
        parcalar.Add((20, karsiliksiz <= 0 ? 100 : karsiliksiz == 1 ? 40 : 0));
        if (kullanimYuzde is { } u) parcalar.Add((10, u <= 80 ? 100 : u <= 100 ? 60 : u <= 120 ? 30 : 0));
        var puan = (int)Math.Round(parcalar.Sum(p => p.agirlik * p.puan) / parcalar.Sum(p => p.agirlik), MidpointRounding.AwayFromZero);
        return new Skor(puan, puan >= 85 ? "A" : puan >= 70 ? "B" : puan >= 50 ? "C" : "D");
    }

    public sealed record Oneri(string Kod, string Ad, IReadOnlyList<string> Nedenler);

    /// <summary>
    /// SEVK BLOKESİ ÖNERİSİ - icmal blokeyi KOYMAZ, önerir (karar 25.10.2026); kuralı limit ve vade verir,
    /// skor değil. Liste dışı (null): blokesiz, limit içinde ve 90+ gecikmesi olmayan müşteri.
    /// <list type="bullet">
    /// <item><c>blokele</c> - limit aşımı teminatla karşılanmıyor VE (90+ vadesi geçen / karşılıksız / 6 aydır tahsilat yok);
    ///   ya da kullanım %150 üstü ve teminat yetmiyor.</item>
    /// <item><c>uyar</c> - limit aşımı var (teminat içinde ya da ağır işaret yok) ya da 90+ vadesi geçen var.</item>
    /// <item><c>kalsin</c> / <c>kaldir</c> - blokeli müşteride aşım ya da ağır işaret sürüyorsa kalsın, yoksa kaldırılabilir.</item>
    /// </list>
    /// </summary>
    public static Oneri? BlokeOnerisi(bool blokeli, decimal? kullanimYuzde, decimal asim, decimal teminat, decimal vade90Ustu,
        int karsiliksiz, int? sonTahsilatGun, decimal bakiye)
    {
        var nedenler = new List<string>();
        var asimVar = asim > 0.005m;
        var teminatKarsilar = asimVar && teminat >= asim;
        if (asimVar) nedenler.Add(kullanimYuzde is { } k ? $"Limit %{Math.Round(k).ToString(Tr)}" : "Limit aşımı");
        if (teminatKarsilar) nedenler.Add("teminat içinde");
        if (vade90Ustu > 0.005m) nedenler.Add($"90+ vadesi geçen {T(vade90Ustu)}");
        if (karsiliksiz > 0) nedenler.Add("karşılıksız geçmişi");
        var tahsilatsiz = bakiye > 0.005m && (sonTahsilatGun is null || sonTahsilatGun > 180);
        if (tahsilatsiz) nedenler.Add(sonTahsilatGun is null ? "hiç tahsilat yok" : "6 aydır tahsilat yok");
        var agir = vade90Ustu > 0.005m || karsiliksiz > 0 || tahsilatsiz;

        if (blokeli)
            return (asimVar && !teminatKarsilar) || agir
                ? new Oneri("kalsin", "blokede kalsın", nedenler)
                : new Oneri("kaldir", "kaldırılabilir", nedenler.Count > 0 ? nedenler : ["limit içinde, gecikme yok"]);
        if (asimVar && !teminatKarsilar && (agir || kullanimYuzde is > 150))
            return new Oneri("blokele", "blokele (peşin / teminat)", nedenler);
        if (asimVar || vade90Ustu > 0.005m)
            return new Oneri("uyar", "uyarıyla sat", nedenler);
        return null;
    }
}
