using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// PROFİLE GÖRE GEÇERLİ ROLLER (786).
///
/// Kullanıcı: *"profili görüntüleme yaptım bütün roller görünüyor.. isg yaptım
/// yine bütün roller görünüyor.. böyle olmasın.. profil sayfasında altta her
/// bir profil için geçerli (aktif) rolleri işaretleyeyim.. üstte kaydet deyip
/// o profilin rollerine girince onlar geçerli olsun"*.
///
/// Haritayı `rol.aktif` alanına yazan TEK yer `fn_kurum_tipi_rol_uygula` -
/// API de, ileride bir betik de aynı duvara çarpsın. Buradaki testler o
/// fonksiyonun sözünü korur: haritada olmayana dokunma, kilitli rolü kapatma.
/// </summary>
public sealed class ProfilRolleriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static Task HaritaYazAsync(NpgsqlConnection b, NpgsqlTransaction t,
                                       string tip, string kod, short gecerli)
        => b.CalistirAsync("""
            insert into public.kurum_tipi_rol (kurum_tipi, rol_kod, gecerli)
            values (@p0, @p1, @p2)
            on conflict (kurum_tipi, rol_kod) do update set gecerli = excluded.gecerli
            """, t, [tip, kod, gecerli], CancellationToken.None);

    private static Task<short> AktifAsync(NpgsqlConnection b, NpgsqlTransaction t, string kod)
        => b.TekDegerAsync<short>("select aktif from public.rol where kod = @p0",
                                  t, [kod], CancellationToken.None);

    [VtFact]
    public async Task Harita_rol_aktifine_UYGULANIR()
    {
        if (!_olgu.Baglandi(nameof(Harita_rol_aktifine_UYGULANIR))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        await HaritaYazAsync(b, t, "test_tipi", "dis_hekimi", 0);
        await HaritaYazAsync(b, t, "test_tipi", "goz_hekimi", 1);
        await b.CalistirAsync("update public.rol set aktif = 1 where kod in ('dis_hekimi','goz_hekimi')",
                              t, [], CancellationToken.None);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);

        Assert.Equal((short)0, await AktifAsync(b, t, "dis_hekimi"));   // işaretsiz -> pasif
        Assert.Equal((short)1, await AktifAsync(b, t, "goz_hekimi"));   // işaretli  -> aktif

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Haritada_OLMAYAN_role_dokunulmaz()
    {
        if (!_olgu.Baglandi(nameof(Haritada_OLMAYAN_role_dokunulmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kurumun kendi açtığı, hiçbir profile bağlanmamış rol: profil
        //   değişimi onu sessizce kapatmamalı.
        await b.CalistirAsync("update public.rol set aktif = 1 where kod = 'kalite'",
                              t, [], CancellationToken.None);
        await HaritaYazAsync(b, t, "test_tipi", "dis_hekimi", 0);

        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);

        Assert.Equal((short)1, await AktifAsync(b, t, "kalite"));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Yonetici_ve_atanmamis_PASIFE_ALINAMAZ()
    {
        if (!_olgu.Baglandi(nameof(Yonetici_ve_atanmamis_PASIFE_ALINAMAZ))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Doğrudan yazma REDDEDİLİR: ikisi de kapanırsa kurum kendi sistemine
        //   giremez. Kural tetikte - ekran unutsa da tutar.
        foreach (var kod in new[] { "yonetici", "atanmamis" })
        {
            await b.CalistirAsync("savepoint sp_kilit", t, [], CancellationToken.None);
            var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
                "update public.rol set aktif = 0 where kod = @p0", t, [kod], CancellationToken.None));
            Assert.Equal("GK422", h.SqlState);
            await b.CalistirAsync("rollback to savepoint sp_kilit", t, [], CancellationToken.None);
        }

        // Harita 0 dese bile uygulama onları ATLAR: tek rol yüzünden bütün
        //   profil uygulaması durmasın.
        await HaritaYazAsync(b, t, "test_tipi", "yonetici", 0);
        await b.CalistirAsync("select public.fn_kurum_tipi_rol_uygula('test_tipi')",
                              t, [], CancellationToken.None);
        Assert.Equal((short)1, await AktifAsync(b, t, "yonetici"));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Bos_tip_reddedilir()
    {
        if (!_olgu.Baglandi(nameof(Bos_tip_reddedilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Tipsiz uygulama "hiçbir satır eşleşmedi" diye sessizce geçseydi,
        //   ekranın gönderdiği boş tip fark edilmeden kaybolurdu.
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_kurum_tipi_rol_uygula('')", t, [], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);

        await t.RollbackAsync();
    }
}

/// <summary>
/// İSKONTO BASAMAKLARI YALNIZ KADRODA (789).
///
/// Kullanıcı: *"yönetici rolünden basamak yetkilerini kaldır"*. 787/788 üç
/// basamağı üç kadro rolüne vermişti; `yonetici` üçünü de YEDEK taşıyordu.
/// Yedek kalkınca yeni tehlike doğuyor: kadroya kimse atanmamışsa o basamağı
/// imzalayacak kimse yok ve talep kuyrukta SESSİZCE bekler.
/// `v_onay_basamak_sahibi` bunu görünür kılar.
/// </summary>
public sealed class OnayBasamakSahibiTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Yonetici_artik_IMZA_atmaz_ama_ekrani_gorur()
    {
        if (!_olgu.Baglandi(nameof(Yonetici_artik_IMZA_atmaz_ama_ekrani_gorur))) return;
        var veri = _olgu.Gerekli();

        var basamak = await veri.TekDegerAsync<long>("""
            select count(*)
              from public.rol r
              join public.rol_yetki ry on ry.rol_id = r.id
              join public.yetki y on y.id = ry.yetki_id
             where r.kod = 'yonetici' and y.kod like 'belge.iskonto_onay_%'
            """, [], CancellationToken.None);
        Assert.Equal(0, basamak);

        // ONAY EKRANI KALIR: imza atmasa da zincirin nerede takıldığını
        //   görmek zorunda - "onaya gitti, sonra ne oldu" sorusunun tek
        //   cevabı o ekran.
        var ekran = await veri.TekDegerAsync<long>("""
            select count(*)
              from public.rol r
              join public.rol_yetki ry on ry.rol_id = r.id
              join public.yetki y on y.id = ry.yetki_id
             where r.kod = 'yonetici' and y.kod = 'iskonto_onay'
            """, [], CancellationToken.None);
        Assert.Equal(1, ekran);
    }

    [VtFact]
    public async Task Sahipsiz_basamak_GORUNUR()
    {
        if (!_olgu.Baglandi(nameof(Sahipsiz_basamak_GORUNUR))) return;
        var veri = _olgu.Gerekli();

        // Görünüm bir SAYIM, kapı değil: talebi açmayı engellemek, indirim
        //   yapmak isteyen bankoyu kurumun kadro eksiğinden ötürü durdururdu.
        var satirlar = await veri.ListeAsync("""
            select yetki_kodu, kisi_sayisi, sahipsiz, roller
              from public.v_onay_basamak_sahibi
             where yetki_kodu like 'belge.iskonto_onay_%'
             order by yetki_kodu
            """, [], o => (Kod: o.GetString(0), Kisi: o.GetInt64(1),
                           Sahipsiz: o.GetInt16(2), Roller: o.GetString(3)),
            CancellationToken.None);

        Assert.Equal(3, satirlar.Count);
        foreach (var s in satirlar)
        {
            // Basamağın ROLÜ her hâlükârda var (787/788); kişi olmayabilir.
            Assert.NotEqual("", s.Roller);
            Assert.Equal(s.Kisi == 0 ? (short)1 : (short)0, s.Sahipsiz);
        }
    }
}

/// <summary>
/// ÇAĞRI MERKEZİ ROLLERİ (791).
///
/// Kullanıcı: *"Çağrı Merkezi Ajanı ve Çağrı Merkezi Sorumlusu da ekle"*.
///
/// İki kural korunuyor: çağrı merkezi hastanın PARASINI görmez (telefonda
/// borç konuşmak bankonun işidir) ve ajan ile sorumlu arasındaki fark
/// silme/şablon yetkisidir - ikisi aynı olsaydı ayrı rol olmalarının anlamı
/// kalmazdı.
/// </summary>
public sealed class CagriMerkeziRolleriTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Cagri_merkezi_PARA_ekranlarini_gormez()
    {
        if (!_olgu.Baglandi(nameof(Cagri_merkezi_PARA_ekranlarini_gormez))) return;

        var sayi = await _olgu.Gerekli().TekDegerAsync<long>(
            "select count(*) from public.rol r "
            + "  join public.rol_yetki ry on ry.rol_id = r.id "
            + "  join public.yetki y on y.id = ry.yetki_id "
            + " where r.kod in ('cagri_ajani','cagri_sorumlu') "
            + "   and y.kod in ('belge','belge_satir','kasa_islem','mali_hareket','hesap')",
            [], CancellationToken.None);
        Assert.Equal(0, sayi);
    }

    [VtFact]
    public async Task Ajan_randevu_SILEMEZ_sorumlu_siler()
    {
        if (!_olgu.Baglandi(nameof(Ajan_randevu_SILEMEZ_sorumlu_siler))) return;
        var veri = _olgu.Gerekli();

        static string Sql(string rol, string yetki, string alan) =>
            $"select coalesce(max(ry.{alan}), -1) from public.rol r "
            + "  join public.rol_yetki ry on ry.rol_id = r.id "
            + "  join public.yetki y on y.id = ry.yetki_id "
            + $" where r.kod = '{rol}' and y.kod = '{yetki}'";

        Assert.Equal((short)0, await veri.TekDegerAsync<short>(Sql("cagri_ajani", "randevu", "sil"), [], CancellationToken.None));
        Assert.Equal((short)1, await veri.TekDegerAsync<short>(Sql("cagri_sorumlu", "randevu", "sil"), [], CancellationToken.None));

        // HASTA KAYDINI İKİSİ DE SİLEMEZ: telefonla açılan kaydı telefonla
        //   silmek, hasta geçmişini çağrı masasına emanet etmek olurdu.
        foreach (var rol in new[] { "cagri_ajani", "cagri_sorumlu" })
            Assert.Equal((short)0, await veri.TekDegerAsync<short>(Sql(rol, "hasta", "sil"), [], CancellationToken.None));

        // Hatırlatma şablonu yalnız sorumluda.
        Assert.Equal((short)-1, await veri.TekDegerAsync<short>(Sql("cagri_ajani", "bildirim_sablon", "gor"), [], CancellationToken.None));
        Assert.Equal((short)1, await veri.TekDegerAsync<short>(Sql("cagri_sorumlu", "bildirim_sablon", "gor"), [], CancellationToken.None));
    }
}
