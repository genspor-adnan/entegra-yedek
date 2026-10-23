using System.Globalization;
using System.Text.Json;

namespace Gentegre.Api.Servisler;

/// <summary>Bankadan çekilen tek hareket - kaynak (Garanti API / örnek sunucu / benzetim) bağımsız ortak satır.</summary>
public sealed record BankaHareketSatiri(string IslemNo, DateTime Tarih, DateTime? Valor, decimal Tutar, string Doviz,
    decimal? Bakiye, string Aciklama, string KarsiAd, string KarsiIban, string KarsiVkn, string Fatura, string Sinif,
    string Ham);

/// <summary>
/// GARANTİ BBVA "Account Transactions" (gettransactions) yanıtını ortak satıra çevirir - Banka/api.json
/// (OpenAPI) ÖRNEĞİNE göre, şemaya değil: şemada <c>txtnCreditDebitIndicator</c> yazar, gerçek yanıt
/// <c>txnCreditDebitIndicator</c> döner (A = alacak / para girişi, B = borç / para çıkışı); zenginleştirme
/// <c>[{enrichmentCode, enrichmentValue:{...}}]</c> biçimindedir (CORRACNT karşı IBAN, MUS karşı ad,
/// DTS fatura metni, EFT gönderen / alıcı, DEK detay). İkisi de hoş görülür.
/// Aynı <c>transactionReferenceId</c> iki harekette tekrar edebiliyor (örnekte GCD1 çifti) - tekil numara
/// referans + oluşturma anı (<c>transactionInstanceId</c>).
/// </summary>
public static class GarantiCevirici
{
    public static List<BankaHareketSatiri> Liste(JsonElement yanit)
    {
        var sonuc = new List<BankaHareketSatiri>();
        if (yanit.TryGetProperty("transactions", out var liste) && liste.ValueKind == JsonValueKind.Array)
            foreach (var x in liste.EnumerateArray()) sonuc.Add(Satir(x));
        return sonuc;
    }

    public static BankaHareketSatiri Satir(JsonElement x)
    {
        string S(string ad) => x.TryGetProperty(ad, out var v) && v.ValueKind != JsonValueKind.Null ? v.ToString().Trim() : "";
        decimal D(string ad) => decimal.TryParse(S(ad), NumberStyles.Any, CultureInfo.InvariantCulture, out var d) ? d : 0;
        DateTime? T(string ad) => DateTime.TryParse(S(ad), CultureInfo.InvariantCulture, DateTimeStyles.None, out var d) ? d : null;

        var gosterge = S("txnCreditDebitIndicator") is { Length: > 0 } g1 ? g1 : S("txtnCreditDebitIndicator");
        var tutar = D("amount");
        var giris = gosterge.ToUpperInvariant() switch
        {
            "A" or "C" or "CREDIT" or "+" => true,
            "B" or "D" or "DEBIT" or "-" => false,
            _ => tutar >= 0,
        };
        tutar = Math.Abs(tutar);

        // Zenginleştirme - gerçek yanıt {enrichmentCode, enrichmentValue}; düz nesne de okunur.
        string karsiIban = "", karsiAd = "", fatura = "", detay = "", eftAd = "", eftIban = "", eftVkn = "";
        if (x.TryGetProperty("enrichmentInformation", out var zen))
            foreach (var m in zen.ValueKind == JsonValueKind.Array ? zen.EnumerateArray() : Enumerable.Repeat(zen, 1))
            {
                var v = m.TryGetProperty("enrichmentValue", out var iv) && iv.ValueKind == JsonValueKind.Object ? iv : m;
                string Z(string ad) => v.TryGetProperty(ad, out var p) && p.ValueKind != JsonValueKind.Null ? p.ToString().Trim() : "";
                var kod = m.TryGetProperty("enrichmentCode", out var ek) ? ek.ToString() : Z("moduleName");
                switch (kod)
                {
                    case "CORRACNT": if (karsiIban == "") karsiIban = Z("corrIBAN"); break;
                    case "MUS": if (karsiAd == "") karsiAd = Z("corrNameSurnameText"); break;
                    case "DTS":
                        if (fatura == "") fatura = Z("relatedInvText1");
                        if (detay == "") detay = Z("firmOriginalText");
                        break;
                    case "DEK": if (detay == "") detay = Z("detailText"); break;
                    case "EFT":
                        // Para girişinde karşı taraf gönderen, çıkışta alıcı.
                        eftAd = giris ? Z("senderName") : Z("receiverName");
                        eftIban = giris ? Z("senderIBANEFT") : Z("receiverIBANEFT");
                        eftVkn = giris ? Z("senderVKN") : Z("receiverVKN");
                        break;
                }
            }
        if (karsiAd == "") karsiAd = eftAd;
        if (karsiIban == "") karsiIban = eftIban;
        var vkn = S("corrVKN") is { Length: > 0 } v1 ? v1 : S("corrTCKN") is { Length: > 0 } v2 ? v2 : eftVkn;

        // Garanti tarih alanı gün hassasiyetinde; aynı günün sırası oluşturma anından.
        var gun = T("activityDate") ?? DateTime.Now;
        var olusma = T("transactionInstanceId");
        var tarih = gun.TimeOfDay == TimeSpan.Zero && olusma is { } o && o.Date == gun.Date ? o : gun;

        var referans = S("transactionReferenceId");
        var ornek = S("transactionInstanceId");
        var islemNo = referans == "" ? (ornek == "" ? $"{gun:yyyyMMdd}|{tutar}|{S("explanation")}" : ornek)
                    : ornek == "" || ornek == referans ? referans : referans + "|" + ornek;

        var aciklama = S("explanation");
        if (detay != "" && !aciklama.Contains(detay, StringComparison.OrdinalIgnoreCase))
            aciklama = aciklama == "" ? detay : aciklama + " · " + detay;

        return new BankaHareketSatiri(islemNo.Length <= 80 ? islemNo : islemNo[..80], tarih, T("valueDate"),
            giris ? tutar : -tutar, S("currencyCode"),
            x.TryGetProperty("balanceAfterTransaction", out var b) && b.ValueKind == JsonValueKind.Number ? D("balanceAfterTransaction") : null,
            aciklama, karsiAd, karsiIban.Replace(" ", ""), vkn, fatura, S("clasificationCode"), x.GetRawText());
    }
}
