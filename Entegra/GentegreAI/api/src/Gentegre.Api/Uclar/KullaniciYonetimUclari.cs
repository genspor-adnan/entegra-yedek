using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KULLANICI YÖNETİMİ (Yönetim › Güvenlik › Kullanıcılar) — mockup
/// `Ekranlar/Ayarlar/kullanicilar.html`.
///
/// <para>Hesap yönetimi üç yere dağılmıştı (personel kartı, rol kartının
/// Kullanıcılar sekmesi, Giriş Kayıtları). Bu uçlar listenin satır
/// eylemleridir; <b>yeni bir yetki mekanizması getirmezler</b> - yetki hâlâ
/// ROLDE durur.</para>
///
/// <para><b>Yönetici parola YAZMAZ.</b> Sıfırlama hesabı parolasız duruma alır;
/// kişi ilk girişte kimliğini doğrulayıp kendi parolasını koyar. Yöneticinin
/// belirlediği parola, kâğıda yazılan ya da telefonda söylenen paroladır -
/// kimin elinde kaldığı bilinmez.</para>
///
/// <para>Hepsi `kullanici` yetkisi + Değiştir ister ve ISLEMLOG'a yazılır.</para>
/// </summary>
public static class KullaniciYonetimUclari
{
    /// <summary>Kullanici kart tablosu (islem_log) - rol karti 903, kullanici 902.</summary>
    private const int LogTabloKullanici = 902;

    public static void KullaniciYonetimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kullanici").WithTags("Kullanıcı")
                      .RequireAuthorization();

