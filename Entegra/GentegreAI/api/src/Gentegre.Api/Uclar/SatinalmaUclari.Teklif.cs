using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATINALMA — TEKLİF / İHALE UÇLARI (724).
///
/// AĞIRLIKLAR DAVETTEN SONRA KİLİTLİ (724 tetiği). Davet gönderildiği anda
/// `agirlik_kilit = 1` olur ve tetik değişikliği reddeder. Sonradan ağırlık
/// değiştirmek, kazananı seçip gerekçeyi sonradan yazmaktır.
///
/// TEKLİFLER SON TARİHE KADAR AÇILMAZ ve HEPSİ BİRLİKTE AÇILIR. Erken açılan
/// tek teklif, diğerlerine söylenebilecek bir bilgidir. `/ac` ucu son tarihten
/// önce çalışmaz (`zorla` + gerekçe hariç) ve `acilma_zamani` damgasını koyar.
///
/// PUAN HESAPLANIR, GİRİLMEZ. Fiyat puanı en düşük tekliften, teslim/garanti
/// puanı en iyi değerden, performans puanı `v_tedarikci_skor`dan gelir. Elle
/// puan girilebilseydi ağırlık kilidi anlamsız olurdu - kilit puanı değil,
/// puanın HESABINI koruyor.
///
/// ZORUNLU KRİTERİ KARŞILAMAYAN FİRMA PUANLAMAYA GİRMEZ (teknik eleme, durum
/// 3). Puanla telafi edilebilseydi şartname bir tavsiye listesi olurdu.
/// </summary>
public static partial class SatinalmaUclari
{
    public sealed class DavetIstegi
    {
        /// <summary>Davet edilecek firmalar (mevcutların üstüne eklenir).</summary>
        public IReadOnlyList<int>? FirmaIdler { get; set; }
        public DateTime? SonTarih { get; set; }
    }

    public sealed class AcIstegi
    {
        /// <summary>Son tarihten önce aç (gerekçe zorunlu, günlüğe düşer).</summary>
        public bool Zorla { get; set; }
        public string? Gerekce { get; set; }
    }

    public sealed class TeklifKararIstegi
    {
        public int KararFirmaId { get; set; }
        public string? Gerekce { get; set; }
        public string? Kurul { get; set; }
    }

