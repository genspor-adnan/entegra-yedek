using System.Text.RegularExpressions;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KİMLİK NO BİÇİMİ (679) — kurum profilinden gelen doğrulama kuralı.
///
/// 678'de etiket genelleşti ("Kimlik No") ama kural hâlâ T.C. kimlik
/// algoritmasıydı. Türkiye dışındaki bir kurulumda o kural hastanın gerçek
/// numarasını reddedip kaydı imkânsız kılar; kuralı topluca kapatmak ise
/// Türkiye'de yanlış TCKN'nin sessizce geçmesi demektir - hata aylar sonra
/// "MEDULA provizyonu alınamıyor" olarak döner. Bu yüzden biçim bir KURULUM
/// AYARIDIR.
///
/// <c>otomatik</c> DB'de (fn_kimlik_kurali) çözülür: sunucu ile istemci aynı
/// cevabı almalı, yoksa ekranın kabul edip sunucunun reddettiği bir numara
/// olurdu.
/// </summary>
public sealed record KimlikKurali(string Bicim, string Desen = "", string Aciklama = "")
{
    public const string Tc = "tc";
    public const string Serbest = "serbest";
    public const string Desenli = "desen";

    /// <summary>Ayar okunamadığında kullanılan kural: KONTROL AÇIK kalır.</summary>
    public static readonly KimlikKurali Varsayilan = new(Tc);

    /// <summary>
    /// İstemciye gidecek kural adı - kart alanının `Dogrulama` değeri bununla
    /// değiştirilir. Desenli kuralda desen de taşınır ("desen:^[A-Z0-9]{6,12}$"),
    /// çünkü ekran aynı kontrolü yazarken uygulamalı.
    /// </summary>
    public string IstemciKurali => Bicim switch
    {
        Tc => KimlikDogrulama.TcknTuru,
        Desenli when Desen.Length > 0 => $"desen:{Desen}",
        _ => "",                       // serbest: ekran biçim kontrolü yapmaz
    };

    /// <summary>Geçersizse kullanıcıya gidecek mesaj, geçerliyse null.</summary>
    public string? Hata(string? deger)
    {
        var metin = (deger ?? "").Trim();
        // BOŞ DEĞER GEÇERLİ: zorunluluk ayrı bir karardır (kimliği belirsiz
        //   hasta numarasız açılabilir).
        if (metin.Length == 0) return null;

        return Bicim switch
        {
            Tc => KimlikDogrulama.TcknGecerli(metin)
                ? null
                : "Kimlik numarası geçersiz - 11 hane olmalı ve doğrulama hanesi tutmalı.",
            Desenli when Desen.Length > 0 => DesenTutar(metin)
                ? null
                : (Aciklama.Length > 0
                    ? $"Kimlik numarası beklenen biçimde değil: {Aciklama}"
                    : "Kimlik numarası beklenen biçimde değil."),
            _ => null,
        };
    }

    /// <summary>
    /// Desen BOZUKSA kayıt ENGELLENMEZ: ayarı yanlış yazan yönetici yüzünden
    /// kayıt kabulün durması, kontrolün o kurulumda çalışmamasından kötüdür.
    /// Zaman sınırı, kötü yazılmış bir desenin isteği kilitlemesine karşı.
    /// </summary>
    private bool DesenTutar(string metin)
    {
        try { return Regex.IsMatch(metin, Desen, RegexOptions.CultureInvariant,
                                   TimeSpan.FromMilliseconds(100)); }
        catch (ArgumentException) { return true; }
        catch (RegexMatchTimeoutException) { return true; }
    }
}
