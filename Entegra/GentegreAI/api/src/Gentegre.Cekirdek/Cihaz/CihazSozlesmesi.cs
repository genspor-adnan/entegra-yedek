using System.Globalization;

namespace Gentegre.Cekirdek.Cihaz;

/// <summary>
/// CİHAZ ARA KATMANI — KANONİK MESAJ (432).
///
/// <para>Biyokimya analizörü HL7 v2, otoref ASTM, bazı cihazlar da düz dosya
/// gönderiyor. Uygulamanın geri kalanı bu üçünü ayırt etmez: sürücü BİÇİMİ
/// çevirir, kayıt ve kural tek yerde durur. Aynı disiplin sigorta (430) ve ÜTS
/// entegrasyonunda da var.</para>
///
/// <para><b>Değer METİN taşınır.</b> Cihaz "&lt;0.01", "POZİTİF", "1,25"
/// gönderebiliyor; sayıya zorlamak bu üçünü de kaybettirirdi. Sayısal karşılık
/// ayrı alanda, çevrilebiliyorsa doldurulur.</para>
/// </summary>
public sealed record CihazMesaji(
    string Protokol,
    string MesajTipi,
    string KontrolNo,
    string OrnekNo,
    string IstemNo,
    string HastaNo,
    DateTime? CihazZamani,
    IReadOnlyList<CihazKalemi> Kalemler,
    string Hata = "")
{
    public bool Gecerli => Hata.Length == 0;
}

public sealed record CihazKalemi(
    int Sira,
    string TestKodu,
    string TestAdi,
    string Deger,
    decimal? Sayisal,
    string Birim,
    string Referans,
    string Isaret,
    string Durum,
    DateTime? OlcumZamani,
    string Aciklama = "");

/// <summary>
/// Bir cihaz protokolünün çözümleyicisi. Uygulama yalnız
/// <see cref="Coz"/> sonucunu görür.
///
/// SÜRÜCÜ I/O YAPMAZ: bağlantıyı (TCP dinleyici, klasör tarama) ara katman
/// yürütür, sürücü yalnız METNİ çevirir. Böylece protokol çözümlemesi
/// veritabanı ve ağ olmadan test edilebiliyor.
/// </summary>
public interface ICihazSurucu
{
    /// <summary>Sürücü kodu - <c>cihaz.surucu</c> kolonundaki değer.</summary>
    string Kod { get; }

    CihazMesaji Coz(string ham);
}

/// <summary>Sayı ve tarih çevrimi - sürücüler arasında ortak.</summary>
public static class CihazCevrim
{
    /// <summary>
    /// Cihaz sayıyı "1.25" ya da "1,25" gönderebiliyor; "&lt;0.01" gibi
    /// eşik değerleri sayı DEĞİLDİR - null döner, metin hâli korunur.
    /// </summary>
    public static decimal? Sayi(string? deger)
    {
        if (string.IsNullOrWhiteSpace(deger)) return null;
        var m = deger.Trim().Replace(',', '.');
        return decimal.TryParse(m, NumberStyles.Any, CultureInfo.InvariantCulture, out var s)
            ? s : null;
    }

    /// <summary>
    /// HL7/ASTM zaman damgası: yyyyMMdd[HHmm[ss]]. Kısa biçimler de gelir
    /// (yalnız tarih), saat dilimi eki (+0300) yok sayılır - cihaz yerel
    /// saatiyle konuşur.
    /// </summary>
    public static DateTime? Zaman(string? ham)
    {
        if (string.IsNullOrWhiteSpace(ham)) return null;
        var m = ham.Trim();
        var artı = m.IndexOfAny(['+', '-']);
        if (artı > 7) m = m[..artı];
        m = new string([.. m.Where(char.IsDigit)]);
        string[] bicimler = ["yyyyMMddHHmmss", "yyyyMMddHHmm", "yyyyMMddHH", "yyyyMMdd"];
        foreach (var b in bicimler)
            if (m.Length >= b.Length &&
                DateTime.TryParseExact(m[..b.Length], b, CultureInfo.InvariantCulture,
                                       DateTimeStyles.None, out var t))
                return t;
        return null;
    }
}
