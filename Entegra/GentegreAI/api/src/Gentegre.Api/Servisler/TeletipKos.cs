using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using FellowOakDicom;
using FellowOakDicom.Imaging;
using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Api.Servisler;

// =====================================================================================================================
// TELETIP KOS (K2) - kullanıcı 11.11.2026: "KOS gönderimini (K2) yap". Teleradyoloji XDS Entegrasyon Kılavuzu 1.15:
//   § 2.1 KOS dokümanı (Tablo 2 - Hiyerarşik SOP Örnek Referans Makrosu), § 2.2 RAD-68 (ITI-41 Provide & Register,
//   SOAP 1.2 + MTOM/XOP), Tablo 3 yanıtları. KOS ve zarf Gentegre'de üretilir; Mirth K2 (TELETIP_KOS) yalnız taşır.
//   ebRIM metadata kodları kılavuzda metin olarak YOK (örnek gövde resim) - 11.11.2026'da Bakanlık SendKOS v15
//   (submit_image_document.xml) ve MakeKOS v2.0 kaynağıyla karşılaştırılıp onlara hizalandı (bkz. tarihçe).
// =====================================================================================================================

/// <summary>PACS'tan okunan çalışma yapısı (C-FIND study / series / image).</summary>
public sealed record KosCalisma(string StudyUid, string Tarih, string Saat, string Aciklama, List<KosSeri> Seriler);
public sealed record KosSeri(string SeriesUid, string Modalite, string Aciklama, int No, List<KosGoruntu> Goruntuler)
{
    /// <summary>Seri küçük resmi (≤128×128 JPEG, YBR_FULL_422) - üretilemediyse null.</summary>
    public KucukResim? Ikon { get; set; }
}
public sealed record KosGoruntu(string SopClassUid, string SopInstanceUid, int No, int Kare);
public sealed record KucukResim(byte[] Jpeg, int Satir, int Sutun);

/// <summary>KOS'un kurum / cihaz girdileri.</summary>
public sealed record KosKurum(string KurumAdi, string Skrs, string FirmaKodu, string RetrieveAe, string CihazSeriNo);

/// <summary>
/// KOS ÜRETİCİ (Key Object Selection Document, SOP Class 1.2.840.10008.5.1.4.1.1.88.59, Modality KO). Kılavuz Tablo 2:
/// StudyInstanceUID = çalışmanınki, AccessionNumber, PatientName, PatientID (TCKN; yoksa dosya no) + OtherPatientIDs
/// (dosya no), InstitutionName "Ad^^^SKRS&lt;kod&gt;^^^FK&lt;firma kodu&gt;", DeviceSerialNumber (Teletıp STM cihaz seri no),
/// Current Requested Procedure Evidence Sequence → Referenced Series (Retrieve AE Title + Retrieve Location UID
/// 1.3.6.1.4.1.21367.2017.10.26.&lt;SKRS&gt;) → Referenced SOP (+ Number of Frames çok karede) + seri başına Icon Image.
/// </summary>
public static class KosUretici
{
    public const string KosSopClass = "1.2.840.10008.5.1.4.1.1.88.59";
    public const string RetrieveOidKoku = "1.3.6.1.4.1.21367.2017.10.26.";

    public static string RetrieveLocationUid(string skrs) => RetrieveOidKoku + skrs;

    /// <summary>Kılavuz biçimi: "Hastane Adı^^^SKRS12345^^^FK&lt;firma kodu&gt;".</summary>
    public static string KurumAlani(KosKurum k) => $"{Temiz(k.KurumAdi)}^^^SKRS{k.Skrs}^^^FK{k.FirmaKodu}";

