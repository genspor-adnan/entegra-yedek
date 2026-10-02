using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// KLİNİK KARAR SINIRI (896 — KTS denetim maddesi L15).
///
/// Karar sınırı referans aralığı DEĞİLDİR: referans sağlıklı popülasyonun
/// dağılımı ("bu değer olağan mı"), karar sınırı kılavuzun eşiğidir ("bu
/// değerde ne yapmak gerekir"). Testin tuttuğu asıl davranış: referans
/// aralığının İÇİNDE olan bir değer bile hedefin dışında olabilir ve bu
/// söylenmelidir - bayrak "N" kalırken karar notu dolar.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class KararSiniriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 0,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.sonuc", 0, true, true, true, true)], []),
    };

    /// <summary>Referansı 0-200, hedefi &lt; 100 olan bir tetkik.</summary>
    private static async Task<(int TetkikId, int IstemId, int SatirId)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var tetkikId = await veri.TekDegerAsync<int>("""
            insert into public.lab_tetkik (kod, ad, tur, birim, ondalik, bolum, durum)
            values ('TESTKRR' || @p0, 'Karar sınırı testi', 1, 'mg/dL', 0, 1, 0)
            returning id
            """, [ek], CancellationToken.None);

        // REFERANS GENİŞ (0-200): 115 mg/dL burada "normal"dir.
        await veri.CalistirAsync("""
            insert into public.lab_tetkik_referans
                   (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, alt, ust)
            values (@p0, 0, 0, 54750, 0, 200)
            """, [tetkikId], CancellationToken.None);

        // KARAR SINIRI: hedef < 100 mg/dL.
        await veri.CalistirAsync("""
            insert into public.lab_karar_siniri (tetkik_id, ad, yon, deger, dayanak)
            values (@p0, 'Hedef LDL', 1, 100, 'ESC/EAS 2019')
            """, [tetkikId], CancellationToken.None);

        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-KRR-' || @p1, 1, 2, 3, 1) returning id
            """, [hastaId, ek], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 1, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);

        return (tetkikId, istemId, satirId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int tetkikId, int istemId)
    {
        await veri.CalistirAsync("""
            delete from public.lab_sonuc where istem_satir_id in
                   (select id from public.lab_istem_satir where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId],
                                 CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_karar_siniri where tetkik_id = @p0",
                                 [tetkikId], CancellationToken.None);
        await veri.CalistirAsync(
            "delete from public.lab_tetkik_referans where tetkik_id = @p0", [tetkikId],
            CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_tetkik where id = @p0", [tetkikId],
                                 CancellationToken.None);
    }

    [VtFact]
    public async Task Referans_araliginda_olan_deger_HEDEFIN_DISINDA_olabilir()
    {
        if (!_olgu.Baglandi(nameof(Referans_araliginda_olan_deger_HEDEFIN_DISINDA_olabilir)))
            return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            // 115: referans aralığında (0-200) ama hedefin (< 100) üstünde.
            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "115", null, null, null),
                null, null, Baglam(), CancellationToken.None);

            // BAYRAK EZİLMEZ: değer referans aralığında, "N" kalır - bayrağı
            //   değiştirmek panik/anormal sayımlarını da bozardı.
            var s = await veri.TekAsync("""
                select bayrak, karar_notu from public.lab_sonuc where id = @p0
                """, [y.SonucId],
                o => new { Bayrak = o.GetString(0), Not = o.GetString(1) },
                CancellationToken.None);
            Assert.Equal("N", s!.Bayrak);

            // AMA KARAR NOTU DOLAR - hekimin göreceği bilgi budur.
            Assert.Contains("Hedefin üstünde", s.Not, StringComparison.Ordinal);
            Assert.Contains("Hedef LDL < 100", s.Not, StringComparison.Ordinal);
            Assert.Contains("ESC/EAS 2019", s.Not, StringComparison.Ordinal);
            Assert.Contains("Hedefin üstünde", y.Mesaj, StringComparison.Ordinal);
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }

    [VtFact]
    public async Task Hedefteki_deger_NOT_URETMEZ_ve_not_SONUCA_DONAR()
    {
        if (!_olgu.Baglandi(nameof(Hedefteki_deger_NOT_URETMEZ_ve_not_SONUCA_DONAR))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            // 80: hem referans aralığında hem hedefte - "hedefte" bilgisini
            //   her satıra yazmak raporu gürültüye boğardı.
            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "80", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            Assert.Equal("", await veri.TekDegerAsync<string>(
                "select karar_notu from public.lab_sonuc where id = @p0", [y.SonucId],
                CancellationToken.None));

            // NOT SONUCA DONAR: kılavuz sonradan değişse bile eski rapor
            //   kendi eşiğiyle okunmalı (888 referansındaki kararın aynısı).
            await veri.CalistirAsync("""
                insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
                select istem_id, tetkik_id, 1, 20 from public.lab_istem_satir where id = @p0
                """, [satirId], CancellationToken.None);
            var yeniSatir = await veri.TekDegerAsync<int>("""
                select id from public.lab_istem_satir
                 where istem_id = (select istem_id from public.lab_istem_satir where id = @p0)
                 order by id desc limit 1
                """, [satirId], CancellationToken.None);

            var y2 = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(yeniSatir, "115", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            var eskiNot = await veri.TekDegerAsync<string>(
                "select karar_notu from public.lab_sonuc where id = @p0", [y2.SonucId],
                CancellationToken.None);
            Assert.Contains("100", eskiNot!, StringComparison.Ordinal);

            // Kılavuz değişti: eşik 130'a çıktı.
            await veri.CalistirAsync("""
                update public.lab_karar_siniri set deger = 130 where tetkik_id = @p0
                """, [tetkikId], CancellationToken.None);

            // ESKİ SONUÇ AYNEN KALIR (donmuş not), yeni sonuç yeni eşiği alır.
            Assert.Equal(eskiNot, await veri.TekDegerAsync<string>(
                "select karar_notu from public.lab_sonuc where id = @p0", [y2.SonucId],
                CancellationToken.None));

            var y3 = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(yeniSatir, "115", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            Assert.Equal("", await veri.TekDegerAsync<string>(
                "select karar_notu from public.lab_sonuc where id = @p0", [y3.SonucId],
                CancellationToken.None));
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }

    [VtFact]
    public async Task Yon_2_sinirda_ALTINDA_kalmak_uyarir()
    {
        if (!_olgu.Baglandi(nameof(Yon_2_sinirda_ALTINDA_kalmak_uyarir))) return;
        var veri = _olgu.Gerekli();

        var (tetkikId, istemId, _) = await DuzenekKurAsync(veri);
        try
        {
            // YÖN 2: "bu değerin ÜSTÜNDE olmalı" (koruyucu düzey - D vitamini
            //   > 30 ng/mL gibi). Altında kalmak uyarı üretmeli.
            await veri.CalistirAsync("""
                update public.lab_karar_siniri set yon = 2, deger = 30, ad = 'Yeterli düzey'
                 where tetkik_id = @p0
                """, [tetkikId], CancellationToken.None);

            var hastaId = await veri.TekDegerAsync<int>(
                "select id from public.taraf_hasta order by id limit 1", null,
                CancellationToken.None);

            Assert.Contains("Hedefin altında", await veri.TekDegerAsync<string>(
                "select public.fn_lab_karar_notu(@p0, @p1, 18)", [tetkikId, hastaId],
                CancellationToken.None)!, StringComparison.Ordinal);

            Assert.Equal("", await veri.TekDegerAsync<string>(
                "select public.fn_lab_karar_notu(@p0, @p1, 45)", [tetkikId, hastaId],
                CancellationToken.None));
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }
}
