using System.Text;
using FellowOakDicom;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Testler;

/// <summary>
/// TELETIP KOS (K2; XDS Entegrasyon Kılavuzu 1.15): KOS içeriği Tablo 2'ye uyar mı (InstitutionName / RetrieveLocationUID
/// biçimleri, hiyerarşik referans, ikon), küçük resim JPEG'i geçerli mi, RAD-68 MTOM zarfı ve Tablo 3 yanıtları.
/// </summary>
public sealed class TeletipKosTestleri
{
    private static OrmVerisi Orm() => new()
    {
        HastaDosyaNo = "H-000084", HastaTckn = "78221082662", HastaSoyad = "DEMO", HastaAd = "GENTEGRE", Cinsiyet = "M",
        DogumTarihi = new DateTime(1980, 5, 1), AccessionNo = "KGM0000000045998", IsteyenHekim = new("12345678950", "GÜNEŞ", "ÖMER"),
        Loinc = [new("24725-4", "CT Head")], PlanlananZaman = new DateTime(2026, 11, 11, 9, 30, 0),
    };
    private static KosKurum Kurum() => new("Koşuyolu Görüntüleme", "148", "c3eade04-4f91-5dab-e043-14031b0ac9f9", "SERVERAE", "STM-12345");
    private static KosCalisma Calisma(KucukResim? ikon = null)
    {
        var s1 = new KosSeri("1.2.3.4.1", "CT", "Aksiyel", 1, [new("1.2.840.10008.5.1.4.1.1.2", "1.2.3.4.1.1", 1, 1), new("1.2.840.10008.5.1.4.1.1.2", "1.2.3.4.1.2", 2, 1)]) { Ikon = ikon };
        var s2 = new KosSeri("1.2.3.4.2", "MR", "Çok kare", 2, [new("1.2.840.10008.5.1.4.1.1.4.1", "1.2.3.4.2.1", 1, 96)]);
        return new("1.2.3.4", "20261111", "093000", "Beyin BT", [s1, s2]);
    }

    [Fact]
    public void KOS_Tablo2_alanlari()
    {
        var f = KosUretici.Uret(Orm(), Calisma(), Kurum(), new DateTime(2026, 11, 11, 10, 0, 0), "1.2.3.9");
        var d = f.Dataset;
        Assert.Equal(KosUretici.KosSopClass, d.GetString(DicomTag.SOPClassUID));
        Assert.Equal("KO", d.GetString(DicomTag.Modality));
        Assert.Equal("1.2.3.4", d.GetString(DicomTag.StudyInstanceUID));
        Assert.Equal("KGM0000000045998", d.GetString(DicomTag.AccessionNumber));
        Assert.Equal("78221082662", d.GetString(DicomTag.PatientID));
        Assert.Equal("H-000084", d.GetString(DicomTag.OtherPatientIDsRETIRED));
        Assert.Equal("Koşuyolu Görüntüleme^^^SKRS148^^^FKc3eade04-4f91-5dab-e043-14031b0ac9f9", d.GetString(DicomTag.InstitutionName));
        Assert.Equal("STM-12345", d.GetString(DicomTag.DeviceSerialNumber));
        Assert.Equal("113030", d.GetSequence(DicomTag.ConceptNameCodeSequence).Items[0].GetString(DicomTag.CodeValue));
        var calisma = d.GetSequence(DicomTag.CurrentRequestedProcedureEvidenceSequence).Items[0];
        var seriler = calisma.GetSequence(DicomTag.ReferencedSeriesSequence).Items;
        Assert.Equal(2, seriler.Count);
        Assert.Equal("SERVERAE", seriler[0].GetString(DicomTag.RetrieveAETitle));
        Assert.Equal("1.3.6.1.4.1.21367.2017.10.26.148", seriler[0].GetString(DicomTag.RetrieveLocationUID));
        Assert.Equal(2, seriler[0].GetSequence(DicomTag.ReferencedSOPSequence).Items.Count);
        // Çok kare: Number of Frames zorunlu.
        Assert.Equal("96", seriler[1].GetSequence(DicomTag.ReferencedSOPSequence).Items[0].GetString(DicomTag.NumberOfFrames));
        // MakeKOS v2.0: tek karede de NumberOfFrames ve InstanceNumber yazılır; RPPS boş dizi.
        Assert.Equal("1", seriler[0].GetSequence(DicomTag.ReferencedSOPSequence).Items[0].GetString(DicomTag.NumberOfFrames));
        Assert.True(d.Contains(DicomTag.ReferencedPerformedProcedureStepSequence));
        Assert.Equal(3, d.GetSequence(DicomTag.ContentSequence).Items.Count);
        // Part 10 olarak yazılıp okunabiliyor.
        var geri = DicomFile.Open(new MemoryStream(KosUretici.Baytlar(f))).Dataset;
        Assert.Equal("Koşuyolu Görüntüleme^^^SKRS148^^^FKc3eade04-4f91-5dab-e043-14031b0ac9f9", geri.GetString(DicomTag.InstitutionName));
    }