    public static DicomFile Uret(OrmVerisi v, KosCalisma c, KosKurum k, DateTime simdi, string? sopUid = null)
    {
        var d = new DicomDataset().NotValidated();
        var sop = sopUid ?? DicomUID.Generate().UID;
        d.AddOrUpdate(DicomTag.SpecificCharacterSet, "ISO_IR 192");
        d.AddOrUpdate(DicomTag.SOPClassUID, KosSopClass);
        d.AddOrUpdate(DicomTag.SOPInstanceUID, sop);
        d.AddOrUpdate(DicomTag.StudyInstanceUID, c.StudyUid);
        d.AddOrUpdate(DicomTag.SeriesInstanceUID, DicomUID.Generate().UID);
        d.AddOrUpdate(DicomTag.Modality, "KO");
        d.AddOrUpdate(DicomTag.SeriesNumber, "999");
        d.AddOrUpdate(DicomTag.InstanceNumber, "1");
        d.AddOrUpdate(DicomTag.StudyDate, c.Tarih);
        d.AddOrUpdate(DicomTag.StudyTime, c.Saat);
        d.AddOrUpdate(DicomTag.StudyDescription, c.Aciklama);
        d.AddOrUpdate(DicomTag.ContentDate, simdi.ToString("yyyyMMdd", CultureInfo.InvariantCulture));
        d.AddOrUpdate(DicomTag.ContentTime, simdi.ToString("HHmmss", CultureInfo.InvariantCulture));
        d.AddOrUpdate(DicomTag.AccessionNumber, v.AccessionNo);
        d.AddOrUpdate(DicomTag.ReferringPhysicianName, $"{v.IsteyenHekim.Soyad}^{v.IsteyenHekim.Ad}".Trim('^'));
        d.AddOrUpdate(DicomTag.PatientName, $"{v.HastaSoyad}^{v.HastaAd}".Trim('^'));
        d.AddOrUpdate(DicomTag.PatientID, v.HastaTckn.Length == 11 ? v.HastaTckn : v.HastaDosyaNo);
        if (v.HastaTckn.Length == 11 && v.HastaDosyaNo.Length > 0) d.AddOrUpdate(DicomTag.OtherPatientIDsRETIRED, v.HastaDosyaNo);
        d.AddOrUpdate(DicomTag.PatientBirthDate, v.DogumTarihi?.ToString("yyyyMMdd", CultureInfo.InvariantCulture) ?? "");
        d.AddOrUpdate(DicomTag.PatientSex, v.Cinsiyet is "M" or "F" ? v.Cinsiyet : "O");
        d.AddOrUpdate(DicomTag.InstitutionName, KurumAlani(k));
        d.AddOrUpdate(DicomTag.Manufacturer, "Gentegre AI");
        d.AddOrUpdate(DicomTag.DeviceSerialNumber, k.CihazSeriNo);
        // SR belge modülü: Key Object Selection - "Manifest" (DCM 113030), tamamlandı / doğrulanmamış.
        d.AddOrUpdate(DicomTag.ValueType, "CONTAINER");
        d.AddOrUpdate(new DicomSequence(DicomTag.ConceptNameCodeSequence, Kod("113030", "DCM", "Manifest")));
        d.AddOrUpdate(DicomTag.ContinuityOfContent, "SEPARATE");
        d.AddOrUpdate(new DicomSequence(DicomTag.ReferencedPerformedProcedureStepSequence)); // MakeKOS: boş (Tip 2)
        d.AddOrUpdate(new DicomSequence(DicomTag.ContentTemplateSequence, new DicomDataset
        {
            { DicomTag.MappingResource, "DCMR" }, { DicomTag.TemplateIdentifier, "2010" },
        }.NotValidated()));

        var icerik = new List<DicomDataset>();
        var seriler = new List<DicomDataset>();
        foreach (var s in c.Seriler)
        {
            var sopListesi = new List<DicomDataset>();
            foreach (var g in s.Goruntuler)
            {
                var r = new DicomDataset().NotValidated();
                r.AddOrUpdate(DicomTag.ReferencedSOPClassUID, g.SopClassUid);
                r.AddOrUpdate(DicomTag.ReferencedSOPInstanceUID, g.SopInstanceUid);
                // MakeKOS v2.0 refSOP: InstanceNumber (yoksa boş) + NumberOfFrames (tek karede 0) her zaman yazılır.
                r.AddOrUpdate(DicomTag.InstanceNumber, g.No > 0 ? g.No.ToString(CultureInfo.InvariantCulture) : "");
                r.AddOrUpdate(DicomTag.NumberOfFrames, Math.Max(g.Kare, 0).ToString(CultureInfo.InvariantCulture));
                sopListesi.Add(r);
                // İçerik ağacı: her referans bir IMAGE öğesi (KOS'un SR gövdesi).
                var ic = new DicomDataset().NotValidated();
                ic.AddOrUpdate(DicomTag.RelationshipType, "CONTAINS");
                ic.AddOrUpdate(DicomTag.ValueType, "IMAGE");
                ic.AddOrUpdate(new DicomSequence(DicomTag.ReferencedSOPSequence, new DicomDataset
                {
                    { DicomTag.ReferencedSOPClassUID, g.SopClassUid }, { DicomTag.ReferencedSOPInstanceUID, g.SopInstanceUid },
                }.NotValidated()));
                icerik.Add(ic);
            }
            var sd = new DicomDataset().NotValidated();
            sd.AddOrUpdate(DicomTag.SeriesInstanceUID, s.SeriesUid);
            sd.AddOrUpdate(DicomTag.SeriesDescription, s.Aciklama);
            sd.AddOrUpdate(DicomTag.Modality, s.Modalite);
            sd.AddOrUpdate(DicomTag.RetrieveAETitle, k.RetrieveAe);
            sd.AddOrUpdate(DicomTag.RetrieveLocationUID, RetrieveLocationUid(k.Skrs));
            sd.AddOrUpdate(new DicomSequence(DicomTag.ReferencedSOPSequence, sopListesi.ToArray()));
            if (s.Ikon is { } ikon) sd.AddOrUpdate(new DicomSequence(DicomTag.IconImageSequence, IkonKumesi(ikon)));
            seriler.Add(sd);
        }
        var calisma = new DicomDataset().NotValidated();
        calisma.AddOrUpdate(DicomTag.StudyInstanceUID, c.StudyUid);
        calisma.AddOrUpdate(new DicomSequence(DicomTag.ReferencedSeriesSequence, seriler.ToArray()));
        d.AddOrUpdate(new DicomSequence(DicomTag.CurrentRequestedProcedureEvidenceSequence, calisma));
        d.AddOrUpdate(new DicomSequence(DicomTag.ContentSequence, icerik.ToArray()));
        return new DicomFile(d);
    }

