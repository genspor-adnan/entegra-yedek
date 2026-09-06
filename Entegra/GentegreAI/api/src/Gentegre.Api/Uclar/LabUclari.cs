using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

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

        // ------------------------------------------------------------ rapor ---

        // GET /api/lab/rapor/{istemId} - HASTAYA VERİLEN belge.
        //
        // Çalışma ekranlarından AYRI uç: çıktının ihtiyacı iş akışı değil,
        // kurum anteti, kimlik satırları, RAPORLANACAK sonuçlar ve imzadır.
        // Tek uç üç bölümü de döndürür (sayısal · kültür · genetik) çünkü bir
        // istemde birden çok tür bulunabilir; sayfa hangi bölüm doluysa onu
        // basar. Üç ayrı uç, aynı hastanın raporunu üç parçaya bölerdi.
        //
        // YALNIZ ONAYLI SONUÇLAR: onaylanmamış değer hastaya verilen belgeye
        // giremez - taslak rapor "geçici" damgasıyla basılır.
        grup.MapGet("/rapor/{istemId:int}", async (
            int istemId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab", Islem.Gor);

            await using var baglanti = await veri.AcAsync(iptal);

            var istem = await baglanti.TekAsync("""
                select i.id, i.istem_no as "istemNo", i.istem_tarihi as "istemTarihi",
                       i.durum, i.oncelik, i.klinik_bilgi as "klinikBilgi",
                       i.tani_icd as "taniIcd", i.sonuc_tarihi as "sonucTarihi",
                       i.hedef_bitis as "hedefBitis",
                       coalesce(h.unvan, '') as "hastaAdi", coalesce(h.kod, '') as "hastaNo",
                       coalesce(h.vkno, '') as "hastaTc",
                       hs.dogum_tarihi as "dogumTarihi", coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(p.unvan, '') as "isteyenHekim",
                       coalesce(b.belge_no, '') as "protokolNo",
                       coalesce(ok.unvan, '') as "odeyenKurum",
                       (select min(n.alim_zamani) from public.lab_numune n
                         where n.istem_id = i.id) as "numuneAlim",
                       (select min(n.kabul_zamani) from public.lab_numune n
                         where n.istem_id = i.id) as "numuneKabul"
                  from public.lab_istem i
                  left join public.taraf h on h.id = i.taraf_id
                  left join public.taraf_hasta hs on hs.id = i.taraf_id
                  left join public.taraf p on p.id = i.personel_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                  left join public.taraf ok on ok.id = bb.odeyen_kurum_id
                 where i.id = @p0
                """, null, [istemId], RaporSatiri, iptal)
                ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

            // SAYISAL SONUÇLAR (biyokimya/hematoloji): bayrak, referans ve
            //   ölçüm zamanı SONUÇLA BİRLİKTE saklandığı gibi basılır -
            //   yeniden hesaplanmaz, yoksa eski rapor bugünkü referansla
            //   yeniden yorumlanmış olurdu.
            var sonuclar = await baglanti.ListeAsync("""
                select t.kod, t.ad, ls.deger_metin as deger, ls.birim, ls.bayrak,
                       ls.referans_alt as "referansAlt", ls.referans_ust as "referansUst",
                       ls.referans_metin as "referansMetin", ls.panik,
                       ls.delta_onceki as "deltaOnceki", ls.delta_yuzde as "deltaYuzde",
                       ls.delta_uyari as "deltaUyari", ls.yorum, ls.tekrar_no as "tekrarNo",
                       ls.olcum_zamani as "olcumZamani", ls.onay_zamani as "onayZamani",
                       coalesce(t.yontem, '') as yontem, coalesce(c.ad, '') as "cihazAdi",
                       coalesce(o.unvan, '') as "onaylayan", t.bolum,
                       coalesce(n.barkod, '') as barkod,
                       -- NUMUNE KALİTESİ raporun zorunlu parçası (ISO 15189):
                       --   "K yüksek" ile "hemoliz nedeniyle yüksek görünüyor"
                       --   hekim için bambaşka iki bilgi.
                       ls.indeks_durum as "indeksDurum", ls.indeks_uyari as "indeksUyari",
                       n.hemoliz_idx as "hemolizIdx", n.lipemi_idx as "lipemiIdx",
                       n.ikter_idx as "ikterIdx"
                  from public.lab_istem_satir s
                  join public.lab_tetkik t on t.id = s.tetkik_id
                  join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                  left join public.lab_numune n on n.id = ls.numune_id
                  left join public.cihaz c on c.id = ls.cihaz_id
                  left join public.taraf o on o.id = ls.onay_id
                 where s.istem_id = @p0 and s.durum <> 0 and t.tur in (1, 2, 3)
                 order by t.bolum, s.sira, t.kod
                """, null, [istemId], RaporSatiri, iptal);

            // KÜLTÜR: rapor bölümü izolat + antibiyogram. Antibiyogramda
            //   YALNIZ bildir = 1 satırlar - kademeli bildirim kararı burada
            //   da geçerli; gizlenen ajanı basmak kuralı anlamsız kılardı.
            var kulturler = await baglanti.ListeAsync("""
                select k.id, t.kod, t.ad, coalesce(n.barkod, '') as barkod,
                       k.ekim_zamani as "ekimZamani", k.direkt_baki as "direktBaki",
                       k.gram_sonuc as "gramSonuc", k.numune_kalite as "numuneKalite",
                       k.on_rapor as "onRapor", k.on_rapor_zamani as "onRaporZamani",
                       k.uzman_yorum as "uzmanYorum", k.onay_zamani as "onayZamani",
                       k.kritik, k.ekk_bildirim as "ekkBildirim", k.durum,
                       coalesce(o.unvan, '') as "onaylayan",
                       public.fn_lab_kultur_ozet(k.id) as ozet,
                       coalesce((select string_agg(b.ad || coalesce(' (lot ' || nullif(kb.lot, '') || ')', ''),
                                                   ' · ' order by kb.sira)
                                   from public.lab_kultur_besiyeri kb
                                   join public.lab_besiyeri b on b.id = kb.besiyeri_id
                                  where kb.kultur_id = k.id), '') as besiyeri
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                  left join public.lab_numune n on n.id = k.numune_id
                  left join public.taraf o on o.id = k.onay_id
                 where k.istem_id = @p0 and k.durum <> 0
                 order by k.id
                """, null, [istemId], RaporSatiri, iptal);

            var izolatlar = await baglanti.ListeAsync("""
                select u.id, u.kultur_id as "kulturId", u.izolat_no as "izolatNo",
                       o.ad as organizma, u.koloni_sayisi as "koloniSayisi",
                       u.koloni_birim as "koloniBirim", u.anlamli,
                       u.id_yontem as "idYontem", u.id_guven as "idGuven",
                       u.esbl, u.karbapenemaz, u.mrsa, u.vre, u.ampc,
                       u.direnc_notu as "direncNotu", o.bildirimi_zorunlu as "bildirimiZorunlu"
                  from public.lab_kultur_ureme u
                  join public.lab_organizma o on o.id = u.organizma_id
                  join public.lab_kultur k on k.id = u.kultur_id
                 where k.istem_id = @p0 and u.durum = 1
                 order by u.kultur_id, u.izolat_no
                """, null, [istemId], RaporSatiri, iptal);

            var antibiyogram = await baglanti.ListeAsync("""
                select g.ureme_id as "uremeId", a.ad as antibiyotik, a.basamak,
                       g.mic, g.mic_isaret as "micIsaret", g.zon_mm as "zonMm",
                       g.yorum, g.standart, g.standart_surum as "standartSurum",
                       g.aciklama, a.yalniz_uriner as "yalnizUriner"
                  from public.lab_antibiyogram g
                  join public.lab_antibiyotik a on a.id = g.antibiyotik_id
                  join public.lab_kultur_ureme u on u.id = g.ureme_id
                  join public.lab_kultur k on k.id = u.kultur_id
                 where k.istem_id = @p0 and g.bildir = 1
                 order by g.ureme_id, a.basamak, a.ad
                """, null, [istemId], RaporSatiri, iptal);

            // GENETİK: vaka başlığı, yöntem/kalite ve RAPORLANAN varyantlar.
            //   Hastanın istemediği ikincil bulgular raporla = 0 olduğu için
            //   burada da görünmez.
            var vakalar = await baglanti.ListeAsync("""
                select g.id, g.vaka_no as "vakaNo", t.kod, t.ad,
                       coalesce(n.barkod, '') as barkod,
                       g.endikasyon, g.tani_icd as "taniIcd",
                       g.aile_oykusu as "aileOykusu",
                       g.onam_surum as "onamSurum", g.onam_tarihi as "onamTarihi",
                       g.tesadufi_bulgu as "tesadufiBulgu",
                       g.veri_saklama_yil as "veriSaklamaYil",
                       g.izolasyon_tarihi as "izolasyonTarihi",
                       g.dna_konsantrasyon as "dnaKonsantrasyon",
                       g.dna_saflik as "dnaSaflik",
                       g.kapsama_yuzde as "kapsamaYuzde", g.ort_derinlik as "ortDerinlik",
                       g.kontaminasyon, g.cinsiyet_dogrulama as "cinsiyetDogrulama",
                       g.uzman_yorum as "uzmanYorum", g.oneriler, g.sinirliliklar,
                       g.onay_zamani as "onayZamani", g.durum, g.rapor_surum as "raporSurum",
                       coalesce(o.unvan, '') as "onaylayan",
                       public.fn_lab_genetik_ozet(g.id) as ozet,
                       coalesce(p.ad, '') as panel, coalesce(p.yontem, 1) as yontem,
                       coalesce(p.referans_genom, '') as "referansGenom",
                       coalesce(p.pipeline, '') as pipeline,
                       coalesce(r.kod, '') as "runKodu", coalesce(r.cihaz_adi, '') as cihaz,
                       r.q30,
                       coalesce((select string_agg(ge.sembol, ', ' order by ge.sembol)
                                   from public.lab_genetik_panel_gen pg
                                   join public.lab_gen ge on ge.id = pg.gen_id
                                  where pg.panel_id = p.id), '') as "genListesi"
                  from public.lab_genetik_vaka g
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                  left join public.lab_genetik_run r on r.id = g.run_id
                  left join public.lab_numune n on n.id = g.numune_id
                  left join public.taraf o on o.id = g.onay_id
                 where g.istem_id = @p0 and g.durum <> 0
                 order by g.id
                """, null, [istemId], RaporSatiri, iptal);

            var varyantlar = await baglanti.ListeAsync("""
                select v.vaka_id as "vakaId", v.gen_sembol as "genSembol",
                       v.transkript, v.hgvs_c as "hgvsC", v.hgvs_p as "hgvsP",
                       v.zigosite, v.kalitim, v.gnomad_af as "gnomadAf",
                       v.clinvar, v.acmg_kriterler as "acmgKriterler", v.sinif,
                       v.dogrulama, v.dogrulama_yontem as "dogrulamaYontem",
                       v.dogrulama_tarihi as "dogrulamaTarihi", v.yorum
                  from public.lab_varyant v
                  join public.lab_genetik_vaka g on g.id = v.vaka_id
                 where g.istem_id = @p0 and v.raporla = 1
                 order by v.vaka_id, v.sinif desc, v.gen_sembol
                """, null, [istemId], RaporSatiri, iptal);

            // ANTET: istemin şubesi; yoksa varsayılan şube. Kurum kimliği
            //   hastaya verilen belgede zorunludur.
            var kurum = await baglanti.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan, s.adres, s.ilce, s.il,
                       s.telefon, s.mersis_no as "mersisNo", s.vkno, s.vd
                  from public.sube s
                 where s.id = coalesce((select i.sube_id from public.lab_istem i
                                         where i.id = @p0),
                                       (select id from public.sube where varsayilan = 1 limit 1))
                """, null, [istemId], RaporSatiri, iptal);

            return Results.Ok(new { istem, sonuclar, kulturler, izolatlar, antibiyogram,
                                    vakalar, varyantlar, kurum, izlemeNo = baglam.IzlemeNo });
        });

        // ---------------------------------------------------- kalite kontrol ---

        // POST /api/lab/kk/olcum - KK ölçümü (elle ya da cihazdan).
        //   Z skoru ve Westgard değerlendirmesi SUNUCUDA; ekranda
        //   hesaplansaydı grafik ile karar ayrışırdı.
        grup.MapPost("/kk/olcum", async (
            KaliteKontrolServisi.OlcumIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var s = await kk.OlcumAsync(istek, baglam, iptal);
            return Results.Ok(new { s.Id, s.Z, s.Durum, s.Ihlaller, s.Mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/olcum/{id}/aksiyon - düzeltici faaliyet (ISO 15189)
        //   ve etkilenen hasta sonuçlarının gözden geçirilmesi.
        grup.MapPost("/kk/olcum/{id:long}/aksiyon", async (
            long id, KaliteKontrolServisi.AksiyonIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Degistir);

            var mesaj = await kk.AksiyonAsync(id, istek, baglam, iptal);
            return Results.Ok(new { id, mesaj, izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kk/lj - Levey-Jennings serisi (grafik ekranının kaynağı).
        //   Z skoru ölçümle saklandığı için burada yeniden hesaplanmaz.
        grup.MapGet("/kk/lj", async (
            int tetkikId, int? lotId, short? seviye, int? gun, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Gor);

            var seri = await veri.ListeAsync("""
                select id, olcum_zamani, deger, z, hedef, sd, durum, ihlaller,
                       seviye, cihaz_kod, materyal_ad, lot, aksiyon, kaynak
                  from public.v_lab_kk_lj
                 where tetkik_id = @p0
                   and (@p1::int is null or lot_id = @p1)
                   and (@p2::smallint is null or seviye = @p2)
                   and olcum_zamani >= now() - make_interval(days => coalesce(@p3, 30))
                 order by olcum_zamani
                """, [tetkikId, lotId, seviye, gun],
                o => new { Id = o.GetInt64(0), Zaman = o.GetDateTime(1),
                           Deger = o.GetDecimal(2),
                           Z = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                           Hedef = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4),
                           Sd = o.IsDBNull(5) ? (decimal?)null : o.GetDecimal(5),
                           Durum = o.GetInt16(6),
                           Ihlaller = o.GetFieldValue<string[]>(7),
                           Seviye = o.GetInt16(8), CihazKod = o.GetString(9),
                           Materyal = o.GetString(10), Lot = o.GetString(11),
                           Aksiyon = o.GetString(12), Kaynak = o.GetInt16(13) }, iptal);

            var tetkik = await veri.TekAsync("""
                select t.kod, t.ad, t.birim,
                       public.fn_lab_kk_gecerli(t.id) as gecerli
                  from public.lab_tetkik t where t.id = @p0
                """, [tetkikId],
                o => new { Kod = o.GetString(0), Ad = o.GetString(1),
                           Birim = o.GetString(2), Gecerli = o.GetBoolean(3) }, iptal);

            // CİHAZ OLAYLARI grafikle birlikte döner: kaymanın nedeni çoğu
            //   zaman kalibrasyon ya da reaktif lot değişimidir.
            var olaylar = await veri.ListeAsync("""
                select o.id, o.zaman, o.olay, o.aciklama, o.lot,
                       coalesce(c.kod, '') as cihaz
                  from public.lab_cihaz_olay o
                  left join public.cihaz c on c.id = o.cihaz_id
                 where (o.tetkik_id = @p0 or o.tetkik_id is null)
                   and o.zaman >= now() - make_interval(days => coalesce(@p1, 30))
                 order by o.zaman
                """, [tetkikId, gun],
                o => new { Id = o.GetInt32(0), Zaman = o.GetDateTime(1),
                           Olay = o.GetInt16(2), Aciklama = o.GetString(3),
                           Lot = o.GetString(4), Cihaz = o.GetString(5) }, iptal);

            return Results.Ok(new { tetkik, seri, olaylar, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/dkk - dış kalite sonucu; SDI sunucuda hesaplanır.
        grup.MapPost("/kk/dkk", async (
            KaliteKontrolServisi.DkkIstegi istek, BaglamCozucu cozucu,
            KaliteKontrolServisi kk, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var (id, sdi, degerlendirme, mesaj) = await kk.DkkAsync(istek, baglam, iptal);
            return Results.Ok(new { id, sdi, degerlendirme, mesaj,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/lab/kk/cihaz-mesaj/{id} - cihazdan gelen KONTROL mesajını
        //   KK ölçümüne çevirir (örnek numarası kontrol lotu kodudur).
        grup.MapPost("/kk/cihaz-mesaj/{id:long}", async (
            long id, BaglamCozucu cozucu, KaliteKontrolServisi kk, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Ekle);

            var yazilan = await kk.CihazMesajindanAsync(id, baglam, iptal);
            return Results.Ok(new { id, yazilan,
                mesaj = yazilan > 0 ? $"{yazilan} kontrol ölçümü kaydedildi."
                                    : "Eşleşen tetkik bulunamadı.",
                izlemeNo = baglam.IzlemeNo });
        });

        // GET /api/lab/kk/durum - testlerin KK geçerliliği (oto-onay penceresi).
        grup.MapGet("/kk/durum", async (
            BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.kk", Islem.Gor);

            var liste = await veri.ListeAsync("""
                select t.id, t.kod, t.ad,
                       public.fn_lab_kk_gecerli(t.id) as gecerli,
                       (select max(o.olcum_zamani) from public.lab_kk_olcum o
                         where o.tetkik_id = t.id) as "sonOlcum",
                       (select count(*) from public.lab_kk_olcum o
                         where o.tetkik_id = t.id and o.durum = 3
                           and o.olcum_zamani >= now() - interval '30 days') as "retSayisi"
                  from public.lab_tetkik t
                 where t.durum = 0
                   and exists (select 1 from public.lab_kk_hedef h
                                where h.tetkik_id = t.id and h.durum = 0)
                 order by t.kod
                """, [],
                o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2),
                           Gecerli = o.GetBoolean(3),
                           SonOlcum = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4),
                           RetSayisi = o.GetInt64(5) }, iptal);

            return Results.Ok(new { liste, izlemeNo = baglam.IzlemeNo });
        });

        // --------------------------------------------- muayene istem & sonuç ---

        // GET /api/lab/muayene/{id}/sonuclar - muayene kartının
        //   "İstem & Sonuçlar" sekmesi.
        //
        // <b>Bağ satırı yetmez.</b> muayene_istem yalnız "şu istem açıldı"
        // der; hekimin görmesi gereken SONUCUN KENDİSİDİR. Sekmede yalnız
        // bağ gösterilirse hekim her sonuç için laboratuvar ekranına gitmek
        // zorunda kalır - muayene sırasında olmayacak bir şey.
        //
        // <b>Aynı başvurunun laboratuvardan açılmış istemleri de gelir</b>:
        // muayeneden değil bankodan istenen tetkik de o hastanın o
        // başvurusuna aittir ve hekimi ilgilendirir.
        grup.MapGet("/muayene/{id:int}/sonuclar", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);

            var m = await veri.TekAsync("""
                select m.id, m.belge_id, m.taraf_id, m.durum
                  from public.muayene m where m.id = @p0
                """, [id],
                o => new { Id = o.GetInt32(0),
                           BelgeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1),
                           HastaId = o.GetInt32(2), Durum = o.GetInt16(3) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Muayene bulunamadı.");

            // Bağ satırları: hekimin "gördüm" işareti bunlarda durur.
            var baglar = await veri.ListeAsync("""
                select mi.id, mi.tur, mi.hedef_tablo as "hedefTablo", mi.hedef_id as "hedefId",
                       mi.aciliyet, mi.istem_zamani as "istemZamani",
                       mi.sonuc_durum as "sonucDurum", mi.sonuc_zamani as "sonucZamani",
                       mi.hekim_gordu as "hekimGordu"
                  from public.muayene_istem mi
                 where mi.muayene_id = @p0
                 order by mi.istem_zamani desc, mi.id desc
                """, [id], RaporSatiri, iptal);

            // LAB İSTEMLERİ: muayeneden açılanlar + aynı başvurunun diğerleri.
            var istemler = await veri.ListeAsync("""
                select i.id, i.istem_no as "istemNo", i.istem_tarihi as "istemTarihi",
                       i.durum, i.oncelik, i.klinik_bilgi as "klinikBilgi",
                       i.hedef_bitis as "hedefBitis",
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum <> 0) as tetkik,
                       (select count(*) from public.lab_istem_satir s
                         where s.istem_id = i.id and s.durum = 5) as onayli,
                       (select mi.id from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'lab_istem'
                           and mi.hedef_id = i.id limit 1) as "bagId",
                       (select mi.hekim_gordu from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'lab_istem'
                           and mi.hedef_id = i.id limit 1) as "hekimGordu"
                  from public.lab_istem i
                 where i.durum <> 9
                   and (i.belge_id = @p1
                        or exists (select 1 from public.muayene_istem mi
                                    where mi.muayene_id = @p0
                                      and mi.hedef_tablo = 'lab_istem'
                                      and mi.hedef_id = i.id))
                 order by i.istem_tarihi desc, i.id desc
                """, [id, m.BelgeId], RaporSatiri, iptal);

            // SONUÇ SATIRLARI: yalnız ONAYLI olanlar. Onaylanmamış değeri
            //   hekime göstermek, laboratuvarın henüz doğrulamadığı bir
            //   sayıya göre tedavi başlatılmasına yol açar.
            var sonuclar = await veri.ListeAsync("""
                select s.istem_id as "istemId", t.kod, t.ad, t.bolum, t.tur as "tetkikTur",
                       ls.deger_metin as deger, ls.birim, ls.bayrak, ls.panik,
                       ls.delta_uyari as "deltaUyari", ls.referans_alt as "referansAlt",
                       ls.referans_ust as "referansUst", ls.referans_metin as "referansMetin",
                       ls.olcum_zamani as "olcumZamani", ls.onay_zamani as "onayZamani",
                       ls.yorum, s.durum as "satirDurum"
                  from public.lab_istem_satir s
                  join public.lab_tetkik t on t.id = s.tetkik_id
                  left join lateral (
                        select * from public.lab_sonuc x
                         where x.istem_satir_id = s.id and x.durum = 3
                         order by x.id desc limit 1) ls on true
                 where s.durum <> 0
                   and s.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.durum <> 9
                           and (i2.belge_id = @p1
                                or exists (select 1 from public.muayene_istem mi
                                            where mi.muayene_id = @p0
                                              and mi.hedef_tablo = 'lab_istem'
                                              and mi.hedef_id = i2.id)))
                 order by s.istem_id desc, t.bolum, s.sira
                """, [id, m.BelgeId], RaporSatiri, iptal);

            // Kültür ve genetik ÖZETİ: ayrıntı laboratuvar ekranında, hekime
            //   sonuç cümlesi ve raporlanan bulgular yeter.
            var kulturler = await veri.ListeAsync("""
                select k.id, k.istem_id as "istemId", t.ad as tetkik, k.durum,
                       public.fn_lab_kultur_ozet(k.id) as ozet,
                       k.on_rapor as "onRapor", k.uzman_yorum as "uzmanYorum",
                       k.kritik, k.onay_zamani as "onayZamani",
                       (select count(*) from public.lab_antibiyogram g
                          join public.lab_kultur_ureme u on u.id = g.ureme_id
                         where u.kultur_id = k.id and g.bildir = 1) as "abSayisi"
                  from public.lab_kultur k
                  join public.lab_tetkik t on t.id = k.tetkik_id
                 where k.durum <> 0
                   and k.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.belge_id = @p1
                            or exists (select 1 from public.muayene_istem mi
                                        where mi.muayene_id = @p0
                                          and mi.hedef_tablo = 'lab_istem'
                                          and mi.hedef_id = i2.id))
                 order by k.id desc
                """, [id, m.BelgeId], RaporSatiri, iptal);

            var vakalar = await veri.ListeAsync("""
                select g.id, g.istem_id as "istemId", g.vaka_no as "vakaNo",
                       coalesce(p.ad, t.ad) as test, g.durum,
                       public.fn_lab_genetik_ozet(g.id) as ozet,
                       g.uzman_yorum as "uzmanYorum", g.oneriler,
                       g.onay_zamani as "onayZamani",
                       (select count(*) from public.lab_varyant v
                         where v.vaka_id = g.id and v.raporla = 1) as "varyantSayisi"
                  from public.lab_genetik_vaka g
                  join public.lab_tetkik t on t.id = g.tetkik_id
                  left join public.lab_genetik_panel p on p.id = g.panel_id
                 where g.durum <> 0
                   and g.istem_id in (
                        select i2.id from public.lab_istem i2
                         where i2.belge_id = @p1
                            or exists (select 1 from public.muayene_istem mi
                                        where mi.muayene_id = @p0
                                          and mi.hedef_tablo = 'lab_istem'
                                          and mi.hedef_id = i2.id))
                 order by g.id desc
                """, [id, m.BelgeId], RaporSatiri, iptal);

            // RADYOLOJİ: aynı sekmede görünür - hekim için "istem" tek
            //   kavramdır, modülü değil sonucu arar.
            var radyoloji = await veri.ListeAsync("""
                select ri.id, hz.ad as tetkik, ri.durum, ri.cekim_tarihi as "cekimTarihi",
                       coalesce(r.rapor_no, '') as "raporNo", r.onay_tarihi as "onayTarihi",
                       coalesce((select string_agg(b.metin, ' ' order by b.sira)
                                   from public.radyoloji_rapor_bolum b
                                  where b.rapor_id = r.id
                                    and lower(b.baslik) like '%sonu%'), '') as sonuc,
                       (select mi.id from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'radyoloji_istem'
                           and mi.hedef_id = ri.id limit 1) as "bagId",
                       (select mi.hekim_gordu from public.muayene_istem mi
                         where mi.muayene_id = @p0 and mi.hedef_tablo = 'radyoloji_istem'
                           and mi.hedef_id = ri.id limit 1) as "hekimGordu"
                  from public.radyoloji_istem ri
                  left join public.hizmet hz on hz.id = ri.hizmet_id
                  left join public.radyoloji_rapor r
                         on r.istem_id = ri.id and r.ust_rapor_id is null
                 where ri.belge_id = @p1
                    or exists (select 1 from public.muayene_istem mi
                                where mi.muayene_id = @p0
                                  and mi.hedef_tablo = 'radyoloji_istem'
                                  and mi.hedef_id = ri.id)
                 order by ri.id desc
                """, [id, m.BelgeId], RaporSatiri, iptal);

            return Results.Ok(new { muayeneId = id, belgeId = m.BelgeId, baglar,
                                    istemler, sonuclar, kulturler, vakalar, radyoloji,
                                    izlemeNo = baglam.IzlemeNo });
        });

        // ----------------------------------------------------------- etiket ---

        // GET /api/lab/etiket?istemId=... | numuneId=...
        //
        // TÜP ETİKETİ: kan alma bankosunun bastığı fiziksel etiket. Barkod
        // numunenin kimliğidir; cihaz da, kabul ekranı da onu okur.
        //
        // <b>Etikette hasta adı KISALTILIR</b> (35 mm'lik tüp etiketine tam
        // ad sığmaz) ama yaş ve cinsiyet KALIR: yanlış tüpü fark etmenin en
        // hızlı yolu budur. Doğum tarihi de gider - aynı adlı iki hasta
        // laboratuvarın klasik kazasıdır.
        grup.MapGet("/etiket", async (
            int? istemId, int? numuneId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("lab.numune", Islem.Gor);

            if (istemId is not > 0 && numuneId is not > 0)
                throw GentegreHatasi.Dogrulama("İstem ya da numune belirtilmeli.",
                    [new("istemId", "İstem ya da numune id'si verin.")]);

            var etiketler = await veri.ListeAsync("""
                select n.id, n.barkod, n.numune_tipi as "numuneTipi",
                       n.tup_tipi as "tupTipi", n.durum, n.alim_zamani as "alimZamani",
                       i.id as "istemId", i.istem_no as "istemNo",
                       i.istem_tarihi as "istemTarihi", i.oncelik,
                       i.klinik_bilgi as "klinikBilgi",
                       h.id as "hastaId",
                       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as hasta,
                       coalesce(h.kod, '') as "hastaNo",
                       hs.dogum_tarihi as "dogumTarihi",
                       coalesce(hs.cinsiyet, 0) as cinsiyet,
                       coalesce(b.belge_no, '') as protokol,
                       coalesce(p.unvan, '') as hekim,
                       -- Tüpteki tetkikler: teknisyen "bu tüpe ne çalışılacak"
                       --   sorusunu etiketten cevaplayabilmeli.
                       coalesce((select string_agg(t2.kod, ', ' order by s2.sira)
                                   from public.lab_istem_satir s2
                                   join public.lab_tetkik t2 on t2.id = s2.tetkik_id
                                  where s2.numune_id = n.id and s2.durum <> 0), '') as tetkikler,
                       coalesce((select string_agg(distinct
                                    case t3.bolum when 2 then 'Hematoloji'
                                         when 3 then 'Hormon' when 4 then 'Mikrobiyoloji'
                                         when 5 then 'Seroloji' when 6 then 'Koagülasyon'
                                         when 7 then 'İdrar' when 9 then 'Diğer'
                                         else 'Biyokimya' end, ' · ')
                                   from public.lab_istem_satir s3
                                   join public.lab_tetkik t3 on t3.id = s3.tetkik_id
                                  where s3.numune_id = n.id and s3.durum <> 0), '') as bolumler,
                       -- HASTA HAZIRLIĞI (açlık vb.) etikette değil, ekranda
                       --   uyarı olarak gösterilir; tüpe basmak yer kaplar.
                       coalesce((select string_agg(distinct t4.hazirlik_notu, ' · ')
                                   from public.lab_istem_satir s4
                                   join public.lab_tetkik t4 on t4.id = s4.tetkik_id
                                  where s4.numune_id = n.id and s4.durum <> 0
                                    and t4.hazirlik_notu <> ''), '') as hazirlik
                  from public.lab_numune n
                  join public.lab_istem i on i.id = n.istem_id
                  join public.taraf h on h.id = n.hasta_id
                  left join public.taraf_hasta hs on hs.id = n.hasta_id
                  left join public.belge b on b.id = i.belge_id
                  left join public.taraf p on p.id = i.personel_id
                 where (@p0::int is null or n.istem_id = @p0)
                   and (@p1::int is null or n.id = @p1)
                 order by n.id
                """, [istemId, numuneId], RaporSatiri, iptal);

            if (etiketler.Count == 0)
                throw GentegreHatasi.Bulunamadi("Etiket basılacak numune bulunamadı.");

            var kurum = await veri.TekAsync("""
                select coalesce(nullif(s.unvan, ''), s.ad) as unvan
                  from public.sube s
                 where s.id = coalesce(
                        (select n.sube_id from public.lab_numune n
                          where (@p0::int is null or n.istem_id = @p0)
                            and (@p1::int is null or n.id = @p1) limit 1),
                        (select id from public.sube where varsayilan = 1 limit 1))
                """, [istemId, numuneId], RaporSatiri, iptal);

            return Results.Ok(new { etiketler, kurum, izlemeNo = baglam.IzlemeNo });
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

    /// <summary>
    /// Rapor sorgularinda satir -> sozluk. Cikti ucu genis ve degisken alan
    /// kumesi tasiyor; her biri icin ayri DTO yazmak, rapora bir alan
    /// eklemeyi uc dosyada degisiklige cevirirdi (radyoloji ciktisiyla ayni
    /// desen).
    /// </summary>
    private static IDictionary<string, object?> RaporSatiri(NpgsqlDataReader o)
    {
        var satir = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            satir[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return satir;
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
