using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// YIL SONU DEVRİ (1155) — beş adım uçtan uca, TEK İŞLEMDE ve sonunda ROLLBACK (test DB'de iz kalmaz).
/// Boş bir yılda (2031 → 2032) çalışır: 2031'e bir satış (600) ve bir 7/A gider (770) fişi konur,
/// beklenen: kapanışta 6xx ve 7xx sıfır, dönem kârı 590'a; açılışta 590 → 570; 4. adım geri alınabilir;
/// kilitten sonra geri alma reddedilir.
/// </summary>
public sealed class YilDevriTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private const short Yil = 2031;

    [VtFact]
    public async Task Bes_adim_kapanis_acilis_geri_al_ve_kilit()
    {
        if (!_olgu.Baglandi(nameof(Bes_adim_kapanis_acilis_geri_al_ve_kilit))) return;
        var veri = _olgu.Gerekli();
        var ct = CancellationToken.None;
        await using var b = await veri.AcAsync(ct);
        await using var t = await b.BeginTransactionAsync(ct);
        try
        {
            var sube = await b.TekDegerAsync<int>("select min(id) from public.sube", t, [], ct);
            // Hazırlık: devir hesapları + 7/A eşleri, 31.12 kuru, açık banko oturumu / gün kapanışı engel olmasın.
            await b.CalistirAsync("""
                insert into public.hesap_plani (kod, ad, seviye, sinif, calisir_mi, cari_alt_hesap, durum)
                select k, 'TEST ' || k, 3, left(k, 1)::smallint, 1, 0, 1
                  from unnest(array['100','600','646','656','690','692','590','591','570','580','770','771','632']) k
                 where public.fn_yil_devri_hesap(k) is null
                """, t, [], ct);
            await b.CalistirAsync("""
                insert into public.doviz_kur (doviz_cinsi, tarih, alis, satis, efektif_alis, efektif_satis)
                select d, make_date(@p0, 12, 31), 40, 40, 40, 40
                  from (select distinct doviz_cinsi d from public.mali_hareket where doviz_cinsi <> public.fn_yerel_para()) x
                """, t, [(int)Yil], ct);
            await b.CalistirAsync("update public.banko_oturum set durum = 4 where durum = 2 and sube_id = @p0", t, [sube], ct);
            await b.CalistirAsync("update public.muhasebe_fis_hata set cozuldu = 1 where cozuldu = 0", t, [], ct);
            await b.CalistirAsync("update public.belge set durum = 0 where durum = 1 and sube_id = @p0 and extract(year from belge_tarihi) = @p1",
                                  t, [sube, (int)Yil], ct);

            // 2031: satış 1.000 (100 / 600) + 7/A gider 300 (770 / 100).
            var fis = await b.TekDegerAsync<int>("""
                insert into public.muhasebe_fis (fis_no, fis_tarihi, tur, durum, kaynak_tur, kaynak_id, aciklama, sube_id, ekleyen)
                values ('', make_date(@p0, 6, 1), 1, 1, 3, 0, 'TEST devir verisi', @p1, 0) returning id
                """, t, [(int)Yil, sube], ct);
            await b.CalistirAsync("select public.fn_yil_devri_satir(@p0, public.fn_yil_devri_hesap('100'), 1000, null, 't')", t, [fis], ct);
            await b.CalistirAsync("select public.fn_yil_devri_satir(@p0, public.fn_yil_devri_hesap('600'), -1000, null, 't')", t, [fis], ct);
            await b.CalistirAsync("select public.fn_yil_devri_satir(@p0, public.fn_yil_devri_hesap('770'), 300, null, 't')", t, [fis], ct);
            await b.CalistirAsync("select public.fn_yil_devri_satir(@p0, public.fn_yil_devri_hesap('100'), -300, null, 't')", t, [fis], ct);

            var devir = await b.TekDegerAsync<int>(
                "insert into public.yil_devri (sube_id, kaynak_yil, hedef_yil) values (@p0, @p1, @p1 + 1) returning id",
                t, [sube, (int)Yil], ct);
            for (var a = 1; a <= 4; a++)
                await b.CalistirAsync(a switch
                {
                    1 => "select public.fn_yil_devri_adim1(@p0, 0)",
                    2 => "select public.fn_yil_devri_adim2(@p0, 0, true, true)",
                    3 => "select public.fn_yil_devri_adim3(@p0, 0, false)",
                    _ => "select public.fn_yil_devri_adim4(@p0, 0, false)",
                }, t, [devir], ct);

            // Kapanış: 2031'de 6xx / 7xx kalmaz; kâr 700 590'da (alacak).
            var kalan = await b.TekDegerAsync<long>("""
                select count(*) from public.fn_yil_devri_mizan(@p0, make_date(@p1, 1, 1), make_date(@p1, 12, 31)) m
                 where left(m.kod, 1) in ('6', '7') and round(m.borc - m.alacak, 2) <> 0
                """, t, [sube, (int)Yil], ct);
            Assert.Equal(0, kalan);
            var kar = await b.TekDegerAsync<decimal>("""
                select coalesce(sum(m.alacak - m.borc), 0) from public.fn_yil_devri_mizan(@p0, make_date(@p1, 1, 1), make_date(@p1, 12, 31)) m
                 where m.kod = '590'
                """, t, [sube, (int)Yil], ct);
            Assert.Equal(700m, kar);

            // 4. adım geri alınır, yeniden yapılır.
            await b.CalistirAsync("select public.fn_yil_devri_geri_al(@p0, 0)", t, [devir], ct);
            Assert.Equal(3, await b.TekDegerAsync<short>("select tamam_adim from public.yil_devri where id = @p0", t, [devir], ct));
            await b.CalistirAsync("select public.fn_yil_devri_adim4(@p0, 0, false)", t, [devir], ct);

            // Açılış + kilit: 2032-01-01 fişi dengeli, 570 alacağında 700 var, 2031 ayları kilitli.
            await b.CalistirAsync("select public.fn_yil_devri_adim5(@p0, 0, true)", t, [devir], ct);
            var acilis570 = await b.TekDegerAsync<decimal>("""
                select coalesce(sum(s.alacak - s.borc), 0) from public.muhasebe_fis f
                  join public.muhasebe_fis_satir s on s.fis_id = f.id join public.hesap_plani h on h.id = s.hesap_plani_id
                 where f.kaynak_tur = 5 and f.kaynak_id = @p0 * 10 + 5 and h.kod = '570'
                """, t, [devir], ct);
            Assert.True(acilis570 >= 700m, $"570 açılış alacağı {acilis570}");
            var dengesiz = await b.TekDegerAsync<long>(
                "select count(*) from public.muhasebe_fis where kaynak_tur in (4, 5) and kaynak_id between @p0 * 10 and @p0 * 10 + 9 and toplam_borc <> toplam_alacak",
                t, [devir], ct);
            Assert.Equal(0, dengesiz);
            Assert.Equal(1, await b.TekDegerAsync<short>("select durum from public.yil_devri where id = @p0", t, [devir], ct));

            // Kilitten sonra geri alma reddedilir (savepoint: işlem bozulmasın).
            await b.CalistirAsync("savepoint s1", t, [], ct);
            var hata = await Assert.ThrowsAsync<PostgresException>(() =>
                b.CalistirAsync("select public.fn_yil_devri_geri_al(@p0, 0)", t, [devir], ct));
            Assert.Contains("kilitlendi", hata.MessageText);
            await b.CalistirAsync("rollback to savepoint s1", t, [], ct);
        }
        finally
        {
            await t.RollbackAsync(ct);
        }
    }
}
