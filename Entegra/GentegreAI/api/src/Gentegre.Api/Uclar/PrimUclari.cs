using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PRİM / HAKEDİŞ uçları (324/325).
///
/// Hesabın kendisi veritabanındadır (fn_prim_uret + tetikler): tahsilat
/// dağıtımı yazıldığında prim kendiliğinden doğar. Buradaki uçlar iki iş
/// yapar - kalemin ROLLERİNİ yazmak (primi kim hak ediyor) ve dönemi
/// KAPATMAK (satırları dondurmak).
/// </summary>
public static class PrimUclari
{
    /// <summary>Kalemin rol satırı: kim, hangi rolde, hangi payla.</summary>
    public sealed record RolSatiri(short Rol, int TarafId, decimal? PayYuzde);
    public sealed record RolIstegi(IReadOnlyList<RolSatiri> Satirlar);

    /// <summary>Dönem kapatma: kişinin açık hakediş satırlarını dondurur.</summary>
    public sealed record DonemIstegi(int TarafId, DateTime Baslangic, DateTime Bitis);

    private static IDictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
    }

    public static void PrimUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/prim").WithTags("Prim").RequireAuthorization();

        // ------------------------------------------------- kalem rolleri ----
        // GET /api/prim/kalem/{belgeSatirId}/roller
        grup.MapGet("/kalem/{satirId:int}/roller", async (
            int satirId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var satirlar = await baglanti.ListeAsync("""
                select r.id, r.rol, coalesce(kd.ad, '') as "rolAdi",
                       r.taraf_id as "tarafId", coalesce(t.unvan, '') as kisi,
                       r.pay_yuzde as "payYuzde", r.kaynak
                  from public.belge_satir_rol r
                  left join public.taraf t on t.id = r.taraf_id
                  left join public.kod_liste kl on kl.kod = 'prim.rol'
                  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = r.rol
                 where r.belge_satir_id = @p0
                 order by r.rol, r.id
                """, null, [satirId], Satir, iptal);

            // Bu kalemden DOGMUS primler: rol degistirilince ne olacagini
            //   kullanici gormeli (kesinlesmis satir yeniden hesaplanmaz).
            var primler = await baglanti.ListeAsync("""
                select hs.id, hs.taraf_id as "tarafId", coalesce(t.unvan, '') as kisi,
                       hs.rol, hs.tarih, hs.taban, hs.deger, hs.tutar, hs.durum
                  from public.hakedis_satir hs
                  left join public.taraf t on t.id = hs.taraf_id
                 where hs.belge_satir_id = @p0 and hs.durum <> 0
                 order by hs.id
                """, null, [satirId], Satir, iptal);

            return Results.Ok(new { satirlar, primler });
        });

        // POST /api/prim/kalem/{satirId}/roller — TOPLU yazar.
        //   Roller kalemin etiketidir: eksik gönderilen satır SİLİNMİŞ sayılır.
        //   Yazımdan sonra o kalemin tahsilat dağıtımları yeniden hesaplanır -
        //   rol değişince primin de değişmesi gerekir.
        grup.MapPost("/kalem/{satirId:int}/roller", async (
            int satirId, RolIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);

            var satirlar = (istek.Satirlar ?? []).Where(x => x.TarafId > 0 && x.Rol > 0).ToList();

            // Ayni rolde toplam pay %100'u asmamali: iki cerrah %50/%50 olur,
            //   %70/%70 olmaz - yoksa kalemden hak edilenden fazla prim doğar.
            foreach (var g in satirlar.GroupBy(x => x.Rol))
            {
                var toplam = g.Sum(x => x.PayYuzde ?? 100);
                if (toplam > 100.005m)
                    throw GentegreHatasi.IsKurali(
                        $"Aynı roldeki pay yüzdeleri toplamı %100'ü aşamaz (bulunan: %{toplam:0.##}).");
            }

            await using var baglanti = await veri.AcAsync(iptal);
            await using var tx = await baglanti.BeginTransactionAsync(iptal);

            await baglanti.CalistirAsync(
                "delete from public.belge_satir_rol where belge_satir_id = @p0",
                tx, [satirId], iptal);

            foreach (var sa in satirlar)
                await baglanti.CalistirAsync("""
                    insert into public.belge_satir_rol
                           (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak, ekleyen)
                    values (@p0, @p1, @p2, coalesce(@p3, 100), 1, @p4)
                    on conflict (belge_satir_id, rol, taraf_id)
                    do update set pay_yuzde = excluded.pay_yuzde
                    """, tx, [satirId, sa.Rol, sa.TarafId, sa.PayYuzde, baglam.KullaniciId], iptal);

            await tx.CommitAsync(iptal);

            // Primi tazele: rol degisti, hakedis satiri da degismeli.
            var uretilen = await baglanti.TekDegerAsync<int>("""
                select coalesce(sum(public.fn_prim_uret(d.id)), 0)
                  from public.kasa_islem_dagitim d where d.belge_satir_id = @p0
                """, null, [satirId], iptal);

            return Results.Ok(new { satirSayisi = satirlar.Count, primSatiri = uretilen });
        });

        // --------------------------------------------------- dönem kapat ----
        // POST /api/prim/donem-kapat
        //   Kişinin o dönemdeki AÇIK hakediş satırlarını bir başlığa bağlar ve
        //   dondurur. Geri alınamaz olduğu için ayrı yetki ister.
        grup.MapPost("/donem-kapat", async (
            DonemIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Degistir);
            baglam.AksiyonIste("prim.donem_kapat");

            if (istek.TarafId <= 0)
                throw GentegreHatasi.IsKurali("Hakedişi kapatılacak kişi seçilmeli.");
            if (istek.Bitis < istek.Baslangic)
                throw GentegreHatasi.IsKurali("Dönem bitişi başlangıçtan önce olamaz.");

            await using var baglanti = await veri.AcAsync(iptal);

            var id = await baglanti.TekDegerAsync<int>("""
                select public.fn_hakedis_kapat(@p0, @p1::date, @p2::date, @p3, @p4)
                """, null,
                [istek.TarafId, istek.Baslangic, istek.Bitis,
                 baglam.KullaniciId, baglam.SubeId], iptal);

            var kayit = await baglanti.TekAsync("""
                select h.id, h.toplam, h.donem_baslangic as "donemBaslangic",
                       h.donem_bitis as "donemBitis",
                       (select count(*) from public.hakedis_satir s where s.hakedis_id = h.id)
                       as "satirSayisi"
                  from public.hakedis h where h.id = @p0
                """, null, [id], Satir, iptal);

            return Results.Ok(kayit);
        });

        // ------------------------------------------------ açık hakedişler ---
        // Dönem kapatma ekranı için: kişi bazında açık (dondurulmamış) tutar.
        grup.MapGet("/acik", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("prim", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            return Results.Ok(await baglanti.ListeAsync("""
                select o.taraf_id as "tarafId", o.kisi, o.acik_satir as "acikSatir",
                       o.acik_tutar as "acikTutar", o.kesin_tutar as "kesinTutar",
                       o.ilk_tarih as "ilkTarih", o.son_tarih as "sonTarih"
                  from public.v_hakedis_ozet o
                 where o.acik_tutar > 0
                 order by o.acik_tutar desc
                """, null, [], Satir, iptal));
        });
    }
}
