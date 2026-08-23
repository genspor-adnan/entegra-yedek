using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// Genel Ayarlar ekranindaki tek satir (public.referans). <c>YardimBaslik</c> /
/// <c>Yardim</c> alan yanindaki "?" ikonunun gosterdigi metindir (public.help,
/// anahtar "ayar.&lt;referans anahtari&gt;") - ekranda paragraf olarak durmaz.
/// </summary>
public sealed record AyarSatiri(string Anahtar, string Deger, string Tip, string Aciklama,
    string YardimBaslik = "", string Yardim = "");

/// <summary>public.help satiri - "?" ikonunun gosterdigi metin.</summary>
public sealed record YardimKaydi(string Anahtar, string Baslik, string Metin);

/// <summary>
/// Firma geneli ayarlar - <c>public.referans</c> tablosu.
///
/// BEYAZ LISTE ile calisir: ekran yalnizca burada tanimli anahtarlari gorur ve
/// yazabilir. referans tablosunda gocten gelen yuzlerce eski opsiyon (ops_*)
/// var; hepsini ayar ekranina dokmek ne anlasilir ne guvenli olurdu.
///
/// DEGER OKUMA UCUZ OLMALI: belge kaydinin her cagrisinda okunuyor, o yuzden
/// sayisal ayarlar 60 saniyelik bellek onbelleginde tutulur (ayar yazilinca
/// onbellek hemen dusurulur).
/// </summary>
public sealed class AyarDeposu
{
    private readonly VeriKaynagi _veri;

    /// <summary>Ekranda gosterilen/yazilabilen ayarlar.</summary>
    public static readonly IReadOnlyList<string> BeyazListe = new[]
    {
        "belge.geri_gun_siniri",
        "liste.sayfa_boyu",
    };

    /// <summary>Ayar yoksa kullanilan degerler - DB'siz de dogru davranis.</summary>
    private static readonly Dictionary<string, int> Varsayilan = new()
    {
        ["belge.geri_gun_siniri"] = 7,
        ["liste.sayfa_boyu"] = 50,
    };

    /// <summary>Sayisal ayarlarin kabul araligi (yoksa yalniz "0 veya buyuk" kurali).</summary>
    private static readonly Dictionary<string, (int EnAz, int EnCok)> Aralik = new()
    {
        // Sunucu tek istekte 500'den fazlasini gondermiyor (ListeIstegi.EnBuyukBoyut);
        //   10'un altinda sayfalama ekrani surekli istek atmaya cevirir.
        ["liste.sayfa_boyu"] = (10, 500),
    };

    private static readonly Dictionary<string, (int Deger, DateTime Zaman)> Onbellek = new();
    private static readonly TimeSpan OnbellekSuresi = TimeSpan.FromSeconds(60);
    private static readonly object Kilit = new();

    public AyarDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<IReadOnlyList<AyarSatiri>> ListeleAsync(CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand("""
            select r.anahtar, r.deger, r.tip, r.aciklama,
                   coalesce(h.baslik, ''), coalesce(h.metin, '')
              from public.referans r
              left join public.help h
                     on h.anahtar = 'ayar.' || r.anahtar and h.dil = 0
             where r.anahtar = any(@p0)
             order by r.anahtar
            """, baglanti);
        komut.Parameters.AddWithValue("p0", BeyazListe.ToArray());

        var liste = new List<AyarSatiri>();
        await using var o = await komut.ExecuteReaderAsync(iptal);
        while (await o.ReadAsync(iptal))
            liste.Add(new AyarSatiri(o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3),
                                     o.GetString(4), o.GetString(5)));

        // DB'de henuz satiri olmayan ayar da ekranda gorunsun (varsayilaniyla).
        foreach (var anahtar in BeyazListe)
            if (!liste.Any(x => x.Anahtar == anahtar))
                liste.Add(new AyarSatiri(anahtar,
                    Varsayilan.TryGetValue(anahtar, out var v) ? v.ToString() : "", "sayi", ""));

