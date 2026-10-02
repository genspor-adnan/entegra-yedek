using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// BOŞ / ANLAMSIZ SONUÇ ENGELİ (893 — KTS denetim maddesi L1).
///
/// Denetimin sorduğu "sonuçlar boş ya da anlamsız gönderilebiliyor mu"
/// sorusunun cevabı ancak DENENİNCE bilinir: sayısal tetkike "iyi" yazmak,
/// hemoglobini 500 g/dL girmek ve boş değerle satırı sonuçlandırmak
/// reddedilmeli; ölçüm aralığı dışındaki gerçek bir değer ise
/// reddedilmemeli - yalnız otomatik onaylanmamalı.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class SonucDogrulamaTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 0,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.sonuc", 0, true, true, true, true)], []),
    };

    /// <summary>Sınırları tanımlı kendi tetkiki + istem satırı.</summary>
    private static async Task<(int TetkikId, int IstemId, int SatirId)>
        DuzenekKurAsync(VeriKaynagi veri, short tur = 1, string desen = "")
    {
        var ek = Random.Shared.Next(100000).ToString();
        var tetkikId = await veri.TekDegerAsync<int>("""
            insert into public.lab_tetkik
                   (kod, ad, tur, birim, ondalik, bolum, durum,
                    mantik_alt, mantik_ust, olculebilir_alt, olculebilir_ust,
                    deger_deseni, oto_onay)
            values ('TESTDGR' || @p0, 'Doğrulama testi', @p1, 'g/dL', 1, 1, 0,
                    1, 25, 2, 22, @p2, 1)
            returning id
            """, [ek, tur, desen], CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-DGR-' || @p1, 1, 2, 3, 1) returning id
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
        await veri.CalistirAsync("delete from public.lab_tetkik where id = @p0", [tetkikId],
                                 CancellationToken.None);
    }

    [VtFact]
    public async Task Bos_ve_anlamsiz_sonuc_YAZILAMAZ()
    {
        if (!_olgu.Baglandi(nameof(Bos_ve_anlamsiz_sonuc_YAZILAMAZ))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            async Task<GentegreHatasi> RedAsync(string deger) =>
                await Assert.ThrowsAsync<GentegreHatasi>(() => servis.SonucYazAsync(
                    new LabServisi.SonucIstegi(satirId, deger, null, null, null),
                    null, null, Baglam(), CancellationToken.None));

            // BOŞ: "sonuçlandı" demek ama bir şey söylememek.
            Assert.Contains("boş olamaz", (await RedAsync("")).Message,
                            StringComparison.OrdinalIgnoreCase);

            // SAYISAL TETKİĞE METİN.
            Assert.Contains("sayı değil", (await RedAsync("iyi")).Message,
                            StringComparison.OrdinalIgnoreCase);

            // FİZYOLOJİK OLARAK İMKÂNSIZ: ölçüm değil, yazım hatası.
            Assert.Contains("imkânsız", (await RedAsync("500")).Message,
                            StringComparison.OrdinalIgnoreCase);
            Assert.Contains("imkânsız", (await RedAsync("-3")).Message,
                            StringComparison.OrdinalIgnoreCase);

            // Hiçbiri yazılmamış olmalı: mesaj doğru ama satır kalmışsa
            //   test yeşil görünüp veriyi kirletirdi.
            Assert.Equal(0, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.lab_sonuc where istem_satir_id = @p0
                """, [satirId], CancellationToken.None));
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }

    [VtFact]
    public async Task Olcum_araligi_disi_deger_YAZILIR_ama_OTO_ONAYLANMAZ()
    {
        if (!_olgu.Baglandi(nameof(Olcum_araligi_disi_deger_YAZILIR_ama_OTO_ONAYLANMAZ))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            // 23 g/dL: ölçüm aralığının (2-22) üstünde ama imkânsız değil.
            //   SONUÇ DÜŞÜRÜLMEZ - veriyi kaybettirirdi; ama kimse görmeden
            //   yayınlanmamalı.
            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "23", null, null, null),
                null, null, Baglam(), CancellationToken.None);

            Assert.True(y.SonucId > 0);
            Assert.Contains("DOĞRULAMA UYARISI", y.Mesaj, StringComparison.Ordinal);

            var sonuc = await veri.TekAsync("""
                select oto_onay, durum, yorum from public.lab_sonuc
                 where istem_satir_id = @p0 order by id desc limit 1
                """, [satirId],
                o => new { Oto = o.GetInt16(0), Durum = o.GetInt16(1), Yorum = o.GetString(2) },
                CancellationToken.None);
            Assert.Equal(0, sonuc!.Oto);
            Assert.NotEqual(3, sonuc.Durum);             // onaylı değil
            // Uyarı sonucun YORUMUNA da düşer: onaylayan uzman değere neden
            //   bakması gerektiğini satırın yanında görmeli.
            Assert.Contains("ölçüm aralığının", sonuc.Yorum, StringComparison.OrdinalIgnoreCase);

            // İŞARETLİ DEĞER UYARI ÜRETMEZ: ">22" zaten "aralık dışında"
            //   demenin cihazca yoludur.
            var y2 = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, ">22", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            Assert.DoesNotContain("DOĞRULAMA UYARISI", y2.Mesaj, StringComparison.Ordinal);
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }

    [VtFact]
    public async Task Metin_tetkikte_TANIMSIZ_deger_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Metin_tetkikte_TANIMSIZ_deger_reddedilir))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, istemId, satirId) =
            await DuzenekKurAsync(veri, tur: 2, desen: "^(Negatif|Pozitif)$");
        try
        {
            var h = await Assert.ThrowsAsync<GentegreHatasi>(() => servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "Belirsiz", null, null, null),
                null, null, Baglam(), CancellationToken.None));

            // MESAJDA REGEX GÖSTERİLMEZ: kullanıcıya ne yazacağı söylenir.
            Assert.Contains("Negatif, Pozitif", h.Message, StringComparison.Ordinal);
            Assert.DoesNotContain("^(", h.Message, StringComparison.Ordinal);

            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "Pozitif", null, null, null),
                null, null, Baglam(), CancellationToken.None);
            Assert.True(y.SonucId > 0);
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }
}
