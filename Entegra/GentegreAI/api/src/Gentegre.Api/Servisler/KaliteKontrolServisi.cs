using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// LABORATUVAR KALİTE KONTROL (442) — İKK ölçümleri, Westgard, DKK.
///
/// <para><b>Kural motoru ölçüm YAZILIRKEN çalışır</b> ve sonucu satırla
/// birlikte saklanır (z skoru, ihlal listesi, durum). Kural seti sonradan
/// değişse geçmiş değerlendirme aynı kalır - hasta sonucundaki bayrakla
/// tamamen aynı gerekçe.</para>
///
/// <para><b>Ret düzeltici faaliyet ister.</b> ISO 15189: ne yapıldığı
/// yazılmayan ret denetimde savunulamaz; ayrıca etkilenen hasta sonuçlarının
/// gözden geçirildiği kayda geçer.</para>
///
/// <para><b>Asıl bağ oto-onaydadır</b>: KK ret durumundayken o testin hasta
/// sonuçları otomatik onaylanmaz (<c>fn_lab_kk_gecerli</c>). Kalite
/// kontrolünü ayrı bir kayıt defteri olarak tutmak, kuralı süse
/// çevirirdi.</para>
/// </summary>
public sealed class KaliteKontrolServisi(VeriKaynagi veri)
{
    private readonly VeriKaynagi _veri = veri;

    public sealed record OlcumIstegi(int LotId, int TetkikId, short Seviye,
                                     decimal Deger, int? CihazId, DateTime? Zaman,
                                     short? Kaynak, bool? Tekrar);

    public sealed record OlcumSonucu(long Id, decimal? Z, short Durum, string[] Ihlaller,
                                     string Mesaj);

    public sealed record AksiyonIstegi(string Aksiyon, int? GozdenGecirilen,
                                       int? Duzeltilen, short? Olay);

    public sealed record DkkIstegi(string Program, string Donem, int TetkikId,
                                   string? NumuneKodu, decimal Sonucumuz, decimal Hedef,
                                   decimal? GrupSd, int? GrupN, string? Yontem,
                                   DateOnly? RaporTarihi);

    // =============================================================== ölçüm

    /// <summary>
    /// KK ölçümü kaydeder, z skorunu hesaplar, Westgard kurallarını uygular
    /// ve kümülatif istatistiği tazeler.
    ///
    /// <b>Hedef/SD yürürlükteki kaynaktan</b> gelir: laboratuvar kümülatifi
    /// eşiği geçtiyse o, geçmediyse üretici değeri (fn_lab_kk_hedef).
    /// </summary>
    public async Task<OlcumSonucu> OlcumAsync(OlcumIstegi istek, IstekBaglami baglam,
                                              CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var hedef = await baglanti.TekAsync("""
            select h.id, k.hedef, k.sd, k.kaynak, h.birim
              from public.lab_kk_hedef h
              cross join lateral public.fn_lab_kk_hedef(h.id) k
             where h.lot_id = @p0 and h.tetkik_id = @p1 and h.seviye = @p2
               and h.durum = 0
            """, islem, [istek.LotId, istek.TetkikId, istek.Seviye],
            o => new { Id = o.GetInt32(0),
                       Hedef = o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                       Sd = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                       Kaynak = o.GetString(3), Birim = o.GetString(4) }, iptal)
            ?? throw GentegreHatasi.IsKurali(
                "Bu lot/tetkik/seviye için hedef tanımlı değil - önce kontrol "
                + "lotunun hedef değerlerini girin.");

        if (hedef.Hedef is null || hedef.Sd is null or 0)
            throw GentegreHatasi.IsKurali(
                "Hedef ya da SD tanımsız; z skoru hesaplanamaz "
                + "(üretici değerlerini girin ya da kümülatif biriktirin).");

        var z = Math.Round((istek.Deger - hedef.Hedef.Value) / hedef.Sd.Value, 3);

        var id = await baglanti.TekDegerAsync<long>("""
            insert into public.lab_kk_olcum
                   (hedef_id, lot_id, tetkik_id, seviye, cihaz_id, olcum_zamani,
                    deger, z, hedef, sd, kaynak, tekrar, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, coalesce(@p5, now()), @p6, @p7, @p8, @p9,
                    @p10, @p11, @p12, @p13)
            returning id
            """, islem,
            [hedef.Id, istek.LotId, istek.TetkikId, istek.Seviye, istek.CihazId,
             istek.Zaman, istek.Deger, z, hedef.Hedef, hedef.Sd, istek.Kaynak ?? 2,
             (short)((istek.Tekrar ?? false) ? 1 : 0), baglam.SubeId ?? 0,
             baglam.KullaniciId], iptal);

        var sonuc = await baglanti.TekAsync(
            "select durum, ihlaller from public.fn_lab_westgard(@p0)", islem, [id],
            o => new { Durum = o.GetInt16(0), Ihlaller = o.GetFieldValue<string[]>(1) },
            iptal)!;

        // KÜMÜLATİF: ret edilen ölçüm hariç tutulur - ret bir ölçüm hatasıdır,
        //   laboratuvarın hedefini kaydırmamalı.
        await baglanti.CalistirAsync("select public.fn_lab_kk_kumulatif(@p0)",
                                     islem, [hedef.Id], iptal);

        await islem.CommitAsync(iptal);

        var ihlal = sonuc!.Ihlaller.Length > 0
            ? " · ihlal: " + string.Join(", ", sonuc.Ihlaller) : "";
        var mesaj = sonuc.Durum switch
        {
            3 => $"RET (z = {z:+0.00;-0.00}){ihlal}. Düzeltici faaliyet kaydedilmeli; "
                 + "bu test için oto-onay durdu.",
            2 => $"UYARI (z = {z:+0.00;-0.00}){ihlal}. İzlenmeli.",
            _ => $"Kabul (z = {z:+0.00;-0.00}) · hedef kaynağı: {hedef.Kaynak}.",
        };

        return new OlcumSonucu(id, z, sonuc.Durum, sonuc.Ihlaller, mesaj);
    }

