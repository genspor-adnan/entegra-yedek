using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Api.Servisler.Yardim;

/// <summary>
/// YARDIM BİLGİ TABANI (871) — ekran/süreç yardım belgelerinin dizini.
///
/// <b>Kaynak:</b> <c>dokuman/yardim/*.md</c> (ürünle birlikte yayınlanır,
/// çalışma anında <c>yardim/</c> klasöründen okunur). Her belge ön-madde
/// (frontmatter) taşır: kararlı id, başlık, modül, ekran kodu, süreç, roller,
/// dil, sürüm, kaynak dosya, son güncelleme, erişim sınıfı, özet. Gövde
/// <c>##</c> başlıklarıyla PARÇALARA bölünür; arama parça üstünde çalışır.
///
/// <b>Arama sözlükseldir</b> (Türkçe sadeleştirme + kelime başlangıcı
/// eşleşmesi + başlık ağırlığı + ekran/modül yakınlığı). Gömme (embedding)
/// servisi yok: dış bağımlılık, maliyet ve veri çıkışı istemiyoruz; katalog
/// birkaç yüz parçadan ibaret, sözlüksel puan yeter. Yarın gömme eklenirse
/// bu sınıfın <see cref="Ara"/> imzası değişmez.
///
/// <b>Yetki süzgeci burada da var:</b> belgenin <c>yetki</c> alanı varsa
/// kullanıcıda GÖR yetkisi olmayan belge hiç dönmez; <c>erisim: ic</c>
/// belgeler (kurulum notları) asistana hiç verilmez.
///
/// <b>İçerik ilkesi:</b> belgeler SQL, gizli anahtar, sistem yönergesi, yetkisiz
/// alan içermez; kod davranışı kullanıcı diline çevrilerek yazılır. Yeniden
/// dizinleme (<see cref="YenidenIndeksle"/>) dosyaları sıfırdan okur; sürüm
/// damgası uygulama sürümü + içerik özetidir, aynı dosya kümesi aynı damgayı
/// verir (tekrarlanabilirlik).
/// </summary>
public sealed class YardimDizini
{
    public sealed record Belge(
        string Id, string Baslik, string Modul, string Ekran, string Rota, string Surec,
        IReadOnlyList<string> Roller, string Dil, string Surum, string KaynakDosya,
        DateOnly? SonGuncelleme, string Erisim, string Ozet, string Yetki, short UrunModu,
        string Dogrulama, IReadOnlyList<Parca> Parcalar, IReadOnlyList<string> OrnekSorular);

    public sealed record Parca(string Id, string BelgeId, string Baslik, string Metin,
                               IReadOnlyList<string> Jetonlar, IReadOnlyList<string> BaslikJetonlari);

    public sealed record Vurus(Parca Parca, Belge Belge, int Puan);

    public sealed record Durum(string Surum, DateTime OlusturmaZamani, int BelgeSayisi,
                               int ParcaSayisi, string Klasor, IReadOnlyList<string> Hatalar,
                               IReadOnlyList<string> Belgeler);

    private readonly object _kilit = new();
    private readonly ILogger<YardimDizini> _gunluk;
    private readonly string _klasor;
    private List<Belge> _belgeler = [];
    private List<string> _hatalar = [];
    public string Surum { get; private set; } = "";
    public DateTime OlusturmaZamani { get; private set; }

    public YardimDizini(string klasor, ILogger<YardimDizini> gunluk)
    {
        _klasor = klasor;
        _gunluk = gunluk;
        YenidenIndeksle();
    }

    /// <summary>
    /// Yardım klasörünü bulur: <c>Ai:YardimKlasoru</c> ayarı, yoksa içerik kökü
    /// ve derleme çıktısı altındaki <c>yardim/</c>, en son depo içindeki
    /// <c>dokuman/yardim</c> (geliştirme). İlk VAR OLAN kazanır.
    /// </summary>
    public static string KlasorBul(string? ayar, string icerikKok)
    {
        var adaylar = new List<string>();
        if (!string.IsNullOrWhiteSpace(ayar)) adaylar.Add(ayar);
        adaylar.Add(Path.Combine(icerikKok, "yardim"));
        // Geliştirmede depo içindeki kaynak klasör ÖNCE: yeniden dizinleme yeni
        //   belgeyi derleme çıktısını beklemeden alsın. Yayında bu yol yoktur,
        //   derleme çıktısındaki kopya kullanılır.
        adaylar.Add(Path.Combine(icerikKok, "..", "..", "..", "dokuman", "yardim"));
        adaylar.Add(Path.Combine(AppContext.BaseDirectory, "yardim"));
        foreach (var a in adaylar)
            if (Directory.Exists(a)) return Path.GetFullPath(a);
        return Path.GetFullPath(adaylar[^2]);
    }

