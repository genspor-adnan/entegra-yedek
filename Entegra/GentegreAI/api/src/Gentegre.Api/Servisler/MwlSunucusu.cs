using System.Globalization;
using System.Text;
using FellowOakDicom;
using FellowOakDicom.Network;
using Gentegre.Veri;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

/// <summary>
/// MODALITY WORKLIST (MWL) SUNUCUSU (1301; kullanıcı 11.11.2026: "amacımız Sağlık Bakanlığı'nın istediği şekilde
/// Teletıp'a verileri görüntülemek" → "MWL ile başla").
///
/// <para><b>Neden:</b> Bakanlık (Teleradyoloji Entegrasyon Kılavuzu 3.43 § 5.2) görüntüyü isteme yalnız
/// DICOM AccessionNumber == HL7 accession ve PatientID == TCKN (ya da dosya no) ise bağlar. Tekniker cihaza elle
/// yazarsa tutmaz. Cihaz çalışma listesini bizden C-FIND ile çeker; etiketler istemden birebir gelir.</para>
///
/// <para><b>Kural DB'de</b> (<c>fn_radyoloji_mwl</c>): hangi istem listede, hangi cihaza. Burada yalnız DICOM'a
/// çevrilir (<see cref="MwlCevirici"/>).</para>
///
/// <para><b>Ayar entegrasyon ekranından, şube başına (1329; mockup Ekranlar/Ayarlar/entegrasyon_mwl.html):</b>
/// <c>entegrasyon_hesap</c> kod = MWL satırları - kullanıcı adı = AE adı, uygulama kodu = port, ayarlar = karakter seti ·
/// tanımsız cihaz · tarih penceresi. Port başına TEK dinleyici; aynı porttaki satırlar çağrılan AE ile ayrılır
/// (<see cref="MwlAyar.Sec"/>). Satırlar 5 sn'de bir imzayla (yalnız ayar sütunları - durum yazımı imzayı değiştirmez)
/// kontrol edilir; değişince eksik portlar açılır, kalkanlar kapanır - API yeniden başlatılmaz. Hiç MWL satırı yoksa
/// eski davranış: appsettings › Dicom:MwlPort (kurum geneli, tek dinleyici).</para>
///
/// <para><b>Cihaz kimliği:</b> çağıran AE başlığı <c>radyoloji_cihaz.ae_title</c> ile tanınır; tanınmayan AE
/// bağlantısı reddedilir (satırda "tanımsız cihaz kabul" açıksa kabul edilir, yalnız modalite + şube süzgeci).</para>
/// </summary>
public sealed class MwlSunucusu(IOptions<DicomAyarlari> ayar, VeriKaynagi veri, ILogger<MwlSunucusu> gunluk) : BackgroundService
{
    private static readonly TimeSpan Aralik = TimeSpan.FromSeconds(5);
    private readonly Dictionary<int, IDicomServer> _sunucular = [];
    private volatile IReadOnlyList<MwlDinleyici> _satirlar = [];
    private readonly System.Collections.Concurrent.ConcurrentDictionary<int, MwlDurum> _durum = new();
    private readonly System.Collections.Concurrent.ConcurrentDictionary<string, (DateTime Zaman, int Sayi)> _sorgular =
        new(StringComparer.OrdinalIgnoreCase);
    private readonly System.Collections.Concurrent.ConcurrentDictionary<string, DateTime> _sessiz = new(StringComparer.OrdinalIgnoreCase);
    private string? _imza;

    internal VeriKaynagi Veri => veri;
    internal ILogger Gunluk => gunluk;

    /// <summary>Arka plan işleri bu API örneğinde çalışıyor mu (testlerde / ad-hoc kopyada kapalı).</summary>
    public bool Calisiyor { get; private set; }

    /// <summary>Satırın dinleyici durumu (null = henüz kurulmadı / satır aktif değil).</summary>
    public MwlDurum? Durum(int id) => _durum.TryGetValue(id, out var d) ? d : null;

    /// <summary>Cihazın (çağıran AE) son sorgusu - bellekte; API yeniden başlayınca sıfırlanır.</summary>
    public (DateTime Zaman, int Sayi)? SonSorgu(string ae) => _sorgular.TryGetValue(ae.Trim(), out var s) ? s : null;

