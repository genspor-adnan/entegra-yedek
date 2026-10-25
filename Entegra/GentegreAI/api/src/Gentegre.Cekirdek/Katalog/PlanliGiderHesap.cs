namespace Gentegre.Cekirdek.Katalog;

/// <summary>Planlı gider tanımının takvim + tutar kuralı (planli_gider satırı, 1177).</summary>
/// <param name="Periyot">1 haftalık · 2 aylık · 3 3 aylık · 4 6 aylık · 5 yıllık · 6 tek sefer</param>
/// <param name="OdemeGunu">Ayın günü (29-31 kısa ayda son gün); haftalıkta 1 = Pzt .. 7 = Paz.</param>
/// <param name="TatilKural">1 önceki iş günü · 2 sonraki iş günü · 0 kaydırma</param>
/// <param name="TutarTur">1 sabit · 2 son N dönem ortalaması · 3 geçen yıl aynı ay · 4 hesaplanan · 5 elle</param>
/// <param name="Tutar">KDV hariç, tanım dövizinde.</param>
public sealed record PlanliGiderTanimi(
    int Periyot, int OdemeGunu, int TatilKural, DateTime Baslangic, DateTime? Bitis, int? DonemSayisi,
    int TutarTur, int OrtalamaDonem, decimal Tutar, decimal KdvOran, decimal StopajOran);

/// <summary>Artış kuralı: geçerlilik tarihinden (dahil) sonraki dönemlere. Tür 1 oran (%) · 2 yeni tutar (KDV hariç).</summary>
public sealed record PlanliGiderArtisi(DateTime Gecerlilik, int Tur, decimal Deger);

/// <summary>
/// Saklanan dönem satırı (planli_gider_donem): istisna / gerçekleşme / dondurulmuş plan.
/// Durum 0 planlı · 1 atlandı · 3 eşleşti · 4 faturalandı. EslesenTutar tanım dövizinde nakit.
/// </summary>
public sealed record PlanliGiderSatiri(
    DateTime Vade, DateTime? PlanTarihi, decimal? PlanTutar, int Durum, decimal? ElleTutar,
    decimal? EslesenTutar, DateTime? EslesenTarih);

/// <summary>Türetilen dönem. Plan = NAKİT ÇIKIŞI (KDV dahil − stopaj), tanım dövizinde.</summary>
public sealed record PlanliGiderDonemi(
    DateTime Vade, DateTime PlanTarihi, bool Kaydirildi, string KaydirmaNedeni,
    decimal Plan, decimal KdvHaric, decimal Kdv, decimal Stopaj,
    bool Artis, bool Tahmini, bool Elle, bool Dondurulmus, PlanliGiderSatiri? Satir)
{
    public bool Atlandi => Satir?.Durum == 1;
    public bool Eslesti => Satir?.Durum is 3 or 4;
}

/// <summary>
/// PLANLI GİDER HESABI TEK YERDE (1177): dönem takvimi, tatil kaydırması ve dönem tutarı.
/// Liste, kart, takvim, Nakit Akış İcmali, dondurma ve eşleştirme hepsi BUNU çağırır -
/// ikinci bir kopya iki farklı "Kasım kirası" demekti.
///
/// <para><b>Vade</b> takvimin KAYDIRILMAMIŞ günüdür (dönem kimliği); tatil kuralı sonradan
/// değişse de dönem aynı kalır. Plan tarihi vadenin tatil / hafta sonu kaydırmasıdır.</para>
///
/// <para><b>Tutar</b>: tür kuralı → artış kuralları (geçerlilik ≤ vade) → dönemin elle tutarı
/// varsa o (karar 6: elle kazanır). Nakit çıkışı = KDV hariç × (1 + KDV) − KDV hariç × stopaj.
/// Ortalama / geçen yıl / SGK: eşleşmiş dönemlerin gerçekleşen (nakit) tutarları; yoksa tanım
/// tutarı. Elle tutar ve gerçekleşen tutarlar NAKİT tutardır; KDV hariç geriye çözülür.</para>
///
/// <para><b>Dondurulmuş</b> satır (plan_tarihi + plan_tutar dolu) tanım değişse de aynen döner.</para>
///
/// Veritabanı bilmez: tatiller <c>Func&lt;DateTime, string?&gt;</c> ile verilir (tatil adı ya da null).
/// </summary>
public static class PlanliGiderHesap
{
    private const int EnFazlaDonem = 2000;

