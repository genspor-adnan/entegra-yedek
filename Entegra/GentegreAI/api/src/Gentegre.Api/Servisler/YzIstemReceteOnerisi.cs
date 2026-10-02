using System.Globalization;
using System.Text.Json;

namespace Gentegre.Api.Servisler;

/// <summary>
/// YZ TETKİK ve İLAÇ ÖNERİSİ (kullanıcı: "tetkik istem ve reçeteye de bu
/// butondan ekle ve tetkik ile ilaç önerilerinde de bulunsun").
///
/// Bağlam <see cref="YzTaniOnerisi.Topla"/> ile AYNI (anonim; ad, soyad,
/// kimlik no gitmez) + bu muayenede istenmiş tetkikler / yazılmış ilaçlar.
///
/// <b>KATALOG DIŞI ÖNERİ YOK.</b>
/// <list type="bullet">
/// <item>Laboratuvar: modele aktif tetkik/panel listesi verilir, yalnız o
///   listeden KOD seçer; listede olmayan kod atılır.</item>
/// <item>Görüntüleme: model modalite + bölge yazar; sunucu radyoloji hizmet
///   kataloğunda (modalite + ad sözcükleri) eşleştirir, bulamazsa atar.</item>
/// <item>İlaç: model ETKEN MADDE yazar (doz YOK - hekim belirler); sunucu
///   ilaç kataloğunda ürün bulur, hastanın aktif alerjisindeki etken maddeyi
///   ayrıca eler. Etkileşim/alerji uyarısı reçeteye eklemede yine çalışır.</item>
/// </list>
/// </summary>
public static class YzIstemReceteOnerisi
{
    public static string TetkikYonergesi(string labListesi) => $$"""
        Sen bir hastane bilgi sisteminde HEKİME yardımcı klinik karar destek aracısın.
        Sana anonimleştirilmiş bir poliklinik muayenesi verilecek.

        Görevin: olası tanıları ayırt etmek / doğrulamak için hekimin isteyebileceği
        TETKİKLERİ önermek. Akılcı ol: yalnız karar değiştirecek tetkik, en fazla 8.
        - Bu muayenede zaten istenmiş tetkiği önerme.
        - Laboratuvar için YALNIZ aşağıdaki listeden KOD seç (listede yoksa önerme).
        - Görüntüleme için "modalite" (BT, MR, USG, Röntgen, Mamografi, DEXA) ve
          "bolge" (ör. "batın", "akciğer", "diz") yaz.
        - "gerekce": neyi ayırt edeceğini 20 sözcüğü geçmeden yaz.

        LABORATUVAR LİSTESİ (kod | ad):
        {{labListesi}}

        YALNIZ şu JSON'u döndür, başka metin yazma:
        {"oneriler":[{"tur":"lab","kod":"GLU","gerekce":"..."},
                     {"tur":"goruntuleme","modalite":"USG","bolge":"batın","gerekce":"..."}],
         "not":""}
        """;

    public const string IlacYonergesi = """
        Sen bir hastane bilgi sisteminde HEKİME yardımcı klinik karar destek aracısın.
        Sana anonimleştirilmiş bir poliklinik muayenesi verilecek.

        Görevin: mevcut / olası tanılar için hekimin değerlendirebileceği tedavi
        seçeneklerini ETKEN MADDE olarak önermek. En fazla 5.
        - Hastanın alerjisi olan etken maddeyi ve onunla çapraz reaksiyon riski
          yüksek olanı ÖNERME.
        - Kullandığı ilaçlarla ciddi etkileşimi olanı önerme; zaten kullandığını ya da
          bu muayenede yazılmış olanı tekrar önerme.
        - Yaşa ve cinsiyete (gebelik olasılığı) uygun ol.
        - İLK BASAMAK, güncel kılavuzlara uygun ilaç öner. Rezerv, toksisitesi yüksek ya
          da bu endikasyonda önerilmeyen ilacı (ör. farenjitte sistemik kloramfenikol)
          ÖNERME. Penisilin alerjisinde beta-laktam önerme.
        - Etken maddeyi Türkiye ilaç kataloğundaki TÜRKÇE yazımıyla yaz: "azitromisin"
          (azithromycin DEĞİL), "amoksisilin", "klaritromisin", "parasetamol",
          "ibuprofen", "metformin".
        - DOZ, süre, kutu YAZMA - hekim belirler.
        - "gerekce": hangi tanı / bulgu için olduğunu 20 sözcüğü geçmeden yaz.
        - Antibiyotik yalnız bakteriyel enfeksiyon bulgusu varsa.

        YALNIZ şu JSON'u döndür, başka metin yazma:
        {"oneriler":[{"etken":"parasetamol","gerekce":"..."}],"not":""}
        """;

