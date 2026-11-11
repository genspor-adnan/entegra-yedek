using System.Globalization;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using System.Threading.RateLimiting;
using FellowOakDicom;
using FellowOakDicom.Imaging;
using FellowOakDicom.Imaging.Codec;
using Gentegre.Veri;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

// =====================================================================================================================
// TELETIP DIŞA AÇIK WADO (RAD-55) - kullanıcı 11.11.2026: "dışa açık WADO adımını yap". db/1313.
//   Teleradyoloji Entegrasyon Kılavuzu 3.43 § 4.2: Bakanlık web görüntüleyicisi KOS'ta referans verilen görüntüleri
//   kurumun WADO servisinden DICOM VE JPEG olarak çeker; public port yönlendirmesi + statik IP + Bakanlık DNS'i +
//   Bakanlık sertifikası; 7/24. XDS Kılavuzu 1.15 § 2.3 Tablo 4: requestType / studyUID / seriesUID / objectUID
//   zorunlu, contentType boşsa application/dicom; en az application/dicom + image/jpeg; bulunamazsa 404, eksik /
//   bozuk parametrede 400.
//   ClearCanvas WADO'su JPEG vermiyor (400) → DICOM'u PACS'tan alıp JPEG'i burada çiziyoruz (DicomGoruntuCizici).
//   Güvenlik: AYRI port (yalnız bu uç), yalnız KOS'u Bakanlık'a başarıyla gitmiş çalışma (teletip_gonderim kanal 2
//   durum 1 study_uid), nesne o çalışmanın C-FIND listesinde olmalı, IP başına hız sınırı, isteğe bağlı IP izin
//   listesi, erişim sayacı (teletip_wado_erisim).
// =====================================================================================================================

/// <summary>"TeletipWado" yapılandırma bölümü. Port 0 → servis kapalı.</summary>
public sealed class TeletipWadoAyarlari
{
    /// <summary>Dinlenecek port (kılavuz örneği 35004). 0 = kapalı.</summary>
    public int Port { get; set; }
    /// <summary>Uç yolu - Bakanlık örneği "/DCM/WADO". "/WADO" da kabul edilir.</summary>
    public string Yol { get; set; } = "/DCM/WADO";
    /// <summary>Bakanlık'ın kurduğu sertifika (.pfx). Boşsa düz HTTP (yalnız test ya da TLS'i önündeki vekil sonlandırıyorsa).</summary>
    public string SertifikaYolu { get; set; } = "";
    /// <summary>.pfx parolası - yalnız ortam değişkeninden (TeletipWado__SertifikaParola), dosyaya yazılmaz.</summary>
    public string SertifikaParola { get; set; } = "";
    /// <summary>İzinli istemci IP / CIDR listesi ("10.0.0.0/8", "1.2.3.4"). Boş = herkes (Bakanlık görüntüleyicisi
    /// SBA içi ve dışından erişir).</summary>
    public string[] IzinliIpler { get; set; } = [];
    /// <summary>IP başına dakikadaki en çok istek (görüntüleyici bir çalışmada yüzlerce nesne çeker).</summary>
    public int DakikadaIstek { get; set; } = 3000;
    /// <summary>imageQuality verilmezse JPEG kalitesi.</summary>
    public int JpegKalite { get; set; } = 90;
    /// <summary>CORS için izinli köken sonekleri (tarayıcıdaki Bakanlık görüntüleyicisi).</summary>
    public string[] KokenSonekleri { get; set; } = [".saglik.gov.tr"];
}

public sealed record CizimIstegi(int Kare = 0, int Satir = 0, int Sutun = 0, double? Merkez = null, double? Genislik = null,
                                 int Kalite = 90, bool CiftGenislik = false);
public sealed record Cizim(byte[] Jpeg, int Satir, int Sutun);

