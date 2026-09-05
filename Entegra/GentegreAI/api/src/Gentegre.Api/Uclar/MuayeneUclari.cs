using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE AKIŞI (409, Faz 1) — hekimin iki düğmesi.
///
/// Kartın alanlarını kaydetmek genel kart ucundan yürür; burada olan şey
/// DURUM GEÇİŞİdir ve geçişin kuralları vardır:
///
/// <para><b>Muayeneye Al</b> başlangıç zamanını yazar. Bu zaman USS "Muayene
/// Başlangıç" alanıdır ve kartın açılma zamanıyla aynı değildir: kart sabah
/// açılıp hasta öğleden sonra girebilir. İkinci kez basmak zamanı EZMEZ -
/// yoksa "hasta ne zaman girdi" sorusunun cevabı her tıklamada değişirdi.</para>
///
/// <para><b>Tamamla</b> kaydı kilitler, başvuruyu tahakkuka döndürür ve
/// e-Nabız kuyruğuna atar. Bu yüzden eksik kayıtta reddedilir: ana tanı,
/// şikayet ve karar zorunludur. Kontrolü gönderim anına bırakmak, hatayı
/// hekim ekrandan ayrıldıktan çok sonra geri getirirdi.</para>
/// </summary>
public static class MuayeneUclari
{
    public static void MuayeneUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/muayene").WithTags("Muayene").RequireAuthorization();

        // POST /api/muayene/{id}/al - "Muayeneye Al"
        grup.MapPost("/{id:int}/al", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            // coalesce: ikinci tikta zaman EZILMEZ.
            var zaman = await veri.TekDegerAsync<DateTime?>("""
                update public.muayene
                   set baslangic = coalesce(baslangic, now()),
                       durum = case when durum = 0 then 1 else durum end,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                returning baslangic
                """, [id, baglam.KullaniciId], iptal);

            if (zaman is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });

            return Results.Ok(new { id, baslangic = zaman,
                                    mesaj = $"Muayeneye alindi ({zaman:HH:mm}).",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/tamamla
        grup.MapPost("/{id:int}/tamamla", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var m = await baglanti.TekAsync("""
                select m.durum, m.belge_id, btrim(m.sikayet), btrim(m.karar),
                       (select count(*) from public.tani t
                         where t.muayene_id = m.id and t.tur = 1),
                       (select count(*) from public.muayene_istem s
                         where s.muayene_id = m.id and s.sonuc_durum in (0, 1))
                  from public.muayene m where m.id = @p0 for update
                """, islem, [id], o => new
                {
                    Durum = o.GetInt16(0),
                    BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                    Sikayet = o.GetString(2), Karar = o.GetString(3),
                    AnaTani = o.GetInt64(4), BekleyenIstem = o.GetInt64(5),
                }, iptal);

            if (m is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Muayene bulunamadi." } });
            if (m.Durum == 3)
                throw GentegreHatasi.IsKurali("Muayene zaten tamamlanmis.");

            // TAMAMLAMA KURALI (muayene sureci, adim 10). Eksikler TEK SEFERDE
            //   sayilir: hekime "once tani gir", sonra "sikayet de lazim"
            //   demek ekrani iki kez kapattirirdi.
            var eksikler = new List<AlanHatasi>();
            if (m.AnaTani == 0) eksikler.Add(new("tanilar", "Ana tani zorunlu."));
            if (m.Sikayet.Length == 0) eksikler.Add(new("sikayet", "Sikayet zorunlu."));
            if (m.Karar.Length == 0) eksikler.Add(new("karar", "Degerlendirme / plan zorunlu."));
            if (eksikler.Count > 0)
                throw GentegreHatasi.Dogrulama(
                    "Muayene tamamlanamaz: " + string.Join(" ", eksikler.Select(x => x.Mesaj)),
                    [.. eksikler]);

            await baglanti.CalistirAsync("""
                update public.muayene
                   set durum = 3, bitis = coalesce(bitis, now()), tamamlanma = now(),
                       tamamlayan_id = @p1, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            // Bekleyen istem varsa hekim bunu BILMELI: sonuc gelmeden kapanan
            //   muayenede tetkik sahipsiz kalir. Engel degil, uyari.
            var uyari = m.BekleyenIstem > 0
                ? $"{m.BekleyenIstem} istem hala sonuc bekliyor."
                : null;
            return Results.Ok(new { id, m.BelgeId, uyari,
                                    mesaj = "Muayene tamamlandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
