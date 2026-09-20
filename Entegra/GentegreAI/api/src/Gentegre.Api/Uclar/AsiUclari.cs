using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// AŞI UYGULAMASI (898 — KTS denetim maddesi H10, USS 207).
///
/// <para>H10 altı USS paketi istiyordu; beşinin ortak sorunu paket değil
/// <b>kaynak veriydi</b>: bizde hasta bazlı aşı kaydı hiç yoktu. Bu uçlar
/// kaydı açar, 207 paketi kayıttan doğar.</para>
///
/// <para><b>Uygulanmış aşı silinmez</b>, iptal edilir ve gerekçesi yazılır:
/// aşı geri alınamayan bir işlemdir; yanlış kaydın izi de kalmalıdır.</para>
///
/// <para><b>SKRS kodu olmayan aşı gönderilemez</b> ve bunu ekran söyler.
/// Sessizce eksik paket üretmek, kurumun gönderdiğini sanmasına yol
/// açardı.</para>
/// </summary>
public static class AsiUclari
{
    public sealed record UygulamaIstegi(int TarafId, int AsiId, short? DozNo,
        int? BelgeId, int? MuayeneId, string? Lot, string? Barkod,
        short? UygulamaSekli, short? UygulamaYeri, short? IslemTuru,
        short? OzelDurum, short? IzlemYeri, int? UygulayanId,
        DateTime? UygulamaZamani, string? BilgiAlinanAd, string? BilgiAlinanTel,
        string? SorguNo, string? Aciklama);

    public sealed record IptalIstegi(string Neden);

    public static void AsiUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/asi").WithTags("Aşı").RequireAuthorization();

