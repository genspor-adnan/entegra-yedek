using System.Text;
using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Testler;

/// <summary>
/// ORU^R01 ÜRETİCİSİ (814) — veritabanı GEREKTİRMEZ.
///
/// Üretici saf işlev olduğu için mesajın biçimi karşı uç olmadan sınanıyor:
/// kapsam belgesindeki *"HL7 önce yapılabilir"* gerekçesinin karşılığı budur.
/// Sınanan şeyler kılavuz 3.46'nın mesajı REDDETTİREN kuralları - alan
/// numarası kayması, eksik parça, kaçışsız ayırıcı.
/// </summary>
public sealed class OruUreticiTestleri
{
    private static OruVerisi Ornek(Hl7Profili profil = Hl7Profili.Bakanlik) => new()
    {
        Profil = profil,
        GonderenUygulama = "GENOTIP", GonderenTesis = "MERKEZ",
        AliciUygulama = "TELETIP", AliciTesis = "TELETIP",
        Zaman = new DateTime(2026, 9, 18, 14, 30, 0),
        KontrolNo = "T1D1",
        HastaDosyaNo = "P-4501", HastaTckn = "12345678901",
        HastaSoyad = "TAŞ", HastaAd = "AHMET",
        DogumTarihi = new DateTime(1980, 1, 5), Cinsiyet = "M",
        HastaneReferans = "REF-99", SysTakipNo = "SYS-77",
        KurumSkrs = "12345", AccessionNo = "ACC-1",
        IsteyenHekimTckn = "98765432101", IsteyenHekimSoyad = "VELİ", IsteyenHekimAd = "ALİ",
        SutKodu = "801950", SutAdi = "Lumbo-sakral radyografi",
        Loinc = "24972-2", LoincAdi = "Lumbar vertebra XR",
        IstemZamani = new DateTime(2026, 9, 18, 9, 0, 0),
        OnayZamani = new DateTime(2026, 9, 18, 14, 0, 0),
        CekimZamani = new DateTime(2026, 9, 18, 10, 15, 0),
        KlinikBilgi = "Bel ağrısı",
        HizmetVerenSkrs = "6789",
        ModaliteKodu = "CR",
        RaporTeknik = "Rutin protokol.",
        RaporBulgular = "Lumbar vertebra dizilimi doğal, disk mesafeleri korunmuş.",
        RaporSonuc = "Patolojik bulgu saptanmadı.",
        IstemNedeniPuan = 4, CekimKalitePuan = 5,
        RadyologTckn = "11122233344", RadyologSoyad = "YILMAZ", RadyologAd = "MERT",
        KontrastObx17 = "IV^Ioheksol^300",
        TaniIcd = ["M54.5"],
    };

    private static string Alan(string mesaj, string segmentAdi, int no)
    {
        var segment = mesaj.Split('\r', StringSplitOptions.RemoveEmptyEntries)
                           .First(x => x.StartsWith(segmentAdi, StringComparison.Ordinal));
        var p = segment.Split('|');
        // MSH'de 1. alan ayırıcının KENDİSİ: MSH-3 dizinin 2. ögesidir.
        var i = segmentAdi == "MSH" ? no - 1 : no;
        return i >= 0 && i < p.Length ? p[i] : "";
    }

    // --------------------------------------------------------------- MSH ----

    [Fact]
    public void Bakanlik_surumu_231()
    {
        var m = OruUretici.Uret(Ornek());
        // Farklı sürüm yazmak ACK hatası 0002 demek.
        Assert.Equal("2.3.1", Alan(m, "MSH", 12));
        Assert.Equal("ORU^R01", Alan(m, "MSH", 9));
        Assert.Equal("T1D1", Alan(m, "MSH", 10));
        Assert.StartsWith(@"MSH|^~\&|GENOTIP|MERKEZ|TELETIP|TELETIP|20260918143000", m);
    }

    [Fact]
    public void Kurum_surumu_25()
        => Assert.Equal("2.5", Alan(OruUretici.Uret(Ornek(Hl7Profili.Kurum)), "MSH", 12));

    [Fact]
    public void Encoding_msh18de()
    {
        var m = OruUretici.Uret(Ornek() with { Encoding = "Windows1254" });
        // MSH-18: Bakanlığa önceden bildirilen kodlama ile aynı olmak zorunda.
        Assert.Equal("Windows1254", Alan(m, "MSH", 18));
    }

