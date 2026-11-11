using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using FellowOakDicom;
using FellowOakDicom.Network;
using FellowOakDicom.Network.Client;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

/// <summary>
/// DICOM SUNUCUSU AYARLARI (kullanıcı 11.11.2026: "localhost/ImageServer'a ClearCanvas kurdum, OHIF'i bağla").
/// ClearCanvas ImageServer: DICOM (C-FIND / C-STORE) 104, WADO-URI web servisi 1000 (<c>/WADO/&lt;AE&gt;</c>).
/// OHIF ayrı konteynerde (yayin/ohif), veri kaynağı "dicomjson": manifest + görüntüleri BU API verir (WADO vekili).
/// </summary>
public sealed class DicomAyarlari
{
    public bool Aktif { get; set; }
    /// <summary>DICOM sunucusu (C-FIND).</summary>
    public string Sunucu { get; set; } = "127.0.0.1";
    public int Port { get; set; } = 104;
    /// <summary>Sunucunun AE başlığı (ClearCanvas ServerPartition.AeTitle).</summary>
    public string SunucuAe { get; set; } = "SERVERAE";
    /// <summary>Bizim AE başlığımız (ClearCanvas "AcceptAnyDevice" kapalıysa Device olarak tanımlanmalı).</summary>
    public string BizimAe { get; set; } = "GENTEGRE";
    /// <summary>WADO-URI tabanı; sorgu: requestType=WADO&amp;studyUID&amp;seriesUID&amp;objectUID&amp;contentType.</summary>
    public string WadoUrl { get; set; } = "http://127.0.0.1:1000/WADO/SERVERAE";
    /// <summary>OHIF kökü (nginx konteyneri); /viewer/dicomjson?url=… ile açılır.</summary>
    public string GoruntuleyiciUrl { get; set; } = "http://localhost:3001";
    /// <summary>Manifest / WADO bağlantı jetonunun ömrü (OHIF oturum başlığı taşımaz; jeton sorguda).</summary>
    public int JetonDakika { get; set; } = 240;
    /// <summary>C-FIND zaman aşımı.</summary>
    public int ZamanAsimiSn { get; set; } = 20;

    // ---------------------------------------------------------------- MWL sunucusu (1301, MwlSunucusu)
    /// <summary>Modality Worklist dinleme portu; 0 = kapalı. Cihazlar bu porta C-FIND (worklist) gönderir.</summary>
    public int MwlPort { get; set; }
    /// <summary>MWL sunucusunun AE başlığı (cihazda "worklist server" olarak girilir); boş = her çağrılan AE kabul.</summary>
    public string MwlAe { get; set; } = "GENTEGRE";
    /// <summary>true: radyoloji cihaz kartında olmayan AE'ler de liste alır (yalnız modalite süzgeci). Varsayılan kapalı.</summary>
    public bool MwlBilinmeyenAe { get; set; }
    /// <summary>"ISO_IR 148" (Latin-5 Türkçe, varsayılan), "ISO_IR 192" (UTF-8) ya da "ASCII" (Türkçe harf indirgenir).</summary>
    public string MwlKarakterSeti { get; set; } = "ISO_IR 148";
}

/// <summary>
/// DICOM KAYNAĞI: C-FIND ile çalışma / seri / görüntü listesi, OHIF "dicomjson" manifesti, WADO vekili ve
/// imzalı bağlantı jetonu. Kimlik: OHIF'in görüntü yükleyicisi JWT başlığı gönderemez; bu yüzden manifest ve
/// WADO uçları anonim ama <c>t=</c> jetonlu - jeton çalışma UID'sine bağlı, süreli, HMAC(imza anahtarı).
/// </summary>
public sealed class DicomKaynagi(IOptions<DicomAyarlari> ayar, IOptions<GuvenlikAyarlari> guvenlik, IHttpClientFactory http) : IWadoPacs
{
    public DicomAyarlari Ayar => ayar.Value;

    // ---------------------------------------------------------------- jeton ----
    public string JetonUret(string studyUid, int? dakika = null)
    {
        var son = DateTimeOffset.UtcNow.AddMinutes(dakika ?? Ayar.JetonDakika).ToUnixTimeSeconds();
        return $"{son}.{Imza(studyUid, son)}";
    }