    /// <summary>Sınama: bu port + çağıran AE çiftinin sorguları 60 sn iz / son sorgu yazmaz (cihaz "gördü" sayılmasın).</summary>
    public void SessizSorgu(int port, string cagiranAe) => _sessiz[$"{port}|{cagiranAe.Trim()}"] = DateTime.UtcNow.AddSeconds(60);

    internal bool SessizMi(int port, string cagiranAe) =>
        _sessiz.TryGetValue($"{port}|{cagiranAe.Trim()}", out var bitis) && bitis > DateTime.UtcNow;

    internal IReadOnlyList<MwlDinleyici> PorttakiSatirlar(int port) => _satirlar.Where(s => s.Port == port).ToList();

    internal void SorguKaydet(string cagiranAe, int sayi) => _sorgular[cagiranAe.Trim()] = (DateTime.Now, sayi);

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        Calisiyor = true;
        while (!dur.IsCancellationRequested)
        {
            try { await TazeleAsync(dur); }
            catch (Exception h) when (h is not OperationCanceledException) { gunluk.LogWarning(h, "MWL ayarları okunamadı; son ayarla devam."); }
            try { await Task.Delay(Aralik, dur); } catch (OperationCanceledException) { break; }
        }
    }

    /// <summary>Satırları okur; imza değiştiyse dinleyicileri yeniden kurar.</summary>
    public async Task TazeleAsync(CancellationToken iptal = default)
    {
        var imza = await veri.TekDegerAsync<string>("""
            select coalesce(md5(string_agg(concat_ws('|', id, coalesce(sube_id, 0), aktif, kullanici_adi, uygulama_kodu, ayarlar::text),
                                           ',' order by id)), '')
              from public.entegrasyon_hesap where kod = 'MWL'
            """, null, iptal) ?? "";
        if (imza == _imza) return;
        var satirlar = await veri.ListeAsync("""
            select id, coalesce(sube_id, 0), coalesce(kullanici_adi, ''), coalesce(uygulama_kodu, ''), coalesce(ayarlar::text, '{}')
              from public.entegrasyon_hesap
             where kod = 'MWL' and aktif = 1
             order by id
            """, null, o => (Id: o.GetInt32(0), Sube: o.GetInt32(1), Ae: o.GetString(2), Port: o.GetString(3), Ayarlar: o.GetString(4)), iptal);
        var gecerli = new List<MwlDinleyici>();
        var hatalar = new Dictionary<int, string>();
        foreach (var s in satirlar)
        {
            var d = MwlAyar.Coz(s.Id, s.Sube, s.Ae, s.Port, s.Ayarlar, out var hata);
            if (d is null) hatalar[s.Id] = hata ?? "geçersiz ayar";
            else if (gecerli.Any(x => x.Port == d.Port && string.Equals(x.Ae, d.Ae, StringComparison.OrdinalIgnoreCase)))
                hatalar[s.Id] = $"port {d.Port} + AE {d.Ae} başka bir satırda da var";
            else gecerli.Add(d);
        }
        // Eski kurulum: hiç MWL satırı yoksa dosyadaki tek dinleyici (kurum geneli).
        var a = ayar.Value;
        if (satirlar.Count == 0 && a.MwlPort > 0)
            gecerli.Add(new MwlDinleyici(0, 0, a.MwlPort, (a.MwlAe ?? "").Trim().ToUpperInvariant(),
                string.IsNullOrWhiteSpace(a.MwlKarakterSeti) ? "ISO_IR 148" : a.MwlKarakterSeti, a.MwlBilinmeyenAe, 0));

        Uygula(gecerli, hatalar);
        _imza = imza;
        await DurumYazAsync(satirlar.Select(s => s.Id), iptal);
    }

    private void Uygula(List<MwlDinleyici> gecerli, Dictionary<int, string> hatalar)
    {
        lock (_sunucular)
        {
            var portlar = gecerli.Select(s => s.Port).ToHashSet();
            foreach (var p in _sunucular.Keys.Where(p => !portlar.Contains(p)).ToList())
            {
                try { _sunucular[p].Stop(); _sunucular[p].Dispose(); } catch (Exception h) { gunluk.LogWarning(h, "MWL: port {Port} kapatılamadı.", p); }
                _sunucular.Remove(p);
                gunluk.LogInformation("MWL: port {Port} kapatıldı.", p);
            }
            var acilamayan = new Dictionary<int, string>();
            foreach (var p in portlar.Where(p => !_sunucular.ContainsKey(p)))
            {
                try
                {
                    // PORT DOLU MU: Windows'ta fo-dicom dolu porta da "bağlanır" (adres paylaşımı) ve hata vermez - gelen
                    //   bağlantı öteki uygulamaya gider, dinleyici sessizce ölü kalır. Önce dışlayıcı bağlanma denenir.
                    if (!PortBos(p)) throw new System.Net.Sockets.SocketException((int)System.Net.Sockets.SocketError.AddressAlreadyInUse);
                    var s = DicomServerFactory.Create<MwlHizmeti>(p, userState: new MwlBaglami(this, p));
                    // fo-dicom dinlemeyi ARKA PLANDA açar: port doluysa hata sonradan Exception özelliğine düşer, Create
                    //   hata atmaz. Dinlemeye geçene ya da hata düşene kadar en çok 2 sn beklenir.
                    for (var i = 0; i < 40 && !s.IsListening && s.Exception is null; i++) Thread.Sleep(50);
                    if (s.Exception is not null || !s.IsListening)
                    {
                        var hata = s.Exception ?? new InvalidOperationException("dinlemeye geçmedi");
                        try { s.Stop(); s.Dispose(); } catch { /* yarım açılmış */ }
                        throw hata;
                    }
                    _sunucular[p] = s;
                    gunluk.LogInformation("MWL sunucusu dinliyor: port {Port}.", p);
                }
                catch (Exception h)
                {
                    var soket = h as System.Net.Sockets.SocketException ?? h.GetBaseException() as System.Net.Sockets.SocketException;
                    var m = soket?.SocketErrorCode == System.Net.Sockets.SocketError.AddressAlreadyInUse
                        ? $"port {p} başka bir uygulamada kullanılıyor"
                        : $"port {p} açılamadı: {h.GetBaseException().Message}";
                    acilamayan[p] = m;
                    gunluk.LogError(h, "MWL: {Mesaj}", m);
                }
            }
            _satirlar = gecerli.Where(s => !acilamayan.ContainsKey(s.Port)).ToList();
            var simdi = DateTime.Now;
            _durum.Clear();
            foreach (var s in gecerli)
                _durum[s.Id] = acilamayan.TryGetValue(s.Port, out var m)
                    ? new MwlDurum(false, $"Açılamadı: {m}", simdi)
                    : new MwlDurum(true, $"Dinliyor · port {s.Port} · AE {(s.Ae.Length > 0 ? s.Ae : "(her AE)")}", simdi);
            foreach (var (id, m) in hatalar) _durum[id] = new MwlDurum(false, $"Açılamadı: {m}", simdi);
        }
    }

    /// <summary>Port başka bir uygulamada değil mi (dışlayıcı bağlanma denemesi; Linux'ta düz bağlanma zaten dışlayıcı).</summary>
    private static bool PortBos(int port)
    {
        try
        {
            var l = new System.Net.Sockets.TcpListener(System.Net.IPAddress.Any, port);
            if (OperatingSystem.IsWindows()) l.ExclusiveAddressUse = true;
            l.Start();
            l.Stop();
            return true;
        }
        catch (System.Net.Sockets.SocketException) { return false; }
    }

    /// <summary>Durum satırın Son Sonuç'una (listede görünsün). İmza ayar sütunlarından - bu yazım dinleyiciyi yeniden kurdurmaz.</summary>
    private async Task DurumYazAsync(IEnumerable<int> idler, CancellationToken iptal)
    {
        foreach (var id in idler)
        {
            if (!_durum.TryGetValue(id, out var d)) continue;
            try
            {
                await veri.CalistirAsync("""
                    update public.entegrasyon_hesap set son_kullanim = (now())::timestamp, son_sonuc = left(@p1, 300)
                     where id = @p0 and son_sonuc is distinct from left(@p1, 300)
                    """, [id, d.Mesaj], iptal);
            }
            catch (Exception h) when (h is not OperationCanceledException) { gunluk.LogWarning(h, "MWL: durum yazılamadı ({Id}).", id); }
        }
    }

    public override async Task StopAsync(CancellationToken iptal)
    {
        lock (_sunucular)
        {
            foreach (var s in _sunucular.Values) { try { s.Stop(); s.Dispose(); } catch { /* kapanış */ } }
            _sunucular.Clear();
        }
        await base.StopAsync(iptal);
    }
}

