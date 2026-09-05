namespace Gentegre.Cekirdek.Bildirim;

/// <summary>Bildirim kanalı (399, kod listesi <c>bildirim.kanal</c>).</summary>
public enum BildirimKanali : short
{
    Sms = 1,
    Eposta = 2,
    Push = 3,
    WhatsApp = 4,
}

/// <summary>Kuyruk durumu (399, kod listesi <c>bildirim.durum</c>).</summary>
public enum BildirimDurumu : short
{
    Kuyrukta = 1,
    Gonderiliyor = 2,
    Gonderildi = 3,
    Hata = 4,
    Iptal = 5,
    Vazgecildi = 6,     // en fazla deneme aşıldı
}

/// <summary>
/// Kuyruğa bir bildirim koyma isteği. Çağıran ya ŞABLON KODU verir (metin
/// şablondan üretilir) ya da doğrudan gövdeyi yazar — ikisi de olur.
/// </summary>
public sealed record BildirimIstegi(
    string? SablonKodu,
    BildirimKanali? Kanal,
    string Alici,
    IReadOnlyDictionary<string, string>? Degiskenler = null,
    string? Konu = null,
    string? Govde = null,
    int? TarafId = null,
    int? KullaniciId = null,
    short KaynakTur = 9,
    int? KaynakId = null,
    short Oncelik = 5,
    DateTime? Planlanan = null,
    int? HesapId = null);

/// <summary>Gönderilmeyi bekleyen tek kayıt — işçi bunu sağlayıcıya verir.</summary>
public sealed record BildirimKaydi(
    long Id,
    BildirimKanali Kanal,
    string Alici,
    string Konu,
    string Govde,
    int? HesapId,
    short Deneme,
    short EnFazlaDeneme);

/// <summary>Sağlayıcı yanıtı.</summary>
public sealed record GonderimSonucu(bool Basarili, string SaglayiciRef = "", string Hata = "",
                                    int HttpDurum = 0, string? HamYanit = null);

/// <summary>
/// BİLDİRİM SAĞLAYICISI — SMS/e-posta/push arasındaki tek ortak yüz.
///
/// Sağlayıcı seçimi bir Faz 0 KAPISIDIR (sözleşme işi) ve henüz kapanmadı;
/// bu yüzden kod sağlayıcıya değil bu arayüze bağlanır. Kurulumda hangi
/// sağlayıcının kullanılacağı <c>entegrasyon_hesap</c> satırıyla belli olur —
/// yeni sağlayıcı = yeni uygulama sınıfı, kuyruk ve ekran değişmez.
/// </summary>
public interface IBildirimGonderici
{
    /// <summary>Bu sağlayıcı hangi kanalı gönderir.</summary>
    BildirimKanali Kanal { get; }

    Task<GonderimSonucu> GonderAsync(BildirimKaydi kayit, CancellationToken iptal);
}

/// <summary>
/// Şablon gövdesindeki <c>{{degisken}}</c> yer tutucularını doldurur.
///
/// Bilinmeyen değişken OLDUĞU GİBİ BIRAKILIR (silinmez): "{{hasta_ad}}" metni
/// gönderilmiş bir SMS'te görülürse hata bellidir; boş bırakılsa mesaj sessizce
/// eksik giderdi.
/// </summary>
public static class BildirimSablonu
{
    public static string Doldur(string metin, IReadOnlyDictionary<string, string>? degerler)
    {
        if (string.IsNullOrEmpty(metin) || degerler is null || degerler.Count == 0) return metin;
        var sonuc = new System.Text.StringBuilder(metin);
        foreach (var (ad, deger) in degerler)
            sonuc.Replace("{{" + ad + "}}", deger ?? "");
        return sonuc.ToString();
    }
}
