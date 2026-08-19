namespace Gentegre.Cekirdek.Yetki;

/// <summary>
/// DB'deki fn_kullanici_yetkileri satiri. tur = 0 kaynak (gor/ekle/degistir/sil),
/// tur = 1 aksiyon (yalniz Gor = calistirma izni).
/// </summary>
public sealed record YetkiKaydi(
    string Kod,
    short Tur,
    bool Gor,
    bool Ekle,
    bool Degistir,
    bool Sil);

/// <summary>Alan bazli yetki: 0 gizle, 1 oku, 2 oku + yaz. Satir YOKSA alan serbest.</summary>
public sealed record AlanYetkisi(string Kaynak, string Alan, short Izin);

public enum Islem { Gor, Ekle, Degistir, Sil }

/// <summary>
/// Bir kullanicinin cozulmus yetkileri. Token'a GOMULMEZ - her istekte rolden
/// cozulur, kisa sureli onbellege alinir (bkz. YetkiCozucu).
/// </summary>
public sealed class YetkiSeti
{
    private readonly Dictionary<string, YetkiKaydi> _yetkiler;
    private readonly Dictionary<string, short> _alanlar;   // "kaynak.alan" -> izin

    public long YetkiSurumu { get; }

    public YetkiSeti(long yetkiSurumu,
                     IEnumerable<YetkiKaydi> yetkiler,
                     IEnumerable<AlanYetkisi> alanYetkileri)
    {
        YetkiSurumu = yetkiSurumu;
        _yetkiler = yetkiler.ToDictionary(y => y.Kod, StringComparer.Ordinal);
        _alanlar = alanYetkileri.ToDictionary(
            a => a.Kaynak + "." + a.Alan, a => a.Izin, StringComparer.Ordinal);
    }

    public bool Var(string kaynakKodu, Islem islem)
    {
        if (!_yetkiler.TryGetValue(kaynakKodu, out var y)) return false;
        return islem switch
        {
            Islem.Gor      => y.Gor,
            Islem.Ekle     => y.Ekle,
            Islem.Degistir => y.Degistir,
            Islem.Sil      => y.Sil,
            _              => false
        };
    }

    /// <summary>Aksiyon yetkisi (tur = 1): 'ebelge.gonder' gibi.</summary>
    public bool AksiyonVar(string aksiyonKodu)
        => _yetkiler.TryGetValue(aksiyonKodu, out var y) && y.Gor;

    /// <summary>Alan okunabilir mi (izin 1 ya da 2, ya da hic kayit yok = serbest).</summary>
    public bool AlanOkunur(string kaynak, string alan)
        => !_alanlar.TryGetValue(kaynak + "." + alan, out var izin) || izin >= 1;

    /// <summary>Alana yazilabilir mi (izin 2, ya da hic kayit yok = serbest).</summary>
    public bool AlanYazilir(string kaynak, string alan)
        => !_alanlar.TryGetValue(kaynak + "." + alan, out var izin) || izin >= 2;

    public IEnumerable<YetkiKaydi> Tumu => _yetkiler.Values;
}
