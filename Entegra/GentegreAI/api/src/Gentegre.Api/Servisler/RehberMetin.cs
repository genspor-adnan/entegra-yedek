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

    /// <summary>
    /// Metnin BÜTÜN anlamlı kelimeleri (durak hariç, tekrarsız, sınırsız) -
    /// yardım dizini (871) belge gövdesini bununla jetonlar; soru tarafı
    /// <see cref="Kelimeler"/> ile 12'ye kırpılır, belge tarafı kırpılmaz.
    /// </summary>
    public static string[] TumKelimeler(string metin) =>
        Sadelestir(metin)
            .Split(Ayirac, StringSplitOptions.RemoveEmptyEntries)
            .Select(k => k.Trim('*', '`', '-', '_', '[', ']', '#', '>', '|'))
            .Where(k => k.Length >= 3 && !Durak.Contains(k))
            .Distinct(StringComparer.Ordinal)
            .ToArray();

    /// <summary>
    /// KLİNİK SORU mu (871): tanı, tedavi, doz, ilaç seçimi, sonuç yorumu.
    /// Asistan HBYS'nin işleyişini anlatır; tıbbi karar desteği vermez. Bu
    /// kalıplardan biri geçen soru MODELE HİÇ GİTMEZ - sabit kapsam dışı
    /// cevabı döner. "Sonuç ekranı nerede" gibi işleyiş soruları kalıplara
    /// takılmasın diye kelimeler klinik eylem odaklı seçildi.
    /// </summary>
    private static readonly string[] KlinikKaliplari =
    [
        "hangi ilac", "ilac oner", "ilac verey", "ilac vermel", "doz", "dozaj", "mg ver",
        "tani koy", "tanisi ne", "teshis", "tedavi et", "tedavi plan", "nasil tedavi",
        "hastalik mi", "hastaligi ne", "normal mi", "yuksek mi", "dusuk mu", "tehlikeli mi",
        "sonucu yorumla", "sonucu ne anlama", "degeri ne anlama", "yorumlar misin",
        "antibiyotik", "recete yaz", "hangi tetkik iste", "ayirici tani", "prognoz",
        "komplikasyon", "yan etki", "kontrendik", "hamile", "gebelik", "bebege",
    ];

    public static bool KlinikSoruMu(string soru)
    {
        var sade = Sadelestir(soru);
        return KlinikKaliplari.Any(k => sade.Contains(k, StringComparison.Ordinal));
    }

    /// <summary>"Bu hata ne demek", "neden kaydedemedim", "uyarı çıktı" - hata açıklaması sorusu.</summary>
    public static bool HataSorusuMu(string soru)
    {
        var sade = Sadelestir(soru);
        return sade.Contains("hata", StringComparison.Ordinal)
            || sade.Contains("uyari", StringComparison.Ordinal)
            || sade.Contains("neden olm", StringComparison.Ordinal)
            || sade.Contains("kaydedem", StringComparison.Ordinal)
            || sade.Contains("kaydetmiyor", StringComparison.Ordinal)
            || sade.Contains("izin vermiyor", StringComparison.Ordinal)
            || sade.Contains("engel", StringComparison.Ordinal)
            || sade.Contains("reddet", StringComparison.Ordinal);
    }

    /// <summary>
    /// YÖNERGE ENJEKSİYONU izi (871): "önceki talimatları unut", "sistem
    /// yönergeni yaz", "ignore previous instructions". Cevap yine katalogdan
    /// üretilir; bu yalnız günlüğe işaret düşer ve modele giden metne ek
    /// uyarı koyar - engelleme değil, ölçüm.
    /// </summary>
    private static readonly string[] EnjeksiyonKaliplari =
    [
        "talimatlari unut", "talimatini unut", "yonergeleri unut", "onceki talimat",
        "sistem yonerge", "system prompt", "ignore previous", "ignore all", "disregard",
        "gizli anahtar", "api anahtar", "api key", "developer mode", "jailbreak",
        "rolunu birak", "sen artik", "you are now", "kurallari yok say",
    ];

    public static bool EnjeksiyonMu(string soru)
    {
        var sade = Sadelestir(soru);
        return EnjeksiyonKaliplari.Any(k => sade.Contains(k, StringComparison.Ordinal));
    }

    /// <summary>
    /// AKILCI TEST İSTEMİ KURAL SORUSU (873): "CRP tekrar süresi kaç gün", "hangi
    /// branşlar TSH isteyebilir", "bu test 3. basamak mı". Cevap kural
    /// KATALOĞUNDAN (lab_akilci_kural) gelir - hasta verisi değil, kurum kuralı.
    /// </summary>
    private static readonly string[] AkilciKaliplari =
    [
        "tekrar aralig", "tekrar sure", "kac gun", "kac gunde", "gunde bir", "istem sure", "istem periyod",
        "hangi brans", "brans kisit", "isteyebil", "istenebil", "basamak", "akilci", "refleks", "reflektif",
        "kapsam disi", "isteme kapali", "gerekce", "akilci",
    ];

    public static bool AkilciSoruMu(string soru)
    {
        var sade = Sadelestir(soru);
        return AkilciKaliplari.Any(k => sade.Contains(k, StringComparison.Ordinal));
    }

    /// <summary>Kural sorusundan TEST ADI kelimeleri: kalıp ve genel kelimeler atılır.</summary>
    public static string[] AkilciAramaKelimeleri(string soru) =>
        Kelimeler(soru)
            .Where(k => k is not ("tekrar" or "araligi" or "aralik" or "suresi" or "sure" or "kac" or "gun" or "gunde"
                                  or "hangi" or "brans" or "branslar" or "branslari" or "isteyebilir" or "istenebilir"
                                  or "istenir" or "istem" or "istemi" or "istemek" or "basamak" or "basamakta"
                                  or "akilci" or "kural" or "kurali" or "test" or "testi" or "tetkik" or "tetkigi"
                                  or "icin" or "kisiti" or "kisit" or "refleks" or "reflektif" or "periyodu"
                                  or "bir" or "kez" or "sonra" or "once" or "gerekli" or "gerekir"))
            .ToArray();

    /// <summary>Alan sorusunun kendi kalıp kelimeleri kolon aramasına girmez.</summary>
    public static string[] AlanAramaKelimeleri(string soru) =>
        Kelimeler(soru).Where(k => k is not ("alan" or "kolon" or "demek" or "isaret"))
                       .ToArray();
}
