using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ MUAYENESİ KART EYLEMLERİ — mockup
/// <c>Ekranlar/Goz/goz_detayli_muayene.html</c> araç çubuğu.
///
/// <para><b>Kart araç çubuğu düğmeleri LİSTEDEKİ aksiyon kodlarının
/// aynısıdır:</b> kural ve yetki tek yerde kalır. Muayene kartında da aynı
/// desen kullanılıyor (461).</para>
///
/// <para><b>"Önceki muayeneden kopyala" ÖLÇÜM KOPYALAMAZ.</b> Sayısal
/// değerler (görme, GİB, refraksiyon) her ziyarette yeniden ölçülür; onları
/// kopyalamak, yapılmamış bir ölçümü yapılmış göstermek olur. Kopyalanan şey
/// biyomikroskopi ve fundusun METİNSEL bulgularıdır — hekim "geçen sefer ne
/// yazmıştım"ı okuyup değişeni düzeltir. Üstelik yalnız BOŞ alanlar dolar:
/// bugün yazılmış bir bulgu asla ezilmez.</para>
/// </summary>
public static partial class GozUclari
{
    /// <summary>Muayene tamamlama logu genel muayene kaydına düşer.</summary>
    private const int LogTabloMuayene = 954;

    private static void MuayeneUclariniEkle(RouteGroupBuilder grup)
    {
        // -------------------------------------------------- muayeneyi tamamla ----
        grup.MapPost("/muayene/{id:int}/tamamla", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);

            var m = await baglanti.TekAsync("""
                select gm.muayene_id, gm.hasta_id, (mu.tamamlanma is not null) as kapali,
                       (select count(*) from public.goz_gorme x
                         where x.goz_muayene_id = gm.id)::int
                     + (select count(*) from public.goz_tonometri x
                         where x.goz_muayene_id = gm.id)::int
                     + (select count(*) from public.goz_on_segment x
                         where x.goz_muayene_id = gm.id)::int
                     + (select count(*) from public.goz_fundus x
                         where x.goz_muayene_id = gm.id)::int
                     + (select count(*) from public.goz_refraksiyon x
                         where x.goz_muayene_id = gm.id)::int          as olcum,
                       (select count(*) from public.tani t
                         where t.muayene_id = gm.muayene_id)::int      as tani
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, null, [id], o => new
            {
                muayeneId = o.GetInt32(0),
                hastaId = o.GetInt32(1),
                kapali = o.GetBoolean(2),
                olcum = o.GetInt32(3),
                tani = o.GetInt32(4),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            if (m.kapali)
                throw GentegreHatasi.IsKurali("Muayene zaten tamamlanmış.");

            // HİÇ ÖLÇÜM YOKSA TAMAMLANMAZ: boş bir muayeneyi kapatmak, hastayı
            //   "görüldü" saymaktır. Tanı yokluğu ise UYARIDIR - ön tanısız
            //   kontrol muayenesi olabiliyor, hekimi sistemi aşmaya itmeyelim.
            if (m.olcum == 0)
                throw GentegreHatasi.IsKurali(
                    "Hiç ölçüm girilmemiş: görme, refraksiyon, basınç, ön segment ya da "
                    + "fundustan en az biri kaydedilmeli.");

            await baglanti.CalistirAsync("""
                update public.muayene
                   set tamamlanma = now(), tamamlayan_id = @p1, durum = 3,
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and tamamlanma is null
                """, null, [m.muayeneId, baglam.KullaniciId], iptal);

            await log.YazAsync(LogIslemi.Degistir, LogTabloMuayene, m.muayeneId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { durum = "Göz muayenesi tamamlandı", olcum = m.olcum, tani = m.tani },
                tarafId: m.hastaId, iptal: iptal);

            return Results.Ok(new
            {
                id,
                tamamlandi = true,
                // TANISIZ TAMAMLAMA SESSİZ GEÇMEZ: ekran uyarıyı gösterir.
                uyari = m.tani == 0 ? "Muayene tanısız tamamlandı." : "",
            });
        });

        // ------------------------------------------- önceki muayeneden kopyala ----
        grup.MapPost("/muayene/{id:int}/onceki-kopyala", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var bu = await baglanti.TekAsync("""
                select gm.hasta_id, mu.muayene_tarihi, (mu.tamamlanma is not null) as kapali
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, islem, [id], o => new
            {
                hastaId = o.GetInt32(0),
                tarih = o.GetDateTime(1),
                kapali = o.GetBoolean(2),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            // TAMAMLANMIS MUAYENEYE BULGU EKLENMEZ: kapanmis bir muayenenin
            //   icerigi sonradan degisirse, o muayeneye dayanan rapor/recete
            //   ile kayit birbirini tutmaz. Duzeltme gerekiyorsa muayene
            //   yeniden acilmali - sessizce satir eklemek yerine.
            if (bu.kapali)
                throw GentegreHatasi.IsKurali(
                    "Muayene tamamlanmış; bulgu kopyalanamaz.");

            var onceki = await baglanti.TekDegerAsync<int?>("""
                select gm.id
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.hasta_id = @p0 and gm.id <> @p1 and mu.muayene_tarihi < @p2
                 order by mu.muayene_tarihi desc
                 limit 1
                """, islem, [bu.hastaId, id, bu.tarih], iptal);

            if (onceki is null)
                throw GentegreHatasi.IsKurali("Bu hastanın önceki göz muayenesi yok.");

            // METİNSEL BULGULAR kopyalanır, ölçüm sayıları kopyalanmaz.
            //   `on conflict` yok: göz başına tek satır tutan tablolarda bile
            //   benzersizlik garantisi yok, bu yüzden "bu gözde satır varsa
            //   atla" kuralı sorguda duruyor - var olan bulgu EZİLMEZ.
            var onSeg = await baglanti.CalistirAsync("""
                insert into public.goz_on_segment
                    (goz_muayene_id, goz, kaynak, zaman, alan, normal,
                     deger_metin, deger_kod, ekleyen)
                select @p0, k.goz, 1, now(), k.alan, k.normal,
                       k.deger_metin, k.deger_kod, @p2
                  from public.goz_on_segment k
                 where k.goz_muayene_id = @p1
                   and not exists (select 1 from public.goz_on_segment y
                                    where y.goz_muayene_id = @p0
                                      and y.goz = k.goz and y.alan = k.alan)
                """, islem, [id, onceki.Value, baglam.KullaniciId], iptal);

            var fundus = await baglanti.CalistirAsync("""
                insert into public.goz_fundus
                    (goz_muayene_id, goz, kaynak, zaman, disk_metin, makula_metin,
                     damar_metin, periferi_metin, vitreus, dr_evre, amd_evre, ekleyen)
                select @p0, k.goz, 1, now(), k.disk_metin, k.makula_metin,
                       k.damar_metin, k.periferi_metin, k.vitreus,
                       k.dr_evre, k.amd_evre, @p2
                  from public.goz_fundus k
                 where k.goz_muayene_id = @p1
                   and not exists (select 1 from public.goz_fundus y
                                    where y.goz_muayene_id = @p0 and y.goz = k.goz)
                """, islem, [id, onceki.Value, baglam.KullaniciId], iptal);

            await islem.CommitAsync(iptal);

            var toplam = onSeg + fundus;
            return Results.Ok(new
            {
                id,
                oncekiId = onceki.Value,
                kopyalanan = toplam,
                aciklama = toplam == 0
                    ? "Kopyalanacak boş alan kalmamış (mevcut bulgular korunur)."
                    : $"{toplam} bulgu satırı önceki muayeneden getirildi; "
                      + "ölçümler (görme, basınç, refraksiyon) kopyalanmaz.",
            });
        });
    }
}
