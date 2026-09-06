using System.Diagnostics;
using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Cekirdek.Sigorta;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ANADOLU SİGORTA / ASMED ADAPTERİ (430).
///
/// Kaynak: <c>Sigorta/Asmed/Asmed_Web Servis Dokümanı.docx</c>.
/// Uçlar: <c>healthclaimprovision/checkPolicy · createProvision ·
/// searchProvisions · cancelProvision · organizationCreateDocument</c>,
/// kimlik <c>asmedoauthapi/oauth2/token</c> (password grant, scope=agency).
///
/// <para><b>Tarihler epoch MİLİSANİYE.</b> Servis <c>1697639781000</c> gibi
/// long bekliyor; ISO metin gönderilirse alan sessizce yok sayılıyor.</para>
///
/// <para><b>Satır eşleşmesi hospitalRowNumber ile.</b> Yanıttaki tutar
/// kırılımı bizim satırımıza bu numarayla bağlanır - sıraya güvenilmez,
/// şirket satırları farklı sırada ve bazı satırları eksik döndürebilir.</para>
///
/// <para><b>Jeton veritabanında önbelleklenir</b> (<c>sigorta_oturum</c>):
/// süreç içi statik alan, ikinci sunucuda ayrı jeton demek olurdu ve şirket
/// "çok fazla token isteği" der. 401'de bir kez yenilenip istek tekrarlanır.</para>
/// </summary>
public sealed class AsmedSaglayici(VeriKaynagi veri, IHttpClientFactory http,
                                   ISigortaKodCevirici kodlar,
                                   ILogger<AsmedSaglayici> gunluk) : ISigortaSaglayici
{
    private readonly VeriKaynagi _veri = veri;
    private readonly IHttpClientFactory _http = http;
    // KOD ÇEVİRİSİ ADAPTERİN İŞİ: kanonik 1/2/3 -> OUTPATIENT_TREATMENT…
    //   Uçta çevirmek, her yeni sağlayıcıda uçları da değiştirmek olurdu.
    private readonly ISigortaKodCevirici _kodlar = kodlar;
    private readonly ILogger<AsmedSaglayici> _gunluk = gunluk;

    public string Kod => "ANADOLU_ASMED";

    public SaglayiciYetenek Yetenekler { get; } =
        new(Police: true, Provizyon: true, Iptal: true, Dokuman: true,
            Paket: false, Ekstre: false);

    private static readonly JsonSerializerOptions Json = new()
    {
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition
                                     .WhenWritingNull,
    };

    // ===================================================================== jeton

    private async Task<string> JetonAlAsync(SigortaHesabi hesap, bool zorla,
                                            CancellationToken iptal)
    {
        if (!zorla)
        {
            // 60 sn pay: istek yola çıkarken geçerli olan jeton, sunucuya
            //   vardığında dolmuş olmasın.
            var mevcut = await _veri.TekDegerAsync<string>("""
                select jeton from public.sigorta_oturum
                 where hesap_id = @p0 and bitis > now() + interval '60 seconds'
                """, [hesap.HesapId], iptal);
            if (!string.IsNullOrEmpty(mevcut)) return mevcut;
        }

        var istemci = _http.CreateClient("sigorta");
        istemci.Timeout = TimeSpan.FromSeconds(45);

        var govde = new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["client_id"] = hesap.IstemciId,
            ["client_secret"] = hesap.IstemciSifre,
            ["grant_type"] = "password",
            ["username"] = hesap.KullaniciAdi,
            ["password"] = hesap.Parola,
            ["scope"] = "agency",
        });

        using var yanit = await istemci.PostAsync(
            $"{hesap.Adres.TrimEnd('/')}/asmedoauthapi/oauth2/token", govde, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);

        if (!yanit.IsSuccessStatusCode)
            throw new InvalidOperationException(
                $"Sigorta jetonu alınamadı ({(int)yanit.StatusCode}): {Kirp(metin, 200)}");

        using var belge = JsonDocument.Parse(metin);
        var jeton = belge.RootElement.TryGetProperty("access_token", out var a)
                  ? a.GetString() : null;
        if (string.IsNullOrWhiteSpace(jeton))
            throw new InvalidOperationException("Sigorta yanıtında access_token yok.");

        var saniye = belge.RootElement.TryGetProperty("expires_in", out var e)
                  && e.TryGetInt32(out var s) ? s : 3600;
        var yenileme = belge.RootElement.TryGetProperty("refresh_token", out var r)
                     ? r.GetString() ?? "" : "";

        await _veri.CalistirAsync("""
            insert into public.sigorta_oturum (hesap_id, jeton, bitis, yenileme, guncelleme)
            values (@p0, @p1, now() + make_interval(secs => @p2), @p3, now())
            on conflict (hesap_id) do update
               set jeton = excluded.jeton, bitis = excluded.bitis,
                   yenileme = excluded.yenileme, guncelleme = now()
            """, [hesap.HesapId, jeton, (double)Math.Max(60, saniye - 120), yenileme], iptal);

        return jeton;
    }

    /// <summary>
    /// Servis çağrısı: jeton + IBM başlıkları, 401'de BİR KEZ jeton yenileyip
    /// tekrar dener. Sonsuz döngü yok - ikinci 401 gerçekten yetkisizliktir.
    /// </summary>
    private async Task<(int Durum, string Yanit, long Sure)> CagirAsync(
        SigortaHesabi hesap, string uc, string govde, CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        var sonuc = await TekCagriAsync(hesap, uc, govde, false, iptal);
        if (sonuc.Durum == 401)
            sonuc = await TekCagriAsync(hesap, uc, govde, true, iptal);
        kronometre.Stop();
        return (sonuc.Durum, sonuc.Yanit, kronometre.ElapsedMilliseconds);
    }

    private async Task<(int Durum, string Yanit)> TekCagriAsync(
        SigortaHesabi hesap, string uc, string govde, bool jetonYenile,
        CancellationToken iptal)
    {
        var jeton = await JetonAlAsync(hesap, jetonYenile, iptal);
        var istemci = _http.CreateClient("sigorta");
        istemci.Timeout = TimeSpan.FromSeconds(90);

        using var istek = new HttpRequestMessage(HttpMethod.Post,
            $"{hesap.Adres.TrimEnd('/')}/healthclaimprovision/{uc}")
        {
            Content = new StringContent(govde, Encoding.UTF8, "application/json"),
        };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        istek.Headers.TryAddWithoutValidation("X-IBM-Client-Id", hesap.IstemciId);
        istek.Headers.TryAddWithoutValidation("X-IBM-Client-Secret", hesap.IstemciSifre);
        istek.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        using var yanit = await istemci.SendAsync(istek, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            _gunluk.LogWarning("Sigorta {Uc} {Durum}: {Yanit}", uc,
                               (int)yanit.StatusCode, Kirp(metin, 300));
        return ((int)yanit.StatusCode, metin);
    }

    /// <summary>
    /// Jeton alır ve kalan ömrünü bildirir. Kimlik bilgileri, ağ erişimi ve
    /// ağ geçidi yetkilendirmesi bununla doğrulanır - bir iş çağrısı daha
    /// yapmak, sahte veriyle şirket tarafında iz bırakırdı.
    /// </summary>
    public async Task<string> BaglantiTestAsync(SigortaHesabi hesap,
                                                CancellationToken iptal)
    {
        // ZORLA yenilenir: önbellekteki jeton "bağlantı çalışıyor" demez.
        await JetonAlAsync(hesap, true, iptal);
        var bitis = await _veri.TekDegerAsync<DateTime?>("""
            select bitis from public.sigorta_oturum where hesap_id = @p0
            """, [hesap.HesapId], iptal);
        var kalan = bitis is { } t ? (int)Math.Max(0, (t - DateTime.Now).TotalMinutes) : 0;
        return $"Jeton alındı ({hesap.Adres}), geçerlilik ~{kalan} dk.";
    }

    // ==================================================================== poliçe

    public async Task<PoliceSonucu> PoliceSorgulaAsync(SigortaHesabi hesap,
        PoliceIstegi istek, CancellationToken iptal)
    {
        var govde = JsonSerializer.Serialize(new
        {
            doctor = HekimGovdesi(hesap, istek.Hekim),
            identityNo = istek.KimlikNo,
            policy = new { policyNumber = istek.PoliceNo },
            provisionDate = EpochMs(istek.Tarih),
        }, Json);

        var (durum, yanit, _) = await CagirAsync(hesap, "checkPolicy", govde, iptal);
        if (durum is < 200 or > 299)
            return new PoliceSonucu(false, istek.PoliceNo, "", 0, 0, "", "", "",
                                    [Hata(yanit, durum)], yanit);

        var kok = JsonNode.Parse(yanit)?.AsObject();
        var police = kok?["policy"]?.AsObject();
        var notlar = (kok?["noteList"] as JsonArray)?
                     .Select(n => n?.ToString() ?? "").Where(n => n.Length > 0).ToList()
                     ?? [];

        // GEÇERLİLİK KARARI: servis boolean dönmüyor, notlarla söylüyor.
        //   "Poliçeniz bu kurumda geçerlidir." olumlu; olumsuz metinler
        //   "geçerli değil" / "bulunamadı" kalıbında. Poliçe numarası dönmüş
        //   ve olumsuz not yoksa geçerli sayılır.
        var poliçeNo = police?["policyNumber"]?.ToString() ?? "";
        var olumsuz = notlar.Any(n => n.Contains("geçerli değil", StringComparison.OrdinalIgnoreCase)
                                   || n.Contains("bulunamadı", StringComparison.OrdinalIgnoreCase)
                                   || n.Contains("geçersiz", StringComparison.OrdinalIgnoreCase));

        return new PoliceSonucu(
            Gecerli: poliçeNo.Length > 0 && !olumsuz,
            PoliceNo: poliçeNo.Length > 0 ? poliçeNo : istek.PoliceNo,
            PoliceAdi: police?["policyName"]?.ToString() ?? "",
            PoliceTipi: 0, PoliceTuru: 0,          // kanonik çeviri serviste yapılır
            KartNo: police?["cardNo"]?.ToString() ?? "",
            MusteriNo: kok?["customerNumber"]?.ToString() ?? "",
            AgKodu: kok?["networkCode"]?.ToString() ?? "",
            Notlar: notlar,
            HamYanit: yanit);
    }

    // ================================================================= provizyon

    public async Task<ProvizyonSonucu> ProvizyonYazAsync(SigortaHesabi hesap,
        ProvizyonIstegi istek, CancellationToken iptal)
    {
        var govde = ProvizyonGovdesi(hesap, istek);
        var (durum, yanit, _) = await CagirAsync(hesap, "createProvision", govde, iptal);

        if (durum is < 200 or > 299)
            // AĞ/SERVİS HATASI: provizyon TASLAK kalır - yarım provizyon
            //   "onaylı" görünmemeli.
            return new ProvizyonSonucu(false, istek.ProvizyonNo, istek.KurumRefNo,
                SigortaKanonik.Durum.Taslak, "", Hata(yanit, durum), null,
                [], [], govde, yanit, Hata(yanit, durum));

        return YanitCoz(yanit, govde, istek);
    }

    public async Task<ProvizyonSonucu> ProvizyonOkuAsync(SigortaHesabi hesap,
        string provizyonNo, string kurumRefNo, CancellationToken iptal)
    {
        var govde = JsonSerializer.Serialize(new
        {
            provisionNo = string.IsNullOrEmpty(provizyonNo) ? null : provizyonNo,
            hospitalReferenceNo = string.IsNullOrEmpty(kurumRefNo) ? null : kurumRefNo,
        }, Json);

        var (durum, yanit, _) = await CagirAsync(hesap, "searchProvisions", govde, iptal);
        if (durum is < 200 or > 299)
            return new ProvizyonSonucu(false, provizyonNo, kurumRefNo, 0, "",
                Hata(yanit, durum), null, [], [], govde, yanit, Hata(yanit, durum));

        // searchProvisions LİSTE döner; tek kayıt bekleniyor - ilk kayıt alınır.
        var kok = JsonNode.Parse(yanit);
        var tekil = (kok?["provisionResponseList"] as JsonArray)?.FirstOrDefault()
                 ?? (kok as JsonArray)?.FirstOrDefault()
                 ?? kok;
        return YanitCoz(tekil?.ToJsonString() ?? yanit, govde, null);
    }

    public async Task<IptalSonucu> ProvizyonIptalAsync(SigortaHesabi hesap,
        IptalIstegi istek, CancellationToken iptal)
    {
        var govde = JsonSerializer.Serialize(new
        {
            cancellationReasonTypeEnum = Uzak(hesap, SigortaKanonik.Alan.IptalNedeni,
                                              istek.NedenKodu),
            description = istek.Aciklama,
            provisionNo = istek.ProvizyonNo,
            userIdentityNo = istek.KullaniciKimlikNo,
        }, Json);

        var (durum, yanit, _) = await CagirAsync(hesap, "cancelProvision", govde, iptal);
        if (durum is < 200 or > 299)
            return new IptalSonucu(false, Hata(yanit, durum), yanit);

        var kok = JsonNode.Parse(yanit)?.AsObject();
        var sonuc = kok?["cancellationResultType"]?.ToString() ?? "";
        var aciklama = kok?["description"]?.ToString() ?? "";
        // SUCCESS/FAIL metin döner; boolean olarak da gelebilir.
        var basarili = sonuc.Equals("SUCCESS", StringComparison.OrdinalIgnoreCase)
                    || sonuc.Equals("true", StringComparison.OrdinalIgnoreCase);
        return new IptalSonucu(basarili, aciklama, yanit);
    }

    public async Task<DokumanSonucu> DokumanGonderAsync(SigortaHesabi hesap,
        DokumanIstegi istek, CancellationToken iptal)
    {
        // İÇERİK BAYT DİZİSİ olarak gider (dokümandaki örnek: [145, 229, …]),
        //   base64 metin değil - servis diziyi bekliyor.
        var govde = JsonSerializer.Serialize(new
        {
            provisionNo = istek.ProvizyonNo,
            documentList = new[]
            {
                new
                {
                    documentName = istek.DosyaAdi,
                    documentMimeType = istek.Mime,
                    itemTypeName = istek.TipKodu,
                    documentContent = istek.Icerik,
                    sort = istek.Sira.ToString(CultureInfo.InvariantCulture),
                },
            },
        }, Json);

        var (durum, yanit, _) = await CagirAsync(hesap, "organizationCreateDocument",
                                                 govde, iptal);
        if (durum is < 200 or > 299)
            return new DokumanSonucu(false, "", Hata(yanit, durum), yanit);

        var ilk = (JsonNode.Parse(yanit)?["documentList"] as JsonArray)?.FirstOrDefault();
        var basarili = ilk?["success"]?.GetValue<bool>() ?? false;
        return new DokumanSonucu(basarili,
            ilk?["piId"]?.ToString() ?? "",
            basarili ? "" : ilk?["failedMessage"]?.ToString() ?? "Doküman kabul edilmedi.",
            yanit);
    }

    // =================================================================== gövdeler

    private object HekimGovdesi(SigortaHesabi hesap, HekimBilgisi h) => new
    {
        diplomaNo = h.DiplomaNo,
        kibris = false,
        lastName = h.Soyad,
        name = h.Ad,
        sgkAgreement = h.SgkAnlasmasi,
        socialNumber = h.Tckn,
        specialty = new
        {
            code = int.TryParse(h.BransKodu, out var k) ? k : 0,
            name = h.BransAdi,
        },
        staff = h.Kadro,
        titleType = Uzak(hesap, SigortaKanonik.Alan.HekimUnvani, h.Unvan) ?? "",
        tssAgrmnt = h.SgkAnlasmasi,
    };

    private string ProvizyonGovdesi(SigortaHesabi hesap, ProvizyonIstegi i)
        => JsonSerializer.Serialize(new
    {
        provisionNo = string.IsNullOrEmpty(i.ProvizyonNo) ? null : i.ProvizyonNo,
        hospitalReferenceNo = i.KurumRefNo,
        tssFollowUpNumber = string.IsNullOrEmpty(i.TakipNo) ? null : i.TakipNo,
        provisionDate = EpochMs(i.ProvizyonTarihi),
        provisionLocationType = Uzak(hesap, SigortaKanonik.Alan.ProvizyonTipi, i.Tip),
        provisionSubLocationType = Uzak(hesap, SigortaKanonik.Alan.YatisTuru, i.AltTip),
        provisionServiceType = Uzak(hesap, SigortaKanonik.Alan.HizmetTipi, i.HizmetTipi),
        provisionIncidenceType = Uzak(hesap, SigortaKanonik.Alan.VakaTipi, i.VakaTipi),
        provisionRequestType = Uzak(hesap, SigortaKanonik.Alan.TalepTuru, i.TalepTuru),
        insured = new
        {
            name = i.Sigortali.Ad,
            surname = i.Sigortali.Soyad,
            birthDate = EpochMs(i.Sigortali.DogumTarihi),
            genderType = i.Sigortali.Cinsiyet == 2 ? "FEMALE" : "MALE",
            cardNo = Bosluksuz(i.Sigortali.KartNo),
            customerNumber = Bosluksuz(i.Sigortali.MusteriNo),
            identityNo = i.Sigortali.KimlikNo,
            identityType = Uzak(hesap, SigortaKanonik.Alan.KimlikTipi, i.Sigortali.KimlikTipi),
        },
        policy = new
        {
            policyNumber = i.PoliceNo,
            policyName = i.PoliceAdi,
            policyType = Uzak(hesap, SigortaKanonik.Alan.PoliceTipi, i.PoliceTipi),
            policyKind = Uzak(hesap, SigortaKanonik.Alan.PoliceTuru, i.PoliceTuru),
            cardNo = Bosluksuz(i.KartNo),
        },
        patientInfo = new
        {
            backgroundInfo = i.Hasta.Ozgecmis,
            complaintInfo = i.Hasta.Sikayet,
            complaintStartDate = EpochMs(i.Hasta.SikayetTarihi),
            lmpDate = EpochMs(i.Hasta.SonAdetTarihi) ?? 0,
            physicalInfo = Bosluksuz(i.Hasta.FizikMuayene),
            plannedCheckInDate = EpochMs(i.Hasta.PlananYatis),
            plannedCheckOutDate = EpochMs(i.Hasta.PlananCikis),
            admissionDate = EpochMs(i.Hasta.KabulTarihi) ?? 0,
            pregnancyStatus = i.Hasta.Gebelik,
        },
        doctor = HekimGovdesi(hesap, i.Hekim),
        icdList = i.Tanilar.Select(t => new { code = t.Kod, name = t.Ad }).ToArray(),
        operationList = i.Satirlar
            .Where(s => s.SatirTuru == SigortaKanonik.SatirTuru.Islem)
            .Select(s => new
            {
                hospitalRowNumber = s.KurumSiraNo,
                operation = new
                {
                    code = s.Kod,
                    name = s.Ad,
                    operationSourceType = Uzak(hesap, SigortaKanonik.Alan.IslemKaynagi, s.Kaynak),
                },
                operationDate = EpochMs(s.IslemTarihi),
                serviceCost = new
                {
                    quantity = s.Adet,
                    requestAmount = s.TalepTutar,
                    sgkAmount = s.SgkTutar,
                    vatTaxRate = s.KdvOran,
                },
                surgicalDetail = (object?)null,
            }).ToArray(),
        materialList = i.Satirlar
            .Where(s => s.SatirTuru == SigortaKanonik.SatirTuru.Sarf)
            .Select(s => new
            {
                description = s.Ad,
                hospitalRowNumber = s.KurumSiraNo,
                material = new { materialType = Uzak(hesap, SigortaKanonik.Alan.MalzemeTipi, s.MalzemeTipi), name = s.Ad },
                operationDate = EpochMs(s.IslemTarihi),
                serviceCost = new
                {
                    quantity = s.Adet,
                    requestAmount = s.TalepTutar,
                    sgkAmount = s.SgkTutar,
                    vatTaxRate = s.KdvOran,
                },
            }).ToArray(),
        noteList = string.IsNullOrWhiteSpace(i.Not)
                 ? null : new[] { new { note = i.Not } },
        emergency = i.Acil,
    }, Json);

    // ==================================================================== çözümle

    /// <summary>
    /// Yanıtı kanonik sonuca çevirir.
    ///
    /// DURUM KARARI: satırların hiçbirine şirket payı düşmediyse RED, hepsi
    /// tam karşılandıysa ONAY, arada ise KISMİ. Şirketin <c>decision.type</c>
    /// alanı da okunur ama tek başına yeterli değil - satır bazında "Rejected"
    /// olup toplamda kısmi karşılanan provizyonlar var.
    /// </summary>
    private static ProvizyonSonucu YanitCoz(string yanit, string istek,
                                            ProvizyonIstegi? gonderilen)
    {
        var kok = JsonNode.Parse(yanit)?.AsObject();
        if (kok is null)
            return new ProvizyonSonucu(false, "", "", SigortaKanonik.Durum.Taslak,
                "", "Yanıt çözümlenemedi.", null, [], [], istek, yanit,
                "Yanıt çözümlenemedi.");

        var satirlar = new List<ProvizyonSatirSonucu>();
        foreach (var ad in new[] { "operationList", "materialList" })
            foreach (var s in (kok[ad] as JsonArray) ?? [])
                if (s is JsonObject o) satirlar.Add(SatirCoz(o, ad == "materialList"));

        var notlar = ((kok["noteList"] as JsonArray) ?? [])
            .OfType<JsonObject>()
            .Select(n => new ProvizyonNotu(n["noteType"]?.ToString() ?? "",
                                           n["note"]?.ToString() ?? ""))
            .Where(n => n.Metin.Length > 0).ToList();

        var karar = kok["decision"]?["type"]?.ToString() ?? "";
        var kararDetay = kok["decision"]?["detail"]?.ToString() ?? "";
        var iptalMi = (kok["provisionStatusType"]?.ToString() ?? "")
                      .Contains("CANCEL", StringComparison.OrdinalIgnoreCase);

        var talep = satirlar.Sum(s => s.TalepTutar);
        var sirket = satirlar.Sum(s => s.SirketTutar);
        var durum = iptalMi ? SigortaKanonik.Durum.Iptal
                  : satirlar.Count == 0 ? SigortaKanonik.Durum.Gonderildi
                  : sirket <= 0 ? SigortaKanonik.Durum.Red
                  : sirket >= talep ? SigortaKanonik.Durum.Onayli
                  : SigortaKanonik.Durum.Kismi;

        var provizyonNo = kok["provisionNo"]?.ToString() ?? gonderilen?.ProvizyonNo ?? "";
        return new ProvizyonSonucu(
            Basarili: provizyonNo.Length > 0,
            ProvizyonNo: provizyonNo,
            KurumRefNo: kok["hospitalReferenceNo"]?.ToString() ?? gonderilen?.KurumRefNo ?? "",
            Durum: durum,
            KararTipi: karar,
            RedNedeni: durum == SigortaKanonik.Durum.Red ? kararDetay : "",
            Gecerlilik: null,
            Satirlar: satirlar,
            Notlar: notlar,
            HamIstek: istek,
            HamYanit: yanit,
            Hata: provizyonNo.Length > 0 ? "" : kararDetay);
    }

    private static ProvizyonSatirSonucu SatirCoz(JsonObject o, bool sarf)
    {
        var m = o["serviceCost"];
        decimal D(string ad) => m?[ad] is { } v && decimal.TryParse(
            v.ToString(), NumberStyles.Any, CultureInfo.InvariantCulture, out var d) ? d : 0m;

        var kalem = sarf ? o["material"] : o["operation"];
        return new ProvizyonSatirSonucu(
            KurumSiraNo: o["hospitalRowNumber"]?.ToString() ?? "",
            Kod: kalem?["code"]?.ToString() ?? "",
            Ad: kalem?["name"]?.ToString() ?? o["description"]?.ToString() ?? "",
            TalepTutar: D("requestAmount"),
            SirketTutar: D("insuranceCompanyAmount"),
            // Servis "coInsuraceAmount" yazıyor (dokümandaki yazım hatası
            //   servisin kendisinde de var); iki yazımı da okuyoruz.
            KatilimPayi: D("coInsuraceAmount") + D("coInsuranceAmount"),
            IstisnaTutar: D("exclusionAmount"),
            MuafiyetTutar: D("exemptionAmount"),
            LimitUstu: D("aboveLimitAmount"),
            Faturalanmaz: D("notBillAccContractAmount"),
            UyumsuzTutar: D("improperAccContractAmount"),
            Tevkifat: D("tevkifatAmount"),
            Odenecek: D("payableAmount"),
            KdvOran: D("vatTaxRate"),
            Adet: D("quantity"),
            KapsamKodu: o["cover"]?["code"]?.ToString() ?? "",
            Kapsam: o["cover"]?["name"]?.ToString() ?? "",
            KararTipi: o["decision"]?["type"]?.ToString() ?? "",
            Aciklama: o["decision"]?["detail"]?.ToString() ?? "");
    }

    // ==================================================================== ufaklar

    /// <summary>
    /// Kanonik kodu sağlayıcı koduna çevirir. EŞLEME YOKSA ALAN GÖNDERİLMEZ
    /// (null): uydurma bir kod, şirkette anlamı belirsiz bir provizyon
    /// oluştururdu; eksik alan ise şirketin kendi doğrulamasına takılır ve
    /// hata mesajı okunabilir olur.
    /// </summary>
    private string? Uzak(SigortaHesabi hesap, string alan, short? kod)
    {
        var uzak = _kodlar.Uzak(hesap.SaglayiciId, alan, kod);
        return uzak.Length == 0 ? null : uzak;
    }

    private static string? Bosluksuz(string? m) => string.IsNullOrWhiteSpace(m) ? null : m;

    private static long? EpochMs(DateTime? t) => t is null ? null
        : new DateTimeOffset(DateTime.SpecifyKind(t.Value, DateTimeKind.Local))
              .ToUnixTimeMilliseconds();

    private static long? EpochMs(DateOnly? t) => t is null ? null
        : EpochMs(t.Value.ToDateTime(TimeOnly.MinValue));

    /// <summary>
    /// Hata metnini yanıttan çıkarır.
    ///
    /// SERVİS ÜÇ AYRI KABUK KULLANIYOR ve ikisi HTTP 500 ile geliyor:
    ///   · iş kuralı  : {"faultstring": "… poliçe … sigortalıya ait değildir!"}
    ///   · alan hatası: {"fieldErrorList": [{fieldName, faultMessage}]}
    ///   · ağ geçidi  : {"httpMessage": "Unauthorized", "moreInformation": …}
    /// Yalnız gateway kabuğuna bakmak, kullanıcıya "Servis hatası (500)" gibi
    /// hiçbir şey anlatmayan bir metin gösterirdi - oysa asıl sebep yazıyor.
    /// </summary>
    private static string Hata(string yanit, int durum)
    {
        try
        {
            var kok = JsonNode.Parse(yanit);

            if (kok?["fieldErrorList"] is JsonArray alanlar && alanlar.Count > 0)
                return string.Join(" · ", alanlar.OfType<JsonObject>().Select(a =>
                    $"{a["fieldName"]}: {a["faultMessage"] ?? a["faultCode"]}"));

            foreach (var ad in new[] { "faultstring", "faultString", "message",
                                       "error_description", "moreInformation",
                                       "httpMessage", "detail" })
                if (kok?[ad]?.ToString() is { Length: > 0 } m) return m;
        }
        catch { /* metin yanıt - aşağıda kırpılır */ }
        return $"Servis hatası ({durum}): {Kirp(yanit, 200)}";
    }

    private static string Kirp(string m, int n)
        => string.IsNullOrEmpty(m) ? "" : m.Length <= n ? m : m[..n] + "…";
}
