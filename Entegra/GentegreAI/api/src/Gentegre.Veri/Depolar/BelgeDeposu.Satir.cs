using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// BELGE SATIRI uzerinde calisan islemler: termin (teslim tarihi) guncelleme,
/// siparis rezervasyonu ve iade edilebilir satirlarin listelenmesi.
///
/// Ucu de belgeyi YENIDEN YAZMAZ - yalniz ilgili kolonlara dokunur; belge
/// numarasi, stok hareketi ve cari etkisi degismez.
/// </summary>
public sealed partial class BelgeDeposu
{
    /// <summary>
    /// PL/pgSQL `raise exception` mesajini IS KURALI hatasina cevirir.
    ///
    /// Yoksa dogrulama mesaji ("... vergi/kimlik numarasi girilmemis") ham
    /// PostgresException olarak 500'e dusuyor ve kullaniciya "Beklenmeyen bir
    /// hata" diye gorunuyordu - yapmasi gerekeni soyleyen mesaj kayboluyordu.
    /// P0001 = raise_exception (fonksiyonlarimizin bilerek attigi hata).
    /// </summary>
    private static async Task<T> IsKuraliCevirAsync<T>(Func<Task<T>> islem)
    {
        try { return await islem(); }
        catch (PostgresException h) when (h.SqlState == "P0001")
        {
            throw GentegreHatasi.IsKurali(h.MessageText);
        }
    }

    /// <summary>
    /// e-BELGE SIFIRLA (164) - Delphi `MenuSifirla`. Hazirlanmis belgeyi geri
    /// alir; GONDERILMIS belgede calismaz (numarasi GIB'e gitmistir).
    /// </summary>
    public Task<string> EBelgeSifirlaAsync(int belgeId, YazmaBaglami baglam,
        CancellationToken iptal = default)
        => IsKuraliCevirAsync(() => EBelgeSifirlaIcAsync(belgeId, baglam, iptal));

