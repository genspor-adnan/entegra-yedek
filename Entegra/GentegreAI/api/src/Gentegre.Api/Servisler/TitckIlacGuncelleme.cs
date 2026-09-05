using System.IO.Compression;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// TİTCK İLAÇ LİSTESİ GÜNCELLEME (400) — "TİTCK'den Güncelle" düğmesinin işi.
///
/// TİTCK, *Ruhsatlı Beşerî Tıbbî Ürünler Listesi*'ni haftalık XLSX olarak
/// yayınlıyor (dinamikmodul/85). Elle indirip CSV'ye çevirmek her hafta
/// tekrarlanan bir angarya; burası sayfadan EN GÜNCEL dosyayı bulur, indirir,
/// XLSX'i okur ve kataloğu tazeler.
///
/// XLSX ek pakete BAŞVURMADAN okunur: dosya bir zip, sayfa ve paylaşılan
/// metinler XML. Okunan tek şey ilk sayfanın hücreleri - tam bir Excel
/// okuyucusuna gerek yok, bağımlılık da eklenmiyor.
///
/// ASKIDAKİ ÜRÜN SİLİNMEZ, PASİF YAZILIR: stokta kalmış olabilir ve geçmiş
/// reçetede geçer. Listede olmayan barkod da pasife çekilmez - eksik bir
/// yayın binlerce ilacı kaybettirmemeli.
/// </summary>
public sealed class TitckIlacGuncelleme
{
    /// <summary>Ruhsatlı Beşerî Tıbbî Ürünler Listesi (barkod, ad, etken madde, ATC).</summary>
    private const string RuhsatSayfasi = "https://www.titck.gov.tr/dinamikmodul/85";

    /// <summary>
    /// SKRS e-Reçete İlaç ve Diğer Farmasötik Ürünler Listesi — REÇETE TÜRÜNÜN
    /// gerçek kaynağı. Ruhsat listesinde reçete türü YOK; kırmızı/yeşil reçete
    /// ayrımı bilinmeden e-Reçete yazılamaz.
    /// </summary>
    private const string ReceteSayfasi = "https://www.titck.gov.tr/dinamikmodul/43";

    private readonly VeriKaynagi _veri;
    private readonly IHttpClientFactory _http;
    private readonly ILogger<TitckIlacGuncelleme> _gunluk;

    public TitckIlacGuncelleme(VeriKaynagi veri, IHttpClientFactory http,
                               ILogger<TitckIlacGuncelleme> gunluk)
    {
        _veri = veri;
        _http = http;
        _gunluk = gunluk;
    }

    public sealed record Sonuc(int Yazilan, int Askida, int Atlanan, string Dosya, string Tarih);

    public async Task<Sonuc> GuncelleAsync(CancellationToken iptal)
    {
        var (adres, tarih) = await EnGuncelDosyaAsync(RuhsatSayfasi, iptal);
        _gunluk.LogInformation("TİTCK ilaç listesi indiriliyor: {Adres}", adres);

        var istemci = _http.CreateClient("katalog");
        istemci.Timeout = TimeSpan.FromMinutes(5);
        var veri = await istemci.GetByteArrayAsync(adres, iptal);

        var satirlar = Oku(veri);
        if (satirlar.Count == 0)
            throw new InvalidOperationException("TİTCK dosyası okundu ama satır bulunamadı.");

        var (yazilan, askida, atlanan) = await YazAsync(satirlar, iptal);
        var dosyaAdi = adres[(adres.LastIndexOf('/') + 1)..];

        await _veri.CalistirAsync("""
            insert into public.katalog_senkron (kod, ad, son_calisma, satir_sayisi, sonuc, basarili)
            values ('ilac', 'İlaç (barkod)', now(),
                    (select count(*) from public.ilac), @p0, 1)
            on conflict (kod) do update
               set son_calisma = now(), satir_sayisi = excluded.satir_sayisi,
                   sonuc = excluded.sonuc, basarili = 1
            """,
            new object?[] { $"TİTCK {tarih}: {yazilan} ürün ({askida} askıda), {atlanan} atlandı." },
            iptal);

        return new Sonuc(yazilan, askida, atlanan, dosyaAdi, tarih);
    }

