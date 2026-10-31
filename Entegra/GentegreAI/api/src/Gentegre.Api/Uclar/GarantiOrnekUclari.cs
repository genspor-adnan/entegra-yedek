using System.Collections.Concurrent;
using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GARANTİ BBVA ÖRNEK SUNUCUSU (1157, kullanıcı 23.10.2026: "garanti entegrasyonu yap örnek").
///
/// Bankanın "Account Transactions" (Elektronik Hesap Özeti) API'sinin Banka/api.json'daki biçimiyle
/// birebir yanıt veren yerel taklit - gerçek istemci yolu (BankaHareketServisi.GarantiAsync: her istekte
/// yeni OAuth jetonu, Basic kimlik, Bearer + GUID başlığı, sayfalama, zenginleştirme çözümü) bankaya
/// gitmeden uçtan uca çalışsın diye. Kullanımı: Entegrasyonlar'daki GARANTI satırı test ortamında,
/// test adresi <c>http://localhost:5180/api/banka-ornek/garanti</c>, kullanıcı adı / şifre herhangi bir
/// değer (boş olamaz - bankadaki gibi). Banka hesabı kartında kaynak "Banka API", onay no herhangi bir metin.
///
/// Kurallar:
/// <list type="bullet">
///   <item>Yalnız GELİŞTİRME ortamında ya da <c>genel.ortam</c> demo / eğitim kurulumunda açık; canlı
///         kurumda 404 (MERNİS benzetim kuralı). Kimlik gerekmez - bankanın kendisi gibi.</item>
///   <item>Jeton TEK KULLANIMLIK ve 5 dakika geçerli (bankanın kuralı): ikinci kez kullanılırsa 401.</item>
///   <item>Hareketler deterministik: istenen tarih aralığının her günü için aynı 7 hareket; karşı taraflar
///         kurumun kendi kayıtlarından (müşteri VKN / IBAN'ı, tedarikçi VKN'si, açık satış faturası, öteki
///         banka hesabının IBAN'ı) seçilir ki öneri motoru gerçek yanıtla aynı yolu izlesin.</item>
///   <item>Servis bu adrese çektiğini kaynak 3 (benzetim) olarak işaretler - ekranda "örnek" görünür,
///         gerçek banka verisiyle karışmaz.</item>
/// </list>
/// </summary>
public static class GarantiOrnekUclari
{
    public const string YolKoku = "/api/banka-ornek/garanti";

    private static readonly ConcurrentDictionary<string, DateTime> Jetonlar = new();

    public static void GarantiOrnekUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup(YolKoku).WithTags("Banka Hareketleri (örnek sunucu)").AllowAnonymous();

        // OAuth 2.0 client credentials - Garanti: POST /auth/oauth/v2/token, Basic ya da gövde kimliği.
        grup.MapPost("/auth/oauth/v2/token", async (HttpContext ctx, VeriKaynagi veri, IWebHostEnvironment ortam, CancellationToken iptal) =>
        {
            if (!await AcikMiAsync(veri, ortam, iptal)) return Results.NotFound();
            var (kimlik, sifre) = Kimlik(ctx);
            if (kimlik == "" || sifre == "")
                return Results.Json(new { error = "invalid_client", error_description = "Client ID / Secret boş" }, statusCode: 401);
            var jeton = Guid.NewGuid().ToString("N");
            Jetonlar[jeton] = DateTime.UtcNow;
            foreach (var eski in Jetonlar.Where(j => j.Value < DateTime.UtcNow.AddMinutes(-5)).Select(j => j.Key).ToList())
                Jetonlar.TryRemove(eski, out _);
            return Results.Json(new { access_token = jeton, token_type = "Bearer", expires_in = 300, scope = "oob" });
        });

