using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// LABORATUVAR KURALLARI (433/434) — veritabanına dokunan uçtan uca test.
///
/// Kural motorunun tamamı SQL'de yaşıyor: barkod kontrol hanesi, bayrak,
/// yaşa/cinsiyete göre referans seçimi, cihaz kodu çözümü ve host query.
/// C# tarafını okumak doğruluğu göstermez - çalıştırınca görülür.
///
/// Buradaki bir hata sahada "yanlış hastaya sonuç" ya da "panik değer normal
/// göründü" olarak çıkar; ikisi de hasta güvenliği sorunudur.
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public class LabTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public LabTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    // ---------------------------------------------------------------- barkod

    [Fact]
    public async Task Barkod_kontrol_hanesi_TEK_HANE_HATASINI_yakalar()
    {
        if (!_olgu.Baglandi(nameof(Barkod_kontrol_hanesi_TEK_HANE_HATASINI_yakalar))) return;
        var veri = _olgu.Gerekli();

        var barkod = await veri.TekDegerAsync<string>(
            "select public.fn_lab_barkod_uret(0)") ?? "";
        Assert.NotEqual("", barkod);

        var govde = barkod[..^1];
        var kontrol = int.Parse(barkod[^1..]);
        Assert.Equal(kontrol, await veri.TekDegerAsync<int>(
            "select public.fn_lab_barkod_kontrol(@p0)", [govde]));

        // Bir hanesi degisen barkod ARTIK GECERLI OLMAMALI: elle okunan
        //   barkodun yanlis numuneye baglanmasi, sonucun yanlis hastaya
        //   yazilmasi demektir.
        var bozuk = govde[..^1] + (char)('0' + ((govde[^1] - '0' + 1) % 10));
        Assert.NotEqual(kontrol, await veri.TekDegerAsync<int>(
            "select public.fn_lab_barkod_kontrol(@p0)", [bozuk]));
    }

    [Fact]
    public async Task Barkod_HER_SEFERINDE_FARKLI()
    {
        if (!_olgu.Baglandi(nameof(Barkod_HER_SEFERINDE_FARKLI))) return;
        var veri = _olgu.Gerekli();

        var a = await veri.TekDegerAsync<string>("select public.fn_lab_barkod_uret(0)");
        var b = await veri.TekDegerAsync<string>("select public.fn_lab_barkod_uret(0)");
        Assert.NotEqual(a, b);
    }

    // ---------------------------------------------------------------- bayrak

    [Theory]
    // deger, alt, ust, panikAlt, panikUst, beklenen
    [InlineData(5.0, 4.0, 10.0, null, null, "N")]
    [InlineData(12.5, 4.0, 10.0, null, null, "H")]
    [InlineData(3.0, 4.0, 10.0, null, null, "L")]
    [InlineData(2.0, 4.0, 10.0, 2.5, null, "LL")]
    [InlineData(20.0, 4.0, 10.0, null, 15.0, "HH")]
    // Referans YOKSA bayrak da yok: uydurulmus "normal", hekimi yanıltır.
    [InlineData(7.0, null, null, null, null, "")]
    public async Task Bayrak_panik_referanstan_ONCE_gelir(
        double deger, double? alt, double? ust, double? panikAlt, double? panikUst,
        string beklenen)
    {
        if (!_olgu.Baglandi(nameof(Bayrak_panik_referanstan_ONCE_gelir))) return;
        var veri = _olgu.Gerekli();

        var bayrak = await veri.TekDegerAsync<string>(
            "select public.fn_lab_bayrak(@p0, @p1, @p2, @p3, @p4)",
            [(decimal)deger, (decimal?)alt, (decimal?)ust,
             (decimal?)panikAlt, (decimal?)panikUst]);

        Assert.Equal(beklenen, bayrak ?? "");
    }

    // -------------------------------------------------------------- referans

    [Fact]
    public async Task Referans_EN_DAR_yas_araligini_secer()
    {
        if (!_olgu.Baglandi(nameof(Referans_EN_DAR_yas_araligini_secer))) return;
        var veri = _olgu.Gerekli();

        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'HGB'");
        if (tetkikId == 0) return;   // katalog seed'i yoksa test anlamsız

        // Ayni tetkige DAR bir yenidogan araligi eklenir; genis eriskin
        //   araligi zaten seed'de var. Dogru davranis: 10 gunluk hasta icin
        //   DAR aralik secilmeli - genis araligi secmek, yenidogani "normal"
        //   gostererek gercek bir anemiyi kacirirdi.
        // TEMIZLIK GARANTISI: kayitlar try ICINDE acilir. Disarida acilip
        //   sonraki satir patlarsa (ornegin FK), finally hic calismaz ve
        //   test verisi katalogda kalir - referans araligi kalinti olarak
        //   kalirsa sonraki sonuclar YANLIS degerlendirilir.
        var refId = 0;
        var hastaId = 0;
        try
        {
            refId = await veri.TekDegerAsync<int>("""
                insert into public.lab_tetkik_referans
                       (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, alt, ust, kaynak)
                values (@p0, 0, 0, 28, 14.0, 22.0, 'TEST')
                returning id
                """, [tetkikId]);

            // Demografi taraf'ta degil taraf_hasta'da: yas ve cinsiyet oradan
            //   okunur (fn_lab_referans).
            hastaId = await veri.TekDegerAsync<int>("""
                insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
                values ('TEST YENIDOGAN', 'TEST', 'YENIDOGAN', 1,
                        (select min(id) from public.sube))
                returning id
                """);
            await veri.CalistirAsync("""
                insert into public.taraf_hasta (id, dogum_tarihi, cinsiyet)
                values (@p0, current_date - 10, 1)
                """, [hastaId]);

            var r = await veri.TekAsync("""
                select alt, ust from public.fn_lab_referans(@p0, @p1, current_date)
                 where tetkik_id is not null
                """, [tetkikId, hastaId],
                o => new { Alt = o.GetDecimal(0), Ust = o.GetDecimal(1) });

            Assert.NotNull(r);
            Assert.Equal(14.0m, r!.Alt);
            Assert.Equal(22.0m, r.Ust);
        }
        finally
        {
            if (refId != 0)
                await veri.CalistirAsync(
                    "delete from public.lab_tetkik_referans where id = @p0", [refId]);
            if (hastaId != 0)
            {
                await veri.CalistirAsync("delete from public.taraf_hasta where id = @p0",
                                         [hastaId]);
                await veri.CalistirAsync("delete from public.taraf where id = @p0",
                                         [hastaId]);
            }
        }
    }

    // ----------------------------------------------------------------- cihaz

    [Fact]
    public async Task Cihaz_kodu_ESLESME_YOKSA_tetkik_koduna_duser()
    {
        if (!_olgu.Baglandi(nameof(Cihaz_kodu_ESLESME_YOKSA_tetkik_koduna_duser))) return;
        var veri = _olgu.Gerekli();

        var cihazId = await veri.TekDegerAsync<int>(
            "select id from public.cihaz order by id limit 1");
        var glu = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU'");
        if (cihazId == 0 || glu == 0) return;

        // Eşleme satırı YOK: kod eşitliğiyle bulunmalı. Her cihaz için 200
        //   satır eşlemeyi elle girdirmek kurulumu haftalara yayardı.
        var tetkikId = await veri.TekDegerAsync<int>(
            "select tetkik_id from public.fn_lab_cihaz_tetkik(@p0, 'GLU', '')",
            [cihazId]);
        Assert.Equal(glu, tetkikId);

        // Eşleme satırı VARSA o kazanır - cihaz kendi kodunu kullanabilir.
        var eslemeId = await veri.TekDegerAsync<int>("""
            insert into public.lab_cihaz_test_esleme
                   (cihaz_id, cihaz_test_kodu, tetkik_id, carpan, ofset)
            values (@p0, 'GLUC-2', @p1, 0.0555, 0)
            returning id
            """, [cihazId, glu]);
        try
        {
            var e = await veri.TekAsync("""
                select tetkik_id, carpan
                  from public.fn_lab_cihaz_tetkik(@p0, 'gluc-2', '')
                """, [cihazId],
                o => new { Id = o.GetInt32(0), Carpan = o.GetDecimal(1) });

            Assert.NotNull(e);
            Assert.Equal(glu, e!.Id);
            // Büyük/küçük harf farkı eşlemeyi bozmamalı: cihazlar kodu
            //   istedikleri biçimde yollar.
            Assert.Equal(0.0555m, e.Carpan);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.lab_cihaz_test_esleme where id = @p0", [eslemeId]);
        }
    }

    [Fact]
    public async Task Calisma_listesi_YALNIZ_KABUL_EDILMIS_numuneyi_verir()
    {
        if (!_olgu.Baglandi(nameof(Calisma_listesi_YALNIZ_KABUL_EDILMIS_numuneyi_verir)))
            return;
        var veri = _olgu.Gerekli();

        var cihazId = await veri.TekDegerAsync<int>(
            "select id from public.cihaz order by id limit 1");
        var glu = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU'");
        if (cihazId == 0 || glu == 0) return;

        var hastaId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (unvan, ad, soyad, hasta, sube_id)
            values ('TEST LAB HASTA', 'TEST', 'LAB', 1,
                    (select min(id) from public.sube))
            returning id
            """);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem (taraf_id, istem_no, bolum, durum)
            values (@p0, 'TEST-LAB-1', 1, 1)
            returning id
            """, [hastaId]);
        var barkod = await veri.TekDegerAsync<string>(
            "select public.fn_lab_barkod_uret(0)") ?? "";
        var numuneId = await veri.TekDegerAsync<int>("""
            insert into public.lab_numune (barkod, istem_id, hasta_id, numune_tipi,
                                           tup_tipi, durum)
            values (@p0, @p1, @p2, 1, 1, 2)
            returning id
            """, [barkod, istemId, hastaId]);
        await veri.CalistirAsync("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, numune_id,
                                                kod, ad, durum, sira)
            values (@p0, @p1, @p2, 'GLU', 'Glukoz', 1, 10)
            """, [istemId, glu, numuneId]);

        try
        {
            // Numune KABUL EDILMEDI (durum 2): cihaz bu tüpü çalışmamalı -
            //   reddedilebilecek bir tüpü çalıştırmak, sonradan silinecek
            //   sonuç üretir.
            var oncesi = await veri.ListeAsync(
                "select tetkik_id from public.fn_lab_cihaz_calisma_listesi(@p0, @p1)",
                [cihazId, barkod], o => o.GetInt32(0));
            Assert.Empty(oncesi);

            await veri.CalistirAsync("""
                update public.lab_numune set durum = 3, kabul_zamani = now()
                 where id = @p0
                """, [numuneId]);

            var sonrasi = await veri.ListeAsync(
                "select tetkik_id from public.fn_lab_cihaz_calisma_listesi(@p0, @p1)",
                [cihazId, barkod], o => o.GetInt32(0));
            Assert.Single(sonrasi);
            Assert.Equal(glu, sonrasi[0]);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.lab_istem_satir where istem_id = @p0", [istemId]);
            await veri.CalistirAsync(
                "delete from public.lab_numune where id = @p0", [numuneId]);
            await veri.CalistirAsync("delete from public.lab_istem where id = @p0",
                                     [istemId]);
            await veri.CalistirAsync("delete from public.taraf where id = @p0", [hastaId]);
        }
    }
}
