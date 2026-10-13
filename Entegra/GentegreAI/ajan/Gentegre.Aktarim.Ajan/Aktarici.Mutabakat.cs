using System.Globalization;
using System.Text.Json.Nodes;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;

namespace Gentegre.Aktarim.Ajan;

/// <summary>Bir kök tablonun mutabakat sonucu.</summary>
public sealed record MutabakatSonucu(string Tablo, int Delphi, int Web, int Eksik, int Fazla, int Giderilen, int Atlanan);

/// <summary>
/// MUTABAKAT (1091, gece ya da --mutabakat): her kök tablonun Delphi kimlik listesi
/// sunucuya gider; sunucu eksik (web'de yok) / fazla (web'de aktif, Delphi'de yok)
/// döner.
/// <list type="bullet">
/// <item>Eksik: toplam yeniden yollanır (artımlı yolla aynı paketler). Sonra ikinci
///   kez sorulur - hâlâ eksik olan KURAL gereği aktarılmayandır ("atlanan").</item>
/// <item>Fazla: liste alındıktan SONRA Delphi'ye eklenmiş olabilir - kimlik Delphi'de
///   yeniden aranır, gerçekten yoksa D gider. Tam yüklemenin ve uzun kesintinin
///   göremediği silmeleri bu kapatır.</item>
/// </list>
/// Hareket tablolarının listesi hareket_baslangic'tan (tam yüklemeyle aynı süzgeç).
/// </summary>
public sealed partial class Aktarici
{
    /// <summary>Mutabakata girmeyenler: DOVIZ (bileşik anahtar, D yok), STOKDURUM (her değişiklikte aynası yazılır).</summary>
    private static readonly HashSet<string> MutabakatDisi = new(StringComparer.Ordinal) { "DOVIZ", "STOKDURUM" };

    public async Task<List<MutabakatSonucu>> MutabakatAsync(CancellationToken iptal)
    {
        var durum = await api.DurumAsync(iptal);
        var kolonlar = durum["kolonlar"]?.AsObject() ?? [];
        var baslangic = DateTime.ParseExact(durum["hareket_baslangic"]?.GetValue<string>() ?? "1900-01-01", "yyyy-MM-dd",
                                            CultureInfo.InvariantCulture);
        var sonuc = new List<MutabakatSonucu>();
        foreach (var g in Toplamlar.Gruplar.Where(g => !MutabakatDisi.Contains(g.Kok)))
        {
            string? nerede = g.Tarih is null ? null : $"[{g.Tarih}] >= @bas";
            SqlParameter[] p = g.Tarih is null ? [] : [new SqlParameter("@bas", baslangic)];
            var idler = await delphi.KimliklerAsync(g.Kok, nerede, null, p, iptal);

            var ilk = await api.MutabakatAsync(g.Kok, idler, iptal);
            var eksik = Liste(ilk["eksik"]);
            var fazla = Liste(ilk["fazla"]);
            var giderilen = 0;
            var kol = await KolonlarAsync(g, kolonlar, iptal);

            if (eksik.Count > 0)
            {
                var hata = await SayfalaAsync(g, eksik.Count, (bas, adet) => g.Altlar.Length > 0
                    ? ToplamPaketiAsync(g, kol, eksik.Skip(bas).Take(adet).ToList(), iptal)
                    : TekilPaketiAsync(g, kol, eksik.Skip(bas).Take(adet).ToList(), iptal), iptal);
                if (hata is not null)
                    throw new InvalidOperationException($"{g.Kok} mutabakatında eksikler yollanamadı: {hata}");
            }
            if (fazla.Count > 0)
            {
                // Liste alındıktan sonra eklenmiş olabilir: Delphi'de hâlâ olan silinmez.
                var duran = (await delphi.SatirlarAsync(g.Kok, new() { ["id"] = "ID" }, "[ID] IN ({0})", fazla, iptal))
                            .Select(s => Uzun(s["id"]!)).ToHashSet();
                var sil = fazla.Where(f => !duran.Contains(f)).Select(f => new object[] { f }).ToList();
                if (sil.Count > 0)
                {
                    var hata = await GonderAsync(new JsonObject { ["D"] = Silme(g.Kok, sil) }, iptal);
                    if (hata is not null)
                        throw new InvalidOperationException($"{g.Kok} mutabakatında silme uygulanamadı: {hata}");
                    giderilen += sil.Count;
                }
            }

            var atlanan = 0;
            if (eksik.Count > 0)
            {
                atlanan = Liste((await api.MutabakatAsync(g.Kok, idler, iptal))["eksik"]).Count;
                giderilen += Math.Max(0, eksik.Count - atlanan);
            }
            var s = new MutabakatSonucu(g.Kok, idler.Count, ilk["web"]!.GetValue<int>(), eksik.Count, fazla.Count, giderilen, atlanan);
            sonuc.Add(s);
            await api.MutabakatKaydetAsync(s, new() { ["eksik"] = [.. eksik.Take(20)], ["fazla"] = [.. fazla.Take(20)] }, iptal);
            if (s.Eksik + s.Fazla > 0)
                gunluk.LogInformation("Mutabakat {Tablo}: Delphi {D}, web {W}, eksik {E}, fazla {F}, giderilen {G}, kural gereği atlanan {A}",
                                      s.Tablo, s.Delphi, s.Web, s.Eksik, s.Fazla, s.Giderilen, s.Atlanan);
        }
        return sonuc;
    }

    /// <summary>Alt tablosu olmayan kök: kimlikle satırlar.</summary>
    private async Task<JsonObject> TekilPaketiAsync(Grup g, Dictionary<string, Dictionary<string, string>> kol, List<long> idler,
                                                    CancellationToken iptal)
        => new() { ["U"] = new JsonObject { [g.Kok] = new JsonArray([.. await delphi.SatirlarAsync(g.Kok, kol[g.Kok], "[ID] IN ({0})", idler, iptal)]) } };

    private static List<long> Liste(JsonNode? n) => n?.AsArray().Select(x => Uzun(x!)).ToList() ?? [];
}
