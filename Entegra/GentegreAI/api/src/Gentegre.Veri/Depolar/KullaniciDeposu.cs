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
    /// <summary>EK rollerin adlari (665) - ana rol bu listede DEGILDIR.</summary>
    string EkRolAdlari,
    short Dil,
    long YetkiSurumu,
    bool Aktif,
    short HataliGiris,
    DateTime? KilitBitis);

/// <summary>Kullanici Ayarlari > Hesabim (669): kisinin kendi hesap ozeti.</summary>
public sealed record HesapBilgisi(
    string Eposta, string CepTel, DateTime? ParolaTarihi, DateTime? SonGiris,
    string SonGirisIp, short HataliGiris, bool TotpAktif,
    string AnaRol, string EkRoller, string Unvan, string Gorev);

/// <summary>Kullanici Ayarlari > Guvenlik (669): giris denemesi satiri.</summary>
public sealed record GirisDenemesi(DateTime Tarih, bool Basarili, string Sebep,
    string Ip, string Istemci);

public sealed class KullaniciDeposu
{
    private readonly VeriKaynagi _veri;
    public KullaniciDeposu(VeriKaynagi veri) => _veri = veri;

    private const string Secim = """
        select k.id, k.kod, coalesce(t.unvan, '') as ad, k.parola_hash,
               k.parola_degismeli, k.rol_id, coalesce(r.ad, '') as rol_adi,
               -- EK ROLLER (665): kisinin ana isinin yaninda tasidigi gorevler.
               coalesce((select string_agg(er.ad, ', ' order by er.ad)
                           from public.kullanici_rol kr
                           join public.rol er on er.id = kr.rol_id
                          where kr.kullanici_id = k.id), '') as ek_rol_adlari,
               k.dil,
               -- Yetki damgasi ROL KUMESINDEN gelir (665): ana rolun sayaci tek
               --   basina ek rol degisimini gormezdi.
               public.fn_kullanici_yetki_surumu(k.id) as yetki_surumu,
               k.aktif, k.hatali_giris, k.kilit_bitis
          from public.taraf_kullanici k
          join public.rol r   on r.id = k.rol_id
          left join public.taraf t on t.id = k.id
        """;

    public Task<KullaniciKaydi?> KodIleBulAsync(string kod, CancellationToken iptal = default)
        => _veri.TekAsync(Secim + " where k.kod = @p0", new object?[] { kod }, Cevir, iptal);

    /// <summary>
    /// ESNEK GIRIS (kullanici: "user giriste de isim/cep/mail olabilir",
    /// sonra "ad soyad / cep tel / mail adresi / tcno ile giris yapilabilsin"):
    /// kullanici kodu, SICIL NO, CEP TELEFONU (bicimden bagimsiz - yalniz
    /// rakamlar karsilastirilir), e-posta, TCKN ya da AD SOYAD ile kullaniciyi
    /// bulur.
    ///
    /// AD SOYAD iki yerden okunur: `unvan` personelde unvan ONEKI tasir
    /// ("Dr. Perihan Şen"), kisinin kendi yazacagi sey ise "perihan şen"dir -
    /// yalniz unvana bakmak personelin cogunu disarida birakirdi.
    ///
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

        // TCKN: yalniz 11 haneli rakam dizisi TCKN sayilir - 4 haneli bir
        //   sicil numarasini "kimlik no" diye eslestirmek yanlis kisiyi acardi.
        var tckn = rakam.Length == 11 ? rakam : "";

        var liste = await _veri.ListeAsync(Secim + """
             where lower(k.kod) = @p0
                or lower(nullif(t.kod, '')) = @p0
                or lower(nullif(k.eposta, '')) = @p0
                or lower(nullif(t.eposta, '')) = @p0
                or lower(nullif(t.unvan, '')) = @p0
                or (coalesce(t.ad, '') <> '' and coalesce(t.soyad, '') <> ''
                    and lower(trim(t.ad || ' ' || t.soyad)) = @p0)
                or (@p2 <> '' and regexp_replace(coalesce(t.vkno, ''), '[^0-9]', '', 'g') = @p2)
                or (@p1 <> '' and length(@p1) >= 10 and (
                      right(regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g'), 10) = right(@p1, 10)
                   or right(regexp_replace(coalesce(k.cep_tel, ''), '[^0-9]', '', 'g'), 10) = right(@p1, 10)))
             limit 3
            """, new object?[] { g, rakam, tckn }, Cevir, iptal);

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
        o.Metin("ek_rol_adlari"), (short)o.Sayi("dil"), o.Uzun("yetki_surumu"), o.Bayrak("aktif"),
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

