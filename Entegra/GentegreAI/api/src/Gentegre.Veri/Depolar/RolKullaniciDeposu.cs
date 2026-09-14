using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

public sealed record RolKullanicisi(int Id, string Kod, string Unvan, string Eposta,
    string Departman, string Gorev, string Telefon, string Sube,
    bool Aktif, DateTime? SonGiris, string RolAdi, bool Ana = false);

/// <summary>
/// Rol kartı "Kullanıcılar" sekmesi (kullanıcı: "rollerin içine kullanıcı
/// ekleyebileyim").
///
/// ÇOK ROLLÜ (665): kullanıcının bir ANA rolü (taraf_kullanici.rol_id - asıl
/// işi) ve istediği kadar EK rolü (kullanici_rol) olur; etkili yetki ikisinin
/// birleşimidir. Bu yüzden "role ekleme" artık kişinin rolünü EZMEZ:
///   · ana rolü "Rol Atanmamış" ise bu rol ANA rol olur (yer tutucu kalmasın),
///   · değilse EK rol olarak eklenir - hekim hekimliğini kaybetmeden
///     "İskonto Onaylayanlar" olabilir.
/// "Çıkarma" ek rolü siler; çıkarılan ANA rol ise ek rollerden biri ana role
/// yükselir, hiç yoksa kişi "Rol Atanmamış"a döner (yönetici DEĞİL - rolden
/// çıkarmanın kişiyi tam yetkili yapması sessiz bir yetki yükseltmesiydi).
/// </summary>
public sealed class RolKullaniciDeposu
{
    private readonly VeriKaynagi _veri;
    private readonly LogDeposu _log;
    private const int LogTabloRol = 903;

    public RolKullaniciDeposu(VeriKaynagi veri, LogDeposu log)
    {
        _veri = veri;
        _log = log;
    }

