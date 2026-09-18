using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ KURUM ROLLERİ — KLİNİK / YÖNETİCİ AYRIMI (824).
///
/// Kullanıcı: *"anlaşmalı kurumdan hasta gönderen doktor ve hesapları kontrol
/// eden yönetici var"* → *"kurum kapsamı olsun, fatura satırında hasta adı
/// görünmesin"*.
///
/// İkisi de kurumun işlerini görür (<c>portal_turu = 2</c>); ayrım YETKİDE.
/// Bu sınıf veritabanı tarafındaki sınırı kilitler; menü tarafını
/// <c>web/src/test/portalDisKurumRolleri.test.ts</c> kilitliyor.
/// </summary>
public sealed class DisKurumRolleriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private async Task<List<string>> YetkilerAsync(string rolKodu)
    {
        await using var b = await _olgu.Gerekli().AcAsync();
        return await b.ListeAsync(
            "select y.kod from public.rol r "
            + "  join public.rol_yetki ry on ry.rol_id = r.id "
            + "  join public.yetki y on y.id = ry.yetki_id "
            + " where r.kod = @p0 order by y.kod",
            null, [rolKodu], o => o.GetString(0), Iptal);
    }

    [Fact(DisplayName = "Kurum portalında birden çok rol var: rol seçimi zorunlu")]
    public async Task KurumPortalindaCokRol()
    {
        if (!_olgu.Baglandi(nameof(KurumPortalindaCokRol))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // AKTİFLİK ARANMAZ: rol Kurum Profili'nin rol haritasıyla pasife
        //   alınabiliyor (786) - testin konusu "bu portal türünde birden çok
        //   rol TANIMLI mı", kurulumun o anki işaretleri değil.
        var roller = await b.ListeAsync(
            "select kod from public.rol where portal_turu = 2 order by id",
            null, [], o => o.GetString(0), Iptal);

        // Uç (`portal-hesap`) eskiden "order by id limit 1" ile rol seçiyordu;
        //   iki rol olunca bu HER ZAMAN Klinik demekti ve muhasebeciye tıbbi
        //   ekran açıyordu. Artık rol kodu isteniyor - bu testin varlık
        //   sebebi, seçimin gerçekten çok seçenekli olduğunu göstermek.
        Assert.True(roller.Count > 1,
            "Kurum portalında tek rol kaldıysa rol sorusu gereksiz hale gelmiştir.");
        Assert.Contains("dis_istem_kurumu", roller);
        Assert.Contains("dis_kurum_yonetici", roller);
    }

    [Fact(DisplayName = "Yönetici rolünde tıbbi yetki YOK")]
    public async Task YoneticiTibbiYetkiTasimaz()
    {
        if (!_olgu.Baglandi(nameof(YoneticiTibbiYetkiTasimaz))) return;

        var yetkiler = await YetkilerAsync("dis_kurum_yonetici");

        Assert.Contains("portal.mali", yetkiler);
        // Muhasebeyi tutan kişinin hasta sonucunu görmesinin savunması yok;
        //   "nasılsa aynı kurum" demek kapsamı kurumun tamamına açmaktır.
        foreach (var tibbi in new[] { "hasta", "lab", "lab.numune", "lab.sonuc",
                                      "teleradyoloji", "radyoloji" })
            Assert.DoesNotContain(tibbi, yetkiler);
    }

    [Fact(DisplayName = "Klinik rolünde mali yetki YOK")]
    public async Task KlinikMaliYetkiTasimaz()
    {
        if (!_olgu.Baglandi(nameof(KlinikMaliYetkiTasimaz))) return;

        var yetkiler = await YetkilerAsync("dis_istem_kurumu");

        Assert.Contains("hasta", yetkiler);
        Assert.DoesNotContain("portal.mali", yetkiler);
        // Kurum içi belge/cari yetkisi de portala sızmamalı: o listeler
        //   hastaAdi/doktor/poliklinik taşıyor.
        Assert.DoesNotContain("belge", yetkiler);
        Assert.DoesNotContain("cari", yetkiler);
    }

    [Fact(DisplayName = "portal.mali yetkisi yalnız Yönetici rolünde")]
    public async Task MaliYetkiTekRolde()
    {
        if (!_olgu.Baglandi(nameof(MaliYetkiTekRolde))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        var roller = await b.ListeAsync(
            "select r.kod from public.rol r "
            + "  join public.rol_yetki ry on ry.rol_id = r.id "
            + "  join public.yetki y on y.id = ry.yetki_id "
            + " where y.kod = 'portal.mali' order by r.kod",
            null, [], o => o.GetString(0), Iptal);

        Assert.Equal(["dis_kurum_yonetici"], roller);
    }
}
