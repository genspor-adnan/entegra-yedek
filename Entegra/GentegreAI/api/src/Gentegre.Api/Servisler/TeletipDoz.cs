using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using FellowOakDicom;
using Gentegre.Cekirdek.Cihaz;

namespace Gentegre.Api.Servisler;

// =====================================================================================================================
// TELETIP DOZ (K3) - kullanıcı 11.11.2026: "doz RDSR (K3) adımını yap". db/1314.
//   XDS Kılavuzu 1.15 § 3 (Tablo 5 künye, Tablo 6 C-STORE-RSP) + Teleradyoloji Kılavuzu 3.43 § 4.3:
//   X-Ray Radiation Dose SR (1.2.840.10008.5.1.4.1.1.88.67, TID 10001 projeksiyon / 10011 BT) → C-STORE (TLS)
//   dicom.teletip.saglik.gov.tr:443, Called AE TELETIP_MGA. RDSR'yi cihaz üretir ve PACS'ta durur; Gentegre onu
//   PACS'tan alır, künyesini KOS'la AYNI yapar (Accession, PatientID TCKN, OtherPatientIDs, InstitutionName
//   Ad^^^SKRS..^^^FK.., DeviceSerialNumber STM seri no), BT'de CTDIvol / DLP > 0 denetler ve Mirth K3'e (HTTP) verir;
//   Mirth DICOM Sender MGA'ya gönderir, C-STORE-RSP durum + Error Comment'i Gentegre'ye döner.
//   SR içerik ağacına (Irradiation Event UID dahil) DOKUNULMAZ - kılavuz: tekrar gönderimde Event UID değişmemeli.
// =====================================================================================================================

/// <summary>RDSR'den okunan özet (kart / mesaj metni ve denetim için).</summary>
public sealed record DozOzeti(string Sablon, int OlaySayisi, double? ToplamDlp, double? EnBuyukCtdiVol, double? Kvp, double? Ma,
                              double? Mas, double? RotasyonSn, double? UzunlukMm, double? Pitch, string Tarama, double? ToplamDap,
                              int SifirDozluOlay);

public static class DozUretici
{
    public const string RdsrSopClass = "1.2.840.10008.5.1.4.1.1.88.67";

    // DCM kodları (PS3.16 CID 10011 / TID 10011 / 10013 / 10001).
    private const string CtdiVol = "113830", Dlp = "113838", ToplamDlpKod = "113813", Kvp = "113733", Akim = "113734",
                         Exposure = "113736", Rotasyon = "113834", Uzunluk = "113825", PitchKod = "113828", Tip = "113820",
                         Olay = "113819", ProjOlay = "113706", DapToplam = "113722", Dap = "122130";

    /// <summary>
    /// Künyeyi KOS'la aynı yapar (Tablo 5) - içerik ağacı olduğu gibi kalır. Boy / kilo başlıkta yoksa Gentegre'deki son
    /// ölçümle doldurulur (BT doz verisinde Bakanlık "doldurulmuş olarak yer almalı" diyor).
    /// </summary>
    public static DicomDataset Kunye(DicomDataset kaynak, OrmVerisi v, KosKurum k, string studyUid, double? boyCm, double? kiloKg)
    {
        var d = kaynak.Clone().NotValidated();
        d.AddOrUpdate(DicomTag.SpecificCharacterSet, "ISO_IR 192");
        d.AddOrUpdate(DicomTag.StudyInstanceUID, studyUid);
        d.AddOrUpdate(DicomTag.AccessionNumber, v.AccessionNo);
        d.AddOrUpdate(DicomTag.PatientName, $"{v.HastaSoyad}^{v.HastaAd}".Trim('^'));
        d.AddOrUpdate(DicomTag.PatientID, v.HastaTckn.Length == 11 ? v.HastaTckn : v.HastaDosyaNo);
        if (v.HastaTckn.Length == 11 && v.HastaDosyaNo.Length > 0) d.AddOrUpdate(DicomTag.OtherPatientIDsRETIRED, v.HastaDosyaNo);
        if (v.DogumTarihi is DateTime dt) d.AddOrUpdate(DicomTag.PatientBirthDate, dt.ToString("yyyyMMdd", CultureInfo.InvariantCulture));
        if (v.Cinsiyet is "M" or "F") d.AddOrUpdate(DicomTag.PatientSex, v.Cinsiyet);
        d.AddOrUpdate(DicomTag.InstitutionName, KosUretici.KurumAlani(k));
        d.AddOrUpdate(DicomTag.DeviceSerialNumber, k.CihazSeriNo);
        if (d.GetSingleValueOrDefault(DicomTag.PatientSize, 0.0) <= 0 && boyCm is > 0)
            d.AddOrUpdate(DicomTag.PatientSize, (boyCm.Value / 100.0).ToString("0.00", CultureInfo.InvariantCulture));
        if (d.GetSingleValueOrDefault(DicomTag.PatientWeight, 0.0) <= 0 && kiloKg is > 0)
            d.AddOrUpdate(DicomTag.PatientWeight, kiloKg.Value.ToString("0.#", CultureInfo.InvariantCulture));
        return d;
    }

