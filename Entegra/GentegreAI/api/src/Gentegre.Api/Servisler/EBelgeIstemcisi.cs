using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// Entegrator hesabi (fn_ebelge_hesap). Sube bazli: her sube kendi kullanicisi
/// ve ortamiyla (test/uretim) baglanabilir.
/// </summary>
public sealed record EBelgeHesabi(string Entegrator, string Kullanici, string Sifre,
                                  bool TestMi, string Url)
{
    /// <summary>Taban adres, sonundaki "/" atilmis (yol birlestirme icin).</summary>
    public string Taban => Url.TrimEnd('/');
}

/// <summary>
/// ENTEGRATOR ERISIMI - tek yer.
///
/// Hesap okuma, jeton alma ve "istek at + hatayi coz" ucu, uc ayri serviste
/// (gonderim / sorgu / gelen kutusu) ayri ayri yazilmisti. Kopyalar zamanla
/// AYRISTI: gonderim jeton alirken JSON basarisiz olursa form-encoded'a
/// dusuyordu, oteki ikisi dogrudan hata veriyordu - ayni hesapla gonderim
/// calisirken sorgu "giris yapilamadi" diyebiliyordu. Burada tek davranis var
/// (once JSON, olmazsa form-encoded).
///
/// Entegratore ozgu YOLLAR cagiranlarda kalir; burasi yalnizca ortak tasima
/// katmanidir.
/// </summary>
public static class EBelgeIstemcisi
{
    /// <summary>
    /// Subenin entegrator hesabini okur ve kullanilabilirligini dogrular.
    /// <paramref name="islevAdi"/> desteklenmeyen entegratorde gosterilecek
    /// mesajda gecer ("... icin gelen belge kutusu henuz desteklenmiyor").
    /// </summary>
    public static async Task<EBelgeHesabi> HesapAsync(NpgsqlConnection baglanti, int? subeId,
                                                      string islevAdi, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            "select entegrator, kullanici, sifre, test_mi, url from public.fn_ebelge_hesap(@p0)", null,
            subeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Şubenin e-Belge hesabı tanımlı değil. Yönetim › Ayarlar › Genel › Entegrasyon (337).");

        var hesap = new EBelgeHesabi(
            o.IsDBNull(0) ? "" : o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
            o.IsDBNull(2) ? "" : o.GetString(2), !o.IsDBNull(3) && o.GetBoolean(3),
            o.IsDBNull(4) ? "" : o.GetString(4));

        if (string.IsNullOrWhiteSpace(hesap.Entegrator) || string.IsNullOrWhiteSpace(hesap.Url))
            throw GentegreHatasi.IsKurali(
                "Entegratör ayarları eksik. Yönetim › Ayarlar › Genel › Entegrasyon (337).");
        if (hesap.Entegrator != "izibiz")
            throw GentegreHatasi.IsKurali(
                $"\"{hesap.Entegrator}\" için {islevAdi} henüz desteklenmiyor.");
        return hesap;
    }

    /// <summary>
    /// izibiz jetonu (/v1/auth/token). Once JSON govde denenir (dogrulanan yol),
    /// basarisiz olursa form-encoded - Delphi tarafinda calisan ikinci varyant.
    /// </summary>
    public static async Task<string> JetonAsync(HttpClient istemci, EBelgeHesabi hesap,
                                                CancellationToken iptal)
    {
        var jeton = await DeneAsync(new StringContent(
            JsonSerializer.Serialize(new { username = hesap.Kullanici, password = hesap.Sifre }),
            Encoding.UTF8, "application/json"));
        if (jeton is not null) return jeton;

        jeton = await DeneAsync(new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "password",
            ["username"] = hesap.Kullanici,
            ["password"] = hesap.Sifre,
        }));
        if (jeton is not null) return jeton;

        throw GentegreHatasi.IsKurali(
            "Entegratöre giriş yapılamadı; kullanıcı adı / şifre ve ortam (test/üretim) doğru mu?");

        async Task<string?> DeneAsync(HttpContent govde)
        {
            using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Taban + "/v1/auth/token")
            { Content = govde };
            using var yanit = await istemci.SendAsync(istek, iptal);
            if (!yanit.IsSuccessStatusCode) return null;
            return JetonAyikla(await yanit.Content.ReadAsStringAsync(iptal));
        }
    }

    /// <summary>Jeton anahtari entegratore gore degisir; bilinen adlar denenir.</summary>
    public static string? JetonAyikla(string yanit)
    {
        try
        {
            using var belge = JsonDocument.Parse(yanit);
            var kok = belge.RootElement;
            if (Bul(kok) is { } t) return t;
            // izibiz jetonu `data` altinda dondurur.
            if (kok.TryGetProperty("data", out var veri) && Bul(veri) is { } t2) return t2;
            return null;
        }
        catch (JsonException) { return null; }

        static string? Bul(JsonElement e)
        {
            foreach (var ad in new[] { "accessToken", "access_token", "token", "ACCESS_TOKEN" })
                if (e.ValueKind == JsonValueKind.Object && e.TryGetProperty(ad, out var d)
                    && d.ValueKind == JsonValueKind.String)
                    return d.GetString();
            return null;
        }
    }

    /// <summary>
    /// Jetonlu istek atar ve GOVDE METNINI dondurur. Basarisiz durumda entegratorun
    /// kendi mesaji cikarilip <see cref="GentegreHatasi"/> olarak firlatilir -
    /// "500 Internal Server Error" yerine kullanicinin okuyabilecegi bir sey.
    /// </summary>
    public static async Task<string> IsteAsync(HttpClient istemci, EBelgeHesabi hesap, string jeton,
        HttpMethod yontem, string yol, HttpContent? govde, string islemAdi,
        CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(yontem, hesap.Taban + yol) { Content = govde };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali($"{islemAdi} başarısız: {HataMetni(metin, yanit.StatusCode)}");
        return metin;
    }

    /// <summary>Entegrator hata govdesinden okunur mesaj; cozulemezse HTTP kodu.</summary>
    public static string HataMetni(string govde, System.Net.HttpStatusCode kod)
    {
        try
        {
            using var belge = JsonDocument.Parse(govde);
            var kok = belge.RootElement;
            foreach (var ad in new[] { "message", "description", "errorMessage", "error" })
                if (kok.ValueKind == JsonValueKind.Object && kok.TryGetProperty(ad, out var d)
                    && d.ValueKind == JsonValueKind.String)
                    return d.GetString() ?? kod.ToString();
        }
        catch (JsonException) { /* JSON degil - ham metne duselim */ }

        var kirpik = govde.Trim();
        return kirpik.Length is > 0 and <= 300 ? kirpik : ((int)kod).ToString();
    }
}
