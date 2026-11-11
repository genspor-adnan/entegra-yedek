using System.Text.Json;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>Bir gönderim denemesinin sonucu (uç ve işçi aynı tipi görür).</summary>
public sealed record TeletipDenemeSonucu(long GonderimId, short Durum, string AckKodu, string Hata);

/// <summary>
/// TELETIP ORM GÖNDERİMİ (1302; kullanıcı 11.11.2026: "ORM'yi kuyruğa ve akışa bağla").
///
/// <para><b>Akış:</b> radyoloji_istem tetiği <c>teletip_gonderim</c>'e NW / XO / CA satırı açar → bu servis satırı alır,
/// veriyi <c>fn_teletip_orm_verisi</c>'nden (CA'da satırdaki anlık görüntüden) okur, <see cref="OrmUretici.Denetle"/> ile
/// Bakanlık'ın reddedeceği eksikleri arar, <see cref="OrmUretici.Uret"/> ile mesajı kurar ve <see cref="MllpIstemci"/> ile
/// Mirth K1'e (TELETIP_HL7) gönderir. Mirth Teletıp'ın ACK'ini aynen geri döndürür.</para>
///
/// <para><b>Durumlar:</b> 0 bekliyor · 1 gönderildi (AA) · 2 reddedildi (AE - otomatik tekrar YOK, aynı mesaj yine
/// reddedilir) · 3 gidemez (eksik; istem değişince tetik yeniden kuyruğa alır) · 4 atlandı · 5 ulaşmadı (AR / ACK yok,
/// artan aralıkla tekrar).</para>
///
/// <para><b>Sıra:</b> aynı istemin önceki satırı sonuçlanmadan (gönderilmeden) sonraki gitmez - XO / CA, NW'den önce
/// Bakanlık'a varırsa "istem yok" diye reddedilir.</para>
/// </summary>
public sealed class TeletipOrmServisi(VeriKaynagi veri, MllpIstemci mllp, ILogger<TeletipOrmServisi> gunluk)
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };
    private const int AzamiDeneme = 20;

    /// <summary>Zamanı gelmiş satırları sırayla dener; gönderilen sayısı.</summary>
    public async Task<int> SiradakileriIsleAsync(int azami, CancellationToken iptal)
    {
        if (!await AktifMiAsync(iptal)) return 0;
        var idler = await veri.ListeAsync("""
            select g.id from public.teletip_gonderim g
             where g.durum in (0, 5) and g.sonraki_deneme <= now()
               and not exists (select 1 from public.teletip_gonderim o
                                where o.istem_id = g.istem_id and o.kanal = g.kanal and o.id < g.id
                                  and o.durum in (0, 2, 3, 5))
             order by g.id
             limit @p0
            """, [azami], o => o.GetInt64(0), iptal);
        var sayac = 0;
        foreach (var id in idler)
        {
            if (iptal.IsCancellationRequested) break;
            try { if ((await DeneAsync(id, iptal)).Durum == 1) sayac++; }
            catch (Exception h) { gunluk.LogError(h, "Teletıp gönderimi {Id} denenirken hata.", id); }
        }
        return sayac;
    }

    public async Task<bool> AktifMiAsync(CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await AyarDeposu.MetinAsync(b, null, "teletip.aktif", "0", iptal) == "1";
    }

    /// <summary>Tek satırı dener (işçi ve "Yeniden Gönder" ucu). Satır kilitlenir; aynı anda iki deneme olmaz.</summary>
    public async Task<TeletipDenemeSonucu> DeneAsync(long id, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        await using var islem = await b.BeginTransactionAsync(iptal);
        var satir = await b.TekAsync("""
            select id, istem_id, emir, durum, deneme_no, veri::text as veri, accession_no, rapor_id
              from public.teletip_gonderim where id = @p0 for update skip locked
            """, islem, [id], o => new
        {
            IstemId = o.SayiNull("istem_id"),
            RaporId = o.SayiNull("rapor_id"),
            EmirKodu = Convert.ToInt32(o.GetValue(o.GetOrdinal("emir"))),
            Durum = Convert.ToInt16(o.GetValue(o.GetOrdinal("durum"))),
            Deneme = o.Sayi("deneme_no"),
            Veri = o.Metin("veri"),
        }, iptal);
        if (satir is null) return new(id, -1, "", "Satır bulunamadı ya da başka bir deneme sürüyor.");
        if (satir.Durum is 1 or 4) return new(id, satir.Durum, "", "Satır zaten sonuçlanmış.");

        var adres = await AyarDeposu.MetinAsync(b, islem, "teletip.hl7_adres", "", iptal);
        var firma = await AyarDeposu.MetinAsync(b, islem, "teletip.firma_kodu", "", iptal);
        var kodlama = await AyarDeposu.MetinAsync(b, islem, "teletip.encoding", "UTF8", iptal);

        // VERİ: CA anlık görüntüden (istem iptal / silinmiş olabilir), NW / XO güncel istemden.
        var json = satir.Veri.Length > 0 ? satir.Veri
                 : satir.IstemId is int iid
                     ? await b.TekDegerAsync<string>("select public.fn_teletip_orm_verisi(@p0)::text", islem, [iid], iptal) ?? ""
                     : "";
        if (json.Length == 0)
            return await YazAsync(b, islem, id, 4, satir.Deneme, "", "İstem yok (silinmiş) ve anlık görüntü yok.", "", "", iptal);

        var oruMu = satir.EmirKodu == 4;
        var v = (JsonSerializer.Deserialize<OrmVerisi>(json, JsonAyar) ?? new OrmVerisi()) with
        {
            // ORU satırında ORM denetimi "yeni istem" kurallarıyla yapılır (hasta / istem / kurum alanları aynı).
            Emir = oruMu ? OrmEmri.Yeni : (OrmEmri)satir.EmirKodu,
            FirmaKodu = firma,
            Encoding = kodlama.Length > 0 ? kodlama : "UTF8",
            KontrolNo = $"TT{id}-{satir.Deneme + 1}",
        };

        string mesaj;
        if (oruMu)
        {
            // RAPOR (1309): rapor kısmı fn_teletip_oru_verisi; istem / hasta / kurum kısmı yukarıdaki ORM verisi.
            var raporJson = satir.RaporId is int rid
                ? await b.TekDegerAsync<string>("select public.fn_teletip_oru_verisi(@p0)::text", islem, [rid], iptal) ?? "" : "";
            if (raporJson.Length == 0)
                return await YazAsync(b, islem, id, 4, satir.Deneme, "", "Rapor yok (silinmiş).", "", "", iptal);
            var rapor = JsonSerializer.Deserialize<TeletipRaporVerisi>(raporJson, JsonAyar) ?? new TeletipRaporVerisi();
            var eksikOru = TeletipOruKurucu.Denetle(v, rapor);
            if (eksikOru.Count > 0)
                return await YazAsync(b, islem, id, 3, satir.Deneme, "", string.Join(" · ", eksikOru), "", "", iptal);
            mesaj = OruUretici.Uret(TeletipOruKurucu.Kur(v, rapor));
        }
        else
        {
            var eksik = OrmUretici.Denetle(v);
            if (eksik.Count > 0)
                return await YazAsync(b, islem, id, 3, satir.Deneme, "", string.Join(" · ", eksik), "", "", iptal);
            mesaj = OrmUretici.Uret(v);
        }
        if (adres.Length == 0)
            return await YazAsync(b, islem, id, 5, satir.Deneme, "", "Teletıp HL7 adresi (teletip.hl7_adres) tanımlı değil.", "", "", iptal,
                                  sonraki: TimeSpan.FromMinutes(30));

        var s = await mllp.GonderAsync(adres, mesaj, v.Encoding, false, 40, iptal);
        short durum = s.AckKodu is "AA" or "CA" ? (short)1
                    : s.KaliciHata ? (short)2
                    : satir.Deneme + 1 >= AzamiDeneme ? (short)2
                    : (short)5;
        var hata = durum == 1 ? "" : s.Hata.Length > 0 ? s.Hata : $"ACK {s.AckKodu}";
        return await YazAsync(b, islem, id, durum, satir.Deneme, s.AckKodu, hata, mesaj, s.YanitGovdesi, iptal,
                              kontrolNo: v.KontrolNo, sonraki: Geri(satir.Deneme + 1));
    }

    /// <summary>Artan aralık: 1, 2, 5, 10, 30 dk, sonra saatlik.</summary>
    public static TimeSpan Geri(int deneme) => deneme switch
    {
        <= 1 => TimeSpan.FromMinutes(1),
        2 => TimeSpan.FromMinutes(2),
        3 => TimeSpan.FromMinutes(5),
        4 => TimeSpan.FromMinutes(10),
        5 => TimeSpan.FromMinutes(30),
        _ => TimeSpan.FromHours(1),
    };

    private static async Task<TeletipDenemeSonucu> YazAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction islem, long id,
        short durum, int deneme, string ack, string hata, string mesaj, string yanit, CancellationToken iptal,
        string kontrolNo = "", TimeSpan? sonraki = null)
    {
        // "gidemez" denemeyi saymaz: mesaj hiç gitmedi, eksik tamamlanınca tetik satırı yeniden 0 yapar.
        var sayilir = durum is 1 or 2 or 5;
        await b.CalistirAsync("""
            update public.teletip_gonderim
               set durum = @p1, deneme_no = deneme_no + @p2, ack_kodu = @p3, hata_metni = left(@p4, 2000),
                   mesaj = case when @p5 = '' then mesaj else @p5 end,
                   yanit = case when @p5 = '' then yanit else @p6 end,
                   kontrol_no = case when @p7 = '' then kontrol_no else @p7 end,
                   son_deneme = now(),
                   sonraki_deneme = now() + make_interval(secs => @p8)
             where id = @p0
            """, islem, [id, durum, sayilir ? 1 : 0, ack, hata, mesaj, yanit, kontrolNo,
                         (sonraki ?? TimeSpan.FromMinutes(1)).TotalSeconds], iptal);
        await islem.CommitAsync(iptal);
        _ = deneme;
        return new(id, durum, ack, hata);
    }
}

