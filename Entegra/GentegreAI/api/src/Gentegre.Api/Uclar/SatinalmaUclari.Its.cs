using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MAL KABUL — İTS BİLDİRİMİ UÇLARI (736).
///
/// OKUTMA BİLDİRİM DEĞİLDİR. Karekod okutulunca satır `its_bildirim`e
/// TASLAK (durum 0) olarak yazılır; İTS işçisi yalnız durum 1 (bekliyor) ve
/// 4 (hatalı) olanları alır. Okutulan her kutuyu anında kuyruğa atsaydık,
/// sayım sürerken yarım bir sevkiyat bildirilmiş olurdu - üstelik muayene
/// bitmeden hangi kutunun kabul edildiği belli değil.
///
/// ============ REDDEDİLEN KALEMİN KUTUSU BİLDİRİLMEZ ==================
/// Kısmi kabulde bazı kalemler geri gider. O kalemlerin kutularını da
/// bildirseydik, elimizde olmayan ilaçları "aldım" diye bildirmiş olurduk -
/// İTS'te bizim envanterimize geçer ve sonra tüketilemeyen, iade edilemeyen
/// kutular olarak kalırdı. Kuyruğa alırken bu kutular AYRI bir bildirime
/// (durum 5 = iptal) taşınır: okutulmuş olmaları kayıtta kalır, bildirime
/// girmezler. Silseydik "bu kutu okutuldu mu" sorusu yanıtsız kalırdı.
///
/// ============ BİLDİRİM TUTANAĞIN KUTULARINI TAŞIR ====================
/// Taslak bildirim BELGEYE bağlıdır, satırları MUAYENEYE. Aynı irsaliyenin
/// ikinci bir tutanağının kutuları - ya da tutanağı silinmiş, sahipsiz kalmış
/// kutular - aynı taslakta durabilir. Kuyruğa alırken bunlar önce AYRI BİR
/// TASLAĞA çıkarılır: bu kararın kapsamında değiller, sırası gelmemiş
/// kutulardır. Çıkarmasaydık (ve bir süre öyleydi) başka bir muayenenin
/// kutuları İTS'e mal alımı olarak giderdi.
///
/// ============ KAPI KAPALIYSA SÖYLENİR ================================
/// İTS hesabı tanımlı değilse bildirim yine KUYRUĞA ALINIR ve durum böyle
/// bildirilir. Sessizce başarılı saysaydık kurum bildirim yapıldığını sanırdı;
/// kuyruğa hiç almasaydık hesap tanımlandığı gün geçmiş kabuller kaybolurdu.
/// </summary>
public static partial class SatinalmaUclari
{
    /// <summary>islem_log.tablo_id - İTS bildirimi.</summary>
    private const int LogItsBildirim = 1255;

    public sealed class ItsGonderIstegi
    {
        /// <summary>Gönderen deponun GLN'i (İTS mal alımda ister).</summary>
        public string? KarsiGln { get; set; }
        /// <summary>Kuyruğa almakla kalma, hemen göndermeyi de dene.</summary>
        public bool SimdiGonder { get; set; }
    }

    public sealed class ItsIptalIstegi
    {
        public int BildirimId { get; set; }
        public string? Gerekce { get; set; }
    }

