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
        // 340: hekim branşı ve sigorta türü de SKRS'den gelir.
        ("BRANS",               "hekim.brans"),
        ("SIGORTATURU",         "taraf.sigorta_turu"),
    };

    /// <summary>
    /// TABLO olarak tutulan SKRS listeleri (340): il · ilçe · ülke. Bunlar
    /// kod listesi değil, dolu ve referans verilen tablolardır - SKRS kodu
    /// `skrs_kod` kolonuna yazılır, `id` yerine geçmez. Sıra ÖNEMLİ: ilçe,
    /// ilin `skrs_kod`u dolduktan sonra bağlanabilir.
    /// </summary>
    private static readonly string[] SkrsTablolari = { "IL", "ILCE", "ULKE" };

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

            // SINAMA SERVISE GORE (340): SKRS'de gerçek kod listesi çağrısı
            //   yapılır; öteki servislerde SKRS SOAP gövdesi göndermek anlamsız
            //   (İzibiz "Servis kullanılmamaktadır" dönüyordu) - orada adresin
            //   ayakta olup olmadığına ve kimliğin dolu olduğuna bakılır.
            var (basarili, mesaj) = string.Equals(hesap.Kod, "SKRS", StringComparison.OrdinalIgnoreCase)
                ? await SkrsDenemeAsync(hesap, istemciler, iptal)
                : await AdresDenemeAsync(hesap, istemciler, iptal);
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

            // Tablo listeleri (340): il -> ilçe -> ülke sırasıyla.
            foreach (var skrsAd in SkrsTablolari)
            {
                var degerler = await SkrsListesiCekAsync(hesap, skrsAd, istemciler, iptal);
                if (degerler.Count == 0)
                {
                    raporlar.Add($"{skrsAd}: boş döndü");
                    continue;
                }

                var (yazilan, atlanan) = skrsAd switch
                {
                    "IL"   => await IlYazAsync(baglanti, degerler, iptal),
                    "ILCE" => await IlceYazAsync(baglanti, degerler, iptal),
                    _      => await UlkeYazAsync(baglanti, degerler, iptal),
                };
                toplam += yazilan;
                raporlar.Add(atlanan > 0
                    ? $"{skrsAd}: {yazilan} (atlanan {atlanan})"
                    : $"{skrsAd}: {yazilan}");
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
                   -- ADRES UC NOKTADAN (340): satirin kendi adresi, yoksa
                   --   servisin bilinen varsayilani (e-Belge entegrator
                   --   katalogu / UTS referans ayari). Satirda adres bos
                   --   birakmak NORMALDIR - gonderim de ayni sirayi izliyor;
                   --   "Sina" bunu bilmeyip "adres bos" diyordu.
                   coalesce(
                     nullif(btrim(case when e.test_mi = 1 then e.test_url else e.url end), ''),
                     case when e.kod = 'EBELGE' then
                       (select case when e.test_mi = 1 then en.test_url else en.uretim_url end
                          from public.ebelge_entegrator en where en.id = e.entegrator_id)
                     end,
                     case when e.kod = 'UTS' then
                       coalesce(
                         nullif(btrim((select r.deger from public.referans r
                                        where r.anahtar = case when e.test_mi = 1
                                                               then 'uts.test_url'
                                                               else 'uts.uretim_url' end)), ''),
                         case when e.test_mi = 1 then 'https://utstest.saglik.gov.tr'
                              else 'https://utsuygulama.saglik.gov.tr' end)
                     end,
                     '') as adres,
                   e.aktif
              from public.entegrasyon_hesap e where e.id = @p0
            """, null, [id], Satir, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Entegrasyon hesabı bulunamadı.");

        string M(string ad) => k[ad]?.ToString() ?? "";

        if (Convert.ToInt32(k["aktif"] ?? 0) != 1)
            throw GentegreHatasi.IsKurali("Hesap pasif - önce aktifleştirin.");
        // KIMLIK KONTROLU SERVISE GORE (340) ve sinamanin KENDISINDE: SKRS
        //   kullanıcı+şifre+uygulama kodu ister, ÜTS yalnız TOKEN (kullanıcı
        //   adı yoktur) - burada topluca "kullanıcı adı boş" demek ÜTS
        //   hesabının sınanmasını engelliyordu. Adres de artık üç noktadan
        //   çözülüyor; gerçekten boşsa sınama mesajı söyler.
        if (M("kod") == "SKRS" && (M("kullanici_adi") == "" || M("sifre") == ""))
            throw GentegreHatasi.IsKurali(
                "SKRS kullanıcı adı ve şifresi girilmemiş (Ayarlar › Genel › Entegrasyon).");

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
    /// SKRS dışındaki servisler için hafif sınama (340): adres ayakta mı ve
    /// kimlik alanları dolu mu. Gerçek oturum açma denemesi YAPILMAZ - her
    /// entegratörün kendi login sözleşmesi var ve yanlış istek kimi serviste
    /// hesabı kilitliyor; gönderim zaten kendi akışında doğruluyor.
    /// </summary>
    private static async Task<(bool, string)> AdresDenemeAsync(
        Hesap hesap, IHttpClientFactory istemciler, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(hesap.Adres))
            return (false, "Servis adresi boş - hesap kartında doldurun.");

        var eksik = new List<string>();
        if (string.IsNullOrWhiteSpace(hesap.KullaniciAdi) && hesap.Kod != "UTS")
            eksik.Add("kullanıcı adı");
        if (string.IsNullOrWhiteSpace(hesap.Sifre))
            eksik.Add(hesap.Kod == "UTS" ? "token" : "şifre");

        try
        {
            var istemci = istemciler.CreateClient("skrs");
            using var istek = new HttpRequestMessage(HttpMethod.Head, hesap.Adres);
            using var yanit = await istemci.SendAsync(istek, iptal);

            // 5xx = servis ayakta DEĞİL (502 "Bad Gateway" de dahil); 4xx bu
            //   sınamada normaldir - HEAD isteği yetkisiz/desteklenmez olabilir
            //   ama adres çözülüp yanıt üretmiştir.
            var kod = (int)yanit.StatusCode;
            var durum = $"HTTP {kod}";
            if (kod >= 500)
                return (false, $"Servis şu an yanıt veremiyor ({durum}) - adres doğru "
                               + "olabilir, servis tarafında sorun var.");

            return eksik.Count == 0
                ? (true, $"Adres yanıt veriyor ({durum}) ve kimlik alanları dolu. "
                         + "Gerçek oturum açma gönderim sırasında doğrulanır.")
                : (false, $"Adres yanıt veriyor ({durum}) ama {string.Join(" / ", eksik)} boş.");
        }
        catch (Exception h)
        {
            return (false, $"Adrese ulaşılamadı: {h.Message}");
        }
    }

    /// <summary>
    /// SKRS kod listesini çeker. Servis SOAP: kimlik üç HTTP başlığında
    /// gider (KullaniciAdi / Sifre / UygulamaKodu), gövde GetSkrsList
    /// çağrısıdır. Cevap XML'inden kod + ad çiftleri ayıklanır.
    /// </summary>
    private static async Task<List<(string Kod, string Ad, string? Ust)>> SkrsListesiCekAsync(
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
        // ÜST KOD (340): ilçe listesinde ilin kodu; ad karşılığı sürüme göre
        //   farklı yazıldığı için birkaç aday birden denenir.
        var liste = new List<(string, string, string?)>();
        var belge = XDocument.Parse(metin);
        foreach (var dugum in belge.Descendants())
        {
            var kod = AltDeger(dugum, "kod", "code", "value", "deger");
            var ad = AltDeger(dugum, "ad", "aciklama", "name", "text");
            if (kod is null || ad is null) continue;
            var ust = AltDeger(dugum, "ustkod", "ilkodu", "il_kodu", "parentcode",
                               "parent", "ustdeger");
            liste.Add((kod, ad, ust));
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
        List<(string Kod, string Ad, string? Ust)> degerler, int kullanici,
        CancellationToken iptal)
    {
        await baglanti.CalistirAsync("""
            insert into public.kod_liste (kod, ad)
            select @p0, @p0
             where not exists (select 1 from public.kod_liste where kod = @p0)
            """, null, [listeKodu], iptal);

        var sayac = 0;
        foreach (var (kod, ad, _) in degerler)
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

    // ===================================================== tablo yazıcıları ==
    // İl / ilçe / ülke KOD LİSTESİ DEĞİL, dolu ve referans verilen tablolardır
    //   (340). Bu yüzden SKRS kodu `id`nin yerine yazılmaz: önce ADA göre
    //   eşleşen satır aranır ve ona `skrs_kod` işlenir; eşleşme yoksa satır
    //   YENİ kayıt olarak eklenir (id = max + 1, tablolarda identity yok).

    /// <summary>SKRS IL listesi -> public.il (ad eşlemesi + skrs_kod).</summary>
    private static async Task<(int Yazilan, int Atlanan)> IlYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, _) in degerler)
        {
            if (!int.TryParse(kod, out var skrs)) { atlanan++; continue; }

            var etkilenen = await baglanti.CalistirAsync("""
                update public.il set skrs_kod = @p0
                 where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.il (id, ad, skrs_kod)
                    select coalesce((select max(id) from public.il), 0) + 1, @p1, @p0
                     where not exists (select 1 from public.il
                                        where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }

    /// <summary>
    /// SKRS ILCE listesi -> public.ilce. Eşleme (il, ad) çiftiyle: ilçe adı
    /// tek başına benzersiz değil (onlarca "MERKEZ"). İlin bağı SKRS üst
    /// kodundan çözülür; üst kod yoksa ya da o ilin `skrs_kod`u henüz
    /// dolmadıysa satır ATLANIR (yanlış ile bağlamak, adres kayıtlarını
    /// sessizce bozardı).
    /// </summary>
    private static async Task<(int Yazilan, int Atlanan)> IlceYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, ust) in degerler)
        {
            if (!int.TryParse(kod, out var skrs) || !int.TryParse(ust, out var ilSkrs))
            { atlanan++; continue; }

            var il = await baglanti.TekAsync(
                "select id from public.il where skrs_kod = @p0", null, [ilSkrs], Satir, iptal);
            if (il is null) { atlanan++; continue; }
            var ilId = Convert.ToInt32(il["id"]);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.ilce set skrs_kod = @p0
                 where il_id = @p2
                   and public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad, ilId], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.ilce (id, il_id, ad, aktif, skrs_kod)
                    select coalesce((select max(id) from public.ilce), 0) + 1, @p2, @p1, 1, @p0
                     where not exists (select 1 from public.ilce
                                        where il_id = @p2
                                          and public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad, ilId], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }

    /// <summary>SKRS ULKE listesi -> public.ulke (ad eşlemesi + skrs_kod).</summary>
    private static async Task<(int Yazilan, int Atlanan)> UlkeYazAsync(
        NpgsqlConnection baglanti, List<(string Kod, string Ad, string? Ust)> degerler,
        CancellationToken iptal)
    {
        int yazilan = 0, atlanan = 0;
        foreach (var (kod, ad, _) in degerler)
        {
            if (!int.TryParse(kod, out var skrs)) { atlanan++; continue; }

            var etkilenen = await baglanti.CalistirAsync("""
                update public.ulke set skrs_kod = @p0
                 where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1)
                   and skrs_kod is distinct from @p0
                """, null, [skrs, ad], iptal);

            if (etkilenen == 0)
                await baglanti.CalistirAsync("""
                    insert into public.ulke (id, ad, skrs_kod)
                    select coalesce((select max(id) from public.ulke), 0) + 1, @p1, @p0
                     where not exists (select 1 from public.ulke
                                        where public.fn_ara_metin(ad) = public.fn_ara_metin(@p1))
                    """, null, [skrs, ad], iptal);

            yazilan++;
        }
        return (yazilan, atlanan);
    }
}
