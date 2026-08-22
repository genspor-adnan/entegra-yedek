using System.Globalization;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>Uretilmis SQL + siraya bagli parametre degerleri (@p0, @p1 ...).</summary>
public sealed record SorguParcasi(string Sql, IReadOnlyList<object?> Parametreler);

/// <summary>
/// Liste istegini SQL'e cevirir. TEK KURAL: istekten gelen metin asla SQL'e
/// yazilmaz - alan adlari katalogla eslestirilir, degerler parametre olur.
/// </summary>
public sealed class SorguUretici
{
    private readonly KaynakTanimi _kaynak;
    private readonly List<object?> _par = new();

    public SorguUretici(KaynakTanimi kaynak) => _kaynak = kaynak;

    private string Ekle(object? deger)
    {
        _par.Add(deger);
        return "@p" + (_par.Count - 1).ToString(CultureInfo.InvariantCulture);
    }

    /// <summary>Sayfali satir sorgusu.</summary>
    public SorguParcasi Satirlar(ListeIstegi istek, IReadOnlyList<KolonTanimi> kolonlar,
                                 int? subeId, IReadOnlyList<int>? kapsamTarafIdleri, int? kullaniciId)
    {
        var secim = string.Join(", ", kolonlar.Select(k => $"{k.Sql} as \"{k.Ad}\""));
        var kaynakIfadesi = KaynakIfadesi(istek, kullaniciId);
        var nerede = Nerede(istek, subeId, kapsamTarafIdleri);
        // "son"/"sik" siralamasi yalniz KaynakIfadesi'nin gercekten "ka" join'i
        //   eklediginde anlamli - kullaniciId eksikken normal siralamaya duser.
        var sirala = Sirala(istek, kullaniciGorunumuAktif: kullaniciId is not null);

        var boyut = Math.Clamp(istek.Boyut, 1, ListeIstegi.EnBuyukBoyut);
        var sayfa = Math.Max(1, istek.Sayfa);

        var sql = new StringBuilder()
            .Append("select ").Append(secim)
            .Append(" from ").Append(kaynakIfadesi)
            .Append(nerede)
            .Append(" order by ").Append(sirala)
            .Append(" limit ").Append(Ekle(boyut))
            .Append(" offset ").Append(Ekle((long)(sayfa - 1) * boyut))
            .ToString();

        return new SorguParcasi(sql, _par.ToArray());
    }

    /// <summary>Toplam kayit sayisi (ayni WHERE, sayfalama yok).</summary>
    public SorguParcasi Sayim(ListeIstegi istek, int? subeId, IReadOnlyList<int>? kapsamTarafIdleri, int? kullaniciId)
    {
        _par.Clear();
        var sql = "select count(*) from " + KaynakIfadesi(istek, kullaniciId) +
                  Nerede(istek, subeId, kapsamTarafIdleri);
        return new SorguParcasi(sql, _par.ToArray());
    }

    /// <summary>Istenen alanlarin toplamlari (yalniz para/sayi kolonlari).</summary>
    public SorguParcasi? Toplamlar(ListeIstegi istek, IReadOnlyList<KolonTanimi> kolonlar,
                                   int? subeId, IReadOnlyList<int>? kapsamTarafIdleri, int? kullaniciId)
    {
        if (istek.Toplam is not { Count: > 0 }) return null;

        var secilen = istek.Toplam
            .Select(a => kolonlar.FirstOrDefault(k => k.Ad == a))
            .Where(k => k is { } kk && kk.SayiMi)
            .Select(k => k!)
            .ToList();

        if (secilen.Count == 0) return null;

        _par.Clear();
        var secim = string.Join(", ", secilen.Select(k => $"coalesce(sum({k.Sql}), 0) as \"{k.Ad}\""));
        var sql = "select " + secim + " from " + KaynakIfadesi(istek, kullaniciId) +
                  Nerede(istek, subeId, kapsamTarafIdleri);
        return new SorguParcasi(sql, _par.ToArray());
    }