/// <summary>Bir MWL dinleyici satırı (entegrasyon_hesap kod = MWL ya da dosya; Id 0 = dosya).</summary>
public sealed record MwlDinleyici(int Id, int Sube, int Port, string Ae, string KarakterSeti, bool BilinmeyenAe, int PencereGun);

/// <summary>Satırın dinleyici durumu.</summary>
public sealed record MwlDurum(bool Dinliyor, string Mesaj, DateTime Zaman);

/// <summary>MWL satırı çözümü ve bağlantı yönlendirmesi - saf, testli.</summary>
public static class MwlAyar
{
    /// <summary>Satırdan dinleyici; port 1..65535, AE en çok 16 karakter (DICOM AE). Bozuksa null + hata.</summary>
    public static MwlDinleyici? Coz(int id, int sube, string ae, string port, string ayarlarJson, out string? hata)
    {
        hata = null;
        if (!int.TryParse((port ?? "").Trim(), out var p) || p is < 1 or > 65535) { hata = $"geçersiz port '{port}'"; return null; }
        var a = (ae ?? "").Trim().ToUpperInvariant();
        if (a.Length > 16) { hata = $"AE adı en çok 16 karakter ('{a}')"; return null; }
        string kSet = "ISO_IR 148"; bool bilinmeyen = false; int pencere = 0;
        try
        {
            using var j = System.Text.Json.JsonDocument.Parse(string.IsNullOrWhiteSpace(ayarlarJson) ? "{}" : ayarlarJson);
            var k = j.RootElement;
            if (k.ValueKind == System.Text.Json.JsonValueKind.Object)
            {
                if (k.TryGetProperty("karakterSeti", out var ks) && ks.ValueKind == System.Text.Json.JsonValueKind.String
                    && !string.IsNullOrWhiteSpace(ks.GetString())) kSet = ks.GetString()!.Trim();
                if (k.TryGetProperty("bilinmeyenAe", out var b))
                    bilinmeyen = b.ValueKind == System.Text.Json.JsonValueKind.True
                                 || (b.ValueKind == System.Text.Json.JsonValueKind.Number && b.GetInt32() != 0);
                if (k.TryGetProperty("pencereGun", out var g))
                    pencere = g.ValueKind == System.Text.Json.JsonValueKind.Number ? Math.Clamp(g.GetInt32(), 0, 30)
                            : int.TryParse(g.GetString(), out var x) ? Math.Clamp(x, 0, 30) : 0;
            }
        }
        catch (System.Text.Json.JsonException) { /* bozuk ayar: varsayılanlar */ }
        return new MwlDinleyici(id, sube, p, a, kSet, bilinmeyen, pencere);
    }

