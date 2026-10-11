using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// FATURA / e-BELGE İCMALİ (mockup Ekranlar/İcmal/fatura_ebelge_icmali.html,
/// kullanıcı 11.10.2026: "efatura icmalini mockup gibi yap").
///
/// <para><b>Belge:</b> dönemde (belge tarihi) e-Belge kaydı olan belgeler
/// (efatura_durum ≠ 0): e-Fatura 1/2, e-Arşiv 11/12, e-İrsaliye 51/52. İptal =
/// belge.durum 2; geçerli = iptal dışı. Tutarlar geçerli satış belgeleri, iade
/// (tipi 2) ayrı izlenir.</para>
///
/// <para><b>Sorunlu:</b> GİB'e gitmedi (hazır 1/11/51), gönderim hatası
/// (efatura_sonuc 3, son hata mesajı e_belge_mesaj'dan), 7 gün kuralı (belge
/// tarihinden gönderime - gönderilmediyse bugüne - 7 günden fazla) ve e-Belgesi
/// HİÇ hazırlanmamış satış faturası. Alıcı yanıtı / iptal talebi giden belgede
/// izlenmiyor (Delphi'de de yok) - o rozetler yok.</para>
///
/// <para><b>Alıcı grubu:</b> taraf.kurum = Kurum, taraf.hasta = Hasta, diğeri Firma.
/// Hasta kimlik no gösterilmez; protokol no başvurudan (kaynak tipi 30).</para>
/// </summary>
public static class EFaturaIcmalUclari
{
    private const string Kod = "efatura.icmal";

    private sealed record Belge(int Id, string No, DateTime Tarih, short Durum, short EDurum, short Sonuc, short Tipi,
        int Tur, decimal Matrah, decimal Kdv, decimal Toplam, int TarafId, string Alici, string Grup, string Protokol,
        DateTime? Gonderim, string Hata)
    {
        public string ETur => EDurum is 1 or 2 ? "e-Fatura" : EDurum is 11 or 12 ? "e-Arşiv" : EDurum is 51 or 52 ? "e-İrsaliye" : "—";
        public bool Gonderildi => EDurum is 2 or 12 or 52;
        public bool Hazir => EDurum is 1 or 11 or 51;
        public bool Iptal => Durum == 2;
        public bool Iade => Tipi == 2;
        public string Seri => No.Length >= 3 && No != "0" ? No[..3] : "—";
    }

    public static void EFaturaIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/efatura-icmal").WithTags("Fatura / e-Belge İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? tur, string? seri, string? alici,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var bugun = Saat.BugunDilim(baglam.ZamanDilimi);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            // e-Belge kaydı olan belgeler + e-Belgesi hazırlanmamış satış faturaları.
            var tum = await b.ListeAsync("""
                select bl.id, coalesce(nullif(bl.belge_no, ''), '0'), bl.belge_tarihi, coalesce(bl.durum, 0)::smallint,
                       coalesce(bl.efatura_durum, 0)::smallint, coalesce(bl.efatura_sonuc, 0)::smallint, coalesce(bl.tipi, 0)::smallint,
                       bl.tur, coalesce(bl.matrah, 0), coalesce(bl.kdv_tutari, 0), coalesce(bl.genel_toplam, 0),
                       coalesce(bl.taraf_id, 0), coalesce(nullif(bl.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), ''),
                       case when coalesce(t.hasta, 0) = 1 then 'Hasta' when coalesce(t.kurum, 0) = 1 then 'Kurum' else 'Firma' end,
                       case when kb.tur = 19 and coalesce(kb.tipi, 0) = 30 then coalesce(kb.belge_no, '') else '' end,
                       (select min(m.ekleme_tarihi) from public.e_belge_mesaj m where m.belge_id = bl.id and m.islem = 2 and m.tip = 2),
                       coalesce((select m.mesaj from public.e_belge_mesaj m where m.belge_id = bl.id and m.tip = 9
                                  order by m.id desc limit 1), '')
                  from public.belge bl
                  left join public.taraf t on t.id = bl.taraf_id
                  left join public.belge kb on kb.id = bl.kaynak_id and bl.kaynak_tur = 30
                 where bl.belge_tarihi >= @p0 and bl.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(bl.sube_id, 0) in (0, @p2))
                   and (coalesce(bl.efatura_durum, 0) <> 0 or (bl.tur = 15 and coalesce(bl.durum, 0) <> 2))
                 order by bl.belge_tarihi, bl.id
                """, null, [baslangic, bitis, sube], o => new Belge(o.GetInt32(0), o.GetString(1), o.GetDateTime(2), o.GetInt16(3),
                    o.GetInt16(4), o.GetInt16(5), o.GetInt16(6), o.GetInt16(7), o.GetDecimal(8), o.GetDecimal(9), o.GetDecimal(10),
                    o.GetInt32(11), o.GetString(12), o.GetString(13), o.GetString(14), o.IsDBNull(15) ? null : o.GetDateTime(15),
                    o.GetString(16)), iptal);

