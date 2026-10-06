using System.Collections.Concurrent;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// MENÜDE GİZLENEN EKRANLAR (979 + kullanıcı 06.10.2026: "gizlenen menü hiçbir
/// yerde kullanılamaz").
///
/// <para>Gizleme başta yalnız YERLEŞİMDİ (ekran menüden kalkar, adresi bilen
/// yine açardı). Kullanıcı kararıyla artık <b>kapıdır</b>: gizlenmiş kaynağın
/// listesi ve kartı sunucuda reddedilir. Yetki tablosuna DOKUNULMAZ - gizlilik
/// kaldırılınca ekran eski yetkileriyle geri gelir, kimseye yeniden yetki
/// vermek gerekmez.</para>
///
/// <para><b>Şube başına kısa ömürlü önbellek</b> (60 sn, KimlikKuraliDeposu ile
/// aynı desen): küme her liste/kart isteğinde gerekiyor ama düzen seyrek
/// değişir - her istekte bir sorgu daha atmak süzgeçten pahalı olurdu. Düzeni
/// yazan uç önbelleği hemen düşürür (<see cref="Temizle"/>), yöneticinin
/// kaydettiği gizleme bir dakika beklemeden geçerli olsun.</para>
/// </summary>
public sealed class MenuDuzenDeposu
{
    private static readonly TimeSpan Omur = TimeSpan.FromSeconds(60);
    private static readonly ConcurrentDictionary<int, (IReadOnlySet<string> Kodlar, DateTime Bitis)> Kova
        = new();

    private readonly VeriKaynagi _veri;

    public MenuDuzenDeposu(VeriKaynagi veri) => _veri = veri;

    /// <summary>Şubede menüden gizlenmiş sistem kodları (ekran kaynağı / grup adı).</summary>
    public async Task<IReadOnlySet<string>> GizliKodlarAsync(int subeId,
        CancellationToken iptal = default)
    {
        if (Kova.TryGetValue(subeId, out var kayit) && kayit.Bitis > DateTime.UtcNow)
            return kayit.Kodlar;

        var kume = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            // ŞUBE SATIRI KURUM GENELİNİ EZER: aynı kodda iki satır varsa
            //   (biri sube_id null) şubeninki geçerli - gizli/görünür kararı da ondan.
            await using var komut = baglanti.Komut("""
                select distinct on (d.sistem_kod) d.sistem_kod, d.gizli
                  from public.menu_duzen d
                 where d.sube_id is null or d.sube_id = @p0
                 order by d.sistem_kod, d.sube_id nulls last
                """, null, subeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal))
                if (o.GetInt16(1) == 1) kume.Add(o.GetString(0));
        }
        catch (Npgsql.PostgresException h) when (h.SqlState == "42P01")
        {
            // Tablo henüz göç edilmemiş kurulum: gizleme yok sayılır. Menüyü
            //   hiç çizmemektense düzenlenmemiş çizmek doğru - 979 uygulanınca
            //   kendiliğinden devreye girer.
        }

        IReadOnlySet<string> sonuc = kume;
        Kova[subeId] = (sonuc, DateTime.UtcNow.Add(Omur));
        return sonuc;
    }

    /// <summary>Düzen yazıldığında çağrılır - bir sonraki istek yeniden okur.</summary>
    public static void Temizle(int subeId) => Kova.TryRemove(subeId, out _);
}