    /// <summary>
    /// SKRS e-Reçete listesinden REÇETE TÜRÜNÜ ve temel ilaç işaretlerini
    /// tazeler. Ruhsat listesinde bu bilgi yok; kırmızı/yeşil reçete ayrımı
    /// bilinmeden e-Reçete yazılamaz.
    ///
    /// Yalnız MEVCUT barkodları günceller - bu liste ruhsat listesinin yerine
    /// geçmez (kapsamı farklı: "aktif ürünler").
    /// </summary>
    public async Task<Sonuc> ReceteTuruGuncelleAsync(CancellationToken iptal)
    {
        var (adres, tarih) = await EnGuncelDosyaAsync(ReceteSayfasi, iptal);
        var istemci = _http.CreateClient("katalog");
        istemci.Timeout = TimeSpan.FromMinutes(5);
        var veri = await istemci.GetByteArrayAsync(adres, iptal);

        var satirlar = XlsxOku(veri);
        var guncellenen = 0;

        await using var baglanti = await _veri.AcAsync(iptal);
        const int Parti = 5000;
        var liste = satirlar
            .Select(h => (
                Barkod: new string(Deger(h, "BARKOD").Where(char.IsDigit).ToArray()),
                Recete: ReceteKodu(Deger(h, "RECETE TURU")),
                Temel:  (short)(Deger(h, "TEMEL ILAC LISTESI DURUMU").StartsWith("A",
                                 StringComparison.OrdinalIgnoreCase) ? 1 : 0),
                Cocuk:  (short)(Deger(h, "COCUK TEMEL ILAC LISTESI DURUM").StartsWith("A",
                                 StringComparison.OrdinalIgnoreCase) ? 1 : 0)))
            .Where(x => x.Barkod.Length is >= 8 and <= 20)
            .GroupBy(x => x.Barkod).Select(g => g.Last()).ToList();

        for (var i = 0; i < liste.Count; i += Parti)
        {
            var p = liste.Skip(i).Take(Parti).ToList();
            guncellenen += await baglanti.CalistirAsync("""
                update public.ilac i
                   set recete_turu = t.recete, temel_ilac = t.temel,
                       cocuk_temel_ilac = t.cocuk, guncelleme = now()
                  from unnest(@p0::varchar[], @p1::smallint[], @p2::smallint[], @p3::smallint[])
                       as t(barkod, recete, temel, cocuk)
                 where i.barkod = t.barkod
                   and (i.recete_turu is distinct from t.recete
                        or i.temel_ilac is distinct from t.temel
                        or i.cocuk_temel_ilac is distinct from t.cocuk)
                """, null,
                [p.Select(x => x.Barkod).ToArray(), p.Select(x => x.Recete).ToArray(),
                 p.Select(x => x.Temel).ToArray(), p.Select(x => x.Cocuk).ToArray()], iptal);
        }

        await _veri.CalistirAsync("""
            insert into public.katalog_senkron (kod, ad, son_calisma, satir_sayisi, sonuc, basarili)
            values ('ilac_recete', 'SKRS e-Reçete listesi (reçete türü)', now(), @p0, @p1, 1)
            on conflict (kod) do update
               set son_calisma = now(), satir_sayisi = excluded.satir_sayisi,
                   sonuc = excluded.sonuc, basarili = 1
            """, new object?[] { liste.Count,
                $"SKRS e-Reçete {tarih}: {liste.Count} satır okundu, {guncellenen} ilaç güncellendi." },
            iptal);

        return new Sonuc(guncellenen, 0, satirlar.Count - liste.Count,
                         adres[(adres.LastIndexOf('/') + 1)..], tarih);
    }

    /// <summary>SKRS reçete türü metni -> kod (0 normal · 1 kırmızı · 2 yeşil · 3 mor · 4 turuncu).</summary>
    private static short ReceteKodu(string metin)
    {
        var m = Sadelestir(metin);
        if (m.Contains("KIRMIZI")) return 1;
        if (m.Contains("YESIL")) return 2;
        if (m.Contains("MOR")) return 3;
        if (m.Contains("TURUNCU")) return 4;
        return 0;
    }

