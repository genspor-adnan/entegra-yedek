using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Testler;

/// <summary>
/// GELEN ORU ÇÖZÜMLEYİCİSİ (817) — veritabanı GEREKTİRMEZ.
///
/// <b>En değerli test gidiş-dönüş:</b> kendi ürettiğimiz mesajı geri
/// okuyabiliyor muyuz? Üretici ile çözümleyici aynı kılavuzu okuyor; biri
/// değişip öteki değişmezse bu test kırılır.
///
/// Ayrıca karşı tarafın bize göndereceği biçimler sınanıyor: farklı ayırıcı,
/// düz TX gövde, base64 olmayan "BASE64" alanı, eksik OBR, ORU olmayan mesaj.
/// </summary>
public sealed class OruCozumleyiciTestleri
{
    private static OruVerisi Ornek(Hl7Profili profil) => new()
    {
        Profil = profil,
        GonderenUygulama = "TELETIP", GonderenTesis = "TELETIP",
        AliciUygulama = "GENOTIP", AliciTesis = "MERKEZ",
        Zaman = new DateTime(2026, 9, 18, 16, 0, 0),
        KontrolNo = "MSG-42",
        HastaDosyaNo = "P-77", HastaTckn = "12345678901",
        HastaSoyad = "ÇELİK", HastaAd = "ŞÜKRÜ",
        DogumTarihi = new DateTime(1975, 3, 9), Cinsiyet = "M",
        KurumSkrs = "12345", AccessionNo = "ACC-77",
        IsteyenHekimTckn = "98765432101", IsteyenHekimSoyad = "VELİ", IsteyenHekimAd = "ALİ",
        SutKodu = "801950", SutAdi = "Lumbo-sakral radyografi",
        OnayZamani = new DateTime(2026, 9, 18, 15, 45, 0),
        HizmetVerenSkrs = "6789",
        ModaliteKodu = "CR",
        RaporTeknik = "İki yönlü grafi.",
        RaporKarsilastirma = "Önceki tetkikle kıyaslandı.",
        RaporBulgular = "Vertebra korpus yükseklikleri korunmuş, disk mesafeleri doğal.",
        RaporSonuc = "Patolojik bulgu saptanmadı.",
        IstemNedeniPuan = 3, CekimKalitePuan = 4,
        RadyologTckn = "11122233344", RadyologSoyad = "YILMAZ", RadyologAd = "MERT",
        KontrastObx17 = "IV^Ioheksol^300",
    };

    // ------------------------------------------------------- gidiş-dönüş ----

    [Fact]
    public void Bakanlik_mesaji_geri_okunur()
    {
        var v = Ornek(Hl7Profili.Bakanlik);
        var g = OruCozumleyici.Coz(OruUretici.Uret(v));

        Assert.True(g.Gecerli);
        Assert.Equal("2.3.1", g.Surum);
        Assert.Equal("MSG-42", g.KontrolNo);
        Assert.Equal("ACC-77", g.AccessionNo);
        Assert.Equal("12345678901", g.HastaTckn);
        Assert.Equal("P-77", g.HastaDosyaNo);
        Assert.Equal("12345", g.GonderenSkrs);          // ORC-21
        Assert.Equal(v.OnayZamani, g.OnayZamani);       // OBR-7
        Assert.Equal("11122233344", g.RadyologTckn);
        Assert.Equal("MERT YILMAZ", g.RadyologAdi);

        // Dört parça base64 geri çözülür.
        Assert.Equal(v.RaporTeknik, g.RaporTeknik);
        Assert.Equal(v.RaporKarsilastirma, g.RaporKarsilastirma);
        Assert.Equal(v.RaporBulgular, g.RaporBulgular);
        Assert.Equal(v.RaporSonuc, g.RaporSonuc);

        Assert.Equal(3, g.IstemNedeniPuan);
        Assert.Equal(4, g.CekimKalitePuan);
        Assert.Equal("IV^Ioheksol^300", g.KontrastObx17);
        Assert.False(g.Duzeltme);
        Assert.True(g.GovdeVar);
    }

    [Fact]
    public void Kurum_mesaji_basliklardan_parcalanir()
    {
        // Kurum profili düz TX gönderiyor; başlıklar geri geldiğinde parçalara
        //   ayrılabilmeli - yoksa bütün rapor tek bloğa düşerdi.
        var v = Ornek(Hl7Profili.Kurum);
        var g = OruCozumleyici.Coz(OruUretici.Uret(v));

        Assert.True(g.Gecerli);
        Assert.Equal("2.5", g.Surum);
        Assert.Equal(v.RaporBulgular, g.RaporBulgular);
        Assert.Equal(v.RaporSonuc, g.RaporSonuc);
        Assert.Equal("", g.RaporDuzMetin);
    }

    [Fact]
    public void Kacisli_karakterler_geri_acilir()
    {
        var v = Ornek(Hl7Profili.Bakanlik) with
        {
            HastaSoyad = "A|B", HastaAd = "C^D",
            AccessionNo = @"AC\C",
        };
        var g = OruCozumleyici.Coz(OruUretici.Uret(v));
        Assert.Equal("A|B C^D", g.HastaAdi);
        Assert.Equal(@"AC\C", g.AccessionNo);
    }

    [Fact]
    public void Duzeltme_isareti_okunur()
    {
        var g = OruCozumleyici.Coz(
            OruUretici.Uret(Ornek(Hl7Profili.Bakanlik) with { Duzeltme = true }));
        Assert.True(g.Duzeltme);
    }

    // --------------------------------------------------- yabancı biçimler ----