    public bool JetonGecerli(string studyUid, string? jeton)
    {
        if (string.IsNullOrWhiteSpace(jeton)) return false;
        var nokta = jeton.IndexOf('.');
        if (nokta <= 0) return false;
        if (!long.TryParse(jeton[..nokta], NumberStyles.Integer, CultureInfo.InvariantCulture, out var son)) return false;
        if (DateTimeOffset.UtcNow.ToUnixTimeSeconds() > son) return false;
        var beklenen = Imza(studyUid, son);
        var gelen = jeton[(nokta + 1)..];
        return CryptographicOperations.FixedTimeEquals(Encoding.ASCII.GetBytes(beklenen), Encoding.ASCII.GetBytes(gelen));
    }

    private string Imza(string studyUid, long son)
    {
        var anahtar = Encoding.UTF8.GetBytes(guvenlik.Value.ImzaAnahtari + "|dicom");
        var veri = Encoding.UTF8.GetBytes($"{studyUid}|{son}");
        var h = HMACSHA256.HashData(anahtar, veri);
        return Convert.ToBase64String(h).TrimEnd('=').Replace('+', '-').Replace('/', '_');
    }

    // ---------------------------------------------------------------- C-FIND ----
    private IDicomClient Istemci()
        => DicomClientFactory.Create(Ayar.Sunucu, Ayar.Port, false, Ayar.BizimAe, Ayar.SunucuAe);

    private async Task<List<DicomDataset>> SorgulaAsync(DicomCFindRequest istek, CancellationToken iptal)
    {
        var sonuc = new List<DicomDataset>();
        istek.OnResponseReceived += (_, yanit) =>
        {
            if (yanit.Status == DicomStatus.Pending && yanit.HasDataset) sonuc.Add(yanit.Dataset);
        };
        var istemci = Istemci();
        await istemci.AddRequestAsync(istek);
        using var zaman = CancellationTokenSource.CreateLinkedTokenSource(iptal);
        zaman.CancelAfter(TimeSpan.FromSeconds(Math.Max(5, Ayar.ZamanAsimiSn)));
        await istemci.SendAsync(zaman.Token);
        return sonuc;
    }

    /// <summary>Accession numarasından çalışma UID'si (ilk eşleşen).</summary>
    public async Task<string?> AccessionIleStudyAsync(string accession, CancellationToken iptal)
    {
        var istek = DicomCFindRequest.CreateStudyQuery(accession: accession);
        var liste = await SorgulaAsync(istek, iptal);
        return liste.Select(d => d.GetSingleValueOrDefault(DicomTag.StudyInstanceUID, ""))
                    .FirstOrDefault(u => !string.IsNullOrWhiteSpace(u));
    }

    public sealed record PacsCalisma(string StudyUid, string Tarih, string Saat, string Modaliteler, string Aciklama,
                                     string Accession, int Adet, string HastaAd, string HastaNo);

