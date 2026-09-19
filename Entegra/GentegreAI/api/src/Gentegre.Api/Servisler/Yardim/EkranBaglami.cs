using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler.Yardim;

/// <summary>
/// İSTEMCİNİN GÖNDERDİĞİ EKRAN BAĞLAMI (871) — yalnız <b>kimlik</b> bilgisi.
///
/// İstemci ekranın İÇERİĞİNİ göndermez: DOM yok, satır verisi yok, hasta adı
/// yok. Gönderdiği her şey sunucuda katalogla doğrulanır; uymayan alan
/// sessizce atılır (<see cref="DogrulanmisBaglam.Reddedilen"/> listesine
/// yazılır) - istemci "ben şu ekrandayım, şu yetkim var" diyerek bağlamı
/// genişletemez.
/// </summary>
public sealed record IstemciBaglami(
    /// <summary>Rota: "/hasta", "/hasta/5057", "/steril-dongu/12".</summary>
    string? Rota = null,
    /// <summary>Ekranın kaynak kodu (liste tanımındaki `kaynak`). Rotayla tutmazsa atılır.</summary>
    string? Kaynak = null,
    /// <summary>Seçili kaydın YALNIZ numarası. Kart kataloğunda karşılığı ve yetkisi yoksa atılır.</summary>
    long? KayitId = null,
    /// <summary>Görünen sekme (kart grup / detay adı). Katalogda yoksa atılır.</summary>
    string? Sekme = null,
    /// <summary>Ekranda son görülen hata kodu (§1.2 ya da engel kodu). Tanınmıyorsa atılır.</summary>
    string? HataKodu = null,
    /// <summary>Arayüz dili: tr · en · de. Başkası "tr" sayılır.</summary>
    string? Dil = null,
    /// <summary>"liste" | "kart" | "ozel" ipucu; sunucu kendi karar verir.</summary>
    string? ListeTuru = null);

public sealed record BaglamAlani(string Ad, string Baslik, string Tip, bool Zorunlu = false);
public sealed record BaglamAksiyonu(string Kod, string Ad, string Ekran);

/// <summary>
/// SUNUCUNUN DOĞRULADIĞI BAĞLAM — modele ve cevaba giden tek ekran bilgisi.
/// Alan/kolon listeleri alan yetkisinden geçmiştir; aksiyonlar kullanıcının
/// yetkili olduklarıdır. <see cref="Yetkili"/> yanlışsa ekran bulunmuş ama
/// kullanıcı oraya giremiyordur: içerik listeleri BOŞ bırakılır, kayıt
/// numarası atılır - göremediği ekranın alanlarını anlatmak yetkiyi delmektir.
/// </summary>
public sealed record DogrulanmisBaglam(
    bool Bulundu,
    bool Yetkili,
    string Kaynak,
    string Rota,
    string Baslik,
    string Yol,
    string MenuGrup,
    string Modul,
    string AksiyonEkrani,
    string YetkiKodu,
    string? KartKaynak,
    long? KayitId,
    string? Sekme,
    string? HataKodu,
    string Dil,
    short UrunModu,
    int? SubeId,
    IReadOnlyList<BaglamAlani> Kolonlar,
    IReadOnlyList<BaglamAlani> Alanlar,
    IReadOnlyList<string> Sekmeler,
    IReadOnlyList<BaglamAksiyonu> Aksiyonlar,
    IReadOnlyList<string> Reddedilen)
{
    public static DogrulanmisBaglam Bos(string dil, short urunModu, int? subeId,
                                        IReadOnlyList<string>? reddedilen = null) =>
        new(false, false, "", "", "", "", "", "", "", "", null, null, null, null, dil, urunModu,
            subeId, [], [], [], [], reddedilen ?? []);

    /// <summary>Modele / günlüğe yazılacak kısa özet - içerik yok, yalnız kimlik.</summary>
    public string Ozet =>
        !Bulundu ? "ekran tanınmadı"
        : $"{Yol} ({Rota})" + (Sekme is { Length: > 0 } ? $" · sekme: {Sekme}" : "")
          + (KayitId is > 0 ? $" · açık kayıt: {KartKaynak} #{KayitId}" : "")
          + (Yetkili ? "" : " · YETKİSİZ");
}