    [Fact]
    public void Farkli_ayirici_ile_gelen_mesaj()
    {
        // Ayırıcı MSH'den okunmasaydı her alan yanlış yere düşerdi (432 dersi).
        var m = "MSH#*~\\&#HBYS#X#GENOTIP#MERKEZ#20260918160000##ORU^R01#K1#P#2.3.1\r"
              + "PID###P-1#12345678901#TAS*AHMET\r"
              + "OBR#1#A1#A1#801950*Grafi*SUT##20260918150000#20260918154500\r"
              + "OBX#1#TX#TXT^BASE64#1#" + B64("Bulgu metni") + "*3\r";
        var g = OruCozumleyici.Coz(m);

        Assert.True(g.Gecerli);
        Assert.Equal("A1", g.AccessionNo);
        Assert.Equal("12345678901", g.HastaTckn);
        Assert.Equal("Bulgu metni", g.RaporBulgular);
    }

    [Fact]
    public void Orc21_yoksa_obr15ten_skrs()
    {
        var m = Basit(obr15: "6789&&SKRS^^^^^R");
        Assert.Equal("6789", OruCozumleyici.Coz(m).GonderenSkrs);
    }

    [Fact]
    public void Obr15_radiology_ise_skrs_yok()
    {
        // Varsayılan değer kurum kodu DEĞİLDİR: "Radiology" yazan alandan
        //   SKRS üretmek uydurma bir eşleşme doğururdu.
        var m = Basit(obr15: "Radiology^^^^^R");
        Assert.Equal("", OruCozumleyici.Coz(m).GonderenSkrs);
    }

    [Fact]
    public void Base64_olmayan_govde_metin_olarak_alinir()
    {
        // Kimi sistem `TXT^BASE64` yazıp düz metin gönderiyor; mesajı çöpe
        //   atmaktansa okunanı almak yeğdir.
        var m = Basit(obx5: "Düz metin bulgular^3");
        Assert.Equal("Düz metin bulgular", OruCozumleyici.Coz(m).RaporBulgular);
    }

    [Fact]
    public void Numarasiz_parca_duz_metne_dusar()
    {
        // Numarasız parçayı 3'e (Bulgular) yazmak, raporu yanlış bölüme
        //   koymak olurdu.
        var m = Basit(obx5: B64("Numarasız gövde"));
        var g = OruCozumleyici.Coz(m);
        Assert.Equal("", g.RaporBulgular);
        Assert.Equal("Numarasız gövde", g.RaporDuzMetin);
        Assert.True(g.GovdeVar);
    }

    [Fact]
    public void Coklu_obx_satirlari_birlesir()
    {
        var m = "MSH|^~\\&|HBYS|X|GENOTIP|MERKEZ|20260918160000||ORU^R01|K9|P|2.5\r"
              + "PID|||P-1|12345678901|TAS^AHMET\r"
              + "OBR|1|A9|A9|801950^Grafi^SUT||20260918150000|20260918154500\r"
              + "OBX|1|TX|801950^RAPOR|1|Birinci satır||||||F\r"
              + "OBX|2|TX|801950^RAPOR|1|İkinci satır||||||F\r";
        var g = OruCozumleyici.Coz(m);
        Assert.Equal("Birinci satır\nİkinci satır", g.RaporDuzMetin);
    }

    // ------------------------------------------------------------ hatalar ----

    [Fact]
    public void Bos_mesaj_gecersiz()
    {
        var g = OruCozumleyici.Coz("");
        Assert.False(g.Gecerli);
        Assert.Equal("Mesaj boş.", g.Hata);
    }

    [Fact]
    public void Msh_olmayan_mesaj_gecersiz()
        => Assert.False(OruCozumleyici.Coz("PID|||1\r").Gecerli);

    [Fact]
    public void Oru_olmayan_mesaj_reddedilir()
    {
        var g = OruCozumleyici.Coz(
            "MSH|^~\\&|HBYS|X|GENOTIP|MERKEZ|20260918160000||ORM^O01|K1|P|2.3.1\r");
        Assert.False(g.Gecerli);
        Assert.Contains("ORM^O01", g.Hata, StringComparison.Ordinal);
        // Kontrol numarası yine okunur: mükerrer ayıklama buna bakıyor.
        Assert.Equal("K1", g.KontrolNo);
    }

    [Fact]
    public void Obr_olmayan_mesaj_reddedilir()
    {
        var g = OruCozumleyici.Coz(
            "MSH|^~\\&|HBYS|X|GENOTIP|MERKEZ|20260918160000||ORU^R01|K2|P|2.3.1\r"
            + "PID|||P-1|12345678901|TAS^AHMET\r");
        Assert.False(g.Gecerli);
        Assert.Contains("OBR", g.Hata, StringComparison.Ordinal);
    }

    [Fact]
    public void Govdesiz_mesaj_gecerli_ama_bos()
    {
        // Çözümlenir ama yazılacak bir şey yok: servis bunu "hata" sayacak.
        var g = OruCozumleyici.Coz(Basit(obx5: ""));
        Assert.True(g.Gecerli);
        Assert.False(g.GovdeVar);
    }

    // ---------------------------------------------------------- yardımcı ----
    private static string B64(string metin)
        => Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(metin));

    private static string Basit(string obr15 = "", string obx5 = "")
        => "MSH|^~\\&|HBYS|X|GENOTIP|MERKEZ|20260918160000||ORU^R01|K5|P|2.3.1\r"
         + "PID|||P-1|12345678901|TAS^AHMET\r"
         + $"OBR|1|A5|A5|801950^Grafi^SUT||20260918150000|20260918154500||||||||{obr15}\r"
         + $"OBX|1|TX|TXT^BASE64|1|{obx5}||||||F\r";
}
