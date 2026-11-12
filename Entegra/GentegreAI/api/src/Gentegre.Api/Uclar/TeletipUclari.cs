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
        grup.MapGet("/pano", async (string? gun, VeriKaynagi veri, MirthIzleme mirth, Gentegre.Api.Servisler.TeletipWadoServisi wadoServis,
                                    BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
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
                            where (x.ekleme_tarihi at time zone g.tz)::date = g.gun and x.kanal in (1, 2, 3))
                select (select gun from g) as gun,
                       (select count(*) from t where kanal = 1 and emir = 1)                     as "nwToplam",
                       (select count(*) from t where kanal = 1 and emir = 1 and durum = 1)       as "nwGonderildi",
                       (select count(*) from t where kanal = 1 and emir in (2, 3))               as "xoCaToplam",
                       (select count(*) from t where kanal = 1 and emir in (2, 3) and durum = 1) as "xoCaGonderildi",
                       (select count(*) from t where kanal = 1 and emir = 4)                     as "oruToplam",
                       (select count(*) from t where kanal = 1 and emir = 4 and durum = 1)       as "oruGonderildi",
                       (select count(*) from t where kanal = 2)                                  as "kosToplam",
                       (select count(*) from t where kanal = 2 and durum = 1)                    as "kosGonderildi",
                       (select count(*) from t where kanal = 3)                                  as "dozToplam",
                       (select count(*) from t where kanal = 3 and durum = 1)                    as "dozGonderildi",
                       (select count(*) from t where durum = 2)                    as reddedildi,
                       (select count(*) from t where durum = 3)                    as gidemez,
                       (select count(*) from public.teletip_gonderim where durum in (0, 5)) as kuyrukta,
                       (select coalesce(floor(extract(epoch from now() - min(ekleme_tarihi)) / 60), 0)::int
                          from public.teletip_gonderim where durum in (0, 5)) as "enEskiDk",
                       (select count(*) from public.teletip_gonderim where durum in (2, 3)) as "sorunluToplam"
                """, null, [g, baglam.SubeId ?? 0], OkuyucuGenisletmeleri.Sozluk, iptal)).First();
            var sonOlaylar = await b.ListeAsync("""
                select t.id, t.istem_id as "istemId", t.accession_no as "accessionNo", t.kanal, t.emir, t.durum, t.ack_kodu as "ackKodu",
                       left(t.hata_metni, 200) as hata, coalesce(t.son_deneme, t.ekleme_tarihi) as zaman,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '') as "hastaAdi"
                  from public.teletip_gonderim t
                  left join public.radyoloji_istem i on i.id = t.istem_id
                  left join public.taraf h on h.id = i.hasta_id
                 order by coalesce(t.son_deneme, t.ekleme_tarihi) desc, t.id desc
                 limit 10
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            // 1317: TeleRadyoloji hesabı (oturum şubesi → kurum geneli); hesap modeli yoksa eski teletip.* ayarları.
            var adres = (await TeleRadyolojiHesabi.OkuAsync(b, null, baglam.SubeId ?? 0, iptal))?.Hl7Adres ?? "";
            var aktif = await b.TekDegerAsync<bool>("select public.fn_teletip_aktif()", null, [], iptal);
            // Dışa açık WADO (1313): yapılandırma + bugünün / son 7 günün erişim sayacı (IP + çalışma bazında).
            var w = wadoServis.Ayar;
            var wadoSayac = (await b.ListeAsync("""
                select coalesce(sum(istek_sayisi) filter (where gun = (now() at time zone 'Europe/Istanbul')::date), 0)::int as "bugunIstek",
                       coalesce(sum(hata_sayisi)  filter (where gun = (now() at time zone 'Europe/Istanbul')::date), 0)::int as "bugunHata",
                       coalesce(sum(istek_sayisi), 0)::int as "haftaIstek",
                       count(distinct study_uid) filter (where study_uid <> '-')::int as "haftaCalisma",
                       count(distinct ip)::int as "haftaIp",
                       max(son_erisim) as "sonErisim"
                  from public.teletip_wado_erisim
                 where gun >= (now() at time zone 'Europe/Istanbul')::date - 6
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal)).First();
            var wadoSonHata = await b.ListeAsync("""
                select ip, study_uid as "studyUid", son_hata as hata, son_erisim as zaman
                  from public.teletip_wado_erisim where hata_sayisi > 0 and son_hata <> ''
                 order by son_erisim desc limit 5
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
            var wado = new
            {
                acik = w.Port > 0, port = w.Port, https = w.SertifikaYolu.Length > 0, yol = w.Yol,
                ipSiniri = w.IzinliIpler.Length > 0, sayac = wadoSayac, sonHatalar = wadoSonHata,
            };
            return Results.Ok(new { aktif, hl7Adres = adres, ozet, sonOlaylar, mirth = await mirth.DurumAsync(iptal), wado });
        });

        // Bağlantı testi: Teletıp HL7 hedefine (Mirth K1) TCP + Mirth REST girişi. Mesaj göndermez.
        grup.MapPost("/baglanti-testi", async (VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            // Pano ya da ayar ekranı yetkisi yeter (ikisinde de düğme var).
            if (!baglam.Yetkiler.Var("radyoloji.teletip.pano", Islem.Gor) && !baglam.Yetkiler.Var("radyoloji.teletip.ayar", Islem.Gor))
                throw GentegreHatasi.Yasak();
            await using var b = await veri.AcAsync(iptal);
            var adres = (await TeleRadyolojiHesabi.OkuAsync(b, null, baglam.SubeId ?? 0, iptal))?.Hl7Adres ?? "";
            var tcp = adres.Length == 0 ? (Acik: false, Hata: "Bu şubede TeleRadyoloji hesabı / K1 adresi yok.", SureMs: 0)
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
            var sube = await b.TekDegerAsync<int?>("select sube_id from public.radyoloji_istem where id = @p0", null, [istemId], iptal) ?? 0;
            // Kuyruk işçisiyle aynı birleştirme (KurumKimlik.Uygula) - önizleme gönderilecek mesajın aynısı.
            var h = await TeleRadyolojiHesabi.OkuAsync(b, null, sube, iptal) ?? new TeleRadyolojiHesabi();
            var k = await KurumKimlik.OkuAsync(b, null, sube, iptal);
            var v = k.Uygula(JsonSerializer.Deserialize<OrmVerisi>(json, JsonAyar) ?? new OrmVerisi(), h) with { KontrolNo = "ONIZLEME" };
            return Results.Ok(new { eksikler = OrmUretici.Denetle(v), mesaj = OrmUretici.Uret(v).Replace("\r", "\n") });
        });
    }

    private static async Task<bool> AktifAsync(VeriKaynagi veri, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await b.TekDegerAsync<bool>("select public.fn_teletip_aktif()", null, [], iptal);   // 1317
    }
}
