using System.Security.Cryptography;
using System.Text;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Veri;

/// <summary>
/// ENTEGRASYON SIRLARI DB'DE ŞİFRELİ (kod inceleme 30.10.2026 K28): e-Belge, e-Nabız, SMS, SMTP, sigorta,
/// banka, ÜTS kimlikleri `entegrasyon_hesap.sifre`'de düz metindi - bir DB yedeği ya da salt-okur erişim bütün
/// dış hesapları açıyordu. Değer AES-256-GCM ile şifrelenir; anahtar DB'de DEĞİL, kurulum klasöründe
/// (`Guvenlik:VeriAnahtari`, appsettings.Gizli.json - yayin/sunucu-guncelle.sh üretir).
///
/// Biçim: <c>enc1:</c> + base64(nonce[12] | şifreli metin | etiket[16]). Önek sürümü taşır; anahtar ya da
/// algoritma değişirse <c>enc2:</c> yan yana okunabilir.
///
/// GEÇİŞ: önek taşımayan değer ESKİ DÜZ METİNDİR ve olduğu gibi döner (Delphi aktarımı, eski satırlar) -
/// <c>GizliMetinTarayici</c> bunları arka planda şifreler. Çözülemeyen değer (başka kurulumun anahtarı, bozuk
/// veri) sessizce boş sayılmaz: iş kuralı hatasıyla "yeniden girin" denir.
///
/// Statik: okuyucular servis, depo ve uçlara dağınık; <see cref="Saat"/> gibi süreç başında bir kez kurulur.
/// </summary>
public static class GizliMetin
{
    public const string Onek = "enc1:";

    /// <summary>Kartta dolu sırrın yerine dönen işaret; kayıtta bu gelirse alan DEĞİŞMEZ.</summary>
    public const string Maske = "••••••••";

    /// <summary>Depodaki appsettings.json'da duran geliştirme anahtarı (Production'da reddedilir).</summary>
    public const string GelistirmeAnahtari = "Z2VsaXN0aXJtZS12ZXJpLWFuYWh0YXJpLTMyYmF5dCE=";

    private static byte[]? _anahtar;

    public static bool Kurulu => _anahtar is not null;

    /// <summary>Anahtarı kurar (base64, 32 bayt). Production'da geliştirme anahtarı kabul edilmez.</summary>
    public static void Kur(string? anahtarBase64, bool uretim)
    {
        if (string.IsNullOrWhiteSpace(anahtarBase64))
            throw new InvalidOperationException(
                "Veri şifreleme anahtarı (Guvenlik:VeriAnahtari) yok. Kurulumda appsettings.Gizli.json'a "
                + "yayin/sunucu-guncelle.sh yazar; geliştirmede appsettings.json'daki değer kullanılır.");
        if (uretim && anahtarBase64 == GelistirmeAnahtari)
            throw new InvalidOperationException(
                "Üretim ortamında veri şifreleme anahtarı geliştirme anahtarı olamaz (appsettings.Gizli.json).");
        byte[] a;
        try { a = Convert.FromBase64String(anahtarBase64.Trim()); }
        catch (FormatException) { throw new InvalidOperationException("Guvenlik:VeriAnahtari base64 değil."); }
        if (a.Length != 32)
            throw new InvalidOperationException($"Guvenlik:VeriAnahtari 32 bayt olmalı (gelen {a.Length}).");
        _anahtar = a;
    }

    public static bool SifreliMi(string? deger) => deger is not null && deger.StartsWith(Onek, StringComparison.Ordinal);

    /// <summary>Boş/null olduğu gibi döner; zaten şifreliyse yeniden şifrelenmez.</summary>
    public static string? Sifrele(string? duz)
    {
        if (string.IsNullOrEmpty(duz) || SifreliMi(duz)) return duz;
        var anahtar = _anahtar ?? throw new InvalidOperationException("Veri şifreleme anahtarı kurulmadı.");
        var acik = Encoding.UTF8.GetBytes(duz);
        var cikti = new byte[12 + acik.Length + 16];
        var nonce = cikti.AsSpan(0, 12);
        RandomNumberGenerator.Fill(nonce);
        using var gcm = new AesGcm(anahtar, 16);
        gcm.Encrypt(nonce, acik, cikti.AsSpan(12, acik.Length), cikti.AsSpan(12 + acik.Length, 16));
        return Onek + Convert.ToBase64String(cikti);
    }

    /// <summary>
    /// Şifreli değeri çözer; önek yoksa (eski düz metin) olduğu gibi döner, boş/null → "".
    /// Çözülemezse <see cref="GentegreHatasi.IsKurali"/> - sır bu kurulumun anahtarıyla yazılmamış.
    /// </summary>
    public static string Coz(string? deger)
    {
        if (string.IsNullOrEmpty(deger)) return "";
        if (!SifreliMi(deger)) return deger;
        var anahtar = _anahtar ?? throw new InvalidOperationException("Veri şifreleme anahtarı kurulmadı.");
        try
        {
            var veri = Convert.FromBase64String(deger[Onek.Length..]);
            if (veri.Length < 28) throw new CryptographicException("kısa");
            var uzunluk = veri.Length - 28;
            var acik = new byte[uzunluk];
            using var gcm = new AesGcm(anahtar, 16);
            gcm.Decrypt(veri.AsSpan(0, 12), veri.AsSpan(12, uzunluk), veri.AsSpan(12 + uzunluk, 16), acik);
            return Encoding.UTF8.GetString(acik);
        }
        catch (Exception h) when (h is CryptographicException or FormatException)
        {
            throw GentegreHatasi.IsKurali(
                "Kayıtlı şifre / token bu kurulumun anahtarıyla çözülemedi (başka kurulumdan taşınmış olabilir). "
                + "Yönetim › Ayarlar › Genel › Entegrasyon'da yeniden girin.");
        }
    }
}
