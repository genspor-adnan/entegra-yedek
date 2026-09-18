using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// BAKANLIK TELERADYOLOJİ PROFİLİ (809–813).
///
/// Kullanıcı: *"sağlık bakanlığının teleradyoloji süreci var ona bak bi"* →
/// *"bunları yap"*. Kılavuz 3.46'nın mesajı REDDETTİREN kuralları burada
/// sınanıyor: dört parça gövde, Bulgular 50 karakter, modalite iki harf,
/// kontrast biçimi, accession zorunluluğu ve eksik listesi.
///
/// Testler kendi verisini açar ve işlemi geri alır: tarayıcıda açılmış gerçek
/// kayıtları ödünç alan test, o kayıt değişince kırılıyordu (806/807 dersi).
/// </summary>
public sealed class BakanlikProfiliTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;
    private static readonly CancellationToken Iptal = CancellationToken.None;

    private static async Task<(int Sube, int Kurum, int Hasta)> ZeminAsync(
        NpgsqlConnection b, NpgsqlTransaction t, short bakanlik)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1", t, [], Iptal);
        var taraf = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, musteri, sube_id) "
            + "values ('BAKANLIK TEST KURUMU', 'BKNTST', 1, @p0) returning id",
            t, [sube], Iptal);
        var kurum = await b.TekDegerAsync<int>("""
            insert into public.telerad_kurum
                   (taraf_id, yon, dicom_ae_title, sube_id, bakanlik_gonderim,
                    skrs_kodu, msh_uygulama)
            values (@p0, 1, '', @p1, @p2, '12345', 'GENOTIP') returning id
            """, t, [taraf, sube, bakanlik], Iptal);
        var hasta = await b.TekDegerAsync<int>(
            "insert into public.taraf (unvan, kod, hasta, sube_id) "
            + "values ('BAKANLIK TEST HASTA', 'BKNHST', 1, @p0) returning id",
            t, [sube], Iptal);
        return (sube, kurum, hasta);
    }

    /// <summary>
    /// RADYOLOJİ HİZMETİ TESTİN KENDİSİNDEN: dev veritabanında radyoloji
    /// işaretli hizmet bulunmayabiliyor ve istem tetiği (514) modalitesiz
    /// hizmeti reddediyor - "ilk hizmeti" ödünç almak bu yüzden kırılgan.
    /// </summary>
    private static Task<int> HizmetAcAsync(NpgsqlConnection b, NpgsqlTransaction t, int sube)
        => b.TekDegerAsync<int>(
            "insert into public.hizmet (kod, ad, radyoloji, modalite, sut_kodu, loinc, sube_id) "
            + "values (@p0, 'BAKANLIK TEST BT TETKİKİ', 1, 1, '801950', '24972-2', @p1) "
            + "returning id",
            t, [$"BKN{Guid.NewGuid().ToString("N")[..8]}", sube], Iptal);

    /// <summary>Rapor + bölümler: gövde parçalarını yazan tek yardımcı.</summary>
    private static async Task<int> RaporAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int sube, int hasta, string bulgular, string sonuc)
    {
        var hizmet = await HizmetAcAsync(b, t, sube);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum)
            values (@p0, @p1, @p2, 1, @p3, 3) returning id
            """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12]], Iptal);
        var rapor = await b.TekDegerAsync<int>(
            "insert into public.radyoloji_rapor (istem_id, durum) values (@p0, 1) returning id",
            t, [istem], Iptal);

        // BAŞLIK SERBEST, PARÇA TÜRETİLİR (809 tetiği): ekran ne yazarsa
        //   yazsın parça numarası veriye düşer.
        await b.CalistirAsync("""
            insert into public.radyoloji_rapor_bolum (rapor_id, sira, baslik, metin)
            values (@p0, 1, 'Teknik', 'Rutin protokol.'),
                   (@p0, 2, 'Bulgular', @p1),
                   (@p0, 3, 'Sonuç ve Öneriler', @p2)
            """, t, [rapor, bulgular, sonuc], Iptal);
        return rapor;
    }

    private static Task AyarAsync(NpgsqlConnection b, NpgsqlTransaction t, string deger)
        => b.CalistirAsync(
            "update public.referans set deger = @p0 where anahtar = 'radyoloji.bakanlik_profili'",
            t, [deger], Iptal);

    // ------------------------------------------------------------ parçalar ----

    [Fact]
    public async Task Bolum_basligindan_parca_numarasi_turer()
    {
        if (!_olgu.Baglandi(nameof(Bolum_basligindan_parca_numarasi_turer))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta,
            new string('a', 80), "Kontrol önerilir.");

        var parcalar = await b.TekDegerAsync<string>("""
            select string_agg(baslik || '=' || bakanlik_parca, ',' order by sira)
              from public.radyoloji_rapor_bolum where rapor_id = @p0
            """, t, [rapor], Iptal);

        Assert.Equal("Teknik=1,Bulgular=3,Sonuç ve Öneriler=4", parcalar);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Taninmayan_baslik_parcasiz_kalir()
    {
        if (!_olgu.Baglandi(nameof(Taninmayan_baslik_parcasiz_kalir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // SESSİZCE YANLIŞ PARÇAYA YAZMAKTANSA EKSİK DEMEK: tanınmayan başlık
        //   0 kalır ve gönderim öncesi kontrolde görünür.
        var parca = await b.TekDegerAsync<short>(
            "select public.fn_rad_bakanlik_parca('Teknisyen Notu')", null, [], Iptal);
        Assert.Equal(0, parca);
    }

    // ------------------------------------------------------- 50 karakter ----

    [Fact]
    public async Task Kisa_bulgular_gonderilemez()
    {
        if (!_olgu.Baglandi(nameof(Kisa_bulgular_gonderilemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta, "Normal.", "Kontrol.");

        var eksik = await b.TekDegerAsync<string>(
            "select public.fn_rad_bakanlik_eksik(@p0)", t, [rapor], Iptal) ?? "";
        Assert.Contains("50 karakter", eksik);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Sonuc_bolumu_bos_ise_gonderilemez()
    {
        if (!_olgu.Baglandi(nameof(Sonuc_bolumu_bos_ise_gonderilemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta, new string('b', 60), "");

        var eksik = await b.TekDegerAsync<string>(
            "select public.fn_rad_bakanlik_eksik(@p0)", t, [rapor], Iptal) ?? "";
        Assert.Contains("Sonuç ve Öneriler", eksik);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Dolu_rapor_gonderilebilir()
    {
        if (!_olgu.Baglandi(nameof(Dolu_rapor_gonderilebilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta,
            "Her iki akciğer parankimi normal görünümde, plevral efüzyon yok.",
            "Patolojik bulgu saptanmadı.");

        Assert.Equal("", await b.TekDegerAsync<string>(
            "select public.fn_rad_bakanlik_eksik(@p0)", t, [rapor], Iptal));
        await t.RollbackAsync();
    }

    // ------------------------------------------------------- onay kapısı ----

    [Fact]
    public async Task Ayar_kapaliyken_onay_engellenmez()
    {
        if (!_olgu.Baglandi(nameof(Ayar_kapaliyken_onay_engellenmez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // ÖZEL HASTANE MÜŞTERİSİ BAKANLIK KURALINA ÇARPMAZ: profil kapalıyken
        //   kısa Bulgular onayı durdurmaz.
        await AyarAsync(b, t, "0");
        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta, "Normal.", "Kontrol.");

        Assert.Equal("", await b.TekDegerAsync<string>(
            "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", t, [rapor], Iptal));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ayar_acikken_onay_engellenir()
    {
        if (!_olgu.Baglandi(nameof(Ayar_acikken_onay_engellenir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        await AyarAsync(b, t, "1");
        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var rapor = await RaporAcAsync(b, t, sube, hasta, "Normal.", "Kontrol.");

        var engel = await b.TekDegerAsync<string>(
            "select public.fn_radyoloji_rapor_onaylanabilir(@p0)", t, [rapor], Iptal) ?? "";
        // REDDİ GÖNDERİM ANINDA ÖĞRENMEK GEÇ: rapor o an kilitlenmiş olurdu.
        Assert.Contains("Bakanlık profili", engel);
        await t.RollbackAsync();
    }

    // --------------------------------------------------------- modalite ----

    [Theory]
    [InlineData((short)1, "CT")]
    [InlineData((short)2, "MR")]
    [InlineData((short)4, "CR")]
    [InlineData((short)6, "BMD")]
    public async Task Modalite_dicom_karsiligi(short modalite, string beklenen)
    {
        if (!_olgu.Baglandi(nameof(Modalite_dicom_karsiligi))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        Assert.Equal(beklenen, await b.TekDegerAsync<string>(
            "select public.fn_rad_modalite_kod(@p0)", null, [modalite], Iptal));
    }

    [Fact]
    public async Task Eslenmemis_modalite_bos_doner()
    {
        if (!_olgu.Baglandi(nameof(Eslenmemis_modalite_bos_doner))) return;
        await using var b = await _olgu.Gerekli().AcAsync();

        // UYDURMA KOD ÜRETİLMEZ: iki harf şartını sağlamak için "XX" dönmek,
        //   mesajı geçirir ama tetkiki yanlış yönteme yazardı.
        Assert.Equal("", await b.TekDegerAsync<string>(
            "select public.fn_rad_modalite_kod(@p0)", null, [(short)99], Iptal));
    }

    // --------------------------------------------------------- kontrast ----

    [Fact]
    public async Task Kontrast_obx17_bicimi()
    {
        if (!_olgu.Baglandi(nameof(Kontrast_obx17_bicimi))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var hizmet = await HizmetAcAsync(b, t, sube);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum,
                    kontrast, kontrast_ml, kontrast_yol, kontrast_madde,
                    kontrast_konsantrasyon)
            values (@p0, @p1, @p2, 1, @p3, 2, 1, 80, 'IV', 'Ioheksol', 300)
            returning id
            """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12]], Iptal);

        Assert.Equal("IV^Ioheksol^300", await b.TekDegerAsync<string>(
            "select public.fn_rad_kontrast_obx17(@p0)", t, [istem], Iptal));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kontrast_yoksa_obx17_yazilmaz()
    {
        if (!_olgu.Baglandi(nameof(Kontrast_yoksa_obx17_yazilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, _, hasta) = await ZeminAsync(b, t, 0);
        var hizmet = await HizmetAcAsync(b, t, sube);
        var istem = await b.TekDegerAsync<int>("""
            insert into public.radyoloji_istem
                   (sube_id, hasta_id, hizmet_id, modalite, accession_no, durum, kontrast)
            values (@p0, @p1, @p2, 1, @p3, 2, 0) returning id
            """, t, [sube, hasta, hizmet, Guid.NewGuid().ToString("N")[..12]], Iptal);

        Assert.Equal("", await b.TekDegerAsync<string>(
            "select public.fn_rad_kontrast_obx17(@p0)", t, [istem], Iptal));
        await t.RollbackAsync();
    }

    // -------------------------------------------------------- accession ----

    [Fact]
    public async Task Bakanlik_kurumunda_accession_zorunlu()
    {
        if (!_olgu.Baglandi(nameof(Bakanlik_kurumunda_accession_zorunlu))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, kurum, _) = await ZeminAsync(b, t, 1);

        // GÖRÜNTÜ İLE İSTEM YALNIZ BU NUMARAYLA EŞLEŞİR (kılavuz §5.2):
        //   boş accession, raporun hiçbir çekime oturmaması demek.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
            values (@p0, '', 1, 1, @p1)
            """, t, [kurum, sube], Iptal));
        Assert.Contains("accession", h.MessageText, StringComparison.OrdinalIgnoreCase);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Ayni_kurumda_accession_tekrar_edemez()
    {
        if (!_olgu.Baglandi(nameof(Ayni_kurumda_accession_tekrar_edemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, kurum, _) = await ZeminAsync(b, t, 1);
        var no = Guid.NewGuid().ToString("N")[..12];
        for (var i = 0; i < 1; i++)
            await b.CalistirAsync("""
                insert into public.telerad_istek
                       (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
                values (@p0, @p2, 1, 1, @p1)
                """, t, [kurum, sube, no], Iptal);

        await b.CalistirAsync("savepoint sp_ikinci", t, [], Iptal);
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
            values (@p0, @p2, 1, 1, @p1)
            """, t, [kurum, sube, no], Iptal));
        Assert.Equal("23505", h.SqlState);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kapali_kurumda_accession_serbest()
    {
        if (!_olgu.Baglandi(nameof(Kapali_kurumda_accession_serbest))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // KURAL HERKESE UYGULANMAZ: Bakanlığa bildirmeyen kurumda numara
        //   kurum portalından sonradan da gelebilir.
        var (sube, kurum, _) = await ZeminAsync(b, t, 0);
        var id = await b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
            values (@p0, '', 1, 1, @p1) returning id
            """, t, [kurum, sube], Iptal);
        Assert.True(id > 0);
        await t.RollbackAsync();
    }

    // ------------------------------------------------------ eksik listesi ----

    [Fact]
    public async Task Eksik_listesi_alan_adlariyla_doner()
    {
        if (!_olgu.Baglandi(nameof(Eksik_listesi_alan_adlariyla_doner))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, kurum, _) = await ZeminAsync(b, t, 1);
        var istek = await b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
            values (@p0, @p2, 1, 1, @p1) returning id
            """, t, [kurum, sube, Guid.NewGuid().ToString("N")[..10]], Iptal);

        var eksik = await b.TekDegerAsync<string>(
            "select public.fn_telerad_bakanlik_eksik(@p0)", t, [istek], Iptal) ?? "";
        Assert.Contains("hasta TCKN", eksik);
        Assert.Contains("isteyen hekim TCKN", eksik);
        Assert.Contains("onaylı rapor", eksik);
        // Kurum alanları dolu verildi: onlar listede OLMAMALI.
        Assert.DoesNotContain("SKRS", eksik);
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kapali_kurumda_eksik_listesi_bos()
    {
        if (!_olgu.Baglandi(nameof(Kapali_kurumda_eksik_listesi_bos))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, kurum, _) = await ZeminAsync(b, t, 0);
        var istek = await b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id)
            values (@p0, '', 1, 1, @p1) returning id
            """, t, [kurum, sube], Iptal);

        Assert.Equal("", await b.TekDegerAsync<string>(
            "select public.fn_telerad_bakanlik_eksik(@p0)", t, [istek], Iptal));
        await t.RollbackAsync();
    }

    [Fact]
    public async Task Hekim_tckn_bicimi_denetlenir()
    {
        if (!_olgu.Baglandi(nameof(Hekim_tckn_bicimi_denetlenir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (sube, kurum, _) = await ZeminAsync(b, t, 0);
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, sube_id, isteyen_hekim_tckn)
            values (@p0, @p2, 1, 1, @p1, 'ABC123')
            """, t, [kurum, sube, Guid.NewGuid().ToString("N")[..10]], Iptal));
        Assert.Equal("23514", h.SqlState);          // check constraint
        await t.RollbackAsync();
    }
}