/// <summary>fn_teletip_oru_verisi (1309) - raporun Bakanlık kısmı.</summary>
public sealed record TeletipRaporVerisi
{
    public int RaporId { get; init; }
    public string Teknik { get; init; } = "";
    public string Karsilastirma { get; init; } = "";
    public string Bulgular { get; init; } = "";
    public string Sonuc { get; init; } = "";
    public DateTime? OnayZamani { get; init; }
    public DateTime? CekimZamani { get; init; }
    public short IstemNedeniPuan { get; init; }
    public short CekimKalitePuan { get; init; }
    public string RadyologTckn { get; init; } = "";
    public string RadyologSoyad { get; init; } = "";
    public string RadyologAd { get; init; } = "";
    public string KontrastObx17 { get; init; } = "";
    public bool Duzeltme { get; init; }
    /// <summary>fn_rad_bakanlik_eksik: Bulgular ≥ 50 karakter, Sonuç dolu - boş = uygun.</summary>
    public string RaporEksik { get; init; } = "";
}

/// <summary>
/// KENDİ RAPORUMUZUN ORU'SU (1309): istem / hasta / kurum alanları ORM verisinden (tek kaynak), rapor alanları
/// <see cref="TeletipRaporVerisi"/>'nden; üretim <see cref="OruUretici"/> Bakanlık profili (kılavuz 3.43 Tablo 20-22).
/// OBR-15 kendi hastanemizde "Radiology" (rapor ve istem aynı kurum - telerad'daki A/B ayrımı yok).
/// </summary>
public static class TeletipOruKurucu
{
    public static OruVerisi Kur(OrmVerisi v, TeletipRaporVerisi r) => new()
    {
        Profil = Hl7Profili.Bakanlik,
        GonderenUygulama = v.FirmaKodu, GonderenTesis = v.HbysAdi,
        AliciUygulama = v.AliciUygulama, AliciTesis = v.AliciTesis,
        Zaman = v.Zaman, KontrolNo = v.KontrolNo, Encoding = v.Encoding,
        HastaDosyaNo = v.HastaDosyaNo, HastaTckn = v.HastaTckn, HastaSoyad = v.HastaSoyad, HastaAd = v.HastaAd,
        DogumTarihi = v.DogumTarihi, Cinsiyet = v.Cinsiyet,
        BasvuruNo = v.BasvuruReferansi, HastaneReferans = v.HastaneReferansi,
        KurumSkrs = v.KurumSkrs, KurumAdi = v.KurumAdi, KurumKisaAdi = v.KurumKisaAdi, SubeNo = v.SubeNo,
        MedulaTesisKodu = v.MedulaTesisKodu,
        HastaSinifi = v.HastaSinifi, BirimId = v.BirimId, Bolum = v.BirimAdi, Sgk = v.Sgk, MedulaTakipNo = v.MedulaTakipNo,
        AccessionNo = v.AccessionNo,
        IsteyenHekimTckn = v.IsteyenHekim.Kimlik, IsteyenHekimSoyad = v.IsteyenHekim.Soyad, IsteyenHekimAd = v.IsteyenHekim.Ad,
        SutKodu = v.SutKodu, SutAdi = v.SutAdi,
        Loinc = v.Loinc.FirstOrDefault()?.Kod ?? "", LoincAdi = v.Loinc.FirstOrDefault()?.Ad ?? "",
        IstemZamani = v.IstemZamani, OnayZamani = r.OnayZamani, CekimZamani = r.CekimZamani,
        PlanlananZaman = v.PlanlananZaman,
        KlinikBilgi = v.KlinikBilgi, HizmetVerenSkrs = v.GonderilenSkrs,
        SysTakipNo = v.SysTakipNo, ModaliteKodu = v.Modalite,
        TeknisyenId = v.Teknisyen.Kimlik, TeknisyenSoyad = v.Teknisyen.Soyad, TeknisyenAd = v.Teknisyen.Ad,
        RaporTeknik = r.Teknik, RaporKarsilastirma = r.Karsilastirma, RaporBulgular = r.Bulgular, RaporSonuc = r.Sonuc,
        IstemNedeniPuan = r.IstemNedeniPuan, CekimKalitePuan = r.CekimKalitePuan,
        RadyologTckn = r.RadyologTckn, RadyologSoyad = r.RadyologSoyad, RadyologAd = r.RadyologAd,
        KontrastObx17 = r.KontrastObx17, Duzeltme = r.Duzeltme,
        TaniIcd = [.. v.Tanilar.Select(t => t.Icd).Where(x => !string.IsNullOrWhiteSpace(x))],
    };

