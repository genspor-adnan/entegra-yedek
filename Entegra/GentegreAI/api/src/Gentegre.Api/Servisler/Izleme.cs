using System.Security.Cryptography;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ULID uretici - hata yanitindaki "izlemeNo" (API §1.2) ve liste yanitindaki
/// izleme numarasi. Zaman onekli oldugu icin siralanabilir, GUID'den kisadir.
/// </summary>
public static class Izleme
{
    private const string Alfabe = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";   // Crockford base32

    public static string YeniNo()
    {
        var zaman = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        Span<char> tampon = stackalloc char[26];

        for (var i = 9; i >= 0; i--)
        {
            tampon[i] = Alfabe[(int)(zaman & 31)];
            zaman >>= 5;
        }

        Span<byte> rastgele = stackalloc byte[16];
        RandomNumberGenerator.Fill(rastgele);
        for (var i = 0; i < 16; i++) tampon[10 + i] = Alfabe[rastgele[i] & 31];

        return new string(tampon);
    }
}
