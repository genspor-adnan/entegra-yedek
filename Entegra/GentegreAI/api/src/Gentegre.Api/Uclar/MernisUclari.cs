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
///   2) SGK      - KPS yoksa entegrasyon_hesap kod='MEDULA' aktif ve canlı adresi girilmiş;
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
             where kod = 'MEDULA' and aktif = 1 and coalesce(test_mi, 1) = 0 and coalesce(url, '') <> ''
               and (sube_id is null or sube_id = @p0)
            """, [subeId ?? 0], iptal) ?? 0;
        if (sgk > 0) return ("sgk", "SGK (MEDULA)");
        await using var b = await veri.AcAsync(iptal);
        var o = (await AyarDeposu.MetinAsync(b, null, "genel.ortam", "canli", iptal)).Trim().ToLowerInvariant();
        if (o is "demo" or "egitim" || ortam.IsDevelopment()) return ("simulasyon", "Benzetim (demo / eğitim kurulumu)");
        return ("yok", "");
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
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
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
                "sgk" => throw GentegreHatasi.IsKurali(
                    "SGK (MEDULA) hesabı tanımlı, ancak MEDULA üzerinden kimlik sorgusu bu sürümde henüz etkin değil. Kimlik bilgilerini elle girip 'Doğrula' ile denetleyebilirsiniz."),
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