            var seriAdlari = tum.Where(x => x.EDurum != 0).Select(x => x.Seri).Where(s => s != "—").Distinct().OrderBy(s => s).ToList();
            // Süzgeçler (tür / seri / alıcı grubu).
            var liste = tum.Where(x => tur is null or "" || x.ETur == tur || (tur == "hazirlanmadi" && x.EDurum == 0))
                           .Where(x => seri is null or "" || x.Seri == seri)
                           .Where(x => alici is null or "" || x.Grup == alici).ToList();
            var eBelgeler = liste.Where(x => x.EDurum != 0).ToList();
            var gecerli = eBelgeler.Where(x => !x.Iptal).ToList();
            var satis = gecerli.Where(x => !x.Iade).ToList();

            int GunFark(Belge x) => (int)((x.Gonderim is { } g ? Saat.Yerel(g, baglam.ZamanDilimi).Date : bugun)
                                          - Saat.Yerel(x.Tarih, baglam.ZamanDilimi).Date).TotalDays;
            bool YediGun(Belge x) => !x.Iptal && x.EDurum != 0 && GunFark(x) > 7;
            string? Sorun(Belge x) => x.Iptal ? null
                : x.EDurum == 0 ? "e-Belge hazırlanmadı"
                : x.Hazir && x.Sonuc == 3 ? "Gönderim hatası"
                : x.Hazir ? "GİB'e gitmedi" : null;

            var sorunlu = liste.Where(x => Sorun(x) is not null || YediGun(x))
                .OrderBy(x => Sorun(x) is null ? 1 : 0).ThenBy(x => x.Tarih)
                .Select(x => new
                {
                    x.Id, belgeNo = x.No, tarih = x.Tarih, tur = x.ETur, x.Alici, protokol = x.Protokol, tutar = x.Toplam,
                    sorun = Sorun(x) ?? "", gun = YediGun(x) ? GunFark(x) : 0, gonderildi = x.Gonderildi,
                    aciklama = x.EDurum == 0 ? "fatura kesildi, e-Belge hazırlanmadı"
                             : x.Hazir && x.Sonuc == 3 ? Kisalt(HataOzet(x.Hata), 160)
                             : x.Hazir ? "hazırlandı, gönderilmedi"
                             : x.Gonderildi ? "geç gönderildi" : "",
                    gonderim = x.Gonderim, hazir = x.Hazir,
                }).ToList();

            var turAdlari = new[] { "e-Fatura", "e-Arşiv", "e-İrsaliye" };
            var turler = turAdlari.Select(ad =>
            {
                var k = eBelgeler.Where(x => x.ETur == ad).ToList();
                if (k.Count == 0) return null;
                object Ozet(IEnumerable<Belge> kume)
                {
                    var l = kume.ToList();
                    var g = l.Where(x => !x.Iptal).ToList();
                    var s = g.Where(x => !x.Iade).ToList();
                    return new
                    {
                        belge = s.Count, matrah = s.Sum(x => x.Matrah), kdv = s.Sum(x => x.Kdv), toplam = s.Sum(x => x.Toplam),
                        iade = g.Count(x => x.Iade), iadeTutar = g.Where(x => x.Iade).Sum(x => x.Toplam),
                        iptal = l.Count(x => x.Iptal),
                        ulasan = g.Count == 0 ? (decimal?)null : Math.Round(100m * g.Count(x => x.Gonderildi) / g.Count, 1),
                        sorunlu = l.Count(x => Sorun(x) is not null), yediGun = l.Count(YediGun),
                    };
                }
                var seriler = k.GroupBy(x => x.Seri).OrderBy(g => g.Key).Select(g => new { seri = g.Key, ozet = Ozet(g) }).ToList();
                return new { tur = ad, ozet = Ozet(k), seriler };
            }).Where(x => x is not null).ToList();

