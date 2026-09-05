using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// KATALOG BÜTÜNLÜĞÜ — liste/kart/aksiyon katalogları ürünün SÖZLEŞMESİ:
/// ekranlar ne görürse ondan ibaret. Buradaki bir eksik ancak o ekran
/// açıldığında, çoğu zaman müşteride fark ediliyordu.
///
/// Testler tek tek kaynağı değil KURALI doğruluyor; yeni kaynak eklendiğinde
/// de kendiliğinden kapsanır.
/// </summary>
public class KatalogButunlukTestleri
{
    [Fact]
    public void HerKaynaginYetkiKoduVar()
    {
        var eksik = KaynakKatalogu.Tumu
            .Where(k => string.IsNullOrWhiteSpace(k.YetkiKodu))
            .Select(k => k.Ad).ToList();
        Assert.True(eksik.Count == 0, "Yetki kodu olmayan kaynak: " + string.Join(", ", eksik));
    }

    [Fact]
    public void HerKaynagin_KIMLIK_kolonuVar()
    {
        // Kimlik olmadan satır açılamaz: çift tık ve aksiyonlar kaydı bulamaz.
        //   Kimlik her kaynakta "id" değil - kod tabanlı katalogda "kod"
        //   (icd, zamanlı iş), barkod tabanlıda "barkod", satır listesinde
        //   "satirId" birincil anahtardır.
        string[] adaylar = ["id", "kod", "barkod", "satirId"];
        var eksik = KaynakKatalogu.Tumu
            .Where(k => adaylar.All(a => k.Kolon(a) is null))
            .Select(k => k.Ad).ToList();
        Assert.True(eksik.Count == 0, "Kimlik kolonu olmayan kaynak: " + string.Join(", ", eksik));
    }

    [Fact]
    public void KaynakAdlariTekil()
    {
        var tekrar = KaynakKatalogu.Tumu.GroupBy(k => k.Ad)
            .Where(g => g.Count() > 1).Select(g => g.Key).ToList();
        Assert.True(tekrar.Count == 0, "Tekrarlayan kaynak adı: " + string.Join(", ", tekrar));
    }

    [Fact]
    public void KolonAdlariKaynakIcindeTekil()
    {
        // Aynı ada iki kolon: istemci hangisini alacağını bilemez, filtre
        //   sessizce yanlış kolonu süzer.
        var hatalar = new List<string>();
        foreach (var k in KaynakKatalogu.Tumu)
            foreach (var g in k.Kolonlar.GroupBy(x => x.Ad).Where(g => g.Count() > 1))
                hatalar.Add($"{k.Ad}.{g.Key}");
        Assert.True(hatalar.Count == 0, "Tekrarlayan kolon: " + string.Join(", ", hatalar));
    }

    [Fact]
    public void SiralamaIfadesiBos_Degil()
    {
        // Varsayılan sıralama yoksa PG satırları rastgele sırada döndürür ve
        //   sayfalama ANLAMSIZ olur (aynı satır iki sayfada görünebilir).
        var eksik = KaynakKatalogu.Tumu
            .Where(k => string.IsNullOrWhiteSpace(k.VarsayilanSirala))
            .Select(k => k.Ad).ToList();
        Assert.True(eksik.Count == 0, "Varsayılan sıralaması olmayan kaynak: "
                                      + string.Join(", ", eksik));
    }

    [Fact]
    public void AksiyonKodlariEkranIcindeTekil()
    {
        var hatalar = new List<string>();
        foreach (var ekran in AksiyonKatalogu.EkranAdlari)
            foreach (var g in (AksiyonKatalogu.Ekran(ekran) ?? [])
                              .GroupBy(a => a.Kod).Where(g => g.Count() > 1))
                hatalar.Add($"{ekran}.{g.Key}");
        Assert.True(hatalar.Count == 0, "Tekrarlayan aksiyon: " + string.Join(", ", hatalar));
    }

    [Fact]
    public void FazSifirKaynaklariKatalogda()
    {
        // Faz 0'da açılan kaynaklar (398-405): birinin kataloğa eklenmeyi
        //   unutulması, ekranın "Bilinmeyen kaynak" ile 404 vermesi demek.
        foreach (var ad in new[] { "onam", "onam-metni", "bildirim", "bildirim-sablon",
                                   "icd", "ilac", "zamanli-is" })
            Assert.True(KaynakKatalogu.Bul(ad) is not null, $"Kaynak katalogda yok: {ad}");
    }
}
