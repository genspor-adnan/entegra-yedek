using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// TEST TEKRARI TALEBİ (891 — KTS denetim maddesi L8).
///
/// Talebin işi laboratuvara ELEKTRONİK olarak iş açmak; iki şey yanlış
/// giderse denetimde de klinikte de sorun olur: aynı iş iki kez açılırsa
/// laboratuvar iki kez çalışır, talep karşılandığı hâlde kuyrukta kalırsa
/// "hiç yapılmamış" görünür. İkisi de ancak çalıştırılınca ortaya çıkar.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class TekrarIstegiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, RolIdleri = [1], SubeYazma = true, SubeId = 0,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("lab.sonuc", 0, true, true, true, true)], []),
    };

    private static async Task<(int IstemId, int SatirId)> DuzenekKurAsync(VeriKaynagi veri)
    {
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU' limit 1", null,
            CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);

        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 0, 'TEST-TKR-' || floor(random() * 1000000)::text, 1, 2, 3, 1)
            returning id
            """, [hastaId], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 1, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);

        return (istemId, satirId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int istemId)
    {
        await veri.CalistirAsync("""
            delete from public.lab_tekrar_istegi where istem_satir_id in
                   (select id from public.lab_istem_satir where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.lab_sonuc where istem_satir_id in
                   (select id from public.lab_istem_satir where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId],
                                 CancellationToken.None);
    }

    private static Task<int> IsteAsync(VeriKaynagi veri, int satirId, short tur,
                                       short gerekce = 1) =>
        veri.TekDegerAsync<int>(
            "select public.fn_lab_tekrar_iste(@p0, @p1, @p2, 'test', 1, null)",
            [satirId, tur, gerekce], CancellationToken.None);

    private static Task<short> SatirDurumAsync(VeriKaynagi veri, int satirId) =>
        veri.TekDegerAsync<short>(
            "select durum from public.lab_istem_satir where id = @p0", [satirId],
            CancellationToken.None);

    [VtFact]
    public async Task Ayni_satirda_IKINCI_acik_talep_acilamaz_ve_tur_satir_durumunu_belirler()
    {
        if (!_olgu.Baglandi(nameof(Ayni_satirda_IKINCI_acik_talep_acilamaz_ve_tur_satir_durumunu_belirler)))
            return;
        var veri = _olgu.Gerekli();

        var (istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            // YENİ NUMUNE istendiğinde satır "tekrar numune bekliyor" (6):
            //   numune kabul ekranı bunu zaten gösteriyor.
            await IsteAsync(veri, satirId, 2);
            Assert.Equal(6, await SatirDurumAsync(veri, satirId));

            // İKİNCİ TALEP AÇILAMAZ: laboratuvara aynı işi iki kez yaptırırdı.
            var h = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => IsteAsync(veri, satirId, 1));
            Assert.Contains("zaten açık", h.MessageText, StringComparison.Ordinal);

            // GEREKÇE ZORUNLU: "neden tekrar" kalite kaydının parçası.
            await veri.TekDegerAsync<int>(
                "select public.fn_lab_tekrar_iptal((select id from public.lab_tekrar_istegi "
                + "where istem_satir_id = @p0 and durum = 1), 'test iptali', 1)",
                [satirId], CancellationToken.None);
            var h2 = await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => IsteAsync(veri, satirId, 1, 0));
            Assert.Contains("gerekçe", h2.MessageText, StringComparison.Ordinal);

            // AYNI NUMUNEDEN tekrar: satır "çalışılıyor" (2) - laboratuvarın
            //   elinde iş vardır, numune beklenmez.
            await IsteAsync(veri, satirId, 1);
            Assert.Equal(2, await SatirDurumAsync(veri, satirId));
        }
        finally { await TemizleAsync(veri, istemId); }
    }

    [VtFact]
    public async Task Yeni_sonuc_yazilinca_talep_KENDILIGINDEN_kapanir()
    {
        if (!_olgu.Baglandi(nameof(Yeni_sonuc_yazilinca_talep_KENDILIGINDEN_kapanir))) return;
        var veri = _olgu.Gerekli();
        var servis = new LabServisi(veri, NullLogger<LabServisi>.Instance);

        var (istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            var tekrarId = await IsteAsync(veri, satirId, 1);

            var y = await servis.SonucYazAsync(
                new LabServisi.SonucIstegi(satirId, "92", null, null, null),
                null, null, Baglam(), CancellationToken.None);

            // TALEBİ SİSTEM KAPATIR: elle kapatmaya bırakmak, çalışılmış ama
            //   kuyrukta duran talepler biriktirirdi.
            var kayit = await veri.TekAsync("""
                select durum, karsilayan_sonuc_id from public.lab_tekrar_istegi where id = @p0
                """, [tekrarId],
                o => new { Durum = o.GetInt16(0),
                           Sonuc = o.IsDBNull(1) ? (long?)null : o.GetInt64(1) },
                CancellationToken.None);
            Assert.Equal(2, kayit!.Durum);
            Assert.Equal(y.SonucId, kayit.Sonuc);
            Assert.Contains("Tekrar talebi karşılandı", y.Mesaj, StringComparison.Ordinal);

            // Kapanınca AYNI satıra yeniden talep açılabilir - ikinci bir
            //   tekrar istenebilmeli.
            var ikinci = await IsteAsync(veri, satirId, 1, 3);
            Assert.True(ikinci > 0);
        }
        finally { await TemizleAsync(veri, istemId); }
    }

    [VtFact]
    public async Task Iptal_GEREKCE_ister_ve_satiri_eski_haline_dondurur()
    {
        if (!_olgu.Baglandi(nameof(Iptal_GEREKCE_ister_ve_satiri_eski_haline_dondurur))) return;
        var veri = _olgu.Gerekli();

        var (istemId, satirId) = await DuzenekKurAsync(veri);
        try
        {
            var tekrarId = await IsteAsync(veri, satirId, 2);
            Assert.Equal(6, await SatirDurumAsync(veri, satirId));

            var h = await Assert.ThrowsAsync<Npgsql.PostgresException>(() =>
                veri.TekDegerAsync<int>("select public.fn_lab_tekrar_iptal(@p0, '', 1)",
                                        [tekrarId], CancellationToken.None));
            Assert.Contains("İptal nedeni", h.MessageText, StringComparison.Ordinal);

            await veri.TekDegerAsync<int>(
                "select public.fn_lab_tekrar_iptal(@p0, 'yanlış istendi', 1)",
                [tekrarId], CancellationToken.None);

            // Sonucu olmayan satır "bekliyor"a döner: talep iptal edildiği
            //   hâlde satırın "tekrar numune bekliyor" kalması, hiç bitmeyen
            //   bir iş gösterirdi.
            Assert.Equal(1, await SatirDurumAsync(veri, satirId));
            Assert.Equal(3, await veri.TekDegerAsync<short>(
                "select durum from public.lab_tekrar_istegi where id = @p0", [tekrarId],
                CancellationToken.None));
        }
        finally { await TemizleAsync(veri, istemId); }
    }
}
