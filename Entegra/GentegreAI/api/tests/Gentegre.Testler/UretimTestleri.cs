using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Testler;

/// <summary>
/// ÜRETİM v1 (429) — kod uzayı ve kart sözleşmesi.
///
/// Buradaki hatalar ancak üretim yapan bir müşteride, stok bakiyesi
/// bozulduktan sonra görülür: sarf çıkış yerine giriş sayılırsa mal depoya
/// EKLENİR, mamul girişi çıkış sayılırsa depo eksiye düşer.
/// </summary>
public class UretimTestleri
{
    [Fact]
    public void SarfVeFire_CIKIS_mamulGirisi_GIRIS()
    {
        Assert.True(BelgeTuru.CikisMi(BelgeTuru.SarfCikisi));
        Assert.True(BelgeTuru.CikisMi(BelgeTuru.FireCikisi));
        Assert.False(BelgeTuru.CikisMi(BelgeTuru.UretimGirisi));

        Assert.Equal("cikisDepoId", BelgeTuru.DepoAlani(BelgeTuru.SarfCikisi));
        Assert.Equal("cikisDepoId", BelgeTuru.DepoAlani(BelgeTuru.FireCikisi));
        Assert.Equal("girisDepoId", BelgeTuru.DepoAlani(BelgeTuru.UretimGirisi));
    }

    [Fact]
    public void UretimTurleri_kasaKodlariyla_CAKISMAZ()
    {
        // kasa_islem_turu TEK tablodur: 21-23 zaten kasa tahsilat türleridir.
        //   "Belge grubunda boş" görünen numara aslında dolu olabilir.
        int[] uretim = [BelgeTuru.SarfCikisi, BelgeTuru.UretimGirisi, BelgeTuru.FireCikisi];
        int[] kasaVeBelge = [3, 4, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                             21, 22, 23, 24, 25, 26, 105, 109, 119];
        Assert.Empty(uretim.Intersect(kasaVeBelge));
    }

    [Fact]
    public void UretimBelgeleri_IADE_yorumuna_kapilmaz()
    {
        // tipi = 2 faturada "iade" demek; üretim belgesinde öyle bir anlam yok.
        //   Yön ters çevrilirse sarf, depoya GİRİŞ olurdu.
        Assert.True(BelgeTuru.CikisMi(BelgeTuru.SarfCikisi, 1));
        Assert.False(BelgeTuru.CikisMi(BelgeTuru.UretimGirisi, 1));
    }

    [Fact]
    public void EmirKartinda_GERCEK_maliyet_yazilamaz()
    {
        // Gerçek maliyet sarf fişleri ve zaman kayıtlarından toplanır; elle
        //   girilebilirse "bu tutar nereden geldi" sorusunun cevabı kalmaz.
        var kart = KartKatalogu.Bul("uretim-emri");
        Assert.NotNull(kart);
        foreach (var ad in new[] { "gercekMalzeme", "gercekIscilik", "gercekToplam",
                                   "planMalzeme", "planIscilik", "planToplam",
                                   "uretilenAdet", "no", "durum" })
            Assert.False(kart!.Alan(ad)?.Yazilabilir ?? true, $"{ad} yazilabilir olmamali");
    }

    [Fact]
    public void AgacKartinda_maliyet_alanlari_hesap_sonucudur()
    {
        var kart = KartKatalogu.Bul("urun-agaci");
        Assert.NotNull(kart);
        foreach (var ad in new[] { "maliyetMalzeme", "maliyetIscilik",
                                   "maliyetGug", "maliyetToplam", "maliyetTarih" })
            Assert.False(kart!.Alan(ad)?.Yazilabilir ?? true, $"{ad} yazilabilir olmamali");
    }

    [Fact]
    public void EmirSatirinda_rezerve_ve_sarf_sunucudan()
    {
        // stok_durum.rezerve ile emir satırı birlikte hareket eder; satır elle
        //   yazılabilseydi depodaki rezerv asılı kalırdı.
        var detay = KartKatalogu.Bul("uretim-emri")?.Detay("malzeme");
        Assert.NotNull(detay);
        var rezerve = detay!.Alanlar.First(a => a.Ad == "rezerve");
        var sarf = detay.Alanlar.First(a => a.Ad == "sarfEdilen");
        Assert.False(rezerve.Yazilabilir);
        Assert.False(sarf.Yazilabilir);
    }

    [Fact]
    public void StokHareketleri_sekmesi_SALT_OKUNUR()
    {
        // Belge kendi ekranından düzenlenir: stok hareketini iki yerden
        //   yönetmek, emirdeki miktarla belgedeki miktarı ayırırdı.
        var detay = KartKatalogu.Bul("uretim-emri")?.Detay("hareketler");
        Assert.NotNull(detay);
        Assert.True(detay!.SaltOkunur);
    }

    [Fact]
    public void UretimAksiyonlari_uretim_yetkisine_bagli()
    {
        // Reçete rekabet bilgisidir: stok yetkisine bağlanırsa depoyu gören
        //   herkes ağacı ve maliyeti görürdü.
        foreach (var ekran in new[] { "urun-agaci-liste", "uretim-emri-liste", "is-merkezi-liste" })
        {
            var aksiyonlar = AksiyonKatalogu.Ekran(ekran);
            Assert.NotNull(aksiyonlar);
            Assert.All(aksiyonlar!.Where(a => a.KaynakKodu is not null),
                a => Assert.Equal("uretim", a.KaynakKodu));
        }
    }

    [Fact]
    public void OnaylamaVeMaliyet_ayri_aksiyon_yetkisi_ister()
    {
        var aksiyonlar = AksiyonKatalogu.Ekran("uretim-emri-liste")!;
        Assert.Equal("uretim.onayla",
            aksiyonlar.First(a => a.Kod == "uretim.onayla").AksiyonYetkisi);
        foreach (var kod in new[] { "uretim.maliyet-kapat", "uretim.kapat" })
            Assert.Equal("uretim.maliyet",
                aksiyonlar.First(a => a.Kod == kod).AksiyonYetkisi);
    }
}
