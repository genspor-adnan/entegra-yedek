namespace Gentegre.Api.Servisler;

/// <summary>
/// AI REHBER — METİN İŞLERİ (447).
///
/// Soruyu anlamaya çalışan saf mantık: Türkçe sadeleştirme, kelime ayıklama,
/// bağlamsal kalıp tanıma. Veritabanı ve yetki bilmez; bu yüzden test edilmesi
/// ucuzdur ve `RehberServisi` yalnız akışı yönetir.
/// </summary>
public static class RehberMetin
{
    /// <summary>
    /// Soruyu AYIRT ETMEYEN kelimeler. "nasıl", "yapılır", "istiyorum" her
    /// soruda geçer; skorlamada kalırlarsa her konu her soruya eşit uzaklıkta
    /// olur ve eşleşme rastgeleleşir.
    /// </summary>
    private static readonly HashSet<string> Durak = new(StringComparer.Ordinal)
    {
        "nasil", "nerede", "nereden", "nedir", "icin", "bir", "bu", "su", "ile",
        "ben", "biz", "yapilir", "yaparim", "yapmak", "istiyorum", "acilir",
        "acmak", "olur", "lazim", "gerekir", "hangi", "kim", "var", "yok",
        "sistem", "sistemde", "ekran", "ekrani", "menu", "menude",
    };

    /// <summary>
    /// BAĞLAMSAL soru: "bu ekranda ne yapabilirim", "şu alan ne işe yarar".
    /// Cevap kullanıcının DURDUĞU ekrana bağlıdır - aynı soru başka ekranda
    /// başka cevap alır, katalog araması bunu bilemez.
    /// </summary>
    private static readonly string[] BaglamKaliplari =
    [
        "bu ekran", "bu sayfa", "burada", "buradan", "bu listede", "bu kart",
        "bu alan", "su alan", "bu kolon", "bu dugme", "ne yapabilirim",
        "ne ise yarar", "ne demek", "neler yapabilirim", "ne var",
    ];

    private const string TurkceHarfler = "ÇĞİIÖŞÜçğıiöşü";
    private const string AsciiHarfler  = "CGIIOSUcgiiosu";

    /// <summary>
    /// Türkçe harfleri ASCII'ye indirger — `fn_ara_metin` ile AYNI kural.
    /// İki taraf ayrı normalleştirirse "İstem" sorgusu "istem" satırını
    /// bulamaz (ICU tr-TR'de lower('I') = 'ı').
    /// </summary>
    public static string Sadelestir(string metin)
    {
        var sb = new System.Text.StringBuilder(metin.Length);
        foreach (var h in metin)
        {
            var i = TurkceHarfler.IndexOf(h);
            sb.Append(i >= 0 ? char.ToLowerInvariant(AsciiHarfler[i]) : char.ToLowerInvariant(h));
        }
        return sb.ToString();
    }

    /// <summary>Kelime ayıracı: jeton ve kelime ayıklama AYNI kuralı kullanır.</summary>
    private static readonly char[] Ayirac =
        [' ', '\t', '\n', '\r', ',', '.', '?', '!', ':', ';', '/', '(', ')',
         '\'', '"'];

    /// <summary>Sorudan anlamlı kelimeler (3+ harf, durak değil, en çok 12).</summary>
    public static string[] Kelimeler(string soru) =>
        Sadelestir(soru)
            .Split(Ayirac, StringSplitOptions.RemoveEmptyEntries)
            .Where(k => k.Length >= 3 && !Durak.Contains(k))
            .Distinct(StringComparer.Ordinal)
            .Take(12)
            .ToArray();

    public static bool BaglamsalMi(string soru)
    {
        var sade = Sadelestir(soru);
        return BaglamKaliplari.Any(k => sade.Contains(k, StringComparison.Ordinal));
    }

    /// <summary>Soru bir ALAN/kolon sorusu mu ("şu alan ne demek").</summary>
    public static bool AlanSorusuMu(string soru)
    {
        var sade = Sadelestir(soru);
        return sade.Contains("alan", StringComparison.Ordinal)
            || sade.Contains("kolon", StringComparison.Ordinal)
            || sade.Contains("ne demek", StringComparison.Ordinal);
    }

    /// <summary>
    /// Kolon eşleşme puanı: BAŞLIKTA geçen kelime iki, teknik adda geçen bir
    /// puan. "Delta alanı" sorusu hem `deltaOnceki` (başlık "Önceki") hem
    /// `deltaUyari` (başlık "Delta") kolonuna vuruyordu; başlık ağırlığı
    /// olmadan sıradaki ilk kolon kazanıyordu.
    /// </summary>
    public static int KolonPuani(string baslik, string ad, IEnumerable<string> kelimeler)
    {
        var sadeBaslik = Sadelestir(baslik);
        var sadeAd = Sadelestir(ad);
        var puan = 0;
        foreach (var k in kelimeler)
        {
            if (sadeBaslik.Contains(k, StringComparison.Ordinal)) puan += 2;
            else if (sadeAd.Contains(k, StringComparison.Ordinal)) puan += 1;
        }
        return puan;
    }

    /// <summary>
    /// ROL sorusu mu: *"kayıt kabul rolü ne yapabilir"*, *"hekimin yetkileri
    /// neler"*, *"benim rolüm"*.
    ///
    /// KELİME SINIRI şart: "kontrol" içinde de "rol" geçer. Bu yüzden sorunun
    /// JETONLARINA bakılır, metnin içine değil - "kalite kontrol nasıl yapılır"
    /// bir rol sorusu değildir.
    /// </summary>
    public static bool RolSorusuMu(string soru) =>
        Jetonlar(soru).Any(j => (j.StartsWith("rol", StringComparison.Ordinal)
                                 || j.StartsWith("yetki", StringComparison.Ordinal))
                                && j.Length <= 11);

    /// <summary>KENDİ rolünü soruyor: "benim rolüm", "rolüm ne yapabilir".</summary>
    public static bool KendiRoluMu(string soru)
    {
        var jeton = Jetonlar(soru);
        return jeton.Contains("benim", StringComparer.Ordinal)
            || jeton.Any(j => j is "rolum" or "rolumun" or "rolumde" or "yetkilerim"
                                   or "yetkim" or "yetkilerimi");
    }

    /// <summary>
    /// Rol ADINI aramak için kelimeler: soruyu kuran kalıp ("rolü", "ne
    /// yapabilir") rol adına karışmamalı - yoksa adında "yetki" geçmeyen her
    /// rol aynı puanı alır.
    /// </summary>
    public static string[] RolAramaKelimeleri(string soru) =>
        Kelimeler(soru)
            .Where(k => !k.StartsWith("rol", StringComparison.Ordinal)
                     && !k.StartsWith("yetki", StringComparison.Ordinal)
                     && k is not ("yapabilir" or "yapabilirim" or "yapar" or "neler"
                                  or "nelere" or "kimdir" or "benim" or "gorebilir"
                                  or "yapabilecek" or "tanimi" or "kullanici"))
            .ToArray();

    /// <summary>Sadeleştirilmiş jetonlar (durak kelimeler DAHİL).</summary>
    private static string[] Jetonlar(string soru) =>
        Sadelestir(soru).Split(Ayirac, StringSplitOptions.RemoveEmptyEntries);

    /// <summary>Alan sorusunun kendi kalıp kelimeleri kolon aramasına girmez.</summary>
    public static string[] AlanAramaKelimeleri(string soru) =>
        Kelimeler(soru).Where(k => k is not ("alan" or "kolon" or "demek" or "isaret"))
                       .ToArray();
}
