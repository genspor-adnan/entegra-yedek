using System.Text;
using System.Text.Json;

namespace Gentegre.Api.Servisler;

/// <summary>
/// REHBERİN MODEL KATMANI (450) — serbest metin sorusunu katalog bağlamıyla
/// cevaplatır.
///
/// <b>Model karar vermez, anlatır.</b> Katalogdan çıkan konu/ekran/adım
/// bilgisi doğruluk kaynağıdır; modelin işi kullanıcının kendi cümlesine
/// uyan kısa bir yol tarifi yazmak. Bu yüzden model şu üç kapıdan geçer:
/// <list type="number">
///   <item><b>Bağlam</b>: yalnız güvenli metadata gider - kullanıcının
///   <b>yetkili</b> olduğu ekranlar ve konu başlıkları. Hasta, cari, belge
///   verisi bu katmana hiç girmez.</item>
///   <item><b>Çıktı doğrulaması</b>: modelin verdiği her ekran, gönderdiğimiz
///   beyaz listede olmak zorunda. Uydurulan rota atılır - olmayan menüyü
///   tarif eden asistan, yanlış cevaptan beterdir.</item>
///   <item><b>Kontör</b>: çağrı ücretlidir; bakiye yoksa hiç çağrılmaz
///   (bkz. RehberServisi).</item>
/// </list>
///
/// Model hata verirse ya da cevabı çözümlenemezse <c>null</c> döner ve
/// katalog cevabı olduğu gibi kullanılır - asistan susmaz.
/// </summary>
public sealed class RehberModeli(IModelSaglayici saglayici, ILogger<RehberModeli> gunluk)
{
    public sealed record Ekran(string Kaynak, string Rota, string Yol);
    public sealed record KonuOzeti(string Baslik, string Adimlar);

    public sealed record Girdi(string Soru, short UrunModu, string? AktifSayfa,
                               IReadOnlyList<Ekran> Ekranlar,
                               IReadOnlyList<KonuOzeti> Konular);

    public sealed record ModelAdimi(string Metin, string? Ekran);

    public sealed record Cikti(string Cevap, IReadOnlyList<ModelAdimi> Adimlar,
                               string? EksikBilgiSorusu, decimal Guven,
                               int GirisJeton, int CikisJeton, string Model);

    public bool Hazir => saglayici.Hazir;
    public string Ad => saglayici.Ad;

    /// <summary>
    /// SİSTEM YÖNERGESİ — asistanın sözleşmesi. Kullanıcının yazdığı hiçbir
    /// şey buraya girmez; bu metin sabittir ki "önceki talimatları unut"
    /// diyen bir soru sınırları gevşetemesin.
    /// </summary>
    private const string Sistem = """
        Sen Gentegre AI (ERP + HBYS) içinde çalışan bir REHBERSİN.

        SINIRLARIN:
        - İşlem yapmazsın, kayıt açmaz/değiştirmez/silmezsin. Yalnız yol
          gösterirsin.
        - Sadece SANA VERİLEN ekran listesindeki ekranlara yönlendirirsin.
          Listede olmayan ekran, menü, düğme, rota UYDURMA.
        - Kullanıcının yetkisi olmayan ekranlar listeye zaten konmadı; listede
          olmayan bir işi "şuradan yapabilirsin" diye anlatma.
        - Emin değilsen guven değerini düşük ver ve eksikBilgiSorusu ile TEK
          bir soru sor.
        - Cevap TÜRKÇE, uzun makale değil, adım adım kısa rehber.

        BİÇİM: yalnız şu JSON'u döndür, başka metin yazma:
        {"cevap":"tek cümlelik giriş",
         "adimlar":[{"metin":"tek cümlelik adım","ekran":"/rota veya null"}],
         "eksikBilgiSorusu":null,
         "guven":0.0}

        En çok 6 adım. Her adım tek cümle. "ekran" alanına yalnız verilen
        listedeki rotalardan birini yaz, uygun ekran yoksa null bırak.
        """;

