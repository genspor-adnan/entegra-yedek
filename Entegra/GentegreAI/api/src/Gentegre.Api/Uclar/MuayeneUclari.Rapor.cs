using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE RAPORLARI — bkz. <c>MuayeneUclari</c>.
///
/// <para>Rapor ekleme / silme / e-imza. <b>İmzalanmış rapor silinmez</b> (durumu
/// iptale döner): imzalı belgeyi kaydın içinden yok etmek, dışarıya çıkmış
/// bir evrakın izini silmek olurdu.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void RaporUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/raporlar - kartın raporları (imza seçimi için)
        grup.MapGet("/{id:int}/raporlar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync(
                "select r.id, r.tur, r.alt_tur as \"altTur\", r.baslangic, r.bitis, r.gun, " +
                "       r.icd_kod as \"icdKod\", r.aciklama, r.durum, " +
                "       r.imza_zamani as \"imzaZamani\" " +
                "  from public.muayene_rapor r where r.muayene_id = @p0 " +
                " order by r.id desc",
                null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { id, raporlar = satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/rapor - yeni TASLAK rapor (mockup rapor araç
        //   çubuğu "＋ Rapor" / "📋 Rapor şablonu ▾"). Tür şablonu seçilir;
        //   satır grid'de açılır, hekim tarih/gün/açıklama/ICD'yi doldurup
        //   e-İmzalar. hasta/hekim/şube muayeneden gelir.
        grup.MapPost("/{id:int}/rapor", async (
            int id, RaporEkleIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);

            var gun = istek.Gun ?? 0;
            var yeniId = await baglanti.TekDegerAsync<int?>(
                "insert into public.muayene_rapor " +
                "  (muayene_id, hasta_id, hekim_id, tur, alt_tur, baslangic, bitis, gun, " +
                "   aciklama, icd_kod, durum, sube_id, ekleyen, rapor_no) " +
                "select m.id, m.taraf_id, m.personel_id, @p1::smallint, @p2::smallint, " +
                "       coalesce(@p5::date, current_date), " +
                // Bitiş verilmişse o; yoksa gün>0 ise başlangıç+gün-1 (istirahat dâhil).
                "       coalesce(@p6::date, case when @p7 > 0 " +
                "            then coalesce(@p5::date, current_date) + (@p7 - 1) else null end), " +
                "       @p7::smallint, @p8, @p9, 1, coalesce(m.sube_id, @p3), @p4, '' " +
                "  from public.muayene m where m.id = @p0 " +
                "returning id",
                null, [id, istek.Tur, istek.AltTur ?? 0, baglam.SubeId ?? 0, baglam.KullaniciId,
                       string.IsNullOrWhiteSpace(istek.Baslangic) ? null : istek.Baslangic,
                       string.IsNullOrWhiteSpace(istek.Bitis) ? null : istek.Bitis,
                       gun, istek.Aciklama ?? "", istek.IcdKod ?? ""], iptal);

            if (yeniId is null)
                return Results.NotFound(new { hata = new { kod = "BULUNAMADI", mesaj = "Muayene bulunamadı." } });

            return Results.Ok(new { raporId = yeniId.Value,
                                    mesaj = "Taslak rapor eklendi - tarih/gün/açıklama girip e-İmzalayın.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/muayene/rapor/{raporId} - TASLAK rapor sil (mockup "🗑").
        //   İmzalı/onaylı rapor silinmez (yasal kayıt).
        grup.MapDelete("/rapor/{raporId:int}", async (
            int raporId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);

            var durum = await baglanti.TekDegerAsync<int?>(
                "select durum from public.muayene_rapor where id = @p0", null, [raporId], iptal);
            if (durum is null)
                return Results.NotFound(new { hata = new { kod = "BULUNAMADI", mesaj = "Rapor bulunamadı." } });
            if (durum != 1)
                throw GentegreHatasi.IsKurali("İmzalanmış/onaylı rapor silinemez.");

            await baglanti.CalistirAsync("delete from public.muayene_rapor where id = @p0 and durum = 1",
                null, [raporId], iptal);
            return Results.Ok(new { raporId, mesaj = "Taslak rapor silindi.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/rapor/{raporId}/imzala
        //   İMZA RAPORU KİLİTLER: imzalanan metin SGK'ya giden metindir.
        //   EKSİK RAPOR İMZALANMAZ: tür, başlangıç, gün ve tanı olmadan
        //   rapor Medula'da reddedilir - hatayı imza anında söylemek, günler
        //   sonra "rapor geçersiz" yanıtı almaktan iyidir.
        grup.MapPost("/rapor/{raporId:int}/imzala", async (
            int raporId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var r = await baglanti.TekAsync(
                "select durum, coalesce(tur, 0), baslangic, coalesce(gun, 0), " +
                "       coalesce(icd_kod, '') " +
                "  from public.muayene_rapor where id = @p0 for update",
                islem, [raporId],
                o => new { Durum = o.GetInt16(0), Tur = o.GetInt16(1),
                           Baslangic = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                           Gun = o.GetInt16(3), Icd = o.GetString(4) }, iptal);
            if (r is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Rapor bulunamadi." } });
            if (r.Durum != 1)
                throw GentegreHatasi.IsKurali("Rapor zaten imzalanmis ya da iptal.");

            var eksik = new List<string>();
            if (r.Tur == 0) eksik.Add("tür");
            if (r.Baslangic is null) eksik.Add("başlangıç tarihi");
            if (r.Gun <= 0) eksik.Add("süre (gün)");
            if (r.Icd.Trim().Length == 0) eksik.Add("tanı (ICD-10)");
            if (eksik.Count > 0)
                throw GentegreHatasi.IsKurali(
                    "Rapor imzalanamaz - eksik: " + string.Join(", ", eksik) + ".");

            await baglanti.CalistirAsync(
                "update public.muayene_rapor " +
                "   set durum = 2, imza_zamani = now(), imzalayan = @p1, " +
                "       degistiren = @p1, degistirme_tarihi = now() " +
                " where id = @p0", islem, [raporId, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { raporId, mesaj = "Rapor imzalandi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