    public static decimal Yuvarla(decimal d) => BelgeHesap.Yuvarla(d, 2);

    /// <summary>Nakit çıkışı: KDV hariç × (1 + kdv%) − KDV hariç × stopaj%.</summary>
    public static decimal Nakit(decimal kdvHaric, decimal kdvOran, decimal stopajOran)
        => Yuvarla(kdvHaric) + Yuvarla(kdvHaric * kdvOran / 100m) - Yuvarla(kdvHaric * stopajOran / 100m);

    /// <summary>Nakit tutarından KDV hariç (elle / gerçekleşen tutar için).</summary>
    public static decimal KdvHaricNakittan(decimal nakit, decimal kdvOran, decimal stopajOran)
    {
        var bolen = 1m + kdvOran / 100m - stopajOran / 100m;
        return bolen <= 0 ? nakit : Yuvarla(nakit / bolen);
    }

    /// <summary>Ayın günü kısa ayda ayın son günü.</summary>
    public static DateTime AyGunu(int yil, int ay, int gun)
        => new(yil, ay, Math.Clamp(gun, 1, DateTime.DaysInMonth(yil, ay)));

    private static int AyAdimi(int periyot) => periyot switch { 2 => 1, 3 => 3, 4 => 6, 5 => 12, _ => 0 };

    /// <summary>
    /// Kaydırılmamış vadeler, eskiden yeniye: başlangıçtan bitişe / dönem sayısına; ikisi de yoksa ufka.
    /// Başlangıçtan önce düşen ilk takvim günü atlanır (01.01'de başlayan "ayın 5'i" → 05.01).
    /// Haftalıkta ödeme günü haftanın günüdür (7'den büyükse başlangıcın günü).
    /// </summary>
    public static List<DateTime> Vadeler(PlanliGiderTanimi t, DateTime ufuk)
    {
        var sonuc = new List<DateTime>();
        var bas = t.Baslangic.Date;
        var adet = t.DonemSayisi is > 0 ? t.DonemSayisi.Value : int.MaxValue;
        // Dönem sayısı verilmişse ufuk sınır değildir (kalan taahhüt bütün dönemleri ister); bitiş her zaman sınırdır.
        var son = t.DonemSayisi is > 0 ? DateTime.MaxValue.Date : ufuk.Date;
        if (t.Bitis is { } bt && bt.Date < son) son = bt.Date;

        if (t.Periyot == 6)
        {
            if (bas <= son) sonuc.Add(bas);
            return sonuc;
        }
        if (t.Periyot == 1)
        {
            var hedef = t.OdemeGunu is >= 1 and <= 7 ? t.OdemeGunu : IsoGun(bas);
            var d = bas.AddDays((hedef - IsoGun(bas) + 7) % 7);
            while (d <= son && sonuc.Count < adet && sonuc.Count < EnFazlaDonem) { sonuc.Add(d); d = d.AddDays(7); }
            return sonuc;
        }
        var adim = AyAdimi(t.Periyot);
        if (adim == 0) return sonuc;
        for (var k = 0; sonuc.Count < adet && sonuc.Count < EnFazlaDonem; k++)
        {
            var ay = new DateTime(bas.Year, bas.Month, 1).AddMonths(k * adim);
            var v = AyGunu(ay.Year, ay.Month, t.OdemeGunu);
            if (v < bas) continue;
            if (v > son) break;
            sonuc.Add(v);
        }
        return sonuc;
    }

    /// <summary>ISO hafta günü: 1 Pazartesi .. 7 Pazar.</summary>
    public static int IsoGun(DateTime d) => ((int)d.DayOfWeek + 6) % 7 + 1;

