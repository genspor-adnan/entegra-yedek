using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE TANILARI — bkz. <c>MuayeneUclari</c>.
///
/// <para>Tanı listesi, ekleme / silme, ICD arama ve geçmişten öneri. <b>Ana tanı
/// tektir</b> ve tamamlamanın ön koşuludur; öneriler hastanın kendi
/// geçmişinden gelir - "sık yazılan tanı" listesi hekimi başka hastanın
/// tanısına yaklaştırırdı.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void TaniUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/tanilar - kartın tanı satırları (araç
        //   çubuğundaki "sil" için: hangi satırın kaldırılacağı SUNUCUDAN
        //   gelen listeden seçilir, ekranın elindeki taslaktan değil).
        grup.MapGet("/{id:int}/tanilar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);
            var satirlar = await baglanti.ListeAsync(
                "select t.id, t.icd_kod, coalesce(i.ad, '') as ad, t.tur " +
                "  from public.tani t " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where t.muayene_id = @p0 " +
                " order by t.tur asc, t.sira asc, t.id asc",
                null, [id],
                o => new { id = o.GetInt32(0), kod = o.GetString(1),
                           ad = o.GetString(2), tur = o.GetInt16(3) }, iptal);

            return Results.Ok(new { id, tanilar = satirlar, izlemeNo = baglam.IzlemeNo });
        });

        // DELETE /api/muayene/{id}/tani/{taniId} - tanı satırını kaldır
        //   Kart üzerinden de silinebilir; araç çubuğundaki sil AYNI ucu
        //   kullanır ki silme izi (log) tek yoldan geçsin.
        grup.MapDelete("/{id:int}/tani/{taniId:int}", async (
            int id, int taniId, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AÇIK MUAYENE (kod inceleme 30.10.2026 K34): tamamlanmış muayenenin tanısı da silinmez.
            await MuayeneAcikIsteAsync(baglanti, islem, id, iptal);

            // SİLME LOGU DELETE'TEN ÖNCE, TAM SATIRLA (kod inceleme 30.10.2026 K34; proje kuralı "Geri Al"):
            //   silinen tanı sonradan yalnız logdan okunabilir. Log ve silme tek transaction.
            var satir = await baglanti.TekAsync(
                "select t.*, (select m.taraf_id from public.muayene m where m.id = t.muayene_id) as hasta_id " +
                "  from public.tani t where t.id = @p0 and t.muayene_id = @p1 for update of t",
                islem, [taniId, id], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (satir is null) return Results.NotFound(new { hata = new
                { kod = "BULUNAMADI", mesaj = "Tani satiri bulunamadi." } });

            var hastaId = satir["hasta_id"] is { } h ? Convert.ToInt32(h) : (int?)null;
            satir.Remove("hasta_id");
            await log.YazAsync(baglanti, islem, LogIslemi.Sil, LogTani, taniId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                satir.ToDictionary(d => d.Key, d => (object?)LogDeposu.Metin(d.Value)),
                ustTabloId: LogMuayene, ustKayitId: id, tarafId: hastaId, iptal: iptal);

            await baglanti.CalistirAsync(
                "delete from public.tani where id = @p0 and muayene_id = @p1",
                islem, [taniId, id], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, taniId, mesaj = "Tani kaldirildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/muayene/{id}/tani-onerileri - mockup "⭐ Sık kullandıklarım"
        //   ve "🕘 Önceki tanılar" listeleri.
        //
        //   ÖNCEKİ: bu HASTANIN başka muayenelerinde yazılmış tanılar. Kronik
        //   hastada tanı her muayenede yeniden yazılıyordu; kod aramak yerine
        //   listeden seçmek hem hızlı hem de kodun aynı kalmasını sağlıyor
        //   (aynı hastalık iki ayrı ICD ile yazılınca rapor ikiye bölünür).
        //   SIK: bu HEKİMİN son 90 günde en çok yazdığı kodlar - poliklinikte
        //   tanı dağılımı dardır, ilk beş kod işin çoğunu görür.
        grup.MapGet("/{id:int}/tani-onerileri", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var onceki = await baglanti.ListeAsync(
                "select t.icd_kod, coalesce(i.ad, '') as ad, max(t.kronik) as kronik, " +
                "       max(m.muayene_tarihi)::date::text as son " +
                "  from public.tani t " +
                "  join public.muayene m on m.id = t.muayene_id " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where m.taraf_id = (select taraf_id from public.muayene where id = @p0) " +
                "   and m.id <> @p0 " +
                " group by t.icd_kod, i.ad " +
                " order by max(m.muayene_tarihi) desc limit 20",
                null, [id],
                o => new { kod = o.GetString(0), ad = o.GetString(1),
                           kronik = o.GetInt32(2), son = o.GetString(3) }, iptal);

            var sik = await baglanti.ListeAsync(
                "select t.icd_kod, coalesce(i.ad, '') as ad, count(*)::int as adet " +
                "  from public.tani t " +
                "  join public.muayene m on m.id = t.muayene_id " +
                "  left join public.icd i on i.kod = t.icd_kod " +
                " where m.personel_id = (select personel_id from public.muayene where id = @p0) " +
                "   and m.muayene_tarihi >= now() - interval '90 days' " +
                " group by t.icd_kod, i.ad " +
                " order by count(*) desc, max(m.muayene_tarihi) desc limit 15",
                null, [id],
                o => new { kod = o.GetString(0), ad = o.GetString(1), adet = o.GetInt32(2) }, iptal);

            return Results.Ok(new { id, onceki, sik, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapGet("/tani-secenekleri", async (
            BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            // TÜR SEÇİCİSİ = KESİN / ÖN TANI (kullanıcı). Ana/ek ayrımı sunucuda
            //   (ilk tanı ana, sonrakiler ek); Ön Tanı SKRS tür 3 + kesinlik 2.
            var kesinlikler = new[] { new { kod = 1, ad = "Kesin Tanı" }, new { kod = 2, ad = "Ön Tanı" } };
            var taraflar = Cekirdek.Katalog.KartKatalogu.TaniTarafKodlari
                .Select(k => new { kod = int.Parse(k.Key, System.Globalization.CultureInfo.InvariantCulture), ad = k.Value });
            return Results.Ok(new { kesinlikler, taraflar, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/{id:int}/tani/{icdKod}", async (
            int id, string icdKod, TaniEkleIstegi? istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // AÇIK MUAYENE (kod inceleme 30.10.2026 K34): tamamlanmış muayeneye tanı eklenmez (422).
            await MuayeneAcikIsteAsync(baglanti, islem, id, iptal);

            var kodVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.icd where kod = @p0", islem, [icdKod], iptal);
            if (kodVar == 0)
                throw GentegreHatasi.Dogrulama($"ICD kodu bulunamadi: {icdKod}");

            // SEÇİLEN TÜR / TARAF (penceredeki seçiciler). Tür SKRS listesinde,
            //   taraf katalog kodlarında olmalı; verilmezse eski kural.
            if (istek?.Tur is short istenenTur)
            {
                var turVar = await baglanti.TekDegerAsync<int>("""
                    select count(*) from public.kod_deger kd
                      join public.kod_liste kl on kl.id = kd.liste_id
                     where kl.kod = 'tani.turu' and kd.aktif = 1 and kd.deger = @p0
                    """, islem, [(int)istenenTur], iptal);
                if (turVar == 0)
                    throw GentegreHatasi.Dogrulama($"Gecersiz tani turu: {istenenTur}");
            }
            // KESİNLİK (penceredeki Kesin / Ön Tanı): Ön tanı, tür verilmediyse
            //   SKRS tür 3 (Ön Tanı) olarak yazılır - e-Nabız türü okur.
            var kesinlik = istek?.Kesinlik ?? 1;
            if (!Cekirdek.Katalog.KartKatalogu.TaniKesinlikSecenekleri.ContainsKey(
                    kesinlik.ToString(System.Globalization.CultureInfo.InvariantCulture)))
                throw GentegreHatasi.Dogrulama($"Gecersiz kesinlik: {kesinlik}");
            var taraf = istek?.Taraf ?? 0;
            if (!Cekirdek.Katalog.KartKatalogu.TaniTarafKodlari.ContainsKey(
                    taraf.ToString(System.Globalization.CultureInfo.InvariantCulture)))
                throw GentegreHatasi.Dogrulama($"Gecersiz taraf: {taraf}");

            var zaten = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and icd_kod = @p1",
                islem, [id, icdKod], iptal);
            if (zaten > 0)
                return Results.Ok(new { id, icdKod, eklendi = false,
                                        mesaj = "Bu tani zaten listede.",
                                        izlemeNo = baglam.IzlemeNo });

            var anaVar = await baglanti.TekDegerAsync<int>(
                "select count(*) from public.tani where muayene_id = @p0 and tur = 1",
                islem, [id], iptal);

            // Tür seçilmediyse: ilk tanı ANA, sonrakiler EK. ANA seçildi ama
            //   ana tanı zaten varsa EK yazılır (muayene başına tek ana tanı -
            //   ux_tani_ana); mevcut ana tanı sessizce değişmez.
            int tur = istek?.Tur ?? (kesinlik == 2 ? 3 : anaVar > 0 ? 2 : 1);
            var anaDustu = tur == 1 && anaVar > 0;
            if (anaDustu) tur = 2;

            await baglanti.CalistirAsync(
                "insert into public.tani (muayene_id, icd_kod, tur, kesinlik, taraf, ekleyen) " +
                "values (@p0, @p1, @p2, @p3, @p4, @p5)",
                islem, [id, icdKod, tur, (int)kesinlik, (int)taraf, baglam.KullaniciId], iptal);
            await islem.CommitAsync(iptal);

            return Results.Ok(new { id, icdKod, eklendi = true, tur,
                                    mesaj = anaDustu ? "Ana tani zaten var - ek tani olarak eklendi."
                                          : tur == 1 ? "Ana tani eklendi."
                                          : tur == 3 ? "On tani eklendi." : "Tani eklendi.",
                                    izlemeNo = baglam.IzlemeNo });
        });
    }
}
