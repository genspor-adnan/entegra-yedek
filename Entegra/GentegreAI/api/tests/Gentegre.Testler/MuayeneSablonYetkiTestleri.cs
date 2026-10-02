using Gentegre.Api.AraKatman;
using Gentegre.Api.Uclar;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Testler;

/// <summary>
/// DOKTOR YALNIZ KENDİ ŞABLONUNU DÜZENLER (929, kullanıcı).
///
/// Genel kart uçları "muayene-sablon" için <see cref="MuayeneSablonUclari.YazmaKuraliAsync"/>
/// çağırır: <c>muayene.sablon_yonet</c> yetkisi olmayan kullanıcı başkasının ya
/// da bölüm ortak şablonu değiştiremez, yeni şablonu yalnız kendi adına açar,
/// şablonunu başkasına / bölüm ortağa çeviremez. Yetkili her şeyi yapar.
/// Test kendi şablon satırlarını açar ve siler. Veritabanı yoksa atlanır.
/// </summary>
public sealed class MuayeneSablonYetkiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly KartTanimi Tanim = KartKatalogu.Bul("muayene-sablon")!;

    private static IstekBaglami Baglam(int kullanici, bool yonetici) => new()
    {
        KullaniciId = kullanici, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 1, IzlemeNo = "test",
        Yetkiler = new YetkiSeti(1,
            yonetici ? [new YetkiKaydi(MuayeneSablonUclari.YonetimAksiyonu, 1, true, true, true, true)] : [],
            []),
    };

    [VtFact]
    public async Task Yetkisiz_doktor_yalniz_kendi_sablonunu_degistirir_ve_yalniz_kendi_adina_acar()
    {
        if (!_olgu.Baglandi(nameof(Yetkisiz_doktor_yalniz_kendi_sablonunu_degistirir_ve_yalniz_kendi_adina_acar))) return;
        var veri = _olgu.Gerekli();
        var e = "T929" + Random.Shared.Next(10000, 99999);
        var ortak = await veri.TekDegerAsync<int>(
            "insert into public.muayene_sablon (kod, ad, tur) values (@p0, 'Ortak', 1) returning id", [e + "O"]);
        var benim = await veri.TekDegerAsync<int>(
            "insert into public.muayene_sablon (kod, ad, tur, hekim_id) values (@p0, 'Benim', 1, 7001) returning id", [e + "B"]);
        try
        {
            var doktor = Baglam(7001, yonetici: false);
            var ct = CancellationToken.None;

            // Kendi şablonu: değiştirir ve siler.
            await MuayeneSablonUclari.YazmaKuraliAsync(Tanim, doktor,
                new Dictionary<string, object?> { ["ad"] = "Yeni ad" }, veri, benim, ct);
            await MuayeneSablonUclari.YazmaKuraliAsync(Tanim, doktor, null, veri, benim, ct);

            // Bölüm ortak şablon: değiştiremez / silemez.
            var h = await Assert.ThrowsAsync<GentegreHatasi>(() => MuayeneSablonUclari.YazmaKuraliAsync(
                Tanim, doktor, new Dictionary<string, object?> { ["ad"] = "x" }, veri, ortak, ct));
            Assert.Equal(HataKodu.Yasak, h.Kod);
            Assert.Contains("Kopyala (bana)", h.Message, StringComparison.Ordinal);
            await Assert.ThrowsAsync<GentegreHatasi>(() =>
                MuayeneSablonUclari.YazmaKuraliAsync(Tanim, doktor, null, veri, ortak, ct));

            // Kendi şablonunu bölüm ortağa ya da başkasına çeviremez.
            await Assert.ThrowsAsync<GentegreHatasi>(() => MuayeneSablonUclari.YazmaKuraliAsync(
                Tanim, doktor, new Dictionary<string, object?> { ["hekimId"] = null }, veri, benim, ct));
            await Assert.ThrowsAsync<GentegreHatasi>(() => MuayeneSablonUclari.YazmaKuraliAsync(
                Tanim, doktor, new Dictionary<string, object?> { ["hekimId"] = 9999L }, veri, benim, ct));

            // Yeni: yalnız kendi adına.
            await MuayeneSablonUclari.YazmaKuraliAsync(Tanim, doktor,
                new Dictionary<string, object?> { ["kod"] = "Y", ["hekimId"] = 7001L }, veri, null, ct);
            await Assert.ThrowsAsync<GentegreHatasi>(() => MuayeneSablonUclari.YazmaKuraliAsync(
                Tanim, doktor, new Dictionary<string, object?> { ["kod"] = "Y" }, veri, null, ct));

            // Yönetici: ortak şablonu değiştirir, bölüm ortak açar.
            var yonetici = Baglam(7002, yonetici: true);
            await MuayeneSablonUclari.YazmaKuraliAsync(Tanim, yonetici,
                new Dictionary<string, object?> { ["ad"] = "x", ["hekimId"] = null }, veri, ortak, ct);
            await MuayeneSablonUclari.YazmaKuraliAsync(Tanim, yonetici,
                new Dictionary<string, object?> { ["kod"] = "Z" }, veri, null, ct);

            // Başka kart bu kurala takılmaz.
            await MuayeneSablonUclari.YazmaKuraliAsync(KartKatalogu.Bul("hasta-alerji")!, doktor,
                new Dictionary<string, object?>(), veri, ortak, ct);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.muayene_sablon where id in (@p0, @p1)", [ortak, benim]);
        }
    }
}