    /// <summary>Kılavuz Tablo 2 Icon Image: JPEG baytları OB, YBR_FULL_422, 8 bit, en/boy ≤ 128, Pixel Aspect Ratio 1.</summary>
    private static DicomDataset IkonKumesi(KucukResim k)
    {
        var i = new DicomDataset().NotValidated();
        i.AddOrUpdate(DicomTag.SamplesPerPixel, (ushort)3);
        i.AddOrUpdate(DicomTag.PhotometricInterpretation, "YBR_FULL_422");
        i.AddOrUpdate(DicomTag.PlanarConfiguration, (ushort)0);
        i.AddOrUpdate(DicomTag.Rows, (ushort)k.Satir);
        i.AddOrUpdate(DicomTag.Columns, (ushort)k.Sutun);
        i.AddOrUpdate(DicomTag.BitsAllocated, (ushort)8);
        i.AddOrUpdate(DicomTag.BitsStored, (ushort)8);
        i.AddOrUpdate(DicomTag.HighBit, (ushort)7);
        i.AddOrUpdate(DicomTag.PixelRepresentation, (ushort)0);
        i.AddOrUpdate(DicomTag.PixelAspectRatio, "1", "1");
        i.AddOrUpdate(DicomVR.OB, DicomTag.PixelData, k.Jpeg);
        return i;
    }

    private static DicomDataset Kod(string deger, string sema, string anlam) => new DicomDataset
    {
        { DicomTag.CodeValue, deger }, { DicomTag.CodingSchemeDesignator, sema }, { DicomTag.CodeMeaning, anlam },
    }.NotValidated();

    private static string Temiz(string s) => (s ?? "").Replace("^", " ").Replace("\\", " ").Trim();

    /// <summary>KOS'u DICOM Part 10 baytlarına yazar (MTOM ekinin içeriği).</summary>
    public static byte[] Baytlar(DicomFile f)
    {
        using var m = new MemoryStream();
        f.Save(m);
        return m.ToArray();
    }

    /// <summary>
    /// Gönderim öncesi KOS denetimi (kılavuz 1.15 Tablo 2 + Şekil 21 doğrulama mesajı: "Hasta Adı, PatientID /
    /// OtherPatientIDs, Cinsiyeti, Çekim Tarihi boş olamaz").
    /// </summary>
    public static List<string> Denetle(OrmVerisi v, KosCalisma? c, KosKurum k)
    {
        var e = new List<string>();
        if (c is null) { e.Add("Çalışma PACS'ta bulunamadı (study_uid ile C-FIND)."); return e; }
        if (c.Seriler.Count == 0 || c.Seriler.All(s => s.Goruntuler.Count == 0)) e.Add("Çalışmada görüntü yok.");
        if (string.IsNullOrWhiteSpace(c.Tarih)) e.Add("Çekim tarihi (StudyDate) yok.");
        if (v.AccessionNo.Length == 0) e.Add("Accession numarası yok.");
        if (v.HastaSoyad.Length == 0 && v.HastaAd.Length == 0) e.Add("Hasta adı yok.");
        if (v.HastaTckn.Length != 11 && v.HastaDosyaNo.Length == 0) e.Add("Hasta TCKN / dosya no yok (PatientID).");
        if (v.HastaTckn.Length != 11) e.Add("Hasta TCKN yok - kurum alanı doğrulanamazsa Bakanlık TCKN ister (InstitutionName / PatientID).");
        if (v.Cinsiyet is not ("M" or "F")) e.Add("Hasta cinsiyeti yok.");
        if (k.Skrs.Length == 0) e.Add("Kurum SKRS kodu yok (InstitutionName / RetrieveLocationUID).");
        if (k.FirmaKodu.Length == 0) e.Add("Firma kodu yok (InstitutionName FK).");
        if (k.CihazSeriNo.Length == 0) e.Add("Cihazın Teletıp seri numarası yok (DeviceSerialNumber) - radyoloji cihaz kartına STM seri no girilmeli.");
        if (k.RetrieveAe.Length == 0) e.Add("PACS AE başlığı yok (Retrieve AE Title).");
        return e;
    }
}

/// <summary>
/// KÜÇÜK RESİM: DICOM görüntüden ≤128×128 YBR_FULL_422 temel JPEG (KOS Icon Image). Pikseller
/// <see cref="DicomGoruntuCizici"/>'den (dışa açık WADO ile aynı çizici); okunamayan görüntüde null (seri ikonsuz gider).
/// </summary>
public static class KucukResimUretici
{
    public static KucukResim? Uret(DicomDataset d, int enFazla = 128)
    {
        try
        {
            var c = DicomGoruntuCizici.Ciz(d, new CizimIstegi(Satir: enFazla, Sutun: enFazla, Kalite: 75, CiftGenislik: true));
            return new KucukResim(c.Jpeg, c.Satir, c.Sutun);
        }
        catch (Exception) { return null; }
    }
}

