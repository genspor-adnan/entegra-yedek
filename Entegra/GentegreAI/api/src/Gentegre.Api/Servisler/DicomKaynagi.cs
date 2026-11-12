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
public sealed class DicomKaynagi(DicomAyarDeposu depo, IOptions<GuvenlikAyarlari> guvenlik, IHttpClientFactory http) : IWadoPacs
{
    /// <summary>Geçerli PACS ayarı - şube kapsamına göre (1316: entegrasyon ekranı → dosya).</summary>
    public DicomAyarlari Ayar => depo.Gecerli();

    // ---------------------------------------------------------------- jeton ----
    // Jeton ŞUBEYİ de taşır (1316): manifest / WADO uçları anonim (OHIF başlık gönderemez), hangi şubenin PACS'ına
    //   gidileceği jetondan okunur. Biçim "son.şube.imza"; eski "son.imza" jetonları kurum geneli sayılır.
    public string JetonUret(string studyUid, int? dakika = null)
    {
        var son = DateTimeOffset.UtcNow.AddMinutes(dakika ?? Ayar.JetonDakika).ToUnixTimeSeconds();
        var sube = DicomAyarDeposu.Kapsam ?? 0;
        return $"{son}.{sube}.{Imza(studyUid, son, sube)}";
    }

    public bool JetonGecerli(string studyUid, string? jeton) => JetonGecerli(studyUid, jeton, out _);

    public bool JetonGecerli(string studyUid, string? jeton, out int? sube)
    {
        sube = null;
        if (string.IsNullOrWhiteSpace(jeton)) return false;
        var p = jeton.Split('.');
        if (p.Length is not (2 or 3)) return false;
        if (!long.TryParse(p[0], NumberStyles.Integer, CultureInfo.InvariantCulture, out var son)) return false;
        if (DateTimeOffset.UtcNow.ToUnixTimeSeconds() > son) return false;
        var s = 0;
        if (p.Length == 3 && !int.TryParse(p[1], NumberStyles.Integer, CultureInfo.InvariantCulture, out s)) return false;
        var beklenen = p.Length == 3 ? Imza(studyUid, son, s) : Imza(studyUid, son, null);
        var tamam = CryptographicOperations.FixedTimeEquals(Encoding.ASCII.GetBytes(beklenen), Encoding.ASCII.GetBytes(p[^1]));
        if (tamam && s > 0) sube = s;
        return tamam;
    }

    private string Imza(string studyUid, long son, int? sube)
    {
        var anahtar = Encoding.UTF8.GetBytes(guvenlik.Value.ImzaAnahtari + "|dicom");
        var veri = Encoding.UTF8.GetBytes(sube is null ? $"{studyUid}|{son}" : $"{studyUid}|{son}|{sube}");
        var h = HMACSHA256.HashData(anahtar, veri);
        return Convert.ToBase64String(h).TrimEnd('=').Replace('+', '-').Replace('/', '_');
    }

    // ---------------------------------------------------------------- C-FIND ----
    private static IDicomClient Istemci(DicomAyarlari a)
        => DicomClientFactory.Create(a.Sunucu, a.Port, false, a.BizimAe, a.SunucuAe);

    private Task<List<DicomDataset>> SorgulaAsync(DicomCFindRequest istek, CancellationToken iptal) => SorgulaAsync(istek, iptal, Ayar);

    private static async Task<List<DicomDataset>> SorgulaAsync(DicomCFindRequest istek, CancellationToken iptal, DicomAyarlari a)
    {
        var sonuc = new List<DicomDataset>();
        istek.OnResponseReceived += (_, yanit) =>
        {
            if (yanit.Status == DicomStatus.Pending && yanit.HasDataset) sonuc.Add(yanit.Dataset);
        };
        var istemci = Istemci(a);
        await istemci.AddRequestAsync(istek);
        using var zaman = CancellationTokenSource.CreateLinkedTokenSource(iptal);
        zaman.CancelAfter(TimeSpan.FromSeconds(Math.Max(5, a.ZamanAsimiSn)));
        await istemci.SendAsync(zaman.Token);
        return sonuc;
    }