    /// <summary>
    /// HASTANIN PACS ÇALIŞMALARI (kullanıcı 11.11.2026: "GENTEGRE DEMO hasta görüntüleri var, programdan nasıl görürüm"):
    /// PACS'ta hasta eşlemesi ad (PN: Soyad^Ad* ve Ad^Soyad*) ve kimlik (PatientID = dosya no / TCKN) üzerinden;
    /// sonuçlar çalışma UID'siyle tekilleştirilir. Radyoloji istemine bağlı olmayan (dışarıdan gelmiş, eski) görüntüler
    /// de böyle bulunur.
    /// </summary>
    public async Task<List<PacsCalisma>> HastaCalismalariAsync(IEnumerable<string> adDesenleri, IEnumerable<string> kimlikler,
                                                               CancellationToken iptal)
    {
        var sonuc = new Dictionary<string, PacsCalisma>(StringComparer.Ordinal);
        async Task Topla(DicomCFindRequest q)
        {
            foreach (var t in new[] { DicomTag.ModalitiesInStudy, DicomTag.NumberOfStudyRelatedInstances, DicomTag.StudyDescription,
                                      DicomTag.AccessionNumber, DicomTag.StudyTime })
                q.Dataset.AddOrUpdate(t, string.Empty);
            foreach (var d in await SorgulaAsync(q, iptal))
            {
                var uid = d.GetSingleValueOrDefault(DicomTag.StudyInstanceUID, "");
                if (string.IsNullOrWhiteSpace(uid) || sonuc.ContainsKey(uid)) continue;
                sonuc[uid] = new PacsCalisma(uid,
                    d.GetSingleValueOrDefault(DicomTag.StudyDate, ""), d.GetSingleValueOrDefault(DicomTag.StudyTime, ""),
                    string.Join("/", d.Contains(DicomTag.ModalitiesInStudy) ? d.GetValues<string>(DicomTag.ModalitiesInStudy) : []),
                    d.GetSingleValueOrDefault(DicomTag.StudyDescription, ""), d.GetSingleValueOrDefault(DicomTag.AccessionNumber, ""),
                    d.GetSingleValueOrDefault(DicomTag.NumberOfStudyRelatedInstances, 0),
                    d.GetSingleValueOrDefault(DicomTag.PatientName, "").Replace('^', ' ').Trim(),
                    d.GetSingleValueOrDefault(DicomTag.PatientID, ""));
            }
        }
        foreach (var k in kimlikler.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
            await Topla(DicomCFindRequest.CreateStudyQuery(patientId: k));
        foreach (var ad in adDesenleri.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct())
            await Topla(DicomCFindRequest.CreateStudyQuery(patientName: ad));
        return sonuc.Values.OrderByDescending(x => x.Tarih).ThenByDescending(x => x.Saat).ToList();
    }

    /// <summary>
    /// OHIF "dicomjson" manifesti: studies[ series[ instances[ {metadata, url} ] ] ]. Görüntü adresi bu API'nin WADO
    /// vekili (<paramref name="wadoTaban"/> + jeton) - OHIF'in tarayıcısı ClearCanvas'a doğrudan gitmez (CORS / ağ).
    /// </summary>
    public async Task<object?> ManifestAsync(string studyUid, string wadoTaban, string jeton, CancellationToken iptal)
    {
        var calismalar = await SorgulaAsync(DicomCFindRequest.CreateStudyQuery(studyInstanceUid: studyUid), iptal);
        var c = calismalar.FirstOrDefault();
        if (c is null) return null;
        var seriler = await SorgulaAsync(DicomCFindRequest.CreateSeriesQuery(studyUid), iptal);
        var seriListesi = new List<object>();
        var toplam = 0;
        var modaliteler = new HashSet<string>(StringComparer.Ordinal);
        foreach (var s in seriler.OrderBy(x => SeriNo(x)))
        {
            var seriesUid = s.GetSingleValueOrDefault(DicomTag.SeriesInstanceUID, "");
            if (string.IsNullOrWhiteSpace(seriesUid)) continue;
            var modalite = s.GetSingleValueOrDefault(DicomTag.Modality, "");
            if (!string.IsNullOrWhiteSpace(modalite)) modaliteler.Add(modalite);
            var goruntuIstek = DicomCFindRequest.CreateImageQuery(studyUid, seriesUid);
            // SOPClassUID istenmeden gelmiyor (ClearCanvas); OHIF görüntü kümesini onunla kurar.
            foreach (var t in new[] { DicomTag.SOPClassUID, DicomTag.InstanceNumber,
                                      DicomTag.Rows, DicomTag.Columns, DicomTag.BitsAllocated, DicomTag.PhotometricInterpretation,
                                      DicomTag.ImagePositionPatient, DicomTag.ImageOrientationPatient, DicomTag.PixelSpacing,
                                      DicomTag.SliceThickness, DicomTag.NumberOfFrames })
                goruntuIstek.Dataset.AddOrUpdate(t, string.Empty);
            var goruntuler = await SorgulaAsync(goruntuIstek, iptal);
            var ornekler = new List<object>();
            foreach (var g in goruntuler.OrderBy(x => x.GetSingleValueOrDefault(DicomTag.InstanceNumber, 0)))
            {
                var sop = g.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, "");
                if (string.IsNullOrWhiteSpace(sop)) continue;
                var meta = new Dictionary<string, object?>
                {
                    ["SOPInstanceUID"] = sop,
                    ["SOPClassUID"] = g.GetSingleValueOrDefault(DicomTag.SOPClassUID, ""),
                    // Dosyada InstanceNumber yoksa sıra numarası (OHIF 0'ı "yok" sayıp sıralamayı bozuyor).
                    ["InstanceNumber"] = g.GetSingleValueOrDefault(DicomTag.InstanceNumber, 0) is var no && no > 0 ? no : ornekler.Count + 1,
                    ["SeriesInstanceUID"] = seriesUid,
                    ["StudyInstanceUID"] = studyUid,
                    ["Modality"] = modalite,
                };
                Ekle(meta, g, "Rows", DicomTag.Rows); Ekle(meta, g, "Columns", DicomTag.Columns);
                Ekle(meta, g, "BitsAllocated", DicomTag.BitsAllocated); Ekle(meta, g, "PhotometricInterpretation", DicomTag.PhotometricInterpretation);
                Ekle(meta, g, "SliceThickness", DicomTag.SliceThickness); Ekle(meta, g, "NumberOfFrames", DicomTag.NumberOfFrames);
                Dizi(meta, g, "ImagePositionPatient", DicomTag.ImagePositionPatient);
                Dizi(meta, g, "ImageOrientationPatient", DicomTag.ImageOrientationPatient);
                Dizi(meta, g, "PixelSpacing", DicomTag.PixelSpacing);
                ornekler.Add(new
                {
                    metadata = meta,
                    url = $"dicomweb:{wadoTaban}?studyUID={Uri.EscapeDataString(studyUid)}&seriesUID={Uri.EscapeDataString(seriesUid)}"
                        + $"&objectUID={Uri.EscapeDataString(sop)}&t={jeton}",
                });
            }
            toplam += ornekler.Count;
            seriListesi.Add(new
            {
                SeriesInstanceUID = seriesUid,
                SeriesNumber = SeriNo(s),
                Modality = modalite,
                SeriesDescription = s.GetSingleValueOrDefault(DicomTag.SeriesDescription, ""),
                instances = ornekler,
            });
        }
        var tarih = c.GetSingleValueOrDefault(DicomTag.StudyDate, "");
        return new
        {
            studies = new[]
            {
                new
                {
                    StudyInstanceUID = studyUid,
                    StudyDate = tarih,
                    StudyTime = c.GetSingleValueOrDefault(DicomTag.StudyTime, ""),
                    PatientName = c.GetSingleValueOrDefault(DicomTag.PatientName, ""),
                    PatientID = c.GetSingleValueOrDefault(DicomTag.PatientID, ""),
                    PatientBirthDate = c.GetSingleValueOrDefault(DicomTag.PatientBirthDate, ""),
                    PatientSex = c.GetSingleValueOrDefault(DicomTag.PatientSex, ""),
                    AccessionNumber = c.GetSingleValueOrDefault(DicomTag.AccessionNumber, ""),
                    StudyDescription = c.GetSingleValueOrDefault(DicomTag.StudyDescription, ""),
                    Modalities = string.Join("\\", modaliteler),
                    NumInstances = toplam,
                    series = seriListesi,
                },
            },
        };
    }

