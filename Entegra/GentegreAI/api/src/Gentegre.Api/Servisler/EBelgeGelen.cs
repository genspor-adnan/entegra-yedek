using System.IO.Compression;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GELEN e-BELGE (kutu / inbox) — 187.
///
/// Giden tarafta belgeyi biz uretiriz; gelen tarafta entegratorun kutusundaki
/// satirlari CEKER, kendi kaydimiza (e_belge, yon = 2) yazariz. Uc is:
///   1. KutuCek  : tarih araligindaki gelen belgeleri listeler ve upsert eder.
///   2. IcerikIndir: secilen belgenin UBL XML'ini indirir (zip icinden cikarir).
///   3. Yanitla  : TEMEL olmayan (ticari) faturaya KABUL / RED yaniti gonderir.
///
/// Entegratore ozgu yollar burada; kalan her sey motordan bagimsiz.
/// </summary>
public sealed class EBelgeGelen(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    public sealed record KutuSonucu(int Okunan, int Yeni, int Guncellenen);
    public sealed record YanitSonucu(bool Basarili, string Mesaj);

    private sealed record Hesap(string Entegrator, string Kullanici, string Sifre,
                                bool TestMi, string Url);

    // ------------------------------------------------------------- hesap ----
    private static async Task<Hesap> HesapOkuAsync(NpgsqlConnection baglanti, int? subeId,
                                                   CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select entegrator, kullanici, sifre, test_mi, url from public.fn_ebelge_hesap(@p0)",
            baglanti);
        komut.Parameters.AddWithValue("p0", (object?)subeId ?? DBNull.Value);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Şubenin e-Belge hesabı çözülemedi.");

        var h = new Hesap(
            o.IsDBNull(0) ? "" : o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
            o.IsDBNull(2) ? "" : o.GetString(2), !o.IsDBNull(3) && o.GetBoolean(3),
            o.IsDBNull(4) ? "" : o.GetString(4));

        if (string.IsNullOrWhiteSpace(h.Entegrator) || string.IsNullOrWhiteSpace(h.Url))
            throw GentegreHatasi.IsKurali(
                "Entegratör ayarları eksik. Yönetim › Firma Bilgileri › e-Belge.");
        if (h.Entegrator != "izibiz")
            throw GentegreHatasi.IsKurali(
                $"\"{h.Entegrator}\" için gelen belge kutusu henüz desteklenmiyor.");
        return h;
    }

    private static async Task<string> JetonAlAsync(HttpClient istemci, Hesap hesap,
                                                   CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Post,
            hesap.Url.TrimEnd('/') + "/v1/auth/token")
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new { username = hesap.Kullanici, password = hesap.Sifre }),
                Encoding.UTF8, "application/json"),
        };
        using var yanit = await istemci.SendAsync(istek, iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali("Entegratöre giriş yapılamadı.");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        var kok = belge.RootElement;
        foreach (var kaynak in new[] { kok, kok.TryGetProperty("data", out var d) ? d : default })
        {
            if (kaynak.ValueKind != JsonValueKind.Object) continue;
            foreach (var ad in new[] { "accessToken", "access_token", "token" })
                if (kaynak.TryGetProperty(ad, out var t) && t.ValueKind == JsonValueKind.String)
                    return t.GetString()!;
        }
        throw GentegreHatasi.IsKurali("Entegratör jetonu alınamadı.");
    }

    // --------------------------------------------------------- kutu cek ----
    /// <summary>
    /// Tarih araligindaki gelen belgeleri ceker ve kaydeder. Kutu SAYFALI
    /// gelir; son sayfaya kadar donulur (bir gunde yuzlerce fatura olabilir).
    /// e-Fatura ve e-Arsiv kutulari AYRI uclar - ikisi de taranir.
    /// </summary>
    public async Task<KutuSonucu> KutuCekAsync(DateTime baslangic, DateTime bitis,
        int? subeId, int kullaniciId, CancellationToken iptal = default)
    {
        if (bitis < baslangic)
            throw GentegreHatasi.Dogrulama("Bitiş tarihi başlangıçtan önce olamaz.");
        if ((bitis - baslangic).TotalDays > 92)
            throw GentegreHatasi.Dogrulama("Tarih aralığı en fazla 3 ay olabilir.");

        await using var baglanti = await veri.AcAsync(iptal);
        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        int okunan = 0, yeni = 0, guncel = 0;

        // (yol, belgeTuru) — e-Fatura kutusu 1, e-Arsiv kutusu 2.
        foreach (var (yol, tur) in new[] { ("/v1/einvoices/inbox", (short)1),
                                           ("/v1/earchives/inbox", (short)2) })
        {
            for (var sayfa = 0; sayfa < 100; sayfa++)     // 100 sayfa = 5000 kayit tavani
            {
                var adres = $"{hesap.Url.TrimEnd('/')}{yol}" +
                            $"?startDate={baslangic:yyyy-MM-dd}&endDate={bitis:yyyy-MM-dd}" +
                            $"&page={sayfa}&pageSize=50";
                using var istek = new HttpRequestMessage(HttpMethod.Get, adres);
                istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
                using var yanit = await istemci.SendAsync(istek, iptal);

                // e-Arsiv kutusu bazi hesaplarda kapali (403/503) - digerini engellemesin.
                if (!yanit.IsSuccessStatusCode) break;

                using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
                if (!belge.RootElement.TryGetProperty("data", out var veriDugum)
                    || veriDugum.ValueKind != JsonValueKind.Object
                    || !veriDugum.TryGetProperty("contents", out var liste)
                    || liste.ValueKind != JsonValueKind.Array)
                    break;

                var adet = liste.GetArrayLength();
                if (adet == 0) break;

                foreach (var satir in liste.EnumerateArray())
                {
                    var (id, eklendi) = await SatirKaydetAsync(baglanti, satir, tur, subeId,
                                                               hesap.Entegrator, kullaniciId, iptal);
                    if (id > 0) { okunan++; if (eklendi) yeni++; else guncel++; }
                }

                if (adet < 50) break;                    // son sayfa
            }
        }

        return new KutuSonucu(okunan, yeni, guncel);
    }

    /// <summary>
    /// Entegrator satirini ORTAK alan adlarina cevirip fn_gelen_belge_kaydet'e
    /// verir. Cevrim burada: baska entegrator eklenince yalniz bu esleme yazilir,
    /// veritabani tarafi degismez.
    /// </summary>
    private static async Task<(long Id, bool Yeni)> SatirKaydetAsync(NpgsqlConnection baglanti,
        JsonElement satir, short belgeTuru, int? subeId, string entegrator, int kullaniciId,
        CancellationToken iptal)
    {
        string Metin(JsonElement e, string ad)
            => e.ValueKind == JsonValueKind.Object && e.TryGetProperty(ad, out var v)
               && v.ValueKind == JsonValueKind.String ? (v.GetString() ?? "").Trim() : "";

        string Sayi(JsonElement e, string ad)
        {
            if (e.ValueKind != JsonValueKind.Object || !e.TryGetProperty(ad, out var v)) return "0";
            // Tutar metin gelebiliyor ve TURKCE bicimli: "1.234,50".
            if (v.ValueKind == JsonValueKind.Number) return v.ToString();
            var m = (v.GetString() ?? "").Trim();
            if (m.Length == 0) return "0";
            return m.Replace(".", "").Replace(',', '.');
        }

        var alt = satir.TryGetProperty("accountingSupplier", out var s) ? s : default;
        var zarf = satir.TryGetProperty("envelope", out var z) ? z : default;
        var durum = satir.TryGetProperty("documentStatus", out var ds) ? ds : default;

        var govde = new Dictionary<string, object?>
        {
            ["uuid"]            = Metin(satir, "uuid"),
            ["belgeNo"]         = Metin(satir, "documentNo"),
            ["belgeTuru"]       = belgeTuru,
            ["belgeTarihi"]     = Metin(satir, "issueDate"),
            ["tutar"]           = Sayi(satir, "amount"),
            ["vergiTutar"]      = Sayi(satir, "taxAmount"),
            ["paraBirimi"]      = Metin(satir, "currency") is { Length: > 0 } pb ? pb : "TRY",
            ["profil"]          = Metin(satir, "profile"),
            ["senaryoAdi"]      = Metin(satir, "invoiceType"),
            ["satirSayisi"]     = satir.TryGetProperty("lineCount", out var lc)
                                  && lc.ValueKind == JsonValueKind.Number ? lc.GetInt32() : 0,
            ["gondericiVkno"]   = Metin(satir, "supplierSSN") is { Length: > 0 } v1
                                  ? v1 : Metin(alt, "identifier"),
            ["gondericiUnvan"]  = Metin(alt, "name"),
            ["gondericiAlias"]  = Metin(satir, "supplierAlias"),
            ["aliciAlias"]      = Metin(satir, "customerAlias"),
            ["yanitKodu"]       = Metin(durum, "value"),
            ["yanitAdi"]        = Metin(durum, "label"),
            ["zarfId"]          = Metin(zarf, "identifier"),
            ["gibZarfKodu"]     = zarf.ValueKind == JsonValueKind.Object
                                  && zarf.TryGetProperty("gibStatusCode", out var gk)
                                  ? gk.ToString() : "",
            ["gibKod"]          = satir.TryGetProperty("statusCode", out var sk) ? sk.ToString() : "",
            ["gibAciklama"]     = Metin(satir, "statusDesc"),
            ["entegratorKayit"] = satir.TryGetProperty("id", out var eid) ? eid.ToString() : "",
            ["ham"]             = satir.GetRawText(),
        };

        await using var komut = new NpgsqlCommand(
            "select e_belge_id, yeni from public.fn_gelen_belge_kaydet(@p0::jsonb, @p1, @p2, @p3)",
            baglanti);
        komut.Parameters.AddWithValue("p0", JsonSerializer.Serialize(govde));
        komut.Parameters.AddWithValue("p1", (object?)subeId ?? DBNull.Value);
        komut.Parameters.AddWithValue("p2", entegrator);
        komut.Parameters.AddWithValue("p3", kullaniciId);

        try
        {
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) return (0, false);
            return (o.GetInt64(0), o.GetBoolean(1));
        }
        catch (PostgresException)
        {
            // Tek bir bozuk satir TUM kutu cekimini durdurmasin.
            return (0, false);
        }
    }

    // ----------------------------------------------------- icerik indir ----
    /// <summary>
    /// Gelen belgenin UBL XML'i. Entegrator zip'i base64 olarak doner; zip
    /// icindeki tek dosya XML'dir. Indirilen icerik kayda YAZILIR - ikinci
    /// goruntulemede aga cikilmaz.
    /// </summary>
    public async Task<string> IcerikIndirAsync(long eBelgeId, int? subeId, int kullaniciId,
                                               CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        string kayitNo = "", mevcut = "";
        short belgeTuru = 1;
        await using (var oku = new NpgsqlCommand("""
            select coalesce(entegrator_kayit, ''), coalesce(ubl_xml, ''), belge_turu
              from public.e_belge where id = @p0 and yon = 2
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", eBelgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi();
            kayitNo = o.GetString(0); mevcut = o.GetString(1); belgeTuru = o.GetInt16(2);
        }

        if (mevcut.Length > 0) return mevcut;
        if (kayitNo.Length == 0)
            throw GentegreHatasi.IsKurali("Belgenin entegratör kayıt numarası yok; kutuyu yenileyin.");

        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        var yol = belgeTuru == 2 ? "/v1/earchives/inbox/download/ubl"
                                 : "/v1/einvoices/inbox/download/ubl";
        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Url.TrimEnd('/') + yol)
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new[]
                {
                    new { id = kayitNo, contentType = "XML", exportType = "SINGLE" }
                }), Encoding.UTF8, "application/json"),
        };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Belge içeriği indirilemedi (HTTP {(int)yanit.StatusCode}).");

        var xml = ZiptenXmlCikar(govde);
        if (xml.Length == 0)
            throw GentegreHatasi.IsKurali("Entegratör yanıtında belge içeriği yok.");

        await using var yaz = new NpgsqlCommand("""
            update public.e_belge set ubl_xml = @p1, okundu = 1,
                   degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, baglanti);
        yaz.Parameters.AddWithValue("p0", eBelgeId);
        yaz.Parameters.AddWithValue("p1", xml);
        yaz.Parameters.AddWithValue("p2", kullaniciId);
        await yaz.ExecuteNonQueryAsync(iptal);

        return xml;
    }

    /// <summary>data.content = base64(zip) -&gt; icindeki ilk XML.</summary>
    private static string ZiptenXmlCikar(string yanitJson)
    {
        using var belge = JsonDocument.Parse(yanitJson);
        if (!belge.RootElement.TryGetProperty("data", out var d)) return "";

        // Bazi yanitlarda data bir dizi (coklu indirme), bazilarinda tek nesne.
        var kaynak = d.ValueKind == JsonValueKind.Array && d.GetArrayLength() > 0 ? d[0] : d;
        if (kaynak.ValueKind != JsonValueKind.Object
            || !kaynak.TryGetProperty("content", out var ic)
            || ic.ValueKind != JsonValueKind.String) return "";

        var ham = Convert.FromBase64String(ic.GetString() ?? "");

        // Icerik zip DEGILSE (dogrudan XML) oldugu gibi kullan.
        if (ham.Length < 4 || ham[0] != 'P' || ham[1] != 'K')
            return Encoding.UTF8.GetString(ham);

        using var akis = new MemoryStream(ham);
        using var arsiv = new ZipArchive(akis, ZipArchiveMode.Read);
        foreach (var girdi in arsiv.Entries)
        {
            if (girdi.Length == 0) continue;
            using var okuyucu = new StreamReader(girdi.Open(), Encoding.UTF8);
            return okuyucu.ReadToEnd();
        }
        return "";
    }

    // ------------------------------------------------------------ yanit ----
    /// <summary>
    /// TICARI faturaya KABUL / RED yaniti. Temel faturaya yanit verilemez -
    /// GIB kabul etmez, kullaniciya sebebiyle birlikte soylenir.
    /// </summary>
    public async Task<YanitSonucu> YanitlaAsync(long eBelgeId, bool kabul, string aciklama,
        int? subeId, int kullaniciId, CancellationToken iptal = default)
    {
        if (!kabul && string.IsNullOrWhiteSpace(aciklama))
            throw GentegreHatasi.Dogrulama("Red gerekçesi zorunlu.");

        await using var baglanti = await veri.AcAsync(iptal);

        string kayitNo = "", uuid = "", profil = "";
        short durum = 0;
        await using (var oku = new NpgsqlCommand("""
            select coalesce(entegrator_kayit, ''), coalesce(uuid, ''),
                   upper(coalesce(profil, '')), durum
              from public.e_belge where id = @p0 and yon = 2
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", eBelgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            kayitNo = o.GetString(0); uuid = o.GetString(1);
            profil = o.GetString(2); durum = o.GetInt16(3);
        }

        if (profil == "TEMELFATURA")
            throw GentegreHatasi.IsKurali(
                "Temel faturaya kabul/red yanıtı verilemez; itiraz noter, KEP ya da " +
                "iade faturasıyla yapılır.");
        if (durum is 101 or 102)
            throw GentegreHatasi.IsKurali("Bu belge için yanıt zaten verilmiş.");
        if (kayitNo.Length == 0)
            throw GentegreHatasi.IsKurali("Belgenin entegratör kayıt numarası yok; kutuyu yenileyin.");

        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        var yol = kabul ? "/v2/einvoices/inbox/accept" : "/v2/einvoices/inbox/reject";
        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Url.TrimEnd('/') + yol)
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new[]
                {
                    new { id = kayitNo, uuid, description = aciklama ?? "" }
                }), Encoding.UTF8, "application/json"),
        };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Yanıt gönderilemedi (HTTP {(int)yanit.StatusCode}): " +
                (govde.Length > 400 ? govde[..400] : govde));

        await using var yaz = new NpgsqlCommand(
            "select public.fn_gelen_belge_yanit_yaz(@p0, @p1, @p2, @p3)", baglanti);
        yaz.Parameters.AddWithValue("p0", eBelgeId);
        yaz.Parameters.AddWithValue("p1", kabul);
        yaz.Parameters.AddWithValue("p2", aciklama ?? "");
        yaz.Parameters.AddWithValue("p3", kullaniciId);
        await yaz.ExecuteNonQueryAsync(iptal);

        return new YanitSonucu(true, kabul ? "Belge kabul edildi." : "Belge reddedildi.");
    }

    // ------------------------------------------------------------ iptal ----
    public sealed record IptalSonucu(bool Basarili, short YeniDurum, string Mesaj);

    /// <summary>
    /// GIDEN belgeyi iptal et (188).
    ///   e-ARSIV  : entegrator uzerinden dogrudan iptal (DELETE .../earchives/cancel).
    ///   e-FATURA : tek tarafli iptal YOK - GIB iptal portalina TALEP gonderilir;
    ///              alici onaylayana kadar belge gecerli kalir.
    /// Hangisinin gecerli oldugu ve belgenin uygun asamada olup olmadigi
    /// veritabaninda karara baglanir (fn_ebelge_iptal_edilebilir) - arayuz ile
    /// sunucu ayni cevabi versin.
    /// </summary>
    public async Task<IptalSonucu> IptalEtAsync(int belgeId, string gerekce, int? subeId,
                                                int kullaniciId, CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(gerekce))
            throw GentegreHatasi.Dogrulama("İptal gerekçesi zorunlu.");

        await using var baglanti = await veri.AcAsync(iptal);

        short yeniDurum;
        await using (var kural = new NpgsqlCommand(
            "select uygun, yeni_durum, sebep from public.fn_ebelge_iptal_edilebilir(@p0)", baglanti))
        {
            kural.Parameters.AddWithValue("p0", belgeId);
            await using var o = await kural.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            if (!o.GetBoolean(0)) throw GentegreHatasi.IsKurali(o.GetString(2));
            yeniDurum = o.GetInt16(1);
        }

        string uuid = "", belgeNo = "";
        await using (var oku = new NpgsqlCommand("""
            select coalesce(uuid, ''), coalesce(belge_no, '')
              from public.e_belge
             where belge_id = @p0 and yon = 1
             order by id desc limit 1
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", belgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (await o.ReadAsync(iptal)) { uuid = o.GetString(0); belgeNo = o.GetString(1); }
        }
        if (uuid.Length == 0)
            throw GentegreHatasi.IsKurali("Belgenin UUID'si yok; iptal edilemez.");

        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        // e-Arsiv: DELETE + [{uuid}] · e-Fatura: iptal talebi ucu.
        var arsiv = yeniDurum == 21;
        var yol = arsiv ? "/v2/earchives/cancel" : "/v2/einvoices/cancel-request";
        using var istek = new HttpRequestMessage(
            arsiv ? HttpMethod.Delete : HttpMethod.Post, hesap.Url.TrimEnd('/') + yol)
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new[] { new { uuid, description = gerekce } }),
                Encoding.UTF8, "application/json"),
        };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
        {
            // Entegratorun "uygun durumda degildir" cevabi tek basina anlamsiz:
            //   e-Arsiv ancak GIB'e RAPORLANDIKTAN sonra iptal edilebilir
            //   (raporlanmamis belgede iptal degil "Hazırı Geri Al" gecerlidir).
            //   Sebebi kullaniciya burada soyluyoruz, ham cevabi da birakiyoruz.
            var ek = govde.Contains("uygun durumda", StringComparison.OrdinalIgnoreCase)
                     ? " Belge büyük olasılıkla henüz GİB'e raporlanmadı; " +
                       "e-Arşiv iptali ancak raporlandıktan sonra yapılabilir."
                     : "";
            throw GentegreHatasi.IsKurali(
                $"İptal edilemedi (HTTP {(int)yanit.StatusCode}).{ek} " +
                (govde.Length > 300 ? govde[..300] : govde));
        }

        await using var yaz = new NpgsqlCommand(
            "select public.fn_ebelge_iptal_yaz(@p0, @p1, @p2, @p3)", baglanti);
        yaz.Parameters.AddWithValue("p0", belgeId);
        yaz.Parameters.AddWithValue("p1", yeniDurum);
        yaz.Parameters.AddWithValue("p2", gerekce);
        yaz.Parameters.AddWithValue("p3", kullaniciId);
        await yaz.ExecuteNonQueryAsync(iptal);

        return new IptalSonucu(true, yeniDurum,
            yeniDurum == 21
                ? $"{belgeNo} iptal edildi."
                : $"{belgeNo} için iptal talebi gönderildi; alıcı onaylayana kadar belge geçerlidir.");
    }
}
