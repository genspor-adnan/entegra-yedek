using System.Diagnostics;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Its;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// İTS (İLAÇ TAKİP SİSTEMİ) SERVİSİ — v1 (Faz 1).
///
/// Kaynak: its.gov.tr REST API servis adres listesi (05.07.2022). Kullanılan
/// uçlar:
/// <list type="bullet">
///   <item><c>/token/app/token/</c> — kimlik (kullanıcı + şifre → jeton)</item>
///   <item><c>/reference/app/verification/</c> — karekod doğrulama</item>
///   <item><c>/common/app/accept/</c> — MAL ALIM (kabul) bildirimi</item>
/// </list>
///
/// <para><b>ÜTS DEĞİL İTS.</b> ÜTS tıbbi cihaz/malzeme, İTS ilaç içindir;
/// ayrı kurum, ayrı servis. Yol haritasında bir ara "ilaç → ÜTS" yazılmıştı,
/// düzeltildi.</para>
///
/// <para><b>Kapı kapalıyken sahte başarı yok.</b> İTS kurum kaydı ve test
/// ortamı başvurusu tamamlanmadan hesap tanımlı değildir; bildirimler
/// üretilir ve kuyrukta bekler. "Gönderildi" işaretlemek, yasal bildirim
/// yükümlülüğü yerine getirilmemişken getirilmiş görünmek olurdu.</para>
///
/// <para><b>Jeton önbelleklenir.</b> Her bildirimde yeniden token almak hem
/// yavaş hem de servis tarafında kota sorunu; jeton süresi dolmadan yeniden
/// kullanılır.</para>
/// </summary>
public sealed class ItsServisi
{
    private readonly VeriKaynagi _veri;
    private readonly IHttpClientFactory _http;
    private readonly ILogger<ItsServisi> _gunluk;

    /// <summary>Jeton önbelleği - süresi dolmadan yeniden alınmaz.</summary>
    private static string _jeton = "";
    private static DateTime _jetonBitis = DateTime.MinValue;
    private static readonly SemaphoreSlim JetonKilidi = new(1, 1);

    public ItsServisi(VeriKaynagi veri, IHttpClientFactory http, ILogger<ItsServisi> gunluk)
    {
        _veri = veri;
        _http = http;
        _gunluk = gunluk;
    }

    public sealed record Hesap(string Adres, string Kullanici, string Sifre, string Gln,
                               bool TestMi);
    public sealed record Sonuc(int Alinan, int Gonderilen, int Hatali, string Aciklama);
    public sealed record DogrulamaSonucu(bool Gecerli, string Durum, string Mesaj);

    // --------------------------------------------------------------- hesap
    /// <summary>
    /// İTS hesabı; yoksa ya da adresi boşsa null.
    ///
    /// Yarım yapılandırılmış hesap hesap sayılmaz: her bildirime
    /// "bağlanılamadı" yazıp kuyruğu hatalarla doldururdu.
    /// </summary>
    public async Task<Hesap?> HesapAlAsync(CancellationToken iptal)
    {
        var h = await _veri.TekAsync("""
            select coalesce(nullif(case when e.test_mi = 1 then e.test_url else e.url end, ''), ''),
                   coalesce(e.kullanici_adi, ''), coalesce(e.sifre, ''),
                   coalesce(e.uygulama_kodu, ''), e.test_mi
              from public.entegrasyon_hesap e
             where e.kod = 'ITS' and e.aktif = 1
             limit 1
            """, null,
            o => new Hesap(o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3),
                           o.GetInt16(4) == 1), iptal);