    private static string Deger(Dictionary<string, string> satir, string sutun)
        => satir.TryGetValue(sutun, out var d) ? d : "";

    // ------------------------------------------------------------ dosya bulma
    /// <summary>
    /// Yayın sayfasındaki XLSX bağlantılarından EN GÜNCELİNİ seçer.
    ///
    /// Dosya adı tarihi taşıyor ("…Listesi04.09.2026_guid.xlsx") ve sayfa
    /// yeniyi üste koyuyor; yine de ada gömülü tarihe göre seçilir - sıralama
    /// sayfanın düzenine bırakılmaz, düzen değişirse sessizce eski dosya
    /// yüklenirdi.
    /// </summary>
    private async Task<(string Adres, string Tarih)> EnGuncelDosyaAsync(
        string sayfaAdresi, CancellationToken iptal)
    {
        var istemci = _http.CreateClient("katalog");
        var html = await istemci.GetStringAsync(sayfaAdresi, iptal);

        var enIyi = ("", new DateTime(2000, 1, 1));
        foreach (Match m in Regex.Matches(html, @"https?://[^""'\s]+?\.xlsx", RegexOptions.IgnoreCase))
        {
            var adres = m.Value;
            // Ada gömülü tarih: "…Listesi04.09.2026_…" ya da "…15.09.2017.xlsx"
            var t = Regex.Match(adres, @"(\d{2})\.(\d{2})\.(\d{4})");
            if (!t.Success) continue;
            if (!DateTime.TryParse($"{t.Groups[3].Value}-{t.Groups[2].Value}-{t.Groups[1].Value}",
                                   out var tarih)) continue;
            if (tarih > enIyi.Item2) enIyi = (adres, tarih);
        }

        if (enIyi.Item1.Length == 0)
            throw new InvalidOperationException(
                "TİTCK sayfasında tarihli bir XLSX bağlantısı bulunamadı - sayfa düzeni değişmiş olabilir.");

        return (enIyi.Item1, enIyi.Item2.ToString("dd.MM.yyyy"));
    }

    // ------------------------------------------------------------- xlsx okuma
    private sealed record IlacSatiri(string Barkod, string Ad, string Etken, string Atc,
                                     string Firma, short Aktif);

