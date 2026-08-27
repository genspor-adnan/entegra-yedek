using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record YetkiSatiri(int YetkiId, string Kod, string Ad, string Grup,
    bool Gor, bool Ekle, bool Degistir, bool Sil);

public sealed record YetkiGuncelleIstegi(int YetkiId, bool Gor, bool Ekle, bool Degistir, bool Sil);

/// <summary>
/// Rol > Yetki matrisi (kullanici: "role verdigimiz yetki dogrultusunda menuleri Gorme/
/// Ekleme/Duzeltme/Silme islem yapabilirdi" - eski sistemdeki rol/yetki modeli). `yetki`
/// tablosundaki HER satir icin bu rolun `rol_yetki` degeri (yoksa hepsi false) doner -
/// generic Detay mekanizmasina UYMAZ (satir ekle/sil degil, SABIT yetki listesi uzerinde
/// checkbox matrisi), o yuzden ozel depo/uc.
/// </summary>
public sealed class RolYetkiDeposu
{
    private readonly VeriKaynagi _veri;

    public RolYetkiDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<IReadOnlyList<YetkiSatiri>> ListeleAsync(int rolId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select y.id, y.kod, y.ad, y.grup,
                   coalesce(ry.gor, 0), coalesce(ry.ekle, 0), coalesce(ry.degistir, 0), coalesce(ry.sil, 0)
              from public.yetki y
              left join public.rol_yetki ry on ry.yetki_id = y.id and ry.rol_id = @p0
             where y.aktif = 1
             order by y.sira, y.ad
            """, null,
            rolId);

        var sonuc = new List<YetkiSatiri>();
        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        while (await okuyucu.ReadAsync(iptal))
            sonuc.Add(new YetkiSatiri(
                okuyucu.GetInt32(0), okuyucu.GetString(1), okuyucu.GetString(2), okuyucu.GetString(3),
                okuyucu.GetInt16(4) == 1, okuyucu.GetInt16(5) == 1,
                okuyucu.GetInt16(6) == 1, okuyucu.GetInt16(7) == 1));
        return sonuc;
    }

    public async Task<IReadOnlyList<YetkiSatiri>> KaydetAsync(int rolId,
        IReadOnlyList<YetkiGuncelleIstegi> satirlar, YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        foreach (var s in satirlar)
        {
            await using var komut = baglanti.Komut("""
                insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6)
                on conflict (rol_id, yetki_id) do update set
                    gor = excluded.gor, ekle = excluded.ekle, degistir = excluded.degistir, sil = excluded.sil,
                    degistiren = @p6
                """, islem,
                rolId, s.YetkiId, (short)(s.Gor ? 1 : 0), (short)(s.Ekle ? 1 : 0), (short)(s.Degistir ? 1 : 0), (short)(s.Sil ? 1 : 0), baglam.KullaniciId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        return await ListeleAsync(rolId, iptal);
    }
}