/// <summary>Görüntü çizilemedi - Kod HTTP durum kodu (404 kare yok, 406 desteklenmeyen biçim).</summary>
public sealed class CizimHatasi(int kod, string mesaj) : Exception(mesaj)
{
    public int Kod { get; } = kod;
}

/// <summary>
/// DICOM → JPEG çizici (WADO image/jpeg ve KOS küçük resmi). Sıkıştırmasız MONOCHROME1/2 (8/16 bit, işaretli /
/// işaretsiz, BitsStored maskesi, Rescale), RGB ve YBR_FULL (8 bit). Pencere: istekteki windowCenter/Width, yoksa
/// görüntünün ilk VOI penceresi, yoksa min-max. Çok kare: Kare (0 tabanlı). Satır / Sütun verilirse en/boy oranı
/// korunarak küçültülür (büyütme yok). Sıkıştırılmış: JPEG Baseline ve ek işlem yoksa kare olduğu gibi döner; aksi
/// halde fo-dicom çekirdeğinin çözebildiği (RLE) açılır, çözülemeyen 406.
/// </summary>
public static class DicomGoruntuCizici
{
    public static Cizim Ciz(DicomDataset d, CizimIstegi i)
    {
        if (!d.Contains(DicomTag.PixelData)) throw new CizimHatasi(406, "Nesnede görüntü verisi yok (PixelData).");
        int satir0 = d.GetSingleValueOrDefault(DicomTag.Rows, (ushort)0), sutun0 = d.GetSingleValueOrDefault(DicomTag.Columns, (ushort)0);
        var ts = d.InternalTransferSyntax;
        if (ts.IsEncapsulated)
        {
            if (ts == DicomTransferSyntax.JPEGProcess1 && i.Merkez is null && i.Genislik is null && !i.CiftGenislik
                && (i.Satir <= 0 || i.Satir >= satir0) && (i.Sutun <= 0 || i.Sutun >= sutun0))
            {
                var p0 = DicomPixelData.Create(d);
                if (i.Kare < 0 || i.Kare >= p0.NumberOfFrames) throw new CizimHatasi(404, $"Kare yok ({i.Kare + 1} / {p0.NumberOfFrames}).");
                return new Cizim(p0.GetFrame(i.Kare).Data, satir0, sutun0);
            }
            try { d = new DicomTranscoder(ts, DicomTransferSyntax.ExplicitVRLittleEndian).Transcode(d); }
            catch (Exception e) { throw new CizimHatasi(406, $"Sıkıştırılmış görüntü çözülemedi ({ts.UID.Name}): {e.Message}"); }
        }

        var p = DicomPixelData.Create(d);
        int w = p.Width, h = p.Height;
        if (w <= 0 || h <= 0) throw new CizimHatasi(406, "Görüntü boyutu yok.");
        if (i.Kare < 0 || i.Kare >= p.NumberOfFrames) throw new CizimHatasi(404, $"Kare yok ({i.Kare + 1} / {p.NumberOfFrames}).");
        var foto = d.GetSingleValueOrDefault(DicomTag.PhotometricInterpretation, "MONOCHROME2").Trim();
        var ham = p.GetFrame(i.Kare).Data;
        byte[] duzlem; bool renkli;

        if (foto.StartsWith("MONOCHROME", StringComparison.Ordinal))
        {
            if (p.BitsAllocated is not (8 or 16)) throw new CizimHatasi(406, $"Desteklenmeyen bit derinliği ({p.BitsAllocated}).");
            var isaretli = p.PixelRepresentation == PixelRepresentation.Signed;
            var maske = p.BitsStored is > 0 and < 16 ? (1 << p.BitsStored) - 1 : 0xFFFF;
            var egim = d.GetSingleValueOrDefault(DicomTag.RescaleSlope, 1.0);
            var kesisim = d.GetSingleValueOrDefault(DicomTag.RescaleIntercept, 0.0);
            var deger = new float[w * h];
            float min = float.MaxValue, max = float.MinValue;
            for (var k = 0; k < w * h; k++)
            {
                double x = p.BitsAllocated == 16
                    ? (isaretli ? BitConverter.ToInt16(ham, k * 2) : BitConverter.ToUInt16(ham, k * 2) & maske)
                    : ham[k];
                var v = (float)(x * egim + kesisim);
                deger[k] = v;
                if (v < min) min = v;
                if (v > max) max = v;
            }
            double alt, ust;
            if (i.Merkez is double mc && i.Genislik is double mg && mg >= 1) { alt = mc - mg / 2; ust = mc + mg / 2; }
            else if (d.TryGetValues<double>(DicomTag.WindowCenter, out var wc) && wc.Length > 0
                     && d.TryGetValues<double>(DicomTag.WindowWidth, out var ww) && ww.Length > 0 && ww[0] > 1)
            { alt = wc[0] - ww[0] / 2; ust = wc[0] + ww[0] / 2; }
            else { alt = min; ust = max; }
            if (ust <= alt) ust = alt + 1;
            var ters = foto == "MONOCHROME1";
            duzlem = new byte[w * h];
            var olcek = 255.0 / (ust - alt);
            for (var k = 0; k < w * h; k++)
            {
                var g8 = (int)Math.Round(Math.Clamp((deger[k] - alt) * olcek, 0, 255));
                duzlem[k] = (byte)(ters ? 255 - g8 : g8);
            }
            renkli = false;
        }
        else if (foto is "RGB" or "YBR_FULL" && p.BitsAllocated == 8)
        {
            var duzlemsel = d.GetSingleValueOrDefault(DicomTag.PlanarConfiguration, (ushort)0) == 1;
            duzlem = new byte[w * h * 3];
            for (var k = 0; k < w * h; k++)
            {
                int a = duzlemsel ? ham[k] : ham[k * 3], b = duzlemsel ? ham[w * h + k] : ham[k * 3 + 1],
                    c = duzlemsel ? ham[2 * w * h + k] : ham[k * 3 + 2];
                if (foto == "YBR_FULL")
                {
                    double y = a, cb = b - 128.0, cr = c - 128.0;
                    (a, b, c) = (Sinir(y + 1.402 * cr), Sinir(y - 0.344136 * cb - 0.714136 * cr), Sinir(y + 1.772 * cb));
                }
                duzlem[k * 3] = (byte)a; duzlem[k * 3 + 1] = (byte)b; duzlem[k * 3 + 2] = (byte)c;
            }
            renkli = true;
        }
        else throw new CizimHatasi(406, $"Desteklenmeyen renk yorumu ({foto}, {p.BitsAllocated} bit).");

        var oran = 1.0;
        if (i.Satir > 0) oran = Math.Min(oran, (double)i.Satir / h);
        if (i.Sutun > 0) oran = Math.Min(oran, (double)i.Sutun / w);
        int kw = Math.Max(1, (int)Math.Round(w * oran)), kh = Math.Max(1, (int)Math.Round(h * oran));
        if (i.CiftGenislik) kw += kw % 2;
        var kanal = renkli ? 3 : 1;
        var cikti = kw == w && kh == h ? duzlem : Kucult(duzlem, w, h, kanal, kw, kh);
        var jpeg = renkli ? JpegKodlayici.Rgb422(cikti, kw, kh, i.Kalite) : JpegKodlayici.Gri422(cikti, kw, kh, i.Kalite);
        return new Cizim(jpeg, kh, kw);
    }

