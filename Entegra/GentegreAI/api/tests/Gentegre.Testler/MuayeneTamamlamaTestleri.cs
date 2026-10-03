using System.Reflection;

namespace Gentegre.Testler;

/// <summary>
/// MUAYENE TAMAMLAMA — e-Nabız'ın zorunlu alanları da burada durdurur (628).
///
/// 103 (muayene) ve 106 (çıkış) paketleri muayene tamamlanırken üretilir.
/// USS o paketleri eksik alanla reddediyor ve hata hekime SAATLER SONRA,
/// kuyruk ekranında dönüyordu - o sırada muayene kilitli ve düzeltmek için
/// geri açmak gerekiyor. Kontrol bu yüzden tamamlama anına alındı.
///
/// Test KAYNAK METNİNE bakar, uç çağırmaz: doğrulama bir iş kuralı ve
/// davranışı görmek için tam bir muayene akışı (başvuru → muayeneye al →
/// tanı → tamamla) kurmak gerekirdi. Buradaki soru daha dar: "kural hâlâ
/// yerinde mi" - bir sonraki düzenlemede sessizce düşmesin.
/// </summary>
public sealed class MuayeneTamamlamaTestleri
{
    private static string Kaynak(params string[] parcalar)
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine([dizin!.FullName, "src", .. parcalar]);
        Assert.True(File.Exists(yol), $"kaynak bulunamadı: {yol}");
        return File.ReadAllText(yol);
    }

    /// <summary>Tamamlama kuralı yardımcısının gövdesi (imzadan bir sonraki metoda).</summary>
    private static string KuralBolumu(string kaynak)
    {
        var bas = kaynak.IndexOf("> TamamlamaKontrolleriAsync(", StringComparison.Ordinal);
        Assert.True(bas >= 0, "TamamlamaKontrolleriAsync tanımı bulunamadı");
        var son = kaynak.IndexOf("private static async Task<string> OzetDerleAsync", bas,
                                 StringComparison.Ordinal);
        Assert.True(son > bas, "kural bölümünün sonu bulunamadı");
        return kaynak[bas..son];
    }

    [Fact]
    public void Tamamlama_eNabiz_zorunlulariyla_engellenir()
    {
        var kaynak = Kaynak("Gentegre.Api", "Uclar", "MuayeneUclari.cs");
        // KURAL TEK YERDE (931): TamamlamaKontrolleriAsync - Tamamla ve özet
        //   sekmesinin kontrol listesi aynı listeyi okur. Maddeler ZORUNLU
        //   (son eleman true) olmalı; zorunlu olmayan madde Tamamla'yı durdurmaz.
        var kural = KuralBolumu(kaynak);

        // 103'ün MUAYENE_BASLANGIC_TARIHI'si: muayeneye alınmadan tamamlanan
        //   kayıtta başlangıç boş kalır ve paket gönderilemez.
        Assert.Matches(@"\(""baslangic"", ""[^""]+"", m\.Baslatildi,[^;]*?, true\)", kural);

        // 106'nın CIKIS_SEKLI'si: SKRS listesinde GEÇERLİ kod olmalı. Boş
        //   gönderildiğinde USS "E1014 ... eksik elemanlar var: CIKIS_SEKLI"
        //   döndürmüştü (canlı deneme, paket 652).
        Assert.Contains("fn_skrs_kod('cikis.sekli', m.cikis_sekli)", kaynak,
                        StringComparison.Ordinal);
        Assert.Matches(@"\(""cikisSekli"", ""[^""]+"", m\.CikisKodu\.Length > 0,[^;]*?, true\)", kural);
        // Tamamla yalnız ZORUNLU eksikle reddeder.
        Assert.Contains(".Where(k => k.Zorunlu && !k.Tamam)", kaynak, StringComparison.Ordinal);

        // Eksikler TEK SEFERDE sayılır - hekime "önce tanı gir", sonra
        //   "çıkış şekli de lazım" demek ekranı iki kez kapattırırdı.
        Assert.Contains("Muayene tamamlanamaz: ", kaynak, StringComparison.Ordinal);
    }

    [Fact]
    public void Takip_numarasi_ENGEL_DEGIL_uyaridir()
    {
        var kaynak = Kaynak("Gentegre.Api", "Uclar", "MuayeneUclari.cs");

        // SYS takip numarası da 103/106'nın zorunlu alanı - AMA hekimin
        //   elinde değil: numara, hasta kaydının (101) USS'ye gönderilmesiyle
        //   gelir ve gönderim ayrı bir iştir. Muayeneyi kilitlemek klinik
        //   kaydı e-Nabız kuyruğuna bağımlı yapardı.
        //
        // Yani takip numarası kontrolü UYARI listesinde olmalı, eksikler
        //   listesinde DEĞİL.
        Assert.DoesNotContain("m.Takip", KuralBolumu(kaynak), StringComparison.Ordinal);

        Assert.Contains("uyarilar.Add(\"Hasta kaydi (101)", kaynak, StringComparison.Ordinal);
    }
}