    /// <summary>Gelen bağlantının satırı: çağrılan AE'si tam eşleşen satır; yoksa AE'si boş ("her AE") satır; yoksa null (red).</summary>
    public static MwlDinleyici? Sec(IReadOnlyList<MwlDinleyici> porttakiler, string? cagrilanAe)
    {
        var c = (cagrilanAe ?? "").Trim();
        return porttakiler.FirstOrDefault(s => s.Ae.Length > 0 && string.Equals(s.Ae, c, StringComparison.OrdinalIgnoreCase))
            ?? porttakiler.FirstOrDefault(s => s.Ae.Length == 0);
    }
}

/// <summary>fo-dicom hizmetine geçen bağımlılıklar (DicomServerFactory DI'sız kurar; userState ile taşınır).</summary>
public sealed record MwlBaglami(MwlSunucusu Sunucu, int Port);

/// <summary>Bir DICOM bağlantısı: C-ECHO (bağlantı testi) + Modality Worklist C-FIND.</summary>
public sealed class MwlHizmeti(INetworkStream akis, Encoding yedekKodlama, ILogger gunluk, DicomServiceDependencies bagimlilik)
    : DicomService(akis, yedekKodlama, gunluk, bagimlilik), IDicomServiceProvider, IDicomCFindProvider, IDicomCEchoProvider
{
    private MwlBaglami B => (MwlBaglami)UserState;
    private string _cagiranAe = "";
    private MwlDinleyici? _satir;
    private MwlDinleyici Satir => _satir ?? throw new InvalidOperationException("MWL: bağlantı satırı yok.");

    private static readonly DicomTransferSyntax[] Sozdizimleri =
        [DicomTransferSyntax.ExplicitVRLittleEndian, DicomTransferSyntax.ImplicitVRLittleEndian];

    public async Task OnReceiveAssociationRequestAsync(DicomAssociation bag)
    {
        _cagiranAe = (bag.CallingAE ?? "").Trim();
        _satir = MwlAyar.Sec(B.Sunucu.PorttakiSatirlar(B.Port), bag.CalledAE);
        if (_satir is null)
        {
            B.Sunucu.Gunluk.LogWarning("MWL: port {Port} çağrılan AE '{Ae}' tanımlı değil; reddedildi.", B.Port, bag.CalledAE);
            await SendAssociationRejectAsync(DicomRejectResult.Permanent, DicomRejectSource.ServiceUser, DicomRejectReason.CalledAENotRecognized);
            return;
        }
        if (!_satir.BilinmeyenAe && !await CihazTanidikMiAsync(_cagiranAe))
        {
            B.Sunucu.Gunluk.LogWarning("MWL: tanınmayan cihaz AE '{Ae}' ({Ip}); reddedildi - radyoloji cihaz kartına AE başlığı girilmeli.",
                _cagiranAe, bag.RemoteHost);
            await SendAssociationRejectAsync(DicomRejectResult.Permanent, DicomRejectSource.ServiceUser, DicomRejectReason.CallingAENotRecognized);
            return;
        }
        foreach (var pc in bag.PresentationContexts)
        {
            if (pc.AbstractSyntax == DicomUID.ModalityWorklistInformationModelFind || pc.AbstractSyntax == DicomUID.Verification)
                pc.AcceptTransferSyntaxes(Sozdizimleri);
            else
                pc.SetResult(DicomPresentationContextResult.RejectAbstractSyntaxNotSupported);
        }
        await SendAssociationAcceptAsync(bag);
    }

    private async Task<bool> CihazTanidikMiAsync(string ae)
    {
        if (ae.Length == 0) return false;
        try
        {
            return await B.Sunucu.Veri.TekDegerAsync<bool>(
                "select exists (select 1 from public.radyoloji_cihaz where durum = 1 and upper(trim(ae_title)) = upper(@p0))", [ae]);
        }
        catch (Exception h)
        {
            B.Sunucu.Gunluk.LogError(h, "MWL: cihaz sorgusu başarısız.");
            return false;
        }
    }

    public Task OnReceiveAssociationReleaseRequestAsync() => SendAssociationReleaseResponseAsync();
    public void OnReceiveAbort(DicomAbortSource kaynak, DicomAbortReason neden) { }
    public void OnConnectionClosed(Exception? hata) { }
    public Task<DicomCEchoResponse> OnCEchoRequestAsync(DicomCEchoRequest istek) =>
        Task.FromResult(new DicomCEchoResponse(istek, DicomStatus.Success));

    public async IAsyncEnumerable<DicomCFindResponse> OnCFindRequestAsync(DicomCFindRequest istek)
    {
        // UID nesnesi ağdan çözülünce ayrı örnek; değerle karşılaştır (== referans karşılaştırır).
        if (istek.SOPClassUID?.UID != DicomUID.ModalityWorklistInformationModelFind.UID)
        {
            yield return new DicomCFindResponse(istek, DicomStatus.QueryRetrieveIdentifierDoesNotMatchSOPClass);
            yield break;
        }
        var sorgu = MwlCevirici.SorguOku(istek.Dataset);
        // Cihaz tarih sormazsa satırın penceresi (bugün ± N gün; 0 = süzgeç yok).
        if (sorgu.Baslangic is null && sorgu.Bitis is null && Satir.PencereGun > 0)
            sorgu = sorgu with { Baslangic = DateTime.Today.AddDays(-Satir.PencereGun), Bitis = DateTime.Today.AddDays(Satir.PencereGun) };
        List<MwlSatiri> satirlar;
        DicomStatus? hata = null;
        try
        {
            satirlar = await B.Sunucu.Veri.ListeAsync(
                "select * from public.fn_radyoloji_mwl(@p0, @p1, @p2::date, @p3::date, @p4, @p5, @p6)",
                [Satir.BilinmeyenAe && !await CihazTanidikMiAsync(_cagiranAe) ? "" : _cagiranAe,
                 sorgu.Modalite, sorgu.Baslangic, sorgu.Bitis, sorgu.Accession, sorgu.HastaId, Satir.Sube],
                MwlCevirici.SatirOku);
        }
        catch (Exception h)
        {
            B.Sunucu.Gunluk.LogError(h, "MWL: iş listesi okunamadı (AE {Ae}).", _cagiranAe);
            satirlar = [];
            hata = DicomStatus.ProcessingFailure;
        }
        if (hata is not null) { yield return new DicomCFindResponse(istek, hata); yield break; }

        var kodlama = Satir.KarakterSeti;
        var adDesen = sorgu.HastaAdi;
        foreach (var s in satirlar)
        {
            if (!MwlCevirici.AdUyar(adDesen, s)) continue;
            var yanit = new DicomCFindResponse(istek, DicomStatus.Pending)
            {
                Dataset = MwlCevirici.Kumeye(s, istek.Dataset, kodlama, _cagiranAe),
            };
            yield return yanit;
        }
        var donen = satirlar.Where(s => MwlCevirici.AdUyar(adDesen, s)).ToList();
        if (!B.Sunucu.SessizMi(B.Port, _cagiranAe))     // sınama sorgusu cihazın "gördü" izini yazmaz
        {
            B.Sunucu.SorguKaydet(_cagiranAe, donen.Count);
            await IzYazAsync(donen);
        }
        yield return new DicomCFindResponse(istek, DicomStatus.Success);
    }

    /// <summary>radyoloji_pacs_olay: cihaz istemi İLK gördüğünde bir kez (olay 1, yön 1) - cihazlar dakikada bir sorar.</summary>
    private async Task IzYazAsync(List<MwlSatiri> satirlar)
    {
        if (satirlar.Count == 0) return;
        try
        {
            foreach (var s in satirlar)
                await B.Sunucu.Veri.CalistirAsync(
                    """
                    insert into public.radyoloji_pacs_olay (istem_id, accession_no, olay, yon, cihaz_id, ae_title, sonuc, mesaj)
                    values (@p0, @p1, 1, 1, (select id from public.radyoloji_cihaz where durum = 1 and upper(trim(ae_title)) = upper(@p2) order by id limit 1),
                            upper(@p2), 1, 'MWL: cihaz çalışma listesinde gördü')
                    on conflict (istem_id, ae_title) where olay = 1 and yon = 1 do nothing
                    """, [s.IstemId, s.Accession, _cagiranAe]);
        }
        catch (Exception h)
        {
            B.Sunucu.Gunluk.LogWarning(h, "MWL: iz yazılamadı.");
        }
    }
}