        // GET /api/asi/hasta/{id} - hastanın aşı geçmişi + şemadaki sıradaki doz.
        grup.MapGet("/hasta/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("asi", Islem.Gor);

            var uygulamalar = await veri.ListeAsync("""
                select id, asi_id as "asiId", asi_kod as "asiKod", asi, skrs_kod as "skrsKod",
                       doz_no as "dozNo", doz_sayisi as "dozSayisi", kalan_doz as "kalanDoz",
                       lot, barkod, uygulama_zamani as "uygulamaZamani",
                       uygulayan, durum, iptal_neden as "iptalNeden",
                       enabiz_durum as "enabizDurum", aciklama
                  from public.v_asi_uygulama
                 where taraf_id = @p0
                 order by uygulama_zamani desc, id desc
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SIRADAKİ DOZ: şeması olan aşılarda "kaçıncı doz" sorusunu
            //   kullanıcıya sordurtmamak için - yanlış doz numarası, USS'de
            //   yanlış şema demektir.
            var siradaki = await veri.ListeAsync("""
                select a.id as "asiId", a.kod, a.ad, a.doz_sayisi as "dozSayisi",
                       coalesce(max(u.doz_no) filter (where u.durum = 1), 0) + 1 as "sonrakiDoz"
                  from public.asi a
                  left join public.asi_uygulama u on u.asi_id = a.id and u.taraf_id = @p0
                 where a.aktif = 1
                 group by a.id, a.kod, a.ad, a.doz_sayisi
                having a.doz_sayisi = 0
                     or coalesce(max(u.doz_no) filter (where u.durum = 1), 0) < a.doz_sayisi
                 order by a.sira, a.ad
                """, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { uygulamalar, siradaki, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/asi/uygula - aşı kaydı + 207 paketi.
        grup.MapPost("/uygula", async (
            UygulamaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            EnabizTetikleyici tetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("asi", Islem.Ekle);

            var asi = await veri.TekAsync("""
                select a.ad, a.skrs_kod, a.doz_sayisi, a.uygulama_sekli, a.uygulama_yeri
                  from public.asi a where a.id = @p0 and a.aktif = 1
                """, [istek.AsiId],
                o => new { Ad = o.GetString(0), Skrs = o.GetString(1),
                           DozSayisi = o.GetInt16(2),
                           Sekil = o.IsDBNull(3) ? (short?)null : o.GetInt16(3),
                           Yer = o.IsDBNull(4) ? (short?)null : o.GetInt16(4) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Aşı bulunamadı ya da pasif.");

            // DOZ VERİLMEZSE ŞEMADAN HESAPLANIR: son uygulanan + 1.
            var doz = istek.DozNo ?? (short)(await veri.TekDegerAsync<int>("""
                select coalesce(max(doz_no), 0)::int from public.asi_uygulama
                 where taraf_id = @p0 and asi_id = @p1 and durum = 1
                """, [istek.TarafId, istek.AsiId], iptal) + 1);

            if (asi.DozSayisi > 0 && doz > asi.DozSayisi)
                throw GentegreHatasi.IsKurali(
                    $"{asi.Ad} şemasında {asi.DozSayisi} doz var; {doz}. doz yazılamaz.");

            int id;
            try
            {
                id = await veri.TekDegerAsync<int>("""
                    insert into public.asi_uygulama
                           (taraf_id, belge_id, muayene_id, asi_id, doz_no, lot, barkod,
                            uygulama_sekli, uygulama_yeri, islem_turu, ozel_durum,
                            izlem_yeri, uygulayan_id, uygulama_zamani,
                            bilgi_alinan_ad, bilgi_alinan_tel, sorgu_no, aciklama,
                            sube_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5, @p6,
                            coalesce(@p7, @p16), coalesce(@p8, @p17), @p9, @p10, @p11,
                            coalesce(@p12, @p18), coalesce(@p13, now()),
                            @p14, @p15, @p19, @p20, @p21, @p18)
                    returning id
                    """,
                    [istek.TarafId, istek.BelgeId, istek.MuayeneId, istek.AsiId, doz,
                     istek.Lot ?? "", istek.Barkod ?? "",
                     istek.UygulamaSekli, istek.UygulamaYeri, istek.IslemTuru,
                     istek.OzelDurum, istek.IzlemYeri, istek.UygulayanId,
                     istek.UygulamaZamani, istek.BilgiAlinanAd ?? "",
                     istek.BilgiAlinanTel ?? "",
                     // Aşı kartındaki varsayılanlar: kullanıcı boş bırakırsa.
                     asi.Sekil, asi.Yer, baglam.KullaniciId,
                     istek.SorguNo ?? "", istek.Aciklama ?? "", baglam.SubeId ?? 0], iptal);
            }
            catch (Npgsql.PostgresException h) when (h.SqlState == "23505")
            {
                // AYNI DOZ İKİ KEZ: kısmi benzersiz index. Mesaj net olmalı -
                //   "beklenmeyen hata" kullanıcıyı tekrar denemeye iter.
                throw GentegreHatasi.IsKurali(
                    $"{asi.Ad} {doz}. dozu bu hastaya zaten kayıtlı.");
            }

            // 207 PAKETİ: kayıt açıldıktan sonra. SKRS kodu yoksa paket
            //   üretilmez - eksik alanla göndermek yerine kurum uyarılır.
            var paketNotu = "";
            if (asi.Skrs.Trim().Length == 0)
                paketNotu = " Aşının SKRS kodu tanımlı değil - e-Nabız'a gönderilemez.";
            else
                await tetik.AsiUygulandiAsync(id, baglam.KullaniciId, iptal);

            return Results.Ok(new { id, doz,
                mesaj = $"{asi.Ad} {doz}. doz kaydedildi.{paketNotu}",
                izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/asi/{id}/iptal - yanlış kaydı gerekçesiyle kapat.
        grup.MapPost("/{id:int}/iptal", async (
            int id, IptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("asi.iptal");

            if (string.IsNullOrWhiteSpace(istek.Neden))
                throw GentegreHatasi.Dogrulama("İptal nedeni zorunlu.",
                    [new("neden", "Kaydın neden iptal edildiğini yazın.")]);

            var etkilenen = await veri.CalistirAsync("""
                update public.asi_uygulama
                   set durum = 0, iptal_neden = @p1,
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum = 1
                """, [id, istek.Neden.Trim(), baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Kayıt bulunamadı ya da zaten iptal edilmiş.");

            // GÖNDERİLMİŞ PAKET BURADA SİLİNMEZ: USS'de duran bir kaydı
            //   kaldırmak ayrı bir paket türüdür (200 Veri Paketi Silme).
            //   Kaydı iptal edip paketi sessizce unutmak, iki tarafı
            //   ayrıştırırdı - uyarı veriyoruz.
            var gonderildi = await veri.TekDegerAsync<int>("""
                select count(*)::int from public.enabiz_paket
                 where kaynak_tur = 10 and kaynak_id = @p0 and durum >= 3
                """, [id], iptal);

            return Results.Ok(new { id,
                mesaj = "Aşı kaydı iptal edildi."
                      + (gonderildi > 0
                         ? " DİKKAT: bu kayıt e-Nabız'a gönderilmişti; silme paketi (200) "
                           + "ayrıca gönderilmelidir."
                         : ""),
                izlemeNo = baglam.IzlemeNo });
        });
    }
}
