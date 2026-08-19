namespace Gentegre.Cekirdek.Sozlesme;

public sealed class GirisIstegi
{
    public string Kod { get; set; } = "";
    public string Parola { get; set; } = "";
    public int? SubeId { get; set; }
}

public sealed class YenileIstegi
{
    public string RefreshToken { get; set; } = "";
}

public sealed class ParolaDegistirIstegi
{
    public string EskiParola { get; set; } = "";
    public string YeniParola { get; set; } = "";
}

public sealed class GirisYaniti
{
    public string AccessToken { get; set; } = "";
    public string RefreshToken { get; set; } = "";
    public DateTime SonaErme { get; set; }            // access token
    public DateTime RefreshSonaErme { get; set; }
    public bool ParolaDegismeli { get; set; }
    /// <summary>
    /// Kullanici birden cok subede calisabiliyor ve giriste sube secmediyse true:
    /// istemci sube secim ekranini gosterir. Token yine de verilir (varsayilan sube ile),
    /// secim yapilinca POST /api/kimlik/sube ile yeni token alinir.
    /// </summary>
    public bool SubeSecimiGerekli { get; set; }
    public KullaniciOzeti Kullanici { get; set; } = new();
}

public sealed class SubeSecIstegi
{
    public int SubeId { get; set; }
}

public sealed class KullaniciOzeti
{
    public int Id { get; set; }                       // = taraf_id
    public string Kod { get; set; } = "";
    public string Ad { get; set; } = "";
    public int RolId { get; set; }
    public string RolAdi { get; set; } = "";
    public long YetkiSurumu { get; set; }
    public int? SubeId { get; set; }
    /// <summary>Aktif subede yazma hakki (kullanici_sube.yazma). 0 ise salt okuma.</summary>
    public bool SubeYazma { get; set; } = true;
    /// <summary>Kullanicinin giris / islem yapabilecegi subeler (kullanici_sube).</summary>
    public IReadOnlyList<SubeOzeti> Subeler { get; set; } = Array.Empty<SubeOzeti>();
}

public sealed record SubeOzeti(int Id, string Ad, bool Varsayilan, bool Yazma);

/// <summary>GET /api/kimlik/ben - profil + cozulmus yetkiler.</summary>
public sealed class BenYaniti
{
    public KullaniciOzeti Kullanici { get; set; } = new();
    public IReadOnlyList<string> Aksiyonlar { get; set; } = Array.Empty<string>();
    public IReadOnlyList<KaynakYetkisi> Kaynaklar { get; set; } = Array.Empty<KaynakYetkisi>();
}

public sealed record KaynakYetkisi(string Kod, bool Gor, bool Ekle, bool Degistir, bool Sil);
