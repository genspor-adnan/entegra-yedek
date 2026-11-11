using FellowOakDicom;
using Gentegre.Api.Servisler;

namespace Gentegre.Testler;

/// <summary>
/// MWL ÇEVİRİSİ (1301; Teletıp hedefi): Bakanlık kılavuzu 3.43 § 5.2 görüntüyü isteme accession + TCKN (ya da dosya no)
/// ile bağlar. Cihaza giden worklist bu iki etiketi istemden birebir taşımalı; Türkçe ad karakter setinde bozulmamalı.
/// </summary>
public sealed class MwlCeviriciTestleri
{
    private static MwlSatiri Satir(string tckn = "78221082662", string dosya = "H-000084") => new(
        2569, "R-000018", "CT", new DateTime(2026, 11, 11, 9, 30, 0), tckn, dosya, "Çağlayan", "Şükrü İsmail",
        new DateTime(1980, 5, 1), "M", "BT1", "BT, Mandibula", "804490", "24590-2", "Güneş", "Ömer", "Uz. Dr.", "CT01", 0, "Ağrı");

    [Fact]
    public void PatientID_gecerli_TCKN_ise_TCKN_digeri_dosya_no()
    {
        var d = MwlCevirici.Kumeye(Satir(), null, "ISO_IR 148", "CT01");
        Assert.Equal("78221082662", d.GetString(DicomTag.PatientID));
        Assert.Equal("H-000084", d.GetString(DicomTag.OtherPatientIDsRETIRED));
        Assert.Equal("R-000018", d.GetString(DicomTag.AccessionNumber));
        var adim = d.GetSequence(DicomTag.ScheduledProcedureStepSequence).Items[0];
        Assert.Equal("CT", adim.GetString(DicomTag.Modality));
        Assert.Equal("CT01", adim.GetString(DicomTag.ScheduledStationAETitle));
        Assert.Equal("20261111", adim.GetString(DicomTag.ScheduledProcedureStepStartDate));
        Assert.Equal("804490", d.GetSequence(DicomTag.RequestedProcedureCodeSequence).Items[0].GetString(DicomTag.CodeValue));
    }

    [Fact]
    public void TCKN_yoksa_PatientID_dosya_no_ve_OtherPatientIDs_yok()
    {
        var d = MwlCevirici.Kumeye(Satir(tckn: ""), null, "ISO_IR 148", "CT01");
        Assert.Equal("H-000084", d.GetString(DicomTag.PatientID));
        Assert.False(d.Contains(DicomTag.OtherPatientIDsRETIRED));
    }

    [Theory]
    [InlineData("ISO_IR 148")]
    [InlineData("ISO_IR 192")]
    public void Turkce_ad_dosyaya_yazilip_okununca_bozulmaz(string kume)
    {
        var d = MwlCevirici.Kumeye(Satir(), null, kume, "CT01");
        // Ağ yerine dosya ile kodla/çöz (aynı yazıcı); dosya başlığı SOP sınıfı ister.
        d.AddOrUpdate(DicomTag.SOPClassUID, DicomUID.ModalityWorklistInformationModelFind);
        d.AddOrUpdate(DicomTag.SOPInstanceUID, DicomUID.Generate());
        var dosya = new DicomFile(d);
        using var bellek = new MemoryStream();
        dosya.Save(bellek);
        bellek.Position = 0;
        var geri = DicomFile.Open(bellek).Dataset;
        Assert.Equal("ÇAĞLAYAN^ŞÜKRÜ İSMAİL", geri.GetString(DicomTag.PatientName));
        Assert.Equal("BT, Mandibula", geri.GetSequence(DicomTag.ScheduledProcedureStepSequence).Items[0]
                                          .GetString(DicomTag.ScheduledProcedureStepDescription));
    }

    [Fact]
    public void ASCII_kipinde_Turkce_harf_indirgenir_karakter_seti_yazilmaz()
    {
        var d = MwlCevirici.Kumeye(Satir(), null, "ASCII", "CT01");
        Assert.Equal("CAGLAYAN^SUKRU ISMAIL", d.GetString(DicomTag.PatientName));
        Assert.False(d.Contains(DicomTag.SpecificCharacterSet));
    }

    [Theory]
    [InlineData("20261111", "2026-11-11", "2026-11-11")]
    [InlineData("20261111-20261112", "2026-11-11", "2026-11-12")]
    [InlineData("-20261112", null, "2026-11-12")]
    [InlineData("20261111-", "2026-11-11", null)]
    [InlineData("", null, null)]
    [InlineData("*", null, null)]
    public void Tarih_araligi(string girdi, string? bas, string? bit)
    {
        var (b, s) = MwlCevirici.TarihAraligi(girdi);
        Assert.Equal(bas is null ? null : DateTime.Parse(bas), b);
        Assert.Equal(bit is null ? null : DateTime.Parse(bit), s);
    }

    [Theory]
    [InlineData("", true)]
    [InlineData("*", true)]
    [InlineData("ÇAĞ*", true)]
    [InlineData("cag*", true)]
    [InlineData("ÇAĞLAYAN^ŞÜKRÜ*", true)]
    [InlineData("YILMAZ*", false)]
    public void Hasta_adi_joker(string desen, bool beklenen) =>
        Assert.Equal(beklenen, MwlCevirici.AdUyar(desen, Satir()));

    [Fact]
    public void Sorgu_joker_alanlari_suzgec_degildir()
    {
        var q = new DicomDataset();
        q.Add(DicomTag.AccessionNumber, "*");
        q.Add(DicomTag.PatientID, "");
        var adim = new DicomDataset { { DicomTag.Modality, "MR" }, { DicomTag.ScheduledProcedureStepStartDate, "20261111" } };
        q.Add(new DicomSequence(DicomTag.ScheduledProcedureStepSequence, adim));
        var s = MwlCevirici.SorguOku(q);
        Assert.Equal("", s.Accession);
        Assert.Equal("", s.HastaId);
        Assert.Equal("MR", s.Modalite);
        Assert.Equal(new DateTime(2026, 11, 11), s.Baslangic);
    }
}
