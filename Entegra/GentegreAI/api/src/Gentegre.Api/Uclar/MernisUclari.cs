using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MERNİS / KPS uçları (kullanıcı 19.10.2026: "yeni hasta kartı bilgilerini MERNİS'ten getirebilmemiz lazım",
/// "MERNİS kullanmayan ama SGK bağlantısı olan müşterilerde kimliği SGK'dan getir").
///
/// KANAL SIRASI (sunucu karar verir, ekran sormaz):
///   1) KPS      - entegrasyon_hesap kod='KPS' aktif ve kullanıcısı girilmiş;
///   2) SGK      - KPS yoksa entegrasyon_hesap kod='MEDULA' aktif: MEDULA kapısı (IMedulaKapisi, işlem
///                 kimlikSorgu). Test hesabında kapı simülasyondur - canlı kurumda reddedilir; canlı hesapta
///                 canlı kapı (bağlanınca kendiliğinden). Anne / baba adı ve doğum yeri SGK'dan gelmez;
///   3) benzetim - yalnız DEMO / EĞİTİM kurulumunda ya da geliştirme ortamında. CANLI kurumda asla sahte
///                 kişi üretilmez: kanal yoksa açık hata ("KPS ya da SGK hesabı tanımlayın").
/// Her sorgu işlem loguna yazılır (kim, ne zaman, hangi kimlik no, hangi kanal).
/// </summary>
public static class MernisUclari
{
    /// <summary>İşlem logu tablo kodu: kimlik sorguları (KPS / SGK / benzetim / NVİ doğrulama).</summary>
    public const int LogKimlikSorgu = 953;

    public sealed record GetirIstegi(string KimlikNo);
    public sealed record DogrulaIstegi(string KimlikNo, string Ad, string Soyad, int DogumYili);

    private static async Task<bool> CanliOrtamAsync(VeriKaynagi veri, IWebHostEnvironment ortam, CancellationToken iptal)
    {
        if (ortam.IsDevelopment()) return false;
        await using var b = await veri.AcAsync(iptal);
        var o = (await AyarDeposu.MetinAsync(b, null, "genel.ortam", "canli", iptal)).Trim().ToLowerInvariant();
        return o is not ("demo" or "egitim");
    }

    private static async Task<(string Kanal, string Aciklama)> KanalAsync(
        VeriKaynagi veri, IWebHostEnvironment ortam, int? subeId, CancellationToken iptal)
    {
        // Şubenin kendi hesabı yoksa kurum geneli (sube_id boş) - entegrasyon_hesap'ın ortak kuralı.
        var kps = await veri.TekDegerAsync<long?>("""
            select count(*) from public.entegrasyon_hesap
             where kod = 'KPS' and aktif = 1 and coalesce(kullanici_adi, '') <> ''
               and (sube_id is null or sube_id = @p0)
            """, [subeId ?? 0], iptal) ?? 0;
        if (kps > 0) return ("kps", "KPS (NVİ Kimlik Paylaşım Sistemi)");
        var sgk = await veri.TekDegerAsync<long?>("""
            select count(*) from public.entegrasyon_hesap
             where kod = 'MEDULA' and aktif = 1 and (sube_id is null or sube_id = @p0)
            """, [subeId ?? 0], iptal) ?? 0;
        if (sgk > 0) return ("sgk", "SGK (MEDULA)");
        if (!await CanliOrtamAsync(veri, ortam, iptal)) return ("simulasyon", "Benzetim (demo / eğitim kurulumu)");
        return ("yok", "");
    }

    /// <summary>
    /// SGK KANALI: MEDULA kapısına <c>kimlikSorgu</c>. Kuyruğa yazılmaz - hasta bankoda bekliyor, sonradan
    /// denemenin anlamı yok; kapı kapalıysa açık hata. Test hesabı (simülasyon kapısı) canlı kurumda
    /// kullanılmaz: sahte kişi gerçek karta yazılmasın.
    /// </summary>
    private static async Task<MernisServisi.KisiBilgisi> SgkKimlikAsync(VeriKaynagi veri, IWebHostEnvironment ortam,
        IMedulaKapisi medula, string tc, int? subeId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var test = await b.TekDegerAsync<int?>("""
            select coalesce(test_mi, 1)::int from public.entegrasyon_hesap
             where kod = 'MEDULA' and aktif = 1 and (sube_id is null or sube_id = @p0)
             order by sube_id nulls last limit 1
            """, null, [subeId ?? 0], iptal) ?? 1;
        if (test == 1 && await CanliOrtamAsync(veri, ortam, iptal))
            throw GentegreHatasi.IsKurali("MEDULA hesabı TEST modunda - canlı kurumda SGK'dan kimlik getirilemez. Hesabı canlıya alın ya da bilgileri elle girin.");
        KapiYaniti y;
        try
        {
            using var d = System.Text.Json.JsonDocument.Parse(System.Text.Json.JsonSerializer.Serialize(new { tckn = tc }));
            y = await medula.CagirAsync(b, "kimlikSorgu", d.RootElement.Clone(), null, null, null, iptal);
        }
        catch (Exception h) when (h is not GentegreHatasi)
        {
            throw GentegreHatasi.IsKurali("SGK (MEDULA) kimlik sorgusu yapılamadı: " + h.Message);
        }
        if (y.Kod != "0000" || y.Yanit is null) throw GentegreHatasi.IsKurali($"SGK: {y.Mesaj} ({y.Kod})");
        string M(string a) => y.Yanit.TryGetValue(a, out var v) ? v?.ToString() ?? "" : "";
        return new MernisServisi.KisiBilgisi(tc, M("ad"), M("soyad"),
            DateOnly.TryParse(M("dogumTarihi"), out var dt) ? dt : null, M("cinsiyet"), "", "", "", Simulasyon: test == 1);
    }

    public static void MernisUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/mernis").WithTags("MERNİS").RequireAuthorization();

        // Hangi kanal - kart düğmesinin ipucu ve ayar ekranı için.
        grup.MapGet("/durum", async (VeriKaynagi veri, IWebHostEnvironment ortam, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var (kanal, aciklama) = await KanalAsync(veri, ortam, baglam.SubeId, iptal);
            return Results.Ok(new { kanal, aciklama });
        });

        // MERNİS'TEN GETİR: hasta kartı ekleyebilen ya da değiştirebilen kullanıcı.
        grup.MapPost("/getir", async (GetirIstegi istek, VeriKaynagi veri, IWebHostEnvironment ortam, LogDeposu log,
            IMedulaKapisi medula, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("hasta", Islem.Ekle) && !baglam.Yetkiler.Var("hasta", Islem.Degistir))
                throw GentegreHatasi.Yasak("Hasta kartı ekleme / değiştirme yetkiniz yok.");
            var tc = (istek.KimlikNo ?? "").Trim();
            if (!MernisServisi.TcGecerli(tc)) throw GentegreHatasi.Dogrulama("Geçerli bir T.C. kimlik no girin (11 hane).");

            var (kanal, aciklama) = await KanalAsync(veri, ortam, baglam.SubeId, iptal);
            await log.YazAsync(LogIslemi.Ekle, LogKimlikSorgu, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "getir", kanal, kimlikNo = tc }, iptal: iptal);
            var kisi = kanal switch
            {
                "simulasyon" => MernisServisi.Simulasyon(tc),
                // CANLI KPS / SGK: kurumun bilgileri ve servis tanımı (WSDL) ile bağlanır. Bu sürümde canlı uç
                //   bağlı değil - Medula canlı kapısıyla aynı kural: sessizce sahte veri DÖNMEZ, açıkça söyler.
                "kps" => throw GentegreHatasi.IsKurali(
                    "KPS hesabı tanımlı, ancak canlı KPS bağlantısı bu sürümde henüz etkin değil. Kimlik bilgilerini elle girip 'Doğrula' ile denetleyebilirsiniz."),
                "sgk" => await SgkKimlikAsync(veri, ortam, medula, tc, baglam.SubeId, iptal),
                _ => throw GentegreHatasi.IsKurali(
                    "Kimlik sorgu kanalı tanımlı değil: Genel Ayarlar › Entegrasyon'da KPS ya da MEDULA (SGK) hesabı tanımlayın."),
            };
            return Results.Ok(new
            {
                kanal, aciklama,
                kisi.KimlikNo, kisi.Ad, kisi.Soyad,
                dogumTarihi = kisi.DogumTarihi?.ToString("yyyy-MM-dd"),
                // Kart kod listesi hasta.cinsiyet: 1 Erkek · 2 Kadın.
                cinsiyet = kisi.Cinsiyet == "E" ? "1" : kisi.Cinsiyet == "K" ? "2" : "",
                kisi.BabaAdi, anaAdi = kisi.AnneAdi, kisi.DogumYeri, kisi.Simulasyon,
            });
        });

        // NVİ HERKESE AÇIK DOĞRULAMA: bilgi getirmez, eşleşiyor mu der. Kullanıcı / şifre gerekmez.
        grup.MapPost("/dogrula", async (DogrulaIstegi istek, MernisServisi mernis, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!baglam.Yetkiler.Var("hasta", Islem.Gor))
                throw GentegreHatasi.Yasak("Hasta kartı yetkiniz yok.");
            var tc = (istek.KimlikNo ?? "").Trim();
            if (!MernisServisi.TcGecerli(tc)) throw GentegreHatasi.Dogrulama("Geçerli bir T.C. kimlik no girin (11 hane).");
            if (string.IsNullOrWhiteSpace(istek.Ad) || string.IsNullOrWhiteSpace(istek.Soyad) || istek.DogumYili < 1900)
                throw GentegreHatasi.Dogrulama("Doğrulama için ad, soyad ve doğum yılı gerekli.");
            var sonuc = await mernis.NviDogrulaAsync(tc, istek.Ad, istek.Soyad, istek.DogumYili, iptal);
            await log.YazAsync(LogIslemi.Ekle, LogKimlikSorgu, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { islem = "dogrula", kanal = "nvi", kimlikNo = tc, sonuc }, iptal: iptal);
            return Results.Ok(new { dogru = sonuc, ulasilamadi = sonuc is null });
        });
    }
}
