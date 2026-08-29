using System.Globalization;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// YETKI SENKRONU (kullanıcı: "menülerdeki ekle/sil/değişimlerde yetki matrisini
/// update et").
///
/// Ekranlar ve aksiyonlar KATALOGDA tanımlı (KaynakKatalogu / KartKatalogu /
/// AksiyonKatalogu); `yetki` tablosu ise DB'de duruyordu ve yeni bir ekran
/// eklendiğinde elle migration yazılmadıkça matriste GÖRÜNMÜYORDU. Bu servis
/// uygulama açılışında iki tarafı karşılaştırır ve YALNIZ EKLER:
///   - katalogda olup tabloda olmayan kod → eklenir,
///   - tabloda pasif duran kod katalogda görünürse → yeniden aktif olur.
/// Silme/pasifleştirme YOK (aşağıdaki nota bakın).
/// </summary>
public sealed class YetkiSenkronu
{
    private readonly VeriKaynagi _veri;
    private readonly ILogger<YetkiSenkronu> _gunluk;

    public YetkiSenkronu(VeriKaynagi veri, ILogger<YetkiSenkronu> gunluk)
    {
        _veri = veri;
        _gunluk = gunluk;
    }

    private sealed record Beklenen(string Kod, string Ad, string Grup, short Tur);

    /// <summary>Katalogdaki tüm yetki kodları (modül + aksiyon).</summary>
    private static IReadOnlyList<Beklenen> KatalogYetkileri()
    {
        var harita = new Dictionary<string, Beklenen>(StringComparer.OrdinalIgnoreCase);

        void Ekle(string? kod, string ad, string grup, short tur)
        {
            if (string.IsNullOrWhiteSpace(kod)) return;
            // Ilk gorulen ad kalir: ayni yetki bircok ekranda kullanilabiliyor.
            if (!harita.ContainsKey(kod)) harita[kod] = new Beklenen(kod, ad, grup, tur);
        }

        // 1) Liste kaynaklari + kartlar: modul yetkileri (tur 0).
        foreach (var k in KaynakKatalogu.Tumu)
            Ekle(k.YetkiKodu, BasliktanAd(k.YetkiKodu), GrupTahmini(k.YetkiKodu), 0);
        foreach (var kart in KartKatalogu.Tumu)
            Ekle(kart.YetkiKodu, BasliktanAd(kart.YetkiKodu), GrupTahmini(kart.YetkiKodu), 0);

        // 2) Aksiyonlar: hem AksiyonYetkisi (tur 1) hem KaynakKodu (modul).
        foreach (var ekran in AksiyonKatalogu.EkranAdlari)
            foreach (var a in AksiyonKatalogu.Ekran(ekran) ?? Array.Empty<AksiyonTanimi>())
            {
                Ekle(a.AksiyonYetkisi, a.Ad, GrupTahmini(a.AksiyonYetkisi ?? ""), 1);
                Ekle(a.KaynakKodu, BasliktanAd(a.KaynakKodu ?? ""), GrupTahmini(a.KaynakKodu ?? ""), 0);
            }

        return harita.Values.ToList();
    }

    /// <summary>"fiyat_listesi" → "Fiyat Listesi" (yalnız yeni eklenen satırın ilk adı).</summary>
    private static string BasliktanAd(string kod)
    {
        var parcalar = kod.Replace('.', ' ').Replace('_', ' ').Replace('-', ' ')
                          .Split(' ', StringSplitOptions.RemoveEmptyEntries);
        return string.Join(' ', parcalar.Select(p =>
            char.ToUpper(p[0], new CultureInfo("tr-TR")) + p[1..]));
    }

