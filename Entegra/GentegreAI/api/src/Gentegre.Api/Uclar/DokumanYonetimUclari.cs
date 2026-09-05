using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DOKÜMAN YÖNETİMİ (419, Faz 1) — sürüm ve onay döngüsü.
///
/// Yükleme/indirme/paylaşım MEVCUT uçlarda kalır (DokumanUclari); burası
/// üstüne gelen yönetim katmanıdır: yeni sürüm, onaya gönderme, karar,
/// yayın. Kart galerileri hiç değişmeden çalışmaya devam eder.
///
/// <para><b>Sürümsüz türde akış yok.</b> Ürün resmi ya da tetkik sonucu
/// yüklenince doğrudan yayında olur. Her dosyayı onaydan geçirmek, galeriye
/// resim ekleyeni onay beklemeye mahkûm ederdi.</para>
///
/// <para><b>Yayında tek sürüm.</b> Yeni sürüm yayınlanınca öncekiler arşive
/// düşer (db kısıtı da bunu korur): iki yayın "hangisi geçerli" sorusunu
/// cevapsız bırakır ve kalite denetiminde bulunan ilk hatadır.</para>
///
/// <para><b>Erişim günlüğe yazılır</b> (KVKK): özel nitelikli dokümanda
/// gerekçe zorunlu. Günlük silinmez.</para>
/// </summary>
public static class DokumanYonetimUclari
{
    /// <summary>Yeni sürüm: içerik zaten yüklenmiş (hash), burada sürüm açılır.</summary>
    public sealed record SurumIstegi(string Hash, string? ContentType, int? Boyut,
                                     string? DegisiklikNotu);

    /// <summary>Onay adımı kararı: 1 uygun/onay · 2 düzelt/ret.</summary>
    public sealed record KararIstegi(int Karar, string? Not);

    public static void DokumanYonetimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/dokuman-yonetim").WithTags("Doküman")
                      .RequireAuthorization();