    // ============================================================ kayıt ==
    private static void ItsUclari(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------ durum ----
        grup.MapGet("/kabul/{id:long}/its", async (
            long id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var bildirimler = await baglanti.ListeAsync("""
                select v.id, v.durum, v.test_mi as "testMi", v.karsi_gln as "karsiGln",
                       v.its_bildirim_no as "itsBildirimNo", v.deneme,
                       v.son_deneme as "sonDeneme", v.hata_kodu as "hataKodu",
                       v.hata_mesaj as "hataMesaj", v.aciklama,
                       v.kutu, v.kalem, v.beklenmeyen, v.ekleme_tarihi as "acilis"
                  from public.v_kabul_its_bildirim v
                 where v.kabul_id = @p0 order by v.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KUTU KIRILIMI: mockup'taki "İlaç · Lot · Adet" satırı. Lot
            //   başına gruplanır - İTS'e giden şey kutu kutu olsa da insanın
            //   okuduğu şey "şu ilaçtan şu lottan kaç kutu".
            var kalemler = await baglanti.ListeAsync("""
                select b.bildirim_id as "bildirimId",
                       coalesce(nullif(s.ad, ''), b.ilac_barkod, '') as ad,
                       b.parti_no as "lot", b.son_kullanma as "skt",
                       count(*) as adet,
                       count(*) filter (where b.dogrulama = 2) as beklenmeyen
                  from public.its_bildirim_satir b
                  left join public.stok s on s.id = b.stok_id
                 where b.kabul_id = @p0
                 group by b.bildirim_id, coalesce(nullif(s.ad, ''), b.ilac_barkod, ''),
                          b.parti_no, b.son_kullanma
                 order by 2, 3
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // İTS hesabı tanımlı mı - ekran "gönderilecek mi" sorusunu
            //   yanıtlayabilsin. Hesap yoksa kuyruk durur ve sebebi budur.
            var hesap = await baglanti.TekAsync("""
                select e.aktif, e.test_mi as "testMi",
                       case when coalesce(e.sifre, '') = '' then 0 else 1 end as "sifreVar"
                  from public.entegrasyon_hesap e
                 where e.kod = 'ITS' and e.aktif = 1 limit 1
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                bildirimler, kalemler,
                hesapVar = hesap is not null,
                testMi = hesap is not null && Convert.ToInt16(hesap["testMi"] ?? (short)1) == 1,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // ------------------------------------------------- kuyruğa al ----
        grup.MapPost("/kabul/{id:long}/its-gonder", async (
            long id, ItsGonderIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.ItsServisi its, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);
            baglam.YetkiIste("stok", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.sonuc, k.belge_id as "belgeId", k.sube_id as "subeId",
                       (select count(*) from public.its_bildirim_satir b
                         where b.kabul_id = k.id) as "kutu"
                  from public.satinalma_kabul k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kabul tutanağı bulunamadı.");

            if (Convert.ToInt32(k["kutu"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali(
                    "Okutulmuş kutu yok - bildirilecek bir şey bulunamadı.");

            // MUAYENE BİTMEDEN BİLDİRİLMEZ: hangi kutunun kabul edildiği
            //   kararla belli olur. Açık tutanağı bildirseydik, sonra
            //   reddedilen kalemler İTS'te bizim envanterimizde kalırdı.
            var sonuc = Convert.ToInt16(k["sonuc"] ?? (short)0);
            if (sonuc == 0)
                throw GentegreHatasi.IsKurali(
                    "Muayenesi tamamlanmamış tutanak İTS'e bildirilemez.");
            if (sonuc == 3)
                throw GentegreHatasi.IsKurali(
                    "Tamamı reddedilen sevkiyat mal alımı olarak bildirilmez.");

            var taslak = await baglanti.TekDegerAsync<int?>("""
                select v.id from public.v_kabul_its_bildirim v
                 where v.kabul_id = @p0 and v.durum in (0, 4) order by v.id desc limit 1
                """, null, [id], iptal);

            if (taslak is null)
            {
                var zaten = await baglanti.TekDegerAsync<int?>("""
                    select v.id from public.v_kabul_its_bildirim v
                     where v.kabul_id = @p0 and v.durum in (1, 2, 3)
                     order by v.id desc limit 1
                    """, null, [id], iptal);
                throw zaten is not null
                    ? GentegreHatasi.IsKurali(
                        $"Bu tutanağın bildirimi ({zaten}) zaten kuyrukta ya da gönderilmiş.")
                    : GentegreHatasi.IsKurali("Kuyruğa alınacak taslak bildirim yok.");
            }

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // --- BU TUTANAĞA AİT OLMAYAN KUTULAR ÖNCE ÇIKARILIR.
            //
            //   Taslak bildirim BELGEYE bağlıdır, satır MUAYENEYE. Aynı
            //   irsaliyenin ikinci bir tutanağının kutuları - ya da tutanağı
            //   silindiği için sahipsiz kalmış kutular (`kabul_id` null) -
            //   aynı taslakta durabilir. Aşağıdaki ayıklama `kabul_id = bu
            //   tutanak` diye süzüyor ama kuyruğa alınan sayı bildirimin
            //   TAMAMIYDI: sonuçta bu kararın kapsamında olmayan, hatta
            //   "beklenmeyen" işaretli kutular İTS'e mal alımı olarak
            //   gidiyordu ve kullanıcıya tutanaktakinden fazla kutu sayısı
            //   söyleniyordu.
            //
            //   YENİ TASLAĞA taşınıyorlar, iptale değil: o kutular yanlış
            //   değil, SIRASI GELMEMİŞ. Kendi tutanağı karara bağlandığında
            //   o taslak kuyruğa alınır; sahipsizler de kayıtta kalır.
            var yabanci = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.its_bildirim_satir b
                 where b.bildirim_id = @p0 and b.kabul_id is distinct from @p1
                """, islem, [taslak, id], iptal);

            int? yabanciBildirim = null;
            if (yabanci > 0)
            {
                yabanciBildirim = await baglanti.TekDegerAsync<int>("""
                    insert into public.its_bildirim (tur, durum, sube_id, test_mi, belge_id,
                                                     karsi_gln, islem_tarihi, aciklama, ekleyen)
                    select b.tur, 0, b.sube_id, b.test_mi, b.belge_id, b.karsi_gln,
                           b.islem_tarihi,
                           'Baska tutanagin / sahipsiz kutulari - ayri taslak',
                           @p1
                      from public.its_bildirim b where b.id = @p0
                    returning id
                    """, islem, [taslak, baglam.KullaniciId], iptal);

                await baglanti.CalistirAsync("""
                    update public.its_bildirim_satir
                       set bildirim_id = @p2
                     where bildirim_id = @p0 and kabul_id is distinct from @p1
                    """, islem, [taslak, id, yabanciBildirim], iptal);
            }

            // --- REDDEDİLEN KALEMİN KUTULARI AYRILIR (bkz. dosya başlığı).
            var ayrilacak = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.its_bildirim_satir b
                 where b.bildirim_id = @p0 and b.kabul_id = @p1
                   and (b.dogrulama = 2
                        or exists (select 1 from public.satinalma_kabul_satir s
                                    where s.kabul_id = b.kabul_id
                                      and s.stok_id = b.stok_id and s.sonuc = 3))
                """, islem, [taslak, id], iptal);

            int? ayrikBildirim = null;
            if (ayrilacak > 0)
            {
                ayrikBildirim = await baglanti.TekDegerAsync<int>("""
                    insert into public.its_bildirim (tur, durum, sube_id, test_mi, belge_id,
                                                     karsi_gln, islem_tarihi, aciklama, ekleyen)
                    select b.tur, 5, b.sube_id, b.test_mi, b.belge_id, b.karsi_gln,
                           b.islem_tarihi,
                           'Reddedilen / beklenmeyen kutular - İTS''e bildirilmedi',
                           @p1
                      from public.its_bildirim b where b.id = @p0
                    returning id
                    """, islem, [taslak, baglam.KullaniciId], iptal);

                await baglanti.CalistirAsync("""
                    update public.its_bildirim_satir
                       set bildirim_id = @p2
                     where bildirim_id = @p0 and kabul_id = @p1
                       and (dogrulama = 2
                            or exists (select 1 from public.satinalma_kabul_satir s
                                        where s.kabul_id = its_bildirim_satir.kabul_id
                                          and s.stok_id = its_bildirim_satir.stok_id
                                          and s.sonuc = 3))
                    """, islem, [taslak, id, ayrikBildirim], iptal);
            }

            var kalan = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.its_bildirim_satir where bildirim_id = @p0",
                islem, [taslak], iptal);

            if (kalan == 0)
            {
                await islem.RollbackAsync(iptal);
                throw GentegreHatasi.IsKurali(
                    "Bildirilecek kutu kalmadı - okutulan kutuların hepsi reddedilen "
                    + "ya da beklenmeyen kalemlere ait.");
            }

            await baglanti.CalistirAsync("""
                update public.its_bildirim
                   set durum = 1, planlanan = now(),
                       karsi_gln = coalesce(nullif(@p1, ''), karsi_gln),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [taslak, istek.KarsiGln ?? "", baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogItsBildirim,
                taslak.Value, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    kabulId = id, kuyrukta = kalan, ayrilan = ayrilacak, ayrikBildirim,
                    yabanci, yabanciBildirim,
                },
                LogKabul, id, iptal: iptal);

            await islem.CommitAsync(iptal);

            var uyarilar = new List<string>();
            if (ayrilacak > 0)
                uyarilar.Add($"{ayrilacak} kutu bildirime girmedi (reddedilen ya da "
                             + "beklenmeyen kalem) - ayrı kayıtta duruyor.");
            if (yabanci > 0)
                uyarilar.Add($"{yabanci} kutu bu tutanağa ait değil - ayrı bir taslakta "
                             + "bekliyor, kendi tutanağıyla bildirilecek.");

            // --- ŞİMDİ GÖNDER. Hesap yoksa kuyrukta kalır ve sebebi söylenir.
            string gonderim = "Kuyruğa alındı.";
            if (istek.SimdiGonder)
            {
                var s = await its.CalistirAsync(1, taslak, iptal);
                gonderim = s.Aciklama;
            }

            return Results.Ok(new
            {
                bildirimId = taslak, kuyrukta = kalan, ayrilan = ayrilacak,
                ayrikBildirim, yabanci, yabanciBildirim, gonderim, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // --------------------------------------------------------- iptal ----
        // GÖNDERİLMİŞ BİLDİRİM İPTAL EDİLEMEZ: İTS'te kayıt oluştu, geri almak
        //   ayrı bir bildirim türüdür (iade / deaktivasyon). Aynı kural
        //   `/api/its/bildirim/{id}/iptal`de de var; burada tutanak bağı da
        //   doğrulanıyor - başka tutanağın bildirimi bu ekrandan iptal edilmesin.
        grup.MapPost("/kabul/{id:long}/its-iptal", async (
            long id, ItsIptalIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.kabul", Islem.Degistir);
            baglam.YetkiIste("stok", Islem.Degistir);

            if (string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("İptal gerekçesi zorunlu.",
                    new AlanHatasi("gerekce", "Bildirim neden iptal ediliyor?"));

            await using var baglanti = await veri.AcAsync(iptal);

            var bizim = await baglanti.TekDegerAsync<int>("""
                select count(*) from public.v_kabul_its_bildirim v
                 where v.kabul_id = @p0 and v.id = @p1
                """, null, [id, istek.BildirimId], iptal);
            if (bizim == 0)
                throw GentegreHatasi.Bulunamadi("Bildirim bu tutanağa ait değil.");

            var etkilenen = await baglanti.CalistirAsync("""
                update public.its_bildirim
                   set durum = 5, aciklama = @p2,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum in (0, 1, 4)
                """, null, [istek.BildirimId, baglam.KullaniciId, istek.Gerekce], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali(
                    "Yalnız taslak, bekleyen ya da hatalı bildirim iptal edilebilir; "
                    + "gönderilmiş bildirim için iade/deaktivasyon gerekir.");

            await log.YazAsync(LogIslemi.Degistir, LogItsBildirim, istek.BildirimId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kabulId = id, iptal = true, gerekce = istek.Gerekce },
                LogKabul, id, iptal: iptal);

            return Results.Ok(new { iptal = true, izlemeNo = baglam.IzlemeNo });
        });
    }
}
