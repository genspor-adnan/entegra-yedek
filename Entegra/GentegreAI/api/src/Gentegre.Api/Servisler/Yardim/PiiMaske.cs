using System.Text.RegularExpressions;

namespace Gentegre.Api.Servisler.Yardim;

/// <summary>
/// KİŞİSEL VERİ MASKESİ (871) — asistana yazılan metin sağlayıcıya, günlüğe ve
/// telemetriye çıkmadan önce buradan geçer.
///
/// <b>Neden:</b> kullanıcı "12345678901 numaralı hastanın sonucu nerede" diye
/// sorabilir. Soru sağlayıcıya olduğu gibi giderse TCKN kurum dışına çıkar;
/// günlüğe olduğu gibi yazılırsa <c>ai_rehber_log</c> bir hasta listesine
/// döner. Maske <b>geri alınamaz</b> ve <b>sunucuda</b> uygulanır - istemcinin
/// "ben maskeledim" demesine güvenilmez.
///
/// Kapsam bilinçli olarak geniş: TCKN, telefon, e-posta, IBAN ve 7+ haneli her
/// sayı dizisi (protokol / barkod / numune no). Yardım sorusunun anlamı bu
/// sayılara bağlı değildir; "protokol X'i nasıl kapatırım" sorusu X olmadan da
/// aynı cevabı alır.
/// </summary>
public static partial class PiiMaske
{
    [GeneratedRegex(@"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}")]
    private static partial Regex Eposta();

    [GeneratedRegex(@"\bTR\s?(\d\s?){24}\b", RegexOptions.IgnoreCase)]
    private static partial Regex Iban();

    /// <summary>+90 / 0 ile başlayan Türkiye cep ve sabit numaraları, ayraçlı biçimler dahil.</summary>
    [GeneratedRegex(@"(\+\s?90|\b0)\s?[\(\-]?\s?\d{3}\s?[\)\-]?\s?\d{3}\s?[\-\s]?\d{2}\s?[\-\s]?\d{2}\b")]
    private static partial Regex Telefon();

    /// <summary>7 ve üzeri ardışık hane: TCKN (11), protokol, barkod, numune, sipariş no.</summary>
    [GeneratedRegex(@"\b\d[\d\s\-]{5,}\d\b")]
    private static partial Regex UzunSayi();

    public const string EpostaYer = "[e-posta]";
    public const string IbanYer = "[IBAN]";
    public const string TelefonYer = "[telefon]";
    public const string KimlikYer = "[kimlik-no]";
    public const string SayiYer = "[numara]";

    /// <summary>
    /// Metindeki kişisel tanımlayıcıları yer tutucuyla değiştirir. Boş/null
    /// metin boş döner. Sıra önemli: e-posta ve IBAN önce (içlerindeki sayılar
    /// "uzun sayı" kuralına takılmasın), sonra telefon, en son kalan uzun
    /// sayılar (11 hane = kimlik, diğerleri = numara).
    /// </summary>
    public static string Uygula(string? metin)
    {
        if (string.IsNullOrEmpty(metin)) return "";
        var m = Eposta().Replace(metin, EpostaYer);
        m = Iban().Replace(m, IbanYer);
        m = Telefon().Replace(m, TelefonYer);
        m = UzunSayi().Replace(m, e =>
        {
            var haneler = e.Value.Count(char.IsDigit);
            if (haneler < 7) return e.Value;
            return haneler == 11 ? KimlikYer : SayiYer;
        });
        return m;
    }

    /// <summary>Metinde maskelenecek bir şey var mı (telemetri sayacı için).</summary>
    public static bool Iceriyor(string? metin)
        => !string.IsNullOrEmpty(metin) && !ReferenceEquals(Uygula(metin), metin)
           && Uygula(metin) != metin;
}
