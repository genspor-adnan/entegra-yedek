using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// TEST SEVİYESİNDE YETKİ KISITI (889 — KTS denetim maddesi L7).
///
/// Kısıt bir kapıdır; kapının kapandığı okunarak değil çalıştırılarak
/// doğrulanır. Üç davranış test edilir:
///   * kısıtı OLMAYAN tetkik herkese açık (kural tanımlanana kadar hiçbir
///     ekran değişmez — en kritik güvence, çünkü tersi kurulu bir sistemi
///     ilk güncellemede durdururdu),
///   * kısıtlı tetkiki yetkisiz rol İSTEYEMEZ,
///   * yetkisiz rol sonucu GÖREMEZ / ONAYLAYAMAZ; yetkili rol yapabilir.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class TestYetkisiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam(int rolId) => new()
    {
        KullaniciId = 1, RolId = rolId, SubeId = 0,
        Yetkiler = new YetkiSeti(rolId,
            [new YetkiKaydi("lab.sonuc", 0, true, true, true, true),
             new YetkiKaydi("lab.onay", 1, true, true, true, true)], []),
    };

    /// <summary>Kendi tetkiki + iki rol: biri izinli, biri değil.</summary>
    private static async Task<(int TetkikId, int IzinliRol, int YasakRol)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var tetkikId = await veri.TekDegerAsync<int>("""
            insert into public.lab_tetkik (kod, ad, tur, birim, ondalik, bolum, durum)
            values ('TESTYET' || floor(random() * 100000)::text,
                    'Kısıtlı test tetkiki', 1, 'mg/dL', 1, 1, 0)
            returning id
            """, null, CancellationToken.None);

        var izinli = await veri.TekDegerAsync<int>("""
            insert into public.rol (kod, ad, aktif)
            values ('test.izin.' || floor(random() * 100000)::text, 'Test izinli rol', 1)
            returning id
            """, null, CancellationToken.None);
        var yasak = await veri.TekDegerAsync<int>("""
            insert into public.rol (kod, ad, aktif)
            values ('test.yasak.' || floor(random() * 100000)::text, 'Test yasaklı rol', 1)
            returning id
            """, null, CancellationToken.None);

        return (tetkikId, izinli, yasak);
    }

    private static Task KisitEkleAsync(VeriKaynagi veri, int tetkikId, int rolId) =>
        veri.CalistirAsync("""
            insert into public.lab_tetkik_kisit (tetkik_id, rol_id, iste, gor, onayla)
            values (@p0, @p1, 1, 1, 1)
            """, [tetkikId, rolId], CancellationToken.None);

    private static async Task TemizleAsync(VeriKaynagi veri, int tetkikId, params int[] roller)
    {
        await veri.CalistirAsync(
            "delete from public.lab_tetkik_kisit where tetkik_id = @p0", [tetkikId],
            CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_tetkik where id = @p0", [tetkikId],
                                 CancellationToken.None);
        foreach (var r in roller)
            await veri.CalistirAsync("delete from public.rol where id = @p0", [r],
                                     CancellationToken.None);
    }

    private static Task<bool> IzinAsync(VeriKaynagi veri, int tetkikId, int rolId, string islem) =>
        veri.TekDegerAsync<bool>(
            "select public.fn_lab_tetkik_izin(@p0, @p1, @p2)", [tetkikId, rolId, islem],
            CancellationToken.None);

    [Fact]
    public async Task Kisiti_OLMAYAN_tetkik_herkese_acik()
    {
        if (!_olgu.Baglandi(nameof(Kisiti_OLMAYAN_tetkik_herkese_acik))) return;
        var veri = _olgu.Gerekli();

        var (tetkikId, izinli, yasak) = await DuzenekKurAsync(veri);
        try
        {
            // Hiç kısıt satırı yok: her rol her işlemi yapabilir. Bu kural
            //   kurulu sistemin güncellemeden sonra AYNEN çalışmasını sağlar.
            foreach (var islem in new[] { "iste", "gor", "onayla" })
            {
                Assert.True(await IzinAsync(veri, tetkikId, izinli, islem));
                Assert.True(await IzinAsync(veri, tetkikId, yasak, islem));
            }

            // TANINMAYAN İŞLEM KAPALI: yazım hatası yüzünden kısıtın açılıp
            //   kalması, hata vermesinden kötüdür.
            Assert.False(await IzinAsync(veri, tetkikId, izinli, "sil"));
        }
        finally { await TemizleAsync(veri, tetkikId, izinli, yasak); }
    }

    [Fact]
    public async Task Tek_kisit_satiri_tetkiki_HERKESE_KAPATIR()
    {
        if (!_olgu.Baglandi(nameof(Tek_kisit_satiri_tetkiki_HERKESE_KAPATIR))) return;
        var veri = _olgu.Gerekli();

        var (tetkikId, izinli, yasak) = await DuzenekKurAsync(veri);
        try
        {
            await KisitEkleAsync(veri, tetkikId, izinli);

            Assert.True(await IzinAsync(veri, tetkikId, izinli, "gor"));
            // Satırı olmayan rol artık DIŞARIDA: beyaz liste mantığı.
            Assert.False(await IzinAsync(veri, tetkikId, yasak, "gor"));
            Assert.False(await IzinAsync(veri, tetkikId, yasak, "iste"));

            // İŞLEMLER AYRI: izinli rolün onay bayrağı kapanınca yalnız onay
            //   kapanır - görme ve isteme sürer.
            await veri.CalistirAsync("""
                update public.lab_tetkik_kisit set onayla = 0
                 where tetkik_id = @p0 and rol_id = @p1
                """, [tetkikId, izinli], CancellationToken.None);
            Assert.True(await IzinAsync(veri, tetkikId, izinli, "gor"));
            Assert.False(await IzinAsync(veri, tetkikId, izinli, "onayla"));

            // PASİF satır kısıt saymaz: tetkik yeniden herkese açılır.
            await veri.CalistirAsync(
                "update public.lab_tetkik_kisit set aktif = 0 where tetkik_id = @p0",
                [tetkikId], CancellationToken.None);
            Assert.True(await IzinAsync(veri, tetkikId, yasak, "gor"));
        }
        finally { await TemizleAsync(veri, tetkikId, izinli, yasak); }
    }

    [Fact]
    public async Task Yetkisiz_rol_kisitli_tetkiki_ISTEYEMEZ()
    {
        if (!_olgu.Baglandi(nameof(Yetkisiz_rol_kisitli_tetkiki_ISTEYEMEZ))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (tetkikId, izinli, yasak) = await DuzenekKurAsync(veri);
        await KisitEkleAsync(veri, tetkikId, izinli);
        // DIŞ KURUM YOLU: hasta `taraf_hasta`, gönderen `taraf_kurum` olmalı
        //   (LabServisi.DisKaynakAsync ikisini de doğruluyor).
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var kurumId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_kurum order by id limit 1", null,
            CancellationToken.None);
        int? istemId = null;
        try
        {
            // YASAK ROL: istem hiç açılmaz, 403 döner.
            var hata = await Assert.ThrowsAsync<GentegreHatasi>(() =>
                servis.IstemAcAsync(null, [new LabServisi.IstemSatiriIstegi(tetkikId, null)],
                    1, "", "", Baglam(yasak), CancellationToken.None,
                    hastaId: hastaId, disKurumId: kurumId, kaynakKodu: 4));
            Assert.Equal(HataKodu.Yasak, hata.Kod);

            // İZİNLİ ROL: aynı istek geçer.
            istemId = await servis.IstemAcAsync(null,
                [new LabServisi.IstemSatiriIstegi(tetkikId, null)],
                1, "", "", Baglam(izinli), CancellationToken.None,
                hastaId: hastaId, disKurumId: kurumId, kaynakKodu: 4);
            Assert.True(istemId > 0);
        }
        finally
        {
            if (istemId is { } iid)
            {
                await veri.CalistirAsync("""
                    delete from public.lab_sonuc where istem_satir_id in
                           (select id from public.lab_istem_satir where istem_id = @p0)
                    """, [iid], CancellationToken.None);
                await veri.CalistirAsync(
                    "delete from public.lab_istem_satir where istem_id = @p0", [iid],
                    CancellationToken.None);
                await veri.CalistirAsync("delete from public.lab_numune where istem_id = @p0",
                                         [iid], CancellationToken.None);
                await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [iid],
                                         CancellationToken.None);
            }
            await TemizleAsync(veri, tetkikId, izinli, yasak);
        }
    }
}
