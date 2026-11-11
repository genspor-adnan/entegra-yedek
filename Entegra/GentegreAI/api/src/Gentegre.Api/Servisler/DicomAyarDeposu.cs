using System.Text.Json;
using Gentegre.Veri;
using Microsoft.Extensions.Options;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PACS (DICOM) AYARLARI ENTEGRASYON EKRANINDAN (1316; kullanıcı 12.11.2026: "clearcanvas a bağlantı ayarları için
/// entegrasyon ekranına baktım göremedim" → mockup Ekranlar/Ayarlar/entegrasyon_pacs.html → "başla").
///
/// Kaynak sırası: şubenin aktif PACS satırı → kurum geneli PACS satırı (şube boş) → appsettings › Dicom (satır yoksa
/// eski davranış; mevcut kurulumlar bozulmaz). Satır alanları: kullanici_adi = bizim AE, uygulama_kodu = PACS AE,
/// url = WADO adresi, ayarlar (jsonb) = sunucu · port · zamanAsimiSn · goruntuleyiciUrl · jetonDakika · urun. Sunucu
/// DİNLEYİCİLERİ (MWL portu / AE / karakter seti) daima dosyadan - port değişimi yeniden başlatma ister.
///
/// ÖNBELLEK: ayar her DICOM çağrısında okunur, bu yüzden bellekte durur. 5 saniyeden eski anlık görüntü arka planda
/// PACS satırlarının imzasıyla (xmin listesi) karşılaştırılır; değişmişse yeniden yüklenir - kart kaydedildikten birkaç
/// saniye sonra geçerli, API yeniden başlatılmaz.
///
/// ŞUBE KAPSAMI: çağrı zinciri boyunca <see cref="Kapsam"/> (AsyncLocal) - uçlar bağlamın şubesini, Teletıp işçisi
/// satırın şubesini, dışa açık WADO KOS satırının şubesini koyar. Kapsam yoksa kurum geneli.
/// </summary>
public sealed class DicomAyarDeposu(IOptions<DicomAyarlari> dosya, VeriKaynagi veri, ILogger<DicomAyarDeposu> gunluk)
{
    private sealed record Anlik(DicomAyarlari? Genel, Dictionary<int, DicomAyarlari> Subeler, string Imza, DateTime Zaman);

    private static readonly AsyncLocal<int?> KapsamDegeri = new();
    private static readonly TimeSpan Tazelik = TimeSpan.FromSeconds(5);
    private volatile Anlik? _anlik;
    private int _tazeleniyor;

    /// <summary>Etkin şube kapsamı (null = kurum geneli).</summary>
    public static int? Kapsam => KapsamDegeri.Value;

    /// <summary>Bu async akış boyunca DICOM çağrıları şubenin PACS'ına gider; Dispose önceki kapsama döner.</summary>
    public static IDisposable SubeIcin(int? subeId)
    {
        var onceki = KapsamDegeri.Value;
        KapsamDegeri.Value = subeId is > 0 ? subeId : null;
        return new Geri(() => KapsamDegeri.Value = onceki);
    }

    private sealed class Geri(Action a) : IDisposable { public void Dispose() => a(); }

    /// <summary>Dosyadaki (appsettings › Dicom) ayar - dinleyiciler ve satır yokken.</summary>
    public DicomAyarlari Dosya => dosya.Value;

    /// <summary>Şubenin (verilmezse kapsamın) geçerli PACS ayarı.</summary>
    public DicomAyarlari Gecerli(int? subeId = null)
    {
        var a = AnlikAl();
        var s = subeId ?? Kapsam;
        if (s is int sube && a.Subeler.TryGetValue(sube, out var x)) return x;
        return a.Genel ?? dosya.Value;
    }

    /// <summary>Ayar entegrasyon ekranından mı (true) yoksa dosyadan mı.</summary>
    public bool EkrandanMi(int? subeId = null)
    {
        var a = AnlikAl();
        var s = subeId ?? Kapsam;
        return (s is int sube && a.Subeler.ContainsKey(sube)) || a.Genel is not null;
    }

    /// <summary>Bir sonraki okuma ayarı hemen (eşzamanlı) yeniden yükler - sınama sonrası.</summary>
    public void Gecersiz() => _anlik = null;

    private Anlik AnlikAl()
    {
        var a = _anlik;
        if (a is null)
        {
            a = YukleAsync(CancellationToken.None).GetAwaiter().GetResult();
            _anlik = a;
            return a;
        }
        if (DateTime.UtcNow - a.Zaman > Tazelik && Interlocked.Exchange(ref _tazeleniyor, 1) == 0)
        {
            _ = Task.Run(async () =>
            {
                try
                {
                    var imza = await ImzaAsync(CancellationToken.None);
                    _anlik = imza == a.Imza ? a with { Zaman = DateTime.UtcNow } : await YukleAsync(CancellationToken.None);
                }
                catch (Exception h) { gunluk.LogWarning(h, "PACS ayarları tazelenemedi; son bilinen ayar kullanılıyor."); }
                finally { Interlocked.Exchange(ref _tazeleniyor, 0); }
            });
        }
        return a;
    }

    private Task<string> ImzaAsync(CancellationToken iptal) => veri.TekDegerAsync<string>(
        "select coalesce(string_agg(id::text || ':' || xmin::text, ',' order by id), '') from public.entegrasyon_hesap where kod = 'PACS'",
        null, iptal)!;

    private async Task<Anlik> YukleAsync(CancellationToken iptal)
    {
        try
        {
            var imza = await ImzaAsync(iptal) ?? "";
            var satirlar = await veri.ListeAsync("""
                select coalesce(sube_id, 0), kullanici_adi, uygulama_kodu, url, ayarlar::text
                  from public.entegrasyon_hesap
                 where kod = 'PACS' and aktif = 1
                 order by test_mi, id
                """, null, o => (Sube: Convert.ToInt32(o.GetValue(0)), BizimAe: o.GetString(1), PacsAe: o.GetString(2), Url: o.GetString(3),
                                 Ayarlar: o.IsDBNull(4) ? "{}" : o.GetString(4)), iptal);
            DicomAyarlari? genel = null;
            var subeler = new Dictionary<int, DicomAyarlari>();
            foreach (var s in satirlar)
            {
                var ayar = Coz(dosya.Value, s.BizimAe, s.PacsAe, s.Url, s.Ayarlar);
                if (s.Sube == 0) genel ??= ayar;            // canlı (test_mi 0) önce gelir
                else subeler.TryAdd(s.Sube, ayar);
            }
            return new Anlik(genel, subeler, imza, DateTime.UtcNow);
        }
        catch (Exception h) when (h is not OperationCanceledException)
        {
            gunluk.LogWarning(h, "PACS ayarları okunamadı; dosyadaki (Dicom) ayar kullanılıyor.");
            return new Anlik(null, [], "", DateTime.UtcNow);
        }
    }

    /// <summary>Satırdan ayar: boş alan dosyadaki değerle tamamlanır; dinleyici (MWL) alanları daima dosyadan.</summary>
    public static DicomAyarlari Coz(DicomAyarlari taban, string bizimAe, string pacsAe, string url, string ayarlarJson)
    {
        string? M(JsonElement k, string ad) => k.ValueKind == JsonValueKind.Object && k.TryGetProperty(ad, out var e)
            ? (e.ValueKind == JsonValueKind.String ? e.GetString() : e.ToString()) : null;
        int Sayi(string? s, int v) => int.TryParse(s, out var x) && x > 0 ? x : v;
        using var j = JsonDocument.Parse(string.IsNullOrWhiteSpace(ayarlarJson) ? "{}" : ayarlarJson);
        var k = j.RootElement;
        static string D(string? s, string v) => string.IsNullOrWhiteSpace(s) ? v : s.Trim();
        return new DicomAyarlari
        {
            Aktif = true,
            Sunucu = D(M(k, "sunucu"), taban.Sunucu),
            Port = Sayi(M(k, "port"), taban.Port),
            SunucuAe = D(pacsAe, taban.SunucuAe),
            BizimAe = D(bizimAe, taban.BizimAe),
            WadoUrl = D(url, taban.WadoUrl),
            GoruntuleyiciUrl = M(k, "goruntuleyiciUrl") is { } g ? g.Trim() : taban.GoruntuleyiciUrl,
            JetonDakika = Sayi(M(k, "jetonDakika"), taban.JetonDakika),
            ZamanAsimiSn = Sayi(M(k, "zamanAsimiSn"), taban.ZamanAsimiSn),
            MwlPort = taban.MwlPort, MwlAe = taban.MwlAe, MwlBilinmeyenAe = taban.MwlBilinmeyenAe, MwlKarakterSeti = taban.MwlKarakterSeti,
        };
    }
}
