using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ODONTOGRAM YAZIMI (706). Üç katman tek tabloda; yazma kuralı tek yerde:
/// <list type="bullet">
/// <item>Bulgu (katman 1): aynı diş + aynı yüzey kümesindeki eski aktif satır
/// pasifleşir, yenisi yazılır. Geçmiş silinmez.</item>
/// <item>Planlanan (katman 2): plan satırı eklenince yazılır, satır iptal
/// olunca pasifleşir.</item>
/// <item>Tamamlanan (katman 3): satır "yapıldı" olunca; hizmet kartındaki
/// <c>odontogram_sonuc_kod</c> doluysa dişin MEVCUT durumu da o koda döner
/// (kron yapıldı → diş artık "kron").</item>
/// </list>
/// </summary>
public static partial class DisUclari
{
    public sealed record BulguIstegi(int DisNo, string? Yuzeyler, int DurumKod, int? Kaynak,
                                     string? Not, int? MuayeneId, int? Dentisyon);

    private static void OdontogramUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------------- bulgu yaz ----
        grup.MapPost("/hasta/{hastaId:int}/bulgu", async (
            int hastaId, BulguIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.hasta", Islem.Degistir);
            DisNoDogrula(istek.DisNo, sifirOlur: false);
            var yuzey = YuzeyNormalle(istek.Yuzeyler);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var id = await BulguYazAsync(baglanti, islem, baglam, hastaId, istek.DisNo, yuzey,
                (short)istek.DurumKod, (short)(istek.Kaynak ?? 1), istek.Not ?? "",
                istek.MuayeneId, null, null, (short)(istek.Dentisyon ?? 1), iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloOdontogram, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { disNo = istek.DisNo, yuzey, durumKod = istek.DurumKod }, tarafId: hastaId, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { id });
        });

        // ------------------------------------------------ bulguyu pasifleştir ----
        grup.MapDelete("/odontogram/{id:int}", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.hasta", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            var satir = await baglanti.TekAsync(
                "select hasta_id, katman, plan_satir_id from public.dis_odontogram where id = @p0 and aktif = 1",
                null, [id], o => new { hastaId = o.GetInt32(0), katman = o.GetInt16(1),
                                       planSatirId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi();
            // Planlanan/tamamlanan katmanı elle silinmez: kaynağı plan satırıdır.
            if (satir.katman != 1)
                throw GentegreHatasi.IsKurali("Planlanan / tamamlanan işaret plan satırından yönetilir; bulgu değil.");
            await baglanti.CalistirAsync("""
                update public.dis_odontogram set aktif = 0, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Sil, LogTabloOdontogram, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { pasif = true }, tarafId: satir.hastaId, iptal: iptal);
            return Results.NoContent();
        });
    }

    /// <summary>Katman 1 yazımı: aynı diş+yüzeydeki aktif mevcut durum pasifleşir.</summary>
    private static async Task<int> BulguYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IstekBaglami baglam, int hastaId, int disNo, string yuzey, short durumKod, short kaynak,
        string notMetin, int? muayeneId, int? seansId, int? planSatirId, short dentisyon,
        CancellationToken iptal)
    {
        // Yüzey '' = tüm diş: dişin bütün eski mevcut durumları kapanır (eksik,
        //   kron, implant dişin tamamını anlatır). Yüzeyli bulgu yalnız aynı
        //   yüzey kümesini kapatır - "O çürük" varken "D çürük" ikisi de kalır.
        await baglanti.CalistirAsync("""
            update public.dis_odontogram
               set aktif = 0, degistiren = @p3, degistirme_tarihi = now()
             where hasta_id = @p0 and dis_no = @p1 and katman = 1 and aktif = 1
               and (@p2 = '' or yuzeyler = @p2 or yuzeyler = '')
            """, islem, [hastaId, disNo, yuzey, baglam.KullaniciId], iptal);

        return await baglanti.TekDegerAsync<int>("""
            insert into public.dis_odontogram
                   (sube_id, hasta_id, dis_no, dentisyon, yuzeyler, durum_kod, katman, kaynak,
                    muayene_id, seans_id, plan_satir_id, not_metin, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6, @p7, @p8, @p9, @p10, @p11)
            returning id
            """, islem, [baglam.SubeId ?? 0, hastaId, disNo, dentisyon, yuzey, durumKod, kaynak,
                         muayeneId, seansId, planSatirId, notMetin, baglam.KullaniciId], iptal);
    }

    /// <summary>Katman 2/3 satırı - plan satırına bağlı işaret.</summary>
    private static async Task<int> KatmanYazAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        IstekBaglami baglam, int hastaId, int disNo, string yuzey, short katman, short durumKod,
        int planSatirId, int? seansId, CancellationToken iptal)
        => await baglanti.TekDegerAsync<int>("""
            insert into public.dis_odontogram
                   (sube_id, hasta_id, dis_no, yuzeyler, durum_kod, katman, kaynak,
                    seans_id, plan_satir_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, 5, @p6, @p7, @p8)
            returning id
            """, islem, [baglam.SubeId ?? 0, hastaId, disNo, yuzey, durumKod, katman,
                         seansId, planSatirId, baglam.KullaniciId], iptal);

    private static void DisNoDogrula(int disNo, bool sifirOlur)
    {
        if (disNo == 0 && sifirOlur) return;
        var cene = disNo / 10; var sira = disNo % 10;
        var daimi = cene is >= 1 and <= 4 && sira is >= 1 and <= 8;
        var sut   = cene is >= 5 and <= 8 && sira is >= 1 and <= 5;
        if (!daimi && !sut)
            throw GentegreHatasi.Dogrulama($"Diş numarası FDI biçiminde olmalı (11-48 daimi, 51-85 süt): {disNo}");
    }

    /// <summary>Yüzey kümesi: M D O I V L harfleri, sıralı, tekrarsız.</summary>
    private static string YuzeyNormalle(string? ham)
    {
        if (string.IsNullOrWhiteSpace(ham)) return "";
        const string sira = "MDOIVL";
        var harfler = ham.ToUpperInvariant().Where(c => sira.Contains(c)).Distinct()
                         .OrderBy(c => sira.IndexOf(c));
        return string.Concat(harfler);
    }
}