    [Fact]
    public void Ikon_Tablo2_kurallari()
    {
        var gri = Enumerable.Range(0, 64 * 48).Select(i => (byte)(i % 256)).ToArray();
        var ikon = new KucukResim(JpegKodlayici.Gri422(gri, 64, 48), 48, 64);
        var d = KosUretici.Uret(Orm(), Calisma(ikon), Kurum(), DateTime.Now).Dataset;
        var i = d.GetSequence(DicomTag.CurrentRequestedProcedureEvidenceSequence).Items[0]
                 .GetSequence(DicomTag.ReferencedSeriesSequence).Items[0].GetSequence(DicomTag.IconImageSequence).Items[0];
        Assert.Equal("YBR_FULL_422", i.GetString(DicomTag.PhotometricInterpretation));
        Assert.Equal((ushort)48, i.GetSingleValue<ushort>(DicomTag.Rows));
        Assert.Equal((ushort)64, i.GetSingleValue<ushort>(DicomTag.Columns));
        Assert.Equal((ushort)8, i.GetSingleValue<ushort>(DicomTag.BitsAllocated));
        Assert.Equal((ushort)7, i.GetSingleValue<ushort>(DicomTag.HighBit));
        Assert.Equal(DicomVR.OB, i.GetDicomItem<DicomElement>(DicomTag.PixelData).ValueRepresentation);
    }