        grup.MapPost("/balancesandmovements/accountinformation/transaction/v1/gettransactions",
            async (HttpContext ctx, VeriKaynagi veri, IWebHostEnvironment ortam, CancellationToken iptal) =>
        {
            if (!await AcikMiAsync(veri, ortam, iptal)) return Results.NotFound();
            var yetki = ctx.Request.Headers.Authorization.ToString();
            var jeton = yetki.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase) ? yetki[7..].Trim() : "";
            // Tek kullanımlık: alınır alınmaz silinir.
            if (jeton == "" || !Jetonlar.TryRemove(jeton, out var an) || an < DateTime.UtcNow.AddMinutes(-5))
                return Results.Json(Sonuc(401, "Geçersiz ya da kullanılmış erişim jetonu"), statusCode: 401);

            JsonDocument istek;
            try { istek = await JsonDocument.ParseAsync(ctx.Request.Body, cancellationToken: iptal); }
            catch (JsonException) { return Results.Json(Sonuc(400, "Gövde JSON değil"), statusCode: 400); }
            using var _ = istek;
            var k = istek.RootElement;
            string S(string ad) => k.TryGetProperty(ad, out var v) && v.ValueKind != JsonValueKind.Null ? v.ToString().Trim() : "";
            int N(string ad, int varsayilan) => k.TryGetProperty(ad, out var v) && v.TryGetInt32(out var n) ? n : varsayilan;
            if (S("consentId") == "") return Results.Json(Sonuc(400, "consentId zorunlu"), statusCode: 400);
            if (!DateTime.TryParse(S("startDate"), CultureInfo.InvariantCulture, DateTimeStyles.None, out var bas))
                return Results.Json(Sonuc(400, "startDate biçimi YYYY-MM-DDTHH:mm:ss.fff"), statusCode: 400);
            var bitMetin = S("endDate") is { Length: > 0 } e ? e : S("endtDate");
            if (!DateTime.TryParse(bitMetin, CultureInfo.InvariantCulture, DateTimeStyles.None, out var bit))
                return Results.Json(Sonuc(400, "endDate biçimi YYYY-MM-DDTHH:mm:ss.fff"), statusCode: 400);

            var iban = S("IBAN").Replace(" ", "");
            var ornek = await OrnekAsync(veri, iban, iptal);
            var hepsi = GarantiOrnekVerisi.Uret(iban, S("unitNum"), S("accountNum"), bas, bit, ornek);
            var boyut = Math.Clamp(N("pageSize", 100), 1, 500);
            var sayfa = Math.Max(1, N("pageIndex", 1));
            var dilim = hepsi.Skip((sayfa - 1) * boyut).Take(boyut).ToList();
            var govde = new JsonObject
            {
                ["result"] = new JsonObject { ["returnCode"] = 200, ["reasonCode"] = 1, ["messageText"] = "Basarili" },
                ["transactions"] = new JsonArray(dilim.Select(x => (JsonNode)x).ToArray()),
            };
            ctx.Response.Headers["GUID"] = ctx.Request.Headers["GUID"].ToString();
            return Results.Content(govde.ToJsonString(), "application/json", Encoding.UTF8);
        });
    }

    private static object Sonuc(int kod, string mesaj)
        => new { result = new { returnCode = kod, reasonCode = kod, messageText = mesaj } };

    private static (string Kimlik, string Sifre) Kimlik(HttpContext ctx)
    {
        var yetki = ctx.Request.Headers.Authorization.ToString();
        if (yetki.StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
            try
            {
                var cozum = Encoding.UTF8.GetString(Convert.FromBase64String(yetki[6..].Trim()));
                var i = cozum.IndexOf(':');
                if (i > 0) return (cozum[..i], cozum[(i + 1)..]);
            }
            catch (FormatException) { /* gövdeye bak */ }
        if (ctx.Request.HasFormContentType)
            return (ctx.Request.Form["client_id"].ToString(), ctx.Request.Form["client_secret"].ToString());
        return ("", "");
    }

    /// <summary>Geliştirme ortamı ya da demo / eğitim kurulumu - canlı kurumda örnek sunucu yok.</summary>
    /// <summary>
    /// YALNIZ GELİŞTİRME (kod inceleme 30.10.2026 K51): demo / eğitim ortamında da açıktı ve kimliksiz jeton
    /// ucu gerçek taraf VKN / IBAN / açık belge numarası dönüyordu - eğitim kurulumuna müşteri verisi
    /// kopyalanmışsa dışarıdan okunabiliyordu. Taklit sunucu artık yalnız Development'ta.
    /// </summary>
    private static Task<bool> AcikMiAsync(VeriKaynagi veri, IWebHostEnvironment ortam, CancellationToken iptal)
        => Task.FromResult(ortam.IsDevelopment());

    /// <summary>Karşı taraflar kurumun kendi kayıtlarından - öneri motoru boşa dönmesin.</summary>
    private static async Task<GarantiOrnekVerisi.Taraflar> OrnekAsync(VeriKaynagi veri, string iban, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await b.TekAsync("""
            select coalesce(m.unvan, 'ORNEK MUSTERI AS'), coalesce(m.vkno, ''),
                   coalesce((select tb.iban from public.taraf_banka tb
                              where tb.taraf_id = m.id and tb.aktif = 1 and coalesce(tb.iban, '') <> '' limit 1), ''),
                   coalesce((select f.belge_no from public.belge f
                              where f.taraf_id = m.id and f.durum = 0 and length(coalesce(f.belge_no, '')) >= 6
                              order by f.belge_tarihi desc limit 1), ''),
                   coalesce(t.unvan, 'ORNEK TEDARIKCI LTD'), coalesce(t.vkno, ''), coalesce(k.ad, ''), coalesce(k.iban, '')
              from (select 1) bos
              left join lateral (select x.id, x.unvan, x.vkno from public.taraf x where x.musteri = 1
                                    and length(coalesce(x.vkno, '')) in (10, 11)
                                  order by exists (select 1 from public.belge f where f.taraf_id = x.id and f.durum = 0
                                                      and length(coalesce(f.belge_no, '')) >= 6) desc, x.id limit 1) m on true
              left join lateral (select x.unvan, x.vkno from public.taraf x where x.tedarikci = 1 and x.id <> coalesce(m.id, 0)
                                    and length(coalesce(x.vkno, '')) in (10, 11) order by x.id limit 1) t on true
              left join lateral (select x.ad, x.iban from public.hesap x where x.tur = 'B'
                                    and public.fn_banka_iban(coalesce(x.iban, '')) <> public.fn_banka_iban(@p0)
                                    and length(coalesce(x.iban, '')) = 26 and coalesce(x.durum, 1) = 1
                                  order by x.id limit 1) k on true
            """, null, [iban], o => new GarantiOrnekVerisi.Taraflar(o.GetString(0), o.GetString(1), o.GetString(2),
                o.GetString(3), o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7)), iptal)
            ?? new GarantiOrnekVerisi.Taraflar("ORNEK MUSTERI AS", "", "", "", "ORNEK TEDARIKCI LTD", "", "", "");
    }
}

