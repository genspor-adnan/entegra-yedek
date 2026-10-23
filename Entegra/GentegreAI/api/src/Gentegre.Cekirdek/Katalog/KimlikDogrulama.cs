namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// T.C. KİMLİK NUMARASI DOĞRULAMASI (NVİ algoritması).
///
/// Kural (Nüfus ve Vatandaşlık İşleri):
///   - 11 hane, hepsi rakam, ilk hane 0 olamaz,
///   - 10. hane = ((1,3,5,7,9. hanelerin toplamı × 7) − (2,4,6,8. hanelerin
///     toplamı)) mod 10,
///   - 11. hane = ilk 10 hanenin toplamı mod 10.
///
/// NEDEN SUNUCUDA: numara kayıt kabulde elle giriliyor ve yanlış TCKN sessizce
/// duruyor - MEDULA provizyonu, e-Nabız gönderimi ve e-Belge alıcı bilgisi
/// hepsi bu numaraya bakıyor. Hata aylar sonra "provizyon alınamıyor" olarak
/// geri dönüyor; girişte söylemek en ucuzu.
///
/// BOŞ DEĞER GEÇERLİ SAYILIR: zorunluluk ayrı bir karardır (kimliği belirsiz
/// hasta TCKN'siz açılabilir - `kimliksiz` bayrağı). Burada yalnız "yazılan
/// numara tutarlı mı" sorusu cevaplanır.
/// </summary>
public static class KimlikDogrulama
{
    /// <summary>Doğrulama türü adı - `KartAlani.Dogrulama` bu değeri taşır.</summary>
    public const string TcknTuru = "tckn";

    public static bool TcknGecerli(string? deger)
    {
        var s = (deger ?? "").Trim();
        if (s.Length == 0) return true;                 // bos = kontrol yok
        if (s.Length != 11) return false;
        foreach (var c in s) if (c is < '0' or > '9') return false;
        if (s[0] == '0') return false;

        var h = new int[11];
        for (var i = 0; i < 11; i++) h[i] = s[i] - '0';

        var tek = h[0] + h[2] + h[4] + h[6] + h[8];     // 1,3,5,7,9. haneler
        var cift = h[1] + h[3] + h[5] + h[7];           // 2,4,6,8. haneler
        var onuncu = ((tek * 7) - cift) % 10;
        if (onuncu < 0) onuncu += 10;                   // negatif mod (C# semantigi)
        if (onuncu != h[9]) return false;

        var ilkOn = 0;
        for (var i = 0; i < 10; i++) ilkOn += h[i];
        return ilkOn % 10 == h[10];
    }

    /// <summary>IBAN doğrulama türü (1153, cari banka hesapları).</summary>
    public const string IbanTuru = "iban";

    /// <summary>
    /// IBAN: boşluklar atılır, 2 harf ülke + 2 hane kontrol + 11-30 alfasayısal; TR ise 26 hane.
    /// ISO 13616 mod-97: ilk dört karakter sona alınır, harfler 10-35 olur, kalan 1 olmalı. Boş geçerli.
    /// </summary>
    public static bool IbanGecerli(string? deger)
    {
        var s = (deger ?? "").Replace(" ", "").ToUpperInvariant();
        if (s.Length == 0) return true;
        if (s.Length < 15 || s.Length > 34) return false;
        if (!char.IsAsciiLetterUpper(s[0]) || !char.IsAsciiLetterUpper(s[1])
            || !char.IsAsciiDigit(s[2]) || !char.IsAsciiDigit(s[3])) return false;
        if (s.StartsWith("TR") && s.Length != 26) return false;
        var kalan = 0;
        foreach (var c in s[4..] + s[..4])
        {
            if (char.IsAsciiDigit(c)) kalan = (kalan * 10 + (c - '0')) % 97;
            else if (char.IsAsciiLetterUpper(c)) kalan = (kalan * 100 + (c - 'A' + 10)) % 97;
            else return false;
        }
        return kalan == 1;
    }

    /// <summary>IBAN geçersizse kullanıcıya gidecek mesaj.</summary>
    public static string? IbanHata(object? deger)
        => IbanGecerli(deger?.ToString()) ? null
           : "IBAN geçersiz - ülke kodu ve kontrol haneleri tutmuyor (TR IBAN 26 karakter).";

    /// <summary>Alan doğrulaması - geçersizse kullanıcıya gidecek mesaj, geçerliyse null.</summary>
    public static string? Hata(string? tur, object? deger)
    {
        if (tur != TcknTuru) return null;
        var metin = deger?.ToString();
        return TcknGecerli(metin)
            ? null
            : "Kimlik numarası geçersiz - 11 hane olmalı ve doğrulama hanesi tutmalı.";
    }
}
