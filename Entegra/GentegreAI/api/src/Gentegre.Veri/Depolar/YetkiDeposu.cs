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
                o.Bayrak("gor"), o.Bayrak("ekle"), o.Bayrak("degistir"), o.Bayrak("sil"),
                o.Metin("deger")),
            iptal);

    /// <summary>
    /// Alan yetkileri: satir YOKSA alan serbest, izin 0 = gizle. Cok rolde
    /// (665) kisitlamayi tasimayan tek bir rol bile alani serbest birakir -
    /// birlesim fonksiyonda cozulur.
    /// </summary>
    public Task<List<AlanYetkisi>> AlanYetkileriAsync(int kullaniciId, CancellationToken iptal = default)
        => _veri.ListeAsync("select * from public.fn_kullanici_alan_yetkileri(@p0)",
            new object?[] { kullaniciId },
            o => new AlanYetkisi(o.Metin("kaynak"), o.Metin("alan"), (short)o.Sayi("izin")),
            iptal);

    /// <summary>
    /// Onbellek damgasi: kullanicinin ROL KUMESININ (ana + ek) parmak izi (665).
    /// Rol eklenip cikinca ya da rollerden birinin yetkisi degisince deger
    /// degisir; YetkiCozucu esitlikle karsilastirir.
    /// </summary>
    public Task<long> YetkiSurumuAsync(int kullaniciId, CancellationToken iptal = default)
        => _veri.TekDegerAsync<long>("select public.fn_kullanici_yetki_surumu(@p0)",
            new object?[] { kullaniciId }, iptal);
}