/// <summary>
/// Örnek sunucunun verisi - Banka/api.json yanıt örneğiyle aynı alanlar ve zenginleştirme yapısı
/// (<c>{enrichmentCode, enrichmentValue}</c>). Veritabanı gerekmez; testte doğrudan çağrılır.
/// </summary>
public static class GarantiOrnekVerisi
{
    public sealed record Taraflar(string MusteriAd, string MusteriVkn, string MusteriIban, string MusteriFaturaNo,
                                  string TedarikciAd, string TedarikciVkn, string KendiAd, string KendiIban);

    public const string KendiVkn = "1194136989";
    private const decimal AcilisBakiye = 1_250_000m;

    public static List<JsonObject> Uret(string iban, string subeNo, string hesapNo, DateTime bas, DateTime bit, Taraflar o)
    {
        var liste = new List<JsonObject>();
        if (bit < bas) return liste;
        var ilk = bas.Date; var son = bit.Date;
        if ((son - ilk).TotalDays > 92) ilk = son.AddDays(-92);
        var bakiye = AcilisBakiye;
        var fatura = o.MusteriFaturaNo;
        for (var d = ilk; d <= son; d = d.AddDays(1))
        {
            // (saat, dakika, giriş?, tutar, açıklama, kategori, sınıf, zenginleştirme)
            var gunluk = new (int Saat, int Dk, bool Giris, decimal Tutar, string Aciklama, string Kategori, string Sinif,
                              string KarsiVkn, JsonArray Zen)[]
            {
                (9, 15, true, 4800m, $"FAST GELEN {Buyuk(o.MusteriAd)} ODEMESI", "ELMS", "NTHE", o.MusteriVkn,
                    Zen(Corr(o.MusteriIban), Mus(o.MusteriAd), Eft(o.MusteriAd, o.MusteriIban, o.MusteriVkn, o.KendiAd, iban, true), Dek(""))),
                (10, 40, true, 12500m, fatura == "" ? "HAVALE GELEN FATURA ODEMESI" : $"HAVALE GELEN FATURA {fatura} ODEMESI", "ELMS", "NTHE", "",
                    Zen(Mus(o.MusteriAd), Dts("", fatura))),
                (11, 40, false, 1250m, $"EFT GIDEN {Buyuk(o.TedarikciAd)} FATURA ODEMESI", "ELMP", "NTHE", o.TedarikciVkn,
                    Zen(Mus(o.TedarikciAd), Eft(o.KendiAd, iban, KendiVkn, o.TedarikciAd, "", false), The())),
                (14, 5, false, 20000m, "HESAPLAR ARASI VIRMAN", "WPDT", "NDTS", KendiVkn,
                    Zen(Corr(o.KendiIban), Mus(o.KendiAd), Hes(), Dek(""))),
                (15, 30, false, 26.25m, "HESAP ISLETIM UCRETI", "GCD1", "NCOM", "", Zen()),
                (16, 10, false, 92.14m, $"INT DOVIZ ALIS  {hesapNo} - 6153564 EUR:9.21410", "GCD1", "??", KendiVkn, Zen(Dov("9.214100"))),
                (17, 45, true, 984m, "POS GUN SONU 41203388 BLOKESIZ", "POSK", "NPOS", "", Zen(Dek("UYE ISYERI 41203388"))),
            };
            foreach (var g in gunluk)
            {
                bakiye += g.Giris ? g.Tutar : -g.Tutar;
                var an = d.AddHours(g.Saat).AddMinutes(g.Dk);
                liste.Add(new JsonObject
                {
                    ["customerNum"] = 45245447, ["customerName"] = "ORNEK KURUM AS",
                    ["VKN"] = long.Parse(KendiVkn, CultureInfo.InvariantCulture), ["TCKN"] = null,
                    ["productId"] = "9d5de526-e32c-5cc7-81ce-545b93ade759",
                    ["unitNum"] = Sayi(subeNo), ["accountNum"] = Sayi(hesapNo), ["currencyCode"] = "TL", ["IBAN"] = iban,
                    ["activityDate"] = d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    ["valueDate"] = d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                    ["txnCreditDebitIndicator"] = g.Giris ? "A" : "B",
                    ["amount"] = g.Tutar, ["balanceAfterTransaction"] = bakiye,
                    ["explanation"] = g.Aciklama, ["transactionId"] = g.Kategori, ["clasificationCode"] = g.Sinif,
                    ["corrVKN"] = g.KarsiVkn == "" ? null : g.KarsiVkn, ["corrTCKN"] = null,
                    ["corrCustomerNum"] = g.KarsiVkn == "" ? null : 45271413,
                    ["transactionReferenceId"] = an.ToString("yyyy-MM-dd'T'HH:mm:ss.ffffff", CultureInfo.InvariantCulture),
                    ["transactionInstanceId"] = an.AddSeconds(2).ToString("yyyy-MM-dd'T'HH:mm:ss.ffffff", CultureInfo.InvariantCulture),
                    ["enrichmentInformation"] = g.Zen,
                });
            }
        }
        return liste;
    }

