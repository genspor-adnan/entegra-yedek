using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using FellowOakDicom;
using FellowOakDicom.Network;
using FellowOakDicom.Network.Client;
using Gentegre.Veri;
using Npgsql;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MWL KARTI (1329; mockup Ekranlar/Ayarlar/entegrasyon_mwl.html §2): dinleyici durumu + şubenin cihazları ve
/// bağlantı testi. Test KAYITLI satırla çalışır: önce dinleyiciler satırlardan yeniden kurulur, sonra bu makinedeki
/// dinleyiciye cihaz gibi bağlanılır (çağıran AE = şubenin kayıtlı bir cihazı - tanımsız AE reddedileceği için).
/// Sınama sorgusu "sessiz": cihazın istemi "gördü" izini ve son sorgu bilgisini yazmaz.
/// </summary>
public static class MwlSinama
{
    private sealed record Satir(int Sube, string Ae, string Port, string Ayarlar, short Aktif);

    private static Task<Satir?> SatirOkuAsync(NpgsqlConnection b, int id, CancellationToken iptal) => b.TekAsync(
        """
        select coalesce(sube_id, 0), coalesce(kullanici_adi, ''), coalesce(uygulama_kodu, ''), coalesce(ayarlar::text, '{}'), aktif
          from public.entegrasyon_hesap where id = @p0 and kod = 'MWL'
        """, null, [id], o => new Satir(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetInt16(4)), iptal);

    /// <summary>Kart üstündeki durum + cihaz tablosu.</summary>
    public static async Task<object> DurumAsync(VeriKaynagi veri, MwlSunucusu mwl, int id, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var s = await SatirOkuAsync(b, id, iptal) ?? throw GentegreHatasi.Bulunamadi("MWL satırı bulunamadı.");
        var d = MwlAyar.Coz(id, s.Sube, s.Ae, s.Port, s.Ayarlar, out var hata);
        var durum = mwl.Durum(id);
        var cihazlar = await b.ListeAsync(
            """
            select c.id, coalesce(c.ad, ''), public.fn_radyoloji_dicom_modalite(c.modalite), upper(trim(coalesce(c.ae_title, ''))),
                   coalesce(c.sube_id, 0),
                   case when coalesce(trim(c.ae_title), '') = '' then null
                        else (select count(*)::int from public.fn_radyoloji_mwl(c.ae_title, '', null, null, '', '', @p0)) end
              from public.radyoloji_cihaz c
             where c.durum = 1 and (@p0 = 0 or coalesce(c.sube_id, 0) in (0, @p0))
             order by c.ad, c.id
            """, null, [s.Sube],
            o => (Id: o.GetInt32(0), Ad: o.GetString(1), Modalite: o.GetString(2), Ae: o.GetString(3), Sube: o.GetInt32(4),
                  Bekleyen: o.IsDBNull(5) ? (int?)null : o.GetInt32(5)), iptal);
        var bilinmeyen = d?.BilinmeyenAe ?? false;
        return new
        {
            calisiyor = mwl.Calisiyor,
            aktif = s.Aktif == 1,
            dinliyor = durum?.Dinliyor,
            mesaj = !mwl.Calisiyor ? "Bu API örneğinde arka plan işleri kapalı - dinleyici burada çalışmıyor."
                  : s.Aktif != 1 ? "Pasif - dinleyici kapalı."
                  : hata is not null ? $"Açılamadı: {hata}"
                  : durum?.Mesaj ?? "Kuruluyor… (birkaç saniye)",
            zaman = durum?.Zaman,
            port = d?.Port,
            ae = d?.Ae ?? s.Ae,
            adresler = Adresler(),
            cihazlar = cihazlar.Select(c =>
            {
                var son = c.Ae.Length > 0 ? mwl.SonSorgu(c.Ae) : null;
                return new
                {
                    c.Id, c.Ad, c.Modalite, c.Ae, c.Bekleyen,
                    sonSorgu = son?.Zaman,
                    sonSayi = son?.Sayi,
                    durum = c.Ae.Length == 0 ? (bilinmeyen ? "AE adı yok · yalnız modalite süzgeci" : "AE adı yok · bağlanamaz")
                          : son is not null ? "bağlandı" : "henüz sorgulamadı",
                    uyari = c.Ae.Length == 0 && !bilinmeyen,
                };
            }),
        };
    }

    /// <summary>Bu makinenin IPv4 adresleri (cihaza "worklist sunucusu" olarak girilecek; Docker'da konteynerin değil sunucunun IP'si).</summary>
    private static string[] Adresler()
    {
        try
        {
            return NetworkInterface.GetAllNetworkInterfaces()
                .Where(n => n.OperationalStatus == OperationalStatus.Up && n.NetworkInterfaceType != NetworkInterfaceType.Loopback)
                .SelectMany(n => n.GetIPProperties().UnicastAddresses)
                .Where(a => a.Address.AddressFamily == AddressFamily.InterNetwork && !IPAddress.IsLoopback(a.Address))
                .Select(a => a.Address.ToString()).Distinct().Take(6).ToArray();
        }
        catch { return []; }
    }