            // KDV ÖZETİ: geçerli SATIŞ faturaları (e-Fatura + e-Arşiv), iade / iptal hariç; satır bazında.
            var kdvBelgeler = satis.Where(x => x.ETur is "e-Fatura" or "e-Arşiv").ToDictionary(x => x.Id, x => x.ETur);
            var kdvSatirlar = await b.ListeAsync("""
                select s.belge_id, coalesce(s.kdv, 0)::int, coalesce(s.tutar, 0)
                  from public.belge_satir s where s.belge_id = any(@p0)
                """, null, [kdvBelgeler.Keys.ToArray()], o => (belge: o.GetInt32(0), oran: o.GetInt32(1), tutar: o.GetDecimal(2)), iptal);
            var kdvToplamMatrah = kdvSatirlar.Sum(x => x.tutar);
            var kdvOzet = kdvSatirlar.GroupBy(x => x.oran).OrderByDescending(g => g.Key == 10).ThenByDescending(g => g.Key)
                .Select(g =>
                {
                    var matrah = g.Sum(x => x.tutar);
                    return new
                    {
                        oran = g.Key, satir = g.Count(), belge = g.Select(x => x.belge).Distinct().Count(),
                        eFatura = g.Where(x => kdvBelgeler[x.belge] == "e-Fatura").Sum(x => x.tutar),
                        eArsiv = g.Where(x => kdvBelgeler[x.belge] == "e-Arşiv").Sum(x => x.tutar),
                        matrah, kdv = g.Sum(x => Math.Round(x.tutar * x.oran / 100m, 2, MidpointRounding.AwayFromZero)),
                        pay = kdvToplamMatrah == 0 ? 0 : Math.Round(100m * matrah / kdvToplamMatrah, 1),
                    };
                }).ToList();

            var toplamSatis = satis.Sum(x => x.Toplam);
            var alicilar = new[] { "Kurum", "Hasta", "Firma" }.Select(ad =>
            {
                var l = eBelgeler.Where(x => x.Grup == ad).ToList();
                var s = l.Where(x => !x.Iptal && !x.Iade).ToList();
                return new
                {
                    grup = ad, belge = s.Count, matrah = s.Sum(x => x.Matrah), kdv = s.Sum(x => x.Kdv), toplam = s.Sum(x => x.Toplam),
                    iade = l.Count(x => x.Iade && !x.Iptal), iptal = l.Count(x => x.Iptal), sorunlu = l.Count(x => Sorun(x) is not null),
                    pay = toplamSatis == 0 ? 0 : Math.Round(100m * s.Sum(x => x.Toplam) / toplamSatis, 1),
                };
            }).Where(x => x.belge + x.iade + x.iptal > 0).ToList();

            var kurumlar = satis.Where(x => x.Grup == "Kurum").GroupBy(x => (x.TarafId, x.Alici))
                .Select(g => new
                {
                    ad = g.Key.Alici, fatura = g.Count(), toplam = g.Sum(x => x.Toplam),
                    durumlar = g.Where(x => Sorun(x) is not null).GroupBy(x => Sorun(x)!).Select(d => new { ad = d.Key, adet = d.Count() }).ToList(),
                }).OrderByDescending(x => x.toplam).ToList();

