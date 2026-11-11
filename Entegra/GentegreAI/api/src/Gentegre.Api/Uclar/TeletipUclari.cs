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

        // ---------------------------------------------------------- PANO (mockup §2; kullanıcı 11.11.2026 "Mirth panosunu yap")
        // Günün özeti (şube saatine göre gün), bekleyen kuyruk, son olaylar ve Mirth kanal istatistikleri. Mirth erişilemezse
        //   DB bölümü yine gelir - pano "Mirth'e ulaşılamadı" der, boş kalmaz.
        grup.MapGet("/pano", async (string? gun, VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.pano", Islem.Gor);
            DateTime? g = DateTime.TryParse(gun, System.Globalization.CultureInfo.InvariantCulture,
                                            System.Globalization.DateTimeStyles.None, out var d) ? d.Date : null;
            await using var b = await veri.AcAsync(iptal);
            var ozet = (await b.ListeAsync("""
                with p as (select public.fn_sube_zaman_dilimi(@p1) as tz),
                     g as (select coalesce(@p0::date, (now() at time zone p.tz)::date) as gun, p.tz from p),
                     t as (select x.* from public.teletip_gonderim x, g
                            where (x.ekleme_tarihi at time zone g.tz)::date = g.gun and x.kanal = 1)
                select (select gun from g) as gun,
                       (select count(*) from t where emir = 1)                     as "nwToplam",
                       (select count(*) from t where emir = 1 and durum = 1)       as "nwGonderildi",
                       (select count(*) from t where emir in (2, 3))               as "xoCaToplam",
                       (select count(*) from t where emir in (2, 3) and durum = 1) as "xoCaGonderildi",
                       (select count(*) from t where durum = 2)                    as reddedildi,
                       (select count(*) from t where durum = 3)                    as gidemez,
                       (select count(*) from public.teletip_gonderim where durum in (0, 5)) as kuyrukta,
                       (select coalesce(floor(extract(epoch from now() - min(ekleme_tarihi)) / 60), 0)::int
                          from public.teletip_gonderim where durum in (0, 5)) as "enEskiDk",
                       (select count(*) from public.teletip_gonderim where durum in (2, 3)) as "sorunluToplam"
                """, null, [g, baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal)).First();
            var sonOlaylar = await b.ListeAsync("""
                select t.id, t.istem_id as "istemId", t.accession_no as "accessionNo", t.emir, t.durum, t.ack_kodu as "ackKodu",
                       left(t.hata_metni, 200) as hata, coalesce(t.son_deneme, t.ekleme_tarihi) as zaman,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as "hastaAdi"
                  from public.teletip_gonderim t
                  left join public.radyoloji_istem i on i.id = t.istem_id
                  left join public.taraf h on h.id = i.hasta_id
                 order by coalesce(t.son_deneme, t.ekleme_tarihi) desc, t.id desc
                 limit 10
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var adres = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.hl7_adres", "", iptal);
            var aktif = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.aktif", "0", iptal) == "1";
            return Results.Ok(new { aktif, hl7Adres = adres, ozet, sonOlaylar, mirth = await mirth.DurumAsync(iptal) });
        });

        // Bağlantı testi: Teletıp HL7 hedefine (Mirth K1) TCP + Mirth REST girişi. Mesaj göndermez.
        grup.MapPost("/baglanti-testi", async (VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var adres = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.hl7_adres", "", iptal);
            var tcp = adres.Length == 0 ? (Acik: false, Hata: "teletip.hl7_adres tanımlı değil.", SureMs: 0)
                                        : await MirthIzleme.TcpDeneAsync(adres, iptal);
            var m = await mirth.DurumAsync(iptal);
            return Results.Ok(new
            {
                hl7 = new { adres, acik = tcp.Acik, hata = tcp.Hata, sureMs = tcp.SureMs },
                mirth = new { m.Tanimli, m.Erisilebilir, m.Hata, m.Surum, kanalSayisi = m.Kanallar.Count },
            });
        });

        // Toplu yeniden gönder: sorunlu (reddedildi / gidemez) ve ulaşmadı satırlarını şimdi yeniden dener. Gidemez satır
        //   denetimden geçemezse yine gidemez kalır; reddedilen, düzeltilmediyse yine reddedilir - kullanıcı bilerek basar.
        grup.MapPost("/yeniden-gonder-toplu", async (VeriKaynagi veri, TeletipOrmServisi servis, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.pano", Islem.Degistir);
            var n = await veri.CalistirAsync(
                "update public.teletip_gonderim set durum = 0, sonraki_deneme = now() where durum in (2, 3, 5)", [], iptal);
            var gonderilen = n > 0 ? await servis.SiradakileriIsleAsync(200, iptal) : 0;
            var kalan = await veri.TekDegerAsync<long>("select count(*) from public.teletip_gonderim where durum in (2, 3, 5)", []);
            return Results.Ok(new { denenen = n, gonderilen, sorunluKalan = kalan, izlemeNo = baglam.IzlemeNo });
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