    // ============================================================ teklif ==
    private static void TeklifUclari(RouteGroupBuilder grup)
    {
        // DAVET GÖNDER: ağırlıklar kilitlenir, firmalar davet edilir.
        grup.MapPost("/teklif/{id:long}/davet", async (
            long id, DavetIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.teklif", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.durum, k.talep_id as "talepId", k.son_tarih as "sonTarih",
                       k.agirlik_fiyat + k.agirlik_teslim + k.agirlik_garanti
                         + k.agirlik_performans as "agirlikToplam",
                       (select count(*) from public.satinalma_teklif_firma f
                         where f.teklif_id = k.id) as "firmaSayisi",
                       (select count(*) from public.satinalma_teklif_kriter x
                         where x.teklif_id = k.id) as "kriterSayisi"
                  from public.satinalma_teklif k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");

            var durum = Convert.ToInt16(k["durum"] ?? (short)0);
            if (durum >= 3) throw GentegreHatasi.IsKurali("Kararı verilmiş teklife davet gönderilemez.");

            // AĞIRLIK TOPLAMI 100 OLMALI: 90 ya da 110 toplayan bir ağırlık
            //   kümesi puanı karşılaştırılamaz kılar ve bunu sonradan fark
            //   etmek, kararı verdikten sonra fark etmektir.
            var toplam = Convert.ToInt32(k["agirlikToplam"] ?? 0);
            if (toplam != 100)
                throw GentegreHatasi.IsKurali(
                    $"Değerlendirme ağırlıkları toplamı 100 olmalı (şu an {toplam}).",
                    new { agirlikToplam = toplam });

            var yeniFirmalar = istek.FirmaIdler ?? [];
            var mevcutFirma = Convert.ToInt32(k["firmaSayisi"] ?? 0);
            if (mevcutFirma + yeniFirmalar.Count == 0)
                throw GentegreHatasi.IsKurali("Davet edilecek firma yok.");

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var eklenen = 0;
            foreach (var firmaId in yeniFirmalar.Distinct())
                eklenen += await baglanti.CalistirAsync("""
                    insert into public.satinalma_teklif_firma
                        (teklif_id, firma_id, davet_zamani, durum, ekleyen)
                    select @p0, @p1, @p2, 0, @p3
                     where not exists (select 1 from public.satinalma_teklif_firma f
                                        where f.teklif_id = @p0 and f.firma_id = @p1)
                    """, islem, [id, firmaId, simdi, baglam.KullaniciId], iptal);

            // Daveti olmayan (sonradan eklenmiş) satırlara da damga.
            await baglanti.CalistirAsync("""
                update public.satinalma_teklif_firma
                   set davet_zamani = @p1 where teklif_id = @p0 and davet_zamani is null
                """, islem, [id, simdi], iptal);

            // KİLİT BURADA DÜŞER. Tetik (724) bundan sonra ağırlık değişimini
            //   reddeder - kilidi uç koyar, korumayı veritabanı yapar.
            await baglanti.CalistirAsync("""
                update public.satinalma_teklif
                   set durum = greatest(durum, 1), agirlik_kilit = 1,
                       davet_tarihi = coalesce(davet_tarihi, @p1::date),
                       son_tarih = coalesce(@p2, son_tarih),
                       degistiren = @p3, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, simdi, istek.SonTarih, baglam.KullaniciId], iptal);

            // Talep "teklifte" durumuna geçer - aynı talep için ikinci bir
            //   teklif süreci açıldığında listede görünsün.
            if (k["talepId"] is { } talepId)
                await baglanti.CalistirAsync("""
                    update public.satinalma_talep set durum = @p1,
                           degistiren = @p2, degistirme_tarihi = (now())::timestamp
                     where id = @p0 and durum = @p3
                    """, islem,
                    [Convert.ToInt64(talepId), TalepTeklifte, baglam.KullaniciId, TalepOnaylandi], iptal);

            var uyarilar = new List<string>();
            if (Convert.ToInt32(k["kriterSayisi"] ?? 0) == 0)
                uyarilar.Add("Şartname kriteri girilmemiş - teknik değerlendirme yapılamaz.");
            if (mevcutFirma + eklenen < 3)
                uyarilar.Add("Üçten az firma davet edildi.");

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTeklif, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { davet = simdi, eklenenFirma = eklenen, agirlikKilit = 1, uyarilar },
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                durum = 1, davetZamani = simdi, eklenenFirma = eklenen,
                firmaSayisi = mevcutFirma + eklenen, agirlikKilit = 1, uyarilar,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // TEKLİFLERİ AÇ: damga + teknik eleme + puanlama.
        grup.MapPost("/teklif/{id:long}/ac", async (
            long id, AcIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.teklif", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.durum, k.son_tarih as "sonTarih", k.acilma_zamani as "acilmaZamani",
                       k.agirlik_fiyat as "aFiyat", k.agirlik_teslim as "aTeslim",
                       k.agirlik_garanti as "aGaranti", k.agirlik_performans as "aPerformans",
                       (select count(*) from public.satinalma_teklif_firma f
                         where f.teklif_id = k.id and f.tutar > 0) as "teklifVeren"
                  from public.satinalma_teklif k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");

            if (Convert.ToInt16(k["durum"] ?? (short)0) < 1)
                throw GentegreHatasi.IsKurali("Davet gönderilmemiş teklif açılamaz.");
            if (k["acilmaZamani"] is not null)
                throw GentegreHatasi.IsKurali("Teklifler zaten açılmış.");

            // SON TARİH KAPISI. Erken açılan bir teklif, diğer firmalara
            //   söylenebilecek bir bilgidir.
            if (k["sonTarih"] is DateTime st && DateTime.Now < st)
            {
                if (!istek.Zorla)
                    throw GentegreHatasi.IsKurali(
                        $"Teklifler son tarihten ({st:dd.MM.yyyy HH:mm}) önce açılamaz.",
                        new { sonTarih = st });
                if (string.IsNullOrWhiteSpace(istek.Gerekce))
                    throw GentegreHatasi.Dogrulama("Erken açılışta gerekçe zorunlu.",
                        new AlanHatasi("gerekce", "Gerekçe zorunlu."));
            }

            if (Convert.ToInt32(k["teklifVeren"] ?? 0) == 0)
                throw GentegreHatasi.IsKurali("Hiç teklif girilmemiş - açılacak bir şey yok.");

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // --- TEKNİK ELEME. Zorunlu kriteri "karşılamıyor" (3) ya da hiç
            //     yanıtlanmamış olan firma elenir (durum 3). Puanla telafi
            //     edilseydi şartname bir tavsiye listesi olurdu.
            var elenen = await baglanti.CalistirAsync("""
                update public.satinalma_teklif_firma f
                   set durum = 3,
                       eleme_neden = coalesce(nullif(f.eleme_neden, ''),
                                              'Zorunlu şartname maddesi karşılanmadı')
                 where f.teklif_id = @p0 and f.tutar > 0 and f.durum <> 3
                   and exists (
                        select 1 from public.satinalma_teklif_kriter x
                         left join public.satinalma_teklif_yanit y
                                on y.kriter_id = x.id and y.teklif_firma_id = f.id
                         where x.teklif_id = @p0 and x.zorunlu = 1
                           and coalesce(y.sonuc, 0) <> 1)
                """, islem, [id], iptal);

            // Teklif veren ve elenmemiş firmalar "teklif verdi" (1) olur.
            await baglanti.CalistirAsync("""
                update public.satinalma_teklif_firma
                   set durum = 1,
                       teklif_zamani = coalesce(teklif_zamani, @p1)
                 where teklif_id = @p0 and tutar > 0 and durum = 0
                """, islem, [id, simdi], iptal);

            // Teklif vermeyenler "teklif vermedi" (2).
            await baglanti.CalistirAsync("""
                update public.satinalma_teklif_firma
                   set durum = 2 where teklif_id = @p0 and coalesce(tutar, 0) <= 0 and durum = 0
                """, islem, [id], iptal);

            // --- PUANLAMA. Yarışan küme: elenmemiş ve teklif vermiş olanlar.
            //
            //     FİYAT: en düşük / teklif (düşük olan 100 alır).
            //     TESLİM: en kısa / teklif. GARANTİ: teklif / en uzun.
            //     PERFORMANS: `v_tedarikci_skor` (son 12 ayın olayları); skoru
            //       olmayan firma 100 alır - geçmişi olmayan firmayı
            //       cezalandırmak, yeni tedarikçiyi baştan elemek olurdu.
            var puanlanan = await baglanti.CalistirAsync("""
                with yarisan as (
                    select f.id, f.firma_id, f.tutar, f.teslim_gun, f.garanti_ay
                      from public.satinalma_teklif_firma f
                     where f.teklif_id = @p0 and f.durum = 1 and f.tutar > 0
                ), sinir as (
                    select min(tutar) as "enDusuk",
                           min(nullif(teslim_gun, 0)) as "enKisa",
                           max(nullif(garanti_ay, 0)) as "enUzun"
                      from yarisan
                )
                update public.satinalma_teklif_firma f
                   set puan_fiyat = round(s."enDusuk" * 100.0 / y.tutar, 2),
                       puan_teslim = case when coalesce(y.teslim_gun, 0) > 0 and s."enKisa" > 0
                                          then round(s."enKisa" * 100.0 / y.teslim_gun, 2)
                                          else 0 end,
                       puan_garanti = case when coalesce(y.garanti_ay, 0) > 0 and s."enUzun" > 0
                                           then round(y.garanti_ay * 100.0 / s."enUzun", 2)
                                           else 0 end,
                       puan_performans = coalesce(
                            (select v.skor from public.v_tedarikci_skor v
                              where v.firma_id = y.firma_id), 100),
                       puan_toplam = round((
                            round(s."enDusuk" * 100.0 / y.tutar, 2) * @p1
                          + case when coalesce(y.teslim_gun, 0) > 0 and s."enKisa" > 0
                                 then round(s."enKisa" * 100.0 / y.teslim_gun, 2) else 0 end * @p2
                          + case when coalesce(y.garanti_ay, 0) > 0 and s."enUzun" > 0
                                 then round(y.garanti_ay * 100.0 / s."enUzun", 2) else 0 end * @p3
                          + coalesce((select v.skor from public.v_tedarikci_skor v
                                       where v.firma_id = y.firma_id), 100) * @p4
                       ) / 100.0, 2)
                  from yarisan y, sinir s
                 where f.id = y.id
                """, islem,
                [id, Convert.ToInt32(k["aFiyat"] ?? 0), Convert.ToInt32(k["aTeslim"] ?? 0),
                 Convert.ToInt32(k["aGaranti"] ?? 0), Convert.ToInt32(k["aPerformans"] ?? 0)],
                iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_teklif
                   set durum = greatest(durum, 2), acilma_zamani = @p1,
                       degistiren = @p2, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem, [id, simdi, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTeklif, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    acilmaZamani = simdi, elenen, puanlanan,
                    erkenAcilis = istek.Zorla ? istek.Gerekce : null
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            var siralama = await baglanti.ListeAsync("""
                select f.firma_id as "firmaId", coalesce(t.unvan, '') as unvan,
                       f.tutar, f.teslim_gun as "teslimGun", f.garanti_ay as "garantiAy",
                       f.puan_fiyat as "puanFiyat", f.puan_teslim as "puanTeslim",
                       f.puan_garanti as "puanGaranti", f.puan_performans as "puanPerformans",
                       f.puan_toplam as "puanToplam", f.durum, f.eleme_neden as "elemeNeden"
                  from public.satinalma_teklif_firma f
                  left join public.taraf t on t.id = f.firma_id
                 where f.teklif_id = @p0
                 order by f.durum = 1 desc, f.puan_toplam desc nulls last, f.tutar
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                durum = 2, acilmaZamani = simdi, elenen, puanlanan, siralama,
                izlemeNo = baglam.IzlemeNo
            });
        });