    private static int Sinir(double x) => Math.Clamp((int)Math.Round(x), 0, 255);

    /// <summary>Kutu ortalamasıyla küçültme (hedef pikselin kapsadığı kaynak alan).</summary>
    private static byte[] Kucult(byte[] kaynak, int w, int h, int kanal, int kw, int kh)
    {
        var hedef = new byte[kw * kh * kanal];
        for (var y = 0; y < kh; y++)
        {
            int y0 = Math.Min(h - 1, y * h / kh), y1 = Math.Min(h, Math.Max(y0 + 1, (y + 1) * h / kh));
            for (var x = 0; x < kw; x++)
            {
                int x0 = Math.Min(w - 1, x * w / kw), x1 = Math.Min(w, Math.Max(x0 + 1, (x + 1) * w / kw));
                for (var c = 0; c < kanal; c++)
                {
                    long t = 0; var n = 0;
                    for (var yy = y0; yy < y1; yy++)
                        for (var xx = x0; xx < x1; xx++) { t += kaynak[(yy * w + xx) * kanal + c]; n++; }
                    hedef[(y * kw + x) * kanal + c] = (byte)(n > 0 ? (t + n / 2) / n : 0);
                }
            }
        }
        return hedef;
    }
}

/// <summary>WADO yanıtı (gövde ya da hata metni).</summary>
public sealed record WadoYaniti(int Kod, string IcerikTuru, byte[] Govde, string Hata = "");