    // --------------------------------------------------- alan numaraları ----

    [Fact]
    public void Hasta_alanlari_dogru_numarada()
    {
        var m = OruUretici.Uret(Ornek());
        Assert.Equal("P-4501", Alan(m, "PID", 3));
        Assert.Equal("12345678901", Alan(m, "PID", 4));      // TCKN
        Assert.Equal("TAŞ^AHMET", Alan(m, "PID", 5));
        Assert.Equal("19800105", Alan(m, "PID", 7));
        Assert.Equal("M", Alan(m, "PID", 8));
        // PV1-19 boş geçilirse 0278 hatası dönüyor.
        Assert.Equal("REF-99", Alan(m, "PV1", 19));
    }

    [Fact]
    public void Istem_alanlari_dogru_numarada()
    {
        var m = OruUretici.Uret(Ornek());
        Assert.Equal("ACC-1", Alan(m, "ORC", 2));
        Assert.Equal("98765432101^VELİ^ALİ", Alan(m, "ORC", 12));   // hekim TCKN
        Assert.Equal("12345", Alan(m, "ORC", 21));                  // kurum SKRS
        Assert.Equal("ACC-1", Alan(m, "OBR", 18));
        Assert.Equal("SYS-77", Alan(m, "OBR", 20));
        Assert.Equal("REF-99", Alan(m, "OBR", 21));
        Assert.Equal("CR", Alan(m, "OBR", 24));
        // OBR-7 ORU'da RAPOR ONAY zamanıdır - istem zamanı değil.
        Assert.Equal("20260918140000", Alan(m, "OBR", 7));
        Assert.Equal("20260918090000", Alan(m, "OBR", 6));
    }

    [Fact]
    public void Sut_ve_loinc_birlikte()
    {
        var m = OruUretici.Uret(Ornek());
        Assert.Equal("801950^Lumbo-sakral radyografi^SUT^24972-2^Lumbar vertebra XR^LNC",
                     Alan(m, "OBR", 4));
    }

    [Fact]
    public void Loinc_yoksa_parca_yazilmaz()
    {
        // Tür alanında SUT/LNC dışında bir şey gelirse mesaj reddediliyor;
        //   boş LOINC parçası da öyle.
        var m = OruUretici.Uret(Ornek() with { Loinc = "", LoincAdi = "" });
        Assert.Equal("801950^Lumbo-sakral radyografi^SUT", Alan(m, "OBR", 4));
    }

    [Fact]
    public void Hizmet_veren_kurum_obr15te()
    {
        // Raporu BİZ yazıyoruz, istem karşı hastanenin: kılavuzun
        //   "A hastanesi B'den hizmet alıyor" senaryosu.
        var m = OruUretici.Uret(Ornek());
        Assert.Equal("6789&&SKRS^^^^^R", Alan(m, "OBR", 15));
    }

    [Fact]
    public void Hizmet_veren_yoksa_varsayilan_radiology()
        => Assert.Equal("Radiology^^^^^R",
               Alan(OruUretici.Uret(Ornek() with { HizmetVerenSkrs = "" }), "OBR", 15));

    // --------------------------------------------------- Bakanlık gövdesi ----

    [Fact]
    public void Rapor_dort_parca_base64()
    {
        var v = Ornek();
        var m = OruUretici.Uret(v);
        var obx5 = Alan(m, "OBX", 5);
        var parcalar = obx5.Split('~');

        Assert.Equal(3, parcalar.Length);                 // karşılaştırma boş
        Assert.All(parcalar, p => Assert.Contains('^', p));

        string Coz(string parca) =>
            Encoding.UTF8.GetString(Convert.FromBase64String(parca.Split('^')[0]));

        // Parça NUMARASI kılavuzun tek bağlayıcı işareti: sıra serbest.
        var bulgular = parcalar.Single(p => p.EndsWith("^3", StringComparison.Ordinal));
        Assert.Equal(v.RaporBulgular, Coz(bulgular));
        var sonuc = parcalar.Single(p => p.EndsWith("^4", StringComparison.Ordinal));
        Assert.Equal(v.RaporSonuc, Coz(sonuc));
    }

