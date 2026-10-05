namespace Gentegre.Cekirdek.Uts;

/// <summary>
/// ÜTS'nin KABUL ETTİĞİ KOD LİSTELERİ (metin kodlar).
///
/// <para><b>Neden burada:</b> HEK / zayiat türü ve imha gerekçesi ÜTS'de sabit
/// metin kodlardır. Sunucu bu kodları <b>doğrulamıyordu</b> - yalnız "boş mu"
/// ve "DIGER ise açıklama var mı" diye bakıyordu; yazım hatalı bir kod
/// ÜTS'ye gidiyor ve ÜTS'nin reddiyle geri dönüyordu (bir ağ turu, anlaşılmaz
/// hata metni). Geçerli liste ayrıca hata mesajının içinde elle yazılıydı -
/// liste değişince mesaj eski kalırdı.</para>
///
/// <para>Etiketler (ekranda görünen Türkçe adlar) istemcidedir
/// (<c>web/src/bilesenler/uts/UtsGenelBildirimModali.tsx</c>); burada yalnız
/// ÜTS'ye giden KODLAR var.</para>
/// </summary>
public static class UtsKodlari
{
    /// <summary>HEK / zayiat türü (s74) - <c>TUR</c> alanı.</summary>
    public static readonly string[] HekTurleri =
        ["HEK", "DOGAL_AFET", "YANGIN", "CALINMA", "STOK_DUZELTME", "DIGER"];

    /// <summary>İmha / bertaraf gerekçesi (s83) - <c>GRK</c> alanı.</summary>
    public static readonly string[] ImhaGerekceleri =
    [
        "KURUM_KARARI", "GONULLU_GERI_CEKME", "SON_KULLANMA_TARIHI_GECMIS",
        "SAHTE_KACAK", "TASIMA_VE_SAKLAMA_KOSULLARI_BOZULMUS",
        "HASTANIN_VUCUDUNDAN_CIKARILMIS", "DIGER",
    ];

    /// <summary>"Diğer" seçildiğinde açıklama zorunlu olan kod.</summary>
    public const string Diger = "DIGER";

    /// <summary>Hata mesajındaki geçerli değer listesi - elle yazılmaz.</summary>
    public static string Liste(string[] kodlar) => string.Join(", ", kodlar) + ".";
}
