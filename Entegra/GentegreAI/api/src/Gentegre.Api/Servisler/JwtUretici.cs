using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Gentegre.Api.Servisler;

public static class Talep
{
    public const string KullaniciId = "kullaniciId";
    public const string RolId       = "rolId";
    public const string SubeId      = "subeId";
    public const string Subeler     = "subeler";
    public const string YetkiSurumu = "yetkiSurumu";
}

public sealed class JwtUretici
{
    private readonly GuvenlikAyarlari _ayar;
    public JwtUretici(IOptions<GuvenlikAyarlari> ayar) => _ayar = ayar.Value;

    public SecurityKey Anahtar()
        => new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_ayar.ImzaAnahtari));

    /// <summary>
    /// Access token. Yetki LISTESI gomulmez (API §1.1) - yalniz kimlik, rol,
    /// subeler ve yetkiSurumu tasinir; yetki her istekte rolden cozulur.
    /// </summary>
    public (string Token, DateTime SonaErme) Uret(int kullaniciId, int rolId, long yetkiSurumu,
        int? subeId, IEnumerable<int> subeler, int dakika)
    {
        var simdi = DateTime.UtcNow;
        var sonaErme = simdi.AddMinutes(dakika);

        var talepler = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, kullaniciId.ToString(CultureInfo.InvariantCulture)),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
            new(Talep.KullaniciId, kullaniciId.ToString(CultureInfo.InvariantCulture)),
            new(Talep.RolId, rolId.ToString(CultureInfo.InvariantCulture)),
            new(Talep.YetkiSurumu, yetkiSurumu.ToString(CultureInfo.InvariantCulture)),
            new(Talep.Subeler, string.Join(",", subeler))
        };

        if (subeId is { } s)
            talepler.Add(new Claim(Talep.SubeId, s.ToString(CultureInfo.InvariantCulture)));

        var token = new JwtSecurityToken(
            issuer: _ayar.Yayinci,
            audience: _ayar.Hedef,
            claims: talepler,
            notBefore: simdi,
            expires: sonaErme,
            signingCredentials: new SigningCredentials(Anahtar(), SecurityAlgorithms.HmacSha256));

        return (new JwtSecurityTokenHandler().WriteToken(token), sonaErme);
    }

    /// <summary>Refresh token: 32 bayt rastgele. DB'de yalniz SHA-256 ozeti durur.</summary>
    public static (string Token, string Hash) RefreshUret()
    {
        Span<byte> bayt = stackalloc byte[32];
        RandomNumberGenerator.Fill(bayt);
        var token = Base64UrlEncoder.Encode(bayt.ToArray());
        return (token, Hashle(token));
    }

    public static string Hashle(string token)
        => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token))).ToLowerInvariant();
}