    /// <summary>Bağlantı testinin bir adımı (entegrasyon ekranı › PACS kartı).</summary>
    public sealed record SinamaAdimi(string Ad, bool Tamam, string Ayrinti, long Ms);

    /// <summary>
    /// PACS BAĞLANTI TESTİ (1316): verilen ayarla sırayla C-ECHO → C-FIND (son 1 günün çalışmaları; boşsa son 30 gün) →
    /// WADO (bulunan ilk görüntü, application/dicom) → görüntüleyici adresi. Bir adım düşerse sonrakiler denenmez
    /// (görüntüleyici hariç - PACS'tan bağımsız). Kayıt değiştirmez.
    /// </summary>
    public async Task<List<SinamaAdimi>> SinaAsync(DicomAyarlari a, CancellationToken iptal)
    {
        var adimlar = new List<SinamaAdimi>();
        var sw = System.Diagnostics.Stopwatch.StartNew();
        async Task<bool> Adim(string ad, Func<Task<string>> is_)
        {
            sw.Restart();
            try { var ayr = await is_(); adimlar.Add(new(ad, true, ayr, sw.ElapsedMilliseconds)); return true; }
            catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
            {
                var m = h is OperationCanceledException ? $"zaman aşımı ({Math.Max(5, a.ZamanAsimiSn)} sn) - sunucu / port / güvenlik duvarı" : h.Message;
                // Ham DICOM / ağ hatasına kullanıcının yapacağı işi ekle.
                if (m.Contains("Association rejected", StringComparison.OrdinalIgnoreCase))
                    m += $" → PACS bağlantıyı reddetti: PACS AE başlığını ({a.SunucuAe}) ve PACS'ta bizim AE'nin ({a.BizimAe}) tanımlı olduğunu kontrol edin.";
                else if (h is System.Net.Sockets.SocketException || m.Contains("refused", StringComparison.OrdinalIgnoreCase)
                         || m.Contains("reddedildi", StringComparison.OrdinalIgnoreCase))
                    m += $" → {a.Sunucu}:{a.Port} adresinde DICOM servisi yok: sunucu / port / güvenlik duvarı.";
                adimlar.Add(new(ad, false, m, sw.ElapsedMilliseconds));
                return false;
            }
        }
        var echoTamam = await Adim($"C-ECHO {a.Sunucu}:{a.Port} {a.BizimAe} → {a.SunucuAe}", async () =>
        {
            var istemci = Istemci(a);
            DicomStatus? durum = null;
            var e = new DicomCEchoRequest();
            e.OnResponseReceived += (_, y) => durum = y.Status;
            await istemci.AddRequestAsync(e);
            using var z = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            z.CancelAfter(TimeSpan.FromSeconds(Math.Max(5, a.ZamanAsimiSn)));
            await istemci.SendAsync(z.Token);
            if (durum != DicomStatus.Success) throw new InvalidOperationException($"PACS yanıtı: {durum?.ToString() ?? "yok"}");
            return "yanıt verdi";
        });
        (string Study, string Seri, string Sop)? ornek = null;
        if (echoTamam && await Adim("C-FIND çalışma sorgusu", async () =>
            {
                // Yalnız StudyDate aralığı: CreateStudyQuery(studyDateTime) StudyTime aralığı da koyuyor (00:00-00:00) ve
                //   hiçbir çalışma eşleşmiyordu. Tüm arşiv sorgulanmaz (büyük PACS'ta ağır) - en çok 1 yıl.
                foreach (var gun in new[] { 1, 30, 365 })
                {
                    var q = DicomCFindRequest.CreateStudyQuery();
                    q.Dataset.AddOrUpdate(DicomTag.StudyDate,
                        $"{DateTime.Today.AddDays(-gun):yyyyMMdd}-{DateTime.Today.AddDays(1):yyyyMMdd}");
                    var calismalar = await SorgulaAsync(q, iptal, a);
                    if (calismalar.Count == 0) continue;
                    foreach (var c in calismalar.Take(5))
                    {
                        var st = c.GetSingleValueOrDefault(DicomTag.StudyInstanceUID, "");
                        foreach (var s in await SorgulaAsync(DicomCFindRequest.CreateSeriesQuery(st), iptal, a))
                        {
                            var se = s.GetSingleValueOrDefault(DicomTag.SeriesInstanceUID, "");
                            var g = (await SorgulaAsync(DicomCFindRequest.CreateImageQuery(st, se), iptal, a)).FirstOrDefault();
                            if (g?.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, "") is { Length: > 0 } sop) { ornek = (st, se, sop); break; }
                        }
                        if (ornek is not null) break;
                    }
                    return $"son {gun} günde {calismalar.Count} çalışma";
                }
                return "sorgu çalıştı, son 1 yılda çalışma yok";
            }) && ornek is { } o)
        {
            await Adim("WADO görüntü (application/dicom)", async () =>
            {
                using var y = await WadoAsync(a, o.Study, o.Seri, o.Sop, iptal);
                if (!y.IsSuccessStatusCode) throw new InvalidOperationException($"HTTP {(int)y.StatusCode} - {a.WadoUrl}");
                var b = await y.Content.ReadAsByteArrayAsync(iptal);
                return $"{b.Length / 1024} KB";
            });
        }
        else if (echoTamam && adimlar.Count > 1 && adimlar[^1].Tamam)
            adimlar.Add(new("WADO görüntü (application/dicom)", true, "denenmedi - PACS'ta örnek görüntü yok", 0));
        if (!string.IsNullOrWhiteSpace(a.GoruntuleyiciUrl))
            await Adim($"Görüntüleyici {a.GoruntuleyiciUrl}", async () =>
            {
                var istemci = http.CreateClient("dicom");
                using var y = await istemci.GetAsync(a.GoruntuleyiciUrl, HttpCompletionOption.ResponseHeadersRead, iptal);
                if ((int)y.StatusCode >= 500) throw new InvalidOperationException($"HTTP {(int)y.StatusCode}");
                return $"HTTP {(int)y.StatusCode}";
            });
        return adimlar;
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
    public Task<HttpResponseMessage> WadoAsync(string studyUid, string seriesUid, string objectUid, CancellationToken iptal)
        => WadoAsync(Ayar, studyUid, seriesUid, objectUid, iptal);

