using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>Kullanıcının bir şubedeki durumu (yetkisiz şube de listelenir).</summary>
public sealed record KullaniciSubeSatiri(int SubeId, string SubeAdi, bool Yetkili,
    bool Varsayilan, bool Yazma);

/// <summary>
/// KULLANICI - ŞUBE yetkisi (kullanıcı: "fotoğrafın altına yetkili şubeleri
/// getir, rolden kaldır tekrar").
///
/// Model son hali: ROL "ne yapabilir"i (yetki matrisi), bu tablo "nerede
/// çalışır"ı taşır ve KİŞİYE bağlıdır - aynı roldeki iki kişi farklı
/// şubelerde çalışabiliyor. 234'te şubeler role taşınmıştı (rol_sube);
/// tablo duruyor ama giriş akışı yine kullanici_sube okuyor.
/// </summary>
public sealed class KullaniciSubeDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;
    private const int LogTabloKullaniciSube = 904;

    public KullaniciSubeDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>Tüm aktif şubeler + bu kullanıcının her birindeki durumu.</summary>
    public async Task<IReadOnlyList<KullaniciSubeSatiri>> ListeleAsync(int kartId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut(
            "select s.id, s.ad, " +
            "       case when rs.taraf_id is null then 0 else 1 end, " +
            "       coalesce(rs.varsayilan, 0), coalesce(rs.yazma, 1) " +
            "  from public.sube s " +
            "  left join public.kullanici_sube rs on rs.sube_id = s.id and rs.taraf_id = @p0 " +
            " where s.aktif = 1 " +
            " order by s.tur, s.ad", null, kartId);

        var liste = new List<KullaniciSubeSatiri>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new KullaniciSubeSatiri(o.GetInt32(0), o.GetString(1),
                o.GetInt32(2) == 1, o.GetInt16(3) == 1, o.GetInt16(4) == 1));
        return liste;
    }

    public sealed record SubeIstegi(int SubeId, bool Yetkili, bool Varsayilan, bool Yazma);

    /// <summary>
    /// Kullanıcının şubelerini topluca yazar. Kurallar: en az bir şube (yoksa
    /// giriş yapamaz), varsayılan en fazla bir (kısmi indeks
    /// ux_kullanici_sube_varsayilan), varsayılan seçilmediyse ilk yetkili şube.
    /// </summary>
    public async Task KaydetAsync(int kartId, IReadOnlyList<SubeIstegi> satirlar,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        // Kisinin CALISTIGI subesi (taraf.sube_id) her zaman yetkilidir
        //   (kullanici): ekran kilitli gonderiyor, sunucu da garantiler.
        var calistigi = await _veri.TekDegerAsync<int>(
            "select coalesce(sube_id, 0) from public.taraf where id = @p0",
            new object?[] { kartId }, iptal);

        var yetkililer = satirlar.Where(s => s.Yetkili).ToList();
        if (calistigi > 0 && yetkililer.All(s => s.SubeId != calistigi))
            yetkililer.Add(new SubeIstegi(calistigi, true, false, true));
        if (yetkililer.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Kullanıcı en az bir şubede yetkili olmalı - yoksa hiçbir şubeye giremez.");
        // VARSAYILAN = calistigi sube (kullanici: "vars kolonu kaldir, cunku
        //   calistigi sube zorunlu varsayilandir"); tanimli degilse ilk yetkili.
        var varsayilanId = calistigi > 0 && yetkililer.Any(s => s.SubeId == calistigi)
            ? calistigi : yetkililer[0].SubeId;

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // Once TUM satirlar silinir, sonra yeniden yazilir: kismi varsayilan
        //   indeksi sira bagimli guncellemede ("A varsayilandan cikmadan B
        //   varsayilan olmaz") catisiyordu.
        await using (var k = baglanti.Komut(
            "delete from public.kullanici_sube where taraf_id = @p0", islem, kartId))
            await k.ExecuteNonQueryAsync(iptal);

        foreach (var s in yetkililer)
        {
            await using var k = baglanti.Komut(
                "insert into public.kullanici_sube (taraf_id, sube_id, varsayilan, yazma, ekleyen) " +
                "values (@p0, @p1, @p2, @p3, @p4)", islem,
                kartId, s.SubeId, (short)(s.SubeId == varsayilanId ? 1 : 0),
                (short)(s.Yazma ? 1 : 0), baglam.KullaniciId);
            await k.ExecuteNonQueryAsync(iptal);
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloKullaniciSube,
            kartId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Kullanıcı şubeleri güncellendi",
                ["subeler"] = string.Join(", ", yetkililer.Select(s =>
                    s.SubeId + (s.SubeId == varsayilanId ? "*" : "") + (s.Yazma ? "" : " (okur)"))),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }
}
