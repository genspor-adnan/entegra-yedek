using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BAKANLIK TELERADYOLOJİ PROFİLİ (809–812) — gönderim öncesi kontrol.
///
/// T.C. Sağlık Bakanlığı Teletıp/Teleradyoloji Entegrasyon Kılavuzu 3.46 bir
/// ORU mesajını eksik alan yüzünden reddediyor: hekim TCKN'si yoksa, modalite
/// iki harf değilse, Bulgular 50 karakterden kısaysa, accession boşsa mesaj
/// geri döner. <b>Reddi gönderim anında öğrenmek geçtir</b> - rapor o noktada
/// çoktan onaylanmış ve kilitlenmiş olur.
///
/// Bu uç aynı soruyu ÖNCEDEN sorar ve eksikleri tek listede verir. Kural
/// veritabanında (<c>fn_telerad_bakanlik_eksik</c>); burada yalnız okunur -
/// ileride ORU üreticisi de aynı işlevi çağıracak, iki ayrı "eksik mi" tanımı
/// olmayacak.
///
/// <b>Kapalı kurumda sessiz geçer:</b> `telerad_kurum.bakanlik_gonderim = 0`
/// ise eksik listesi boştur. Özel hastane müşterisi bu ekranı hiç görmez.
/// </summary>
public static partial class TeleradUclari
{
    private static void BakanlikUclariniEkle(RouteGroupBuilder grup)
    {
        // Tek isteğin Bakanlık hazırlığı: eksikler + mesaja girecek değerler.
        grup.MapGet("/istek/{id:int}/bakanlik", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("teleradyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            // ALANLAR HL7 ADIYLA DÖNÜYOR (OBR-18, ORC-12 …): ekranda hangi
            //   kutunun hangi alana gittiği görünsün - kurulumda karşı tarafla
            //   konuşulan dil budur.
            var satir = await baglanti.TekAsync("""
                select i.id,
                       i.istek_no                                  as "istekNo",
                       coalesce(k.bakanlik_gonderim, 0)            as "bakanlikAcik",
                       coalesce(k.skrs_kodu, '')                   as "skrsKodu",
                       coalesce(k.msh_uygulama, '')                as "mshUygulama",
                       coalesce(k.msh_tesis, '')                   as "mshTesis",
                       coalesce(k.msh_encoding, 1)                 as "mshEncoding",
                       coalesce(k.wado_adres, '')                  as "wadoAdres",
                       coalesce(i.dis_erisim_no, '')               as "accessionNo",
                       coalesce(i.dis_hasta_kimlik, '')            as "hastaTckn",
                       coalesce(i.isteyen_hekim, '')               as "isteyenHekim",
                       coalesce(i.isteyen_hekim_tckn, '')          as "isteyenHekimTckn",
                       public.fn_rad_modalite_kod(i.modalite)      as "modaliteKodu",
                       coalesce(i.study_uid, '')                   as "studyUid",
                       coalesce(hz.sut_kodu, '')                   as "sutKodu",
                       coalesce(hz.loinc, '')                      as "loinc",
                       i.rapor_id                                  as "raporId",
                       coalesce(rp.istem_nedeni_puan, 0)           as "istemNedeniPuan",
                       coalesce(rp.cekim_kalite_puan, 0)           as "cekimKalitePuan",
                       coalesce(t.vkno, '')                        as "radyologTckn",
                       coalesce(t.unvan, '')                       as "radyolog",
                       rp.onay_tarihi                              as "onayTarihi",
                       case when i.radyoloji_istem_id is null then ''
                            else public.fn_rad_kontrast_obx17(i.radyoloji_istem_id) end
                                                                   as "kontrastObx17",
                       coalesce(er.sys_takip_no, '')               as "sysTakipNo",
                       coalesce(er.hastane_referans, '')           as "hastaneReferans",
                       public.fn_telerad_bakanlik_eksik(i.id)      as "eksik"
                  from public.telerad_istek i
                  join public.telerad_kurum k on k.id = i.kurum_id
                  left join public.hizmet hz on hz.id = i.tetkik_hizmet_id
                  left join public.radyoloji_istem ri on ri.id = i.radyoloji_istem_id
                  left join public.radyoloji_rapor rp on rp.id = i.rapor_id
                  left join public.taraf t on t.id = rp.onaylayan_id
                  left join lateral public.fn_enabiz_basvuru_referans(ri.belge_id) er on true
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstek bulunamadı.");

            // Rapor gövdesinin dört parçası: hangisi dolu, Bulgular kaç karakter.
            //   Radyolog "neyi eksik bıraktım" sorusunu burada görür.
            var parcalar = satir["raporId"] is null
                ? new List<IDictionary<string, object?>>()
                : await baglanti.ListeAsync("""
                    select p.parca,
                           case p.parca when 1 then 'Teknik'
                                        when 2 then 'Karşılaştırma'
                                        when 3 then 'Bulgular'
                                        else 'Sonuç ve Öneriler' end            as ad,
                           coalesce(sum(length(btrim(coalesce(b.metin, '')))), 0) as uzunluk
                      from (values (1), (2), (3), (4)) as p(parca)
                      left join public.radyoloji_rapor_bolum b
                             on b.rapor_id = @p0 and b.bakanlik_parca = p.parca
                     group by p.parca order by p.parca
                    """, null, [Convert.ToInt32(satir["raporId"])],
                    OkuyucuGenisletmeleri.Sozluk, iptal);

            var eksik = satir["eksik"] as string ?? "";
            return Results.Ok(new
            {
                istek = satir,
                parcalar,
                gonderilebilir = Convert.ToInt32(satir["bakanlikAcik"] ?? 0) == 1 && eksik.Length == 0,
                eksik,
            });
        });

        // ------------------------------------------------------- TESLİM ----
        // TEK DÜĞME, YOLU SUNUCU SEÇER. Kurumun teslim kanalı HL7 ORU ise iş
        //   kuyruğa girer ve mesaj gönderilir; kanal "Portal" ise teslim
        //   damgasından ibarettir (kurum raporu kendi ekranından alır).
        //   Seçimi istemciye bırakmak, aynı kuralın iki yerde yaşaması
        //   demekti - ekran kanal bilmez.
        grup.MapPost("/istek/{id:int}/teslim", async (
            int id, short? hedef, bool? hemen, BaglamCozucu cozucu, VeriKaynagi veri,
            TeleradTeslimServisi teslim, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("telerad.teslim");

            await using var b = await veri.AcAsync(iptal);
            var kanal = await b.TekDegerAsync<int>("""
                select coalesce(k.hl7_tur, 0)
                  from public.telerad_istek i
                  join public.telerad_kurum k on k.id = i.kurum_id
                 where i.id = @p0
                """, null, [id], iptal);

            if (kanal != 1)
            {
                // PORTAL TESLİMİ: damga SUNUCUDA yazılır. Durum akışı ve
                //   teslim zamanı tetikte (799) - ekran "durum 7" göndermez.
                await b.CalistirAsync("""
                    update public.telerad_istek
                       set durum = 7, degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0 and durum between 1 and 6
                    """, null, [id, baglam.KullaniciId], iptal);
                return Results.Ok(new { yol = "portal", basarili = true });
            }

            var teslimId = await teslim.KuyruklaAsync(id, hedef ?? 1, baglam.KullaniciId, iptal);

            // HEMEN DENEMEK VARSAYILAN: kullanıcı düğmeye bastıysa sonucu
            //   şimdi görmek ister; başarısızsa iş kuyrukta kalır ve işçi
            //   artan aralıkla tekrar dener.
            if (hemen is false)
                return Results.Ok(new { yol = "kuyruk", teslimId, denendi = false });

            var sonuc = await teslim.DeneAsync(teslimId, iptal);
            return Results.Ok(new
            {
                yol = "kuyruk", teslimId, denendi = true,
                sonuc.Basarili, sonuc.AckKodu, sonuc.Hata, sonuc.Durum,
            });
        });

        // YENİDEN DENE: kuyruk ekranındaki satır için. Kalıcı hataya düşmüş
        //   (AE) satır da buradan zorlanabilir - düzeltme yapıldıysa.
        grup.MapPost("/teslim/{teslimId:long}/dene", async (
            long teslimId, BaglamCozucu cozucu, TeleradTeslimServisi teslim,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("telerad.teslim_kuyruk");

            await using (var b = await veri.AcAsync(iptal))
                await b.CalistirAsync(
                    "update public.telerad_teslim set durum = 1, "
                    + "sonraki_deneme = now()::timestamp where id = @p0 and durum <> 3",
                    null, [teslimId], iptal);

            var sonuc = await teslim.DeneAsync(teslimId, iptal);
            return Results.Ok(new { sonuc.Basarili, sonuc.AckKodu, sonuc.Hata, sonuc.Durum });
        });

        // İPTAL: gönderilmeyecek iş kuyrukta durup her gün yeniden denenmesin.
        grup.MapPost("/teslim/{teslimId:long}/iptal", async (
            long teslimId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("telerad.teslim_kuyruk");

            await using var b = await veri.AcAsync(iptal);
            await b.CalistirAsync("""
                update public.telerad_teslim
                   set durum = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum <> 3
                """, null, [teslimId, baglam.KullaniciId], iptal);
            return Results.Ok(new { tamam = true });
        });

        // DENEME GEÇMİŞİ: ham ORU ve ham ACK ile. "Ne gönderdik, ne aldık"
        //   sorusu aylar sonra soruluyor (814).
        grup.MapGet("/teslim/{teslimId:long}/iz", async (
            long teslimId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("teleradyoloji", Islem.Gor);

            await using var b = await veri.AcAsync(iptal);
            var satirlar = await b.ListeAsync("""
                select z.id, z.deneme_no as "denemeNo", z.zaman, z.sonuc,
                       z.ack_kodu as "ackKodu", z.hata_metni as "hata",
                       z.sure_ms as "sureMs",
                       z.istek_govde as "istekGovde", z.yanit_govde as "yanitGovde"
                  from public.telerad_teslim_iz z
                 where z.teslim_id = @p0
                 order by z.id desc
                """, null, [teslimId], OkuyucuGenisletmeleri.Sozluk, iptal);
            return Results.Ok(new { satirlar });
        });

        // --------------------------------------------------- GELEN RAPOR ----
        // ELLE BAĞLA: accession tutmadığı için eşleşmemiş raporu doğru işe
        //   bağlar ve yeniden işler. Eşleştirme kuralı gevşetilmiyor - yanlış
        //   hastaya rapor yazma riski insan kararına bırakılıyor.
        grup.MapPost("/gelen/{gelenId:long}/bagla", async (
            long gelenId, int istekId, BaglamCozucu cozucu, TeleradGelenServisi gelen,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("telerad.gelen");

            var sonuc = await gelen.ElleBaglaAsync(gelenId, istekId, iptal);
            return Results.Ok(new { sonuc.Durum, sonuc.Mesaj });
        });

        // HAM MESAJ: "ne geldi" sorusunun cevabı. Çözümlenemeyen mesajda tek
        //   kaynak budur.
        grup.MapGet("/gelen/{gelenId:long}", async (
            long gelenId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("teleradyoloji", Islem.Gor);

            await using var b = await veri.AcAsync(iptal);
            var satir = await b.TekAsync("""
                select g.id, g.kontrol_no as "kontrolNo", g.geldi_zamani as "geldiZamani",
                       g.kaynak_ip as "kaynakIp", g.accession_no as "accessionNo",
                       g.hasta_tckn as "hastaTckn", g.radyolog_ad as "radyologAd",
                       g.radyolog_tckn as "radyologTckn", g.onay_zamani as "onayZamani",
                       g.durum, g.hata_metni as "hata", g.istek_id as "istekId",
                       g.rapor_id as "raporId", g.ham
                  from public.telerad_gelen g where g.id = @p0
                """, null, [gelenId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Gelen rapor bulunamadı.");
            return Results.Ok(satir);
        });

        // Eksik listesi AYRI UÇ DEĞİL: `telerad-bakanlik-eksik` kaynağı
        //   (813 görünümü) liste altyapısından geçiyor - yetki, şube süzgeci,
        //   sayfalama ve dışa aktarım orada zaten var. İkinci bir uç yazmak
        //   aynı kuralı iki yerde tutmak olurdu.
    }
}