/// <summary>
/// Asgari temel (baseline, sıralı, Huffman) JPEG kodlayıcı - gri ölçek girdiyi 3 bileşenli YCbCr 4:2:2 olarak yazar
/// (Cb = Cr = 128; Y H2V1, Cb/Cr H1V1). Standart (JPEG Ek K) niceleme ve Huffman tabloları, kalite ~75. Yalnız küçük
/// resim içindir; ek paket (lisanslı görüntü kütüphanesi) gerektirmesin diye burada.
/// </summary>
public static class JpegKodlayici
{
    private static readonly int[] Zigzag =
    [
        0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33, 40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28,
        35, 42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59, 52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63,
    ];
    private static readonly int[] LumQ =
    [
        16, 11, 10, 16, 24, 40, 51, 61, 12, 12, 14, 19, 26, 58, 60, 55, 14, 13, 16, 24, 40, 57, 69, 56, 14, 17, 22, 29, 51, 87, 80, 62,
        18, 22, 37, 56, 68, 109, 103, 77, 24, 35, 55, 64, 81, 104, 113, 92, 49, 64, 78, 87, 103, 121, 120, 101, 72, 92, 95, 98, 112, 100, 103, 99,
    ];
    private static readonly int[] KroQ =
    [
        17, 18, 24, 47, 99, 99, 99, 99, 18, 21, 26, 66, 99, 99, 99, 99, 24, 26, 56, 99, 99, 99, 99, 99, 47, 66, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
    ];
    private static readonly byte[] DcLumBits = [0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0];
    private static readonly byte[] DcLumVal = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    private static readonly byte[] DcKroBits = [0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0];
    private static readonly byte[] DcKroVal = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    private static readonly byte[] AcLumBits = [0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 0x7d];
    private static readonly byte[] AcLumVal =
    [
        0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xa1, 0x08,
        0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1, 0xf0, 0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0a, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x25, 0x26, 0x27, 0x28,
        0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
        0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
        0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6,
        0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe1, 0xe2,
        0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa,
    ];
    private static readonly byte[] AcKroBits = [0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 0x77];
    private static readonly byte[] AcKroVal =
    [
        0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05, 0x21, 0x31, 0x06, 0x12, 0x41, 0x51, 0x07, 0x61, 0x71, 0x13, 0x22, 0x32, 0x81, 0x08, 0x14, 0x42, 0x91,
        0xa1, 0xb1, 0xc1, 0x09, 0x23, 0x33, 0x52, 0xf0, 0x15, 0x62, 0x72, 0xd1, 0x0a, 0x16, 0x24, 0x34, 0xe1, 0x25, 0xf1, 0x17, 0x18, 0x19, 0x1a, 0x26,
        0x27, 0x28, 0x29, 0x2a, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
        0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
        0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4,
        0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda,
        0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa,
    ];

    private sealed class Yazar(MemoryStream m)
    {
        private int _tampon, _bit;
        public void Bit(int kod, int uzunluk)
        {
            for (var i = uzunluk - 1; i >= 0; i--)
            {
                _tampon = (_tampon << 1) | ((kod >> i) & 1);
                if (++_bit == 8) { m.WriteByte((byte)_tampon); if (_tampon == 0xFF) m.WriteByte(0); _tampon = 0; _bit = 0; }
            }
        }
        public void Bitir() { if (_bit > 0) Bit((1 << (8 - _bit)) - 1, 8 - _bit); }
    }

    private static (int[] kod, int[] uzun) Tablo(byte[] bits, byte[] vals)
    {
        var kod = new int[256]; var uzun = new int[256]; int k = 0, j = 0;
        for (var l = 1; l <= 16; l++) { for (var i = 0; i < bits[l - 1]; i++) { kod[vals[j]] = k; uzun[vals[j]] = l; j++; k++; } k <<= 1; }
        return (kod, uzun);
    }

    private static int[] Nicele(int[] taban, int kalite)
    {
        var s = kalite < 50 ? 5000 / kalite : 200 - kalite * 2;
        return taban.Select(q => Math.Clamp((q * s + 50) / 100, 1, 255)).ToArray();
    }

    /// <summary>Gri ölçek → YCbCr 4:2:2 (Cb = Cr = 128).</summary>
    public static byte[] Gri422(byte[] gri, int w, int h, int kalite = 75) => Kodla422(gri, null, null, w, h, kalite);

    /// <summary>RGB (piksel başına 3 bayt, sıralı) → YCbCr 4:2:2 (JFIF dönüşümü).</summary>
    public static byte[] Rgb422(byte[] rgb, int w, int h, int kalite = 75)
    {
        var yy = new byte[w * h]; var cb = new byte[w * h]; var cr = new byte[w * h];
        for (var i = 0; i < w * h; i++)
        {
            double r = rgb[i * 3], g = rgb[i * 3 + 1], b = rgb[i * 3 + 2];
            yy[i] = Bayt(0.299 * r + 0.587 * g + 0.114 * b);
            cb[i] = Bayt(128 - 0.168736 * r - 0.331264 * g + 0.5 * b);
            cr[i] = Bayt(128 + 0.5 * r - 0.418688 * g - 0.081312 * b);
        }
        return Kodla422(yy, cb, cr, w, h, kalite);
    }

    private static byte Bayt(double x) => (byte)Math.Clamp((int)Math.Round(x), 0, 255);

