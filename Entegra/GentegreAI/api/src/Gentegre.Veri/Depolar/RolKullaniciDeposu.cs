using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record RolKullanicisi(int Id, string Kod, string Unvan, string Eposta,
    string Departman, string Gorev, string Telefon, string Sube,
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
            select k.id, k.kod, coalesce(t.unvan, ''), k.eposta,
                   coalesce((select dp.ad from public.departman dp
                              where dp.id = t.departman), ''),
                   coalesce((select d.ad from public.kod_deger d
                              join public.kod_liste l on l.id = d.liste_id
                             where l.kod = 'taraf.gorev'
                               and d.deger = t.gorev_id), t.gorev, ''),
                   coalesce(nullif(t.telefon, ''), nullif(t.cep_tel, ''),
                            k.cep_tel, ''),
                   coalesce(sb.ad, ''),
                   k.aktif, k.son_giris_tarihi, coalesce(r.ad, '')
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
              left join public.sube sb on sb.id = t.sube_id
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
            select k.id, k.kod, coalesce(t.unvan, ''), k.eposta,
                   coalesce((select dp.ad from public.departman dp
                              where dp.id = t.departman), ''),
                   coalesce((select d.ad from public.kod_deger d
                              join public.kod_liste l on l.id = d.liste_id
                             where l.kod = 'taraf.gorev'
                               and d.deger = t.gorev_id), t.gorev, ''),
                   coalesce(nullif(t.telefon, ''), nullif(t.cep_tel, ''),
                            k.cep_tel, ''),
                   coalesce(sb.ad, ''),
                   k.aktif, k.son_giris_tarihi, coalesce(r.ad, '')
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
              left join public.sube sb on sb.id = t.sube_id
              left join public.rol r on r.id = k.rol_id
             where k.rol_id <> @p0
               and (@p1 = '' or t.unvan ilike '%' || @p1 || '%'
                             or k.kod ilike '%' || @p1 || '%'
                             or k.eposta ilike '%' || @p1 || '%'
                             or t.gorev ilike '%' || @p1 || '%')
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

    /// <summary>
    /// Personel/kişi kartından kullanıcı rolü (kullanıcı: "personel kartında
    /// rolü görebilmem ve istersem değiştirebilmem lazım"). Kartın kullanıcı
    /// hesabı yoksa KullaniciVar=false döner - ekran "hesabı yok" der.
    /// </summary>
    public async Task<(bool KullaniciVar, int RolId, string RolAdi,
                       IReadOnlyList<(int Id, string Ad)> Roller)>
        KartRolOkuAsync(int kartId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var roller = new List<(int, string)>();
        await using (var k = baglanti.Komut(
            "select id, ad from public.rol where aktif = 1 order by ad", null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) roller.Add((o.GetInt32(0), o.GetString(1)));

        await using var komut = baglanti.Komut(
            "select k.rol_id, coalesce(r.ad, '') " +
            "  from public.taraf_kullanici k " +
            "  left join public.rol r on r.id = k.rol_id " +
            " where k.id = @p0", null, kartId);
        await using var oku = await komut.ExecuteReaderAsync(iptal);
        if (!await oku.ReadAsync(iptal)) return (false, 0, "", roller);
        return (true, oku.GetInt32(0), oku.GetString(1), roller);
    }

    /// <summary>Karttan rol değiştirme - AtaAsync ile aynı iz (islem_log).</summary>
    public async Task KartRolDegistirAsync(int kartId, int rolId, YazmaBaglami baglam,
        CancellationToken iptal = default)
        => await AtaAsync(rolId, kartId, baglam, iptal);

    private static async Task<IReadOnlyList<RolKullanicisi>> OkuAsync(NpgsqlCommand komut,
        CancellationToken iptal)
    {
        var liste = new List<RolKullanicisi>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new RolKullanicisi(o.GetInt32(0), o.GetString(1), o.GetString(2),
                o.GetString(3), o.GetString(4), o.GetString(5), o.GetString(6),
                o.GetString(7), o.GetInt16(8) == 1,
                o.IsDBNull(9) ? null : o.GetDateTime(9), o.GetString(10)));
        return liste;
    }
}