    [Fact]
    public void Obx_degerlendirme_ve_radyolog()
    {
        var m = OruUretici.Uret(Ornek());
        Assert.Equal("TX", Alan(m, "OBX", 2));
        Assert.Equal("TXT^BASE64", Alan(m, "OBX", 3));
        Assert.Equal("F", Alan(m, "OBX", 11));
        Assert.Equal("4^5", Alan(m, "OBX", 13));                       // OBX-13
        Assert.Equal("11122233344^YILMAZ^MERT", Alan(m, "OBX", 16));   // radyolog TCKN
        Assert.Equal("IV^Ioheksol^300", Alan(m, "OBX", 17));
    }

    [Fact]
    public void Puanlardan_biri_bossa_obx13_yazilmaz()
    {
        // "4^0" kılavuzda karşılığı olmayan bir değer olurdu.
        var m = OruUretici.Uret(Ornek() with { CekimKalitePuan = 0 });
        Assert.Equal("", Alan(m, "OBX", 13));
    }

    [Fact]
    public void Addendum_durumu_c()
        => Assert.Equal("C", Alan(OruUretici.Uret(Ornek() with { Duzeltme = true }), "OBX", 11));

    [Fact]
    public void Tani_dg1de()
        => Assert.Equal("M54.5^^I10", Alan(OruUretici.Uret(Ornek()), "DG1", 3));

    // ------------------------------------------------------ kurum gövdesi ----

    [Fact]
    public void Kurum_profilinde_satir_satir_tx()
    {
        var m = OruUretici.Uret(Ornek(Hl7Profili.Kurum));
        var obx = m.Split('\r', StringSplitOptions.RemoveEmptyEntries)
                   .Where(x => x.StartsWith("OBX", StringComparison.Ordinal)).ToList();

        // Tek OBX'e sığdırmak uzun raporda kesilmeye yol açıyor.
        Assert.True(obx.Count > 1);
        // Başlık YAZILDIĞI GİBİ: büyük harfe çevirmek Türkçe "İ"yi bozuyordu.
        Assert.Contains(obx, x => x.Contains("Bulgular:", StringComparison.Ordinal));
        Assert.Contains(obx, x => x.Contains("Patolojik bulgu saptanmadı.", StringComparison.Ordinal));
        // Base64 YOK: kurum profilinde metin düz gider.
        Assert.DoesNotContain("BASE64", m, StringComparison.Ordinal);
    }

    // -------------------------------------------------------------- kaçış ----

    [Fact]
    public void Ayirici_karakterler_kacisli()
    {
        var m = OruUretici.Uret(Ornek() with
        {
            HastaSoyad = "A|B", HastaAd = "C^D",
            KlinikBilgi = @"x&y\z",
        });
        Assert.Equal(@"A\F\B^C\S\D", Alan(m, "PID", 5));
        Assert.Equal(@"x\T\y\E\z", Alan(m, "OBR", 13));
        // Kaçışsız tek karakter karşı tarafta BÜTÜN alanları kaydırır: mesaj
        //   yine yedi segment olmalı (MSH PID PV1 ORC OBR OBX DG1).
        Assert.Equal(7, m.Split('\r', StringSplitOptions.RemoveEmptyEntries).Length);
    }

    [Fact]
    public void Satir_sonu_segmenti_bolmez()
    {
        var m = OruUretici.Uret(Ornek() with { KlinikBilgi = "Bir\r\nİki" });
        var satirlar = m.Split('\r', StringSplitOptions.RemoveEmptyEntries);
        // Rapor metnindeki satır sonu segment sonu sanılırsa mesaj bozulur.
        Assert.All(satirlar, x => Assert.Matches("^[A-Z][A-Z0-9]{2}\\|", x));
        Assert.Contains(@"\X0D0A\", Alan(m, "OBR", 13), StringComparison.Ordinal);
    }

    [Fact]
    public void Sondaki_bos_alanlar_atilir()
    {
        var m = OruUretici.Uret(Ornek());
        Assert.DoesNotContain("||\r", m, StringComparison.Ordinal);
        Assert.All(m.Split('\r', StringSplitOptions.RemoveEmptyEntries),
                   x => Assert.False(x.EndsWith('|')));
    }
}
