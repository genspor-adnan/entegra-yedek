using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// TABURCU VE YATIŞ İPTALİ — bkz. <c>YatanUclari</c>.
///
/// <para>Taburcu planı, çıkış kontrolü, taburcu ve yatışın iptali.
///
/// <para><b>Çıkışı neyin engellediği tek yerde:</b> <c>/cikis-kontrol</c> aynı
/// listeyi hem taburcu ekranına hem yatan hasta şeridine veriyor - "çıkışta bir
/// şey kalmış mıydı" sorusunun cevabı hasta yatarken de aynı yerden okunmalı.
/// İptal taburcudan ayrıdır: yanlış açılmış yatışı kapatır, hasta hiç yatmamış
/// sayılır ve yatak serbest kalır.</para></para>
/// </summary>
public static partial class YatanUclari
{
    private static void CikisUclariniEkle(RouteGroupBuilder grup)
    {
        // ---------------------------------------------------- taburcu planlama ----
        // "Taburcu planlandı" AYRI DURUM: hekim sabah karar verir, çıkış öğleden
        //   sonra olur. Arada yatak dolu ama panoda "bugün boşalacak" görünmeli -
        //   yatak planlaması bu bilgiyle yapılır.
        grup.MapPost("/{id:int}/taburcu-planla", async (
            int id, TaburcuPlanIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.taburcu");

            await using var baglanti = await veri.AcAsync(iptal);

            var etkilenen = await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = 3, tahmini_cikis = coalesce(@p1::date, current_date),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and durum in (1, 2, 3)
                """, null, [id, istek.TahminiCikis, baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Yatış bulunamadı ya da kapanmış.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Taburcu planlandı", tahminiCikis = istek.TahminiCikis },
                iptal: iptal);

            return Results.Ok(new { id, durum = 3 });
        });

        // --------------------------------------------------- çıkış kontrol listesi ----
        // TABURCU EKRANI BU LİSTEYİ SORAR, yatış kartındaki "Açık işler" kutusu
        //   da aynı sayıları okur: iki yerde iki ayrı "açık iş" tanımı olsaydı,
        //   taburcuda görünmeyen bir eksik hastayla birlikte çıkardı.
        //
        // ENGEL / UYARI AYRIMI: sonucu gelmemiş tetkik ve imzasız sözel order
        //   sahipsiz kalır - bunlar taburcuyu durdurur. Yanıtlanmamış
        //   konsültasyon ve geciken doz görünür ama hekimin kararıyla geçilir.
        grup.MapGet("/{id:int}/cikis-kontrol", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("yatan", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var liste = await CikisKontrolAsync(baglanti, null, id, iptal);
            return Results.Ok(new
            {
                maddeler = liste,
                engelVar = liste.Any(m => m.engel && !m.tamam),
            });
        });

        // ------------------------------------------------------------ taburcu ----
        grup.MapPost("/{id:int}/taburcu", async (
            int id, TaburcuIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.taburcu");

            // ÇIKIŞ ŞEKLİ ZORUNLU ve SKRS kodludur: tek "taburcu" alanı ölüm
            //   vakasını da taburcu gösterirdi. e-Nabız, Medula ve kurum
            //   istatistiği bu ayrımı ister.
            if (istek.CikisSekli is < 1 or > 7)
                throw GentegreHatasi.Dogrulama("Çıkış şekli seçilmeli.",
                    new AlanHatasi("cikisSekli", "Zorunlu."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select durum, yatak_id, hasta_id, dosya_no
                  from public.yatis where id = @p0 for no key update
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                hastaId = o.GetInt32(2),
                dosyaNo = o.GetString(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum is not (1 or 2 or 3))
                throw GentegreHatasi.IsKurali("Yatış zaten kapanmış.");

            var kontrol = await CikisKontrolAsync(baglanti, islem, id, iptal);
            // SONUCU TAKİP EDECEK HEKİM seçildiyse "sonuç bekleyen tetkik"
            //   engeli aşılır - ama kim aştığı ve kimin takip edeceği loga
            //   yazılır. Sessizce geçilen bir engel, engel değildir.
            var engeller = kontrol
                .Where(m => m.engel && !m.tamam)
                .Where(m => !(m.kod == "tetkik" && istek.TakipHekimId is > 0))
                .ToList();
            if (engeller.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Taburcu engelleri var: " + string.Join(", ", engeller.Select(m => m.ad)),
                    new { engeller });

            // SEVK AYRI DURUM: "kurum dışına sevk" edilen hasta taburcu
            //   sayılmaz - gittiği kurumla ilişki sürer, istatistik ayrıdır.
            var yeniDurum = istek.CikisSekli == 3 ? (short)5 : (short)4;

            await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = @p1, cikis_tarihi = coalesce(@p2, now()),
                       cikis_sekli = @p3, cikis_tani_kodu = coalesce(@p4, cikis_tani_kodu),
                       degistiren = @p5, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, yeniDurum, istek.CikisTarihi, istek.CikisSekli,
                             istek.CikisTaniKodu, baglam.KullaniciId], iptal);

            // AÇIK ORDER KAPANIR: taburcu olan hastanın "aktif" ilacı eMAR
            //   kuyruğunda doz üretmeye devam ederdi.
            await baglanti.CalistirAsync("""
                update public.yatis_order
                   set durum = 3, degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and durum = 1
                """, islem, [id, baglam.KullaniciId], iptal);

            // BEKLEYEN DOZ SİLİNMEZ, "atlandı" olarak NEDENİYLE kapanır:
            //   silinen satır "verilmedi mi, hiç planlanmadı mı" sorusunu
            //   cevapsız bırakır.
            await baglanti.CalistirAsync("""
                update public.order_uygulama u
                   set durum = 3, atlama_nedeni = 'Taburcu', degistiren = @p1,
                       degistirme_tarihi = now()
                  from public.yatis_order od
                 where od.id = u.order_id and od.yatis_id = @p0
                   and u.durum in (1, 5)
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.yatis_yatak
                   set bitis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and bitis is null
                """, islem, [id, baglam.KullaniciId], iptal);

            // YATAK TEMİZLİĞE DÜŞER: taburcu olan yatak anında "boş" sayılsaydı
            //   kabul masası hastayı yapılmamış yatağa gönderirdi.
            if (yatis.yatakId is int yatakId)
                await baglanti.CalistirAsync("""
                    update public.yatak
                       set durum = 4, durum_notu = 'Taburcu sonrası', degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [yatakId, baglam.KullaniciId], iptal);

            // KONTROL RANDEVUSU TABURCUYLA AÇILIR: "on gün sonra gelin" denip
            //   randevu verilmeyen hastanın yarısı gelmiyor. Epikrizde kontrol
            //   tarihi yoksa randevu da yok - uydurulmaz.
            var randevuId = await KontrolRandevusuAcAsync(
                baglanti, islem, id, yatis.hastaId, baglam.SubeId ?? 0,
                baglam.KullaniciId, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    durum = yeniDurum == 5 ? "Kurum dışına sevk" : "Taburcu",
                    cikisSekli = istek.CikisSekli,
                    dosyaNo = yatis.dosyaNo,
                    takipHekimId = istek.TakipHekimId,
                    kontrolRandevusu = randevuId,
                }, tarafId: yatis.hastaId, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id,
                durum = yeniDurum,
                kontrolRandevusu = randevuId,
                uyarilar = kontrol.Where(m => !m.engel && !m.tamam).ToList(),
            });
        });

        // ------------------------------------------------------ yatış iptali ----
        // YATIŞ SİLİNMEZ, İPTAL EDİLİR (durum 0). Yatışa order, izlem, doz ve
        //   tahakkuk bağlı; silinen yatış bunları da götürür ve "bu hasta
        //   yatmış mıydı" sorusu cevapsız kalır. Yanlış açılan yatışın doğru
        //   karşılığı iptaldir: kayıt kalır, yatak serbest kalır.
        //
        // HASTA YATAĞA ÇIKTIYSA İPTAL YOK: o artık bir yatıştır ve çıkışı
        //   taburcudur. İptal yalnız "yanlış kayıt" içindir.
        grup.MapPost("/{id:int}/iptal", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("yatan.kabul");

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var yatis = await baglanti.TekAsync("""
                select durum, yatak_id, hasta_id, dosya_no
                  from public.yatis where id = @p0 for no key update
                """, islem, [id], o => new
            {
                durum = o.GetInt16(0),
                yatakId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                hastaId = o.GetInt32(2),
                dosyaNo = o.GetString(3),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Yatış bulunamadı.");

            if (yatis.durum != 1)
                throw GentegreHatasi.IsKurali(
                    "Yalnız 'Yatış kabul' durumundaki yatış iptal edilir; "
                    + "yatağa alınmış hasta TABURCU edilir.");

            // UYGULANMIŞ DOZU OLAN YATIŞ İPTAL EDİLMEZ: iptal "hiç olmadı"
            //   demektir, oysa ilaç verilmiş.
            var verilenDoz = await baglanti.TekDegerAsync<int>("""
                select count(*)::int from public.order_uygulama u
                  join public.yatis_order od on od.id = u.order_id
                 where od.yatis_id = @p0 and u.durum = 2
                """, islem, [id], iptal);
            if (verilenDoz > 0)
                throw GentegreHatasi.IsKurali(
                    $"Bu yatışta {verilenDoz} doz uygulanmış: iptal edilemez, taburcu edilir.");

            await baglanti.CalistirAsync("""
                update public.yatis
                   set durum = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.yatis_yatak
                   set bitis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where yatis_id = @p0 and bitis is null
                """, islem, [id, baglam.KullaniciId], iptal);

            // YATAK BOŞA DÖNER (temizliğe değil): hasta yatağa hiç çıkmadı.
            if (yatis.yatakId is int yatakId)
                await baglanti.CalistirAsync("""
                    update public.yatak
                       set durum = 1, durum_notu = '', degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0 and durum = 3
                    """, islem, [yatakId, baglam.KullaniciId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloYatis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "İptal", dosyaNo = yatis.dosyaNo }, tarafId: yatis.hastaId,
                iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new { id, durum = 0 });
        });
    }
}
