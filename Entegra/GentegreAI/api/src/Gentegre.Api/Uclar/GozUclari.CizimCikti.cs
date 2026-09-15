using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ ŞEMASI — KARŞILAŞTIRMA ve ÇIKTI (705), mockup
/// <c>Ekranlar/Goz/goz_semasi.html</c> araç çubuğu.
///
/// <para><b>Karşılaştırma çizimin asıl işidir.</b> Tek bir şema "bugün ne
/// var"ı söyler; iki şema yan yana "ne değişti"yi söyler — ve göz hekimliğinde
/// kararı değiştiren ikincisidir. Yeni çıkan bir yırtık ile altı aydır duran
/// bir laser skarı aynı damgayla çizilir; ayıran tek şey öncekiyle farktır.</para>
///
/// <para><b>Fark SUNUCUDA hesaplanır</b> ve işaretin türü + saati üzerinden
/// eşleşir. İki ekranın (kart, çıktı) aynı iki çizimden farklı "yeni bulgu"
/// listesi üretmesi, hastaya farklı iki rapor vermek demekti.</para>
///
/// <para><b>Çıktı ayrı uçtur.</b> Basılan belgenin ihtiyacı palet ve araç
/// değil; kurum anteti, hasta kimliği, çizim ve işaret dökümüdür. Aynı ekranı
/// yazdırmaya zorlamak, kâğıda damga paletini basmak olurdu.</para>
/// </summary>
public static partial class GozUclari
{
    private static void CizimCiktiUclariniEkle(RouteGroupBuilder grup)
    {
        // ------------------------------------------------- karşılaştırma ----
        grup.MapGet("/muayene/{id:int}/cizim/karsilastir", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var bu = await baglanti.TekAsync("""
                select gm.hasta_id, mu.muayene_tarihi
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.id = @p0
                """, null, [id], o => new { hastaId = o.GetInt32(0), tarih = o.GetDateTime(1) },
                iptal) ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            // ÖNCEKİ = ÇİZİMİ OLAN en yakın muayene. Çizimsiz muayeneleri
            //   atlamak gerekiyor: "önceki muayene" ile "önceki çizim" aynı
            //   şey değil, hekim her ziyarette çizmiyor.
            var onceki = await baglanti.TekAsync("""
                select gm.id, mu.muayene_tarihi
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                 where gm.hasta_id = @p0 and gm.id <> @p1 and mu.muayene_tarihi < @p2
                   and exists (select 1 from public.goz_cizim c where c.goz_muayene_id = gm.id)
                 order by mu.muayene_tarihi desc
                 limit 1
                """, null, [bu.hastaId, id, bu.tarih],
                o => new { id = o.GetInt32(0), tarih = o.GetDateTime(1) }, iptal);

            if (onceki is null)
                return Results.Ok(new
                {
                    oncekiId = 0, oncekiTarih = (DateTime?)null,
                    semalar = Array.Empty<object>(), degisim = Array.Empty<object>(),
                    aciklama = "Bu hastanın çizimli önceki muayenesi yok.",
                });

            var isaretler = await IsaretleriOkuAsync(baglanti, [id, onceki.id], iptal);

            var oncekiSemalar = isaretler
                .Where(i => i.gozMuayeneId == onceki.id)
                .GroupBy(i => (i.goz, i.semaTuru))
                .Select(g => new
                {
                    goz = g.Key.goz,
                    semaTuru = g.Key.semaTuru,
                    isaretler = g.Select(i => new
                        { i.id, i.sekil, i.tur, i.x, i.y, i.saat, i.renk, i.yol, i.aciklama }),
                })
                .ToArray();

            // FARK: tür + saat ikilisi. Konumun kendisi (0–1 oranı) iki
            //   çizimde asla birebir aynı olmaz - hekim aynı lezyonu bir
            //   piksel yana koyar. Saat kadranı, hekimin zaten konuştuğu
            //   çözünürlüktür: "saat 11'deki kanama duruyor mu".
            var anahtar = (int goz, int sema, int tur, int? saat) =>
                $"{goz}-{sema}-{tur}-{saat?.ToString() ?? "merkez"}";

            var bugun = isaretler.Where(i => i.gozMuayeneId == id).ToArray();
            var eski = isaretler.Where(i => i.gozMuayeneId == onceki.id).ToArray();
            var eskiKume = eski.Select(i => anahtar(i.goz, i.semaTuru, i.tur, i.saat)).ToHashSet();
            var bugunKume = bugun.Select(i => anahtar(i.goz, i.semaTuru, i.tur, i.saat)).ToHashSet();

            var degisim = bugun
                .Select(i => new
                {
                    i.goz, i.semaTuru, i.tur, i.saat,
                    durum = eskiKume.Contains(anahtar(i.goz, i.semaTuru, i.tur, i.saat))
                            ? "duruyor" : "yeni",
                })
                .Concat(eski
                    .Where(i => !bugunKume.Contains(anahtar(i.goz, i.semaTuru, i.tur, i.saat)))
                    .Select(i => new { i.goz, i.semaTuru, i.tur, i.saat, durum = "kayboldu" }))
                .GroupBy(d => (d.goz, d.semaTuru, d.tur, d.saat, d.durum))
                .Select(g => g.First())
                .OrderBy(d => d.goz).ThenBy(d => d.semaTuru).ThenBy(d => d.durum)
                .ToArray();

            var yeni = degisim.Count(d => d.durum == "yeni");
            var kayip = degisim.Count(d => d.durum == "kayboldu");

            return Results.Ok(new
            {
                oncekiId = onceki.id,
                oncekiTarih = onceki.tarih,
                semalar = oncekiSemalar,
                degisim,
                aciklama = yeni == 0 && kayip == 0
                    ? "Önceki çizime göre yeni ya da kaybolan işaret yok."
                    : $"{yeni} yeni, {kayip} kaybolan işaret.",
            });
        });

