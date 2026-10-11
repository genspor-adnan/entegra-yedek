using System.Net.Http.Headers;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-BELGE SORGULARI - entegratore SORULAN, gonderim disi isler:
///   1. MUKELLEF SORGUSU: alici GIB e-Fatura kullanicisi mi? Bu bilgi belgenin
///      e-Fatura mi e-Arsiv mi kesilecegini belirler. Elle isaretlenen bayrak
///      yanlissa belge yanlis turde gider ve GIB reddeder.
///   2. DURUM SORGUSU: gonderilen belge GIB'de ne oldu (raporlandi / kabul /
///      red)? Gonderimden sonra durum kendiliginden degismiyordu.
///
/// Gonderimle AYNI hesabi kullanir (fn_ebelge_hesap) - ayri kimlik yonetimi yok.
/// </summary>
public sealed class EBelgeSorgu(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    public sealed record MukellefBilgisi(bool Mukellef, string Unvan, string VergiDairesi,
                                         string Il, string Ilce, string Adres, string Durum,
                                         string Alias = "", string IrsaliyeAlias = "",
                                         bool IrsaliyeKullanicisi = false);

    /// <summary>GIB kullanici listesi sonucu: posta kutulari + kullanici mi.</summary>
    private sealed record GibKullanici(bool EFatura, bool EIrsaliye,
                                       string Alias, string IrsaliyeAlias);


    // Hesap okuma / jeton alma ORTAK: EBelgeIstemcisi. Uc serviste ayri ayri
    //   yaziliyordu ve kopyalar ayrismisti (jeton yedek yolu yalniz gonderimde
    //   vardi) - ayni hesapla gonderim calisirken sorgu "giris yapilamadi"
    //   diyebiliyordu.

    /// <summary>
    /// GIB e-FATURA KULLANICI LISTESI (186): GET /v1/resources/gib-users.
    /// Donen her kayit bir POSTA KUTUSU (alias) + belge turu (INVOICE /
    /// DESPATCHADVICE). Liste bossa alici e-Fatura kullanicisi DEGILDIR.
    ///
    /// Mukellefiyetin TEK dogru kaynagi burasi: /v2/taxpayers vergi dairesi
    /// kaydini doner, faal her firmaya "aktif" der. Onunla karar verilince
    /// e-Arsivlik alicilara e-Fatura hazirlaniyor, gonderimde entegrator
    /// RECEIVER_COULD_NOT_FOUND_IN_GIB_USER_LIST ile reddediyordu.
    /// </summary>
    private static async Task<GibKullanici> GibKullaniciAsync(HttpClient istemci, EBelgeHesabi hesap,
        string jeton, string vkno, CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Taban}/v1/resources/gib-users?identifier={vkno}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);

        // 404 = listede yok; hata degil, gecerli bir cevap (e-Arsiv kesilecek).
        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound)
            return new GibKullanici(false, false, "", "");
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"GİB kullanıcı sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        if (!belge.RootElement.TryGetProperty("data", out var dizi)
            || dizi.ValueKind != JsonValueKind.Array)
            return new GibKullanici(false, false, "", "");

        string fatura = "", irsaliye = "";
        foreach (var k in dizi.EnumerateArray())
        {
            if (k.ValueKind != JsonValueKind.Object) continue;
            // Kapatilmis posta kutusu ATLANIR - eskimis alias'a gonderim GIB'de reddedilir.
            if (k.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.False)
                continue;

            var alias = k.TryGetProperty("alias", out var a) && a.ValueKind == JsonValueKind.String
                        ? (a.GetString() ?? "").Trim() : "";
            if (alias.Length == 0) continue;

            var tur = k.TryGetProperty("documentType", out var t) && t.ValueKind == JsonValueKind.String
                      ? (t.GetString() ?? "").ToUpperInvariant() : "";
            // Delphi ile ayni kural: tur DESPATCHADVICE ya da alias'ta "IRSALIYE".
            if (tur == "DESPATCHADVICE" || alias.ToUpperInvariant().Contains("IRSALIYE"))
            {
                if (irsaliye.Length == 0) irsaliye = alias;
            }
            else if (fatura.Length == 0) fatura = alias;
        }

        // Fatura kutusu yoksa ama irsaliye kutusu varsa alici yine GIB
        //   kullanicisidir; fatura icin o alias kullanilir.
        var eFatura = fatura.Length > 0 || irsaliye.Length > 0;
        return new GibKullanici(eFatura, irsaliye.Length > 0,
                                fatura.Length > 0 ? fatura : irsaliye, irsaliye);
    }

    // --------------------------------------------------------- mukellef ----
    /// <summary>
    /// GIB e-Fatura kullanicisi mi? 404 = kayitli DEGIL (e-Arsiv kesilecek) -
    /// hata degil, gecerli bir cevaptir.
    /// </summary>
    public async Task<MukellefBilgisi> MukellefSorgulaAsync(string vkno, int? subeId,
                                                            CancellationToken iptal = default)
    {
        var temiz = new string((vkno ?? "").Where(char.IsDigit).ToArray());
        if (temiz.Length is not (10 or 11))
            throw GentegreHatasi.Dogrulama("VKN 10, kimlik no 11 hane olmalı.");

        await using var baglanti = await veri.AcAsync(iptal);
        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "sorgulama", iptal);

        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        // MUKELLEFIYET + ALIAS: GIB kullanici listesi (tek dogru kaynak).
        var gib = await GibKullaniciAsync(istemci, hesap, jeton, temiz, iptal);

        // UNVAN / VERGI DAIRESI / ADRES: vergi dairesi kaydi - kart doldurmak icin.
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Taban}/v2/taxpayers/{temiz}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);

        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound)
            return new MukellefBilgisi(gib.EFatura, "", "", "", "", "",
                                       gib.EFatura ? "Kayıtlı" : "Kayıtlı değil",
                                       gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Mükellef sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        if (!belge.RootElement.TryGetProperty("data", out var d) || d.ValueKind != JsonValueKind.Object)
            return new MukellefBilgisi(gib.EFatura, "", "", "", "", "",
                                       gib.EFatura ? "Kayıtlı" : "Kayıtlı değil",
                                       gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);

        string Metin(JsonElement e, string ad)
            => e.TryGetProperty(ad, out var v) && v.ValueKind == JsonValueKind.String
               ? v.GetString() ?? "" : "";

        // Ilk adres yeterli: kart doldururken kullanicidan onay alinacak.
        var il = ""; var ilce = ""; var adres = "";
        if (d.TryGetProperty("addresses", out var adresler)
            && adresler.ValueKind == JsonValueKind.Array && adresler.GetArrayLength() > 0)
        {
            var a = adresler[0];
            il = Metin(a, "city");
            ilce = Metin(a, "subCity");
            adres = string.Join(' ', new[] { Metin(a, "district"), Metin(a, "streetName"),
                                             Metin(a, "buildingNumber") }
                                     .Where(x => !string.IsNullOrWhiteSpace(x)));
        }

        var durum = Metin(d, "status");
        // MUKELLEFIYET gib-users'tan; ama vergi dairesi kaydi KAPANMISSA (status
        //   <> FAAL) e-Fatura kesilmez - iki kaynak da olumlu olmali.
        var faal = durum.Length == 0
                   || durum.Equals("FAAL", StringComparison.OrdinalIgnoreCase)
                   || (d.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.True);

        return new MukellefBilgisi(gib.EFatura && faal, Metin(d, "commercialName"),
                                   Metin(d, "taxoffice"), il, ilce, adres,
                                   string.IsNullOrWhiteSpace(durum) ? "-" : durum,
                                   gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);
    }
}
