using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record RolKullanicisi(int Id, string Kod, string Unvan, string Eposta,
    bool Aktif, DateTime? SonGiris, string RolAdi);

/// <summary>
/// Rol kartı "Kullanıcılar" sekmesi (kullanıcı: "rollerin içine kullanıcı
/// ekleyebileyim"). Bir kullanıcı TEK role bağlıdır (taraf_kullanici.rol_id
/// not null) - "role ekleme" o kullanıcının rolünü BU role çevirmektir;
/// "çıkarma" ise varsayılan sistem rolüne (yonetici) geri taşır.
/// </summary>
public sealed class RolKullaniciDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;
    private const int LogTabloRol = 903;

    public RolKullaniciDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>Role bağlı kullanıcılar.</summary>
    public async Task<IReadOnlyList<RolKullanicisi>> ListeleAsync(int rolId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select k.id, k.kod, coalesce(t.unvan, ''), k.eposta, k.aktif,
                   k.son_giris_tarihi, coalesce(r.ad, '')
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
              left join public.rol r on r.id = k.rol_id
             where k.rol_id = @p0
             order by k.aktif desc, t.unvan
            """, null, rolId);
        return await OkuAsync(komut, iptal);
    }

    /// <summary>
    /// Role eklenebilecek kullanıcılar: BU rolde olmayanlar. Arama boşsa ilk 50
    /// (353 kullanıcı var - hepsini listelemek anlamsız).
    /// </summary>
    public async Task<IReadOnlyList<RolKullanicisi>> AdaylarAsync(int rolId, string? arama,
        CancellationToken iptal = default)
    {
        var q = (arama ?? "").Trim();
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select k.id, k.kod, coalesce(t.unvan, ''), k.eposta, k.aktif,
                   k.son_giris_tarihi, coalesce(r.ad, '')
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
              left join public.rol r on r.id = k.rol_id
             where k.rol_id <> @p0
               and (@p1 = '' or t.unvan ilike '%' || @p1 || '%'
                             or k.kod ilike '%' || @p1 || '%'
                             or k.eposta ilike '%' || @p1 || '%')
             order by k.aktif desc, t.unvan
             limit 50
            """, null, rolId, q);
        return await OkuAsync(komut, iptal);
    }

    /// <summary>Kullanıcıyı bu role taşır (eski rolü ne olursa olsun).</summary>
    public async Task AtaAsync(int rolId, int kullaniciId, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // int (0 = kayit yok): nullable donusu merkezi olarak calisiyor ama
        //   burada 0 kontrolu hem daha basit hem cagriyi tipe bagimli birakmiyor.
        var eski = await baglanti.TekDegerAsync<int>(
            "select rol_id from public.taraf_kullanici where id = @p0", islem,
            new object?[] { kullaniciId }, iptal);
        if (eski == 0) throw GentegreHatasi.Bulunamadi("Kullanıcı bulunamadı.");

        await using (var k = baglanti.Komut("""
            update public.taraf_kullanici
               set rol_id = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, islem, kullaniciId, rolId, baglam.KullaniciId))
            await k.ExecuteNonQueryAsync(iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol, rolId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Kullanıcı role eklendi",
                ["kullaniciId"] = kullaniciId.ToString(),
                ["eskiRolId"] = eski.ToString(),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }

    /// <summary>
    /// Kullanıcıyı rolden çıkarır: rol boş bırakılamayacağı için VARSAYILAN
    /// sistem rolüne (yonetici) taşınır.
    /// </summary>
    public async Task<string> CikarAsync(int rolId, int kullaniciId, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var varsayilan = await baglanti.TekDegerAsync<int>(
            "select id from public.rol where kod = 'yonetici'", islem, null, iptal);
        if (varsayilan == 0)
            throw GentegreHatasi.IsKurali("Varsayılan sistem rolü (yonetici) bulunamadı.");
        if (varsayilan == rolId)
            throw GentegreHatasi.IsKurali(
                "Varsayılan sistem rolünden kullanıcı çıkarılamaz - kullanıcıyı başka bir role ekleyin.");

        await using (var k = baglanti.Komut("""
            update public.taraf_kullanici
               set rol_id = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0 and rol_id = @p3
            """, islem, kullaniciId, varsayilan, baglam.KullaniciId, rolId))
            await k.ExecuteNonQueryAsync(iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol, rolId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Kullanıcı rolden çıkarıldı",
                ["kullaniciId"] = kullaniciId.ToString(),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return "Kullanıcı varsayılan role (Yönetici) taşındı.";
    }

    private static async Task<IReadOnlyList<RolKullanicisi>> OkuAsync(NpgsqlCommand komut,
        CancellationToken iptal)
    {
        var liste = new List<RolKullanicisi>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new RolKullanicisi(o.GetInt32(0), o.GetString(1), o.GetString(2),
                o.GetString(3), o.GetInt16(4) == 1,
                o.IsDBNull(5) ? null : o.GetDateTime(5), o.GetString(6)));
        return liste;
    }
}
