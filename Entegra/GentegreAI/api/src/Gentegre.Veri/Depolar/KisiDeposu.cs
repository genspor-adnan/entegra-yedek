using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// İlgili kişi satırı (mockup: cari_karti.html Genel &gt; İlgili Kişiler). <c>Bagli</c> =
/// bu cariye HALEN bagli mi (false ise gecmiste bagliydi, "Ayrıldı" - taraf_gecmis'ten).
/// </summary>
public sealed record KisiKaydi(long Id, string Unvan, string? Telefon, string? Eposta, bool Aktif,
    string? Gorev, short? Departman, bool Bagli);

/// <summary>
/// Cari kartındaki "İlgili Kişiler" — ayrı bir tablo DEĞİL, semadaki tasarıma uyularak
/// (taraf.bag_id yorumu: "eski REHBERILETISIM.REHBERID") kişiler de birer <c>public.taraf</c>
/// satırı (kisi=1), üst carinin id'sine <c>bag_id</c> ile bağlı. Generic Detay-farkı
/// mekanizması (KartDeposu) kullanılmadı: unvan NOT NULL'ı otomatik doldurmak ve karta ait
/// silme/log akışını (aynı tabloya karşı çift DELETE) netleştirmek özel kod gerektiriyordu.
/// </summary>
public sealed class KisiDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;

    public KisiDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    public async Task<IReadOnlyList<KisiKaydi>> ListeleAsync(long tarafId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await ListeleAsync(baglanti, null, tarafId, iptal);
    }

    /// <summary>
    /// HALEN bagli kisiler (bag_id=tarafId) + GECMISTE bagli olup AYRILMIS kisiler
    /// (taraf_gecmis.cari_id=tarafId, kapali donem, su an baska/hic bagli degil) - "Ayrıldı"
    /// olarak KALICI gorunsun diye (kullanici: "gridden çıkarmasın, ayrıldı olarak dursun").
    /// </summary>
    private static async Task<IReadOnlyList<KisiKaydi>> ListeleAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, long tarafId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            select id, unvan, telefon, eposta, durum, gorev, departman, true as bagli
              from public.taraf
             where bag_id = @p0 and kisi = 1
            union all
            select id, unvan, telefon, eposta, durum, gorev, departman, false as bagli
              from public.taraf t
             where kisi = 1
               and (bag_id is null or bag_id <> @p0)
               and id in (select distinct kisi_id from public.taraf_gecmis
                           where cari_id = @p0 and bitis_tarihi is not null)
             order by bagli desc, unvan
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", tarafId);

        var sonuc = new List<KisiKaydi>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new KisiKaydi(
                okuyucu.GetInt64(0),
                okuyucu.GetString(1),
                okuyucu.IsDBNull(2) ? null : okuyucu.GetString(2),
                okuyucu.IsDBNull(3) ? null : okuyucu.GetString(3),
                okuyucu.GetInt16(4) == 1,
                okuyucu.IsDBNull(5) ? null : okuyucu.GetString(5),
                okuyucu.IsDBNull(6) ? null : okuyucu.GetInt16(6),
                okuyucu.GetBoolean(7)));
        return sonuc;
    }

    /// <summary>Bu kisi-cari cifti icin ACIK (bitis_tarihi=null) donemi bugun kapatir.</summary>
    private static async Task GecmisKapatAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        long kisiId, long cariId, int kullaniciId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            update public.taraf_gecmis set bitis_tarihi = current_date, degistiren = @p0
            where kisi_id = @p1 and cari_id = @p2 and bitis_tarihi is null
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", kullaniciId);
        komut.Parameters.AddWithValue("p1", kisiId);
        komut.Parameters.AddWithValue("p2", cariId);
        var etkilenen = await komut.ExecuteNonQueryAsync(iptal);

        // Acik donem hic yoktu (eski/legacy baglanti, hic izlenmemis) - yine de "gecmiste
        // bagliydi" bilgisini kaybetmeyelim, baslangici bilinmeyen kapali bir satir ekle.
        if (etkilenen == 0)
        {
            await using var ekle = new NpgsqlCommand("""
                insert into public.taraf_gecmis (kisi_id, cari_id, baslama_tarihi, bitis_tarihi, ekleyen)
                values (@p0, @p1, null, current_date, @p2)
                """, baglanti, islem);
            ekle.Parameters.AddWithValue("p0", kisiId);
            ekle.Parameters.AddWithValue("p1", cariId);
            ekle.Parameters.AddWithValue("p2", kullaniciId);
            await ekle.ExecuteNonQueryAsync(iptal);
        }
    }

    /// <summary>Bu kisi-cari cifti icin yeni ACIK donem baslatir (zaten acik varsa dokunmaz).</summary>
    private static async Task GecmisAcAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        long kisiId, long cariId, int kullaniciId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            insert into public.taraf_gecmis (kisi_id, cari_id, baslama_tarihi, ekleyen)
            values (@p0, @p1, current_date, @p2)
            on conflict (kisi_id, cari_id) where bitis_tarihi is null do nothing
            """, baglanti, islem);
        komut.Parameters.AddWithValue("p0", kisiId);
        komut.Parameters.AddWithValue("p1", cariId);
        komut.Parameters.AddWithValue("p2", kullaniciId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    private static async Task<(int SubeId, short Musteri, short Tedarikci)> UstTarafAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, long tarafId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select sube_id, musteri, tedarikci from public.taraf where id = @p0", baglanti, islem);
        komut.Parameters.AddWithValue("p0", tarafId);
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        if (!await okuyucu.ReadAsync(iptal))
            throw GentegreHatasi.Bulunamadi("Cari bulunamadi.");
        return (okuyucu.GetInt32(0), okuyucu.GetInt16(1), okuyucu.GetInt16(2));
    }

    public async Task<IReadOnlyList<KisiKaydi>> EkleAsync(long tarafId, string unvan,
        string? telefon, string? eposta, string? gorev, short? departman,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(unvan))
            throw GentegreHatasi.Dogrulama("Unvan zorunlu.", new AlanHatasi("unvan", "Bos birakilamaz."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var ust = await UstTarafAsync(baglanti, islem, tarafId, iptal);

        long yeniId;
        await using (var komut = new NpgsqlCommand("""
            insert into public.taraf
                (unvan, telefon, eposta, gorev, departman, bag_id, kisi, musteri, tedarikci, durum, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6, @p7, 1, @p8, @p9)
            returning id
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", unvan.Trim());
            komut.Parameters.AddWithValue("p1", (object?)telefon ?? DBNull.Value);
            komut.Parameters.AddWithValue("p2", (object?)eposta ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", (object?)gorev ?? DBNull.Value);
            komut.Parameters.AddWithValue("p4", (object?)departman ?? DBNull.Value);
            komut.Parameters.AddWithValue("p5", tarafId);
            komut.Parameters.AddWithValue("p6", ust.Musteri);
            komut.Parameters.AddWithValue("p7", ust.Tedarikci);
            komut.Parameters.AddWithValue("p8", ust.SubeId);
            komut.Parameters.AddWithValue("p9", baglam.KullaniciId);
            yeniId = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal));
        }

        // Kod verilmedi (bu hizli-ekle akisinda kod hic sorulmuyor) - ID numarasi kod
        // olarak atanir (kullanici: "kod verilmediyse ID no atasın").
        await using (var kodKomut = new NpgsqlCommand(
            "update public.taraf set kod = @p0 where id = @p1", baglanti, islem))
        {
            kodKomut.Parameters.AddWithValue("p0", yeniId.ToString(System.Globalization.CultureInfo.InvariantCulture));
            kodKomut.Parameters.AddWithValue("p1", yeniId);
            await kodKomut.ExecuteNonQueryAsync(iptal);
        }

        await GecmisAcAsync(baglanti, islem, yeniId, tarafId, baglam.KullaniciId, iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Ekle, KartTabloId.Cari, yeniId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, object?> {
                ["unvan"] = unvan, ["telefon"] = telefon, ["eposta"] = eposta,
                ["gorev"] = gorev, ["departman"] = departman,
            },
            ustTabloId: KartTabloId.Cari, ustKayitId: tarafId, tarafId: (int)yeniId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return await ListeleAsync(tarafId, iptal);
    }

    public async Task<IReadOnlyList<KisiKaydi>> GuncelleAsync(long tarafId, long kisiId,
        string unvan, string? telefon, string? eposta, bool aktif, string? gorev, short? departman,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (string.IsNullOrWhiteSpace(unvan))
            throw GentegreHatasi.Dogrulama("Unvan zorunlu.", new AlanHatasi("unvan", "Bos birakilamaz."));

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        Dictionary<string, object?> eski;
        await using (var kontrol = new NpgsqlCommand(
            "select unvan, telefon, eposta, durum, gorev, departman from public.taraf " +
            "where id = @p0 and bag_id = @p1 and kisi = 1", baglanti, islem))
        {
            kontrol.Parameters.AddWithValue("p0", kisiId);
            kontrol.Parameters.AddWithValue("p1", tarafId);
            await using var okuyucu = await kontrol.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Kisi bulunamadi.");
            eski = new Dictionary<string, object?>
            {
                ["unvan"] = okuyucu.GetString(0),
                ["telefon"] = okuyucu.IsDBNull(1) ? null : okuyucu.GetString(1),
                ["eposta"] = okuyucu.IsDBNull(2) ? null : okuyucu.GetString(2),
                ["durum"] = okuyucu.GetInt16(3),
                ["gorev"] = okuyucu.IsDBNull(4) ? null : okuyucu.GetString(4),
                ["departman"] = okuyucu.IsDBNull(5) ? null : okuyucu.GetInt16(5),
            };
        }

        await using (var komut = new NpgsqlCommand("""
            update public.taraf set unvan = @p0, telefon = @p1, eposta = @p2, durum = @p3,
                   gorev = @p4, departman = @p5, degistiren = @p6
            where id = @p7 and bag_id = @p8 and kisi = 1
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", unvan.Trim());
            komut.Parameters.AddWithValue("p1", (object?)telefon ?? DBNull.Value);
            komut.Parameters.AddWithValue("p2", (object?)eposta ?? DBNull.Value);
            komut.Parameters.AddWithValue("p3", (short)(aktif ? 1 : 0));
            komut.Parameters.AddWithValue("p4", (object?)gorev ?? DBNull.Value);
            komut.Parameters.AddWithValue("p5", (object?)departman ?? DBNull.Value);
            komut.Parameters.AddWithValue("p6", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p7", kisiId);
            komut.Parameters.AddWithValue("p8", tarafId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        var yeni = new Dictionary<string, object?>
        {
            ["unvan"] = unvan, ["telefon"] = telefon, ["eposta"] = eposta,
            ["durum"] = (short)(aktif ? 1 : 0), ["gorev"] = gorev, ["departman"] = departman,
        };
        var fark = LogDeposu.Fark(eski, yeni);
        if (fark is not null)
            await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, KartTabloId.Cari, kisiId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip, fark,
                ustTabloId: KartTabloId.Cari, ustKayitId: tarafId, tarafId: (int)kisiId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return await ListeleAsync(tarafId, iptal);
    }

    public async Task SilAsync(long tarafId, long kisiId, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        Dictionary<string, object?> yedek;
        await using (var kontrol = new NpgsqlCommand(
            "select unvan, telefon, eposta, durum from public.taraf " +
            "where id = @p0 and bag_id = @p1 and kisi = 1", baglanti, islem))
        {
            kontrol.Parameters.AddWithValue("p0", kisiId);
            kontrol.Parameters.AddWithValue("p1", tarafId);
            await using var okuyucu = await kontrol.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Kisi bulunamadi.");
            yedek = new Dictionary<string, object?>
            {
                ["unvan"] = okuyucu.GetString(0),
                ["telefon"] = okuyucu.IsDBNull(1) ? null : okuyucu.GetString(1),
                ["eposta"] = okuyucu.IsDBNull(2) ? null : okuyucu.GetString(2),
                ["durum"] = okuyucu.GetInt16(3),
            };
        }

        // SILME LOGU DELETE'TEN ONCE (ULog kurali - "Geri Al" satirin tam halini kullanir).
        await _log.YazAsync(baglanti, islem, LogIslemi.Sil, KartTabloId.Cari, kisiId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip, yedek,
            ustTabloId: KartTabloId.Cari, ustKayitId: tarafId, tarafId: (int)kisiId, iptal: iptal);

        await using (var komut = new NpgsqlCommand(
            "delete from public.taraf where id = @p0 and bag_id = @p1 and kisi = 1", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", kisiId);
            komut.Parameters.AddWithValue("p1", tarafId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
    }

    /// <summary>
    /// Kisiyi bu cariden KOPAR (bag_id = null) - SilAsync'ten farkli, kisi TABLODAN SILINMEZ
    /// (kullanici: "sil kisiyi db'den silmeyecek, sadece bagini bu cariden koparacak"). Cari
    /// kartindaki İlgili Kişiler grid'inin "Sil" ikonu bunu cagirir.
    /// </summary>
    public async Task<IReadOnlyList<KisiKaydi>> KoparAsync(long tarafId, long kisiId,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using (var komut = new NpgsqlCommand(
            "update public.taraf set bag_id = null, degistiren = @p0 " +
            "where id = @p1 and bag_id = @p2 and kisi = 1", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p1", kisiId);
            komut.Parameters.AddWithValue("p2", tarafId);
            var etkilenen = await komut.ExecuteNonQueryAsync(iptal);
            if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("Kisi bulunamadi.");
        }

        await GecmisKapatAsync(baglanti, islem, kisiId, tarafId, baglam.KullaniciId, iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, KartTabloId.Cari, kisiId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, object?> { ["bag_id"] = $"{tarafId} -> (kopar)" },
            ustTabloId: KartTabloId.Cari, ustKayitId: tarafId, tarafId: (int)kisiId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return await ListeleAsync(tarafId, iptal);
    }

    /// <summary>
    /// VAR OLAN bir kisiyi bu cariye bagla (TarafArama'dan secilen kisinin bag_id'sini
    /// degistirir) - yeni kisi OLUSTURMAZ, EkleAsync'ten farkli. Kisi kartinda "Cariye Bağla"
    /// tersi: cari kartinda "Kişi Ekle" (mevcut bir kisiyi bu cariye tasi).
    /// </summary>
    public async Task<IReadOnlyList<KisiKaydi>> BaglaAsync(long tarafId, long kisiId,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        int? eskiBagId;
        await using (var kontrol = new NpgsqlCommand(
            "select bag_id from public.taraf where id = @p0 and kisi = 1", baglanti, islem))
        {
            kontrol.Parameters.AddWithValue("p0", kisiId);
            await using var okuyucu = await kontrol.ExecuteReaderAsync(iptal);
            if (!await okuyucu.ReadAsync(iptal))
                throw GentegreHatasi.Bulunamadi("Kisi bulunamadi.");
            eskiBagId = okuyucu.IsDBNull(0) ? null : okuyucu.GetInt32(0);
        }

        // Kural: cari karti > İlgili Kişiler > Kişi Ekle akışı SADECE bağı boş kişiyi
        // ekleyebilir - kişinin carisi doluysa (baska bir cariye zaten bagliysa) sessizce
        // TASIMAK yerine engellenir, kullaniciya mesaj verilir. (Kisi kartinin KENDI
        // "Cariye Bağla"sı bu metodu cagirmaz - GenForm.tsx orada formu PUT ile kaydeder,
        // bilerek yeniden baglama/tasima yapabilir.)
        if (eskiBagId.HasValue)
            throw GentegreHatasi.Dogrulama("Bu kişi zaten bir cariye bağlı, önce o carideki bağını koparın.",
                new AlanHatasi("bagId", "Kişinin carisi dolu."));

        await using (var komut = new NpgsqlCommand(
            "update public.taraf set bag_id = @p0, degistiren = @p1 where id = @p2 and kisi = 1", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", tarafId);
            komut.Parameters.AddWithValue("p1", baglam.KullaniciId);
            komut.Parameters.AddWithValue("p2", kisiId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        if (eskiBagId.HasValue && eskiBagId.Value != tarafId)
            await GecmisKapatAsync(baglanti, islem, kisiId, eskiBagId.Value, baglam.KullaniciId, iptal);
        await GecmisAcAsync(baglanti, islem, kisiId, tarafId, baglam.KullaniciId, iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, KartTabloId.Cari, kisiId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, object?> { ["bag_id"] = $"{eskiBagId} -> {tarafId}" },
            ustTabloId: KartTabloId.Cari, ustKayitId: tarafId, tarafId: (int)kisiId, iptal: iptal);

        await islem.CommitAsync(iptal);
        return await ListeleAsync(tarafId, iptal);
    }

}

internal static class KartTabloId
{
    public const int Cari = 71; // GENINI -11110: 71 = Cari (KartKatalogu.Cari LogTabloId ile ayni)
}