        return liste;
    }

    public async Task<IReadOnlyList<AyarSatiri>> YazAsync(string anahtar, string deger,
        YazmaBaglami baglam, CancellationToken iptal = default)
    {
        if (!BeyazListe.Contains(anahtar))
            throw GentegreHatasi.Dogrulama($"Bilinmeyen ayar: {anahtar}",
                new AlanHatasi("anahtar", "Böyle bir ayar yok."));

        // Sayisal ayarlarda deger dogrulanir: "abc" yazilirsa belge kaydi patlardi.
        if (Varsayilan.ContainsKey(anahtar))
        {
            if (!int.TryParse(deger, out var sayi) || sayi < 0)
                throw GentegreHatasi.Dogrulama("Değer 0 veya daha büyük bir tam sayı olmalı.",
                    new AlanHatasi("deger", "Geçersiz sayı."));

            if (Aralik.TryGetValue(anahtar, out var sinir) &&
                (sayi < sinir.EnAz || sayi > sinir.EnCok))
                throw GentegreHatasi.Dogrulama(
                    $"Değer {sinir.EnAz} ile {sinir.EnCok} arasında olmalı.",
                    new AlanHatasi("deger", $"{sinir.EnAz}-{sinir.EnCok}"));

            deger = sayi.ToString();
        }

        await using var baglanti = await _veri.AcAsync(iptal);
        await using (var komut = new NpgsqlCommand("""
            insert into public.referans (anahtar, deger, tip, kapsam, degistiren, degistirme_tarihi)
            values (@p0, @p1, 'sayi', 'firma', @p2, now()::timestamp)
            on conflict (anahtar) do update
               set deger = excluded.deger, degistiren = excluded.degistiren,
                   degistirme_tarihi = excluded.degistirme_tarihi,
                   guncelleme = now()::timestamp
            """, baglanti))
        {
            komut.Parameters.AddWithValue("p0", anahtar);
            komut.Parameters.AddWithValue("p1", deger);
            komut.Parameters.AddWithValue("p2", baglam.KullaniciId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        lock (Kilit) Onbellek.Remove(anahtar);
        return await ListeleAsync(iptal);
    }

    /// <summary>
    /// Tek bir yardim metni (public.help). Ayar disindaki ekranlar da ayni ucu
    /// kullanir - anahtar duzeni "kart.&lt;kart&gt;.&lt;alan&gt;" gibi genisler.
    /// </summary>
    public async Task<YardimKaydi?> YardimAsync(string anahtar, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var komut = new NpgsqlCommand(
            "select baslik, metin from public.help where anahtar = @p0 and dil = 0", baglanti);
        komut.Parameters.AddWithValue("p0", anahtar);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        return await o.ReadAsync(iptal) ? new YardimKaydi(anahtar, o.GetString(0), o.GetString(1)) : null;
    }

    /// <summary>
    /// Sayisal ayari okur (60 sn onbellekli). Ayni baglanti/transaction icinden
    /// cagrilabilsin diye baglanti disaridan verilir - belge kaydi ortasinda
    /// ikinci bir baglanti acmak havuzu bosuna mesgul ederdi.
    /// </summary>
    public static async Task<int> SayiAsync(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string anahtar, CancellationToken iptal = default)
    {
        lock (Kilit)
            if (Onbellek.TryGetValue(anahtar, out var kayit) &&
                DateTime.UtcNow - kayit.Zaman < OnbellekSuresi)
                return kayit.Deger;

        var sonuc = Varsayilan.TryGetValue(anahtar, out var v) ? v : 0;
        await using (var komut = new NpgsqlCommand(
            "select deger from public.referans where anahtar = @p0", baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", anahtar);
            if (await komut.ExecuteScalarAsync(iptal) is string metin &&
                int.TryParse(metin, out var okunan))
                sonuc = okunan;
        }

        lock (Kilit) Onbellek[anahtar] = (sonuc, DateTime.UtcNow);
        return sonuc;
    }
}
