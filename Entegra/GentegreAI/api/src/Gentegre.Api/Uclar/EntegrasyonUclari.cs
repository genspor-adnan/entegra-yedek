using System.Text;
using System.Xml.Linq;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ENTEGRASYON HESAPLARI uçları (336): bağlantı sınama ve SKRS kod listesi
/// senkronu.
///
/// SKRS (Sağlık Kodlama Referans Sunucusu) SOAP servisidir ve kimlik üç HTTP
/// başlığıyla verilir: KullaniciAdi · Sifre · UygulamaKodu (Sağlık.NET
/// hesabı). Bu yüzden kimlikler `entegrasyon_hesap` kaydından okunur -
/// kodda gömülü kimlik YOKTUR.
///
/// SKRS kodları YEREL KOD LİSTELERİNİN DEĞERİ olarak yazılır (kullanıcı
/// kararı): ayrı "yerel kod -> SKRS kodu" eşleme tablosu tutulmaz. Senkron,
/// hedef kod listesini SKRS'den gelen değerlerle günceller.
/// </summary>
public static class EntegrasyonUclari
{
    /// <summary>SKRS kod sistemi -> yerel kod listesi eşlemesi.</summary>
    private static readonly (string SkrsAd, string YerelListe)[] SkrsListeleri =
    {
        ("CINSIYET",            "hasta.cinsiyet"),
        ("MEDENIHAL",           "hasta.medeni_hal"),
        ("YABANCIHASTATURU",    "hasta.yabanci_turu"),
        ("KANGRUBU",            "taraf.kan_grubu"),
    };

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    public static void EntegrasyonUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/entegrasyon").WithTags("Entegrasyon")
                      .RequireAuthorization();

        // ---------------------------------------------------- bağlantı sına --
        // Kimlik ve adres doğru mu: servise en ucuz çağrı yapılır, sonuç
        //   kayda yazılır (son_kullanim / son_sonuc) - kullanıcı ekranda görür.
        grup.MapPost("/{id:int}/sina", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, IHttpClientFactory istemciler,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);

            var (basarili, mesaj) = await SkrsDenemeAsync(hesap, istemciler, iptal);
            await SonucYazAsync(baglanti, id, mesaj, iptal);

