using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri.Depolar;

namespace Gentegre.Testler;

/// <summary>
/// BİLDİRİM KUYRUĞU (399) — veritabanına dokunan uçtan uca test.
///
/// Kuyruğun sözü şu: satır bir kez alınır, sonucu yazılır, başarısızsa deneme
/// hakkı varken kuyrukta kalır. Bu kuralların hepsi SQL'de yaşıyor
/// (`for update skip locked`, koşullu durum güncellemesi) - C# tarafını
/// okumak doğruluğu göstermiyor, ancak çalıştırarak görülür.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class BildirimKuyruguTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public BildirimKuyruguTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private const string TestAlicisi = "5559999999";

    [Fact]
    public async Task SablondanKuyruga_degiskenlerDolar()
    {
        if (!_olgu.Baglandi(nameof(SablondanKuyruga_degiskenlerDolar))) return;
        var depo = new BildirimDeposu(_olgu.Gerekli());

        var id = await depo.KuyrugaEkleAsync(new BildirimIstegi(
            SablonKodu: "randevu.hatirlatma",
            Kanal: null,
            Alici: TestAlicisi,
            Degiskenler: new Dictionary<string, string>
            {
                ["hasta_ad"] = "TEST HASTA", ["tarih"] = "01.01.2027",
                ["bolum"] = "Dahiliye", ["kurum"] = "Test Kurumu",
            },
            KaynakTur: 9, KaynakId: -1), kullaniciId: 0, subeId: null);

        Assert.NotNull(id);
        try
        {
            var govde = await _olgu.Veri!.TekDegerAsync<string>(
                "select govde from public.bildirim where id = @p0", [id]);
            Assert.Contains("TEST HASTA", govde);
            Assert.Contains("Dahiliye", govde);
            // Şablonda kalan yer tutucu olmamalı.
            Assert.DoesNotContain("{{", govde);
        }
        finally { await TemizleAsync(id!.Value); }
    }

    [Fact]
    public async Task Kuyruk_AYNI_SATIRI_IKI_KEZ_VERMEZ()
    {
        if (!_olgu.Baglandi(nameof(Kuyruk_AYNI_SATIRI_IKI_KEZ_VERMEZ))) return;
        var veri = _olgu.Gerekli();
        var depo = new BildirimDeposu(veri);

        var id = await depo.KuyrugaEkleAsync(new BildirimIstegi(
            SablonKodu: null, Kanal: BildirimKanali.Sms, Alici: TestAlicisi,
            Govde: "kilit denemesi", KaynakTur: 9, KaynakId: -2, Oncelik: 1),
            kullaniciId: 0, subeId: null);

        try
        {
            // Aynı kuyruktan iki kez almak: ikinci alışta AYNI satır gelmemeli.
            var birinci = await depo.SiradakileriAlAsync(50);
            var ikinci = await depo.SiradakileriAlAsync(50);

            Assert.Contains(birinci, x => x.Id == id);
            Assert.DoesNotContain(ikinci, x => x.Id == id);

            // Alınan satır "Gönderiliyor" (2) durumunda bekler.
            var durum = await veri.TekDegerAsync<short>(
                "select durum from public.bildirim where id = @p0", [id]);
            Assert.Equal((short)BildirimDurumu.Gonderiliyor, durum);

            // Başarısız sonuç: deneme hakkı varken KUYRUKTA kalır ve planlanan
            //   ileri atılır (aynı saniyede üç kez denenmesin).
            var kayit = birinci.First(x => x.Id == id);
            await depo.SonucYazAsync(kayit, new GonderimSonucu(false, Hata: "test hatası"), 12);

            var yeniDurum = await veri.TekDegerAsync<short>(
                "select durum from public.bildirim where id = @p0", [id]);
            // KARSILASTIRMA DB'DE (602): `planlanan` timestamp without time zone
            //   ve DB'nin kendi `now()`u ile yaziliyor (BildirimDeposu). Onu C#
            //   `DateTime.Now` ile olcmek, sunucu ile veritabani ayri saat
            //   diliminde oldugunda yaniltir - dev kurulumunda DB UTC, makine
            //   UTC+3; test 3 saat geride gorup "ileri atilmamis" diyordu.
            //   Uretimde boyle bir karsilastirma YOK: kuyruk da `planlanan <=
            //   now()` ile, yani tamamen DB tarafinda suzuluyor.
            var ileriAtildi = await veri.TekDegerAsync<bool>(
                "select planlanan > now() from public.bildirim where id = @p0", [id]);
            Assert.Equal((short)BildirimDurumu.Kuyrukta, yeniDurum);
            Assert.True(ileriAtildi, "Yeniden deneme ileri atılmalı.");

            // Deneme günlüğüne satır düştü mü.
            var log = await depo.LogAsync(id!.Value);
            Assert.Single(log);
        }
        finally { await TemizleAsync(id!.Value); }
    }

    [Fact]
    public async Task PasifSablon_KUYRUGA_KONMAZ()
    {
        if (!_olgu.Baglandi(nameof(PasifSablon_KUYRUGA_KONMAZ))) return;
        var veri = _olgu.Gerekli();
        var depo = new BildirimDeposu(veri);

        await veri.CalistirAsync("""
            insert into public.bildirim_sablon (kod, ad, kanal, govde, durum)
            values ('test.pasif', 'Test pasif şablon', 1, 'gitmemeli', 0)
            on conflict (kod) do update set durum = 0
            """, null);
        try
        {
            var id = await depo.KuyrugaEkleAsync(new BildirimIstegi(
                SablonKodu: "test.pasif", Kanal: null, Alici: TestAlicisi),
                kullaniciId: 0, subeId: null);

            // null = kayıt açılmadı. Hata DEĞİL: kurulum o bildirimi kapatmış.
            Assert.Null(id);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.bildirim_sablon where kod = 'test.pasif'", null);
        }
    }

    [Fact]
    public async Task AliciBos_ISE_REDDEDILIR()
    {
        if (!_olgu.Baglandi(nameof(AliciBos_ISE_REDDEDILIR))) return;
        var depo = new BildirimDeposu(_olgu.Gerekli());
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            depo.KuyrugaEkleAsync(new BildirimIstegi(
                SablonKodu: null, Kanal: BildirimKanali.Sms, Alici: "  ", Govde: "x"),
                kullaniciId: 0, subeId: null));
    }

    private async Task TemizleAsync(long id)
        => await _olgu.Veri!.CalistirAsync("delete from public.bildirim where id = @p0", [id]);
}