        // POST /api/dokuman-yonetim/{id}/surum - yeni sürüm aç (taslak)
        grup.MapPost("/{id:int}/surum", async (
            int id, SurumIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokuman", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var d = await baglanti.TekAsync("""
                select d.surumlu, d.akis_id, coalesce(max(s.surum_no), 0)
                  from public.dokuman d
                  left join public.dokuman_surum s on s.dokuman_id = d.id
                 where d.id = @p0
                 group by d.surumlu, d.akis_id
                """, islem, [id],
                o => new { Surumlu = o.GetInt16(0),
                           AkisId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           SonSurum = o.GetInt32(2) }, iptal);

            if (d is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Dokuman bulunamadi." } });

            var yeniNo = (short)(d.SonSurum + 1);
            // SURUMSUZ TURDE dogrudan yayin: galeriye resim ekleyeni onay
            //   beklemeye mahkum etmemek icin.
            var durum = (short)(d.Surumlu == 1 ? 1 : 3);

            var surumId = await baglanti.TekDegerAsync<int>("""
                insert into public.dokuman_surum (dokuman_id, surum_no, hash, content_type,
                                                  boyut, degisiklik_notu, yukleyen_id, durum,
                                                  yayin_tarihi)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7,
                        case when @p7 = 3 then now() end)
                returning id
                """, islem,
                [id, yeniNo, istek.Hash, istek.ContentType ?? "", istek.Boyut ?? 0,
                 istek.DegisiklikNotu ?? "", baglam.KullaniciId, durum], iptal);

            if (durum == 3) await YayinlaIcAsync(baglanti, islem, id, surumId, iptal);
            else await baglanti.CalistirAsync(
                "update public.dokuman set durum = 1 where id = @p0", islem, [id], iptal);

            await OlayYazAsync(baglanti, islem, id, surumId, (short)5, baglam.KullaniciId,
                               "", iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { surumId, surumNo = yeniNo, durum,
                                    mesaj = durum == 3
                                        ? "Yeni surum yayinlandi (surumsuz tur)."
                                        : "Yeni surum taslak olarak acildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/dokuman-yonetim/surum/{surumId}/onaya-gonder
        grup.MapPost("/surum/{surumId:int}/onaya-gonder", async (
            int surumId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokuman", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var s = await baglanti.TekAsync("""
                select s.dokuman_id, s.durum, d.akis_id, d.sahip_id
                  from public.dokuman_surum s
                  join public.dokuman d on d.id = s.dokuman_id
                 where s.id = @p0 for update of s
                """, islem, [surumId],
                o => new { DokumanId = o.GetInt32(0), Durum = o.GetInt16(1),
                           AkisId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                           SahipId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal);

            if (s is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Surum bulunamadi." } });
            if (s.Durum != 1)
                throw GentegreHatasi.IsKurali("Yalniz taslak surum onaya gonderilebilir.");
            if (s.AkisId is null)
                throw GentegreHatasi.IsKurali(
                    "Dokuman turunde onay akisi tanimli degil; surum dogrudan yayinlanabilir.");

            var onayId = await baglanti.TekDegerAsync<int>("""
                insert into public.dokuman_onay (dokuman_id, surum_id, akis_id, baslatan_id)
                values (@p0, @p1, @p2, @p3)
                returning id
                """, islem, [s.DokumanId, surumId, s.AkisId, baglam.KullaniciId], iptal);

            // Adimlar SABLONDAN KOPYALANIR: akis sonradan degisirse suren
            //   onay etkilenmemeli - denetimde "hangi kurala gore onaylandi"
            //   sorusunun cevabi surecin kendisinde durmali.
            await baglanti.CalistirAsync("""
                insert into public.dokuman_onay_adim
                       (onay_id, sira, ad, atanan_rol_id, atanan_kullanici_id)
                select @p0, a.sira, a.ad, a.rol_id,
                       case when a.dinamik = 1 then @p2 else a.kullanici_id end
                  from public.dokuman_akis_adim a
                 where a.akis_id = @p1
                 order by a.sira
                """, islem, [onayId, s.AkisId, s.SahipId], iptal);

            await baglanti.CalistirAsync("""
                update public.dokuman_surum set durum = 2, onay_id = @p1 where id = @p0
                """, islem, [surumId, onayId], iptal);
            await baglanti.CalistirAsync(
                "update public.dokuman set durum = 2 where id = @p0", islem, [s.DokumanId], iptal);

            await OlayYazAsync(baglanti, islem, s.DokumanId, surumId, (short)6,
                               baglam.KullaniciId, "", iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { onayId, mesaj = "Surum onaya gonderildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/dokuman-yonetim/onay/{onayId}/karar
        //   Sıradaki adıma karar verir; son adım onaylanınca sürüm YAYINLANIR.
        grup.MapPost("/onay/{onayId:int}/karar", async (
            int onayId, KararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dokuman", Islem.Degistir);

            if (istek.Karar is not (1 or 2))
                throw GentegreHatasi.Dogrulama("Karar 1 (onay) ya da 2 (ret) olmali.",
                    [new("karar", "Gecersiz karar.")]);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var o_ = await baglanti.TekAsync("""
                select o.dokuman_id, o.surum_id, o.guncel_adim, o.durum,
                       (select count(*) from public.dokuman_onay_adim a where a.onay_id = o.id)
                  from public.dokuman_onay o where o.id = @p0 for update
                """, islem, [onayId],
                o => new { DokumanId = o.GetInt32(0),
                           SurumId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           Adim = o.GetInt16(2), Durum = o.GetInt16(3),
                           AdimSayisi = o.GetInt64(4) }, iptal);

            if (o_ is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Onay sureci bulunamadi." } });
            if (o_.Durum != 1)
                throw GentegreHatasi.IsKurali("Onay sureci zaten kapanmis.");

            await baglanti.CalistirAsync("""
                update public.dokuman_onay_adim
                   set karar = @p2, karar_veren_id = @p3, karar_zamani = now(),
                       not_metni = @p4
                 where onay_id = @p0 and sira = @p1
                """, islem, [onayId, o_.Adim, (short)istek.Karar, baglam.KullaniciId,
                             istek.Not ?? ""], iptal);

            string mesaj;
            if (istek.Karar == 2)
            {
                // RET: surum reddedilir, dokuman TASLAGA doner. Hazirlayan
                //   duzeltip yeni surum acar - reddedilen surumu yeniden
                //   onaya gondermek, neyin degistigini gorunmez kilardi.
                await baglanti.CalistirAsync("""
                    update public.dokuman_onay set durum = 3, bitis = now() where id = @p0
                    """, islem, [onayId], iptal);
                await baglanti.CalistirAsync(
                    "update public.dokuman_surum set durum = 5 where id = @p0",
                    islem, [o_.SurumId], iptal);
                await baglanti.CalistirAsync("""
                    update public.dokuman set durum = case
                        when exists (select 1 from public.dokuman_surum s
                                      where s.dokuman_id = @p0 and s.durum = 3)
                        then 3 else 1 end
                     where id = @p0
                    """, islem, [o_.DokumanId], iptal);
                await OlayYazAsync(baglanti, islem, o_.DokumanId, o_.SurumId, (short)8,
                                   baglam.KullaniciId, istek.Not ?? "", iptal);

                // MESAJ DURUMU DOGRU SOYLEMELI: onceden yayinlanmis bir surum
                //   varsa dokuman YAYINDA KALIR - "taslaga dondu" demek,
                //   kullanicinin yururlukteki belgenin kalktigini sanmasina
                //   yol acardi.
                var yayindaKaldi = await baglanti.TekDegerAsync<int>("""
                    select count(*) from public.dokuman_surum s
                     where s.dokuman_id = @p0 and s.durum = 3
                    """, islem, [o_.DokumanId], iptal) > 0;
                mesaj = yayindaKaldi
                    ? "Surum reddedildi; onceki yayin surumu yururlukte kaldi."
                    : "Surum reddedildi; dokuman taslaga dondu.";
            }
            else if (o_.Adim < o_.AdimSayisi)
            {
                await baglanti.CalistirAsync(
                    "update public.dokuman_onay set guncel_adim = guncel_adim + 1 where id = @p0",
                    islem, [onayId], iptal);
                await OlayYazAsync(baglanti, islem, o_.DokumanId, o_.SurumId, (short)7,
                                   baglam.KullaniciId, istek.Not ?? "", iptal);
                mesaj = "Adim onaylandi; sonraki adima gecti.";
            }
            else
            {
                await baglanti.CalistirAsync("""
                    update public.dokuman_onay set durum = 2, bitis = now() where id = @p0
                    """, islem, [onayId], iptal);
                await YayinlaIcAsync(baglanti, islem, o_.DokumanId, o_.SurumId!.Value, iptal);
                await OlayYazAsync(baglanti, islem, o_.DokumanId, o_.SurumId, (short)9,
                                   baglam.KullaniciId, istek.Not ?? "", iptal);
                mesaj = "Onay tamamlandi; surum yayinlandi.";
            }

            await islem.CommitAsync(iptal);
            return Results.Ok(new { onayId, mesaj, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Sürümü yayınlar: önceki yayın ARŞİVE düşer ve doküman başlığı yeni
    /// sürümü gösterir (hash / sürüm no / durum).
    ///
    /// Başlıktaki hash'i güncellemek şart: kart galerisi ve indirme ucu oradan
    /// okuyor - güncellenmezse onaylanan sürüm hiç görünmezdi.
    /// </summary>
    private static async Task YayinlaIcAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction islem, int dokumanId, int surumId, CancellationToken iptal)
    {
        await baglanti.CalistirAsync("""
            update public.dokuman_surum
               set durum = 4, arsiv_tarihi = now()
             where dokuman_id = @p0 and durum = 3 and id <> @p1
            """, islem, [dokumanId, surumId], iptal);

        await baglanti.CalistirAsync("""
            update public.dokuman_surum
               set durum = 3, yayin_tarihi = coalesce(yayin_tarihi, now())
             where id = @p0
            """, islem, [surumId], iptal);

        await baglanti.CalistirAsync("""
            update public.dokuman d
               set hash = s.hash, content_type = s.content_type, boyut = s.boyut,
                   surum_no = s.surum_no, durum = 3, degistirme_tarihi = now()
              from public.dokuman_surum s
             where s.id = @p1 and d.id = @p0 and s.hash <> ''
            """, islem, [dokumanId, surumId], iptal);
    }

    /// <summary>Erişim/işlem günlüğü (KVKK) - silinmez.</summary>
    private static Task<int> OlayYazAsync(Npgsql.NpgsqlConnection baglanti,
        Npgsql.NpgsqlTransaction islem, int dokumanId, int? surumId, short olay,
        int kullaniciId, string gerekce, CancellationToken iptal)
        => baglanti.CalistirAsync("""
            insert into public.dokuman_olay (dokuman_id, surum_id, kullanici_id, olay, gerekce)
            values (@p0, @p1, @p2, @p3, @p4)
            """, islem, [dokumanId, surumId, kullaniciId, olay, gerekce], iptal);
}
