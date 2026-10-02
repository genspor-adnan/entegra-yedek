using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// İKİ SEVİYELİ ONAY (895 — KTS denetim maddesi L4).
///
/// İki aşama tanımlıydı ama ikincisi birincisini beklemiyordu: uzman
/// doğrudan yayınlayabiliyor, aynı kişi iki aşamayı da verebiliyor,
/// oto-onay ikisini birden atlıyordu. Bu kurallar ayar olduğu için
/// <b>varsayılan davranış değişmez</b> - test ayarı açıp kapatarak ikisini
/// de doğruluyor ve sonunda ayarı ESKİ HÂLİNE döndürüyor.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class CiftOnayTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam(int kullanici) => new()
    {
        KullaniciId = kullanici, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 0,
        Yetkiler = new YetkiSeti(1,
            [new YetkiKaydi("lab.sonuc", 0, true, true, true, true),
             new YetkiKaydi("lab.onay", 1, true, true, true, true)], []),
    };

    /// <summary>Kendi tetkiki (çift onay zorunlu) + sonuçlu satır.</summary>
    private static async Task<(int TetkikId, int IstemId, int SatirId, long SonucId)>
        DuzenekKurAsync(VeriKaynagi veri, short ciftOnay)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var tetkikId = await veri.TekDegerAsync<int>("""
            insert into public.lab_tetkik (kod, ad, tur, birim, ondalik, bolum,
                                           durum, cift_onay, oto_onay)
            values ('TESTONY' || @p0, 'Çift onay testi', 1, 'mg/dL', 1, 1, 0, @p1, 1)
            returning id
            """, [ek, ciftOnay], CancellationToken.None);
        // REFERANS ARALIGI SART: bayrak "N" cikmadan oto-onay zaten
        //   calismaz (433) - testin olctugu fark cift onay kurali olmali,
        //   referans eksikligi degil.
        await veri.CalistirAsync("""
            insert into public.lab_tetkik_referans
                   (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, alt, ust)
            values (@p0, 0, 0, 54750, 70, 110)
            """, [tetkikId], CancellationToken.None);

        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-ONY-' || @p1, 1, 2, 3, 1) returning id
            """, [hastaId, ek], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 3, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);
        var sonucId = await veri.TekDegerAsync<long>("""
            insert into public.lab_sonuc
                   (istem_satir_id, tetkik_id, deger_sayisal, deger_metin, birim,
                    bayrak, durum, olcum_zamani, sube_id)
            values (@p0, @p1, 95, '95', 'mg/dL', 'N', 1, now(), 0)
            returning id
            """, [satirId, tetkikId], CancellationToken.None);

        return (tetkikId, istemId, satirId, sonucId);
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
        await veri.CalistirAsync(
            "delete from public.lab_tetkik_referans where tetkik_id = @p0", [tetkikId],
            CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_tetkik where id = @p0", [tetkikId],
                                 CancellationToken.None);
    }

    [VtFact]
    public async Task Cift_onay_ZORUNLUYSA_uzman_teknik_onayi_BEKLER()
    {
        if (!_olgu.Baglandi(nameof(Cift_onay_ZORUNLUYSA_uzman_teknik_onayi_BEKLER))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        // Tetkik "zorunlu" (1) - kurum ayarına DOKUNULMADAN test edilebilsin:
        //   tetkik ayarı kurum ayarını ezer.
        var (tetkikId, istemId, _, sonucId) = await DuzenekKurAsync(veri, ciftOnay: 1);
        try
        {
            // Teknik onay YOKKEN yayın onayı reddedilir.
            var h = await Assert.ThrowsAsync<GentegreHatasi>(
                () => servis.OnaylaAsync(sonucId, 2, Baglam(1), CancellationToken.None));
            Assert.Contains("TEKNİK onay", h.Message, StringComparison.Ordinal);

            // Teknik onay verilince yayın onayı geçer.
            await servis.OnaylaAsync(sonucId, 1, Baglam(1), CancellationToken.None);
            await servis.OnaylaAsync(sonucId, 2, Baglam(2), CancellationToken.None);

            var s = await veri.TekAsync("""
                select durum, teknik_onay_id, onay_id from public.lab_sonuc where id = @p0
                """, [sonucId],
                o => new { Durum = o.GetInt16(0), Teknik = o.GetInt32(1), Onay = o.GetInt32(2) },
                CancellationToken.None);
            Assert.Equal(3, s!.Durum);
            Assert.Equal(1, s.Teknik);
            Assert.Equal(2, s.Onay);
        }
        finally { await TemizleAsync(veri, tetkikId, istemId); }
    }

    [VtFact]
    public async Task Dort_goz_ACIKKEN_ayni_kisi_ikinci_onayi_VEREMEZ()
    {
        if (!_olgu.Baglandi(nameof(Dort_goz_ACIKKEN_ayni_kisi_ikinci_onayi_VEREMEZ))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var eski = await veri.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'lab.onay_ayni_kisi'",
            null, CancellationToken.None);
        var (tetkikId, istemId, _, sonucId) = await DuzenekKurAsync(veri, ciftOnay: 1);
        try
        {
            await veri.CalistirAsync("""
                update public.referans set deger = '0' where anahtar = 'lab.onay_ayni_kisi'
                """, null, CancellationToken.None);

            await servis.OnaylaAsync(sonucId, 1, Baglam(7), CancellationToken.None);

            // AYNI KİŞİ: teknik onayı veren, aynı sonucu yayınlayamaz.
            var h = await Assert.ThrowsAsync<GentegreHatasi>(
                () => servis.OnaylaAsync(sonucId, 2, Baglam(7), CancellationToken.None));
            Assert.Contains("dört göz", h.Message, StringComparison.OrdinalIgnoreCase);

            // BAŞKA KİŞİ yayınlayabilir.
            await servis.OnaylaAsync(sonucId, 2, Baglam(8), CancellationToken.None);
            Assert.Equal(3, await veri.TekDegerAsync<short>(
                "select durum from public.lab_sonuc where id = @p0", [sonucId],
                CancellationToken.None));
        }
        finally
        {
            // AYAR ESKİ HÂLİNE: test kurulumun davranışını kalıcı değiştirmemeli.
            await veri.CalistirAsync("""
                update public.referans set deger = @p0 where anahtar = 'lab.onay_ayni_kisi'
                """, [eski ?? "1"], CancellationToken.None);
            await TemizleAsync(veri, tetkikId, istemId);
        }
    }

    [VtFact]
    public async Task Cift_onay_zorunluyken_OTO_ONAY_devre_disi()
    {
        if (!_olgu.Baglandi(nameof(Cift_onay_zorunluyken_OTO_ONAY_devre_disi))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        // İki tetkik: biri çift onaya tabi (1), öteki muaf (2). İkisinde de
        //   oto-onay AÇIK ve sonuç temiz - fark yalnız kuraldan gelmeli.
        var (tetkikZorunlu, istem1, satir1, _) = await DuzenekKurAsync(veri, ciftOnay: 1);
        var (tetkikMuaf, istem2, satir2, _) = await DuzenekKurAsync(veri, ciftOnay: 2);
        try
        {
            var y1 = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satir1, "95", null, null, null),
                null, null, Baglam(1), CancellationToken.None);
            var y2 = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satir2, "95", null, null, null),
                null, null, Baglam(1), CancellationToken.None);

            // ÇİFT ONAYA TABİ: oto-onay yok - iki seviyeli onay kuralını
            //   sessizce delerdi.
            Assert.Equal(0, await veri.TekDegerAsync<short>(
                "select oto_onay from public.lab_sonuc where id = @p0",
                [y1.SonucId], CancellationToken.None));

            // MUAF: eski davranış aynen sürer.
            Assert.Equal(1, await veri.TekDegerAsync<short>(
                "select oto_onay from public.lab_sonuc where id = @p0",
                [y2.SonucId], CancellationToken.None));
        }
        finally
        {
            await TemizleAsync(veri, tetkikZorunlu, istem1);
            await TemizleAsync(veri, tetkikMuaf, istem2);
        }
    }
}
