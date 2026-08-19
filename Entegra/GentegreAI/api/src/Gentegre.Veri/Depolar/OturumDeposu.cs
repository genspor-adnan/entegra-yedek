namespace Gentegre.Veri.Depolar;

public sealed record OturumKaydi(
    long Id,
    int KullaniciId,
    Guid AileId,
    DateTime BitisTarihi,
    DateTime? IptalTarihi,
    string IptalNedeni,
    int? SubeId);

/// <summary>
/// Refresh token kayitlari. Token'in KENDISI degil SHA-256 ozeti saklanir.
/// Rotation: yenilemede eski satir 'yenilendi' ile kapanir, yenisi ayni aile_id
/// ile acilir. Iptal edilmis bir token tekrar kullanilirsa AILE komple iptal
/// edilir (token calinmis kabul edilir).
/// </summary>
public sealed class OturumDeposu
{
    private readonly VeriKaynagi _veri;
    public OturumDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<(long Id, Guid AileId)> AcAsync(int kullaniciId, string refreshHash,
        DateTime bitis, Guid? aileId, long? oncekiId, int? subeId, string ip, string istemci,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = _veri.Komut(baglanti, """
            insert into public.oturum
                (kullanici_id, aile_id, refresh_hash, onceki_oturum_id, sube_id, ip, istemci, bitis_tarihi)
            values (@p0, coalesce(@p1, gen_random_uuid()), @p2, @p3, @p4, @p5, @p6, @p7)
            returning id, aile_id
            """, new object?[] { kullaniciId, aileId, refreshHash, oncekiId, subeId, ip, istemci, bitis });

        await using var okuyucu = await komut.ExecuteReaderAsync(iptal);
        await okuyucu.ReadAsync(iptal);
        return (okuyucu.GetInt64(0), okuyucu.GetGuid(1));
    }

    public Task<OturumKaydi?> HashIleBulAsync(string refreshHash, CancellationToken iptal = default)
        => _veri.TekAsync("""
            select id, kullanici_id, aile_id, bitis_tarihi, iptal_tarihi, iptal_nedeni, sube_id
              from public.oturum where refresh_hash = @p0
            """, new object?[] { refreshHash },
            o => new OturumKaydi(o.GetInt64(0), o.Sayi("kullanici_id"), o.GetGuid(2),
                                 o.GetDateTime(3), o.Tarih("iptal_tarihi"), o.Metin("iptal_nedeni"),
                                 o.SayiNull("sube_id")),
            iptal);

    public Task IptalAsync(long id, string neden, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.oturum
               set iptal_tarihi = now()::timestamp, iptal_nedeni = @p1
             where id = @p0 and iptal_tarihi is null
            """, new object?[] { id, neden }, iptal);

    /// <summary>Tekrar kullanim tespiti: ailenin acik tum oturumlarini kapat.</summary>
    public Task AileIptalAsync(Guid aileId, string neden, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.oturum
               set iptal_tarihi = now()::timestamp, iptal_nedeni = @p1
             where aile_id = @p0 and iptal_tarihi is null
            """, new object?[] { aileId, neden }, iptal);

    public Task KullaniciOturumlariniKapatAsync(int kullaniciId, string neden,
                                                CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.oturum
               set iptal_tarihi = now()::timestamp, iptal_nedeni = @p1
             where kullanici_id = @p0 and iptal_tarihi is null
            """, new object?[] { kullaniciId, neden }, iptal);

    /// <summary>Aktif sube degisince oturumda da guncellenir - yenilemede ayni sube gelsin.</summary>
    public Task SubeGuncelleAsync(string refreshHash, int subeId, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.oturum set sube_id = @p1
             where refresh_hash = @p0 and iptal_tarihi is null
            """, new object?[] { refreshHash, subeId }, iptal);

    public Task KullanildiAsync(long id, CancellationToken iptal = default)
        => _veri.CalistirAsync("update public.oturum set son_kullanim = now()::timestamp where id = @p0",
            new object?[] { id }, iptal);
}