    private async Task<HttpResponseMessage> WadoAsync(DicomAyarlari a, string studyUid, string seriesUid, string objectUid, CancellationToken iptal)
    {
        var istemci = http.CreateClient("dicom");
        var url = $"{a.WadoUrl}?requestType=WADO&studyUID={Uri.EscapeDataString(studyUid)}&seriesUID={Uri.EscapeDataString(seriesUid)}"
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

    /// <summary>
    /// TELETIP DOZ (1314): çalışmadaki X-Ray Radiation Dose SR nesneleri (SOP Class 1.2.840.10008.5.1.4.1.1.88.67) -
    /// (seriesUID, sopUID). Cihaz RDSR üretmiyorsa boş.
    /// </summary>
    public async Task<List<(string Seri, string Sop)>> DozRaporlariAsync(string studyUid, CancellationToken iptal)
    {
        var sonuc = new List<(string, string)>();
        foreach (var s in await SorgulaAsync(DicomCFindRequest.CreateSeriesQuery(studyUid), iptal))
        {
            var seriesUid = s.GetSingleValueOrDefault(DicomTag.SeriesInstanceUID, "");
            if (seriesUid.Length == 0) continue;
            var modalite = s.GetSingleValueOrDefault(DicomTag.Modality, "");
            if (modalite.Length > 0 && modalite != "SR" && modalite != "KO" && modalite != "OT") continue;   // doz SR'si SR serisinde
            var istek = DicomCFindRequest.CreateImageQuery(studyUid, seriesUid);
            istek.Dataset.AddOrUpdate(DicomTag.SOPClassUID, string.Empty);
            foreach (var g in await SorgulaAsync(istek, iptal))
                if (g.GetSingleValueOrDefault(DicomTag.SOPClassUID, "") == DozUretici.RdsrSopClass
                    && g.GetSingleValueOrDefault(DicomTag.SOPInstanceUID, "") is { Length: > 0 } sop)
                    sonuc.Add((seriesUid, sop));
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
            // Görüntüsüz seriler (doz SR, KO, PR) küçük resim taşımaz - WADO indirmesi boşa olurdu.
            if (goruntuler.Count > 0 && seri.Modalite is not ("SR" or "KO" or "PR"))
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
