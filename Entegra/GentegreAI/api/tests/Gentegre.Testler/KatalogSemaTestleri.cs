using System.Text.RegularExpressions;
using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// KATALOG ↔ VERİTABANI ŞEMASI (dokuman/17, kullanıcı 13.10.2026: "katalog
/// tutarlılık testlerini kur").
///
/// Katalog (liste kaynakları, kartlar, aksiyonlar) SQL'i METİN olarak taşır;
/// derleyici kolonun ya da görünümün var olduğunu bilmez. Bu sınıf her tanımı
/// test veritabanına sorar - yeni bir kolon / görünüm / yetki kataloğa eklenip
/// migration'da unutulursa ekran açılmadan, burada kırmızı olur.
///
/// GERÇEK VAKALAR (12.10.2026): kalite_gosterge_deger ve kalite_denetim_bulgu
/// tablolarında kartın yazdığı `ekleyen` / `degistiren` yoktu - dönem değeri
/// düzeltmek ve bulgu eklemek 500 veriyordu, ancak ekran denenince görüldü.
///
/// Salt OKUR: hiçbir satır yazmaz (`where false`, information_schema).
/// </summary>
public sealed class KatalogSemaTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Katalog SQL'indeki yer tutucular ({sube}, {kullanici}...) sorguda sabit olur.</summary>
    private static string YerTutucusuz(string sql) => Regex.Replace(sql, @"\{[a-zA-Z_]+\}", "0");

    /// <summary>"public.x" ya da "x" -> (şema, ad).</summary>
    private static (string Sema, string Ad) Ayir(string tablo)
    {
        var p = tablo.Trim().Split(' ')[0].Split('.');
        return p.Length == 2 ? (p[0], p[1]) : ("public", p[0]);
    }

    private static bool BasitKolon(string kolon) => Regex.IsMatch(kolon, @"^[a-z_][a-z0-9_]*$");

    [VtFact]
    public async Task Her_liste_kaynaginin_SQL_i_calisir()
    {
        if (!_olgu.Baglandi(nameof(Her_liste_kaynaginin_SQL_i_calisir))) return;
        var veri = _olgu.Gerekli();
        var hatalar = new List<string>();
        foreach (var k in KaynakKatalogu.Tumu.OrderBy(k => k.Ad))
        {
            // Önce kaynağın tamamı; hata verirse hangi kolon olduğunu bulmak için tek tek.
            var kolonlar = k.Kolonlar.Select((c, i) => $"{YerTutucusuz(c.Sql)} as k{i}").ToList();
            if (k.SubeKolonu is { } sube) kolonlar.Add($"{YerTutucusuz(sube)} as k_sube");
            var kosul = k.SabitKosul is { } sk ? $" and ({YerTutucusuz(sk)})" : "";
            var tam = $"select {string.Join(", ", kolonlar)} from {YerTutucusuz(k.Kaynak)} where false{kosul}";
            if (await Calisir(veri, tam) is null) continue;

            var tekil = new List<string>();
            var kaynakHatasi = await Calisir(veri, $"select 1 from {YerTutucusuz(k.Kaynak)} where false");
            if (kaynakHatasi is not null) tekil.Add($"KAYNAK: {kaynakHatasi}");
            else
                foreach (var c in k.Kolonlar)
                    if (await Calisir(veri, $"select {YerTutucusuz(c.Sql)} from {YerTutucusuz(k.Kaynak)} where false") is { } h)
                        tekil.Add($"{c.Ad} ({c.Sql}): {h}");
            if (tekil.Count == 0) tekil.Add($"sube / sabit koşul: {await Calisir(veri, tam)}");
            hatalar.Add($"{k.Ad}\n      " + string.Join("\n      ", tekil));
        }
        Assert.True(hatalar.Count == 0, "Liste kaynağı SQL'i çalışmıyor - ekran açılmaz:\n  " + string.Join("\n  ", hatalar));
    }

    [VtFact]
    public async Task Her_kartin_ve_detayin_yazdigi_kolonlar_tabloda_var()
    {
        if (!_olgu.Baglandi(nameof(Her_kartin_ve_detayin_yazdigi_kolonlar_tabloda_var))) return;
        var veri = _olgu.Gerekli();
        var sema = new Dictionary<(string, string), HashSet<string>>();
        foreach (var (s, t, c) in await veri.ListeAsync(
                     "select table_schema, table_name, column_name from information_schema.columns", [],
                     o => (o.GetString(0), o.GetString(1), o.GetString(2))))
        {
            if (!sema.TryGetValue((s, t), out var k)) sema[(s, t)] = k = new(StringComparer.Ordinal);
            k.Add(c);
        }

        var hatalar = new List<string>();
        void Denetle(string yer, string tablo, IEnumerable<string> kolonlar)
        {
            var (s, t) = Ayir(tablo);
            if (!sema.TryGetValue((s, t), out var var_)) { hatalar.Add($"{yer}: tablo yok ({tablo})"); return; }
            var eksik = kolonlar.Where(BasitKolon).Distinct().Where(k => !var_.Contains(k)).ToList();
            if (eksik.Count > 0) hatalar.Add($"{yer} ({tablo}): eksik kolon {string.Join(", ", eksik)}");
        }

        foreach (var kart in KartKatalogu.Tumu.OrderBy(k => k.Ad))
        {
            // Kart yazımı (KartDeposu): alanlar + ekleyen (ekle) + degistiren (güncelle).
            var yazar = kart.Alanlar.Any(a => a.Yazilabilir);
            var kolonlar = kart.Alanlar.Select(a => a.Kolon).Append(kart.IdKolonu).ToList();
            if (yazar) kolonlar.AddRange(["ekleyen", "degistiren"]);
            if (kart.SubeKolonu is { } sube) kolonlar.Add(sube);
            Denetle($"kart {kart.Ad}", kart.Tablo, kolonlar);

            // Detay yazımı (KartDeposu.Detay): üst kolon + alanlar + ekleyen + degistiren + şube.
            foreach (var d in kart.Detaylar ?? [])
            {
                var dk = d.Alanlar.Select(a => a.Kolon).Append(d.UstKolon).Append(d.IdKolonu).ToList();
                if (!d.SaltOkunur) dk.AddRange(["ekleyen", "degistiren"]);
                if (d.SubeKolonu is { } ds) dk.Add(ds);
                Denetle($"kart {kart.Ad} › detay {d.Ad}", d.Tablo, dk);
            }
        }
        Assert.True(hatalar.Count == 0, "Kartın yazdığı kolon tabloda yok - kaydet / satır ekle 500 verir:\n  "
            + string.Join("\n  ", hatalar));
    }

    [VtFact]
    public async Task Katalogdaki_her_yetki_kodu_veritabaninda_aktif()
    {
        if (!_olgu.Baglandi(nameof(Katalogdaki_her_yetki_kodu_veritabaninda_aktif))) return;
        var veri = _olgu.Gerekli();
        var aktif = (await veri.ListeAsync("select kod from public.yetki where aktif = 1", [], o => o.GetString(0)))
            .ToHashSet(StringComparer.Ordinal);

        var kullanan = new Dictionary<string, SortedSet<string>>(StringComparer.Ordinal);
        void Ekle(string? kod, string yer)
        {
            if (string.IsNullOrWhiteSpace(kod)) return;
            if (!kullanan.TryGetValue(kod, out var y)) kullanan[kod] = y = new(StringComparer.Ordinal);
            y.Add(yer);
        }
        foreach (var k in KaynakKatalogu.Tumu) Ekle(k.YetkiKodu, $"liste {k.Ad}");
        foreach (var k in KartKatalogu.Tumu) Ekle(k.YetkiKodu, $"kart {k.Ad}");
        foreach (var e in AksiyonKatalogu.EkranAdlari)
            foreach (var a in AksiyonKatalogu.Ekran(e) ?? [])
                Ekle(a.KaynakKodu, $"aksiyon {e}/{a.Kod}");

        var eksik = kullanan.Where(x => !aktif.Contains(x.Key))
            .Select(x => $"{x.Key}  ← {string.Join(", ", x.Value.Take(4))}{(x.Value.Count > 4 ? " ..." : "")}")
            .OrderBy(x => x).ToList();
        Assert.True(eksik.Count == 0, "Katalogda kullanılan ama veritabanında olmayan / pasif yetki kodu - "
            + "kimseye verilemez, ekran açılmaz:\n  " + string.Join("\n  ", eksik));
    }

    /// <summary>Sorguyu çalıştırır; hata varsa ilk satırını döner.</summary>
    private static async Task<string?> Calisir(Gentegre.Veri.VeriKaynagi veri, string sql)
    {
        try { await veri.CalistirAsync(sql, []); return null; }
        catch (Npgsql.PostgresException h) { return h.MessageText; }
    }
}
