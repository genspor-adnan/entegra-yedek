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

        // ---------------------------------------------------------- AYAR (mockup §5; kullanıcı 11.11.2026 "kurum Teletıp ayar ekranını yap")
        // Kurumun Teletıp kimliği ve Mirth K1 bağlantısı. Yazılanlar: referans (teletip.aktif / hl7_adres / firma_kodu /
        //   encoding / sube_no, kurum.skrs_kodu) ve kurum_profil (şube 0) tesis_kodu. Mirth REST ve Mirth'teki Teletıp
        //   hedefi YALNIZ GÖRÜNTÜLENİR (API ortam değişkeni / Mirth configuration map). Yetki radyoloji.teletip.ayar.
        grup.MapGet("/ayar", async (VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.ayar", Islem.Gor);
            return Results.Ok(await AyarOkuAsync(veri, mirth, iptal));
        });

        grup.MapPut("/ayar", async (TeletipAyarIstegi istek, VeriKaynagi veri, MirthIzleme mirth, BaglamCozucu cozucu,
                                    HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji.teletip.ayar", Islem.Degistir);
            var hatalar = new List<AlanHatasi>();
            string T(string? v) => (v ?? "").Trim();
            var skrs = T(istek.KurumSkrs); var tesis = T(istek.MedulaTesisKodu); var sube = T(istek.SubeNo);
            var firma = T(istek.FirmaKodu); var adres = T(istek.Hl7Adres);
            var kodlama = T(istek.Encoding) is "Windows1254" ? "Windows1254" : "UTF8";
            var xds = T(istek.XdsAdres); var oid = T(istek.XdsHastaOid);
            if (xds.Length > 0 && !Uri.TryCreate(xds, UriKind.Absolute, out _))
                hatalar.Add(new AlanHatasi("xdsAdres", "Tam adres olmalı (ör. http://10.0.0.12:8082/kos/)."));
            if (oid.Length > 0 && !System.Text.RegularExpressions.Regex.IsMatch(oid, @"^[0-2](\.[0-9]+)+$"))
                hatalar.Add(new AlanHatasi("xdsHastaOid", "OID biçiminde olmalı (Bakanlık: 1.3.6.1.4.1.21367.13.20.3000)."));
            if (skrs.Length > 0 && !System.Text.RegularExpressions.Regex.IsMatch(skrs, "^[0-9]{1,10}$"))
                hatalar.Add(new AlanHatasi("kurumSkrs", "Yalnız rakam (SKRS kurum kodu)."));
            if (tesis.Length > 0 && !System.Text.RegularExpressions.Regex.IsMatch(tesis, "^[0-9]{8}$"))
                hatalar.Add(new AlanHatasi("medulaTesisKodu", "8 haneli sayı olmalı."));
            if (!System.Text.RegularExpressions.Regex.IsMatch(sube, "^[0-9]{1,4}$"))
                hatalar.Add(new AlanHatasi("subeNo", "Rakam olmalı (genelde 1)."));
            if (firma.Length > 60) hatalar.Add(new AlanHatasi("firmaKodu", "En fazla 60 karakter."));
            if (adres.Length > 0 && !System.Text.RegularExpressions.Regex.IsMatch(adres, @"^[A-Za-z0-9.\-]+:[0-9]{1,5}$"))
                hatalar.Add(new AlanHatasi("hl7Adres", "host:port biçiminde olmalı (ör. 10.0.0.12:6661)."));
            // Açmak için kimlik tam olmalı: eksik kimlikle açılan gönderim her mesajı "gidemez"e düşürür.
            if (istek.Aktif)
            {
                if (skrs.Length == 0) hatalar.Add(new AlanHatasi("kurumSkrs", "Gönderimi açmak için zorunlu."));
                if (tesis.Length == 0) hatalar.Add(new AlanHatasi("medulaTesisKodu", "Gönderimi açmak için zorunlu."));
                if (firma.Length == 0) hatalar.Add(new AlanHatasi("firmaKodu", "Gönderimi açmak için zorunlu."));
                if (adres.Length == 0) hatalar.Add(new AlanHatasi("hl7Adres", "Gönderimi açmak için zorunlu."));
            }
            if (hatalar.Count > 0) throw GentegreHatasi.Dogrulama("Teletıp ayarları kaydedilemedi.", [.. hatalar]);

            await using var b = await veri.AcAsync(iptal);
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var (anahtar, deger, tip) in new[]
            {
                ("teletip.aktif", istek.Aktif ? "1" : "0", "sayi"), ("teletip.hl7_adres", adres, "metin"),
                ("teletip.firma_kodu", firma, "metin"), ("teletip.encoding", kodlama, "metin"),
                ("teletip.sube_no", sube, "metin"), ("kurum.skrs_kodu", skrs, "metin"),
                ("teletip.xds_adres", xds, "metin"), ("teletip.xds_hasta_oid", oid, "metin"),
            })
                await b.CalistirAsync("""
                    insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
                    values (@p0, @p1, @p2, 'firma', @p3, now()::timestamp)
                    on conflict (anahtar) do update set deger = excluded.deger, degistiren = excluded.degistiren,
                           degistirme_tarihi = excluded.degistirme_tarihi
                    """, islem, [anahtar, deger, tip, baglam.KullaniciId], iptal);
            // MEDULA tesis kodu: kurum profilinin GENEL satırı (şube 0) - ORM / ORU önce isteğin şubesinin satırına,
            //   boşsa buna bakar. Genel satır yoksa AÇILMAZ: o satır ürün modunu da taşır (fn_urun_modu, varsayılan 2
            //   HBYS) - buradan açmak bir ERP kurulumunu sessizce HBYS'ye çevirirdi.
            var n = await b.CalistirAsync(
                "update public.kurum_profil set tesis_kodu = @p0, degistiren = @p1, degistirme_tarihi = now() where sube_id = 0",
                islem, [tesis, baglam.KullaniciId], iptal);
            if (n == 0 && tesis.Length > 0)
                throw GentegreHatasi.Dogrulama("Kurum profili (genel satır) yok - önce kurum profili / kurulum sihirbazı tamamlanmalı.",
                    new AlanHatasi("medulaTesisKodu", "Kurum profili yok."));
            await islem.CommitAsync(iptal);
            return Results.Ok(await AyarOkuAsync(veri, mirth, iptal));
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
                            where (x.ekleme_tarihi at time zone g.tz)::date = g.gun and x.kanal in (1, 2))
                select (select gun from g) as gun,
                       (select count(*) from t where kanal = 1 and emir = 1)                     as "nwToplam",
                       (select count(*) from t where kanal = 1 and emir = 1 and durum = 1)       as "nwGonderildi",
                       (select count(*) from t where kanal = 1 and emir in (2, 3))               as "xoCaToplam",
                       (select count(*) from t where kanal = 1 and emir in (2, 3) and durum = 1) as "xoCaGonderildi",
                       (select count(*) from t where kanal = 1 and emir = 4)                     as "oruToplam",
                       (select count(*) from t where kanal = 1 and emir = 4 and durum = 1)       as "oruGonderildi",
                       (select count(*) from t where kanal = 2)                                  as "kosToplam",
                       (select count(*) from t where kanal = 2 and durum = 1)                    as "kosGonderildi",
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
            var adres = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.hl7_adres", "", iptal);
            var aktif = await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.aktif", "0", iptal) == "1";
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

    /// <summary>PUT /api/teletip/ayar gövdesi.</summary>
    public sealed record TeletipAyarIstegi(bool Aktif, string? KurumSkrs, string? MedulaTesisKodu, string? SubeNo,
                                           string? FirmaKodu, string? Encoding, string? Hl7Adres,
                                           string? XdsAdres = null, string? XdsHastaOid = null);

    /// <summary>Ayar ekranı verisi: DB ayarları + şube bazlı tesis kodları + Mirth (yalnız görüntü) + test değeri uyarıları.</summary>
    private static async Task<object> AyarOkuAsync(VeriKaynagi veri, MirthIzleme mirth, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        async Task<string> R(string a, string v) => await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, a, v, iptal);
        var aktif = await R("teletip.aktif", "0") == "1";
        var skrs = await R("kurum.skrs_kodu", "");
        var firma = await R("teletip.firma_kodu", "");
        var tesis = await b.TekDegerAsync<string>(
            "select coalesce(tesis_kodu, '') from public.kurum_profil where sube_id = 0 limit 1", null, [], iptal) ?? "";
        // Şubeye özel tesis kodu genel satırı ezer (ORM / ORU önce şubeye bakar) - ekranda görünsün.
        var subeTesisleri = await b.ListeAsync("""
            select kp.sube_id as "subeId", coalesce(s.ad, '') as "subeAdi", kp.tesis_kodu as "tesisKodu"
              from public.kurum_profil kp left join public.sube s on s.id = kp.sube_id
             where kp.sube_id <> 0 and coalesce(kp.tesis_kodu, '') <> '' order by kp.sube_id
            """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);
        var uyarilar = new List<string>();
        if (skrs == "999999") uyarilar.Add("Kurum SKRS kodu TEST değeri (999999) - gerçek Bakanlık bağlantısından önce değiştirin.");
        if (tesis == "99999999") uyarilar.Add("MEDULA tesis kodu TEST değeri (99999999).");
        if (firma.Contains("TEST", StringComparison.OrdinalIgnoreCase)) uyarilar.Add("Firma kodu TEST değeri gibi görünüyor.");
        var m = mirth.Ozet();
        return new
        {
            aktif, kurumSkrs = skrs, medulaTesisKodu = tesis, subeNo = await R("teletip.sube_no", "1"), firmaKodu = firma,
            encoding = await R("teletip.encoding", "UTF8"), hl7Adres = await R("teletip.hl7_adres", ""),
            xdsAdres = await R("teletip.xds_adres", ""), xdsHastaOid = await R("teletip.xds_hasta_oid", ""),
            subeTesisleri, uyarilar,
            mirth = new { url = m.Url, kullanici = m.Kullanici, parolaTanimli = m.ParolaTanimli, sertifikaDogrula = m.SertifikaDogrula,
                          harita = await mirth.TeletipHaritasiAsync(iptal) },
        };
    }

    private static async Task<bool> AktifAsync(VeriKaynagi veri, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await Gentegre.Veri.Depolar.AyarDeposu.MetinAsync(b, null, "teletip.aktif", "0", iptal) == "1";
    }
}
