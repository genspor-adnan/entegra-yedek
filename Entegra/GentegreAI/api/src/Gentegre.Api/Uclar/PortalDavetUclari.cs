using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authorization;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PORTAL DAVETİ (822) — hastaya SMS/e-posta ile tek kullanımlık bağlantı.
///
/// <para><b>819 ile farkı:</b> orada yönetici hesabı açar ve kullanıcı kodunu
/// kişiye söyler. Dış hekimde çalışır, hastada çalışmaz - hastaya "portalımız
/// var, şu kodla gir" demek kodu da yöntemi de anlatmak demektir. Davet bunu
/// tersine çevirir: bağlantı hastaya gider, hesabını kendi açar.</para>
///
/// <para><b>Jeton depoda DÜZ DURMAZ.</b> Saklanan SHA-256 özeti; gelen jeton
/// özetlenip aranır. Veritabanını (ya da yedeğini) okuyan biri, özetten
/// çalışan bir bağlantı üretemez.</para>
///
/// <para><b>Doğrulama iki parçalı:</b> bağlantı + TCKN son 4. Yalnız bağlantı
/// yeterli olsaydı, yanlış numaraya giden ya da ekran görüntüsü paylaşılan bir
/// SMS başkasının sağlık kayıtlarını açardı. Beş yanlış denemede davet kapanır.
/// </para>
/// </summary>
public static class PortalDavetUclari
{
    private const int LogTabloKullanici = 902;
    private const int EnFazlaDeneme = 5;

    public sealed record DavetIstegi(int TarafId, short Kanal = 1, string? Alici = null);
    public sealed record DavetKullanIstegi(string Jeton, string TcknSon4, string YeniParola);

    public static void PortalDavetUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // ---------------------------------------------------- yönetici ucu ----
        var grup = yol.MapGroup("/api/kullanici").WithTags("Kullanıcı").RequireAuthorization();