/// <summary>
/// Bağlam çözücü: istemcinin ipucunu <b>katalog + yetki</b> ile doğrular.
/// Ekran satırı <c>ai_rehber_ekran</c>'dan, kolonlar <c>KaynakKatalogu</c>,
/// alanlar/sekmeler <c>KartKatalogu</c>, düğmeler <c>AksiyonKatalogu</c>'ndan.
/// Hiçbir yerde kayıt İÇERİĞİ okunmaz - kayıt numarasının varlığı bile
/// sorgulanmaz (var olmayan / görülemeyen kaydı ayırt ettirmemek için).
/// </summary>
public static class EkranBaglamiCozucu
{
    private static readonly HashSet<string> Diller = new(StringComparer.OrdinalIgnoreCase)
        { "tr", "en", "de" };

    public static string DilNormalle(string? dil)
        => dil is { Length: > 0 } d && Diller.Contains(d.Trim()) ? d.Trim().ToLowerInvariant() : "tr";

    /// <summary>Rota temizliği: yalnız [a-z0-9-_/], 120 karakter, "/" ile başlar.</summary>
    public static string? RotaNormalle(string? rota)
    {
        if (string.IsNullOrWhiteSpace(rota)) return null;
        var r = rota.Trim();
        var soru = r.IndexOfAny(['?', '#']);
        if (soru >= 0) r = r[..soru];
        if (!r.StartsWith('/')) r = "/" + r;
        if (r.Length > 120) return null;
        foreach (var ch in r)
            if (!(char.IsAsciiLetterLower(ch) || char.IsAsciiDigit(ch) || ch is '-' or '_' or '/'))
                return null;
        return r.Length > 1 ? r.TrimEnd('/') : r;
    }

    /// <summary>"/hasta/5057" → ("/hasta", 5057); "/hasta" → ("/hasta", null).</summary>
    public static (string Kok, long? Id) RotayiAyir(string rota)
    {
        var parcalar = rota.TrimStart('/').Split('/', StringSplitOptions.RemoveEmptyEntries);
        if (parcalar.Length == 0) return ("/", null);
        var kok = "/" + parcalar[0];
        long? id = parcalar.Length >= 2 && long.TryParse(parcalar[1], out var n) && n > 0 ? n : null;
        return (kok, id);
    }

    /// <summary>Ekran satırı (katalog). Test için ayrı: DB'siz de çözülebilsin.</summary>
    public sealed record EkranSatiri(string Kaynak, string Rota, string Baslik, string Yol,
                                     string MenuGrup, string Modul, string YetkiKodu,
                                     string AksiyonEkrani, string KartYolu, short UrunModu);

    public static async Task<EkranSatiri?> EkranBulAsync(NpgsqlConnection baglanti, string rota,
                                                         string kok, CancellationToken iptal)
    {
        var s = await baglanti.TekAsync("""
            select e.kaynak, e.rota, e.baslik, e.yol, e.menu_grup as "menuGrup", e.modul,
                   e.yetki_kodu as "yetkiKodu", e.aksiyon_ekrani as "aksiyonEkrani",
                   e.kart_yolu as "kartYolu", e.urun_modu as "urunModu"
              from public.ai_rehber_ekran e
             where (e.rota = @p0 or e.rota = @p1) and e.durum = 0
             order by case when e.rota = @p0 then 0 else 1 end, e.id
             limit 1
            """, null, [rota, kok], OkuyucuGenisletmeleri.Sozluk, iptal);
        if (s is null) return null;
        return new EkranSatiri(
            s["kaynak"]?.ToString() ?? "", s["rota"]?.ToString() ?? "",
            s["baslik"]?.ToString() ?? "", s["yol"]?.ToString() ?? "",
            s["menuGrup"]?.ToString() ?? "", s["modul"]?.ToString() ?? "",
            s["yetkiKodu"]?.ToString() ?? "", s["aksiyonEkrani"]?.ToString() ?? "",
            s["kartYolu"]?.ToString() ?? "", Convert.ToInt16(s["urunModu"] ?? (short)0));
    }