    public Durum DurumAl()
    {
        lock (_kilit)
            return new Durum(Surum, OlusturmaZamani, _belgeler.Count,
                             _belgeler.Sum(b => b.Parcalar.Count), _klasor, _hatalar,
                             _belgeler.Select(b => b.Id + " · " + b.Baslik).ToList());
    }

    public IReadOnlyList<Belge> Belgeler { get { lock (_kilit) return _belgeler; } }

    /// <summary>Dosyaları sıfırdan okur; hatalı belge atlanır ve hatalar listesine yazılır.</summary>
    public Durum YenidenIndeksle()
    {
        var belgeler = new List<Belge>();
        var hatalar = new List<string>();
        var ozet = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        if (Directory.Exists(_klasor))
        {
            foreach (var dosya in Directory.EnumerateFiles(_klasor, "*.md").OrderBy(d => d, StringComparer.Ordinal))
            {
                try
                {
                    var icerik = File.ReadAllText(dosya, Encoding.UTF8);
                    ozet.AppendData(Encoding.UTF8.GetBytes(Path.GetFileName(dosya)));
                    ozet.AppendData(Encoding.UTF8.GetBytes(icerik));
                    var belge = Ayristir(Path.GetFileName(dosya), icerik);
                    if (belge is null) { hatalar.Add(Path.GetFileName(dosya) + ": ön-madde (id/baslik) eksik"); continue; }
                    if (belgeler.Any(b => b.Id == belge.Id)) { hatalar.Add(Path.GetFileName(dosya) + ": id tekrar ediyor (" + belge.Id + ")"); continue; }
                    belgeler.Add(belge);
                }
                catch (Exception h) when (h is IOException or UnauthorizedAccessException)
                {
                    hatalar.Add(Path.GetFileName(dosya) + ": " + h.Message);
                }
            }
        }
        else hatalar.Add("Yardım klasörü yok: " + _klasor);

        var uygulamaSurumu = typeof(YardimDizini).Assembly.GetName().Version?.ToString() ?? "0";
        var damga = Convert.ToHexString(ozet.GetHashAndReset())[..12].ToLowerInvariant();
        lock (_kilit)
        {
            _belgeler = belgeler;
            _hatalar = hatalar;
            Surum = uygulamaSurumu + "+" + damga;
            OlusturmaZamani = DateTime.UtcNow;
        }
        _gunluk.LogInformation("Yardım dizini: {Belge} belge, {Parca} parça, sürüm {Surum} ({Klasor})",
                               belgeler.Count, belgeler.Sum(b => b.Parcalar.Count), Surum, _klasor);
        foreach (var h in hatalar) _gunluk.LogWarning("Yardım dizini: {Hata}", h);
        return DurumAl();
    }

