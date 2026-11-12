using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TELERADYOLOJİ (BAKANLIK) ŞUBE ÖZETİ (1317; mockup Ekranlar/Ayarlar/entegrasyon_teletip.html §3-§4). Ayar ekranı artık
/// düzenleme değil özet: her şubenin Bakanlık kimliği (1321: ANA kaynak e-Nabız hesabı), gönderim hesabı (Entegrasyon ›
/// TELERADYOLOJI; şube satırı → kurum geneli) ve kanal adresleri. Kimlik çakışmaları (1317 geçişinde iki yerde FARKLI
/// bulunan kodlar) burada seçilerek çözülür. Kart sekmesi için kimlik + Mirth hesapları da buradan.
/// </summary>
public static class TeleradyolojiSubeUclari
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };

    public sealed record CakismaCozIstegi(string Secim);   // "profil" | "eski"
    private sealed record CakismaSatiri(int Sube, string Alan, string Eski, string Profil);

    public static void TeleradyolojiSubeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/teletip").WithTags("TeleRadyoloji şubeler");

        grup.MapGet("/subeler", async (VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            PanoYetkisi(baglam);
            await using var b = await veri.AcAsync(iptal);
            var subeler = await b.ListeAsync("""
                select s.id, s.ad,
                       k.ad as kimlik_ad, k.skrs, k.tesis, k.kaynak, k.enabiz_hesap_id,
                       public.fn_teletip_hesap_ayar(s.id)::text as hesap
                  from public.sube s
                  cross join lateral public.fn_kurum_kimlik(s.id) k
                 where s.aktif = 1
                 order by s.id
                """, null, [], o => new
            {
                subeId = o.GetInt32(0), subeAdi = o.GetString(1),
                kimlik = new { ad = o.GetString(2), skrs = o.GetString(3), tesis = o.GetString(4), kaynak = o.GetString(5),
                               enabizHesapId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6) },
                hesap = TeleRadyolojiHesabi.Coz(o.IsDBNull(7) ? null : o.GetString(7)),
            }, iptal);
            var cakismalar = await b.ListeAsync("""
                select c.id, c.sube_id, coalesce(s.ad, 'Kurum geneli'), c.alan, c.profil_degeri, c.eski_kaynak, c.eski_deger, c.ekleme_tarihi
                  from public.kurum_kimlik_cakisma c left join public.sube s on s.id = c.sube_id
                 where c.cozuldu = 0 order by c.id
                """, null, [], o => new
            {
                id = o.GetInt32(0), subeId = o.GetInt32(1), subeAdi = o.GetString(2), alan = o.GetString(3),
                profilDegeri = o.GetString(4), eskiKaynak = o.GetString(5), eskiDeger = o.GetString(6), zaman = o.GetDateTime(7),
            }, iptal);
            var m = await mirth.OzetAsync(iptal);
            return Results.Ok(new
            {
                subeler, cakismalar,
                mirth = new { url = m.Url, kullanici = m.Kullanici, parolaTanimli = m.ParolaTanimli, kaynak = m.Kaynak },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // Kanal adreslerine TCP (mesaj göndermez - Mirth HTTP dinleyicisine GET atmak kanalda mesaj açardı).
        grup.MapPost("/subeler/sina", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            PanoYetkisi(baglam);
            await using var b = await veri.AcAsync(iptal);
            var hesaplar = await b.ListeAsync("""
                select s.id, public.fn_teletip_hesap_ayar(s.id)::text from public.sube s where s.aktif = 1 order by s.id
                """, null, [], o => (Sube: o.GetInt32(0), Json: o.IsDBNull(1) ? null : o.GetString(1)), iptal);
            // Aynı adres bir kez denenir; bütün denemeler paralel (ölü adres başına 5 sn sırayla beklenmez).
            var denemeler = new Dictionary<(string, bool), Task<KanalSonucu>>();
            Task<KanalSonucu> Dene(string adres, bool http) =>
                denemeler.TryGetValue((adres, http), out var g) ? g : denemeler[(adres, http)] = KanalDeneAsync(adres, http, iptal);
            var bekleyen = hesaplar.Select(x => (x.Sube, H: TeleRadyolojiHesabi.Coz(x.Json)))
                .Select(x => (x.Sube, Kanallar: x.H is null ? null
                    : new[] { Dene(x.H.Hl7Adres, false), Dene(x.H.XdsAdres, true), Dene(x.H.DozAdres, true) })).ToList();
            await Task.WhenAll(denemeler.Values);
            var liste = bekleyen.Select(x => x.Kanallar is null
                ? new { subeId = x.Sube, k1 = (KanalSonucu?)null, k2 = (KanalSonucu?)null, k3 = (KanalSonucu?)null }
                : new { subeId = x.Sube, k1 = (KanalSonucu?)x.Kanallar[0].Result, k2 = (KanalSonucu?)x.Kanallar[1].Result, k3 = (KanalSonucu?)x.Kanallar[2].Result });
            return Results.Ok(new { sonuclar = liste, izlemeNo = baglam.IzlemeNo });
        });

        // Çakışma çöz (1321): seçilen değer ANA kaynağa yazılır - şubenin e-Nabız hesabı (SKRS → kurum_kodu, tesis →
        //   ayarlar.medulaTesisKodu); e-Nabız hesabı yoksa kurum profili. Kayıt kapanır.
        grup.MapPost("/cakisma/{id:int}/coz", async (int id, CakismaCozIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);
            if (istek.Secim is not ("profil" or "eski"))
                throw GentegreHatasi.Dogrulama("Seçim 'profil' ya da 'eski' olmalı.", new AlanHatasi("secim", "profil / eski"));
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var c = await b.TekAsync("select sube_id, alan, eski_deger, profil_degeri from public.kurum_kimlik_cakisma where id = @p0 and cozuldu = 0 for update",
                islem, [id], o => new CakismaSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3)), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çakışma bulunamadı ya da çözülmüş.");
            var deger = istek.Secim == "eski" ? c.Eski : c.Profil;
            // 1323: yalnız şubenin KENDİ e-Nabız satırına yazılır (şube 0 → kurum geneli satır). Şubenin satırı yoksa şubenin
            //   kurum profili - kurum geneli satıra yazmak bütün şubelerin kodunu değiştirirdi.
            var (enabizId, genelEnabizVar) = await b.TekAsync(
                "select case when @p0 = 0 then enabiz_hesap_id else sube_enabiz_id end, enabiz_hesap_id is not null from public.fn_kurum_kimlik(@p0)",
                islem, [c.Sube], o => Tuple.Create(o.IsDBNull(0) ? (int?)null : o.GetInt32(0), o.GetBoolean(1)), iptal)
                ?? Tuple.Create((int?)null, false);
            // 1328: kurum profili yalnız YEDEK (kurum geneli e-Nabız onu ezer) - şubenin kendi e-Nabız satırı yokken kurum
            //   geneli e-Nabız varsa profile yazmak etkisiz kalırdı; şubeye e-Nabız satırı açılması istenir.
            if (enabizId is null && c.Sube != 0 && genelEnabizVar)
                throw GentegreHatasi.IsKurali(
                    "Bu şubenin kendi e-Nabız satırı yok - şubeye özel kod için Ayarlar › Entegrasyon › e-Nabız'da şube seçili bir satır açın; kurum geneli değer kullanılacaksa çakışmayı ondan seçin.");
            int n;
            if (enabizId is int eid)
                n = c.Alan == "skrs"
                    ? await b.CalistirAsync("update public.entegrasyon_hesap set kurum_kodu = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                        islem, [eid, deger, baglam.KullaniciId], iptal)
                    : await b.CalistirAsync("update public.entegrasyon_hesap set ayarlar = coalesce(ayarlar, '{}'::jsonb) || jsonb_build_object('medulaTesisKodu', @p1::text), degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                        islem, [eid, deger, baglam.KullaniciId], iptal);
            else
                n = await b.CalistirAsync($"update public.kurum_profil set {(c.Alan == "skrs" ? "skrs_kodu" : "tesis_kodu")} = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp where sube_id = @p0",
                    islem, [c.Sube, deger, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Yazılacak yer yok - bu şubeye e-Nabız satırı açın (Ayarlar › Entegrasyon › e-Nabız, şube seçili).");
            await b.CalistirAsync("update public.kurum_kimlik_cakisma set cozuldu = 1 where id = @p0", islem, [id], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = $"{deger} {(enabizId is null ? "kurum profiline" : "e-Nabız hesabına")} yazıldı.", izlemeNo = baglam.IzlemeNo });
        });

        // Entegrasyon kartı › TeleRadyoloji Bağlantısı sekmesi: şubenin kimliği (salt okunur) + Mirth hesapları (seçim).
        yol.MapGet("/api/entegrasyon/teleradyoloji/baglam", async (int? subeId, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await b.TekAsync("select ad, skrs, tesis, kaynak, enabiz_hesap_id from public.fn_kurum_kimlik(@p0)", null, [subeId ?? 0],
                o => new { ad = o.GetString(0), skrs = o.GetString(1), tesis = o.GetString(2), kaynak = o.GetString(3),
                           enabizHesapId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4) }, iptal);
            var mirthler = await b.ListeAsync(
                "select id, ad from public.entegrasyon_hesap where kod = 'MIRTH' and aktif = 1 order by id", null, [],
                o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { kimlik = k, mirthler, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Şube özeti TeleRadyoloji Panosu'nda (12.11.2026): pano yetkisi yeter; eski ayar ekranı yetkisi de kabul.</summary>
    private static void PanoYetkisi(IstekBaglami baglam)
    {
        if (!baglam.Yetkiler.Var("radyoloji.teletip.pano", Islem.Gor) && !baglam.Yetkiler.Var("radyoloji.teletip.ayar", Islem.Gor))
            throw GentegreHatasi.Yasak();
    }

    public sealed record KanalSonucu(string Adres, bool Acik, string Hata, int SureMs);

    /// <summary>
    /// Kanal adresine TCP (mesaj göndermez - Mirth HTTP dinleyicisine istek atmak kanalda mesaj açardı). HTTP kanalında (K2 /
    /// K3) adresin sonunda "/" olmalı (Jetty 302 verip gövdeyi düşürür). Şube özeti ve hesap kartı sınaması aynı kuralı kullanır.
    /// </summary>
    public static async Task<KanalSonucu> KanalDeneAsync(string adres, bool http, CancellationToken iptal)
    {
        adres = (adres ?? "").Trim();
        if (adres.Length == 0) return new(adres, false, "tanımsız", 0);
        if (http && !adres.EndsWith('/')) return new(adres, false, "adres sonunda \"/\" yok (Jetty 302 verip gövdeyi düşürür)", 0);
        var r = await MirthIzleme.TcpDeneAsync(adres, iptal);
        return new(adres, r.Acik, r.Acik ? "" : r.Hata, r.SureMs);
    }
}
