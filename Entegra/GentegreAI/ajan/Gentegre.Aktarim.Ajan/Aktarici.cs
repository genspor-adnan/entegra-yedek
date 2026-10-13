using System.Globalization;
using System.Text;
using System.Text.Json.Nodes;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace Gentegre.Aktarim.Ajan;

/// <summary>Bir turun özeti (günlük + --tek-tur çıkış kodu).</summary>
public sealed record TurSonucu(long Versiyon, int Paket, int Kok, int Silinen, string? Hata, bool DegisiklikYok);

/// <summary>
/// BİR TUR: sunucunun bildiği versiyonları al, Delphi'nin güncel CT versiyonunu
/// (OKUMADAN ÖNCE) yakala, grupları sunucu sırasıyla işle, en sonda başarılı
/// grupların versiyonunu bildir.
///
/// <list type="bullet">
/// <item>Grubun sunucuda versiyonu yoksa ya da CT saklama süresi geçtiyse TAM
///   yükleme (hareket tablosu hareket_baslangic'tan). Tam yükleme Delphi'de
///   SİLİNMİŞ kaydı göremez (gece mutabakatı / bilerek bırakıldı).</item>
/// <item>Artımlı: kök değişikliği + değişen alt satırın kökü (satırdan) + silinen
///   alt satırın kökü (sunucudaki eşlemeden, /ust). Kök Delphi'de yoksa D.</item>
/// <item>Paketler versiyonsuz gider; versiyon turun son paketinde, yalnız bütün
///   paketleri hatasız geçen gruplar için. Bir grup hata alırsa sonraki gruplar
///   bu turda gönderilmez (ona bağlılar) - sunucu da aynı kuralla durur.</item>
/// </list>
/// Okuma anı ile versiyon arasındaki değişiklik bir sonraki turda yeniden gelir;
/// yeniden gönderim zararsızdır (sunucu içeriği aynı satırı yazmaz).
/// </summary>
public sealed partial class Aktarici(DelphiOkuyucu delphi, ApiIstemci api, Ayarlar ayar, ILogger gunluk)
{
    private int _paket, _kok, _silinen;

    public async Task<TurSonucu> TurAsync(CancellationToken iptal)
    {
        _paket = _kok = _silinen = 0;
        var durum = await api.DurumAsync(iptal);
        var guncel = await delphi.GuncelVersiyonAsync(iptal);

        var sunucu = new Dictionary<string, long>(StringComparer.Ordinal);
        foreach (var t in durum["tablolar"]?.AsArray() ?? [])
            sunucu[t!["tablo"]!.GetValue<string>()] = t["versiyon"]!.GetValue<long>();
        var kolonlar = durum["kolonlar"]?.AsObject() ?? [];
        var baslangic = DateTime.ParseExact(durum["hareket_baslangic"]?.GetValue<string>() ?? "1900-01-01", "yyyy-MM-dd",
                                            CultureInfo.InvariantCulture);
        Uyumluluk(durum);

        if (Toplamlar.Gruplar.SelectMany(g => g.Tablolar).All(t => sunucu.TryGetValue(t, out var v) && v >= guncel))
            return new TurSonucu(guncel, 0, 0, 0, null, true);

        var ilerleyen = new List<string>();
        string? hata = null;
        foreach (var g in Toplamlar.Gruplar)
        {
            var tablolar = g.Tablolar.ToArray();
            if (tablolar.All(t => sunucu.TryGetValue(t, out var v) && v >= guncel)) continue;

            string? tamSebep = null;
            foreach (var t in tablolar)
            {
                if (!sunucu.TryGetValue(t, out var v)) { tamSebep = $"{t} sunucuda hiç yok"; break; }
                if (v < await delphi.EnAzVersiyonAsync(t, iptal)) { tamSebep = $"{t} versiyonu ({v}) CT saklama süresini geçti"; break; }
            }
            var kol = await KolonlarAsync(g, kolonlar, iptal);

            hata = tamSebep is not null
                ? await TamAsync(g, kol, baslangic, tamSebep, iptal)
                : await ArtimliAsync(g, kol, sunucu, iptal);
            if (hata is not null) break;
            ilerleyen.AddRange(tablolar.Where(t => !sunucu.TryGetValue(t, out var v) || v < guncel));
        }

        if (ilerleyen.Count > 0)
        {
            var v = new JsonObject();
            foreach (var t in ilerleyen) v[t] = guncel;
            await GonderAsync(new JsonObject { ["V"] = v }, iptal);
        }
        return new TurSonucu(guncel, _paket, _kok, _silinen, hata, false);
    }

