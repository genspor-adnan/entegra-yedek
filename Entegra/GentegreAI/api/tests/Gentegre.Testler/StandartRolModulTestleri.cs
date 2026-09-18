using System.Text.RegularExpressions;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// STANDART ROL ŞABLONLARI KURUM PROFİLİNE GÖRE (785).
///
/// Kullanıcı: *"bir de kurum profiline göre gelebilsin"*, *"örneğin bir lab
/// merkezinde diş hekimi rolü görünmemeli"*, *"bir lab da isg uzmanı olamaz
/// gibi"*, *"bir diş kliniğinde lab uzmanı/biyokimya uzmanı olamaz"*.
///
/// İki süzgeç var: **kurum tipi** (şablonun `Tipler` listesi - hangi iş kolu)
/// ve **açık modül** (`SablonModul` haritası - bu kurulumda o modül var mı).
/// Şablon-modül haritasında YANLIŞ YAZILMIŞ bir modül kodu sessiz bir
/// arızadır: `fn_kurum_modul_acik` onu hiçbir zaman açık görmez, rol de hiçbir
/// kurulumda önerilmez - kimse hata almaz, rol yalnızca ortadan kaybolur.
/// Bu test haritayı `kurum_modul` kataloğuyla karşılaştırır.
///
/// Harita KAYNAKTAN okunuyor (KorunanSatirTestleri deseni): sözlük `private`,
/// metnin kendisi zaten testin konusu.
/// </summary>
public sealed class StandartRolModulTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>`SablonModul` sözlüğündeki (rol kodu, modül kodu) çiftleri.</summary>
    private static List<(string Rol, string Modul)> HaritaOku()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        var yol = Path.Combine(dizin!.FullName, "src", "Gentegre.Api",
                               "Uclar", "StandartRolUclari.cs");
        var metin = File.ReadAllText(yol);
        var blok = Regex.Match(metin,
            @"SablonModul = new\(StringComparer\.Ordinal\)\s*\{(?<govde>.*?)\};",
            RegexOptions.Singleline);
        Assert.True(blok.Success, "SablonModul haritası kaynakta bulunamadı.");
        return Regex.Matches(blok.Groups["govde"].Value,
                             @"\[""(?<rol>[a-z_]+)""\]\s*=\s*""(?<modul>[a-z_]+)""")
            .Select(m => (m.Groups["rol"].Value, m.Groups["modul"].Value)).ToList();
    }

    [Fact]
    public async Task Haritadaki_modul_kodlari_KATALOGDA_var()
    {
        if (!_olgu.Baglandi(nameof(Haritadaki_modul_kodlari_KATALOGDA_var))) return;
        var veri = _olgu.Gerekli();

        var harita = HaritaOku();
        Assert.NotEmpty(harita);

        var moduller = await veri.ListeAsync("select kod from public.kurum_modul",
            null, o => o.GetString(0), CancellationToken.None);
        var eksik = harita.Select(x => x.Modul).Distinct()
                          .Where(m => !moduller.Contains(m)).ToList();

        Assert.True(eksik.Count == 0,
            "kurum_modul'de olmayan modül kodu (rol hiçbir kurulumda önerilmez): "
            + string.Join(", ", eksik));
    }

    [Fact]
    public void Modul_gerektirmeyen_roller_haritada_YOK()
    {
        // Kayıt kabul, muhasebe, yönetim görüntüleyici, bilgi işlem: her
        //   kurulumda geçerli. Haritaya girerlerse modülü kapalı bir kurumda
        //   hiç önerilmezler ve kurum rolsüz kalır.
        var harita = HaritaOku().Select(x => x.Rol).ToHashSet();
        foreach (var kod in new[] { "kayit_kabul", "muhasebe", "vezne",
                                    "rapor_goruntuleyici", "kalite", "bilgi_islem" })
            Assert.DoesNotContain(kod, harita);
    }

    [Fact]
    public void Dal_rolleri_KENDI_modulune_bagli()
    {
        // Kullanıcının örnekleri: lab merkezinde diş hekimi / İSG uzmanı,
        //   diş kliniğinde lab uzmanı çıkmamalı. Kurum TİPİ bunu zaten
        //   ayırıyor; harita ikinci kapı - aynı tipte modül kapalıysa da
        //   çıkmasın (tıp merkezi + diş modülü kapalı gibi).
        var harita = HaritaOku().ToDictionary(x => x.Rol, x => x.Modul);

        Assert.Equal("dis", harita["dis_hekimi"]);
        Assert.Equal("lab", harita["lab_uzmani"]);
        Assert.Equal("lab", harita["lab_teknisyen"]);
        Assert.Equal("isg", harita["isg_uzmani"]);
        Assert.Equal("goz", harita["goz_hekimi"]);
        Assert.Equal("radyoloji", harita["radyolog"]);
        Assert.Equal("yatan_hasta", harita["yatan_hemsire"]);
    }

    [Fact]
    public async Task Sistem_rolleri_SILINEMEZ_ama_pasife_alinabilir()
    {
        if (!_olgu.Baglandi(nameof(Sistem_rolleri_SILINEMEZ_ama_pasife_alinabilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 785: koruma SİLMEYE ve KİMLİĞE kaldı; kurumun kullanmadığı rol
        //   pasife alınabilmeli (kullanıcı: "silinemesin aktif/pasif
        //   yapılabilsin").
        var rolId = await b.TekDegerAsync<int>(
            "select id from public.rol where sistem = 1 and kod = 'dis_hekimi'",
            t, [], CancellationToken.None);
        Assert.True(rolId > 0, "dis_hekimi sistem rolü kurulu olmalı (785).");

        await b.CalistirAsync("update public.rol set aktif = 0 where id = @p0",
            t, [rolId], CancellationToken.None);

        var h = await Assert.ThrowsAsync<Npgsql.PostgresException>(() => b.CalistirAsync(
            "delete from public.rol where id = @p0", t, [rolId], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);
        Assert.Contains("silinemez", h.MessageText);

        await t.RollbackAsync();
    }

    [Fact]
    public void ERP_kurulumunun_da_sablonu_var()
    {
        // 795 (kullanici: "bir de standart ERP rolleri var, bunlari da
        //   dusunelim"): ERP kurulumunda "Standart rolleri kur" BOS liste
        //   donuyordu - butun sablonlar klinik tiplere yazilmisti ve yonetici
        //   150 yetkiyi elle isaretliyordu.
        var metin = KaynakOku();
        foreach (var kod in new[] { "erp_satis", "erp_alis", "erp_depo",
                                    "erp_uretim", "erp_servis", "erp_ik" })
            Assert.Contains($"new(\"{kod}\"", metin);

        // IS KOLUNDAN BAGIMSIZ roller ERP'de de gecerli olmali: muhasebe,
        //   yonetim goruntuleyici, kalite, bilgi islem. Bunlar `Hepsi`
        //   listesini kullanir (Klinik + erp).
        Assert.Contains("private static readonly string[] Hepsi", metin);
        foreach (var kod in new[] { "muhasebe", "rapor_goruntuleyici", "kalite",
                                    "bilgi_islem" })
        {
            var i = metin.IndexOf($"new(\"{kod}\"", StringComparison.Ordinal);
            Assert.True(i > 0, kod + " sablonu yok");
            var satir = metin.Substring(i, Math.Min(400, metin.Length - i));
            Assert.True(satir.Contains("Hepsi"),
                $"\"{kod}\" rolu ERP kurulumunda da gecerli olmali (Hepsi).");
        }
    }

    /// <summary>Şablon kaynağının metni (harita testleriyle aynı dosya).</summary>
    private static string KaynakOku()
    {
        var dizin = new DirectoryInfo(AppContext.BaseDirectory);
        while (dizin is not null && !Directory.Exists(Path.Combine(dizin.FullName, "src")))
            dizin = dizin.Parent;
        Assert.NotNull(dizin);
        return File.ReadAllText(Path.Combine(dizin!.FullName, "src", "Gentegre.Api",
                                             "Uclar", "StandartRolUclari.cs"));
    }
}
