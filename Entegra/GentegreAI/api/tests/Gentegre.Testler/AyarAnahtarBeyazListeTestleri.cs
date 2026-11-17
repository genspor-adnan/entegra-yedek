using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri.Depolar;
using Xunit;

namespace Gentegre.Testler;

/// <summary>
/// AYAR EKRANI ANAHTARI BEYAZ LİSTEDE OLMALI (17.11.2026): Başvuru Ayarları'nda KVKK ayarları kaydedilirken
/// "Bilinmeyen ayar: basvuru.kvkk_gecerlilik_gun" - anahtar ekranın yetki listesine (EkranKodlari) eklenmiş,
/// AyarDeposu.BeyazListe'ye eklenmemişti. Ekranın yazabildiği her anahtar beyaz listede de bulunmalı.
/// </summary>
public sealed class AyarAnahtarBeyazListeTestleri
{
    [Fact]
    public void Ekranlarin_yazdigi_her_ayar_anahtari_beyaz_listede()
    {
        var beyaz = new HashSet<string>(AyarDeposu.BeyazListe, StringComparer.Ordinal);
        var eksik = EkranKodlari.KayitKabulAyarAnahtarlari
            .Concat(EkranKodlari.AyarAnahtariKodu.Keys)
            .Where(a => !beyaz.Contains(a))
            .ToList();
        Assert.True(eksik.Count == 0, "Beyaz listede olmayan ayar anahtarları: " + string.Join(", ", eksik));
    }
}
