namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// KOD SÖZLÜĞÜNDEN SQL ETİKETİ — liste kataloğunun <c>case</c> ifadelerini
/// sözlükten üretir.
///
/// <para><b>Neden:</b> aynı kodların metni hem kolon kod sözlüğünde (kartta ve
/// filtrede görünen), hem de grid kolonunun SQL <c>case</c> ifadesinde
/// yazılıyordu. Sözlüğe yeni kod eklenip <c>case</c>'in güncellenmemesi, o
/// kodun gridde boş görünmesi demek - sessiz ve bulması zor.</para>
///
/// <para>İlk kullanıcı acil (<see cref="AcilKodlari"/>) ve Medula
/// (<see cref="MedulaKodlari"/>) kataloglarıdır. Koşula bağlı etiketler
/// (ör. "açık takip / kapatıldı" ayrımı gibi iki kolona bakanlar) burada
/// üretilmez - onlar kendi <c>case</c> ifadelerinde kalır.</para>
/// </summary>
public static class KodIfadesi
{
    /// <param name="kolon">Kod kolonu, tablo takma adıyla (<c>i.durum</c>).</param>
    /// <param name="kodlar">Kod → etiket sözlüğü.</param>
    /// <param name="bosDeger">Sözlükte olmayan kodun SQL literali.</param>
    public static string KodAdi(string kolon, IReadOnlyDictionary<string, string> kodlar,
                               string bosDeger = "''")
    {
        var sb = new System.Text.StringBuilder($"case {kolon}");
        foreach (var (kod, ad) in kodlar.OrderBy(x => x.Key, StringComparer.Ordinal))
            sb.Append($" when {kod} then '{ad.Replace("'", "''")}'");
        return sb.Append($" else {bosDeger} end").ToString();
    }
}