    /// <summary>ORM'in ortak denetimi (hasta, istem, kurum) + rapora özgü: kılavuz OBX-5 (Bulgular ≥ 50, Sonuç), OBX-16
    /// radyolog TCKN (ÇKYS'den doğrulanır), OBX-13 puanları, OBR-7 onay zamanı.</summary>
    public static List<string> Denetle(OrmVerisi v, TeletipRaporVerisi r)
    {
        var e = OrmUretici.Denetle(v with { Emir = OrmEmri.Yeni });
        if (r.RaporEksik.Length > 0) e.Add(r.RaporEksik);
        if (!OrmUretici.TcknGecerli(r.RadyologTckn)) e.Add("Raporu onaylayan radyoloğun TCKN'si yok ya da geçersiz (OBX-16).");
        if (r.IstemNedeniPuan <= 0 || r.CekimKalitePuan <= 0) e.Add("İstem nedeni / çekim kalitesi puanı girilmemiş (OBX-13).");
        if (r.OnayZamani is null) e.Add("Rapor onay zamanı yok (OBR-7).");
        return e;
    }
}

/// <summary>Teletıp ORM kuyruğu işçisi: 30 sn'de bir; teletip.aktif kapalıysa hiçbir şey yapmaz.</summary>
public sealed class TeletipOrmIscisi(IServiceScopeFactory kapsam, ILogger<TeletipOrmIscisi> gunluk) : BackgroundService
{
    private static readonly TimeSpan Aralik = TimeSpan.FromSeconds(30);

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        try { await Task.Delay(TimeSpan.FromSeconds(25), dur); }
        catch (OperationCanceledException) { return; }
        while (!dur.IsCancellationRequested)
        {
            try
            {
                using var k = kapsam.CreateScope();
                var n = await k.ServiceProvider.GetRequiredService<TeletipOrmServisi>().SiradakileriIsleAsync(50, dur);
                if (n > 0) gunluk.LogInformation("Teletıp ORM: {Sayi} mesaj gönderildi.", n);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception h) { gunluk.LogError(h, "Teletıp ORM kuyruğu turu başarısız."); }
            try { await Task.Delay(Aralik, dur); }
            catch (OperationCanceledException) { break; }
        }
    }
}