/// <summary>fn_radyoloji_mwl satırı.</summary>
public sealed record MwlSatiri(
    int IstemId, string Accession, string Modalite, DateTime? YerelZaman,
    string Tckn, string DosyaNo, string Soyad, string Ad, DateTime? DogumTarihi, string Cinsiyet,
    string HizmetKod, string HizmetAd, string SutKodu, string Loinc,
    string HekimSoyad, string HekimAd, string HekimUnvan, string CihazAe, int Oncelik, string KlinikBilgi);

/// <summary>Gelen MWL sorgusunun süzgeçleri.</summary>
public sealed record MwlSorgusu(string Modalite, DateTime? Baslangic, DateTime? Bitis, string Accession, string HastaId, string HastaAdi);

/// <summary>
/// MWL ↔ DICOM çevirisi - saf, testli. Bakanlık kuralı burada: PatientID = geçerli TCKN, yoksa dosya no;
/// OtherPatientIDs = dosya no (TCKN kullanıldıysa). Böylece kılavuz § 5.2'nin iki yolu da tutar.
/// </summary>
public static class MwlCevirici
{
    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public static MwlSatiri SatirOku(Npgsql.NpgsqlDataReader o) => new(
        o.Sayi("istem_id"), o.Metin("accession_no"), o.Metin("modalite"), o.Tarih("yerel_zaman"),
        o.Metin("hasta_tckn"), o.Metin("hasta_dosya_no"), o.Metin("hasta_soyad"), o.Metin("hasta_ad"),
        o.Tarih("dogum_tarihi"), o.Metin("cinsiyet"),
        o.Metin("hizmet_kod"), o.Metin("hizmet_ad"), o.Metin("sut_kodu"), o.Metin("loinc"),
        o.Metin("hekim_soyad"), o.Metin("hekim_ad"), o.Metin("hekim_unvan"), o.Metin("cihaz_ae"),
        o.IsDBNull(o.GetOrdinal("oncelik")) ? 0 : Convert.ToInt32(o.GetValue(o.GetOrdinal("oncelik"))),
        o.Metin("klinik_bilgi"));

