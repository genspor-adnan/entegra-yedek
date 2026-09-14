using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// ELLE SONUÇ GİRİŞİ (`LabServisi.SonucYazAsync`, cihazsız yol).
///
/// Bu yolun hiç testi yoktu ve iki kez sahada kırıldı:
///   * Ayna kolonuna cihaz damgası yazan sorgu NULL cihaz parametresinin
///     tipini bildirmediği için sonuç yazımı "Beklenmeyen bir hata" ile
///     düşüyordu (Npgsql: could not determine data type of parameter).
///   * Aynı satıra ikinci kez yazınca önceki sonuç İPTAL EDİLMİYOR, iki
///     canlı sonuç kalıyordu - ekran sonuncuyu gösterirken onay kuyruğu
///     ötekini de taşıyordu.
///
/// İkisi de sessiz: derleme geçiyor, ekran "kaydedildi" diyor. Test gerçek
/// veritabanına yazar, kendi satırlarını açar ve siler.
/// </summary>
public sealed class ElleSonucGirisiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, SubeId = 0,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.sonuc", 0, true, true, true, true)], []),
    };

    /// <summary>Testin kendi istem + satırı; tetkik katalogdan seçilir.</summary>
    private static async Task<(int IstemId, int SatirId)> DuzenekKurAsync(VeriKaynagi veri)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU' limit 1", null,
            CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where hasta = 1 order by id limit 1", null,
            CancellationToken.None);

        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-ELLE-' || floor(random() * 1000000)::text, 1, 2, 3, 1)
            returning id
            """, [hastaId], CancellationToken.None);

        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 1, 10)
            returning id
            """, [istemId, tetkikId], CancellationToken.None);

        return (istemId, satirId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int istemId)
    {
        await veri.CalistirAsync("""
            delete from public.lab_sonuc
             where istem_satir_id in (select id from public.lab_istem_satir
                                       where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync(
            "delete from public.lab_istem_satir where istem_id = @p0", [istemId],
            CancellationToken.None);
        await veri.CalistirAsync(
            "delete from public.lab_istem where id = @p0", [istemId], CancellationToken.None);
    }

    [Fact]
    public async Task Elle_girilen_sonuc_YAZILIR_ve_satira_ELLE_damgasi_duser()
    {
        if (!_olgu.Baglandi(nameof(Elle_girilen_sonuc_YAZILIR_ve_satira_ELLE_damgasi_duser)))
            return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
        var (istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            // CİHAZSIZ yazım: `cihazId` null - sorgunun patladığı yer burasıydı.
            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "95", null, null, null),
                null, null, Baglam(), CancellationToken.None);

            Assert.True(y.SonucId > 0);

            // Satırın AYNA kolonları: ekran (istem kartı gridi) bunları okuyor.
            var satir = await veri.TekAsync("""
                select coalesce(sonuc, ''), coalesce(cihaz, ''), coalesce(referans, ''), durum
                  from public.lab_istem_satir where id = @p0
                """, [satirId],
                o => new { Sonuc = o.GetString(0), Cihaz = o.GetString(1),
                           Referans = o.GetString(2), Durum = o.GetInt16(3) },
                CancellationToken.None);

            Assert.NotNull(satir);
            Assert.Equal("95", satir!.Sonuc);
            // Damga IKON (kullanici: "elle yerine ikon ciksin"): kalem
            //   isareti + giren kisi. Cihazdan gelen sonucta cihaz kodu olur.
            Assert.StartsWith("✍", satir.Cihaz, StringComparison.Ordinal);
            // Referans katalogdan gelmeli: boşsa bayrak hesabı da anlamsızdır.
            Assert.NotEqual("", satir.Referans);
            // Satır artık sonuçlanmış sayılır (3 sonuçlandı / 5 oto-onaylı).
            Assert.Contains(satir.Durum, new short[] { 3, 5 });
        }
        finally { await TemizleAsync(veri, istemId); }
    }

    [Fact]
    public async Task Ayni_satira_IKINCI_yazim_oncekini_IPTAL_eder()
    {
        if (!_olgu.Baglandi(nameof(Ayni_satira_IKINCI_yazim_oncekini_IPTAL_eder))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);
        var (istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "30", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "130", null, null, null),
                null, null, Baglam(), CancellationToken.None);

            // TEK canlı sonuç kalmalı; ikisi birden kalırsa onay kuyruğu
            //   kullanıcının görmediği eski değeri de taşır.
            var canli = await veri.ListeAsync("""
                select coalesce(deger_metin, '') from public.lab_sonuc
                 where istem_satir_id = @p0 and durum <> 4
                """, [satirId], o => o.GetString(0), CancellationToken.None);

            Assert.Single(canli);
            Assert.Equal("130", canli[0]);

            // Eskisi silinmez, İPTAL edilir: giriş geçmişi izlenebilir kalmalı.
            var iptal = await veri.TekDegerAsync<int>("""
                select count(*) from public.lab_sonuc
                 where istem_satir_id = @p0 and durum = 4
                """, [satirId], CancellationToken.None);
            Assert.Equal(1, iptal);
        }
        finally { await TemizleAsync(veri, istemId); }
    }
}