        // --------------------------------------------------------- çıktı ----
        // Hastaya/dosyaya giden belge: kurum anteti, kimlik, şema ve işaret
        //   dökümü. Ekranın paleti ve araçları KÂĞIDA BASILMAZ.
        grup.MapGet("/muayene/{id:int}/cizim/cikti", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var muayene = await baglanti.TekAsync("""
                select gm.id, mu.id as "muayeneId",
                       coalesce(b.belge_no, mu.muayene_no, '') as protokol,
                       mu.muayene_tarihi as "muayeneTarihi",
                       (mu.tamamlanma is not null) as kapali,
                       coalesce(h.unvan, '') as hasta, coalesce(h.kod, '') as "hastaNo",
                       coalesce(h.vkno, '') as "hastaTc",
                       hs.dogum_tarihi as "dogumTarihi", coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(hk.unvan, '') as hekim,
                       gm.dilate, coalesce(gm.dilatasyon_ilac, '') as "dilatasyonIlac",
                       gm.sube_id as "subeId"
                  from public.goz_muayene gm
                  join public.muayene mu on mu.id = gm.muayene_id
                  left join public.belge b on b.id = mu.belge_id
                  left join public.taraf h on h.id = gm.hasta_id
                  left join public.taraf_hasta hs on hs.id = gm.hasta_id
                  left join public.taraf hk on hk.id = mu.personel_id
                 where gm.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            var semalar = await baglanti.ListeAsync("""
                select distinct on (c.goz, c.sema_turu)
                       c.id, c.goz, c.sema_turu as "semaTuru", c.surum, c.kilitli,
                       c.uretilen_metin as "uretilenMetin",
                       coalesce(c.degistirme_tarihi, c.ekleme_tarihi) as zaman,
                       coalesce(t.unvan, '') as kullanici
                  from public.goz_cizim c
                  left join public.taraf t on t.id = c.ekleyen
                 where c.goz_muayene_id = @p0
                 order by c.goz, c.sema_turu, c.surum desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            var isaretler = await IsaretleriOkuAsync(baglanti, [id], iptal);

            // ANTET: muayenenin şubesi; yoksa varsayılan şube. Hastaya verilen
            //   belgede kurum kimliği zorunlu.
            var kurum = await baglanti.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan, s.adres, s.ilce, s.il,
                       s.telefon, s.vkno, s.vd
                  from public.sube s
                 where s.id = coalesce((select gm.sube_id from public.goz_muayene gm
                                         where gm.id = @p0),
                                       (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                muayene,
                kurum,
                semalar,
                isaretler = isaretler.Select(i => new
                {
                    i.goz, i.semaTuru, i.sekil, i.tur, i.x, i.y, i.saat,
                    i.boyutDd, i.renk, i.yol, i.aciklama,
                }),
                // Damga adları ve simgeleri çıktıda da sunucudan: kâğıttaki
                //   ad ile ekrandaki ad ayrışmasın.
                damgalar = Damgalar.Select(d => new { d.Tur, d.Ad, d.Simge, d.Renk }),
                semaAdlari = SemaAdlari.Select((a, i) => new { tur = i, ad = a })
                                       .Where(x => x.tur > 0),
            });
        });
    }

    private sealed record CizimIsaretSatiri(
        int gozMuayeneId, long id, int goz, int semaTuru, int sekil, int tur,
        decimal? x, decimal? y, int? saat, decimal? boyutDd, string renk,
        string yol, string aciklama);

    /// <summary>Birden çok muayenenin işaretleri: karşılaştırma iki kaydı
    /// birlikte okur, çıktı tek kaydı - sorgu aynı.</summary>
    private static async Task<List<CizimIsaretSatiri>> IsaretleriOkuAsync(
        Npgsql.NpgsqlConnection baglanti, int[] muayeneler, CancellationToken iptal)
        => await baglanti.ListeAsync("""
            with guncel as (
                select distinct on (c.goz_muayene_id, c.goz, c.sema_turu)
                       c.id, c.goz_muayene_id, c.goz, c.sema_turu
                  from public.goz_cizim c
                 where c.goz_muayene_id = any(@p0)
                 order by c.goz_muayene_id, c.goz, c.sema_turu, c.surum desc
            )
            select g.goz_muayene_id, i.id, g.goz, g.sema_turu, i.sekil, i.tur,
                   i.x, i.y, i.saat, i.boyut_dd, i.renk, i.yol, i.aciklama
              from guncel g
              join public.goz_cizim_isaret i on i.cizim_id = g.id
             order by g.goz_muayene_id, g.goz, g.sema_turu, i.sira, i.id
            """, null, [muayeneler], o => new CizimIsaretSatiri(
                o.GetInt32(0), o.GetInt64(1), o.GetInt16(2), o.GetInt16(3),
                o.GetInt16(4), o.GetInt16(5),
                o.IsDBNull(6) ? null : o.GetDecimal(6),
                o.IsDBNull(7) ? null : o.GetDecimal(7),
                o.IsDBNull(8) ? null : o.GetInt16(8),
                o.IsDBNull(9) ? null : o.GetDecimal(9),
                o.GetString(10), o.GetString(11), o.GetString(12)), iptal);
}
