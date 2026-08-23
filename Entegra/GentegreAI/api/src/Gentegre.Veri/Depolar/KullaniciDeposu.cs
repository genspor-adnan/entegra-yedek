using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Veri.Depolar;

public sealed record KullaniciKaydi(
    int TarafId,
    string Kod,
    string Ad,
    string ParolaHash,
    bool ParolaDegismeli,
    int RolId,
    string RolAdi,
    short Dil,
    long YetkiSurumu,
    bool Aktif,
    short HataliGiris,
    DateTime? KilitBitis);

public sealed class KullaniciDeposu
{
    private readonly VeriKaynagi _veri;
    public KullaniciDeposu(VeriKaynagi veri) => _veri = veri;

    private const string Secim = """
        select k.id, k.kod, coalesce(t.unvan, '') as ad, k.parola_hash,
               k.parola_degismeli, k.rol_id, coalesce(r.ad, '') as rol_adi,
               k.dil, r.yetki_surumu, k.aktif, k.hatali_giris, k.kilit_bitis
          from public.taraf_kullanici k
          join public.rol r   on r.id = k.rol_id
          left join public.taraf t on t.id = k.id
        """;

    public Task<KullaniciKaydi?> KodIleBulAsync(string kod, CancellationToken iptal = default)
        => _veri.TekAsync(Secim + " where k.kod = @p0", new object?[] { kod }, Cevir, iptal);

    public Task<KullaniciKaydi?> IdIleBulAsync(int tarafId, CancellationToken iptal = default)
        => _veri.TekAsync(Secim + " where k.id = @p0", new object?[] { tarafId }, Cevir, iptal);

    private static KullaniciKaydi Cevir(Npgsql.NpgsqlDataReader o) => new(
        o.Sayi("id"), o.Metin("kod"), o.Metin("ad"), o.Metin("parola_hash"),
        o.Bayrak("parola_degismeli"), o.Sayi("rol_id"), o.Metin("rol_adi"),
        (short)o.Sayi("dil"), o.Uzun("yetki_surumu"), o.Bayrak("aktif"),
        (short)o.Sayi("hatali_giris"), o.Tarih("kilit_bitis"));

    /// <summary>Basarili giris: sayaci sifirla, son giris bilgisini yaz.</summary>
    public Task GirisBasariliAsync(int tarafId, string ip, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.taraf_kullanici
               set hatali_giris = 0, kilit_bitis = null,
                   son_giris_tarihi = now()::timestamp, son_giris_ip = @p1
             where id = @p0
            """, new object?[] { tarafId, ip }, iptal);

    /// <summary>
    /// Hatali giris: sayaci artir, sinira ulasildiysa kilitle.
    /// Sinir ve sure referans tablosundan gelir (guvenlik.hatali_giris_siniri / kilit_dakika).
    /// </summary>
    public Task<int> HataliGirisAsync(int tarafId, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            with ayar as (
                select coalesce((select deger::int from public.referans
                                  where anahtar = 'guvenlik.hatali_giris_siniri'), 5) as sinir,
                       coalesce((select deger::int from public.referans
                                  where anahtar = 'guvenlik.kilit_dakika'), 15) as dakika
            )
            update public.taraf_kullanici k
               set hatali_giris = k.hatali_giris + 1,
                   kilit_bitis  = case when k.hatali_giris + 1 >= a.sinir
                                       then now()::timestamp + make_interval(mins => a.dakika)
                                       else k.kilit_bitis end
              from ayar a
             where k.id = @p0
            """, new object?[] { tarafId }, iptal);

    /// <summary>Parola atama tek kapidan: DB'deki fn_parola_ata (bcrypt).</summary>
    public Task ParolaAtaAsync(int tarafId, string yeniHash, bool degismeli,
                               CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.taraf_kullanici
               set parola_hash = @p1, parola_algo = 'bcrypt',
                   parola_tarihi = now()::timestamp, parola_degismeli = @p2,
                   hatali_giris = 0, kilit_bitis = null
             where id = @p0
            """, new object?[] { tarafId, yeniHash, (short)(degismeli ? 1 : 0) }, iptal);

    public Task DilAtaAsync(int tarafId, short dil, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.taraf_kullanici
               set dil = @p1, degistiren = @p0, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, new object?[] { tarafId, dil }, iptal);

    public Task<List<SubeOzeti>> SubeleriAsync(int tarafId, CancellationToken iptal = default)
        => _veri.ListeAsync("""
            select s.id, s.ad, ks.varsayilan, ks.yazma
              from public.kullanici_sube ks
              join public.sube s on s.id = ks.sube_id
             where ks.taraf_id = @p0
             order by ks.varsayilan desc, s.ad
            """, new object?[] { tarafId },
            o => new SubeOzeti(o.Sayi("id"), o.Metin("ad"), o.Bayrak("varsayilan"), o.Bayrak("yazma")),
            iptal);

    /// <summary>
    /// Kayit kapsami (eski YETKIALANI). Bos liste = kapsam SINIRSIZ;
    /// dolu liste = yalniz bu taraf kayitlari gorunur.
    /// </summary>
    public Task<List<int>> KapsamAsync(int tarafId, CancellationToken iptal = default)
        => _veri.ListeAsync("select hedef_id from public.kullanici_kapsam where kullanici_id = @p0 and tur = 1",
            new object?[] { tarafId }, o => o.GetInt32(0), iptal);
}