    /// <summary>
    /// Role bağlı kullanıcılar: ana rolü BU olanlar + bu rolü EK rol olarak
    /// taşıyanlar (665). `RolAdi` kişinin ANA rolüdür - ek rolle listeye giren
    /// hekimin satırında "Doktor" yazar, `Ana = false` ile birlikte okununca
    /// "asıl işi doktor, burada ek görevli" anlaşılır.
    /// </summary>
    public async Task<IReadOnlyList<RolKullanicisi>> ListeleAsync(int rolId,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select k.id, k.kod, coalesce(t.unvan, ''), k.eposta,
                   coalesce((select dp.ad from public.departman dp
                              where dp.id = t.departman), ''),
                   coalesce((select g.ad from public.personel_gorev g
                              where g.id = t.gorev_id), t.gorev, ''),
                   coalesce(nullif(t.telefon, ''), nullif(t.cep_tel, ''),
                            k.cep_tel, ''),
                   coalesce(sb.ad, ''),
                   k.aktif, k.son_giris_tarihi, coalesce(r.ad, ''),
                   case when k.rol_id = @p0 then 1 else 0 end::smallint as ana
              from public.taraf_kullanici k
              join public.taraf t on t.id = k.id
              left join public.sube sb on sb.id = t.sube_id
              left join public.rol r on r.id = k.rol_id
             where k.rol_id = @p0
                or exists (select 1 from public.kullanici_rol kr
                            where kr.kullanici_id = k.id and kr.rol_id = @p0)
             order by k.aktif desc, ana desc, t.unvan
            """, null, rolId);
        return await OkuAsync(komut, iptal);
    }

    /// <summary>
    /// Role eklenebilecek kullanıcılar: BU rolde olmayanlar. Arama boşsa ilk 50
    /// (353 kullanıcı var - hepsini listelemek anlamsız).
    /// </summary>
    /// <summary>
    /// ROLE EKLENEBILECEKLER: BUTUN AKTIF PERSONEL (kullanici, 663).
    ///
    /// Eskiden yalniz `taraf_kullanici` satiri OLANLAR listeleniyordu - yani
    /// daha once hesap acilmis kisiler. Kurumda 93 aktif personelin 55'inin
    /// hesabi vardi; kalan 38'i role eklenemiyordu ve ekranda sebebi de
    /// gorunmuyordu ("bulunamadi" diyordu).
    ///
    /// Artik liste PERSONELDEN kurulur; hesap varsa bilgileri ona baglanir,
    /// yoksa satir yine gelir ve atamada hesap ACILIR (bkz. AtaAsync).
    /// </summary>
    public async Task<IReadOnlyList<RolKullanicisi>> AdaylarAsync(int rolId, string? arama,
        CancellationToken iptal = default)
    {
        var q = (arama ?? "").Trim();
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = baglanti.Komut("""
            select t.id, coalesce(k.kod, ''), coalesce(t.unvan, ''), coalesce(k.eposta, ''),
                   coalesce((select dp.ad from public.departman dp
                              where dp.id = t.departman), ''),
                   coalesce((select g.ad from public.personel_gorev g
                              where g.id = t.gorev_id), t.gorev, ''),
                   coalesce(nullif(t.telefon, ''), nullif(t.cep_tel, ''),
                            k.cep_tel, ''),
                   coalesce(sb.ad, ''),
                   coalesce(k.aktif, 1), k.son_giris_tarihi,
                   -- Hesabi olmayanda rol yerine DURUMU yazariz: kullanici
                   --   "neden rolu bos" diye aramasin, atamada acilacagini bilsin.
                   case when k.id is null then '(hesap açılacak)'
                        else coalesce(r.ad, '') end
              from public.taraf t
              left join public.taraf_kullanici k on k.id = t.id
              left join public.sube sb on sb.id = t.sube_id
              left join public.rol r on r.id = k.rol_id
             where t.personel = 1
               and coalesce(t.durum, 1) = 1
               -- Zaten bu rolde olan (ana ya da EK, 665) listede durmaz.
               and coalesce(k.rol_id, 0) <> @p0
               and not exists (select 1 from public.kullanici_rol kr
                                where kr.kullanici_id = k.id and kr.rol_id = @p0)
               and (@p1 = '' or t.unvan ilike '%' || @p1 || '%'
                             or k.kod ilike '%' || @p1 || '%'
                             or k.eposta ilike '%' || @p1 || '%'
                             or t.gorev ilike '%' || @p1 || '%')
             order by t.unvan
             limit 200
            """, null, rolId, q);
        return await OkuAsync(komut, iptal);
    }

    /// <summary>
    /// Kullanıcıyı bu role ekler. Ana rolü yer tutucu ("Rol Atanmamış") ise
    /// ANA rol yapar, değilse EK rol olarak ekler (665) - kişinin asıl rolü
    /// ezilmez. <paramref name="anaYap"/> ile çağıran ana rolü açıkça
    /// değiştirebilir (personel kartındaki "Ana rol" seçimi).
    /// </summary>
    public async Task AtaAsync(int rolId, int kullaniciId, YazmaBaglami baglam,
        CancellationToken iptal = default, bool anaYap = false)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // int (0 = kayit yok): nullable donusu merkezi olarak calisiyor ama
        //   burada 0 kontrolu hem daha basit hem cagriyi tipe bagimli birakmiyor.
        var eski = await baglanti.TekDegerAsync<int>(
            "select rol_id from public.taraf_kullanici where id = @p0", islem,
            new object?[] { kullaniciId }, iptal);

        if (eski == 0)
        {
            // HESABI YOK: personel role eklenirken hesap ACILIR (663).
            //   Aday listesi artik butun aktif personeli gosteriyor; hesabi
            //   olmayani "bulunamadi" diye reddetmek, kullaniciyi once
            //   Kullanicilar ekranina gonderip geri getirirdi.
            //
            //   PAROLA BOS ve `parola_degismeli = 1`: giris ancak parola
            //   belirlendikten sonra yapilir. Burada parola URETMEK, kimsenin
            //   gormedigi bir sifreyi kayda gecirmek olurdu.
            var personelVar = await baglanti.TekDegerAsync<int>("""
                select 1 from public.taraf
                 where id = @p0 and personel = 1 and coalesce(durum, 1) = 1
                """, islem, new object?[] { kullaniciId }, iptal);
            if (personelVar == 0)
                throw GentegreHatasi.Bulunamadi("Aktif personel bulunamadı.");

            await using var ac = baglanti.Komut("""
                insert into public.taraf_kullanici
                       (id, kod, rol_id, eposta, cep_tel, aktif,
                        parola_hash, parola_degismeli, ekleyen)
                select t.id,
                       -- KOD BENZERSIZ ve KUCUK HARF olmali (ck_taraf_kullanici_kod:
                       --   ^[a-z0-9._@-]+$). E-posta varsa o, yoksa 'p' + taraf
                       --   kimligi - iki personelde de cakismaz.
                       lower(coalesce(nullif(t.eposta, ''), 'p' || t.id::text)),
                       @p1, coalesce(t.eposta, ''), coalesce(t.cep_tel, ''), 1,
                       '', 1, @p2
                  from public.taraf t
                 where t.id = @p0
                on conflict (id) do nothing
                """, islem, kullaniciId, rolId, baglam.KullaniciId);
            await ac.ExecuteNonQueryAsync(iptal);
        }
        else if (eski != rolId)
        {
            // Yer tutucu rol ("Rol Atanmamış") gercek bir gorev degil: kisi
            //   ilk gercek rolunu alinca ANA rol olmali, yoksa herkes sonsuza
            //   kadar "atanmamis + ek rol" gorunurdu.
            var yerTutucu = await baglanti.TekDegerAsync<int>(
                "select id from public.rol where kod = 'atanmamis'", islem, null, iptal);

            if (anaYap || eski == yerTutucu)
            {
                // Ana rolu degistiriyoruz: eski ana rol EK role dusurulur ki
                //   kisinin tasidigi yetki sessizce kaybolmasin. Yer tutucu
                //   ve ayni rol haric.
                if (eski != yerTutucu)
                    await using (var e = baglanti.Komut("""
                        insert into public.kullanici_rol (kullanici_id, rol_id, ekleyen)
                        values (@p0, @p1, @p2) on conflict do nothing
                        """, islem, kullaniciId, eski, baglam.KullaniciId))
                        await e.ExecuteNonQueryAsync(iptal);

                await using var k = baglanti.Komut("""
                    update public.taraf_kullanici
                       set rol_id = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp
                     where id = @p0
                    """, islem, kullaniciId, rolId, baglam.KullaniciId);
                await k.ExecuteNonQueryAsync(iptal);
            }
            else
            {
                // EK ROL: asil rol yerinde kalir (665).
                await using var k = baglanti.Komut("""
                    insert into public.kullanici_rol (kullanici_id, rol_id, ekleyen)
                    values (@p0, @p1, @p2) on conflict do nothing
                    """, islem, kullaniciId, rolId, baglam.KullaniciId);
                await k.ExecuteNonQueryAsync(iptal);
            }
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol, rolId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = anaYap ? "Kullanıcının ana rolü değiştirildi" : "Kullanıcı role eklendi",
                ["kullaniciId"] = kullaniciId.ToString(),
                ["eskiRolId"] = eski.ToString(),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }

    /// <summary>
    /// Kullanıcıyı rolden çıkarır (665):
    ///   · rol EK rolse satır silinir, ana rol yerinde kalır;
    ///   · ANA rolse ek rollerden biri ana role yükselir, hiç yoksa kişi
    ///     "Rol Atanmamış" yer tutucusuna döner.
    /// Eskiden "yonetici"ye taşınıyordu: rolden çıkarmanın kişiyi TAM YETKİLİ
    /// yapması sessiz bir yetki yükseltmesiydi.
    /// </summary>
    public async Task<string> CikarAsync(int rolId, int kullaniciId, YazmaBaglami baglam,
        CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var anaRol = await baglanti.TekDegerAsync<int>(
            "select rol_id from public.taraf_kullanici where id = @p0", islem,
            new object?[] { kullaniciId }, iptal);
        if (anaRol == 0)
            throw GentegreHatasi.Bulunamadi("Kullanıcı hesabı bulunamadı.");

        string sonuc;
        if (anaRol != rolId)
        {
            await using var k = baglanti.Komut(
                "delete from public.kullanici_rol where kullanici_id = @p0 and rol_id = @p1",
                islem, kullaniciId, rolId);
            if (await k.ExecuteNonQueryAsync(iptal) == 0)
                throw GentegreHatasi.IsKurali("Kullanıcı bu rolde değil.");
            sonuc = "Ek rol kaldırıldı; kullanıcının ana rolü değişmedi.";
        }
        else
        {
            // ANA ROL cikariliyor: once EK rollerden biri ana role yukselir.
            //   Sirali secim (en eski eklenen) - keyfi degil, tekrar edilebilir.
            var yeni = await baglanti.TekDegerAsync<int>("""
                select rol_id from public.kullanici_rol
                 where kullanici_id = @p0
                 order by ekleme_tarihi, rol_id
                 limit 1
                """, islem, new object?[] { kullaniciId }, iptal);

            var yerTutucu = await baglanti.TekDegerAsync<int>(
                "select id from public.rol where kod = 'atanmamis'", islem, null, iptal);

            if (yeni == 0 && yerTutucu == 0)
                throw GentegreHatasi.IsKurali(
                    "Yer tutucu sistem rolü (Rol Atanmamış) bulunamadı - kullanıcı rolsüz bırakılamaz.");
            if (yeni == 0 && yerTutucu == rolId)
                throw GentegreHatasi.IsKurali(
                    "Yer tutucu rolden kullanıcı çıkarılamaz - kullanıcıyı başka bir role ekleyin.");

            var hedef = yeni != 0 ? yeni : yerTutucu;

            await using (var k = baglanti.Komut("""
                update public.taraf_kullanici
                   set rol_id = @p1, degistiren = @p2, degistirme_tarihi = now()::timestamp
                 where id = @p0 and rol_id = @p3
                """, islem, kullaniciId, hedef, baglam.KullaniciId, rolId))
                await k.ExecuteNonQueryAsync(iptal);

            // Yeni ana rol EK roller arasindan cikarilir (tetik de yapar, ayni
            //   islemde acikca yapmak sonucu okunur kilar).
            if (yeni != 0)
                await using (var k = baglanti.Komut(
                    "delete from public.kullanici_rol where kullanici_id = @p0 and rol_id = @p1",
                    islem, kullaniciId, yeni))
                    await k.ExecuteNonQueryAsync(iptal);

            sonuc = yeni != 0
                ? "Ana rol kaldırıldı; kullanıcının ek rollerinden biri ana rol oldu."
                : "Kullanıcı 'Rol Atanmamış' durumuna alındı - yetkisi kalmadı.";
        }

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol, rolId,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Kullanıcı rolden çıkarıldı",
                ["kullaniciId"] = kullaniciId.ToString(),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
        return sonuc;
    }

    /// <summary>
    /// Personel/kişi kartından kullanıcı rolü (kullanıcı: "personel kartında
    /// rolü görebilmem ve istersem değiştirebilmem lazım"). Kartın kullanıcı
    /// hesabı yoksa KullaniciVar=false döner - ekran "hesabı yok" der.
    /// </summary>
    public async Task<(bool KullaniciVar, int RolId, string RolAdi,
                       IReadOnlyList<(int Id, string Ad)> Roller,
                       IReadOnlyList<int> EkRolIdleri)>
        KartRolOkuAsync(int kartId, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var roller = new List<(int, string)>();
        await using (var k = baglanti.Komut(
            "select id, ad from public.rol where aktif = 1 order by ad", null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) roller.Add((o.GetInt32(0), o.GetString(1)));

        var ekRoller = new List<int>();
        await using (var k = baglanti.Komut("""
            select kr.rol_id from public.kullanici_rol kr
              join public.rol r on r.id = kr.rol_id
             where kr.kullanici_id = @p0
             order by r.ad
            """, null, kartId))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) ekRoller.Add(o.GetInt32(0));

        await using var komut = baglanti.Komut(
            "select k.rol_id, coalesce(r.ad, '') " +
            "  from public.taraf_kullanici k " +
            "  left join public.rol r on r.id = k.rol_id " +
            " where k.id = @p0", null, kartId);
        await using var oku = await komut.ExecuteReaderAsync(iptal);
        if (!await oku.ReadAsync(iptal)) return (false, 0, "", roller, ekRoller);
        return (true, oku.GetInt32(0), oku.GetString(1), roller, ekRoller);
    }

    /// <summary>
    /// Karttan ANA rol değiştirme - AtaAsync ile aynı iz (islem_log). Eski ana
    /// rol ek role düşer: kart ekranından rol değiştiren kişi, taşınan yetkiyi
    /// istemiyorsa ek rol listesinden kaldırır (görerek, sessizce değil).
    /// </summary>
    public async Task KartRolDegistirAsync(int kartId, int rolId, YazmaBaglami baglam,
        CancellationToken iptal = default)
        => await AtaAsync(rolId, kartId, baglam, iptal, anaYap: true);

    /// <summary>
    /// Kartın EK rollerini topluca yazar (665): listede olmayanlar silinir,
    /// yeni gelenler eklenir. Ana rol listeye girerse yok sayılır - aynı rol
    /// iki yerde duramaz (tg_kullanici_rol_dogrula).
    /// </summary>
    public async Task KartEkRollerKaydetAsync(int kartId, IReadOnlyList<int> rolIdleri,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var anaRol = await baglanti.TekDegerAsync<int>(
            "select rol_id from public.taraf_kullanici where id = @p0", islem,
            new object?[] { kartId }, iptal);
        if (anaRol == 0)
            throw GentegreHatasi.Bulunamadi("Kullanıcı hesabı bulunamadı.");

        var hedef = rolIdleri.Where(r => r != anaRol).Distinct().ToArray();

        await using (var k = baglanti.Komut("""
            delete from public.kullanici_rol
             where kullanici_id = @p0 and rol_id <> all(@p1)
            """, islem, kartId, hedef))
            await k.ExecuteNonQueryAsync(iptal);

        foreach (var rolId in hedef)
            await using (var k = baglanti.Komut("""
                insert into public.kullanici_rol (kullanici_id, rol_id, ekleyen)
                values (@p0, @p1, @p2) on conflict do nothing
                """, islem, kartId, rolId, baglam.KullaniciId))
                await k.ExecuteNonQueryAsync(iptal);

        await _log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRol, anaRol,
            baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new Dictionary<string, string>
            {
                ["islem"] = "Kullanıcının ek rolleri güncellendi",
                ["kullaniciId"] = kartId.ToString(),
                ["ekRolIdleri"] = string.Join(",", hedef),
            }, iptal: iptal);

        await islem.CommitAsync(iptal);
    }

    private static async Task<IReadOnlyList<RolKullanicisi>> OkuAsync(NpgsqlCommand komut,
        CancellationToken iptal)
    {
        var liste = new List<RolKullanicisi>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new RolKullanicisi(o.GetInt32(0), o.GetString(1), o.GetString(2),
                o.GetString(3), o.GetString(4), o.GetString(5), o.GetString(6),
                o.GetString(7), o.GetInt16(8) == 1,
                o.IsDBNull(9) ? null : o.GetDateTime(9), o.GetString(10),
                // 12. kolon YOKSA (aday listesi) ana/ek ayrimi anlamsizdir.
                o.FieldCount > 11 && !o.IsDBNull(11) && o.GetInt16(11) == 1));
        return liste;
    }
}