/// <summary>Testte / sunucuda PACS'a erişim (DicomKaynagi bunu uygular).</summary>
public interface IWadoPacs
{
    Task<HashSet<string>> CalismaNesneleriAsync(string studyUid, CancellationToken iptal);
    Task<HttpResponseMessage> WadoAsync(string studyUid, string seriesUid, string objectUid, CancellationToken iptal);
}

/// <summary>
/// WADO-URI isteğini işler: parametre denetimi (400), içerik türü (406), erişim kuralı + nesne listesi (404), PACS'tan
/// DICOM, gerekirse JPEG çizimi. Her istek erişim sayacına yazılır. Ağ katmanından bağımsız - testler doğrudan çağırır.
/// </summary>
public sealed class TeletipWadoServisi(VeriKaynagi veri, IWadoPacs pacs, IMemoryCache bellek,
                                       IOptions<TeletipWadoAyarlari> ayar, ILogger<TeletipWadoServisi> gunluk)
{
    private static readonly Regex UidDeseni = new(@"^[0-9]+(\.[0-9]+)*$", RegexOptions.Compiled);
    public const string Dicom = "application/dicom";
    public const string Jpeg = "image/jpeg";

    public TeletipWadoAyarlari Ayar => ayar.Value;

    /// <summary>İstemci IP'si izin listesinde mi (liste boşsa herkes).</summary>
    public bool IpIzinli(IPAddress? ip)
    {
        if (Ayar.IzinliIpler.Length == 0) return true;
        if (ip is null) return false;
        if (ip.IsIPv4MappedToIPv6) ip = ip.MapToIPv4();
        foreach (var g in Ayar.IzinliIpler.Select(x => x.Trim()).Where(x => x.Length > 0))
        {
            if (g.Contains('/')) { if (IPNetwork.TryParse(g, out var ag) && ag.Contains(ip)) return true; }
            else if (IPAddress.TryParse(g, out var tek) && tek.Equals(ip)) return true;
        }
        return false;
    }

    /// <summary>contentType listesinden (virgüllü olabilir, PS3.18) desteklenen ilk tür; boş → DICOM, yok → null.</summary>
    public static string? IcerikTuruSec(string istenen)
    {
        if (string.IsNullOrWhiteSpace(istenen)) return Dicom;
        foreach (var ham in istenen.Split(','))
        {
            var t = ham.Split(';')[0].Trim().ToLowerInvariant();
            if (t is "application/dicom" or "*/*") return Dicom;
            if (t is "image/jpeg" or "image/jpg" or "application/jpeg" or "image/*") return Jpeg;
        }
        return null;
    }

    public async Task<WadoYaniti> IsleAsync(IReadOnlyDictionary<string, string> q, string ip, CancellationToken iptal)
    {
        string Q(string ad) => q.TryGetValue(ad, out var v) ? (v ?? "").Trim() : "";
        var st = Q("studyUID");
        var y = await HesaplaAsync(Q, st, Q("seriesUID"), Q("objectUID"), iptal);
        await SayacAsync(ip, st.Length is > 0 and <= 64 && UidDeseni.IsMatch(st) ? st : "-", y, iptal);
        return y;
    }

    private async Task<WadoYaniti> HesaplaAsync(Func<string, string> Q, string st, string se, string ob, CancellationToken iptal)
    {
        if (!Q("requestType").Equals("WADO", StringComparison.OrdinalIgnoreCase)) return Hata(400, "requestType=WADO olmalı.");
        foreach (var (ad, uid) in new[] { ("studyUID", st), ("seriesUID", se), ("objectUID", ob) })
            if (uid.Length is 0 or > 64 || !UidDeseni.IsMatch(uid)) return Hata(400, $"{ad} eksik ya da geçersiz.");
        var tur = IcerikTuruSec(Q("contentType"));
        if (tur is null) return Hata(406, "Desteklenen contentType: application/dicom, image/jpeg.");
        int? Sayi(string ad, int enAz, int enCok)
        {
            var s = Q(ad);
            if (s.Length == 0) return null;
            return int.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n) && n >= enAz && n <= enCok ? n : int.MinValue;
        }
        double? Ondalik(string ad) => double.TryParse(Q(ad), NumberStyles.Float, CultureInfo.InvariantCulture, out var x) ? x : null;
        var kare = Sayi("frameNumber", 1, 100000); var satir = Sayi("rows", 1, 65535); var sutun = Sayi("columns", 1, 65535);
        var kalite = Sayi("imageQuality", 1, 100);
        if (new[] { kare, satir, sutun, kalite }.Any(x => x == int.MinValue)) return Hata(400, "frameNumber / rows / columns / imageQuality geçersiz.");
        var merkez = Ondalik("windowCenter"); var genislik = Ondalik("windowWidth");
        if ((Q("windowCenter").Length > 0 || Q("windowWidth").Length > 0) && (merkez is null || genislik is null))
            return Hata(400, "windowCenter ile windowWidth birlikte ve sayı olarak verilmeli.");

        // Erişim kuralı: yalnız KOS'u Bakanlık'a başarıyla gitmiş çalışma; nesne o çalışmada olmalı.
        var sube = await CalismaSubesiAsync(st, iptal);
        if (sube is null) return Hata(404, "Nesne bulunamadı.");
        using var kapsam = DicomAyarDeposu.SubeIcin(sube);             // 1316: KOS'u gönderen şubenin PACS'ı
        HashSet<string> nesneler;
        try { nesneler = await NesnelerAsync(st, iptal); }
        catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
        {
            gunluk.LogWarning(h, "Teletıp WADO: PACS sorgusu başarısız ({Study}).", st);
            return Hata(503, "PACS'a ulaşılamadı.");
        }
        if (!nesneler.Contains(se + "|" + ob)) return Hata(404, "Nesne bulunamadı.");

        byte[] baytlar;
        try
        {
            using var y = await pacs.WadoAsync(st, se, ob, iptal);
            if (y.StatusCode == HttpStatusCode.NotFound) return Hata(404, "Nesne PACS'ta bulunamadı.");
            if (!y.IsSuccessStatusCode) return Hata(502, $"PACS WADO HTTP {(int)y.StatusCode}.");
            baytlar = await y.Content.ReadAsByteArrayAsync(iptal);
        }
        catch (Exception h) when (h is HttpRequestException || (h is TaskCanceledException && !iptal.IsCancellationRequested))
        {
            return Hata(503, "PACS WADO'suna ulaşılamadı: " + h.Message);
        }
        if (tur == Dicom) return new WadoYaniti(200, Dicom, baytlar);

        try
        {
            var dosya = await DicomFile.OpenAsync(new MemoryStream(baytlar));
            var c = DicomGoruntuCizici.Ciz(dosya.Dataset, new CizimIstegi(
                Kare: (kare ?? 1) - 1, Satir: satir ?? 0, Sutun: sutun ?? 0,
                Merkez: merkez, Genislik: genislik, Kalite: kalite ?? Ayar.JpegKalite));
            return new WadoYaniti(200, Jpeg, c.Jpeg);
        }
        catch (CizimHatasi h) { return Hata(h.Kod, h.Message); }
        catch (DicomFileException h) { return Hata(502, "PACS'tan gelen DICOM okunamadı: " + h.Message); }
    }

    private static WadoYaniti Hata(int kod, string mesaj) => new(kod, "text/plain; charset=utf-8", [], mesaj);

    /// <summary>KOS'u başarıyla gitmiş çalışmanın şubesi (0 = kurum geneli); gitmemişse null.</summary>
    private async Task<int?> CalismaSubesiAsync(string st, CancellationToken iptal)
    {
        if (bellek.TryGetValue("tt-wado-izin:" + st, out int? sube)) return sube;
        sube = await veri.TekDegerAsync<int?>(
            "select max(sube_id) from public.teletip_gonderim where kanal = 2 and durum = 1 and study_uid = @p0", [st], iptal);
        bellek.Set("tt-wado-izin:" + st, sube, TimeSpan.FromMinutes(1));
        return sube;
    }

    private async Task<HashSet<string>> NesnelerAsync(string st, CancellationToken iptal)
    {
        if (bellek.TryGetValue("tt-wado-nesne:" + st, out HashSet<string>? k) && k is not null) return k;
        var liste = await pacs.CalismaNesneleriAsync(st, iptal);
        // Boş liste kısa tutulur (PACS'a yeni gelen görüntü); dolu liste 10 dk.
        bellek.Set("tt-wado-nesne:" + st, liste, TimeSpan.FromMinutes(liste.Count == 0 ? 1 : 10));
        return liste;
    }

    private async Task SayacAsync(string ip, string st, WadoYaniti y, CancellationToken iptal)
    {
        try
        {
            var hata = y.Kod == 200 ? 0 : 1;
            var metin = $"{y.Kod} {y.Hata}";
            await veri.CalistirAsync("""
                insert into public.teletip_wado_erisim as t (gun, ip, study_uid, istek_sayisi, hata_sayisi, bayt, son_hata)
                values ((now() at time zone 'Europe/Istanbul')::date, @p0, @p1, 1, @p2, @p3, @p4)
                on conflict (gun, ip, study_uid) do update
                   set istek_sayisi = t.istek_sayisi + 1, hata_sayisi = t.hata_sayisi + excluded.hata_sayisi,
                       bayt = t.bayt + excluded.bayt, son_erisim = now(),
                       son_hata = case when excluded.hata_sayisi > 0 then excluded.son_hata else t.son_hata end
                """, [ip.Length > 45 ? ip[..45] : ip, st, hata, (long)y.Govde.Length, hata == 1 ? (metin.Length > 300 ? metin[..300] : metin) : ""], iptal);
        }
        catch (Exception h) when (h is not OperationCanceledException) { gunluk.LogWarning(h, "Teletıp WADO erişim sayacı yazılamadı."); }
    }
}