    // ------------------------------------------------------------ ayrıştırma
    /// <summary>
    /// Markdown + ön-madde ayrıştırıcı. Ön-madde <c>---</c> satırları arasında
    /// <c>anahtar: değer</c>; gövde <c>##</c> başlıklarına bölünür. "Örnek
    /// sorular" başlığı altındaki madde işaretleri panelin önerilen sorularıdır
    /// ve arama parçası olarak DA kalır (kullanıcı aynı soruyu yazınca bulunsun).
    /// </summary>
    public static Belge? Ayristir(string dosyaAdi, string icerik)
    {
        var satirlar = icerik.Replace("\r\n", "\n").Split('\n');
        var on = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var i = 0;
        if (satirlar.Length > 0 && satirlar[0].Trim() == "---")
        {
            i = 1;
            for (; i < satirlar.Length && satirlar[i].Trim() != "---"; i++)
            {
                var iki = satirlar[i].IndexOf(':');
                if (iki <= 0) continue;
                on[satirlar[i][..iki].Trim()] = satirlar[i][(iki + 1)..].Trim().Trim('"');
            }
            i++;
        }
        if (!on.TryGetValue("id", out var id) || id.Length == 0) return null;
        if (!on.TryGetValue("baslik", out var baslik) || baslik.Length == 0) return null;

        string Al(string ad, string varsayilan = "") => on.TryGetValue(ad, out var v) ? v : varsayilan;
        var roller = Al("roller").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        DateOnly? guncelleme = DateOnly.TryParse(Al("guncelleme"), System.Globalization.CultureInfo.InvariantCulture,
                                                 out var g) ? g : null;
        short.TryParse(Al("urun_modu", "0"), out var urunModu);

        // Gövde parçaları
        var parcalar = new List<Parca>();
        var ornekler = new List<string>();
        var parcaBaslik = baslik;
        var govde = new StringBuilder();
        void Kapat()
        {
            var metin = govde.ToString().Trim();
            if (metin.Length == 0) return;
            var slug = Slug(parcaBaslik);
            var pid = id + "#" + slug;
            var n = 2;
            while (parcalar.Any(p => p.Id == pid)) pid = id + "#" + slug + "-" + n++;
            parcalar.Add(new Parca(pid, id, parcaBaslik, metin, Jetonla(metin), Jetonla(parcaBaslik)));
        }
        for (; i < satirlar.Length; i++)
        {
            var s = satirlar[i];
            if (s.StartsWith("## ", StringComparison.Ordinal))
            {
                Kapat();
                parcaBaslik = s[3..].Trim();
                govde.Clear();
                continue;
            }
            if (s.StartsWith("# ", StringComparison.Ordinal)) continue;   // belge başlığı tekrarı
            govde.AppendLine(s);
            if (RehberMetin.Sadelestir(parcaBaslik).Contains("ornek soru", StringComparison.Ordinal)
                && s.TrimStart().StartsWith("- ", StringComparison.Ordinal))
                ornekler.Add(s.TrimStart()[2..].Trim().Trim('"'));
        }
        Kapat();

        return new Belge(id, baslik, Al("modul"), Al("ekran"), Al("rota"), Al("surec"), roller,
                         Al("dil", "tr"), Al("surum", "1"), dosyaAdi, guncelleme,
                         Al("erisim", "kullanici"), Al("ozet"), Al("yetki"), urunModu,
                         Al("dogrulama", "insan-dogrulama-bekliyor"), parcalar, ornekler);
    }

    private static string Slug(string s)
    {
        var sade = RehberMetin.Sadelestir(s);
        var sb = new StringBuilder();
        foreach (var ch in sade)
            sb.Append(char.IsAsciiLetterOrDigit(ch) ? ch : '-');
        var slug = sb.ToString().Trim('-');
        while (slug.Contains("--", StringComparison.Ordinal)) slug = slug.Replace("--", "-");
        return slug.Length > 40 ? slug[..40].TrimEnd('-') : slug;
    }

    /// <summary>Metnin bütün anlamlı jetonları (durak kelimeler hariç, tekrarsız).</summary>
    public static IReadOnlyList<string> Jetonla(string metin) => RehberMetin.TumKelimeler(metin);

