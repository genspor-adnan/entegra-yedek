using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KLİNİK KATALOGLAR (400) — ICD-10 ve ilaç listesinin doldurulması.
///
/// İki kaynak vardır ve ikisi de gerçektir:
///   * SKRS senkronu (`/api/entegrasyon/{id}/skrs-senkron`) — ICD'yi oradan
///     çeker. Ama SKRS hesabı bir Faz 0 KAPISIDIR (başvuru/sözleşme işi) ve
///     kapanmadan katalog boş kalır.
///   * DOSYADAN YÜKLEME (burası) — bakanlığın/İTS'nin yayınladığı liste
///     CSV olarak yüklenir. İlaç barkod listesi zaten SKRS'de yoktur; ICD
///     için de kapı kapanana kadar tek yol budur.
///
/// Yükleme UPSERT'tir: var olan kod güncellenir, olmayan eklenir. Gelmeyen
/// kod PASİFE ÇEKİLMEZ — eksik bir dosya yüzünden binlerce tanının kaybolması,
/// ertesi gün "tanı bulunamıyor" olarak geri gelirdi.
/// </summary>
public static class KatalogUclari
{
    /// <summary>Yükleme isteği: ayraçlı metin (CSV/TSV) ve başlık satırı var mı.</summary>
    public sealed record YuklemeIstegi(string Icerik, string? Ayrac, bool? BaslikVar);

    public static void KatalogUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/katalog").WithTags("Katalog").RequireAuthorization();

        // GET /api/katalog/durum - hangi katalog ne zaman, kaç satırla doldu
        grup.MapGet("/durum", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Gor);

            var satirlar = await veri.ListeAsync("""
                select k.kod, k.ad, k.son_calisma as "sonCalisma", k.satir_sayisi as "satirSayisi",
                       k.sonuc, k.basarili,
                       case k.kod when 'icd'  then (select count(*) from public.icd)
                                  when 'ilac' then (select count(*) from public.ilac)
                                  else 0 end as "mevcutSatir"
                  from public.katalog_senkron k order by k.kod
                """, null, o => new
                {
                    kod = o.GetString(0), ad = o.GetString(1),
                    sonCalisma = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                    satirSayisi = o.GetInt32(3), sonuc = o.GetString(4),
                    basarili = o.GetInt16(5) == 1, mevcutSatir = o.GetInt64(6),
                }, iptal);

