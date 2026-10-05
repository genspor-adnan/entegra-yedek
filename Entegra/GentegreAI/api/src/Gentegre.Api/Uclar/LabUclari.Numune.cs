using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LABORATUVAR NUMUNESİ — bkz. <c>LabUclari</c>.
///
/// <para>Barkod okuma, kabul / ret, istem bazında numune durumu, saklama ve ret
/// nedenleri. <b>Ret nedeni listesi sunucudan:</b> teknisyenin serbest
/// metin yazdığı bir ret, istatistikte sayılamayan bir rettir.</para>
/// </summary>
public static partial class LabUclari
{
    private static void NumuneUclariniEkle(RouteGroupBuilder grup)
    {
        // POST /api/lab/istem/{id}/numune-plani - kart ekranından açılmış
        //   istemin barkodlarını üretir. Kart yolu tüp planını çalıştırmaz;
        //   barkodsuz istem kan alma biriminde "hangi tüp" sorusunu cevapsız
        //   bırakırdı.
        grup.MapPost("/istem/{id:int}/numune-plani", async (
            int id, BaglamCozucu cozucu, LabServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Ekle);

            var barkodlar = await servis.NumunePlaniAsync(id, baglam, iptal);
            return Results.Ok(new { id, barkodlar,
                mesaj = $"{barkodlar.Count} tüp barkodu üretildi: "
                      + string.Join(", ", barkodlar),
                izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------- ret kriterleri ---
        // RET NEDENLERİ ARTIK TANIMDAN GELİYOR (879, KTS maddesi L6).
        //   Eskiden sekiz sabit kod hem sunucuda hem ekranda ayrı ayrı
        //   yazılıydı; laboratuvar kendi kabul/ret ölçütlerini giremiyordu.
        //   Ekran bu listeyi okur: ret penceresinin seçenekleri de, numune
        //   kabulündeki "kalite" listesi de aynı satırlardan çıkar.
        grup.MapGet("/ret-nedenleri", async (
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select kod, ad, aciklama, kabulde_secilebilir, hasta_bilgilendir
                  from public.v_lab_ret_nedeni
                 where aktif = 1
                 order by sira, kod
                """, null, [], o => new
            {
                kod = (int)o.GetInt16(0), ad = o.GetString(1), aciklama = o.GetString(2),
                kabuldeSecilebilir = o.GetInt16(3) == 1, hastaBilgilendir = o.GetInt16(4) == 1,
            }, iptal);
            return Results.Ok(new { nedenler = liste });
        });

        // POST /api/lab/numune/{id}/durum - alındı (2) / kabul (3) / ret (0).
        //   TAT kabulde başlar; ret satırları "tekrar bekliyor"a alır.
        grup.MapPost("/numune/{id:int}/durum", async (
            int id, NumuneDurumIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var mesaj = await servis.NumuneDurumAsync(id, istek.Durum, istek.Kalite,
                istek.RetNeden, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/numune-durum - İSTEMİN TÜM TÜPLERİ.
        //   Mockup araç çubuğu ("✔ Numune Kabul" / "✖ Numune Ret") istem
        //   satırının üzerindedir: banko hastanın tüplerini birlikte işler.
        grup.MapPost("/istem/{id:int}/numune-durum", async (
            int id, NumuneDurumIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var mesaj = await servis.IstemNumuneDurumAsync(id, istek.Durum, istek.Kalite,
                istek.RetNeden, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/istem/{id}/saklama - tüplerin saklama yeri/sıcaklığı.
        //   Mockup "🧊 Saklama Yeri": çalışılmayı bekleyen tüp nerede duruyor?
        //   Kayıtsız buzdolabı, tekrar çalışma gerektiğinde numuneyi
        //   bulunamaz hâle getirir.
        grup.MapPost("/istem/{id:int}/saklama", async (
            int id, SaklamaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Degistir);

            var yer = (istek.Yer ?? "").Trim();
            if (yer.Length == 0)
                throw GentegreHatasi.Dogrulama("Saklama yeri zorunlu.",
                    [new("yer", "Saklama yeri boş bırakılamaz.")]);

            var say = await veri.CalistirAsync("""
                update public.lab_numune
                   set saklama_yeri = @p1, saklama_sicaklik = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where istem_id = @p0 and ret = 0
                """, [id, yer, istek.Sicaklik, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, say,
                mesaj = say == 0 ? "Güncellenecek tüp bulunamadı."
                                 : $"{say} tüp için saklama yeri: {yer}.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/numune/barkod/{barkod} - barkod okutunca kabul ekranı.
        grup.MapGet("/numune/barkod/{barkod}", async (
            string barkod, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);

            var n = await veri.TekAsync("""
                select n.id, n.barkod, n.durum, n.numune_tipi, n.tup_tipi,
                       n.istem_id, i.istem_no, i.oncelik, n.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120)),
                       n.alim_zamani, n.kabul_zamani,
                       (select count(*) from public.lab_istem_satir s
                         where s.numune_id = n.id and s.durum <> 0)
                  from public.lab_numune n
                  join public.lab_istem i on i.id = n.istem_id
                  join public.taraf h on h.id = n.hasta_id
                 where n.barkod = @p0
                """, [barkod],
                o => new { Id = o.GetInt32(0), Barkod = o.GetString(1),
                           Durum = o.GetInt16(2), NumuneTipi = o.GetInt16(3),
                           TupTipi = o.GetInt16(4), IstemId = o.GetInt32(5),
                           IstemNo = o.GetString(6), Oncelik = o.GetInt16(7),
                           HastaId = o.GetInt32(8), Hasta = o.GetString(9),
                           Alim = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
                           Kabul = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                           Tetkik = o.GetInt64(12) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi($"'{barkod}' barkodlu numune yok.");

            return Results.Ok(new { n.Id, n.Barkod, n.Durum, n.NumuneTipi, n.TupTipi,
                                    n.IstemId, n.IstemNo, n.Oncelik, n.HastaId, n.Hasta,
                                    n.Alim, n.Kabul, n.Tetkik,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