    public static MwlSorgusu SorguOku(DicomDataset? d)
    {
        d ??= new DicomDataset();
        var sps = d.TryGetSequence(DicomTag.ScheduledProcedureStepSequence, out var dizi) && dizi.Items.Count > 0
            ? dizi.Items[0] : new DicomDataset();
        var modalite = Joker(sps.GetSingleValueOrDefault(DicomTag.Modality, ""));
        var (bas, bit) = TarihAraligi(sps.GetSingleValueOrDefault(DicomTag.ScheduledProcedureStepStartDate, ""));
        return new MwlSorgusu(modalite, bas, bit,
            Joker(d.GetSingleValueOrDefault(DicomTag.AccessionNumber, "")),
            Joker(d.GetSingleValueOrDefault(DicomTag.PatientID, "")),
            d.GetSingleValueOrDefault(DicomTag.PatientName, "").Trim());
    }

    /// <summary>Tam değer değilse ('*', '?', boş) süzgeç yok - cihazlar çoğu alanı joker gönderir.</summary>
    private static string Joker(string v)
    {
        v = (v ?? "").Trim();
        return v.Length == 0 || v.Contains('*') || v.Contains('?') ? "" : v;
    }

    /// <summary>DICOM DA aralığı: "20261111", "20261111-20261112", "-20261112", "20261111-".</summary>
    public static (DateTime? bas, DateTime? bit) TarihAraligi(string v)
    {
        v = (v ?? "").Trim();
        if (v.Length == 0 || v.Contains('*')) return (null, null);
        static DateTime? Oku(string s) => DateTime.TryParseExact(s.Trim(), "yyyyMMdd", CultureInfo.InvariantCulture,
            DateTimeStyles.None, out var t) ? t.Date : null;
        var i = v.IndexOf('-');
        if (i < 0) { var t = Oku(v); return (t, t); }
        return (Oku(v[..i]), Oku(v[(i + 1)..]));
    }