    private static byte[] Kodla422(byte[] gri, byte[]? cbd, byte[]? crd, int w, int h, int kalite)
    {
        kalite = Math.Clamp(kalite, 1, 100);
        var lq = Nicele(LumQ, kalite); var kq = Nicele(KroQ, kalite);
        var (dcLk, dcLu) = Tablo(DcLumBits, DcLumVal); var (acLk, acLu) = Tablo(AcLumBits, AcLumVal);
        var (dcKk, dcKu) = Tablo(DcKroBits, DcKroVal); var (acKk, acKu) = Tablo(AcKroBits, AcKroVal);
        using var m = new MemoryStream();
        void B(params int[] x) { foreach (var b in x) m.WriteByte((byte)b); }
        void Seg(int isaret, byte[] govde) { B(0xFF, isaret, (govde.Length + 2) >> 8, (govde.Length + 2) & 0xFF); m.Write(govde); }
        B(0xFF, 0xD8);
        Seg(0xE0, [(byte)'J', (byte)'F', (byte)'I', (byte)'F', 0, 1, 1, 0, 0, 1, 0, 1, 0, 0]);
        var dqt = new List<byte> { 0 }; dqt.AddRange(Zigzag.Select(z => (byte)lq[z])); dqt.Add(1); dqt.AddRange(Zigzag.Select(z => (byte)kq[z]));
        Seg(0xDB, [.. dqt]);
        Seg(0xC0, [8, (byte)(h >> 8), (byte)h, (byte)(w >> 8), (byte)w, 3, 1, 0x21, 0, 2, 0x11, 1, 3, 0x11, 1]);
        var dht = new List<byte>();
        void Ht(int sinif, byte[] bits, byte[] vals) { dht.Add((byte)sinif); dht.AddRange(bits); dht.AddRange(vals); }
        Ht(0x00, DcLumBits, DcLumVal); Ht(0x10, AcLumBits, AcLumVal); Ht(0x01, DcKroBits, DcKroVal); Ht(0x11, AcKroBits, AcKroVal);
        Seg(0xC4, [.. dht]);
        Seg(0xDA, [3, 1, 0x00, 2, 0x11, 3, 0x11, 0, 63, 0]);

        var y = new Yazar(m);
        int dcY = 0, dcCb = 0, dcCr = 0;
        var blok = new double[64];
        for (var my = 0; my < h; my += 8)
            for (var mx = 0; mx < w; mx += 16)
            {
                for (var b = 0; b < 2; b++)
                {
                    for (var i = 0; i < 64; i++)
                    {
                        int px = Math.Min(mx + b * 8 + (i & 7), w - 1), py = Math.Min(my + (i >> 3), h - 1);
                        blok[i] = gri[py * w + px] - 128.0;
                    }
                    dcY = Kodla(y, blok, lq, dcY, dcLk, dcLu, acLk, acLu);
                }
                if (cbd is null || crd is null)
                {
                    Array.Clear(blok);                     // Cb = Cr = 128 → seviye kaydırmadan sonra 0
                    dcCb = Kodla(y, blok, kq, dcCb, dcKk, dcKu, acKk, acKu);
                    dcCr = Kodla(y, blok, kq, dcCr, dcKk, dcKu, acKk, acKu);
                }
                else
                {
                    Krom(cbd, mx, my); dcCb = Kodla(y, blok, kq, dcCb, dcKk, dcKu, acKk, acKu);
                    Krom(crd, mx, my); dcCr = Kodla(y, blok, kq, dcCr, dcKk, dcKu, acKk, acKu);
                }
            }
        y.Bitir();
        B(0xFF, 0xD9);
        return m.ToArray();

        // 4:2:2 - kroma bloğu yatayda iki pikselin ortalaması (16×8 MCU → 8×8).
        void Krom(byte[] k, int mx, int my)
        {
            for (var i = 0; i < 64; i++)
            {
                int x0 = Math.Min(mx + 2 * (i & 7), w - 1), x1 = Math.Min(x0 + 1, w - 1), py = Math.Min(my + (i >> 3), h - 1);
                blok[i] = (k[py * w + x0] + k[py * w + x1]) / 2.0 - 128.0;
            }
        }
    }

    /// <summary>C[u, x] = ½ · c(u) · cos((2x+1)uπ/16), c(0) = 1/√2 (iki boyutta ¼ · c(u) · c(v)).</summary>
    private static readonly double[] DctC = Enumerable.Range(0, 64)
        .Select(i => 0.5 * (i / 8 == 0 ? Math.Sqrt(0.5) : 1) * Math.Cos((2 * (i % 8) + 1) * (i / 8) * Math.PI / 16)).ToArray();

