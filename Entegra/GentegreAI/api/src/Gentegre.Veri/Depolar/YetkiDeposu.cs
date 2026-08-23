using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Veri.Depolar;

public sealed class YetkiDeposu
{
    private readonly VeriKaynagi _veri;
    public YetkiDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>
    /// Yetki listesi token'a GOMULMEZ (API §1.1) - her istekte rolden cozulur.
    /// DB tarafinda tek kapi: fn_kullanici_yetkileri.
    /// </summary>
    public Task<List<YetkiKaydi>> YetkilerAsync(int kullaniciId, CancellationToken iptal = default)
        => _veri.ListeAsync("select * from public.fn_kullanici_yetkileri(@p0)",
            new object?[] { kullaniciId },
            o => new YetkiKaydi(
                o.Metin("yetki_kod"),
                (short)o.Sayi("tur"),
                o.Bayrak("gor"), o.Bayrak("ekle"), o.Bayrak("degistir"), o.Bayrak("sil")),
            iptal);

    /// <summary>Alan yetkileri: satir YOKSA alan serbest, izin 0 = gizle.</summary>
    public Task<List<AlanYetkisi>> AlanYetkileriAsync(int kullaniciId, CancellationToken iptal = default)
        => _veri.ListeAsync("""
            select ay.kaynak, ay.alan, ay.izin
              from public.taraf_kullanici k
              join public.rol_alan_yetki ay on ay.rol_id = k.rol_id
             where k.id = @p0
            """, new object?[] { kullaniciId },
            o => new AlanYetkisi(o.Metin("kaynak"), o.Metin("alan"), (short)o.Sayi("izin")),
            iptal);

    /// <summary>JWT'deki yetkiSurumu ile karsilastirilir; eskiyse yetki yeniden cozulur.</summary>
    public Task<long> YetkiSurumuAsync(int kullaniciId, CancellationToken iptal = default)
        => _veri.TekDegerAsync<long>("""
            select r.yetki_surumu from public.taraf_kullanici k
              join public.rol r on r.id = k.rol_id
             where k.id = @p0
            """, new object?[] { kullaniciId }, iptal);
}