    /// <summary>Grubun tablolarında okunacak kolonlar (sunucunun stg listesi ∩ Delphi).</summary>
    private async Task<Dictionary<string, Dictionary<string, string>>> KolonlarAsync(Grup g, JsonObject kolonlar, CancellationToken iptal)
    {
        var kol = new Dictionary<string, Dictionary<string, string>>(StringComparer.Ordinal);
        foreach (var t in g.Tablolar)
        {
            kol[t] = await delphi.KolonlarAsync(t, kolonlar[t]?.AsArray().Select(x => x!.GetValue<string>()) ?? [], iptal);
            if (kol[t].Count == 0)
                throw new InvalidOperationException($"{t}: sunucunun istediği kolonların hiçbiri Delphi tablosunda yok.");
        }
        return kol;
    }

    // ---------------------------------------------------------------- tam ----
    private async Task<string?> TamAsync(Grup g, Dictionary<string, Dictionary<string, string>> kol, DateTime baslangic,
                                         string sebep, CancellationToken iptal)
    {
        gunluk.LogInformation("{Kok}: tam yükleme ({Sebep})", g.Kok, sebep);
        string? nerede = g.Tarih is null ? null : $"[{g.Tarih}] >= @bas";
        SqlParameter[] p = g.Tarih is null ? [] : [new SqlParameter("@bas", baslangic)];

        if (g.Altlar.Length == 0)
        {
            var satirlar = await delphi.TumuAsync(g.Kok, kol[g.Kok], nerede, p, iptal);
            return await SayfalaAsync(g, satirlar.Count, (bas, adet) => Task.FromResult(new JsonObject
            {
                ["U"] = new JsonObject { [g.Kok] = new JsonArray([.. satirlar.Skip(bas).Take(adet).Select(s => s.DeepClone())]) },
            }), iptal);
        }

        var idler = await delphi.KimliklerAsync(g.Kok, nerede, g.TamSira, p, iptal);
        return await SayfalaAsync(g, idler.Count, (bas, adet) => ToplamPaketiAsync(g, kol, idler.Skip(bas).Take(adet).ToList(), iptal), iptal);
    }

