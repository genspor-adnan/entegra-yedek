using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace Gentegre.Aktarim.Ajan;

/// <summary>
/// ajan.json. Sırlar (API anahtarı, MSSQL bağlantısı) düz yazılabilir; <c>--sifrele</c>
/// onları DPAPI (makine kapsamı - servis hesabı da çözer) ile <c>*Sifreli</c> alanlara
/// taşır ve düz alanı boşaltır. Şifreli değer yalnız o makinede çözülür.
/// </summary>
public sealed class Ayarlar
{
    public string ApiAdres { get; set; } = "";
    public string Anahtar { get; set; } = "";
    public string AnahtarSifreli { get; set; } = "";
    public string MssqlBaglanti { get; set; } = "";
    public string MssqlBaglantiSifreli { get; set; } = "";
    public int YoklamaSn { get; set; } = 5;
    public int NabizSn { get; set; } = 60;
    public int PaketMb { get; set; } = 32;
    public string GunlukKlasoru { get; set; } = "gunluk";

    private static readonly byte[] Tuz = "Gentegre.Aktarim.Ajan"u8.ToArray();
    private static readonly JsonSerializerOptions Secenek = new() { WriteIndented = true };

    public string GercekAnahtar => Coz(Anahtar, AnahtarSifreli);
    public string GercekBaglanti => Coz(MssqlBaglanti, MssqlBaglantiSifreli);

    public static Ayarlar Oku(string yol)
    {
        if (!File.Exists(yol))
            throw new FileNotFoundException($"Ayar dosyası yok: {yol} (ajan.ornek.json'dan kopyalayın).");
        var a = JsonSerializer.Deserialize<Ayarlar>(File.ReadAllText(yol)) ?? new Ayarlar();
        if (string.IsNullOrWhiteSpace(a.ApiAdres)) throw new InvalidOperationException("ApiAdres boş.");
        if (!a.ApiAdres.EndsWith('/')) a.ApiAdres += "/";
        if (a.YoklamaSn < 1) a.YoklamaSn = 1;
        if (a.PaketMb is < 1 or > 60) a.PaketMb = 32;   // sunucu sınırı 64 MB
        return a;
    }

    /// <summary>Düz sırları şifreler, dosyayı yeniden yazar. Kaç alan şifrelendiğini döner.</summary>
    public static int Sifrele(string yol)
    {
        var a = JsonSerializer.Deserialize<Ayarlar>(File.ReadAllText(yol)) ?? new Ayarlar();
        var n = 0;
        if (a.Anahtar != "") { a.AnahtarSifreli = Sifre(a.Anahtar); a.Anahtar = ""; n++; }
        if (a.MssqlBaglanti != "") { a.MssqlBaglantiSifreli = Sifre(a.MssqlBaglanti); a.MssqlBaglanti = ""; n++; }
        File.WriteAllText(yol, JsonSerializer.Serialize(a, Secenek));
        return n;
    }

    private static string Sifre(string s)
        => Convert.ToBase64String(ProtectedData.Protect(Encoding.UTF8.GetBytes(s), Tuz, DataProtectionScope.LocalMachine));

    private static string Coz(string duz, string sifreli)
        => duz != "" ? duz
         : sifreli != "" ? Encoding.UTF8.GetString(ProtectedData.Unprotect(Convert.FromBase64String(sifreli), Tuz, DataProtectionScope.LocalMachine))
         : "";
}