            return Results.Ok(new { satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/katalog/icd-yukle
        //   Sütunlar: kod ; ad ; ust_kod(ops) ; cinsiyet(ops 0/1/2)
        grup.MapPost("/icd-yukle", async (
            YuklemeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            int yazilan = 0, atlanan = 0;

            foreach (var s in Satirlar(istek))
            {
                var kod = Alan(s, 0);
                var ad = Alan(s, 1);
                if (kod.Length is 0 or > 12 || ad.Length == 0) { atlanan++; continue; }

                await baglanti.CalistirAsync("""
                    insert into public.icd (kod, ad, ust_kod, seviye, cinsiyet, aktif,
                                            kaynak_surum, guncelleme)
                    values (@p0, @p1, nullif(@p2, ''),
                            case when nullif(@p2, '') is null then 3 else 4 end,
                            coalesce(nullif(@p3, '')::smallint, 0), 1, 'dosya', now())
                    on conflict (kod) do update
                       set ad = excluded.ad,
                           ust_kod = coalesce(excluded.ust_kod, public.icd.ust_kod),
                           cinsiyet = excluded.cinsiyet,
                           aktif = 1, kaynak_surum = 'dosya', guncelleme = now()
                    """, null,
                    [kod, Kirp(ad, 300), Kirp(Alan(s, 2), 12), Alan(s, 3)], iptal);
                yazilan++;
            }

            await SenkronYazAsync(baglanti, "icd", "ICD-10 Tanı", yazilan,
                $"Dosyadan: {yazilan} kod yazıldı, {atlanan} satır atlandı.", iptal);

            return Results.Ok(new { yazilan, atlanan, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/katalog/ilac-yukle
        //   Sütunlar: barkod ; ad ; etken_madde(ops) ; atc(ops) ; firma(ops) ;
        //             recete_turu(ops 0-4) ; ambalaj(ops) ; aktif(ops 0/1)
        //   AKTİF sütunu ruhsatı ASKIDA ürünler için: katalogdan silmek yanlış
        //   olur (stokta kalmış olabilir, geçmiş reçetede geçer), pasif işaretlenir.
        grup.MapPost("/ilac-yukle", async (
            YuklemeIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            int yazilan = 0, atlanan = 0;

            foreach (var s in Satirlar(istek))
            {
                // BARKOD ANAHTARDIR: reçete ve sarf barkoddan okunur. Barkodsuz
                //   satır kataloğa girmez - sonradan eşleşemez.
                var barkod = new string(Alan(s, 0).Where(char.IsDigit).ToArray());
                var ad = Alan(s, 1);
                if (barkod.Length is < 8 or > 20 || ad.Length == 0) { atlanan++; continue; }

                await baglanti.CalistirAsync("""
                    insert into public.ilac (barkod, ad, etken_madde, atc_kod, firma,
                                             recete_turu, ambalaj, aktif, kaynak_surum, guncelleme)
                    values (@p0, @p1, @p2, @p3, @p4,
                            coalesce(nullif(@p5, '')::smallint, 0), @p6,
                            coalesce(nullif(@p7, '')::smallint, 1), 'dosya', now())
                    on conflict (barkod) do update
                       set ad = excluded.ad,
                           etken_madde = excluded.etken_madde,
                           atc_kod = excluded.atc_kod,
                           firma = excluded.firma,
                           recete_turu = excluded.recete_turu,
                           ambalaj = excluded.ambalaj,
                           aktif = excluded.aktif, kaynak_surum = 'dosya', guncelleme = now()
                    """, null,
                    // DOSYADAN GELEN DEGER KOLONU TASABILIR (TITCK listesinde
                    //   etken madde kombinasyonlari ve firma unvanlari uzun):
                    //   23 bin satirin biri yuzunden yukleme durmamali, deger
                    //   kolon sinirina KIRPILIR.
                    [barkod, Kirp(ad, 300), Kirp(Alan(s, 2), 300), Kirp(Alan(s, 3), 20),
                     Kirp(Alan(s, 4), 200), Alan(s, 5), Kirp(Alan(s, 6), 60), Alan(s, 7)],
                    iptal);
                yazilan++;
            }

            await SenkronYazAsync(baglanti, "ilac", "İlaç (barkod)", yazilan,
                $"Dosyadan: {yazilan} ilaç yazıldı, {atlanan} satır atlandı.", iptal);

            return Results.Ok(new { yazilan, atlanan, izlemeNo = baglam.IzlemeNo });
        });
        // POST /api/katalog/titck-guncelle
        //   TİTCK'nin haftalık yayınından EN GÜNCEL dosyayı bulur, indirir ve
        //   kataloğu tazeler - elle indirip CSV'ye çevirme adımı kalkar.
        grup.MapPost("/titck-guncelle", async (
            BaglamCozucu cozucu, Servisler.TitckIlacGuncelleme titck,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            var s = await titck.GuncelleAsync(iptal);
            return Results.Ok(new { s.Yazilan, s.Askida, s.Atlanan, s.Dosya, s.Tarih,
                                    izlemeNo = baglam.IzlemeNo });
        });
        // POST /api/katalog/recete-turu-guncelle
        //   SKRS e-Reçete listesinden reçete türü + temel ilaç işaretleri.
        grup.MapPost("/recete-turu-guncelle", async (
            BaglamCozucu cozucu, Servisler.TitckIlacGuncelleme titck,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            var s = await titck.ReceteTuruGuncelleAsync(iptal);
            return Results.Ok(new { s.Yazilan, s.Atlanan, s.Dosya, s.Tarih,
                                    izlemeNo = baglam.IzlemeNo });
        });
        // POST /api/katalog/sgk-ek4a-yukle
        //   Ek-4/A FIYAT VERMEZ, ISKONTO verir; kamu fiyati TITCK perakende
        //   fiyatindan bu iskontolar dusulerek bulunur. Adres duyurudan
        //   yapistirilir (SGK her duzenlemede yeni GUID'li adrese koyuyor).
        grup.MapPost("/sgk-ek4a-yukle", async (
            SgkIstegi istek, BaglamCozucu cozucu, Servisler.SgkIlacListesi sgk,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            byte[]? icerik = string.IsNullOrWhiteSpace(istek.Icerik)
                ? null : Convert.FromBase64String(istek.Icerik);
            DateOnly? yururluk = DateOnly.TryParse(istek.Yururluk, out var g) ? g : null;

            var s = await sgk.YukleAsync(istek.Adres, icerik, yururluk, iptal);
            return Results.Ok(new { s.Okunan, s.FiyatSatiri, s.IlacGuncellenen, s.Eslesmeyen,
                                    s.Yururluk, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/katalog/ilac/{id}/stok - ilaç kataloğundan STOK KARTI üretir
        //   İlaç kataloğu 23 bin satır; hepsine peşinen stok kartı açmak stok
        //   listesini kullanılamaz hale getirirdi. Kart İLK KULLANIMDA açılır
        //   ve ilac.stok_id ile bağlanır; ikinci kez basıldığında var olan
        //   kart döner (bu yüzden uç tekrarlanabilir).
        // POST /api/katalog/ilac/{id}/stok - ilac katalogundan STOK KARTI
        //   Kural ve SQL Servisler/IlacKartFiyat'te; burasi yalniz yetki
        //   kontrolu yapip cevabi bicimlendirir.
        grup.MapPost("/ilac/{id:int}/stok", async (
            int id, BaglamCozucu cozucu, Servisler.IlacKartFiyat ilaclar,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Ekle);

            var k = await ilaclar.StokKartiAsync(id, baglam.KullaniciId, baglam.SubeId, iptal);
            return k is null
                ? Results.NotFound(new { hata = new { kod = "BULUNAMADI",
                                                      mesaj = "Ilac bulunamadi." } })
                : Results.Ok(new { k.StokId, k.Barkod, k.Ad, k.Fiyat,
                                   izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/katalog/ilac/{id}/fiyat - ELLE FIYAT (kaynak 9)
        //   TITCK Detayli Fiyat Listesi kurumsal portal hesabi istiyor; o kapi
        //   acilana kadar ilac fiyatsiz kalir ve ilac cikisi fiyatsiz duser.
        grup.MapPost("/ilac/{id:int}/fiyat", async (
            int id, IlacFiyatIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.IlacKartFiyat ilaclar, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            if (istek.Perakende <= 0)
                throw GentegreHatasi.Dogrulama("Fiyat sifirdan buyuk olmali.",
                    [new("perakende", "Sifirdan buyuk bir tutar girin.")]);

            var barkod = await veri.TekDegerAsync<string>(
                "select barkod from public.ilac where id = @p0", [id], iptal);
            if (barkod is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Ilac bulunamadi." } });

            var gun = DateOnly.TryParse(istek.Yururluk, out var g)
                    ? g : DateOnly.FromDateTime(DateTime.Today);
            var s = await ilaclar.FiyatYazAsync(
                [new(barkod, istek.Perakende, istek.Kdv ?? 10m)],
                gun, "elle", baglam.KullaniciId, iptal);

            var stokId = await veri.TekDegerAsync<int?>(
                "select stok_id from public.ilac where id = @p0", [id], iptal);
            return Results.Ok(new { barkod, istek.Perakende, stokId,
                                    stokGuncellendi = s.StokGuncellenen > 0,
                                    yururluk = gun.ToString("dd.MM.yyyy"),
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/katalog/ilac-fiyat-yukle - TOPLU FIYAT (kaynak 9)
        //   Tek tek girmek 23 bin ilac icin bir yol degil. Sutunlar:
        //     barkod ; perakende [; kdv]
        grup.MapPost("/ilac-fiyat-yukle", async (
            YuklemeIstegi istek, BaglamCozucu cozucu, Servisler.IlacKartFiyat ilaclar,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("katalog", Islem.Degistir);

            var satirlar = new List<Servisler.IlacKartFiyat.FiyatSatiri>();
            foreach (var satir in Satirlar(istek))
            {
                var barkod = new string(Alan(satir, 0).Where(char.IsDigit).ToArray());
                var fiyat = IlacListeCozumleme.Ondalik(Alan(satir, 1));
                if (barkod.Length is < 8 or > 20 || fiyat <= 0) continue;
                var kdv = IlacListeCozumleme.Ondalik(Alan(satir, 2));
                satirlar.Add(new(barkod, fiyat, kdv > 0 ? kdv : 10m));
            }
            if (satirlar.Count == 0)
                throw GentegreHatasi.Dogrulama("Yuklenecek satir bulunamadi.",
                    [new("icerik", "Sutunlar: barkod ; fiyat ; kdv(ops).")]);

            var s = await ilaclar.FiyatYazAsync(satirlar,
                DateOnly.FromDateTime(DateTime.Today), "toplu", baglam.KullaniciId, iptal);
            return Results.Ok(new { s.Okunan, s.Yazilan, s.StokGuncellenen, s.Eslesmeyen,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Elle ilaç fiyatı: KDV dahil perakende satış fiyatı.</summary>
    public sealed record IlacFiyatIstegi(decimal Perakende, decimal? Kdv, string? Yururluk);

    /// <summary>Ek-4/A yükleme: duyurudaki adres ya da doğrudan dosya (base64).</summary>
    public sealed record SgkIstegi(string? Adres, string? Icerik, string? Yururluk);

    // ---------------------------------------------------------------- yardımcı
    /// <summary>
    /// Metni satır/sütuna böler. Ayraç verilmezse ilk satırdan ANLAŞILIR
    /// (`;` · sekme · `,`): bakanlık listeleri üçünü de kullanıyor, kullanıcıya
    /// "hangi ayraç" diye sormak gereksiz bir adım.
    /// </summary>
    private static IEnumerable<string[]> Satirlar(YuklemeIstegi istek)
    {
        var metin = istek.Icerik ?? "";
        var satirlar = metin.Split(['\n', '\r'], StringSplitOptions.RemoveEmptyEntries);
        if (satirlar.Length == 0) yield break;

        var ayrac = !string.IsNullOrEmpty(istek.Ayrac) ? istek.Ayrac[0]
                  : satirlar[0].Contains(';') ? ';'
                  : satirlar[0].Contains('\t') ? '\t' : ',';

        // Başlık satırı: açıkça söylenmişse ya da ilk hücre "kod"/"barkod" ise.
        var ilk = satirlar[0].Split(ayrac)[0].Trim().ToLowerInvariant();
        var baslikVar = istek.BaslikVar ?? (ilk is "kod" or "barkod" or "icd");

        foreach (var (satir, i) in satirlar.Select((x, i) => (x, i)))
        {
            if (i == 0 && baslikVar) continue;
            yield return satir.Split(ayrac);
        }
    }

    /// <summary>Kolon sinirina kirpar (dosya kaynagi kolon boyunu bilmez).</summary>
    private static string Kirp(string metin, int en)
        => string.IsNullOrEmpty(metin) || metin.Length <= en ? metin : metin[..en];

    private static string Alan(string[] satir, int sira)
        => sira < satir.Length ? satir[sira].Trim().Trim('"') : "";

    /// <summary>
    /// Katalog izleme satırını tazeler.
    ///
    /// `satir_sayisi` TABLODAN SAYILIR, "bu istekte yazılan" değil: büyük
    /// listeler parça parça yükleniyor (23 bin ilaç = 6 istek) ve son parçanın
    /// sayısını yazmak "3.053 ilaç" gibi yanıltıcı bir rakam bırakıyordu.
    /// </summary>
    private static Task SenkronYazAsync(Npgsql.NpgsqlConnection baglanti, string kod, string ad,
                                        int satir, string sonuc, CancellationToken iptal)
        => baglanti.CalistirAsync($"""
            insert into public.katalog_senkron (kod, ad, son_calisma, satir_sayisi, sonuc, basarili)
            values (@p0, @p1, now(),
                    (select count(*) from public.{(kod == "icd" ? "icd" : "ilac")}), @p3, 1)
            on conflict (kod) do update
               set son_calisma = now(), satir_sayisi = excluded.satir_sayisi,
                   sonuc = excluded.sonuc, basarili = 1
            """, null, [kod, ad, satir, sonuc], iptal);
}