    /// <summary>Modalite adı → radyoloji modalite kodu (istem ekranıyla aynı).</summary>
    public static int? ModaliteKodu(string? ad)
    {
        var a = (ad ?? "").Trim().ToLower(CultureInfo.GetCultureInfo("tr-TR"));
        return a switch
        {
            "bt" or "tomografi" or "bilgisayarlı tomografi" => 1,
            "mr" or "mri" or "manyetik rezonans" => 2,
            "usg" or "us" or "ultrason" or "ultrasonografi" or "doppler" => 3,
            "röntgen" or "rontgen" or "grafi" or "direkt grafi" or "x-ray" => 4,
            "mamografi" => 5,
            "dexa" or "kemik dansitometri" => 6,
            "anjiyo" or "anjiyografi" => 7,
            "skopi" or "floroskopi" => 8,
            _ => null,
        };
    }

    public sealed record LabOneri(string Kod, string Gerekce);
    public sealed record GoruntulemeOneri(int Modalite, string Bolge, string Gerekce);
    public sealed record IlacOneri(string Etken, string Gerekce);

    private sealed record HamTetkik(string? tur, string? kod, string? modalite, string? bolge, string? gerekce);
    private sealed record HamTetkikYanit(List<HamTetkik>? oneriler, string? not);
    private sealed record HamIlac(string? etken, string? gerekce);
    private sealed record HamIlacYanit(List<HamIlac>? oneriler, string? not);

