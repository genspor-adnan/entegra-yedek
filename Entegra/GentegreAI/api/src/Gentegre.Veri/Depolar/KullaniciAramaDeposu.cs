namespace Gentegre.Veri.Depolar;

/// <summary>
/// Eski KULLANICI_ARAMA karsiligi: kart acilis/ekleme sikligini tutar (Son/Sik Aranan).
/// </summary>
public sealed class KullaniciAramaDeposu
{
    private readonly VeriKaynagi _veri;
    public KullaniciAramaDeposu(VeriKaynagi veri) => _veri = veri;

    private const string UpsertSql = """
        insert into public.kullanici_arama (kullanici_id, kaynak, kayit_id, say, son_tarih)
        values (@p0, @p1, @p2, 1, now())
        on conflict (kullanici_id, kaynak, kayit_id)
        do update set say = public.kullanici_arama.say + 1, son_tarih = now()
        """;

    public Task IsaretleAsync(int kullaniciId, string kaynak, long kayitId, CancellationToken iptal = default)
        => _veri.CalistirAsync(UpsertSql, new object?[] { kullaniciId, kaynak, kayitId }, iptal);
}