/// <summary>
/// AYRI PORTTA WADO SUNUCUSU: ana API'nin hiçbir ucu bu portta yok - dışarı yalnız WADO açılır. TeletipWado:Port 0
/// ise başlamaz. TLS: Bakanlık sertifikası (.pfx). IP başına hız sınırı, izin listesi, CORS (*.saglik.gov.tr).
/// </summary>
public sealed class TeletipWadoSunucusu(TeletipWadoServisi servis, ILogger<TeletipWadoSunucusu> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        var a = servis.Ayar;
        if (a.Port <= 0) return;
        WebApplication uygulama;
        try
        {
            var k = WebApplication.CreateSlimBuilder(new WebApplicationOptions { Args = [], ContentRootPath = AppContext.BaseDirectory });
            k.WebHost.ConfigureKestrel(o =>
            {
                o.AddServerHeader = false;
                o.ListenAnyIP(a.Port, l =>
                {
                    if (a.SertifikaYolu.Length > 0)
                        l.UseHttps(X509CertificateLoader.LoadPkcs12FromFile(a.SertifikaYolu, a.SertifikaParola));
                });
            });
            k.Services.AddRateLimiter(r =>
            {
                r.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
                r.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(c =>
                    RateLimitPartition.GetFixedWindowLimiter(c.Connection.RemoteIpAddress?.ToString() ?? "-", _ =>
                        new FixedWindowRateLimiterOptions { PermitLimit = Math.Max(1, a.DakikadaIstek), Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
            });
            uygulama = k.Build();
            uygulama.UseRateLimiter();
            uygulama.Use(async (c, sonraki) =>
            {
                if (KokenIzinli(c.Request.Headers.Origin.ToString(), a.KokenSonekleri))
                {
                    c.Response.Headers.AccessControlAllowOrigin = c.Request.Headers.Origin.ToString();
                    c.Response.Headers.Vary = "Origin";
                }
                await sonraki(c);
            });
            async Task<IResult> Isle(HttpContext c, CancellationToken iptal)
            {
                var ip = c.Connection.RemoteIpAddress;
                if (!servis.IpIzinli(ip)) return Results.StatusCode(StatusCodes.Status403Forbidden);
                var q = c.Request.Query.ToDictionary(x => x.Key, x => x.Value.ToString(), StringComparer.OrdinalIgnoreCase);
                var y = await servis.IsleAsync(q, (ip?.IsIPv4MappedToIPv6 == true ? ip.MapToIPv4() : ip)?.ToString() ?? "", iptal);
                c.Response.Headers.CacheControl = "private, max-age=3600";
                return y.Kod == 200 ? Results.Bytes(y.Govde, y.IcerikTuru) : Results.Text(y.Hata, "text/plain; charset=utf-8", statusCode: y.Kod);
            }
            foreach (var yol in new[] { a.Yol, "/WADO" }.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                uygulama.MapGet(yol, Isle);
                uygulama.MapMethods(yol, ["OPTIONS"], (HttpContext c) =>
                {
                    c.Response.Headers.AccessControlAllowMethods = "GET";
                    c.Response.Headers.AccessControlAllowHeaders = "Accept";
                    return Results.NoContent();
                });
            }
            uygulama.MapFallback(() => Results.NotFound());
            await uygulama.StartAsync(dur);
        }
        catch (Exception h) when (h is not OperationCanceledException)
        {
            gunluk.LogError(h, "Teletıp WADO sunucusu {Port} portunda başlatılamadı.", a.Port);
            return;
        }
        gunluk.LogInformation("Teletıp WADO {Port} portunda ({Tls}) - {Yol}.", a.Port, a.SertifikaYolu.Length > 0 ? "HTTPS" : "HTTP", a.Yol);
        try { await Task.Delay(Timeout.Infinite, dur); }
        catch (OperationCanceledException) { }
        await uygulama.StopAsync(CancellationToken.None);
        await uygulama.DisposeAsync();
    }

    /// <summary>CORS kökeni: yalnız https ve izinli sonekle biten ana bilgisayar (".saglik.gov.tr" ya da tam "saglik.gov.tr").</summary>
    public static bool KokenIzinli(string koken, string[] sonekler) =>
        koken.Length > 0 && Uri.TryCreate(koken, UriKind.Absolute, out var u) && u.Scheme == Uri.UriSchemeHttps
        && sonekler.Any(s => s.Length > 1 && s.StartsWith('.')
                             && (u.Host.EndsWith(s, StringComparison.OrdinalIgnoreCase) || u.Host.Equals(s[1..], StringComparison.OrdinalIgnoreCase)));
}
