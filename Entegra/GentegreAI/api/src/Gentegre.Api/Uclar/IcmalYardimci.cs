using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İCMAL UÇLARININ ORTAK YARDIMCILARI (refaktör 20.11.2026, dokuman/REFAKTOR_RAPORU_2026-11-20.md B3).
///
/// Aynı üç yardımcı icmal dosyalarında harfi harfine kopyaydı (şube çözümü 7, yuvarlama 12, yüzde 6 dosyada). Şube
/// çözümü GÜVENLİKLE ilgili - tek yerde durmalı. Dosyalar <c>using static</c> ile alır; çağrı yerleri değişmedi.
/// Ortalama / medyan / null dönen yüzde kopyaları BİRBİRİNDEN FARKLI (tip ve yuvarlama) - onlar dosyalarında kaldı.
/// </summary>
internal static class IcmalYardimci
{
    /// <summary>İstenen şube (0 / boş = yetkili bütün şubeler). Kullanıcının yetkisi olmayan şube istenirse YASAK.</summary>
    internal static int SubeCoz(IstekBaglami baglam, int? sube)
    {
        var s = sube ?? 0;
        if (s > 0 && baglam.Subeler.All(x => x.Id != s))
            throw GentegreHatasi.Yasak("Bu şubenin verisini görme yetkiniz yok.");
        return s;
    }

    /// <summary>Para: iki hane.</summary>
    internal static decimal R(decimal d) => Math.Round(d, 2);

    /// <summary>a'nın b'ye yüzdesi, bir hane; payda 0 ise 0.</summary>
    internal static decimal Yuzde(decimal a, decimal b) => b != 0 ? Math.Round(100m * a / b, 1) : 0m;
}