    private static T? JsonBul<T>(string metin) where T : class
    {
        var bas = metin.IndexOf('{');
        var son = metin.LastIndexOf('}');
        if (bas < 0 || son <= bas) return null;
        try
        {
            return JsonSerializer.Deserialize<T>(metin[bas..(son + 1)],
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch (JsonException) { return null; }
    }

    private static string Kirp(string? s, int n = 300) { s = (s ?? "").Trim(); return s.Length > n ? s[..n] : s; }

    /// <summary>
    /// Tetkik yanıtı: lab kodu <paramref name="labKodlari"/> içinde değilse atılır,
    /// görüntülemede modalite tanınmıyorsa ya da bölge boşsa atılır.
    /// </summary>
    public static (List<LabOneri> Lab, List<GoruntulemeOneri> Goruntuleme, string Not, int Atilan) CozTetkik(
        string metin, IReadOnlySet<string> labKodlari)
    {
        var h = JsonBul<HamTetkikYanit>(metin);
        if (h is null) return ([], [], "", 0);
        var lab = new List<LabOneri>();
        var gor = new List<GoruntulemeOneri>();
        var atilan = 0;
        foreach (var o in (h.oneriler ?? []).Take(10))
        {
            var tur = (o.tur ?? "").Trim().ToLowerInvariant();
            if (tur.StartsWith("lab"))
            {
                var kod = (o.kod ?? "").Trim();
                var gercek = labKodlari.FirstOrDefault(k => string.Equals(k, kod, StringComparison.OrdinalIgnoreCase));
                if (gercek is null) { atilan++; continue; }
                if (lab.Any(x => x.Kod == gercek)) continue;
                lab.Add(new LabOneri(gercek, Kirp(o.gerekce)));
            }
            else
            {
                var m = ModaliteKodu(o.modalite);
                var bolge = Kirp(o.bolge, 60);
                if (m is null || bolge.Length == 0) { atilan++; continue; }
                gor.Add(new GoruntulemeOneri(m.Value, bolge, Kirp(o.gerekce)));
            }
        }
        return (lab, gor, Kirp(h.not), atilan);
    }

    /// <summary>İlaç yanıtı: etken madde adı sadeleştirilir (küçük harf, Türkçe).</summary>
    public static (List<IlacOneri> Oneriler, string Not) CozIlac(string metin)
    {
        var h = JsonBul<HamIlacYanit>(metin);
        if (h is null) return ([], "");
        var tr = CultureInfo.GetCultureInfo("tr-TR");
        var liste = new List<IlacOneri>();
        foreach (var o in (h.oneriler ?? []).Take(6))
        {
            var etken = Kirp(o.etken, 80).ToLower(tr);
            if (etken.Length < 3 || liste.Any(x => x.Etken == etken)) continue;
            liste.Add(new IlacOneri(etken, Kirp(o.gerekce)));
        }
        return (liste, Kirp(h.not));
    }

    /// <summary>
    /// Önerilen etken madde hastanın alerji listesindekiyle ÇAKIŞIYOR mu
    /// (biri ötekini içeriyorsa). Modele de söylendi; bu ikinci, kesin kapı.
    /// </summary>
    public static bool AlerjiCakisir(string etken, IEnumerable<string> alerjiler)
    {
        var tr = CultureInfo.GetCultureInfo("tr-TR");
        var adlar = new[] { etken.ToLower(tr).Trim(), TurkceYazim(etken) }.Distinct().ToArray();
        return alerjiler.Select(a => (a ?? "").ToLower(tr).Split('(')[0].Trim())
            .Where(a => a.Length >= 3)
            .Any(a => adlar.Any(e => a.Contains(e) || e.Contains(a)
                                     || CaprazGruplar.Any(g => g.Any(a.Contains) && g.Any(e.Contains))));
    }

    /// <summary>
    /// ÇAPRAZ ALERJİ GRUPLARI (kaba, güvenli tarafta): alerji ve öneri aynı
    /// gruptaysa öneri elenir. Penisilin alerjisi amoksisilini, sülfonamid
    /// alerjisi kotrimoksazolü yakalar. Kesin farmakolojik tablo değil - son
    /// kapı reçeteye eklemedeki alerji/etkileşim kontrolüdür.
    /// </summary>
    private static readonly string[][] CaprazGruplar =
    [
        ["penisilin", "amoksisilin", "ampisilin", "sultamisilin", "piperasilin", "benzatin", "fenoksimetil", "flukloksasilin"],
        ["sefalosporin", "sefazolin", "sefuroksim", "seftriakson", "sefiksim", "sefdinir", "sefpodoksim", "sefaleksin", "sefadroksil"],
        ["sülfonamid", "sulfonamid", "sülfametoksazol", "sulfametoksazol", "kotrimoksazol", "trimetoprim"],
        ["nsaid", "nsaii", "ibuprofen", "naproksen", "diklofenak", "deksketoprofen", "ketoprofen", "flurbiprofen", "etodolak", "meloksikam", "asetilsalisilik", "aspirin"],
        ["kinolon", "siprofloksasin", "levofloksasin", "moksifloksasin", "ofloksasin"],
        ["makrolid", "azitromisin", "klaritromisin", "eritromisin"],
    ];

    /// <summary>
    /// Bölge eş anlamlıları: hizmet kataloğu Türkçe ve Latince adları karışık
    /// kullanır ("Abdominal Renkli Doppler US", "Akciğer Grafisi", "Toraks BT").
    /// </summary>
    private static readonly Dictionary<string, string[]> BolgeEsleri = new()
    {
        ["batın"] = ["batın", "abdomen", "abdominal", "karın"],
        ["karın"] = ["karın", "batın", "abdomen", "abdominal"],
        ["akciğer"] = ["akciğer", "toraks", "göğüs"],
        ["göğüs"] = ["göğüs", "toraks", "akciğer"],
        ["beyin"] = ["beyin", "kranial", "kafa"],
        ["boyun"] = ["boyun", "servikal"],
        ["bel"] = ["bel", "lomber", "lumbosakral"],
        ["böbrek"] = ["böbrek", "renal", "üriner"],
        ["pelvis"] = ["pelvis", "pelvik"],
        ["kalp"] = ["kalp", "kardiyak", "ekokardiyografi"],
    };

    /// <summary>Her bölge sözcüğü için kabul edilen yazımlar (sözcük kendisi dahil).</summary>
    public static List<string[]> BolgeKosullari(string bolge)
        => BolgeSozcukleri(bolge).Select(s => BolgeEsleri.GetValueOrDefault(s) ?? [s]).ToList();

    /// <summary>
    /// İNGİLİZCE → TÜRKÇE YAZIM (yedek): model yönergeye rağmen "azithromycin"
    /// yazarsa katalogdaki "azitromisin" bulunsun. Yalnız ilk arama boş
    /// dönünce denenir; kaba ama INN'lerin çoğunda tutar (ph→f, th→t, y→i,
    /// ce/ci→se/si, c→k, x→ks, ll→l).
    /// </summary>
    public static string TurkceYazim(string etken)
    {
        var s = etken.ToLower(CultureInfo.GetCultureInfo("tr-TR"))
            .Replace("ph", "f").Replace("th", "t").Replace("ae", "e").Replace("qu", "kv")
            .Replace("y", "i").Replace("x", "ks");
        s = System.Text.RegularExpressions.Regex.Replace(s, "c(?=[eiı])", "s").Replace("c", "k");
        s = System.Text.RegularExpressions.Regex.Replace(s, @"(.)\1", "$1");
        return s;
    }

    /// <summary>Radyoloji hizmet adında aranacak bölge sözcükleri (modalite sözcükleri atılır).</summary>
    public static List<string> BolgeSozcukleri(string bolge)
    {
        var tr = CultureInfo.GetCultureInfo("tr-TR");
        return bolge.ToLower(tr).Split([' ', ',', '/', '-', '(', ')'], StringSplitOptions.RemoveEmptyEntries)
            .Where(s => s.Length >= 3 && ModaliteKodu(s) is null && s is not "ve" and not "ile" and not "tüm")
            .Distinct().Take(3).ToList();
    }
}