    /// <summary>Yetkinin matriste hangi başlık altına düşeceği (menüde eşi yoksa).</summary>
    private static string GrupTahmini(string kod) => kod switch
    {
        var k when k.StartsWith("kasa", StringComparison.Ordinal)
                || k.StartsWith("ceksenet", StringComparison.Ordinal)
                || k.StartsWith("kredi", StringComparison.Ordinal)
                || k.StartsWith("fis", StringComparison.Ordinal)
                || k.StartsWith("muhasebe", StringComparison.Ordinal) => "mali",
        var k when k.StartsWith("belge", StringComparison.Ordinal) => "belge",
        var k when k.StartsWith("ebelge", StringComparison.Ordinal)
                || k.StartsWith("e_belge", StringComparison.Ordinal) => "ebelge",
        var k when k.StartsWith("stok", StringComparison.Ordinal)
                || k.StartsWith("uts", StringComparison.Ordinal)
                || k.StartsWith("fiyat", StringComparison.Ordinal)
                || k.StartsWith("hizmet", StringComparison.Ordinal)
                || k.StartsWith("depo", StringComparison.Ordinal) => "stok",
        var k when k.StartsWith("cari", StringComparison.Ordinal)
                || k.StartsWith("taraf", StringComparison.Ordinal)
                || k.StartsWith("personel", StringComparison.Ordinal)
                || k.StartsWith("kisi", StringComparison.Ordinal) => "kart",
        var k when k.StartsWith("log", StringComparison.Ordinal)
                || k.StartsWith("kullanici", StringComparison.Ordinal)
                || k.StartsWith("rol", StringComparison.Ordinal)
                || k.StartsWith("sube", StringComparison.Ordinal)
                || k.StartsWith("ayar", StringComparison.Ordinal) => "yonetim",
        _ => "genel",
    };

    /// <summary>Açılışta bir kez çalışır; eklenen/canlanan sayısını döner.</summary>
    public async Task<(int Eklenen, int Pasiflesen, int Canlanan)> CalistirAsync(
        CancellationToken iptal = default)
    {
        var beklenen = KatalogYetkileri();
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var mevcut = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        await using (var oku = new NpgsqlCommand(
            "select kod, aktif from public.yetki where grup not like 'eski%'", baglanti, islem))
        await using (var o = await oku.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) mevcut[o.GetString(0)] = o.GetInt16(1) == 1;

        var eklenen = 0; var canlanan = 0;
        foreach (var b in beklenen)
        {
            if (!mevcut.TryGetValue(b.Kod, out var aktif))
            {
                await using var k = new NpgsqlCommand("""
                    insert into public.yetki (kod, ad, grup, tur, sira, aktif)
                    values (@p0, @p1, @p2, @p3, 400, 1)
                    on conflict (kod) do nothing
                    """, baglanti, islem);
                k.Parameters.AddWithValue("p0", b.Kod);
                k.Parameters.AddWithValue("p1", b.Ad);
                k.Parameters.AddWithValue("p2", b.Grup);
                k.Parameters.AddWithValue("p3", b.Tur);
                eklenen += await k.ExecuteNonQueryAsync(iptal);
            }
            else if (!aktif)
            {
                // Ekran geri geldi: yetki de canlanir (rol_yetki satirlari duruyordu).
                await using var k = new NpgsqlCommand(
                    "update public.yetki set aktif = 1 where kod = @p0", baglanti, islem);
                k.Parameters.AddWithValue("p0", b.Kod);
                canlanan += await k.ExecuteNonQueryAsync(iptal);
            }
        }

        // KATALOGDA OLMAYANI PASIFLESTIRMEK YOK. Denendi ve YANLIS cikti: bir
        //   yetki katalogda gorunmese de kodda dogrudan kullaniliyor olabilir
        //   (uclardaki AksiyonIste("log.geri-al") gibi) ya da yakin fazin
        //   yetkisi olabilir (ceksenet.*, kredi.*, muhasebe.donem-kilitle).
        //   Ilk denemede 21 gecerli yetki pasiflesti; fazla satirin zarari yok,
        //   yanlis pasiflestirmenin zarari o ozelligin hic verilememesi.
        var pasiflesen = 0;

        await islem.CommitAsync(iptal);
        if (eklenen + pasiflesen + canlanan > 0)
            _gunluk.LogInformation(
                "Yetki senkronu: {Eklenen} eklendi, {Canlanan} canlandi, {Pasiflesen} pasiflesti.",
                eklenen, canlanan, pasiflesen);
        return (eklenen, pasiflesen, canlanan);
    }
}
