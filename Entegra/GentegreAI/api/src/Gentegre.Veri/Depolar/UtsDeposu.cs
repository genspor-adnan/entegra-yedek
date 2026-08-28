using System.Globalization;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// ÜTS veri katmanı (UTSRepository) - uts_bildirim / uts_bildirim_mesaj /
/// uts_envanter. Delphi'de elle string birleştirilen INSERT'lerin karşılığı;
/// her yazma parametreli ve islem_log'lu.
///
/// AKIŞ SÖZLEŞMESİ: bildirim HTTP'ye çıkmadan ÖNCE durum=0 (Bekliyor) olarak
/// KAYDEDİLİR ve COMMIT edilir - süreç ölse bile ne gönderilmeye çalışıldığı
/// bellidir. Cevap gelince SonucYaz durumu 1/2'ye çeker. Token bu katmana
/// hiç girmez (yalnız HTTP başlığında yaşar).
/// </summary>
public sealed class UtsDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    /// <summary>islem_log tablo kodları (223): 930 hesap, 931 bildirim, 932 envanter.</summary>
    public const int LogTabloHesap = 930;
    public const int LogTabloBildirim = 931;
    public const int LogTabloEnvanter = 932;

    public UtsDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>Bildirim satırı + ham istek: tek transaction, HTTP ÖNCESİ iz.</summary>
    public async Task<int> BildirimEkleAsync(
        short tur, YazmaBaglami baglam, bool testMi, int? stokId, int? seriLotId,
        int? belgeId, int? belgeSatirId, decimal adet, DateTime? gercekIslemTarihi,
        string kurumNo, string belgeNo, string urunNo, string lotNo, string seriNo,
        DateTime? urt, DateTime? skt, string istekJson,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var id = await baglanti.TekDegerAsync<int>("""
            insert into public.uts_bildirim
                   (tur, durum, sube_id, test_mi, stok_id, seri_lot_id,
                    belge_id, belge_satir_id, adet, gercek_islem_tarihi, ekleyen)
            values (@p0, 0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
            returning id
            """, islem, new object?[]
            {
                tur, baglam.SubeId ?? 0, (short)(testMi ? 1 : 0), stokId, seriLotId,
                belgeId, belgeSatirId, adet, gercekIslemTarihi, baglam.KullaniciId
            }, iptal);

        await using (var mesaj = baglanti.Komut("""
            insert into public.uts_bildirim_mesaj
                   (bildirim_id, kurum_no, belge_no, urun_no, lot_no, seri_no,
                    urt, skt, istek_json)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8::jsonb)
            """, islem,
            id, kurumNo, belgeNo, urunNo, lotNo, seriNo,
            (object?)urt ?? DBNull.Value, (object?)skt ?? DBNull.Value, istekJson))
            await mesaj.ExecuteNonQueryAsync(iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloBildirim, id,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["tur"] = tur.ToString(CultureInfo.InvariantCulture),
                ["urunNo"] = urunNo,
                ["belgeNo"] = belgeNo
            },
            stokId: stokId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return id;
    }

    /// <summary>ÜTS cevabını işler: durum + SNC + ham cevap + özet.</summary>
    public async Task SonucYazAsync(int bildirimId, short durum, string utsBildirimId,
        string cevapJson, int httpKodu, string sonucKodu, string sonucMesaji,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using (var k1 = baglanti.Komut("""
            update public.uts_bildirim
               set durum = @p1, uts_bildirim_id = @p2,
                   degistiren = @p3, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, islem, bildirimId, durum, utsBildirimId, baglam.KullaniciId))
            await k1.ExecuteNonQueryAsync(iptal);

        await using (var k2 = baglanti.Komut("""
            update public.uts_bildirim_mesaj
               set cevap_json = @p1::jsonb, http_kodu = @p2,
                   sonuc_kodu = left(@p3, 20), sonuc_mesaji = left(@p4, 500)
             where bildirim_id = @p0
            """, islem, bildirimId, cevapJson, (short)httpKodu, sonucKodu, sonucMesaji))
            await k2.ExecuteNonQueryAsync(iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloBildirim, bildirimId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["durum"] = durum.ToString(CultureInfo.InvariantCulture),
                ["utsBildirimId"] = utsBildirimId,
                ["sonuc"] = sonucMesaji
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }

    /// <summary>Yeniden gönderim / iptal için bildirimin özeti.</summary>
    public async Task<(short Tur, short Durum, int SubeId, string UtsBildirimId,
                       string IstekJson)> BildirimOkuAsync(int bildirimId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select b.tur, b.durum, b.sube_id, b.uts_bildirim_id,
                   coalesce(m.istek_json::text, '')
              from public.uts_bildirim b
              join public.uts_bildirim_mesaj m on m.bildirim_id = b.id
             where b.id = @p0
            """, null, bildirimId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
        return (o.GetInt16(0), o.GetInt16(1), o.GetInt32(2), o.GetString(3), o.GetString(4));
    }

    /// <summary>
    /// Askıdaki satırı upsert eder (anahtar: sube + verme_bildirim_id).
    /// Senkronda görülen kayıt yeniden "askıda"ya döner (karşı taraf iptal
    /// edip tekrar vermiş olabilir); alınmışsa alındı kalır.
    /// </summary>
    public async Task<int> EnvanterUpsertAsync(int subeId, string vermeBildirimId,
        string kurumNo, string kurumUnvan, string urunNo, string lotNo, string seriNo,
        string belgeNo, string bildirimTipi, DateTime? bildirimZamani, string markaModel,
        decimal adet, int? stokId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await baglanti.TekDegerAsync<int>("""
            insert into public.uts_envanter
                   (sube_id, verme_bildirim_id, kurum_no, kurum_unvan, urun_no,
                    lot_no, seri_no, belge_no, bildirim_tipi, bildirim_zamani,
                    marka_model, gelen_adet, aski_adet, stok_id, durum, guncelleme)
            values (@p0, @p1, @p2, left(@p3, 200), @p4, @p5, @p6, @p7, @p8, @p9,
                    left(@p10, 300), @p11, @p11, @p12, 1, now()::timestamp)
            on conflict (sube_id, verme_bildirim_id) do update
               set kurum_unvan = excluded.kurum_unvan,
                   marka_model = excluded.marka_model,
                   gelen_adet  = excluded.gelen_adet,
                   -- Alınmamışsa askı adeti tazelenir; alınmışsa dokunulmaz.
                   aski_adet   = case when uts_envanter.durum = 2
                                      then uts_envanter.aski_adet
                                      else excluded.gelen_adet end,
                   durum       = case when uts_envanter.durum = 2 then 2 else 1 end,
                   stok_id     = coalesce(uts_envanter.stok_id, excluded.stok_id),
                   guncelleme  = now()::timestamp
            returning id
            """, null, new object?[]
            {
                subeId, vermeBildirimId, kurumNo, kurumUnvan, urunNo,
                lotNo, seriNo, belgeNo, bildirimTipi,
                (object?)bildirimZamani ?? DBNull.Value, markaModel, adet, stokId
            }, iptal);
    }

    /// <summary>Senkronda GELMEYEN askıdaki kayıtlar: karşı taraf iptal etmiş
    /// ya da başka yolla kapanmış - durum 0 (kayboldu).</summary>
    public async Task<int> EnvanterEksikleriIsaretleAsync(int subeId,
        IReadOnlyList<string> gorulenBidler, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            update public.uts_envanter
               set durum = 0, guncelleme = now()::timestamp
             where sube_id = @p0 and durum = 1
               and not (verme_bildirim_id = any(@p1))
            """, baglanti);
        komut.Parameters.AddWithValue("p0", subeId);
        komut.Parameters.Add("p1", NpgsqlDbType.Array | NpgsqlDbType.Varchar)
             .Value = gorulenBidler.ToArray();
        return await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>Alma bildirimi kaynağı: envanter satırının özeti.</summary>
    public async Task<(string Bid, string KurumNo, string UrunNo, string LotNo,
                       string SeriNo, decimal AskiAdet, int? StokId, short Durum)>
        EnvanterOkuAsync(int envanterId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select verme_bildirim_id, kurum_no, urun_no, lot_no, seri_no,
                   aski_adet, stok_id, durum
              from public.uts_envanter where id = @p0
            """, null, envanterId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
        return (o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3),
                o.GetString(4), o.GetDecimal(5),
                o.IsDBNull(6) ? null : o.GetInt32(6), o.GetInt16(7));
    }

    /// <summary>Başarılı alma sonrası: askı adetini düş, biterse "alındı".</summary>
    public async Task EnvanterAlindiAsync(int envanterId, decimal alinanAdet,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);
        await using (var komut = baglanti.Komut("""
            update public.uts_envanter
               set aski_adet = greatest(aski_adet - @p1, 0),
                   durum = case when aski_adet - @p1 <= 0 then 2 else 1 end,
                   guncelleme = now()::timestamp
             where id = @p0
            """, islem, envanterId, alinanAdet))
            await komut.ExecuteNonQueryAsync(iptal);
        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloEnvanter, envanterId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string> { ["alinanAdet"] = alinanAdet.ToString(CultureInfo.InvariantCulture) },
            iptal: iptal);
        await islem.CommitAsync(iptal);
    }

    /// <summary>Belge köprüsü (226): belgenin ÜTS'ye konu özeti.</summary>
    public async Task<(short Tur, string BelgeNo, DateTime BelgeTarihi, int SubeId,
                       int TarafId, string TarafUnvan, string TarafUtsNo)>
        BelgeOzetAsync(int belgeId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select b.tur, b.belge_no, b.belge_tarihi, coalesce(b.sube_id, 0),
                   coalesce(b.taraf_id, 0), coalesce(t.unvan, ''),
                   coalesce(t.uts_kurum_no, '')
              from public.belge b
              left join public.taraf t on t.id = b.taraf_id
             where b.id = @p0
            """, null, belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");
        return (o.GetInt16(0), o.GetString(1), o.GetDateTime(2), o.GetInt32(3),
                o.GetInt32(4), o.GetString(5), o.GetString(6));
    }

    public sealed record BelgeIzlemSatiri(int BelgeSatirId, int StokId, int SeriLotId,
        string StokAdi, string UrunNo, string SeriNo, string LotNo, decimal Adet,
        bool Bildirildi);

    /// <summary>
    /// Belgenin seri/lot dökümü + stok ÜTS ürün no'su + "bu seri/lot için
    /// bekleyen/başarılı bildirim var mı" işareti (çift gönderim raporu).
    /// </summary>
    public async Task<List<BelgeIzlemSatiri>> BelgeIzlemleriAsync(int belgeId, short tur,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select i.belge_satir_id, i.stok_id, i.seri_lot_id,
                   coalesce(s.ad, ''), coalesce(s.urun_no, ''),
                   coalesce(i.seri_no, ''), coalesce(i.lot_no, ''), i.adet,
                   exists(select 1 from public.uts_bildirim ub
                           where ub.belge_satir_id = i.belge_satir_id
                             and ub.tur = @p1
                             and coalesce(ub.seri_lot_id, 0) = i.seri_lot_id
                             and ub.durum in (0, 1)) as bildirildi
              from public.v_belge_satir_izlem i
              join public.stok s on s.id = i.stok_id
             where i.belge_id = @p0
             order by i.id
            """, null, belgeId, tur);
        var liste = new List<BelgeIzlemSatiri>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new BelgeIzlemSatiri(
                o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3),
                o.GetString(4), o.GetString(5), o.GetString(6), o.GetDecimal(7),
                o.GetBoolean(8)));
        return liste;
    }

    /// <summary>Bildirimin bağlı olduğu belge (iptal sonrası rozet için).</summary>
    public async Task<int?> BildirimBelgeIdAsync(int bildirimId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var d = await baglanti.TekDegerAsync<int?>(
            "select belge_id from public.uts_bildirim where id = @p0", null,
            new object?[] { bildirimId }, iptal);
        return d;
    }

    /// <summary>
    /// Belgenin ÜTS durumunu yeniden hesaplar (230): izlem satırlarının kaçı
    /// BAŞARILI bildirimli → 0 bildirilmedi / 1 kısmi / 2 tamam. Köprü
    /// gönderiminden ve iptalden sonra çağrılır.
    /// </summary>
    public async Task BelgeUtsDurumGuncelleAsync(int belgeId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            update public.belge b
               set uts_durum = alt.durum
              from (
                select case
                         when t.toplam = 0 or t.bildirilen = 0 then 0
                         when t.bildirilen >= t.toplam then 2
                         else 1
                       end as durum
                  from (
                    select count(*) as toplam,
                           count(*) filter (where exists (
                               select 1 from public.uts_bildirim ub
                                where ub.belge_satir_id = i.belge_satir_id
                                  and coalesce(ub.seri_lot_id, 0) = i.seri_lot_id
                                  and ub.durum = 1)) as bildirilen
                      from public.v_belge_satir_izlem i
                     where i.belge_id = @p0
                  ) t
              ) alt
             where b.id = @p0
            """, null, belgeId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    /// <summary>Alış köprüsü: askıdaki envanterde seri/lot eşleşmesi arar.</summary>
    public async Task<(int Id, string Bid, decimal AskiAdet)?> EnvanterEsleAsync(
        int subeId, string[] unoVaryantlari, string seriNo, string lotNo,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select id, verme_bildirim_id, aski_adet
              from public.uts_envanter
             where sube_id = @p0 and durum = 1
               and urun_no = any(@p1)
               and (@p2 = '' or seri_no = @p2)
               and (@p3 = '' or lot_no = @p3)
             order by bildirim_zamani nulls last, id
             limit 1
            """, baglanti);
        komut.Parameters.AddWithValue("p0", subeId);
        komut.Parameters.Add("p1", NpgsqlDbType.Array | NpgsqlDbType.Varchar)
             .Value = unoVaryantlari;
        komut.Parameters.AddWithValue("p2", seriNo);
        komut.Parameters.AddWithValue("p3", lotNo);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal)) return null;
        return (o.GetInt32(0), o.GetString(1), o.GetDecimal(2));
    }

    /// <summary>
    /// UNO → stok eşleşmesi: GTIN 13/14 iki varyantla stok.urun_no ve
    /// stok_barkod.barkod aranır (Delphi tuzağı).
    /// </summary>
    public async Task<int?> StokEsleAsync(string[] unoVaryantlari,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select s.id from public.stok s
             where s.urun_no = any(@p0)
            union
            select b.stok_id from public.stok_barkod b
             where b.barkod = any(@p0)
            limit 1
            """, baglanti);
        komut.Parameters.Add("p0", NpgsqlDbType.Array | NpgsqlDbType.Varchar)
             .Value = unoVaryantlari;
        var sonuc = await komut.ExecuteScalarAsync(iptal);
        return sonuc is null or DBNull ? null : Convert.ToInt32(sonuc);
    }
}