    // ------------------------------------------------------------- son/sik ----
    /// <summary>
    /// "Son Aranan"/"Sik Aranan" gorunumu (eski KULLANICI_ARAMA): kaynak ifadesine
    /// bu kullanicinin kullanici_arama satirlarina INNER JOIN eklenir - sonuc yalniz
    /// bu kullanicinin daha once actigi/eklediği kayitlarla sinirlanir.
    /// </summary>
    private string KaynakIfadesi(ListeIstegi istek, int? kullaniciId)
    {
        if (istek.Gorunum is not ("son" or "sik") || kullaniciId is null) return _kaynak.Kaynak;

        var idKolon = _kaynak.Kolon("id")?.Sql
            ?? throw new InvalidOperationException($"'{_kaynak.Ad}' kaynaginda 'id' kolonu yok.");

        return _kaynak.Kaynak +
            $" join public.kullanici_arama ka on ka.kaynak = {Ekle(_kaynak.Ad)}" +
            $" and ka.kullanici_id = {Ekle(kullaniciId)} and ka.kayit_id = {idKolon}";
    }

    // ------------------------------------------------------------------ where ----
    private string Nerede(ListeIstegi istek, int? subeId, IReadOnlyList<int>? kapsamTarafIdleri)
    {
        var parcalar = new List<string>();

        if (!string.IsNullOrWhiteSpace(_kaynak.SabitKosul))
            parcalar.Add("(" + _kaynak.SabitKosul + ")");

        // Sube filtresi SUNUCUDA eklenir - istekte gelmez (API §8).
        if (_kaynak.SubeKolonu is { } sk && subeId is { } sid)
            parcalar.Add($"{sk} = {Ekle(sid)}");

        // Kayit kapsami (eski YETKIALANI): satir varsa yalniz o kayitlar gorunur.
        if (kapsamTarafIdleri is { Count: > 0 } && _kaynak.KapsamKolonu is { } kk)
            parcalar.Add($"{kk} = any({Ekle(kapsamTarafIdleri.ToArray())})");

        if (istek.Filtre is { } f)
        {
            var s = Kosul(f);
            if (!string.IsNullOrEmpty(s)) parcalar.Add(s);
        }

        return parcalar.Count == 0 ? "" : " where " + string.Join(" and ", parcalar);
    }

    private string Kosul(Kosul kosul)
    {
        if (kosul.DalMi)
        {
            var birlesim = kosul.Op.Equals("or", StringComparison.OrdinalIgnoreCase) ? " or " : " and ";
            var altlar = kosul.Kosullar!
                .Select(Kosul)
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();
            return altlar.Count == 0 ? "" : "(" + string.Join(birlesim, altlar) + ")";
        }

        if (string.IsNullOrWhiteSpace(kosul.Alan)) return "";

        var kolon = _kaynak.Kolon(kosul.Alan)
            ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen alan: {kosul.Alan}",
                   new AlanHatasi(kosul.Alan!, "Bu listede boyle bir alan yok."));

        if (!kolon.Filtrelenebilir)
            throw GentegreHatasi.Dogrulama($"{kolon.Baslik} alaninda filtre kullanilamaz.",
                   new AlanHatasi(kosul.Alan!, "Filtrelenebilir degil."));

        if (!KosulOperatoru.Gecerlidir(kosul.Op))
            throw GentegreHatasi.Dogrulama($"Bilinmeyen operator: {kosul.Op}",
                   new AlanHatasi(kosul.Alan!, "Gecersiz operator."));

        var x = kolon.Sql;

