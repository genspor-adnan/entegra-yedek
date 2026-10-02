using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// AŞI MODÜLÜ VE USS 207 (898 — KTS denetim maddesi H10).
///
/// H10'un altı paketinden beşinin sorunu paket değil KAYNAK VERİ idi; aşı
/// kaydı hiç yoktu. Test iki şeyi tutuyor: kaydın kuralları (doz şeması,
/// mükerrer doz, iptal) ve paketin rehberdeki şemaya uyması — alan adları
/// rehber.enabiz.gov.tr'den birebir alındı, uydurulmadı.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class AsiPaketiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<(int AsiId, int HastaId, int BelgeId)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var asiId = await veri.TekDegerAsync<int>("""
            insert into public.asi (kod, ad, skrs_kod, doz_sayisi, aktif)
            values ('TESTASI' || @p0, 'Test aşısı', 'T' || @p0, 3, 1)
            returning id
            """, [ek], CancellationToken.None);

        // TAKİP NUMARALI BAŞVURU TESTİN KENDİ DÜZENEĞİDİR. Önce "var olanı
        //   bul" deniyordu; dev veritabanında takip numaralı başvuru
        //   olmadığı için testler sessizce boş geçiyordu - yeşil ama hiçbir
        //   şey doğrulamayan test, olmayan testten kötüdür.
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);
        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, ekleyen)
            values (19, 30, @p0, (select min(id) from public.sube), now(), 1)
            returning id
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("""
            insert into public.belge_basvuru (id, hasta_id, sys_takip_no)
            values (@p0, @p1, 'TEST-TKP-' || @p0::text)
            """, [belgeId, hastaId], CancellationToken.None);

        return (asiId, hastaId, belgeId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int asiId, int belgeId = 0)
    {
        await veri.CalistirAsync("""
            delete from public.enabiz_paket_alan where paket_id in
                   (select p.id from public.enabiz_paket p
                     where p.kaynak_tur = 10 and p.kaynak_id in
                           (select id from public.asi_uygulama where asi_id = @p0))
            """, [asiId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.enabiz_paket where kaynak_tur = 10 and kaynak_id in
                   (select id from public.asi_uygulama where asi_id = @p0)
            """, [asiId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.asi_uygulama where asi_id = @p0",
                                 [asiId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.asi where id = @p0", [asiId],
                                 CancellationToken.None);
        if (belgeId > 0)
        {
            await veri.CalistirAsync("delete from public.belge_basvuru where id = @p0",
                                     [belgeId], CancellationToken.None);
            await veri.CalistirAsync("delete from public.belge where id = @p0",
                                     [belgeId], CancellationToken.None);
        }
    }

    private static Task<int> UygulaAsync(VeriKaynagi veri, int hastaId, int asiId,
                                         int belgeId, short doz) =>
        veri.TekDegerAsync<int>("""
            insert into public.asi_uygulama
                   (taraf_id, belge_id, asi_id, doz_no, lot, uygulama_zamani, sube_id)
            values (@p0, nullif(@p1, 0), @p2, @p3, 'LOT-1', now(), 0)
            returning id
            """, [hastaId, belgeId, asiId, doz], CancellationToken.None);

    [VtFact]
    public async Task Ayni_doz_IKI_KEZ_yazilamaz_ve_iptal_kaydi_SILMEZ()
    {
        if (!_olgu.Baglandi(nameof(Ayni_doz_IKI_KEZ_yazilamaz_ve_iptal_kaydi_SILMEZ))) return;
        var veri = _olgu.Gerekli();

        var (asiId, hastaId, belgeId) = await DuzenekKurAsync(veri);
        try
        {
            var id = await UygulaAsync(veri, hastaId, asiId, belgeId, 1);

            // AYNI HASTAYA AYNI AŞININ AYNI DOZU BİR KEZ: kısmi benzersiz index.
            await Assert.ThrowsAsync<Npgsql.PostgresException>(
                () => UygulaAsync(veri, hastaId, asiId, belgeId, 1));

            // İPTAL SİLMEZ: uygulanmış aşı geri alınamaz, izi kalmalı.
            await veri.CalistirAsync("""
                update public.asi_uygulama set durum = 0, iptal_neden = 'yanlış hasta'
                 where id = @p0
                """, [id], CancellationToken.None);
            Assert.Equal(1, await veri.TekDegerAsync<int>(
                "select count(*)::int from public.asi_uygulama where id = @p0", [id],
                CancellationToken.None));

            // İptal edilen doz yeniden yazılabilir - hatalı kayıt düzeltilebilmeli.
            var yeni = await UygulaAsync(veri, hastaId, asiId, belgeId, 1);
            Assert.True(yeni > 0);
        }
        finally { await TemizleAsync(veri, asiId, belgeId); }
    }

    [VtFact]
    public async Task Paket_207_REHBERDEKI_alanlarla_uretilir()
    {
        if (!_olgu.Baglandi(nameof(Paket_207_REHBERDEKI_alanlarla_uretilir))) return;
        var veri = _olgu.Gerekli();

        var (asiId, hastaId, belgeId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            var id = await UygulaAsync(veri, hastaId, asiId, belgeId, 2);
            var s = await uretici.UretAsync("ASI", id, 1, CancellationToken.None);
            Assert.True(s.PaketId > 0);

            var alanlar = await veri.ListeAsync("""
                select uss_alan, deger from public.enabiz_paket_alan
                 where paket_id = @p0 order by id
                """, [s.PaketId],
                o => (Alan: o.GetString(0), Deger: o.GetString(1)), CancellationToken.None);
            var harita = alanlar.ToDictionary(x => x.Alan, x => x.Deger, StringComparer.Ordinal);

            // ZORUNLU ÖGELER (rehber → 207 → YAPI): takip no, aşı, doz.
            Assert.True(harita.ContainsKey("HASTA_TAKIP_BILGISI/SYSTakipNo"));
            Assert.True(harita.ContainsKey("ASI_VERI_SETI/ASI_BILGISI[1]/ASI"));
            Assert.Equal("2", harita["ASI_VERI_SETI/ASI_BILGISI[1]/ASI_DOZU"]);
            // ASI_YAPILMA_ZAMANI USS biçiminde (yyyyMMddHHmm).
            Assert.Matches("^[0-9]{12}$",
                harita["ASI_VERI_SETI/ASI_BILGISI[1]/ASI_YAPILMA_ZAMANI"]);

            // BOŞ ÖGE GÖNDERİLMEZ: barkod girilmediyse alan hiç açılmaz -
            //   veri yokken veri varmış gibi göstermek olurdu.
            Assert.False(harita.ContainsKey("ASI_VERI_SETI/ASI_BILGISI[1]/ASI_BARKODU"));

            // AYNI İÇERİK → AYNI PAKET: ikinci üretim yeni satır açmaz.
            var s2 = await uretici.UretAsync("ASI", id, 1, CancellationToken.None);
            Assert.Equal(s.PaketId, s2.PaketId);
        }
        finally { await TemizleAsync(veri, asiId, belgeId); }
    }

    [VtFact]
    public async Task SKRS_kodu_olmayan_asi_ASI_OGESI_URETMEZ()
    {
        if (!_olgu.Baglandi(nameof(SKRS_kodu_olmayan_asi_ASI_OGESI_URETMEZ))) return;
        var veri = _olgu.Gerekli();

        var (asiId, hastaId, belgeId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            // SKRS kodu silinince aşı e-Nabız'a gönderilemez; paket üretilse
            //   bile ASI ögesi boş kalır ve EKSİK olarak raporlanır - sessiz
            //   bir boşluk bırakmaz (`v_asi_skrs_eksik` de bunu listeler).
            await veri.CalistirAsync("update public.asi set skrs_kod = '' where id = @p0",
                                     [asiId], CancellationToken.None);
            var id = await UygulaAsync(veri, hastaId, asiId, belgeId, 1);

            var s = await uretici.UretAsync("ASI", id, 1, CancellationToken.None);
            Assert.Contains(s.Eksikler,
                e => e.Contains("ASI", StringComparison.Ordinal));

            Assert.Equal(1, await veri.TekDegerAsync<int>(
                "select count(*)::int from public.v_asi_skrs_eksik where id = @p0",
                [asiId], CancellationToken.None));
        }
        finally { await TemizleAsync(veri, asiId, belgeId); }
    }
}
