namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// ACİL SERVİS KOD SÖZLÜKLERİ — tek kaynak (liste kataloğu, kart kataloğu ve
/// SQL etiketleri aynı yerden).
///
/// <para><b>Üç yerde üç farklı metin vardı.</b> Çıkış şekli hem liste
/// kataloğunda (<c>case b.cikis_sekli …</c> ve kolon kod sözlüğü) hem kart
/// kataloğunda yazılıydı; ikisinde "Sevk", ekranın çıkış penceresinde "Sevk
/// (başka kuruma)". Geliş şekli listede "Sevk", kartta "Başka kurumdan sevk"
/// diyordu - aynı başvuru, iki ekranda iki cevap.</para>
///
/// <para><b>SQL etiketi de buradan üretilir</b> (<see cref="KodAdiIfadesi"/>):
/// sözlüğü güncelleyip <c>case</c> ifadesini güncellemeyi unutmak, gridde yeni
/// kodun boş görünmesiydi.</para>
///
/// <para><b>Kart kataloğunun "(açık)" satırı burada değil:</b> o, kodun kendi
/// anlamı değil - kartta "çıkış yapılmamış" durumunu göstermenin yolu. Kart
/// kataloğu sözlüğü alıp başına onu ekliyor.</para>
///
/// <para>SQL etiketini <see cref="KodIfadesi.KodAdi"/> üretir (Medula kataloğu
/// da aynı yardımcıyı kullanıyor).</para>
///
/// <para>Acil kodları için veritabanında kod listesi YOK (<c>kod_liste</c>'de
/// <c>acil.*</c> satırı yok): bu dosya kanonik kaynaktır. İstemci tarafındaki
/// karşılığı <c>web/src/bilesenler/acil/acilKodlari.ts</c> - oradaki metinler
/// buradakilerle aynı tutulur.</para>
/// </summary>
public static class AcilKodlari
{
    /// <summary>
    /// <c>acil_basvuru.triyaj</c> — sayı BÜYÜDÜKÇE aciliyet AZALIR (1 = kırmızı).
    /// 0, triyajı henüz yapılmamış başvurudur.
    /// </summary>
    public static readonly Dictionary<string, string> Triyaj = new()
    {
        ["1"] = "1 Kırmızı (resüsitasyon)", ["2"] = "2 Turuncu (acil)",
        ["3"] = "3 Sarı (acele)", ["4"] = "4 Yeşil (az acil)", ["5"] = "5 Mavi (acil değil)",
        ["0"] = "Triyaj bekliyor",
    };

    /// <summary>Triyajın RENK adı - grid rozeti ve pano için (dar sütun).</summary>
    public static readonly Dictionary<string, string> TriyajRenk = new()
    {
        ["1"] = "Kırmızı", ["2"] = "Turuncu", ["3"] = "Sarı", ["4"] = "Yeşil",
        ["5"] = "Mavi", ["0"] = "Triyaj bekliyor",
    };

    /// <summary><c>acil_basvuru.gelis_sekli</c>.</summary>
    public static readonly Dictionary<string, string> GelisSekli = new()
    {
        ["1"] = "Kendi imkânı", ["2"] = "112 ambulans", ["3"] = "Özel ambulans",
        ["4"] = "Polis/Jandarma", ["5"] = "Başka kurumdan sevk", ["9"] = "Diğer",
    };

    /// <summary><c>acil_basvuru.cikis_sekli</c>; 0 = çıkış yapılmadı (burada yok).</summary>
    public static readonly Dictionary<string, string> CikisSekli = new()
    {
        ["1"] = "Taburcu", ["2"] = "Servise yatış", ["3"] = "Yoğun bakım",
        ["4"] = "Sevk (başka kuruma)", ["5"] = "Ölüm",
        ["6"] = "Kendi isteğiyle ayrıldı", ["7"] = "Ameliyathane",
    };

    /// <summary>Grid sütunu dar: çıkış şeklinin kısa adı.</summary>
    public static readonly Dictionary<string, string> CikisSekliKisa = new()
    {
        ["1"] = "Taburcu", ["2"] = "Servise yatış", ["3"] = "Yoğun bakım",
        ["4"] = "Sevk", ["5"] = "Ölüm", ["6"] = "Kendi isteğiyle", ["7"] = "Ameliyathane",
    };

    /// <summary><c>acil_cagri.tur</c> — konsültasyon ve renk kodları.</summary>
    public static readonly Dictionary<string, string> CagriTuru = new()
    {
        ["1"] = "Konsültasyon", ["2"] = "Mavi Kod", ["3"] = "Beyaz Kod",
        ["4"] = "Pembe Kod", ["5"] = "Kateter Lab", ["6"] = "Ameliyathane",
        ["7"] = "Yoğun Bakım",
    };

}