    [Fact]
    public void JPEG_temel_422_yapisi()
    {
        var gri = new byte[40 * 20];
        for (var y = 0; y < 20; y++) for (var x = 0; x < 40; x++) gri[y * 40 + x] = (byte)(x * 6);
        var j = JpegKodlayici.Gri422(gri, 40, 20);
        Assert.Equal(new byte[] { 0xFF, 0xD8 }, j[..2]);
        Assert.Equal(new byte[] { 0xFF, 0xD9 }, j[^2..]);
        var sof = IndexOf(j, [0xFF, 0xC0]);
        Assert.True(sof > 0);
        Assert.Equal(20, (j[sof + 5] << 8) | j[sof + 6]);     // yükseklik
        Assert.Equal(40, (j[sof + 7] << 8) | j[sof + 8]);     // genişlik
        Assert.Equal(3, j[sof + 9]);                          // 3 bileşen
        Assert.Equal(0x21, j[sof + 11]);                      // Y H2V1 = 4:2:2
        // Pillow ile bağımsız doğrulama varsa çalıştır: gerçek bir JPEG çözücü dosyayı açabilmeli.
        var yol = Path.Combine(Path.GetTempPath(), $"gentegre_jpeg_{Guid.NewGuid():N}.jpg");
        File.WriteAllBytes(yol, j);
        try
        {
            var p = System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("python",
                $"-c \"from PIL import Image; i=Image.open(r'{yol}'); i.load(); print(i.size, i.mode)\"")
            { RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false });
            if (p is null) return;
            var cikti = p.StandardOutput.ReadToEnd(); var hata = p.StandardError.ReadToEnd(); p.WaitForExit(20000);
            if (hata.Contains("No module named", StringComparison.Ordinal) || hata.Contains("not recognized", StringComparison.Ordinal)) return;
            Assert.Contains("(40, 20) RGB", cikti);
        }
        catch (System.ComponentModel.Win32Exception) { /* python yok - yapı denetimi yeter */ }
        finally { File.Delete(yol); }
    }

    [Fact]
    public void Kucuk_resim_16bit_gri_DICOM_den()
    {
        var d = new DicomDataset(DicomTransferSyntax.ExplicitVRLittleEndian);
        d.Add(DicomTag.PhotometricInterpretation, "MONOCHROME2");
        d.Add(DicomTag.Rows, (ushort)300); d.Add(DicomTag.Columns, (ushort)512);
        d.Add(DicomTag.BitsAllocated, (ushort)16); d.Add(DicomTag.BitsStored, (ushort)12); d.Add(DicomTag.HighBit, (ushort)11);
        d.Add(DicomTag.PixelRepresentation, (ushort)0); d.Add(DicomTag.SamplesPerPixel, (ushort)1);
        var px = new ushort[300 * 512];
        for (var i = 0; i < px.Length; i++) px[i] = (ushort)(i % 4096);
        d.Add(DicomVR.OW, DicomTag.PixelData, px);
        var k = KucukResimUretici.Uret(d);
        Assert.NotNull(k);
        Assert.True(k!.Satir <= 128 && k.Sutun <= 128);
        Assert.Equal(0, k.Sutun % 2);
        Assert.Equal(new byte[] { 0xFF, 0xD8 }, k.Jpeg[..2]);
    }

    [Fact]
    public void Denetim_eksikler()
    {
        Assert.Empty(KosUretici.Denetle(Orm(), Calisma(), Kurum()));
        var e = KosUretici.Denetle(Orm() with { Cinsiyet = "U", HastaTckn = "" }, Calisma() with { Tarih = "" },
                                   Kurum() with { CihazSeriNo = "", FirmaKodu = "" });
        Assert.Contains(e, x => x.Contains("cinsiyet"));
        Assert.Contains(e, x => x.Contains("StudyDate"));
        Assert.Contains(e, x => x.Contains("DeviceSerialNumber"));
        Assert.Contains(e, x => x.Contains("FK"));
        Assert.Contains(KosUretici.Denetle(Orm(), null, Kurum()), x => x.Contains("PACS"));
    }

    [Fact]
    public void XDS_zarfi_MTOM_ve_eylem()
    {
        var kos = KosUretici.Baytlar(KosUretici.Uret(Orm(), Calisma(), Kurum(), DateTime.Now, "1.2.3.9"));
        var z = XdsZarfi.Kur(kos, "1.2.3.9", "1.2.3.4", Orm(), Kurum(), "http://xds/repo", new DateTime(2026, 11, 11, 7, 0, 0), "2.16.792.1", "CT");
        Assert.StartsWith("multipart/related;", z.IcerikTuru);
        Assert.Contains("type=\"application/xop+xml\"", z.IcerikTuru);
        Assert.Contains("action=\"urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b\"", z.IcerikTuru);
        Assert.Contains("<wsa:Action soap:mustUnderstand=\"1\">urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b</wsa:Action>", z.SoapXml);
        Assert.Contains("ProvideAndRegisterDocumentSetRequest", z.SoapXml);
        Assert.Contains("mimeType=\"application/dicom\"", z.SoapXml);
        Assert.Contains("href=\"cid:kos@gentegre\"", z.SoapXml);
        Assert.Contains("78221082662^^^&amp;2.16.792.1&amp;ISO", z.SoapXml);
        Assert.Contains("PID-7|19800501000000", z.SoapXml);
        // 1323: doğum tarihi yoksa PID-7 boş (eskiden "000000" - geçersiz HL7 tarihi).
        var zb = XdsZarfi.Kur(kos, "1.2.3.9", "1.2.3.4", Orm() with { DogumTarihi = null }, Kurum(), "http://xds/repo", new DateTime(2026, 11, 11, 7, 0, 0), "2.16.792.1", "CT");
        Assert.Contains("<rim:Value>PID-7|</rim:Value>", zb.SoapXml);
        // Bakanlık SendKOS v15 şablonu (submit_image_document.xml) birebir.
        Assert.Contains($"value=\"{XdsZarfi.KaynakKimligi}\"", z.SoapXml);         // sourceId sabit
        Assert.Contains("nodeRepresentation=\"DEMO-Eval\"", z.SoapXml);              // classCode
        Assert.Contains("urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d", z.SoapXml);   // formatCode şeması
        Assert.Contains("nodeRepresentation=\"Hospital Setting\"", z.SoapXml);
        Assert.Contains("nodeRepresentation=\"General Medicine\"", z.SoapXml);
        Assert.Contains("name=\"authorPerson\"", z.SoapXml);
        Assert.DoesNotContain("2c6b8cb7-8b2a-4051-b291-b1ae6a575ef4", z.SoapXml);     // eventCodeList yok
        // Belge kimliği ExtrinsicObject ile Document ekinde aynı.
        var x = System.Xml.Linq.XDocument.Parse(z.SoapXml);
        var eo = x.Descendants().First(e => e.Name.LocalName == "ExtrinsicObject").Attribute("id")!.Value;
        Assert.StartsWith("urn:uuid:", eo);
        Assert.Equal(eo, x.Descendants().First(e => e.Name.LocalName == "Document").Attribute("id")!.Value);
        Assert.Equal("1.3.6.1.4.1.21367.13.20.3000", XdsZarfi.VarsayilanHastaOid);
        var govde = Encoding.Latin1.GetString(z.Govde);
        Assert.Contains("Content-Type: application/dicom", govde);
        Assert.Contains("Content-ID: <kos@gentegre>", govde);
        Assert.True(IndexOf(z.Govde, "DICM"u8.ToArray()) > 0);                  // Part 10 dosyası ekte bayt olarak
    }

    [Fact]
    public void Yanit_Tablo3_basari_eslesme()
    {
        var y = XdsYaniti.Coz("""
            <rs:RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success">
              <rs:RegistryErrorList><rs:RegistryError codeContext="{ &quot;result&quot;: true, &quot;institutionId&quot;: 111111, &quot;citizenId&quot;: &quot;11111111111&quot;, &quot;accessionNumberList&quot;: &quot;[\&quot;123456789\&quot;]&quot;, &quot;error&quot;: &quot;&quot;}"
                errorCode="MatchStatus" location="ProvideAndRegister.java" severity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning" /></rs:RegistryErrorList>
            </rs:RegistryResponse>
            """);
        Assert.True(y.Basarili);
        Assert.True(y.Eslesti);
        Assert.Equal("MatchStatus", y.HataKodu);
    }

    [Fact]
    public void Yanit_Tablo3_kismi_ve_hata()
    {
        var k = XdsYaniti.Coz("""
            --x
            Content-Type: application/xop+xml
            <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope"><s:Body>
            <rs:RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="urn:ihe:iti:2007:ResponseStatusType:PartialSuccess">
            <rs:RegistryErrorList><rs:RegistryError codeContext="{ &quot;result&quot;: true, &quot;institutionId&quot;: -1, &quot;citizenId&quot;: &quot;&quot;, &quot;accessionNumberList&quot;: &quot;[]&quot;, &quot;error&quot;: &quot;&quot;}" errorCode="MatchStatus" severity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error" /></rs:RegistryErrorList>
            </rs:RegistryResponse></s:Body></s:Envelope>
            --x--
            """);
        Assert.Equal("PartialSuccess", k.Durum);
        Assert.False(k.Eslesti);
        Assert.Contains("eşleşmedi", k.Aciklama);

        var h = XdsYaniti.Coz("""
            <rs:RegistryResponse xmlns:rs="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure">
            <rs:RegistryErrorList><rs:RegistryError codeContext="Hasta Adı, PatientID/OtherPatientIDs, Cinsiyeti, Çekim Tarihi boş olamaz." errorCode="XDSRepositoryError" severity="urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error" /></rs:RegistryErrorList>
            </rs:RegistryResponse>
            """);
        Assert.Equal("Failure", h.Durum);
        Assert.Equal("XDSRepositoryError", h.HataKodu);
        Assert.Contains("Cinsiyeti", h.Aciklama);
        Assert.Equal("", XdsYaniti.Coz("<html>502</html>").Durum);
    }

    private static int IndexOf(byte[] a, byte[] b)
    {
        for (var i = 0; i <= a.Length - b.Length; i++)
            if (a.AsSpan(i, b.Length).SequenceEqual(b)) return i;
        return -1;
    }
}
