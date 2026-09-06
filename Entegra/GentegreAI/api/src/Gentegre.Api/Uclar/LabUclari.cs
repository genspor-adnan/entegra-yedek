using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// LABORATUVAR UÇLARI — v1 (433/434): istem, numune/barkod, kabul-ret,
/// sonuç girişi, iki aşamalı onay, panik bildirimi, cihaz çalışma listesi.
///
/// <para><b>Yetki üçe ayrılır:</b> <c>lab.numune</c> (kabul/ret),
/// <c>lab.sonuc</c> (giriş + teknik onay), <c>lab.onay</c> (uzman onayı).
/// Sonucu giren kişinin kendi sonucunu yayınlaması, iki aşamalı onayı
/// anlamsız kılardı.</para>
/// </summary>
public static class LabUclari
{
    public sealed record IstemIstegi(int BelgeId, LabServisi.IstemSatiriIstegi[]? Satirlar,
                                     short? Oncelik, string? KlinikBilgi, string? TaniIcd);

    public sealed record NumuneDurumIstegi(short Durum, short? Kalite, short? RetNeden,
                                           string? Aciklama);

    public sealed record OnayIstegi(short? Asama);

    public sealed record DuzeltmeIstegi(string Deger, string Neden);

    public sealed record PanikIstegi(string BildirilenAd, short? Kanal, string? Aciklama);

    public sealed record TeyitIstegi(string TeyitEden);

    public sealed record OnRaporIstegi(string Metin, bool? Kritik);

    public sealed record YorumIstegi(string Yorum, bool? Bildir, string Neden);

    public sealed record UzmanYorumIstegi(string? Yorum);

    public sealed record KulturIptalIstegi(string Neden);

    public sealed record VaryantSinifIstegi(short Sinif, string Neden, bool? Raporla);

    public sealed record DogrulamaIstegi(short Durum, string? Yontem);

    public sealed record GenetikOnayIstegi(string? Yorum, string? Oneriler,
                                           string? Sinirliliklar);

    public static void LabUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/lab").WithTags("Laboratuvar").RequireAuthorization();

        // ------------------------------------------------------------ istem ---

        // POST /api/lab/istem - başvurudan istem açar, tüp planını ve barkodları
        //   üretir. Panel satırı tetkiklerine açılır; aynı tüpteki tetkikler TEK
        //   barkoda bağlanır (hastadan gereksiz tüp alınmaz).
        grup.MapPost("/istem", async (
            IstemIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Ekle);

            var id = await servis.IstemAcAsync(
                istek.BelgeId, istek.Satirlar ?? [], istek.Oncelik ?? 1,
                istek.KlinikBilgi ?? "", istek.TaniIcd ?? "", baglam, iptal);

            var ozet = await IstemOzetAsync(veri, id, iptal);
            return Results.Ok(new { id, ozet.IstemNo, ozet.Barkodlar, ozet.TetkikSayisi,
                                    mesaj = $"İstem açıldı: {ozet.IstemNo} · "
                                          + $"{ozet.TetkikSayisi} tetkik · "
                                          + $"{ozet.Barkodlar.Count} tüp",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/istem/{id} - istem + numune + sonuç (rapor/ekran kaynağı).
        grup.MapGet("/istem/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var basli = await veri.TekAsync("""
                select i.id, i.istem_no, i.istem_tarihi, i.durum, i.oncelik,
                       i.taraf_id, coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''),
                                            h.unvan) as hasta,
                       i.klinik_bilgi, i.tani_icd, i.hedef_bitis, i.belge_id
                  from public.lab_istem i
                  join public.taraf h on h.id = i.taraf_id
                 where i.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0), IstemNo = o.GetString(1),
                           Tarih = o.GetDateTime(2), Durum = o.GetInt16(3),
                           Oncelik = o.GetInt16(4), HastaId = o.GetInt32(5),
                           Hasta = o.GetString(6), Klinik = o.GetString(7),
                           Tani = o.GetString(8),
                           HedefBitis = o.IsDBNull(9) ? (DateTime?)null : o.GetDateTime(9),
                           BelgeId = o.IsDBNull(10) ? (int?)null : o.GetInt32(10) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            // Sonuç ONAYLI satırın kendisinden okunur; bayrak/referans o gün
            //   hesaplanmış hâliyle durur, sonradan referans değişse rapor aynı kalır.
            var satirlar = await veri.ListeAsync("""
                select s.id, s.kod, s.ad, s.durum, n.barkod, n.durum as numune_durum,
                       ls.id as sonuc_id, ls.deger_metin, ls.birim, ls.bayrak,
                       ls.referans_alt, ls.referans_ust, ls.referans_metin, ls.panik,
                       ls.delta_uyari, ls.durum as sonuc_durum, ls.olcum_zamani,
                       ls.onay_zamani, ls.yorum
                  from public.lab_istem_satir s
                  left join public.lab_numune n on n.id = s.numune_id
                  left join lateral (
                        select * from public.lab_sonuc x
                         where x.istem_satir_id = s.id and x.durum <> 4
                         order by x.id desc limit 1) ls on true
                 where s.istem_id = @p0 and s.durum <> 0
                 order by s.sira, s.id
                """, [id],
                o => new {
                    SatirId = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                    Durum = o.GetInt16(3),
                    Barkod = o.IsDBNull(4) ? "" : o.GetString(4),
                    NumuneDurum = o.IsDBNull(5) ? (short)0 : o.GetInt16(5),
                    SonucId = o.IsDBNull(6) ? (long?)null : o.GetInt64(6),
                    Deger = o.IsDBNull(7) ? "" : o.GetString(7),
                    Birim = o.IsDBNull(8) ? "" : o.GetString(8),
                    Bayrak = o.IsDBNull(9) ? "" : o.GetString(9),
                    RefAlt = o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10),
                    RefUst = o.IsDBNull(11) ? (decimal?)null : o.GetDecimal(11),
                    RefMetin = o.IsDBNull(12) ? "" : o.GetString(12),
                    Panik = !o.IsDBNull(13) && o.GetInt16(13) == 1,
                    DeltaUyari = !o.IsDBNull(14) && o.GetInt16(14) == 1,
                    SonucDurum = o.IsDBNull(15) ? (short)0 : o.GetInt16(15),
                    OlcumZamani = o.IsDBNull(16) ? (DateTime?)null : o.GetDateTime(16),
                    OnayZamani = o.IsDBNull(17) ? (DateTime?)null : o.GetDateTime(17),
                    Yorum = o.IsDBNull(18) ? "" : o.GetString(18) }, iptal);