    // ------------------------------------------------------------ artımlı ----
    private async Task<string?> ArtimliAsync(Grup g, Dictionary<string, Dictionary<string, string>> kol,
                                             Dictionary<string, long> sunucu, CancellationToken iptal)
    {
        var kokDeg = await delphi.DegisikliklerAsync(g.Kok, sunucu[g.Kok], iptal);
        var silinecek = kokDeg.Where(d => d.Islem == 'D').Select(d => d.Anahtar).ToList();
        var adaylar = kokDeg.Where(d => d.Islem != 'D').Select(d => d.Anahtar).ToList();

        if (g.Altlar.Length > 0)
        {
            var kokler = adaylar.Select(a => Convert.ToInt64(a[0], CultureInfo.InvariantCulture)).ToHashSet();
            var silinenAlt = new JsonObject();
            foreach (var alt in g.Altlar)
            {
                var deg = await delphi.DegisikliklerAsync(alt.Tablo, sunucu[alt.Tablo], iptal);
                var degisen = deg.Where(d => d.Islem != 'D').Select(d => Convert.ToInt64(d.Anahtar[0], CultureInfo.InvariantCulture)).ToList();
                kokler.UnionWith(await delphi.UstlerAsync(alt.UstSorgu, degisen, iptal));
                var silinen = deg.Where(d => d.Islem == 'D').Select(d => JsonValue.Create(Convert.ToInt64(d.Anahtar[0], CultureInfo.InvariantCulture))).ToArray();
                if (silinen.Length > 0) silinenAlt[alt.Tablo] = new JsonArray(silinen);
            }
            if (silinenAlt.Count > 0)
            {
                var ust = await api.UstAsync(silinenAlt, iptal);
                foreach (var (_, ids) in ust)
                    foreach (var id in ids!.AsArray()) kokler.Add(Uzun(id!));
                var bulunan = ust.Sum(x => x.Value!.AsArray().Count);
                if (silinenAlt.Any(x => x.Key == "REHBERBILGI"))
                    gunluk.LogInformation("REHBERBILGI silmesi web'e eşlenemez (karşılık satırı yok) - gece mutabakatı düzeltir");
                gunluk.LogDebug("{Kok}: silinen alt satırlardan {N} kök", g.Kok, bulunan);
            }

            var varOlan = (await delphi.SatirlarAsync(g.Kok, new() { ["id"] = "ID" }, "[ID] IN ({0})", kokler, iptal))
                          .Select(s => Uzun(s["id"]!)).ToHashSet();
            var yok = kokler.Where(k => !varOlan.Contains(k)).ToList();
            silinecek.AddRange(yok.Select(k => new object[] { k }));
            var liste = varOlan.Order().ToList();
            var d = Silme(g.Kok, silinecek);
            if (liste.Count == 0 && d is null) return null;
            if (liste.Count == 0) return await GonderAsync(new JsonObject { ["D"] = d }, iptal);
            return await SayfalaAsync(g, liste.Count, async (bas, adet) =>
            {
                var paket = await ToplamPaketiAsync(g, kol, liste.Skip(bas).Take(adet).ToList(), iptal);
                if (bas == 0 && d is not null) paket["D"] = d;
                return paket;
            }, iptal);
        }

        // Tekil tablo: değişen satırlar; Delphi'de bulunmayan = silinmiş.
        var satirlar = await delphi.AnahtarlaAsync(g.Kok, kol[g.Kok], adaylar, iptal);
        var pk = await delphi.AnahtarAsync(g.Kok, iptal);
        var bulundu = satirlar.Select(s => Kimlik(pk, s)).ToHashSet();
        silinecek.AddRange(adaylar.Where(a => !bulundu.Contains(Kimlik(a))));
        var dTekil = Silme(g.Kok, silinecek, pk);
        if (satirlar.Count == 0 && dTekil is null) return null;
        return await SayfalaAsync(g, Math.Max(satirlar.Count, 1), (bas, adet) =>
        {
            var p = new JsonObject { ["U"] = new JsonObject { [g.Kok] = new JsonArray([.. satirlar.Skip(bas).Take(adet).Select(s => s.DeepClone())]) } };
            if (bas == 0 && dTekil is not null) p["D"] = dTekil;
            return Task.FromResult(p);
        }, iptal);
    }

    // ------------------------------------------------------------ paketler ----
    private async Task<JsonObject> ToplamPaketiAsync(Grup g, Dictionary<string, Dictionary<string, string>> kol, List<long> kokler,
                                                     CancellationToken iptal)
    {
        var u = new JsonObject
        {
            [g.Kok] = new JsonArray([.. await delphi.SatirlarAsync(g.Kok, kol[g.Kok], "[ID] IN ({0})", kokler, iptal)]),
        };
        foreach (var alt in g.Altlar)
            u[alt.Tablo] = new JsonArray([.. await delphi.SatirlarAsync(alt.Tablo, kol[alt.Tablo], alt.AltFiltre, kokler, iptal)]);
        return new JsonObject { ["U"] = u };
    }

