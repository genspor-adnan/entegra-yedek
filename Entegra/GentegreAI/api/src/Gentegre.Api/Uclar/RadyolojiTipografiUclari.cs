using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOJİ › AYARLAR › RAPOR TİPOGRAFİSİ (1344, mockup radyoloji_rapor_tipografi.html).
///
/// Kurum düzeyi tek ayar (referans 'radyoloji.tipografi', json). Genel /api/ayar ucu "ayar" yetkisi ister; bu
/// ekran radyoloji ayarıdır, radyoloji.tipografi ile okunur / değişir (haklar radyoloji.sablon'dan kopyalandı).
/// Kaydetmek şablon kaydına dokunmaz; etkisi görünümdedir ve onaylı raporlar damgalarıyla korunur
/// (RaporTipografisi.DamgalaAsync). Değişiklik alan alan loglanır; değişen yoksa log yok.
/// </summary>
public static class RadyolojiTipografiUclari
{
    private const int LogRadTipografi = 1784;

    public sealed record TipografiIstegi(string Font, decimal Punto, decimal Satir, int Paragraf, string Hiza, int Kenar,
                                         decimal BaslikPunto);

    public static void RadyolojiTipografiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/radyoloji/tipografi").WithTags("Radyoloji").RequireAuthorization();

        // GET: ayar + varsayılan + özgün (ekran karşılaştırma gösterir) + onaylı rapor sayısı (bilgi: damgalılar değişmez).
        grup.MapGet("/", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Rapor ekranı da okur: radyoloji Gör yeterli; ayar ekranı radyoloji.tipografi ister.
            if (!baglam.Yetkiler.Var("radyoloji.tipografi", Islem.Gor)) baglam.YetkiIste("radyoloji", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var ayar = await RaporTipografisi.KurumAsync(b, null, iptal);
            var damgali = await b.TekDegerAsync<long>(
                "select count(*) from public.radyoloji_rapor where tipografi is not null", null, [], iptal);
            // ESKİ HBYS (Word) ŞABLONLARI: toplu düğmenin sayaçları (kendi biçimi / kurum ayarı / özel).
            var eski = await b.TekAsync("""
                select count(*) filter (where tipografi_kaynak = 3)::int as kendi,
                       count(*) filter (where tipografi_kaynak = 1)::int as kurum,
                       count(*) filter (where tipografi_kaynak = 2)::int as ozel
                  from public.radyoloji_sablon where durum = 1 and aciklama like 'Eski HBYS şablonu%'
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new
            {
                ayar, varsayilan = RaporTipografisi.Varsayilan, ozgun = RaporTipografisi.Ozgun,
                fontlar = RaporTipografisi.Fontlar.Select(f => new { kod = f, ad = RaporTipografisi.FontAdi(f) }),
                damgaliRapor = damgali,
                eskiSablon = new { kendi = Convert.ToInt32(eski?["kendi"] ?? 0), kurum = Convert.ToInt32(eski?["kurum"] ?? 0),
                                   ozel = Convert.ToInt32(eski?["ozel"] ?? 0) },
                duzenle = baglam.Yetkiler.Var("radyoloji.tipografi", Islem.Degistir),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        grup.MapPut("/", async (TipografiIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.tipografi", Islem.Degistir);

            var font = (istek.Font ?? "").Trim().ToLowerInvariant();
            if (!RaporTipografisi.Fontlar.Contains(font))
                throw GentegreHatasi.Dogrulama("Font Arial, Calibri, Times New Roman, Segoe UI ya da Trebuchet MS olmalı.",
                    new AlanHatasi("font", "Geçersiz."));
            if (istek.Punto is < 9 or > 12)
                throw GentegreHatasi.Dogrulama("Punto 9-12 arasında olmalı (okunabilirlik / sayfa taşması).", new AlanHatasi("punto", "9-12"));
            if (istek.Satir is < 1.0m or > 2.0m)
                throw GentegreHatasi.Dogrulama("Satır aralığı 1,0-2,0 arasında olmalı.", new AlanHatasi("satir", "1,0-2,0"));
            if (istek.Paragraf is < 0 or > 12)
                throw GentegreHatasi.Dogrulama("Paragraf arası 0-12 pt olmalı.", new AlanHatasi("paragraf", "0-12"));
            if (istek.Hiza is not ("sol" or "iki"))
                throw GentegreHatasi.Dogrulama("Hizalama sol ya da iki yana olmalı.", new AlanHatasi("hiza", "sol | iki"));
            if (istek.Kenar is < 10 or > 25)
                throw GentegreHatasi.Dogrulama("Kenar boşluğu 10-25 mm olmalı.", new AlanHatasi("kenar", "10-25"));
            if (istek.BaslikPunto is < 11 or > 16)
                throw GentegreHatasi.Dogrulama("Rapor başlığı 11-16 pt olmalı.", new AlanHatasi("baslikPunto", "11-16"));

            var yeni = RaporTipografisi.Sinirla(new RaporTipografisi.Tipografi(
                font, istek.Punto, istek.Satir, istek.Paragraf, istek.Hiza, istek.Kenar, istek.BaslikPunto, "kurum"));

            await using var b = await veri.AcAsync(iptal);
            var eski = await RaporTipografisi.KurumAsync(b, null, iptal);
            var fark = new Dictionary<string, object>();
            void F(string ad, object e, object y) { if (!Equals(e, y)) fark[ad] = new { eski = e, yeni = y }; }
            F("font", eski.Font, yeni.Font); F("punto", eski.Punto, yeni.Punto); F("satir", eski.Satir, yeni.Satir);
            F("paragraf", eski.Paragraf, yeni.Paragraf); F("hiza", eski.Hiza, yeni.Hiza); F("kenar", eski.Kenar, yeni.Kenar);
            F("baslikPunto", eski.BaslikPunto, yeni.BaslikPunto);
            if (fark.Count > 0)
            {
                await using var tx = await b.BeginTransactionAsync(iptal);
                await b.CalistirAsync("""
                    insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
                    values ('radyoloji.tipografi', @p0, 'json', 'firma', @p1, now()::timestamp)
                    on conflict (anahtar) do update
                       set deger = excluded.deger, degistiren = excluded.degistiren,
                           degistirme_tarihi = excluded.degistirme_tarihi, guncelleme = now()::timestamp
                    """, tx, [RaporTipografisi.Json(yeni), baglam.KullaniciId], iptal);
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogRadTipografi, 0,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark, iptal: iptal);
                await tx.CommitAsync(iptal);
            }
            return Results.Ok(new { ayar = yeni, degisti = fark.Count, izlemeNo = baglam.IzlemeNo });
        });

        // TOPLU: eski HBYS (Word) şablonlarını kurum tipografisine uydur / kendi biçimine geri al (kullanıcı 14.11.2026:
        //   "toplu düğmeyi ekle"). Yalnız aciklama 'Eski HBYS şablonu%' olanlar; Özel (2) seçilmişlere dokunulmaz.
        //   Geri alınabilir: aynı uç 'kendi' ile tersine çevirir. Onaylı raporlar damgalı, etkilenmez.
        grup.MapPost("/eski-sablonlar", async (EskiSablonIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
                                               HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.tipografi", Islem.Degistir);
            var hedef = istek.Islem switch { "kurum" => 1, "kendi" => 3, _ => 0 };
            if (hedef == 0)
                throw GentegreHatasi.Dogrulama("İşlem kurum (kurum tipografisine uydur) ya da kendi (kendi biçimine döndür) olmalı.",
                    new AlanHatasi("islem", "kurum | kendi"));
            var kaynak = hedef == 1 ? 3 : 1;
            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);
            var idler = await b.ListeAsync("""
                update public.radyoloji_sablon
                   set tipografi_kaynak = @p0, degistiren = @p2, degistirme_tarihi = now()::timestamp
                 where durum = 1 and aciklama like 'Eski HBYS şablonu%' and tipografi_kaynak = @p1
                returning id
                """, tx, [hedef, kaynak, baglam.KullaniciId], o => o.GetInt32(0), iptal);
            if (idler.Count > 0)
                await log.YazAsync(b, tx, LogIslemi.Degistir, LogRadTipografi, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, object> { ["eskiSablonTipografi"] = new { islem = istek.Islem, adet = idler.Count, idler = idler.Take(50) } },
                    iptal: iptal);
            await tx.CommitAsync(iptal);
            return Results.Ok(new { adet = idler.Count, islem = istek.Islem, izlemeNo = baglam.IzlemeNo });
        });
    }

    public sealed record EskiSablonIstegi(string Islem);
}
