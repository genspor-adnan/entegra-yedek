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
    public async Task<(long EBelgeId, int BelgeTuru, string BelgeNo, string Seri, string Uyari)>
        EBelgeHazirlaAsync(int belgeId, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using var komut = new NpgsqlCommand(
            "select * from public.fn_ebelge_hazirla(@p0, @p1)", baglanti, islem);
        komut.Parameters.AddWithValue("p0", belgeId);
        komut.Parameters.AddWithValue("p1", baglam.KullaniciId);

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
            belge = Satir(o);
        }

        if (baglam.SubeId is { } sube && belge["sube_id"] is { } bs
            && Convert.ToInt32(bs) != sube)
            throw GentegreHatasi.Bulunamadi();

        if (Convert.ToInt32(belge["durum"]) == 2)
            throw GentegreHatasi.IsKurali("İptal edilmiş belgede termin güncellenemez.");

        var degisen = 0;
        foreach (var (satirId, tarih) in satirlar)
        {
            await using var komut = new NpgsqlCommand("""
                update public.belge_satir
                   set teslim_tarihi = @p2, degistiren = @p3
                 where id = @p0 and belge_id = @p1
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", satirId);
            komut.Parameters.AddWithValue("p1", belgeId);
            komut.Parameters.AddWithValue("p2", (object?)tarih ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", baglam.KullaniciId);
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
            await using var kontrol = new NpgsqlCommand(
                "select sube_id from public.belge where id = @p0", baglanti, islem);
            kontrol.Parameters.AddWithValue("p0", belgeId);
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
        await using var komut = new NpgsqlCommand("""
            select v.satir_id as "satirId", v.sira, v.satir_tur as "satirTur",
                   v.stok_id as "stokId", v.stok_kodu as "stokKodu", v.stok_adi as "stokAdi",
                   v.hizmet_id as "hizmetId", v.masraf_id as "masrafId", v.aciklama,
                   v.miktar, v.kapatilan_miktar as "kapatilanMiktar",
                   v.kalan_miktar as "kalanMiktar", v.birim,
                   v.birim_fiyat as "birimFiyat", v.iskonto, v.kdv,
                   v.belge_tur as "belgeTur", v.belge_tur_adi as "belgeTurAdi",
                   v.belge_no as "belgeNo", v.taraf_unvan as "tarafUnvan",
                   v.belge_dovizi as "belgeDovizi", v.kapanma_durum as "kapanmaDurum"
              from public.v_belge_acik_satir v
             where v.belge_id = @p0 order by v.sira
            """, baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(Satir(o));
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
        await using var komut = new NpgsqlCommand("""
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
            """, baglanti);
        komut.Parameters.AddWithValue("p0", tarafId);
        komut.Parameters.AddWithValue("p1", belgeId ?? 0);
        komut.Parameters.AddWithValue("p2", ara ?? "");
        komut.Parameters.AddWithValue("p3", (turler ?? Array.Empty<int>()).ToArray());

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(Satir(o));
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
        await using var komut = new NpgsqlCommand("""
            select hb.id                       as "belgeId",
                   hb.belge_no                 as "belgeNo",
                   hb.belge_tarihi             as "belgeTarihi",
                   coalesce(ht.ad, '')         as "turAdi",
                   hb.taraf_unvan              as "tarafUnvan",
                   sum(hs.miktar)              as miktar,
                   sum(hs.tutar)               as tutar,
                   hb.durum,
                   case hb.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end as "durumAdi"
              from public.belge_satir hs
              join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
              join public.belge hb       on hb.id = hs.belge_id
              left join public.kasa_islem_turu ht on ht.kod = hb.tur
             where ks.belge_id = @p0
             group by hb.id, hb.belge_no, hb.belge_tarihi, ht.ad, hb.taraf_unvan, hb.durum
             order by hb.belge_tarihi, hb.id
            """, baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);

        var liste = new List<IDictionary<string, object?>>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal)) liste.Add(Satir(o));
        return liste;
    }
}
