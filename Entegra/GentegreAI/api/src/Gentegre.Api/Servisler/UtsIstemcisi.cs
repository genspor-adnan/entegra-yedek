using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Uts;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>Şubenin çözülmüş ÜTS hesabı (fn_uts_hesap).</summary>
public sealed record UtsHesabi(string KurumNo, string Token, bool TestMi, string Url)
{
    public string Taban => Url.TrimEnd('/');
}

/// <summary>
/// ÜTS ERİŞİMİ - tek yer (UTSClient katmanı; EBelgeIstemcisi deseni).
///
/// Delphi'deki RestUTS.pas'ın karşılığı ama global token/server değişkeni
/// yok: hesap her çağrıda ŞUBEDEN çözülür (fn_uts_hesap - şubenin kaydı
/// yoksa merkez/varsayılan şube). Kimlik utsToken HTTP başlığıdır ve token
/// BURADAN başka hiçbir yere yazılmaz (log'a / istek_json'a asla).
///
/// RETRY YOK: bildirimler idempotent değildir (tekrar POST = çift bildirim).
/// Başarısız kayıt durum=2'de kalır; kullanıcı "yeniden gönder" ile bilinçli
/// tekrarlar.
/// </summary>
public static class UtsIstemcisi
{
    /// <summary>Şubenin ÜTS hesabını okur ve kullanılabilirliğini doğrular.</summary>
    public static async Task<UtsHesabi> HesapAsync(NpgsqlConnection baglanti, int? subeId,
                                                   CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            "select kurum_no, token, test_mi, url from public.fn_uts_hesap(@p0)", null,
            subeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali(
                "ÜTS hesabı tanımlı değil. Yönetim › Firma Bilgileri › şube kartı › ÜTS.");

        var hesap = new UtsHesabi(
            o.IsDBNull(0) ? "" : o.GetString(0),
            o.IsDBNull(1) ? "" : o.GetString(1),
            !o.IsDBNull(2) && o.GetBoolean(2),
            o.IsDBNull(3) ? "" : o.GetString(3));

        if (string.IsNullOrWhiteSpace(hesap.Token))
            throw GentegreHatasi.IsKurali(
                "ÜTS sistem token'ı boş. Şube kartı › ÜTS sekmesinden girin "
                + "(token ÜTS arayüzünde e-imza ile üretilir).");
        return hesap;
    }

    /// <summary>
    /// POST atar; (httpKodu, gövde) döndürür. HTTP kodları ANLAMLI mesaja
    /// çevrilir ama 200 ve 400 FIRLATILMAZ: 400'ün gövdesi ÜTS'nin alan
    /// hatalarıdır (MSJ) ve çağıran bildirim kaydına yazar.
    /// </summary>
    public static async Task<(int HttpKodu, string Govde)> PostAsync(
        HttpClient istemci, UtsHesabi hesap, string yol, string govdeJson,
        string islemAdi, CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Taban + yol)
        {
            Content = new StringContent(govdeJson, Encoding.UTF8, "application/json")
        };
        istek.Headers.Add("utsToken", hesap.Token);

        HttpResponseMessage yanit;
        try { yanit = await istemci.SendAsync(istek, iptal); }
        catch (HttpRequestException h)
        {
            throw GentegreHatasi.IsKurali(
                $"{islemAdi}: ÜTS sunucusuna ulaşılamadı ({h.Message}).");
        }
        catch (TaskCanceledException) when (!iptal.IsCancellationRequested)
        {
            throw GentegreHatasi.IsKurali(
                $"{islemAdi}: ÜTS yanıt vermedi (zaman aşımı). Daha sonra tekrar deneyin.");
        }

        using (yanit)
        {
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            var kod = (int)yanit.StatusCode;
            return kod switch
            {
                200 or 400 => (kod, metin),   // 400 = alan hataları MSJ'de - çağıran işler
                401 or 403 => throw GentegreHatasi.IsKurali(
                    $"{islemAdi}: ÜTS token'ı geçersiz ya da yetkisiz. "
                    + "Şube kartı › ÜTS sekmesindeki token'ı ve ortam (test/canlı) seçimini kontrol edin."),
                404 => throw GentegreHatasi.IsKurali(
                    $"{islemAdi}: ÜTS servis adresi bulunamadı. "
                    + "Test/canlı ortam seçimi ve URL ayarları doğru mu?"),
                >= 500 => throw GentegreHatasi.IsKurali(
                    $"{islemAdi}: ÜTS sunucusu hata verdi ({kod}). Daha sonra tekrar deneyin."),
                _ => throw GentegreHatasi.IsKurali(
                    $"{islemAdi}: ÜTS beklenmeyen yanıt verdi ({kod}).")
            };
        }
    }

    /// <summary>Cevaptaki MSJ dizisini ayıklar (savunmacı - şema değişse de patlamaz).</summary>
    public static List<UtsMesaj> MesajlariAyikla(string govde)
    {
        var sonuc = new List<UtsMesaj>();
        try
        {
            using var belge = JsonDocument.Parse(govde);
            if (belge.RootElement.ValueKind == JsonValueKind.Object
                && belge.RootElement.TryGetProperty("MSJ", out var msj)
                && msj.ValueKind == JsonValueKind.Array)
                foreach (var m in msj.EnumerateArray())
                    sonuc.Add(new UtsMesaj(
                        Metin(m, "TIP"), Metin(m, "MET"), Metin(m, "KOD")));
        }
        catch (JsonException) { /* JSON değil - boş liste */ }
        return sonuc;

        static string? Metin(JsonElement e, string ad) =>
            e.ValueKind == JsonValueKind.Object && e.TryGetProperty(ad, out var d)
                ? d.ValueKind switch
                  {
                      JsonValueKind.String => d.GetString(),
                      JsonValueKind.Number => d.GetRawText(),
                      _ => null
                  }
                : null;
    }

    /// <summary>Bildirim cevabındaki SNC'yi (ÜTS bildirim GUID'i) ayıklar.</summary>
    public static string? SncAyikla(string govde)
    {
        try
        {
            using var belge = JsonDocument.Parse(govde);
            if (belge.RootElement.ValueKind == JsonValueKind.Object
                && belge.RootElement.TryGetProperty("SNC", out var snc)
                && snc.ValueKind == JsonValueKind.String)
                return snc.GetString();
        }
        catch (JsonException) { }
        return null;
    }

    /// <summary>İlk HATA (yoksa UYARI) mesajından (kod, metin) özeti.</summary>
    public static (string Kod, string Mesaj) HataOzeti(List<UtsMesaj> mesajlar)
    {
        var m = mesajlar.FirstOrDefault(x => x.Tip == "HATA")
             ?? mesajlar.FirstOrDefault(x => x.Tip == "UYARI");
        return (m?.Kod ?? "", m?.Met ?? "");
    }
}