        // KARAR: kazanan firma. En düşük alınmadıysa gerekçe zorunlu.
        grup.MapPost("/teklif/{id:long}/karar", async (
            long id, TeklifKararIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("satinalma.teklif", Islem.Degistir);
            baglam.AksiyonIste("satinalma.karar");

            await using var baglanti = await veri.AcAsync(iptal);

            var k = await baglanti.TekAsync("""
                select k.durum, k.acilma_zamani as "acilmaZamani",
                       (select f.firma_id from public.satinalma_teklif_firma f
                         where f.teklif_id = k.id and f.durum = 1 and f.tutar > 0
                         order by f.tutar limit 1) as "enDusukFirma",
                       (select f.tutar from public.satinalma_teklif_firma f
                         where f.teklif_id = k.id and f.durum = 1 and f.tutar > 0
                         order by f.tutar limit 1) as "enDusukTutar"
                  from public.satinalma_teklif k where k.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Teklif bulunamadı.");

            if (k["acilmaZamani"] is null)
                throw GentegreHatasi.IsKurali("Teklifler açılmadan karar verilemez.");
            if (Convert.ToInt16(k["durum"] ?? (short)0) >= 3)
                throw GentegreHatasi.IsKurali("Bu teklifin kararı zaten verilmiş.");

            var kazanan = await baglanti.TekAsync("""
                select f.durum, f.tutar, f.eleme_neden as "elemeNeden",
                       coalesce(t.unvan, '') as unvan
                  from public.satinalma_teklif_firma f
                  left join public.taraf t on t.id = f.firma_id
                 where f.teklif_id = @p0 and f.firma_id = @p1
                """, null, [id, istek.KararFirmaId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Seçilen firma bu teklifte davet edilmemiş.");

            // ELENMİŞ FİRMA KAZANAMAZ: teknik elemenin anlamı budur.
            if (Convert.ToInt16(kazanan["durum"] ?? (short)0) == 3)
                throw GentegreHatasi.IsKurali(
                    $"Teknik olarak elenmiş firma kazanan seçilemez ({kazanan["elemeNeden"]}).");
            if (Convert.ToDecimal(kazanan["tutar"] ?? 0m) <= 0)
                throw GentegreHatasi.IsKurali("Teklif vermemiş firma kazanan seçilemez.");

            // EN DÜŞÜK ALINMADIYSA GEREKÇE ŞART. Denetimin ilk sorusu budur ve
            //   yanıtı kararla aynı anda yazılmalı - sonradan yazılan gerekçe,
            //   verilmiş kararın savunmasıdır.
            var enDusukFirma = k["enDusukFirma"] is { } ed ? Convert.ToInt32(ed) : 0;
            var enDusukAlindi = enDusukFirma == istek.KararFirmaId;
            if (!enDusukAlindi && string.IsNullOrWhiteSpace(istek.Gerekce))
                throw GentegreHatasi.Dogrulama("En düşük teklif alınmıyorsa gerekçe zorunlu.",
                    new AlanHatasi("gerekce",
                        $"En düşük teklif {k["enDusukTutar"]} - neden bu firma seçildi?"));

            var simdi = DateTime.Now;
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_teklif_firma
                   set durum = case when firma_id = @p1 then 5
                                    when durum = 1 then 4 else durum end
                 where teklif_id = @p0
                """, islem, [id, istek.KararFirmaId], iptal);

            await baglanti.CalistirAsync("""
                update public.satinalma_teklif
                   set durum = 3, karar_firma_id = @p1, karar_zamani = @p2,
                       karar_gerekce = coalesce(nullif(@p3, ''), karar_gerekce),
                       kurul = coalesce(nullif(@p4, ''), kurul),
                       degistiren = @p5, degistirme_tarihi = (now())::timestamp
                 where id = @p0
                """, islem,
                [id, istek.KararFirmaId, simdi, istek.Gerekce ?? "", istek.Kurul ?? "",
                 baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTeklif, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    kararFirmaId = istek.KararFirmaId, unvan = kazanan["unvan"],
                    tutar = kazanan["tutar"], enDusukAlindi,
                    enDusukTutar = k["enDusukTutar"], gerekce = istek.Gerekce
                }, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                durum = 3, kararFirmaId = istek.KararFirmaId, kararZamani = simdi,
                enDusukAlindi, izlemeNo = baglam.IzlemeNo
            });
        });
    }
}