        switch (kosul.Op)
        {
            case KosulOperatoru.Bos:
                return kolon.MetinMi ? $"({x} is null or {x} = '')" : $"{x} is null";

            case KosulOperatoru.BosDegil:
                return kolon.MetinMi ? $"({x} is not null and {x} <> '')" : $"{x} is not null";

            // ARAMA NORMALIZASYONU (027): ILIKE tek basina YETMEZ - veritabani ICU
            //   'tr-TR' locale'inde oldugu icin lower('GRANIT') = 'granıt' (noktasiz i)
            //   ve 'GRANIT' ilike '%granit%' FALSE doner. fn_ara_metin iki tarafi da
            //   ASCII'ye indirger; ustundeki pg_trgm GIN indeksi de ayni ifadededir.
            case KosulOperatoru.Icerir:
                return $"public.fn_ara_metin({x}) like '%' || public.fn_ara_metin({Ekle(Metin(kosul.Deger))}) || '%'";

            case KosulOperatoru.Baslar:
                return $"public.fn_ara_metin({x}) like public.fn_ara_metin({Ekle(Metin(kosul.Deger))}) || '%'";

            case KosulOperatoru.Biter:
                return $"public.fn_ara_metin({x}) like '%' || public.fn_ara_metin({Ekle(Metin(kosul.Deger))})";

            case KosulOperatoru.Icinde:
            {
                var liste = Liste(kosul.Deger, kolon);
                if (liste.Count == 0) return "false";
                // `= any(@p)` KULLANILMAZ: liste object?[] oldugu icin Npgsql tipi
                //   cikaramiyor ve "Writing values of 'System.Object[]' is not
                //   supported" ile patliyordu. Her deger AYRI parametre olarak
                //   baglanir - tip cikarimi eleman basina calisir.
                return $"{x} in ({string.Join(", ", liste.Select(Ekle))})";
            }

            case KosulOperatoru.Arasinda:
            {
                var liste = Liste(kosul.Deger, kolon);
                if (liste.Count != 2)
                    throw GentegreHatasi.Dogrulama("'arasinda' iki deger ister.",
                        new AlanHatasi(kosul.Alan!, "Alt ve ust sinir verilmeli."));
                // Tarihte ust sinir GUN SONUNA kadar kapsar (saat bileseni tuzagi).
                if (kolon.Tip == "tarih")
                    return $"({x} >= {Ekle(liste[0])} and {x} < ({Ekle(liste[1])}::timestamp + interval '1 day'))";
                return $"({x} >= {Ekle(liste[0])} and {x} <= {Ekle(liste[1])})";
            }

            default:
            {
                var op = kosul.Op switch
                {
                    KosulOperatoru.Esit      => "=",
                    KosulOperatoru.EsitDegil => "<>",
                    KosulOperatoru.Buyuk     => ">",
                    KosulOperatoru.BuyukEsit => ">=",
                    KosulOperatoru.Kucuk     => "<",
                    KosulOperatoru.KucukEsit => "<=",
                    _ => throw GentegreHatasi.Dogrulama("Gecersiz operator: " + kosul.Op)
                };
                var deger = Deger(kosul.Deger, kolon);
                if (deger is null)
                    return kosul.Op == KosulOperatoru.EsitDegil ? $"{x} is not null" : $"{x} is null";
                return $"{x} {op} {Ekle(deger)}";
            }
        }
    }

    // ----------------------------------------------------------------- sirala ----
    private string Sirala(ListeIstegi istek, bool kullaniciGorunumuAktif)
    {
        if (kullaniciGorunumuAktif && istek.Gorunum == "son") return "ka.son_tarih desc";
        if (kullaniciGorunumuAktif && istek.Gorunum == "sik") return "ka.say desc, ka.son_tarih desc";

        if (istek.Sirala is not { Count: > 0 }) return _kaynak.VarsayilanSirala;

        var parcalar = new List<string>();
        foreach (var s in istek.Sirala)
        {
            var kolon = _kaynak.Kolon(s.Alan);
            if (kolon is null || !kolon.Siralanabilir) continue;
            var yon = s.Yon.Equals("desc", StringComparison.OrdinalIgnoreCase) ? "desc" : "asc";
            parcalar.Add($"{kolon.Sql} {yon}");
        }
        return parcalar.Count == 0 ? _kaynak.VarsayilanSirala : string.Join(", ", parcalar);
    }

    // ------------------------------------------------------------ deger cevrimi ----
    private static string Metin(object? d) => JsonMetin(d) ?? "";

    private static List<object?> Liste(object? d, KolonTanimi kolon)
    {
        var sonuc = new List<object?>();
        if (d is JsonElement je && je.ValueKind == JsonValueKind.Array)
        {
            foreach (var e in je.EnumerateArray()) sonuc.Add(Deger(e, kolon));
        }
        else if (d is System.Collections.IEnumerable dizi and not string)
        {
            foreach (var e in dizi) sonuc.Add(Deger(e, kolon));
        }
        else if (d is not null)
        {
            sonuc.Add(Deger(d, kolon));
        }
        return sonuc;
    }

    /// <summary>Deger cevrimi tek yerde: DegerCevirici (kart yazimi da ayni kurallari kullanir).</summary>
    private static object? Deger(object? d, KolonTanimi kolon)
        => DegerCevirici.Cevir(d, kolon.Tip, kolon.Ad, kolon.Baslik);

    private static string? JsonMetin(object? d)
        => d switch
        {
            null => null,
            JsonElement je => je.ValueKind == JsonValueKind.String ? je.GetString() : je.ToString(),
            _ => d.ToString()
        };
}