    /// <summary>
    /// XLSX'in ilk sayfasını okur. Başlık satırından SÜTUN ADLARIYLA eşleme
    /// yapılır (harf sırasına güvenilmez): TİTCK sütun ekleyip çıkarabiliyor,
    /// sabit "B = barkod" varsayımı sessizce yanlış veri yüklerdi.
    /// </summary>
    private static List<IlacSatiri> Oku(byte[] veri)
    {
        using var zip = new ZipArchive(new MemoryStream(veri), ZipArchiveMode.Read);
        var paylasilan = PaylasilanMetinler(zip);

        var sayfa = zip.GetEntry("xl/worksheets/sheet1.xml")
                    ?? throw new InvalidOperationException("XLSX içinde sayfa bulunamadı.");

        XNamespace ad = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        using var akis = sayfa.Open();
        var kok = XDocument.Load(akis).Root!;

        var sonuc = new List<IlacSatiri>();
        Dictionary<string, string>? sutunlar = null;   // "BARKOD" -> "B"

        foreach (var satir in kok.Descendants(ad + "row"))
        {
            var hucreler = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var h in satir.Elements(ad + "c"))
            {
                var yer = h.Attribute("r")?.Value ?? "";
                var sutun = new string(yer.TakeWhile(char.IsLetter).ToArray());
                var tip = h.Attribute("t")?.Value;
                var deger = tip switch
                {
                    "s" => int.TryParse(h.Element(ad + "v")?.Value, out var i)
                           && i < paylasilan.Count ? paylasilan[i] : "",
                    "inlineStr" => string.Concat(h.Descendants(ad + "t").Select(x => x.Value)),
                    _ => h.Element(ad + "v")?.Value ?? "",
                };
                if (deger.Length > 0) hucreler[sutun] = deger.Trim();
            }
            if (hucreler.Count == 0) continue;

            // BAŞLIK SATIRI: "BARKOD" hücresini gördüğümüz satır.
            if (sutunlar is null)
            {
                var basliklar = hucreler.Where(x => Sadelestir(x.Value).Contains("BARKOD"))
                                        .Select(x => x.Key).ToList();
                if (basliklar.Count == 0) continue;
                sutunlar = hucreler.ToDictionary(x => Sadelestir(x.Value), x => x.Key,
                                                 StringComparer.Ordinal);
                continue;
            }

            string Al(params string[] adaylar)
            {
                foreach (var a in adaylar)
                {
                    var anahtar = sutunlar!.Keys.FirstOrDefault(k => k.Contains(a, StringComparison.Ordinal));
                    if (anahtar is not null && hucreler.TryGetValue(sutunlar[anahtar], out var d)) return d;
                }
                return "";
            }

            var barkod = new string(Al("BARKOD").Where(char.IsDigit).ToArray());
            var urun = Al("URUN ADI", "URUNADI", "URUN");
            if (barkod.Length is < 8 or > 20 || urun.Length == 0) continue;

            // "RUHSATI ASKIDA OLMAYAN ÜRÜN: 0" sütunu: 0 = askıda değil.
            var askidaSutun = Al("ASKIDA");
            var aktif = (short)(string.IsNullOrEmpty(askidaSutun) || askidaSutun == "0" ? 1 : 0);

            sonuc.Add(new IlacSatiri(barkod, Kirp(urun, 300),
                                     Kirp(Al("ETKIN MADDE", "ETKEN MADDE"), 300),
                                     Kirp(Al("ATC"), 20),
                                     Kirp(Al("RUHSAT SAHIBI", "FIRMA"), 200), aktif));
        }
        return sonuc;
    }

    /// <summary>
    /// XLSX'i BAŞLIK ADIYLA anahtarlanmış satırlara çevirir (genel okuyucu).
    ///
    /// Başlık satırı "BARKOD" hücresini gördüğümüz satırdır; TİTCK dosyalarında
    /// üstte logo/başlık satırları var ve kaç tane olduğu dosyadan dosyaya
    /// değişiyor - sabit "2. satır başlıktır" varsayımı bir gün sessizce
    /// veriyi kaydırırdı.
    /// </summary>
    public static List<Dictionary<string, string>> XlsxOku(byte[] veri)
    {
        using var zip = new ZipArchive(new MemoryStream(veri), ZipArchiveMode.Read);
        var paylasilan = PaylasilanMetinler(zip);
        var sayfa = zip.GetEntry("xl/worksheets/sheet1.xml")
                    ?? throw new InvalidOperationException("XLSX içinde sayfa bulunamadı.");

        XNamespace ad = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        using var akis = sayfa.Open();
        var kok = XDocument.Load(akis).Root!;

        var sonuc = new List<Dictionary<string, string>>();
        Dictionary<string, string>? sutunlar = null;      // "BARKOD" -> "B"

        foreach (var satir in kok.Descendants(ad + "row"))
        {
            var hucreler = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var h in satir.Elements(ad + "c"))
            {
                var yer = h.Attribute("r")?.Value ?? "";
                var sutun = new string(yer.TakeWhile(char.IsLetter).ToArray());
                var tip = h.Attribute("t")?.Value;
                var deger = tip switch
                {
                    "s" => int.TryParse(h.Element(ad + "v")?.Value, out var i)
                           && i < paylasilan.Count ? paylasilan[i] : "",
                    "inlineStr" => string.Concat(h.Descendants(ad + "t").Select(x => x.Value)),
                    _ => h.Element(ad + "v")?.Value ?? "",
                };
                if (deger.Length > 0) hucreler[sutun] = deger.Trim();
            }
            if (hucreler.Count == 0) continue;

            if (sutunlar is null)
            {
                if (!hucreler.Values.Any(v => Sadelestir(v).Contains("BARKOD"))) continue;
                sutunlar = new Dictionary<string, string>(StringComparer.Ordinal);
                foreach (var (harf, baslik) in hucreler) sutunlar[Sadelestir(baslik)] = harf;
                continue;
            }

            var kayit = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var (baslik, harf) in sutunlar)
                if (hucreler.TryGetValue(harf, out var d)) kayit[baslik] = d;
            if (kayit.Count > 0) sonuc.Add(kayit);
        }
        return sonuc;
    }

    private static List<string> PaylasilanMetinler(ZipArchive zip)
    {
        var giris = zip.GetEntry("xl/sharedStrings.xml");
        if (giris is null) return [];
        XNamespace ad = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        using var akis = giris.Open();
        return XDocument.Load(akis).Root!.Elements(ad + "si")
            .Select(si => string.Concat(si.Descendants(ad + "t").Select(t => t.Value)))
            .ToList();
    }

    // ----------------------------------------------------------------- yazma
    /// <summary>
    /// TEK SORGUDA TOPLU UPSERT (unnest): 23 bin satırı tek tek yazmak 35
    /// saniye sürüyordu; düğmeye basan kullanıcı o kadar bekleyemez.
    /// </summary>
    private async Task<(int Yazilan, int Askida, int Atlanan)> YazAsync(
        List<IlacSatiri> satirlar, CancellationToken iptal)
    {
        // Aynı barkod listede iki kez geçebiliyor (farklı ruhsat satırı):
        //   toplu upsert'te "ON CONFLICT ... aynı komutta iki kez" hatası
        //   verir, bu yüzden sonuncusu kalacak şekilde teklenir.
        var tekil = satirlar.GroupBy(x => x.Barkod).Select(g => g.Last()).ToList();
        var atlanan = satirlar.Count - tekil.Count;

        await using var baglanti = await _veri.AcAsync(iptal);
        const int Parti = 5000;

        for (var i = 0; i < tekil.Count; i += Parti)
        {
            var p = tekil.Skip(i).Take(Parti).ToList();
            await baglanti.CalistirAsync("""
                insert into public.ilac (barkod, ad, etken_madde, atc_kod, firma,
                                         aktif, kaynak_surum, guncelleme)
                select * from unnest(@p0::varchar[], @p1::varchar[], @p2::varchar[],
                                     @p3::varchar[], @p4::varchar[], @p5::smallint[])
                     as t(barkod, ad, etken, atc, firma, aktif),
                     lateral (select 'titck'::varchar as kaynak, now() as zaman) x
                on conflict (barkod) do update
                   set ad = excluded.ad,
                       etken_madde = excluded.etken_madde,
                       atc_kod = excluded.atc_kod,
                       firma = excluded.firma,
                       aktif = excluded.aktif,
                       kaynak_surum = 'titck',
                       guncelleme = now()
                """, null,
                [p.Select(x => x.Barkod).ToArray(), p.Select(x => x.Ad).ToArray(),
                 p.Select(x => x.Etken).ToArray(), p.Select(x => x.Atc).ToArray(),
                 p.Select(x => x.Firma).ToArray(), p.Select(x => x.Aktif).ToArray()],
                iptal);
        }

        return (tekil.Count, tekil.Count(x => x.Aktif == 0), atlanan);
    }

    private static string Kirp(string m, int n) => m.Length <= n ? m : m[..n];

    /// <summary>Başlık karşılaştırması için: Türkçe harfler sadeleşir, boşluk tekleşir.</summary>
    private static string Sadelestir(string metin)
    {
        // NOKTASIZ 'ı' AYRICA ELE ALINIR: ToUpperInvariant onu 'I' yapmaz
        //   (U+0131 aynen kalir), bu yuzden "Eczacı İskonto Oranı" basligi
        //   "ECZACı ISKONTO ORANı" olarak cikiyor ve sutun eslesmiyordu.
        var s = metin.Replace('ı', 'I').ToUpperInvariant()
                     .Replace('İ', 'I').Replace('Ş', 'S').Replace('Ğ', 'G')
                     .Replace('Ü', 'U').Replace('Ö', 'O').Replace('Ç', 'C');
        return Regex.Replace(s, @"\s+", " ").Trim();
    }
}
