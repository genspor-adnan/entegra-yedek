using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SARF / KONTRAST — malzeme düşümü ve kontrast kaydı.
///
/// Uclar RadyolojiUclari.cs dosyasindan ayrildi: tek dosyada 1956 satiri
/// buluyordu ve bir ucun nerede bittigini gormek, aradigini
/// bulmaktan uzun suruyordu. Kod degismedi, yalniz yer degistirdi.
/// </summary>
public static partial class RadyolojiUclari
{
    private static void SarfVeKontrastEkle(RouteGroupBuilder grup)
    {
        // --------------------------------------------- sarf / kontrast ----
        // CEKIM SONRASI SARF (320). Oneri protokolun malzeme listesinden gelir
        //   (v_radyoloji_protokol_malzeme); gercek kullanim teknisyenin
        //   onayindan gecer - kontrast miktari hastanin kilosuna gore degisir,
        //   damar yolu ikinci kanul gerektirebilir.
        grup.MapGet("/istem/{id:int}/sarf", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var aktif = await AyarDeposu.MetinAsync(baglanti, null,
                                                    "radyoloji.sarf_aktif", "1", iptal);
            var depoAyar = await AyarDeposu.MetinAsync(baglanti, null,
                                                       "radyoloji.sarf_depo", "", iptal);

            // DEPO: ayarda yazan depo, yoksa varsayilan isaretli depo, o da
            //   yoksa ilk aktif depo. Sarf hangi depodan dustugunu bilmeden
            //   yazilamaz.
            var depo = await baglanti.TekAsync("""
                select d.id, d.ad
                  from public.depo d
                 where d.id = coalesce(nullif(@p0, '')::int,
                              (select min(x.id) from public.depo x
                                where x.varsayilan = 1 and coalesce(x.durum, 1) = 1),
                              (select min(x.id) from public.depo x
                                where coalesce(x.durum, 1) = 1))
                """, null, [depoAyar], OkuyucuGenisletmeleri.Sozluk, iptal);
            var depoId = depo is null ? (int?)null : Convert.ToInt32(depo["id"]);

            // Istemin CD istegi (311): "istenirse" tipli malzeme (CD) yalniz
            //   kabulde isaretlenmisse onerilir.
            var istem = await baglanti.TekAsync("""
                select i.hizmet_id as "hizmetId", i.accession_no as "accessionNo",
                       coalesce(i.cd_istendi, 0) as "cdIstendi",
                       coalesce(i.kontrast, 0) as kontrast,
                       coalesce(i.kontrast_ml, 0) as "kontrastMl", i.durum
                  from public.radyoloji_istem i where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            var satirlar = await baglanti.ListeAsync("""
                select m.stok_id as "stokId", m.stok_kod as "kod", m.stok_ad as "ad",
                       m.birim, m.izleme, m.miktar as "protokolMiktar",
                       m.dusum_tipi as "dusumTipi", m.kural,
                       coalesce(sd.kalan, 0) as kalan,
                       coalesce(sd.min_stok, 0) as "minStok"
                  from public.v_radyoloji_protokol_malzeme m
                  join public.radyoloji_protokol p on p.id = m.protokol_id
                  left join public.stok_durum sd
                         on sd.stok_id = m.stok_id and sd.depo_id = @p1
                 where p.hizmet_id = @p0
                 order by m.sira, m.stok_id
                """, null, [istem["hizmetId"], depoId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // IZLEMLI (lot/seri) stoklarin o depodaki bakiyeleri: modal lot
            //   sectirir, SKT'si en yakin olan basa gelir (ilk giren ilk cikar
            //   degil - MIADI once dolan once kullanilir).
            var lotlar = await baglanti.ListeAsync("""
                select l.stok_id as "stokId", sl.lot_no as "lotNo", sl.seri_no as "seriNo",
                       l.seri_lot_id as "seriLotId",
                       sl.son_kullanma_tarihi as "sonKullanmaTarihi", l.kalan
                  from public.stok_lot_durum l
                  join public.stok_seri_lot sl on sl.id = l.seri_lot_id
                 where l.depo_id = @p1 and l.kalan > 0
                   and l.stok_id in (select m.stok_id
                                       from public.v_radyoloji_protokol_malzeme m
                                       join public.radyoloji_protokol p on p.id = m.protokol_id
                                      where p.hizmet_id = @p0 and m.izleme > 0)
                 order by sl.son_kullanma_tarihi nulls last, sl.id
                """, null, [istem["hizmetId"], depoId], OkuyucuGenisletmeleri.Sozluk, iptal);

            var dusulen = await baglanti.ListeAsync("""
                select s.stok_id as "stokId", s.miktar, s.belge_id as "belgeId",
                       s.ekleme_tarihi as "zaman"
                  from public.radyoloji_sarf s where s.istem_id = @p0
                 order by s.id
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                aktif = aktif == "1",
                depoId, depoAdi = depo?["ad"] as string ?? "",
                accessionNo = istem["accessionNo"],
                cdIstendi = Convert.ToInt32(istem["cdIstendi"]),
                kontrastMl = istem["kontrastMl"],
                satirlar, lotlar, dusulen,
            });
        });

        // SARFI DUS (320): mevcut belge hattindan STOK CIKIS FISI (tur 4)
        //   uretilir - stok_durum, lot bakiyesi ve maliyet orada cozuluyor.
        //   Radyolojiye ikinci bir stok mantigi yazilmaz.
        grup.MapPost("/istem/{id:int}/sarf", async (
            int id, SarfIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            BelgeDeposu belgeDepo, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("radyoloji", Islem.Degistir);
            baglam.YetkiIste("stok", Islem.Degistir);

            var satirlar = (istek.Satirlar ?? []).Where(x => x.Miktar > 0).ToList();
            if (satirlar.Count == 0)
                throw GentegreHatasi.IsKurali("Düşülecek malzeme seçilmedi.");

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.accession_no as "accessionNo", i.sube_id as "subeId",
                       coalesce(hz.ad, '') as tetkik
                  from public.radyoloji_istem i
                  left join public.hizmet hz on hz.id = i.hizmet_id
                 where i.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            var depoAyar = await AyarDeposu.MetinAsync(baglanti, null,
                                                       "radyoloji.sarf_depo", "", iptal);
            var depoId = istek.DepoId
                ?? await baglanti.TekDegerAsync<int?>("""
                    select coalesce(nullif(@p0, '')::int,
                           (select min(x.id) from public.depo x
                             where x.varsayilan = 1 and coalesce(x.durum, 1) = 1),
                           (select min(x.id) from public.depo x
                             where coalesce(x.durum, 1) = 1))
                    """, null, [depoAyar], iptal)
                ?? throw GentegreHatasi.IsKurali(
                    "Sarf çıkışı için depo bulunamadı - Genel Ayarlar'dan sarf deposunu seçin.");

            // ---------------------------------------------- cikis fisi ----
            var fis = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                // 4 = Stok Cikis Fisi: carisiz, yalniz stok yonu verir.
                ["tur"] = 4,
                ["tipi"] = 1,
                ["belgeTarihi"] = DateTime.Now,
                ["belgeDovizi"] = "TL",
                ["dovizKuru"] = 1m,
                ["cikisDepoId"] = depoId,
                ["subeId"] = baglam.SubeId ?? istem["subeId"],
                ["aciklama"] = $"Radyoloji sarf · {istem["accessionNo"]} · {istem["tetkik"]}",
            };

            var fisSatirlari = new List<Dictionary<string, JsonElement>>();
            var sira = 0;
            foreach (var sa in satirlar)
            {
                var alanlar = new Dictionary<string, object?>(StringComparer.Ordinal)
                {
                    ["tur"] = 1,                       // 1 = stok kalemi
                    ["stokId"] = sa.StokId,
                    ["miktar"] = sa.Miktar,
                    ["birimFiyat"] = 0m,               // maliyet stok tarafinda
                    ["kdv"] = 0,
                    ["dovizCinsi"] = "TL",
                    ["cikisDepoId"] = depoId,
                    ["aciklama"] = istem["accessionNo"],
                    ["sira"] = ++sira,
                };
                if (sa.Izlemler is { Count: > 0 })
                    alanlar["izlemler"] = sa.Izlemler.Select(z => new Dictionary<string, object?>
                    {
                        ["seriLotId"] = z.SeriLotId,
                        ["miktar"] = z.Miktar,
                    }).ToList();
                fisSatirlari.Add(BelgeGovdesi.Satir(alanlar));
            }

            var (belgeId, uyarilar) = await belgeDepo.KaydetAsync(
                fis, fisSatirlari,
                // Stok kontrolu ACIK. Negatif bakiyede ENGEL mi UYARI mi olacagi
                //   kurum ayarina bagli (Genel Ayarlar > Stok: negatif stok);
                //   varsayilan uyaridir ve `uyarilar` icinde cagirana doner.
                new BelgeSecenekleri { Taslak = false, StokKontrolu = true },
                new YazmaBaglami(baglam.KullaniciId, baglam.SubeId, baglam.Ip), iptal);

            foreach (var sa in satirlar)
                await baglanti.CalistirAsync("""
                    insert into public.radyoloji_sarf
                           (istem_id, belge_id, stok_id, miktar, depo_id, ekleyen)
                    values (@p0, @p1, @p2, @p3, @p4, @p5)
                    """, null,
                    [id, belgeId, sa.StokId, sa.Miktar, depoId, baglam.KullaniciId], iptal);

            // KRITIK STOK: dusumden sonra kalan, stok_durum.min_stok altina
            //   indiyse uyari doner - satin alma talebini kullanici acar.
            var kritik = await baglanti.ListeAsync("""
                select coalesce(s.ad, '') as ad, sd.kalan, sd.min_stok as "minStok"
                  from public.stok_durum sd
                  join public.stok s on s.id = sd.stok_id
                 where sd.depo_id = @p0 and sd.stok_id = any(@p1)
                   and coalesce(sd.min_stok, 0) > 0 and sd.kalan <= sd.min_stok
                """, null, [depoId, satirlar.Select(x => x.StokId).ToArray()], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { belgeId, uyarilar, kritik });
        });
    }
}