    public static async Task<DogrulanmisBaglam> CozAsync(
        NpgsqlConnection baglanti, IstemciBaglami? istemci, IstekBaglami baglam,
        short urunModu, CancellationToken iptal)
    {
        var dil = DilNormalle(istemci?.Dil);
        var rota = RotaNormalle(istemci?.Rota);
        if (rota is null)
            return DogrulanmisBaglam.Bos(dil, urunModu, baglam.SubeId,
                                         istemci?.Rota is { Length: > 0 } ? ["rota"] : []);
        var (kok, rotaId) = RotayiAyir(rota);
        var ekran = await EkranBulAsync(baglanti, rota, kok, iptal);
        return Coz(ekran, istemci, rota, rotaId, baglam, urunModu, dil);
    }

    /// <summary>Saf çözüm (DB'siz): ekran satırı verilmiş, gerisi katalog + yetki.</summary>
    public static DogrulanmisBaglam Coz(EkranSatiri? ekran, IstemciBaglami? istemci, string rota,
                                        long? rotaId, IstekBaglami baglam, short urunModu,
                                        string dil)
    {
        var red = new List<string>();
        if (ekran is null)
            return DogrulanmisBaglam.Bos(dil, urunModu, baglam.SubeId, ["rota"]);

        // Ürün modu: HBYS ekranı ERP kurulumunda "yok" sayılır.
        if (!UrunModlari.Uyar(ekran.UrunModu, urunModu))
            return DogrulanmisBaglam.Bos(dil, urunModu, baglam.SubeId, ["rota:urun-modu"]);

        var kaynak = ekran.Kaynak;
        // İstemcinin kaynağı katalogla tutmuyorsa İSTEMCİNİNKİ atılır.
        if (istemci?.Kaynak is { Length: > 0 } ik
            && !string.Equals(ik.Trim(), kaynak, StringComparison.OrdinalIgnoreCase))
            red.Add("kaynak");

        var yetkili = string.IsNullOrEmpty(ekran.YetkiKodu)
                      || baglam.Yetkiler.Var(ekran.YetkiKodu, Islem.Gor);

        // Yetkisiz ekran: kimlik bilgisi kalır (kullanıcıya "bu ekrana yetkiniz
        //   yok" denebilsin), içerik listeleri ve kayıt numarası gider.
        if (!yetkili)
        {
            if (istemci?.KayitId is > 0 || rotaId is > 0) red.Add("kayitId:yetkisiz");
            if (istemci?.Sekme is { Length: > 0 }) red.Add("sekme:yetkisiz");
            return new DogrulanmisBaglam(true, false, kaynak, ekran.Rota, ekran.Baslik, ekran.Yol,
                                         ekran.MenuGrup, ekran.Modul, ekran.AksiyonEkrani,
                                         ekran.YetkiKodu, null, null, null,
                                         HataKoduSec(istemci?.HataKodu, red), dil, urunModu,
                                         baglam.SubeId, [], [], [], [], red);
        }

        // ---------------------------------------------------- kart / kayıt
        // Kart kaynağı: liste kaynağıyla aynı ad kart kataloğunda varsa o;
        //   yoksa kart_yolu'nun kökü ("/hasta" -> "hasta").
        var kartAd = KartKatalogu.Bul(kaynak) is not null ? kaynak
                   : ekran.KartYolu is { Length: > 1 } ky ? ky.TrimStart('/').Split('/')[0] : "";
        var kart = kartAd.Length > 0 ? KartKatalogu.Bul(kartAd) : null;
        if (kart is not null && !baglam.Yetkiler.Var(kart.YetkiKodu, Islem.Gor)) kart = null;

        long? kayitId = null;
        var istenen = istemci?.KayitId is > 0 ? istemci.KayitId : rotaId;
        if (istenen is > 0)
        {
            if (kart is not null) kayitId = istenen;
            else red.Add("kayitId");
        }

        string? sekme = null;
        var sekmeler = new List<string>();
        if (kart is not null)
        {
            foreach (var g in kart.Alanlar.Select(a => a.Grup).Where(g => !string.IsNullOrEmpty(g)))
                if (!sekmeler.Contains(g!, StringComparer.OrdinalIgnoreCase)) sekmeler.Add(g!);
            foreach (var d in kart.Detaylar ?? [])
                if (!sekmeler.Contains(d.Etiket, StringComparer.OrdinalIgnoreCase)) sekmeler.Add(d.Etiket);
        }
        if (istemci?.Sekme is { Length: > 0 } s)
        {
            var bulunan = sekmeler.FirstOrDefault(x => string.Equals(x, s.Trim(), StringComparison.OrdinalIgnoreCase));
            if (bulunan is not null) sekme = bulunan; else red.Add("sekme");
        }

        // ------------------------------------------------ kolonlar / alanlar
        var kolonlar = new List<BaglamAlani>();
        var liste = KaynakKatalogu.Bul(kaynak);
        if (liste is not null)
            foreach (var k in liste.Kolonlar)
            {
                if (kolonlar.Count >= 40) break;
                if (!UrunModlari.Uyar(k.UrunModu, urunModu)) continue;
                if (!baglam.Yetkiler.AlanOkunur(kaynak, k.YetkiAlani ?? k.Ad)) continue;
                kolonlar.Add(new BaglamAlani(k.Ad, k.Baslik, k.Tip, false));
            }

        var alanlar = new List<BaglamAlani>();
        if (kart is not null)
            foreach (var a in kart.Alanlar)
            {
                if (alanlar.Count >= 60) break;
                if (a.Ad == kart.IdKolonu) continue;
                if (!baglam.Yetkiler.AlanOkunur(kart.Ad, a.Ad)) continue;
                alanlar.Add(new BaglamAlani(a.Ad, a.Etiket, a.Tip, a.Zorunlu));
            }

        // ------------------------------------------------------- aksiyonlar
        var aksiyonEkrani = string.IsNullOrWhiteSpace(ekran.AksiyonEkrani)
            ? kaynak + "-liste" : ekran.AksiyonEkrani;
        var aksiyonlar = (AksiyonKatalogu.Ekran(aksiyonEkrani) ?? [])
            .Where(a => UrunModlari.Uyar(a.UrunModu, urunModu))
            .Where(a => AksiyonKatalogu.Yetkili(a, baglam.Yetkiler))
            .Take(12)
            .Select(a => new BaglamAksiyonu(a.Kod, a.Ad, aksiyonEkrani))
            .ToList();

        return new DogrulanmisBaglam(true, true, kaynak, ekran.Rota, ekran.Baslik, ekran.Yol,
                                     ekran.MenuGrup, ekran.Modul, aksiyonEkrani, ekran.YetkiKodu,
                                     kart?.Ad, kayitId, sekme, HataKoduSec(istemci?.HataKodu, red),
                                     dil, urunModu, baglam.SubeId, kolonlar, alanlar, sekmeler,
                                     aksiyonlar, red);
    }

    private static string? HataKoduSec(string? kod, List<string> red)
    {
        if (string.IsNullOrWhiteSpace(kod)) return null;
        if (HataAciklamalari.Bilinir(kod)) return kod.Trim().ToUpperInvariant();
        red.Add("hataKodu");
        return null;
    }
}
