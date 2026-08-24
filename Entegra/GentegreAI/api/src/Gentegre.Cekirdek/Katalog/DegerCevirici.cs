using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// JSON degerini kolon tipine cevirir. Tek yerde durur ki liste filtresi ile kart
/// yazimi ayni kurallari kullansin.
///
/// KRITIK: 'mantik' alanlar PG'de SMALLINT'tir (MSSQL bit karsiligi, boolean DEGIL) -
/// true/false 1/0 olarak baglanir. Aksi halde "boolean = integer" hatalari ciker.
/// </summary>
public static class DegerCevirici
{
    public static object? Cevir(object? deger, string tip, string alanAdi, string alanBasligi)
    {
        if (deger is null) return null;

        if (deger is JsonElement je)
        {
            switch (je.ValueKind)
            {
                case JsonValueKind.Null or JsonValueKind.Undefined:
                    return null;

                case JsonValueKind.True:
                    return tip == "mantik" ? (short)1 : (object)true;

                case JsonValueKind.False:
                    return tip == "mantik" ? (short)0 : (object)false;

                case JsonValueKind.Number:
                    return tip switch
                    {
                        "para"   => je.GetDecimal(),
                        "mantik" => (short)je.GetInt32(),
                        "metin"  => je.ToString(),
                        _        => je.TryGetInt64(out var l) ? l : je.GetDecimal()
                    };

                case JsonValueKind.String:
                {
                    var s = je.GetString() ?? "";
                    return MetinCevir(s, tip, alanAdi, alanBasligi);
                }

                default:
                    throw GentegreHatasi.Dogrulama($"{alanBasligi}: desteklenmeyen deger.",
                        new AlanHatasi(alanAdi, "Deger cozulemedi."));
            }
        }

        return deger switch
        {
            bool b when tip == "mantik" => (short)(b ? 1 : 0),
            string s => MetinCevir(s, tip, alanAdi, alanBasligi),
            _ => deger
        };
    }

    private static object? MetinCevir(string s, string tip, string alanAdi, string alanBasligi)
        => tip switch
        {
            "tarih" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var t)
                         ? t
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: tarih cozulemedi ({s}).",
                               new AlanHatasi(alanAdi, "Gecersiz tarih.")),

            "sayi" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var n)
                         ? n
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: sayi bekleniyor ({s}).",
                               new AlanHatasi(alanAdi, "Sayi olmali.")),

            // KOD her zaman sayi DEGILDIR: cogu kod listesi sayisaldir (durum, tur)
            //   ama bazi kolonlar HARF tasir (hesap.tur = 'K'/'B'/'P', doviz kodu).
            //   Sayiya cevrilebiliyorsa sayi, cevrilemiyorsa METIN gecer - kolonun
            //   gercek tipini DB dogrular. (Eskiden hepsi sayi zorunluydu ve
            //   "tur: sayi bekleniyor (K)" ile kasa/banka karti kaydedilemiyordu.)
            "kod" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var k)
                         ? k
                         : s,

            "para" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out var m)
                         ? m
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: tutar cozulemedi ({s}).",
                               new AlanHatasi(alanAdi, "Sayisal deger olmali.")),

            "mantik" => (short)(s is "1" or "true" or "True" or "evet" ? 1 : 0),

            _ => s
        };

    /// <summary>Kart alani uzunluk kontrolu - kart yazimi ve detay yaziminda ortak.</summary>
    public static void UzunlukKontrol(KartAlani alan, object? deger, string alanYolu)
    {
        if (alan.EnFazlaUzunluk is { } sinir && deger is string s && s.Length > sinir)
            throw GentegreHatasi.Dogrulama($"{alan.Ad}: en fazla {sinir} karakter.",
                new AlanHatasi(alanYolu, $"En fazla {sinir} karakter."));
    }
}
