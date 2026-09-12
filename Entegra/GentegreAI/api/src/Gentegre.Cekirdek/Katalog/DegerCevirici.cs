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

    private static decimal OndalikCoz(string s, string alanAdi, string alanBasligi)
    {
        var d = s.Trim();
        if (d.Contains(',') && d.Contains('.'))
            throw GentegreHatasi.Dogrulama($"{alanBasligi}: sayi cozulemedi ({s}).",
                new AlanHatasi(alanAdi, "Sayisal deger olmali."));
        d = d.Replace(',', '.');
        return decimal.TryParse(d, NumberStyles.Number, CultureInfo.InvariantCulture, out var o)
            ? o
            : throw GentegreHatasi.Dogrulama($"{alanBasligi}: sayi cozulemedi ({s}).",
                  new AlanHatasi(alanAdi, "Sayisal deger olmali."));
    }

    private static object? MetinCevir(string s, string tip, string alanAdi, string alanBasligi)
        => tip switch
        {
            // "zaman" = tarih + SAAT (datetime-local). Cozumleme "tarih" ile
            //   aynidir - fark yalnizca EKRANDA: hangi girdi kutusu cizilecegi.
            "tarih" or "zaman" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var t)
                         ? t
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: tarih cozulemedi ({s}).",
                               new AlanHatasi(alanAdi, "Gecersiz tarih.")),

            // "ondalik": olculen deger (ates 36,6 · boy 174,5 · BKI 30,4).
            //   "sayi" TAM SAYIDIR ve olcum alanlarinda 36,6 girilince kayit
            //   "sayi bekleniyor" ile reddediliyordu. VIRGUL DE KABUL EDILIR:
            //   Turkce klavyede ondalik ayirici virguldur; kullaniciyi nokta
            //   yazmaya zorlamak yerine sunucu tek ayiriciyi normalize eder
            //   (iki ayirici varsa deger belirsizdir - reddedilir).
            "ondalik" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : OndalikCoz(s, alanAdi, alanBasligi),

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

    /// <summary>
    /// Kart alani uzunluk + BICIM kontrolu - kart yazimi ve detay yaziminda ortak.
    /// Bicim kurali alanin `Dogrulama` bayragindan gelir (bugun: "tckn").
    /// </summary>
    public static void UzunlukKontrol(KartAlani alan, object? deger, string alanYolu)
    {
        if (alan.EnFazlaUzunluk is { } sinir && deger is string s && s.Length > sinir)
            throw GentegreHatasi.Dogrulama($"{alan.Ad}: en fazla {sinir} karakter.",
                new AlanHatasi(alanYolu, $"En fazla {sinir} karakter."));

        // BICIM: yanlis TCKN sessizce durur ve aylar sonra "provizyon
        //   alinamiyor" olarak geri doner - girişte soylemek en ucuzu.
        if (KimlikDogrulama.Hata(alan.Dogrulama, deger) is { } mesaj)
            throw GentegreHatasi.Dogrulama($"{alan.Etiket}: {mesaj}",
                new AlanHatasi(alanYolu, mesaj));
    }
}