        // ------------------------------------------------- parola sıfırla ----
        // Hesap PAROLASIZ duruma döner + bütün oturumları kapanır. İki iş
        //   birlikte yapılır: parolası sıfırlanan hesabın açık oturumu kalırsa
        //   sıfırlama hiçbir şeyi korumamış olur.
        grup.MapPost("/{id:int}/parola-sifirla", async (
            int id, bool? kilitCoz, VeriKaynagi veri, OturumDeposu oturumlar,
            LogDeposu log, YetkiCozucu yetkiCozucu, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Degistir);

            var kod = await veri.TekDegerAsync<string>(
                "select kod from public.taraf_kullanici where id = @p0",
                new object?[] { id }, iptal);
            if (string.IsNullOrEmpty(kod)) return Results.NotFound();

            await veri.CalistirAsync("""
                update public.taraf_kullanici
                   set parola_hash = '', parola_degismeli = 1,
                       hatali_giris = 0,
                       kilit_bitis = case when @p1 then null else kilit_bitis end,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, new object?[] { id, kilitCoz != false, baglam.KullaniciId }, iptal);

            await oturumlar.KullaniciOturumlariniKapatAsync(id, "parola_sifirlandi", iptal);
            yetkiCozucu.Temizle(id);

            await log.YazAsync(LogIslemi.Degistir, LogTabloKullanici, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["islem"] = "Parola sıfırlandı",
                    ["kullanici"] = kod,
                }, iptal: iptal);

            return Results.Ok(new
            {
                mesaj = $"{kod}: parola sıfırlandı, oturumlar kapatıldı. "
                      + "Kişi ilk girişte kendi parolasını belirleyecek.",
            });
        });

        // ------------------------------------------------------ kilidi çöz ----
        // Hatalı giriş kilidi PAROLA SORUNU DEĞİLDİR: parolayı bilen ama üç kez
        //   yanlış yazan kişiye parola sıfırlatmak gereksiz bir tur attırır.
        grup.MapPost("/{id:int}/kilit-coz", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Degistir);

            var etkilenen = await veri.TekDegerAsync<int>("""
                with g as (
                    update public.taraf_kullanici
                       set kilit_bitis = null, hatali_giris = 0,
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    returning 1
                )
                select count(*)::int from g
                """, new object?[] { id, baglam.KullaniciId }, iptal);
            if (etkilenen == 0) return Results.NotFound();

            await log.YazAsync(LogIslemi.Degistir, LogTabloKullanici, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["islem"] = "Hesap kilidi çözüldü" },
                iptal: iptal);

            return Results.Ok(new { mesaj = "Kilit çözüldü, hatalı giriş sayacı sıfırlandı." });
        });

        // ------------------------------------------------ oturumları kapat ----
        // İşten ayrılan ya da cihazını kaybeden kişi: parolası DEĞİŞMEDEN
        //   oturumları kapatılabilmeli (parola sıfırlamak kişiyi de kilitler).
        grup.MapPost("/{id:int}/oturum-kapat", async (
            int id, OturumDeposu oturumlar, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Degistir);

            await oturumlar.KullaniciOturumlariniKapatAsync(id, "yonetici", iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloKullanici, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string> { ["islem"] = "Oturumlar kapatıldı" },
                iptal: iptal);

            return Results.Ok(new { mesaj = "Kullanıcının tüm oturumları kapatıldı." });
        });

        // ------------------------------------------------------ aktif/pasif ----
        // HESAP SİLİNMEZ: işlem günlüğü, belge ve log satırları kullanıcıya
        //   bağlı - silinen hesap geçmişi sahipsiz bırakır. Pasif hesap giriş
        //   yapamaz ve açık oturumları kapanır.
        grup.MapPost("/{id:int}/durum", async (
            int id, bool aktif, VeriKaynagi veri, OturumDeposu oturumlar,
            LogDeposu log, YetkiCozucu yetkiCozucu, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Degistir);

            // KENDİNİ PASİFE ALMA: yönetici kendi hesabını kapatırsa sistemde
            //   yetkili kimse kalmayabilir ve geri açacak kişi de yoktur.
            if (id == baglam.KullaniciId && !aktif)
                throw GentegreHatasi.IsKurali("Kendi hesabınızı pasife alamazsınız.");

            var etkilenen = await veri.TekDegerAsync<int>("""
                with g as (
                    update public.taraf_kullanici
                       set aktif = @p1, degistiren = @p2, degistirme_tarihi = now()
                     where id = @p0
                    returning 1
                )
                select count(*)::int from g
                """, new object?[] { id, (short)(aktif ? 1 : 0), baglam.KullaniciId }, iptal);
            if (etkilenen == 0) return Results.NotFound();

            if (!aktif) await oturumlar.KullaniciOturumlariniKapatAsync(id, "pasif", iptal);
            yetkiCozucu.Temizle(id);

            await log.YazAsync(LogIslemi.Degistir, LogTabloKullanici, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["islem"] = aktif ? "Hesap aktifleştirildi" : "Hesap pasife alındı",
                }, iptal: iptal);

            return Results.Ok(new
            {
                mesaj = aktif ? "Hesap aktif." : "Hesap pasife alındı, oturumları kapatıldı.",
            });
        });

        // ----------------------------------- kullanicinin oturumlari (kart) ----
        // Kisinin KENDI oturum listesi /api/kimlik/oturumlar'da; bu, YONETICININ
        //   baskasinin cihazlarini gormesi. Ayni depo, ayri yetki: `kullanici`.
        grup.MapGet("/{id:int}/oturumlar", async (
            int id, OturumDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);
            var liste = await depo.AcikListeAsync(id, iptal);
            return Results.Ok(liste.Select(o => new
            {
                id = o.Id, ip = o.Ip, istemci = o.Istemci,
                olusma = o.OlusmaTarihi, sonKullanim = o.SonKullanim,
                bitis = o.BitisTarihi, sube = o.SubeAdi, buCihaz = false,
            }));
        });

        grup.MapGet("/{id:int}/giris-gecmisi", async (
            int id, KullaniciDeposu depo, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);
            var liste = await depo.GirisGecmisiAsync(id, 10, iptal);
            return Results.Ok(liste.Select(g => new
            {
                tarih = g.Tarih, basarili = g.Basarili, sebep = g.Sebep,
                ip = g.Ip, istemci = g.Istemci,
            }));
        });

        // --------------------------------------------- hesabin islem gunlugu ----
        // Listenin ALT PANELINDEKI "Islem Gunlugu" sekmesi (mockup). Genel
        //   islem-log ekrani da ayni satirlari gosterir; buradaki fark SORUNUN
        //   dar olmasi: "bu hesaba ne yapildi" - parola sifirlandi mi, kim
        //   pasife aldi. Genel ekrana gidip tablo/kayit suzmek ayni isi uc
        //   tiklamada yaptirirdi.
        //
        // TABLO 902 (kullanici karti) SABIT: kisinin KENDI yaptigi islemler
        //   degil, HESABINA yapilanlar sorulur.
        grup.MapGet("/{id:int}/islem-gunlugu", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);

            var satirlar = await veri.ListeAsync("""
                select l.tarih, l.islem_tipi, coalesce(k.unvan, '') as kullanici,
                       coalesce(l.ip, '') as ip, coalesce(l.bilgi->>'islem', '') as islem
                  from public.islem_log l
                  left join public.taraf k on k.id = l.kullanici_id
                 where l.tablo_id = @p1 and l.kayit_id = @p0
                 order by l.tarih desc, l.id desc
                 limit 20
                """, new object?[] { id, LogTabloKullanici }, r => new
            {
                tarih = r.GetDateTime(0),
                islemTipi = (int)r.GetInt16(1),
                kullanici = r.GetString(2),
                ip = r.GetString(3),
                islem = r.GetString(4),
            }, iptal);

            return Results.Ok(satirlar);
        });

        // -------------------------------------------------- ozet sayaclari ----
        // GRIDIN USTUNDEKI KUTULAR (mockup `.ozet`): sus degil, GIRIS KAPISI -
        //   her kutu bir cipin karsiligi ve tiklaninca listeyi o suzgecle acar.
        //   "Kac hesap var" listede zaten yaziyor; buradaki sayilar "bugun neye
        //   bakmam gerek" sorusunun cevabi (parolasiz, kilitli, unutulmus hesap).
        //
        // TEK SORGU: alti ayri istek hem yavas hem de seridin yarisini bos
        //   gosterirdi (lab ozet seridinde ayni karar).
        grup.MapGet("/ozet", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);

            var o = await veri.TekAsync("""
                select
                  (select count(*) from public.taraf_kullanici)::int                     as toplam,
                  (select count(*) from public.taraf_kullanici where aktif = 1)::int     as aktif,
                  (select count(*) from public.taraf_kullanici where aktif = 0)::int     as pasif,
                  -- PAROLASIZ: hic parola konmamis YA DA varsayilan bayragi acik.
                  --   Ikisi de "bu hesaba kim girerse girsin" demektir.
                  (select count(*) from public.taraf_kullanici
                    where coalesce(parola_hash, '') = '' or parola_degismeli = 1)::int   as parolasiz,
                  (select count(*) from public.taraf_kullanici
                    where kilit_bitis is not null and kilit_bitis > now())::int          as kilitli,
                  -- UNUTULMUS HESAP: hic girmemis olan da sayilir - acilip
                  --   kullanilmayan hesap, kilitli hesaptan daha sessiz bir risk.
                  (select count(*) from public.taraf_kullanici
                    where aktif = 1
                      and (son_giris_tarihi is null
                           or son_giris_tarihi < now() - interval '90 days'))::int       as uykuda,
                  (select count(*) from public.taraf
                    where personel = 1 and durum = 1)::int                               as personel,
                  (select count(*) from public.taraf t
                    where t.personel = 1 and t.durum = 1
                      and not exists (select 1 from public.taraf_kullanici k
                                       where k.id = t.id))::int                          as hesapsiz,
                  -- OTURUM AILE basina sayilir: rotation her yenilemede yeni satir
                  --   acar, ham sayim anlamsiz buyuk bir sayi verirdi.
                  (select count(distinct o.aile_id) from public.oturum o
                    where o.iptal_tarihi is null and o.bitis_tarihi > now())::int        as oturum,
                  (select count(distinct o.kullanici_id) from public.oturum o
                    where o.iptal_tarihi is null and o.bitis_tarihi > now())::int        as oturumKisi
                """, null, r => new
            {
                toplam = r.GetInt32(0), aktif = r.GetInt32(1), pasif = r.GetInt32(2),
                parolasiz = r.GetInt32(3), kilitli = r.GetInt32(4), uykuda = r.GetInt32(5),
                personel = r.GetInt32(6), hesapsiz = r.GetInt32(7),
                oturum = r.GetInt32(8), oturumKisi = r.GetInt32(9),
            }, iptal);

            return Results.Ok(o);
        });

        // -------------------------------------------- personelden toplu aç ----
        // 93 aktif personelin 5'inin hesabı yoktu ve bu, kişi giriş yapamayınca
        //   fark ediliyordu. Hesap PAROLASIZ açılır (KullaniciDeposu).
        grup.MapPost("/toplu-ac", async (
            KullaniciDeposu depo, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Ekle);

            var acilan = await depo.OtomatikHesapAcAsync(null, iptal);
            if (acilan > 0)
                await log.YazAsync(LogIslemi.Ekle, LogTabloKullanici, 0,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["islem"] = "Personelden toplu hesap açıldı",
                        ["adet"] = acilan.ToString(),
                    }, iptal: iptal);

            return Results.Ok(new
            {
                acilan,
                mesaj = acilan == 0
                    ? "Hesabı olmayan aktif personel yok."
                    : $"{acilan} hesap açıldı. Kişiler ilk girişte kendi parolalarını belirleyecek.",
            });
        });
    }
}
