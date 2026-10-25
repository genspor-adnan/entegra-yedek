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
/// ÜRETİM İCMALİ (1176, kullanıcı 25.10.2026 - mockup Ekranlar/İcmal/uretim_icmali.html).
/// "Planı tutturuyor muyuz, fire ve sarf sapması nerede, birim maliyet plandan ne kadar saptı,
/// önümüzdeki haftalarda hangi iş merkezi dolu, hangi hammadde eksik?"
///
/// <para><b>Kaynak (429):</b> uretim_emri / _satir / uretim_operasyon / uretim_zaman /
/// uretim_maliyet. Ağaç emre kopyalanır; hesap emrin KENDİ satırlarından yapılır (ağaç sonradan
/// değişse emir bozulmaz). Plan maliyet emir açılırken donar - sapma o sabit plana karşıdır.</para>
///
/// <para><b>Maliyet:</b> kapanan emirde son uretim_maliyet kaydı (tarihli, donmuş); açık emirde
/// canlı toplam (emrin gercek_* alanları - zaman kaydı tetiği ve sarf yazar). GÜG ayrı
/// dağıtılmaz, iş merkezi saat ücretine dahildir (karar 25.10.2026) - kapanış GÜG yazmadıysa
/// sütun 0 + rozet. FASON (karar 25.10.2026): maliyet fason giriş belgesi
/// (uretim_operasyon.fason_giris_belge_id) gelince kesinleşir; giriş belgesi gelmemiş fason
/// emir "fasonda" rozetiyle döner, canlı maliyet gösterilmez.</para>
///
/// <para><b>Alt emirler</b> (karar 25.10.2026): ayrı satır, ana emrin altında girintili;
/// özet kutuları ve A4 dip toplamı yalnız ANA emirlerden (yarı mamul iki kez sayılmasın).</para>
///
/// <para><b>Malzeme ihtiyacı</b> (karar 25.10.2026): eldeki = stok_durum.kalan (Kritik Stok
/// İcmali ile aynı kaynak) − SKT'si geçmiş lot − BAŞKA kayıtların rezervi; emrin kendi rezervi
/// düşülmez, önce kendi satırını karşılar; kalan serbest stok ilk gereken tarihe göre sırayla
/// dağıtılır. Yoldaki = açık alış siparişi (Kritik Stok ile aynı sorgu).</para>
///
/// <para>Sapma eşikleri Genel Ayarlar'dan: <c>uretim.sapma_maliyet_yuzde</c> (5),
/// <c>uretim.sapma_sarf_yuzde</c> (5), <c>uretim.fire_hedef_kat</c> (1,5). Rakamlar sunucuda;
/// ekran toplamaz. Şube süzgeci kullanıcının şubeleriyle sınırlı.</para>
/// </summary>
public static class UretimIcmalUclari
{
    private const string Kod = "uretim.icmali";

    /// <summary>satinalma_talep.kaynak: 9 diğer (üretim için ayrı kod yok - 724); kaynak_tur 60 üretim emri.</summary>
    private const short TalepKaynakDiger = 9;

    private const int HaftaSayisi = 4;
    private const int IsGunuHafta = 5;

    public sealed record TalepSatiri(int StokId, decimal Miktar, int? EmirId);
    public sealed record TalepIstegi(int DepoId, List<TalepSatiri>? Satirlar, string? Aciklama);

    private static readonly string[] DurumAdlari =
        ["İptal", "Taslak", "Onaylı", "Planlandı", "Üretimde", "Kısmi", "Tamamlandı", "Kapatıldı"];
    private static readonly string[] SatirDurumAdlari = ["bekliyor", "rezerve", "kısmi sarf", "sarf edildi"];

    private static string DurumAdi(int d) => d >= 0 && d < DurumAdlari.Length ? DurumAdlari[d] : "?";
    private static string TurAdi(int t) => t switch { 1 => "siparişe", 3 => "fason", 4 => "alt emir", _ => "stoğa" };

    /// <summary>Ayardaki ondalık eşik ("1,5" / "1.5" - AyarDeposu.OndalikCoz); boş / bozuk / sıfır ve altı → varsayılan.</summary>
    private static async Task<decimal> AyarSayiAsync(NpgsqlConnection b, string anahtar, decimal varsayilan, CancellationToken iptal)
        => await AyarDeposu.OndalikAsync(b, null, anahtar, iptal) is decimal d && d > 0 ? d : varsayilan;