    public static string GunAdi(DateTime d) => IsoGun(d) switch
    {
        1 => "Pazartesi", 2 => "Salı", 3 => "Çarşamba", 4 => "Perşembe", 5 => "Cuma", 6 => "Cumartesi", _ => "Pazar",
    };

    /// <summary>Türkçe sıra eki: 5'i, 10'u, 20'si, 26'sı, 3'ü.</summary>
    public static string GunEki(int n)
    {
        if (n % 10 == 0) return n switch { 10 or 30 => n + "'u", 20 => n + "'si", _ => n + "'ı" };
        return n + (n % 10) switch { 1 or 5 or 8 => "'i", 2 or 7 => "'si", 3 or 4 => "'ü", 6 => "'sı", _ => "'u" };
    }

    /// <summary>
    /// Ödeme günü: hafta sonu ya da tam gün resmi tatil ise kurala göre önceki / sonraki iş günü.
    /// Neden: "5'i cumartesi", "29'u Cumhuriyet Bayramı".
    /// </summary>
    public static (DateTime Tarih, bool Kaydirildi, string Neden) Kaydir(DateTime vade, int tatilKural,
        Func<DateTime, string?> tatil)
    {
        vade = vade.Date;
        string? Engel(DateTime d) => IsoGun(d) >= 6 ? GunAdi(d).ToLower(Tr) : tatil(d);
        var ilk = Engel(vade);
        if (ilk is null || tatilKural is not (1 or 2)) return (vade, false, "");
        var adim = tatilKural == 1 ? -1 : 1;
        var d = vade;
        for (var i = 0; i < 20 && Engel(d) is not null; i++) d = d.AddDays(adim);
        return (d, d != vade, GunEki(vade.Day) + " " + ilk);
    }

    private static readonly System.Globalization.CultureInfo Tr = System.Globalization.CultureInfo.GetCultureInfo("tr-TR");

    /// <summary>Tanım tutarına geçerliliği vadeye kadar gelen artışları sırayla uygular (KDV hariç).</summary>
    public static decimal ArtisliTutar(decimal tutar, IEnumerable<PlanliGiderArtisi> artislar, DateTime vade)
    {
        var h = tutar;
        foreach (var a in artislar.Where(x => x.Gecerlilik.Date <= vade.Date).OrderBy(x => x.Gecerlilik))
            h = a.Tur == 2 ? Yuvarla(a.Deger) : Yuvarla(h * (1m + a.Deger / 100m));
        return h;
    }