    /// <summary>Dinleyici → C-ECHO → cihaz gibi worklist C-FIND.</summary>
    public static async Task<List<DicomKaynagi.SinamaAdimi>> SinaAsync(NpgsqlConnection b, MwlSunucusu mwl, int id, CancellationToken iptal)
    {
        var adimlar = new List<DicomKaynagi.SinamaAdimi>();
        var s = await SatirOkuAsync(b, id, iptal) ?? throw GentegreHatasi.Bulunamadi("MWL satırı bulunamadı.");
        var d = MwlAyar.Coz(id, s.Sube, s.Ae, s.Port, s.Ayarlar, out var hata);
        if (d is null) { adimlar.Add(new("Ayar", false, hata ?? "geçersiz ayar", 0)); return adimlar; }
        if (s.Aktif != 1) { adimlar.Add(new("Dinleyici", false, "satır pasif - Aktif kutusunu işaretleyip kaydedin", 0)); return adimlar; }
        if (!mwl.Calisiyor)
        {
            adimlar.Add(new("Dinleyici", false,
                "bu API örneğinde arka plan işleri kapalı (ArkaPlan:Kapali) - dinleyici çalışan örnekten sınayın", 0));
            return adimlar;
        }
        await mwl.TazeleAsync(iptal);            // kaydedilen ayar hemen (5 sn beklemeden)
        var durum = mwl.Durum(id);
        if (durum is not { Dinliyor: true })
        {
            adimlar.Add(new($"Dinleyici port {d.Port}", false, durum?.Mesaj ?? "dinleyici kurulamadı", 0));
            return adimlar;
        }
        adimlar.Add(new($"Dinleyici port {d.Port}", true, "açık", 0));

        // Çağıran AE: şubenin AE adı girilmiş ilk cihazı (tanımsız AE reddedilir); "tanımsız cihaz kabul" açıksa sabit test adı.
        var cihazAe = await b.TekDegerAsync<string>(
            """
            select upper(trim(ae_title)) from public.radyoloji_cihaz
             where durum = 1 and coalesce(trim(ae_title), '') <> '' and (@p0 = 0 or coalesce(sube_id, 0) in (0, @p0))
             order by id limit 1
            """, null, [d.Sube], iptal);
        if (string.IsNullOrEmpty(cihazAe))
        {
            if (!d.BilinmeyenAe)
            {
                adimlar.Add(new("C-ECHO", false,
                    "bu şubede AE adı girilmiş cihaz yok - Radyoloji › Cihaz Listesi'nde cihaza AE adı girin (tanımsız AE reddedilir)", 0));
                return adimlar;
            }
            cihazAe = "GENTEGRE_SINA";
        }
        var cagrilan = d.Ae.Length > 0 ? d.Ae : "ANY-SCP";
        mwl.SessizSorgu(d.Port, cihazAe);

        var sw = System.Diagnostics.Stopwatch.StartNew();
        try
        {
            DicomStatus? sonuc = null;
            var echo = new DicomCEchoRequest();
            echo.OnResponseReceived += (_, y) => sonuc = y.Status;
            var istemci = DicomClientFactory.Create("127.0.0.1", d.Port, false, cihazAe, cagrilan);
            await istemci.AddRequestAsync(echo);
            using var z = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            z.CancelAfter(TimeSpan.FromSeconds(10));
            await istemci.SendAsync(z.Token);
            if (sonuc != DicomStatus.Success) throw new InvalidOperationException($"yanıt: {sonuc?.ToString() ?? "yok"}");
            adimlar.Add(new($"C-ECHO {cihazAe} → {cagrilan}", true, "yanıt verdi", sw.ElapsedMilliseconds));
        }
        catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
        {
            adimlar.Add(new($"C-ECHO {cihazAe} → {cagrilan}", false, Acikla(h), sw.ElapsedMilliseconds));
            return adimlar;
        }

        sw.Restart();
        try
        {
            var bulunan = new List<DicomDataset>();
            var q = DicomCFindRequest.CreateWorklistQuery();
            q.OnResponseReceived += (_, y) => { if (y.Status == DicomStatus.Pending && y.HasDataset) bulunan.Add(y.Dataset); };
            var istemci = DicomClientFactory.Create("127.0.0.1", d.Port, false, cihazAe, cagrilan);
            await istemci.AddRequestAsync(q);
            using var z = CancellationTokenSource.CreateLinkedTokenSource(iptal);
            z.CancelAfter(TimeSpan.FromSeconds(20));
            await istemci.SendAsync(z.Token);
            var ornek = bulunan.Select(x => x.GetSingleValueOrDefault(DicomTag.PatientName, "")).FirstOrDefault(x => x.Length > 0);
            adimlar.Add(new("C-FIND worklist (cihaz gibi)", true,
                $"{bulunan.Count} hasta · {cihazAe}" + (ornek is null ? "" : $" · örnek: {ornek.Replace('^', ' ')}"), sw.ElapsedMilliseconds));
        }
        catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
        {
            adimlar.Add(new("C-FIND worklist (cihaz gibi)", false, Acikla(h), sw.ElapsedMilliseconds));
        }
        return adimlar;
    }

    private static string Acikla(Exception h)
    {
        var m = h is OperationCanceledException ? "zaman aşımı" : h.GetBaseException().Message;
        if (m.Contains("Association rejected", StringComparison.OrdinalIgnoreCase))
            m += " → dinleyici bağlantıyı reddetti: AE adı satırla, çağıran cihaz AE'si cihaz kartıyla eşleşmeli.";
        return m;
    }
}
