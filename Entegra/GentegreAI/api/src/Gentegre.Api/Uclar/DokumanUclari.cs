using Gentegre.Api.AraKatman;
using Gentegre.Veri;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// Genel resim/doküman galerisi ucu - {kartAdi} kullanıcının bildiği kart adı ("personel",
/// "cari", "kisi", "stok"), hem yetki kontrolü hem fiziksel `dokuman.kaynak` değerine
/// çevirmek için kullanılır (cari/kisi/personel hepsi `taraf` satırı - tek fiziksel kaynak).
/// </summary>
// KaynakId/Yon/Varsayilan yalniz e-Belge XSLT sablonlarinda kullanilir (160);
// kart dokumanlarinda gonderilmez ve mevcut deger korunur.
public sealed record DuzenleIstegi(string Ad, string? BelgeTuru,
    int? KaynakId = null, short? Yon = null, bool? Varsayilan = null);

public static class DokumanUclari
{
    public static void DokumanUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dokuman/{kartAdi}/{kaynakId:long}").WithTags("Dokuman").RequireAuthorization();

        grup.MapGet("/", async (
            string kartAdi, long kaynakId, BaglamCozucu cozucu, DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!KendiKartiMi(kartAdi, kaynakId, baglam)) baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Gor);
            return Results.Ok(await depo.ListeleAsync(FizikselKaynak(kartAdi), kaynakId, iptal));
        });

        grup.MapPost("/", async (
            string kartAdi, long kaynakId, BaglamCozucu cozucu, DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!KendiKartiMi(kartAdi, kaynakId, baglam)) baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);

            var form = await ctx.Request.ReadFormAsync(iptal);
            var dosya = form.Files.GetFile("dosya")
                ?? throw GentegreHatasi.Dogrulama("Dosya gerekli.", new AlanHatasi("dosya", "Dosya seçilmedi."));
            var varsayilanIstendi = form["varsayilan"].ToString() == "true";
            // 160: gelen/giden ayrimi (e-Belge XSLT). Verilmezse 0 = uygulanmaz.
            _ = short.TryParse(form["yon"].ToString(), out var yon);

            using var akis = new MemoryStream();
            await dosya.CopyToAsync(akis, iptal);

            // Tarayici .xsl/.xslt icin cogunlukla bos ya da genel tip gonderir;
            //   XSLT kaynaginda tipi biz sabitliyoruz - beyaz listeye takilmasin.
            var tip = kartAdi == "ebelge-xslt" && (string.IsNullOrWhiteSpace(dosya.ContentType)
                        || dosya.ContentType == "application/octet-stream")
                      ? "application/xslt+xml" : dosya.ContentType;

            var liste = await depo.EkleAsync(FizikselKaynak(kartAdi), kaynakId, dosya.FileName,
                tip, akis.ToArray(), varsayilanIstendi,
                baglam.Yazma, iptal, yon);
            return Results.Ok(liste);
        });

        // dokumanId "/{kaynakId}" ile ilgisiz ama URL tutarliligi icin ust grup altinda -
        // gercek anahtar dokumanId, kaynakId sadece yol icin (kullanilmiyor).
        grup.MapPost("/{dokumanId:int}/varsayilan", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.VarsayilanYapAsync(dokumanId,
                baglam.Yazma, iptal);
            return Results.Ok(liste);
        });

        grup.MapPut("/{dokumanId:int}", async (
            string kartAdi, long kaynakId, int dokumanId, DuzenleIstegi istek, BaglamCozucu cozucu,
            DokumanDeposu depo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.DuzenleAsync(dokumanId, istek.Ad, istek.BelgeTuru,
                baglam.Yazma, iptal,
                istek.KaynakId, istek.Yon, istek.Varsayilan);
            return Results.Ok(liste);
        });

        grup.MapDelete("/{dokumanId:int}", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            if (!KendiKartiMi(kartAdi, kaynakId, baglam)) baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var liste = await depo.SilAsync(dokumanId,
                baglam.Yazma, iptal);
            return Results.Ok(liste);
        });

        grup.MapPost("/{dokumanId:int}/paylas", async (
            string kartAdi, long kaynakId, int dokumanId, BaglamCozucu cozucu, DokumanDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(YetkiKodu(kartAdi), Islem.Degistir);
            var kod = await depo.PaylasAsync(dokumanId,
                baglam.Yazma, iptal);
            return Results.Ok(new { kod });
        });
    }

    // İçerik indirme ayrı bir uc - RequireAuthorization standart Bearer header ister; <img
    // src=...> bunu gönderemediği için frontend içeriği fetch+Authorization ile çekip blob
    // URL'e çevirir (istemci.ts dokumanIcerik) - token URL'de/query string'de TAŞINMAZ.
    public static void DokumanIcerikUcunuEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/dokuman-icerik/{dokumanId:int}", async (
            int dokumanId, DokumanDeposu depo, CancellationToken iptal) =>
        {
            var icerik = await depo.IcerikAsync(dokumanId, iptal);
            return icerik is null
                ? Results.NotFound()
                : Results.File(icerik.Veri, icerik.ContentType, icerik.Ad);
        }).RequireAuthorization();

        // Kimliksiz paylaşım ucu - tahmin edilemez kod (128 bit) TEK erişim
        // kontrolü. Auth YOK: linki bilen görüntüler.
        //
        // 424 ile link artık SINIRLI olabiliyor (süre, açılma kotası, iptal).
        // Kural BURADA uygulanır ve AÇILMA SAYILIR: sınırları yalnız üretim
        // anında yazıp okuma anında bakmamak, iptal edilmiş bir linki sonsuza
        // kadar çalışır bırakırdı.
        yol.MapGet("/api/dokuman-paylasim/{kod}", async (
            string kod, DokumanDeposu depo, VeriKaynagi veri, CancellationToken iptal) =>
        {
            // Yeni tabloda kayıtlıysa sınırlar uygulanır; kayıtlı değilse eski
            //   davranış (dokuman.paylasim_kodu) sürer - taşınmamış kod da
            //   çalışmaya devam etsin.
            var p = await veri.TekAsync("""
                select v.id, v.durum, v.dokuman_id
                  from public.v_dokuman_paylasim v where v.kod = @p0
                """, [kod],
                o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1),
                           DokumanId = o.GetInt32(2) }, iptal);

            if (p is not null && p.Durum != 1) return Results.NotFound();

            // ICERIK IKI YOLDAN COZULUR: yeni tabloda kayitli link dokuman
            //   kimligini tasidigi icin dogrudan okunur; eski tek kodlu
            //   paylasim (dokuman.paylasim_kodu) icin eski yol surer. Yalniz
            //   eski yola bakmak, 424 ile uretilen her linki 404 yapardi.
            var icerik = p is not null
                ? await depo.IcerikAsync(p.DokumanId, iptal)
                : await depo.IcerikPaylasimKoduIleAsync(kod, iptal);
            if (icerik is null) return Results.NotFound();

            if (p is not null)
            {
                await veri.CalistirAsync("""
                    update public.dokuman_paylasim
                       set acilma_sayisi = acilma_sayisi + 1 where id = @p0
                    """, [p.Id], iptal);
                // KVKK: link açılması da erişimdir, günlüğe yazılır (kanal 3).
                await veri.CalistirAsync("""
                    insert into public.dokuman_olay (dokuman_id, olay, kanal, gerekce)
                    values (@p0, 12, 3, 'Paylasim linki acildi')
                    """, [p.DokumanId], iptal);
            }

            return Results.File(icerik.Veri, icerik.ContentType, icerik.Ad);
        });
    }

    private static string FizikselKaynak(string kartAdi) => kartAdi switch
    {
        "cari" or "kisi" or "personel" or "hasta" => "taraf",
        "stok" => "stok",
        // e-Belge XSLT sablonlari (160): kart degil ama ayni depoyu kullanir.
        "ebelge-xslt" => "ebelge-xslt",
        // Firma gorselleri (193): logo / kase / imza; belge_turu hangisi
        //   oldugunu tasir, kaynak_id sube kimligidir.
        "sube" => "sube",
        // Radyoloji istem kagidi (310) - kaynak_id istem kimligidir.
        "radyoloji-istem" => "radyoloji-istem",
        // Muayene DOSYALARI (mockup muayene_karti.html "Dosyalar"): disaridan
        //   gelen tetkik, epikriz, ragit... kaynak_id muayene kimligidir.
        "muayene" => "muayene",
        // KURUMSAL KLASOR (419): kaynagi bir KART OLMAYAN dokuman. Prosedur,
        //   talimat, sozlesme sablonu... kaynak_id klasor kimligidir. Bu
        //   olmadan kurumsal dokuman yuklenemiyordu - her dokumanin bir karta
        //   asilmasi gerekiyordu.
        "klasor" => "klasor",
        _ => throw new InvalidOperationException($"Bilinmeyen kart: {kartAdi}"),
    };

    /// <summary>
    /// PROFİL FOTOĞRAFI (kullanıcı ayarları): kişi KENDİ personel kartının
    /// resmini personel yetkisi olmadan görür/yükler/siler. Kullanıcı kimliği
    /// personel kartı kimliğidir (taraf_kullanici.id = taraf.id); başkasının
    /// kartı için yine kart yetkisi aranır.
    /// </summary>
    private static bool KendiKartiMi(string kartAdi, long kaynakId, IstekBaglami baglam)
        => kartAdi == "personel" && kaynakId == baglam.KullaniciId;

    // Kisi kendi yetki kodu yok, cari'yi kullanir (bkz. KisiUclari.cs).
    private static string YetkiKodu(string kartAdi) => kartAdi switch
    {
        "kisi" => "cari",
        "hasta" => "personel",
        "ebelge-xslt" => "ebelge_xslt",
        "radyoloji-istem" => "radyoloji",
        "muayene" => "muayene",
        // Kurumsal klasore yukleme DOKUMAN yetkisiyle (kaynak kart yok).
        "klasor" => "dokuman",
        _ => kartAdi
    };

}