    /// <summary>
    /// Bütün dönemler (ufka / bitişe kadar), eskiden yeniye. <paramref name="hesapDegeri"/> tutar türü
    /// 4'ün dışarıdan hesaplanan NAKİT değeri (KDV İcmali ödenecek); null ise SGK kuralı (son 3
    /// gerçekleşen ortalaması), o da yoksa tanım tutarı.
    /// </summary>
    public static List<PlanliGiderDonemi> Donemler(PlanliGiderTanimi t, IReadOnlyList<PlanliGiderArtisi> artislar,
        IReadOnlyDictionary<DateTime, PlanliGiderSatiri> satirlar, Func<DateTime, string?> tatil, DateTime ufuk,
        decimal? hesapDegeri = null)
    {
        var vadeler = Vadeler(t, ufuk);
        // Kayıtlı ama takvimden düşmüş satır (tanım değişti) eşleşmiş / dondurulmuşsa yine görünür.
        foreach (var s in satirlar.Values)
            if ((s.Durum is 3 or 4 || s.PlanTutar is not null) && !vadeler.Contains(s.Vade.Date)) vadeler.Add(s.Vade.Date);
        vadeler.Sort();

        var gerceklesen = satirlar.Values.Where(s => s.Durum is 3 or 4 && s.EslesenTutar is not null)
            .OrderBy(s => s.Vade).ToList();
        var sonuc = new List<PlanliGiderDonemi>(vadeler.Count);
        DateTime? onceki = null;
        foreach (var vade in vadeler)
        {
            satirlar.TryGetValue(vade, out var satir);
            var artis = artislar.Any(a => a.Gecerlilik.Date <= vade && (onceki is null || a.Gecerlilik.Date > onceki.Value));
            onceki = vade;

            DateTime planTarihi; bool kaydirildi; string neden;
            var k = Kaydir(vade, t.TatilKural, tatil);
            if (satir?.PlanTarihi is { } dpt)
            {
                planTarihi = dpt.Date; kaydirildi = planTarihi != vade; neden = kaydirildi ? (k.Tarih == planTarihi ? k.Neden : "") : "";
            }
            else (planTarihi, kaydirildi, neden) = k;

            decimal plan; bool tahmini = false, elle = false, dondu = false;
            if (satir?.ElleTutar is { } et) { plan = et; elle = true; }
            else if (satir?.PlanTutar is { } dp) { plan = dp; dondu = true; tahmini = t.TutarTur is 2 or 3 or 4; }
            else plan = KuralTutari(t, artislar, vade, gerceklesen, hesapDegeri, out tahmini);

            var turDegeri = (t.TutarTur is 2 or 3 or 4) && !TanimTutariMi(t, vade, gerceklesen, hesapDegeri);
            var kdvHaric = elle || dondu || turDegeri
                ? KdvHaricNakittan(plan, t.KdvOran, t.StopajOran)
                : ArtisliTutar(t.Tutar, artislar, vade);
            var kdv = Yuvarla(kdvHaric * t.KdvOran / 100m);
            var stopaj = Yuvarla(kdvHaric * t.StopajOran / 100m);
            sonuc.Add(new PlanliGiderDonemi(vade, planTarihi, kaydirildi, neden, plan, kdvHaric, kdv, stopaj,
                artis && !elle && !turDegeri, tahmini, elle, satir?.PlanTutar is not null, satir));
        }
        return sonuc;
    }

    /// <summary>Tür kuralı gerçekleşen / hesaplanan bir değer bulamadı mı (tanım tutarına düştü mü).</summary>
    private static bool TanimTutariMi(PlanliGiderTanimi t, DateTime vade, List<PlanliGiderSatiri> gerceklesen, decimal? hesapDegeri)
        => t.TutarTur switch
        {
            2 => !gerceklesen.Any(s => s.Vade < vade),
            3 => !gerceklesen.Any(s => s.Vade.Year == vade.Year - 1 && s.Vade.Month == vade.Month),
            4 => hesapDegeri is null && !gerceklesen.Any(s => s.Vade < vade),
            _ => true,
        };

    /// <summary>Tür kuralının nakit tutarı (elle tutar yoksa).</summary>
    public static decimal KuralTutari(PlanliGiderTanimi t, IReadOnlyList<PlanliGiderArtisi> artislar, DateTime vade,
        IReadOnlyList<PlanliGiderSatiri> gerceklesen, decimal? hesapDegeri, out bool tahmini)
    {
        tahmini = t.TutarTur is 2 or 3 or 4 or 5;
        decimal? Ortalama(int n)
        {
            var son = gerceklesen.Where(s => s.Vade < vade).OrderByDescending(s => s.Vade).Take(Math.Max(1, n)).ToList();
            return son.Count == 0 ? null : Yuvarla(son.Average(s => s.EslesenTutar!.Value));
        }
        var deger = t.TutarTur switch
        {
            2 => Ortalama(t.OrtalamaDonem),
            3 => gerceklesen.Where(s => s.Vade.Year == vade.Year - 1 && s.Vade.Month == vade.Month)
                    .Select(s => s.EslesenTutar).FirstOrDefault(),
            4 => hesapDegeri is { } h ? Yuvarla(h) : Ortalama(3),
            _ => null,
        };
        return deger ?? Nakit(ArtisliTutar(t.Tutar, artislar, vade), t.KdvOran, t.StopajOran);
    }

    /// <summary>Bir dönemlik tutarın AYLIK karşılığı (yıllık / 3 aylık tanım aya bölünür; tek sefer 0).</summary>
    public static decimal Aylik(int periyot, decimal donemTutari) => periyot switch
    {
        1 => Yuvarla(donemTutari * 52m / 12m),
        2 => donemTutari,
        3 => Yuvarla(donemTutari / 3m),
        4 => Yuvarla(donemTutari / 6m),
        5 => Yuvarla(donemTutari / 12m),
        _ => 0m,
    };

