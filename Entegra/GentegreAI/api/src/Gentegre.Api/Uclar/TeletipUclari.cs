using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TELETIP GÖNDERİM UÇLARI (1302): istemin Teletıp mesaj izi, mesajın ham hâli, yeniden gönderme ve gönderim öncesi
/// önizleme (ne gidecek, ne eksik). Ekranlar (Ekranlar/Radyoloji/teletip_mirth.html §3, §4, §6) bunları okur.
/// </summary>
public static class TeletipUclari
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };

    public static void TeletipUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/teletip").WithTags("Teletıp").RequireAuthorization();

        // İstemin gönderimleri (eskiden yeniye): emir, durum, deneme, ACK, hata. `radyoloji` görme yeter - istem
        //   kartındaki şerit bunu okur; ham mesaj / yeniden gönder / önizleme ekran yetkisi (radyoloji.teletip) ister.
        grup.MapGet("/istem/{istemId:int}", async (int istemId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);
            var satirlar = await veri.ListeAsync("""
                select id, kanal, emir, durum, deneme_no as "denemeNo", ack_kodu as "ackKodu", hata_metni as "hata",
                       kontrol_no as "kontrolNo", accession_no as "accessionNo", ekleme_tarihi as "eklemeTarihi",
                       son_deneme as "sonDeneme", sonraki_deneme as "sonrakiDeneme"
                  from public.teletip_gonderim where istem_id = @p0 order by id
                """, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal);
            // Kart başlığı: istemin kimliği (istem silinmişse yok).
            var istem = (await veri.ListeAsync("""
                select i.id, i.accession_no as "accessionNo", i.durum, i.hasta_id as "hastaId",
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as "hastaAdi",
                       coalesce(hz.ad, '') || public.fn_radyoloji_yon_ek(i.yon) as "tetkikAdi",
                       public.fn_rad_modalite_kod(i.modalite) as modalite,
                       coalesce(i.kabul_tarihi, i.ekleme_tarihi) as kabul
                  from public.radyoloji_istem i
                  left join public.taraf h on h.id = i.hasta_id
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.id = @p0
                """, [istemId], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault();
            return Results.Ok(new { aktif = await AktifAsync(veri, iptal), istem, satirlar,
                                    detayYetkisi = baglam.Yetkiler.Var("radyoloji.teletip", Islem.Gor) });
        });

        // Ham mesaj + ACK (kart: mesaj izi). Hasta kimliği içerir - radyoloji görme yetkisi.
        grup.MapGet("/gonderim/{id:long}/mesaj", async (long id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip", Islem.Gor);
            var s = await veri.TekAsync("select mesaj, yanit from public.teletip_gonderim where id = @p0", [id],
                o => new { mesaj = o.Metin("mesaj").Replace("\r", "\n"), yanit = o.Metin("yanit").Replace("\r", "\n") }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Gönderim bulunamadı.");
            return Results.Ok(s);
        });

        // Yeniden gönder: reddedilen (AE) / gidemez / ulaşmadı satırı düzeltme sonrası şimdi dener.
        grup.MapPost("/gonderim/{id:long}/dene", async (long id, VeriKaynagi veri, TeletipOrmServisi servis, BaglamCozucu cozucu,
                                                         HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip", Islem.Degistir);
            var n = await veri.CalistirAsync(
                "update public.teletip_gonderim set durum = 0, sonraki_deneme = now() where id = @p0 and durum in (0, 2, 3, 5)", [id], iptal);
            if (n == 0) throw GentegreHatasi.Dogrulama("Bu gönderim yeniden denenemez (gönderilmiş ya da atlanmış).");
            var s = await servis.DeneAsync(id, iptal);
            return Results.Ok(new { s.GonderimId, s.Durum, s.AckKodu, s.Hata, izlemeNo = baglam.IzlemeNo });
        });

        // Önizleme: istemin şu anki verisiyle kurulacak NW mesajı ve eksik listesi (göndermez).
        grup.MapGet("/istem/{istemId:int}/onizle", async (int istemId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var json = await b.TekDegerAsync<string>("select public.fn_teletip_orm_verisi(@p0)::text", null, [istemId], iptal)
                       ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");
            var v = (JsonSerializer.Deserialize<OrmVerisi>(json, JsonAyar) ?? new OrmVerisi()) with
            {
                FirmaKodu = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.firma_kodu", "", iptal),
                KontrolNo = "ONIZLEME",
            };
            return Results.Ok(new { eksikler = OrmUretici.Denetle(v), mesaj = OrmUretici.Uret(v).Replace("\r", "\n") });
        });
    }

    private static async Task<bool> AktifAsync(VeriKaynagi veri, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.aktif", "0", iptal) == "1";
    }
}