    private static int SeriNo(DicomDataset s) => s.GetSingleValueOrDefault(DicomTag.SeriesNumber, 0);
    private static void Ekle(Dictionary<string, object?> meta, DicomDataset d, string ad, DicomTag tag)
    {
        if (!d.Contains(tag)) return;
        var v = d.GetSingleValueOrDefault<string>(tag, "");
        if (string.IsNullOrWhiteSpace(v)) return;
        meta[ad] = int.TryParse(v, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n) ? n
                 : double.TryParse(v, NumberStyles.Float, CultureInfo.InvariantCulture, out var f) ? f : v;
    }
    private static void Dizi(Dictionary<string, object?> meta, DicomDataset d, string ad, DicomTag tag)
    {
        if (!d.Contains(tag)) return;
        var v = d.GetValues<string>(tag);
        if (v.Length == 0 || v.All(string.IsNullOrWhiteSpace)) return;
        meta[ad] = v.Select(x => double.TryParse(x, NumberStyles.Float, CultureInfo.InvariantCulture, out var f) ? f : 0).ToArray();
    }

    // ---------------------------------------------------------------- WADO vekili ----
    /// <summary>ClearCanvas WADO-URI'den DICOM nesnesini çeker (application/dicom).</summary>
    public async Task<HttpResponseMessage> WadoAsync(string studyUid, string seriesUid, string objectUid, CancellationToken iptal)
    {
        var istemci = http.CreateClient("dicom");
        var url = $"{Ayar.WadoUrl}?requestType=WADO&studyUID={Uri.EscapeDataString(studyUid)}&seriesUID={Uri.EscapeDataString(seriesUid)}"
                + $"&objectUID={Uri.EscapeDataString(objectUid)}&contentType=application%2Fdicom";
        return await istemci.GetAsync(url, HttpCompletionOption.ResponseHeadersRead, iptal);
    }