    public static string PeriyotAdi(int p) => p switch
    {
        1 => "Haftalık", 2 => "Aylık", 3 => "3 aylık", 4 => "6 aylık", 5 => "Yıllık", 6 => "Tek sefer", _ => "",
    };

    private static readonly string[] AyAdlari =
        ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];

    public static string AyAdi(int ay) => AyAdlari[Math.Clamp(ay, 1, 12) - 1];

    /// <summary>"Aylık · ayın 5'i", "Aylık · ay sonu", "Haftalık · Cuma", "Yıllık · 15 Ocak".</summary>
    public static string PeriyotMetni(PlanliGiderTanimi t) => t.Periyot switch
    {
        1 => "Haftalık · " + GunAdi(new DateTime(2024, 1, 1).AddDays(Math.Clamp(t.OdemeGunu, 1, 7) - 1)),
        2 => "Aylık · " + (t.OdemeGunu >= 31 ? "ay sonu" : "ayın " + GunEki(t.OdemeGunu)),
        3 or 4 => PeriyotAdi(t.Periyot) + " · " + string.Join(" / ",
            Enumerable.Range(0, t.Periyot == 3 ? 4 : 2).Select(i => AyAdi((t.Baslangic.Month - 1 + i * (t.Periyot == 3 ? 3 : 6)) % 12 + 1)[..3]))
            + " " + (t.OdemeGunu >= 31 ? "ay sonu" : GunEki(t.OdemeGunu)),
        5 => "Yıllık · " + t.OdemeGunu + " " + AyAdi(t.Baslangic.Month),
        6 => "Tek sefer · " + t.Baslangic.ToString("dd.MM.yyyy"),
        _ => "",
    };

    public static string TutarTurAdi(int tur) => tur switch
    {
        1 => "Sabit", 2 => "Son N dönem ort.", 3 => "Geçen yıl aynı ay", 4 => "Hesaplanan", 5 => "Elle (her dönem)", _ => "",
    };

    public static string YontemAdi(int y) => y switch
    {
        1 => "havale", 2 => "otomatik talimat", 3 => "kredi kartı", 4 => "nakit", 5 => "vergi tahsilatı", _ => "",
    };

    /// <summary>
    /// Dönemin durumu (yanıt metni): odendi · gec · erken · planli · bugun · gecikti · atlandi ·
    /// faturalandi · beklemede (işlenmemiş banka hareketiyle eşleşti). Gün: durumun gün farkı (mutlak).
    /// </summary>
    public static (string Durum, int Gun) Durum(PlanliGiderDonemi d, DateTime bugun, bool bankaBekliyor = false)
    {
        var s = d.Satir;
        if (s?.Durum == 1) return ("atlandi", 0);
        if (s?.Durum == 4) return ("faturalandi", 0);
        if (s?.Durum == 3)
        {
            if (bankaBekliyor) return ("beklemede", 0);
            var od = (s.EslesenTarih ?? d.PlanTarihi).Date;
            var fark = (od - d.PlanTarihi).Days;
            return fark > 0 ? ("gec", fark) : fark < 0 ? ("erken", -fark) : ("odendi", 0);
        }
        var g = (d.PlanTarihi - bugun.Date).Days;
        return g < 0 ? ("gecikti", -g) : g == 0 ? ("bugun", 0) : ("planli", g);
    }

    /// <summary>"{ay} {yil} {ad}" şablonu - ödeme açıklaması.</summary>
    public static string Aciklama(string sablon, string ad, DateTime vade)
    {
        var s = string.IsNullOrWhiteSpace(sablon) ? "{ay} {yil} {ad}" : sablon;
        return s.Replace("{ay}", AyAdi(vade.Month)).Replace("{yil}", vade.Year.ToString())
                .Replace("{yıl}", vade.Year.ToString()).Replace("{ad}", ad).Trim();
    }
}
