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
    /// <param name="zamanDilimi">
    /// AKTIF SUBENIN saat dilimi (666). "zaman" alanlarinda kullanicinin
    /// yazdigi duvar saati bu dilimde yorumlanip UTC ana cevrilir; bos ise
    /// kurulus dilimi kullanilir. "tarih" alanlari GUNDUR, cevrilmez.
    /// </param>
    public static object? Cevir(object? deger, string tip, string alanAdi, string alanBasligi,
                                string? zamanDilimi = null)
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
            string s => MetinCevir(s, tip, alanAdi, alanBasligi, zamanDilimi),
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

    private static object? MetinCevir(string s, string tip, string alanAdi, string alanBasligi,
                                      string? zamanDilimi = null)
        => tip switch
        {
            // "zaman" = tarih + SAAT (datetime-local). Cozumleme "tarih" ile
            //   aynidir - fark yalnizca EKRANDA: hangi girdi kutusu cizilecegi.
            // "tarih"  -> GUN (dogum tarihi, vade, donem basi). Gun bir andir
            //             DEGIL; saat dilimine cevirmek tarihi bir gun
            //             kaydirirdi (00:00 Istanbul = onceki gun 21:00 UTC).
            // "zaman"   -> AN (islem saati, kabul saati). 667'den beri kolon
            //             timestamptz; kullanicinin yazdigi DUVAR SAATI kurulus
            //             dilimine gore UTC ana cevrilir, yoksa girilen 14:30
            //             ekranda 17:30 goruntusu verirdi.
            "tarih" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var g)
                         ? g
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: tarih cozulemedi ({s}).",
                               new AlanHatasi(alanAdi, "Gecersiz tarih.")),

            "zaman" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var t)
                         ? Saat.UtcYap(t, zamanDilimi)
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: tarih cozulemedi ({s}).",
                               new AlanHatasi(alanAdi, "Gecersiz tarih.")),

            // "json": jsonb kolonu (cihaz olcum eslemesi, time-out teyitleri,
            //   IOL formul tablosu). Metin olarak tasinir ama BURADA
            //   DOGRULANIR: bozuk JSON'u veritabanina birakmak, kullaniciya
            //   "22P02 invalid input syntax" diye anlasilmaz bir hata
            //   dondurmek demek. Yazarken `::jsonb` cast'i KartDeposu'nda.
            "json" => string.IsNullOrWhiteSpace(s)
                       ? null
                       : JsonGecerliMi(s)
                         ? s
                         : throw GentegreHatasi.Dogrulama($"{alanBasligi}: gecersiz JSON.",
                               new AlanHatasi(alanAdi, "Gecerli bir JSON degil.")),

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
    public static void UzunlukKontrol(KartAlani alan, object? deger, string alanYolu,
                                      bool kimlikKontrolu = true,
                                      KimlikKurali? kimlikKurali = null)
    {
        if (alan.EnFazlaUzunluk is { } sinir && deger is string s && s.Length > sinir)
            throw GentegreHatasi.Dogrulama($"{alan.Ad}: en fazla {sinir} karakter.",
                new AlanHatasi(alanYolu, $"En fazla {sinir} karakter."));

        // BICIM: yanlis TCKN sessizce durur ve aylar sonra "provizyon
        //   alinamiyor" olarak geri doner - girişte soylemek en ucuzu.
        //
        // TR DISI SUBEDE KONTROL YOK (666): T.C. kimlik numarasi Turkiye'ye
        //   ozgudur; Berlin subesinde acilan hastanin numarasi bu algoritmayi
        //   saglamaz ve kayit HIC acilamazdi.
        // BICIM KURUM PROFILINDEN (679): TR kurulumunda T.C. algoritmasi,
        //   yurt disinda serbest ya da kuruma ozel desen. Kural gelmediyse
        //   varsayilan ACIK kalir - sessizce kapanmasi kotudur.
        if (kimlikKontrolu && alan.Dogrulama == KimlikDogrulama.TcknTuru
            && (kimlikKurali ?? KimlikKurali.Varsayilan).Hata(deger?.ToString()) is { } mesaj)
            throw GentegreHatasi.Dogrulama($"{alan.Etiket}: {mesaj}",
                new AlanHatasi(alanYolu, mesaj));
    }

    /// <summary>jsonb alanina yazilacak metin gercekten JSON mu.</summary>
    private static bool JsonGecerliMi(string s)
    {
        try { using var _ = System.Text.Json.JsonDocument.Parse(s); return true; }
        catch (System.Text.Json.JsonException) { return false; }
    }
}
