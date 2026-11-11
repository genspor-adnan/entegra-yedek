using System.Net;
using FellowOakDicom;
using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;

namespace Gentegre.Testler;

/// <summary>
/// TELETIP DIŞA AÇIK WADO (1313): DICOM → JPEG çizici (gri 16 bit, RGB, çok kare, küçültme, pencere), WADO-URI kuralları
/// (XDS kılavuzu 1.15 Tablo 4: 400 / 404 / 406), erişim kuralı (yalnız KOS'u başarıyla gitmiş çalışma + o çalışmanın
/// nesnesi), erişim sayacı, CORS kökeni ve IP izin listesi.
/// </summary>
[Collection("TeletipReferans")]
public sealed class TeletipWadoTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static DicomDataset Gri16(int w, int h, int kare = 1)
    {
        var d = new DicomDataset(DicomTransferSyntax.ExplicitVRLittleEndian);
        d.Add(DicomTag.SOPClassUID, "1.2.840.10008.5.1.4.1.1.2");
        d.Add(DicomTag.SOPInstanceUID, "1.2.3.4.5.6");
        d.Add(DicomTag.PhotometricInterpretation, "MONOCHROME2");
        d.Add(DicomTag.Rows, (ushort)h); d.Add(DicomTag.Columns, (ushort)w);
        d.Add(DicomTag.BitsAllocated, (ushort)16); d.Add(DicomTag.BitsStored, (ushort)12); d.Add(DicomTag.HighBit, (ushort)11);
        d.Add(DicomTag.PixelRepresentation, (ushort)0); d.Add(DicomTag.SamplesPerPixel, (ushort)1);
        if (kare > 1) d.Add(DicomTag.NumberOfFrames, kare.ToString());
        var px = new ushort[w * h * kare];
        for (var i = 0; i < px.Length; i++) px[i] = (ushort)(i / (w * h) * 1000 + i % w * 4000 / w);
        d.Add(DicomVR.OW, DicomTag.PixelData, px);
        return d;
    }

    private static DicomDataset Rgb(int w, int h, byte r, byte g, byte b)
    {
        var d = new DicomDataset(DicomTransferSyntax.ExplicitVRLittleEndian);
        d.Add(DicomTag.SOPClassUID, "1.2.840.10008.5.1.4.1.1.6.1");
        d.Add(DicomTag.SOPInstanceUID, "1.2.3.4.5.7");
        d.Add(DicomTag.PhotometricInterpretation, "RGB");
        d.Add(DicomTag.Rows, (ushort)h); d.Add(DicomTag.Columns, (ushort)w);
        d.Add(DicomTag.BitsAllocated, (ushort)8); d.Add(DicomTag.BitsStored, (ushort)8); d.Add(DicomTag.HighBit, (ushort)7);
        d.Add(DicomTag.PixelRepresentation, (ushort)0); d.Add(DicomTag.SamplesPerPixel, (ushort)3);
        d.Add(DicomTag.PlanarConfiguration, (ushort)0);
        var px = new byte[w * h * 3];
        for (var i = 0; i < w * h; i++) { px[i * 3] = r; px[i * 3 + 1] = g; px[i * 3 + 2] = b; }
        d.Add(DicomVR.OB, DicomTag.PixelData, px);
        return d;
    }

    private static (int W, int H) SofBoyut(byte[] j)
    {
        for (var i = 0; i < j.Length - 9; i++)
            if (j[i] == 0xFF && j[i + 1] == 0xC0) return ((j[i + 7] << 8) | j[i + 8], (j[i + 5] << 8) | j[i + 6]);
        return (0, 0);
    }

    /// <summary>Pillow varsa JPEG'i bağımsız çözdürüp orta pikseli döner; yoksa null.</summary>
    private static string? Pillow(byte[] jpeg)
    {
        var yol = Path.Combine(Path.GetTempPath(), $"gentegre_wado_{Guid.NewGuid():N}.jpg");
        File.WriteAllBytes(yol, jpeg);
        try
        {
            var p = System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("python",
                $"-c \"from PIL import Image; i=Image.open(r'{yol}').convert('RGB'); print(i.size, i.getpixel((i.size[0]//2, i.size[1]//2)))\"")
            { RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false });
            if (p is null) return null;
            var cikti = p.StandardOutput.ReadToEnd(); var hata = p.StandardError.ReadToEnd(); p.WaitForExit(20000);
            if (hata.Contains("No module named", StringComparison.Ordinal) || hata.Contains("not recognized", StringComparison.Ordinal)) return null;
            Assert.True(p.ExitCode == 0, hata);
            return cikti.Trim();
        }
        catch (System.ComponentModel.Win32Exception) { return null; }
        finally { File.Delete(yol); }
    }

    [Fact]
    public void Cizici_tam_boy_gri_ve_kucultme()
    {
        var tam = DicomGoruntuCizici.Ciz(Gri16(301, 200), new CizimIstegi());
        Assert.Equal((301, 200), SofBoyut(tam.Jpeg));                     // tek genişlik de olur (kenar MCU'su)
        Assert.Equal(new byte[] { 0xFF, 0xD8 }, tam.Jpeg[..2]);
        if (Pillow(tam.Jpeg) is { } p) Assert.StartsWith("(301, 200)", p);

        var kucuk = DicomGoruntuCizici.Ciz(Gri16(301, 200), new CizimIstegi(Satir: 100));   // en/boy korunur
        Assert.Equal(100, kucuk.Satir);
        Assert.Equal(150, kucuk.Sutun);                                   // 150,5 → 150 (Math.Round)
        var buyutme = DicomGoruntuCizici.Ciz(Gri16(64, 32), new CizimIstegi(Satir: 512, Sutun: 512));
        Assert.Equal((64, 32), (buyutme.Sutun, buyutme.Satir));           // büyütme yok
    }

    [Fact]
    public void Cizici_RGB_renk_korunur()
    {
        var c = DicomGoruntuCizici.Ciz(Rgb(40, 24, 220, 30, 30), new CizimIstegi());
        Assert.Equal((40, 24), SofBoyut(c.Jpeg));
        if (Pillow(c.Jpeg) is not { } p) return;
        // "(40, 24) (r, g, b)" - kırmızı baskın kalmalı (gri dönüşüm olsaydı r ≈ g ≈ b).
        var rgb = p[(p.LastIndexOf('(') + 1)..^1].Split(',').Select(x => int.Parse(x.Trim())).ToArray();
        Assert.True(rgb[0] > 180 && rgb[1] < 80 && rgb[2] < 80, p);
    }

    [Fact]
    public void Cizici_cok_kare_ve_pencere()
    {
        var d = Gri16(32, 32, kare: 3);
        var k3 = DicomGoruntuCizici.Ciz(d, new CizimIstegi(Kare: 2));
        Assert.Equal((32, 32), SofBoyut(k3.Jpeg));
        Assert.Equal(404, Assert.Throws<CizimHatasi>(() => DicomGoruntuCizici.Ciz(d, new CizimIstegi(Kare: 3))).Kod);
        // Pencere farklı → farklı görüntü.
        var a = DicomGoruntuCizici.Ciz(d, new CizimIstegi(Merkez: 500, Genislik: 200)).Jpeg;
        var b = DicomGoruntuCizici.Ciz(d, new CizimIstegi(Merkez: 3000, Genislik: 4000)).Jpeg;
        Assert.NotEqual(Convert.ToBase64String(a), Convert.ToBase64String(b));
    }

    [Fact]
    public void Cizici_desteklenmeyen_406()
    {
        var d = Rgb(8, 8, 1, 2, 3);
        d.AddOrUpdate(DicomTag.PhotometricInterpretation, "PALETTE COLOR");
        Assert.Equal(406, Assert.Throws<CizimHatasi>(() => DicomGoruntuCizici.Ciz(d, new CizimIstegi())).Kod);
        var bos = new DicomDataset(DicomTransferSyntax.ExplicitVRLittleEndian);
        Assert.Equal(406, Assert.Throws<CizimHatasi>(() => DicomGoruntuCizici.Ciz(bos, new CizimIstegi())).Kod);
    }

    [Fact]
    public void Icerik_turu_koken_ve_ip()
    {
        Assert.Equal(TeletipWadoServisi.Dicom, TeletipWadoServisi.IcerikTuruSec(""));
        Assert.Equal(TeletipWadoServisi.Jpeg, TeletipWadoServisi.IcerikTuruSec("image/jpeg"));
        Assert.Equal(TeletipWadoServisi.Jpeg, TeletipWadoServisi.IcerikTuruSec("application/jpeg"));   // kılavuz metni
        Assert.Equal(TeletipWadoServisi.Jpeg, TeletipWadoServisi.IcerikTuruSec("image/png, image/jpeg"));
        Assert.Null(TeletipWadoServisi.IcerikTuruSec("image/png"));

        string[] s = [".saglik.gov.tr"];
        Assert.True(TeletipWadoSunucusu.KokenIzinli("https://teletip.saglik.gov.tr", s));
        Assert.True(TeletipWadoSunucusu.KokenIzinli("https://saglik.gov.tr", s));
        Assert.False(TeletipWadoSunucusu.KokenIzinli("http://teletip.saglik.gov.tr", s));      // https şart
        Assert.False(TeletipWadoSunucusu.KokenIzinli("https://saglik.gov.tr.kotu.com", s));
        Assert.False(TeletipWadoSunucusu.KokenIzinli("https://kotusaglik.gov.tr", s));

        var acik = Servis(null, new SahtePacs(), []);
        Assert.True(acik.IpIzinli(IPAddress.Parse("8.8.8.8")));
        var sinirli = Servis(null, new SahtePacs(), ["10.0.0.0/8", "193.140.1.5"]);
        Assert.True(sinirli.IpIzinli(IPAddress.Parse("10.2.3.4")));
        Assert.True(sinirli.IpIzinli(IPAddress.Parse("::ffff:193.140.1.5")));
        Assert.False(sinirli.IpIzinli(IPAddress.Parse("193.140.1.6")));
        Assert.False(sinirli.IpIzinli(null));
    }

    private sealed class SahtePacs : IWadoPacs
    {
        public HashSet<string> Nesneler { get; } = new(StringComparer.Ordinal);
        public byte[] Dicom { get; set; } = [];
        public int WadoCagrisi { get; private set; }
        public Task<HashSet<string>> CalismaNesneleriAsync(string studyUid, CancellationToken iptal) => Task.FromResult(Nesneler);
        public Task<HttpResponseMessage> WadoAsync(string studyUid, string seriesUid, string objectUid, CancellationToken iptal)
        {
            WadoCagrisi++;
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent(Dicom) });
        }
    }

    private static TeletipWadoServisi Servis(VeriKaynagi? veri, IWadoPacs pacs, string[] ipler) =>
        new(veri!, pacs, new MemoryCache(new MemoryCacheOptions()),
            Options.Create(new TeletipWadoAyarlari { IzinliIpler = ipler }), NullLogger<TeletipWadoServisi>.Instance);

    [VtFact]
    public async Task WADO_kurallari_ve_erisim_sayaci()
    {
        if (!olgu.Baglandi(nameof(WADO_kurallari_ve_erisim_sayaci))) return;
        var veri = olgu.Gerekli();
        var st = "2.25." + new System.Numerics.BigInteger(Guid.NewGuid().ToByteArray(), true);
        var kapali = "2.25." + new System.Numerics.BigInteger(Guid.NewGuid().ToByteArray(), true);
        const string se = "1.2.3.4.100", ob = "1.2.3.4.100.1";
        var ip = "203.0.113." + Random.Shared.Next(1, 250);
        var pacs = new SahtePacs();
        pacs.Nesneler.Add(se + "|" + ob);
        var f = new DicomFile(Gri16(64, 48)); var m = new MemoryStream(); f.Save(m); pacs.Dicom = m.ToArray();
        var s = Servis(veri, pacs, []);
        Dictionary<string, string> Q(string study, string series, string obj, string tur = "") => new(StringComparer.OrdinalIgnoreCase)
        { ["requestType"] = "WADO", ["studyUID"] = study, ["seriesUID"] = series, ["objectUID"] = obj, ["contentType"] = tur };


        try
        {
            // KOS'u başarıyla gitmiş çalışma (durum 1) + KOS'u REDDEDİLMİŞ çalışma (durum 2).
            await veri.TekDegerAsync<long>(
                "insert into public.teletip_gonderim (kanal, emir, durum, accession_no, study_uid) values (2, 1, 1, 'TT-WADO', @p0) returning id", [st]);
            await veri.CalistirAsync(
                "insert into public.teletip_gonderim (kanal, emir, durum, accession_no, study_uid) values (2, 1, 2, 'TT-WADO', @p0)", [kapali]);

            Assert.Equal(400, (await s.IsleAsync(new Dictionary<string, string> { ["requestType"] = "WADO", ["studyUID"] = st }, ip, default)).Kod);
            Assert.Equal(400, (await s.IsleAsync(Q(st, se, "1.2.abc"), ip, default)).Kod);
            Assert.Equal(400, (await s.IsleAsync(new Dictionary<string, string>(Q(st, se, ob)) { ["requestType"] = "X" }, ip, default)).Kod);
            Assert.Equal(406, (await s.IsleAsync(Q(st, se, ob, "image/png"), ip, default)).Kod);
            Assert.Equal(404, (await s.IsleAsync(Q(kapali, se, ob), ip, default)).Kod);                 // KOS reddedilmiş
            Assert.Equal(404, (await s.IsleAsync(Q(st, se, "1.2.3.4.100.2"), ip, default)).Kod);         // çalışmada yok
            Assert.Equal(0, pacs.WadoCagrisi);                                                           // PACS'a hiç gidilmedi

            var dcm = await s.IsleAsync(Q(st, se, ob), ip, default);                                     // contentType boş → DICOM
            Assert.Equal(200, dcm.Kod);
            Assert.Equal("application/dicom", dcm.IcerikTuru);
            Assert.Equal(pacs.Dicom.Length, dcm.Govde.Length);
            var jpg = await s.IsleAsync(new Dictionary<string, string>(Q(st, se, ob, "image/jpeg")) { ["rows"] = "24" }, ip, default);
            Assert.Equal(200, jpg.Kod);
            Assert.Equal("image/jpeg", jpg.IcerikTuru);
            Assert.Equal((32, 24), SofBoyut(jpg.Govde));
            Assert.Equal(404, (await s.IsleAsync(new Dictionary<string, string>(Q(st, se, ob, "image/jpeg")) { ["frameNumber"] = "2" }, ip, default)).Kod);

            var sayac = await veri.TekAsync(
                "select istek_sayisi, hata_sayisi, son_hata from public.teletip_wado_erisim where ip = @p0 and study_uid = @p1", [ip, st],
                o => Tuple.Create(o.GetInt32(0), o.GetInt32(1), o.GetString(2)));
            Assert.NotNull(sayac);
            Assert.Equal(8, sayac!.Item1);                      // st ile 8 istek (5 hata + 2 başarı + kare yok)
            Assert.Equal(6, sayac.Item2);
            Assert.StartsWith("404", sayac.Item3);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.teletip_gonderim where accession_no = 'TT-WADO' and study_uid in (@p0, @p1)", [st, kapali]);
            await veri.CalistirAsync("delete from public.teletip_wado_erisim where ip = @p0", [ip]);
        }
    }
}
