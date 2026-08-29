using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Rolün bir şubedeki durumu (yetkisiz şube de listelenir).</summary>
public sealed record RolSubeSatiri(int SubeId, string SubeAdi, bool Yetkili,
    bool Varsayilan, bool Yazma);

/// <summary>
/// ROL - ŞUBE yetkisi (kullanıcı kararı: "şube kısıtını personel değil role
/// ata, personel yetkiyi her zaman rolden alır").
///
/// Rol hem "ne yapabilir" (yetki matrisi) hem "nerede çalışır" (bu tablo)
/// bilgisini taşır; kullanıcının şube listesi giriş anında rolünden çözülür
/// (KullaniciDeposu.SubeleriAsync). Eski kullanıcı bazlı `kullanici_sube`
/// tablosu veri olarak duruyor ama artık okunmuyor (234).
/// </summary>
public sealed class KullaniciSubeDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;
    private const int LogTabloRol = 903;

    public KullaniciSubeDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>Tüm aktif şubeler + bu rolün her birindeki durumu.</summary>
    public async Task<IReadOnlyList<RolSubeSatiri>> ListeleAsync(int rolId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select s.id, s.ad, " +
            "       case when rs.rol_id is null then 0 else 1 end, " +
            "       coalesce(rs.varsayilan, 0), coalesce(rs.yazma, 1) " +
            "  from public.sube s " +
            "  left join public.rol_sube rs on rs.sube_id = s.id and rs.rol_id = @p0 " +
            " where s.aktif = 1 " +
            " order by s.tur, s.ad", null, rolId);

        var liste = new List<RolSubeSatiri>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new RolSubeSatiri(o.GetInt32(0), o.GetString(1),
                o.GetInt32(2) == 1, o.GetInt16(3) == 1, o.GetInt16(4) == 1));
        return liste;
    }

    public sealed record SubeIstegi(int SubeId, bool Yetkili, bool Varsayilan, bool Yazma);

    /// <summary>
    /// Rolün şubelerini topluca yazar. Kurallar: en az bir şube (yoksa o rolün
    /// kullanıcıları hiçbir şubeye giremez), varsayılan en fazla bir (kısmi
    /// indeks ux_rol_sube_varsayilan), varsayılan seçilmediyse ilk yetkili şube.
    /// </summary>
    public async Task KaydetAsync(int rolId, IReadOnlyList<SubeIstegi> satirlar,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        var yetkililer = satirlar.Where(s => s.Yetkili).ToList();
        if (yetkililer.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Rol en az bir şubede yetkili olmalı - yoksa bu roldeki kullanıcılar hiçbir şubeye giremez.");
        var varsayilanlar = yetkililer.Where(s => s.Varsayilan).ToList();
        if (varsayilanlar.Count > 1)
            throw GentegreHatasi.IsKurali("Yalnız bir şube varsayılan olabilir.");

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // Once TUM satirlar silinir, sonra yeniden yazilir: kismi varsayilan
        //   indeksi sira bagimli guncellemede ("A varsayilandan cikmadan B
        //   varsayilan olmaz") catisiyordu.
        await using (var k = baglanti.Komut(
            "delete from public.rol_sube where rol_id = @p0", islem, rolId))
            await k.ExecuteNonQueryAsync(iptal);

        var varsayilanId = varsayilanlar.Count == 1
            ? varsayilanlar[0].SubeId : yetkililer[0].SubeId;

        foreach (var s in yetkililer)
        {
            await using var k = baglanti.Komut(
                "insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen) " +
                "values (@p0, @p1, @p2, @p3, @p4)", islem,
                rolId, s.SubeId, (short)(s.SubeId == varsayilanId ? 1 : 0),
                (short)(s.Yazma ? 1 : 0), baglam.KullaniciId);
            await k.ExecuteNonQueryAsync(iptal);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol,
            rolId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Rol şubeleri güncellendi",
                ["subeler"] = string.Join(", ", yetkililer.Select(s =>
                    s.SubeId + (s.SubeId == varsayilanId ? "*" : "") + (s.Yazma ? "" : " (okur)"))),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }
}
