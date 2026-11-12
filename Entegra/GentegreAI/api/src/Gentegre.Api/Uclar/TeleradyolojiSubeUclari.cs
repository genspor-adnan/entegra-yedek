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
            baglam.YetkiIste("radyoloji.teletip.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var model = await b.TekDegerAsync<bool>("select public.fn_teletip_hesap_modeli()", null, [], iptal);
            // Eski yolda (hesap yok) ayar her zaman döner; açık mı ayrıca (teletip.aktif) - ekran "gönderiyor" demesin.
            var aktif = await b.TekDegerAsync<bool>("select public.fn_teletip_aktif()", null, [], iptal);
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
                hesap = o.IsDBNull(7) ? null : JsonSerializer.Deserialize<TeleRadyolojiHesabi>(o.GetString(7), JsonAyar),
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
                hesapModeli = model, aktif, subeler, cakismalar,
                mirth = new { url = m.Url, kullanici = m.Kullanici, parolaTanimli = m.ParolaTanimli, kaynak = m.Kaynak },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // Kanal adreslerine TCP (mesaj göndermez - Mirth HTTP dinleyicisine GET atmak kanalda mesaj açardı).
        grup.MapPost("/subeler/sina", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var hesaplar = await b.ListeAsync("""
                select s.id, public.fn_teletip_hesap_ayar(s.id)::text from public.sube s where s.aktif = 1 order by s.id
                """, null, [], o => (Sube: o.GetInt32(0), Json: o.IsDBNull(1) ? null : o.GetString(1)), iptal);
            var onbellek = new Dictionary<string, object>();
            async Task<object> Dene(string adres)
            {
                var hp = HostPort(adres);
                if (hp is null) return new { adres, acik = false, hata = adres.Length == 0 ? "tanımsız" : "adres çözülemedi", sureMs = 0 };
                if (onbellek.TryGetValue(hp, out var x)) return x;
                var r = await MirthIzleme.TcpDeneAsync(hp, iptal);
                var sonuc = new { adres, acik = r.Acik, hata = r.Hata, sureMs = r.SureMs };
                onbellek[hp] = sonuc;
                return sonuc;
            }
            var liste = new List<object>();
            foreach (var (sube, json) in hesaplar)
            {
                if (json is null) { liste.Add(new { subeId = sube, k1 = (object?)null, k2 = (object?)null, k3 = (object?)null }); continue; }
                var h = JsonSerializer.Deserialize<TeleRadyolojiHesabi>(json, JsonAyar) ?? new();
                liste.Add(new { subeId = sube, k1 = await Dene(h.Hl7Adres), k2 = await Dene(h.XdsAdres), k3 = await Dene(h.DozAdres) });
            }
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
            var enabizId = await b.TekDegerAsync<int?>(
                "select case when @p0 = 0 then enabiz_hesap_id else sube_enabiz_id end from public.fn_kurum_kimlik(@p0)", islem, [c.Sube], iptal);
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

    /// <summary>"10.0.0.12:6661" ya da "http://10.0.0.12:8082/kos/" → "host:port".</summary>
    public static string? HostPort(string adres)
    {
        if (string.IsNullOrWhiteSpace(adres)) return null;
        adres = adres.Trim();
        if (Uri.TryCreate(adres, UriKind.Absolute, out var u) && (u.Scheme == Uri.UriSchemeHttp || u.Scheme == Uri.UriSchemeHttps))
            return $"{u.Host}:{u.Port}";
        var p = adres.Split(':');
        return p.Length == 2 && int.TryParse(p[1], out _) ? adres : null;
    }
}