        return h is null || h.Adres.Length == 0 ? null : h;
    }

    private async Task<string> JetonAlAsync(Hesap hesap, CancellationToken iptal)
    {
        await JetonKilidi.WaitAsync(iptal);
        try
        {
            if (_jeton.Length > 0 && DateTime.Now < _jetonBitis) return _jeton;

            var istemci = _http.CreateClient("its");
            istemci.Timeout = TimeSpan.FromSeconds(30);

            var govde = JsonSerializer.Serialize(new
            {
                username = hesap.Kullanici,
                password = hesap.Sifre,
            });
            using var yanit = await istemci.PostAsync($"{hesap.Adres}/token/app/token/",
                new StringContent(govde, Encoding.UTF8, "application/json"), iptal);

            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            if (!yanit.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    $"İTS jetonu alınamadı ({(int)yanit.StatusCode}): {Kirp(metin, 200)}");

            using var belge = JsonDocument.Parse(metin);
            var jeton = belge.RootElement.TryGetProperty("token", out var t) ? t.GetString()
                      : belge.RootElement.TryGetProperty("access_token", out var a)
                        ? a.GetString() : null;
            if (string.IsNullOrWhiteSpace(jeton))
                throw new InvalidOperationException("İTS yanıtında jeton yok.");

            _jeton = jeton;
            // Servis süreyi bildirmiyorsa 50 dakika: jetonun ömrü bir saat
            //   olarak belgelenmiş, sınıra dayanmamak için pay bırakılır.
            _jetonBitis = DateTime.Now.AddMinutes(50);
            return _jeton;
        }
        finally { JetonKilidi.Release(); }
    }

    // ---------------------------------------------------------- doğrulama
    /// <summary>
    /// Karekodu İTS'de doğrular (<c>/reference/app/verification/</c>).
    ///
    /// Doğrulama İSTEĞE BAĞLIDIR: hesap yoksa kod yine kaydedilir, yalnız
    /// "doğrulanmadı" kalır. Doğrulamayı zorunlu kılmak, kapı kapalıyken mal
    /// kabulünü tamamen durdururdu.
    /// </summary>
    public async Task<DogrulamaSonucu> DogrulaAsync(KarekodCozumleme.Karekod kod,
                                                    CancellationToken iptal)
    {
        var hesap = await HesapAlAsync(iptal);
        if (hesap is null)
            return new DogrulamaSonucu(false, "hesapsiz",
                "İTS hesabı tanımlı değil - karekod doğrulanmadan kaydedildi.");

        try
        {
            var jeton = await JetonAlAsync(hesap, iptal);
            var istemci = _http.CreateClient("its");
            istemci.Timeout = TimeSpan.FromSeconds(30);

            using var istek = new HttpRequestMessage(HttpMethod.Post,
                $"{hesap.Adres}/reference/app/verification/")
            {
                Content = new StringContent(JsonSerializer.Serialize(new
                {
                    gtin = kod.Gtin,
                    serialNumber = kod.SeriNo,
                    lotNumber = kod.PartiNo,
                    expirationDate = kod.SonKullanma?.ToString("yyMMdd") ?? "",
                }), Encoding.UTF8, "application/json"),
            };
            istek.Headers.Add("Authorization", jeton);

            using var yanit = await istemci.SendAsync(istek, iptal);
            var metin = await yanit.Content.ReadAsStringAsync(iptal);

            return yanit.IsSuccessStatusCode
                ? new DogrulamaSonucu(true, "gecerli", Kirp(metin, 200))
                : new DogrulamaSonucu(false, "gecersiz", Kirp(metin, 200));
        }
        catch (Exception h)
        {
            // Dogrulama SERVIS hatasi mal kabulu durdurmaz: kod kaydedilir,
            //   dogrulama "yapilamadi" kalir ve bildirim yine kuyruga girer.
            _gunluk.LogWarning(h, "İTS doğrulaması yapılamadı (GTIN {Gtin})", kod.Gtin);
            return new DogrulamaSonucu(false, "hata", Kirp(h.Message, 200));
        }
    }

    // ------------------------------------------------------------ gönderim
    /// <summary>
    /// Kuyruktaki bildirimleri gönderir.
    ///
    /// Hata sınıfı ayrımı gerçek: servis hatası üstel beklemeyle tekrarlanır,
    /// veri hatası tekrarlanmaz - aynı veriyi beş kez göndermek aynı reddi beş
    /// kez almaktır.
    /// </summary>
    public async Task<Sonuc> CalistirAsync(int adet, int? bildirimId, CancellationToken iptal)
    {
        var hesap = await HesapAlAsync(iptal);
        if (hesap is null)
            return new Sonuc(0, 0, 0,
                "İTS hesabı tanımlı değil (entegrasyon: ITS) - bildirimler kuyrukta bekliyor.");

        var bildirimler = bildirimId is null
            ? await _veri.ListeAsync("select * from public.fn_its_siradakiler(@p0)",
                [adet], OkuBildirim, iptal)
            : await _veri.ListeAsync("""
                update public.its_bildirim
                   set durum = 2, deneme = deneme + 1, son_deneme = now()
                 where id = @p0 and durum in (0, 1, 4)
                returning id, tur, coalesce(karsi_gln, '') as karsi_gln, islem_tarihi
                """, [bildirimId], OkuBildirim, iptal);

        if (bildirimler.Count == 0)
            return new Sonuc(0, 0, 0, "Gönderilecek bildirim yok.");

        int gonderilen = 0, hatali = 0;
        foreach (var b in bildirimler)
        {
            var (basarili, kod, mesaj, ham, yanit) = await GonderAsync(hesap, b, iptal);
            if (basarili)
            {
                gonderilen++;
                await _veri.CalistirAsync("""
                    update public.its_bildirim
                       set durum = 3, its_bildirim_no = @p1, ham_istek = @p2, ham_yanit = @p3,
                           hata_kodu = '', hata_mesaj = '', hata_sinifi = 0
                     where id = @p0
                    """, [b.Id, kod, ham, yanit], iptal);
            }
            else
            {
                hatali++;
                var sinif = (short)(kod == "BAGLANTI" ? 2 : kod == "YETKI" ? 3 : 1);
                var bekle = sinif == 2 ? 15 : 0;
                await _veri.CalistirAsync("""
                    update public.its_bildirim
                       set durum = 4, hata_kodu = @p1, hata_mesaj = @p2, hata_sinifi = @p3,
                           ham_istek = @p4, ham_yanit = @p5,
                           planlanan = case when @p3 = 2
                                            then now() + (@p6 || ' minutes')::interval
                                            else planlanan end
                     where id = @p0
                    """, [b.Id, kod, mesaj, sinif, ham, yanit, bekle], iptal);
            }
        }

        return new Sonuc(bildirimler.Count, gonderilen, hatali,
            $"{bildirimler.Count} bildirim denendi: {gonderilen} gitti, {hatali} hata.");
    }

    private sealed record BildirimOzet(int Id, short Tur, string KarsiGln, DateTime? Tarih);

    private static BildirimOzet OkuBildirim(Npgsql.NpgsqlDataReader o)
        => new(o.GetInt32(o.GetOrdinal("id")),
               o.GetInt16(o.GetOrdinal("tur")),
               o.GetString(o.GetOrdinal("karsi_gln")),
               o.IsDBNull(o.GetOrdinal("islem_tarihi"))
                   ? null : o.GetDateTime(o.GetOrdinal("islem_tarihi")));

    private async Task<(bool, string, string, string, string)> GonderAsync(
        Hesap hesap, BildirimOzet b, CancellationToken iptal)
    {
        var satirlar = await _veri.ListeAsync("""
            select gtin, seri_no, parti_no, to_char(son_kullanma, 'YYMMDD')
              from public.its_bildirim_satir where bildirim_id = @p0 order by id
            """, [b.Id],
            o => new
            {
                gtin = o.GetString(0), serialNumber = o.GetString(1),
                lotNumber = o.GetString(2), expirationDate = o.IsDBNull(3) ? "" : o.GetString(3),
            }, iptal);

        // MAL ALIM = "kabul" (/common/app/accept/). Tuketim ve iade Faz 2;
        //   yol farkli oldugu icin tur burada acikca eslenir.
        var yol = b.Tur switch
        {
            1 => "/common/app/accept/",
            2 => "/consume/app/consume/",
            3 => "/common/app/return/",
            4 => "/common/app/deactivation/",
            _ => "",
        };
        if (yol.Length == 0) return (false, "TUR", "Desteklenmeyen bildirim türü.", "", "");

        var govde = JsonSerializer.Serialize(new
        {
            senderGln = hesap.Gln,
            receiverGln = b.KarsiGln,
            documentDate = (b.Tarih ?? DateTime.Today).ToString("yyyy-MM-dd"),
            products = satirlar,
        });

        var kronometre = Stopwatch.StartNew();
        try
        {
            var jeton = await JetonAlAsync(hesap, iptal);
            var istemci = _http.CreateClient("its");
            istemci.Timeout = TimeSpan.FromSeconds(60);

            using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Adres + yol)
            {
                Content = new StringContent(govde, Encoding.UTF8, "application/json"),
            };
            istek.Headers.Add("Authorization", jeton);

            using var yanit = await istemci.SendAsync(istek, iptal);
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            kronometre.Stop();

            if (!yanit.IsSuccessStatusCode)
            {
                var s = (int)yanit.StatusCode;
                return (false, s is 401 or 403 ? "YETKI" : s >= 500 ? "BAGLANTI" : $"HTTP{s}",
                        Kirp(metin, 400), govde, Kirp(metin, 4000));
            }

            return (true, BildirimNoCoz(metin), "", govde, Kirp(metin, 4000));
        }
        catch (Exception h)
        {
            kronometre.Stop();
            return (false, "BAGLANTI", Kirp(h.Message, 400), govde, "");
        }
    }

    /// <summary>Yanıttan İTS bildirim numarası - bulunamazsa boş (gönderim yine başarılı).</summary>
    private static string BildirimNoCoz(string yanit)
    {
        try
        {
            using var belge = JsonDocument.Parse(yanit);
            foreach (var ad in new[] { "notificationId", "id", "documentId", "uuid" })
                if (belge.RootElement.TryGetProperty(ad, out var d))
                    return Kirp(d.ToString(), 64);
        }
        catch { /* yanit JSON degilse kimlik de yok */ }
        return "";
    }

    private static string Kirp(string m, int n)
        => string.IsNullOrEmpty(m) ? "" : m.Length <= n ? m : m[..n];
}