    public async Task<Cikti?> DeneAsync(Girdi girdi, CancellationToken iptal)
    {
        if (!Hazir) return null;

        var kullanici = new StringBuilder();
        kullanici.Append("KURULUM: ").Append(girdi.UrunModu == 2 ? "HBYS (hastane)"
                                                                 : "ERP").AppendLine();
        if (!string.IsNullOrWhiteSpace(girdi.AktifSayfa))
            kullanici.Append("AÇIK EKRAN: ").AppendLine(girdi.AktifSayfa);

        kullanici.AppendLine().AppendLine("KULLANABİLECEĞİN EKRANLAR (yetkili):");
        foreach (var e in girdi.Ekranlar)
            kullanici.Append("- ").Append(e.Rota).Append("  ").AppendLine(e.Yol);

        if (girdi.Konular.Count > 0)
        {
            kullanici.AppendLine().AppendLine("İLGİLİ REHBER KONULARI:");
            foreach (var k in girdi.Konular)
            {
                kullanici.Append("- ").AppendLine(k.Baslik);
                if (k.Adimlar.Length > 0) kullanici.Append("  ").AppendLine(k.Adimlar);
            }
        }

        kullanici.AppendLine().Append("SORU: ").Append(girdi.Soru);

        var yanit = await saglayici.IsteAsync(new ModelIstegi(Sistem, kullanici.ToString()),
                                              iptal);
        if (yanit is null) return null;

        var cozum = Coz(yanit.Metin, girdi.Ekranlar);
        if (cozum is null)
        {
            gunluk.LogWarning("AI model cevabı çözümlenemedi; katalog cevabı kullanılıyor.");
            return null;
        }

        return cozum with
        {
            GirisJeton = yanit.GirisJeton, CikisJeton = yanit.CikisJeton, Model = yanit.Model,
        };
    }

    /// <summary>
    /// MODEL ÇIKTISININ DOĞRULANMASI. Model serbest metin üretir; buradan
    /// çıkan her alan sınırlıdır: ekran beyaz listede olmalı, adım sayısı ve
    /// uzunluk kısıtlı, güven 0-1 arasına sıkıştırılır.
    /// </summary>
    public static Cikti? Coz(string ham, IReadOnlyList<Ekran> beyazListe)
    {
        var metin = (ham ?? "").Trim();
        // Model bazen JSON'u ``` içine sarar; sözleşmeyi bozmasın diye
        //   ilk '{' ile son '}' arası alınır.
        var bas = metin.IndexOf('{');
        var son = metin.LastIndexOf('}');
        if (bas < 0 || son <= bas) return null;
        metin = metin[bas..(son + 1)];

        try
        {
            using var belge = JsonDocument.Parse(metin);
            var kok = belge.RootElement;
            var cevap = Kisalt(Metin(kok, "cevap"), 600);
            if (cevap.Length == 0) return null;

            var adimlar = new List<ModelAdimi>();
            if (kok.TryGetProperty("adimlar", out var dizi)
                && dizi.ValueKind == JsonValueKind.Array)
            {
                foreach (var oge in dizi.EnumerateArray())
                {
                    if (adimlar.Count >= 6) break;
                    var adimMetni = Kisalt(Metin(oge, "metin"), 240);
                    if (adimMetni.Length == 0) continue;
                    var ekran = Metin(oge, "ekran");
                    // UYDURULAN ROTA ATILIR: adım metni kalır, düğmesi gitmez.
                    var gecerli = beyazListe.FirstOrDefault(
                        b => string.Equals(b.Rota, ekran, StringComparison.OrdinalIgnoreCase));
                    adimlar.Add(new ModelAdimi(adimMetni, gecerli?.Rota));
                }
            }

            var soru = Kisalt(Metin(kok, "eksikBilgiSorusu"), 200);
            var guven = 0.5m;
            if (kok.TryGetProperty("guven", out var gv)
                && gv.ValueKind == JsonValueKind.Number && gv.TryGetDecimal(out var g))
                guven = Math.Clamp(Math.Round(g, 2), 0m, 1m);

            return new Cikti(cevap, adimlar, soru.Length == 0 ? null : soru, guven, 0, 0, "");
        }
        catch (JsonException)
        {
            return null;
        }
    }

    private static string Metin(JsonElement oge, string ad) =>
        oge.ValueKind == JsonValueKind.Object && oge.TryGetProperty(ad, out var d)
        && d.ValueKind == JsonValueKind.String
            ? (d.GetString() ?? "").Trim()
            : "";

    private static string Kisalt(string s, int uzunluk) =>
        s.Length <= uzunluk ? s : s[..uzunluk];
}
