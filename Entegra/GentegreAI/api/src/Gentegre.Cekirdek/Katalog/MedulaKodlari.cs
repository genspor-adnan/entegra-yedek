namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// MEDULA KOD SÖZLÜKLERİ — liste kataloğunun etiketleri tek yerden.
///
/// <para><b>Neden:</b> işlem / fatura / dönem durumlarının metni liste
/// kataloğunda SQL <c>case</c> ifadesi olarak yazılıydı ve aynı kodlar
/// istemcide rozet sözlüğü olarak duruyordu
/// (<c>web/src/api/uclar/medula.ts</c>). İki tarafı ayrı ayrı güncellemek
/// gerekiyordu; işlem durumunda <c>0</c> kodu sunucuda hiç yoktu ve gönderilmemiş
/// hizmet kaydı gridde <b>boş</b> görünüyordu - istemci ona "Gönderilmedi"
/// diyor.</para>
///
/// <para><b>Metin farkı bilinçli olanlar:</b> grid sütunları dar, bu yüzden
/// sunucu kısa yazar ("Ücretli"); ekranın kendi rozetinde uzun hâli var
/// ("Ücretli (yerel)"). Medula için veritabanında kod listesi yok, kanonik
/// kaynak bu dosyadır.</para>
///
/// <para><b>Takip durumu burada DEĞİL:</b> onun etiketi tek kolona bakmıyor -
/// onaylı takip, çıkış zamanı varsa "Kapatıldı", yoksa "Açık takip" olarak
/// yazılıyor; koşullu ifade liste kataloğunda kalır.</para>
/// </summary>
public static class MedulaKodlari
{
    /// <summary><c>medula_islem.durum</c> — hizmet kaydının Medula'ya gönderim durumu.</summary>
    public static readonly Dictionary<string, string> IslemDurum = new()
    {
        ["0"] = "Gönderilmedi", ["1"] = "Bekliyor", ["2"] = "Kabul", ["3"] = "Hata",
        ["4"] = "İptal", ["5"] = "Ücretli",
    };

    /// <summary><c>medula_fatura.fatura_turu</c>.</summary>
    public static readonly Dictionary<string, string> FaturaTuru = new()
    {
        ["1"] = "Ayaktan", ["2"] = "Yatan", ["3"] = "Günübirlik", ["4"] = "Acil",
    };

    /// <summary><c>medula_fatura.durum</c>.</summary>
    public static readonly Dictionary<string, string> FaturaDurum = new()
    {
        ["1"] = "Taslak", ["2"] = "Kaydedildi", ["3"] = "Dönemde", ["4"] = "Dönem kapandı",
        ["5"] = "İncelendi", ["6"] = "Ödendi", ["7"] = "İptal",
    };

    /// <summary><c>medula_donem.durum</c>.</summary>
    public static readonly Dictionary<string, string> DonemDurum = new()
    {
        ["1"] = "Açık", ["2"] = "Sonlandırıldı", ["3"] = "İncelemede", ["4"] = "Kapandı",
    };

    /// <summary><c>medula_rapor.durum</c> — e-Rapor (ilaç / cihaz raporu).</summary>
    public static readonly Dictionary<string, string> RaporDurum = new()
    {
        ["1"] = "Taslak", ["2"] = "İmzalı", ["3"] = "Medula kabul", ["4"] = "İptal",
        ["5"] = "Hata",
    };

    /// <summary><c>medula_kuyruk.durum</c> — gönderim kuyruğu.</summary>
    public static readonly Dictionary<string, string> KuyrukDurum = new()
    {
        ["1"] = "Bekliyor", ["2"] = "Gönderildi", ["3"] = "Kabul", ["4"] = "Hata",
        ["5"] = "Elle müdahale", ["6"] = "İptal",
    };
}
