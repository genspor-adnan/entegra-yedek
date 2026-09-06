using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// DIŞ LABORATUVAR GÖNDERİMİ (445).
///
/// <para><b>Numune binadan çıkar.</b> O andan itibaren laboratuvarın elinde
/// olan tek şey kayıttır: hangi tüp, kime, ne zaman, hangi kurye ile, hangi
/// sıcaklıkta gitti. Numune kaybolduğunda ya da sonuç geciktiğinde cevabı
/// verecek olan bu zincirdir.</para>
///
/// <para><b>Dış lab sonucu oto-onaya girmez</b>: başka bir laboratuvarın
/// yöntemini, referans aralığını ve kalite kontrolünü biz doğrulamadık.
/// Sonuç kaydedilir, uzman görüp onaylar.</para>
///
/// <para><b>Aynı tetkik iki kez gönderilmez</b> (benzersiz indeks): mükerrer
/// gönderim hem ikinci kez faturalanır hem iki farklı sonuç döndürür.</para>
/// </summary>
public sealed class DisLabServisi(VeriKaynagi veri, LabServisi lab)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly LabServisi _lab = lab;

    // Gönderim durumları (db/445): 0 iptal · 1 hazırlanıyor · 2 yolda ·
    //   3 teslim edildi · 4 kısmi sonuç · 5 sonuçlandı.
    private const short Hazirlaniyor = 1, Yolda = 2, Teslim = 3,
                        Kismi = 4, Sonuclandi = 5;

    public sealed record GonderimIstegi(int DisLabId, int[]? IstemSatirIdler,
                                        string? KuryeFirma, string? KuryeAd,
                                        string? KuryeTel, short? TasimaKosulu,
                                        decimal? Sicaklik, short? KapSayisi,
                                        string? Aciklama);

    public sealed record TeslimIstegi(string? TeslimAlan, string? DisKabulNo,
                                      DateTime? Zaman);

    public sealed record DisSonucIstegi(int IstemSatirId, string Deger, string? Birim,
                                        string? Yorum, DateTime? SonucZamani);

    // ============================================================= gönderim

    /// <summary>
    /// Seçilen istem satırlarını dış laboratuvara gönderir.
    ///
    /// <b>Yalnız KABUL EDİLMİŞ numunenin satırı gönderilir</b>: elde olmayan
    /// tüpü sevk etmek, kayıp numunenin izini baştan silmek olurdu.
    /// </summary>
    public async Task<(int Id, string No, int Satir)> GonderAsync(GonderimIstegi istek,
        IstekBaglami baglam, CancellationToken iptal)
    {
        if (istek.IstemSatirIdler is not { Length: > 0 })
            throw GentegreHatasi.Dogrulama("Gönderilecek tetkik seçilmeli.",
                [new("istemSatirIdler", "En az bir istem satırı seçin.")]);

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var disLab = await baglanti.TekAsync("""
            select d.id, d.ad, d.kurye_firma, d.sube_id
              from public.lab_dis_lab d where d.id = @p0 and d.durum = 0
            """, islem, [istek.DisLabId],
            o => new { Id = o.GetInt32(0), Ad = o.GetString(1),
                       Kurye = o.GetString(2), SubeId = o.GetInt32(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Dış laboratuvar bulunamadı ya da pasif.");

        var satirlar = await baglanti.ListeAsync("""
            select s.id, s.tetkik_id, s.numune_id, t.kod, t.ad,
                   coalesce(n.durum, 0) as numune_durum, s.durum,
                   coalesce(dt.dis_kod, '') as dis_kod, dt.birim_fiyat,
                   (select count(*) from public.lab_dis_gonderim_satir x
                     where x.istem_satir_id = s.id and x.durum <> 3) as gonderilmis
              from public.lab_istem_satir s
              join public.lab_tetkik t on t.id = s.tetkik_id
              left join public.lab_numune n on n.id = s.numune_id
              left join public.lab_dis_test dt
                     on dt.dis_lab_id = @p1 and dt.tetkik_id = s.tetkik_id
                    and dt.durum = 0
             where s.id = any(@p0) and s.durum <> 0
            """, islem, [istek.IstemSatirIdler, istek.DisLabId],
            o => new { Id = o.GetInt32(0), TetkikId = o.GetInt32(1),
                       NumuneId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                       Kod = o.GetString(3), Ad = o.GetString(4),
                       NumuneDurum = o.GetInt16(5), Durum = o.GetInt16(6),
                       DisKod = o.GetString(7),
                       Fiyat = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                       Gonderilmis = o.GetInt64(9) }, iptal);

        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali("Seçilen satırlar bulunamadı.");

        var kabulsuz = satirlar.Where(x => x.NumuneDurum != 3).ToList();
        if (kabulsuz.Count > 0)
            throw GentegreHatasi.IsKurali(
                "Kabul edilmemiş numune gönderilemez: "
                + string.Join(", ", kabulsuz.Select(x => x.Kod)));

        var tekrar = satirlar.Where(x => x.Gonderilmis > 0).ToList();
        if (tekrar.Count > 0)
            throw GentegreHatasi.IsKurali(
                "Bu tetkikler zaten dış laboratuvara gönderilmiş: "
                + string.Join(", ", tekrar.Select(x => x.Kod)));

        var no = await baglanti.TekDegerAsync<string>(
            "select public.fn_lab_dis_gonderim_no()", islem, [], iptal) ?? "";

        var id = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_dis_gonderim
                   (gonderim_no, dis_lab_id, gonderim_zamani, gonderen_id,
                    kurye_firma, kurye_ad, kurye_tel, tasima_kosulu, sicaklik,
                    kap_sayisi, durum, aciklama, sube_id, ekleyen)
            values (@p0, @p1, now(), @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9,
                    @p10, @p11, @p2)
            returning id
            """, islem,
            [no, istek.DisLabId, baglam.KullaniciId,
             string.IsNullOrWhiteSpace(istek.KuryeFirma) ? disLab.Kurye
                                                         : istek.KuryeFirma,
             istek.KuryeAd ?? "", istek.KuryeTel ?? "", istek.TasimaKosulu ?? 2,
             istek.Sicaklik, istek.KapSayisi ?? 1, Hazirlaniyor,
             istek.Aciklama ?? "", baglam.SubeId ?? disLab.SubeId], iptal);

        foreach (var s in satirlar)
        {
            await baglanti.CalistirAsync("""
                insert into public.lab_dis_gonderim_satir
                       (gonderim_id, istem_satir_id, numune_id, tetkik_id, dis_kod,
                        birim_fiyat, durum, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6)
                """, islem,
                [id, s.Id, s.NumuneId, s.TetkikId,
                 string.IsNullOrWhiteSpace(s.DisKod) ? s.Kod : s.DisKod, s.Fiyat,
                 baglam.KullaniciId], iptal);

            // Satır durumu 7 = dış lab: çalışma listesinde "bekliyor" olarak
            //   kalmamalı, teknisyen o tüpü kendi cihazında aramamalı.
            await baglanti.CalistirAsync("""
                update public.lab_istem_satir
                   set durum = 7, dis_gonderim_id = @p1, degistiren = @p2,
                       degistirme_tarihi = now()
                 where id = @p0
                """, islem, [s.Id, id, baglam.KullaniciId], iptal);

            if (s.NumuneId is { } nid)
                await baglanti.CalistirAsync("""
                    insert into public.lab_numune_hareket
                           (numune_id, olay, kullanici_id, aciklama)
                    values (@p0, 7, @p1, @p2)
                    """, islem,
                    [nid, baglam.KullaniciId,
                     $"Dış laboratuvara gönderildi: {disLab.Ad} ({no})"], iptal);
        }

        await islem.CommitAsync(iptal);
        return (id, no, satirlar.Count);
    }

    /// <summary>Kurye yola çıktı.</summary>
    public async Task<string> YoldaAsync(int gonderimId, IstekBaglami baglam,
                                         CancellationToken iptal)
    {
        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_dis_gonderim
               set durum = @p1, degistiren = @p2, degistirme_tarihi = now()
             where id = @p0 and durum = @p3
            """, [gonderimId, Yolda, baglam.KullaniciId, Hazirlaniyor], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali(
                "Yalnız 'hazırlanıyor' durumundaki gönderim yola çıkarılabilir.");
        return "Gönderim yolda olarak işaretlendi.";
    }

    /// <summary>
    /// Karşı taraf teslim aldı. <b>Dış kabul numarası önemlidir</b>: sonuç
    /// geldiğinde ve itirazda iki laboratuvarın ortak tek referansı odur.
    /// </summary>
    public async Task<string> TeslimAsync(int gonderimId, TeslimIstegi istek,
                                          IstekBaglami baglam, CancellationToken iptal)
    {
        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_dis_gonderim
               set durum = @p1, teslim_zamani = coalesce(@p2, now()),
                   teslim_alan = @p3, dis_kabul_no = @p4,
                   degistiren = @p5, degistirme_tarihi = now()
             where id = @p0 and durum in (1, 2)
            """, [gonderimId, Teslim, istek.Zaman, istek.TeslimAlan ?? "",
                  istek.DisKabulNo ?? "", baglam.KullaniciId], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali("Bu gönderim zaten teslim edilmiş ya da kapalı.");

        return string.IsNullOrWhiteSpace(istek.DisKabulNo)
            ? "Teslim kaydedildi. Dış laboratuvarın kabul numarasını da girin - "
              + "sonuç eşleştirmesinde ortak referans odur."
            : "Teslim kaydedildi.";
    }

    // ================================================================ sonuç

    /// <summary>
    /// Dış laboratuvardan gelen sonucu yazar (PDF/HL7/portal fark etmez;
    /// değer buraya girilir).
    ///
    /// <b>Oto-onay kapalı</b>: başka bir laboratuvarın yöntemini ve kalite
    /// kontrolünü biz doğrulamadık - sonuç uzman görmeden yayınlanmaz.
    /// </summary>
    public async Task<string> SonucAsync(int gonderimId, DisSonucIstegi istek,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var satir = await _veri.TekAsync("""
            select gs.id, gs.durum, g.dis_lab_id, d.ad
              from public.lab_dis_gonderim_satir gs
              join public.lab_dis_gonderim g on g.id = gs.gonderim_id
              join public.lab_dis_lab d on d.id = g.dis_lab_id
             where gs.gonderim_id = @p0 and gs.istem_satir_id = @p1
            """, [gonderimId, istek.IstemSatirId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1),
                       DisLabId = o.GetInt32(2), DisLabAd = o.GetString(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi(
                "Bu tetkik bu gönderimde yok - yanlış gönderim numarası olabilir.");

        if (satir.Durum == 2)
            throw GentegreHatasi.IsKurali("Bu tetkiğin sonucu zaten girilmiş.");

        // Sonuç normal hattan yazılır: referans, bayrak, panik ve delta
        //   kuralları dış lab sonucunda da işler - hasta için fark yok.
        var sonuc = await _lab.SonucYazAsync(
            new LabServisi.SonucIstegi(istek.IstemSatirId, istek.Deger, istek.Birim,
                                       istek.Yorum ?? $"Dış laboratuvar: {satir.DisLabAd}",
                                       null),
            null, null, baglam, iptal, otoOnaySerbest: false);

        await _veri.CalistirAsync(
            "update public.lab_sonuc set dis_lab_id = @p1 where id = @p0",
            [sonuc.SonucId, satir.DisLabId], iptal);

        await _veri.CalistirAsync("""
            update public.lab_dis_gonderim_satir
               set durum = 2, sonuc_zamani = coalesce(@p1, now()),
                   degistiren = @p2, degistirme_tarihi = now()
             where id = @p0
            """, [satir.Id, istek.SonucZamani, baglam.KullaniciId], iptal);

        await DurumTazeleAsync(gonderimId, baglam, iptal);

        return $"{satir.DisLabAd} sonucu kaydedildi ({sonuc.Bayrak}) - uzman onayı bekliyor."
             + (sonuc.Panik ? " PANİK DEĞER: hekime bildirilmeli." : "");
    }

    /// <summary>
    /// Dış laboratuvar numuneyi reddetti ya da numune kayboldu.
    /// Tetkik "tekrar numune bekliyor"a döner - açık bırakmak, sonucu hiç
    /// gelmeyecek bir istem üretirdi.
    /// </summary>
    public async Task<string> RetAsync(int gonderimId, int istemSatirId, short durum,
        string neden, IstekBaglami baglam, CancellationToken iptal)
    {
        if (durum is not (3 or 4))
            throw GentegreHatasi.IsKurali("Geçersiz durum (3 ret · 4 kayıp).");
        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("Neden zorunlu.",
                [new("neden", "Dış laboratuvarın gerekçesini yazın.")]);

        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_dis_gonderim_satir
               set durum = @p2, ret_neden = @p3, degistiren = @p4,
                   degistirme_tarihi = now()
             where gonderim_id = @p0 and istem_satir_id = @p1 and durum = 1
            """, [gonderimId, istemSatirId, durum, neden, baglam.KullaniciId], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali("Satır bulunamadı ya da sonucu girilmiş.");

        await _veri.CalistirAsync("""
            update public.lab_istem_satir
               set durum = 6, dis_gonderim_id = null, degistiren = @p1,
                   degistirme_tarihi = now()
             where id = @p0
            """, [istemSatirId, baglam.KullaniciId], iptal);

        await DurumTazeleAsync(gonderimId, baglam, iptal);
        return durum == 3
            ? "Dış laboratuvar reddetti - tetkik tekrar numune bekliyor."
            : "Numune kayıp olarak işaretlendi - tetkik tekrar numune bekliyor.";
    }

    /// <summary>
    /// Alış faturası eşleştirmesi: dış lab hizmeti satın alınan bir
    /// hizmettir; fatura ile gönderim eşleşmezse "kime ne ödedik" cevapsız
    /// kalır.
    /// </summary>
    public async Task<string> FaturaAsync(int gonderimId, int belgeId, decimal? tutar,
                                          IstekBaglami baglam, CancellationToken iptal)
    {
        var belge = await _veri.TekAsync("""
            select b.id, b.tur, coalesce(b.belge_no, ''), b.taraf_id
              from public.belge b where b.id = @p0
            """, [belgeId],
            o => new { Id = o.GetInt32(0), Tur = o.GetInt16(1), No = o.GetString(2),
                       TarafId = o.GetInt32(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

        // ALIŞ FATURASI (10) beklenir: satış faturasıyla eşleştirmek, gideri
        //   gelir gibi göstermek olurdu.
        if (belge.Tur != 10)
            throw GentegreHatasi.IsKurali(
                "Yalnız alış faturası eşleştirilebilir (belge türü 10).");

        var karsiTaraf = await _veri.TekDegerAsync<int>("""
            select d.taraf_id from public.lab_dis_gonderim g
              join public.lab_dis_lab d on d.id = g.dis_lab_id
             where g.id = @p0
            """, [gonderimId], iptal);

        if (karsiTaraf != belge.TarafId)
            throw GentegreHatasi.IsKurali(
                "Fatura başka bir cariye ait - gönderimin dış laboratuvarıyla "
                + "aynı olmalı.");

        await _veri.CalistirAsync("""
            update public.lab_dis_gonderim
               set fatura_belge_id = @p1, tutar = coalesce(@p2, tutar),
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, [gonderimId, belgeId, tutar, baglam.KullaniciId], iptal);

        return $"{belge.No} numaralı alış faturası gönderime eşleştirildi.";
    }

    /// <summary>
    /// Gönderim durumu SATIRLARDAN türetilir: hepsi sonuçlandıysa kapanır,
    /// bir kısmı geldiyse "kısmi". İki yerde tutmak, listede "sonuçlandı"
    /// görünen gönderimde bekleyen tetkik olması demekti.
    /// </summary>
    private async Task DurumTazeleAsync(int gonderimId, IstekBaglami baglam,
                                        CancellationToken iptal)
        => await _veri.CalistirAsync("""
            update public.lab_dis_gonderim g
               set durum = case
                     when k.acik = 0 and k.sonuclu > 0 then @p1
                     when k.sonuclu > 0 then @p2
                     else g.durum end,
                   degistiren = @p3, degistirme_tarihi = now()
              from (select count(*) filter (where durum = 1) as acik,
                           count(*) filter (where durum = 2) as sonuclu
                      from public.lab_dis_gonderim_satir where gonderim_id = @p0) k
             where g.id = @p0
            """, [gonderimId, Sonuclandi, Kismi, baglam.KullaniciId], iptal);
}
