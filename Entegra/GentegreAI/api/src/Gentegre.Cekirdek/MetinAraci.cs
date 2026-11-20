namespace Gentegre.Cekirdek;

/// <summary>
/// METİN KISALTMA - tek yer (refaktör 20.11.2026, dokuman/REFAKTOR_RAPORU_2026-11-20.md A4).
///
/// Kolon sınırına sığdırma her dosyada ayrı bir özel `Kirp` / `Kisalt` olarak yazılmıştı (~30 kopya) ve kopyalar
/// aynı davranmıyordu. Üç davranış var; ad davranışı söyler:
///  * <see cref="Kes"/>      - olduğu gibi keser (boşluk kırpmaz).
///  * <see cref="KirpKes"/>  - baştaki / sondaki boşluğu atar, sonra keser.
///  * <see cref="KesUc"/>    - keser ve kesildiyse sonuna "…" koyar (ekranda / günlükte okunacak metin; sonuç sınırdan
///                             BİR karakter uzun olabilir - kolon sınırı için kullanılmaz).
/// Üçü de null için "" döner.
/// </summary>
public static class MetinAraci
{
    public static string Kes(string? metin, int azami)
        => string.IsNullOrEmpty(metin) ? "" : metin.Length <= azami ? metin : metin[..azami];

    public static string KirpKes(string? metin, int azami)
    {
        var t = (metin ?? "").Trim();
        return t.Length > azami ? t[..azami] : t;
    }

    public static string KesUc(string? metin, int azami)
        => string.IsNullOrEmpty(metin) ? "" : metin.Length <= azami ? metin : metin[..azami] + "…";
}