    // -------------------------------------------------------------- arama
    /// <summary>
    /// Soruya en yakın parçalar. Puan: soru jetonu parça başlığında 3, belge
    /// başlığında 2, gövdede 1 (jeton başına en çok bir kez). Ekran eşleşmesi
    /// +4, modül eşleşmesi +2, süreç eşleşmesi +2. Yetkisiz ve iç belgeler
    /// hiç aday olmaz. Puanı sıfır olan dönmez.
    /// </summary>
    public IReadOnlyList<Vurus> Ara(string soru, DogrulanmisBaglam? ekran, IstekBaglami baglam,
                                    short urunModu, string dil, int azami = 4)
    {
        var jetonlar = RehberMetin.Kelimeler(soru);
        List<Belge> belgeler;
        lock (_kilit) belgeler = _belgeler;

        var sonuc = new List<Vurus>();
        foreach (var b in belgeler)
        {
            if (!Erisilebilir(b, baglam, urunModu, dil)) continue;
            var yakinlik = 0;
            if (ekran is { Bulundu: true, Yetkili: true })
            {
                if (EkranUyar(b, ekran)) yakinlik += 4;
                if (b.Modul.Length > 0 && string.Equals(b.Modul, ekran.Modul, StringComparison.OrdinalIgnoreCase)) yakinlik += 2;
            }
            // "ÖRNEK SORULAR" parçası belgeyi BULDURUR ama cevap olarak DÖNMEZ:
            //   kullanıcının sorusu örnek soruyla birebir tutunca cevap yerine
            //   soru listesi geliyordu. Örnek parçanın puanı belgenin öteki
            //   parçalarına (yarısı) eklenir; en iyi içerik parçası döner.
            var ornekBonus = 0;
            var belgeBasligi = Jetonla(b.Baslik);
            var puanlar = new List<(Parca P, int Puan)>();
            foreach (var p in b.Parcalar)
            {
                var puan = 0;
                foreach (var j in jetonlar)
                {
                    if (p.BaslikJetonlari.Any(x => x.StartsWith(j, StringComparison.Ordinal))) puan += 3;
                    else if (belgeBasligi.Any(x => x.StartsWith(j, StringComparison.Ordinal))) puan += 2;
                    else if (p.Jetonlar.Any(x => x.StartsWith(j, StringComparison.Ordinal))) puan += 1;
                }
                if (OrnekParcasiMi(p)) { ornekBonus = Math.Max(ornekBonus, puan); continue; }
                if (MetaParcasiMi(p)) continue;   // "Kaynaklar", "Doğrulama durumu": belge künyesi, cevap değil
                puanlar.Add((p, puan));
            }
            foreach (var (p, ham) in puanlar)
            {
                var puan = ham + ornekBonus / 2;
                if (puan == 0 && jetonlar.Length > 0) continue;
                // Bağlamsal soru ("bu ekranda ne yapabilirim") jetonsuz kalabilir:
                //   o zaman yalnız ekranı eşleşen belgenin ilk parçaları gelir.
                if (jetonlar.Length == 0 && yakinlik == 0) continue;
                sonuc.Add(new Vurus(p, b, puan + yakinlik));
            }
        }
        return sonuc.OrderByDescending(v => v.Puan).ThenBy(v => v.Parca.Id, StringComparer.Ordinal)
                    .Take(azami).ToList();
    }

    /// <summary>Ekrana bağlı belgelerin örnek soruları (panel önerileri).</summary>
    public IReadOnlyList<string> OnerilenSorular(DogrulanmisBaglam ekran, IstekBaglami baglam,
                                                 short urunModu, string dil, int azami = 5)
    {
        List<Belge> belgeler;
        lock (_kilit) belgeler = _belgeler;
        return belgeler.Where(b => Erisilebilir(b, baglam, urunModu, dil) && EkranUyar(b, ekran))
                       .SelectMany(b => b.OrnekSorular)
                       .Distinct(StringComparer.Ordinal)
                       .Take(azami).ToList();
    }

    private static bool MetaParcasiMi(Parca p)
    {
        var b = RehberMetin.Sadelestir(p.Baslik);
        return b.StartsWith("kaynaklar", StringComparison.Ordinal) || b.StartsWith("dogrulama", StringComparison.Ordinal);
    }

    private static bool OrnekParcasiMi(Parca p)
        => RehberMetin.Sadelestir(p.Baslik).Contains("ornek soru", StringComparison.Ordinal);

    public static bool EkranUyar(Belge b, DogrulanmisBaglam ekran)
        => (b.Ekran.Length > 0 && string.Equals(b.Ekran, ekran.Kaynak, StringComparison.OrdinalIgnoreCase))
           || (b.Rota.Length > 0 && string.Equals(b.Rota, ekran.Rota, StringComparison.OrdinalIgnoreCase));

    private static bool Erisilebilir(Belge b, IstekBaglami baglam, short urunModu, string dil)
    {
        if (string.Equals(b.Erisim, "ic", StringComparison.OrdinalIgnoreCase)) return false;
        if (string.Equals(b.Erisim, "yonetici", StringComparison.OrdinalIgnoreCase)
            && !baglam.Yetkiler.Var("rol", Islem.Gor)) return false;
        if (!UrunModlari.Uyar(b.UrunModu, urunModu)) return false;
        if (b.Yetki.Length > 0 && !baglam.Yetkiler.Var(b.Yetki, Islem.Gor)) return false;
        // Dil: belge dili istenen dil değilse yalnız Türkçe belge (kaynak dil) kabul edilir.
        if (!string.Equals(b.Dil, dil, StringComparison.OrdinalIgnoreCase)
            && !string.Equals(b.Dil, "tr", StringComparison.OrdinalIgnoreCase)) return false;
        return true;
    }
}