    /// <summary>PatientName joker eşleşmesi (DICOM: * ve ?, büyük-küçük harf duyarsız; "^" ayraç). Boş/"*" = hepsi.</summary>
    public static bool AdUyar(string desen, MwlSatiri s)
    {
        desen = (desen ?? "").Trim();
        if (desen.Length == 0 || desen == "*") return true;
        var ad = HastaAdi(s);
        var re = "^" + System.Text.RegularExpressions.Regex.Escape(desen.ToUpper(Tr))
                         .Replace("\\*", ".*").Replace("\\?", ".") + "$";
        return System.Text.RegularExpressions.Regex.IsMatch(ad.ToUpper(Tr), re)
            || System.Text.RegularExpressions.Regex.IsMatch(Ascii(ad.ToUpper(Tr)), Ascii(re));
    }

    public static string HastaAdi(MwlSatiri s) => $"{s.Soyad.Trim().ToUpper(Tr)}^{s.Ad.Trim().ToUpper(Tr)}";

    /// <summary>Bakanlık § 5.2: PatientID geçerli TCKN ise TCKN, değilse hasta dosya no.</summary>
    public static string HastaKimligi(MwlSatiri s) => s.Tckn.Length == 11 ? s.Tckn : s.DosyaNo;

    /// <summary>Türkçe harfleri ASCII'ye indirger (eski cihaz "ASCII" karakter setiyle çalışırsa).</summary>
    public static string Ascii(string v) => new(v.Select(c => c switch
    {
        'Ç' => 'C', 'ç' => 'c', 'Ğ' => 'G', 'ğ' => 'g', 'İ' => 'I', 'ı' => 'i', 'Ö' => 'O', 'ö' => 'o',
        'Ş' => 'S', 'ş' => 's', 'Ü' => 'U', 'ü' => 'u', _ => c,
    }).ToArray());