    /// <summary>
    /// Kökleri grubun sayfa boyuyla paketler; paket ayar sınırını aşarsa sayfa yarıya
    /// iner (o sayfa için). Hata ilk hatalı pakette döner, kalan sayfalar gitmez.
    /// </summary>
    private async Task<string?> SayfalaAsync(Grup g, int adet, Func<int, int, Task<JsonObject>> kur, CancellationToken iptal)
    {
        var sinir = ayar.PaketMb * 1024L * 1024;
        for (var bas = 0; bas < adet;)
        {
            var boy = Math.Min(g.Sayfa, adet - bas);
            JsonObject paket;
            while (true)
            {
                paket = await kur(bas, boy);
                if (boy == 1 || Encoding.UTF8.GetByteCount(paket.ToJsonString()) <= sinir) break;
                boy = Math.Max(1, boy / 2);
            }
            string? hata;
            try { hata = await GonderAsync(paket, iptal); }
            catch (SunucuReddi r) when (r.Durum == System.Net.HttpStatusCode.RequestEntityTooLarge && boy > 1)
            {
                // Aradaki vekil (nginx) API'den küçük sınır koymuş olabilir: sayfayı yarıla, aynı yerden.
                gunluk.LogWarning("{Kok}: paket büyük bulundu (413), sayfa {Boy} -> {Yeni}", g.Kok, boy, boy / 2);
                sinir = Math.Min(sinir, Encoding.UTF8.GetByteCount(paket.ToJsonString()) / 2);
                continue;
            }
            if (hata is not null) return hata;
            _kok += boy;
            bas += boy;
        }
        return null;
    }

    private async Task<string?> GonderAsync(JsonObject paket, CancellationToken iptal)
    {
        paket["paket"] = Guid.NewGuid().ToString("N");
        if (paket["D"] is JsonObject d) _silinen += d.Sum(x => x.Value!.AsArray().Count);
        var sonuc = await api.PaketAsync(paket.ToJsonString(), iptal);
        _paket++;
        if (sonuc["hata"] is JsonObject h)
        {
            var m = $"{h["adim"]}: {h["mesaj"]}";
            gunluk.LogError("Paket {Paket} sunucuda hata aldı - {Hata}", paket["paket"], m);
            return m;
        }
        gunluk.LogDebug("Paket {Paket}: {Sonuc}", paket["paket"], sonuc["sonuc"]?.ToJsonString());
        return null;
    }

    // ------------------------------------------------------------ yardımcı ----
    private static JsonObject? Silme(string tablo, List<object[]> anahtarlar, string[]? pk = null)
    {
        if (anahtarlar.Count == 0) return null;
        var a = new JsonArray();
        foreach (var k in anahtarlar.DistinctBy(Kimlik))
        {
            if (k.Length == 1) a.Add(DelphiOkuyucu.Deger(k[0]));
            else
            {
                var o = new JsonObject();
                for (var i = 0; i < k.Length; i++) o[pk![i].ToLowerInvariant()] = DelphiOkuyucu.Deger(k[i]);
                a.Add(o);
            }
        }
        return new JsonObject { [tablo] = a };
    }

    private static long Uzun(JsonNode n) => long.Parse(n.ToJsonString(), CultureInfo.InvariantCulture);

    private static string Kimlik(object[] a) => string.Join("\u001f", a.Select(x => Convert.ToString(x, CultureInfo.InvariantCulture)));

    private static string Kimlik(string[] pk, JsonObject satir)
        => string.Join("\u001f", pk.Select(c => Metin(satir[c.ToLowerInvariant()])));

    // Satır JSON'u ile CT anahtarı aynı metne düşmeli (tarih: ikisi de DateTime'dan).
    private static string Metin(JsonNode? n) => n is null ? "" : n.GetValueKind() == System.Text.Json.JsonValueKind.String
        ? (DateTime.TryParseExact(n.GetValue<string>(), "yyyy-MM-dd'T'HH:mm:ss.fff", CultureInfo.InvariantCulture, DateTimeStyles.None, out var t)
            ? Convert.ToString(t, CultureInfo.InvariantCulture)! : n.GetValue<string>())
        : n.ToJsonString();

    private void Uyumluluk(JsonObject durum)
    {
        var sunucuTablolari = (durum["adimlar"]?.AsArray() ?? []).SelectMany(a => a!["tablolar"]!.AsArray().Select(t => t!.GetValue<string>())).ToHashSet();
        var bizim = Toplamlar.Gruplar.SelectMany(g => g.Tablolar).ToHashSet();
        foreach (var t in sunucuTablolari.Except(bizim))
            gunluk.LogWarning("Sunucu {Tablo} tablosunu da işliyor; bu ajan sürümü göndermiyor (ajanı güncelleyin)", t);
        foreach (var t in bizim.Except(sunucuTablolari))
            throw new InvalidOperationException($"Sunucu {t} tablosunu tanımıyor - sunucu sürümü eski.");
    }
}
