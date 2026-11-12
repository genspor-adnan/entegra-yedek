using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TELERADYOLOJİ (BAKANLIK) ŞUBE ÖZETİ (1317; mockup Ekranlar/Ayarlar/entegrasyon_teletip.html §3-§4). Ayar ekranı artık
/// düzenleme değil özet: her şubenin Bakanlık kimliği (kurum profili - tek kaynak), gönderim hesabı (Entegrasyon ›
/// TELERADYOLOJI; şube satırı → kurum geneli) ve kanal adresleri. Kimlik çakışmaları (1317 geçişinde iki yerde FARKLI
/// bulunan kodlar) burada seçilerek çözülür. Kart sekmesi için kimlik + Mirth hesapları da buradan.
/// </summary>
public static class TeleradyolojiSubeUclari
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };

    public sealed record CakismaCozIstegi(string Secim);   // "profil" | "eski"
    private sealed record CakismaSatiri(int Sube, string Alan, string Eski);

    public static void TeleradyolojiSubeUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/teletip").WithTags("TeleRadyoloji şubeler");

        grup.MapGet("/subeler", async (VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var model = await b.TekDegerAsync<bool>("select public.fn_teletip_hesap_modeli()", null, [], iptal);
            var subeler = await b.ListeAsync("""
                select s.id, s.ad,
                       k.ad as kimlik_ad, k.skrs, k.tesis,
                       exists (select 1 from public.kurum_profil kp where kp.sube_id = s.id and (kp.skrs_kodu <> '' or coalesce(kp.tesis_kodu, '') <> '' or kp.bakanlik_ad <> '')) as kendi_kimlik,
                       public.fn_teletip_hesap_ayar(s.id)::text as hesap
                  from public.sube s
                  cross join lateral public.fn_kurum_kimlik(s.id) k
                 where s.aktif = 1
                 order by s.id
                """, null, [], o => new
            {
                subeId = o.GetInt32(0), subeAdi = o.GetString(1),
                kimlik = new { ad = o.GetString(2), skrs = o.GetString(3), tesis = o.GetString(4), kendi = o.GetBoolean(5) },
                hesap = o.IsDBNull(6) ? null : JsonSerializer.Deserialize<TeleRadyolojiHesabi>(o.GetString(6), JsonAyar),
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
                hesapModeli = model, subeler, cakismalar,
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

        // Çakışma çöz: "eski" → eski değer kurum profiline yazılır; "profil" → profildeki kalır. İki durumda da kayıt kapanır.
        grup.MapPost("/cakisma/{id:int}/coz", async (int id, CakismaCozIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("ayar", Islem.Degistir);
            if (istek.Secim is not ("profil" or "eski"))
                throw GentegreHatasi.Dogrulama("Seçim 'profil' ya da 'eski' olmalı.", new AlanHatasi("secim", "profil / eski"));
            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            var c = await b.TekAsync("select sube_id, alan, eski_deger from public.kurum_kimlik_cakisma where id = @p0 and cozuldu = 0 for update",
                islem, [id], o => new CakismaSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2)), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Çakışma bulunamadı ya da çözülmüş.");
            if (istek.Secim == "eski")
            {
                var kolon = c.Alan == "skrs" ? "skrs_kodu" : "tesis_kodu";
                var n = await b.CalistirAsync($"update public.kurum_profil set {kolon} = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp where sube_id = @p0",
                    islem, [c.Sube, c.Eski, baglam.KullaniciId], iptal);
                if (n == 0) throw GentegreHatasi.IsKurali("Bu şubenin kurum profili satırı yok - önce Kurum Profili'nde şubeyi kaydedin.");
            }
            await b.CalistirAsync("update public.kurum_kimlik_cakisma set cozuldu = 1 where id = @p0", islem, [id], iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { mesaj = istek.Secim == "eski" ? "Eski değer kurum profiline yazıldı." : "Profildeki değer korundu.", izlemeNo = baglam.IzlemeNo });
        });

        // Entegrasyon kartı › TeleRadyoloji Bağlantısı sekmesi: şubenin kimliği (salt okunur) + Mirth hesapları (seçim).
        yol.MapGet("/api/entegrasyon/teleradyoloji/baglam", async (int? subeId, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("entegrasyon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await b.TekAsync("select ad, skrs, tesis from public.fn_kurum_kimlik(@p0)", null, [subeId ?? 0],
                o => new { ad = o.GetString(0), skrs = o.GetString(1), tesis = o.GetString(2) }, iptal);
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