    /// <summary>
    /// VARSAYILAN PAROLA YAZILACAK PERSONEL HESAPLARI (674).
    ///
    /// Normalde YALNIZ PAROLASIZ hesaplar doner: otomatik acilan hesabin
    /// parolasi bostur, kisinin kendi belirledigi parolayi "varsayilana"
    /// cevirmek ise hesabi herkese acardi.
    ///
    /// <paramref name="sifirla"/> = true ise DOLU PAROLALAR DA doner
    /// (kullanici: "eski kayitlarin sifrelerini de admin haric kart ID ile
    /// guncelle") - toplu ilk kurulum icin. ADMIN her durumda disaridadir:
    /// yonetici hesabinin parolasini tahmin edilebilir bir sayiya cevirmek
    /// sistemin tamamini acardi.
    /// </summary>
    public async Task<IReadOnlyList<int>> VarsayilanParolaHedefleriAsync(
        int? tarafId = null, bool sifirla = false, CancellationToken iptal = default)
        => await _veri.ListeAsync("""
            select k.id
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
             where k.aktif = 1 and t.personel = 1 and t.durum = 1
               and lower(k.kod) <> 'admin'
               and (@p1 = 1 or k.parola_hash = '')
               and (@p0::int is null or k.id = @p0)
             order by k.id
            """, new object?[] { tarafId, (short)(sifirla ? 1 : 0) },
            o => o.GetInt32(0), iptal);

    // ------------------------------------------- KULLANICI AYARLARI (669) ----

    /// <summary>
    /// "Hesabım" sekmesinin verisi: kisinin KENDI hesabi. Yetki istemez -
    /// kendi e-postasini gormek icin `kullanici` yetkisi aramak, herkesin
    /// yonetici olmasini gerektirirdi.
    /// </summary>
    public Task<HesapBilgisi?> HesapBilgisiAsync(int tarafId, CancellationToken iptal = default)
        => _veri.TekAsync("""
            -- E-POSTA/CEP IKI YERDE OLABILIR: hesap satirinda (taraf_kullanici)
            --   ve personel kartinda (taraf). Otomatik acilan hesaplarda kart
            --   dolu, hesap satiri BOSTUR - yalniz hesap satirini okumak
            --   "Hasan Aydın'in cep telefonu yok" demek olurdu; kartinda var.
            --   Hesap satiri onceliklidir (kisi buradan degistirmisse o gecerli).
            select coalesce(nullif(k.eposta, ''), nullif(t.eposta, ''), '') as eposta,
                   coalesce(nullif(k.cep_tel, ''), nullif(t.cep_tel, ''),
                            nullif(t.telefon, ''), '') as cep_tel,
                   k.parola_tarihi, k.son_giris_tarihi,
                   k.son_giris_ip, k.hatali_giris, k.totp_aktif,
                   coalesce(r.ad, '') as ana_rol,
                   coalesce((select string_agg(er.ad, ', ' order by er.ad)
                               from public.kullanici_rol kr
                               join public.rol er on er.id = kr.rol_id
                              where kr.kullanici_id = k.id), '') as ek_roller,
                   coalesce(t.unvan, '') as unvan,
                   coalesce((select g.ad from public.personel_gorev g
                              where g.id = t.gorev_id), t.gorev, '') as gorev
              from public.taraf_kullanici k
              join public.rol r on r.id = k.rol_id
              left join public.taraf t on t.id = k.id
             where k.id = @p0
            """, new object?[] { tarafId },
            o => new HesapBilgisi(o.Metin("eposta"), o.Metin("cep_tel"),
                o.Tarih("parola_tarihi"), o.Tarih("son_giris_tarihi"),
                o.Metin("son_giris_ip"), (short)o.Sayi("hatali_giris"),
                o.Sayi("totp_aktif") == 1, o.Metin("ana_rol"), o.Metin("ek_roller"),
                o.Metin("unvan"), o.Metin("gorev")),
            iptal);

    /// <summary>
    /// Kendi iletisim bilgisini gunceller. AD, GOREV ve ROL BURADA YOK:
    /// onlar personel kartinda durur (kendi kartini duzenleyebilen kisi kendi
    /// gorevini de degistirebilirdi).
    ///
    /// IKI TABLO BIRDEN yazilir (hesap satiri + personel karti): e-posta iki
    /// yerde saklaniyor ve esnek giris ikisine de bakiyor (KodIleBulAsync).
    /// Yalniz birini yazmak, kartta eski adres kalmasina ve "degistirdim ama
    /// hala eskisine posta geliyor" durumuna yol acardi. Kartin DIGER alanlarina
    /// dokunulmaz.
    /// </summary>
    public async Task IletisimGuncelleAsync(int tarafId, string eposta, string cepTel,
                                            CancellationToken iptal = default)
    {
        await _veri.CalistirAsync("""
            update public.taraf_kullanici
               set eposta = @p1, cep_tel = @p2,
                   degistiren = @p0, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, new object?[] { tarafId, eposta, cepTel }, iptal);

        await _veri.CalistirAsync("""
            update public.taraf
               set eposta = @p1, cep_tel = @p2,
                   degistiren = @p0, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, new object?[] { tarafId, eposta, cepTel }, iptal);
    }