    private static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s)) throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    /// <summary>Stok ana birim adı (Stok icmalleriyle aynı kod listesi). Takma ad: st = stok.</summary>
    private const string BirimIfadesi = """
        coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                   where kl.kod = 'stok.ana_birim' and kd.deger = st.ana_birim order by kd.dil limit 1), '')
        """;

    /// <summary>AÇIK EMİR KÜMESİ (iş merkezi yükü + malzeme ihtiyacı): dönem ve durum seçiminden
    ///   bağımsız, ileriye bakar. @p0 şubeler · @p1 şube · @p2 tür · @p3 mamul · @p4 depo · @p5 iş merkezi.</summary>
    private const string AcikKosul = """
        e.durum between 1 and 5
           and (e.sube_id = 0 or e.sube_id = any(@p0::int[]))
           and (@p1 = 0 or e.sube_id = @p1)
           and (@p2 = 0 or e.tur = @p2)
           and (@p3 = 0 or e.stok_id = @p3)
           and (@p4 = 0 or e.sarf_depo_id = @p4 or e.mamul_depo_id = @p4)
           and (@p5 = 0 or exists (select 1 from public.uretim_operasyon ox where ox.emir_id = e.id and ox.is_merkezi_id = @p5))
        """;

    private sealed record Emir(
        int Id, string No, int Tur, int Durum, int StokId, string MamulKod, string Mamul, string Birim,
        decimal Adet, decimal Uretilen, decimal Fire, DateTime? PlanBas, DateTime? Termin, DateTime? GercekBit,
        int? UstId, string KaynakNo, int? KaynakBelgeId, decimal PlanToplam,
        decimal GMalzeme, decimal GIscilik, decimal GToplam, int SarfModu, string FireDepo, bool Eslesti,
        int FasonOp, int GirisEksik, decimal FasonTutar, Kapanis? Kapanis);

    private sealed record Kapanis(decimal Malzeme, decimal Iscilik, decimal Gug, decimal Fason, decimal Fire,
        decimal Toplam, decimal Uretilen, decimal Birim, decimal PlanBirim, decimal FarkYuzde, DateTime Tarih);

    public static void UretimIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/uretim-icmal").WithTags("Üretim İcmali").RequireAuthorization();

        // ================================================================== İCMAL ===
        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? durum, int? tur, int? sube, int? depo,
                                int? isMerkezi, int? mamul, VeriKaynagi veri, BaglamCozucu cozucu,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var bugun = Saat.Bugun.Date;
            var baslangic = (bas ?? new DateTime(bugun.Year, bugun.Month, 1)).Date;
            var bitis = (bit ?? baslangic.AddMonths(1).AddDays(-1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            if ((bitis - baslangic).TotalDays > 1100) throw GentegreHatasi.Dogrulama("Dönem en çok 3 yıl olabilir.");
            var dKod = durum is "planli" or "uretimde" or "kismi" or "tamam" ? durum : "hepsi";
            var (dMin, dMax) = dKod switch
            {
                "planli" => (1, 3), "uretimde" => (4, 4), "kismi" => (5, 5), "tamam" => (6, 7), _ => (1, 7),
            };
            var t0 = tur is 1 or 2 or 3 ? tur.Value : 0;
            var subeler = baglam.Subeler.Select(s => s.Id).ToArray();
            var s0 = SubeCoz(baglam, sube);
            var d0 = depo ?? 0;
            var im0 = isMerkezi ?? 0;
            var m0 = mamul ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var esikMaliyet = await AyarSayiAsync(b, "uretim.sapma_maliyet_yuzde", 5m, iptal);
            var esikSarf = await AyarSayiAsync(b, "uretim.sapma_sarf_yuzde", 5m, iptal);
            var fireKat = await AyarSayiAsync(b, "uretim.fire_hedef_kat", 1.5m, iptal);

            // ------------------------------------------------------- emir kümesi --
            // Süzgece uyan emirler + (özyinelemeli) alt emirleri. Alt emir ana emrin süzgecine
            //   uymasa da (tür 4, plan tarihi) ana emrin altında görünür.
            var hamEmirler = await b.ListeAsync($"""
                with recursive taban as (
                    select e.id from public.uretim_emri e
                     where e.durum <> 0
                       and (e.sube_id = 0 or e.sube_id = any(@p0::int[]))
                       and (@p1 = 0 or e.sube_id = @p1)
                       and coalesce(e.plan_bas, e.ekleme_tarihi::date) between @p2::date and @p3::date
                       and (@p4 = 0 or e.tur = @p4)
                       and (@p5 = 0 or e.stok_id = @p5)
                       and (@p6 = 0 or e.sarf_depo_id = @p6 or e.mamul_depo_id = @p6)
                       and (@p7 = 0 or exists (select 1 from public.uretim_operasyon ox where ox.emir_id = e.id and ox.is_merkezi_id = @p7))
                       and e.durum between @p8 and @p9
                ),
                kume as (
                    select id from taban
                    union
                    select e.id from public.uretim_emri e join kume k on e.ust_emir_id = k.id
                     where e.durum <> 0 and (e.sube_id = 0 or e.sube_id = any(@p0::int[]))
                )
                select e.id, coalesce(e.no, ''), e.tur, e.durum, e.stok_id, coalesce(st.kod, ''), coalesce(st.ad, ''),
                       {BirimIfadesi},
                       e.adet, e.uretilen_adet, e.fire_adet, e.plan_bas, e.termin, e.gercek_bit::date, e.ust_emir_id,
                       coalesce(kb.belge_no, ''), e.kaynak_belge_id, e.plan_toplam,
                       e.gercek_malzeme, e.gercek_iscilik, e.gercek_toplam, e.sarf_modu, coalesce(fd.ad, ''),
                       (tb.id is not null), fs.fason_op, fs.giris_eksik, fs.fason_tutar,
                       m.malzeme, m.iscilik, m.gug, m.fason, m.fire, m.toplam, m.uretilen_adet, m.birim, m.plan_birim,
                       m.fark_yuzde, m.kapanis_tarih::date
                  from (select distinct id from kume) k
                  join public.uretim_emri e on e.id = k.id
                  join public.stok st on st.id = e.stok_id
                  left join taban tb on tb.id = e.id
                  left join public.belge kb on kb.id = e.kaynak_belge_id
                  left join public.depo fd on fd.id = e.fire_depo_id
                  left join lateral (
                        select count(*) filter (where o.fason = 1)::int as fason_op,
                               count(*) filter (where o.fason = 1 and o.fason_giris_belge_id is null)::int as giris_eksik,
                               coalesce((select sum(bs.tutar) from public.belge_satir bs
                                          where bs.belge_id in (select o2.fason_giris_belge_id from public.uretim_operasyon o2
                                                                 where o2.emir_id = e.id and o2.fason = 1
                                                                   and o2.fason_giris_belge_id is not null)), 0) as fason_tutar
                          from public.uretim_operasyon o where o.emir_id = e.id) fs on true
                  left join lateral (
                        select um.* from public.uretim_maliyet um where um.emir_id = e.id
                         order by um.kapanis_tarih desc, um.id desc limit 1) m on true
                 order by e.id
                 limit 3000
                """, null, [subeler, s0, baslangic, bitis, t0, m0, d0, im0, dMin, dMax], o => new Emir(
                    o.GetInt32(0), o.GetString(1), Convert.ToInt32(o.GetValue(2)), Convert.ToInt32(o.GetValue(3)),
                    o.GetInt32(4), o.GetString(5), o.GetString(6), o.GetString(7),
                    o.GetDecimal(8), o.GetDecimal(9), o.GetDecimal(10),
                    o.IsDBNull(11) ? null : o.GetDateTime(11), o.IsDBNull(12) ? null : o.GetDateTime(12),
                    o.IsDBNull(13) ? null : o.GetDateTime(13), o.IsDBNull(14) ? null : o.GetInt32(14),
                    o.GetString(15), o.IsDBNull(16) ? null : o.GetInt32(16), o.GetDecimal(17),
                    o.GetDecimal(18), o.GetDecimal(19), o.GetDecimal(20), Convert.ToInt32(o.GetValue(21)), o.GetString(22),
                    o.GetBoolean(23), o.GetInt32(24), o.GetInt32(25), o.GetDecimal(26),
                    o.IsDBNull(27) ? null : new Kapanis(o.GetDecimal(27), o.GetDecimal(28), o.GetDecimal(29), o.GetDecimal(30),
                        o.GetDecimal(31), o.GetDecimal(32), o.GetDecimal(33), o.GetDecimal(34), o.GetDecimal(35),
                        o.GetDecimal(36), o.GetDateTime(37))), iptal);
            var sinirli = hamEmirler.Count >= 3000;
            var emirSozluk = hamEmirler.ToDictionary(x => x.Id);
            var idler = hamEmirler.Select(x => x.Id).ToArray();

            // ------------------------------------------------- emir başına türevler --
            bool Acik(Emir e) => e.Durum is >= 1 and <= 5;
            bool FasonVar(Emir e) => e.Tur == 3 || e.FasonOp > 0;
            // Fasonda: fason emir / operasyon var, emir açık, giriş belgesi (henüz) yok.
            bool Fasonda(Emir e) => FasonVar(e) && Acik(e) && (e.FasonOp == 0 || e.GirisEksik > 0);
            decimal PlanBirim(Emir e) => e.Adet > 0 ? Math.Round(e.PlanToplam / e.Adet, 4) : 0;
            int? Gecikme(Emir e)
            {
                if (e.Termin is not { } t) return null;
                if (Acik(e) && t.Date < bugun) return (int)(bugun - t.Date).TotalDays;
                if (e.Durum >= 6 && e.GercekBit is { } gb && gb.Date > t.Date) return (int)(gb.Date - t.Date).TotalDays;
                return null;
            }

            // MALİYET SATIRI: kapanış kaydı (donmuş) > fasonda (gösterilmez) > canlı.
            //   Kapanış fason tutarı yazmadıysa ve fason giriş belgesi geldiyse (karar 25.10.2026:
            //   maliyet giriş belgesiyle kesinleşir) belge tutarı fason sütununa eklenir.
            (string durum, decimal? malzeme, decimal? iscilik, decimal? gug, decimal? fason, decimal? toplam,
             decimal? birim, decimal? sapma, bool fasonEklendi) Maliyet(Emir e)
            {
                var pb = PlanBirim(e);
                if (e.Kapanis is { } k)
                {
                    var fasonEk = k.Fason == 0 && e.FasonTutar > 0;
                    var fason = fasonEk ? e.FasonTutar : k.Fason;
                    var toplam = k.Toplam + (fasonEk ? e.FasonTutar : 0);
                    var birim = fasonEk ? (k.Uretilen > 0 ? Math.Round(toplam / k.Uretilen, 4) : k.Birim) : k.Birim;
                    var planB = k.PlanBirim > 0 ? k.PlanBirim : pb;
                    decimal? sapma = planB <= 0 ? null
                                   : fasonEk ? Math.Round((birim - planB) * 100 / planB, 2) : k.FarkYuzde;
                    return ("kapandi", k.Malzeme, k.Iscilik, k.Gug, fason, toplam, birim, sapma, fasonEk);
                }
                if (Fasonda(e)) return ("fasonda", null, null, null, null, null, null, null, false);
                var canliFason = FasonVar(e) ? e.FasonTutar : 0;
                return ("acik", e.GMalzeme, e.GIscilik, 0m, canliFason, e.GToplam + canliFason, null, null, false);
            }
            decimal? KapanisBirim(Emir e) => Maliyet(e) is { durum: "kapandi", birim: { } bb } ? (decimal?)bb : null;

            // Hiyerarşik sıra: kök (ana ya da ana emri kümede olmayan) emirler plan başlangıcına göre,
            //   alt emirler hemen altında (derinlik ile girintili).
            var cocuklar = hamEmirler.Where(x => x.UstId is { } u && emirSozluk.ContainsKey(u))
                .GroupBy(x => x.UstId!.Value).ToDictionary(g => g.Key, g => g.OrderBy(x => x.PlanBas ?? DateTime.MaxValue).ThenBy(x => x.Id).ToList());
            var sirali = new List<(Emir e, int derinlik)>();
            var gezildi = new HashSet<int>();
            void Gez(Emir e, int d)
            {
                if (!gezildi.Add(e.Id)) return;
                sirali.Add((e, d));
                if (cocuklar.TryGetValue(e.Id, out var l)) foreach (var c in l) Gez(c, d + 1);
            }
            foreach (var k in hamEmirler.Where(x => x.UstId is not { } u || !emirSozluk.ContainsKey(u))
                         .OrderBy(x => x.PlanBas ?? DateTime.MaxValue).ThenBy(x => x.Id))
                Gez(k, 0);

            var emirler = sirali.Select(z =>
            {
                var e = z.e;
                var ust = e.UstId is { } u && emirSozluk.TryGetValue(u, out var ue) ? ue : null;
                return new
                {
                    id = e.Id, no = e.No, tur = e.Tur, turAd = TurAdi(e.Tur), durum = e.Durum, durumAd = DurumAdi(e.Durum),
                    stokId = e.StokId, mamulKod = e.MamulKod, mamul = e.Mamul, birim = e.Birim,
                    plan = e.Adet, uretilen = e.Uretilen, fire = e.Fire, kalan = Math.Max(0, e.Adet - e.Uretilen - e.Fire),
                    planBas = e.PlanBas, termin = e.Termin, gecikme = Gecikme(e),
                    kalanGun = Acik(e) && e.Termin is { } t && t.Date >= bugun ? (int?)(t.Date - bugun).TotalDays : null,
                    // KAYNAK: siparişe üretimde satış siparişi, alt emirde ana emir.
                    kaynak = e.UstId is not null ? (ust?.No ?? $"#{e.UstId}") : e.KaynakNo,
                    kaynakBelgeId = e.UstId is null ? e.KaynakBelgeId : null, ustEmirId = e.UstId,
                    derinlik = z.derinlik, ana = e.UstId is null, fasonda = Fasonda(e), eslesti = e.Eslesti,
                };
            }).ToList();

            // ------------------------------------------------------------- sarf --
            var satirlar = idler.Length == 0 ? [] : await b.ListeAsync($"""
                select s.id, s.emir_id, s.bilesen_stok_id, coalesce(st.kod, ''), coalesce(st.ad, ''), {BirimIfadesi},
                       s.birim_ihtiyac, s.fire_yuzde, s.gerekli, s.sarf_edilen, s.rezerve, s.birim_maliyet, s.durum
                  from public.uretim_emri_satir s join public.stok st on st.id = s.bilesen_stok_id
                 where s.emir_id = any(@p0::int[])
                 order by s.emir_id, s.sira, s.id
                """, null, [idler], o => new
                {
                    id = o.GetInt32(0), emirId = o.GetInt32(1), stokId = o.GetInt32(2), kod = o.GetString(3), ad = o.GetString(4),
                    birim = o.GetString(5), birimIhtiyac = o.GetDecimal(6), fireYuzde = o.GetDecimal(7), gerekli = o.GetDecimal(8),
                    sarfEdilen = o.GetDecimal(9), rezerve = o.GetDecimal(10), birimMaliyet = o.GetDecimal(11),
                    durum = Convert.ToInt32(o.GetValue(12)),
                }, iptal);

            // FARK = sarf − (gerekli × üretilen / plan): kısmi emirde orantılı karşılaştırılır.
            //   Tek seferde sarf (sarf_modu 1) edilmiş ve hâlâ üretimdeki emirde tüm malzeme başta
            //   çıktığı için oran anlamsızdır → "sürüyor". Hiç üretim yoksa fark yok.
            var sarf = satirlar.Select(s =>
            {
                var e = emirSozluk[s.emirId];
                var suruyor = e.Durum is 4 or 5 && e.SarfModu == 1;
                decimal? beklenen = !suruyor && e.Uretilen > 0 && e.Adet > 0 ? Math.Round(s.gerekli * e.Uretilen / e.Adet, 4) : null;
                decimal? fark = beklenen is { } bk ? Math.Round(s.sarfEdilen - bk, 4) : null;
                decimal? farkYuzde = fark is { } f && beklenen is > 0 ? Math.Round(f * 100 / beklenen.Value, 1) : null;
                return new
                {
                    satirId = s.id, s.emirId, emirNo = e.No, s.stokId, s.kod, s.ad, s.birim, s.birimIhtiyac, s.fireYuzde,
                    s.gerekli, s.sarfEdilen, beklenen, fark, farkYuzde,
                    farkTutar = fark is { } ff ? Math.Round(ff * s.birimMaliyet, 2) : (decimal?)null,
                    s.durum, durumAd = s.durum >= 0 && s.durum < SatirDurumAdlari.Length ? SatirDurumAdlari[s.durum] : "?",
                    suruyor, esikAsti = farkYuzde is { } fy && Math.Abs(fy) > esikSarf,
                };
            }).OrderByDescending(x => x.esikAsti).ThenByDescending(x => Math.Abs(x.farkTutar ?? 0)).ThenBy(x => x.emirNo).ToList();

            // ------------------------------------------------------------- fire --
            var nedenler = idler.Length == 0 ? [] : await b.ListeAsync("""
                select e.stok_id, coalesce(nullif(btrim(bs.aciklama), ''), '(neden yazılmamış)'), sum(bs.miktar), count(*)::int
                  from public.belge bl
                  join public.belge_satir bs on bs.belge_id = bl.id
                  join public.uretim_emri e on e.id = bl.kaynak_id
                 where bl.kaynak_tur = @p1 and bl.tur = @p2 and bl.kaynak_id = any(@p0::int[]) and bs.stok_id = e.stok_id
                 group by 1, 2
                """, null, [idler, BelgeTuru.KaynakTurUretimEmri, BelgeTuru.FireCikisi],
                o => (stok: o.GetInt32(0), neden: o.GetString(1), miktar: o.GetDecimal(2), adet: o.GetInt32(3)), iptal);
            // AĞAÇ HEDEFİ: emir satırlarının (ağaçtan donmuş) fire %'si, gerekliyle ağırlıklı.
            var hedefler = satirlar.GroupBy(s => emirSozluk[s.emirId].StokId).ToDictionary(g => g.Key, g =>
            {
                var top = g.Sum(s => s.gerekli);
                return top > 0 ? Math.Round(g.Sum(s => s.gerekli * s.fireYuzde) / top, 2) : (decimal?)null;
            });
            // FİRE TUTARI = fire adedi × kapanıştaki birim maliyet; kapanış yoksa plan birim (tahmini).
            (decimal tutar, bool tahmini) FireTutar(Emir e)
                => e.Fire <= 0 ? (0, false)
                 : KapanisBirim(e) is { } kb ? (Math.Round(e.Fire * kb, 2), false)
                 : (Math.Round(e.Fire * PlanBirim(e), 2), true);
            static decimal? Oran(decimal fire, decimal uretilen) => fire + uretilen > 0 ? Math.Round(fire * 100 / (fire + uretilen), 1) : null;

            var fire = hamEmirler.Where(e => e.Uretilen > 0 || e.Fire > 0).GroupBy(e => e.StokId).Select(g =>
            {
                var ilk = g.First();
                var ur = g.Sum(x => x.Uretilen);
                var fr = g.Sum(x => x.Fire);
                var oran = Oran(fr, ur);
                var hedef = hedefler.TryGetValue(g.Key, out var h) ? h : null;
                var ft = g.Select(FireTutar).ToList();
                var neden = nedenler.Where(n => n.stok == g.Key).OrderByDescending(n => n.adet).ThenByDescending(n => n.miktar).Take(2).Select(n => n.neden);
                return new
                {
                    stokId = g.Key, kod = ilk.MamulKod, ad = ilk.Mamul, birim = ilk.Birim, uretilen = ur, fire = fr, oran,
                    hedef = hedef is > 0 ? hedef : null,
                    esikAsti = oran is { } o && hedef is > 0 && o > hedef.Value * fireKat,
                    tutar = ft.Sum(x => x.tutar), tahmini = ft.Any(x => x.tahmini),
                    neden = string.Join(" · ", neden),
                    depo = string.Join(", ", g.Select(x => x.FireDepo).Where(x => x.Length > 0).Distinct()),
                    emir = g.Count(),
                };
            }).OrderByDescending(x => x.esikAsti).ThenByDescending(x => x.tutar).ThenByDescending(x => x.fire).ToList();
            var fireToplam = new
            {
                uretilen = fire.Sum(x => x.uretilen), fire = fire.Sum(x => x.fire),
                oran = Oran(fire.Sum(x => x.fire), fire.Sum(x => x.uretilen)), tutar = fire.Sum(x => x.tutar),
            };

            // ---------------------------------------------------------- maliyet --
            var maliyet = sirali
                .Where(z => z.e.Kapanis is not null || z.e.Uretilen > 0 || z.e.GToplam > 0 || Fasonda(z.e))
                .Select(z =>
                {
                    var e = z.e;
                    var m = Maliyet(e);
                    var pb = e.Kapanis is { PlanBirim: > 0 } k ? k.PlanBirim : PlanBirim(e);
                    return new
                    {
                        emirId = e.Id, no = e.No, stokId = e.StokId, mamul = e.Mamul, ana = e.UstId is null,
                        z.derinlik,
                        uretilen = e.Kapanis?.Uretilen ?? e.Uretilen, m.malzeme, m.iscilik, m.gug, m.fason, m.toplam, m.birim,
                        planBirim = pb, m.sapma, kapanis = e.Kapanis?.Tarih, m.durum, m.fasonEklendi,
                        gugYok = m.durum != "fasonda" && (m.gug ?? 0) == 0,
                        esikAsti = m.sapma is { } sp && Math.Abs(sp) > esikMaliyet,
                    };
                }).ToList();
            var anaMaliyet = maliyet.Where(x => x.ana && x.durum != "fasonda").ToList();
            var maliyetToplam = new
            {
                malzeme = anaMaliyet.Sum(x => x.malzeme ?? 0), iscilik = anaMaliyet.Sum(x => x.iscilik ?? 0),
                gug = anaMaliyet.Sum(x => x.gug ?? 0), fason = anaMaliyet.Sum(x => x.fason ?? 0),
                toplam = anaMaliyet.Sum(x => x.toplam ?? 0), fire = hamEmirler.Where(e => e.UstId is null).Sum(e => FireTutar(e).tutar),
                kapanan = anaMaliyet.Count(x => x.durum == "kapandi"), acik = anaMaliyet.Count(x => x.durum == "acik"),
                fasonda = maliyet.Count(x => x.ana && x.durum == "fasonda"),
            };

            // ------------------------------------------------ iş merkezi yükü --
            object?[] pa = [subeler, s0, t0, m0, d0, im0, bugun];
            var operasyonlar = await b.ListeAsync($"""
                select o.id, o.emir_id, coalesce(e.no, ''), coalesce(o.ad, ''), coalesce(o.is_merkezi_id, 0),
                       greatest(0, o.plan_saat - o.gercek_saat),
                       coalesce(o.bas::date, e.plan_bas, @p6::date), coalesce(o.bit::date, e.termin, e.plan_bas, @p6::date)
                  from public.uretim_operasyon o
                  join public.uretim_emri e on e.id = o.emir_id
                 where {AcikKosul}
                   and o.durum < 4 and o.plan_saat > o.gercek_saat
                   and (@p5 = 0 or o.is_merkezi_id = @p5)
                 order by 7, o.emir_id, o.sira
                 limit 5000
                """, null, pa, o => (id: o.GetInt32(0), emirId: o.GetInt32(1), emirNo: o.GetString(2), ad: o.GetString(3),
                    im: o.GetInt32(4), saat: o.GetDecimal(5), bas: o.GetDateTime(6), bit: o.GetDateTime(7)), iptal);
            var merkezler = await b.ListeAsync("""
                select im.id, coalesce(im.kod, ''), coalesce(im.ad, ''), im.gunluk_kapasite_saat, im.saat_ucreti, im.fason,
                       coalesce((select sum(z.sure_saat) from public.uretim_zaman z
                                   join public.uretim_operasyon o on o.id = z.operasyon_id
                                  where o.is_merkezi_id = im.id and z.tur = 2
                                    and coalesce(z.bas, z.ekleme_tarihi)::date >= date_trunc('month', @p1::date)::date
                                    and coalesce(z.bas, z.ekleme_tarihi)::date <= @p1::date), 0)
                  from public.is_merkezi im
                 where im.durum = 0 and (im.sube_id = 0 or im.sube_id = any(@p0::int[])) and (@p2 = 0 or im.id = @p2)
                 order by im.kod, im.ad
                """, null, [subeler, bugun, im0], o => (id: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2),
                    gunluk: o.GetDecimal(3), ucret: o.GetDecimal(4), fason: Convert.ToInt32(o.GetValue(5)), durus: o.GetDecimal(6)), iptal);

            // YAYMA: operasyonun kalan plan saati başlangıç - bitiş arasındaki iş günlerine (Pzt-Cum)
            //   eşit bölünür; geçmişte kalan (gecikmiş) yük bu haftaya düşer. Son hücre = sonrası.
            var w0 = bugun.AddDays(-(((int)bugun.DayOfWeek + 6) % 7));
            decimal[] Yay(DateTime bs0, DateTime bt0, decimal saat)
            {
                var h = new decimal[HaftaSayisi + 1];
                var b0 = bs0.Date < w0 ? w0 : bs0.Date;
                var b1 = bt0.Date < b0 ? b0 : bt0.Date;
                if ((b1 - b0).TotalDays > 366) b1 = b0.AddDays(366);
                var gunler = new List<DateTime>();
                for (var g = b0; g <= b1; g = g.AddDays(1))
                    if (g.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)) gunler.Add(g);
                if (gunler.Count == 0) gunler.Add(b0);
                var pay = saat / gunler.Count;
                foreach (var g in gunler) h[Math.Min(HaftaSayisi, (int)((g - w0).TotalDays / 7))] += pay;
                return h.Select(x => Math.Round(x, 2)).ToArray();
            }
            var opYuk = operasyonlar.Select(x => new
            {
                x.id, x.emirId, x.emirNo, x.ad, isMerkeziId = x.im, saat = Math.Round(x.saat, 2),
                bas = x.bas, bit = x.bit, haftalar = Yay(x.bas, x.bit, x.saat),
            }).ToList();
            // KAPASİTE / HAFTA = iş merkezi kartındaki günlük kapasite × 5 iş günü.
            var merkezTanim = merkezler.Select(m => (id: m.id, kod: m.kod, ad: m.ad, kapasite: Math.Round(m.gunluk * IsGunuHafta, 2),
                ucret: m.ucret, fason: m.fason, durus: m.durus)).ToList();
            bool Atanmamis(int imId) => imId == 0 || merkezler.All(mm => mm.id != imId);
            if (opYuk.Any(x => Atanmamis(x.isMerkeziId)))
                merkezTanim.Add((0, "", "(iş merkezi atanmamış)", 0m, 0m, 0, 0m));
            var merkezSatirlari = merkezTanim
                .Select(m =>
                {
                    var ops = opYuk.Where(x => m.id == 0 ? Atanmamis(x.isMerkeziId) : x.isMerkeziId == m.id).ToList();
                    var hucreler = Enumerable.Range(0, HaftaSayisi + 1).Select(i =>
                    {
                        var saat = ops.Sum(x => x.haftalar[i]);
                        return new { saat, oran = m.kapasite > 0 ? Math.Round(saat * 100 / m.kapasite, 0) : (decimal?)null, operasyon = ops.Count(x => x.haftalar[i] > 0) };
                    }).ToList();
                    return new
                    {
                        m.id, m.kod, m.ad, m.kapasite, fason = m.fason == 1, ucretYok = m.id > 0 && m.ucret == 0,
                        durus = Math.Round(m.durus, 2), hucreler, toplamSaat = ops.Sum(x => x.saat),
                    };
                }).ToList();
            var haftalar = Enumerable.Range(0, HaftaSayisi).Select(i => new { bas = w0.AddDays(7 * i), bit = w0.AddDays(7 * i + 6) }).ToList();
            var pencereSaat = merkezSatirlari.Where(x => x.kapasite > 0).Sum(x => x.hucreler.Take(HaftaSayisi).Sum(h => h.saat));
            var pencereKapasite = merkezSatirlari.Sum(x => x.kapasite) * HaftaSayisi;

            // ------------------------------------------------- malzeme ihtiyacı --
            // Yarı mamul satırı (alt emri olan) satınalmayla değil alt emirle karşılanır - ihtiyaca girmez.
            var ihtiyac = await b.ListeAsync($"""
                select s.id, s.emir_id, coalesce(e.no, ''), s.bilesen_stok_id, coalesce(st.kod, ''), coalesce(st.ad, ''), {BirimIfadesi},
                       coalesce(s.depo_id, e.sarf_depo_id, 0), coalesce(d.ad, ''), s.gerekli, s.sarf_edilen, s.rezerve,
                       coalesce(e.plan_bas, e.termin, @p6::date), s.birim_maliyet
                  from public.uretim_emri_satir s
                  join public.uretim_emri e on e.id = s.emir_id
                  join public.stok st on st.id = s.bilesen_stok_id
                  left join public.depo d on d.id = coalesce(s.depo_id, e.sarf_depo_id)
                 where {AcikKosul}
                   and s.gerekli > s.sarf_edilen and s.alt_emir_id is null
                """, null, pa, o => (id: o.GetInt32(0), emirId: o.GetInt32(1), emirNo: o.GetString(2), stok: o.GetInt32(3),
                    kod: o.GetString(4), ad: o.GetString(5), birim: o.GetString(6), depo: o.GetInt32(7), depoAd: o.GetString(8),
                    gerekli: o.GetDecimal(9), sarf: o.GetDecimal(10), rezerve: o.GetDecimal(11), tarih: o.GetDateTime(12),
                    maliyet: o.GetDecimal(13)), iptal);
            var anahtarlar = ihtiyac.Select(x => (x.stok, x.depo)).Distinct().ToList();
            var bakiye = anahtarlar.Count == 0 ? [] : await b.ListeAsync("""
                select k.stok_id, k.depo_id, coalesce(sd.kalan, 0), coalesce(sd.rezerve, 0),
                       coalesce((select sum(ld.kalan) from public.stok_lot_durum ld
                                   join public.stok_seri_lot l on l.id = ld.seri_lot_id
                                  where ld.stok_id = k.stok_id and ld.depo_id = k.depo_id and ld.kalan > 0
                                    and l.son_kullanma_tarihi is not null and l.son_kullanma_tarihi::date < @p2::date), 0),
                       coalesce((select sum(case when coalesce(bs.miktar, 0) <> 0 then bs.miktar else coalesce(bs.adet, 0) end)
                                   from public.belge_satir bs
                                   join public.belge bl on bl.id = bs.belge_id
                                   join public.belge_satinalma bsa on bsa.id = bl.id
                                   join public.depo dd on dd.id = k.depo_id
                                  where bl.tur = 9 and coalesce(bsa.takip_durum, 0) in (0, 1) and bs.stok_id = k.stok_id
                                    and (coalesce(bs.giris_depo_id, bl.giris_depo_id) = k.depo_id
                                         or (coalesce(bs.giris_depo_id, bl.giris_depo_id) is null and bl.sube_id = dd.sube_id))), 0),
                       coalesce((select string_agg(distinct coalesce(nullif(t.talep_no, ''), '#' || t.id), ', ')
                                   from public.satinalma_talep_satir ts
                                   join public.satinalma_talep t on t.id = ts.talep_id
                                   join public.depo dd on dd.id = k.depo_id
                                  where t.durum in (0, 1, 2, 4) and ts.stok_id = k.stok_id and ts.belge_satir_id is null
                                    and t.sube_id = coalesce(dd.sube_id, 0)), '')
                  from unnest(@p0::int[], @p1::int[]) as k(stok_id, depo_id)
                  left join public.stok_durum sd on sd.stok_id = k.stok_id and sd.depo_id = k.depo_id
                """, null, [anahtarlar.Select(x => x.stok).ToArray(), anahtarlar.Select(x => x.depo).ToArray(), bugun],
                o => (stok: o.GetInt32(0), depo: o.GetInt32(1), kalan: o.GetDecimal(2), rezerve: o.GetDecimal(3),
                      skt: o.GetDecimal(4), yolda: o.GetDecimal(5), talep: o.GetString(6)), iptal);
            var bakSozluk = bakiye.ToDictionary(x => (x.stok, x.depo));

            var malzeme = ihtiyac.GroupBy(x => (x.stok, x.depo)).Select(g =>
            {
                var ilk = g.First();
                var bk = bakSozluk.TryGetValue(g.Key, out var v) ? v : default;
                var sktGecmis = Math.Min(bk.skt, Math.Max(0, bk.kalan));
                var kendiRezerv = g.Sum(x => x.rezerve);
                // BAŞKA REZERV (bu kümenin dışındaki emirler ve diğer kayıtlar) eldekinden düşülür;
                //   kümenin kendi rezervi düşülmez.
                var baskaRezerv = Math.Max(0, bk.rezerve - kendiRezerv);
                var eldeki = Math.Max(0, bk.kalan - sktGecmis - baskaRezerv);
                // DAĞITIM: her satırı önce kendi rezervi karşılar, kalan serbest stok ilk gereken tarihe göre.
                var serbest = Math.Max(0, eldeki - kendiRezerv);
                var acik = new List<(int emirId, string emirNo, DateTime tarih, decimal eksik)>();
                foreach (var x in g.OrderBy(x => x.tarih).ThenBy(x => x.emirId).ThenBy(x => x.id))
                {
                    var kalanIhtiyac = Math.Max(0, x.gerekli - x.sarf - Math.Min(x.rezerve, Math.Max(0, x.gerekli - x.sarf)));
                    var al = Math.Min(serbest, kalanIhtiyac);
                    serbest -= al;
                    if (kalanIhtiyac - al > 0) acik.Add((x.emirId, x.emirNo, x.tarih, kalanIhtiyac - al));
                }
                var karsilanmayan = acik.Sum(x => x.eksik);
                var eksik = Math.Max(0, karsilanmayan - bk.yolda);
                return new
                {
                    stokId = g.Key.stok, ilk.kod, ilk.ad, ilk.birim, depoId = g.Key.depo, depo = ilk.depoAd,
                    ihtiyac = g.Sum(x => x.gerekli - x.sarf), rezerve = kendiRezerv, eldeki, sktGecmis, baskaRezerv,
                    yoldaki = bk.yolda, eksik, karsilanmayan,
                    ilkGereken = acik.Count > 0 ? acik.Min(x => x.tarih) : g.Min(x => x.tarih),
                    emirler = g.GroupBy(x => (x.emirId, x.emirNo)).Select(e => new
                    {
                        id = e.Key.emirId, no = e.Key.emirNo, eksik = acik.Where(a => a.emirId == e.Key.emirId).Sum(a => a.eksik),
                    }).OrderByDescending(e => e.eksik).ThenBy(e => e.no).ToList(),
                    talep = bk.talep ?? "", birimMaliyet = g.Max(x => x.maliyet),
                    eksikTutar = Math.Round(eksik * g.Max(x => x.maliyet), 2),
                };
            }).OrderByDescending(x => x.eksik > 0).ThenBy(x => x.ilkGereken).ThenBy(x => x.ad).ToList();

            // ------------------------------------------------------------- özet --
            // ÖZET YALNIZ ANA EMİRLER (karar 25.10.2026): yarı mamul iki kez sayılmasın; süzgece
            //   uymayıp ana emrin altında gelen alt emir zaten ana değildir.
            var ana = hamEmirler.Where(e => e.UstId is null && e.Eslesti).ToList();
            var kapanan = ana.Select(e => (e, m: Maliyet(e))).Where(x => x.m.durum == "kapandi" && x.m.toplam is not null).ToList();
            var kapananPlan = kapanan.Sum(x => (x.e.Kapanis!.PlanBirim > 0 ? x.e.Kapanis.PlanBirim : PlanBirim(x.e)) * x.e.Kapanis.Uretilen);
            var gecikenler = ana.Where(e => Acik(e) && e.Termin is { } t && t.Date < bugun).ToList();
            var ozet = new
            {
                emir = ana.Count, siparise = ana.Count(e => e.Tur == 1), stoga = ana.Count(e => e.Tur == 2), fason = ana.Count(e => e.Tur == 3),
                altEmir = hamEmirler.Count(e => e.UstId is not null),
                acik = ana.Count(Acik), uretimde = ana.Count(e => e.Durum == 4), kismi = ana.Count(e => e.Durum == 5),
                planli = ana.Count(e => e.Durum is >= 1 and <= 3), tamamlanan = ana.Count(e => e.Durum >= 6),
                plan = ana.Sum(e => e.Adet), uretilen = ana.Sum(e => e.Uretilen),
                gerceklesme = ana.Sum(e => e.Adet) > 0 ? Math.Round(ana.Sum(e => e.Uretilen) * 100 / ana.Sum(e => e.Adet), 1) : (decimal?)null,
                fire = ana.Sum(e => e.Fire), fireOran = Oran(ana.Sum(e => e.Fire), ana.Sum(e => e.Uretilen)),
                fireTutar = ana.Sum(e => FireTutar(e).tutar),
                maliyetSapma = kapananPlan > 0 ? Math.Round((kapanan.Sum(x => x.m.toplam!.Value) - kapananPlan) * 100 / kapananPlan, 1) : (decimal?)null,
                kapanan = kapanan.Count,
                doluluk = pencereKapasite > 0 ? Math.Round(pencereSaat * 100 / pencereKapasite, 0) : (decimal?)null,
                terminGecen = gecikenler.Count,
                enEskiGecikme = gecikenler.Count > 0 ? gecikenler.Max(e => (int)(bugun - e.Termin!.Value.Date).TotalDays) : (int?)null,
                eksikKalem = malzeme.Count(x => x.eksik > 0), eksikTutar = malzeme.Sum(x => x.eksikTutar),
                fasonda = ana.Count(Fasonda), isMerkezi = merkezSatirlari.Count(x => x.id > 0),
            };

            // --------------------------------------------------------------- A4 --
            var a4Mamuller = ana.GroupBy(e => e.StokId).Select(g =>
            {
                var ilk = g.First();
                var kp = g.Select(e => (e, m: Maliyet(e))).Where(x => x.m.durum == "kapandi" && x.e.Kapanis!.Uretilen > 0).ToList();
                var kpUr = kp.Sum(x => x.e.Kapanis!.Uretilen);
                var kpPlan = kp.Sum(x => (x.e.Kapanis!.PlanBirim > 0 ? x.e.Kapanis.PlanBirim : PlanBirim(x.e)) * x.e.Kapanis.Uretilen);
                var kpTop = kp.Sum(x => x.m.toplam ?? 0);
                return new
                {
                    stokId = g.Key, kod = ilk.MamulKod, ad = ilk.Mamul, plan = g.Sum(e => e.Adet), uretilen = g.Sum(e => e.Uretilen),
                    fireOran = Oran(g.Sum(e => e.Fire), g.Sum(e => e.Uretilen)),
                    birim = kpUr > 0 ? Math.Round(kpTop / kpUr, 2) : (decimal?)null,
                    sapma = kpPlan > 0 ? Math.Round((kpTop - kpPlan) * 100 / kpPlan, 1) : (decimal?)null,
                };
            }).OrderByDescending(x => x.uretilen).ThenBy(x => x.ad).ToList();

            // ---------------------------------------------------------- seçimler --
            var depoListesi = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.depo d
                 where d.durum = 1 and (d.sube_id is null or d.sube_id = any(@p0::int[])) order by d.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var isMerkezleri = await b.ListeAsync("""
                select im.id, coalesce(nullif(btrim(coalesce(im.kod, '') || ' · ' || coalesce(im.ad, '')), '·'), '?')
                  from public.is_merkezi im
                 where im.durum = 0 and (im.sube_id = 0 or im.sube_id = any(@p0::int[])) order by im.kod, im.ad
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var mamuller = await b.ListeAsync("""
                select st.id, coalesce(nullif(btrim(coalesce(st.kod, '') || ' · ' || coalesce(st.ad, '')), '·'), '?')
                  from public.stok st
                 where st.id in (select e.stok_id from public.uretim_emri e
                                  where e.durum <> 0 and (e.sube_id = 0 or e.sube_id = any(@p0::int[])))
                 order by st.ad limit 500
                """, null, [subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, durum = dKod, tur = t0, sube = s0, depo = d0, isMerkezi = im0, mamul = m0,
                bugun, esikler = new { maliyet = esikMaliyet, sarf = esikSarf, fireKat },
                ozet, emirler, sinirli, sarf, fire, fireToplam, maliyet, maliyetToplam,
                yuk = new { haftalar, merkezler = merkezSatirlari, operasyonlar = opYuk, kapasiteGun = IsGunuHafta },
                malzeme,
                a4 = new { mamuller = a4Mamuller, dip = maliyetToplam },
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    depolar = depoListesi, isMerkezleri, mamuller,
                },
                yetkiler = new
                {
                    talep = baglam.Yetkiler.Var("satinalma.talep", Islem.Ekle),
                    emir = baglam.Yetkiler.Var("uretim", Islem.Gor),
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ------------------------------------------- eksik hammaddeden talep --
        // TASLAK satınalma talebi (durum 0) - Kritik Stok İcmali'nin talebiyle aynı biçim; kaynak 9
        //   (diğer), kaynak_tur 60 üretim emri, kaynak_id ilk emir. Açık talebi olan kalem ATLANIR.
        grup.MapPost("/talep", async (TalepIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                      HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste("satinalma.talep", Islem.Ekle);
            var satirlar = TaslakTalep.Suz(istek.Satirlar, x => x.StokId, x => x.Miktar);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var (subeId, depoAd) = await TaslakTalep.DepoAsync(b, islem, baglam, istek.DepoId, iptal);

            // Kaynak emir(ler): kullanıcının şubelerinde, açık olmalı.
            var emirIdleri = satirlar.Where(x => x.EmirId is > 0).Select(x => x.EmirId!.Value).Distinct().ToArray();
            var emirler = emirIdleri.Length == 0 ? [] : await b.ListeAsync("""
                select e.id, coalesce(e.no, '') from public.uretim_emri e
                 where e.id = any(@p0::int[]) and e.durum between 1 and 5
                   and (e.sube_id = 0 or e.sube_id = any(@p1::int[]))
                """, islem, [emirIdleri, baglam.Subeler.Select(s => s.Id).ToArray()], o => (id: o.GetInt32(0), no: o.GetString(1)), iptal);
            if (emirler.Count != emirIdleri.Length) throw GentegreHatasi.Bulunamadi("Üretim emri bulunamadı ya da açık değil.");
            string EmirNo(int? id) => emirler.FirstOrDefault(e => e.id == id).no ?? "";
            var ilkEmir = satirlar.Select(x => x.EmirId).FirstOrDefault(x => x is > 0);
            var emirNolari = string.Join(", ", emirler.Select(x => x.no).Where(x => x.Length > 0).Take(10));

            var sonuc = await TaslakTalep.AcAsync(b, islem, log, baglam, subeId, depoAd, istek.DepoId,
                satirlar.Select(x => new TaslakTalep.Kalem(x.StokId, x.Miktar,
                    EmirNo(x.EmirId) is { Length: > 0 } en ? "emir " + en : "",
                    new { x.StokId, x.Miktar, x.EmirId })).ToList(),
                new TaslakTalep.Tanim(Kaynak: TalepKaynakDiger, KaynakTur: (short)BelgeTuru.KaynakTurUretimEmri,
                    KaynakId: ilkEmir is > 0 ? ilkEmir.Value : null, DepartmanId: null,
                    GerekceOnEki: "Üretim eksik hammadde", Icmal: "Üretim İcmali",
                    MiktarNotu: "miktar: eksik = kalan ihtiyaç − eldeki − yoldaki",
                    NotEki: emirNolari.Length > 0 ? " · emir: " + emirNolari : "",
                    LogKaynak: "uretim-icmali", LogEk: new { emirler = emirIdleri }),
                istek.Aciklama, iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id = sonuc.Id, talepNo = sonuc.TalepNo, kalem = sonuc.Kalem, atlanan = sonuc.Atlananlar.Count,
                atlananlar = sonuc.Atlananlar, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