    private static string Buyuk(string s) => s.ToUpper(new CultureInfo("tr-TR"));
    private static JsonNode? Sayi(string s) => long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n) ? n : (s == "" ? null : s);
    private static JsonArray Zen(params JsonObject?[] kalemler) => new(kalemler.Where(k => k is not null).Cast<JsonNode>().ToArray());
    private static JsonObject Kalem(string kod, JsonObject deger)
    {
        deger["moduleName"] = kod;
        return new JsonObject { ["enrichmentCode"] = kod, ["enrichmentValue"] = deger };
    }
    private static JsonObject? Corr(string iban) => iban == "" ? null : Kalem("CORRACNT", new JsonObject
        { ["productType"] = "Account", ["corrAccountNum"] = iban.Length == 26 ? iban[^7..] : "", ["corrUnitNum"] = iban.Length == 26 ? iban[9..13] : "", ["corrIBAN"] = iban });
    private static JsonObject Mus(string ad) => Kalem("MUS", new JsonObject { ["nameSurnameText"] = ad, ["corrNameSurnameText"] = ad });
    private static JsonObject Hes() => Kalem("HES", new JsonObject
        { ["accountMainType"] = "M", ["accSubType"] = "S", ["accType"] = "A", ["productCode"] = "VDSTDUI", ["subProductCode"] = "" });
    private static JsonObject Dts(string firma, string fatura) => Kalem("DTS", new JsonObject { ["firmOriginalText"] = firma, ["relatedInvText1"] = fatura });
    private static JsonObject Dek(string detay) => Kalem("DEK", new JsonObject { ["detailText"] = detay });
    private static JsonObject The() => Kalem("THE", new JsonObject { ["firmOriginalText1"] = "202610230145504", ["txnId"] = "", ["ustrId"] = "" });
    private static JsonObject Dov(string kur) => Kalem("DOV", new JsonObject { ["processRate"] = kur });
    private static JsonObject Eft(string gonderenAd, string gonderenIban, string gonderenVkn, string aliciAd, string aliciIban, bool giris)
        => Kalem("EFT", new JsonObject
        {
            ["corrBankNum"] = "46", ["corrUnitNum"] = "90001", ["corrBankCityNum"] = "999", ["referenceNum"] = "140008",
            ["msgType"] = "KRED", ["senderIBANEFT"] = gonderenIban, ["receiverIBANEFT"] = aliciIban,
            ["senderName"] = gonderenAd, ["receiverName"] = aliciAd, ["remark"] = giris ? "TRANSFER FAST" : "TRANSFER ELMP-EFT",
            ["senderVKN"] = gonderenVkn, ["corrAccountNum"] = gonderenIban, ["corrGoAddress"] = aliciIban,
            ["rejectedDate"] = null, ["rejectedCode"] = null, ["rejectedMsgReferenceNum"] = null,
        });
}