    /// <summary>RDSR içerik ağacından özet: olay sayısı, toplam DLP, en büyük CTDIvol, kVp / mA / mAs / rotasyon / uzunluk / pitch.</summary>
    public static DozOzeti Ozet(DicomDataset d)
    {
        var sablon = d.TryGetSequence(DicomTag.ContentTemplateSequence, out var ts) && ts.Items.Count > 0
            ? ts.Items[0].GetSingleValueOrDefault(DicomTag.TemplateIdentifier, "") : "";
        int olay = 0, sifir = 0;
        double? toplamDlp = null, ctdi = null, kvp = null, ma = null, mas = null, rot = null, uz = null, pitch = null, dap = null, dapToplam = null;
        var tarama = new List<string>();
        void Gez(DicomDataset ic)
        {
            if (!ic.TryGetSequence(DicomTag.ContentSequence, out var cs)) return;
            foreach (var o in cs.Items)
            {
                var kod = Kod(o);
                if (kod == Olay || kod == ProjOlay)
                {
                    olay++;
                    var c = Sayi(o, CtdiVol); var l = Sayi(o, Dlp); var p = Sayi(o, Dap);
                    if (kod == Olay && ((c ?? 0) <= 0 || (l ?? 0) <= 0)) sifir++;
                    if (c > (ctdi ?? 0)) ctdi = c;
                    if (p is double pd) dap = (dap ?? 0) + pd;
                }
                switch (kod)
                {
                    case ToplamDlpKod: toplamDlp = Deger(o); break;
                    case DapToplam: dapToplam = Deger(o); break;
                    case Kvp: kvp ??= Deger(o); break;
                    case Akim: ma ??= Deger(o); break;
                    case Exposure: mas ??= Deger(o); break;
                    case Rotasyon: rot ??= Deger(o); break;
                    case Uzunluk: uz ??= Deger(o); break;
                    case PitchKod: pitch ??= Deger(o); break;
                    case Tip:
                        if (o.TryGetSequence(DicomTag.ConceptCodeSequence, out var cc) && cc.Items.Count > 0
                            && cc.Items[0].GetSingleValueOrDefault(DicomTag.CodeMeaning, "") is { Length: > 0 } t && !tarama.Contains(t))
                            tarama.Add(t);
                        break;
                }
                Gez(o);
            }
        }
        Gez(d);
        return new DozOzeti(sablon, olay, toplamDlp, ctdi, kvp, ma, mas, rot, uz, pitch, string.Join(", ", tarama), dapToplam ?? dap, sifir);
    }

    private static string Kod(DicomDataset o) =>
        o.TryGetSequence(DicomTag.ConceptNameCodeSequence, out var s) && s.Items.Count > 0 ? s.Items[0].GetSingleValueOrDefault(DicomTag.CodeValue, "") : "";

    private static double? Deger(DicomDataset o) =>
        o.TryGetSequence(DicomTag.MeasuredValueSequence, out var m) && m.Items.Count > 0
        && m.Items[0].TryGetSingleValue<double>(DicomTag.NumericValue, out var x) ? x : null;

    /// <summary>Alt düğümlerde (bir seviye derin dahil) koda ait ilk sayı - CTDIvol / DLP olayın "CT Dose" konteynerinde.</summary>
    private static double? Sayi(DicomDataset o, string kod)
    {
        if (!o.TryGetSequence(DicomTag.ContentSequence, out var cs)) return null;
        foreach (var c in cs.Items)
        {
            if (Kod(c) == kod && Deger(c) is double x) return x;
            if (Sayi(c, kod) is double y) return y;
        }
        return null;
    }