            var seriKullanim = await b.ListeAsync(
                "select upper(btrim(seri)), coalesce(aciklama, '') from public.ebelge_seri where durum = 1", null, null,
                o => (seri: o.GetString(0), ad: o.GetString(1)), iptal);
            var seriler = eBelgeler.Where(x => x.Seri != "—").GroupBy(x => x.Seri).OrderBy(g => g.Key).Select(g =>
            {
                var nolar = g.Select(x => long.TryParse(x.No.Length == 16 ? x.No[7..] : "", out var n) ? n : 0).Where(n => n > 0).Distinct().OrderBy(n => n).ToList();
                var atlama = nolar.Count == 0 ? 0 : (int)(nolar[^1] - nolar[0] + 1 - nolar.Count);
                return new
                {
                    seri = g.Key, tur = string.Join(", ", g.Select(x => x.ETur).Distinct()),
                    kullanim = seriKullanim.FirstOrDefault(s => s.seri == g.Key).ad ?? "",
                    ilk = g.MinBy(x => x.No)!.No, son = g.MaxBy(x => x.No)!.No, kayit = g.Count(),
                    gecerli = g.Count(x => !x.Iptal && !x.Iade), iade = g.Count(x => x.Iade && !x.Iptal), iptal = g.Count(x => x.Iptal),
                    toplam = g.Where(x => !x.Iptal && !x.Iade).Sum(x => x.Toplam), atlama,
                };
            }).ToList();

            object Satir(Belge x) => new
            {
                x.Id, belgeNo = x.No, tarih = x.Tarih, tur = x.ETur, x.Alici, protokol = x.Protokol, matrah = x.Matrah, kdv = x.Kdv,
                toplam = x.Toplam, durum = x.Gonderildi ? "Gönderildi" : x.Hazir ? (x.Sonuc == 3 ? "Gönderim hatası" : "Hazır") : "Taslak",
            };
            var iadeler = eBelgeler.Where(x => x.Iade && !x.Iptal).Select(Satir).ToList();
            var iptaller = eBelgeler.Where(x => x.Iptal).Select(Satir).ToList();

            var gitmedi = liste.Count(x => !x.Iptal && (x.Hazir || x.EDurum == 0));
            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun },
                ozet = new
                {
                    kesilen = satis.Count, kayit = eBelgeler.Count, iptal = eBelgeler.Count(x => x.Iptal),
                    toplam = toplamSatis, matrah = satis.Sum(x => x.Matrah), kdv = satis.Sum(x => x.Kdv),
                    faturaKdv = satis.Where(x => x.ETur is "e-Fatura" or "e-Arşiv").Sum(x => x.Kdv),
                    eFatura = satis.Count(x => x.ETur == "e-Fatura"), eFaturaTutar = satis.Where(x => x.ETur == "e-Fatura").Sum(x => x.Toplam),
                    eFaturaIade = gecerli.Count(x => x.Iade && x.ETur == "e-Fatura"),
                    eArsiv = satis.Count(x => x.ETur == "e-Arşiv"), eArsivTutar = satis.Where(x => x.ETur == "e-Arşiv").Sum(x => x.Toplam),
                    eIrsaliye = satis.Count(x => x.ETur == "e-İrsaliye"), eIrsaliyeTutar = satis.Where(x => x.ETur == "e-İrsaliye").Sum(x => x.Toplam),
                    sorunlu = liste.Count(x => Sorun(x) is not null), gitmedi, hata = liste.Count(x => !x.Iptal && x.Hazir && x.Sonuc == 3),
                    hazirlanmadi = liste.Count(x => !x.Iptal && x.EDurum == 0), yediGun = liste.Count(YediGun),
                    ulasan = gecerli.Count == 0 ? (decimal?)null : Math.Round(100m * gecerli.Count(x => x.Gonderildi) / gecerli.Count, 1),
                },
                turler, sorunlu, kdvOzet, alicilar, kurumlar, seriler, iadeler, iptaller, seriAdlari,
            });
        });
    }

    /// <summary>Entegratör ham yanıtından okunur hata ("HTTP 400: {...message...}").</summary>
    private static string HataOzet(string ham)
    {
        var m = System.Text.RegularExpressions.Regex.Match(ham ?? "", "\"message\"\\s*:\\s*\"([^\"]+)\"");
        var k = System.Text.RegularExpressions.Regex.Match(ham ?? "", "\"code\"\\s*:\\s*\"?([0-9A-Z_]+)");
        return m.Success ? (k.Success ? $"{k.Groups[1].Value}: " : "") + m.Groups[1].Value : ham ?? "";
    }

    private static string Kisalt(string s, int n) => s.Length <= n ? s : s[..n] + "…";
}
