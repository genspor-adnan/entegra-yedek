using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Its;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İTS UÇLARI — v1 (Faz 1): karekod okuma, doğrulama, mal alım bildirimi.
///
/// <para><b>Karekod çözümleme SUNUCUDA.</b> Okuyucudan gelen ham metin
/// istemciye ayrıştırılsaydı her ekranda ayrı bir GS1 çözümleyicisi olurdu ve
/// ayırıcı göndermeyen okuyucu bir ekranda çalışıp ötekinde bozulurdu. Kural
/// tek yerde (Çekirdek/Its), testli.</para>
///
/// <para><b>Doğrulama isteğe bağlı.</b> İTS hesabı yoksa karekod yine
/// kaydedilir, yalnız "doğrulanmadı" kalır - doğrulamayı zorunlu kılmak, kapı
/// kapalıyken mal kabulünü tamamen durdururdu.</para>
/// </summary>
public static class ItsUclari
{
    /// <summary>Okutulan karekodlar + bildirimin bağlı olduğu belge.</summary>
    public sealed record BildirimIstegi(int Tur, int? BelgeId, string? KarsiGln,
                                        string[] Karekodlar, string? IslemTarihi);

    public static void ItsUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/its").WithTags("İTS").RequireAuthorization();

        // POST /api/its/karekod - tek karekod çözümle (+ istenirse doğrula)
        //   Okutma anında çağrılır: hekim/depo görevlisi kutuyu okuttuğunda
        //   ürünün ne olduğu ANINDA görünmeli, bildirim beklenmemeli.
        grup.MapPost("/karekod", async (
            KarekodIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, ItsServisiKisayol its,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Gor);

            var kod = KarekodCozumleme.Coz(istek.Karekod);
            if (!kod.Gecerli)
                throw GentegreHatasi.Dogrulama(kod.Hata, [new("karekod", kod.Hata)]);

            // Katalog eslesmesi: GTIN 14 hane, ilac katalogu EAN-13.
            var barkod = KarekodCozumleme.GtinBarkod(kod.Gtin);
            var ilac = await veri.TekAsync("""
                select i.barkod, i.ad, coalesce(i.stok_id, 0), i.recete_turu
                  from public.ilac i where i.barkod = @p0
                """, [barkod],
                o => new { Barkod = o.GetString(0), Ad = o.GetString(1),
                           StokId = o.GetInt32(2), ReceteTuru = o.GetInt16(3) }, iptal);

            var dogrulama = istek.Dogrula == true
                ? await its.Servis.DogrulaAsync(kod, iptal)
                : null;

            return Results.Ok(new
            {
                kod.Gtin, barkod, kod.SeriNo, kod.PartiNo,
                sonKullanma = kod.SonKullanma,
                ilacAd = ilac?.Ad ?? "",
                stokId = ilac?.StokId ?? 0,
                katalogda = ilac is not null,
                dogrulama = dogrulama is null ? null
                    : new { dogrulama.Gecerli, dogrulama.Durum, dogrulama.Mesaj },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/its/bildirim - mal alım (kabul) bildirimi kuyruğa
        grup.MapPost("/bildirim", async (
            BildirimIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Degistir);

            if (istek.Karekodlar is not { Length: > 0 })
                throw GentegreHatasi.Dogrulama("En az bir karekod okutulmalı.",
                    [new("karekodlar", "Karekod listesi boş.")]);

            // ONCE HEPSI COZULUR: bir kod bozuksa bildirim HIC acilmaz.
            //   Yarim bildirim, kutularin bir kismi bildirilmis bir kismi
            //   bildirilmemis bir envanter birakirdi.
            var cozulen = new List<KarekodCozumleme.Karekod>();
            foreach (var ham in istek.Karekodlar)
            {
                var k = KarekodCozumleme.Coz(ham);
                if (!k.Gecerli)
                    throw GentegreHatasi.Dogrulama($"Karekod okunamadı: {k.Hata}",
                        [new("karekodlar", $"{ham}: {k.Hata}")]);
                cozulen.Add(k);
            }

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var tarih = DateOnly.TryParse(istek.IslemTarihi, out var g)
                      ? g : DateOnly.FromDateTime(DateTime.Today);

            var bildirimId = await baglanti.TekDegerAsync<int>("""
                insert into public.its_bildirim (tur, durum, sube_id, test_mi, belge_id,
                                                 karsi_gln, islem_tarihi, ekleyen)
                select @p0, 1, @p1,
                       coalesce((select e.test_mi from public.entegrasyon_hesap e
                                  where e.kod = 'ITS' limit 1), 1),
                       @p2, @p3, @p4::date, @p5
                returning id
                """, islem,
                [(short)(istek.Tur <= 0 ? 1 : istek.Tur), baglam.SubeId ?? 0, istek.BelgeId,
                 istek.KarsiGln ?? "", tarih.ToDateTime(TimeOnly.MinValue),
                 baglam.KullaniciId], iptal);

            var eklenen = 0;
            foreach (var (k, ham) in cozulen.Zip(istek.Karekodlar))
            {
                var barkod = KarekodCozumleme.GtinBarkod(k.Gtin);
                // AYNI KUTU IKINCI KEZ: benzersiz indeks reddeder; burada
                //   yakalanip kullaniciya SEBEBIYLE soylenir, yoksa 23505
                //   "beklenmeyen hata" olarak doner.
                var varMi = await baglanti.TekDegerAsync<int>("""
                    select count(*) from public.its_bildirim_satir s
                     where s.gtin = @p0 and s.seri_no = @p1 and s.seri_no <> ''
                    """, islem, [k.Gtin, k.SeriNo], iptal);
                if (varMi > 0)
                    throw GentegreHatasi.IsKurali(
                        $"Bu kutu zaten bildirilmiş (GTIN {k.Gtin}, seri {k.SeriNo}).");

                await baglanti.CalistirAsync("""
                    insert into public.its_bildirim_satir
                           (bildirim_id, karekod, gtin, seri_no, parti_no, son_kullanma,
                            ilac_barkod, stok_id, ekleyen)
                    select @p0, @p1, @p2, @p3, @p4, @p5::date, @p6,
                           (select i.stok_id from public.ilac i where i.barkod = @p6), @p7
                    """, islem,
                    [bildirimId, ham, k.Gtin, k.SeriNo, k.PartiNo,
                     k.SonKullanma?.ToDateTime(TimeOnly.MinValue), barkod,
                     baglam.KullaniciId], iptal);
                eklenen++;
            }

            await islem.CommitAsync(iptal);
            return Results.Ok(new { bildirimId, eklenen,
                mesaj = $"{eklenen} karekod bildirim kuyruğuna alındı.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/its/bildirim/{id}/gonder - "Şimdi Gönder"
        grup.MapPost("/bildirim/{id:int}/gonder", async (
            int id, BaglamCozucu cozucu, ItsServisiKisayol its,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Degistir);

            var s = await its.Servis.CalistirAsync(1, id, iptal);
            return Results.Ok(new { id, s.Alinan, s.Gonderilen, s.Hatali,
                                    mesaj = s.Aciklama, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/its/bildirim/{id}/iptal
        grup.MapPost("/bildirim/{id:int}/iptal", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("stok", Islem.Degistir);

            // GONDERILMIS bildirim iptal edilemez: İTS'de kayıt oluştu,
            //   geri almak ayrı bir bildirim türüdür (iade / deaktivasyon).
            var etkilenen = await veri.CalistirAsync("""
                update public.its_bildirim set durum = 5, degistiren = @p1,
                       degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, [id, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali(
                    "Yalnız bekleyen ya da hatalı bildirim iptal edilebilir; "
                  + "gönderilmiş bildirim için iade/deaktivasyon gerekir.");

            return Results.Ok(new { id, mesaj = "Bildirim iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>Tek karekod çözümleme isteği.</summary>
    public sealed record KarekodIstegi(string Karekod, bool? Dogrula);
}

/// <summary>
/// Uçların İTS servisine erişimi.
///
/// Minimal API her parametreyi DI'dan çözüyor; servisi doğrudan parametre
/// olarak almak yerine ince bir sarmalayıcı kullanılıyor ki uç imzaları
/// Servisler ad alanına bağımlı görünmesin.
/// </summary>
public sealed class ItsServisiKisayol(Servisler.ItsServisi servis)
{
    public Servisler.ItsServisi Servis { get; } = servis;
}
