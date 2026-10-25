using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// PLANLI GİDER HESABI (1177) - dönem takvimi, kısa ay, tatil kaydırması, artış, elle tutar
/// önceliği, ortalama / geçen yıl, stopaj / KDV. VERİTABANI GEREKTİRMEZ: tatiller fonksiyonla verilir.
/// </summary>
public sealed class PlanliGiderHesapTestleri
{
    private static DateTime G(int y, int a, int g) => new(y, a, g);

    private static PlanliGiderTanimi Tanim(int periyot = 2, int gun = 5, int tatil = 2, DateTime? bas = null, DateTime? bit = null,
        int? adet = null, int tur = 1, int ort = 3, decimal tutar = 1000m, decimal kdv = 0m, decimal stopaj = 0m)
        => new(periyot, gun, tatil, bas ?? G(2026, 1, 1), bit, adet, tur, ort, tutar, kdv, stopaj);

    private static readonly Func<DateTime, string?> TatilYok = _ => null;
    private static readonly Dictionary<DateTime, PlanliGiderSatiri> Bos = new();

    [Fact]
    public void Aylik_vadeler_baslangictan_ve_bitise_kadar()
    {
        var v = PlanliGiderHesap.Vadeler(Tanim(bas: G(2026, 1, 10), bit: G(2026, 6, 30)), G(2030, 1, 1));
        // 05.01 başlangıçtan önce: ilk vade 05.02.
        Assert.Equal([G(2026, 2, 5), G(2026, 3, 5), G(2026, 4, 5), G(2026, 5, 5), G(2026, 6, 5)], v);
    }

    [Fact]
    public void Kisa_ayda_ayin_son_gunu()
    {
        var v = PlanliGiderHesap.Vadeler(Tanim(gun: 31, bas: G(2027, 1, 1), adet: 4), G(2027, 12, 31));
        Assert.Equal([G(2027, 1, 31), G(2027, 2, 28), G(2027, 3, 31), G(2027, 4, 30)], v);
        var artik = PlanliGiderHesap.Vadeler(Tanim(gun: 30, bas: G(2028, 2, 1), adet: 1), G(2028, 12, 31));
        Assert.Equal([G(2028, 2, 29)], artik);
    }

    [Fact]
    public void Periyotlar_haftalik_uc_aylik_yillik_tek_sefer()
    {
        // Haftalık, Cuma (5): 01.01.2026 Perşembe → ilk 02.01.
        Assert.Equal([G(2026, 1, 2), G(2026, 1, 9), G(2026, 1, 16)],
            PlanliGiderHesap.Vadeler(Tanim(periyot: 1, gun: 5, adet: 3), G(2027, 1, 1)));
        Assert.Equal([G(2026, 1, 1), G(2026, 4, 1), G(2026, 7, 1), G(2026, 10, 1)],
            PlanliGiderHesap.Vadeler(Tanim(periyot: 3, gun: 1, bit: G(2026, 12, 31)), G(2030, 1, 1)));
        Assert.Equal([G(2026, 1, 15), G(2027, 1, 15)],
            PlanliGiderHesap.Vadeler(Tanim(periyot: 5, gun: 15, bit: G(2027, 6, 1)), G(2030, 1, 1)));
        Assert.Equal([G(2026, 3, 9)], PlanliGiderHesap.Vadeler(Tanim(periyot: 6, bas: G(2026, 3, 9)), G(2030, 1, 1)));
    }

    [Fact]
    public void Suresiz_tanim_ufukta_durur_donem_sayisi_ufku_asar()
    {
        Assert.Equal(12, PlanliGiderHesap.Vadeler(Tanim(), G(2026, 12, 31)).Count);
        Assert.Equal(36, PlanliGiderHesap.Vadeler(Tanim(adet: 36), G(2026, 12, 31)).Count);
    }

    [Fact]
    public void Hafta_sonu_ve_tatil_kaydirmasi()
    {
        // 05.12.2026 Cumartesi.
        var s = PlanliGiderHesap.Kaydir(G(2026, 12, 5), 2, TatilYok);
        Assert.Equal((G(2026, 12, 7), true, "5'i cumartesi"), s);
        Assert.Equal(G(2026, 12, 4), PlanliGiderHesap.Kaydir(G(2026, 12, 5), 1, TatilYok).Tarih);
        Assert.Equal((G(2026, 12, 5), false, ""), PlanliGiderHesap.Kaydir(G(2026, 12, 5), 0, TatilYok));

        // 29.10.2026 Perşembe tatil; sonraki iş günü Cuma 30.10. Tatil + hafta sonu zinciri: Cuma tatilse Pazartesi.
        Func<DateTime, string?> tatil = d => d == G(2026, 10, 29) ? "Cumhuriyet Bayramı" : d == G(2026, 10, 30) ? "Köprü" : null;
        var k = PlanliGiderHesap.Kaydir(G(2026, 10, 29), 2, tatil);
        Assert.Equal(G(2026, 11, 2), k.Tarih);
        Assert.Equal("29'u Cumhuriyet Bayramı", k.Neden);
        Assert.Equal(G(2026, 10, 28), PlanliGiderHesap.Kaydir(G(2026, 10, 29), 1, tatil).Tarih);
    }

