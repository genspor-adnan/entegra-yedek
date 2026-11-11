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
/// <para><b>Cihaz kimliği:</b> çağıran AE başlığı <c>radyoloji_cihaz.ae_title</c> ile tanınır; tanınmayan AE
/// bağlantısı reddedilir (<c>Dicom:MwlBilinmeyenAe</c> açıksa kabul edilir, yalnız modalite süzgeci).</para>
///
/// <para><b>Port 0 = kapalı</b> (<c>Dicom:MwlPort</c>). Arka plan kapalıysa (testler, ad-hoc kopya) açılmaz.</para>
/// </summary>
public sealed class MwlSunucusu(IOptions<DicomAyarlari> ayar, VeriKaynagi veri, ILogger<MwlSunucusu> gunluk,
                                ILoggerFactory gunlukFabrikasi) : BackgroundService
{
    private IDicomServer? _sunucu;

    protected override Task ExecuteAsync(CancellationToken dur)
    {
        var a = ayar.Value;
        if (a.MwlPort <= 0) { gunluk.LogInformation("MWL sunucusu kapalı (Dicom:MwlPort = 0)."); return Task.CompletedTask; }
        try
        {
            var baglam = new MwlBaglami(veri, a, gunlukFabrikasi.CreateLogger("MWL"));
            _sunucu = DicomServerFactory.Create<MwlHizmeti>(a.MwlPort, userState: baglam);
            gunluk.LogInformation("MWL sunucusu dinliyor: port {Port}, AE {Ae}.", a.MwlPort, a.MwlAe);
            if (a.MwlBilinmeyenAe)
                gunluk.LogWarning("MWL: tanınmayan AE başlıkları da kabul ediliyor (Dicom:MwlBilinmeyenAe).");
        }
        catch (Exception h)
        {
            gunluk.LogError(h, "MWL sunucusu açılamadı (port {Port}).", a.MwlPort);
        }
        return Task.CompletedTask;
    }

    public override async Task StopAsync(CancellationToken iptal)
    {
        _sunucu?.Stop();
        _sunucu?.Dispose();
        await base.StopAsync(iptal);
    }
}

/// <summary>fo-dicom hizmetine geçen bağımlılıklar (DicomServerFactory DI'sız kurar; userState ile taşınır).</summary>
public sealed record MwlBaglami(VeriKaynagi Veri, DicomAyarlari Ayar, ILogger Gunluk);

/// <summary>Bir DICOM bağlantısı: C-ECHO (bağlantı testi) + Modality Worklist C-FIND.</summary>
public sealed class MwlHizmeti(INetworkStream akis, Encoding yedekKodlama, ILogger gunluk, DicomServiceDependencies bagimlilik)
    : DicomService(akis, yedekKodlama, gunluk, bagimlilik), IDicomServiceProvider, IDicomCFindProvider, IDicomCEchoProvider
{
    private MwlBaglami B => (MwlBaglami)UserState;
    private string _cagiranAe = "";

    private static readonly DicomTransferSyntax[] Sozdizimleri =
        [DicomTransferSyntax.ExplicitVRLittleEndian, DicomTransferSyntax.ImplicitVRLittleEndian];

    public async Task OnReceiveAssociationRequestAsync(DicomAssociation bag)
    {
        _cagiranAe = (bag.CallingAE ?? "").Trim();
        if (!string.IsNullOrEmpty(B.Ayar.MwlAe) && !string.Equals(bag.CalledAE?.Trim(), B.Ayar.MwlAe, StringComparison.OrdinalIgnoreCase))
        {
            B.Gunluk.LogWarning("MWL: çağrılan AE '{Ae}' bizim değil ({Bizim}); reddedildi.", bag.CalledAE, B.Ayar.MwlAe);
            await SendAssociationRejectAsync(DicomRejectResult.Permanent, DicomRejectSource.ServiceUser, DicomRejectReason.CalledAENotRecognized);
            return;
        }
        if (!B.Ayar.MwlBilinmeyenAe && !await CihazTanidikMiAsync(_cagiranAe))
        {
            B.Gunluk.LogWarning("MWL: tanınmayan cihaz AE '{Ae}' ({Ip}); reddedildi - radyoloji cihaz kartına AE başlığı girilmeli.",
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
            return await B.Veri.TekDegerAsync<bool>(
                "select exists (select 1 from public.radyoloji_cihaz where durum = 1 and upper(trim(ae_title)) = upper(@p0))", [ae]);
        }
        catch (Exception h)
        {
            B.Gunluk.LogError(h, "MWL: cihaz sorgusu başarısız.");
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
        List<MwlSatiri> satirlar;
        DicomStatus? hata = null;
        try
        {
            satirlar = await B.Veri.ListeAsync(
                "select * from public.fn_radyoloji_mwl(@p0, @p1, @p2::date, @p3::date, @p4, @p5)",
                [B.Ayar.MwlBilinmeyenAe && !await CihazTanidikMiAsync(_cagiranAe) ? "" : _cagiranAe,
                 sorgu.Modalite, sorgu.Baslangic, sorgu.Bitis, sorgu.Accession, sorgu.HastaId],
                MwlCevirici.SatirOku);
        }
        catch (Exception h)
        {
            B.Gunluk.LogError(h, "MWL: iş listesi okunamadı (AE {Ae}).", _cagiranAe);
            satirlar = [];
            hata = DicomStatus.ProcessingFailure;
        }
        if (hata is not null) { yield return new DicomCFindResponse(istek, hata); yield break; }

        var kodlama = B.Ayar.MwlKarakterSeti;
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
        await IzYazAsync(satirlar.Where(s => MwlCevirici.AdUyar(adDesen, s)).ToList());
        yield return new DicomCFindResponse(istek, DicomStatus.Success);
    }

    /// <summary>radyoloji_pacs_olay: cihaz istemi İLK gördüğünde bir kez (olay 1, yön 1) - cihazlar dakikada bir sorar.</summary>
    private async Task IzYazAsync(List<MwlSatiri> satirlar)
    {
        if (satirlar.Count == 0) return;
        try
        {
            foreach (var s in satirlar)
                await B.Veri.CalistirAsync(
                    """
                    insert into public.radyoloji_pacs_olay (istem_id, accession_no, olay, yon, cihaz_id, ae_title, sonuc, mesaj)
                    values (@p0, @p1, 1, 1, (select id from public.radyoloji_cihaz where durum = 1 and upper(trim(ae_title)) = upper(@p2) order by id limit 1),
                            upper(@p2), 1, 'MWL: cihaz çalışma listesinde gördü')
                    on conflict (istem_id, ae_title) where olay = 1 and yon = 1 do nothing
                    """, [s.IstemId, s.Accession, _cagiranAe]);
        }
        catch (Exception h)
        {
            B.Gunluk.LogWarning(h, "MWL: iz yazılamadı.");
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