    /// <summary>
    /// Yanıt kümesi. Cihazın istediği etiketlerle sınırlı kalmaz - MWL'de yaygın uygulama tüm bilinen alanları
    /// döndürmektir; cihaz tanımadığını yok sayar. Karakter seti: "ISO_IR 148" (Latin-5, Türkçe), "ISO_IR 192"
    /// (UTF-8) ya da "ASCII" (Türkçe harfler indirgenir; eski cihazlar).
    /// </summary>
    public static DicomDataset Kumeye(MwlSatiri s, DicomDataset? istek, string karakterSeti, string cagiranAe)
    {
        var ascii = string.Equals(karakterSeti, "ASCII", StringComparison.OrdinalIgnoreCase);
        string M(string v) => ascii ? Ascii(v) : v;
        var d = new DicomDataset().NotValidated();
        if (!ascii) d.AddOrUpdate(DicomTag.SpecificCharacterSet, string.IsNullOrWhiteSpace(karakterSeti) ? "ISO_IR 148" : karakterSeti);

        var hekim = $"{M(s.HekimSoyad.ToUpper(Tr))}^{M(s.HekimAd.ToUpper(Tr))}^^{M(s.HekimUnvan)}".TrimEnd('^');
        var zaman = s.YerelZaman ?? DateTime.Now;
        var aciklama = M(s.HizmetAd);

        d.AddOrUpdate(DicomTag.AccessionNumber, s.Accession);
        d.AddOrUpdate(DicomTag.PatientName, M(HastaAdi(s)));
        d.AddOrUpdate(DicomTag.PatientID, HastaKimligi(s));
        d.AddOrUpdate(DicomTag.IssuerOfPatientID, s.Tckn.Length == 11 ? "TC" : "HBYS");
        if (s.Tckn.Length == 11 && s.DosyaNo.Length > 0) d.AddOrUpdate(DicomTag.OtherPatientIDsRETIRED, s.DosyaNo);
        d.AddOrUpdate(DicomTag.PatientBirthDate, s.DogumTarihi?.ToString("yyyyMMdd", CultureInfo.InvariantCulture) ?? "");
        d.AddOrUpdate(DicomTag.PatientSex, s.Cinsiyet);
        d.AddOrUpdate(DicomTag.ReferringPhysicianName, hekim);
        d.AddOrUpdate(DicomTag.RequestingPhysician, hekim);
        d.AddOrUpdate(DicomTag.RequestedProcedureID, s.Accession);
        d.AddOrUpdate(DicomTag.RequestedProcedureDescription, aciklama);
        d.AddOrUpdate(DicomTag.RequestedProcedurePriority, s.Oncelik > 1 ? "STAT" : s.Oncelik == 1 ? "HIGH" : "ROUTINE");
        d.AddOrUpdate(DicomTag.StudyInstanceUID, "");   // cihaz kendi üretir; eşleşme accession ile (1301 başlığı)
        d.AddOrUpdate(DicomTag.AdmittingDiagnosesDescription, M(s.KlinikBilgi));
        if (s.SutKodu.Length > 0)
            d.AddOrUpdate(new DicomSequence(DicomTag.RequestedProcedureCodeSequence, Kod(s.SutKodu, "SUT", aciklama)));

        var adim = new DicomDataset().NotValidated();
        adim.AddOrUpdate(DicomTag.Modality, s.Modalite);
        adim.AddOrUpdate(DicomTag.ScheduledStationAETitle, s.CihazAe.Length > 0 ? s.CihazAe : cagiranAe);
        adim.AddOrUpdate(DicomTag.ScheduledProcedureStepStartDate, zaman.ToString("yyyyMMdd", CultureInfo.InvariantCulture));
        adim.AddOrUpdate(DicomTag.ScheduledProcedureStepStartTime, zaman.ToString("HHmmss", CultureInfo.InvariantCulture));
        adim.AddOrUpdate(DicomTag.ScheduledPerformingPhysicianName, "");
        adim.AddOrUpdate(DicomTag.ScheduledProcedureStepDescription, aciklama);
        adim.AddOrUpdate(DicomTag.ScheduledProcedureStepID, s.Accession);
        adim.AddOrUpdate(DicomTag.ScheduledProcedureStepStatus, "SCHEDULED");
        if (s.SutKodu.Length > 0)
            adim.AddOrUpdate(new DicomSequence(DicomTag.ScheduledProtocolCodeSequence, Kod(s.SutKodu, "SUT", aciklama)));
        d.AddOrUpdate(new DicomSequence(DicomTag.ScheduledProcedureStepSequence, adim));
        return d;
    }

    private static DicomDataset Kod(string deger, string sema, string anlam)
    {
        var k = new DicomDataset().NotValidated();
        k.AddOrUpdate(DicomTag.CodeValue, deger);
        k.AddOrUpdate(DicomTag.CodingSchemeDesignator, sema);
        k.AddOrUpdate(DicomTag.CodeMeaning, anlam.Length > 64 ? anlam[..64] : anlam);
        return k;
    }
}
