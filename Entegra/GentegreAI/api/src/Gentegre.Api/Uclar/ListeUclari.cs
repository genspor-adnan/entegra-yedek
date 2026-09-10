using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

public static class ListeUclari
{
    public static void ListeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/liste").WithTags("Liste").RequireAuthorization();

        // POST /api/liste/{kaynak}
        grup.MapPost("/{kaynak}", async (
            string kaynak, ListeIstegi istek, BaglamCozucu cozucu, ListeDeposu depo,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KaynakBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var kolonlar = GorunurKolonlar(tanim, baglam);
            if (kolonlar.Count == 0) throw GentegreHatasi.Yasak("Bu listede gorebileceginiz kolon yok.");

            var yanit = await depo.SorgulaAsync(tanim, istek ?? new ListeIstegi(), kolonlar,
                baglam.SubeId, baglam.Kapsam, baglam.IzlemeNo, baglam.KullaniciId, iptal);

            return Results.Ok(yanit);
        });

        // GET /api/liste/{kaynak}/kullanilan - metin anahtarlı katalogda
        //   kullanıcının SIK ve SON kullandıkları (461).
        //
        //   Poliklinikte tanı dağılımı dardır: ilk beş kod işin çoğunu görür.
        //   Arama penceresi boşken bunları göstermek, hem yazmayı kaldırır hem
        //   de aynı hastalığın hep AYNI kodla yazılmasını sağlar.
        grup.MapGet("/{kaynak}/kullanilan", async (
            string kaynak, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var tanim = KaynakKatalogu.Bul(kaynak) ?? throw GentegreHatasi.Bulunamadi();
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            // Ad ALANI kataloğun kendisinden okunur; kaynak beyaz listede
            //   (KaynakKatalogu) olduğu için tablo adı istekten GELMEZ.
            var sik = await veri.ListeAsync(
                "select k.kod, coalesce(i.ad, '') as ad, k.say " +
                "  from public.kullanici_katalog k " +
                "  left join public.icd i on i.kod = k.kod " +
                " where k.kullanici_id = @p0 and k.kaynak = @p1 " +
                " order by k.say desc, k.son_tarih desc limit 10",
                [baglam.KullaniciId, kaynak],
                o => new { kod = o.GetString(0), ad = o.GetString(1), say = o.GetInt32(2) },
                iptal);

            var son = await veri.ListeAsync(
                "select k.kod, coalesce(i.ad, '') as ad, k.son_tarih " +
                "  from public.kullanici_katalog k " +
                "  left join public.icd i on i.kod = k.kod " +
                " where k.kullanici_id = @p0 and k.kaynak = @p1 " +
                " order by k.son_tarih desc limit 10",
                [baglam.KullaniciId, kaynak],
                o => new { kod = o.GetString(0), ad = o.GetString(1),
                           tarih = o.GetDateTime(2) },
                iptal);

            return Results.Ok(new { kaynak, sik, son, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/liste/{kaynak}/kullanilan/{kod} - katalog kullanım sayacı
        //   Seçim ANINDA işaretlenir: kayıt kaydedilmese bile hekim o kodla
        //   çalışmıştır; sayacı kaydetmeye bağlamak sık kullanılanı geç ve
        //   eksik doldururdu.
        grup.MapPost("/{kaynak}/kullanilan/{kod}", async (
            string kaynak, string kod, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var tanim = KaynakKatalogu.Bul(kaynak) ?? throw GentegreHatasi.Bulunamadi();
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            await veri.CalistirAsync(
                "insert into public.kullanici_katalog (kullanici_id, kaynak, kod) " +
                "values (@p0, @p1, @p2) " +
                "on conflict (kullanici_id, kaynak, kod) " +
                "do update set say = public.kullanici_katalog.say + 1, son_tarih = now()",
                [baglam.KullaniciId, kaynak, kod], iptal);

            return Results.Ok(new { isaretlendi = true, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/liste/{kaynak}/kolonlar  - yetkisiz kolon bu listede de DONMEZ (§2.4)
        // POST /api/liste/{kaynak}/{id}/isaretle - "Son / Sik Aranan" sayaci
        //   Kart acilisi disinda da isaretlenmeli: kullanici bir stogu BELGE
        //   KALEMINDEN seciyorsa da o kayitla calismis olur; sayac buna kordu.
        grup.MapPost("/{kaynak}/{id:long}/isaretle", async (
            string kaynak, long id, BaglamCozucu cozucu, KullaniciAramaDeposu arama,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var tanim = KaynakKatalogu.Bul(kaynak) ?? throw GentegreHatasi.Bulunamadi();
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            await arama.IsaretleAsync(baglam.KullaniciId, kaynak, id, iptal);
            return Results.Ok(new { isaretlendi = true, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/{kaynak}/kolonlar", async (
            string kaynak, BaglamCozucu cozucu, KurumProfilDeposu profil,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var tanim = KaynakBul(kaynak);
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(tanim.YetkiKodu, Islem.Gor);

            var kolonlar = GorunurKolonlar(tanim, baglam,
                    await profil.UrunModuAsync(baglam.SubeId ?? 0, iptal))
                .Select(k => new KolonMeta(k.Ad, k.Baslik, k.Tip, k.Hizalama, k.Bicim,
                                           k.Varsayilan, k.Siralanabilir, k.Filtrelenebilir, k.Genislik,
                                           k.SadeceGrupToplami, k.Kodlar))
                .ToList();

            return Results.Ok(new { kaynak = tanim.Ad, kolonlar });
        });

        // GET /api/liste  - kullanicinin gorebilecegi kaynaklar
        grup.MapGet("/", async (BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kaynaklar = KaynakKatalogu.Tumu
                .Where(k => baglam.Yetkiler.Var(k.YetkiKodu, Islem.Gor))
                .Select(k => new { k.Ad, k.YetkiKodu })
                .ToList();
            return Results.Ok(new { kaynaklar });
        });
    }

    private static KaynakTanimi KaynakBul(string ad)
        => KaynakKatalogu.Bul(ad)
           ?? throw GentegreHatasi.Bulunamadi($"Bilinmeyen liste kaynagi: {ad}");

    /// <summary>
    /// Alan yetkisi (API §8): yetkisiz kolon yanit govdesinden CIKARILMAZ -
    /// sorguya hic girmez. Boylece deger ne SQL'e ne de log'a dusrer.
    /// </summary>
    /// <summary>
    /// Gorunur kolonlar: alan yetkisi + URUN MODU (542). Bu kurulumda anlamsiz
    /// kolon listeye HIC girmez - ERP'de "Tarife" kolonu her satirda ayni
    /// degeri gosteren olu bir sutundu.
    /// </summary>
    private static List<KolonTanimi> GorunurKolonlar(KaynakTanimi tanim,
        IstekBaglami baglam, int urunModu = 0)
        => tanim.Kolonlar
                .Where(k => UrunModlari.Uyar(k.UrunModu, urunModu)
                            && baglam.Yetkiler.AlanOkunur(tanim.Ad, k.AlanAdi))
                .ToList();
}
