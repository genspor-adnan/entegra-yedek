using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İRSALİYE-FATURA EŞLEŞME İCMALİ (kullanıcı 25.10.2026 - mockup
/// Ekranlar/İcmal/irsaliye_fatura_eslesme_icmali.html).
///
/// <para><b>Kaynak:</b> irsaliye satırları (satış 14 + giden konsinye 119, alış 10 + gelen
/// konsinye 109) ve onlardan TÜREYEN belge satırları - dönüşümün yazdığı satır bağı
/// (belge_satir.kaynak_tur = 30, kaynak_id = irsaliye satırı; BelgeDeposu.DonusturAsync).
/// Eşleşme satır bazındadır: bir irsaliye birden çok faturaya, bir fatura birden çok
/// irsaliyeye bağlanabilir. Faturalanan = iptal edilmemiş KESİN hedef belgelerin satır
/// miktarı (taslak hedef "taslak fatura var" diye ayrıca işaretlenir).</para>
///
/// <para><b>Durumlar:</b> faturalanmamış (hiç kesin hedef yok) · kısmi (kalan miktar) ·
/// fazla faturalanan · fiyat farkı (satır birim tutarı irsaliyeden hem %2 hem 1 ₺ sapınca) ·
/// tam eşleşen · irsaliyesiz fatura (stoklu kalemi stok düşürmüş, hiçbir irsaliyeye bağlı
/// değil). Tutarlar KDV hariç: belge matrahı (fn_belge_diptoplam'ın yazdığı belge.matrah)
/// ve satırın kayıtlı tutarı; kalan tutar = satır tutarı × kalan / miktar.</para>
///
/// <para><b>VUK 7 gün:</b> bekleyen gün eşikten (varsayılan 7) uzun faturasız irsaliye
/// "Yasal Süre Aşımı"dır. KONSİNYE (karar 25.10.2026) muaftır: listede rozetle durur,
/// süre aşımına ve ⚠ işaretine girmez.</para>
///
/// <para><b>e-İrsaliye:</b> giden irsaliyede belge.efatura_durum (51 hazır / 52 gönderildi)
/// + e_belge yanıt kodu; gelen irsaliyede e_belge.durum (100 bekliyor · 101 kabul ·
/// 102 red · 103 yanıt süresi doldu, fn_gelen_belge_kaydet).</para>
///
/// <para><b>İşlemler:</b> "Faturala" web'de mevcut dönüşüm akışını (POST /api/belge/{id}/donustur,
/// BelgeDonusumModali) açar - burada ayrı fatura üretici YOK. "Bağla" (POST /bagla):
/// irsaliyesiz kesilmiş faturanın stoklu satırlarını aynı carinin açık irsaliye satırlarına
/// dönüşümle AYNI alanlarla bağlar (kaynak_tur 30, kaynak_id, stok_durum_degis 0) ve
/// faturanın stok etkisini kaldırır (irsaliye malı zaten düşürmüştü). Kapanmış döneme
/// dokunabilir (karar 25.10.2026) ama onay ister ve dönemi log'a yazar.</para>
/// </summary>
public static class EslesmeIcmalUclari
{
    private const string Kod = "irsaliye_fatura_eslesme";

    /// <summary>islem_log.tablo_id - belge (BelgeDeposu.LogTabloBelge ile aynı).</summary>
    private const int LogTabloBelge = 30;

    /// <summary>Dönüşüm bağının kaynak türü (belge_satir → belge_satir).</summary>
    private const int KaynakTurDonusum = 30;

    private static readonly int[] SatisIrsaliye = [14, 119];
    private static readonly int[] AlisIrsaliye = [10, 109];
    private const decimal Eps = 0.0001m;

    public sealed record BaglaSatiri(int FaturaSatirId, int IrsaliyeSatirId);
    public sealed record BaglaIstegi(int FaturaId, List<BaglaSatiri>? Satirlar, bool Onay);

    private sealed record IrsSatir(int Id, string Kod, string Ad, decimal Miktar, decimal Tutar,
        decimal FatMiktar, decimal FatTutar, string FatNo, DateTime? IlkFatura, int Taslak, int[] FatIdler);

    private sealed class Irsaliye
    {
        public int Id; public int Tur; public int Tipi; public string No = ""; public DateTime Tarih;
        public int TarafId; public string Cari = ""; public decimal Matrah; public int EDurum; public string Depo = "";
        public int EbDurum; public int EbYon; public string EbYanit = ""; public int SubeId;
        public List<IrsSatir> Satirlar = [];
    }

    private sealed record FaturaBaslik(int Id, int Tur, int Tipi, int Durum, int TarafId, int? SubeId,
        DateTime Tarih, string No, long KaynakId);

    private sealed record FaturaSatir(int Id, int? StokId, decimal Miktar, decimal Adet, int StokDurumDegis,
        int KaynakTur, long KaynakId, int? CikisDepo, int? GirisDepo, bool Lotlu, int Tur, string Kod, string Ad);

    private sealed record HedefSatir(int Id, int BelgeId, int? StokId, decimal Kalan, int Tur, int Tipi, int Durum,
        int TarafId, int? SubeId, DateTime Tarih, string No);

    private static bool Konsinye(int tur) => tur is 109 or 119;
    private static string Yon(int tur) => tur is 14 or 119 or 15 ? "satis" : "alis";

    private static string DonemAdi(DateTime gun) => gun.ToString("yyyy-MM", CultureInfo.InvariantCulture);

    /// <summary>e-İrsaliye yanıt durumu: kabul · red · sure · bekliyor · gonderildi · hazir · kagit.</summary>
    private static string EIrsaliye(Irsaliye x)
    {
        if (x.EbYon == 2)
            return x.EbDurum switch { 101 => "kabul", 102 => "red", 103 => "sure", _ => "bekliyor" };
        if (x.EbYanit is "ACCEPTED" or "APPROVED") return "kabul";
        if (x.EbYanit is "REJECTED" or "DECLINED" or "PARTIAL_REJECTED") return "red";
        return x.EDurum switch { 52 => "gonderildi", 51 => "hazir", _ => x.EbYon == 1 ? "gonderildi" : "kagit" };
    }

    public static void EslesmeIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/eslesme-icmal").WithTags("İrsaliye-Fatura Eşleşme İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (string? yon, DateTime? bas, DateTime? bit, int? cari, int? sube, int? esik, int? tam,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var bitis = (bit ?? bugun).Date;
            if (bitis > bugun) bitis = bugun;
            var baslangic = (bas ?? new DateTime(bitis.Year, 1, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            var y = yon is "alis" or "ikisi" ? yon : "satis";
            var e = esik is >= 1 and <= 90 ? esik.Value : 7;
            var tamGoster = (tam ?? 0) == 1;
            var c0 = cari ?? 0;
            var tumSubeler = baglam.Subeler.Select(s => s.Id).ToArray();
            int[] subeler;
            if (sube is > 0)
            {
                if (!tumSubeler.Contains(sube.Value)) throw GentegreHatasi.Bulunamadi("Şube bulunamadı.");
                subeler = [sube.Value];
            }
            else subeler = tumSubeler;

            var irsTurleri = y switch { "alis" => AlisIrsaliye, "ikisi" => SatisIrsaliye.Concat(AlisIrsaliye).ToArray(), _ => SatisIrsaliye };
            var fatTurleri = y switch { "alis" => new[] { 11 }, "ikisi" => new[] { 15, 11 }, _ => new[] { 15 } };

            await using var b = await veri.AcAsync(iptal);
            var acikDonemBasi = await MuhasebeDonemi.AcikDonemBasiAsync(b, null, bugun, iptal);

            // ------------------------------------------- irsaliye satırları + hedefleri --
            var ham = await b.ListeAsync("""
                select b.id, b.tur::int, coalesce(b.tipi, 0)::int, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi,
                       coalesce(b.taraf_id, 0),
                       coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''),
                       coalesce(b.matrah, 0), coalesce(b.efatura_durum, 0)::int, coalesce(d.ad, ''),
                       coalesce(eb.durum, 0)::int, coalesce(eb.yon, 0)::int, coalesce(eb.yk, ''),
                       s.id, coalesce(st.kod, hz.kod, ''), coalesce(st.ad, hz.ad, nullif(s.aciklama, ''), ''),
                       coalesce(s.miktar, 0), coalesce(s.tutar, 0),
                       coalesce(h.m, 0), coalesce(h.t, 0), coalesce(h.no, ''), h.ilk, coalesce(h.taslak, 0),
                       coalesce(h.idler, '{}'::int[]), coalesce(b.sube_id, 0)
                  from public.belge b
                  join public.belge_satir s on s.belge_id = b.id
                  left join public.taraf t on t.id = b.taraf_id
                  left join public.depo d on d.id = case when b.tur in (14, 119) then coalesce(b.cikis_depo_id, b.giris_depo_id)
                                                         else coalesce(b.giris_depo_id, b.cikis_depo_id) end
                  left join public.stok st on st.id = s.stok_id
                  left join public.hizmet hz on hz.id = s.hizmet_id
                  left join lateral (select e.durum, e.yon, upper(coalesce(e.yanit_durum_kodu, '')) as yk
                                       from public.e_belge e where e.belge_id = b.id and e.belge_turu = 7
                                      order by e.id desc limit 1) eb on true
                  left join lateral (
                        select sum(hs.miktar) filter (where hb.durum = 0) as m,
                               sum(hs.tutar) filter (where hb.durum = 0) as t,
                               string_agg(distinct coalesce(nullif(hb.belge_no, ''), '#' || hb.id), ', ') filter (where hb.durum = 0) as no,
                               min(hb.belge_tarihi) filter (where hb.durum = 0) as ilk,
                               (count(*) filter (where hb.durum = 1))::int as taslak,
                               array_agg(distinct hb.id) filter (where hb.durum = 0) as idler
                          from public.belge_satir hs join public.belge hb on hb.id = hs.belge_id
                         where hs.kaynak_tur = 30 and hs.kaynak_id > 0 and hs.kaynak_id = s.id) h on true
                 where b.tur = any(@p0::int[]) and b.durum = 0
                   and b.belge_tarihi::date >= @p1::date and b.belge_tarihi::date <= @p2::date
                   and (b.sube_id is null or b.sube_id = any(@p3::int[]))
                   and (@p4 = 0 or b.taraf_id = @p4)
                   and coalesce(s.miktar, 0) > 0
                 order by b.belge_tarihi, b.id, s.sira, s.id
                """, null, [irsTurleri, baslangic, bitis, subeler, c0], o => new
                {
                    id = o.GetInt32(0), tur = o.GetInt32(1), tipi = o.GetInt32(2), no = o.GetString(3), tarih = o.GetDateTime(4),
                    taraf = o.GetInt32(5), cari = o.GetString(6), matrah = o.GetDecimal(7), edurum = o.GetInt32(8), depo = o.GetString(9),
                    ebDurum = o.GetInt32(10), ebYon = o.GetInt32(11), ebYanit = o.GetString(12),
                    satir = new IrsSatir(o.GetInt32(13), o.GetString(14), o.GetString(15), o.GetDecimal(16), o.GetDecimal(17),
                        o.GetDecimal(18), o.GetDecimal(19), o.GetString(20), o.IsDBNull(21) ? null : o.GetDateTime(21),
                        o.GetInt32(22), o.GetFieldValue<int[]>(23)),
                    sube = o.GetInt32(24),
                }, iptal);

            var irsaliyeler = new List<Irsaliye>();
            foreach (var g in ham.GroupBy(x => x.id))
            {
                var f = g.First();
                irsaliyeler.Add(new Irsaliye
                {
                    Id = f.id, Tur = f.tur, Tipi = f.tipi, No = f.no, Tarih = f.tarih, TarafId = f.taraf, Cari = f.cari,
                    Matrah = f.matrah, EDurum = f.edurum, Depo = f.depo, EbDurum = f.ebDurum, EbYon = f.ebYon,
                    EbYanit = f.ebYanit, SubeId = f.sube, Satirlar = g.Select(x => x.satir).ToList(),
                });
            }

            // SATIR HESABI: kalan, fazla, fiyat farkı. Birim tutarlar kayıtlı satır tutarından
            //   (tutar / miktar) - satır tutarı yeniden hesaplanmaz.
            static decimal Kalan(IrsSatir s) => s.Miktar - s.FatMiktar;
            static decimal IrsBirim(IrsSatir s) => s.Miktar > 0 ? s.Tutar / s.Miktar : 0;
            static decimal? FatBirim(IrsSatir s) => s.FatMiktar > Eps ? s.FatTutar / s.FatMiktar : null;
            static decimal Fark(IrsSatir s) => s.FatMiktar > Eps ? Math.Round(s.FatTutar - IrsBirim(s) * s.FatMiktar, 2) : 0;
            static decimal Sapma(IrsSatir s)
            {
                if (FatBirim(s) is not { } fb) return 0;
                var ib = IrsBirim(s);
                return ib != 0 ? Math.Round((fb - ib) / ib * 100, 1) : (fb != 0 ? 100 : 0);
            }
            static bool FiyatFarkli(IrsSatir s) => s.FatMiktar > Eps && Math.Abs(Fark(s)) >= 1 && Math.Abs(Sapma(s)) >= 2;
            static bool Fazla(IrsSatir s) => Kalan(s) < -Eps;
            static decimal KalanTutar(IrsSatir s) => Kalan(s) > Eps && s.Miktar > 0 ? s.Tutar * Kalan(s) / s.Miktar : 0;

            int Gun(DateTime t) => (int)(bugun - Saat.Gun(t)).TotalDays;
            string Durum(Irsaliye x) => x.Satirlar.Sum(s => s.FatMiktar) <= Eps ? "faturasiz"
                : x.Satirlar.Any(s => Kalan(s) > Eps) ? "kismi"
                : x.Satirlar.Any(s => Fazla(s) || FiyatFarkli(s)) ? "fark" : "tam";
            bool Acik(Irsaliye x) => Durum(x) is "faturasiz" or "kismi";
            bool SureAsimi(Irsaliye x) => Acik(x) && !Konsinye(x.Tur) && Gun(x.Tarih) > e;
            decimal AcikTutar(Irsaliye x) => Durum(x) == "faturasiz" ? x.Matrah : Math.Round(x.Satirlar.Sum(s => KalanTutar(s)), 2);
            double? FaturaSuresi(Irsaliye x)
            {
                var ilkler = x.Satirlar.Where(s => s.IlkFatura is not null).Select(s => s.IlkFatura!.Value).ToList();
                if (ilkler.Count == 0) return null;
                return Math.Max(0, (Saat.Gun(ilkler.Min()) - Saat.Gun(x.Tarih)).TotalDays);
            }

            // ------------------------------------------------ Faturalanmamış --
            var faturasiz = irsaliyeler.Where(x => Durum(x) == "faturasiz")
                .OrderByDescending(x => SureAsimi(x)).ThenBy(x => x.Tarih)
                .Select(x => new
                {
                    x.Id, x.Tur, yon = Yon(x.Tur), no = x.No, tarih = x.Tarih, tarafId = x.TarafId, cari = x.Cari, depo = x.Depo,
                    kalem = x.Satirlar.Count, miktar = x.Satirlar.Sum(s => s.Miktar), tutar = x.Matrah,
                    bekleyen = Gun(x.Tarih), sureAsimi = SureAsimi(x), konsinye = Konsinye(x.Tur), iade = x.Tipi == 2,
                    eIrsaliye = EIrsaliye(x), taslakFatura = x.Satirlar.Any(s => s.Taslak > 0),
                    kalemler = x.Satirlar.Select(s => new { s.Kod, s.Ad, s.Miktar, birimFiyat = Math.Round(IrsBirim(s), 4) }).ToList(),
                }).ToList();

            // ------------------------------------------------ Kısmi / Fark --
            var farklar = irsaliyeler.Where(x => Durum(x) is "kismi" or "fark" || tamGoster && Durum(x) == "tam")
                .OrderBy(x => Yon(x.Tur) == "satis" ? 0 : 1).ThenBy(x => x.Tarih)
                .SelectMany(x => x.Satirlar
                    .Where(s => Kalan(s) > Eps || Fazla(s) || FiyatFarkli(s) || tamGoster)
                    .Select(s => new
                    {
                        irsaliyeId = x.Id, x.Tur, yon = Yon(x.Tur), irsaliyeNo = x.No, tarih = x.Tarih, tarafId = x.TarafId, cari = x.Cari,
                        faturaNo = s.FatNo, faturaId = s.FatIdler.Length > 0 ? s.FatIdler.Min() : (int?)null,
                        satirId = s.Id, s.Kod, s.Ad, irsMiktar = s.Miktar, fatMiktar = s.FatMiktar, kalan = Kalan(s),
                        irsFiyat = Math.Round(IrsBirim(s), 4), fatFiyat = FatBirim(s) is { } fb ? Math.Round(fb, 4) : (decimal?)null,
                        fark = Fark(s), sapma = Sapma(s),
                        durum = Fazla(s) ? "fazla" : Kalan(s) > Eps ? "kismi" : FiyatFarkli(s) ? "fiyat" : "tam",
                        konsinye = Konsinye(x.Tur), eIrsaliye = EIrsaliye(x),
                    }))
                .ToList();

            // ------------------------------------------------ İrsaliyesiz faturalar --
            var fatHam = await b.ListeAsync("""
                select b.id, b.tur::int, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi, coalesce(b.taraf_id, 0),
                       coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''),
                       coalesce(b.matrah, 0),
                       s.id, s.stok_id, coalesce(st.kod, ''), coalesce(st.ad, ''),
                       case when coalesce(s.miktar, 0) <> 0 then s.miktar else coalesce(s.adet, 0) end, coalesce(s.tutar, 0),
                       coalesce(st.izleme, 0)::int > 0
                         or exists (select 1 from public.stok_izleme i where i.belge_satir_id = s.id)
                  from public.belge b
                  join public.belge_satir s on s.belge_id = b.id
                  join public.stok st on st.id = s.stok_id
                  left join public.taraf t on t.id = b.taraf_id
                 where b.tur = any(@p0::int[]) and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                   and b.belge_tarihi::date >= @p1::date and b.belge_tarihi::date <= @p2::date
                   and (b.sube_id is null or b.sube_id = any(@p3::int[]))
                   and (@p4 = 0 or b.taraf_id = @p4)
                   and s.tur = 1 and s.stok_durum_degis = 1
                   and not (coalesce(s.kaynak_tur, 0) = 30 and coalesce(s.kaynak_id, 0) > 0)
                 order by b.belge_tarihi, b.id, s.sira, s.id
                """, null, [fatTurleri, baslangic, bitis, subeler, c0], o => new
                {
                    id = o.GetInt32(0), tur = o.GetInt32(1), no = o.GetString(2), tarih = o.GetDateTime(3), taraf = o.GetInt32(4),
                    cari = o.GetString(5), matrah = o.GetDecimal(6), satirId = o.GetInt32(7), stokId = o.GetInt32(8),
                    kod = o.GetString(9), ad = o.GetString(10), miktar = o.GetDecimal(11), tutar = o.GetDecimal(12), lotlu = o.GetBoolean(13),
                }, iptal);

            // Aynı carinin AÇIK irsaliye satırları (tarih sınırı yok - fatura irsaliyeden sonra da kesilir).
            //   Kalan = kalan_miktar (dönüşümün de kullandığı sayaç; Bağla aynı sınırı uygular).
            var taraflar = fatHam.Select(x => x.taraf).Where(x => x > 0).Distinct().ToArray();
            var acikSatirlar = await b.ListeAsync("""
                select s.id, s.belge_id, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi, b.tur::int,
                       coalesce(b.taraf_id, 0), s.stok_id, s.kalan_miktar, coalesce(b.matrah, 0)
                  from public.belge_satir s join public.belge b on b.id = s.belge_id
                 where cardinality(@p1::int[]) > 0
                   and b.tur = any(@p0::int[]) and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                   and b.taraf_id = any(@p1::int[]) and s.stok_id is not null and s.kalan_miktar > 0.0001
                   and (b.sube_id is null or b.sube_id = any(@p2::int[]))
                 order by b.belge_tarihi, b.id, s.sira, s.id
                """, null, [irsTurleri, taraflar, tumSubeler], o => new
                {
                    satirId = o.GetInt32(0), belgeId = o.GetInt32(1), no = o.GetString(2), tarih = o.GetDateTime(3), tur = o.GetInt32(4),
                    taraf = o.GetInt32(5), stokId = o.GetInt32(6), kalan = o.GetDecimal(7), matrah = o.GetDecimal(8),
                }, iptal);

            var irsaliyesiz = fatHam.GroupBy(x => x.id).Select(g =>
            {
                var f = g.First();
                var uygunTurler = f.tur == 15 ? SatisIrsaliye : AlisIrsaliye;
                var aday = acikSatirlar.Where(a => a.taraf == f.taraf && f.taraf > 0 && uygunTurler.Contains(a.tur)).ToList();
                var stoklar = g.Select(x => x.stokId).ToHashSet();
                var acik = aday.Where(a => stoklar.Contains(a.stokId)).GroupBy(a => a.belgeId).Select(ag => new
                {
                    id = ag.Key, no = ag.First().no, tarih = ag.First().tarih, tutar = ag.First().matrah,
                    ortakKalem = ag.Select(a => a.stokId).Distinct().Count(),
                }).ToList();
                // EŞLEŞME ÖNERİSİ: her stoklu fatura satırı için aynı stoğun en eski, kalanı yeten açık
                //   irsaliye satırı (aynı istekte paylaştırılan miktar düşülerek). Sunucu Bağla'da yeniden doğrular.
                var kullanilan = new Dictionary<int, decimal>();
                var eslesme = g.Select(x =>
                {
                    var hedef = x.lotlu || x.miktar <= 0 ? null
                        : aday.FirstOrDefault(a => a.stokId == x.stokId
                              && a.kalan - kullanilan.GetValueOrDefault(a.satirId) + Eps >= x.miktar);
                    if (hedef is not null) kullanilan[hedef.satirId] = kullanilan.GetValueOrDefault(hedef.satirId) + x.miktar;
                    return new
                    {
                        faturaSatirId = x.satirId, x.kod, x.ad, x.miktar, x.lotlu,
                        irsaliyeSatirId = hedef?.satirId, irsaliyeId = hedef?.belgeId, irsaliyeNo = hedef?.no,
                        irsaliyeKalan = hedef?.kalan,
                    };
                }).ToList();
                var eslesen = eslesme.Count(x => x.irsaliyeSatirId is not null);
                var kapanmis = Saat.Gun(f.tarih) < acikDonemBasi
                               || eslesme.Where(x => x.irsaliyeId is not null)
                                         .Any(x => aday.First(a => a.satirId == x.irsaliyeSatirId).tarih is var it && Saat.Gun(it) < acikDonemBasi);
                return new
                {
                    f.id, f.tur, yon = Yon(f.tur), f.no, f.tarih, tarafId = f.taraf, f.cari, tutar = f.matrah,
                    stokluKalem = g.Count(), acikIrsaliyeler = acik, eslesme, eslesenKalem = eslesen,
                    lotlu = g.Any(x => x.lotlu),
                    oneri = acik.Count == 0 ? "normal" : eslesen > 0 ? "bagla" : "incele",
                    kapanmisDonem = kapanmis,
                };
            }).OrderBy(x => x.oneri == "bagla" ? 0 : x.oneri == "incele" ? 1 : 2).ThenBy(x => x.tarih).ToList();

            // ------------------------------------------------ Cari bazında --
            var cariler = irsaliyeler.GroupBy(x => (x.TarafId, yon: Yon(x.Tur))).Select(g =>
            {
                var acik = g.Where(Acik).ToList();
                var sureler = g.Select(x => FaturaSuresi(x)).Where(v => v is not null).Select(v => v!.Value).ToList();
                return new
                {
                    tarafId = g.Key.TarafId, cari = g.First().Cari, g.Key.yon, irsaliye = g.Count(), tam = g.Count(x => Durum(x) == "tam"),
                    acik = acik.Count, acikTutar = acik.Sum(x => AcikTutar(x)),
                    ortSure = sureler.Count > 0 ? Math.Round(sureler.Average(), 1) : (double?)null,
                    enEski = acik.Count > 0 ? acik.Max(x => Gun(x.Tarih)) : (int?)null,
                    sureAsimi = g.Count(SureAsimi),
                };
            }).OrderByDescending(x => x.acikTutar).ThenBy(x => x.cari).ToList();

            // ------------------------------------------------ özet --
            var fs = irsaliyeler.Where(x => Durum(x) == "faturasiz").ToList();
            var ks = irsaliyeler.Where(x => Durum(x) == "kismi").ToList();
            var tumSatir = irsaliyeler.SelectMany(x => x.Satirlar).ToList();
            var fiyatSatir = tumSatir.Where(FiyatFarkli).ToList();
            var tumSure = irsaliyeler.Select(x => FaturaSuresi(x)).Where(v => v is not null).Select(v => v!.Value).ToList();
            var tamSayi = irsaliyeler.Count(x => Durum(x) == "tam");
            var ozet = new
            {
                incelenen = irsaliyeler.Count,
                faturasiz = fs.Count, faturasizTutar = fs.Sum(x => x.Matrah),
                enEskiGun = fs.Count > 0 ? fs.Max(x => Gun(x.Tarih)) : 0,
                kismi = ks.Count, kismiKalan = Math.Round(ks.Sum(x => AcikTutar(x)), 2),
                irsaliyesiz = irsaliyesiz.Count, supheli = irsaliyesiz.Count(x => x.oneri == "bagla"),
                miktarFarki = tumSatir.Count(s => s.FatMiktar > Eps && Math.Abs(Kalan(s)) > Eps),
                fazla = tumSatir.Count(Fazla),
                fiyatFarki = fiyatSatir.Count, fiyatFarkTutar = Math.Round(fiyatSatir.Sum(s => Math.Abs(Fark(s))), 2),
                tam = tamSayi, tamOran = irsaliyeler.Count > 0 ? Math.Round(100m * tamSayi / irsaliyeler.Count, 1) : 0,
                ortSure = tumSure.Count > 0 ? Math.Round(tumSure.Average(), 1) : (double?)null,
                sureAsimi = irsaliyeler.Count(SureAsimi),
                konsinyeAcik = irsaliyeler.Count(x => Acik(x) && Konsinye(x.Tur)),
                redAcik = irsaliyeler.Count(x => Acik(x) && EIrsaliye(x) == "red"),
                acikTutar = Math.Round(irsaliyeler.Where(Acik).Sum(x => AcikTutar(x)), 2),
                farkSatir = farklar.Count(x => x.durum != "tam"),
            };

            var cariSecim = await b.ListeAsync("""
                select distinct coalesce(b.taraf_id, 0),
                       coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')
                  from public.belge b left join public.taraf t on t.id = b.taraf_id
                 where b.tur = any(@p0::int[]) and b.durum = 0 and coalesce(b.taraf_id, 0) > 0
                   and b.belge_tarihi::date >= @p1::date and b.belge_tarihi::date <= @p2::date
                   and (b.sube_id is null or b.sube_id = any(@p3::int[]))
                 order by 2
                """, null, [irsTurleri.Concat(fatTurleri).ToArray(), baslangic, bitis, subeler],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var cariTekil = cariSecim.GroupBy(x => x.id).Select(g => g.First()).ToList();

            var ayinSonGunu = new DateTime(bugun.Year, bugun.Month, DateTime.DaysInMonth(bugun.Year, bugun.Month));
            return Results.Ok(new
            {
                yon = y, bas = baslangic, bit = bitis, cari = c0, sube = sube ?? 0, esik = e, tam = tamGoster,
                aySonuKalanGun = (int)(ayinSonGunu - bugun).TotalDays,
                acikDonemBasi, ozet, faturasiz, farklar, irsaliyesiz, cariler,
                secim = new { cariler = cariTekil, subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList() },
                yetkiler = new
                {
                    // FATURALA = mevcut dönüşüm ucunun kapıları (belge ekleme + belge.donustur aksiyonu).
                    faturala = baglam.Yetkiler.Var("belge", Islem.Ekle) && baglam.Yetkiler.AksiyonVar("belge.donustur") && baglam.SubeYazma,
                    // BAĞLA = belge değiştirme (fatura satırı ve stok etkisi değişir).
                    bagla = baglam.Yetkiler.Var("belge", Islem.Degistir) && baglam.SubeYazma,
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ================================================================= BAĞLA ===
        // İrsaliyesiz kesilmiş faturanın stoklu satırlarını açık irsaliye satırlarına bağlar.
        //   DÖNÜŞÜMLE AYNI ALANLAR: fatura satırı kaynak_tur = 30, kaynak_id = irsaliye satırı,
        //   stok_durum_degis = 0 (kapatilan_miktar'ı tetik sürer); başlık kaynağı boşsa ilk irsaliye.
        //   STOK: faturanın bu satırlarla depoya yazdığı hareket TERSİNE çevrilir - BelgeDeposu'nun
        //   satırı depoya yazdığı yolun (StokDurumGuncelle / DepoyaYaz) birebir tersi: aynı yön
        //   (BelgeTuru.CikisMi), aynı depo seçimi, aynı miktar (miktar, yoksa adet). İrsaliye malı
        //   zaten düşürmüştü; böylece mal bir kez düşmüş olur.
        //   LOT / SERİ İZLEMLİ satır BAĞLANMAZ: faturanın lot tüketimi giriş zincirinden FIFO
        //   düşülmüştür ve hangi girişlerden ne kadar düştüğü kayıtlı değil (yalnız ilk kaynak) -
        //   tam geri alınamaz. Böyle faturada "Bağla" reddedilir, faturayı düzenleyin.
        grup.MapPost("/bagla", async (BaglaIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste("belge", Islem.Degistir);
            var ciftler = (istek.Satirlar ?? []).Where(x => x.FaturaSatirId > 0 && x.IrsaliyeSatirId > 0).ToList();
            if (istek.FaturaId <= 0) throw GentegreHatasi.Dogrulama("Fatura seçilmeli.", new AlanHatasi("faturaId", "Zorunlu."));
            if (ciftler.Count == 0) throw GentegreHatasi.Dogrulama("Bağlanacak satır seçilmedi.", new AlanHatasi("satirlar", "Boş bırakılamaz."));
            if (ciftler.Count > 500) throw GentegreHatasi.Dogrulama("Tek seferde en çok 500 satır bağlanır.");
            if (ciftler.Select(x => x.FaturaSatirId).Distinct().Count() != ciftler.Count)
                throw GentegreHatasi.Dogrulama("Bir fatura satırı yalnız bir irsaliye satırına bağlanır.");
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);

            // ------------------------------------------------------ 1) fatura --
            var fatura = await b.TekAsync("""
                select b.id, b.tur::int, coalesce(b.tipi, 0)::int, coalesce(b.durum, 0)::int, coalesce(b.taraf_id, 0), b.sube_id,
                       b.belge_tarihi, coalesce(nullif(b.belge_no, ''), '#' || b.id), coalesce(b.kaynak_id, 0)::bigint
                  from public.belge b where b.id = @p0
                   for update
                """, tx, [istek.FaturaId], o => new FaturaBaslik(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetInt32(3),
                    o.GetInt32(4), o.IsDBNull(5) ? null : o.GetInt32(5), o.GetDateTime(6), o.GetString(7), o.GetInt64(8)), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Fatura bulunamadı.");
            if (fatura.SubeId is { } fsb && !baglam.Subeler.Any(s => s.Id == fsb)) throw GentegreHatasi.Bulunamadi("Fatura bulunamadı.");
            if (fatura.Tur is not (15 or 11)) throw GentegreHatasi.IsKurali("Yalnız satış ya da alış faturası irsaliyeye bağlanır.");
            if (fatura.Durum != 0) throw GentegreHatasi.IsKurali("Yalnız kesinleşmiş fatura bağlanır (taslak / iptal değil).");
            if (fatura.Tipi == 2) throw GentegreHatasi.IsKurali("İade faturası irsaliyeye bağlanamaz.");
            if (fatura.TarafId <= 0) throw GentegreHatasi.IsKurali("Carisiz fatura irsaliyeye bağlanamaz.");
            // Dönüşüm gibi: yazma aktif şubede (belgenin şubesi aktif şube olmalı).
            if (baglam.SubeId is { } aktif && fatura.SubeId is { } fs2 && fs2 != aktif)
                throw GentegreHatasi.IsKurali("Fatura başka bir şubenin; o şubeye geçip bağlayın.");
            if (!BelgeUclari.TurIzinli(baglam, fatura.Tur, fatura.Tipi, Islem.Degistir))
                throw GentegreHatasi.Yasak("Bu belge türünde değiştirme yetkiniz yok.");

            // ------------------------------------------------ 2) fatura satırları --
            var fatSatirlar = (await b.ListeAsync("""
                select s.id, s.stok_id, coalesce(s.miktar, 0), coalesce(s.adet, 0), coalesce(s.stok_durum_degis, 0)::int,
                       coalesce(s.kaynak_tur, 0)::int, coalesce(s.kaynak_id, 0)::bigint,
                       coalesce(s.cikis_depo_id, b.cikis_depo_id), coalesce(s.giris_depo_id, b.giris_depo_id),
                       coalesce(st.izleme, 0)::int > 0
                         or exists (select 1 from public.stok_izleme i where i.belge_satir_id = s.id),
                       s.tur::int, coalesce(st.kod, ''), coalesce(st.ad, '')
                  from public.belge_satir s
                  join public.belge b on b.id = s.belge_id
                  left join public.stok st on st.id = s.stok_id
                 where s.id = any(@p0::int[]) and s.belge_id = @p1
                   for update of s
                """, tx, [ciftler.Select(x => x.FaturaSatirId).ToArray(), fatura.Id], o => new FaturaSatir(
                    o.GetInt32(0), o.IsDBNull(1) ? null : o.GetInt32(1), o.GetDecimal(2), o.GetDecimal(3), o.GetInt32(4),
                    o.GetInt32(5), o.GetInt64(6), o.IsDBNull(7) ? null : o.GetInt32(7), o.IsDBNull(8) ? null : o.GetInt32(8),
                    o.GetBoolean(9), o.GetInt32(10), o.GetString(11), o.GetString(12)), iptal))
                .ToDictionary(x => x.Id);

            // ------------------------------------------------ 3) irsaliye satırları --
            var irsSatirlar = (await b.ListeAsync("""
                select s.id, s.belge_id, s.stok_id, coalesce(s.kalan_miktar, 0), b.tur::int, coalesce(b.tipi, 0)::int, coalesce(b.durum, 0)::int,
                       coalesce(b.taraf_id, 0), b.sube_id, b.belge_tarihi, coalesce(nullif(b.belge_no, ''), '#' || b.id)
                  from public.belge_satir s join public.belge b on b.id = s.belge_id
                 where s.id = any(@p0::int[])
                   for update of s
                """, tx, [ciftler.Select(x => x.IrsaliyeSatirId).Distinct().ToArray()], o => new HedefSatir(
                    o.GetInt32(0), o.GetInt32(1), o.IsDBNull(2) ? null : o.GetInt32(2), o.GetDecimal(3), o.GetInt32(4),
                    o.GetInt32(5), o.GetInt32(6), o.GetInt32(7), o.IsDBNull(8) ? null : o.GetInt32(8), o.GetDateTime(9),
                    o.GetString(10)), iptal))
                .ToDictionary(x => x.Id);

            var uygunTurler = fatura.Tur == 15 ? SatisIrsaliye : AlisIrsaliye;
            var kullanilan = new Dictionary<int, decimal>();
            foreach (var c in ciftler)
            {
                if (!fatSatirlar.TryGetValue(c.FaturaSatirId, out var fsa))
                    throw GentegreHatasi.Bulunamadi($"Fatura satırı bulunamadı: {c.FaturaSatirId}");
                var ad = fsa.Kod.Length > 0 ? fsa.Kod : "#" + fsa.Id;
                if (fsa.Tur != 1 || fsa.StokId is null)
                    throw GentegreHatasi.IsKurali($"{ad}: yalnız stoklu kalem irsaliyeye bağlanır.");
                if (fsa.KaynakTur == KaynakTurDonusum && fsa.KaynakId > 0)
                    throw GentegreHatasi.IsKurali($"{ad}: satır zaten bir irsaliyeye bağlı.");
                if (fsa.StokDurumDegis != 1)
                    throw GentegreHatasi.IsKurali($"{ad}: satır stoğu etkilemiyor; bağlanacak stok etkisi yok.");
                if (fsa.Lotlu)
                    throw GentegreHatasi.IsKurali($"{ad}: lot / seri izlemli kalem bu ekrandan bağlanamaz - faturanın lot " +
                        "tüketimi tam geri alınamıyor. Faturayı iptal edip irsaliyeden \"Faturaya Dönüştür\" ile yeniden kesin.");
                if (fsa.Miktar <= 0) throw GentegreHatasi.IsKurali($"{ad}: satır miktarı sıfır; bağlanamaz.");

                if (!irsSatirlar.TryGetValue(c.IrsaliyeSatirId, out var isa))
                    throw GentegreHatasi.Bulunamadi($"İrsaliye satırı bulunamadı: {c.IrsaliyeSatirId}");
                if (isa.SubeId is { } isb && !baglam.Subeler.Any(s => s.Id == isb))
                    throw GentegreHatasi.Bulunamadi($"İrsaliye satırı bulunamadı: {c.IrsaliyeSatirId}");
                if (!uygunTurler.Contains(isa.Tur))
                    throw GentegreHatasi.IsKurali($"{ad}: {isa.No} bu faturanın yönünde bir irsaliye değil.");
                if (isa.Durum != 0 || isa.Tipi == 2)
                    throw GentegreHatasi.IsKurali($"{ad}: {isa.No} kesinleşmiş normal irsaliye değil (taslak / iptal / iade).");
                if (isa.TarafId != fatura.TarafId)
                    throw GentegreHatasi.IsKurali($"{ad}: {isa.No} başka carinin irsaliyesi.");
                if (isa.StokId != fsa.StokId)
                    throw GentegreHatasi.IsKurali($"{ad}: {isa.No} satırının stoğu farklı.");
                if (!BelgeUclari.TurIzinli(baglam, isa.Tur, isa.Tipi, Islem.Gor))
                    throw GentegreHatasi.Bulunamadi($"İrsaliye satırı bulunamadı: {c.IrsaliyeSatirId}");
                var toplam = kullanilan.GetValueOrDefault(isa.Id) + fsa.Miktar;
                if (toplam > isa.Kalan + Eps)
                    throw GentegreHatasi.IsKurali(
                        $"{ad}: {isa.No} satırında faturalanmamış {isa.Kalan:0.####} kaldı, {toplam:0.####} bağlanmak istendi.");
                kullanilan[isa.Id] = toplam;
            }

            // ------------------------------------------------ 4) kapanmış dönem --
            var acikDonemBasi = await MuhasebeDonemi.AcikDonemBasiAsync(b, tx, bugun, iptal);
            var tarihler = new List<(string No, DateTime Gun)> { (fatura.No, Saat.Gun(fatura.Tarih)) };
            tarihler.AddRange(ciftler.Select(c => irsSatirlar[c.IrsaliyeSatirId]).DistinctBy(x => x.BelgeId)
                .Select(x => (x.No, Saat.Gun(x.Tarih))));
            var kapali = tarihler.Where(x => x.Gun < acikDonemBasi).ToList();
            var donemler = kapali.Select(x => DonemAdi(x.Gun)).Distinct().OrderBy(x => x).ToList();
            if (kapali.Count > 0 && !istek.Onay)
                throw GentegreHatasi.IsKurali(
                    $"Kapanmış döneme ait belge değişecek ({string.Join(", ", kapali.Select(x => $"{x.No} · {x.Gun:dd.MM.yyyy}"))}). " +
                    "Onaylarsanız işlem yapılır ve dönem bilgisiyle loglanır.",
                    new
                    {
                        kod = "KAPANMIS_DONEM", kapanmisDonem = true, donemler,
                        acikDonemBasi = acikDonemBasi.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                        belgeler = kapali.Select(x => new { no = x.No, tarih = x.Gun.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) }).ToList(),
                    });

            // ------------------------------------------------ 5) stok etkisini kaldır + bağla --
            var cikis = BelgeTuru.CikisMi(fatura.Tur, fatura.Tipi);
            var negatifDavranis = await AyarDeposu.SayiAsync(b, tx, "stok.negatif_davranis", iptal);
            var uyarilar = new List<string>();
            var satirLog = new List<string>();
            foreach (var c in ciftler)
            {
                var fsa = fatSatirlar[c.FaturaSatirId];
                var isa = irsSatirlar[c.IrsaliyeSatirId];
                var m = fsa.Miktar != 0 ? fsa.Miktar : fsa.Adet;
                // Depo seçimi StokDurumGuncelleAsync ile aynı: çıkışta çıkış deposu, girişte giriş deposu.
                var depo = cikis ? fsa.CikisDepo ?? fsa.GirisDepo : fsa.GirisDepo ?? fsa.CikisDepo;
                if (depo is { } d && m != 0)
                {
                    // DepoyaYaz(giren = çıkışta 0 / girişte m, çıkan = çıkışta m / girişte 0) TERSİ.
                    var giren = cikis ? 0m : m;
                    var cikan = cikis ? m : 0m;
                    var kalan = await b.TekDegerAsync<decimal?>("""
                        update public.stok_durum
                           set giren = giren - @p2, cikan = cikan - @p3, kalan = kalan - @p2 + @p3
                         where stok_id = @p0 and depo_id = @p1
                        returning kalan
                        """, tx, [fsa.StokId!.Value, d, giren, cikan], iptal);
                    if (kalan is null)
                        throw GentegreHatasi.IsKurali($"{fsa.Kod}: depo bakiye satırı bulunamadı; faturanın stok etkisi kaldırılamadı.");
                    if (kalan < 0 && !cikis)
                    {
                        if (negatifDavranis >= 2)
                            throw GentegreHatasi.IsKurali($"{fsa.Kod}: alış faturasının girişi geri alınınca depoda {kalan:0.####} kalıyor " +
                                                          "(Genel Ayarlar > Stok: negatif stok engelli).");
                        if (negatifDavranis == 1) uyarilar.Add($"{fsa.Kod}: depo bakiyesi negatife düştü ({kalan:0.####}).");
                    }
                }
                else if (depo is null)
                    uyarilar.Add($"{fsa.Kod}: satırda depo yok - fatura stok bakiyesine yazmamıştı, yalnız bağ kuruldu.");

                await b.CalistirAsync("""
                    update public.belge_satir
                       set kaynak_tur = 30, kaynak_id = @p1, stok_durum_degis = 0, degistiren = @p2
                     where id = @p0
                    """, tx, [fsa.Id, isa.Id, baglam.KullaniciId], iptal);

                satirLog.Add(string.Create(CultureInfo.InvariantCulture, $"{fsa.Id}->{isa.Id} ({fsa.Kod} {m})"));
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, fatura.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["aksiyon"] = "irsaliye-bagla-satir",
                        ["faturaSatirId"] = fsa.Id.ToString(CultureInfo.InvariantCulture),
                        ["irsaliyeSatirId"] = isa.Id.ToString(CultureInfo.InvariantCulture),
                        ["irsaliyeNo"] = isa.No,
                        ["miktar"] = LogDeposu.Metin(m),
                        ["depoId"] = depo?.ToString(CultureInfo.InvariantCulture) ?? "",
                        ["stokDurumDegis"] = "1 -> 0",
                    }, tarafId: fatura.TarafId, stokId: fsa.StokId, iptal: iptal);
            }

            // Başlık bağı (dönüşüm gibi): boşsa ilk irsaliye.
            var ilkIrsaliye = irsSatirlar[ciftler[0].IrsaliyeSatirId].BelgeId;
            if (fatura.KaynakId == 0)
                await b.CalistirAsync("""
                    update public.belge set kaynak_tur = 30, kaynak_id = @p1, degistiren = @p2
                     where id = @p0 and coalesce(kaynak_id, 0) = 0
                    """, tx, [fatura.Id, ilkIrsaliye, baglam.KullaniciId], iptal);

            var irsBelgeler = ciftler.Select(c => irsSatirlar[c.IrsaliyeSatirId]).GroupBy(x => x.BelgeId).ToList();
            var kapaliMetin = kapali.Count > 0 ? "evet" : "hayır";
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, fatura.Id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["aksiyon"] = "irsaliye-bagla",
                    ["irsaliyeler"] = string.Join(", ", irsBelgeler.Select(g => g.First().No)),
                    ["satirlar"] = string.Join("; ", satirLog),
                    ["stokEtkisi"] = "fatura satırlarının stok etkisi kaldırıldı (irsaliye düşmüştü)",
                    ["kapanmisDonem"] = kapaliMetin,
                    ["donem"] = string.Join(", ", donemler),
                    ["onay"] = istek.Onay ? "1" : "0",
                    ["kaynak"] = "irsaliye-fatura-eslesme-icmali",
                }, tarafId: fatura.TarafId, iptal: iptal);
            foreach (var g in irsBelgeler)
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, g.Key, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["aksiyon"] = "faturaya-baglandi",
                        ["faturaId"] = fatura.Id.ToString(CultureInfo.InvariantCulture),
                        ["faturaNo"] = fatura.No,
                        ["satirAdedi"] = g.Count().ToString(CultureInfo.InvariantCulture),
                        ["kapanmisDonem"] = kapaliMetin,
                        ["donem"] = string.Join(", ", donemler),
                    }, tarafId: fatura.TarafId, iptal: iptal);

            await tx.CommitAsync(iptal);
            return Results.Ok(new
            {
                faturaId = fatura.Id, faturaNo = fatura.No, baglanan = ciftler.Count,
                irsaliyeler = irsBelgeler.Select(g => new { id = g.Key, no = g.First().No }).ToList(),
                kapanmisDonem = kapali.Count > 0, donemler, uyarilar, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