    /// <summary>
    /// TELETIP WADO (1313): çalışmadaki bütün nesneler "seriesUID|objectUID" - dışa açık WADO yalnız bu listedeki nesneyi
    /// verir (istek parametreleriyle başka çalışmanın nesnesine uzanılamaz).
    /// </summary>
    public async Task<HashSet<string>> CalismaNesneleriAsync(string studyUid, CancellationToken iptal)
    {
        var sonuc = new HashSet<string>(StringComparer.Ordinal);
        foreach (var s in await SorgulaAsync(DicomCFindRequest.CreateSeriesQuery(studyUid), iptal))
        {
            var seriesUid = s.GetSingleValueOrDefault(DicomTag.SeriesInstanceUID, "");
            if (seriesUid.Length == 0) continue;
            foreach (var g in await SorgulaAsync(DicomCFindRequest.CreateImageQuery(studyUid, seriesUid), iptal))
                if (g.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, "") is { Length: > 0 } sop) sonuc.Add(seriesUid + "|" + sop);
        }
        return sonuc;
    }

    /// <summary>KOS'ta Retrieve AE Title olarak yazılan PACS AE başlığı.</summary>
    public string PacsAe => Ayar.SunucuAe;

    /// <summary>
    /// TELETIP KOS (1310): çalışmanın KOS yapısı - C-FIND study / series / image + her serinin ortadaki görüntüsünden
    /// küçük resim (WADO application/dicom → <see cref="KucukResimUretici"/>). Çalışma yoksa null. Küçük resim
    /// üretilemeyen seri ikonsuz döner (çağıran uyarı yazar).
    /// </summary>
    public async Task<KosCalisma?> KosCalismaAsync(string studyUid, CancellationToken iptal)
    {
        var calismalar = await SorgulaAsync(DicomCFindRequest.CreateStudyQuery(studyInstanceUid: studyUid), iptal);
        var c = calismalar.FirstOrDefault();
        if (c is null) return null;
        var seriler = new List<KosSeri>();
        foreach (var s in (await SorgulaAsync(DicomCFindRequest.CreateSeriesQuery(studyUid), iptal)).OrderBy(SeriNo))
        {
            var seriesUid = s.GetSingleValueOrDefault(DicomTag.SeriesInstanceUID, "");
            if (string.IsNullOrWhiteSpace(seriesUid)) continue;
            var istek = DicomCFindRequest.CreateImageQuery(studyUid, seriesUid);
            foreach (var t in new[] { DicomTag.SOPClassUID, DicomTag.InstanceNumber, DicomTag.NumberOfFrames })
                istek.Dataset.AddOrUpdate(t, string.Empty);
            var goruntuler = (await SorgulaAsync(istek, iptal))
                .Select(g => new KosGoruntu(g.GetSingleValueOrDefault(DicomTag.SOPClassUID, ""), g.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, ""),
                                            g.GetSingleValueOrDefault(DicomTag.InstanceNumber, 0), g.GetSingleValueOrDefault(DicomTag.NumberOfFrames, 1)))
                .Where(g => g.SopInstanceUid.Length > 0).OrderBy(g => g.No).ToList();
            var seri = new KosSeri(seriesUid, s.GetSingleValueOrDefault(DicomTag.Modality, ""),
                                   s.GetSingleValueOrDefault(DicomTag.SeriesDescription, ""), SeriNo(s), goruntuler);
            if (goruntuler.Count > 0)
            {
                var orta = goruntuler[goruntuler.Count / 2];
                try
                {
                    using var y = await WadoAsync(studyUid, seriesUid, orta.SopInstanceUid, iptal);
                    if (y.IsSuccessStatusCode)
                    {
                        await using var akis = await y.Content.ReadAsStreamAsync(iptal);
                        using var bellek = new MemoryStream();
                        await akis.CopyToAsync(bellek, iptal);
                        bellek.Position = 0;
                        seri.Ikon = KucukResimUretici.Uret((await DicomFile.OpenAsync(bellek)).Dataset);
                    }
                }
                catch (Exception h) when (h is HttpRequestException or DicomFileException or TaskCanceledException) { /* ikonsuz */ }
            }
            seriler.Add(seri);
        }
        return new KosCalisma(studyUid, c.GetSingleValueOrDefault(DicomTag.StudyDate, ""), c.GetSingleValueOrDefault(DicomTag.StudyTime, ""),
                              c.GetSingleValueOrDefault(DicomTag.StudyDescription, ""), seriler);
    }
}
