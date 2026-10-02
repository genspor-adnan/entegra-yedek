using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// BEBEK / ÇOCUK İZLEMİ VE USS 209 (899 — KTS maddesi H10).
///
/// Üç şey tutuluyor:
///   * persentil LMS formülüyle doğru hesaplanıyor mu (gerçek WHO satırıyla),
///   * eğri verisi YOKKEN persentil NULL dönüyor mu ("hesaplayamadım" ile
///     "sıfırıncı persentil" farklı şeylerdir),
///   * paket rehberdeki alanlarla üretiliyor ve <b>kilo GRAMA</b> çevriliyor mu.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class CocukIzlemTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>12 aylık erkek bir çocuk + takip numaralı başvuru.</summary>
    private static async Task<(int HastaId, int BelgeId)> DuzenekKurAsync(VeriKaynagi veri)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST COCUK ' || @p0, 'TEST', 'ÇOCUK', 1,
                    (select min(id) from public.sube))
            returning id
            """, [ek], CancellationToken.None);
        await veri.CalistirAsync("""
            insert into public.taraf_hasta (id, cinsiyet, dogum_tarihi)
            values (@p0, 1, (current_date - interval '12 months')::date)
            """, [hastaId], CancellationToken.None);

        var belgeId = await veri.TekDegerAsync<int>("""
            insert into public.belge (tur, tipi, taraf_id, sube_id, belge_tarihi, ekleyen)
            values (19, 30, @p0, (select min(id) from public.sube), now(), 1)
            returning id
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("""
            insert into public.belge_basvuru (id, hasta_id, sys_takip_no)
            values (@p0, @p1, 'TEST-TKP-' || @p0::text)
            """, [belgeId, hastaId], CancellationToken.None);

        return (hastaId, belgeId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int hastaId, int belgeId)
    {
        await veri.CalistirAsync("""
            delete from public.enabiz_paket_alan where paket_id in
                   (select p.id from public.enabiz_paket p
                     where p.kaynak_tur = 11 and p.kaynak_id in
                           (select id from public.cocuk_izlem where taraf_id = @p0))
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.enabiz_paket where kaynak_tur = 11 and kaynak_id in
                   (select id from public.cocuk_izlem where taraf_id = @p0)
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.cocuk_izlem where taraf_id = @p0",
                                 [hastaId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.belge_basvuru where id = @p0",
                                 [belgeId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.belge where id = @p0", [belgeId],
                                 CancellationToken.None);
        await veri.CalistirAsync("delete from public.taraf_hasta where id = @p0", [hastaId],
                                 CancellationToken.None);
        await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId],
                                 CancellationToken.None);
    }

    [VtFact]
    public async Task Persentil_LMS_formuluyle_hesaplanir_egri_yoksa_NULL_doner()
    {
        if (!_olgu.Baglandi(nameof(Persentil_LMS_formuluyle_hesaplanir_egri_yoksa_NULL_doner)))
            return;
        var veri = _olgu.Gerekli();

        // EĞRİ YOKKEN: "hesaplayamadım" - sıfırıncı persentil DEĞİL.
        Assert.Null(await veri.TekDegerAsync<decimal?>(
            "select public.fn_cocuk_persentil(1::smallint, 1::smallint, 12, 9.6)",
            null, CancellationToken.None));

        // GERÇEK WHO SATIRI (erkek, 12 ay, kilo): L=-0.1600 M=9.6479 S=0.11080
        await veri.CalistirAsync("""
            insert into public.cocuk_buyume_lms (kaynak, cinsiyet, olcut, ay, l, m, s)
            values ('TEST-WHO', 1, 1, 12, -0.1600, 9.6479, 0.11080)
            """, null, CancellationToken.None);
        try
        {
            // MEDYAN TAM 50: M değeri verilince z = 0 olmalı.
            Assert.Equal(50.0m, await veri.TekDegerAsync<decimal?>("""
                select public.fn_cocuk_persentil(1::smallint, 1::smallint, 12, 9.6479,
                                                 'TEST-WHO')
                """, null, CancellationToken.None));

            // Düşük ve yüksek uçlar makul aralıkta (WHO tablosuyla uyumlu).
            var dusuk = await veri.TekDegerAsync<decimal?>("""
                select public.fn_cocuk_persentil(1::smallint, 1::smallint, 12, 8.0,
                                                 'TEST-WHO')
                """, null, CancellationToken.None);
            var yuksek = await veri.TekDegerAsync<decimal?>("""
                select public.fn_cocuk_persentil(1::smallint, 1::smallint, 12, 11.5,
                                                 'TEST-WHO')
                """, null, CancellationToken.None);
            Assert.InRange(dusuk!.Value, 2m, 8m);
            Assert.InRange(yuksek!.Value, 90m, 98m);

            // NEGATİF / SIFIR ÖLÇÜM: hesap yapılmaz.
            Assert.Null(await veri.TekDegerAsync<decimal?>("""
                select public.fn_cocuk_persentil(1::smallint, 1::smallint, 12, 0,
                                                 'TEST-WHO')
                """, null, CancellationToken.None));
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.cocuk_buyume_lms where kaynak = 'TEST-WHO'", null,
                CancellationToken.None);
        }
    }

    [VtFact]
    public async Task Paket_209_uretilir_ve_KILO_GRAMA_cevrilir()
    {
        if (!_olgu.Baglandi(nameof(Paket_209_uretilir_ve_KILO_GRAMA_cevrilir))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            var izlemId = await veri.TekDegerAsync<int>("""
                insert into public.cocuk_izlem
                       (taraf_id, belge_id, kacinci_izlem, islem_turu, izlem_tarihi,
                        boy_cm, kilo_kg, bas_cevresi_cm, sube_id)
                values (@p0, @p1, 5, 1, now(), 75.5, 9.648, 46.2, 0)
                returning id
                """, [hastaId, belgeId], CancellationToken.None);

            var s = await uretici.UretAsync("COCUK_IZLEM", izlemId, 1, CancellationToken.None);
            Assert.True(s.PaketId > 0);

            var harita = (await veri.ListeAsync("""
                select uss_alan, coalesce(nullif(skrs_kod, ''), deger)
                  from public.enabiz_paket_alan where paket_id = @p0
                """, [s.PaketId],
                o => (Alan: o.GetString(0), Deger: o.GetString(1)), CancellationToken.None))
                .ToDictionary(x => x.Alan, x => x.Deger, StringComparer.Ordinal);

            Assert.True(harita.ContainsKey("HASTA_TAKIP_BILGISI/SYSTakipNo"));
            Assert.Equal("5", harita["BEBEK_COCUK_IZLEM_VERI_SETI/KACINCI_IZLEM"]);
            Assert.Equal("75.5", harita["BEBEK_COCUK_IZLEM_VERI_SETI/BOY_KILO_BILGILERI/BOY"]);

            // KİLO PAKETTE GRAM: 9,648 kg → 9648. Çevrim tek yerde yapılıyor;
            //   ekranda kilogram kalıyor.
            Assert.Equal("9648", harita["BEBEK_COCUK_IZLEM_VERI_SETI/BOY_KILO_BILGILERI/KILO"]);
            Assert.Equal("46.2", harita["BEBEK_COCUK_IZLEM_VERI_SETI/BAS_CEVRESI"]);

            // GİRİLMEYEN ÖLÇÜM ALANI HİÇ AÇILMAZ.
            Assert.False(harita.ContainsKey("BEBEK_COCUK_IZLEM_VERI_SETI/HEMOGLOBIN"));
        }
        finally { await TemizleAsync(veri, hastaId, belgeId); }
    }

    [VtFact]
    public async Task Ayni_izlem_sirasi_IKI_KEZ_yazilamaz()
    {
        if (!_olgu.Baglandi(nameof(Ayni_izlem_sirasi_IKI_KEZ_yazilamaz))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId) = await DuzenekKurAsync(veri);
        try
        {
            async Task<int> EkleAsync() => await veri.TekDegerAsync<int>("""
                insert into public.cocuk_izlem (taraf_id, belge_id, kacinci_izlem, sube_id)
                values (@p0, @p1, 3, 0) returning id
                """, [hastaId, belgeId], CancellationToken.None);

            var id = await EkleAsync();
            await Assert.ThrowsAsync<Npgsql.PostgresException>(EkleAsync);

            // İPTAL EDİLEN SAYILMAZ: hatalı kayıt düzeltilebilmeli.
            await veri.CalistirAsync("""
                update public.cocuk_izlem set durum = 0, iptal_neden = 'test'
                 where id = @p0
                """, [id], CancellationToken.None);
            Assert.True(await EkleAsync() > 0);

            // YAŞ AYI izlem tarihinden hesaplanır: 12 aylık çocuk.
            Assert.Equal(12, await veri.TekDegerAsync<int?>("""
                select yas_ay from public.v_cocuk_izlem
                 where taraf_id = @p0 and durum = 1 limit 1
                """, [hastaId], CancellationToken.None));
        }
        finally { await TemizleAsync(veri, hastaId, belgeId); }
    }
}
