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

    /// <summary>
    /// ESNEK GIRIS (kullanici: "user giriste de isim/cep/mail olabilir"):
    /// kullanici kodu, CEP TELEFONU (bicimden bagimsiz - yalniz rakamlar
    /// karsilastirilir), e-posta ya da ad-soyad ile kullaniciyi bulur.
    /// Birden fazla kisi eslesirse (ayni isim) NULL doner - cagiran "kim
    /// oldugunuz belirsiz" der; yanlis hesaba giris riski alinmaz.
    /// </summary>
    public async Task<(KullaniciKaydi? Kullanici, bool Belirsiz)> EsnekBulAsync(
        string girdi, CancellationToken iptal = default)
    {
        var g = (girdi ?? "").Trim().ToLowerInvariant();
        if (g.Length == 0) return (null, false);
        // Cep: yalniz rakamlar, bastaki 90/0 atilir -> "5551112233".
        var rakam = new string(g.Where(char.IsDigit).ToArray());
        if (rakam.StartsWith("90", StringComparison.Ordinal) && rakam.Length > 10)
            rakam = rakam[2..];
        rakam = rakam.TrimStart('0');

        var liste = await _veri.ListeAsync(Secim + """
             where lower(k.kod) = @p0
                or lower(nullif(k.eposta, '')) = @p0
                or lower(nullif(t.eposta, '')) = @p0
                or lower(nullif(t.unvan, '')) = @p0
                or (@p1 <> '' and length(@p1) >= 10 and (
                      right(regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g'), 10) = right(@p1, 10)
                   or right(regexp_replace(coalesce(k.cep_tel, ''), '[^0-9]', '', 'g'), 10) = right(@p1, 10)))
             limit 3
            """, new object?[] { g, rakam }, Cevir, iptal);

        return liste.Count switch
        {
            1 => (liste[0], false),
            0 => (null, false),
            _ => (null, true),
        };
    }

    public Task<KullaniciKaydi?> IdIleBulAsync(int tarafId, CancellationToken iptal = default)
        => _veri.TekAsync(Secim + " where k.id = @p0", new object?[] { tarafId }, Cevir, iptal);

    private static KullaniciKaydi Cevir(Npgsql.NpgsqlDataReader o) => new(
        o.Sayi("id"), o.Metin("kod"), o.Metin("ad"), o.Metin("parola_hash"),
        o.Bayrak("parola_degismeli"), o.Sayi("rol_id"), o.Metin("rol_adi"),
        (short)o.Sayi("dil"), o.Uzun("yetki_surumu"), o.Bayrak("aktif"),
        (short)o.Sayi("hatali_giris"), o.Tarih("kilit_bitis"));

    /// <summary>
    /// PERSONELE OTOMATIK KULLANICI HESABI (kullanici: "personel ekleyince
    /// otomatik kullanici hesabi acsin"). Parola BOS birakilir ve
    /// parola_degismeli = 1 olur: kisi ilk girisde kendi parolasini tanimlar
    /// (bkz. KimlikServisi.IlkParolaAsync - TCKN son 4 ile dogrulanir).
    /// Kod sicil numarasidir; bos/cakisik ise taraf id'si kullanilir.
    /// Zaten hesabi olan kayit ATLANIR; kac hesap acildigini doner.
    /// </summary>
    public async Task<int> OtomatikHesapAcAsync(int? tarafId = null,
        CancellationToken iptal = default)
        => await _veri.TekDegerAsync<int>("""
            with hedef as (
                select t.id,
                       nullif(trim(t.kod), '') as sicil,
                       coalesce(nullif(trim(t.eposta), ''), '') as eposta,
                       -- Cep: yalniz rakam, bastaki 90/0 atilmis 10 hane.
                       ltrim(regexp_replace(
                           regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g'),
                           '^(90)?0*', ''), '0') as cep
                  from public.taraf t
                 where t.personel = 1 and t.durum = 1
                   and (@p0::int is null or t.id = @p0)
                   and not exists (select 1 from public.taraf_kullanici k where k.id = t.id)
            ), yeni as (
                insert into public.taraf_kullanici
                       (id, kod, parola_hash, parola_degismeli, rol_id, eposta, aktif, ekleyen)
                select h.id,
                       -- Kod = CEP NO (kullanici); yoksa sicil, o da yoksa id.
                       --   Benzersizlik zorunlu: cakisirsa bir sonrakine duser.
                       case when h.cep <> ''
                             and not exists (select 1 from public.taraf_kullanici k
                                              where k.kod = h.cep)
                            then h.cep
                            when h.sicil is not null
                             and not exists (select 1 from public.taraf_kullanici k
                                              where lower(k.kod) = lower(h.sicil))
                            then lower(h.sicil)
                            else h.id::text end,
                       '', 1,
                       coalesce((select id from public.rol where kod = 'atanmamis'),
                                (select id from public.rol order by id limit 1)),
                       h.eposta, 1, 0
                  from hedef h
                returning id
            )
            , sube as (
                insert into public.kullanici_sube
                       (taraf_id, sube_id, varsayilan, yazma, ekleyen)
                select y.id, t.sube_id, 1, 1, 0
                  from yeni y
                  join public.taraf t on t.id = y.id
                 where coalesce(t.sube_id, 0) > 0
                   and not exists (select 1 from public.kullanici_sube ks
                                    where ks.taraf_id = y.id)
                returning 1
            )
            select count(*)::int from yeni
            """, new object?[] { tarafId }, iptal);

    /// <summary>Ilk parola dogrulamasi icin TCKN (taraf.vkno).</summary>
    public Task<string?> TcknAsync(int tarafId, CancellationToken iptal = default)
        => _veri.TekDegerAsync<string>(
            "select coalesce(vkno, '') from public.taraf where id = @p0",
            new object?[] { tarafId }, iptal);

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

    /// <summary>
    /// Kullanıcının şubeleri - ROLÜNDEN gelir (234). Rolün şubesi tanımlı
    /// değilse ve kurulumda TEK şube varsa o şube verilir: tek şubeli
    /// kurulumda şube seçimi anlamsız (rol kartında bölüm de çizilmez),
    /// kimse şubesiz kalmamalı.
    /// </summary>
    public async Task<List<SubeOzeti>> SubeleriAsync(int tarafId,
        CancellationToken iptal = default)
    {
        // 1) KISIYE tanimli subeler (kullanici karari: sube kisiti kisiye
        //    dondu - kullanici_sube), 2) yoksa rolunun subeleri (234 donemi
        //    kayitlari), 3) o da yoksa tek subeli kurulum kurali.
        var liste = await _veri.ListeAsync(
            "select s.id, s.ad, ks.varsayilan, ks.yazma " +
            "  from public.kullanici_sube ks " +
            "  join public.sube s on s.id = ks.sube_id and s.aktif = 1 " +
            " where ks.taraf_id = @p0 " +
            " order by ks.varsayilan desc, s.ad",
            new object?[] { tarafId },
            o => new SubeOzeti(o.Sayi("id"), o.Metin("ad"), o.Bayrak("varsayilan"),
                               o.Bayrak("yazma")), iptal);
        if (liste.Count > 0) return liste;

        liste = await RolSubeleriAsync(tarafId, iptal);
        if (liste.Count > 0) return liste;

        // 3) Kisinin CALISTIGI subesi (taraf.sube_id) - yeni acilan hesaplar
        //    subesiz kalmasin (sube secici ve oturum bilgisi bos goruluyordu).
        liste = await _veri.ListeAsync(
            "select s.id, s.ad, 1 as varsayilan, 1 as yazma " +
            "  from public.taraf t " +
            "  join public.sube s on s.id = t.sube_id and s.aktif = 1 " +
            " where t.id = @p0",
            new object?[] { tarafId },
            o => new SubeOzeti(o.Sayi("id"), o.Metin("ad"), o.Bayrak("varsayilan"),
                               o.Bayrak("yazma")), iptal);
        if (liste.Count > 0) return liste;
        return await _veri.ListeAsync(
            "select s.id, s.ad, 1 as varsayilan, 1 as yazma " +
            "  from public.sube s " +
            " where s.aktif = 1 " +
            "   and (select count(*) from public.sube where aktif = 1) = 1",
            Array.Empty<object?>(),
            o => new SubeOzeti(o.Sayi("id"), o.Metin("ad"), o.Bayrak("varsayilan"),
                               o.Bayrak("yazma")),
            iptal);
    }

    private Task<List<SubeOzeti>> RolSubeleriAsync(int tarafId, CancellationToken iptal)
        => _veri.ListeAsync("""
            -- Sube yetkisi ROLDEN gelir (234, kullanici karari): kullanicinin
            --   girebildigi subeler rolunun subeleridir. Eski kullanici_sube
            --   tablosu veri olarak duruyor ama ARTIK OKUNMUYOR.
            select s.id, s.ad, rs.varsayilan, rs.yazma
              from public.taraf_kullanici k
              join public.rol_sube rs on rs.rol_id = k.rol_id
              join public.sube s on s.id = rs.sube_id and s.aktif = 1
             where k.id = @p0
             order by rs.varsayilan desc, s.ad
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


