using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// NUMUNE ARŞİVİ (890 — KTS denetim maddesi L13).
///
/// <para>Arşiv iki soruya cevap verir: <b>tüp nerede</b> (ünite / raf / kutu /
/// göz) ve <b>ne zamana kadar duracak</b> (saklama politikası → imha hedefi).
/// Önceden yalnız serbest metin bir "saklama yeri" vardı; 600 tüplük bir
/// dondurucuda o metin tüpü bulmaya yetmiyordu.</para>
///
/// <para><b>Karar SQL'de:</b> yerleştirme ve çıkarma <c>fn_lab_arsiv_koy</c> /
/// <c>fn_lab_arsiv_cikar</c> ile yapılır - dolu göz, ızgara dışı göz ve
/// "zaten arşivde" kontrolleri orada. Uçlar yalnız barkodu id'ye çevirir ve
/// hatayı kullanıcının anlayacağı biçimde döndürür.</para>
///
/// <para><b>İMHAYI SİSTEM YAPMAZ.</b> Süresi dolan numune listelenir; kaydı
/// kapatan kullanıcıdır. Otomatik kapatmak, fiziksel olarak hâlâ dolapta
/// duran tüpü "imha edildi" göstermek olurdu - denetimde en kötü kayıt,
/// gerçeği yanlış anlatan kayıttır.</para>
/// </summary>
public static partial class LabUclari
{
    public sealed record ArsivKoyIstegi(string? Barkod, int? NumuneId, int KonumId, string Goz);
    public sealed record ArsivCikarIstegi(string? Barkod, int? NumuneId, short Neden, string? Not);
    public sealed record ArsivImhaIstegi(IReadOnlyList<int>? NumuneIdler, string? Not);