    /// <summary>
    /// Gönderim öncesi denetim (Tablo 6 SR111 / SR112 / SR113-115 + BT'de DLP / CTDIvol boş ya da sıfırsa Bakanlık
    /// kabul etmez). Dönen ikinci liste uyarıdır (gönderimi durdurmaz).
    /// </summary>
    public static (List<string> Hatalar, List<string> Uyarilar) Denetle(DicomDataset d, DozOzeti o)
    {
        var e = new List<string>(); var u = new List<string>();
        if (d.GetSingleValueOrDefault(DicomTag.SOPClassUID, "") != RdsrSopClass) e.Add("Nesne X-Ray Radiation Dose SR değil (SOP Class).");
        if (string.IsNullOrWhiteSpace(d.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, ""))) e.Add("SOPInstanceUID yok.");
        if (string.IsNullOrWhiteSpace(d.GetSingleValueOrDefault(DicomTag.AccessionNumber, ""))) e.Add("AccessionNumber yok.");
        if (string.IsNullOrWhiteSpace(d.GetSingleValueOrDefault(DicomTag.PatientName, ""))) e.Add("Hasta adı yok.");
        if (string.IsNullOrWhiteSpace(d.GetSingleValueOrDefault(DicomTag.PatientID, ""))) e.Add("PatientID yok.");
        if (d.GetSingleValueOrDefault(DicomTag.PatientSex, "") is not ("M" or "F")) e.Add("Hasta cinsiyeti yok.");
        var tarih = d.GetSingleValueOrDefault(DicomTag.StudyDate, "");
        if (tarih.Length == 0) tarih = d.GetSingleValueOrDefault(DicomTag.ContentDate, "");
        if (!Regex.IsMatch(tarih, @"^\d{8}$")) e.Add("Çekim tarihi (StudyDate) yok ya da YYYYMMDD değil.");
        var bt = o.Sablon == "10011" || d.GetSingleValueOrDefault(DicomTag.Modality, "") == "CT" && o.Sablon != "10001";
        if (o.OlaySayisi == 0) e.Add("RDSR'de ışınlama olayı (Irradiation Event) yok.");
        if (bt)
        {
            if ((o.ToplamDlp ?? 0) <= 0 && (o.EnBuyukCtdiVol ?? 0) <= 0) e.Add("BT doz verisinde DLP ve CTDIvol boş ya da sıfır - Bakanlık kabul etmez.");
            else if ((o.ToplamDlp ?? 0) <= 0) e.Add("BT doz verisinde toplam DLP boş ya da sıfır - Bakanlık kabul etmez.");
            else if ((o.EnBuyukCtdiVol ?? 0) <= 0) e.Add("BT doz verisinde CTDIvol boş ya da sıfır - Bakanlık kabul etmez.");
            if (o.SifirDozluOlay > 0) u.Add($"{o.SifirDozluOlay} ışınlamada CTDIvol / DLP sıfır (lokalizer olabilir).");
            if (d.GetSingleValueOrDefault(DicomTag.PatientSize, 0.0) <= 0 || d.GetSingleValueOrDefault(DicomTag.PatientWeight, 0.0) <= 0)
                u.Add("Hastanın boyu / kilosu yok (BT doz verisinde istenir) - muayenede vital ölçüm girilmeli.");
        }
        return (e, u);
    }

    /// <summary>Saklanan mesaj metni (ikili SR yerine okunur özet).</summary>
    public static string MesajMetni(DicomDataset d, DozOzeti o)
    {
        static string S(double? x, string birim) => x is double v ? v.ToString("0.##", CultureInfo.InvariantCulture) + birim : "-";
        var b = new StringBuilder();
        b.AppendLine("C-STORE X-Ray Radiation Dose SR → TELETIP_MGA");
        foreach (var (ad, t) in new[] { ("SOPInstanceUID", DicomTag.SOPInstanceUID), ("StudyInstanceUID", DicomTag.StudyInstanceUID),
                     ("AccessionNumber", DicomTag.AccessionNumber), ("PatientID", DicomTag.PatientID), ("PatientSex", DicomTag.PatientSex),
                     ("PatientSize", DicomTag.PatientSize), ("PatientWeight", DicomTag.PatientWeight), ("InstitutionName", DicomTag.InstitutionName),
                     ("DeviceSerialNumber", DicomTag.DeviceSerialNumber), ("StudyDate", DicomTag.StudyDate), ("Manufacturer", DicomTag.Manufacturer) })
            b.AppendLine($"{ad}: {d.GetSingleValueOrDefault(t, "")}");
        b.AppendLine($"Şablon: TID {(o.Sablon.Length > 0 ? o.Sablon : "?")} · ışınlama: {o.OlaySayisi} · tarama: {(o.Tarama.Length > 0 ? o.Tarama : "-")}");
        b.AppendLine($"DLP toplam: {S(o.ToplamDlp, " mGy·cm")} · CTDIvol en büyük: {S(o.EnBuyukCtdiVol, " mGy")} · DAP toplam: {S(o.ToplamDap, " Gy·m²")}");
        b.Append($"U {S(o.Kvp, " kV")} · I {S(o.Ma, " mA")} · Qel {S(o.Mas, " mAs")} · T {S(o.RotasyonSn, " s")} · L {S(o.UzunlukMm, " mm")} · P {S(o.Pitch, "")}");
        return b.ToString();
    }
}

