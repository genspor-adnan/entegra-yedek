using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Testler;

/// <summary>
/// KAYIT KABUL LİSTELERİ YALNIZ GÖR (1115 aşama 2, göç 1126) — kullanıcı 17.10.2026: *"Hasta Listesi
/// yetkisi sade Gör/Görme ve hasta kartı yetkisi Gör/ekle/değiş/sil"*.
///
/// İddialar veritabanı istemez:
///   1. Liste kodu veri kodunu yalnız OKUMADA açar (liste satırları, kart salt okunur).
///   2. Liste kodunun Ekle / Değiştir / Sil'i hiçbir yerde sayılmaz - satırda açık kalsa bile.
///   3. Kart işlemleri yalnız veri koduyla.
///   4. Başvuru Listesi başvuru kümesini okumada açar; ERP belge kümelerini açmaz.
/// </summary>
public sealed class ListeYalnizGorTestleri
{
    private static YetkiSeti Set(params (string kod, bool g, bool e, bool d, bool s)[] satirlar)
        => new(1, satirlar.Select(x => new YetkiKaydi(x.kod, 0, x.g, x.e, x.d, x.s)), []);

    [Theory]
    [InlineData("hasta.liste", "hasta")]
    [InlineData("basvuru.liste", "belge")]
    public void Liste_kodu_veri_kodunu_yalniz_okumada_acar(string liste, string veri)
    {
        // Eski satır (1115 kopyası) tam haklı olsa da yalnız Gör sayılır.
        var s = Set((liste, true, true, true, true));
        Assert.True(s.Var(veri, Islem.Gor));
        Assert.False(s.Var(veri, Islem.Ekle));
        Assert.False(s.Var(veri, Islem.Degistir));
        Assert.False(s.Var(veri, Islem.Sil));
        Assert.True(s.VarTam(liste, Islem.Gor));
        Assert.False(s.VarTam(liste, Islem.Ekle));
    }

    [Theory]
    [InlineData("hasta.liste", "hasta")]
    [InlineData("basvuru.liste", "belge")]
    public void Kart_islemleri_veri_kodundan(string liste, string veri)
    {
        var s = Set((liste, true, false, false, false), (veri, true, true, true, false));
        Assert.True(s.Var(veri, Islem.Ekle));
        Assert.True(s.Var(veri, Islem.Degistir));
        Assert.False(s.Var(veri, Islem.Sil));
    }

    [Theory]
    [InlineData("radyoloji.cihaz.liste", "radyoloji")]          // kaynak üst kodda (aşama 1 köprüsü)
    [InlineData("randevu.plan.sablon.liste", "randevu.plan")]
    public void Liste_kodu_ortak_kaynagi_zincirle_yalniz_okumada_acar(string liste, string kaynak)
    {
        var s = Set((liste, true, true, true, true));
        Assert.True(s.Var(kaynak, Islem.Gor));
        Assert.False(s.Var(kaynak, Islem.Ekle));
        Assert.False(s.Var(kaynak, Islem.Degistir));
    }

    [Theory]
    [InlineData("randevu.liste", "randevu")]
    [InlineData("teleradyoloji.kurum.liste", "teleradyoloji.kurum")]
    [InlineData("hasta.liste", "hasta")]          // 1115 AyniGrup kopyası önce gelir
    public void Standart_sablon_liste_kodunu_kartindan_uretir(string liste, string kart)
        => Assert.Equal(kart, EkranKodlari.KopyaKaynagi(liste));

    /// <summary>Tablodaki HER liste kodu (1126 / 1128 / 1129): kartını yalnız okur, işlem vermez.</summary>
    [Fact]
    public void Her_liste_kodu_kartini_yalniz_okumada_acar()
    {
        Assert.True(EkranKodlari.YalnizGorKodlari.Count >= 158);
        foreach (var liste in EkranKodlari.YalnizGorKodlari)
        {
            var kart = EkranKodlari.KopyaKaynagi(liste)!;
            var s = Set((liste, true, true, true, true));
            Assert.True(s.Var(kart, Islem.Gor), liste);
            Assert.False(s.Var(kart, Islem.Ekle), liste);
            Assert.False(s.Var(kart, Islem.Degistir), liste);
            Assert.False(s.Var(kart, Islem.Sil), liste);
        }
    }

    [Theory]
    [InlineData("muayene.sevk", "muayene")]
    [InlineData("medula.recete", "muayene")]
    [InlineData("klinik_kalite.olgu", "klinik_kalite")]
    [InlineData("kasa.finans", "kasa_islem")]
    public void Okuma_koprusu_kaynagi_yalniz_okumada_acar_kodun_kendi_haklari_kalir(string ekran, string kaynak)
    {
        var s = Set((ekran, true, true, true, true));
        Assert.True(s.Var(kaynak, Islem.Gor));
        Assert.False(s.Var(kaynak, Islem.Ekle));
        Assert.False(s.Var(kaynak, Islem.Degistir));
        Assert.True(s.VarTam(ekran, Islem.Degistir));   // yalnız-Gör listesi DEĞİL: e-Reçete gönderme vb. sürer
    }

    [Fact]
    public void Liste_kodu_kapaliyken_veri_kapisi_acilmaz()
    {
        var s = Set(("hasta.liste", false, true, true, true));
        Assert.False(s.Var("hasta", Islem.Gor));
        Assert.False(s.Var("hasta", Islem.Ekle));
    }

    [Fact]
    public void Basvuru_listesi_basvuru_kumesini_acar_erp_kumelerini_acmaz()
    {
        Assert.Equal(KaynakKatalogu.BelgeKumeBasvuru, KaynakKatalogu.BelgeKumesi("basvuru.liste"));
        Assert.Contains("basvuru.liste", KaynakKatalogu.BelgeYetkiKodlari);
        var s = Set(("basvuru.liste", true, true, true, true));
        // Satış belgesi kodu verilmedi: ERP kümesi kapalı.
        Assert.False(s.Var("belge.satis", Islem.Gor));
    }

    /// <summary>
    /// Web tablosu (web/src/kimlik/listeKartKodlari.ts) sunucunun tablosuyla AYNI: biri eksik
    /// kalırsa menü / matris liste kodunu gösterir ama sunucu onu tam yetki sayar (ya da tersi).
    /// </summary>
    [Fact]
    public void Web_liste_kart_tablosu_sunucuyla_ayni()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "web", "src", "kimlik")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var metin = File.ReadAllText(Path.Combine(dizin!.FullName, "web", "src", "kimlik", "listeKartKodlari.ts"));
        var web = System.Text.RegularExpressions.Regex.Matches(metin, @"'([a-z0-9._-]+)':\s*'([a-z0-9._-]+)'")
            .ToDictionary(x => x.Groups[1].Value, x => x.Groups[2].Value);
        Assert.Equal(EkranKodlari.YalnizGorKodlari.OrderBy(x => x), web.Keys.OrderBy(x => x));
        foreach (var (liste, kart) in web)
            Assert.Equal([liste], EkranKodlari.ListeGorAltlari(kart).Where(x => x == liste));
    }

    [Fact]
    public void Liste_kodlari_tam_kapi_koprusunde_degil()
    {
        Assert.Empty(EkranKodlari.VeriKapisiAltlari("hasta").Where(EkranKodlari.YalnizGor));
        Assert.Empty(EkranKodlari.VeriKapisiAltlari("belge").Where(EkranKodlari.YalnizGor));
        Assert.Equal(["hasta.liste"], EkranKodlari.ListeGorAltlari("hasta"));
        Assert.Equal(["basvuru.liste"], EkranKodlari.ListeGorAltlari("belge"));
    }
}