    private async Task<string> EBelgeSifirlaIcAsync(int belgeId, YazmaBaglami baglam,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using var komut = baglanti.Komut(
            "select public.fn_ebelge_sifirla(@p0, @p1)", islem,
            belgeId, baglam.KullaniciId);
        var mesaj = (await komut.ExecuteScalarAsync(iptal))?.ToString() ?? "";

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["eBelgeSifirla"] = mesaj }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return mesaj;
    }

    /// <summary>
    /// e-BELGE SERI DEGISTIR (164) - Delphi `MenuSeriDegistir`. Seri
    /// verilmezse siradaki kurala gecer; yeni numara uretilir.
    /// </summary>
    public Task<(string Numara, string Seri)> EBelgeSeriDegistirAsync(int belgeId,
        string? seri, YazmaBaglami baglam, CancellationToken iptal = default)
        => IsKuraliCevirAsync(() => EBelgeSeriDegistirIcAsync(belgeId, seri, baglam, iptal));

    private async Task<(string Numara, string Seri)> EBelgeSeriDegistirIcAsync(int belgeId,
        string? seri, YazmaBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using var komut = baglanti.Komut(
            "select * from public.fn_ebelge_seri_degistir(@p0, @p1, @p2)", islem,
            belgeId, baglam.KullaniciId, string.IsNullOrWhiteSpace(seri) ? DBNull.Value : seri.Trim());

        string no, yeniSeri;
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
        {
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("Seri değiştirilemedi.");
            no = okuyucu.GetString(0);
            yeniSeri = okuyucu.GetString(1);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["eBelgeSeri"] = $"{yeniSeri} / {no}" }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return (no, yeniSeri);
    }

    /// <summary>
    /// e-BELGE HAZIRLA (163) - Delphi `TEBelgeOlusturucu.MenuHazirla` karsiligi.
    ///
    /// Is kurallari SUNUCUDA (fn_ebelge_hazirla): dogrulama, belge turu karari
    /// (e-Fatura / e-Arsiv / e-Irsaliye), seri secimi, numara uretimi ve
    /// e_belge satirinin acilmasi tek transaction icinde olur - Delphi'deki
    /// "dogrulama en basta, numara en son" sirasi orada korunuyor.
    ///
    /// UBL/XML BU ADIMDA URETILMEZ; belge kuyruga alinir, gonderim asamasi
    /// XML'i sonra kurar.
    /// </summary>
    public Task<(long EBelgeId, int BelgeTuru, string BelgeNo, string Seri, string Uyari)>
        EBelgeHazirlaAsync(int belgeId, YazmaBaglami baglam, CancellationToken iptal = default)
        => IsKuraliCevirAsync(() => EBelgeHazirlaIcAsync(belgeId, baglam, iptal));

    private async Task<(long EBelgeId, int BelgeTuru, string BelgeNo, string Seri, string Uyari)>
        EBelgeHazirlaIcAsync(int belgeId, YazmaBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using var komut = baglanti.Komut(
            "select * from public.fn_ebelge_hazirla(@p0, @p1)", islem,
            belgeId, baglam.KullaniciId);

        long eBelgeId; int tur; string no, seri, uyari;
        await using (var okuyucu = await komut.ExecuteReaderAsync(iptal))
        {
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("e-Belge hazırlanamadı.");
            eBelgeId = okuyucu.GetInt64(0);
            tur      = okuyucu.GetInt16(1);
            no       = okuyucu.GetString(2);
            seri     = okuyucu.GetString(3);
            uyari    = okuyucu.IsDBNull(4) ? "" : okuyucu.GetString(4);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["eBelgeHazirla"] = $"{seri} / {no}" },
            iptal: iptal);

        await islem.CommitAsync(iptal);
        return (eBelgeId, tur, no, seri, uyari);
    }


    /// <summary>
    /// TERMIN GUNCELLEME (140): satirlarin teslim tarihini toplu degistirir.
    ///
    /// Belgeyi YENIDEN YAZMAZ. Termin ne stok ne cari ne de tutar etkiler; bu
    /// yuzden "kayitli belge duzenleme" kilidine (135) de takilmaz - e-Belgesi
    /// gonderilmis ya da faturalanmis bir siparisin kalan kalemleri icin de
    /// yeni tarih verilebilir. Tedarikci gecikince siparisi iptal edip yeniden
    /// kesmek yerine tarih guncellenir: numara, fiyat ve donusum zinciri kalir.
    ///
    /// Bos tarih = termin KALDIRILDI (belirsiz). Yalniz belgenin KENDI satirlari
    /// guncellenir - baska belgenin satir kimligi gonderilirse sessizce atlanmaz,
    /// 404 verir.
    /// </summary>
    public async Task<int> TerminGuncelleAsync(
        int belgeId, IReadOnlyList<(int SatirId, DateTime? Tarih)> satirlar,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (satirlar.Count == 0)
            throw GentegreHatasi.Dogrulama("Güncellenecek satır yok.",
                new AlanHatasi("satirlar", "Boş bırakılamaz."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        IDictionary<string, object?> belge;
        await using (var komut = new NpgsqlCommand(
            "select id, tur, durum, sube_id, taraf_id, belge_no from public.belge where id = @p0",
            baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            belge = o.Sozluk();
        }

        if (baglam.SubeId is { } sube && belge["sube_id"] is { } bs
            && Convert.ToInt32(bs) != sube)
            throw GentegreHatasi.Bulunamadi();

        if (Convert.ToInt32(belge["durum"]) == 2)
            throw GentegreHatasi.IsKurali("İptal edilmiş belgede termin güncellenemez.");

        var degisen = 0;
        foreach (var (satirId, tarih) in satirlar)
        {
            await using var komut = baglanti.Komut("""
                update public.belge_satir
                   set teslim_tarihi = @p2, degistiren = @p3
                 where id = @p0 and belge_id = @p1
                """, islem,
                satirId, belgeId, (object?)tarih ?? DBNull.Value, baglam.KullaniciId);
            var etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            if (etkilenen == 0)
                throw GentegreHatasi.Bulunamadi($"Satır bu belgeye ait değil: {satirId}");
            degisen += etkilenen;
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = "termin",
                ["satirAdedi"] = degisen.ToString(CultureInfo.InvariantCulture),
                // En ileri tarih ozet olarak yeterli: "termin nereye cekildi".
                ["yeniTermin"] = satirlar.Where(s => s.Tarih is not null)
                    .Select(s => s.Tarih!.Value)
                    .DefaultIfEmpty()
                    .Max()
                    .ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
            },
            tarafId: SayiNull(belge, "taraf_id"), iptal: iptal);

        await islem.CommitAsync(iptal);
        return degisen;
    }

    /// <summary>
    /// SIPARIS REZERVASYONU (142): satirlarin KALAN miktarini depoda ayirir
    /// (ac=true) ya da birakir (ac=false).
    ///
    /// Stok DUSMEZ - o irsaliyede olur; yalniz "soz verilmis" miktar isaretlenir
    /// ve stok aramasinda kullanilabilir (kalan - rezerve) olarak gorunur.
    /// Kural motorda (fn_belge_rezerve): yalniz kesin SIPARISTE calisir, sevk
    /// edildikce rezerv kendiliginden cozulur.
    /// </summary>
    public async Task<int> RezerveAsync(int belgeId, bool ac,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        if (baglam.SubeId is { } sube)
        {
            await using var kontrol = baglanti.Komut(
                "select sube_id from public.belge where id = @p0", islem,
                belgeId);
            var bs = await kontrol.ExecuteScalarAsync(iptal);
            if (bs is null) throw GentegreHatasi.Bulunamadi();
            if (bs is not DBNull && Convert.ToInt32(bs) != sube) throw GentegreHatasi.Bulunamadi();
        }

        int adet;
        await using (var komut = new NpgsqlCommand(
            "select public.fn_belge_rezerve(@p0, @p1)", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", belgeId);
            komut.Parameters.AddWithValue("p1", ac);
            try
            {
                adet = Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
            }
            catch (PostgresException h) when (h.SqlState == "GK422")
            {
                throw GentegreHatasi.IsKurali(h.MessageText);
            }
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBelge, belgeId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["aksiyon"] = ac ? "rezerve" : "rezerve-kaldir",
                ["satirAdedi"] = adet.ToString(CultureInfo.InvariantCulture)
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return adet;
    }

    /// <summary>Acik (kalani olan) satirlar - donusum ekraninin kaynagi.</summary>
    public async Task<List<IDictionary<string, object?>>> AcikSatirlarAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select v.satir_id as "satirId", v.sira, v.satir_tur as "satirTur",
                   v.stok_id as "stokId", v.stok_kodu as "stokKodu", v.stok_adi as "stokAdi",
                   v.hizmet_id as "hizmetId", v.masraf_id as "masrafId", v.aciklama,
                   v.miktar, v.kapatilan_miktar as "kapatilanMiktar",
                   v.kalan_miktar as "kalanMiktar", v.birim,
                   v.birim_fiyat as "birimFiyat", v.iskonto, v.kdv,
                   v.belge_tur as "belgeTur", v.belge_tur_adi as "belgeTurAdi",
                   v.belge_no as "belgeNo", v.taraf_unvan as "tarafUnvan",
                   v.belge_dovizi as "belgeDovizi", v.kapanma_durum as "kapanmaDurum",
                   -- Odeme paylasimi (289/290): donusum penceresi hangi payin
                   --   ne kadarinin acik oldugunu gostersin.
                   v.kurum_tutar as "kurumTutar", v.hasta_tutar as "hastaTutar",
                   v.kurum_kalan as "kurumKalan", v.hasta_kalan as "hastaKalan",
                   -- Kalem adi (293): stok disi satirlarda (hizmet/masraf) ad
                   --   yoktu, donusum penceresinde satir BOS gorunuyordu.
                   v.kalem_kodu as "kalemKodu", v.kalem_adi as "kalemAdi",
                   -- Tutar bazli donusum (352): matrah, tahsil edilen matrah ve
                   --   acik kalan tutar - "tahsil edilen kadar fis" onerisi.
                   v.tutar, v.hasta_tahsil_matrah as "hastaTahsilMatrah",
                   v.kurum_tahsil_matrah as "kurumTahsilMatrah", v.tutar_kalan as "tutarKalan"
              from public.v_belge_acik_satir v
             where v.belge_id = @p0 order by v.sira
            """, null,
            belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(o.Sozluk());
        return liste;
    }

    /// <summary>
    /// IADE EDILEBILIR SATIRLAR (132) - iade faturasinda "onceki alinanlar".
    ///
    /// Carinin kesin fatura/fis satirlari; miktar, iade edilmis miktar ve
    /// kaynaktan gelen fiyat/iskonto/KDV ile birlikte. Tamami iade edilmis
    /// satirlar DUSER (kalan = 0), boylece ayni kalem iki kez iade edilemez.
    /// belgeId verilirse yalniz o belgenin satirlari (belge uzerinden iade).
    /// </summary>
    public async Task<List<IDictionary<string, object?>>> IadeSatirlariAsync(
        int tarafId, int? belgeId, string? ara, IReadOnlyList<int>? turler = null,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select v.satir_id as "satirId", v.belge_id as "belgeId",
                   v.belge_tur as "belgeTur", v.belge_no as "belgeNo",
                   v.belge_tarihi as "belgeTarihi", v.taraf_id as "tarafId",
                   v.taraf_unvan as "tarafUnvan", v.sira,
                   v.satir_tur as "satirTur", v.stok_id as "stokId",
                   v.stok_kodu as "stokKodu", v.stok_adi as "stokAdi",
                   v.hizmet_id as "hizmetId", v.aciklama,
                   v.miktar, v.iade_miktar as "iadeMiktar",
                   (v.miktar - v.iade_miktar) as "kalanMiktar",
                   v.birim, v.birim_fiyat as "birimFiyat", v.iskonto, v.kdv,
                   v.doviz_cinsi as "dovizCinsi", v.izleme, v.izleme_kodu as "izlemeKodu"
              from public.v_iade_edilebilir_satir v
             where (@p0 <= 0 or v.taraf_id = @p0)
               and (@p1 <= 0 or v.belge_id = @p1)
               -- Iade FATURASINDA fatura, iade IRSALIYESINDE irsaliye satirlari
               --   (133): ayni mal iki kaynaktan iade edilip cift sayilmasin.
               and (cardinality(@p3::int[]) = 0 or v.belge_tur = any(@p3::int[]))
               and (v.miktar - v.iade_miktar) > 0
               and (@p2 = '' or v.stok_kodu ilike '%' || @p2 || '%'
                             or v.stok_adi  ilike '%' || @p2 || '%'
                             or v.belge_no  ilike '%' || @p2 || '%')
             order by v.belge_tarihi desc, v.belge_id desc, v.sira
             limit 200
            """, null,
            tarafId, belgeId ?? 0, ara ?? "", (turler ?? Array.Empty<int>()).ToArray());

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(o.Sozluk());
        return liste;
    }

    /// <summary>
    /// Bu belgeden TURETILMIS belgeler (irsaliye kartinin Faturalama sekmesi).
    /// Satir bagindan gruplanir: bir irsaliye birden fazla faturaya bolunebilir.
    /// </summary>
    public async Task<List<IDictionary<string, object?>>> DonusumlerAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select hb.id                       as "belgeId",
                   hb.belge_no                 as "belgeNo",
                   hb.belge_tarihi             as "belgeTarihi",
                   hb.tur                      as tur,
                   coalesce(ht.ad, '')         as "turAdi",
                   hb.taraf_unvan              as "tarafUnvan",
                   sum(hs.miktar)              as miktar,
                   -- KDV DAHIL (kullanici: "3190 ucretlendirme var ama
                   --   donusumde 2900 gorunuyor"): kaynaktaki ucretlendirme
                   --   KDV dahil okunuyor, burada satir tutari KDV HARICTI -
                   --   ayni isin iki farkli sayisi kafa karistiriyordu.
                   --   Belgenin genel_toplam'i kullanilamaz: bir fatura birden
                   --   cok kaynaktan satir toplayabilir, o zaman bu kaynagin
                   --   payindan fazlasini gosterirdi.
                   sum(round(hs.tutar * (1 + coalesce(hs.kdv, 0) / 100.0), 2)) as tutar,
                   hb.durum,
                   case hb.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end as "durumAdi"
              from public.belge_satir hs
              join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
              join public.belge hb       on hb.id = hs.belge_id
              left join public.kasa_islem_turu ht on ht.kod = hb.tur
             where ks.belge_id = @p0
             group by hb.id, hb.belge_no, hb.belge_tarihi, hb.tur, ht.ad, hb.taraf_unvan, hb.durum
             order by hb.belge_tarihi, hb.id
            """, null,
            belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(o.Sozluk());
        return liste;
    }

    /// <summary>Onizleme HTML'i (178). Belge hazirlanmamis olsa da uretilir.</summary>
    public async Task<string> EBelgeHtmlAsync(int belgeId, CancellationToken iptal = default)
        => await IsKuraliCevirAsync(async () =>
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "select public.fn_ebelge_html(@p0)", null,
                belgeId);
            return (await komut.ExecuteScalarAsync(iptal))?.ToString() ?? "";
        });

    /// <summary>
    /// Gonderim govdesi + onerilen dosya adi. Bicim 1 JSON / 2 UBL-XML
    /// (entegratore gore, 167) - dosya uzantisi buna gore secilir.
    /// </summary>
    public async Task<(short Bicim, string Govde, string DosyaAdi)> EBelgeGovdeAsync(
        int belgeId, CancellationToken iptal = default)
        => await IsKuraliCevirAsync(async () =>
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                select g.bicim, g.govde::text,
                       coalesce(nullif(e.belge_no, ''), 'belge-' || @p0::text)
                  from public.fn_ebelge_gonderim_govdesi(@p0) g
                  left join lateral (select e2.belge_no from public.e_belge e2
                                      where e2.belge_id = @p0 order by e2.id desc limit 1) e on true
                """, null,
                belgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("Gönderim gövdesi üretilemedi.");
            return (o.GetInt16(0), o.GetString(1), o.GetString(2));
        });

    public sealed record EBelgeMesaji(int Sira, DateTime? Tarih, string Olay,
                                      string Durum, string Kod, string Aciklama);

    /// <summary>Belgenin e-Belge gecmisi: hazirlama, gonderim, GIB yaniti (178).</summary>
    public async Task<IReadOnlyList<EBelgeMesaji>> EBelgeMesajlarAsync(
        int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select sira, tarih, olay, durum, kod, aciklama from public.fn_ebelge_mesajlar(@p0)", null,
            belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        var liste = new List<EBelgeMesaji>();
        while (await o.ReadAsync(iptal))
            liste.Add(new EBelgeMesaji(
                o.GetInt32(0),
                o.IsDBNull(1) ? null : o.GetDateTime(1),
                o.IsDBNull(2) ? "" : o.GetString(2),
                o.IsDBNull(3) ? "" : o.GetString(3),
                o.IsDBNull(4) ? "" : o.GetString(4),
                o.IsDBNull(5) ? "" : o.GetString(5)));
        return liste;
    }

    /// <summary>
    /// Bu subede e-Belge KULLANILIYOR mu: ANA SALTER subenin (ya da kimligini
    /// kullandigi merkezin) e-Fatura mukellefiyetidir (179). Menu gorunurlugu
    /// buna bagli - mukellef olmayan firmada e-Belge maddeleri hic cizilmez.
    /// </summary>
    public async Task<bool> EBelgeKullanimdaAsync(int? subeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select public.fn_ebelge_acik(@p0)
            """, null,
            (object?)subeId ?? DBNull.Value);
        return await komut.ExecuteScalarAsync(iptal) is bool b && b;
    }

    /// <summary>
    /// Belgeyi siler (181). On-kosul saglanmazsa IS KURALI hatasi doner -
    /// e-Belge hazirlanmis/gonderilmis, kasa islemi bagli ya da baska belgeye
    /// donusturulmus belge SILINMEZ; onlarda "İptal Et" kullanilir.
    /// </summary>
    public async Task<string> SilAsync(int belgeId, YazmaBaglami baglam,
                                       CancellationToken iptal = default)
        => await IsKuraliCevirAsync(async () =>
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            // Log SILMEDEN ONCE yazilir: silinen satirin alanlari sonra okunamaz.
            //   Ozet (tur/no/cari) bilgiye konur - log listesi Modul/Kod/Ad
            //   kolonlarini silinmis kayitta da cozebilsin.
            Dictionary<string, string>? logOzet = null;
            await using (var ozetKomut = baglanti.Komut(
                "select tur, belge_no, taraf_unvan, taraf_id from public.belge where id = @p0",
                islem, belgeId))
            await using (var o = await ozetKomut.ExecuteReaderAsync(iptal))
                if (await o.ReadAsync(iptal))
                    logOzet = new Dictionary<string, string>
                    {
                        ["tur"] = Convert.ToString(o["tur"], CultureInfo.InvariantCulture) ?? "",
                        ["belgeNo"] = Convert.ToString(o["belge_no"]) ?? "",
                        ["tarafUnvan"] = Convert.ToString(o["taraf_unvan"]) ?? "",
                        ["tarafId"] = Convert.ToString(o["taraf_id"], CultureInfo.InvariantCulture) ?? ""
                    };
            await _log.YazAsync(baglanti, islem, LogIslemi.Sil, LogTabloBelge, belgeId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, logOzet, iptal: iptal);

            await using var komut = baglanti.Komut(
                "select public.fn_belge_sil(@p0, @p1)", islem,
                belgeId, baglam.KullaniciId);
            var mesaj = (await komut.ExecuteScalarAsync(iptal))?.ToString() ?? "Belge silindi.";

            await islem.CommitAsync(iptal);
            return mesaj;
        });

    /// <summary>Silme on-kosulu: bos metin = silinebilir, dolu = sebep (181).</summary>
    public async Task<string> SilinebilirMiAsync(int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select public.fn_belge_silinebilir(@p0)", null,
            belgeId);
        return (await komut.ExecuteScalarAsync(iptal))?.ToString() ?? "";
    }

    /// <summary>
    /// Belgenin UBL-XML'i + (varsa) goruntuleme XSLT'si (182).
    ///
    /// XSLT'yi de AYNI cagrida doner: arayuz ikisini birlestirip GIB'in gordugu
    /// goruntuyu cizer. Ayri iki istek, 1-2 MB'lik sablonu ikinci kez cekmek
    /// demekti.
    /// </summary>
    public async Task<(string Ubl, string Xslt, string DosyaAdi)> EBelgeUblAsync(
        int belgeId, CancellationToken iptal = default)
        => await IsKuraliCevirAsync(async () =>
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var komut = baglanti.Komut("""
                select xmlserialize(document public.fn_ebelge_ubl(@p0) as text),
                       coalesce((select convert_from(di.icerik, 'UTF8')
                                   from public.dokuman d
                                   join public.dokuman_icerik di on di.hash = d.hash
                                  where d.kaynak = 'ebelge-xslt' and d.durum = 1
                                    and d.kaynak_id = coalesce(
                                        (select e.belge_turu from public.e_belge e
                                          where e.belge_id = @p0 order by e.id desc limit 1),
                                        case when (select bl.tur from public.belge bl
                                                    where bl.id = @p0) = 14 then 7 else 1 end)
                                  order by d.varsayilan desc, d.id limit 1), ''),
                       coalesce((select nullif(e.belge_no, '') from public.e_belge e
                                  where e.belge_id = @p0 order by e.id desc limit 1),
                                'belge-' || @p0::text)
                """, null,
                belgeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("UBL üretilemedi.");
            return (o.GetString(0), o.GetString(1), o.GetString(2));
        });

    public sealed record TopluSonuc(int BelgeId, bool Basarili, string BelgeNo, string Mesaj);

    /// <summary>
    /// Secili belgeleri TEK cagrida hazirlar (183). Hata tek belgeyi duserir,
    /// digerleri devam eder - tek transaction olsaydi bir hatali belge yuzunden
    /// dogru olanlar da geri alinirdi.
    /// </summary>
    public async Task<IReadOnlyList<TopluSonuc>> EBelgeTopluHazirlaAsync(
        IReadOnlyList<int> belgeIdler, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select belge_id, basarili, belge_no, mesaj from public.fn_ebelge_toplu_hazirla(@p0, @p1)", null,
            belgeIdler.ToArray(), baglam.KullaniciId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        var liste = new List<TopluSonuc>();
        while (await o.ReadAsync(iptal))
            liste.Add(new TopluSonuc(o.GetInt32(0), o.GetBoolean(1),
                                     o.IsDBNull(2) ? "" : o.GetString(2),
                                     o.IsDBNull(3) ? "" : o.GetString(3)));
        return liste;
    }

    public sealed record AliciBilgisi(short BelgeTuru, string Alias, string OnerilenMail,
                                      string TarafUnvan);

    /// <summary>
    /// Gonderim oncesi alici adresi (184). e-ARSIVDE alias alani alici
    /// e-postasidir; bos ise arayuz sorar ve carinin adresini onerir.
    /// </summary>
    public async Task<AliciBilgisi> EBelgeAliciAsync(int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select belge_turu, alias, onerilen_mail, taraf_unvan from public.fn_ebelge_alici_bilgi(@p0)", null,
            belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Belge icin e-Belge kaydi yok.");
        return new AliciBilgisi(o.GetInt16(0), o.GetString(1), o.GetString(2), o.GetString(3));
    }
}