        grup.MapPost("/portal-davet", async (
            DavetIstegi istek, BaglamCozucu cozucu, PortalDavetServisi davet,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("kullanici.portal");

            // ÜRETİM TEK YERDE (PortalDavetServisi): "Portal Erişimi" akışı da
            //   aynı servisi çağırıyor - jeton, süre ve şablon iki yerde
            //   yaşamasın.
            var sonuc = await davet.UretVeGonderAsync(
                istek.TarafId, istek.Kanal, istek.Alici, baglam, zorunlu: true, iptal)
                ?? throw GentegreHatasi.IsKurali("Davet üretilemedi.");

            await log.YazAsync(LogIslemi.Ekle, LogTabloKullanici, istek.TarafId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["islem"] = "Portal daveti gönderildi",
                    ["kanal"] = sonuc.Kanal == 1 ? "SMS" : "E-posta",
                    // ALICI MASKELİ: günlük satırı da kişisel veridir.
                    ["alici"] = sonuc.MaskeliAlici,
                    ["gecerlilikSaat"] = sonuc.GecerlilikSaat.ToString(),
                }, iptal: iptal);

            return Results.Ok(new
            {
                davetId = sonuc.DavetId,
                kanal = sonuc.Kanal,
                alici = sonuc.MaskeliAlici,
                gecerlilikSaat = sonuc.GecerlilikSaat,
                bildirimId = sonuc.BildirimId,
                // JETON DÖNMEZ: bağlantı YALNIZ kişiye gider. Yöneticiye de
                //   göstermek, hastanın kaydını yönetici eliyle açılabilir
                //   kılardı.
                mesaj = sonuc.Mesaj,
            });
        });

        // ---------------------------------------------- oturumsuz davet ucu ----
        // `/f/{kod}` (740) ile aynı desen: kişi henüz giriş yapamıyor, bu
        //   yüzden uç anonim. Kimlik kanıtı istekte taşınır.
        var acik = yol.MapGroup("/api/davet").WithTags("Portal Daveti");

        acik.MapGet("/{jeton}", [AllowAnonymous] async (
            string jeton, VeriKaynagi veri, CancellationToken iptal) =>
        {
            await using var b = await veri.AcAsync(iptal);
            var d = await DavetBulAsync(b, jeton, iptal);

            // GEÇERSİZ DAVETTE SEBEP SÖYLENMEZ: "süresi dolmuş" ile "böyle bir
            //   bağlantı yok" ayrımı, elindeki jetonun gerçek olup olmadığını
            //   söylerdi. Tek yanıt.
            if (d is null) return Results.Ok(new { gecerli = false });

            return Results.Ok(new
            {
                gecerli = true,
                kisi = (string)(d["unvan"] ?? ""),
                // Hangi kimlik kanıtının isteneceği ekranda yazsın.
                kanit = "TCKN son 4 hane",
            });
        });

        acik.MapPost("/kullan", [AllowAnonymous] async (
            DavetKullanIstegi istek, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            const string ortakHata = "Bağlantı geçersiz ya da kimlik doğrulaması hatalı.";

            var parola = (istek.YeniParola ?? "").Trim();
            if (parola.Length < 6)
                throw GentegreHatasi.Dogrulama("Parola en az 6 karakter olmalı.");

            await using var b = await veri.AcAsync(iptal);
            var d = await DavetBulAsync(b, istek.Jeton, iptal)
                ?? throw GentegreHatasi.Yetkisiz(ortakHata);

            var davetId = Convert.ToInt64(d["id"]);
            var tarafId = Convert.ToInt32(d["tarafId"]);
            var tckn = ((string)(d["tckn"] ?? "")).Trim();
            var son4 = (istek.TcknSon4 ?? "").Trim();

            if (tckn.Length < 4 || son4.Length != 4
                || !tckn.EndsWith(son4, StringComparison.Ordinal))
            {
                // DENEME SAYILIR: beşincide davet kapanır - 10.000 ihtimalli
                //   bir sayı sınırsız denenebilseydi bağlantıyı ele geçiren
                //   kişi kaba kuvvetle açardı.
                var deneme = await b.TekDegerAsync<int>("""
                    update public.portal_davet
                       set deneme = deneme + 1,
                           durum = case when deneme + 1 >= @p1 then 3 else durum end
                     where id = @p0
                    returning deneme
                    """, null, [davetId, EnFazlaDeneme], iptal);
                throw GentegreHatasi.Yetkisiz(deneme >= EnFazlaDeneme
                    ? "Bağlantı kapatıldı: kimlik doğrulaması çok kez hatalı girildi."
                    : ortakHata);
            }

            var rolId = await b.TekDegerAsync<int?>(
                "select id from public.rol where portal_turu = 3 and coalesce(aktif, 1) = 1 "
                + "order by id limit 1", null, [], iptal)
                ?? throw GentegreHatasi.IsKurali("Hasta portalı rolü tanımlı değil (818).");

            // KOD = TCKN: hasta kendi bildiği numarayla girer. Çakışma olamaz -
            //   TCKN benzersiz; yine de kontrol edilir.
            var kod = tckn;
            var cakisma = await b.TekDegerAsync<int>(
                "select count(*) from public.taraf_kullanici "
                + "where lower(kod) = lower(@p0) and id <> @p1", null, [kod, tarafId], iptal);
            if (cakisma > 0) kod = $"h{tarafId}";

            var hash = BCrypt.Net.BCrypt.HashPassword(parola, workFactor: 12);
            var ip = (ctx.Connection.RemoteIpAddress?.ToString() ?? "").Trim();

            await using var islem = await b.BeginTransactionAsync(iptal);

            // HESAP YOKSA AÇILIR, VARSA (parolasız) PAROLASI KONUR.
            //   "Portal Erişimi" akışında hesap önceden açılıyor ve kişiye bu
            //   bağlantı gidiyor; aynı sayfa ikisinde de çalışmalı. Rol
            //   DEĞİŞTİRİLMEZ: dış hekime hasta rolü yazmak, yetkisini
            //   sessizce değiştirmek olurdu.
            var mevcut = await b.TekDegerAsync<int?>(
                "select id from public.taraf_kullanici where id = @p0", islem, [tarafId], iptal);
            if (mevcut is null)
                await b.CalistirAsync("""
                    insert into public.taraf_kullanici
                           (id, kod, parola_hash, parola_algo, parola_degismeli, parola_tarihi,
                            rol_id, aktif, ekleyen)
                    values (@p0, @p1, @p2, 'bcrypt', 0, now(), @p3, 1, 0)
                    """, islem, [tarafId, kod, hash, rolId], iptal);
            else
            {
                await b.CalistirAsync("""
                    update public.taraf_kullanici
                       set parola_hash = @p1, parola_algo = 'bcrypt', parola_degismeli = 0,
                           parola_tarihi = now(), aktif = 1
                     where id = @p0 and coalesce(parola_hash, '') = ''
                    """, islem, [tarafId, hash], iptal);
                kod = await b.TekDegerAsync<string>(
                    "select kod from public.taraf_kullanici where id = @p0",
                    islem, [tarafId], iptal) ?? kod;
            }

            var subeId = await b.TekDegerAsync<int?>(
                "select sube_id from public.portal_davet where id = @p0", islem, [davetId], iptal);
            await b.CalistirAsync("""
                insert into public.kullanici_sube (taraf_id, sube_id, varsayilan)
                values (@p0, coalesce(@p1, 1), 1)
                on conflict do nothing
                """, islem, [tarafId, subeId], iptal);

            // TEK KULLANIM: parola konduğu an davet kapanır.
            await b.CalistirAsync("""
                update public.portal_davet
                   set durum = 2, kullanim_zamani = now()::timestamp, kullanim_ip = @p1
                 where id = @p0
                """, islem, [davetId, ip], iptal);

            await islem.CommitAsync(iptal);

            return Results.Ok(new
            {
                tamam = true,
                kod,
                mesaj = "Hesabınız açıldı. Kullanıcı kodunuz: " + kod,
            });
        });
    }

    // ------------------------------------------------------------ yardımcı ----
    /// <summary>
    /// 32 baytlık rastgele jeton + SHA-256 özeti. URL'de güvenli karakterler
    /// (base64url): SMS'te kırpılan bir bağlantı çalışmaz.
    /// </summary>
    private static string Ozet(string jeton) => PortalDavetServisi.Ozet(jeton);

    /// <summary>Geçerli (açık + süresi dolmamış) daveti ve kişisini getirir.</summary>
    private static Task<IDictionary<string, object?>?> DavetBulAsync(
        Npgsql.NpgsqlConnection b, string jeton, CancellationToken iptal)
        => b.TekAsync("""
            select d.id, d.taraf_id as "tarafId", d.deneme,
                   coalesce(t.unvan, '') as unvan, coalesce(t.vkno, '') as tckn
              from public.portal_davet d
              join public.taraf t on t.id = d.taraf_id
             where d.jeton_ozet = @p0
               and d.durum = 1
               and d.gecerlilik >= now()::timestamp
            """, null, [Ozet((jeton ?? "").Trim())], OkuyucuGenisletmeleri.Sozluk, iptal);

}