    [Fact]
    public void Donemler_plan_tarihi_kaydirilir_vade_kaydirilmaz()
    {
        var d = PlanliGiderHesap.Donemler(Tanim(bas: G(2026, 12, 1), adet: 1), [], Bos, TatilYok, G(2027, 12, 31));
        Assert.Single(d);
        Assert.Equal(G(2026, 12, 5), d[0].Vade);
        Assert.Equal(G(2026, 12, 7), d[0].PlanTarihi);
        Assert.True(d[0].Kaydirildi);
    }

    [Fact]
    public void Artis_gecerlilikten_sonraki_donemlere_oran_ve_yeni_tutar()
    {
        List<PlanliGiderArtisi> artis = [new(G(2026, 3, 1), 1, 30m), new(G(2026, 5, 5), 2, 2000m), new(G(2026, 6, 1), 1, 10m)];
        var d = PlanliGiderHesap.Donemler(Tanim(tutar: 1000m, adet: 7), artis, Bos, TatilYok, G(2030, 1, 1));
        Assert.Equal([1000m, 1000m, 1300m, 1300m, 2000m, 2200m, 2200m], d.Select(x => x.KdvHaric));
        Assert.Equal([false, false, true, false, true, true, false], d.Select(x => x.Artis));
    }

    [Fact]
    public void Nakit_kdv_dahil_eksi_stopaj()
    {
        Assert.Equal(102000m, PlanliGiderHesap.Nakit(85000m, 20m, 0m));
        // Şahıstan kira: brüt 10.000, stopaj %20 → 8.000 (KDV yok).
        Assert.Equal(8000m, PlanliGiderHesap.Nakit(10000m, 0m, 20m));
        Assert.Equal(11000m, PlanliGiderHesap.Nakit(10000m, 20m, 10m));
        Assert.Equal(10000m, PlanliGiderHesap.KdvHaricNakittan(11000m, 20m, 10m));
        var d = PlanliGiderHesap.Donemler(Tanim(tutar: 10000m, kdv: 20m, stopaj: 10m, adet: 1), [], Bos, TatilYok, G(2030, 1, 1))[0];
        Assert.Equal((11000m, 10000m, 2000m, 1000m), (d.Plan, d.KdvHaric, d.Kdv, d.Stopaj));
    }

    [Fact]
    public void Elle_tutar_kural_ve_dondurulmus_plandan_once_gelir()
    {
        var satir = new Dictionary<DateTime, PlanliGiderSatiri>
        {
            [G(2026, 2, 5)] = new(G(2026, 2, 5), null, null, 0, 777m, null, null),
            [G(2026, 3, 5)] = new(G(2026, 3, 5), G(2026, 3, 6), 999m, 0, null, null, null),
            [G(2026, 4, 5)] = new(G(2026, 4, 5), G(2026, 4, 6), 999m, 0, 555m, null, null),
        };
        var d = PlanliGiderHesap.Donemler(Tanim(tutar: 1000m, adet: 4), [new(G(2026, 1, 1), 1, 50m)], satir, TatilYok, G(2030, 1, 1));
        Assert.Equal([1500m, 777m, 999m, 555m], d.Select(x => x.Plan));
        Assert.True(d[1].Elle);
        Assert.True(d[2].Dondurulmus);
        Assert.Equal(G(2026, 3, 6), d[2].PlanTarihi);   // dondurulmuş plan tarihi aynen
        Assert.False(d[1].Tahmini);
    }

