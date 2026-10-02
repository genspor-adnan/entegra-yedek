using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// KURUM PORTALI — DIŞ KURUM KENDİ İSTEĞİNİ AÇAR (804).
///
/// Kullanıcı: *"kurum portalı istek ekranıyla devam et"*.
///
/// 794/795'te portal KAPSAMI yazılmıştı (okuma) ama rolde `teleradyoloji`
/// yetkisi yoktu ve YAZMA tarafı açıktı. Kural <b>veritabanında</b>: aynı
/// istek portal ekranından da, API'den de, ileride DICOM alımından da
/// açılabilir - "ne yazabilir" sorusunun cevabı tek yerde olmalı.
/// </summary>
public sealed class TeleradPortalTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>İki kurum + birinin portal kullanıcısı (kurumun cari kaydı).</summary>
    private static async Task<(int Kurum, int BaskaKurum, int PortalKullanici, int Sube)>
        KurulumAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        var sube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktif = 1 order by id limit 1",
            t, [], CancellationToken.None);

        async Task<int> KurumAc(string kod, string unvan)
        {
            var taraf = await b.TekDegerAsync<int>("""
                insert into public.taraf (unvan, kod, musteri, sube_id)
                values (@p1, @p2, 1, @p0) returning id
                """, t, [sube, unvan, kod], CancellationToken.None);
            return await b.TekDegerAsync<int>("""
                insert into public.telerad_kurum (taraf_id, yon, dicom_ae_title, sube_id)
                values (@p0, 1, '', @p1) returning id
                """, t, [taraf, sube], CancellationToken.None);
        }

        var kurum = await KurumAc("TRPRT1", "PORTAL TEST KURUMU");
        var baska = await KurumAc("TRPRT2", "ÖTEKİ KURUM");

        // PORTAL KULLANICISI KURUMUN CARİ KAYDIDIR (795): ayrı bir "kurum
        //   kullanıcısı" tablosu yok, bağ `telerad_kurum.taraf_id`.
        var taraf1 = await b.TekDegerAsync<int>(
            "select taraf_id from public.telerad_kurum where id = @p0",
            t, [kurum], CancellationToken.None);
        var rol = await b.TekDegerAsync<int>(
            "select id from public.rol where kod = 'dis_istem_kurumu'",
            t, [], CancellationToken.None);
        Assert.True(rol > 0, "Dis kurum portal rolu yok (795).");
        await b.CalistirAsync("""
            insert into public.taraf_kullanici (id, kod, parola_hash, rol_id, aktif)
            values (@p0, 'trprt1', '', @p1, 1)
            on conflict (id) do update set rol_id = @p1, aktif = 1
            """, t, [taraf1, rol], CancellationToken.None);

        return (kurum, baska, taraf1, sube);
    }

    private static Task<int> IstekAcAsync(NpgsqlConnection b, NpgsqlTransaction t,
        int kurum, int sube, int ekleyen)
        => b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum,
                    klinik_bilgi, cekim_zamani, gelis_zamani, sube_id, ekleyen)
            values (@p0, @p3, 1, 1, 1, 'portal denemesi', now(), now(), @p1, @p2)
            returning id
            """, t, [kurum, sube, ekleyen, Guid.NewGuid().ToString("N")[..10]],
            CancellationToken.None);

    [VtFact]
    public async Task Portal_kullanicisi_KENDI_kurumu_adina_acar()
    {
        if (!_olgu.Baglandi(nameof(Portal_kullanicisi_KENDI_kurumu_adina_acar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, baska, kullanici, sube) = await KurulumAsync(b, t);

        // Kendi kurumu: geçer.
        var id = await IstekAcAsync(b, t, kurum, sube, kullanici);
        Assert.True(id > 0);

        // BAŞKASININ ADINA AÇAMAZ: istemciden gelen kurum değerine güvenilmez.
        await b.CalistirAsync("savepoint sp_baska", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(
            () => IstekAcAsync(b, t, baska, sube, kullanici));
        Assert.Equal("42501", h.SqlState);
        await b.CalistirAsync("rollback to savepoint sp_baska", t, [], CancellationToken.None);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Portal_istegi_GORUNTU_BEKLENIYOR_dogar()
    {
        if (!_olgu.Baglandi(nameof(Portal_istegi_GORUNTU_BEKLENIYOR_dogar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // İŞİN AKIŞI MERKEZDE BAŞLAR: portal isteği "görüntü bekleniyor"
        //   doğar; atama, ücret ve teslim raporlama merkezinin işidir.
        //   Kurum kendi işini "onaylı" açıp faturalatamasın.
        var (kurum, _, kullanici, sube) = await KurulumAsync(b, t);
        // GÖRÜNTÜ HENÜZ GELMEDİ (goruntu_durum 0): görüntü "tamam" olsaydı
        //   797 tetiği isteği kendiliğinden "Sırada"ya (2) alırdı - o da doğru
        //   davranış, ama burada ölçtüğümüz portal kuralı.
        var id = await b.TekDegerAsync<int>("""
            insert into public.telerad_istek
                   (kurum_id, dis_erisim_no, oncelik, modalite, goruntu_durum,
                    durum, ucret, cekim_zamani, gelis_zamani, sube_id, ekleyen)
            values (@p0, 'PRT-1', 1, 1, 0, 6, 5000, now(), now(), @p1, @p2)
            returning id
            """, t, [kurum, sube, kullanici], CancellationToken.None);

        var satir = await b.ListeAsync(
            "select durum, ucret from public.telerad_istek where id = @p0",
            t, [id], o => (Durum: o.GetInt16(0), Ucret: o.GetDecimal(1)),
            CancellationToken.None);
        Assert.Equal((short)1, satir[0].Durum);
        Assert.Equal(0m, satir[0].Ucret);

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Portal_MERKEZIN_alanlarini_degistiremez()
    {
        if (!_olgu.Baglandi(nameof(Portal_MERKEZIN_alanlarini_degistiremez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (kurum, _, kullanici, sube) = await KurulumAsync(b, t);
        var id = await IstekAcAsync(b, t, kurum, sube, kullanici);

        // KLİNİK BİLGİYİ DÜZELTEBİLİR: portalın işi bu.
        await b.CalistirAsync("""
            update public.telerad_istek
               set klinik_bilgi = 'düzeltilmiş bilgi', degistiren = @p1
             where id = @p0
            """, t, [id, kullanici], CancellationToken.None);

        // DURUMU DEĞİŞTİREMEZ: sessizce yutmak yerine HATA - kullanıcının
        //   ekranda yaptığı değişikliği yutup "kaydedildi" demek ona yanlış
        //   bir dünya gösterirdi.
        await b.CalistirAsync("savepoint sp_durum", t, [], CancellationToken.None);
        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync("""
            update public.telerad_istek set durum = 6, degistiren = @p1 where id = @p0
            """, t, [id, kullanici], CancellationToken.None));
        Assert.Equal("42501", h.SqlState);
        await b.CalistirAsync("rollback to savepoint sp_durum", t, [], CancellationToken.None);

        // İÇ KULLANICI AYNI İŞİ YAPABİLİR: kural yalnız portal rolleri için.
        await b.CalistirAsync(
            "update public.telerad_istek set durum = 2, degistiren = 1 where id = @p0",
            t, [id], CancellationToken.None);
        Assert.Equal((short)2, await b.TekDegerAsync<short>(
            "select durum from public.telerad_istek where id = @p0", t, [id],
            CancellationToken.None));

        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Dis_kurum_rolu_ISTEK_ACABILIR()
    {
        if (!_olgu.Baglandi(nameof(Dis_kurum_rolu_ISTEK_ACABILIR))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // 795'te yetki BİLEREK verilmemişti (ekranı yoktu); 804'te karşılığı
        //   geldi. Silme YOK: açılmış isteği geri çekmek merkezin işidir.
        var yetki = await b.ListeAsync("""
            select ry.gor, ry.ekle, ry.degistir, ry.sil
              from public.rol_yetki ry
              join public.rol r on r.id = ry.rol_id
              join public.yetki y on y.id = ry.yetki_id
             where r.kod = 'dis_istem_kurumu' and y.kod = 'teleradyoloji'
            """, t, [], o => (Gor: o.GetInt16(0), Ekle: o.GetInt16(1),
                              Degistir: o.GetInt16(2), Sil: o.GetInt16(3)),
            CancellationToken.None);

        Assert.Single(yetki);
        Assert.Equal((short)1, yetki[0].Gor);
        Assert.Equal((short)1, yetki[0].Ekle);
        Assert.Equal((short)0, yetki[0].Sil);

        await t.RollbackAsync();
    }

    [Fact]
    public void Kurum_secim_listesi_PORTALDA_daralir()
    {
        // Dış kurum kullanıcısı "Gönderen Kurum" kutusunda ÖTEKİ kurumların
        //   adını görmemeli - rakip listesi olurdu (804).
        var kosul = PortalKapsam.LookupKosulu("public.v_telerad_kurum_lookup",
                                              PortalKapsam.DisKurum);
        Assert.False(string.IsNullOrEmpty(kosul));
        Assert.Contains("telerad_kurum", kosul!);
        Assert.Contains("{kullanici}", kosul);

        // KURALI OLMAYAN LOOKUP AÇIK KALIR: lookup kayıt erişimi değil, alan
        //   doldurma listesidir - kapalı varsayılan portal kullanıcısının
        //   hasta/tetkik seçmesini de engellerdi.
        Assert.Null(PortalKapsam.LookupKosulu("public.v_hasta_lookup",
                                              PortalKapsam.DisKurum));
        // İÇ KULLANICI hiçbir zaman süzülmez.
        Assert.Null(PortalKapsam.LookupKosulu("public.v_telerad_kurum_lookup", 0));
    }
}