            return Results.Ok(new { basarili, mesaj });
        });

        // ------------------------------------------------- SKRS liste senkron
        grup.MapPost("/{id:int}/skrs-senkron", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, IHttpClientFactory istemciler,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            var hesap = await HesapOkuAsync(baglanti, id, iptal);

            if (!string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase))
                throw GentegreHatasi.IsKurali("Bu işlem yalnız SKRS hesabında çalışır.");

            var toplam = 0;
            var raporlar = new List<string>();
            foreach (var (skrsAd, yerelListe) in SkrsListeleri)
            {
                var degerler = await SkrsListesiCekAsync(hesap, skrsAd, istemciler, iptal);
                if (degerler.Count == 0)
                {
                    raporlar.Add($"{skrsAd}: boş döndü");
                    continue;
                }

                var yazilan = await ListeYazAsync(baglanti, yerelListe, degerler,
                                                  baglam.KullaniciId, iptal);
                toplam += yazilan;
                raporlar.Add($"{skrsAd} → {yerelListe}: {yazilan}");
            }

            var ozet = toplam > 0
                ? $"SKRS listeleri güncellendi ({toplam} kod): {string.Join(" · ", raporlar)}"
                : $"SKRS'den kod alınamadı: {string.Join(" · ", raporlar)}";
            await SonucYazAsync(baglanti, id, ozet, iptal);

            return Results.Ok(new { satirSayisi = toplam, mesaj = ozet });
        });
    }

    // ============================================================== yardımcı ==
    private sealed record Hesap(int Id, string Kod, string KullaniciAdi, string Sifre,
                                string UygulamaKodu, string Adres);

    private static async Task<Hesap> HesapOkuAsync(
        NpgsqlConnection baglanti, int id, CancellationToken iptal)
    {
        var k = await baglanti.TekAsync("""
            select e.id, e.kod, e.kullanici_adi, e.sifre, e.uygulama_kodu,
                   case when e.test_mi = 1 and coalesce(e.test_url, '') <> ''
                        then e.test_url else e.url end as adres,
                   e.aktif
              from public.entegrasyon_hesap e where e.id = @p0
            """, null, [id], Satir, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Entegrasyon hesabı bulunamadı.");

        string M(string ad) => k[ad]?.ToString() ?? "";

        if (Convert.ToInt32(k["aktif"] ?? 0) != 1)
            throw GentegreHatasi.IsKurali("Hesap pasif - önce aktifleştirin.");
        if (M("kullanici_adi") == "" || M("sifre") == "")
            throw GentegreHatasi.IsKurali(
                "Kullanıcı adı ve şifre girilmemiş (Ayarlar › Kayıt Kabul › Entegrasyon).");
        if (M("adres") == "")
            throw GentegreHatasi.IsKurali("Servis adresi boş - hesap kartında doldurun.");

        return new Hesap(id, M("kod"), M("kullanici_adi"), M("sifre"),
                         M("uygulama_kodu"), M("adres"));
    }

    private static async Task SonucYazAsync(
        NpgsqlConnection baglanti, int id, string sonuc, CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.entegrasyon_hesap
               set son_kullanim = (now())::timestamp,
                   son_sonuc = left(@p1, 300)
             where id = @p0
            """, null, [id, sonuc], iptal);

    /// <summary>
    /// SKRS'ye en ucuz çağrı: kod sistemi listesini ister. Amaç veriyi almak
    /// değil, KİMLİĞİN geçerliliğini görmek - hata metni kullanıcıya döner.
    /// </summary>
    private static async Task<(bool, string)> SkrsDenemeAsync(
        Hesap hesap, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        try
        {
            var degerler = await SkrsListesiCekAsync(hesap, SkrsListeleri[0].SkrsAd,
                                                     istemciler, iptal);
            return degerler.Count > 0
                ? (true, $"Bağlantı başarılı - {SkrsListeleri[0].SkrsAd} listesinde "
                         + $"{degerler.Count} kod okundu.")
                : (false, "Bağlantı kuruldu ama servis boş liste döndü "
                          + "(kullanıcı/uygulama kodu yetkisiz olabilir).");
        }
        catch (Exception h)
        {
            return (false, $"Bağlantı kurulamadı: {h.Message}");
        }
    }

    /// <summary>
    /// SKRS kod listesini çeker. Servis SOAP: kimlik üç HTTP başlığında
    /// gider (KullaniciAdi / Sifre / UygulamaKodu), gövde GetSkrsList
    /// çağrısıdır. Cevap XML'inden kod + ad çiftleri ayıklanır.
    /// </summary>
    private static async Task<List<(string Kod, string Ad)>> SkrsListesiCekAsync(
        Hesap hesap, string skrsAd, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        var istemci = istemciler.CreateClient("skrs");

        var govde = $"""
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
              <s:Body>
                <GetSkrsList xmlns="http://tempuri.org/">
                  <skrsCodeSystemName>{skrsAd}</skrsCodeSystemName>
                </GetSkrsList>
              </s:Body>
            </s:Envelope>
            """;

        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Adres)
        {
            Content = new StringContent(govde, Encoding.UTF8, "text/xml"),
        };
        istek.Headers.TryAddWithoutValidation("KullaniciAdi", hesap.KullaniciAdi);
        istek.Headers.TryAddWithoutValidation("Sifre", hesap.Sifre);
        istek.Headers.TryAddWithoutValidation("UygulamaKodu", hesap.UygulamaKodu);
        istek.Headers.TryAddWithoutValidation("SOAPAction", "http://tempuri.org/ISKRSServis/GetSkrsList");

        using var yanit = await istemci.SendAsync(istek, iptal);
        var metin = await yanit.Content.ReadAsStringAsync(iptal);

        if (!yanit.IsSuccessStatusCode)
            throw new InvalidOperationException(
                $"HTTP {(int)yanit.StatusCode} - {Kisalt(metin)}");

        // Cevap şeması sürümle değişebiliyor: "kod/ad" ya da "value/name"
        //   adlı düğümler aranır, ad alanı eşleşmezse düğüm atlanır.
        var liste = new List<(string, string)>();
        var belge = XDocument.Parse(metin);
        foreach (var dugum in belge.Descendants())
        {
            var kod = AltDeger(dugum, "kod", "code", "value", "deger");
            var ad = AltDeger(dugum, "ad", "aciklama", "name", "text");
            if (kod is null || ad is null) continue;
            liste.Add((kod, ad));
        }
        return liste;
    }

    private static string? AltDeger(XElement dugum, params string[] adlar)
    {
        foreach (var alt in dugum.Elements())
            if (adlar.Contains(alt.Name.LocalName, StringComparer.OrdinalIgnoreCase)
                && !string.IsNullOrWhiteSpace(alt.Value))
                return alt.Value.Trim();
        return null;
    }

    private static string Kisalt(string s)
        => s.Length <= 200 ? s : s[..200] + "…";

    /// <summary>
    /// Yerel kod listesini SKRS değerleriyle günceller. SAYISAL olmayan SKRS
    /// kodu atlanır: `kod_deger.deger` integer'dır (metin kodlu listeler için
    /// ayrı görünüm gerekir; bugünkü dört liste sayısaldır).
    /// </summary>
    private static async Task<int> ListeYazAsync(
        NpgsqlConnection baglanti, string listeKodu,
        List<(string Kod, string Ad)> degerler, int kullanici, CancellationToken iptal)
    {
        await baglanti.CalistirAsync("""
            insert into public.kod_liste (kod, ad)
            select @p0, @p0
             where not exists (select 1 from public.kod_liste where kod = @p0)
            """, null, [listeKodu], iptal);

        var sayac = 0;
        foreach (var (kod, ad) in degerler)
        {
            if (!int.TryParse(kod, out var sayi)) continue;
            await baglanti.CalistirAsync("""
                insert into public.kod_deger (liste_id, deger, ad, ekleyen)
                select kl.id, @p1, @p2, @p3 from public.kod_liste kl where kl.kod = @p0
                on conflict (liste_id, deger) do update set ad = excluded.ad
                """, null, [listeKodu, sayi, ad, kullanici], iptal);
            sayac++;
        }
        return sayac;
    }
}
