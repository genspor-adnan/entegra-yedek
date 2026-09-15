using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ ÜNİTE AKIŞI — hastayı istasyonlar arasında taşıyan uçlar (mockup
/// <c>Ekranlar/Goz/goz_unite_panosu.html</c> araç çubuğu).
///
/// <para><b>Akış satırı KAPANIR ve YENİSİ AÇILIR</b>, istasyon alanı
/// güncellenmez: bir ziyarette hasta beş altı istasyondan geçiyor ve "ön
/// tetkikte 12 dakika, görüntülemede 31 dakika bekledi" cevabı ancak her
/// geçişin kendi satırı varsa verilebiliyor. Tek satırın istasyonunu
/// değiştirmek, geçmişi her adımda siler ve darboğaz ölçümünü imkânsız
/// kılardı.</para>
///
/// <para><b>Dilatasyon ENGEL DEĞİL UYARIDIR:</b> damlası hazır olmayan hastayı
/// muayeneye almak klinik bir karar — acil vakada hekim dilatasyonsuz da
/// bakar. Uç işlemi yapar ve uyarıyı döner; ekran bunu gösterir. Engel
/// yapsaydık hekim panoyu atlayıp hastayı elle çağırırdı, o zaman pano
/// gerçeğin gerisinde kalırdı.</para>
///
/// <para><b>Çağrı kaydı tutulur</b> (702): "çağrıldı ama gelmedi" ile "kimse
/// çağırmadı" aynı görünürse sıra kimsede kalmaz.</para>
/// </summary>
public static partial class GozUclari
{
    /// <summary>1 kabul · 2 ön tetkik · 3 muayene · 4 görüntüleme · 5 karar · 6 tamamlandı.</summary>
    private static readonly string[] IstasyonAdi =
        ["", "Kabul", "Ön tetkik", "Hekim muayenesi", "Görüntüleme", "Karar / işlem", "Tamamlandı"];

    public sealed record IstasyonIstegi(short Istasyon, string? Oda, int? PersonelId,
                                        string? Not);
    public sealed record DilatasyonIstegi(string? Ilac);
    public sealed record OdaIstegi(string? Oda, int? PersonelId);

    private static void AkisUclariniEkle(RouteGroupBuilder grup)
    {
        // --------------------------------------------------- sıradakini çağır ----
        // Seçili satır yoksa EN UZUN BEKLEYEN çağrılır: "sıradaki" ünitede
        //   sıra numarası değil, en uzun bekleyendir - numaraya göre çağırmak,
        //   arada dilatasyona giren hastayı sonsuza kadar geride bırakır.
        grup.MapPost("/akis/cagir", async (
            int? istasyonId, short? istasyon, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var satir = await baglanti.TekAsync("""
                select i.id, t.unvan, i.istasyon, i.oda, i.cagri_zamani
                  from public.goz_ziyaret_istasyon i
                  join public.taraf t on t.id = i.hasta_id
                 where i.cikis is null
                   and (@p0::int is null or i.id = @p0)
                   and (@p1::smallint is null or i.istasyon = @p1)
                   -- ÇAĞRILMIŞ HASTA TEKRAR ÇAĞRILMAZ (id verilmediyse):
                   --   kuyruğun başındaki çağrılmış hasta yüzünden düğme
                   --   hep aynı kişiyi çağırır, sıra ilerlemezdi.
                   and (@p0::int is not null or i.cagri_zamani is null)
                 order by i.giris
                 limit 1
                """, null, [istasyonId, istasyon], o => new
            {
                id = o.GetInt32(0),
                hasta = o.GetString(1),
                istasyon = (int)o.GetInt16(2),
                oda = o.GetString(3),
                cagrildi = !o.IsDBNull(4),
            }, iptal);

            if (satir is null)
                throw GentegreHatasi.IsKurali("Çağrılacak bekleyen hasta yok.");

            await baglanti.CalistirAsync("""
                update public.goz_ziyaret_istasyon
                   set cagri_zamani = now(), cagiran_id = @p1,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, null, [satir.id, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloGozAkis, satir.id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { cagri = satir.hasta, istasyon = IstasyonAdi[satir.istasyon] }, iptal: iptal);

            return Results.Ok(new
            {
                satir.id,
                satir.hasta,
                istasyon = IstasyonAdi[satir.istasyon],
                satir.oda,
                tekrar = satir.cagrildi,
            });
        });

        // ------------------------------------------------------- istasyona al ----
        grup.MapPost("/akis/{id:int}/istasyon", async (
            int id, IstasyonIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);

            if (istek.Istasyon is < 1 or > 6)
                throw GentegreHatasi.Dogrulama("İstasyon seçilmeli.",
                    new AlanHatasi("istasyon", "1-6 arası olmalı."));

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var mevcut = await baglanti.TekAsync("""
                select i.belge_id, i.hasta_id, i.sube_id, i.istasyon, i.cikis,
                       i.dilatasyon_zamani, i.sira_no, i.oda, i.personel_id,
                       t.unvan
                  from public.goz_ziyaret_istasyon i
                  join public.taraf t on t.id = i.hasta_id
                 where i.id = @p0
                 for no key update of i
                """, islem, [id], o => new
            {
                belgeId = o.GetInt32(0),
                hastaId = o.GetInt32(1),
                subeId = o.GetInt32(2),
                istasyon = (int)o.GetInt16(3),
                kapali = !o.IsDBNull(4),
                dilatasyon = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                siraNo = (int)o.GetInt16(6),
                oda = o.GetString(7),
                personelId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                hasta = o.GetString(9),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Akış kaydı bulunamadı.");

            if (mevcut.kapali)
                throw GentegreHatasi.IsKurali("Bu istasyon kaydı kapanmış; ziyaret ilerlemiş.");
            if (mevcut.istasyon == istek.Istasyon)
                throw GentegreHatasi.IsKurali(
                    $"Hasta zaten {IstasyonAdi[istek.Istasyon].ToLowerInvariant()} istasyonunda.");

            // DİLATASYON UYARISI: damla damlatıldıysa ve 20 dakika dolmadıysa
            //   muayeneye alınan hasta geri gönderilir - uç bunu ENGELLEMEZ
            //   ama söyler.
            string uyari = "";
            if (istek.Istasyon == 3 && mevcut.dilatasyon is DateTime d
                && d.AddMinutes(20) > DateTime.UtcNow)
            {
                var kalan = (int)Math.Ceiling((d.AddMinutes(20) - DateTime.UtcNow).TotalMinutes);
                uyari = $"Dilatasyon hazır değil: {kalan} dk kaldı.";
            }

            await baglanti.CalistirAsync("""
                update public.goz_ziyaret_istasyon
                   set cikis = now(), degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);

            // ZİYARET TAMAMLANDIYSA yeni satır AÇILMAZ: 6 "tamamlandı"
            //   durumudur, bir bekleme yeri değil - açık satır bırakmak
            //   hastayı sonsuza kadar panoda tutardı.
            int? yeniId = null;
            if (istek.Istasyon != 6)
            {
                yeniId = await baglanti.TekDegerAsync<int>("""
                    insert into public.goz_ziyaret_istasyon
                        (sube_id, belge_id, hasta_id, istasyon, giris, oda, personel_id,
                         sira_no, not_metin, dilatasyon_zamani, dilatasyon_ilac, ekleyen)
                    select @p0, @p1, @p2, @p3, now(), coalesce(@p4, ''), @p5,
                           @p6, coalesce(@p7, ''),
                           -- DİLATASYON ZAMANI TAŞINIR: damla hastaya
                           --   damlatıldı, istasyon değişti diye sıfırlanmaz;
                           --   sayaç yeni sütunda da doğru saymalı.
                           i.dilatasyon_zamani, i.dilatasyon_ilac, @p8
                      from public.goz_ziyaret_istasyon i where i.id = @p9
                    returning id
                    """, islem,
                    [mevcut.subeId, mevcut.belgeId, mevcut.hastaId, istek.Istasyon,
                     istek.Oda ?? mevcut.oda, istek.PersonelId ?? mevcut.personelId,
                     mevcut.siraNo, istek.Not, baglam.KullaniciId, id], iptal);
            }

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloGozAkis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new
                {
                    hasta = mevcut.hasta,
                    istasyon = $"{IstasyonAdi[mevcut.istasyon]} -> {IstasyonAdi[istek.Istasyon]}",
                    uyari,
                }, tarafId: mevcut.hastaId, iptal: iptal);

            await islem.CommitAsync(iptal);
            return Results.Ok(new
            {
                id = yeniId,
                hasta = mevcut.hasta,
                istasyon = IstasyonAdi[istek.Istasyon],
                tamamlandi = istek.Istasyon == 6,
                uyari,
            });
        });

        // ------------------------------------------------- dilatasyon başlat ----
        grup.MapPost("/akis/{id:int}/dilatasyon", async (
            int id, DilatasyonIstegi istek, VeriKaynagi veri, LogDeposu log,
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            // İKİNCİ KEZ BAŞLATMA ENGELİ: sayaç sıfırlanırsa hazır olan hasta
            //   yeniden 20 dakika bekler ve kimse sebebini anlamaz. Damla
            //   gerçekten tekrarlandıysa önce kayıt düzeltilir.
            var etkilenen = await baglanti.CalistirAsync("""
                update public.goz_ziyaret_istasyon
                   set dilatasyon_zamani = now(),
                       dilatasyon_ilac = coalesce(@p1, dilatasyon_ilac),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0 and cikis is null and dilatasyon_zamani is null
                """, null, [id, istek.Ilac?.Trim(), baglam.KullaniciId], iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali(
                    "Kayıt kapanmış ya da dilatasyon zaten başlatılmış.");

            await log.YazAsync(LogIslemi.Degistir, LogTabloGozAkis, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { dilatasyon = istek.Ilac ?? "başlatıldı" }, iptal: iptal);

            return Results.Ok(new { id, hazirDk = 20 });
        });

        // ------------------------------------------------------ oda / personel ----
        grup.MapPost("/akis/{id:int}/oda", async (
            int id, OdaIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz", Islem.Degistir);

            var etkilenen = await veri.CalistirAsync("""
                update public.goz_ziyaret_istasyon
                   set oda = coalesce(@p1, oda), personel_id = coalesce(@p2, personel_id),
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0 and cikis is null
                """, new object?[] { id, istek.Oda?.Trim(), istek.PersonelId,
                                     baglam.KullaniciId }, iptal);

            if (etkilenen == 0)
                throw GentegreHatasi.IsKurali("Kayıt bulunamadı ya da kapanmış.");

            return Results.Ok(new { id, oda = istek.Oda ?? "" });
        });
    }
}
