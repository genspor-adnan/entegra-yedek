using Gentegre.Cekirdek.Cihaz;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GELEN RAPOR SERVİSİ (817) — dışarıdan gelen ORU'yu isteğe oturtur.
///
/// <para><b>Sıra bilinçli: önce KAYIT, sonra işleme</b> (432 cihaz dersinin
/// aynısı). Karşı sistem raporu bir kez gönderir; çözümleme ya da eşleştirme
/// çökerse ham metin durmalı ki düzeltilince yeniden işlensin. Tersi sırada
/// bir ayrıştırma hatası raporu yok ederdi.</para>
///
/// <para><b>ACK politikası:</b>
/// <list type="bullet">
/// <item>İşlendi / mükerrer → <c>AA</c>.</item>
/// <item>Eşleşmedi, çözümlenemedi → <c>AE</c>: mesaj ulaştı ama kabul
/// edilmedi. Tekrar göndermek bir şey değiştirmez, insan bakmalı - kayıt
/// bizde duruyor ve "Gelen Raporlar" ekranında kırmızı.</item>
/// <item>Bizim tarafta beklenmedik hata → <c>AR</c>: karşı taraf tekrar
/// denesin, sorun geçici olabilir.</item>
/// </list></para>
///
/// <para><b>Onaylı raporun üstüne yazılmaz.</b> Aynı işe ikinci kez rapor
/// gelirse (düzeltme) yeni rapor EK RAPOR olarak açılır; ilk rapor kilitli
/// kalır - iç akıştaki addendum kuralının aynısı (283).</para>
/// </summary>
public sealed class TeleradGelenServisi(VeriKaynagi veri, ILogger<TeleradGelenServisi> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly ILogger<TeleradGelenServisi> _gunluk = gunluk;

    public sealed record AlimSonucu(long GelenId, string AckKodu, string Mesaj, short Durum);

    /// <summary>Ham mesajı alır, kaydeder, işler ve ACK kodunu döner.</summary>
    public async Task<AlimSonucu> AlAsync(string ham, string kaynakIp, CancellationToken iptal)
    {
        var coz = OruCozumleyici.Coz(ham);

        await using var b = await _veri.AcAsync(iptal);

        // MÜKERRER: aynı kontrol numarası ikinci kez gelirse rapor yeniden
        //   yazılmaz. Karşı sistem ACK'i alamadığını sanıp tekrar gönderiyor.
        if (coz.KontrolNo.Length > 0)
        {
            var mevcut = await b.TekAsync("""
                select id, durum from public.telerad_gelen where kontrol_no = @p0
                """, null, [coz.KontrolNo], OkuyucuGenisletmeleri.Sozluk, iptal);
            if (mevcut is not null)
                return new AlimSonucu(Convert.ToInt64(mevcut["id"]), "AA",
                                      "Bu rapor daha önce alınmıştı.", 3);
        }

        var istekId = coz.Gecerli
            ? await b.TekDegerAsync<int?>(
                "select public.fn_telerad_gelen_istek(@p0, @p1, @p2)", null,
                [coz.AccessionNo, coz.GonderenSkrs, coz.HastaTckn], iptal)
            : null;

        // KAYNAK: gönderen SKRS kodu bizdeki bir kuruma denk geliyorsa "kurum",
        //   gelmiyorsa ve mesaj TELETIP'ten geliyorsa "Bakanlık".
        short kaynakTur = 0;
        if (istekId is not null) kaynakTur = 2;
        if (coz.GonderenUygulama.Contains("TELETIP", StringComparison.OrdinalIgnoreCase)
            || coz.GonderenTesis.Contains("TELETIP", StringComparison.OrdinalIgnoreCase))
            kaynakTur = 1;

        var durum = !coz.Gecerli ? (short)0
                  : istekId is null ? (short)1
                  : !coz.GovdeVar ? (short)4
                  : (short)2;
        var hata = !coz.Gecerli ? coz.Hata
                 : istekId is null
                     ? $"Erişim (accession) numarası '{coz.AccessionNo}' ile eşleşen istek yok."
                 : !coz.GovdeVar ? "Mesajda rapor gövdesi yok (OBX boş)."
                 : "";

        var gelenId = await b.TekDegerAsync<long>("""
            insert into public.telerad_gelen
                   (kontrol_no, kaynak_ip, kaynak_tur, gonderen_skrs, accession_no,
                    hasta_tckn, radyolog_tckn, radyolog_ad, onay_zamani, durum,
                    istek_id, hata_metni, ham, sube_id)
            select @p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10,
                   left(@p11, 400), @p12,
                   (select i.sube_id from public.telerad_istek i where i.id = @p10)
            returning id
            """, null,
            [coz.KontrolNo, kaynakIp, kaynakTur, coz.GonderenSkrs, coz.AccessionNo,
             coz.HastaTckn, coz.RadyologTckn, coz.RadyologAdi, coz.OnayZamani,
             durum, istekId, hata, ham], iptal);

        if (durum != 2)
            return new AlimSonucu(gelenId, durum == 0 ? "AE" : "AE", hata, durum);

        try
        {
            await RaporYazAsync(b, gelenId, istekId!.Value, coz, iptal);
            return new AlimSonucu(gelenId, "AA", "Rapor kaydedildi.", 2);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Gelen rapor {Id} işlenemedi.", gelenId);
            await b.CalistirAsync("""
                update public.telerad_gelen
                   set durum = 4, hata_metni = left(@p1, 400), ack_kodu = 'AR'
                 where id = @p0
                """, null, [gelenId, h.Message], iptal);
            // AR: sorun BİZDE - karşı taraf tekrar denesin.
            return new AlimSonucu(gelenId, "AR", h.Message, 4);
        }
    }

    /// <summary>Eşleşmeyen kaydı elle isteğe bağlar ve yeniden işler.</summary>
    public async Task<AlimSonucu> ElleBaglaAsync(long gelenId, int istekId,
                                                 CancellationToken iptal)
    {
        await using var b = await _veri.AcAsync(iptal);

        var g = await b.TekAsync("""
            select id, ham, durum from public.telerad_gelen where id = @p0
            """, null, [gelenId], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Gelen rapor bulunamadı.");

        if (Convert.ToInt16(g["durum"]) == 2)
            throw GentegreHatasi.IsKurali("Bu rapor zaten işlendi.");

        var coz = OruCozumleyici.Coz((string)(g["ham"] ?? ""));
        if (!coz.Gecerli || !coz.GovdeVar)
            throw GentegreHatasi.IsKurali("Mesaj çözümlenemedi ya da rapor gövdesi yok.");

        await b.CalistirAsync(
            "update public.telerad_gelen set istek_id = @p1 where id = @p0",
            null, [gelenId, istekId], iptal);

        await RaporYazAsync(b, gelenId, istekId, coz, iptal);
        return new AlimSonucu(gelenId, "AA", "Rapor kaydedildi.", 2);
    }

    // ------------------------------------------------------------- yazım ----
    private async Task RaporYazAsync(NpgsqlConnection b, long gelenId, int istekId,
                                     GelenOru coz, CancellationToken iptal)
    {
        await using var islem = await b.BeginTransactionAsync(iptal);

        var istek = await b.TekAsync("""
            -- KOLON ADLARI API ADIYLA: sözlük anahtarı SQL'deki addır; takma
            --   ad verilmezse `tetkik_hizmet_id` olur ve okuma patlar.
            select i.id, i.sube_id as "subeId", i.hasta_id as "hastaId",
                   i.tetkik_hizmet_id as "tetkikHizmetId", i.modalite,
                   i.dis_erisim_no as "disErisimNo",
                   i.radyoloji_istem_id as "istemId", i.rapor_id as "raporId",
                   i.klinik_bilgi as "klinikBilgi"
              from public.telerad_istek i where i.id = @p0
            """, islem, [istekId], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Teleradyoloji isteği bulunamadı.");

        // İÇ İSTEM YOKSA AÇILIR: rapor `radyoloji_rapor`a yazılıyor ve o tablo
        //   bir isteme bağlı. Ayrı bir "dış rapor" tablosu açmak, raporu
        //   mevcut ekranların hiçbirinde göstermemek olurdu (797 kararı:
        //   telerad_istek bir SARMAL, iç istemin yerine geçmez).
        var istemId = istek["istemId"] as int?;
        if (istemId is null)
        {
            if (istek["tetkikHizmetId"] is null)
                throw new InvalidOperationException(
                    "İsteğin tetkik hizmeti boş - iç istem açılamadı.");
            istemId = await b.TekDegerAsync<int>("""
                insert into public.radyoloji_istem
                       (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum,
                        klinik_bilgi, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 5, @p5, 0)
                returning id
                """, islem,
                [istek["subeId"], istek["hastaId"], istek["tetkikHizmetId"], istek["modalite"],
                 istek["disErisimNo"], istek["klinikBilgi"] ?? ""], iptal);
            await b.CalistirAsync(
                "update public.telerad_istek set radyoloji_istem_id = @p1 where id = @p0",
                islem, [istekId, istemId], iptal);
        }

        // RADYOLOG TCKN'DEN BULUNUR, UYDURULMAZ: tanınmayan radyolog için
        //   onaylayan boş kalır ve adı rapor bölümünde yazar - yanlış kişiye
        //   rapor imzalatmaktansa boş bırakmak yeğdir.
        var radyologId = coz.RadyologTckn.Length == 0 ? null
            : await b.TekDegerAsync<int?>(
                "select id from public.taraf where vkno = @p0 and coalesce(personel, 0) = 1 "
                + "order by id limit 1", islem, [coz.RadyologTckn], iptal);

        // ÖNCEKİ RAPOR KİLİTLİYSE EK RAPOR: üstüne yazmak, imzalanmış metni
        //   değiştirmek olurdu (283 addendum kuralı).
        var oncekiId = istek["raporId"] as int?;
        var onceki = oncekiId is null ? null : await b.TekAsync(
            "select id, coalesce(kilit, 0) as kilit from public.radyoloji_rapor where id = @p0",
            islem, [oncekiId.Value], OkuyucuGenisletmeleri.Sozluk, iptal);
        var ustRaporId = onceki is not null && Convert.ToInt16(onceki["kilit"]) == 1
                       ? oncekiId : null;

        var raporId = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_rapor
                   (istem_id, durum, kilit, yazan_id, yazma_tarihi,
                    onaylayan_id, onay_tarihi, ust_rapor_id,
                    istem_nedeni_puan, cekim_kalite_puan, ekleyen)
            values (@p0, 3, 1, @p1, @p2, @p1, @p2, @p3, @p4, @p5, 0)
            returning id
            """, islem,
            [istemId, radyologId, coz.OnayZamani ?? DateTime.Now, ustRaporId,
             coz.IstemNedeniPuan, coz.CekimKalitePuan], iptal);

        await b.CalistirAsync("""
            update public.radyoloji_rapor
               set rapor_no = case when rapor_no = ''
                                   then public.fn_radyoloji_rapor_no(@p1::date)
                                   else rapor_no end
             where id = @p0
            """, islem, [raporId, (coz.OnayZamani ?? DateTime.Now).Date], iptal);

        // BÖLÜMLER PARÇA NUMARASIYLA (809): geldiği gibi yazılır, başlık
        //   uydurulmaz. Parçalanamamış düz metin tek "Rapor" bölümüdür.
        var bolumler = new List<(short Sira, string Baslik, string Metin, short Parca)>();
        void Ekle(short sira, string baslik, string metin, short parca)
        {
            if (!string.IsNullOrWhiteSpace(metin))
                bolumler.Add((sira, baslik, metin.Trim(), parca));
        }
        Ekle(1, "Teknik", coz.RaporTeknik, 1);
        Ekle(2, "Karşılaştırma", coz.RaporKarsilastirma, 2);
        Ekle(3, "Bulgular", coz.RaporBulgular, 3);
        Ekle(4, "Sonuç ve Öneriler", coz.RaporSonuc, 4);
        Ekle(5, "Rapor", coz.RaporDuzMetin, 0);
        if (coz.RadyologTckn.Length > 0 && radyologId is null)
            Ekle(6, "Raporlayan", $"{coz.RadyologAdi} (TCKN {coz.RadyologTckn})", 0);

        foreach (var (sira, baslik, metin, parca) in bolumler)
            await b.CalistirAsync("""
                insert into public.radyoloji_rapor_bolum
                       (rapor_id, sira, baslik, metin, yazdir, bakanlik_parca)
                values (@p0, @p1, @p2, @p3, 1, @p4)
                """, islem, [raporId, sira, baslik, metin, parca], iptal);

        await b.CalistirAsync(
            "update public.radyoloji_istem set durum = 5 where id = @p0 and durum < 5",
            islem, [istemId], iptal);

        // İSTEK "ONAYLANDI"YA GEÇER (durum 6), teslim edilmiş sayılmaz: rapor
        //   bize geldi, kurumun eline geçmesi ayrı adım (teslim kuyruğu 814).
        await b.CalistirAsync("""
            update public.telerad_istek
               set rapor_id = @p1,
                   durum = case when durum < 6 then 6 else durum end,
                   atanan_radyolog_id = coalesce(atanan_radyolog_id, @p2)
             where id = @p0
            """, islem, [istekId, raporId, radyologId], iptal);

        await b.CalistirAsync("""
            update public.telerad_gelen
               set durum = 2, rapor_id = @p1, hata_metni = '', ack_kodu = 'AA',
                   islenme_zamani = now()::timestamp
             where id = @p0
            """, islem, [gelenId, raporId], iptal);

        await islem.CommitAsync(iptal);
    }
}
