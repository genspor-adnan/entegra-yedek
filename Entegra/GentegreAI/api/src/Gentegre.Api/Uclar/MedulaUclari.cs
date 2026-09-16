using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MEDULA UÇLARI (707) — hasta kabul / provizyon ve hizmet kaydı. Mockup
/// <c>Ekranlar/Medula/medula_hasta_kabul.html</c>, <c>medula_hizmet_kayit.html</c>.
///
/// <para>Sıra: TCKN → müstehaklık → (kart/başvuru) → provizyon → hizmet kaydı
/// → çıkış → fatura. Her uç kuyruk satırı açıp <see cref="MedulaServisi"/>
/// ile dener; ekran "sonuç kodu + mesaj + bekliyor mu" alır.</para>
/// </summary>
public static partial class MedulaUclari
{
    public sealed record MustehaklikIstegi(int HastaId, int? BelgeId, int? ProvizyonTipi);
    public sealed record HastaKabulIstegi(int? TakipTipi, int? ProvizyonTipi, string? BransKodu, int? HekimId,
                                          bool? Sevkli, string? SevkKurum);
    public sealed record CikisIstegi(int? CikisSekli);
    public sealed record HizmetGonderIstegi(int[]? SatirIds, bool? TanilarDa);

    public static void MedulaUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/medula").WithTags("Medula").RequireAuthorization();
        KabulUclariniEkle(grup);
        HizmetUclariniEkle(grup);
        ReceteUclariniEkle(grup);
        FaturaUclariniEkle(grup);
        KuyrukUclariniEkle(grup);
    }

    // ============================================================ hasta kabul ==
    private static void KabulUclariniEkle(RouteGroupBuilder grup)
    {
        // Hastanın Medula özeti: SGK kaydı, son müstehaklık, takipler, reçeteler, raporlar.
        grup.MapGet("/hasta/{hastaId:int}/ozet", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var hasta = await b.TekAsync("""
                select t.id, t.unvan, coalesce(t.vkno, '') as tckn, th.dogum_tarihi,
                       extract(year from age(current_date, th.dogum_tarihi))::int as yas, coalesce(th.cinsiyet, 0)::int,
                       (select k.tur from public.taraf_hasta_kurum k where k.hasta_id = t.id and k.aktif = 1
                         order by case k.tur when 3 then 0 when 4 then 1 when 2 then 2 else 3 end limit 1) as kurum_tur,
                       (select x.unvan from public.taraf_hasta_kurum k join public.taraf x on x.id = k.kurum_id
                         where k.hasta_id = t.id and k.aktif = 1 order by case k.tur when 3 then 0 else 1 end limit 1) as kurum_adi
                  from public.taraf t left join public.taraf_hasta th on th.id = t.id where t.id = @p0
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), unvan = o.GetString(1), tckn = o.GetString(2),
                dogumTarihi = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3),
                yas = o.IsDBNull(4) ? (int?)null : o.GetInt32(4), cinsiyet = o.GetInt32(5),
                kurumTur = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6), kurumAdi = o.Metin("kurum_adi"),
            }, iptal) ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

            var takipler = await b.ListeAsync("""
                select v.belge_id, v.belge_no, v.belge_tarihi, v.sgk_durum, v.sgk_takip_no, v.sgk_provizyon_no,
                       v.sgk_takip_turu, v.sgk_provizyon_tipi, v.sgk_sigorta_turu, v.sgk_mustehaklik, v.sgk_mustehaklik_zaman,
                       v.sgk_takip_tarihi, v.sgk_gecerlilik, v.sgk_red_nedeni, v.sgk_cikis_zaman, v.sgk_brans_kodu,
                       coalesce(v.hekim_adi, ''), coalesce(v.bolum_adi, ''), v.kabul_islem, v.hatali_islem, v.satir_sayisi,
                       v.yerel_tutar, v.medula_fatura_no, v.medula_tutar, v.fatura_durum, v.hata_sayisi, v.hekim_id
                  from public.v_medula_takip v where v.hasta_id = @p0 order by v.belge_id desc limit 30
                """, null, [hastaId], TakipOku, iptal);

            var receteler = await b.ListeAsync("""
                select r.id, r.recete_no, r.ekleme_tarihi, r.durum, r.medula_recete_no, r.medula_sonuc, coalesce(h.unvan, ''),
                       (select count(*) from public.recete_satir s where s.recete_id = r.id)::int
                  from public.recete r left join public.taraf h on h.id = r.hekim_id
                 where r.hasta_id = @p0 order by r.id desc limit 20
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), receteNo = o.GetString(1), tarih = o.GetDateTime(2), durum = (int)o.GetInt16(3),
                medulaReceteNo = o.GetString(4), medulaSonuc = o.GetString(5), hekim = o.GetString(6), ilac = o.GetInt32(7),
            }, iptal);

            var raporlar = await b.ListeAsync("""
                select r.id, r.rapor_turu, r.rapor_no, r.icd_kod, r.tani, r.baslangic, r.bitis, r.durum, r.medula_sonuc
                  from public.medula_rapor r where r.hasta_id = @p0 order by r.id desc limit 20
                """, null, [hastaId], o => new
            {
                id = o.GetInt32(0), raporTuru = (int)o.GetInt16(1), raporNo = o.GetString(2), icdKod = o.GetString(3),
                tani = o.GetString(4), baslangic = o.GetDateTime(5), bitis = o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                durum = (int)o.GetInt16(7), medulaSonuc = o.GetString(8),
            }, iptal);

            return Results.Ok(new { hasta, takipler, receteler, raporlar });
        });

        // Müstehaklık: hasta bazlı; başvuru verilmişse sonucu provizyon satırına da yazar.
        grup.MapPost("/mustehaklik", async (
            MustehaklikIstegi istek, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.provizyon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var tckn = await b.TekDegerAsync<string>("select coalesce(vkno, '') from public.taraf where id = @p0", null, [istek.HastaId], iptal) ?? "";
            var tesis = await TesisKoduAsync(b, iptal);
            var s = await medula.CagirAsync("YardimciIslemler", "mustehaklikSorgu", "taraf", istek.HastaId, istek.HastaId, istek.BelgeId,
                new { tckn, tesisKodu = tesis, provizyonTipi = istek.ProvizyonTipi ?? 1, sorguTarihi = DateTime.UtcNow },
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, 1, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj, yanit = s.Yanit });
        });

        // Hasta kabul = provizyon al (takip no). Başvuru üstünden.
        grup.MapPost("/basvuru/{belgeId:int}/hasta-kabul", async (
            int belgeId, HastaKabulIstegi istek, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.provizyon", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var bv = await BasvuruOkuAsync(b, belgeId, iptal);
            var acik = await b.TekDegerAsync<string>("select sgk_takip_no from public.belge_provizyon where id = @p0 and sgk_durum = 1", null, [belgeId], iptal);
            if (!string.IsNullOrEmpty(acik)) throw GentegreHatasi.IsKurali($"Bu başvurunun açık takibi var: {acik}");

            var hekimId = istek.HekimId ?? bv.hekimId;
            var hekim = hekimId is int hid ? await b.TekAsync("""
                select coalesce(p.tescil_no, ''), coalesce(p.medula_brans_kodu, ''), coalesce(t.vkno, '')
                  from public.taraf t left join public.taraf_personel p on p.id = t.id where t.id = @p0
                """, null, [hid], o => new { tescil = o.GetString(0), brans = o.GetString(1), tckn = o.GetString(2) }, iptal) : null;
            var brans = istek.BransKodu ?? (hekim?.brans is { Length: > 0 } hb ? hb : bv.bolumId?.ToString() ?? "");
            var tesis = await TesisKoduAsync(b, iptal);
            var s = await medula.CagirAsync("HastaKabulIslemleri", "hastaKabul", "belge", belgeId, bv.hastaId, belgeId, new
            {
                tesisKodu = tesis, hastaTckn = bv.tckn, takipTipi = istek.TakipTipi ?? 1, provizyonTipi = istek.ProvizyonTipi ?? 1,
                bransKodu = brans, hekimId, hekimTckn = hekim?.tckn ?? "", hekimTescil = hekim?.tescil ?? "",
                sevkli = istek.Sevkli ?? false, sevkKurum = istek.SevkKurum ?? "", provizyonTarihi = DateTime.UtcNow,
            }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 1, iptal);
            if (istek.Sevkli == true)
                await b.CalistirAsync("update public.belge_provizyon set sgk_sevkli = 1, sgk_sevk_kurum = @p1 where id = @p0",
                    null, [belgeId, istek.SevkKurum ?? ""], iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj, yanit = s.Yanit });
        });

        grup.MapPost("/basvuru/{belgeId:int}/hasta-kabul-iptal", async (
            int belgeId, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.provizyon", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            var bv = await BasvuruOkuAsync(b, belgeId, iptal);
            if (bv.takipNo == "") throw GentegreHatasi.IsKurali("Başvurunun takip numarası yok.");
            var s = await medula.CagirAsync("HastaKabulIslemleri", "hastaKabulIptal", "belge", belgeId, bv.hastaId, belgeId,
                new { takipNo = bv.takipNo }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 2, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        grup.MapPost("/basvuru/{belgeId:int}/hasta-cikis", async (
            int belgeId, CikisIstegi? istek, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.provizyon", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var bv = await BasvuruOkuAsync(b, belgeId, iptal);
            if (bv.takipNo == "") throw GentegreHatasi.IsKurali("Takip yok; önce provizyon alın.");
            var s = await medula.CagirAsync("HastaKabulIslemleri", "hastaCikisKayit", "belge", belgeId, bv.hastaId, belgeId,
                new { takipNo = bv.takipNo, cikisSekli = istek?.CikisSekli ?? 1, cikisZamani = DateTime.UtcNow },
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, 3, iptal);
            return Results.Ok(new { s.KuyrukId, s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        // Takip ara: v_medula_takip üstünde metin/takip no.
        grup.MapGet("/takip-ara", async (
            string? q, int? sadeceAcik, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var arama = "%" + (q ?? "").Trim() + "%";
            var liste = await b.ListeAsync("""
                select v.belge_id, v.belge_no, v.belge_tarihi, v.sgk_durum, v.sgk_takip_no, v.sgk_provizyon_no,
                       v.sgk_takip_turu, v.sgk_provizyon_tipi, v.sgk_sigorta_turu, v.sgk_mustehaklik, v.sgk_mustehaklik_zaman,
                       v.sgk_takip_tarihi, v.sgk_gecerlilik, v.sgk_red_nedeni, v.sgk_cikis_zaman, v.sgk_brans_kodu,
                       coalesce(v.hekim_adi, ''), coalesce(v.bolum_adi, ''), v.kabul_islem, v.hatali_islem, v.satir_sayisi,
                       v.yerel_tutar, v.medula_fatura_no, v.medula_tutar, v.fatura_durum, v.hata_sayisi, v.hekim_id,
                       v.hasta_id, v.hasta_adi
                  from public.v_medula_takip v
                 where (v.hasta_adi ilike @p0 or v.sgk_takip_no ilike @p0 or v.belge_no ilike @p0)
                   and (@p1 = 0 or (v.sgk_durum = 1 and v.sgk_cikis_zaman is null))
                 order by v.belge_id desc limit 100
                """, null, [arama, sadeceAcik ?? 0], o => new { takip = TakipOku(o), hastaId = o.GetInt32(27), hasta = o.GetString(28) }, iptal);
            return Results.Ok(liste);
        });
    }

    // ============================================================ hizmet kaydı ==
    private static void HizmetUclariniEkle(RouteGroupBuilder grup)
    {
        // Başvurunun hizmet kaydı görünümü: tanılar, satırlar ↔ medula_islem, günlük.
        grup.MapGet("/basvuru/{belgeId:int}/hizmet", async (
            int belgeId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var takip = await b.TekAsync("""
                select v.belge_id, v.belge_no, v.belge_tarihi, v.sgk_durum, v.sgk_takip_no, v.sgk_provizyon_no,
                       v.sgk_takip_turu, v.sgk_provizyon_tipi, v.sgk_sigorta_turu, v.sgk_mustehaklik, v.sgk_mustehaklik_zaman,
                       v.sgk_takip_tarihi, v.sgk_gecerlilik, v.sgk_red_nedeni, v.sgk_cikis_zaman, v.sgk_brans_kodu,
                       coalesce(v.hekim_adi, ''), coalesce(v.bolum_adi, ''), v.kabul_islem, v.hatali_islem, v.satir_sayisi,
                       v.yerel_tutar, v.medula_fatura_no, v.medula_tutar, v.fatura_durum, v.hata_sayisi, v.hekim_id,
                       v.hasta_id, v.hasta_adi
                  from public.v_medula_takip v where v.belge_id = @p0
                """, null, [belgeId], o => new { takip = TakipOku(o), hastaId = o.GetInt32(27), hasta = o.GetString(28) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

            var tanilar = await b.ListeAsync("""
                select t.id, t.icd_kod, coalesce(k.ad, '') as ad, t.tur, t.dis_no, m.id as muayene_id,
                       mt.id as medula_id, mt.durum, mt.sonuc_kod
                  from public.muayene m
                  join public.tani t on t.muayene_id = m.id
                  left join public.icd k on k.kod = t.icd_kod
                  left join public.medula_tani mt on mt.tani_id = t.id and mt.belge_id = m.belge_id
                 where m.belge_id = @p0 order by t.tur, t.sira, t.id
                """, null, [belgeId], o => new
            {
                id = o.GetInt32(0), icdKod = o.GetString(1), ad = o.GetString(2), tur = (int)o.GetInt16(3),
                disNo = o.IsDBNull(4) ? (int?)null : (int)o.GetInt16(4), muayeneId = o.GetInt32(5),
                medulaId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6),
                durum = o.IsDBNull(7) ? 0 : (int)o.GetInt16(7), sonucKod = o.Metin("sonuc_kod"),
            }, iptal);

            var satirlar = await b.ListeAsync("""
                select s.id, coalesce(h.sut_kodu, ''), coalesce(h.ad, s.aciklama), s.adet, s.tutar_kdvli, s.dis_no,
                       coalesce(h.radyoloji, 0), i.id, i.durum, i.sonuc_kod, i.sonuc_mesaj, i.medula_sira, i.tutar, i.tetkik,
                       s.teslim_tarihi
                  from public.belge_satir s
                  left join public.hizmet h on h.id = s.hizmet_id
                  left join public.medula_islem i on i.belge_satir_id = s.id and i.durum <> 4
                 where s.belge_id = @p0 and s.hizmet_id is not null order by s.sira, s.id
                """, null, [belgeId], o => new
            {
                satirId = o.GetInt32(0), sutKodu = o.GetString(1), islem = o.GetString(2), adet = o.GetDecimal(3),
                yerelTutar = o.GetDecimal(4), disNo = o.IsDBNull(5) ? (int?)null : (int)o.GetInt16(5),
                tetkik = o.GetInt16(6) == 1, medulaId = o.IsDBNull(7) ? (int?)null : o.GetInt32(7),
                durum = o.IsDBNull(8) ? 0 : (int)o.GetInt16(8), sonucKod = o.Metin("sonuc_kod"), sonucMesaj = o.Metin("sonuc_mesaj"),
                medulaSira = o.IsDBNull(11) ? (int?)null : o.GetInt32(11),
                medulaTutar = o.IsDBNull(12) ? (decimal?)null : o.GetDecimal(12),
                tarih = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
            }, iptal);

            var gunluk = await KuyrukListesiAsync(b, "q.belge_id = @p0", [belgeId], 50, iptal);
            return Results.Ok(new { takip.takip, takip.hastaId, takip.hasta, tanilar, satirlar, gunluk });
        });

        // Gönder: tanılar + seçili (yoksa tüm) satırlar. Her satır bir kuyruk satırı.
        grup.MapPost("/basvuru/{belgeId:int}/hizmet-gonder", async (
            int belgeId, HizmetGonderIstegi? istek, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.hizmet", Islem.Ekle);
            await using var b = await veri.AcAsync(iptal);
            var bv = await BasvuruOkuAsync(b, belgeId, iptal);
            if (bv.takipNo == "") throw GentegreHatasi.IsKurali("Takip yok; önce provizyon alın.");
            var sube = baglam.SubeId ?? 0;
            int kabul = 0, hata = 0, bekleyen = 0;

            if (istek?.TanilarDa != false)
            {
                var tanilar = await b.ListeAsync("""
                    select t.id, t.icd_kod, t.tur, t.dis_no from public.muayene m join public.tani t on t.muayene_id = m.id
                     where m.belge_id = @p0 and not exists (select 1 from public.medula_tani mt where mt.tani_id = t.id and mt.durum = 2)
                    """, null, [belgeId], o => new { id = o.GetInt32(0), icd = o.GetString(1), tur = o.GetInt16(2),
                                                     dis = o.IsDBNull(3) ? (short?)null : o.GetInt16(3) }, iptal);
                foreach (var t in tanilar)
                {
                    var mtId = await b.TekDegerAsync<int>("""
                        insert into public.medula_tani (belge_id, tani_id, icd_kod, ana_tani, dis_no, sube_id, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, @p5, @p6) returning id
                        """, null, [belgeId, t.id, t.icd, (short)(t.tur == 1 ? 1 : 0), t.dis, sube, baglam.KullaniciId], iptal);
                    var s = await medula.CagirAsync("HizmetKayitIslemleri", "taniKayit", "medula_tani", mtId, bv.hastaId, belgeId,
                        new { takipNo = bv.takipNo, icdKod = t.icd, anaTani = t.tur == 1, disNo = t.dis },
                        baglam.KullaniciId, baglam.SubeId, baglam.Ip, 4, iptal);
                    if (s.Kabul) kabul++; else if (s.Bekliyor) bekleyen++; else hata++;
                }
            }

            var satirlar = await b.ListeAsync("""
                select s.id, coalesce(h.sut_kodu, ''), coalesce(h.ad, s.aciklama), s.adet, s.tutar_kdvli, s.dis_no,
                       coalesce(h.radyoloji, 0), coalesce(s.teslim_tarihi, now())::date, bb.personel_id
                  from public.belge_satir s
                  left join public.hizmet h on h.id = s.hizmet_id
                  left join public.belge_basvuru bb on bb.id = s.belge_id
                 where s.belge_id = @p0 and s.hizmet_id is not null
                   and (@p1::int[] is null or s.id = any(@p1))
                   and not exists (select 1 from public.medula_islem i where i.belge_satir_id = s.id and i.durum in (2, 5))
                 order by s.sira, s.id
                """, null, [belgeId, istek?.SatirIds], o => new
            {
                id = o.GetInt32(0), sut = o.GetString(1), ad = o.GetString(2), adet = o.GetDecimal(3), tutar = o.GetDecimal(4),
                dis = o.IsDBNull(5) ? (short?)null : o.GetInt16(5), tetkik = o.GetInt16(6) == 1, tarih = o.GetDateTime(7),
                hekimId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
            }, iptal);
            foreach (var s in satirlar)
            {
                // Eski hatalı kayıt varsa aynı satır tekrar kullanılır (deneme sayısı kuyrukta).
                var miId = await b.TekDegerAsync<int?>("select id from public.medula_islem where belge_satir_id = @p0 and durum <> 4", null, [s.id], iptal)
                    ?? await b.TekDegerAsync<int>("""
                        insert into public.medula_islem (sube_id, belge_id, belge_satir_id, takip_no, sut_kodu, islem_adi, adet, tutar, tarih, hekim_id, dis_no, tetkik, ekleyen)
                        values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12) returning id
                        """, null, [sube, belgeId, s.id, bv.takipNo, s.sut, s.ad, s.adet, s.tutar, s.tarih, s.hekimId, s.dis,
                                    (short)(s.tetkik ? 1 : 0), baglam.KullaniciId], iptal);
                var r = await medula.CagirAsync("HizmetKayitIslemleri", s.tetkik ? "tetkikVeRadyolojiKayit" : "hizmetKayit",
                    "medula_islem", miId, bv.hastaId, belgeId,
                    new { takipNo = bv.takipNo, sutKodu = s.sut, adet = s.adet, tarih = s.tarih, hekimId = s.hekimId, disNo = s.dis, tutar = s.tutar },
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip, 5, iptal);
                if (r.Kabul) kabul++; else if (r.Bekliyor) bekleyen++; else hata++;
            }
            return Results.Ok(new { gonderilen = satirlar.Count, kabul, hata, bekleyen });
        });

        grup.MapPost("/islem/{id:int}/iptal", async (
            int id, MedulaServisi medula, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.hizmet", Islem.Sil);
            await using var b = await veri.AcAsync(iptal);
            var i = await b.TekAsync("select belge_id, takip_no, medula_sira, durum, sut_kodu from public.medula_islem where id = @p0", null, [id],
                o => new { belgeId = o.GetInt32(0), takip = o.GetString(1), sira = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                           durum = o.GetInt16(3), sut = o.GetString(4) }, iptal) ?? throw GentegreHatasi.Bulunamadi();
            var hastaId = await b.TekDegerAsync<int>("select taraf_id from public.belge where id = @p0", null, [i.belgeId], iptal);
            if (i.durum != 2)
            {
                // Medula'da kabul edilmemiş satır: yerelde iptal yeter.
                await b.CalistirAsync("update public.medula_islem set durum = 4, degistirme_tarihi = now() where id = @p0", null, [id], iptal);
                return Results.Ok(new { Kabul = true, Kod = "", Mesaj = "Yerel kayıt iptal edildi." });
            }
            var s = await medula.CagirAsync("HizmetKayitIslemleri", "hizmetKayitIptal", "medula_islem", id, hastaId, i.belgeId,
                new { takipNo = i.takip, sira = i.sira, sutKodu = i.sut }, baglam.KullaniciId, baglam.SubeId, baglam.Ip, 5, iptal);
            return Results.Ok(new { s.Kabul, s.Bekliyor, s.Kod, s.Mesaj });
        });

        // "Hastaya ücretli bırak": Medula'ya gitmez, yerel satır kalır.
        grup.MapPost("/islem/{id:int}/yerel", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("medula.hizmet", Islem.Degistir);
            await veri.CalistirAsync("update public.medula_islem set durum = 5, sonuc_kod = '', sonuc_mesaj = 'Hastaya ücretli bırakıldı', degistirme_tarihi = now() where id = @p0 and durum <> 2",
                [id], iptal);
            return Results.Ok(new { durum = 5 });
        });
    }

    // ------------------------------------------------------------- yardımcılar ----
    internal sealed record BasvuruBilgi(int hastaId, string tckn, int? hekimId, int? bolumId, string takipNo, short sgkDurum, DateTime? cikis);

    internal static async Task<BasvuruBilgi> BasvuruOkuAsync(NpgsqlConnection b, int belgeId, CancellationToken iptal)
        => await b.TekAsync("""
            select x.taraf_id, coalesce(t.vkno, ''), bb.personel_id, bb.bolum_id,
                   coalesce(p.sgk_takip_no, ''), coalesce(p.sgk_durum, 0), p.sgk_cikis_zaman
              from public.belge x
              join public.taraf t on t.id = x.taraf_id
              left join public.belge_basvuru bb on bb.id = x.id
              left join public.belge_provizyon p on p.id = x.id
             where x.id = @p0 and x.tur = 19
            """, null, [belgeId], o => new BasvuruBilgi(o.GetInt32(0), o.GetString(1),
                o.IsDBNull(2) ? null : o.GetInt32(2), o.IsDBNull(3) ? null : o.GetInt32(3), o.GetString(4), o.GetInt16(5),
                o.IsDBNull(6) ? null : o.GetDateTime(6)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

    internal static async Task<string> TesisKoduAsync(NpgsqlConnection b, CancellationToken iptal)
        => await b.TekDegerAsync<string>("select coalesce(kurum_kodu, '') from public.entegrasyon_hesap where kod = 'MEDULA' order by test_mi nulls last, id limit 1", null, [], iptal) ?? "";

    internal static object TakipOku(NpgsqlDataReader o) => new
    {
        belgeId = o.GetInt32(0), belgeNo = o.GetString(1), belgeTarihi = o.GetDateTime(2),
        sgkDurum = o.IsDBNull(3) ? 0 : (int)o.GetInt16(3), takipNo = o.Metin("sgk_takip_no"), provizyonNo = o.Metin("sgk_provizyon_no"),
        takipTuru = o.IsDBNull(6) ? (int?)null : (int)o.GetInt16(6), provizyonTipi = o.IsDBNull(7) ? (int?)null : (int)o.GetInt16(7),
        sigortaTuru = o.Metin("sgk_sigorta_turu"), mustehaklik = o.IsDBNull(9) ? 0 : (int)o.GetInt16(9),
        mustehaklikZaman = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10),
        takipTarihi = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
        gecerlilik = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12),
        redNedeni = o.Metin("sgk_red_nedeni"), cikisZaman = o.IsDBNull(14) ? (DateTime?)null : o.GetDateTime(14),
        bransKodu = o.Metin("sgk_brans_kodu"), hekim = o.GetString(16), bolum = o.GetString(17),
        kabulIslem = o.GetInt32(18), hataliIslem = o.GetInt32(19), satirSayisi = o.GetInt32(20), yerelTutar = o.GetDecimal(21),
        medulaFaturaNo = o.Metin("medula_fatura_no"), medulaTutar = o.IsDBNull(23) ? (decimal?)null : o.GetDecimal(23),
        faturaDurum = o.IsDBNull(24) ? (int?)null : (int)o.GetInt16(24), hataSayisi = o.GetInt32(25),
        hekimId = o.IsDBNull(26) ? (int?)null : o.GetInt32(26),
    };

    internal static async Task<List<object>> KuyrukListesiAsync(NpgsqlConnection b, string kosul, object?[] par, int enFazla, CancellationToken iptal)
        => await b.ListeAsync($"""
            select q.id, q.servis, q.islem, q.kaynak_tablo, q.kaynak_id, q.hasta_adi, q.belge_id, q.sonuc_kod, q.sonuc_mesaj,
                   q.durum, q.deneme, q.sonraki_deneme, q.gonderim, q.sure_ms, q.kullanici_adi, q.ekleme_tarihi, q.hasta_id
              from public.v_medula_kuyruk q where {kosul} order by q.id desc limit {enFazla}
            """, null, par, o => (object)new
        {
            id = o.GetInt64(0), servis = o.GetString(1), islem = o.GetString(2), kaynakTablo = o.GetString(3),
            kaynakId = o.IsDBNull(4) ? (long?)null : o.GetInt64(4), hasta = o.GetString(5),
            belgeId = o.IsDBNull(6) ? (int?)null : o.GetInt32(6), sonucKod = o.GetString(7), sonucMesaj = o.GetString(8),
            durum = (int)o.GetInt16(9), deneme = (int)o.GetInt16(10),
            sonrakiDeneme = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
            gonderim = o.IsDBNull(12) ? (DateTime?)null : o.GetDateTime(12), sureMs = o.GetInt32(13),
            kullanici = o.GetString(14), zaman = o.GetDateTime(15), hastaId = o.IsDBNull(16) ? (int?)null : o.GetInt32(16),
        }, iptal);
}
