using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// EXCEL'DEN ICERI ALMA UCLARI (548) - Ayarlar › Veri Aktarımı › İçeri Alma.
/// Mockup: Ekranlar/Ayarlar/excel_iceri_alma.html
///
/// DOSYA SUNUCUDA TUTULMAZ: sihirbazin her adimi dosyayi yeniden gonderir.
/// Gecici dosya deposu tutmak (temizleme isi, yarim kalan yukleme, disk
/// dolmasi) kazandigi seyden pahali - dosya zaten kullanicinin diskinde.
///
/// Yetki: hepsinde `veri.iceri-al` aksiyonu + hedef kartin kendi yetkisi.
/// Jenerik kapi tek basina yazdirmaz; cari alamayan kullanici bu ekrandan da
/// cari yazamaz.
/// </summary>
public static class IceriAlmaUclari
{
    private sealed record KuralIstegi(string Ad, string Hedef, string BaslikImzasi,
                                      Dictionary<string, string> Esleme);

    public static void IceriAlmaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        // ----------------------------------------------------------- hedefler ----
        // Sihirbazin hedef combosu ve "Şablonlar" sekmesi: hangi hedefler var,
        //   her birinde hangi alanlar, hangisi zorunlu, cakisma anahtari ne.
        yol.MapGet("/api/iceri-alma/hedefler", async (
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var hedefler = IceriAlma.Hedefler
                // Kullanicinin YAZAMADIGI hedef listelenmez: secilince
                //   "yetkiniz yok" diyen bir secenek sunmanin anlami yok.
                .Where(h => baglam.Yetkiler.Var(IceriAlma.YetkiKodu(h), Islem.Ekle))
                .Select(h =>
                {
                    var alanlar = IceriAlma.HedefAlanlari(h);
                    var dizin = alanlar.ToDictionary(a => a.Ad, StringComparer.Ordinal);
                    return new
                    {
                        ad = h.Ad,
                        baslik = h.Baslik,
                        ikon = h.Ikon,
                        tur = h.Tur,
                        // Fiyat listesi hedefinde sihirbaz LISTE sorar (548).
                        listeGerekli = h.Tur == "fiyat-listesi",
                        anahtarlar = h.Anahtarlar
                            .Select(a => dizin.TryGetValue(a, out var al) ? al.Etiket : a)
                            .ToArray(),
                        alanlar = alanlar.Select(a => new
                        {
                            ad = a.Ad, baslik = a.Etiket, tip = a.Tip, zorunlu = a.Zorunlu,
                            anahtar = h.Anahtarlar.Contains(a.Ad, StringComparer.Ordinal),
                        }).ToArray(),
                    };
                }).ToArray();

            return Results.Ok(new { hedefler, izlemeNo = baglam.IzlemeNo });
        }).WithTags("IceriAlma").RequireAuthorization();

