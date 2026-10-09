using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ZİMMET / HAREKETLER (1007, Ekranlar/Demirbas/demirbas_zimmet_hareketleri.html).
///
/// Ekran hareket satırı YAZMAZ: zimmetle / iade al / devret / yer değiştir
/// demirbaş kartının `zimmet_taraf_id` ve `lokasyon` alanlarını değiştirir,
/// hareketi ve tutanak numarasını 1006 tetiği yazar. Kart ile hareket
/// geçmişi böylece aynı işlemde yazılır, birbiriyle çelişemez.
///
/// TOPLU İŞLEM TEK TUTANAK: üç demirbaşı birlikte zimmetlemek tek imzalı
/// tutanaktır. Tetik her satıra numara verir; işlem sonunda aynı işlemin
/// satırları ilk numarada birleştirilir.
/// </summary>
public static class DemirbasZimmetUclari
{
    private const string Kod = "demirbas.zimmet";
    private const int LogTabloDemirbas = 925;

    public sealed record IslemIstegi(string Islem, int[] DemirbasIdler, int? KisiId,
                                     short? Lokasyon, string? Aciklama);

    public static void DemirbasZimmetUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/demirbas-zimmet").WithTags("Demirbaş Zimmet")
                      .RequireAuthorization();

        // ------------------------------------------------------------ özet --
        grup.MapGet("/ozet", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
                                    CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("demirbas-zimmet");
            baglam.YetkiIste(Kod, Islem.Gor);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var kpi = await b.TekAsync("""
                select count(*)::int,
                       count(*) filter (where d.zimmet_taraf_id is not null)::int,
                       count(*) filter (where d.zimmet_taraf_id is null)::int,
                       (select count(*)::int from public.demirbas_hareket h
                          join public.demirbas x on x.id = h.demirbas_id
                         where h.zaman >= date_trunc('month', now())
                           and (@p0 = 0 or x.sube_id is null or x.sube_id = @p0)),
                       count(*) filter (where d.zimmet_taraf_id is not null
                                          and coalesce(p.aktif, 0) = 0)::int,
                       coalesce(sum(d.alis_tutari) filter (where d.zimmet_taraf_id is not null), 0)
                  from public.demirbas d
                  left join public.v_personel_lookup p on p.id = d.zimmet_taraf_id
                 where d.durum = 1 and (@p0 = 0 or d.sube_id is null or d.sube_id = @p0)
                """, null, [sube], o => new
            {
                toplam = o.GetInt32(0), zimmetli = o.GetInt32(1), bosta = o.GetInt32(2),
                buAyHareket = o.GetInt32(3), iadeBekleyen = o.GetInt32(4),
                zimmetliDeger = o.GetDecimal(5),
            }, iptal);

            var lokasyonlar = await b.ListeAsync("""
                select coalesce(lk.ad, '(lokasyonsuz)'), count(*)::int,
                       count(*) filter (where d.zimmet_taraf_id is not null)::int,
                       coalesce(sum(d.alis_tutari), 0)
                  from public.demirbas d
                  left join public.kod_liste ll on ll.kod = 'demirbas.lokasyon'
                  left join public.kod_deger lk on lk.liste_id = ll.id and lk.deger = d.lokasyon and lk.dil = 0
                 where d.durum = 1 and (@p0 = 0 or d.sube_id is null or d.sube_id = @p0)
                 group by 1 order by 2 desc, 1
                """, null, [sube], o => new
            {
                ad = o.GetString(0), adet = o.GetInt32(1), zimmetli = o.GetInt32(2),
                deger = o.GetDecimal(3),
            }, iptal);

            var personeller = await b.ListeAsync("""
                select p.id, p.ad, coalesce(p.aktif, 0), count(*)::int, coalesce(sum(d.alis_tutari), 0)
                  from public.demirbas d
                  join public.v_personel_lookup p on p.id = d.zimmet_taraf_id
                 where d.durum = 1 and (@p0 = 0 or d.sube_id is null or d.sube_id = @p0)
                 group by p.id, p.ad, p.aktif
                 order by coalesce(p.aktif, 0), p.ad
                """, null, [sube], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), aktif = o.GetInt16(2) == 1,
                adet = o.GetInt32(3), deger = o.GetDecimal(4),
            }, iptal);

            return Results.Ok(new { kpi, lokasyonlar, personeller });
        });

        // ------------------------------------------------ kişinin zimmetleri --
        grup.MapGet("/personel/{id:int}", async (int id, VeriKaynagi veri, BaglamCozucu cozucu,
                                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("demirbas-zimmet");
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select d.id, d.kod, d.ad,
                       coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                                  where kl.kod = 'demirbas.kategori' and kd.deger = d.kategori and kd.dil = 0), ''),
                       h.zaman, coalesce(h.tutanak_no, ''), coalesce(d.alis_tutari, 0)
                  from public.demirbas d
                  left join lateral (
                       select x.zaman, x.tutanak_no from public.demirbas_hareket x
                        where x.demirbas_id = d.id and x.hareket = 1 and x.yeni_zimmet_id = d.zimmet_taraf_id
                        order by x.zaman desc, x.id desc limit 1) h on true
                 where d.zimmet_taraf_id = @p0 and d.durum = 1
                   and (@p1 = 0 or d.sube_id is null or d.sube_id = @p1)
                 order by d.kod
                """, null, [id, baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                kategori = o.GetString(3),
                zimmetTarihi = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                tutanakNo = o.GetString(5), deger = o.GetDecimal(6),
            }, iptal);
            return Results.Ok(liste);
        });

        // ------------------------------------------------ personel seçimi --
        // Zimmet alacak kişi: yalnız AKTİF personel (ayrılan kişiye zimmet verilmez).
        grup.MapGet("/personeller", async (VeriKaynagi veri, BaglamCozucu cozucu,
                                           HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select id, ad from public.v_personel_lookup
                 where coalesce(aktif, 0) = 1 order by ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(liste);
        });

        // ------------------------------------------------- demirbaş arama --
        // Barkod okutma da buraya düşer: barkod / seri no tam, kod önek, ad içerir.
        grup.MapGet("/ara", async (string? q, VeriKaynagi veri, BaglamCozucu cozucu,
                                   HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var aranan = (q ?? "").Trim();
            if (aranan.Length == 0) return Results.Ok(Array.Empty<object>());
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select d.id, d.kod, d.ad, d.zimmet_taraf_id, coalesce(p.ad, ''),
                       d.lokasyon, coalesce(lk.ad, '')
                  from public.demirbas d
                  left join public.v_personel_lookup p on p.id = d.zimmet_taraf_id
                  left join public.kod_liste ll on ll.kod = 'demirbas.lokasyon'
                  left join public.kod_deger lk on lk.liste_id = ll.id and lk.deger = d.lokasyon and lk.dil = 0
                 where d.durum = 1 and (@p1 = 0 or d.sube_id is null or d.sube_id = @p1)
                   and (d.kod ilike @p0 || '%' or coalesce(d.barkod, '') = @p0
                        or coalesce(d.seri_no, '') = @p0 or d.ad ilike '%' || @p0 || '%')
                 order by (d.kod ilike @p0 || '%' or coalesce(d.barkod, '') = @p0) desc, d.kod
                 limit 15
                """, null, [aranan, baglam.SubeId ?? 0], o => new
            {
                id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2),
                zimmetId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), zimmet = o.GetString(4),
                lokasyon = o.IsDBNull(5) ? (short?)null : o.GetInt16(5), lokasyonAd = o.GetString(6),
            }, iptal);
            return Results.Ok(liste);
        });

        // ----------------------------------------------------------- işlem --
        grup.MapPost("/islem", async (IslemIstegi istek, VeriKaynagi veri, LogDeposu log,
                                      BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.MenuAcikIste("demirbas-zimmet");
            baglam.YetkiIste(Kod, Islem.Degistir);

            var tur = (istek.Islem ?? "").Trim().ToLowerInvariant();
            if (tur is not ("veris" or "iade" or "devir" or "yer"))
                throw GentegreHatasi.Dogrulama("Bilinmeyen işlem.", new AlanHatasi("islem", "Geçersiz."));
            var idler = (istek.DemirbasIdler ?? []).Distinct().ToArray();
            if (idler.Length == 0)
                throw GentegreHatasi.Dogrulama("Demirbaş seçilmedi.",
                    new AlanHatasi("demirbasIdler", "En az bir demirbaş seçin."));
            if (tur is "veris" or "devir" && istek.KisiId is null)
                throw GentegreHatasi.Dogrulama("Teslim alan personel seçilmedi.",
                    new AlanHatasi("kisiId", "Zorunlu."));
            if (tur == "yer" && istek.Lokasyon is null)
                throw GentegreHatasi.Dogrulama("Yeni lokasyon seçilmedi.",
                    new AlanHatasi("lokasyon", "Zorunlu."));
            var aciklama = (istek.Aciklama ?? "").Trim();
            if (aciklama.Length > 300) aciklama = aciklama[..300];

            await using var b = await veri.AcAsync(iptal);
            if (istek.KisiId is int kisi &&
                await b.TekDegerAsync<int?>("select id from public.v_personel_lookup where id = @p0",
                                            null, [kisi], iptal) is null)
                throw GentegreHatasi.Dogrulama("Personel bulunamadı.", new AlanHatasi("kisiId", "Geçersiz."));

            // İADE LOKASYONU (ayar, kod listesi ADI saklar - AyarAlani listeKod).
            short? iadeLok = null;
            if (tur == "iade")
                iadeLok = await b.TekDegerAsync<short?>("""
                    select kd.deger from public.referans r
                      join public.kod_liste kl on kl.kod = 'demirbas.lokasyon'
                      join public.kod_deger kd on kd.liste_id = kl.id and kd.dil = 0 and kd.ad = r.deger
                     where r.anahtar = 'demirbas.iade_lokasyon' and r.deger <> ''
                     limit 1
                    """, null, [], iptal);

            await using var islem = await b.BeginTransactionAsync(iptal);
            var sube = baglam.SubeId ?? 0;
            var mevcut = await b.ListeAsync("""
                select d.id, d.kod, d.zimmet_taraf_id, d.lokasyon
                  from public.demirbas d
                 where d.id = any(@p0) and (@p1 = 0 or d.sube_id is null or d.sube_id = @p1)
                 for update
                """, islem, [idler, sube], o => (Id: o.GetInt32(0), Kod: o.GetString(1),
                    Zimmet: o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                    Lok: o.IsDBNull(3) ? (short?)null : o.GetInt16(3)), iptal);
            if (mevcut.Count != idler.Length)
                throw GentegreHatasi.Bulunamadi("Demirbaş bulunamadı ya da bu şubede değil.");

            foreach (var d in mevcut)
            {
                // KURAL SUNUCUDA: zimmetli demirbaş yeniden "verilmez", devredilir -
                //   aksi halde önceki kişinin iadesi tutanaksız kalırdı.
                if (tur == "veris" && d.Zimmet is not null)
                    throw GentegreHatasi.IsKurali($"{d.Kod} zaten zimmetli - Devret kullanın.");
                if (tur is "iade" or "devir" && d.Zimmet is null)
                    throw GentegreHatasi.IsKurali($"{d.Kod} kimsede zimmetli değil.");
                if (tur == "devir" && d.Zimmet == istek.KisiId)
                    throw GentegreHatasi.IsKurali($"{d.Kod} zaten bu personelde.");
            }

            var hareketIdler = new List<long>();
            foreach (var d in mevcut)
            {
                int? yeniZimmet = tur switch
                {
                    "veris" or "devir" => istek.KisiId,
                    "iade" => null,
                    _ => d.Zimmet,
                };
                short? yeniLok = tur switch
                {
                    "yer" => istek.Lokasyon,
                    "iade" => iadeLok ?? d.Lok,
                    _ => istek.Lokasyon ?? d.Lok,
                };
                await b.CalistirAsync("""
                    update public.demirbas
                       set zimmet_taraf_id = @p1, lokasyon = @p2, degistiren = @p3, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [d.Id, yeniZimmet, yeniLok, baglam.KullaniciId], iptal);

                var hid = await b.TekDegerAsync<long?>("""
                    select max(id) from public.demirbas_hareket
                     where demirbas_id = @p0 and zaman >= now() - interval '1 minute'
                    """, islem, [d.Id], iptal);
                if (hid is long h)
                {
                    hareketIdler.Add(h);
                    if (aciklama.Length > 0)
                        await b.CalistirAsync(
                            "update public.demirbas_hareket set aciklama = @p1 where id = @p0",
                            islem, [h, aciklama], iptal);
                }

                await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloDemirbas, d.Id,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { islem = tur, zimmet = new { eski = d.Zimmet, yeni = yeniZimmet },
                          lokasyon = new { eski = d.Lok, yeni = yeniLok }, aciklama },
                    iptal: iptal);
            }

            // TEK TUTANAK: aynı işlemin zimmet satırları ilk numarada birleşir.
            string tutanak = "";
            if (hareketIdler.Count > 0)
            {
                tutanak = await b.TekDegerAsync<string>("""
                    select coalesce(min(tutanak_no) filter (where tutanak_no <> ''), '')
                      from public.demirbas_hareket where id = any(@p0)
                    """, islem, [hareketIdler.ToArray()], iptal) ?? "";
                if (tutanak.Length > 0)
                    await b.CalistirAsync("""
                        update public.demirbas_hareket set tutanak_no = @p1
                         where id = any(@p0) and tutanak_no <> ''
                        """, islem, [hareketIdler.ToArray(), tutanak], iptal);
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { adet = mevcut.Count, tutanakNo = tutanak });
        });

        // --------------------------------------------------------- tutanak --
        grup.MapGet("/tutanak/{no}", async (string no, VeriKaynagi veri, BaglamCozucu cozucu,
                                            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var kalemler = await b.ListeAsync("""
                select h.zaman, h.hareket, coalesce(ek.ad, ''), coalesce(yk.ad, ''),
                       coalesce(yl.ad, ''), d.kod, d.ad, coalesce(d.seri_no, ''),
                       trim(coalesce(d.marka, '') || ' ' || coalesce(d.model, '')),
                       coalesce(d.alis_tutari, 0), coalesce(iy.ad, ''), h.aciklama
                  from public.demirbas_hareket h
                  join public.demirbas d on d.id = h.demirbas_id
                  left join public.v_personel_lookup ek on ek.id = h.eski_zimmet_id
                  left join public.v_personel_lookup yk on yk.id = h.yeni_zimmet_id
                  left join public.v_personel_lookup iy on iy.id = h.ekleyen
                  left join public.kod_liste ll on ll.kod = 'demirbas.lokasyon'
                  left join public.kod_deger yl on yl.liste_id = ll.id and yl.deger = h.yeni_lokasyon and yl.dil = 0
                 where h.tutanak_no = @p0 and (@p1 = 0 or d.sube_id is null or d.sube_id = @p1)
                 order by d.kod
                """, null, [no, baglam.SubeId ?? 0], o => new
            {
                zaman = o.GetDateTime(0), hareket = o.GetInt16(1), eskiKisi = o.GetString(2),
                yeniKisi = o.GetString(3), lokasyon = o.GetString(4), kod = o.GetString(5),
                ad = o.GetString(6), seriNo = o.GetString(7), markaModel = o.GetString(8),
                deger = o.GetDecimal(9), islemYapan = o.GetString(10), aciklama = o.GetString(11),
            }, iptal);
            if (kalemler.Count == 0) throw GentegreHatasi.Bulunamadi("Tutanak bulunamadı.");
            var metin = await b.TekDegerAsync<string>(
                "select deger from public.referans where anahtar = 'demirbas.tutanak_metni'",
                null, [], iptal) ?? "";
            var k = kalemler[0];
            return Results.Ok(new
            {
                tutanakNo = no, tarih = k.zaman, iade = k.hareket == 9,
                // İadede malı TESLİM EDEN eski zimmetli, alan kurum (işlemi yapan).
                teslimEden = k.hareket == 9 ? k.eskiKisi : (k.eskiKisi.Length > 0 ? k.eskiKisi : k.islemYapan),
                teslimAlan = k.hareket == 9 ? k.islemYapan : k.yeniKisi,
                lokasyon = k.lokasyon, aciklama = k.aciklama, metin,
                kalemler = kalemler.Select(x => new { x.kod, x.ad, x.seriNo, x.markaModel, x.deger }),
            });
        });
    }
}
