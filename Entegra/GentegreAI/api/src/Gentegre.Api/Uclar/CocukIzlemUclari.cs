using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BEBEK / ÇOCUK İZLEMİ (899 — KTS maddesi H10, USS 209).
///
/// <para>Ölçümler ekrandaki birimlerle tutulur (boy cm, <b>kilo kg</b>, baş
/// çevresi cm); pakette kilo GRAMA çevrilir - çevrim tek yerde, paket
/// sorgusunda.</para>
///
/// <para><b>Persentil eğri verisi olmadan hesaplanmaz.</b> `cocuk_buyume_lms`
/// boşken izlem yine kaydedilir ve gönderilir, yalnız persentil boş görünür;
/// uydurulmuş bir eğri sağlıklı çocuğu "geri kalmış" gösterebilirdi.</para>
/// </summary>
public static class CocukIzlemUclari
{
    public sealed record IzlemIstegi(int TarafId, short KacinciIzlem, int? BelgeId,
        int? MuayeneId, short? IslemTuru, DateTime? IzlemTarihi,
        decimal? BoyCm, decimal? KiloKg, decimal? BasCevresiCm, int? DogumAgirligiG,
        decimal? Hemoglobin, decimal? Hematokrit,
        short? Beslenme, short? DVitamini, short? Demir, short? Gkd, short? Gorme,
        short? Dkh, short? DkhYapilmama, short? Ntp, string? Oneri, string? Aciklama);

    public sealed record IptalIstegi(string Neden);

    public static void CocukIzlemUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/cocuk-izlem").WithTags("Çocuk İzlem")
                      .RequireAuthorization();

        // GET /api/cocuk-izlem/hasta/{id} - çocuğun izlem geçmişi + persentiller.
        grup.MapGet("/hasta/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cocuk.izlem", Islem.Gor);

            var izlemler = await veri.ListeAsync("""
                select id, kacinci_izlem as "kacinciIzlem", izlem_tarihi as "izlemTarihi",
                       yas_ay as "yasAy", boy_cm as "boyCm", kilo_kg as "kiloKg",
                       bas_cevresi_cm as "basCevresiCm",
                       kilo_persentil as "kiloPersentil", boy_persentil as "boyPersentil",
                       bas_persentil as "basPersentil",
                       hemoglobin, hematokrit, beslenme, d_vitamini as "dVitamini",
                       demir, gkd, gorme, dkh, ntp, oneri, aciklama,
                       durum, iptal_neden as "iptalNeden", enabiz_durum as "enabizDurum"
                  from public.v_cocuk_izlem
                 where taraf_id = @p0
                 order by kacinci_izlem desc, id desc
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SIRADAKİ İZLEM NUMARASI: kullanıcı saymasın - yanlış sıra,
            //   USS'de yanlış izlem demektir.
            var sonraki = await veri.TekDegerAsync<int>("""
                select coalesce(max(kacinci_izlem), 0)::int + 1
                  from public.cocuk_izlem where taraf_id = @p0 and durum = 1
                """, [id], iptal);

            // EĞRİ VERİSİ YOKSA EKRAN BUNU SÖYLESİN: boş persentil "ölçüm
            //   kötü" diye okunmamalı.
            var egriVar = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.cocuk_buyume_lms", null, iptal) > 0;

            return Results.Ok(new { izlemler, sonraki, egriVar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/cocuk-izlem - izlem kaydı + 209 paketi.
        grup.MapPost("/", async (
            IzlemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            EnabizTetikleyici tetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cocuk.izlem", Islem.Ekle);

            if (istek.KacinciIzlem <= 0)
                throw GentegreHatasi.Dogrulama("İzlem sırası gerekli.",
                    [new("kacinciIzlem", "Kaçıncı izlem olduğunu seçin.")]);

            int id;
            try
            {
                id = await veri.TekDegerAsync<int>("""
                    insert into public.cocuk_izlem
                           (taraf_id, belge_id, muayene_id, kacinci_izlem, islem_turu,
                            izlem_tarihi, boy_cm, kilo_kg, bas_cevresi_cm,
                            dogum_agirligi_g, hemoglobin, hematokrit, beslenme,
                            d_vitamini, demir, gkd, gorme, dkh, dkh_yapilmama, ntp,
                            oneri, aciklama, sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, coalesce(@p5, now()),
                            @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13, @p14,
                            @p15, @p16, @p17, @p18, @p19, @p20, @p21, @p22, @p23)
                    returning id
                    """,
                    [istek.TarafId, istek.BelgeId, istek.MuayeneId, istek.KacinciIzlem,
                     istek.IslemTuru, istek.IzlemTarihi, istek.BoyCm, istek.KiloKg,
                     istek.BasCevresiCm, istek.DogumAgirligiG, istek.Hemoglobin,
                     istek.Hematokrit, istek.Beslenme, istek.DVitamini, istek.Demir,
                     istek.Gkd, istek.Gorme, istek.Dkh, istek.DkhYapilmama, istek.Ntp,
                     istek.Oneri ?? "", istek.Aciklama ?? "", baglam.SubeId ?? 0,
                     baglam.KullaniciId], iptal);
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "23505")
            {
                throw GentegreHatasi.IsKurali(
                    $"Bu çocuğun {istek.KacinciIzlem}. izlemi zaten kayıtlı.");
            }

            await tetik.CocukIzlemiKaydedildiAsync(id, baglam.KullaniciId, iptal);

            // PERSENTİL YANITTA: hekim ölçümü girdiği anda eğrideki yerini
            //   görmeli - ayrı bir ekrana gitmek, bakılmamasına yol açar.
            var p = await veri.TekAsync("""
                select kilo_persentil, boy_persentil, bas_persentil, yas_ay
                  from public.v_cocuk_izlem where id = @p0
                """, [id],
                o => new { Kilo = o.IsDBNull(0) ? (decimal?)null : o.GetDecimal(0),
                           Boy = o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                           Bas = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                           YasAy = o.IsDBNull(3) ? (int?)null : o.GetInt32(3) }, iptal);

            return Results.Ok(new { id, p?.YasAy,
                kiloPersentil = p?.Kilo, boyPersentil = p?.Boy, basPersentil = p?.Bas,
                mesaj = $"{istek.KacinciIzlem}. izlem kaydedildi.",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/cocuk-izlem/{id}/iptal - yanlış kaydı gerekçesiyle kapat.
        grup.MapPost("/{id:int}/iptal", async (
            int id, IptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("cocuk.izlem", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Neden))
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    [new("neden", "Kaydın neden iptal edildiğini yazın.")]);

            var etkilenen = await veri.CalistirAsync("""
                update public.cocuk_izlem
                   set durum = 0, iptal_neden = @p1,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, [id, istek.Neden.Trim(), baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Kayıt bulunamadı ya da zaten iptal edilmiş.");

            return Results.Ok(new { id, mesaj = "İzlem kaydı iptal edildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