        // --------------------------------------------------------------- coz ----
        // Adim 1 -> 2: dosyayi oku, basliklari ve ornek degerleri don, esleme
        //   oner. Kayitli kural varsa (ayni baslik imzasi) esleme %100 gelir.
        yol.MapPost("/api/iceri-alma/coz", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var form = await ctx.Request.ReadFormAsync(iptal);
            var hedef = IceriAlma.HedefBul(form["hedef"].ToString());
            baglam.YetkiIste(IceriAlma.YetkiKodu(hedef), Islem.Ekle);

            var sayfa = FormdanOku(form, out var dosyaAdi);

            // Kayitli kural: dosyanin baslik imzasi tutuyorsa adim 2 atlanabilir.
            var imza = IceriAlma.BaslikImzasi(sayfa.Basliklar);
            Dictionary<string, string>? kuralEsleme = null;
            string? kuralAdi = null;
            int? kuralId = null;
            await using (var baglanti = await veri.AcAsync(iptal))
            {
                await using var komut = baglanti.Komut(
                    "select id, ad, esleme::text from public.iceri_alma_kurali "
                    + " where hedef = @p0 and baslik_imzasi = @p1 and aktif = 1 limit 1",
                    null, hedef.Ad, imza);
                await using var o = await komut.ExecuteReaderAsync(iptal);
                if (await o.ReadAsync(iptal))
                {
                    kuralId = o.GetInt32(0);
                    kuralAdi = o.GetString(1);
                    kuralEsleme = JsonSerializer.Deserialize<Dictionary<string, string>>(o.GetString(2));
                }
            }

            var esleme = IceriAlma.EslemeOner(IceriAlma.HedefAlanlari(hedef), sayfa,
                                              kuralEsleme);

            // Ornek satirlar: kullanici eslemeyi DEGERLERE bakarak dogrular.
            var ornekler = sayfa.Satirlar.Take(10).Select(s => new
            {
                satirNo = s.SatirNo,
                hucreler = sayfa.Basliklar.ToDictionary(
                    b => b,
                    b => s.Hucreler.TryGetValue(ExcelOkuma.BaslikAnahtari(b), out var v) ? v : ""),
            }).ToArray();

            return Results.Ok(new
            {
                dosyaAdi,
                basliklar = sayfa.Basliklar,
                satirSayisi = sayfa.Satirlar.Count,
                baslikImzasi = imza,
                kural = kuralId is null ? null : new { id = kuralId, ad = kuralAdi },
                esleme = esleme.Select(e => new
                {
                    kolon = e.Kolon, alan = e.Alan, guven = e.Guven, ornek = e.Ornek
                }).ToArray(),
                ornekler,
                izlemeNo = baglam.IzlemeNo,
            });
        }).WithTags("IceriAlma").RequireAuthorization();

        // ----------------------------------------------------------- onizle ----
        // Adim 3: HICBIR SEY YAZILMAZ. Her satir icin yeni/degisecek/sorunlu.
        yol.MapPost("/api/iceri-alma/onizle", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var form = await ctx.Request.ReadFormAsync(iptal);
            var hedef = IceriAlma.HedefBul(form["hedef"].ToString());
            baglam.YetkiIste(IceriAlma.YetkiKodu(hedef), Islem.Ekle);

            var sayfa = FormdanOku(form, out _);
            var esleme = EslemeCoz(form);
            var bicim = form["sayiBicimi"].ToString() is "en" ? "en" : "tr";

            var sonuc = await IceriAlma.OnizleAsync(veri, hedef, sayfa, esleme, bicim,
                                                    SayiAlani(form, "listeId"), iptal);

            return Results.Ok(new
            {
                sonuc.Toplam, sonuc.Yeni, sonuc.Degisecek, sonuc.Sorunlu,
                // Ekranda 200 satir yeter; sayimlar TUM dosyayi kapsar.
                satirlar = sonuc.Satirlar.Take(200).Select(s => new
                {
                    satirNo = s.SatirNo, durum = s.Durum, anahtar = s.Anahtar,
                    ozet = s.Ozet, not = s.Not,
                }).ToArray(),
                izlemeNo = baglam.IzlemeNo,
            });
        }).WithTags("IceriAlma").RequireAuthorization();

        // ----------------------------------------------------------- uygula ----
        yol.MapPost("/api/iceri-alma/uygula", async (
            BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, BelgeDeposu belgeDeposu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var form = await ctx.Request.ReadFormAsync(iptal);
            var hedef = IceriAlma.HedefBul(form["hedef"].ToString());
            // Guncelleme de yapiyor: iki yetki birden istenir.
            baglam.YetkiIste(IceriAlma.YetkiKodu(hedef), Islem.Ekle);
            baglam.YetkiIste(IceriAlma.YetkiKodu(hedef), Islem.Degistir);

            var sayfa = FormdanOku(form, out var dosyaAdi);
            var esleme = EslemeCoz(form);
            var bicim = form["sayiBicimi"].ToString() is "en" ? "en" : "tr";

            var sonuc = await IceriAlma.UygulaAsync(veri, log, belgeDeposu, hedef, sayfa,
                esleme, bicim, dosyaAdi, SayiAlani(form, "listeId"),
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, iptal);

            return Results.Ok(new
            {
                yuklemeNo = sonuc.YuklemeNo, sonuc.Eklenen, sonuc.Guncellenen,
                sonuc.Atlanan, sonuc.Toplam, sonuc.Mesaj, izlemeNo = baglam.IzlemeNo,
            });
        }).WithTags("IceriAlma").RequireAuthorization();

        // ----------------------------------------------------------- gecmis ----
        yol.MapGet("/api/iceri-alma/gecmis", async (
            int? limit, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var kayitlar = await veri.ListeAsync(
                "select y.id, y.hedef, y.dosya_adi, y.satir_sayisi, y.eklenen, y.guncellenen, "
                + "       y.atlanan, y.durum, y.mesaj, y.tarih, coalesce(k.kod, '') "
                + "  from public.iceri_alma y "
                + "  left join public.taraf_kullanici k on k.id = y.kullanici_id "
                + " order by y.id desc limit @p0",
                new object?[] { Math.Clamp(limit ?? 50, 1, 200) },
                r => new
                {
                    id = r.GetInt32(0), hedef = r.GetString(1), dosyaAdi = r.GetString(2),
                    satirSayisi = r.GetInt32(3), eklenen = r.GetInt32(4),
                    guncellenen = r.GetInt32(5), atlanan = r.GetInt32(6),
                    durum = r.GetInt16(7), mesaj = r.GetString(8),
                    tarih = r.GetDateTime(9), kullanici = r.GetString(10),
                }, iptal);

            return Results.Ok(new { kayitlar, izlemeNo = baglam.IzlemeNo });
        }).WithTags("IceriAlma").RequireAuthorization();

        // ---------------------------------------------------------- kurallar ----
        yol.MapGet("/api/iceri-alma/kurallar", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            var kurallar = await veri.ListeAsync(
                "select k.id, k.ad, k.hedef, k.baslik_imzasi, k.esleme::text, k.aktif, "
                + "       k.son_kullanim, k.tarih "
                + "  from public.iceri_alma_kurali k order by k.aktif desc, k.id desc",
                [],
                r => new
                {
                    id = r.GetInt32(0), ad = r.GetString(1), hedef = r.GetString(2),
                    // Imza kullaniciya "hangi basliklar" olarak gosterilir.
                    basliklar = r.GetString(3).Replace("|", " · "),
                    alanSayisi = (JsonSerializer.Deserialize<Dictionary<string, string>>(
                                      r.GetString(4)) ?? []).Count(e => e.Value.Length > 0),
                    aktif = r.GetInt16(5),
                    sonKullanim = r.IsDBNull(6) ? (DateTime?)null : r.GetDateTime(6),
                    tarih = r.GetDateTime(7),
                }, iptal);

            return Results.Ok(new { kurallar, izlemeNo = baglam.IzlemeNo });
        }).WithTags("IceriAlma").RequireAuthorization();

        // "Eşlemeyi Sakla": ayni imzada kural varsa UZERINE yazar - kullanici
        //   duzelttigi eslemeyi saklarken eskisini elle silmek zorunda kalmasin.
        yol.MapPost("/api/iceri-alma/kural", async (
            KuralIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");
            var hedef = IceriAlma.HedefBul(istek.Hedef);
            if (string.IsNullOrWhiteSpace(istek.Ad))
                throw GentegreHatasi.Dogrulama("Kurala bir ad verin.",
                    new AlanHatasi("ad", "Ad zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "insert into public.iceri_alma_kurali "
                + "       (ad, hedef, baslik_imzasi, esleme, kullanici_id, sube_id, son_kullanim) "
                + "values (@p0, @p1, @p2, @p3::jsonb, @p4, @p5, now()::timestamp) "
                + "on conflict (hedef, baslik_imzasi) where baslik_imzasi <> '' "
                + "do update set ad = excluded.ad, esleme = excluded.esleme, aktif = 1, "
                + "              son_kullanim = now()::timestamp "
                + "returning id",
                null, istek.Ad.Trim(), hedef.Ad, istek.BaslikImzasi ?? "",
                JsonSerializer.Serialize(istek.Esleme ?? []),
                baglam.KullaniciId, (object?)baglam.SubeId);
            var id = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));

            return Results.Ok(new { id, mesaj = $"\"{istek.Ad.Trim()}\" kuralı saklandı.",
                                    izlemeNo = baglam.IzlemeNo });
        }).WithTags("IceriAlma").RequireAuthorization();

        yol.MapDelete("/api/iceri-alma/kural/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "delete from public.iceri_alma_kurali where id = @p0", null, id);
            var silinen = await komut.ExecuteNonQueryAsync(iptal);
            return silinen == 0 ? Results.NotFound() : Results.Ok(new { id });
        }).WithTags("IceriAlma").RequireAuthorization();

        // ----------------------------------------------------------- sablon ----
        // Bos sablon: hedefin alanlari baslik satiri olarak. Zorunlu alanlar
        //   basliga " *" ile isaretlenmez - baslik metni eslesmede kullaniliyor.
        yol.MapGet("/api/iceri-alma/sablon", async (
            string hedef, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("veri.iceri-al");
            var h = IceriAlma.HedefBul(hedef);
            baglam.YetkiIste(IceriAlma.YetkiKodu(h), Islem.Gor);

            var basliklar = IceriAlma.HedefAlanlari(h)
                // Gizli alanlar (arka plan bayraklari) sablona girmez.
                .Where(a => !a.Gizli)
                .Select(a => a.Etiket).ToList();
            var icerik = ExcelOkuma.Yaz(h.Baslik, basliklar, []);
            return Results.File(icerik,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                $"{h.Baslik} Şablonu.xlsx");
        }).WithTags("IceriAlma").RequireAuthorization();
    }

    /// <summary>Formdaki dosyayi okur; boyut/uzanti kontrolu burada tek yerde.</summary>
    private static ExcelOkuma.Sayfa FormdanOku(IFormCollection form, out string dosyaAdi)
    {
        var dosya = form.Files.GetFile("dosya")
            ?? throw GentegreHatasi.Dogrulama("Dosya gönderilmedi.",
                   new AlanHatasi("dosya", "Bir .xlsx dosyası seçin."));
        if (dosya.Length > ExcelOkuma.AzamiBoyut)
            throw GentegreHatasi.Dogrulama(
                $"Dosya {ExcelOkuma.AzamiBoyut / 1024 / 1024} MB sınırını aşıyor.",
                new AlanHatasi("dosya", "Dosya çok büyük."));

        dosyaAdi = dosya.FileName;
        using var akis = dosya.OpenReadStream();
        return ExcelOkuma.Oku(akis);
    }

    /// <summary>Formdaki sayisal alan (fiyat listesi hedefinde listeId).</summary>
    private static int? SayiAlani(IFormCollection form, string ad)
        => int.TryParse(form[ad].ToString(), out var v) && v > 0 ? v : null;

    /// <summary>Esleme form alaninda JSON gelir: { "Excel başlığı": "alanAdi" }.</summary>
    private static Dictionary<string, string> EslemeCoz(IFormCollection form)
    {
        var ham = form["esleme"].ToString();
        if (string.IsNullOrWhiteSpace(ham))
            throw GentegreHatasi.Dogrulama("Eşleme gönderilmedi.",
                new AlanHatasi("esleme", "Kolon eşlemesi boş."));
        try
        {
            return JsonSerializer.Deserialize<Dictionary<string, string>>(ham) ?? [];
        }
        catch (JsonException)
        {
            throw GentegreHatasi.Dogrulama("Eşleme çözülemedi.",
                new AlanHatasi("esleme", "Geçersiz eşleme."));
        }
    }
}