/// <summary>
/// Mirth K3 yanıtı (TELETIP_DOZ yanıt dönüştürücüsü satır satır yazar): DURUM (SENT / ERROR), KOD (C-STORE-RSP Status
/// onaltılık), YORUM (Error Comment - SR110..SR117 virgüllü ya da metin), MESAJ (Mirth durum mesajı).
/// </summary>
public sealed record DozSonucu(short Durum, string Ack, string Aciklama);

public static class DozYaniti
{
    public static DozSonucu Coz(string govde)
    {
        var alan = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var satir in (govde ?? "").Replace("\r", "").Split('\n'))
        {
            var i = satir.IndexOf('=');
            if (i > 0) alan[satir[..i].Trim()] = satir[(i + 1)..].Trim();
        }
        alan.TryGetValue("DURUM", out var durum); alan.TryGetValue("KOD", out var kod);
        alan.TryGetValue("YORUM", out var yorum); alan.TryGetValue("MESAJ", out var mesaj);
        durum ??= ""; kod = (kod ?? "").Replace("0x", "", StringComparison.OrdinalIgnoreCase).Trim().ToUpperInvariant();
        yorum ??= ""; mesaj ??= "";
        // Mirth mesajından durum kodu ("Error status code received from DICOM server: 0xC000").
        if (kod.Length == 0 && Regex.Match(mesaj, @"0x([0-9A-Fa-f]{4})") is { Success: true } m) kod = m.Groups[1].Value.ToUpperInvariant();
        if (kod.Length > 0 && kod.TrimStart('0').Length == 0) return new DozSonucu(1, "0000", "");
        if (kod.Length > 0)
        {
            var aciklama = string.Join(" · ", new[] { yorum.Length > 0 ? Acikla(yorum) : "", mesaj }.Where(x => x.Length > 0));
            // B000 / B007 / B006 uyarı - kayıt oldu (PS3.4 C-STORE uyarı durumları).
            return kod.StartsWith('B') ? new DozSonucu(1, kod, aciklama) : new DozSonucu(2, kod, aciklama.Length > 0 ? aciklama : $"C-STORE durum 0x{kod}");
        }
        if (durum.Equals("SENT", StringComparison.OrdinalIgnoreCase)) return new DozSonucu(1, "0000", "");
        return new DozSonucu(5, "", mesaj.Length > 0 ? mesaj : govde?.Length > 0 ? govde : "Mirth K3 yanıtı boş.");
    }

    private static readonly Dictionary<string, string> Kodlar = new()
    {
        ["SR110"] = "Hatalı tarih biçimi (YYYYMMdd / YYYYMMddmmss)",
        ["SR111"] = "Hasta adı, PatientID / OtherPatientIDs, cinsiyet, çekim tarihi boş olamaz",
        ["SR112"] = "AccessionNumber, StudyInstanceUID, SOPInstanceUID boş olamaz",
        ["SR113"] = "InstitutionName boş olamaz",
        ["SR114"] = "InstitutionName'de SKRS ve firma kodu olmalı",
        ["SR115"] = "InstitutionName <Kurum Adı>^^^SKRS<kod> biçiminde olmalı",
        ["SR116"] = "Firma kodu hatalı",
        ["SR117"] = "Firma kodu kontrol edilemedi",
    };

    /// <summary>"SR111,SR114" → kodlar + Türkçe açıklama (Tablo 6).</summary>
    public static string Acikla(string yorum) =>
        string.Join(", ", yorum.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(k => Kodlar.TryGetValue(k, out var a) ? $"{k} {a}" : k));
}
