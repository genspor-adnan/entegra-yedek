using Gentegre.Cekirdek;
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

    // Hesap okuma / jeton alma ORTAK: EBelgeIstemcisi. Uc serviste ayri ayri
    //   yaziliyordu ve kopyalar ayrismisti (jeton yedek yolu yalniz gonderimde
    //   vardi) - ayni hesapla gonderim calisirken sorgu "giris yapilamadi"
    //   diyebiliyordu.

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
        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "gelen belge kutusu", iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        int okunan = 0, yeni = 0, guncel = 0;

        // (yol, belgeTuru) — e-Fatura kutusu 1, e-Arsiv kutusu 2, e-Irsaliye kutusu 7
        //   (izibiz v2; satir bicimi farkli - SatirKaydetAsync esler).
        foreach (var (yol, tur) in new[] { ("/v1/einvoices/inbox", (short)1),
                                           ("/v1/earchives/inbox", (short)2),
                                           ("/v2/edespatches/inbox", EFatura.EFaturaKodlari.TurEIrsaliye) })
        {
            for (var sayfa = 0; sayfa < 100; sayfa++)     // 100 sayfa = 5000 kayit tavani
            {
                var adres = $"{hesap.Taban}{yol}" +
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
            // BİÇİM AYRIMI (kod inceleme 30.10.2026 K70): virgül varsa Türkçe ("1.234,50"); yoksa nokta ONDALIKTIR
            //   ("1234.50") - eskiden her nokta binlik sayılıp 1234.50 → 123450 oluyordu.
            return m.Contains(',') ? m.Replace(".", "").Replace(',', '.') : m;
        }

        var alt = satir.TryGetProperty("accountingSupplier", out var s) ? s : default;
        var zarf = satir.TryGetProperty("envelope", out var z) ? z : default;
        var durum = satir.TryGetProperty("documentStatus", out var ds) ? ds : default;

        // e-IRSALIYE KUTUSU (v2): gonderen `sender`, alici `receiver`; yanit durumu
        //   detail.responseStatus (WaitingForResponse / ACCEPTED / REJECTED /
        //   PARTIAL_REJECTED / RESPONSE_TIME_EXPIRED). Bekleyen = bos kod (-> 100).
        if (belgeTuru == EFatura.EFaturaKodlari.TurEIrsaliye)
        {
            var gonderen = satir.TryGetProperty("sender", out var sn) ? sn : default;
            var alan = satir.TryGetProperty("receiver", out var rc) ? rc : default;
            var detay = satir.TryGetProperty("detail", out var dt) ? dt : default;
            var yanit = detay.ValueKind == JsonValueKind.Object && detay.TryGetProperty("responseStatus", out var rs) ? rs : default;
            var yanitKodu = Metin(yanit, "value");
            if (yanitKodu.Equals("WaitingForResponse", StringComparison.OrdinalIgnoreCase)
                || yanitKodu.Equals("InProcessing", StringComparison.OrdinalIgnoreCase)) yanitKodu = "";
            var ig = new Dictionary<string, object?>
            {
                ["uuid"]            = Metin(satir, "uuid"),
                ["belgeNo"]         = Metin(satir, "documentNo"),
                ["belgeTuru"]       = belgeTuru,
                ["belgeTarihi"]     = Metin(satir, "issueDate"),
                ["tutar"]           = Sayi(satir, "amount"),
                ["vergiTutar"]      = Sayi(satir, "taxAmount"),
                ["paraBirimi"]      = Metin(satir, "currency") is { Length: > 0 } ipb ? ipb : "TRY",
                ["profil"]          = Metin(satir, "profile"),
                ["senaryoAdi"]      = Metin(satir, "documentType"),
                ["satirSayisi"]     = satir.TryGetProperty("lineCount", out var ilc)
                                      && ilc.ValueKind == JsonValueKind.Number ? ilc.GetInt32() : 0,
                ["gondericiVkno"]   = Metin(gonderen, "identifier"),
                ["gondericiUnvan"]  = Metin(gonderen, "name"),
                ["gondericiAlias"]  = Metin(gonderen, "alias"),
                ["aliciAlias"]      = Metin(alan, "alias"),
                ["yanitKodu"]       = yanitKodu,
                ["yanitAdi"]        = Metin(yanit, "label"),
                ["gibKod"]          = Metin(satir, "gibStatusCode"),
                ["gibAciklama"]     = Metin(satir, "gibStatusDescription"),
                ["entegratorKayit"] = satir.TryGetProperty("id", out var iid) ? iid.ToString() : "",
                ["ham"]             = satir.GetRawText(),
            };
            return await KaydetAsync(ig);
        }

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

        return await KaydetAsync(govde);

        async Task<(long, bool)> KaydetAsync(Dictionary<string, object?> g)
        {
            await using var komut = baglanti.Komut(
                "select e_belge_id, yeni from public.fn_gelen_belge_kaydet(@p0::jsonb, @p1, @p2, @p3)", null,
                JsonSerializer.Serialize(g), (object?)subeId ?? DBNull.Value, entegrator, kullaniciId);

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

        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "gelen belge kutusu", iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        var yol = belgeTuru switch
        {
            2 => "/v1/earchives/inbox/download/ubl",
            EFatura.EFaturaKodlari.TurEIrsaliye => "/v2/edespatches/inbox/download/ubl",
            _ => "/v1/einvoices/inbox/download/ubl",
        };
        var govde = await EBelgeIstemcisi.IsteAsync(istemci, hesap, jeton, HttpMethod.Post, yol,
            new StringContent(
                JsonSerializer.Serialize(new[]
                {
                    new { id = kayitNo, contentType = "XML", exportType = "SINGLE" }
                }), Encoding.UTF8, "application/json"),
            "Belge içeriği indirme", iptal);

        var xml = ZiptenXmlCikar(govde);
        if (xml.Length == 0)
            throw GentegreHatasi.IsKurali("Entegratör yanıtında belge içeriği yok.");

        await using var yaz = baglanti.Komut("""
            update public.e_belge set ubl_xml = @p1, okundu = 1,
                   degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, null,
            eBelgeId, xml, kullaniciId);
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
        short durum = 0, belgeTuru = 1;
        await using (var oku = new NpgsqlCommand("""
            select coalesce(entegrator_kayit, ''), coalesce(uuid, ''),
                   upper(coalesce(profil, '')), durum, belge_turu
              from public.e_belge where id = @p0 and yon = 2
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", eBelgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            kayitNo = o.GetString(0); uuid = o.GetString(1);
            profil = o.GetString(2); durum = o.GetInt16(3); belgeTuru = o.GetInt16(4);
        }

        if (belgeTuru == EFatura.EFaturaKodlari.TurEIrsaliye)
        {
            if (durum is 101 or 102) throw GentegreHatasi.IsKurali("Bu irsaliye için yanıt zaten verilmiş.");
            if (durum == 103) throw GentegreHatasi.IsKurali("İrsaliyenin yanıt süresi geçmiş; yanıt verilemez.");
            await IrsaliyeYanitlaAsync(baglanti, eBelgeId, kabul, (aciklama ?? "").Trim(), subeId, kullaniciId, iptal);
            await using var iy = baglanti.Komut(
                "select public.fn_gelen_belge_yanit_yaz(@p0, @p1, @p2, @p3)", null,
                eBelgeId, kabul, aciklama ?? "", kullaniciId);
            await iy.ExecuteNonQueryAsync(iptal);
            return new YanitSonucu(true, kabul ? "İrsaliye kabul edildi (teslim alındı)." : "İrsaliye reddedildi.");
        }

        if (profil == "TEMELFATURA")
            throw GentegreHatasi.IsKurali(
                "Temel faturaya kabul/red yanıtı verilemez; itiraz noter, KEP ya da " +
                "iade faturasıyla yapılır.");
        if (durum is 101 or 102)
            throw GentegreHatasi.IsKurali("Bu belge için yanıt zaten verilmiş.");
        if (kayitNo.Length == 0)
            throw GentegreHatasi.IsKurali("Belgenin entegratör kayıt numarası yok; kutuyu yenileyin.");

        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "gelen belge kutusu", iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        var yol = kabul ? "/v2/einvoices/inbox/accept" : "/v2/einvoices/inbox/reject";
        await EBelgeIstemcisi.IsteAsync(istemci, hesap, jeton, HttpMethod.Post, yol,
            new StringContent(
                JsonSerializer.Serialize(new[]
                {
                    new { id = kayitNo, uuid, description = aciklama ?? "" }
                }), Encoding.UTF8, "application/json"),
            "Yanıt gönderme", iptal);

        await using var yaz = baglanti.Komut(
            "select public.fn_gelen_belge_yanit_yaz(@p0, @p1, @p2, @p3)", null,
            eBelgeId, kabul, aciklama ?? "", kullaniciId);
        await yaz.ExecuteNonQueryAsync(iptal);

        return new YanitSonucu(true, kabul ? "Belge kabul edildi." : "Belge reddedildi.");
    }

    private static readonly System.Xml.Linq.XNamespace Cbc =
        "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2";
    private static readonly System.Xml.Linq.XNamespace Cac =
        "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2";

    /// <summary>
    /// e-İRSALİYE YANITI (GİB ReceiptAdvice; izibiz /v2/edespatch-responses/send):
    /// irsaliyenin satırları UBL'den okunur, kabulde tamamı teslim alınmış, redde
    /// tamamı reddedilmiş olarak gider. Yanıtın kendi numarası bizim serimizden
    /// (ebelge_seri tür 9; tanımlı değilse IYN) - giden e_belge kaydı (tür 9) numara
    /// sırasını tutar. Kısmi teslim (satır bazında miktar) ilk sürümde yok.
    /// </summary>
    private async Task IrsaliyeYanitlaAsync(NpgsqlConnection b, long eBelgeId, bool kabul, string aciklama,
                                            int? subeId, int kullaniciId, CancellationToken iptal)
    {
        var ubl = await IcerikIndirAsync(eBelgeId, subeId, kullaniciId, iptal);
        var kok = System.Xml.Linq.XDocument.Parse(ubl).Root
                  ?? throw GentegreHatasi.IsKurali("İrsaliye içeriği okunamadı.");
        var irsNo = kok.Element(Cbc + "ID")?.Value.Trim() ?? "";
        var irsTarih = DateTime.TryParse(kok.Element(Cbc + "IssueDate")?.Value, System.Globalization.CultureInfo.InvariantCulture,
                                         System.Globalization.DateTimeStyles.None, out var it) ? it : Saat.Bugun;

        // Irsaliyeyi gonderen (DespatchSupplierParty) - yanitin ALICISI.
        var p = kok.Element(Cac + "DespatchSupplierParty")?.Element(Cac + "Party");
        string Pv(params System.Xml.Linq.XName[] yol)
        {
            System.Xml.Linq.XElement? e = p;
            foreach (var y in yol) e = e?.Element(y);
            return e?.Value.Trim() ?? "";
        }
        var gVkn = p?.Elements(Cac + "PartyIdentification").Select(x => x.Element(Cbc + "ID"))
                     .FirstOrDefault(x => (string?)x?.Attribute("schemeID") is "VKN" or "TCKN")?.Value.Trim() ?? "";
        var gUnvan = Pv(Cac + "PartyName", Cbc + "Name");
        if (gUnvan.Length == 0) gUnvan = $"{Pv(Cac + "Person", Cbc + "FirstName")} {Pv(Cac + "Person", Cbc + "FamilyName")}".Trim();
        var gonderen = new EFatura.EFaturaTaraf(gUnvan, gVkn, Pv(Cac + "PartyTaxScheme", Cac + "TaxScheme", Cbc + "Name"),
            Pv(Cac + "PostalAddress", Cbc + "StreetName"), Pv(Cac + "PostalAddress", Cbc + "CitySubdivisionName"),
            Pv(Cac + "PostalAddress", Cbc + "CityName"), "TR", "", "", "");

        var satirlar = kok.Elements(Cac + "DespatchLine").Select((d, i) =>
        {
            var m = d.Element(Cbc + "DeliveredQuantity");
            _ = decimal.TryParse(m?.Value, System.Globalization.NumberStyles.Any,
                                 System.Globalization.CultureInfo.InvariantCulture, out var miktar);
            return (No: int.TryParse(d.Element(Cbc + "ID")?.Value, out var n) ? n : i + 1,
                    Ad: d.Element(Cac + "Item")?.Element(Cbc + "Name")?.Value.Trim() ?? "",
                    Miktar: miktar,
                    Birim: (string?)m?.Attribute("unitCode") ?? "C62");
        }).ToList();
        if (satirlar.Count == 0) throw GentegreHatasi.IsKurali("İrsaliyede satır bulunamadı; yanıt üretilemez.");

        // Biz (yanitin gondereni): subenin e-Belge kimligi.
        var biz = await b.TekAsync("""
            select coalesce(unvan, '') unvan, coalesce(vkno, '') vkno, coalesce(vergi_dairesi, '') vd,
                   coalesce(adres, '') adres, coalesce(ilce, '') ilce, coalesce(il, '') il,
                   coalesce(gonderici_alias, '') alias
              from public.v_ebelge_gonderici
             where sube_id = coalesce(@p0, (select id from public.sube where varsayilan = 1 and aktif = 1 order by id limit 1))
            """, null, [(object?)subeId ?? DBNull.Value], o => new Tuple<EFatura.EFaturaTaraf, string>(new EFatura.EFaturaTaraf(
                o.Metin("unvan").Trim(), o.Metin("vkno").Trim(), o.Metin("vd").Trim(), o.Metin("adres").Trim(),
                o.Metin("ilce").Trim(), o.Metin("il").Trim(), "TR", "", "", ""), o.Metin("alias").Trim()), iptal);
        if (biz is null || EFatura.EFaturaKodlari.Rakam(biz.Item1.Vkno).Length is not (10 or 11))
            throw GentegreHatasi.IsKurali("Firma (şube) vergi numarası eksik: Yönetim › Firma Bilgileri.");

        var hesap = await EBelgeIstemcisi.HesapAsync(b, subeId, "e-İrsaliye yanıtı", iptal);
        var aliciAlias = hesap.TestMi ? "urn:mail:defaultpk@izibiz.com.tr"
            : await b.TekDegerAsync<string>("select coalesce(gonderici_alias, '') from public.e_belge where id = @p0",
                                            null, [eBelgeId], iptal) ?? "";

        var xslt = await b.TekDegerAsync<string>("""
            select convert_from(di.icerik, 'UTF8')
              from public.dokuman d join public.dokuman_icerik di on di.hash = d.hash
             where d.kaynak = 'ebelge-xslt' and d.kaynak_id in (9, 7) and coalesce(d.yon, 0) in (0, 2)
             order by (d.kaynak_id = 9) desc, d.varsayilan desc, d.id limit 1
            """, null, null, iptal) ?? "";
        if (xslt.Trim().Length == 0)
            throw GentegreHatasi.IsKurali("e-İrsaliye XSLT şablonu yok: Ayarlar › Satış Belgeleri › e-Belge › XSLT.");

        var seri = await b.TekDegerAsync<string>("""
            select upper(btrim(seri)) from public.ebelge_seri
             where belge_turu = 9 and durum = 1 and length(btrim(seri)) = 3 order by sira, id limit 1
            """, null, null, iptal) ?? "IYN";

        var zaman = Saat.Simdi;
        var uuid = Guid.NewGuid().ToString();
        await using var tx = await b.BeginTransactionAsync(iptal);
        var no = await EFatura.EFaturaServisi.NumaraUretAsync(b, tx, seri, zaman.Year, iptal);
        var govde = EFatura.IzibizGovde.IrsaliyeYaniti(no, uuid, zaman, irsNo, irsTarih, gonderen, biz.Item1, satirlar,
            kabul, aciklama, xslt, aliciAlias, biz.Item2).ToJsonString();

        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);
        await EBelgeIstemcisi.IsteAsync(istemci, hesap, jeton, HttpMethod.Post, "/v2/edespatch-responses/send",
            new StringContent(govde, Encoding.UTF8, "application/json"), "İrsaliye yanıtı gönderme", iptal);

        // Numara sirasi + iz: giden yanit kaydi (tur 9), gelen irsaliyenin carisine bagli.
        await b.CalistirAsync("""
            insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, uuid, belge_no, gonderici_alias, alici_alias,
                                        durum, api_json, sube_id, gonderici_vkno, gonderici_unvan, belge_tarihi, profil,
                                        entegrator, yanit_aciklama, ekleyen)
            select null, g.taraf_id, 9, 1, @p1, @p2, @p3, @p4, @p5, @p6, g.sube_id, @p7, @p8, @p9::date, 'TEMELIRSALIYE',
                   @p10, @p11, @p12
              from public.e_belge g where g.id = @p0
            """, tx, [eBelgeId, uuid, no, biz.Item2, aliciAlias, (short)(kabul ? 101 : 102), govde.Length > 20000 ? "" : govde,
                      EFatura.EFaturaKodlari.Rakam(biz.Item1.Vkno), biz.Item1.Unvan, zaman.Date, hesap.Entegrator,
                      $"{(kabul ? "Kabul" : "Red")} yanıtı: {irsNo}", kullaniciId], iptal);
        await tx.CommitAsync(iptal);
    }
}
