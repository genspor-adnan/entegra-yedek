using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// e-NABIZ EKRANLARI (454) — kuyruk tek başına yetmiyordu.
///
/// Bu testler ekranların <b>sözleşmesini</b> tutuyor: kod eşleme listesi ile
/// kartı aynı tabloya bakmalı (yoksa liste bir şey gösterip kart başkasını
/// kaydeder), eşleme türü serbest metin olmamalı (aynı türün iki yazımı paket
/// üreticisine eşlemeyi kaybettirir) ve rehber kataloğu yeni ekranları
/// bilmeli (bilmezse asistan olmayan menüyü tarif eder).
/// </summary>
public class EnabizTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public EnabizTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    [Fact]
    public void Kod_esleme_LISTESI_ve_KARTI_ayni_tabloya_bakar()
    {
        var kaynak = KaynakKatalogu.Bul("enabiz-kod-esleme");
        var kart = KartKatalogu.Bul("enabiz-kod-esleme");
        Assert.NotNull(kaynak);
        Assert.NotNull(kart);

        Assert.Contains("enabiz_kod_esleme", kaynak!.Kaynak, StringComparison.Ordinal);
        Assert.Equal("public.enabiz_kod_esleme", kart!.Tablo);
        // Aynı yetki: listesi görünüp kartı açılamayan ekran, kullanıcıya
        //   "bozuk" görünür.
        Assert.Equal(kaynak.YetkiKodu, kart.YetkiKodu);
    }

    [Fact]
    public void Esleme_turu_SABIT_LISTEDEN_secilir()
    {
        // "klinik" ile "Klinik" iki ayrı tür sayılırsa paket üreticisi
        //   eşlemeyi bulamaz ve alan yine eksik kalır.
        var kart = KartKatalogu.Bul("enabiz-kod-esleme");
        var alan = kart!.Alanlar.FirstOrDefault(a => a.Ad == "eslemeTuru");
        Assert.NotNull(alan);
        Assert.Equal("kod", alan!.Tip);
        Assert.NotNull(alan.SabitKodlar);
        Assert.Contains("klinik", alan.SabitKodlar!.Keys);
    }

    [Fact]
    public void Kod_esleme_ekraninin_AKSIYONLARI_var()
    {
        // Katalog ekranı yoksa araç çubuğu boş çizilir: kullanıcı kayıt
        //   ekleyemez ve bunu "yetkim yok" sanır.
        var aksiyonlar = AksiyonKatalogu.Ekran("enabiz-kod-esleme-liste");
        Assert.NotNull(aksiyonlar);
        Assert.Contains(aksiyonlar!, a => a.Kod == "enabiz-kod-esleme.yeni");
        Assert.Contains(aksiyonlar!, a => a.Kod == "enabiz-kod-esleme.duzenle");
    }

    [Fact]
    public async Task Rehber_katalogu_YENI_EKRANLARI_bilir()
    {
        if (!_olgu.Baglandi(nameof(Rehber_katalogu_YENI_EKRANLARI_bilir))) return;
        var veri = _olgu.Gerekli();

        // Menüye eklenen her ekran rehber kataloğuna da girmeli; girmezse
        //   asistan o ekranı hiç öneremez.
        foreach (var rota in new[] { "/enabiz-paket", "/enabiz-pano", "/enabiz-kod-esleme" })
        {
            var satir = await veri.TekAsync(
                "select yol, menu_grup from public.ai_rehber_ekran where rota = @p0",
                [rota], o => new { Yol = o.GetString(0), Grup = o.GetString(1) });
            Assert.True(satir is not null, $"rehber kataloğunda yok: {rota}");
            Assert.Equal("e-Nabız", satir!.Grup);
        }
    }

    [Fact]
    public async Task Enabiz_SURECI_rehberde_anlatilir()
    {
        if (!_olgu.Baglandi(nameof(Enabiz_SURECI_rehberde_anlatilir))) return;
        var veri = _olgu.Gerekli();

        // "e-Nabıza nasıl gidiyor" tek ekranla cevaplanmıyor: olay klinik
        //   ekranda, paket arka planda, gönderim zamanlı işte.
        var adim = await veri.TekDegerAsync<int>(
            "select jsonb_array_length(adimlar) from public.ai_rehber_konu "
            + "where kod = 'enabiz-surec'");
        Assert.True(adim >= 5, $"süreç konusu eksik ({adim} adım)");
    }
}
