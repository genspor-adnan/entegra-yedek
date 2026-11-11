using FellowOakDicom;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELETIP DOZ (1314, K3): RDSR künyesi KOS'la aynı (XDS 1.15 Tablo 5), içerik ağacı ve Irradiation Event UID değişmez,
/// BT'de DLP / CTDIvol boş ya da sıfırsa gönderilmez, Mirth K3 yanıtı (Tablo 6: 0000H, 0110H + SR1xx) çözümü, KOS başarıya
/// geçince doz satırı (yalnız iyonlaştırıcı modalite, tek).
/// </summary>
[Collection("TeletipReferans")]
public sealed class TeletipDozTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static OrmVerisi Orm() => new()
    {
        HastaDosyaNo = "H-000084", HastaTckn = "78221082662", HastaSoyad = "DEMO", HastaAd = "GENTEGRE", Cinsiyet = "M",
        DogumTarihi = new DateTime(1980, 5, 1), AccessionNo = "KGM0000000045998",
    };
    private static KosKurum Kurum() => new("Koşuyolu Görüntüleme", "148", "c3eade04-4f91-5dab-e043-14031b0ac9f9", "SERVERAE", "STM-12345");

    private static DicomDataset Kod(string deger, string sema, string anlam) => new()
    {
        { DicomTag.CodeValue, deger }, { DicomTag.CodingSchemeDesignator, sema }, { DicomTag.CodeMeaning, anlam },
    };

    private static DicomDataset Sayisal(string kod, string anlam, double deger, string birim) => new()
    {
        { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "NUM" },
        new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod(kod, "DCM", anlam)),
        new DicomSequence(DicomTag.MeasuredValueSequence, new DicomDataset
        {
            { DicomTag.NumericValue, deger.ToString(System.Globalization.CultureInfo.InvariantCulture) },
            new DicomSequence(DicomTag.MeasurementUnitsCodeSequence, Kod(birim, "UCUM", birim)),
        }),
    };

    /// <summary>Asgari BT RDSR (TID 10011): iki ışınlama olayı + birikimli DLP. Modalite cihazın yazdığı künye "yanlış".</summary>
    public static DicomDataset OrnekBtRdsr(double ctdi = 45.2, double dlp = 980.5, string sop = "1.2.826.0.1.3680043.8.498.777", string study = "1.2.3.4")
    {
        DicomDataset Olay(string uid, double c, double l) => new()
        {
            { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "CONTAINER" },
            new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113819", "DCM", "CT Acquisition")),
            new DicomSequence(DicomTag.ContentSequence,
                new DicomDataset
                {
                    { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "CODE" },
                    new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113820", "DCM", "CT Acquisition Type")),
                    new DicomSequence(DicomTag.ConceptCodeSequence, Kod("P5-08001", "SRT", "Spiral Acquisition")),
                },
                new DicomDataset
                {
                    { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "UIDREF" },
                    new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113769", "DCM", "Irradiation Event UID")),
                    { DicomTag.UID, uid },
                },
                new DicomDataset
                {
                    { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "CONTAINER" },
                    new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113822", "DCM", "CT Acquisition Parameters")),
                    new DicomSequence(DicomTag.ContentSequence, Sayisal("113825", "Scanning Length", 350, "mm"),
                                      Sayisal("113828", "Pitch Factor", 0.98, "{ratio}"), Sayisal("113834", "Exposure Time per Rotation", 0.5, "s"),
                                      Sayisal("113733", "KVP", 120, "kV"), Sayisal("113734", "X-Ray Tube Current", 250, "mA"),
                                      Sayisal("113736", "Exposure", 125, "mAs")),
                },
                new DicomDataset
                {
                    { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "CONTAINER" },
                    new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113829", "DCM", "CT Dose")),
                    new DicomSequence(DicomTag.ContentSequence, Sayisal("113830", "Mean CTDIvol", c, "mGy"), Sayisal("113838", "DLP", l, "mGy.cm")),
                }),
        };
        var d = new DicomDataset(DicomTransferSyntax.ExplicitVRLittleEndian)
        {
            { DicomTag.SpecificCharacterSet, "ISO_IR 100" },
            { DicomTag.SOPClassUID, DozUretici.RdsrSopClass }, { DicomTag.SOPInstanceUID, sop },
            { DicomTag.StudyInstanceUID, study }, { DicomTag.SeriesInstanceUID, sop + ".1" },
            { DicomTag.Modality, "SR" }, { DicomTag.StudyDate, "20261111" }, { DicomTag.StudyTime, "093000" },
            { DicomTag.ContentDate, "20261111" }, { DicomTag.ContentTime, "094500" },
            { DicomTag.AccessionNumber, "CIHAZ-ACC" }, { DicomTag.PatientName, "CIHAZ^ADI" }, { DicomTag.PatientID, "CIHAZ-ID" },
            { DicomTag.PatientSex, "O" }, { DicomTag.InstitutionName, "Cihaz Hastanesi" }, { DicomTag.DeviceSerialNumber, "CT-FABRIKA-1" },
            { DicomTag.Manufacturer, "Ornek" }, { DicomTag.ValueType, "CONTAINER" }, { DicomTag.SeriesNumber, "997" }, { DicomTag.InstanceNumber, "1" },
            { DicomTag.CompletionFlag, "COMPLETE" }, { DicomTag.VerificationFlag, "UNVERIFIED" },
            new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113701", "DCM", "X-Ray Radiation Dose Report")),
            new DicomSequence(DicomTag.ContentTemplateSequence, new DicomDataset { { DicomTag.MappingResource, "DCMR" }, { DicomTag.TemplateIdentifier, "10011" } }),
            new DicomSequence(DicomTag.ContentSequence,
                new DicomDataset
                {
                    { DicomTag.RelationshipType, "CONTAINS" }, { DicomTag.ValueType, "CONTAINER" },
                    new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113811", "DCM", "CT Accumulated Dose Data")),
                    new DicomSequence(DicomTag.ContentSequence, Sayisal("113812", "Total Number of Irradiation Events", 2, "{events}"),
                                      Sayisal("113813", "CT Dose Length Product Total", dlp * 2, "mGy.cm")),
                },
                Olay("1.2.826.0.1.3680043.8.498.777.11", 0, 0),            // lokalizer: sıfır doz
                Olay("1.2.826.0.1.3680043.8.498.777.12", ctdi, dlp)),
        };
        return d;
    }

    [Fact]
    public void Kunye_KOS_ile_ayni_icerik_degismez()
    {
        var kaynak = OrnekBtRdsr();
        var d = DozUretici.Kunye(kaynak, Orm(), Kurum(), "1.2.3.4", 178, 82.5);
        Assert.Equal("KGM0000000045998", d.GetString(DicomTag.AccessionNumber));
        Assert.Equal("78221082662", d.GetString(DicomTag.PatientID));
        Assert.Equal("H-000084", d.GetString(DicomTag.OtherPatientIDsRETIRED));
        Assert.Equal("DEMO^GENTEGRE", d.GetString(DicomTag.PatientName));
        Assert.Equal("M", d.GetString(DicomTag.PatientSex));
        Assert.Equal("Koşuyolu Görüntüleme^^^SKRS148^^^FKc3eade04-4f91-5dab-e043-14031b0ac9f9", d.GetString(DicomTag.InstitutionName));
        Assert.Equal("STM-12345", d.GetString(DicomTag.DeviceSerialNumber));
        Assert.Equal("1.78", d.GetString(DicomTag.PatientSize));
        Assert.Equal("82.5", d.GetString(DicomTag.PatientWeight));
        Assert.Equal("1.2.826.0.1.3680043.8.498.777", d.GetString(DicomTag.SOPInstanceUID));      // SOP UID korunur
        Assert.Equal("CIHAZ-ACC", kaynak.GetString(DicomTag.AccessionNumber));                    // kaynak değişmedi
        // İçerik ağacı (Irradiation Event UID) aynen: Part 10'a yazılıp okunduktan sonra da.
        var geri = DicomFile.Open(new MemoryStream(KosUretici.Baytlar(new DicomFile(d)))).Dataset;
        var olay = geri.GetSequence(DicomTag.ContentSequence).Items[2].GetSequence(DicomTag.ContentSequence).Items[1];
        Assert.Equal("1.2.826.0.1.3680043.8.498.777.12", olay.GetString(DicomTag.UID));
        Assert.Equal("Koşuyolu Görüntüleme^^^SKRS148^^^FKc3eade04-4f91-5dab-e043-14031b0ac9f9", geri.GetString(DicomTag.InstitutionName));
        // Cihaz boy / kilo yazmışsa üzerine yazılmaz.
        var cihazBoy = OrnekBtRdsr(); cihazBoy.AddOrUpdate(DicomTag.PatientSize, "1.65");
        Assert.Equal("1.65", DozUretici.Kunye(cihazBoy, Orm(), Kurum(), "1.2.3.4", 178, null).GetString(DicomTag.PatientSize));
    }

    [Fact]
    public void Ozet_ve_denetim()
    {
        var d = DozUretici.Kunye(OrnekBtRdsr(), Orm(), Kurum(), "1.2.3.4", 178, 82);
        var o = DozUretici.Ozet(d);
        Assert.Equal("10011", o.Sablon);
        Assert.Equal(2, o.OlaySayisi);
        Assert.Equal(1961, o.ToplamDlp);
        Assert.Equal(45.2, o.EnBuyukCtdiVol);
        Assert.Equal(120, o.Kvp); Assert.Equal(250, o.Ma); Assert.Equal(125, o.Mas); Assert.Equal(0.5, o.RotasyonSn);
        Assert.Equal(350, o.UzunlukMm); Assert.Equal(0.98, o.Pitch);
        Assert.Equal("Spiral Acquisition", o.Tarama);
        Assert.Equal(1, o.SifirDozluOlay);
        var (h, u) = DozUretici.Denetle(d, o);
        Assert.Empty(h);
        Assert.Contains(u, x => x.Contains("lokalizer"));
        Assert.DoesNotContain(u, x => x.Contains("boyu"));
        Assert.Contains("DLP toplam: 1961 mGy·cm", DozUretici.MesajMetni(d, o));

        // DLP / CTDIvol sıfır → Bakanlık kabul etmez, gönderilmez.
        var sifir = DozUretici.Kunye(OrnekBtRdsr(0, 0), Orm(), Kurum(), "1.2.3.4", null, null);
        var (h2, u2) = DozUretici.Denetle(sifir, DozUretici.Ozet(sifir));
        Assert.Contains(h2, x => x.Contains("DLP"));
        Assert.Contains(u2, x => x.Contains("boyu"));
        // Cinsiyet yok, accession yok.
        var eksik = DozUretici.Kunye(OrnekBtRdsr(), Orm() with { Cinsiyet = "U", AccessionNo = "" }, Kurum(), "1.2.3.4", 1, 1);
        eksik.AddOrUpdate(DicomTag.PatientSex, "O");
        var (h3, _) = DozUretici.Denetle(eksik, DozUretici.Ozet(eksik));
        Assert.Contains(h3, x => x.Contains("cinsiyet"));
        Assert.Contains(h3, x => x.Contains("AccessionNumber"));
    }

    [Theory]
    [InlineData("DURUM=SENT\nKOD=0000\nYORUM=\nMESAJ=DICOM message successfully sent", 1, "0000")]
    [InlineData("DURUM=ERROR\nKOD=0110\nYORUM=SR111,SR114\nMESAJ=Error status code received from DICOM server: 0x0110", 2, "0110")]
    [InlineData("DURUM=ERROR\nKOD=\nYORUM=\nMESAJ=Error status code received from DICOM server: 0xC000", 2, "C000")]
    [InlineData("DURUM=SENT\nKOD=B000\nYORUM=\nMESAJ=DICOM message successfully sent with warning status code: 0xB000", 1, "B000")]
    [InlineData("DURUM=ERROR\nKOD=\nYORUM=\nMESAJ=Connection refused", 5, "")]
    [InlineData("", 5, "")]
    public void Yanit_Tablo6(string govde, short durum, string ack)
    {
        var s = DozYaniti.Coz(govde);
        Assert.Equal(durum, s.Durum);
        Assert.Equal(ack, s.Ack);
        if (govde.Contains("SR111")) Assert.Contains("SR114 InstitutionName'de SKRS ve firma kodu olmalı", s.Aciklama);
    }

    [Fact]
    public void Ornek_RDSR_dosyasi_istege_bagli()
    {
        // GENTEGRE_RDSR_CIKTI=<yol> verilirse elle uçtan uca deneme için örnek RDSR yazılır (study / SOP ortamdan).
        var yol = Environment.GetEnvironmentVariable("GENTEGRE_RDSR_CIKTI");
        if (string.IsNullOrEmpty(yol)) return;
        var d = OrnekBtRdsr(study: Environment.GetEnvironmentVariable("GENTEGRE_RDSR_STUDY") ?? "1.2.3.4",
                            sop: Environment.GetEnvironmentVariable("GENTEGRE_RDSR_SOP") ?? "1.2.826.0.1.3680043.8.498.777");
        new DicomFile(d).Save(yol);
    }

    [VtFact]
    public async Task KOS_basarisinda_doz_satiri_yalniz_iyonlastirici()
    {
        if (!olgu.Baglandi(nameof(KOS_basarisinda_doz_satiri_yalniz_iyonlastirici))) return;
        await using var b = await olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await b.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1", t, [], default);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, ad, soyad, kod, hasta, vkno, sube_id) values ('TT DOZ', 'Ali', 'Çelik', @p1, 1, '10000000146', @p0) returning id",
            t, [sube, "TD" + Guid.NewGuid().ToString("N")[..8]], default);
        async Task<int> Istem(short modalite)
        {
            var hizmet = await b.TekDegerAsync<int>(
                "insert into public.hizmet (kod, ad, radyoloji, modalite, sube_id) values (@p0, 'TT doz', 1, @p1, @p2) returning id",
                t, ["TD" + Guid.NewGuid().ToString("N")[..8], modalite, sube], default);
            return await b.TekDegerAsync<int>("""
                insert into public.radyoloji_istem (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, study_uid)
                values (@p0, @p1, @p2, @p3, @p4, 1, @p5) returning id
                """, t, [sube, hasta, hizmet, modalite, "TD-" + Guid.NewGuid().ToString("N")[..10], "2.25." + Random.Shared.NextInt64(1, long.MaxValue)], default);
        }
        async Task<long> Kos(int istem) => await b.TekDegerAsync<long>("""
            insert into public.teletip_gonderim (istem_id, accession_no, kanal, emir, durum, study_uid, sube_id)
            select id, accession_no, 2, 1, 0, study_uid, sube_id from public.radyoloji_istem where id = @p0 returning id
            """, t, [istem], default);
        Task<int> DozSayisi(int istem) => b.TekDegerAsync<int>(
            "select count(*)::int from public.teletip_gonderim where istem_id = @p0 and kanal = 3 and durum = 0", t, [istem], default);

        var bt = await Istem(1); var mr = await Istem(2);
        var kBt = await Kos(bt); var kMr = await Kos(mr);
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where id in (@p0, @p1)", t, [kBt, kMr], default);
        Assert.Equal(1, await DozSayisi(bt));
        Assert.Equal(0, await DozSayisi(mr));                       // MR iyonlaştırıcı değil
        // Aynı çalışmanın KOS'u yeniden başarıya geçse de ikinci doz satırı açılmaz.
        var kBt2 = await Kos(bt);
        await b.CalistirAsync("update public.teletip_gonderim set durum = 1 where id = @p0", t, [kBt2], default);
        Assert.Equal(1, await DozSayisi(bt));
        Assert.Equal(await b.TekDegerAsync<string>("select study_uid from public.radyoloji_istem where id = @p0", t, [bt], default),
                     await b.TekDegerAsync<string>("select study_uid from public.teletip_gonderim where istem_id = @p0 and kanal = 3", t, [bt], default));
        await t.RollbackAsync();
    }
}