    [Fact]
    public void Son_n_donem_ortalamasi_gerceklesenden_yoksa_tanimdan()
    {
        var satir = new Dictionary<DateTime, PlanliGiderSatiri>
        {
            [G(2026, 1, 5)] = new(G(2026, 1, 5), G(2026, 1, 5), 1000m, 3, null, 900m, G(2026, 1, 5)),
            [G(2026, 2, 5)] = new(G(2026, 2, 5), G(2026, 2, 5), 1000m, 4, null, 1200m, G(2026, 2, 5)),
            [G(2026, 3, 5)] = new(G(2026, 3, 5), G(2026, 3, 5), 1000m, 1, null, null, null),   // atlandı - sayılmaz
        };
        var d = PlanliGiderHesap.Donemler(Tanim(tur: 2, ort: 2, tutar: 1000m, adet: 5), [], satir, TatilYok, G(2030, 1, 1));
        Assert.Equal(1050m, d[3].Plan);     // (900 + 1200) / 2
        Assert.True(d[3].Tahmini);
        Assert.True(d[2].Atlandi);
        var ilk = PlanliGiderHesap.Donemler(Tanim(tur: 2, tutar: 1000m, kdv: 10m, adet: 1), [], Bos, TatilYok, G(2030, 1, 1))[0];
        Assert.Equal(1100m, ilk.Plan);       // gerçekleşen yok: tanım tutarı + KDV
    }

    [Fact]
    public void Gecen_yil_ayni_ay_ve_hesaplanan()
    {
        var satir = new Dictionary<DateTime, PlanliGiderSatiri>
        {
            [G(2026, 1, 5)] = new(G(2026, 1, 5), G(2026, 1, 5), 500m, 3, null, 3100m, G(2026, 1, 6)),
        };
        var d = PlanliGiderHesap.Donemler(Tanim(tur: 3, tutar: 500m, adet: 14), [], satir, TatilYok, G(2030, 1, 1));
        Assert.Equal(500m, d[1].Plan);       // Şubat 2026: geçen yıl yok → tanım
        Assert.Equal(3100m, d[12].Plan);     // Ocak 2027 ← Ocak 2026 gerçekleşen
        var h = PlanliGiderHesap.Donemler(Tanim(tur: 4, tutar: 0m, adet: 2), [], Bos, TatilYok, G(2030, 1, 1), hesapDegeri: 4321.555m);
        Assert.All(h, x => Assert.Equal(4321.56m, x.Plan));
    }

    [Fact]
    public void Durum_metinleri()
    {
        var bugun = G(2026, 10, 25);
        PlanliGiderDonemi D(DateTime plan, PlanliGiderSatiri? s) => new(plan, plan, false, "", 100m, 100m, 0, 0, false, false, false, false, s);
        Assert.Equal(("gecikti", 20), PlanliGiderHesap.Durum(D(G(2026, 10, 5), null), bugun));
        Assert.Equal(("bugun", 0), PlanliGiderHesap.Durum(D(bugun, null), bugun));
        Assert.Equal(("planli", 11), PlanliGiderHesap.Durum(D(G(2026, 11, 5), null), bugun));
        Assert.Equal(("gec", 3), PlanliGiderHesap.Durum(D(G(2026, 7, 5), new(G(2026, 7, 5), null, null, 3, null, 100m, G(2026, 7, 8))), bugun));
        Assert.Equal(("erken", 1), PlanliGiderHesap.Durum(D(G(2026, 7, 5), new(G(2026, 7, 5), null, null, 3, null, 100m, G(2026, 7, 4))), bugun));
        Assert.Equal("beklemede", PlanliGiderHesap.Durum(D(G(2026, 7, 5), new(G(2026, 7, 5), null, null, 3, null, 100m, G(2026, 7, 5))), bugun, true).Durum);
        Assert.Equal("faturalandi", PlanliGiderHesap.Durum(D(G(2026, 7, 5), new(G(2026, 7, 5), null, null, 4, null, 100m, null)), bugun).Durum);
        Assert.Equal("atlandi", PlanliGiderHesap.Durum(D(G(2026, 7, 5), new(G(2026, 7, 5), null, null, 1, null, null, null)), bugun).Durum);
    }

    [Fact]
    public void Metinler_ve_aylik_karsilik()
    {
        Assert.Equal(["1'i", "2'si", "3'ü", "5'i", "6'sı", "9'u", "10'u", "20'si", "26'sı", "30'u"],
            new[] { 1, 2, 3, 5, 6, 9, 10, 20, 26, 30 }.Select(PlanliGiderHesap.GunEki));
        Assert.Equal("Aylık · ayın 5'i", PlanliGiderHesap.PeriyotMetni(Tanim()));
        Assert.Equal("Aylık · ay sonu", PlanliGiderHesap.PeriyotMetni(Tanim(gun: 31)));
        Assert.Equal(2600m, PlanliGiderHesap.Aylik(3, 7800m));
        Assert.Equal(100m, PlanliGiderHesap.Aylik(5, 1200m));
        Assert.Equal("Kasım 2026 Depo kirası", PlanliGiderHesap.Aciklama("{ay} {yil} {ad}", "Depo kirası", G(2026, 11, 5)));
    }
}
