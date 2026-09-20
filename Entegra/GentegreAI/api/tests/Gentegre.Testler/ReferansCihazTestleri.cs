using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// CİHAZ BAZLI REFERANS ARALIĞI (888 — KTS denetim maddesi L3).
///
/// Aynı tetkikin referans aralığı ölçüm yöntemine bağlıdır: TSH, ferritin,
/// D vitamini gibi immünoassay testlerinde aralık üreticinin kitiyle gelir.
/// İki cihazlı bir laboratuvar tek aralık kullanırsa bir cihazın sonuçları
/// sistematik olarak yanlış bayraklanır — normal değer "yüksek", yüksek
/// değer "normal" görünür. Kural SQL'de yaşıyor; okumakla değil,
/// çalıştırmakla doğrulanır.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class ReferansCihazTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, SubeId = 0,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.sonuc", 0, true, true, true, true)], []),
    };

    /// <summary>Testin kendi tetkiki, iki referans satırı ve bir cihazı.</summary>
    private static async Task<(int TetkikId, int CihazId, int HastaId)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var tetkikId = await veri.TekDegerAsync<int>("""
            insert into public.lab_tetkik (kod, ad, tur, birim, ondalik, bolum, durum)
            values ('TESTREF' || floor(random() * 100000)::text,
                    'Test referans tetkiki', 1, 'mg/dL', 1, 1, 0)
            returning id
            """, null, CancellationToken.None);
        var cihazId = await veri.TekDegerAsync<int>("""
            insert into public.cihaz (kod, ad, tur, durum)
            values ('TESTCHZ' || floor(random() * 100000)::text,
                    'Test cihazı', 1, 0)
            returning id
            """, null, CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where hasta = 1 order by id limit 1", null,
            CancellationToken.None);

        // GENEL aralık 70 - 100, CİHAZA ÖZEL aralık 80 - 120. Cihaza özel
        //   satırın yaş bandı daha GENİŞ: yöntem farkı bant darlığından daha
        //   belirleyicidir, yine de o kazanmalı.
        await veri.CalistirAsync("""
            insert into public.lab_tetkik_referans
                   (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, alt, ust, cihaz_id, sira)
            values (@p0, 0, 0, 54750, 70, 100, null, 10),
                   (@p0, 0, 0, 54750, 80, 120, @p1, 20)
            """, [tetkikId, cihazId], CancellationToken.None);

        return (tetkikId, cihazId, hastaId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int tetkikId, int cihazId)
    {
        await veri.CalistirAsync(
            "delete from public.lab_tetkik_referans where tetkik_id = @p0", [tetkikId],
            CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_tetkik where id = @p0", [tetkikId],
                                 CancellationToken.None);
        await veri.CalistirAsync("delete from public.cihaz where id = @p0", [cihazId],
                                 CancellationToken.None);
    }

    private static Task<decimal?> UstAsync(VeriKaynagi veri, int tetkikId, int hastaId,
                                           int? cihazId) =>
        veri.TekDegerAsync<decimal?>("""
            select ust from public.fn_lab_referans(@p0, @p1, current_date, @p2)
             where tetkik_id is not null
            """, [tetkikId, hastaId, cihazId], CancellationToken.None);

    [Fact]
    public async Task Cihaza_ozel_aralik_GENEL_araligi_ezer()
    {
        if (!_olgu.Baglandi(nameof(Cihaza_ozel_aralik_GENEL_araligi_ezer))) return;
        var veri = _olgu.Gerekli();

        var (tetkikId, cihazId, hastaId) = await DuzenekKurAsync(veri);
        try
        {
            // Ölçüm o cihazda yapıldıysa CİHAZIN aralığı.
            Assert.Equal(120m, await UstAsync(veri, tetkikId, hastaId, cihazId));

            // Cihaz bilinmiyorsa (elle giriş) GENEL aralık - cihaza özel satır
            //   başka bir yöntemin aralığıdır, rastgele uygulanamaz.
            Assert.Equal(100m, await UstAsync(veri, tetkikId, hastaId, null));

            // BAŞKA cihazda ölçüldüyse yine genel aralık: tanımsız cihaz için
            //   bir başkasının kit aralığını kullanmak, yanlış bayrak üretirdi.
            Assert.Equal(100m, await UstAsync(veri, tetkikId, hastaId, cihazId + 987654));
        }
        finally { await TemizleAsync(veri, tetkikId, cihazId); }
    }

    [Fact]
    public async Task Sonuc_yazilirken_CIHAZIN_araligi_satira_donar()
    {
        if (!_olgu.Baglandi(nameof(Sonuc_yazilirken_CIHAZIN_araligi_satira_donar))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, cihazId, hastaId) = await DuzenekKurAsync(veri);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-REFCHZ-' || floor(random() * 1000000)::text, 1, 2, 3, 1)
            returning id
            """, [hastaId], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 1, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);
        try
        {
            // 110 mg/dL: GENEL aralıkta (70-100) YÜKSEK, cihazın aralığında
            //   (80-120) NORMAL. Bayrak, kullanılan aralığı ele verir.
            await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "110", null, null, null),
                cihazId, null, Baglam(), CancellationToken.None);

            var s = await veri.TekAsync("""
                select referans_alt, referans_ust, bayrak from public.lab_sonuc
                 where istem_satir_id = @p0 order by id desc limit 1
                """, [satirId],
                o => new { Alt = o.IsDBNull(0) ? (decimal?)null : o.GetDecimal(0),
                           Ust = o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                           Bayrak = o.GetString(2) }, CancellationToken.None);

            Assert.NotNull(s);
            // ARALIK SONUCA DONAR: tanım sonradan değişse bile eski rapor
            //   kendi aralığıyla kalır.
            Assert.Equal(80m, s!.Alt);
            Assert.Equal(120m, s.Ust);
            Assert.Equal("N", s.Bayrak);     // cihazın aralığında NORMAL
            //   Genel aralık (70-100) kullanılsaydı "H" olurdu: bayrak,
            //   hangi aralığın uygulandığını ele veren tek işaret.
        }
        finally
        {
            await veri.CalistirAsync("""
                delete from public.lab_sonuc where istem_satir_id = @p0
                """, [satirId], CancellationToken.None);
            await veri.CalistirAsync("delete from public.lab_istem_satir where id = @p0",
                                     [satirId], CancellationToken.None);
            await veri.CalistirAsync("delete from public.lab_istem where id = @p0",
                                     [istemId], CancellationToken.None);
            await TemizleAsync(veri, tetkikId, cihazId);
        }
    }
}
