using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// GEBELİK DOSYASI, GEBE İZLEMİ VE USS 221 (900 — KTS maddesi H10).
///
/// Tutulan davranışlar:
///   * gebelik haftası SAT'tan ve (SAT yoksa) beklenen doğumdan hesaplanıyor,
///   * aynı hastada iki açık dosya açılamıyor,
///   * paket rehberdeki alanlarla üretiliyor ve <b>kilo KİLOGRAM</b> kalıyor
///     (209'daki gram çevrimi burada olmamalı),
///   * risk faktörleri tekrarlı grup olarak [1], [2] … gidiyor.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class GebeIzlemTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<(int HastaId, int BelgeId, int GebelikId)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST GEBE ' || @p0, 'TEST', 'GEBE', 1,
                    (select min(id) from public.sube))
            returning id
            """, [ek], CancellationToken.None);
        await veri.CalistirAsync("""
            insert into public.taraf_hasta (id, cinsiyet, dogum_tarihi)
            values (@p0, 2, (current_date - interval '28 years')::date)
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

        // 20 haftalık gebelik: SAT 140 gün önce.
        var gebelikId = await veri.TekDegerAsync<int>("""
            insert into public.gebelik (taraf_id, sat, gebelik_no, sube_id, ekleyen)
            values (@p0, (current_date - 140), 1, 0, 1) returning id
            """, [hastaId], CancellationToken.None);

        return (hastaId, belgeId, gebelikId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int hastaId, int belgeId)
    {
        await veri.CalistirAsync("""
            delete from public.enabiz_paket_alan where paket_id in
                   (select p.id from public.enabiz_paket p
                     where p.kaynak_tur in (12, 13) and p.kaynak_id in
                           (select id from public.gebe_izlem where taraf_id = @p0))
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.enabiz_paket where kaynak_tur = 13 and kaynak_id in
                   (select id from public.gebelik where taraf_id = @p0)
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.enabiz_paket where kaynak_tur = 12 and kaynak_id in
                   (select id from public.gebe_izlem where taraf_id = @p0)
            """, [hastaId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.gebelik where taraf_id = @p0",
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
    public async Task Hafta_SATtan_ve_BEKLENEN_DOGUMDAN_hesaplanir()
    {
        if (!_olgu.Baglandi(nameof(Hafta_SATtan_ve_BEKLENEN_DOGUMDAN_hesaplanir))) return;
        var veri = _olgu.Gerekli();

        // SAT 140 gün önce → 20. hafta.
        Assert.Equal(20, await veri.TekDegerAsync<int?>(
            "select public.fn_gebelik_hafta(current_date - 140, null)", null,
            CancellationToken.None));

        // SAT YOKSA beklenen doğumdan geriye: 140 gün sonrası → 20. hafta.
        Assert.Equal(20, await veri.TekDegerAsync<int?>(
            "select public.fn_gebelik_hafta(null, current_date + 140)", null,
            CancellationToken.None));

        // İKİSİ DE YOKSA NULL: uydurma hafta, izlem takvimini yanlış kurardı.
        Assert.Null(await veri.TekDegerAsync<int?>(
            "select public.fn_gebelik_hafta(null, null)", null, CancellationToken.None));
    }

    [VtFact]
    public async Task Ayni_hastada_IKI_ACIK_dosya_olmaz()
    {
        if (!_olgu.Baglandi(nameof(Ayni_hastada_IKI_ACIK_dosya_olmaz))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId, gebelikId) = await DuzenekKurAsync(veri);
        try
        {
            // İkinci açık dosya: izlemlerin hangisine ait olduğu belirsiz kalırdı.
            await Assert.ThrowsAsync<Npgsql.PostgresException>(() =>
                veri.TekDegerAsync<int>("""
                    insert into public.gebelik (taraf_id, sat, sube_id)
                    values (@p0, current_date - 30, 0) returning id
                    """, [hastaId], CancellationToken.None));

            // Dosya sonuçlanınca yenisi açılabilir.
            await veri.CalistirAsync("""
                update public.gebelik set durum = 2, sonuc_tarihi = current_date
                 where id = @p0
                """, [gebelikId], CancellationToken.None);
            Assert.True(await veri.TekDegerAsync<int>("""
                insert into public.gebelik (taraf_id, sat, gebelik_no, sube_id)
                values (@p0, current_date - 30, 2, 0) returning id
                """, [hastaId], CancellationToken.None) > 0);
        }
        finally { await TemizleAsync(veri, hastaId, belgeId); }
    }

    [VtFact]
    public async Task Paket_221_KILOYU_CEVIRMEZ_ve_riskleri_TEKRARLI_gonderir()
    {
        if (!_olgu.Baglandi(nameof(Paket_221_KILOYU_CEVIRMEZ_ve_riskleri_TEKRARLI_gonderir)))
            return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId, gebelikId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            var izlemId = await veri.TekDegerAsync<int>("""
                insert into public.gebe_izlem
                       (gebelik_id, taraf_id, belge_id, kacinci_izlem, islem_turu,
                        izlem_tarihi, boy_cm, kilo_kg, sistolik, diastolik,
                        fetus_kalp_sesi, hemoglobin, demir, d_vitamini, sube_id)
                values (@p0, @p1, @p2, 3, 1, now(), 165.0, 68.50, 120, 80, 145,
                        11.8, 1, 1, 0)
                returning id
                """, [gebelikId, hastaId, belgeId], CancellationToken.None);

            foreach (var r in new short[] { 4, 7 })
                await veri.CalistirAsync("""
                    insert into public.gebe_izlem_risk (izlem_id, risk, sira)
                    values (@p0, @p1, @p1)
                    """, [izlemId, r], CancellationToken.None);

            var s = await uretici.UretAsync("GEBE_IZLEM", izlemId, 1, CancellationToken.None);
            Assert.True(s.PaketId > 0);

            var harita = (await veri.ListeAsync("""
                select uss_alan, coalesce(nullif(skrs_kod, ''), deger)
                  from public.enabiz_paket_alan where paket_id = @p0
                """, [s.PaketId],
                o => (Alan: o.GetString(0), Deger: o.GetString(1)), CancellationToken.None))
                .ToDictionary(x => x.Alan, x => x.Deger, StringComparer.Ordinal);

            Assert.Equal("3", harita["GEBE_IZLEM/KACINCI_GEBE_IZLEM"]);
            Assert.Equal("120", harita["GEBE_IZLEM/TANSIYON_BILGISI/SISTOLIK_KAN_BASINCI_DEGERI"]);
            Assert.Equal("145", harita["GEBE_IZLEM/FETUS_KALP_SESI_BILGISI/FETUS_KALP_SESI"]);

            // 221'DE KİLO KİLOGRAM: 209'daki gram çevrimi BURADA OLMAMALI -
            //   ikisini aynı sanmak gebeyi 68.500 kg gösterirdi.
            Assert.Equal("68.5", harita["GEBE_IZLEM/BOY_KILO_BILGILERI/KILO"]);

            // RİSK FAKTÖRLERİ TEKRARLI GRUP: [1] ve [2].
            Assert.True(harita.ContainsKey(
                "GEBELIKTE_RISK_FAKTORLERI_BILGISI[1]/GEBELIKTE_RISK_FAKTORLERI"));
            Assert.True(harita.ContainsKey(
                "GEBELIKTE_RISK_FAKTORLERI_BILGISI[2]/GEBELIKTE_RISK_FAKTORLERI"));

            // Girilmeyen ölçüm alanı hiç açılmaz.
            Assert.False(harita.ContainsKey("GEBE_IZLEM/IDRARDA_PROTEIN"));
        }
        finally { await TemizleAsync(veri, hastaId, belgeId); }
    }

    [VtFact]
    public async Task Paket_223_SAT_ve_ONCEKI_DOGUM_ister()
    {
        if (!_olgu.Baglandi(nameof(Paket_223_SAT_ve_ONCEKI_DOGUM_ister))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId, gebelikId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            // Bildirim takip numarasını İZLEMDEN alıyor: dosyanın kendi
            //   başvurusu yok.
            await veri.CalistirAsync("""
                insert into public.gebe_izlem
                       (gebelik_id, taraf_id, belge_id, kacinci_izlem, izlem_tarihi, sube_id)
                values (@p0, @p1, @p2, 1, now(), 0)
                """, [gebelikId, hastaId, belgeId], CancellationToken.None);

            // ÖNCEKİ DOĞUM DURUMU YOKKEN: dosya "bildirime hazır" değil.
            Assert.False(await veri.TekDegerAsync<bool>(
                "select bildirime_hazir from public.v_gebelik where id = @p0",
                [gebelikId], CancellationToken.None));

            await veri.CalistirAsync(
                "update public.gebelik set onceki_dogum = 2 where id = @p0",
                [gebelikId], CancellationToken.None);
            Assert.True(await veri.TekDegerAsync<bool>(
                "select bildirime_hazir from public.v_gebelik where id = @p0",
                [gebelikId], CancellationToken.None));

            var s = await uretici.UretAsync("GEBELIK_BILDIRIM", gebelikId, 1,
                                            CancellationToken.None);
            var harita = (await veri.ListeAsync("""
                select uss_alan, coalesce(nullif(skrs_kod, ''), deger)
                  from public.enabiz_paket_alan where paket_id = @p0
                """, [s.PaketId],
                o => (Alan: o.GetString(0), Deger: o.GetString(1)), CancellationToken.None))
                .ToDictionary(x => x.Alan, x => x.Deger, StringComparer.Ordinal);

            Assert.True(harita.ContainsKey("HASTA_TAKIP_BILGISI/SYSTakipNo"));
            Assert.Equal("2",
                harita["GEBELIK_BILDIRIM_VERI_SETI/BIR_ONCEKI_DOGUM_DURUMU"]);
            // SON ADET TARİHİ USS biçiminde (yyyyMMddHHmm).
            Assert.Matches("^[0-9]{12}$",
                harita["GEBELIK_BILDIRIM_VERI_SETI/SON_ADET_TARIHI"]);
        }
        finally { await TemizleAsync(veri, hastaId, belgeId); }
    }

    [VtFact]
    public async Task Sonuc_kaydi_DOSYAYI_KAPATIR_ve_224_uretilir()
    {
        if (!_olgu.Baglandi(nameof(Sonuc_kaydi_DOSYAYI_KAPATIR_ve_224_uretilir))) return;
        var veri = _olgu.Gerekli();

        var (hastaId, belgeId, gebelikId) = await DuzenekKurAsync(veri);
        var uretici = new EnabizPaketUretici(veri, NullLogger<EnabizPaketUretici>.Instance);
        try
        {
            // Takip numarası izlemden geliyor (dosyanın kendi başvurusu yok).
            await veri.CalistirAsync("""
                insert into public.gebe_izlem
                       (gebelik_id, taraf_id, belge_id, kacinci_izlem, izlem_tarihi, sube_id)
                values (@p0, @p1, @p2, 1, now(), 0)
                """, [gebelikId, hastaId, belgeId], CancellationToken.None);

            var sonucId = await veri.TekDegerAsync<int>("""
                select public.fn_gebelik_sonucla(@p0, 1::smallint, now(), 1)
                """, [gebelikId], CancellationToken.None);

            // KAYIT DOSYAYI KAPATIR: iki adımı ayrı bırakmak, kapanmış ama
            //   bildirilmemiş gebelikler üretirdi.
            Assert.Equal(2, await veri.TekDegerAsync<short>(
                "select durum from public.gebelik where id = @p0", [gebelikId],
                CancellationToken.None));

            // İKİNCİ SONUÇ AÇILAMAZ.
            await Assert.ThrowsAsync<Npgsql.PostgresException>(() =>
                veri.TekDegerAsync<int>(
                    "select public.fn_gebelik_sonucla(@p0, 1::smallint, now(), 1)",
                    [gebelikId], CancellationToken.None));

            await veri.CalistirAsync("""
                update public.gebelik_sonuc
                   set dogum_yontemi = 2, canli_bebek = 1, olu_bebek = 0
                 where id = @p0
                """, [sonucId], CancellationToken.None);

            var s = await uretici.UretAsync("GEBELIK_SONUCU", sonucId, 1,
                                            CancellationToken.None);
            var harita = (await veri.ListeAsync("""
                select uss_alan, coalesce(nullif(skrs_kod, ''), deger)
                  from public.enabiz_paket_alan where paket_id = @p0
                """, [s.PaketId],
                o => (Alan: o.GetString(0), Deger: o.GetString(1)), CancellationToken.None))
                .ToDictionary(x => x.Alan, x => x.Deger, StringComparer.Ordinal);

            Assert.True(harita.ContainsKey("HASTA_TAKIP_BILGISI/SYSTakipNo"));
            Assert.Matches("^[0-9]{12}$",
                harita["GEBELIK_SONUCU_VERI_SETI/GEBELIK_SONLANMA_TARIHI"]);
            Assert.Equal("1", harita["GEBELIK_SONUCU_VERI_SETI/GEBELIK_SONUCU"]);
            Assert.Equal("1", harita["GEBELIK_SONUCU_VERI_SETI/CANLI_DOGAN_BEBEK_SAYISI"]);

            // GİRİLMEYEN ALAN GİTMEZ: sezaryen endikasyonu yok.
            Assert.False(harita.ContainsKey("GEBELIK_SONUCU_VERI_SETI/SEZARYAN_ENDIKASYON"));

            // SONUCU OLAN DOSYA "sonuçsuz kapalı" listesinde görünmez.
            Assert.Equal(0, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_gebelik_sonucsuz where gebelik_id = @p0
                """, [gebelikId], CancellationToken.None));
        }
        finally
        {
            await veri.CalistirAsync("""
                delete from public.enabiz_paket_alan where paket_id in
                       (select id from public.enabiz_paket
                         where kaynak_tur = 14 and kaynak_id in
                               (select id from public.gebelik_sonuc where taraf_id = @p0))
                """, [hastaId], CancellationToken.None);
            await veri.CalistirAsync("""
                delete from public.enabiz_paket where kaynak_tur = 14 and kaynak_id in
                       (select id from public.gebelik_sonuc where taraf_id = @p0)
                """, [hastaId], CancellationToken.None);
            await TemizleAsync(veri, hastaId, belgeId);
        }
    }
}