            var numuneler = await veri.ListeAsync("""
                select id, barkod, numune_tipi, tup_tipi, durum, alim_zamani,
                       kabul_zamani, ret, ret_neden, ret_aciklama
                  from public.lab_numune where istem_id = @p0 order by id
                """, [id],
                o => new { Id = o.GetInt32(0), Barkod = o.GetString(1),
                           NumuneTipi = o.GetInt16(2), TupTipi = o.GetInt16(3),
                           Durum = o.GetInt16(4),
                           Alim = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5),
                           Kabul = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                           Ret = o.GetInt16(7) == 1,
                           RetNeden = o.IsDBNull(8) ? (short?)null : o.GetInt16(8),
                           RetAciklama = o.GetString(9) }, iptal);

            return Results.Ok(new { basli.Id, basli.IstemNo, basli.Tarih, basli.Durum,
                                    basli.Oncelik, basli.HastaId, basli.Hasta,
                                    basli.Klinik, basli.Tani, basli.HedefBitis,
                                    basli.BelgeId, numuneler, satirlar,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/basvuru/{belgeId}/istemler - muayene "İstem & Sonuçlar"
        //   sekmesi: başvurunun istemleri ve tamamlanma durumu.
        grup.MapGet("/basvuru/{belgeId:int}/istemler", async (
            int belgeId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select i.id, i.istem_no, i.istem_tarihi, i.durum, i.oncelik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum <> 0) as tetkik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum = 5) as onayli,
                       (select count(*) from public.lab_istem_satir s
                          join public.lab_sonuc ls on ls.istem_satir_id = s.id
                         where s.istem_id = i.id and ls.panik = 1
                           and ls.durum <> 4) as panik
                  from public.lab_istem i
                 where i.belge_id = @p0 and i.durum <> 0
                 order by i.id desc
                """, [belgeId],
                o => new { Id = o.GetInt32(0), IstemNo = o.GetString(1),
                           Tarih = o.GetDateTime(2), Durum = o.GetInt16(3),
                           Oncelik = o.GetInt16(4), Tetkik = o.GetInt64(5),
                           Onayli = o.GetInt64(6), Panik = o.GetInt64(7) }, iptal);

            return Results.Ok(new { belgeId, istemler = liste,
                                    izlemeNo = baglam.IzlemeNo });
        });

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

        // ----------------------------------------------------------- numune ---

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
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
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

        // ------------------------------------------------------------ sonuç ---

        // POST /api/lab/sonuc - kural motoru burada çalışır: referans, bayrak,
        //   panik, delta. Temiz sonuç oto-onaya gider, bayraklı sonuç insana.
        grup.MapPost("/sonuc", async (
            LabServisi.SonucIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Ekle);

            var s = await servis.SonucYazAsync(istek, null, null, baglam, iptal);
            return Results.Ok(new { s.SonucId, s.Bayrak, s.Panik, s.DeltaUyari, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/sonuc/{id}/onayla - aşama 1 teknik, 2 uzman (yayın).
        grup.MapPost("/sonuc/{id:long}/onayla", async (
            long id, OnayIstegi? istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var asama = istek?.Asama ?? 2;
            baglam.YetkiIste(asama == 1 ? "lab.sonuc" : "lab.onay", Islem.Degistir);

            var mesaj = await servis.OnaylaAsync(id, asama, baglam, iptal);
            return Results.Ok(new { id, asama, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/sonuc/{id}/duzelt - onaylı sonuç GÜNCELLENMEZ; eski satır
        //   iptal edilir, yenisi açılır. Neden zorunlu.
        grup.MapPost("/sonuc/{id:long}/duzelt", async (
            long id, DuzeltmeIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var s = await servis.DuzeltAsync(id, istek.Deger, istek.Neden, baglam, iptal);
            return Results.Ok(new { s.SonucId, s.Bayrak, s.Panik, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------ panik ---

        grup.MapPost("/sonuc/{id:long}/panik", async (
            long id, PanikIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var bildirimId = await servis.PanikBildirAsync(id, istek.BildirilenAd,
                istek.Kanal ?? 1, istek.Aciklama ?? "", baglam, iptal);
            return Results.Ok(new { bildirimId,
                mesaj = "Bildirim kaydedildi - TEYİT alınmadan kapanmış sayılmaz.",
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/panik/{id:int}/teyit", async (
            int id, TeyitIstegi istek, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Degistir);

            var mesaj = await servis.PanikTeyitAsync(id, istek.TeyitEden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // ---------------------------------------------------- mikrobiyoloji ---

        // POST /api/lab/satir/{id}/ekim - kültürü açar (besiyeri seti tetkikten).
        grup.MapPost("/satir/{id:int}/ekim", async (
            int id, KulturServisi.EkimIstegi? istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Ekle);

            var kulturId = await kultur.EkimAsync(id,
                istek ?? new KulturServisi.EkimIstegi(null, null, null, null, null, null),
                baglam, iptal);
            return Results.Ok(new { kulturId, mesaj = "Ekim yapıldı, inkübasyon başladı.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kultur/{id} - kültür + besiyeri + okuma + izolat +
        //   antibiyogram: çalışma alanının ve raporun tek kaynağı.
        grup.MapGet("/kultur/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Gor);

            var k = await veri.TekAsync("""
                select k.id, k.istem_id, k.istem_satir_id, t.kod, t.ad, k.durum,
                       k.ekim_zamani, k.sonraki_okuma, k.sicaklik, k.atmosfer,
                       k.direkt_baki, k.gram_sonuc, k.numune_kalite, k.on_rapor,
                       k.on_rapor_zamani, k.kritik, k.ekk_bildirim, k.uzman_yorum,
                       k.onay_zamani, coalesce(n.barkod, ''), k.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       public.fn_lab_kultur_ozet(k.id)
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                  join public.taraf h on h.id = k.hasta_id
                  left join public.lab_numune n on n.id = k.numune_id
                 where k.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0), IstemId = o.GetInt32(1),
                           IstemSatirId = o.GetInt32(2), TetkikKod = o.GetString(3),
                           TetkikAd = o.GetString(4), Durum = o.GetInt16(5),
                           EkimZamani = o.GetDateTime(6),
                           SonrakiOkuma = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                           Sicaklik = o.GetInt16(8), Atmosfer = o.GetInt16(9),
                           DirektBaki = o.GetString(10), GramSonuc = o.GetString(11),
                           NumuneKalite = o.GetString(12), OnRapor = o.GetString(13),
                           OnRaporZamani = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
                           Kritik = o.GetInt16(15) == 1, Ekk = o.GetInt16(16) == 1,
                           UzmanYorum = o.GetString(17),
                           OnayZamani = o.IsDBNull(18) ? (DateTime?)null : o.GetDateTime(18),
                           Barkod = o.GetString(19), HastaId = o.GetInt32(20),
                           Hasta = o.GetString(21), Ozet = o.GetString(22) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Kültür bulunamadı.");

            var besiyeriler = await veri.ListeAsync("""
                select kb.id, b.kod, b.ad, kb.lot, kb.sonuc
                  from public.lab_kultur_besiyeri kb
                  join public.lab_besiyeri b on b.id = kb.besiyeri_id
                 where kb.kultur_id = @p0 order by kb.sira, kb.id
                """, [id],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Lot = o.GetString(3), Sonuc = o.GetString(4) }, iptal);

            var okumalar = await veri.ListeAsync("""
                select o.id, o.saat, o.okuma_zamani, o.ureme_var, o.bulgu, o.sonraki_adim
                  from public.lab_kultur_okuma o
                 where o.kultur_id = @p0 order by o.saat, o.id
                """, [id],
                o => new { Id = o.GetInt32(0), Saat = o.GetInt16(1),
                           Zaman = o.GetDateTime(2), UremeVar = o.GetInt16(3) == 1,
                           Bulgu = o.GetString(4), SonrakiAdim = o.GetString(5) }, iptal);

            var izolatlar = await veri.ListeAsync("""
                select u.id, u.izolat_no, o.kod, o.ad, u.koloni_sayisi, u.koloni_birim,
                       u.anlamli, u.id_yontem, u.id_guven, u.esbl, u.karbapenemaz,
                       u.mrsa, u.vre, u.ampc, u.direnc_notu, o.bildirimi_zorunlu
                  from public.lab_kultur_ureme u
                  join public.lab_organizma o on o.id = u.organizma_id
                 where u.kultur_id = @p0 and u.durum = 1
                 order by u.izolat_no
                """, [id],
                o => new { Id = o.GetInt32(0), IzolatNo = o.GetInt16(1),
                           OrganizmaKod = o.GetString(2), Organizma = o.GetString(3),
                           KoloniSayisi = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                           KoloniBirim = o.GetString(5), Anlamli = o.GetInt16(6) == 1,
                           IdYontem = o.GetInt16(7),
                           IdGuven = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                           Esbl = o.GetInt16(9), Karbapenemaz = o.GetInt16(10),
                           Mrsa = o.GetInt16(11), Vre = o.GetInt16(12),
                           Ampc = o.GetInt16(13), DirencNotu = o.GetString(14),
                           BildirimiZorunlu = o.GetInt16(15) == 1 }, iptal);

            // Antibiyogram RAPOR SIRASIYLA gelir: basamak, sonra ad. Kademeli
            //   bildirimde gizlenen satır da döner ("bildir" bayrağıyla) -
            //   uzman neyin gizlendiğini görebilmeli.
            var antibiyogram = await veri.ListeAsync("""
                select g.id, g.ureme_id, a.kod, a.ad, a.basamak, g.mic, g.mic_isaret,
                       g.zon_mm, g.yorum, g.kaynak, g.standart, g.standart_surum,
                       g.bildir, g.aciklama, g.degistirme_neden
                  from public.lab_antibiyogram g
                  join public.lab_antibiyotik a on a.id = g.antibiyotik_id
                  join public.lab_kultur_ureme u on u.id = g.ureme_id
                 where u.kultur_id = @p0
                 order by g.ureme_id, a.basamak, a.ad
                """, [id],
                o => new { Id = o.GetInt32(0), UremeId = o.GetInt32(1),
                           Kod = o.GetString(2), Ad = o.GetString(3),
                           Basamak = o.GetInt16(4),
                           Mic = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                           MicIsaret = o.GetString(6),
                           ZonMm = o.IsDBNull(7) ? (short?)null : o.GetInt16(7),
                           Yorum = o.GetString(8), Kaynak = o.GetInt16(9),
                           Standart = o.GetString(10), StandartSurum = o.GetString(11),
                           Bildir = o.GetInt16(12) == 1, Aciklama = o.GetString(13),
                           DegistirmeNeden = o.GetString(14) }, iptal);

            return Results.Ok(new { kultur = k, besiyeriler, okumalar, izolatlar,
                                    antibiyogram, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/okuma", async (
            int id, KulturServisi.OkumaIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.OkumaAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kultur/{id}/on-rapor - Gram / erken bulgu hekime.
        grup.MapPost("/kultur/{id:int}/on-rapor", async (
            int id, OnRaporIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.OnRaporAsync(id, istek.Metin, istek.Kritik ?? false,
                                                  baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/izolat", async (
            int id, KulturServisi.IzolatIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var uremeId = await kultur.IzolatAsync(id, istek, baglam, iptal);
            return Results.Ok(new { uremeId, mesaj = "İzolat kaydedildi.",
                                    izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/izolat/{id:int}/antibiyogram", async (
            int id, KulturServisi.AntibiyogramIstegi istek, BaglamCozucu cozucu,
            KulturServisi kultur, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var (satir, bildirilen) = await kultur.AntibiyogramAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, satir, bildirilen,
                mesaj = $"{satir} antibiyotik kaydedildi; kademeli bildirimle "
                      + $"{bildirilen} tanesi raporda gösterilecek.",
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/antibiyogram/{id:int}/yorum", async (
            int id, YorumIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await kultur.YorumDegistirAsync(id, istek.Yorum,
                istek.Bildir ?? true, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/onayla", async (
            int id, UzmanYorumIstegi? istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await kultur.OnaylaAsync(id, istek?.Yorum, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/kultur/{id:int}/iptal", async (
            int id, KulturIptalIstegi istek, BaglamCozucu cozucu, KulturServisi kultur,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kultur", Islem.Degistir);

            var mesaj = await kultur.IptalAsync(id, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // ----------------------------------------------------------- genetik ---

        // POST /api/lab/satir/{id}/genetik-vaka - istemden vaka açar.
        grup.MapPost("/satir/{id:int}/genetik-vaka", async (
            int id, GenetikServisi.VakaIstegi? istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Ekle);

            var (vakaId, vakaNo) = await genetik.VakaAcAsync(id,
                istek ?? new GenetikServisi.VakaIstegi(null, null, null, null, null, null),
                baglam, iptal);
            return Results.Ok(new { vakaId, vakaNo,
                mesaj = $"Genetik vaka açıldı: {vakaNo}. Rapor için ONAM kaydı şart.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/genetik/{id} - vaka + run + varyantlar (çalışma alanı
        //   ve raporun tek kaynağı).
        grup.MapGet("/genetik/{id:int}", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Gor);

            var v = await veri.TekAsync("""
                select g.id, g.vaka_no, g.durum, g.endikasyon, g.tani_icd, g.aile_oykusu,
                       g.onam_surum, g.onam_tarihi, g.tesadufi_bulgu, g.veri_saklama_yil,
                       g.arastirma_izni, g.izolasyon_tarihi, g.dna_konsantrasyon,
                       g.dna_saflik, g.kapsama_yuzde, g.ort_derinlik, g.kontaminasyon,
                       g.cinsiyet_dogrulama, g.sonuc_ozeti, g.uzman_yorum, g.oneriler,
                       g.sinirliliklar, g.onay_zamani, g.hedef_bitis, g.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       coalesce(p.kod || ' · ' || p.ad, ''), coalesce(r.kod, ''),
                       coalesce(n.barkod, ''), t.kod, t.ad,
                       public.fn_lab_genetik_ozet(g.id), g.istem_id, g.istem_satir_id,
                       coalesce(p.referans_genom, ''), coalesce(p.pipeline, '')
                  from public.lab_genetik_vaka g
                  join public.taraf h on h.id = g.hasta_id
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                  left join public.lab_genetik_run r on r.id = g.run_id
                  left join public.lab_numune n on n.id = g.numune_id
                 where g.id = @p0
                """, [id],
                o => new {
                    Id = o.GetInt32(0), VakaNo = o.GetString(1), Durum = o.GetInt16(2),
                    Endikasyon = o.GetString(3), TaniIcd = o.GetString(4),
                    AileOykusu = o.GetString(5), OnamSurum = o.GetString(6),
                    OnamTarihi = o.IsDBNull(7) ? (DateTime?)null : o.GetDateTime(7),
                    TesadufiBulgu = o.GetInt16(8), VeriSaklamaYil = o.GetInt16(9),
                    ArastirmaIzni = o.GetInt16(10) == 1,
                    IzolasyonTarihi = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
                    DnaKonsantrasyon = o.IsDBNull(12) ? (decimal?)null : o.GetDecimal(12),
                    DnaSaflik = o.IsDBNull(13) ? (decimal?)null : o.GetDecimal(13),
                    KapsamaYuzde = o.IsDBNull(14) ? (decimal?)null : o.GetDecimal(14),
                    OrtDerinlik = o.IsDBNull(15) ? (decimal?)null : o.GetDecimal(15),
                    Kontaminasyon = o.IsDBNull(16) ? (decimal?)null : o.GetDecimal(16),
                    CinsiyetDogrulama = o.GetInt16(17), SonucOzeti = o.GetString(18),
                    UzmanYorum = o.GetString(19), Oneriler = o.GetString(20),
                    Sinirliliklar = o.GetString(21),
                    OnayZamani = o.IsDBNull(22) ? (DateTime?)null : o.GetDateTime(22),
                    HedefBitis = o.IsDBNull(23) ? (DateTime?)null : o.GetDateTime(23),
                    HastaId = o.GetInt32(24), Hasta = o.GetString(25),
                    Panel = o.GetString(26), Run = o.GetString(27),
                    Barkod = o.GetString(28), TetkikKod = o.GetString(29),
                    TetkikAd = o.GetString(30), Ozet = o.GetString(31),
                    IstemId = o.GetInt32(32), IstemSatirId = o.GetInt32(33),
                    ReferansGenom = o.GetString(34), Pipeline = o.GetString(35) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Genetik vaka bulunamadı.");

            // Varyantlar RAPOR SIRASIYLA: önce patojenik. Raporlanmayanlar da
            //   döner ("raporla" bayrağıyla) - uzman neyin dışarıda kaldığını
            //   görebilmeli.
            var varyantlar = await veri.ListeAsync("""
                select v.id, v.gen_sembol, v.transkript, v.hgvs_c, v.hgvs_p, v.zigosite,
                       v.kalitim, v.derinlik, v.vaf, v.gnomad_af, v.clinvar,
                       v.acmg_kriterler, v.sinif, v.sinif_elle, v.sinif_neden,
                       v.raporla, v.ikincil_bulgu, v.dogrulama, v.dogrulama_yontem,
                       v.yorum
                  from public.lab_varyant v
                 where v.vaka_id = @p0
                 order by v.sinif desc, v.gen_sembol
                """, [id],
                o => new { Id = o.GetInt32(0), GenSembol = o.GetString(1),
                           Transkript = o.GetString(2), HgvsC = o.GetString(3),
                           HgvsP = o.GetString(4), Zigosite = o.GetInt16(5),
                           Kalitim = o.GetInt16(6),
                           Derinlik = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                           Vaf = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                           GnomadAf = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                           ClinVar = o.GetString(10),
                           Acmg = o.IsDBNull(11) ? Array.Empty<string>()
                                                 : o.GetFieldValue<string[]>(11),
                           Sinif = o.GetInt16(12), SinifElle = o.GetInt16(13) == 1,
                           SinifNeden = o.GetString(14), Raporla = o.GetInt16(15) == 1,
                           IkincilBulgu = o.GetInt16(16) == 1,
                           Dogrulama = o.GetInt16(17), DogrulamaYontem = o.GetString(18),
                           Yorum = o.GetString(19) }, iptal);

            return Results.Ok(new { vaka = v, varyantlar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/genetik/{id}/onam - KVKK md. 6: onamsız rapor yok.
        grup.MapPost("/genetik/{id:int}/onam", async (
            int id, GenetikServisi.OnamIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.OnamAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/izolasyon", async (
            int id, GenetikServisi.IzolasyonIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.IzolasyonAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/run", async (
            int id, GenetikServisi.RunaAlIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var (runId, runKodu) = await genetik.RunaAlAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, runId, runKodu,
                mesaj = $"Vaka {runKodu} run'ına alındı.", izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/kalite", async (
            int id, GenetikServisi.KaliteIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.KaliteAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/genetik/{id}/varyant - sınıf ACMG kanıtlarından türetilir.
        grup.MapPost("/genetik/{id:int}/varyant", async (
            int id, GenetikServisi.VaryantIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var s = await genetik.VaryantAsync(id, istek, baglam, iptal);
            return Results.Ok(new { s.Id, s.Sinif, s.SinifAdi, s.Raporlanir,
                s.BankaUyarisi,
                mesaj = $"{istek.GenSembol} {istek.HgvsC} → {s.SinifAdi}"
                      + (s.Raporlanir ? " (raporlanacak)" : " (raporlanmayacak)"),
                izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/varyant/{id:int}/sinif", async (
            int id, VaryantSinifIstegi istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await genetik.SinifDegistirAsync(id, istek.Sinif, istek.Neden,
                                                         istek.Raporla, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/varyant/{id}/dogrulama - 1 istendi · 2 doğrulandı ·
        //   3 doğrulanamadı (rapordan çıkar).
        grup.MapPost("/varyant/{id:int}/dogrulama", async (
            int id, DogrulamaIstegi istek, BaglamCozucu cozucu, GenetikServisi genetik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.DogrulamaAsync(id, istek.Durum, istek.Yontem,
                                                     baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/onayla", async (
            int id, GenetikOnayIstegi? istek, BaglamCozucu cozucu,
            GenetikServisi genetik, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.onay", Islem.Degistir);

            var mesaj = await genetik.OnaylaAsync(id, istek?.Yorum, istek?.Oneriler,
                                                  istek?.Sinirliliklar, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        grup.MapPost("/genetik/{id:int}/iptal", async (
            int id, KulturIptalIstegi istek, BaglamCozucu cozucu, GenetikServisi genetik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Degistir);

            var mesaj = await genetik.IptalAsync(id, istek.Neden, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/genetik/yeniden-degerlendirme - bilgi bankasındaki sınıf
        //   değişince etkilenen ONAYLI vakalar. VUS'un yıllar sonra patojenik
        //   çıkması hastayı doğrudan ilgilendirir; elle takip edilemez.
        grup.MapGet("/genetik/yeniden-degerlendirme", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.genetik", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select y.varyant_id, y.vaka_id, y.vaka_no, y.hasta_id,
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan),
                       y.gen_sembol, y.hgvs_c, y.rapor_sinif, y.guncel_sinif,
                       y.degerlendirme_tarihi
                  from public.v_lab_varyant_yeniden y
                  join public.taraf h on h.id = y.hasta_id
                 order by y.degerlendirme_tarihi desc
                """, [],
                o => new { VaryantId = o.GetInt32(0), VakaId = o.GetInt32(1),
                           VakaNo = o.GetString(2), HastaId = o.GetInt32(3),
                           Hasta = o.GetString(4), GenSembol = o.GetString(5),
                           HgvsC = o.GetString(6), RaporSinif = o.GetInt16(7),
                           GuncelSinif = o.GetInt16(8), Tarih = o.GetDateTime(9) },
                iptal);

            return Results.Ok(new { liste, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------------ cihaz ---

        // GET /api/lab/cihaz/{id}/calisma-listesi/{barkod} - HOST QUERY.
        grup.MapGet("/cihaz/{id:int}/calisma-listesi/{barkod}", async (
            int id, string barkod, BaglamCozucu cozucu, LabServisi servis,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            var liste = await servis.CalismaListesiAsync(id, barkod, iptal);
            return Results.Ok(new { cihazId = id, barkod, satirlar = liste,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/cihaz-mesaj/{id}/isle - çözümlenmiş mesajı sonuca yaz.
        grup.MapPost("/cihaz-mesaj/{id:long}/isle", async (
            long id, BaglamCozucu cozucu, LabServisi servis, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.sonuc", Islem.Ekle);

            var s = await servis.CihazMesajIsleAsync(id, baglam, iptal);
            return Results.Ok(new { id, s.Yazilan, s.Atlanan, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });
    }

    private sealed record IstemOzeti(string IstemNo, List<string> Barkodlar,
                                     int TetkikSayisi);

    private static async Task<IstemOzeti> IstemOzetAsync(VeriKaynagi v, int istemId,
                                                         CancellationToken iptal)
    {
        var no = await v.TekDegerAsync<string>(
            "select istem_no from public.lab_istem where id = @p0", [istemId], iptal) ?? "";
        var barkodlar = await v.ListeAsync(
            "select barkod from public.lab_numune where istem_id = @p0 order by id",
            [istemId], o => o.GetString(0), iptal);
        var adet = await v.TekDegerAsync<long>(
            "select count(*) from public.lab_istem_satir where istem_id = @p0 and durum <> 0",
            [istemId], iptal);
        return new IstemOzeti(no, barkodlar, (int)adet);
    }
}
