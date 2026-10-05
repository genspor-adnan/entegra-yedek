namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// RADYOLOJİ SQL İFADELERİ — modalite kodunun adı TEK YERDE.
///
/// <para>Modalite <c>case</c> ifadesi on üç yerde kopyalanmıştı: altı liste
/// kataloğunda (radyoloji + teleradyoloji + nöbet), üç uç sorgusunda ve
/// aralarında yalnız kolon adı ile boş değerin metni değişiyordu. Dokuzuncu
/// bir modalite (PET, sintigrafi) eklendiğinde on üç yerden on ikisi eski
/// kalırdı ve aynı tetkik bir ekranda "PET", ötekinde boş görünürdü.</para>
///
/// <para><b>Kod listesi veritabanında</b> (<c>rad.modalite</c>); buradaki
/// ifade onun SQL karşılığıdır. Liste kataloğu kod listesini çalışma anında
/// okumuyor (kolon tanımı statiktir), bu yüzden metinler iki yerde durur -
/// ama en azından <b>bir</b> yerde durur.</para>
/// </summary>
public static class RadyolojiIfadeleri
{
    /// <summary>Veritabanındaki kod listesi: <c>rad.modalite</c>.</summary>
    public const string ModaliteKodListesi = "rad.modalite";

    /// <param name="kolon">Modalite kolonu, tablo takma adıyla (örn. <c>i.modalite</c>).</param>
    /// <param name="bosDeger">
    /// Eşleşmeyen kodun metni - SQL literali olarak verilir. Ekranlar farklı
    /// şey yazıyor: liste boş bırakıyor, nöbet çizelgesi "Tümü" (modalitesiz
    /// nöbet her modaliteyi kapsar), başvuru istemi "Görüntüleme".
    /// </param>
    public static string ModaliteAdi(string kolon, string bosDeger = "''")
        => $"case {kolon} when 1 then 'BT' when 2 then 'MR' when 3 then 'USG' "
           + "when 4 then 'Röntgen' when 5 then 'Mamografi' when 6 then 'DEXA' "
           + $"when 7 then 'Anjiyo' when 8 then 'Skopi' else {bosDeger} end";
}