    private static int Kodla(Yazar y, double[] blok, int[] q, int oncekiDc, int[] dcK, int[] dcU, int[] acK, int[] acU)
    {
        // Ayrık (satır sonra sütun) 8×8 DCT, katsayılar tablodan - tam boy WADO JPEG'inde hız için.
        var ara = new double[64]; var f = new double[64];
        for (var yy = 0; yy < 8; yy++)
            for (var u = 0; u < 8; u++)
            {
                double t = 0;
                for (var xx = 0; xx < 8; xx++) t += blok[yy * 8 + xx] * DctC[u * 8 + xx];
                ara[yy * 8 + u] = t;
            }
        for (var v = 0; v < 8; v++)
            for (var u = 0; u < 8; u++)
            {
                double t = 0;
                for (var yy = 0; yy < 8; yy++) t += ara[yy * 8 + u] * DctC[v * 8 + yy];
                f[v * 8 + u] = t;
            }
        var z = new int[64];
        for (var i = 0; i < 64; i++) z[i] = (int)Math.Round(f[Zigzag[i]] / q[Zigzag[i]]);
        var fark = z[0] - oncekiDc;
        var (dk, dl) = Buyukluk(fark);
        y.Bit(dcK[dl], dcU[dl]); if (dl > 0) y.Bit(dk, dl);
        var sifir = 0;
        for (var i = 1; i < 64; i++)
        {
            if (z[i] == 0) { sifir++; continue; }
            while (sifir > 15) { y.Bit(acK[0xF0], acU[0xF0]); sifir -= 16; }
            var (ak, al) = Buyukluk(z[i]);
            var sembol = (sifir << 4) | al;
            y.Bit(acK[sembol], acU[sembol]); y.Bit(ak, al);
            sifir = 0;
        }
        if (sifir > 0) y.Bit(acK[0x00], acU[0x00]);
        return z[0];
    }

    private static (int kod, int uzun) Buyukluk(int x)
    {
        if (x == 0) return (0, 0);
        var a = Math.Abs(x); var l = 0;
        while (a > 0) { l++; a >>= 1; }
        return (x > 0 ? x : x + (1 << l) - 1, l);
    }
}

/// <summary>
/// RAD-68 / ITI-41 ZARFI: SOAP 1.2 + MTOM/XOP (multipart/related). ebRIM: SubmissionSet (RegistryPackage) + DocumentEntry
/// (ExtrinsicObject, mimeType application/dicom, formatCode = KOS SOP Class) + HasMember. Kodlar Bakanlık SendKOS v15
/// şablonundan birebir (kılavuzda metin olarak yok).
/// </summary>
public static class XdsZarfi
{
    public const string Eylem = "urn:ihe:iti:2007:ProvideAndRegisterDocumentSet-b";
    /// <summary>XDSSubmissionSet.sourceId - Bakanlık şablonundaki sabit değer (SendKOS submit_image_document.xml).</summary>
    public const string KaynakKimligi = "1.3.6.1.4.1.21367.2010.1.2.108";
    /// <summary>Hasta kimliği atama otoritesi - kılavuz 1.15 Şekil 16 + SendKOS: "TCKN^^^&amp;1.3.6.1.4.1.21367.13.20.3000&amp;ISO".</summary>
    public const string VarsayilanHastaOid = "1.3.6.1.4.1.21367.13.20.3000";

    public sealed record Zarf(string IcerikTuru, byte[] Govde, string SoapXml);

