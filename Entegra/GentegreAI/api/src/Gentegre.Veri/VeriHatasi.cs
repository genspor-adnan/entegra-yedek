using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri;

/// <summary>
/// PostgreSQL kisit ihlallerini sozlesme hatasina cevirir. Aksi halde kullanici
/// "Beklenmeyen bir hata olustu" goruyor ve HANGI alanin sorunlu oldugunu ogrenemiyor
/// (gercek vaka: yeni cari kaydinda durum kolonuna null gidince 500 donuyordu).
/// </summary>
public static class VeriHatasi
{
    public static GentegreHatasi? Cevir(PostgresException h) => h.SqlState switch
    {
        // not null violation
        "23502" => GentegreHatasi.Dogrulama(
            $"{Alan(h)} bos birakilamaz.",
            new AlanHatasi(Alan(h), "Zorunlu alan.")),

        // unique violation
        "23505" => GentegreHatasi.IsKurali(BenzersizMesaji(h)),

        // foreign key violation
        "23503" => GentegreHatasi.IsKurali(
            "Baglantili kayit bulunamadi ya da baska kayitlar tarafindan kullaniliyor."),

        // check violation
        "23514" => GentegreHatasi.Dogrulama(
            $"Deger kurala uymuyor{(h.ConstraintName is null ? "" : $" ({h.ConstraintName})")}."),

        // string too long
        "22001" => GentegreHatasi.Dogrulama("Girilen deger alanin izin verdiginden uzun."),

        // numeric/tarih cevrim hatasi
        "22P02" or "22003" => GentegreHatasi.Dogrulama("Sayisal ya da tarih degeri cozulemedi."),

        // DB tetikleyicilerinin bilerek firlattigi IS KURALI (bkz. kasa motoru,
        //   depo kurallari): mesaj kullaniciya gosterilmek uzere yazilmistir.
        "GK422" => GentegreHatasi.IsKurali(h.MessageText),

        _ => null
    };

    /// <summary>
    /// Bilinen benzersizlik kisitlari icin kullanicinin anlayacagi mesaj. Ham kisit
    /// adi ("ux_depo_ad") kullaniciya bir sey anlatmiyor.
    /// </summary>
    private static readonly Dictionary<string, string> BenzersizMesajlari = new(StringComparer.Ordinal)
    {
        ["ux_depo_ad"] = "Bu depo adı zaten kullanılıyor.",
        ["ux_depo_varsayilan"] = "Yalnizca bir depo varsayilan olabilir."
    };

    private static string BenzersizMesaji(PostgresException h)
        => h.ConstraintName is not null && BenzersizMesajlari.TryGetValue(h.ConstraintName, out var m)
            ? m
            : $"Ayni kayit zaten var{(h.ConstraintName is null ? "" : $" ({h.ConstraintName})")}.";

    /// <summary>PG kolon adi (snake_case) -> API alan adi (camelCase).</summary>
    private static string Alan(PostgresException h)
    {
        var kolon = h.ColumnName;
        if (string.IsNullOrEmpty(kolon)) return "alan";

        var sonuc = new System.Text.StringBuilder(kolon.Length);
        var buyuk = false;
        foreach (var c in kolon)
        {
            if (c == '_') { buyuk = true; continue; }
            sonuc.Append(buyuk ? char.ToUpperInvariant(c) : c);
            buyuk = false;
        }
        return sonuc.ToString();
    }
}