    /// <summary>
    /// Ret/uyarı sonrası düzeltici faaliyet ve etkilenen hasta sonuçlarının
    /// gözden geçirilmesi. Metin ZORUNLU.
    /// </summary>
    public async Task<string> AksiyonAsync(long olcumId, AksiyonIstegi istek,
                                           IstekBaglami baglam, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(istek.Aksiyon))
            throw GentegreHatasi.Dogrulama("Düzeltici faaliyet zorunlu.",
                [new("aksiyon", "Ne yapıldığını yazın (kalibrasyon, reaktif değişimi…).")]);

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var o = await baglanti.TekAsync("""
            select cihaz_id, tetkik_id, durum from public.lab_kk_olcum where id = @p0
            """, islem, [olcumId],
            o2 => new { CihazId = o2.IsDBNull(0) ? (int?)null : o2.GetInt32(0),
                        TetkikId = o2.GetInt32(1), Durum = o2.GetInt16(2) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("KK ölçümü bulunamadı.");

        await baglanti.CalistirAsync("""
            update public.lab_kk_olcum
               set aksiyon = @p1, gozden_gecirilen = coalesce(@p2, gozden_gecirilen),
                   duzeltilen = coalesce(@p3, duzeltilen),
                   onay_id = @p4, onay_zamani = now(),
                   degistiren = @p4, degistirme_tarihi = now()
             where id = @p0
            """, islem, [olcumId, istek.Aksiyon, istek.GozdenGecirilen,
                         istek.Duzeltilen, baglam.KullaniciId], iptal);

        // CİHAZ OLAYI: Levey-Jennings'teki kaymanın nedeni burada yazar.
        //   Ayrı tutulmazsa "kayma" ile "reaktif lot değişimi" arasındaki bağ
        //   sonradan kurulamaz.
        if (istek.Olay is > 0)
            await baglanti.CalistirAsync("""
                insert into public.lab_cihaz_olay
                       (cihaz_id, tetkik_id, olay, aciklama, kullanici_id, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p4)
                """, islem,
                [o.CihazId, o.TetkikId, istek.Olay, istek.Aksiyon, baglam.KullaniciId,
                 baglam.SubeId ?? 0], iptal);

        await islem.CommitAsync(iptal);

        return o.Durum == 3
            ? "Düzeltici faaliyet kaydedildi. Oto-onayın açılması için GEÇERLİ bir "
              + "tekrar ölçümü girilmeli."
            : "Kayıt güncellendi.";
    }

    // ================================================================== DKK

    /// <summary>
    /// Dış kalite sonucu. SDI = (bizim − hedef) / grup SD; |SDI| ≤ 2 kabul,
    /// 2–3 uyarı, &gt; 3 kabul edilemez.
    /// </summary>
    public async Task<(int Id, decimal? Sdi, short Degerlendirme, string Mesaj)>
        DkkAsync(DkkIstegi istek, IstekBaglami baglam, CancellationToken iptal)
    {
        decimal? sdi = istek.GrupSd is > 0
            ? Math.Round((istek.Sonucumuz - istek.Hedef) / istek.GrupSd.Value, 3)
            : null;

        var degerlendirme = (short)(sdi is null ? 1
            : Math.Abs(sdi.Value) > 3 ? 3
            : Math.Abs(sdi.Value) > 2 ? 2 : 1);

        var id = await _veri.TekDegerAsync<int>("""
            insert into public.lab_dkk_sonuc
                   (program, donem, tetkik_id, numune_kodu, sonucumuz, hedef, grup_sd,
                    grup_n, yontem, sdi, degerlendirme, rapor_tarihi, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11,
                    @p12, @p13)
            returning id
            """,
            [istek.Program, istek.Donem, istek.TetkikId, istek.NumuneKodu ?? "",
             istek.Sonucumuz, istek.Hedef, istek.GrupSd, istek.GrupN,
             istek.Yontem ?? "", sdi, degerlendirme, istek.RaporTarihi,
             baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

        var mesaj = degerlendirme switch
        {
            3 => $"KABUL EDİLEMEZ (SDI {sdi:+0.00;-0.00}) - kök neden analizi ve "
                 + "düzeltici faaliyet gerekir.",
            2 => $"UYARI (SDI {sdi:+0.00;-0.00}) - eğilim izlenmeli.",
            _ => sdi is null ? "Kaydedildi (grup SD verilmediği için SDI hesaplanmadı)."
                             : $"Kabul (SDI {sdi:+0.00;-0.00}).",
        };
        return (id, sdi, degerlendirme, mesaj);
    }

    /// <summary>
    /// Cihazdan gelen kontrol mesajını KK ölçümüne çevirir.
    ///
    /// Cihaz kontrolü hasta örneğiyle aynı hattan gönderir; ayırt eden şey
    /// örnek numarasının kontrol lotu kodu olmasıdır. Eşleşme yoksa mesaj
    /// hasta sonucu olarak işlenmeye devam eder.
    /// </summary>
    public async Task<int> CihazMesajindanAsync(long mesajId, IstekBaglami baglam,
                                                CancellationToken iptal)
    {
        var m = await _veri.TekAsync("""
            select m.id, m.cihaz_id, m.ornek_no, m.durum
              from public.cihaz_mesaj m where m.id = @p0
            """, [mesajId],
            o => new { Id = o.GetInt64(0), CihazId = o.GetInt32(1),
                       OrnekNo = o.GetString(2), Durum = o.GetInt16(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Cihaz mesajı bulunamadı.");

        // Örnek numarası kontrol lotunun kodu mu? (KK barkodları lot koduyla
        //   basılır; "KK-…" gibi bir ön ek zorunlu değil.)
        var lot = await _veri.TekAsync("""
            select id, seviye_sayisi from public.lab_kk_lot
             where upper(kod) = upper(@p0) and durum = 0
            """, [m.OrnekNo],
            o => new { Id = o.GetInt32(0), Seviye = o.GetInt16(1) }, iptal);

        if (lot is null)
            throw GentegreHatasi.IsKurali(
                $"'{m.OrnekNo}' bir kontrol lotu kodu değil - bu mesaj hasta "
                + "sonucu olarak işlenmeli.");

        var kalemler = await _veri.ListeAsync("""
            select k.test_kodu, k.sayisal
              from public.cihaz_mesaj_kalem k
             where k.mesaj_id = @p0 and k.sayisal is not null
             order by k.sira, k.id
            """, [mesajId],
            o => new { Kod = o.GetString(0), Deger = o.GetDecimal(1) }, iptal);

        var yazilan = 0;
        foreach (var k in kalemler)
        {
            var tetkikId = await _veri.TekDegerAsync<int?>("""
                select tetkik_id from public.fn_lab_cihaz_tetkik(@p0, @p1, '')
                """, [m.CihazId, k.Kod], iptal);
            if (tetkikId is null or 0) continue;

            // SEVİYE: cihaz ayrı ayrı gönderir; tek mesajda tek seviye
            //   varsayılır (çoklu seviye ayrı kontrol barkodudur).
            await OlcumAsync(new OlcumIstegi(lot.Id, tetkikId.Value, 1, k.Deger,
                                             m.CihazId, null, 1, false), baglam, iptal);
            yazilan++;
        }

        await _veri.CalistirAsync("""
            update public.cihaz_mesaj set durum = 3, islenme = now(),
                   hata = case when @p1 = 0 then 'KK: eşleşen tetkik yok' else hata end
             where id = @p0
            """, [mesajId, yazilan], iptal);

        return yazilan;
    }
}