    /// <summary>
    /// Son giris denemeleri (basarili + BASARISIZ). Basarisizlari gizlemek,
    /// "birinin denedigini" kullanicidan saklamak olurdu.
    /// </summary>
    public Task<List<GirisDenemesi>> GirisGecmisiAsync(int tarafId, int adet = 10,
        CancellationToken iptal = default)
        => _veri.ListeAsync("""
            select tarih, basarili, sebep, ip, istemci
              from public.giris_denemesi
             where kullanici_id = @p0
             order by tarih desc
             limit @p1
            """, new object?[] { tarafId, adet },
            o => new GirisDenemesi(o.GetDateTime(0), o.Sayi("basarili") == 1,
                o.Metin("sebep"), o.Metin("ip"), o.Metin("istemci")),
            iptal);

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

    /// <summary>PAROLA GECMISI (687): son n hash, yeniden eskiye.</summary>
    public Task<List<string>> SonParolaHashleriAsync(int tarafId, int adet, CancellationToken iptal = default)
        => _veri.ListeAsync(
            "select parola_hash from public.parola_gecmisi where kullanici_id = @p0 order by tarih desc, id desc limit @p1",
            new object?[] { tarafId, adet }, o => o.GetString(0), iptal);

    public Task ParolaGecmisineYazAsync(int tarafId, string hash, CancellationToken iptal = default)
        => _veri.CalistirAsync(
            "insert into public.parola_gecmisi (kullanici_id, parola_hash) values (@p0, @p1)",
            new object?[] { tarafId, hash }, iptal);

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
        var liste = await SubeleriHamAsync(tarafId, iptal);
        if (liste.Count == 0) return liste;
        // ŞUBE LOGOSU (kullanıcı: üst şeritte şube combosu yerine logo + ad).
        //   KURAL TEK YERDE (772): `v_sube_antet.logo_dokuman_id`. Burada satır
        //   içi duruyordu; çıktı antetleri de aynı logoyu göstermek zorunda ve
        //   iki kopya, bir gün üst şeritteki logonun kâğıttakinden farklı
        //   dosyayı göstermesi demekti.
        var logolar = await _veri.ListeAsync(
            "select a.sube_id, a.logo_dokuman_id " +
            "  from public.v_sube_antet a " +
            " where a.sube_id = any(@p0) and a.logo_dokuman_id is not null",
            new object?[] { liste.Select(s => s.Id).ToArray() },
            o => (kaynakId: o.GetInt32(0), id: o.GetInt32(1)), iptal);
        if (logolar.Count == 0) return liste;
        var harita = logolar.ToDictionary(x => x.kaynakId, x => x.id);
        return liste.Select(s => harita.TryGetValue(s.Id, out var d) ? s with { LogoDokumanId = d } : s).ToList();
    }

    private async Task<List<SubeOzeti>> SubeleriHamAsync(int tarafId,
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
            --   girebildigi subeler rollerinin subeleridir. Cok rolde (665)
            --   subeler BIRLESIR; yazma hakki genis olan kazanir, varsayilan
            --   sube ANA ROLden gelir. Eski kullanici_sube tablosu veri olarak
            --   duruyor ama ARTIK OKUNMUYOR.
            select sube_id as id, ad, varsayilan, yazma,
                   ulke_kod, telefon_kodu, zaman_dilimi, para_birimi
              from public.fn_kullanici_subeleri(@p0)
             order by varsayilan desc, ad
            """, new object?[] { tarafId },
            o => new SubeOzeti(o.Sayi("id"), o.Metin("ad"), o.Bayrak("varsayilan"), o.Bayrak("yazma"),
                o.Metin("ulke_kod"), o.Metin("telefon_kodu"),
                o.Metin("zaman_dilimi"), o.Metin("para_birimi")),
            iptal);

    /// <summary>
    /// Kayit kapsami (eski YETKIALANI). Bos liste = kapsam SINIRSIZ;
    /// dolu liste = yalniz bu taraf kayitlari gorunur.
    /// </summary>
    public Task<List<int>> KapsamAsync(int tarafId, CancellationToken iptal = default)
        => _veri.ListeAsync("select hedef_id from public.kullanici_kapsam where kullanici_id = @p0 and tur = 1",
            new object?[] { tarafId }, o => o.GetInt32(0), iptal);
}