    public static Zarf Kur(byte[] kos, string kosSopUid, string studyUid, OrmVerisi v, KosKurum k, string hedefUrl, DateTime simdiUtc,
                           string hastaOid, string modalite)
    {
        XNamespace soap = "http://www.w3.org/2003/05/soap-envelope", wsa = "http://www.w3.org/2005/08/addressing",
                   xds = "urn:ihe:iti:xds-b:2007", lcm = "urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0",
                   rim = "urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0", xop = "http://www.w3.org/2004/08/xop/include";
        var zaman = simdiUtc.ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture);
        var hasta = $"{(v.HastaTckn.Length == 11 ? v.HastaTckn : v.HastaDosyaNo)}^^^&{hastaOid}&ISO";
        XElement Slot(string ad, params string[] degerler) =>
            new(rim + "Slot", new XAttribute("name", ad), new XElement(rim + "ValueList", degerler.Select(x => new XElement(rim + "Value", x))));
        XElement Ad(string metin) => new(rim + "Name", new XElement(rim + "LocalizedString", new XAttribute("value", metin)));
        XElement Sinif(string sema, string nesne, string kod, string kodSemasi, string anlam) =>
            new(rim + "Classification", new XAttribute("classificationScheme", sema), new XAttribute("classifiedObject", nesne),
                new XAttribute("nodeRepresentation", kod), new XAttribute("id", "urn:uuid:" + Guid.NewGuid()),
                new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"),
                Slot("codingScheme", kodSemasi), Ad(anlam));
        XElement Dis(string sema, string nesne, string deger, string ad) =>
            new(rim + "ExternalIdentifier", new XAttribute("identificationScheme", sema), new XAttribute("registryObject", nesne),
                new XAttribute("value", deger), new XAttribute("id", "urn:uuid:" + Guid.NewGuid()),
                new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:ExternalIdentifier"), Ad(ad));

        // KODLAR BAKANLIK ŞABLONUNDAN (11.11.2026 karşılaştırma: teletip.saglik.gov.tr SendKOS v15 kaynağı,
        //   submit_image_document.xml - Bakanlık'ın kendi test deposuna gönderdiği gövde). classCode / healthcareFacility /
        //   practiceSetting / typeCode / contentTypeCode IHE Connect-a-thon değerleri; yazar (author) sınıflandırması;
        //   eventCodeList YOK; sourceId sabit. Belge ve küme kimlikleri urn:uuid (şablon gibi).
        var belgeId = "urn:uuid:" + Guid.NewGuid();
        var kumeId = "urn:uuid:" + Guid.NewGuid();
        XElement Yazar(string sema, string nesne) =>
            new(rim + "Classification", new XAttribute("classificationScheme", sema), new XAttribute("classifiedObject", nesne),
                new XAttribute("nodeRepresentation", ""), new XAttribute("id", "urn:uuid:" + Guid.NewGuid()),
                new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"),
                Slot("authorPerson", "GENTEGRE+AUTOPUBLISH"), Slot("authorRole", "SC"));
        var belge = new XElement(rim + "ExtrinsicObject", new XAttribute("id", belgeId), new XAttribute("mimeType", "application/dicom"),
            new XAttribute("objectType", "urn:uuid:7edca82f-054d-47f2-a032-9b2a5b5186c1"),
            Slot("languageCode", "en-US"),
            Slot("serviceStartTime", (v.PlanlananZaman ?? simdiUtc).ToString("yyyyMMddHHmmss", CultureInfo.InvariantCulture)),
            Slot("creationTime", zaman), Slot("sourcePatientId", hasta),
            Slot("sourcePatientInfo", $"PID-3|{hasta}", $"PID-5|{v.HastaSoyad}^{v.HastaAd}",
                 $"PID-7|{(v.DogumTarihi is DateTime dt ? dt.ToString("yyyyMMdd", CultureInfo.InvariantCulture) + "000000" : "")}", $"PID-8|{v.Cinsiyet}"),
            Ad("Manifest"),
            Yazar("urn:uuid:93606bcf-9494-43ec-9b4e-a7748d1a838d", belgeId),
            Sinif("urn:uuid:41a5887f-8865-4c09-adf7-e362475b143a", belgeId, "DEMO-Eval", "1.3.6.1.4.1.21367.100.1", "Evaluation"),
            Sinif("urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f", belgeId, "N", "2.16.840.1.113883.5.25", "Normal"),
            Sinif("urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d", belgeId, KosUretici.KosSopClass, "1.2.840.10008.2.6.1", "Key Object Selection Document"),
            Sinif("urn:uuid:f33fb8ac-18af-42cc-ae0e-ed0b0bdb91e1", belgeId, "Hospital Setting", "Connect-a-thon healthcareFacilityTypeCodes", "Hospital Setting"),
            Sinif("urn:uuid:cccf5598-8b07-4b77-a05e-ae952c785ead", belgeId, "General Medicine", "Connect-a-thon practiceSettingCodes", "General Medicine"),
            Sinif("urn:uuid:f0306f51-975f-434e-a61c-c59651d33983", belgeId, "34117-2", "2.16.840.1.113883.6.1", "History And Physical Note"),
            Dis("urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab", belgeId, kosSopUid, "XDSDocumentEntry.uniqueId"),
            Dis("urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427", belgeId, hasta, "XDSDocumentEntry.patientId"));
        _ = modalite; // şablonda eventCodeList yok - imza çağıranlar için korunuyor

        var kume = new XElement(rim + "RegistryPackage", new XAttribute("id", kumeId),
            new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:RegistryPackage"),
            Slot("submissionTime", zaman), Ad("Software"),
            Yazar("urn:uuid:a7058bb9-b4e4-4307-ba5b-e3f0ab85e12d", kumeId),
            Sinif("urn:uuid:aa543740-bdda-424e-8c96-df4873be8500", kumeId, "34117-2", "2.16.840.1.113883.6.1", "History and Physical"),
            Dis("urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8", kumeId, "2.25." + new System.Numerics.BigInteger(Guid.NewGuid().ToByteArray(), true), "XDSSubmissionSet.uniqueId"),
            Dis("urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446", kumeId, hasta, "XDSSubmissionSet.patientId"),
            Dis("urn:uuid:554ac39e-e3fe-47fe-b233-965d2a147832", kumeId, KaynakKimligi, "XDSSubmissionSet.sourceId"));
        var siniflama = new XElement(rim + "Classification", new XAttribute("id", "urn:uuid:" + Guid.NewGuid()),
            new XAttribute("classifiedObject", kumeId), new XAttribute("classificationNode", "urn:uuid:a54d6aa5-d40d-43f9-88c5-b4633d873bdd"),
            new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Classification"));
        var iliski = new XElement(rim + "Association", new XAttribute("id", "urn:uuid:" + Guid.NewGuid()),
            new XAttribute("associationType", "urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember"),
            new XAttribute("sourceObject", kumeId), new XAttribute("targetObject", belgeId),
            new XAttribute("objectType", "urn:oasis:names:tc:ebxml-regrep:ObjectType:RegistryObject:Association"),
            Slot("SubmissionSetStatus", "Original"));

        var zarf = new XDocument(new XElement(soap + "Envelope",
            new XAttribute(XNamespace.Xmlns + "soap", soap), new XAttribute(XNamespace.Xmlns + "wsa", wsa),
            new XElement(soap + "Header",
                new XElement(wsa + "Action", new XAttribute(soap + "mustUnderstand", "1"), Eylem),
                new XElement(wsa + "MessageID", "urn:uuid:" + Guid.NewGuid()),
                new XElement(wsa + "ReplyTo", new XElement(wsa + "Address", "http://www.w3.org/2005/08/addressing/anonymous")),
                new XElement(wsa + "To", new XAttribute(soap + "mustUnderstand", "1"), hedefUrl)),
            new XElement(soap + "Body",
                new XElement(xds + "ProvideAndRegisterDocumentSetRequest", new XAttribute(XNamespace.Xmlns + "xds", xds),
                    new XElement(lcm + "SubmitObjectsRequest", new XAttribute(XNamespace.Xmlns + "lcm", lcm), new XAttribute(XNamespace.Xmlns + "rim", rim),
                        new XElement(rim + "RegistryObjectList", belge, kume, siniflama, iliski)),
                    new XElement(xds + "Document", new XAttribute("id", belgeId),
                        new XElement(xop + "Include", new XAttribute(XNamespace.Xmlns + "xop", xop), new XAttribute("href", "cid:kos@gentegre")))))));
        var soapXml = zarf.ToString(SaveOptions.DisableFormatting);

        var sinir = "MIMEBoundary_" + Guid.NewGuid().ToString("N");
        var icerikTuru = $"multipart/related; boundary=\"{sinir}\"; type=\"application/xop+xml\"; start=\"<root@gentegre>\"; " +
                         $"start-info=\"application/soap+xml\"; action=\"{Eylem}\"";
        using var m = new MemoryStream();
        void Yaz(string s) { var b = Encoding.UTF8.GetBytes(s); m.Write(b); }
        Yaz($"--{sinir}\r\nContent-Type: application/xop+xml; charset=UTF-8; type=\"application/soap+xml\"; action=\"{Eylem}\"\r\n" +
            "Content-Transfer-Encoding: binary\r\nContent-ID: <root@gentegre>\r\n\r\n");
        Yaz(soapXml);
        Yaz($"\r\n--{sinir}\r\nContent-Type: application/dicom\r\nContent-Transfer-Encoding: binary\r\nContent-ID: <kos@gentegre>\r\n\r\n");
        m.Write(kos);
        Yaz($"\r\n--{sinir}--\r\n");
        return new Zarf(icerikTuru, m.ToArray(), soapXml);
    }
}

/// <summary>RAD-68 yanıtı (kılavuz 1.15 Tablo 3).</summary>
public sealed record XdsSonuc(string Durum, bool Eslesti, string HataKodu, string Aciklama)
{
    /// <summary>Success → kayıt ve istem eşleşmesi tamam.</summary>
    public bool Basarili => Durum == "Success";
}

public static class XdsYaniti
{
    /// <summary>
    /// Yanıt gövdesinden (MTOM ya da düz SOAP) RegistryResponse'u çözer. Success + MatchStatus result:true → eşleşti;
    /// PartialSuccess → KOS kaydedildi, istem eşleşmedi; Failure → doğrulama / eşleşme / genel hata (codeContext özetlenir).
    /// </summary>
    public static XdsSonuc Coz(string govde)
    {
        // Önce kapanış etiketli tam eleman (içinde kendiliğinden kapanan RegistryError olabilir); yoksa boş kök (<rs:… />).
        var m = Regex.Match(govde ?? "", @"<(\w+:)?RegistryResponse\b.*?</(\w+:)?RegistryResponse>", RegexOptions.Singleline);
        if (!m.Success) m = Regex.Match(govde ?? "", @"<(\w+:)?RegistryResponse\b[^>]*/>", RegexOptions.Singleline);
        if (!m.Success) return new("", false, "", "Yanıtta RegistryResponse yok.");
        XElement x;
        try { x = XElement.Parse(m.Value.Contains("xmlns", StringComparison.Ordinal) ? m.Value
                                 : m.Value.Replace("<rs:RegistryResponse", "<rs:RegistryResponse xmlns:rs=\"urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0\"")); }
        catch (System.Xml.XmlException h) { return new("", false, "", "RegistryResponse okunamadı: " + h.Message); }
        var durum = (x.Attribute("status")?.Value ?? "").Split(':').Last();
        var hatalar = x.Descendants().Where(e => e.Name.LocalName == "RegistryError").ToList();
        var eslesti = false; var kod = ""; var aciklama = new List<string>();
        foreach (var h in hatalar)
        {
            kod = h.Attribute("errorCode")?.Value ?? kod;
            var baglam = h.Attribute("codeContext")?.Value ?? "";
            if (kod == "MatchStatus" && baglam.TrimStart().StartsWith('{'))
            {
                try
                {
                    using var j = JsonDocument.Parse(baglam);
                    var r = j.RootElement;
                    var sonuc = r.TryGetProperty("result", out var rs) && rs.ValueKind == JsonValueKind.True;
                    var kurum = r.TryGetProperty("institutionId", out var ki) && ki.ValueKind == JsonValueKind.Number ? ki.GetInt64() : -1;
                    eslesti = sonuc && kurum > 0;
                    var hata = r.TryGetProperty("error", out var er) ? er.GetString() ?? "" : "";
                    if (!eslesti) aciklama.Add(hata.Length > 0 ? $"Eşleşme: {hata}" : "KOS kaydedildi, istemle eşleşmedi (institutionId -1).");
                    continue;
                }
                catch (JsonException) { }
            }
            aciklama.Add(baglam.Length > 400 ? baglam[..400] + "…" : baglam);
        }
        return new(durum, eslesti, kod, string.Join(" · ", aciklama.Where(a => a.Length > 0)));
    }
}