    private static void ArsivEkle(RouteGroupBuilder grup)
    {
        // GET /api/lab/arsiv/kutular - kutular ve doluluk.
        grup.MapGet("/arsiv/kutular", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Gor);

            var kutular = await veri.ListeAsync("""
                select konum_id as "konumId", kod, ad, yol, sicaklik, satir, sutun,
                       goz_sayisi as "gozSayisi", dolu, bos
                  from public.v_lab_arsiv_kutu
                 where aktif = 1 and (@p0 = 0 or sube_id = @p0)
                 order by yol
                """, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kutular, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/arsiv/kutu/{id} - ızgara + gözlerdeki tüpler.
        //   Ekran kutuyu çizip hangi gözün dolu olduğunu gösterir; aynı
        //   döküm yazdırılıp dolabın kapağına asılabilir (offline arşiv).
        grup.MapGet("/arsiv/kutu/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Gor);

            var kutu = await veri.TekAsync("""
                select konum_id as "konumId", kod, ad, yol, sicaklik, satir, sutun,
                       goz_sayisi as "gozSayisi", dolu, bos
                  from public.v_lab_arsiv_kutu where konum_id = @p0
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kutu bulunamadı.");

            var gozler = await veri.ListeAsync("""
                select goz, numune_id as "numuneId", barkod, hasta,
                       istem_no as "istemNo", giris_zamani as "girisZamani",
                       imha_hedef as "imhaHedef", kalan_gun as "kalanGun"
                  from public.v_lab_arsiv
                 where konum_id = @p0 and durum = 1
                 order by goz
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { kutu, gozler, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/arsiv/bul/{barkod} - "bu tüp nerede?"
        //   GEÇMİŞİ DE DÖNER: çıkarılmış/imha edilmiş kayıt da cevabın bir
        //   parçasıdır - "arşivde değil" ile "3 ay önce imha edildi" farklı
        //   iki cevaptır.
        grup.MapGet("/arsiv/bul/{barkod}", async (
            string barkod, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Gor);

            var numune = await veri.TekAsync("""
                select n.id, n.barkod, n.numune_tipi as "numuneTipi",
                       n.tup_tipi as "tupTipi", n.durum, i.istem_no as "istemNo",
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as hasta,
                       n.alim_zamani as "alimZamani",
                       public.fn_lab_arsiv_saklama_gun(n.id) as "saklamaGun"
                  from public.lab_numune n
                  join public.lab_istem i on i.id = n.istem_id
                  left join public.taraf h on h.id = n.hasta_id
                 where n.barkod = @p0
                """, [barkod.Trim()], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Bu barkodla numune bulunamadı.");

            var kayitlar = await veri.ListeAsync("""
                select id, konum_id as "konumId", konum, goz, sicaklik,
                       giris_zamani as "girisZamani", saklama_gun as "saklamaGun",
                       imha_hedef as "imhaHedef", kalan_gun as "kalanGun", durum,
                       cikis_zamani as "cikisZamani", cikis_neden as "cikisNeden",
                       not_metni as "notMetni"
                  from public.v_lab_arsiv
                 where barkod = @p0
                 order by giris_zamani desc
                """, [barkod.Trim()], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { numune, kayitlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/arsiv/koy - tüpü kutunun gözüne yerleştirir.
        grup.MapPost("/arsiv/koy", async (
            ArsivKoyIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Ekle);

            var numuneId = await NumuneCozAsync(veri, istek.NumuneId, istek.Barkod, iptal);
            var arsivId = await KuralCalistirAsync(() => veri.TekDegerAsync<int>(
                "select public.fn_lab_arsiv_koy(@p0, @p1, @p2, @p3)",
                [numuneId, istek.KonumId, istek.Goz ?? "", baglam.KullaniciId], iptal));

            var yer = await veri.TekDegerAsync<string>("""
                select konum || ' · ' || goz from public.v_lab_arsiv where id = @p0
                """, [arsivId], iptal) ?? "";

            return Results.Ok(new { arsivId, numuneId, mesaj = $"Arşive kondu: {yer}.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/arsiv/cikar - tekrar çalışma / dış lab / devir.
        //   İmha bu uçtan YAPILMAZ: ayrı yetki ister (aşağıda).
        grup.MapPost("/arsiv/cikar", async (
            ArsivCikarIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Degistir);

            if (istek.Neden == 3)
                throw GentegreHatasi.IsKurali(
                    "İmha ayrı bir işlemdir - imha listesinden yapılır.");

            var numuneId = await NumuneCozAsync(veri, istek.NumuneId, istek.Barkod, iptal);
            await KuralCalistirAsync(() => veri.TekDegerAsync<int>(
                "select public.fn_lab_arsiv_cikar(@p0, @p1, @p2, @p3)",
                [numuneId, istek.Neden, baglam.KullaniciId, istek.Not ?? ""], iptal));

            return Results.Ok(new { numuneId, mesaj = "Numune arşivden çıkarıldı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/arsiv/imha-bekleyen - saklama süresi dolanlar.
        grup.MapGet("/arsiv/imha-bekleyen", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.arsiv", Islem.Gor);

            var satirlar = await veri.ListeAsync("""
                select numune_id as "numuneId", barkod, hasta, istem_no as "istemNo",
                       konum, goz, giris_zamani as "girisZamani",
                       imha_hedef as "imhaHedef", kalan_gun as "kalanGun"
                  from public.v_lab_arsiv_imha_bekleyen
                 where (@p0 = 0 or sube_id = @p0)
                 order by imha_hedef, barkod
                """, [baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/arsiv/imha - seçilen tüpleri imha edildi olarak kapatır.
        //   AYRI YETKİ (`lab.arsiv.imha`): imha geri alınamaz; arşive tüp
        //   koyabilen herkesin imha edebilmesi, kaydı koruyan kuralı
        //   anlamsız kılardı.
        grup.MapPost("/arsiv/imha", async (
            ArsivImhaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("lab.arsiv.imha");

            var idler = istek.NumuneIdler ?? [];
            if (idler.Count == 0)
                throw GentegreHatasi.Dogrulama("İmha edilecek numune seçilmedi.",
                    [new("numuneIdler", "En az bir numune seçin.")]);

            var sayi = 0;
            var hatalar = new List<string>();
            foreach (var id in idler)
            {
                try
                {
                    await veri.TekDegerAsync<int>(
                        "select public.fn_lab_arsiv_cikar(@p0, 3::smallint, @p1, @p2)",
                        [id, baglam.KullaniciId, istek.Not ?? ""], iptal);
                    sayi++;
                }
                catch (Npgsql.PostgresException h)
                {
                    // TEK TÜP YÜZÜNDEN TOPLU İŞ DURMAZ: arada biri elle
                    //   çıkarılmış olabilir; hangisinin neden atlandığı
                    //   yanıtta söylenir.
                    hatalar.Add($"#{id}: {h.MessageText}");
                }
            }

            return Results.Ok(new { sayi, hatalar,
                mesaj = $"{sayi} numune imha edildi olarak kapatıldı."
                      + (hatalar.Count > 0 ? $" {hatalar.Count} tanesi atlandı." : ""),
                izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Barkod ya da id ile numuneyi bulur - ekran ikisini de gönderebilir.</summary>
    private static async Task<int> NumuneCozAsync(VeriKaynagi veri, int? numuneId,
                                                  string? barkod, CancellationToken iptal)
    {
        if (numuneId is > 0) return numuneId.Value;
        var b = (barkod ?? "").Trim();
        if (b.Length == 0)
            throw GentegreHatasi.Dogrulama("Numune barkodu gerekli.",
                [new("barkod", "Barkodu okutun ya da yazın.")]);

        return await veri.TekDegerAsync<int?>(
            "select id from public.lab_numune where barkod = @p0", [b], iptal)
            ?? throw GentegreHatasi.Bulunamadi($"{b} barkodlu numune bulunamadı.");
    }

    /// <summary>
    /// SQL'deki `raise exception` mesajını kullanıcıya olduğu gibi gösterir.
    ///
    /// Kurallar fonksiyonun içinde ("A5 gözü dolu", "Numune zaten arşivde");
    /// ham PostgresException'ı yukarı bırakmak kullanıcıya "Beklenmeyen bir
    /// hata" dedirtirdi - oysa söylenecek net bir cümle var.
    /// </summary>
    private static async Task<T> KuralCalistirAsync<T>(Func<Task<T>> is_)
    {
        try { return await is_(); }
        catch (Npgsql.PostgresException h) when (h.SqlState == "P0001")
        {
            throw GentegreHatasi.IsKurali(h.MessageText);
        }
    }
}
